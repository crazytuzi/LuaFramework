CmdType = { };

CmdType.Login_Game = 0x0101;
CmdType.Create_Role = 0x0102;
CmdType.Get_Role_Name = 0x0103;
CmdType.In_Game = 0x0105;
CmdType.Get_MinorData = 0x0106 -- 获取次要数据
CmdType.Exit_Game = 0x0107
CmdType.GetServerTime = 0x0108
CmdType.InterBreak = 0x0109
CmdType.HeartBeat = 0x010A;

CmdType.OtRec = 0x010B;

CmdType.Money_Change = 0x0201;
CmdType.OtherInfoChange = 0x0202
CmdType.RevChatMessage = 0x0204
CmdType.SendPrivChatMessage = 0x0209

CmdType.GetPrivChatMsgData = 0x020A -- 获取私有频道 离线数据
CmdType.Message_Marquee = 0x020C;
CmdType.Message_Notice = 0x020D;
CmdType.Message_Tips = 0x020E;
CmdType.Message_Props = 0x020F;
CmdType.Message_Trumpet = 0x0212;

CmdType.DressChange = 0x0401
CmdType.ProductChange = 0x0402;
CmdType.Use_Product = 0x0403;
CmdType.Move_Product = 0x0404;
CmdType.Sell_Product = 0x0405;
CmdType.Reset_BackPack = 0x0406;
CmdType.UnLockBackPack = 0x0407;
CmdType.DropItem = 0x0408
CmdType.EquipStrong = 0x0409
CmdType.EquipRefine = 0x040A
CmdType.GemComp = 0x040B
CmdType.GemAllComp = 0x040C
CmdType.GemEmbed = 0x040D
CmdType.GemPick = 0x040E
CmdType.GemPunch = 0x040F
CmdType.GemShengji = 0x0410
CmdType.SQCompose = 0x0411 -- 11 装备部位套装变化通知(服务器发出)
CmdType.SQUpStar = 0x0412 -- 12 套装升级
CmdType.SQZY = 0x0413
CmdType.SQGetSuitLvData = 0x0414
CmdType.SQSuitLvDataChange = 0x0415
CmdType.TryComLingYao = 0x0416   -- 灵药合成
CmdType.GetBoxProducts = 0x0417
CmdType.TrumpRefineZoneChange = 0x0420
CmdType.TrumpGet = 0x0421
CmdType.TrumpOneKeyCollect = 0x0422
CmdType.TrumpFunsion = 0x0423
CmdType.TrumpOnekKeyFunsion = 0x0424
CmdType.TrumpOnDress = 0x0425
CmdType.TrumpUnDress = 0x0426
CmdType.TrumpRefine = 0x0427
CmdType.ItemCompose = 0x0428
CmdType.NewEquipStrong = 0x0429



CmdType.ExpOrLevelChange = 0x0501
CmdType.UnLockSkill = 0x0502
CmdType.SkillUp = 0x0503
CmdType.RealmUpgrade = 0x0504;
CmdType.RealmCompact = 0x0505;
CmdType.SkillSetting = 0x060D;
CmdType.SkillTalent = 0x0506;
CmdType.GetTitle = 0x0507;
CmdType.LostTitle = 0x0508;
CmdType.ChangeTitle = 0x0509;
CmdType.ActiveTalent = 0x0510;
CmdType.GetSimplePlayerInfo = 0x050A;
CmdType.GetOtherInfo = 0x050B;
CmdType.GetOtherPetInfo = 0x050C;
CmdType.GetOtherTeamPetInfo = 0x050D;
CmdType.GetOtherSkillInfo = 0x050E;
CmdType.GetOtherFightInfo = 0x050F;
CmdType.RoleRealmChange = 0x0511;
CmdType.ChooseRealmSkill = 0x0512;
CmdType.TalentPointChg = 0x0513;
CmdType.ChooseTheurgy = 0x0514;
CmdType.ChangeRoleName = 0x0515;
CmdType.LotBuyExp = 0x0516;
CmdType.GetLotInfo = 0x0517;
CmdType.WorldLevel = 0x0518;
CmdType.LotBuyMoney = 0x0519;
CmdType.GetLotMoneyInfo = 0x0520;

