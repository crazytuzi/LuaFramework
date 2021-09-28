selectPetSkill = class("selectPetSkill", CcsSubView)
function selectPetSkill:ctor(waruiObj, petObj, pos)
  selectPetSkill.super.ctor(self, "views/select_petskill.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "m_Btn_Close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_WarUIObj = waruiObj
  self.m_PetObj = petObj
  self.m_WarPos = pos
  local tianshengSkill = {}
  local neidanSkill = {}
  local lingwuSkill = {}
  local data_table = data_Pet[self.m_PetObj:getTypeId()]
  if data_table ~= nil and data_table.skills[1] ~= nil and data_table.skills[1] ~= 0 then
    for num = 1, 4 do
      local tempSkillId = data_table.skills[num]
      local openFlag = g_WarScene:roleCanOpenSkill(self.m_WarPos, tempSkillId)
      if openFlag then
        tianshengSkill[#tianshengSkill + 1] = tempSkillId
      end
    end
  end
  local index = 1
  for tempSkillId, _ in pairs(data_Neidan) do
    local openFlag = g_WarScene:roleCanOpenSkill(self.m_WarPos, tempSkillId)
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
    local openFlag = g_WarScene:roleCanOpenSkill(self.m_WarPos, tempSkillId)
    if openFlag then
      lingwuSkill[#lingwuSkill + 1] = tempSkillId
    end
  end
  table.sort(lingwuSkill)
  local index = 1
  if #tianshengSkill ~= 0 then
    self:getNode(string.format("skillType%d", index)):setText("天生法术")
    for num, tempSkillId in ipairs(tianshengSkill) do
      local mpEnoughFlag = g_WarScene:roleSkillMpEnough(self.m_WarPos, tempSkillId)
      local openFlag = g_WarScene:roleCanOpenSkill(self.m_WarPos, tempSkillId)
      local yiwangFlag = g_WarScene:roleSkillIsYiWang(self.m_WarPos, tempSkillId)
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
    end
    index = index + 1
  end
  if #neidanSkill ~= 0 then
    self:getNode(string.format("skillType%d", index)):setText("魂石技能")
    for num, tempSkillId in ipairs(neidanSkill) do
      local mpEnoughFlag = g_WarScene:roleSkillMpEnough(self.m_WarPos, tempSkillId)
      local openFlag = g_WarScene:roleCanOpenSkill(self.m_WarPos, tempSkillId)
      local yiwangFlag = g_WarScene:roleSkillIsYiWang(self.m_WarPos, tempSkillId)
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
    end
    index = index + 1
  end
  if #lingwuSkill ~= 0 then
    self:getNode(string.format("skillType%d", index)):setText("领悟技能")
    local frameData = {}
    for num, tempSkillId in ipairs(lingwuSkill) do
      local roleId = self.m_PetObj:getObjId()
      local minRoundFlag = g_WarScene:roleSkillCanUseOfMinRound(self.m_WarPos, tempSkillId)
      local mpEnoughFlag = g_WarScene:roleSkillMpEnough(self.m_WarPos, tempSkillId)
      local openFlag = g_WarScene:roleCanOpenSkill(self.m_WarPos, tempSkillId)
      local cdFlag = g_WarScene:roleSkillCDEnough(self.m_WarPos, tempSkillId)
      local proFlag = g_WarScene:roleSkillProEnough(self.m_WarPos, tempSkillId)
      local hasUseFlag = g_WarScene:roleSkillHasUse(self.m_WarPos, tempSkillId)
      local hpEnoughFlag = g_WarScene:roleSkillHpEnough(self.m_WarPos, tempSkillId)
      local yiwangFlag = g_WarScene:roleSkillIsYiWang(self.m_WarPos, tempSkillId)
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
  end
  for i = index, 3 do
    self:getNode(string.format("skillType%d", i)):setVisible(false)
  end
end
function selectPetSkill:Btn_Close(obj, t)
  self:CloseSelf()
end
function selectPetSkill:ShowWarSelectView(flag)
  self:setEnabled(flag)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setEnabled(flag)
  end
end
function selectPetSkill:onSelected(clickSkillItem)
  local skillId = clickSkillItem:getSkillId()
  local unKnownFlag = clickSkillItem:getUnKnownFlag()
  local openFlag = clickSkillItem:getOpenFlag()
  local mpEnoughFlag = clickSkillItem:getMpEnoughFlag()
  local minRoundFlag = clickSkillItem:getMinRoundFlag()
  local hasUsedFlag = clickSkillItem:getHasUseFlag()
  local yiwangFlag = clickSkillItem:getYiwangFlag()
  local data_table = data_Pet[self.m_PetObj:getTypeId()]
  local warType = g_WarScene:getWarType()
  if skillId == nil or unKnownFlag == true then
    ShowNotifyTips("技能还没有开启")
  elseif openFlag == false then
    ShowNotifyTips("技能还没有开启")
  elseif skillId == PETSKILL_ZHAOYUNMUYU and not IsPVPWarType(warType) then
    ShowNotifyTips("玩家之间战斗时才能使用")
  elseif hasUsedFlag == true then
    ShowNotifyTips("该技能全场只能使用一次")
  elseif minRoundFlag ~= true then
    ShowNotifyTips(string.format("该技能前%d回合不能使用", minRoundFlag - 1))
  else
    self:ShowWarSelectView(false)
    self.m_WarUIObj:SelectSkill(skillId)
  end
end
function selectPetSkill:Clear()
  self.m_WarUIObj:CancelAction()
  self.m_WarUIObj = nil
  self.m_PetObj = nil
end
return selectPetSkill
