local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local MagicMarkNode = Lplus.Extend(TabNode, "MagicMarkNode")
local GUIUtils = require("GUI.GUIUtils")
local ECUIModel = require("Model.ECUIModel")
local Vector3 = require("Types.Vector3").Vector3
local FashionUtils = require("Main.Fashion.FashionUtils")
local def = MagicMarkNode.define
def.field("table")._uiObjs = nil
def.field("userdata")._magicmaskItemTemplate = nil
def.field("table")._showMagicMarkItemData = nil
def.field("table").magicmark_model = nil
def.field("number").selectedMarkIdx = 0
def.field("boolean")._isDrag = false
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.method("=>", "boolean").IsShow = function(self)
  return self.isShow
end
def.override().OnShow = function(self)
  if self._uiObjs == nil then
    self:InitMagicMarkPanel()
    self:MagicMark_ShowModel()
  end
  Event.RegisterEventWithContext(ModuleId.MAGIC_MARK, gmodule.notifyId.MagicMark.MAGIC_MARK_CHANGED, MagicMarkNode.OnMagicMarkChanged, self)
  Event.RegisterEventWithContext(ModuleId.MAGIC_MARK, gmodule.notifyId.MagicMark.MAGIC_MARK_UNLOCKED, MagicMarkNode.OnMagicMarkUnlocked, self)
  Event.RegisterEventWithContext(ModuleId.MAGIC_MARK, gmodule.notifyId.MagicMark.MAGIC_MARK_EXPIRED, MagicMarkNode.OnMagicMarkExpired, self)
end
def.override().OnHide = function(self)
  if self.magicmark_model then
    self.magicmark_model:Destroy()
    self.magicmark_model = nil
  end
  self._uiObjs = nil
  self._magicmaskItemTemplate = nil
  self._showMagicMarkItemData = nil
  self.selectedMarkIdx = 0
  self._isDrag = false
  Event.UnregisterEvent(ModuleId.MAGIC_MARK, gmodule.notifyId.MagicMark.MAGIC_MARK_CHANGED, MagicMarkNode.OnMagicMarkChanged)
  Event.UnregisterEvent(ModuleId.MAGIC_MARK, gmodule.notifyId.MagicMark.MAGIC_MARK_UNLOCKED, MagicMarkNode.OnMagicMarkUnlocked)
  Event.UnregisterEvent(ModuleId.MAGIC_MARK, gmodule.notifyId.MagicMark.MAGIC_MARK_EXPIRED, MagicMarkNode.OnMagicMarkExpired)
end
def.method().InitMagicMarkPanel = function(self)
  self._uiObjs = {}
  self._uiObjs.mm_ScrollView_Item = self.m_node:FindDirect("Bg_Item/Scroll View_Item")
  self._uiObjs.mm_Grid_Item = self._uiObjs.mm_ScrollView_Item:FindDirect("Grid_Item")
  self._magicmaskItemTemplate = self._uiObjs.mm_Grid_Item:FindDirect("FY_Item1")
  self._uiObjs.mm_Group_Left = self.m_node:FindDirect("Group_Left")
  self._uiObjs.mm_Toggle_Have = self.m_node:FindDirect("Toggle_Have")
  self._uiObjs.mm_Model = self._uiObjs.mm_Group_Left:FindDirect("Model")
  self._uiObjs.mm_Bg_Info = self._uiObjs.mm_Group_Left:FindDirect("Bg_Info")
  self._uiObjs.mm_ScrollView_Info = self._uiObjs.mm_Bg_Info:FindDirect("Scroll View")
  self._uiObjs.mm_Container_Info = self._uiObjs.mm_ScrollView_Info:FindDirect("Container")
  self._uiObjs.mm_Label_Name = self._uiObjs.mm_Container_Info:FindDirect("Label_Name")
  self._uiObjs.mm_Label_Time = self._uiObjs.mm_Container_Info:FindDirect("Label_Time")
  self._uiObjs.mm_Label_Info = self._uiObjs.mm_Container_Info:FindDirect("Label_Info")
  self._uiObjs.mm_Label_Attribute = self._uiObjs.mm_Container_Info:FindDirect("Label_Attribute")
  self._uiObjs.mm_Label_Way = self._uiObjs.mm_Container_Info:FindDirect("Label_Way")
  self._uiObjs.mm_MainOperationBtn = self.m_node:FindDirect("Group_Btn/Btn_FY_UnLock")
  self._uiObjs.mm_Group_Wear = self.m_node:FindDirect("Group_Btn/Group_UnLocked")
  self._uiObjs.mm_MainOperationBtn:SetActive(false)
  self._uiObjs.Label_Effect = self._uiObjs.mm_Container_Info:FindDirect("Label_Effect")
  self._uiObjs.Label_Effect:GetComponent("NGUIHTML"):set_depth(1)
  if self._uiObjs.Label_Effect:GetComponent("BoxCollider") ~= nil then
    self._uiObjs.Label_Effect:GetComponent("BoxCollider"):set_enabled(false)
  end
