local CPetList_BaseSkillLearn_OpenSkillPos = class(".CPetList_BaseSkillLearn_OpenSkillPos", CcsSubView)
function CPetList_BaseSkillLearn_OpenSkillPos:ctor(petIns, ssFlag, num, flag)
  CPetList_BaseSkillLearn_OpenSkillPos.super.ctor(self, "views/petlist_openskillpos.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Cancel),
      variName = "btn_cancel"
    },
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_confirm"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_PetId = petIns:getObjId()
  self.m_ssFlag = ssFlag
  self.m_FuncFlag = flag
  self.m_Num = num
  local itemTypeId
  if flag == 0 then
    itemTypeId = ITEM_DEF_OTHER_JFS
  else
    itemTypeId = ITEM_DEF_OTHER_LYF
  end
  self.m_ItemTypeId = itemTypeId
  local itemPj = data_getItemPinjie(self.m_ItemTypeId)
  local textColor = NameColor_Item[itemPj] or NameColor_Item[0]
  local itemName = data_getItemName(itemTypeId)
  self:getNode("title"):setText(itemName)
  self:getNode("title"):setColor(textColor)
  local iconpos = self:getNode("iconpos")
  iconpos:setVisible(false)
  local p = iconpos:getParent()
  local x, y = iconpos:getPosition()
  local itemIcon = createClickItem({
    itemID = itemTypeId,
    clickListener = handler(self, self.OnClickItem),
    num = num,
    numType = 1
  })
  p:addChild(itemIcon)
  itemIcon:setPosition(ccp(x, y))
  self.m_ItemIcon = itemIcon
  local tip = self:getNode("tip")
  tip:setVisible(false)
  local p = tip:getParent()
  local size = tip:getContentSize()
  local x, y = tip:getPosition()
  local tipBox = CRichText.new({
    width = size.width,
    color = ccc3(255, 255, 255),
    fontSize = 20
  })
  p:addChild(tipBox)
  local petName = petIns:getProperty(PROPERTY_NAME)
  local zs = petIns:getProperty(PROPERTY_ZHUANSHENG)
  local namecolor = NameColor_Pet[zs] or ccc3(255, 255, 255)
  local text = string.format("你确定要对#<r:%d,g:%d,b:%d>%s#使用吗？", namecolor.r, namecolor.g, namecolor.b, petName)
  tipBox:addRichText(text)
  local tipBoxSize = tipBox:getRealRichTextSize()
  tipBox:setPosition(ccp(x, y + size.height - tipBoxSize.height))
  self:setVisible(false)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setVisible(false)
  end
  local act1 = CCDelayTime:create(0.1)
  local act2 = CCCallFunc:create(function()
    self:setVisible(true)
    if self._auto_create_opacity_bg_ins then
      self._auto_create_opacity_bg_ins:setVisible(true)
    end
  end)
  self:runAction(transition.sequence({act1, act2}))
  self:ListenMessage(MsgID_MoveScene)
  self:ListenMessage(MsgID_ItemInfo)
end
function CPetList_BaseSkillLearn_OpenSkillPos:OnClickItem()
  self.m_PopItemDetail = CEquipDetail.new(nil, {
    closeListener = handler(self, self.CloseItemDetail),
    itemType = self.m_ItemTypeId
  })
  getCurSceneView():addSubView({
    subView = self.m_PopItemDetail,
    zOrder = MainUISceneZOrder.menuView
  })
  self.m_PopItemDetail:ShowCloseBtn()
  local size = self.m_PopItemDetail:getBoxSize()
  self.m_PopItemDetail:setPosition(ccp(display.width / 2 - size.width / 2, display.height / 2 - size.height / 2))
end
function CPetList_BaseSkillLearn_OpenSkillPos:OnBtn_Close()
  self:CloseSelf()
end
function CPetList_BaseSkillLearn_OpenSkillPos:OnBtn_Cancel()
  self:CloseSelf()
end
function CPetList_BaseSkillLearn_OpenSkillPos:OnBtn_Confirm()
  if self.m_FuncFlag == 0 then
    netsend.netbaseptc.requestOpenSkillPos(self.m_PetId, self.m_ssFlag)
  else
    netsend.netbaseptc.requestUnlockSkillPos(self.m_PetId, self.m_ssFlag)
  end
  self:CloseSelf()
