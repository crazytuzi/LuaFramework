function _petTypeSortFunc(id_a, id_b)
  if id_a == nil or id_b == nil then
    return false
  end
  local data_a = data_Pet[id_a]
  local data_b = data_Pet[id_b]
  local sortLvType_a = data_a.LEVELTYPE
  local sortLvType_b = data_b.LEVELTYPE
  if data_getPetTypeIsGaoJiShouHu(id_a) then
    sortLvType_a = 1.5
  end
  if data_getPetTypeIsGaoJiShouHu(id_b) then
    sortLvType_b = 1.5
  end
  if sortLvType_a ~= sortLvType_b then
    return sortLvType_a < sortLvType_b
  elseif data_a.OPENLV ~= data_b.OPENLV then
    return data_a.OPENLV < data_b.OPENLV
  else
    return id_a < id_b
  end
end
local CShowlifeskillpet = class("CShowlifeskillpet", function()
  return Widget:create()
end)
function CShowlifeskillpet:ctor(petTypeId, isSel, petObjId)
  self.m_PetTypeId = petTypeId
  self.m_onePetObjId = petObjId
  self.m_PetHeandBg = display.newSprite("views/mainviews/btn_pet.png")
  self.m_PetHeandBg:setAnchorPoint(ccp(0.5, 0.5))
  self:addNode(self.m_PetHeandBg)
  self.m_PetHead = createHeadIconByRoleTypeID(self.m_PetTypeId, nil, false)
  self.m_PetHead:setAnchorPoint(ccp(0.5, 0.5))
  self:addNode(self.m_PetHead, 1)
  self.m_PetHead:setScale(0.8)
  self.m_PetHead:setPosition(HEAD_OFF_X, HEAD_OFF_Y)
  self.m_SelectScale = 1.2
  self.m_UnSelectScale = 1
  self.m_SelectOpacity = 255
  self.m_UnSelectOpacity = 255
  self.m_IsSelected = isSel
  self:setScale(self.m_UnSelectScale)
  self:SetOpacity(self.m_UnSelectOpacity)
  self:setTouchEnabled(false)
end
function CShowlifeskillpet:setLevlelable()
  local size = self.m_PetHead:getContentSize()
  local x, y = self.m_PetHead:getPosition()
  local nodePos = self:getParent():convertToNodeSpace(ccp(x, y))
  local openLv = data_Pet[self.m_PetTypeId].OPENLV or 0
  local numLabel = CCLabelTTF:create(string.format("Lv%s", openLv), ITEM_NUM_FONT, 22)
  local color = ccc3(255, 0, 0)
  numLabel:setColor(color)
  numLabel:setAnchorPoint(ccp(0.5, 0.5))
  numLabel:setPosition(ccp(nodePos.x + size.width / 2 + 5, nodePos.y - size.height / 2 + 20))
  self.m_PetHead:addChild(numLabel)
  AutoLimitObjSize(numLabel, 70)
  if openLv == 0 then
    numLabel:setVisible(false)
  end
end
function CShowlifeskillpet:getPetTypeID()
  return self.m_PetTypeId
end
function CShowlifeskillpet:getPetObjId()
  return self.m_onePetObjId
end
function CShowlifeskillpet:setFadeIn()
  local dt = 0.5
  local opacity = self.m_UnSelectOpacity
  if self.m_ChoosedFrame and self.m_ChoosedFrame:isVisible() then
    opacity = self.m_SelectOpacity
  end
  self.m_PetHeandBg:setOpacity(0)
  self.m_PetHeandBg:runAction(CCFadeTo:create(dt, opacity))
  self.m_PetHead:setOpacity(0)
  self.m_PetHead:runAction(CCFadeTo:create(dt, opacity))
  if self.m_ChoosedFrame then
    self.m_ChoosedFrame:setOpacity(0)
    self.m_ChoosedFrame:runAction(CCFadeTo:create(dt, opacity))
  end
end
function CShowlifeskillpet:setSelected(flag)
  self:stopAllActions()
  local act1 = CCScaleTo:create(0.05, self.m_SelectScale)
  local act2 = CCScaleTo:create(0.05, self.m_UnSelectScale)
  local sequenAction = transition.sequence({act1, act2})
  self:runAction(sequenAction)
  soundManager.playSound("xiyou/sound/clickbutton_1.wav")
