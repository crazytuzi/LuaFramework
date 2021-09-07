TrialModel = TrialModel or BaseClass(BaseModel)

function TrialModel:__init()
    self.window = nil

    self.mode = 0
    self.order = 1
    self.direct_order = 1
    self.clear_normal = false
    self.trial_unit = nil
    self.reset = 0
    self.round = 0
    self.coin = 0
    self.times = 0
    self.max_times = 0
    self.can_ask = 0
    self.failMark = false
    self.data_13100 = nil

    self.questteam_loaded = false
    self.questData = {}

    EventMgr.Instance:AddListener(event_name.scene_load, function() self:update() end)
    EventMgr.Instance:AddListener(event_name.end_fight, function(combat_type, fightResult) self:end_fight(combat_type, fightResult) end)
    EventMgr.Instance:AddListener(event_name.trace_quest_loaded, function() self.questteam_loaded = true self:UpdataQuest() end)
end

function TrialModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function TrialModel:OpenWindow()
    if self.window == nil then
        self.window = TrialView.New(self)
    end
    self.window:Open()
end

function TrialModel:CloseWindow()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function TrialModel:update()
    self:change_map()
    self:update_unit()
    self:run_to_reward()
    self:UpdataQuest()
    EventMgr.Instance:Fire(event_name.trial_update)
end

function TrialModel:update_unit()
    local data = DataTrial.data_trial_data[self.order]
    if data == nil then return end

    local zone = data.zone

    for i = 1, zone do
        local data = DataTrial.data_map_data[i]
        local uniquenpcid = BaseUtils.get_unique_npcid(data.unit_id, data.battle_id)
        SceneManager.Instance.sceneElementsModel:RemoveVirtual_Unit(uniquenpcid)
    end

    for i = zone + 1, #DataTrial.data_map_data do
        local data = DataTrial.data_map_data[i]
        if SceneManager.Instance:CurrentMapId() == data.map_id then
            data.id = data.unit_id
            data.battleid = data.battle_id

            local npc = NpcData.New()
            npc:update_data(data)

            npc.unittype = SceneConstData.unittype_trialeffect -- 单位类型
            SceneManager.Instance.sceneElementsModel:CreateVirtual_Unit(npc.uniqueid, npc)
        end
    end

    if self.trial_unit ~= nil then
        local data = self.trial_unit
        if SceneManager.Instance:CurrentMapId() == data.map_id then
            local npc = NpcData.New()
            npc:update_data(data)
            npc.unittype = SceneConstData.unittype_dramaunit -- 单位类型
            if DataUnit.data_unit[data.base_id] == nil then
                -- Log.Error(string.format("[极寒]unit表里没有该id:  %s", data.base_id))
                return
            end
            if DataUnit.data_unit[data.base_id].fun_type == SceneConstData.fun_type_trial_box then
                npc.canIdle = false
                SceneManager.Instance.sceneElementsModel:CreateVirtual_Unit(npc.uniqueid, npc)
            else
                SceneManager.Instance.sceneElementsModel:CreateVirtual_Unit(npc.uniqueid, npc)
                -- -- 特效
                local fun = function(effectView)
                    local effectObject = effectView.gameObject

                    effectObject.transform:SetParent(SceneManager.Instance.sceneModel.sceneView.gameObject.transform)
                    effectObject.transform.localScale = Vector3.one
                    local p = SceneManager.Instance.sceneModel:transport_small_pos(npc.x, npc.y)
                    effectObject.transform.localPosition = Vector3(p.x, p.y, p.y)
                    effectObject.transform.localRotation = Quaternion.identity

                    Utils.ChangeLayersRecursively(effectObject.transform, "Model")
                end
                BaseEffectView.New({effectId = 30019, time = 1500, callback = fun})
            end
        end
    end
end

