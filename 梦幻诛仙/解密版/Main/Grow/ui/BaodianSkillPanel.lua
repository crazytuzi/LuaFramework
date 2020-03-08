local Lplus = require("Lplus")
local BaodianBasePanel = require("Main.Grow.ui.BaodianBasePanel")
local BaodianUtils = require("Main.Grow.BaodianUtils")
local GUIUtils = require("GUI.GUIUtils")
local SkillUtils = require("Main.Skill.SkillUtility")
local WingsUtils = require("Main.Wings.WingsUtility")
local FashionUtils = require("Main.Fashion.FashionUtils")
local BaodianSkillPanel = Lplus.Extend(BaodianBasePanel, "BaodianSkillPanel")
local def = BaodianSkillPanel.define
local NodeId = {
  MenPai = 1,
  Pet = 2,
  FaBao = 3,
  Wings = 4,
  Equip = 5,
  Fashion = 6
}
def.const("table").NodeId = NodeId
def.field("table").mUIObjs = nil
def.field("number").mCurSkillNode = 0
def.field("number").mCurSkillSelectId = 0
def.field("boolean").mIsDownSelect = false
def.field("table").mCurSkillIds = nil
def.field("table").mCurSkillNames = nil
def.field("table").mSelectIds = nil
def.field("table").mSelectNames = nil
def.field("table").mWingSubSkillIds = nil
def.field("number").mCurSkillId = 0
def.field("userdata").mParent = nil
local instance
def.static("=>", BaodianSkillPanel).Instance = function()
  if instance == nil then
    instance = BaodianSkillPanel()
  end
  return instance
end
def.override("userdata").ShowPanel = function(self, parentPanel)
  if self:IsShow() then
    return
  end
  self.mParent = parentPanel
  GameUtil.AddGlobalLateTimer(0, true, function()
    self:CreatePanel(RESPATH.PREFAB_BAODIAN_SKILL, 2)
  end)
end
def.override("userdata", "number").ShowPanelWithTargetNode = function(self, parentPanel, subNode)
  if not self:NeedSubNode() then
    return
  end
  if not self:CheckNodeExist(subNode) then
    return
  end
  if self:IsShow() then
    return
  end
  self.mCurSkillNode = subNode
  self.mParent = parentPanel
  GameUtil.AddGlobalLateTimer(0, true, function()
    self:CreatePanel(RESPATH.PREFAB_BAODIAN_SKILL, 2)
  end)
end
def.override("=>", "boolean").NeedSubNode = function(self)
  return true
end
def.override("number", "=>", "boolean").CheckNodeExist = function(self, targetSubNode)
  for k, v in pairs(NodeId) do
    if targetSubNode == v then
      return true
    end
  end
  return false
end
def.override().OnCreate = function(self)
  if self.mParent == nil or self.mParent.isnil == true then
    self:DestroyPanel()
    return
  end
  self:InitData()
  self:InitUI()
  self:SetChooseBtn()
  self:UpdateSkillListView()
  self:UpdateRightDetailView()
end
def.method().InitData = function(self)
  if 0 == self.mCurSkillNode then
    self.mCurSkillNode = NodeId.MenPai
  end
  self.mCurSkillSelectId = 0
  BaodianUtils.GetPetBookAllCfg()
  self:UpdateData()
