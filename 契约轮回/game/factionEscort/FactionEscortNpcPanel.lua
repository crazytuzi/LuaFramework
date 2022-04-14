FactionEscortNpcPanel = FactionEscortNpcPanel or class("FactionEscortNpcPanel", BasePanel)

function FactionEscortNpcPanel:ctor()
    self.abName = "factionEscort"
    self.assetName = "FactionEscortNpcPanel"
    self.layer = LayerManager.LayerNameList.UI

    self.use_background = true
    self.change_scene_close = true
    self.click_bg_close = true
    self.is_hide_other_panel = true
    self.events = {}
    self.model = FactionEscortModel:GetInstance()
    --  self.item_list = {}
    --self.model = TaskModel:GetInstance()
    self.role = RoleInfoModel.GetInstance():GetMainRoleData()
end

function FactionEscortNpcPanel:dctor()
    GlobalEvent.RemoveTabEventListener(self.events)
    if self.npc_model then
        self.npc_model:destroy()
        self.npc_model = nil
    end
    self:StopTime()

    if self.camera_component then
        self.camera_component.targetTexture = nil
    end
    if self.rawImage then
        self.rawImage.texture = nil
        ReleseRenderTexture(self.render_texture)
        self.render_texture = nil
    end
end

function FactionEscortNpcPanel:CloseCallBack()

end

function FactionEscortNpcPanel:Open(npcID, type)
    self.npcID = npcID
    self.type = type   --  1 开始  2中间  3 结束
    self.db = Config.db_npc[npcID]
    FactionEscortNpcPanel.super.Open(self)
end