end
function CShowlifeskillpet:SetOpacity(a)
  self.m_PetHeandBg:setOpacity(a)
  self.m_PetHead:setOpacity(a)
  if self.m_ChoosedFrame then
    self.m_ChoosedFrame:setOpacity(a)
  end
end
CShowlifeskillpetFrame = class("CDisplayPetBoard", function()
  return Widget:create()
end)
function CShowlifeskillpetFrame:ctor(listParam, isMarket)
  self.m_PetTypeList = listParam.petTypeList
  self.m_ClickListener = listParam.clickListener
  self.m_PageListener = listParam.pageListener
  self.m_XYSpace = listParam.xySpace or ccp(5, 2)
  self.m_HeadSize = listParam.headSize or CCSize(75, 75)
  self.m_PageLines = listParam.pageLines or 4
  self.m_OneLineNum = listParam.oneLineNum or 3
  self.m_petObjIdList = listParam.petObjIdList or {}
  self.m_PageItemNum = self.m_PageLines * self.m_OneLineNum
  local mWidth = self.m_OneLineNum * self.m_HeadSize.width + (self.m_OneLineNum - 1) * self.m_XYSpace.x
  local mHeight = self.m_PageLines * self.m_HeadSize.height + (self.m_PageLines - 1) * self.m_XYSpace.y
  local initType = listParam.initType
  self.m_CurrPageIndex = -1
  self.m_CurrPagePetObjs = {}
  self:setTotalPetList()
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(mWidth, mHeight))
  self:setAnchorPoint(ccp(0, 0))
  self:setTouchEnabled(true)
  self:addTouchEventListener(function(touchObj, event)
    self:OnTouchEvent(touchObj, event)
  end)
  self:ShowPackagePage(1, listParam.fadeoutAction)
  self:setNodeEventEnabled(true)
end
function CShowlifeskillpetFrame:SetSelectAtIndex(index)
  self.m_TouchBeganItem = self.m_CurrPagePetObjs[index]
  self:ClickAtPos()
end
function CShowlifeskillpetFrame:SetSelectPet(petTypeId)
  for _, obj in pairs(self.m_CurrPagePetObjs) do
    if obj:getPetTypeID() == petTypeId then
      self.m_TouchBeganItem = obj
      self:ClickAtPos()
    end
  end
end
function CShowlifeskillpetFrame:getCurSelectItem()
  return self.m_TouchBeganItem
end
function CShowlifeskillpetFrame:getFrameSize()
  local w = self.m_OneLineNum * self.m_HeadSize.width + (self.m_OneLineNum - 1) * self.m_XYSpace.x
  local h = self.m_PageLines * self.m_HeadSize.height + (self.m_PageLines - 1) * self.m_XYSpace.y
  return CCSize(w, h)
