local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local AircraftData = require("Main.Aircraft.data.AircraftData")
local AircraftUIModel = require("Main.Aircraft.ui.AircraftUIModel")
local ECUIModel = require("Model.ECUIModel")
local AircraftProtocols = require("Main.Aircraft.AircraftProtocols")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local EasyBasicItemTip = require("Main.Common.EasyBasicItemTip")
local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local CurrencyType = require("consts.mzm.gsp.common.confbean.CurrencyType")
local FlyModule = require("Main.Fly.FlyModule")
local AircraftDyePanel = Lplus.Extend(ECPanelBase, "AircraftDyePanel")
local def = AircraftDyePanel.define
local instance
def.static("=>", AircraftDyePanel).Instance = function()
  if instance == nil then
    instance = AircraftDyePanel()
  end
  return instance
end
def.field(EasyBasicItemTip).itemTipHelper = nil
def.field("table")._uiObjs = nil
def.field("table")._aircraftInfo = nil
def.field("table")._aircraftCfg = nil
def.field("boolean")._isDrag = false
def.field(ECUIModel)._aircraftModel = nil
def.field(ECUIModel)._heroModel = nil
def.field("number")._selectDyeIdx = 0
def.field("table")._dyeCfgList = nil
def.field("boolean")._bUseYB = false
def.field("number")._useYuanBaoNum = 0
def.static("table").ShowPanel = function(aircraftInfo)
  if not AircraftDyePanel.Instance():_InitData(aircraftInfo) then
    if AircraftDyePanel.Instance():IsShow() then
      AircraftDyePanel.Instance():DestroyPanel()
    end
    return
  end
  if AircraftDyePanel.Instance():IsShow() then
    AircraftDyePanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_AIRCRAFT_DYE_PANEL, 1)
end
def.override().OnCreate = function(self)
  self.itemTipHelper = EasyBasicItemTip()
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Model = self.m_panel:FindDirect("Img_Bg/Model")
  self._uiObjs.uiModel = self._uiObjs.Model:GetComponent("UIModel")
  self._uiObjs.Img_Item = self.m_panel:FindDirect("Img_Bg/Img_Item")
  self._uiObjs.Label_ItemName = self._uiObjs.Img_Item:FindDirect("Label_ItemName")
  self._uiObjs.Texture_Item = self._uiObjs.Img_Item:FindDirect("Texture_Item")
  self._uiObjs.Label_Num = self._uiObjs.Img_Item:FindDirect("Label_Num")
  self._uiObjs.Btn_UseGold = self._uiObjs.Img_Item:FindDirect("Btn_UseGold")
  self._uiObjs.DyeItemGroup = self.m_panel:FindDirect("Img_Bg/Btn_Dye/Label")
  self._uiObjs.DyeYBGroup = self.m_panel:FindDirect("Img_Bg/Btn_Dye/Group_Yuanbao")
  self._uiObjs.DyeYBLabel = self._uiObjs.DyeYBGroup:FindDirect("Label_Money")
  self._uiObjs.Container = self.m_panel:FindDirect("Img_Bg/Group_Color/Container")
  self._uiObjs.ColorList = {}
  local idx = 1
  local colorItem = self._uiObjs.Container:FindDirect("WingColor" .. idx)
  while colorItem do
    table.insert(self._uiObjs.ColorList, colorItem)
    idx = idx + 1
    colorItem = self._uiObjs.Container:FindDirect("WingColor" .. idx)
  end
end
def.method("table", "=>", "boolean")._InitData = function(self, aircraftInfo)
  self._aircraftInfo = aircraftInfo
  self._aircraftCfg = aircraftInfo and AircraftData.Instance():GetAircraftCfg(aircraftInfo.cfgId)
  self._dyeCfgList = AircraftData.Instance():GetSortedDyeCfgs(aircraftInfo.cfgId)
  if self._aircraftInfo and self._aircraftCfg then
    return true
  else
    return false
  end
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  self:FillAircraftModel()
  self:ShowDyeColors()
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self.itemTipHelper = nil
  self._aircraftInfo = nil
  self._aircraftCfg = nil
  self._isDrag = false
  if not _G.IsNil(self._aircraftModel) then
    self._aircraftModel:Destroy()
    self._aircraftModel = nil
  end
  if not _G.IsNil(self._heroModel) then
    self._heroModel:Destroy()
    self._heroModel = nil
  end
  self._selectDyeIdx = 0
  self._dyeCfgList = nil
  self._bUseYB = false
  self._useYuanBaoNum = 0
  self._uiObjs = nil
