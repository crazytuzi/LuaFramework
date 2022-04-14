--
-- @Author: LaoY
-- @Date:   2018-08-31 15:02:41
-- 
MainMiddleLeft = MainMiddleLeft or class("MainMiddleLeft", BaseItem)
local this = MainMiddleLeft
local ConfigLanguage = require('game.config.language.CnLanguage');
MainMiddleLeft.SwitchType = {
    Task = 1,
    Team = 2,
}

function MainMiddleLeft:ctor(parent_node, layer)
    self.abName = "main"
    self.assetName = "MainMiddleLeft"
    self.layer = layer

    self.task_item_list = {}
    self.team_item_list = {}
    self.team_status_imgs = {}
    self.team_height = 0

    self.isNeedLoadTopItem = true
    self.model = MainModel:GetInstance()
    MainMiddleLeft.super.Load(self)
    self.boss_info = nil
    self:BindRoleUpdate()
    self.global_event_list = {}
end

function MainMiddleLeft:dctor()
    if self.task_event_list then
        TaskModel:GetInstance():RemoveTabListener(self.task_event_list)
        self.task_event_list = nil
    end 

    if self.event_id_3 then
        TeamModel:GetInstance():RemoveListener(self.event_id_3)
        self.event_id_3 = nil
    end

    if self.event_id_4 then
        TeamModel:GetInstance():RemoveListener(self.event_id_4)
        self.event_id_4 = nil
    end

    if self.event_id_5 then
        self.model:RemoveListener(self.event_id_5)
        self.event_id_5 = nil
    end

    if self.event_id_6 then
        self.model:RemoveListener(self.event_id_6)
        self.event_id_6 = nil
    end

    if self.global_events then
        for i = 1, #self.global_events do
            GlobalEvent:RemoveListener(self.global_events[i])
        end
    end
   

    if self.global_event_list then
        GlobalEvent:RemoveTabListener(self.global_event_list)
        self.global_event_list = {}
    end

    for k, item in pairs(self.task_item_list) do
        item:destroy()
    end
    self.task_item_list = {}

    for k, item in pairs(self.team_item_list) do
        item:destroy()
    end
    self.team_item_list = nil

    if self.task_top_item then
        self.task_top_item:destroy()
        self.task_top_item = nil
    end

    if self.role_update_list then
        for k, event_id in pairs(self.role_update_list) do
            self.role_data:RemoveListener(event_id)
        end
        self.role_update_list = nil
    end

    if self.task_guide then
        self.task_guide:destroy()
        self.task_guide = nil
    end
    self.team_status_imgs = nil
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
    if self.boss_info then
        self.boss_info:destroy()
        self.boss_info = nil
    end
end

