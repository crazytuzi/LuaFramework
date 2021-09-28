-------------------------------------------------------
--module(..., package.seeall)

local require = require;

--require("cocos/init");
require("ui/cc_def");
require("ui/ccui_def");

-------------------------------------------------------
--uiid
eUIID_Loading		=  0;
eUIID_Login			=  1;
--eUIID_Main			=  2;
-- eUIID_Battle		=  3;
-- eUIID_Mask			=  4;
eUIID_Yg			=  5;
--eUIID_SetView		=  6;
eUIID_Tips			=  7;
eUIID_Bag			=  8;
eUIID_CSelectChar	=  9;
eUIID_CCreateChar	= 10;
eUIID_SelChar		= 11;
eUIID_Main			= 12;
eUIID_SaleItems		= 13;
eUIID_EquipTips		= 14;
--eUIID_CommonTips	= 15;
--eUIID_ItemTips		= 16;
eUIID_SaleItemBat	= 17;
--eUIID_ZB			= 18;
--eUIID_YB			= 19;
eUIID_DB			= 20;
--eUIID_Return		= 21;
eUIID_FBLB			= 22;
eUIID_Email			= 23;
eUIID_StrengEquip	= 24;
eUIID_MessageBox1	= 25;
eUIID_MessageBox2	= 26;
eUIID_StrengTips	= 27;
eUIID_RoleLy			= 28;
eUIID_SkillLy			= 29;
eUIID_XB				= 30;
eUIID_UpSkillTips		 = 31;
eUIID_XinFa			= 32;
eUIID_Help			= 33;
eUIID_SetBlood		= 34;
eUIID_Task			= 35;
eUIID_Jewel			= 36;
eUIID_ShenBing		= 37;
eUIID_BuyTips		= 38;
eUIID_GetTips		= 39;
eUIID_JewelUpdate	= 40;
eUIID_ShenBingSkillTips = 41;
eUIID_Dialogue1		= 42;
--eUIID_Dialogue2		= 43;
eUIID_Dialogue3		= 44;
eUIID_RepairEquipTips	= 45;
eUIID_SuiCong		= 46;
--eUIID_SuicongPlay	= 47;
eUIID_SuicongSkillTips = 48;
eUIID_SuicongBreakTips = 49;
eUIID_DungeonBonus	= 50;
eUIID_PlayerRevive	= 51;
eUIID_Dialogue4		= 52;
eUIID_RoleTips		= 53;
eUIID_Team			= 54;
eUIID_CreateTeam	= 55;
eUIID_CreateRoom	= 56;
eUIID_MyTeam		= 57;
eUIID_Transfrom1	= 58;
eUIID_Transfrom2	= 59;
eUIID_TransfromSucceedTips = 60;
eUIID_TransfromSkillTips = 61;
eUIID_Wjxx			= 62;
--eUIID_TeamApply		= 63;
eUIID_WIPE			= 64;
eUIID_WIPEAward			= 65;
eUIID_SuitEquip		= 66;
eUIID_SuicongDungeonPlay = 67;
eUIID_Bangpai		= 68
eUIID_CreateFaction	= 69
eUIID_JoinFaction	= 70
eUIID_InviteFriends	= 71
eUIID_RoomTips 		= 72
eUIID_InviteLayer	= 73
eUIID_FactionLayer	= 74
eUIID_FactionList	= 75
eUIID_FactionMain	= 76
eUIID_SP_DEMO		= 77
eUIID_FactionUpSpeed = 78
eUIID_FactionSKill	= 79
eUIID_FactionWorship = 80
eUIID_FactionContribution = 81
eUIID_FactionControl = 82
eUIID_FactionDine = 83
eUIID_FactionEatDine = 84
eUIID_MercenaryRevive = 85;
eUIID_FactionDineTips = 86
--eUIID_FactionStore = 87
--eUIID_FactionStoreBuy = 88
eUIID_DailyTask		= 89
eUIID_NpcDialogue	= 90
eUIID_FactionDungeon = 91
eUIID_FactionDungeonFenpei = 92
eUIID_FactionDungeonLayer = 93
eUIID_FactionDungeonAward = 94
eUIID_FactionDungeonDetail = 95
eUIID_FactionDungeonBattleOver = 96
eUIID_FactionCreed		= 97
eUIID_Chat				= 98
eUIID_FactionSuicongPlay = 99
eUIID_FactionDamageRank = 100
eUIID_FactionSet = 101
eUIID_ChatFC			= 102
eUIID_CreateKungfu	= 103
eUIID_FactionTask 	= 104
eUIID_PriviteChat		= 105
eUIID_PKMode	= 106
eUIID_CreateKungfuSuccess = 107
eUIID_ChangeSkillIcon = 108
eUIID_KungfuFull	= 109
eUIID_SelectBq			= 110
eUIID_KungfuDetail	= 111
eUIID_KungfuUplvl	= 112
--eUIID_JoinClan		= 113
--eUIID_ClanList		= 114
eUIID_KungfuBuyCount = 115
--eUIID_ClanIntroduce	= 116
--eUIID_ClanMain		= 117
--eUIID_ClanHall		= 118
--eUIID_ClanUpLvl		= 119
--eUIID_ClanControlMember	= 120
--eUIID_ClanDismiss	= 121
--eUIID_ClanCreate	= 122
--eUIID_Arena			= 123
--eUIID_ClanDismissTips = 124
--eUIID_ClanLongmen	= 125
--eUIID_ClanExchange	= 126
--eUIID_ClanZhaoren	= 127
--eUIID_ClanShoutuBegin = 128
--eUIID_ClanShoutuIng = 129
--eUIID_ClanContestBegin = 130
--eUIID_ClanContestIng = 131
--eUIID_ClanContestEnd = 132
eUIID_ArenaRank		= 133
--eUIID_ClanBuschEnd = 134
--eUIID_ClanPreachEnd = 135
--eUIID_ClanChildHall = 136
--eUIID_ClanChildAttribute = 137
--eUIID_ClanExpRun	= 138
--eUIID_ClanRunExpEnd = 139
--eUIID_ClanEliteAddAttribute = 140
eUIID_ArenaEnemyLineup	= 141
eUIID_ArenaSetBattle	= 142
eUIID_FactionGetAward = 143
eUIID_SuitAttributeTips = 144
--eUIID_ClanTask		= 145
eUIID_ArenaSetLineup	= 146
--eUIID_ClanTaskEnemy	= 147
--eUIID_ClanTaskFinish	= 148
--eUIID_CLanReawardChild = 149
eUIID_ArenaWin			= 150
eUIID_ArenaLose			= 151
--eUIID_ClanArmy	= 152
--eUIID_ClanHideArmy	= 153
--eUIID_CLanSetArmy	= 154
--eUIID_ClanPosData 	= 155
--eUIID_ClanMine		= 156
--eUIID_ClanMineLayer	= 157
eUIID_ShenBingPropertyTips = 158
eUIID_ArenaLogs				= 159
eUIID_ArenaIntegral			= 160
--eUIID_ClanOtherTeam	= 161
eUIID_Production	= 162
--eUIID_ClanBattleLayer = 163
eUIID_ArenaCheckLineup		= 164
--eUIID_ArenaShop				= 165
eUIID_ArenaRankBest			= 166
--eUIID_ArenaBuyTimes			= 167
--eUIID_ProductionBuyTimes		= 168
--eUIID_ClanMineTeam		= 169
eUIID_DungeonFailed		= 170
--eUIID_ClanMineUpLvl		= 171
eUIID_BuyCoin	= 172
eUIID_BuyCoinBat = 173
eUIID_VipSystem = 174
eUIID_ArenaHelp			= 175
eUIID_FactionChangeName	= 176
eUIID_FactionChangeLevel = 177
--eUIID_FactionChangeIcon = 178
eUIID_BuyVit = 179
eUIID_ChannelPay = 180
eUIID_VitTips = 182
eUIID_ArenaSwallow		= 183
eUIID_Activity			= 184
eUIID_ActivityDetail	= 185
--eUIID_ArenaShopBuyTips	= 186
--eUIID_CheckItem			= 187
eUIID_SignIn 			= 188
eUIID_SignInAward		= 189
--eUIID_ClanMineHarvest	= 190
eUIID_VipStore			= 191
eUIID_BossSelect		= 192
eUIID_FactionDungeonRule	= 193
--eUIID_ClanTips1			= 194
--eUIID_ClanTips2			= 195
--eUIID_ClanTips3			= 196
eUIID_UseItems			= 197
eUIID_ActivityPets		= 198
eUIID_FactionGetWorshipAward = 199
eUIID_VIP_STROE_BUY = 200
eUIID_SceneMap			= 201
--eUIID_ClanRank			= 202
--eUIID_ClanDefindRecord	= 203
eUIID_ItemInfo			= 205
--eUIID_ActivityTips		= 206
eUIID_BagItemInfo 		= 207
eUIID_EquipUpStar		= 208
eUIID_WorldMap			= 209
eUIID_CommmonStore		= 210
eUIID_CommmonStoreBuy		= 211
eUIID_GemUpLevel		= 212
eUIID_Auction			= 213
--eUIID_TaskFinished      = 214
eUIID_Fuli				= 215
--eUIID_TaskAnimation 	= 216
eUIID_SaleEquip			= 217
eUIID_SaleProp			= 218
eUIID_FactionNewChangeIcon = 219
eUIID_AuctionPutOff		= 220
--eUIID_ClanAttack		= 221
--eUIID_ClanEnemySituation = 222
--eUIID_ClanKeekMsg		= 223
eUIID_Steed				= 224
--eUIID_ClanBattleReport	= 225
--eUIID_ClanBattleReportDetail = 226
eUIID_OtherTest			= 227
eUIID_BuyDungeonTimes	= 228
eUIID_SteedPractice		= 229
eUIID_SteedStar			= 230
eUIID_SteedSkill		= 231
eUIID_SteedActSkill		= 232
eUIID_FactionEmail		= 233
eUIID_GodEye			= 234
eUIID_ActivityResult	= 235
eUIID_Friends           = 236
eUIID_UseLimitConsumeItems		= 237
eUIID_UseLimitItems				= 238
eUIID_SteedHuanhua		= 239
eUIID_UseItemGainItems			= 240
eUIID_UseItemGainMoreItems		= 241
--eUIID_ClanPresgite		= 242
eUIID_SteedPracticeTips			= 243
eUIID_GetFriendsMoredec         = 244
--eUIID_ClanCreateAnimation		= 245
eUIID_BattleBase = 246
eUIID_BattleTask = 247
eUIID_BattleTeam = 248
eUIID_BattlePets = 249
eUIID_BattleNPChp = 250
eUIID_BattleBossHp = 251
eUIID_BattleFuben = 252
eUIID_BattleDrug = 253
eUIID_BattleTXFinishTask = 254
eUIID_BattleTXAcceptTask = 255
--eUIID_BattleRoom = 256
eUIID_BattleFight = 257
eUIID_BattleEquip = 258
eUIID_BattleProcessBar = 259
eUIID_Wait = 260
eUIID_BattleShowExp = 261
eUIID_DailyActivity = 262
eUIID_ChangePersonState = 263
eUIID_QueryRoleFeature = 264
eUIID_FashionDress				= 265
eUIID_FashionDressTips			= 266
eUIID_ShowFriendsEquipTips		= 267
eUIID_KillCount				= 268
eUIID_ShowEquipTips			= 269
eUIID_PutOffEquip			= 270
eUIID_MercenaryPop1			= 271
eUIID_MercenaryPop2			= 272
eUIID_MercenaryPop3			= 273
--eUIID_ClanBattleFailOver 	= 274
--eUIID_ClanBattleWinOver		= 275
eUIID_UseAnimateGainItems = 276
eUIID_UseAnimateGainMoreItems = 277
eUIID_UseAnimateGainMoreItems = 278
eUIID_VIP_STROE_FASHION_BUY		= 279
eUIID_BattleLowBlood			= 280
eUIID_BattleTreasure			= 281
eUIID_PowerChange			= 282
eUIID_BattleHeroHp          = 283
eUIID_TreasureScrectBox			= 284
eUIID_GiveFlower			= 285
eUIID_Charm				= 286
eUIID_MountCollection		= 287
eUIID_BattleEntrance = 288
eUIID_KungfuShowOff  = 289
eUIID_GetCollection			= 290
eUIID_FriendsCharm		= 291
eUIID_AnswerQuestions = 292
eUIID_TalkPop1				= 293
eUIID_TalkPop2				= 294
--eUIID_LeadBoard2		= 295
eUIID_FindClue				= 296
eUIID_ExploreSpotFailed		= 297
eUIID_ExploreSpotSuccessed	= 298
eUIID_NewTips				= 299
eUIID_LuckyWheel				= 300
eUIID_LuckyWheel_buy_count = 301
eUIID_SocialAction				= 303
eUIID_BattleMiniMap        = 304
--eUIID_Matching					= 305
eUIID_CONTROLLEAD				= 306
eUIID_QuizShowExp 	= 316
eUIID_TournamentRoom			= 307
eUIID_MainTask_SpecialUI     = 308
eUIID_TournamentResult			= 309
eUIID_OfflineExpReceive 	= 310
eUIID_EquipSevenTips = 311
eUIID_EquipSevenTips2 = 312
eUIID_LongYin       =313
eUIID_BattleOfflineExp = 314
eUIID_Battle4v4				= 315
--eUIID_Arena_Choose       = 317
--eUIID_ArenaTaoist      = 318
eUIID_RankList 			 = 319
--eUIID_TournamentShop		= 320
eUIID_RankListRoleInfo	 =321
eUIID_RankListRoleProperty = 322
eUIID_GuideUI					= 323
eUIID_TournamentRecord			= 324
eUIID_Empowerment        = 325
eUIID_Library            = 326
eUIID_PVPShowKill	= 327
eUIID_TaoistPets				= 328
eUIID_TournamentHelp			= 329
eUIID_TaoistLogs				= 330
eUIID_TaoistRank				= 331
eUIID_GameNotice	= 332
eUIID_SelectServer	= 333
eUIID_CanWu                    = 334
eUIID_TaoistWin					= 335
eUIID_TaoistLose				= 336
eUIID_CanWuStrat				= 337
eUIID_CanWuEnd					= 338
eUIID_LeadPlot				= 339
eUIID_BattleFuncPrompt          = 340
eUIID_ShouSha			= 341
eUIID_PreviewDetailone = 342
eUIID_PreviewDetailtwo = 343
eUIID_OtherLongYinInfo = 344
eUIID_BattleShowExpCoin = 345
eUIID_Fengce					= 346
eUIID_RolePropertyTips			= 347
eUIID_PerfectUserdata			= 348
eUIID_Survey					= 349
eUIID_AddDiamond				= 350
eUIID_HostelGuide1				= 351
eUIID_HostelGuide2				= 352

eUIID_RollNotice        = 353
eUIID_RoleTitles 	 	= 354
eUIID_TopMessageBox1 = 356
eUIID_TopMessageBox2 = 357

eUIID_FactionEscort = 358
eUIID_RoleTitlesAllProperty = 359
eUIID_RoleTitlesProperty    = 360
eUIID_SkillFuncPrompt       = 361
eUIID_UniqueSkill       = 362
eUIID_PetAchievement	= 363
eUIID_ShenshiExplore 	= 364

eUIID_FiveUniquePrestige	= 365
eUIID_FiveUniqueSelect	= 366
eUIID_FiveUniqueExploits = 367
eUIID_FiveUniquePets	= 368
eUIID_Secretarea	= 369
eUIID_KillTarget		= 370
eUIID_FiveUniqueFailed  = 371
eUIID_FiveUniqueBonus	= 372
eUIID_FactionEscortPath = 373
eUIID_ShenshiBattle		= 374
eUIID_WorldLine			= 375
eUIID_WorldLineProcessBar	= 376
eUIID_FactionResearch	= 377
eUIID_EscortAction 		= 378
eUIID_Transfrom3		= 379
eUIID_EscortAward		= 380
eUIID_ForceWarKillNumber= 381
eUIID_ForceWarResult	= 382
--eUIID_ForceWarMatching	= 383
eUIID_BattleUnlockSkill = 384
eUIID_ForceWarMiniMap   = 385
eUIID_ForceWarMap 		= 386
--eUIID_ESCORTSTORE		= 387
--eUIID_EscortStoreBuy	= 388
eUIID_EscortForHelp		= 389
eUIID_EscortHelpTips 	= 390
eUIID_ForceWarHelp		= 391
eUIID_BreakSceneAni		= 392
eUIID_transportProcessBar	= 393
eUIID_BattleSkillItem   = 394
eUIID_MainTaskInsertUI	= 395
eUIID_KeepActivity		= 396
eUIID_Invite			= 397
eUIID_MonsterPop		= 398
eUIID_TaskShapeshiftingTips		= 399
eUIID_DBF				= 400
eUIID_FindwayStateTips	= 401
eUIID_TreasureAnis		= 402
eUIID_ModifyName		= 403
eUIID_ItemMailUI	    = 404
eUIID_Compound			= 405
eUIID_BattleTXUpLevel   = 406
eUIID_GiveFlowerEffects = 407
eUIID_SnapShot          = 408
eUIID_BindEffect		= 409
eUIID_Volume			= 410
eUIID_TiShi             = 411
eUIID_BillBoard         = 412
eUIID_BillBoard_Editor  = 413
eUIID_BillBoard_Revise  = 414
eUIID_BillBoard_CL      = 415
eUIID_FactionMemberDetail = 416
eUIID_FactionControlLayer = 417
eUIID_FactionControlMember = 418
eUIID_FactionAppilyNoticeSet = 419
eUIID_Schedule      	= 420
eUIID_Schedule_Detail   = 421
eUIID_Under_Wear		= 422
eUIID_ArenaList			= 423
eUIID_ChooseAutoStreng 	= 424
eUIID_Under_Wear_Unlock = 425
eUIID_Under_Wear_update = 426
eUIID_KickMember	    = 427
--eUIID_Battle_Entrance   = 428
eUIID_MapName         = 429
eUIID_Under_Wear_upStage = 430
eUIID_PetTask			= 431
eUIID_Under_Wear_showWuXun	= 432
eUIID_Under_Wear_Talent	= 433
eUIID_Under_Wear_Talent_Point = 434
eUIID_Under_Wear_Talent_Point_Reset= 435
eUIID_Under_Wear_Rune= 436
eUIID_Push_Rune= 437
eUIID_RuneBagItemInfo= 438
eUIID_RuneBagPopNum= 439
eUIID_Under_Wear_Slot_Unlock = 440
eUIID_BossRecords = 441
eUIID_BattleBoss  = 442
eUIID_Under_Wear_Rune_Lang  = 443
eUIID_PlayerLead = 444
eUIID_Under_Wear_Rune_Equip = 445
eUIID_Warehouse 			= 446
eUIID_RobEscortAnimation = 447
eUIID_RobEscortShowCoin = 448
eUIID_BuffTips			= 449
eUIID_HuoLongDao		= 450

eUIID_Marry_Create_Marriage= 451
eUIID_Marry_Demande_Marriage = 452
eUIID_Marry_Select_Size= 453
eUIID_Marry_Proposing = 454
eUIID_Marry_Wendding = 455
eUIID_Marry_Unmarried = 456
eUIID_Marry_Progress_Inst= 457
eUIID_Marry_Marryed_Yinyuan= 458
eUIID_Task_Question   = 459
eUIID_EmpowermentTips = 460
eUIID_Marry_Marryed_lihun = 461
eUIID_Marry_Marryed_skills = 462
eUIID_npcExchange  = 463
eUIID_FactionDungeonSchedule = 464
eUIID_FactionTeamDungeonOver = 465
eUIID_steedSkillUpLevel  = 466
eUIID_Marry_Banquat = 467
eUIID_AfterTenYears = 468
eUIID_FactionTeamDungeonBtn = 469
eUIID_FactionTeamDungeonDamageRank = 470
eUIID_SkillPreset  = 471
eUIID_SkillSet  = 472
eUIID_SpiritsSet  = 473
eUIID_PreName  = 474
eUIID_SingleDungeonTips = 475
eUIID_FactionTeamDungeonMap   = 476
eUIID_2v2Result			   	  = 477
eUIID_Battle2v2			      = 478
eUIID_ShenBing_UpSkill        = 479
eUIID_ShenBing_UpSkillMax     = 480
eUIID_ShenBing_Talent_Info    = 481
eUIID_ShenBing_Talent_Buy     = 482
eUIID_ShenBing_Talent_Reset   = 483
eUIID_2v2DanResult		= 484
eUIID_FactionDineGetVit		= 485
eUIID_Grab_Red_Envelope		= 486
eUIID_Firework1				= 487
eUIID_SuicongUpSkillLevel	  = 488
eUIID_SuicongMaxSkillLevel	  = 489
eUIID_GiveItem				  = 490
eUIID_Firework2			= 491
eUIID_Firework3			= 492
eUIID_Firework4 		= 493
eUIID_Firework5 		= 494
eUIID_UntilBossUI       = 495
eUIID_WaitTip = 496
eUIID_SignWait			= 497
eUIID_FactionRobFlagAward = 498
eUIID_ShenBing_UniqueSkill = 499
eUIID_BindEffect2D         = 500
eUIID_War_Team_Room = 501
eUIID_FactionRobFlagLog = 502
eUIID_Grab_Red_Bag_Reward = 503
eUIID_Grab_Red_Bag_Not_HaveReward = 504

eUIID_StrengthenSelf 	= 505
eUIID_MidMessageBox1 	= 506
eUIID_MidMessageBox2 	= 507
eUIID_Schedule_Tips 	= 508
eUIID_RankList_Other	= 509
eUIID_ProgressSuccess   = 510
eUIID_ShenshiTongmin   	= 511
eUIID_Danyao			= 512
eUIID_SpanTips    		= 513
eUIID_AllSpirits 		= 514
eUIID_ExploitTips		= 515
eUIID_StudySpirit		= 516
eUIID_SpiritTips1		= 517
eUIID_SpiritTips2 		= 518
eUIID_SpiritTips3		= 519
eUIID_TournamentChoosePet = 520
eUIID_FactionQq			= 521
eUIID_BuyWizardPoint	= 522