CmdType.CheckScene = 0x0301;
CmdType.GotoScene = 0x0302;
CmdType.EnterScene = 0x0303;
CmdType.RoleInView = 0x0304;
CmdType.RoleOutView = 0x0305;
CmdType.RoleMoveByPath = 0x0306;
CmdType.RoleMoveByAngle = 0x0307;
CmdType.RoleMoveEnd = 0x0308;
CmdType.PositionProof = 0x0309;
CmdType.InstanceMapResult = 0x030A;
CmdType.InstanceMapInfo = 0x030B;
CmdType.GetOldSceneInfo = 0x030C;
CmdType.TransLateInScene = 0x030D;
CmdType.SceneObstaclChange = 0x030E;
CmdType.GetLastSceneId = 0x030F;
CmdType.GetSceneLines = 0x0310;
CmdType.GetSceneLine = 0x0311;
CmdType.SceneLineChange = 0x0312;
CmdType.GetRolePosInfo = 0x0313;

CmdType.LdAskGenShui = 0x0314;
CmdType.RecLdAskGenShui = 0x0315;
CmdType.AnswerLdAskGenShui = 0x0316;
CmdType.LdRecAskGenShui = 0x0317;
CmdType.LdCancelGenShui = 0x0318;
CmdType.RecLdCancelGenShui = 0x0319;
CmdType.GenShuiMbChange = 0x031A;
CmdType.SendLineMovePre = 0x031B;
CmdType.RoleDisapear = 0x031C;
CmdType.EnterExitMirror = 0x031D;
CmdType.GuildMsg = 0x031E;
CmdType.CheckLine = 0x031F;

CmdType.ScenePropChange = 0x0320;--20 场景更新物件（服务端发出）
CmdType.SceneNotice = 0x0321;--20 场景说话通知（服务端发出）¶
CmdType.RedirectScene = 0x0322;
CmdType.PetChangeBody = 0x0323;
CmdType.GetSceneProps = 0x0330;--获取所有宝箱
CmdType.ScenePropChange = 0x0331;--宝箱点状态改变(服务端发出)
CmdType.HoldSceneProp = 0x0332;--占领资源

CmdType.MPChange = 0x0601;
CmdType.SkillHurt = 0x0602;
CmdType.CastSkill = 0x0603;
CmdType.AddBuff = 0x0604;
CmdType.RemoveBuff = 0x0605;
CmdType.ChoosePkType = 0x0606;
CmdType.ChangePkData = 0x0607;
CmdType.PlayerDie = 0x0608
CmdType.PlayerRelive = 0x0609
CmdType.PlayAppearAnimation = 0x060A
CmdType.ExtraSkillEffect = 0x060E;
CmdType.TargetOwnership = 0x060F;
CmdType.TargetMiss = 0x0610;
CmdType.DisplayPkData = 0x0611;
CmdType.HeroAbsorption = 0x0612;
CmdType.SkillCdChange = 0x0613;
CmdType.BossAffiliationChange = 0x0614;
CmdType.HeroAutoFightState = 0x0615;
CmdType.RecAutoFightExp = 0x0616;

CmdType.UseMount = 0x0701;
CmdType.UnUseMount = 0x0702;


