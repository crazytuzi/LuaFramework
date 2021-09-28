g_CheckDetailDlg = nil
local SetCheckDetaiDlgPos = function()
  if g_CheckDetailDlg == nil then
    return
  end
  if g_CPHBViewDlg ~= nil then
    g_CPHBViewDlg:setCheckDetailDlg(g_CheckDetailDlg)
  elseif g_SocialityDlg and g_SocialityDlg:getIsDlgShow() then
    g_SocialityDlg:setCheckDetailDlg(g_CheckDetailDlg)
  elseif g_FriendsDlg and g_FriendsDlg:getIsDlgShow() then
    g_FriendsDlg:setCheckDetailDlg(g_CheckDetailDlg)
  elseif g_CMainMenuHandler and g_CMainMenuHandler:getMsgbox() then
    g_CMainMenuHandler:getMsgbox():setCheckDetailDlg(g_CheckDetailDlg)
  end
end
function ClearShowChatDetail()
  if g_CheckDetailDlg then
    g_CheckDetailDlg:CloseSelf()
    g_CheckDetailDlg = nil
  end
end
function ShowChatDetail_Item(playerId, itemId, itemTypeId)
  if g_CheckDetailDlg and iskindof(g_CheckDetailDlg, "CChatDetail_Item") and g_CheckDetailDlg:getPlayerId() == playerId and g_CheckDetailDlg:getItemId() == itemId then
    return
  end
  local isLocal = playerId == g_LocalPlayer:getPlayerId()
  if isLocal then
    if g_LocalPlayer:GetOneItem(itemId) == nil then
      ShowNotifyTips("物品链接已经失效")
      ClearShowChatDetail()
      return
    end
  else
    local iType = GetItemTypeByItemTypeId(itemTypeId)
    if iType == ITEM_LARGE_TYPE_EQPT or iType == ITEM_LARGE_TYPE_SENIOREQPT or iType == ITEM_LARGE_TYPE_SHENBING or iType == ITEM_LARGE_TYPE_XIANQI or itemTypeId == ITEM_DEF_OTHER_ZBT or itemTypeId == ITEM_DEF_OTHER_GJZBT then
      netsend.netitem.requestPlayerItemInfo(playerId, itemId)
      return
    end
  end
  ClearShowChatDetail()
  g_CheckDetailDlg = CChatDetail_Item.new(playerId, itemId, itemTypeId)
  getCurSceneView():addSubView({
    subView = g_CheckDetailDlg,
    zOrder = MainUISceneZOrder.menuView
  })
  SetCheckDetaiDlgPos()
end
function ShowChatDetail_Item_WithSvrData(playerId, itemId, itemTypeId, data)
  ClearShowChatDetail()
  g_CheckDetailDlg = CChatDetail_Item.new(playerId, itemId, itemTypeId, data)
  getCurSceneView():addSubView({
    subView = g_CheckDetailDlg,
    zOrder = MainUISceneZOrder.menuView
  })
  SetCheckDetaiDlgPos()
