---
--- Created by  Administrator
--- DateTime: 2019/6/3 10:03
---

require("game.marry.RequireMarry")
MarryController = MarryController or class("MarryController", BaseController)
local MarryController = MarryController

function MarryController:ctor()
    MarryController.Instance = self
    self.model = MarryModel:GetInstance()
    self.events = {}
    self.cp_dunge_remind_cd = 0
    self:AddEvents()
    self:RegisterAllProtocol()
end

function MarryController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self:StopMySchedule()
end

function MarryController:GetInstance()
    if not MarryController.Instance then
        MarryController.new()
    end
    return MarryController.Instance
end

function MarryController:AddEvents()


    local function call_back()
        lua_panelMgr:GetPanelOrCreate(MarryPanel):Open()
    end
    GlobalEvent:AddListener(MarryEvent.OpenMarryPanel, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(WeddingQingTiePanel):Open()
    end
    GlobalEvent:AddListener(MarryEvent.OpenMarryInvitationPanel, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(MarryMatchingPanel):Open()
    end
    GlobalEvent:AddListener(MarryEvent.OpenMarryMatching, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(MarryPanel):Open(2)
    end
    GlobalEvent:AddListener(MarryEvent.OpenMarryRingPanel, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(MarryPanel):Open(5)
    end
    GlobalEvent:AddListener(MarryEvent.OpenMarryDungeonPanel, call_back)

    local function call_back(isShow, id)
        if id == 10124 and not isShow then
            GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "marrysuo", false, nil, nil, nil, nil)
        end
    end
    GlobalEvent:AddListener(ActivityEvent.ChangeActivity, call_back)


    --  local function call_back()
    --      local level = RoleInfoModel:GetInstance():GetRoleValue("level")
    --      local lv = Config.db_advertise[4].level
    --      local taskID = Config.db_advertise[4].task_id
    --      local closeLV = 75
    --      local isShow = false
    --     -- TaskModel:GetInstance():IsFinishMainTask(config.task)
    --      --logError(TaskModel:GetInstance():IsFinishMainTask(taskID))
    --      if (level >= lv  and level < closeLV) or lv == 0 then
    --          if taskID == 0 or TaskModel:GetInstance():IsFinishMainTask(taskID) or
    --                  (TaskModel:GetInstance():GetTask(taskID) and TaskModel:GetInstance():GetTask(taskID).state == enum.TASK_STATE.TASK_STATE_ACCEPT ) then
    --              isShow = true
    --          end
    --      end
    --
    --      if level > closeLV then
    --          isShow = false
    --      end
    --      self.model.isShowMatchIcon = isShow
    --      GlobalEvent:Brocast(MarryEvent.ShowMarrIcon,isShow)
    --
    --  end
    ----  GlobalEvent:AddListener(TaskEvent.ReqTaskList, call_back)
    --GlobalEvent:AddListener(TaskEvent.GlobalAddTask, call_back)
    --  RoleInfoModel:GetInstance():GetMainRoleData():BindData("level", call_back)
    --  call_back()


    local function call_back(data)
        --错误信息
        local name1 = data[1]
        local name2 = data[2]
        local des = string.format("Player <color=#1BBA16>%s</color> is Considering proposal from <color=#1BBA16>%s</color>,\nplease try again later!\n*You can send PM to <color=#1BBA16>%s</color>Decline it quickly<color=#1BBA16>%s</color>*\n*and can try again 30 mins later*", name1, name2, name1, name2)
        local function btn_func()

        end
        Dialog.ShowOne("Tip", des, "Confirm", btn_func, 5)
    end
    GlobalEvent:AddListener(MarryEvent.MarryErrorInfo, call_back)

    local function call_back(id)
        -- self:UdpateGoods()
        if id == self.model:GetUpRingMat() then
            self.model:UpdateRedPoint()
        end
    end
    GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)

    --GlobalEvent:AddListener(EventName.KeyRelease, handler(self, self.Test))

    ---CP副本
    GlobalEvent:AddListener(CoupleEvent.ContinueCD, handler(self, self.HandleContinueCPDungeonCD))
    GlobalEvent:AddListener(TeamEvent.ReciveRemindFromTeamate, handler(self, self.HandleReciveRemind))
    local function callback(stype, info)
        if stype ~= enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COUPLE then
            return
        end
        CoupleModel.GetInstance().dunge_panel_info = info
        self.model:UpdateRedPoint()
    end
    GlobalEvent:AddListener(DungeonEvent.UpdateDungeonData, callback)
    local function callback(data)
        if data.id == 30103 then
            CoupleModel.GetInstance():SetEnterInfo(data)
            GlobalEvent:Brocast(MarryEvent.UpdateDungeonTarget)
        end
    end
    GlobalEvent:AddListener(DungeonEvent.DUNGEON_EXP_GOLD_INFO, callback)

    local function callback(id)
        CoupleModel.GetInstance().cur_ques_id = id
        lua_panelMgr:GetPanelOrCreate(CoupleAnswerPanel):Open()
    end
    GlobalEvent:AddListener(DungeonEvent.DeliverQuestion, callback)
end

function MarryController:Test(keyCode)
    if keyCode == InputManager.KeyCode.N then
        lua_panelMgr:GetPanelOrCreate(MarryMatchingPanel):Open()
    end
end

function MarryController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    self.pb_module_name = "pb_1133_dating_pb"

    self:RegisterProtocal(proto.DATING_HALL, self.HandleDatingInfo);
    self:RegisterProtocal(proto.DATING_TAG, self.HandleDatingTag);
    self:RegisterProtocal(proto.DATING_FLIRT, self.HandleMakeFriend);
    self:RegisterProtocal(proto.DATING_MATCH, self.HandleMatch);

    -----结婚三步走----
    self:RegisterProtocal(proto.MARRIAGE_STEP, self.HandleMarriageStep);
    self:RegisterProtocal(proto.MARRIAGE_PROPOSAL_PANEL, self.HandleProposalInfo);
    self:RegisterProtocal(proto.MARRIAGE_PROPOSAL, self.HandleProposal);
    self:RegisterProtocal(proto.MARRIAGE_PROPOSAL_REQUEST, self.HandleProposalRequest);
    self:RegisterProtocal(proto.MARRIAGE_PROPOSAL_ACCEPT, self.HandleProposalAccept);
    self:RegisterProtocal(proto.MARRIAGE_PROPOSAL_REFUSE, self.HandleProposalRefuse);
    self:RegisterProtocal(proto.MARRIAGE_PROPOSAL_SUCC, self.HandleProposalSucc);
    self:RegisterProtocal(proto.MARRIAGE_INFO, self.HandleMarriageInfo);

    self:RegisterProtocal(proto.MARRIAGE_RING_INFO, self.HandleRingInfo);
    self:RegisterProtocal(proto.MARRIAGE_RING_UPGRADE, self.HandleRingUpgradeInfo);
    self:RegisterProtocal(proto.MARRIAGE_PROPOSAL_PANEL, self.HandleProposalPanelInfo);
    self:RegisterProtocal(proto.MARRIAGE_DIVORCE, self.HandleDivorce);


    --婚礼
    self:RegisterProtocal(proto.WEDDING_APPOINTMENT_INFO, self.HandleAppointmentInfo);
    self:RegisterProtocal(proto.WEDDING_APPOINTMENT_BOOK, self.HandleAppointmentBook);
    self:RegisterProtocal(proto.WEDDING_GUEST_LIST, self.HandleGuestList);
    self:RegisterProtocal(proto.WEDDING_GUEST_INVITE, self.HandleGuestInvite);
    self:RegisterProtocal(proto.WEDDING_INFO, self.HandleWeddingInfo);
    -- self:RegisterProtocal(proto.WEDDING_INVITATION, self.HandleInvitation);
    --  self:RegisterProtocal(proto.WEDDING_INVITATION_ACCEPT, self.HandleInvitationAccept);
    -- self:RegisterProtocal(proto.WEDDING_INVITATION_REFUSE, self.HandleInvitationRefuse);
    self:RegisterProtocal(proto.WEDDING_NOTICE, self.HandleWeddingNotice);
    self:RegisterProtocal(proto.WEDDING_INVITATION_REQUEST, self.HandleInvitationRequest);
    self:RegisterProtocal(proto.WEDDING_INVITATION_REQUEST_LIST, self.HandleInvitationRequestList);
    self:RegisterProtocal(proto.WEDDING_INVITATION_REQUEST_ACCEPT, self.HandleInvitationRequestAccept);
    self:RegisterProtocal(proto.WEDDING_INVITATION_REQUEST_REFUSE, self.HandleInvitationRequestRefuse);
    self:RegisterProtocal(proto.WEDDING_INVITATION_ADD, self.HandleInvitationAdd);
    --self:RegisterProtocal(proto.WEDDING_START, self.HandleStartAct);
    --self:RegisterProtocal(proto.WEDDING_STOP, self.HandleEndAct);
    self:RegisterProtocal(proto.WEDDING_INVITATION_APPLY, self.HandleInvitationApply);

    --self:RegisterProtocal(proto.WEDDING_PARTY_FIREWORK, self.HandlePartyFirework);
    self:RegisterProtocal(proto.WEDDING_PARTY_INFO, self.HandlePartyInfo);
    self:RegisterProtocal(proto.WEDDING_PARTY_EXP, self.HandlePartyExp);
    self:RegisterProtocal(proto.WEDDING_PARTY_HOT, self.HandlePartyHot);
    self:RegisterProtocal(proto.WEDDING_PARTY_FETCH, self.HandlePartyFetch);
end

-- overwrite
function MarryController:GameStart()
    local function step()
        self:ResusetMarriageStep()
        self:RequsetMarriageInfo()
        self:RequsetProposalRequest()
        local role = RoleInfoModel.GetInstance():GetMainRoleData()
        if role.marry ~= 0 then
            self:RequsetWeddingInfo()
        end
        --self:RequsetAppointmentInfo()
        --self:RequsetInvitation()
        -- self:RequsetWeddingNotice()
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.High)
end

--请求交友大厅
function MarryController:RequsetDatingInfo(page)
    local pb = self:GetPbObject("m_dating_hall_tos")
    pb.page = page
    self:WriteMsg(proto.DATING_HALL, pb)
end

--交友大厅返回
function MarryController:HandleDatingInfo()
    local data = self:ReadMsg("m_dating_hall_toc")
    dump(data)
    self.model.mineInfo = data.mine
    self.model.selectTags = data.mine.tags
    self.model:Brocast(MarryEvent.DatingInfo, data)
end


--请求设置标签
function MarryController:RequsetDatingTag(tags)
    local pb = self:GetPbObject("m_dating_tag_tos")
    for i, v in pairs(tags) do
        pb.tags:append(v)
    end
    self:WriteMsg(proto.DATING_TAG, pb)
end

--设置标签
function MarryController:HandleDatingTag(tags)
    local data = self:ReadMsg("m_dating_tag_toc")
    self.model.selectTags = data.tags
    self.model:Brocast(MarryEvent.MarryTagsInfo, data)
    dump(data)
end

function MarryController:RequsetMakeFriend(role_id)
    local pb = self:GetPbObject("m_dating_flirt_tos")
    pb.role_id = role_id
    self:WriteMsg(proto.DATING_FLIRT, pb)
end

--返回交友
function MarryController:HandleMakeFriend()
    Notify.ShowText("Friend request accepted")
    local data = self:ReadMsg("m_dating_flirt_toc")
end





--匹配
function MarryController:RequsetMatch()
    local pb = self:GetPbObject("m_dating_match_tos")
    self:WriteMsg(proto.DATING_MATCH, pb)
end
--返回匹配
function MarryController:HandleMatch()
    local data = self:ReadMsg("m_dating_match_toc")
    self.model:Brocast(MarryEvent.MarryMatch, data)
end


--------------------------------结婚三步走-----------------

function MarryController:ResusetMarriageStep()
    local pb = self:GetPbObject("m_marriage_step_tos", "pb_1134_marriage_pb")
    self:WriteMsg(proto.MARRIAGE_STEP, pb)
end

--返回三步走信息
function MarryController:HandleMarriageStep()
    local data = self:ReadMsg("m_marriage_step_toc", "pb_1134_marriage_pb")
    self.model.marriageStep = data.steps
    self.model:UpdateRedPoint()
    self.model:Brocast(MarryEvent.MarryMarriageInfo, data)
end

--领取三步走奖励  成功则返回HandleMarriageStep
function MarryController:RequsetMarriageStepReward(id)
    local pb = self:GetPbObject("m_marriage_step_reward_tos", "pb_1134_marriage_pb")
    pb.id = id
    self:WriteMsg(proto.MARRIAGE_STEP_REWARD, pb)
end


--求婚面板
function MarryController:RequsetProposalPanelInfo(target)
    local pb = self:GetPbObject("m_marriage_proposal_panel_tos", "pb_1134_marriage_pb")
    pb.target = target
    self:WriteMsg(proto.MARRIAGE_PROPOSAL_PANEL, pb)
end

function MarryController:HandleProposalPanelInfo()
    local data = self:ReadMsg("m_marriage_proposal_panel_toc", "pb_1134_marriage_pb")
    self.model:Brocast(MarryEvent.MarriagePanelInfo, data)
end

--求婚
function MarryController:RequsetProposalInfo(target, type, is_aa)
    local pb = self:GetPbObject("m_marriage_proposal_tos", "pb_1134_marriage_pb")
    pb.target = target
    pb.type = type
    pb.is_aa = is_aa
    self:WriteMsg(proto.MARRIAGE_PROPOSAL, pb)
end

function MarryController:HandleProposal()
    --print2("返回求婚")
    Notify.ShowText("Successful proposal! Waiting for acceptance")
    local panel = lua_panelMgr:GetPanel(MarryPropPanel)
    if panel then
        panel:Close()
    end

end

--当前求婚请求
function MarryController:RequsetProposalRequest()
    -- logError("当前求婚请求")
    local pb = self:GetPbObject("m_marriage_proposal_request_tos", "pb_1134_marriage_pb")
    self:WriteMsg(proto.MARRIAGE_PROPOSAL_REQUEST, pb)
end

function MarryController:HandleProposalRequest()
    -- logError("返回求婚请求")
    local data = self:ReadMsg("m_marriage_proposal_request_toc", "pb_1134_marriage_pb")
    self.model.proposalInfo = data
    local endTime = data.endtime
    local timeTab = TimeManager:GetLastTimeData(TimeManager.Instance:GetServerTime(), endTime)
    if timeTab then
        local function call_back()
            lua_panelMgr:GetPanelOrCreate(MarryRequsetPanel):Open(MarryModel:GetInstance().proposalInfo)
        end
        GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "marry", true, call_back, nil, endTime - os.time(), nil)
    end
    --self:FlashButton(self.icon_tip_marry)
    --SetVisible(self.icon_tip_marry,true)
    GlobalEvent:Brocast(MarryEvent.ProposalRequest, data)
    lua_panelMgr:GetPanelOrCreate(MarryRequsetPanel):Open(data)