CmdType.AddPet = 0x0801
CmdType.CombinePet = 0x0802
CmdType.MotifyPetName = 0x0803
CmdType.UpdatePetSkill = 0x0805
CmdType.SetPetStatus = 0x0806
CmdType.EquipPetSkill = 0x0807
CmdType.PetUpdateLevel = 0x0808
CmdType.PetAdvance = 0x0809
CmdType.RandomName = 0x080A
CmdType.RandomAptitude = 0x080B
CmdType.SaveAptitude = 0x080C
CmdType.PetExplain = 0x080D
CmdType.AddPetSkill = 0x080E
CmdType.PetAddFormation = 0x080F
CmdType.PetDeFormation = 0x0810
CmdType.RandomAptitudeNew = 0x0811 --新资质洗练
CmdType.RandomAptitudeOneKey = 0x0812 --一键洗练
CmdType.SendActiveSkill = 0x0813 --一键洗练


CmdType.GetPet = 0x0814
CmdType.UpdatePetLevel = 0x0815
CmdType.UpdatePetRank = 0x0816
CmdType.ActivePetBody = 0x0817 --激活形象
CmdType.UpdatePetBody = 0x0818 --升级形象
CmdType.ChangePetBody = 0x0819 --切换形象






CmdType.Mail_New = 0x0A01;
CmdType.Mail_List = 0x0A02;
CmdType.Mail_Read = 0x0A03;
CmdType.Mail_Pick = 0x0A04;
CmdType.Mail_Del = 0x0A05;
CmdType.Mail_AllPick = 0x0A06;
CmdType.Mail_AllDel = 0x0A07;

CmdType.Task_List = 0x0D01;
CmdType.Task_Get = 0x0D02;
CmdType.Task_Update = 0x0D03;
CmdType.Task_Trigger = 0x0D04;
CmdType.Task_End = 0x0D05;
CmdType.Task_Daily_Acc = 0x0D06;
CmdType.Task_Complete = 0x0D07;
CmdType.Task_Monster = 0x0D08;
CmdType.Task_Reward_BuyTime = 0x0D09;
CmdType.Task_Reward_Refresh = 0x0D0A;
CmdType.Task_Cancel = 0x0D0B;
CmdType.Task_Escort = 0x0D0C;
CmdType.Task_Escort_Fail = 0x0D0D;
CmdType.Task_Escort_Trigger = 0x0D0E;
CmdType.Task_Help_List = 0x0D0F;
CmdType.Task_Need_Help = 0x0D10;
CmdType.Task_Do_CollectItem = 0x0D11;
CmdType.Task_Help_CollectItem = 0x0D12;
CmdType.Task_Gold_Refresh = 0x0D13;


CmdType.RideActivate = 0x0901
CmdType.RideExpired = 0x0902
CmdType.UseRide = 0x0903
CmdType.GetOnRide = 0x0904
CmdType.GetDownRide = 0x0905
CmdType.CancleRide = 0x0906
CmdType.RideBecomeExpired = 0x0907--到期前一分钟通知
CmdType.RideRenewal = 0x0908 --坐骑续费
CmdType.RideFeed = 0x0909 --坐骑续费
CmdType.RideFeedOneKey = 0x090A --坐骑续费

CmdType.CreateArmy = 0x0B01
CmdType.JoinTeamAsk = 0x0B02
CmdType.AskForJointParty = 0x0B03
CmdType.AskForJointPartyResult = 0x0B04
CmdType.AddToParty = 0x0B05
CmdType.LeaveTeam = 0x0B06
CmdType.GetOutFromTeam = 0x0B07
CmdType.UpToTeamLeader = 0x0B08
CmdType.PartSetCfData = 0x0B09
CmdType.InviteToTeam = 0x0B0A
CmdType.InvToGroudS = 0x0B0B
CmdType.NearTeam = 0x0B0C
CmdType.AccJoinTeam = 0x0B0D
CmdType.GetPartyDress = 0x0B0E
CmdType.DismissTeam = 0x0B0F
CmdType.PartCfData = 0x0B10
CmdType.ResultForTeamLeaderAsk = 0x0B11
CmdType.ResultForPlayerAsk = 0x0B12
CmdType.AskForStarTeamFB = 0x0B13
CmdType.AskForStarTeamFBAcc = 0x0B14
CmdType.AskForStarTeamFBRec = 0x0B15
CmdType.CanStarTeamFB = 0x0B16
CmdType.GetTeamFBData = 0x0B17
CmdType.TeamDataChange = 0x0B18
CmdType.TeamDataOnlineChange = 0x0B19
CmdType.SendLaderGotoScene = 0x0B1A
CmdType.GetNearPlayers = 0x0B1B
CmdType.GetApplyTearmList = 0x0B1C
CmdType.CleanApplyTearmList = 0x0B1D
CmdType.TreamNumberSceneChange = 0x0B22
CmdType.TreamCancleToFb = 0x0B23

