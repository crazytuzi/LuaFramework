local Lplus = require("Lplus")
local ChildrenInterface = Lplus.Class("ChildrenInterface")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local def = ChildrenInterface.define
def.static("userdata").OpenChildGrow = function(cid)
  gmodule.moduleMgr:GetModule(ModuleId.CHILDREN):OpenGrowPanel(cid)
end
def.static("userdata").PickUpChild = function(cid)
  gmodule.moduleMgr:GetModule(ModuleId.CHILDREN):PickUpChild(cid)
end
def.static("userdata").OpenChildrenBag = function(cid)
  if not ChildrenInterface.CheckFunctionOpenAndToast() then
    return
  end
  require("Main.Children.ui.ChildrenBagPanel").ShowChildrenBag(cid)
end
def.static("userdata").AbandonChildWithConfirm = function(cid)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local CaptchaConfirmDlg = require("GUI.CaptchaConfirmDlg")
  local child = ChildrenDataMgr.Instance():GetChildById(cid)
  if child == nil then
    print(string.format("OnAbandonChild: child not found for cid = %s", tostring(cid)))
    return
  end
  local ownerId = child:GetOwner()
  local myRoleId = _G.GetMyRoleID()
  if ownerId ~= myRoleId then
    Toast(textRes.Children[4005])
    return
  end
  local function showCaptchaConfirm(callback)
    CaptchaConfirmDlg.ShowConfirm(textRes.Children[4002], "", textRes.Children[4003], nil, callback, nil)
  end
  CommonConfirmDlg.ShowConfirm(textRes.Children[4000], textRes.Children[4001], function(s)
    if s == 1 then
      showCaptchaConfirm(function(s2)
        if s2 == 1 then
          gmodule.moduleMgr:GetModule(ModuleId.CHILDREN):ExileChild(cid)
        end
      end)
    end
  end, nil)
end
def.static("userdata").ChildComeToMe = function(cid)
  gmodule.moduleMgr:GetModule(ModuleId.CHILDREN):ChildComeToMe(cid)
end
def.static("=>", "number").GetCurrentSingleQiuziScore = function(self)
  local phaseData = require("Main.Children.data.GetBabyPhaseData").Instance()
  if phaseData:IsSingleBreeding() then
    return phaseData:GetCurrentBreedScore()
  else
    return 0
  end
end
def.static("=>", "number").GetMaxSingleQiuziScore = function()
  local GetBabyPhaseData = require("Main.Children.data.GetBabyPhaseData")
  return GetBabyPhaseData.SINGLE_PHASE_SCORE
end
def.static("number", "=>", "table").GetChildAnimationByPhase = function(phase)
  return textRes.Children.ChildAnimation[phase]
end
def.static("=>", "boolean").IsFunctionOpen = function()
  if not ChildrenInterface.IsFunctionFeatureOpen() then
    return false
  end
  if not ChildrenInterface.IsReachFunctionOpenLevel() then
    return false
  end
  return true
end
def.static("=>", "boolean").CheckFunctionOpenAndToast = function()
  if not ChildrenInterface.IsFunctionFeatureOpen() then
    Toast(textRes.Children[1042])
    return false
  end
  if not ChildrenInterface.IsReachFunctionOpenLevel() then
    Toast(string.format(textRes.Children[1041], constant.CChildrenConsts.children_function_open_level))
    return false
  end
  return true
end
def.static("=>", "boolean").IsReachFunctionOpenLevel = function()
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  if heroProp == nil then
    return false
  end
  return heroProp.level >= constant.CChildrenConsts.children_function_open_level
end
def.static("=>", "boolean").IsFunctionFeatureOpen = function()
  local isOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHILDREN)
  return isOpen
end
def.static("=>", "boolean").CheckChildhoodPhaseOpenAndToast = function(self)
  if not ChildrenInterface.IsChildhoodPhaseOpen() then
    Toast(textRes.Children[7])
    return false
  end
  return true
end
def.static("=>", "boolean").IsChildhoodPhaseOpen = function()
  local isOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHILDHOOD)
  return isOpen
end
def.static("=>", "boolean").IsRecallOpen = function()
  local isOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHILDREN_RECALL)
  return isOpen
end
def.static("=>", "boolean").CheckAdultPhaseOpenAndToast = function(self)
  if not ChildrenInterface.IsAdultPhaseOpen() then
    Toast(textRes.Children[8])
    return false
  end
  return true
end
def.static("=>", "boolean").IsAdultPhaseOpen = function()
  local isOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_ADULT)
  return isOpen
end
local function queryToShowPanel(p)
  local data = ChildrenDataMgr.MakeChild(p.child_bean)
  if data then
    local birthTime = p.child_give_birth_time
    local nameList = {}
    for _, v in ipairs(p.parents_name_list) do
      table.insert(nameList, GetStringFromOcts(v))
    end
    require("Main.Children.ui.ChildShow").ShowChildren(data, nameList, birthTime)
  end
end
def.static("string").RequestChildInfoChat = function(linkStr)
  local childId = Int64.new(string.sub(linkStr, 7))
  if childId then
    gmodule.moduleMgr:GetModule(ModuleId.CHILDREN):QueryChild(childId, queryToShowPanel)
  end
end
def.static("userdata").RequestChildInfo = function(cid)
  if cid then
    gmodule.moduleMgr:GetModule(ModuleId.CHILDREN):QueryChild(cid, queryToShowPanel)
  end
end
def.static("=>", "table").GetAllBagChildren = function()
  return require("Main.Children.ChildrenDataMgr").Instance():GetChildrenInBagSort()
end
def.static("userdata", "=>", "table").GetChildById = function(cid)
  return require("Main.Children.ChildrenDataMgr").Instance():GetChildById(cid)
end
def.static("=>", "table").GetInFightSceneChild = function()
  return require("Main.Children.ChildrenDataMgr").Instance():GetInFightSceneChild()
end
return ChildrenInterface.Commit()