end



--同意结婚
function MarryController:RequsetProposalAccept(target)
    local pb = self:GetPbObject("m_marriage_proposal_accept_tos", "pb_1134_marriage_pb")
    pb.target = target
    self:WriteMsg(proto.MARRIAGE_PROPOSAL_ACCEPT, pb)
end

function MarryController:HandleProposalAccept()
    GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "marry", false)
    self.model:Brocast(MarryEvent.ProposalAccept)
    -- GlobalEvent:Brocast(MarryEvent.ProposalAccept)
end


--拒绝结婚
function MarryController:RequsetProposalRefuse(target)
    local pb = self:GetPbObject("m_marriage_proposal_refuse_tos", "pb_1134_marriage_pb")
    pb.target = target
    self:WriteMsg(proto.MARRIAGE_PROPOSAL_REFUSE, pb)
end

function MarryController:HandleProposalRefuse()
    self.model:Brocast(MarryEvent.ProposalRefuse)
    --GlobalEvent:Brocast(MarryEvent.ProposalRefuse)
    GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "marry", false)

end


--求婚成功 双方都推送
function MarryController:HandleProposalSucc()
    local data = self:ReadMsg("m_marriage_proposal_succ_toc", "pb_1134_marriage_pb")
    --   GlobalEvent:Brocast(MarryEvent.MarrySuc)
    local role = RoleInfoModel:GetInstance():GetMainRoleData()
    self.model.has_marry = true
    if data.proposer.id ~= role.id then
        self.model.withMarry = data.proposer
    end
    if data.accepter.id ~= role.id then
        self.model.withMarry = data.accepter
    end
    self.model.appointmentTimes = data.wedding_times

    local TopTransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.Top)
    UIEffect(TopTransform, 30003)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(WeddingAppointmentPanel):Open()
    end
    GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "marryyu", self.model.appointmentTimes > 0, call_back, nil, nil, nil)
    lua_panelMgr:GetPanelOrCreate(MarrySucPanel):Open(data)
