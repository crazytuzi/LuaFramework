g_CLWZBMatchingDlg = nil
CLWZBMatchingDlg = class("CLWZBMatchingDlg", CcsSubView)
function CLWZBMatchingDlg:ctor()
  CLWZBMatchingDlg.super.ctor(self, "views/lwzbmatching.json", {
    isAutoCenter = true,
    opacityBg = 0,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_cancel = {
      listener = handler(self, self.Btn_Cancel),
      variName = "btn_cancel"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
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
end
function CLWZBMatchingDlg:OnMessage(msgSID, ...)
  if msgSID == MsgID_Activity_LeiTaiEnemyInfo then
    local arg = {
      ...
    }
    local info = arg[1]
    self:setEnemyInfo(info)
  elseif msgSID == MsgID_Scene_War_Enter then
    self:CloseSelf()
  elseif msgSID == MsgID_Activity_LeiTaiStatus then
    local arg = {
      ...
    }
    local state = arg[1]
    if state == 2 then
      self:CloseSelf()
    end
  elseif msgSID == MsgID_ReConnect_ReLogin then
    self:CloseSelf()
  elseif msgSID == MsgID_Activity_LeiTaiMatching then
    local arg = {
      ...
    }
    local status = arg[1]
    if status == 2 then
      self:CloseSelf()
    end
  end
end
function CLWZBMatchingDlg:startRandomEnmeyAni()
  self:getNode("level_e"):setVisible(false)
  local act1 = CCCallFunc:create(function()
    local typeIdList = data_getAllMainHeroTypeId()
    local typeId = typeIdList[math.random(1, #typeIdList)]
    self:setEnemyHead(typeId)
  end)
  local act2 = CCDelayTime:create(0.3)
  self:runAction(CCRepeatForever:create(transition.sequence({act1, act2})))
end
function CLWZBMatchingDlg:stopRandomEnmeyAni()
  self:stopAllActions()
end
function CLWZBMatchingDlg:setEnemyInfo(info)
  self:stopRandomEnmeyAni()
  self.btn_cancel:setVisible(false)
  self.btn_cancel:setTouchEnabled(false)
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
function CLWZBMatchingDlg:setEnemyHead(rTypeId)
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
function CLWZBMatchingDlg:Btn_Cancel()
  netsend.netactivity.sendMatchLWZB(0)
end
function CLWZBMatchingDlg:Clear()
  if g_CLWZBMatchingDlg == self then
    g_CLWZBMatchingDlg = nil
  end
end
function ShowLBZBMatchingDlg(state)
  if state == 1 and g_CLWZBMatchingDlg == nil then
    g_CLWZBMatchingDlg = getCurSceneView():addSubView({
      subView = CLWZBMatchingDlg.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  end
end
function CloseLBZBMatchingDlg()
  if g_CLWZBMatchingDlg ~= nil then
    g_CLWZBMatchingDlg:CloseSelf()
  end
end
