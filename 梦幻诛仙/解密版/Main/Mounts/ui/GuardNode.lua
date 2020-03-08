local Lplus = require("Lplus")
local MountsPanelNodeBase = require("Main.Mounts.ui.MountsPanelNodeBase")
local ECPanelBase = require("GUI.ECPanelBase")
local GuardNode = Lplus.Extend(MountsPanelNodeBase, "GuardNode")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local Vector3 = require("Types.Vector3").Vector3
local PetMgr = require("Main.Pet.mgr.PetMgr")
local MountsUtils = require("Main.Mounts.MountsUtils")
local MountsMgr = require("Main.Mounts.mgr.MountsMgr")
local PetUtility = require("Main.Pet.PetUtility")
local SkillUtility = require("Main.Skill.SkillUtility")
local SkillTipMgr = require("Main.Skill.SkillTipMgr")
local ItemColor = require("consts.mzm.gsp.item.confbean.Color")
local def = GuardNode.define
def.field("table").uiObjs = nil
def.field("number").selectedPetId = -1
def.field("table").petModel = nil
def.field("boolean").isDragModel = false
def.field("number").curOperateIdx = -1
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  MountsPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:InitUI()
  Event.RegisterEventWithContext(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsProtectPet, GuardNode.OnMountsProtectPet, self)
  Event.RegisterEventWithContext(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsUnProtectPet, GuardNode.OnMountsUnProtectPet, self)
  Event.RegisterEventWithContext(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsProtectPetChange, GuardNode.OnMountsProtectPetChange, self)
  Event.RegisterEventWithContext(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsUnlockProtectPos, GuardNode.OnMountsUnlockProtectPos, self)
end
def.override().OnHide = function(self)
  self:Clear()
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsProtectPet, GuardNode.OnMountsProtectPet)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsUnProtectPet, GuardNode.OnMountsUnProtectPet)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsProtectPetChange, GuardNode.OnMountsProtectPetChange)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsUnlockProtectPos, GuardNode.OnMountsUnlockProtectPos)
end
def.method().Clear = function(self)
  self.uiObjs = nil
  self.selectedPetId = -1
  if self.petModel ~= nil then
    for k, v in pairs(self.petModel) do
      v:Destroy()
    end
    self.petModel = nil
  end
  self.isDragModel = false
  self.curOperateIdx = -1
end
def.method().InitUI = function(self)
  if not self.m_node or self.m_node.isnil then
    return
  end
  self.uiObjs = {}
  self.uiObjs.Btn_ChangePet = self.m_node:FindDirect("Btn_ChangePet")
  self.uiObjs.Btn_Cancel = self.m_node:FindDirect("Btn_Cancel")
  self.uiObjs.Group_Select = self.m_node:FindDirect("Group_Select")
  self.uiObjs.Group_Skill = self.m_node:FindDirect("Group_Skill")
  self.uiObjs.Btn_ChoosePet = self.m_node:FindDirect("Btn_ChoosePet")
  self.uiObjs.Label_Pet = self.m_node:FindDirect("Label")
  GUIUtils.SetActive(self.uiObjs.Group_Select, false)
  self.petModel = {}
end
def.override("userdata").ChooseMounts = function(self, mountsId)
  if not self.isShow then
    return
  end
  MountsPanelNodeBase.ChooseMounts(self, mountsId)
  self:SetProtectedPet()
