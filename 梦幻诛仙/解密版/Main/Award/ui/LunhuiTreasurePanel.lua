local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local LunhuiTreasurePanel = Lplus.Extend(ECPanelBase, "LunhuiTreasurePanel")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local GUIUtils = require("GUI.GUIUtils")
local RewardItem = require("netio.protocol.mzm.gsp.floplottery.RewardItem")
local EC = require("Types.Vector3")
local ItemModule = require("Main.Item.ItemModule")
local LunhuiTreasureMgr = Lplus.ForwardDeclare("LunhuiTreasureMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local def = LunhuiTreasurePanel.define
def.const("table").MoneySprite = {
  [MoneyType.YUANBAO] = "Img_Money",
  [MoneyType.GOLD] = "Icon_Gold",
  [MoneyType.SILVER] = "Icon_Sliver",
  [MoneyType.GANGCONTRIBUTE] = "Img_Bang",
  [MoneyType.GOLD_INGOT] = "Img_JinDing"
}
def.field("userdata").sessionId = nil
def.field("table").drawInfo = nil
def.field("number").cfgId = 0
def.field("boolean").drawing = false
local instance
def.static("=>", LunhuiTreasurePanel).Instance = function()
  if instance == nil then
    instance = LunhuiTreasurePanel()
  end
  return instance
end
def.static("userdata", "number", "table").ShowDrawCard = function(sessionId, cfgId, drawInfo)
  local self = LunhuiTreasurePanel.Instance()
  self.sessionId = sessionId
  self.cfgId = cfgId
  self.drawInfo = drawInfo or {}
  self.drawing = false
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_DRAW_CARD, 0)
  self:SetModal(true)
end
def.static("userdata", "number", "table").TurnOver = function(sessionId, index, info)
  local self = LunhuiTreasurePanel.Instance()
  if self:IsShow() and self.sessionId == sessionId then
    self.drawInfo[index] = info
    self.drawing = true
    do
      local card = self.m_panel:FindDirect(string.format("Img_Bg0/Group_Card/Group_Type_%d", index))
      local cardInfo = card:FindDirect(string.format("Group_Info_%d", index))
      local cardBack1 = card:FindDirect(string.format("Group_Type01_%d", index))
      local cardBack2 = card:FindDirect(string.format("Group_Type02_%d", index))
      self:FillIcon(cardInfo, info[1], index)
      cardBack1:GetComponent("TweenRotation"):PlayForward()
      cardBack1:GetComponent("TweenAlpha"):PlayForward()
      cardBack2:GetComponent("TweenRotation"):PlayForward()
      cardBack2:GetComponent("TweenAlpha"):PlayForward()
      cardInfo:SetActive(true)
      cardInfo:GetComponent("TweenRotation"):PlayForward()
      cardInfo:GetComponent("TweenAlpha"):PlayForward()
      require("Fx.GUIFxMan").Instance():PlayAsChildLayer(card, RESPATH.FanZhuan_EFFECT, "flash", 0, 0, 1, 1, 1, false)
      GameUtil.AddGlobalTimer(0.51, true, function()
        self.drawing = false
        if self:IsShow() then
          cardBack1:SetActive(false)
          cardBack2:SetActive(false)
          self:UpdateCard()
        end
      end)
    end
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, LunhuiTreasurePanel.OnMoneyChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, LunhuiTreasurePanel.OnMoneyChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, LunhuiTreasurePanel.OnMoneyChange)
  self:UpdateDesc()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, LunhuiTreasurePanel.OnMoneyChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, LunhuiTreasurePanel.OnMoneyChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, LunhuiTreasurePanel.OnMoneyChange)
end
def.static("table", "table").OnMoneyChange = function(p1, p2)
  local self = LunhuiTreasurePanel.Instance()
  self:UpdateMoney()
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:UpdateCard()
    self:UpdateMoney()
  end
end
def.method().UpdateDesc = function(self)
  local cfg = LunhuiTreasureMgr.Instance():GetTreasureCfg(self.cfgId)
  if cfg then
    local lbl = self.m_panel:FindDirect("Img_Bg0/Label_Tips")
    local tipContent = require("Main.Common.TipsHelper").GetHoverTip(cfg.tipId)
    if tipContent then
      lbl:GetComponent("UILabel"):set_text(tipContent)
    end
  end
