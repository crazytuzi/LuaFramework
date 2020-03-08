local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChildrenFashionPanel = Lplus.Extend(ECPanelBase, "ChildrenFashionPanel")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local ChildPhase = require("consts.mzm.gsp.children.confbean.ChildPhase")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local ChildrenFashionMgr = require("Main.Children.mgr.ChildrenFashionMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local ItemModule = require("Main.Item.ItemModule")
local Child = require("Main.Children.Child")
local def = ChildrenFashionPanel.define
local instance
def.static("=>", ChildrenFashionPanel).Instance = function()
  if instance == nil then
    instance = ChildrenFashionPanel()
  end
  return instance
end
def.const("table").ToggleName = {
  [ChildPhase.INFANT] = "Toggle_YingEr",
  [ChildPhase.CHILD] = "Toggle_TongNian",
  [ChildPhase.YOUTH] = "Toggle_ShaoNian"
}
def.field("userdata").childId = nil
def.field("number").phase = 0
def.field("number").fashionId = 0
def.field("table").clothesList = nil
def.field(Child).childModel = nil
def.field("number").toggleGroupId = 0
def.field("boolean").isDrag = false
def.static("userdata", "number", "number").ShowChildrenFashionPanel = function(childId, phase, fashionId)
  if childId == nil then
    return
  end
  local dlg = ChildrenFashionPanel.Instance()
  dlg.childId = childId
  dlg.phase = phase
  dlg.fashionId = fashionId
  if not dlg:IsShow() then
    dlg:CreatePanel(RESPATH.PREFAB_CHILDREN_FASHION, 1)
    dlg:SetModal(true)
  else
    dlg:UpdateUI()
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Update, ChildrenFashionPanel.OnFashionUpdate, self)
  Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Change, ChildrenFashionPanel.OnChildrenFashionChange, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, ChildrenFashionPanel.OnItemChange, self)
  Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_TimeChg, ChildrenFashionPanel.OnFashionTimeChg, self)
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Update, ChildrenFashionPanel.OnFashionUpdate)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Change, ChildrenFashionPanel.OnChildrenFashionChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, ChildrenFashionPanel.OnItemChange)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_TimeChg, ChildrenFashionPanel.OnFashionTimeChg)
  self.childId = nil
  self.phase = 0
  self.fashionId = 0
  self.clothesList = nil
  if self.childModel ~= nil then
    self.childModel:DestroyModel()
    self.childModel = nil
  end
  self.isDrag = false
end
def.method("table").OnFashionUpdate = function(self, params)
  self:UpdateClothes()
  self:UpdateBtn()
end
def.method("table").OnChildrenFashionChange = function(self, params)
  local childId = params[1]
  local phase = params[2]
  if self.childId == childId and self.phase == phase then
    self:UpdateModel()
    self:UpdateBtn()
    self:UpdateClothes()
  end
end
def.method("table").OnItemChange = function(self, params)
  self:UpdateItem()
end
def.method("table").OnFashionTimeChg = function(self, p)
  self:UpdateClothes()
  self:UpdateBtn()
  self:UpdateItem()
  self:UpdateDesc()
end
def.method().InitUI = function(self)
  local list = self.m_panel:FindDirect("Img_Bg0/Group_Fashion/Group_Right/Group_Item/Scroll View_Item/List_Item")
  self.toggleGroupId = list:FindDirect("Template"):GetComponent("UIToggle"):get_group()
  local listCmp = list:GetComponent("UIScrollList")
  local GUIScrollList = list:GetComponent("GUIScrollList")
  if GUIScrollList == nil then
    list:AddComponent("GUIScrollList")
    ScrollList_setUpdateFunc(listCmp, ChildrenFashionPanel.FillItem)
  end
end
def.static("userdata", "number").FillItem = function(item, index)
  local self = ChildrenFashionPanel.Instance()
  local child = ChildrenDataMgr.Instance():GetChildById(self.childId)
  if not child then
    return
  end
  local fashionId = self.clothesList[index]
  if fashionId then
    item:SetActive(true)
    local fashionCfg = ChildrenUtils.GetChildrenFashionCfg(fashionId)
    local isUnlock = ChildrenFashionMgr.Instance():IsUnlock(fashionId)
    local isDressed = child:GetFashionByPhase(self.phase) and child:GetFashionByPhase(self.phase).fashionId == fashionId or false
    local itemBase = ItemUtils.GetItemBase(fashionCfg.itemId)
    local tex = item:FindDirect("Img_Icon"):GetComponent("UITexture")
    GUIUtils.FillIcon(tex, itemBase.icon)
    local lockSPr = item:FindDirect("Sprite")
    lockSPr:SetActive(not isUnlock)
    local dressSpr = item:FindDirect("Img_Fit")
    dressSpr:SetActive(isDressed)
    if fashionId == self.fashionId then
      item:GetComponent("UIToggle").value = true
    end
  else
    item:SetActive(false)
  end