CmdType.GetFirstWing = 0x0C01
CmdType.UseWing = 0x0C02
CmdType.CancleWing = 0x0C03
CmdType.UpdateWing = 0x0C04
CmdType.ActiveWing = 0x0C05
CmdType.RenewWing = 0x0C06
CmdType.WingTimeEnd = 0x0C07



CmdType.GetPVPPlayer = 0x0E01
CmdType.PVPFight = 0x0E02
CmdType.GetPVPRank = 0x0E04
CmdType.SelfPVPRankChange = 0x0E05
CmdType.BuyPVPTime = 0x0E08

-- CmdType.SelfPVPPointChange = 0x0E07

CmdType.GetFB_instReds = 0x0F01
CmdType.GetFB_ElseTime = 0x0F02
CmdType.TryStarTeamFB = 0x0F03
CmdType.TryStarTeamFBErr = 0x0F04
CmdType.FoceOutOfTeamFB = 0x0F05
CmdType.GetTeamFBID = 0x0F07
CmdType.Saodang = 0x0F0B
CmdType.YiJianSaodang = 0x0F09
CmdType.ResetInstanteTime = 0x0F0A

CmdType.GetGBoxInfos = 0x0F0C
CmdType.GetGBoxProducts = 0x0F0D
CmdType.TryGetChuangGuanAward = 0x0F0E
CmdType.GetChuangGuanAwardLog = 0x0F0F

CmdType.TryXLTSaoDang = 0x0F10
CmdType.TryGetXLTSaoDangAwards = 0x0F11
CmdType.GetXLTSaoDangInfo = 0x0F13
CmdType.GetXLTSaoDangProsInfo = 0x0F14
CmdType.XLTReSetSaoDangTime = 0x0F15
CmdType.XLTReSetTiaoZhanTime = 0x0F16
CmdType.HireList = 0x0F17
CmdType.HirePlayer = 0x0F18
CmdType.EndlessTryBuy = 0x0F20
CmdType.EndlessTryInfo = 0x0F21
CmdType.EndlessTryTeamInfo = 0x0F22

CmdType.TryGetFBStar = 0x0F23 --
CmdType.UseProudctBuff = 0x0F24 --

CmdType.GetTShopData = 0x1002
CmdType.TShopExchange = 0x1003

CmdType.TestGetPet = 0xFF03
CmdType.TestGetSkill = 0xFF04

CmdType.GmCmd = 0xFF07
CmdType.ProtocolTest = 0xFF08



CmdType.LoadAutoFightConfig = 0x060B
CmdType.SaveAutoFightConfig = 0x060C

CmdType.SendLottery = 0x1101
CmdType.GetLotteryInfo = 0x1102
CmdType.AchievementChange = 0x1103
CmdType.GetAchievementReward = 0x1104
CmdType.GetActivityData = 0x1105
CmdType.ActivityDataChange = 0x1106
CmdType.GetActivityAv = 0x1107
CmdType.PlotProgress = 0x1108
CmdType.VipChange = 0x1109
CmdType.OffLineChg = 0x1114
CmdType.GetLotteryRecorder = 0x111B



