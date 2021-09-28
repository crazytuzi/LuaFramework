CZBD_ITEM_1101 = 1101
CZBC_ITEM_1102 = 1102
CZBD_ITEM_1103 = 1103
CZBD_ITEM_1104 = 1104
CZBD_ITEM_1105 = 1105
CZBD_ITEM_1106 = 1106
CZBD_ITEM_1107 = 1107
CZBD_ITEM_1201 = 1201
CZBD_ITEM_1202 = 1202
CZBD_ITEM_1203 = 1203
CZBD_ITEM_1204 = 1204
CZBD_ITEM_1205 = 1205
CZBD_ITEM_1206 = 1206
CZBD_ITEM_1207 = 1207
CZBD_ITEM_1301 = 1301
CZBD_ITEM_1401 = 1401
CZBD_ITEM_1402 = 1402
CZBD_ITEM_1403 = 1403
CZBD_ITEM_1404 = 1404
CZBD_ITEM_1405 = 1405
CZBD_ITEM_1406 = 1406
CZBD_ITEM_1407 = 1407
CZBD_ITEM_1408 = 1408
CZBD_ITEM_1409 = 1409
CZBD_ITEM_1410 = 1410
CZBD_ITEM_1411 = 1411
CZBD_ITEM_1412 = 1412
CZBD_ITEM_1413 = 1413
CZBD_ITEM_1414 = 1414
CZBD_ITEM_1415 = 1415
CZBD_ITEM_1416 = 1416
CZBD_ITEM_2101 = 2101
CZBD_ITEM_2201 = 2201
CZBD_ITEM_2202 = 2202
CZBD_ITEM_2203 = 2203
CZBD_ITEM_2204 = 2204
CZBD_ITEM_3101 = 3101
CZBD_ITEM_3102 = 3102
CZBD_ITEM_3201 = 3201
CZBD_ITEM_3202 = 3202
CZBD_ITEM_3203 = 3203
CZBD_ITEM_3204 = 3204
CZBD_ITEM_3205 = 3205
CZBD_ITEM_3206 = 3206
CZBD_ITEM_3301 = 3301
CZBD_ITEM_3302 = 3302
CZBD_ITEM_3303 = 3303
CZBD_ITEM_3401 = 3401
CZBD_ITEM_3501 = 3501
CZBD_ITEM_3601 = 3601
CZBD_ITEM_3602 = 3602
CZBD_ITEM_3603 = 3603
CZBD_ITEM_3701 = 3701
CZBD_ITEM_3801 = 3801
CZBD_ITEM_3802 = 3802
CZBD_ITEM_39101 = 39101
CZBD_ITEM_39102 = 39102
CZBD_ITEM_39201 = 39201
CZBD_ITEM_4001 = 4001
CZBD_ITEM_4002 = 4002
CZBD_ITEM_4003 = 4003
CZBD_ITEM_4004 = 4004
CZBD_ITEM_4005 = 4005
CZBD_ITEM_4006 = 4006
CZBD_ITEM_4007 = 4007
CZBD_ITEM_5001 = 5001
CZBD_ITEM_5002 = 5002
CZBD_ITEM_5004 = 5004
CZBD_ITEM_6001 = 6001
CZBD_ITEM_7001 = 7001
CZBD_ITEM_8001 = 8001
CZBD_ITEM_14 = 14
CZBD_ITEM_39 = 39
JumpExtend = {}
function JumpExtend.extend(obj)
  function obj:StartJump(id)
    local addpoint_id = math.floor(id / 100)
    if not data_getCZBD_ItemCanJumpInWar(id) then
      if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
        ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
        return
      end
      if g_MapMgr:IsInBangPaiWarMap() and g_BpWarMgr:getBpWarState() == BPWARSTATE_START then
        ShowNotifyTips("帮战地图无法使用此功能")
        return
      end
      if not activity.yzdd:canJumpMap() then
        return
      end
      if not g_DuleMgr:canJumpMap() then
        return
      end
      if JudgeIsInWar() then
        ShowNotifyTips("处于战斗中，不能跳转")
        return
      end
    end
    if not data_getCZBD_ItemCanJumpAsTeamer(id) and g_LocalPlayer:getNormalTeamer() == true then
      ShowNotifyTips("你已跟随队长中，不能跳转")
      return
    end
    if addpoint_id == CZBD_ITEM_14 then
      obj:SetShow(false)
      local view = settingDlg.new({spId = id}, function()
        obj:SetShow(true)
      end)
      getCurSceneView():addSubView({
        subView = view,
        zOrder = MainUISceneZOrder.menuView
      })
      view:ShowSetPoint()
    elseif addpoint_id == CZBD_ITEM_39 then
      print("$$$$$$$$$$$$$$$:终极技能，跳转到市场界面", id)
      enterMarket({
        initViewType = MarketShow_InitShow_CoinView,
        initBaitanType = BaitanShow_InitShow_ShoppingView,
        initBaitanMainType = 7,
        initBaitanSubType = 1
      })
    end
    if id == CZBD_ITEM_1101 then
      getCurSceneView():addSubView({
        subView = CMissionView.new(),
        zOrder = MainUISceneZOrder.menuView
      })
    elseif id == CZBC_ITEM_1102 then
      obj:GuanQiaView()
    elseif id == CZBD_ITEM_1103 then
      obj:TalkToAnShiZhuChiView(10003)
    elseif id == CZBD_ITEM_1104 then
      obj:ZhuaGui()
    elseif id == CZBD_ITEM_1105 then
      obj:TalkToAnShiZhuChiView(activity.dayanta.StartNpcId)
    elseif id == CZBD_ITEM_1106 then
      obj:TalkToAnShiZhuChiView(activity.tianting.startNpc)
    elseif id == CZBD_ITEM_1107 then
      obj:GotoNpc(90011)
    elseif id == CZBD_ITEM_1201 then
      obj:Tisheng25Ji(90002)
    elseif id == CZBD_ITEM_1202 then
      obj:Tisheng25Ji(90003)
    elseif id == CZBD_ITEM_1203 then
      obj:LianHua(g_LocalPlayer:getMainHeroId())
    elseif id == CZBD_ITEM_1204 then
      obj:QingHuaZhuangBei(g_LocalPlayer:getMainHeroId())
    elseif id == CZBD_ITEM_1205 then
      obj:ShengJiZhuangBei(g_LocalPlayer:getMainHeroId())
    elseif id == CZBD_ITEM_1206 then
      obj:CreateZhuangBeiView(1)
    elseif id == CZBD_ITEM_1207 then
      obj:CreateZhuangBeiView(2)
    elseif id == CZBD_ITEM_1301 then
      obj:SkillView()
    elseif id == CZBD_ITEM_2101 then
      obj:GetHuobanView()
    elseif id == CZBD_ITEM_2201 then
      obj:LianHua()
    elseif id == CZBD_ITEM_2202 then
      obj:QingHuaZhuangBei()
    elseif id == CZBD_ITEM_2203 then
      obj:ShengJiZhuangBei()
    elseif id == CZBD_ITEM_2204 then
      obj:HuoBanView()
    elseif id == CZBD_ITEM_3101 then
      obj:ChongWuTJView(true)
    elseif id == CZBD_ITEM_3102 then
      obj:ChongWuTJView(false)
    elseif id == CZBD_ITEM_3201 then
      obj:GuanQiaView()
    elseif id == CZBD_ITEM_3202 then
      obj:TalkToAnShiZhuChiView(10003)
    elseif id == CZBD_ITEM_3203 then
      obj:ZhuaGui()
    elseif id == CZBD_ITEM_3204 then
      obj:TalkToAnShiZhuChiView(activity.dayanta.StartNpcId)
    elseif id == CZBD_ITEM_3205 then
      obj:TalkToAnShiZhuChiView(activity.tianting.startNpc)
    elseif id == CZBD_ITEM_3206 then
      obj:GotoNpc(90011)
    elseif id == CZBD_ITEM_3301 then
      obj:BuyNeiDan()
    elseif id == CZBD_ITEM_3302 then
      obj:toPetView(2)
    elseif id == CZBD_ITEM_3303 then
      obj:toPetView(1)
    elseif id == CZBD_ITEM_3401 then
      obj:LianyaoView(PetShow_InitShow_LianYaoView)
    elseif id == CZBD_ITEM_3501 then
      obj:LianyaoView(PetShow_InitShow_XiChongView)
    elseif id == CZBD_ITEM_3601 then
      obj:ZuoQiView()
    elseif id == CZBD_ITEM_3602 then
      obj:ZuoQiLvUp(1)
    elseif id == CZBD_ITEM_3603 then
      obj:ZuoQiLvUp(2)
    elseif id == CZBD_ITEM_3701 then
      obj:toPetView(3)
    elseif id == CZBD_ITEM_3801 then
      enterMarket({
        initItemType = MarketShow_InitShow_SilverView,
        initItemType = 92001,
        SilverAutoBuy = false
      })
    elseif id == CZBD_ITEM_3802 then
      obj:toPetView(4)
    elseif id == CZBD_ITEM_4001 then
      obj:GuanQiaView()
    elseif id == CZBD_ITEM_4002 then
      obj:TalkToAnShiZhuChiView(10003)
    elseif id == CZBD_ITEM_4003 then
      obj:ChangBaoTu()
    elseif id == CZBD_ITEM_4004 then
      obj:GotoNpc(90016)
    elseif id == CZBD_ITEM_4005 then
      obj:TalkToAnShiZhuChiView(activity.tianting.startNpc)
    elseif id == CZBD_ITEM_4006 then
      obj:BaoTuMission()
    elseif id == CZBD_ITEM_4007 then
      obj:BpPaoShang()
    elseif id == CZBD_ITEM_5001 then
      local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Huodong)
      print(" =========  ", openFlag, noOpenType, tips, OPEN_FUNC_Type_Gray)
      if openFlag == false then
        ShowNotifyTips(tips)
        return
      end
      local tempView = CHuodongShow.new({InitHuodongShow = HuodongShow_EventView})
      getCurSceneView():addSubView({
        subView = tempView,
        zOrder = MainUISceneZOrder.menuView
      })
    elseif id == CZBD_ITEM_5002 then
      obj:ChangBaoTu()
    elseif id == CZBD_ITEM_5004 then
      obj:BaoTuMission()
    elseif id == CZBD_ITEM_6001 then
      obj:BiWuView()
    elseif id == CZBD_ITEM_7001 then
      obj:OpenBangPaiViews(4)
    elseif id == CZBD_ITEM_8001 then
      obj:OpenBangPaiViews(3)
    elseif id == CZBD_ITEM_39101 then
      ShowNotifyTips("逢周日19:20-20:30开启天降宝箱活动")
    elseif id == CZBD_ITEM_39102 then
      g_MapMgr:AutoRouteToNpc(NPC_TianShuLaoRen_ID, function(isSucceed)
        if isSucceed and CMainUIScene.Ins then
          CMainUIScene.Ins:ShowNormalNpcViewById(NPC_TianShuLaoRen_ID)
        end
      end)
    elseif id == CZBD_ITEM_39201 then
      enterMarket({
        initItemType = MarketShow_InitShow_SilverView,
        initItemType = 93031,
        SilverAutoBuy = true
      })
    end
  end
  function obj:ZhuaGui()
    g_MissionMgr:TraceMission(ZhuaGui_MissionId)
    obj:removeFromParent()
  end
  function obj:BuyNeiDan()
    local tempView = PvpShopView.new()
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
    tempView:ShowPage(Shop_Honour_Nd_Page)
  end
  function obj:ChangBaoTu(pageNum)
    pageNum = pageNum or Shop_Honour_Tool_Page
    local itemId = g_LocalPlayer:GetOneItemIdByType(ITEM_DEF_OTHER_ZBT)
    print("YYYYYYYYYYYYYYYYYYYYY:", itemId)
    if itemId == nil or itemId <= 0 then
      local tempView = PvpShopView.new()
      getCurSceneView():addSubView({
        subView = tempView,
        zOrder = MainUISceneZOrder.menuView
      })
      scheduler.performWithDelayGlobal(function()
        local pageNum = Shop_Daoju_Page
        local itemId = ITEM_DEF_OTHER_ZBT
        local priceResType = RESTYPE_Honour
        local priceNum = data_ShopHonour2[ITEM_DEF_OTHER_ZBT].honour
        local player = g_LocalPlayer
        if priceNum > player:getHonour() then
          ShowNotifyTips("荣誉不足")
          return
        end
        CBuyNormalItemView.new(pageNum, itemId, RESTYPE_Honour, priceNum)
      end, 0.2)
      return
    end
    local player = g_DataMgr:getPlayer()
    local itemObj = player:GetOneItem(itemId)
    local mapId = itemObj:getProperty(ITME_PRO_ZBT_SCENE)
    local pos = itemObj:getProperty(ITME_PRO_ZBT_POS)
    local rIndex = itemObj:getProperty(ITEM_PRO_ZBT_RESULTINDEX)
    if mapId ~= 0 and mapId ~= nil and pos ~= nil and #pos >= 2 and rIndex ~= nil and rIndex ~= 0 then
      g_MapMgr:UseZBT(itemId, mapId, pos, rIndex)
    else
      netsend.netitem.requestUseItem(itemId)
    end
    obj:removeFromParent()
  end
  function obj:BaoTuMission()
    local npcId = data_Mission_Activity[DaTingCangBaoTu_MissionId].startNpc
    if CDaTingCangBaoTu.taskid == nil then
      g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
        if isSucceed and CMainUIScene.Ins then
          CDaTingCangBaoTu.requestBaoTuMission()
        end
      end)
    else
      CDaTingCangBaoTu.TraceMission()
    end
  end
  function obj:BpPaoShang()
    BangPaiPaoShang.GoToPaoShangNPC()
  end
  function obj:toPetView(index)
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Zhaohuanshou)
    if openFlag == false then
      if noOpenType == OPEN_FUNC_Type_Gray then
        ShowNotifyTips(tips)
      end
      return
    end
    local mainHero = g_LocalPlayer:getMainHero()
    local curPetId = mainHero:getProperty(PROPERTY_PETID)
    if index == 4 then
      getCurSceneView():addSubView({
        subView = CPetList.new(PetShow_InitShow_SkillLearnView, curPetId),
        zOrder = MainUISceneZOrder.menuView
      })
      return
    end
    local pv = CPetList.new()
    getCurSceneView():addSubView({
      subView = pv,
      zOrder = MainUISceneZOrder.menuView
    })
    if index == 3 then
      local petlist = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
      if #petlist ~= 0 then
        for k, v in pairs(petlist) do
          local curPet = g_LocalPlayer:getObjById(v)
          if curPet then
            local pclose = curPet:getProperty(PROPERTY_CLOSEVALUE)
            if pclose and pclose < CalculatePetCloseValueLimit() then
              pv:ChooseAndScrollToRoleWithIndex(k - 1)
              break
            end
          end
        end
      end
      pv:ShowAddClose()
      return
    end
    if curPetId ~= nil and curPetId > 0 then
      local petInfo = g_LocalPlayer:getObjById(curPetId)
      local ndList = {}
      local zbList = petInfo:getZhuangBei()
      for itemId, _ in pairs(zbList) do
        local itemIns = g_LocalPlayer:GetOneItem(itemId)
        if itemIns and itemIns:getType() == ITEM_LARGE_TYPE_NEIDAN then
          ndList[#ndList + 1] = itemIns
        end
      end
      table.sort(ndList, function(a, b)
        if a == nil or b == nil then
          return false
        end
        local zs_a = a:getProperty(ITEM_PRO_EQPT_ZSLIMIT)
        local zs_b = b:getProperty(ITEM_PRO_EQPT_ZSLIMIT)
        if zs_a ~= zs_b then
          return zs_a < zs_b
        else
          local lv_a = a:getProperty(ITEM_PRO_EQPT_LVLIMIT)
          local lv_b = b:getProperty(ITEM_PRO_EQPT_LVLIMIT)
          if lv_a ~= lv_b then
            return lv_a < lv_b
          else
            return a:getObjId() < b:getObjId()
          end
        end
      end)
      local fnd
      local maxlv = ndList[1]
      for k, v in pairs(ndList) do
        if v then
          local level = v:getProperty(ITEM_PRO_LV)
          local zs = v:getProperty(ITEM_PRO_NEIDAN_ZS)
          local levelLimit = CalculateNeidanLevelLimit(zs)
          print(" ==============  ", index, k, level, zs, levelLimit)
          if index == 2 then
            if level < levelLimit then
              fnd = v
              break
            end
          elseif index == 1 then
            if zs < CalculateNeidanZSLimit() and levelLimit == level then
              fnd = v
              break
            elseif level > maxlv:getProperty(ITEM_PRO_LV) then
              maxlv = v
            end
          end
        end
      end
      if index == 1 then
        if fnd == nil then
          fnd = maxlv
        end
        pv.m_PageItemList:ShowPackageDetail(fnd:getObjId(), true)
      elseif index == 2 and fnd and 0 < fnd:getObjId() then
        pv.m_PageItemList:ShowPackageDetail(fnd:getObjId(), true)
      end
    end
  end
  function obj:upgrateZhuangBei(action, hId)
    local itemId, item
    if hId == nil then
      item = obj:getParams(action)
    else
      item = obj:getParams(action, hId)
    end
    local heroObj
    if item then
      hId = item[1]
      itemId = item[2]
    end
    print(" ==== ", hId, item == nil)
    if hId == g_LocalPlayer:getMainHeroId() then
      heroObj = g_LocalPlayer:getMainHero()
    else
      heroObj = g_LocalPlayer:getObjById(hId)
    end
    if heroObj then
      if hId == g_LocalPlayer:getMainHeroId() then
        local tempView = CMainRoleView.new()
        getCurSceneView():addSubView({
          subView = tempView,
          zOrder = MainUISceneZOrder.menuView
        })
      else
        local tempView = CHuobanShow.new({viewNum = HuobanShow_ShowHuobanView, huobanID = hId})
        getCurSceneView():addSubView({
          subView = tempView,
          zOrder = MainUISceneZOrder.menuView
        })
        tempView.m_ShowHuobanView:ChooseItemByHeroId(hId)
        tempView.m_ShowHuobanView:ScrollToRole(hId)
      end
      if itemId then
        getCurSceneView():addSubView({
          subView = CZhuangbeiShow.new({
            InitItemId = itemId,
            InitRoleId = hId,
            InitUpgradeType = action
          }),
          zOrder = MainUISceneZOrder.menuView
        })
      end
    end
  end
  function obj:LianHua(hId)
    obj:upgrateZhuangBei(Eqpt_Upgrade_LianhuaType, hId)
  end
  function obj:QingHuaZhuangBei(hId)
    obj:upgrateZhuangBei(Eqpt_Upgrade_QianghuaType, hId)
  end
  function obj:ShengJiZhuangBei(hId)
    obj:upgrateZhuangBei(Eqpt_Upgrade_CreateType, hId)
  end
  function obj:getLianHuaItem(hid, mType)
    local heroObj = g_LocalPlayer:getObjById(hid)
    if heroObj then
      local itemId
      for g, tempPos in ipairs({
        ITEM_DEF_EQPT_POS_WUQI,
        ITEM_DEF_EQPT_POS_TOUKUI,
        ITEM_DEF_EQPT_POS_YIFU,
        ITEM_DEF_EQPT_POS_XIEZI,
        ITEM_DEF_EQPT_POS_XIANGLIAN,
        ITEM_DEF_EQPT_POS_YAODAI,
        ITEM_DEF_EQPT_POS_GUANJIAN,
        ITEM_DEF_EQPT_POS_CHIBANG,
        ITEM_DEF_EQPT_POS_MIANJU,
        ITEM_DEF_EQPT_POS_PIFENG
      }) do
        local itemObj = heroObj:GetEqptByPos(tempPos)
        if itemObj and itemObj:getType() ~= ITEM_LARGE_TYPE_HUOBANEQPT then
          if mType == Eqpt_Upgrade_LianhuaType then
            local noLianhua = true
            for _, para in ipairs(ITEM_PRO_SHOW_LIANHUA_DICT) do
              local proName = para[1]
              local tempNum = itemObj:getProperty(proName)
              if tempNum ~= 0 then
                noLianhua = false
                break
              end
            end
            if noLianhua == true then
              itemId = itemObj:getObjId()
              return itemId
            end
          elseif mType == Eqpt_Upgrade_CreateType then
            local largeType = itemObj:getType()
            local lv = itemObj:getProperty(ITEM_PRO_LV)
            local shape = itemObj:getTypeId()
            local nextShape = shape + 1
            local isNotMaxLvFlag = false
            if largeType == ITEM_LARGE_TYPE_SENIOREQPT then
              if lv < ITEM_LARGE_TYPE_SENIOREQPT_MaxLv then
                isNotMaxLvFlag = true
              end
            elseif largeType == ITEM_LARGE_TYPE_XIANQI and lv < ITEM_LARGE_TYPE_XIANQI_MaxLv then
              isNotMaxLvFlag = true
            end
            local lvFlag = false
            local zs = heroObj:getProperty(PROPERTY_ZHUANSHENG)
            local lv = heroObj:getProperty(PROPERTY_ROLELEVEL)
            local nextLv = data_getItemLvLimit(nextShape)
            local nextZs = data_getItemZsLimit(nextShape)
            if zs > nextZs or nextZs == zs and lv >= nextLv then
              lvFlag = true
            end
            if isNotMaxLvFlag and lvFlag then
              itemId = itemObj:getObjId()
              return itemId
            end
          elseif mType == Eqpt_Upgrade_QianghuaType then
            local isNeedQianghua = false
            local holeNum = itemObj:getProperty(ITME_PRO_EQPT_HOLENUM)
            local bsNum = itemObj:getProperty(ITME_PRO_EQPT_BAOSHINUM)
            if holeNum ~= nil and bsNum ~= nil and holeNum > bsNum then
              isNeedQianghua = true
            end
            if isNeedQianghua then
              itemId = itemObj:getObjId()
              return itemId
            end
          end
        end
      end
    end
    return nil
  end
  function obj:getParams(PType, hid)
    local result
    if hid == nil then
      local warsetting = g_LocalPlayer:getAllRoleIds(LOGICTYPE_HERO) or {}
      if #warsetting <= 0 then
        ShowNotifyTips("还没招募伙伴")
      end
      for index, pos in ipairs(warsetting) do
        local hId = pos
        if g_LocalPlayer:getMainHeroId() ~= hId then
          if result == nil then
            result = hId
          end
          local item = obj:getLianHuaItem(hId, PType)
          if item and hId then
            return {hId, item}
          end
        end
      end
    else
      local item = obj:getLianHuaItem(hid, PType)
      if item and hid then
        return {hid, item}
      end
    end
    hid = hid or result
    return {hid}
  end
  function obj:TalkToAnShiZhuChiView(npcId)
    print(" TalkToAnShiZhuChiView ==== ", npcId)
    if npcId == activity.dayanta.StartNpcId then
      activity.dayanta:GotoNpc()
    elseif npcId == activity.tianting.startNpc then
      activity.tianting:GotoNpc()
    elseif npcId == 10003 then
      Shimen.GotoShimenNpc()
    elseif npcId == 10006 then
      ZhuaGui.GotoNpc()
    end
    obj:removeFromParent()
  end
  function obj:ZuoQiView()
    local tempView = CZuoqiShow.new()
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
  end
  function obj:GuanQiaView(...)
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Guanqia)
    if openFlag == false then
      if noOpenType == OPEN_FUNC_Type_Gray then
        ShowNotifyTips(tips)
      end
      return
    end
    g_MapMgr:AutoRouteFB()
    obj:removeFromParent()
  end
  function obj:BiWuView(...)
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Biwu)
    if openFlag == false then
      if noOpenType == OPEN_FUNC_Type_Gray then
        ShowNotifyTips(tips)
      end
      return
    end
    ShowBattlePvpDlg()
  end
  function obj:HuoBanView(...)
    getCurSceneView():addSubView({
      subView = CHuobanShow.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  end
  function obj:GetHuobanView(...)
    getCurSceneView():addSubView({
      subView = CHuobanShow.new({viewNum = HuobanShow_GetHuobanView}),
      zOrder = MainUISceneZOrder.menuView
    })
  end
  function obj:CreateZhuangBeiView(tap)
    local tempView = CCreateZhuangbei.new()
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
    if tap == 1 then
      tempView:Btn_Gaoji()
    elseif tap == 2 then
      tempView:Btn_Xianqi()
    end
  end
  function obj:SkillView()
    getCurSceneView():addSubView({
      subView = CSkillShow.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  end
  function obj:ChongWuTJView(tag)
    local m_PuTongtag = tag
    local m_InitTujianPet = PetShow_InitShow_TuJianView
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Zhaohuanshou)
    if openFlag == false then
      if noOpenType == OPEN_FUNC_Type_Gray then
        ShowNotifyTips(tips)
      end
      return
    end
    local petType = 20020
    if m_PuTongtag then
      petType = 20003
    end
    local m_subView = CPetList.new(m_InitTujianPet, nil, nil, petType)
    getCurSceneView():addSubView({
      subView = m_subView,
      zOrder = MainUISceneZOrder.menuView
    })
  end
  function obj:LianyaoView(petShowView)
    local m_petShowView = petShowView
    local petIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
    if #petIds > 0 then
      local tempView = CPetList.new(m_petShowView, nil)
      getCurSceneView():addSubView({
        subView = tempView,
        zOrder = MainUISceneZOrder.menuView
      })
      if tempView.m_PageLianYaoList then
        tempView.m_PageLianYaoList:OnBtn_SelectLYS()
      end
    else
      ShowNotifyTips("没有召唤兽,无法使用")
    end
  end
  function obj:ZuoQiSkillView()
  end
  function obj:ZuoQiLvUp(item)
    local myZuoqiList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_ZUOQI)
    if myZuoqiList == nil or #myZuoqiList <= 0 then
      obj:ZuoQiView()
      return
    end
    local zqtid = ZUOQITYPE_BAIMA
    local maxindex = 0
    for k, zuoqiId in pairs(myZuoqiList) do
      local zqIns = g_LocalPlayer:getObjById(zuoqiId)
      if zqIns then
        if item == 2 then
          local lvstr = zqIns:getProperty(PROPERTY_ROLELEVEL)
          print("  ************* ", k, "  *** ", lvstr, CalculateZuoqiLevelLimit())
          if lvstr and lvstr < CalculateZuoqiLevelLimit() and maxindex < lvstr then
            zqtid = zqIns:getTypeId() or ZUOQITYPE_BAIMA
            maxindex = lvstr
          end
        elseif item == 1 then
          local isdianhua = zqIns:getProperty(PROPERTY_ZUOQI_DIANHUA) or 0
          local skillvlue = zqIns:getProperty(PROPERTY_ZUOQI_SKILLPVALUE) or 0
          local skilllimit = CalculateUpgradeZuoqiSkillPValueLimit(isdianhua)
          print("   ===================  ", k, zqIns:getTypeId(), skillvlue, skilllimit)
          if skillvlue < skilllimit and maxindex < skillvlue then
            maxindex = skillvlue
            zqtid = zqIns:getTypeId() or ZUOQITYPE_BAIMA
          end
        end
      end
    end
    local tempView = CZuoqiShow.new()
    getCurSceneView():addSubView({
      subView = tempView,
      zOrder = MainUISceneZOrder.menuView
    })
    tempView:SelectZuoqi(zqtid, false)
    if item == 1 then
      tempView:OnBtn_SkillView()
      tempView:setGroupBtnSelected(tempView.btn_skill)
    elseif item == 2 then
      tempView:OnBtn_UpgradeLv()
      tempView:setGroupBtnSelected(tempView.btn_uplv)
    end
  end
  function obj:Tisheng25Ji(npcId)
    if npcId then
      g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
        if isSucceed then
          getCurSceneView():addSubView({
            subView = ShopNPCView.new(npcId),
            zOrder = MainUISceneZOrder.menuView
          })
        end
      end)
    else
      return
    end
  end
  function obj:GotoNpc(npcId)
    if npcId then
      g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
        if isSucceed and CMainUIScene.Ins then
          CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
        end
      end)
    else
      return
    end
  end
  function obj:OpenBangPaiViews(index)
    if g_BpMgr:localPlayerHasBangPai() then
      if g_CBpInfoHandler == nil then
        local bpinfo = CBpInfo.new()
        getCurSceneView():addSubView({
          subView = bpinfo,
          zOrder = MainUISceneZOrder.menuView
        })
        if index == 4 then
          bpinfo:OnBtn_Page_Fuli()
          bpinfo:setGroupBtnSelected(bpinfo.btn_page_fuli)
        elseif index == 3 then
          bpinfo:OnBtn_Page_Huodong()
          bpinfo:setGroupBtnSelected(bpinfo.btn_page_huodong)
        elseif index == 2 then
          bpinfo:OnBtn_Page_Tuteng()
          bpinfo:setGroupBtnSelected(bpinfo.btn_page_tuteng)
        elseif index == 1 then
          bpinfo:OnBtn_Page_Base()
          bpinfo:setGroupBtnSelected(bpinfo.btn_page_base)
        end
      end
    else
      getCurSceneView():addSubView({
        subView = CBpJoinCreate.new(),
        zOrder = MainUISceneZOrder.menuView
      })
    end
  end
end