eUIID_OpenArtufact		= 523
eUIID_OpenArtufact1		= 524
eUIID_Under_Wear_Introduce	= 525
eUIID_OfflinWizardTips		= 526
eUIID_NpcHotel 				= 527
eUIID_MartialFeatShop		= 528
eUIID_MartialFeatShopTip	= 529
eUIID_ShowRoleTitleTips		= 530
eUI_EXP_DESC				= 531
eUIID_GroupBuy				= 532
eUIID_RoleLy2				= 533
eUIID_TransferPreview 		= 534
eUIID_Marry_reserve			= 535
eUIID_Weapon_NPC_RESULT 	= 536
eUIID_Marry_effects			= 537
eUIID_RewardTest			= 538
eUIID_RewardTips			= 539
eUIID_BuyBaseItem			= 540
eUIID_Broadcast				= 542
eUIID_Qiankun				= 543
eUIID_QiankunBuy			= 544
eUIID_QiankunReset			= 545
eUIID_StoreRefresh			= 546
eUIID_FlashSale				= 547
eUIID_AboveBuffTips			= 548
eUIID_RetrieveChoose		= 549
eUIID_RetrieveActivity		= 550
eUIID_AuctionSearching		= 551
eUIID_MapCopyDamageRank		= 552
eUIID_RightHeart			= 553
eUIID_DownloadExtPack		= 554
eUIID_YunbiaoTips			= 555
eUIID_RightHeart_RESULT		= 556
eUIID_Stela 				= 557
eUIID_DemonHoleRank 		= 558
eUIID_DemonHolesummary		= 559
eUIID_DemonHoleDialogue		= 560
eUIID_Annunciate			= 561
eUIID_BattleReadFight		= 562
eUIID_RetrieveActivityTip	= 563
eUIID_FightNpc				= 564
eUIID_BindEffectMarry 		= 565
eUIID_AddFriends			= 566
eUIID_LuckyStarTip			= 567
eUIID_QiankunUp				= 568
eUIID_FanXian               = 569
eUIID_UniqueskillPreview	= 570
eUIID_SendItems             = 571
eUIID_OnlineVoice			= 572
eUIID_PayActivity           = 573
eUIID_BuyChannelSpirit		= 574
eUIID_ServerLineUp			= 575
eUIID_Grab_Red_Bag_other    = 576
eUIID_Evaluation_weaponPet	= 577
eUIID_MakeLegendEquip		= 578
eUIID_DungeonMap			= 579
eUIID_LegendEquip           = 580
eUIID_woodMan 				= 581
eUIID_woodManShare 			= 582
eUIID_BackDefense			= 583
eUIID_DefendRank			= 584
eUIID_UnlockHead			= 585
eUIID_PrayActivity          = 586
eUIID_PrayActivityTurntable = 587
eUIID_DefendSummary			= 588
eUIID_DefendResult			= 589
eUIID_BuyPrivateWareHouse	= 590
eUIID_IsBuyWareHouse		= 591
eUIID_DefendCount			= 592
eUIID_Master_shitu          = 593  -- 师徒关系主界面
eUIID_Master_baishi         = 594  -- 拜师界面
eUIID_Master_chushi         = 595  -- 出师提示界面
eUIID_Master_modifyAnnc     = 596  -- 修改收徒宣言
eUIID_Master_mstrInfo       = 597  -- 师傅信息，徒弟拜师时查看
eUIID_Master_apprtcActv     = 598  -- 徒弟活跃值界面
--eUIID_Master_shop           = 599  -- 师徒点商店
--eUIID_Master_shop_buy       = 600  -- 师徒点商店购买界面
eUIID_FuBen_Skill			= 601
eUIID_FuBen_SkillDetail		= 602
eUIID_RECHARGE_CONSUME_RANK	= 603  --充值,消费排行榜
eUIID_ArtifactStrengthSelect = 604
-- eUIID_ArtifactStrength      = 605 -- 弃用
eUIID_Activity_Calendar     = 606  -- 活动日历
eUIID_Activity_CalendarDetail = 607
eUIID_Blood_Pool			= 608 -- 血池使用
eUIID_Today_Tip				= 609 -- 今日提示（用于兑换活动，幸运大转盘...）
eUIID_Fly_Mount_Preview     =610 -- 飞天骑行预览（坐骑）
eUIID_Quick_Combine			= 611 -- 一键合并
eUIID_Bag_extend			= 612 -- 背包扩充使用道具
eUIID_UnlockHunyu			= 613 -- 魂玉解封
eUIID_ExpTreeWater			= 614 -- 人参浇水
eUIID_ExpTreeShake			= 615 -- 人参摇一摇
eUIID_ExpTreeFlower			= 616 -- 人参丰收
eUIID_UnlockHunyuTips       = 617  -- 解封魂玉tips
eUIID_RefineTip				= 618 --生产精炼的确认提示框
eUIID_longyinSpeedup		= 619 -- 解封龙印加速
eUIID_GemBless				= 620 --宝石祝福
eUIID_RecycleOpen			= 621 --炼化炉开启
eUIID_DestroyItem			= 622 --销毁道具
eUIID_DestroyItem_Count		= 623 --销毁数量选择
eUIID_MessageBox3        	= 624 --组队邀请
eUIID_CombatTeamList		= 625 --渠道对抗赛团队列表
eUIID_CreateCombatTeam		= 626 --渠道对抗赛团队
eUIID_AuctionSelect			= 627 -- 寄售行筛选
eUIID_PkTooltip				= 628 -- PK被击提示框
eUIID_FactionFightGroup		= 629 -- 分堂界面
eUIID_FactionFightGroupCreate	= 630 -- 创建分堂界面
eUIID_FactionFightGroupMsg	= 631 -- 帮派战消息推送
eUIID_FashionSpinning     	= 632 -- 时装精纺
eUIID_FashionSpinningProperty	= 633 -- 时装精纺属性
eUIID_BattleShowEquipPower  = 634 -- 自动售卖蓝绿装备飘字（装备能量）
eUIID_SteedSkin				= 635 --坐骑皮肤
eUIID_SteedSkinTips			= 636 --坐骑皮肤tips
eUIID_SteedSkinProperty		= 637 --坐骑皮肤属性
eUIID_SteedSkinRenew		= 638 --坐骑皮肤续费
eUIID_SteedSkinPrompt		= 639 --坐骑皮肤提示
eUIID_Flash_Sale_Buy		= 640 -- 限时特卖购买物品弹框
eUIID_FactionFightGroupRename	= 641 --分堂修改名字
eUIID_RankListRoleSteedSkin = 642 --排行榜坐骑皮肤
eUIID_Upgrade_Rune_lang 	= 	643
eUIID_FactionFightGroupScore 	= 	644 --帮派战得分面板
eUIID_FactionFightGroupResult 	= 	645 --帮派战结果
eUIID_IsShowSkill               =646 --守护副本技能介绍
eUIID_Rune_lang_attr 			= 647
eUIID_FactionFightMap    		= 648 -- 帮派战大地图
eUIID_FactionFightMiniMap		= 649 -- 帮派战小地图
eUIID_FactionFightPush			= 650 -- 帮派战推送
eUIID_FactionFightPushResult	= 651 -- 帮派战胜负推送
eUIID_DegenerationNpc		= 652 --变性NPC界面
eUIID_DegenerationConfirm	= 653 --变性再次确认界面
eUIID_FiveEndActivity		= 654 --秘藏
eUIID_QieCuoInvite			= 655 --切磋邀请
eUIID_QieCuoResult			= 656 --切磋结果
eUIID_RoleReturn			= 657 --老玩家回归
eUIID_EquipSharpen 			= 658 -- 装备淬锋
eUIID_ChangeHeadFrame		= 659 --头像框
eUIID_RoleReturnActivity	= 660 --回归活动
eUIID_ExchangeMore			= 661 --批量兑换
eUIID_ChangeProfession		= 662 --变换职业
eUIID_ChangeProfessionConfirm	= 663 --变换职业
eUIID_PetRace				= 664 -- 宠物赛跑
eUIID_ExchangeWords			= 665 --对对碰兑换祈福文字
eUIID_BattlePetRace			= 666 -- 宠物赛跑放技能ui
eUIID_DriftBottle			= 667 -- 漂流瓶
eUIID_GoldenEgg              = 668 --热血夺宝
eUIID_DriftBottleGift		= 669 --漂流瓶回礼
eUIID_DriftBottleExtra		= 670 --漂流瓶额外回礼
eUIID_PetRaceSkillDesc		= 671 -- 宠物赛跑技能描述
eUIID_SpringAct				= 672 --温泉交互UI
eUIID_SpringBuff			= 673 --温泉BUFF
--eUIID_PetRaceShop			= 674 -- 宠物赛跑商城
--eUIID_PetRaceShopBuy		= 675 -- 宠物赛跑商城购买
eUIID_FactionRobFlagItem	= 676 -- 夺旗奖励提示
eUIID_MonsterPop2			= 677 -- 宠物赛跑需要同时显示3个泡泡
eUIID_MonsterPop3			= 678 -- 宠物赛跑需要同时显示3个泡泡
eUIID_SpringTips			= 679 -- 温泉提示
eUIID_SpringInvite			= 680 -- 温泉邀请
eUIID_DebrisRecycle			= 681 -- 碎片回收
eUIID_MarriageTitle			= 682 -- 姻缘称号
eUIID_BuffDrugTips			= 683 -- buff药
eUIID_BuffDrugRemove		= 684 -- 清除buff药
eUIID_UserAgreement			= 685 -- 用户协议
eUIID_OtherBuffDrugTips		= 686 -- 其他玩家buff药
eUIID_MartialSoul			= 687 -- 武魂
eUIID_MartialSoulProp		= 688 -- 武魂总属性
eUIID_MartialSoulSkin		= 689 -- 武魂形象
eUIID_MartialSoulSkinUnlock	= 690 -- 武魂形象解锁
eUIID_MartialSoulStage		= 691 -- 武魂归元界面
eUIID_Qiling				= 692 -- 器灵
eUIID_QilingProp			= 693 -- 器灵修炼
eUIID_QilingActive			= 694 -- 器灵激活
eUIID_QilingNode			= 695 -- 器灵节点属性
eUIID_QilingPromote			= 696 -- 器灵进化
eUIID_WoodenTripod          = 697 -- 神木鼎
eUIID_RankListWeaponSoul	= 698 -- 武魂排行榜
eUIID_QilingTips			= 699 -- 器灵属性提示
eUIID_WoodenTripodBuyTimes  = 700 -- 神木鼎购买次数
eUIID_QilingSkillDesc		= 701 -- 器灵被动技能说明
eUIID_QilingSkillUpdate		= 702 -- 器灵技能升级
eUIID_DigitalCollection		= 703 -- 集数兑换
eUIID_FindMooncake		    = 704 -- 中秋节找你妹
eUIID_StarDish				= 705 -- 星盘
eUIID_StarFlare				= 706 -- 星耀
eUIID_Dice					= 707 -- 寻宝大富翁
eUIID_NationalRaiseFlag		= 708 -- 国庆升旗主界面
eUIID_NationalCheerRank		= 709 -- 国庆加油排行榜
eUIID_NationalAddOil		= 710 -- 国庆加油
eUIID_NationalLuckyDog		= 711 -- 国庆加油幸运者
eUIID_WaitToFind			= 712 -- 找你妹等待UI
eUIID_StarShape				= 713 -- 星盘部位形状设置
eUIID_FactionGarrison		= 714 -- 帮派驻地
eUIID_FactionGarrisonDonate	= 715 -- 帮派驻地捐献材料
eUIID_GarrisonDonateRanks	= 716 -- 帮派驻地捐献排行
eUIID_DiceExchange			= 717 -- 大富翁兑换
eUIID_DiceMonster			= 718 -- 大富翁击杀怪物
eUIID_DiceFlower			= 719 -- 大富翁送花
eUIID_FactionFateRanks		= 720 -- 帮派气运排行
eUIID_FactionBoss			= 721 -- 帮派BOSS
eUIID_StarChangeShape		= 722 -- 星耀选择形状界面
eUIID_StarLock				= 723 -- 星耀解锁
eUIID_GameEntrance          = 724 -- 假期节日小游戏入口
eUIID_FactionGarrisonMap	= 725 -- 帮派驻地地图
eUIID_FindFail              = 726 -- 找你妹游戏失败
eUIID_FactionGarrisonSummary = 727 -- 帮派驻地左侧
eUIID_RedEnvelope			= 728 -- 帮派红包领取
eUIID_RedEnvelopeSend		= 729 -- 帮派发红包
eUIID_DragonLucky			= 730 -- 龙运福祉
eUIID_RankStarDish			= 740 --星耀排行榜
eUIID_BonusHouse			= 741 -- 帮派振威堂
eUIID_DiceEventSlow			= 742 -- 大富翁-龟速效果
eUIID_DiceEventThrow		= 743 -- 大富翁-获得多扔一次的机会
eUIID_DiceEventFast			= 744 -- 大富翁-急速效果
eUIID_DiceEventDeduct		= 745 -- 大富翁-免费住店，扣一次
eUIID_StarDishLead			= 746 -- 星盘引导
eUIID_StarActivate			= 747 -- 星盘激活
eUIID_DiceYun				= 748 --- 大富翁 云动画
eUIID_RedEnvelopeDetail		= 749 -- 帮派红包历史
eUIID_CallBack				= 750 -- 玩家回归活动
eUIID_BuyGetGifts			= 751 -- 买赠活动
eUIID_SteedRank             = 752 -- 坐骑排行
eUIID_CheckSteedInfo        = 753 -- 查看他人坐骑信息
eUIID_PromoteSteed          = 754 -- 提升坐骑
eUIID_SuicongWakenTips		= 755 -- 宠物觉醒进度提示
eUIID_SuicongWakenTask1		= 756 -- 宠物觉醒任务1
eUIID_SuicongWakenTask2		= 757 -- 宠物觉醒任务2
eUIID_SuicongWakenTask3		= 758 -- 宠物觉醒任务3
eUIID_SuicongWakenGiveUp	= 759 -- 宠物觉醒放弃
eUIID_SuicongWakenStep		= 760 -- 宠物觉醒步骤
eUIID_Bid					= 761 -- 拍卖行--非寄售行
eUIID_BuyChannelSpiritOther = 762 -- 购买，续费精灵（两种方式）
eUIID_CallBackTips          = 763 -- 玩家回归开启宝箱
eUIID_ChatBubble			= 764 -- 聊天气泡
eUIID_RobberMonster			= 765 -- 江洋大盗详情
eUIID_GmBackstage			= 766 -- 后台指令主界面
eUIID_GmSetLevel			= 767 -- 设置人物等级
eUIID_GmAddItem 			= 768 -- 添加物品
eUIID_GmSetTime 			= 769 -- 设置时间
eUIID_GmSetTransferLevel	= 770 -- 设置转职等级
eUIID_GmEquipUpLevel 		= 771 -- 设置装备升级等级
eUIID_GmUnderWear			= 772 -- 设置内甲
eUIID_GmSetEvilPoint		= 773 -- 设置罪恶点
eUIID_GmSuperWeaponPro		= 774 -- 神兵熟练度
eUIID_GmArtifactSrengthen	= 775 -- 神器强化
eUIID_GmArtifactRefine		= 776 -- 神器精炼
eUIID_GmStarLightShape		= 777 -- 星耀形状
eUIID_GmOpenGarrison		= 778 -- 开启驻地
eUIID_GmSectBossProgress	= 779 -- 驻地boss
eUIID_GmFiveUniqueActivity	= 780 -- 设置五绝层数
eUIID_BidTips				= 781 -- 拍卖行购买提示
eUIID_BidHistory			= 782 -- 拍卖行记录
eUIID_SuicongAwakenWin		= 783 -- 宠物觉醒成功
eUIID_LuckyStar 			= 784 -- 幸运星
eUIID_BreakSeal             = 785 -- 封印开启
eUIID_ExchangeFame          = 786 -- 捐赠获得声望
eUIID_FactionSalary			= 787 -- 帮派工资
--eUIID_FameShop              = 788 -- 武林声望商店
--eUIID_FameShopTips          = 789 -- 武林声望商店Tips
eUIID_GMEntrance			= 790 -- gm入口按钮
eUIID_Meridian				= 791 -- 经脉主界面
eUIID_MeridianResetPulse	= 792 -- 脉象重置界面
eUIID_MeridianPulse			= 793 -- 脉象详情界面
eUIID_MeridianPotential		= 794 -- 经脉潜能界面
eUIID_MeridianPotentialUp	= 795 -- 升级经脉潜能
eUIID_RobberMonsterKiller	= 796 -- 江洋大盗击杀者详情ui
eUIID_CompoundItems			= 797 -- 合成多个道具
eUIID_PersonShop			= 798 -- 个人商店
eUIID_PersonShopBuy			= 799 -- 个人商店购买
eUIID_CreateFightTeam		= 800 -- 创建武道会战队
eUIID_FightTeamRecord		= 801 -- 武道会战队战绩
eUIID_FightTeamSchedule		= 802 -- 武道会赛程
eUIID_FightTeamGameReport	= 803 -- 武道会赛事
eUIID_FightTeamAward		= 804 -- 武道会奖励
eUIID_FightTeamSummary		= 805 -- 武道会战斗左侧
eUIID_otherMeridian 		= 806 --别人的经脉潜能
eUIID_DynamicTitle			= 807 -- 动态称号界面
eUIID_BreakSealEffect       = 808 -- 封印开启特效
eUIID_FightTeamInfo         = 809 -- 武道会队伍信息
eUIID_MeridianProperty		= 810 -- 经脉全属性界面
eUIID_Head_Preview			= 811 -- 商城购买头像
eUIID_Delete_Friend			= 812 -- 一键删除好友
eUIID_selectWeapon			= 813 -- 一键删除好友
eUIID_FightTeamResult		= 814 -- 武道会结果
eUIID_ModifyPetName			= 815 -- 宠物改名
eUIID_FactionRecruitment	= 816 -- 帮派招募令
eUIID_MarriageCertificate	= 817 -- 结婚证
eUIID_ShareMarriageCard		= 818 -- 分享结婚证
eUIID_FightTeamGuard		= 819 -- 武道会观战
eUIID_ActivityShow			= 820 -- 活动通用公告
eUIID_ChristmasWish			= 821 -- 圣诞节许愿
eUIID_ChristmasWishesList	= 822 -- 圣诞节愿望
eUIID_EquipTransform		= 823 -- 装备转化列表
eUIID_EquipTransformCompare = 824 -- 装备转化
eUIID_UpgradePurchaseTip	= 825 -- 等级礼包跳转按钮
eUIID_EquipTransformEnd		= 826 -- 装备转化动画
eUIID_SteedBreak            = 827 -- 坐骑突破
eUIID_FightTeamInviteConfirm = 828 -- 武道会邀请确认框
eUIID_FightTeamPrompt 		= 829 -- 武道战斗ui提示
eUIID_FiveUniqueBatchSweep	= 830 -- 五绝一键扫荡
eUIID_GiftBagSelect			= 831 -- N选n礼包
eUIID_WizardGift			= 832 -- 休闲宠物求取礼物
eUIID_SteedFight			= 833 -- 坐骑骑战
eUIID_UnderWear_upStage_Prop= 834 -- 内甲锻造属性
eUIID_SteedFightUnlock 		= 835 -- 坐骑皮肤激活骑战
eUIID_XingHun				= 836 -- 星魂页面
eUIID_XingHunUpStage		= 837 -- 星魂升阶
eUIID_XingHunSubStar		= 838 -- 辅星详情面板
eUIID_XingHunSubStarLock	= 839 -- 辅星预览面板
eUIID_XingHunSubStarPerfect = 840 -- 辅星圆满面板
eUIID_XingHunMainStarLock	= 841 -- 主星预览面板
eUIID_XingHunMainStarPractice= 842 -- 主星洗炼面板
eUIID_SteedFightPropUnlock 	= 843 -- 坐骑骑战属性激活骑战
eUIID_XingHunOtherInfo		= 844 -- 查看他人神器
eUIID_SteedFightAwardProp	= 845 -- 坐骑骑战属性奖励
eUIID_RankListRoleSteedFight = 846-- 排行榜骑战属性
eUIID_UseShowLoveItem	     = 847-- 使用示爱道具
eUIID_Adventure		 		= 848 --奇遇
eUIID_ShootMsg				 = 849 --帮派弹幕
eUIID_DragonHoleDialogue	= 850 -- 龙穴npc传送对话
eUIID_SteedFightProp		= 851 --骑战精通总属性
eUIID_StatueInfo            = 852 --荣耀殿堂雕像详细信息
eUIID_GoldenEggGifts        = 854 --金蛋显示奖励界面
eUIID_NewYearRedEnvelope	= 855 --新年红包
eUIID_LuckyPack				= 856 --新年福袋
eUIID_LuckyPackTip			= 857 --新年福袋Tip
eUIID_Dengmi				= 858 --灯谜
eUIID_DragonHoleAward		= 859 --龙穴奖励
eUIID_SteedSpiritSkillUnlock = 860 --良驹之灵技能激活
eUIID_SteedSpiritSkillUp	= 861 --良驹之灵技能升级
eUIID_SteedSpiritSkillTips	= 862 --良驹之灵技能满级tips
eUIID_FactionFightAward		= 863 --帮战奖励
eUIID_BuyOffineWizardExp    = 864 --挂机精灵经验购买
eUIID_SteedSpiritShows		= 865 --良驹之灵形象ui
eUIID_RedPacketTips			= 866 --红包拿来Tips
eUIID_RankListRoleSteedSpirit = 867-- 良驹之灵排行榜
eUIID_RedPacketHelp			= 868 --红包拿来帮助ui
eUIID_ShowLoveItemUI		= 869 -- 示爱道具显示特效ui
eUIID_SteedSpiritUpRank		= 870 -- 良驹之灵升阶成功ui
eUIID_Bagua					= 871 -- 八卦
eUIID_puzzlePic				= 872 -- 奇遇拼图
eUIID_BaguaStoneSelect		= 873 -- 八卦原石选择
eUIID_BaguaSacrificeSelect	= 874 -- 八卦祭品选择
eUIID_BaguaExtract			= 875 -- 八卦萃取
eUIID_BaguaSaleBat			= 876 -- 八卦批量出售
eUIID_BaguaTips				= 877 -- 八卦装备预览
eUIID_HitDiglett			= 878 -- 打地鼠
eUIID_TripWizardItem		= 879 -- 旅行精灵消耗道具
eUIID_TripWizardPhotoAlbum	= 880 -- 旅行精灵相册
eUIID_TripWizardPhotoBtn	= 881 -- 旅行精灵照片按钮
eUIID_TripWizardPhotoShow	= 882 -- 旅行精灵照片
eUIID_TripWizardSharePhoto	= 883 -- 旅行精灵分享照片
eUIID_GlobalPveRule			= 884 -- 跨服pve规则
eUIID_PvePeaceArea 			= 885 -- 跨服pve和平区
eUIID_factionBusiness		= 886 -- 帮派商路
eUIID_PinDuoDuoTips			= 887 -- 拼多多 提示
-- eUIID_PvePeaceMap			= 888 -- 跨服pve和平区 小地图
eUIID_FactionDungeonSpecialOver = 889 -- 帮派独立本通过结算界面
eUIID_BaGuaSuit				= 890 -- 套装预览
eUIID_BaGuaGuide			= 891 -- 八卦引导界面
eUIID_ShowLineInfo			= 892 -- 跨服Pve 对战区线路信息 UI
eUIID_PveBattleArea			= 893 -- 跨服pve对战区
eUIID_FactionWareHouse		= 894 -- 跨服pve 帮派仓库
eUIID_WareHouseItem			= 895 -- 跨服pve 帮派仓库 物品信息
eUIID_SetWareHouseItemPrice	= 896 -- 跨服pve 帮派仓库 修改物品所需积分
eUIID_ApplyWareHouseItem	= 897 -- 跨服pve 帮派仓库 申请兑换物品
eUIID_BuyBusinessStars		= 898 -- 帮派商路代做
eUIID_EquipTransFromTo		= 899 -- 装备转化选择
eUIID_MillionsAnswer		= 900 -- 百万答题
eUIID_MillionsAnswerFailure = 901 -- 百万答题失败
eUIID_MillionsAnswerSuccess = 902 -- 百万答题成功
eUIID_Divination 			= 903 -- 每日占卜
eUIID_DivinationReward		= 904 -- 占卜领奖
eUIID_Adventure2			= 905 -- 奇遇2
eUIID_Adventure3			= 906 -- 奇遇3
eUIID_fiveTrans				= 907 -- 五转之路
eUIID_SuperArenaWeaponSet	= 908 -- 神器乱战神兵设置
eUIID_MoodDiary				= 909 -- 心情日记
eUIID_DiaryContent			= 910 -- 心情日记内容UI
eUIID_SingleChallenge 		= 911 -- 单人闯关
eUIID_DestinyRoll			= 912 -- 五转之路天命轮
eUIID_PigeonPost			= 913 -- 飞鸽传书
eUIID_PigeonPostSend		= 914 -- 飞鸽传书发送
eUIID_BattleTouramentWeapon = 915 -- 神器乱战战斗ui
eUIID_DescTips 				= 916 -- 描述tips
eUIID_TournamentWeaponResult = 917 -- 会武神器乱战战斗结果
eUIID_FansRank				= 918 -- 心情日记粉丝排行
eUIID_SendGift				= 919 -- 心情日记赠送礼物UI
eUIID_WeaponEffect 			= 920 -- 幻灵--强化武器特效选择
eUIID_MoodDiaryBeauty		= 921 --心情日记美化
eUIID_FulingAddPoint		= 922 -- 龙印 魂玉 附灵加点
eUIID_FulingUpLevel			= 923 -- 龙印 魂玉 附灵升星
eUIID_FulingReset			= 924 -- 龙印 魂玉 附灵重置
eUIID_FulingTips			= 925 -- 龙印 魂玉 附灵战力提示
eUIID_SingleChallengeFailed = 926 -- 单人闯关失败界面
eUIID_UseVit   				= 927 -- 道具使用增加体力的界面
eUIID_MoodDiaryShare		= 928 -- 心情日记分享
eUIID_SingleBuffTips		= 929 -- 单人闯关buff tips
eUIID_FulingUpLevelMax		= 930 -- 附灵 五行相生圆满
eUIID_sweepActivity			= 931 -- 试炼扫荡
eUIID_TransfromAnimate		= 932 -- 转职成功动画
eUIID_FactionAssist			= 933 -- 帮派助战
eUIID_PowerReputation		= 934 -- 势力声望
eUIID_PowerReputationCommit = 935 -- 势力声望 捐赠
eUIID_PowerReputationTask 	= 936 -- 势力声望 任务
eUIID_MoodDiaryAnimate1		= 937 -- 心情日记特效1
eUIID_MoodDiaryAnimate2		= 938 -- 心情日记特效2
eUIID_ShowLove				= 939 -- 告白
eUIID_ShowLoveWish			= 940 -- 告白祝福领奖
eUIID_ProtectMelon			= 941 -- 保卫西瓜
eUIID_ChessTaskAccept		= 942 -- 珍珑棋局接任务
eUIID_ChessTaskThink		= 943 -- 珍珑棋局思考
eUIID_ChessTaskEnd			= 944 -- 珍珑棋局结束
eUIID_BaguaSplitSure		= 945 -- 八卦分解二次确认
eUIID_HomelandPlant			= 946 -- 家园种植界面
eUIID_HomelandPlantOperate	= 947 -- 家园种植操作界面
eUIID_WorldCup				= 948 -- 世界杯
eUIID_WorldCupYaZhu			= 949 -- 世界杯押注
eUIID_WorldCupResult		= 950 -- 世界杯结果
eUIID_HomeLandMain			= 951 -- 家园系统主界面
eUIID_HomeLandCreate		= 952 -- 家园系统创建
eUIID_ChessTaskVerse		= 953 -- 珍珑棋局诗句
eUIID_NpcDonate				= 954 -- npc捐赠界面
eUIID_ChessTaskAnimate		= 955 -- 珍珑棋局动画
eUIID_BattleShowPowerRep	= 956 -- 势力声望增加弹出
eUIID_ChessTaskFindDiff     = 957 -- 珍珑棋局找不同
eUIID_HomeLandChangeName	= 958 -- 家园改名
eUIID_HomeLandStructure		= 959 -- 家园建筑面板
eUIID_ChessTaskRank			= 960 -- 珍珑棋局排行
eUIID_MoodDiaryAnimate3		= 961 -- 珍珑棋局本服跨服动画
eUIID_MoodDiaryShowGifts	= 962 -- 心情日记显示礼物
eUIID_MoodDiaryEffect		= 963 -- 特效
eUIID_MoodDiaryEffectGift 	= 964 -- 特效
eUIID_MoodDiaryEffectRocket = 965 -- 特效
eUIID_ChessTaskDiffAnimate	= 966 -- 珍珑棋局找不同动画
eUIID_ChessTaskPuzzle		= 967 -- 珍珑棋局拼图
eUIID_ThumbtackScollUI		= 968 -- 图钉scoll界面
eUIID_ThumbtackDetail		= 969 -- 图钉详细界面
eUIID_ThumbtackTransferNol  = 970 -- 图钉传送界面一
eUIID_ThumbtackTransferVip	= 971 -- 图钉传送界面二
eUIID_ThumbtackDelete		= 972 -- 删除图钉
eUIID_XinJue				= 973 -- 心决
eUIID_VipStoreCallItemBuy 	= 974 -- 坐骑和宠物召唤类道具购买界面
eUIID_MoodDiaryEffectRocket2 = 975 -- 特效2
eUIID_XinJueTips			= 976 -- 心决tip
eUIID_FirstLoginShow		= 977 -- 登录拍脸（每个角色仅有一次）
eUIID_TaskGuide				= 978 -- 任务指引动画
eUIID_UnlockSteedAddSpirit  = 979 -- 解锁坐骑追加形象
eUIID_XinJueKq				= 980 -- 心决开启界面
eUIID_ChessTaskCross		= 981 -- 珍珑棋局穿越特效
eUIID_HomeLandEquipBag		= 982 -- 家园装备仓库
eUIID_HomeLandFish			= 983 -- 家园钓鱼
eUIID_VipGiftDisTips		= 984 -- Vip礼包折扣提示界面
eUIID_HomeLandEquipTips		= 985 -- 家园钓鱼装备tips
eUIID_XinJueBreakSuccess	= 986 -- 心决突破成功界面
eUIID_BagSearch             = 987 -- 背包搜索面板
eUIID_HideWeapon			= 988 -- 暗器
eUIID_HideWeaponActiveSkill	= 989 -- 暗器主动技能
eUIID_HideWeaponPassiveSkill = 990 -- 暗器被动技能
eUIID_HomeLandMap    		= 991 -- 家园地图
eUIID_HomelandCustomer    	= 992 -- 家园访客
eUIID_HomeLandEvent    		= 993 -- 家园事件
eUIID_HomeLandFishPrompt	= 995 -- 钓鱼提示ui
eUIID_HideWeaponBattle      = 996 -- 暗器战斗界面
eUIID_FamilyDonate      	= 997 -- 家族互助界面
eUIID_FamilyDonateRoles		= 998 -- 家族互助角色界面
eUIID_ApplyWareHouseItemSecond = 999 --帮派互助捐赠物界面
eUIID_EffectFashionTips		= 1000 --特效披风tips
eUIID_HideWeaponActiveSkillLock = 1001 --暗器主动技能未解锁状态
eUIID_SpiritBossReward		= 1002	--巨灵攻城奖励
eUIID_SpiritBossResult		= 1003  --巨灵攻城结算
eUIID_SpiritBossFight		= 1004  --巨灵攻城战斗
eUIID_ChangeNpcList         = 1005 -- NPC奖励面板
eUIID_DefenceWarBattle      = 1006 -- 城战战斗界面
eUIID_DefenceWarBid         = 1007 -- 城战竞标
eUIID_DefenceWarBidRes      = 1008 -- 城战竞标公示
eUIID_DefenceWarBidSure     = 1009 -- 城战竞标确认
eUIID_DefenceWarReLife      = 1010 -- 城战复活
eUIID_DefenceWarReward      = 1011 -- 城战奖励
eUIID_DefenceWarSignIn      = 1012 -- 城战报名
eUIID_DefenceWarSure        = 1013 -- 城战确认报名
eUIID_HuoBan                = 1014 -- 伙伴召回
eUIID_HuoBanCode            = 1015 -- 伙伴码
eUIID_UnlockOutcastTips     = 1016 -- 解锁外传副本提示
eUIID_DefenceWarMap         = 1017 -- 城战地图
eUIID_OutCastBattle 		= 1018 -- 外传副本任务
eUIID_AnqiSelect 			= 1019 -- 战斗界面暗器切换
eUIID_HelpPanel 			= 1020 -- 帮助面板
eUIID_OutCastFinish 		= 1021 -- 外传总结面板
eUIID_HideWeaponHuanhua 	= 1022 -- 暗器幻化
eUIID_HideWeaponHuanhuaTips = 1023 -- 暗器幻化tips
eUIID_HideWeaponHuanhuaUnlock = 1024 -- 暗器幻化形象解锁
eUIID_MoodDiaryEffect3		= 1025 -- 心情日记胡萝卜特效
eUIID_HuoBanBonus   		= 1026 -- 伙伴返回红利
eUIID_DisCountBuyPower		= 1027 -- 充值获得折扣礼包购买权
eUIID_DefenceWarTrans       = 1028 -- 城战npc传送
eUIID_HuoBanCopy            = 1029 -- 伙伴副本提示
eUIID_EquipTemper			= 1030 -- 装备锤炼
eUIID_HomeLandRelease		= 1031 -- 家园放生界面
eUIID_HomeLandProduce		= 1032 -- 家园生产
eUIID_EquipTemperSkillDes	= 1033 -- 装备锤炼技能介绍界面
eUIID_EquipTemperSkillActive= 1034 -- 装备锤炼技能激活界面
eUIID_EquipTemperWash		= 1035 -- 装备锤炼洗练界面
eUIID_HouseBase				= 1036 -- 家园房屋主界面
eUIID_HouseFurniture		= 1037 -- 家园家具界面
eUIID_HouseFurnitureSet		= 1038 -- 家园家具摆放界面
eUIID_HouseBuildinfo   	    = 1039 -- 家园建筑介绍界面
eUIID_EquipTemperStarPreview = 1040 --装备锤炼星级预览界面
eUIID_DefenceWarResult		= 1041 -- 城战结束离开界面
eUIID_EquipTemperSkillUp 	= 1042 --装备锤炼技能升级界面
eUIID_DefenceWarExpTips		= 1043 -- 城战城主之光经验加成tips
eUIID_HomeLandOverview		= 1044 -- 家园总览界面
eUIID_ShenBingBingHun		= 1045 -- 神兵兵魂界面
eUIID_ShenBingBingHunShengJi = 1046 -- 神兵兵魂升级界面
eUIID_ShenBingShenYao 		= 1047 --神兵神耀界面
eUIID_HomelandAddition 		= 1048 -- 家园挂载界面
eUIID_TimingActivity        = 1049 --定期活动
eUIID_TimingActivityTips    = 1050 --定期活动提示
eUIID_DefenceWarMember      = 1051 -- 城战参加成员界面
eUIID_PassExamGift			= 1052 -- 登科有礼界面
eUIID_PassExamGiftReward	= 1053 -- 登科有礼奖励界面
eUIID_HouseSkin				= 1054 -- 房屋皮肤
eUIID_SpiritBlessing		= 1055 --帮派祝福
eUIID_BlessingInfoTips		= 1056 --祝福信息显示
eUIID_VipStoreHomeland		= 1057 -- 商城购买家具
eUIID_KillTips				= 1058 -- 杀戮结果飘字
eUIID_FactionGarrisonSpirit = 1059 --帮派驻地精灵
eUIID_SpiritSkillTips 		= 1060 --驻地精灵技能介绍
eUIID_SetConstellation		= 1061 --心情日记星座选择
eUIID_SetHobby				= 1062 --心情日记爱好选择
eUIID_BattleIllusory		= 1063 --幻境试炼boss属性
eUIID_WriteDiyHobby			= 1064 --心情日记自定义爱好输入
eUIID_FactionBlessingBufTips = 1065 --帮派祝福buf提示
eUIID_MarryAchievement		= 1066 -- 姻缘成就
eUIID_SpiritSkill			= 1067 --驻地精灵技能
eUIID_SetSex				= 1068 --星语星愿设置性别
eUIID_ConstellationTest		= 1069 --星语星愿答题
eUIID_MarryAchievementShow	= 1070 --姻缘成就累积奖励展示
eUIID_ConstellationTestResult = 1071 --星语星愿答题结果页面
eUIID_ConstellationTestShare= 1072 --星语星愿答题结果分享
eUIID_WriteDeclaration		= 1073 --写好友宣言
eUIID_LuckyStarGift			= 1074 --幸运星
eUIID_AddCrossFriends		= 1075 --跨服好友匹配大厅
eUIID_PetDungeonChoseMap	= 1076 --宠物试炼选择地图界面
eUIID_PetDungeonChosePet	= 1077 --宠物试炼选择宠物界面
eUIID_ImportantNotice		= 1078 --仓库代币弹出重要通知
eUIID_PetDungeonBattleBase	= 1079 --宠物试炼战斗界面
eUIID_ConstellationTip		= 1080 --心语星愿提示
eUIID_PetDungeonTaskDetail	= 1081 --宠物试炼任务详情界面
eUIID_PetDungeonGatherDetail = 1082 --宠物试炼采集详情界面
eUIID_PetEquip				= 1083 --宠物装备
eUIID_PetDungeonReceiveTask = 1084 --宠物试炼任务接取界面
eUIID_CrossFriendsApply		= 1085 --跨服好友申请列表
eUIID_QuickWeaponTaskConfirm= 1086 --快速完成神兵任务确认UI
eUIID_PetDungeonrRewards 	= 1087 --宠物试炼奖励界面
eUIID_PetDungeonrEvents 	= 1088 --宠物试炼时间界面
eUIID_PetEquipUpLevel		= 1089 --宠物装备升级
eUIID_PetDungeonrMiniMap	= 1090 --宠物试炼小地图界面
eUIID_PetGahterOperation	= 1091 --宠物试炼采集界面  
eUIID_PetEquipInfoTips		= 1092 --宠物装备详情面板
eUIID_PetEquipSaleBat		= 1093 --宠物装备批量出售
eUIID_PetDungeonReadingbar	= 1094 --宠物试炼采集读条
eUIID_PetEquipSkillUpLvl	= 1095 --宠物试炼技能升级
eUIID_PetEquipSkillUpGrade	= 1096 --宠物试炼技能升级/解锁
eUIID_HomeLandAutoFishTips	= 1097 --自动钓鱼提示
eUIID_PetEquipRankList		= 1098 --宠物排行榜（宠物装备）
eUIID_BattleDesertHero		= 1099 --决战荒漠选择英雄界面
eUIID_BattleDesertAward		= 1100 --决战荒漠奖励界面
eUIID_BattleDesertRank		= 1101 --决战荒漠排行榜界面
eUIID_DesertBattleMiniMap	= 1102 --决战荒漠小地图
eUIID_SwornIntroduce		= 1103 --结拜介绍
eUIID_DesertBattleWatchWar	= 1104 --决战荒漠观战
eUIID_BattleFubenDesert		= 1105 --决战荒漠副本战斗界面
eUIID_DesertBattleFindWayTips = 1106 -- 前往安全区寻路提示
eUIID_WeekLimitReward		= 1107 --每周限时宝箱奖励展示
eUIID_Wujue                 = 1108 -- 武诀（吐纳系统）
eUIID_WujueBreak            = 1109 -- 武诀突破
eUIID_WujueRules            = 1110 -- 武诀规则提示
eUIID_WujueUseItems         = 1111 -- -- 武诀一键使用道具
eUIID_BattleDesertPunish	= 1112 -- 决战荒漠惩罚时间
eUIID_SignInExtraAward		= 1113 --签到额外奖励
eUIID_WujueBreakFull        = 1114 -- 武诀突破圆满
eUIID_WujueSkillActive      = 1115 -- 武诀技能激活
eUIID_WujueSkillFull        = 1116 -- 武诀技能圆满
eUIID_WujueSkillUpLevel     = 1117 -- 武诀技能升级
eUIID_DesertPersonalResult	= 1118 -- 决战荒漠个人积分
eUIID_DesertTeamResult      = 1119 -- 决战荒漠队伍积分
eUIID_SwornDate				= 1120 --输入生日确定座次
eUIID_BattleDesertBag		= 1121 -- 决战荒漠背包
eUIID_WeekBoxGetTips		= 1122 -- 每周限时宝箱获得提示
eUIID_SetSwornPrefix		= 1123 -- 结拜设置称谓前缀
eUIID_MetamorphosisDressTips = 1124 -- 幻形提示框
eUIID_SwornAnim				= 1125 -- 结拜成功动画
eUIID_BattleDesertEquipTips	= 1126 -- 荒漠装备tips
eUIID_BattleDesertItemTips	= 1127 -- 荒漠道具tips
eUIID_SwornModify			= 1128 -- 结拜配置界面
eUIID_WuJueKQ				= 1129 -- 武决开启界面
eUIID_SwornKick				= 1130 -- 结拜踢人
eUIID_SwornChangeName		= 1131 -- 结拜修改称谓
eUIID_SwornCallFriends		= 1132 -- 结拜减负
eUIID_SwornValueDesc		= 1133 -- 结拜金兰值
eUIID_WujueRank				= 1134 -- 武诀排行
eUIID_WujueDH				= 1135 -- 武决动画
eUIID_MemoryCard			= 1136 -- 记忆卡片
eUIID_BuyFulingPoint		= 1137 -- 附灵购买分配点
eUIID_MazeBattleInfo		= 1138 -- 天魔迷宫信息显示界面
eUIID_MazeBattleBenifit		= 1139 -- 天魔迷宫收益
eUIID_DoorOfXiuLianFuBen	= 1140 -- 修炼之门副本界面
eUIID_DoorOfXiuLianResult	= 1141 -- 修炼之门结算界面
eUIID_XingJun				= 1142 -- 星君
eUIID_FiveHegemony			= 1143 -- 五绝争霸占坑
eUIID_FestivalLimitTask		= 1144 -- 节日限时任务入口
eUIID_SteedSprite   		= 1145 -- 拆分出来的，良驹之灵
eUIID_SteedEquip            = 1146 -- 骑战装备
eUIID_SteedEquipPropTip     = 1147 -- 骑战装备属性显示
eUIID_SteedSuit             = 1148 -- 骑战装备 套装
eUIID_SteedStove            = 1149 -- 骑战装备 熔炉
eUIID_steedEquipPropCmp     = 1150 -- 骑战装备比较
eUIID_LingQianQiFuDialog	= 1151 -- 灵签祈福dialog
eUIID_LingQianQiFuResult	= 1152 -- 灵签祈福result
eUIID_FiveHegemonyShow		= 1153 -- 五绝争霸展示
eUIID_FiveHegemonySkill		= 1154 -- 五绝争霸技能
eUIID_SteedSuitActive       = 1155 -- 骑战套装激活
eUIID_BaGuaSacrificeCheck   = 1156 -- 八卦界面查看八卦祭品
eUIID_BaGuaSacrificeSplit   = 1157 -- 八卦祭品拆分
eUIID_BaGuaSacrificeCompound= 1158 -- 八卦祭品合成
eUIID_steedEquipMake        = 1159 -- 骑战装备锻造
eUIID_steedEquipSale        = 1160 -- 骑战装备批量熔炼
eUIID_steedEquipSale2       = 1161 -- 骑战装备批量熔炼2
eUIID_ShakeTree				= 1162 -- 春节摇钱树
eUIID_RankListRoleSteedEquip = 1163 -- 骑战装备排行榜
eUIID_ChannelMigrationTips	= 1164 -- 账号渠道迁移
eUIID_LingQianAnimation		= 1165 -- 灵签动画
eUIID_HomePetChoose			= 1166 -- 家园宠物选择
eUIID_HomePetDialogue		= 1167 -- 家园宠物对话
eUIID_HomePetOperate		= 1168 -- 家园宠物主界面
eUIID_HomePetOther			= 1169 -- 家园宠物他人操作界面
eUIID_MarryUpStage			= 1170 -- 婚礼升级
eUIID_SignInSolarTerm		= 1171 -- 签到节气
eUIID_RoleFlying			= 1172 -- 角色飞升
eUIID_RoleFlyingTips		= 1173 -- 角色飞升提示
eUIID_RoleFlyingEnd			= 1174 -- 角色飞升成功
eUIID_RoleFlyingFind		= 1175 -- 找到灵虚入口
eUIID_PetGuard 				= 1176 -- 守护灵兽
eUIID_PrincessMarryReward 	= 1177 -- 公主出嫁奖励展示
eUIID_TaoistShowReward 		= 1178 -- 正邪道场奖励展示
eUIID_PlotDialogue 			= 1179 -- 公主出嫁对话
eUIID_PrincessMarryBattle 	= 1180 -- 公主出嫁战斗UI
eUIID_PrincessMarryAddScore = 1181 -- 公主出嫁积分飘子
eUIID_PrincessMarryMap		= 1182 -- 公主出嫁小地图
eUIID_ChuHanFightInfo		= 1183 -- 楚汉之争兵种
eUIID_PetGuardSkillInfo 	= 1184 -- 守护灵兽技能展示界面
eUIID_CreateHomeLandTips	= 1185 -- 创建家园提示界面
eUIID_DanceTip				= 1186 -- 周年舞会经验次数满了提示
eUIID_Jubilee				= 1187 -- 周年庆活动
eUIID_JubileeStageOneAward	= 1188 -- 周年庆阶段1奖励tips
eUIID_JubileeStageTwoAward	= 1189 -- 周年庆阶段2奖励tips
eUIID_JubileeChestTips		= 1190 -- 周年庆宝箱tips
eUIID_TalkPop3				= 1191 -- 起泡文本3
eUIID_PetGuardPotential		= 1192 -- 守护灵兽潜能
eUIID_PetGuardPotentialActive= 1193 -- 守护灵兽潜能激活
eUIID_RoleFlyingFoot		= 1194 -- 角色飞升脚印特效
eUIID_RecentlyGet			= 1195 -- 最近获得
eUIID_chuHanFightResult		= 1196 -- 楚汉之争结算
eUIID_FactionEscortRobStore = 1197 -- 劫镖任务
eUIID_PrincessMarryResult   = 1198 -- 公主出嫁奖励
eUIID_FlyingEquipInfo		= 1199 -- 飞升装备信息
eUIID_FactionEscortLuckDraw	= 1200 -- 运镖抽奖
eUIID_GemSaleConfirm		= 1201 -- 宝石二次确认界面
eUIID_JubileeStageThreeTips	= 1202 -- 周年庆阶段3 tips
eUIID_ShowFlyingEquipTips	= 1203 -- 飞升装备提示
eUIID_FriendsFlyingEquipTips = 1204 -- 好友飞升装备展示
eUIID_GemExchangeShow		= 1205 -- 玄系宝石npc展示
eUIID_GemExchangeOperate	= 1206 -- 玄系宝石npc转化
eUIID_UpdateAnnouncement	= 1207 -- 更新公告
eUIID_SpringBuffRank		= 1208 -- 温泉祝福榜
eUIID_PrincessMarryCarton	= 1209 -- 公主出嫁漫画，漫画展示页面，切页，关闭X按钮
eUIID_ShenDou				= 1210 -- 神斗
eUIID_ShenDouSkillMax 		= 1211 -- 神斗技能满级
eUIID_ShenDouBigSkillActive	= 1212 -- 神斗大技能激活
eUIID_ShenDouBigSkillUp		= 1213 -- 神斗大星术升级
eUIID_ShenDouSmallSkillActive= 1214 -- 神斗小星术激活
eUIID_ShenDouSmallSkillUp  	= 1215 --神斗小星术升级
eUIID_MMRank				= 1216 --神机藏海幸运团队
eUIID_MMRankDetail			= 1217 --神机藏海幸运团队详情
eUIID_MMReward				= 1218	--神机藏海奖励
eUIID_MagicMachineBattle  	= 1219 --神机藏海战斗界面
eUIID_BaguaAffixHelp		= 1220	--八卦词缀预览
eUIID_StarShapeTips 		= 1221 --强制变更星位不满足条件时
eUIID_StarShapeConfirm 		= 1222 --强制变更星位满足条件时
eUIID_OppoActivity			= 1223 --oppo活动
eUIID_MagicMachineResult	= 1224 --神机藏海奖励界面
eUIID_MagicMachineMiniMap	= 1225 --神机藏海小地图
eUIID_ShenDouRank    		= 1226 --神斗排行榜
eUIID_CardPacket			= 1227 -- 图鉴界面
eUIID_CardPacketBack		= 1228 -- 图鉴卡背
eUIID_CardPacketUnlock		= 1229 -- 图鉴卡背解锁
eUIID_CardPacketShow		= 1230 -- 图鉴解锁卡牌展示
eUIID_CardPacketDesc		= 1231 -- 图鉴卡牌详情
eUIID_CardPacketChatInfo	= 1232 -- 图鉴聊天分享展示界面
eUIID_FactionDungeonOpenAni = 1233 -- 帮派副本开启成功动画
eUIID_FactionDungeonResetAni= 1234 -- 帮派副本重置成功动画
eUIID_MasterCard			= 1235 -- 桃李症
eUIID_MasterCardShare		= 1236 --桃李症分享
eUIID_MasterCardEdit 		= 1237 --桃李症宣言修改
eUIID_TournamentWeekReward  = 1238 -- 会武周奖励
eUIID_JinLanPu				= 1239 --金兰谱
eUIID_JinLanAchievement 	= 1240 --金兰成就
eUIID_JinLanChangeMessage	= 1241 --金兰改寄语
eUIID_JinLanShare			= 1242 --金兰分享
eUIID_ReceiveAchievementReward = 1243 --一键领取成就tips
eUIID_CityWarExp			= 1244 --城战之光经验
eUIID_MessageBox4			= 1245 --cpr复活提示
eUIID_JinlanAchiPointRwdTips = 1246 --金兰成就点奖励提示
eUIID_NPCHotelDetail		= 1247 --江湖客栈售卖图鉴
eUIID_ChallengeSubmitItems	= 1248 --挑战任务提交道具
eUIID_HomeLandSkill			= 1249 --家园保卫战副本技能界面
eUIID_AutoDo				= 1250 --自动做某件事情
eUIID_AutoRefineSet			= 1251 --坐骑自动洗练设置
eUIID_AutoRefineSetPreview	= 1252 --坐骑自动洗练设置预览
eUIID_HomeLandTreeBlood		= 1253 --家园保卫战副本黄金数血量
eUIID_FiveElements			= 1254 --五行轮转
eUIID_FeiSheng				= 1255 --飞升界面2
eUIID_FeiShengUpgrade		= 1256 --飞升升级
eUIID_FeishengQuickFinish   = 1257 --飞升环任务快速完成
eUIID_FeishengAni		    = 1258 --飞升成功动画
eUIID_FactionPhotoTips      = 1259 --帮派合照提示
eUIID_FactionPhotoList		= 1260 -- 帮派合照列表
eUIID_FactionPhotoEnd		= 1261 -- 合照结束
eUIID_KnightlyDetectiveMember = 1262 -- 江湖侠探成员
eUIID_KnightlyDetectiveSurvey = 1263 -- 江湖侠探调查
eUIID_KnightlyDetectiveLeader = 1264 -- 江湖侠探头目
eUIID_BaguaYilue 			= 1265 --八卦易略开启界面
eUIID_BaguaYilueByPoint		= 1266 --八卦易略购买点数界面
eUIID_SkillSetCartoon		 = 1267 --技能设置动画
eUIID_HuoBanUnbind 			= 1268 --伙伴解绑上家 II
eUIID_KniefShooting			= 1269 -- 至强飞刀手小游戏
eUIID_YilueResetPoint		= 1270 --易略重置点数界面
eUIID_YilueTips				= 1271 --易略介绍
eUIID_YilueSkill			= 1272 --易略技能
eUIID_YilueSkillShengjie	= 1273 --易略技能升阶
eUIID_YilueSkillJihuo		= 1274 --易略技能激活界面
eUIID_KnightlyDetectiveTips = 1275 -- 江湖侠探提示
eUIID_KnightlyDetectiveAnimate = 1276 -- 江湖侠探动画
eUIID_KnightlyDetectiveClue	= 1277 -- 江湖侠探线索提示
eUIID_FieldSublineTask		= 1278 -- 野外支线npc对话
eUIID_FlyingExpItem			= 1279 -- 飞升经验道具
eUIID_FlyingEquipSharpen	= 1280 -- 飞升淬锋
eUIID_FlyingEquipTrans		= 1281 -- 飞升精锻
eUIID_SwordsmanFriendship	= 1282 -- 大侠朋友圈称谓奖励
eUIID_FuYuZhuDing			= 1283 -- 符语铸锭
eUIID_SwordsmanCommit		= 1284 -- 大侠朋友圈交换道具
eUIID_TimingActivityPray	= 1285 -- 定期活动祈愿墙
eUIID_TimingActivityTakeReward = 1286 -- 定期活动领奖界面
eUIID_InputMessageBox 		= 1287 -- 需输入内容确认框
eUIID_FriendsInviteAnswer = 1288 -- 其他玩家邀请好友界面
eUIID_FuYuFastAdd			= 1289 --符语铸锭快速添加
eUIID_SwordsmanQuestion		= 1290 -- 大侠朋友圈答题
eUIID_GoldCoastPKMode		= 1291 -- 黄金海岸PK模式界面
eUIID_EnterWarZone			= 1292 -- 战区地图进入界面
eUIID_WarZoneLine			= 1293 -- 战区地图分线
eUIID_WarZoneCard			= 1294 -- 战区卡片
eUIID_GlobalWorldTaskTake 	= 1295 -- 黄金海岸:赏金任务多领取界面
eUIID_TimeAndDescBuffTips   = 1296 -- buff提示
eUIID_GlobalWorldMapTask 	= 1297 -- 黄金海岸:地图中任务列表界面
eUIID_WarZoneCardShow		= 1298 -- 黄金海岸卡片展示
eUIID_WarZoneCardGetShow	= 1299 -- 卡牌获取展示
eUIID_ArrayStone			= 1300 -- 阵法石主界面
eUIID_ArrayStoneBatchRecycle = 1301 -- 阵法石快速回收
eUIID_ArrayStoneArchive		= 1302 -- 阵法石图鉴
eUIID_ArrayStoneLock		= 1303 -- 阵法石锁定
eUIID_ArrayStoneMWInfo		= 1304 -- 阵法石 密文 Info
eUIID_ArrayStoneMWDisplace	= 1305 -- 阵法石 密文 置换
eUIID_ArrayStoneMWRecovery	= 1306 -- 阵法石 密文 回收
eUIID_ArrayStoneMWSynthetise= 1307 -- 阵法石 密文 合成
eUIID_ArrayStoneSuit		= 1308 -- 阵法石言诀
eUIID_ArrayStoneUpLevel		= 1309 -- 阵法石真言升级
eUIID_ArrayStoneMWRecoveryConfirm = 1310 -- 阵法石 密文 回收 确认
eUIID_ArrayStoneMWEquipConfirm = 1311 -- 阵法石 密文 装备 确认
eUIID_ArrayStoneUnlockHole	= 1312 --阵法石解孔
eUIID_ArrayStoneAmuletProp	= 1313 -- 阵法石符印
eUIID_SwordsmanExpProp		= 1314 -- 大侠朋友圈经验飘字
eUIID_ArrayStoneRanking		= 1315 -- 阵法石排行榜
eUIID_ArrayStoneSuitRank	= 1316 -- 阵法石言诀排行查看
eUIID_FightTeamList			= 1317 -- 武道会列表
eUIID_ForceWarLottery		= 1318 -- 势力战抽奖
eUIID_LotteryNew			= 1319 -- 新充值抽奖
eUIID_LotteryPosibility		= 1320 -- 新充值抽奖概率展示
eUIID_SuperOnHook			= 1321 -- 高级挂机
eUIID_UseItemUpEquipLevel	= 1322 -- 装备升级卷轴
eUIID_LongevityPavilionReward = 1323 -- 万寿阁奖励 longevityPavilionReward
eUIID_LongevityPavilionResult = 1324 -- 万寿阁结算
eUIID_LongevityPavilionBattle = 1325 -- 万寿阁战斗界面
eUIID_LongevityPavilionDelivery = 1326 -- 万寿阁战斗界面
eUIID_InviteList 			= 1327 --邀请列表界面
eUIID_InviteEntrance		= 1328 --邀请列表入口
eUIID_InviteSetting			= 1329 --邀请设置界面
eUIID_SpriteFragmentBag		= 1330 --元灵碎片背包
eUIID_SpriteFragmentExchange = 1331 --元灵碎片交换
eUIID_SpyStory				= 1332 -- 密探风云
eUIID_CatchSpiritPreview	= 1333 -- 鬼岛驭灵拍脸
eUIID_LearnCatchSpiritSkills = 1334 -- 鬼岛驭灵技能学习
eUIID_CatchSpiritSkills		= 1335 -- 鬼岛驭灵技能连招
eUIID_WujueSoulSkill		= 1336 --武决潜魂技能界面
eUIID_CatchSpiritMap		= 1337 -- 鬼岛驭灵小地图
eUIID_CatchSpiritTask		= 1338 -- 鬼岛驭灵副本内次数显示
eUIID_SpiritRefreshTip 		= 1339 --鬼岛驭灵刷新说明界面
eUIID_SpiritTip 			= 1340 --鬼岛驭灵玩法说明技能说明界面
eUIID_SpyStoryTask			= 1341 -- 密探风云任务界面
eUIID_CatchSpiritBag		= 1342 -- 鬼岛驭灵背包
eUIID_ActivityAddTimesWay	= 1343 -- 试炼加次数方式
eUIID_ActivityAddTimesByItem = 1344 --道具加试炼次数
--eUIID_CatchSpiritAnimate	= 1345 -- 鬼岛驭灵技能学习动画
eUIID_CatchSpiritGuide		= 1345 -- 鬼岛驭灵指导ui
eUIID_ShowPlayerProgress	= 1346 -- 查看他人成长界面
eUIID_ShowPlayerPetXinfa	= 1347 -- 查看他人宠物心法
eUIID_FirstClearReward		= 1348 -- 首通奖励
eUIID_SpringRollMain			= 1371 -- 新春灯券主界面
eUIID_SpringRollQuiz			= 1373 -- 新春灯券猜谜
eUIID_SpringRollBuy				= 1374 -- 新春灯券购买

