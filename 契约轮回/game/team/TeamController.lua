require('game.team.RequireTeam')

TeamController = TeamController or class("TeamController", BaseController)
local this = TeamController

function TeamController:ctor()
    TeamController.Instance = self
    self.model = TeamModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function TeamController:dctor()
end

function TeamController:GetInstance()
    if not TeamController.Instance then
        TeamController.new()
    end
    return TeamController.Instance
end

function TeamController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1500_team_pb"
    self:RegisterProtocal(proto.TEAM_CREATE_TEAM, self.HandleCreateTeam)
    self:RegisterProtocal(proto.TEAM_UPDATE_TEAM_INFO, self.HandleUpdateTeamInfo)
    self:RegisterProtocal(proto.TEAM_QUIT_TEAM, self.HandleQuitTeam)
    self:RegisterProtocal(proto.TEAM_CHANGE_SET, self.HandleChangeSet)
    self:RegisterProtocal(proto.TEAM_GET_TEAM_LIST, self.HandleGetTeamList)
    self:RegisterProtocal(proto.TEAM_APPLY, self.HandleApplyTeam)
    self:RegisterProtocal(proto.TEAM_GET_APPLY_LIST, self.HandleGetApplyList)
    self:RegisterProtocal(proto.TEAM_HANDLE_APPLY, self.HandleHandleApply)
    self:RegisterProtocal(proto.TEAM_REMIND_CAPTAIN, self.HandleRemindCaptain)
    self:RegisterProtocal(proto.TEAM_GET_INVITE_LIST, self.HandleGetInviteList)
    self:RegisterProtocal(proto.TEAM_HANDLE_INVITE, self.HandleAcceptInvite)
    self:RegisterProtocal(proto.TEAM_KICKOUT, self.HandleKickout)
    self:RegisterProtocal(proto.TEAM_UPDATE_TEAM_MEMBER, self.HandleUpdateTeamMember)
    self:RegisterProtocal(proto.TEAM_ENTER_DUNGE_ASK, self.HandleDungeEnterAsk)
    self:RegisterProtocal(proto.TEAM_ENTER_DUNGE, self.HandleDungeEnter)
    self:RegisterProtocal(proto.TEAM_TRANS_CAPTAIN, self.HandleTransCaptain)
    self:RegisterProtocal(proto.TEAM_UPDATE_LIST, self.HandleUpdateTeamList)
end

function TeamController:AddEvents()
    -- --请求基本信息
    -- local function ON_REQ_BASE_INFO()
    -- self:RequestLoginVerify()
    -- end
    -- self.model:AddListener(TeamModel.REQ_BASE_INFO, ON_REQ_BASE_INFO)
    GlobalEvent:AddListener(TeamEvent.CreateTeamView, handler(self, self.CreateTeamView))
    self.model:AddListener(TeamEvent.CloseTeamView, handler(self, self.CloseTeamView))

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(MyTeamPanel):Open()
    end
    self.model:AddListener(TeamEvent.CreateTeam, call_back)

    local function call_back(dunge_id, role_ids)
        OperationManager:GetInstance():StopAStarMove()
        if self.model:GetTeamOnlineMemNum() == 1 then
            self:DungeEnter(dunge_id)
        else
            local panel = lua_panelMgr:GetPanelOrCreate(EnterDungeonPanel)
            panel:SetData(dunge_id, role_ids)
            panel:Open()
        end
    end
    self.model:AddListener(TeamEvent.EnterDungeAsk, call_back)

    local function call_back()
        local function call_back2()
            local role_id = RoleInfoModel:GetInstance():GetMainRoleId()
            if self.model.team_info and self.model:IsCaptain(role_id) then
                local members = self.model.team_info.members
                for _, member in pairs(members) do
                    if faker:GetInstance():is_fake(member.role_id) then
                        self:RequestKickout(member.role_id)
                    end
                end
            end
        end
        GlobalSchedule:StartOnce(call_back2, 3)
    end
    GlobalEvent:AddListener(DungeonEvent.LEAVE_DUNGEON_SCENE, call_back)

    local function call_back(scene_id)
        local stype = Config.db_scene[scene_id].stype
        self.model:SetMerge(stype, 0)
    end
    GlobalEvent:AddListener(DungeonEvent.ENTER_DUNGEON_SCENE, call_back)

    local function call_back()
        local main_role_id = RoleInfoModel:GetInstance():GetMainRoleId()
        if TeamModel.GetInstance():IsCaptain(main_role_id) then
            local function call_back2()
                lua_panelMgr:GetPanelOrCreate(ApplyListPanel):Open()
            end
            local applyLst = self.model:GetApplyList()
            if table.nums(applyLst) <= 0 then
                GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "teamapply", false, call_back2)
            else
                GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "teamapply", true, call_back2)
            end
        end
    end
    GlobalEvent:AddListener(TeamEvent.UpdateApplyList, call_back)

    local function call_back()
        local invite_list = TeamModel:GetInstance():GetInivteList()
        local function call_back2()
            lua_panelMgr:GetPanelOrCreate(TeamInviteListPanel):Open()
        end
        if not table.isempty(invite_list) then
            GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "teaminvite", true, call_back2)
        else
            GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "teaminvite", false, call_back2)
        end
    end
    GlobalEvent:AddListener(TeamEvent.UpdateInviteList, call_back)
