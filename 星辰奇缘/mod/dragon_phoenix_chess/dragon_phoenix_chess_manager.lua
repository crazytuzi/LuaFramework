-- @author hze
-- @date 2018/06/07


DragonPhoenixChessManager = DragonPhoenixChessManager or BaseClass(BaseManager)

function DragonPhoenixChessManager:__init()
    if DragonPhoenixChessManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    DragonPhoenixChessManager.Instance = self

    self.model = DragonPhoenixChessModel.New()

    self.onChessEvent = EventLib.New()
    self.onSpeakEvent = EventLib.New()
    self.onOverSpeakEvent = EventLib.New()

    self.dragonChessData = { lev = 1, score = 1}
    self.status = DragonChessEumn.Status.Close
    
    self:InitHandler()
end

function DragonPhoenixChessManager:__delete()
end

function DragonPhoenixChessManager:InitHandler()
    self:AddNetHandler(20900, self.On20900)
    self:AddNetHandler(20901, self.On20901)
    self:AddNetHandler(20902, self.On20902)
    self:AddNetHandler(20903, self.On20903)
    self:AddNetHandler(20904, self.On20904)
    self:AddNetHandler(20905, self.On20905)
    self:AddNetHandler(20906, self.On20906)
    self:AddNetHandler(20907, self.On20907)
    self:AddNetHandler(20908, self.On20908)
    self:AddNetHandler(20909, self.On20909)
    self:AddNetHandler(20910, self.On20910)
    self:AddNetHandler(20911, self.On20911)
    self:AddNetHandler(20912, self.On20912)
    self:AddNetHandler(20913, self.On20913)
    self:AddNetHandler(20914, self.On20914)
    self:AddNetHandler(20915, self.On20915)

    EventMgr.Instance:AddListener(event_name.role_event_change, function(event, old_event) self:EnterChessboard(event, old_event) end)
end

function DragonPhoenixChessManager:RequestInitData()
    -- if self.model.mainPanel ~= nil then
    --     self.model.mainPanel:DeleteMe()
    --     self.model.mainPanel = nil
    -- end

    self:InitData()

    self:Send20910()            --活动状态

    -- if RoleManager.Instance.RoleData.event == RoleEumn.Event.DragonChess then
    --     self:EnterChessboard()
    -- end

    self:Send20900()            --玩家信息
    self:Send20901()            --棋盘信息

    self.initMark = true -- 初始化标记，棋盘打开过后设为false
end

function DragonPhoenixChessManager:InitData()
    self.model.chessType = 1
    self.model.who_turn = 1
    self.model.next_time_step = 0
    self.model.round = 0

    self.dragonChessData = { lev = 1, score = 1}

    self.model.myInfo = {}
    self.model.enemyInfo = {}

    self.model.chessInfoTab = {
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
        }
end



function DragonPhoenixChessManager:EnterChessboard(event, old_event)
    if event == RoleEumn.Event.DragonChess and old_event ~= RoleEumn.Event.DragonChess then
        self.initMark = false   
        if self.closeMainTimerId ~= nil then
            LuaTimer.Delete(self.closeMainTimerId)
            self.closeMainTimerId = nil
        end

        if self.model.iconView ~= nil then
            self.model.iconView:DeleteMe()
            self.model.iconView = nil
        end
        
        if self.model.settlepanel ~= nil then
            self.model.settlepanel:DeleteMe()
            self.model.settlepanel = nil
        end
        
        if MainUIManager.Instance.mainuitracepanel ~= nil and not BaseUtils.isnull(MainUIManager.Instance.mainuitracepanel.gameObject) then
            MainUIManager.Instance.mainuitracepanel:TweenHiden()
        end

        --进入活动展示棋盘
        self.model:OpenMain()
    elseif old_event == RoleEumn.Event.DragonChess and event ~= RoleEumn.Event.DragonChess then
        local fun = function()             
            if self.model.mainPanel ~= nil then
                self.model.mainPanel:DeleteMe() 
                self.model.mainPanel = nil
            end

            self.model:ShowMainView(true)
            -- if MainUIManager.Instance.mainuitracepanel ~= nil and not BaseUtils.isnull(MainUIManager.Instance.mainuitracepanel.gameObject) then
            --     MainUIManager.Instance.mainuitracepanel:TweenShow()
            -- end
        end

        if self.initMark then
            fun()
        else
            if self.closeMainTimerId ~= nil then
                LuaTimer.Delete(self.closeMainTimerId)
                self.closeMainTimerId = nil
            end
            self.closeMainTimerId = LuaTimer.Add(10000, fun)
        end
    elseif event == RoleEumn.Event.DragonChessMatchSucc and old_event ~= RoleEumn.Event.DragonChessMatchSucc then
        --匹配成功，关闭结算界面
        if self.model.settlepanel ~= nil then
            self.model.settlepanel:DeleteMe()
            self.model.settlepanel = nil
        end
    end

    if RoleManager.Instance.RoleData.event == RoleEumn.Event.DragonChessMatch and self.model.matchWin == nil then
        self.model:OpenIconView()
    else
        if self.model.iconView ~= nil then
            self.model.iconView:DeleteMe()
            self.model.iconView = nil
        end
    end
