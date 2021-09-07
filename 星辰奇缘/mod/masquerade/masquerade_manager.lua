-- @author 黄耀聪
-- @date 2016年6月29日

MasqueradeManager = MasqueradeManager or BaseClass(BaseManager)

function MasqueradeManager:__init()
    if MasqueradeManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end

    self.pushTimes = 0

    self.MasqueradeStatusEnum = {
        NoBegin = 0,    -- 结束/未开始
        Broadcast = 1,  -- 广播
        Register = 2,   -- 报名
        Battle = 3,     -- 战斗
        Settle = 4,     -- 奖励
    }

    MasqueradeManager.Instance = self
    self.model = MasqueradeModel.New()

    self.eventListener = function() self:CheckMainUIProgress() end

    self.status = 0
    self.name = TI18N("精灵幻境")
    self.ruleDesc = TI18N("1.幻境共5层，进入每层幻境后玩家将进行<color='#ffff00'>变身</color>，并获得本层的变身效果\n2.每层玩家之间进行<color='#ffff00'>随机匹配</color>，通过战斗获得能量，累计足够能量将进入下一层\n3.最终奖励按<color='#ffff00'>能量</color>发放")
    self:InitHandler()

    self.onUpdateRank = EventLib.New()  -- 更新排名数据
    self.onUpdateMy = EventLib.New()    -- 更新我的数据
    self.onUpdateActive = EventLib.New()    -- 更新活动信息
    self.onUpdateTime = EventLib.New()  -- 更新时间
end

function MasqueradeManager:__delete()
end

function MasqueradeManager:InitHandler()
    self:AddNetHandler(16500, self.on16500)
    self:AddNetHandler(16501, self.on16501)
    self:AddNetHandler(16502, self.on16502)
    self:AddNetHandler(16503, self.on16503)
    self:AddNetHandler(16504, self.on16504)
    self:AddNetHandler(16505, self.on16505)
    self:AddNetHandler(16506, self.on16506)
    self:AddNetHandler(16507, self.on16507)
    self:AddNetHandler(16508, self.on16508)
    self:AddNetHandler(16509, self.on16509)

    EventMgr.Instance:AddListener(event_name.role_event_change, self.eventListener)
    EventMgr.Instance:AddListener(event_name.mainui_loaded, function() if RoleManager.Instance.RoleData.event == RoleEumn.Event.Masquerade then self:CheckMainUIProgress() end end)
    -- EventMgr.Instance:AddListener(event_name.role_looks_change, function(looks) self:CheckLooks(looks) end)
    EventMgr.Instance:AddListener(event_name.role_level_change, function ()
        if (RoleManager.Instance.RoleData.event ~= RoleEumn.Event.Masquerade and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.MasqueradeReady and (self.status == self.MasqueradeStatusEnum.Register or self.status == self.MasqueradeStatusEnum.Battle)) then
            self:OnPush()
        end
    end)
    EventMgr.Instance:AddListener(event_name.scene_load, function(mapid)
        self.onUpdateRank:Fire()
        if mapid == 71000 and self.hasRegister then
            if self.showLooks[1] ~= true then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.masquerade_preview_window, 1)
                self.showLooks[1] = true
            end
        end
    end)
end

function MasqueradeManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

-- 获取状态
function MasqueradeManager:send16500()
  -- print("发送16500")
    Connection.Instance:send(16500, {})
end

function MasqueradeManager:on16500(data)
    -- BaseUtils.dump(data, "接收16500")
    self.status = data.statue
    self.time = data.mtime

    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
        self.timer = nil
    end

    if self.status == self.MasqueradeStatusEnum.NoBegin then
        self.hasRegister = false
        self.model.myInfo = {score = 0}
        self.model.playerList = {}
    end

    if self.status == self.MasqueradeStatusEnum.Broadcast
        or self.status == self.MasqueradeStatusEnum.Register
        or self.status == self.MasqueradeStatusEnum.Battle
        then
        self.timer = LuaTimer.Add(0, 1000, function() self.onUpdateTime:Fire() end)

        if not (RoleManager.Instance.RoleData.event == RoleEumn.Event.Masquerade or RoleManager.Instance.RoleData.event == RoleEumn.Event.MasqueradeReady) and self.status ~= self.MasqueradeStatusEnum.Broadcast then
            self:OnPush()
        end
    else
        self.showLooks = {}
    end

    if self.status == self.MasqueradeStatusEnum.Battle then
        self.model.playerList = {}
        self:send16504()
        self:send16505()
    end

    if self.panel ~= nil then
        self.panel:GotoPhase(self.status)
    end

    self.onUpdateActive:Fire()

    -- LuaTimer.Add(1000, function() self:CheckMainUIProgress() end)
    self:CheckMainUIProgress()
    self:CheckActivityIcon()

    AgendaManager.Instance:SetCurrLimitID(2027, self:InActivity())
