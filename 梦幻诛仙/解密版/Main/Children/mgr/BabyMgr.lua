local Lplus = require("Lplus")
local BabyMgr = Lplus.Class("BabyMgr")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local NPCInterface = require("Main.npc.NPCInterface")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = BabyMgr.define
def.field("userdata").operateSessionId = nil
def.field("number").babyTimerId = 0
local instance
def.static("=>", BabyMgr).Instance = function()
  if instance == nil then
    instance = BabyMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SSyncBreedInfo", BabyMgr.OnSSyncBreedInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SGiveUpBreedSuccess", BabyMgr.OnSGiveUpBreedSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SSelectPregnantBelong", BabyMgr.OnSSelectPregnantBelong)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SAgreeOrRefusePregnantBelong", BabyMgr.OnSAgreeOrRefusePregnantBelong)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.STransmitAttendPreparePregnancyInvite", BabyMgr.OnSTransmitAttendPreparePregnancyInvite)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SAnswerAttendPreparePregnancyInviteSuccess", BabyMgr.OnSAnswerAttendPreparePregnancyInviteSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SStartBreedBabyChildSuccess", BabyMgr.OnSStartBreedBabyChildSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SBreedBabyChildEnd", BabyMgr.OnSBreedBabyChildEnd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SWakeUpBabyChild", BabyMgr.OnSWakeUpBabyChild)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SBabyToChildHoodSuccess", BabyMgr.OnSBabyToChildHoodSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SChildAbortionNotify", BabyMgr.OnSChildAbortionNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SAttendFetusEducationMusicFail", BabyMgr.OnSAttendFetusEducationMusicFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SAttendPreparePregnancyFail", BabyMgr.OnSAttendPreparePregnancyFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SAnswerAttendPreparePregnancyInviteFail", BabyMgr.OnSAnswerAttendPreparePregnancyInviteFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SPregnantCutVigorFail", BabyMgr.OnSPregnantCutVigorFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SAutoBreedBabyRes", BabyMgr.OnSAutoBreedBabyRes)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.CHOOSE_CHILD_BELONG_CONFIRM, BabyMgr.OnChooseChildBelongConfirm)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Get_Baby, BabyMgr.OnGetBaby)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, BabyMgr.OnAcceptNPCService)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, BabyMgr.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, BabyMgr.OnLeaveWorld)
  local npcInterface = NPCInterface.Instance()
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.BreedChild, BabyMgr.OnNPCService_BreedChild)
end
def.method().Reset = function(self)
  self.operateSessionId = nil
  self.babyTimerId = 0
  require("Main.Children.data.GetBabyPhaseData").Instance():ClearData()
end
def.static("table").OnSSyncBreedInfo = function(p)
  local BreedStepEnum = require("consts.mzm.gsp.children.confbean.BreedStepEnum")
  local phaseData = require("Main.Children.data.GetBabyPhaseData").Instance()
  local preStep = phaseData:GetCurrentBreedStep()
  phaseData:RawSet(p)
  local curStep = phaseData:GetCurrentBreedStep()
  if preStep == BreedStepEnum.PREGNANT and curStep == BreedStepEnum.FETUS_EDUCATION then
    instance:PlayPregnantEffect()
  end
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.GET_BABY_PHASE_CHANGED, nil)
end
def.static("table").OnSGiveUpBreedSuccess = function(p)
  Toast(textRes.Children[1004])
end
def.static("table").OnSSelectPregnantBelong = function(p)
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  if heroProp == nil then
    warn("hero prop not exist")
    return
  end
  instance.operateSessionId = p.session_id
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.CHOOSE_CHILD_BELONG_CONFIRM, {
    p.belong_role_id
  })
end
def.static("table").OnSAgreeOrRefusePregnantBelong = function(p)
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.CHOOSE_CHILD_BELONG_RESULT, nil)
  local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
  if mateInfo == nil then
    return
  end
  local teamData = require("Main.Team.TeamData").Instance()
  local mateData = teamData:getMember(mateInfo.mateId)
  if mateData == nil then
    return
  end
  if p.operator == 1 then
    Toast(string.format(textRes.Children[1018], mateData.name))
  else
    Toast(string.format(textRes.Children[1019], mateData.name))
  end
