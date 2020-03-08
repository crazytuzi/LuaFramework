local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local MathHelper = require("Common.MathHelper")
local LJTransformMgr = Lplus.ForwardDeclare("LJTransformMgr")
local LJTransformPanel = Lplus.Extend(ECPanelBase, "LJTransformPanel")
local def = LJTransformPanel.define
local querySourceLongJingId = -1
local queryTargetLongJingId = -1
def.field("table").m_AllLongJingList = nil
def.field("number").m_SelectIndex = 0
def.field("table").m_SelectLongJingInfo = nil
def.field("table").m_TargetLongJingInfo = nil
local instance
def.static("=>", LJTransformPanel).Instance = function()
  if nil == instance then
    instance = LJTransformPanel()
    instance.m_AllLongJingList = nil
    instance.m_SelectIndex = 0
    instance.m_SelectLongJingInfo = nil
    instance.m_TargetLongJingInfo = nil
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  local canTransformLongjingList = LJTransformMgr.Instance():GetCanTransformLongJingList()
  if nil == canTransformLongjingList or 0 == MathHelper.CountTable(canTransformLongjingList) then
    Toast(textRes.Fabao[123])
    return
  end
  self:CreatePanel(RESPATH.PREFAB_LONGJING_TRANSFORM_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.LONG_JING_TRANS_SUCC, LJTransformPanel.OnLongJingTransSucc)
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.LONG_JING_QUERY_PRICE_SUCC, LJTransformPanel.OnQueryLongJingPrice)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, LJTransformPanel.OnGoldChanged)
  self:InitData()
  self:UpdateData()
  self:SetSelectIndex(1)
  self:UpdateUI()
end
def.method().InitData = function(self)
  self.m_AllLongJingList = nil
  self.m_SelectIndex = 0
  self.m_SelectLongJingInfo = nil
  self.m_TargetLongJingInfo = nil
end
def.method().UpdateData = function(self)
  self.m_AllLongJingList = LJTransformMgr.Instance():GetCanTransformLongJingList()
end
def.method("number").SetSelectIndex = function(self, index)
  if self.m_AllLongJingList then
    self.m_SelectIndex = index
    self.m_SelectLongJingInfo = self.m_AllLongJingList[index]
  end
end
def.method().UpdateUI = function(self)
  self:UpdateLeftList()
  self:UpdateRightView()
end
def.method().UpdateLeftList = function(self)
  local leftList = self.m_panel:FindDirect("Img_Bg1/Goup_List/Scroll View_List/Grid_List")
  local num = self.m_AllLongJingList and MathHelper.CountTable(self.m_AllLongJingList) or 0
  warn("UpdateLeftList ~~~~~ ", leftList, " ", num)
  local items = GUIUtils.InitUIList(leftList, num, false)
  for i = 1, num do
    local itemObj = items[i]
    itemObj.name = string.format("longjingItem_%d", i)
    local nameLabel = itemObj:FindDirect(string.format("Label_Name_%d", i)):GetComponent("UILabel")
    local uiTexture = itemObj:FindDirect(string.format("Group_Icon_%d/Icon_Equip01_%d", i, i)):GetComponent("UITexture")
    local attributeLabel = itemObj:FindDirect(string.format("Label_Attribute_%d", i)):GetComponent("UILabel")
    local numLabel = itemObj:FindDirect(string.format("Group_Icon_%d/Label_Num_%d", i, i)):GetComponent("UILabel")
    local longjing = self.m_AllLongJingList[i]
    nameLabel:set_text(longjing.name)
    attributeLabel:set_text(longjing.attrName .. " +" .. longjing.attrValue)
    GUIUtils.FillIcon(uiTexture, longjing.iconId)
    numLabel:set_text(longjing.num)
    if 1 == i then
      local uiToggle = itemObj:GetComponent("UIToggle")
      uiToggle.value = true
    end
  end
  GUIUtils.Reposition(leftList, "UIList", 0.01)
  self.m_msgHandler:Touch(leftList)
end
def.method().UpdateRightView = function(self)
  self:UpdateTransformNumView()
  self:UpdateLongJingView()
  self:UpdateGoldView()
  self:UpdateTranformTipsView()
