MainUISkillBar = class("MainUISkillBar", CcsSubView)
function MainUISkillBar:ctor(index, clickListener, addSkillExpListener, typeIdx)
  MainUISkillBar.super.ctor(self, "views/skillbar.json")
  self.m_Index = index
  self.m_Listener = clickListener
  self.m_addExpListener = addSkillExpListener
  self.m_Icon = nil
  self.m_RoleId = nil
  self.m_SkillId = nil
  self.m_SkillProficiency = 0
  local x, y = self:getNode("btn_pos"):getPosition()
  self.btn_addP = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.OnBtn_AddP), 0.2)
  self:addChild(self.btn_addP)
  self.btn_addP:setPosition(ccp(x, y))
  self:ListenMessage(MsgID_PlayerInfo)
  print("MainUISkillBar, index, typeIdx:", index, typeIdx)
  if typeIdx == 1 and index == 1 and g_MissionMgr then
    g_MissionMgr:registerClassObj(self, self.__cname, nil, 1)
  end
end
function MainUISkillBar:Reflush(roleId, skillId)
  if skillId == nil then
    return
  end
  local roleIns = g_LocalPlayer:getObjById(roleId)
  if roleIns == nil then
    return
  end
  if self.m_RoleId == roleId and self.m_SkillId == skillId then
    return
  end
  self.m_RoleId = roleId
  self.m_SkillId = skillId
  self:updateSkillIcon()
  self:updateSkillData()
end
function MainUISkillBar:updateSkillIcon()
  local roleIns = g_LocalPlayer:getObjById(self.m_RoleId)
  local skillId = self.m_SkillId
  if self.m_Icon then
    self.m_Icon:removeSelf()
  end
  local x, y = self:getNode("img_pos"):getPosition()
  local imgSize = self:getNode("img_pos"):getContentSize()
  local w = imgSize.width
  local h = imgSize.height
  self.m_OpenFlag = roleIns:getSkillIsOpen(skillId) or roleIns:getBDSkillIsOpen(skillId)
  local path = data_getSkillShapePath(skillId)
  if self.m_OpenFlag == false then
    self.m_SkillImg = display.newGraySprite(path)
  else
    self.m_SkillImg = display.newSprite(path)
  end
  local size = CCSize(w, h)
  local jie = data_getSkillStep(skillId)
  if jie ~= nil and jie > 2 and jie <= 5 then
    local jieImg = display.newSprite(string.format("views/warui/pic_jie%d.png", jie - 2))
    jieImg:setAnchorPoint(ccp(1, 0))
    self.m_SkillImg:addChild(jieImg)
    jieImg:setPosition(ccp(size.width - 6, -2))
  end
  local clickImg = createClickSkill({
    roleID = self.m_RoleId,
    skillID = skillId,
    autoSize = size,
    LongPressTime = 0.2,
    LongPressListener = nil,
    LongPressEndListner = nil,
    imgFlag = false,
    clickDel = nil
  })
  self.m_Icon = clickImg
  self:addChild(self.m_Icon)
  self.m_Icon:setPosition(ccp(x, y))
  self.m_Icon:addNode(self.m_SkillImg)
  self.m_SkillImg:setPosition(ccp(size.width / 2, size.height / 2))
  self:setSkillIconEnabled(self.m_IconEnabledFlag)