end

function DragonPhoenixChessManager:GoMatch()
    if self.status == DragonChessEumn.Status.Open then
        -- if (self.model.times or 0) > 0 then
            if TeamManager.Instance.TypeData.status == TeamEumn.MatchStatus.None then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.dragon_chess_match)
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("组队中不能进入匹配噢"))
            end
        -- else
        --     NoticeManager.Instance:FloatTipsByString(TI18N("当天参与次数已达上限"))
        -- end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启，敬请期待！{face_1 ,3}"))
    end
end



--角色信息
function DragonPhoenixChessManager:Send20900()
    -- print("发送20900协议")
    self:Send(20900, {})
end

function DragonPhoenixChessManager:On20900(data)
    -- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20900</color>"))
    self.dragonChessData = {lev = data.self_grade, score = data.self_score}
    self.model:AnalyzeChessRole(data)
end

--棋盘信息
function DragonPhoenixChessManager:Send20901()
    -- print("发送20901协议")
    self:Send(20901, {})
end

function DragonPhoenixChessManager:On20901(data)
    -- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20901</color>"))
    self.model:AnalyzeChessBoard(data)

    --断线重连处理
    if not self.model:BrokenReconnection() then
        self.onChessEvent:Fire()
    end
end

--推送玩家说话
function DragonPhoenixChessManager:Send20903(msgindx)
    -- print("发送20903协议")
    self:Send(20903, {msg_num = msgindx})
end

function DragonPhoenixChessManager:On20903(data)
    -- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20903</color>"))
    self.onSpeakEvent:Fire(data)
end

--发起求和
function DragonPhoenixChessManager:Send20904()
    -- print("发送20904协议--发起求和")
    self:Send(20904, {})
end

function DragonPhoenixChessManager:On20904(data)
    -- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20904</color>"))
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--回应求和
function DragonPhoenixChessManager:Send20905(flag)
    -- print("发送20905协议--回应求和")
    self:Send(20905, {flag = flag})
end

function DragonPhoenixChessManager:On20905(data)
    -- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20905</color>"))
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--认输
function DragonPhoenixChessManager:Send20906()
    -- print("发送20906协议")
    self:Send(20906, {})
end

function DragonPhoenixChessManager:On20906(data)
    -- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20906</color>"))
end

--下棋
function DragonPhoenixChessManager:Send20907(x,y)
    -- print("发送20907协议")
    self:Send(20907,{x = x, y = y})
end

function DragonPhoenixChessManager:On20907(data)
    -- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20907</color>"))
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--加入匹配
function DragonPhoenixChessManager:Send20908()
    -- print("发送20908协议")
    self:Send(20908, {})
end

function DragonPhoenixChessManager:On20908(data)
    -- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20908</color>"))
    NoticeManager.Instance:FloatTipsByString(data.msg)

end

--取消匹配
function DragonPhoenixChessManager:Send20909()
    -- print("发送20909协议")
    self:Send(20909, {})
end

function DragonPhoenixChessManager:On20909(data)
    -- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20909</color>"))
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--活动状态及可参与次数
function DragonPhoenixChessManager:Send20910()
    -- print("发送20910协议")
    self:Send(20910, {})
end

function DragonPhoenixChessManager:On20910(data)
    -- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20910</color>"))

    local oldStatus = self.status

    self.model.times = data.times
    self.status = data.state
    self.time = data.end_time

    --星辰乐园
    AgendaManager.Instance:SetCurrLimitID(2105, data.state == 1)
    StarParkManager.Instance.agendaTab[2105] = nil
    local cfg_data = DataSystem.data_daily_icon[121]


    if self.status == DragonChessEumn.Status.Open then
        StarParkManager.Instance.agendaTab[2105] = {}
        StarParkManager.Instance.agendaTab[2105].time = data.end_time - (BaseUtils.BASE_TIME - Time.time)

        -- local dat = {targetTime = data.end_time - (BaseUtils.BASE_TIME - Time.time), timeoutCallBack = function() MainUIManager.Instance:DelAtiveIcon(391) end}
        -- self:ShowIcon(dat)

        if oldStatus == DragonChessEumn.Status.Close and RoleManager.Instance.RoleData.lev >= cfg_data.lev then
            local confirmData = confirmData or NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Normal
            confirmData.content = TI18N("<color='#ffff00'>龙凤棋</color>活动正在进行中，是否前往参加？")
            confirmData.sureLabel = TI18N("确认")
            confirmData.sureCallback = function() QuestManager.Instance.model:FindNpc("3_1") end
            confirmData.cancelLabel = TI18N("取消")
            confirmData.cancelSecond = 30
            confirmData.cancelCallback = nil

            NoticeManager.Instance:ActiveConfirmTips(confirmData)
        end
    end
    StarParkManager.Instance:ShowIcon()
end

-- 龙凤棋结算
function DragonPhoenixChessManager:Send20911()
    -- print("send20911")
    Connection.Instance:send(20911, {})
