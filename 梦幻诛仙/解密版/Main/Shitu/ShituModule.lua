local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local ShituModule = Lplus.Extend(ModuleBase, "ShituModule")
local ShituData = require("Main.Shitu.ShituData")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ShiTuConst = require("netio.protocol.mzm.gsp.shitu.ShiTuConst")
local NPCInterface = require("Main.npc.NPCInterface")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr")
local Octets = require("netio.Octets")
local def = ShituModule.define
local instance
def.field("table")._currentWaitDlg = nil
def.static("=>", ShituModule).Instance = function()
  if instance == nil then
    instance = ShituModule()
    instance.m_moduleId = ModuleId.WORLD_QUESTION
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SSyncShiTuInfo", ShituModule.OnSyncShiTuInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SGetChuShiApprenticeSuccess", ShituModule.OnReceiveChuShiApprenticeList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SShouTuConditionCheckResult", ShituModule.OnShouTuConditionCheckResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SShouTuSuccess", ShituModule.OnStartShoutu)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SCancelShouTuSuccess", ShituModule.OnCancelShouTuSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SAgreeOrRefuseShouTu", ShituModule.OnAgreeOrRefuseShouTu)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SRelieveShiTuRelation", ShituModule.OnRelieveShiTuRelation)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SChuShiConditionCheckResult", ShituModule.OnChuShiConditionCheckResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SChuShiSuccess", ShituModule.OnChuShiSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SGetClassMateApprenticeInfo", ShituModule.OnReceiveClassMateApprenticeList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SGetApprenticeNumAwardSuccess", ShituModule.OnGetApprenticeNumAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SPayRespectSuccess", ShituModule.OnQingAnSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SPayRespectFail", ShituModule.OnQingAnFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SReplyPayRespect", ShituModule.OnQingAnResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SApprenticePayRespect", ShituModule.OnReceiveQingAn)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, ShituModule.OnShituNPCService)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ShituModule.ClearData)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, ShituModule.OnActivityReset)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ShituModule.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, ShituModule.OnFeatureOpenInit)
  local npcInterface = NPCInterface.Instance()
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.ToBeMaster, ShituModule.OnNPCService_ToBeMaster)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.ExpelApprentice, ShituModule.OnNPCService_ExpelApprentice)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.BetrayMaster, ShituModule.OnNPCService_BetrayMaster)
  require("Main.Shitu.interact.InteractMgr").Instance():Init()
  ModuleBase.Init(self)
end
def.static("table").OnSyncShiTuInfo = function(p)
  local shituData = ShituData.Instance()
  if shituData ~= nil then
    shituData:SetMaster(p.masterInfo)
    shituData:SetNowApprentice(p.nowApprenticeList)
    shituData:SetTotalApprenticeNum(p.totalApprenticeNum)
    shituData:SetReceivedAward(p.aleardy_awarded_cfg_id_set)
    shituData:SetChushiState(p.is_chu_shi_state)
    shituData:SetPayRespectTimes(p.now_pay_respect_times)
    HeroPropMgr.Instance():SetShituNotify()
    Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.ShituRelationChange, nil)
  end
end
def.method().ShowShituRelation = function(self)
  local shituRelationPanel = require("Main.Shitu.ui.ShituRelationPanel").Instance()
  shituRelationPanel:ShowShituRelation()
end
def.method().GetChuShiApprenticeInfo = function(self)
  local shituData = ShituData.Instance()
  local pullChushiApprentice = require("netio.protocol.mzm.gsp.shitu.CGetChuShiApprenticeInfo").new(shituData:GetNextCacheApprenticePos())
  gmodule.network.sendProtocol(pullChushiApprentice)
end
def.static("table").OnReceiveChuShiApprenticeList = function(p)
  local shituData = ShituData.Instance()
  shituData:AddChushiApprentice(p.chuShiApprenticeListInfo)
  Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.ReceiveChushiApprenticeList, nil)