end
def.method().UpdateMoney = function(self)
  local goldLbl = self.m_panel:FindDirect("Img_Bg0/Group_Gold/Label_HaveNum")
  local goldNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  goldLbl:GetComponent("UILabel"):set_text(goldNum:tostring())
  local yuanbaoLbl = self.m_panel:FindDirect("Img_Bg0/Group_Money/Label_HaveNum")
  local yuanbaoNum = ItemModule.Instance():GetAllYuanBao()
  yuanbaoLbl:GetComponent("UILabel"):set_text(yuanbaoNum:tostring())
end
def.method().UpdateCard = function(self)
  local cfg = LunhuiTreasureMgr.Instance():GetTreasureCfg(self.cfgId)
  if cfg == nil then
    return
  end
  local drawList = LunhuiTreasureMgr.Instance():GetDrawCardCfg(cfg.typeId)
  if drawList == nil then
    return
  end
  local cardInfo = drawList[table.nums(self.drawInfo) + 1]
  local list = self.m_panel:FindDirect("Img_Bg0/Group_Card")
  for i = 1, 8 do
    local uiGo = list:FindDirect("Group_Type_" .. i)
    if uiGo then
      if drawList[i] then
        if self.drawInfo[i] then
          self:FillItem(uiGo, self.drawInfo[i], i)
        else
          self:FillCard(uiGo, cardInfo, i)
        end
        self.m_msgHandler:Touch(uiGo)
      else
        uiGo:SetActive(false)
      end
    end
  end
end
def.method("userdata", "table", "number").FillCard = function(self, uiGo, cardInfo, index)
  local Group_Info = uiGo:FindDirect(string.format("Group_Info_%d", index))
  local Group_Type01 = uiGo:FindDirect(string.format("Group_Type01_%d", index))
  local Group_Type02 = uiGo:FindDirect(string.format("Group_Type02_%d", index))
  Group_Info:SetActive(false)
  local card_back
  if cardInfo.moneyCount > 0 then
    card_back = Group_Type02
    Group_Type01:SetActive(false)
    Group_Type02:SetActive(true)
    local spriteName = LunhuiTreasurePanel.MoneySprite[cardInfo.moneyType]
    if spriteName then
      local sprite = Group_Type02:FindDirect(string.format("Img_MoneyIcon_%d", index))
      sprite:GetComponent("UISprite"):set_spriteName(spriteName)
    end
    local lbl = Group_Type02:FindDirect(string.format("Label_HaveNum_%d", index))
    lbl:GetComponent("UILabel"):set_text(cardInfo.moneyCount)
  else
    card_back = Group_Type01
    Group_Type01:SetActive(true)
    Group_Type02:SetActive(false)
  end
  card_back.localRotation = Quaternion.Euler(EC.Vector3.zero)
  card_back:GetComponent("UISprite"):set_alpha(1)
end
def.method("userdata", "table", "number").FillItem = function(self, uiGo, drawInfo, index)
  local Group_Info = uiGo:FindDirect(string.format("Group_Info_%d", index))
  local Group_Type01 = uiGo:FindDirect(string.format("Group_Type01_%d", index))
  local Group_Type02 = uiGo:FindDirect(string.format("Group_Type02_%d", index))
  Group_Type01:SetActive(false)
  Group_Type02:SetActive(false)
  local info = drawInfo[1]
  self:FillIcon(Group_Info, info, index)
  Group_Info:SetActive(true)
  Group_Info.localRotation = Quaternion.Euler(EC.Vector3.zero)
  Group_Info:GetComponent("UISprite"):set_alpha(1)