end
def.method().InitUI = function(self)
  self.mUIObjs = {}
  local GroupTitle = self.m_panel:FindDirect("Group_Title")
  local GroupList = self.m_panel:FindDirect("Group_List")
  local GroupDetail = self.m_panel:FindDirect("Group_Detail")
  local GroupWing = self.m_panel:FindDirect("Grou_WingSkill")
  local GroupEquip = self.m_panel:FindDirect("Group_EquipShow")
  self.mUIObjs.groupTitle = GroupTitle
  self.mUIObjs.groupList = GroupList
  self.mUIObjs.groupDetail = GroupDetail
  self.mUIObjs.groupWing = GroupWing
  self.mUIObjs.groupEquip = GroupEquip
  GroupTitle:SetActive(true)
  GroupList:SetActive(true)
  GroupDetail:SetActive(true)
  GroupWing:SetActive(false)
  local ChooseBtn = self.m_panel:FindDirect("Group_Title/Group_Choose/Btn_SkillChoose")
  local upSprite = self.m_panel:FindDirect("Group_Title/Group_Choose/Btn_SkillChoose/Img_Up")
  local downSprite = self.m_panel:FindDirect("Group_Title/Group_Choose/Btn_SkillChoose/Img_Down")
  self.mUIObjs.upSprite = upSprite
  self.mUIObjs.downSprite = downSprite
  self.mUIObjs.ChooseBtn = ChooseBtn
  local selectLabel = self.m_panel:FindDirect("Group_Title/Group_Choose/Btn_SkillChoose/Label_Btn")
  self.mUIObjs.selectLabel = selectLabel
  local menpaiChooseView = self.m_panel:FindDirect("Group_Title/Group_Choose/Group_SkillChoose")
  local petChooseView = self.m_panel:FindDirect("Group_Title/Group_Choose/Group_PetSkillChoose")
  local menpaiChooseList = menpaiChooseView:FindDirect("Scroll View/List_SkillChoose")
  local petChooseList = petChooseView:FindDirect("Scroll View/List_SkillChoose")
  self.mUIObjs.menpaiChooseView = menpaiChooseView
  self.mUIObjs.petChooseView = petChooseView
  self.mUIObjs.menpaiChooseList = menpaiChooseList
  self.mUIObjs.petChooseList = petChooseList
  local skillList = self.m_panel:FindDirect("Group_List/Scroll View/List")
  self.mUIObjs.skillList = skillList
  local detailView = self.m_panel:FindDirect("Group_Detail")
  local detailBasicView = detailView:FindDirect("Group_Skill")
  local detailAttributeView = detailView:FindDirect("Group_Attribute")
  local detailChannelView = detailView:FindDirect("Grou_Chanel")
  local detaiMoreSkillView = detailView:FindDirect("Grou_MoreSkill")
  self.mUIObjs.detailView = detailView
  self.mUIObjs.detailBasicView = detailBasicView
  self.mUIObjs.detailAttributeView = detailAttributeView
  self.mUIObjs.detailChannelView = detailChannelView
  self.mUIObjs.detaiMoreSkillView = detaiMoreSkillView
  self:SetDownUpSprite(false)
  self:UpdateTapToggle()
end
def.method().UpdateTapToggle = function(self)
  local TapList = self.m_panel:FindDirect("Group_Tab/Group_TabBtn/List")
  if TapList and not TapList.isnil then
    local tapName = string.format("Tab_%d", self.mCurSkillNode)
    local curTap = TapList:FindDirect(tapName)
    if curTap and not curTap.isnil then
      local uiToggle = curTap:GetComponent("UIToggle")
      if uiToggle then
        uiToggle.value = true
      end
    end
  end
end
def.method().UpdateData = function(self)
  if self.mCurSkillNode == NodeId.MenPai or self.mCurSkillNode == NodeId.Pet or self.mCurSkillNode == NodeId.FaBao then
    self.mSelectIds = BaodianUtils.GetAllSelectIdByType(self.mCurSkillNode)
    self.mSelectNames = BaodianUtils.GetGetSkillSelectNamesByTypeEx(self.mCurSkillNode, self.mSelectIds)
    self.mCurSkillIds, self.mCurSkillNames = BaodianUtils.GetSkillIdsAndNamesBySelectId(self.mCurSkillNode, self.mCurSkillSelectId)
    self.mCurSkillId = self.mCurSkillIds[1]
  elseif self.mCurSkillNode == NodeId.Wings then
    self.mSelectIds = {}
    local curPhase = require("Main.Wing.WingInterface").GetCurWingPhase()
    self.mCurSkillIds = require("Main.Wing.WingUtils").GetWingSkillLib(curPhase)
  elseif self.mCurSkillNode == NodeId.Equip then
    self.mSelectIds = {}
    self.mCurSkillIds = BaodianUtils.GetAllEquipSkillCfg()
    self.mCurSkillId = self.mCurSkillIds[1]
  elseif self.mCurSkillNode == NodeId.Fashion then
    self.mSelectIds = {}
    self.mCurSkillIds = FashionUtils.GetAllFashionSkills()
    self.mCurSkillId = self.mCurSkillIds[1]
  end
end
def.method("number").SetCurSkillNode = function(self, nodeId)
  self.mCurSkillNode = nodeId
end
def.method("number").SetCurSelectId = function(self, selectId)
  self.mCurSkillSelectId = selectId