end
function CPetList_BaseSkillLearn_OpenSkillPos:showPetList(iShow)
  self:SetShow(iShow)
  if g_PetListDlg then
    g_PetListDlg:SetShow(iShow)
  end
end
function CPetList_BaseSkillLearn_OpenSkillPos:SetShow(iShow)
  if self.m_UINode ~= nil then
    self:setVisible(iShow)
    if self._auto_create_opacity_bg_ins then
      self._auto_create_opacity_bg_ins:setVisible(iShow)
    end
  end
end
function CPetList_BaseSkillLearn_OpenSkillPos:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ItemSource_Jump then
    self:CloseItemDetail()
    local d = arg[1][1]
    for _, t in pairs(Item_Source_MoveMapList) do
      if d == t then
        self:CloseSelf()
        break
      end
    end
  elseif msgSID == MsgID_ItemInfo_AddItem then
    if self.m_ItemTypeId == arg[3] then
      self:updateItemNum()
    end
  elseif msgSID == MsgID_ItemInfo_DelItem then
    if self.m_ItemTypeId == arg[2] then
      self:updateItemNum()
    end
  elseif msgSID == MsgID_ItemInfo_ChangeItemNum and self.m_ItemTypeId == arg[3] then
    self:updateItemNum()
  end
end
function CPetList_BaseSkillLearn_OpenSkillPos:updateItemNum()
  local myNum = g_LocalPlayer:GetItemNum(self.m_ItemTypeId)
  self.m_ItemIcon._numLabel:setString(string.format("%d/%d", myNum, self.m_Num))
  if myNum < self.m_Num then
    self.m_ItemIcon._numLabel:setColor(ccc3(255, 0, 0))
  else
    self.m_ItemIcon._numLabel:setColor(ccc3(0, 255, 0))
  end
  AutoLimitObjSize(self.m_ItemIcon._numLabel, 70)
end
function CPetList_BaseSkillLearn_OpenSkillPos:CloseItemDetail()
  if self.m_PopItemDetail then
    self.m_PopItemDetail:CloseSelf()
    self.m_PopItemDetail = nil
  end
end
function CPetList_BaseSkillLearn_OpenSkillPos:Clear()
  self:CloseItemDetail()
