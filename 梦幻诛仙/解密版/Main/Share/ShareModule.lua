local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local ShareModule = Lplus.Extend(ModuleBase, "ShareModule")
local PlayerPref = require("Main.Common.LuaPlayerPrefs")
local GiftAwardMgr = require("Main.Award.mgr.GiftAwardMgr")
local UseType = require("consts.mzm.gsp.giftaward.confbean.UseType")
local def = ShareModule.define
local instance
def.static("=>", ShareModule).Instance = function()
  if instance == nil then
    instance = ShareModule()
    instance.m_moduleId = ModuleId.WORLD_QUESTION
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.SHARE, gmodule.notifyId.Share.ShareCharacter, ShareModule._OnShareCharacter)
  Event.RegisterEvent(ModuleId.SHARE, gmodule.notifyId.Share.SharePet, ShareModule._OnSharePet)
  Event.RegisterEvent(ModuleId.SHARE, gmodule.notifyId.Share.LUCKYDOG, ShareModule._OnLuckyDog)
  ModuleBase.Init(self)
end
def.static("table", "table")._OnShareCharacter = function(params, context)
  local characterSharePanel = require("Main.Share.ui.CharacterSharePanel").Instance()
  characterSharePanel:ShowSharePanel()
end
def.static("table", "table")._OnSharePet = function(params, context)
  local petSharePanel = require("Main.Share.ui.PetSharePanel").Instance()
  petSharePanel:ShowSharePanel(params.petId)
end
def.static("table", "table")._OnLuckyDog = function(params, context)
  if instance:CanRemind() then
    local BegComment = require("Main.Share.ui.BegComment")
    BegComment.ShowBeg(function(sel)
      if sel == 1 then
        instance:RecordRemind(1)
        instance:Remind()
      else
        instance:RecordRemind(0)
      end
    end)
  end
end
def.method().Remind = function(self)
  local url = _G.ClientCfg.GetStoreUrl(_G.platform)
  if url and url ~= "" then
    Application.OpenURL(url)
  end
end
def.method("=>", "boolean").CanRemind = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_COMMENT_GUIDE) then
    return false
  end
  local url = _G.ClientCfg.GetStoreUrl(_G.platform)
  if url == nil or url == "" then
    return false
  end
  local yesColdDownTime = constant.CCommentGuideConsts.AGREE_COOLDOWN * 3600
  local noColdDownTime = constant.CCommentGuideConsts.REFUSE_COOLDOWN * 3600
  local rate = constant.CCommentGuideConsts.TRIGGER_PROBABILITY
  local stime = GetServerTime()
  if GiftAwardMgr.Instance():CanDraw(UseType.COMMENT_GUIDE__AGREE) and GiftAwardMgr.Instance():CanDraw(UseType.COMMENT_GUIDE__REFUSE) then
    local remindInfo = self:GetRemindInfo()
    local lastRemindTime = remindInfo.lastRemindTime
    local lastSelection = remindInfo.lastSelection
    warn(lastSelection, stime, lastRemindTime, yesColdDownTime, noColdDownTime)
    if lastSelection > 0 then
      if yesColdDownTime < stime - lastRemindTime then
        return rate >= math.random(10000)
      else
        return false
      end
    elseif noColdDownTime < stime - lastRemindTime then
      return rate >= math.random(10000)
    else
      return false
    end
  else
    return false
  end
end
def.method("=>", "table").GetRemindInfo = function(self)
  local remindInfo = {}
  if PlayerPref.HasGlobalKey("RemindMe") then
    warn("RemindMe")
    remindInfo = PlayerPref.GetGlobalTable("RemindMe")
  else
    warn("Empty")
    remindInfo.lastSelection = 0
    remindInfo.lastRemindTime = 0
  end
  return remindInfo
end
def.method("number").RecordRemind = function(self, selection)
  local remindInfo = {}
  remindInfo.lastSelection = selection
  remindInfo.lastRemindTime = GetServerTime()
  PlayerPref.SetGlobalTable("RemindMe", remindInfo)
  PlayerPref.Save()
  if selection == 1 then
    GiftAwardMgr.Instance():DrawAward(UseType.COMMENT_GUIDE__AGREE)
  else
    GiftAwardMgr.Instance():DrawAward(UseType.COMMENT_GUIDE__REFUSE)
  end
end
ShareModule.Commit()
return ShareModule
