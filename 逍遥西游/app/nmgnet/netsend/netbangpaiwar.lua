local netbangpaiwar = {}
function netbangpaiwar.requestSignUp()
  NetSend({}, S2C_BPWAR, "P1")
end
function netbangpaiwar.submitMoney(money)
  NetSend({money = money}, S2C_BPWAR, "P2")
end
function netbangpaiwar.gotoWarMap()
  NetSend({}, S2C_BPWAR, "P3")
end
function netbangpaiwar.launchBpFight(pid)
  NetSend({pid = pid}, S2C_BPWAR, "P4")
end
function netbangpaiwar.quitBpFight()
  NetSend({}, S2C_BPWAR, "P5")
end
return netbangpaiwar