end

-- 报名
function MasqueradeManager:send16501()
  -- print("发送16501")
    self.hasRegister = true
    Connection.Instance:send(16501, {})
end

function MasqueradeManager:on16501(data)
    print("接收16501")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 退出
function MasqueradeManager:send16502()
  -- print("发送16502")
    Connection.Instance:send(16502, {})
end

function MasqueradeManager:on16502(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 活动信息
function MasqueradeManager:send16503()
  -- print("发送16503")
    Connection.Instance:send(16503, {})
end

function MasqueradeManager:on16503(data)
    -- BaseUtils.dump(data, "接收16503")

    local model = self.model
    self.group = data.group

    if data.list ~= nil then
        for _,v in ipairs(data.list) do
            model:AddMap(v)
        end
    end

    self.onUpdateActive:Fire()
end

-- 我的信息
function MasqueradeManager:send16504()
  -- print("发送16504")
    Connection.Instance:send(16504, {})
end

function MasqueradeManager:on16504(data)
    local model = self.model
    -- BaseUtils.dump(data, "<color='#00ff00'>接收16504</color>")
    if data.list ~= nil then
        if model.myInfo.score == 0 and self.hasRegister == true and self.showLooks[1] ~= true then
            if self.showLooks[1] ~= true and SceneManager.Instance:CurrentMapId() == 71000 then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.masquerade_preview_window, 1)
                self.showLooks[1] = true
            end
        elseif model.myInfo.score ~= nil then
            local score_sum = 0
            local last_score = model.myInfo.score
            local curr_score = data.list[1].score
            local max = 0
            for i,v in pairs(model.floorToDiff) do
                if v ~= nil and max < i then
                    max = i
                end
            end
            for i=0,max do
                score_sum = score_sum + model.floorToDiff[i]
                if last_score < score_sum and curr_score >= score_sum then
                    if self.showLooks[i + 1] ~= true then
                        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.masquerade_preview_window, i + 1)
                        if i ~= 5 then
                            self.showLooks[i + 1] = true
                        end
                    end
                    break
                end
            end
        end
        model.myInfo = data.list[1]
    end

    self.onUpdateMy:Fire()
end

-- 排名信息，客户端请求就返回全部整个排行榜，服务端推送就返回前三名
function MasqueradeManager:send16505()
  -- print("发送16505")
    Connection.Instance:send(16505, {})
end

function MasqueradeManager:on16505(data)
    -- BaseUtils.dump(data, "接收16505")
    local model = self.model
    if data.list ~= nil then
        for i,v in ipairs(data.list) do
            model:AddPlayer(v, i)
        end
    end
    model.rankSize = 100

    self.onUpdateRank:Fire()
end

-- 结算信息
function MasqueradeManager:send16506()
  -- print("发送16506")
    Connection.Instance:send(16506, {})
end

function MasqueradeManager:on16506(data)
    local model = self.model
    -- BaseUtils.dump(data, "接收16506")
    self.group = data.group
    if data.list ~= nil then
        model:AddPlayer(data.list[1])
    end
    if data.rank_list ~= nil then
        for i,v in ipairs(data.rank_list) do
            model:AddPlayer(v)
        end
        model.rankSize = #data.list
    end
    self.onUpdateMy:Fire()
    self.onUpdateRank:Fire()
end

-- 结算奖励
function MasqueradeManager:send16508()
  -- print("发送16508")
    Connection.Instance:send(16508, {})
end

function MasqueradeManager:on16508(data)
    -- BaseUtils.dump(data, "接收16508")
end

function MasqueradeManager:OnQuit()
    self:send16502()
end

function MasqueradeManager:Cmp(a, b)
    if a.score == b.score then
        if a.win_streak == b.win_streak then
            if a.win == b.win then
                return a.lev > b.lev
            else
                return a.win > b.win
            end
        else
            return (a.win_streak or 0) > (b.win_streak or 0)
        end
    else
        return a.score > b.score
    end
end

function MasqueradeManager:RequestInitData()
    local model = self.model
    model.playerList = {}
    self.showLooks = {}
    self.pushTimes = 0
    model.myInfo = {score = 0}
    self.lastStatus = nil
    self.hasRegister = false
    self:send16500()
    self:send16504()
    self:send16505()
end

function MasqueradeManager:CheckMainUIProgress()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.Masquerade then
        self.model:OpenMainUIPanel()
    else
        self.model:CloseMainUIPanel()
    end
end

function MasqueradeManager:OpenPreviewWindow(args)
    self.model:OpenPreviewWindow(args)
end

function MasqueradeManager:ClosePreviewWindow(args)
    self.model:ClosePreviewWindow(args)
