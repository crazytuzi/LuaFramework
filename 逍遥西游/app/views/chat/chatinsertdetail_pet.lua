CChatInsertDetail_PetIcon = class("CChatInsertDetail_PetIcon", CcsSubView)
function CChatInsertDetail_PetIcon:ctor(petObj, PlayerId, PetId)
  CChatInsertDetail_PetIcon.super.ctor(self, "views/chatinsertdetail_pet.json")
  clickArea_check.extend(self)
  self.m_PlayerId = PlayerId
  self.m_PetId = PetId
  self.petObj = petObj
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
  self.m_RoleAureole = CreateSeqAnimation("xiyou/ani/role_aureole.plist", -1, nil, nil, nil, 6)
  p:addNode(self.m_RoleAureole, z + 1)
  self.m_RoleAureole:setPosition(x + AUREOLE_OFF_X, y + AUREOLE_OFF_Y)
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
  self:LoadPetAttr()
end
function CChatInsertDetail_PetIcon:LoadPetAttr(petTypeId, petInfo)
  local petname = self.petObj:getProperty(PROPERTY_NAME)
  local zs = self.petObj:getProperty(PROPERTY_ZHUANSHENG)
  local lv = self.petObj:getProperty(PROPERTY_ROLELEVEL)
  local color = NameColor_Pet[zs] or ccc3(255, 255, 255)
  local cur_level = string.format("%d转%d级", zs, lv)
  self.pet_name = self:getNode("txt_name")
  self.pet_name:setText(petname)
  self.pet_level = self:getNode("txt_level")
  self.pet_level:setText(cur_level)
  self.pet_name:setColor(color)
  self.neidan_1 = self:getNode("neidan_1")
  self.neidan_1_level = self:getNode("neidan_1_level")
  self.neidan_2 = self:getNode("neidan_2")
  self.neidan_2_level = self:getNode("neidan_2_level")
  self.neidan_3 = self:getNode("neidan_3")
  self.neidan_3_level = self:getNode("neidan_3_level")
  self.m_CurPetIns = g_LocalPlayer:getObjById(self.m_PetId)
  local count_ND = 1
  local itemName, neidan_LV, lv, zs
  local zbList = self.m_CurPetIns:getZhuangBei()
  for itemId, _ in pairs(zbList) do
    local itemIns = g_LocalPlayer:GetOneItem(itemId)
    if itemIns and itemIns:getType() == ITEM_LARGE_TYPE_NEIDAN then
      itemName = itemIns:getProperty(ITEM_PRO_NAME)
      lv = itemIns:getProperty(ITEM_PRO_EQPT_LVLIMIT)
      zs = itemIns:getProperty(ITEM_PRO_EQPT_ZSLIMIT)
      neidan_LV = string.format("%d转%d级", zs, lv)
      if count_ND == 1 then
        self.neidan_1:setText(itemName)
        self.neidan_1_level:setText(neidan_LV)
      end
      if count_ND == 2 then
        self.neidan_2:setText(itemName)
        self.neidan_2_level:setText(neidan_LV)
      end
      if count_ND == 3 then
        self.neidan_3:setText(itemName)
        self.neidan_3_level:setText(neidan_LV)
      end
      count_ND = count_ND + 1
    end
  end
end
function CChatInsertDetail_PetIcon:Clear()
  self.petObj = nil
end
CChatInsertDetail_PetInfo = class("CChatInsertDetail_PetInfo", function()
  return Widget:create()
end)
function CChatInsertDetail_PetInfo:ctor(petObj, w)
  self.m_KangProperLabels = {}
  self:setPetDeailInfo(petObj, w)
