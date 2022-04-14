--
-- @Author: chk
-- @Date:   2018-12-05 10:40:57
--
require('game.faction.RequireFaction')
FactionController = FactionController or class("FactionController", BaseController)
local FactionController = FactionController

function FactionController:ctor()
    FactionController.Instance = self
    self.model = FactionModel:GetInstance()
    self.events = {};
    self:AddEvents()
    self:RegisterAllProtocal()
end

function FactionController:dctor()
end

function FactionController:GetInstance()
    if not FactionController.Instance then
        FactionController.new()
    end
    return FactionController.Instance
end

function FactionController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1400_guild_pb"
    self:RegisterProtocal(proto.GUILD_LIST, self.ResponeFactionList)
    self:RegisterProtocal(proto.GUILD_CREATE, self.ResponeCreateFaction)
    self:RegisterProtocal(proto.GUILD_INFO, self.ResponeSelfFactionInfo)
    self:RegisterProtocal(proto.GUILD_QUERY, self.ResponeFactionInfo)
    self:RegisterProtocal(proto.GUILD_APPOINT, self.ResponeAppointment)
    self:RegisterProtocal(proto.GUILD_APPLY, self.ResponeApplyEnterFaction)
    self:RegisterProtocal(proto.GUILD_CANCEL, self.ResponeCancleApplyEnterFaction)
    self:RegisterProtocal(proto.GUILD_NOTICE, self.ResponeModifyNotice)
    self:RegisterProtocal(proto.GUILD_APPLIANTS, self.ResponeApplyList)
    self:RegisterProtocal(proto.GUILD_REJECT, self.ResponeRefuseApply)
    self:RegisterProtocal(proto.GUILD_APPROVE, self.ResponeAcceptApply)
    self:RegisterProtocal(proto.GUILD_QUIT, self.ResponeQuitFaction)
    self:RegisterProtocal(proto.GUILD_DISMISS, self.ResponeDisCareer)
    self:RegisterProtocal(proto.GUILD_JOIN, self.ResponeMemberJoint)
    self:RegisterProtocal(proto.GUILD_DEMISE, self.ResponseDemis)
    self:RegisterProtocal(proto.GUILD_RUNFOR, self.ResponeApplyCareer)
    self:RegisterProtocal(proto.GUILD_AGREE, self.ResponeAgreeApplyCareer)
    self:RegisterProtocal(proto.GUILD_REFUSE, self.ResponeRefuseApplyCareer)
    self:RegisterProtocal(proto.GUILD_UPGRADE, self.ResponeUpLV)
    self:RegisterProtocal(proto.GUILD_LOG, self.ResponeLog)
    self:RegisterProtocal(proto.GUILD_WELFARE, self.ResponeWelf)
    self:RegisterProtocal(proto.GUILD_SETUP, self.ResponeFactionSet)
    self:RegisterProtocal(proto.GUILD_SETTING, self.ResponeFactionSetInfo)
    self:RegisterProtocal(proto.GUILD_DISBAND, self.ResponeDisBand)
    self:RegisterProtocal(proto.GUILD_MEMBERS, self.ResponeMember)

    self:RegisterProtocal(proto.GUILD_KICKOUT, self.ResponeKitOut)
    self:RegisterProtocal(proto.GUILD_RENAME, self.ResponeGuildRename)

    GlobalEvent:AddListener(FactionEvent.OpenFactionPanel, handler(self, self.OpenFactionPanel))
    GlobalEvent:AddListener(FactionEvent.RequestMember, handler(self, self.RequestMember))
    GlobalEvent:AddListener(FactionEvent.Faction_OpenTempleEvent, handler(self, self.OnOpenTemple))
    GlobalEvent:AddListener(FactionEvent.Faction_OpenGuildWithWarOpeningEvent, handler(self, self.OpenFactionPanelWithWarOpening))
    GlobalEvent:AddListener(ActivityEvent.ChangeActivity, handler(self, self.OnChangeActivity))

    GlobalEvent:AddListener(FPacketEvent.UpdateFPacketRedDot, handler(self, self.UpdateFPacketRedDot))

    GlobalEvent:AddListener(ActivityEvent.ChangeActivity, handler(self, self.ChangeActivity));

    local function call_back(isRed)
        --logError("guidl",isRed)
        self.model.redPoints[4] = isRed
        self:UpdateRedPoint()
    end
    GlobalEvent:AddListener(FactionEvent.Faction_GuildWarRedPointEvent, call_back)

    local function call_back(isRed)
        self.model.redPoints[7] = isRed
        self:UpdateRedPoint()
    end
    GlobalEvent:AddListener(FactionSerWarEvent.FactionSerWarRed, call_back)


    local function call_back()
        SceneControler:GetInstance():RequestSceneChange(30361, enum.SCENE_CHANGE.SCENE_CHANGE_ACT, nil, nil, 10211)
    end
    GlobalEvent:AddListener(FactionEvent.Faction_EnterGuildHouseEvent, call_back)



    --local function call_back(id)
    --	if id == 90010011 then
    --		self:UpdateRedPoint()
    --	end
    --end
    --GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)

    -- self:RegisterProtocal(35025, self.RequestLoginVerify)