eUIID_OutCareerPractice		= 1400 -- 外传职业历练入口
eUIID_BiographyTask			= 1401 -- 外传职业历练任务
eUIID_BiographySkills		= 1402 -- 外传职业技能
eUIID_BiographyQigong		= 1403 -- 外传职业心法
eUIID_BiographyMapExit		= 1404 -- 外传职业副本倒计时
eUIID_BiographySkillsUnlock = 1405 -- 外传职业技能解锁动画
eUIID_BiographyAnimate		= 1406 -- 外传职业进入试炼动画
eUIID_BiographyCareerMap	= 1407 -- 外传职业试炼副本小地图
eUIID_NewQueryRoleFeature	= 1408 -- 新版查看他人信息面板
eUIID_SpyStoryHelp			= 1409 -- 密探风云帮助
eUIID_MessageBox5			= 1410 -- 提示选择弹窗
eUIID_ShowFriendsFashionTips= 1411 -- 查看他人时装
eUIID_PetDungeonTip			= 1412 -- 宠物试炼提示
eUIID_FactionFightExplain	= 1413 -- 帮派战规则说明
eUIID_MazeBattleExplain     = 1414 -- 天魔迷宫规则说明
eUIID_FestivalTaskAccept	  = 1446 -- 新节日任务接取界面
eUIID_FestivalTaskCommit	  = 1447 -- 新节日任务捐赠界面
eUIID_FestivalActivityUI	  = 1448 -- 新节日任务捐赠界面
eUIID_FestivalScoreBoxTips    = 1449 -- 捐赠进度宝箱奖励Tips
eUIID_SpringRollTips		= 1505 -- 新春灯券提示
eUIID_JnCoinBuyTips			= 1507 -- 鼠年纪念币购买
eUIID_ExChangeCoin			= 1508 -- 纪念币万能币兑换界面
eUIID_ExposeLetter			= 12106	--检视密信UI
eUIID_MatchToken			= 12107	--重合令牌UI
eUIID_AtAnyMomentAnimate	= 70001 --随时副本动画
eUIID_AnyTimeAnimate		= 70003 --随时副本新动画
eUIID_MarryHelp			= 70004   --姻缘称谓
-------------------------------------------------------
--ui local z order
eUIO_BOTTOM			    = 1;
eUIO_NORMAL			    = 2; -- default z order
eUIO_TOP			    = 3;
eUIO_TOP_MOST			= 4;
eUIO_LEADBOARDS			= 5;--强制指引界面需要在各种操作层的上面，但需比tips界面的低，此层只用于各种指引的显示，其他界面禁止使用
eUIO_BOARDTOP			= 6;--需要在各种指引界面操作层的上面，此层只用于极少数，其他界面禁止乱使用
eUIO_TIPS			    = 7;--tips界面需要在最上层，此层只给tips用，其他界面禁止使用
eUIO_CONNECTINGSTATE    = 8;--CONNECTINGSTATE仅用于断线重连  其他界面禁止使用

eUIType_MAIN = 1

local eFontMaxMemory	= 1024 * 2;
local eFontFreeTick		= 1000;
local eUpdateTickLine	= 10 --60 * 10; -- 10分钟

local eUITexMaxMemory	= 1024 * 1024 * 4;

local eUI_DESKTOP_TYPE_NORMAL = 1;
local eUI_DESKTOP_TYPE_SPECIAL = 2;


local i3k_ui_map =
{
	[eUIID_Loading]			= { name = "loading", layout = "loading", order = eUIO_TIPS },
	[eUIID_Login]			= { name = "login" , layout = "dl" },
	[eUIID_GameNotice]			= { name = "game_notice", layout = "gg", order = eUIO_TOP_MOST },
	[eUIID_Main]			= { name = "main", layout = "zjm", relevance = { eUIID_XB, eUIID_DB, eUIID_DBF } },--, uitypes = {[eUIType_MAIN] = true}},
	-- new battle
	[eUIID_BattleBase]       = { name = "battleBase",layout = "xzd",relevance = { eUIID_Yg }},
	[eUIID_BattleBoss]		 = {name = "battle_boss", layout = "zdbosspm"},
	[eUIID_BattleTask]       = { name = "battleTask",layout = "dyjd"},
	[eUIID_BattleTeam]       = { name = "battleTeam",layout = "rwjd"},
	[eUIID_BattlePets]       = { name = "battlePets",layout = "ybjd"},
	[eUIID_BattleNPChp]      = { name = "battleNPChp",layout = "xgxt"},
	[eUIID_BattleBossHp]     = { name = "battleBossHp",layout = "bossxt"},
	[eUIID_BattleHeroHp]     = { name = "battleHeroHp",layout = "wjxt"},
	[eUIID_BattleFuben]      = { name = "battleFuben",layout = "fbzx"},
	[eUIID_BattleDrug]       = { name = "battleDrug",layout = "ypbz"},
	[eUIID_BattleOfflineExp]       = { name = "battleOfflineExp",layout = "lxsydh"},
	[eUIID_BattleTXFinishTask]       = { name = "battleTXFinishTask",layout = "wctx"},
	[eUIID_BattleTXAcceptTask]       = { name = "battleTXAcceptTask",layout = "jqtx"},
	[eUIID_BattleTXUpLevel]   = { name = "battleTXUpLevel", layout = "sjtx" , order = eUIO_TOP_MOST},
--	[eUIID_BattleRoom]       = { name = "battleRoom",layout = "bossdh"},
	[eUIID_BattleFight]       = { name = "battleFight",layout = "kaizhan"},
	[eUIID_BattleEquip]       = { name = "battleEquip",layout = "czb"},
	[eUIID_BattleProcessBar]       = { name = "battleProcessBar",layout = "jdt"},
	[eUIID_BattleShowExp]       = { name = "battleShowExp",layout = "pz"},
	[eUIID_BattleLowBlood]		= { name = "battleShowLowBlood",layout = "xueld", order = eUIO_BOTTOM},
	[eUIID_BattleEntrance]  = { name = "battleEntrance", layout = "kja"},
	[eUIID_BattleMiniMap]   = { name = "battleMiniMap", layout = "zdrw"},
	[eUIID_BattleFuncPrompt]       = { name = "battlefuncPrompt",layout = "gnjs",order = eUIO_TOP_MOST},
	[eUIID_BattleUnlockSkill] = { name = "battleUnlockSkill", layout = "jndh"},
	[eUIID_BattleSkillItem] = { name = "battleSkillItem" , layout = "jndj"},
	-- [eUIID_Mask]			= { name = "mask", layout = "zz", order = eUIO_BOTTOM },
	[eUIID_Yg]				= { name = "yg", layout = "yg" },
	--[eUIID_SetView]			= { name = "setView", layout = "sz" },
	[eUIID_Tips]			= { name = "tips", layout = "tips2", order = eUIO_TIPS},
	[eUIID_Bag]				= { name = "bag", layout = "bg",order = eUIO_TOP_MOST, isPad = true },--uitypes = {[eUIType_MAIN] = true} },
	[eUIID_CSelectChar]		= { name = "create_char_sel_class", layout = "xxjs", },-- uitypes = {[eUIType_MAIN] = true}},
--	[eUIID_CCreateChar]		= { name = "create_char", layout = "qm" },
	[eUIID_SelChar]			= { name = "xr", layout = "xjs2" },
	[eUIID_SaleItems]		= { name = "sale_items", layout = "djcs",order = eUIO_TOP_MOST  },
	[eUIID_EquipTips]		= { name = "equip_info", layout = "zbtips",order = eUIO_TOP_MOST },
	--[eUIID_CommonTips]		= { name = "common_tips", layout = "cs1" ,order = eUIO_TOP_MOST },
	[eUIID_SaleItemBat]		= { name = "sale_items_bat", layout = "plcs",order = eUIO_TOP_MOST  },
--	[eUIID_ZB]				= { name = "zb", layout = "zb" },
	[eUIID_EscortAction]				= { name = "escort_action", layout = "zdyb" },
	[eUIID_EscortHelpTips]				= { name = "escort_help_tips", layout = "zdqyxx" },
	[eUIID_EscortForHelp]				= { name = "escort_for_help", layout = "qyxx" },
	[eUIID_EscortAward]				= { name = "escort_award", layout = "ybjl", order = eUIO_TOP_MOST },
--	[eUIID_YB]				= { name = "yb", layout = "yb" },
	[eUIID_XB]				= { name = "xb", layout = "zjm2" },
	[eUIID_DB]				= { name = "db", layout = "db" ,order = eUIO_TOP_MOST},
	[eUIID_DBF]				= { name = "dbf", layout = "dbf" ,order = eUIO_TOP},
--	[eUIID_Return]			= { name = "return", layout = "ht", order = eUIO_TOP_MOST },
	[eUIID_FBLB]			= { name = "dungeon_sel", layout = "fb",order = eUIO_TOP, isPad = true },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_Email]			= { name = "email", layout = "yj", order = eUIO_TOP_MOST},
	[eUIID_StrengEquip]		= { name = "equip_streng", layout = "zbqh2", isPad = true},--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_MessageBox1]		= { name = "messagebox1", layout = "cs2", order = eUIO_TOP_MOST },
	[eUIID_MessageBox2]		= { name = "messagebox2", layout = "cs1", order = eUIO_TOP_MOST },
	[eUIID_StrengTips]		= { name = "streng_tips", layout = "tzjl", order = eUIO_TOP_MOST },
	[eUIID_RoleLy]			= { name = "role_property",layout = "yx", isPad = true },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_RoleLy2]			= { name = "role_property",layout = "yx2", order = eUIO_TOP_MOST, isPad = true },
	[eUIID_SkillLy]			= { name = "skill",layout = "jnjm2", isPad = true },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_UpSkillTips]		= {name = "up_skill_tips",layout = "jnsj",order = eUIO_TOP_MOST},
	[eUIID_XinFa]			= {name = "xinfa",layout = "xfjm", isPad = true },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_Help]			= {name = "help",layout = "bz",order = eUIO_TOP_MOST},
	[eUIID_SetBlood]		= {name = "set_blood",layout = "szjm",order = eUIO_TOP_MOST},
	[eUIID_Task]			= {name = "task",layout = "rw",order = eUIO_TOP_MOST},
	[eUIID_Jewel]			= {name = "equip_gem_inlay", layout = "bsxt2", isPad = true },--uitypes = {[eUIType_MAIN] = true}},
	--[eUIID_Jewel]			= {name = "jewel", layout = "bsxt" ,uitypes = {[eUIType_MAIN] = true}},
	[eUIID_ShenBing]		= {name = "shen_bing", layout = "sbjm", isPad = true },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_BuyTips]			= {name = "buy_tips", layout = "djgm" ,order = eUIO_TOP_MOST},
	[eUIID_GetTips]			= {name = "get_tips", layout = "hdtj",order = eUIO_TOP_MOST },
	--[eUIID_JewelUpdate]		= {name = "jewelUpdate", layout = "bssj2", order = eUIO_TOP_MOST },
	[eUIID_ShenBingSkillTips]		= {name = "shen_bing_skill_tips", layout = "sbtips"},
	[eUIID_Dialogue1]		= {name = "dialogue1", layout = "db1", order = eUIO_TOP_MOST},
	--[eUIID_Dialogue2]		= {name = "dialogue2", layout = "db2"},
	[eUIID_Dialogue3]		= {name = "dialogue3", layout = "db3", order = eUIO_TOP_MOST},
	[eUIID_Dialogue4]		= {name = "dialogue4", layout = "db4", order = eUIO_TOP_MOST},
	[eUIID_RepairEquipTips]		= {name = "repair_equip_tips", layout = "xlzb",order = eUIO_TOP_MOST},
	[eUIID_SuiCong]			= {name = "new_sui_cong", layout = "scjm", isPad = true },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_PetAchievement]		= {name = "petAchievement", layout = "sccj",order = eUIO_TOP_MOST},
	--[eUIID_SuicongPlay]			= {name = "suicong_play_tips", layout = "czsz",order = eUIO_TOP },
	[eUIID_SuicongSkillTips]			= {name = "suicong_skill_tips", layout = "scjn", order = eUIO_TOP_MOST},
	[eUIID_SuicongUpSkillLevel]			= {name = "suicongUpSkillLevel", layout = "scsj", order = eUIO_TOP_MOST},
	[eUIID_SuicongMaxSkillLevel]		= {name = "suicongMaxSkillLevel", layout = "scsjm", order = eUIO_TOP_MOST},
	[eUIID_SuicongBreakTips]			= {name = "suicong_upbreakskill_tips", layout = "sctp",order = eUIO_TOP_MOST},
	[eUIID_DungeonBonus]			= {name = "dungeon_bonus", layout = "sljs",order = eUIO_TOP_MOST},
	[eUIID_PlayerRevive]			= {name = "role_revive", layout = "fhjm",order = eUIO_BOARDTOP},
	[eUIID_RoleTips]			= {name = "role_tips", layout = "qhjc", order = eUIO_TOP_MOST},
	[eUIID_Danyao]			= {name = "danyao_tips", layout = "dyjc", order = eUIO_TOP_MOST},
	[eUIID_Team]			= {name = "team", layout = "zdjm"},
	[eUIID_CreateTeam]		= {name = "createTeam", layout = "cjdw"},
	[eUIID_CreateRoom]		= {name = "create_room", layout = "fbdw",order = eUIO_TOP_MOST},
	[eUIID_MyTeam]			= {name = "myTeam", layout = "wddw"},
	[eUIID_Transfrom1]		= {name = "transfrom1", layout = "zhzh", order = eUIO_TOP_MOST},
	[eUIID_Transfrom2]		= {name = "transfrom2", layout = "jczh", order = eUIO_TOP_MOST},
	[eUIID_Transfrom3]		= {name = "transfrom3", layout = "jczh2", order = eUIO_TOP_MOST},
	[eUIID_TransfromSucceedTips]		= {name = "transfrom_succeed_tips", layout = "zzcg",},
	[eUIID_TransfromSkillTips]		= {name = "transfrom_skill_tips", layout = "zzjntips", order = eUIO_TOP_MOST},
	[eUIID_Wjxx]			= {name = "wjxx", layout = "wjxx", order = eUIO_TOP_MOST},
	[eUIID_GiveItem]			= {name = "giveItem", layout = "szzs", order = eUIO_TOP_MOST},
	--[eUIID_TeamApply]		= {name = "teamApply", layout = "cs3", order = eUIO_TOP_MOST},
	[eUIID_WIPE]		= {name = "wipe", layout = "fbsd",order = eUIO_TOP_MOST},
	[eUIID_WIPEAward]		= {name = "wipe_award", layout = "sdwc",order = eUIO_TOP_MOST},
	[eUIID_SuitEquip]		= {name = "suit_equip", layout = "tzjm",order = eUIO_TOP_MOST},
	[eUIID_SuicongDungeonPlay]		= {name = "suicong_dungeon_play", layout = "sccz",order = eUIO_TOP_MOST},
	[eUIID_Bangpai]			= {name = "bprk", layout = "bprk",order = eUIO_TOP_MOST, },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_CreateFaction]	= {name = "createfaction", layout = "bpcj",order = eUIO_TOP_MOST},
	[eUIID_JoinFaction]		= {name = "joinfaction", layout = "bpsq",order = eUIO_TOP_MOST, },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_InviteFriends]	= {name = "inviteFriends", layout = "yqhy",order = eUIO_TOP_MOST},
	[eUIID_RoomTips]		= {name = "room_tips", layout = "wjxx2",order = eUIO_TOP_MOST},
	[eUIID_InviteLayer]		= {name = "invite_layer", layout = "yqhy2",order = eUIO_TOP_MOST},
	[eUIID_FactionLayer]		= {name = "faction_layer", layout = "bpgl",order = eUIO_TOP_MOST},
	[eUIID_FactionList]		= {name = "faction_list", layout = "bplb",order = eUIO_TOP_MOST},
	[eUIID_FactionMain]		= {name = "faction_main", layout = "bpjm",order = eUIO_TOP_MOST, },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_SP_DEMO]			= {name = "sp_demo", layout = "demo",order = eUIO_TOP_MOST},
	[eUIID_FactionUpSpeed]		= {name = "faction_upspeed", layout = "bpsj",order = eUIO_TOP_MOST},
	[eUIID_FactionSKill]		= {name = "faction_skill", layout = "bpjn",order = eUIO_TOP_MOST},
	[eUIID_FactionResearch]		= {name = "factionResearch", layout = "xzywy",order = eUIO_TOP_MOST},
	[eUIID_FactionWorship]		= {name = "faction_worship", layout = "bpmb",order = eUIO_TOP_MOST},
	[eUIID_FactionContribution]		= {name = "faction_contribution", layout = "bpjx",order = eUIO_TOP_MOST},
	[eUIID_FactionControl]		= {name = "faction_control", layout = "bpgl2",order = eUIO_TOP_MOST},
	[eUIID_FactionControlLayer]		= {name = "faction_control_layer", layout = "bpgl3",order = eUIO_TOP_MOST},
	[eUIID_FactionControlMember]		= {name = "faction_control_member", layout = "bpcygl",order = eUIO_TOP_MOST},
	[eUIID_FactionDine]		= {name = "faction_dine", layout = "qkcf",order = eUIO_TOP_MOST},
	[eUIID_MercenaryRevive]		= {name = "mercenary_revive", layout = "scfh",order = eUIO_TOP_MOST},
	[eUIID_FactionEatDine]		= {name = "faction_eat_dine", layout = "bpyx",order = eUIO_TOP_MOST},
	[eUIID_FactionDineTips]		= {name = "faction_dine_tips", layout = "qkcf2",order = eUIO_TOP_MOST},
	--[eUIID_FactionStore]		= {name = "faction_store", layout = "bpsd",order = eUIO_TOP_MOST},
	--[eUIID_ESCORTSTORE]		= {name = "escort_shop", layout = "bpsd",order = eUIO_TOP_MOST},
	--[eUIID_FactionStoreBuy]		= {name = "faction_store_buy", layout = "bpdjgm",order = eUIO_TOP_MOST},
	--[eUIID_EscortStoreBuy]		= {name = "escort_shop_by", layout = "bpdjgm",order = eUIO_TOP_MOST},
	[eUIID_DailyTask]		= {name = "dailyTask", layout = "rch", order = eUIO_TOP_MOST, },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_NpcDialogue]		= {name = "npc_dialogue", layout = "db5",order = eUIO_TOP_MOST},
	[eUIID_FactionDungeon]		= {name = "faction_dungeon", layout = "bpfb",order = eUIO_TOP_MOST},
	[eUIID_FactionDungeonSchedule]		= {name = "faction_dungeon_schedule", layout = "zdbpfb",order = eUIO_TOP_MOST},
	[eUIID_FactionTeamDungeonDamageRank]		= {name = "faction_team_dungeon_damage_rank", layout = "bpfbph",order = eUIO_TOP_MOST},
	[eUIID_FactionTeamDungeonBtn]		= {name = "faction_team_dungeon_btn", layout = "zdbpfb2",order = eUIO_TOP_MOST},
	[eUIID_FactionDungeonFenpei]		= {name = "faction_dungeon_fenpei", layout = "bffpb",order = eUIO_TOP_MOST},
	[eUIID_FactionDungeonLayer]		= {name = "faction_dungeon_layer", layout = "bfjm",order = eUIO_TOP_MOST},
	[eUIID_FactionDungeonAward]		= {name = "faction_dungeon_award", layout = "bffp",order = eUIO_TOP_MOST},
	[eUIID_FactionDungeonDetail]		= {name = "faction_dungeon_detail", layout = "bfsq",order = eUIO_TOP_MOST},
	[eUIID_FactionDungeonBattleOver]		= {name = "faction_dungeon_battle_over", layout = "bfjg",order = eUIO_TOP_MOST},
	[eUIID_FactionTeamDungeonOver]		= {name = "faction_team_dungeon_over", layout = "bpfbjs",order = eUIO_TOP_MOST},
	[eUIID_FactionCreed]		= {name = "faction_creed", layout = "xgxy",order = eUIO_TOP_MOST},
	[eUIID_FactionMemberDetail]		= {name = "faction_member_detail", layout = "bpcyxx",order = eUIO_TOP_MOST},
	[eUIID_Chat]				= {name = "chat", layout = "ltxt", order = eUIO_TOP_MOST},
	[eUIID_FactionSuicongPlay]				= {name = "faction_suicong_play", layout = "bpsccz", order = eUIO_TOP_MOST},
	[eUIID_FactionDamageRank]				= {name = "faction_damage_rank", layout = "bfph", order = eUIO_TOP_MOST},
	[eUIID_FactionSet]				= {name = "faction_set", layout = "bpsz2", order = eUIO_TOP_MOST},
	[eUIID_ChatFC]				= {name = "chatFC", layout = "lttx", order = eUIO_TOP_MOST},
	[eUIID_CreateKungfu]				= {name = "create_kungfu", layout = "zcwg", order = eUIO_TOP_MOST},
	[eUIID_FactionTask]				= {name = "faction_task", layout = "bprw", order = eUIO_TOP_MOST},
	[eUIID_PriviteChat]			= {name = "priviteChat", layout = "sljm", order = eUIO_TOP_MOST},
	[eUIID_PKMode]				= {name = "role_pk", layout = "pk", order = eUIO_TOP},
	[eUIID_CreateKungfuSuccess]				= {name = "create_kungfu_success", layout = "wgqm", order = eUIO_TOP_MOST},
	[eUIID_ChangeSkillIcon]				= {name = "change_skill_icon", layout = "xgtp", order = eUIO_TOP_MOST},
	[eUIID_KungfuFull]				= {name = "kungfu_full", layout = "wggl", order = eUIO_TOP_MOST},
	[eUIID_SelectBq]			= {name = "selectBq", layout = "ltbq", order = eUIO_TOP_MOST},
	[eUIID_KungfuDetail]				= {name = "kungfu_detail", layout = "wgxq", order = eUIO_TOP_MOST},
	[eUIID_KungfuUplvl]				= {name = "kungfu_uplvl", layout = "wgsj", order = eUIO_TOP_MOST},
	[eUIID_KungfuShowOff]           = {name = "kungfu_showOff",layout = "wgxy", order = eUIO_TOP_MOST},
	[eUIID_KungfuBuyCount]				= {name = "kungfu_buy_count", layout = "gmcs", order = eUIO_TOP_MOST},
	--[eUIID_Arena]					= {name = "arena", layout = "1v1jjc", },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_ArenaRank]				= {name = "arenaRank", layout = "11jjph", order = eUIO_TOP_MOST},
	[eUIID_ArenaEnemyLineup]		= {name = "arenaEnemyLineup", layout = "jjds", order = eUIO_TOP_MOST},
	[eUIID_ArenaSetBattle]			= {name = "setBattle", layout = "11jjxr", order = eUIO_TOP_MOST},
	[eUIID_FactionGetAward]				= {name = "faction_get_award", layout = "bprwjl", order = eUIO_TOP_MOST},
	[eUIID_SuitAttributeTips]				= {name = "suit_attribute_tips", layout = "tzjm2", order = eUIO_TOP_MOST},
	[eUIID_ArenaSetLineup]			= {name = "setLineup", layout = "jjxr1", order = eUIO_TOP_MOST},
	[eUIID_ArenaWin]				= {name = "arenaWin", layout = "jjsl", order = eUIO_TOP_MOST},
	[eUIID_ArenaLose]				= {name = "arenaLose", layout = "jjsb", order = eUIO_TOP_MOST},
	--[eUIID_ClanArmy]				= {name = "clan_army", layout = "zmbd", order = eUIO_TOP_MOST},
	[eUIID_Production]				= {name = "faction_production", layout = "zmsc", order = eUIO_TOP, isPad = true },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_ShenBingPropertyTips]    = {name = "shen_bing_property_tips", layout = "sbtips2" },
	[eUIID_ArenaLogs]					= {name = "arenaLogs", layout = "11jjzb", order = eUIO_TOP_MOST},
	[eUIID_ArenaIntegral]				= {name = "arenaIntegral", layout = "jfjl", order = eUIO_TOP_MOST},
	[eUIID_ArenaCheckLineup]			= {name = "arenaCheckLineup", layout = "11jjjg", order = eUIO_TOP_MOST},
	--[eUIID_ArenaShop]					= {name = "arenaShop", layout = "bpsd", order = eUIO_TOP_MOST},
	[eUIID_ArenaRankBest]				= {name = "arena_rank_best", layout = "11jjzg", order = eUIO_TOP_MOST},
	--[eUIID_ArenaBuyTimes]				= {name = "arena_buy_times", layout = "cs4"},
	--[eUIID_ProductionBuyTimes]				= {name = "seperationpower_buy_times", layout = "cs4", order = eUIO_TOP_MOST},
	[eUIID_DungeonFailed]				= {name = "dungeon_failed", layout = "sbjs", order = eUIO_TOP_MOST},
	[eUIID_BuyCoin]						= {name = "buy_coin", layout = "djs",order = eUIO_TOP_MOST},
	[eUIID_BuyCoinBat]					= {name = "buy_coin_bat", layout = "djs2",order = eUIO_TOP_MOST},
	[eUIID_VipSystem]					= {name = "vip_system", layout = "viptq", order = eUIO_TOP_MOST},
	[eUIID_ArenaHelp]					= {name = "arena_help", layout = "jjgz2", order = eUIO_TOP_MOST},
	[eUIID_FactionChangeName]				= {name = "faction_changge_name", layout = "xgmz", order = eUIO_TOP_MOST},
	[eUIID_FactionChangeLevel]				= {name = "faction_changge_level", layout = "xgbpdj", order = eUIO_TOP_MOST},
	[eUIID_FactionQq]					= {name = "faction_qq", layout = "bpqq", order = eUIO_TOP_MOST},
	[eUIID_FactionAppilyNoticeSet]			= {name = "faction_appily_notice_set", layout = "bpsqsz", order = eUIO_TOP_MOST},
	--[eUIID_FactionChangeIcon]				= {name = "faction_changge_icon", layout = "xgbptb", order = eUIO_TOP_MOST},
	[eUIID_BuyVit]						= {name = "buy_vit", layout = "gmtl",order = eUIO_TOP_MOST},
	[eUIID_ChannelPay]					= {name = "channel_pay", layout = "czjm", order = eUIO_TOP_MOST},
	[eUIID_VitTips]						= {name = "vit_tips", layout = "tltips", order = eUIO_TOP_MOST},
	[eUIID_ArenaSwallow]				= {name = "common_swallow_screen", layout = "zhezhao"},
	[eUIID_Activity]					= {name = "activity", layout = "hdlb", isPad = true },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_ActivityDetail]				= {name = "activity_detail", layout = "hdlx1", order = eUIO_TOP_MOST},
	--[eUIID_ArenaShopBuyTips]			= {name = "arena_shop_buy_tips", layout = "bpdjgm", order = eUIO_TOP_MOST},
	--[eUIID_CheckItem]					= { name = "check_item", layout = "djtips" },
	[eUIID_SignIn]						= {name = "sign_in", layout = "qd",order = eUIO_TOP_MOST},
	[eUIID_SignInAward]					= {name = "sign_in_award", layout = "qdjl",order = eUIO_TOP_MOST},
	[eUIID_VipStore]				= {name = "vip_store", layout = "ybsc" ,order = eUIO_TOP_MOST, isPad = true},--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_FactionDungeonRule]			= {name = "faction_dungeon_rule",layout = "bfgz",order = eUIO_TOP_MOST},
	[eUIID_BossSelect]					= {name = "boss_select", layout = "bossdd", order = eUIO_TOP_MOST},
	[eUIID_UseItems]					= { name = "use_items", layout = "djsy",order = eUIO_TOP_MOST  },
	[eUIID_FactionGetWorshipAward]					= { name = "faction_get_worship_award", layout = "mbjl",order = eUIO_TOP_MOST  },
	[eUIID_ActivityPets]				= {name = "activity_pets", layout = "hdsccz", order = eUIO_TOP_MOST},
	[eUIID_VIP_STROE_BUY]				= {name = "vip_store_buy", layout = "djgm2", order = eUIO_TOP_MOST},
	[eUIID_SceneMap]					= {name = "scene_map", layout = "sjdt",order = eUIO_TOP_MOST},
	[eUIID_ItemInfo]				= {name = "item_info", layout = "wptips", order = eUIO_TOP_MOST},
	--[eUIID_ActivityTips]			= {name = "activity_tips", layout = "cs4"},
	[eUIID_BagItemInfo]		= { name = "bag_item_info", layout = "djtips",order = eUIO_TOP_MOST },
	[eUIID_EquipUpStar]		= {name = "equip_up_star", layout = "zbsx", isPad = true },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_WorldMap]				= {name = "world_map", layout = "sjdt2",order = eUIO_TOP_MOST },
	[eUIID_CommmonStore]				= {name = "common_store", layout = "tqsd", order = eUIO_TOP_MOST},
	[eUIID_CommmonStoreBuy]			= {name = "common_store_buy", layout = "djgm" ,order = eUIO_TOP_MOST},
	[eUIID_GemUpLevel]		= {name = "gem_up_level", layout = "bssj2", order = eUIO_TOP_MOST },
	[eUIID_Auction]					= {name = "auction", layout = "pmh", isPad = true },--uitypes = {[eUIType_MAIN] = true}},