end
def.method().GetClassMateApprenticeInfo = function(self)
  local shituData = ShituData.Instance()
  local pullClassmate = require("netio.protocol.mzm.gsp.shitu.CGetClassMateApprenticeInfo").new(shituData:GetNextClassmatePos())
  gmodule.network.sendProtocol(pullClassmate)
end
def.static("table").OnReceiveClassMateApprenticeList = function(p)
  local shituData = ShituData.Instance()
  local preClassMateCacheCount = shituData:GetCurrentCachedClassmateCount()
  shituData:SetNowClassmates(p.nowClassMateListInfo)
  shituData:AddChushiClassmates(p.chuShiClassMateListInfo)
  shituData:SetTotalClassmateCount(p.classMateSize)
  Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.ReceiveClassMateApprenticeList, nil)
end
def.static("table").OnShouTuConditionCheckResult = function(p)
  local takeApprenticePanel = require("Main.Shitu.ui.TakeApprenticePanel").Instance()
  if takeApprenticePanel:IsShow() then
    takeApprenticePanel:OnReceiveServerConditionStatus(p)
  end
end
def.static("table").OnStartShoutu = function(p)
  local shituData = ShituData.Instance()
  shituData:SetCurrentSession(p)
  if instance._currentWaitDlg ~= nil then
    instance._currentWaitDlg:DestroyPanel()
    instance._currentWaitDlg = nil
  end
  local roleId = require("Main.Hero.HeroModule").Instance().roleId
  if roleId == p.masterRoleId then
    instance._currentWaitDlg = CommonConfirmDlg.ShowConfirmCoundDown("", textRes.Shitu[8], "nil", textRes.Shitu[9], 0, constant.ShiTuConsts.waitSeconds, function(result, tag)
      if result == 0 then
        ShituModule.CancelTakeApprentice()
      end
    end, nil)
  else
    local info = string.format(textRes.Shitu[10], p.masterRoleName)
    instance._currentWaitDlg = CommonConfirmDlg.ShowConfirmCoundDown("", info, textRes.Shitu[11], textRes.Shitu[12], 0, constant.ShiTuConsts.waitSeconds, function(result, tag)
      local isAgree = result == 1 and true or false
      ShituModule.HandleTakeApprenticeReq(isAgree)
    end, nil)
  end
end
def.static().CancelTakeApprentice = function()
  local shituData = ShituData.Instance()
  local session = shituData:GetCurrentSession()
  if session ~= nil then
    local cancelShoutu = require("netio.protocol.mzm.gsp.shitu.CCancelShouTuReq").new(session.sessionid)
    gmodule.network.sendProtocol(cancelShoutu)
  end
  instance._currentWaitDlg = nil
end
def.static("table").OnCancelShouTuSuccess = function(p)
  local roleId = require("Main.Hero.HeroModule").Instance().roleId
  if roleId ~= p.masterRoleId then
    local info = string.format(textRes.Shitu[13], p.masterRoleName)
    Toast(info)
  end
  instance:CloseTakeApprenticeSession()
end
def.static("boolean").HandleTakeApprenticeReq = function(isAgree)
  local shituData = ShituData.Instance()
  local session = shituData:GetCurrentSession()
  local operator = isAgree and ShiTuConst.AGREE_SHOUTU or ShiTuConst.REFUSE_SHOUTU
  if session ~= nil then
    local handleShoutu = require("netio.protocol.mzm.gsp.shitu.CAgreeOrRefuseShouTu").new(operator, session.sessionid)
    gmodule.network.sendProtocol(handleShoutu)
  end
  instance._currentWaitDlg = nil
