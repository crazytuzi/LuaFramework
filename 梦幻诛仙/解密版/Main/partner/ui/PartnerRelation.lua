local Lplus = require("Lplus")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local PartnerRelation = Lplus.Extend(ECPanelBase, "PartnerRelation")
local def = PartnerRelation.define
local inst
local PartnerInterface = require("Main.partner.PartnerInterface")
local partnerInterface = PartnerInterface.Instance()
local PersonalHelper = require("Main.Chat.PersonalHelper")
def.static("=>", PartnerRelation).Instance = function()
  if inst == nil then
    inst = PartnerRelation()
    inst:Init()
  end
  return inst
end
def.field("number")._partnerID = 0
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method("number").ShowDlg = function(self, partnerID)
  self._partnerID = partnerID
  if self.m_panel == nil or self.m_panel.isnil then
    print("PartnerMain CreatePanel()")
    self:CreatePanel(RESPATH.PREFAB_UI_PARTNER_RELATION, 2)
    self:SetModal(true)
  end
end
def.method().HideDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:Fill()
    Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, PartnerRelation.OnMoneyChanged)
    Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, PartnerRelation.OnMoneyChanged)
    Event.RegisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LovesDataChanged, PartnerRelation.OnPartnerLovesDataChanged)
    Event.RegisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_ReadyLovesDataChanged, PartnerRelation.OnPartnerReadyLovesDataChanged)
  else
    Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, PartnerRelation.OnMoneyChanged)
    Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, PartnerRelation.OnMoneyChanged)
    Event.UnregisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LovesDataChanged, PartnerRelation.OnPartnerLovesDataChanged)
    Event.UnregisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_ReadyLovesDataChanged, PartnerRelation.OnPartnerReadyLovesDataChanged)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:HideDlg()
    return
  end
  local fnTable = {}
  fnTable.Btn_Replace = PartnerRelation.OnBtnReplace
  fnTable.Btn_Wash = PartnerRelation.OnBtnWash
  fnTable.Btn_AddSilver = PartnerRelation.OnBtnAddSilver
  fnTable.Btn_Tips = PartnerRelation.OnBtnTips
  local fn = fnTable[id]
  if fn ~= nil then
    fn(self)
  end
end
def.method().Fill = function(self)
  self:_FillCurrent()
  self:_FillLoveToReplace()
  self:_FillMoney()
end
def.method()._FillCurrent = function(self)
  local Group_Current = self.m_panel:FindDirect("Img_Bg/Group_Current")
  for i = 1, 2 do
    local Label_Name = Group_Current:FindDirect(string.format("Label_Name%d", i))
    local Label_Content = Group_Current:FindDirect(string.format("Label_Content%d", i))
    Label_Name:GetComponent("UILabel"):set_text("")
    Label_Content:GetComponent("UILabel"):set_text("")
  end
  local i = 0
  local LoveInfos = partnerInterface:GetPartnerLoveInfos(self._partnerID)
  if LoveInfos ~= nil then
    for k, v in pairs(LoveInfos) do
      i = i + 1
      local Label_Name = Group_Current:FindDirect(string.format("Label_Name%d", i))
      local Label_Content = Group_Current:FindDirect(string.format("Label_Content%d", i))
      local Text_Head = Group_Current:FindDirect(string.format("Img_Head%d/Text_Head", i))
      local uiTexture = Text_Head:GetComponent("UITexture")
      local LoveDataCfg = PartnerInterface.GetPartnerLoveDataCfg(v)
      if LoveDataCfg ~= nil then
        local color = Color.Color(1, 1, 1, 1)
        if LoveDataCfg.loveRank == 0 then
          color = Color.Color(constant.PartnerConstants.loveRankLowFontColorR / 255, constant.PartnerConstants.loveRankLowFontColorG / 255, constant.PartnerConstants.loveRankLowFontColorB / 255, 1)
        elseif LoveDataCfg.loveRank == 1 then
          color = Color.Color(constant.PartnerConstants.loveRankNormalFontColorR / 255, constant.PartnerConstants.loveRankNormalFontColorG / 255, constant.PartnerConstants.loveRankNormalFontColorB / 255, 1)
        elseif LoveDataCfg.loveRank == 2 then
          color = Color.Color(constant.PartnerConstants.loveRankHighFontColorR / 255, constant.PartnerConstants.loveRankHighFontColorG / 255, constant.PartnerConstants.loveRankHighFontColorB / 255, 1)
        end
        Label_Name:GetComponent("UILabel"):set_text(LoveDataCfg.loveName)
        Label_Name:GetComponent("UILabel"):set_textColor(color)
        Label_Content:GetComponent("UILabel"):set_text(LoveDataCfg.loveDes)
        Text_Head:SetActive(true)
        GUIUtils.FillIcon(uiTexture, LoveDataCfg.loveIconId)
      else
        Label_Name:GetComponent("UILabel"):set_text("")
        Label_Name:GetComponent("UILabel"):set_textColor(Color.Color(1, 1, 1, 1))
        Label_Content:GetComponent("UILabel"):set_text("")
        Text_Head:SetActive(false)
      end
    end
  end
