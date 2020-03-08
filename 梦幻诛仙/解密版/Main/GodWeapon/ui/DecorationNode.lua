local Lplus = require("Lplus")
local GodWeaponTabNode = require("Main.GodWeapon.ui.GodWeaponTabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local DecorationNode = Lplus.Extend(GodWeaponTabNode, "DecorationNode")
local def = DecorationNode.define
local instance
local DecorationMgr = require("Main.GodWeapon.DecorationMgr")
local GUIUtils = require("GUI.GUIUtils")
local DecorationUtils = require("Main.GodWeapon.Decoration.DecorationUtils")
local DecorationProtocols = require("Main.GodWeapon.Decoration.DecorationProtocols")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local txtConst = textRes.GodWeapon.Decoration
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.field("table")._uiModel = nil
def.field("table")._modelInfo = nil
def.field("table")._WSList = nil
def.field("table")._allLvsWSInfo = nil
def.static("=>", DecorationNode).Instance = function()
  if instance == nil then
    instance = DecorationNode()
  end
  return instance
end
def.override().OnShow = function(self)
  Event.RegisterEventWithContext(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.WUSHI_USE_FRAGMENTS_SUCCESS, DecorationNode.OnUseFragsSuccess, self)
  Event.RegisterEventWithContext(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.WUSHI_LEVEL_UP_SUCCESS, DecorationNode.OnLevelUpSuccess, self)
  Event.RegisterEventWithContext(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.WS_PUTON_CHANGE, DecorationNode.OnWSPutOnChg, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, DecorationNode.OnBagChange, self)
  self._uiStatus = {}
  self._WSList = {}
  self._uiStatus.selWSIdx = self._uiStatus.selWSIdx or 1
  if self._params ~= nil then
    self._uiStatus.selWSCfgId = self._params.cfgId
    self._params = nil
  end
  self._uiStatus.selLv = 1
  self:InitUI()
end
def.override().OnHide = function(self)
  if self._uiModel ~= nil then
    self._uiModel:Destroy()
  end
  if self._uiGOs ~= nil and not self._uiGOs.WSList.isnil then
    self._uiGOs.WSList:SetActive(false)
    GUIUtils.SetText(self._uiGOs.lblTitle, txtConst[7])
  end
  self._uiModel = nil
  self._uiStatus = nil
  self._uiGOs = nil
  self._WSList = nil
  self._allLvsWSInfo = nil
  self._modelInfo = nil
  Event.UnregisterEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.WUSHI_USE_FRAGMENTS_SUCCESS, DecorationNode.OnUseFragsSuccess)
  Event.UnregisterEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.WUSHI_LEVEL_UP_SUCCESS, DecorationNode.OnLevelUpSuccess)
  Event.UnregisterEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.WS_PUTON_CHANGE, DecorationNode.OnWSPutOnChg)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, DecorationNode.OnBagChange)