end
def.static("table").OnSTransmitAttendPreparePregnancyInvite = function(p)
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  if heroProp == nil then
    warn("hero prop not exist")
    return
  end
  if heroProp.id == p.inviterid then
    instance:WaitPreparePregancy()
  else
    instance.operateSessionId = p.sessionid
    instance:ConfirmPreparePregancy(p.inviterid)
  end
end
def.static("table").OnSAnswerAttendPreparePregnancyInviteSuccess = function(p)
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  if heroProp == nil then
    warn("hero prop not exist")
    return
  end
  local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
  if mateInfo == nil then
    return
  end
  local teamData = require("Main.Team.TeamData").Instance()
  local mateData = teamData:getMember(mateInfo.mateId)
  if mateData == nil then
    return
  end
  if heroProp.id == p.inviterid then
    instance:StopWaitPreparePregancy()
    local SAnswerAttendPreparePregnancyInviteSuccess = require("netio.protocol.mzm.gsp.children.SAnswerAttendPreparePregnancyInviteSuccess")
    if p.answer == SAnswerAttendPreparePregnancyInviteSuccess.REFUSE then
      Toast(string.format(textRes.Children[1034], mateData.name))
    end
  end
end
def.static("table").OnSStartBreedBabyChildSuccess = function(p)
  local child = ChildrenDataMgr.Instance():GetChildById(p.child_id)
  if child == nil then
    return
  end
  child:SetRemainOperater(p.operator)
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.BREED_OPERATE_SUCCESS, nil)
  local BabyOperatorEnum = require("consts.mzm.gsp.children.confbean.BabyOperatorEnum")
  if p.operator ~= BabyOperatorEnum.SLEEP then
    require("Main.Children.ui.BabyBreedProgressPanel").Instance():ShowPanel(p.operator, Int64.ToNumber(child:GetRemainOperatorSeconds()))
  else
    Toast(textRes.Children[1031])
  end
end
def.static("table").OnSBreedBabyChildEnd = function(p)
  local child = ChildrenDataMgr.Instance():GetChildById(p.child_id)
  if child == nil then
    return
  end
  child:RemoveRemainOperator()
  child:SetBabyProperty(p.now_baby_property)
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.BREED_OPERATE_END, nil)
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.BABY_DATA_CHANGE, {
    p.child_id
  })
  local BabyOperatorEnum = require("consts.mzm.gsp.children.confbean.BabyOperatorEnum")
  if p.operator ~= BabyOperatorEnum.SLEEP then
    require("Main.Children.ui.BabyBreedProgressPanel").Instance():HideProgress()
  else
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.BABY_SLEEP_END, {
      p.child_id
    })
    Toast(textRes.Children[1032])
  end
end
def.static("table").OnSWakeUpBabyChild = function(p)
  local child = ChildrenDataMgr.Instance():GetChildById(p.child_id)
  if child == nil then
    return
  end
  child:SetTireProperty(p.now_tired_value)
  child:RemoveRemainOperator()
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.BABY_DATA_CHANGE, {
    p.child_id
  })
  Toast(string.format(textRes.Children[1033], child:GetTiredProperty()))
end
def.static("table").OnSBabyToChildHoodSuccess = function(p)
  local child = ChildrenDataMgr.Instance():GetChildById(p.child_id)
  if child == nil then
    return
  end
  local childName = child:GetName()
  Toast(string.format(textRes.Children[1036], childName))
  ChildrenDataMgr.Instance():AddChild(p.child_id, p.child_bean)
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Baby_Teen, {
    p.child_id
  })
  instance:PlayBabyToChildEffect()
end
def.static("table").OnSChildAbortionNotify = function(p)
  instance:NotifyChildAbortion()
end
def.static("table").OnSAttendFetusEducationMusicFail = function(p)
  if textRes.Children.SAttendFetusEducationMusicFail[p.res] then
    Toast(textRes.Children.SAttendFetusEducationMusicFail[p.res])
  else
    Toast(textRes.Children[1022])
  end
end
def.static("table").OnSAttendPreparePregnancyFail = function(p)
  if textRes.Children.SAttendPreparePregnancyFail[p.res] then
    Toast(textRes.Children.SAttendPreparePregnancyFail[p.res])
  else
    Toast(textRes.Children[1022])
  end