end
def.method().UpdateChooseView = function(self)
  if self.mCurSkillNode == NodeId.MenPai then
    self.mUIObjs.menpaiChooseView:SetActive(true)
    self.mUIObjs.petChooseView:SetActive(false)
  elseif self.mCurSkillNode == NodeId.Pet or self.mCurSkillNode == NodeId.FaBao then
    self.mUIObjs.menpaiChooseView:SetActive(false)
    self.mUIObjs.petChooseView:SetActive(true)
  else
    self.mUIObjs.menpaiChooseView:SetActive(false)
    self.mUIObjs.petChooseView:SetActive(false)
  end
end
def.method().UpdateChooseListView = function(self)
  local selectNum = #self.mSelectIds + 1
  local selectItems
  if self.mCurSkillNode == NodeId.MenPai then
    selectItems = GUIUtils.InitUIList(self.mUIObjs.menpaiChooseList, selectNum)
  elseif self.mCurSkillNode == NodeId.Pet or self.mCurSkillNode == NodeId.FaBao then
    selectItems = GUIUtils.InitUIList(self.mUIObjs.petChooseList, selectNum)
  end
  for i = 1, selectNum do
    local item = selectItems[i]
    local label = item:FindDirect(string.format("Label_%d", i)):GetComponent("UILabel")
    if i == 1 then
      local selectName = self:GetSelectNameById(0)
      label.text = selectName
      item.name = string.format("selectId_%d", 0)
    else
      local selectName = self:GetSelectNameById(self.mSelectIds[i - 1])
      label.text = selectName
      item.name = string.format("selectId_%d", self.mSelectIds[i - 1])
    end
    self.m_msgHandler:Touch(item)
  end
  if self.mCurSkillNode == NodeId.MenPai then
    GUIUtils.Reposition(self.mUIObjs.menpaiChooseList, "UIList", 0)
  elseif self.mCurSkillNode == NodeId.Pet or self.mCurSkillNode == NodeId.FaBao then
    GUIUtils.Reposition(self.mUIObjs.petChooseList, "UIList", 0)
  end
end
def.method().UpdateSkillListView = function(self)
  if self.mCurSkillNode == NodeId.MenPai or self.mCurSkillNode == NodeId.Pet or self.mCurSkillNode == NodeId.FaBao then
    self.mUIObjs.groupWing:SetActive(false)
    self.mUIObjs.groupEquip:SetActive(false)
    self.mUIObjs.groupTitle:SetActive(true)
    self.mUIObjs.groupList:SetActive(true)
    self.mUIObjs.groupDetail:SetActive(true)
    self:SetChooseBtn()
    self:SetDownUpSprite(false)
    local skillNum = #self.mCurSkillIds
    local skillItems = GUIUtils.InitUIList(self.mUIObjs.skillList, skillNum)
    for i = 1, skillNum do
      local item = skillItems[i]
      local nameLabel = item:FindDirect(string.format("Label_Name_%d", i))
      local uiTexture = item:FindDirect(string.format("Img_BgIcon_%d", i)):FindDirect(string.format("Texture_Icon_%d", i))
      local skillId = self.mCurSkillIds[i]
      local skillInfo
      if self.mCurSkillNode ~= NodeId.MenPai then
        skillInfo = SkillUtils.GetSkillCfg(skillId)
        local schoolLabel = item:FindDirect(string.format("Label_School_%d", i))
        schoolLabel:SetActive(false)
      else
        skillInfo = SkillUtils.GetSkillBagCfg(skillId)
        local schoolLabel = item:FindDirect(string.format("Label_School_%d", i))
        schoolLabel:SetActive(true)
        local menpaiName = BaodianUtils.GetMeiPaiName(self.mCurSkillNode, self.mCurSkillSelectId, skillId)
        schoolLabel:GetComponent("UILabel").text = menpaiName
      end
      if skillInfo == nil then
        return
      end
      local skillName = skillInfo.name
      local skillIcon = skillInfo.iconId
      nameLabel:GetComponent("UILabel").text = skillName
      GUIUtils.FillIcon(uiTexture:GetComponent("UITexture"), skillIcon)
      item.name = string.format("skillId_%d", skillId)
      if i == 1 then
        item:GetComponent("UIToggle").value = true
      end
    end
    self.m_msgHandler:Touch(self.mUIObjs.skillList)
    GUIUtils.Reposition(self.mUIObjs.skillList, "UIList", 0)
    self.mUIObjs.skillList:GetComponent("UIList"):DragToMakeVisible(0, 100)
  elseif self.mCurSkillNode == NodeId.Wings then
    self:UpdateWingSkillView(1)
  elseif self.mCurSkillNode == NodeId.Fashion then
    self:UpdateFashionSkillView()
  elseif self.mCurSkillNode == NodeId.Equip then
    self:UpdateEquipSkillView()
  end