--	[eUIID_TaskFinished]	= {name = "taskfinished", layout = "wctx", },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_Fuli]            =  {name = "fu_li_new", layout = "yyhd",order = eUIO_TOP_MOST},
--	[eUIID_TaskAnimation]				= {name = "task_animation", layout = "jqtx"},
	[eUIID_SaleEquip]				= {name = "sale_equip", layout = "zbsmjm", order = eUIO_TOP_MOST},
	[eUIID_SaleProp]				= {name = "sale_prop", layout = "djsmjm", order = eUIO_TOP_MOST},
	[eUIID_FactionNewChangeIcon]	= {name = "faction_new_change_icon",layout = "xgbptb2", order = eUIO_TOP_MOST},
	[eUIID_AuctionPutOff]			= {name = "auction_put_off", layout = "pmxj", order = eUIO_TOP_MOST},
	[eUIID_Steed]					= {name = "steed", layout = "zq", isPad = true },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_OtherTest]				= {name = "other_test", layout = "test", order = eUIO_TOP_MOST},
	[eUIID_BuyDungeonTimes]			= {name = "buy_dungeon_times", layout = "gmfbcs", order = eUIO_TOP_MOST},
	[eUIID_SteedPractice]			= {name = "steed_practice", layout = "zqxl2",  order = eUIO_TOP_MOST},
	[eUIID_SteedStar]				= {name = "steed_star", layout = "zqsx", order = eUIO_TOP_MOST},
	[eUIID_SteedSkill]				= {name = "steed_skill", layout = "zqqs", order = eUIO_TOP_MOST, },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_SteedActSkill]			= {name = "steed_act_skill", layout = "zqjh", order = eUIO_TOP_MOST},
	[eUIID_FactionEmail]				= {name = "faction_email", layout = "bpyj", order = eUIO_TOP_MOST},
	[eUIID_GodEye]				= {name = "godeye", layout = "godeye", order = eUIO_TOP_MOST},
	[eUIID_ActivityResult]			= {name = "activity_result", layout = "hdjs", order = eUIO_TOP_MOST},
	[eUIID_Friends]			= {name = "friends", layout = "hy" ,order = eUIO_TOP_MOST},
	[eUIID_UseLimitConsumeItems]		= { name = "limit_consume_items", layout = "djsy2",order = eUIO_TOP_MOST  },
	[eUIID_UseLimitItems]				= { name = "limit_items", layout = "djsy3",order = eUIO_TOP_MOST  },
	[eUIID_SteedHuanhua]			= {name = "steed_huanhua", layout = "zqhh", order = eUIO_TOP_MOST},
	[eUIID_UseItemGainItems]			= { name = "use_item_gain_items", layout = "sydjjl",order = eUIO_TOP_MOST  },
	[eUIID_UseItemGainMoreItems]			= { name = "use_item_gain_m_items", layout = "sydjjl2",order = eUIO_TOP_MOST  },
	[eUIID_SteedPracticeTips]		= {name = "steed_practice_tips", layout = "zqtips2", order = eUIO_TOP_MOST},
	[eUIID_GetFriendsMoredec]		= {name = "friendsFC", layout = "hygn", order = eUIO_TOP_MOST},
	[eUIID_Wait]				= { name = "wait", layout = "dxcl", order = eUIO_CONNECTINGSTATE},
	[eUIID_DailyActivity]			=  {name = "daily_Activity", layout = "zxlj",order = eUIO_TOP_MOST},
	[eUIID_ChangePersonState]		= {name = "changeText", layout = "xgzt", order = eUIO_TOP_MOST},
	[eUIID_QueryRoleFeature]		= {name = "queryRoleFeature", layout = "hyxx", order = eUIO_TOP_MOST},
	[eUIID_FashionDress]			= {name = "fashion_dress", layout = "shizhuang", order = eUIO_TOP_MOST,isPad = true},--uitypes = {[eUIType_MAIN] = true} },
	[eUIID_FashionDressTips]		= { name = "fashion_dress_tips", layout = "sztips",order = eUIO_TOP_MOST },
	[eUIID_ShowFriendsEquipTips]		= { name = "friendsEquiptips", layout = "hyzbtips",order = eUIO_TOP_MOST },
	[eUIID_KillCount]			= { name = "kill_number", layout = "kill" },
	[eUIID_ShowEquipTips]			= { name = "show_equip_tips", layout = "zbtips2",order = eUIO_TOP_MOST },
	[eUIID_PutOffEquip]				= {name = "put_off_equip", layout = "zbxj", order = eUIO_TOP_MOST},
	[eUIID_MercenaryPop1]				= {name = "mercenarypop", layout = "qipao", order = eUIO_BOTTOM},
	[eUIID_MercenaryPop2]				= {name = "mercenarypop", layout = "qipao", order = eUIO_BOTTOM},
	[eUIID_MercenaryPop3]				= {name = "mercenarypop", layout = "qipao", order = eUIO_BOTTOM},
	[eUIID_UseAnimateGainItems]			= { name = "package_gift_gain_items", layout = "dhmlb",order = eUIO_TOP_MOST  },
	[eUIID_UseAnimateGainMoreItems]			= { name = "package_gift_gain_m_items", layout = "dhmlb2",order = eUIO_TOP_MOST  },
	[eUIID_VIP_STROE_FASHION_BUY]			= { name = "vip_store_fashion_buy", layout = "szgm",order = eUIO_TOP_MOST  },
	[eUIID_BattleTreasure]				= {name = "battle_treasure", layout = "zdcbt"},
	[eUIID_PowerChange]				= { name = "powerchange", layout = "zltips", order = eUIO_TOP_MOST },
	[eUIID_TreasureScrectBox]			= {name = "treasure_screct_box", layout = "pjmx"},
	[eUIID_GiveFlower]				= {name = "give_flower", layout = "zenghua", order = eUIO_TOP_MOST},
	[eUIID_Charm]				= {name = "charm", layout = "meili", order = eUIO_TOP_MOST},
	[eUIID_MountCollection]				= {name = "mount_collection", layout = "zbcp", order = eUIO_TOP_MOST},
	[eUIID_GetCollection]				= {name = "get_collection", layout = "cbtjl2", order = eUIO_TOP_MOST},
	[eUIID_FriendsCharm]				= {name = "friends_charm", layout = "hyml", order = eUIO_TOP_MOST},
	[eUIID_AnswerQuestions]				= {name = "answer_questions", layout = "qfdt", order = eUIO_TOP_MOST},
	[eUIID_TalkPop1]					= {name = "talk_pop1", layout = "qipao", order = eUIO_BOTTOM},
	[eUIID_TalkPop2]					= {name = "talk_pop2", layout = "qipao", order = eUIO_BOTTOM},
	[eUIID_TalkPop3]					= {name = "talk_pop3", layout = "qipao", order = eUIO_BOTTOM},
	--[eUIID_LeadBoard2]				= {name = "leadboard2", layout = "zhiyin2", order = eUIO_LEADBOARDS},
	[eUIID_FindClue]					= {name = "find_clue", layout = "xiansuo", order = eUIO_TOP_MOST},
	[eUIID_ExploreSpotFailed]			= {name = "explore_spot_failed", layout = "yiwusuohuo", order = eUIO_TOP_MOST},
	[eUIID_ExploreSpotSuccessed]		= {name = "explore_spot_successed", layout = "wcxs", order = eUIO_TOP_MOST},
	[eUIID_NewTips]						= {name = "new_tips", layout = "tips3", order = eUIO_TOP_MOST},
	[eUIID_LuckyWheel]					= {name = "lucky_wheel", layout = "xyzp", order = eUIO_TOP, },--uitypes = {[eUIType_MAIN] = true} },
	[eUIID_LuckyWheel_buy_count]		= {name = "lucky_wheel_buy_count", layout = "gmcs", order = eUIO_TOP_MOST},
	[eUIID_SocialAction]       = { name = "social_action",layout = "dzxx"},
	--[eUIID_Matching]					= {name = "matching", layout = "ppds", order = eUIO_TOP_MOST},
	[eUIID_CONTROLLEAD]				= {name = "controllead", layout = "zhiyin3", order = eUIO_TOP_MOST},
	[eUIID_QuizShowExp]       = { name = "quitShowExp",layout = "pz", order = eUIO_TOP_MOST},
	[eUIID_TournamentRoom]				= {name = "tournament_room", layout = "4v4dw", order = eUIO_TOP_MOST},
	[eUIID_MainTask_SpecialUI]				= {name = "mainTask_specialUI", layout = "zhiyin4", order = eUIO_TOP_MOST},
	[eUIID_TournamentResult]			= {name = "tournament_result", layout = "4v4jg", order = eUIO_TOP_MOST},
	[eUIID_OfflineExpReceive] = {name = "offline_exp_receive", layout = "lxsy", order = eUIO_TOP_MOST},
	[eUIID_EquipSevenTips]				= {name = "equip_seven_tips", layout = "lytips", order = eUIO_TOP_MOST},
	[eUIID_EquipSevenTips2]				= {name = "equip_seven_tips2", layout = "lytips2", order = eUIO_TOP_MOST},
	[eUIID_OtherLongYinInfo]			= {name = "othersLongYinInfo", layout = "lytips3", order = eUIO_TOP_MOST},
	[eUIID_LongYin]				= {name = "longyin", layout = "ly", order = eUIO_TOP_MOST},
	[eUIID_Battle4v4]					= {name = "battle_4v4", layout = "4v4xt"},
	--[eUIID_Arena_Choose]				= {name = "arena_choose", layout = "xzjjc", order = eUIO_TOP_MOST},--uitypes = {[eUIType_MAIN] = true}},
	--[eUIID_ArenaTaoist]					= {name = "arena_taoist", layout = "zxdc", },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_RankList]					= {name = "ranking_list", layout = "rxphb",  order = eUIO_TOP_MOST},
	[eUIID_RankListRoleInfo]			= {name = "ranking_list_RoleInfo", layout = "jsxx",  order = eUIO_TOP_MOST},
	[eUIID_RankListRoleProperty]		= {name = "ranking_list_RoleProperty", layout = "qtxx",  order = eUIO_TOP_MOST},
	[eUIID_RankListRoleSteedSkin]		= {name = "ranking_list_RoleSteedSkin", layout = "qtxx",  order = eUIO_TOP_MOST},
	[eUIID_RankListRoleSteedFight]		= {name = "ranking_list_RoleSteedFight", layout = "qtxx",  order = eUIO_TOP_MOST},
	[eUIID_RankListRoleSteedSpirit]		= {name = "ranking_list_RoleSteedSpirit", layout = "qtxx",  order = eUIO_TOP_MOST},
	[eUIID_RankListRoleSteedEquip]		= {name = "ranking_list_RoleSteedEquip", layout = "qtxx",  order = eUIO_TOP_MOST},
	--[eUIID_TournamentShop]				= {name = "tournament_shop", layout = "bpsd", order = eUIO_TOP_MOST},
	[eUIID_GuideUI]						= {name = "guide_ui", layout = "zhiyin5", order = eUIO_LEADBOARDS},
	[eUIID_TournamentRecord]			= {name = "tournament_record", layout = "4v4ph", order = eUIO_TOP_MOST},
	[eUIID_TournamentChoosePet]			= {name = "tournament_choosePet", layout = "scczhw", order = eUIO_TOP_MOST},
	[eUIID_Empowerment]					= {name = "empowerment", layout = "lilian", order = eUIO_TOP_MOST},
	[eUIID_EmpowermentTips]				= {name = "empowermentTips", layout = "tqll", order = eUIO_TOP_MOST},
	[eUIID_BattleShowExpCoin]			= {name = "battleShowExpCoin", layout = "pz2"},
	[eUIID_Library]						= {name = "library", layout = "cangshu", order = eUIO_TOP_MOST},
	[eUIID_CanWu]                       = {name = "canwu", layout = "canwu", order = eUIO_TOP_MOST},
	[eUIID_CanWuStrat]					= {name = "canwuStart", layout = "wdcw", order = eUIO_TOP_MOST},
	[eUIID_CanWuEnd]					= {name = "canwuEnd", layout = "cwzq", order = eUIO_TOP_MOST},
	[eUIID_PVPShowKill]					= { name = "PVPShowKill",layout = "pz3"},
	[eUIID_TaoistPets]					= {name = "taoist_pets", layout = "sccz2", order = eUIO_TOP_MOST},
	[eUIID_TournamentHelp]				= {name = "tournament_help", layout = "hwgz", order = eUIO_TOP_MOST},
	[eUIID_SelectServer]				= {name = "select_server", layout = "fwqlb", order = eUIO_TOP_MOST},
	[eUIID_TaoistLogs]					= {name = "taoist_logs", layout = "11jjzb", order = eUIO_TOP_MOST},
	[eUIID_TaoistRank]					= {name = "taoist_rank", layout = "zxdcph", order = eUIO_TOP_MOST},
	[eUIID_TaoistWin]					= {name = "taoist_win", layout = "zxdcsl", order = eUIO_TOP_MOST},
	[eUIID_TaoistLose]					= {name = "taoist_lose", layout = "zxdcsb", order = eUIO_TOP_MOST},
	[eUIID_LeadPlot]					= {name = "leadplot", layout = "jqdh", order = eUIO_TOP_MOST},
	[eUIID_ShouSha]						= {name = "battleShowshousha", layout = "shousha", order = eUIO_TOP_MOST},
	[eUIID_PreviewDetailone]			= {name = "previewone", layout = "gnyl", order = eUIO_TOP_MOST},
	[eUIID_PreviewDetailtwo]			= {name = "previewtwo", layout = "gnyl2", order = eUIO_TOP_MOST},
	[eUIID_Fengce]						= {name = "fengce", layout = "fchd", order = eUIO_TOP_MOST},
	[eUIID_RoleTitles]					= {name = "roleTitles", layout = "chenghao",isPad = true },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_RoleTitlesAllProperty]		= {name = "roleTitlesAllProperty", layout = "chtips", order = eUIO_TOP_MOST},
	[eUIID_RoleTitlesProperty]			= {name = "roleTitlesProperty", layout = "chtips2", order = eUIO_TOP_MOST},
	[eUIID_RollNotice]					= {name = "rollNotice", layout = "gdt", order = eUIO_BOARDTOP},
	[eUIID_RolePropertyTips]			= {name = "rolePropertyTips", layout = "tips4", order = eUIO_TOP_MOST},
	[eUIID_PerfectUserdata]				= {name = "perfect_userdata", layout = "wszl2", order = eUIO_TOP_MOST},
	[eUIID_Survey]						= {name = "survey", layout = "yjdy", order = eUIO_TOP_MOST},
	[eUIID_AddDiamond]					= {name = "add_diamond", layout = "pz4", order = eUIO_TOP_MOST},
	[eUIID_HostelGuide1]				= {name = "hostel_guide1", layout = "kzts", order = eUIO_TOP_MOST},
	[eUIID_HostelGuide2]				= {name = "hostel_guide2", layout = "kzts2", order = eUIO_TOP_MOST},
	[eUIID_TopMessageBox1]				= { name = "topMessagebox1", layout = "cs2", order = eUIO_CONNECTINGSTATE },
	[eUIID_TopMessageBox2]				= { name = "topMessagebox2", layout = "cs1", order = eUIO_CONNECTINGSTATE },
	[eUIID_FactionEscort]				= { name = "faction_escort", layout = "yunbiao", order = eUIO_TOP_MOST },
	[eUIID_FactionEscortPath]				= { name = "faction_escort_path", layout = "xzlx", order = eUIO_TOP_MOST },
	[eUIID_SkillFuncPrompt]      	    = { name = "skillfuncPrompt",layout = "jnjs",order = eUIO_TOP_MOST},
	[eUIID_UniqueSkill]					= {name = "uniqueSkill",layout = "jueji", isPad = true },--uitypes = {[eUIType_MAIN] = true}},
	[eUIID_FiveUniquePrestige]			= {name = "fiveUnique_prestige", layout = "wjsw", order = eUIO_TOP_MOST},
	[eUIID_FiveUniqueSelect]			= {name = "fiveUnique_select", layout = "wjxg", order = eUIO_TOP_MOST},
	[eUIID_FiveUniqueExploits]			= {name = "fiveUnique_exploits", layout = "wjzj", order = eUIO_TOP_MOST},
	[eUIID_FiveUniquePets]				= {name = "fiveUnique_pets", layout = "sccz",order = eUIO_TOP_MOST},
	[eUIID_ShenshiExplore]				= {name = "shenshiExplore", layout = "ssrw", order = eUIO_TOP_MOST},
	[eUIID_Secretarea]					= {name = "fiveUnique_secretarea", layout = "mjrw",order = eUIO_TOP_MOST},
	[eUIID_KillTarget]					= { name = "kill_target", layout = "zdwj" },
	[eUIID_FiveUniqueFailed]			= {name = "fiveUnique_failed", layout = "sbjs"},
	[eUIID_FiveUniqueBonus]				= {name = "fiveUnique_bonus", layout = "hdjs"},
	[eUIID_ShenshiBattle]				= {name = "shenshiBattle", layout = "zdss"},
	[eUIID_WorldLine]					= {name = "worldLine_change", layout = "huanxian"},
	[eUIID_WorldLineProcessBar]      	= { name = "worldLine_ProcessBar",layout = "jdt"},
	[eUIID_ForceWarKillNumber]			= { name = "forcewar_showkillnumber", layout = "zdslz" },
	[eUIID_ForceWarResult]				= {name = "forcewar_showresult", layout = "slzzj"},
	--[eUIID_ForceWarMatching]			= {name = "forcewar_matching", layout = "ppds", order = eUIO_TOP_MOST},
	[eUIID_ForceWarMiniMap]   			= { name = "forcewar_miniMap", layout = "slzxdt"},
	[eUIID_ForceWarMap]					= {name = "forcewar_map", layout = "slzdt",order = eUIO_TOP_MOST},
	[eUIID_ForceWarHelp]				= {name = "forcewar_help", layout = "slzgz", order = eUIO_TOP_MOST},
	[eUIID_BreakSceneAni]				= {name = "breaksceneani", layout = "tgdh",desktopType = eUI_DESKTOP_TYPE_SPECIAL},
	[eUIID_transportProcessBar]			= {name = "transportProcessBar",layout = "jdt"},
	[eUIID_MainTaskInsertUI]			= {name = "maintaskInsert",layout = "rwdh"},
	[eUIID_KeepActivity]				= {name = "keep_activity", layout = "dlsl", order = eUIO_TOP_MOST},
	[eUIID_Invite]						= {name = "invite_code", layout = "jhm", order = eUIO_TOP_MOST},
	[eUIID_MonsterPop]					= {name = "monster_pop", layout = "qipao2", order = eUIO_BOTTOM},
	[eUIID_MonsterPop2]					= {name = "monster_pop2", layout = "qipao2", order = eUIO_BOTTOM},
	[eUIID_MonsterPop3]					= {name = "monster_pop3", layout = "qipao2", order = eUIO_BOTTOM},
	[eUIID_TaskShapeshiftingTips]		= {name = "specialmissionTips", layout = "bsrwts", order = eUIO_NORMAL},
	[eUIID_FindwayStateTips]			= {name = "findwayStateTips", layout = "xlz", order = eUIO_TOP},
	[eUIID_ModifyName]					= {name = "modify_name", layout = "xgjsmz", order = eUIO_TOP_MOST},
	[eUIID_ItemMailUI]				    = {name = "bag_item_mail", layout = "xin", order = eUIO_TOP_MOST},
	[eUIID_Compound]					= {name = "compound", layout = "hcjm", order = eUIO_TOP_MOST},
	[eUIID_TreasureAnis]				= {name = "treasure_anis", layout = "hddh", order = eUIO_TOP_MOST},
	[eUIID_GiveFlowerEffects]			= {name = "give_flower_effects", layout = "shtx", order = eUIO_TOP_MOST},
	[eUIID_SnapShot]                    = {name = "snapShot", layout = "pzjm"},
	[eUIID_BindEffect]					= {name = "bind_effect", layout = "cjtx1", order = eUIO_BOTTOM},
	[eUIID_BindEffect2D]				= {name = "bind_effect2d", layout = "cjtx2", order = eUIO_BOTTOM},
	[eUIID_Volume]						= {name = "chatVolume", layout = "yljm", order = eUIO_TOP_MOST},
	[eUIID_TiShi]                       = {name = "shen_bing_ti_shi", layout = "sbts", order =  eUIO_TOP_MOST},
	[eUIID_BillBoard]                   = {name = "bill_board",layout = "bgbjm", order = eUIO_TOP_MOST},
	[eUIID_BillBoard_Editor]            = {name = "bill_board_editor",layout = "xbgjm", order = eUIO_TOP_MOST},
	[eUIID_BillBoard_Revise]            = {name = "bill_board_revise",layout = "xgbgjm",order = eUIO_TOP_MOST},
	[eUIID_BillBoard_CL]		        = {name = "bill_board_common_layer", layout = "cs1" ,order = eUIO_TOP_MOST},
	[eUIID_Schedule]		        	= {name = "schedule", layout = "rcb" ,order = eUIO_TOP_MOST},
	[eUIID_Schedule_Detail]				= {name = "schedule_detail", layout = "rcbtc", order = eUIO_TOP_MOST},
	[eUIID_Under_Wear]				    = {name = "underwear", layout = "njjm", order = eUIO_TOP_MOST},
	[eUIID_ArenaList]					= {name = "arena_list", layout = "jjlb", isPad = true},
	[eUIID_ChooseAutoStreng]			= {name = "chooseAutoStreng", layout = "qhxz", order = eUIO_TOP_MOST},
	[eUIID_Under_Wear_Unlock]		    = {name = "underwear_unlock", layout = "njjs", order = eUIO_TOP_MOST},
	[eUIID_Under_Wear_update]		    = {name = "underwear_update", layout = "njsj", order = eUIO_TOP_MOST},
	[eUIID_KickMember]					= {name = "kick_member", layout = "zqtr", order = eUIO_TOP_MOST},
	--[eUIID_Battle_Entrance]             = {name = "battle_entrance", layout = "kja", order = eUIO_CONNECTINGSTATE},
	[eUIID_MapName]                     = {name = "mapName", layout = "cjmz", order = eUIO_TOP_MOST},
	[eUIID_Under_Wear_upStage]          = {name = "underwear_upStage", layout = "njsj2", order = eUIO_TOP_MOST},
	[eUIID_PetTask]						= {name = "petTask", layout = "hxrw", order = eUIO_TOP_MOST},
	[eUIID_Under_Wear_showWuXun]	    = {name = "underwear_showWuXun", layout = "njwxzf", order = eUIO_TOP_MOST},
	[eUIID_Under_Wear_Talent]	        = {name = "underwear_talent", layout = "njtf", order = eUIO_TOP_MOST},
	[eUIID_Under_Wear_Talent_Point]	    = {name = "underwear_talentPoint", layout = "njtfjdtc", order = eUIO_TOP_MOST},
	[eUIID_Under_Wear_Talent_Point_Reset] = {name = "underwear_talentPoint_reset", layout = "njcztc", order = eUIO_TOP_MOST},
	[eUIID_Under_Wear_Rune] 			= {name = "underwear_rune", layout = "njfw", order = eUIO_TOP_MOST},
	[eUIID_Push_Rune] 			        = {name = "push_rune", layout = "djcs", order = eUIO_TOP_MOST},
	[eUIID_RuneBagItemInfo] 			= {name = "runeBag_Item_Info", layout = "njdjfwtc", order = eUIO_TOP_MOST},
	[eUIID_RuneBagPopNum] 			    = {name = "runeBag_pop_num", layout = "njtqdbg", order = eUIO_TOP_MOST},
	[eUIID_Under_Wear_Slot_Unlock] 		= {name = "underwear_slot_unlock", layout = "njjs", order = eUIO_TOP_MOST},
	[eUIID_BossRecords]					= {name = "boss_records", layout = "bosspm", order = eUIO_TOP_MOST},
	[eUIID_Under_Wear_Rune_Lang] 		= {name = "underwear_rune_lang", layout = "njfwzy", order = eUIO_TOP_MOST},
	[eUIID_PlayerLead] 					= {name = "playerLead", layout = "xsgzy", order = eUIO_TOP_MOST},
	[eUIID_Under_Wear_Rune_Equip] 	    = {name = "underwear_rune_equip", layout = "njfwtc", order = eUIO_TOP_MOST},
	[eUIID_Warehouse]					= {name = "warehouse", layout = "jhck", order = eUIO_TOP_MOST, isPad = true},
	[eUIID_RobEscortAnimation]      	 = { name = "rob_escort_animation",layout = "jbcgtx"},
	[eUIID_RobEscortShowCoin]			= {name = "rob_escort_show_coin", layout = "pz5"},
	[eUIID_BuffTips]					= {name = "buff_tips", layout = "bufftips", order = eUIO_TOP_MOST},
	[eUIID_HuoLongDao]					= {name = "huolongdao", layout = "rwdh", order = eUIO_TOP_MOST},
	[eUIID_Marry_Create_Marriage] 	    = {name = "marry_create_marriage", layout = "jhdjyy", order = eUIO_TOP_MOST},
	[eUIID_Marry_Demande_Marriage] 	    = {name = "marry_demande_marriage", layout = "jhqhjm", order = eUIO_TOP_MOST},
	[eUIID_Marry_Select_Size] 	        = {name = "marry_select_size", layout = "jhhlgm", order = eUIO_TOP_MOST},
	[eUIID_Marry_Proposing] 	        = {name = "marry_proposing", layout = "cs1", order = eUIO_TOP_MOST},
	[eUIID_Marry_Wendding] 	            = {name = "marry_wendding", layout = "jhdjyy2", order = eUIO_TOP_MOST},
	[eUIID_Marry_Unmarried] 	        = {name = "marry_unmarried", layout = "jhdjyy3", order = eUIO_TOP_MOST},
	[eUIID_Marry_Progress_Inst] 	    = {name = "marry_pro_instructions", layout = "jhjdsm", order = eUIO_TOP_MOST},
	[eUIID_Marry_Marryed_Yinyuan] 	    = {name = "marry_marryed_yinyuan", layout = "jhfqyy"},
	[eUIID_Task_Question]				= {name = "task_question", layout = "jqrwdt", order = eUIO_TOP_MOST},
	[eUIID_Marry_Marryed_lihun]			= {name = "marry_marryed_lihun", layout = "jhlhjm", order = eUIO_TOP_MOST},
	[eUIID_Marry_Marryed_skills]		= {name = "marry_marryed_skills", layout = "jhhyjn", order = eUIO_TOP_MOST},
	[eUIID_npcExchange]                 = {name = "npc_exchange", layout = "dhjl", order = eUIO_TOP_MOST},
	[eUIID_steedSkillUpLevel]           = {name = "steedSkillUpLevel", layout = "qssj", order = eUIO_TOP_MOST},
	[eUIID_Marry_Banquat] 	            = {name = "marry_banquet", layout = "jhdjyy4", order = eUIO_TOP_MOST},
	[eUIID_Marry_reserve]				= {name = "marry_reserve", layout = "hlyy", order = eUIO_TOP_MOST},
	[eUIID_Marry_effects]				= {name = "marry_effects", layout = "jhtx", order = eUIO_TOP_MOST},
	[eUIID_AfterTenYears] 	            = {name = "afterTenYears", layout = "scsnhjm", order = eUIO_TOP_MOST},
	[eUIID_SkillPreset]                 = {name = "skill_preset", layout = "jnqh", order = eUIO_NORMAL},
	[eUIID_SkillSet]                 = {name = "skill_set", layout = "jnsd", order = eUIO_NORMAL},
	[eUIID_SpiritsSet]                 = {name = "spirits_set", layout = "xfsd", order = eUIO_NORMAL},
	[eUIID_PreName]                 = {name = "pre_name", layout = "jnsdmz", order = eUIO_NORMAL},
	[eUIID_SingleDungeonTips]      = { name = "single_dungeon_tips",layout = "zdfbts"},
	[eUIID_FactionTeamDungeonMap]					= {name = "faction_team_dungeon_map", layout = "bpfbdt",order = eUIO_TOP_MOST},
	[eUIID_2v2Result]				= {name = "2v2_result", layout = "2v2sfjm", order = eUIO_NORMAL},
	[eUIID_Battle2v2]				= {name = "battle_2v2", layout = "2v2zd"},
	[eUIID_ShenBing_UpSkill]        = {name = "shen_bing_upskill", layout = "sbsj" ,order = eUIO_TOP_MOST},
	[eUIID_ShenBing_UpSkillMax]     = {name = "shen_bing_upskill_max", layout = "sbsjm" ,order = eUIO_TOP_MOST},
	[eUIID_ShenBing_Talent_Info]    = {name = "shen_bing_talent_info", layout = "sbtftc" ,order = eUIO_TOP_MOST},
	[eUIID_ShenBing_Talent_Buy]     = {name = "shen_bing_talent_buy", layout = "sbtfgm" ,order = eUIO_TOP_MOST},
	[eUIID_ShenBing_Talent_Reset]   = {name = "shen_bing_talent_reset", layout = "sbtfcz" ,order = eUIO_TOP_MOST},
	[eUIID_2v2DanResult]			= {name = "2v2_dan_result", layout = "2v2jg", order = eUIO_TOP},
	[eUIID_FactionDineGetVit]			= { name = "faction_dine_get_vit", layout = "hdtl",order = eUIO_TOP_MOST  },
	[eUIID_Grab_Red_Envelope]			= { name = "grab_red_envelope", layout = "qhb",order = eUIO_TOP_MOST  },
	[eUIID_Firework1]				= { name = "firework1", layout = "yhtx1", order = eUIO_TOP_MOST },
	[eUIID_Firework2]				= { name = "firework2", layout = "yhtx2", order = eUIO_TOP_MOST },
	[eUIID_Firework3]				= { name = "firework3", layout = "yhtx3", order = eUIO_TOP_MOST },
	[eUIID_Firework4]				= { name = "firework4", layout = "yhtx4", order = eUIO_TOP_MOST },
	[eUIID_Firework5]				= { name = "firework5", layout = "yhtx5", order = eUIO_TOP_MOST },
	[eUIID_UntilBossUI]				= { name = "until_boss", layout = "cs2", order = eUIO_TOP_MOST },
	[eUIID_WaitTip]					= {name = "wait_tip", layout = "ddts",order = eUIO_TOP_MOST},
	[eUIID_SignWait]				= {name = "sign_wait", layout = "bmcg", order = eUIO_TOP_MOST},
	[eUIID_FactionRobFlagAward]		= {name = "faction_rob_flag_award", layout = "zljl", order = eUIO_TOP_MOST},
	[eUIID_ShenBing_UniqueSkill]	= {name = "shen_bing_unique_skill", layout = "sbtj", order = eUIO_TOP_MOST},
	[eUIID_War_Team_Room]	        = {name = "war_team_room", layout = "lsdwslz11", order = eUIO_TOP_MOST},
	[eUIID_FactionRobFlagLog]		= {name = "faction_rob_flag_log", layout = "dqgz", order = eUIO_TOP_MOST},
	[eUIID_Grab_Red_Bag_Reward]		= {name = "grab_red_bag_reward", layout = "qhb2", order = eUIO_TOP_MOST},
	[eUIID_Grab_Red_Bag_Not_HaveReward]		= {name = "grab_red_bag_not_reward", layout = "qhb3", order = eUIO_TOP_MOST},
	[eUIID_Grab_Red_Bag_other]      = {name = "grab_red_bag_other", layout = "qhb4", order = eUIO_TOP_MOST},
	[eUIID_StrengthenSelf]					= {name = "strengthen_self", layout = "wybq2",order = eUIO_TOP_MOST},
	[eUIID_MidMessageBox1]				= { name = "topMessagebox1", layout = "cs2", order = eUIO_BOARDTOP },
	[eUIID_MidMessageBox2]				= { name = "topMessagebox2", layout = "cs1", order = eUIO_BOARDTOP },
	[eUIID_Schedule_Tips]				= { name = "schedule_tips", layout = "rcbtips", order = eUIO_TOP_MOST },
	[eUIID_JinlanAchiPointRwdTips]				= { name = "jinlanAchiPointRwdTips", layout = "rcbtips", order = eUIO_TOP_MOST },
	[eUIID_RankList_Other]				= { name = "ranking_list_other", layout = "rxphb", order = eUIO_TOP_MOST },
	[eUIID_ProgressSuccess]	        = {name = "progress_success", layout = "jjcg", order = eUIO_TOP_MOST},
	[eUIID_ShenshiTongmin]	        = {name = "shen_bing_tongmin", layout = "sbtjdmzy", order = eUIO_TOP_MOST},
	[eUIID_SpanTips]	       		= {name = "span_tips", layout = "kffyts", order = eUIO_TOP_MOST},
	[eUIID_AllSpirits]				= {name = "suicongAllSpirits", layout = "scwk", order = eUIO_TOP_MOST},
	[eUIID_ExploitTips]				= {name = "suicongExploitTips", layout = "scxfzj", order = eUIO_TOP_MOST},
	[eUIID_StudySpirit]				= {name = "suicongStudySpirit", layout = "scxxxf", order = eUIO_TOP_MOST},
	[eUIID_SpiritTips1]				= {name = "suicongSpiritTips1", layout = "scxfcx", order = eUIO_TOP_MOST},
	[eUIID_SpiritTips2]				= {name = "suicongSpiritTips2", layout = "scxfth", order = eUIO_TOP_MOST},
	[eUIID_SpiritTips3]				= {name = "suicongSpiritTips3", layout = "scxxf", order = eUIO_TOP_MOST},
	[eUIID_BuyWizardPoint]			= {name = "buy_wizard_point", layout = "gmxld",order = eUIO_TOP_MOST},
	[eUIID_OpenArtufact]			= {name = "activity_open_artifact", layout = "jfsq", order = eUIO_TOP_MOST},
	[eUIID_OpenArtufact1]			= {name = "activity_open_artifact1", layout = "cjb1", order = eUIO_TOP_MOST},
	[eUIID_Under_Wear_Introduce]	= {name = "underwear_intr", layout = "njbz", order = eUIO_TOP_MOST},
	[eUIID_OfflinWizardTips]		= {name = "offlinWizardTips", layout = "lxsytips", order = eUIO_TOP_MOST},
	[eUIID_NpcHotel]				= {name = "npcHotel", layout = "jhkz", order = eUIO_TOP_MOST},
	[eUIID_MartialFeatShop]			= { name = "martialFeatShop", layout = "wxsc", relevance = { eUIID_DB, eUIID_DBF } },
	[eUIID_MartialFeatShopTip]		= {name = "martialFeatShopTip", layout = "wxscdj", order = eUIO_TOP_MOST},
	[eUIID_ShowRoleTitleTips]		= {name = "show_roleTitle_tips", layout = "chts2", order = eUIO_TOP_MOST},
	[eUI_EXP_DESC]					= {name = "exp_desc",layout = "jybz",order = eUIO_TOP_MOST},
	[eUIID_GroupBuy]				= {name = "group_buy", layout = "xstg", order = eUIO_TOP_MOST},
	[eUIID_TransferPreview]			= {name = "transferPreview", layout = "zzyl", order = eUIO_TOP_MOST},
	[eUIID_Weapon_NPC_RESULT]		= {name = "weapon_result", layout = "hdjs"},
	[eUIID_RewardTest]				= {name = "rewardTest", layout = "yjdy2"},
	[eUIID_RewardTips]				= {name = "rewardTips", layout = "dlsltips",order = eUIO_TOP_MOST},
	[eUIID_BuyBaseItem]				= {name = "buyBaseItem", layout = "gmnl", order = eUIO_TOP_MOST},
	[eUIID_Qiankun]					= {name = "qiankun", layout = "qiankun", order = eUIO_TOP_MOST},
	[eUIID_QiankunBuy]				= {name = "qiankunbuy", layout = "gmqk", order = eUIO_TOP_MOST},
	[eUIID_QiankunReset]			= {name = "qiankunreset", layout = "qkcz", order = eUIO_TOP_MOST},
	[eUIID_Broadcast]				= {name = "broadcast", layout = "zbjm", order = eUIO_TIPS},
	[eUIID_StoreRefresh]			= {name = "storeRefresh", layout = "sdsx", order = eUIO_TOP_MOST},
	[eUIID_FlashSale]				= {name = "flash_sale", layout = "xstm2", order = eUIO_TOP_MOST},
	[eUIID_AboveBuffTips]			= {name = "above_buff_tips", layout = "bufftips2", order = eUIO_TOP_MOST},
	[eUIID_RetrieveChoose]			= {name = "retrieveChoose", layout = "hdbz", order = eUIO_TOP_MOST},
	[eUIID_RetrieveActivity]		= {name = "retrieveActivity", layout = "hdbznd", order = eUIO_TOP_MOST},
	[eUIID_AuctionSearching]		= {name = "auctionSearching", layout = "ssz", order = eUIO_TOP_MOST},
	[eUIID_MapCopyDamageRank]		= {name = "mapCopyDamageRank", layout = "fbphb", order = eUIO_TOP_MOST},
	[eUIID_RightHeart]				= {name = "rightheart", layout = "zyzx", order = eUIO_TOP_MOST},
	[eUIID_DownloadExtPack]			= {name = "downloadExtPack", layout = "fbxz", order = eUIO_TOP_MOST},
	[eUIID_YunbiaoTips]				= {name = "yunbiaoTips", layout = "ybts", order = eUIO_TOP_MOST},
	[eUIID_RightHeart_RESULT]		= {name = "rightHeart_result", layout = "hdjs"},
	[eUIID_Stela]					= {name = "stela", layout = "txbw", order = eUIO_TOP_MOST},
	[eUIID_DemonHoleRank]			= {name = "demonholeRank", layout = "fmdph", order = eUIO_TOP_MOST},
	[eUIID_DemonHolesummary]		= {name = "demonholeSummary", layout = "zdfmd", order = eUIO_TOP},
	[eUIID_DemonHoleDialogue]		= {name = "demonholeDialogue", layout = "db7",order = eUIO_TOP_MOST},
	[eUIID_Annunciate]				= {name = "annunciate", layout = "jhgj", order = eUIO_TOP_MOST},
	[eUIID_BattleReadFight]       	= {name = "battleReadyFight",layout = "kaizhan2"},
	[eUIID_RetrieveActivityTip]     = {name = "retrieveActivityTip",layout = "zyzhdh"},
	[eUIID_FightNpc]				= {name = "fight_npc", layout = "fgcs",order = eUIO_TOP_MOST},
	[eUIID_BindEffectMarry]			= {name = "bind_effect_marry", layout = "jhcjtx",order = eUIO_TOP_MOST},
	[eUIID_AddFriends]				= {name = "addFriends", layout = "tjhy", order = eUIO_TOP_MOST},
	[eUIID_LuckyStarTip]			= {name = "luckyStarTip", layout = "xyxdh"},
	[eUIID_QiankunUp]				= {name = "qiankun_up", layout = "qksj", order = eUIO_TOP_MOST},
	[eUIID_FanXian]                 = {name = "fanxian", layout = "czfl", order = eUIO_TOP_MOST},
	[eUIID_UniqueskillPreview]    	= {name = "uniqueSkillPreview", layout = "jjdj", order = eUIO_TOP_MOST},
	[eUIID_SendItems]                = {name = "send_items",layout = "djzs", order = eUIO_TOP_MOST},
	[eUIID_OnlineVoice]				= {name = "online_Voice",layout = "zdlt", order = eUIO_TOP_MOST},
	[eUIID_PayActivity]   			= {name = "payActivity_new",layout = "yyhd1", order = eUIO_TOP_MOST},
	[eUIID_BuyChannelSpirit]		= {name = "buyChannelSpirit",layout = "gmjl", order = eUIO_TOP_MOST},
	[eUIID_ServerLineUp]			= {name = "server_line_up",layout = "dlpd", order = eUIO_TOP_MOST},
	[eUIID_Evaluation_weaponPet]	= {name = "evaluation_pet_weapon",layout = "pjjm", order = eUIO_TOP_MOST},
	[eUIID_MakeLegendEquip]			= {name = "make_legend_equip",layout = "cszb", order = eUIO_TOP_MOST},
	[eUIID_DungeonMap]				= {name = "dungeonMap", layout = "fmddt",order = eUIO_TOP_MOST},
	[eUIID_LegendEquip]				= {name = "legendEquip", layout = "cszb2",order = eUIO_TOP_MOST},
	[eUIID_woodMan]					= {name = "woodMan", layout = "zdmz"},
	[eUIID_woodManShare]			= {name = "woodManShare", layout = "mzfx", order = eUIO_TOP_MOST},
	[eUIID_BackDefense]				= {name = "backDefense", layout = "zdsh",order = eUIO_TOP_MOST},
	[eUIID_DefendRank]				= {name = "defendRank", layout = "shphb",order = eUIO_TOP_MOST},
	[eUIID_DefendSummary]			= {name = "defendSummary", layout = "zdsh2",order = eUIO_TOP_MOST},
	[eUIID_DefendResult]			= {name = "defendResult", layout = "shjs",order = eUIO_TOP_MOST},
	[eUIID_UnlockHead]				= {name = "unlockhead", layout = "txjh",order = eUIO_TOP_MOST},
    [eUIID_PrayActivity]            = {name = "prayActivity", layout = "qifu", order = eUIO_TOP_MOST},
    [eUIID_PrayActivityTurntable]   = {name = "prayActivityTurntable", layout = "qifu2", order = eUIO_TOP_MOST},
	[eUIID_BuyPrivateWareHouse]   	= {name = "buy_private_warehouse", layout = "ckjs", order = eUIO_TOP_MOST},
	[eUIID_IsBuyWareHouse] 	    	= {name = "is_buy_wareHouse", layout = "cs1", order = eUIO_TOP_MOST},
	[eUIID_DefendCount]				= {name = "defendCount", layout = "boshu",order = eUIO_TOP_MOST},
	[eUIID_Master_shitu]            = {name = "master_shitu",layout = "shitu", order = eUIO_TOP_MOST},
	[eUIID_Master_modifyAnnc]       = {name = "master_modify_annc",layout = "xgshxy", order = eUIO_TOP_MOST},
	[eUIID_Master_baishi]           = {name = "master_baishi",layout = "baishi", order = eUIO_TOP_MOST},
	[eUIID_Master_mstrInfo]         = {name = "master_mstr_info",layout = "sfxx", order = eUIO_TOP_MOST},
	[eUIID_Master_apprtcActv]       = {name = "master_apprtc_activity",layout = "tdhy", order = eUIO_TOP_MOST},
	[eUIID_Master_chushi]           = {name = "master_chushi",layout = "chushi", order = eUIO_TOP_MOST},
	--[eUIID_Master_shop]             = {name = "master_shop",layout = "bpsd", order = eUIO_TOP_MOST},
	--[eUIID_Master_shop_buy]		    = {name = "master_shop_buy", layout = "bpdjgm",order = eUIO_TOP_MOST},
	[eUIID_FuBen_Skill]		   		= {name = "fuben_Skill", layout = "zdxjn"},
	[eUIID_FuBen_SkillDetail]		= {name = "fuben_SkillDetail", layout = "zdxjn2"},
	[eUIID_RECHARGE_CONSUME_RANK]	= {name = "recharge_consume_rank", layout = "czphb",order = eUIO_TOP_MOST},
	[eUIID_ArtifactStrengthSelect]  = {name = "artifactStrengthSelect", layout = "jlsq2",order = eUIO_TOP_MOST},
	-- [eUIID_ArtifactStrength]        = {name = "artifactStrength", layout = "jlsq"},
	[eUIID_Activity_Calendar]	    = {name = "activityCalendar", layout = "rili",order = eUIO_TOP_MOST},
	[eUIID_Activity_CalendarDetail]	= {name = "activityCalendarDetail", layout = "rili2",order = eUIO_TOP_MOST},
	[eUIID_Blood_Pool]				= {name = "blood_pool", layout = "xcts", order = eUIO_TOP_MOST},
	[eUIID_Today_Tip]				= {name = "today_tips", layout = "dhtips", order = eUIO_TOP_MOST},
	[eUIID_Fly_Mount_Preview]		= {name="fly_mount_preview",layout="zqqstips",order = eUIO_TOP_MOST},
	[eUIID_Quick_Combine]			= {name = "quick_combine", layout = "djhb", order = eUIO_TOP_MOST},
	[eUIID_Bag_extend]				= {name = "bag_extend", layout = "bgkc", order = eUIO_TOP_MOST},
	[eUIID_UnlockHunyu] 			= {name = "unlockHunyu", layout = "lyjf", order = eUIO_TOP_MOST},
	[eUIID_ExpTreeWater] 			= {name = "expTreeWater", layout = "jiaoshui", order = eUIO_TOP_MOST},
	[eUIID_ExpTreeShake] 			= {name = "expTreeShake", layout = "shanghua", order = eUIO_TOP_MOST},
	[eUIID_ExpTreeFlower] 			= {name = "expTreeFlower", layout = "zhanfang", order = eUIO_TOP_MOST},
	[eUIID_UnlockHunyuTips] 		= {name = "unlockHunyuTips", layout = "lyjftips", order = eUIO_TOP_MOST},
	[eUIID_longyinSpeedup] 			= {name = "longyinSpeedup", layout = "jfjs", order = eUIO_TOP_MOST},
	[eUIID_RefineTip]				= {name = "refine_tip", layout = "jltips", order = eUIO_TOP_MOST},
	[eUIID_GemBless] 				= {name = "gem_bless", layout = "bszf", order = eUIO_TOP_MOST},
	[eUIID_RecycleOpen]				= {name = "faction_recycle_open", layout = "jubaopen", order = eUIO_TOP_MOST},
	[eUIID_DestroyItem]				= {name = "destroy_new_item", layout = "plch", order = eUIO_TOP_MOST},
	[eUIID_DestroyItem_Count]		= {name = "destroy_item_count", layout = "djcs", order = eUIO_TOP_MOST},
	[eUIID_MessageBox3]				= { name = "messagebox3", layout = "zdts", order = eUIO_TOP_MOST },
	[eUIID_CombatTeamList]			= { name = "combatTeamList", layout = "guanzhan", order = eUIO_TOP_MOST },
	[eUIID_CreateCombatTeam]		= { name = "createCombatTeam", layout = "tuandui", order = eUIO_TOP_MOST },
	[eUIID_AuctionSelect]			= { name = "auctionSelect", layout = "pmhsx", order = eUIO_TOP_MOST },
	[eUIID_PkTooltip]				= { name = "pk_attacked_tooltip", layout = "SETIPS", order = eUIO_TOP_MOST },
	[eUIID_FactionFightGroup]		= { name = "factionFightGroup", layout = "bpft", order = eUIO_TOP_MOST },
	[eUIID_FactionFightGroupCreate]	= { name = "factionFightGroupCreate", layout = "cjft", order = eUIO_TOP_MOST },
	[eUIID_FactionFightGroupMsg]	= { name = "factionFightGroupMsg", layout = "bpzts", order = eUIO_TOP_MOST },
	[eUIID_FashionSpinning]			= { name = "fashion_spinning", layout = "szjf", order = eUIO_TOP_MOST },
	[eUIID_FashionSpinningProperty]	= { name = "fashion_spinning_property", layout = "szjf2", order = eUIO_TOP_MOST },
	[eUIID_BattleShowEquipPower]    = { name = "battleShowEquipPower",layout = "pz6"},
	[eUIID_SteedSkin]				= { name = "steedSkin", layout = "zqpf", isPad = true },
	[eUIID_SteedSkinTips]			= { name = "steedSkinTips", layout = "zqpftips", order = eUIO_TOP_MOST },
	[eUIID_SteedSkinProperty]		= { name = "steedSkinProperty", layout = "zqpfsx", order = eUIO_TOP_MOST },
	[eUIID_SteedSkinRenew]			= { name = "steedSkinRenew", layout = "pfxq", order = eUIO_TOP_MOST },
	[eUIID_SteedSkinPrompt]         = {name = "steedSkinPrompt", layout = "zqts", order =  eUIO_TOP_MOST},
	[eUIID_Flash_Sale_Buy]			= { name = "flash_sale_buy", layout = "xstmgm", order = eUIO_TOP_MOST },
	[eUIID_FactionFightGroupRename]	= { name = "factionFightGroupRename", layout = "xgftmz", order = eUIO_TOP_MOST },
	[eUIID_Upgrade_Rune_lang]		= { name = "upgrade_rune_lang_items", layout = "njfwzysj", order = eUIO_TOP_MOST },
	[eUIID_FactionFightGroupScore]		= { name = "factionFightGroupScore", layout = "zdbpz" ,order = eUIO_TOP},
	[eUIID_FactionFightGroupResult]		= { name = "factionFightGroupResult", layout = "bpzzj", order = eUIO_TOP_MOST },
	[eUIID_FactionFightMap]				= {name = "factionFightMap", layout = "slzdt",order = eUIO_TOP_MOST},
	[eUIID_FactionFightMiniMap]   			= { name = "factionFightMiniMap", layout = "slzxdt"},
	[eUIID_IsShowSkill]				= {name="IsShowSkill",layout="bsjnms",order = eUIO_TOP_MOST},
	[eUIID_Rune_lang_attr]			= { name = "queryRoleRuneLangAttr", layout = "fwzytips", order = eUIO_TOP_MOST },
	[eUIID_FactionFightPush]		= { name = "faction_fight_push", layout = "bpzts", order = eUIO_TOP_MOST },
	[eUIID_FactionFightPushResult]	= { name = "faction_fight_push_result", layout = "bpzts2", order = eUIO_TOP_MOST },
	[eUIID_DegenerationNpc]			= { name = "degenerationNpc", layout = "bianxing", order = eUIO_TOP_MOST },
	[eUIID_DegenerationConfirm]		= { name = "degenerationConfirm", layout = "bxqrts", order = eUIO_TOP_MOST },
	[eUIID_FiveEndActivity]			= { name = "fiveEndActivity", layout = "wjmz", order = eUIO_TOP_MOST},
	[eUIID_QieCuoInvite]			= { name = "qieCuoInvite", layout = "qcts", order = eUIO_TOP_MOST},
	[eUIID_QieCuoResult]			= { name = "qieCuoResult", layout = "qcjs", order = eUIO_TOP_MOST},
	[eUIID_RoleReturn]				= { name = "role_return", layout = "lyzh", order = eUIO_TOP_MOST},
	[eUIID_EquipSharpen]			= { name = "equipSharpen", layout = "zbcf", order = eUIO_TOP_MOST},
	[eUIID_ChangeHeadFrame]			= { name = "change_head_frame", layout = "xgtxk", order = eUIO_TOP_MOST },
	[eUIID_RoleReturnActivity]		= { name = "role_return_activity", layout = "flhd", order = eUIO_TOP_MOST },
	[eUIID_ExchangeMore]			= { name = "exchange_more", layout = "dhsl", order = eUIO_TOP_MOST},
	[eUIID_ChangeProfession]		= { name = "changeProfession", layout = "zybg", order = eUIO_TOP_MOST},
	[eUIID_ChangeProfessionConfirm] = { name = "changeProfessionConfirm", layout = "zybgts", order = eUIO_TOP_MOST},
	[eUIID_PetRace]					= { name = "petRace", layout = "saipao", order = eUIO_TOP_MOST},
	[eUIID_BattlePetRace]			= { name = "battlePetRace", layout = "zdsp", order = eUIO_TOP_MOST},
	[eUIID_ExchangeWords]			= { name = "exchange_word", layout = "duiduipeng", order = eUIO_TOP_MOST},
	[eUIID_DriftBottle]				= { name = "drift_bottle", layout = "piaoliuping", order = eUIO_TOP_MOST},
	[eUIID_GoldenEgg]                = { name = "goldenEgg", layout = "jindan", order = eUIO_TOP_MOST},
	[eUIID_DriftBottleGift]			= { name = "drift_bottle_gift", layout = "piaoliupingjl", order = eUIO_TOP_MOST},
	[eUIID_DriftBottleExtra]		= { name = "drift_bottle_extra", layout = "piaoliupingjl2", order = eUIO_TOP_MOST},
	[eUIID_PetRaceSkillDesc]		= { name = "petRaceSkillDesc", layout = "bsjnms", order = eUIO_TOP_MOST},
    [eUIID_SpringAct]				= { name = "spring_act", layout = "wenquan"},
	[eUIID_SpringBuff]              = { name = "springBuff",layout = "zdwenquan"},
	--[eUIID_PetRaceShop]				= {name = "petRaceShop", layout = "bpsd", order = eUIO_TOP_MOST},
	--[eUIID_PetRaceShopBuy]			= {name = "petRaceShopBuy", layout = "bpdjgm",order = eUIO_TOP_MOST},
	[eUIID_FactionRobFlagItem]		= { name = "faction_rob_flag_item", layout = "dqtips", order = eUIO_TOP_MOST},
	[eUIID_SpringTips]		        = { name = "springTips", layout = "wenquantips", order = eUIO_TOP_MOST},
	[eUIID_SpringInvite]		    = { name = "springInvite", layout = "wenquanhd", order = eUIO_TOP_MOST},
	[eUIID_DebrisRecycle]		    = { name = "debrisRecycle", layout = "djhs", order = eUIO_TOP_MOST},
	[eUIID_MarriageTitle]			= { name = "marriageTitle", layout = "yych"},
	[eUIID_BuffDrugTips]			= { name = "buff_drug_tips", layout = "bufftips3", order = eUIO_BOTTOM},
	[eUIID_BuffDrugRemove]			= { name = "buff_drug_remove", layout = "buffsc", order = eUIO_TOP_MOST},
	[eUIID_UserAgreement]			= { name = "user_agreement", layout = "xieyi", order = eUIO_TOP_MOST},
	[eUIID_OtherBuffDrugTips]		= { name = "buff_drug_tips", layout = "bufftips4", order = eUIO_TOP_MOST},
	[eUIID_MartialSoul]				= { name = "martialSoul", layout = "wuhun"},
	[eUIID_MartialSoulProp]			= { name = "martialSoulProp", layout = "Wuhuntips", order = eUIO_TOP_MOST},
	[eUIID_MartialSoulSkin]			= { name = "martialSoulSkin", layout = "wuhunhh2", order = eUIO_TOP_MOST},
	[eUIID_MartialSoulSkinUnlock]	= { name = "martialSoulSkinUnlock", layout = "wuhunjs", order = eUIO_TOP_MOST},
	[eUIID_MartialSoulStage]		= { name = "martialSoulStage", layout = "wuhunsj", order = eUIO_TOP_MOST},
	[eUIID_Qiling]					= { name = "qiling", layout = "qiling", order = eUIO_TOP_MOST},
	[eUIID_QilingProp]				= { name = "qilingProp", layout = "qiling2", order = eUIO_TOP_MOST},
	[eUIID_QilingActive]			= { name = "qilingActive", layout = "qljh", order = eUIO_TOP_MOST},
	[eUIID_QilingNode]				= { name = "qilingNode", layout = "qljdsx", order = eUIO_TOP_MOST},
	[eUIID_QilingPromote]			= { name = "qilingPromote", layout = "qljh2", order = eUIO_TOP_MOST},
	[eUIID_WoodenTripod]			= { name = "woodenTripod", layout = "shenmuding", order = eUIO_TOP_MOST},
	[eUIID_WoodenTripodBuyTimes]	= { name = "woodenTripodBuyTimes", layout = "gmcs", order = eUIO_TOP_MOST},
	[eUIID_RankListWeaponSoul]		= { name = "ranking_list_RoleWeaponSoul", layout = "whxx", order = eUIO_TOP_MOST},
	[eUIID_QilingTips]				= { name = "qilingTips", layout = "qilingtips", order = eUIO_TOP_MOST},
	[eUIID_QilingSkillDesc]			= { name = "qilingSkillDesc", layout = "scjn", order = eUIO_TOP_MOST},
	[eUIID_QilingSkillUpdate]		= { name = "qilingSkillUpdate", layout = "jnsj", order = eUIO_TOP_MOST},
	[eUIID_DigitalCollection]		= { name = "digital_collection", layout = "jishulingjiang", order = eUIO_TOP_MOST},
	[eUIID_FindMooncake]		    = { name = "findMooncake", layout = "zhaocha", order = eUIO_TOP_MOST},
	[eUIID_StarDish]				= { name = "starDish", layout = "xingpan"},
	[eUIID_StarFlare]				= { name = "starFlare", layout = "xyjm", order = eUIO_TOP_MOST},
	[eUIID_Dice]					= { name = "dice", layout = "dafuweng", order = eUIO_TOP_MOST},
	[eUIID_NationalRaiseFlag]		= { name = "national_raise_flag", layout = "guoqingjie", order = eUIO_TOP_MOST},
	[eUIID_NationalCheerRank]		= { name = "national_cheer_rank", layout = "jiayouph", order = eUIO_TOP_MOST},
	[eUIID_NationalAddOil]			= { name = "national_add_oil", layout = "jiayou", order = eUIO_TOP_MOST},
	[eUIID_NationalLuckyDog]		= { name = "national_lucky_dog", layout = "xingyunzhe", order = eUIO_TOP_MOST},
	[eUIID_WaitToFind]				= { name = "waitToFind", layout = "djszhao", order = eUIO_TOP_MOST},
	[eUIID_FactionGarrison]			= { name = "factionGarrison", layout = "bpgz", order = eUIO_TOP_MOST},
	[eUIID_FactionGarrisonDonate]	= { name = "factionGarrisonDonate", layout = "jxcl", order = eUIO_TOP_MOST},
	[eUIID_GarrisonDonateRanks]		= { name = "garrisonDonateRanks", layout = "zdgxb", order = eUIO_TOP_MOST},
	[eUIID_FactionFateRanks]		= { name = "factionFateRanks", layout = "bpqy", order = eUIO_TOP_MOST},
	[eUIID_StarShape]				= { name = "starShape", layout = "xingwei",order = eUIO_TOP_MOST},
	[eUIID_DiceExchange]			= { name = "diceExchange", layout = "dhwp",order = eUIO_TOP_MOST},
	[eUIID_DiceMonster]				= { name = "diceMonster", layout = "hdjy",order = eUIO_TOP_MOST},
	[eUIID_DiceFlower]				= { name = "diceFlower", layout = "hdmg",order = eUIO_TOP_MOST},
	[eUIID_DiceEventSlow]			= { name = "diceEventSlow", layout = "dfwgsxg",order = eUIO_TOP_MOST},
	[eUIID_DiceEventThrow]			= { name = "diceEventThrow", layout = "dfwhdjh",order = eUIO_TOP_MOST},
	[eUIID_DiceEventFast]			= { name = "diceEventFast", layout = "dfwjsxg",order = eUIO_TOP_MOST},
	[eUIID_DiceEventDeduct]			= { name = "diceEventDeduct", layout = "dfwmfzd",order = eUIO_TOP_MOST},
	[eUIID_DiceYun]					= { name = "diceYun", layout = "yun",order = eUIO_TOP_MOST},
	[eUIID_FactionBoss]				= { name = "factionBoss", layout = "bpb",order = eUIO_TOP_MOST},
	[eUIID_StarChangeShape]			= { name = "starChangeShape", layout = "xwxz",order = eUIO_TOP_MOST},
	[eUIID_StarLock]				= { name = "starLock", layout = "xyjs",order = eUIO_TOP_MOST},
	[eUIID_GameEntrance]			= { name = "gameEntrance", layout = "gnhdrk",order = eUIO_TOP_MOST},
	[eUIID_FactionGarrisonMap]		= { name = "factionGarrisonMap", layout = "bpdt",order = eUIO_TOP_MOST},
	[eUIID_FindFail]		        = { name = "findFail", layout = "zhaochasb",order = eUIO_TOP_MOST},
	[eUIID_FactionGarrisonSummary]		= {name = "factionGarrisonSummary", layout = "zdbpzd"},
	[eUIID_RedEnvelope]				= { name = "red_envelope", layout = "bpqhb", order = eUIO_TOP_MOST},
	[eUIID_RedEnvelopeSend]			= { name = "red_envelope_send", layout = "fhb", order = eUIO_TOP_MOST},
	[eUIID_DragonLucky]				= { name = "dragon_lucky", layout = "lyfz", order = eUIO_TOP_MOST},
	[eUIID_RankStarDish]			= {name = "starDishRank", layout = "phbxy", order = eUIO_TOP_MOST},
	[eUIID_BonusHouse]				= {name = "bonus_house", layout = "bphdrk", order = eUIO_TOP_MOST},
	[eUIID_StarDishLead]			= {name = "starDishLead", layout = "xingpanyd", order = eUIO_TOP_MOST},
	[eUIID_RedEnvelopeDetail]		= {name = "red_envelope_detail", layout = "bphbxq", order = eUIO_TOP_MOST},
	[eUIID_StarActivate]			= {name = "starActivate", layout = "xyjhcg", order = eUIO_TOP_MOST},
	[eUIID_CallBack]				= {name = "callBack", layout = "huigui", order = eUIO_TOP_MOST},
	[eUIID_BuyGetGifts]				= {name = "buy_get_gifts", layout = "djgm2f", order = eUIO_TOP_MOST},
	[eUIID_SteedRank]				= {name = "steedRank", layout = "zqph", order = eUIO_TOP_MOST},
	[eUIID_CheckSteedInfo]			= {name = "checkSteedInfo", layout = "zqphgr", order = eUIO_TOP_MOST},
	[eUIID_PromoteSteed]			= {name = "promoteSteed", layout = "zqzlts", order = eUIO_TOP_MOST},
	[eUIID_SuicongWakenTips]		= {name = "petWakenTips", layout = "scjx", order = eUIO_TOP_MOST},
	[eUIID_SuicongWakenTask1]		= {name = "petWakenTask1", layout = "jxrw1", order = eUIO_TOP_MOST},
	[eUIID_SuicongWakenTask2]		= {name = "petWakenTask2", layout = "jxrw2", order = eUIO_TOP_MOST},
	[eUIID_SuicongWakenTask3]		= {name = "petWakenTask3", layout = "jxrw3", order = eUIO_TOP_MOST},
	[eUIID_SuicongWakenGiveUp]		= {name = "petWakenGiveUp", layout = "jxfq", order = eUIO_TOP_MOST},
	[eUIID_SuicongWakenStep]		= {name = "petWakenStep", layout = "huigui", order = eUIO_TOP_MOST},
	[eUIID_Bid]						= {name = "bid", layout = "paimai", order = eUIO_TOP_MOST},
	[eUIID_BuyChannelSpiritOther]	= {name = "buyChannelSpiritOther", layout = "gmjl2", order = eUIO_TOP_MOST},
	[eUIID_CallBackTips]			= {name = "callBackTips", layout = "huiguitips", order = eUIO_TOP_MOST},
	[eUIID_ChatBubble]				= {name = "chatBubble", layout = "ltqp", order = eUIO_TOP_MOST},
	[eUIID_RobberMonster]			= {name = "robberMonster", layout = "jiangyangdadao", order = eUIO_TOP_MOST},
	[eUIID_RobberMonsterKiller]		= {name = "robberMonsterKiller", layout = "jiangyangdadaojl", order = eUIO_TOP_MOST},
	[eUIID_GmBackstage]				= {name = "backstage", layout = "gm1", order = eUIO_TOP_MOST},
	[eUIID_GmSetLevel]				= {name = "gm_set_level", layout = "sr1", order = eUIO_TOP_MOST},
	[eUIID_GmSetLevel]				= {name = "gm_set_level", layout = "sr1", order = eUIO_TOP_MOST},
	[eUIID_GmAddItem]				= {name = "gm_add_item", layout = "sr2", order = eUIO_TOP_MOST},
	[eUIID_GmSetTime]				= {name = "gm_set_time", layout = "sr3", order = eUIO_TOP_MOST},
	[eUIID_GmSetTransferLevel]		= {name = "gm_set_transfer_level", layout = "sr4", order = eUIO_TOP_MOST},
	[eUIID_GmEquipUpLevel]			= {name = "gm_equip_up_level", layout = "sr5", order = eUIO_TOP_MOST},
	[eUIID_GmUnderWear]				= {name = "gm_under_wear", layout = "sr6", order = eUIO_TOP_MOST},
	[eUIID_GmSetEvilPoint]			= {name = "gm_set_evil_point", layout = "sr7", order = eUIO_TOP_MOST},
	[eUIID_GmSuperWeaponPro]		= {name = "gm_super_weapon_pro", layout = "sr8", order = eUIO_TOP_MOST},
	[eUIID_GmArtifactSrengthen]		= {name = "gm_artifact_strengthen", layout = "sr9", order = eUIO_TOP_MOST},
	[eUIID_GmArtifactRefine]		= {name = "gm_artufact_refine", layout = "sr10", order = eUIO_TOP_MOST},
	[eUIID_GmStarLightShape]		= {name = "gm_star_light_shape", layout = "sr11", order = eUIO_TOP_MOST},
	[eUIID_GmOpenGarrison]			= {name = "gm_open_garrison", layout = "cs1", order = eUIO_TOP_MOST},
	[eUIID_GmSectBossProgress]		= {name = "gm_sect_boss_progress", layout = "sr12", order = eUIO_TOP_MOST},
	[eUIID_GmFiveUniqueActivity]	= {name = "gm_five_unique_activity", layout = "sr13", order = eUIO_TOP_MOST},
	[eUIID_BidTips]					= {name = "bidTips", layout = "paimaitips", order = eUIO_TOP_MOST},
	[eUIID_BidHistory]				= {name = "bidHistory", layout = "paimaijl", order = eUIO_TOP_MOST},
	[eUIID_SuicongAwakenWin]		= {name = "petWakenWin", layout = "scjxcg", order = eUIO_TOP_MOST},
	[eUIID_LuckyStar]				= {name = "lucky_star", layout = "xingyunxing", order = eUIO_TOP_MOST},
	[eUIID_BreakSeal]				= {name = "breakSeal", layout = "fengyin", order = eUIO_TOP_MOST},
	[eUIID_ExchangeFame]			= {name = "exchangeFame", layout = "fengyin2", order = eUIO_TOP_MOST},
	[eUIID_FactionSalary]			= {name = "factionSalary", layout = "bpfl", order = eUIO_TOP_MOST},
	--[eUIID_FameShop]			    = {name = "fameShop", layout = "bpsd", order = eUIO_TOP_MOST},
	--[eUIID_FameShopTips]		    = {name = "fameShopTips", layout = "bpdjgm",order = eUIO_TOP_MOST},
	[eUIID_CreateFightTeam]			= {name = "createFightTeam", layout = "wudaohuiqm", order = eUIO_TOP_MOST},
	[eUIID_FightTeamRecord]			= {name = "fightTeamRecord", layout = "wudaohuizjxx", order = eUIO_TOP_MOST},
	[eUIID_FightTeamSummary]		= {name = "fightTeamSummary", layout = "zdwdh", order = eUIO_TOP},
	[eUIID_GMEntrance]				= {name = "gm_entrance", layout = "gmt", order = eUIO_BOARDTOP},
	[eUIID_Meridian]				= {name = "meridian", layout = "jingmai", order = eUIO_TOP_MOST},
	[eUIID_MeridianResetPulse]		= {name = "meridianResetPulse", layout = "mxcz", order = eUIO_TOP_MOST},
	[eUIID_MeridianPulse]			= {name = "meridianPulse", layout = "maixiangxq", order = eUIO_TOP_MOST},
	[eUIID_MeridianPotential]		= {name = "meridianPotential", layout = "qianneng", order = eUIO_TOP_MOST},
	[eUIID_MeridianPotentialUp]		= {name = "meridianPotentialUp", layout = "qiannengsj", order = eUIO_TOP_MOST},
	[eUIID_CompoundItems]			= {name = "compoundItems", layout = "dhsl", order = eUIO_TOP_MOST},
	[eUIID_PersonShop]				= {name = "person_shop", layout = "bpsd",order = eUIO_TOP_MOST},
	[eUIID_PersonShopBuy]			= {name = "person_shop_buy", layout = "bpdjgm", order = eUIO_TOP_MOST},
	[eUIID_FightTeamSchedule]		= {name = "fightTeamSchedule", layout = "wudaohuism", order = eUIO_TOP_MOST},
	[eUIID_FightTeamGameReport]		= {name = "fightTeamGameReport", layout = "wudaohuiss", order = eUIO_TOP_MOST},
	[eUIID_FightTeamAward]			= {name = "fightTeamAward", layout = "wudaohuijl", order = eUIO_TOP_MOST},
	[eUIID_otherMeridian]			= {name = "queryMeridian", layout = "qiannenghy", order = eUIO_TOP_MOST},
	[eUIID_DynamicTitle]			= {name = "roleDynamicTitle", layout = "chenghaodt", order = eUIO_TOP_MOST},
	[eUIID_BreakSealEffect]			= {name = "breakSealEffect", layout = "fengyincp"},
	[eUIID_FightTeamInfo]			= {name = "fightTeamInfo", layout = "wudaohuidw", order = eUIO_TOP_MOST},
	[eUIID_MeridianProperty]		= {name = "meridianProperty", layout = "jingmaitips", order = eUIO_TOP_MOST},
	[eUIID_Head_Preview]			= {name = "headPreview", layout = "txgm", order = eUIO_TOP_MOST},
	[eUIID_Delete_Friend]			= {name = "deleteFriend", layout = "haoyousc", order = eUIO_TOP_MOST},
	[eUIID_selectWeapon]			= {name = "selectWeapon", layout = "shenbingqh", order = eUIO_TOP_MOST},
	[eUIID_FightTeamResult]         = {name = "fightTeamResult", layout = "wudaohuijg", order = eUIO_TOP_MOST},
	[eUIID_ModifyPetName]			= {name = "modify_pet_name", layout = "scgm", order = eUIO_TOP_MOST},
	[eUIID_FactionRecruitment]		= {name = "faction_recruitment", layout = "zhaomuling", order = eUIO_TOP_MOST},
	[eUIID_MarriageCertificate]		= {name = "marriageCertificate", layout = "jiehunzheng", order = eUIO_TOP_MOST},
	[eUIID_ShareMarriageCard]		= {name = "shareMarriageCard", layout = "jiehunzhengfx", order = eUIO_TOP_MOST},
	[eUIID_FightTeamGuard]			= {name = "fightTeamGuard", layout = "zdwudaohuigz", order = eUIO_TOP_MOST},
	[eUIID_ActivityShow]			= {name = "activityShow", layout = "hdgg", order = eUIO_TOP_MOST},
	[eUIID_ChristmasWish]			= {name = "christmas_wish", layout = "shengdanheka", order = eUIO_TOP_MOST},
	[eUIID_ChristmasWishesList]		= {name = "christmas_wishes_list", layout = "shengdanshu", order = eUIO_TOP_MOST},
	[eUIID_EquipTransform]			= {name = "equip_transform", layout = "fuhuzh", order = eUIO_TOP_MOST},
	[eUIID_EquipTransformCompare]	= {name = "equip_transform_compare", layout = "fuhuzh2", order = eUIO_TOP_MOST},
	[eUIID_UpgradePurchaseTip]		= {name = "upgradepurchaseTip", layout = "djlbdh"},
	[eUIID_EquipTransformEnd]		= {name = "equip_transform_end", layout = "lfjlcg", order = eUIO_TOP_MOST},
	[eUIID_SteedBreak]				= {name = "steedBreak", layout = "zqtp", order = eUIO_TOP_MOST},
	[eUIID_FightTeamInviteConfirm]	= {name = "fightTeamInviteConfirm", layout = "wdhyqts", order = eUIO_TOP_MOST},
	[eUIID_FightTeamPrompt]			= {name = "fightTeamPormpt", layout = "zdwdhts", order = eUIO_TOP_MOST},
	[eUIID_FiveUniqueBatchSweep]	= {name = "fiveUnique_batch_sweep", layout = "wjsd", order = eUIO_TOP_MOST},
	[eUIID_GiftBagSelect]			= {name = "gift_bag_select", layout = "nxuanx", order = eUIO_TOP_MOST},
	[eUIID_WizardGift]				= {name = "offlinWizardGift", layout = "liwuqiuqu", order = eUIO_TOP_MOST},
	[eUIID_SteedFight]				= {name = "steedFight", layout = "zqqz", order = eUIO_TOP_MOST},
	[eUIID_UnderWear_upStage_Prop]	= {name = "underwear_upStage_prop", layout = "njqs", order = eUIO_TOP_MOST},
	[eUIID_SteedFightUnlock]		= {name = "steedFightUnlock", layout = "zqqzjh", order = eUIO_TOP_MOST},
	[eUIID_XingHun]					= {name = "xinghun", layout = "shenqixinghun", order = eUIO_TOP_MOST},
	[eUIID_XingHunUpStage]			= {name = "xinghunUpStage", layout = "xinghunsj2", order = eUIO_TOP_MOST},
	[eUIID_XingHunSubStar]			= {name = "xinghunSubStar", layout = "xinghunjd1", order = eUIO_TOP_MOST},
	[eUIID_XingHunSubStarLock]		= {name = "xinghunSubStarLock", layout = "xinghunjd2", order = eUIO_TOP_MOST},
	[eUIID_XingHunSubStarPerfect]	= {name = "xinghunSubStarPerfect", layout = "xinghunjd3", order = eUIO_TOP_MOST},
	[eUIID_XingHunMainStarLock]		= {name = "xinghunMainStarLock", layout = "xinghunzhuxing", order = eUIO_TOP_MOST},
	[eUIID_XingHunMainStarPractice]	= {name = "xinghunMainStarPractice", layout = "xinghunzhuxing2", order = eUIO_TOP_MOST},
	[eUIID_XingHunOtherInfo]		= {name = "xinghunOtherInfo", layout = "cjbxx", order = eUIO_TOP_MOST},
	[eUIID_SteedFightPropUnlock]	= {name = "steedFightPropUnlock", layout = "zqqzjh", order = eUIO_TOP_MOST},
	[eUIID_SteedFightAwardProp]		= {name = "steedFightAwardProp", layout = "qzpfjl", order = eUIO_TOP_MOST},
	[eUIID_UseShowLoveItem]			= {name = "useShowLoveItem", layout = "djsysa", order = eUIO_TOP_MOST},
	[eUIID_ShowLoveItemUI]			= {name = "showLoveItemUI", layout = "shiaitx", order = eUIO_TOP_MOST},
	[eUIID_Adventure]				= {name = "adventure", layout = "qiyu", order = eUIO_TOP_MOST},
	[eUIID_ShootMsg]				= {name = "shootMsg", layout = "bpdm", order = eUIO_TOP_MOST},
	[eUIID_DragonHoleDialogue]		= {name = "dragon_hole_dialogue", layout = "db5", order = eUIO_TOP_MOST},
	[eUIID_SteedFightProp]			= {name = "steedFightProp", layout = "qztips", order = eUIO_TOP_MOST},
	[eUIID_StatueInfo]			    = {name = "statueInfo", layout = "rongyutang", order = eUIO_TOP_MOST},
	[eUIID_GoldenEggGifts]			= {name = "goldenEggGifts", layout = "jindantips2", order = eUIO_TOP_MOST},
	[eUIID_NewYearRedEnvelope]		= {name = "newYearRedEnvelope", layout = "xinnianhongbao", order = eUIO_TOP_MOST},
	[eUIID_LuckyPack]				= {name = "luckyPack", layout = "xinnianfudai", order = eUIO_TOP_MOST},
	[eUIID_LuckyPackTip]			= {name = "luckyPackTip", layout = "xinniantips", order = eUIO_TOP_MOST},
	[eUIID_SteedSpiritSkillUnlock]	= {name = "steedSpiritSkillUnLock", layout = "zqqzsj", order = eUIO_TOP_MOST},
	[eUIID_SteedSpiritSkillUp]		= {name = "steedSpiritSkillUp", layout = "zqqzsj2", order = eUIO_TOP_MOST},
	[eUIID_SteedSpiritSkillTips]	= {name = "steedSpiritSkillTips", layout = "zqqzsj3", order = eUIO_TOP_MOST},
	[eUIID_SteedSpiritShows]		= {name = "steedSpiritShows", layout = "zqqzhh", order = eUIO_TOP_MOST},
	[eUIID_SteedSpiritUpRank]		= {name = "steedSpiritUpRank", layout = "zqqzsjcg", order = eUIO_TOP_MOST},
	[eUIID_Dengmi]					= {name = "dengmi", layout = "xinnianyuanxiao", order = eUIO_TOP_MOST},
	[eUIID_DragonHoleAward]			= {name = "dragon_hole_award", layout = "lxjl", order = eUIO_TOP_MOST},
	[eUIID_FactionFightAward]		= {name = "factionFightAward", layout = "lxjl", order = eUIO_TOP_MOST},
	[eUIID_BuyOffineWizardExp]		= {name = "buyOffineWizardExp", layout = "gmjljy", order = eUIO_TOP_MOST},
	[eUIID_RedPacketTips]			= {name = "redPacketTips", layout = "xinnianhongbaotips", order = eUIO_TOP_MOST},
	[eUIID_RedPacketHelp]			= {name = "redPacketHelp", layout = "xinnianhongbaosm", order = eUIO_TOP_MOST},
	[eUIID_Bagua]					= {name = "bagua", layout = "bagua", order = eUIO_TOP_MOST},
	[eUIID_puzzlePic]				= {name = "puzzlePic", layout = "pintu", order = eUIO_TOP_MOST},
	[eUIID_BaguaStoneSelect]		= {name = "baguaStoneSelect", layout = "baguayuanshi", order = eUIO_TOP_MOST},
	[eUIID_BaguaSacrificeSelect]	= {name = "baguaSacrificeSelect", layout = "baguajipin", order = eUIO_TOP_MOST},
	[eUIID_BaguaExtract]			= {name = "baguaExtract", layout = "baguacuiqu", order = eUIO_TOP_MOST},
	[eUIID_BaguaSaleBat]			= {name = "baguaSaleBat", layout = "baguashushou", order = eUIO_TOP_MOST},
	[eUIID_BaguaTips]				= {name = "baguaTips", layout = "baguatips", order = eUIO_TOP_MOST},
	[eUIID_HitDiglett]				= {name = "hit_diglett", layout = "dadishu", order = eUIO_TOP_MOST},
	[eUIID_TripWizardItem]			= {name = "tripWizardItem", layout = "lxjs", order = eUIO_TOP_MOST},
	[eUIID_TripWizardPhotoAlbum]	= {name = "tripWizardPhotoAlbum", layout = "xiangce", order = eUIO_TOP_MOST},
	[eUIID_TripWizardPhotoBtn]		= {name = "tripWizardPhotoBtn", layout = "zdlx", },
	[eUIID_TripWizardPhotoShow]		= {name = "tripWizardPhotoShow", layout = "zhaopianhd", order = eUIO_TOP_MOST},
	[eUIID_TripWizardSharePhoto]	= {name = "tripWizardSharePhoto", layout = "jiehunzhengfx", order = eUIO_TOP_MOST},
	[eUIID_GlobalPveRule]			= {name = "globalPveRule", layout = "sdymjgz", order = eUIO_TOP_MOST},
	[eUIID_FactionWareHouse]		= {name = "factionWareHouse", layout = "bpck", order = eUIO_TOP_MOST},
	[eUIID_PvePeaceArea]				= {name = "pvePeaceArea", layout = "zdsdymj", order = eUIO_TOP_MOST},
	[eUIID_factionBusiness]			= {name = "factionBusiness", layout = "bpsl", order = eUIO_TOP_MOST},
	[eUIID_PinDuoDuoTips]			= {name = "pinDuoDuoTips", layout = "pinduoduotips", order = eUIO_TOP_MOST},
	[eUIID_FactionDungeonSpecialOver]		= {name = "faction_dungeon_special_over", layout = "bfjg2",order = eUIO_TOP_MOST},
	[eUIID_ShowLineInfo]			= {name="showBattleLineInfo", layout = "sdymjdzq",order=eUIO_TOP_MOST},
	[eUIID_PveBattleArea]			= {name="pveBattleArea", layout = "zdsdymj",order=eUIO_TOP_MOST},
	[eUIID_BaGuaSuit]   			= {name="baguaSuit", layout = "baguatz",order=eUIO_TOP_MOST},
	[eUIID_BaGuaGuide]   			= {name="baguaGuide", layout = "baguayd",order=eUIO_TOP_MOST},
	[eUIID_WareHouseItem]   		= {name="wareHouseItem", layout = "djtips",order=eUIO_TOP_MOST},
	[eUIID_SetWareHouseItemPrice]   = {name="setWareHouseItemPrice", layout = "bpckdj",order=eUIO_TOP_MOST},
	[eUIID_ApplyWareHouseItem]   	= {name="applyWareHouseItem", layout = "bpckdj2",order=eUIO_TOP_MOST},
	[eUIID_BuyBusinessStars]		= {name="buy_business_stars", layout = "bpsldz",order=eUIO_TOP_MOST},
	[eUIID_EquipTransFromTo]		= {name="equip_trans_from_to", layout = "zzxz",order=eUIO_TOP_MOST},
	[eUIID_MillionsAnswer]			= {name="millionsAnswer", layout = "baiwandati",order=eUIO_TOP_MOST},
	[eUIID_MillionsAnswerFailure]	= {name="millionsAnswerFailure", layout = "baiwandatisb",order=eUIO_TOP_MOST},
	[eUIID_MillionsAnswerSuccess]	= {name="millionsAnswerSuccess", layout = "baiwandaticg",order=eUIO_TOP_MOST},
	[eUIID_Divination]				= {name="divination", layout = "zhanbu",order=eUIO_TOP_MOST},
	[eUIID_DivinationReward]		= {name="divinationReward", layout = "zhanbu2",order=eUIO_TOP_MOST},
	[eUIID_Adventure2]				= {name = "adventure2", layout = "qiyu2", order = eUIO_TOP_MOST},
	[eUIID_Adventure3]				= {name = "adventure3", layout = "qiyu3", order = eUIO_TOP_MOST},
	[eUIID_SuperArenaWeaponSet]		= {name = "superArenaWeaponSet", layout = "sbxz", order = eUIO_TOP_MOST},
	[eUIID_BattleTouramentWeapon]	= {name = "battleTouramentWeapon", layout = "zdsqlz", order = eUIO_TOP_MOST},
	[eUIID_DescTips]				= {name = "descTips", layout = "sqlzjn", order = eUIO_TOP_MOST},
	[eUIID_TournamentWeaponResult]	= {name = "tournamentWeaponResult", layout = "sqlzzj", order = eUIO_TOP_MOST},
	[eUIID_fiveTrans]				= {name = "fiveTrans", layout = "wzzl", order = eUIO_TOP_MOST},
	[eUIID_MoodDiary]				= {name = "moodDiary", layout = "xinqingriji", order = eUIO_TOP_MOST},
	[eUIID_DiaryContent]			= {name = "diaryContent", layout = "xinqingrijix", order = eUIO_TOP_MOST},
	[eUIID_SingleChallenge]			= {name = "single_challenge", layout = "danrenchuangguan", order = eUIO_TOP_MOST},
	[eUIID_DestinyRoll]				= {name = "destinyRoll", layout = "wzzltml", order = eUIO_TOP_MOST},
	[eUIID_PigeonPost]				= {name = "pigeon_post", layout = "feigechuanshuzs"},
	[eUIID_PigeonPostSend]			= {name = "pigeon_post_send", layout = "feigechaunshu", order = eUIO_TOP_MOST},
	[eUIID_WeaponEffect]			= {name = "weapon_effect", layout = "huanling", order = eUIO_TOP_MOST},
	[eUIID_FansRank]				= {name = "moodDiaryFansRank", layout = "gongxianpaihang", order = eUIO_TOP_MOST},
	[eUIID_SendGift]				= {name = "moodDiarySendGift", layout = "zengsongliwu", order = eUIO_TOP_MOST},
	[eUIID_MoodDiaryBeauty]			= {name = "moodDiaryBeauty", layout = "xinqingrijimh", order = eUIO_TOP_MOST},
	[eUIID_FulingAddPoint]			= {name = "fulingAddPoint", layout = "lyfljd", order = eUIO_TOP_MOST},
	[eUIID_FulingUpLevel]			= {name = "fulingUpLevel", layout = "lyflsx", order = eUIO_TOP_MOST},
	[eUIID_FulingUpLevelMax]		= {name = "fulingUpLevelMax", layout = "lyflsx2", order = eUIO_TOP_MOST},
	[eUIID_FulingReset]				= {name = "fulingReset", layout = "lyflcz", order = eUIO_TOP_MOST},
	[eUIID_FulingTips]				= {name = "fulingTips", layout = "lyfltips", order = eUIO_TOP_MOST},
	[eUIID_SingleChallengeFailed]	= {name = "singleChallengeFailed", layout = "sbjs", order = eUIO_TOP_MOST},
	[eUIID_UseVit]					= {name = "useVit", layout = "tlsy", order = eUIO_TOP_MOST},
	[eUIID_MoodDiaryShare]			= {name = "moodDiary_share", layout = "xinqingrijifx", order = eUIO_TOP_MOST},
	[eUIID_SingleBuffTips]			= {name = "single_buff_tips", layout = "danrenchuangguantips", order = eUIO_TOP_MOST},
	[eUIID_sweepActivity]			= {name = "sweepActivity", layout = "shiliansaodang2", order = eUIO_TOP_MOST},
	[eUIID_TransfromAnimate]		= {name = "transfrom_animate", layout = "zzcgdh", order = eUIO_TOP_MOST},
	[eUIID_FactionAssist]			= {name = "factionAssist", layout = "lixianzhuzhan", order = eUIO_TOP_MOST},
	[eUIID_PowerReputation]			= {name = "powerReputation", layout = "shengwang", order = eUIO_TOP_MOST},
	[eUIID_PowerReputationCommit]	= {name = "powerReputationCommit", layout = "shengwangjz", order = eUIO_TOP_MOST},
	[eUIID_PowerReputationTask]		= {name = "powerReputationTask", layout = "shengwangrw", order = eUIO_TOP_MOST},
	[eUIID_MoodDiaryAnimate1]		= {name = "moodDiaryAnimate1", layout = "xinqingrijihj", order = eUIO_TOP_MOST},
	[eUIID_MoodDiaryAnimate2]		= {name = "moodDiaryAnimate2", layout = "xinqingrijihj", order = eUIO_TOP_MOST},
	[eUIID_BattleShowPowerRep]		= {name = "battleShowPowerRep", layout = "pz2"},
	[eUIID_ShowLove]				= {name = "showLove", layout = "gaobaix", order = eUIO_TOP_MOST},
	[eUIID_ShowLoveWish]			= {name = "showLoveWish", layout = "gaobaizf", order = eUIO_TOP_MOST},
	[eUIID_ProtectMelon]			= {name = "protectMelon", layout = "baoweixigua", order = eUIO_TOP_MOST},
	[eUIID_ChessTaskAccept]			= {name = "chess_task_accept", layout = "zhenlongqiju1", order = eUIO_TOP_MOST},
	[eUIID_ChessTaskThink]			= {name = "chess_task_think", layout = "zhenlongqijusk", order = eUIO_TOP_MOST},
	[eUIID_ChessTaskEnd]			= {name = "chess_task_end", layout = "zhenlongqijujs", order = eUIO_TOP_MOST},
	[eUIID_ChessTaskVerse]			= {name = "chess_task_verse", layout = "zhenlongqijusj", order = eUIO_TOP_MOST},
	[eUIID_ChessTaskFindDiff]		= {name = "chessTaskFindDiff", layout = "zhenlongqijuzbt", order = eUIO_TOP_MOST},
	[eUIID_HomeLandMain]			= {name = "homeLandMain", layout = "jiayuan", order = eUIO_TOP_MOST},
	[eUIID_HomeLandCreate]			= {name = "homelandCreate", layout = "jiayuancj", order = eUIO_TOP_MOST},
	[eUIID_HomeLandChangeName]		= {name = "homeLandChangeName", layout = "jiayuanxgmz", order = eUIO_TOP_MOST},
	[eUIID_HomeLandEquipBag]		= {name = "homeLandEquipBag", layout = "yugan", order = eUIO_TOP_MOST},
	[eUIID_HomeLandFish]			= {name = "homeLandFish", layout = "diaoyu", order = eUIO_TOP_MOST},
	[eUIID_HomeLandEquipTips]		= {name = "homeLandFishEquipTips", layout = "yugantips", order = eUIO_TOP_MOST},
	[eUIID_HomeLandEvent]			= {name = "homeLandEvent", layout = "jiayuansj", order = eUIO_TOP_MOST},
	[eUIID_HomeLandFishPrompt]		= {name = "homeLandFishPrompt", layout = "diaoyutips", order = eUIO_TOP_MOST},
	[eUIID_BaguaSplitSure]			= {name = "baguaSplitSure", layout = "baguaerciqueren", order = eUIO_TOP_MOST},
	[eUIID_HomelandPlant]			= {name = "homeland_plant", layout = "jiayuanzz", order = eUIO_TOP_MOST},
	[eUIID_HomelandPlantOperate]	= {name = "homeland_plant_operate", layout = "jiayuancz", order = eUIO_TOP_MOST},
	[eUIID_WorldCup]				= {name = "world_cup", layout ="shijiebei", order = eUIO_TOP_MOST},
	[eUIID_WorldCupYaZhu]			= {name = "world_cup_yazhu", layout ="shijiebeiyz", order = eUIO_TOP_MOST },
	[eUIID_WorldCupResult]			= {name = "world_cup_result", layout = "shijiebeijg", order = eUIO_TOP_MOST},
	[eUIID_NpcDonate]				= {name = "npcDonate", layout = "fodanjie", order = eUIO_TOP_MOST},
	[eUIID_ChessTaskAnimate]		= {name = "chess_task_animate", layout = "zhenlongqijudh", order = eUIO_TOP_MOST},
	[eUIID_HomeLandStructure]		= {name = "homeland_structure", layout = "jiangyuanjz", order = eUIO_TOP_MOST},
	[eUIID_ChessTaskRank]			= {name = "chess_task_rank", layout = "zhenlongqijuph", order = eUIO_TOP_MOST},
	[eUIID_MoodDiaryAnimate3]		= {name = "moodDiaryAnimate3", layout = "xinqingrijitx", order = eUIO_TOP_MOST},
	[eUIID_MoodDiaryShowGifts]		= {name = "moodDiary_show_gifts", layout = "xinqingrijixx", order = eUIO_TOP_MOST},
	[eUIID_MoodDiaryEffect]			= {name = "moodDiaryEffect", layout = "xinqingrijilw", order = eUIO_BOARDTOP},
	[eUIID_MoodDiaryEffectGift]		= {name = "moodDiaryEffectGift", layout = "xinqingrijitx", order = eUIO_BOARDTOP},
	[eUIID_MoodDiaryEffectRocket]	= {name = "moodDiaryEffectRocket", layout = "xinqingrijihj", order = eUIO_BOARDTOP},
	[eUIID_MoodDiaryEffectRocket2]	= {name = "moodDiaryEffectRocket2", layout = "xinqingrijihj2", order = eUIO_BOARDTOP},
	[eUIID_ChessTaskDiffAnimate]	= {name = "chess_task_diff_animate", layout = "zhenlongqijusl", order = eUIO_TOP_MOST},
	[eUIID_ChessTaskPuzzle]			= {name = "chess_task_puzzle", layout = "pintu", order = eUIO_TOP_MOST},
	[eUIID_ThumbtackScollUI]		= {name = "thumbtackScoll", layout = "tuding", order = eUIO_TOP_MOST},
	[eUIID_ThumbtackDetail]			= {name = "thumbtackDetail", layout = "tudingcj", order = eUIO_TOP_MOST},
	[eUIID_ThumbtackTransferNol]	= {name = "thumbtackTransferNol", layout = "tudingts2", order = eUIO_TOP_MOST},
	[eUIID_ThumbtackTransferVip]	= {name = "thumbtackTransferVip", layout = "tudingts1", order = eUIO_TOP_MOST},
	[eUIID_ThumbtackDelete]			= {name = "thumbtackDelete", layout = "tudingxg", order = eUIO_TOP_MOST},
	[eUIID_BagSearch]				= {name = "bagSearch", layout = "bgss", order = eUIO_TOP_MOST},	--
	[eUIID_XinJue]					= {name = "xinjue", layout = "xinjue", order = eUIO_TOP_MOST},
	[eUIID_VipStoreCallItemBuy]		= {name = "vip_store_call_item_buy", layout = "zqgm", order = eUIO_TOP_MOST},
	[eUIID_XinJueTips]				= {name = "xinjuetips", layout = "xinjuetips", order = eUIO_TOP_MOST},
	[eUIID_FirstLoginShow]			= {name = "firstLoginShow", layout = "zaizhanjianghu", order = eUIO_BOARDTOP},
	[eUIID_UnlockSteedAddSpirit]	= {name = "unlockSteedAddSpirit", layout = "wuhunjs", order = eUIO_TOP_MOST},
	[eUIID_TaskGuide]				= {name = "taskGuide", layout = "jiantouzy", order = eUIO_BOTTOM},
	[eUIID_XinJueKq]				= {name = "xinjuekq", layout = "xinjuekq", order = eUIO_TOP_MOST},
	[eUIID_ChessTaskCross]			= {name = "chess_task_cross", layout = "zhenlongqijucy", order = eUIO_TOP_MOST},
	[eUIID_VipGiftDisTips]			= {name = "vipGiftDisTips", layout = "viplbtips", order = eUIO_TOP_MOST},
	[eUIID_XinJueBreakSuccess]		= {name = "xinjuetpcg", layout = "xinjuetpcg", order = eUIO_TOP_MOST},
	[eUIID_HideWeapon]				= {name = "hideWeapon", layout = "anqi"},
	[eUIID_HideWeaponActiveSkill]	= {name = "hideWeaponActiveSkill", layout = "anqijnsj", order = eUIO_TOP_MOST},
	[eUIID_HideWeaponPassiveSkill]	= {name = "hideWeaponPassiveSkill", layout = "anqijn", order = eUIO_TOP_MOST},
    [eUIID_HideWeaponBattle]		= {name = "hideWeaponBattle", layout = "zdanqi", order = eUIO_TOP_MOST},
    [eUIID_HideWeaponActiveSkillLock] = {name = "hideWeaponActiveSkillLock", layout = "anqijntips", order = eUIO_TOP_MOST},
	[eUIID_HomeLandMap]				= {name = "homelandMap", layout = "bpdt", order = eUIO_TOP_MOST},
	[eUIID_HomelandCustomer]		= {name = "homeland_customers", layout = "jiayuantr", order = eUIO_TOP_MOST},
	[eUIID_FamilyDonate]			= {name = "familyDonate", layout = "bangpaihuzhu", order = eUIO_TOP_MOST},
	[eUIID_FamilyDonateRoles]		= {name = "familyDonateRoles", layout = "bangpaihuzhujzz", order = eUIO_TOP_MOST},
	[eUIID_ApplyWareHouseItemSecond]  = {name = "applyWareHouseItemSecond", layout = "bpckdj3",order = eUIO_TOP_MOST},
	[eUIID_EffectFashionTips]		= {name ="effectFashionTips", layout = "shizhuangtips", order = eUIO_TOP_MOST},
	[eUIID_SpiritBossReward]		= {name ="spiritBossReward", layout = "julinggongchengjl", order = eUIO_TOP_MOST,},
	[eUIID_SpiritBossResult]		= {name ="spiritBossResult", layout = "julinggongchengjs", order = eUIO_TOP_MOST,},
	[eUIID_SpiritBossFight]			= {name ="spiritBossFight", layout = "zdjlgc",},
	[eUIID_ChangeNpcList]	    	= {name ="changeNpcList", layout = "dhnpclb", order = eUIO_TOP_MOST,},
    [eUIID_DefenceWarBattle]	    = {name ="defenceWarBattle", layout = "zdchengzhan", order = eUIO_TOP_MOST,},
    [eUIID_DefenceWarBid]	        = {name = "defenceWarBid", layout = "chengzhanjb", order = eUIO_TOP_MOST,},
    [eUIID_DefenceWarBidRes]	    = {name = "defenceWarBidRes", layout = "chengzhangs", order = eUIO_TOP_MOST,},
    [eUIID_DefenceWarBidSure]	    = {name = "defenceWarBidSure", layout = "chengzhanjbqr", order = eUIO_TOP_MOST,},
    [eUIID_DefenceWarReLife]	    = {name = "defenceWarReLife", layout = "chengzhanfh", order = eUIO_TOP_MOST,},
    [eUIID_DefenceWarReward]	    = {name = "defenceWarReward", layout = "chengzhanjl", order = eUIO_TOP_MOST,},
    [eUIID_DefenceWarSignIn]	    = {name ="defenceWarSignIn", layout = "chengzhanbm", order = eUIO_TOP_MOST,},
    [eUIID_DefenceWarSure]	    	= {name ="defenceWarSure", layout = "chengzhanbmqr", order = eUIO_TOP_MOST,},
    [eUIID_DefenceWarMap]       	= {name = "defenceWarMap", layout = "chengzhandt", order = eUIO_TOP_MOST,},
    [eUIID_DefenceWarTrans]       	= {name = "defenceWarTrans", layout = "chengzhandt", order = eUIO_TOP_MOST,},
    [eUIID_DefenceWarResult]       	= {name = "defenceWarResult", layout = "chengzhanlk", order = eUIO_TOP_MOST,},
    [eUIID_DefenceWarExpTips]		= {name = "defenceWarExpTips", layout = "bufftips3", order = eUIO_BOTTOM,},
	[eUIID_HuoBan]	    	        = {name ="huobanRecall", layout = "huoban", order = eUIO_TOP_MOST,},
	[eUIID_HuoBanCode]	    	    = {name ="huobanCode", layout = "huobanmasr", order = eUIO_TOP_MOST,},
	[eUIID_UnlockOutcastTips]	    = {name ="unlockOutcastTips", layout = "rchwzjs", order = eUIO_TOP_MOST,},
	[eUIID_OutCastBattle]			= {name = "outCastBattle", layout = "zdss"},
	[eUIID_AnqiSelect]				= {name = "anqiSelect", layout = "zdanqiqh"},
	[eUIID_HelpPanel]				= {name = "help_panel",layout = "jybz",order = eUIO_TOP_MOST},
	[eUIID_OutCastFinish]			= {name = "outCastFinish",layout = "rchwztg",order = eUIO_TOP_MOST},
	[eUIID_HideWeaponHuanhua]		= {name = "hideWeaponHuanhua",layout = "anqihh",order = eUIO_TOP_MOST},
	[eUIID_HideWeaponHuanhuaTips]	= {name = "hideWeaponHuanhuaTips",layout = "anqihhtips",order = eUIO_TOP_MOST},
	[eUIID_HideWeaponHuanhuaUnlock]	= {name = "hideWeaponHuanhuaUnlock",layout = "anqihhjs",order = eUIO_TOP_MOST},
	[eUIID_MoodDiaryEffect3]		= {name = "moodDiaryEffect3", layout = "xinqingrijihlb", order = eUIO_TOP_MOST},
	[eUIID_HuoBanBonus]		        = {name = "huobanBonus", layout = "huobanyqxq", order = eUIO_TOP_MOST},
	[eUIID_DisCountBuyPower]		= {name = "disCountBuyPower", layout = "shangpinzhekou", order = eUIO_TOP_MOST},
	[eUIID_HuoBanCopy]		        = {name = "huobanCopy", layout = "huobanmats", order = eUIO_TOP_MOST},
	[eUIID_EquipTemper]				= {name = "equip_temper", layout = "zbcl", isPad = true},
	[eUIID_HomeLandRelease]			= {name = "jiayuanfangsheng", layout = "fangsheng", order = eUIO_TOP_MOST},
	[eUIID_HomeLandProduce]			= {name = "homeLandProduce", layout = "jiayuansc", order = eUIO_TOP_MOST},
	[eUIID_EquipTemperSkillDes]		= {name = "equip_temper_skill_des", layout = "zbcljn", order = eUIO_TOP_MOST,},
	[eUIID_EquipTemperSkillActive]  = {name = "equip_temper_skill_active", layout = "zbcljnjh", order = eUIO_TOP_MOST,},
	[eUIID_HouseBase]  				= {name = "house_base", layout = "jiayuanjj"},
	[eUIID_HouseFurniture]			= {name = "house_furniture", layout = "jiayuanjjbf"},
	[eUIID_HouseFurnitureSet]		= {name = "house_furniture_set", layout = "jiayuanjjxz", order = eUIO_TOP_MOST,},
	[eUIID_EquipTemperWash]			= {name = "equip_temper_wash", layout = "zbclxl", isPad = true},
	[eUIID_HouseBuildinfo]          = {name = "homebuild_help",layout = "jiayuanjzsm",order = eUIO_TOP_MOST, },
	[eUIID_EquipTemperStarPreview]	= {name = "equip_temper_star_preview", layout = "zbclqs", order = eUIO_TOP_MOST,},
	[eUIID_EquipTemperSkillUp]		= {name = "equip_temper_skill_up", layout = "zbcljnsj", order = eUIO_TOP_MOST,},
	[eUIID_HomeLandOverview]		= {name = "homelandOverView", layout = "jiayuanzonglan", order = eUIO_TOP_MOST,},
	[eUIID_ShenBingBingHun]			= {name = "shen_bing_awake_bing_hun", layout = "shenbingbinghun", order = eUIO_TOP_MOST,},
	[eUIID_ShenBingBingHunShengJi]  = {name = "shen_bing_awake_bing_hun_sheng_ji", layout = "shenbingbinghunsj", order = eUIO_TOP_MOST,},
	[eUIID_ShenBingShenYao]			= {name = "shen_bing_shen_yao", layout = "shenbingshenyao", order = eUIO_TOP_MOST,},
	[eUIID_HomelandAddition]		= {name = "homelandAddition", layout = "jiayuanjjgz", order = eUIO_TOP_MOST,},
	[eUIID_TimingActivity]          = {name = "timingactivity", layout= "dingqihuodong" , order = eUIO_TOP_MOST,},
	[eUIID_TimingActivityTips]      = {name = "timingactivity_tips", layout = "dingqihuodongtips" , order = eUIO_TOP_MOST, },
	[eUIID_DefenceWarMember]        = {name = "defencewarMember", layout = "zdchengzhan2" , order = eUIO_TOP_MOST, },	
	[eUIID_PassExamGift]			= {name = "passExamGift", layout = "dengkeyouli" , order = eUIO_TOP_MOST, },
	[eUIID_PassExamGiftReward]		= {name = "passExamGiftReward", layout = "dengkeyoulijl" , order = eUIO_TOP_MOST, },
	[eUIID_HouseSkin]				= {name = "house_skin", layout = "jiayuanzb" , order = eUIO_TOP_MOST, },
	[eUIID_SpiritBlessing]			= {name = "faction_blessing", layout = "bpzf", order = eUIO_TOP_MOST,},
	[eUIID_BlessingInfoTips]		= {name = "faction_blessing_tips", layout = "bpzdjltips", order = eUIO_TOP_MOST,},
	[eUIID_VipStoreHomeland]		= {name = "vip_store_homeland", layout = "jygm" , order = eUIO_TOP_MOST, },
	[eUIID_KillTips]				= {name = "killTips", layout = "zdshalu" , order = eUIO_TOP_MOST, },
	[eUIID_FactionGarrisonSpirit]	= {name = "faction_garrison_spirit", layout = "zdzdjl", order = eUIO_TOP_MOST, }, --zdzdjl
	[eUIID_SpiritSkillTips]			= {name = "spirit_skill_tips", layout = "zdzdjljntips", order = eUIO_TOP_MOST,},
	[eUIID_SetConstellation]		= {name = "setConstellation", layout = "xinqingrijixz", order = eUIO_TOP_MOST,},
	[eUIID_SetHobby]				= {name = "setHobby", layout = "xinqingrijiah", order = eUIO_TOP_MOST,},
	[eUIID_BattleIllusory]			= {name = "battle_illusory", layout = "zdhuanjingshilian",},
	[eUIID_WriteDiyHobby]			= {name = "writeDiyHobby", layout = "xinqingrijix", order = eUIO_TOP_MOST,},
	[eUIID_FactionBlessingBufTips]	= {name = "factionBlessinBufTips", layout = "bufftips3", order = eUIO_BOTTOM, },
	[eUIID_MarryAchievement]		= {name = "marry_achievement", layout = "jhfqcj", order = eUIO_TOP_MOST,},
	[eUIID_SpiritSkill]				= {name = "spirit_skill", layout = "zdzdjl2", order = eUIO_TOP_MOST, },
	[eUIID_SetSex]					= {name = "setSex", layout = "xinyuxingyuanxb", order = eUIO_TOP_MOST, },
	[eUIID_ConstellationTest]		= {name = "constellationTest", layout = "xinyuxingyuan", order = eUIO_TOP_MOST, },
	[eUIID_MarryAchievementShow]	= {name = "marry_achievement_show", layout = "rcbtips", order = eUIO_TOP_MOST, },
	[eUIID_ConstellationTestResult]	= {name = "constellationTestResult", layout = "xinyuxingyuanjg", order = eUIO_TOP_MOST, },
	[eUIID_ConstellationTestShare]	= {name = "constellationTestShare", layout = "xinyuxinyuanfx", order = eUIO_TOP_MOST},
	[eUIID_WriteDeclaration]		= {name = "writeDeclaration", layout = "xinqingrijix", order = eUIO_TOP_MOST,},
	[eUIID_LuckyStarGift]			= {name = "lucky_star_gift", layout = "lipin", order = eUIO_TOP_MOST,},
	[eUIID_AddCrossFriends]			= {name = "addCrossFriends", layout = "kuafuhaoyoupp", order = eUIO_TOP_MOST,},
	[eUIID_PetDungeonChoseMap]		= {name = "petDungeonMapChose", layout = "chongwushiliandw", order = eUIO_TOP_MOST,},
	[eUIID_PetDungeonChosePet]		= {name = "petDungeonChosepet", layout = "chongwushiliancz", order = eUIO_TOP_MOST,},
	[eUIID_ImportantNotice]			= {name = "importantNotice", layout = "zhongyaotongzhi", order = eUIO_TOP_MOST,},	
	[eUIID_PetDungeonBattleBase]	= {name = "battlePetDungeonBase", layout = "zdchongwushilian", order = eUIO_TOP_MOST,},
	[eUIID_ConstellationTip]		= {name = "constellationTip", layout = "xinyuxingyuants", order = eUIO_TOP_MOST,},
	[eUIID_PetDungeonTaskDetail]	= {name = "petDungeonTaskDetail", layout = "chongwushilianrwzy", order = eUIO_TOP_MOST,},
	[eUIID_PetDungeonGatherDetail]	= {name = "petDungeonGatherDetail", layout = "chongwushiliancjzy", order = eUIO_TOP_MOST,},
	[eUIID_PetEquip]				= {name = "petEquip", layout = "xunyangbg", order = eUIO_TOP_MOST},
	[eUIID_PetDungeonReceiveTask]	= {name = "petDungeonReceiveTask", layout = "shengwangrw", order = eUIO_TOP_MOST,},	
	[eUIID_CrossFriendsApply]		= {name = "crossFriendsApply", layout = "kuafuhaoyousq", order = eUIO_TOP_MOST,},	
	[eUIID_QuickWeaponTaskConfirm]	= {name = "quickWeaponTaskConfirm", layout = "sbrwkuaisu"},
	[eUIID_PetDungeonrRewards]		= {name = "petDungeonReward", layout = "chongwushiliansy", order = eUIO_TOP_MOST,},
	[eUIID_PetDungeonrEvents]		= {name = "petDungeonEvent", layout = "chongwushilianxysj", order = eUIO_TOP_MOST,},
	[eUIID_PetEquipUpLevel]			= {name = "petEquipUpLevel", layout = "xunyangzbsj", order = eUIO_TOP_MOST},
	[eUIID_PetDungeonrMiniMap]		= {name = "battlePetDungeonMap", layout = "bpdt", order = eUIO_TOP_MOST,},
	[eUIID_PetGahterOperation]		= {name = "petGahterOperation", layout = "chongwushiliancj", order = eUIO_TOP_MOST,},
	[eUIID_PetEquipInfoTips]		= {name = "petEquipInfoTips", layout = "xunyangzbtips", order = eUIO_TOP_MOST,},
	[eUIID_PetEquipSaleBat]			= {name = "petEquipSaleBat", layout = "xunyangplcs", order = eUIO_TOP_MOST,},
	[eUIID_PetDungeonReadingbar]	= {name = "petDungeonGahterReadingbar", layout = "jdt", order = eUIO_TOP_MOST,},	
	[eUIID_PetEquipSkillUpLvl]		= {name = "petEquipSkillUpLvl", layout = "xunyangsljn", order = eUIO_TOP_MOST},
	[eUIID_PetEquipSkillUpGrade]	= {name = "petEquipSkillUpGrade", layout = "xunyangjnsj", order = eUIO_TOP_MOST,},
	[eUIID_HomeLandAutoFishTips]	= {name = "homeLandAutoFishTips", layout = "dyz", order = eUIO_TOP,},
	[eUIID_PetEquipRankList]		= {name = "petEquipRankList", layout = "xunyangphb", order = eUIO_TOP_MOST,},
	[eUIID_BattleDesertHero]		= {name = "battleDesertHero", layout = "juezhanhuangmoyx", order = eUIO_TOP_MOST,},
	[eUIID_BattleDesertAward]		= {name = "battleDesertAward", layout = "juezhanhuangmojl", order = eUIO_TOP_MOST,},
	[eUIID_DesertBattleMiniMap]		= {name = "battleDesertMap", layout = "fmddt", order = eUIO_TOP_MOST,},
	[eUIID_SwornIntroduce]			= {name = "swornIntroduce", layout = "jiebaijs", order = eUIO_TOP_MOST,},
	[eUIID_DesertBattleWatchWar]	= {name = "battleDesertWatchWar", layout = "zdjuezhanhuangmogz", order = eUIO_TOP_MOST,},
	[eUIID_BattleFubenDesert]		= {name = "battleFubenDesert", layout = "zdjuezhanhuangmo", order = eUIO_TOP_MOST},
	[eUIID_DesertBattleFindWayTips]	= {name = "desertFindWayStateTips",  layout = "juezhanhuangmodh", order = eUIO_TOP,},
	[eUIID_WeekLimitReward]			= {name = "weekLimitReward", layout = "dlsltips2", order = eUIO_TOP_MOST,},
    [eUIID_Wujue]               	= {name = "wujue", layout = "wujue", order = eUIO_TOP_MOST,},
    [eUIID_WujueBreak]	            = {name = "wujueBreak", layout = "wujuetp", order = eUIO_TOP_MOST,},
    [eUIID_WujueBreakFull]	        = {name = "wujueBreakFull", layout = "wujuetpm", order = eUIO_TOP_MOST,},
    [eUIID_WujueRules]	            = {name = "wujueRules", layout = "wujuegz1", order = eUIO_TOP_MOST,},
    [eUIID_WujueUseItems]	        = {name = "wujueUseItems", layout = "wujueyjsy", order = eUIO_TOP_MOST,},
    [eUIID_WujueSkillActive]	    = {name = "wujueSkillActive", layout = "wujuejnjh", order = eUIO_TOP_MOST,},
    [eUIID_WujueSkillFull]	        = {name = "wujueSkillFull", layout = "wujuejnm", order = eUIO_TOP_MOST,},
    [eUIID_WujueSkillUpLevel]	    = {name = "wujueSkillUpLevel", layout = "wujuejnsj", order = eUIO_TOP_MOST,},
    [eUIID_BattleDesertPunish]		= {name = "battleDesertPunish", layout = "juezhanhuangmocf", order = eUIO_TOP_MOST,},
	[eUIID_SignInExtraAward]		= {name = "sign_in_extra_award", layout = "qdjl",order = eUIO_TOP_MOST},
	[eUIID_DesertPersonalResult]	= {name = "desertPersonalResult", layout = "juezhanhuangmojs1",order = eUIO_TOP_MOST},
	[eUIID_DesertTeamResult]		= {name = "desertTeamResult", layout = "juezhanhuangmojs2",order = eUIO_TOP_MOST},
	[eUIID_SwornDate]				= {name = "swornDate", layout = "jiebailc1", order = eUIO_TOP_MOST,},
	[eUIID_BattleDesertBag]			= {name = "battleDesertBag", layout = "juezhanhuangmobg", order = eUIO_TOP_MOST,},
	[eUIID_BattleDesertEquipTips]	= {name = "battleDesertEquipTips", layout = "juezhanhuangmozbtips", order = eUIO_TOP_MOST,},
	[eUIID_BattleDesertItemTips]	= {name = "battleDesertItemTips", layout = "juezhanhuangmodjtips", order = eUIO_TOP_MOST,},
	[eUIID_WeekBoxGetTips]			= {name = "weekBoxGetTips", layout = "dlsltips3", order = eUIO_TOP_MOST,},
	[eUIID_SetSwornPrefix]			= {name = "setSwornPrefix", layout = "jiebailc2", order = eUIO_TOP_MOST,},
	[eUIID_MetamorphosisDressTips]  = {name = "metamorphosis_dress_tips", layout = "sztips",order = eUIO_TOP_MOST },
	[eUIID_SwornAnim]  				= {name = "swornAnim", layout = "jiebaicgdh",order = eUIO_TOP_MOST },
	[eUIID_SwornModify]  			= {name = "swornModify", layout = "jiebaijm",order = eUIO_TOP_MOST },
	[eUIID_WuJueKQ]					= {name = "wujueOpen", layout = "wujuekq", order = eUIO_TOP_MOST },
	[eUIID_SwornKick]				= {name = "sworn_kick", layout = "jiebaiqljr", order = eUIO_TOP_MOST },
	[eUIID_SwornChangeName]			= {name = "sworn_change_name", layout = "jiebaixgcw", order = eUIO_TOP_MOST },
	[eUIID_SwornCallFriends]		= {name = "sworn_call_friends", layout = "jiebaijf", order = eUIO_TOP_MOST },
	[eUIID_SwornValueDesc]			= {name = "sworn_value_desc", layout = "jiebaijlz", order = eUIO_TOP_MOST },
	[eUIID_WujueRank]				= {name = "wujueRank", layout = "wujuephb", order = eUIO_TOP_MOST },
	[eUIID_WujueDH]					= {name = "wujueDH", layout = "wujuedh", order = eUIO_TOP_MOST},
	[eUIID_MemoryCard]				= {name = "memoryCard", layout = "fanfanle", order = eUIO_TOP_MOST},
	[eUIID_BuyFulingPoint]			= {name = "buyFulingPoint", layout = "gmfpd", order = eUIO_TOP_MOST},
	[eUIID_MazeBattleInfo]			= {name = "mazeBattleInfo", layout = "zdtianmomigong", order = eUIO_TOP_MOST},
	[eUIID_MazeBattleBenifit]		= {name = "mazeBattleBenifit", layout = "tianmomigongsy", order = eUIO_TOP_MOST},
	[eUIID_DoorOfXiuLianFuBen]		= {name = "xiulianzhimen", layout = "hudxlzm"},
	[eUIID_DoorOfXiuLianResult]		= {name = "xiulianzhimenjiesuan", layout = "xlzm_js", order = eUIO_TOP_MOST},
	[eUIID_XingJun]					= {name = "answerEntrance", layout = "xj", order = eUIO_TOP_MOST,},
	[eUIID_FiveHegemony]			= {name = "fiveFightHegemony", layout = "wjzb", order = eUIO_TOP_MOST,},
	[eUIID_FestivalLimitTask]		= {name = "festival_limit_task", layout = "canyutiaojian", order = eUIO_TOP_MOST,},
    [eUIID_SteedSprite]		       = {name = "steedSprite", layout = "liangjuzhiling", order = eUIO_TOP_MOST,},
    [eUIID_SteedEquip]		       = {name = "steedEquip", layout = "qizhanzhuangbei", order = eUIO_TOP_MOST,},
    [eUIID_SteedEquipPropTip]	   = {name = "steedEquipPropTip", layout = "qizhanzhuangbeitips", order = eUIO_TOP_MOST,},
    [eUIID_SteedStove]		       = {name = "steedStove", layout = "qizhanronglu", order = eUIO_TOP_MOST,},
    [eUIID_SteedSuit]		       = {name = "steedSuit", layout = "qizhantaozhuang", order = eUIO_TOP_MOST,},
    [eUIID_SteedSuitActive]		   = {name = "steedSuitActive", layout = "qizhantaozhuangjh", order = eUIO_TOP_MOST,},
    [eUIID_steedEquipMake]	       = {name = "steedEquipMake", layout = "qizhanzhuangbeidz", order = eUIO_TOP_MOST,},
    [eUIID_steedEquipPropCmp]	   = {name = "steedEquipPropCmp", layout = "qizhanzhuangbeitips2", order = eUIO_TOP_MOST,},
    [eUIID_steedEquipSale]	       = {name = "steedEquipSale", layout = "qizhanzhuangbeiplrl1", order = eUIO_TOP_MOST,},
    [eUIID_steedEquipSale2]	       = {name = "steedEquipSale2", layout = "qizhanzhuangbeiplrl2", order = eUIO_TOP_MOST,},
    [eUIID_LingQianQiFuDialog]		= {name = "lingQianQiFuDialog", layout = "qifu3", order = eUIO_TOP_MOST,},
	[eUIID_LingQianQiFuResult]		= {name = "lingQianQiFuResult", layout = "qifu3jg", order = eUIO_TOP_MOST,},
	[eUIID_FiveHegemonyShow]		= {name = "hegemonyRewardShow", layout = "wjzbjl", order = eUIO_TOP_MOST,},
	[eUIID_BaGuaSacrificeCheck]		= {name = "baguaSacrifaceCheck", layout = "baguajipin2", order = eUIO_TOP_MOST,},
	[eUIID_BaGuaSacrificeSplit]		= {name = "baguaSacrifaceSplit", layout = "baguajipincf", order = eUIO_TOP_MOST,},
	[eUIID_FiveHegemonySkill]		= {name = "fiveHegemonyNpcSkill", layout = "wjzbjn", order = eUIO_TOP_MOST,},
	[eUIID_BaGuaSacrificeCompound]	= {name = "baguaSacrifaceCompound", layout = "baguajipinhc", order = eUIO_TOP_MOST,},
	[eUIID_ShakeTree]				= {name = "shakeTree", layout = "yaoqianshu", order = eUIO_TOP_MOST,},
	[eUIID_ChannelMigrationTips]	= {name = "channelMigrationTips", layout = "zhanghaoqianyi", order = eUIO_TOP_MOST,},
	[eUIID_LingQianAnimation]		= {name = "lingQianQiFuAnimation", layout = "qifu3dh", order = eUIO_TOP_MOST,},
	[eUIID_HomePetDialogue]			= {name = "home_pet_dialogue", layout = "db5", order = eUIO_TOP_MOST,},
	[eUIID_HomePetOperate]			= {name = "home_pet_operate", layout = "jiayuanshouhu", order = eUIO_TOP_MOST,},
	[eUIID_HomePetOther]			= {name = "home_pet_other", layout = "jiayuanshouhu2", order = eUIO_TOP_MOST,},
	[eUIID_HomePetChoose]			= {name = "home_pet_choose", layout = "jiayuanshouhu", order = eUIO_TOP_MOST,},
	[eUIID_MarryUpStage]			= {name = "marry_up_stage", layout = "jhhlgm2", order = eUIO_TOP_MOST,},
	[eUIID_SignInSolarTerm]			= {name = "sign_in_solar_term", layout = "qdjqjl", order = eUIO_TOP_MOST,},
	[eUIID_AtAnyMomentAnimate]		= {name = "at_any_moment_animate", layout = "suishifuben", order = eUIO_TOP_MOST,},
	[eUIID_AnyTimeAnimate]			= {name = "any_time_animate", layout = "jinruzhandou", order = eUIO_TOP_MOST,},
	[eUIID_RoleFlying]				= {name = "role_flying", layout = "feisheng", order = eUIO_TOP_MOST,},
	[eUIID_RoleFlyingTips]			= {name = "role_flying_tips", layout = "feishengtips", order = eUIO_TOP_MOST,},
	[eUIID_RoleFlyingEnd]			= {name = "role_flying_end", layout = "feishengcg", order = eUIO_TOP_MOST,},
	[eUIID_RoleFlyingFind]			= {name = "role_flying_find", layout = "zdfeisheng"},
	[eUIID_PetGuard]				= {name = "petGuard", layout = "shouhulingshou"},
	[eUIID_PrincessMarryReward]		= {name = "princessMarryReward", layout = "gongzhuchujiajl", order = eUIO_TOP_MOST,},
	[eUIID_TaoistShowReward]		= {name = "taoistShowReward", layout = "zhengxiedaochangkq", order = eUIO_TOP_MOST,},
	[eUIID_PlotDialogue]			= {name = "plotDialogue", layout = "jqdh", order = eUIO_TOP_MOST,},	
	[eUIID_PrincessMarryBattle]		= {name = "princessMarryBattle", layout = "zdgongzhuchujia", order = eUIO_TOP_MOST,},
	[eUIID_PrincessMarryAddScore]	= {name = "princessMarryAddScore", layout = "pzgongzhuchujia", order = eUIO_TOP_MOST,},
	[eUIID_PrincessMarryMap]		= {name = "battlePrincessMarryMap", layout = "fmddt", order = eUIO_TOP_MOST,},	
	[eUIID_ChuHanFightInfo]			= {name = "chuHanFight", layout = "chuhanzhizhengjn", order = eUIO_TOP_MOST, },
	[eUIID_PetGuardSkillInfo]		= {name = "petGuardSkillInfo", layout = "shouhulingshoujntips"},
	[eUIID_CreateHomeLandTips]		= {name = "createHomeLandTips", layout = "jiayuancj2"},
	[eUIID_DanceTip]				= {name = "danceTip", layout = "zhounianqingwh"},
	[eUIID_Jubilee]					= {name = "jubilee", layout = "zhounianqing", order = eUIO_TOP_MOST,},
	[eUIID_JubileeStageOneAward]	= {name = "jubileeStageOneAward", layout = "zhounianqingjl1", order = eUIO_TOP_MOST,},	
	[eUIID_JubileeStageTwoAward]	= {name = "jubileeStageTwoAward", layout = "zhounianqingjl2", order = eUIO_TOP_MOST,},
	[eUIID_JubileeStageThreeTips]	= {name = "jubileeStageThreeTips", layout = "zhounianqingjg", order = eUIO_TOP_MOST,},	
	[eUIID_JubileeChestTips]		= {name = "jubileeChestTips", layout = "zhounianqingbxtips", order = eUIO_TOP_MOST,},
	[eUIID_PetGuardPotential]		= {name = "petGuardPotential", layout = "shouhulingshouqn",},
	[eUIID_PetGuardPotentialActive] = {name = "petGuardPotentialActive", layout = "shouhulingshouqnjh",},
	[eUIID_RoleFlyingFoot]			= {name = "role_flying_foot", layout = "feishengjytx", order = eUIO_TOP_MOST,},
	[eUIID_chuHanFightResult]		= {name = "chuHanFightResult", layout = "chuhanzhizhengjg", order = eUIO_TOP_MOST,},
	[eUIID_RecentlyGet]				= {name = "recentlyGet", layout = "huodejilv", order = eUIO_TOP_MOST,},
	[eUIID_FactionEscortRobStore]	= {name = "faction_escort_rob_store", layout = "yunbiaojb", order = eUIO_TOP_MOST,},
	[eUIID_PrincessMarryResult]		= {name = "princessMarryResult", layout = "gongzhuchujiajg", order = eUIO_TOP_MOST,},
	[eUIID_FlyingEquipInfo]			= {name = "flying_equip_info", layout = "zbtipsfs", order = eUIO_TOP_MOST,},
	[eUIID_FactionEscortLuckDraw]	= {name = "faction_escort_luck_draw", layout = "yunbiaozp", order = eUIO_TOP_MOST,},
	[eUIID_GemSaleConfirm]			= {name = "gemSaleConfirm", layout = "baoshicsqr", order = eUIO_TOP_MOST,},	
	[eUIID_ShowFlyingEquipTips]		= {name = "show_flying_equip_tips", layout = "zbtips2fs", order = eUIO_TOP_MOST,},
	[eUIID_FriendsFlyingEquipTips]	= {name = "friendsFlyingEquipTips", layout = "hyzbtipsfs", order = eUIO_TOP_MOST,},
	[eUIID_GemExchangeShow]			= {name = "gemExchangeShow", layout = "fuhuzh", order = eUIO_TOP_MOST,},
	[eUIID_GemExchangeOperate]		= {name = "gemExchangeOperate", layout = "baoshizh", order = eUIO_TOP_MOST,},
	[eUIID_SpringBuffRank]			= {name = "springBuffRank", layout = "wenquanph", order = eUIO_TOP_MOST,},
	[eUIID_UpdateAnnouncement]		= {name = "update_announcement", layout = "gengxinshuoming", order = eUIO_TOP_MOST,},
	[eUIID_PrincessMarryCarton]		= {name = "princessMarryCarton", layout = "gongzhuchujiamh", order = eUIO_TOP_MOST,},	
	[eUIID_ShenDou]					= {name = "shen_dou", layout = "shendou",},
	[eUIID_ShenDouSkillMax]			= {name = "shen_dou_skill_max", layout = "shendoujnmax", order = eUIO_TOP_MOST,},
	[eUIID_ShenDouBigSkillActive]	= {name = "shen_dou_big_skill_active", layout = "shendoujnjh", order = eUIO_TOP_MOST,},
	[eUIID_ShenDouBigSkillUp]		= {name = "shen_dou_big_skill_up", layout = "shendoujnsj", order = eUIO_TOP_MOST,},
	[eUIID_ShenDouSmallSkillActive] = {name = "shen_dou_small_skill_active", layout = "shendoujnjh3", order = eUIO_TOP_MOST,},
	[eUIID_ShenDouSmallSkillUp] 	= {name = "shen_dou_small_skill_up", layout = "shendoujnsj3", order = eUIO_TOP_MOST},
	[eUIID_MMRank]					= {name = "magicMachineRank", layout = "shenjizanghaixytd", order = eUIO_TOP_MOST},	
	[eUIID_MMRankDetail]			= {name = "magicMachineRankDetail", layout = "shenjizanghaixytd2", order = eUIO_TOP_MOST},
	[eUIID_MMReward]				= {name = "magicMachineReward", layout = "shenjizanghaijl", order = eUIO_TOP_MOST},	
	[eUIID_MagicMachineBattle] 		= {name = "magicMachineBattle", layout = "zdshenjizanghai", order = eUIO_TOP_MOST,},
	[eUIID_BaguaAffixHelp]			= {name = "bagua_affix_help", layout = "baguaczyl", order = eUIO_TOP_MOST,},
	[eUIID_StarShapeTips]			= {name = "starShapeTips", layout = "xingweitips", order = eUIO_TOP_MOST,},
	[eUIID_StarShapeConfirm]		= {name = "starShapeConfirm", layout = "xingweibg", order = eUIO_TOP_MOST,},
	[eUIID_MagicMachineResult]		= {name = "magicMachineResult", layout = "shenjizanghaijg", order = eUIO_TOP_MOST,},
	[eUIID_MagicMachineMiniMap]		= {name = "magicMachineMiniMap", layout = "slzdt", order = eUIO_TOP_MOST,},	
	[eUIID_ShenDouRank] 			= {name = "shen_dou_rank", layout = "shendouphb",order = eUIO_TOP_MOST},
	[eUIID_OppoActivity]			= {name = "oppoActivity", layout = "oppofl", order = eUIO_TOP_MOST,},
	[eUIID_JinLanPu]				= {name = "jinlanpu", layout = "jinlanpu", order = eUIO_TOP_MOST,},
	[eUIID_JinLanAchievement]		= {name = "jinlanAchievement", layout = "jinlancj", order = eUIO_TOP_MOST,},
	[eUIID_JinLanChangeMessage]		= {name = "jinlanMsg", layout = "jinlanpu1", order = eUIO_TOP_MOST,},
	[eUIID_JinLanShare]				= {name = "jinlanShare", layout = "jiehunzhengfx", order = eUIO_TOP_MOST,},
	[eUIID_CardPacket]				= {name = "cardPacket", layout = "tujian", order = eUIO_TOP_MOST},
	[eUIID_CardPacketBack]			= {name = "cardPacketBack", layout = "tujiankb", order = eUIO_TOP_MOST,},
	[eUIID_CardPacketUnlock]		= {name = "cardPacketUnlock", layout = "tujiankbjs", order = eUIO_TOP_MOST,},
	[eUIID_CardPacketDesc]			= {name = "cardPacketDesc", layout = "tujian3", order = eUIO_TOP_MOST,},
	[eUIID_CardPacketShow]			= {name = "cardPacketShow", layout = "tujian2", order = eUIO_TOP_MOST,},
	[eUIID_CardPacketChatInfo]		= {name = "cardPacketChatInfo", layout = "tujian4", order = eUIO_TOP_MOST,},
	[eUIID_TournamentWeekReward]	= {name = "tournament_week_reward", layout = "huiwujl", order = eUIO_TOP_MOST,},
	[eUIID_FactionDungeonOpenAni]	= {name = "faction_dungeon_ani", layout = "bpfbkqcg", order = eUIO_TOP_MOST},
	[eUIID_FactionDungeonResetAni]	= {name = "faction_dungeon_ani", layout = "bpfbczcg", order = eUIO_TOP_MOST},
	[eUIID_MasterCard]				= {name = "master_card", layout = "taoli", order = eUIO_TOP_MOST,},
	[eUIID_MasterCardEdit]			= {name = "master_card_modify_annc", layout = "taolijiyu", order = eUIO_TOP_MOST,},
	[eUIID_MasterCardShare]			= {name = "master_card_share", layout = "jiehunzhengfx", order = eUIO_TOP_MOST},
	[eUIID_ReceiveAchievementReward] = {name = "receiveAllAchievementReward", layout = "yjlq", order = eUIO_TOP_MOST,},
	[eUIID_CityWarExp]				= {name = "cityWarExp", layout = "chengzhanczzg", order = eUIO_TOP_MOST,},
	[eUIID_MessageBox4]				= {name = "messagebox4", layout = "cprtips", order = eUIO_BOARDTOP,},
	[eUIID_NPCHotelDetail]			= {name = "npcHotelDetail", layout = "jhkz2", order = eUIO_TOP_MOST},
	[eUIID_ChallengeSubmitItems]	= {name = "challenge_submit_items", layout = "rchtjwp", order = eUIO_TOP_MOST},
	[eUIID_HomeLandSkill]		   	= {name = "homelandSkill", layout = "zdxjn",},
	[eUIID_AutoDo]					= {name = "autoDo", layout = "jdt2", order = eUIO_TOP_MOST},
	[eUIID_AutoRefineSet]			= {name = "steedAutoRefineSet", layout = "zqxl3", order = eUIO_TOP_MOST},
	[eUIID_AutoRefineSetPreview]	= {name = "steedAutoRefineSetPreview", layout = "zqxl4", order = eUIO_TOP_MOST},
	[eUIID_HomeLandTreeBlood]		= {name = "homelandGuardTreeBlood", layout = "hudxlzm"},
	[eUIID_FiveElements]			= {name = "fiveElements", layout = "wuxinglunzhuan", order = eUIO_TOP_MOST},
	[eUIID_FeiSheng]				= {name = "feisheng_scr", layout = "feisheng2", order = eUIO_TOP_MOST},
	[eUIID_FeiShengUpgrade]			= {name = "feishengUpgrade", layout = "feisheng2tips2", order = eUIO_TOP_MOST},
	[eUIID_FeishengQuickFinish]		= {name = "feishengRMQuick", layout = "sbrwkuaisu", order = eUIO_TOP_MOST},
	[eUIID_FeishengAni]				= {name = "feishengAni", layout = "feishengcgdh", order = eUIO_TOP_MOST},
	[eUIID_FactionPhotoTips]		= {name = "faction_photo_desc", layout = "bphz1", order = eUIO_TOP_MOST},
	[eUIID_FactionPhotoList]		= {name = "choosePhotographer", layout = "bphz2", order = eUIO_TOP_MOST},
	[eUIID_FactionPhotoEnd]			= {name = "faction_photo_end", layout = "bphz3", order = eUIO_TOP_MOST},
	[eUIID_KnightlyDetectiveMember]	= {name = "knightly_detective_member", layout = "guiyingwangluo", order = eUIO_TOP_MOST},
	[eUIID_KnightlyDetectiveSurvey]	= {name = "knightly_detective_survey", layout = "guiyingwangluo2", order = eUIO_TOP_MOST},
	[eUIID_KnightlyDetectiveLeader]	= {name = "knightly_detective_leader", layout = "guiyingwangluo3", order = eUIO_TOP_MOST},
	[eUIID_BaguaYilue]				= {name = "yilueOpen", layout = "baguayskq", order = eUIO_TOP_MOST },
	[eUIID_BaguaYilueByPoint]		= {name = "yilueByPoint", layout = "baguaysdgm", order = eUIO_TOP_MOST },
	[eUIID_SkillSetCartoon]			= {name = "skillSetCartoon", layout = "jnjmyd", order = eUIO_TOP_MOST},
	[eUIID_KniefShooting]			= {name = "kniefShooting", layout = "feidao", order = eUIO_TOP_MOST},
	[eUIID_HuoBanUnbind]	 		= {name = "huobanUnbind", layout = "huobanjb", order = eUIO_TOP_MOST},
	[eUIID_YilueResetPoint]			= {name = "yilueResetPoint", layout = "baguaysdcz", order = eUIO_TOP_MOST},
	[eUIID_YilueTips]				= {name = "yilueTips", layout = "baguaystips", order = eUIO_TOP_MOST},
	[eUIID_YilueSkill]				= {name = "yilueSkill", layout = "baguaysjn", order = eUIO_TOP_MOST},
	[eUIID_YilueSkillShengjie]		= {name = "yilueSkillShengjie", layout = "baguaysjnsj", order = eUIO_TOP_MOST},
	[eUIID_YilueSkillJihuo]			= {name = "yilueSkillJihuo", layout = "baguaysjnjs", order = eUIO_TOP_MOST},
	[eUIID_KnightlyDetectiveTips]	= {name = "knightly_detective_tips", layout = "guiyingwangluotips", order = eUIO_TOP_MOST},
	[eUIID_KnightlyDetectiveAnimate]= {name = "knightly_detective_animate", layout = "guiyingwangluodh", order = eUIO_TOP_MOST},
	[eUIID_KnightlyDetectiveClue]	= {name = "knightly_detective_clue", layout = "guiyingwangluo4", order = eUIO_TOP_MOST},
	[eUIID_FieldSublineTask]		= {name = "field_subline_task", layout = "db5", order = eUIO_TOP_MOST},
	[eUIID_FlyingExpItem]			= {name = "flyingExpItem", layout = "feishengjysy", order = eUIO_TOP_MOST},
	[eUIID_FlyingEquipSharpen]		= {name = "flyingEquipSharpen", layout = "feishenghyjd", order = eUIO_TOP_MOST},
	[eUIID_FlyingEquipTrans]		= {name = "flyingEquipTrans", layout = "feishenghyjd2", order = eUIO_TOP_MOST},
	[eUIID_SwordsmanFriendship]		= {name = "swordsman_friendship", layout = "daxiajl", order = eUIO_TOP_MOST},
	[eUIID_FuYuZhuDing]				= {name = "fuYuZhuDing", layout = "njfwzd", order = eUIO_TOP_MOST},
	[eUIID_SwordsmanCommit]			= {name = "swordsman_commit", layout = "daxiah", order = eUIO_TOP_MOST},
	[eUIID_TimingActivityPray] 		= {name = "timingactivityPray", layout = "dingqihuodongqyq", order = eUIO_TOP_MOST},
	[eUIID_TimingActivityTakeReward]= {name = "timingactivityTakeReward", layout = "choukajg2", order = eUIO_TOP_MOST},
	[eUIID_InputMessageBox]			= {name = "inputMessageBox", layout = "bxqrts", order = eUIO_TOP_MOST },
	[eUIID_FriendsInviteAnswer]		= {name = "friendsInviteAnswer", layout = "haoyoutips", order = eUIO_TOP_MOST},
	[eUIID_FuYuFastAdd]				= {name = "fuyuFastAdd", layout = "njfwzdtips", order = eUIO_TOP_MOST },
	[eUIID_SwordsmanQuestion]		= {name = "swordsman_question", layout = "daxiadt", order = eUIO_TOP_MOST },
	[eUIID_GoldCoastPKMode]			= {name = "goldCoastPk", layout = "hjhapk", order = eUIO_TOP_MOST },  
	[eUIID_WarZoneLine]				= {name = "warZoneLine", layout = "hjhahx"},
	[eUIID_EnterWarZone]			= {name = "enterWarZone", layout = "hjha", order = eUIO_TOP_MOST },
	[eUIID_WarZoneCard]				= {name = "warZoneCard", layout = "shenmikapian", order = eUIO_TOP_MOST},
	[eUIID_TimeAndDescBuffTips]		= {name = "timeAndDescBufTips", layout = "bufftips3", order = eUIO_BOTTOM, },
	[eUIID_WarZoneCardShow]			= {name = "warZoneCardShow", layout = "shenmikapianhd", order = eUIO_TOP_MOST },
	[eUIID_WarZoneCardGetShow]		= {name = "warZoneCardGetShow", layout = "hjhahdkp", order = eUIO_BOTTOM},
	[eUIID_ArrayStone]				= {name = "array_stone", layout = "zfs", order = eUIO_TOP_MOST},
	[eUIID_ArrayStoneBatchRecycle]	= {name = "array_stone_batch_recycle", layout = "zfshs", order = eUIO_TOP_MOST},
	[eUIID_ArrayStoneArchive]		= {name = "array_stone_archive", layout = "zfsmw", order = eUIO_TOP_MOST},
	[eUIID_ArrayStoneLock]			= {name = "array_stone_lock", layout = "zfsmwsd", order = eUIO_TOP_MOST},
	[eUIID_ArrayStoneMWInfo] 		= {name = "array_stone_mw_info", layout = "zfsmwsx", order = eUIO_TOP_MOST},
	[eUIID_ArrayStoneMWDisplace	]	= {name = "array_stone_mw_displace", layout = "zfsmwzh", order = eUIO_TOP_MOST,},
	[eUIID_ArrayStoneMWRecovery	]	= {name = "array_stone_mw_recovery", layout = "zfsmwhs", order = eUIO_TOP_MOST,},
	[eUIID_ArrayStoneMWSynthetise]	= {name = "array_stone_mw_synthetise", layout = "zfsmwhc", order = eUIO_TOP_MOST,},
	[eUIID_ArrayStoneSuit]			= {name = "array_stone_suit", layout = "zfsyj", order = eUIO_TOP_MOST,},
	[eUIID_ArrayStoneUpLevel]		= {name = "array_stone_up_level", layout = "zfszy", order = eUIO_TOP_MOST,},
	[eUIID_ArrayStoneMWRecoveryConfirm] = {name = "array_stone_mw_recovery_confirm", layout = "zfsmwts", order = eUIO_TOP_MOST},
	[eUIID_ArrayStoneMWEquipConfirm] = {name = "array_stone_mw_equip_confirm", layout = "zfsmwsz", order = eUIO_TOP_MOST},
	[eUIID_GlobalWorldTaskTake]		= {name = "globalWorldTasktake", layout = "sjrwjl", order = eUIO_TOP_MOST},
	[eUIID_ArrayStoneUnlockHole]	= {name = "array_stone_unlock_hole", layout = "zfsjk", order = eUIO_TOP_MOST},
	[eUIID_ArrayStoneAmuletProp]	= {name = "array_stone_amulet_prop", layout = "zfsfysx", order = eUIO_TOP_MOST},
	[eUIID_GlobalWorldMapTask]		= {name = "globalWorldMapTask", layout = "shangjinjiemian"},
	[eUIID_SwordsmanExpProp]		= {name = "swordsman_exp_prop", layout = "pz3"},
	[eUIID_ArrayStoneRanking]		= {name = "array_stone_ranking", layout = "zfsphb", order = eUIO_TOP_MOST},
	[eUIID_ArrayStoneSuitRank]		= {name = "array_stone_suit_rank", layout = "zfsphb1", order = eUIO_TOP_MOST},
	[eUIID_FightTeamList]			= {name = "fightTeamList", layout = "wudaohuilb", order = eUIO_TOP_MOST},
	[eUIID_UseItemUpEquipLevel]		= {name = "useItemUpEquipLevel", layout = "zbsj", order = eUIO_TOP_MOST},
	[eUIID_ForceWarLottery]			= {name = "forceWarLottery", layout = "shilizhanchoujiang", order = eUIO_TOP_MOST},
	[eUIID_LotteryNew]				= {name = "lottery", layout = "czcj", order = eUIO_TOP, relevance = { eUIID_DB, eUIID_DBF } },
	[eUIID_LotteryPosibility]		= {name = "lottery_posibility", layout = "glgs", order = eUIO_TOP_MOST},
	[eUIID_SuperOnHook]				= {name = "superOnHook", layout = "gaojiguaji", order = eUIO_TOP_MOST},
	[eUIID_LongevityPavilionReward]	= {name = "longevityPavilionReward", layout = "gongzhuchujiajl", order = eUIO_TOP_MOST,},
	[eUIID_LongevityPavilionResult] = {name = "longevityPavilionResult", layout = "wanshougejg", order = eUIO_TOP_MOST},
	[eUIID_LongevityPavilionBattle] = {name = "longevityPavilionBattle", layout = "wanshougerw", order = eUIO_TOP_MOST},
	[eUIID_LongevityPavilionDelivery] = {name = "longevityPavilionDelivery", layout = "wanshougecs", order = eUIO_TOP_MOST},
	[eUIID_InviteList] 				= {name = "invite_list", layout = "yaoqingxx", order = eUIO_TOP},
	[eUIID_InviteEntrance] 			= {name = "inviteEntrance", layout = "yaoqingrk"},
	[eUIID_InviteSetting]			= {name = "invite_setting", layout = "yaoqingsz", order = eUIO_TOP_MOST},
	[eUIID_SpriteFragmentBag]		= {name = "spriteFragmentBag", layout = "gdyljm", order = eUIO_TOP_MOST},
	[eUIID_SpriteFragmentExchange]	= {name = "spriteFragmentExchange", layout = "gdyljh", order = eUIO_TOP_MOST},
	[eUIID_SpyStory]				= {name = "spyStory", layout = "mitanfengyunjm", order = eUIO_TOP_MOST},
	[eUIID_MarryHelp]				= {name = "marryHelp", layout = "bz", order = eUIO_TOP_MOST},
	[eUIID_CatchSpiritPreview]		= {name = "catch_spirit_preview", layout = "bgylplt", order = eUIO_TOP_MOST},
	[eUIID_LearnCatchSpiritSkills]	= {name = "learn_catch_spirit_skills", layout = "gdylxxjn", order = eUIO_TOP_MOST},
	[eUIID_CatchSpiritSkills]		= {name = "catch_spirit_skills", layout = "gdyljn",},
	[eUIID_SpyStory]				= {name = "spyStory", layout = "mitanfengyunjm", order = eUIO_TOP_MOST},
	[eUIID_WujueSoulSkill]			= {name = "wujueSoulSkill", layout = "wujuekz", order = eUIO_TOP_MOST,},
	[eUIID_CatchSpiritMap]			= {name = "catch_spirit_map", layout = "fmddt", order = eUIO_TOP_MOST},
	[eUIID_CatchSpiritTask]			= {name = "catch_spirit_task", layout = "gdylrw"},
	[eUIID_SpyStoryTask]			= {name = "spyStoryTask", layout = "mitanfengyunrw", order = eUIO_TOP_MOST},
	[eUIID_ActivityAddTimesWay]		= {name = "activityAddTimesWay", layout = "jiacs1", order = eUIO_TOP_MOST},
	[eUIID_ActivityAddTimesByItem]	= {name = "activityAddTimesByItem", layout = "jiacs", order = eUIO_TOP_MOST},
	[eUIID_SpiritRefreshTip]		= {name = "spiritRefreshTip", layout ="gdylsm1", order = eUIO_TOP_MOST},
	[eUIID_SpiritTip]				= {name = "spiritTip", layout ="gdylsm", order = eUIO_TOP_MOST},
	[eUIID_CatchSpiritBag]			= {name = "catch_spirit_bag", layout = "gdylrk1"},
	[eUIID_OutCareerPractice]		= {name = "out_career_practice", layout = "qsll", order = eUIO_TOP_MOST},
	[eUIID_BiographyTask]			= {name = "biography_task", layout = "qsrw"},
	[eUIID_BiographySkills]			= {name = "biography_skills", layout = "qsjnjm", order = eUIO_TOP_MOST},
	[eUIID_ExposeLetter]			= {name = "exposeLetter", layout = "zhuxianmixin", order = eUIO_TOP_MOST,},
	[eUIID_MatchToken]				= {name = "matchToken", layout = "zhuxianlingpai", order = eUIO_TOP_MOST,},
	[eUIID_BiographyQigong]			= {name = "biography_qigong", layout = "qsqg", order = eUIO_TOP_MOST},
	[eUIID_BiographyMapExit]		= {name = "biography_map_exit", layout = "cs2", order = eUIO_TOP_MOST},
	[eUIID_BiographySkillsUnlock]	= {name = "biography_skills_unlock", layout = "qsjs", order = eUIO_TOP_MOST},
	[eUIID_BiographyAnimate]		= {name = "biography_animate", layout = "qswzdh", order = eUIO_TOP_MOST},
	[eUIID_BiographyCareerMap]		= {name = "biography_career_map", layout = "fmddt", order = eUIO_TOP_MOST},
	--[eUIID_CatchSpiritAnimate]		= {name = "catch_spirit_animate", layout = "gdyljnwc1", order = eUIO_TOP_MOST},
	[eUIID_CatchSpiritGuide]		= {name = "catch_spirit_guide", layout = "gdylsm3", order = eUIO_TOP_MOST},
	[eUIID_NewQueryRoleFeature]		= {name = "newQueryRoleFeature", layout = "hyxx1", order = eUIO_TOP_MOST},
	[eUIID_SpyStoryHelp]			= {name = "spyStoryHelp", layout = "mitanfengyunsm", order = eUIO_TOP_MOST},
	[eUIID_MessageBox5]				= { name = "messagebox3", layout = "cs3", order = eUIO_TOP_MOST },
	[eUIID_ShowFriendsFashionTips]	= {name = "showFriendsFashionTips", layout = "hyxxsztips", order = eUIO_TOP_MOST},
	[eUIID_ShowPlayerProgress]		= {name = "show_player_progress", layout = "hyxxczty", order = eUIO_TOP_MOST},
	[eUIID_PetDungeonTip]			= {name = "petDungeonTip", layout = "gdylsm3", order = eUIO_TOP_MOST},
	[eUIID_FactionFightExplain]		= {name = "factionFightExplain", layout = "gdylsm3", order = eUIO_TOP_MOST},
	[eUIID_MazeBattleExplain]		= {name = "mazeBattleExplain", layout = "gdylsm3", order = eUIO_TOP_MOST},
	[eUIID_ShowPlayerPetXinfa]		= {name = "show_player_pet_xinfa", layout = "hyxxcwxf", order = eUIO_TOP_MOST},
	[eUIID_FirstClearReward]		= {name = "firstClearReward", layout = "wanfascjl", order = eUIO_TOP_MOST},

	[eUIID_SpringRollMain]			= {name = "springRollMain", layout = "xinchundenglong", order = eUIO_TOP_MOST},
	[eUIID_SpringRollQuiz]			= {name = "springRollQuiz", layout = "xinchundenglongtips1", order = eUIO_TOP_MOST},
	[eUIID_SpringRollBuy]			= {name = "springRollBuy", layout = "xinchundenglongtips2", order = eUIO_TOP_MOST},
	[eUIID_FestivalTaskAccept]		= {name = "festivalDailyTaskAccept", layout = "jierirw", order = eUIO_TOP_MOST},
	[eUIID_FestivalTaskCommit]		= {name = "festivalDailyTaskCommit", layout = "jierizb", order = eUIO_TOP_MOST},
	[eUIID_FestivalActivityUI]		= {name = "festival_new_activity_ui", layout = "jierimb", order = eUIO_TOP_MOST},
	[eUIID_FestivalScoreBoxTips]	= {name = "festivalScoreBoxTips", layout = "jieribxtips1", order = eUIO_TOP_MOST},
	
	[eUIID_SpringRollTips]			= {name = "springRollTips", layout = "xinchundenglongtips3", order = eUIO_TOP_MOST},
	[eUIID_JnCoinBuyTips]			= {name = "collect_coin_buy", layout = "shunianjnjbgm", order = eUIO_TOP_MOST},
	[eUIID_ExChangeCoin]			= {name = "collect_coin_exchange", layout = "shunianjnjbdh", order = eUIO_TOP_MOST},
};

