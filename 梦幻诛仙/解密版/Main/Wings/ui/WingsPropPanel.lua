local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local WingsUtility = require("Main.Wings.WingsUtility")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local WingsDataMgr = require("Main.Wings.data.WingsDataMgr")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemData = require("Main.Item.ItemData")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local WingsPropPanel = Lplus.Extend(ECPanelBase, "WingsPropPanel")
local def = WingsPropPanel.define
def.field("table").uiNodes = nil
local instance
def.static("=>", WingsPropPanel).Instance = function()
  if instance == nil then
    instance = WingsPropPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_WING_ATTRIBUTE_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self.uiNodes = {}
  self.uiNodes.imgBG = self.m_panel:FindDirect("Img_Bg")
  self.uiNodes.groupCur = self.uiNodes.imgBG:FindDirect("Group_Current")
  self.uiNodes.groupRes = self.uiNodes.imgBG:FindDirect("Group_Result")
  self.uiNodes.groupBtn = self.uiNodes.imgBG:FindDirect("Gruop_Btn")
  self.uiNodes.imgItem = self.uiNodes.imgBG:FindDirect("Img_Item")
  self.uiNodes.toggleBtn = self.uiNodes.imgBG:FindDirect("Img_Item/Btn_UseGold")
  self.uiNodes.ResetBtnLabel = self.uiNodes.groupBtn:FindDirect("Btn_Wash/Label_Wash")
  self.uiNodes.yuanbaoGroup = self.uiNodes.groupBtn:FindDirect("Btn_Wash/Group_Yuanbao")
  self.uiNodes.ResetBtnLabel:SetActive(true)
  self.uiNodes.yuanbaoGroup:SetActive(false)
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_RESET_PROP_CHANGED, WingsPropPanel.OnResetPropChanged)
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_CURRENT_PROP_CHANGED, WingsPropPanel.OnCurrentPropChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, WingsPropPanel.OnBagInfoSyncronized)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow == false then
    return
  end
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_RESET_PROP_CHANGED, WingsPropPanel.OnResetPropChanged)
  Event.UnregisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_CURRENT_PROP_CHANGED, WingsPropPanel.OnCurrentPropChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, WingsPropPanel.OnBagInfoSyncronized)
end
def.method().UpdateUI = function(self)
  self:UpdateCurrentPropInfo()
  self:UpdateResetPropInfo()
  self:UpdateConsumeItemInfo()
end
def.method().UpdateCurrentPropInfo = function(self)
  local propMap = WingsDataMgr.Instance():GetPropertyMap(true)
  if not propMap then
    return
  end
  local grids = self.uiNodes.groupCur:FindDirect("Grid")
  local propNum = WingsDataMgr.WING_PROPERTY_NUM
  for i = 1, propNum do
    local propRoot = grids:FindDirect("Attribute_" .. i)
    local propitem = propMap[WingsUtility.PropSeq[i]]
    if not propitem then
      return
    end
    propRoot:FindDirect("Label2"):GetComponent("UILabel"):set_text(string.format("+ %d", propitem.value))
    local colorText = string.format("[%s]%s[-]", ItemTipsMgr.Color[propitem.phase], textRes.Wings.PropPhase[propitem.phase])
    propRoot:FindDirect("Label3"):GetComponent("UILabel"):set_text(colorText)
  end
end
def.method().UpdateResetPropInfo = function(self)
  local propMap = WingsDataMgr.Instance():GetPropertyMap(false)
  local tip = self.uiNodes.groupRes:FindDirect("Label_Tip")
  local grids = self.uiNodes.groupRes:FindDirect("Grid")
  if not propMap then
    tip:SetActive(true)
    grids:SetActive(false)
    return
  else
    tip:SetActive(false)
    grids:SetActive(true)
  end
  local propNum = WingsDataMgr.WING_PROPERTY_NUM
  for i = 1, propNum do
    local propRoot = grids:FindDirect("Attribute_" .. i)
    local propitem = propMap[WingsUtility.PropSeq[i]]
    if not propitem then
      return
    end
    propRoot:FindDirect("Label2"):GetComponent("UILabel"):set_text(string.format("+ %d", propitem.value))
    local colorText = string.format("[%s]%s[-]", ItemTipsMgr.Color[propitem.phase], textRes.Wings.PropPhase[propitem.phase])
    propRoot:FindDirect("Label3"):GetComponent("UILabel"):set_text(colorText)
  end
