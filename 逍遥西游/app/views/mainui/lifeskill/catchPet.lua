function ShowCatchPetView(para)
  local skID, lsLv = g_LocalPlayer:getBaseLifeSkill()
  if skID ~= LIFESKILL_CATCH then
    print("不是抓宠技能。")
    return
  end
  getCurSceneView():addSubView({
    subView = CCatchPetShow.new(para),
    zOrder = MainUISceneZOrder.menuView
  })
end
CCatchPetShow = class("CCatchPetShow", CcsSubView)
function CCatchPetShow:ctor(para)
  self.m_CallBack = para.callback
  self.m_InitPetType = para.initPetType
  CCatchPetShow.super.ctor(self, "views/catchpetshow.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_base = {
      listener = handler(self, self.OnBtn_Base),
      variName = "btn_base"
    },
    btn_detail = {
      listener = handler(self, self.OnBtn_Detail),
      variName = "btn_detail"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_base,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_detail,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    }
  })
  self.btn_base:setTitleText("基\n础\n属\n性")
  self.btn_detail:setTitleText("详\n细\n属\n性")
  local size = self.btn_base:getContentSize()
  self:adjustClickSize(self.btn_base, size.width + 30, size.height, true)
  local size = self.btn_detail:getContentSize()
  self:adjustClickSize(self.btn_detail, size.width + 30, size.height, true)
  self:setGroupAllNotSelected(self.btn_base)
  self.m_SelectPetTypeId = nil
  self.m_ShowViewType = CatchPetShow_BaseView
  self:setGroupBtnSelected(self.btn_base)
  self:SetPetList()