end
def.method().UpdateUI = function(self)
  self:UpdateModel()
  self:UpdatePhase()
  self:UpdateClothes()
  self:UpdateItem()
  self:UpdateBtn()
  self:UpdateDesc()
end
def.method().UpdateModel = function(self)
  if self.childModel ~= nil then
    self.childModel:DestroyModel()
  end
  local child = ChildrenDataMgr.Instance():GetChildById(self.childId)
  local modelCfgId = child:GetModelIdByPhase(self.phase)
  warn("modelCfgId", modelCfgId)
  if modelCfgId <= 0 then
    return
  end
  if child:IsYouth() then
    self.childModel = Child.CreateWithFashionAndWeapon(modelCfgId, self.fashionId, child:GetWeaponId())
  else
    self.childModel = Child.CreateWithFashion(modelCfgId, self.fashionId)
  end
  local uiModel = self.m_panel:FindDirect("Img_Bg0/Group_Fashion/Group_Left/Model"):GetComponent("UIModel")
  self.childModel:LoadUIModel(nil, function()
    uiModel.modelGameObject = self.childModel.model.m_model
    if uiModel.mCanOverflow ~= nil then
      uiModel.mCanOverflow = true
      local camera = uiModel:get_modelCamera()
      camera:set_orthographic(true)
    end
  end)
end
def.method().UpdatePhase = function(self)
  if ChildrenFashionPanel.ToggleName[self.phase] == nil then
    self.phase = ChildPhase.INFANT
  end
  local toggleGroup = self.m_panel:FindDirect("Img_Bg0/Group_Fashion/Group_Right/Group_Toggle")
  local toggleName = ChildrenFashionPanel.ToggleName[self.phase]
  local toggle = toggleGroup:FindDirect(toggleName)
  toggle:GetComponent("UIToggle").value = true
end
def.method().UpdateClothes = function(self)
  local activeToggle = UIToggle.GetActiveToggle(self.toggleGroupId)
  if activeToggle then
    activeToggle.value = false
  end
  local child = ChildrenDataMgr.Instance():GetChildById(self.childId)
  if child then
    local phase = self.phase
    local gender = child:GetGender()
    self.clothesList = ChildrenFashionMgr.Instance():GetFashionsByPeriodAndGender(phase, gender)
    table.sort(self.clothesList, function(a, b)
      local bAunlock = ChildrenFashionMgr.Instance():IsUnlock(a)
      local bBunlock = ChildrenFashionMgr.Instance():IsUnlock(b)
      if bAunlock then
        if bBunlock then
          return a < b
        else
          return true
        end
      elseif bBunlock then
        return false
      else
        return a < b
      end
    end)
    local list = self.m_panel:FindDirect("Img_Bg0/Group_Fashion/Group_Right/Group_Item/Scroll View_Item/List_Item")
    local listCmp = list:GetComponent("UIScrollList")
    local count = #self.clothesList
    ScrollList_clear(listCmp)
    ScrollList_setCount(listCmp, count)
    self:ResetScroll()
  end
end
def.method().ResetScroll = function(self)
  local scroll = self.m_panel:FindDirect("Img_Bg0/Group_Fashion/Group_Right/Group_Item/Scroll View_Item")
  scroll:GetComponent("UIScrollView"):ResetPosition()