end
def.method()._FillLoveToReplace = function(self)
  local Group_Result1 = self.m_panel:FindDirect("Img_Bg/Group_Result1")
  local Group_Result2 = self.m_panel:FindDirect("Img_Bg/Group_Result2")
  local LoveToReplace = partnerInterface:GetReadyLovesToReplace(self._partnerID)
  for i = 1, 2 do
    local Label_Name = Group_Result2:FindDirect(string.format("Label_Name%d", i))
    local Label_Content = Group_Result2:FindDirect(string.format("Label_Content%d", i))
    Label_Name:GetComponent("UILabel"):set_text("")
    Label_Content:GetComponent("UILabel"):set_text("")
  end
  local Btn_Replace = self.m_panel:FindDirect("Img_Bg/Gruop_Btn/Btn_Replace")
  local loveCount = 0
  if LoveToReplace ~= nil then
    for k, v in pairs(LoveToReplace) do
      loveCount = loveCount + 1
      local Label_Name = Group_Result2:FindDirect(string.format("Label_Name%d", loveCount))
      local Label_Content = Group_Result2:FindDirect(string.format("Label_Content%d", loveCount))
      local LoveDataCfg = PartnerInterface.GetPartnerLoveDataCfg(v)
      if LoveDataCfg ~= nil then
        local color = Color.Color(1, 1, 1, 1)
        if LoveDataCfg.loveRank == 0 then
          color = Color.Color(constant.PartnerConstants.loveRankLowFontColorR / 255, constant.PartnerConstants.loveRankLowFontColorG / 255, constant.PartnerConstants.loveRankLowFontColorB / 255, 1)
        elseif LoveDataCfg.loveRank == 1 then
          color = Color.Color(constant.PartnerConstants.loveRankNormalFontColorR / 255, constant.PartnerConstants.loveRankNormalFontColorG / 255, constant.PartnerConstants.loveRankNormalFontColorB / 255, 1)
        elseif LoveDataCfg.loveRank == 2 then
          color = Color.Color(constant.PartnerConstants.loveRankHighFontColorR / 255, constant.PartnerConstants.loveRankHighFontColorG / 255, constant.PartnerConstants.loveRankHighFontColorB / 255, 1)
        end
        Label_Name:GetComponent("UILabel"):set_text(LoveDataCfg.loveName)
        Label_Name:GetComponent("UILabel"):set_textColor(color)
        Label_Content:GetComponent("UILabel"):set_text(LoveDataCfg.loveDes)
      else
        Label_Name:GetComponent("UILabel"):set_text("")
        Label_Name:GetComponent("UILabel"):set_textColor(Color.Color(1, 1, 1, 1))
        Label_Content:GetComponent("UILabel"):set_text("")
      end
    end
  end
  Group_Result1:SetActive(loveCount == 0)
  Group_Result2:SetActive(loveCount ~= 0)
  Btn_Replace:GetComponent("UIButton"):set_isEnabled(loveCount ~= 0)
end
def.method()._FillMoney = function(self)
  local ItemModule = require("Main.Item.ItemModule")
  local itemModule = gmodule.moduleMgr:GetModule(ModuleId.ITEM)
  local gold = itemModule:GetMoney(ItemModule.MONEY_TYPE_GOLD)
  local Label_Coin = self.m_panel:FindDirect("Img_Bg/Img_BgHaveCoin/Label_Coin")
  if gold:lt(constant.PartnerConstants.Partner_WASHGOLD_NUM) then
    Label_Coin:GetComponent("UILabel"):set_text("[ff0000]" .. tostring(gold) .. "[-]")
  else
    Label_Coin:GetComponent("UILabel"):set_text(tostring(gold))
  end
  local Label_Coin = self.m_panel:FindDirect("Img_Bg/Img_BgNeedCoin/Label_Coin")
  Label_Coin:GetComponent("UILabel"):set_text(tostring(constant.PartnerConstants.Partner_WASHGOLD_NUM))
end
def.method().OnBtnReplace = function(self)
  local CReplaceLovesReq = require("netio.protocol.mzm.gsp.partner.CReplaceLovesReq").new(self._partnerID)
  gmodule.network.sendProtocol(CReplaceLovesReq)
end
def.method().OnBtnWash = function(self)
  local ItemModule = require("Main.Item.ItemModule")
  local itemModule = gmodule.moduleMgr:GetModule(ModuleId.ITEM)
  local gold = itemModule:GetMoney(ItemModule.MONEY_TYPE_GOLD)
  if gold:lt(constant.PartnerConstants.Partner_WASHGOLD_NUM) then
    local personAward = {}
    table.insert(personAward, {
      PersonalHelper.Type.Text,
      textRes.Partner[13]
    })
    table.insert(personAward, {
      PersonalHelper.Type.Gold,
      constant.PartnerConstants.Partner_WASHGOLD_NUM
    })
    PersonalHelper.CommonTableMsg(personAward)
    return
  end
  local CShuffleLovesReq = require("netio.protocol.mzm.gsp.partner.CShuffleLovesReq").new(inst._partnerID)
  gmodule.network.sendProtocol(CShuffleLovesReq)
end
def.static("number", "table").OnDoWashConfirm = function(id, tag)
  if id == 1 then
    local CShuffleLovesReq = require("netio.protocol.mzm.gsp.partner.CShuffleLovesReq").new(inst._partnerID)
    gmodule.network.sendProtocol(CShuffleLovesReq)
  end
end
def.method().OnBtnAddSilver = function(self)
  GoToBuyGold(false)
end
def.method().OnBtnTips = function(self)
  require("Main.partner.ui.PartnerTips").Instance():ShowDlg(self._partnerID)
end
def.static("table", "table").OnMoneyChanged = function(p1, p2)
  inst:_FillMoney()
end
def.static("table", "table").OnPartnerLovesDataChanged = function(p1, p2)
  inst:_FillCurrent()
end
def.static("table", "table").OnPartnerReadyLovesDataChanged = function(p1, p2)
  inst:_FillLoveToReplace()
end
PartnerRelation.Commit()
return PartnerRelation