end


--请求结婚信息
function MarryController:RequsetMarriageInfo()
    local pb = self:GetPbObject("m_marriage_info_tos", "pb_1134_marriage_pb")
    self:WriteMsg(proto.MARRIAGE_INFO, pb)
end

function MarryController:HandleMarriageInfo()
    local data = self:ReadMsg("m_marriage_info_toc", "pb_1134_marriage_pb")
    if data.marry_with then
        self.model.withMarry = data.marry_with
    end
    self.model.appointmentTimes = data.wedding_times
    self.model.has_marry = data.has_marry
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(WeddingAppointmentPanel):Open()
    end
    GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "marryyu", self.model.appointmentTimes > 0, call_back, nil, nil, nil)

    self.model:Brocast(MarryEvent.MarriageInfo, data)
end


--戒指信息
function MarryController:RequsetRingInfo()
    local pb = self:GetPbObject("m_marriage_ring_info_tos", "pb_1134_marriage_pb")
    self:WriteMsg(proto.MARRIAGE_RING_INFO, pb)
end

function MarryController:HandleRingInfo()
    local data = self:ReadMsg("m_marriage_ring_info_toc", "pb_1134_marriage_pb")

    self.model:Brocast(MarryEvent.RingInfo, data)
end

function MarryController:RequsetRingUpgradeInfo()
    local pb = self:GetPbObject("m_marriage_ring_upgrade_tos", "pb_1134_marriage_pb")
    self:WriteMsg(proto.MARRIAGE_RING_UPGRADE, pb)