end

function DragonPhoenixChessManager:On20911(data)
    -- BaseUtils.dump(data,"On20911结算信息")
    local temp = data
    temp.olddata = BaseUtils.copytab(self.dragonChessData)
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.dragon_chess_settle, temp)
    self.dragonChessData = {lev = data.grade, score = data.score}

    --结算时作清空操作
    self:ClearModelData()

    --结束时请求一下活动次数
    self:Send20910()

    self.onOverSpeakEvent:Fire(data)
end

-- 发送邀请信息
function DragonPhoenixChessManager:Send20912(id, platform, zone_id)
    -- print("send20912")
    Connection.Instance:send(20912, {rid = id, platform = platform, zone_id = zone_id})
end

function DragonPhoenixChessManager:On20912(data)
    -- print("邀请信息发送成功--20912")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    -- if data.result == 1 then
    --     local dat = dat or NoticeConfirmData.New()
    --     dat.type = ConfirmData.Style.Sure
    --     dat.content = TI18N("等待好友接受邀请....")
    --     dat.sureLabel = TI18N("取消邀请")
    --     dat.sureSecond = 30
    --     dat.sureCallback = function()  end
    --     NoticeManager.Instance:ActiveConfirmTips(dat)
    -- end
end

-- 回应邀请信息
function DragonPhoenixChessManager:Send20913(rid, platform, zone_id)
    -- print("send20913")
    Connection.Instance:send(20913, {rid = rid, platform = platform, zone_id = zone_id})
end

function DragonPhoenixChessManager:On20913(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 收到回应请求
function DragonPhoenixChessManager:Send20914()
    -- print("send20914--收到求和请求")
    Connection.Instance:send(20914, {})
end

function DragonPhoenixChessManager:On20914(data)
    -- BaseUtils.dump(TI18N("<color=#FF0000>接收20914</color>--收到求和请求"))
    local dat = dat or NoticeConfirmData.New()
    dat.type = ConfirmData.Style.Normal
    dat.content = TI18N("对方玩家希望与你<color='#00ff00'>握手言和</color>，是否<color='#ffff00'>同意</color>？")
    dat.sureLabel = TI18N("确认")
    dat.sureCallback = function() self:Send20905(1) end
    dat.cancelLabel = TI18N("拒绝")
    dat.cancelCallback = function() self:Send20905(0) end
    dat.cancelSecond = 30
    NoticeManager.Instance:ConfirmTips(dat)
end


-- 收到好友邀请信息
function DragonPhoenixChessManager:Send20915()
    Connection.Instance:send(20915, {})
end

function DragonPhoenixChessManager:On20915(data)
    -- BaseUtils.dump(TI18N("<color=#FF0000>接收20915</color>--收到求和请求"))
    local dat = dat or NoticeConfirmData.New()
    dat.type = ConfirmData.Style.Normal
    dat.content = string.format(TI18N("玩家%s邀请你一起玩<color='#ffff00'>龙凤棋</color>，是否接受？"),data.name)
    dat.sureLabel = TI18N("确认")
    dat.sureCallback = function() self:Send20913(data.rid, data.platform, data.zone_id) end
    dat.cancelLabel = TI18N("拒绝")
    dat.cancelSecond = 30
    NoticeManager.Instance:ConfirmTips(dat)
end

function DragonPhoenixChessManager:ClearModelData()
    self.model.chessInfoTab = {
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
        }

    self.enemyInfo = {}
    self.myInfo = {}
end

function DragonPhoenixChessManager:ShowIcon(data)
    MainUIManager.Instance:DelAtiveIcon(391)
    self.activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[391]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    self.activeIconData.timestamp = data.targetTime
    self.activeIconData.timeoutCallBack = data.timeoutCallBack
    self.activeIconData.clickCallBack = function() QuestManager.Instance.model:FindNpc("3_1") end
    MainUIManager.Instance:AddAtiveIcon(self.activeIconData)

end

function DragonPhoenixChessManager:InitChess()
    local dat = {
        self_role =
        {
             grade = 10,
        },


        ops_role = {
            name = "121121",
            sex = 1,
            classes = 5,
            lev = 65,
            grade = 20,
        },

        ops_looks =
        {
            looks_type = 0,
            looks_mode = 0,
            looks_val = 0,
            looks_str = 0,
        },

        self_color = 2
    }
    self:On20900(BaseUtils.copytab(dat))

    local dat1 = {
        who_turn = 2,
        end_time = 2,
        chess_list = {
            [1] = {
                color = 1,
                row = 4,
                col = 4,
            },
            [2] = {
                color = 1,
                row = 5,
                col = 5,
            },
            [3] = {
                color = 2,
                row = 5,
                col = 4,
            },
            [4] = {
                color = 2,
                row = 4,
                col = 5,
            },
        },
        now_turn = 1,
        can_use_list = {
            [1] = {
                row = 4,
                col = 3,
            },
            [2] = {
                row = 5,
                col = 3,
            },
        },
    }
    self:On20901(BaseUtils.copytab(dat1))
end
