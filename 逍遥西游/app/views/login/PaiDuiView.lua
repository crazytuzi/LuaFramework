function ShowPaiDuiView(time, num, serName)
  if CPaiDuiView_Login.Ins then
    CPaiDuiView_Login.Ins:setDetailData(time, num, serName)
  elseif CPaiDuiView.Ins then
    CPaiDuiView.Ins:setDetailData(time, num, serName)
  elseif getCurSceneView() ~= nil then
    if g_DataMgr:IsInGame() then
      getCurSceneView():addSubView({
        subView = CPaiDuiView.new(time, num, serName),
        zOrder = MainUISceneZOrder.menuView
      })
    else
      getCurSceneView():addSubView({
        subView = CPaiDuiView_Login.new(time, num, serName),
        zOrder = MainUISceneZOrder.menuView
      })
    end
  end
end
CPaiDuiView_Login = class("CPaiDuiView_Login", CcsSubView)
function CPaiDuiView_Login:ctor(time, num, serName)
  CPaiDuiView_Login.super.ctor(self, "views/login_paidui.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_cancel = {
      listener = handler(self, self.Btn_Cancel),
      variName = "m_BtnCancel"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.pic_bg = self:getNode("pic_bg")
  local size = self.pic_bg:getContentSize()
  if size.width < display.width or size.height < display.height then
    self:getNode("pic_bg"):setSize(CCSize(display.width, display.height))
  end
  local btn_back_txt = display.newSprite("views/common/btn/btntxt_cancel.png")
  self.m_BtnCancel:addNode(btn_back_txt)
  btn_back_txt:setPosition(ccp(-5, 20))
  self:setDetailData(time, num, serName)
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.frameUpdate))
  self:scheduleUpdate()
  self:frameUpdate()
  self:ListenMessage(MsgID_Connect)
  self:ListenMessage(MsgID_ReConnect)
  CPaiDuiView_Login.Ins = self
  resetLogoSpriteWithSpriteNode(self:getNode("pic_logo"))
end
function CPaiDuiView_Login:setDetailData(time, num, serName)
  self:getNode("txt_ser"):setText(serName)
  self:getNode("txt_num"):setText(string.format("%d人", num))
  self.m_LoginTime = os.time() + time
end
function CPaiDuiView_Login:frameUpdate(dt)
  local restTime = self.m_LoginTime - os.time()
  if restTime < 60 then
    restTime = 60
  end
  self:getNode("txt_time"):setText(string.format("%d分钟", math.ceil(restTime / 60)))
end
function CPaiDuiView_Login:Btn_Cancel(obj, t)
  print("==>>CPaiDuiView_Login:Btn_Cancel")
  g_DataMgr:returnToLoginView()
  if LoginGame.Ins then
    LoginGame.Ins:HideWaitingView()
    LoginGame.Ins:LogoutGame()
  end
  self:CloseSelf()
end
function CPaiDuiView_Login:OnMessage(msgSID, ...)
  print("CPaiDuiView_Login:OnMessage:", msgSID, ...)
  if msgSID == MsgID_Connect_SendFinished then
    self:CloseSelf()
  elseif msgSID == MsgID_ReConnect_PingSuccess then
    self:CloseSelf()
  end
end
function CPaiDuiView_Login:Clear()
  if CPaiDuiView_Login.Ins == self then
    CPaiDuiView_Login.Ins = nil
  end
end
CPaiDuiView = class("CPaiDuiView", CcsSubView)
function CPaiDuiView:ctor(time, num, serName)
  CPaiDuiView.super.ctor(self, "views/paidui.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close"
    },
    btn_cancel = {
      listener = handler(self, self.Btn_Cancel),
      variName = "m_BtnCancel"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:setDetailData(time, num, serName)
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.frameUpdate))
  self:scheduleUpdate()
  self:frameUpdate()
  self:ListenMessage(MsgID_Connect)
  self:ListenMessage(MsgID_ReConnect)
  CPaiDuiView.Ins = self
end
function CPaiDuiView:setDetailData(time, num, serName)
  self:getNode("txt_ser"):setText(serName)
  self:getNode("txt_num"):setText(string.format("%d人", num))
  self.m_LoginTime = os.time() + time
end
function CPaiDuiView:frameUpdate(dt)
  local restTime = self.m_LoginTime - os.time()
  if restTime < 60 then
    restTime = 60
  end
  self:getNode("txt_time"):setText(string.format("%d分钟", math.ceil(restTime / 60)))
end
function CPaiDuiView:Btn_Close(obj, t)
  print("==>>CPaiDuiView:Btn_Close")
  g_DataMgr:returnToLoginView()
  if LoginGame.Ins then
    LoginGame.Ins:HideWaitingView()
    LoginGame.Ins:LogoutGame()
  end
  self:CloseSelf()
end
function CPaiDuiView:Btn_Cancel(obj, t)
  print("==>>CPaiDuiView:Btn_Cancel")
  g_DataMgr:returnToLoginView()
  if LoginGame.Ins then
    LoginGame.Ins:HideWaitingView()
    LoginGame.Ins:LogoutGame()
  end
  self:CloseSelf()
end
function CPaiDuiView:OnMessage(msgSID, ...)
  print("CPaiDuiView:OnMessage:", msgSID, ...)
  if msgSID == MsgID_Connect_SendFinished then
    self:CloseSelf()
  elseif msgSID == MsgID_ReConnect_PingSuccess then
    self:CloseSelf()
  end
end
function CPaiDuiView:Clear()
  if CPaiDuiView.Ins == self then
    CPaiDuiView.Ins = nil
  end
end