end
function CShowlifeskillpetFrame:setTotalPetList()
  table.sort(self.m_PetTypeList, _petTypeSortFunc)
  self.m_TotalPageNum = math.max(math.ceil(#self.m_PetTypeList / self.m_PageItemNum), 1)
end
function CShowlifeskillpetFrame:ShowPackagePage(pageIndex, showAction)
  if self.m_CurrPageIndex == pageIndex then
    return
  end
  self.m_CurrPageIndex = pageIndex
  for _, obj in pairs(self.m_CurrPagePetObjs) do
    obj:removeFromParentAndCleanup(true)
  end
  self.m_CurrPagePetObjs = {}
  local idIndex = 1 + self.m_PageItemNum * (self.m_CurrPageIndex - 1)
  local iWidth = self.m_HeadSize.width
  local iHeight = self.m_HeadSize.height
  local spacex = self.m_XYSpace.x
  local spacey = self.m_XYSpace.y
  for line = 1, self.m_PageLines do
    for i = 1, self.m_OneLineNum do
      local petTypeId = self.m_PetTypeList[idIndex]
      local petObjId = self.m_petObjIdList[idIndex]
      if petObjId ~= nil then
        local petIns = g_LocalPlayer:getObjById(petObjId)
        petTypeId = petIns:getTypeId()
      end
      if petTypeId ~= nil then
        local petObj = CShowlifeskillpet.new(petTypeId, false, petObjId)
        self:addChild(petObj)
        local ox, oy = (iWidth + spacex) * (i - 1) + iWidth * 0.5, (iHeight + spacey) * (self.m_PageLines - line) + iHeight * 0.5
        petObj.m_OriPosXY = ccp(ox, oy)
        petObj:setPosition(petObj.m_OriPosXY)
        petObj:setLevlelable()
        self.m_CurrPagePetObjs[#self.m_CurrPagePetObjs + 1] = petObj
        idIndex = idIndex + 1
        if showAction == true then
          petObj:setFadeIn()
        end
      end
    end
  end
  if self.m_PageListener then
    self.m_PageListener(self.m_CurrPageIndex, self.m_TotalPageNum)
  end
end
function CShowlifeskillpetFrame:OnTouchEvent(touchObj, event)
  if event == TOUCH_EVENT_BEGAN then
    local startPos = touchObj:getTouchStartPos()
    self.m_TouchBeganItem = self:checkTouchBeganPos(startPos)
    if self.m_TouchBeganItem then
      self.m_TouchBeganItem:setSelected()
    end
    self.m_HasTouchMoved = false
  elseif event == TOUCH_EVENT_MOVED then
    local startPos = touchObj:getTouchStartPos()
    local movePos = touchObj:getTouchMovePos()
    if not self.m_HasTouchMoved and math.abs(startPos.x - movePos.x) + math.abs(startPos.y - movePos.y) > 40 then
      self.m_HasTouchMoved = true
    end
    if self.m_HasTouchMoved and self.m_TouchBeganItem then
      self.m_TouchBeganItem = nil
    end
  elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
    if self.m_HasTouchMoved then
      if self.m_TouchBeganItem ~= nil then
        self.m_TouchBeganItem = nil
      end
      local startPos = touchObj:getTouchStartPos()
      local endPos = touchObj:getTouchEndPos()
    else
      self:ClickAtPos()
    end
  end
end
function CShowlifeskillpetFrame:checkTouchBeganPos(pos)
  local touchPos = self:convertToNodeSpace(ccp(pos.x, pos.y))
  for _, headObj in pairs(self.m_CurrPagePetObjs) do
    local x, y = headObj:getPosition()
    if touchPos.x >= x - self.m_HeadSize.width / 2 and touchPos.x <= x + self.m_HeadSize.width / 2 and touchPos.y >= y - self.m_HeadSize.height / 2 and touchPos.y <= y + self.m_HeadSize.height / 2 then
      return headObj
    end
  end
  return nil
end
function CShowlifeskillpetFrame:ClickAtPos()
  if self.m_TouchBeganItem == nil then
    return
  end
  local petTypeId = self.m_TouchBeganItem:getPetTypeID()
  local petObjId = self.m_TouchBeganItem:getPetObjId()
  if self.m_ClickListener then
    self.m_ClickListener(petTypeId)
  end
  self.m_TouchBeganItem = nil
end
function CShowlifeskillpetFrame:ClearSelectItem()
end
function CShowlifeskillpetFrame:onCleanup()
  self.m_ClickListener = nil
  self.m_PageListener = nil
end
CShowLifeSkillPetDetail = class("CShowLifeSkillPetDetail", CcsSubView)
function CShowLifeSkillPetDetail:ctor(petTypeId)
  CShowLifeSkillPetDetail.super.ctor(self, "views/chatdetail_pet.json")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_petattr = {
      listener = handler(self, self.OnBtn_ShowPetVBaseAttr),
      variName = "btn_petattr"
    },
    btn_petzizhi = {
      listener = handler(self, self.OnBtn_ShowPetZiZhi),
      variName = "btn_petzizhi"
    },
    btn_petkangxing = {
      listener = handler(self, self.OnBtn_ShowPetKangXing),
      variName = "btn_petkangxing"
    },
    btn_petskill = {
      listener = handler(self, self.OnBtn_ShowPetSkill),
      variName = "btn_petskill"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_petattr,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_petzizhi,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_petkangxing,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_petskill,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    }
  })
  self.btn_petattr:setTitleText("基\n础\n属\n性")
  self.btn_petzizhi:setTitleText("属\n性\n资\n质")
  self.btn_petkangxing:setTitleText("抗\n性")
  self.btn_petskill:setTitleText("技\n能")
  self.m_needLv = self:getNode("need_lv")
  self:reSetBtnPos()
  self.m_petTypeId = petTypeId
  self:enableCloseWhenTouchOutside(self:getNode("touch_layer"), true)
  self.list_detail = self:getNode("list_detail")
  self:ShowPetPanel(nil)
  if g_CheckDetailDlg ~= nil then
    g_CheckDetailDlg:CloseSelf()
    g_CheckDetailDlg = nil
  end
  g_CheckDetailDlg = self
  self:SetPetDetailData()
end
function CShowLifeSkillPetDetail:ShowPetPanel(btnObj)
  if btnObj ~= nil then
    if self.petBaseAttrPanel then
      self.petBaseAttrPanel:setEnabled(btnObj == "BaseAttr")
      self.petBaseAttrPanel:setVisible(btnObj == "BaseAttr")
    end
    if self.petZiZhiPanel then
      self.petZiZhiPanel:setEnabled(btnObj == "ZiZhi")
      self.petZiZhiPanel:setVisible(btnObj == "ZiZhi")
    end
    if self.petKangXingPanel then
      self.petKangXingPanel:setEnabled(btnObj == "KangXing")
      self.petKangXingPanel:setVisible(btnObj == "KangXing")
    end
    if self.petSkillPanel then
      self.petSkillPanel:setEnabled(btnObj == "Skill")
      self.petSkillPanel:setVisible(btnObj == "Skill")
    end
  end
end
function CShowLifeSkillPetDetail:addChildObjByControl(obj, ctrObj)
  local parent = ctrObj:getParent()
  local x, y = ctrObj:getPosition()
  local zOrder = ctrObj:getZOrder()
  parent:addChild(obj.m_UINode, zOrder)
  obj:setPosition(ccp(x, y))
end
function CShowLifeSkillPetDetail:reSetBtnPos()
  local attrX, attrY = self.btn_petattr:getPosition()
  self.btn_petattr:setPosition(ccp(attrX, attrY - 15))
  local zzX, zzY = self.btn_petzizhi:getPosition()
  self.btn_petzizhi:setPosition(ccp(zzX, zzY - 15))
  self.btn_petkangxing:setEnabled(false)
  local kxX, kxY = self.btn_petkangxing:getPosition()
  self.btn_petskill:setPosition(ccp(kxX, kxY - 15))
end
function CShowLifeSkillPetDetail:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CShowLifeSkillPetDetail:OnBtn_ShowPetVBaseAttr(obj, t)
  if self.petBaseAttrPanel == nil then
    self.petBaseAttrPanel = CShowLifeSkillPetDetail_Base.new(self.m_petTypeId)
    self:addChildObjByControl(self.petBaseAttrPanel, self.list_detail)
  end
  self.m_needLv:setVisible(true)
  self:CleanUpPanel("BaseAttr")
  self:ShowPetPanel("BaseAttr")
  self:reSetBtnPos()
end
function CShowLifeSkillPetDetail:OnBtn_ShowPetZiZhi(obj, t)
  self.m_needLv:setVisible(false)
  if self.petZiZhiPanel == nil then
    self.petZiZhiPanel = CShowLifeSkillPetDetail_Attr.new(self.m_petTypeId)
    self:addChildObjByControl(self.petZiZhiPanel, self.list_detail)
  end
  self:CleanUpPanel("ZiZhi")
  self:ShowPetPanel("ZiZhi")
  self:reSetBtnPos()
end
function CShowLifeSkillPetDetail:OnBtn_ShowPetKangXing(obj, t)
  self.m_needLv:setVisible(false)
  if self.petKangXingPanel == nil then
    self.petKangXingPanel = CShowLifeSkillPetDetail_KX.new(self.m_petTypeId)
    self:addChildObjByControl(self.petKangXingPanel, self.list_detail)
  end
  self:CleanUpPanel("KangXing")
  self:ShowPetPanel("KangXing")
  self:reSetBtnPos()
end
function CShowLifeSkillPetDetail:OnBtn_ShowPetSkill(obj, t)
  self.m_needLv:setVisible(false)
  if self.petSkillPanel == nil then
    self.petSkillPanel = CShowLifeSkillPetDetail_Skill.new(self.m_petTypeId)
    self:addChildObjByControl(self.petSkillPanel, self.list_detail)
  end
  self:CleanUpPanel("Skill")
  self:ShowPetPanel("Skill")
  self:reSetBtnPos()
end
function CShowLifeSkillPetDetail:needtoHide(...)
end
function CShowLifeSkillPetDetail:Clear()
  if g_CheckDetailDlg == self then
    g_CheckDetailDlg = nil
  end
end
function CShowLifeSkillPetDetail:CleanUpPanel(btnObj)
  if btnObj ~= "BaseAttr" and self.petBaseAttrPanel ~= nil then
    self.petBaseAttrPanel:removeFromParentAndCleanup(true)
    self.petBaseAttrPanel = nil
  end
  if btnObj ~= "ZiZhi" and self.petZiZhiPanel ~= nil then
    self.petZiZhiPanel:removeFromParentAndCleanup(true)
    self.petZiZhiPanel = nil
  end
  if btnObj ~= "KangXing" and self.petKangXingPanel ~= nil then
    self.petKangXingPanel:removeFromParentAndCleanup(true)
    self.petKangXingPanel = nil
  end
  if btnObj ~= "Skill" and self.petSkillPanel ~= nil then
    self.petSkillPanel:removeFromParentAndCleanup(true)
    self.petSkillPanel = nil
  end
end
function CShowLifeSkillPetDetail:SetPetDetailData()
  local petData = data_Pet[self.m_petTypeId]
  self.skills = petData.skills
  local openlv = petData.OPENLV
  self.m_needLv:setText(string.format("等级要求:%d", openlv))
  self.m_needLv:setPosition(ccp(150, 160))
  self.petBaseAttrPanel = CShowLifeSkillPetDetail_Base.new(self.m_petTypeId)
  self:addChildObjByControl(self.petBaseAttrPanel, self.list_detail)
  self.petBaseAttrPanel:setVisible(true)
end
CShowLifeSkillPetDetail_Base = class("CShowLifeSkillPetDetail_Base", CcsSubView)
function CShowLifeSkillPetDetail_Base:ctor(petTypeId)
  CShowLifeSkillPetDetail_Base.super.ctor(self, "views/chatinsertdetail_pet.csb")
  self.BaseAttrPanel = self:getNode("BaseAttrPanel")
  self.m_petTypeId = petTypeId
  if self.m_petTypeId == nil then
    self:CloseSelf()
    return
  end
  self.ndLists_BA = {}
  self:LoadPetIcon()
  self:needToHide()
end
function CShowLifeSkillPetDetail_Base:LoadPetIcon()
  if self.m_petTypeId == nil then
    return
  end
  clickArea_check.extend(self)
  self.imagepos = self:getNode("imagepos")
  self.imagepos:setVisible(false)
  local p = self.imagepos:getParent()
  local x, y = self.imagepos:getPosition()
  local z = self.imagepos:getZOrder()
  local shapeId = data_Pet[self.m_petTypeId].SHAPE
  local roleAni, offx, offy = createWarBodyByShape(shapeId)
  roleAni:playAniWithName("guard_4", -1)
  p:addNode(roleAni, z + 2)
  roleAni:setPosition(ccp(x + offx, y + offy))
  self:addclickAniForPetAni(roleAni, self.imagepos)
  if self.m_RoleAureole == nil then
    self.m_RoleAureole = CreateSeqAnimation("xiyou/ani/role_aureole.plist", -1, nil, nil, nil, 6)
    p:addNode(self.m_RoleAureole, z + 1)
    self.m_RoleAureole:setPosition(x + AUREOLE_OFF_X, y + AUREOLE_OFF_Y)
  end
  if self.m_RoleShadow == nil then
    local roleShadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
    p:addNode(roleShadow, z + 1)
    roleShadow:setPosition(x, y)
    self.m_RoleShadow = roleShadow
  end
  local iconPath = data_getPetIconPath(self.m_petTypeId)
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
function CShowLifeSkillPetDetail_Base:needToHide()
  self.pet_level:setVisible(false)
  self:getNode("coner3_0"):setVisible(false)
  self:getNode("pet_neidan"):setVisible(false)
end
function CShowLifeSkillPetDetail_Base:LoadPetAttr()
  local petData = data_Pet[self.m_petTypeId]
  if petData == nil then
    print("====================导表不存在")
    return
  end
  local petname = petData.NAME
  local zs = 0
  local lv = petData.OPENLV
  local color = ccc3(248, 193, 100)
  local cur_level = string.format("%d转%d级", zs, lv)
  self.pet_name = self:getNode("txt_name")
  self.pet_level = self:getNode("txt_level")
  local x, y = self.pet_level:getPosition()
  self.pet_name:setText(petname)
  self.pet_name:setPosition(ccp(x, y))
  self.pet_name:setColor(color)
end
CShowLifeSkillPetDetail_Attr = class("CShowLifeSkillPetDetail_Attr", CcsSubView)
function CShowLifeSkillPetDetail_Attr:ctor(petTypeId)
  CShowLifeSkillPetDetail_Attr.super.ctor(self, "views/chatdetail_shuxinzizhi_pet.csb")
  self.m_petTypeId = petTypeId
  if self.m_petTypeId == nil then
    self:CloseSelf()
    return
  end
  self.txt_grow_speed = self:getNode("txt_grow_speed")
  self.txt_longgu_num = self:getNode("txt_longgu_num")
  self.txt_qixue = self:getNode("txt_qixue")
  self.txt_fali = self:getNode("txt_fali")
  self.txt_gongji = self:getNode("txt_gongji")
  self.txt_sudu = self:getNode("txt_sudu")
  self.txt_qinmi = self:getNode("txt_qinmi")
  self.txt_gengu = self:getNode("txt_gengu")
  self.txt_lingxing = self:getNode("txt_lingxing")
  self.txt_liliang = self:getNode("txt_liliang")
  self.txt_minjie = self:getNode("txt_minjie")
  self.txt_qx_chuzhi = self:getNode("txt_qx_chuzhi")
  self.txt_fali_chuzhi = self:getNode("txt_fali_chuzhi")
  self.txt_gongji_chuzhi = self:getNode("txt_gongji_chuzhi")
  self.txt_sudu_chuzhi = self:getNode("txt_sudu_chuzhi")
  self.txt_qinmi_chuzhi = self:getNode("txt_qinmi_chuzhi")
  self:SetBaseAttr()
  self:SetAttrTips_ZiZhi()
  self:needToHide()
end
function CShowLifeSkillPetDetail_Attr:SetAttrTips_ZiZhi()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("growspeed"), PROPERTY_GROWUP)
  self:attrclick_check_withWidgetObj(self:getNode("txt_grow_speed"), PROPERTY_GROWUP, self:getNode("growspeed"))
  self:attrclick_check_withWidgetObj(self:getNode("qixue_lable_1"), PROPERTY_HP)
  self:attrclick_check_withWidgetObj(self:getNode("txt_qixue"), PROPERTY_HP, self:getNode("qixue_lable_1"))
  self:attrclick_check_withWidgetObj(self:getNode("fali_lable_2"), PROPERTY_MP)
  self:attrclick_check_withWidgetObj(self:getNode("txt_fali"), PROPERTY_MP, self:getNode("fali_lable_2"))
  self:attrclick_check_withWidgetObj(self:getNode("gongji_lable_3"), PROPERTY_AP)
  self:attrclick_check_withWidgetObj(self:getNode("txt_gongji"), PROPERTY_AP, self:getNode("gongji_lable_3"))
  self:attrclick_check_withWidgetObj(self:getNode("sudu_lable_4"), PROPERTY_SP)
  self:attrclick_check_withWidgetObj(self:getNode("txt_sudu"), PROPERTY_SP, self:getNode("sudu_lable_4"))
  self:attrclick_check_withWidgetObj(self:getNode("qinmi_lable_5"), PROPERTY_CLOSEVALUE)
  self:attrclick_check_withWidgetObj(self:getNode("txt_qinmi"), PROPERTY_CLOSEVALUE, self:getNode("qinmi_lable_5"))
  self:attrclick_check_withWidgetObj(self:getNode("gengu_lable_6"), PROPERTY_GenGu)
  self:attrclick_check_withWidgetObj(self:getNode("gengu_lable_6"), PROPERTY_GenGu, self:getNode("gengu_lable_6"))
  self:attrclick_check_withWidgetObj(self:getNode("lingxing_lable_7"), PROPERTY_Lingxing)
  self:attrclick_check_withWidgetObj(self:getNode("lingxing_lable_7"), PROPERTY_Lingxing, self:getNode("lingxing_lable_7"))
  self:attrclick_check_withWidgetObj(self:getNode("liliang_lable_8"), PROPERTY_LiLiang)
  self:attrclick_check_withWidgetObj(self:getNode("liliang_lable_8"), PROPERTY_LiLiang, self:getNode("liliang_lable_8"))
  self:attrclick_check_withWidgetObj(self:getNode("minjie_lable_9"), PROPERTY_MinJie)
  self:attrclick_check_withWidgetObj(self:getNode("minjie_lable_9"), PROPERTY_MinJie, self:getNode("minjie_lable_9"))
