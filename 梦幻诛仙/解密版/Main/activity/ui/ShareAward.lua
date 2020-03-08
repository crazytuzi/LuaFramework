local Lplus = require("Lplus")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local NPCModule = Lplus.ForwardDeclare("NPCModule")
local ShareAward = Lplus.Extend(ECPanelBase, "ShareAward")
local def = ShareAward.define
local Instance
def.field("table").m_AwardCfg = nil
def.field("table").m_UIGO = nil
def.static("=>", ShareAward).Instance = function()
  if not Instance then
    Instance = ShareAward()
  end
  return Instance
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:Update()
end
def.override().OnDestroy = function(self)
  self.m_AwardCfg = nil
  self.m_UIGO = nil
end
def.method("number").InitData = function(self, awardID)
  if awardID ~= 0 then
    self.m_AwardCfg = {}
    local record = DynamicData.GetRecord(CFG_PATH.DATA_SHARE_AWARD, awardID)
    if record then
      self.m_AwardCfg.itemID = record:GetIntValue("giftId")
      self.m_AwardCfg.shareID = record:GetIntValue("shareTitleContentCfg")
      self.m_AwardCfg.desc = record:GetStringValue("description")
    end
  end
end
def.method("number").ShowDlg = function(self, awardID)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:InitData(awardID)
  self:CreatePanel(RESPATH.PREFAB_UI_ACTIVITY_SHARE_QQ, GUILEVEL.MUTEX)
  self:SetModal(true)
end
def.method().InitUI = function(self)
  if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
    GUIUtils.SetText(self.m_panel:FindDirect("Img_Bg/Btn_Left/Label_Btn"), textRes.activity[301])
    GUIUtils.SetText(self.m_panel:FindDirect("Img_Bg/Btn_Right/Label_Btn"), textRes.activity[302])
  end
  self.m_UIGO = {}
  self.m_UIGO.source = self.m_panel:FindDirect("Img_Bg/Img_Item")
end
def.method().Update = function(self)
  local cfg = self.m_AwardCfg
  if cfg then
    local itemBase = ItemUtils.GetItemBase(cfg.itemID)
    GUIUtils.SetText(self.m_panel:FindDirect("Img_Bg/Label_Tips2"), cfg.desc)
    GUIUtils.SetText(self.m_panel:FindDirect("Img_Bg/Img_Item/Label_Name"), itemBase.name)
    GUIUtils.SetTexture(self.m_panel:FindDirect("Img_Bg/Img_Item/Texture"), itemBase.icon)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Left" then
    if not self.m_AwardCfg or not self.m_AwardCfg.shareID then
      return
    end
    RelationShipChainMgr.SendToFriend(MSDK_SHARE_SCENE.SPACE, self.m_AwardCfg.shareID)
    self:DestroyPanel()
  elseif id == "Btn_Right" then
    if not self.m_AwardCfg or not self.m_AwardCfg.shareID then
      return
    end
    RelationShipChainMgr.SendToFriend(MSDK_SHARE_SCENE.SINGEL, self.m_AwardCfg.shareID)
    self:DestroyPanel()
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Img_Item" then
    local source = self.m_UIGO.source
    if not source or not self.m_AwardCfg or not self.m_AwardCfg.itemID then
      return
    end
    local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(self.m_AwardCfg.itemID, source, 0, true)
  end
end
return ShareAward.Commit()
