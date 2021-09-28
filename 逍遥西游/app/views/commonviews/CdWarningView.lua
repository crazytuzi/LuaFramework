CdWarningView = class("CdWarningView", CcsSubView)
function CdWarningView:ctor(title, cdTime, btnName, cblistener, isChangeMapClose)
  CdWarningView.super.ctor(self, "views/cd_warning_view.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_ok = {
      listener = handler(self, self.OnBtn_OK),
      variName = "btn_ok"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.frameUpdate))
  self:scheduleUpdate()
  self:getNode("title"):setText(title)
  self.m_CdTxt = self:getNode("cd")
  self.btn_ok:setTitleText(btnName)
  self.m_Cd = cdTime
  self.m_LastShowCd = nil
  self.m_Listener = cblistener
  self:showCd(math.floor(self.m_Cd))
  getCurSceneView():addSubView({
    subView = self,
    zOrder = MainUISceneZOrder.popView
  })
  self.m_IsChangeMapClose = isChangeMapClose
  self:ListenMessage(MsgID_MapScene)
end
function CdWarningView:frameUpdate(dt)
  self.m_Cd = self.m_Cd - dt
  self:showCd(math.floor(self.m_Cd))
  if self.m_Cd <= 0 then
    self:CloseView()
  end
end
function CdWarningView:OnMessage(msgSID, ...)
  if msgSID == MsgID_MapScene_ChangedMap then
    local arg = {
      ...
    }
    local pid = arg[1]
    if pid == g_LocalPlayer:getPlayerId() and self.m_IsChangeMapClose == true then
      self:CloseSelf()
    end
  end
end
function CdWarningView:showCd(cd)
  if cd < 0 then
    cd = 0
  end
  if self.m_LastShowCd ~= cd then
    self.m_LastShowCd = cd
    self.m_CdTxt:setText(cd)
  end
end
function CdWarningView:CloseView()
  if self.m_Listener ~= nil then
    self.m_Listener()
  end
  self:CloseSelf()
end
function CdWarningView:OnBtn_OK(obj, t)
  self:CloseView()
end
function CdWarningView:Clear()
  self.m_Listener = nil
end
