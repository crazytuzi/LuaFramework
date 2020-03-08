local Lplus = require("Lplus")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local NPCInterface = require("Main.npc.NPCInterface")
local ECPanelBase = require("GUI.ECPanelBase")
local Convoy = Lplus.Extend(ECPanelBase, "Convoy")
local def = Convoy.define
local inst
def.field("boolean").isshowing = false
def.static("=>", Convoy).Instance = function()
  if inst == nil then
    inst = Convoy()
    inst:Init()
  end
  return inst
end
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method().ShowDlg = function(self)
  if self:IsShow() == false then
    self.isshowing = true
    self:CreatePanel(RESPATH.PREFAB_UI_ACTIVITY_HUSONG, 0)
  end
end
def.method().HideDlg = function(self)
  self.isshowing = false
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, Convoy.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, Convoy.OnLeaveFight)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, Convoy.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, Convoy.OnLeaveFight)
  self.isshowing = false
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:Fill()
  else
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Quit" then
    self:OnBtn_Quit()
  end
end
def.method().Fill = function(self)
  if self:IsShow() == false then
    return
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ACTIVITY_CHuSongCfg, activityInterface._husongcfgid)
  if record == nil then
    return
  end
  local HuSongType = require("consts.mzm.gsp.activity.confbean.HuSongType")
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.handupNPCid = record:GetIntValue("handupNPCid")
  cfg.huSongMonsterid = record:GetIntValue("huSongMonsterid")
  cfg.huSongType = record:GetIntValue("huSongType")
  local NPCInterface = require("Main.npc.NPCInterface")
  local npcCfg = NPCInterface.GetNPCCfg(cfg.handupNPCid)
  local PetInterface = require("Main.Pet.Interface")
  local mapRecord = DynamicData.GetRecord(CFG_PATH.DATA_MAP_CONFIG, npcCfg.mapId)
  if mapRecord == nil then
    return nil
  end
  local mapCfg = {}
  mapCfg.mapName = mapRecord:GetStringValue("mapName")
  local Label_Title = self.m_panel:FindDirect("Img_Bg/Label_Title")
  local Label_Content = self.m_panel:FindDirect("Img_Bg/Label_Content")
  Label_Title:GetComponent("UILabel"):set_text(textRes.activity[253])
  local desc = ""
  if cfg.huSongType == HuSongType.SPECIAL then
    if activityInterface.husong_couple_npc_cfgid > 0 then
      local targetNpc = NPCInterface.GetNPCCfg(activityInterface.husong_couple_npc_cfgid)
      desc = string.format(textRes.activity[269], npcCfg.npcName, targetNpc.npcName, npcCfg.npcName)
    end
  else
    local monsCfg = PetInterface.GetMonsterCfg(cfg.huSongMonsterid)
    desc = string.format(textRes.activity[266], monsCfg.name, mapCfg.mapName, npcCfg.npcName)
  end
  Label_Content:GetComponent("UILabel"):set_text(desc)
  if PlayerIsInFight() == true then
    Convoy.OnEnterFight(nil, nil)
  end
end
def.method().OnBtn_Quit = function(self)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirmCoundDown(textRes.activity[253], textRes.activity[265], textRes.Login[105], textRes.Login[106], 0, 10, Convoy.OnConvoyGivupConfirm, {self})
end
def.static("number", "table").OnConvoyGivupConfirm = function(id, tag)
  if id == 1 then
    local p = require("netio.protocol.mzm.gsp.activity.CHuSongGiveup").new()
    gmodule.network.sendProtocol(p)
  end
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  local self = inst
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  Img_Bg:SetActive(false)
  local Img_FxBg = self.m_panel:FindDirect("Img_FxBg")
  Img_FxBg:SetActive(false)
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  local self = inst
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  Img_Bg:SetActive(true)
  local Img_FxBg = self.m_panel:FindDirect("Img_FxBg")
  Img_FxBg:SetActive(true)
end
Convoy.Commit()
return Convoy