end

function FactionController:AddEvents()
    -- --请求基本信息
    -- local function ON_REQ_BASE_INFO()
    -- self:RequestLoginVerify()
    -- end
    -- self.model:AddListener(FactionModel.REQ_BASE_INFO, ON_REQ_BASE_INFO)

    local handle_activity_list = function(bool, id)
        --如果
        --if bool and id == FactionModel:GetInstance().GUILD_ACTIVITY_ID and ActivityModel:GetInstance():GetActivity(FactionModel:GetInstance().GUILD_ACTIVITY_ID) then
        --    local activityConfig = Config.db_activity[FactionModel:GetInstance().GUILD_ACTIVITY_ID];
        --    if activityConfig and activityConfig.scene then
        --        local sceneConfig = Config.db_scene[activityConfig.scene];
        --        if sceneConfig then
        --            local reqtab = String2Table(sceneConfig.reqs);
        --            for k, reqs in pairs(reqtab) do
        --                if #reqs == 2 and reqs[1] == "level" then
        --                    if RoleInfoModel:GetInstance():GetMainRoleLevel() >= reqs[2] then
        --                        self:OpenFactionPanel(5,2);
        --                    end
        --                end
        --            end
        --        end
        --    end
        --end
        print2("活动开启");
    end
    --AddEventListenerInTab(ActivityEvent.ChangeActivity, handle_activity_list, self.events);

    local call_back2 = function(tab_index, toggle_id)
        if tab_index == 10221 then

        end
        local roleInfoData = RoleInfoModel.GetInstance():GetMainRoleData();
        if roleInfoData.guild == "0" or roleInfoData.guild == 0 or roleInfoData.gname == "" then
            Notify.ShowText(errno[1200015]);
            return ;
        end
        lua_panelMgr:GetPanelOrCreate(FactionPanel):Open(5, 2);
    end
    GlobalEvent:AddListener(FactionEvent.OPEN_GUILD_GUARD, call_back2)
end

-- overwrite
function FactionController:GameStart()
    local function step()
        local role = RoleInfoModel.GetInstance():GetMainRoleData()
        if role.guild ~= "0" then
            self:RequestSelfFactionInfo()
            self:RequestApplyList()
            FactionSkillController:GetInstance():RequestFactionSkills()
        end

    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Best)
end

--转让帮主
function FactionController:RequestDemis(role_id)
    local pb = self:GetPbObject("m_guild_demise_tos")
    pb.to = role_id
    self:WriteMsg(proto.GUILD_DEMISE, pb)
end

function FactionController:ResponseDemis()
    local data = self:ReadMsg("m_guild_demise_toc")
    self.model:SetMemberCareer(data.from, enum.GUILD_POST.GUILD_POST_MEMB)
    self.model:SetMemberCareer(data.to, enum.GUILD_POST.GUILD_POST_CHIEF)
    self.model:Brocast(FactionEvent.Demise, data)
end

--踢出帮会
function FactionController:RequestKitOut(role_id)
    local pb = self:GetPbObject("m_guild_kickout_tos")
    pb.role_id = role_id
    self:WriteMsg(proto.GUILD_KICKOUT, pb)

