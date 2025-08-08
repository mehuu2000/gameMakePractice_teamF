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
    int[] triggerSeasons; // 発動季節の配列（0:秋, 1:冬, 2:春, 3:夏）複数指定可能   
    float probability; // 発動確率（0.0 - 1.0）         
    int duration; // 持続ターン数（1 = 1ターンのみ、0は使用しない）
    int originalDuration; // 元の持続時間を保持（ダミー化前の値）
    int forecastTiming; // 予報タイミング（0:なし, 1:1ターン前, 2:2ターン前）  
    String forecastMessage; // 予報メッセージ（予報がある場合のみ使用）    
    String effectDescription; // なぜそのようなことが起こったか（イベントポップアップで表示）
    String effectMessage; // ゲームに与える効果（左下の画面で表示）
    boolean isDummy; // ダミーイベントかどうか（予報のみで実際には発動しない）
    boolean isOnceOnly; // このイベントがゲーム中1回だけ発生するか
    
    EventAction onStart;       
    EventEndAction onEnd;      
    
    // 通常のコンストラクタ
    Event(String name, int[] seasons, float prob, int dur, int forecast, 
          String forecastMsg, String description, String message,
          boolean onceOnly, EventAction startAction, EventEndAction endAction) {
        eventName = name;
        triggerSeasons = seasons;
        probability = prob;
        duration = dur;
        originalDuration = dur;  // 元の持続時間を保存
        forecastTiming = forecast;
        forecastMessage = forecastMsg;
        effectDescription = description;
        effectMessage = message;
        isOnceOnly = onceOnly;
        onStart = startAction;
        onEnd = endAction;
        isDummy = false;
    }
    
    // ダミーイベント用コンストラクタ
    Event(Event original, boolean dummy) {
        this.eventName = original.eventName; // イベント名をコピー
        this.triggerSeasons = original.triggerSeasons; // 発動季節をコピー
        this.probability = original.probability; // 発動確率をコピー
        this.originalDuration = original.duration;  // 元の持続時間を保存
        this.duration = dummy ? 1 : original.duration;  // ダミーの場合は1ターンのみ
        this.forecastTiming = original.forecastTiming; // 予報タイミングをコピー
        this.forecastMessage = original.forecastMessage; // 予報メッセージをコピー
        this.effectDescription = original.effectDescription; // 効果の理由をコピー
        this.effectMessage = original.effectMessage; // 効果の説明をコピー
        this.isOnceOnly = original.isOnceOnly; // 1回限りかどうかをコピー
        this.onStart = original.onStart; // イベント開始時のアクションをコピー
        this.onEnd = original.onEnd; // イベント終了時のアクションをコピー
        this.isDummy = dummy; // ダミーイベントかどうかを設定
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
    ArrayList<String> usedOnceOnlyEvents; // 使用済みの1回限りイベント名を記録
    
    EventManager() {
        usedOnceOnlyEvents = new ArrayList<String>();
        initializeEventTemplates();
        generateEventSchedule();
    }
    
    // イベントテンプレートの初期化
    void initializeEventTemplates() {
        ArrayList<Event> templates = new ArrayList<Event>();
        
        // 通常イベント（持続1ターン、予報なし）
        templates.add(new Event("通常", new int[]{0, 1, 2, 3}, 1.0, 1, 0, "", 
                 "通常の市場",
                 "特別な効果なし",
                 false,  // 1回限りではない 
            () -> { /* 何もしない */ },
            () -> { /* 何もしない */ }
        ));

        // {"りょうおもい", "ほしひかり", "ゆめごこち", "つやおうじ"};
        // 豊作イベント（本来は2ターン持続、予報あり、70%で実際に発生）
        templates.add(new Event("豊作（りょうおもい）", new int[]{0}, 0.7, 2, 1, 
                 "来季は豊作の予報！（2ターン持続予定）",  // 予報メッセージ
                 "今期は天候に恵まれ、各地でりょうおもいが豊作となりました", // 効果の理由
                 "供給増加・りょうおもいの買値が20%低下", // 効果の説明
                 false,  // 1回限りではない 
            () -> {
                applyHarvestEvent("豊作（りょうおもい）", 0);
                println("豊作イベント発動！りょうおもいの供給増加・価格低下（2ターン持続）");
            },
            () -> {
                removeEventEffects("豊作（りょうおもい）");
                println("豊作イベント終了");
            }
        ));
        templates.add(new Event("豊作（ほしひかり）", new int[]{0}, 0.7, 2, 1, 
                 "来季は豊作の予報！（2ターン持続予定）", 
                 "今期は天候に恵まれ、各地でほしひかりが豊作となりました",
                 "供給増加・ほしひかりの買値が20%低下",
                 false,  // 1回限りではない 
            () -> {
                applyHarvestEvent("豊作（ほしひかり）", 1);
                println("豊作イベント発動！ほしひかりの供給増加・価格低下（2ターン持続）");
            },
            () -> {
                removeEventEffects("豊作（ほしひかり）");
                println("豊作イベント終了");
            }
        ));
        templates.add(new Event("豊作（ゆめごこち）", new int[]{0}, 0.7, 2, 1, 
                 "来季は豊作の予報！（2ターン持続予定）", 
                 "今期は天候に恵まれ、各地でゆめごこちが豊作となりました",
                 "供給増加・ゆめごこちの買値が20%低下",
                 false,  // 1回限りではない 
            () -> {
                applyHarvestEvent("豊作（ゆめごこち）", 2);
                println("豊作イベント発動！ゆめごこちの供給増加・価格低下（2ターン持続）");
            },
            () -> {
                removeEventEffects("豊作（ゆめごこち）");
                println("豊作イベント終了");
            }
        ));
        templates.add(new Event("豊作（つやおうじ）", new int[]{0}, 0.7, 2, 1, 
                 "来季は豊作の予報！（2ターン持続予定）", 
                 "今期は天候に恵まれ、各地でつやおうじが豊作となりました",
                 "供給増加・つやおうじの買値が20%低下",
                 false,  // 1回限りではない 
            () -> {
                applyHarvestEvent("豊作（つやおうじ）", 3);
                println("豊作イベント発動！つやおうじの供給増加・価格低下（2ターン持続）");
            },
            () -> {
                removeEventEffects("豊作（つやおうじ）");
                println("豊作イベント終了");
            }
        ));
        
        // 台風イベント（本来は1ターン持続、予報あり、60%で実際に発生）
        templates.add(new Event("台風接近！", new int[]{0, 3}, 0.5, 1, 1, 
                 "台風が接近中、直撃すると米の収穫量に影響が出るかもしれない...", 
                 "台風が直撃！収穫物に大打撃、収穫量が減ってしまった...",
                 "供給減少・農家さんから仕入れる米の量が20%減少",
                 false,  // 1回限りではない 
            () -> {
                applyTyphoonEvent("台風接近！");
                println("台風イベント発動！供給減少");
            },
            () -> {
                removeEventEffects("台風接近！");
                println("台風イベント終了");
            }
        ));
        
        // 大雪イベント（本来は2ターン持続、予報あり、80%で実際に発生）
        templates.add(new Event("大雪", new int[]{1}, 0.8, 1, 1, 
                 "大雪警報発令", 
                 "記録的な大雪により物流が停滞しています",
                 "輸送困難・買値20%上昇",
                 false,  // 1回限りではない 
            () -> {
                applySnowEvent("大雪");
                println("大雪イベント発動！輸送困難");
            },
            () -> {
                removeEventEffects("大雪");
                println("大雪イベント終了");
            }
        ));
        
        // 猛暑イベント（夏、2ターン持続、予報あり、75%で実際に発生）
        templates.add(new Event("猛暑", new int[]{3}, 0.75, 1, 1, 
                 "記録的猛暑の予報", 
                 "連日の猛暑により米の品質管理が困難になっています",
                 "古米、古古米の売値50%減少",
                 false,  // 1回限りではない 
            () -> {
                applyHeatwaveEvent("猛暑");
                println("猛暑イベント発動！古米の売値低下");
            },
            () -> {
                removeEventEffects("猛暑");
                println("猛暑イベント終了");
            }
        ));
        
        // 米騒動イベント（全季節、3ターン持続、予報あり、50%で実隟に発生）
        templates.add(new Event("米騒動", new int[]{0, 1, 2, 3}, 0.5, 2, 2, 
                 "市場に不穏な動き...（最大2ターン継続の可能性）", 
                 "市民の買い占めにより米不足が深刻化しています",
                 "全米の買値、売値2倍！経過後ゲーム終了",
                 true,  // 1回限り！ 
            () -> {
                applyRiceRiotEvent("米騒動");
                println("米騒動発生！価格急騰！（2ターン持続）");
            },
            () -> {
                removeEventEffects("米騒動");
                // 米騒動終了でゲーム強制終了
                println("米騒動が収束しました");
                // TODO: ゲーム終了処理
            }
        ));

        // 日本一決定戦（4ブランド分、どれか1つが選ばれると全て除外）
        templates.add(new Event("日本一決定戦", new int[]{0, 1, 2, 3}, 1.0, 1, 1, 
                 "日本一のお米を決める大会が次の季節に開催されるようだ", 
                 "日本一のお米を決める大会が開催！今回はりょうおもいが日本一に輝き価値が上昇！",
                 "りょうおもい米の売値が次の季節だけ1.5倍になる",
                 true,  // 1回限り！ 
            () -> {
                applyChampionshipEvent("日本一決定戦（りょうおもい）", 0);
                println("日本一決定戦！りょうおもいが優勝！");
            },
            () -> {
                removeEventEffects("日本一決定戦（りょうおもい）");
            }
        ));
        
        templates.add(new Event("日本一決定戦", new int[]{0, 1, 2, 3}, 1.0, 1, 1, 
                 "日本一のお米を決める大会が次の季節に開催されるようだ", 
                 "日本一のお米を決める大会が開催！今回はほしひかりが日本一に輝き価値が上昇！",
                 "ほしひかり米の売値が次の季節だけ1.5倍になる",
                 true,  // 1回限り！ 
            () -> {
                applyChampionshipEvent("日本一決定戦（ほしひかり）", 1);
                println("日本一決定戦！ほしひかりが優勝！");
            },
            () -> {
                removeEventEffects("日本一決定戦（ほしひかり）");
            }
        ));
        
        templates.add(new Event("日本一決定戦", new int[]{0, 1, 2, 3}, 1.0, 1, 1, 
                 "日本一のお米を決める大会が次の季節に開催されるようだ", 
                 "日本一のお米を決める大会が開催！今回はゆめごこちが日本一に輝き価値が上昇！",
                 "ゆめごこち米の売値が次の季節だけ1.5倍になる",
                 true,  // 1回限り！ 
            () -> {
                applyChampionshipEvent("日本一決定戦（ゆめごこち）", 2);
                println("日本一決定戦！ゆめごこちが優勝！");
            },
            () -> {
                removeEventEffects("日本一決定戦（ゆめごこち）");
            }
        ));
        
        templates.add(new Event("日本一決定戦", new int[]{0, 1, 2, 3}, 1.0, 1, 1, 
                 "日本一のお米を決める大会が次の季節に開催されるようだ", 
                 "日本一のお米を決める大会が開催！今回はつやおうじが日本一に輝き価値が上昇！",
                 "つやおうじ米の売値が次の季節だけ1.5倍になる",
                 true,  // 1回限り！ 
            () -> {
                applyChampionshipEvent("日本一決定戦（つやおうじ）", 3);
                println("日本一決定戦！つやおうじが優勝！");
            },
            () -> {
                removeEventEffects("日本一決定戦（つやおうじ）");
            }
        ));

        templates.add(new Event("オオカタ・ハズレールの大予言", new int[]{0}, 0.2, 1, 1, 
                 "外れることで有名な予言師が、今年の新米は大不作になり、古米の需要が増えるだろう、と大予言", 
                 "今年は記録的な雨不足で大不作に...新米の値段が高騰し、古米に注目が集まった。不運にも予言は的中した...",
                 "買値が2.5倍になり、米の売値が2.5倍になる",
                 true,  // 1回限り！ 
            () -> {
                applyProphecyEvent("オオカタ・ハズレールの大予言");
                println("大予言が的中！価格が大幅に変動！");
            },
            () -> {
                removeEventEffects("オオカタ・ハズレールの大予言");
            }
        ));

        templates.add(new Event("棚からぼたもち", new int[]{0, 1, 2, 3}, 1.0, 1, 0, "", 
                 "むかし作ったへそくりを見つけた！ラッキー！",
                 "所持金が2000pt増える(プレイヤーのみ)",
                 false,
            () -> {
                applyBonusMoneyEvent("棚からぼたもち");
                println("棚からぼたもち！プレイヤーに2000pt追加！");
            },
            () -> { /* 何もしない */ }
        ));

        templates.add(new Event("大盤振米", new int[]{0}, 1.0, 1, 0, "", 
                 "農家さんからいつものお礼にお米を少し多くいただけた！",
                 "農家さんから買う米の量が1.2倍になる（小数点は切り上げ）",
                 false,
            () -> {
                applySupplyBonusEvent("大盤振米");
                println("大盤振米！供給量1.2倍！");
            },
            () -> { 
                removeEventEffects("大盤振米");
             }
        ));

        templates.add(new Event("きりたんぽ鍋ブーム", new int[]{1}, 0.8, 1, 2, 
                 "有名インフルエンサーがきりたんぽ鍋を大絶賛、これは今年の冬にブームが到来するのでは...?",
                 "空前のきりたんぽ鍋ブームが到来！きりたんぽ需要の増加でお米の価値も上昇！",
                 "売値が1.5倍になる",
                 false,
            () -> {
                applyHotpotBoomEvent("きりたんぽ鍋ブーム");
                println("きりたんぽ鍋ブーム！売値1.5倍！");
            },
            () -> { 
                removeEventEffects("きりたんぽ鍋ブーム");
             }
        ));

        templates.add(new Event("不況", new int[]{1}, 0.8, 2, 2, 
                 "経済指標の悪化が懸念される中...",
                 "やはり関税が原因で景気が悪化し、国民が節約を始めたため、米の価値が下がることに...",
                 "買値と売値が今年の間0.8倍になる",
                 true,
            () -> {
                applyRecessionEvent("不況");
                println("不況発生！価格が0.8倍に！");
            },
            () -> { 
                removeEventEffects("不況");
             }
        ));

        templates.add(new Event("買い占め", new int[]{1, 2}, 1.0, 1, 1, 
                 "匿名者が大災害を予言か...?",
                 "突如として市場の米が何者かに大量に買われ、市場の米が大幅に減少した！",
                 "消費量が1.5倍になる",
                 true,
            () -> {
                applyHoardingEvent("買い占め");
                println("買い占め発生！消費量1.5倍！");
            },
            () -> { 
                removeEventEffects("買い占め");
             }
        ));

        templates.add(new Event("海外からの安価な米の輸入", new int[]{0, 1, 2, 3}, 1.0, 1, 0, "", 
                 "政府が緊急経済対策として、海外から安価な米を大量に輸入した。市場には米が溢れ、国産米の価格も下落してしまった。",
                 "市場の消費が低下し、売値が0.9倍になる。買値が0.8倍になる",
                 true,
            () -> {
                applyImportEvent("海外からの安価な米の輸入");
                println("安価な米の輸入！価格低下！");
            },
            () -> { 
                removeEventEffects("海外からの安価な米の輸入");
             }
        ));

        templates.add(new Event("農業体験ブーム", new int[]{0, 3}, 1.0, 1, 1, 
                 "次の季節に農業体験イベントが開催されるようだ",
                 "テレビ番組の影響で農業体験がブームに！多くの若者がボランティアとして農作業を手伝い、今年は豊作が期待できそうだ。",
                 "ボランティアが増え、今年の米の収穫量が1割増加する。",
                 false,
            () -> {
                applyAgricultureBoomEvent("農業体験ブーム");
                println("農業体験ブーム！収穫量1.1倍！");
            },
            () -> { 
                removeEventEffects("農業体験ブーム");
             }
        ));

        templates.add(new Event("農家の後継者問題", new int[]{0}, 1.0, 1, 3, 
                 "農家の高齢化が進む中...",
                 "お世話になっている農家さんが、高齢のため今年で引退することに…。後継者がおらず、来年から米を分けてもらえなくなってしまう。",
                 "来年から米を分けてくれる農家が1軒へり、今年の米の収穫量が1割減少する。",
                 false,
            () -> {
                applyFarmerRetirementEvent("農家の後継者問題");
                println("農家の後継者問題！収穫量0.9倍！");
            },
            () -> { 
                removeEventEffects("農家の後継者問題");
             }
        ));


        

        



        
        // 配列に変換
        eventTemplates = templates.toArray(new Event[templates.size()]);
    }
    
    // ゲーム開始時に全イベントを抽選
    void generateEventSchedule() {
        eventSchedule = new Event[maxTurn];
        forecastSchedule = new ForecastInfo[maxTurn];
        
        // ターン0は何も設定しない（イベントなし）
        // ターン1から開始
        for (int turn = 1; turn < maxTurn; turn++) {
            if (eventSchedule[turn] == null) {
                Event selectedEvent;
                if (turn == 1) {
                    // 最初のターン（ターン1）は必ず通常イベント
                    selectedEvent = eventTemplates[0]; // 通常イベント
                } else {
                    selectedEvent = selectEventForTurn(turn);
                }
                if (selectedEvent != null) {
                    placeEventWithForecast(selectedEvent, turn);
                }
            }
        }
        
        // デバッグ用：全イベントスケジュールを出力
        printDetailedEventSchedule();
    }
    
    // ターンに応じたイベントを抽選
    Event selectEventForTurn(int turn) {
        int season = turn % 4; // 0:秋, 1:冬, 2:春, 3:夏
        ArrayList<Event> candidates = new ArrayList<Event>();
        
        // 該当季節のイベントを候補に追加
        for (Event e : eventTemplates) {
            // 1回限りイベントで既に使用済みの場合はスキップ
            if (e.isOnceOnly && usedOnceOnlyEvents.contains(e.eventName)) {
                continue;
            }
            
            // 米騒動は1年目と2シーズン（ターン6）以降のみ抽選対象
            if (e.eventName.equals("米騒動") && turn < 6) {
                continue; // ターン6未満では米騒動をスキップ
            }
            
            // triggerSeasonsに現在の季節が含まれているかチェック
            for (int s : e.triggerSeasons) {
                if (s == season) {
                    candidates.add(e);
                    break;
                }
            }
        }
        
        // 候補から均等な確率でランダムに1つ選ぶ
        if (candidates.size() > 0) {
            int randomIndex = int(random(candidates.size()));
            return candidates.get(randomIndex);
        }
        
        // 候補がない場合は通常イベントを返す
        return eventTemplates[0]; // デフォルトは通常イベント
    }
    
    // イベントを予報付きで配置
    void placeEventWithForecast(Event event, int startTurn) {
        // 1回限りイベントの場合、使用済みリストに追加
        if (event.isOnceOnly && !usedOnceOnlyEvents.contains(event.eventName)) {
            usedOnceOnlyEvents.add(event.eventName);
            println("1回限りイベント「" + event.eventName + "」を使用済みリストに追加");
        }
        
        // 予報がないイベントは通常配置
        if (event.forecastTiming == 0) {
            placeEvent(event, startTurn, false);
            println("イベント設定: " + event.eventName + 
                   " (ターン" + startTurn + "から" + event.duration + "ターン発生) [予報なし]");
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