g_i3k_ui_mgr = nil;
function i3k_ui_mgr_create()
	if not g_i3k_ui_mgr then
		g_i3k_ui_mgr = i3k_ui_mgr.new();
		g_i3k_ui_mgr:Create();
	end

	return 1;
end

function i3k_ui_mgr_update(dTime)
	if g_i3k_ui_mgr then
		g_i3k_ui_mgr:OnUpdate(dTime);
	end

	return 1;
end

function i3k_ui_mgr_cleanup()
	if g_i3k_ui_mgr then
		g_i3k_ui_mgr:Release();
	end
	g_i3k_ui_mgr = nil;

	return 1;
end

function ui_conv_point(_x, _y)
    if _y == nil then
         return { x = _x.x, y = _x.y };
    else
         return { x = _x, y = _y };
    end
end

-------------------------------------------------------
--这个类废弃了
i3k_ui_order = i3k_class("i3k_ui_order")
function i3k_ui_order:ctor()
	self:ResetOrder()
end
--复位
function i3k_ui_order:ResetOrder()
	self._stack = {[eUIO_BOTTOM] = {}, [eUIO_NORMAL] = {}, [eUIO_TOP] = {}, [eUIO_TOP_MOST] = {},[eUIO_LEADBOARDS] = {},[eUIO_BOARDTOP] = {} , [eUIO_TIPS] = {} , [eUIO_CONNECTINGSTATE] = {}}
