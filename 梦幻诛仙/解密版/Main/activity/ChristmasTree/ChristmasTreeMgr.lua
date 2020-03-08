local Lplus = require("Lplus")
local ChristmasTreeMgr = Lplus.Class("ChristmasTreeMgr")
local def = ChristmasTreeMgr.define
def.field("number").totalHangNum = 0
def.field("table").currentVistTreeData = nil
local instance
def.static("=>", ChristmasTreeMgr).Instance = function()
  if instance == nil then
    instance = ChristmasTreeMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.christmasstocking.SSynRoleStockingInfo", ChristmasTreeMgr.OnSSynRoleStockingInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.christmasstocking.SGetStockingInfoSuccess", ChristmasTreeMgr.OnSGetStockingInfoSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.christmasstocking.SGetStockingInfoFail", ChristmasTreeMgr.OnSGetStockingInfoFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.christmasstocking.SHangStockingSuccess", ChristmasTreeMgr.OnSHangStockingSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.christmasstocking.SHangStockingFail", ChristmasTreeMgr.OnSHangStockingFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.christmasstocking.SGetStockingAwardSuccess", ChristmasTreeMgr.OnSGetStockingAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.christmasstocking.SGetStockingAwardFail", ChristmasTreeMgr.OnSGetStockingAwardFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.christmasstocking.SGetStockingHidingAwardFail", ChristmasTreeMgr.OnSGetStockingHidingAwardFail)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, ChristmasTreeMgr.OnActivityTodo)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, ChristmasTreeMgr.OnNewDay)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ChristmasTreeMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, ChristmasTreeMgr.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ChristmasTreeMgr.OnFeatureOpenChange)
end
def.static("table").OnSSynRoleStockingInfo = function(p)
  local self = ChristmasTreeMgr.Instance()
  self.totalHangNum = p.total_hang_num
  self:CheckActivityNotify()
end
def.static("table").OnSGetStockingInfoSuccess = function(p)
  local self = ChristmasTreeMgr.Instance()
  local ChristmasTreeData = require("Main.activity.ChristmasTree.data.ChristmasTreeData")
  self.currentVistTreeData = ChristmasTreeData()
  self.currentVistTreeData:RawSet(p)
  require("Main.activity.ChristmasTree.ui.ChristmasTreePanel").Instance():ShowCurrentVisitTree()
end
def.static("table").OnSGetStockingInfoFail = function(p)
  if textRes.activity.ChristmasTree.SGetStockingInfoFail[p.error_code] then
    Toast(textRes.activity.ChristmasTree.SGetStockingInfoFail[p.error_code])
  else
    Toast(string.format(textRes.activity.ChristmasTree.SGetStockingInfoFail[0], p.error_code))
  end
end
def.static("table").OnSHangStockingSuccess = function(p)
  local self = ChristmasTreeMgr.Instance()
  self:AddTodayHangNum()
  self:CheckActivityNotify()
  if self.currentVistTreeData == nil then
    return
  end
  if Int64.eq(self.currentVistTreeData:GetRoleId(), p.target_role_id) then
    self.currentVistTreeData:MarkPosAsHanging(p.position)
    self.currentVistTreeData:AddOperationHistory(p.new_history)
    self.currentVistTreeData:AddSelfHangNum()
    if self.currentVistTreeData:IsMyChristmasTree() then
      Toast(textRes.activity.ChristmasTree[20])
    end
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ChristmasTree_Change, nil)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ChristmasTree_Hang_Stock, {
      pos = p.position
    })
  end
end
def.static("table").OnSHangStockingFail = function(p)
  if textRes.activity.ChristmasTree.SHangStockingFail[p.error_code] then
    Toast(textRes.activity.ChristmasTree.SHangStockingFail[p.error_code])
  else
    Toast(string.format(textRes.activity.ChristmasTree.SHangStockingFail[0], p.error_code))
  end
