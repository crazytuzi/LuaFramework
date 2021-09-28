function ShowChangeRaceView()
  getCurSceneView():addSubView({
    subView = CChangeRaceView.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
CChangeRaceView = class(".CChangeRaceView", CcsSubView)
local BAGUA_ACTION_TIME = 0.5
function CChangeRaceView:ctor()
  CChangeRaceView.super.ctor(self, "views/zhongzuzhuanhuan_new.json", {isAutoCenter = true, opacityBg = 100})
  clickArea_check.extend(self)
  local btnBatchListener = {
    btn_ren = {
      listener = handler(self, self.OnBtn_Ren),
      variName = "btn_ren"
    },
    btn_mo = {
      listener = handler(self, self.OnBtn_Mo),
      variName = "btn_mo"
    },
    btn_xian = {
      listener = handler(self, self.OnBtn_Xian),
      variName = "btn_xian"
    },
    btn_gui = {
      listener = handler(self, self.OnBtn_Gui),
      variName = "btn_gui"
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_cancel"
    },
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_confirm"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_ren,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_mo,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_xian,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_gui,
      nil,
      ccc3(251, 248, 145)
    }
  })
  self:getNode("btn_beforeType"):setTouchEnabled(false)
  self:getNode("btn_afterType"):setTouchEnabled(false)
  self:getNode("btn_beforeType"):setEnabled(false)
  self:getNode("btn_afterType"):setEnabled(false)
  self.m_BaguaLayer = self:getNode("bagua")
  self.m_BaguaLeft = self:getNode("bagua1")
  self.m_BaguaRight = self:getNode("bagua2")
  self.m_P0 = self:getNode("point_0")
  self.m_P1 = self:getNode("point_1")
  self.m_P2 = self:getNode("point_2")
  self.m_TxtRace = self:getNode("txt_race")
  self.m_TxtSex = self:getNode("txt_sex")
  self.m_TxtWeapon = self:getNode("txt_weapon")
  self.m_DesText = nil
  self.m_FadeObjList = {
    "m_P0",
    "m_P1",
    "m_P2",
    "m_TxtRace",
    "m_TxtSex",
    "m_TxtWeapon",
    "m_DesText"
  }
  for i, objname in pairs(self.m_FadeObjList) do
    local obj = self[objname]
    if obj then
      obj:setVisible(false)
    end
  end
  self.m_SelectIcon = nil
  self.m_SelectRace = nil
  self.m_SelectZS = 0
  self.m_SelectTypeID = 0
  self.m_ShapeHeadList = {}
  self:SetCanChangeFlag(true)
  self.m_RoleBg = self:getNode("rolebg")
  self.m_RoleBg:getParent():reorderChild(self.m_RoleBg, -2)
  self:SetCurRoleShape()
  local mainHero = g_LocalPlayer:getMainHero()
  local name = mainHero:getProperty(PROPERTY_NAME)
  self:getNode("txt_name"):setText(name)
  local mainHero = g_LocalPlayer:getMainHero()
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local color = NameColor_MainHero[zs]
  self:getNode("txt_name"):setColor(color)
end
function CChangeRaceView:SetCurRoleShape()
  local mainHero = g_LocalPlayer:getMainHero()
  local typeID = mainHero:getTypeId()
  local race = data_getRoleRace(typeID)
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  self:SetSelectRace(race)
  self:SetSelectZS(zs)
  self:SetHeroHeadData()
  self:ChangeRole(typeID, false)
  if race == RACE_MO then
    self:setGroupBtnSelected(self.btn_mo)
  elseif race == RACE_REN then
    self:setGroupBtnSelected(self.btn_ren)
  elseif race == RACE_XIAN then
    self:setGroupBtnSelected(self.btn_xian)
  elseif race == RACE_GUI then
    self:setGroupBtnSelected(self.btn_gui)
  end
end
function CChangeRaceView:SetSelectRace(race)
  self.m_SelectRace = race
end
function CChangeRaceView:SetSelectZS(zsNum)
  self.m_SelectZS = zsNum
