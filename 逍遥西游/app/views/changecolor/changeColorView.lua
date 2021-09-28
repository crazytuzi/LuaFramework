ChangeColorView = class("ChangeColorView", CcsSubView)
local POSNUM = 3
local COLORNUM = 4
local COLORLIST = {
  0,
  2,
  3,
  4
}
function SetOneBodyChangeColor(body, shape, colorList)
  if body then
    for i = 1, POSNUM do
      local tempData = colorList or {
        0,
        0,
        0
      }
      local r, g, b, a = data_getRGBRanColor(shape, i, tempData[i])
      if i == 1 then
        pos = 2
      elseif i == 2 then
        pos = 4
      elseif i == 3 then
        pos = 3
      end
      body:setColorful(pos, ccc4(r, g, b, a))
    end
  end
end
function SetOneBodyChangeColorWithLocalPlayerColor(body)
  if g_LocalPlayer and body then
    local mainRole = g_LocalPlayer:getMainHero()
    if mainRole then
      local colorList = mainRole:getProperty(PROPERTY_RANCOLOR)
      local shapeId = data_getRoleShape(mainRole:getTypeId())
      SetOneBodyChangeColor(body, shapeId, colorList)
    end
  end
end
function ChangeColorView:ctor(para)
  ChangeColorView.super.ctor(self, "views/changecolor.json", {isAutoCenter = true, opacityBg = 100})
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
      btnBatchListener[btnName] = {
        listener = handler(self, self[string.format("OnBtn_SetColor%d", btnNum)]),
        variName = btnName
      }
    end
    local btnNum = j * 10 + 4
    local btnName = string.format("btn_%d", btnNum)
    self:getNode(btnName):setEnabled(false)
  end
  self:addBatchBtnListener(btnBatchListener)
  self.m_RoleAni = nil
  self.m_DirNum = nil
  self.m_RunFlag = nil
  self.m_NeedRLNum = nil
  self.m_ColorData = nil
  self.m_OldColorData = g_LocalPlayer:getMainHero():getProperty(PROPERTY_RANCOLOR)
  if self.m_OldColorData == nil or self.m_OldColorData == 0 or type(self.m_OldColorData) == "table" and #self.m_OldColorData == 0 then
    self.m_OldColorData = {
      0,
      0,
      0
    }
  end
  self:setRoleShape()
  self:setRoleDir(DIRECTIOIN_DOWN)
  self:setRoleRunFlag(false)
  self:setRoleColor(self.m_OldColorData)
  for pos = 1, POSNUM do
    self:SetOneColorBtnSelect(pos, self.m_ColorData[pos])
  end
  self:ListenMessage(MsgID_PlayerInfo)
end
function ChangeColorView:setRoleShape()
  local shape = g_LocalPlayer:getMainHero():getProperty(PROPERTY_SHAPE)
  self.role_aureole = self:getNode("role_aureole")
  self.role_aureole:setVisible(false)
  local x, y = self.role_aureole:getPosition()
  local parent = self.role_aureole:getParent()
  local z = self.role_aureole:getZOrder()
  if self.m_RoleAni == nil or self.m_RoleAni._shape ~= shape then
    if self.m_RoleAni ~= nil then
      if self.m_RoleAni._addClickWidget then
        self.m_RoleAni._addClickWidget:removeFromParentAndCleanup(true)
        self.m_RoleAni._addClickWidget = nil
      end
      self.m_RoleAni:removeFromParentAndCleanup(true)
      self.m_RoleAni = nil
    end
    local offx, offy = 0, 0
    self.m_RoleAni, offx, offy = createBodyByRoleTypeID(shape)
    parent:addNode(self.m_RoleAni, z + 10)
    self.m_RoleAni:setPosition(x + offx, y + offy)
    local function clickFunc()
      self:setRoleRunFlag(not self.m_RunFlag)
    end
    self:addclickAniForHeroAni(self.m_RoleAni, self.role_aureole, 0, 0, clickFunc)
    self.m_RoleAni:setVisible(false)
    local act1 = CCDelayTime:create(0.01)
    local act2 = CCCallFunc:create(function()
      self.m_RoleAni:setVisible(true)
    end)
    self.m_RoleAni:runAction(transition.sequence({act1, act2}))
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
function ChangeColorView:setRoleDir(dirNum)
  if self.m_DirNum == dirNum then
    return
  end
  self.m_DirNum = dirNum
  if self.m_RoleAni then
    self:flushAni()
  end
