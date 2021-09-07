-- @author 黄耀聪
-- @date 2017年4月27日

AnimalChessManager = AnimalChessManager or BaseClass(BaseManager)

function AnimalChessManager:__init()
    if AnimalChessManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    AnimalChessManager.Instance = self

    self.model = AnimalChessModel.New()

    self.simulate = false

    self.onChessEvent = EventLib.New()
    self.onRedEvent = EventLib.New()
    self.onGreenEvent = EventLib.New()
    self.onNormalEvent = EventLib.New()
    self.animalChessData = { lev = 1, score = 1}
    self:InitHandler()
end

function AnimalChessManager:__delete()
end

function AnimalChessManager:InitHandler()
    self:AddNetHandler(17847, self.on17847)
    self:AddNetHandler(17848, self.on17848)
    self:AddNetHandler(17849, self.on17849)
    self:AddNetHandler(17850, self.on17850)
    self:AddNetHandler(17851, self.on17851)
    self:AddNetHandler(17852, self.on17852)
    self:AddNetHandler(17853, self.on17853)
    self:AddNetHandler(17854, self.on17854)
    self:AddNetHandler(17855, self.on17855)
    self:AddNetHandler(17856, self.on17856)
    self:AddNetHandler(17857, self.on17857)

    EventMgr.Instance:AddListener(event_name.role_event_change, function() self:EnterChessboard() end)
end

function AnimalChessManager:RequireInitData()
    self.model.chessLastTab = nil

    self:send17851()
    self:send17848()
    self:send17856()
end

function AnimalChessManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function AnimalChessManager:OpenMatch(args)
    self.model:OpenMatch(args)
end

--------------------------------------------------------------------------------------------
----------------------------------------- 外部接口 -----------------------------------------
--------------------------------------------------------------------------------------------

function AnimalChessManager:OnSurrender()
    if self.model.round < 15 then
        NoticeManager.Instance:FloatTipsByString(TI18N("15回合后才可投降哟~{face_1, 30}"))
    else
        self.confirmData = self.confirmData or NoticeConfirmData.New()
        self.confirmData.type = ConfirmData.Style.Normal
        self.confirmData.content = TI18N("胜利只属于那些<color='#ffff00'>永不言弃</color>的玩家！投降后将获得<color='#00ff00'>较少</color>奖励，是否确认<color='#ffff00'>投降</color>？")
        self.confirmData.sureLabel = TI18N("确认投降")
        self.confirmData.sureCallback = function() self:send17850() end
        self.confirmData.cancelCallback = nil
        self.confirmData.cancelLabel = TI18N("我再想想")
        NoticeManager.Instance:ConfirmTips(self.confirmData)
    end
end

function AnimalChessManager:EnterChessboard()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.AnimalChess then
        if self.model.mainPanel == nil then
            self.model:OpenMain()
        end
        if self.model.iconView ~= nil then
            self.model.iconView:DeleteMe()
            self.model.iconView = nil
        end
        if MainUIManager.Instance.mainuitracepanel ~= nil then
            MainUIManager.Instance.mainuitracepanel:TweenHiden()
        end
        self.model:OpenOperation()
    else
        if self.model.mainPanel ~= nil then
            self.model.mainPanel:DeleteMe()
            self.model.mainPanel = nil
        end
        if self.model.operation ~= nil then
            self.model.operation:DeleteMe()
            self.model.operation = nil
        end
        if (RoleManager.Instance.RoleData.event == RoleEumn.Event.AnimalChessMatch
                    or RoleManager.Instance.RoleData.event == RoleEumn.Event.AnimalChessMatchSucc)
            and self.model.matchWin == nil then
            self:OpenIconView()
        else
            if self.model.iconView ~= nil then
                self.model.iconView:DeleteMe()
                self.model.iconView = nil
            end
        end

        if RoleManager.Instance.RoleData.event == RoleEumn.Event.AnimalChessMatchSucc and self.model.matchWin == nil then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.animal_chess_match)
        end
        if MainUIManager.Instance.mainuitracepanel ~= nil then
            MainUIManager.Instance.mainuitracepanel:TweenShow()
        end
    end
end

function AnimalChessManager:GoMatch()
    if self.status == AnimalChessEumn.Status.Open then
        if (self.model.times or 0) > 0 then
            if TeamManager.Instance.TypeData.status == TeamEumn.MatchStatus.None then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.animal_chess_match)
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("组队中不能进入匹配噢"))
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("当天参与次数已达上限"))
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启，敬请期待！{face_1 ,3}"))
    end
end

function AnimalChessManager:OpenSettle(args)
    self.model:OpenSettlePanel(args)
end