end
function CShowLifeSkillPetDetail_Attr:needToHide()
  self:getNode("longgu"):setVisible(false)
  self:getNode("txt_longgu_num"):setVisible(false)
  self:getNode("txt_qx_chuzhi"):setVisible(false)
  self:getNode("txt_fali_chuzhi"):setVisible(false)
  self:getNode("txt_gongji_chuzhi"):setVisible(false)
  self:getNode("txt_sudu_chuzhi"):setVisible(false)
  self:getNode("qinmi_lable_5"):setVisible(false)
  self:getNode("txt_qinmi"):setVisible(false)
  self:getNode("txt_qinmi_chuzhi"):setVisible(false)
  self:getNode("pet_attr_0"):setVisible(false)
  self:getNode("bg1_0_0_1"):setVisible(false)
  self:getNode("gengu_lable_6"):setVisible(false)
  self:getNode("txt_gengu"):setVisible(false)
  self:getNode("lingxing_lable_7"):setVisible(false)
  self:getNode("txt_lingxing"):setVisible(false)
  self:getNode("liliang_lable_8"):setVisible(false)
  self:getNode("txt_liliang"):setVisible(false)
  self:getNode("minjie_lable_9"):setVisible(false)
  self:getNode("txt_minjie"):setVisible(false)
end
function CShowLifeSkillPetDetail_Attr:SetBaseAttr()
  local petTypeId = self.m_petTypeId
  local petData = data_Pet[petTypeId] or {}
  if petData == nil then
    return
  end
  self.txt_grow_speed:setText(string.format("%s - %s", Value2Str(petData.GROWUP * 0.98, 3), Value2Str(petData.GROWUP * 1.02, 3)))
  local max_hp = math.floor(petData.HP * 1.2 + 1.0E-8)
  local min_hp = math.floor(petData.HP * 0.8 + 1.0E-8)
  self.txt_qixue:setText(string.format("%s - %s", min_hp, max_hp))
  self.txt_qx_chuzhi:setVisible(false)
  local max_mp = math.floor(petData.MP * 1.2 + 1.0E-8)
  local min_mp = math.floor(petData.MP * 0.8 + 1.0E-8)
  self.txt_fali:setText(string.format("%s - %s", min_mp, max_mp))
  local min_ap = math.floor(petData.AP * 0.8 + 1.0E-8)
  local max_ap = math.floor(petData.AP * 1.2 + 1.0E-8)
  self.txt_gongji:setText(string.format("%s - %s", min_ap, max_ap))
  local min_sd = math.floor(petData.SP * 0.8 + 1.0E-8)
  local max_sd = math.floor(petData.SP * 1.2 + 1.0E-8)
  self.txt_sudu:setText(string.format("%s - %s", min_sd, max_sd))
