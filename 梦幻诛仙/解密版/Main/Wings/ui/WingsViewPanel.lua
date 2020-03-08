local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECUIModel = require("Model.ECUIModel")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local ItemData = require("Main.Item.ItemData")
local GUIUtils = require("GUI.GUIUtils")
local WingsUtility = require("Main.Wings.WingsUtility")
local WingsDataMgr = require("Main.Wings.data.WingsDataMgr")
local WingsViewPanel = Lplus.Extend(ECPanelBase, "WingsViewPanel")
local def = WingsViewPanel.define
def.field("table").model = nil
def.field("boolean").isDraggingModel = false
def.field("table").uiNodes = nil
def.field("number").schemaIdx = 0
def.field("table").wingsViewList = nil
def.field("boolean").isShowWings = false
def.field("number").curSelected = -1
def.field("boolean").isDyed = false
def.const("number").INITVIEWINDEX = 1
local instance
def.static("=>", WingsViewPanel).Instance = function()
  if instance == nil then
    instance = WingsViewPanel()
  end
  return instance
end
def.method("number").ShowPanel = function(self, idx)
  if self:IsShow() then
    return
  end
  if idx == 0 then
    return
  end
  self.schemaIdx = idx
  self:CreatePanel(RESPATH.PREFAB_WING_VIEW_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self.uiNodes = {}
  self.uiNodes.imgBG = self.m_panel:FindDirect("Img_Bg")
  self.uiNodes.groupLeft = self.uiNodes.imgBG:FindDirect("Group_Left")
  self.uiNodes.groupRight = self.uiNodes.imgBG:FindDirect("Group_Right")
  self.uiNodes.itemList = self.uiNodes.groupRight:FindDirect("Scroll View/List")
  self.uiNodes.tgShow = self.uiNodes.groupRight:FindDirect("Img_Toggle")
  self.uiNodes.toggleBtn = self.m_panel:FindDirect("Img_Bg/Group_Left/Img_Item/Btn_UseGold")
  self.uiNodes.yuanbaoGroup = self.m_panel:FindDirect("Img_Bg/Group_Left/Btn_RanSe/Group_Yuanbao")
  self.uiNodes.RanseBtnLabel = self.m_panel:FindDirect("Img_Bg/Group_Left/Btn_RanSe/Label")
  self.uiNodes.RanseBtnLabel:SetActive(true)
  self.uiNodes.yuanbaoGroup:SetActive(false)
  self.isShowWings = WingsDataMgr.Instance():GetIsWingsShowing() == 1
  self.curSelected = WingsViewPanel.INITVIEWINDEX
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_VIEW_DATA_CHANGED, WingsViewPanel.OnViewDataChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, WingsViewPanel.OnBagInfoSyncronized)
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_DYED, WingsViewPanel.OnWingsDyed)
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_CURRENT_VIEW_CHANGED, WingsViewPanel.OnCurrentViewChanged)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow == false then
    self:DestroyModel()
  else
    self:UpdateUI()
    self:UpdateModel()
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_VIEW_DATA_CHANGED, WingsViewPanel.OnViewDataChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, WingsViewPanel.OnBagInfoSyncronized)
  Event.UnregisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_DYED, WingsViewPanel.OnWingsDyed)
  Event.UnregisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_CURRENT_VIEW_CHANGED, WingsViewPanel.OnCurrentViewChanged)
  self:ClearUp()
end
def.method().DestroyModel = function(self)
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
end
def.method().ClearUp = function(self)
  self.schemaIdx = 0
  self.wingsViewList = nil
  self.isShowWings = false
  self.curSelected = -1
  self.isDyed = false
end
def.method().UpdateUI = function(self)
  self:UpdateWingsList()
  self:UpdateToggleWear()
  self:UpdateDyeItemInfo()
end
def.method().UpdateWingsList = function(self)
  self.wingsViewList = WingsDataMgr.Instance():GetWingsViewList()
  if not self.wingsViewList then
    return
  end
  local viewCount = #self.wingsViewList
  local uiList = self.uiNodes.itemList:GetComponent("UIList")
  uiList:set_itemCount(viewCount)
  uiList:Resize()
  local items = uiList.children
  for i = 1, viewCount do
    local item = items[i]
    local wingsView = self.wingsViewList[i]
    local viewCfg = WingsUtility.GetWingsViewCfg(wingsView.modelId)
    local uilabel = item:FindDirect("Label_Name"):GetComponent("UILabel")
    uilabel.text = viewCfg.name
    local uiTexture = item:FindDirect("Img_Icon/Texture"):GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, viewCfg.iconId)
    local imgSelect = item:FindDirect("Img_Select")
    imgSelect:SetActive(self.curSelected == i)
  end
  uiList:Resize()
  uiList:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().UpdateToggleWear = function(self)
  local uiToggle = self.uiNodes.groupRight:FindDirect("Img_Toggle"):GetComponent("UIToggle")
  uiToggle.isChecked = not self.isShowWings