end
def.method().MagicMark_ShowModel = function(self)
  if self.magicmark_model then
    local ani = self.magicmark_model.m_model:GetComponent("Animation")
    if ani then
      ani.enabled = false
      ani.enabled = true
    end
    self.magicmark_model:Play(ActionName.Stand)
    return
  end
  if self.m_panel ~= nil and not self.m_panel.isnil then
    do
      local uiModel = self._uiObjs.mm_Model:GetComponent("UIModel")
      local heroProp = require("Main.Hero.Interface").GetHeroProp()
      if heroProp == nil then
        return
      end
      local modelId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyModelId()
      self.magicmark_model = ECUIModel.new(modelId)
      self.magicmark_model.m_bUncache = true
      local modelInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleModelInfo(gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId)
      self.magicmark_model:AddOnLoadCallback("FashionPanel", function()
        if self.m_panel == nil or self.m_panel.isnil then
          self.magicmark_model:Destroy()
          self.magicmark_model = nil
          return
        end
        if self.magicmark_model == nil or self.magicmark_model.m_model == nil or self.magicmark_model.m_model.isnil or uiModel == nil or uiModel.isnil then
          return
        end
        uiModel.modelGameObject = self.magicmark_model.m_model
        if uiModel.mCanOverflow ~= nil then
          uiModel.mCanOverflow = true
          local camera = uiModel:get_modelCamera()
          camera:set_orthographic(true)
        end
        self:UpdateMagicMarks()
        self:MagicMark_SelectItemByIdx(self.selectedMarkIdx)
      end)
      _G.LoadModel(self.magicmark_model, modelInfo, 0, 0, 180, false, false)
    end
  end