end
def.method().UpdateItem = function(self)
  local itemGroup = self.m_panel:FindDirect("Img_Bg0/Group_Fashion/Group_Right/Group_UnluckItem")
  local btnExtend = self.m_panel:FindDirect("Img_Bg0/Group_Fashion/Group_Right/Btn_Continue")
  if self.fashionId > 0 then
    itemGroup:SetActive(true)
    local fashionCfg = ChildrenUtils.GetChildrenFashionCfg(self.fashionId)
    local itemBase = ItemUtils.GetItemBase(fashionCfg.itemId)
    local tex = itemGroup:FindDirect("Bg_Item/Img_Icon"):GetComponent("UITexture")
    GUIUtils.FillIcon(tex, itemBase.icon)
    local nameLbl = itemGroup:FindDirect("Label_Name")
    nameLbl:GetComponent("UILabel"):set_text(itemBase.name)
    local isUnlock = ChildrenFashionMgr.Instance():IsUnlock(self.fashionId)
    local numLbl = itemGroup:FindDirect("Label_Num")
    if ChildrenFashionMgr.IsExtendTimeOpen() then
      btnExtend:SetActive(isUnlock and fashionCfg.duration ~= 0)
    end
    if isUnlock then
      numLbl:GetComponent("UILabel"):set_text(textRes.Children[5009])
      itemGroup:SetActive(false)
    else
      local num = ItemModule.Instance():GetItemCountById(fashionCfg.itemId)
      numLbl:GetComponent("UILabel"):set_text(string.format("%d/%d", num, 1))
    end
  else
    itemGroup:SetActive(false)
    btnExtend:SetActive(false)
  end
end
local Hour2Text = function(hour)
  if not (hour >= 0) or not hour then
    hour = 0
  end
  local day = math.floor(hour / 24)
  hour = hour % 24
  local text = ""
  if day > 0 then
    text = string.format("%2d%s%2d%s", day, textRes.Common.Day, hour, textRes.Common.Hour)
  else
    text = string.format("%2d%s", hour, textRes.Common.Hour)
  end
  return text
end
def.method().UpdateDesc = function(self)
  local descGroup = self.m_panel:FindDirect("Img_Bg0/Group_Fashion/Group_Left/Container")
  if self.fashionId > 0 then
    descGroup:SetActive(true)
    local name = descGroup:FindDirect("Label_Name")
    local time = descGroup:FindDirect("Label_Time")
    local info = descGroup:FindDirect("Label_Info")
    local fashionCfg = ChildrenUtils.GetChildrenFashionCfg(self.fashionId)
    name:GetComponent("UILabel"):set_text(fashionCfg.name)
    info:GetComponent("UILabel"):set_text(fashionCfg.desc)
    if 0 < fashionCfg.duration then
      local fashionInfo = ChildrenFashionMgr.Instance():GetFashionInfo(self.fashionId)
      if fashionInfo then
        local leftHour = math.ceil((fashionInfo.startTime + fashionCfg.duration * 3600 - GetServerTime()) / 3600)
        local text = ""
        if fashionInfo.startTime == 0 then
          text = textRes.Children[5013]
          time:GetComponent("UILabel"):set_text(text)
        else
          text = Hour2Text(leftHour)
          time:GetComponent("UILabel"):set_text(string.format(textRes.Children[2030], text))
        end
      else
        local text = Hour2Text(fashionCfg.duration)
        time:GetComponent("UILabel"):set_text(string.format(textRes.Children[2029], text))
      end
    else
      time:GetComponent("UILabel"):set_text(textRes.Children[2028])
    end
  else
    descGroup:SetActive(false)
  end
end
def.method().UpdateBtn = function(self)
  local btn = self.m_panel:FindDirect("Img_Bg0/Group_Fashion/Group_Right/Btn_UnLock")
  if self.fashionId > 0 then
    btn:SetActive(true)
    local btnNameLbl = btn:FindDirect("Label_Settle")
    local isUnlock = ChildrenFashionMgr.Instance():IsUnlock(self.fashionId)
    if not isUnlock then
      btnNameLbl:GetComponent("UILabel"):set_text(textRes.Children[5000])
    else
      local child = ChildrenDataMgr.Instance():GetChildById(self.childId)
      local isDressed = child:GetFashionByPhase(self.phase) and child:GetFashionByPhase(self.phase).fashionId == self.fashionId or false
      if isDressed then
        btnNameLbl:GetComponent("UILabel"):set_text(textRes.Children[5002])
      else
        btnNameLbl:GetComponent("UILabel"):set_text(textRes.Children[5001])
      end
    end
  else
    btn:SetActive(false)
  end
end
def.method("number", "=>", "boolean").CanExplore = function(self, phase)
  local child = ChildrenDataMgr.Instance():GetChildById(self.childId)
  if phase > child:GetStatus() then
    return false
  else
    return true
  end
end
def.method("number", "=>", "number").AutoSelecetFashion = function(self, pahse)
  local child = ChildrenDataMgr.Instance():GetChildById(self.childId)
  if child then
    local fashion = child:GetFashionByPhase(pahse)
    if fashion then
      return fashion.fashionId
    else
      return 0
    end
  else
    return 0
  end
