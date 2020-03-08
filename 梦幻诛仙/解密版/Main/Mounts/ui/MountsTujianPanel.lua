local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MountsTujianPanel = Lplus.Extend(ECPanelBase, "MountsTujianPanel")
local GUIUtils = require("GUI.GUIUtils")
local EC = require("Types.Vector3")
local Vector3 = EC.Vector3
local MountsMgr = require("Main.Mounts.mgr.MountsMgr")
local MountsUIModel = require("Main.Mounts.MountsUIModel")
local MountsUtils = require("Main.Mounts.MountsUtils")
local MountsTypeEnum = require("consts.mzm.gsp.mounts.confbean.MountsTypeEnum")
local SkillUtility = require("Main.Skill.SkillUtility")
local SkillTipMgr = require("Main.Skill.SkillTipMgr")
local ItemColor = require("consts.mzm.gsp.item.confbean.Color")
local def = MountsTujianPanel.define
local instance
def.field("table").uiObjs = nil
def.field("number").curSelectMountsId = 0
def.field("table").mountsCfgData = nil
def.field(MountsUIModel).model = nil
def.field("boolean").isDragModel = false
def.field("number").selectedMountsRank = 1
def.field("number").selectedSkillRank = 1
def.field("boolean").initWithRank = true
def.static("=>", MountsTujianPanel).Instance = function()
  if instance == nil then
    instance = MountsTujianPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel ~= nil then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_MOUNTS_TUJINA, 1)
  self:SetModal(true)
end
def.method("number").ShowPanelWithMountsId = function(self, mountsId)
  if self.m_panel ~= nil then
    return
  end
  self.curSelectMountsId = mountsId
  self:CreatePanel(RESPATH.PREFAB_MOUNTS_TUJINA, 1)
  self:SetModal(true)
end
def.method("number", "number", "number").ShowPanelWithsMountsIdAndRank = function(self, mountsId, mountsRank, skillRank)
  if self.m_panel ~= nil then
    return
  end
  self.curSelectMountsId = mountsId
  self.selectedMountsRank = mountsRank
  self.selectedSkillRank = skillRank
  self.initWithRank = true
  self:CreatePanel(RESPATH.PREFAB_MOUNTS_TUJINA, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:SetMountsList()
  self:ChooseMounts(self.curSelectMountsId)
  Event.RegisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsFunctionOpenChange, MountsTujianPanel.OnMountsFunctionOpenChange)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.curSelectMountsId = 0
  self.mountsCfgData = nil
  if self.model ~= nil then
    self.model:Destroy()
    self.model = nil
  end
  self.isDragModel = false
  self.selectedMountsRank = 1
  self.selectedSkillRank = 1
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsFunctionOpenChange, MountsTujianPanel.OnMountsFunctionOpenChange)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.PetList = self.uiObjs.Img_Bg0:FindDirect("PetList")
  self.uiObjs.Img_PetList = self.uiObjs.PetList:FindDirect("Img_PetList")
  self.uiObjs.Scroll_View_PetList = self.uiObjs.Img_PetList:FindDirect("Scroll View_PetList")
  self.uiObjs.Group_ChooseType = self.uiObjs.Img_Bg0:FindDirect("Group_ChooseType")
  GUIUtils.SetActive(self.uiObjs.Group_ChooseType, false)
  self.uiObjs.Label_SkillType = self.uiObjs.Img_Bg0:FindDirect("Label_SkillType")
  self.uiObjs.Label_Peishi = self.uiObjs.Img_Bg0:FindDirect("Label_Peishi")