end
def.method().UpdateMagicMarks = function(self)
  if self._uiObjs == nil then
    return
  end
  local magic_mark_mgr = gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK)
  local items = magic_mark_mgr:GetAllMagicMarkItemCfg()
  self._showMagicMarkItemData = {}
  local showOwnedOnly = self._uiObjs.mm_Toggle_Have:GetComponent("UIToggle").isChecked
  local locked = {}
  for k, markcfg in pairs(items) do
    if magic_mark_mgr:hasMagicMark(markcfg.magicMarkType) then
      table.insert(self._showMagicMarkItemData, markcfg)
    elseif not showOwnedOnly then
      table.insert(locked, markcfg)
    end
  end
  if not showOwnedOnly then
    for _, cfg in pairs(locked) do
      table.insert(self._showMagicMarkItemData, cfg)
    end
  end
  local itemObjParent = self._uiObjs.mm_Grid_Item
  local uiGrid = itemObjParent:GetComponent("UIGrid")
  local visibleCount = uiGrid:GetChildListCount()
  local itemCount = #self._showMagicMarkItemData
  for i = 1, itemCount do
    local item = self._showMagicMarkItemData[i]
    local itemObj = itemObjParent:FindDirect("FY_Item" .. i)
    if itemObj == nil then
      itemObj = GameObject.Instantiate(self._magicmaskItemTemplate)
      itemObj.name = "FY_Item" .. i
      uiGrid:AddChild(itemObj.transform)
      itemObj.transform.localScale = Vector3.one
    end
    itemObj:FindDirect("Img_Select"):SetActive(false)
    itemObj:FindDirect("Img_Try"):SetActive(false)
    local itemIcon = itemObj:FindDirect("Img_Icon")
    itemIcon:SetActive(true)
    local uiTexture = itemIcon:GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, item.iconId)
    local lockIcon = itemObj:FindDirect("Sprite")
    if magic_mark_mgr:hasMagicMark(item.magicMarkType) then
      lockIcon:SetActive(false)
      GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
    else
      lockIcon:SetActive(true)
      GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
    end
    if item.magicMarkType == magic_mark_mgr.currentMagicMarkId then
      itemObj:FindDirect("Img_Fit"):SetActive(true)
    else
      itemObj:FindDirect("Img_Fit"):SetActive(false)
    end
    if item.magicMarkType == magic_mark_mgr.currentMagicMarkId and self.selectedMarkIdx <= 0 then
      self.selectedMarkIdx = i
    end
  end
  for i = itemCount + 1, 30 do
    local itemObj = itemObjParent:FindDirect("FY_Item" .. i)
    if itemObj == nil then
      itemObj = GameObject.Instantiate(self._magicmaskItemTemplate)
      itemObj.name = "FY_Item" .. i
      uiGrid:AddChild(itemObj.transform)
      itemObj.transform.localScale = Vector3.one
      itemObj:GetComponent("UIToggle"):set_enabled(false)
    end
    local childCount = itemObj.transform.childCount
    for k = 1, childCount do
      local child = itemObj.transform:GetChild(k - 1).gameObject
      if child.name ~= "Img_Bg" then
        child:SetActive(false)
      end
    end
  end
  if visibleCount > 30 then
    for i = 31, visibleCount do
      local itemObj = itemObjParent:FindDirect("FY_Item" .. i)
      if not _G.IsNil(itemObj) then
        uiGrid:RemoveChild(itemObj.transform)
        itemObj:Destroy()
      end
    end
  end
  uiGrid:DragToMakeVisible(0, 24)
end
def.method("number").MagicMark_SelectItemByIdx = function(self, idx)
  if idx > #self._showMagicMarkItemData then
    return
  end
  self:MagicMark_ChooseItem(idx)
  self:SetMagicMark()
  self:MagicMark_ShowItemInfo(idx)
  self:MagicMark_UpdateOperationBtn()
  self:MagicMark_UpdateLeftTime(idx)
end
def.method().SetMagicMark = function(self)
  if self.magicmark_model then
    local currentMagicMark = self._showMagicMarkItemData[self.selectedMarkIdx]
    if currentMagicMark and currentMagicMark.modelId > 0 then
      self.magicmark_model:SetMagicMark(currentMagicMark.modelId)
    else
      self.magicmark_model:SetMagicMark(0)
    end
  end
end
def.method("number").MagicMark_ChooseItem = function(self, idx)
  if self._uiObjs == nil then
    return
  end
  if self.selectedMarkIdx ~= idx and self.selectedMarkIdx > 0 then
    local preObj = self._uiObjs.mm_Grid_Item:FindDirect("FY_Item" .. self.selectedMarkIdx)
    local iconTry = preObj:FindDirect("Img_Try")
    iconTry:SetActive(false)
    local uiToggle = preObj:GetComponent("UIToggle")
    uiToggle.value = false
  end
  self.selectedMarkIdx = idx
  if idx < 1 then
    return
  end
  local itemObj = self._uiObjs.mm_Grid_Item:FindDirect("FY_Item" .. idx)
  itemObj:FindDirect("Img_Select"):SetActive(true)
  local uiToggle = itemObj:GetComponent("UIToggle")
  uiToggle.value = true
  local magicMarkItem = self._showMagicMarkItemData[idx]
  if magicMarkItem and magicMarkItem.magicMarkType ~= gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK).currentMagicMarkId then
    itemObj:FindDirect("Img_Try"):SetActive(true)
  end
