selectHeroSkill = class("selectHeroSkill", CcsSubView)
function selectHeroSkill:ctor(waruiObj, heroObj, pos)
  selectHeroSkill.super.ctor(self, "views/select_heroskill.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "m_Btn_Close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_WarUIObj = waruiObj
  self.m_HeroObj = heroObj
  self.m_WarPos = pos
  local race = heroObj:getProperty(PROPERTY_RACE)
  local gender = heroObj:getProperty(PROPERTY_GENDER)
  local skillTypeList = heroObj:getSkillTypeList()
  self:getNode("skillType1"):setText(SKILLATTR_NAME_DICT[skillTypeList[1]])
  self:getNode("skillType2"):setText(SKILLATTR_NAME_DICT[skillTypeList[2]])
  self:getNode("skillType3"):setText(SKILLATTR_NAME_DICT[skillTypeList[3]])
  for row = 1, 3 do
    local skillAttr = skillTypeList[row]
    local skillList = data_getSkillListByAttr(skillAttr)
    for set = 1, 5 do
      local tempSkillId = skillList[set]
      local mpEnoughFlag = g_WarScene:roleSkillMpEnough(self.m_WarPos, tempSkillId)
      local openFlag = g_WarScene:roleCanOpenSkill(self.m_WarPos, tempSkillId)
      local yiwangFlag = g_WarScene:roleSkillIsYiWang(self.m_WarPos, tempSkillId)
      if openFlag then
        local flagDict = {
          mpEnoughFlag = mpEnoughFlag,
          openFlag = openFlag,
          unKnownFlag = false,
          yiwangFlag = yiwangFlag
        }
        local tempSkillItem = selectSkillItem.new(self.m_HeroObj:getObjId(), tempSkillId, handler(self, self.onSelected), flagDict)
        local x, y = self:getNode(string.format("pos_%d%d", row, set)):getPosition()
        tempSkillItem:setPosition(ccp(x, y))
        self:addSubView({subView = tempSkillItem})
      end
    end
  end
end
function selectHeroSkill:Btn_Close(obj, t)
  self:CloseSelf()
end
function selectHeroSkill:ShowWarSelectView(flag)
  self:setEnabled(flag)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setEnabled(flag)
  end
  scheduler.performWithDelayGlobal(function()
    if g_MissionMgr then
      g_MissionMgr:unRegisterClassObj(self, self.__cname, nil)
    end
  end, 0.01)
end
function selectHeroSkill:onSelected(clickSkillItem)
  local skillId = clickSkillItem:getSkillId()
  local unKnownFlag = clickSkillItem:getUnKnownFlag()
  local openFlag = clickSkillItem:getOpenFlag()
  local mpEnoughFlag = clickSkillItem:getMpEnoughFlag()
  local yiwangFlag = clickSkillItem:getYiwangFlag()
  if skillId == nil or unKnownFlag == true then
    ShowNotifyTips("技能还没有开启")
  elseif openFlag == false then
    local step = data_getSkillStep(skillId)
    local attr = data_getSkillAttrStyle(skillId)
    local lastSkill = data_getSkillListByAttr(attr)[step - 1]
    if lastSkill ~= nil then
      ShowNotifyTips(string.format("%s技能熟练度到达%d时开启", data_getSkillName(lastSkill), data_getSkill_OpenNextSkillValue(step)))
    else
      ShowNotifyTips("技能还没有开启")
    end
  else
    self:ShowWarSelectView(false)
    self.m_WarUIObj:SelectSkill(skillId)
  end
end
function selectHeroSkill:Clear()
  self.m_WarUIObj:CancelAction()
  self.m_WarUIObj = nil
  self.m_HeroObj = nil
end
return selectHeroSkill
