local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FabaoSpiritProtocols = require("Main.FabaoSpirit.FabaoSpiritProtocols")
local FabaoSpiritUtils = require("Main.FabaoSpirit.FabaoSpiritUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local MallUtility = require("Main.Mall.MallUtility")
local FabaoSpiritInterface = require("Main.FabaoSpirit.FabaoSpiritInterface")
local QuickImprovePanel = Lplus.Extend(ECPanelBase, "QuickImprovePanel")
local def = QuickImprovePanel.define
local instance
def.static("=>", QuickImprovePanel).Instance = function()
  if instance == nil then
    instance = QuickImprovePanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("table")._lqInfo = nil
def.field("table")._basePropCfg = nil
def.field("table")._improvePropCfg = nil
def.field("table")._itemBase = nil
def.field("boolean")._bUseYB = true
def.field("number")._YBPrice = 0
def.static("table", "number").ShowPanel = function(lqInfo, attrIdx)
  if not _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_FABAOLINGQI) then
    if QuickImprovePanel.Instance():IsShow() then
      QuickImprovePanel.Instance():DestroyPanel()
    end
    return
  end
  if not QuickImprovePanel.Instance():_InitData(lqInfo, attrIdx) then
    if QuickImprovePanel.Instance():IsShow() then
      QuickImprovePanel.Instance():DestroyPanel()
    end
    return
  end
  if QuickImprovePanel.Instance():IsShow() then
    QuickImprovePanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_LQ_QUICK_IMPROVE, 2)
end
def.method("table", "number", "=>", "boolean")._InitData = function(self, lqInfo, attrIdx)
  if nil == lqInfo then
    warn("[ERROR][QuickImprovePanel:_InitData] self._lqInfo nil!")
    return false
  end
  self._lqInfo = lqInfo
  local lqPropCfg = self:GetLQPropCfg(lqInfo)
  self._basePropCfg = lqPropCfg and lqPropCfg.arrPropValues[attrIdx]
  local lqImproveCfg = lqPropCfg and FabaoSpiritUtils.GetFabaoLQImproveCfgById(lqPropCfg.improveCfgId)
  self._improvePropCfg = lqImproveCfg and lqImproveCfg.arrPropValues[attrIdx]
  self._itemBase = self._improvePropCfg and ItemUtils.GetItemFilterCfg(self._improvePropCfg.itemFilterId)
  if self._basePropCfg and self._improvePropCfg and self._itemBase then
    return true
  else
    warn("[ERROR][QuickImprovePanel:_InitData] self._basePropCfg or self._improvePropCfg or self._itemBase nil:", self._basePropCfg, self._improvePropCfg, self._itemBase)
    return false
  end
end
def.method("table", "=>", "table").GetLQPropCfg = function(self, lqInfo)
  if nil == lqInfo then
    return nil
  end
  local cfgId = FabaoSpiritInterface.GetLQCfgIDByLQInfo(lqInfo)
  local propCfg = FabaoSpiritUtils.GetFabaoLQPropCfgById(cfgId)
  return propCfg
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
  GUIUtils.SetText(self._uiObjs.Label_Title, textRes.FabaoSpirit[38])
  self:UpdateUI(true)
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Label_Title = self.m_panel:FindDirect("Img_Bg/Label_Title")
  self._uiObjs.Label_Tips = self.m_panel:FindDirect("Img_Bg/Img_BgWords/Label")
  self._uiObjs.TextureIcon = self.m_panel:FindDirect("Img_Bg/Group_Cost/Label_UseItemNum/Texture")
  self._uiObjs.Label_UseItemNum = self.m_panel:FindDirect("Img_Bg/Group_Cost/Label_UseItemNum")
  self._uiObjs.Label_UseYuanBaoNum = self.m_panel:FindDirect("Img_Bg/Group_Cost/Label_UseYuanBaoNum")
  self._uiObjs.Toggle_YuanBao = self.m_panel:FindDirect("Img_Bg/Group_Cost/Toggle_YuanBao")
  self._uiObjs.uiToggle = self._uiObjs.Toggle_YuanBao:GetComponent("UIToggle")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
  else
  end
