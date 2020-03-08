local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetMarkLotteryAwardPanel = Lplus.Extend(ECPanelBase, "PetMarkLotteryAwardPanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local PetMarkMgr = require("Main.Pet.PetMark.PetMarkMgr")
local AwardItemTipHelper = require("Main.Award.AwardItemTipHelper")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local def = PetMarkLotteryAwardPanel.define
def.field("number").lotteryType = 0
def.field("table").awardItems = nil
def.field(AwardItemTipHelper).itemTipHelper = nil
local instance
def.static("=>", PetMarkLotteryAwardPanel).Instance = function()
  if instance == nil then
    instance = PetMarkLotteryAwardPanel()
  end
  return instance
end
def.method("number", "table").ShowAwards = function(self, lotteryType, items)
  if self:IsShow() then
    return
  end
  if items == nil then
    warn("PetMarkLotteryAwardPanel params award items is nil")
    return
  end
  self.lotteryType = lotteryType
  self.awardItems = items
  if #items == 1 then
    self:CreatePanel(RESPATH.PREFAB_PET_MARK_LOTTERY_ONE_PANEL, 2)
  else
    self:CreatePanel(RESPATH.PREFAB_PET_MARK_LOTTERY_TEN_PANEL, 2)
  end
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self.itemTipHelper = AwardItemTipHelper()
  self:ShowAwardItems()
  self:DrawAward()
end
def.override().OnDestroy = function(self)
  self.lotteryType = 0
  self.awardItems = nil
  self.itemTipHelper = nil
end
def.method().ShowAwardItems = function(self)
  if #self.awardItems == 1 then
    self:ShowOneAward()
  elseif #self.awardItems == 10 then
    self:ShowTenAwards()
  end
end
def.method().ShowOneAward = function(self)
  local Group_One = self.m_panel:FindDirect("Img_Bg0/Group_One")
  local Effect_Ten = Group_One:FindDirect("Effect_Ten")
  local Group_Item = Group_One:FindDirect("Group_Item")
  local Img_BgItem = Group_Item:FindDirect("Img_BgItem")
  local Icon_Item = Img_BgItem:FindDirect("Icon_Item")
  local Label_Name = Group_Item:FindDirect("Label_Name")
  local itemData = self.awardItems[1]
  local itemId = itemData.item_cfg_id
  local itemBase = ItemUtils.GetItemBase(itemId)
  GUIUtils.SetTexture(Icon_Item, itemBase.icon)
  GUIUtils.SetItemCellSprite(Img_BgItem, itemBase.namecolor)
  GUIUtils.SetText(Label_Name, string.format("[%s]%s[-]", HtmlHelper.NameColor[itemBase.namecolor], itemBase.name))
  self.itemTipHelper:RegisterItem2ShowTip(itemId, Group_Item)
  local Group_Out = self.m_panel:FindDirect("Img_Bg0/Group_Out")
  local Btn_Again = Group_Out:FindDirect("Btn_Again")
  local Label_Name = Btn_Again:FindDirect("Label_Name")
  local Label_Num = Btn_Again:FindDirect("Label_Num")
  local tokenCfg
  local tokenNum = 0
  local CPetMarkLotteryDrawReq = require("netio.protocol.mzm.gsp.petmark.CPetMarkLotteryDrawReq")
  if self.lotteryType == CPetMarkLotteryDrawReq.LOTTERY_TYPE1 then
    tokenCfg = ItemUtils.GetTokenCfg(TokenType.PET_MARK_SCORE1)
    tokenNum = constant.CPetMarkConstants.LOTTERY_COST1
  elseif self.lotteryType == CPetMarkLotteryDrawReq.LOTTERY_TYPE2 then
    tokenCfg = ItemUtils.GetTokenCfg(TokenType.PET_MARK_SCORE2)
    tokenNum = constant.CPetMarkConstants.LOTTERY_COST2
  end
  GUIUtils.SetText(Label_Name, tokenCfg.name .. "\239\188\154")
  GUIUtils.SetText(Label_Num, tokenNum)
end
def.method().ShowTenAwards = function(self)
  local Group_Ten = self.m_panel:FindDirect("Img_Bg0/Group_Ten")
  local Effect_Ten = Group_Ten:FindDirect("Effect_Ten")
  local Group_Items = Group_Ten:FindDirect("Group_Items")
  for i = 1, 10 do
    local uiItem = Group_Items:FindDirect("Img_BgIcon" .. i)
    if self.awardItems[i] then
      GUIUtils.SetActive(uiItem, true)
      local Texture_Icon = uiItem:FindDirect("Texture_Icon")
      local Img_New = uiItem:FindDirect("Img_New")
      local Img_Tpye = uiItem:FindDirect("Img_Tpye")
      local Label_Name = uiItem:FindDirect("Label_Name")
      local itemData = self.awardItems[i]
      local itemId = itemData.item_cfg_id
      local itemBase = ItemUtils.GetItemBase(itemId)
      GUIUtils.SetTexture(Texture_Icon, itemBase.icon)
      GUIUtils.SetItemCellSprite(uiItem, itemBase.namecolor)
      GUIUtils.SetText(Label_Name, string.format("[%s]%s[-]", HtmlHelper.NameColor[itemBase.namecolor], itemBase.name))
      GUIUtils.SetActive(Img_New, false)
      GUIUtils.SetActive(Img_Tpye, false)
      self.itemTipHelper:RegisterItem2ShowTip(itemId, uiItem)
    else
      GUIUtils.SetActive(uiItem, false)
    end
  end
  local Group_Out = self.m_panel:FindDirect("Img_Bg0/Group_Out")
  local Btn_Again = Group_Out:FindDirect("Btn_Again")
  local Label_Name = Btn_Again:FindDirect("Label_Name")
  local Label_Num = Btn_Again:FindDirect("Label_Num")
  local tokenCfg
  local tokenNum = 0
  local CPetMarkLotteryDrawReq = require("netio.protocol.mzm.gsp.petmark.CPetMarkLotteryDrawReq")
  if self.lotteryType == CPetMarkLotteryDrawReq.LOTTERY_TYPE1 then
    tokenCfg = ItemUtils.GetTokenCfg(TokenType.PET_MARK_SCORE1)
    tokenNum = constant.CPetMarkConstants.TEN_LOTTERY_COST1
  elseif self.lotteryType == CPetMarkLotteryDrawReq.LOTTERY_TYPE2 then
    tokenCfg = ItemUtils.GetTokenCfg(TokenType.PET_MARK_SCORE2)
    tokenNum = constant.CPetMarkConstants.TEN_LOTTERY_COST2
  end
  GUIUtils.SetText(Label_Name, tokenCfg.name .. "\239\188\154")
  GUIUtils.SetText(Label_Num, tokenNum)
end
def.method().DrawAward = function(self)
  PetMarkMgr.Instance():DrawLotteryAward()
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  warn(id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Conform" then
    self:DestroyPanel()
  elseif id == "Btn_Again" then
    self:OnClickDrawLotteryAgain()
  else
    self.itemTipHelper:CheckItem2ShowTip(id)
  end
end
def.method().OnClickDrawLotteryAgain = function(self)
  local CPetMarkLotteryDrawReq = require("netio.protocol.mzm.gsp.petmark.CPetMarkLotteryDrawReq")
  local ret = true
  if self.lotteryType == CPetMarkLotteryDrawReq.LOTTERY_TYPE1 then
    if #self.awardItems == 1 then
      ret = self:DrawLotteryCommonOne()
    elseif #self.awardItems == 10 then
      ret = self:DrawLotteryCommonTen()
    end
  elseif self.lotteryType == CPetMarkLotteryDrawReq.LOTTERY_TYPE2 then
    if #self.awardItems == 1 then
      ret = self:DrawLotteryHighOne()
    elseif #self.awardItems == 10 then
      ret = self:DrawLotteryHighTen()
    end
  end
  if ret then
    self:DestroyPanel()
  end
end
def.method("=>", "boolean").DrawLotteryCommonOne = function(self)
  local tokenNum = ItemModule.Instance():GetCredits(TokenType.PET_MARK_SCORE1)
  if Int64.lt(tokenNum, constant.CPetMarkConstants.LOTTERY_COST1) then
    Toast(textRes.Pet.PetMark[26])
    return false
  end
  PetMarkMgr.Instance():DrawLotteryCommonOne()
  return true
end
def.method("=>", "boolean").DrawLotteryCommonTen = function(self)
  local tokenNum = ItemModule.Instance():GetCredits(TokenType.PET_MARK_SCORE1)
  if Int64.lt(tokenNum, constant.CPetMarkConstants.TEN_LOTTERY_COST1) then
    Toast(textRes.Pet.PetMark[26])
    return false
  end
  PetMarkMgr.Instance():DrawLotteryCommonTen()
  return true
end
def.method("=>", "boolean").DrawLotteryHighOne = function(self)
  local tokenNum = ItemModule.Instance():GetCredits(TokenType.PET_MARK_SCORE2)
  if Int64.lt(tokenNum, constant.CPetMarkConstants.LOTTERY_COST2) then
    Toast(textRes.Pet.PetMark[26])
    return false
  end
  PetMarkMgr.Instance():DrawLotteryHighOne()
  return true
end
def.method("=>", "boolean").DrawLotteryHighTen = function(self)
  local tokenNum = ItemModule.Instance():GetCredits(TokenType.PET_MARK_SCORE2)
  if Int64.lt(tokenNum, constant.CPetMarkConstants.TEN_LOTTERY_COST2) then
    Toast(textRes.Pet.PetMark[26])
    return false
  end
  PetMarkMgr.Instance():DrawLotteryHighTen()
  return true
end
PetMarkLotteryAwardPanel.Commit()
return PetMarkLotteryAwardPanel
