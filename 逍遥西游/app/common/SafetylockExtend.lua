SafetylockExtend = {}
function SafetylockExtend.extend(object)
  object.m_SafetyLock_isLock = true
  object.m_SafetyLock_isSetPwd = false
  object.m_SafetyLock_forceUnLockExceedTime = nil
  function object:getSafetyLockIsLock()
    return self.m_SafetyLock_isLock
  end
  function object:getSafetyLockIsSetPwd()
    return self.m_SafetyLock_isSetPwd
  end
  function object:getSafetyLockForceUnlockTime()
    return self.m_SafetyLock_forceUnLockExceedTime
  end
  function object:safetylockDataUpdate(data)
    print("safetylockDataUpdate")
    dump(data, "data")
    local islock = data.islock
    if islock == 1 then
      self.m_SafetyLock_isLock = true
    else
      self.m_SafetyLock_isLock = false
    end
    local passwd = data.passwd
    if passwd == 1 then
      self.m_SafetyLock_isSetPwd = true
    else
      self.m_SafetyLock_isSetPwd = false
    end
    local unlock_exceedtime = data.unlock_exceedtime
    if unlock_exceedtime ~= nil then
      self.m_SafetyLock_forceUnLockExceedTime = unlock_exceedtime
    else
      self.m_SafetyLock_forceUnLockExceedTime = nil
    end
    SendMessage(MsgID_SafetylockDataUpdate)
  end
  function object:needUnlockPwd()
    ShowSafetylockUnlockView()
  end
end
return SafetylockExtend