function MainMiddleLeft:LoadCallBack()
    self.nodes = {
        "con", "con/btn_task", "con/btn_team", "con/text_task", "con/text_team", "con/task_scroll",
        "con/task_scroll/task_viewport", "con/task_scroll/task_viewport/task_content", "con/team_info",
        "con/team_info/team_pre/btn_teamlist", "con/team_info/team_pre/btn_create", "con/team_info/team_pre",
        "con/team_info/team_members", "con/team_info/team_members/member_scroll/Viewport/team_content", "con/btn_switch_1",
        "con/team_info/team_members/btn_quit",
        "con/team_info/team_members/statusContain/status_1",
        "con/team_info/team_members/statusContain/status_2",
        "con/team_info/team_members/statusContain/status_3",
        "con/team_info/team_members/member_scroll/Viewport/team_content/TeamMemberItem",
        "con/img_task_show", "con/img_team_show",
        "con/boss_info/ScrollView/Viewport/BossContent",
        "con/task_scroll/img_task_bg_3_1", "con/taskItemParent",
        "btn_switch_2", "con/team_info/team_members/Text",
    }
    self:GetChildren(self.nodes)

    self.global_events = {}

    self.text_task_component = self.text_task:GetComponent('Text')
    self.text_team_component = self.text_team:GetComponent('Text')
    self.text_task_component.text = ConfigLanguage.Custom.Task
    self.text_team_component.text = ConfigLanguage.Custom.Team
    self.team_status_imgs[1] = self.status_1:GetComponent('Image')
    self.team_status_imgs[2] = self.status_2:GetComponent('Image')
    self.team_status_imgs[3] = self.status_3:GetComponent('Image')
    self.exp_text = GetText(self.Text)

    -- self.img_task_bg_3_1 = self.transform:GetComponent('RectTransform')
    self.TeamMemberItem_gameobject = self.TeamMemberItem.gameObject
    SetVisible(self.TeamMemberItem_gameobject, false)

    self.start_pos_x = self.position.x
    local x, _ = GetLocalPosition(self.btn_switch_2)
    local w, h = GetSizeDeltaX(self.btn_switch_2)
    self.offset = DesignResolutionWidth * 0.5 + x - w * 0.5

    SetVisible(self.btn_switch_2.transform, false)

    -- Yzprint('--LaoY MainMiddleLeft.lua,line 74-- x,y=',self.start_pos_x,self.offset)
    self:SetMask()
    self:AddEvent()
    self:SwitchTaskTeam(MainMiddleLeft.SwitchType.Task)
    self:UpdateTask()
    GlobalEvent.BrocastEvent(MainEvent.MAIN_MIDDLE_LEFT_LOADED);

    if self.isCreateLeftCenterNoTransform then
        self:UpdateBossInfo(self.isCreateLeftCenterNoTransform, self.isCreateDungeLeftCenterNoTransform);
        self.isCreateDungeLeftCenterNoTransform = nil;
        self.isCreateLeftCenterNoTransform = nil;
    end

    self.task_scroll_height = GetSizeDeltaY(self.task_scroll)
    self.task_scroll_g_y = GetGlobalPositionY(self.task_scroll)
    self.task_scroll_component = self.task_scroll:GetComponent('ScrollRect')

    if self.isNeedLoadTopItem == true then
        local role_data = RoleInfoModel:GetInstance():GetMainRoleData()
        self:IsShowTopItem(role_data.level)
    end
end