CmdType.VipBuy = 0x110A
CmdType.GetFirstRechargeAward = 0x110B
CmdType.SaveGuide = 0x110C
CmdType.GiftCode = 0x110D
CmdType.APP_DOWN_STATE = 0x110E
CmdType.APP_DOWN_GET_AWARD = 0x110F
CmdType.DRAMA_CREATE_ROLE = 0x1110
CmdType.DRAMA_DELETE_ROLE = 0x1111
CmdType.DRAMA_CREATE_TRUMP = 0x1112
CmdType.GetVipDailyAward = 0x1113

CmdType.GetGuildHongBaoData = 0x1115
CmdType.SendHongBao = 0x1116
CmdType.ShowHongBao = 0x1117
CmdType.HongBaoNotify = 0x1118
CmdType.PayToDoTask = 0x111A

CmdType.AddFriend = 0x1201
CmdType.GetMyFriendsList = 0x1202
CmdType.RemoveFriend = 0x1203
CmdType.GetTJFriendList = 0x1204
CmdType.FindFriend = 0x1205
CmdType.GetPlayerInfo = 0x1206
CmdType.RecBeAddFriend = 0x1207
CmdType.RecOnlineTz = 0x1208
CmdType.AddFriends = 0x1209

CmdType.Guild_Create = 0x1301;
CmdType.Guild_Join = 0x1302;
CmdType.Guild_Verify = 0x1304;
CmdType.Guild_Verify_List = 0x1307;
CmdType.Guild_Kick = 0x1308;
CmdType.Guild_List = 0x1310;
CmdType.Guild_Find = 0x1311;
CmdType.Guild_SetIdentity = 0x1312;
CmdType.Guild_Member = 0x1315;
CmdType.Guild_Verify_Set = 0x1316;
CmdType.Guild_LogList = 0x1317;
CmdType.Guild_Verify_AllRefuse = 0x1318;
CmdType.Guild_SetEnemy = 0x1314;
CmdType.Guild_GetEnemyList = 0x1319;
CmdType.Guild_CancelEnemy = 0x1320;
CmdType.Guild_MoBaiInfo = 0x1322;			-- 膜拜
CmdType.Guild_MoBaiOpt = 0x1323;
CmdType.Guild_MoBaiActive = 0x1324;
CmdType.Guild_Task_MoBaiNum = 0x1325;
CmdType.Guild_Task_GetNum = 0x1326;
CmdType.Guild_Send_Join_Notice = 0x132A;
CmdType.GUild_Get_TuoJi_Exp = 0x132B;
CmdType.Guild_Invite = 0x130A;
CmdType.Guild_AnsInvite = 0x130C;
CmdType.Guild_Juanxian = 0x130E;
CmdType.Guild_Quit = 0x131A;
CmdType.Guild_Dissolve = 0x131B;
CmdType.Guild_SetNotice = 0x131D;
CmdType.Guild_Info = 0x131E;
CmdType.Guild_Act_Info = 0x1327;
CmdType.GUild_Get_junxian_logs = 0x1329;
CmdType.GUild_Get_junxian_logs = 0x132B;
CmdType.Guild_Research_Skill = 0x1340;
CmdType.Guild_Learn_Skill = 0x1341;
CmdType.Guild_Get_Salary = 0x1343;
CmdType.Guild_Get_Salary_Status = 0x1344;

CmdType.Guild_Notify_NewReqJoin = 0x1303;
CmdType.Guild_Notify_NewMember = 0x1305;
CmdType.Guild_Notify_InGuild = 0x1306;
CmdType.Guild_Notify_OutGuild = 0x1309;
CmdType.Guild_Notify_Identity_Chg = 0x1313;
CmdType.Guild_Notify_Dissolve = 0x131B;
CmdType.Guild_Notify_BeRefuseJoin = 0x131C;
CmdType.Guild_Notify_GuildLevelUp = 0x1321;
CmdType.Guild_Notify_MyGuildInfo = 0x1328;
CmdType.Guild_Notify_BeInvite = 0x130B;
CmdType.Guild_Notify_InfoUpdate = 0x1342;