end
def.method("userdata", "table", "number").FillIcon = function(self, Group_Info, info, index)
  if info == nil then
    return
  end
  local icon = Group_Info:FindDirect(string.format("Texture_%d", index))
  local iconNum = Group_Info:FindDirect(string.format("Label_num_%d", index))
  local iconName = Group_Info:FindDirect(string.format("Label_Name_%d", index))
  local type = info.rewardType
  if type == RewardItem.TYPE_ITEM then
    local itemId = info.paramMap[RewardItem.PARAM_ITEM_ID]
    local num = info.paramMap[RewardItem.PARAM_ITEM_NUM]
    local itemBase = ItemUtils.GetItemBase(itemId)
    if num > 1 then
      iconNum:SetActive(true)
      iconNum:GetComponent("UILabel"):set_text(num)
    else
      iconNum:SetActive(false)
    end
    iconName:GetComponent("UILabel"):set_text(string.format("[%s]%s[-]", require("Main.Chat.HtmlHelper").NameColor[itemBase.namecolor], itemBase.name))
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), itemBase.icon)
    icon:FindDirect(string.format("Sprite_%d", index)):GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", itemBase.namecolor))
  elseif type == RewardItem.TYPE_ROLE_EXP then
    local exp = info.paramMap[RewardItem.PARAM_EXP]
    iconNum:SetActive(false)
    iconName:GetComponent("UILabel"):set_text(exp)
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), GUIUtils.GetIconIdRoleExp())
    icon:FindDirect(string.format("Sprite_%d", index)):GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", 1))
  elseif type == RewardItem.TYPE_PET_EXP then
    local exp = info.paramMap[RewardItem.PARAM_EXP]
    iconNum:SetActive(false)
    iconName:GetComponent("UILabel"):set_text(exp)
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), GUIUtils.GetIconIdPetExp())
    icon:FindDirect(string.format("Sprite_%d", index)):GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", 1))
  elseif type == RewardItem.TYPE_XIULIAN_EXP then
    local exp = info.paramMap[RewardItem.PARAM_EXP]
    iconNum:SetActive(false)
    iconName:GetComponent("UILabel"):set_text(exp)
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), GUIUtils.GetIconIdXiulianExp())
    icon:FindDirect(string.format("Sprite_%d", index)):GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", 1))
  elseif type == RewardItem.TYPE_SILVER then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    iconNum:SetActive(false)
    iconName:GetComponent("UILabel"):set_text(money)
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), GUIUtils.GetIconIdSilver())
    icon:FindDirect(string.format("Sprite_%d", index)):GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", 1))
  elseif type == RewardItem.TYPE_GOLD then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    iconNum:SetActive(false)
    iconName:GetComponent("UILabel"):set_text(money)
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), GUIUtils.GetIconIdGold())
    icon:FindDirect(string.format("Sprite_%d", index)):GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", 1))
  elseif type == RewardItem.TYPE_BANGGONG then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    iconNum:SetActive(false)
    iconName:GetComponent("UILabel"):set_text(money)
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), GUIUtils.GetIconIdBanggong())
    icon:FindDirect(string.format("Sprite_%d", index)):GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", 1))
  elseif type == RewardItem.TYPE_YUANBAO then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    iconNum:SetActive(false)
    iconName:GetComponent("UILabel"):set_text(money)
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), GUIUtils.GetIconIdYuanbao())
    icon:FindDirect(string.format("Sprite_%d", index)):GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", 1))
  end
