ChangeColorViewTest = class("ChangeColorViewTest", CcsSubView)
local POSNUM = 3
local COLORNUM = 5
function ChangeColorViewTest:ctor(para)
  ChangeColorViewTest.super.ctor(self, "views/changecolor.json", {isAutoCenter = true, opacityBg = 100})
  clickArea_check.extend(self)
  para = para or {}
  self.m_CallBack = para.callBack
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_left = {
      listener = handler(self, self.OnBtn_Left),
      variName = "btn_left"
    },
    btn_right = {
      listener = handler(self, self.OnBtn_Right),
      variName = "btn_right"
    },
    btn_random = {
      listener = handler(self, self.OnBtn_Random),
      variName = "btn_random"
    },
    btn_reset = {
      listener = handler(self, self.OnBtn_Reset),
      variName = "btn_reset"
    },
    btn_changecolor = {
      listener = handler(self, self.OnBtn_ChangeColor),
      variName = "btn_changecolor"
    }
  }
  for j = 1, POSNUM do
    for i = 1, COLORNUM do
      local btnNum = j * 10 + i - 1
      local btnName = string.format("btn_%d", btnNum)
      self:getNode(btnName):setEnabled(false)
    end
  end
  self:addBatchBtnListener(btnBatchListener)
  self.btn_addr1 = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.OnBtn_Addr1))
  self:addChild(self.btn_addr1)
  self.btn_addr1:setPosition(ccp(700, 500))
  self.btn_subr1 = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.OnBtn_Subr1))
  self:addChild(self.btn_subr1)
  self.btn_subr1:setPosition(ccp(600, 500))
  self.btn_addr2 = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.OnBtn_Addr2))
  self:addChild(self.btn_addr2)
  self.btn_addr2:setPosition(ccp(700, 350))
  self.btn_subr2 = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.OnBtn_Subr2))
  self:addChild(self.btn_subr2)
  self.btn_subr2:setPosition(ccp(600, 350))
  self.btn_addr3 = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.OnBtn_Addr3))
  self:addChild(self.btn_addr3)
  self.btn_addr3:setPosition(ccp(700, 200))
  self.btn_subr3 = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.OnBtn_Subr3))
  self:addChild(self.btn_subr3)
  self.btn_subr3:setPosition(ccp(600, 200))
  self.btn_addg1 = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.OnBtn_Addg1))
  self:addChild(self.btn_addg1)
  self.btn_addg1:setPosition(ccp(700, 460))
  self.btn_subg1 = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.OnBtn_Subg1))
  self:addChild(self.btn_subg1)
  self.btn_subg1:setPosition(ccp(600, 460))
  self.btn_addg2 = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.OnBtn_Addg2))
  self:addChild(self.btn_addg2)
  self.btn_addg2:setPosition(ccp(700, 310))
  self.btn_subg2 = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.OnBtn_Subg2))
  self:addChild(self.btn_subg2)
  self.btn_subg2:setPosition(ccp(600, 310))
  self.btn_addg3 = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.OnBtn_Addg3))
  self:addChild(self.btn_addg3)
  self.btn_addg3:setPosition(ccp(700, 160))
  self.btn_subg3 = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.OnBtn_Subg3))
  self:addChild(self.btn_subg3)
  self.btn_subg3:setPosition(ccp(600, 160))
  self.btn_addb1 = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.OnBtn_Addb1))
  self:addChild(self.btn_addb1)
  self.btn_addb1:setPosition(ccp(700, 420))
  self.btn_subb1 = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.OnBtn_Subb1))
  self:addChild(self.btn_subb1)
  self.btn_subb1:setPosition(ccp(600, 420))
  self.btn_addb2 = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.OnBtn_Addb2))
  self:addChild(self.btn_addb2)
  self.btn_addb2:setPosition(ccp(700, 270))
  self.btn_subb2 = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.OnBtn_Subb2))
  self:addChild(self.btn_subb2)
  self.btn_subb2:setPosition(ccp(600, 270))
  self.btn_addb3 = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.OnBtn_Addb3))
  self:addChild(self.btn_addb3)
  self.btn_addb3:setPosition(ccp(700, 120))
  self.btn_subb3 = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.OnBtn_Subb3))
  self:addChild(self.btn_subb3)
  self.btn_subb3:setPosition(ccp(600, 120))
  self.btn_hideWeapon = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.OnBtn_HideWeapon))
  self:addChild(self.btn_hideWeapon)
  self.btn_hideWeapon:setPosition(ccp(730, 50))
  self.btn_showWeapon = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.OnBtn_ShowWeapon))
  self:addChild(self.btn_showWeapon)
  self.btn_showWeapon:setPosition(ccp(680, 50))
  self.btn_random:setTitleText("下一个角色")
  self.btn_changecolor:setEnabled(false)
  self.m_TempColorData = {
    255,
    255,
    255,
    255,
    255,
    255,
    255,
    255,
    255
  }
  self.m_RoleAni = nil
  self.m_DirNum = nil
  self.m_RunFlag = nil
  self.m_IsShowWebpon = true
  self.m_ShapeList = {
    11001,
    11002,
    11004,
    11006,
    11008,
    11009,
    12001,
    12002,
    12004,
    12006,
    12007,
    12009,
    13001,
    13003,
    13004,
    13006,
    13008,
    13009,
    14001,
    14002,
    14003,
    14004
  }
  self.m_ShowShapeIndex = 1
  self:setRoleShape(self.m_ShapeList[1])
  self:setRoleDir(DIRECTIOIN_DOWN)
  self:setRoleRunFlag(false)
  self:setRoleColor(255, 255, 255, 255, 255, 255, 255, 255, 255)