end
def.static("table").OnSGetStockingAwardSuccess = function(p)
  local self = ChristmasTreeMgr.Instance()
  if self.currentVistTreeData == nil then
    return
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if not heroProp then
    return
  end
  if Int64.eq(self.currentVistTreeData:GetRoleId(), heroProp.id) then
    self.currentVistTreeData:MarkPosAsEmpty(p.position)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ChristmasTree_Change, nil)
  end
end
def.static("table").OnSGetStockingAwardFail = function(p)
  if textRes.activity.ChristmasTree.SGetStockingAwardFail[p.error_code] then
    Toast(textRes.activity.ChristmasTree.SGetStockingAwardFail[p.error_code])
  else
    Toast(string.format(textRes.activity.ChristmasTree.SGetStockingAwardFail[0], p.error_code))
  end
end
def.static("table").OnSGetStockingHidingAwardFail = function(p)
  if textRes.activity.ChristmasTree.SGetStockingHidingAwardFail[p.error_code] then
    Toast(textRes.activity.ChristmasTree.SGetStockingHidingAwardFail[p.error_code])
  else
    Toast(string.format(textRes.activity.ChristmasTree.SGetStockingHidingAwardFail[0], p.error_code))
  end
end
def.static("table", "table").OnActivityTodo = function(params, context)
  local activityId = params[1]
  if activityId == constant.CChristmasStockingConsts.ACTIVITY_ID then
    if gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):HaveHome() then
      gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):ReturnHome()
    else
      Toast(textRes.Homeland[60])
    end
  end
end
def.static("table", "table").OnNewDay = function(params, context)
  local self = ChristmasTreeMgr.Instance()
  self.totalHangNum = 0
  self:CheckActivityNotify()
  if self.currentVistTreeData ~= nil then
    self.currentVistTreeData:NewDayToUpdateAward()
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ChristmasTree_Change, nil)
  end
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  local self = ChristmasTreeMgr.Instance()
  self:ResetData()
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  local self = ChristmasTreeMgr.Instance()
  self:UpdateActivityIDIPState()
  self:CheckActivityNotify()
end
def.static("table", "table").OnFeatureOpenChange = function(p1, p2)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local featureType = p1.feature
  if featureType == ModuleFunSwitchInfo.TYPE_CHRISTMAS_STOCKING then
    local self = ChristmasTreeMgr.Instance()
    self:UpdateActivityIDIPState()
    self:CheckActivityNotify()
  end
end
def.method("=>", "boolean").IsOpen = function(self)
  if not self:IsFeatureOpen() then
    return false
  end
  if not self:IsActivityOpen() then
    return false
  end
  if not self:IsReachFunctionLevel() then
    return false
  end
  return true
end
def.method("=>", "boolean").CheckIsOpenAndToast = function(self)
  if not self:IsFeatureOpen() then
    Toast(textRes.activity.ChristmasTree[1])
    return false
  end
  if not self:IsActivityOpen() then
    Toast(textRes.activity.ChristmasTree[8])
    return false
  end
  if not self:IsReachFunctionLevel() then
    local openLevel = self:GetActivityOpenLevel()
    Toast(string.format(textRes.activity.ChristmasTree[2], openLevel))
    return false
  end
  return true
end
def.method("=>", "boolean").IsActivityOpen = function(self)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  return ActivityInterface.Instance():isActivityOpend2(constant.CChristmasStockingConsts.ACTIVITY_ID)
end
def.method("=>", "boolean").IsReachFunctionLevel = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if not heroProp then
    return false
  end
  local openLevel = self:GetActivityOpenLevel()
  return openLevel <= heroProp.level
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  if _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHRISTMAS_STOCKING) then
    return true
  end
  return false
end
def.method("=>", "number").GetActivityOpenLevel = function(self)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local cfg = ActivityInterface.GetActivityCfgById(constant.CChristmasStockingConsts.ACTIVITY_ID)
  if cfg then
    return cfg.levelMin
  else
    return 0
  end