end
def.method().SetMountsList = function(self)
  self.mountsCfgData = {}
  local allCfgs = MountsUtils.GetAllMountsCfg()
  for k, v in pairs(allCfgs) do
    local MountsModule = require("Main.Mounts.MountsModule")
    if MountsModule.Instance():IsMountsIDIPOpen(v.id) then
      self.mountsCfgData[k] = v
    end
  end
  local sortedMounts = {}
  for k, v in pairs(self.mountsCfgData) do
    table.insert(sortedMounts, v)
  end
  table.sort(sortedMounts, function(a, b)
    return a.displayOrder < b.displayOrder
  end)
  if self.curSelectMountsId == 0 and #sortedMounts > 0 then
    self.curSelectMountsId = sortedMounts[1].id
  end
  local listPetList = self.uiObjs.Scroll_View_PetList:FindDirect("List_PetList")
  local uiList = listPetList:GetComponent("UIList")
  local amount = #sortedMounts
  uiList:set_itemCount(amount)
  uiList:Resize()
  local items = uiList.children
  for index = 1, amount do
    local listItem = items[index]
    local petListItem = listItem:FindDirect("Pet01")
    if petListItem then
      petListItem:set_name("Pet_" .. index)
    else
      petListItem = listItem:FindDirect("Pet_" .. index)
    end
    petListItem:GetComponent("UIToggle"):set_startsActive(false)
    self:SetMountsItemInfo(petListItem, sortedMounts[index])
  end
  uiList:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("userdata", "table").SetMountsItemInfo = function(self, item, mountsCfg)
  GUIUtils.SetActive(item:FindDirect("Group_Add"), false)
  GUIUtils.SetActive(item:FindDirect("Group_Empty"), false)
  GUIUtils.SetActive(item:FindDirect("Img_Red"), false)
  GUIUtils.SetActive(item:FindDirect("Img_BgPetItem"), true)
  local Label_PetName01 = item:FindDirect("Label_PetName01")
  GUIUtils.SetText(Label_PetName01, mountsCfg.mountsName)
  local Img_BgPetItem = item:FindDirect("Img_BgPetItem")
  local Icon_Pet01 = Img_BgPetItem:FindDirect("Icon_Pet01")
  GUIUtils.FillIcon(Icon_Pet01:GetComponent("UITexture"), mountsCfg.mountsIconId)
  item:FindDirect("Img_Many"):SetActive(mountsCfg.maxMountRoleNum > 1)
  local mountsTag = item:GetComponent("UILabel")
  if mountsTag == nil then
    mountsTag = item:AddComponent("UILabel")
    mountsTag:set_enabled(false)
  end
  mountsTag.text = mountsCfg.id
  if self.curSelectMountsId == mountsCfg.id then
    item:GetComponent("UIToggle").value = true
  end
end
def.method("number").ChooseMounts = function(self, mountsId)
  self.curSelectMountsId = mountsId
  if not self.initWithRank then
    self:ChooseDefaultMountsRank()
    self:ChooseDefaultSkillRank()
  else
    self:verifyInitRank()
    self.initWithRank = false
  end
  self:ShowMountsCfgInfo()