end
CShowLifeSkillPetDetail_KX = class("CShowLifeSkillPetDetail_KX", CcsSubView)
function CShowLifeSkillPetDetail_KX:ctor(petTypeId)
  CShowLifeSkillPetDetail_KX.super.ctor(self, "views/chatdetail_kangxing_pet.csb")
  self.m_petTypeId = petTypeId
  if self.m_petTypeId == nil then
    self:CloseSelf()
    return
  end
  self:setKXAttr()
  self:SetAttrTips()
end
function CShowLifeSkillPetDetail_KX:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys_1"), PROPERTY_PDEFEND)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_1"), PROPERTY_PDEFEND, self:getNode("txt_lys2"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys_5"), PROPERTY_KFENG)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_5"), PROPERTY_KFENG, self:getNode("txt_lys6"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys_3"), PROPERTY_KSHUI)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_3"), PROPERTY_KSHUI, self:getNode("txt_lys4"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys_2"), PROPERTY_KHUO)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_2"), PROPERTY_KHUO, self:getNode("txt_lys3"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys_4"), PROPERTY_KLEI)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_4"), PROPERTY_KLEI, self:getNode("txt_lys5"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys_6"), PROPERTY_KHUNLUAN)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_6"), PROPERTY_KHUNLUAN, self:getNode("txt_lys7"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys_8"), PROPERTY_KZHONGDU)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_8"), PROPERTY_KZHONGDU, self:getNode("txt_lys9"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys_10"), PROPERTY_KZHENSHE)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_10"), PROPERTY_KZHENSHE, self:getNode("txt_lys11"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys_7"), PROPERTY_KHUNSHUI)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_7"), PROPERTY_KHUNSHUI, self:getNode("txt_lys8"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys_9"), PROPERTY_KFENGYIN)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_9"), PROPERTY_KFENGYIN, self:getNode("txt_lys10"))
end
function CShowLifeSkillPetDetail_KX:setKXAttr()
  if m_petTypeId == nil then
    return
  end
  local lys_x, lys_y = self.liaoyao_num:getPosition()
  local txt_x, txt_y = self:getNode("txt_liaoyao"):getPosition()
  local txt_size = self:getNode("txt_liaoyao"):getContentSize()
  local count = 1
  for i, proName in ipairs({
    PROPERTY_PDEFEND,
    PROPERTY_KHUO,
    PROPERTY_KSHUI,
    PROPERTY_KLEI,
    PROPERTY_KFENG,
    PROPERTY_KHUNLUAN,
    PROPERTY_KHUNSHUI,
    PROPERTY_KZHONGDU,
    PROPERTY_KFENGYIN,
    PROPERTY_KZHENSHE
  }) do
    local value = 0
    local lys_add_Node = self:getNode(string.format("lys_add_%d", i))
    local txt_lys_Node = self:getNode(string.format("txt_lys_%d", i))
    if value ~= 0 then
      lys_add_Node:setText(string.format("%d", value * 100))
      lys_add_Node:setPosition(ccp(lys_x, lys_y - count * txt_size.width / 3))
      txt_lys_Node:setPosition(ccp(txt_x, lys_y - count * txt_size.width / 3 - txt_size.height / 2))
      count = count + 1
    else
      lys_add_Node:setVisible(false)
      txt_lys_Node:setVisible(false)
      txt_lys_Node:setTouchEnabled(false)
    end
  end
