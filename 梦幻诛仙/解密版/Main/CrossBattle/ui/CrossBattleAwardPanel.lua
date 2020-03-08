local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CrossBattleAwardPanel = Lplus.Extend(ECPanelBase, "CrossBattleAwardPanel")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local def = CrossBattleAwardPanel.define
def.field("table").uiObjs = nil
local instance
def.static("=>", CrossBattleAwardPanel).Instance = function()
  if instance == nil then
    instance = CrossBattleAwardPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CROSS_BATTLE_AWARD_PREVIEW) then
    Toast(textRes.CrossBattle.AwardPreview[1])
    return
  end
  self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_AWARD, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:ShowAwardInfo()
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.uiObjs.Label_Title = self.uiObjs.Img_Bg:FindDirect("Label_Title")
  self.uiObjs.ScrollView = self.uiObjs.Img_Bg:FindDirect("Group_DuanWei/ScrollView")
  self.uiObjs.List = self.uiObjs.ScrollView:FindDirect("List")
end
def.method().ShowAwardInfo = function(self)
  GUIUtils.SetText(self.uiObjs.Label_Title, string.format(textRes.CrossBattle.AwardPreview[2], constant.CrossBattleConsts.cross_battle_session))
  local awards = CrossBattleInterface.GetCrossBattleAwardPreviewCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local uiList = self.uiObjs.List:GetComponent("UIList")
  uiList.itemCount = #awards
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local uiItem = uiItems[i]
    self:FillAwardItemInfo(i, uiItem, awards[i])
  end
  GUIUtils.ResetPosition(self.uiObjs.ScrollView, 0.1)
