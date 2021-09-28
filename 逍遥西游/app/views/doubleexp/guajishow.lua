function CanGuajiInMap(mapId)
  print("CanGuajiInMap", mapId)
  if g_LocalPlayer == nil then
    return false
  end
  local lvFlag = true
  local heroObj = g_LocalPlayer:getMainHero()
  local curZs = 0
  local curLv = 0
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return false
  end
  if activity.tianting:isInFb() then
    ShowNotifyTips("天庭任务中无法使用该功能")
    return false
  end
  if activity.tiandiqishu:isInFb() then
    ShowNotifyTips("天地奇书任务中无法使用该功能")
    return false
  end
  if g_MapMgr:isInDayanta() == true then
    ShowNotifyTips("大雁塔副本中无法使用该功能")
    return false
  end
  if g_LocalPlayer:getPlayerIsInTeam() and g_LocalPlayer:getPlayerInTeamAndIsCaptain() == false and g_TeamMgr:getLocalPlayerTeamState() == TEAMSTATE_FOLLOW then
    ShowNotifyTips("你已跟随队长中，不能跳转")
    return false
  end
  if heroObj ~= nil then
    curZs = heroObj:getProperty(PROPERTY_ZHUANSHENG)
    curLv = heroObj:getProperty(PROPERTY_ROLELEVEL)
  end
  local data = data_GuaJi_Map[mapId]
  if data and data_judgeFuncOpen(curZs, curLv, data.UnlockZs, data.UnlockLv, data.AlwaysJudgeLvFlag) == false then
    local tips = ""
    local mapName = data.MapName
    if data.UnlockZs == 0 then
      tips = string.format("到达%d级后可进入%s", data.UnlockLv, mapName)
    else
      tips = string.format("到达%d转%d级后可进入%s", data.UnlockZs, data.UnlockLv, mapName)
    end
    ShowNotifyTips(tips)
    lvFlag = false
  end
  local canJumpFlag = true
  local str = g_LocalPlayer:getPlayerCanJumpToNpc()
  if str ~= true then
    ShowNotifyTips(str)
    canJumpFlag = false
  end
  if lvFlag and canJumpFlag then
    return true
  else
    return false
  end
end
function TellSerToStartGuaji()
  print("TellSerToStartGuaji")
  if g_LocalPlayer == nil then
    return
  end
  if g_MapMgr == nil then
    return
  end
  g_MapMgr:TellSerMyPosForce()
  netsend.netguaji.startGuaji()
end
function TellSerToStopGuaji()
  print("TellSerToStopGuaji")
  if g_LocalPlayer == nil then
    return
  end
  if g_LocalPlayer:getGuajiState() ~= GUAJI_STATE_OFF then
    netsend.netguaji.endGuaji()
  end
  StopGuaJi()
end
function StartGuaJi()
  print("StartGuaJi")
  if g_LocalPlayer == nil then
    return
  end
  if g_LocalPlayer:getPlayerIsInTeam() and g_LocalPlayer:getPlayerInTeamAndIsCaptain() == false and g_TeamMgr:getLocalPlayerTeamState() == TEAMSTATE_FOLLOW then
    return
  end
  local curMap = g_MapMgr:getCurMapId()
  if data_getIsGuajiMap(curMap) == false then
    ShowNotifyTips("不是挂机地图，不能挂机")
    return
  end
  if CanGuajiInMap(curMap) == false then
    return
  end
  local mapViewIns = g_MapMgr:getMapViewIns()
  if mapViewIns then
    mapViewIns:startGuaji()
  end
end
function StopGuaJi()
  if g_LocalPlayer == nil then
    return
  end
  if g_LocalPlayer:getPlayerIsInTeam() and g_LocalPlayer:getPlayerInTeamAndIsCaptain() == false and g_TeamMgr:getLocalPlayerTeamState() == TEAMSTATE_FOLLOW then
    return
  end
  print("StopGuaJi")
  local mapViewIns = g_MapMgr:getMapViewIns()
  if mapViewIns and mapViewIns:getIsGuajiFlag() then
    mapViewIns:endGuaji()
  end
