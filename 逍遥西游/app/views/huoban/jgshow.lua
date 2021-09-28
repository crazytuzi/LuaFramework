CJiuguanShow = class("CJiuguanShow", CcsSubView)
function CJiuguanShow:ctor()
  CJiuguanShow.super.ctor(self, "views/jg.json")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_ItemList = {}
  self.m_ShowList = self:getNode("list")
  self:SetList()
  self:SetHuobanNum()
  self:ListenMessage(MsgID_PlayerInfo)
end
function CJiuguanShow:SetList()
  local minCanGetIndex = 1
  for i = 1, MAX_JIUGUAN_FRIEND_HERO_NUM do
    local jgIndex = data_getJiuguanIndexByShowNo(i)
    local item = CJiuguanOneHero.new(jgIndex)
    self:getNode("list"):pushBackCustomItem(item:getUINode())
    self.m_ItemList[#self.m_ItemList + 1] = item
    local zs = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ZHUANSHENG)
    local lv = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ROLELEVEL)
    local needZs, needLv, alwaysJudgeLvFlag = data_getJiuguanNeedZsLvData(jgIndex)
    local lvEnough = data_judgeFuncOpen(zs, lv, needZs, needLv, alwaysJudgeLvFlag)
    if lvEnough and i > minCanGetIndex then
      minCanGetIndex = i
    end
  end
  self.m_CurIndex = 1
  self:LoadRole()
  local pro, tb, cp = g_MissionMgr:getMissionProgress(10017)
  if pro ~= nil and cp ~= nil and cp ~= true then
    minCanGetIndex = 1
  end
  self:ScrollToIndexRole(minCanGetIndex)
end
function CJiuguanShow:ScrollToIndexRole(index)
  self.m_ShowList:refreshView()
  local cnt = #self.m_ItemList
  local w = self.m_ShowList:getContentSize().width
  local iw = self.m_ShowList:getInnerContainerSize().width
  if w < iw then
    local x = (1 - (index + 0.5) / cnt) * iw - w / 2
    local percent = (1 - x / (iw - w)) * 100
    percent = math.max(percent, 0)
    percent = math.min(percent, 100)
    self.m_ShowList:scrollToPercentHorizontal(percent, 0.3, false)
  end
end
function CJiuguanShow:SetHuobanNum()
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    self:getNode("txt_1"):setVisible(false)
    self:getNode("txt_numLimit"):setVisible(false)
    self:getNode("txt_add"):setVisible(false)
    return
  end
  self:getNode("txt_1"):setVisible(true)
  self:getNode("txt_numLimit"):setVisible(true)
  self:getNode("txt_add"):setVisible(true)
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
  local txt_numLimit = self:getNode("txt_numLimit")
  local maxNum = data_getWarNumLimit(zs, lv)
  txt_numLimit:setText(tostring(maxNum))
  local nextLv = data_getNextAddWarNumLimit(zs, lv)
  if nextLv == nil then
    self:getNode("txt_add"):setVisible(false)
  else
    self:getNode("txt_add"):setVisible(true)
    self:getNode("txt_add"):setText(string.format("(%d级后+1)", nextLv))
  end
end
function CJiuguanShow:LoadRole()
  if self.m_CurIndex > MAX_JIUGUAN_FRIEND_HERO_NUM then
    return
  end
  local delayTime = 0.02
  local act1 = CCDelayTime:create(delayTime)
  local act2 = CCCallFunc:create(function()
    local tempItem = self.m_ItemList[self.m_CurIndex]
    if tempItem then
      tempItem:SetHeroHead()
    end
    self.m_CurIndex = self.m_CurIndex + 1
    self:LoadRole()
  end)
  self:runAction(transition.sequence({act1, act2}))
end
function CJiuguanShow:OnBtn_Close(btnObj, touchType)
  g_HuobanView:OnBtn_Close()
end
function CJiuguanShow:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_HeroUpdate then
    local playerId = arg[1].pid
    local heroId = arg[1].heroId
    local player = g_DataMgr:getPlayer(playerId)
    if playerId ~= g_LocalPlayer:getPlayerId() then
      return
    end
    if player == nil or heroId == nil then
      return
    end
    if heroId ~= player:getMainHeroId() then
      return
    end
    local lv = arg[1].pro[PROPERTY_ROLELEVEL]
    local zs = arg[1].pro[PROPERTY_ZHUANSHENG]
    if lv ~= nil or zs ~= nil then
      self:SetHuobanNum()
    end
  end