end
def.method().UpdateDyeItemInfo = function(self)
  local dyeItemId = WingsDataMgr.WING_DYE_ITEM_ID
  local dyeItemNeeded = WingsDataMgr.WING_DYE_ITEM_NUM
  local ItemModule = require("Main.Item.ItemModule")
  local dyeItemNumInBag = ItemData.Instance():GetNumberByItemId(ItemModule.BAG, dyeItemId)
  local imgItem = self.uiNodes.groupLeft:FindDirect("Img_Item")
  local uiTexture = imgItem:FindDirect("Texture_Item"):GetComponent("UITexture")
  local uiLabelNum = imgItem:FindDirect("Label_Num"):GetComponent("UILabel")
  local uiLabelName = imgItem:FindDirect("Label_ItemName"):GetComponent("UILabel")
  local ItemUtils = require("Main.Item.ItemUtils")
  local dyeItemBase = ItemUtils.GetItemBase(dyeItemId)
  GUIUtils.FillIcon(uiTexture, dyeItemBase.icon)
  if dyeItemNeeded > dyeItemNumInBag then
    uiLabelNum:set_color(Color.red)
  else
    uiLabelNum:set_color(Color.white)
  end
  uiLabelNum:set_text(string.format("%d/%d", dyeItemNumInBag, dyeItemNeeded))
  uiLabelName:set_text(dyeItemBase.name)
end
def.method().UpdateModel = function(self)
  local uiModel = self.m_panel:FindDirect("Img_Bg/Group_Left/Model"):GetComponent("UIModel")
  if uiModel.mCanOverflow ~= nil then
    uiModel.mCanOverflow = true
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local modelId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyModelId()
  local modelPath = GetModelPath(modelId)
  if modelPath == nil then
    return
  end
  local function modelLoadCB()
    self.model:SetDir(180)
    self.model:Play("Stand_c")
    self.model:SetScale(1)
    self.model:SetPos(0, 0)
    self:UpdateModelExtra()
    uiModel.modelGameObject = self.model.m_model
  end
  if not self.model then
    self.model = ECUIModel.new(modelId)
    self.model.m_bUncache = true
    self.model:LoadUIModel(modelPath, function(ret)
      if self.model == nil or self.model.m_model == nil or self.model.m_model.isnil or uiModel == nil or uiModel.isnil then
        return
      end
      modelLoadCB()
    end)
  else
    modelLoadCB()
  end
end
def.method().UpdateModelExtra = function(self)
  local DyeingMgr = require("Main.Dyeing.DyeingMgr")
  local dyeData = DyeingMgr.GetCurClothData()
  if dyeData then
    if dyeData.hairid then
      local hairColor = DyeingMgr.GetColorFormula(dyeData.hairid)
      DyeingMgr.ChangeModelColor(DyeingMgr.PARTINDEX.HAIR, self.model, hairColor)
    end
    if dyeData.clothid then
      local clothColor = DyeingMgr.GetColorFormula(dyeData.clothid)
      DyeingMgr.ChangeModelColor(DyeingMgr.PARTINDEX.CLOTH, self.model, clothColor)
    end
  end
  local position = require("consts.mzm.gsp.item.confbean.WearPos")
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local weapon = ItemModule.Instance():GetHeroEquipmentCfg(position.WEAPON)
  local strenLevel = weapon and weapon.extraMap[ItemXStoreType.STRENGTH_LEVEL] or 0
  self.model:SetWeapon(weapon and weapon.id or 0, strenLevel or 0)
  local fabao = ItemModule.Instance():GetHeroEquipmentCfg(position.FABAO)
  self.model:SetFabao(fabao and fabao.id or 0)
  self:TryOnModelWings(self.curSelected)
end
def.method("number").TryOnModelWings = function(self, idx)
  if not self.model then
    return
  end
  if not self.isShowWings then
    self.model:SetWing(0, 0)
    return
  end
  local curView
  if idx == 0 then
    curView = WingsDataMgr.Instance():GetCurrentViewBySchemaIdx(self.schemaIdx)
  else
    if not self.wingsViewList then
      return
    end
    curView = self.wingsViewList[idx]
  end
  if not curView then
    return
  end
  self.model:SetWing(curView.modelId, curView.dyeId)