end
function ShowChatDetail_Pet(playerId, petId)
  if g_CheckDetailDlg and iskindof(g_CheckDetailDlg, "CChatDetail_Pet") and g_CheckDetailDlg:getPlayerId() == playerId and g_CheckDetailDlg:getPetId() == petId then
    return g_CheckDetailDlg
  end
  local isLocal = playerId == g_LocalPlayer:getPlayerId()
  if isLocal then
    local petIns = g_LocalPlayer:getObjById(petId)
    if petIns == nil then
      ShowNotifyTips("宠物链接已经失效")
      ClearShowChatDetail()
      return
    end
    local data = {}
    data.i_playerid = playerId
    data.i_pid = petId
    data.i_type = petIns:getTypeId()
    data.i_lv = petIns:getProperty(PROPERTY_ROLELEVEL)
    data.i_exp = petIns:getProperty(PROPERTY_EXP)
    data.s_name = petIns:getProperty(PROPERTY_NAME)
    data.i_grand = petIns:getProperty(PROPERTY_RANDOM_GROWUP)
    data.i_hprand = petIns:getProperty(PROPERTY_RANDOM_HPBASE)
    data.i_mprand = petIns:getProperty(PROPERTY_RANDOM_MPBASE)
    data.i_aprand = petIns:getProperty(PROPERTY_RANDOM_APBASE)
    data.i_sprand = petIns:getProperty(PROPERTY_RANDOM_SPBASE)
    local temp = petIns:getRandomKang()
    local i = 1
    for k, _ in pairs(temp) do
      local v = PROPERTIES_RANDOM_KANG_REVERSE[k]
      if v ~= nil then
        data[string.format("i_defrate%d", i)] = v
        i = i + 1
        if i > 2 then
          break
        end
      end
    end
    data.i_gg = petIns:getProperty(PROPERTY_GenGu)
    data.i_lx = petIns:getProperty(PROPERTY_Lingxing)
    data.i_ll = petIns:getProperty(PROPERTY_LiLiang)
    data.i_mj = petIns:getProperty(PROPERTY_MinJie)
    data.i_pt = petIns:getProperty(PROPERTY_FREEPOINT)
    data.i_rebirth = petIns:getProperty(PROPERTY_ZHUANSHENG)
    data.i_ngbone = petIns:getProperty(PROPERTY_LONGGU_NUM)
    data.i_close = petIns:getProperty(PROPERTY_CLOSEVALUE)
    data.i_hj = petIns:getProperty(PROPERTY_HUAJING_NUM)
    data.i_hl = petIns:getProperty(PROPERTY_HUALING_NUM)
    data.i_hjcz = petIns:getProperty(PROPERTY_HUAJING_ADDPRONUM)
    data.i_lyn = petIns:getProperty(PROPERTY_LIANYAO_NUM)
    data.i_k1 = petIns:getProperty(PROPERTY_PETLIANHUA_PDEFEND)
    data.i_k2 = petIns:getProperty(PROPERTY_PETLIANHUA_KFENG)
    data.i_k3 = petIns:getProperty(PROPERTY_PETLIANHUA_KHUO)
    data.i_k4 = petIns:getProperty(PROPERTY_PETLIANHUA_KSHUI)
    data.i_k5 = petIns:getProperty(PROPERTY_PETLIANHUA_KLEI)
    data.i_k6 = petIns:getProperty(PROPERTY_PETLIANHUA_KHUNLUAN)
    data.i_k7 = petIns:getProperty(PROPERTY_PETLIANHUA_KFENGYIN)
    data.i_k8 = petIns:getProperty(PROPERTY_PETLIANHUA_KHUNSHUI)
    data.i_k9 = petIns:getProperty(PROPERTY_PETLIANHUA_KZHONGDU)
    data.i_k10 = petIns:getProperty(PROPERTY_PETLIANHUA_KZHENSHE)
    data.i_k11 = petIns:getProperty(PROPERTY_PETLIANHUA_KAIHAO)
    data.i_k12 = petIns:getProperty(PROPERTY_PETLIANHUA_KYIWANG)
    data.t_skills = petIns:getProperty(PROPERTY_PETSKILLS)
    data.t_skillpro = petIns:getProperty(PROPERTY_ZJSKILLSEXP)
    data.t_ss = petIns:getProperty(PROPERTY_SSSKILLS)
    data.t_items = {}
    local zbList = petIns:getZhuangBei()
    for itemId, _ in pairs(zbList) do
      local itemIns = g_LocalPlayer:GetOneItem(itemId)
      if itemIns and itemIns:getType() == ITEM_LARGE_TYPE_NEIDAN then
        local ndList = {}
        ndList.i_iid = itemIns:getObjId()
        ndList.i_sid = itemIns:getTypeId()
        ndList.i_nlv = itemIns:getProperty(ITEM_PRO_LV)
        ndList.i_nexp = itemIns:getProperty(ITEM_PRO_NEIDAN_EXP)
        ndList.i_nzs = itemIns:getProperty(ITEM_PRO_NEIDAN_ZS)
        data.t_items[#data.t_items + 1] = ndList
      end
    end
    ClearShowChatDetail()
    g_CheckDetailDlg = CChatDetail_Pet.new(playerId, petId, data)
    getCurSceneView():addSubView({
      subView = g_CheckDetailDlg,
      zOrder = MainUISceneZOrder.menuView
    })
    SetCheckDetaiDlgPos()
  else
    netsend.netbaseptc.requestPlayerPetInfo(playerId, petId)
  end
end
function ShowChatDetail_Pet_WithSvrData(playerId, petId, data)
  ClearShowChatDetail()
  g_CheckDetailDlg = CChatDetail_Pet.new(playerId, petId, data)
  getCurSceneView():addSubView({
    subView = g_CheckDetailDlg,
    zOrder = MainUISceneZOrder.menuView
  })
  SetCheckDetaiDlgPos()
end