end

function MarryController:HandleRingUpgradeInfo()
    local data = self:ReadMsg("m_marriage_ring_upgrade_toc", "pb_1134_marriage_pb")

    self.model:Brocast(MarryEvent.RingUpgradeInfo, data)
end

function MarryController:RequsetDivorce()
    local pb = self:GetPbObject("m_marriage_divorce_tos", "pb_1134_marriage_pb")
    self:WriteMsg(proto.MARRIAGE_DIVORCE, pb)
end


--离婚
function MarryController:HandleDivorce()
    -- local data = self:ReadMsg("m_marriage_divorce_toc","pb_1134_marriage_pb")
    print2("离婚成功")
    self.model.appointmentTimes = 0
    local panel = lua_panelMgr:GetPanel(MarryPanel)
    if panel then
        panel:Close()
    end
    self.model:Brocast(MarryEvent.DivorceSuscc)
end


------------------------------end-----------------------



------------------------------婚礼相关-----------------------

--预约面板
function MarryController:RequsetAppointmentInfo()
    local pb = self:GetPbObject("m_wedding_appointment_info_tos", "pb_1135_wedding_pb")
    self:WriteMsg(proto.WEDDING_APPOINTMENT_INFO, pb)
end

function MarryController:HandleAppointmentInfo()
    local data = self:ReadMsg("m_wedding_appointment_info_toc", "pb_1135_wedding_pb")
    print2("预约数据")
    dump(data)
    self.model.appointmentInfos = data.appointments
    --self.model:GetAppointmentList(data)
    self.model:Brocast(MarryEvent.AppointmentInfo, data)