end
def.method().SetProtectedPet = function(self)
  local petList = MountsMgr.Instance():GetBattleMountsGuradPets(self.curMountsId) or {}
  local petItemInNode = constant.CMountsConsts.maxMountsProtectPets
  local hasPet = false
  for i = 1, petItemInNode do
    local posIdx = i - 1
    local petItem = self.m_node:FindDirect("Group_Pet" .. posIdx)
    if MountsMgr.Instance():IsMountsProtectPetPosUnlock(self.curMountsId, posIdx) then
      local petId = petList[i] or Int64.new(-1)
      local showPet = PetMgr.Instance():GetPet(petId)
      self:FillPetInfo(posIdx, petItem, showPet)
      if showPet ~= nil then
        hasPet = true
      end
    else
      self:SetProtectPosLock(posIdx, petItem)
    end
  end
  local mounts = MountsMgr.Instance():GetMountsById(self.curMountsId)
  local passiveSkills = mounts.passive_skill_list
  local skillCount = 3
  for i = 1, skillCount do
    local skillItem = self.uiObjs.Group_Skill:FindDirect("Img_Skill_" .. i)
    if skillItem then
      local skillTag = skillItem:GetComponent("UILabel")
      if skillTag == nil then
        skillTag = skillItem:AddComponent("UILabel")
        skillTag:set_enabled(false)
      end
      local Img_SkillIcon = skillItem:FindDirect("Img_SkillIcon")
      local Label_SkillName = skillItem:FindDirect("Label_SkillName")
      if passiveSkills[i] then
        local skillCfg = SkillUtility.GetSkillCfg(passiveSkills[i].current_passive_skill_cfg_id)
        GUIUtils.FillIcon(Img_SkillIcon:GetComponent("UITexture"), skillCfg.iconId)
        GUIUtils.SetText(Label_SkillName, skillCfg.name)
        skillTag.text = passiveSkills[i].current_passive_skill_cfg_id
        local passiveSkillCfg = MountsUtils.GetMountsPassiveSkillCfgByMountsIdAndSkillId(mounts.mounts_cfg_id, passiveSkills[i].current_passive_skill_cfg_id)
        if passiveSkillCfg ~= nil then
          GUIUtils.SetItemCellSprite(skillItem, MountsUtils.GetMountsSkillColor(passiveSkillCfg.passiveSkillIconColor))
        else
          GUIUtils.SetItemCellSprite(skillItem, ItemColor.WHITE)
        end
      else
        GUIUtils.FillIcon(Img_SkillIcon:GetComponent("UITexture"), 0)
        GUIUtils.SetText(Label_SkillName, textRes.Mounts[105])
        skillTag.text = ""
        GUIUtils.SetItemCellSprite(skillItem, ItemColor.WHITE)
      end
    end
  end
end
def.method("number", "userdata", "table").FillPetInfo = function(self, idx, petItem, pet)
  local modelName = "Model_Pet" .. idx
  local Model_Pet = petItem:FindDirect(modelName)
  local Label = petItem:FindDirect("Label" .. idx)
  local Btn_ChoosePet = petItem:FindDirect("Btn_ChoosePet" .. idx)
  local Label_LockTip = petItem:FindDirect("Label_LockTip" .. idx)
  local Btn_Lock = petItem:FindDirect("Btn_Lock" .. idx)
  local box = petItem:GetComponent("BoxCollider")
  local uiToggle = petItem:GetComponent("UIToggle")
  local Group_Name = petItem:FindDirect("Group_Name")
  GUIUtils.SetActive(Model_Pet, true)
  GUIUtils.SetActive(Label_LockTip, false)
  GUIUtils.SetActive(Btn_Lock, false)
  GUIUtils.SetActive(Label, true)
  if pet == nil then
    GUIUtils.SetActive(Btn_ChoosePet, true)
    GUIUtils.SetText(Label, textRes.Mounts[104])
    GUIUtils.SetActive(Model_Pet, false)
    GUIUtils.SetActive(Group_Name, false)
    uiToggle.value = false
    box:set_enabled(false)
    if self.petModel[modelName] ~= nil then
      self.petModel[modelName]:Destroy()
      self.petModel[modelName] = nil
    end
  else
    GUIUtils.SetActive(Model_Pet, true)
    GUIUtils.SetActive(Btn_ChoosePet, false)
    GUIUtils.SetText(Label, "")
    GUIUtils.SetActive(Group_Name, true)
    uiToggle.value = false
    box:set_enabled(true)
    local Label_Name = Group_Name:FindDirect("Label_Name")
    local Label_Lv = Group_Name:FindDirect("Label_Lv")
    GUIUtils.SetText(Label_Name, pet.name)
    GUIUtils.SetText(Label_Lv, string.format(textRes.Common[3], pet.level))
    local uiModel = Model_Pet:GetComponent("UIModel")
    if self.petModel[modelName] ~= nil then
      self.petModel[modelName]:Destroy()
    end
    self.petModel[modelName] = PetUtility.CreateAndAttachPetUIModel(pet, uiModel, nil)
  end