end
CPetList_BaseSkillLearn = class(".CPetList_BaseSkillLearn", CcsSubView)
function CPetList_BaseSkillLearn:ctor(petId)
  CPetList_BaseSkillLearn.super.ctor(self, "views/pet_list_petskill.json")
  local btnBatchListener = {
    btn_zhiyuan = {
      listener = handler(self, self.OnBtn_ZhiYuan),
      variName = "btn_zhiyuan"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_PetId = nil
  self.m_SkillIcon = {}
  self.skillpos_1 = self:getNode("skillpos_1")
  self.skillpos_2 = self:getNode("skillpos_2")
  self.skillpos_1:setVisible(false)
  self.skillpos_2:setVisible(false)
  self:LoadPet(petId)
  self:ListenMessage(MsgID_PlayerInfo)
end
function CPetList_BaseSkillLearn:LoadPet(petId)
  if self.m_PetId == petId then
    return
  end
  self.m_PetId = petId
  self.m_PetIns = g_LocalPlayer:getObjById(self.m_PetId)
  self:SetBaseSkill()
end
function CPetList_BaseSkillLearn:SetBaseSkill()
  if self.m_PetIns == nil then
    return
  end
  for _, skillIcon in pairs(self.m_SkillIcon) do
    skillIcon:removeFromParentAndCleanup(true)
  end
  self.m_SkillIcon = {}
  local coverTable = {}
  local petTypeId = self.m_PetIns:getTypeId()
  local levelType = data_getPetLevelType(petTypeId)
  if data_getPetTypeIsHasShenShouSkill(petTypeId) then
    local ssPetSkills = self.m_PetIns:getProperty(PROPERTY_SSSKILLS)
    if type(ssPetSkills) ~= "table" then
      ssPetSkills = {}
    end
    local xlSkills = self.m_PetIns:getProperty(PROPERTY_ZJSKILLSEXP)
    if type(xlSkills) ~= "table" then
      xlSkills = {}
    end
    for index = #ssPetSkills, 1, -1 do
      do
        local d = ssPetSkills[index]
        if d == nil then
          d = PETSKILL_LOCKED
        end
        local skillIcon
        if d > 0 then
          local skillId = d
          local categoryId = data_getSkillCategoryId(skillId)
          grayFlag = false
          if categoryId > 0 and xlSkills[d] == nil and coverTable[categoryId] ~= nil then
            grayFlag = true
          end
          local _checkFlag = self:_checkSkillGGLXMJLL(skillId)
          if _checkFlag ~= true then
            grayFlag = true
          end
          if categoryId > 0 and xlSkills[d] == nil then
            coverTable[categoryId] = true
          end
          skillIcon = createClickSkill({
            roleID = self.m_PetId,
            skillID = skillId,
            LongPressTime = 0.2,
            imgFlag = true,
            grayFlag = grayFlag,
            delBtnFlag = true,
            xlFlag = xlSkills[d] ~= nil
          })
          local iconTxt
          if _checkFlag == SIXING_LACK_LILIANG then
            iconTxt = ui.newTTFLabel({
              text = "力量\n不足",
              size = 20,
              font = KANG_TTF_FONT,
              color = ccc3(255, 0, 0)
            })
          elseif _checkFlag == SIXING_LACK_GENGU then
            iconTxt = ui.newTTFLabel({
              text = "根骨\n不足",
              size = 20,
              font = KANG_TTF_FONT,
              color = ccc3(255, 0, 0)
            })
          elseif _checkFlag == SIXING_LACK_LINGXING then
            iconTxt = ui.newTTFLabel({
              text = "灵性\n不足",
              size = 20,
              font = KANG_TTF_FONT,
              color = ccc3(255, 0, 0)
            })
          elseif _checkFlag == SIXING_LACK_MINJIE then
            iconTxt = ui.newTTFLabel({
              text = "敏捷\n不足",
              size = 20,
              font = KANG_TTF_FONT,
              color = ccc3(255, 0, 0)
            })
          elseif _checkFlag == WUXING_LACK_JIN then
            iconTxt = ui.newTTFLabel({
              text = "五行金\n不足",
              size = 20,
              font = KANG_TTF_FONT,
              color = ccc3(255, 0, 0)
            })
          elseif _checkFlag == WUXING_LACK_MU then
            iconTxt = ui.newTTFLabel({
              text = "五行木\n不足",
              size = 20,
              font = KANG_TTF_FONT,
              color = ccc3(255, 0, 0)
            })
          elseif _checkFlag == WUXING_LACK_SHUI then
            iconTxt = ui.newTTFLabel({
              text = "五行水\n不足",
              size = 20,
              font = KANG_TTF_FONT,
              color = ccc3(255, 0, 0)
            })
          elseif _checkFlag == WUXING_LACK_HUO then
            iconTxt = ui.newTTFLabel({
              text = "五行火\n不足",
              size = 20,
              font = KANG_TTF_FONT,
              color = ccc3(255, 0, 0)
            })
          elseif _checkFlag == WUXING_LACK_TU then
            iconTxt = ui.newTTFLabel({
              text = "五行土\n不足",
              size = 20,
              font = KANG_TTF_FONT,
              color = ccc3(255, 0, 0)
            })
          end
          if iconTxt then
            local size = skillIcon:getSize()
            skillIcon:addNode(iconTxt, 99)
            iconTxt:setPosition(ccp(size.width / 2, size.height / 2))
          end
        elseif d == PETSKILL_NONESKILL then
          skillIcon = createClickButton("views/rolelist/pic_skill_open.png", nil, function()
            self:OnClickOpenSSSkillPos(index)
          end, nil, nil, true)
        elseif d == PETSKILL_CLOSED then
          skillIcon = createClickButton("views/rolelist/pic_skill_closed.png", nil, function()
            self:OnClickClosedSSSkillPos(index)
          end, nil, nil, true)
        else
          skillIcon = createClickButton("views/rolelist/pic_skill_locked.png", nil, function()
            self:OnClickLockedSSSkillPos(index)
          end, nil, nil, true)
        end
        table.insert(self.m_SkillIcon, 1, skillIcon)
        local size = skillIcon:getSize()
        local leftPart = display.newSprite("views/rolelist/pic_ssicon.png")
        leftPart:setAnchorPoint(ccp(1, 0))
        skillIcon:addNode(leftPart, 99)
        leftPart:setPosition(ccp(size.width / 2 - 1, 0))
        local size = skillIcon:getSize()
        local rightPart = display.newSprite("views/rolelist/pic_ssicon.png")
        rightPart:setAnchorPoint(ccp(1, 0))
        rightPart:setScaleX(-1)
        skillIcon:addNode(rightPart, 99)
        rightPart:setPosition(ccp(size.width / 2 + 1, 0))
      end
    end
  end
  local normalPetSkills = self.m_PetIns:getProperty(PROPERTY_PETSKILLS)
  if type(normalPetSkills) ~= "table" then
    normalPetSkills = {}
  end
  local xlSkills = self.m_PetIns:getProperty(PROPERTY_ZJSKILLSEXP)
  if type(xlSkills) ~= "table" then
    xlSkills = {}
  end
  for index = #normalPetSkills, 1, -1 do
    do
      local d = normalPetSkills[index]
      if d == nil then
        d = PETSKILL_LOCKED
      end
      local skillIcon
      if d > 0 then
        local skillId = d
        local categoryId = data_getSkillCategoryId(skillId)
        grayFlag = false
        if categoryId > 0 and xlSkills[d] == nil and coverTable[categoryId] ~= nil then
          grayFlag = true
        end
        local _checkFlag = self:_checkSkillGGLXMJLL(skillId)
        if _checkFlag ~= true then
          grayFlag = true
        end
        if categoryId > 0 and xlSkills[d] == nil then
          coverTable[categoryId] = true
        end
        skillIcon = createClickSkill({
          roleID = self.m_PetId,
          skillID = skillId,
          LongPressTime = 0.2,
          imgFlag = true,
          grayFlag = grayFlag,
          delBtnFlag = true,
          xlFlag = xlSkills[d] ~= nil
        })
        local iconTxt
        if _checkFlag == SIXING_LACK_LILIANG then
          iconTxt = ui.newTTFLabel({
            text = "力量\n不足",
            size = 20,
            font = KANG_TTF_FONT,
            color = ccc3(255, 0, 0)
          })
        elseif _checkFlag == SIXING_LACK_GENGU then
          iconTxt = ui.newTTFLabel({
            text = "根骨\n不足",
            size = 20,
            font = KANG_TTF_FONT,
            color = ccc3(255, 0, 0)
          })
        elseif _checkFlag == SIXING_LACK_LINGXING then
          iconTxt = ui.newTTFLabel({
            text = "灵性\n不足",
            size = 20,
            font = KANG_TTF_FONT,
            color = ccc3(255, 0, 0)
          })
        elseif _checkFlag == SIXING_LACK_MINJIE then
          iconTxt = ui.newTTFLabel({
            text = "敏捷\n不足",
            size = 20,
            font = KANG_TTF_FONT,
            color = ccc3(255, 0, 0)
          })
        elseif _checkFlag == WUXING_LACK_JIN then
          iconTxt = ui.newTTFLabel({
            text = "五行金\n不足",
            size = 20,
            font = KANG_TTF_FONT,
            color = ccc3(255, 0, 0)
          })
        elseif _checkFlag == WUXING_LACK_MU then
          iconTxt = ui.newTTFLabel({
            text = "五行木\n不足",
            size = 20,
            font = KANG_TTF_FONT,
            color = ccc3(255, 0, 0)
          })
        elseif _checkFlag == WUXING_LACK_SHUI then
          iconTxt = ui.newTTFLabel({
            text = "五行水\n不足",
            size = 20,
            font = KANG_TTF_FONT,
            color = ccc3(255, 0, 0)
          })
        elseif _checkFlag == WUXING_LACK_HUO then
          iconTxt = ui.newTTFLabel({
            text = "五行火\n不足",
            size = 20,
            font = KANG_TTF_FONT,
            color = ccc3(255, 0, 0)
          })
        elseif _checkFlag == WUXING_LACK_TU then
          iconTxt = ui.newTTFLabel({
            text = "五行土\n不足",
            size = 20,
            font = KANG_TTF_FONT,
            color = ccc3(255, 0, 0)
          })
        end
        if iconTxt then
          local size = skillIcon:getSize()
          skillIcon:addNode(iconTxt, 99)
          iconTxt:setPosition(ccp(size.width / 2, size.height / 2))
        end
      elseif d == PETSKILL_NONESKILL then
        skillIcon = createClickButton("views/rolelist/pic_skill_open.png", nil, function()
          self:OnClickOpenSkillPos(index)
        end, nil, nil, true)
      elseif d == PETSKILL_CLOSED then
        skillIcon = createClickButton("views/rolelist/pic_skill_closed.png", nil, function()
          self:OnClickClosedSkillPos(index)
        end, nil, nil, true)
      else
        skillIcon = createClickButton("views/rolelist/pic_skill_locked.png", nil, function()
          self:OnClickLockedSkillPos(index)
        end, nil, nil, true)
      end
      table.insert(self.m_SkillIcon, 1, skillIcon)
    end
  end
  for index, skillIcon in ipairs(self.m_SkillIcon) do
    local row = math.floor((index - 1) / 5) + 1
    local col = (index - 1) % 5 + 1
    local posObj = self["skillpos_" .. tostring(row)]
    local px, py = posObj:getPosition()
    local parent = posObj:getParent()
    local zOrder = posObj:getZOrder()
    parent:addChild(skillIcon, zOrder)
    px = px + 85 * (col - 1)
    skillIcon:setPosition(ccp(px, py))
  end
end
function CPetList_BaseSkillLearn:_checkSkillGGLXMJLL(skillID)
  local gg, lx, mj, ll = data_getGGLXMJLL(skillID)
  if gg > 0 then
    local ugg = self.m_PetIns:getProperty(PROPERTY_GenGu)
    if gg > ugg then
      return SIXING_LACK_GENGU
    end
  end
  if lx > 0 then
    local ulx = self.m_PetIns:getProperty(PROPERTY_Lingxing)
    if lx > ulx then
      return SIXING_LACK_LINGXING
    end
  end
  if mj > 0 then
    local umj = self.m_PetIns:getProperty(PROPERTY_MinJie)
    if mj > umj then
      return SIXING_LACK_MINJIE
    end
  end
  if ll > 0 then
    local ull = self.m_PetIns:getProperty(PROPERTY_LiLiang)
    if ll > ull then
      return SIXING_LACK_LILIANG
    end
  end
  local jin, mu, shui, huo, tu = data_getSkillWuXingRequire(skillID)
  if jin > 0 then
    local ujin = self.m_PetIns:getProperty(PROPERTY_WXJIN)
    if jin > ujin then
      return WUXING_LACK_JIN
    end
  end
  if mu > 0 then
    local umu = self.m_PetIns:getProperty(PROPERTY_WXMU)
    if mu > umu then
      return WUXING_LACK_MU
    end
  end
  if shui > 0 then
    local ushui = self.m_PetIns:getProperty(PROPERTY_WXSHUI)
    if shui > ushui then
      return WUXING_LACK_SHUI
    end
  end
  if huo > 0 then
    local uhuo = self.m_PetIns:getProperty(PROPERTY_WXHUO)
    if huo > uhuo then
      return WUXING_LACK_HUO
    end
  end
  if tu > 0 then
    local utu = self.m_PetIns:getProperty(PROPERTY_WXTU)
    if tu > utu then
      return WUXING_LACK_TU
    end
  end
  return true
end
function CPetList_BaseSkillLearn:OnOpenSkillPos(index, num, ssFlag, judgePre)
  if index > 1 and judgePre then
    local petSkills = self.m_PetIns:getProperty(PROPERTY_PETSKILLS)
    if ssFlag == 1 then
      petSkills = self.m_PetIns:getProperty(PROPERTY_SSSKILLS)
    end
    if type(petSkills) ~= "table" then
      petSkills = {}
    end
    local pre = petSkills[index - 1]
    if pre == nil then
      pre = PETSKILL_LOCKED
    end
    if pre == PETSKILL_NONESKILL then
      ShowNotifyTips("前一个技能栏还未学习技能，无法开启")
      return
    elseif pre == PETSKILL_CLOSED then
      ShowNotifyTips("前一个技能栏还未解封，无法开启")
      return
    elseif pre == PETSKILL_LOCKED then
      ShowNotifyTips("前一个技能格还未获得，无法开启")
      return
    end
  end
  local dlg = CPetList_BaseSkillLearn_OpenSkillPos.new(self.m_PetIns, ssFlag, num, 0)
  getCurSceneView():addSubView({
    subView = dlg,
    zOrder = MainUISceneZOrder.menuView
  })
end
function CPetList_BaseSkillLearn:OnUnLockSkillPos(index, num, ssFlag, judgePre)
  if index > 1 and judgePre then
    local petSkills = self.m_PetIns:getProperty(PROPERTY_PETSKILLS)
    if ssFlag == 1 then
      petSkills = self.m_PetIns:getProperty(PROPERTY_SSSKILLS)
    end
    if type(petSkills) ~= "table" then
      petSkills = {}
    end
    local pre = petSkills[index - 1]
    if pre == nil then
      pre = PETSKILL_LOCKED
    end
    if pre == PETSKILL_NONESKILL then
      ShowNotifyTips("前一个技能栏还未学习技能，无法开启")
      return
    elseif pre == PETSKILL_CLOSED then
      ShowNotifyTips("前一个技能栏还未解封，无法开启")
      return
    elseif pre == PETSKILL_LOCKED then
      ShowNotifyTips("前一个技能格还未获得，无法开启")
      return
    end
  end
  local dlg = CPetList_BaseSkillLearn_OpenSkillPos.new(self.m_PetIns, ssFlag, num, 1)
  getCurSceneView():addSubView({
    subView = dlg,
    zOrder = MainUISceneZOrder.menuView
  })
end
function CPetList_BaseSkillLearn:OnUseItem_JFS()
  if self.m_PetIns == nil then
    return
  end
  local petSkills = self.m_PetIns:getProperty(PROPERTY_PETSKILLS)
  if type(petSkills) ~= "table" then
    petSkills = {}
  end
  for index, d in pairs(petSkills) do
    if d == PETSKILL_CLOSED then
      self:OnClickClosedSkillPos(index, false)
      return
    end
  end
  local ssSkills = self.m_PetIns:getProperty(PROPERTY_SSSKILLS)
  if type(ssSkills) ~= "table" then
    ssSkills = {}
  end
  for index, d in pairs(ssSkills) do
    if d == PETSKILL_CLOSED then
      self:OnClickClosedSSSkillPos(index, false)
      return
    end
  end
  local name = self.m_PetIns:getProperty(PROPERTY_NAME)
  local zs = self.m_PetIns:getProperty(PROPERTY_ZHUANSHENG)
  local nameColor = NameColor_Pet[zs] or ccc3(255, 255, 255)
  local itemName = data_getItemName(ITEM_DEF_OTHER_JFS)
  ShowNotifyTips(string.format("#<r:%d,g:%d,b:%d>%s#没有需要解封的技能栏，使用#<CI:%d>%s#失败", nameColor.r, nameColor.g, nameColor.b, name, ITEM_DEF_OTHER_JFS, itemName))
end
function CPetList_BaseSkillLearn:OnUseItem_LYF()
  if self.m_PetIns == nil then
    return
  end
  local petSkills = self.m_PetIns:getProperty(PROPERTY_PETSKILLS)
  if type(petSkills) ~= "table" then
    petSkills = {}
  end
  for index, d in pairs(petSkills) do
    if d == PETSKILL_LOCKED then
      self:OnClickLockedSkillPos(index, false)
      return
    end
  end
  local ssSkills = self.m_PetIns:getProperty(PROPERTY_SSSKILLS)
  if type(ssSkills) ~= "table" then
    ssSkills = {}
  end
  for index, d in pairs(ssSkills) do
    if d == PETSKILL_LOCKED then
      self:OnClickLockedSSSkillPos(index, false)
      return
    end
  end
  local name = self.m_PetIns:getProperty(PROPERTY_NAME)
  local zs = self.m_PetIns:getProperty(PROPERTY_ZHUANSHENG)
  local nameColor = NameColor_Pet[zs] or ccc3(255, 255, 255)
  local itemName = data_getItemName(ITEM_DEF_OTHER_LYF)
  ShowNotifyTips(string.format("#<r:%d,g:%d,b:%d>%s#没有需要解锁的技能格，使用#<CI:%d>%s#失败", nameColor.r, nameColor.g, nameColor.b, name, ITEM_DEF_OTHER_LYF, itemName))
end
function CPetList_BaseSkillLearn:OnClickOpenSkillPos(index)
  ShowNotifyTips("通过学习技能和战斗领悟可获得技能")
end
function CPetList_BaseSkillLearn:OnClickClosedSkillPos(index, judgePre)
  if self.m_PetIns == nil then
    return
  end
  if judgePre == nil then
    judgePre = true
  end
  if index > 1 and judgePre then
    local petSkills = self.m_PetIns:getProperty(PROPERTY_PETSKILLS)
    if type(petSkills) ~= "table" then
      petSkills = {}
    end
    local pre = petSkills[index - 1]
    if pre == nil then
      pre = PETSKILL_LOCKED
    end
    if pre == PETSKILL_NONESKILL then
      ShowNotifyTips("前一个技能栏还未学习技能，无法开启")
      return
    elseif pre == PETSKILL_CLOSED then
      ShowNotifyTips("前一个技能栏还未解封，无法开启")
      return
    elseif pre == PETSKILL_LOCKED then
      ShowNotifyTips("前一个技能格还未获得，无法开启")
      return
    end
  end
  local title = "技能格(封印)"
  local num = data_getUnFengYinSkillPosCost(index)
  local itemName = data_getItemName(ITEM_DEF_OTHER_JFS)
  local text = string.format("解封技能格方式:\n#<F:20,W>1、战斗有几率开启(非玩家间的战斗)\n2、使用##<CI:%d,F:20>%s##<F:20,W>x%d个开启#", ITEM_DEF_OTHER_JFS, itemName, num)
  if num <= 0 then
    text = "解封技能格方式:\n#<F:20,W>1、战斗有几率开启(非玩家间的战斗)\n#"
  end
  local confirmText = "道具开启"
  local cancelText = "取消"
  local function confirmFunc()
    self:OnOpenSkillPos(index, num, nil, not judgePre)
  end
  local confirmBoxDlg = CPopWarning.new({
    title = title,
    text = text,
    confirmFunc = confirmFunc,
    confirmText = confirmText,
    cancelText = cancelText,
    align = CRichText_AlignType_Left,
    fontSize = 23
  })
end
function CPetList_BaseSkillLearn:OnClickLockedSkillPos(index, judgePre)
  if self.m_PetIns == nil then
    return
  end
  if judgePre == nil then
    judgePre = true
  end
  if index > 1 and judgePre then
    local petSkills = self.m_PetIns:getProperty(PROPERTY_PETSKILLS)
    if type(petSkills) ~= "table" then
      petSkills = {}
    end
    local pre = petSkills[index - 1]
    if pre == nil then
      pre = PETSKILL_LOCKED
    end
    if pre == PETSKILL_NONESKILL then
      ShowNotifyTips("前一个技能栏还未学习技能，无法开启")
      return
    elseif pre == PETSKILL_CLOSED then
      ShowNotifyTips("前一个技能栏还未解封，无法开启")
      return
    elseif pre == PETSKILL_LOCKED then
      ShowNotifyTips("前一个技能格还未获得，无法开启")
      return
    end
  end
  local title = "技能格(未获得)"
  local num = data_getUnLockSkillPosCost(index)
  local itemName = data_getItemName(ITEM_DEF_OTHER_LYF)
  local text = string.format("获得技能格方式:\n#<F:20,W>使用##<CI:%d,F:20>%s##<F:20,W>x%d解锁技能格#", ITEM_DEF_OTHER_LYF, itemName, num)
  if num <= 0 then
    text = ""
  end
  local confirmText = "道具开启"
  local cancelText = "取消"
  local function confirmFunc()
    self:OnUnLockSkillPos(index, num, nil, not judgePre)
  end
  local confirmBoxDlg = CPopWarning.new({
    title = title,
    text = text,
    confirmFunc = confirmFunc,
    confirmText = confirmText,
    cancelText = cancelText,
    align = CRichText_AlignType_Left,
    fontSize = 23
  })
  confirmBoxDlg:setTitleColor(ccc3(255, 0, 0))
end
function CPetList_BaseSkillLearn:OnClickOpenSSSkillPos(index)
  ShowNotifyTips("向天宫神兽仙子请教可习得神兽技能")
end
function CPetList_BaseSkillLearn:OnClickClosedSSSkillPos(index, judgePre)
  if self.m_PetIns == nil then
    return
  end
  if judgePre == nil then
    judgePre = true
  end
  if index > 1 and judgePre then
    local petSkills = self.m_PetIns:getProperty(PROPERTY_SSSKILLS)
    if type(petSkills) ~= "table" then
      petSkills = {}
    end
    local pre = petSkills[index - 1]
    if pre == nil then
      pre = PETSKILL_LOCKED
    end
    if pre == PETSKILL_NONESKILL then
      ShowNotifyTips("前一个技能栏还未学习技能，不能开启")
      return
    elseif pre == PETSKILL_CLOSED then
      ShowNotifyTips("前一个技能栏还未解封，不能开启")
      return
    elseif pre == PETSKILL_LOCKED then
      ShowNotifyTips("前一个技能格还未获得，不能开启")
      return
    end
  end
  local title = "神兽技能格(封印)"
  local num = data_getUnFengYinSSSkillPosCost(index)
  local itemName = data_getItemName(ITEM_DEF_OTHER_JFS)
  local text = string.format("解封技能格方式:\n#<F:19,W>1、战斗有几率开启(非玩家间的战斗)\n2、使用##<CI:%d,F:19>%s##<F:19,W>x%d个开启(开启后可去天宫神兽仙子处学习神兽技能)\n\n##<IRP,F:18,W> 此为神兽技能专属格,只能学习神兽技能#", ITEM_DEF_OTHER_JFS, itemName, num)
  if num <= 0 then
    text = "解封技能格方式:\n#<F:19,W>1、战斗有几率开启(非玩家间的战斗)\n2、开启后可去天宫神兽仙子处学习神兽技能\n\n##<IRP,F:18,W> 此为神兽技能专属格,只能学习神兽技能#"
  end
  local confirmText = "现在开启"
  local cancelText = "取消"
  local function confirmFunc()
    self:OnOpenSkillPos(index, num, 1, not judgePre)
  end
  local confirmBoxDlg = CPopWarning.new({
    title = title,
    text = text,
    confirmFunc = confirmFunc,
    confirmText = confirmText,
    cancelText = cancelText,
    align = CRichText_AlignType_Left,
    fontSize = 22
  })
end
function CPetList_BaseSkillLearn:OnClickLockedSSSkillPos(index, judgePre)
  if self.m_PetIns == nil then
    return
  end
  if judgePre == nil then
    judgePre = true
  end
  if index > 1 and judgePre then
    local petSkills = self.m_PetIns:getProperty(PROPERTY_SSSKILLS)
    if type(petSkills) ~= "table" then
      petSkills = {}
    end
    local pre = petSkills[index - 1]
    if pre == nil then
      pre = PETSKILL_LOCKED
    end
    if pre == PETSKILL_NONESKILL then
      ShowNotifyTips("前一个技能栏还未学习技能，不能开启")
      return
    elseif pre == PETSKILL_CLOSED then
      ShowNotifyTips("前一个技能栏还未解封，不能开启")
      return
    elseif pre == PETSKILL_LOCKED then
      ShowNotifyTips("前一个技能格还未获得，不能开启")
      return
    end
  end
  local title = "技能格(未获得)"
  local num = data_getUnLockSSSkillPosCost(index)
  local itemName = data_getItemName(ITEM_DEF_OTHER_LYF)
  local text = string.format("获得技能格方式:\n#<F:20,W>1、每次升级有几率获得封印状态\n2、使用##<CI:%d,F:20>%s##<F:20,W>x%d,获得封印状态#", ITEM_DEF_OTHER_LYF, itemName, num)
  if num <= 0 then
    text = "获得技能格方式:\n#<F:20,W>1、每次升级有几率获得封印状态\n#"
  end
  local confirmText = "现在获得"
  local cancelText = "取消"
  local function confirmFunc()
    self:OnUnLockSkillPos(index, num, 1, not judgePre)
  end
  local confirmBoxDlg = CPopWarning.new({
    title = title,
    text = text,
    confirmFunc = confirmFunc,
    confirmText = confirmText,
    cancelText = cancelText,
    align = CRichText_AlignType_Left,
    fontSize = 23
  })
  confirmBoxDlg:setTitleColor(ccc3(255, 0, 0))
end
function CPetList_BaseSkillLearn:OnMessage(msgSID, ...)
  if msgSID == MsgID_PetUpdate then
    local arg = {
      ...
    }
    local d = arg[1]
    if d.petId == self.m_PetId then
      local proTable = d.pro
      if proTable[PROPERTY_PETSKILLS] ~= nil or proTable[PROPERTY_SSSKILLS] ~= nil or proTable[PROPERTY_ZJSKILLSEXP] or proTable[PROPERTY_GenGu] ~= nil or proTable[PROPERTY_Lingxing] ~= nil or proTable[PROPERTY_MinJie] ~= nil or proTable[PROPERTY_LiLiang] ~= nil then
        self:SetBaseSkill()
      end
    end
  end
end
function CPetList_BaseSkillLearn:OnBtn_ZhiYuan()
  netsend.netteamwar.requestShanXianList()
end
function CPetList_BaseSkillLearn:Clear()
  self.m_PetIns = nil
end