end
def.method().UpdateRightDetailView = function(self)
  local titleLabel = self.mUIObjs.detailBasicView:FindDirect("Label_Title")
  local schoolLabel = self.mUIObjs.detailBasicView:FindDirect("Label_School")
  local nameLabel = self.mUIObjs.detailBasicView:FindDirect("Label_Name")
  local attribute = self.mUIObjs.detailAttributeView:FindDirect("Label_AttributeNum2")
  local curSkillInfo
  if self.mCurSkillNode == NodeId.MenPai then
    titleLabel:SetActive(true)
    schoolLabel:SetActive(true)
    self.mUIObjs.detaiMoreSkillView:SetActive(true)
    self.mUIObjs.detailChannelView:SetActive(false)
    curSkillInfo = SkillUtils.GetSkillBagCfg(self.mCurSkillId)
    local menpaiName = BaodianUtils.GetMeiPaiName(self.mCurSkillNode, self.mCurSkillSelectId, self.mCurSkillId)
    schoolLabel:GetComponent("UILabel").text = menpaiName
  elseif self.mCurSkillNode == NodeId.Pet or self.mCurSkillNode == NodeId.FaBao then
    titleLabel:SetActive(false)
    schoolLabel:SetActive(false)
    self.mUIObjs.detaiMoreSkillView:SetActive(false)
    self.mUIObjs.detailChannelView:SetActive(true)
    curSkillInfo = SkillUtils.GetSkillCfg(self.mCurSkillId)
  elseif self.mCurSkillNode == NodeId.Wings then
    titleLabel:SetActive(false)
    schoolLabel:SetActive(false)
    self.mUIObjs.detaiMoreSkillView:SetActive(false)
    self.mUIObjs.detailChannelView:SetActive(false)
    curSkillInfo = SkillUtils.GetSkillCfg(self.mCurSkillId)
  elseif self.mCurSkillNode == NodeId.Equip then
    titleLabel:SetActive(false)
    schoolLabel:SetActive(false)
    self.mUIObjs.detaiMoreSkillView:SetActive(false)
    self.mUIObjs.detailChannelView:SetActive(false)
    curSkillInfo = SkillUtils.GetSkillCfg(self.mCurSkillId)
  end
  self:UpdateOtherDetaiView()
  if curSkillInfo == nil then
    return
  end
  local skillName = curSkillInfo.name
  local skillIcon = curSkillInfo.iconId
  local skillDescription = curSkillInfo.description
  nameLabel:GetComponent("UILabel").text = skillName
  attribute:GetComponent("UILabel").text = skillDescription
  local uiTexture = self.mUIObjs.detailBasicView:FindDirect("Img_BgIcon/Texture_Icon"):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, skillIcon)