end
def.static("table").OnAgreeOrRefuseShouTu = function(p)
  local roleId = require("Main.Hero.HeroModule").Instance().roleId
  local shituData = ShituData.Instance()
  local session = shituData:GetCurrentSession()
  local apprenticeRoleInfo = p.apprenticeRoleInfo
  local masterRoleInfo = p.masterRoleInfo
  if p.operator == ShiTuConst.AGREE_SHOUTU then
    local info = ""
    if roleId == apprenticeRoleInfo.roleId then
      info = string.format(textRes.Shitu[17], apprenticeRoleInfo.roleName)
      shituData:SetMaster(masterRoleInfo)
    else
      local session = shituData:GetCurrentSession()
      info = string.format(textRes.Shitu[17], apprenticeRoleInfo.roleName)
      shituData:AddApprentice(apprenticeRoleInfo)
      shituData:ChangeTotalApprenticeNum(1)
    end
    Toast(info)
    local shoutuPanel = require("Main.Shitu.ui.TakeApprenticePanel").Instance()
    if shoutuPanel:IsShow() then
      shoutuPanel:Close()
    end
    HeroPropMgr.Instance():SetShituNotify()
    Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.ShituRelationChange, nil)
  elseif roleId ~= apprenticeRoleInfo.roleId then
    local info = string.format(textRes.Shitu[16], apprenticeRoleInfo.roleName)
    Toast(info)
  end
  instance:CloseTakeApprenticeSession()
end
def.method().TakeApprenticeSessionTimeOut = function(self)
  Toast(textRes.Shitu[18])
  self:CloseTakeApprenticeSession()
end
def.method().CloseTakeApprenticeSession = function(self)
  if self._currentWaitDlg ~= nil then
    self._currentWaitDlg:DestroyPanel()
    self._currentWaitDlg = nil
  end
  local shituData = ShituData.Instance()
  shituData:ClearSession()
end
def.static("table").OnRelieveShiTuRelation = function(p)
  local opName = ""
  local roleId = require("Main.Hero.HeroModule").Instance().roleId
  local shituData = ShituData.Instance()
  if roleId == p.masterRoleId then
    opName = p.apprenticeRoleName
    shituData:RemoveNowApprenticeById(p.apprenticeRoleId)
    shituData:ChangeTotalApprenticeNum(-1)
  else
    opName = p.masterRoleName
    shituData:SetMaster(nil)
  end
  local info = string.format(textRes.Shitu[23], opName)
  Toast(info)
  HeroPropMgr.Instance():SetShituNotify()
  Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.ShituRelationChange, nil)
end
def.static("table").OnChuShiConditionCheckResult = function(p)
  local toBeMasterPanel = require("Main.Shitu.ui.ToBeMasterPanel").Instance()
  if toBeMasterPanel:IsShow() then
    toBeMasterPanel:OnReceiveServerConditionStatus(p)
  end
end
def.static("table").OnChuShiSuccess = function(p)
  local apprenticeId = p.apprenticeRoleId
  local apprenticeName = p.apprenticeRoleName
  local roleId = require("Main.Hero.HeroModule").Instance().roleId
  local shituData = ShituData.Instance()
  if roleId == apprenticeId then
    shituData:SetChushiState(ShiTuConst.YES_CHU_SHI)
    Toast(textRes.Shitu[26])
  else
    shituData:RemoveNowApprenticeById(apprenticeId)
    Toast(string.format(textRes.Shitu[27], apprenticeName))
  end
  HeroPropMgr.Instance():SetShituNotify()
  Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.ShituRelationChange, nil)
end
def.static("table", "table").OnShituNPCService = function(p1, p2)
  local npcId = p1[2]
  local serviceId = p1[1]
  local NPCServiceConst = require("Main.npc.NPCServiceConst")
  if constant.ShiTuConsts.shiTuNPCId == npcId then
    if NPCServiceConst.ExpelApprentice == serviceId then
      instance:ExpelApprentice()
    elseif NPCServiceConst.ToBeMaster == serviceId then
      instance:ToBeMaster()
    elseif NPCServiceConst.TakeApprentice == serviceId then
      instance:ShowTakeApprenticePanel()
    elseif NPCServiceConst.BetrayMaster == serviceId then
      instance:BetrayMaster()
    end
  end
