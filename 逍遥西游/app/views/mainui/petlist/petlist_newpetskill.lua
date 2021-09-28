CNewPetSkillAnimation = class("CNewPetSkillAnimation", CcsSubView)
function CNewPetSkillAnimation:ctor(petId, skillId)
  CNewPetSkillAnimation.super.ctor(self, "views/petlist_newpetskill.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_confirm"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_PetId = petId
  self.m_SkillId = skillId
  self.btn_close:setVisible(false)
  self.btn_close:setTouchEnabled(false)
  self.btn_confirm:setVisible(false)
  self.btn_confirm:setTouchEnabled(false)
  self.btn_close:setScale(0)
  self.btn_confirm:setScale(0)
  local pos_icon = self:getNode("pos_icon")
  pos_icon:setVisible(false)
  local iconPath = data_getSkillPinJieIconPath(skillId)
  local iconImg = display.newSprite(iconPath)
  local x, y = pos_icon:getPosition()
  local z = pos_icon:getZOrder()
  local size = pos_icon:getSize()
  local p = pos_icon:getParent()
  iconImg:setAnchorPoint(ccp(0, 1))
  iconImg:setPosition(ccp(x, y + size.height))
  p:addNode(iconImg, z)
  local pos_body = self:getNode("pos_body")
  pos_body:setVisible(false)
  local x, y = pos_body:getPosition()
  local size = pos_body:getContentSize()
  x = x + size.width / 2
  y = y + size.height / 2
  local z = pos_body:getZOrder()
  local roleParent = pos_body:getParent()
  local pinjie = data_getItemPinjie(skillId)
  if pinjie == ITEM_PINJIE_1 then
    iconType = 1
  elseif pinjie == ITEM_PINJIE_2 then
    iconType = 2
  else
    iconType = 3
  end
  local imgPath = string.format("views/peticon/boxlight%d.png", iconType)
  local imgSprite = display.newSprite(imgPath)
  imgSprite:setPosition(ccp(x, y))
  roleParent:addNode(imgSprite, z)
  imgSprite:setScale(0)
  self.m_ImgSprite = imgSprite
  local itemPath = data_getSkillShapePath(skillId)
  local roleAni = display.newSprite(itemPath)
  roleParent:addNode(roleAni, z + 2)
  roleAni:setPosition(ccp(x, y))
  roleAni:setColor(ccc3(0, 0, 0))
  self.m_RoleAni = roleAni
  local title_name = self:getNode("title_name")
  local skillName = data_getSkillName(skillId)
  title_name:setText(skillName)
  self.m_IsAction = false
  self:ListenMessage(MsgID_Scene)
end
function CNewPetSkillAnimation:onEnterEvent()
  self:checkShow()
end
function CNewPetSkillAnimation:OnMessage(msgSID, ...)
  if msgSID == MsgID_Scene_War_Exit or msgSID == MsgID_Scene_WarResult_Exit then
    local act1 = CCDelayTime:create(0.3)
    local act2 = CCCallFunc:create(function()
      self:checkShow()
    end)
    self:runAction(transition.sequence({act1, act2}))
  end
end
function CNewPetSkillAnimation:checkShow()
  if self.m_IsAction then
    return
  end
  local iShow = g_WarScene == nil and g_WarLoseResultIns == nil
  self:setEnabled(iShow)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setEnabled(iShow)
  end
  if iShow then
    self.m_IsAction = true
    self.m_ImgSprite:runAction(transition.sequence({
      CCScaleTo:create(0.3, 1.4),
      CCCallFunc:create(function()
        soundManager.playSound("xiyou/sound/openbox.wav")
      end),
      CCScaleTo:create(0.2, 1)
    }))
    self.m_ImgSprite:runAction(CCRepeatForever:create(CCRotateBy:create(1.5, 360)))
    self.m_RoleAni:runAction(transition.sequence({
      CCDelayTime:create(0.7),
      CCShow:create(),
      CCCallFunc:create(function()
        self.m_RoleAni:runAction(CCTintTo:create(1, 255, 255, 255))
      end),
      CCDelayTime:create(1),
      CCCallFunc:create(function()
        self.btn_close:setVisible(true)
        self.btn_close:setTouchEnabled(true)
        self.btn_confirm:setVisible(true)
        self.btn_confirm:setTouchEnabled(true)
        self.btn_close:runAction(CCScaleTo:create(0.2, 1))
        self.btn_confirm:runAction(CCScaleTo:create(0.2, 1))
      end)
    }))
  end
end
function CNewPetSkillAnimation:OnBtn_Confirm()
  self:OnBtn_Close()
  if g_PetListDlg == nil then
    getCurSceneView():addSubView({
      subView = CPetList.new(PetShow_InitShow_SkillLearnView, self.m_PetId),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif g_PetListDlg:isVisible() then
    g_PetListDlg:InitViews(PetShow_InitShow_SkillLearnView)
    g_PetListDlg:ChooseAndScrollToRoleWithID(self.m_PetId)
  elseif g_PetListDisplayDlg and g_PetListDisplayDlg:isVisible() then
    g_PetListDisplayDlg:OnBtn_Page_ItemList()
    g_PetListDlg:InitViews(PetShow_InitShow_SkillLearnView)
    g_PetListDlg:ChooseAndScrollToRoleWithID(self.m_PetId)
  else
    getCurSceneView():addSubView({
      subView = CPetList.new(PetShow_InitShow_SkillLearnView, self.m_PetId),
      zOrder = MainUISceneZOrder.menuView
    })
  end
end
function CNewPetSkillAnimation:OnBtn_Close()
  self:CloseSelf()
end
function CNewPetSkillAnimation:Clear()
end
function ShowNewPetSkillAnimation(petId, skillId)
  getCurSceneView():addSubView({
    subView = CNewPetSkillAnimation.new(petId, skillId),
    zOrder = MainUISceneZOrder.popZView
  })
end
