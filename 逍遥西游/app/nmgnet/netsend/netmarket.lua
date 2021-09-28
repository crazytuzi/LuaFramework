local netmarket = {}
function netmarket.buyMarketItem(itemid, num)
  g_NetConnectMgr:showLoadingLayer(1)
  NetSend({itemid = itemid, num = num}, S2C_MARKET, "P1")
end
function netmarket.sellMarketItem(itemid, num)
  NetSend({itemid = itemid, num = num}, S2C_MARKET, "P2")
end
function netmarket.requestMarketInfo(iType)
  NetSend({dir = iType}, S2C_MARKET, "P3")
end
function netmarket.closeMarket()
  NetSend({}, S2C_MARKET, "P4")
end
return netmarket