end
def.static("table").OnSAnswerAttendPreparePregnancyInviteFail = function(p)
  if textRes.Children.SAnswerAttendPreparePregnancyInviteFail[p.res] then
    Toast(textRes.Children.SAnswerAttendPreparePregnancyInviteFail[p.res])
  else
    Toast(textRes.Children[1022])
  end
end
def.static("table").OnSPregnantCutVigorFail = function(p)
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  if heroProp == nil then
    warn("hero prop not exist")
    return
  end
  if heroProp.id == p.role_id then
    Toast(string.format(textRes.Children[1015], textRes.Children[1016], constant.CChildrenConsts.pregnant_cut_vigor_score))
  else
    local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
    if mateInfo == nil then
      return
    end
    local teamData = require("Main.Team.TeamData").Instance()
    local mateData = teamData:getMember(mateInfo.mateId)
    if mateData == nil then
      return
    end
    if mateInfo.mateId == p.role_id then
      Toast(string.format(textRes.Children[1015], mateData.name, constant.CChildrenConsts.pregnant_cut_vigor_score))
    end
  end
end
def.static("number", "=>", "boolean").OnNPCService_BreedChild = function(serviceId)
  if serviceId == NPCServiceConst.BreedChild then
    local isOpen = require("Main.Children.ChildrenInterface").IsFunctionOpen()
    if not isOpen then
      return false
    elseif not gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):IsInSelfHomeland() then
      return false
    else
      return true
    end
  else
    return true
  end
end
def.static("table", "table").OnAcceptNPCService = function(params)
  local serviceID = params[1]
  local npcID = params[2]
  if serviceID == NPCServiceConst.BreedChild then
    instance:ShowGetBabyService()
  end
end
def.static("table", "table").OnChooseChildBelongConfirm = function(params, context)
  local belongId = params and params[1] or nil
  if belongId == nil then
    return
  end
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:HasTeam() ~= true or teamData:GetMemberCount() ~= 2 then
    return
  end
  if teamData:MeIsCaptain() then
    instance:WaitChooseChildBelong()
  else
    instance:ConfirmChooseChildBelong(belongId)
  end
end
def.static("table", "table").OnGetBaby = function(params, context)
  instance:PlayGetBabyEffect()
end
def.static("table", "table").OnEnterWorld = function(params, context)
  instance:StartBabyTimer()
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  instance:StopBabyTimer()
  instance:Reset()
end
def.method().ShowGetBabyService = function(self)
  if not require("Main.Children.ChildrenInterface").CheckFunctionOpenAndToast() then
    return
  end
  require("Main.Children.ui.GetBabyPanel").Instance():ShowPanel()
end
def.method("=>", "boolean").CheckCoupleStateAndToast = function(self)
  if not self:CanDoCoupleActivity() then
    Toast(textRes.Children[1000])
    return false
  end
  if self:IsCoupleFullChildren() then
    Toast(textRes.Children[1010])
    return false
  end
  return true
end
def.method("=>", "boolean").CanDoCoupleActivity = function(self)
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:HasTeam() ~= true or teamData:GetMemberCount() ~= 2 then
    return false
  end
  local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
  if mateInfo == nil then
    return false
  end
  if teamData:HasLeavingMember() or not teamData:IsTeamMember(mateInfo.mateId) then
    return false
  end
  return true
end
def.method("=>", "boolean").IsCoupleFullChildren = function(self)
  local childrenDataMgr = ChildrenDataMgr.Instance()
  local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
  if mateInfo == nil then
    return false
  end
  if childrenDataMgr:GetChildrenCountByRoleId(mateInfo.mateId) < constant.CChildrenConsts.max_children_can_carrey then
    return false
  end
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  if childrenDataMgr:GetChildrenCountByRoleId(heroProp.id) < constant.CChildrenConsts.max_children_can_carrey then
    return false
  end
  return true
end
def.method("=>", "boolean").IsSingleFullChildren = function(self)
  local childrenDataMgr = ChildrenDataMgr.Instance()
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  if childrenDataMgr:GetChildrenCountByRoleId(heroProp.id) < constant.CChildrenConsts.max_children_can_carrey then
    return false
  end
  return true