end
def.method().FillAircraftModel = function(self)
  local colorId = self:GetSelectColor()
  if colorId == 0 then
    colorId = self._aircraftInfo.colorId
  end
  local function callback()
    if self:IsModelLoaded(self._heroModel) then
      self._aircraftModel:AttachRole(self._heroModel)
    elseif _G.IsNil(self._heroModel) then
      self:LoadHeroModel()
    end
    self:DyeAircraft()
  end
  if _G.IsNil(self._aircraftModel) then
    self._aircraftModel = AircraftUIModel.new(self._aircraftCfg.id, colorId, self._uiObjs.uiModel)
    self._aircraftModel:LoadWithCB(function(model)
      if _G.IsNil(model) then
        return
      end
      if _G.IsNil(self.m_panel) or _G.IsNil(self._uiObjs.uiModel) then
        return
      end
      callback()
    end)
  elseif not self._aircraftModel:IsInLoading() then
    self._aircraftModel:Play(FlyModule.FlyIdleAnimation)
    callback()
  end
end
def.method().LoadHeroModel = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local modelId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyModelId()
  self._heroModel = ECUIModel.new(modelId)
  self._heroModel.m_bUncache = true
  local modelInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleModelInfo(gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId)
  local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
  modelInfo.extraMap[ModelInfo.MAGIC_MARK] = nil
  self._heroModel:AddOnLoadCallback("AircraftDyePanel", function()
    if _G.IsNil(self.m_panel) then
      self._heroModel:Destroy()
      self._heroModel = nil
      return
    end
    if _G.IsNil(self._heroModel) or _G.IsNil(self._heroModel.m_model) then
      return
    end
    if self:IsModelLoaded(self._aircraftModel) then
      self._aircraftModel:AttachRole(self._heroModel)
    end
  end)
  _G.LoadModel(self._heroModel, modelInfo, 0, 0, 180, false, false)
end
def.method(ECUIModel, "=>", "boolean").IsModelLoaded = function(self, ecUIModel)
  if not _G.IsNil(ecUIModel) and not ecUIModel:IsInLoading() then
    return true
  else
    return false
  end
end
def.method().ShowDyeColors = function(self)
  self:_ClearList()
  local dyeColorCount = self._dyeCfgList and #self._dyeCfgList or 0
  local selectIdx = self._selectDyeIdx
  if dyeColorCount > 0 then
    for i = 1, dyeColorCount do
      local dyeCfg = self._dyeCfgList[i]
      local colorItem = self._uiObjs.ColorList[i]
      if colorItem then
        GUIUtils.SetActive(colorItem, true)
        local color = Color.Color(1, 1, 1, 1)
        if 0 < dyeCfg.colorId then
          local colorCfg = GetModelColorCfg(dyeCfg.colorId)
          if colorCfg then
            local alpha = (colorCfg.part2_a < 128 and colorCfg.part2_a or 128) / 255 * 2
            color.r = colorCfg.part2_r / 255 * alpha
            color.g = colorCfg.part2_g / 255 * alpha
            color.b = colorCfg.part2_b / 255 * alpha
            color.a = 1
          end
        end
        GUIUtils.SetColor(colorItem, color, GUIUtils.COTYPE.SPRITE)
        if selectIdx == 0 and dyeCfg.colorId == self._aircraftInfo.colorId then
          selectIdx = i
        end
      else
        warn("[ERROR][AircraftDyePanel:ShowDyeColors] colorItem nil at idx:", i)
      end
    end
  end
  self:SelectColor(selectIdx)
end
def.method("number").SelectColor = function(self, idx)
  local dyeCfg = self._dyeCfgList[idx]
  if nil == dyeCfg then
    warn("[ERROR][AircraftDyePanel:SelectColor] dyeCfg nil at idx:", idx)
    return
  end
  self._selectDyeIdx = idx
  local colorItem = self._uiObjs.ColorList and self._uiObjs.ColorList[idx]
  if colorItem then
    GUIUtils.Toggle(colorItem, true)
  else
  end
  self:DyeAircraft()
  self:UpdateCostItem(self._bUseYB)
end
def.method().DyeAircraft = function(self)
  if not _G.IsNil(self._aircraftModel) and not self._aircraftModel:IsInLoading() then
    local colorId = self:GetSelectColor()
    self._aircraftModel:Dye(colorId)
  end