end
def.method().ShowTakeApprenticePanel = function(self)
  local teamData = require("Main.Team.TeamData").Instance()
  local TeamMember = require("netio.protocol.mzm.gsp.team.TeamMember")
  if teamData:GetStatus() == TeamMember.ST_TMP_LEAVE then
    Toast(textRes.Shitu[30])
  else
    local takeApprenticePanel = require("Main.Shitu.ui.TakeApprenticePanel").Instance()
    takeApprenticePanel:ShowTakeApprenticePanel()
  end
end
def.method().ToBeMaster = function(self)
  local shituData = ShituData.Instance()
  if shituData:GetMaster() == nil then
    Toast(textRes.Shitu[24])
    return
  end
  local toBeMasterPanel = require("Main.Shitu.ui.ToBeMasterPanel").Instance()
  toBeMasterPanel:ShowToBeMasterPanel()
end
def.method().BetrayMaster = function(self)
  local shituData = ShituData.Instance()
  if not shituData:HasMaster() then
    Toast(textRes.Shitu[31])
    return
  end
  CommonConfirmDlg.ShowConfirm("", textRes.Shitu[14], function(result, tag)
    if result == 1 then
      local betrayReq = require("netio.protocol.mzm.gsp.shitu.CApprenticeRelieveShiTuRelation").new()
      gmodule.network.sendProtocol(betrayReq)
    end
  end, nil)
end
def.method().ExpelApprentice = function(self)
  local shituData = ShituData.Instance()
  if shituData:GetNowApprenticeCount() == 0 then
    Toast(textRes.Shitu[32])
    return
  end
  local expelApprenticePanel = require("Main.Shitu.ui.ExpelApprenticePanel").Instance()
  expelApprenticePanel:ShowExpelApprenticePanel()
end
def.method("number").GetApprenticeNumAward = function(self, awardId)
  local getAward = require("netio.protocol.mzm.gsp.shitu.CGetApprenticeNumAward").new(awardId)
  gmodule.network.sendProtocol(getAward)
end
def.static("table").OnGetApprenticeNumAwardSuccess = function(p)
  ShituData.Instance():ReceiveNewAward(p.award_score_cfg_id)
  HeroPropMgr.Instance():SetShituNotify()
  Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.ReceiveNewAward, nil)
end
def.method().ShowAwardPanel = function(self)
  require("Main.Shitu.ui.ChushiAwardPanel").Instance():ShowAwardPanel()
end
def.method("userdata", "function").GetRoleInfo = function(self, roleId, callback)
  gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ReqRoleInfo(roleId, callback)
end
def.static("=>", "boolean").IsQingAnFunctionOpen = function(self)
  if IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_SHI_TU_PAY_RESPECT) then
    return true
  end
  return false
end
def.static().ShowQinganPanel = function()
  if not ShituModule.IsQingAnFunctionOpen() then
    Toast(textRes.Shitu[44])
    return
  end
  local shituData = ShituData.Instance()
  if not shituData:HasMaster() then
    Toast(textRes.Shitu[33])
    return
  end
  local masterRoleId = shituData:GetMaster().roleId
  if not shituData:HasPayRespectTimes() then
    Toast(textRes.Shitu[34])
    return
  end
  require("Main.Shitu.ui.QingAnPanel").Instance():ShowQingAnPanel()
end
def.static("string").QingAn = function(content)
  local req = require("netio.protocol.mzm.gsp.shitu.CPayRespect").new(Octets.rawFromString(content))
  gmodule.network.sendProtocol(req)
end
def.static("table").OnQingAnSuccess = function(p)
  Toast(textRes.Shitu[36])
end
def.static("table").OnQingAnFail = function(p)
  if textRes.Shitu.SPayRespectFail[p.result] ~= nil then
    Toast(textRes.Shitu.SPayRespectFail[p.result])
  else
    Toast(textRes.Shitu[37])
  end
