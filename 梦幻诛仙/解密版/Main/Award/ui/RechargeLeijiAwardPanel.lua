local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local RechargeLeijiAwardPanel = Lplus.Extend(ECPanelBase, "RechargeLeijiAwardPanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
local ItemModule = require("Main.Item.ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local RechargeLeijiMgr = require("Main.Award.mgr.RechargeLeijiMgr")
local def = RechargeLeijiAwardPanel.define
def.field("table")._uiObjs = nil
def.field("table")._items = nil
local instance
def.static("=>", RechargeLeijiAwardPanel).Instance = function()
  if instance == nil then
    instance = RechargeLeijiAwardPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_RECHARGE_LEIJI_PANEL, 0)
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  self:InitUI()
  self:UpdateRechargeStatus()
  self:UpdateRechareAwardItems()
  RechargeLeijiMgr.Instance():MarkAsKnowAboutThisAward()
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.RECHARGE_LEIJI_AWARD_UPDATE, RechargeLeijiAwardPanel.UpdateRechargeLeijiInfo)
end
def.override().OnDestroy = function(self)
  self._uiObjs = nil
  self._items = nil
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.RECHARGE_LEIJI_AWARD_UPDATE, RechargeLeijiAwardPanel.UpdateRechargeLeijiInfo)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  warn(id)
  if id == "Btn_Recharge" then
    self:GoToRecharge()
  elseif id == "Btn_LingQu" then
    self:ReceiveAward()
  elseif string.find(id, "Img_BgIcon") == 1 then
    local idx = tonumber(string.sub(id, 11))
    self:ShowAwardItemTips(idx, obj)
  end
end
def.method().GoToRecharge = function(self)
  if RechargeLeijiMgr.Instance():IsOpen() then
    self:DestroyPanel()
    local MallPanel = require("Main.Mall.ui.MallPanel")
    require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.RECHARGEORRECEIVEAWARD, {1})
  else
    Toast(textRes.Award[78])
  end
end
def.method().ReceiveAward = function(self)
  RechargeLeijiMgr.Instance():GetRechargeLeijiAward()
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.RECHARGEORRECEIVEAWARD, {2})
end
def.method("number", "userdata").ShowAwardItemTips = function(self, idx, source)
  local itemId = self._items[idx].itemId
  ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, source, 0, false)
end
def.method().InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Btn_Recharge = self.m_panel:FindDirect("Btn_Recharge")
  self._uiObjs.Btn_LingQu = self.m_panel:FindDirect("Btn_LingQu")
  self._uiObjs.Label_Num = self.m_panel:FindDirect("Label_Num")
  self._uiObjs.Img_HaveChong = self.m_panel:FindDirect("Img_HaveChong")
  self._uiObjs.Grid_Items = self.m_panel:FindDirect("Grid_Items")
  self._uiObjs.AwardTips = self.m_panel:FindDirect("Label1")
  self._uiObjs.AwardLabel = self.m_panel:FindDirect("Label2")
end
def.method().UpdateRechargeStatus = function(self)
  local rechargeLeijiMgr = RechargeLeijiMgr.Instance()
  if RechargeLeijiMgr.Instance():HasNextRechargeAward() then
    local recharge = rechargeLeijiMgr:GetNextRechargeCfg()
    local totalRecharge = tonumber(ItemModule.Instance():GetYuanbao(ItemModule.CASH_SAVE_AMT):tostring()) - tonumber(rechargeLeijiMgr:GetBaseSaveAmt():tostring())
    local needYuanBao = recharge.saveAmt - totalRecharge
    if needYuanBao > 0 then
      self._uiObjs.AwardTips:SetActive(true)
      self._uiObjs.Label_Num:SetActive(true)
      self._uiObjs.Img_HaveChong:SetActive(false)
      self._uiObjs.Btn_Recharge:SetActive(true)
      self._uiObjs.Btn_LingQu:SetActive(false)
      GUIUtils.SetText(self._uiObjs.Label_Num, needYuanBao)
      GUIUtils.SetText(self._uiObjs.AwardLabel, string.format(textRes.Award[71], recharge.desc))
    else
      self._uiObjs.AwardTips:SetActive(false)
      GUIUtils.SetText(self._uiObjs.AwardLabel, textRes.Award[74])
      self._uiObjs.Label_Num:SetActive(false)
      self._uiObjs.Img_HaveChong:SetActive(false)
      self._uiObjs.Btn_Recharge:SetActive(false)
      self._uiObjs.Btn_LingQu:SetActive(true)
    end
  else
    self._uiObjs.AwardTips:SetActive(false)
    GUIUtils.SetText(self._uiObjs.AwardLabel, textRes.Award[74])
    self._uiObjs.Label_Num:SetActive(false)
    self._uiObjs.Img_HaveChong:SetActive(true)
    self._uiObjs.Btn_Recharge:SetActive(false)
    self._uiObjs.Btn_LingQu:SetActive(false)
  end
end
def.method().UpdateRechareAwardItems = function(self)
  if RechargeLeijiMgr.Instance():HasNextRechargeAward() then
    local awardItems = RechargeLeijiMgr.Instance():GetAwardItems()
    self._items = awardItems
    for idx, awardCfg in pairs(awardItems) do
      local itemBase = ItemUtils.GetItemBase(awardCfg.itemId)
      local award = self._uiObjs.Grid_Items:FindDirect("Img_BgIcon" .. idx)
      local awardName = award:FindDirect("Label_Name2")
      local awardIcon = award:FindDirect("Texture_Icon")
      local awarnNum = award:FindDirect("Label_Num")
      local itemName = itemBase.name
      local HtmlHelper = require("Main.Chat.HtmlHelper")
      local color = HtmlHelper.NameColor[namecolor]
      if color then
        itemName = string.format("[%s]%s[-]", color, itemName)
      end
      GUIUtils.SetText(awardName, itemName)
      GUIUtils.SetText(awarnNum, awardCfg.num)
      GUIUtils.SetTexture(awardIcon, itemBase.icon)
      awardIcon.name = "Texture_Icon_" .. awardCfg.itemId
    end
  end
  local awardCount = 0
  if self._items ~= nil then
    awardCount = #self._items
  end
  local totoalItemCount = self._uiObjs.Grid_Items.childCount
  for i = awardCount + 1, totoalItemCount do
    local award = self._uiObjs.Grid_Items:FindDirect("Img_BgIcon" .. i)
    GameObject.Destroy(award)
  end
end
def.static("table", "table").UpdateRechargeLeijiInfo = function(params, context)
  instance:UpdateRechargeStatus()
  instance:UpdateRechareAwardItems()
end
return RechargeLeijiAwardPanel.Commit()