end
function MainUISkillBar:updateSkillData()
  print("updateSkillData")
  local roleIns = g_LocalPlayer:getObjById(self.m_RoleId)
  local curZs = roleIns:getProperty(PROPERTY_ZHUANSHENG)
  local curLv = roleIns:getProperty(PROPERTY_ROLELEVEL)
  local zsMaxProficiency = CalculateSkillProficiency(curZs)
  local maxProficiency = data_getSkillExpLimitByZsAndLv(curZs, curLv)
  if maxProficiency == nil then
    maxProficiency = zsMaxProficiency
  end
  self.m_SkillProficiency = roleIns:getProficiency(self.m_SkillId) or 0
  self:getNode("txt_p"):setText(string.format("%d/%d", self.m_SkillProficiency, maxProficiency))
  self:getNode("txt_p"):setVisible(true)
  self:getNode("bar"):setPercent(self.m_SkillProficiency / maxProficiency * 100)
  self:getNode("bar"):setVisible(true)
  self:getNode("barbg"):setVisible(true)
  local skillName = data_getSkillName(self.m_SkillId)
  self:getNode("txt_name"):setText(skillName)
  local text = ""
  if self.m_RoleId == g_LocalPlayer:getMainHeroId() then
    if not self.m_OpenFlag then
      local jie = data_getSkillStep(self.m_SkillId)
      text = string.format("#<IRP>#上一技能熟练度%d时开启", data_getSkill_OpenNextSkillValue(jie))
    else
      local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Shaofa)
      if openFlag == false then
        if noOpenType == OPEN_FUNC_Type_Hide then
          text = ""
        elseif noOpenType == OPEN_FUNC_Type_Gray then
          text = "#<IRP>#" .. tips
        end
      elseif maxProficiency > self.m_SkillProficiency then
        local needCoin = GetAddSkillExpNeedCoin(self.m_SkillId, self.m_SkillProficiency)
        local coinC = "W"
        if needCoin > g_LocalPlayer:getCoin() then
          coinC = "R"
        end
        text = string.format("升级花费 #<IR1,%s>%d#", coinC, needCoin)
      elseif zsMaxProficiency > maxProficiency then
        local nextMaxProficiency = data_getSkillExpLimitByZsAndLv(curZs, curLv + 1)
        if nextMaxProficiency == nil then
          nextMaxProficiency = zsMaxProficiency
        end
        text = string.format("#<IRP>#下一级熟练度上限%d", nextMaxProficiency)
      elseif curZs < 3 then
        text = "#<IRP>#转生后提升熟练度上限"
      end
    end
  elseif roleIns:getType() ~= LOGICTYPE_PET then
    if not self.m_OpenFlag then
      if self.m_Index == 1 then
        text = string.format("%d级时开启", Skill_HuobanSkill1OpenLv)
      elseif self.m_Index == 2 then
        text = string.format("%d级时开启", Skill_HuobanSkill2OpenLv)
      elseif self.m_Index == 3 then
        text = string.format("%d级时开启", Skill_HuobanSkill3OpenLv)
      else
        text = "技能还没有开启"
      end
    end
    self:getNode("txt_p"):setVisible(false)
    self:getNode("bar"):setVisible(false)
    self:getNode("barbg"):setVisible(false)
  else
    if not self.m_OpenFlag then
      if self.m_Index == 1 then
        text = string.format("召唤兽等级到达%d时开启", Skill_PetSkill1OpenLv)
      elseif self.m_Index == 2 then
        text = string.format("召唤兽等级到达%d时开启", Skill_PetSkill2OpenLv)
      else
        text = "技能还没有开启"
      end
    end
    self:getNode("txt_p"):setVisible(false)
    self:getNode("bar"):setVisible(false)
    self:getNode("barbg"):setVisible(false)
  end
  local x, y = self:getNode("tips_pos"):getPosition()
  local size = self:getNode("tips_pos"):getContentSize()
  if self.m_TextBox == nil then
    self.m_TextBox = CRichText.new({
      width = size.width,
      verticalSpace = 0,
      font = KANG_TTF_FONT,
      fontSize = 18,
      color = ccc3(94, 211, 207)
    })
    self.m_TextBox:addRichText(text)
    self:addChild(self.m_TextBox)
    local h = self.m_TextBox:getContentSize().height
    self.m_TextBox:setPosition(ccp(x, y + size.height - h))
  else
    self.m_TextBox:clearAll()
    self.m_TextBox:addRichText(text)
    local h = self.m_TextBox:getContentSize().height
    self.m_TextBox:setPosition(ccp(x, y + size.height - h))
  end
  self.m_ShowBtnFlag = true
  if not self.m_OpenFlag then
    self.m_ShowBtnFlag = false
  elseif self.m_RoleId ~= g_LocalPlayer:getMainHeroId() then
    self.m_ShowBtnFlag = false
  elseif maxProficiency <= self.m_SkillProficiency then
    self.m_ShowBtnFlag = false
  end
  if self.m_ShowBtnFlag == false then
    self.btn_addP:setEnabled(false)
    self.btn_addP:setTouchEnabled(false)
    self.btn_addP:setVisible(false)
  else
    self.btn_addP:setEnabled(true)
    self.btn_addP:setTouchEnabled(true)
    self.btn_addP:setVisible(true)
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Shaofa)
    if openFlag == false then
      if noOpenType == OPEN_FUNC_Type_Hide then
        self.m_ShowBtnFlag = false
        self.btn_addP:setEnabled(false)
        self.btn_addP:setTouchEnabled(false)
        self.btn_addP:setVisible(false)
      elseif noOpenType == OPEN_FUNC_Type_Gray then
        self.btn_addP:setButtonDisableState(false)
      end
    else
      self.btn_addP:setButtonDisableState(true)
    end
  end
  self:setSkillIconEnabled(self.m_IconEnabledFlag)
end
function MainUISkillBar:setSkillIconEnabled(b)
  b = b or false
  self.m_IconEnabledFlag = b
  self:setEnabled(b)
  self:setTouchEnabled(b)
  self:setVisible(b)
  if self.m_Icon then
    self.m_Icon:setEnabled(b)
    self.m_Icon:setTouchEnabled(b)
    self.m_Icon:setVisible(b)
  end
  if self.btn_addP then
    if self.m_ShowBtnFlag == false then
      b = false
    end
    self.btn_addP:setEnabled(b)
    self.btn_addP:setTouchEnabled(b)
    self.btn_addP:setVisible(b)
  end