end
def.method("=>", "boolean").CheckCoupleLevelAndToast = function(self)
  if not self:CanDoCoupleActivity() then
    return false
  end
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  if heroProp.level < constant.CChildrenConsts.children_function_open_level then
    Toast(string.format(textRes.Children[1043], textRes.Children[1016], constant.CChildrenConsts.children_function_open_level))
    return false
  end
  local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
  local teamData = require("Main.Team.TeamData").Instance()
  local mateData = teamData:getMember(mateInfo.mateId)
  if mateData.level < constant.CChildrenConsts.children_function_open_level then
    Toast(string.format(textRes.Children[1043], mateData.name, constant.CChildrenConsts.children_function_open_level))
    return false
  end
  return true
end
def.method("=>", "boolean").CheckSingleLevelAndToast = function(self)
  if not require("Main.Children.ChildrenInterface").IsReachFunctionOpenLevel() then
    Toast(string.format(textRes.Children[1043], textRes.Children[1016], constant.CChildrenConsts.children_function_open_level))
    return false
  end
  return true
end
def.method().InvitePreparePregnant = function(self)
  if not self:CheckCoupleStateAndToast() then
    return
  end
  if not self:CheckCoupleLevelAndToast() then
    return
  end
  if not self:CheckPreparePregnantFunctionAndToast() then
    return
  end
  local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
  if mateInfo == nil then
    return
  end
  local req = require("netio.protocol.mzm.gsp.children.CAttendPreparePregnancyReq").new(mateInfo.mateId)
  gmodule.network.sendProtocol(req)
end
def.method("=>", "boolean").CheckPreparePregnantFunctionAndToast = function(self)
  if not IsFeatureOpen(Feature.TYPE_BUBBLE_GAME) or not IsFeatureOpen(Feature.TYPE_PREPARE_PREGNANCY) then
    Toast(textRes.Children[1045])
    return false
  end
  return true
end
def.method("userdata").SelectPregnantBelong = function(self, belongId)
  if not self:CheckCoupleStateAndToast() then
    return
  end
  if not self:CheckCoupleLevelAndToast() then
    return
  end
  local homelandModule = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND)
  if not homelandModule:IsThereABedInMyHouse() then
    Toast(textRes.Children[1040])
    return
  end
  local req = require("netio.protocol.mzm.gsp.children.CSelectPregnantBelong").new(belongId)
  gmodule.network.sendProtocol(req)
end
def.method().BabyEducate = function(self)
  if not self:CheckSingleLevelAndToast() then
    return
  end
  if not self:CheckBabyEducateFunctionAndToast() then
    return
  end
  local req = require("netio.protocol.mzm.gsp.children.CAttendFetusEducationMusicReq").new()
  gmodule.network.sendProtocol(req)
end
def.method("=>", "boolean").CheckBabyEducateFunctionAndToast = function(self)
  if not IsFeatureOpen(Feature.TYPE_MUSIC_GAME) or not IsFeatureOpen(Feature.TYPE_FETUS_EDUCATION_MUSIC) then
    Toast(textRes.Children[1046])
    return false
  end
  return true
end
def.method().GiveBirth = function(self)
  if not self:CheckCoupleStateAndToast() then
    return
  end
  if not self:CheckCoupleLevelAndToast() then
    return
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm("", textRes.Children[1020], function(result)
    if result == 0 then
      return
    end
    self:RequireMidWife()
  end, nil)
end
def.method().SingleGiveBirth = function(self)
  if not self:CheckSingleLevelAndToast() then
    return
  end
  if self:IsSingleFullChildren() then
    Toast(textRes.Children[1021])
    return
  end
  local songZiGuanYinPanel = require("Main.Children.ui.SongZiGuanYin").Instance()
  songZiGuanYinPanel:ShowPanel()
end
def.method().GiveUpBreed = function(self)
  local req = require("netio.protocol.mzm.gsp.children.CGiveUpBreed").new()
  gmodule.network.sendProtocol(req)
end
def.method().WaitPreparePregancy = function(self)
  local WaitingTipCountDown = require("GUI.WaitingTipCountDown")
  WaitingTipCountDown.ShowTip(textRes.Children[1025], 10)
end
def.method().StopWaitPreparePregancy = function(self)
  local WaitingTipCountDown = require("GUI.WaitingTipCountDown")
  WaitingTipCountDown.HideTip()