function AnimalChessManager:WantPeace()
    if self.model.round < 25 then
        -- self.confirmData.type = ConfirmData.Style.Sure
        -- self.confirmData.content = TI18N("25回合后才可求和哟~{face_1, 30}")
        -- self.confirmData.sureCallback = nil
        -- self.confirmData.cancelSecond = -1
        -- self.confirmData.sureLabel = TI18N("确 认")

        NoticeManager.Instance:FloatTipsByString(TI18N("25回合后才可求和哟~{face_1, 30}"))
    elseif self.model.drawTab[self.model.myCamp].draw_time1 ~= nil and self.model.drawTab[self.model.myCamp].draw_time1 > BaseUtils.BASE_TIME then
        NoticeManager.Instance:FloatTipsByString(TI18N("正在进行求和，不要重复请求哟{face_1 ,22}"))
    elseif self.model.drawTab[self.model.myCamp].draw_time2 ~= nil and self.model.drawTab[self.model.myCamp].draw_time2 > BaseUtils.BASE_TIME then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("还剩<color='#ffff00'>%s</color>秒才能再次求和"), self.model.drawTab[self.model.myCamp].draw_time2 - BaseUtils.BASE_TIME))
    else
        self.confirmData = self.confirmData or NoticeConfirmData.New()
        self.confirmData.type = ConfirmData.Style.Normal
        self.confirmData.content = TI18N("胜利只属于那些<color='#ffff00'>永不言弃</color>的玩家！求和后将获得<color='#00ff00'>少量</color>奖励，是否确认进行<color='#ffff00'>求和</color>？")
        self.confirmData.sureCallback = function() self:send17854() end
        self.confirmData.sureLabel = TI18N("确认求和")
        self.confirmData.cancelLabel = TI18N("我再想想")
        self.confirmData.cancelSecond = -1
        self.confirmData.cancelCallback = nil
        NoticeManager.Instance:ConfirmTips(self.confirmData)
    end
end

function AnimalChessManager:OpenIconView()
    self.model:OpenIconView()
end

--------------------------------------------------------------------------------------------
----------------------------------------- 协议监听 -----------------------------------------
--------------------------------------------------------------------------------------------

-- 斗兽棋开始匹配
function AnimalChessManager:send17847()
    Connection.Instance:send(17847, {})
    self.model.isPlaying = false
end