end
def.method("=>", "boolean").IsChristmasTreeOver = function(self)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local openTime, activeTimeList, closeTime = ActivityInterface.Instance():getActivityStatusChangeTime(constant.CChristmasStockingConsts.ACTIVITY_ID)
  local overTime = closeTime + constant.CChristmasStockingConsts.AFTER_ACTIVITY_RETAIN_MINUTES * 60
  local curTime = _G.GetServerTime()
  return overTime <= curTime
end
def.method("=>", "table").GetCurrentVisitTree = function(self)
  return self.currentVistTreeData
end
def.method("userdata").GetChristmasTreeInfo = function(self, roleId)
  if not self:IsFeatureOpen() then
    Toast(textRes.activity.ChristmasTree[1])
    return
  end
  if not self:IsReachFunctionLevel() then
    local openLevel = self:GetActivityOpenLevel()
    Toast(string.format(textRes.activity.ChristmasTree[2], openLevel))
    return
  end
  if self:IsChristmasTreeOver() then
    Toast(textRes.activity.ChristmasTree[14])
    return
  end
  local req = require("netio.protocol.mzm.gsp.christmasstocking.CGetStockingInfoReq").new(roleId)
  gmodule.network.sendProtocol(req)
end
def.method("userdata", "number").HangStockOnCurrentTree = function(self, roleId, pos)
  if not self:CheckIsOpenAndToast() then
    return
  end
  if roleId == nil then
    return
  end
  if self.currentVistTreeData == nil then
    return
  end
  if not Int64.eq(roleId, self.currentVistTreeData:GetRoleId()) then
    return
  end
  if not self.currentVistTreeData:IsEmpytyPosition(pos) then
    Toast(textRes.activity.ChristmasTree[6])
    return
  end
  local req = require("netio.protocol.mzm.gsp.christmasstocking.CHangStockingReq").new(roleId, pos)
  gmodule.network.sendProtocol(req)
end
def.method("number").GetChristmasStockAward = function(self, pos)
  if not self:IsFeatureOpen() then
    Toast(textRes.activity.ChristmasTree[1])
    return
  end
  if not self:IsReachFunctionLevel() then
    local openLevel = self:GetActivityOpenLevel()
    Toast(string.format(textRes.activity.ChristmasTree[2], openLevel))
    return
  end
  if self:IsChristmasTreeOver() then
    Toast(textRes.activity.ChristmasTree[14])
    return
  end
  local req = require("netio.protocol.mzm.gsp.christmasstocking.CGetStockingAwardReq").new(pos)
  gmodule.network.sendProtocol(req)
end
def.method().AddTodayHangNum = function(self)
  self.totalHangNum = self.totalHangNum + 1
end
def.method("=>", "boolean").IsTodayFullHangNum = function(self)
  return self.totalHangNum >= constant.CChristmasStockingConsts.ROLE_HANG_MAX_NUM
end
def.method().CheckActivityNotify = function(self)
  if not self:IsOpen() then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Set_RedPoint, {
      activityId = constant.CChristmasStockingConsts.ACTIVITY_ID,
      isShowRedPoint = false
    })
  elseif self:IsTodayFullHangNum() then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Set_RedPoint, {
      activityId = constant.CChristmasStockingConsts.ACTIVITY_ID,
      isShowRedPoint = false
    })
  else
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Set_RedPoint, {
      activityId = constant.CChristmasStockingConsts.ACTIVITY_ID,
      isShowRedPoint = true
    })
  end
end
def.method().UpdateActivityIDIPState = function(self)
  local isOpen = self:IsFeatureOpen()
  local activityId = constant.CChristmasStockingConsts.ACTIVITY_ID
  local ActivityInterface = require("Main.activity.ActivityInterface")
  if isOpen then
    ActivityInterface.Instance():removeCustomCloseActivity(activityId)
  else
    ActivityInterface.Instance():addCustomCloseActivity(activityId)
  end
end
def.method().ResetData = function(self)
  self.totalHangNum = 0
  self.currentVistTreeData = nil
end
return ChristmasTreeMgr.Commit()