function TrialModel:change_map()
    if BaseUtils.is_null(ctx.sceneManager.Map) then return end
    if SceneManager.Instance:CurrentMapId() == 60001 then
        if self.maincamera_effect == nil then
            local fun = function(effectView)
                local effectObject = effectView.gameObject

                effectObject.transform:SetParent(SceneManager.Instance.MainCamera.gameObject.transform)
                effectObject.transform.localScale = Vector3(1.95 / SceneManager.Instance.DefaultCameraSize, 1, 1)
                effectObject.transform.localPosition = Vector3(0, 0, 0)
                effectObject.transform.localRotation = Quaternion.identity

                Utils.ChangeLayersRecursively(effectObject.transform, "SceneEffect")

                if BaseUtils.IsWideScreen() then
                    local scaleX = (ctx.ScreenWidth / ctx.ScreenHeight) / (16 / 9)
                    effectObject.transform.localScale = Vector3(scaleX, 1, 1)
                else
                    local scaleY = (ctx.ScreenHeight/ ctx.ScreenWidth) / (9 / 16)
                    effectObject.transform.localScale = Vector3(1, scaleY, 1)
                end
            end
            self.maincamera_effect = BaseEffectView.New({effectId = 20061, time = nil, callback = fun})
        end
    else
        if self.maincamera_effect ~= nil then
            GameObject.Destroy(self.maincamera_effect.gameObject)
            self.maincamera_effect = nil
        end
    end

    local data = DataTrial.data_trial_data[self.order]
    if data == nil then return end
    local zone = data.zone
    local row = ctx.sceneManager.Map.Row
    local map_id = 0
    if zone ~= 0 then
        map_id = DataTrial.data_map_data[zone].map_id
    else
        map_id = DataTrial.data_map_data[1].map_id
    end
    local map_data = { base_id = map_id, flag = 0, pos = nil}
    local map_pos = {}
    for i = 1, zone do
        local map_data = DataTrial.data_map_data[i]
        if map_data ~= nil and map_data.map_id == map_id then
            local pos = map_data.map_pos
            for k,v in pairs(pos) do
                table.insert(map_pos, { x = v[1], y = row - v[2] - 1 })
            end
        end
    end
    map_data.flag = 0
    map_data.pos = map_pos
    ctx.sceneManager:ModifyMap(map_data)

    map_pos = {}
    for i = zone + 1, DataTrial.data_map_data_length do
        local map_data = DataTrial.data_map_data[i]
        if map_data ~= nil and map_data.map_id == map_id then
            local pos = map_data.map_pos
            for k,v in pairs(pos) do
                table.insert(map_pos, { x = v[1], y = row - v[2] - 1 })
            end
        end
    end
    map_data.flag = 1
    map_data.pos = map_pos
    ctx.sceneManager:ModifyMap(map_data)
end

function TrialModel:update_trial_unit(data)
    self.trial_unit = {}
    self.trial_unit.battle_id = data.battle_id
    self.trial_unit.id = data.unit_id
    self.trial_unit.base_id = data.unit_baseid
    self.trial_unit.name = data.unit_name
    self.trial_unit.classes = data.classes
    self.trial_unit.sex = data.sex
    self.trial_unit.lev = data.lev
    self.trial_unit.dir = data.dir
    self.trial_unit.map_id = data.map_id
    self.trial_unit.x = data.x
    self.trial_unit.y = data.y
    self.trial_unit.looks = data.looks

    -- print(data.looks)
    -- BaseUtils.dump(data.looks, "---------------------------------------")
end

function TrialModel:end_fight(combat_type, fightResult)
    if combat_type ~= 4 then
        return
    end
    if fightResult == 1 and self.trial_unit ~= nil then
        local data = self.trial_unit
        -- 特效
        local fun = function(effectView)
            local effectObject = effectView.gameObject

            effectObject.transform:SetParent(SceneManager.Instance.sceneModel.sceneView.gameObject.transform)
            effectObject.transform.localScale = Vector3.one
            local p = SceneManager.Instance.sceneModel:transport_small_pos(data.x, data.y)
            effectObject.transform.localPosition = Vector3(p.x, p.y, p.y)
            effectObject.transform.localRotation = Quaternion.identity

            Utils.ChangeLayersRecursively(effectObject.transform, "Model")
        end
        BaseEffectView.New({effectId = 30019, time = 1500, callback = fun})
    end
    self:run_to_reward()
end

function TrialModel:run_to_reward()
    -- 需求改成默认自动到下一个对象了，不局限于奖励
    -- if self.order < self.direct_order then
    if self.trial_unit ~= nil then
        SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(BaseUtils.get_unique_npcid(self.trial_unit.id, self.trial_unit.battle_id))
    end
end