end
function ShowSelectGuajiMap(teleporterId)
  print("ShowSelectGuajiMap", teleporterId)
  if g_LocalPlayer == nil then
    return
  end
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  local curMapId = g_MapMgr:getCurMapId()
  if activity.tianting:isInFb() and curMapId ~= activity.tianting.mapId then
    ShowNotifyTips("天庭任务中无法使用该功能")
    return
  end
  if activity.tiandiqishu:isInFb() and curMapId ~= activity.tiandiqishu.mapId then
    ShowNotifyTips("天地奇书任务中无法使用该功能")
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    ShowNotifyTips("帮战中无法使用此功能")
    return
  end
  if not activity.yzdd:canJumpMap() then
    return
  end
  if not g_DuleMgr:canJumpMap() then
    return
  end
  if JudgeIsInWar() then
    ShowNotifyTips("处于战斗中，不能跳转")
    return
  end
  if g_LocalPlayer:getPlayerIsInTeam() and g_LocalPlayer:getPlayerInTeamAndIsCaptain() == false and g_TeamMgr:getLocalPlayerTeamState() == TEAMSTATE_FOLLOW then
    print("LLLLLLLLLLLLLLLLLLLLLLLLLLLLL")
    ShowNotifyTips("你已跟随队长中，不能跳转")
    return
  end
  local mapList = TELEPOINT_2_MAP_DICT[teleporterId] or {}
  local heroObj = g_LocalPlayer:getMainHero()
  local curZs = 0
  local curLv = 0
  if heroObj ~= nil then
    curZs = heroObj:getProperty(PROPERTY_ZHUANSHENG)
    curLv = heroObj:getProperty(PROPERTY_ROLELEVEL)
  end
  local data = data_GuaJi_Map[mapList[1]]
  if data and data_judgeFuncOpen(curZs, curLv, data.UnlockZs, data.UnlockLv, data.AlwaysJudgeLvFlag) == false then
    if data.UnlockZs ~= 0 then
      ShowNotifyTips(string.format("%d转%d级开启", data.UnlockZs, data.UnlockLv))
    else
      ShowNotifyTips(string.format("%d级开启", data.UnlockLv))
    end
    return
  end
  getCurSceneView():addSubView({
    subView = CSelectGuajiShow.new({mapList = mapList}),
    zOrder = MainUISceneZOrder.menuView
  })
