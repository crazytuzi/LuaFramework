CNewZuoqiAnimation = class("CNewZuoqiAnimation", CcsSubView)
function CNewZuoqiAnimation:ctor(zqId, zqTypeId)
  CNewZuoqiAnimation.super.ctor(self, "views/newzuoqi.json", {
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
  self.m_ZuoqiId = zqId
  self.m_ZqTypeId = zqTypeId
  self.btn_close:setEnabled(false)
  self.btn_confirm:setEnabled(false)
  self.btn_close:setScale(0)
  self.btn_confirm:setScale(0)
  local pos_body = self:getNode("pos_body")
  pos_body:setVisible(false)
  local x, y = pos_body:getPosition()
  local size = pos_body:getContentSize()
  x = x + size.width / 2
  y = y + size.height / 2
  local z = pos_body:getZOrder()
  local roleParent = pos_body:getParent()
  local iconType
  if zqTypeId == ZUOQITYPE_BAIMA or zqTypeId == ZUOQITYPE_LUOTUO then
    iconType = 1
  elseif zqTypeId == ZUOQITYPE_BAILANG or zqTypeId == ZUOQITYPE_TUONIAO then
    iconType = 2
  else
    iconType = 3
  end
  local imgPath = string.format("views/peticon/boxlight%d.png", iconType)
  local imgSprite = display.newSprite(imgPath)
  imgSprite:setPosition(ccp(x, y))
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
  local roleAni, offx, offy = createWidgetFrameHeadIconByRoleTypeID(zqTypeId)
  roleParent:addChild(roleAni, z + 2)
  roleAni:setPosition(ccp(x, y))
  roleAni._BgIcon:setColor(ccc3(0, 0, 0))
  roleAni._HeadIcon:setColor(ccc3(0, 0, 0))
  roleAni:runAction(transition.sequence({
    CCDelayTime:create(0.7),
    CCShow:create(),
    CCCallFunc:create(function()
      roleAni._BgIcon:runAction(CCTintTo:create(1, 255, 255, 255))
      roleAni._HeadIcon:runAction(CCTintTo:create(1, 255, 255, 255))
    end),
    CCDelayTime:create(1),
    CCCallFunc:create(function()
      self.btn_close:setEnabled(true)
      self.btn_confirm:setEnabled(true)
      self.btn_close:runAction(CCScaleTo:create(0.2, 1))
      self.btn_confirm:runAction(CCScaleTo:create(0.2, 1))
    end)
  }))
  local petData = data_Zuoqi[zqTypeId] or {}
  local title_name = self:getNode("title_name")
  title_name:setText(petData.name or "")
end
function CNewZuoqiAnimation:OnBtn_Confirm()
  self:OnBtn_Close()
  if g_ZuoqiDlg == nil then
    getCurSceneView():addSubView({
      subView = CZuoqiShow.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  end
  g_ZuoqiDlg:SelectZuoqi(self.m_ZqTypeId)
end
function CNewZuoqiAnimation:OnBtn_Close()
  self:CloseSelf()
end
function CNewZuoqiAnimation:Clear()
end
function ShowNewZuoqiAnimation(zqId, zqTypeId)
  getCurSceneView():addSubView({
    subView = CNewZuoqiAnimation.new(zqId, zqTypeId),
    zOrder = MainUISceneZOrder.menuView
  })
end