end
def.method("userdata").ConfirmPreparePregancy = function(self, inviteId)
  local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
  if mateInfo == nil then
    return
  end
  local teamData = require("Main.Team.TeamData").Instance()
  local mateData = teamData:getMember(mateInfo.mateId)
  if mateData == nil then
    return
  end
  local strConfirm = string.format(textRes.Children[1023], mateData.name)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirmCoundDown("", strConfirm, "", "", 0, constant.CChildrenConsts.select_pregnant_wait_seconds, function(result)
    self:AnswerAttendPreparePregnancyInvite(inviteId, result)
  end, nil)
end
def.method("userdata", "number").AnswerAttendPreparePregnancyInvite = function(self, inviteId, isAgree)
  local CAnswerAttendPreparePregnancyInvite = require("netio.protocol.mzm.gsp.children.CAnswerAttendPreparePregnancyInvite")
  local isAgree = isAgree == 1 and CAnswerAttendPreparePregnancyInvite.AGREE or CAnswerAttendPreparePregnancyInvite.REFUSE
  local req = CAnswerAttendPreparePregnancyInvite.new(isAgree, inviteId, self.operateSessionId)
  gmodule.network.sendProtocol(req)
end
def.method().WaitChooseChildBelong = function(self)
  require("Main.Children.ui.ChooseChildOwnerPanel").Instance():WaitForConfirm()
end
def.method("userdata").ConfirmChooseChildBelong = function(self, belongId)
  local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
  if mateInfo == nil then
    return
  end
  local teamData = require("Main.Team.TeamData").Instance()
  local mateData = teamData:getMember(mateInfo.mateId)
  if mateData == nil then
    return
  end
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  if heroProp == nil then
    return
  end
  local belongName = ""
  if belongId == mateInfo.mateId then
    belongName = mateData.name
  else
    belongName = heroProp.name
  end
  local strConfirm = string.format(textRes.Children[1014], mateData.name, constant.CChildrenConsts.pregnant_cut_vigor_score, mateData.name, belongName)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirmCoundDown("", strConfirm, "", "", 0, constant.CChildrenConsts.select_pregnant_wait_seconds, function(result)
    self:AgreeOrRefusePregnantBelong(result)
  end, nil)
end
def.method("number").AgreeOrRefusePregnantBelong = function(self, isAgree)
  local req = require("netio.protocol.mzm.gsp.children.CAgreeOrRefusePregnantBelong").new(isAgree, self.operateSessionId)
  gmodule.network.sendProtocol(req)
end
def.method().RequireMidWife = function(self)
  require("Main.Children.mgr.DeliveryMgr").Instance():StartDelivery()
end
def.method("userdata").ShowBabyCarePanel = function(self, babyId)
  if not require("Main.Children.ChildrenInterface").CheckFunctionOpenAndToast() then
    return
  end
  require("Main.Children.ui.BabyCarePanel").Instance():ShowPanel(babyId)
end
def.method("number", "userdata").StartBreedBabyChild = function(self, operater, childId)
  local req = require("netio.protocol.mzm.gsp.children.CStartBreedBabyChild").new(operater, childId)
  gmodule.network.sendProtocol(req)
end
def.method("userdata").WakeUpBabyChild = function(self, childId)
  local req = require("netio.protocol.mzm.gsp.children.CWakeUpBabyChild").new(childId)
  gmodule.network.sendProtocol(req)
end
def.method("userdata").BabyToChildHood = function(self, childId)
  if not require("Main.Children.ChildrenInterface").CheckChildhoodPhaseOpenAndToast() then
    return
  end
  local req = require("netio.protocol.mzm.gsp.children.CBabyToChildHood").new(childId)
  gmodule.network.sendProtocol(req)
end
def.method("userdata", "userdata").HireNannyReq = function(self, childId, owndYuanbao)
  if not require("Main.Children.ChildrenInterface").CheckChildhoodPhaseOpenAndToast() then
    return
  end
  local req = require("netio.protocol.mzm.gsp.children.CAutoBreedBabyReq").new(childId, owndYuanbao)
  gmodule.network.sendProtocol(req)