end
def.method().UpdateOtherDetaiView = function(self)
  if self.mCurSkillNode == NodeId.MenPai then
    local subid1 = 0
    local subid2 = 0
    local subid3 = 0
    local skillInfo = SkillUtils.GetSkillBagCfg(self.mCurSkillId)
    local skillList = skillInfo.skillList
    if skillList ~= nil then
      subid1 = skillList[1].id
      subid2 = skillList[2].id
      if #skillList > 2 then
        subid3 = skillList[3].id
      end
    end
    local skillInfo1 = SkillUtils.GetSkillCfg(subid1)
    local skillInfo2 = SkillUtils.GetSkillCfg(subid2)
    local skillInfo3
    local name1 = skillInfo1.name
    local icon1 = skillInfo1.iconId
    local name2 = skillInfo2.name
    local icon2 = skillInfo2.iconId
    self.mUIObjs.detaiMoreSkillView:FindDirect("Group_Skill1"):SetActive(true)
    self.mUIObjs.detaiMoreSkillView:FindDirect("Group_Skill2"):SetActive(true)
    self.mUIObjs.detaiMoreSkillView:FindDirect("Group_Skill3"):SetActive(false)
    local SubSkillLabel1 = self.mUIObjs.detaiMoreSkillView:FindDirect("Group_Skill1/Label_Name")
    local subTexture1 = self.mUIObjs.detaiMoreSkillView:FindDirect("Group_Skill1/Img_BgIcon1/Texture_Icon")
    local SubSkillLabel2 = self.mUIObjs.detaiMoreSkillView:FindDirect("Group_Skill2/Label_Name")
    local subTexture2 = self.mUIObjs.detaiMoreSkillView:FindDirect("Group_Skill2/Img_BgIcon2/Texture_Icon")
    SubSkillLabel1:GetComponent("UILabel").text = name1
    SubSkillLabel2:GetComponent("UILabel").text = name2
    GUIUtils.FillIcon(subTexture1:GetComponent("UITexture"), icon1)
    GUIUtils.FillIcon(subTexture2:GetComponent("UITexture"), icon2)
    if #skillList > 2 and subid3 ~= 0 then
      skillInfo3 = SkillUtils.GetSkillCfg(subid3)
      if skillInfo3 ~= nil then
        self.mUIObjs.detaiMoreSkillView:FindDirect("Group_Skill3"):SetActive(true)
        local SubSkillLabel3 = self.mUIObjs.detaiMoreSkillView:FindDirect("Group_Skill3/Label_Name")
        local subTexture3 = self.mUIObjs.detaiMoreSkillView:FindDirect("Group_Skill3/Img_BgIcon3/Texture_Icon")
        local name3 = skillInfo3.name
        local icon3 = skillInfo3.iconId
        SubSkillLabel3:GetComponent("UILabel").text = name3
        GUIUtils.FillIcon(subTexture3:GetComponent("UITexture"), icon3)
      end
    end
  elseif self.mCurSkillNode == NodeId.Pet then
    self.mUIObjs.detailChannelView:SetActive(true)
    self.mUIObjs.detailChannelView:FindDirect("Btn_Chanel1"):SetActive(true)
    self.mUIObjs.detailChannelView:FindDirect("Btn_Chanel1/Label"):GetComponent("UILabel").text = textRes.Grow[8]
    self.mUIObjs.detailChannelView:FindDirect("Label_Get"):SetActive(false)
  elseif self.mCurSkillNode == NodeId.FaBao then
    self.mUIObjs.detailChannelView:SetActive(true)
    self.mUIObjs.detailChannelView:FindDirect("Btn_Chanel1"):SetActive(false)
    self.mUIObjs.detailChannelView:FindDirect("Label_Get"):SetActive(true)
    self.mUIObjs.detailChannelView:FindDirect("Label_Get"):GetComponent("UILabel").text = textRes.Grow[9]
  elseif self.mCurSkillNode == NodeId.Wings then
    self.mUIObjs.detailChannelView:SetActive(false)
    self.mUIObjs.detaiMoreSkillView:SetActive(false)
  elseif self.mCurSkillNode == NodeId.Equip then
    self.mUIObjs.detailChannelView:SetActive(false)
    self.mUIObjs.detaiMoreSkillView:SetActive(false)
  end
end
def.method("number").UpdateWingSkillView = function(self, selectIndex)
  self.mUIObjs.groupEquip:SetActive(false)
  self.mUIObjs.ChooseBtn:SetActive(false)
  self.m_panel:FindDirect("Group_Title/Group_Choose/Label_Skill"):SetActive(false)
  self.mUIObjs.groupWing:SetActive(true)
  self.mUIObjs.groupTitle:SetActive(false)
  self.mUIObjs.groupList:SetActive(false)
  self.mUIObjs.groupDetail:SetActive(false)
  local ui = self.mUIObjs.groupWing:FindDirect("Group_Left")
  local data = self.mCurSkillIds
  local list = ui:FindDirect("Scroll View/List_Zhu")
  local scroll = ui:FindDirect("Scroll View")
  local listCmp = list:GetComponent("UIList")
  local num = #data
  listCmp:set_itemCount(num)
  listCmp:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not listCmp.isnil and not scroll.isnil then
      listCmp:Reposition()
      scroll:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local info = data[i]
    local lbl = uiGo:FindDirect("Label_" .. i)
    lbl:GetComponent("UILabel"):set_text(info.name)
    if selectIndex == i then
      uiGo:GetComponent("UIToggle").value = true
    end
    self.m_msgHandler:Touch(uiGo)
  end
  self:UpdateWingKillRightView(selectIndex)