end

--预约
function MarryController:RequsetAppointmentBook(start_time, end_time)
    local pb = self:GetPbObject("m_wedding_appointment_book_tos", "pb_1135_wedding_pb")
    pb.start_time = start_time
    pb.end_time = end_time
    self:WriteMsg(proto.WEDDING_APPOINTMENT_BOOK, pb)
end

function MarryController:HandleAppointmentBook()
    local data = self:ReadMsg("m_wedding_appointment_book_toc", "pb_1135_wedding_pb")
    Notify.ShowText("Wedding reserved")
    self.model.appointmentTimes = self.model.appointmentTimes - 1
    self.model.isAppointment = true
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(WeddingAppointmentPanel):Open()
    end
    GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "marryyu", self.model.appointmentTimes > 0, call_back, nil, nil, nil)
    self.model:Brocast(MarryEvent.AppointmentBook, data)
end

--已邀请宾客列表
function MarryController:RequsetGuestList()
    local pb = self:GetPbObject("m_wedding_guest_list_tos", "pb_1135_wedding_pb")
    self:WriteMsg(proto.WEDDING_GUEST_LIST, pb)
end

function MarryController:HandleGuestList()
    local data = self:ReadMsg("m_wedding_guest_list_toc", "pb_1135_wedding_pb")
    self.model.guestList = data.guests
    self.model:Brocast(MarryEvent.GuestList, data)
end