end
def.method("number", "userdata").SetProtectPosLock = function(self, idx, petItem)
  local modelName = "Model_Pet" .. idx
  local Model_Pet = petItem:FindDirect(modelName)
  local Label = petItem:FindDirect("Label" .. idx)
  local Btn_ChoosePet = petItem:FindDirect("Btn_ChoosePet" .. idx)
  local Label_LockTip = petItem:FindDirect("Label_LockTip" .. idx)
  local Btn_Lock = petItem:FindDirect("Btn_Lock" .. idx)
  local box = petItem:GetComponent("BoxCollider")
  local uiToggle = petItem:GetComponent("UIToggle")
  local Group_Name = petItem:FindDirect("Group_Name")
  if self.petModel[modelName] ~= nil then
    self.petModel[modelName]:Destroy()
    self.petModel[modelName] = nil
  end
  GUIUtils.SetActive(Model_Pet, false)
  GUIUtils.SetActive(Label, false)
  GUIUtils.SetActive(Btn_ChoosePet, false)
  GUIUtils.SetActive(Label_LockTip, true)
  GUIUtils.SetActive(Btn_Lock, true)
  GUIUtils.SetActive(Group_Name, false)
  uiToggle.value = false
  box:set_enabled(false)
  local unlockCfgs = MountsUtils.GetMountsProtectPetsUnlockCfg()
  local unlockCondition = unlockCfgs[idx]
  if unlockCondition == nil then
    GUIUtils.SetText(Label_LockTip, textRes.Mounts[123])
  else
    GUIUtils.SetText(Label_LockTip, string.format(textRes.Mounts[124], unlockCondition.openLevel, unlockCondition.minMountsRank))
  end
end
def.override().NoMounts = function(self)
  if not self.isShow then
    return
  end
  MountsPanelNodeBase.NoMounts(self)
  GUIUtils.SetActive(self.uiObjs.Group_Skill, false)
  GUIUtils.SetActive(self.uiObjs.Btn_ChangePet, false)
  GUIUtils.SetActive(self.uiObjs.Btn_Cancel, false)
end
def.method().OnClickChoosePet = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self.curMountsId == nil then
    Toast(textRes.Mounts[2])
    return
  end
  if self.curOperateIdx < 0 then
    Toast(textRes.Mounts[127])
    return
  end
  if not MountsMgr.Instance():IsMountsBattle(self.curMountsId) then
    Toast(textRes.Mounts[22])
    return
  end
  self:ShowUnGuardPets()