end
function ChangeColorViewTest:OnBtn_Addr1()
  local r1 = self.m_TempColorData[1]
  local g1 = self.m_TempColorData[2]
  local b1 = self.m_TempColorData[3]
  local r2 = self.m_TempColorData[4]
  local g2 = self.m_TempColorData[5]
  local b2 = self.m_TempColorData[6]
  local r3 = self.m_TempColorData[7]
  local g3 = self.m_TempColorData[8]
  local b3 = self.m_TempColorData[9]
  r1 = (r1 + 1) % 256
  self:setRoleColor(r1, g1, b1, r2, g2, b2, r3, g3, b3)
end
function ChangeColorViewTest:OnBtn_Subr1()
  local r1 = self.m_TempColorData[1]
  local g1 = self.m_TempColorData[2]
  local b1 = self.m_TempColorData[3]
  local r2 = self.m_TempColorData[4]
  local g2 = self.m_TempColorData[5]
  local b2 = self.m_TempColorData[6]
  local r3 = self.m_TempColorData[7]
  local g3 = self.m_TempColorData[8]
  local b3 = self.m_TempColorData[9]
  r1 = (r1 - 1) % 256
  self:setRoleColor(r1, g1, b1, r2, g2, b2, r3, g3, b3)
end
function ChangeColorViewTest:OnBtn_Addr2()
  local r1 = self.m_TempColorData[1]
  local g1 = self.m_TempColorData[2]
  local b1 = self.m_TempColorData[3]
  local r2 = self.m_TempColorData[4]
  local g2 = self.m_TempColorData[5]
  local b2 = self.m_TempColorData[6]
  local r3 = self.m_TempColorData[7]
  local g3 = self.m_TempColorData[8]
  local b3 = self.m_TempColorData[9]
  r2 = (r2 + 1) % 256
  self:setRoleColor(r1, g1, b1, r2, g2, b2, r3, g3, b3)
end
function ChangeColorViewTest:OnBtn_Subr2()
  local r1 = self.m_TempColorData[1]
  local g1 = self.m_TempColorData[2]
  local b1 = self.m_TempColorData[3]
  local r2 = self.m_TempColorData[4]
  local g2 = self.m_TempColorData[5]
  local b2 = self.m_TempColorData[6]
  local r3 = self.m_TempColorData[7]
  local g3 = self.m_TempColorData[8]
  local b3 = self.m_TempColorData[9]
  r2 = (r2 - 1) % 256
  self:setRoleColor(r1, g1, b1, r2, g2, b2, r3, g3, b3)
end
function ChangeColorViewTest:OnBtn_Addr3()
  local r1 = self.m_TempColorData[1]
  local g1 = self.m_TempColorData[2]
  local b1 = self.m_TempColorData[3]
  local r2 = self.m_TempColorData[4]
  local g2 = self.m_TempColorData[5]
  local b2 = self.m_TempColorData[6]
  local r3 = self.m_TempColorData[7]
  local g3 = self.m_TempColorData[8]
  local b3 = self.m_TempColorData[9]
  r3 = (r3 + 1) % 256
  self:setRoleColor(r1, g1, b1, r2, g2, b2, r3, g3, b3)