end
def.method("boolean").UpdateUI = function(self, bUseYB)
  self._bUseYB = bUseYB
  GUIUtils.Toggle(self._uiObjs.Toggle_YuanBao, self._bUseYB)
  local curPropValue = self._lqInfo.properties[self._basePropCfg.propType]
  local maxPropValue = self._basePropCfg.dstVal
  if curPropValue >= maxPropValue then
    GUIUtils.SetText(self._uiObjs.Label_Tips, textRes.FabaoSpirit[41])
    GUIUtils.SetText(self._uiObjs.Label_UseItemNum, 0)
    GUIUtils.SetText(self._uiObjs.Label_UseYuanBaoNum, 0)
  else
    do
      local ownNum, itemId = FabaoSpiritInterface.GetItemsNumByFilterId(self._improvePropCfg.itemFilterId)
      local attrName = FabaoSpiritUtils.GetFabaoSpiritProName(self._basePropCfg.propType)
      if self._bUseYB then
        do
          local diffValue = maxPropValue - curPropValue
          local needItemCount = math.floor(diffValue / self._improvePropCfg.improveVal) * self._improvePropCfg.itemNum
          warn("[QuickImprovePanel:UpdateUI] diffValue, self._improvePropCfg.improveVal, needItemCount:", diffValue, self._improvePropCfg.improveVal, needItemCount)
          local tip = string.format(textRes.FabaoSpirit[39], attrName, curPropValue, maxPropValue)
          GUIUtils.SetText(self._uiObjs.Label_Tips, tip)
          local itemCount = math.min(ownNum, needItemCount)
          GUIUtils.SetText(self._uiObjs.Label_UseItemNum, itemCount)
          local lackCount = math.max(0, needItemCount - ownNum)
          require("Main.Item.ItemConsumeHelper").Instance():GetItemYuanBaoPrice(itemId, function(price)
            if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.Label_UseYuanBaoNum) then
              self._YBPrice = price
              GUIUtils.SetText(self._uiObjs.Label_UseYuanBaoNum, self._YBPrice * lackCount)
              warn("[QuickImprovePanel:UpdateUI] ownNum, useCount, lackCount, self._YBPrice:", ownNum, itemCount, lackCount, self._YBPrice)
            end
          end)
          GUIUtils.SetText(self._uiObjs.Label_UseYuanBaoNum, self._YBPrice * lackCount)
          warn("[QuickImprovePanel:UpdateUI] ownNum, useCount, lackCount, self._YBPrice:", ownNum, itemCount, lackCount, self._YBPrice)
        end
      else
        local itemCount = 0
        local improveAttr = 0
        if ownNum >= self._improvePropCfg.itemNum then
          while ownNum >= itemCount + self._improvePropCfg.itemNum and maxPropValue >= curPropValue + improveAttr + self._improvePropCfg.improveVal do
            itemCount = itemCount + self._improvePropCfg.itemNum
            improveAttr = improveAttr + self._improvePropCfg.improveVal
          end
          local tip = string.format(textRes.FabaoSpirit[39], attrName, curPropValue, curPropValue + improveAttr)
          GUIUtils.SetText(self._uiObjs.Label_Tips, tip)
        else
          GUIUtils.SetText(self._uiObjs.Label_Tips, textRes.FabaoSpirit[42])
        end
        local itemCount = math.min(ownNum, itemCount)
        GUIUtils.SetText(self._uiObjs.Label_UseItemNum, itemCount)
        GUIUtils.SetText(self._uiObjs.Label_UseYuanBaoNum, 0)
      end
    end
  end
end
def.method("table", "=>", "number").GetFilterItemPrice = function(self, itemFilterCfg)
  if nil == itemFilterCfg or itemFilterCfg.siftCfgs == nil then
    return 0
  end
  local ret = 0
  for i = 1, #itemFilterCfg.siftCfgs do
    local itemId = itemFilterCfg.siftCfgs[i].idvalue
    ret = MallUtility.GetPriceByItemId(itemId)
    if ret > 0 then
      break
    end
  end
  return ret
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._uiObjs = nil
  self._lqInfo = nil
  self._basePropCfg = nil
  self._improvePropCfg = nil
  self._itemBase = nil
  self._bUseYB = true
  self._YBPrice = 0
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:OnBtn_Close()
  elseif id == "Toggle_YuanBao" then
    self:OnToggle_YuanBao()
  elseif id == "Btn_Cancel" then
    self:OnBtn_Close()
  elseif id == "Btn_Confirm" then
    self:OnBtn_Confirm()
  end
end
def.method().OnBtn_Close = function(self)
  self:DestroyPanel()
end
def.method().OnToggle_YuanBao = function(self)
  local bUseYB = self._uiObjs.uiToggle.value
  self:UpdateUI(bUseYB)
end
def.method().OnBtn_Confirm = function(self)
  local ownedYuanBao = ItemModule.Instance():GetAllYuanBao() or Int64.new(0)
  FabaoSpiritProtocols.SendCPetFightSetTeamFormationReq(self._lqInfo.class_id, self._basePropCfg.propType, self._bUseYB, ownedYuanBao)
  self:DestroyPanel()
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, QuickImprovePanel.OnBagInfoSynchronized)
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(params, context)
  warn("[QuickImprovePanel:OnBagInfoSynchronized] OnBagInfoSynchronized.")
  local self = QuickImprovePanel.Instance()
  if self and self:IsShow() then
    self:UpdateUI(self._bUseYB)
  end
end
QuickImprovePanel.Commit()
return QuickImprovePanel
