local netstall = {}
function netstall.buyCommodity(id, num)
  NetSend({id = id, num = num}, S2C_STALL, "P1")
end
function netstall.addedGoods(id, num, price, ispet)
  NetSend({
    id = id,
    num = num,
    price = price,
    ispet = ispet
  }, S2C_STALL, "P2")
end
function netstall.offShelfProducts(id)
  NetSend({id = id}, S2C_STALL, "P3")
end
function netstall.withDrawals(id)
  NetSend({id = id}, S2C_STALL, "P4")
end
function netstall.openStallDir(dir, force)
  NetSend({dir = dir, force = force}, S2C_STALL, "P5")
end
function netstall.colseView()
  NetSend({}, S2C_STALL, "P6")
end
function netstall.frushStallData()
  NetSend({}, S2C_STALL, "P7")
end
function netstall.expandStalls()
  NetSend({}, S2C_STALL, "P8")
end
function netstall.backShelves(id, price)
  NetSend({id = id, price = price}, S2C_STALL, "P9")
end
function netstall.getAllMoney()
  if g_BaitanDataMgr then
    g_BaitanDataMgr:SetIsSellingFlag(true)
  end
  NetSend({}, S2C_STALL, "P10")
end
return netstall