CmdType.Rank_List_Fight = 0x1501;
CmdType.Rank_List_Level = 0x1502;
CmdType.Rank_List_Gold = 0x1503;
CmdType.Rank_List_Money = 0x1504;
CmdType.Rank_List_Pet = 0x1505;
CmdType.Rank_List_Realm = 0x1506;
CmdType.Rank_List_Wing = 0x1507;
CmdType.Rank_List_GuildFight = 0x1508;
CmdType.Rank_List_GuildRank = 0x1509;
CmdType.Rank_List_Xuling = 0x150A;
CmdType.Rank_List_AutoFight = 0x150B;

CmdType.Rank_Item_Info = 0x1530;
CmdType.Rank_Send_Flower = 0x1531;
CmdType.DaysRank_List = 0x1540;
CmdType.DaysRank_Award = 0x1541;

CmdType.TryJoinYaoyuan = 0x1401;
CmdType.OpenPanelForYaoyuan = 0x1402;
CmdType.TryZhongzhi = 0x1403;
CmdType.TryGetXianMenNumberInfo = 0x1404;
CmdType.TryYaoYuanJiaoShui = 0x1405;
CmdType.TryHarvest = 0x1406;
CmdType.TryHarvestAll = 0x1407;

CmdType.TryInviteForShouHu = 0x1409;
CmdType.TryRecForShouHu = 0x140A;
CmdType.AcceptForShouHu = 0x140B;
CmdType.RecAcceptForShouHu = 0x140C;

CmdType.TryGetMyXianMenNembers = 0x140D;
CmdType.TryGetDiDuiXianMenNembers = 0x140E;
CmdType.TryGetXianMenLog = 0x140F;
CmdType.TryJiaoShuiAll = 0x1410;
CmdType.TrytouQu = 0x1411;
CmdType.TryTouQuAll = 0x1408;
CmdType.TryCleanAllYaoYuanLog = 0x1412;
CmdType.TryGetYaoYuanJs_Ty_time = 0x1413;
CmdType.MyYaoYuanLevelChange = 0x1414;
CmdType.MyYaoYuanDataChange = 0x1415;
CmdType.YijianChengshu = 0x1416;

CmdType.Chat_ReceiveMsg = 0x0204-- 收到消息
CmdType.Chat_SendWorld = 0x0206-- 发送世界消息
CmdType.Chat_SendSchool = 0x0207-- 发送帮会消息
CmdType.Chat_SendTeam = 0x0208-- 发送队伍消息
CmdType.Chat_SendPrivate = 0x0209-- 发送私人消息
CmdType.Chat_HistroyMsg = 0x020A-- 获取离线信息
CmdType.Chat_SendActive = 0x020B-- 活动频道发言
CmdType.Opera_Log = 0x0210-- 操作日志
CmdType.Daily_Num_Chg = 0x0211



CmdType.GetXMBossMainInfos = 0x1601;
CmdType.GetXMBossRank = 0x1602;
CmdType.GetXMBossJoinInfos = 0x1603;
CmdType.TryMXBossZaoHuang = 0x1604;
CmdType.MXBossPhChange = 0x1605;
CmdType.TryGetXMBossMapInfo = 0x1606;
CmdType.TryGetXMBossBox = 0x1607;
CmdType.XMBossBoxChange = 0x1608;
CmdType.XMBossFenPeiPro = 0x1609;
CmdType.GetXMBossFBResult = 0x160A;
CmdType.GetXMBossFBFuLiInfo = 0x160B;
CmdType.GetXMBossFBFenPeiBox = 0x160C;
CmdType.GetXMBossFBJoinNum = 0x160D;
CmdType.NpcStateChange = 0x1610
CmdType.InitNpc = 0x1611
CmdType.SetNpc = 0x1612

