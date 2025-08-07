// イベント管理システム

// イベント発動時のアクションインターフェース
interface EventAction {
    void execute();
}

// イベント終了時のアクションインターフェース  
interface EventEndAction {
    void execute();
}

// イベントクラス
class Event {
    String eventName;           
    int triggerSeason;         
    float probability;         
    int duration;              // 持続ターン数（1 = 1ターンのみ、0は使用しない）
    int originalDuration;      // 元の持続時間を保持（ダミー化前の値）
    int forecastTiming;        
    String forecastMessage;    
    String effectDescription;  
    boolean isDummy;           
    
    EventAction onStart;       
    EventEndAction onEnd;      
    
    // 通常のコンストラクタ
    Event(String name, int season, float prob, int dur, int forecast, 
          String msg, String effect, EventAction startAction, EventEndAction endAction) {
        eventName = name;
        triggerSeason = season;
        probability = prob;
        duration = dur;
        originalDuration = dur;  // 元の持続時間を保存
        forecastTiming = forecast;
        forecastMessage = msg;
        effectDescription = effect;
        onStart = startAction;
        onEnd = endAction;
        isDummy = false;
    }
    
    // ダミーイベント用コンストラクタ
    Event(Event original, boolean dummy) {
        this.eventName = original.eventName;
        this.triggerSeason = original.triggerSeason;
        this.probability = original.probability;
        this.originalDuration = original.duration;  // 元の持続時間を保存
        this.duration = dummy ? 1 : original.duration;  // ダミーの場合は1ターンのみ
        this.forecastTiming = original.forecastTiming;
        this.forecastMessage = original.forecastMessage;
        this.effectDescription = original.effectDescription;
        this.onStart = original.onStart;
        this.onEnd = original.onEnd;
        this.isDummy = dummy;
    }
    
    // イベント開始処理
    void start() {
        if (!isDummy && onStart != null) {
            onStart.execute();
        }
    }
    
    // イベント終了処理
    void end() {
        if (!isDummy && onEnd != null) {
            onEnd.execute();
        }
    }
}

// 予報情報クラス
class ForecastInfo {
    String message;
    String eventName;
    boolean willOccur;
    int expectedDuration;
    
    ForecastInfo(String msg, String name, boolean occur, int duration) {
        message = msg;
        eventName = name;
        willOccur = occur;
        expectedDuration = duration;
    }
}

// イベント管理クラス
class EventManager {
    Event[] eventTemplates;
    Event[] eventSchedule;
    ForecastInfo[] forecastSchedule;
    Event activeEvent;
    int activeEventRemainingTurns;
    
    EventManager() {
        initializeEventTemplates();
        generateEventSchedule();
    }
    