end

function MasqueradeManager:OnPush()
    self.pushTimes = self.pushTimes + 1
    if self.pushTimes > 1 then
        return
    end
    local iconData = DataSystem.data_daily_icon[116]
    if RoleManager.Instance.RoleData.lev < iconData.lev then
        return
    end

    if ActivityManager.Instance:GetNoticeState(GlobalEumn.ActivityEumn.qualify) == false then
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.content = string.format(TI18N("<color=#FFFF00>%s</color>活动已开启，是否前往参加？"), self.name)
        confirmData.sureSecond = -1
        confirmData.cancelSecond = 180
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function() self:send16501() end

        if RoleManager.Instance.RoleData.cross_type == 1 then
            -- 如果处在中央服，先回到本服在参加活动
            RoleManager.Instance.jump_over_call = function() self:send16501() end
            confirmData.sureCallback = SceneManager.Instance.quitCenter
            confirmData.content = string.format(TI18N("<color='#ffff00'>%s</color>活动已开启，是否<color='#ffff00'>返回原服</color>参加？"), self.name)
        end

        NoticeManager.Instance:ActiveConfirmTips(confirmData)
        ActivityManager.Instance:MarkNoticeState(GlobalEumn.ActivityEumn.qualify)
    end
end

function MasqueradeManager:CheckActivityIcon()
    local activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[116]
    activeIconData.id = iconData.id
    activeIconData.iconPath = iconData.res_name
    activeIconData.sort = iconData.sort
    activeIconData.lev = iconData.lev
    MainUIManager.Instance:DelAtiveIcon(116)

    if self.status == self.MasqueradeStatusEnum.Broadcast
        then
        -- activeIconData.text = TI18N("即将开启")
        -- activeIconData.clickCallBack = function() NoticeManager.Instance:FloatTipsByString(TI18N("活动即将开启，请留意活动公告")) end
        -- MainUIManager.Instance:AddAtiveIcon(activeIconData)
    elseif self.status == self.MasqueradeStatusEnum.Register
        then
        -- 暂时去除特效
        activeIconData.createCallBack = nil
        activeIconData.text = TI18N("准备中")
        activeIconData.clickCallBack = function () self:MasqueradeCheckIn() end
        MainUIManager.Instance:AddAtiveIcon(activeIconData)
    elseif self.status == self.MasqueradeStatusEnum.Battle
        then
        activeIconData.clickCallBack = function()
            -- if BaseUtils.BASE_TIME > self.model.registerTime then
            --     NoticeManager.Instance:FloatTipsByString(TI18N("报名时间已过，请留意下次活动公告"))
            -- else
                self:MasqueradeCheckIn()
            -- end
        end
        activeIconData.timestamp = (self.time - BaseUtils.BASE_TIME) + Time.time
        activeIconData.timeoutCallBack = nil
        MainUIManager.Instance:AddAtiveIcon(activeIconData)
    end
end

function MasqueradeManager:MasqueradeCheckIn()
    if RoleManager.Instance.RoleData.cross_type == 1 then
        -- 如果处在中央服，先回到本服在参加活动
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureSecond = -1
        confirmData.cancelSecond = 180
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        RoleManager.Instance.jump_over_call = function() self:send16501() end
        confirmData.sureCallback = SceneManager.Instance.quitCenter
        confirmData.content = string.format(TI18N("<color='#ffff00'>%s</color>活动已开启，是否<color='#ffff00'>返回原服</color>参加？"), self.name)
        NoticeManager.Instance:ConfirmTips(confirmData)
    else
        self:send16501()
    end
end

function MasqueradeManager:OnQuit()
    local phaseEumn = self.MasqueradeStatusEnum
    if self:InActivity() then
        local exit = function() self:send16502() end
        if self.status == phaseEumn.Battle then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("退出后即视为放弃，<color=#FF0000>无法</color>再次参加。\n是否退出？")
            data.sureLabel = TI18N("退 出")
            data.cancelLabel = TI18N("取消")
            data.cancelSecond = 180
            data.sureCallback = exit
            NoticeManager.Instance:ConfirmTips(data)
        else
            exit()
        end
    end
end

-- 是否在活动状态
function MasqueradeManager:InActivity()
    local phaseEumn = self.MasqueradeStatusEnum
    return not (self.status == phaseEumn.NoBegin or self.status == phaseEumn.Broadcast)
end

-- 去下一层
function MasqueradeManager:send16509()
  -- print("发送16509")
    Connection.Instance:send(16509, {})
end

function MasqueradeManager:on16509(data)
    --BaseUtils.dump(data, "接收16509")
end

function MasqueradeManager:SetMasqHide(isHide)
    if self:InActivity() then
        self.model.hideStatus = isHide
        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(isHide)
    end
end

