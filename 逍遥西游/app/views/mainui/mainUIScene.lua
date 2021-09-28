CMainUIScene = class(".CMainUIScene", CcsSceneView)
function CMainUIScene:ctor(enterListener)
  CMainUIScene.super.ctor(self, "Widget")
  CMainUIScene.Ins = self
  self.m_ZOrderObjList = {}
  self.m_CoverZOrder = MainUISceneZOrder.warScene
  self.m_PopView = nil
  self.m_EntenListener = enterListener
  self.m_MenuView = self:addSubView({
    subView = CMainMenu:new(),
    zOrder = MainUISceneZOrder.mainMenu
  })
  self:Show("None")
end
function CMainUIScene:ShowNormalNpcViewById(npcId)
  local npcView = CNpcNormal.new(npcId)
  self:addSubView({
    subView = npcView,
    zOrder = MainUISceneZOrder.popView
  })
  self:addPopView(npcView)
end
function CMainUIScene:ShowMonsterView(...)
  local npcView = CMonsterOpenView.new(...)
  self:addSubView({
    subView = npcView,
    zOrder = MainUISceneZOrder.popView
  })
  self:addPopView(npcView)
end
function CMainUIScene:ShowNpcViewByClass(NpcClass, npcTypeId, npcId)
  local npcView = NpcClass.new(npcId)
  self:addSubView({
    subView = npcView,
    zOrder = MainUISceneZOrder.popView
  })
  self:addPopView(npcView)
end
function CMainUIScene:addPopView(popView)
  self:removeCurPopView()
  self.m_PopView = popView
end
function CMainUIScene:removeCurPopView()
  if self.m_PopView ~= nil then
    if self.m_PopView.CloseSelf then
      self.m_PopView:CloseSelf()
    else
      self.m_PopView:removeSelf()
    end
    self.m_PopView = nil
  end
end
function CMainUIScene:PopViewClosed(popView)
  if self.m_PopView == popView then
    self.m_PopView = nil
  end
end
function CMainUIScene:HadTouchMap(t, x, y)
  if t == TOUCH_EVENT_BEGAN then
    self:removeCurPopView()
    ClearAllShowProgressBar()
  end
end
function CMainUIScene:onEnterEvent()
  print("==>>> CMainUIScene onEnterEvent")
  if self.m_EntenListener then
    self.m_EntenListener(self)
    self.m_EntenListener = nil
  end
end
function CMainUIScene:TalkViewWillShow()
  if g_FubenHandler == nil and g_WarScene == nil then
    self.m_MenuView:setCoverFlagByTalkView(true)
  end
end
function CMainUIScene:TalkViewShowFinished()
  if g_FubenHandler == nil and g_WarScene == nil then
    self.m_MenuView:setCoverFlagByTalkView(false)
  end
end
function CMainUIScene:SetMainRoleGridPosText(oldGX, oldGY, gx, gy)
  self.m_MenuView:updateMapPos(oldGX, oldGY, gx, gy)
end
function CMainUIScene:SetMapName(mapName)
  self.m_MenuView:updateMapName(mapName)
end
function CMainUIScene:getMenuView()
  return self.m_MenuView