end
function CCatchPetShow:SetPetList()
  local petList = {}
  for petId, petData in pairs(data_Pet) do
    if petData.CATCHMAP ~= nil and petData.CATCHMAP ~= 0 then
      petList[#petList + 1] = petId
    end
  end
  local initType = self.m_InitPetType or petList[0]
  self.m_PetListBoard_Normal = CDisplayPetBoard.new({
    petTypeList = petList,
    clickListener = handler(self, self.OnSelectPet),
    xySpace = ccp(22, 22),
    initType = initType,
    pageLines = 5,
    oneLineNum = 2
  })
  self:addChildObjByControl(self.m_PetListBoard_Normal, self:getNode("list_type"))
end
function CCatchPetShow:OnSelectPet(petTypeId)
  self:LoadPet(petTypeId, nil)
  if self.m_PetListBoard_Normal then
    self.m_PetListBoard_Normal:ClearSelectItem()
  end
end
function CCatchPetShow:LoadPet(petId, showViewType)
  petId = petId or self.m_SelectPetTypeId
  showViewType = showViewType or self.m_ShowViewType
  if petId == nil or showViewType == nil then
    return
  end
  if petId == self.m_SelectPetTypeId and showViewType == self.m_ShowViewType then
    return
  end
  self.m_SelectPetTypeId = petId
  self.m_ShowViewType = showViewType
  if self.m_ShowingBoard then
    self.m_ShowingBoard:removeFromParent()
    self.m_ShowingBoard = nil
  end
  local tempView
  if self.m_ShowViewType == CatchPetShow_BaseView then
    tempView = CCatchPetBaseShow.new(self.m_SelectPetTypeId, self)
  elseif self.m_ShowViewType == CatchPetShow_DetailView then
    tempView = CCatchPetDetailShow.new(self.m_SelectPetTypeId, self)
  end
  if tempView ~= nil then
    local x, y = self:getNode("box_pos"):getPosition()
    self:addChild(tempView.m_UINode, 1)
    tempView:setPosition(ccp(x, y))
    self.m_ShowingBoard = tempView
  end
end
function CCatchPetShow:addChildObjByControl(obj, ctrObj)
  local parent = ctrObj:getParent()
  local x, y = ctrObj:getPosition()
  local size = ctrObj:getContentSize()
  local mSize = obj:getContentSize()
  local zOrder = ctrObj:getZOrder()
  parent:addChild(obj, zOrder)
  obj:setPosition(ccp(x + (size.width - mSize.width) / 2, y + 30))
end
function CCatchPetShow:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CCatchPetShow:OnBtn_Base(obj, t)
  self:LoadPet(petId, CatchPetShow_BaseView)
end
function CCatchPetShow:OnBtn_Detail(obj, t)
  self:LoadPet(petId, CatchPetShow_DetailView)
end
function CCatchPetShow:Clear()
  if self.m_CallBack then
    self.m_CallBack()
  end
  self.m_CallBack = nil
end
CCatchPetBaseShow = class("CCatchPetDetailShow", CcsSubView)
function CCatchPetBaseShow:ctor(petID, viewObj)
  CCatchPetBaseShow.super.ctor(self, "views/catchpet_base.json")
  clickArea_check.extend(self)
  local btnBatchListener = {
    btn_catch = {
      listener = handler(self, self.OnBtn_Catch),
      variName = "btn_catch"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.viewObj = viewObj
  self.m_ChoosePet = petID
  self:SetPetShape()
  self:SetLimit()
  self:SetHuoli()
  self:SetAttrTips()
  self:SetPetQuality()
  self:ListenMessage(MsgID_PlayerInfo)
end
function CCatchPetBaseShow:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("coinBg_0"), "reshuoli")
end
function CCatchPetBaseShow:SetPetShape()
  self.role_aureole = self:getNode("role_aureole")
  self.role_aureole:setVisible(false)
  local x, y = self.role_aureole:getPosition()
  local roleParent = self.role_aureole:getParent()
  local z = self.role_aureole:getZOrder()
  if self.m_RoleAni ~= nil then
    if self.m_RoleAni._addClickWidget then
      self.m_RoleAni._addClickWidget:removeFromParentAndCleanup(true)
      self.m_RoleAni._addClickWidget = nil
    end
    self.m_RoleAni:removeFromParentAndCleanup(true)
    self.m_RoleAni = nil
  end
  local shape = data_getRoleShape(self.m_ChoosePet)
  self.m_DynamicLoadShape = shape
  local path = data_getWarBodyPngPathByShape(shape, DIRECTIOIN_RIGHTDOWN)
  addDynamicLoadTexture(path, function(handlerName, texture)
    if self.__isExist and self.m_DynamicLoadShape == shape then
      local offx, offy = 0, 0
      self.m_RoleAni, offx, offy = createWarBodyByShape(shape, DIRECTIOIN_RIGHTDOWN)
      self.m_RoleAni:playAniWithName("guard_4", -1)
      roleParent:addNode(self.m_RoleAni, z + 1)
      self.m_RoleAni:setPosition(x + offx, y + offy)
      self.m_RoleAni:setOpacity(0)
      self.m_RoleAni:runAction(CCFadeIn:create(0.3))
      self:addclickAniForPetAni(self.m_RoleAni, self.role_aureole)
    end
  end)
  if self.m_RoleAureole == nil then
    self.m_RoleAureole = CreateSeqAnimation("xiyou/ani/role_aureole.plist", -1, nil, nil, nil, 6)
    roleParent:addNode(self.m_RoleAureole, z)
    self.m_RoleAureole:setPosition(x + AUREOLE_OFF_X, y + AUREOLE_OFF_Y)
  end
  if self.m_RoleShadow == nil then
    self.m_RoleShadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
    roleParent:addNode(self.m_RoleShadow, z)
    self.m_RoleShadow:setPosition(x, y)
  end
end
function CCatchPetBaseShow:SetLimit()
  local petData = data_Pet[self.m_ChoosePet] or {}
  local openlv = petData.OPENLV or 0
  self:getNode("txt_catchlv"):setText(string.format("等级要求:%d", openlv))
  local x, y = self:getNode("box_coin_0"):getPosition()
  local z = self:getNode("box_coin_0"):getZOrder()
  local size = self:getNode("box_coin_0"):getSize()
  self:getNode("box_coin_0"):setTouchEnabled(false)
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_HUOLI))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
end
function CCatchPetBaseShow:SetPetQuality()
  if self.m_QualityIcon ~= nil then
    self.m_QualityIcon:removeFromParent()
  end
  local iconPath = data_getPetIconPath(self.m_ChoosePet)
  local iconImg = display.newSprite(iconPath)
  local x, y = self:getNode("pet_quality"):getPosition()
  local z = self:getNode("pet_quality"):getZOrder()
  local size = self:getNode("pet_quality"):getSize()
  local roleParent = self:getNode("pet_quality"):getParent()
  iconImg:setAnchorPoint(ccp(0, 1))
  iconImg:setPosition(ccp(x, y + size.height))
  roleParent:addNode(iconImg, z + 10)
  self.m_QualityIcon = iconImg
end
function CCatchPetBaseShow:SetHuoli()
  local needHL = self:GetCatchPetNeedHuoLi()
  self:getNode("txt_coin_0"):setText(string.format("%d/%d", g_LocalPlayer:getHuoli(), needHL))
  if needHL > g_LocalPlayer:getHuoli() then
    self:getNode("txt_coin_0"):setColor(ccc3(255, 0, 0))
  else
    self:getNode("txt_coin_0"):setColor(ccc3(255, 255, 255))
  end
end
function CCatchPetBaseShow:OnBtn_Catch(obj, t)
  local petData = data_Pet[self.m_ChoosePet] or {}
  local openlv = petData.OPENLV or 0
  local curZs = g_LocalPlayer:getObjProperty(1, PROPERTY_ZHUANSHENG)
  local curLv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  if curLv ~= nil and openlv > curLv and curZs <= 0 then
    ShowNotifyTips(string.format("需要等级%d", openlv))
    return
  end
  local curHL = g_LocalPlayer:getHuoli()
  if curHL < self:GetCatchPetNeedHuoLi() then
    ShowNotifyTips(string.format("活力不足%d点，不能前往捕捉", self:GetCatchPetNeedHuoLi()))
    return
  end
  if petData.CATCHMAP ~= nil and petData.CATCHMAP ~= 0 then
    local sID = data_CustomMapPos[petData.CATCHMAP].SceneID
    if g_MapMgr then
      g_MapMgr:AskToEnterGuaji(sID, nil, nil, nil, true)
    end
  end