end

function TeamController:CreateTeamView(type_id, invite_role)
    local scene_id = SceneManager:GetInstance():GetSceneInfo().scene
    local scene_type = Config.db_scene[scene_id].type
    if not type_id then
        if scene_type == enum.SCENE_TYPE.SCENE_TYPE_CITY
                or scene_type == enum.SCENE_TYPE.SCENE_TYPE_FIELD then
            type_id = 2
        else
            type_id = 1
        end
    end
    type_id = ((type_id == 0) and 1 or type_id)
    local target = Config.db_team_target_sub[type_id]
    local min_level = String2Table(target.min_lv)[1][3]
    local max_level = String2Table(target.max_lv)[1][3]
    self.model.invite_role = invite_role
    self:RequestCreateTeam(type_id, min_level, max_level, 1)
end

function TeamController:CloseTeamView()
    lua_panelMgr:GetPanelOrCreate(MyTeamPanel):Close()
end
-- overwrite
function TeamController:GameStart()
    local function call_back()
        self:RequestGetTeamInfo()
    end
    GlobalSchedule:StartOnce(call_back, Constant.GameStartReqLevel.Ordinary)

    local function call_back()
        if self.model:IsCaptain(RoleInfoModel:GetInstance():GetMainRoleId()) then
            self:RequestGetApplyList()
        end
        if not self.model.team_info then
            self:RequestGetInviteList()
        end
    end
    GlobalSchedule:StartOnce(call_back, Constant.GameStartReqLevel.VLow)

    local function ok_func(...)
        if self.model.team_info then
            self:RequestGetTeamInfo()
        end
    end
    GlobalSchedule:Start(ok_func, 60)
end

function TeamController:GetTeamInfo()
    return self.model:GetTeamInfo()
end

function TeamController:ShowCreateTeamView()
    local UITransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.UI)
    self.createTeamPanel = CreateTeamPanel(UITransform)
end

--请求基本信息
function TeamController:RequestCreateTeam(type_id, min_level, max_level, is_auto_accept)
    local pb = self:GetPbObject("m_team_create_team_tos")
    pb.type_id = type_id
    pb.min_level = min_level
    pb.max_level = max_level
    pb.is_auto_accept = is_auto_accept
    self:WriteMsg(proto.TEAM_CREATE_TEAM, pb)
end

function TeamController:RequestGetTeamInfo()
    local pb = self:GetPbObject("m_team_get_team_tos")

    self:WriteMsg(proto.TEAM_GET_TEAM, pb)
end

function TeamController:RequestQuit()
    local pb = self:GetPbObject("m_team_quit_team_tos")
    self:WriteMsg(proto.TEAM_QUIT_TEAM, pb)