end
def.method().UpdateFashionSkillView = function(self)
  self.mUIObjs.groupEquip:SetActive(true)
  self.mUIObjs.ChooseBtn:SetActive(false)
  self.m_panel:FindDirect("Group_Title/Group_Choose/Label_Skill"):SetActive(false)
  self.mUIObjs.groupWing:SetActive(false)
  self.mUIObjs.groupTitle:SetActive(false)
  self.mUIObjs.groupList:SetActive(false)
  self.mUIObjs.groupDetail:SetActive(false)
  local fashionList = self.mUIObjs.groupEquip:FindDirect("Scroll View/List")
  local equipSkillList = self.mCurSkillIds
  local skillNum = #equipSkillList
  local listItems = GUIUtils.InitUIList(fashionList, skillNum, false)
  for i = 1, skillNum do
    local Item = listItems[i]
    Item.name = string.format("equipSkill_%d", i)
    if 1 == i then
      local uiToggle = Item:GetComponent("UIToggle")
      if uiToggle then
        uiToggle.value = true
      end
    end
    local skillId = self.mCurSkillIds[i]
    local skillInfo = SkillUtils.GetSkillCfg(skillId)
    if skillInfo then
      local name = skillInfo.name
      local nameLabel = Item:FindDirect(string.format("Label_School_%d", i))
      if nameLabel then
        nameLabel:GetComponent("UILabel"):set_text(name)
      end
    end
  end
  GUIUtils.Reposition(fashionList, "UIList", 0)
  fashionList:GetComponent("UIList"):DragToMakeVisible(0, 100)
  self.m_msgHandler:Touch(fashionList)
  self:UpdateRightFashionSkillView()
end
def.method().UpdateRightFashionSkillView = function(self)
  local nameLabel = self.mUIObjs.groupEquip:FindDirect("Group_ShowDetail/Label_ShowName")
  local descLabel = self.mUIObjs.groupEquip:FindDirect("Group_ShowDetail/Label_ShowDetail")
  local curSkillId = self.mCurSkillId
  local skillInfo = SkillUtils.GetSkillCfg(curSkillId)
  if skillInfo then
    local skillName = skillInfo.name
    local skillDesc = skillInfo.description
    nameLabel:GetComponent("UILabel"):set_text(skillName)
    descLabel:GetComponent("UILabel"):set_text(skillDesc)
  end
end
def.method("number").UpdateWingKillRightView = function(self, selectIndex)
  local data = self.mCurSkillIds[selectIndex]
  local ui = self.mUIObjs.groupWing:FindDirect("Group_Right")
  local list = ui:FindDirect("Group_Skill/Scroll View/List")
  local scroll = ui:FindDirect("Group_Skill/Scroll View")
  local listCmp = list:GetComponent("UIList")
  local num = #data.skills
  listCmp:set_itemCount(num)
  listCmp:Resize()
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if not listCmp.isnil and not scroll.isnil then
      listCmp:Reposition()
      scroll:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local info = data[i]
    local typeName = data.skills[i].name
    self:FillOneSkill(uiGo, typeName, data.skills[i])
    self.m_msgHandler:Touch(uiGo)
  end
end
def.method("userdata", "string", "table").FillOneSkill = function(self, ui, name, skills)
  local nameLbl = ui:FindDirect("Label_Title")
  nameLbl:GetComponent("UILabel"):set_text(name)
  local list = ui:FindDirect("List")
  local listCmp = list:GetComponent("UIList")
  local num = #skills
  listCmp:set_itemCount(num)
  listCmp:Resize()
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if listCmp.isnil then
      listCmp:Reposition()
    end
  end)
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local skillId = skills[i]
    self:FillSkillIcon(uiGo, skillId)
  end
end
def.method("userdata", "number").FillSkillIcon = function(self, uiGo, skillId)
  local tex = uiGo:FindChildByPrefix("WingSkillIcon")
  local skillCfg = skillId > 0 and SkillUtils.GetSkillCfg(skillId) or nil
  if skillCfg then
    tex:SetActive(true)
    local texCmp = tex:GetComponent("UITexture")
    GUIUtils.FillIcon(texCmp, skillCfg.iconId)
    tex.name = "WingSkillIcon_" .. skillId
  else
    tex:SetActive(false)
  end
