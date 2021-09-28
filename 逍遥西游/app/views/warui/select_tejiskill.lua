selectTejiSkill = class("selectTejiSkill", CcsSubView)
function selectTejiSkill:ctor(waruiObj, heroObj, pos)
  selectTejiSkill.super.ctor(self, "views/select_tejiskill.json", {isAutoCenter = true, opacityBg = 100})
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
  self:getNode("skillType1"):setText("亲密技能")
  self:getNode("skillType2"):setText("")
  self:getNode("skillType3"):setText("")
  for row = 1, 3 do
    if row == 1 then
      for set = 1, 3 do
        local tempSkillId = ACTIVE_MARRYSKILLLIST[set]
        local openFlag = g_WarScene:roleCanOpenSkill(self.m_WarPos, tempSkillId)
        local cdFlag = g_WarScene:roleSkillCDEnough(self.m_WarPos, tempSkillId)
        local mpEnoughFlag = g_WarScene:roleSkillMpEnough(self.m_WarPos, tempSkillId)
        local hasUseFlag = g_WarScene:roleSkillHasUse(self.m_WarPos, tempSkillId)
        local yiwangFlag = g_WarScene:roleSkillIsYiWang(self.m_WarPos, tempSkillId)
        local flagDict = {
          mpEnoughFlag = mpEnoughFlag,
          openFlag = openFlag,
          cdFlag = cdFlag,
          hasUseFlag = hasUseFlag,
          yiwangFlag = yiwangFlag
        }
        local tempSkillItem = selectSkillItem.new(self.m_HeroObj:getObjId(), tempSkillId, handler(self, self.onSelected), flagDict)
        local x, y = self:getNode(string.format("pos_%d%d", row, set + 2)):getPosition()
        tempSkillItem:setPosition(ccp(x, y))
        self:addSubView({subView = tempSkillItem})
      end
    end
  end
end
function selectTejiSkill:Btn_Close(obj, t)
  self:CloseSelf()
end
function selectTejiSkill:ShowWarSelectView(flag)
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
function selectTejiSkill:onSelected(clickSkillItem)
  if g_WarScene == nil then
    return
  end
  local skillId = clickSkillItem:getSkillId()
  local unKnownFlag = clickSkillItem:getUnKnownFlag()
  local openFlag = clickSkillItem:getOpenFlag()
  local mpEnoughFlag = clickSkillItem:getMpEnoughFlag()
  local yiwangFlag = clickSkillItem:getYiwangFlag()
  if skillId == nil or unKnownFlag == true then
    ShowNotifyTips("技能还没有开启")
  elseif openFlag == false then
    ShowNotifyTips("技能还没有开启")
  elseif g_WarScene:roleSkillCanGetMarryTarget(self.m_WarPos, skillId) == false then
    local banlvName = "伴侣"
    if g_FriendsMgr then
      local _, blID = g_FriendsMgr:getBanlvInfo()
      if blID then
        blInfo = g_FriendsMgr:getPlayerInfo(blID)
        banlvName = blInfo and (blInfo.name or "伴侣")
      end
    end
    local skillName = data_getSkillName(skillId)
    ShowNotifyTips(string.format("你与%s不在同一战斗中，无法释放#<Y>%s#", banlvName, skillName))
  else
    self:ShowWarSelectView(false)
    self.m_WarUIObj:SelectSkill(skillId)
  end
end
function selectTejiSkill:Clear()
  self.m_WarUIObj:CancelAction()
  self.m_WarUIObj = nil
  self.m_HeroObj = nil
end
return selectTejiSkill