end
def.static("table").OnSAutoBreedBabyRes = function(p)
  local babyData = ChildrenDataMgr.Instance():GetChildById(p.childid)
  if babyData then
    local const = constant.CChildrenConsts
    babyData:SetHasNanny(true)
    babyData.propBaoshi = const.baby_auto_bao_shi_value
    babyData.propMood = const.baby_auto_mood_value
    babyData.propClean = const.baby_auto_clean_value
  end
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.HIRE_NANNY_SUCCESS, {
    childId = p.childid
  })
end
def.method().NotifyChildAbortion = function(self)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local content = require("Main.Common.TipsHelper").GetHoverTip(constant.CChildrenConsts.baby_abortion_tips)
  CommonConfirmDlg.ShowCerternConfirm(textRes.Children[1044], content, "", nil, nil)
end
def.method().PlayGetBabyEffect = function(self)
  local effectId = constant.CChildrenConsts.special_effect_source_cfg_id
  if effectId ~= 0 then
    local effectCfg = GetEffectRes(effectId)
    if nil == effectCfg then
      warn("BabyMgr::PlayGetBabyEffect: effet cfg is nil ~~~~~~~~~~~~ id = " .. effectId)
      return
    end
    local GUIFxMan = require("Fx.GUIFxMan")
    local fx = GUIFxMan.Instance():Play(effectCfg.path, "GetBaby", 0, 0, -1, false)
  end
end
def.method().PlayPregnantEffect = function(self)
  local effectId = constant.CChildrenConsts.pregnant_effect_source_cfg_id
  if effectId ~= 0 then
    local effectCfg = GetEffectRes(effectId)
    if nil == effectCfg then
      warn("BabyMgr::PlayPregnantEffect: effet cfg is nil ~~~~~~~~~~~~ id = " .. effectId)
      return
    end
    local GUIFxMan = require("Fx.GUIFxMan")
    local fx = GUIFxMan.Instance():Play(effectCfg.path, "Pregnant", 0, 0, -1, false)
    GameUtil.AddGlobalTimer(16, true, function()
      if _G.IsEnteredWorld() then
        Toast(textRes.Children[1051])
      end
    end)
  end
end
def.method().PlayBabyToChildEffect = function(self)
  local effectId = constant.CChildrenConsts.baby_to_child_effect_source_cfg_id
  if effectId ~= 0 then
    local effectCfg = GetEffectRes(effectId)
    if nil == effectCfg then
      warn("BabyMgr::PlayBabyToChildEffect: effet cfg is nil ~~~~~~~~~~~~ id = " .. effectId)
      return
    end
    local GUIFxMan = require("Fx.GUIFxMan")
    local fx = GUIFxMan.Instance():Play(effectCfg.path, "BabyToChild", 0, 0, -1, false)
  end
end
def.method().StartBabyTimer = function(self)
  self.babyTimerId = GameUtil.AddGlobalTimer(1, false, function()
    self:UpdateGetBabyPhaseTick()
    self:UpdateBabyDataTick()
  end)
end
def.method().UpdateGetBabyPhaseTick = function(self)
  local BreedStepEnum = require("consts.mzm.gsp.children.confbean.BreedStepEnum")
  local getBabyPhaseData = require("Main.Children.data.GetBabyPhaseData").Instance()
  if getBabyPhaseData:IsCoupleBreeding() and getBabyPhaseData:GetCurrentBreedStep() == BreedStepEnum.GIVE_BIRTH then
    getBabyPhaseData:Tick()
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.GIVE_BIRTH_CHILD_REMAIN_TIME_CHANGE, nil)
  end
end
def.method().UpdateBabyDataTick = function(self)
  local ChildPhase = require("consts.mzm.gsp.children.confbean.ChildPhase")
  local children = ChildrenDataMgr.Instance():GetChildrenByStatus(ChildPhase.INFANT)
  local dataChangedChild = {}
  for idx, child in pairs(children) do
    if child:Tick() then
      table.insert(dataChangedChild, child:GetId())
    end
  end
  if #dataChangedChild > 0 then
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.BABY_DATA_CHANGE, dataChangedChild)
  end
end
def.method().StopBabyTimer = function(self)
  GameUtil.RemoveGlobalTimer(self.babyTimerId)
end
BabyMgr.Commit()
return BabyMgr