end
def.method("string").onDragStart = function(self, id)
  if id == "Model" then
    self.isDraggingModel = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self.isDraggingModel = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDraggingModel == true then
    self.model:SetDir(self.model.m_ang - dx / 2)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif string.find(id, "item_") == 1 then
    local idx = tonumber(string.sub(id, 6))
    self:OnListItemClicked(idx)
  elseif id == "Btn_Conform" then
    self:OnConfirmClicked()
  elseif id == "Btn_RanSe" then
    self:OnDyeWingsClicked()
  elseif id == "Img_Toggle" then
    self:OnToggleViewClicked()
  elseif id == "Texture_Item" then
    self:OnDyeItemClicked()
  elseif id == "Btn_Tips" then
    self:OnBtnTipsClicked()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_panelName
    })
  elseif id == "Btn_UseGold" then
    self:OnClickNeedYuanbaoReplace()
  end
end
def.method().OnClickNeedYuanbaoReplace = function(self)
  local toggleBtn = self.uiNodes.toggleBtn
  if toggleBtn and not toggleBtn.isnil then
    do
      local uiToggle = toggleBtn:GetComponent("UIToggle")
      local curValue = uiToggle.value
      if curValue then
        local needItemId = WingsDataMgr.WING_DYE_ITEM_ID
        local needItemNum = WingsDataMgr.WING_DYE_ITEM_NUM
        local ItemModule = require("Main.Item.ItemModule")
        local haveItemNum = ItemData.Instance():GetNumberByItemId(ItemModule.BAG, needItemId)
        if needItemNum <= haveItemNum then
          Toast(textRes.Wings[43])
          uiToggle.value = false
          self:UpdateRanseBtnState()
          return
        end
        local function callback(select, tag)
          if 1 == select then
            uiToggle.value = true
          else
            uiToggle.value = false
          end
          self:UpdateRanseBtnState()
        end
        local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
        CommonConfirmDlg.ShowConfirm("", textRes.Wings[44], callback, nil)
      else
        self:UpdateRanseBtnState()
      end
    end
  end
end
def.method().UpdateRanseBtnState = function(self)
  local toggleBtn = self.uiNodes.toggleBtn
  if toggleBtn and not toggleBtn.isnil then
    local needItemId = WingsDataMgr.WING_DYE_ITEM_ID
    local needItemNum = WingsDataMgr.WING_DYE_ITEM_NUM
    local ItemModule = require("Main.Item.ItemModule")
    local haveItemNum = ItemData.Instance():GetNumberByItemId(ItemModule.BAG, needItemId)
    local uiToggle = toggleBtn:GetComponent("UIToggle")
    local curValue = uiToggle.value
    if curValue then
      if needItemNum <= haveItemNum then
        uiToggle.value = false
        self.uiNodes.RanseBtnLabel:SetActive(true)
        self.uiNodes.yuanbaoGroup:SetActive(false)
        return
      end
      self.uiNodes.RanseBtnLabel:SetActive(false)
      self.uiNodes.yuanbaoGroup:SetActive(true)
      local needItemPrice = WingsUtility.GetRanseItemPrice(needItemId)
      local needYuanBao = (needItemNum - haveItemNum) * needItemPrice
      local uiLabel = self.uiNodes.yuanbaoGroup:FindDirect("Label_Money"):GetComponent("UILabel")
      uiLabel:set_text(tostring(needYuanBao))
    else
      self.uiNodes.RanseBtnLabel:SetActive(true)
      self.uiNodes.yuanbaoGroup:SetActive(false)
    end
  end
end
def.method("number").OnListItemClicked = function(self, idx)
  self:ShowViewTip(idx)
  if idx == self.curSelected then
    return
  end
  self:ToggleSelectedItem(idx)
  self:TryOnModelWings(idx)
  self.curSelected = idx