end
def.method().UpdateConsumeItemInfo = function(self)
  local resetItemId = WingsDataMgr.WING_PROPERTY_RESET_ITEM_ID
  local resetItemNumNeed = WingsDataMgr.WING_PROPERTY_RESET_ITEM_NUM
  local ItemModule = require("Main.Item.ItemModule")
  local resetItemNumInBag = ItemData.Instance():GetNumberByItemId(ItemModule.BAG, resetItemId)
  local imgItem = self.uiNodes.imgBG:FindDirect("Img_Item")
  local uiTexture = imgItem:FindDirect("Texture_Item"):GetComponent("UITexture")
  local uiLabelNum = imgItem:FindDirect("Label"):GetComponent("UILabel")
  local uiLabelName = self.uiNodes.imgBG:FindDirect("Label_ItemName"):GetComponent("UILabel")
  local ItemUtils = require("Main.Item.ItemUtils")
  local resetItemBase = ItemUtils.GetItemBase(resetItemId)
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.FillIcon(uiTexture, resetItemBase.icon)
  if resetItemNumNeed > resetItemNumInBag then
    uiLabelNum:set_color(Color.red)
  else
    uiLabelNum:set_color(Color.white)
  end
  uiLabelNum:set_text(string.format("%d/%d", resetItemNumInBag, resetItemNumNeed))
  uiLabelName:set_text(resetItemBase.name)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Wash" then
    self:OnBtnResetClicked()
  elseif id == "Btn_Replace" then
    self:OnBtnReplaceClicked()
  elseif id == "Btn_Tips" then
    self:OnBtnTipsClicked()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_panelName
    })
  elseif id == "Texture_Item" then
    self:OnResetItemClicked()
  elseif id == "Btn_UseGold" then
    self:OnClickNeedYuanBaoReplace()
  end
end
def.method().OnClickNeedYuanBaoReplace = function(self)
  local toggleBtn = self.uiNodes.toggleBtn
  if toggleBtn and not toggleBtn.isnil then
    do
      local uiToggle = toggleBtn:GetComponent("UIToggle")
      local curValue = uiToggle.value
      if curValue then
        local resetItemId = WingsDataMgr.WING_PROPERTY_RESET_ITEM_ID
        local resetItemNumNeed = WingsDataMgr.WING_PROPERTY_RESET_ITEM_NUM
        local ItemModule = require("Main.Item.ItemModule")
        local resetItemNumInBag = ItemData.Instance():GetNumberByItemId(ItemModule.BAG, resetItemId)
        if resetItemNumNeed <= resetItemNumInBag then
          Toast(textRes.Wings[41])
          uiToggle.value = false
          self:UpdateResetBtnState()
          return
        end
        local function callback(select, tag)
          if 0 == select then
            uiToggle.value = false
          elseif 1 == select then
            uiToggle.value = true
          end
          self:UpdateResetBtnState()
        end
        CommonConfirmDlg.ShowConfirm("", textRes.Wings[42], callback, nil)
      else
        self:UpdateResetBtnState()
      end
    end
  end
end
def.method().UpdateResetBtnState = function(self)
  local toggleBtn = self.uiNodes.toggleBtn
  local uiToggle = toggleBtn:GetComponent("UIToggle")
  local curValue = uiToggle.value
  if curValue then
    local resetItemId = WingsDataMgr.WING_PROPERTY_RESET_ITEM_ID
    local resetItemNumNeed = WingsDataMgr.WING_PROPERTY_RESET_ITEM_NUM
    local ItemModule = require("Main.Item.ItemModule")
    local resetItemNumInBag = ItemData.Instance():GetNumberByItemId(ItemModule.BAG, resetItemId)
    if resetItemNumNeed <= resetItemNumInBag then
      uiToggle.value = false
      self.uiNodes.ResetBtnLabel:SetActive(true)
      self.uiNodes.yuanbaoGroup:SetActive(false)
      return
    end
    self.uiNodes.ResetBtnLabel:SetActive(false)
    self.uiNodes.yuanbaoGroup:SetActive(true)
    local itemPrice = WingsUtility.GetReSetPropItemPrice(resetItemId)
    local needYuanBao = itemPrice * (resetItemNumNeed - resetItemNumInBag)
    local uiLabel = self.uiNodes.yuanbaoGroup:FindDirect("Label_Money"):GetComponent("UILabel")
    uiLabel:set_text(tostring(needYuanBao))
  else
    self.uiNodes.ResetBtnLabel:SetActive(true)
    self.uiNodes.yuanbaoGroup:SetActive(false)
  end
