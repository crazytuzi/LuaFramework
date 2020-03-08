local Lplus = require("Lplus")
local DeliveryMgr = Lplus.Class("DeliveryMgr")
local InteractiveTaskModule = Lplus.ForwardDeclare("InteractiveTaskModule")
local TeamData = require("Main.Team.TeamData")
local MarriageInterface = require("Main.Marriage.MarriageInterface")
local def = DeliveryMgr.define
def.const("number").SHOW_COMMANDER_UI_SERVICE = 150210027
local instance
def.static("=>", DeliveryMgr).Instance = function()
  if instance == nil then
    instance = DeliveryMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, DeliveryMgr.OnNPCService)
  Event.RegisterEvent(ModuleId.INTERACTIVE_TASK, gmodule.notifyId.InteractiveTask.ENTER_TASK_MAP, DeliveryMgr.OnEnterTaskMap)
end
def.method("=>", "boolean").StartDelivery = function(self)
  if self:CheckStartDeliveryCondition() == false then
    return false
  end
  local taskTypeId = _G.constant.CGivebirthConsts.TASK_TYPE_ID
  InteractiveTaskModule.Instance():BeginInteractiveTask(taskTypeId)
  return true
end
def.method("=>", "boolean").CheckStartDeliveryCondition = function(self)
  local heroProp = require("Main.Hero.mgr.HeroPropMgr").Instance().heroProp
  local GenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  if heroProp.gender ~= GenderEnum.FEMALE then
    print("hero is male")
    Toast(textRes.Children.Delivery[6])
    return false
  end
  local teamData = TeamData.Instance()
  if not teamData:HasTeam() then
    print("self not in team")
    Toast(textRes.Children.Delivery[1])
    return false
  end
  if not teamData:MeIsCaptain() then
    print("self is not captain")
    Toast(textRes.Children.Delivery[2])
    return false
  end
  local mateInfo = MarriageInterface.GetMateInfo()
  if mateInfo == nil then
    warn(string.format("Mateinfo not found onEnterDeliveryRoom"))
    Toast(textRes.Children.Delivery[1])
    return false
  end
  local mateId = mateInfo.mateId
  if not teamData:IsTeamMember(mateId) then
    print("mate not in team")
    Toast(textRes.Children.Delivery[1])
    return false
  end
  local memberCount = teamData:GetMemberCount()
  if memberCount > 2 then
    print("other player in team")
    Toast(textRes.Children.Delivery[3])
    return false
  end
  if teamData:HasLeavingMember() then
    print("mate is leaving")
    Toast(textRes.Children.Delivery[4])
    return false
  end
  if teamData:HasOfflineMember() then
    print("mate is offline")
    Toast(textRes.Children.Delivery[5])
    return false
  end
  return true
end
def.method().ShowHelpfulPrompt = function(self)
  local tipId = _G.constant.CGivebirthConsts.TIP_ID or 701605047
  local MiniGameTip = require("Main.MiniGame.ui.MiniGameTip")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(tipId)
  MiniGameTip.Instance():ShowDlg(tipContent, nil)
end
def.static("table", "table").OnNPCService = function(params, p2)
  local serviceId = params[1]
  local npcId = params[2]
  if serviceId == DeliveryMgr.SHOW_COMMANDER_UI_SERVICE then
    InteractiveTaskModule.Instance():ShowCommanderUI()
  end
end
def.static("table", "table").OnEnterTaskMap = function(params, p2)
  local itaskTypeId = params[1]
  if itaskTypeId ~= _G.constant.CGivebirthConsts.TASK_TYPE_ID then
    return
  end
  instance:ShowHelpfulPrompt()
end
return DeliveryMgr.Commit()