--邀请宾客
function MarryController:RequsetGuestInvite(id)
    local pb = self:GetPbObject("m_wedding_guest_invite_tos", "pb_1135_wedding_pb")
    pb.id = id
    self:WriteMsg(proto.WEDDING_GUEST_INVITE, pb)
end

function MarryController:HandleGuestInvite()
    local data = self:ReadMsg("m_wedding_guest_invite_toc", "pb_1135_wedding_pb")
    table.insert(self.model.guestList, data.guest)
    self.model:Brocast(MarryEvent.GuestInvite, data)
end

----请柬*（上线时请求）
--function MarryController:RequsetInvitation()
--    print2("请帖1.0")
--    local pb = self:GetPbObject("m_wedding_invitation_tos","pb_1135_wedding_pb")
--    self:WriteMsg(proto.WEDDING_INVITATION,pb)
--end
----在线时后端会主动推送
--function MarryController:HandleInvitation()
--    print2("返回请帖1.0")
--    local data = self:ReadMsg("m_wedding_invitation_toc","pb_1135_wedding_pb")
--    self.model:Brocast(MarryEvent.Invitation,data)
--end

----同意
--function MarryController:RequsetInvitationAccept(start_time,end_time)
--    local pb = self:GetPbObject("m_wedding_invitation_accept_tos","pb_1135_wedding_pb")
--    pb.start_time = start_time
--    pb.end_time = end_time
--    self:WriteMsg(proto.WEDDING_INVITATION_ACCEPT,pb)
--end
--
--function MarryController:HandleInvitationAccept()
--    local data = self:ReadMsg("m_wedding_invitation_accept_toc","pb_1135_wedding_pb")
--   -- self.model:Brocast(MarryEvent.Invitation,data)
--end
--
----拒绝
--function MarryController:RequsetInvitationRefuse()
--    local pb = self:GetPbObject("m_wedding_invitation_refuse_tos","pb_1135_wedding_pb")
--    self:WriteMsg(proto.WEDDING_INVITATION_REFUSE,pb)
--end
--
--function MarryController:HandleInvitationRefuse()
--    local data = self:ReadMsg("m_wedding_invitation_refuse_toc","pb_1135_wedding_pb")
--    -- self.model:Brocast(MarryEvent.Invitation,data)
--end

--查询当前要举行的婚礼(上线时查询)
function MarryController:RequsetWeddingNotice()
    local pb = self:GetPbObject("m_wedding_notice_tos", "pb_1135_wedding_pb")
    self:WriteMsg(proto.WEDDING_NOTICE, pb)
end

function MarryController:HandleWeddingNotice()
    --logError("当前要举行的婚礼信息")
    local data = self:ReadMsg("m_wedding_notice_toc", "pb_1135_wedding_pb")
    dump(data)
    self.model.weddingInfo = data.wedding
    --  local curTime = TimeManager.GetInstance():GetServerTime()
    --local time = data.wedding.start_time
    --if curTime > time then
    --    time = data.wedding.end_time
    --end
    --GlobalEvent:Brocast(MainEvent.ChangeRightIcon,"marryInvitation",true,nil,time,data.wedding.end_time)
    self.model:Brocast(MarryEvent.WeddingNotice, data)
end

--索要邀请
function MarryController:RequsetInvitationRequest(start_time, end_time)
    local pb = self:GetPbObject("m_wedding_invitation_request_tos", "pb_1135_wedding_pb")
    pb.start_time = start_time
    pb.end_time = end_time
    self:WriteMsg(proto.WEDDING_INVITATION_REQUEST, pb)
end

function MarryController:HandleInvitationRequest()
    local data = self:ReadMsg("m_wedding_invitation_request_toc", "pb_1135_wedding_pb")
    self.model:Brocast(MarryEvent.InvitationRequest, data)
end

--宾客索要管理
function MarryController:RequsetInvitationRequestList()
    local pb = self:GetPbObject("m_wedding_invitation_request_list_tos", "pb_1135_wedding_pb")
    self:WriteMsg(proto.WEDDING_INVITATION_REQUEST_LIST, pb)
end

function MarryController:HandleInvitationRequestList()
    local data = self:ReadMsg("m_wedding_invitation_request_list_toc", "pb_1135_wedding_pb")
    self.model.guestSouList = data.guests
    self.model:Brocast(MarryEvent.InvitationRequestList, data)
end


