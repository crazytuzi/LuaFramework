CNewHuobanAnimation = class("CNewHuobanAnimation", CcsSubView)
function CNewHuobanAnimation:ctor(heroId, heroTypeId)
  CNewHuobanAnimation.super.ctor(self, "views/newhuoban.json", {
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
  self.m_HeroId = heroId
  self.btn_close:setEnabled(false)
  self.btn_confirm:setEnabled(false)
  self.btn_close:setScale(0)
  self.btn_confirm:setScale(0)
  self.btn_war:setEnabled(false)
  self.btn_war:setScale(0)
  local posOffY = 0
  local bodyHeight = data_getBodyHeightByTypeID(heroTypeId)
  if bodyHeight < 110 then
    posOffY = (110 - bodyHeight) / 2
  end
  local pos_body = self:getNode("pos_body")
  pos_body:setVisible(false)
  local x, y = pos_body:getPosition()
  y = y + posOffY
  local z = pos_body:getZOrder()
  local roleParent = pos_body:getParent()
  local iconType = data_getPetLevelType(heroTypeId)
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
  local shape = data_getRoleShape(heroTypeId)
  local roleAni, offx, offy = createBodyByShapeForDlg(shape)
  roleAni:playAniWithName("stand_4", -1)
  roleParent:addNode(roleAni, z + 2)
  roleAni:setPosition(x + offx, y + offy)
  roleAni:setColor(ccc3(0, 0, 0))
  local roleAni_Attack, offx, offy = createWarBodyByShape(shape, DIRECTIOIN_RIGHTDOWN)
  roleAni_Attack:playAniWithName("attack_4", -1)
  roleParent:addNode(roleAni_Attack, z + 2)
  roleAni_Attack:setPosition(x + offx, y + offy)
  roleAni_Attack:setVisible(false)
  roleAni:runAction(transition.sequence({
    CCDelayTime:create(0.7),
    CCShow:create(),
    CCTintTo:create(1, 255, 255, 255),
    CCCallFunc:create(function()
      self.btn_close:setEnabled(true)
      self.btn_confirm:setEnabled(true)
      self.btn_close:runAction(CCScaleTo:create(0.2, 1))
      self.btn_confirm:runAction(CCScaleTo:create(0.2, 1))
      self.btn_war:setEnabled(true)
      self.btn_war:runAction(CCScaleTo:create(0.2, 1))
      roleAni:setVisible(false)
      roleAni_Attack:setVisible(true)
      roleAni_Attack:playAniWithName("attack_4", 1, function()
        roleAni:setVisible(true)
        roleAni_Attack:setVisible(false)
        self:addclickAniForHeroAni(roleAni, pos_body)
      end, false)
      self:playNormalAttackWeaponAni(roleAni, pos_body)
      soundManager.playShapeDlgSound(roleAni._shape)
    end)
  }))
  local petData = data_Hero[heroTypeId] or {}
  local title_name = self:getNode("title_name")
  title_name:setText(petData.NAME or "")
  local x, y = title_name:getPosition()
  title_name:setPosition(ccp(x, y + posOffY))
end
function CNewHuobanAnimation:OnBtn_Confirm()
  self:OnBtn_Close()
  if g_HuobanView then
    g_HuobanView:OnBtn_ShowHuoban()
    g_HuobanView.m_ShowHuobanView:ChooseItemByHeroId(self.m_HeroId)
  else
    local param = {
      viewNum = HuobanShow_ShowHuobanView,
      huobanID = self.m_HeroId
    }
    getCurSceneView():addSubView({
      subView = CHuobanShow.new(param),
      zOrder = MainUISceneZOrder.menuView
    })
  end
end
function CNewHuobanAnimation:OnBtn_war()
  local mainHeroId = g_LocalPlayer:getMainHeroId()
  if mainHeroId ~= nil then
    local inWarFlag = false
    local curRoleId = self.m_HeroId
    local warsetting = g_LocalPlayer:getWarSetting()
    local warNum = 0
    for index, pos in ipairs({
      3,
      2,
      4,
      1,
      5
    }) do
      if warsetting[pos] == curRoleId then
        inWarFlag = true
      end
      if warsetting[pos] ~= nil then
        warNum = warNum + 1
      end
    end
    local zs = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ZHUANSHENG)
    local lv = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ROLELEVEL)
    if warNum >= data_getWarNumLimit(zs, lv) + 1 then
      if zs > 0 or lv >= 60 then
        ShowNotifyTips("上场伙伴已满")
      else
        local nextLv
        if lv >= 40 then
          nextLv = 60
        elseif lv >= 20 then
          nextLv = 40
        else
          nextLv = 20
        end
        ShowNotifyTips(string.format("上场伙伴已满，%d级伙伴出战人数+1", nextLv))
      end
    else
      local newSetting = DeepCopyTable(warsetting)
      for index, pos in ipairs({
        3,
        2,
        4,
        1,
        5
      }) do
        if warsetting[pos] == nil then
          newSetting[pos] = curRoleId
          break
        end
      end
      netsend.netwar.submitWarSetting(newSetting)
      ShowWarningInWar()
    end
  end
  self:OnBtn_Close()
end
function CNewHuobanAnimation:OnBtn_Close()
  self:CloseSelf()
end
function CNewHuobanAnimation:Clear()
end
function ShowNewHuobanAnimation(heroId, heroTypeId)
  getCurSceneView():addSubView({
    subView = CNewHuobanAnimation.new(heroId, heroTypeId),
    zOrder = MainUISceneZOrder.menuView
  })
end