end
def.method("number", "userdata", "table").FillAwardItemInfo = function(self, idx, item, award)
  local Img_Rank = item:FindDirect("Img_Rank")
  local Label = item:FindDirect("Label")
  GUIUtils.SetTexture(Img_Rank, award.icon)
  GUIUtils.SetText(Label, award.title)
  local Group_Icon = item:FindDirect("Group_Icon")
  local uiList = Group_Icon:GetComponent("UIList")
  local giftId = 0
  local awardCfg = ItemUtils.GetGiftAwardCfgByAwardId(award.awardId)
  if awardCfg and awardCfg.itemList[1] then
    local giftBagCfg = ItemUtils.GetGiftBasicCfg(awardCfg.itemList[1].itemId)
    if giftBagCfg then
      giftId = giftBagCfg.awardId
    end
  end
  local giftCfg = ItemUtils.GetGiftAwardCfgByAwardId(giftId)
  if giftCfg then
    uiList.itemCount = #giftCfg.moneyList + #giftCfg.itemList + (giftCfg.appellationId == 0 and 0 or 1) + (giftCfg.titleId == 0 and 0 or 1)
    uiList:Resize()
  else
    uiList.itemCount = 0
    uiList:Resize()
  end
  local AllMoneyType = require("consts.mzm.gsp.item.confbean.AllMoneyType")
  local startIdx = 0
  for i = 1, #giftCfg.moneyList do
    local awardItem = Group_Icon:FindDirect("Img_BgIcon_" .. startIdx + i)
    local Texture_Icon = awardItem:FindDirect("Texture_Icon_" .. startIdx + i)
    local Label_Num = awardItem:FindDirect("Label_Num_" .. startIdx + i)
    local moneyBean = giftCfg.moneyList[i]
    local bigType = moneyBean.bigType
    local littleType = moneyBean.littleType
    local num = moneyBean.num
    if bigType == AllMoneyType.TYPE_MONEY then
      local cfg = ItemUtils.GetMoneyCfg(littleType)
      GUIUtils.SetTexture(Texture_Icon, cfg.iconTex)
      awardItem.name = "AwardMoney_" .. cfg.desitemid
    elseif bigType == AllMoneyType.TYPE_TOKEN then
      local cfg = ItemUtils.GetTokenCfg(littleType)
      GUIUtils.SetTexture(Texture_Icon, cfg.iconTex)
      awardItem.name = "AwardMoney_" .. cfg.showItemId
    end
    GUIUtils.SetText(Label_Num, num)
  end
  startIdx = startIdx + #giftCfg.moneyList
  for i = 1, #giftCfg.itemList do
    local awardItem = Group_Icon:FindDirect("Img_BgIcon_" .. startIdx + i)
    local Texture_Icon = awardItem:FindDirect("Texture_Icon_" .. startIdx + i)
    local Label_Num = awardItem:FindDirect("Label_Num_" .. startIdx + i)
    local itemId = giftCfg.itemList[i].itemId
    local itemNum = giftCfg.itemList[i].num
    local itemBase = ItemUtils.GetItemBase(itemId)
    GUIUtils.SetTexture(Texture_Icon, itemBase.icon)
    GUIUtils.SetText(Label_Num, itemNum)
    awardItem.name = "AwardItem_" .. itemId
  end
  startIdx = startIdx + #giftCfg.itemList
  local TitleInterface = require("Main.title.TitleInterface")
  if giftCfg.appellationId ~= 0 then
    local awardItem = Group_Icon:FindDirect("Img_BgIcon_" .. startIdx + 1)
    local Texture_Icon = awardItem:FindDirect("Texture_Icon_" .. startIdx + 1)
    local Label_Num = awardItem:FindDirect("Label_Num_" .. startIdx + 1)
    GUIUtils.SetTexture(Texture_Icon, TitleInterface.GetAppellationIcon())
    GUIUtils.SetText(Label_Num, "")
    awardItem.name = "AwardAppellation_" .. giftCfg.appellationId
  end
  startIdx = startIdx + (giftCfg.appellationId == 0 and 0 or 1)
  if giftCfg.titleId ~= 0 then
    local awardItem = Group_Icon:FindDirect("Img_BgIcon_" .. startIdx + 1)
    local Texture_Icon = awardItem:FindDirect("Texture_Icon_" .. startIdx + 1)
    local Label_Num = awardItem:FindDirect("Label_Num_" .. startIdx + 1)
    GUIUtils.SetTexture(Texture_Icon, TitleInterface.GetTitleIcon())
    GUIUtils.SetText(Label_Num, "")
    awardItem.name = "AwardTitle_" .. giftCfg.titleId
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if string.find(id, "AwardItem_") then
    local itemId = tonumber(string.sub(id, #"AwardItem_" + 1))
    self:OnClickAwardItem(obj, itemId)
  elseif string.find(id, "AwardMoney_") then
    local itemId = tonumber(string.sub(id, #"AwardMoney_" + 1))
    self:OnClickAwardMonkey(obj, itemId)
  elseif string.find(id, "AwardAppellation_") then
    local appellationId = tonumber(string.sub(id, #"AwardAppellation_" + 1))
    self:OnClickAwardAppellation(appellationId)
  elseif string.find(id, "AwardTitle_") then
    local titleId = tonumber(string.sub(id, #"AwardTitle_" + 1))
    self:OnClickAwardTitle(titleId)
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  end
end
def.method("userdata", "number").OnClickAwardItem = function(self, source, itemId)
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, source, 0, false)
end
def.method("userdata", "number").OnClickAwardMonkey = function(self, source, itemId)
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, source, 0, false)
end
def.method("number").OnClickAwardAppellation = function(self, appellationId)
  local TitleInterface = require("Main.title.TitleInterface")
  local chengweiCfg = TitleInterface.GetAppellationCfg(appellationId)
  if chengweiCfg == nil then
    warn("no appellationId:" .. appellationId)
    return
  end
  require("Main.title.ui.ChengweiTips").Instance():ShowTip(appellationId, chengweiCfg.appellationName)
end
def.method("number").OnClickAwardTitle = function(self, titleId)
  local TitleInterface = require("Main.title.TitleInterface")
  local touxianCfg = TitleInterface.GetTitleCfg(titleId)
  if touxianCfg == nil then
    warn("no titleId:" .. titleId)
    return
  end
  require("Main.title.ui.TouxianTips").Instance():ShowTip(titleId, touxianCfg.titleName)
end
CrossBattleAwardPanel.Commit()
return CrossBattleAwardPanel