end

--添加UI
function i3k_ui_order:AddUI(id, order)
	table.insert(self._stack[order], id)
end
--移除UI
function i3k_ui_order:RemoveUI(id, order)
	local index = self:GetIndex(id, order)
	if index then
		table.remove(self._stack[order], index)
	end
end

--获取索引
function i3k_ui_order:GetIndex(id, order)
	for i, e in ipairs(self._stack[order]) do
		if e == id then
			return i
		end
	end
end

function i3k_ui_order:GetOrderIndex(id)
	local script = i3k_ui_map[id]
	if script then
		local order = script.order or eUIO_NORMAL
		return order, self:GetIndex(id, order)
	end
end

--[[function i3k_ui_order:TestUIType(id, uiType)
	local script = i3k_ui_map[id]
	return script and script.uitypes and script.uitypes[uiType];
end

function i3k_ui_order:FindLastUI(order, findStartIndex, wndtype)
	local orderUIs = self._stack[order]
	for k = findStartIndex, 1, -1 do
		local uiId = orderUIs[k]
		if not wndtype or self:TestUIType(uiId, wndtype) then
			return uiId
		end
	end
end

function i3k_ui_order:GetUnderUI(id, wndtype)
	local order, index = self:GetOrderIndex(id)
	if order and index then
		for k = order, eUIO_BOTTOM, -1 do
			local findStartIndex = k == order and index - 1 or #self._stack[k]
			local uiId = self:FindLastUI(k, findStartIndex, wndtype)
			if uiId then
				return uiId
			end
		end
	end
end--]]