end
function ChangeColorViewTest:OnBtn_Subr3()
  local r1 = self.m_TempColorData[1]
  local g1 = self.m_TempColorData[2]
  local b1 = self.m_TempColorData[3]
  local r2 = self.m_TempColorData[4]
  local g2 = self.m_TempColorData[5]
  local b2 = self.m_TempColorData[6]
  local r3 = self.m_TempColorData[7]
  local g3 = self.m_TempColorData[8]
  local b3 = self.m_TempColorData[9]
  r3 = (r3 - 1) % 256
  self:setRoleColor(r1, g1, b1, r2, g2, b2, r3, g3, b3)
end
function ChangeColorViewTest:OnBtn_Addg1()
  local r1 = self.m_TempColorData[1]
  local g1 = self.m_TempColorData[2]
  local b1 = self.m_TempColorData[3]
  local r2 = self.m_TempColorData[4]
  local g2 = self.m_TempColorData[5]
  local b2 = self.m_TempColorData[6]
  local r3 = self.m_TempColorData[7]
  local g3 = self.m_TempColorData[8]
  local b3 = self.m_TempColorData[9]
  g1 = (g1 + 1) % 256
  self:setRoleColor(r1, g1, b1, r2, g2, b2, r3, g3, b3)
end
function ChangeColorViewTest:OnBtn_Subg1()
  local r1 = self.m_TempColorData[1]
  local g1 = self.m_TempColorData[2]
  local b1 = self.m_TempColorData[3]
  local r2 = self.m_TempColorData[4]
  local g2 = self.m_TempColorData[5]
  local b2 = self.m_TempColorData[6]
  local r3 = self.m_TempColorData[7]
  local g3 = self.m_TempColorData[8]
  local b3 = self.m_TempColorData[9]
  g1 = (g1 - 1) % 256
  self:setRoleColor(r1, g1, b1, r2, g2, b2, r3, g3, b3)
end
function ChangeColorViewTest:OnBtn_Addg2()
  local r1 = self.m_TempColorData[1]
  local g1 = self.m_TempColorData[2]
  local b1 = self.m_TempColorData[3]
  local r2 = self.m_TempColorData[4]
  local g2 = self.m_TempColorData[5]
  local b2 = self.m_TempColorData[6]
  local r3 = self.m_TempColorData[7]
  local g3 = self.m_TempColorData[8]
  local b3 = self.m_TempColorData[9]
  g2 = (g2 + 1) % 256
  self:setRoleColor(r1, g1, b1, r2, g2, b2, r3, g3, b3)
end
function ChangeColorViewTest:OnBtn_Subg2()
  local r1 = self.m_TempColorData[1]
  local g1 = self.m_TempColorData[2]
  local b1 = self.m_TempColorData[3]
  local r2 = self.m_TempColorData[4]
  local g2 = self.m_TempColorData[5]
  local b2 = self.m_TempColorData[6]
  local r3 = self.m_TempColorData[7]
  local g3 = self.m_TempColorData[8]
  local b3 = self.m_TempColorData[9]
  g2 = (g2 - 1) % 256
  self:setRoleColor(r1, g1, b1, r2, g2, b2, r3, g3, b3)
end
function ChangeColorViewTest:OnBtn_Addg3()
  local r1 = self.m_TempColorData[1]
  local g1 = self.m_TempColorData[2]
  local b1 = self.m_TempColorData[3]
  local r2 = self.m_TempColorData[4]
  local g2 = self.m_TempColorData[5]
  local b2 = self.m_TempColorData[6]
  local r3 = self.m_TempColorData[7]
  local g3 = self.m_TempColorData[8]
  local b3 = self.m_TempColorData[9]
  g3 = (g3 + 1) % 256
  self:setRoleColor(r1, g1, b1, r2, g2, b2, r3, g3, b3)
end
function ChangeColorViewTest:OnBtn_Subg3()
  local r1 = self.m_TempColorData[1]
  local g1 = self.m_TempColorData[2]
  local b1 = self.m_TempColorData[3]
  local r2 = self.m_TempColorData[4]
  local g2 = self.m_TempColorData[5]
  local b2 = self.m_TempColorData[6]
  local r3 = self.m_TempColorData[7]
  local g3 = self.m_TempColorData[8]
  local b3 = self.m_TempColorData[9]
  g3 = (g3 - 1) % 256
  self:setRoleColor(r1, g1, b1, r2, g2, b2, r3, g3, b3)
