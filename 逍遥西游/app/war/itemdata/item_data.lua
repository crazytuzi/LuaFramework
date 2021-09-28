if not CItemData then
  CItemData = class("CItemData")
end
function CItemData:ctor(playerId, objId, lTypeId, copyProperties)
  self.m_Id = objId
  self.m_PlayerId = playerId
  self.m_LogicType = GetItemTypeByItemTypeId(lTypeId)
  self.m_LtypeId = lTypeId
  Properties.extend(self)
  self.m_PropertyChangedListener = nil
  if copyProperties then
    self:setItemProSerialization(copyProperties)
  else
    self:LoadItemPropertyFromData()
  end
end
function CItemData:getObjId()
  return self.m_Id
end
function CItemData:getType()
  return self.m_LogicType
end
function CItemData:getTypeId()
  return self.m_LtypeId
end
function CItemData:getPlayerId()
  return self.m_PlayerId
end
function CItemData:SendMessage(msgSID, ...)
  if SendMessage then
    SendMessage(msgSID, self, ...)
  end
end
function CItemData:LoadItemPropertyFromData()
  printLogDebug("role_data", "[ERROR]没有实现 LoadItemPropertyFromData，ai不应该有这个接口，data才有这个接口")
end
function CItemData:getItemProSerialization()
  return {
    pro = self:getOwnPropertyValueDict()
  }
end
function CItemData:setItemProSerialization(proSerialization)
  if proSerialization.pro then
    for k, v in pairs(proSerialization.pro) do
      local curV = v[1]
      if curV ~= nil then
        self:setProperty(k, curV)
      end
      local maxV = v[2]
      if maxV ~= nil then
        self:setMaxProperty(k, maxV)
      end
    end
  end
end
