local netshop = {}
function netshop.setSecretShopData(param, ptc_main, ptc_sub)
  local smsdFrushNum = param.i_t
  local secretShopData = param.t_a
  SetSecretShopFrushNum(smsdFrushNum)
  SetSecretShopData(secretShopData)
end
function netshop.updateSecretShopNum(param, ptc_main, ptc_sub)
  local sellId = param.i_i
  local restNum = param.i_n
  UpdateSecretShopData(sellId, restNum)
end
function netshop.canUpdateSecretShop(param, ptc_main, ptc_sub)
  if g_CMainMenuHandler then
    g_CMainMenuHandler:SetSMSDFlag(true)
  end
end
function netshop.canShowRechargeView(param, ptc_main, ptc_sub)
  if param.i_f == 1 then
    g_LocalPlayer:setCanShowRechargeView(true)
  else
    g_LocalPlayer:setCanShowRechargeView(false)
  end
end
function netshop.canShowBuyRechargeViewItem(param, ptc_main, ptc_sub)
  if param.t_l ~= nil then
    g_LocalPlayer:setCanShowRechargeItemList(param.t_l)
  else
    g_LocalPlayer:setCanShowRechargeItemList({})
  end
end
function netshop.updateXiaYiShop(param, ptc_main, ptc_sub)
  if param.shoplist then
    SetXiaYiShopData(param.shoplist)
  end
end
function netshop.updateXianGouData(param, ptc_main, ptc_sub)
  local list = param.t_l or {}
  if g_LocalPlayer then
    g_LocalPlayer:SetXianGouShopList(list)
  end
end
function netshop.updateMomoCZFLTime(param, ptc_main, ptc_sub)
  local startTimePoint = param.i_s
  local endTimePoint = param.i_e
  g_LocalPlayer:setMoMoChongZhiFanliTime(startTimePoint, endTimePoint)
end
function netshop.updatePaiMaiShenShouData(param, ptc_main, ptc_sub)
  local startTimePoint = param.i_s
  local endTimePoint = param.i_e
  local listData = param.t_l
  dump(listData, "updatePaiMaiShenShouData")
  dump(startTimePoint, "updatePaiMaiShenShouData startTimePoint")
  dump(endTimePoint, "updatePaiMaiShenShouData endTimePoint")
  g_LocalPlayer:setPaiMaiShenShouTime(startTimePoint, endTimePoint)
  g_LocalPlayer:setPaiMaiShenShouData(listData)
end
return netshop