end
def.method().UpdateLongJingView = function(self)
  local mainItem = self.m_panel:FindDirect("Img_Bg1/Group_Right/Group_Top/Group_IconNow")
  local mainLongJingTexture = mainItem:FindDirect("Icon"):GetComponent("UITexture")
  local mainLongJingLabel = mainItem:FindDirect("Label_Name"):GetComponent("UILabel")
  local targetItem = self.m_panel:FindDirect("Img_Bg1/Group_Right/Group_Top/Group_IconNext")
  local targetLongJingTexture = targetItem:FindDirect("Icon"):GetComponent("UITexture")
  local targetLongJingLabel = targetItem:FindDirect("Label_Name"):GetComponent("UILabel")
  if self.m_SelectLongJingInfo then
    mainLongJingLabel:set_text(self.m_SelectLongJingInfo.name)
    GUIUtils.FillIcon(mainLongJingTexture, self.m_SelectLongJingInfo.iconId)
  else
    mainLongJingLabel:set_text("")
    mainLongJingTexture.mainTexture = nil
  end
  if self.m_TargetLongJingInfo then
    targetLongJingLabel:set_text(self.m_TargetLongJingInfo.name)
    GUIUtils.FillIcon(targetLongJingTexture, self.m_TargetLongJingInfo.iconId)
  else
    targetLongJingLabel:set_text("")
    targetLongJingTexture.mainTexture = nil
  end
end
def.method().UpdateTransformNumView = function(self)
  local restTransformNum = LJTransformMgr.Instance():GetRestTransformNum()
  local numLabel = self.m_panel:FindDirect("Img_Bg1/Group_Right/Group_Top/Label_LeftExchangeNum/Label_Num"):GetComponent("UILabel")
  numLabel:set_text(restTransformNum)
end
def.method().UpdateTranformTipsView = function(self)
  local tipsLabel = self.m_panel:FindDirect("Img_Bg1/Group_Right/Group_Tips/Container/Scroll View/Label_Content"):GetComponent("UILabel")
  local tipId = require("Main.Fabao.FabaoUtils").GetLJTransformTipId()
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(tipId)
  tipsLabel:set_text(tipContent)
end
def.method().UpdateGoldView = function(self)
  local ItemModule = require("Main.Item.ItemModule")
  local myGold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  local ownGoldLabel = self.m_panel:FindDirect("Img_Bg1/Group_Right/Own_BgCoin/Label_Coin"):GetComponent("UILabel")
  ownGoldLabel:set_text(myGold:tostring())
  local costGoldObj = self.m_panel:FindDirect("Img_Bg1/Group_Right/Group_Top/Cost_BgCoin")
  costGoldObj:SetActive(false)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
  elseif "Btn_Choose" == id then
    self:OnClickChooseLongJingBtn()
  elseif "Btn_Exchange" == id then
    self:OnClickTransformBtn()
  elseif string.find(id, "longjingItem_") then
    self:OnClickLeftLongJing(clickObj)
  elseif "Btn_Add" == id then
    self:OnClickAddGoldBtn()
  end
end
def.method().OnClickAddGoldBtn = function(self)
  local BuyGoldSilverPanel = require("Main.Item.ui.BuyGoldSilverPanel")
  BuyGoldSilverPanel.Instance():ShowPanel(BuyGoldSilverPanel.ExchangType.YUANBAO2GOLD)
end
def.method("userdata").OnClickLeftLongJing = function(self, clickObj)
  local id = clickObj.name
  local strs = string.split(id, "_")
  local index = tonumber(strs[2])
  self:SetSelectIndex(index)
  self.m_TargetLongJingInfo = nil
  self:UpdateLongJingView()
  self:UpdateGoldView()
  local uiToggle = clickObj:GetComponent("UIToggle")
  uiToggle.value = true
end
def.method().OnClickChooseLongJingBtn = function(self)
  if nil == self.m_SelectLongJingInfo then
    return
  end
  local function cb(selectLongJing)
    GameUtil.AddGlobalLateTimer(0.01, true, function()
      if nil == self.m_panel or self.m_panel.isnil then
        return
      end
      self.m_TargetLongJingInfo = selectLongJing
      local targetItem = self.m_panel:FindDirect("Img_Bg1/Group_Right/Group_Top/Group_IconNext")
      local targetLongJingTexture = targetItem:FindDirect("Icon"):GetComponent("UITexture")
      local targetLongJingLabel = targetItem:FindDirect("Label_Name"):GetComponent("UILabel")
      if self.m_TargetLongJingInfo then
        targetLongJingLabel:set_text(self.m_TargetLongJingInfo.name)
        GUIUtils.FillIcon(targetLongJingTexture, self.m_TargetLongJingInfo.iconId)
      else
        targetLongJingLabel:set_text("")
        targetLongJingTexture.mainTexture = nil
      end
      if nil == self.m_TargetLongJingInfo or nil == self.m_SelectLongJingInfo then
        return
      end
      querySourceLongJingId = self.m_SelectLongJingInfo.id
      queryTargetLongJingId = self.m_TargetLongJingInfo.id
      LJTransformMgr.CQueryTransformLongJingPriceReq(self.m_SelectLongJingInfo.id, self.m_TargetLongJingInfo.id)
    end)
  end
  local LongJingChoosePanel = require("Main.Fabao.ui.LongJingChoosePanel")
  LongJingChoosePanel.Instance():ShowPanel(self.m_SelectLongJingInfo.attrId, self.m_SelectLongJingInfo.level, cb)