--同意索要
function MarryController:RequsetInvitationRequestAccept(ids)
    local pb = self:GetPbObject("m_wedding_invitation_request_accept_tos", "pb_1135_wedding_pb")
    for i, v in pairs(ids) do
        pb.ids:append(v)
    end
    self:WriteMsg(proto.WEDDING_INVITATION_REQUEST_ACCEPT, pb)
end

function MarryController:HandleInvitationRequestAccept()
    local data = self:ReadMsg("m_wedding_invitation_request_accept_toc", "pb_1135_wedding_pb")
    local ids = data.ids
    for i, v in pairs(ids) do
        self.model:RemoveGuestSouList(v)
    end
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(WeddingGuestPanel):Open()
    end
    GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "marrysuo", table.nums(self.model.guestSouList) > 0, call_back, nil, nil, nil)
    self.model:Brocast(MarryEvent.InvitationRequestAccept, data)
end

--拒绝索要
function MarryController:RequsetInvitationRequestRefuse(id)
    local pb = self:GetPbObject("m_wedding_invitation_request_refuse_tos", "pb_1135_wedding_pb")
    pb.id = id
    self:WriteMsg(proto.WEDDING_INVITATION_REQUEST_REFUSE, pb)
end

function MarryController:HandleInvitationRequestRefuse()
    local data = self:ReadMsg("m_wedding_invitation_request_refuse_toc", "pb_1135_wedding_pb")
    local id = data.id
    self.model:RemoveGuestSouList(id)
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(WeddingGuestPanel):Open()
    end
    GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "marrysuo", table.nums(self.model.guestSouList) > 0, call_back, nil, nil, nil)
    self.model:Brocast(MarryEvent.InvitationRequestRefuse, data)
end

--增加请柬
function MarryController:RequsetInvitationAdd()
    local pb = self:GetPbObject("m_wedding_invitation_add_tos", "pb_1135_wedding_pb")
    self:WriteMsg(proto.WEDDING_INVITATION_ADD, pb)
end

function MarryController:HandleInvitationAdd()
    local data = self:ReadMsg("m_wedding_invitation_add_toc", "pb_1135_wedding_pb")
    self.model:Brocast(MarryEvent.InvitationAdd, data)
end



----活动开始
--function MarryController:HandleStartAct()
--    print2("活动开始了！！！")
--  --  local data = self:ReadMsg("m_wedding_start_toc","pb_1135_wedding_pb")
--   -- self.model:Brocast(MarryEvent.InvitationAdd,data)
--    GlobalEvent:Brocast(MainEvent.ChangeRightIcon,"marryInvitation",true,nil,self.model.weddingInfo.end_time)
--end
----活动结束
--function MarryController:HandleEndAct()
--    print2("活动结束了！！！")
--    GlobalEvent:Brocast(MainEvent.ChangeRightIcon,"marryInvitation",false)
--    --local data = self:ReadMsg("m_wedding_stop_toc","pb_1135_wedding_pb")
--
--end



--function MarryController:RequsetPartyFirework(item_id)
--    local pb = self:GetPbObject("m_wedding_party_firework_tos","pb_1135_wedding_pb")
--    pb.item_id = item_id
--    self:WriteMsg(proto.WEDDING_PARTY_FIREWORK,pb)
--end
----使用烟花
--function MarryController:HandlePartyFirework()
--    local data = self:ReadMsg("m_wedding_party_firework_toc","pb_1135_wedding_pb")
--    self.model:Brocast(MarryEvent.PartyFirework,data)
--end


function MarryController:RequsetPartyInfo()

    local pb = self:GetPbObject("m_wedding_party_info_tos", "pb_1135_wedding_pb")
    self:WriteMsg(proto.WEDDING_PARTY_INFO, pb)
end
--场景数据
function MarryController:HandlePartyInfo()
    local data = self:ReadMsg("m_wedding_party_info_toc", "pb_1135_wedding_pb")
    self.model.hotReward = data.fetch
    self.model.curHot = data.hot
    self.model:Brocast(MarryEvent.PartyInfo, data)
end

function MarryController:RequsetPartyExp()
    local pb = self:GetPbObject("m_wedding_party_exp_tos", "pb_1135_wedding_pb")
    self:WriteMsg(proto.WEDDING_PARTY_EXP, pb)
end
--定时请求经验
function MarryController:HandlePartyExp()
    local data = self:ReadMsg("m_wedding_party_exp_toc", "pb_1135_wedding_pb")
    self.model:Brocast(MarryEvent.PartyExp, data)