end
def.method().UpdateEquipSkillView = function(self)
  self.mUIObjs.groupEquip:SetActive(true)
  self.mUIObjs.ChooseBtn:SetActive(false)
  self.m_panel:FindDirect("Group_Title/Group_Choose/Label_Skill"):SetActive(false)
  self.mUIObjs.groupWing:SetActive(false)
  self.mUIObjs.groupTitle:SetActive(false)
  self.mUIObjs.groupList:SetActive(false)
  self.mUIObjs.groupDetail:SetActive(false)
  local equipList = self.mUIObjs.groupEquip:FindDirect("Scroll View/List")
  local equipSkillList = self.mCurSkillIds
  local skillNum = #equipSkillList
  local listItems = GUIUtils.InitUIList(equipList, skillNum, false)
  for i = 1, skillNum do
    local Item = listItems[i]
    Item.name = string.format("equipSkill_%d", i)
    if 1 == i then
      local uiToggle = Item:GetComponent("UIToggle")
      if uiToggle then
        uiToggle.value = true
      end
    end
    local skillId = self.mCurSkillIds[i]
    local skillInfo = SkillUtils.GetSkillCfg(skillId)
    if skillInfo then
      local name = skillInfo.name
      local nameLabel = Item:FindDirect(string.format("Label_School_%d", i))
      if nameLabel then
        nameLabel:GetComponent("UILabel"):set_text(name)
      end
    end
  end
  GUIUtils.Reposition(equipList, "UIList", 0)
  equipList:GetComponent("UIList"):DragToMakeVisible(0, 100)
  self.m_msgHandler:Touch(equipList)
  self:UpdateRightEquipSkillView()
end
def.method().UpdateRightEquipSkillView = function(self)
  local nameLabel = self.mUIObjs.groupEquip:FindDirect("Group_ShowDetail/Label_ShowName")
  local descLabel = self.mUIObjs.groupEquip:FindDirect("Group_ShowDetail/Label_ShowDetail")
  local curSkillId = self.mCurSkillId
  local skillInfo = SkillUtils.GetSkillCfg(curSkillId)
  if skillInfo then
    local skillName = skillInfo.name
    local skillDesc = skillInfo.description
    nameLabel:GetComponent("UILabel"):set_text(skillName)
    descLabel:GetComponent("UILabel"):set_text(skillDesc)
  end
end
def.method("number", "=>", "table").GetSubSkillList = function(self, mainSkill)
  if self.mWingSubSkillIds == nil or self.mCurSkillIds == nil then
    return nil
  end
  for k, v in pairs(self.mCurSkillIds) do
    if v == mainSkill then
      return self.mWingSubSkillIds[k]
    end
  end
  return nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_SkillChoose" then
    if self.mIsDownSelect then
      self:SetChooseBtn()
      self:SetDownUpSprite(false)
    else
      self:SetDownUpSprite(true)
      self:UpdateChooseView()
      self:UpdateChooseListView()
    end
  elseif string.find(id, "Tab_") then
    local strs = string.split(id, "_")
    local newNode = tonumber(strs[2])
    if newNode == self.mCurSkillNode then
      return
    end
    self.mUIObjs.ChooseBtn:SetActive(true)
    self.m_panel:FindDirect("Group_Title/Group_Choose/Label_Skill"):SetActive(true)
    if newNode == NodeId.Wings then
      self:Switch2SkillNode(newNode)
      self:UpdateWingSkillView(1)
    elseif newNode == NodeId.Equip then
      self:Switch2SkillNode(newNode)
      self:UpdateEquipSkillView()
    elseif newNode == NodeId.MenPai or newNode == NodeId.Pet or newNode == NodeId.FaBao then
      self:Switch2SkillNode(newNode)
      self:UpdateSkillListView()
      self:UpdateRightDetailView()
    elseif newNode == NodeId.Fashion then
      self:Switch2SkillNode(newNode)
      self:UpdateFashionSkillView()
    end
  elseif string.find(id, "selectId_") then
    self:SetDownUpSprite(false)
    local strs = string.split(id, "_")
    local selectId = tonumber(strs[2])
    self:SetCurSelectId(selectId)
    self:UpdateData()
    self:SetChooseBtn()
    self:UpdateSkillListView()
    self:UpdateRightDetailView()
  elseif string.find(id, "skillId_") then
    local strs = string.split(id, "_")
    local skillId = tonumber(strs[2])
    self.mCurSkillId = skillId
    self:UpdateRightDetailView()
  elseif id == "Btn_Chanel1" then
    local heroLevel = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
    local openLevel = require("Main.CommerceAndPitch.CommercePitchUtils").GetCommerceOpenLevel()
    if heroLevel < openLevel then
      Toast(string.format(textRes.Commerce[17], openLevel))
      return
    end
    local PetMgr = require("Main.Pet.mgr.PetMgr")
    local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
    local sourceItemId = PetMgr.SKILL_BOOK_SOURCE_ITEM_ID
    local skillBookId = BaodianUtils.GetSkillBookItem(self.mCurSkillId)
    if 0 == skillBookId then
      Toast(textRes.Commerce[24])
      return
    end
    local CommerceData = require("Main.CommerceAndPitch.data.CommerceData")
    local CommercePitchModule = require("Main.CommerceAndPitch.CommercePitchModule")
    local bigIndex, smallIndex = CommerceData.Instance():GetGroupInfoByItemId(skillBookId)
    if 0 == bigIndex or 0 == smallIndex then
      Toast(textRes.Commerce[24])
      return
    end
    CommercePitchModule.Instance():ComemrceBuyItemByBigSmallIndex(bigIndex, smallIndex, skillBookId)
  elseif string.find(id, "Img_BgIcon") then
    local strs = string.split(id, "Icon")
    local subId = tonumber(strs[2])
    local skillInfo = SkillUtils.GetSkillBagCfg(self.mCurSkillId)
    local subSkillId = skillInfo.skillList[subId].id
    local skillTipMgr = require("Main.Skill.SkillTipMgr")
    local skillTipInstance = skillTipMgr.Instance()
    skillTipInstance:ShowTipByIdEx(subSkillId, obj, 0)
  elseif string.find(id, "Group_SkillZhu_") then
    local index = tonumber(string.sub(id, 16))
    self:UpdateWingKillRightView(index)
  elseif string.sub(id, 1, 14) == "WingSkillIcon_" then
    local skillId = tonumber(string.sub(id, 15))
    local findRoot = self.mUIObjs.groupWing:FindDirect("Group_Right/Group_Skill/Scroll View/List")
    local cell = findRoot:FindChild(id)
    if cell and skillId then
      require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdEx(skillId, cell, 0)
    end
  elseif string.find(id, "equipSkill_") then
    local strs = string.split(id, "_")
    local index = tonumber(strs[2])
    local skillId = self.mCurSkillIds[index]
    self.mCurSkillId = skillId
    self:UpdateRightEquipSkillView()
  end
