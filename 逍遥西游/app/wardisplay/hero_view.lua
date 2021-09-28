local CHeroView = class("CHeroView", CRoleViewBase)
function CHeroView:ctor(pos, roleData, warScene)
  CHeroView.super.ctor(self, pos, roleData, warScene)
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_Message)
end
function CHeroView:getType()
  return LOGICTYPE_HERO
end
function CHeroView:OnMessage(msgSID, ...)
  if msgSID == MsgID_Message_TeamMsg and self.m_IsDirty ~= true then
    local arg = {
      ...
    }
    local chatpid = arg[1]
    local msg = arg[2]
    local yy = arg[4]
    if chatpid == self.m_PlayerId and self.m_IsPlayerMainHero then
      self:addTalkMsg(msg, nil, yy)
    end
  end
end
function CHeroView:getNameColor()
  if self.m_IsPlayerMainHero then
    local nameColor = NameColor_MainHero[self.m_Zs] or ccc3(0, 150, 5)
    return nameColor
  else
    return ccc3(255, 255, 0)
  end
end
function CHeroView:onCleanup()
  CHeroView.super.onCleanup(self)
  self:RemoveAllMessageListener()
end
return CHeroView