end

function FactionController:ResponeKitOut()
    local data = self:ReadMsg("m_guild_kickout_toc")
    self.model:SetKitOut(data.role_id)
    self.model:Brocast(FactionEvent.KitOut, data.role_id)

    GlobalEvent:Brocast(FactionEvent.KitOut)
end

function FactionController:OpenFactionPanel(index, toggleIndex)
    local guild = RoleInfoModel.GetInstance():GetMainRoleData().guild
    local m_index = 1
    if guild ~= "0" then
        m_index = index
    end
    lua_panelMgr:GetPanelOrCreate(FactionPanel):Open(m_index, toggleIndex)
end

function FactionController:OpenFactionPanelWithWarOpening()
    local tabPage = RoleInfoModel.GetInstance():GetMainRoleData().guild ~= "0" and 5 or 1
    lua_panelMgr:GetPanelOrCreate(FactionPanel):Open(tabPage, 1)
end

function FactionController:OnOpenTemple()
    lua_panelMgr:GetPanelOrCreate(FactionBattleTemplePanel):Open()
end

---活动变化
function FactionController:OnChangeActivity(isOpen, activityId, startTime, endTime)

    --local cf = Config.db_activity[activityId]
    --if(cf and cf.group == 102) then
    --	if(isOpen) then
    --		GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "guildBattle", true)
    --		self.CountdownTip = FactionBattleCountdownTip()
    --		self.CountdownTip.mountName = "guildBattle"
    --		self.CountdownTip:SetTime(startTime, endTime)
    --	else
    --		if(self.CountdownTip) then
    --			self.CountdownTip:destroy()
    --		end
    --
    --		GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "guildBattle", false)
    --	end
    --
    --end
end

function FactionController:RequestFactionList()
    local pb = self:GetPbObject("m_guild_list_tos")
    self:WriteMsg(proto.GUILD_LIST, pb)
end

function FactionController:ResponeFactionList()
    local data = self:ReadMsg("m_guild_list_toc")
    self.model:SetFactionList(data.guilds)
    --self.model.factionLst = data.guilds
    self.model:Brocast(FactionEvent.FactionList)
end

--请求自己的帮派成员
function FactionController:RequestMember()
    local pb = self:GetPbObject("m_guild_members_tos")
    self:WriteMsg(proto.GUILD_MEMBERS)
end

function FactionController:ResponeMember()
    self.model.members = {}
    local data = self:ReadMsg("m_guild_members_toc")
    for i, v in pairs(data.members) do
        self.model:AddMember(v)
    end
    --self.model:SetMembers(data.members)
    self.model:Brocast(FactionEvent.ResponeMember, data)
end

--请求解散帮会
function FactionController:RequestDisband()
    local pb = self:GetPbObject("m_guild_disband_tos")
    self:WriteMsg(proto.GUILD_DISBAND, pb)
end

function FactionController:ResponeDisBand()
    local roleInfoData = RoleInfoModel.GetInstance():GetMainRoleData()
    roleInfoData.guild = "0"

    self.model:Brocast(FactionEvent.DisbandFaction)

    TaskModel:GetInstance():Brocast(TaskEvent.ReqTaskList)
end

--退出帮会
function FactionController:RequestQuitFaction()
    local pb = self:GetPbObject("m_guild_quit_tos")
    local roleData = RoleInfoModel.Instance:GetMainRoleData()
    self:WriteMsg(proto.GUILD_QUIT)

end

function FactionController:ResponeQuitFaction()
    local data = self:ReadMsg("m_guild_quit_toc")
    local roleData = RoleInfoModel.Instance:GetMainRoleData()
    if data.role_id == 0 then
        --自己退出帮会
        roleData.guild = "0"
        self.model.faction_id = "0"
        self.model.members = {}
        self:ClearRedPoint()
        self.model:Brocast(FactionEvent.QuitSucess)

    end
    -- TaskModel:GetInstance():Brocast(TaskEvent.ReqTaskList)
end

function FactionController:RequestCreateFaction(name, lv)
    local pb = self:GetPbObject("m_guild_create_tos")
    pb.name = name
    pb.level = lv
    self:WriteMsg(proto.GUILD_CREATE, pb)