end
function ChangeColorViewTest:OnBtn_Addb1()
  local r1 = self.m_TempColorData[1]
  local g1 = self.m_TempColorData[2]
  local b1 = self.m_TempColorData[3]
  local r2 = self.m_TempColorData[4]
  local g2 = self.m_TempColorData[5]
  local b2 = self.m_TempColorData[6]
  local r3 = self.m_TempColorData[7]
  local g3 = self.m_TempColorData[8]
  local b3 = self.m_TempColorData[9]
  b1 = (b1 + 1) % 256
  self:setRoleColor(r1, g1, b1, r2, g2, b2, r3, g3, b3)
end
function ChangeColorViewTest:OnBtn_Subb1()
  local r1 = self.m_TempColorData[1]
  local g1 = self.m_TempColorData[2]
  local b1 = self.m_TempColorData[3]
  local r2 = self.m_TempColorData[4]
  local g2 = self.m_TempColorData[5]
  local b2 = self.m_TempColorData[6]
  local r3 = self.m_TempColorData[7]
  local g3 = self.m_TempColorData[8]
  local b3 = self.m_TempColorData[9]
  b1 = (b1 - 1) % 256
  self:setRoleColor(r1, g1, b1, r2, g2, b2, r3, g3, b3)
end
function ChangeColorViewTest:OnBtn_Addb2()
  local r1 = self.m_TempColorData[1]
  local g1 = self.m_TempColorData[2]
  local b1 = self.m_TempColorData[3]
  local r2 = self.m_TempColorData[4]
  local g2 = self.m_TempColorData[5]
  local b2 = self.m_TempColorData[6]
  local r3 = self.m_TempColorData[7]
  local g3 = self.m_TempColorData[8]
  local b3 = self.m_TempColorData[9]
  b2 = (b2 + 1) % 256
  self:setRoleColor(r1, g1, b1, r2, g2, b2, r3, g3, b3)
end
function ChangeColorViewTest:OnBtn_Subb2()
  local r1 = self.m_TempColorData[1]
  local g1 = self.m_TempColorData[2]
  local b1 = self.m_TempColorData[3]
  local r2 = self.m_TempColorData[4]
  local g2 = self.m_TempColorData[5]
  local b2 = self.m_TempColorData[6]
  local r3 = self.m_TempColorData[7]
  local g3 = self.m_TempColorData[8]
  local b3 = self.m_TempColorData[9]
  b2 = (b2 - 1) % 256
  self:setRoleColor(r1, g1, b1, r2, g2, b2, r3, g3, b3)
end
function ChangeColorViewTest:OnBtn_Addb3()
  local r1 = self.m_TempColorData[1]
  local g1 = self.m_TempColorData[2]
  local b1 = self.m_TempColorData[3]
  local r2 = self.m_TempColorData[4]
  local g2 = self.m_TempColorData[5]
  local b2 = self.m_TempColorData[6]
  local r3 = self.m_TempColorData[7]
  local g3 = self.m_TempColorData[8]
  local b3 = self.m_TempColorData[9]
  b3 = (b3 + 1) % 256
  self:setRoleColor(r1, g1, b1, r2, g2, b2, r3, g3, b3)
end
function ChangeColorViewTest:OnBtn_Subb3()
  local r1 = self.m_TempColorData[1]
  local g1 = self.m_TempColorData[2]
  local b1 = self.m_TempColorData[3]
  local r2 = self.m_TempColorData[4]
  local g2 = self.m_TempColorData[5]
  local b2 = self.m_TempColorData[6]
  local r3 = self.m_TempColorData[7]
  local g3 = self.m_TempColorData[8]
  local b3 = self.m_TempColorData[9]
  b3 = (b3 - 1) % 256
  self:setRoleColor(r1, g1, b1, r2, g2, b2, r3, g3, b3)
end
function ChangeColorViewTest:OnBtn_HideWeapon()
  self.m_IsShowWebpon = true
  self:flushAni()
end
function ChangeColorViewTest:OnBtn_ShowWeapon()
  self.m_IsShowWebpon = false
  self:flushAni()
