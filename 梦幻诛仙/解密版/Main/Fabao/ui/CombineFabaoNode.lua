local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local EquipModule = require("Main.Equip.EquipModule")
local ItemModule = require("Main.Item.ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local WearPos = require("consts.mzm.gsp.item.confbean.WearPos")
local SkillTipMgr = require("Main.Skill.SkillTipMgr")
local FabaoMgr = require("Main.Fabao.FabaoMgr")
local FabaoPanelNodeBase = require("Main.Fabao.ui.FabaoPanelNodeBase")
local CombineFabaoNode = Lplus.Extend(FabaoPanelNodeBase, "CombineFabaoNode")
local def = CombineFabaoNode.define
def.field("boolean").m_Continue = false
def.field("number").m_FragmentCount = 0
def.field("number").m_ShowSkillCount = 9
def.field("table").m_SkillData = nil
def.field("table").m_SeverReturnInfo = nil
local instance
def.static("=>", CombineFabaoNode).Instance = function()
  if not instance then
    instance = CombineFabaoNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  FabaoPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:Update()
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.COMBINE_SUCCESS, CombineFabaoNode.OnCombineSuccess)
end
def.override().OnHide = function(self)
  self:Clear()
  Event.UnregisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.COMBINE_SUCCESS, CombineFabaoNode.OnCombineSuccess)
end
def.override().InitUI = function(self)
  FabaoPanelNodeBase.InitUI(self)
  self.m_UIGO = {}
  self.m_UIGO.Img_Bg = self.m_node:FindDirect("Group_Slide/Img_Bg")
  self.m_UIGO.Icon_Equip = self.m_node:FindDirect("Group_Preview/Icon_Equip")
  self.m_UIGO.Btn_DZ_Make = self.m_node:FindDirect("Group_Make/Btn_DZ_Make")
  self.m_UIGO.Texture_Icon = self.m_node:FindDirect("Group_Describe/Img_BgIcon/Texture_Icon")
  self.m_UIGO.Label_Describe = self.m_node:FindDirect("Group_Describe/Label_Describe")
  self.m_UIGO.Label_ExpNum = self.m_node:FindDirect("Group_Slide/Label_ExpNum")
  self.m_UIGO.Img_DZ_BgEquipMakeItem03 = self.m_node:FindDirect("Group_Make/Img_DZ_BgEquipMakeItem03")
  self.m_UIGO.Label_DZ_EquipMakeName03 = self.m_node:FindDirect("Group_Make/Label_DZ_EquipMakeName03")
  self.m_UIGO.Icon_DZ_EquipMakeItem03 = self.m_node:FindDirect("Group_Make/Img_DZ_BgEquipMakeItem03/Icon_DZ_EquipMakeItem03")
  self.m_UIGO.List_Attribute = self.m_node:FindDirect("Group_Attribute/Scroll View/List_Attribute")
  self.m_UIGO.List_Skill = self.m_node:FindDirect("Group_Skill/Scroll View/List_Skill")
  self.m_UIGO.Scroll_View = self.m_node:FindDirect("Group_Skill/Scroll View")
end
def.override().Clear = function(self)
  self.m_FragmentCount = 0
  self.m_ShowSkillCount = 9
  self.m_SkillData = nil
  self.m_SeverReturnInfo = nil
  FabaoPanelNodeBase.Clear(self)
end
def.override("=>", "boolean").IsUnlock = function(self)
  return true
end
def.static("table", "table").OnCombineSuccess = function(params)
  instance.m_SeverReturnInfo = params
  instance:ShowItemTips()
  local go = instance.m_UIGO.Icon_Equip
  if not go or go.isnil then
    return
  end
  require("Fx.GUIFxMan").Instance():PlayAsChild(go, RESPATH.PANEL_FABAO_HC_EFFECT, 0, 0, -1, false)
end
def.method().ShowItemTips = function(self)
  local params = instance.m_SeverReturnInfo
  if not params then
    warn("ShowItemTips Empty params")
    return
  end
  ItemModule.Instance():BlockItemGetEffect(true)
  GameUtil.AddGlobalTimer(1, true, function()
    if instance and instance.m_panel and not instance.m_panel.isnil then
      local btn = instance.m_UIGO.Icon_Equip
      local _, posItem = ItemModule.Instance():GetItemByPosition(ItemModule.EQUIPBAG, WearPos.FABAO)
      if posItem and posItem.uuid[1] == params.eqpInfo.uuid[1] then
        ItemTipsMgr.Instance():ShowTipsEx(params.eqpInfo, 0, 0, 0, btn, 0)
      else
        ItemTipsMgr.Instance():ShowTipsEx(params.eqpInfo, ItemModule.EQUIPBAG, params.key, ItemTipsMgr.Source.FabaoBag, btn, 0)
      end
      instance:UpdateFabaoColorView(true, Color.white)
    end
    ItemModule.Instance():BlockItemGetEffect(false)
  end)
