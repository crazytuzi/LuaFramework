g_CYZDDMatchingDlg = nil
CYZDDMatchingDlg = class("CYZDDMatchingDlg", CcsSubView)
function CYZDDMatchingDlg:ctor()
  CYZDDMatchingDlg.super.ctor(self, "views/yzddmatching.json", {
    isAutoCenter = true,
    opacityBg = 0,
    clickOutSideToClose = false
  })
  local head_m = self:getNode("head_m")
  local p = head_m:getParent()
  local x, y = head_m:getPosition()
  local mainHero = g_LocalPlayer:getMainHero()
  local rTypeId = mainHero:getTypeId()
  local headObj_m = createHeadIconByRoleTypeID(rTypeId)
  p:addNode(headObj_m, 10)
  headObj_m:setPosition(ccp(x + HEAD_OFF_X, y + HEAD_OFF_Y))
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
  local level_m = self:getNode("level_m")
  level_m:setText(string.format("%d转%d级", zs, lv))
  self:startRandomEnmeyAni()
  self:ListenMessage(MsgID_Activity)
  self:ListenMessage(MsgID_Scene)
  self:ListenMessage(MsgID_ReConnect)
  self:ListenMessage(MsgID_MapScene)
end
function CYZDDMatchingDlg:OnMessage(msgSID, ...)
  if msgSID == MsgID_Activity_YZDDEnemyInfo then
    local arg = {
      ...
    }
    local info = arg[1]
    self:setEnemyInfo(info)
  elseif msgSID == MsgID_Scene_War_Enter then
    self:CloseSelf()
  elseif msgSID == MsgID_Activity_YZDDStatus then
    local arg = {
      ...
    }
    local state = arg[1]
    if state ~= 1 then
      self:CloseSelf()
    end
  elseif msgSID == MsgID_ReConnect_ReLogin then
    self:CloseSelf()
  elseif msgSID == MsgID_MapScene_ChangedMap and not g_MapMgr:IsInYiZhanDaoDiMap() then
    self:CloseSelf()
  end
end
function CYZDDMatchingDlg:startRandomEnmeyAni()
  self:getNode("level_e"):setVisible(false)
  local act1 = CCCallFunc:create(function()
    local typeIdList = data_getAllMainHeroTypeId()
    local typeId = typeIdList[math.random(1, #typeIdList)]
    self:setEnemyHead(typeId)
  end)
  local act2 = CCDelayTime:create(0.3)
  self:runAction(CCRepeatForever:create(transition.sequence({act1, act2})))
end
function CYZDDMatchingDlg:stopRandomEnmeyAni()
  self:stopAllActions()
end
function CYZDDMatchingDlg:setEnemyInfo(info)
  self:stopRandomEnmeyAni()
  local title = self:getNode("title_1")
  title:runAction(CCFadeOut:create(0.5))
  local rTypeId = info.rtype or 11001
  self:setEnemyHead(rTypeId)
  local zs = info.zs or 0
  local lv = info.lv or 0
  local level_e = self:getNode("level_e")
  level_e:setText(string.format("%d转%d级", zs, lv))
  level_e:setVisible(true)
end
function CYZDDMatchingDlg:setEnemyHead(rTypeId)
  local head_e = self:getNode("head_e")
  if head_e._headObj then
    if head_e._rTypeId == rTypeId then
      return
    end
    head_e._headObj:removeFromParent()
    head_e._headObj = nil
  end
  local head_e = self:getNode("head_e")
  local p = head_e:getParent()
  local x, y = head_e:getPosition()
  local headObj_e = createHeadIconByRoleTypeID(rTypeId)
  p:addNode(headObj_e, 10)
  headObj_e:setPosition(ccp(x + HEAD_OFF_X, y + HEAD_OFF_Y))
  head_e._headObj = headObj_e
  head_e._rTypeId = rTypeId
end
function CYZDDMatchingDlg:Clear()
  if g_CYZDDMatchingDlg == self then
    g_CYZDDMatchingDlg = nil
  end
end
function ShowYZDDMatchingDlg(state)
  if state == 1 and g_CYZDDMatchingDlg == nil then
    g_CYZDDMatchingDlg = getCurSceneView():addSubView({
      subView = CYZDDMatchingDlg.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  end
end
function CloseYZDDMatchingDlg()
  if g_CYZDDMatchingDlg ~= nil then
    g_CYZDDMatchingDlg:CloseSelf()
  end
end