CmdType.GetZongMenInfo = 0x1613
CmdType.OpenZongMenLiLian = 0x1614
CmdType.GetZongMenLiLianPreInfo = 0x1615
CmdType.ZongMenLiLianPiPei = 0x1616
CmdType.ZongMenLiLianPiPeiSuccess = 0x1617
CmdType.ZongMenLiLianGetToNPC = 0x1618
CmdType.ZongMenLiLianCanGotoFb = 0x1619
CmdType.ZongMenLiLianQuXianPiPei = 0x161A

CmdType.ZongMenLiLianCancelGetNpc = 0x161B

CmdType.ZongMenLiLianGameOver = 0x161C

CmdType.ZongMenLiLianYaoQing = 0x161D

CmdType.RecPipeiInfos = 0x161F

CmdType.TryGetInLineInfo = 0x1640;
CmdType.TryGetInLineAward = 0x1641;
CmdType.TryGetRevertAward = 0x1642;
CmdType.SignInRevertAward = 0x1643;

CmdType.GetGuildAssignInfo = 0x1644;

CmdType.CanActiveTrump = 0x1701;
CmdType.ActiveTrump = 0x1702;
CmdType.EquipTrump = 0x1703;
CmdType.RefineTrump = 0x1704;
CmdType.EnableMobao = 0x1705;

CmdType.WildBossInfos = 0x1620;
CmdType.WildBossHeroRank = 0x1621;
CmdType.WildBossHurtRank = 0x1622;

CmdType.WildBossVipInfo = 0x1625;
CmdType.WildBossVipHistory = 0x1626;
CmdType.WildBossVipHurtRank = 0x1627;
CmdType.WildBossVipInfoChg = 0x1628;

CmdType.WorldBossInfos = 0x1630;
CmdType.WorldBossSimpleHurtRank = 0x1631;
CmdType.WorldBossHurtRank = 0x1632;
CmdType.WorldBossEnd = 0x1633;

CmdType.YaoShouBossInfo = 0x1635;

CmdType.XinJiRisksGetCurrState = 0x1650;
CmdType.XinJiRisksRecState = 0x1651;
CmdType.XinJiRisksAnswer = 0x1652;
CmdType.XinJiRisksRecServerNotice = 0x1653;

CmdType.ActivityNotify = 0x16FF;

CmdType.GetMallItemInfo = 0x1801
CmdType.BuyMallItem = 0x1802

CmdType.SendSale = 0x1901
CmdType.GetMySaleData = 0x1902
CmdType.ReGrounding = 0x1903
CmdType.GetSaleRecord = 0x1904
CmdType.ResetSaleRecord = 0x1905
CmdType.GetSaleGold = 0x1906
CmdType.GetCanBuyList = 0x1907
CmdType.BuySaleItem = 0x1908
CmdType.UnGrounding = 0x1909
CmdType.GetRecentPrice = 0x190A
CmdType.GetSaleMoney = 0x190B


CmdType.Sign = 0x1A01
CmdType.ReSign = 0x1A02
CmdType.GetSignData = 0x1A03

CmdType.GetLogin7AwardInfos = 0x1A04
CmdType.GetLogin7Award = 0x1A05

CmdType.GetTotalRechageAward = 0x1A06
CmdType.GetRechageAwardLog = 0x1A07

CmdType.GetChengZhangJiJingInfos = 0x1A08
CmdType.GetChengZhangJiJingAwards = 0x1A09

CmdType.GetChongJiInfos = 0x1A0A
CmdType.GetChongJiAwards = 0x1A0B

CmdType.GetChargeOrderId = 0x1B01
CmdType.GetLimitBuyInfo = 0x1B02


CmdType.GetYueKaInfos = 0x1B03
CmdType.GetYueKaAwards = 0x1B04
CmdType.GetFirstChargeRecord = 0x1B05
CmdType.RechageAwarChange = 0x1B06
CmdType.RAChange = 0x1B07 --运营充值礼包发生改变
CmdType.RAGet = 0x1B08--领取运营充值礼包
CmdType.RAInfo = 0x1B09--查询运营充值礼包
CmdType.ChargeSuccess = 0x1B0A--充值成功(由前端回调的支付都走这条)