function AnimalChessManager:on17847(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 斗兽棋信息
function AnimalChessManager:send17848()
    -- print("send17848")
    Connection.Instance:send(17848, {})
end

function AnimalChessManager:on17848(data)
    -- BaseUtils.dump(data, "<color='#00ff00'>on17848</color>")
    self.model:Analyze(data)
end

-- 斗兽棋移动
function AnimalChessManager:send17849(start_x, start_y, end_x, end_y)
    -- print("send17849 "..string.format("%s %s %s %s", start_x, start_y, end_x, end_y))
    if self.simulate then
        self:Move(start_x, start_y, end_x, end_y)
    else
        Connection.Instance:send(17849, {start_x = start_x, start_y = start_y, end_x = end_x, end_y = end_y})
    end
end

function AnimalChessManager:on17849(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 斗兽棋投降
function AnimalChessManager:send17850()
    -- print("send17850")
    Connection.Instance:send(17850, {})
end

function AnimalChessManager:on17850(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 斗兽棋投降
function AnimalChessManager:send17851()
    -- print("send17851")
    Connection.Instance:send(17851, {})
end

function AnimalChessManager:on17851(data)
    self.model.times = data.times
    self.status = data.status
    self.time = data.time
    AgendaManager.Instance:SetCurrLimitID(2104, data.status == 1)
    StarParkManager.Instance.agendaTab[2104] = nil

    local cfg_data = DataSystem.data_daily_icon[121]
    if self.status == AnimalChessEumn.Status.Close then
    elseif self.status == AnimalChessEumn.Status.Open then
        StarParkManager.Instance.agendaTab[2104] = {}
        StarParkManager.Instance.agendaTab[2104].time = data.time - (BaseUtils.BASE_TIME - Time.time)

        local roleData = RoleManager.Instance.RoleData
        if roleData.lev >= cfg_data.lev and roleData.event ~= RoleEumn.Event.AnimalChessMatch and roleData.event ~= RoleEumn.Event.AnimalChess
            then
            self.confirmData = self.confirmData or NoticeConfirmData.New()
            self.confirmData.type = ConfirmData.Style.Normal
            self.confirmData.content = TI18N("<color='#ffff00'>斗兽棋</color>活动正在进行中，是否前往参加？")
            self.confirmData.sureLabel = TI18N("确认")
            self.confirmData.sureCallback = function() QuestManager.Instance.model:FindNpc("34_1") end
            self.confirmData.cancelLabel = TI18N("取消")
            self.confirmData.cancelSecond = 30
            self.confirmData.cancelCallback = nil

            NoticeManager.Instance:ActiveConfirmTips(self.confirmData)
        end
    end
    StarParkManager.Instance:ShowIcon()
end

-- 斗兽棋开箱子
function AnimalChessManager:send17852(x, y)
    -- print("send17852 " .. string.format("%s %s", x, y))
    if self.simulate then
        self:Open(x, y)
    else
        Connection.Instance:send(17852, {x = x, y = y})
    end
end

function AnimalChessManager:on17852(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 斗兽棋结算
function AnimalChessManager:send17853(x, y)
    -- print("send17853 " .. string.format("%s %s", x, y))
    Connection.Instance:send(17853, {x = x, y = y})
end

function AnimalChessManager:on17853(data)
    local temp = data
    temp.olddata = BaseUtils.copytab(self.animalChessData)
    self.model:OpenSettlePanel(temp)
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.animal_chess_settle, temp)
    self.animalChessData = {lev = data.grade, score = data.score}
    self.model.isPlaying = false
end

-- 求和
function AnimalChessManager:send17854()
    Connection.Instance:send(17854, {})
end

function AnimalChessManager:on17854(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 求和确认
function AnimalChessManager:send17855(flag)
    Connection.Instance:send(17855, {flag = flag})
end

function AnimalChessManager:on17855(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 斗兽棋信息
function AnimalChessManager:send17856()
    -- print("send17856")
    Connection.Instance:send(17856, {})
end


function AnimalChessManager:on17856(data)
    self.animalChessData = data
end

-- 斗兽棋收到求和请求
function AnimalChessManager:send17857()
    -- print("send17857")
    Connection.Instance:send(17857, {})
end


function AnimalChessManager:on17857()
    self.confirmData = self.confirmData or NoticeConfirmData.New()
    self.confirmData.type = ConfirmData.Style.Normal
    self.confirmData.content = TI18N("对方玩家希望与你<color='#00ff00'>握手言和</color>，是否<color='#ffff00'>同意</color>？")
    self.confirmData.sureLabel = TI18N("同 意")
    self.confirmData.sureCallback = function() self:send17855(1) end
    self.confirmData.cancelLabel = TI18N("拒绝")
    self.confirmData.cancelSecond = 30
    self.confirmData.cancelCallback = function() self:send17855(0) end
    NoticeManager.Instance:ConfirmTips(self.confirmData)
end
--------------------------------------------------------------------------------------------
----------------------------------------- 模拟输入 -----------------------------------------
--------------------------------------------------------------------------------------------

function AnimalChessManager:InitChess()
    self.dat = {
        round = 0,
        time = 0,
        next_move = 2,

        role_id1 = 1,
        platform1 = "test",
        zone_id1 = 1,
        first_name = "121121",
        first_lev = 90,
        first_classes = 1,
        first_sex = 1,
        first_grade = 1,
        first_score = 1,

        role_id2 = 2,
        platform2 = "test",
        zone_id2 = 1,
        second_name = "jjjj",
        second_lev = 90,
        second_classes = 4,
        second_sex = 0,
        second_grade = 1,
        second_score = 1,

        chesses = {}
    }

    for i=1,36 do
        table.insert(self.dat.chesses, {
            x = (i - 1) % 6 + 1,
            y = math.ceil(i / 6),
            camp = 0,
            status = 1,
        })
    end

    self:on17848(BaseUtils.copytab(self.dat))
end

function AnimalChessManager:Open(x, y)
    for i,chess in ipairs(self.dat.chesses) do
        if chess.x == x and chess.y == y then
            if chess.status == AnimalChessEumn.SlotStatus.UnOpen then
                chess.grade = math.random(1, 6)
                chess.camp = math.random(1, 2)
                chess.status = AnimalChessEumn.SlotStatus.Opened
                self:on17848(self.dat)
            end
            return
        end
    end
end

function AnimalChessManager:Move(start_x, start_y, end_x, end_y)
    local chessTab = {{}, {}, {}, {}, {}, {}}
    for i,chess in ipairs(self.dat.chesses) do
        chessTab[chess.x][chess.y] = chess
    end
    if chessTab[start_x][start_y].status == AnimalChessEumn.SlotStatus.Opened
        and chessTab[end_x][end_y].status == AnimalChessEumn.SlotStatus.Empty
        then
        chessTab[start_x][start_y].status = AnimalChessEumn.SlotStatus.Empty
        chessTab[end_x][end_y].status = AnimalChessEumn.SlotStatus.Opened
        chessTab[end_x][end_y].camp = chessTab[start_x][start_y].camp
        chessTab[end_x][end_y].grade = chessTab[start_x][start_y].grade
        self:on17848(BaseUtils.copytab(self.dat))
    elseif chessTab[start_x][start_y].status == AnimalChessEumn.SlotStatus.Opened
        and chessTab[end_x][end_y].status == AnimalChessEumn.SlotStatus.Opened
        then
        for _,v in ipairs(AnimalChessEumn.ChessType[chessTab[start_x][start_y].grade].defeat) do
            if v == chessTab[end_x][end_y].grade then
                chessTab[start_x][start_y].status = AnimalChessEumn.SlotStatus.Empty
                chessTab[end_x][end_y].status = AnimalChessEumn.SlotStatus.Opened
                chessTab[end_x][end_y].camp = chessTab[start_x][start_y].camp
                chessTab[end_x][end_y].grade = chessTab[start_x][start_y].grade
                self:on17848(BaseUtils.copytab(self.dat))
                return
            end
        end
    end
end