end

function FactionController:ResponeCreateFaction()
    local data = self:ReadMsg("m_guild_create_toc")
    self.model.faction_id = data.guild_id
    self.model:Brocast(FactionEvent.FactionCreateSucess)
    OpenHighController.GetInstance():HandleOpenPanel()
    TaskModel:GetInstance():Brocast(TaskEvent.ReqTaskList)
end

--请求(自己)的帮派信息
function FactionController:RequestSelfFactionInfo()
    local pb = self:GetPbObject("m_guild_info_tos")
    self:WriteMsg(proto.GUILD_INFO, pb)
end

function FactionController:ResponeSelfFactionInfo()
    local data = self:ReadMsg("m_guild_info_toc")
    --self.model.members = data.members
    self.model.selfFactionInfo = data
    self.model:SetMembers(data.members)
    self.model:SetCadremember()
    self.model:SetSelfCadre()
    self.model.guildLv = data.level
    for i, v in pairs(data.welfare) do
        --self.model:SetReceiveWelfareCount(1,v)
        self.model:Setwelfares(i, v)
    end
    self:UpdateRedPoint()
    self.model:Brocast(FactionEvent.SelfFactionInfo, data)
end


--请求(别人的帮派信息)
function FactionController:RequestFactionInfo(id)
    Chkprint("请求帮派消息" .. id)
    local pb = self:GetPbObject("m_guild_query_tos")
    pb.guild_id = id
    self:WriteMsg(proto.GUILD_QUERY, pb)
end

function FactionController:ResponeFactionInfo()
    local data = self:ReadMsg("m_guild_query_toc")
    lua_panelMgr:GetPanelOrCreate(FactionMessagePanel):Open(data)
end

--加入帮会通知
function FactionController:ResponeMemberJoint()
    local data = self:ReadMsg("m_guild_join_toc")
    local roleData = RoleInfoModel.Instance:GetMainRoleData()
    --if roleData.guild == data.guild_id then
    roleData.guild = data.guild_id
    roleData.gname = self.model:GetFactionNameById(data.guild_id)
    self.model.faction_id = data.guild_id
    FactionSkillController:GetInstance():RequestFactionSkills()  --加入成功后请求公会技能
    self:RequestSelfFactionInfo()
    self.model:Brocast(FactionEvent.JoinSucuss)
    --end

    TaskModel:GetInstance():Brocast(TaskEvent.ReqTaskList)
	
	local str = RoleInfoModel.GetInstance():GetMainRoleData().name
	local my_name = "<color=#ff9600>" .. str .. "</color>"
	local str = string.format(msgno[140007].desc, my_name)
	str = string.trim(str)
	GlobalEvent:Brocast(ChatEvent.AutoUnionSendTextMsg, str)	
	
	GlobalEvent:Brocast(FactionEvent.ShowMainIcon)
end

--职位任命
function FactionController:RequestAppointment(role_id, pos)
    local pb = self:GetPbObject("m_guild_appoint_tos")
    pb.role_id = role_id
    pb.post = pos
    self:WriteMsg(proto.GUILD_APPOINT, pb)
end

function FactionController:ResponeAppointment()
    local data = self:ReadMsg("m_guild_appoint_toc")
    self.model:SetMemberCareer(data.role_id, data.post)
    self.model:Brocast(FactionEvent.AppointmentSucess, data)
    local myPost = self.model:SetSelfCadre()
    if myPost == enum.GUILD_POST.GUILD_POST_CHIEF and data.post == enum.GUILD_POST.GUILD_POST_VICE then
        OpenHighController.GetInstance():HandleOpenPanel()
    end
    GlobalEvent:Brocast(FactionEvent.AppointmentSucess)
end

--解除职位
function FactionController:RequestDisCareer(role_id)
    local pb = self:GetPbObject("m_guild_dismiss_tos")
    pb.role_id = role_id
    self:WriteMsg(proto.GUILD_DISMISS, pb)
end

