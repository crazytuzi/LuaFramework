local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIJewelTransform = Lplus.Extend(ECPanelBase, MODULE_NAME)
local def = UIJewelTransform.define
local instance
local GUIUtils = require("GUI.GUIUtils")
local ItemModule = require("Main.Item.ItemModule")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local ItemUtils = require("Main.Item.ItemUtils")
local JewelTransMgr = require("Main.GodWeapon.JewelTransMgr")
local JewelUtils = require("Main.GodWeapon.Jewel.JewelUtils")
local JewelMgr = require("Main.GodWeapon.JewelMgr")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local txtConst = textRes.GodWeapon.Jewel
local const = constant.SuperEquipmentJewelConstants
local Cls = UIJewelTransform
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.static("=>", UIJewelTransform).Instance = function()
  if instance == nil then
    instance = UIJewelTransform()
  end
  return instance
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GET_TRANSFORM_COUNT, Cls.OnQueryTransCountRes, self)
  Event.RegisterEventWithContext(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GET_JEWELS_PRICE, Cls.OnQueryPriceRes, self)
  Event.RegisterEventWithContext(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.TRANS_JEWEL_SUCCESS, Cls.OnTransJewelSuccess, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, Cls.OnGoldMoneyChanged, self)
  Event.RegisterEventWithContext(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.TRANS_JEWEL_FAILED, Cls.OnTransJewelFailed, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_GodWeapon_Bag_Change, Cls.OnJewelBagChange, self)
  self._uiStatus.selIdx = 1
  self:_initUI()
end
def.method()._initUI = function(self)
  self._uiGOs.groupList = self.m_panel:FindDirect("Img_Bg1/Goup_List")
  self._uiGOs.groupRight = self.m_panel:FindDirect("Img_Bg1/Group_Right")
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GET_TRANSFORM_COUNT, Cls.OnQueryTransCountRes)
  Event.UnregisterEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GET_JEWELS_PRICE, Cls.OnQueryPriceRes)
  Event.UnregisterEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.TRANS_JEWEL_SUCCESS, Cls.OnTransJewelSuccess)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, Cls.OnGoldMoneyChanged)
  Event.UnregisterEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.TRANS_JEWEL_FAILED, Cls.OnTransJewelFailed)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_GodWeapon_Bag_Change, Cls.OnJewelBagChange)
  self._uiGOs = nil
  self._uiStatus = nil
end
def.override("boolean").OnShow = function(self, s)
  if s then
    self:_updateUI()
  else
  end
end
def.method()._updateUI = function(self)
  self:_updateUILeft()
  if self._uiStatus == nil or #self._uiStatus.owndJewels == 0 then
    return
  end
  self:_updateUIRight()