end
def.method().ShowUnGuardPets = function(self)
  local allPetList = PetMgr.Instance():GetSortedPetList()
  local petList = {}
  for i = 1, #allPetList do
    local isProtected = MountsMgr.Instance():IsPetProtected(allPetList[i].id)
    if not isProtected then
      table.insert(petList, allPetList[i])
    end
  end
  if #petList == 0 then
    Toast(textRes.Mounts[103])
    return
  end
  GUIUtils.SetActive(self.uiObjs.Group_Select, true)
  local Img_Bg = self.uiObjs.Group_Select:FindDirect("Img_Bg")
  local ScrollView = Img_Bg:FindDirect("Img_Background/Scroll View")
  local Grid = ScrollView:FindDirect("Grid")
  local template = Grid:FindDirect("Img_Bg01")
  GUIUtils.SetActive(template, false)
  local uiGrid = Grid:GetComponent("UIGrid")
  local itemCount = #petList
  for i = 1, itemCount do
    local itemObj = Grid:FindDirect("PetDeital_" .. i)
    if itemObj == nil then
      itemObj = GameObject.Instantiate(template)
      itemObj:SetActive(true)
      itemObj.name = "PetDeital_" .. i
      uiGrid:AddChild(itemObj.transform)
      itemObj.transform.localScale = Vector3.one
    end
    local petTag = itemObj:GetComponent("UILabel")
    if petTag == nil then
      petTag = itemObj:AddComponent("UILabel")
      petTag:set_enabled(false)
    end
    petTag.text = petList[i].id:tostring()
    local petCfg = petList[i]:GetPetCfgData()
    local Label_Name = itemObj:FindDirect("Label_Name")
    local Label_Lv = itemObj:FindDirect("Label_Lv")
    local Labe_PetType = itemObj:FindDirect("Labe_PetType")
    local Img_Icon = itemObj:FindDirect("Img_BgIcon/Img_Icon")
    GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), petList[i]:GetHeadIconId())
    GUIUtils.SetText(Label_Name, petList[i].name)
    GUIUtils.SetText(Label_Lv, string.format(textRes.Mounts[21], petList[i].level))
    GUIUtils.SetText(Labe_PetType, textRes.Pet.Type[petCfg.type])
  end
  local rmIdx = itemCount + 1
  while true do
    local itemObj = Grid:FindDirect("PetDeital_" .. rmIdx)
    if itemObj == nil then
      break
    end
    GameObject.Destroy(itemObj)
    rmIdx = rmIdx + 1
  end
  GameUtil.AddGlobalTimer(0, true, function()
    GameUtil.AddGlobalTimer(0, true, function()
      if ScrollView.isnil then
        return
      end
      ScrollView:GetComponent("UIScrollView"):ResetPosition()
    end)
  end)
end
def.method().ChoosePet = function(self)
  self.selectedPetId = -1
  local Img_Bg = self.uiObjs.Group_Select:FindDirect("Img_Bg")
  local ScrollView = Img_Bg:FindDirect("Img_Background/Scroll View")
  local Grid = ScrollView:FindDirect("Grid")
  local idx = 1
  while true do
    local petItem = Grid:FindDirect("PetDeital_" .. idx)
    if petItem == nil then
      break
    end
    if petItem:GetComponent("UIToggle").value then
      local petTag = petItem:GetComponent("UILabel")
      if petTag ~= nil then
        local petId = tonumber(petTag.text)
        if petId ~= nil then
          self.selectedPetId = petId
        end
      end
      break
    end
    idx = idx + 1
  end
end
def.method().GuardPet = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self.selectedPetId == -1 then
    return
  end
  if self.curOperateIdx < 0 then
    return
  end
  if self.curMountsId ~= nil then
    MountsMgr.Instance():MountsProtectPet(self.curMountsId, self.curOperateIdx, Int64.new(self.selectedPetId))
  else
    Toast(textRes.Mounts[19])
  end
end
def.method().UnGuardPet = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self.curOperateIdx < 0 then
    Toast(textRes.Mounts[127])
    return
  end
  if self.curMountsId ~= nil then
    if not MountsMgr.Instance():MountsHasProtectedPet(self.curMountsId) then
      Toast(textRes.Mounts[27])
    else
      local petList = MountsMgr.Instance():GetBattleMountsGuradPets(self.curMountsId)
      local petId = petList[self.curOperateIdx + 1]
      if petId == nil or Int64.lt(petId, 0) then
        self.curOperateIdx = -1
        Toast(textRes.Mounts[127])
        return
      end
      MountsMgr.Instance():MountsUnProtectPet(self.curMountsId, self.curOperateIdx, petId)
    end
  else
    Toast(textRes.Mounts[19])
  end