end
def.method("number").ShowAward = function(self, index)
  local drawInfo = self.drawInfo[index]
  if drawInfo == nil then
    return
  end
  local info = drawInfo[1]
  if info == nil then
    return
  end
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local source = self.m_panel:FindDirect(string.format("Img_Bg0/Group_Card/Group_Type_%d/Group_Info_%d/Texture_%d", index, index, index))
  local position = source:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = source:GetComponent("UIWidget")
  if info.rewardType == RewardItem.TYPE_ITEM then
    local itemId = info.paramMap[RewardItem.PARAM_ITEM_ID]
    ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0, false)
  elseif info.rewardType == RewardItem.TYPE_ROLE_EXP then
    local exp = info.paramMap[RewardItem.PARAM_EXP]
    local iconId = GUIUtils.GetIconIdRoleExp()
    local title = exp .. textRes.BaoTu[10]
    local type = textRes.BaoTu[10]
    local desc = textRes.BaoTu[11]
    ItemTipsMgr.Instance():ShowCustomTip(title, iconId, type, desc, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
  elseif info.rewardType == RewardItem.TYPE_PET_EXP then
    local exp = info.paramMap[RewardItem.PARAM_EXP]
    local iconId = GUIUtils.GetIconIdPetExp()
    local title = exp .. textRes.BaoTu[12]
    local type = textRes.BaoTu[12]
    local desc = textRes.BaoTu[13]
    ItemTipsMgr.Instance():ShowCustomTip(title, iconId, type, desc, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
  elseif info.rewardType == RewardItem.TYPE_XIULIAN_EXP then
    local exp = info.paramMap[RewardItem.PARAM_EXP]
    local iconId = GUIUtils.GetIconIdXiulianExp()
    local title = exp .. textRes.BaoTu[18]
    local type = textRes.BaoTu[18]
    local desc = textRes.BaoTu[19]
    ItemTipsMgr.Instance():ShowCustomTip(title, iconId, type, desc, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
  elseif info.rewardType == RewardItem.TYPE_SILVER then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    local iconId = GUIUtils.GetIconIdSilver()
    local title = money .. textRes.BaoTu[16]
    local type = textRes.BaoTu[16]
    local desc = textRes.BaoTu[17]
    ItemTipsMgr.Instance():ShowCustomTip(title, iconId, type, desc, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
  elseif info.rewardType == RewardItem.TYPE_BANGGONG then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    local iconId = GUIUtils.GetIconIdBanggong()
    local title = money .. textRes.BaoTu[26]
    local type = textRes.BaoTu[26]
    local desc = textRes.BaoTu[27]
    ItemTipsMgr.Instance():ShowCustomTip(title, iconId, type, desc, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
  elseif info.rewardType == RewardItem.TYPE_CONTROLLER then
    local ctlId = info.paramMap[RewardItem.PARAM_OCNTROLLER_ID]
    local ctlCfg = WabaoModule.Instance():GetControllerCfg(ctlId)
    if ctlCfg then
      local iconId = ctlCfg.iconId
      local title = ctlCfg.name
      local type = ctlCfg.name
      local desc = ctlCfg.desc
      ItemTipsMgr.Instance():ShowCustomTip(title, iconId, type, desc, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
    end
  elseif info.rewardType == RewardItem.TYPE_YUANBAO then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    local iconId = GUIUtils.GetIconIdYuanbao()
    local title = money .. textRes.BaoTu[20]
    local type = textRes.BaoTu[20]
    local desc = textRes.BaoTu[21]
    ItemTipsMgr.Instance():ShowCustomTip(title, iconId, type, desc, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
  elseif info.rewardType == RewardItem.TYPE_GOLD then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    local iconId = GUIUtils.GetIconIdGold()
    local title = money .. textRes.BaoTu[14]
    local type = textRes.BaoTu[14]
    local desc = textRes.BaoTu[15]
    ItemTipsMgr.Instance():ShowCustomTip(title, iconId, type, desc, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
  end
end
def.method("number").DrawCard = function(self, index)
  if self.drawing or self.drawInfo[index] then
    return
  else
    require("Main.Award.mgr.LunhuiTreasureMgr").Instance():Draw(self.sessionId, index, table.nums(self.drawInfo) + 1, self.cfgId)
  end
end
def.method().AddGold = function(self)
  GoToBuyGold(false)
end
def.method().AddYuanBao = function(self)
  local MallPanel = require("Main.Mall.ui.MallPanel")
  require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
end
def.method().ConfirmHide = function(self)
  local num = table.nums(self.drawInfo)
  local cfg = LunhuiTreasureMgr.Instance():GetTreasureCfg(self.cfgId)
  if cfg == nil then
    self:DestroyPanel()
  end
  local drawList = LunhuiTreasureMgr.Instance():GetDrawCardCfg(cfg.typeId)
  if drawList == nil then
    self:DestroyPanel()
  end
  local total = #drawList
  if num > 0 and num < total then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm("", textRes.Award[200], function(sel)
      if sel == 1 then
        require("Main.Award.mgr.LunhuiTreasureMgr").Instance():Close(self.sessionId)
        self:DestroyPanel()
      end
    end, nil)
  else
    if num >= total then
      require("Main.Award.mgr.LunhuiTreasureMgr").Instance():Close(self.sessionId)
    end
    self:DestroyPanel()
  end
end
def.method("string").onClick = function(self, id)
  warn("onClick", id)
  if id == "Btn_Close" then
    self:ConfirmHide()
  elseif id == "Btn_AddGold" then
    self:AddGold()
  elseif id == "Btn_AddYuanbao" then
    self:AddYuanBao()
  elseif string.sub(id, 1, 11) == "Group_Type_" then
    local index = tonumber(string.sub(id, 12))
    if index then
      self:DrawCard(index)
    end
  elseif string.sub(id, 1, 8) == "Texture_" then
    local index = tonumber(string.sub(id, 9))
    if index then
      self:ShowAward(index)
    end
  end
end
return LunhuiTreasurePanel.Commit()