end
def.method()._updateUILeft = function(self)
  local ctrlScrollView = self._uiGOs.groupList:FindDirect("Scroll View_List")
  local ctrlUIList = ctrlScrollView:FindDirect("Grid_List")
  self._uiStatus.owndJewels = JewelTransMgr.GetJewelWithLv(const.TRANSFER_MIN_JEWEL_LEVEL)
  if #self._uiStatus.owndJewels < 1 then
    Toast(txtConst[54])
    self:DestroyPanel()
    return
  end
  if 1 > self._uiStatus.selIdx then
    self._uiStatus.selIdx = 1
  end
  table.sort(self._uiStatus.owndJewels, function(a, b)
    return a.basicCfg.level < b.basicCfg.level
  end)
  local owndJewels = self._uiStatus.owndJewels or {}
  local ctrlJewelList = GUIUtils.InitUIList(ctrlUIList, #owndJewels)
  self._uiStatus.ctrlJewelList = ctrlJewelList
  for i = 1, #ctrlJewelList do
    self:_fillJewelInfo(ctrlJewelList[i], owndJewels[i], i)
  end
end
def.method("userdata", "table", "number")._fillJewelInfo = function(self, ctrl, itemInfo, idx)
  local lblName = ctrl:FindDirect("Label_Name_" .. idx)
  local equip = ctrl:FindDirect("Group_Icon_" .. idx)
  local imgIcon = equip:FindDirect("Icon_Equip01_" .. idx)
  local imgIconBg = equip:FindDirect("Icon_BgEquip01_" .. idx)
  local lblNum = equip:FindDirect("Label_Num_" .. idx)
  local lblAttr = ctrl:FindDirect("Label_Attribute_" .. idx)
  local item, jewelBasic = itemInfo.item, itemInfo.basicCfg
  local itemBase = ItemUtils.GetItemBase(item.id)
  GUIUtils.SetTexture(imgIcon, itemBase.icon)
  GUIUtils.SetSprite(imgIconBg, ItemUtils.GetItemFrame({
    id = item.id
  }, itemBase))
  GUIUtils.SetText(lblNum, item.number)
  local propName = JewelUtils.GetProName(jewelBasic.arrProps[1].propType)
  local propVal = jewelBasic.arrProps[1].propVal
  GUIUtils.SetText(lblAttr, txtConst[47]:format(propName, propVal))
  GUIUtils.SetText(lblName, itemBase.name)
  local comToggle = ctrl:GetComponent("UIToggle")
  comToggle.value = idx == self._uiStatus.selIdx
end
def.method()._updateUIRight = function(self)
  self._uiStatus.moneyType = 2
  local allJewels = self._uiStatus.owndJewels
  self:_updateUISrcJewel(allJewels[self._uiStatus.selIdx].basicCfg)
  self:_updateUIDstJewel(self._uiStatus.dstJewel)
  self:_updateUIBackMoney(self._uiStatus.needMoney or 0)
  self:_updateLeftTimes(self._uiStatus.iCanTransNum)
  self:_updateUIOwnMoney()
end
def.method("table")._updateUISrcJewel = function(self, jewelInfo)
  local ctrlRoot = self._uiGOs.groupRight:FindDirect("Group_Top/Group_IconNow")
  self:_fillRightJewelInfo(ctrlRoot, jewelInfo)
end
def.method("table")._updateUIDstJewel = function(self, jewelInfo)
  local ctrlRoot = self._uiGOs.groupRight:FindDirect("Group_Top/Group_IconNext")
  self:_fillRightJewelInfo(ctrlRoot, jewelInfo)
end
def.method("userdata", "table")._fillRightJewelInfo = function(self, ctrlRoot, jewelInfo)
  local lblName = ctrlRoot:FindDirect("Label_Name")
  local icon = ctrlRoot:FindDirect("Icon")
  local iconBg = ctrlRoot:FindDirect("Icon_Bg")
  icon:SetActive(jewelInfo ~= nil)
  lblName:SetActive(jewelInfo ~= nil)
  if jewelInfo == nil then
    return
  end
  local itemBase = ItemUtils.GetItemBase(jewelInfo.itemId)
  GUIUtils.SetTexture(icon, itemBase.icon)
  GUIUtils.SetText(lblName, itemBase.name)
  GUIUtils.SetSprite(iconBg, ItemUtils.GetItemFrame({
    id = jewelInfo.itemId
  }, itemBase))
end
def.method("number")._updateUIBackMoney = function(self, num)
  local ctrlRoot = self._uiGOs.groupRight:FindDirect("Group_Top/Cost_BgCoin")
  local iconMoney = ctrlRoot:FindDirect("Img_Coin")
  local lblNum = ctrlRoot:FindDirect("Label_Cost")
  local lblName = ctrlRoot:FindDirect("Label")
  if num > 0 then
    GUIUtils.SetText(lblName, txtConst[49])
  else
    GUIUtils.SetText(lblName, txtConst[48])
  end
  local moneyData = CurrencyFactory.Create(self._uiStatus.moneyType)
  GUIUtils.SetText(lblNum, math.floor(math.abs(num)))
  GUIUtils.SetSprite(iconMoney, moneyData:GetSpriteName())
end
def.method("number")._updateLeftTimes = function(self, num)
  local lblNum = self._uiGOs.groupRight:FindDirect("Group_Top/Label_LeftExchangeNum/Label_Num")
  GUIUtils.SetText(lblNum, num)
end
def.method()._updateUIOwnMoney = function(self)
  local ctrlRoot = self._uiGOs.groupRight:FindDirect("Own_BgCoin")
  local iconMoney = ctrlRoot:FindDirect("Img_Coin")
  local lblNum = ctrlRoot:FindDirect("Label_Coin")
  local owndMoney = JewelMgr.GetMoneyNumByType(self._uiStatus.moneyType)
  local moneyData = CurrencyFactory.Create(self._uiStatus.moneyType)
  GUIUtils.SetSprite(iconMoney, moneyData:GetSpriteName())
  GUIUtils.SetText(lblNum, owndMoney:tostring())
end
def.method()._showAllClsJewels = function(self)
end
def.method("number").ShowPanel = function(self, iTimes)
  if self:IsLoaded() then
    return
  end
  self._uiGOs = {}
  self._uiStatus = {}
  self._uiStatus.iCanTransNum = iTimes
  self._uiStatus.bTransFinish = true
  self:CreatePanel(RESPATH.PREFAB_JEWEL_TRANS, 1)
  self:SetModal(true)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Add" then
    JewelMgr.GotoBuyMoney(self._uiStatus.moneyType, false)
  elseif id == "Btn_Exchange" then
    self:onClick2Transform()
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Choose" then
    self:onClickShowJewelList()
  elseif string.find(id, "Group_ListItem1_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[3])
    if idx == self._uiStatus.selIdx then
      return
    end
    local ctrl = self._uiStatus.ctrlJewelList[idx]
    local srcJewel
    local comToggle = ctrl:GetComponent("UIToggle")
    if comToggle.value then
      self._uiStatus.selIdx = idx
      srcJewel = self._uiStatus.owndJewels[idx].basicCfg
    else
      srcJewel = nil
      self._uiStatus.selIdx = 0
    end
    self._uiStatus.needMoney = 0
    self:_updateUIBackMoney(self._uiStatus.needMoney)
    self:_updateUISrcJewel(srcJewel)
    if self._uiStatus.dstJewel and (srcJewel.level ~= self._uiStatus.dstJewel.level or srcJewel.itemId == self._uiStatus.dstJewel.itemId) then
      self._uiStatus.dstJewel = nil
      self:_updateUIDstJewel(nil)
    end
  end
end
def.method().onClick2Transform = function(self)
  if self._uiStatus.selIdx < 1 then
    Toast(txtConst[50])
    return
  end
  local iCanTransNum = self._uiStatus.iCanTransNum or 0
  if iCanTransNum < 1 then
    Toast(txtConst[52]:format(const.MAX_TRANSFER_COUNT))
    return
  end
  local selJewelInfo = self._uiStatus.owndJewels[self._uiStatus.selIdx].item
  local dstJewelInfo = self._uiStatus.dstJewel
  if dstJewelInfo == nil then
    Toast(txtConst[50])
    return
  end
  if self._uiStatus.needMoney == nil then
    Cls.SelJewelCallback(self._uiStatus.dstJewel)
    return
  end
  local owndMoney = JewelMgr.GetMoneyNumByType(self._uiStatus.moneyType)
  if Int64.lt(owndMoney, math.floor(-self._uiStatus.needMoney)) then
    JewelMgr.GotoBuyMoney(self._uiStatus.moneyType, true)
    return
  end
  if selJewelInfo ~= nil then
    if not self._uiStatus.bTransFinish then
      Toast(txtConst[53])
      return
    end
    local bagId = ItemModule.Instance():GetBagIdByItemId(selJewelInfo.id)
    JewelTransMgr.Send2TransJewelReq(bagId, selJewelInfo.itemKey, dstJewelInfo.itemId)
  end
end
def.method().onClickShowJewelList = function(self)
  if self._uiStatus.selIdx < 1 then
    Toast(txtConst[50])
    return
  end
  local selJewelBasic = self._uiStatus.owndJewels[self._uiStatus.selIdx].basicCfg
  require("Main.GodWeapon.ui.JewelChoosePanel").Instance():ShowPanel(selJewelBasic.itemId, selJewelBasic.level, Cls.SelJewelCallback)
end
def.method("table").OnQueryTransCountRes = function(self, p)
  self._uiStatus.iCanTransNum = p.count
  self:_updateLeftTimes(p.count)
end
def.method("table").OnQueryPriceRes = function(self, p)
  local srcJewel = self._uiStatus.owndJewels[self._uiStatus.selIdx].basicCfg
  local dstJewel = self._uiStatus.dstJewel
  local priceMap = p.jewelCfgId2price
  local srcPrice = priceMap[srcJewel.itemId] or 0
  local dstPrice = priceMap[dstJewel.itemId] or 0
  self._uiStatus.needMoney = srcPrice - dstPrice
  self:_updateUIBackMoney(self._uiStatus.needMoney)
end
def.method("table").OnTransJewelSuccess = function(self, p)
  self._uiStatus.bTransFinish = true
  if not self:IsShow() then
    return
  end
  self._uiStatus.iCanTransNum = p.availableTransferCount
  self._uiStatus.dstJewel = nil
  self._uiStatus.selIdx = -1
  self._uiStatus.needMoney = 0
  self:_updateUI()
end
def.method("table").OnTransJewelFailed = function(self, p)
  self._uiStatus.bTransFinish = true
end
def.static("table").SelJewelCallback = function(selJewel)
  local self = instance
  if self.m_panel == nil or instance.m_panel.isnil then
    return
  end
  local srcJewel = self._uiStatus.owndJewels[self._uiStatus.selIdx].basicCfg
  self._uiStatus.dstJewel = selJewel
  self:_updateUIDstJewel(selJewel)
  local jewels = {}
  table.insert(jewels, selJewel.itemId)
  table.insert(jewels, srcJewel.itemId)
  JewelTransMgr.CQueryJewelsPrice(jewels)
end
def.method("table").OnGoldMoneyChanged = function(self, p)
  self:_updateUIOwnMoney()
end
def.method("table").OnJewelBagChange = function(self, p)
  if not self:IsShow() then
    return
  end
  self:_updateUI()
end
return UIJewelTransform.Commit()