function FactionController:ResponeDisCareer(role_id)
    local data = self:ReadMsg("m_guild_dismiss_toc")
    self.model:SetMemberCareer(data.role_id, enum.GUILD_POST.GUILD_POST_MEMB)
    self.model:Brocast(FactionEvent.DisCareerSucess, data.role_id)
    GlobalEvent:Brocast(FactionEvent.DisCareerSucess)
end


--申请职位
function FactionController:RequestApplyCareer(career)
    local pb = self:GetPbObject("m_guild_runfor_tos")
    pb.post = career
    self:WriteMsg(proto.GUILD_RUNFOR, pb)
end

function FactionController:ResponeApplyCareer()
    local data = self:ReadMsg("m_guild_runfor_toc")
    if data.appliant.base.id == 0 then
        Notify.ShowText(ConfigLanguage.Mix.ApplySucess)
    else
        self.model:AddApplyList(data.appliant)
        self:UpdateRedPoint()
    end
    self.model:Brocast(FactionEvent.ApplyCareer, data.post)
end

--同意职位申请
function FactionController:RequestAgreeApplyCareer(role_id)
    local pb = self:GetPbObject("m_guild_agree_tos")
    pb.role_id = role_id
    self:WriteMsg(proto.GUILD_AGREE, pb)
end

function FactionController:ResponeAgreeApplyCareer()
    local data = self:ReadMsg("m_guild_agree_toc")
    self.model:SetMemberCareer(data.role_id, data.post)
    self.model:DeatchApplyList(data.role_id)
    self:UpdateRedPoint()
    Chkprint("同意职位申请")
    self.model:Brocast(FactionEvent.AgreeApplyCareer, data.role_id, data.post)
end

--拒绝申请职位
function FactionController:RequestRefuseApplyCareer(role_id)
    local pb = self:GetPbObject("m_guild_refuse_tos")
    pb.role_id = role_id
    self:WriteMsg(proto.GUILD_REFUSE, pb)
end

function FactionController:ResponeRefuseApplyCareer()
    local data = self:ReadMsg("m_guild_refuse_toc")
    Chkprint("拒绝职位申请")
    self.model:DeatchApplyList(data.role_id)
    self:UpdateRedPoint()
    self.model:Brocast(FactionEvent.RefuseApplyCareer, data.role_id)

end




--申请入帮
function FactionController:RequestApplyEnterFaction(guild_id)
    local pb = self:GetPbObject("m_guild_apply_tos")
    pb.guild_id = guild_id
    self:WriteMsg(proto.GUILD_APPLY, pb)
end

function FactionController:ResponeApplyEnterFaction()
    local data = self:ReadMsg("m_guild_apply_toc")
    if data.guild_id == 0 then
        self.model:AddApplyList(data.appliant)
        self:UpdateRedPoint()
    end
    self.model:Brocast(FactionEvent.ApplySucess, data.guild_id)
end

--取消申请入帮
function FactionController:RequestCancleApplyEnterFaction(guild_id)
    local pb = self:GetPbObject("m_guild_cancel_tos")
    pb.guild_id = guild_id
    self:WriteMsg(proto.GUILD_CANCEL, pb)
end

function FactionController:ResponeCancleApplyEnterFaction()
    print("收到取消申请的协议")
    local data = self:ReadMsg("m_guild_cancel_toc")
    if data.guild_id == 0 then
        self.model:DeatchApplyList(data.role_id)
        self:UpdateRedPoint()
    end
    self.model:Brocast(FactionEvent.CancleApplySucess, data.guild_id)
end

function FactionController:RequestModifyNotice(notice, informMem)
    self.model.modifyNotice = notice
    local pb = self:GetPbObject("m_guild_notice_tos")
    pb.notice = notice
    pb.inform = informMem
    self:WriteMsg(proto.GUILD_NOTICE, pb)
end

function FactionController:ResponeModifyNotice()
    local data = self:ReadMsg("m_guild_notice_toc")
    if data.inform then
        self.model.selfFactionInfo.modify = self.model.selfFactionInfo.modify + 1
    end
    self.model.selfFactionInfo.notice = data.notice
    self.model:Brocast(FactionEvent.ModifyNoticeSucess)
end