end
def.method().InitUI = function(self)
  self._uiGOs = {}
  self._uiGOs.groupEquipments = self.m_panel:FindDirect("Img_Bg/Group_EquipList")
  self._uiGOs.WSList = self._uiGOs.groupEquipments:FindDirect("Group_WSList")
  self._uiGOs.lblTitle = self._uiGOs.groupEquipments:FindDirect("Img_TBg/Label")
  self._uiGOs.groupModel = self.m_panel:FindDirect("Img_Bg/Group_WS/Group_Model")
  self._uiGOs.groupProp = self.m_panel:FindDirect("Img_Bg/Group_WS/Group_Att")
  self._uiGOs.lblTipsLimit = self._uiGOs.groupProp:FindDirect("Group_Slider/Label_TipsLimit")
  self._uiGOs.lblTipsLimit:SetActive(false)
  local groupWS = self.m_panel:FindDirect("Img_Bg/Group_WS")
  self._WSList = DecorationMgr.GetData():GetWSInfoList()
  local groupNoData = self.m_panel:FindDirect("Img_Bg/Group_NoData")
  groupNoData:SetActive(false)
  local myEquipList = require("Main.GodWeapon.JewelMgr").GetData():GetHeroGodWeapons() or {}
  local numEquips = #myEquipList
  self._uiGOs.WSList:SetActive(numEquips > 0)
  groupNoData:SetActive(numEquips < 1)
  groupWS:SetActive(numEquips > 0)
  if numEquips < 1 then
    return
  end
  local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
  local bEquipWeapon = false
  for i = 1, numEquips do
    local equipInfo = myEquipList[i]
    if equipInfo.wearPos == 0 and equipInfo.bEquiped then
      bEquipWeapon = true
    end
  end
  if not bEquipWeapon then
    Toast(txtConst[19])
    self.m_base:SwitchTo(1)
    return
  end
  if numEquips > 0 then
    GUIUtils.SetText(self._uiGOs.lblTitle, txtConst[6])
    self.m_base:ShowEquipList(nil)
    self._allLvsWSInfo = {}
    self:UpdateUI()
  end
end
def.method().UpdateUI = function(self)
  self:UpdateUILeft()
  self:UpdateUIRight()
  self:UpdateUIBottom()