function MainMiddleLeft:AddEvent()
    local function call_back(target, x, y)
        self:SwitchTaskTeam(MainMiddleLeft.SwitchType.Task)
    end
    AddClickEvent(self.btn_task.gameObject, call_back)

    local function call_back(target, x, y)
        if not IsOpenModular(80) then
            Notify.ShowText("Teaming unlocks at Lv.80")
            return
        end
        self:SwitchTaskTeam(MainMiddleLeft.SwitchType.Team)
        --Notify.ShowText("组队功能暂未开启")
    end
    AddClickEvent(self.btn_team.gameObject, call_back)

    local function call_back(target, x, y)
        GlobalEvent:Brocast(TeamEvent.CreateTeamView)
    end
    AddClickEvent(self.btn_create.gameObject, call_back)

    local function call_back(target, x, y)
        lua_panelMgr:GetPanelOrCreate(TeamListPanel):Open()
        self:StartAction(false)
    end
    AddClickEvent(self.btn_teamlist.gameObject, call_back)

    local function call_back(target, x, y)
        lua_panelMgr:GetPanelOrCreate(MyTeamPanel):Open()
    end
    AddClickEvent(self.team_members.gameObject, call_back)

    local function call_back(target, x, y)
        TeamController.GetInstance():RequestQuit()
    end
    AddClickEvent(self.btn_quit.gameObject, call_back)

    local function call_back(target, x, y)
        --lua_panelMgr:GetPanelOrCreate(TeamInviteListPanel):Open()
    end
    AddClickEvent(self.team_info.gameObject, call_back)

    local function call_back(target, x, y)
        self:StartAction(false)
    end
    AddClickEvent(self.btn_switch_1.gameObject, call_back)

    local function call_back(target, x, y)
        self:StartAction(true)
    end
    AddClickEvent(self.btn_switch_2.gameObject, call_back)

    self.task_event_list = {}
    local function ON_ACC_TASK_LIST()
        self:UpdateTask()
    end
    self.task_event_list[#self.task_event_list+1] = TaskModel:GetInstance():AddListener(TaskEvent.AccTaskList, ON_ACC_TASK_LIST)
    local function ON_ACC_TASK_UPDATE()
        self:UpdateTask()

    end
    self.task_event_list[#self.task_event_list+1] = TaskModel:GetInstance():AddListener(TaskEvent.AccTaskUpdate, ON_ACC_TASK_UPDATE)

    local function ON_DelGuild()
        self:UpdateTask()

    end
    self.task_event_list[#self.task_event_list+1] = TaskModel:GetInstance():AddListener(TaskEvent.UpdateGuild, ON_DelGuild)

    local function call_back()
        self:UpdateTask()
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(FactionEscortEvent.FactionEscortStart, call_back)
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(FactionEscortEvent.FactionEscortFinish, call_back)

    local function ON_UPDATE_TEAM_INFO()
        self:UpdateTeam()
    end
    self.event_id_3 = TeamModel:GetInstance():AddListener(TeamEvent.UpdateTeamInfo, ON_UPDATE_TEAM_INFO)

    local function ON_QUTI_TEAM()
        self:UpdateTeam()
    end
    self.event_id_4 = TeamModel:GetInstance():AddListener(TeamEvent.QuitTeam, ON_QUTI_TEAM)

    local function call_back()
        self:StartAction(true)
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(EventName.ClosePanel, call_back)

    local function call_back(id)
        local cfg = Config.db_task[id]
        local type = cfg.type
        if type == 6 then  --觉醒任务
            self:IsShowTopItem(RoleInfoModel:GetInstance():GetMainRoleData().level)
        end
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(TaskEvent.FinishTask, call_back)
    self.event_id_6 = TeamModel:GetInstance():AddListener(TaskEvent.AccTaskAccept, call_back)

    local function call_back()
        local wake = RoleInfoModel:GetInstance():GetRoleValue("wake") or 0
        if wake < 3 then
            self:IsShowTopItem(RoleInfoModel:GetInstance():GetMainRoleData().level)
        end
    end

    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(TaskEvent.GlobalAddTask, call_back)

    local function call_back()
        if not self.is_loaded then
            self.isNeedLoadTopItem = true
            return
        end
        self.isNeedLoadTopItem = false
        local role_data = RoleInfoModel:GetInstance():GetMainRoleData()
        self:IsShowTopItem(role_data.level)
    end
    self.event_id_5 = self.model:AddListener(MainEvent.LevelRewardRet, call_back)

    self.role_data = RoleInfoModel:GetInstance():GetMainRoleData()
    self.role_update_list = self.role_update_list or {}
    local function call_back()
        self:UpdateTeamText()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("level", call_back)
    call_back()

    local function call_back()
        self:UpdateTask()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("wake", call_back)
end

function MainMiddleLeft:UpdateTeamText()
    local is_open = self.role_data.level >= 80
    if self.last_check_team_flag == is_open then
        return
    end
    self.last_check_team_flag = is_open
    if is_open then
        self.text_team_component.text = ConfigLanguage.Custom.Team
        self.text_team_component.lineSpacing = 1.4
    else
        self.text_team_component.lineSpacing = 1
        self.text_team_component.text = "Lv.80\nUnlock"
    end
end

function MainMiddleLeft:StartAction(flag)
    self:StopAction()
    local move_time = 0.3
    local x = self.start_pos_x
    if not flag then
        x = self.start_pos_x - self.offset
    else
        SetVisible(self.btn_switch_2.transform, false)
        SetVisible(self.con, true)
    end
    local action = cc.MoveTo(move_time, x, 0, 0)
    if not flag then
        local function end_call_back()
            if not flag then
                SetVisible(self.btn_switch_2.transform, true)
                SetVisible(self.con, false)
            end
        end
        local call_action = cc.CallFunc(end_call_back)
        action = cc.Sequence(action, call_action)
    end
    cc.ActionManager:GetInstance():addAction(action, self)
end

function MainMiddleLeft:StopAction()
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self)
end

function MainMiddleLeft:SwitchTaskTeam(switch_type)
    if self.switch_type == switch_type then
        return
    end
    local x, y = self:GetPosition()

    self.switch_type = switch_type
    local task_color
    local task_img
    local team_color
    if self.switch_type == MainMiddleLeft.SwitchType.Task then
        task_color = Color(252, 245, 224, 255)
        team_color = Color(162, 162, 162, 255)
        self:SetTaskVisible(true)
        self:SetTeamVisible(false)
    else
        task_color = Color(162, 162, 162, 255)
        team_color = Color(252, 245, 224, 255)
        self:SetTaskVisible(false)
        self:SetTeamVisible(true)
    end

    SetColor(self.text_task_component, task_color.r, task_color.g, task_color.b, task_color.a)
    SetColor(self.text_team_component, team_color.r, team_color.g, team_color.b, team_color.a)
end

function MainMiddleLeft:SetTaskVisible(flag)
    if self.boss_info then
        SetVisible(self.boss_info.gameObject, flag)
        SetVisible(self.task_scroll, false)
    else
        if not self.task_top_item then
            --  local role_data = RoleInfoModel:GetInstance():GetMainRoleData()
            -- self:IsShowTopItem(role_data.level)
        else
            self.task_top_item:SetVisible(flag)
        end
        SetVisible(self.task_scroll, flag)
    end
    SetVisible(self.img_task_show, flag)
end

function MainMiddleLeft:SetTeamVisible(flag)
    SetVisible(self.team_info, flag)
    self:UpdateTeam()
    SetVisible(self.img_team_show, flag)
end

function MainMiddleLeft:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.task_viewport.gameObject)
    self.StencilMask.id = self.StencilId
end

function MainMiddleLeft:UpdateTask()
    local list = TaskModel:GetInstance():GetMainShowTaskList()
    local guide_task_id, guide_task_str = TaskModel:GetInstance():GetGuideTaskID(list)

    local height = 52
    local content_height = #list * height

    SetSizeDeltaY(self.task_content, content_height)

    local function call_back(sel_item)
        self.select_task_id = sel_item.data.id
        for k, v in pairs(self.task_item_list) do
            v:SetSelState(sel_item == v)
        end

        if self.task_guide and TaskModel:GetInstance():IsMainTaskGuide(self.task_guide.data.task_id) then
            self.task_guide:destroy()
            self.task_guide = nil
            TaskModel:GetInstance():ClearCurTaskGuide()
        end
    end

    local guide_task_indexMainTaskTopItem
    local guide_task_index
    for i = 1, #list do
        local item = self.task_item_list[i]
        if not item then
            item = MainTaskItem(self.task_content)
            self.task_item_list[i] = item
            item:SetCallBack(call_back)
        end
        item:SetData(list[i], self.StencilId, 3,i)
        if not guide_task_index and guide_task_id == list[i].id then
            guide_task_index = i
        end

        item:SetSelState(self.select_task_id == item.data.id)
    end
    for i = #list + 1, #self.task_item_list do
        local item = self.task_item_list[i]
        item:destroy()
        self.task_item_list[i] = nil
    end

    self:SetTaskGuide(guide_task_index, guide_task_str)
end

function MainMiddleLeft:DelTaskGuide()
    if self.task_guide then
        self.task_guide:destroy()
    end
    self.task_guide = nil
end

function MainMiddleLeft:SetTaskGuide(guide_task_index, guide_task_str)
    if not guide_task_index then
        self:DelTaskGuide()
        return
    end

    local item = self.task_item_list[guide_task_index]
    if not item then
        self:DelTaskGuide()
        return
    end
    if self.task_guide and self.task_guide.is_dctored then
        self.task_guide = nil
    end
    if not self.task_guide then
        self.task_guide = GuideItem4(self.task_scroll)
    end

    local function update_call_back()
        self:TaskScrollChange()
    end
    local function destroy_call_back()
        self:DelTaskGuide()
    end
    local task_id = item.data.id
    local start_time = TaskModel:GetInstance().last_guide_time or Time.time
    local isTaskconfigGuide = not TaskModel:GetInstance():IsSpecialGuide(task_id)
    local showTime = isTaskconfigGuide and GuideItem4.ShowTime or GuideItem4.SpecialShowTime
    local end_time = start_time + showTime
    if TaskModel:GetInstance():IsMainTaskGuide(task_id) then
        end_time = start_time + 100000
    end
    self.task_guide:SetData({ text = guide_task_str, end_time = end_time, task_id = task_id })
    self.task_guide:SetCallBack(update_call_back, destroy_call_back)
    self.task_guide:SetFollowObject(item, 310, 0)
end

function MainMiddleLeft:TaskScrollChange()
    if self.task_guide and self.task_guide.is_loaded then
        local y = GetGlobalPositionY(self.task_guide.transform)
        if y > self.task_scroll_g_y + self.task_scroll_height * 0.5 * 0.01 or y < self.task_scroll_g_y - self.task_scroll_height * 0.5 * 0.01 then
            self.task_guide:SetVisibleState(GuideItem4.VisibleState.Scroll,true)
        else
            self.task_guide:SetVisibleState(GuideItem4.VisibleState.Scroll,false)
        end
    end
end

function MainMiddleLeft:UpdateTeam()
    local team_info = TeamController:GetInstance():GetTeamInfo()
    for _, item in pairs(self.team_item_list) do
        SetVisible(item, false)
    end
    if team_info and TeamModel.GetInstance():SelfInTeam() then
        SetVisible(self.team_pre, false)
        SetVisible(self.team_members, true)
        local members = team_info.members
        self.team_height = 0
        for i = 1, #members do
            local member = members[i]
            local teamItem
            if self.team_item_list[i] then
                teamItem = self.team_item_list[i]
                SetVisible(teamItem, true)
            else
                teamItem = TeamMemberItem(self.TeamMemberItem_gameobject, self.team_content)
                table.insert(self.team_item_list, teamItem)
            end
            teamItem:SetData(member)
            self.team_height = self.team_height + teamItem:GetHeight()
        end
        self:ReLayoutTeamScroll()

        local memberCouont = TeamModel:GetInstance():GetTeamOnlineMemNum()
        self.exp_text.text = TeamModel:GetInstance():GetExpPlus()
        for i = 1, 3 do
            SetVisible(self.team_status_imgs[i].gameObject, true)
            if memberCouont >= i then
                lua_resMgr:SetImageTexture(self, self.team_status_imgs[i], "team_image", "team_status_1")
            else
                lua_resMgr:SetImageTexture(self, self.team_status_imgs[i], "team_image", "team_status_2")
            end
        end
        self.text_team_component.text = string.format("%s (%s)", ConfigLanguage.Custom.Team, #members)
    else
        local is_open = self.role_data.level >= 80
        if is_open then
            self.text_team_component.text = ConfigLanguage.Custom.Team
            self.text_team_component.lineSpacing = 1.4
        else
            self.text_team_component.lineSpacing = 1
            self.text_team_component.text = "Lv.80\nUnlock"
        end
        SetVisible(self.team_pre, true)
        SetVisible(self.team_members, false)
    end
end

function MainMiddleLeft:SetData(data)

end

function MainMiddleLeft:ReLayoutTeamScroll()
    self.team_content.sizeDelta = Vector2(self.team_content.sizeDelta.x, self.team_height)
end

function MainMiddleLeft:UpdateBossInfo(is_show, is_dunge)
    if self.boss_info then
        self.boss_info:destroy()
        self.boss_info = nil
    end
    if is_show or is_dunge then
        if not self.transform then
            self.isCreateLeftCenterNoTransform = true;
            self.isCreateDungeLeftCenterNoTransform = is_dunge;
        else
            if self.text_task_component then
                self.text_task_component.text = ConfigLanguage.Custom.Boss;
            end

            local sceneId = SceneManager:GetInstance():GetSceneId()
            local sceneCfg = Config.db_scene[sceneId]
            if sceneCfg and sceneCfg.type == enum.SCENE_TYPE.SCENE_TYPE_BOSS and sceneCfg.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_PET then
                self.boss_info = PetBossDungeonLeftCenter(self.transform)
            elseif is_dunge then
                --if sceneCfg and sceneCfg.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and sceneCfg.stype == enum.SCENE_STYPE.SCENE_STYPE_GUILDGUARD then
                --    self.boss_info = GuildGuardLeftCenter(self.transform)
                --else
                self.boss_info = DungeonBossLeftCenter(self.transform)
                --end
            else
                if sceneCfg and sceneCfg.type == enum.SCENE_TYPE.SCENE_TYPE_BOSS and sceneCfg.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_BEAST then
                    self.boss_info = BeastIslandLeftCenter(self.transform)
                elseif sceneCfg and sceneCfg.stype == enum.SCENE_STYPE.SCENE_STYPE_SIEGEWAR then
                    self.boss_info = SiegewarBossLeftCenter(self.transform)
                elseif sceneCfg and sceneCfg.stype == enum.SCENE_STYPE.SCENE_STYPE_THRONE then
                    self.boss_info = ThroneStarDungePanel(self.transform)
                else
                    self.boss_info = DungeonLeftCenter(self.transform)
                end

            end

            SetVisible(self.task_scroll, false)
            if self.switch_type ~= MainMiddleLeft.SwitchType.Task then
                self.boss_info:SetShow(false)
            end
        end
    else
        if self.text_task_component then
            self.text_task_component.text = ConfigLanguage.Custom.Task;
        end
        if self.switch_type == MainMiddleLeft.SwitchType.Task then
            SetVisible(self.task_scroll, true)
        end
        self.isCreateLeftCenterNoTransform = false;
    end
end

--监听等级
function MainMiddleLeft:BindRoleUpdate()
    self.role_data = RoleInfoModel.GetInstance():GetMainRoleData()
    self.role_update_list = self.role_update_list or {}
    local function call_back(level)
        self:IsShowTopItem(level)
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("level", call_back)
end

function MainMiddleLeft:IsShowTopItem(level,isTask)
    local lvCfg = self.model:CheckLevelRewards(level)
    local wake = RoleInfoModel:GetInstance():GetRoleValue("wake") or 0
    local showWake = 0
    if  lvCfg == nil then
        showWake = wake + 1
    else
        showWake = lvCfg.is_show
    end

    if wake < 3 and showWake ~= 0 and wake  < showWake then --有觉醒任务
        self:ResizeTopItemPos()
        if not self.task_top_item then
            self.task_top_item = MainTaskTopItem(self.task_scroll)
            self.task_top_item:SetData(wake, 0,2,WakeModel:GetInstance():IsHaveWakeBigTask())
            return
        end
        self.task_top_item:SetData(wake, 0,2,WakeModel:GetInstance():IsHaveWakeBigTask())
        return
    end

    --if isTask and wake >= 4 then
    --    return
    --end

    local cfg = self.model:CheckLevelRewards(level)
    --print2("-------------122--------")
    --print2("-------------122--------")
    --print2("-------------122--------")
    if cfg == nil then
        if self.task_top_item then
            self.task_top_item:destroy()
        end
        self:SetTopItemPos()
        return
    end
    self:ResizeTopItemPos()
    if not self.task_top_item then
        self.task_top_item = MainTaskTopItem(self.task_scroll)
        self.task_top_item:SetData(cfg, level,1)
        return
    end
    self.task_top_item:SetData(cfg, level,1)
end

function MainMiddleLeft:GetTopItemCfg(level)
    local cfg = Config.db_task_jump
    for i, v in pairs(cfg) do
        local levelTab = String2Table(v.level)
        local minLv = levelTab[1]
        local maxLV = levelTab[2]
        if level >= minLv and level < maxLV then
            return v
        end
    end
    return nil
end

function MainMiddleLeft:SetTopItemPos()
    SetSizeDeltaY(self.task_scroll, 245)
    SetLocalPositionY(self.task_scroll, -43)
    SetSizeDeltaY(self.img_task_bg_3_1, 260)
    SetLocalPositionY(self.img_task_bg_3_1, -4)

    self.task_scroll_height = GetSizeDeltaY(self.task_scroll)
    self.task_scroll_g_y = GetGlobalPositionY(self.task_scroll)
    -- self.task_scroll_g_y = GetGlobalPositionY(self.task_scroll)

    self.StencilMask:Resize()
end

function MainMiddleLeft:ResizeTopItemPos()
    SetSizeDeltaY(self.task_scroll, 186)
    SetLocalPositionY(self.task_scroll, -71)
    SetSizeDeltaY(self.img_task_bg_3_1, 198)
    SetLocalPositionY(self.img_task_bg_3_1, -3)
    self.task_scroll_height = GetSizeDeltaY(self.task_scroll)
    self.task_scroll_g_y = GetGlobalPositionY(self.task_scroll)
    -- self.task_scroll_g_y = GetGlobalPositionY(self.task_scroll)

    self.StencilMask:Resize()
end



