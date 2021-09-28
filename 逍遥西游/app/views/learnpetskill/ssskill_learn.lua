local CSSSkill_learn = class("CSSSkill_learn", CcsSubView)
function CSSSkill_learn:ctor(petId, petObj)
  CSSSkill_learn.super.ctor(self, "views/pet_ssskill.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close"
    },
    btn_study = {
      listener = handler(self, self.Btn_Study),
      variName = "btn_study"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  clickArea_check.extend(self)
  self.m_PetId = petId
  self.petObj = petObj
  self.descbox = self:getNode("descbox")
  self.descbox:setVisible(false)
  self.imagepos = self:getNode("imagepos")
  self.imagepos:setVisible(false)
  local p = self.imagepos:getParent()
  local x, y = self.imagepos:getPosition()
  local z = self.imagepos:getZOrder()
  local shapeId = petObj:getProperty(PROPERTY_SHAPE)
  local roleAni, offx, offy = createWarBodyByShape(shapeId)
  roleAni:playAniWithName("guard_4", -1)
  p:addNode(roleAni, z + 2)
  roleAni:setPosition(ccp(x + offx, y + offy))
  self:addclickAniForPetAni(roleAni, self.imagepos)
  local roleAureole = CreateSeqAnimation("xiyou/ani/role_aureole.plist", -1, nil, nil, nil, 6)
  p:addNode(roleAureole, z + 1)
  roleAureole:setPosition(x + AUREOLE_OFF_X, y + AUREOLE_OFF_Y)
  local roleShadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  p:addNode(roleShadow, z + 1)
  roleShadow:setPosition(x, y)
  local iconPath = data_getPetIconPath(petObj:getTypeId())
  local iconImg = display.newSprite(iconPath)
  local pet_quality = self:getNode("pet_quality")
  pet_quality:setVisible(false)
  local p = pet_quality:getParent()
  local x, y = pet_quality:getPosition()
  local z = pet_quality:getZOrder()
  local size = pet_quality:getContentSize()
  p:addNode(iconImg, z + 10)
  iconImg:setAnchorPoint(ccp(0, 1))
  iconImg:setPosition(ccp(x, y + size.height))
  local petName = petObj:getProperty(PROPERTY_NAME)
  local zs = petObj:getProperty(PROPERTY_ZHUANSHENG)
  local lv = petObj:getProperty(PROPERTY_ROLELEVEL)
  local color = NameColor_Pet[zs] or ccc3(255, 255, 255)
  local name = self:getNode("name")
  name:setText(petName)
  name:setColor(color)
  local level = self:getNode("level")
  level:setText(string.format("%d转%d级", zs, lv))
  local skillbox = self:getNode("skillbox")
  skillbox:setVisible(false)
  local p = skillbox:getParent()
  local x, y = skillbox:getPosition()
  self.m_SkillBord = CSSSkill_Board.new(self.petObj, {
    clickListener = handler(self, self.OnSelectSkill)
  })
  p:addChild(self.m_SkillBord)
  self.m_SkillBord:setPosition(ccp(x, y))
  self:getNode("text_cost"):setText(string.format("%d万", math.floor(data_Variables.SS_Skill_CostCoin) / 10000))
  self:getNode("text_cost_qm"):setText(string.format("%d万", math.floor(data_Variables.SS_Skill_CostCloseV / 10000)))
  self:ListenMessage(MsgID_PlayerInfo)
end
function CSSSkill_learn:OnMessage(msgSID, ...)
  if msgSID == MsgID_PetUpdate then
    local arg = {
      ...
    }
    local d = arg[1]
    if d.petId == self.m_PetId then
      local proTable = d.pro
      if (proTable[PROPERTY_PETSKILLS] ~= nil or proTable[PROPERTY_SSSKILLS] ~= nil) and self.m_SelectSkillId ~= nil then
        self:LoadSkillInfo(self.m_SelectSkillId)
      end
    end
  end
end
function CSSSkill_learn:Btn_Close()
  self:CloseSelf()
end
function CSSSkill_learn:Btn_Study()
  if self.m_SelectSkillId == nil then
    return
  end
  if self.petObj:hasLearnPetSkill(self.m_SelectSkillId) then
    ShowNotifyTips("你的神兽已经学会此技能")
    return
  end
  local petSkills = self.petObj:getProperty(PROPERTY_PETSKILLS)
  if type(petSkills) ~= "table" then
    petSkills = {}
  end
  local noOpenFlag = false
  local noLearnFlag = false
  for index = 1, 3 do
    local d = petSkills[index]
    if d == nil then
      d = PETSKILL_LOCKED
    end
    if d == PETSKILL_CLOSED or d == PETSKILL_LOCKED then
      noOpenFlag = true
    elseif d == PETSKILL_NONESKILL then
      noLearnFlag = true
    end
  end
  if noOpenFlag then
    ShowNotifyTips("你的神兽前三个技能栏还没有全部开启")
    return
  end
  if noLearnFlag then
    ShowNotifyTips("你的神兽前三个技能栏还没有学满")
    return
  end
  local ssSkills = self.petObj:getProperty(PROPERTY_SSSKILLS)
  if type(ssSkills) ~= "table" then
    ssSkills = {}
  end
  local d = ssSkills[1]
  if d == nil then
    d = PETSKILL_LOCKED
  end
  if d == PETSKILL_LOCKED or d == PETSKILL_CLOSED then
    ShowNotifyTips("你的神兽技能专属栏还没有解封")
    return
  end
  if d > 0 then
    ShowNotifyTips("神兽技能只能学习一个")
    return
  end
  local closev = self.petObj:getProperty(PROPERTY_CLOSEVALUE)
  if closev < data_Variables.SS_Skill_CostCloseV then
    ShowNotifyTips(string.format("你的神兽亲密度不足%d万", math.floor(data_Variables.SS_Skill_CostCloseV / 10000)))
    return
  end
  local petName = self.petObj:getProperty(PROPERTY_NAME)
  local zs = self.petObj:getProperty(PROPERTY_ZHUANSHENG)
  local color = NameColor_Pet[zs] or ccc3(255, 255, 255)
  local skillName = data_getSkillName(self.m_SelectSkillId)
  local confirmBoxDlg = CPopWarning.new({
    title = "提示",
    text = string.format("是否同意#<r:%d,g:%d,b:%d>%s#学习神兽技能#<R>%s#?", color.r, color.g, color.b, petName, skillName),
    confirmFunc = function()
      self:OnLearnSkill(self.m_SelectSkillId, petName, color)
    end,
    confirmText = "确定",
    cancelText = "取消",
    align = CRichText_AlignType_Left
  })
end
function CSSSkill_learn:OnLearnSkill(ssSkill, petName, color)
  local skills = self.petObj:getProperty(PROPERTY_PETSKILLS)
  if type(skills) ~= "table" then
    skills = {}
  end
  skills = DeepCopyTable(skills)
  local ssskills = self.petObj:getProperty(PROPERTY_SSSKILLS)
  if type(ssskills) == "table" then
    for _, d in pairs(ssskills) do
      skills[#skills + 1] = d
    end
  end
  local xlSkills = self.petObj:getProperty(PROPERTY_ZJSKILLSEXP)
  if type(xlSkills) ~= "table" then
    xlSkills = {}
  end
  local categoryId = data_getSkillCategoryId(ssSkill)
  local fgSkill
  for index, d in pairs(skills) do
    if d > 0 then
      if d == ssSkill then
        ShowNotifyTips(string.format("你的#<r:%d,g:%d,b:%d>%s#已有相同的技能", color.r, color.g, color.b, petName))
        return
      end
      if data_getSkillCategoryId(d) == categoryId and categoryId > 0 and xlSkills[d] == nil then
        fgSkill = d
      end
    end
  end
  if fgSkill ~= nil then
    local skillName = data_getSkillName(ssSkill)
    local fgskillName = data_getSkillName(fgSkill)
    local tip = string.format("你此时学习的#<R>%s#技能将会覆盖#<R>%s#等技能的效果，你确定要学习吗？", skillName, fgskillName)
    CPopWarning.new({
      title = "提示",
      text = tip,
      confirmFunc = function()
        netsend.netbaseptc.requestLearnSSSkill(self.m_PetId, ssSkill)
      end,
      confirmText = "确定",
      cancelText = "取消",
      align = CRichText_AlignType_Left
    })
  else
    netsend.netbaseptc.requestLearnSSSkill(self.m_PetId, ssSkill)
  end
end
function CSSSkill_learn:OnSelectSkill(skillId)
  if self.m_SelectSkillId == skillId then
    return
  end
  self.m_SelectSkillId = skillId
  self:LoadSkillInfo(skillId)
end
function CSSSkill_learn:LoadSkillInfo(skillId)
  local skillName = data_getSkillName(skillId)
  self:getNode("title_skill"):setText(skillName)
  if self.m_DescBox ~= nil then
    self.m_DescBox:removeFromParent()
    self.m_DescBox = nil
  end
  local p = self.descbox:getParent()
  local x, y = self.descbox:getPosition()
  local descSize = self.descbox:getSize()
  self.m_DescBox = CRichText.new({
    width = descSize.width,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 20,
    color = ccc3(255, 255, 255)
  })
  p:addChild(self.m_DescBox, 10)
  local desc = ""
  if self.petObj:hasLearnPetSkill(skillId) then
    desc = GetSkillDesString(self.petObj, skillId)
  else
    local skillType = _getSkillStyle(skillId)
    if skillType == SKILLSTYLE_INITIATIVE then
      desc = desc .. "【类型】主动\n"
    else
      desc = desc .. "【类型】被动\n"
    end
    local skillDesc = data_getPetSkillWbDesc(skillId)
    desc = desc .. skillDesc
  end
  self.m_DescBox:addRichText(desc)
  local rsize = self.m_DescBox:getRichTextSize()
  self.m_DescBox:setPosition(ccp(x, y + descSize.height - rsize.height))
  if self.petObj:hasLearnPetSkill(skillId) then
    self:getNode("hidelayer"):setEnabled(false)
    self.btn_study:setTitleText("已学习")
  else
    self:getNode("hidelayer"):setEnabled(true)
    self.btn_study:setTitleText("学习技能")
  end
end
function CSSSkill_learn:Clear()
  self.petObj = nil
end
function ShowSSSKillLearnDlg(petId)
  local petObj = g_LocalPlayer:getObjById(petId)
  if petObj == nil then
    ShowNotifyTips("该召唤兽不存在")
  else
    getCurSceneView():addSubView({
      subView = CSSSkill_learn.new(petId, petObj),
      zOrder = MainUISceneZOrder.menuView
    })
  end
end