end

function TeamController:RequestChangeTarget(type_id, min_level, max_level, is_auto_accept)
    local pb = self:GetPbObject("m_team_change_set_tos")
    pb.type_id = type_id or self.model.team_info.type_id
    pb.min_level = min_level or self.model.team_info.min_level
    pb.max_level = max_level or self.model.team_info.max_level
    pb.is_auto_accept = is_auto_accept or self.model.team_info.is_auto_accept
    self:WriteMsg(proto.TEAM_CHANGE_SET, pb)
end

function TeamController:RequestGetTeamList(type_id)
    local pb = self:GetPbObject("m_team_get_team_list_tos")
    pb.type_id = type_id
    self:WriteMsg(proto.TEAM_GET_TEAM_LIST, pb)
end

function TeamController:RequestApply(team_id, is_role)
    local pb = self:GetPbObject("m_team_apply_tos")
    pb.team_id = team_id
    pb.is_role = is_role or 0
    self:WriteMsg(proto.TEAM_APPLY, pb)
end

--获取入队申请列表
function TeamController:RequestGetApplyList()
    local pb = self:GetPbObject("m_team_get_apply_list_tos")

    self:WriteMsg(proto.TEAM_GET_APPLY_LIST, pb)
end

function TeamController:RequestHandleApply(role_id, is_accept, reject_all)
    local pb = self:GetPbObject("m_team_handle_apply_tos")
    if reject_all then
        pb.reject_all = reject_all
    else
        pb.role_id = role_id
        pb.is_accept = is_accept
    end
    self:WriteMsg(proto.TEAM_HANDLE_APPLY, pb)
end

function TeamController:RequestRemindCaptain()
    local pb = self:GetPbObject("m_team_remind_captain_tos")

    self:WriteMsg(proto.TEAM_REMIND_CAPTAIN, pb)
end

function TeamController:RequestInvite(role_id)
    local pb = self:GetPbObject("m_team_invite_tos")
    pb.role_id = role_id

    self:WriteMsg(proto.TEAM_INVITE, pb)
end

function TeamController:RequestGetInviteList()
    local pb = self:GetPbObject("m_team_get_invite_list_tos")

    self:WriteMsg(proto.TEAM_GET_INVITE_LIST, pb)
end

function TeamController:RequestHandleInvite(team_id, reject_all)
    local pb = self:GetPbObject("m_team_handle_invite_tos")
    if reject_all then
        pb.reject_all = reject_all
    end
    pb.team_id = team_id or 0
    self:WriteMsg(proto.TEAM_HANDLE_INVITE, pb)
end

function TeamController:RequestKickout(role_id)
    local pb = self:GetPbObject("m_team_kickout_tos")
    pb.role_id = role_id

    self:WriteMsg(proto.TEAM_KICKOUT, pb)
end

----服务的返回信息
function TeamController:HandleCreateTeam()
    local data = self:ReadMsg("m_team_create_team_toc")

    --self:CreateTeamView()
    --lua_panelMgr:GetPanelOrCreate(MyTeamPanel):Open()
    if self.model.invite_role then
        self:RequestInvite(self.model.invite_role)
        self.model.invite_role = nil
    elseif self.model.special_dunge_id then
        self:HandleSpecialCreateTeam()
        self.model.special_dunge_id = nil
    else
        if self.model.no_open_team_panel then
            self.model.no_open_team_panel = nil
            return
        end
        self.model:Brocast(TeamEvent.CreateTeam, self.model.no_open_team_panel)
    end
end

function TeamController:HandleUpdateTeamInfo()
    local data = self:ReadMsg("m_team_update_team_info_toc")
    self.model:UpdateTeamInfo(data.team_info)

    self.model:Brocast(TeamEvent.UpdateTeamInfo)
end

function TeamController:HandleQuitTeam()
    local data = self:ReadMsg("m_team_quit_team_toc")
    self.model:UpdateTeamInfo(nil)
    self.model:DelApplyTeamId(data.team_id)
    self.model:Brocast(TeamEvent.QuitTeam)