end
def.method("=>", "number").GetSelectColor = function(self)
  local dyeCfg = self._dyeCfgList and self._dyeCfgList[self._selectDyeIdx]
  local colorId = dyeCfg and dyeCfg.colorId or 0
  return colorId
end
def.method()._ClearList = function(self)
  if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.ColorList) and #self._uiObjs.ColorList > 0 then
    for i = 1, #self._uiObjs.ColorList do
      local colorItem = self._uiObjs.ColorList[i]
      GUIUtils.SetActive(colorItem, false)
    end
  end
end
def.method("boolean").UpdateCostItem = function(self, bUseYB)
  self._bUseYB = bUseYB
  local dyeCfg = self._dyeCfgList[self._selectDyeIdx]
  if nil == dyeCfg then
    GUIUtils.SetActive(self._uiObjs.Img_Item, false)
    GUIUtils.SetActive(self._uiObjs.DyeItemGroup, true)
    GUIUtils.SetActive(self._uiObjs.DyeYBGroup, false)
  elseif dyeCfg.colorId == self._aircraftInfo.colorId then
    GUIUtils.SetActive(self._uiObjs.Img_Item, false)
    GUIUtils.SetActive(self._uiObjs.DyeItemGroup, true)
    GUIUtils.SetActive(self._uiObjs.DyeYBGroup, false)
  else
    do
      local costItemId = dyeCfg.itemId
      local costItemNum = dyeCfg.itemCount
      local itemBase = ItemUtils.GetItemBase(costItemId)
      if itemBase then
        GUIUtils.SetActive(self._uiObjs.Img_Item, true)
        GUIUtils.SetText(self._uiObjs.Label_ItemName, itemBase.name)
        GUIUtils.SetTexture(self._uiObjs.Texture_Item, itemBase.icon)
        do
          local haveNum = ItemModule.Instance():GetItemCountById(costItemId)
          local textColor = costItemNum <= haveNum and Color.green or Color.red
          GUIUtils.SetTextAndColor(self._uiObjs.Label_Num, haveNum .. "/" .. costItemNum, textColor)
          self.itemTipHelper:RegisterItem2ShowTip(costItemId, self._uiObjs.Texture_Item)
          GUIUtils.Toggle(self._uiObjs.Btn_UseGold, self._bUseYB)
          if self._bUseYB then
            GUIUtils.SetActive(self._uiObjs.DyeItemGroup, false)
            GUIUtils.SetActive(self._uiObjs.DyeYBGroup, true)
            do
              local lackCount = math.max(0, costItemNum - haveNum)
              GUIUtils.SetText(self._uiObjs.DyeYBLabel, self._useYuanBaoNum)
              ItemConsumeHelper.Instance():GetItemYuanBaoPrice(costItemId, function(price)
                if not self:IsShow() or _G.IsNil(self._uiObjs.DyeYBLabel) then
                  return
                end
                self._useYuanBaoNum = price * lackCount
                GUIUtils.SetText(self._uiObjs.DyeYBLabel, self._useYuanBaoNum)
                warn(string.format("[AircraftDyePanel:UpdateCostItem] costItemNum[%d], haveNum[%d], lackCount[%d], price[%d], self._useYuanBaoNum[%d]", costItemNum, haveNum, lackCount, price, self._useYuanBaoNum))
              end)
            end
          else
            GUIUtils.SetActive(self._uiObjs.DyeItemGroup, true)
            GUIUtils.SetActive(self._uiObjs.DyeYBGroup, false)
          end
        end
      else
        warn("[ERROR][AircraftDyePanel:UpdateCostItem] itemBase nil for id:", costItemId)
        GUIUtils.SetActive(self._uiObjs.Img_Item, false)
        GUIUtils.SetActive(self._uiObjs.DyeItemGroup, true)
        GUIUtils.SetActive(self._uiObjs.DyeYBGroup, false)
      end
    end
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:OnBtn_Close()
  elseif id == "Btn_Tips" then
    self:OnBtn_Tips()
  elseif id == "Btn_Dye" then
    self:OnBtn_Dye()
  elseif id == "Texture_Item" then
    self:OnTexture_Item(id)
  elseif id == "Btn_UseGold" then
    self:OnBtn_UseGold()
  elseif string.find(id, "WingColor") then
    self:OnColorClicked(id)
  end
