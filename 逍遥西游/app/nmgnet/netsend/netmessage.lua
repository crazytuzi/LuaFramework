local netmessage = {}
function netmessage.sendPrivateMessage(i_pid, s_msg, yy)
  NetSend({
    i_pid = i_pid,
    s_msg = s_msg,
    yy = yy
  }, S2C_MESSAGE, "P1")
end
function netmessage.sendTeamMessage(s_msg, yy)
  NetSend({s_msg = s_msg, yy = yy}, S2C_MESSAGE, "P2")
end
function netmessage.sendWorldMessage(s_msg, yy)
  NetSend({s_msg = s_msg, yy = yy}, S2C_MESSAGE, "P3")
end
function netmessage.sendBangPaiMessage(s_msg, yy)
  NetSend({s_msg = s_msg, yy = yy}, S2C_MESSAGE, "P4")
end
function netmessage.requestLeaveWord()
  NetSend({}, S2C_MESSAGE, "P5")
end
function netmessage.updateLeaveWord()
  NetSend({}, S2C_MESSAGE, "P6")
end
function netmessage.writeLeaveWord(msg)
  NetSend({msg = msg}, S2C_MESSAGE, "P7")
end
function netmessage.sendLocalMessage(s_msg, yy)
  NetSend({s_msg = s_msg, yy = yy}, S2C_MESSAGE, "P8")
end
function netmessage.sendLaBaMessage(s_msg, yy)
  NetSend({s_msg = s_msg, yy = yy}, S2C_MESSAGE, "P9")
end
return netmessage