function FactionEscortNpcPanel:LoadCallBack()
    self.nodes = {
        "startBtn", "pillageBtn", "name", "content", "testBtn", "EndBtn", "todayTimes", "time",
        "Image/img_task_bg", "Image", "UIModelCamera", "UIModelCamera/Camera"
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self.name = GetText(self.name)
    self.content = GetText(self.content)
    self.todayTimes = GetText(self.todayTimes)
    self.time_text = GetText(self.time)

    local texture = CreateRenderTexture() 
    self.rawImage = self.UIModelCamera:GetComponent("RawImage")
    self.camera_component = self.Camera:GetComponent("Camera")
    self.camera_component.targetTexture = texture
    self.rawImage.texture = texture
    self.render_texture = texture

    self:AddEvent()
    self:InitUI()
    SetSizeDeltaX(self.img_task_bg, ScreenWidth - 8)
    SetSizeDeltaX(self.Image, ScreenWidth)

    SetLocalPositionX(self.UIModelCamera, (-ScreenWidth / 2) + 315)
end

function FactionEscortNpcPanel:InitUI()
    self.name.text = self.db.name
    self:SetContent()
    self:InitModel()
    if self.type == 1 then
        --开始NPC
        SetVisible(self.testBtn, false)
        SetVisible(self.EndBtn, false)
        SetVisible(self.time, false)
        self:SetTimes()
    elseif self.type == 2 then
        --中间使者
        self:StartTime()
        SetVisible(self.startBtn, false)
        SetVisible(self.EndBtn, false)
        SetVisible(self.todayTimes.transform, false)
    else
        self:StartTime()
        SetVisible(self.startBtn, false)
        SetVisible(self.testBtn, false)
        SetVisible(self.todayTimes.transform, false)
    end

end

function FactionEscortNpcPanel:StartTime()
    self:StopTime()
    local time = 11
    local function step()
        time = time - 1
        local str
        if self.type == 2 then
            str = string.format("(Auto continue in %s sec)", time)
        elseif self.type == 3 then
            str = string.format("(Auto submission in %s sec)", time)
        end

        self.time_text.text = str
        if time <= 0 then
            if self.type == 2 then
                FactionEscortController:GetInstance():RequestEscortFinish(1)
            elseif self.type == 3 then
                FactionEscortController:GetInstance():RequestEscortFinish(2)
            end
            self:StopTime()
        end
    end
    self.time_id = GlobalSchedule:Start(step, 1.0)
    step()
end

function FactionEscortNpcPanel:StopTime()
    if self.time_id then
        GlobalSchedule:Stop(self.time_id)
    end
end

function FactionEscortNpcPanel:SetTimes()
    local db = Config.db_escort[1]
    local aTimes = db.attend
    self.todayTimes.text = string.format("Daily attempts: <color=#%s>%s/%s</color>", "2E870F", aTimes - self.model.escortCount, aTimes)
end

function FactionEscortNpcPanel:InitModel()
    local config = Config.db_npc[self.npcID]
    if not config then
        return
    end
    --if not config or not config.figure then
    --    if AppConfig.Debug then
    --        local vo = TaskModel:GetInstance():GetTask(self.task_id)
    --        print('--LaoY TaskTalkNovicePanel.lua,line 97--')
    --        dump(vo,"vo")
    --    end
    --    logError(string.format("配置了一个不存在的NPC，ID是：%s,任务ID是：%s",tostring(self.npcID),self.task_id))
    --end
    self.npc_model = UINpcModel(self.UIModelCamera, self.db.figure, handler(self, self.LoadModelCallBack))
    local scale = config.chat or 1
    self.npc_model:SetScale(scale * 100)
end
function FactionEscortNpcPanel:LoadModelCallBack()
    local config = Config.db_npc[self.npcID] or {}
    if not config then
        SetLocalPosition(self.npc_model.transform, -2098, -65, 388);--172.2
    else
        local pos = String2Table(config.pos)
        SetLocalPosition(self.npc_model.transform, pos[1], pos[2], pos[3])
    end
    SetLocalRotation(self.npc_model.transform, 0, 172, 0);
    self.npc_model:SetCameraLayer();

    local npc_object = SceneManager:GetInstance():GetObject(self.npcID)
    local show_action_name = SceneConstant.ActionName.show
    if npc_object then
        show_action_name = npc_object:GetShowActionName()
        npc_object:ChangeMachineState(show_action_name)
    end
    self.npc_model:AddAnimation({ show_action_name, "idle" }, true, "idle", 0)--,"casual"
end

function FactionEscortNpcPanel:SetContent()
    -- self.des.text = string.format("   每天%s:%s-%s:%s和%s:%s-%s:%s为双倍\n护送时间，期间护送的奖励翻倍;",startTime1,startTime2,endTime1,endTime2,startTime3,startTime4,endTime3,endTime4)
    -- <color=#27C31F></color>
    local startTime1, startTime2, startTime3, startTime4 = self.model:DoubleStartText()
    local endTime1, endTime2, endTime3, endTime4 = self.model:DoubleEndText()

    if self.type == 1 then
        self.content.text = string.format("Daily from <color=#27C31F>%s:%s-%s:%s</color> and <color=#27C31F>%s:%s-%s:%s</color> you will gain double travelling rewards.\nReaches LV.130 can attend. Don't miss it. \nUse the<color=#27C31F>higher quality sleds</color>, and can get <color=#27C31F>the better rewards</color>", startTime1, startTime2, endTime1, endTime2, startTime3, startTime4, endTime3, endTime4)
    elseif self.type == 2 then
        self.content.text = "In this ever-frozen land, we never expected to meet such a champion like you.You are facing multiple sharp turns!\nHere are some gifts for you,thank you for coming to visit me!"
    else
        self.content.text = "Congratulations! You have just crossed the most dangerous zone in this land!\nabundant rewards will be given to you!!"
    end
end

function FactionEscortNpcPanel:AddEvent()

    function start_call_back()
        --开始护送
        self:Close()
        local db = Config.db_escort[1]
        local aTimes = db.attend
        if aTimes - self.model.escortCount <= 0 then
            Notify.ShowText("Your daily escort attempts are used up! Please come back tomorrow.")
            return
        end
        --if self.role.guild == "0" then   --暂无公户
        --    Notify.ShowText("请先加入公会")
        --    return
        --end
        lua_panelMgr:GetPanelOrCreate(FactionEscortPanel):Open()
    end
    AddClickEvent(self.startBtn.gameObject, start_call_back)
    --function des_call_back() --开始劫掠
    --    --if self.role.guild == "0" then   --暂无公户
    --    --    Notify.ShowText("请先加入公会")
    --    --    return
    --    --end
    --end

    --AddClickEvent(self.desBtn.gameObject,des_call_back)
    --
    --function des_call_back()  --玩法说明
    --    ShowHelpTip(HelpConfig.Escort.des);
    --end
    --AddClickEvent(self.desBtn.gameObject,des_call_back)
    function call_back()
        -- 中间使者
        FactionEscortController:GetInstance():RequestEscortFinish(1)
    end
    AddClickEvent(self.testBtn.gameObject, call_back)

    function call_back()
        --结束
        FactionEscortController:GetInstance():RequestEscortFinish(2)
    end

    AddClickEvent(self.EndBtn.gameObject, call_back)
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(FactionEscortEvent.FactionEscortFinish, handler(self, self.FactionEscortFinish))
end

function FactionEscortNpcPanel:FactionEscortFinish(data)
    if self.model.progress == 1 then
        local db = Config.db_escort_road
        local npcDB = Config.db_npc
        local main_role = SceneManager:GetInstance():GetMainRole()
        local start_pos = main_role:GetPosition()
        local endId = db[1].end_npc
        local sceneId = npcDB[endId].scene
        local endPos = SceneConfigManager:GetInstance():GetNpcPosition(sceneId, endId)
        function callback()
            local npc_object = SceneManager:GetInstance():GetObject(endId)
            if npc_object then
                npc_object:OnClick()
            end
        end
        OperationManager:GetInstance():TryMoveToPosition(sceneId, start_pos, endPos, callback)
    end

    self:Close()
end

