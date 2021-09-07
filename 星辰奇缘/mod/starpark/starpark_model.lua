--星辰乐园model
--2017/3/1
--zzl

StarParkModel = StarParkModel or BaseClass(BaseModel)

function StarParkModel:__init()
    --守护阵法名称

    self.leftBtnList = {
        [1] = {id = 1, agendaId = 2101, icon = 1, btnType = 1, bgPath = AssetConfig.starpark_pumpkin_bg, tips = {TI18N("1.系统<color='#ffff00'>自动匹配</color>4名选手，进行2V2对战"), TI18N("2.将制作出来的雪球丢向对手，可使对手附带<color='#ffff00'>冰冻</color>效果"), TI18N("3.达到<color='#ffff00'>3层冰冻</color>会变成雪人，将对手全部变成雪人即获胜")}},  --冰雪世界
        -- [2] = {id = 2, agendaId = 2102, icon = 2, btnType = 2, bgPath = AssetConfig.starpark_pumpkin_bg1, tips = {TI18N("1.系统会<color='#ffff00'>自动匹配</color>10名选手，随机划分成<color='#ffff00'>红蓝</color>两个阵营，识破对方假扮的南瓜精<color='#ffff00'>+1分</color>"), TI18N("2.率先达到<color='#ffff00'>20分</color>的一方获胜，若比赛结束后双方得分相同则按时间先后判定胜负")}},  --南瓜
        [2] = {id = 2, agendaId = 2105, icon = 4, btnType = 2, bgPath = AssetConfig.starpark_dragon_chess, tips = {TI18N("1、单人<color='#ffff00'>匹配</color>进行<color='#ffff00'>1v1</color>的策略对决\n2、在对手任一棋子<color='#ffff00'>相邻</color>的空位上落子，在<color='#ffff00'>横、竖、斜</color>其中一个方向，<color='#ffff00'>夹住</color>对手<color='#ffff00'>至少一个</color>棋子。夹住的棋子翻转为自己的棋子。\n3、场上仅有己方的棋子，或是结束时己方棋子数量更多时，即可获胜")}},  -- 龙凤棋
        [3] = {id = 3, agendaId = 2104, icon = 3, btnType = 3, bgPath = AssetConfig.starpark_animal_chess, tips = {TI18N("1.系统自动<color='#ffff00'>匹配</color>进行<color='#ffff00'>1V1</color>的策略对决！"), TI18N("2.每次操作可<color='#ffff00'>打开</color>一个箱子或将<color='#ffff00'>移动</color>自己单位一格"), TI18N("3.帅>将>校>尉>士>兵>帅，同级别<color='#ffff00'>先手</color>可击杀对方。"), TI18N("4、占据<color='#ffff00'>更大优势</color>的一方将取得胜利！")}},  --斗兽棋
    }

    self.mainWin = nil
end

function StarParkModel:__delete()

end


--打开守护主面板
function StarParkModel:OpenStarParkMainUI(args)
    BaseUtils.dump(args)
    if self.mainWin == nil then
        self.mainWin = StarParkMainWindow.New(self)
    end
    self.mainWin:Open(args)
end

--关闭守护主面板
function StarParkModel:CloseStarParkMainUI()
    if self.mainWin ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWin)
        self.mainWin = nil
    end
end

function StarParkModel:OpenShop()
    local datalist = {}
    for i,v in pairs(ShopManager.Instance.model.datalist[2][15] or {}) do
        table.insert(datalist, v)
    end

    if self.exchangeWin == nil then
        self.exchangeWin = MidAutumnExchangeWindow.New(self)
        self.exchangeWin.windowId = WindowConfig.WinID.starpark_exchange
    end
    self.exchangeWin:Open({datalist = datalist, title = TI18N("乐园兑换"), extString = ""})
end

function StarParkModel:GetActivityState(id)
    if id == 2101 then
        return MatchManager.Instance.statusList[1000] ~= nil and MatchManager.Instance.statusList[1000] ~= 0
    elseif id == 2102 then
        return HalloweenManager.Instance.model.status ~= 0
    elseif id == 2104 then
        return AnimalChessManager.Instance.status == AnimalChessEumn.Status.Open
    elseif id == 2105 then
        return DragonPhoenixChessManager.Instance.status == DragonChessEumn.Status.Open
    end
end