end

--推送热度更新
function MarryController:HandlePartyHot()
    local data = self:ReadMsg("m_wedding_party_hot_toc", "pb_1135_wedding_pb")
    self.model.curHot = data.hot
    self.model:Brocast(MarryEvent.PartyHot, data)
end

function MarryController:RequsetPartyFetch(hot)
    local pb = self:GetPbObject("m_wedding_party_fetch_tos", "pb_1135_wedding_pb")
    pb.hot = hot
    self:WriteMsg(proto.WEDDING_PARTY_FETCH, pb)
end

--领取热度奖励
function MarryController:HandlePartyFetch()
    local data = self:ReadMsg("m_wedding_party_fetch_toc", "pb_1135_wedding_pb")
    self.model.hotReward = data.fetch
    self.model:Brocast(MarryEvent.PartyFetch, data)
end

function MarryController:RequsetWeddingInfo()
    local pb = self:GetPbObject("m_wedding_info_tos", "pb_1135_wedding_pb")
    self:WriteMsg(proto.WEDDING_INFO, pb)
end
--预约信息
function MarryController:HandleWeddingInfo()
    --logError("---d返回预约信息")
    local data = self:ReadMsg("m_wedding_info_toc", "pb_1135_wedding_pb")
    if data.appointment then
        table.insert(self.model.appointmentInfos, data.appointment)
    end
    self.model.has_request = data.has_request
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(WeddingGuestPanel):Open()
    end
    GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "marrysuo", self.model.has_request, call_back, nil, nil, nil)

    -- self.model.appointmentInfos =  data.appointment
    -- dump(data)
    -- self.model:Brocast(MarryEvent.PartyFetch,data)
end


--推送玩家索要邀请
function MarryController:HandleInvitationApply()
    local data = self:ReadMsg("m_wedding_invitation_apply_toc", "pb_1135_wedding_pb")
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(WeddingGuestPanel):Open()
    end
    GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "marrysuo", true, call_back, nil, nil, nil)
    GlobalEvent:Brocast(MarryEvent.InvitationApply, data)
end


------------------------------end-----------------------

-------------------------红点-------------------------

--function MarryController:UpdateThreePoint()
--   -- self.model.redPoints
--    self.model.redPoints[1] = false
--
--end

------------------------结婚副本-------------------
function MarryController:HandleContinueCPDungeonCD()
    self.cp_dunge_remind_cd = CoupleModel.GetInstance().remind_cd
    if self.cp_dunge_remind_cd > 0 then
        self:StopMySchedule()
        self.schedule = GlobalSchedule.StartFun(handler(self, self.BeginningCD), 0.1, -1)
    end
end

function MarryController:StopMySchedule()
    if self.schedule then
        GlobalSchedule:Stop(self.schedule)
        self.schedule = nil
    end
end

function MarryController:BeginningCD()
    if self.cp_dunge_remind_cd > 0 then
        self.cp_dunge_remind_cd = self.cp_dunge_remind_cd - 1
    else
        self:StopMySchedule()
        CoupleModel.GetInstance().is_remind_cd = false
    end
end

function MarryController:HandleReciveRemind(stype, ask_name)
    if stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COUPLE then
        local dunge_id = 30103
        local dunge_cf = Config.db_dunge[dunge_id]
        local cost_tbl = String2Table(dunge_cf.enter_buy)
        local cost_name = FreeGiftModel.GetInstance():GetMoneyTypeNameByItemId(cost_tbl[1])
        local str = string.format(ConfigLanguage.CoupleDungeon.RemindBuyDialog, ask_name, cost_tbl[2], cost_name)
        local function ok_func()
            local role_data = RoleInfoModel.GetInstance():GetMainRoleData()
            if role_data.marry == 0 then
                Notify.ShowText(ConfigLanguage.CoupleDungeon.PleaseBuyAfterMarry)
                return
            end
            if not dunge_cf then
                logError("MarryController:Dunge配置中没有该副本配置")
                return
            end
            local cost_tbl = cost_tbl
            if RoleInfoModel.GetInstance():CheckGold(cost_tbl[2], cost_tbl[1]) then
                DungeonCtrl.GetInstance():RequestBuyTimes(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COUPLE)
            end
        end
        Dialog.ShowTwo("Tip", str, "Buy", ok_func, nil, "Cancel", nil, nil, nil, nil)

    end
end