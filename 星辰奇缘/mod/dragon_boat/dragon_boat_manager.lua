-- @author 黄耀聪
-- @date 2016年6月1日

DragonBoatManager = DragonBoatManager or BaseClass(BaseManager)

function DragonBoatManager:__init()
    if DragonBoatManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    DragonBoatManager.Instance = self

    self.model = DragonBoatModel.New()

    self.status = 0
    self.time_out = 0

    self.start_time = 0
    self.done = 0
    self.title_name = TI18N("滑雪")

    self:InitHandler()

    self.onUpdateTrace = EventLib.New()
    self.onUpdateStatus = EventLib.New()
end

function DragonBoatManager:__delete()
end

function DragonBoatManager:InitHandler()
    self:AddNetHandler(19900, self.on19900)
    self:AddNetHandler(19901, self.on19901)
    self:AddNetHandler(19902, self.on19902)
    self:AddNetHandler(19903, self.on19903)
    self:AddNetHandler(19904, self.on19904)
    self:AddNetHandler(19905, self.on19905)
    self:AddNetHandler(19906, self.on19906)

    EventMgr.Instance:AddListener(event_name.end_fight, function(type, result)
        self:OnEndFight(type, result)
    end)

    EventMgr.Instance:AddListener(event_name.role_event_change, function(event, old_event) self:UpdateEvent(event, old_event) end)
end

function DragonBoatManager:send19900(data)
  -- print("发送14015")
    Connection.Instance:send(19900, {})
end

function DragonBoatManager:on19900(data)
    -- BaseUtils.dump(data, "接收19900")
    for k,v in pairs(data) do
        self[k] = v
    end
    self.onUpdateTrace:Fire()

    if self.isFirst ~= true and CombatManager.Instance.isFighting ~= true and self.done ~= 0 then
        self:GoNext()
    end
    self.isFirst = false
end

function DragonBoatManager:send19901(data)
    Connection.Instance:send(19901, {})
end

function DragonBoatManager:on19901(data)
    -- print("<color='#ff0000'>接收19901</color>")
    -- BaseUtils.dump(data, "19901")
    self.status = data.status
    self.time_out = data.time_out
    self.campId = data.camp_id

    if DataCampaign.data_list[self.campId] ~= nil then 
        self.title_name = DataCampaign.data_list[self.campId].name
    end

    self.onUpdateStatus:Fire()

    MainUIManager.Instance:DelAtiveIcon(339)

    if self.status ~= 0 then
        local cfg_data = DataSystem.data_daily_icon[339]
        local ativeIconData = AtiveIconData.New()
        ativeIconData.id = cfg_data.id
        ativeIconData.iconPath = cfg_data.res_name
        ativeIconData.sort = cfg_data.sort
        ativeIconData.lev = cfg_data.lev
        if self.status == 1 then
            ativeIconData.text = TI18N("报名中")
            -- ativeIconData.timestamp = self.time_out - BaseUtils.BASE_TIME + Time.time
        elseif self.status == 2 then
            -- ativeIconData.text = TI18N("进行中")
            ativeIconData.timestamp = self.time_out - BaseUtils.BASE_TIME + Time.time
        end
        ativeIconData.clickCallBack = function()
            if self.status == 1 then
                local target = BaseUtils.get_unique_npcid(32025, 1)
                SceneManager.Instance.sceneElementsModel:Self_AutoPath(10001, target, nil, nil, true)
            elseif self.status == 2 then
                if RoleManager.Instance.RoleData.event == RoleEumn.Event.DragonBoat then
                    self:GoNext()
                else -- 没报名的，去报名
                    local target = BaseUtils.get_unique_npcid(32025, 1)
                    SceneManager.Instance.sceneElementsModel:Self_AutoPath(10001, target, nil, nil, true)
                end
            end
        end
        MainUIManager.Instance:AddAtiveIcon(ativeIconData)
    end

    self:UpdateEvent(RoleManager.Instance.RoleData.event)

    if self.status == 1 and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.DragonBoat then
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.content = string.format(TI18N("<color='#ffff00'>%s</color>活动正在进行中，是否前往参加？"),self.title_name)
        
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.cancelSecond = 30
        confirmData.sureCallback = function()
                local target = BaseUtils.get_unique_npcid(32025, 1)
                SceneManager.Instance.sceneElementsModel:Self_AutoPath(10001, target, nil, nil, true)
            end

        NoticeManager.Instance:ActiveConfirmTips(confirmData)
    end