end
def.method("number").MagicMark_ShowItemInfo = function(self, idx)
  if self._uiObjs == nil then
    return
  end
  if idx < 1 then
    self._uiObjs.mm_Label_Name:GetComponent("UILabel"):set_text(textRes.MagicMark[9])
    self._uiObjs.mm_Label_Info:GetComponent("UILabel"):set_text("")
    self._uiObjs.mm_Label_Attribute:GetComponent("UILabel"):set_text(textRes.Common[1])
    self._uiObjs.mm_Label_Way:GetComponent("UILabel"):set_text(textRes.Common[1])
    self._uiObjs.Label_Effect:GetComponent("NGUIHTML"):ForceHtmlText(textRes.Fashion[9])
  else
    local item = self._showMagicMarkItemData[idx]
    self._uiObjs.mm_Label_Name:GetComponent("UILabel"):set_text(item.name)
    self._uiObjs.mm_Label_Info:GetComponent("UILabel"):set_text(item.desc)
    self._uiObjs.mm_Label_Way:GetComponent("UILabel"):set_text(item.howToGet)
    local props = item.properties
    local propertyDesc = {}
    for i = 1, #props do
      local prop_cfg = require("Main.Skill.SkillUtility").GetSkillCfg(props[i])
      if prop_cfg ~= nil then
        table.insert(propertyDesc, prop_cfg.description)
      end
    end
    if #propertyDesc == 0 then
      self._uiObjs.mm_Label_Attribute:GetComponent("UILabel"):set_text(textRes.Fashion[4])
    else
      self._uiObjs.mm_Label_Attribute:GetComponent("UILabel"):set_text(table.concat(propertyDesc, "\n"))
    end
    local skillEffects = item.effectSkills
    local effectDesc = {}
    for i = 1, #skillEffects do
      local skillId = skillEffects[i]
      local skillCfg = require("Main.Skill.SkillUtility").GetSkillCfg(skillId)
      if skillCfg ~= nil then
        table.insert(effectDesc, string.format(textRes.Fashion[32], skillId, skillCfg.name))
      end
    end
    if #effectDesc == 0 then
      self._uiObjs.Label_Effect:GetComponent("NGUIHTML"):ForceHtmlText(textRes.Fashion[9])
    else
      self._uiObjs.Label_Effect:GetComponent("NGUIHTML"):ForceHtmlText(table.concat(effectDesc, "&nbsp;"))
    end
  end
end
def.method().MagicMark_UpdateOperationBtn = function(self)
  if self._uiObjs == nil then
    return
  end
  local item = self._showMagicMarkItemData[self.selectedMarkIdx]
  if item ~= nil then
    if gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK):hasMagicMark(item.magicMarkType) then
      self._uiObjs.mm_MainOperationBtn:SetActive(false)
      self._uiObjs.mm_Group_Wear:SetActive(true)
      local isCurrent = item.magicMarkType == gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK).currentMagicMarkId
      self._uiObjs.mm_Group_Wear:FindDirect("Btn_Fit"):SetActive(not isCurrent)
      self._uiObjs.mm_Group_Wear:FindDirect("Btn_TakeOut"):SetActive(isCurrent)
    else
      self._uiObjs.mm_MainOperationBtn:SetActive(true)
      self._uiObjs.mm_Group_Wear:SetActive(false)
    end
  else
    self._uiObjs.mm_MainOperationBtn:SetActive(false)
    self._uiObjs.mm_Group_Wear:SetActive(false)
  end
end
def.method("number").MagicMark_UpdateLeftTime = function(self, idx)
  if self._uiObjs == nil then
    return
  end
  if idx < 1 then
    self._uiObjs.mm_Label_Time:GetComponent("UILabel"):set_text(textRes.Fashion[3])
  else
    local magic_mark_mgr = gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK)
    local item = self._showMagicMarkItemData[self.selectedMarkIdx]
    if item ~= nil then
      if magic_mark_mgr:hasMagicMark(item.magicMarkType) then
        if Int64.lt(magic_mark_mgr.owned[item.magicMarkType], 0) then
          self._uiObjs.mm_Label_Time:GetComponent("UILabel"):set_text(textRes.Fashion[3])
        else
          self._uiObjs.mm_Label_Time:GetComponent("UILabel"):set_text(FashionUtils.ConvertSecondToSentence(magic_mark_mgr.owned[item.magicMarkType]))
        end
      else
        self._uiObjs.mm_Label_Time:GetComponent("UILabel"):set_text(textRes.MagicMark[8])
      end
    end
  end