    // イベントテンプレートの初期化
    void initializeEventTemplates() {
        ArrayList<Event> templates = new ArrayList<Event>();
        
        // 通常イベント（持続1ターン、予報なし）
        templates.add(new Event("通常", -1, 0.4, 1, 0, "", "通常の市場", 
            () -> { /* 何もしない */ },
            () -> { /* 何もしない */ }
        ));
        
        // 豊作イベント（本来は2ターン持続、予報あり、70%で実際に発生）
        templates.add(new Event("豊作", 0, 0.7, 2, 1, 
                 "来季は豊作の予報！（2ターン持続予定）", 
                 "供給増加により価格が20%低下", 
            () -> {
                updateEventEffect(0.8);
                for (int i = 0; i < riceBrandsInfo.length; i++) {
                    int additionalSupply = int(random(5, 15));
                    market.updateBrandStock(i, additionalSupply);
                }
                println("豊作イベント発動！供給増加・価格低下（2ターン持続）");
            },
            () -> {
                resetEventEffect();
                println("豊作イベント終了");
            }
        ));
        
        // 台風イベント（本来は1ターン持続、予報あり、60%で実際に発生）
        templates.add(new Event("台風", 0, 0.6, 1, 2, 
                 "台風接近中！備蓄推奨", 
                 "供給減少により価格が30%上昇", 
            () -> {
                updateEventEffect(1.3);
                for (int i = 0; i < riceBrandsInfo.length; i++) {
                    int reduction = min(market.getBrandStock(i), int(random(3, 8)));
                    market.updateBrandStock(i, -reduction);
                }
                println("台風イベント発動！供給減少・価格上昇");
            },
            () -> {
                resetEventEffect();
                println("台風イベント終了");
            }
        ));
        
        // 大雪イベント（本来は2ターン持続、予報あり、80%で実際に発生）
        templates.add(new Event("大雪", 1, 0.8, 2, 1, 
                 "大雪警報発令", 
                 "輸送困難により価格が20%上昇", 
            () -> {
                updateEventEffect(1.2);
                // 消費率を一時的に変更することはMarketクラスの構造上避ける
                println("大雪イベント発動！輸送困難");
            },
            () -> {
                resetEventEffect();
                println("大雪イベント終了");
            }
        ));
        
        // 花見需要イベント（春、1ターン持続、予報なし）
        templates.add(new Event("花見需要", 2, 0.3, 1, 0, "", 
                 "消費増加により価格が15%上昇", 
            () -> {
                updateEventEffect(1.15);
                println("花見需要イベント発動！消費増加");
            },
            () -> {
                resetEventEffect();
                println("花見需要イベント終了");
            }
        ));
        
        // 猛暑イベント（夏、2ターン持続、予報あり、75%で実際に発生）
        templates.add(new Event("猛暑", 3, 0.75, 2, 1, 
                 "記録的猛暑の予報", 
                 "品質低下により古米の価値が50%減少", 
            () -> {
                println("猛暑イベント発動！古米の価値低下");
                // 古米に対する特別な処理を後で追加可能
            },
            () -> {
                println("猛暑イベント終了");
            }
        ));
        
        // 米騒動イベント（全季節、3ターン持続、予報あり、50%で実際に発生）
        templates.add(new Event("米騒動", -1, 0.5, 3, 2, 
                 "市場に不穏な動き...（最大3ターン継続の可能性）", 
                 "需要急増！全ての米価格が2倍に", 
            () -> {
                updateEventEffect(2.0);
                println("米騒動発生！価格急騰！（3ターン持続）");
            },
            () -> {
                resetEventEffect();
                println("米騒動が収束しました");
            }
        ));
        
        // 配列に変換
        eventTemplates = templates.toArray(new Event[templates.size()]);
    }
    
    // ゲーム開始時に全イベントを抽選
    void generateEventSchedule() {
        eventSchedule = new Event[maxTurn];
        forecastSchedule = new ForecastInfo[maxTurn];
        
        // 1ターン目（インデックス0）はスキップして、2ターン目から開始
        for (int turn = 1; turn < maxTurn; turn++) {
            if (eventSchedule[turn] == null) {
                Event selectedEvent = selectEventForTurn(turn);
                if (selectedEvent != null) {
                    placeEventWithForecast(selectedEvent, turn);
                }
            }
        }
    }
    
    // ターンに応じたイベントを抽選
    Event selectEventForTurn(int turn) {
        int season = turn % 4; // 0:秋, 1:冬, 2:春, 3:夏
        ArrayList<Event> candidates = new ArrayList<Event>();
        
        // 該当季節のイベントと全季節イベントを候補に追加
        for (Event e : eventTemplates) {
            if (e.triggerSeason == season || e.triggerSeason == -1) {
                candidates.add(e);
            }
        }
        
        // 確率に基づいて抽選
        float rand = random(1);
        float cumulativeProbability = 0;
        
        for (Event e : candidates) {
            cumulativeProbability += e.probability;
            if (rand < cumulativeProbability) {
                return e;
            }
        }
        
        return candidates.get(0); // デフォルトは通常イベント
    }
    