end

function DragonBoatManager:send19902(data)
  -- print("发送19902")
    Connection.Instance:send(19902, {})
end

function DragonBoatManager:on19902(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.flag == 1 then
        self:GoNext()
    end
end

function DragonBoatManager:send19903(data)
  -- print("发送14017")
    Connection.Instance:send(19903, {})
end

function DragonBoatManager:on19903(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function DragonBoatManager:send19904(data)
  -- print("发送14018")
    Connection.Instance:send(19904, {})
end

function DragonBoatManager:on19904(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function DragonBoatManager:ReqOnConnect()
    self.status = 0
    self.time_out = 0
    self.start_time = 0
    self.done = 0
    self.isFirst = true
    self:send19901()
    self:send19900()
end

function DragonBoatManager:GoNext()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.DragonBoat then
        if self.done == DataDragonBoat.data_list_length then
        else
            local currentMapId = SceneManager.Instance:CurrentMapId()
            local monsterData = DataDragonBoat.data_list[self.done + 1]
            local target = BaseUtils.get_unique_npcid(monsterData.base_id, 28)
            -- if monsterData.map_id == currentMapId then
            --     QuestManager.Instance.model:FindNpc(target)
            -- else
                SceneManager.Instance.sceneElementsModel:Self_AutoPath(monsterData.map_id, target, nil, nil, false)
            -- end
        end
    end
end

function DragonBoatManager:OpenRewardSettle(time, gain)
    local hour = nil
    local min = nil
    local sec = nil
    local _ = nil
    _,hour,min,sec = BaseUtils.time_gap_to_timer(time)
    local time_str = nil
    if hour > 0 then
        time_str = string.format(TI18N("%s小时%s分%s秒"), tostring(hour), tostring(min), tostring(sec))
    else
        time_str = string.format(TI18N("%s分%s秒"), tostring(min), tostring(sec))
    end

    local val_str = TI18N("排名结算奖励将在活动结束时发放")
    if time <= 600 then
        val_str = TI18N("10分钟内完成，<color=#FFFF00>额外获得</color>了大量奖励")
    elseif time <= 900 then
        val_str = TI18N("15分钟内完成，<color=#FFFF00>额外获得</color>了一份奖励")
    end
    if #gain > 0 then
        FinishCountManager.Instance.model.reward_win_data = {
            titleTop = self.title_name
            , val2 = TI18N("恭喜你们完成赛程，请收下你的奖励")
            , val1 = string.format(TI18N("本次成绩为%s"), time_str)
            , val = val_str
            , title = TI18N("终点奖励")
            , confirm_str = TI18N("确 认")
            , reward_list = gain
            , confirm_callback = function() end
            , share_callback = nil
            , sure_time = 20
            , reward_title = TI18N("比赛奖励")
        }
        FinishCountManager.Instance.model:InitRewardWin_Common()
    else
        NoticeManager.Instance:On9910({base_id = DataDragonBoat.data_list[DataDragonBoat.data_list_length].base_id, msg = string.format(TI18N("表现不错，本次成绩%s，今日已领过奖励咯{face_1,22}"), time_str)})
    end
end

function DragonBoatManager:send19905()
    Connection.Instance:send(19905)
end

function DragonBoatManager:on19905(data)
    local gain = BaseUtils.copytab(data.reward)
    for k,v in pairs(gain) do
        v.id = v.base_id
    end
    self:OpenRewardSettle(data.time_span, gain)
    self.effect = nil
    self.effect = BibleRewardPanel.ShowEffect(30074, ctx.CanvasContainer.transform, Vector3(1, 1, 1), Vector3(0, 0, 0), 1000 * 3)
end

function DragonBoatManager:send19906()
    Connection.Instance:send(19906)
end

function DragonBoatManager:on19906(data)
    -- BaseUtils.dump(data, "19906")

    self.rankData = data
    self.model:OpenRankScoreWindow({campId = self.campId})
end

function DragonBoatManager:OnEndFight(type, result)
    if type == 37 then
        self:GoNext()
    end
end

function DragonBoatManager:UpdateEvent(event, old_event)
    if event == RoleEumn.Event.DragonBoat and self.status == 1 then
        self.model:ShowIcon()
    else
        self.model:HideIcon()
    end
end