end
function CChangeRaceView:SetHeroHeadData()
  self.m_TypeList = {}
  local curZSNum = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ZHUANSHENG)
  local zs0List = data_getMainHeroIdsByRaceNZSheng(self.m_SelectRace, 0)
  local zs1List = data_getMainHeroIdsByRaceNZSheng(self.m_SelectRace, 1)
  table.sort(zs0List)
  table.sort(zs1List)
  if curZSNum == 0 then
    self.m_TypeList = {
      0,
      0,
      zs0List[2],
      0,
      0,
      zs0List[1]
    }
  else
    self.m_TypeList = {
      zs0List[1],
      zs0List[2],
      0,
      zs1List[2],
      zs1List[1],
      0
    }
  end
  for _, head in pairs(self.m_ShapeHeadList) do
    head:removeFromParent()
  end
  self.m_ShapeHeadList = {}
  if self.m_SelectIcon then
    self.m_SelectIcon:removeFromParent()
    self.m_SelectIcon = nil
  end
  for index, typeID in ipairs(self.m_TypeList) do
    if typeID ~= 0 then
      local head = createClickHead({
        roleTypeId = typeID,
        autoSize = nil,
        clickListener = function(...)
          self:ChangeRole(typeID)
        end,
        noBgFlag = true,
        offx = nil,
        offy = nil,
        clickDel = nil,
        LongPressTime = nil,
        LongPressListener = nil,
        LongPressEndListner = nil
      })
      local pos = self:getNode(string.format("headpos_%d", index))
      pos:addChild(head)
      head:setPosition(ccp(0, 8))
      self.m_ShapeHeadList[index] = head
    end
  end
end
function CChangeRaceView:ChangeRole(typeID, needToCloseFlag)
  if needToCloseFlag == false then
    needToCloseFlag = false
  else
    needToCloseFlag = true
  end
  if not self.m_CanChangeFlag then
    return
  end
  if self.m_SelectIcon then
    self.m_SelectIcon:removeFromParent()
    self.m_SelectIcon = nil
  end
  for index, tempID in pairs(self.m_TypeList) do
    if tempID == typeID then
      self.m_SelectIcon = display.newSprite("views/rolelist/pic_role_selected.png")
      local pos = self:getNode(string.format("headpos_%d", index))
      local x, y = pos:getPosition()
      self.m_SelectIcon:setAnchorPoint(ccp(0, 0))
      self:addNode(self.m_SelectIcon, 2)
      self.m_SelectIcon:setPosition(x - 4, y)
      break
    end
  end
  if self.m_SelectTypeID == typeID then
    return
  end
  self.m_SelectTypeID = typeID
  self:SetCanChangeFlag(false)
  local act_close = CCCallFunc:create(function()
    self:BaguaClose()
    self:FadeOutText()
  end)
  local act_wait1 = CCDelayTime:create(BAGUA_ACTION_TIME + 0.3)
  local act_changeRole = CCCallFunc:create(function()
    self:SetRoleData(typeID)
  end)
  local act_open = CCCallFunc:create(function()
    self:BaguaOpen()
    self:FadeInText()
  end)
  local act_wait2 = CCDelayTime:create(BAGUA_ACTION_TIME)
  local act_setFlag = CCCallFunc:create(function()
    self:SetCanChangeFlag(true)
  end)
  if needToCloseFlag then
    self:runAction(transition.sequence({
      act_close,
      act_wait1,
      act_changeRole,
      act_open,
      act_wait2,
      act_setFlag,
      act2
    }))
  else
    self:runAction(transition.sequence({
      act_wait1,
      act_changeRole,
      act_open,
      act_wait2,
      act_setFlag,
      act2
    }))
  end
end
function CChangeRaceView:SetCanChangeFlag(flag)
  self.m_CanChangeFlag = flag
  for _, head in pairs(self.m_ShapeHeadList) do
    head:setTouchEnabled(flag)
  end
  for _, tempName in pairs({
    "btn_ren",
    "btn_mo",
    "btn_xian",
    "btn_gui"
  }) do
    local btn = self[tempName]
    if btn then
      btn:setTouchEnabled(flag)
    end
  end
  self.btn_confirm:setTouchEnabled(flag)
  if self.m_RoleAni and self.m_RoleAni._addClickWidget then
    self.m_RoleAni._addClickWidget:setTouchEnabled(flag)
  end