end
function CChatInsertDetail_PetInfo:setPetDeailInfo(petObj, w)
  local nameTxtFontSize = 27
  local proTxtFontSize = 20
  local fontName = KANG_TTF_FONT
  local pos_y = 0
  for index, proShowTable in ipairs(Def_KangViewShowSeq) do
    pos_y = pos_y - 5
    local nameTxt = self:getKangNameTxtIns_(proShowTable.name, fontName, nameTxtFontSize)
    local h = nameTxt:getContentSize().height
    nameTxt:setPosition(w / 2, pos_y - h / 2)
    pos_y = pos_y - h / 2
    local curLineShowIndex = 0
    local lineNO = proShowTable.lineNum
    local proSpaceW = 10
    local proW = (w - (lineNO + 1) * proSpaceW) / lineNO
    local lineH = 0
    for idx, proName in ipairs(proShowTable.pro) do
      local value = petObj:getProperty(proName)
      if proName == PROPERTY_PACC then
        value = value - Def_Show_PROPERTY_PACC_DelValue
      elseif proName == PROPERTY_MAGICKUANGBAO_AIHAO then
        if value ~= 0 then
          value = value - Def_Show_PROPERTY_AiHaoKuangBaoChengDu_DelValue
        end
      elseif proName == PROPERTY_MAGICKUANGBAO_XIXUE then
        if value ~= 0 then
          value = value - Def_Show_PROPERTY_XiXueKuangBaoChengDu_DelValue
        end
      elseif proName == PROPERTY_KE_WXJIN then
        value = value + petObj:getProperty(PROPERTY_WINE_KE_WXJIN)
      elseif proName == PROPERTY_KE_WXMU then
        value = value + petObj:getProperty(PROPERTY_WINE_KE_WXMU)
      elseif proName == PROPERTY_KE_WXTU then
        value = value + petObj:getProperty(PROPERTY_WINE_KE_WXTU)
      elseif proName == PROPERTY_KE_WXSHUI then
        value = value + petObj:getProperty(PROPERTY_WINE_KE_WXSHUI)
      elseif proName == PROPERTY_KE_WXHUO then
        value = value + petObj:getProperty(PROPERTY_WINE_KE_WXHUO)
      end
      local desTxtIns, valueTxtIns = self:getKangProTxtIns_(proName, value, fontName, proTxtFontSize)
      if desTxtIns and valueTxtIns then
        if curLineShowIndex == 0 then
          lineH = 30
          pos_y = pos_y - lineH
        end
        desTxtIns:setVisible(true)
        desTxtIns:setPosition(curLineShowIndex * proW + (1 + curLineShowIndex) * proSpaceW, pos_y - lineH / 2)
        valueTxtIns:setVisible(true)
        valueTxtIns:setPosition((1 + curLineShowIndex) * proW + (1 + curLineShowIndex) * proSpaceW, pos_y - lineH / 2)
        curLineShowIndex = curLineShowIndex + 1
        if lineNO <= curLineShowIndex then
          curLineShowIndex = 0
        end
      end
    end
    pos_y = pos_y - 45
  end
  local realH = -pos_y
  for k, v in pairs(self.m_KangProperLabels) do
    for k1, v1 in pairs(v) do
      if v1 then
        local x, y = v1:getPosition()
        v1:setPosition(CCPoint(x, y + realH))
      end
    end
  end
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(w, realH))
  self:setAnchorPoint(ccp(0, 0))
end
function CChatInsertDetail_PetInfo:getKangNameTxtIns_(name, fontName, nameTxtFontSize)
  local nameTxtFontSize = nameTxtFontSize or 26
  local fontName = fontName or KANG_TTF_FONT
  local key = "kang_name_" .. name
  local nameTxt = self.m_KangProperLabels[key]
  nameTxt = nameTxt and nameTxt.des
  if nameTxt == nil then
    nameTxt = CCLabelTTF:create(name, fontName, nameTxtFontSize)
    nameTxt:setColor(ccc3(255, 196, 98))
    self:addNode(nameTxt)
    self.m_KangProperLabels[key] = {des = nameTxt}
    local txtBg = display.newSprite("views/rolelist/pic_kx_titlebg.png")
    nameTxt:addChild(txtBg, -1)
    local size = nameTxt:getContentSize()
    txtBg:setPosition(size.width / 2 - 10, 10)
  end
  return nameTxt
end
function CChatInsertDetail_PetInfo:getKangProTxtIns_(proType, value, fontName, proTxtFontSize)
  local proTxtFontSize = proTxtFontSize or 20
  local fontName = fontName or KANG_TTF_FONT
  local desTxtIns, valueTxtIns
  local txtInsTable = self.m_KangProperLabels[proType]
  if txtInsTable then
    desTxtIns = txtInsTable.des
    valueTxtIns = txtInsTable.value
  else
    txtInsTable = {}
    self.m_KangProperLabels[proType] = txtInsTable
  end
  if value == 0 then
    if desTxtIns then
      desTxtIns:setVisible(false)
    end
    if valueTxtIns then
      valueTxtIns:setVisible(false)
    end
    return nil, nil
  end
  if desTxtIns == nil then
    desTxtIns = CCLabelTTF:create((Def_Pro_Name[proType] or proType) .. ":", fontName, proTxtFontSize)
    desTxtIns:setHorizontalAlignment(kCCTextAlignmentLeft)
    desTxtIns:setAnchorPoint(ccp(0, 0.5))
    desTxtIns:setColor(ccc3(188, 125, 41))
    self:addNode(desTxtIns)
    txtInsTable.des = desTxtIns
  end
  local tempText = ""
  local addFlag = ""
  if value < 0 then
    addFlag = "-"
  end
  if Def_Pro_ValueType[proType] == Pro_Value_PERCENT_TYPE then
    tempText = string.format("%s%s%%", addFlag, Value2Str(math.abs(value) * 100, 1))
  elseif Def_Pro_ValueType[proType] == Pro_Value_NUM_TYPE then
    tempText = string.format("%s%d", addFlag, math.floor(math.abs(value)))
  elseif Def_Pro_ValueType[proType] == Pro_Value_CZL_TYPE then
    tempText = string.format("%s%s", addFlag, Value2Str(value, 3))
  else
    tempText = string.format("%s%d", addFlag, math.floor(math.abs(value)))
  end
  if valueTxtIns == nil then
    valueTxtIns = CCLabelTTF:create(tempText, fontName, proTxtFontSize)
    valueTxtIns:setHorizontalAlignment(kCCTextAlignmentRight)
    valueTxtIns:setAnchorPoint(ccp(1, 0.5))
    valueTxtIns:setColor(ccc3(255, 255, 255))
    self:addNode(valueTxtIns)
    txtInsTable.value = valueTxtIns
  else
    valueTxtIns:setString(tempText)
  end
  return desTxtIns, valueTxtIns
end