end
function ChangeColorViewTest:setRoleShape(shape)
  print("---->>>shape:", shape)
  if self.m_ShapeTextShow == nil then
    self.m_ShapeTextShow = ui.newTTFLabel({
      text = tostring(shape),
      font = KANG_TTF_FONT,
      size = 16,
      color = ccc3(255, 196, 98)
    })
    self.m_ShapeTextShow:setAnchorPoint(ccp(0, 0))
    self:addNode(self.m_ShapeTextShow)
    self.m_ShapeTextShow:setPosition(ccp(300, 300))
  else
    self.m_ShapeTextShow:setString(tostring(shape))
  end
  self.role_aureole = self:getNode("role_aureole")
  self.role_aureole:setVisible(false)
  local x, y = self.role_aureole:getPosition()
  local parent = self.role_aureole:getParent()
  local z = self.role_aureole:getZOrder()
  if self.m_RoleAni == nil or self.m_RoleAni._shape ~= shape then
    if self.m_RoleAni ~= nil then
      self.m_RoleAni:removeFromParent()
      self.m_RoleAni = nil
    end
    do
      local tempRoleAni
      if self.m_RoleAni ~= nil then
        tempRoleAni = self.m_RoleAni
      end
      local offx, offy = 0, 0
      self.m_RoleAni, offx, offy = createBodyByRoleTypeID(shape, false)
      parent:addNode(self.m_RoleAni, z + 10)
      self.m_RoleAni:setPosition(x + offx, y + offy)
      local function clickFunc()
        self:setRoleRunFlag(not self.m_RunFlag)
      end
      self:addclickAniForHeroAni(self.m_RoleAni, self.role_aureole, 0, 0, clickFunc)
      if tempRoleAni ~= nil then
        self.m_RoleAni:setVisible(false)
        local act1 = CCDelayTime:create(0.01)
        local act2 = CCCallFunc:create(function()
          if tempRoleAni._addClickWidget then
            tempRoleAni._addClickWidget:removeFromParentAndCleanup(true)
            tempRoleAni._addClickWidget = nil
          end
          tempRoleAni:removeFromParentAndCleanup(true)
          self.m_RoleAni:setVisible(true)
        end)
        self.m_RoleAni:runAction(transition.sequence({act1, act2}))
      end
    end
  end
  if self.m_RoleAureole == nil then
    self.m_RoleAureole = CreateSeqAnimation("xiyou/ani/role_aureole.plist", -1, nil, nil, nil, 6)
    parent:addNode(self.m_RoleAureole, z + 9)
    self.m_RoleAureole:setPosition(x + AUREOLE_OFF_X, y + AUREOLE_OFF_Y)
  end
  if self.m_RoleShadow == nil then
    self.m_RoleShadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
    parent:addNode(self.m_RoleShadow, z + 9)
    self.m_RoleShadow:setPosition(x, y)
  end
end
function ChangeColorViewTest:setRoleDir(dirNum)
  if self.m_DirNum == dirNum then
    return
  end
  self.m_DirNum = dirNum
  if self.m_RoleAni then
    self:flushAni()
  end
end
function ChangeColorViewTest:setRoleRunFlag(flag)
  if self.m_RunFlag == flag then
    return
  end
  self.m_RunFlag = flag
  if self.m_RoleAni then
    self:flushAni()
  end
end
function ChangeColorViewTest:setRoleColor(r1, g1, b1, r2, g2, b2, r3, g3, b3)
  if self.m_RoleAni then
    self:flushAni(r1, g1, b1, r2, g2, b2, r3, g3, b3)
  end
end
function ChangeColorViewTest:flushAni(r1, g1, b1, r2, g2, b2, r3, g3, b3)
  if r1 == nil then
    r1 = self.m_TempColorData[1]
    g1 = self.m_TempColorData[2]
    b1 = self.m_TempColorData[3]
    r2 = self.m_TempColorData[4]
    g2 = self.m_TempColorData[5]
    b2 = self.m_TempColorData[6]
    r3 = self.m_TempColorData[7]
    g3 = self.m_TempColorData[8]
    b3 = self.m_TempColorData[9]
  end
  self.m_TempColorData = {
    r1,
    g1,
    b1,
    r2,
    g2,
    b2,
    r3,
    g3,
    b3
  }
  local DirrectConvert = {
    [6] = 4,
    [7] = 3,
    [8] = 2
  }
  if self.m_RoleAni ~= nil then
    local d = self.m_DirNum
    if d >= 6 then
      d = DirrectConvert[d]
      self.m_RoleAni:setScaleX(-1)
    else
      self.m_RoleAni:setScaleX(1)
    end
    local aniName
    if self.m_RunFlag == true then
      aniName = string.format("walk_%d", d)
    else
      aniName = string.format("stand_%d", d)
    end
    self.m_RoleAni:playAniWithName(aniName, -1)
    self.m_RoleAni:setColorful(2, ccc4(r1, g1, b1, 255))
    self.m_RoleAni:setColorful(4, ccc4(r2, g2, b2, 255))
    self.m_RoleAni:setColorful(3, ccc4(r3, g3, b3, 255))
    if self.m_IsShowWebpon then
      self.m_RoleAni:setColorful(5, ccc4(255, 255, 255, 255))
    else
      self.m_RoleAni:setColorful(5, ccc4(0, 0, 0, 0))
    end
    self.m_RoleAni:setVisible(false)
    scheduler.performWithDelayGlobal(function()
      if self.m_RoleAni then
        self.m_RoleAni:setVisible(true)
      end
    end, 0.001)
  end
  self:SetItemNum()
