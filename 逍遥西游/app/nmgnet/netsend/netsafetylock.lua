local netsafetylock = {}
function netsafetylock.setPwd(passwd, checkpasswd)
  NetSend({passwd = passwd, checkpasswd = checkpasswd}, S2C_SafetyLock, "P1")
end
function netsafetylock.requestUnlock(passwd)
  NetSend({passwd = passwd}, S2C_SafetyLock, "P2")
end
function netsafetylock.resetPwd(oldpasswd, passwd, checkpasswd)
  NetSend({
    oldpasswd = oldpasswd,
    passwd = passwd,
    checkpasswd = checkpasswd
  }, S2C_SafetyLock, "P3")
end
function netsafetylock.cancel(passwd)
  NetSend({passwd = passwd}, S2C_SafetyLock, "P4")
end
function netsafetylock.forceUnlock(passwd)
  NetSend({passwd = passwd}, S2C_SafetyLock, "P5")
end
return netsafetylock