end
function ShowGuajiMenu()
  print("ShowGuajiMenu")
  if g_LocalPlayer == nil then
    return
  end
  if g_MapMgr == nil then
    return
  end
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
    ShowNotifyTips("帮战中无法使用此功能")
    return
  end
  if not activity.yzdd:canJumpMap() then
    return
  end
  if not g_DuleMgr:canJumpMap() then
    return
  end
  if JudgeIsInWar() then
    ShowNotifyTips("处于战斗中，不能跳转")
    return
  end
  getCurSceneView():addSubView({
    subView = CGuajiShow.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
CGuajiShow = class("CGuajiShow", CcsSubView)
function CGuajiShow:ctor(para)
  para = para or {}
  CGuajiShow.super.ctor(self, "views/guaji.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_xl = {
      listener = handler(self, self.OnBtn_XunLuo),
      variName = "btn_xl"
    },
    btn_double = {
      listener = handler(self, self.OnBtn_Double),
      variName = "btn_double"
    },
    btn_auto = {
      listener = handler(self, self.OnBtn_AutoAddBsd),
      variName = "btn_auto"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:ListenMessage(MsgID_Scene)
  self:ListenMessage(MsgID_PlayerInfo)
  self:SetMapList()
  self:SetGuajiState()
  self:SetSBDData()
  self:SetAutoAddBsdData()
end
function CGuajiShow:SetMapList()
  self.list_map = self:getNode("list")
  local mapList = {}
  local sortMapDict = {}
  local sortMapID = {}
  local heroObj = g_LocalPlayer:getMainHero()
  local curZs = 0
  local curLv = 0
  if heroObj ~= nil then
    curZs = heroObj:getProperty(PROPERTY_ZHUANSHENG)
    curLv = heroObj:getProperty(PROPERTY_ROLELEVEL)
  end
  for mapId, data in pairs(data_GuaJi_Map) do
    if curZs > data.UnlockZs then
      sortMapID[#sortMapID + 1] = data.warDataId
      sortMapDict[data.warDataId] = mapId
    elseif data.UnlockZs == curZs and curLv >= data.UnlockLv then
      sortMapID[#sortMapID + 1] = data.warDataId
      sortMapDict[data.warDataId] = mapId
    end
  end
  table.sort(sortMapID)
  for _, warID in ipairs(sortMapID) do
    local mapId = sortMapDict[warID]
    mapList[#mapList + 1] = mapId
  end
  self.m_ItemList = {}
  local tuijianIndex = 1
  for index, mapId in ipairs(mapList) do
    local item = CGuajiOneItem.new(mapId, "views/guaji_item.json")
    self.list_map:pushBackCustomItem(item:getUINode())
    self.m_ItemList[#self.m_ItemList + 1] = item
    if item:GetTuijianFlag() then
      tuijianIndex = index
    end
  end
  self.list_map:refreshView()
  local cnt = #mapList
  local w = self.list_map:getContentSize().width
  local iw = self.list_map:getInnerContainerSize().width
  if w < iw then
    local x = (1 - (tuijianIndex + 0.5) / cnt) * iw - w / 2
    local percent = (1 - x / (iw - w)) * 100
    percent = math.max(percent, 0)
    percent = math.min(percent, 100)
    self.list_map:scrollToPercentHorizontal(percent, 0.3, false)
  end
  self.m_CurIndex = 1
  if tuijianIndex ~= self.m_CurIndex then
    self.m_ItemList[tuijianIndex]:SetRole()
  end
  self:LoadRole()
end
function CGuajiShow:SetGuajiState()
  local inGuajiMap = self:GetIsInGuajiMap()
  if inGuajiMap then
    self:getNode("pic_point"):setVisible(false)
    self:getNode("txt_tips"):setVisible(false)
    self.btn_xl:setEnabled(true)
    self.btn_auto:setEnabled(true)
    self:getNode("txt_guajitips"):setVisible(true)
  else
    self:getNode("pic_point"):setVisible(true)
    self:getNode("txt_tips"):setVisible(true)
    self.btn_xl:setEnabled(false)
    self.btn_auto:setEnabled(false)
    self:getNode("txt_guajitips"):setVisible(false)
  end
end
function CGuajiShow:GetIsInGuajiMap()
  local curMap = g_MapMgr:getCurMapId()
  return data_getIsGuajiMap(curMap)
end
function CGuajiShow:SetSBDData()
  local doubleExpData = g_LocalPlayer:getDoubleExpData()
  local deP = doubleExpData.deP or 0
  self:getNode("text_sbd"):setText(tostring(deP))
end
function CGuajiShow:SetAutoAddBsdData()
  local tag = 999
  local btn = self.btn_auto
  local oldChild = btn:getVirtualRenderer():getChildByTag(tag)
  if g_LocalPlayer:getGuajiAutoAddBsd() == GUAJI_AUTOADDBSD_ON then
    if oldChild == nil then
      local tempSprite = display.newSprite("views/common/btn/selected.png")
      tempSprite:setAnchorPoint(ccp(-0.2, -0.3))
      btn:getVirtualRenderer():addChild(tempSprite, 1, tag)
    end
  elseif oldChild ~= nil then
    btn:getVirtualRenderer():removeChild(oldChild)
  end
end
function CGuajiShow:LoadRole()
  local delayTime = 0.02
  local act1 = CCDelayTime:create(delayTime)
  local act2 = CCCallFunc:create(function()
    local tempItem = self.m_ItemList[self.m_CurIndex]
    if tempItem then
      tempItem:SetRole()
      self.m_CurIndex = self.m_CurIndex + 1
      self:LoadRole()
    end
  end)
  self:runAction(transition.sequence({act1, act2}))
end
function CGuajiShow:OnBtn_XunLuo(btnObj, touchType)
  if self:GetIsInGuajiMap() then
    TellSerToStartGuaji()
    self:CloseSelf()
  end
end
function CGuajiShow:OnBtn_Double(btnObj, touchType)
  getCurSceneView():addSubView({
    subView = CDoubleExpView.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CGuajiShow:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CGuajiShow:OnBtn_AutoAddBsd(btnObj, touchType)
  if g_LocalPlayer:getGuajiAutoAddBsd() == GUAJI_AUTOADDBSD_OFF then
    netsend.netguaji.setAutoAddBSD(GUAJI_AUTOADDBSD_ON)
  else
    netsend.netguaji.setAutoAddBSD(GUAJI_AUTOADDBSD_OFF)
  end
end
function CGuajiShow:Clear()
end
function CGuajiShow:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Scene_CanGotoGuajiMap then
    self:CloseSelf()
  elseif msgSID == MsgID_GuajiUpdateAutoAddBsd then
    self:SetAutoAddBsdData()
  elseif msgSID == MsgID_DoubleExpUpdate then
    self:SetSBDData()
  end
end
CSelectGuajiShow = class("CSelectGuajiShow", CcsSubView)
function CSelectGuajiShow:ctor(para)
  para = para or {}
  self.m_MapList = para.mapList or {}
  CSelectGuajiShow.super.ctor(self, "views/guajimap_list.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:ListenMessage(MsgID_Scene)
  self:SetMapList()
end
function CSelectGuajiShow:SetMapList()
  self.list_map = self:getNode("list")
  local mapList = {}
  local heroObj = g_LocalPlayer:getMainHero()
  local curZs = 0
  local curLv = 0
  if heroObj ~= nil then
    curZs = heroObj:getProperty(PROPERTY_ZHUANSHENG)
    curLv = heroObj:getProperty(PROPERTY_ROLELEVEL)
  end
  for _, mapId in pairs(self.m_MapList) do
    data = data_GuaJi_Map[mapId]
    if curZs > data.UnlockZs then
      mapList[#mapList + 1] = mapId
    elseif data.UnlockZs == curZs and curLv >= data.UnlockLv then
      mapList[#mapList + 1] = mapId
    end
  end
  table.sort(mapList)
  self.m_ItemList = {}
  local tuijianIndex = 1
  for index, mapId in ipairs(mapList) do
    local item = CGuajiOneItem.new(mapId, "views/guajimap_item.json")
    self.list_map:pushBackCustomItem(item:getUINode())
    self.m_ItemList[#self.m_ItemList + 1] = item
    if item:GetTuijianFlag() then
      tuijianIndex = index
    end
  end
  self.list_map:refreshView()
  local cnt = #mapList
  local w = self.list_map:getContentSize().width
  local iw = self.list_map:getInnerContainerSize().width
  if w < iw then
    local x = (1 - (tuijianIndex + 0.5) / cnt) * iw - w / 2
    local percent = (1 - x / (iw - w)) * 100
    percent = math.max(percent, 0)
    percent = math.min(percent, 100)
    self.list_map:scrollToPercentHorizontal(percent, 0.3, false)
  end
  self.m_CurIndex = 1
  if tuijianIndex ~= self.m_CurIndex then
    self.m_ItemList[tuijianIndex]:SetRole()
  end
  self:LoadRole()
end
function CSelectGuajiShow:LoadRole()
  local delayTime = 0.02
  local act1 = CCDelayTime:create(delayTime)
  local act2 = CCCallFunc:create(function()
    local tempItem = self.m_ItemList[self.m_CurIndex]
    if tempItem then
      tempItem:SetRole()
      self.m_CurIndex = self.m_CurIndex + 1
      self:LoadRole()
    end
  end)
  self:runAction(transition.sequence({act1, act2}))
end
function CSelectGuajiShow:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CSelectGuajiShow:Clear()
end
function CSelectGuajiShow:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Scene_CanGotoGuajiMap then
    self:CloseSelf()
  end
end
CGuajiOneItem = class("CGuajiOneItem", CcsSubView)
function CGuajiOneItem:ctor(mapId, jsonPath)
  CGuajiOneItem.super.ctor(self, jsonPath)
  self.m_MapId = mapId
  self:SetMapData()
  local btnBatchListener = {
    btn_help = {
      listener = handler(self, self.OnBtn_Help),
      variName = "btn_help"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:getNode("rolepos"):setVisible(false)
  clickArea_check.extend(self)
  self.m_SetRoleFlag = false
end
function CGuajiOneItem:SetMapData()
  self:getNode("txt_name"):setText(data_GuaJi_Map[self.m_MapId].MapName or "")
  local minLv = data_GuaJi_Map[self.m_MapId].RecommandLv[1]
  local maxLv = data_GuaJi_Map[self.m_MapId].RecommandLv[2]
  self:getNode("txt_lv"):setText(string.format("%d-%d级", minLv, maxLv))
  local heroObj = g_LocalPlayer:getMainHero()
  local curLv = 0
  if heroObj ~= nil then
    curLv = heroObj:getProperty(PROPERTY_ROLELEVEL)
  end
  self.m_TuijianFlag = false
  if minLv <= curLv and maxLv >= curLv then
    local img = display.newSprite("views/pic/pic_tuijian.png")
    img:setAnchorPoint(ccp(0, 1))
    local size = self:getContentSize()
    img:setPosition(ccp(5, size.height - 2))
    self:addNode(img, 10)
    self.m_TuijianFlag = true
  end
end
function CGuajiOneItem:GetTuijianFlag()
  return self.m_TuijianFlag
end
function CGuajiOneItem:SetRole()
  if self.m_SetRoleFlag then
    return
  end
  self.m_SetRoleFlag = true
  local warId = data_getGuajiMapMinRateWarId(self.m_MapId)
  if warId == nil then
    return
  end
  local bossId, _ = data_getBossForWar(warId)
  if bossId == nil then
    return
  end
  local shape, name = data_getRoleShapeAndName(bossId)
  local delY = 0
  local rolePosObj = self:getNode("rolepos")
  local x, y = rolePosObj:getPosition()
  local size = rolePosObj:getContentSize()
  local z = rolePosObj:getZOrder()
  local path = data_getWarBodyPngPathByShape(shape, DIRECTIOIN_RIGHTDOWN)
  local dynamicLoadTextureMode = getBodyDynamicLoadTextureMode(shape)
  addDynamicLoadTexture(path, function(handlerName, texture)
    if self.__isExist then
      self.m_ShapeAni, offx, offy = createWarBodyByShape(shape, DIRECTIOIN_RIGHTDOWN)
      self.m_ShapeAni:setPosition(x + offx + size.width / 2, y + offy + delY)
      self:addNode(self.m_ShapeAni, z + 1)
      self.m_ShapeAni:playAniWithName("guard_" .. tostring(DIRECTIOIN_RIGHTDOWN), -1, nil)
      self:addclickAniForHeroAni(self.m_ShapeAni, rolePosObj, size.width / 2, 0, function()
        self:EnterMap()
      end, nil, handler(self, self.OnTouchRole))
    end
  end, {pixelFormat = dynamicLoadTextureMode})
  self.m_RoleShadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  self:addNode(self.m_RoleShadow, z)
  self.m_RoleShadow:setPosition(x + size.width / 2, y + delY)
end
function CGuajiOneItem:OnTouchRole(touch)
  if self.__isExist ~= true then
    return
  end
  if self.m_ShapeAni == nil then
    return
  end
  if touch then
    self.m_ShapeAni:setOpacity(150)
  else
    self.m_ShapeAni:setOpacity(255)
  end
end
function CGuajiOneItem:EnterMap()
  local mapId = self.m_MapId
  local minLv = data_GuaJi_Map[mapId].RecommandLv[1]
  local heroObj = g_LocalPlayer:getMainHero()
  local curLv = 0
  if heroObj ~= nil then
    curLv = heroObj:getProperty(PROPERTY_ROLELEVEL)
  end
  if minLv > curLv then
    local tempPop = CPopWarning.new({
      title = "提示",
      text = "此地图怪物等级较高,现在进入可能有危险,是否进入?",
      confirmFunc = function()
        if g_MapMgr then
          g_MapMgr:AskToEnterGuaji(self.m_MapId, nil, nil, nil, true)
        end
      end,
      align = CRichText_AlignType_Left,
      cancelFunc = nil,
      closeFunc = nil,
      confirmText = nil,
      cancelText = nil,
      hideInWar = true
    })
    tempPop:ShowCloseBtn(false)
  elseif g_MapMgr then
    g_MapMgr:AskToEnterGuaji(self.m_MapId, nil, nil, nil, true)
  end
end
function CGuajiOneItem:OnBtn_Help(btnObj, touchType)
  getCurSceneView():addSubView({
    subView = CGuajiDetail.new(self.m_MapId),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CGuajiOneItem:Clear()
end
CGuajiDetail = class("CGuajiDetail", CcsSubView)
function CGuajiDetail:ctor(mapId)
  self.m_MapId = mapId
  CGuajiDetail.super.ctor(self, "views/guaji_detail.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:SetMonsterData()
end
function CGuajiDetail:SetMonsterData()
  local mapName = data_GuaJi_Map[self.m_MapId].MapName or ""
  self:getNode("title"):setText(string.format("%s召唤兽", mapName))
  local normalList, bossList = data_getGuajiMapMonsterList(self.m_MapId)
  local w = self:getNode("pos_line1"):getContentSize().width
  local oldX, y = self:getNode("pos_line1"):getPosition()
  local index = 1
  local delW = 0
  local allW = #normalList * w + (#normalList - 1) * delW
  for _, npcID in ipairs(normalList) do
    local headIcon = createClickMonsterHead({
      roleTypeId = npcID,
      isBoss = false,
      autoSize = nil,
      clickListener = nil,
      noBgFlag = nil,
      offx = nil,
      offy = nil,
      clickDel = nil,
      LongPressTime = 0.2,
      LongPressListener = nil,
      LongPressEndListner = nil
    })
    self:addChild(headIcon)
    local mw = headIcon:getContentSize().width
    local x = oldX + w / 2 - allW / 2 + (index - 1) * (w + delW) - (mw - w) / 2
    headIcon:setPosition(ccp(x, y))
    index = index + 1
  end
  self:getNode("pos_line1"):setVisible(false)
  local oldX, y = self:getNode("pos_line2"):getPosition()
  local index = 1
  local delW = 10
  local allW = #bossList * w + (#bossList - 1) * delW
  for _, npcID in ipairs(bossList) do
    local headIcon = createClickMonsterHead({
      roleTypeId = npcID,
      isBoss = true,
      autoSize = nil,
      clickListener = nil,
      noBgFlag = nil,
      offx = nil,
      offy = nil,
      clickDel = nil,
      LongPressTime = 0.2,
      LongPressListener = nil,
      LongPressEndListner = nil
    })
    self:addChild(headIcon)
    local mw = headIcon:getContentSize().width
    local x = oldX + w / 2 - allW / 2 + (index - 1) * (w + delW) - (mw - w) / 2
    headIcon:setPosition(ccp(x, y))
    index = index + 1
  end
  self:getNode("pos_line2"):setVisible(false)
end
function CGuajiDetail:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CGuajiDetail:Clear()
end