end
def.method().ShowMountsCfgInfo = function(self)
  local mountsCfg = self.mountsCfgData[self.curSelectMountsId]
  if mountsCfg == nil then
    Toast(textRes.Mounts[136])
    self:DestroyPanel()
    return
  end
  local availableRank = self:GetAvailableRank()
  if #availableRank <= 1 then
    GUIUtils.SetActive(self.uiObjs.Label_Peishi, false)
    GUIUtils.SetActive(self.uiObjs.Label_SkillType, false)
  else
    GUIUtils.SetActive(self.uiObjs.Label_Peishi, true)
    GUIUtils.SetActive(self.uiObjs.Label_SkillType, true)
    GUIUtils.SetText(self.uiObjs.Label_Peishi, string.format(textRes.Mounts[108], self.selectedMountsRank))
    GUIUtils.SetText(self.uiObjs.Label_SkillType, string.format(textRes.Mounts[109], self.selectedSkillRank))
  end
  local Label_PetName = self.uiObjs.Img_Bg0:FindDirect("Label_PetName")
  local Label_Tips = self.uiObjs.Img_Bg0:FindDirect("Label_Tips")
  local Model_Pet = self.uiObjs.Img_Bg0:FindDirect("Model_Pet")
  local Img_Type = self.uiObjs.Img_Bg0:FindDirect("Img_Type")
  local Label_RidingPersonNum = self.uiObjs.Img_Bg0:FindDirect("Label_RidingPersonNum")
  local Label_RidingSpeed = self.uiObjs.Img_Bg0:FindDirect("Label_RidingSpeed")
  local Label_RidingSpeedNum = self.uiObjs.Img_Bg0:FindDirect("Label_RidingSpeedNum")
  GUIUtils.SetText(Label_PetName, mountsCfg.mountsName)
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(mountsCfg.mountsApproachOfAchieving)
  GUIUtils.SetText(Label_Tips, tipContent)
  GUIUtils.SetSprite(Img_Type, textRes.Mounts.MountsTypeSprite[mountsCfg.mountsType])
  GUIUtils.SetText(Label_RidingPersonNum, mountsCfg.maxMountRoleNum)
  local property
  local mountsRankCfg = MountsUtils.GetMountsCfgOfRank(self.curSelectMountsId, self.selectedMountsRank)
  if mountsRankCfg ~= nil then
    property = mountsRankCfg.property
  end
  if property == nil then
    GUIUtils.SetText(Label_RidingSpeed, "")
    GUIUtils.SetText(Label_RidingSpeedNum, "")
  else
    local propertyName = {}
    local propertyValue = {}
    for k, v in pairs(property) do
      local propertyCfg = _G.GetCommonPropNameCfg(k)
      if propertyCfg ~= nil then
        table.insert(propertyName, string.format("%s  ", propertyCfg.propName))
        table.insert(propertyValue, string.format("+%d", v))
      end
    end
    GUIUtils.SetText(Label_RidingSpeed, table.concat(propertyName, "\n"))
    GUIUtils.SetText(Label_RidingSpeedNum, table.concat(propertyValue, "\n"))
  end
  local uiModel = Model_Pet:GetComponent("UIModel")
  if self.model ~= nil then
    self.model:Destroy()
  end
  self.model = MountsUtils.LoadMountsModel(uiModel, self.curSelectMountsId, self.selectedMountsRank, mountsCfg.defaultDyeColorId, function()
    if self.model ~= nil then
      self.model:SetDir(-135)
    end
  end)
  local JN = self.uiObjs.Img_Bg0:FindDirect("JN")
  local Group_Skill = JN:FindDirect("Group_Skill")
  local Label = Group_Skill:FindDirect("Label")
  GUIUtils.SetText(Label, textRes.Mounts[107])
  local Img_ZhudongSkill = Group_Skill:FindDirect("Img_ZhudongSkill")
  local Img_JN_IconSkill = Img_ZhudongSkill:FindDirect("Img_JN_IconSkill")
  local Label_SkillName = Img_ZhudongSkill:FindDirect("Label_SkillName")
  local zhudongSkillTag = Img_ZhudongSkill:GetComponent("UILabel")
  if zhudongSkillTag == nil then
    zhudongSkillTag = Img_ZhudongSkill:AddComponent("UILabel")
    zhudongSkillTag:set_enabled(false)
  end
  local zhudongSkillDesc = textRes.Mounts[35]
  local skillId = 0
  local mountsActiveSkillRankCfg = MountsUtils.GetMountsActiveSkillRankChange(self.curSelectMountsId)
  if mountsActiveSkillRankCfg ~= nil and mountsActiveSkillRankCfg[self.selectedSkillRank] ~= nil then
    local curSkill = mountsActiveSkillRankCfg[self.selectedSkillRank]
    if curSkill ~= nil then
      if curSkill.skillId == 0 then
        if curSkill.nextSkillRank ~= nil then
          local nextSkill = mountsActiveSkillRankCfg[curSkill.nextSkillRank]
          if nextSkill ~= nil then
            skillId = nextSkill.skillId
          end
        end
      else
        skillId = curSkill.skillId
      end
    end
  end
  local skillCfg = SkillUtility.GetSkillCfg(skillId)
  if skillCfg ~= nil then
    GUIUtils.FillIcon(Img_JN_IconSkill:GetComponent("UITexture"), skillCfg.iconId)
    zhudongSkillDesc = skillCfg.name
    zhudongSkillTag.text = skillId
    GUIUtils.SetItemCellSprite(Img_ZhudongSkill, MountsUtils.GetMountsSkillColor(mountsRankCfg.activeSkillIconColor))
  else
    GUIUtils.FillIcon(Img_JN_IconSkill:GetComponent("UITexture"), 0)
    zhudongSkillTag.text = ""
    GUIUtils.SetItemCellSprite(Img_ZhudongSkill, ItemColor.ALL)
  end
  GUIUtils.SetText(Label_SkillName, zhudongSkillDesc)
  local ScrollView = JN:FindDirect("Scroll View")
  local List_Skill = ScrollView:FindDirect("List_Skill")
  local uiList = List_Skill:GetComponent("UIList")
  local passiveSkills = {}
  local mountsSkillCfg = MountsUtils.GetMountsRankPassiveSkillCfg(self.curSelectMountsId, self.selectedSkillRank)
  if mountsSkillCfg ~= nil then
    for k, v in pairs(mountsSkillCfg) do
      table.insert(passiveSkills, v)
    end
  end
  local amount = #passiveSkills
  uiList:set_itemCount(amount)
  uiList:Resize()
  local items = uiList.children
  for index = 1, amount do
    local listItem = items[index]
    local Img_JN_IconSkill = listItem:FindDirect("Img_JN_IconSkill")
    local Label_SkillName = listItem:FindDirect("Label_SkillName")
    local skillCfg = SkillUtility.GetSkillCfg(passiveSkills[index].passiveSkillCfgId)
    if skillCfg ~= nil then
      GUIUtils.FillIcon(Img_JN_IconSkill:GetComponent("UITexture"), skillCfg.iconId)
      GUIUtils.SetText(Label_SkillName, skillCfg.name)
      local passiveSkillCfg = MountsUtils.GetMountsPassiveSkillCfgByMountsIdAndSkillId(self.curSelectMountsId, passiveSkills[index].passiveSkillCfgId)
      if passiveSkillCfg ~= nil then
        GUIUtils.SetItemCellSprite(listItem, MountsUtils.GetMountsSkillColor(passiveSkillCfg.passiveSkillIconColor))
      else
        GUIUtils.SetItemCellSprite(listItem, ItemColor.ALL)
      end
    else
      GUIUtils.FillIcon(Img_JN_IconSkill:GetComponent("UITexture"), 0)
      GUIUtils.SetText(Label_SkillName, textRes.Mounts[35])
      GUIUtils.SetItemCellSprite(listItem, ItemColor.ALL)
    end
    local passiveSkillTag = listItem:GetComponent("UILabel")
    if passiveSkillTag == nil then
      passiveSkillTag = listItem:AddComponent("UILabel")
      passiveSkillTag:set_enabled(false)
    end
    passiveSkillTag.text = passiveSkills[index].passiveSkillCfgId
  end
  uiList:Reposition()
  GameUtil.AddGlobalTimer(0, true, function()
    if ScrollView.isnil then
      return
    end
    ScrollView:GetComponent("UIScrollView"):ResetPosition()
  end)