end
def.method().CombineItem = function(self)
  local count = self.m_FragmentCount
  local maxCount = self.m_Item.data.fragmentCount
  local fragmentId = self.m_Item.data.fragmentId
  if count < maxCount then
    local btnGO = self.m_UIGO.Btn_DZ_Make
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(fragmentId, btnGO, -1, true)
    Toast(textRes.Fabao[3])
    return
  end
  local itemId = self.m_Item.baseData.itemid
  FabaoMgr.CombineItem(itemId)
end
def.method().Preview = function(self)
  if not self.m_Item then
    return
  end
  Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.BTN_PREVIEW_CLICK, {
    id = self.m_Item.baseData.itemid
  })
end
def.override("string").onClick = function(self, id)
  if id == "Btn_DZ_Make" then
    self:CombineItem()
  elseif id == "Btn_Preview" then
    self:Preview()
  elseif id == "Img_DZ_BgEquipMakeItem03" then
    local btnGO = self.m_UIGO[id]
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(self.m_Item.data.fragmentId, btnGO, -1, true)
  elseif id == "Icon_Equip" then
    self:ShowItemTips()
  elseif id == "Btn_Tip" then
    local tipContent = textRes.Fabao[64]
    local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
    CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 50, y = 75})
  elseif id:find("Img_Icon_") == 1 then
    local _, lastIndex = id:find("Img_Icon_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    local skillCfg = self.m_SkillData[index]
    local btnGO = self.m_UIGO[id]
    if not skillCfg or not btnGO then
      return
    end
    SkillTipMgr.Instance():ShowTipByIdEx(skillCfg.cfg.id, btnGO, 0)
  end
end
def.override("string", "boolean").onPress = function(self, id, state)
  if id:find("Group_Skill") == 1 then
    if state and not self.m_Continue then
      self.m_Continue = true
    elseif not state then
      self.m_Continue = false
    end
  end
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
  if id:find("Group_Skill") == 1 then
    if dy > 5 and self.m_Continue then
      self.m_ShowSkillCount = self.m_ShowSkillCount + 6
      self.m_ShowSkillCount = self.m_ShowSkillCount > #self.m_SkillData and #self.m_SkillData or self.m_ShowSkillCount
      self.m_Continue = false
      self:UpdateRightMiddleView()
    elseif dy < -5 and self.m_Continue then
      self.m_ShowSkillCount = self.m_ShowSkillCount - 3
      self.m_ShowSkillCount = self.m_ShowSkillCount < 6 and 6 or self.m_ShowSkillCount
      self.m_Continue = false
      self:UpdateRightMiddleView()
    elseif self.m_Continue then
      self.m_Continue = false
    end
  end
end
def.override("table").UpdateItem = function(self, item)
  FabaoPanelNodeBase.UpdateItem(self, item)
  local id = self.m_Item.id
  self.m_Item = FabaoMgr.GetFabaoTemplateData(id)
end
def.method().UpdateFragmentCount = function(self)
  if not self.m_Item then
    return
  end
  self.m_FragmentCount = FabaoMgr.GetItemFromBag(self.m_Item.data.fragmentId)
end
def.method().UpdataSkillData = function(self)
  self.m_SkillData = {}
  local skillCfg = FabaoMgr.GetFabaoEffectCfg(self.m_Item.baseData.itemid)
  table.sort(skillCfg, function(l, r)
    if l and r then
      return l.specific
    else
      return false
    end
  end)
  for k, v in pairs(skillCfg) do
    self.m_SkillData[k] = {}
    self.m_SkillData[k].skillId = v.skillId
    self.m_SkillData[k].specific = v.specific
    self.m_SkillData[k].cfg = FabaoMgr.GetFabaoEffectSkillCfg(v.skillId, 0)
  end
  table.sort(self.m_SkillData, function(l, r)
    if l.specific ~= r.specific then
      return l.specific
    elseif l.skillId ~= r.skillId then
      return l.skillId < r.skillId
    end
  end)
end
def.method().ResetPosition = function(self)
  self.m_ShowSkillCount = 9
  local scrollViewGO = self.m_UIGO.Scroll_View
  GUIUtils.ResetPosition(scrollViewGO, 0.1)
end
def.method("boolean", "userdata").UpdateFabaoColorView = function(self, flag, color)
  if not self.m_Item then
    return
  end
  local iconGO = self.m_UIGO.Icon_Equip
  GUIUtils.SetCollider(iconGO, flag)
  GUIUtils.SetColor(iconGO, color, GUIUtils.COTYPE.TEXTURE)
end
def.method().UpdateTopView = function(self)
  if not self.m_Item then
    return
  end
  local iconGO = self.m_UIGO.Texture_Icon
  local labelGO = self.m_UIGO.Label_Describe
  local icon = self.m_Item.baseData.icon
  local desc = self.m_Item.baseData.desc
  GUIUtils.SetTexture(iconGO, icon)
  GUIUtils.SetText(labelGO, desc)
end
def.method().UpdateLeftMiddleView = function(self)
  local attriData = FabaoMgr.GetFabaoAllAttribute()
  local uiListGO = self.m_UIGO.List_Attribute
  local itemCount = #attriData
  local listItems = GUIUtils.InitUIList(uiListGO, itemCount)
  self.m_base.m_msgHandler:Touch(uiListGO)
  for i = 1, itemCount do
    local itemGO = listItems[i]
    local itemData = attriData[i]
    local nameGO = itemGO:FindDirect(("Label_Name_%d"):format(i))
    local numGO = itemGO:FindDirect(("Label_Num_%d"):format(i))
    local attriName = EquipModule.GetAttriName(itemData.attrId)
    GUIUtils.SetText(nameGO, attriName)
    GUIUtils.SetText(numGO, ("+ %d"):format(itemData.initValue))
  end
  GUIUtils.Reposition(uiListGO, GUIUtils.COTYPE.LIST, 0)
end
def.method().UpdateRightMiddleView = function(self)
  local uiListGO = self.m_UIGO.List_Skill
  local itemCount = self.m_ShowSkillCount > #self.m_SkillData and #self.m_SkillData or self.m_ShowSkillCount
  local listItems = GUIUtils.InitUIList(uiListGO, itemCount)
  self.m_base.m_msgHandler:Touch(uiListGO)
  for i = 1, itemCount do
    local itemGO = listItems[i]
    local itemData = self.m_SkillData[i]
    local nameGO = itemGO:FindDirect(("Label_Name_%d"):format(i))
    local iconGO = itemGO:FindDirect(("Item_001_%d/Img_Icon_%d"):format(i, i))
    local newGO = itemGO:FindDirect(("Item_001_%d/Img_New_%d"):format(i, i))
    GUIUtils.SetText(nameGO, itemData.cfg.name)
    GUIUtils.SetTexture(iconGO, itemData.cfg.icon)
    GUIUtils.SetActive(newGO, itemData.specific)
    self.m_UIGO[("Img_Icon_%d"):format(i)] = iconGO
  end
  GUIUtils.Reposition(uiListGO, GUIUtils.COTYPE.LIST, 0)
end
def.method().UpdateFabaoView = function(self)
  if not self.m_Item then
    return
  end
  local iconGO = self.m_UIGO.Icon_Equip
  local icon = self.m_Item.baseData.icon
  GUIUtils.SetTexture(iconGO, icon)
  self:UpdateFabaoColorView(false, Color.gray)
end
def.method().UpdateShatterView = function(self)
  if not self.m_Item then
    return
  end
  local iconGO = self.m_UIGO.Icon_DZ_EquipMakeItem03
  local labelGO = self.m_UIGO.Label_DZ_EquipMakeName03
  local fragmentId = self.m_Item.data.fragmentId
  local data = ItemUtils.GetItemBase(fragmentId)
  GUIUtils.SetTexture(iconGO, data.icon)
  GUIUtils.SetText(labelGO, data.name)
end
def.method().UpdateProgressView = function(self)
  if not self.m_Item then
    return
  end
  local silderGO = self.m_UIGO.Img_Bg
  local labelGO = self.m_UIGO.Label_ExpNum
  local count = self.m_FragmentCount
  local maxCount = self.m_Item.data.fragmentCount
  GUIUtils.SetProgress(silderGO, GUIUtils.COTYPE.SLIDER, count / maxCount)
  if not (count < maxCount) or not Color.red then
  end
  GUIUtils.SetTextAndColor(labelGO, ("%d/%d"):format(count, maxCount), (Color.Color(0.30980392156862746, 0.18823529411764706, 0.09411764705882353)))
end
def.method().UpdateBottomView = function(self)
  self:UpdateShatterView()
  self:UpdateProgressView()
end
def.method().Update = function(self)
  self:ResetPosition()
  self:UpdateFragmentCount()
  self:UpdataSkillData()
  self:UpdateTopView()
  self:UpdateLeftMiddleView()
  self:UpdateRightMiddleView()
  self:UpdateBottomView()
end
def.method().OnClickLeftFaBaoItem = function(self)
end
return CombineFabaoNode.Commit()