    // イベントを予報付きで配置
    void placeEventWithForecast(Event event, int startTurn) {
        // 予報がないイベントは通常配置
        if (event.forecastTiming == 0) {
            placeEvent(event, startTurn, false);
            return;
        }
        
        // 予報があるイベントの場合、実際に発生するか判定
        boolean willActuallyOccur = random(1) < event.probability;
        
        // 予報を配置（元の持続時間を伝える）
        int forecastTurn = startTurn - event.forecastTiming;
        if (forecastTurn >= 0 && forecastTurn < maxTurn) {
            forecastSchedule[forecastTurn] = new ForecastInfo(
                event.forecastMessage,
                event.eventName,
                willActuallyOccur,
                event.originalDuration
            );
        }
        
        if (willActuallyOccur) {
            // 実際に発生する（フル期間）
            placeEvent(event, startTurn, false);
            println("予報設定: " + event.eventName + 
                   " (ターン" + startTurn + "から" + event.duration + "ターン発生)");
        } else {
            // ダミーイベントとして配置（1ターンのみ）
            Event dummyEvent = new Event(event, true);
            placeEvent(dummyEvent, startTurn, true);
            println("予報設定: " + event.eventName + 
                   " (ターン" + startTurn + "に予報のみ、実際は発生せず)");
            
            // ダミーイベントの後のターンで別のイベントを抽選する機会を作る
            for (int nextTurn = startTurn + 1; 
                 nextTurn < startTurn + event.originalDuration && nextTurn < maxTurn; 
                 nextTurn++) {
                if (eventSchedule[nextTurn] == null) {
                    // 空いたスロットに新しいイベントを抽選
                    Event replacementEvent = selectEventForTurn(nextTurn);
                    if (replacementEvent != null && !replacementEvent.eventName.equals("通常")) {
                        placeEvent(replacementEvent, nextTurn, false);
                        println("  → ターン" + nextTurn + "に代替イベント「" + 
                               replacementEvent.eventName + "」を配置");
                    }
                }
            }
        }
    }
    
    // イベントをスケジュールに配置
    void placeEvent(Event event, int startTurn, boolean isDummy) {
        int actualDuration = isDummy ? 1 : event.duration;
        
        for (int i = 0; i < actualDuration; i++) {
            if (startTurn + i < maxTurn && eventSchedule[startTurn + i] == null) {
                eventSchedule[startTurn + i] = event;
            }
        }
    }
    
    // 現在のターンのイベント処理
    void processCurrentTurn() {
        // 1ターン目（currentTurn == 1）は何もしない
        if (currentTurn == 1) return;
        
        if (currentTurn >= eventSchedule.length) return;
        
        Event currentEvent = eventSchedule[currentTurn];
        
        // 新しいイベントの開始
        if (currentEvent != null && currentEvent != activeEvent) {
            // 前のイベントが残っていたら終了
            if (activeEvent != null && !activeEvent.isDummy) {
                activeEvent.end();
            }
            
            // 新イベント開始
            activeEvent = currentEvent;
            activeEventRemainingTurns = currentEvent.duration;
            
            if (!currentEvent.isDummy) {
                // 実際のイベント発動
                activeEvent.start();
                println("イベント「" + currentEvent.eventName + 
                       "」が発動しました！（" + currentEvent.duration + "ターン持続）");
            } else {
                // ダミーイベントの場合
                println("予報された「" + currentEvent.eventName + 
                       "」は発生しませんでした。");
            }
        }
        
        // イベント継続カウント
        if (activeEvent != null) {
            activeEventRemainingTurns--;
            if (activeEventRemainingTurns <= 0) {
                if (!activeEvent.isDummy) {
                    activeEvent.end();
                }
                activeEvent = null;
            }
        }
    }
    
    // 現在のイベントを取得（ダミーでない場合のみ）
    Event getCurrentEvent() {
        if (activeEvent != null && !activeEvent.isDummy) {
            return activeEvent;
        }
        return null;
    }
    
    // 現在の予報を取得
    ForecastInfo getCurrentForecast() {
        // 1ターン目は予報なし
        if (currentTurn == 1) return null;
        
        if (currentTurn < forecastSchedule.length) {
            return forecastSchedule[currentTurn];
        }
        return null;
    }
    
    // デバッグ用：イベントスケジュールを詳細出力
    void printDetailedEventSchedule() {
        println("=== 詳細イベントスケジュール ===");
        for (int i = 0; i < min(maxTurn, eventSchedule.length); i++) {
            String seasonName = SEASONS[i % 4];
            String yearNum = str((i / 4) + 1);
            
            print("ターン" + i + " (" + yearNum + "年目 " + seasonName + "): ");
            
            if (eventSchedule[i] != null) {
                Event e = eventSchedule[i];
                if (e.isDummy) {
                    println(e.eventName + " [ダミー・効果なし]");
                } else {
                    String durationInfo = e.duration > 1 ? 
                        " [" + e.duration + "ターン持続]" : "";
                    println(e.eventName + durationInfo);
                }
            } else {
                println("イベントなし");
            }
            
            if (forecastSchedule[i] != null) {
                ForecastInfo f = forecastSchedule[i];
                String occurStatus = f.willOccur ? " ✓" : " ✗";
                println("  └ 予報: " + f.eventName + occurStatus);
            }
        }
    }
}