end
function ChangeColorViewTest:SetItemNum()
  self:getNode("txt1"):setAnchorPoint(ccp(0, 0.5))
  self:getNode("txt2"):setAnchorPoint(ccp(0, 0.5))
  self:getNode("txt3"):setAnchorPoint(ccp(0, 0.5))
  self:getNode("txt1"):setText(string.format("头饰r:%d,g:%d,b:%d", self.m_TempColorData[1], self.m_TempColorData[2], self.m_TempColorData[3]))
  self:getNode("txt2"):setText(string.format("上装r:%d,g:%d,b:%d", self.m_TempColorData[4], self.m_TempColorData[5], self.m_TempColorData[6]))
  self:getNode("txt3"):setText(string.format("下装r:%d,g:%d,b:%d", self.m_TempColorData[7], self.m_TempColorData[8], self.m_TempColorData[9]))
end
function ChangeColorViewTest:Clear()
  if self.m_CallBack then
    self.m_CallBack()
  end
end
function ChangeColorViewTest:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function ChangeColorViewTest:OnBtn_Left(btnObj, touchType)
  local tempDirDict = {
    [DIRECTIOIN_DOWN] = DIRECTIOIN_LEFTDOWN,
    [DIRECTIOIN_LEFTDOWN] = DIRECTIOIN_LEFT,
    [DIRECTIOIN_LEFT] = DIRECTIOIN_LEFTUP,
    [DIRECTIOIN_LEFTUP] = DIRECTIOIN_UP,
    [DIRECTIOIN_UP] = DIRECTIOIN_RIGHTUP,
    [DIRECTIOIN_RIGHTUP] = DIRECTIOIN_RIGHT,
    [DIRECTIOIN_RIGHT] = DIRECTIOIN_RIGHTDOWN,
    [DIRECTIOIN_RIGHTDOWN] = DIRECTIOIN_DOWN
  }
  self:setRoleDir(tempDirDict[self.m_DirNum])
end
function ChangeColorViewTest:OnBtn_Right(btnObj, touchType)
  local tempDirDict = {
    [DIRECTIOIN_DOWN] = DIRECTIOIN_RIGHTDOWN,
    [DIRECTIOIN_RIGHTDOWN] = DIRECTIOIN_RIGHT,
    [DIRECTIOIN_RIGHT] = DIRECTIOIN_RIGHTUP,
    [DIRECTIOIN_RIGHTUP] = DIRECTIOIN_UP,
    [DIRECTIOIN_UP] = DIRECTIOIN_LEFTUP,
    [DIRECTIOIN_LEFTUP] = DIRECTIOIN_LEFT,
    [DIRECTIOIN_LEFT] = DIRECTIOIN_LEFTDOWN,
    [DIRECTIOIN_LEFTDOWN] = DIRECTIOIN_DOWN
  }
  self:setRoleDir(tempDirDict[self.m_DirNum])
end
function ChangeColorViewTest:OnBtn_Random(btnObj, touchType)
  local index = self.m_ShowShapeIndex + 1
  if index >= #self.m_ShapeList + 1 then
    index = 1
  end
  self.m_ShowShapeIndex = index
  print([[



]])
  print("shapeId:", self.m_ShapeList[index])
  print([[



]])
  self:setRoleShape(self.m_ShapeList[index])
  self:setRoleDir(DIRECTIOIN_DOWN)
  self:setRoleRunFlag(false)
  self:setRoleColor()
end
function ChangeColorViewTest:OnBtn_Reset(btnObj, touchType)
  self:setRoleColor(255, 255, 255, 255, 255, 255, 255, 255, 255)
end
function ChangeColorViewTest:OnBtn_ChangeColor(btnObj, touchType)
end