end
function CJiuguanShow:Clear()
  if g_LocalPlayer == nil then
    return
  end
  local tempList = {}
  for i = 1, MAX_JIUGUAN_FRIEND_HERO_NUM do
    local enoughLevel = true
    local zs = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ZHUANSHENG)
    local lv = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ROLELEVEL)
    local needZs, needLv, alwaysJudgeLvFlag = data_getJiuguanNeedZsLvData(i)
    local lvEnough = data_judgeFuncOpen(zs, lv, needZs, needLv, alwaysJudgeLvFlag)
    if lvEnough == false then
      enoughLevel = false
    end
    if enoughLevel then
      tempList[#tempList + 1] = i
    end
  end
  if g_CMainMenuHandler then
    g_CMainMenuHandler:SetJGShowHuobanList(tempList)
    g_CMainMenuHandler:ShowBtnLightCircle(g_CMainMenuHandler.btn_menu_huoban, false)
  end
end
CJiuguanOneHero = class("CJiuguanOneHero", CcsSubView)
function CJiuguanOneHero:ctor(index)
  CJiuguanOneHero.super.ctor(self, "views/jg_item.json")
  clickArea_check.extend(self)
  self.m_Index = index
  local mainHero = g_LocalPlayer:getMainHero()
  local zsList = mainHero:getProperty(PROPERTY_ZSTYPELIST)
  if type(zsList) ~= "table" then
    zsList = {}
  end
  local mainHeroType = zsList[1] or 0
  if mainHeroType == 0 then
    mainHeroType = mainHero:getTypeId()
  end
  self.m_Shape = data_getJiuguanRole(mainHeroType, index)
  local btnBatchListener = {
    btn_get = {
      listener = handler(self, self.OnBtn_Get),
      variName = "btn_get"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:SetHeroData()
  self:UpdateState()
  if g_MissionMgr then
    g_MissionMgr:registerClassObj(self, self.__cname, nil, index)
  end
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_PlayerInfo)
end
function CJiuguanOneHero:SetHeroData()
  self:getNode("rolepos"):setVisible(false)
  local shape, name = data_getRoleShapeAndName(self.m_Shape)
  self:getNode("name"):setText(name)
  local color = ccc3(78, 47, 20)
  self:getNode("name"):setColor(color)
  local attrstr = data_getRoleSkillDes(self.m_Shape)
  self:getNode("attrtxt"):setText(attrstr)
  local needZs, needLv, alwaysJudgeLvFlag = data_getJiuguanNeedZsLvData(self.m_Index)
  self:getNode("txt_lv"):setText(string.format("%s", needLv))
  local resType, resNum
  local isFree = false
  if data_getJiuguanGold(self.m_Index) > 0 then
    resType = RESTYPE_GOLD
    resNum = data_getJiuguanGold(self.m_Index)
  elseif 0 < data_getJiuguanCoin(self.m_Index) then
    resType = RESTYPE_COIN
    resNum = data_getJiuguanCoin(self.m_Index)
  else
    isFree = true
  end
  local tempImg
  if isFree then
    self:getNode("txt_coin"):setText("免费")
    self:getNode("txt_coin"):setAnchorPoint(ccp(0.5, 0.5))
    local x, y = self:getNode("txt_coin"):getPosition()
    x, _ = self:getNode("txt_lv"):getPosition()
    self:getNode("txt_coin"):setPosition(ccp(x, y))
  else
    self:getNode("txt_coin"):setText(string.format("%s", resNum))
    local x, y = self:getNode("coinbox"):getPosition()
    local z = self:getNode("coinbox"):getZOrder()
    local size = self:getNode("coinbox"):getSize()
    tempImg = display.newSprite(data_getResPathByResID(resType))
    tempImg:setAnchorPoint(ccp(0, 0))
    tempImg:setScale(size.width / tempImg:getContentSize().width)
    tempImg:setPosition(ccp(x, y + 3))
    self:addNode(tempImg, z)
  end
end
function CJiuguanOneHero:SetHeroHead()
  local shape, name = data_getRoleShapeAndName(self.m_Shape)
  local delY = 0
  local rolePosObj = self:getNode("rolepos")
  local x, y = rolePosObj:getPosition()
  local size = rolePosObj:getContentSize()
  local z = rolePosObj:getZOrder()
  local path, offx, offy = data_getBodyPathByShapeForDlg(shape)
  if path:sub(-6) == ".plist" then
    path = path:sub(1, -6) .. "png"
  else
    path = path .. ".png"
  end
  addDynamicLoadTexture(path, function(handlerName, texture)
    if self.__isExist then
      self.m_RoleAni, offx, offy = createBodyByShapeForDlg(shape)
      self:addNode(self.m_RoleAni, z + 1)
      self.m_RoleAni:setPosition(x + offx + size.width / 2, y + offy + delY)
      self:addclickAniForHeroAni(self.m_RoleAni, rolePosObj, size.width / 2, delY)
    end
  end, {pixelFormat = kCCTexture2DPixelFormat_RGBA4444})
  self.m_RoleShadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  self:addNode(self.m_RoleShadow, z)
  self.m_RoleShadow:setPosition(x + size.width / 2, y + delY)
end
function CJiuguanOneHero:UpdateState()
  local resType, resNum
  local isFree = false
  if data_getJiuguanGold(self.m_Index) > 0 then
    resType = RESTYPE_GOLD
    resNum = data_getJiuguanGold(self.m_Index)
  elseif 0 < data_getJiuguanCoin(self.m_Index) then
    resType = RESTYPE_COIN
    resNum = data_getJiuguanCoin(self.m_Index)
  else
    isFree = true
  end
  local enoughMoney = true
  self:getNode("txt_coin"):setColor(ccc3(255, 255, 255))
  if isFree == false then
    if resType == RESTYPE_COIN then
      if resNum > g_LocalPlayer:getCoin() then
        enoughMoney = false
        self:getNode("txt_coin"):setColor(ccc3(224, 84, 45))
      end
    elseif resType == RESTYPE_GOLD and resNum > g_LocalPlayer:getGold() then
      enoughMoney = false
      self:getNode("txt_coin"):setColor(ccc3(224, 84, 45))
    end
  end
  local enoughLevel = true
  local zs = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ZHUANSHENG)
  local lv = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ROLELEVEL)
  local needZs, needLv, alwaysJudgeLvFlag = data_getJiuguanNeedZsLvData(self.m_Index)
  local lvEnough = data_judgeFuncOpen(zs, lv, needZs, needLv, alwaysJudgeLvFlag)
  if lvEnough == false then
    enoughLevel = false
    self:getNode("txt_lv"):setColor(ccc3(224, 84, 45))
  else
    self:getNode("txt_lv"):setColor(ccc3(255, 255, 255))
  end
  local isOpen = false
  for _, temp in pairs(g_LocalPlayer:getJiuguanOpenList()) do
    if temp == self.m_Index then
      isOpen = true
      break
    end
  end
  if isOpen then
    self.btn_get:setTitleText("已招募")
    self:getNode("txt_lv"):setColor(ccc3(255, 255, 255))
    self:getNode("txt_coin"):setColor(ccc3(255, 255, 255))
  else
    self.btn_get:setTitleText("招募")
  end
  if enoughMoney and enoughLevel and not isOpen then
    if self.btn_get.redIcon == nil then
      local redIcon = display.newSprite("views/pic/pic_tipnew.png")
      self.btn_get:addNode(redIcon, 0)
      redIcon:setPosition(ccp(60, 20))
      self.btn_get.redIcon = redIcon
    end
  elseif self.btn_get.redIcon then
    self.btn_get.redIcon:removeFromParent()
    self.btn_get.redIcon = nil
  end