end
function ChangeColorView:setRoleRunFlag(flag)
  if self.m_RunFlag == flag then
    return
  end
  self.m_RunFlag = flag
  if self.m_RoleAni then
    self:flushAni()
  end
end
function ChangeColorView:setRoleColor(colorData)
  local pos1ColorNum = colorData[1] or 0
  local pos2ColorNum = colorData[2] or 0
  local pos3ColorNum = colorData[3] or 0
  if self.m_ColorData ~= nil and self.m_ColorData[1] == pos1ColorNum and self.m_ColorData[2] == pos2ColorNum and self.m_ColorData[3] == pos3ColorNum then
    self:SetItemNum()
    return
  end
  self.m_ColorData = {
    pos1ColorNum,
    pos2ColorNum,
    pos3ColorNum
  }
  if self.m_RoleAni then
    self:flushAni()
  end
  self:SetItemNum()
end
function ChangeColorView:flushAni()
  local shape = g_LocalPlayer:getMainHero():getProperty(PROPERTY_SHAPE)
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
    SetOneBodyChangeColor(self.m_RoleAni, shape, self.m_ColorData)
  end
end
function ChangeColorView:SetItemNum()
  local num = 0
  for pos, oldColor in pairs(self.m_OldColorData) do
    local newColor = self.m_ColorData[pos]
    if newColor ~= oldColor then
      num = num + data_getNeedRanLiaoNum(pos, newColor)
    end
  end
  self.m_NeedRLNum = num
  local posObj = self:getNode("box_item")
  local s = posObj:getContentSize()
  if self.m_ItemObj == nil then
    local s = posObj:getContentSize()
    icon = createClickItem({
      itemID = ITEM_DEF_STUFF_RANLIAO,
      autoSize = nil,
      num = 0,
      LongPressTime = 0,
      clickListener = nil,
      LongPressListener = nil,
      LongPressEndListner = nil,
      clickDel = nil,
      noBgFlag = true
    })
    local size = icon:getContentSize()
    icon:setPosition(ccp(-size.width / 2, -size.height / 2))
    posObj:addChild(icon)
    posObj:setVisible(true)
    self.m_ItemObj = icon
  end
  local curNum = g_LocalPlayer:GetItemNum(ITEM_DEF_STUFF_RANLIAO)
  local numText = string.format("%s/%s", curNum, self.m_NeedRLNum)
  if posObj._posNum == nil then
    local numLabel = CCLabelTTF:create(numText, ITEM_NUM_FONT, 22)
    numLabel:setAnchorPoint(ccp(1, 0))
    numLabel:setPosition(ccp(s.width / 2 - 5, -s.height / 2 + 5))
    posObj:addNode(numLabel)
    posObj._posNum = numLabel
  else
    posObj._posNum:setString(numText)
  end
  if curNum >= self.m_NeedRLNum then
    posObj._posNum:setColor(VIEW_DEF_PGREEN_COLOR)
  else
    posObj._posNum:setColor(VIEW_DEF_WARNING_COLOR)
  end
  AutoLimitObjSize(posObj._posNum, 70)
end
function ChangeColorView:Clear()
  if self.m_CallBack then
    self.m_CallBack()
  end
end
function ChangeColorView:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function ChangeColorView:OnBtn_Left(btnObj, touchType)
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
function ChangeColorView:OnBtn_Right(btnObj, touchType)
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
function ChangeColorView:SetOnePosColor(pos, colorV)
  local newColor = DeepCopyTable(self.m_ColorData or {})
  newColor[pos] = colorV
  self:setRoleColor(newColor)
  self:SetOneColorBtnSelect(pos, colorV)
