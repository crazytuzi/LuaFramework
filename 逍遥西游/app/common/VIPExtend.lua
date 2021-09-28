VIPExtend = {}
function VIPExtend.extend(object)
  object.m_VIPLv = 0
  object.m_HasAddGold = 0
  function object:setVipLv(vipLv)
    local oldVIP = object.m_VIPLv
    object.m_VIPLv = vipLv
    SendMessage(MsgID_VIPUpdate, {
      pid = object.m_RoleId,
      oldVIP = oldVIP,
      newVIP = vipLv
    })
  end
  function object:getVipLv()
    return object.m_VIPLv
  end
  function object:setVipAddGold(num)
    local oldAddGold = object.m_HasAddGold
    object.m_HasAddGold = num
    SendMessage(MsgID_VIPUpdateAddGold, {
      pid = object.m_RoleId,
      oldAddGold = oldVIP,
      newAddGold = num
    })
  end
  function object:getVipAddGold()
    return object.m_HasAddGold
  end
end
return VIPExtend
