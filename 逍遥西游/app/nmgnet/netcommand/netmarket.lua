local netmarket = {}
function netmarket.setMarkItemInfo(param, ptc_main, ptc_sub)
  print("netmarket.setMarkItemInfo:", param, ptc_main, ptc_sub)
  local typeNumber = param.dir
  local goods = param.goods
  if g_Market then
    local silverPanel = g_Market:getSilverMarketPanel()
    if silverPanel then
      silverPanel:setMarkItemInfoFromSvr(typeNumber, goods)
    end
  end
end
function netmarket.updateMarkItemInfo(param, ptc_main, ptc_sub)
  print("netmarket.setMarkItemInfo:", param, ptc_main, ptc_sub)
  local typeNumber = param.dir
  local goods = param.goods
  if g_Market then
    local silverPanel = g_Market:getSilverMarketPanel()
    if silverPanel then
      silverPanel:updateMarkItemInfoFromSvr(typeNumber, goods)
    end
  end
end
return netmarket
