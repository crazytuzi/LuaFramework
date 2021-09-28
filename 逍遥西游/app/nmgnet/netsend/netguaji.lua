local netguaji = {}
function netguaji.enterGuajiMap(mapId)
  print("netguaji.enterGuajiMap", mapId)
  NetSend({sceneid = mapId}, "guaji", "P1")
end
function netguaji.startGuaji()
  print("netguaji.startGuaji")
  NetSend({}, "guaji", "P2")
end
function netguaji.endGuaji()
  print("netguaji.endGuaji")
  NetSend({}, "guaji", "P3")
end
function netguaji.setAutoAddBSD(flag)
  print("netguaji.setAutoAddBSD")
  NetSend({i = flag}, "guaji", "P4")
end
return netguaji