--获取所有UI
function i3k_ui_order:GetAllUIs()
	local uis = {}
	for i = eUIO_TIPS, eUIO_BOTTOM, -1 do
		local orderUIs = self._stack[i]
		for j = #orderUIs, 1, -1 do
			table.insert(uis, orderUIs[j])
		end
	end
	return uis
end
-------------------------------------------------------
i3k_ui_cache = i3k_class("i3k_ui_cache")
function i3k_ui_cache:ctor(size)
	self._cache = { };
	self._max	= size;
	self._size	= 0;
	self._orders  = i3k_ui_order.new();
end
--释放缓存
function i3k_ui_cache:Release()
	for k, v in pairs(self._cache) do
		if v.open then
			--v.wnd:onRelease();
			--v.wnd:onHide();
			v.__desktop:removeChild(v.wnd, true);--删除这个节点的所有信息（动作行为）
		end
	end
	self._cache = { };
	self._orders:ResetOrder();
end

function i3k_ui_cache:Push(id, wnd, order, desktop)
	self._size		= self._size + 1;
	self._cache[id] = { open = false, wnd = wnd, order = order, callback = nil, __desktop = desktop };

	return self:Open(id)
end

function i3k_ui_cache:Open(id)
	local cache = self._cache[id];
	if cache and not cache.open then
		cache.open = true;
		self._size = self._size - 1;
		cache.__desktop:addChild(cache.wnd, cache.order);
		cache.wnd:onShowImpl();
		self._orders:AddUI(id, cache.order);
		--i3k_log("openui:#############"..id)
		--g_i3k_game_context:LeadCheck();
		return true  --首次打开
	end
	return false --已经存在