end
def.method().OnClickTransformBtn = function(self)
  if nil == self.m_TargetLongJingInfo then
    Toast(textRes.Fabao[124])
    return
  end
  LJTransformMgr.CLongJingTransformReq(self.m_SelectLongJingInfo.uuid, self.m_TargetLongJingInfo.attrId, self.m_TargetLongJingInfo.id)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.LONG_JING_TRANS_SUCC, LJTransformPanel.OnLongJingTransSucc)
  Event.UnregisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.LONG_JING_QUERY_PRICE_SUCC, LJTransformPanel.OnQueryLongJingPrice)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, LJTransformPanel.OnGoldChanged)
  self.m_AllLongJingList = nil
  self.m_SelectIndex = 0
  self.m_TargetLongJingInfo = nil
  self.m_TargetLongJingInfo = nil
end
def.static("table", "table").OnGoldChanged = function()
  local self = LJTransformPanel.Instance()
  if nil == self.m_panel or self.m_panel.isnil then
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local myGold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  local ownGoldLabel = self.m_panel:FindDirect("Img_Bg1/Group_Right/Own_BgCoin/Label_Coin"):GetComponent("UILabel")
  ownGoldLabel:set_text(myGold:tostring())
end
def.static("table", "table").OnLongJingTransSucc = function(p1, p2)
  local self = LJTransformPanel.Instance()
  if nil == self.m_panel or self.m_panel.isnil then
    return
  end
  local transInfo = p1[1]
  local sourceUuid = transInfo.sourceUuid
  local sourceId = transInfo.sourceItemId
  local targetItemInfo = transInfo.targetItemInfo
  local index = -1
  if self.m_AllLongJingList then
    for k, v in pairs(self.m_AllLongJingList) do
      if v.uuid:eq(sourceUuid) and v.id == sourceId then
        index = k
        break
      end
    end
    if -1 ~= index then
      local longjingNum = self.m_AllLongJingList[index].num
      if longjingNum > 1 then
        self.m_AllLongJingList[index].num = longjingNum - 1
      else
        table.remove(self.m_AllLongJingList, index)
      end
    end
  end
  if nil == self.m_TargetLongJingInfo then
    return
  end
  if self.m_TargetLongJingInfo.id ~= targetItemInfo.id then
    warn("the target longjing id is not match !!!!!!!!!!! ", self.m_TargetLongJingInfo.id, " ", targetItemInfo.id)
    return
  end
  if nil == self.m_AllLongJingList then
    self.m_AllLongJingList = {}
  end
  local longjing = self.m_TargetLongJingInfo
  longjing.num = 1
  longjing.uuid = targetItemInfo.uuid[1]
  table.insert(self.m_AllLongJingList, longjing)
  table.sort(self.m_AllLongJingList, function(a, b)
    return a.id < b.id
  end)
  self.m_TargetLongJingInfo = nil
  self:SetSelectIndex(1)
  self:UpdateUI()
  local uiList = self.m_panel:FindDirect("Img_Bg1/Goup_List/Scroll View_List/Grid_List"):GetComponent("UIList")
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if self.m_panel and not self.m_panel.isnil and uiList and not uiList.isnil then
      uiList:DragToMakeVisible(0, 100)
    end
  end)
end
def.static("table", "table").OnQueryLongJingPrice = function(p1, p2)
  local self = LJTransformPanel.Instance()
  if self.m_panel and not self.m_panel.isnil then
    if -1 == queryTargetLongJingId or -1 == querySourceLongJingId then
      return
    end
    local priceMap = p1.priceMap
    if nil == priceMap or nil == priceMap[querySourceLongJingId] or nil == priceMap[queryTargetLongJingId] then
      return
    end
    local sourcePrice = priceMap[querySourceLongJingId]
    local targetPrice = priceMap[queryTargetLongJingId]
    warn("OnQueryLongJingPrice ***** ", queryTargetLongJingId, " ", querySourceLongJingId, " ", sourcePrice, " ", targetPrice)
    local costGoldObj = self.m_panel:FindDirect("Img_Bg1/Group_Right/Group_Top/Cost_BgCoin")
    local costNameLabel = costGoldObj:FindDirect("Label"):GetComponent("UILabel")
    local costNumLabel = costGoldObj:FindDirect("Label_Cost"):GetComponent("UILabel")
    costGoldObj:SetActive(true)
    local name = ""
    if sourcePrice >= targetPrice then
      name = textRes.Fabao[129]
    else
      name = textRes.Fabao[128]
    end
    costNameLabel:set_text(name)
    costNumLabel:set_text(math.floor(math.abs(sourcePrice - targetPrice)))
    queryTargetLongJingId = -1
    querySourceLongJingId = -1
  end
end
LJTransformPanel.Commit()
return LJTransformPanel
