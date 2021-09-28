local netitem = {}
function netitem.requestAddItemToRole(i_iid, i_oid)
  print("netitem.requestAddItemToRole")
  NetSend({i_iid = i_iid, i_oid = i_oid}, "item", "P1")
end
function netitem.requestDelItemFromRole(i_iid, i_oid)
  print("netitem.requestDelItemFromRole")
  NetSend({i_iid = i_iid, i_oid = i_oid}, "item", "P2")
end
function netitem.requestSellItem(i_iid, i_num)
  print("netitem.requestSellItem")
  NetSend({i_iid = i_iid, i_num = i_num}, "item", "P3")
end
function netitem.requestTakeUpNeiDan(i_iid, i_oid)
  print("netitem.requestTakeUpNeiDan")
  NetSend({i_iid = i_iid, i_oid = i_oid}, "item", "P10")
end
function netitem.requestTakeDownNeiDan(i_iid, i_oid)
  print("netitem.requestTakeDownNeiDan")
  NetSend({i_iid = i_iid, i_oid = i_oid}, "item", "P11")
end
function netitem.requestNeiDanExpFromPet(i_iid, i_oid)
  print("netitem.requestNeiDanExpFromPet")
  NetSend({i_iid = i_iid, i_oid = i_oid}, "item", "P12")
end
function netitem.requestNeiDanZhuanSheng(i_iid, i_oid)
  print("netitem.requestNeiDanZhuanSheng")
  NetSend({i_iid = i_iid, i_oid = i_oid}, "item", "P13")
end
function netitem.equipHuiLu(i_itemId)
  print("netitem.equipHuiLu")
  g_NetConnectMgr:showLoadingLayer(1)
  NetSend({i_itemId = i_itemId}, "item", "P19")
end
function netitem.requestUseItem(i_itemId, i_tarId)
  print("netitem.requestUseItem")
  NetSend({i_itemId = i_itemId, i_tarId = i_tarId}, "item", "P20")
end
function netitem.requestUpgradeItem(i_iid, i_h, i_ts)
  print("netitem.requestUpgradeItem")
  g_NetConnectMgr:showLoadingLayer(1)
  NetSend({
    i_iid = i_iid,
    i_h = i_h,
    i_ts = i_ts
  }, "item", "P23")
end
function netitem.requestLianhuaItem(i_iid, i_h, lock_posts)
  print("netitem.requestLianhuaItem")
  g_NetConnectMgr:showLoadingLayer(1)
  NetSend({
    i_iid = i_iid,
    i_h = i_h,
    lock_posts = lock_posts
  }, "item", "P24")
end
function netitem.requestChongzhuItem(i_iid, i_h, i_s)
  print("netitem.requestChongzhuItem")
  g_NetConnectMgr:showLoadingLayer(1)
  NetSend({
    i_iid = i_iid,
    i_h = i_h,
    i_s = i_s
  }, "item", "P25")
end
function netitem.requestQianghuaItem(i_iid, i_h)
  print("netitem.requestQianghuaItem")
  g_NetConnectMgr:showLoadingLayer(1)
  NetSend({i_iid = i_iid, i_h = i_h}, "item", "P26")
end
function netitem.requestZhengliPackage()
  print("netitem.requestZhengliPackage")
  NetSend({}, "item", "P27")
end
function netitem.requestOnekeyLevelupNeiDan(i_iid, i_oid)
  print("netitem.requestOnekeyLevelupNeiDan")
  NetSend({i_iid = i_iid, i_oid = i_oid}, "item", "P28")
end
function netitem.requestUseDrugOutOfWar(i_rid, i_iid, i_hp, i_mp)
  print("netitem.requestUseDrugOutOfWar", i_rid, i_iid, i_hp, i_mp)
  NetSend({
    i_rid = i_rid,
    i_iid = i_iid,
    i_hp = i_hp,
    i_mp = i_mp
  }, "item", "P29")
end
function netitem.UseNewLianHuaPro(i_iid, i_rid)
  print("netitem.UseNewLianHuaPro", i_iid, i_rid)
  NetSend({i_rid = i_rid, i_iid = i_iid}, "item", "P30")
  g_MissionMgr:GuideIdComplete(GuideId_Lianhua)
end
function netitem.requestUseZhuanPanDrug(id)
  NetSend({id = id}, "item", "P31")
end
function netitem.requestPlayerItemInfo(i_playerid, i_itemId)
  print("netitem.requestPlayerItemInfo")
  NetSend({i_playerid = i_playerid, i_itemId = i_itemId}, "item", "P50")
end
function netitem.requestBuyAndUseItem(itemid, tarid, num)
  g_NetConnectMgr:showLoadingLayer(1)
  print("netitem.requestBuyAndUseItem")
  NetSend({
    itemid = itemid,
    tarid = tarid,
    num = num
  }, "item", "P51")
end
function netitem.requestSellItemList(t_items)
  print("netitem.requestSellItemList")
  NetSend({t_items = t_items}, "item", "P52")
end
function netitem.requestUseItemByGold(i_t, i_n, i_tarid)
  g_NetConnectMgr:showLoadingLayer(1)
  print("netitem.requestUseItemByGold")
  NetSend({
    i_t = i_t,
    i_n = i_n,
    i_tarid = i_tarid
  }, "item", "P53")
end
function netitem.requestGetGJCangBaoTu()
  print("netitem.requestGetGJCangBaoTu")
  NetSend({}, "item", "P54")
end
function netitem.requestBuyPackageGrid()
  print("netitem.requestGetGJCangBaoTu")
  NetSend({}, "item", "P55")
end
function netitem.equipZhuanHuan(id)
  print("netitem.equipZhuanHuan")
  NetSend({id = id}, "item", "P56")
end
return netitem
