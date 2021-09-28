selectAutoSkill = class("selectAutoSkill", CcsSubView)
function selectAutoSkill:ctor(waruiObj, heroObj, heroPos, petObj, petPos, initPetPage)
  selectAutoSkill.super.ctor(self, "views/select_autoskill.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_setAttack = {
      listener = handler(self, self.Btn_SetAttack),
      variName = "m_Btn_SetAttack"
    },
    btn_setDefence = {
      listener = handler(self, self.Btn_SetDefence),
      variName = "m_Btn_SetDefence"
    },
    btn_setHero = {
      listener = handler(self, self.Btn_SetHero),
      variName = "m_Btn_SetHero"
    },
    btn_setPet = {
      listener = handler(self, self.Btn_SetPet),
      variName = "m_Btn_SetPet"
    },
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "m_Btn_Close",
      param = {3}
    },
    btn_killwar = {
      listener = handler(self, self.Btn_KillWar),
      variName = "btn_killwar"
    },
    btn_changeAttack = {
      listener = handler(self, self.Btn_SetChangeAttack),
      variName = "btn_changeAttack"
    },
    btn_notChangeAttack = {
      listener = handler(self, self.Btn_SetNotChangeAttack),
      variName = "btn_notChangeAttack"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_WarUIObj = waruiObj
  self.m_HeroObj = heroObj
  self.m_HeroPos = heroPos
  self.m_PetObj = petObj
  self.m_PetPos = petPos
  self.m_HeadImg = nil
  self.m_SettingPos = nil
  self.m_SkillItemObjDict = {}
  self:addBtnSigleSelectGroup({
    {
      self.m_Btn_SetHero,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.m_Btn_SetPet,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    }
  })
  self.m_Btn_SetHero:setTitleText("角\n色")
  self.m_Btn_SetPet:setTitleText("召\n唤\n兽")
  self:setGroupAllNotSelected(self.m_Btn_SetHero)
  if self.m_PetObj == nil then
    initPetPage = false
    self.m_Btn_SetPet:setEnabled(false)
  end
  if initPetPage == false then
    self:Btn_SetHero()
  else
    self:Btn_SetPet()
  end
end
function selectAutoSkill:Btn_Close(obj, t)
  self:CloseSelf()
end
function selectAutoSkill:ClearAllSkillItems()
  for _, obj in pairs(self.m_SkillItemObjDict) do
    obj:removeFromParent()
  end
  self.m_SkillItemObjDict = {}
  if self.m_PetLingwuSkillFrame then
    self.m_PetLingwuSkillFrame:removeFromParent()
  end
  self.m_PetLingwuSkillFrame = nil
end
function selectAutoSkill:ReSetAutoSelectView()
  if self.m_SettingPos == self.m_PetPos then
    self:Btn_SetPet()
  else
    self:Btn_SetHero()
  end
end
function selectAutoSkill:SetHead(typeId)
  if self.m_HeadImg then
    self.m_HeadImg:removeFromParent()
    self.m_HeadImg = nil
  end
  self.m_HeadImg = createWidgetFrameHeadIconByRoleTypeID(typeId, nil, gray)
  self:addChild(self.m_HeadImg)
  local x, y = self:getNode("box_head"):getPosition()
  local bgSize = self:getNode("box_head"):getContentSize()
  self.m_HeadImg:setPosition(ccp(x + bgSize.width / 2, y + bgSize.height / 2))
  self.m_HeadImg:setScale(0.8)
end
function selectAutoSkill:Btn_SetHero(obj, t)
  if self.m_HeroObj == nil then
    return
  end
  self:SetHead(self.m_HeroObj:getTypeId())
  self.m_SettingPos = self.m_HeroPos
  self:setGroupBtnSelected(self.m_Btn_SetHero)
  self:ClearAllSkillItems()
  local race = self.m_HeroObj:getProperty(PROPERTY_RACE)
  local gender = self.m_HeroObj:getProperty(PROPERTY_GENDER)
  local skillTypeList = self.m_HeroObj:getSkillTypeList()
  self:getNode("txt21"):setVisible(true)
  self:getNode("txt22"):setVisible(true)
  self:getNode("txt23"):setVisible(true)
  self:getNode("txt21"):setText(SKILLATTR_NAME_DICT[skillTypeList[1]] .. ":")
  self:getNode("txt22"):setText(SKILLATTR_NAME_DICT[skillTypeList[2]] .. ":")
  self:getNode("txt23"):setText(SKILLATTR_NAME_DICT[skillTypeList[3]] .. ":")
  for row = 1, 3 do
    local skillAttr = skillTypeList[row]
    local skillList = data_getSkillListByAttr(skillAttr)
    for set = 1, 5 do
      local tempSkillId = skillList[set]
      local mpEnoughFlag = g_WarScene:roleSkillMpEnough(self.m_HeroPos, tempSkillId)
      local openFlag = g_WarScene:roleCanOpenSkill(self.m_HeroPos, tempSkillId)
      local yiwangFlag = g_WarScene:roleSkillIsYiWang(self.m_HeroPos, tempSkillId)
      if openFlag and set >= 3 then
        local flagDict = {
          mpEnoughFlag = mpEnoughFlag,
          openFlag = openFlag,
          unKnownFlag = false,
          yiwangFlag = yiwangFlag
        }
        local tempSkillItem = selectSkillItem.new(self.m_HeroObj:getObjId(), tempSkillId, handler(self, self.onSelected), flagDict)
        local x, y = self:getNode(string.format("pos_%d%d", row, set - 2)):getPosition()
        tempSkillItem:setPosition(ccp(x, y))
        self:addSubView({subView = tempSkillItem})
        self.m_SkillItemObjDict[tempSkillId] = tempSkillItem
      end
    end
  end
  self:SetSelected()
end
function selectAutoSkill:Btn_SetPet(obj, t)
  if self.m_PetObj == nil then
    return
  end
  self:SetHead(self.m_PetObj:getTypeId())
  self.m_SettingPos = self.m_PetPos
  self:setGroupBtnSelected(self.m_Btn_SetPet)
  self:ClearAllSkillItems()
  local tianshengSkill = {}
  local neidanSkill = {}
  local lingwuSkill = {}
  local data_table = data_Pet[self.m_PetObj:getTypeId()]
  if data_table ~= nil and data_table.skills[1] ~= nil and data_table.skills[1] ~= 0 then
    for num = 1, 4 do
      local tempSkillId = data_table.skills[num]
      local openFlag = g_WarScene:roleCanOpenSkill(self.m_PetPos, tempSkillId)
      if openFlag then
        tianshengSkill[#tianshengSkill + 1] = tempSkillId
      end
    end
  end
  local index = 1
  for tempSkillId, _ in pairs(data_Neidan) do
    local openFlag = g_WarScene:roleCanOpenSkill(self.m_PetPos, tempSkillId)
    if openFlag then
      neidanSkill[#neidanSkill + 1] = tempSkillId
      index = index + 1
    end
    if index > 3 then
      break
    end
  end
  table.sort(neidanSkill)
  for _, tempSkillId in pairs(ACTIVE_PETSKILLLIST) do
    local openFlag = g_WarScene:roleCanOpenSkill(self.m_PetPos, tempSkillId)
    if openFlag then
      lingwuSkill[#lingwuSkill + 1] = tempSkillId
    end
  end
  table.sort(lingwuSkill)
  local index = 1
  if #tianshengSkill ~= 0 then
    self:getNode(string.format("txt2%d", index)):setText("天生法术:")
    for num, tempSkillId in ipairs(tianshengSkill) do
      local mpEnoughFlag = g_WarScene:roleSkillMpEnough(self.m_PetPos, tempSkillId)
      local openFlag = g_WarScene:roleCanOpenSkill(self.m_PetPos, tempSkillId)
      local yiwangFlag = g_WarScene:roleSkillIsYiWang(self.m_PetPos, tempSkillId)
      local flagDict = {
        mpEnoughFlag = mpEnoughFlag,
        openFlag = openFlag,
        unKnownFlag = false,
        yiwangFlag = yiwangFlag
      }
      local tempSkillItem = selectSkillItem.new(self.m_PetObj:getObjId(), tempSkillId, handler(self, self.onSelected), flagDict)
      local x, y = self:getNode(string.format("pos_%d%d", index, num)):getPosition()
      tempSkillItem:setPosition(ccp(x, y))
      self:addSubView({subView = tempSkillItem})
      self.m_SkillItemObjDict[tempSkillId] = tempSkillItem
    end
    index = index + 1
  end
  if #neidanSkill ~= 0 then
    self:getNode(string.format("txt2%d", index)):setText("魂石技能:")
    for num, tempSkillId in ipairs(neidanSkill) do
      local mpEnoughFlag = g_WarScene:roleSkillMpEnough(self.m_PetPos, tempSkillId)
      local openFlag = g_WarScene:roleCanOpenSkill(self.m_PetPos, tempSkillId)
      local yiwangFlag = g_WarScene:roleSkillIsYiWang(self.m_PetPos, tempSkillId)
      local flagDict = {
        mpEnoughFlag = mpEnoughFlag,
        openFlag = openFlag,
        unKnownFlag = false,
        yiwangFlag = yiwangFlag
      }
      local tempSkillItem = selectSkillItem.new(self.m_PetObj:getObjId(), tempSkillId, handler(self, self.onSelected), flagDict)
      local x, y = self:getNode(string.format("pos_%d%d", index, num)):getPosition()
      tempSkillItem:setPosition(ccp(x, y))
      self:addSubView({subView = tempSkillItem})
      self.m_SkillItemObjDict[tempSkillId] = tempSkillItem
    end
    index = index + 1
  end
  if #lingwuSkill ~= 0 then
    self:getNode(string.format("txt2%d", index)):setText("领悟技能:")
    local frameData = {}
    for num, tempSkillId in ipairs(lingwuSkill) do
      local roleId = self.m_PetObj:getObjId()
      local minRoundFlag = g_WarScene:roleSkillCanUseOfMinRound(self.m_PetPos, tempSkillId)
      local mpEnoughFlag = g_WarScene:roleSkillMpEnough(self.m_PetPos, tempSkillId)
      local openFlag = g_WarScene:roleCanOpenSkill(self.m_PetPos, tempSkillId)
      local cdFlag = g_WarScene:roleSkillCDEnough(self.m_PetPos, tempSkillId)
      local proFlag = g_WarScene:roleSkillProEnough(self.m_PetPos, tempSkillId)
      local hasUseFlag = g_WarScene:roleSkillHasUse(self.m_PetPos, tempSkillId)
      local hpEnoughFlag = g_WarScene:roleSkillHpEnough(self.m_PetPos, tempSkillId)
      local yiwangFlag = g_WarScene:roleSkillIsYiWang(self.m_PetPos, tempSkillId)
      local flagDict = {
        mpEnoughFlag = mpEnoughFlag,
        openFlag = openFlag,
        unKnownFlag = false,
        cdFlag = cdFlag,
        proFlag = proFlag,
        hasUseFlag = hasUseFlag,
        minRoundFlag = minRoundFlag,
        hpEnoughFlag = hpEnoughFlag,
        yiwangFlag = yiwangFlag
      }
      frameData[#frameData + 1] = {
        roleId,
        tempSkillId,
        handler(self, self.onSelected),
        flagDict
      }
    end
    local tempFrame = CPetLWSkillFrame.new(frameData)
    self:addChild(tempFrame)
    local x, _ = self:getNode("pos_31"):getPosition()
    local _, y = self:getNode(string.format("pos_%d1", index)):getPosition()
    tempFrame:setPosition(ccp(x, y))
    index = index + 1
    self.m_PetLingwuSkillFrame = tempFrame
  end
  for i = index, 3 do
    self:getNode(string.format("txt2%d", i)):setVisible(false)
  end
  self:SetSelected()
end
function selectAutoSkill:Btn_SetChangeAttack(obj, t)
  if self.m_SettingPos ~= nil then
    local opData = self.m_WarUIObj:GetAutoFightDataByPos(self.m_SettingPos) or {}
    opData.caFlag = true
    self.m_WarUIObj:SetDefaultSettingData(self.m_SettingPos, opData)
    ShowNotifyTips("下回合生效")
  end
  self:SetSelected()
end
function selectAutoSkill:Btn_SetNotChangeAttack(obj, t)
  if self.m_SettingPos ~= nil then
    local opData = self.m_WarUIObj:GetAutoFightDataByPos(self.m_SettingPos) or {}
    opData.caFlag = false
    self.m_WarUIObj:SetDefaultSettingData(self.m_SettingPos, opData)
    ShowNotifyTips("下回合生效")
  end
  self:SetSelected()
end
function selectAutoSkill:Btn_SetAttack(obj, t)
  if self.m_SettingPos ~= nil then
    local opData = self.m_WarUIObj:GetAutoFightDataByPos(self.m_SettingPos) or {}
    opData.aiActionType = AI_ACTION_TYPE_NORMALATTACK
    opData.targetPos = 0
    opData.skillId = SKILLTYPE_NORMALATTACK
    self.m_WarUIObj:SetDefaultSettingData(self.m_SettingPos, opData)
    ShowNotifyTips("下回合生效")
  end
  self:SetSelected()
end
function selectAutoSkill:Btn_SetDefence(obj, t)
  if self.m_SettingPos ~= nil then
    local opData = self.m_WarUIObj:GetAutoFightDataByPos(self.m_SettingPos) or {}
    opData.aiActionType = AI_ACTION_TYPE_DEFEND
    opData.targetPos = nil
    opData.skillId = nil
    self.m_WarUIObj:SetDefaultSettingData(self.m_SettingPos, opData)
    ShowNotifyTips("下回合生效")
  end
  self:SetSelected()
end
function selectAutoSkill:onSelected(clickSkillItem)
  local skillId = clickSkillItem:getSkillId()
  local unKnownFlag = clickSkillItem:getUnKnownFlag()
  local openFlag = clickSkillItem:getOpenFlag()
  local mpEnoughFlag = clickSkillItem:getMpEnoughFlag()
  local yiwangFlag = clickSkillItem:getYiwangFlag()
  if skillId == nil or unKnownFlag == true or openFlag == false then
  else
    local opData = self.m_WarUIObj:GetAutoFightDataByPos(self.m_SettingPos) or {}
    opData.aiActionType = AI_ACTION_TYPE_USESKILL
    opData.targetPos = 0
    opData.skillId = skillId
    self.m_WarUIObj:SetDefaultSettingData(self.m_SettingPos, opData)
    ShowNotifyTips("下回合生效")
  end
  self:SetSelected()
end
function selectAutoSkill:SetSelected()
  print("selectAutoSkill:SetSelected")
  local opData = self.m_WarUIObj:GetAutoFightDataByPos(self.m_SettingPos) or {}
  for _, btn in pairs({
    self.m_Btn_SetAttack,
    self.m_Btn_SetDefence,
    self.btn_changeAttack,
    self.btn_notChangeAttack
  }) do
    if btn and btn._SelectFlag ~= nil then
      btn._SelectFlag:removeFromParent()
      btn._SelectFlag = nil
    end
  end
  for _, btn in pairs(self.m_SkillItemObjDict) do
    if btn and btn._SelectFlag ~= nil then
      btn._SelectFlag:removeFromParent()
      btn._SelectFlag = nil
    end
  end
  if opData.caFlag == false then
    local tempSprite = display.newSprite("views/common/btn/selected.png")
    tempSprite:setAnchorPoint(ccp(0.3, 0.3))
    self.btn_notChangeAttack:addNode(tempSprite, 1)
    self.btn_notChangeAttack._SelectFlag = tempSprite
  else
    local tempSprite = display.newSprite("views/common/btn/selected.png")
    tempSprite:setAnchorPoint(ccp(0.3, 0.3))
    self.btn_changeAttack:addNode(tempSprite, 1)
    self.btn_changeAttack._SelectFlag = tempSprite
  end
  if opData.aiActionType == AI_ACTION_TYPE_NORMALATTACK then
    local tempSprite = display.newSprite("views/common/btn/selected.png")
    tempSprite:setAnchorPoint(ccp(0.3, 0.3))
    self.m_Btn_SetAttack:addNode(tempSprite, 1)
    self.m_Btn_SetAttack._SelectFlag = tempSprite
  elseif opData.aiActionType == AI_ACTION_TYPE_DEFEND then
    local tempSprite = display.newSprite("views/common/btn/selected.png")
    tempSprite:setAnchorPoint(ccp(0.3, 0.3))
    self.m_Btn_SetDefence:addNode(tempSprite, 1)
    self.m_Btn_SetDefence._SelectFlag = tempSprite
  elseif opData.aiActionType == AI_ACTION_TYPE_USESKILL then
    local skillId = opData.skillId
    local btn = self.m_SkillItemObjDict[skillId]
    if btn then
      local tempSprite = display.newSprite("views/common/btn/selected.png")
      tempSprite:setAnchorPoint(ccp(0.3, 0.3))
      local size = btn:getContentSize()
      tempSprite:setPosition(ccp(size.width / 2, size.height / 2))
      btn:addNode(tempSprite, 1)
      btn._SelectFlag = tempSprite
    end
  end
  if self.m_PetLingwuSkillFrame then
    self.m_PetLingwuSkillFrame:JumpToItemPage(opData.skillId)
    self.m_PetLingwuSkillFrame:setSelectSkill(opData.skillId)
  end
end
function selectAutoSkill:Clear()
  self.m_WarUIObj:SaveWaruiSetting()
  self.m_WarUIObj:SaveFightSettingToSer()
  self.m_WarUIObj = nil
  self.m_HeroObj = nil
  self.m_PetObj = nil
end
function selectAutoSkill:Btn_KillWar(obj, t)
  local tempView = CPopWarning.new({
    title = "解决卡机",
    text = "因异常导致无法继续游戏时,可使用解决卡机,确定使用吗？",
    cancelFunc = nil,
    align = CRichText_AlignType_Left,
    confirmFunc = function()
      if g_WarScene then
        netsend.netwar.tellSerToKillWar(g_WarScene:getWarID())
      end
    end
  })
  tempView:ShowCloseBtn(false)
end
return selectAutoSkill
