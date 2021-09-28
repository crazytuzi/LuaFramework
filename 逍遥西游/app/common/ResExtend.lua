ResExtend = {}
function ResExtend.extend(object)
  object.m_GoldNum = 0
  object.m_CoinNum = 0
  object.m_Arch = 0
  object.m_Honour = 0
  object.m_Silver = 0
  object.m_BpConstruct = 0
  object.m_HuoliValue = 0
  object.m_StoreExp = 0
  object.m_XiaYiValue = 0
  function object:setGold(goldNum)
    local oldGold = object.m_GoldNum
    object.m_GoldNum = goldNum
    SendMessage(MsgID_MoneyUpdate, {
      pid = object.m_RoleId,
      oldGold = oldGold,
      newGold = goldNum
    })
  end
  function object:getGold()
    return object.m_GoldNum
  end
  function object:setCoin(coinNum)
    local oldCoin = object.m_CoinNum
    object.m_CoinNum = coinNum
    SendMessage(MsgID_MoneyUpdate, {
      pid = object.m_RoleId,
      oldCoin = oldCoin,
      newCoin = coinNum
    })
  end
  function object:getCoin()
    return object.m_CoinNum
  end
  function object:setSilver(silver)
    local oldSilver = object.m_Silver
    object.m_Silver = silver
    SendMessage(MsgID_MoneyUpdate, {
      pid = object.m_RoleId,
      oldSilver = oldSilver,
      newSilver = silver
    })
  end
  function object:getSilver()
    return object.m_Silver
  end
  function object:setArch(arch)
    object.m_Arch = arch
    SendMessage(MsgID_ArchUpdate, arch)
  end
  function object:getArch()
    return object.m_Arch
  end
  function object:setHonour(honour)
    local oldHonour = object.m_Honour
    object.m_Honour = honour
    SendMessage(MsgID_HonourUpdate, {
      pid = object.m_RoleId,
      oldHonour = oldHonour,
      newHonour = honour
    })
  end
  function object:getHonour()
    return object.m_Honour
  end
  function object:setBpConstruct(construct)
    local oldConstruct = object.m_BpConstruct
    object.m_BpConstruct = construct
    SendMessage(MsgID_BpOfferUpdate, construct)
  end
  function object:getBpConstruct()
    return object.m_BpConstruct
  end
  function object:setHuoli(huoli)
    local oldHuoli = object.m_HuoliValue
    object.m_HuoliValue = huoli
    SendMessage(MsgID_HouliUpdate, {
      pid = object.m_RoleId,
      oldHuoli = oldHuoli,
      newHuoli = huoli
    })
  end
  function object:getHuoli()
    return object.m_HuoliValue
  end
  function object:setStoreExp(exp)
    local oldexp = self.m_StoreExp
    self.m_StoreExp = exp
    SendMessage(MsgID_HouliUpdate, {
      pid = object.m_RoleId,
      oldStoreExp = oldexp,
      newStoreExp = self.m_StoreExp
    })
  end
  function object:getStoreExp()
    return self.m_StoreExp
  end
  function object:setXiaYiValue(xiayi)
    local oldXiayi = object.m_XiaYiValue
    object.m_XiaYiValue = xiayi
    SendMessage(MsgID_MoneyUpdate, {
      pid = object.m_RoleId,
      oldXiayi = oldXiayi,
      newXiaYi = xiayi
    })
  end
  function object:getXiaYiValue()
    return object.m_XiaYiValue
  end
end
return ResExtend
