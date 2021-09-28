local netitem = {}
function netitem.allItemInfo(param, ptc_main, ptc_sub)
  print("netitem.allItemInfo")
  local player = g_DataMgr:getPlayer()
  for k, v in pairs(param.t_items) do
    local svrPro = {}
    for proK, proV in pairs(v) do
      if proK ~= "i_iid" and proK ~= "i_sid" then
        svrPro[proK] = proV
      end
    end
    player:SetOneItem(v.i_iid, v.i_sid, svrPro)
  end
end
function netitem.setOneItem(param, ptc_main, ptc_sub)
  print("netitem.setOneItem")
  local player = g_DataMgr:getPlayer()
  local svrPro = {}
  for proK, proV in pairs(param) do
    if proK ~= "i_iid" and proK ~= "i_sid" then
      svrPro[proK] = proV
    end
  end
  if param.i_iid == nil then
    print("error 物品id为空")
  else
    player:SetOneItem(param.i_iid, param.i_sid, svrPro)
  end
end
function netitem.delOneItem(param, ptc_main, ptc_sub)
  print("netitem.delOneItem")
  local player = g_DataMgr:getPlayer()
  if param.i_iid == nil then
    print("error 物品id为空")
  else
    player:DelOneItem(param.i_iid)
  end
end
function netitem.addItemToRole(param, ptc_main, ptc_sub)
  print("netitem.addItemToRole")
  local player = g_DataMgr:getPlayer()
  player:AddItemToRole(param.i_iid, param.i_oid)
end
function netitem.delItemFromRole(param, ptc_main, ptc_sub)
  print("netitem.delItemFromRole")
  local player = g_DataMgr:getPlayer()
  player:DelItemFromRole(param.i_iid, param.i_oid)
end
function netitem.addNeiDanToPet(param, ptc_main, ptc_sub)
  netitem.addItemToRole(param, ptc_main, ptc_sub)
end
function netitem.delNeiDanFromPet(param, ptc_main, ptc_sub)
  netitem.delItemFromRole(param, ptc_main, ptc_sub)
end
function netitem.upgradeItem(param, ptc_main, ptc_sub)
  print("netitem.upgradeItem")
  local itemId = param.i_itemId
  local itemObj = g_LocalPlayer:GetOneItem(itemId)
  if itemObj ~= nil then
    local lv = itemObj:getProperty(ITEM_PRO_LV)
    if lv == 1 then
      ShowNotifyTips("装备合成成功")
    else
      CheckEquipAddAttr(itemId, true, false)
      ShowNotifyTips("装备升级成功")
    end
  end
  PutItemToUpgradePackageZhuangbei(itemId, true)
  PutItemToUpgradeZhuangbei(itemId, true)
  ResetCreateZhuangbei(true)
  soundManager.playSound(SOUND_PATH_EQUIP_UPGRADE_S)
  g_MissionMgr:GuideIdComplete(GuideId_Dazao)
  g_MissionMgr:GuideIdComplete(GuideId_UpgradeEquipe)
end
function netitem.lianhuaItem(param, ptc_main, ptc_sub)
  print("netitem.lianhuaItem")
  local itemId = param.i_itemId
  ShowNotifyTips("装备炼化成功")
  PutItemToUpgradePackageZhuangbei(itemId, true)
  PutItemToUpgradeZhuangbei(itemId, true)
  soundManager.playSound(SOUND_PATH_EQUIP_UPGRADE_S)
  g_MissionMgr:GuideIdComplete(GuideId_Lianhua)
end
function netitem.chongzhuItem(param, ptc_main, ptc_sub)
  print("netitem.chongzhuItem")
  local itemId = param.i_itemId
  ShowNotifyTips("装备重铸成功")
  PutItemToUpgradePackageZhuangbei(itemId, true)
  PutItemToUpgradeZhuangbei(itemId, true)
  soundManager.playSound(SOUND_PATH_EQUIP_UPGRADE_S)
end
function netitem.qianghuaItem(param, ptc_main, ptc_sub)
  print("netitem.qianghuaItem")
  local itemId = param.i_itemId
  ShowNotifyTips("恭喜,强化成功,强化值+1")
  PutItemToUpgradePackageZhuangbei(itemId, true)
  PutItemToUpgradeZhuangbei(itemId, true)
  soundManager.playSound(SOUND_PATH_EQUIP_UPGRADE_S)
  g_MissionMgr:GuideIdComplete(GuideId_Xiangqian)
end
function netitem.qianghuaItemFail(param, ptc_main, ptc_sub)
  print("netitem.qianghuaItemFail")
  ShowNotifyTips("很遗憾,强化失败了#<E:16>#")
  local itemId = param.i_itemId
  PutItemToUpgradePackageZhuangbei(itemId)
  PutItemToUpgradeZhuangbei(itemId)
  soundManager.playSound(SOUND_PATH_EQUIP_UPGRADE_F)
end
function netitem.getPlayerItemInfo(param, ptc_main, ptc_sub)
  print("netitem.getPlayerItemInfo")
  local svrPro = {}
  for proK, proV in pairs(param) do
    if proK ~= "i_iid" and proK ~= "i_sid" and proK ~= "i_playerid" then
      svrPro[proK] = proV
    end
  end
  ShowChatDetail_Item_WithSvrData(param.i_playerid, param.i_iid, param.i_sid, svrPro)
end
function netitem.dayantaDataUpadte(param, ptc_main, ptc_sub)
  if param then
    activity.dayanta:dayantaDataUpadte(param.i_itimes, param.i_iauto)
  end
end
function netitem.userZBT(param, ptc_main, ptc_sub)
  if param then
    local itemId = param.i_id
    if itemId then
      local itemIns = g_LocalPlayer:GetOneItem(itemId)
      if itemIns and (itemIns:getTypeId() == ITEM_DEF_OTHER_ZBT or itemIns:getTypeId() == ITEM_DEF_OTHER_GJZBT) then
        local mapId = itemIns:getProperty(ITME_PRO_ZBT_SCENE)
        local pos = itemIns:getProperty(ITME_PRO_ZBT_POS)
        local rIndex = itemIns:getProperty(ITEM_PRO_ZBT_RESULTINDEX)
        if mapId ~= 0 and mapId ~= nil and pos ~= nil and #pos >= 2 and rIndex ~= nil and rIndex ~= 0 then
          SendMessage(MsgID_ItemInfo_CangBaoTuClose)
          g_MapMgr:UseZBT(itemId, mapId, pos, rIndex)
        end
      end
    else
      printLog("NetItem", "netitem.userZBT:itemId == nil ")
    end
  end
end
function netitem.userZBTFinish(param, ptc_main, ptc_sub)
  print("userZBTFinish")
  if param then
    local itemId = param.i_id
    print("userZBTFinishitemId", itemId)
    SendMessage(MsgID_ItemInfo_CangBaoTuFinished, {itemId = itemId})
  end
end
function netitem.expendPackage(param, ptc_main, ptc_sub)
  if param then
    local num = param.num
    g_LocalPlayer:SetExpandPackageGird(num)
  end
end
function netitem.finishedZhenliPackage(param, ptc_main, ptc_sub)
  SendMessage(MsgID_ItemInfo_FinishedZhenli)
end
function netitem.showZhuanHuanXianqi(param, ptc_main, ptc_sub)
  if param then
    local id = param.id
    ShowHasZhuanHuanXianQi(id)
  end
end
return netitem