end
def.method().UpdateUILeft = function(self)
  self._WSList = DecorationMgr.GetData():GetWSInfoList()
  local WSList = self._WSList
  local ctrlScrollView = self._uiGOs.groupEquipments:FindDirect("Group_WSList/Group_List/Scroll View_WSList")
  local ctrlUIList = ctrlScrollView:FindDirect("List_EquipList")
  local ctrlGWList = GUIUtils.InitUIList(ctrlUIList, #(WSList or {}))
  for i = 1, #ctrlGWList do
    local WSInfo = WSList[i]
    self:FillWSInfo(ctrlGWList[i], WSInfo, i)
  end
  local comScrollView = ctrlScrollView:GetComponent("UIScrollView")
  if #ctrlGWList > 0 then
    do
      local selIdx = self._uiStatus.selWSIdx
      local ctrl = ctrlGWList[selIdx]
      _G.GameUtil.AddGlobalTimer(0.1, true, function()
        if comScrollView == nil or comScrollView.isnil then
          return
        end
        comScrollView:DragToMakeVisible(ctrl.transform, 1280)
      end)
    end
  end
end
local WuShiInfo = require("netio.protocol.mzm.gsp.superequipment.WuShiInfo")
def.method("userdata", "table", "number").FillWSInfo = function(self, ctrl, WSInfo, idx)
  if ctrl == nil or WSInfo == nil then
    return
  end
  local iconEquip = ctrl:FindDirect("Icon_Equip_" .. idx)
  local lblName = ctrl:FindDirect("Label_EquipName_" .. idx)
  local lblLv = ctrl:FindDirect("Label_EquipLv_" .. idx)
  local imgIsEquip = ctrl:FindDirect("Img_EquipMark_" .. idx)
  local ctrlSlider = ctrl:FindDirect("Slider_Pro_" .. idx)
  local lblProgress = ctrlSlider:FindDirect("Label_Slider_" .. idx)
  local imgRed = ctrl:FindDirect("Img_Red_" .. idx)
  local imgLock = ctrl:FindDirect("Sprite_" .. idx)
  GUIUtils.SetTexture(iconEquip, WSInfo.icon or 0)
  GUIUtils.SetText(lblName, WSInfo.name)
  GUIUtils.SetText(lblLv, txtConst[5]:format(WSInfo.level or ""))
  imgIsEquip:SetActive(WSInfo.isOn == WuShiInfo.ON)
  local bIsUnlock = WSInfo.isActivate and WSInfo.isActivate == WuShiInfo.ACTIVATE or false
  local haveFragsNum = WSInfo.fragmentCount or 0
  ctrlSlider:SetActive(not bIsUnlock)
  if not bIsUnlock then
    if WSInfo.nxtLvId < 1 then
      ctrlSlider:SetActive(false)
    else
      ctrlSlider:GetComponent("UISlider").value = haveFragsNum / WSInfo.fragsCount
      GUIUtils.SetText(lblProgress, txtConst[4]:format(haveFragsNum, WSInfo.fragsCount))
    end
    GUIUtils.SetTextureEffect(iconEquip:GetComponent("UITexture"), GUIUtils.Effect.Gray)
  else
    GUIUtils.SetTextureEffect(iconEquip:GetComponent("UITexture"), GUIUtils.Effect.Normal)
    ctrlSlider:GetComponent("UISlider").value = haveFragsNum / WSInfo.fragsCount
    if 0 < WSInfo.nxtLvId then
      local nxtLvWSBasicCfg = DecorationUtils.GetWSBasicCfgById(WSInfo.nxtLvId)
      local needFragsCount = 0
      if nxtLvWSBasicCfg ~= nil then
        needFragsCount = nxtLvWSBasicCfg.fragsCount
      end
      GUIUtils.SetText(lblProgress, txtConst[4]:format(haveFragsNum, nxtLvWSBasicCfg.fragsCount))
    end
  end
  imgLock:SetActive(not bIsUnlock)
  if 0 < WSInfo.nxtLvId then
    imgRed:SetActive(DecorationMgr.CanWSImprove(WSInfo.id))
  else
    imgRed:SetActive(false)
  end
  if self._uiStatus.selWSCfgId == nil and self._uiStatus.selWSType == nil then
    if idx == self._uiStatus.selWSIdx then
      ctrl:GetComponent("UIToggle").value = true
    end
  elseif self._uiStatus.selWSCfgId ~= nil then
    if self._uiStatus.selWSCfgId == WSInfo.id then
      self._uiStatus.selWSIdx = idx
      self._uiStatus.selWSCfgId = nil
      ctrl:GetComponent("UIToggle").value = true
    end
  elseif self._uiStatus.selWSType ~= nil and self._uiStatus.selWSType == WSInfo.type then
    self._uiStatus.selWSType = nil
    self._uiStatus.selWSIdx = idx
    ctrl:GetComponent("UIToggle").value = true
  end
end
def.method().UpdateUIRight = function(self)
  local ctrlRoot = self._uiGOs.groupProp
  local ctrlSelPropRoot = ctrlRoot:FindDirect("Group_Title/Group_Act")
  local lblPreview = ctrlRoot:FindDirect("Group_Title/Label_Preview")
  local selWSInfo = self._WSList[self._uiStatus.selWSIdx] or {}
  local bOwnedWS = selWSInfo.isActivate and selWSInfo.isActivate == WuShiInfo.ACTIVATE or false
  ctrlSelPropRoot:SetActive(true)
  lblPreview:SetActive(false)
  local heroProp = _G.GetHeroProp()
  self:UpdateModelWeapon(selWSInfo.displayTypeId)
  self:UpdateUIRightTop(selWSInfo)
  self:_fillPropList(selWSInfo.arrProps)
  if self._uiModel == nil then
    self:UpdateUIModel(selWSInfo.displayTypeId)
  end
end
def.method("table")._fillPropList = function(self, props)
  local ctrlRoot = self._uiGOs.groupProp
  local groupProp = ctrlRoot:FindDirect("Group_Info")
  local ctrlPropScrollView = groupProp:FindDirect("Group_List/ScrollView_Att")
  local ctrlUIList = ctrlPropScrollView:FindDirect("List_Att")
  local propList = props or {}
  local propNum = #propList
  local ctrlPropList = GUIUtils.InitUIList(ctrlUIList, propNum)
  for i = 1, propNum do
    local ctrlProp = ctrlPropList[i]
    local prop = propList[i]
    local lblName = ctrlProp:FindDirect("Label_AttName_" .. i)
    local lblVal = ctrlProp:FindDirect("Label_AttNum_" .. i)
    GUIUtils.SetText(lblName, DecorationUtils.GetProName(prop.propType))
    GUIUtils.SetText(lblVal, prop.propVal)
  end
end
def.method("table").UpdateUIRightTop = function(self, WSInfo)
  if WSInfo == nil then
    return
  end
  local ctrlRoot = self._uiGOs.groupProp:FindDirect("Group_Title/Group_Act")
  local lblName = ctrlRoot:FindDirect("Label_Name")
  local lblLv = ctrlRoot:FindDirect("Label_Lv")
  local btnPre = ctrlRoot:FindDirect("Btn_Left")
  local btnNxt = ctrlRoot:FindDirect("Btn_Right")
  local imgDark = self._uiGOs.groupProp:FindDirect("Group_Title/Img_Dark")
  if self._allLvsWSInfo[WSInfo.level] == nil then
    self._allLvsWSInfo[WSInfo.level] = WSInfo
  end
  local selWSInfo = self._WSList[self._uiStatus.selWSIdx]
  if selWSInfo and selWSInfo.level == WSInfo.level then
    imgDark:SetActive(false)
  else
    imgDark:SetActive(true)
  end
  self._uiStatus.selLv = WSInfo.level or 1
  btnPre:SetActive(WSInfo.level > 1)
  btnNxt:SetActive(WSInfo.nxtLvId > 0)
  GUIUtils.SetText(lblName, WSInfo.name or "")
  GUIUtils.SetText(lblLv, txtConst[16]:format(WSInfo.level or 1))
  self:_fillPropList(WSInfo.arrProps)
end
def.method().UpdateUIBottom = function(self)
  local ctrlRoot = self._uiGOs.groupProp
  local lblTips = ctrlRoot:FindDirect("Label_Tips")
  local selWSInfo = self._WSList[self._uiStatus.selWSIdx] or {}
  local haveFragsNum = ItemModule.Instance():GetItemCountById(selWSInfo.fragsItemId) or 0
  local eatFragsNum = selWSInfo.fragmentCount and selWSInfo.fragmentCount or 0
  GUIUtils.SetText(lblTips, txtConst[2]:format(selWSInfo.source or ""))
  local ctrlSliderRoot = ctrlRoot:FindDirect("Group_Slider")
  local ctrlSlider = ctrlSliderRoot:FindDirect("Slider_Pro")
  local lblSlider = ctrlSlider:FindDirect("Label_Slider")
  local lblHint = ctrlSliderRoot:FindDirect("Label_Tips")
  local btnImprove = ctrlSliderRoot:FindDirect("Btn_LvUp")
  local btnLbl = btnImprove:GetChild(0)
  local btnImgRed = btnImprove:GetChild(1)
  local btnDress = self._uiGOs.groupProp:FindDirect("Group_Info/Btn_Dress")
  local bNeedShow = 0 < selWSInfo.nxtLvId
  ctrlSlider:SetActive(bNeedShow)
  lblHint:SetActive(bNeedShow)
  GUIUtils.EnableButton(btnImprove, bNeedShow)
  local bIsUnlock = selWSInfo.isActivate and selWSInfo.isActivate == WuShiInfo.ACTIVATE or false
  btnDress:SetActive(bIsUnlock)
  if bIsUnlock then
    local comDressLbl = btnDress:FindDirect("Label"):GetComponent("UILabel")
    if selWSInfo.isOn == WuShiInfo.ON then
      comDressLbl.text = txtConst[14]
    else
      comDressLbl.text = txtConst[13]
    end
  end
  if 0 < selWSInfo.nxtLvId then
    if not bIsUnlock then
      ctrlSlider:GetComponent("UISlider").value = eatFragsNum / selWSInfo.fragsCount
      GUIUtils.SetText(lblSlider, txtConst[4]:format(eatFragsNum, selWSInfo.fragsCount))
      GUIUtils.SetText(lblHint, txtConst[3])
      GUIUtils.SetText(btnLbl, txtConst[9])
      btnLbl.name = "Label_" .. haveFragsNum .. "_" .. selWSInfo.fragsCount
    else
      local nxtLvWSBasicCfg = DecorationUtils.GetWSBasicCfgById(selWSInfo.nxtLvId)
      local needFragsCount = 1
      if nxtLvWSBasicCfg ~= nil then
        needFragsCount = nxtLvWSBasicCfg.fragsCount
      end
      ctrlSlider:GetComponent("UISlider").value = eatFragsNum / needFragsCount
      GUIUtils.SetText(lblSlider, txtConst[4]:format(eatFragsNum, needFragsCount))
      GUIUtils.SetText(lblHint, txtConst[3])
      GUIUtils.SetText(btnLbl, txtConst[10])
      btnLbl.name = "Label"
    end
    if 0 < selWSInfo.nxtLvId then
      btnImgRed:SetActive(DecorationMgr.CanWSImprove(selWSInfo.id))
      self._uiGOs.lblTipsLimit:SetActive(false)
    end
  else
    btnImgRed:SetActive(false)
    self._uiGOs.lblTipsLimit:SetActive(true)
    GUIUtils.SetText(self._uiGOs.lblTipsLimit, txtConst[23])
    GUIUtils.SetText(btnLbl, txtConst[22])
  end
end
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local ECUIModel = require("Model.ECUIModel")
def.method("number").UpdateUIModel = function(self, displayTypeId)
  local comUIModel = self._uiGOs.groupModel:FindDirect("Model"):GetComponent("UIModel")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local ocp = _G.GetHeroProp().occupation
  local modelId = DecorationMgr.GetData():GetHeroModelId()
  if self._uiModel ~= nil then
    self._uiModel:Destroy()
  end
  self._uiModel = ECUIModel.new(modelId)
  if self._modelInfo ~= nil then
    self._modelInfo = DecorationMgr.GetData():GetOccupationModelInfo(ocp)
  end
  local modelInfo = self._modelInfo
  modelInfo.modelid = modelId
  _G.LoadModelWithCallBack(self._uiModel, modelInfo, false, false, function()
    if self.m_panel == nil or self.m_panel.isnil then
      if self._uiModel then
        self._uiModel:Destroy()
        self._uiModel = nil
      end
      return
    end
    if self._uiModel == nil or self._uiModel.m_model == nil or self._uiModel.m_model.isnil or comUIModel == nil or comUIModel.isnil then
      return
    end
    self._uiModel:SetDir(180)
    self._uiModel:Play(ActionName.Stand)
    comUIModel.modelGameObject = self._uiModel:GetMainModel()
    if comUIModel.mCanOverflow ~= nil then
      comUIModel.mCanOverflow = true
      local camera = comUIModel:get_modelCamera()
      if camera then
        camera:set_orthographic(true)
      end
    end
    local wsModelInfo = DecorationMgr.GetData():GetDisplayCfgByModelId(displayTypeId, modelId)
    self._uiModel:SetWeaponModel(wsModelInfo)
    self:PlayAttackThenStand()
  end)
end
def.method("number").UpdateModelWeapon = function(self, displayTypeId)
  if self._modelInfo == nil then
    local ocp = _G.GetHeroProp().occupation
    self._modelInfo = DecorationMgr.GetData():GetOccupationModelInfo(ocp)
  end
  local modelId = DecorationMgr.GetData():GetHeroModelId()
  local wsModelInfo = DecorationMgr.GetData():GetDisplayCfgByModelId(displayTypeId, modelId)
  self._uiStatus.weaponInfo = wsModelInfo
  if self._uiModel ~= nil and self._uiModel:IsLoaded() then
    self._uiModel:SetWeaponModel(wsModelInfo)
    self:PlayAttackThenStand()
  end
end
def.method().PlayAttackThenStand = function(self)
  if self._uiModel == nil then
    return
  end
  self._uiModel:CrossFade(ActionName.Idle1, 0.2)
  self._uiModel:CrossFadeQueued(ActionName.Stand, 0.2)
end
def.method("=>", "number").GetSelectedOccupation = function(self)
  if self.selOcp == 0 then
    self.selOcp = _G.GetHeroProp().occupation
  end
  return self.selOcp
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_LvUp" then
    local lblName = clickObj:GetChild(0).name
    local strs = string.split(lblName, "_")
    if strs[2] == nil then
      self:OnClickBtnLvUp()
    else
      self:OnClickBtnLvUp()
    end
  elseif id == "Btn_Dress" then
    local selWSInfo = self._WSList[self._uiStatus.selWSIdx] or {}
    if selWSInfo.isOn ~= nil then
      if WuShiInfo.ON == selWSInfo.isOn then
        self:OnClickBtnDress(false)
      else
        self:OnClickBtnDress(true)
      end
    end
  elseif id == "Btn_Left" then
    self:OnClickBtnPreProp()
  elseif id == "Btn_Right" then
    self:OnClickBtnNxtProp()
  elseif id == "Btn_HelpInfor" then
    GUIUtils.ShowHoverTip(constant.CSuperEquipmentConsts.WEAPON_DECORATION_HOVER_TIP_ID, 0, 0)
  elseif string.find(id, "Img_BgWuShi_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[3])
    self._uiStatus.selWSIdx = idx
    self._allLvsWSInfo = {}
    self:UpdateUIRight()
    self:UpdateUIBottom()
  elseif id == "Btn_MakeOrg" then
    self:OnBtn_MakeOrgClick(clickObj)
  elseif id == "Btn_MakeHigher" then
    self:OnBtn_MakeHigherClick(clickObj)
  elseif id == "Model" then
    self:PlayAttackThenStand()
  end
end
def.method("table", "=>", "table")._getItemIdList = function(self, selWSInfo)
  if selWSInfo == nil then
    return nil
  end
  local itemIdList = {}
  local WSItemIds = DecorationUtils.GetItemIdsByWuShiType(selWSInfo.type)
  if WSItemIds ~= nil then
    for i = 1, #WSItemIds.itemIds do
      local itemId = WSItemIds.itemIds[i]
      table.insert(itemIdList, itemId)
    end
  end
  table.insert(itemIdList, selWSInfo.fragsItemId)
  return itemIdList
end
def.method().OnClickBtnLvUp = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local selWSInfo = self._WSList[self._uiStatus.selWSIdx]
  local CommonItemUse = require("Main.Wing.ui.CommonItemUse")
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  if selWSInfo ~= nil then
    local itemIdList = self:_getItemIdList(selWSInfo)
    CommonItemUse.ShowCommonUseByItemId(txtConst[12], itemIdList, function(itemId, bUseAll)
      local selWSInfo = self._WSList[self._uiStatus.selWSIdx]
      if selWSInfo == nil then
        return
      end
      self._uiStatus.selWSType = selWSInfo.type
      DecorationProtocols.CSendUpgradeWSReq(selWSInfo.id, itemId, bUseAll)
    end)
  end
end
def.method().OnClickUnlock = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local selWSInfo = self._WSList[self._uiStatus.selWSIdx]
  if selWSInfo ~= nil then
    self._uiStatus.selWSType = selWSInfo.type
    local itemBase = ItemUtils.GetItemBase(selWSInfo.fragsItemId)
    local bagId = ItemModule.Instance():GetBagIdByItemType(itemBase.itemType)
    local itemKey = ItemModule.Instance():SearchOneItemByItemId(selWSInfo.fragsItemId)
    DecorationProtocols.CSendUseWSItemReq(bagId, itemKey)
  end
end
def.method("boolean").OnClickBtnDress = function(self, bToDress)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if bToDress then
    local selWSInfo = self._WSList[self._uiStatus.selWSIdx]
    if selWSInfo ~= nil then
      self._uiStatus.selWSType = selWSInfo.type
      DecorationProtocols.CPutOnWSReq(selWSInfo.id)
    end
  else
    DecorationProtocols.CPutOffWSReq()
  end
end
def.method().OnClickBtnNxtProp = function(self)
  local nxtLv = self._uiStatus.selLv + 1
  local selWSInfo = self._WSList[self._uiStatus.selWSIdx]
  local nxtWSBasicCfg = self._allLvsWSInfo[nxtLv]
  local curWSBasicCfg = self._allLvsWSInfo[self._uiStatus.selLv]
  if nxtWSBasicCfg ~= nil then
    self:UpdateUIRightTop(nxtWSBasicCfg)
  elseif curWSBasicCfg == nil then
    self:UpdateUIRightTop(selWSInfo)
  elseif 1 > curWSBasicCfg.nxtLvId then
    self:UpdateUIRightTop(curWSBasicCfg)
  else
    nxtWSBasicCfg = DecorationUtils.GetWSBasicCfgById(curWSBasicCfg.nxtLvId)
    if nxtWSBasicCfg ~= nil then
      self:UpdateUIRightTop(nxtWSBasicCfg)
    end
  end
end
def.method().OnClickBtnPreProp = function(self)
  local preLv = self._uiStatus.selLv - 1
  if preLv < 1 then
    preLv = 1
  end
  local selWSInfo = self._WSList[self._uiStatus.selWSIdx]
  if selWSInfo ~= nil then
    local curlvWSInfo = self._allLvsWSInfo[preLv]
    if curlvWSInfo ~= nil then
      self:UpdateUIRightTop(curlvWSInfo)
      return
    end
    local oneLvWSCfgId = DecorationUtils.GetOneLvCfgIdByType(selWSInfo.type)
    local curWSBasicCfg = DecorationUtils.GetWSBasicCfgById(oneLvWSCfgId)
    if curWSBasicCfg ~= nil then
      for i = curWSBasicCfg.level, preLv do
        self._allLvsWSInfo[curWSBasicCfg.level] = curWSBasicCfg
        curWSBasicCfg = DecorationUtils.GetWSBasicCfgById(curWSBasicCfg.nxtLvId)
        if curWSBasicCfg == nil then
          self:UpdateUIRightTop(selWSInfo)
          return
        end
        i = curWSBasicCfg.level
      end
    end
    curlvWSInfo = self._allLvsWSInfo[preLv]
    if curlvWSInfo ~= nil then
      self:UpdateUIRightTop(curlvWSInfo)
    end
  else
    warn("selected WuShi info isnil")
  end
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
  self._uiModel:SetDir(self._uiModel.m_ang - dx / 2)
end
def.method("userdata").OnBtn_MakeOrgClick = function(self, clickObj)
  local EquipMainPanel = require("Main.Equip.ui.EquipSocialPanel")
  EquipMainPanel.ShowSocialPanel(EquipMainPanel.StateConst.EquipMake)
end
def.method("userdata").OnBtn_MakeHigherClick = function(self, clickObj)
  local EquipMainPanel = require("Main.Equip.ui.EquipSocialPanel")
  EquipMainPanel.ShowSocialPanel(EquipMainPanel.StateConst.EquipStren)
end
def.method("table").OnUseFragsSuccess = function(self, p)
  self:UpdateUI()
end
def.method("table").OnLevelUpSuccess = function(self, p)
  self:UpdateUI()
end
def.method("table").OnWSPutOnChg = function(self, p)
  self:UpdateUI()
end
def.method("table").OnBagChange = function(self, p)
  self:UpdateUILeft()
  self:UpdateUIBottom()
end
return DecorationNode.Commit()