end
CShowLifeSkillPetDetail_Skill = class("CShowLifeSkillPetDetail_Skill", CcsSubView)
function CShowLifeSkillPetDetail_Skill:ctor(petTypeId)
  CShowLifeSkillPetDetail_Skill.super.ctor(self, "views/chatdetail_skill_pet.csb")
  self.m_petTypeId = petTypeId
  if self.m_petTypeId == nil then
    self:CloseSelf()
    return
  end
  self.m_SkillIcon = {}
  self:LoadPet()
  self:needToHide()
end
function CShowLifeSkillPetDetail_Skill:LoadPet()
  if self.m_petTypeId == nil then
    return
  end
  self:SetBaseSkill()
end
function CShowLifeSkillPetDetail_Skill:SetBaseSkill()
  local petData = data_Pet[self.m_petTypeId]
  local skillList = {}
  if petData ~= nil and petData.skills ~= nil then
    local skills = petData.skills
    for i = #skills, 1, -1 do
      local skillId = skills[i]
      if skillId ~= 0 then
        table.insert(skillList, 1, skillId)
      end
    end
  end
  for _, skillIcon in pairs(self.m_SkillIcon) do
    skillIcon:removeFromParentAndCleanup(true)
  end
  self.m_SkillIcon = {}
  local lwSkillList = {}
  local normalPetSkills = {}
  for i, skillId in ipairs(normalPetSkills) do
    lwSkillList[#lwSkillList + 1] = {skillId, false}
  end
  local ssPetSkills = {}
  if type(ssPetSkills) ~= "table" then
    ssPetSkills = {}
  end
  for i, skillId in ipairs(ssPetSkills) do
    lwSkillList[#lwSkillList + 1] = {skillId, true}
  end
  self:SetSkillAtRow(skillList, 1)
end
function CShowLifeSkillPetDetail_Skill:SetSkillAtRow(skillList, row)
  for i, d in ipairs(skillList) do
    local posObj = self:getNode(string.format("box_%d%d", row, i))
    local px, py = posObj:getPosition()
    local parent = posObj:getParent()
    local zOrder = posObj:getZOrder()
    skillIcon = nil
    if row == 1 then
      local skillId = d
      local openFlag = false
      skillIcon = createClickSkill({
        skillID = skillId,
        LongPressTime = 0.2,
        roleTypeId = self.m_petTypeId
      })
    else
      local skillId = d[1]
      local ssFlag = d[2]
      if skillId > 0 then
        skillIcon = createClickSkill({
          skillID = skillId,
          LongPressTime = 0.2,
          roleTypeId = self.m_petTypeId
        })
      end
      if ssFlag then
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
    parent:addChild(skillIcon, zOrder)
    skillIcon:setPosition(ccp(px, py))
    self.m_SkillIcon[#self.m_SkillIcon + 1] = skillIcon
  end
end
function CShowLifeSkillPetDetail_Skill:needToHide()
  self:getNode("txt_lingwuskill"):setVisible(false)
  self:getNode("bg2"):setVisible(false)
end