end

function TeamController:HandleChangeSet()
    local data = self:ReadMsg("m_team_change_set_toc")

    self.model:Brocast(TeamEvent.ChangeSet)
    --lua_panelMgr:GetPanelOrCreate(CreateTeamPanel):Close()
end

function TeamController:HandleGetTeamList()
    local data = self:ReadMsg("m_team_get_team_list_toc")

    self.model:UpdateTeamList(data.team_list)
    self.model:Brocast(TeamEvent.UpdateTeamList)
end

function TeamController:HandleApplyTeam()
    local data = self:ReadMsg("m_team_apply_toc")
    self.model:AddApplyTeamId(data.team_id)

    self.model:Brocast(TeamEvent.ApplyTeamSuccess)
    Notify.ShowText("Successfully applied")
end

function TeamController:HandleGetApplyList()
    local data = self:ReadMsg("m_team_get_apply_list_toc")
    if data.is_add_new == 1 then
        self.model:AddApplyList(data.apply_list)
    else
        self.model:UpdateApplyList(data.apply_list)
    end

    GlobalEvent:Brocast(TeamEvent.UpdateApplyList)
end

function TeamController:HandleHandleApply()
    local data = self:ReadMsg("m_team_handle_apply_toc")
    local role_id = data.role_id

    self.model:DeleteFromApplyList(role_id)
    GlobalEvent:Brocast(TeamEvent.UpdateApplyList)
end

function TeamController:HandleRemindCaptain()
    --Dialog.ShowTwo(nil,string.format(ConfigLanguage.Team.EnterTip,1,"东奔西走"))
    local data = self:ReadMsg("m_team_remind_captain_toc")
    lua_panelMgr:GetPanelOrCreate(TeamRemindPanel):Open(data.name)
end

function TeamController:HandleGetInviteList()
    local data = self:ReadMsg("m_team_get_invite_list_toc")
    if data.is_add_new == 1 then
        self.model:AddInviteList(data.invite_list)
    else
        self.model:UpdateInviteList(data.invite_list)
    end

    GlobalEvent:Brocast(TeamEvent.UpdateInviteList)
end

function TeamController:HandleAcceptInvite()
    lua_panelMgr:GetPanelOrCreate(TeamInviteListPanel):Close()
    lua_panelMgr:GetPanelOrCreate(MyTeamPanel):Open()
end

function TeamController:HandleKickout()
    self.model.team_info = nil
    self.model:Brocast(TeamEvent.UpdateTeamInfo)
end

function TeamController:HandleUpdateTeamMember()
    local data = self:ReadMsg("m_team_update_team_member_toc")
    local role_id = data.role_id
    local is_online = data.is_online
    local scene_id = data.scene_id

    self.model:UpdateTeamMember(role_id, is_online, scene_id)
    self.model:Brocast(TeamEvent.UpdateTeamInfo)
end

--请求进入副本
function TeamController:DungeEnterAsk(dunge_id, is_agree)
    local pb = self:GetPbObject("m_team_enter_dunge_ask_tos")
    pb.dunge_id = dunge_id
    if is_agree then
        pb.is_agree = is_agree
    end
    local stype = Config.db_dunge[dunge_id].stype
    local count = self.model:GetMerge(stype)
    if is_agree == 1 and count > 1 then
        local cost = String2Table(Config.db_game["dunge_merge_cost"].val)[1][1]
        local need = cost[2] * (count-1)
        local vo = RoleInfoModel:GetInstance():CheckGold(need, Constant.GoldType.BGold)
        if not vo then
            return
        end
    end
    pb.count = count
    self:WriteMsg(proto.TEAM_ENTER_DUNGE_ASK, pb)
end