end
def.method("number", "userdata").ShowSkillTips = function(self, skillId, source)
  SkillTipMgr.Instance():ShowTipByIdEx(skillId, source, 0)
end
def.method("number").OnClickUnlockBtn = function(self, idx)
  local mounts = MountsMgr.Instance():GetMountsById(self.curMountsId)
  if mounts == nil then
    return
  end
  local unlockCfgs = MountsUtils.GetMountsProtectPetsUnlockCfg()
  local unlockCondition = unlockCfgs[idx]
  if unlockCondition == nil then
    self:ShowProtectUnlockTips(idx)
  else
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    local heroLevel = heroProp.level
    local mountsRank = mounts.mounts_rank
    if heroLevel < unlockCondition.openLevel or mountsRank < unlockCondition.minMountsRank then
      self:ShowProtectUnlockTips(idx)
    else
      self:UnlockProtectPos(idx, unlockCondition)
    end
  end
end
def.method("number", "table").UnlockProtectPos = function(self, idx, condition)
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PROTECT_PET_EXPAND_SIZE) then
    Toast(textRes.Mounts[131])
    return
  end
  if not MountsMgr.Instance():IsMountsProtectPetPosUnlock(self.curMountsId, idx - 1) then
    Toast(textRes.Mounts[130])
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local ItemUtils = require("Main.Item.ItemUtils")
  local title = textRes.Mounts[128]
  local itemBase = ItemUtils.GetItemBase(condition.costItemId)
  local name = itemBase.name
  local iconId = itemBase.icon
  local hasNum = 0
  local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, condition.costItemType)
  for k, v in pairs(items) do
    hasNum = hasNum + v.number
  end
  local numStr = ""
  local hasEnoughItem = false
  if hasNum >= condition.costItemNum then
    numStr = string.format("%d/%d", hasNum, condition.costItemNum)
    hasEnoughItem = true
  else
    numStr = string.format("[ff0000]%d[-]/%d", hasNum, condition.costItemNum)
    hasEnoughItem = false
  end
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local desc = string.format(textRes.Item[33], condition.costItemNum, HtmlHelper.NameColor[itemBase.namecolor], name, string.format(textRes.Mounts[129], idx + 1))
  local ItemConsumeDlg = require("Main.Item.ui.ItemConsumeDlg")
  ItemConsumeDlg.ShowItemConsume(condition.costItemId, title, name, numStr, desc, iconId, 0, function(select)
    if select < 0 then
    elseif select == 0 then
      if hasEnoughItem then
        MountsMgr.Instance():ExpandProtectPetSize(self.curMountsId, false, 0)
      else
        Toast(string.format(textRes.Mounts[133], name))
      end
    end
  end)
end
def.method("number").ShowProtectUnlockTips = function(self, idx)
  local unlockCfgs = MountsUtils.GetMountsProtectPetsUnlockCfg()
  local unlockCondition = unlockCfgs[idx]
  if unlockCondition == nil then
    Toast(textRes.Mounts[123])
  else
    Toast(string.format(textRes.Mounts[126], unlockCondition.openLevel, unlockCondition.minMountsRank))
  end
end
def.method("number").SetCurOperateIdx = function(self, idx)
  self.curOperateIdx = idx
end
def.method("number").CheckToChooseProtectPos = function(self, idx)
  local petItem = self.m_node:FindDirect("Group_Pet" .. idx)
  local uiToggle = petItem:GetComponent("UIToggle")
  if not MountsMgr.Instance():IsMountsProtectPetPosUnlock(self.curMountsId, idx) then
    uiToggle.value = false
    return
  end
  local petList = MountsMgr.Instance():GetBattleMountsGuradPets(self.curMountsId)
  local petId = petList[idx + 1] or Int64.new(-1)
  local pet = PetMgr.Instance():GetPet(petId)
  if pet == nil then
    uiToggle.value = false
    return
  end
  uiToggle.value = true
  self:SetCurOperateIdx(idx)