end

function i3k_ui_cache:Close(id, cleanup)
	local cache = self._cache[id];
	if cache and cache.open then
		cache.wnd:onHideImpl();
		if cleanup then
			cache.__desktop:removeChild(cache.wnd, true);
			self._cache[id] = nil;
		else
			cache.__desktop:removeChild(cache.wnd, false);
			self._size = self._size + 1;
			self:Tidy();
		end
		self._orders:RemoveUI(id, cache.order);
		cache.open = false;
		local callback = cache.callback
		cache.callback = nil
		if callback then
			callback(false)
		end

		--i3k_log("closeui:########%%%%%%#####"..id)
		return true
	end
	return false
end

function i3k_ui_cache:CloseAll(cleanup, exceptTb)
	for k, v in pairs(self._cache) do
		if v and v.open and not exceptTb[k] then
			v.wnd:onHideImpl();
			v.open = false;
			local callback = v.callback
			v.callback = nil;

			if cleanup then
				v.__desktop:removeChild(v.wnd, true);

				self._cache[k] = nil;
			else
				v.__desktop:removeChild(v.wnd, false);

				self._size = self._size + 1;
				self:Tidy();
			end
			self._orders:RemoveUI(k, v.order);
			if callback then
				callback(true) --callback true表示全部关闭
			end
		end
	end
	-- if exceptId then
	-- 	local exceptUI = g_i3k_ui_mgr:GetUI(exceptId)
	-- 	if not exceptUI then
	-- 		g_i3k_ui_mgr:OpenUI(exceptId)
	-- 		g_i3k_ui_mgr:RefreshUI(exceptId)
	-- 	end
	-- end
end

function i3k_ui_cache:Get(id)
	return self._cache[id];
end

function i3k_ui_cache:GetAll()
	return self._cache;
end

function i3k_ui_cache:Tidy()--整理
	if self._size > self._max then
		for k, v in pairs(self._cache) do
			if not v.open then
				--v:cleanup();
				self._size		= self._size - 1;
				self._cache[id] = nil;
			end
			if self._size <= self._max then
				break;
			end
		end
	end
end

--[[function i3k_ui_cache:GetUnderUI(id, wndtype)
	return self._orders:GetUnderUI(id, wndtype)
end--]]

function i3k_ui_cache:GetAllUIs()
	return self._orders:GetAllUIs()
end


function i3k_ui_cache:SetUICloseCallback(id, callback)
	local oldcallback = nil
	local cache = self._cache[id];
	if cache and cache.open then
		oldcallback = cache.callback
		cache.callback = callback
	end
	return oldcallback
end
-------------------------------------------------------
i3k_ui_mgr = i3k_class("i3k_ui_mgr")
function i3k_ui_mgr:ctor()
	self._destop	= nil;
	self._cache		= i3k_ui_cache.new(10);
	self._tickLine	= 0;
	self._tasks		= { };
	self._uniqueIDSeed = 0;
	self._tasksAddList = { };
	self._isExecutingTask = false;
	self._normalDesktop = nil;
	self._specDesktop = nil;
end

function i3k_ui_mgr:Create()
	cc.FileUtils:getInstance():addSearchPath("ui");--设置搜索路径(可以是绝对路径、相对路径)

	-- init gui
	self._director = cc.Director:getInstance();--获取导演类
	self._glView = self._director:getOpenGLView();--设置OpenGL视图
	if nil == self._glView then
		return false;
	end

	if i3k_game_is_dev_mode() then--是否为开发版本
		self._director:setDisplayStats(true);--设置是否显示每帧时间
	end
--设置分辨率
	local designSize = { width = 1280, height = 720, autoscale = "EXACT_FIT" };
	self._glView:setDesignResolutionSize(designSize.width, designSize.height, cc.ResolutionPolicy.NO_BORDER);--无边策略
	--self:SetDesignResolution(designSize);--使得自己设计的屏幕大小适应各种机器的屏

	self._destop = cc.Scene:create();--创建场景
	if self._destop then
		self._director:runWithScene(self._destop);--运行场景
	end
	self._normalDesktop = cc.Layer:create();--创建layer层
	self._specDesktop = cc.Layer:create();

	g_i3k_ui_mgr._destop:addChild(self._normalDesktop, 0);--最先加载某一层，数值越大，最后加载
	g_i3k_ui_mgr._destop:addChild(self._specDesktop, 0);

	return true;
end

function i3k_ui_mgr:Release()
	if self._cache then
		self._cache:Release();
	end

	if self._destop then
		cc.Director:getInstance():popScene();--场景出站，删除当前场景
		self._destop = nil;
	end
end

g_newUIOpened = false

function i3k_ui_mgr:OpenUI(id)
	if self._isUpdate then
		error(string.format("Trying to open a UI when updating! uiid:%d", id))
	end
	local script = i3k_ui_map[id];
	if not script then
		return nil;
	end

	local wnd = nil;
	local is_first_open = false
	local cache = self._cache:Get(id);--获取cacheID
	if cache then
		is_first_open = self._cache:Open(id);
		wnd = cache.wnd;
	else
		local ui = require("ui/" .. script.name);
 		if ui then
			wnd = ui.wnd_create(script.layout);
			if wnd then
				--if script.isPad then
				--	local is_pad = self:JudgeIsPad()
				--	wnd:adaptorIsPad(is_pad)
				--end
				wnd.__uiid = id
				wnd.__uniqueID = self._uniqueIDSeed;
				self._uniqueIDSeed = self._uniqueIDSeed + 1;
				local order = script.order or eUIO_NORMAL;
				local desktop = self._normalDesktop;
				if script.desktopType == eUI_DESKTOP_TYPE_SPECIAL then
					desktop = self._specDesktop;
				end
				is_first_open = self._cache:Push(id, wnd, order, desktop);
			end
		end
	end
	if is_first_open and g_i3k_game_context:IsInLeadMode() then
			if id == eUIID_Dialogue1 or id == eUIID_Dialogue3 or id == eUIID_Dialogue4 then
				g_i3k_game_context:ResetLeadMode();
			end
		end
	if wnd then
		if script.relevance then
			for k, v in ipairs(script.relevance) do
				self:OpenUI(v);
			end
		end
	end
	g_newUIOpened = true

	return wnd;
end

function i3k_ui_mgr:CloseUI(id, cleanup)
	local script = i3k_ui_map[id];
	if not script then
		return false;
	end
	if script.relevance then
		for k, v in ipairs(script.relevance) do
			self:CloseUI(v, true);
		end
	end
	local suc = self._cache:Close(id, true);

	if suc and not g_i3k_game_context:IsInLeadMode() and g_i3k_game_context:IsOpenLead() then
		self.co = g_i3k_coroutine_mgr:StartCoroutine(function ()
			g_i3k_coroutine_mgr.WaitForNextFrame()

				g_i3k_game_context:LeadCheck()

			g_i3k_coroutine_mgr:StopCoroutine(self.co)
		end)
	end
	return suc
end

--变参
function i3k_ui_mgr:CloseAllOpenedUI(...)
	local exceptTb = { [eUIID_Broadcast] = true, }
	for i, v in ipairs{...} do
		exceptTb[v] = true
	end
	self._cache:CloseAll(true, exceptTb);
	self:CloseGuideUI(eUIID_GuideUI == exceptId);
end
--隐藏UI
function i3k_ui_mgr:HideNormalUI()
	self._normalDesktop:setVisible(false);
end
--正常显示UI
function i3k_ui_mgr:ShowNormalUI()
	self._normalDesktop:setVisible(true);
end

function i3k_ui_mgr:ShowRenderInfo(vis)
	if i3k_game_is_dev_mode() then
		if vis then
			self._director:setDisplayStats(true);
		else
			self._director:setDisplayStats(false);
		end
	end
end
--获取UI
function i3k_ui_mgr:GetUI(id)
	local cache = self._cache:Get(id);
	if cache and cache.open then
		return cache.wnd;
	end
	return nil;
end

--[[function i3k_ui_mgr:GetUnderUI(id, wndtype)
	return self._cache:GetUnderUI(id, wndtype)
end

function i3k_ui_mgr:TryCloseUnderUI(id, wndtype)
	local uiId = self:GetUnderUI(id, wndtype)
	if uiId then
		self:CloseUI(uiId)
	end
	return self:GetUI(id)
end--]]


--获取UI函数
function i3k_ui_mgr:InvokeUIFunction(id, fname, ...)
	local wnd = self:GetUI(id);
	if wnd then
		local func = wnd[fname];
		if func then
			func(wnd, ...);
		end
	end
	return wnd
end
--刷新界面
function i3k_ui_mgr:RefreshUI(id, ...)
	return self:InvokeUIFunction(id, "refresh", ...)
end
--设置UI关闭回调
function i3k_ui_mgr:SetUICloseCallback(id, callback)
	return self._cache:SetUICloseCallback(id, callback);
end
--获得正常的桌面
function i3k_ui_mgr:GetNormalDesktop()
	return self._normalDesktop;
end
--获得规范的桌面
function i3k_ui_mgr:GetSpecDesktop()
	return self._specDesktop;
end
--弹出等待窗口
function i3k_ui_mgr:PopupWait()
	self:OpenUI(eUIID_Wait)
	self:RefreshUI(eUIID_Wait)
end
--弹窗信息
function i3k_ui_mgr:PopupTipMessage(msg)
 	self:OpenUI(eUIID_Tips)
	self:RefreshUI(eUIID_Tips, msg)
end
--显示消息box1
function i3k_ui_mgr:ShowMessageBox1(msg, callback)
	self:ShowCustomMessageBox1("确定", msg, callback)
end
--显示自定义消息box1
function i3k_ui_mgr:ShowCustomMessageBox1(btnName, msg, callback)
	if not self:GetUI(eUIID_MessageBox1) then
		self:OpenUI(eUIID_MessageBox1)
		self:RefreshUI(eUIID_MessageBox1, btnName, msg, callback)
		return true
	end
	return false
end
--显示消息box2
function i3k_ui_mgr:ShowMessageBox2(msg, callback)
	self:ShowCustomMessageBox2("确定", "取消", msg, callback)
end

function i3k_ui_mgr:ShowMessageBox3(msg, tips, callback)
	if not self:GetUI(eUIID_SpringTips) then
		self:OpenUI(eUIID_SpringTips)
		self:RefreshUI(eUIID_SpringTips,msg,tips,callback)
		return true
	end
	return false
end
--显示...邀请
function i3k_ui_mgr:ShowSpringInvite(btnTitle, msg, isShowClose, callback)
	if not self:GetUI(eUIID_SpringInvite) then
		self:OpenUI(eUIID_SpringInvite)
		self:RefreshUI(eUIID_SpringInvite, btnTitle, msg, isShowClose, callback)
		return true
	end
	return false
end
--星语星愿提示
function i3k_ui_mgr:ShowConstellationBox(yesName, noName, msg, callback)
	if not self:GetUI(eUIID_ConstellationTip) then
		self:OpenUI(eUIID_ConstellationTip)
		self:RefreshUI(eUIID_ConstellationTip, yesName, noName, msg, callback)
		return true
	end
	return false
end

function i3k_ui_mgr:ShowCustomMessageBox2(yesName, noName, msg, callback)
	if not self:GetUI(eUIID_MessageBox2) then
		self:OpenUI(eUIID_MessageBox2)
		self:RefreshUI(eUIID_MessageBox2, yesName, noName, msg, callback)
		return true
	end
	return false
end
--显示消息输入内容确认框box
function i3k_ui_mgr:ShowInputMedssageBox(yesName, noName, msg, inputNum, callback)
	if not self:GetUI(eUIID_InputMessageBox) then
		self:OpenUI(eUIID_InputMessageBox)
		self:RefreshUI(eUIID_InputMessageBox, yesName, noName, msg, inputNum,callback)
		return true
	end
	return false
end

function i3k_ui_mgr:ShowMidCustomMessageBox2Ex(yesName, noName, msg, rtext, callback, callbackRadioButton, radioShow)
	if not self:GetUI(eUIID_MessageBox3) then
		self:OpenUI(eUIID_MessageBox3)
		self:RefreshUI(eUIID_MessageBox3, yesName, noName, msg, rtext, callback, callbackRadioButton, radioShow)
		return true
	end
	return false
end

function i3k_ui_mgr:ShowTopMessageBox1(msg, callback)
	self:ShowTopCustomMessageBox1("确定", msg, callback)
end

function i3k_ui_mgr:ShowTopCustomMessageBox1(btnName, msg, callback)
	self:OpenUI(eUIID_TopMessageBox1)
	self:RefreshUI(eUIID_TopMessageBox1, btnName, msg, callback)
end

function i3k_ui_mgr:ShowTopMessageBox2(msg, callback)
	self:ShowTopCustomMessageBox2("确定", "取消", msg, callback)
end

function i3k_ui_mgr:ShowTopCustomMessageBox2(yesName, noName, msg, callback)
	self:OpenUI(eUIID_TopMessageBox2)
	self:RefreshUI(eUIID_TopMessageBox2, yesName, noName, msg, callback)
end

function i3k_ui_mgr:ShowMidMessageBox1(msg, callback)
	self:ShowMidCustomMessageBox1("确定", msg, callback)
end

function i3k_ui_mgr:ShowMidCustomMessageBox1(btnName, msg, callback)
	self:OpenUI(eUIID_MidMessageBox1)
	self:RefreshUI(eUIID_MidMessageBox1, btnName, msg, callback)
end

function i3k_ui_mgr:ShowMidMessageBox2(msg, callback)
	self:ShowMidCustomMessageBox2("确定", "取消", msg, callback)
end

function i3k_ui_mgr:ShowMidCustomMessageBox2(yesName, noName, msg, callback)
	self:OpenUI(eUIID_MidMessageBox2)
	self:RefreshUI(eUIID_MidMessageBox2, yesName, noName, msg, callback)
end
--显示帮助
function i3k_ui_mgr:ShowHelp(msg)
	self:OpenUI(eUIID_Help)
	self:RefreshUI(eUIID_Help, msg)
end
--弹出菜单列表
function i3k_ui_mgr:PopupMenuList(pos, funcs)
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
	g_i3k_ui_mgr:OpenUI(eUIID_Wjxx)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Wjxx, "popMenuList", pos, funcs)
end
--弹出战力变化
function i3k_ui_mgr:PopupPowerChange(value1,value2)
	self:CloseUI(eUIID_PowerChange)
	self:OpenUI(eUIID_PowerChange)
	self:RefreshUI(eUIID_PowerChange, value1,value2)
end
--显示普通物品信息
function i3k_ui_mgr:ShowCommonItemInfo(itemId)
	if itemId > 10000000 or itemId < -10000000 then
		local cfg = g_i3k_db.i3k_db_get_equip_item_cfg(itemId)
		if cfg.partID == eEquipFlying or cfg.partID == eEquipFlyClothes then
			self:OpenUI(eUIID_ShowFlyingEquipTips)
			self:RefreshUI(eUIID_ShowFlyingEquipTips, itemId)
		else
		self:OpenUI(eUIID_ShowEquipTips)
		self:RefreshUI(eUIID_ShowEquipTips, itemId)
		end
	else
		if g_i3k_db.i3k_db_get_common_item_type(itemId) == g_COMMON_ITEM_TYPE_PET_EQUIP then
			local data = {isOut = true, id = itemId, group = g_i3k_db.i3k_db_get_pet_equip_item_cfg(itemId).petGroupLimit}
			self:OpenUI(eUIID_PetEquipInfoTips)
			self:RefreshUI(eUIID_PetEquipInfoTips, data)
        elseif g_i3k_db.i3k_db_get_common_item_type(itemId) == g_COMMON_ITEM_TYPE_HORSE_EQUIP then
            self:OpenUI(eUIID_steedEquipPropCmp)
			self:RefreshUI(eUIID_steedEquipPropCmp, itemId, g_STEED_EQUIP_TIPS_NONE)
		else		
			self:OpenUI(eUIID_ItemInfo)
			self:RefreshUI(eUIID_ItemInfo, itemId)
		end
	end
end

--显示增益物品信息(配置表格式)
function i3k_ui_mgr:ShowGainItemInfoByCfg_safe(items, callback, needMerge)
	self:ShowGainItemInfo_safe(g_i3k_db.i3k_db_cfgItemsToItems(items), callback, needMerge)
end

--显示增益物品信息
function i3k_ui_mgr:ShowGainItemInfo_safe(items, callback, needMerge)
	if items and next(items) and #items > 0 then
		self:ShowGainItemInfo(items, callback, needMerge)
	end
end

function i3k_ui_mgr:ShowGainItemInfo(items, callback, needMerge)
	if #items <= 3 then
		g_i3k_ui_mgr:OpenUI(eUIID_UseItemGainItems)
		g_i3k_ui_mgr:RefreshUI(eUIID_UseItemGainItems, items, callback, needMerge)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_UseItemGainMoreItems)
		g_i3k_ui_mgr:RefreshUI(eUIID_UseItemGainMoreItems, items, callback)
	end
end

--显示礼包增益信息
function i3k_ui_mgr:ShowGiftPackageGainItemInfo(title,items)
	if #items <= 3 then
		g_i3k_ui_mgr:OpenUI(eUIID_UseAnimateGainItems)
		g_i3k_ui_mgr:RefreshUI(eUIID_UseAnimateGainItems,title, items)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_UseAnimateGainMoreItems)
		g_i3k_ui_mgr:RefreshUI(eUIID_UseAnimateGainMoreItems,title, items)
	end
end
--显示普通装备信息
function i3k_ui_mgr:ShowCommonEquipInfo(equip, out)
	if equip then
		local equipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(equip.equip_id)
		if equipCfg.partID == eEquipFlying or equipCfg.partID == eEquipFlyClothes then
			self:OpenUI(eUIID_FlyingEquipInfo)
			self:RefreshUI(eUIID_FlyingEquipInfo, equip, out)
		else
		self:OpenUI(eUIID_EquipTips)
		self:RefreshUI(eUIID_EquipTips, equip, out)
		end
	end
end

-- 新手关，添加遮罩，点击无效的（一段时间自动关闭）
function i3k_ui_mgr:ShowGuideUIAutoClosed(pos, radius, cb, text,step,groupID, widgetName)
	--//add by jxw 加半径为空或传0判断 防止无剪裁区域
	radius = radius or 50
	radius = radius == 0 and 50 or radius

	local clipNode = cc.ClippingNode:create()--require("ui/widgets/clipNode")()
	clipNode:setInverted(true)
	clipNode:setAlphaThreshold(0)

	local front=cc.DrawNode:create()
	local yellow = cc.c4f(1, 1, 0, 1)
	front:drawSolidCircle(pos, radius, 0, 200, yellow)
	clipNode:setStencil(front)

	g_i3k_ui_mgr._normalDesktop:addChild(clipNode, eUIO_LEADBOARDS)

	self.co3 = g_i3k_coroutine_mgr:StartCoroutine(function()
		g_i3k_coroutine_mgr.WaitForSeconds(3) --延时
		self:CloseGuideUI()
		g_i3k_coroutine_mgr:StopCoroutine(self.co3)
	end)

	self:OpenUI(eUIID_GuideUI)
	self:RefreshUI(eUIID_GuideUI, pos, radius, text)
end

-- 不包括遮罩的指引ui(新手关使用)
function i3k_ui_mgr:ShowGuideUIWithoutMask(pos, radius, cb, text,step,groupID, widgetName)
	--//add by jxw 加半径为空或传0判断 防止无剪裁区域
	radius = radius or 50
	radius = radius == 0 and 50 or radius

	local clipNode = cc.ClippingNode:create()--require("ui/widgets/clipNode")()
	clipNode:setInverted(true)
	clipNode:setAlphaThreshold(0)

	local front=cc.DrawNode:create()
	local yellow = cc.c4f(1, 1, 0, 1)
	front:drawSolidCircle(pos, radius, 0, 200, yellow)
	clipNode:setStencil(front)

	g_i3k_ui_mgr._normalDesktop:addChild(clipNode, eUIO_LEADBOARDS)

	-- local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
	-- clipNode:addChild(layerColor, eUIO_LEADBOARDS)
	-- layerColor:setTouchEnabled(true)
	local  listenner = cc.EventListenerTouchOneByOne:create()
	--ccui.TouchEvent.began
	listenner:registerScriptHandler(function(touch, event)
		local location = touch:getLocation()
		return true
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	listenner:setSwallowTouches(true)

	-- local eventDispatcher = layerColor:getEventDispatcher()
	-- eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, layerColor)

	local imgExcept = i3k_checkPList("uieffect/zhiyin.png")
	local lightNode = ccui.Button:create(imgExcept)

	local scale = radius*2/lightNode:getContentSize().width
	lightNode:setScale(scale)


	local test = clipNode:getStencil()
	if not test then
		i3k_log("stencil is nil\n");
	end
	lightNode:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if cb then
				cb();
				self:CloseGuideUI()
				-- local eventID = "引导ID"
				-- DCEvent.onEvent("引导", { eventID = groupID .. "_" .. step})
				-- g_i3k_game_context:LeadCheck(eLTEventClickTri);
			end
		end
	end)

	lightNode:setPosition(pos)
	local needScale = scale-0.1<0.1 and 0.1 or scale-0.1
	local scaleBy = cc.ScaleBy:create(0.5, needScale, needScale)
	local seq = cc.Sequence:create(scaleBy, scaleBy:reverse())
	local forever = cc.RepeatForever:create(seq)
	lightNode:runAction(forever)
	g_i3k_ui_mgr._normalDesktop:addChild(lightNode, eUIO_LEADBOARDS)
	local guideWidgets = {clipNode, lightNode}
	if not self._guideWidgets then
		self._guideWidgets = {}
	end
	table.insert(self._guideWidgets, guideWidgets)


	self:OpenUI(eUIID_GuideUI)
	self:RefreshUI(eUIID_GuideUI, pos, radius, text)
end

--显示引导UI
function i3k_ui_mgr:ShowGuideUI(pos, radius, cb, text,step,groupID)
	--//add by jxw 加半径为空或传0判断 防止无剪裁区域
	radius = radius or 50
	radius = radius == 0 and 50 or radius

	local clipNode = cc.ClippingNode:create()--require("ui/widgets/clipNode")()
	clipNode:setInverted(true)
	clipNode:setAlphaThreshold(0)

	local front=cc.DrawNode:create()
	local yellow = cc.c4f(1, 1, 0, 1)
	front:drawSolidCircle(pos, radius, 0, 200, yellow)
	clipNode:setStencil(front)

	g_i3k_ui_mgr._normalDesktop:addChild(clipNode, eUIO_LEADBOARDS)

	local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
	clipNode:addChild(layerColor, eUIO_LEADBOARDS)
	layerColor:setTouchEnabled(true)
	local  listenner = cc.EventListenerTouchOneByOne:create()
	--ccui.TouchEvent.began
	listenner:registerScriptHandler(function(touch, event)
		local location = touch:getLocation()
		return true
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	listenner:setSwallowTouches(true)

	local eventDispatcher = layerColor:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, layerColor)

	local imgExcept = i3k_checkPList("uieffect/zhiyin.png")
	local lightNode = ccui.Button:create(imgExcept)

	local scale = radius*2/lightNode:getContentSize().width
	lightNode:setScale(scale)


	local test = clipNode:getStencil()
	if not test then
		i3k_log("stencil is nil\n");
	end
	lightNode:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if cb then
				cb();
				self:CloseGuideUI()
				local eventID = "引导ID"
				DCEvent.onEvent("引导", { eventID = groupID .. "_" .. step})
				g_i3k_game_context:LeadCheck(eLTEventClickTri);
			end
		end
	end)

	lightNode:setPosition(pos)
	local needScale = scale-0.1<0.1 and 0.1 or scale-0.1
	local scaleBy = cc.ScaleBy:create(0.5, needScale, needScale)
	local seq = cc.Sequence:create(scaleBy, scaleBy:reverse())
	local forever = cc.RepeatForever:create(seq)
	lightNode:runAction(forever)
	g_i3k_ui_mgr._normalDesktop:addChild(lightNode, eUIO_LEADBOARDS)
	local guideWidgets = {clipNode, lightNode}
	if not self._guideWidgets then
		self._guideWidgets = {}
	end
	table.insert(self._guideWidgets, guideWidgets)


	self:OpenUI(eUIID_GuideUI)
	self:RefreshUI(eUIID_GuideUI, pos, radius, text)
end
--关闭引导UI
function i3k_ui_mgr:CloseGuideUI(expectGuideUI)
	if self._guideWidgets then
		for i=1, #self._guideWidgets do
			for j=1,2 do
				g_i3k_ui_mgr._normalDesktop:removeChild(self._guideWidgets[i][j], true);
				self._guideWidgets[i][j] = nil
			end
			self._guideWidgets[i] = nil
		end
	end
	if not expectGuideUI then
		self:CloseUI(eUIID_GuideUI)
	end
end

function i3k_ui_mgr:OnUpdate(dTime)
	self._tickLine = self._tickLine + dTime;
	if self._tickLine > eUpdateTickLine then
		self._tickLine = 0;

		local nowSize, afterSize = cc.Director:getInstance():getLetterCacheSize(eFontFreeTick);
		if (nowSize - afterSize) >= eFontMaxMemory then
			cc.Director:getInstance():clearFontLetterCache(eFontFreeTick);
		end
		local unusedsize = 0;
		nowSize, unusedsize = cc.Director:getInstance():getAllTextureSizeAndUnusedTextureSize(eUpdateTickLine);
		if unusedsize >= eUITexMaxMemory then
			cc.Director:getInstance():removeUnusedTextures(eUpdateTickLine);
			g_i3k_last_clear_ui_tex_cache_time = g_i3k_last_clear_ui_tex_cache_time + 1;--i3k_game_get_logic_tick()
		end
	end
	self._isUpdate = true;
	local tbl = self._cache:GetAll();
	if tbl then
		for k, v in pairs(tbl) do
			if v.open then
				v.wnd:onUpdate(dTime);
			end
		end
	end
	self._isUpdate = false;

	self._isExecutingTask = true;
	local rmvs = { };
	local ticks = i3k_get_update_tick();
	for k, v in ipairs(self._tasks) do
		if ticks > v.tick then
			local UI = self:GetUI(v.uiid)
			if UI and v.uniqueID == UI.__uniqueID then
				local ok = true
				for k, node in pairs(v.testAlives) do
					if not node.__taskCheckAlive then
						ok = false
						break
					end
				end
				if ok then
					v.cb(UI)
				end
			end
			table.insert(rmvs, k);
		end
	end
	self._isExecutingTask = false;
    --得倒序删除
	for i=#rmvs, 1, -1 do
		table.remove(self._tasks, rmvs[i]);
	end

	for k, v in ipairs(self._tasksAddList) do
		table.insert(self._tasks, v);
	end
	self._tasksAddList = {};
end
--添加任务
function i3k_ui_mgr:AddTask(ui, usedWidges, cb, addTick)
	local task = { cb = cb, tick = i3k_get_update_tick() + (addTick or 0), uiid = ui.__uiid, uniqueID = ui.__uniqueID, testAlives = {} }
	for k, v in pairs(usedWidges) do
		local node = v.root or v.ccNode_
		if node ~= nil then
			node.__taskCheckAlive = true
			table.insert(task.testAlives, node)
		end
	end
	if self._isExecutingTask == true then
		table.insert(self._tasksAddList, task);
	else
		table.insert(self._tasks, task);
	end
end
--得到当前打开用户界面
function i3k_ui_mgr:GetCurrentOpenedUIs()
	local uinames = {}
	for i, e in ipairs(self._cache:GetAllUIs()) do
		local script = i3k_ui_map[e]
		table.insert(uinames, script and script.name or e)
	end
	return uinames
end

function i3k_ui_mgr:PopTextBubble(isTrue, entity, text, nextEntity, nextText, cb)
	local uiid = eUIID_TalkPop1
	if self:GetUI(eUIID_TalkPop1) then
		uiid = eUIID_TalkPop2
	end
	if self:GetUI(eUIID_TalkPop2) then
		uiid = eUIID_TalkPop3
	end
	self:OpenUI(uiid)
	self:InvokeUIFunction(uiid, "treasureDialogue", isTrue, entity, text, nextEntity, nextText, cb)
end
--获取鼠标位置
function i3k_ui_mgr:GetMousePos()
	if g_i3k_game_handler and self._glView then
		local pos = { x = g_i3k_game_handler:GetMouseX(), y = g_i3k_game_handler:GetViewHeight() - g_i3k_game_handler:GetMouseY() };
		if self._glView then
			local vp = self._glView:getViewPortRect();
			local sx = self._glView:getScaleX();
			local sy = self._glView:getScaleY();

			pos.x = (pos.x - vp.x) / sx;
			pos.y = (pos.y - vp.y) / sy;

			return pos;
		end
	end

	return { x = 0, y = 0 };
end

function i3k_ui_mgr:GetVisibleOrigin()
	return self._director:getVisibleOrigin();
end

function i3k_ui_mgr:SetDesignResolution(r, framesize)
	local view = self._glView;

	local framesize = view:getFrameSize();

    if r.autoscale == "FILL_ALL" then
        view:setDesignResolutionSize(framesize.width, framesize.height, cc.ResolutionPolicy.FILL_ALL);
    else
        local scaleX, scaleY = framesize.width / r.width, framesize.height / r.height;
        local width, height = framesize.width, framesize.height;
        if r.autoscale == "FIXED_WIDTH" then
            width = framesize.width / scaleX;
            height = framesize.height / scaleX;
            view:setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER);
        elseif r.autoscale == "FIXED_HEIGHT" then
            width = framesize.width / scaleY;
            height = framesize.height / scaleY;
            view:setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER);
        elseif r.autoscale == "EXACT_FIT" then
            view:setDesignResolutionSize(r.width, r.height, cc.ResolutionPolicy.EXACT_FIT);
        elseif r.autoscale == "NO_BORDER" then
            view:setDesignResolutionSize(r.width, r.height, cc.ResolutionPolicy.NO_BORDER);
        elseif r.autoscale == "SHOW_ALL" then
            view:setDesignResolutionSize(r.width, r.height, cc.ResolutionPolicy.SHOW_ALL);
        end
    end
end

-- iphoneX 分辨率下的处理与pad分辨率下处理相同
function i3k_ui_mgr:JudgeIsIphoneX()
	local width = g_i3k_game_handler:GetViewWidth()
	local height = g_i3k_game_handler:GetViewHeight()
	return width/height > 2.07  -- 约 1218:562(华为 P20 2.07777)
end

function i3k_ui_mgr:JudgeIsPad()
	local width = g_i3k_game_handler:GetViewWidth()
	local height = g_i3k_game_handler:GetViewHeight()
	return width/height <= 3/2 or width/height > 2
end


function i3k_ui_mgr:PopMgrCode(code)
	local mrg_errCode = {
	[0]	= "失败",
	[-1] = "没有队伍",
	[-2] = "队伍人数非法",
	[-3] = "夫妻距离太远",
	[-4] = "队友背包满了",
	}
	if mrg_errCode[code] then
		return self:PopupTipMessage(mrg_errCode[code])
	end
end

-- 获取下拉列表的组件
function i3k_ui_mgr:createDropDownList(scrollView, info, titleRes)
	scrollView:removeAllChildren()
	if not titleRes then
		titleRes = i3k_getDropDownWidgetsMap(g_DROPDOWNLIST_DEFAULT)
	end
	local script = require("ui/widgetDropDownList");
	local widget = script.widgetDropDownList.new(scrollView, titleRes);
	widget:configure(info)
	return widget
end

-- 获取页签切换管理器
function i3k_ui_mgr:createTabManager(tabs, hoster, listener)
	local script = require("ui/widgetTabManager");
	local widget = script.widgetTabManager.new(hoster);
	widget:rgListener(listener)
	widget:configure(tabs)
	return widget
end

-- 在scrollview上列出item
function i3k_ui_mgr:refreshScrollItems(scrollView, itemsInfo, itemRes, numType, showName)
	scrollView:removeAllChildren()
	local _, items = g_i3k_game_context:simpleBagItemSort(itemsInfo)
	local bagItems = {}
	for i, info in ipairs(items) do
		local script = require("ui/widgetBagItem")
		local item = script.widgetBagItem.new(itemRes);
		item:configure(info)
		item:NumType(numType)
		item:ShowName(showName)
		scrollView:addItem(item:initView())
		table.insert(bagItems, item)
	end
	return bagItems
end



function i3k_ui_mgr:OpenAndRefresh(id, ...)
	self:OpenUI(id)
	self:RefreshUI(id, ...)
end
function i3k_ui_mgr:ShowMessageBox4(msg, callback)
	self:ShowCustomMessageBox4("确定", msg, callback)
end
function i3k_ui_mgr:ShowCustomMessageBox4(btnName, msg, callback)
	if not self:GetUI(eUIID_MessageBox4) then
		self:OpenUI(eUIID_MessageBox4)
		self:RefreshUI(eUIID_MessageBox4, btnName, msg, callback)
		return true
	end
	return false
end
--显示消息box5 --显示较多文本
function i3k_ui_mgr:ShowMessageBox5(msg, rtext, callback, callbackRadioButton, radioShow)
	self:ShowMidCustomMessageBox5Ex("确定", "取消",msg, rtext, callback, callbackRadioButton, radioShow)
end
function i3k_ui_mgr:ShowMidCustomMessageBox5Ex(yesName, noName, msg, rtext, callback, callbackRadioButton, radioShow)
	if not self:GetUI(eUIID_MessageBox5) then
		self:OpenUI(eUIID_MessageBox5)
		self:RefreshUI(eUIID_MessageBox5, yesName, noName, msg, rtext, callback, callbackRadioButton, radioShow)
		return true
	end
	return false
end
return i3k_ui_map
