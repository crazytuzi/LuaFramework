local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgSkillTraining = Lplus.Extend(ECPanelBase, "DlgSkillTraining")
local GUIUtils = require("GUI.GUIUtils")
local OccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local SkillUtility = require("Main.Skill.SkillUtility")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local def = DlgSkillTraining.define
local instance
def.field("number").selectedIdx = 1
def.field("userdata").childId = nil
def.field("table").skills = nil
def.static("=>", DlgSkillTraining).Instance = function()
  if instance == nil then
    instance = DlgSkillTraining()
  end
  return instance
end
def.method("userdata").ShowPanel = function(self, childId)
  if self.m_panel ~= nil then
    return
  end
  self.childId = childId
  self:CreatePanel(RESPATH.PREFAB_CHILDREN_SKILL_TRAIN, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Skill_Level_Updated, DlgSkillTraining.RefreshSkillLevel)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, DlgSkillTraining.OnBagInfoSynchronized)
  self:ShowSkills()
  self.selectedIdx = 1
  local skill = self.skills[self.selectedIdx]
  if skill then
    self:OnSelectSkill(skill.skillid)
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Skill_Level_Updated, DlgSkillTraining.RefreshSkillLevel)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, DlgSkillTraining.OnBagInfoSynchronized)
end
def.static("table", "table").OnBagInfoSynchronized = function(p1, p2)
  instance:ShowCostItems()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("------DlgSkillTraining:", id)
  if string.find(id, "Img_Skill_") then
    self.selectedIdx = tonumber(string.sub(id, #"Img_Skill_" + 1, -1))
    local skill = self.skills[self.selectedIdx]
    if skill then
      self:OnSelectSkill(skill.skillid)
    end
  elseif id == "Toggle_Captain" then
    local isChecked = self.m_panel:FindDirect("Img_Bg0/Group_Right_YingEr/Group_Set/Toggle_Captain"):GetComponent("UIToggle").isChecked
    local childData = require("Main.Children.ChildrenDataMgr").Instance():GetChildById(self.childId)
    local maxFightSkillNum = constant.CChildrenConsts.child_fight_skill_max
    local fightSkill1 = childData and childData.info.fightSkills[1]
    local fightSkill = childData and childData.info.fightSkills[maxFightSkillNum]
    if isChecked and fightSkill1 and fightSkill1 > 0 and fightSkill == nil and maxFightSkillNum == 2 then
      local childEquipLv = childData:GetEquipsMinLevel()
      local needLevel = constant.CChildrenConsts.child_take_twoskills_equipment_level
      if childEquipLv < needLevel then
        Toast(string.format(textRes.Children[35], needLevel))
        self.m_panel:FindDirect("Img_Bg0/Group_Right_YingEr/Group_Set/Toggle_Captain"):GetComponent("UIToggle").value = false
        return
      end
    end
    if isChecked and fightSkill and fightSkill > 0 then
      Toast(textRes.Children[3051])
      self.m_panel:FindDirect("Img_Bg0/Group_Right_YingEr/Group_Set/Toggle_Captain"):GetComponent("UIToggle").value = false
      return
    end
    local skillId = self.skills[self.selectedIdx].skillid
    local pro = require("netio.protocol.mzm.gsp.Children.CFightSkillOperReq")
    local use = pro.USE
    if not isChecked then
      use = pro.UN_USE
    end
    gmodule.network.sendProtocol(pro.new(self.childId, skillId, use))
  elseif id == "Btn_SkillUp" then
    local skillId = self.skills[self.selectedIdx].skillid
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.Children.CLevelUpOccupationSkillReq").new(self.childId, skillId))
  elseif id == "Btn_Add" then
    _G.GoToBuySilver()
  elseif id == "Btn_Cancel" then
    local childData = require("Main.Children.ChildrenDataMgr").Instance():GetChildById(self.childId)
    local fightSkill = 0
    for k, v in pairs(childData.info.fightSkills) do
      fightSkill = v
    end
    local pName = clickObj.parent.name
    if pName == "Img_BgIcon01" then
      fightSkill = childData.info.fightSkills[1]
    elseif pName == "Img_BgIcon02" then
      fightSkill = childData.info.fightSkills[2]
    end
    if fightSkill and fightSkill > 0 then
      local pro = require("netio.protocol.mzm.gsp.Children.CFightSkillOperReq")
      gmodule.network.sendProtocol(pro.new(self.childId, fightSkill, pro.UN_USE))
    else
      warn("!!!!!!!! cancel fightSkill is nil:", fightSkill)
    end
  elseif id == "Img_MakeItem" then
    self:ShowItemTip()
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Img_BgIcon01" then
    self:ShowMenpaiSkillTip(1, clickObj)
  elseif id == "Img_BgIcon02" then
    local childData = require("Main.Children.ChildrenDataMgr").Instance():GetChildById(self.childId)
    local childEquipLv = childData:GetEquipsMinLevel()
    local needLevel = constant.CChildrenConsts.child_take_twoskills_equipment_level
    if childEquipLv < needLevel then
      Toast(string.format(textRes.Children[35], needLevel))
      return
    end
    self:ShowMenpaiSkillTip(2, clickObj)
  end
end
def.method("number", "userdata").ShowMenpaiSkillTip = function(self, index, sourceObj)
  local childData = require("Main.Children.ChildrenDataMgr").Instance():GetChildById(self.childId)
  if childData == nil or childData.info == nil then
    return
  end
  local skillId = childData.info.fightSkills[index]
  local CommonSkillTip = require("GUI.CommonSkillTip")
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  if skillId and skillId > 0 then
    require("Main.Skill.SkillTipMgr").Instance():ShowChildSkillTip(skillId, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), -1, childData:GetMenpai(), self.childId)
  end
end
def.static("table", "table").RefreshSkillLevel = function(p1, p2)
  instance:ShowSkills()
  local skill = instance.skills[instance.selectedIdx]
  if skill then
    instance:OnSelectSkill(skill.skillid)
  end
end
def.method().ShowSkills = function(self)
  local childData = require("Main.Children.ChildrenDataMgr").Instance():GetChildById(self.childId)
  if childData == nil then
    return
  end
  local menpai = childData:GetMenpai()
  local allSkills = ChildrenUtils.GetMenpaiSkills(childData:GetMenpai())
  local childEquipLv = childData:GetEquipsMinLevel()
  local menpaiSkillMap = ChildrenUtils.GetMenpaiSkillMap(menpai)
  local skills = {}
  for i, v in ipairs(allSkills) do
    local skillCfgInfo = menpaiSkillMap[v.skillid]
    if skillCfgInfo and childEquipLv >= skillCfgInfo.needEquipmentLevel then
      table.insert(skills, v)
    end
  end
  self.skills = skills
  local listPanel = self.m_panel:FindDirect("Img_Bg0/Group_Left/ScrollView_Move/ScrollView_SkillList/List_SkillList")
  local uilist = listPanel:GetComponent("UIList")
  local count = #self.skills
  uilist.itemCount = count
  uilist:Resize()
  for i = 1, count do
    local skillPanel = listPanel:FindDirect("Img_Skill_" .. i)
    local skillId = self.skills[i].skillid
    local ui_Texture = skillPanel:FindDirect(string.format("Img_BgIcon_%d/Img_Icon_%d", i, i)):GetComponent("UITexture")
    local skillCfg = SkillUtility.GetSkillCfg(skillId)
    if skillCfg then
      GUIUtils.FillIcon(ui_Texture, skillCfg.iconId)
      skillPanel:FindDirect("Label_Name_" .. i):GetComponent("UILabel").text = skillCfg.name
      local skillLevel = childData:GetSkillLevel(skillId)
      local skill_max_level = ChildrenUtils.GetChildSkillMaxLevel()
      skillPanel:FindDirect("Label_Date_" .. i):GetComponent("UILabel").text = string.format("%d/%d", skillLevel, math.min(skill_max_level, childData.info.level))
    else
      GUIUtils.FillIcon(ui_Texture, 0)
      skillPanel:FindDirect("Label_Name_" .. i):GetComponent("UILabel").text = ""
      skillPanel:FindDirect("Label_Date_" .. i):GetComponent("UILabel").text = ""
    end
  end
  local fightSkill = childData.info.fightSkills[1]
  local fightSkillPanel = self.m_panel:FindDirect("Img_Bg0/Group_Right_YingEr")
  local ui_Texture = fightSkillPanel:FindDirect("Group_Skill/Img_BgIcon01/Img_Icon"):GetComponent("UITexture")
  fightSkillPanel:FindDirect("Group_Skill/Img_BgIcon01/Img_Select"):SetActive(false)
  if fightSkill and fightSkill > 0 then
    local skillCfg = SkillUtility.GetSkillCfg(fightSkill)
    GUIUtils.FillIcon(ui_Texture, skillCfg.iconId)
    fightSkillPanel:FindDirect("Group_Skill/Img_BgIcon01/Btn_Cancel"):SetActive(true)
  else
    fightSkillPanel:FindDirect("Group_Skill/Img_BgIcon01/Btn_Cancel"):SetActive(false)
    GUIUtils.FillIcon(ui_Texture, 0)
  end
  local fightSkill2 = childData.info.fightSkills[2]
  local ui_Texture2 = fightSkillPanel:FindDirect("Group_Skill/Img_BgIcon02/Img_Icon"):GetComponent("UITexture")
  fightSkillPanel:FindDirect("Group_Skill/Img_BgIcon02/Img_Select"):SetActive(false)
  if fightSkill2 and fightSkill2 > 0 then
    local skillCfg = SkillUtility.GetSkillCfg(fightSkill2)
    GUIUtils.FillIcon(ui_Texture2, skillCfg.iconId)
    fightSkillPanel:FindDirect("Group_Skill/Img_BgIcon02/Btn_Cancel"):SetActive(true)
    fightSkillPanel:FindDirect("Group_Skill/Img_BgIcon02/Img_Lock"):SetActive(false)
  else
    fightSkillPanel:FindDirect("Group_Skill/Img_BgIcon02/Btn_Cancel"):SetActive(false)
    GUIUtils.FillIcon(ui_Texture2, 0)
    local needLevel = constant.CChildrenConsts.child_take_twoskills_equipment_level
    if childEquipLv < needLevel then
      fightSkillPanel:FindDirect("Group_Skill/Img_BgIcon02/Img_Lock"):SetActive(true)
    else
      fightSkillPanel:FindDirect("Group_Skill/Img_BgIcon02/Img_Lock"):SetActive(false)
    end
  end
end
def.method("number").OnSelectSkill = function(self, skillId)
  local skillPanel = self.m_panel:FindDirect("Img_Bg0/Group_Right_YingEr")
  local skillCfg = SkillUtility.GetSkillCfg(skillId)
  local childData = require("Main.Children.ChildrenDataMgr").Instance():GetChildById(self.childId)
  if childData == nil then
    return
  end
  skillPanel:FindDirect("Group_Set/Toggle_Captain"):GetComponent("UIToggle").isChecked = childData:IsFightSkill(skillId)
  skillPanel:FindDirect("Group_Set/Label_SkillName"):GetComponent("UILabel").text = skillCfg.name
  skillPanel:FindDirect("Img_Operate/Scrollview/Label_Widget/Label_Slider"):GetComponent("UILabel").text = skillCfg.description
  self:ShowCostItems()
end
def.method().ShowCostItems = function(self)
  if self.skills == nil or self.m_panel == nil then
    return
  end
  local skill = self.skills[self.selectedIdx]
  if skill == nil then
    return
  end
  local skillId = skill.skillid
  local skillPanel = self.m_panel:FindDirect("Img_Bg0/Group_Right_YingEr")
  local childData = require("Main.Children.ChildrenDataMgr").Instance():GetChildById(self.childId)
  if childData == nil then
    return
  end
  local costPanel = skillPanel:FindDirect("Group_Buy")
  local skillLevel = childData:GetSkillLevel(skillId)
  local childSkillCfg = self.skills[self.selectedIdx]
  if childSkillCfg == nil then
    return
  end
  local cost = require("Main.Children.ChildrenUtils").GetChildSkillUpdateCfg(childSkillCfg.levelUpCostClassid, skillLevel)
  local ItemModule = require("Main.Item.ItemModule")
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local itemCount = ItemModule.Instance():GetNumByItemType(ItemModule.BAG, ItemType.CHILDREN_OCCUPATION_SKILL_LEVEL_UP)
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(childSkillCfg.mainItemid)
  local ui_texture = costPanel:FindDirect("Img_MakeItem/Icon_MakeItem01"):GetComponent("UITexture")
  GUIUtils.FillIcon(ui_texture, itemBase.icon)
  local ui_Label_num = costPanel:FindDirect("Img_MakeItem/Label_MakeItem01")
  ui_Label_num:GetComponent("UILabel"):set_text(string.format("%d/%d", itemCount, cost))
  costPanel:FindDirect("Label_ItemName"):GetComponent("UILabel").text = itemBase.name
end
def.method().ShowItemTip = function(self)
  if self.skills == nil or self.m_panel == nil then
    return
  end
  local skill = self.skills[self.selectedIdx]
  if skill == nil then
    return
  end
  local childSkillCfg = self.skills[self.selectedIdx]
  local itemId = childSkillCfg and childSkillCfg.mainItemid
  local sourceObj = self.m_panel:FindDirect("Img_Bg0/Group_Right_YingEr/Group_Buy/Img_MakeItem")
  if itemId then
    require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(itemId, sourceObj, -1, true)
  end
end
DlgSkillTraining.Commit()
return DlgSkillTraining
