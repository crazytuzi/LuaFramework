local npcfuncs = {
  [1016] = function()
    ShowZuoqiSkillDlg()
  end,
  [1017] = function()
    ShowZuoqiDianHuaDlg()
  end,
  [1020] = function()
    return activity.keju:Join(KejuType_1)
  end,
  [1021] = function()
    return activity.keju:Join(KejuType_2)
  end,
  [1022] = function()
    return activity.keju:Join(KejuType_3)
  end,
  [1023] = function()
    return activity.keju:ShowDianshiRank()
  end,
  [1025] = function()
    g_CurSceneView:addSubView({
      subView = DayataEntrance.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [1026] = function()
    print("NPC功能:我要换奖励")
    activity.dayanta:exchangeObj(1)
  end,
  [1027] = function()
    g_CurSceneView:addSubView({
      subView = CRebirthPetShow.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [1028] = function()
    print("NPC功能:高级碎片兑换召唤兽")
    activity.dayanta:exchangeObj(4)
  end,
  [1029] = function()
    print("NPC功能:中级碎片兑换召唤兽")
    activity.dayanta:exchangeObj(3)
  end,
  [1030] = function()
    print("NPC功能:低级碎片兑换召唤兽")
    activity.dayanta:exchangeObj(2)
  end,
  [1031] = function()
    Shimen.reqAccept()
  end,
  [1032] = function()
    Shimen.reqCommit()
  end,
  [1033] = function()
    activity.tianting:reqStart()
  end,
  [1034] = function(npcTypeId, npcId)
    activity.tianting:monsterOptionTouch(npcId)
  end,
  [1035] = function(npcTypeId, npcId)
    activity.tianting:monsterOptionTouch(npcId)
  end,
  [1036] = function(npcTypeId, npcId)
    activity.tianting:monsterOptionTouch(npcId)
  end,
  [1037] = function(npcTypeId, npcId)
    activity.tianting:monsterOptionTouch(npcId)
  end,
  [1039] = function(npcTypeId, npcId)
    getCurSceneView():addSubView({
      subView = ShopNPCView.new(npcId),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [1040] = function(npcTypeId, npcId)
    getCurSceneView():addSubView({
      subView = ShopNPCView.new(npcId),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [1041] = function(npcTypeId, npcId)
    getCurSceneView():addSubView({
      subView = ShopNPCView.new(npcId),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [1042] = function(npcTypeId, npcId)
    getCurSceneView():addSubView({
      subView = ShopNPCView.new(npcId),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [1044] = function(npcTypeId, npcId)
    SanJieLiLian.reqAccept()
  end,
  [1045] = function(npcTypeId, npcId)
    return BpTaskTokenDlg.RenWuLing_MuJi(1045)
  end,
  [1046] = function(npcTypeId, npcId)
    return BpTaskTokenDlg.RenWuLing_AnZhan(1046)
  end,
  [1047] = function(npcTypeId, npcId)
    return BpTaskTokenDlg.RenWuLing_ChuMo(1047)
  end,
  [1048] = function(npcTypeId, npcId)
    return BpTaskTokenDlg.RenWuLing_TuiWeiRangXian(1048)
  end,
  [1050] = function(npcTypeId, npcId)
    getCurSceneView():addSubView({
      subView = CMakeTeam.new(1),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [1051] = function(npcTypeId, npcId)
    getCurSceneView():addSubView({
      subView = CMakeTeam.new(3),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [1052] = function(npcTypeId, npcId)
    getCurSceneView():addSubView({
      subView = CMakeTeam.new(4),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [1073] = function(npcTypeId, npcId)
    getCurSceneView():addSubView({
      subView = CMakeTeam.new(5),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [1054] = function(npcTypeId, npcId)
    getCurSceneView():addSubView({
      subView = CMakeTeam.new(2),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [1055] = function(npcTypeId, npcId)
    getCurSceneView():addSubView({
      subView = ChangeColorView.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [1056] = function(npcTypeId, npcId)
    return RequestBangPaiWarSignUp()
  end,
  [1057] = function(npcTypeId, npcId)
    BangPaiChuMo.getChuMoMission(true)
  end,
  [1058] = function(npcTypeId, npcId)
    BangPaiChuMo.reqCommit()
  end,
  [1059] = function(npcTypeId, npcId)
    return BangPaiPaoShang.reqAccept()
  end,
  [1060] = function(npcTypeId, npcId)
    return BangPaiPaoShang.MissionCommit(npcId)
  end,
  [1061] = function(npcTypeId, npcId)
    return BangPaiPaoShang.ShowTalk(701612, Business_MissionId)
  end,
  [1062] = function(npcTypeId, npcId)
    return BangPaiPaoShang.PoPView(1, npcId)
  end,
  [1063] = function(npcTypeId, npcId)
    return BangPaiPaoShang.PoPView(2, npcId)
  end,
  [1064] = function(npcTypeId, npcId)
    return BangPaiPaoShang.PoPView(3, npcId)
  end,
  [1065] = function(npcTypeId, npcId)
    BangPaiAnZhan.getAnZhanMission()
  end,
  [1066] = function(npcTypeId, npcId)
    BangPaiAnZhan.reqCommit()
  end,
  [1067] = function(npcTypeId, npcId)
    ShowSelectListOfAllSS()
  end,
  [1068] = function(npcTypeId, npcId)
    ShowLearSSSkillRequire(npcId)
    return false
  end,
  [1069] = function(npcTypeId, npcId)
    ShowChangeLifeSkill()
    return false
  end,
  [1070] = function(npcTypeId, npcId)
    AwardPrompt.addPrompt("已经接受了这个任务")
    return false
  end,
  [1071] = function(npcTypeId, npcId)
    ShowTTHJView()
  end,
  [1072] = function(npcTypeId, npcId)
    getCurSceneView():addSubView({
      subView = CMakeTeam.new(8),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [1053] = function(npcTypeId, npcId)
    ShowLeiWangZhengBaDlg()
  end,
  [1074] = function(npcTypeId, npcId)
    enterMarket({
      initViewType = MarketShow_InitShow_CoinView,
      initBaitanType = BaitanShow_InitShow_ShoppingView,
      initBaitanMainType = 1,
      initBaitanSubType = 1
    })
  end,
  [1075] = function(npcTypeId, npcId)
    ShowLeaveWordBoard()
  end,
  [1076] = function(npcTypeId, npcId)
    if CDaTingCangBaoTu.taskid == nil then
      CDaTingCangBaoTu.requestBaoTuMission()
    else
      ShowNotifyTips("你身上已有宝图任务")
    end
  end,
  [1077] = function(npcTypeId, npcId)
    SanJieLiLian.reqReSet()
  end,
  [1078] = function(npcTypeId, npcId)
    netsend.netitem.requestGetGJCangBaoTu()
  end,
  [1079] = function(npcTypeId, npcId)
    activity.tbsj:ReqAcceptTBSJ()
  end,
  [1080] = function(npcTypeId, npcId)
    getCurSceneView():addSubView({
      subView = CMakeTeam.new(12),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [1081] = function(npcTypeId, npcId)
    netsend.netactivity.joinYZDD()
  end,
  [1082] = function(npcTypeId, npcId)
    gift.festival:CheckFestivalGift()
  end,
  [1083] = function(npcTypeId, npcId)
    netsend.netteamwar.requestDuanWuWar()
  end,
  [1084] = function(npcTypeId, npcId)
    netsend.netteam.requestBangPaiHelp(5)
  end,
  [1085] = function(npcTypeId, npcId)
    netsend.netteam.requestBangPaiHelp(4)
  end,
  [1086] = function(npcTypeId, npcId)
    ShowChangeZSXZ()
  end,
  [1087] = function(npcTypeId, npcId)
    ShowChangeWXPro()
  end,
  [1088] = function(npcTypeId, npcId)
    getLingShouByLSZY()
  end,
  [1089] = function(npcTypeId, npcId)
    netsend.netactivity.enterXZSC()
  end,
  [1090] = function(npcTypeId, npcId)
    netsend.netbangpai.requestRejectBpLeader()
  end,
  [1091] = function(npcTypeId, npcId)
    getCurSceneView():addSubView({
      subView = CDuelRule.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [1092] = function(npcTypeId, npcId)
    netsend.netactivity.enterDuelScene()
  end,
  [1093] = function(npcTypeId, npcId)
    netsend.netactivity.requestDuel()
  end,
  [1095] = function(npcTypeId, npcId)
    g_DuleMgr:QuitDuleMap()
  end,
  [1096] = function(npcTypeId, npcId)
    ShowEquipHuiLu()
  end,
  [1097] = function(npcTypeId, npcId)
    print("npcFunc:我要结婚")
    g_HunyinMgr:touchNpcOption_Jiehun()
  end,
  [1098] = function(npcTypeId, npcId)
    print("npcFunc:我要结契")
    if g_JieqiMgr then
      g_JieqiMgr:touchNpcOption_Jieqi()
    end
  end,
  [1099] = function(npcTypeId, npcId)
    print("npcFunc:我要离婚")
    g_HunyinMgr:touchNpcOption_Lihun()
  end,
  [1100] = function(npcTypeId, npcId)
    print("npcFunc:解除结契")
    g_HunyinMgr:touchNpcOption_Jiechujieqi()
  end,
  [1101] = function(npcTypeId, npcId)
    print("npcFunc:答题考验")
    netsend.netmarry.requestDati()
  end,
  [1102] = function(npcTypeId, npcId)
    print("npcFunc:查看姻缘树")
    openMarryTreeView()
  end,
  [1103] = function(npcTypeId, npcId)
    print("npcFunc:举办婚宴")
    if g_HunyinMgr then
      g_HunyinMgr:touchNpcOption_Hunyan()
    end
  end,
  [1104] = function(npcTypeId, npcId)
    print("npcFunc:留言墙")
    ShowZhaoQinLeaveWordBoard()
  end,
  [1105] = function(npcTypeId, npcId)
    print("npcFunc:仙器转换")
    ShowEquipZhuanHuan()
  end,
  [1107] = function(npcTypeId, npcId)
    print("查看修罗次数")
    XiuLuo.resetTalkId()
    getCurSceneView():ShowTalkView(700151, nil, XiuLuo_MissionId)
  end,
  [1108] = function(npcTypeId, npcId)
    ShowChange6ZuoqiView()
  end,
  [1109] = function(npcTypeId, npcId)
    ShowChangeRaceView()
  end,
  [1110] = function(npcTypeId, npcId)
    print("修罗寻找队伍")
    getCurSceneView():addSubView({
      subView = CMakeTeam.new(16),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [1111] = function(npcTypeId, npcId)
    activity.tjbx:exchangeSilverBox()
  end,
  [1112] = function(npcTypeId, npcId)
    print("进入天地奇书地图界面")
    activity.tiandiqishu:requestToStart()
  end,
  [1113] = function(npcTypeId, npcId)
    print("天地奇书寻找队伍")
    getCurSceneView():addSubView({
      subView = CMakeTeam.new(17),
      zOrder = MainUISceneZOrder.menuView
    })
  end,
  [1114] = function(npcTypeId, npcId)
    print("打开乾坤一掷界面")
    ShowQianKunYiZhiView()
  end,
  [1115] = function(npcTypeId, npcId)
    print("保护嫦娥")
    netsend.netteamwar.startProtectChangE()
  end,
  [1116] = function(npcTypeId, npcId)
    print("兑换25万元宝")
    netsend.netactivity.changeGuoQingJSCJ(1)
    return false
  end,
  [1117] = function(npcTypeId, npcId)
    print("兑换800w经验")
    netsend.netactivity.changeGuoQingJSCJ(2)
    return false
  end,
  [1118] = function(npcTypeId, npcId)
    print("兑换奖券X3")
    netsend.netactivity.changeGuoQingJSCJ(3)
    return false
  end,
  [1121] = function(npcTypeId, npcId)
    print("兑换顶级宠物蛋x1")
    netsend.netactivity.changeGuoQingJSCJ(4)
    return false
  end,
  [1122] = function(npcTypeId, npcId)
    print("兑换顶级宠物蛋x1")
    netsend.netactivity.changeGuoQingJSCJ(5)
    return false
  end,
  [1123] = function(npcTypeId, npcId)
    print("兑换顶级宠物蛋x1")
    netsend.netactivity.changeGuoQingJSCJ(6)
    return false
  end,
  [1124] = function(npcTypeId, npcId)
    print("兑换顶级宠物蛋x1")
    netsend.netactivity.changeGuoQingJSCJ(7)
    return false
  end,
  [1125] = function(npcTypeId, npcId)
    print("兑换顶级宠物蛋x1")
    netsend.netactivity.changeGuoQingJSCJ(8)
    return false
  end,
  [1126] = function(npcTypeId, npcId)
    print("兑换顶级宠物蛋x1")
    netsend.netactivity.changeGuoQingJSCJ(9)
    return false
  end,
  [1127] = function(npcTypeId, npcId)
    print("兑换顶级宠物蛋x1")
    netsend.netactivity.changeGuoQingJSCJ(10)
    return false
  end,
  [1128] = function(npcTypeId, npcId)
    print("兑换顶级宠物蛋x1")
    netsend.netactivity.changeGuoQingJSCJ(11)
    return false
  end,
  [1129] = function(npcTypeId, npcId)
    print("兑换顶级宠物蛋x1")
    netsend.netactivity.changeGuoQingJSCJ(12)
    return false
  end,
  [1130] = function(npcTypeId, npcId)
    print("兑换顶级宠物蛋x1")
    netsend.netactivity.changeGuoQingJSCJ(13)
    return false
  end,
  [1131] = function(npcTypeId, npcId)
    print("兑换顶级宠物蛋x1")
    netsend.netactivity.changeGuoQingJSCJ(14)
    return false
  end,
  [1132] = function(npcTypeId, npcId)
    print("兑换顶级宠物蛋x1")
    netsend.netactivity.changeGuoQingJSCJ(15)
    return false
  end,
  [1133] = function(npcTypeId, npcId)
    print("兑换顶级宠物蛋x1")
    netsend.netactivity.changeGuoQingJSCJ(16)
    return false
  end,
  [1119] = function(npcTypeId, npcId)
    print("兑换重阳糕")
    netsend.netactivity.changeChongYangItem(1)
    return false
  end,
  [1120] = function(npcTypeId, npcId)
    print("兑换菊花酒")
    netsend.netactivity.changeChongYangItem(2)
    return false
  end
}
function NpcFuncStart(npcTypeId, npcId)
  local npcfunc = npcfuncs[npcTypeId]
  local t = type(npcfunc)
  local closeFlag = true
  if npcfunc == nil then
    printLog("ERROR", "NPC功能还没有实现[%d]", npcTypeId)
  elseif t == "function" then
    if npcfunc(npcTypeId, npcId) == false then
      closeFlag = false
    end
  elseif CMainUIScene.Ins then
    CMainUIScene.Ins:ShowNpcViewByClass(npcfunc, npcTypeId, npcId)
  end
  return closeFlag
end
