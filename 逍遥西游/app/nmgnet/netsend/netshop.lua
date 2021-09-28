local netshop = {}
function netshop.shopbuyitem(i_st, i_it, i_n, i_i)
  g_NetConnectMgr:showLoadingLayer(1)
  NetSend({
    i_st = i_st,
    i_it = i_it,
    i_n = i_n,
    i_i = i_i
  }, "shop", "P1")
end
function netshop.openSecretShop()
  NetSend({}, "shop", "P2")
end
function netshop.frushSecretShop()
  NetSend({}, "shop", "P3")
end
function netshop.BuyCoinUseGold(i_n)
  NetSend({i_n = i_n}, "shop", "P4")
end
function netshop.BuySilverUseGold(i_n)
  NetSend({i_n = i_n}, "shop", "P5")
end
function netshop.OpenXiaYiShop()
  NetSend({}, "shop", "P6")
end
function netshop.BuyXiaYiGoods(id)
  NetSend({id = id}, "shop", "P7")
end
function netshop.AskXianGouList()
  NetSend({}, "shop", "P8")
end
function netshop.BuyXianGouItem(no, num)
  g_NetConnectMgr:showLoadingLayer(1)
  NetSend({no = no, num = num}, "shop", "P9")
end
function netshop.SendPaiMaiShenShou(i_i)
  g_NetConnectMgr:showLoadingLayer(1)
  NetSend({i_i = i_i}, "shop", "P10")
end
return netshop