function TrialModel:open_dialog(data)
    -- print("<color='#00ff00'>打开试炼对话框</color>")
    local button_text = TI18N("开始挑战")
    if self.times ~= self.max_times then button_text = string.format(TI18N("开始挑战(剩%s次机会)"), self.max_times - self.times) end
    local args = BaseUtils.copytab(DataUnit.data_unit[data.baseid])
    args.id = data.baseid
    args.name = data.name
    if self.trial_unit == nil then
        self:update_trial_unit(self.data_13100)
    end
    args.plot_talk = string.format("<color='#00ff00'>%s Lv.%s</color>\n%s", KvData.classes_name[data.classes], self.trial_unit.lev, args.plot_talk)
    local btn1 = {button_id = DialogEumn.ActionType.action8, button_args = { 1, battleid = data.battleid, id = data.id}, button_desc = button_text, button_show = "[]"}
    local btn2 = {button_id = DialogEumn.ActionType.action48, button_args = {1}, button_desc = string.format(TI18N("求助(%s/2)"), self.can_ask), button_show = "[]"}
    if self.failMark and self.can_ask > 0 then
        btn1.button_args[1] = 2
    end

    args.buttons = { btn1, btn2 }
    args.isrole = true
    args.looks = data.looks
    args.sex = data.sex
    args.classes = data.classes
    MainUIManager.Instance.dialogModel:Open(data, { base = args }, true)
end

function TrialModel:dialog_button_click(args)
    SceneManager.Instance:Send10100(args.battleid, args.id)
end

function TrialModel:click_trial_box(view, data)
    local touchNpcView = view
    local touchNpcData = data
    LuaTimer.Add(500,
        function()
            local fun = function(effectView)
                if BaseUtils.is_null(touchNpcView.gameObject) then
                    GameObject.Destroy(effectView.gameObject)
                    return
                end
                local effectObject = effectView.gameObject

                effectObject.transform:SetParent(SceneManager.Instance.sceneModel.sceneView.gameObject.transform)
                effectObject.transform.localScale = Vector3.one
                effectObject.transform.localPosition = touchNpcView.gameObject.transform.localPosition
                effectObject.transform.localRotation = Quaternion.identity

                Utils.ChangeLayersRecursively(effectObject.transform, "SceneEffect")

                SceneManager.Instance:Send10100(touchNpcData.battleid, touchNpcData.id)
            end
            BaseEffectView.New({effectId = 30069, time = 1500, callback = fun})

            local fun2 = function(effectView)
                local effectObject = effectView.gameObject

                effectObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.gameObject.transform)
                effectObject.transform.localScale = Vector3.one
                effectObject.transform.localPosition = Vector3(480, -270, 0)
                effectObject.transform.localRotation = Quaternion.identity

                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            end
            BaseEffectView.New({effectId = 20111, time = 4000, callback = fun2})
        end)
    touchNpcView:PlayAction(SceneConstData.UnitAction.Idle)
end

function TrialModel:CreatQuest()
    if self.quest_track then
        return
    end
    self.quest_track = MainUIManager.Instance.mainuitracepanel.traceQuest:AddCustom()

    self.quest_track.callback = function ()
            if QuestManager.Instance.model:CheckCross() then
                return
            end

            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath_AndTopEffect()
            AutoFarmManager.Instance:StopAncientDemons()  -- 解决进行极寒试炼时上古模式干扰的问题 by 嘉俊 2017/8/31
            TrialManager.Instance:Send13101(self.mode)
        end

    self:UpdataQuest()
end

function TrialModel:DeleteQuest()
    if self.quest_track then
        MainUIManager.Instance.mainuitracepanel.traceQuest:DeleteCustom(self.quest_track.customId)
        self.quest_track = nil
        self.questData = {}
    end
end