end
def.method().OnBtnTipsClicked = function(self)
  local tmpPosition = {x = 0, y = 0}
  local CommonDescDlg = require("GUI.CommonUITipsDlg")
  local tipString = require("Main.Common.TipsHelper").GetHoverTip(WingsDataMgr.WING_PRO_RESET_TIP_ID)
  if tipString == "" then
    return
  end
  CommonDescDlg.ShowCommonTip(tipString, tmpPosition)
end
def.method().OnResetItemClicked = function(self)
  local sourceObj = self.uiNodes.imgItem
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = sourceObj:GetComponent("UISprite")
  ItemTipsMgr.Instance():ShowBasicTips(WingsDataMgr.WING_PROPERTY_RESET_ITEM_ID, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
end
def.method().OnBtnResetClicked = function(self)
  warn("OnBtnResetClicked  ~~~~~~~ ")
  local resetItemId = WingsDataMgr.WING_PROPERTY_RESET_ITEM_ID
  local resetItemNumNeed = WingsDataMgr.WING_PROPERTY_RESET_ITEM_NUM
  local ItemModule = require("Main.Item.ItemModule")
  local resetItemNumInBag = ItemData.Instance():GetNumberByItemId(ItemModule.BAG, resetItemId)
  local needYuanBaoReplace = false
  if resetItemNumNeed > resetItemNumInBag then
    local uiToggle = self.uiNodes.toggleBtn:GetComponent("UIToggle")
    local curValue = uiToggle.value
    if not curValue then
      uiToggle.value = true
      self:OnClickNeedYuanBaoReplace()
      return
    else
      needYuanBaoReplace = true
    end
  end
  local needYuanBao = 0
  local allYuanBao = ItemModule.Instance():GetAllYuanBao()
  if needYuanBaoReplace then
    local itemPrice = WingsUtility.GetReSetPropItemPrice(resetItemId)
    needYuanBao = itemPrice * (resetItemNumNeed - resetItemNumInBag)
    warn("price is : ", itemPrice, resetItemNumNeed, resetItemNumInBag)
    if allYuanBao:lt(needYuanBao) then
      Toast(textRes.Common[15])
      return
    end
  end
  local isUseYuanBao = 0
  if needYuanBaoReplace then
    isUseYuanBao = 1
  end
  warn("reset wing prop  ", isUseYuanBao, needYuanBao)
  local idx = WingsDataMgr.Instance():GetCurrentSchemaIdx()
  local p = require("netio.protocol.mzm.gsp.wing.CRestWingProperty").new(idx, isUseYuanBao, allYuanBao, needYuanBao)
  gmodule.network.sendProtocol(p)
end
def.method().OnBtnReplaceClicked = function(self)
  if not WingsDataMgr.Instance():IsResetPropAvalible() then
    Toast(textRes.Wings[20])
    return
  end
  local idx = WingsDataMgr.Instance():GetCurrentSchemaIdx()
  local p = require("netio.protocol.mzm.gsp.wing.CReplaceWingProperty").new(idx)
  gmodule.network.sendProtocol(p)
end
def.static("table", "table").OnResetPropChanged = function(params, context)
  instance:UpdateResetPropInfo()
end
def.static("table", "table").OnCurrentPropChanged = function(params, context)
  instance:UpdateCurrentPropInfo()
end
def.static("table", "table").OnBagInfoSyncronized = function(params, context)
  instance:UpdateConsumeItemInfo()
  instance:UpdateResetBtnState()
end
return WingsPropPanel.Commit()