end
function CMainUIScene:reOrderAllViewWhenEnterWar()
  print("CMainUIScene:reOrderAllViewWhenEnterWar")
  local notResetType = {
    "warScene",
    "fbui",
    "CQuickUseBoard"
  }
  for zOrder, vList in pairs(self.m_ZOrderObjList) do
    local reOrderList = {}
    for _, tempView in ipairs(vList) do
      local node = tempView.m_UIViewParent or tempView
      if node ~= nil and zOrder == self.m_CoverZOrder and tempView.__cname ~= nil then
        local resetFlag = true
        for _, typeName in pairs(notResetType) do
          if tempView.__cname == typeName then
            resetFlag = false
            break
          end
        end
        if resetFlag then
          reOrderList[#reOrderList + 1] = tempView
        end
      end
    end
    for _, tempView in ipairs(reOrderList) do
      self:ReOrderSubView(tempView, zOrder)
    end
  end
end
function CMainUIScene:reOrderAllViewWhenEndWarEnterFuben()
  print("CMainUIScene:reOrderAllViewWhenEndWarEnterFuben")
  local resetType = {
    "warScene",
    "fbui",
    "CQuickUseBoard",
    "CPopWarning"
  }
  for zOrder, vList in pairs(self.m_ZOrderObjList) do
    local reOrderList = {}
    for _, tempView in ipairs(vList) do
      local node = tempView.m_UIViewParent or tempView
      if node ~= nil and zOrder == self.m_CoverZOrder and tempView.__cname ~= nil then
        local resetFlag = false
        for _, typeName in pairs(resetType) do
          if tempView.__cname == typeName then
            resetFlag = true
            break
          end
        end
        if resetFlag then
          reOrderList[#reOrderList + 1] = tempView
        end
      end
    end
    for _, tempView in ipairs(reOrderList) do
      self:ReOrderSubView(tempView, zOrder)
    end
  end
end
function CMainUIScene:closeSomePopDlgWhenEnterWar()
  if g_Click_Skill_View ~= nil then
    g_Click_Skill_View:removeFromParentAndCleanup(true)
    g_Click_Skill_View = nil
  end
  if g_Click_Item_View ~= nil then
    g_Click_Item_View:removeFromParentAndCleanup(true)
    g_Click_Item_View = nil
  end
  if g_Click_Attr_View ~= nil then
    g_Click_Attr_View:removeFromParentAndCleanup(true)
    g_Click_Attr_View = nil
  end
  if g_Click_MONSTER_Head_View ~= nil then
    g_Click_MONSTER_Head_View:removeFromParentAndCleanup(true)
    g_Click_MONSTER_Head_View = nil
  end
  if g_Click_PET_Head_View ~= nil then
    g_Click_PET_Head_View:removeFromParentAndCleanup(true)
    g_Click_PET_Head_View = nil
  end
end
function CMainUIScene:addSubView(param)
  print("CMainUIScene:addSubView")
  local subView = param.subView
  local z = param.zOrder or 0
  local notOnlyOneList = {
    "CPopWarning"
  }
  if subView.__cname ~= nil and z == self.m_CoverZOrder then
    local delFlag = true
    for _, tempCName in pairs(notOnlyOneList) do
      if subView.__cname == tempCName then
        delFlag = false
        break
      end
    end
    local oldView = self:getSubViewInSceneByClassName(subView.__cname)
    if oldView ~= nil and delFlag then
      if oldView.CloseSelf then
        oldView:CloseSelf()
      else
        oldView:removeFromParent()
      end
      self:DelSubViewInScene(oldView)
    end
  end
  if self.m_ZOrderObjList[z] == nil then
    self.m_ZOrderObjList[z] = {}
  end
  if subView.setIsCoverFlag then
    self.m_ZOrderObjList[z][#self.m_ZOrderObjList[z] + 1] = subView
  end
  local tempView = CMainUIScene.super.addSubView(self, param)
  if g_CurShowTalkView ~= nil and tempView.setCoverFlagByTalkView and z < MainUISceneZOrder.storyView and tempView.__cname ~= "warScene" then
    tempView:setCoverFlagByTalkView(true)
  end
  return tempView
end
function CMainUIScene:ReOrderSubView(subView, newZOrder)
  print("CMainUIScene:ReOrderSubView", subView, newZOrder, subView.__cname, type(subView))
  if not self:SubViewIsInScene(subView) then
    return
  else
    self:DelSubViewInScene(subView)
    if self.m_ZOrderObjList[newZOrder] == nil then
      self.m_ZOrderObjList[newZOrder] = {}
    end
    if subView.setIsCoverFlag then
      self.m_ZOrderObjList[newZOrder][#self.m_ZOrderObjList[newZOrder] + 1] = subView
    end
    local blackLayer = subView._auto_create_opacity_bg_ins
    local uiNode = subView.m_UINode or subView
    local p = uiNode:getParent()
    if blackLayer then
      p:reorderChild(blackLayer, newZOrder)
    end
    p:reorderChild(uiNode, newZOrder)
  end
  self:updateSubViewsCoverFlags()
end
function CMainUIScene:PrintZOrderObjList()
  for z, vList in pairs(self.m_ZOrderObjList) do
    for i, tempView in ipairs(vList) do
      print(z, i, tempView, tempView.__cname, type(tempView))
    end
  end
end
function CMainUIScene:SubViewIsInScene(subView)
  print("CMainUIScene:SubViewIsInScene", subView, subView.__cname, type(subView))
  for z, vList in pairs(self.m_ZOrderObjList) do
    for _, tempView in ipairs(vList) do
      if tempView ~= nil and tempView == subView then
        return true
      end
    end
  end
  return false
end
function CMainUIScene:getSubViewInSceneByClassName(className)
  for z, vList in pairs(self.m_ZOrderObjList) do
    for _, tempView in ipairs(vList) do
      if tempView.__cname ~= nil and tempView.__cname == className then
        return tempView
      end
    end
  end
  return nil
end
function CMainUIScene:DelSubViewInScene(subView)
  print("CMainUIScene:DelSubViewInScene", subView)
  for z, vList in pairs(self.m_ZOrderObjList) do
    for i, tempView in ipairs(vList) do
      if tempView == subView then
        table.remove(vList, i)
        break
      end
    end
  end
end
function CMainUIScene:updateSubViewsCoverFlags()
  print("CMainUIScene:updateSubViewsCoverFlags")
  local needSetCover = false
  if g_WarScene ~= nil or g_FubenHandler ~= nil then
    needSetCover = true
  end
  local needCoverFlag = false
  if needSetCover == false then
    needCoverFlag = false
    for z, vList in pairs(self.m_ZOrderObjList) do
      for i, tempView in ipairs(vList) do
        if tempView.setIsCoverFlag then
          tempView:setIsCoverFlag(needCoverFlag)
        end
      end
    end
    if g_MapMgr then
      local mapIns = g_MapMgr:getMapViewIns()
      if mapIns then
        mapIns:setVisible(true)
      end
    end
  else
    local minShowIndex = 0
    local tempList = self.m_ZOrderObjList[self.m_CoverZOrder] or {}
    for i, tempView in ipairs(tempList) do
      if tempView == g_WarScene and tempView ~= nil then
        minShowIndex = i
      elseif tempView == g_FubenHandler and tempView ~= nil then
        minShowIndex = i
      end
    end
    needCoverFlag = false
    for z, vList in pairs(self.m_ZOrderObjList) do
      for i, tempView in ipairs(vList) do
        if z < self.m_CoverZOrder then
          needCoverFlag = true
        elseif z > self.m_CoverZOrder then
          needCoverFlag = false
        elseif i < minShowIndex then
          needCoverFlag = true
        else
          needCoverFlag = false
        end
        if tempView.setIsCoverFlag then
          tempView:setIsCoverFlag(needCoverFlag)
        end
      end
    end
    if g_MapMgr then
      local mapIns = g_MapMgr:getMapViewIns()
      if mapIns and minShowIndex > 0 then
        mapIns:setVisible(false)
      end
    end
  end
end
function CMainUIScene:updateSubViewsVisibleCoverFlags()
  print("CMainUIScene:updateSubViewsVisibleCoverFlags")
  local needSetCover = false
  if g_CurShowTalkView ~= nil then
    needSetCover = true
  end
  local needCoverFlag = false
  if needSetCover == false then
    for z, vList in pairs(self.m_ZOrderObjList) do
      for i, tempView in ipairs(vList) do
        if tempView.setCoverFlagByTalkView and tempView.__cname ~= "warScene" then
          tempView:setCoverFlagByTalkView(needCoverFlag)
        end
      end
    end
  else
    for z, vList in pairs(self.m_ZOrderObjList) do
      for i, tempView in ipairs(vList) do
        if z < MainUISceneZOrder.storyView then
          needCoverFlag = true
        else
          needCoverFlag = false
        end
        if tempView.setCoverFlagByTalkView and tempView.__cname ~= "warScene" then
          tempView:setCoverFlagByTalkView(needCoverFlag)
        end
      end
    end
  end
end
function CMainUIScene:ShowTopSwallowTouchNode(isShow)
  if isShow then
    if self.m_TopSwallowTouchNode == nil then
      local widget = Widget:create()
      widget:setAnchorPoint(ccp(0, 0))
      widget:ignoreContentAdaptWithSize(false)
      widget:setSize(CCSize(display.width, display.height))
      widget:setContentSize(CCSize(display.width, display.height))
      widget:setTouchEnabled(true)
      self.m_TopSwallowTouchNode = widget
      self:addSubView({
        subView = self.m_TopSwallowTouchNode,
        zOrder = self:getChildMaxZ() + 1
      })
    else
      self:reorderChild(self, self:getChildMaxZ() + 1)
    end
    self.m_TopSwallowTouchNode:setEnabled(true)
  elseif self.m_TopSwallowTouchNode then
    self.m_TopSwallowTouchNode:setEnabled(false)
  end
end
function CMainUIScene:setShowMapLoading(isShow)
  if self.m_MapLoading then
    self.m_MapLoading:removeSelf()
    self.m_MapLoading = nil
  end
  if isShow then
    self.m_MapLoading = CMapLoading.new()
    self:addSubView({
      subView = self.m_MapLoading,
      zOrder = self:getChildMaxZ() + 1
    })
  end
  self:ShowTopSwallowTouchNode(isShow)
end
function CMainUIScene:setLoadProgress(pro)
  if self.m_MapLoading then
    self.m_MapLoading:setLoadProgress(pro)
  end
end
function CMainUIScene:setToolBtn(btn)
  if btn then
    self.m_ToolBtnPos = btn:convertToWorldSpace(ccp(0, 0))
    self.m_ToolBtnPos = ccp(self.m_ToolBtnPos.x, self.m_ToolBtnPos.y)
  end
end
function CMainUIScene:getToolBtnPos()
  return ccp(self.m_ToolBtnPos.x, self.m_ToolBtnPos.y)
end
function CMainUIScene:Clear()
  self.m_PopView = nil
  self.m_ToolBtn = nil
  self:stopShowCDTime(true)
  if CMainUIScene.Ins == self then
    CMainUIScene.Ins = nil
  end
end
function CMainUIScene:showCDTimer(endTime, listener, delayStartTime)
  self:stopShowCDTime(true)
  self.m_ShowCdTimerListener = listener
  self.m_EndTime = endTime
  self.m_StartTime = g_DataMgr:getServerTime() + delayStartTime - 0.01
  self.m_LastShowCdTimeCount = -1
  self.m_TopCDHaddle = nil
  self.m_CdTimeShowNode = nil
  self.m_TopCDHaddle = scheduler.scheduleUpdateGlobal(function(dt)
    local ot = self.m_EndTime - g_DataMgr:getServerTime()
    if ot < 0 then
      self:stopShowCDTime(false)
      return
    end
    if self.m_StartTime > g_DataMgr:getServerTime() then
      return
    end
    ot = math.floor(ot)
    if ot < 0 then
      ot = 0
    end
    if self.m_LastShowCdTimeCount ~= ot then
      self.m_LastShowCdTimeCount = ot
      self:showCDTimerDisplay(ot)
    end
  end)
end
function CMainUIScene:showCDTimerDisplay(ot)
  if self.m_CdTimeShowNode == nil then
    self.m_CdTimeShowNode = CCLabelBMFont:create("10", "views/common/num/num_fnt/number2.fnt")
    self:addNode(self.m_CdTimeShowNode, MainUISceneZOrder.cdView)
    self.m_CdTimeShowNode:setPosition(ccp(display.width / 2, display.height - 200))
  end
  self.m_CdTimeShowNode:stopAllActions()
  self.m_CdTimeShowNode:runAction(transition.sequence({
    CCScaleTo:create(0.1, 1.5),
    CCCallFunc:create(function()
      self.m_CdTimeShowNode:setString(string.format("%d", ot))
    end),
    CCScaleTo:create(0.1, 1)
  }))
end
function CMainUIScene:stopShowCDTime(isBreak)
  if self.m_TopCDHaddle then
    if isBreak == nil then
      isBreak = true
    end
    scheduler.unscheduleGlobal(self.m_TopCDHaddle)
    self.m_TopCDHaddle = nil
    if self.m_ShowCdTimerListener then
      self.m_ShowCdTimerListener(isBreak)
      self.m_ShowCdTimerListener = nil
    end
    if self.m_CdTimeShowNode then
      self.m_CdTimeShowNode:removeSelf()
      self.m_CdTimeShowNode = nil
    end
  end
end