end
function CJiuguanOneHero:OnBtn_Get(btnObj, touchType)
  local curTime = cc.net.SocketTCP.getTime()
  if self.m_LastClickTime ~= nil and curTime - self.m_LastClickTime < 0.5 then
    return
  end
  self.m_LastClickTime = curTime
  local isOpen = false
  for _, temp in pairs(g_LocalPlayer:getJiuguanOpenList()) do
    if temp == self.m_Index then
      isOpen = true
      break
    end
  end
  if isOpen then
    ShowNotifyTips("该伙伴已招募")
    return
  end
  local zs = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ZHUANSHENG)
  local lv = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ROLELEVEL)
  local needZs, needLv, alwaysJudgeLvFlag = data_getJiuguanNeedZsLvData(self.m_Index)
  local lvEnough = data_judgeFuncOpen(zs, lv, needZs, needLv, alwaysJudgeLvFlag)
  if lvEnough == false then
    ShowNotifyTips("等级不足")
    return
  end
  local resType, resNum
  local isFree = false
  if data_getJiuguanGold(self.m_Index) > 0 then
    resType = RESTYPE_GOLD
    resNum = data_getJiuguanGold(self.m_Index)
  elseif 0 < data_getJiuguanCoin(self.m_Index) then
    resType = RESTYPE_COIN
    resNum = data_getJiuguanCoin(self.m_Index)
  else
    isFree = true
  end
  if isFree == false and resType == RESTYPE_GOLD and resNum > g_LocalPlayer:getGold() then
    ShowNotifyTips("元宝不足")
    ShowRechargeView()
    return
  end
  netsend.netjiuguan.askGetFriend(self.m_Index)
end
function CJiuguanOneHero:Clear()
  self:RemoveAllMessageListener()
  if g_MissionMgr then
    g_MissionMgr:unRegisterClassObj(self, self.__cname, nil)
  end
end
function CJiuguanOneHero:OnMessage(msgSID, ...)
  if msgSID == MsgID_HeroUpdate then
    self:UpdateState()
  elseif msgSID == MsgID_JiuguanOpenListUpdate then
    self:UpdateState()
  elseif msgSID == MsgID_MoneyUpdate then
    self:UpdateState()
  end
end