end
def.method("number").Switch2SkillNode = function(self, newNode)
  self:SetCurSkillNode(newNode)
  if newNode == NodeId.Pet or newNode == NodeId.FaBao then
    local selectIds = BaodianUtils.GetAllSelectIdByType(self.mCurSkillNode)
    self:SetCurSelectId(selectIds[1])
  else
    self:SetCurSelectId(0)
  end
  self:UpdateData()
end
def.method("boolean").SetDownUpSprite = function(self, setUp)
  if setUp then
    self.mIsDownSelect = true
    self.mUIObjs.upSprite:SetActive(true)
    self.mUIObjs.downSprite:SetActive(false)
  else
    self.mIsDownSelect = false
    self.mUIObjs.upSprite:SetActive(false)
    self.mUIObjs.downSprite:SetActive(true)
  end
end
def.method().SetChooseBtn = function(self)
  local selectName = self:GetSelectNameById(self.mCurSkillSelectId)
  self.mUIObjs.selectLabel:GetComponent("UILabel").text = selectName
  self:SetDownUpSprite(false)
  self.mUIObjs.menpaiChooseView:SetActive(false)
  self.mUIObjs.petChooseView:SetActive(false)
end
def.method("number", "=>", "string").GetSelectNameById = function(self, idx)
  local index = 0
  for k, v in pairs(self.mSelectIds) do
    if v == idx then
      index = k
      break
    end
  end
  if index == 0 then
    return textRes.Grow[7]
  end
  return self.mSelectNames[index]
end
def.override().ReleaseUI = function(self)
  if self.mUIObjs then
    for k, v in pairs(self.mUIObjs) do
      k = nil
    end
    self.mUIObjs = nil
  end
end
def.override().OnDestroy = function(self)
  self:ReleaseUI()
  self.mCurSkillNode = 0
  self.mCurSkillSelectId = 0
  self.mIsDownSelect = false
  self.mCurSkillIds = nil
  self.mCurSkillNames = nil
  self.mSelectIds = nil
  self.mSelectNames = nil
  self.mCurSkillId = 0
  self.mParent = nil
end
BaodianSkillPanel.Commit()
return BaodianSkillPanel
