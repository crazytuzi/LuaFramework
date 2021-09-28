CPetList_BaseSkill = class(".CPetList_BaseSkill", CcsSubView)
function CPetList_BaseSkill:ctor(petId)
  CPetList_BaseSkill.super.ctor(self, "views/pet_list_skill.json")
  self.m_PetId = nil
  self.m_SkillIcon = {}
  self.skillpos_1 = self:getNode("skillpos_1")
  self.skillpos_2 = self:getNode("skillpos_2")
  self.skillpos_1:setVisible(false)
  self.skillpos_2:setVisible(false)
  self:LoadPet(petId)
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ItemInfo)
end
function CPetList_BaseSkill:LoadPet(petId)
  if self.m_PetId == petId then
    return
  end
  self.m_PetId = petId
  self.m_PetIns = g_LocalPlayer:getObjById(self.m_PetId)
  self:SetBaseSkill()
end
function CPetList_BaseSkill:SetBaseSkill()
  local skillTypeList = self.m_PetIns:getSkillTypeList()
  local skillList = {}
  local ndSkillList = {}
  for _, skillAttr in pairs(skillTypeList) do
    if skillAttr == NDATTR_MOJIE then
      for _, ndItemId in pairs(NEIDAN_MOJIE_ITEMLIST) do
        if self.m_PetIns:GetNeidanObj(ndItemId) ~= nil then
          local ndSkillId = NEIDAN_ITEM_TO_SKILL_TABLE[ndItemId]
          if ndSkillId ~= nil then
            ndSkillList[#ndSkillList + 1] = ndSkillId
          end
        end
      end
    else
      local data_table = data_Pet[self.m_PetIns:getTypeId()]
      if data_table ~= nil and data_table.skills ~= nil then
        skills = data_table.skills
        for i = #skills, 1, -1 do
          local skillId = skills[i]
          if skillId ~= 0 then
            table.insert(skillList, 1, skillId)
          end
        end
      end
    end
  end
  for _, skillIcon in pairs(self.m_SkillIcon) do
    skillIcon:removeFromParentAndCleanup(true)
  end
  self.m_SkillIcon = {}
  local index = 1
  if #skillList > 0 then
    self:SetSkillAtRow(skillList, index)
    index = index + 1
  end
  self:SetSkillAtRow(ndSkillList, index)
end
function CPetList_BaseSkill:SetSkillAtRow(skillList, row)
  local posObj = self["skillpos_" .. tostring(row)]
  local px, py = posObj:getPosition()
  local parent = posObj:getParent()
  local zOrder = posObj:getZOrder()
  for i, skillId in ipairs(skillList) do
    local openFlag = self.m_PetIns:getSkillIsOpen(skillId) or self.m_PetIns:getBDSkillIsOpen(skillId)
    local skillIcon = createClickSkill({
      roleID = self.m_PetId,
      skillID = skillId,
      LongPressTime = 0.2,
      imgFlag = true,
      grayFlag = not openFlag
    })
    parent:addChild(skillIcon, zOrder)
    skillIcon:setPosition(ccp(px, py))
    self.m_SkillIcon[#self.m_SkillIcon + 1] = skillIcon
    local size = skillIcon:getContentSize()
    px = px + size.width + 20
  end
end
function CPetList_BaseSkill:OnNeiDanChanged(ndItemId)
  local ndItemIns = g_LocalPlayer:GetOneItem(ndItemId)
  if ndItemIns then
    local ndTypeId = ndItemIns:getTypeId()
    local ndSkillId = NEIDAN_ITEM_TO_SKILL_TABLE[ndTypeId]
    if ndSkillId ~= nil then
      local skillAttr = data_getSkillAttrStyle(ndSkillId)
      if skillAttr == NDATTR_MOJIE then
        self:SetBaseSkill()
      end
    end
  end
end
function CPetList_BaseSkill:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_PetUpdate then
    local d = arg[1]
    if d.petId == self.m_PetId then
      local proTable = d.pro
      if proTable[PROPERTY_ROLELEVEL] ~= nil then
        self:SetBaseSkill()
      end
    end
  elseif msgSID == MsgID_ItemInfo_TakeEquip then
    local roleId, ndItemId = arg[1], arg[2]
    if roleId == self.m_PetId then
      self:OnNeiDanChanged(ndItemId)
    end
  elseif msgSID == MsgID_ItemInfo_TakeDownEquip then
    local roleId, ndItemId = arg[1], arg[2]
    if roleId == self.m_PetId then
      self:OnNeiDanChanged(ndItemId)
    end
  end
end
function CPetList_BaseSkill:Clear()
  self.m_PetIns = nil
end