CmdType.ArathiSignupTips = 0x1C01
CmdType.ArathiData = 0x1C02
CmdType.ArathiLastNotify = 0x1C03
CmdType.ArathiEnter = 0x1C04
CmdType.ArathiExit = 0x1C05
CmdType.ArathiWarData = 0x1C06
CmdType.ArathiResChage = 0x1C07
CmdType.ArathiMineChage = 0x1C08
CmdType.ArathiBuffChage = 0x1C09
CmdType.ArathiOccupyMine = 0x1C0A
CmdType.ArathiOccupyBuff = 0x1C0B
CmdType.ArathiSignup = 0x1C0C
CmdType.ArathiWarRank = 0x1C0D
CmdType.ArathiOverResult = 0x1C0E
CmdType.ArathiReadyTime = 0x1C0F

CmdType.GuildWarEnroll = 0x1D01;
CmdType.GuildWarRankList = 0x1D02;
CmdType.GuildWarEnrollInfo = 0x1D03;
CmdType.GuildWarPreEnter = 0x1D04;
CmdType.GuildWarInfo = 0x1D05;
CmdType.GuildWarReport = 0x1D06;
CmdType.GuildWarAllReport = 0x1D07;
CmdType.GuildWarCenterChg = 0x1D08;
CmdType.GuildWarPointChg = 0x1D09;
CmdType.GuildWarCollect = 0x1D0A;
CmdType.GuildWarDetail = 0x1D0B;
CmdType.GuildWarResult = 0x1D0C;
CmdType.GuildWarLeave = 0x1D0D;
CmdType.GuildWarStartNotify = 0x1D0E;

CmdType.TabooInfo = 0x1E01;
CmdType.TabooChangeMine = 0x1E02;
CmdType.TabooHoldMine = 0x1E03;
CmdType.TabooCollectNum = 0x1E04;


CmdType.WiseEquip_jianding = 0x2001;--仙兵玄兵 鉴定
CmdType.WiseEquip_fumo = 0x2002;-- 仙兵玄兵 附魔
CmdType.WiseEquip_duanzao = 0x2003;--仙器属性锻造


CmdType.RYSevenDayInfo = 0x1F01;
CmdType.RYSevenDayStatusChg = 0x1F02;
CmdType.RYSevenDayAward = 0x1F03;
CmdType.RYSevenDayFullAward = 0x1F04;
CmdType.ImmortalShopList = 0x1F05;
CmdType.ImmortalShopBuy = 0x1F06;
CmdType.ImmortalShopRank = 0x1F07;
CmdType.ImmortalRevelry = 0x1F08;
CmdType.ImmortalRevelryGet = 0x1F09;
CmdType.ImmortalRevelryChange = 0x1F0A;
CmdType.ImmortalShopRefresh = 0x1F0B;

CmdType.SendCloudPurchaseBuy = 0x1F20;
CmdType.GetCloudPurchaseInfo = 0x1F21;
CmdType.NoticeCloudPurchase = 0x1F22;
CmdType.GetLastCloudPurchaseRecorder = 0x1F23;
CmdType.GetCloudPurchaseReward = 0x1F24;

 

CmdType.GetClashGiftsInfo = 0x1F30;




CmdType.YYGetActvityInfo = 0x1F10;
CmdType.YYExChange = 0x1F11;
CmdType.YYLoginGet = 0x1F12;
CmdType.YYRechargeGet = 0x1F13;
CmdType.YYRechargeChange = 0x1F14;

CmdType.FormationUpdate = 0x2101;

CmdType.XuanBaoInfo = 0x2201;
CmdType.XuanBaoStatusChg = 0x2202;
CmdType.XuanBaoAward = 0x2203;
CmdType.XuanBaoFullAward = 0x2204;

 