end
def.method().ResetMagicMark = function(self)
  self.selectedMarkIdx = 0
  self:UpdateMagicMarks()
  self:MagicMark_SelectItemByIdx(self.selectedMarkIdx)
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_FY_ReSet" then
    self:ResetMagicMark()
  elseif id == "Btn_FY_UnLock" or id == "Btn_Extend" then
    if IsCrossingServer() then
      ToastCrossingServerForbiden()
      return false
    end
    local item = self._showMagicMarkItemData[self.selectedMarkIdx]
    if item then
      require("Main.MagicMark.ui.DlgMagicMarkUnlock").Instance():ShowDlg(item.magicMarkType)
    end
  elseif string.find(id, "FY_Item") == 1 then
    local itemIdx = tonumber(string.sub(id, #"FY_Item" + 1))
    self:MagicMark_SelectItemByIdx(itemIdx)
  elseif id == "Btn_FY_Effect" then
    require("Main.MagicMark.ui.MagicMarkPropPanel").Instance():ShowDlg()
  elseif id == "Btn_TakeOut" then
    if IsCrossingServer() then
      ToastCrossingServerForbiden()
      return
    end
    local item = self._showMagicMarkItemData[self.selectedMarkIdx]
    if item == nil then
      Toast(textRes.Fashion[13])
      return
    end
    gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK):RemoveMagicMark(item.magicMarkType)
  elseif id == "Btn_Fit" then
    if IsCrossingServer() then
      ToastCrossingServerForbiden()
      return
    end
    local item = self._showMagicMarkItemData[self.selectedMarkIdx]
    if item == nil then
      Toast(textRes.Fashion[13])
      return
    end
    gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK):SetMagicMark(item.magicMarkType)
  elseif id == "Toggle_Have" then
    if self._showMagicMarkItemData == nil then
      return
    end
    local item = self._showMagicMarkItemData[self.selectedMarkIdx]
    self:UpdateMagicMarks()
    if item then
      for i = 1, #self._showMagicMarkItemData do
        if item.magicMarkType == self._showMagicMarkItemData[i].magicMarkType then
          self.selectedMarkIdx = i
          break
        end
      end
    end
    self:MagicMark_SelectItemByIdx(self.selectedMarkIdx)
  elseif string.find(id, "skill_") == 1 then
    local skillId = tonumber(string.sub(id, 7))
    self:_ShowSkillTips(skillId)
  end
end
def.override("string").onDragStart = function(self, id)
  if id == "Model" then
    self._isDrag = true
  end
end
def.override("string").onDragEnd = function(self, id)
  self._isDrag = false
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self._isDrag == true and self.magicmark_model then
    self.magicmark_model:SetDir(self.magicmark_model.m_ang - dx / 2)
  end
end
def.method("table").OnMagicMarkChanged = function(self, params)
  self:UpdateMagicMarks()
  self:MagicMark_SelectItemByIdx(self.selectedMarkIdx)
end
def.method("table").OnMagicMarkUnlocked = function(self, params)
  self:UpdateMagicMarks()
  self:MagicMark_SelectItemByIdx(self.selectedMarkIdx)
end
def.method("table").OnMagicMarkExpired = function(self, params)
  self:UpdateMagicMarks()
  self:MagicMark_SelectItemByIdx(self.selectedMarkIdx)
end
def.method("number")._ShowSkillTips = function(self, skillId)
  require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdEx(skillId, self._uiObjs.Label_Effect:FindDirect("skill_" .. skillId), 0)
end
MagicMarkNode.Commit()
return MagicMarkNode