function TeamController:HandleDungeEnterAsk()
    local data = self:ReadMsg("m_team_enter_dunge_ask_toc")
    local dunge_id = data.dunge_id
    local role_ids = data.role_ids
    local is_agree = data.is_agree
    local role_id  = data.role_id
    local merge_count = data.count

    --同意
    if is_agree == 1 then
        self.model:SetAgreeIds(role_ids)
        self.model:SetShowMerge(role_id, merge_count)
        self.model:Brocast(TeamEvent.EnterDungeAsk, dunge_id, role_ids)
        local stype = Config.db_dunge[dunge_id].stype
    else
        --不同意
        self.model:SetAgreeIds({})
        self.model.merges = {}
        self.model:Brocast(TeamEvent.EnterDungeDisAgree)
    end
end

function TeamController:DungeEnter(dunge_id)
    local pb = self:GetPbObject("m_team_enter_dunge_tos")
    pb.dunge_id = dunge_id
    self:WriteMsg(proto.TEAM_ENTER_DUNGE, pb)
end

function TeamController:HandleDungeEnter()
    local data = self:ReadMsg("m_team_enter_dunge_toc")

    self.model:SetAgreeIds({})
    self.model.merges = {}
    self.model:Brocast(TeamEvent.EnterDunge)
end

function TeamController:RequestAddFaker()
    local pb = self:GetPbObject("m_team_faker_tos")
    self:WriteMsg(proto.TEAM_FAKER, pb)
end

--是否同队
function TeamController:IsSameTeam(team_id)
    return self.model.team_info and self.model.team_info.id == team_id
end

--移交队长
function TeamController:RequestTransCaptain(role_id)
    if not self.model:IsCaptain(RoleInfoModel:GetInstance():GetMainRoleId()) then
        return Notify.ShowText("You are not the team leader")
    end
    local pb = self:GetPbObject("m_team_trans_captain_tos")
    pb.role_id = role_id
    self:WriteMsg(proto.TEAM_TRANS_CAPTAIN, pb)
end

function TeamController:HandleTransCaptain()
    Notify.ShowText("Team leadership transferred")
end

function TeamController:HandleUpdateTeamList()
    GlobalEvent:Brocast(TeamEvent.NeedUpdateTeamList)
end

function TeamController:AddFaker()
    if self.model.auto_call then
        if self.schedule_id then
            GlobalSchedule:Stop(self.schedule_id)
            self.schedule_id = nil
            return
        end
    end
    local second = 2
    local level = RoleInfoModel:GetInstance():GetRoleValue("level")
    if level >= 200 and self.model:GetAddFaker() == 1 then
        return
    end
    local task_ids = String2Table(Config.db_game["first_dunge_equip"].val)[1]
    local has_task = false
    for _, task_id in pairs(task_ids) do
        local task = TaskModel:GetInstance():GetTask(task_id)
        if task and task.state == enum.TASK_STATE.TASK_STATE_ACCEPT then
            has_task = true
            break
        end
    end
    if has_task then
        second = 0.1
    else
        if level <= 200 then
            second = 20
        elseif level <= 300 then
            second = 120
        elseif level <= 350 then
            second = 180
        else
            second = 300
        end
    end
    local function call_back()
        if self.model.team_info and #self.model.team_info.members < 3 then
            self:RequestAddFaker()
            self.schedule_id = nil
        end
    end
    self.schedule_id = GlobalSchedule:StartOnce(call_back, second)
end

function TeamController:IsSpecialCreateTeam()
    local task_id = String2Table(Config.db_game["first_dunge_equip"].val)[1][1]
    local task = TaskModel:GetInstance():GetTask(task_id)
    if task and task.state == enum.TASK_STATE.TASK_STATE_ACCEPT then
        return true
    end
    return false
end

function TeamController:HandleSpecialCreateTeam()
    if self.model.team_info then
        local num = #self.model.team_info.members
        for i=1, 3-num do
            self:RequestAddFaker()
        end
        local dunge_id = self.model.special_dunge_id
        local function call_back()
            self:DungeEnterAsk(dunge_id, 1)
        end
        GlobalSchedule:StartOnce(call_back, 0.3)
    end
end