end
def.method().OnBtn_Close = function(self)
  self:DestroyPanel()
end
def.method().OnBtn_Tips = function(self)
  GUIUtils.ShowHoverTip(constant.CFeijianConsts.dye_tips_cfg_id, 0, 0)
end
def.method().OnBtn_Dye = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local dyeCfg = self._dyeCfgList[self._selectDyeIdx]
  if nil == dyeCfg then
    warn("[ERROR][AircraftDyePanel:OnBtn_Dye] dyeCfg nil at idx:", self._selectDyeIdx)
  elseif dyeCfg.colorId == self._aircraftInfo.colorId then
    Toast(textRes.Aircraft.AIRCRAFT_DYE_SAME_COLOR)
  else
    local costItemId = dyeCfg.itemId
    local costItemNum = dyeCfg.itemCount
    local haveNum = ItemModule.Instance():GetItemCountById(costItemId)
    if costItemNum <= haveNum or self._bUseYB then
      local moneyData = CurrencyFactory.Create(CurrencyType.YUAN_BAO)
      local haveYB = moneyData:GetHaveNum()
      if self._bUseYB and Int64.gt(self._useYuanBaoNum, haveYB) then
        moneyData:AcquireWithQuery()
      else
        local needYB = self._bUseYB and self._useYuanBaoNum or 0
        AircraftProtocols.SendCDyeAircraft(self._aircraftCfg.id, dyeCfg.colorId, self._bUseYB and 1 or 0, needYB, haveYB)
      end
    else
      require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Aircraft.AIRCRAFT_DYE_CONFIRM_TITLE, textRes.Aircraft.AIRCRAFT_DYE_CONFIRM_CONTENT, function(id, tag)
        if id == 1 then
          self:UpdateCostItem(true)
        end
      end, nil)
    end
  end
end
def.method("string").OnTexture_Item = function(self, id)
  local dyeCfg = self._dyeCfgList[self._selectDyeIdx]
  if nil == dyeCfg then
    warn("[ERROR][AircraftDyePanel:OnTexture_Item] dyeCfg nil at idx:", self._selectDyeIdx)
  else
    self.itemTipHelper:CheckItem2ShowTip(id, -1, true)
  end
end
def.method().OnBtn_UseGold = function(self)
  local bUseYB = self._uiObjs.Btn_UseGold:GetComponent("UIToggle").value
  if bUseYB then
    local dyeCfg = self._dyeCfgList[self._selectDyeIdx]
    if nil == dyeCfg then
      warn("[ERROR][AircraftDyePanel:OnBtn_UseGold] dyeCfg nil at idx:", self._selectDyeIdx)
    else
      local costItemId = dyeCfg.itemId
      local costItemNum = dyeCfg.itemCount
      local haveNum = ItemModule.Instance():GetItemCountById(costItemId)
      if costItemNum <= haveNum then
        Toast(textRes.Aircraft.AIRCRAFT_DYE_ITEM_ENOUGH)
        self:UpdateCostItem(false)
      else
        self:UpdateCostItem(bUseYB)
      end
    end
  else
    self:UpdateCostItem(bUseYB)
  end
end
def.method("string").OnColorClicked = function(self, id)
  local togglePrefix = "WingColor"
  local index = tonumber(string.sub(id, string.len(togglePrefix) + 1))
  self:SelectColor(index)
end
def.method("string").onDragStart = function(self, id)
  self._isDrag = true
end
def.method("string").onDragEnd = function(self, id)
  self._isDrag = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self._isDrag == true and not _G.IsNil(self._aircraftModel) then
    self._aircraftModel:SetDir(self._aircraftModel.m_ang - dx / 2)
  end
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.AIRCRAFT, gmodule.notifyId.Aircraft.AIRCRAFT_DYE_CHANGE, AircraftDyePanel.OnAircraftDyeChange)
    eventFunc(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, AircraftDyePanel.OnBagInfoSynchronized)
  end
end
def.static("table", "table").OnAircraftDyeChange = function(params, context)
  local self = AircraftDyePanel.Instance()
  if self:IsShow() then
    self:UpdateCostItem(self._bUseYB)
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(params, context)
  local self = AircraftDyePanel.Instance()
  if self:IsShow() then
    self:UpdateCostItem(self._bUseYB)
  end
end
AircraftDyePanel.Commit()
return AircraftDyePanel
