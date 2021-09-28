if not CBaseData then
  CBaseData = class("CBaseData")
end
function CBaseData:ctor(playerId, objId, lTypeId)
  self.m_Id = objId
  self.m_PlayerId = playerId
  self.m_LogicType = GetRoleObjType(lTypeId)
  self.m_LtypeId = lTypeId
end
function CBaseData:getObjId()
  return self.m_Id
end
function CBaseData:getType()
  return self.m_LogicType
end
function CBaseData:getTypeId()
  return self.m_LtypeId
end
function CBaseData:getPlayerId()
  return self.m_PlayerId
end
function CBaseData:getWarID()
  return self.m_WarID
end
function CBaseData:SendMessage(msgSID, ...)
  if SendMessage then
    SendMessage(msgSID, self, ...)
  end
end