end
function ChangeColorView:SetOneColorBtnSelect(pos, colorV)
  for i = 1, COLORNUM do
    local tempBtn = self[string.format("btn_%d%d", pos, i - 1)]
    if tempBtn and tempBtn._SelectFlag then
      tempBtn._SelectFlag:removeFromParent()
      tempBtn._SelectFlag = nil
    end
  end
  local btn = self[string.format("btn_%d%d", pos, colorV)]
  if btn then
    local tempSprite = display.newSprite("views/common/btn/selected.png")
    tempSprite:setAnchorPoint(ccp(0.3, 0.3))
    btn:addNode(tempSprite, 1)
    btn._SelectFlag = tempSprite
  end
end
function ChangeColorView:OnBtn_Random(btnObj, touchType)
  for pos = 1, POSNUM do
    local tempColorList = {}
    for color = 1, COLORNUM do
      if self.m_OldColorData[pos] ~= color - 1 then
        tempColorList[#tempColorList + 1] = color - 1
      end
    end
    local randomColor = 0
    local randomIndex = math.floor(math.random(1, 10000)) % #tempColorList
    randomColor = tempColorList[randomIndex + 1]
    self:SetOnePosColor(pos, randomColor)
  end
end
function ChangeColorView:OnBtn_Reset(btnObj, touchType)
  for pos = 1, POSNUM do
    self:SetOnePosColor(pos, self.m_OldColorData[pos])
  end
end
function ChangeColorView:OnBtn_ChangeColor(btnObj, touchType)
  local pos1ColorNum = self.m_OldColorData[1] or 0
  local pos2ColorNum = self.m_OldColorData[2] or 0
  local pos3ColorNum = self.m_OldColorData[3] or 0
  if self.m_ColorData ~= nil and self.m_ColorData[1] == pos1ColorNum and self.m_ColorData[2] == pos2ColorNum and self.m_ColorData[3] == pos3ColorNum then
    ShowNotifyTips("你没有修改染色")
    return
  end
  netsend.netbaseptc.requestSetRanColor(self.m_ColorData)
end
function ChangeColorView:OnBtn_SetColor10(btnObj, touchType)
  self:SetOnePosColor(1, 0)
end
function ChangeColorView:OnBtn_SetColor11(btnObj, touchType)
  self:SetOnePosColor(1, 1)
end
function ChangeColorView:OnBtn_SetColor12(btnObj, touchType)
  self:SetOnePosColor(1, 2)
end
function ChangeColorView:OnBtn_SetColor13(btnObj, touchType)
  self:SetOnePosColor(1, 3)
end
function ChangeColorView:OnBtn_SetColor14(btnObj, touchType)
  self:SetOnePosColor(1, 4)
end
function ChangeColorView:OnBtn_SetColor20(btnObj, touchType)
  self:SetOnePosColor(2, 0)
end
function ChangeColorView:OnBtn_SetColor21(btnObj, touchType)
  self:SetOnePosColor(2, 1)
end
function ChangeColorView:OnBtn_SetColor22(btnObj, touchType)
  self:SetOnePosColor(2, 2)
end
function ChangeColorView:OnBtn_SetColor23(btnObj, touchType)
  self:SetOnePosColor(2, 3)
end
function ChangeColorView:OnBtn_SetColor24(btnObj, touchType)
  self:SetOnePosColor(2, 4)
end
function ChangeColorView:OnBtn_SetColor30(btnObj, touchType)
  self:SetOnePosColor(3, 0)
end
function ChangeColorView:OnBtn_SetColor31(btnObj, touchType)
  self:SetOnePosColor(3, 1)
end
function ChangeColorView:OnBtn_SetColor32(btnObj, touchType)
  self:SetOnePosColor(3, 2)
end
function ChangeColorView:OnBtn_SetColor33(btnObj, touchType)
  self:SetOnePosColor(3, 3)
end
function ChangeColorView:OnBtn_SetColor34(btnObj, touchType)
  self:SetOnePosColor(3, 4)
end
function ChangeColorView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  local hid = g_LocalPlayer:getMainHeroId()
  if msgSID == MsgID_HeroUpdate then
    local d = arg[1]
    if d.heroId == hid and d.pro ~= nil and d.pro[PROPERTY_RANCOLOR] ~= nil then
      self.m_OldColorData = DeepCopyTable(d.pro[PROPERTY_RANCOLOR])
      self:setRoleColor(self.m_OldColorData)
    end
  end
end