function FactionController:RequestApplyList()
    --
    local pb = self:GetPbObject("m_guild_appliants_tos")
    self:WriteMsg(proto.GUILD_APPLIANTS, pb)
end

function FactionController:ResponeApplyList()
    local data = self:ReadMsg("m_guild_appliants_toc")
    self.model.applyList = data
    self.model.appliants = data.appliants
    self.model:Brocast(FactionEvent.ApplyList)
    self:UpdateRedPoint()
end

--拒绝入帮申请
function FactionController:RequestRefuseApply(role_id)
    local pb = self:GetPbObject("m_guild_reject_tos")
    pb.role_id = role_id
    self:WriteMsg(proto.GUILD_REJECT, pb)
end

function FactionController:ResponeRefuseApply()
    local data = self:ReadMsg("m_guild_reject_toc")
    self.model:DeatchApplyList(data.role_id)
    self:UpdateRedPoint()
    self.model:Brocast(FactionEvent.RefuseApply, data.role_id, data.guild_id)
end

--同意入帮申请
function FactionController:RequestAcceptApply(role_id)
    print2("同意入帮")
    local pb = self:GetPbObject("m_guild_approve_tos")
    pb.role_id = role_id
    self:WriteMsg(proto.GUILD_APPROVE, pb)
end

function FactionController:ResponeAcceptApply()
    local data = self:ReadMsg("m_guild_approve_toc")
    self.model:AddMember(data.member)
    self.model:DeatchApplyList(data.member.base.id)
    self:UpdateRedPoint()

    local myPost = self.model:SetSelfCadre()
    if myPost == enum.GUILD_POST.GUILD_POST_CHIEF then
        OpenHighController.GetInstance():HandleOpenPanel()
    end
    self.model:Brocast(FactionEvent.AcceptApply, data.member.base.id)
	
	GlobalEvent:Brocast(FactionEvent.ShowMainIcon)
end

--弹骇
function FactionController:RequestImpeach(type)
    local db = self:GetPbObject("m_guild_impeach_tos")
    self:WriteMsg(proto.GUILD_IMPEACH, db)
end

function FactionController:ReponseImpeach()
    local data = self:ReadMsg("m_guild_impeach_toc")
    self.model:Brocast(FactionEvent.GUILD_IMPEACH)
end

function FactionController:RequestWelf(type)
    local pb = self:GetPbObject("m_guild_welfare_tos")
    pb.type = type
    self:WriteMsg(proto.GUILD_WELFARE, pb)
end

function FactionController:ResponeWelf()
    Notify.ShowText(ConfigLanguage.Mix.GetSucess)
    local data = self:ReadMsg("m_guild_welfare_toc")
    self.model:SetReceiveWelfareCount(data.type, 1)
    self.model:Setwelfares(data.type, 1)
    self:UpdateRedPoint()
    --logError(data.type)
    self.model:Brocast(FactionEvent.ReceiveWelfare, data.type)
end

function FactionController:ResponeFactionMessage()
    Chkprint("帮派消息______")
    local data = self:ReadMsg("m_guild_inform_toc")
    if data.msgid == enum.GUILD_MSG.GUILD_MSG_APPLY then

    elseif data.msgid == enum.GUILD_MSG.GUILD_MSG_JOIN then
        self.model:AddMember(data.member)
    end
    self.model:Brocast(FactionEvent.FactionMessage, data)
end

--捐献
function FactionController:RequestDonate(num)
    local pb = self:GetPbObject("m_guild_donate_tos")
    pb.num = num
    self:WriteMsg(proto.GUILD_DONATE, pb)
end

function FactionController:ResponeDonate()
    local data = self:WriteMsg("m_guild_donate_toc")
    self.model:Brocast(FactionEvent.Donate, data.role_id, data.fund)
end

--帮派升级
function FactionController:RequestUpLV()
    local pb = self:GetPbObject("m_guild_upgrade_tos")
    self:WriteMsg(proto.GUILD_UPGRADE, pb)
end

function FactionController:ResponeUpLV()
    local data = self:ReadMsg("m_guild_upgrade_toc")
    self.model.guildLv = data.level
    local myPost = self.model:SetSelfCadre()
    if myPost == enum.GUILD_POST.GUILD_POST_CHIEF then
        OpenHighController.GetInstance():HandleOpenPanel()
    end
    self.model:Brocast(FactionEvent.UpLV, data.level)