end
def.method().OnClickReplacePet = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self.curMountsId == nil then
    Toast(textRes.Mounts[2])
    return
  end
  if self.curOperateIdx < 0 then
    Toast(textRes.Mounts[127])
    return
  end
  if not MountsMgr.Instance():IsMountsBattle(self.curMountsId) then
    Toast(textRes.Mounts[22])
    return
  end
  if not MountsMgr.Instance():MountsHasProtectedPet(self.curMountsId) then
    Toast(textRes.Mounts[27])
    return
  else
    local petList = MountsMgr.Instance():GetBattleMountsGuradPets(self.curMountsId)
    local petId = petList[self.curOperateIdx + 1]
    if petId == nil or Int64.lt(petId, 0) then
      self.curOperateIdx = -1
      Toast(textRes.Mounts[127])
      return
    end
  end
  self:ShowUnGuardPets()
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if not string.find(id, "PetDeital_") then
    GUIUtils.SetActive(self.uiObjs.Group_Select, false)
  end
  self.selectedPetId = -1
  if string.find(id, "Btn_ChoosePet") then
    local idx = tonumber(string.sub(id, #"Btn_ChoosePet" + 1))
    self:SetCurOperateIdx(idx)
    self:OnClickChoosePet()
  elseif id == "Btn_Confirm" then
    self:ChoosePet()
    self:GuardPet()
  elseif id == "Btn_Cancel" then
    self:UnGuardPet()
  elseif id == "Btn_ChangePet" then
    self:OnClickReplacePet()
  elseif string.find(id, "Img_Skill_") then
    local skillTag = clickObj:GetComponent("UILabel")
    if skillTag ~= nil then
      local skillId = tonumber(skillTag.text)
      if skillId ~= nil then
        self:ShowSkillTips(skillId, clickObj)
      end
    end
  elseif string.find(id, "Btn_Lock") then
    local idx = tonumber(string.sub(id, #"Btn_Lock" + 1))
    self:OnClickUnlockBtn(idx)
  elseif string.find(id, "Model_Pet") then
    local idx = tonumber(string.sub(id, #"Model_Pet" + 1))
    self:CheckToChooseProtectPos(idx)
  elseif string.find(id, "Group_Pet") then
    local idx = tonumber(string.sub(id, #"Group_Pet" + 1))
    self:CheckToChooseProtectPos(idx)
  end
end
def.override("string").onDragStart = function(self, id)
  if string.find(id, "Model_Pet") then
    self.isDragModel = true
  end
end
def.override("string").onDragEnd = function(self, id)
  self.isDragModel = false
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDragModel == true and self.petModel[id] then
    self.petModel[id]:SetDir(self.petModel[id].m_ang - dx / 2)
  end
end
def.static("table", "table").OnMountsProtectPet = function(context, params)
  local self = context
  if self ~= nil then
    Toast(textRes.Mounts[26])
    self:SetProtectedPet()
    self:SetCurOperateIdx(-1)
  end
end
def.static("table", "table").OnMountsUnProtectPet = function(context, params)
  local self = context
  if self ~= nil then
    Toast(textRes.Mounts[28])
    self:SetProtectedPet()
    self:SetCurOperateIdx(-1)
  end
end
def.static("table", "table").OnMountsProtectPetChange = function(context, params)
  local self = context
  if self ~= nil then
    Toast(textRes.Mounts[106])
    self:SetProtectedPet()
    self:SetCurOperateIdx(-1)
  end
end
def.static("table", "table").OnMountsUnlockProtectPos = function(context, params)
  local self = context
  if self ~= nil then
    Toast(textRes.Mounts[132])
    self:SetProtectedPet()
    self:SetCurOperateIdx(-1)
  end
end
GuardNode.Commit()
return GuardNode