end
def.method("number").ShowViewTip = function(self, idx)
  local sourceObj = self.uiNodes.itemList:FindDirect("item_" .. idx)
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = sourceObj:GetComponent("UISprite")
  local wingsView = self.wingsViewList[idx]
  local cfg = WingsUtility.GetWingsViewCfg(wingsView.modelId)
  if not cfg then
    return
  end
  require("Main.Item.ItemTipsMgr").Instance():ShowBasicTips(cfg.fakeItemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
end
def.method("number").ToggleSelectedItem = function(self, idx)
  local items = self.uiNodes.itemList:GetComponent("UIList").children
  local curItem = items[self.curSelected]
  local newSelectItem = items[idx]
  curItem:FindDirect("Img_Select"):SetActive(false)
  newSelectItem:FindDirect("Img_Select"):SetActive(true)
end
def.method().OnConfirmClicked = function(self)
  local newShowState
  if self.isShowWings then
    newShowState = 1
  else
    newShowState = 0
  end
  local curShowState = WingsDataMgr.Instance():GetIsWingsShowing()
  if curShowState ~= newShowState or self.curSelected ~= WingsViewPanel.INITVIEWINDEX or self.isDyed then
    local curModelId = self.wingsViewList[self.curSelected].modelId
    local p = require("netio.protocol.mzm.gsp.wing.CChangeWingView").new(self.schemaIdx, curModelId, newShowState)
    gmodule.network.sendProtocol(p)
  else
    Toast(textRes.Wings[24])
    self:DestroyPanel()
  end
end
def.method().OnDyeWingsClicked = function(self)
  if not self.wingsViewList or #self.wingsViewList == 0 then
    Toast(textRes.Wings[25])
    return
  end
  local dyeItemId = WingsDataMgr.WING_DYE_ITEM_ID
  local dyeItemNeeded = WingsDataMgr.WING_DYE_ITEM_NUM
  local ItemModule = require("Main.Item.ItemModule")
  local dyeItemNumInBag = ItemData.Instance():GetNumberByItemId(ItemModule.BAG, dyeItemId)
  if self.curSelected == -1 then
    Toast(textRes.Wings[26])
  end
  local needYuanBaoReplace = false
  if dyeItemNeeded > dyeItemNumInBag then
    local toggleBtn = self.uiNodes.toggleBtn
    if toggleBtn and not toggleBtn.isnil then
      local uiToggle = toggleBtn:GetComponent("UIToggle")
      local curValue = uiToggle.value
      if not curValue then
        uiToggle.value = true
        self:OnClickNeedYuanbaoReplace()
        return
      else
        needYuanBaoReplace = true
      end
    else
      Toast(textRes.Wings[27])
      return
    end
  end
  local needYuanBao = 0
  local allYuanBao = ItemModule.Instance():GetAllYuanBao()
  if needYuanBaoReplace then
    needYuanBao = WingsUtility.GetRanseItemPrice(dyeItemId) * (dyeItemNeeded - dyeItemNumInBag)
    if allYuanBao:lt(needYuanBao) then
      Toast(textRes.Common[15])
      return
    end
  end
  local isUseYuanBao = 0
  if needYuanBaoReplace then
    isUseYuanBao = 1
  end
  warn("ran se params : ", isUseYuanBao, needYuanBao)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.Wings[28], textRes.Wings[29], function(id, tag)
    if id == 1 then
      self:SendDyeReq(dyeItemId, isUseYuanBao, allYuanBao, needYuanBao)
    end
  end, nil)
end
def.method("number", "number", "userdata", "number").SendDyeReq = function(self, dyeItemId, isUseYuanBao, allYuanBao, needYuanBao)
  warn("~~~SendDyeReq~~~~~~ ", isUseYuanBao)
  local wingView = self.wingsViewList[self.curSelected]
  local p = require("netio.protocol.mzm.gsp.wing.CWingModelDye").new(wingView.modelId, dyeItemId, isUseYuanBao, allYuanBao, needYuanBao)
  gmodule.network.sendProtocol(p)
end
def.method().OnToggleViewClicked = function(self)
  local value = self.uiNodes.groupRight:FindDirect("Img_Toggle"):GetComponent("UIToggle").isChecked
  self.isShowWings = not value
  self:TryOnModelWings(self.curSelected)
end
def.method().OnDyeItemClicked = function(self)
  local sourceObj = self.uiNodes.groupLeft:FindDirect("Img_Item")
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = sourceObj:GetComponent("UISprite")
  require("Main.Item.ItemTipsMgr").Instance():ShowBasicTips(WingsDataMgr.WING_DYE_ITEM_ID, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
end
def.method().OnBtnTipsClicked = function(self)
  local tmpPosition = {x = 0, y = 0}
  local CommonDescDlg = require("GUI.CommonUITipsDlg")
  local tipString = require("Main.Common.TipsHelper").GetHoverTip(WingsDataMgr.WING_DYE_TIP_ID)
  if tipString == "" then
    return
  end
  CommonDescDlg.ShowCommonTip(tipString, tmpPosition)
end
def.static("table", "table").OnViewDataChanged = function(params, context)
  instance:UpdateWingsList()
  instance:UpdateModel()
end
def.static("table", "table").OnBagInfoSyncronized = function(params, context)
  instance:UpdateDyeItemInfo()
  instance:UpdateRanseBtnState()
end
def.static("table", "table").OnWingsDyed = function(params, context)
  if instance.curSelected == params.index then
    instance:TryOnModelWings(params.index)
  end
  instance.wingsViewList = WingsDataMgr.Instance():GetWingsViewList()
  instance.isDyed = true
end
def.static("table", "table").OnCurrentViewChanged = function(params, context)
  Toast(textRes.Wings[30])
  instance:DestroyPanel()
end
return WingsViewPanel.Commit()