end

--请求日志
function FactionController:RequestLog()
    local pb = self:GetPbObject("m_guild_log_tos")
    self:WriteMsg(proto.GUILD_LOG, pb)
end

function FactionController:ResponeLog()
    local data = self:ReadMsg("m_guild_log_toc")
    self.model.logs = data.logs
    for i, v in pairs(data.logs) do
        Chkprint("m_guild_log_toc type, pos ___", v.log, v.post)
    end
    self.model:Brocast(FactionEvent.Logs)
end

function FactionController:ResponeLearnSkill()
    local data = self:ReadMsg("")
    self.model:Brocast(FactionEvent.UpLV)
end

--请求帮派入会设置信息
function FactionController:RequestFactionSetInfo()
    local pb = self:GetPbObject("m_guild_setting_tos")
    self:WriteMsg(proto.GUILD_SETTING, pb)
end

function FactionController:ResponeFactionSetInfo()
    local data = self:ReadMsg("m_guild_setting_toc")
    self.model.factionSetInfo = data
    self.model:Brocast(FactionEvent.FactionSetInfo)
end

function FactionController:RequestFactionSet(auto, level, power)
    local pb = self:GetPbObject("m_guild_setup_tos")
    pb.auto = auto
    pb.level = level
    pb.power = power
    self:WriteMsg(proto.GUILD_SETUP, pb)
end

function FactionController:ResponeFactionSet()
    local data = self:ReadMsg("m_guild_setup_toc")
    self.model.factionSetInfo = data
    self.model:Brocast(FactionEvent.FactionSetSucess)
end

function FactionController:RequestGuildRename(name)
    local pb = self:GetPbObject("m_guild_rename_tos")
    pb.name = name
    self:WriteMsg(proto.GUILD_RENAME, pb)
end

function FactionController:ResponeGuildRename()
    local data = self:ReadMsg("m_guild_rename_toc")
    self.model:Brocast(FactionEvent.FactionRename, data)
end

function FactionController:UpdateRedPoint()
    self.model.redPoints[1] = false  --是否有人申请职位
    self.model.redPoints[2] = false   --技能
    self.model.redPoints[3] = false   --福利
    self.model.redPoints[5] = FPacketModel.GetInstance():IsShowFPRD()
    self.model.redPoints[6] = GuildHouseModel:GetInstance():IsShowRed()
    self.model.redPoints[7] =  FactionSerWarModel:GetInstance():GetSerWarRed()
    --logError(self.model.redPoints[6])
    if FPacketModel.GetInstance():IsShowFPRD() then
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "guild", true)
        return
    end

    if GuildHouseModel:GetInstance():IsShowRed() then
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "guild", true)
        return
    end

    if FactionSerWarModel:GetInstance():GetSerWarRed() then
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "guild", true)
        return
    end

    local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
    if self.money_event_id == nil then
        local function call_back()
            self:UpdateRedPoint()
        end
        self.money_event_id = roleData:BindData(Constant.GoldType.Contrib, call_back)
    end

    if self.model.appliants then
        if #self.model.appliants > 0 and self.model:SetSelfCadre() > enum.GUILD_POST.GUILD_POST_BABY then
            --self.model.isHaveApp = true
            --self.model.redPoints[1] = true
            for i, v in pairs(self.model.appliants) do
                if v.post < self.model:SetSelfCadre() then
                    self.model.redPoints[1] = true
                    break
                end
            end
            --for i = 1, #self.model.appliants do
            --	if self.model.appliants[i].post < self.model:SetSelfCadre()  then
            --		self.model.redPoints[1] = true
            --		break
            --	end
            --end
        end
    end

    local bgValue = RoleInfoModel.GetInstance():GetRoleValue(90010011)
    if roleData.guild ~= "0" then
        if table.nums(self.model.skillCfgList) <= 0 then
            local skillCfg = Config.db_skill
            for i, v in pairs(skillCfg) do
                if v.group == enum.SKILL_GROUP.SKILL_GROUP_GUILD then
                    table.insert(self.model.skillCfgList, v)
                end
            end
        end

        for i, v in pairs(self.model.skillCfgList) do
            local skillCfg = v
            local level = self.model.skillLst[skillCfg.id]
            if level == nil then
                level = 0
            end
            local key = skillCfg.id .. "@" .. level
            local reqTbl = String2Table(Config.db_skill_level[key].reqs)
            --if Config.db_skill_level[key] ~= nil then
            --	local lvCfg = Config.db_skill_level[key]
            --
            --end
            if reqTbl[2] > roleData.level then

            else
                if self.model.skillLst[skillCfg.id] == nil then
                    --有未激活的
                    self.model.redPoints[2] = true
                    break
                else
                    local costTab = String2Table(Config.db_skill_level[key].learn)
                    if costTab[2] <= bgValue then
                        self.model.redPoints[2] = true
                        break
                    end
                end
            end
        end
    end
    if self.model.welfares then
        for i, v in pairs(self.model.welfares) do
            if i ~= 3 then
                if i == 2 then
                    if self.model:SetSelfCadre() == enum.GUILD_POST.GUILD_POST_BABY then
                        if v == 0 then
                            self.model.redPoints[3] = true
                            break
                        end
                    end
                else
                    if v == 0 then
                        self.model.redPoints[3] = true
                        break
                    end
                end
            end
        end
    end

    local isRed = false
    for i, v in pairs(self.model.redPoints) do
        if v == true then
            isRed = true
            break
        end
    end
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "guild", isRed)

    self.model:Brocast(FactionEvent.UpdateRedDot)