end
def.method("number").TogglePhase = function(self, phase)
  if not self:CanExplore(phase) then
    self:UpdatePhase()
    Toast(textRes.Children[5003])
    return
  end
  self.phase = phase
  self.fashionId = self:AutoSelecetFashion(phase)
  self:UpdatePhase()
  self:UpdateClothes()
  self:UpdateItem()
  self:UpdateDesc()
  self:UpdateBtn()
  self:UpdateModel()
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Help" then
    local tipsId = constant.CChildFashionConst.UI_TIPS
    require("GUI.GUIUtils").ShowHoverTip(tipsId, 0, 0)
  elseif id == "Template" then
    warn("onClickObj", id)
    local item, idx = ScrollList_getItem(obj)
    item:GetComponent("UIToggle").value = true
    if self.clothesList then
      local fashionId = self.clothesList[idx]
      if fashionId then
        self.fashionId = fashionId
        self:UpdateModel()
        self:UpdateBtn()
        self:UpdateItem()
        self:UpdateDesc()
      end
    end
  elseif id == "Bg_Item" then
    local fashionCfg = ChildrenUtils.GetChildrenFashionCfg(self.fashionId)
    if fashionCfg then
      require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(fashionCfg.itemId, obj, 0, true)
    end
  elseif id == "Toggle_YingEr" then
    if self.phase ~= ChildPhase.INFANT then
      self:TogglePhase(ChildPhase.INFANT)
    end
  elseif id == "Toggle_TongNian" then
    if self.phase ~= ChildPhase.CHILD then
      self:TogglePhase(ChildPhase.CHILD)
    end
  elseif id == "Toggle_ShaoNian" then
    if self.phase ~= ChildPhase.YOUTH then
      self:TogglePhase(ChildPhase.YOUTH)
    end
  elseif id == "Btn_UnLock" then
    if 0 < self.fashionId then
      local isUnlock = ChildrenFashionMgr.Instance():IsUnlock(self.fashionId)
      if not isUnlock then
        ChildrenFashionMgr.Instance():UnlockFashion(self.fashionId)
      else
        local child = ChildrenDataMgr.Instance():GetChildById(self.childId)
        local isDressed = child:GetFashionByPhase(self.phase) and child:GetFashionByPhase(self.phase).fashionId == self.fashionId or false
        if isDressed then
          ChildrenFashionMgr.Instance():UndressFashion(self.childId, self.fashionId)
        else
          ChildrenFashionMgr.Instance():DressFashion(self.childId, self.fashionId)
        end
      end
    end
  elseif id == "Btn_Continue" then
    self:OnClickBtnExtendTime()
  end
end
def.method("string").onDragStart = function(self, id)
  if id == "Model" then
    self.isDrag = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self.isDrag = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDrag == true and self.childModel then
    self.childModel:SetDir(self.childModel:GetDir() - dx / 2)
  end
end
def.method().OnClickBtnExtendTime = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local CommonItemUse = require("Main.Wing.ui.CommonItemUse")
  local itemIdList = self:_getItemIdList(self.fashionId) or {}
  CommonItemUse.ShowCommonUseByItemId(textRes.Children[5012], itemIdList, function(itemId, bUseAll)
    local itemBase = ItemUtils.GetItemBase(itemId)
    local bagId = ItemUtils.GetBagIdByItemType(itemBase.itemType)
    if bagId == 0 then
      bagId = ItemModule.BAG
    end
    local items = ItemModule.Instance():GetItemsByItemID(bagId, itemId)
    for itemKey, item in pairs(items) do
      ChildrenFashionMgr.CSendExtendFashionReq(bagId, itemKey, self.fashionId)
      return
    end
    Toast(textRes.Children[5010])
  end)
end
def.method("number", "=>", "table")._getItemIdList = function(self, fashionCfgId)
  local fashionCfg = ChildrenUtils.GetChildrenFashionCfg(fashionCfgId)
  if fashionCfg == nil then
    return nil
  end
  local cfgIds = ChildrenUtils.GetChildrenFashionCfgIdsByTypeId(fashionCfg.typeId)
  local retData = {}
  local tblCfgIds = {}
  for i = 1, #cfgIds do
    fashionCfg = ChildrenUtils.GetChildrenFashionCfg(cfgIds[i])
    if fashionCfg and tblCfgIds[fashionCfg.itemId] == nil then
      table.insert(retData, fashionCfg.itemId)
      tblCfgIds[fashionCfg.itemId] = 1
    end
  end
  return retData
end
return ChildrenFashionPanel.Commit()
