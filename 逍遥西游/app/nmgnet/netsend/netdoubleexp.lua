local netdoubleexp = {}
function netdoubleexp.requestGetDEP()
  NetSend({}, S2C_DoubleExp, "P1")
end
function netdoubleexp.requestClearDEP()
  NetSend({}, S2C_DoubleExp, "P2")
end
return netdoubleexp