end
function CCatchPetBaseShow:GetCatchPetNeedHuoLi()
  local huoli = _getCatchPetNeedHuoLi_Succeed(self.m_ChoosePet, activity.huoliHuodong:getIsStarting())
  return huoli
end
function CCatchPetBaseShow:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_HouliUpdate then
    self:SetHuoli()
  end
end
function CCatchPetBaseShow:Clear()
  self.viewObj = nil
end
CCatchPetDetailShow = class("CCatchPetDetailShow", CcsSubView)
function CCatchPetDetailShow:ctor(petID, viewObj)
  CCatchPetDetailShow.super.ctor(self, "views/catchpet_detail.json")
  clickArea_check.extend(self)
  self.m_ChoosePet = petID
  self.viewObj = viewObj
  self.pic_bg = self:getNode("pic_bg")
  self.txt_name = self:getNode("txt_name")
  self.txt_czl = self:getNode("txt_czl")
  self.txt_qx = self:getNode("txt_qxcz")
  self.txt_fl = self:getNode("txt_flcz")
  self.txt_gj = self:getNode("txt_gjcz")
  self.txt_sd = self:getNode("txt_sdcz")
  self.m_PetSkill = {}
  self:SetPotential()
  self:SetAttrTips()
  self:SetSkill()
end
function CCatchPetDetailShow:SetAttrTips()
  self:attrclick_check_withWidgetObj(self:getNode("txt_3"), PROPERTY_GROWUP)
  self:attrclick_check_withWidgetObj(self:getNode("bg_2"), PROPERTY_GROWUP, self:getNode("txt_3"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_4"), PROPERTY_RANDOM_HPBASE)
  self:attrclick_check_withWidgetObj(self:getNode("bg_3"), PROPERTY_RANDOM_HPBASE, self:getNode("txt_4"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_5"), PROPERTY_RANDOM_MPBASE)
  self:attrclick_check_withWidgetObj(self:getNode("bg_4"), PROPERTY_RANDOM_MPBASE, self:getNode("txt_5"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_6"), PROPERTY_RANDOM_APBASE)
  self:attrclick_check_withWidgetObj(self:getNode("bg_5"), PROPERTY_RANDOM_APBASE, self:getNode("txt_6"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_1"), PROPERTY_RANDOM_SPBASE)
  self:attrclick_check_withWidgetObj(self:getNode("bg_6"), PROPERTY_RANDOM_SPBASE, self:getNode("txt_1"))
end
function CCatchPetDetailShow:SetPotential()
  local petData = data_Pet[self.m_ChoosePet]
  if petData == nil then
    return
  end
  self:getNode("txt_name"):setText(petData.NAME)
  self.txt_czl:setText(string.format("%s - %s", Value2Str(petData.GROWUP * 0.98, 3), Value2Str(petData.GROWUP * 1.02, 3)))
  local qx_min = math.floor(petData.HP * 0.8 + 1.0E-8)
  local qx_max = math.floor(petData.HP * 1.2 + 1.0E-8)
  self.txt_qx:setText(string.format("%d - %d", qx_min, qx_max))
  local fl_min = math.floor(petData.MP * 0.8 + 1.0E-8)
  local fl_max = math.floor(petData.MP * 1.2 + 1.0E-8)
  self.txt_fl:setText(string.format("%d - %d", fl_min, fl_max))
  local gj_min = math.floor(petData.AP * 0.8 + 1.0E-8)
  local gj_max = math.floor(petData.AP * 1.2 + 1.0E-8)
  self.txt_gj:setText(string.format("%d - %d", gj_min, gj_max))
  local sd_min = math.floor(petData.SP * 0.8 + 1.0E-8)
  local sd_max = math.floor(petData.SP * 1.2 + 1.0E-8)
  self.txt_sd:setText(string.format("%d - %d", sd_min, sd_max))
end
function CCatchPetDetailShow:SetSkill()
  local petData = data_Pet[self.m_ChoosePet]
  if petData == nil then
    return
  end
  for _, skillObj in pairs(self.m_PetSkill) do
    skillObj:removeFromParentAndCleanup(true)
  end
  self.m_PetSkill = {}
  local skills = petData.skills
  if skills ~= nil then
    local parent = self.pic_bg:getParent()
    local ox, oy = self.pic_bg:getPosition()
    local zOrder = self.pic_bg:getZOrder()
    local x, y = ox - 80, oy - 20
    for i, skillId in ipairs(skills) do
      if skillId ~= 0 then
        local skillIcon = createClickSkill({
          skillID = skillId,
          LongPressTime = 0.2,
          roleTypeId = self.m_ChoosePet
        })
        parent:addChild(skillIcon, zOrder)
        skillIcon:setPosition(ccp(x, y))
        local size = skillIcon:getContentSize()
        self.m_PetSkill[#self.m_PetSkill + 1] = skillIcon
        if i % 2 == 0 then
          x = ox
          y = y - size.height - 20
        else
          x = x + size.width + 20
        end
      end
    end
  end
end
function CCatchPetDetailShow:Clear()
  self.viewObj = nil
end
