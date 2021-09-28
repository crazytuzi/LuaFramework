local roleMaxZ = 10000
local warsetting = class("warsetting", CcsSubView)
function warsetting:ctor()
  warsetting.super.ctor(self, "views/warsetting.json", {isAutoCenter = true, opacityBg = 100})
  self.m_RoleShapes = {}
  local btnBatchListener = {
    buttonWar_del = {
      listener = handler(self, self.Btn_WarDel),
      variName = "m_buttonWarDel"
    },
    buttonBack = {
      listener = handler(self, self.Btn_Save),
      variName = "m_buttonBack",
      param = {3}
    },
    buttonSetting = {
      listener = handler(self, self.Btn_DrugSetting),
      variName = "m_buttonSetting"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.pic_arrow_down = self:getNode("pic_arrow_down")
  self.pos_sel = self:getNode("pos_sel")
  self:setAllGridsNotSelected()
  self:initRoleList()
  self:initMainRoleShape()
  self.m_ClickRoleShapePos = nil
  self.m_buttonWarDel:setVisible(false)
  self:ListenMessage(MsgID_PlayerInfo)
end
function warsetting:setRoleListTouchEventListener()
  local listLen = self.m_RoleList:getCount()
  if listLen < 4 then
    self.pic_arrow_down:setVisible(false)
    self.m_RoleList:addTouchEventListenerScrollView(nil)
  else
    self.pic_arrow_down:setVisible(true)
    self.m_RoleList:addTouchEventListenerScrollView(function(item, event)
      self:OnRoleListScrollEvent(event)
    end)
  end
end
function warsetting:OnRoleListScrollEvent(event)
  if event == SCROLLVIEW_EVENT_SCROLL_TO_BOTTOM or event == SCROLLVIEW_EVENT_BOUNCE_BOTTOM then
    self.pic_arrow_down:setVisible(false)
  else
    self.pic_arrow_down:setVisible(true)
  end
end
function warsetting:OnMessage(msgSID, ...)
  if msgSID == MsgID_WarSettingSuccess then
    local arg = {
      ...
    }
    if self.m_SaveInfo ~= nil then
      g_LocalPlayer:setWarSetting(self.m_SaveInfo)
      ShowNotifyTips("出战设置保存成功")
      self:CloseSelf()
    end
  elseif msgSID == MsgID_WarDrugSettingSuccess then
    ShowNotifyTips("出战吃药设置保存成功")
  end
end
function warsetting:getRoleInfo(roleID)
  local roleObj = g_LocalPlayer:getObjById(roleID)
  if not roleObj then
    return nil
  end
  local rTypeID = roleObj:getTypeId()
  local rName = roleObj:getProperty(PROPERTY_NAME)
  local rRace = roleObj:getProperty(PROPERTY_RACE)
  return {
    rID = roleID,
    rTypeID = rTypeID,
    rName = rName,
    rRace = rRace
  }
end
function warsetting:getPetInfoByHero(heroID)
  local heroData = g_LocalPlayer:getObjById(heroID)
  local petID = heroData:getProperty(PROPERTY_PETID)
  return self:getRoleInfo(petID)
end
function warsetting:getMainHeroID()
  local mainHero = g_LocalPlayer:getMainHero()
  local heroID = mainHero:getObjId()
  return heroID
end
function warsetting:getRoleInitPos(roleID)
  local mainHeroID = self:getMainHeroID()
  if self.m_RecordFbWarSetting == nil then
    local warsettingInfo = g_LocalPlayer:getWarSetting()
    self.m_RecordFbWarSetting = {}
    for warPos, roleId in pairs(warsettingInfo) do
      self.m_RecordFbWarSetting[roleId] = warPos
    end
    if self.m_RecordFbWarSetting[mainHeroID] == nil then
      self.m_RecordFbWarSetting = {}
    end
    self.m_InitWarSetting = DeepCopyTable(warsettingInfo)
  end
  local pos = self.m_RecordFbWarSetting[roleID]
  if pos == nil and roleID == mainHeroID then
    return 3
  else
    return pos
  end
end
function warsetting:initRoleList()
  self.m_RoleList = self:getNode("rolelist")
  self.m_RoleList:addTouchItemListenerListView(handler(self, self.onSelected))
  local allHeroList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_HERO)
  local roleList = {}
  local mainHeroID = self:getMainHeroID()
  for _, heroID in pairs(allHeroList) do
    if heroID ~= mainHeroID then
      local pos = self:getRoleInitPos(heroID)
      local info = self:getRoleInfo(heroID)
      if pos == nil then
        if info ~= nil then
          roleList[#roleList + 1] = info
        end
      else
        self:createRoleShapeAtPos(pos, info, false)
      end
    end
  end
  table.sort(roleList, function(a, b)
    if a == nil or b == nil then
      return false
    end
    return self:sortCmpFunc(a, b)
  end)
  for _, info in pairs(roleList) do
    local roleInfo = roleinfo.new(info)
    self.m_RoleList:pushBackCustomItem(roleInfo:getUINode())
  end
  self:setRoleListTouchEventListener()
end
function warsetting:sortCmpFunc(a, b)
  if a.rLevel ~= b.rLevel then
    return a.rLevel > b.rLevel
  elseif a.rZhuan ~= b.rZhuan then
    return a.rZhuan > b.rZhuan
  else
    return a.rTypeID < b.rTypeID
  end
end
function warsetting:insertToRoleList(param)
  local index = 0
  while true do
    local item = self.m_RoleList:getItem(index)
    if not item then
      break
    end
    local obj = item.m_UIViewParent
    local objParam = obj:getParam()
    if self:sortCmpFunc(param, objParam) then
      break
    end
    index = index + 1
  end
  local roleInfo = roleinfo.new(param)
  self.m_RoleList:insertCustomItem(roleInfo:getUINode(), index)
  self:setRoleListTouchEventListener()
end
function warsetting:deleteFromRoleList(index)
  self.m_RoleList:removeItem(index)
  self:setRoleListTouchEventListener()
end
function warsetting:onSelected(item, index)
  if item == nil then
    return
  end
  local pos = self:getNextRoleShapePos()
  if pos ~= nil then
    do
      local obj = item.m_UIViewParent
      local param = obj:getParam()
      local act1 = CCDelayTime:create(0.01)
      local act2 = CCCallFunc:create(function()
        self:deleteFromRoleList(index)
        self:createRoleShapeAtPos(pos, param, false)
      end)
      self:runAction(transition.sequence({act1, act2}))
    end
  else
    print("-->>位置已满，无法继续派遣!")
    ShowNotifyTips("最多派遣5个英雄")
  end
end
function warsetting:getNextRoleShapePos()
  for pos = 1, 5 do
    if self.m_RoleShapes[pos] == nil then
      return pos
    end
  end
  return nil
end
function warsetting:initMainRoleShape()
  local hID = self:getMainHeroID()
  local info = self:getRoleInfo(hID)
  local pos = self:getRoleInitPos(hID)
  self:createRoleShapeAtPos(pos, info, true)
end
function warsetting:createRoleShapeAtPos(pos, heroInfo, isMainShape)
  self:deleteRoleShapeAtPos(pos)
  local posLayer = self:getNode(string.format("pos%d", pos))
  if posLayer == nil then
    return
  end
  local p = posLayer:getParent()
  local x, y = posLayer:getPosition()
  local newHero = roleshape.heroshape.new(pos, heroInfo, self, isMainShape)
  p:addChild(newHero, 10000 - y)
  newHero:setPosition(ccp(x, y))
  self.m_RoleShapes[pos] = newHero
  local petPos = getRelativePetPos(pos)
  local petPosLayer = self:getNode(string.format("pos%d", petPos))
  if petPosLayer == nil then
    return
  end
  local petInfo = self:getPetInfoByHero(heroInfo.rID)
  if petInfo then
    local p = petPosLayer:getParent()
    local x, y = petPosLayer:getPosition()
    local newPet = roleshape.petshape.new(petPos, petInfo, self)
    p:addChild(newPet, 10000 - y)
    newPet:setPosition(ccp(x, y))
    self.m_RoleShapes[petPos] = newPet
  end
end
function warsetting:deleteRoleShapeAtPos(pos)
  if self.m_RoleShapes[pos] ~= nil then
    local oldHero = self.m_RoleShapes[pos]
    local param = oldHero:getParam()
    self:insertToRoleList(param)
    oldHero:removeFromParentAndCleanup(true)
    self.m_RoleShapes[pos] = nil
    local petPos = getRelativePetPos(pos)
    local oldPet = self.m_RoleShapes[petPos]
    if oldPet then
      oldPet:removeFromParentAndCleanup(true)
      self.m_RoleShapes[petPos] = nil
    end
  end
end
function warsetting:onClickRoleShape(roleObj, gridPos)
  if not roleObj:IsMainShape() then
    self.m_ClickRoleShapePos = gridPos
    self.m_buttonWarDel:setVisible(true)
  else
    self.m_ClickRoleShapePos = nil
    self.m_buttonWarDel:setVisible(false)
  end
end
function warsetting:setAllGridsNotSelected()
  self.pos_sel:setVisible(false)
end
function warsetting:setGridSelected(gridPos)
  if gridPos == nil then
    return
  end
  local gridObj = self:getNode(string.format("pos%d", gridPos))
  if gridObj then
    local x, y = gridObj:getPosition()
    self.pos_sel:setVisible(true)
    self.pos_sel:setPosition(ccp(x, y))
  end
end
function warsetting:onDragBegan(dragPosXY)
  self:setAllGridsNotSelected()
  local dragPos = self:checkGridPos(dragPosXY)
  self:setGridSelected(dragPos)
end
function warsetting:onDragMoved(dragPosXY)
  self:setAllGridsNotSelected()
  local dragPos = self:checkGridPos(dragPosXY)
  self:setGridSelected(dragPos)
  self.m_ClickRoleShapePos = nil
  self.m_buttonWarDel:setVisible(false)
end
function warsetting:onDragEnded(obj, gridPos, dragPosXY)
  self:setAllGridsNotSelected()
  local posLayer = self:getNode(string.format("pos%d", gridPos))
  if posLayer == nil then
    return
  end
  local dragPos = self:checkGridPos(dragPosXY)
  if dragPos == nil then
    if obj:IsMainShape() then
      self:setRoleShapeAtPos(obj, gridPos)
    else
      local param = obj:getParam()
      self:deleteRoleShapeAtPos(gridPos)
    end
  else
    local otherObj = self.m_RoleShapes[dragPos]
    if dragPos == gridPos then
      self:setRoleShapeAtPos(obj, gridPos)
    elseif otherObj == nil then
      local heroObj, heroOldPos, heroNewPos, petObj, petOldPos, petNewPos = self:setRoleShapeAtPos(obj, dragPos)
      self.m_RoleShapes[heroNewPos] = heroObj
      self.m_RoleShapes[heroOldPos] = nil
      self.m_RoleShapes[petNewPos] = petObj
      self.m_RoleShapes[petOldPos] = nil
    else
      local heroObj_1, heroOldPos_1, heroNewPos_1, petObj_1, petOldPos_1, petNewPos_1 = self:setRoleShapeAtPos(otherObj, gridPos)
      local heroObj_2, heroOldPos_2, heroNewPos_2, petObj_2, petOldPos_2, petNewPos_2 = self:setRoleShapeAtPos(obj, dragPos)
      self.m_RoleShapes[heroNewPos_1] = heroObj_1
      self.m_RoleShapes[heroNewPos_2] = heroObj_2
      self.m_RoleShapes[petNewPos_1] = petObj_1
      self.m_RoleShapes[petNewPos_2] = petObj_2
    end
  end
end
function warsetting:checkGridPos(dragPosXY)
  local closeGrid
  local checkPosList = {
    1,
    2,
    3,
    4,
    5,
    101,
    102,
    103,
    104,
    105
  }
  for _, pos in pairs(checkPosList) do
    local posLayer = self:getNode(string.format("pos%d", pos))
    if posLayer == nil then
      break
    end
    local x, y = posLayer:getPosition()
    local size = posLayer:getContentSize()
    if math.abs(dragPosXY.x - x) <= size.width / 2 and math.abs(dragPosXY.y - y) <= size.height / 2 then
      local dis = (dragPosXY.x - x) ^ 2 + (dragPosXY.y - y) ^ 2
      if closeGrid == nil or dis < closeGrid[2] then
        closeGrid = {pos, dis}
      end
    end
  end
  if closeGrid == nil then
    return nil
  else
    local gridPos = closeGrid[1]
    if gridPos >= DefineRelativePetAddPos then
      gridPos = gridPos - DefineRelativePetAddPos
    end
    return gridPos
  end
end
function warsetting:setRoleShapeAtPos(obj, gridPos)
  local posLayer = self:getNode(string.format("pos%d", gridPos))
  if posLayer == nil then
    return
  end
  local oldPos = obj:getPos()
  local x, y = posLayer:getPosition()
  obj:getParent():reorderChild(obj, roleMaxZ - y)
  obj:setPos(gridPos)
  local act = CCMoveTo:create(0.15, ccp(x, y))
  obj:runAction(act)
  local petPos = getRelativePetPos(oldPos)
  local newPetPos = getRelativePetPos(gridPos)
  local petObj = self.m_RoleShapes[petPos]
  if petObj then
    local petPosLayer = self:getNode(string.format("pos%d", newPetPos))
    if petPosLayer == nil then
      return
    end
    local x, y = petPosLayer:getPosition()
    petObj:getParent():reorderChild(petObj, roleMaxZ - y)
    petObj:setPos(newPetPos)
    local act2 = CCMoveTo:create(0.15, ccp(x, y))
    petObj:runAction(act2)
  end
  return obj, oldPos, gridPos, petObj, petPos, newPetPos
end
function warsetting:resetAllShapeState()
  for _, roleObj in pairs(self.m_RoleShapes) do
    if roleObj.setTouchState then
      roleObj:setTouchState(false)
    end
  end
end
function warsetting:CheckNeedSave(saveInfo)
  for _, pos in pairs({
    1,
    2,
    3,
    4,
    5
  }) do
    if self.m_InitWarSetting[pos] ~= saveInfo[pos] then
      return true
    end
  end
  return false
end
function warsetting:Btn_Save(obj, t)
  print("==>>warsetting:Btn_Save")
  local saveInfo = {}
  local mainRolePos
  for _, pos in pairs({
    1,
    2,
    3,
    4,
    5
  }) do
    local obj = self.m_RoleShapes[pos]
    if obj then
      local param = obj:getParam()
      saveInfo[pos] = param.rID
      if obj:IsMainShape() then
        mainRolePos = pos
      end
    end
  end
  if mainRolePos ~= nil then
    self.m_SaveInfo = saveInfo
    if self:CheckNeedSave(saveInfo) then
      netsend.netwar.submitWarSetting(saveInfo)
    else
      print("--->>阵型没变动，不用保存")
      self:CloseSelf()
    end
  else
    print("没有主角!？")
    self:CloseSelf()
  end
end
function warsetting:Btn_WarDel(obj, t)
  if self.m_ClickRoleShapePos then
    local roleObj = self.m_RoleShapes[self.m_ClickRoleShapePos]
    if roleObj and not roleObj:IsMainShape() then
      local param = roleObj:getParam()
      self:deleteRoleShapeAtPos(self.m_ClickRoleShapePos)
    end
    self:setAllGridsNotSelected()
    self.m_ClickRoleShapePos = nil
    self.m_buttonWarDel:setVisible(false)
  end
end
function warsetting:Btn_DrugSetting()
  local tempDrugSetting = CDrugSetting.new()
  tempDrugSetting:addTo(self.m_UINode, roleMaxZ)
end
function warsetting:Clear()
  self.m_RoleList:addTouchEventListenerScrollView(nil)
end
return warsetting