end

function FactionController:ClearRedPoint()
    self.model.redPoints[1] = false  --是否有人申请职位
    self.model.redPoints[2] = false
    self.model.redPoints[3] = false
    self.model.redPoints[4] = false
    self.model.redPoints[5] = false
    self.model.redPoints[6] = false
    self.model.redPoints[7] = false
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "guild", false)

    self.model:Brocast(FactionEvent.UpdateRedDot)

end

function FactionController:UpdateFPacketRedDot(isRed)
    self.model.redPoints[5] = isRed
    --logError(isRed)
    if GuildHouseModel:GetInstance():IsShowRed() then
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "guild", true)
        return
    end

    if isRed then
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "guild", true)
    else
        self:UpdateRedPoint()
    end
    self.model:Brocast(FactionEvent.UpdateRedDot)
end

function FactionController:ChangeActivity(isShow, id)
    if id == FactionModel.GUILD_ACTIVITY_ID then
        if isShow then
            local roleLevel = RoleInfoModel:GetInstance():GetMainRoleLevel();
            local config = Config.db_dunge[self.model.GUILD_DUNGE_ID];
            local mainrole_data = RoleInfoModel.GetInstance():GetMainRoleData();
            local activytyConfig = Config.db_activity[self.model.GUILD_ACTIVITY_ID];
            if activytyConfig and activytyConfig.scene ~= SceneManager:GetInstance():GetSceneId() then
                if config then
                    if config.level <= roleLevel then
                        if mainrole_data then
                            if mainrole_data.guild and tostring(mainrole_data.guild) ~= "0" then
                                local okFun = function()
                                    DungeonCtrl:GetInstance():RequestEnterDungeon(enum.SCENE_STYPE.SCENE_STYPE_GUILDGUARD);
                                end
                                Dialog.ShowTwo("Tip", "The guild guard has started, enter?", "Enter", okFun, 10, "Cancel", nil, nil);
                            end
                        end
                    end
                end
            end
        end
    end
    if id == GuildHouseModel:GetInstance().activity_id then
        self.model.redPoints[6] = isShow
        --logError(isShow)
        if FPacketModel.GetInstance():IsShowFPRD() then
            GlobalEvent:Brocast(MainEvent.ChangeRedDot, "guild", true)
            return
        end
        if isShow then
            GlobalEvent:Brocast(MainEvent.ChangeRedDot, "guild", true)
        else
            self:UpdateRedPoint()
        end
    end

    self.model:Brocast(FactionEvent.UpdateRedDot)
end