end
def.static("table").OnQingAnResult = function(p)
  local roleId = require("Main.Hero.HeroModule").Instance().roleId
  local shituData = ShituData.Instance()
  if roleId == p.master_role_id then
    if p.operator == ShiTuConst.YES_PAY_RESPECT then
      local apprentice = shituData:GetNowApprenticeById(p.apprentice_role_id)
      if apprentice ~= nil then
        Toast(string.format(textRes.Shitu[40], apprentice.roleName, constant.ShiTuConsts.payRespectAwardRelationValue))
      end
    end
  elseif shituData:HasMaster() then
    local master = shituData:GetMaster()
    if p.operator == ShiTuConst.YES_PAY_RESPECT then
      Toast(string.format(textRes.Shitu[38], master.roleName, constant.ShiTuConsts.payRespectAwardRelationValue))
      shituData:AddPayRespectTimes()
      HeroPropMgr.Instance():SetShituNotify()
      Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.PayRespectDataChange, nil)
    else
      Toast(textRes.Shitu[43])
    end
  end
end
def.static("table").OnReceiveQingAn = function(p)
  local QingAnResponsePanel = require("Main.Shitu.ui.QingAnResponsePanel").Instance()
  if not QingAnResponsePanel:IsHandingQingAn() then
    local content = p.pay_respect_str
    local apprenticeId = p.apprentice_role_id
    local currentSessionId = p.session_id
    QingAnResponsePanel:ShowResponsePanel(currentSessionId, apprenticeId, _G.GetStringFromOcts(content))
  end
end
def.static("userdata", "userdata", "boolean").ResponseQingAn = function(sessionId, roleId, isAgree)
  local shituData = ShituData.Instance()
  if shituData:GetNowApprenticeById(roleId) ~= nil then
    local operator = isAgree and 1 or 0
    local req = require("netio.protocol.mzm.gsp.shitu.CReplyPayRespect").new(operator, roleId, sessionId)
    gmodule.network.sendProtocol(req)
  else
    Toast(textRes.Shitu[43])
  end
end
def.static("table", "table").OnActivityReset = function(params, context)
  local activityId = params[1]
  if activityId == constant.ShiTuConsts.payRespectActivityId then
    ShituData.Instance():ResetPayRespectTimes()
    HeroPropMgr.Instance():SetShituNotify()
    Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.PayRespectDataChange, nil)
  end
end
def.static("table", "table").OnFeatureOpenChange = function(params, context)
  if params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_SHI_TU_PAY_RESPECT then
    HeroPropMgr.Instance():SetShituNotify()
    Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.PayRespectDataChange, nil)
  end
end
def.static("table", "table").OnFeatureOpenInit = function(params, context)
  HeroPropMgr.Instance():SetShituNotify()
  Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.PayRespectDataChange, nil)
end
def.override().OnReset = function(self)
  ShituData.Instance():ClearData()
end
def.static("table", "table").ClearData = function(param, tbl)
  instance:OnReset()
end
def.static("number", "=>", "boolean").OnNPCService_ToBeMaster = function(serviceId)
  if serviceId == NPCServiceConst.ToBeMaster then
    local shituData = ShituData.Instance()
    if not shituData:HasMaster() then
      return false
    end
    if shituData:IsChushi() then
      return false
    end
    return true
  else
    return true
  end
end
def.static("number", "=>", "boolean").OnNPCService_ExpelApprentice = function(serviceId)
  if serviceId == NPCServiceConst.ExpelApprentice then
    local shituData = ShituData.Instance()
    return shituData:GetNowApprenticeCount() > 0
  else
    return true
  end
end
def.static("number", "=>", "boolean").OnNPCService_BetrayMaster = function(serviceId)
  if serviceId == NPCServiceConst.BetrayMaster then
    local shituData = ShituData.Instance()
    if not shituData:HasMaster() then
      return false
    end
    if shituData:IsChushi() then
      return false
    end
    return true
  else
    return true
  end
end
def.static().GotoShituNPC = function()
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.ShiTuConsts.shiTuNPCId
  })
end
ShituModule.Commit()
return ShituModule