end
function MainUISkillBar:stopLongPressClick()
  self.btn_addP:stopLongPressClick()
end
function MainUISkillBar:getSkillId()
  return self.m_SkillId
end
function MainUISkillBar:getOpenFlag()
  return self.m_OpenFlag
end
function MainUISkillBar:OnBtn_AddP()
  self.m_addExpListener(self, self.m_SkillId)
end
function MainUISkillBar:Clear()
  self.m_Listener = nil
  self.m_addExpListener = nil
  if g_MissionMgr then
    g_MissionMgr:unRegisterClassObj(self, self.__cname, nil)
  end
end
function MainUISkillBar:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_HeroUpdate then
    local playerId = arg[1].pid
    local heroId = arg[1].heroId
    local player = g_DataMgr:getPlayer(playerId)
    if self.m_RoleId == g_LocalPlayer:getMainHeroId() and heroId == self.m_RoleId and playerId ~= g_LocalPlayer:getPlayerId() then
      self:updateSkillData()
    end
  elseif msgSID == MsgID_MoneyUpdate then
    if self.m_RoleId == g_LocalPlayer:getMainHeroId() then
      self:updateSkillData()
    end
  elseif msgSID == MsgID_HeroSkillExpChange and self.m_RoleId == g_LocalPlayer:getMainHeroId() then
    local skillNo = arg[1].skillNo
    local mainHero = g_LocalPlayer:getMainHero()
    local skillTypeList = mainHero:getSkillTypeList()
    local row = math.floor(skillNo / 5) + 1
    local step = skillNo % 5
    if step == 0 then
      step = 5
      row = row - 1
    end
    local skillAttr = skillTypeList[row]
    local skillId = data_getSkillListByAttr(skillAttr)[step]
    if skillId == self.m_SkillId then
      local roleIns = g_LocalPlayer:getMainHero()
      if roleIns == nil then
        return
      end
      if self.m_OpenFlag ~= roleIns:getSkillIsOpen(skillId) then
        self:updateSkillIcon()
      end
      self:updateSkillData()
    end
  end
end
QinMiSkillBar = class("QinMiSkillBar", CcsSubView)
function QinMiSkillBar:ctor(skillId, addSkillExpListener)
  QinMiSkillBar.super.ctor(self, "views/skillbar.json")
  self.m_Index = index
  self.m_addExpListener = addSkillExpListener
  self.m_Icon = nil
  self.m_SkillId = skillId
  self.m_SkillProficiency = 0
  local x, y = self:getNode("btn_pos"):getPosition()
  self.btn_addP = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.OnBtn_AddP), 0.2)
  self:addChild(self.btn_addP)
  self.btn_addP:setPosition(ccp(x, y))
  self:updateSkillIcon()
  self:updateSkillData()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_Friends)
end
function QinMiSkillBar:updateSkillIcon()
  local banLvID = g_FriendsMgr:getBanLvId()
  local hasBLFlag = banLvID ~= nil
  if self.m_Icon then
    self.m_Icon:removeSelf()
  end
  local x, y = self:getNode("img_pos"):getPosition()
  local imgSize = self:getNode("img_pos"):getContentSize()
  local w = imgSize.width
  local h = imgSize.height
  self.m_OpenFlag = hasBLFlag
  local path = data_getSkillShapePath(self.m_SkillId)
  if self.m_OpenFlag == false then
    self.m_SkillImg = display.newGraySprite(path)
  else
    self.m_SkillImg = display.newSprite(path)
  end
  local size = CCSize(w, h)
  local jie = data_getSkillStep(self.m_SkillId)
  if jie ~= nil and jie > 0 and jie <= 3 then
    local jieImg = display.newSprite(string.format("views/warui/pic_jie%d.png", jie))
    jieImg:setAnchorPoint(ccp(1, 0))
    self.m_SkillImg:addChild(jieImg)
    jieImg:setPosition(ccp(size.width - 6, -2))
  end
  local clickImg = createClickSkill({
    roleID = g_LocalPlayer:getMainHeroId(),
    skillID = self.m_SkillId,
    autoSize = size,
    LongPressTime = 0.2,
    LongPressListener = nil,
    LongPressEndListner = nil,
    imgFlag = false,
    clickDel = nil
  })
  self.m_Icon = clickImg
  self:addChild(self.m_Icon)
  self.m_Icon:setPosition(ccp(x, y))
  self.m_Icon:addNode(self.m_SkillImg)
  self.m_SkillImg:setPosition(ccp(size.width / 2, size.height / 2))
  self:setSkillIconEnabled(self.m_IconEnabledFlag)
