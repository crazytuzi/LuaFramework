local Lplus = require("Lplus")
local WingInterface = Lplus.Class("WingInterface")
local WingModule = require("Main.Wing.WingModule")
local WingUtils = require("Main.Wing.WingUtils")
local def = WingInterface.define
def.static("=>", "boolean").InWingOpen = function()
  return WingModule.Instance():IsWingSetup()
end
def.static("number").OpenWingPanel = function(tab)
  if WingModule.Instance():IsWingSetup() then
    require("Main.Wing.ui.WingPanel").ShowWingPanel(tab)
  else
    Toast(textRes.Wing[34])
  end
end
def.static("=>", "number").GetCurWingLevel = function()
  if WingModule.Instance():IsWingSetup() then
    return WingModule.Instance():GetWingData():GetLevel()
  else
    return 0
  end
end
def.static("=>", "number").GetCurWingPhase = function()
  if WingModule.Instance():IsWingSetup() then
    return WingModule.Instance():GetWingData():GetPhase()
  else
    return 0
  end
end
def.static("=>", "number").GetCurWingItemId = function()
  if not WingModule.Instance():IsWingSetup() then
    return 0
  end
  local curWingId = WingModule.Instance():GetWingData():GetCurWingId()
  if curWingId > 0 then
    local outlookCfg = WingUtils.GetWingOutlookCfgByWingId(curWingId)
    return outlookCfg.fakeItemId
  else
    return constant.WingConsts.WING_FAKE_ITEM_ID
  end
end
def.static("=>", "number").GetCurWingId = function()
  if WingModule.Instance():IsWingSetup() then
    local wingData = WingModule.Instance():GetWingData()
    return wingData:GetCurWingId()
  else
    return 0
  end
end
def.static("=>", "table").GetCurWing = function()
  if WingModule.Instance():IsWingSetup() then
    local wingData = WingModule.Instance():GetWingData()
    return wingData:GetCurWing()
  else
    return nil
  end
end
def.static("=>", "number", "number").GetCurWingOutLookAndColorId = function()
  if WingModule.Instance():IsWingSetup() then
    local wingData = WingModule.Instance():GetWingData()
    local curWingId = wingData:GetCurWingId()
    if curWingId > 0 then
      local wing = wingData:GetWingByWingId(curWingId)
      local id = wing.id
      local colorId = wing.colorId
      local wingCfg = WingUtils.GetWingCfg(id)
      local outlook = wingCfg.outlook
      return outlook, colorId
    else
      return 0, 0
    end
  else
    return 0, 0
  end
end
def.static("number").ShowWingDye = function(wingId)
  if WingModule.Instance():IsWingSetup() then
    WingModule.Instance():ShowDyeWingPanel(wingId)
  end
end
def.static("userdata", "number").CheckWing = function(roleId, wingId)
  WingModule.Instance():CheckOtherWing(roleId, wingId)
end
def.static().CheckMyWing = function()
  if WingModule.Instance():IsWingSetup() then
    local wingData = WingModule.Instance():GetWingData()
    local fakeProtocol = {}
    fakeProtocol.roleId = GetMyRoleID()
    fakeProtocol.curLv = wingData:GetLevel()
    fakeProtocol.curRank = wingData:GetPhase()
    fakeProtocol.checkWing = wingData:GetCurWingId()
    fakeProtocol.wings = {}
    for k, v in pairs(wingData.wings) do
      local wing = {}
      wing.cfgId = v.id
      wing.colorId = v.colorId
      wing.propIds = v.props
      wing.skills = v.skills
      fakeProtocol.wings[k] = wing
    end
    WingModule.OnSCheckWingsRep(fakeProtocol)
  end
end
def.static("=>", "boolean").HasWingNotify = function(self)
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_WING_OCC_PLAN) then
    return false
  end
  local wingData = WingModule.Instance():GetWingData()
  if wingData then
    local isNewOpend = wingData:isNewOpend()
    local newPlans = wingData:GetNewOccPlans()
    return isNewOpend or #newPlans > 0
  end
  return false
end
return WingInterface.Commit()
