CNewPetAnimation = class("CNewPetAnimation", CcsSubView)
function CNewPetAnimation:ctor(petId)
  CNewPetAnimation.super.ctor(self, "views/petlist_newpet.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  clickArea_check.extend(self)
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_confirm"
    },
    btn_war = {
      listener = handler(self, self.OnBtn_war),
      variName = "btn_war"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_PetId = petId
  self.m_InitSuccess = false
  local petObj = g_LocalPlayer:getObjById(self.m_PetId)
  if petObj == nil then
  end
  local petTypeId = petObj:getTypeId()
  self.btn_close:setEnabled(false)
  self.btn_confirm:setEnabled(false)
  self.btn_close:setScale(0)
  self.btn_confirm:setScale(0)
  self.btn_war:setEnabled(false)
  self.btn_war:setScale(0)
  local pos_icon = self:getNode("pos_icon")
  pos_icon:setVisible(false)
  local iconPath = data_getPetIconPath(petTypeId)
  local iconImg = display.newSprite(iconPath)
  local x, y = pos_icon:getPosition()
  local z = pos_icon:getZOrder()
  local size = pos_icon:getSize()
  local p = pos_icon:getParent()
  iconImg:setAnchorPoint(ccp(0, 1))
  iconImg:setPosition(ccp(x, y + size.height))
  p:addNode(iconImg, z + 10)
  local posOffY = 0
  local bodyHeight = data_getBodyHeightByTypeID(petTypeId)
  if bodyHeight < 110 then
    posOffY = (110 - bodyHeight) / 2
  end
  local pos_body = self:getNode("pos_body")
  pos_body:setVisible(false)
  local x, y = pos_body:getPosition()
  y = y + posOffY
  local z = pos_body:getZOrder()
  local roleParent = pos_body:getParent()
  local iconType = data_getPetLevelType(petTypeId)
  local imgPath = string.format("views/peticon/boxlight%d.png", iconType)
  local imgSprite = display.newSprite(imgPath)
  imgSprite:setPosition(ccp(x, y + bodyHeight / 2))
  roleParent:addNode(imgSprite, z)
  imgSprite:setScale(0)
  imgSprite:runAction(transition.sequence({
    CCScaleTo:create(0.3, 1.4),
    CCCallFunc:create(function()
      soundManager.playSound("xiyou/sound/openbox.wav")
    end),
    CCScaleTo:create(0.2, 1)
  }))
  imgSprite:runAction(CCRepeatForever:create(CCRotateBy:create(1.5, 360)))
  local roleShadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  roleParent:addNode(roleShadow, z + 1)
  roleShadow:setPosition(x, y)
  roleShadow:setColor(ccc3(0, 0, 0))
  roleShadow:runAction(transition.sequence({
    CCDelayTime:create(0.7),
    CCShow:create(),
    CCTintTo:create(1, 255, 255, 255)
  }))
  local shape = data_getRoleShape(petTypeId)
  local roleAni, offx, offy = createWarBodyByShape(shape)
  roleAni:playAniWithName("guard_4", -1)
  roleParent:addNode(roleAni, z + 2)
  roleAni:setPosition(x + offx, y + offy)
  roleAni:setColor(ccc3(0, 0, 0))
  roleAni:runAction(transition.sequence({
    CCDelayTime:create(0.7),
    CCShow:create(),
    CCTintTo:create(1, 255, 255, 255),
    CCCallFunc:create(function()
      self.btn_close:setEnabled(true)
      self.btn_confirm:setEnabled(true)
      self.btn_war:setEnabled(true)
      self.btn_close:runAction(CCScaleTo:create(0.2, 1))
      self.btn_confirm:runAction(CCScaleTo:create(0.2, 1))
      self.btn_war:runAction(CCScaleTo:create(0.2, 1))
      roleAni._aniState = "attack"
      roleAni:playAniWithName("attack_4", 1, function()
        roleAni._aniState = "guard"
        roleAni:playAniWithName("guard_4", -1)
        self:addclickAniForPetAni(roleAni, pos_body)
      end, false)
      self:playNormalAttackWeaponAni(roleAni, pos_body)
      soundManager.playShapeDlgSound(roleAni._shape)
    end)
  }))
  local petData = data_Pet[petTypeId] or {}
  local title_name = self:getNode("title_name")
  title_name:setText(petData.NAME or "")
  local x, y = title_name:getPosition()
  title_name:setPosition(ccp(x, y + posOffY))
  self.m_InitSuccess = true
end
function CNewPetAnimation:InitSuccess()
  return self.m_InitSuccess
end
function CNewPetAnimation:OnBtn_Confirm()
  self:OnBtn_Close()
  if g_PetListDlg == nil then
    getCurSceneView():addSubView({
      subView = CPetList.new(nil, self.m_PetId),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif g_PetListDlg:isVisible() then
    g_PetListDlg:InitViews(PetShow_InitShow_PropertyView)
    g_PetListDlg:ChooseAndScrollToRoleWithID(self.m_PetId)
  elseif g_PetListDisplayDlg and g_PetListDisplayDlg:isVisible() then
    g_PetListDlg:InitViews(PetShow_InitShow_PropertyView)
    g_PetListDlg:ChooseAndScrollToRoleWithID(self.m_PetId)
    g_PetListDisplayDlg:OnBtn_Page_ItemList()
  else
    getCurSceneView():addSubView({
      subView = CPetList.new(nil, self.m_PetId),
      zOrder = MainUISceneZOrder.menuView
    })
  end
end
function CNewPetAnimation:OnBtn_war()
  local mainHeroId = g_LocalPlayer:getMainHeroId()
  if mainHeroId ~= nil then
    if JudgeIsInWar() then
      ShowNotifyTips("战斗中不能执行此操作")
      return
    end
    netsend.netbaseptc.setEquipPet(mainHeroId, self.m_PetId)
  end
  self:OnBtn_Close()
end
function CNewPetAnimation:OnBtn_Close()
  self:CloseSelf()
end
function CNewPetAnimation:Clear()
end
function ShowNewPetAnimation(petId)
  if JudgeIsInWar() == true then
    return
  end
  local dlg = CNewPetAnimation.new(petId)
  if dlg:InitSuccess() then
    getCurSceneView():addSubView({
      subView = dlg,
      zOrder = MainUISceneZOrder.menuView
    })
  end
end
