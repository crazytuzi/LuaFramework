function ShowPlayerInfoOfChat(pid, roleTypeId, name, zs, lv, channel, msg)
  if g_SocialityDlg and g_SocialityDlg:getIsDlgShow() then
    local dlg = getCurSceneView():addSubView({
      subView = CPlayerInfoOfChat.new(pid, roleTypeId, name, zs, lv, channel, nil, msg),
      zOrder = MainUISceneZOrder.menuView
    })
    local size = g_SocialityDlg:getSize()
    local dSize = dlg:getSize()
    local x, y = g_SocialityDlg:getPosition()
    dlg:setPosition(ccp(x + size.width, size.height / 2 - dSize.height / 2 - 5))
    dlg:adjustPos()
  elseif g_FriendsDlg and g_FriendsDlg:getIsDlgShow() then
    local dlg = getCurSceneView():addSubView({
      subView = CPlayerInfoOfChat.new(pid, roleTypeId, name, zs, lv, channel, nil, msg),
      zOrder = MainUISceneZOrder.menuView
    })
    local size = g_FriendsDlg:getSize()
    local dSize = dlg:getSize()
    local x, y = g_FriendsDlg:getPosition()
    dlg:setPosition(ccp(x + size.width, size.height / 2 - dSize.height / 2 - 5))
    dlg:adjustPos()
  end
end
CPlayerInfoOfChat = class("CPlayerInfoOfChat", CPlayerInfoOfMap)
function CPlayerInfoOfChat:ctor(pid, roleTypeId, name, zs, lv, channel, closeListener, msg)
  self.m_TempRoleTypeId = roleTypeId
  self.m_TempName = name
  self.m_TempZs = zs
  self.m_TempLevel = lv
  self.m_Channel = channel
  self.m_msg = msg
  CPlayerInfoOfChat.super.ctor(self, pid, closeListener, "views/playerInfoOfChat.json")
  local pic_headbg = self:getNode("pic_headbg")
  local x, y = pic_headbg:getPosition()
  local p = pic_headbg:getParent()
  local z = pic_headbg:getZOrder()
  local head = createHeadIconByRoleTypeID(roleTypeId)
  p:addNode(head, z + 1)
  head:setPosition(ccp(x + HEAD_OFF_X, y + HEAD_OFF_Y))
  self.m_Arrrow = self:getNode("pic_arrow")
  self:enableCloseWhenTouchOutside(self:getNode("bg"), true)
end
function CPlayerInfoOfChat:setRoleInfo(pid)
  local data = data_Hero[self.m_TempRoleTypeId]
  if data then
    race = data.RACE
    self:SetInfo(self.m_TempName, race, self.m_TempZs, self.m_TempLevel)
  else
    self:HideInfo()
  end
end
function CPlayerInfoOfChat:isShowPingBi()
  return self.m_Channel == CHANNEL_WOLRD
end
function CPlayerInfoOfChat:isShowJuBao()
  return self.m_Channel == CHANNEL_WOLRD or self.m_Channel == CHANNEL_LaBa
end