end
function CChangeRaceView:SetRoleData(typeID)
  local shape = data_getRoleShape(typeID)
  local tempRoleAni
  if self.m_RoleAni ~= nil then
    tempRoleAni = self.m_RoleAni
  end
  local offx, offy = 0, 0
  local x, y = self.m_RoleBg:getPosition()
  local mainHero = g_LocalPlayer:getMainHero()
  local colorList = mainHero:getProperty(PROPERTY_RANCOLOR)
  if colorList == nil or colorList == 0 or type(colorList) == "table" and #colorList == 0 then
    colorList = {
      0,
      0,
      0
    }
  end
  self.m_RoleAni, offx, offy = createBodyByShapeForDlg(shape, colorList)
  self:addNode(self.m_RoleAni, -1)
  self.m_RoleAni:setPosition(x + offx, y + offy - 60)
  self:addclickAniForHeroAni(self.m_RoleAni, self.m_RoleBg, 0, -60)
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
  local gender = data_getRoleGender(typeID)
  local genderText = "男"
  if gender == HERO_FEMALE then
    genderText = "女"
  end
  self.m_TxtRace:setText("性别 " .. genderText)
  local race = data_getRoleRace(typeID)
  local raceText = RACENAME_DICT[race] or RACENAME_DICT[RACE_REN]
  self.m_TxtSex:setText("种族 " .. raceText)
  local weaponText = data_getRoleWeapon(typeID)
  self.m_TxtWeapon:setText("武器 " .. weaponText)
  local des = data_getRoleDes(typeID)
  if self.m_DesText then
    self.m_DesText:removeFromParent()
    self.m_DesText = nil
  end
  local size = self:getNode("despos"):getContentSize()
  local x, y = self:getNode("despos"):getPosition()
  self.m_DesText = CRichText.new({
    width = size.width,
    color = ccc3(255, 255, 255),
    fontSize = 20
  })
  self.m_DesText:addRichText(des)
  local desSize = self.m_DesText:getContentSize()
  self.m_DesText:setPosition(ccp(x, y + size.height - desSize.height))
  self:addChild(self.m_DesText)
  self.m_DesText:setVisible(false)
end
function CChangeRaceView:FadeOutText()
  for i, objname in pairs(self.m_FadeObjList) do
    local obj = self[objname]
    if obj then
      if obj == self.m_DesText then
        obj:FadeOut(BAGUA_ACTION_TIME)
      else
        obj:stopAllActions()
        local act = CCFadeOut:create(BAGUA_ACTION_TIME)
        obj:runAction(act)
      end
    end
  end
end
function CChangeRaceView:FadeInText()
  for i, objname in pairs(self.m_FadeObjList) do
    local obj = self[objname]
    if obj then
      obj:setVisible(true)
      if obj == self.m_DesText then
        obj:FadeIn(BAGUA_ACTION_TIME)
      else
        obj:stopAllActions()
        local act = CCFadeIn:create(BAGUA_ACTION_TIME)
        obj:runAction(act)
      end
    end
  end
end
function CChangeRaceView:BaguaOpen()
  local rotate1 = -100
  local rotate2 = -500
  local act1 = CCRotateTo:create(BAGUA_ACTION_TIME, rotate1)
  local act2 = CCRotateTo:create(BAGUA_ACTION_TIME, rotate1)
  local act3 = CCRotateTo:create(BAGUA_ACTION_TIME, rotate2)
  self.m_BaguaLeft:runAction(act1)
  self.m_BaguaRight:runAction(act2)
  self.m_BaguaLayer:runAction(act3)
end
function CChangeRaceView:BaguaClose()
  local rotate1 = 0
  local rotate2 = 360
  local act1 = CCRotateTo:create(BAGUA_ACTION_TIME, rotate1)
  local act2 = CCRotateTo:create(BAGUA_ACTION_TIME, rotate1)
  local act3 = CCRotateTo:create(BAGUA_ACTION_TIME, rotate2)
  self.m_BaguaLeft:runAction(act1)
  self.m_BaguaRight:runAction(act2)
  self.m_BaguaLayer:runAction(act3)
end
function CChangeRaceView:BtnSelectRace(race)
  if self.m_SelectRace == race then
    return
  end
  self:SetSelectRace(race)
  self:SetHeroHeadData()
end
function CChangeRaceView:OnBtn_Ren(btnObj, touchType)
  self:BtnSelectRace(RACE_REN)
end
function CChangeRaceView:OnBtn_Mo(btnObj, touchType)
  self:BtnSelectRace(RACE_MO)
end
function CChangeRaceView:OnBtn_Xian(btnObj, touchType)
  self:BtnSelectRace(RACE_XIAN)
end
function CChangeRaceView:OnBtn_Gui(btnObj, touchType)
  self:BtnSelectRace(RACE_GUI)
end
function CChangeRaceView:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CChangeRaceView:OnBtn_Confirm(btnObj, touchType)
  local mainHero = g_LocalPlayer:getMainHero()
  local shape = mainHero:getProperty(PROPERTY_SHAPE)
  if self.m_SelectTypeID == shape then
    ShowNotifyTips("你选定的人物造型和现在一样，无需转换。")
    return
  end
  netsend.netbaseptc.requestChangeRace(self.m_SelectTypeID)
end
function CChangeRaceView:Clear()
end
