g_BpTuiWeiRangXianDlg = nil
function ShowBpTuiWeiRangXian(info)
  if g_BpTuiWeiRangXianDlg == nil then
    g_BpTuiWeiRangXianDlg = getCurSceneView():addSubView({
      subView = CBpTuiWeiRangXian.new(info),
      zOrder = MainUISceneZOrder.menuView
    })
  else
    g_BpTuiWeiRangXianDlg:setInfo(info)
  end
end
CBpTuiWeiRangXian = class("CBpTuiWeiRangXian", CcsSubView)
function CBpTuiWeiRangXian:ctor(info)
  CBpTuiWeiRangXian.super.ctor(self, "views/bptuiweirangxian.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_cancel"
    },
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_confirm"
    },
    btn_1 = {
      listener = handler(self, self.OnBtn_1),
      variName = "btn_1"
    },
    btn_2 = {
      listener = handler(self, self.OnBtn_2),
      variName = "btn_2"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.img_selected = self:getNode("img_selected")
  self.fbz_1 = self:getNode("fbz_1")
  self.fbz_2 = self:getNode("fbz_2")
  self:setInfo(info)
  g_TouchEvent:setCanTouch(false)
end
function CBpTuiWeiRangXian:setInfo(info)
  for index = 1, 2 do
    local btn = self[string.format("btn_%d", index)]
    local fbz = self[string.format("fbz_%d", index)]
    local data = info[index]
    if data then
      btn:setEnabled(true)
      fbz:setEnabled(true)
      btn._pid = data.i_pid
      local color = NameColor_MainHero[data.i_zs]
      fbz:setColor(color)
      fbz:setText(string.format("%s(副帮主)", data.s_pname))
    else
      btn:setEnabled(false)
      fbz:setEnabled(false)
      btn._pid = nil
    end
  end
  if #info <= 0 then
    self.m_SelectIndex = nil
    self.img_selected:setVisible(false)
  elseif self.m_SelectIndex == nil then
    self:OnBtn_1()
  elseif self.m_SelectIndex == 2 and not self.btn_2:isEnabled() then
    self:OnBtn_1()
  end
end
function CBpTuiWeiRangXian:OnBtn_1()
  self.m_SelectIndex = 1
  local x, y = self.btn_1:getPosition()
  self.img_selected:setPosition(ccp(x + 18, y + 8))
  self.img_selected:setVisible(true)
end
function CBpTuiWeiRangXian:OnBtn_2()
  self.m_SelectIndex = 2
  local x, y = self.btn_2:getPosition()
  self.img_selected:setPosition(ccp(x + 18, y + 8))
  self.img_selected:setVisible(true)
end
function CBpTuiWeiRangXian:OnBtn_Close()
  self:CloseSelf()
end
function CBpTuiWeiRangXian:OnBtn_Confirm()
  if self.m_SelectIndex == nil then
    ShowNotifyTips("请先选择一个副帮主")
    return
  end
  local btn = self[string.format("btn_%d", self.m_SelectIndex)]
  local pid = btn._pid
  if pid == nil then
    ShowNotifyTips("请先选择一个副帮主")
    return
  end
  self:CloseSelf()
  g_BpMgr:send_changeBpLeader(pid)
end
function CBpTuiWeiRangXian:Clear()
  g_BpTuiWeiRangXianDlg = nil
  g_TouchEvent:setCanTouch(true)
end