function TrialModel:UpdataQuest()
    if not self.questteam_loaded then return end
    if self.times > 0 and self.mode ~= 0 and self.trial_unit ~= nil then
        if self.questData.order ~= self.order or self.questData.unit_name ~= self.trial_unit.name then
            local data = DataTrial.data_trial_data[self.order]
            if data == nil then
                self.questData = {}
                self:DeleteQuest()
            else
                if self.quest_track then
                    self.questData.order = self.order
                    self.questData.unit_name = self.trial_unit.name

                    if data.type == 1 then
                        self.quest_track.title = string.format(TI18N("[极寒]继续挑战<color='#ff0000'>(%s/%s)</color>"), data.order_desc, #DataTrial.data_trial_data/2)
                        self.quest_track.Desc = string.format(TI18N("击败 <color='#00ff00'>%s</color>"), self.trial_unit.name)
                        self.quest_track.fight = true
                    else
                        self.quest_track.title = TI18N("[极寒]领取奖励")
                        self.quest_track.Desc = string.format(TI18N("领取 <color='#00ff00'>第%s关奖励</color>"), data.order_desc)
                        self.quest_track.fight = false
                    end

                    MainUIManager.Instance.mainuitracepanel.traceQuest:UpdateCustom(self.quest_track)
                else
                    self:CreatQuest()
                end
            end
        end
    else
        self.questData = {}
        self:DeleteQuest()
    end
end

function TrialModel:seekHelp(data)
    if data.type == 1 then
        local str = string.format(TI18N("<color='#249015'>%s</color>发起求助：<color='#017dd7'>极寒试炼-%s</color>，快帮助TA吧<color='#249015'>(点此帮助)</color>"), data.name, data.unit_name)
        local msgData = MessageParser.GetMsgData(str)
        local chatData = ChatData.New()
        chatData:Update(data)
        chatData.showType = MsgEumn.ChatShowType.TrialHelp
        chatData.id = chatData.rid
        chatData.msgData = msgData
        chatData.channel = MsgEumn.ChatChannel.Private
        chatData.prefix = MsgEumn.ChatChannel.Private
        ChatManager.Instance.model:ShowMsg(chatData)
    elseif data.type == 2 then
        local str = string.format(TI18N("%s发起求助：极寒试炼-[%s]，快帮助TA吧"), data.name, data.unit_name)
        local btnOffestY = 0
        local msgData = MsgData.New()
        msgData.sourceString = str
        msgData.showString = str
        NoticeManager.Instance.model.calculator:ChangeFoneSize(17)
        local allWidth = NoticeManager.Instance.model.calculator:SimpleGetWidth(msgData.sourceString)
        msgData.allWidth = allWidth
        local chatData = ChatData.New()
        chatData.showType = MsgEumn.ChatShowType.TrialHelp
        chatData.msgData = msgData
        data.id = 1
        data.btnOffestY = btnOffestY
        chatData.extraData = data
        chatData.prefix = MsgEumn.ChatChannel.Guild
        chatData.channel = MsgEumn.ChatChannel.Guild
        -- self.chatShowMatchTab[data.id] = chatData

        ChatManager.Instance.model:ShowMsg(chatData)
    end
end

function TrialModel:ShowReward(data)
    self.failMark = false

    for k,v in pairs(data.gain_items) do
        v.id = v.base_id
    end
    local order = self.order
    if order < self.direct_order then
        order = self.direct_order
    end

    if DataTrial.data_trial_data[order] ~= nil then
        order = tonumber(DataTrial.data_trial_data[order].order_desc) - 1
    else
        order = math.floor(order / 2)
    end
    local str = string.format(TI18N("历经磨练，你成功突破了第%s关！"), order)
    FinishCountManager.Instance.model.reward_win_data = {
                        titleTop = TI18N("极寒试炼")
                        -- , val = string.format("目前排名：<color='#ffff00'>%s</color>", self.rank)
                        , val1 = str
                        -- , val2 = ""
                        , title = TI18N("奖励统计")
                        , confirm_str = TI18N("确定")
                        , reward_list = data.gain_items
                        , confirm_callback = function()  end
                    }
    FinishCountManager.Instance.model:InitRewardWin_Common()
end

function TrialModel:On13100(data)
    self.data_13100 = data
    self.mode = data.mode
    self.order = data.order
    self.direct_order = data.direct_order
    self.clear_normal = data.clear_normal
    self.max_order_easy = data.max_order_easy
    self.max_order_hard = data.max_order_hard
    self.round = data.round
    self.coin = data.coin
    self.times = data.times
    self.max_times = data.max_times
    self.can_ask = data.can_ask
    if self.mode == 0 then
        self.trial_unit = nil
    else
        self:update_trial_unit(data)
    end
    self.reset = data.reset

    self:update()
end

function TrialModel:On13101(data)
    self.reset = data.reset
    self:update()
end

function TrialModel:On13102(data)
    self.mode = data.mode
    if self.order ~= data.order and self.failMark then self.failMark = false end
    self.order = data.order
    self.direct_order = data.direct_order
    self.clear_normal = data.clear_normal
    self.max_order_easy = data.max_order_easy
    self.max_order_hard = data.max_order_hard
    self.round = data.round
    self.coin = data.coin
    if self.times == 2 and data.times == 1 then self.failMark = true end
    self.times = data.times
    self.max_times = data.max_times
    self.can_ask = data.can_ask
    if self.mode == 0 then
        self.trial_unit = nil
    else
        self:update_trial_unit(data)
    end
    self:update()
end