end
function QinMiSkillBar:updateSkillData()
  print("updateSkillData")
  local fValue = 0
  local banLvID = g_FriendsMgr:getBanLvId()
  if banLvID ~= nil then
    fValue = g_FriendsMgr:getFriendValue(banLvID) or 0
  end
  local roleIns = g_LocalPlayer:getMainHero()
  local maxProficiency = math.min(data_Variables.FriendCloseLimit or 25000, fValue)
  self.m_SkillProficiency = roleIns:getProficiency(self.m_SkillId) or 0
  self:getNode("txt_p"):setText(string.format("%d/%d", self.m_SkillProficiency, maxProficiency))
  self:getNode("txt_p"):setVisible(self.m_OpenFlag)
  self:getNode("bar"):setPercent(self.m_SkillProficiency / maxProficiency * 100)
  self:getNode("bar"):setVisible(self.m_OpenFlag)
  self:getNode("barbg"):setVisible(self.m_OpenFlag)
  local skillName = data_getSkillName(self.m_SkillId)
  self:getNode("txt_name"):setText(skillName)
  local text = ""
  if self.m_OpenFlag then
    if maxProficiency > self.m_SkillProficiency then
      local needCoin = GetAddMarrySkillExpNeedCoin(self.m_SkillId, self.m_SkillProficiency)
      local coinC = "W"
      if needCoin > g_LocalPlayer:getCoin() then
        coinC = "R"
      end
      text = string.format("升级花费 #<IR1,%s>%d#", coinC, needCoin)
    elseif maxProficiency < (data_Variables.FriendCloseLimit or 25000) then
      text = string.format("#<IRP>#熟练度上限随着友好度提升")
    else
      text = string.format("#<IRP>#技能已修炼圆满")
    end
  end
  local x, y = self:getNode("tips_pos"):getPosition()
  local size = self:getNode("tips_pos"):getContentSize()
  if self.m_TextBox == nil then
    self.m_TextBox = CRichText.new({
      width = size.width,
      verticalSpace = 0,
      font = KANG_TTF_FONT,
      fontSize = 18,
      color = ccc3(94, 211, 207)
    })
    self.m_TextBox:addRichText(text)
    self:addChild(self.m_TextBox)
    local h = self.m_TextBox:getContentSize().height
    self.m_TextBox:setPosition(ccp(x, y + size.height - h))
  else
    self.m_TextBox:clearAll()
    self.m_TextBox:addRichText(text)
    local h = self.m_TextBox:getContentSize().height
    self.m_TextBox:setPosition(ccp(x, y + size.height - h))
  end
  self.m_ShowBtnFlag = true
  if not self.m_OpenFlag then
    self.m_ShowBtnFlag = false
  elseif maxProficiency <= self.m_SkillProficiency then
    self.m_ShowBtnFlag = false
  end
  if self.m_ShowBtnFlag == false then
    self.btn_addP:setEnabled(false)
    self.btn_addP:setTouchEnabled(false)
    self.btn_addP:setVisible(false)
  else
    self.btn_addP:setEnabled(true)
    self.btn_addP:setTouchEnabled(true)
    self.btn_addP:setVisible(true)
    self.btn_addP:setButtonDisableState(true)
  end
  self:setSkillIconEnabled(self.m_IconEnabledFlag)
end
function QinMiSkillBar:setSkillIconEnabled(b)
  b = b or false
  self.m_IconEnabledFlag = b
  self:setEnabled(b)
  self:setTouchEnabled(b)
  self:setVisible(b)
  if self.m_Icon then
    self.m_Icon:setEnabled(b)
    self.m_Icon:setTouchEnabled(b)
    self.m_Icon:setVisible(b)
  end
  if self.btn_addP then
    if self.m_ShowBtnFlag == false then
      b = false
    end
    self.btn_addP:setEnabled(b)
    self.btn_addP:setTouchEnabled(b)
    self.btn_addP:setVisible(b)
  end
end
function QinMiSkillBar:stopLongPressClick()
  self.btn_addP:stopLongPressClick()
end
function QinMiSkillBar:OnBtn_AddP()
  self.m_addExpListener(self, self.m_SkillId)
end
function QinMiSkillBar:Clear()
  self.m_addExpListener = nil
end
function QinMiSkillBar:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_HeroMarrySkillExpChange then
    self:updateSkillData()
  elseif msgSID == MsgID_MoneyUpdate then
    self:updateSkillData()
  elseif msgSID == MsgID_Friends_FlushBanLv then
    self:updateSkillIcon()
    self:updateSkillData()
  elseif msgSID == MsgID_Friends_UpdateFirend then
    local pid = arg[1]
    if pid == g_FriendsMgr:getBanLvId() then
      self:updateSkillIcon()
      self:updateSkillData()
    end
  end
end