end
def.method("=>", "table").GetAvailableRank = function(self)
  return MountsUtils.GetMountsAvailableRank(self.curSelectMountsId)
end
def.method().verifyInitRank = function(self)
  local availableRank = self:GetAvailableRank()
  if #availableRank > 0 then
    local rankMap = {}
    for i = 1, #availableRank do
      rankMap[availableRank[i]] = i
    end
    if rankMap[self.selectedMountsRank] == nil then
      self.selectedMountsRank = availableRank[1]
    end
    if rankMap[self.selectedSkillRank] == nil then
      self.selectedSkillRank = availableRank[1]
    end
  else
    self.selectedMountsRank = 1
    self.selectedSkillRank = 1
  end
end
def.method().ShowMountsRankSelector = function(self)
  GUIUtils.SetActive(self.uiObjs.Group_ChooseType, true)
  local position = self.uiObjs.Label_Peishi.position
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = self.uiObjs.Group_ChooseType:FindDirect("Img_Bg2"):GetComponent("UIWidget")
  self.uiObjs.Group_ChooseType:set_localPosition(Vector3.new(screenPos.x - widget.width * 0.1, screenPos.y - widget.height * 0.4, 0))
  local ScrollView = self.uiObjs.Group_ChooseType:FindDirect("Img_Bg2/Scroll View")
  local List_Item = ScrollView:FindDirect("List_Item")
  local uiList = List_Item:GetComponent("UIList")
  local availableRank = self:GetAvailableRank()
  uiList:set_itemCount(#availableRank)
  uiList:Resize()
  local items = uiList.children
  for i = 1, #items do
    local listItem = items[i]
    listItem.name = "MountsRank_" .. availableRank[i]
    GUIUtils.SetText(listItem:FindDirect("Btn_Item/Label_Name2"), string.format(textRes.Mounts[108], availableRank[i]))
  end
  uiList:Resize()
  uiList:Reposition()
  GameUtil.AddGlobalTimer(0.1, true, function()
    if ScrollView.isnil then
      return
    end
    ScrollView:GetComponent("UIScrollView"):ResetPosition()
  end)
end
def.method().ChooseDefaultMountsRank = function(self)
  for i = 1, constant.CMountsConsts.maxMountsRank do
    local mountsRankCfg = MountsUtils.GetMountsCfgOfRank(self.curSelectMountsId, i)
    if mountsRankCfg ~= nil then
      self:ChooseMountsRank(i)
      break
    end
  end
end
def.method("number").ChooseMountsRank = function(self, rank)
  self.selectedMountsRank = rank
  GUIUtils.SetText(self.uiObjs.Label_Peishi, string.format(textRes.Mounts[108], self.selectedMountsRank))
end
def.method().ShowSkillRankSelector = function(self)
  GUIUtils.SetActive(self.uiObjs.Group_ChooseType, true)
  local position = self.uiObjs.Label_SkillType.position
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = self.uiObjs.Group_ChooseType:FindDirect("Img_Bg2"):GetComponent("UIWidget")
  self.uiObjs.Group_ChooseType:set_localPosition(Vector3.new(screenPos.x - widget.width * 0.1, screenPos.y - widget.height * 0.4, 0))
  local ScrollView = self.uiObjs.Group_ChooseType:FindDirect("Img_Bg2/Scroll View")
  local List_Item = ScrollView:FindDirect("List_Item")
  local uiList = List_Item:GetComponent("UIList")
  local availableRank = self:GetAvailableRank()
  uiList:set_itemCount(#availableRank)
  uiList:Resize()
  local items = uiList.children
  for i = 1, #items do
    local listItem = items[i]
    listItem.name = "SkillRank_" .. availableRank[i]
    GUIUtils.SetText(listItem:FindDirect("Btn_Item/Label_Name2"), string.format(textRes.Mounts[109], availableRank[i]))
  end
  uiList:Resize()
  uiList:Reposition()
  GameUtil.AddGlobalTimer(0.1, true, function()
    if ScrollView.isnil then
      return
    end
    ScrollView:GetComponent("UIScrollView"):ResetPosition()
  end)
end
def.method().ChooseDefaultSkillRank = function(self)
  for i = 1, constant.CMountsConsts.maxMountsRank do
    local mountsRankCfg = MountsUtils.GetMountsCfgOfRank(self.curSelectMountsId, i)
    if mountsRankCfg ~= nil then
      self:ChooseSkillRank(i)
      break
    end
  end
end
def.method("number").ChooseSkillRank = function(self, rank)
  self.selectedSkillRank = rank
  GUIUtils.SetText(self.uiObjs.Label_SkillType, string.format(textRes.Mounts[109], self.selectedSkillRank))
end
def.method("number", "userdata").ShowSkillTips = function(self, skillId, source)
  SkillTipMgr.Instance():ShowTipByIdEx(skillId, source, 0)
end
def.method("userdata").onClickObj = function(self, clickObj)
  GUIUtils.SetActive(self.uiObjs.Group_ChooseType, false)
  local id = clickObj.name
  if id == "Btn_Choose" then
    local parent = clickObj.parent
    if parent ~= nil then
      id = parent.name
      clickObj = parent
    end
  end
  if id == "Btn_Item" then
    local parent = clickObj.parent
    if parent ~= nil then
      id = parent.name
      clickObj = parent
    end
  end
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "Pet_") then
    local mountsTag = clickObj:GetComponent("UILabel")
    if mountsTag ~= nil then
      local mountsId = tonumber(mountsTag.text)
      if mountsId ~= nil then
        self:ChooseMounts(mountsId)
      end
    end
  elseif id == "Img_ZhudongSkill" or string.find(id, "item_") then
    local skillTag = clickObj:GetComponent("UILabel")
    if skillTag ~= nil then
      local skillId = tonumber(skillTag.text)
      if skillId ~= nil then
        self:ShowSkillTips(skillId, clickObj)
      end
    end
  elseif id == "Label_Peishi" then
    self:ShowMountsRankSelector()
  elseif id == "Label_SkillType" then
    self:ShowSkillRankSelector()
  elseif string.find(id, "MountsRank_") then
    local rank = tonumber(string.sub(id, #"MountsRank_" + 1))
    if rank ~= nil then
      self:ChooseMountsRank(rank)
      self:ShowMountsCfgInfo()
    end
  elseif string.find(id, "SkillRank_") then
    local rank = tonumber(string.sub(id, #"SkillRank_" + 1))
    if rank ~= nil then
      self:ChooseSkillRank(rank)
      self:ShowMountsCfgInfo()
    end
  end
end
def.method("string").onDragStart = function(self, id)
  if id == "Model_Pet" then
    self.isDragModel = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self.isDragModel = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.model and self.isDragModel then
    self.model:SetDir(self.model.m_ang - dx / 2)
  end
end
def.method().Close = function(self)
  self:DestroyPanel()
end
def.override("boolean").OnShow = function(self, s)
  if s and self.model then
    self.model:Play("Stand_c")
  end
end
def.static("table", "table").OnMountsFunctionOpenChange = function(params, context)
  local self = instance
  if self ~= nil then
    local MountsModule = require("Main.Mounts.MountsModule")
    if not MountsModule.IsFunctionOpen() then
      self:Close()
    end
  end
end
MountsTujianPanel.Commit()
return MountsTujianPanel
