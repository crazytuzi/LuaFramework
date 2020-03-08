
local tbUi = Ui:CreateClass("NotifyMsgList");
local tbGrid = Ui:CreateClass("NotifyMsgListGrid");

-- tbData 必须有szType 和 nTimeOut 两个字段，其他自定义
local tbFnSetData = {
	["InviteDungeon"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "神秘洞窟邀请")
		self.pPanel:Label_SetText("lbContent", string.format("[FFFE0D]%s[-]邀请您进入神秘洞窟", tbData.szInviteName))
	end;
	["InviteTripFuben"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "门客协助邀请")
		self.pPanel:Label_SetText("lbContent", string.format("[FFFE0D]%s[-]邀请您进入门客协助副本", tbData.szInviteName))
	end;
	["AssistTripFuben"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "门客游历协助")
		self.pPanel:Label_SetText("lbContent", string.format("门客[FFFE0D]%s[-]游历时遇险，请前往协助", tbData.szCardName))
	end;
	["PartnerCardActAward"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "门客派遣奖励")
		self.pPanel:Label_SetText("lbContent", string.format("您有门客完成了派遣任务，请至家园查看"))
	end;
	["PartnerCardComposeFinish"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "门客解封完成")
		self.pPanel:Label_SetText("lbContent", string.format("您有门客解封完成，请至家园查看"))
	end;
	["KinGather"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "家族烤火活动");
		self.pPanel:Label_SetText("lbContent", "家族烤火活动将在3分钟后开始");
	end;

	["MedalFightAct"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "奖章争夺战");
		self.pPanel:Label_SetText("lbContent", "奖章争夺战即将开始，请大侠前往家族属地点击奖章按钮参加。");
	end;

	["Boss"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "挑战武林盟主活动");
		self.pPanel:Label_SetText("lbContent", "挑战武林盟主活动开启, 是否前往参加");
	end;

	["Fairyland"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "邀请进入幻境");
		self.pPanel:Label_SetText("lbContent", string.format("「%s」盛情邀请大侠进入桃花幻境一聚！", tbData.szName));
	end;

	["Auction"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "拍卖竞价失败");
		local szMsg = string.format("【%s】竞价失败，%d%s已退还给您。", tbData.szItemName, tbData.nCurPrice, tbData.szMoneyName);
		self.pPanel:Label_SetText("lbContent", szMsg);
	end;

	["StartBattle"] = function (self, tbData)
		local tbBattleSetting = Battle:GetCanSignBattleSetting(me)
		local szName = "宋金战场"
		if tbBattleSetting and tbBattleSetting.bShowName then
			szName = tbBattleSetting.szName
		else
			szName = szName .. Battle:GetSpecialNameEndFix()
		end
		self.pPanel:Label_SetText("title", szName);
		self.pPanel:Label_SetText("lbContent", szName .. "活动开启, 是否前往参加");
	end;

	["BossResult"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "挑战武林盟主结算");
		self.pPanel:Label_SetText("lbContent", "挑战武林盟主活动已结束, 是否查看结算结果");
	end;

	["HuaShanLunJian"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "华山论剑");
		self.pPanel:Label_SetText("lbContent", "华山论剑活动已经开启，是否前往参加？");
	end;
	["HuaShanLunJianNotify"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "华山论剑");
		self.pPanel:Label_SetText("lbContent", "您的队伍成员已经进入准备场了，快一起去并肩作战吧！");
	end;
	["WuLinDaHuiNotify"] = function ( self, tbData )
		self.pPanel:Label_SetText("title", "武林大会");
		self.pPanel:Label_SetText("lbContent", "您的队伍成员已经进入准备场了，快一起去并肩作战吧！");
	end;
	["HSLJGuessing"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "华山论剑-冠军竞猜");
		self.pPanel:Label_SetText("lbContent", "华山论剑冠军竞猜将在5分钟后结束，请最后确认自己的竞猜情况！");
	end;

	["QunYingHui"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "群英会");
		self.pPanel:Label_SetText("lbContent", "群英会活动已经开启，是否前往参加？");
	end;

	["DaXueZhang"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "打雪仗");
		self.pPanel:Label_SetText("lbContent", "打雪仗活动已经开启，是否前往参加？");
	end;

	["WarOfIceAndFire"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "灭火大作战");
		self.pPanel:Label_SetText("lbContent", "灭火大作战活动已经开启，是否前往参加？");
	end;


	["KinRobber"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "家族盗贼来袭");
		self.pPanel:Label_SetText("lbContent", "家族中突然闯入一伙来历不明的盗贼");
	end;

	["KinNest"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "奸商地窖");
		self.pPanel:Label_SetText("lbContent", "族长已开启奸商地窖活动，是否前往参加？");
	end;

	["ChuangGongGet"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "传功请求");
		if tbData.dwKinId ~= 0 and tbData.dwKinId == me.dwKinId then
			self.pPanel:Label_SetText("lbContent", string.format("「%s」请求传功，是否要回到家族同意传功？", tbData.szGetName));
		else
			self.pPanel:Label_SetText("lbContent", string.format("「%s」请求传功，是否前往襄阳城同意传功？", tbData.szGetName));
		end
	end;

	["PartnerCardAddVisitor"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "新拜访者");
		self.pPanel:Label_SetText("lbContent", string.format("「%s」门客来拜访了，是否要回到家园？", tbData.szVisitorName));
	end;

	["ChuangGongSend"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "接受传功请求");
		if tbData.dwKinId ~= 0 and tbData.dwKinId == me.dwKinId then
			self.pPanel:Label_SetText("lbContent", string.format("「%s」要对你进行传功，是否要回到家族接受传功？", tbData.szSendName));
		else
			self.pPanel:Label_SetText("lbContent", string.format("「%s」要对你进行传功，是否前往襄阳城接受传功？", tbData.szSendName));
		end
	end;

	["TSChuanGongGet"] = function(self, tbData)
		self.pPanel:Label_SetText("title", "传功请求")
		local szOtherRole = tbData.bTeacher and "徒弟" or "师父"
		if tbData.nKinId ~= 0 and tbData.nKinId == me.dwKinId then
			self.pPanel:Label_SetText("lbContent", string.format("你的%s「%s」请求传功，是否要回到家族同意传功？", szOtherRole, tbData.szName))
		else
			self.pPanel:Label_SetText("lbContent", string.format("你的%s「%s」请求传功，是否同意传功？", szOtherRole, tbData.szName))
		end
	end,

	["TSChuanGongSend"] = function(self, tbData)
		self.pPanel:Label_SetText("title", "接受传功请求")
		local szOtherRole = tbData.bTeacher and "徒弟" or "师父"
		if tbData.nKinId ~= 0 and tbData.nKinId == me.dwKinId then
			self.pPanel:Label_SetText("lbContent", string.format("你的%s「%s」要对你进行传功，是否要回到家族接受传功？", szOtherRole, tbData.szName))
		else
			self.pPanel:Label_SetText("lbContent", string.format("你的%s「%s」要对你进行传功，是否前往襄阳城接受传功？", szOtherRole, tbData.szName))
		end
	end,

	["TSConnectReq"] = function(self, tbData)
		local szTitle = tbData.bOtherTeacher and "收徒请求" or "拜师请求"
		self.pPanel:Label_SetText("title", szTitle)
		local szContent = tbData.bOtherTeacher and "「%s」请求收你为徒" or "「%s」请求拜你为师"
		self.pPanel:Label_SetText("lbContent", string.format(szContent, tbData.szName))
	end,

	["TSReportReq"] = function(self, tbData)
		self.pPanel:Label_SetText("title", "师徒目标汇报")
		self.pPanel:Label_SetText("lbContent", string.format("你的徒弟「%s」向你汇报了师徒目标，请查看", tbData.szName))
	end,

	["TSAssignCustomTasks"] = function(self, tbData)
		self.pPanel:Label_SetText("title", "师父布置任务")
		self.pPanel:Label_SetText("lbContent", string.format("你的师父「%s」给你布置了任务，快去看看吧。", tbData.szName))
	end,

	["KinSecretFuben"] = function(self, tbData)
		self.pPanel:Label_SetText("title", "家族秘境")
		self.pPanel:Label_SetText("lbContent", "家族秘境已经准时开启, 是否前往参加")
	end,

	["KinDefendFuben"] = function(self, tbData)
		self.pPanel:Label_SetText("title", "家族保卫战")
		self.pPanel:Label_SetText("lbContent", "家族保卫战已经准时开启, 是否前往参加")
	end,

	["RobDebris"] = function (self, tbData)
		local tbRoleInfo = FriendShip:GetFriendDataInfo(tbData.dwID)
		self.pPanel:Label_SetText("title", "夺宝");
		self.pPanel:Button_SetText("btnGo", "复仇")
		local tbBaseInfo = KItem.GetItemBaseProp(tbData.nItemId);
		self.pPanel:Label_SetText("lbContent", string.format("「%s」在夺宝中抢走了你的【%s碎片%s】", tbRoleInfo.szName, tbBaseInfo.szName, Lib:Transfer4LenDigit2CnNum(tbData.nIndex)));
	end;

	["MapExploreAttack"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "地图探索");
		self.pPanel:Button_SetText("btnGo", "复仇")
		local tbRoleInfo = FriendShip:GetFriendDataInfo(tbData.dwID)
		self.pPanel:Label_SetText("lbContent", string.format("「%s」在探索中击杀了你，抢走了%d银两%s", tbRoleInfo.szName, tbData.nRobCoin,
			tbData.nRobJuBaoPen > 0 and string.format("(其中%d来自聚宝盆)", tbData.nRobJuBaoPen) or ""	));
	end;

	["Revenge"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "复仇");
		self.pPanel:Button_SetText("btnGo", "复仇")

		local tbRoleInfo = FriendShip:GetFriendDataInfo(tbData.dwID)

		self.pPanel:Label_SetText("lbContent", string.format("「%s」对你复仇，抢走了%d银两%s", tbRoleInfo.szName, tbData.nRobCoin, tbData.nRobJuBaoPen > 0 and string.format("(其中%d来自聚宝盆)", tbData.nRobJuBaoPen) or "" ));
	end;

	["WantedKill"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "通缉");
		self.pPanel:Button_SetText("btnGo", "复仇")

		local tbRoleInfo = FriendShip:GetFriendDataInfo(tbData.dwID)
		self.pPanel:Label_SetText("lbContent", string.format("「%s」成功将你通缉抓捕，抢走了%d银两%s",
					tbRoleInfo.szName, tbData.nRobCoin, tbData.nRobJuBaoPen > 0 and string.format("(其中%d来自聚宝盆)", tbData.nRobJuBaoPen) or "" ));
	end;

	["RankBattle"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "武神殿");
		self.pPanel:Button_SetText("btnGo", "前往");

		self.pPanel:Label_SetText("lbContent", string.format("「%s」在武神殿中将你击败，你从第%d名跌落至第%d名",
					tbData.szName, tbData.nOrgNo, tbData.nNewNo));
	end;

	["RankBattleCross"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "跨服武神殿");
		self.pPanel:Button_SetText("btnGo", "前往");
		local szServer = Sdk:GetServerDesc(tbData.nServerId)
		self.pPanel:Label_SetText("lbContent", string.format("【%s】的「%s」将你由第%d名击落至第%d名", szServer,
					tbData.szName, tbData.nOrgNo, tbData.nNewNo));
	end;

	["WhiteTigerFuben"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "白虎堂")
		self.pPanel:Button_SetText("btnGo", "参加")

		self.pPanel:Label_SetText("lbContent", "白虎堂已经准时开启, 是否前往参加")
	end;

	["FactionBattleWinner"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "门派竞技")
		self.pPanel:Button_SetText("btnGo", "查看")
		self.pPanel:Label_SetText("lbContent", string.format("第%s届的门派新人王已经产生，快看看他们都是谁吧！", Lib:Transfer4LenDigit2CnNum(tbData.nCurSession)))
	end;

	["FactionBattleCrossWinner"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "跨服门派竞技")
		self.pPanel:Button_SetText("btnGo", "查看")
		local nCrossType = tbData.nType
		local szCrossName = FactionBattle:GetNameFromCrossType(nCrossType)
		self.pPanel:Label_SetText("lbContent", string.format("跨服门派竞技%s新人王已经产生，快看看他们都是谁吧！", szCrossName))
	end;

	["TeamBattle"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "通天塔");
		self.pPanel:Button_SetText("btnGo", "查看");

		self.pPanel:Label_SetText("lbContent", "通天塔的入口已打开，众侠士可前往挑战");
	end;

	["FactionBattleStart"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "门派竞技")
		self.pPanel:Button_SetText("btnGo", "参加")
		self.pPanel:Label_SetText("lbContent", "门派竞技已经开启，是否前往参加")
	end;

	["StartDomainBattle"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "攻城战")
		self.pPanel:Button_SetText("btnGo", "参加")
		self.pPanel:Label_SetText("lbContent", "攻城战已经开启，是否前往参加")
	end;

	["DomainBattleEndMsg"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "攻城战结算")
		self.pPanel:Label_SetText("lbContent", "攻城战结束了，快去看看这次战况如何吧！")
	end;

	["ImperialTombSecretInvite"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "秦始皇陵密室")
		self.pPanel:Button_SetText("btnGo", "前往")
		self.pPanel:Label_SetText("lbContent", string.format(XT("在[FFFE0D]%s[-]身上发现了一份通往秦始皇陵密室的路线图，是否前往？"), tbData.szTitle or ""))
	end;

	["ImperialTombEmperorInvite"] = function (self, tbData)
		self.pPanel:Label_SetText("title", ImperialTomb.EMPEROR_PREPARE_MSG[tbData.bOpenFemaleEmperor].szTitle)
		self.pPanel:Button_SetText("btnGo", "前往")
		self.pPanel:Label_SetText("lbContent", ImperialTomb.EMPEROR_PREPARE_MSG[tbData.bOpenFemaleEmperor].szContent)
	end;

	["BackToZoneBattle"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "跨区战场")
		self.pPanel:Button_SetText("btnGo", "前往")
		self.pPanel:Label_SetText("lbContent", "少侠您刚掉线了，是否重新返回跨服战场")
	end;

	["StartInDifferBattle"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "心魔幻境")
		local szContent = "心魔幻境开始报名了，请侠士尽快入场"
		if tbData.tbReadyMapList then
			local szBattleType = InDifferBattle:GetTopCanSignBattleType({me}, tbData.tbReadyMapList)
			if szBattleType and szBattleType ~= "Normal" then
				szContent = InDifferBattle.tbBattleTypeSetting[szBattleType].szName .. szContent
			end
		end
		self.pPanel:Label_SetText("lbContent", szContent)
	end;

	["CrossHostStart"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "主播频道")
		Lib:Tree(tbData)
		self.pPanel:Label_SetText("lbContent", string.format("您关注的主播【%s】开播啦!", tbData.szHostName or ""));
	end;

	["Ask4DirectLevelUpItem"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "直升丹申请")
		self.pPanel:Label_SetText("lbContent", string.format("%s向你求助", tbData.szApplyer))
	end;

	["ArborDayCureAct"] = function (self)
		self.pPanel:Label_SetText("title", "比翼花/连理枝状况异常")
		self.pPanel:Label_SetText("lbContent", "你养殖的比翼花/连理枝好像有一点不对劲，快回去看看怎么回事")
	end;

	["FathersDayAct"] = function (self)
		self.pPanel:Label_SetText("title", "桃树状况异常")
		self.pPanel:Label_SetText("lbContent", "你养殖的桃树好像有一点不对劲，快回去看看怎么回事")
	end;

	["HouseInvite"] = function (self, tbData)
		local tbRoleInfo = FriendShip:GetFriendDataInfo(tbData.dwOwnerId);
		self.pPanel:Label_SetText("title", "家园入住邀请");
		self.pPanel:Label_SetText("lbContent", string.format("%s邀请你入住其家园，是否同意？", tbRoleInfo and tbRoleInfo.szName or "-"));
		self.pPanel:Button_SetText("btnGo", "同意");
	end,

	["PlantRipen"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "家园种植");
		self.pPanel:Label_SetText("lbContent", "家园种植的树丛已成熟，是否前往收成？");
		self.pPanel:Button_SetText("btnGo", "前往");
	end,

	["PlantSick"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "家园种植");
		self.pPanel:Label_SetText("lbContent", "家园种植的树丛出现了异样，是否前往养护？");
		self.pPanel:Button_SetText("btnGo", "前往");
	end,

	["InscriptionHarvest"] = function(self, tbData)
		self.pPanel:Label_SetText("title", "聚宝盆");
		self.pPanel:Label_SetText("lbContent", "铭文已铸造完毕，是否前往收取？");
		self.pPanel:Button_SetText("btnGo", "前往");
	end,

	["ToMuchMailList"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "满邮件");
		self.pPanel:Label_SetText("lbContent", "您的邮件已经快满了，请尽快领取以防邮件丢失");
		self.pPanel:Button_SetText("btnGo", "前往");
	end,

	["WuLinDaHui"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "武林大会");
		local nGameType = tbData.nGameType
		local tbGameFormat = WuLinDaHui.tbGameFormat[nGameType]
		local szMsg = tbData.bFinal and string.format("武林大会[FFFE0D]「%s」[-]的决赛开始，请尽快入场！", tbGameFormat.szName) or string.format("武林大会[FFFE0D]「%s」[-]的初赛开始，请尽快参加！", tbGameFormat.szName)
		self.pPanel:Label_SetText("lbContent", szMsg);
		self.pPanel:Button_SetText("btnGo", "前往");
	end,

	["WeddingTourBaseInvite"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "游城邀请")
		self.pPanel:Button_SetText("btnGo", "参加")
		self.pPanel:Label_SetText("lbContent", string.format("%s", tbData.szContent or ""))
	end;

	["DomainCrossStart"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "跨服攻城战")
		self.pPanel:Button_SetText("btnGo", "参加")
		self.pPanel:Label_SetText("lbContent", "跨服攻城战已经开启，是否前往参加")
	end;


	["NewYearQAAct"] = function (self, tbData)
		local szTitle = Activity.NewYearQAAct:GetValue("szMailTitle")
		self.pPanel:Label_SetText("title", szTitle)
		self.pPanel:Button_SetText("btnGo", "参加")

		local szTips = Activity.NewYearQAAct:GetValue("szCreateQuestionTips")
		self.pPanel:Label_SetText("lbContent", szTips)
	end;

	["NotifyUseClearFirstRecharge"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "双倍重置令");
		local pItem = me.GetItemInBag(tbData.nId)
		if not pItem then
			return
		end
		local nEndTime = pItem.GetIntValue(-9996)
		local nNow = GetTime();

		self.pPanel:Label_SetText("lbContent", string.format("您的双倍重置令还有%s就要过期了，请尽快使用", Lib:TimeDesc13(nEndTime - nNow)) );
		self.pPanel:Button_SetText("btnGo", "查看");
	end;
	["StartDanceMatch"] = function (self, tbData)
		self.pPanel:Label_SetText("title", Activity.DanceMatch.tbSetting.szActName);
		self.pPanel:Button_SetText("btnGo", "参加")
		self.pPanel:Label_SetText("lbContent", string.format("%s已经开启，是否前往参加", Activity.DanceMatch.tbSetting.szActName))
	end;
	["DanceMatchOpenMusc"] = function ( self, tbData )
		self.pPanel:Label_SetText("title", Activity.DanceMatch.tbSetting.szActName);
		self.pPanel:Label_SetText("lbContent", "打开音乐，体验更佳！")
	end;

	["KinEncounter"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "家族遭遇战")
		self.pPanel:Button_SetText("btnGo", "参加")
		self.pPanel:Label_SetText("lbContent", "家族遭遇战已经开启，是否前往参加")
	end;

	["StartKeyQuestFuben"] = function (self, tbData )
		self.pPanel:Label_SetText("title", Fuben.KeyQuestFuben.DEFINE.NAME);
		self.pPanel:Button_SetText("btnGo", "参加")
		self.pPanel:Label_SetText("lbContent", string.format("%s已经开启，是否前往参加", Fuben.KeyQuestFuben.DEFINE.NAME))
	end;

	["DumplingBanquetActStart"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "饺子宴")
		self.pPanel:Button_SetText("btnGo", "参加")
		self.pPanel:Label_SetText("lbContent", "家族今日饺子宴已经开启，是否前往参加")
	end;

	["BrocadeBoxActPut"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "锦盒活动")
		self.pPanel:Button_SetText("btnGo", "前往")
		self.pPanel:Label_SetText("lbContent", "有人在您的家园放置了锦盒，快回家看一看，猜一猜是谁赠送的吧")
	end;

	["ApplyReunion"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "重逢邀请")
		self.pPanel:Button_SetText("btnGo", "同意")
		self.pPanel:Label_SetText("lbContent", string.format("[FFFE0D]%s[-]邀请您组成重逢关系", tbData.szApplyName))
	end;

	["ReunionChuanGongGet"] = function(self, tbData)
		self.pPanel:Label_SetText("title", "传功请求")
		local szOtherRole = tbData.bGuider and "向导" or "召回"
		if tbData.nKinId ~= 0 and tbData.nKinId == me.dwKinId then
			self.pPanel:Label_SetText("lbContent", string.format("你的%s「%s」请求传功，是否要回到家族同意传功？", szOtherRole, tbData.szName))
		else
			self.pPanel:Label_SetText("lbContent", string.format("你的%s「%s」请求传功，是否同意传功？", szOtherRole, tbData.szName))
		end
	end,

	["ReunionChuanGongSend"] = function(self, tbData)
		self.pPanel:Label_SetText("title", "接受传功请求")
		local szOtherRole = tbData.bGuider and "向导" or "召回"
		if tbData.nKinId ~= 0 and tbData.nKinId == me.dwKinId then
			self.pPanel:Label_SetText("lbContent", string.format("你的%s「%s」要对你进行传功，是否要回到家族接受传功？", szOtherRole, tbData.szName))
		else
			self.pPanel:Label_SetText("lbContent", string.format("你的%s「%s」要对你进行传功，是否前往襄阳城接受传功？", szOtherRole, tbData.szName))
		end
	end,

	["StartLingTuZhan"] = function ( self, tbData )
		self.pPanel:Label_SetText("title", "跨服领土战")
		self.pPanel:Button_SetText("btnGo", "前往")
		self.pPanel:Label_SetText("lbContent", "跨服领土战活动开启了")
	end;

	["AnniversaryJiYuAct"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "周年寄语活动")
		self.pPanel:Button_SetText("btnGo", "参加")
		self.pPanel:Label_SetText("lbContent", "酒宴开始了，是否前往参加？")
	end;
	["ChangBaiZhiDian"] = function (self, tbData)
		self.pPanel:Label_SetText("title", "长白之巅")
		self.pPanel:Button_SetText("btnGo", "参加")
		self.pPanel:Label_SetText("lbContent", "长白之巅活动开启了，是否前往参加？")
	end;
	["KinFoKuBattle"] = function(self, tbData)
		self.pPanel:Label_SetText("title", "龙门之争");
		self.pPanel:Button_SetText("btnGo", "允许");
		self.pPanel:Label_SetText("lbContent",string.format("[FFFE0D]「%s」[-]率领[FFFE0D]%d[-]人队伍，想要申请进入精英赛场，是否允许？",tbData.szName,tbData.nNum));
	end;
	["DaMoCave"] = function(self, tbData)
		self.pPanel:Label_SetText("title", "达摩洞")
		self.pPanel:Button_SetText("btnGo", "参加")
		self.pPanel:Label_SetText("lbContent", "达摩洞活动开始了，是否前往参加？")
	end;
	["KinChaosFight"] = function(self, tbData)
		self.pPanel:Label_SetText("title", tbData.szActName)
		self.pPanel:Button_SetText("btnGo", "前往")
		self.pPanel:Label_SetText("lbContent", string.format("%s决赛开始了，点击前往参加！", tbData.szActName or "大乱斗"))
	end;
}

--设置后同类型同key下就只能一条的消息，会替换掉
local tbUniqueNotifyMsg = {
	--szType           key
	["InviteDungeon"] = "dwInviteRoleId";
	["InviteTripFuben"] = "dwInviteRoleId";
	["AssistTripFuben"] = "nCardId";
	["ChuangGongGet"] = "dwGetId";
	["ChuangGongSend"] = "dwSendId";
	["TSChuanGongGet"] = "nId";
	["TSChuanGongSend"] = "nId";
	["TSConnectReq"] = "nId";
	["TSReportReq"] = "nId";
	["TSAssignCustomTasks"] = "nId";
	["HouseInvite"] = "dwOwnerId",
	["ToMuchMailList"] = "nId",
	["PartnerCardAddVisitor"] = "nVisitPlayerId",
	["PartnerCardActAward"] = "nOwnId";
	["PartnerCardComposeFinish"] = "nCardId";
	["BrocadeBoxActPut"] = "dwOwnerId",
	["ReunionChuanGongSend"] = "nId";
	["ReunionChuanGongGet"] = "nId";
	["ApplyReunion"] = "nApplyPlayer";
}

--返回true就是点击后会移除该条消息 self 是tbGrid
local tbFnProcess = {
	["InviteDungeon"] = function (self)
		local fnConfrim = function ()
			RemoteServer.DungeonFubenInviteApply(self.tbData.dwInviteRoleId)
		 	self.tbData.nTimeOut = 0; --处理完设置其过期
			Ui:RemoveTimeOutMsg();
			return true
		end

		if me.dwTeamID and me.dwTeamID ~= 0 then
			Ui:OpenWindow("MessageBox",
			 "您要脱离当前队伍，前往神秘洞窟吗？",
			 { {fnConfrim}, {}  },
			 {"同意", "取消"});
			return
		end

		return fnConfrim()
	end;

	["InviteTripFuben"] = function (self)
		local fnConfrim = function ()
			RemoteServer.PartnerCardOnClientCall("InviteApply2TripFuben", self.tbData.dwInviteRoleId)
		 	self.tbData.nTimeOut = 0; --处理完设置其过期
			Ui:RemoveTimeOutMsg();
			return true
		end

		if me.dwTeamID and me.dwTeamID ~= 0 then
			Ui:OpenWindow("MessageBox",
			 "您要脱离当前队伍，前往门客协助副本吗？",
			 { {fnConfrim}, {}  },
			 {"同意", "取消"});
			return
		end

		return fnConfrim()
	end;
	["AssistTripFuben"] = function (self)
		local fnConfrim = function ()
			RemoteServer.PartnerCardOnClientCall("StartTripFuben", self.tbData.nCardId)
		 	self.tbData.nTimeOut = 0; --处理完设置其过期
			Ui:RemoveTimeOutMsg();
			return true
		end

		if me.dwTeamID and me.dwTeamID ~= 0 then
			Ui:OpenWindow("MessageBox",
			 "您要脱离当前队伍，前往门客协助副本吗？",
			 { {fnConfrim}, {}  },
			 {"同意", "取消"});
			return
		end

		return fnConfrim()
	end;

	["KinGather"] = function (self)
		Kin:GoKinMap();
		return true;
	end;

	["MedalFightAct"] = function (self)
		Kin:GoKinMap();
		return true;
	end;

	["KinRobber"] = function (self)
		Kin:GoKinMap();
		return true;
	end;

	["KinNest"] = function (self)
		RemoteServer.EnterKinNest();
		return true;
	end;

	["ChuangGongGet"] = function (self)
		local bRet, szMsg = ChuangGong:AcceptSendChuangGong(self.tbData.dwGetId)
		if szMsg then
			me.CenterMsg(szMsg)
		end
		if bRet then
			AutoFight:StopAll();
		end
		return bRet
	end;

	["PartnerCardAddVisitor"] = function (self)
		if House.bHasHouse then
			if House:IsInOwnHouse(me) then
				me.CenterMsg("已经在家园了", true)
				return
			end
			AutoFight:StopAll();
			RemoteServer.EnterHome(me.dwID);
		else
			me.CenterMsg("你还没有家园", true)
		end
		return true
	end;

	["PartnerCardActAward"] = function (self)
		if House.bHasHouse then
			if House:IsInOwnHouse(me) then
				Ui:OpenWindow("PartnerCardActivityPanel")
			else
				AutoFight:StopAll();
				RemoteServer.EnterHome(me.dwID);
			end
		else
			me.CenterMsg("你还没有家园", true)
		end
		return true
	end;

	["PartnerCardComposeFinish"] = function (self)
		if House.bHasHouse then
			if House:IsInOwnHouse(me) then
				me.CenterMsg("已经在家园了", true)
				return true
			end
			AutoFight:StopAll();
			RemoteServer.EnterHome(me.dwID);
		else
			me.CenterMsg("你还没有家园", true)
		end
		return true
	end;

	["ChuangGongSend"] = function (self)
		local bRet, szMsg = ChuangGong:AcceptGetChuangGong(self.tbData.dwSendId)
		if szMsg then
			me.CenterMsg(szMsg)
		end
		if bRet then
			AutoFight:StopAll();
		end
		return bRet
	end;

	["TSChuanGongGet"] = function(self)
		TeacherStudent:AcceptChuanGongReq(self.tbData.nId)
		return true
	end,

	["TSChuanGongSend"] = function(self)
		TeacherStudent:AcceptChuanGongReq(self.tbData.nId)
		return true
	end,

	["TSConnectReq"] = function(self)
		Ui:OpenWindow("SocialPanel", "MasterPanel", "ApplyList")
		return true
	end,

	["TSReportReq"] = function(self)
		Ui:OpenWindow("StudentReportPanel", self.tbData.nId, self.tbData.szName, self.tbData.tbTargets)
		return true
	end,

	["TSAssignCustomTasks"] = function(self)
		Ui:OpenWindow("SocialPanel", "MasterPanel", "MainInfo")
		return true
	end,

	["KinSecretFuben"] = function(self)
		Ui:OpenWindow("KinSecretSelectPanel")
		return true
	end,

	["KinDefendFuben"] = function(self)
		Ui:OpenWindow("KinDefendPanel")
		return true
	end,

	["Boss"] = function (self)
		Ui:OpenWindow("BossPanel");
		return true;
	end;

	["Fairyland"] = function (self)
		House.tbPeach:InvitedIntoFairyland(self.tbData.nFairyId);
		return true;
	end;

	["Auction"] = function (self)
		Ui:OpenWindow("AuctionPanel", "MyBiding");
		return true;
	end;

	["HuaShanLunJian"] = function (self)
		Ui:OpenWindow("HSLJPanel");
		return true;
	end;
	["HuaShanLunJianNotify"] = function (self )
		Ui:OpenWindow("HSLJPanel");
		return true;
	end;
	["WuLinDaHuiNotify"] = function ( self )
		Ui:OpenWindow("WLDHJoinPanel", self.tbData.nGameType)
		return true;
	end;

	["HSLJGuessing"] = function (self)
    	Ui:OpenWindow("HSLJBattlefieldPanel");
	    return true;
	end;

	["QunYingHui"] = function (self)
		Ui:OpenWindow("QYHEntrance");
		return true;
	end;

	["DaXueZhang"] = function (self)
		if Activity:__IsActInProcessByType("KinChaosFightAct") then
			Ui:OpenWindow("KinChaosFightPanel")
		else
			Ui:OpenWindow("SnowballPanel");
		end
		return true;
	end;

	["WarOfIceAndFire"] = function (self)
		Ui:OpenWindow("ExtinguishingPanel");
		return true;
	end;

	["StartBattle"] = function (self)
		Ui:OpenWindow("BattleEntrance");
		return true;
	end;

	["BossResult"] = function (self)
		Ui:OpenWindow("BossResult", unpack(self.tbData.tbResult));
		return true;
	end;

	["RobDebris"] = function (self)
		local tbRoleInfo = FriendShip:GetFriendDataInfo(self.tbData.dwID)
		FriendShip:DoRevenge(tbRoleInfo)
		return true;
	end;

	["MapExploreAttack"] = function (self)
		local tbRoleInfo = FriendShip:GetFriendDataInfo(self.tbData.dwID)
		FriendShip:DoRevenge(tbRoleInfo)
		return true;
	end;

	["Revenge"] = function (self)
		local tbRoleInfo = FriendShip:GetFriendDataInfo(self.tbData.dwID)
		FriendShip:DoRevenge(tbRoleInfo)
		return true;
	end;

	["WantedKill"] = function (self)
		local tbRoleInfo = FriendShip:GetFriendDataInfo(self.tbData.dwID)
		FriendShip:DoRevenge(tbRoleInfo)
		return true;
	end;

	["RankBattle"]  = function (self)
		Ui:OpenWindow("RankPanel");
		return true;
	end;

	["RankBattleCross"]  = function (self)
		Ui:OpenWindow("RankPanel", 2);
		return true;
	end;

	["WhiteTigerFuben"] = function (self)
		Fuben.WhiteTigerFuben:Join()
		AutoFight:StopAll();
		return true
	end;

	["FactionBattleWinner"] = function (self)
		Ui:OpenWindow("NewInformationPanel", "FactionBattle")
		return true
	end;

	["FactionBattleCrossWinner"] = function (self)
		Ui:OpenWindow("NewInformationPanel", "FactionBattleCross")
		return true
	end;

	["TeamBattle"] = function (self)
		Ui:OpenWindow("TeamBattlePanel");
		return true;
	end;

	["FactionBattleStart"] = function (self)
		FactionBattle:Join()
		return true
	end;
	["StartDomainBattle"] = function (self)
		Ui:OpenWindow("KinDetailPanel", "DomainBattleMain")
		return true
	end;
	["DomainBattleEndMsg"] = function (self)
		Ui:OpenWindow("DomainBattleReport", true)
		return true
	end;

	["ImperialTombSecretInvite"] = function (self)
		local bRet = ImperialTomb:SecretEnterRequest();
		if bRet then
			AutoFight:StopAll();
		end
		return bRet;
	end;

	["ImperialTombEmperorInvite"] = function (self)
		Ui:OpenWindow("ImperialTombPanel", self.tbData.bOpenFemaleEmperor)
		return true
	end;

	["BackToZoneBattle"] = function (self)
		RemoteServer.ReEnterZoneBattle();
		return true
	end;

	["StartInDifferBattle"] = function (self)
		local szBattleType = InDifferBattle:GetTopCanSignBattleType({me}, self.tbData.tbReadyMapList)
		Ui:OpenWindow("DreamlandJoinPanel", szBattleType)
		return true
	end;

	["CrossHostStart"] = function (self)
		Ui:OpenWindow("ChatLargePanel", ChatMgr.ChannelType.Cross);
		return true
	end;

	["Ask4DirectLevelUpItem"] = function (self)
		Ui:OpenWindow("SendGiftPanel", "HelpFriend")
		return true
	end;

	["ArborDayCureAct"] = function (self)
		RemoteServer.ArborDayTryGoHouse()
		return true
	end;

	["FathersDayAct"] = function (self)
		local szLink = self.tbData.szLink
		Ui.HyperTextHandle:Handle(szLink, 0, 0)
		return true
	end;

	["HouseInvite"] = function (self)
		RemoteServer.CheckIn(self.tbData.dwOwnerId);
		return true;
	end,

	["PlantRipen"] = function (self)
		RemoteServer.GotoLand(me.dwID);
		return true;
	end,

	["PlantSick"] = function (self)
		RemoteServer.GotoLand(me.dwID);
		return true;
	end,

	["InscriptionHarvest"] = function(self)
		RemoteServer.GotoMagicBowl()
		return true
	end,

	["ToMuchMailList"] = function (self)
		Ui:OpenWindow("ChatLargePanel", ChatMgr.nChannelMail)
		return true
	end,
	["WuLinDaHui"] = function (self)
		Ui:OpenWindow("WLDHJoinPanel", self.tbData.nGameType)
		return true
	end,
	["WeddingTourBaseInvite"] = function (self)
		Ui.HyperTextHandle:Handle(string.format("[url=npc:text, %d, %d]", Wedding.nTourMsgListGoNpcTId, Wedding.nTourMapTemplateId), 0, 0)
		return true
	end;

	["DomainCrossStart"] = function (self)
		RemoteServer.CrossDomainEnterReq()
		return true
	end;

	["NewYearQAAct"] = function (self)
		Activity.NewYearQAAct:TryOpenAnswerUi()
		return true
	end;
	["NotifyUseClearFirstRecharge"] = function (self)
		Item:ShowItemDetail({nItemId = self.tbData.nId})
		return true
	end;
	["StartDanceMatch"] = function (self)
		Activity.DanceMatch:TrySignUp()
		return true
	end;
	["DanceMatchOpenMusc"] = function ( self )
		Ui:OpenWindow("RoleInformationPanel", nil, "BtnSetting")
		return true
	end;
	["KinEncounter"] = function (self)
		Ui:OpenWindow("KinEncounterJoinPanel")
		return true
	end;
	["StartKeyQuestFuben"] = function (self)
		Ui:OpenWindow("RuinsTreasureEntrance")
		return true
	end;
	["DumplingBanquetActStart"] = function (self)
		Kin:GoKinMap()
		return true
	end;
	["BrocadeBoxActPut"] = function (self)
		RemoteServer.EnterHome(me.dwID)
		return true
	end;
	["ApplyReunion"] = function (self)
		RemoteServer.ReunionOnClientCall("AgreeApply", self.tbData.nApplyPlayer)
		return true
	end;
	["ReunionChuanGongGet"] = function(self)
		RemoteServer.ReunionOnClientCall("AgreeChuanGong", self.tbData.nId)
		return true
	end,
	["ReunionChuanGongSend"] = function(self)
		RemoteServer.ReunionOnClientCall("AgreeChuanGong", self.tbData.nId)
		return true
	end,
	["StartLingTuZhan"] = function ( self )
		Ui:OpenWindow("TerritorialWarMapPanel")
		return true
	end;
	["AnniversaryJiYuAct"] = function (self)
		local tbAct = Activity.AnniversaryJiYuAct or {}
		if tbAct.GotoDrink then
			tbAct:GotoDrink(false)
		end
		return true
	end;
	["ChangBaiZhiDian"] = function (self)
		Ui:OpenWindow("ChangBaiZhiDianSignUpPanel")
		return true
	end;

	["KinFoKuBattle"] = function (self)
		KinBattle.Foku:EnterSure(self.tbData.nApplyPlayer);
		return true;
	end;
	["DaMoCave"] = function(self)
		Ui:OpenWindow("DaMoCavePanel")
		return true;
	end;
	["KinChaosFight"] = function(self)
		Ui:OpenWindow("KinChaosFightPanel")
		return true;
	end;
}

local tbSpecialCheck =
{
	["ChuangGongGet"] = function (self)
		local bNoFuben = AsyncBattle.ASYNC_BATTLE_MAP_TYPE[Map:GetClassDesc(me.nMapTemplateId)]
		if not ChuangGong:CheckMap() and bNoFuben then
			local fnCall = function ()
				self.tbOnClick.btnGo(self)
				UiNotify.OnNotify(UiNotify.emNOTIFY_NOTIFY_PROCESS_MSG);
			end
			ChuangGong:GoSafe(fnCall, ChuangGong.szBtnGoSafeTip)
			Ui:CloseWindow("NotifyMsgList")
			return false
		end

		if ChuangGong:IsWhiteMap(me.nMapTemplateId) then
			return true;
		end

		if not bNoFuben then
			return false,"当前地图不允许参与，请先返回襄阳或忘忧岛再尝试！"
		end

		return true
	end;

	["ChuangGongSend"] = function (self)
		local bNoFuben = AsyncBattle.ASYNC_BATTLE_MAP_TYPE[Map:GetClassDesc(me.nMapTemplateId)]
		if not ChuangGong:CheckMap() and bNoFuben then
			local fnCall = function ()
				self.tbOnClick.btnGo(self)
				UiNotify.OnNotify(UiNotify.emNOTIFY_NOTIFY_PROCESS_MSG);
			end
			ChuangGong:GoSafe(fnCall, ChuangGong.szBtnGoSafeTip)
			Ui:CloseWindow("NotifyMsgList")
			return false
		end

		if ChuangGong:IsWhiteMap(me.nMapTemplateId) then
			return true;
		end

		if not bNoFuben then
			return false,"当前地图不允许参与，请先返回襄阳或忘忧岛再尝试！"
		end

		return true
	end;

	["TSChuanGongGet"] = function(self)
		local bNoFuben = AsyncBattle.ASYNC_BATTLE_MAP_TYPE[Map:GetClassDesc(me.nMapTemplateId)]
		if not ChuangGong:CheckMap() and bNoFuben then
			local fnCall = function ()
				self.tbOnClick.btnGo(self)
				UiNotify.OnNotify(UiNotify.emNOTIFY_NOTIFY_PROCESS_MSG);
			end
			ChuangGong:GoSafe(fnCall, ChuangGong.szBtnGoSafeTip)
			Ui:CloseWindow("NotifyMsgList")
			return false
		end

		if ChuangGong:IsWhiteMap(me.nMapTemplateId) then
			return true;
		end

		if not bNoFuben then
			return false,"当前地图不允许参与，请先返回襄阳或忘忧岛再尝试！"
		end

		return true
	end;

	["TSChuanGongSend"] = function(self)
		local bNoFuben = AsyncBattle.ASYNC_BATTLE_MAP_TYPE[Map:GetClassDesc(me.nMapTemplateId)]
		if not ChuangGong:CheckMap() and bNoFuben then
			local fnCall = function ()
				self.tbOnClick.btnGo(self)
				UiNotify.OnNotify(UiNotify.emNOTIFY_NOTIFY_PROCESS_MSG);
			end
			ChuangGong:GoSafe(fnCall, ChuangGong.szBtnGoSafeTip)
			Ui:CloseWindow("NotifyMsgList")
			return false
		end

		if ChuangGong:IsWhiteMap(me.nMapTemplateId) then
			return true;
		end

		if not bNoFuben then
			return false,"当前地图不允许参与，请先返回襄阳或忘忧岛再尝试！"
		end

		return true
	end;
	["AssistTripFuben"] = function ()
		if Map:IsHouseMap(me.nMapTemplateId) then
			return true
		end
		if not AsyncBattle.ASYNC_BATTLE_MAP_TYPE[Map:GetClassDesc(me.nMapTemplateId)] then
			return false,"当前地图不允许参与，请先返回襄阳或忘忧岛再尝试！"
		end

		return true
	end;
	["PartnerCardActAward"] = function ()
		if House:IsInOwnHouse(me) then
			return true
		end
		if not AsyncBattle.ASYNC_BATTLE_MAP_TYPE[Map:GetClassDesc(me.nMapTemplateId)] then
			return false,"当前地图不允许参与，请先返回襄阳或忘忧岛再尝试！"
		end

		return true
	end;
	["PartnerCardComposeFinish"] = function ()
		if Map:IsHouseMap(me.nMapTemplateId) then
			return true
		end
		if not AsyncBattle.ASYNC_BATTLE_MAP_TYPE[Map:GetClassDesc(me.nMapTemplateId)] then
			return false,"当前地图不允许参与，请先返回襄阳或忘忧岛再尝试！"
		end

		return true
	end;

	["Auction"] = function (self)
		return true
	end;

	["RankBattle"] = function (self)
		return true
	end;

	["RankBattleCross"] = function (self)
		return true
	end;

	["FactionBattleWinner"] = function (self)
		return true
	end;

	["FactionBattleCrossWinner"] = function (self)
		return true
	end;

	["Boss"] = function (self)
		return Boss:IsFightMap(me.nMapTemplateId), "当前地图不允许参与，请先返回襄阳或忘忧岛再尝试！";
	end;

	["BossResult"] = function (self)
		return true;
	end;

	["DomainBattleEndMsg"] = function (self)
		return  true
	end;

	["ImperialTombSecretInvite"] = function (self)
		return  true
	end;

	["ImperialTombEmperorInvite"] = function (self)
		return  true
	end;

	["TSConnectReq"] = function(self)
		return true
	end,

	["TSReportReq"] = function(self)
		return true
	end,

	["TSAssignCustomTasks"] = function(self)
		return true
	end,

	["CrossHostStart"] = function (self)
		return true;
	end,

	["KinNest"] = function(self)
		if me.nMapTemplateId == Kin.Def.nKinMapTemplateId then
			return true
		end
		if not AsyncBattle.ASYNC_BATTLE_MAP_TYPE[Map:GetClassDesc(me.nMapTemplateId)] then
			return false,"当前地图不允许参与，请先返回襄阳或忘忧岛再尝试！"
		end

		if not Map:IsCityMap(me.nMapTemplateId) then
			if Map:GetClassDesc(me.nMapTemplateId) ~= "fight" or me.nFightMode ~= 0 then
				return false, "当前地图不允许参与，请先返回襄阳或忘忧岛再尝试！"
			end
		end

		return true
	end,

	["KinEncounter"] = function(self)
		if me.nMapTemplateId == Kin.Def.nKinMapTemplateId then
			return true
		end
		if not AsyncBattle.ASYNC_BATTLE_MAP_TYPE[Map:GetClassDesc(me.nMapTemplateId)] then
			return false,"当前地图不允许参与，请先返回襄阳或忘忧岛再尝试！"
		end

		if not Map:IsCityMap(me.nMapTemplateId) then
			if Map:GetClassDesc(me.nMapTemplateId) ~= "fight" or me.nFightMode ~= 0 then
				return false, "当前地图不允许参与，请先返回襄阳或忘忧岛再尝试！"
			end
		end

		return true
	end,

	["HouseInvite"] = function (self)
		return true;
	end,

	["PlantRipen"] = function (self)
		return House:CheckCanEnterMap(me);
	end,

	["PlantSick"] = function (self)
		return House:CheckCanEnterMap(me);
	end,

	["InscriptionHarvest"] = function(self)
		return House:CheckCanEnterMap(me);
	end,
	["PartnerCardAddVisitor"] = function (self)
		if House.bHasHouse and House:IsInOwnHouse(me) then
			return false, "已经在家园了"
		end
		return true;
	end,
	["ReunionChuanGongGet"] = function(self)
		if not ChuangGong:CheckMap() then
			local fnCall = function ()
				self.tbOnClick.btnGo(self)
				UiNotify.OnNotify(UiNotify.emNOTIFY_NOTIFY_PROCESS_MSG);
			end
			ChuangGong:GoSafe(fnCall, ChuangGong.szBtnGoSafeTip)
			Ui:CloseWindow("NotifyMsgList")
			return false
		end

		if ChuangGong:IsWhiteMap(me.nMapTemplateId) then
			return true;
		end

		if not AsyncBattle.ASYNC_BATTLE_MAP_TYPE[Map:GetClassDesc(me.nMapTemplateId)] then
			return false,"当前地图不允许参与，请先返回襄阳或忘忧岛再尝试！"
		end

		return true
	end,
	["ReunionChuanGongSend"] = function(self)
		if not ChuangGong:CheckMap() then
			local fnCall = function ()
				self.tbOnClick.btnGo(self)
				UiNotify.OnNotify(UiNotify.emNOTIFY_NOTIFY_PROCESS_MSG);
			end
			ChuangGong:GoSafe(fnCall, ChuangGong.szBtnGoSafeTip)
			Ui:CloseWindow("NotifyMsgList")
			return false
		end

		if ChuangGong:IsWhiteMap(me.nMapTemplateId) then
			return true;
		end

		if not AsyncBattle.ASYNC_BATTLE_MAP_TYPE[Map:GetClassDesc(me.nMapTemplateId)] then
			return false,"当前地图不允许参与，请先返回襄阳或忘忧岛再尝试！"
		end

		return true
	end,
	["DanceMatchOpenMusc"] = function ( self )
		return true;
	end,
	["KinFoKuBattle"] = function ( self )
		return true;
	end,
}

--通知特殊图标的优先级
local tbIconPriority = {
	["ImperialTombEmperorInvite"] = {szSprite="New_03", nPriority = 1},
	["ImperialTombSecretInvite"] = {szSprite="New_03", nPriority = 1},
	["WuLinDaHui"] = {szSprite="New_04", nPriority = 1},
	["WuLinDaHuiNotify"] = {szSprite="New_04", nPriority = 1},
	["HuaShanLunJian"] = {szSprite="New_04", nPriority = 1},
	["HuaShanLunJianNotify"] = {szSprite="New_04", nPriority = 1},

}

local function InitCheck()
	for k,v in pairs(tbFnSetData) do
		assert(tbFnProcess[k], k)
	end
end

InitCheck();

function tbGrid:SetData(tbData)
	self.tbData = tbData  --todo
	local fnSetData = tbFnSetData[tbData.szType]
	if not fnSetData then
		Log("Error!! NotifyMsgList, szType:", tbData.szType)
		return
	end

	self.pPanel:Button_SetText("btnGo", "前往")
	fnSetData(self, tbData)
end

tbGrid.tbOnClick = {}

--处理该消息
tbGrid.tbOnClick.btnGo = function (self)
	local tbData = self.tbData
	if tbData.nTimeOut <= GetTime() then
		me.CenterMsg("消息已过期")
		Ui:OpenWindow("NotifyMsgList")
		return
	end

    local bRet = Map:IsForbidTransEnter(me.nMapTemplateId);
	if IsAlone() == 1 or bRet then
		me.CenterMsg("当前地图不允许参与，请先返回襄阳或忘忧岛再尝试！")
		return
	end

	if tbSpecialCheck[self.tbData.szType] then
		local fnCheck = tbSpecialCheck[self.tbData.szType]
		local bRet,szMsg = fnCheck(self)
		if not bRet then
			if szMsg then
				me.CenterMsg(szMsg)
			end
			return
		end
	elseif  Map.tbFieldFightMap[me.nMapTemplateId] and me.nFightMode == 1 and not self.bOnAutoPath then
		local fnCallBack = function ()
			self.bOnAutoPath = true;
			self.tbOnClick.btnGo(self)
			UiNotify.OnNotify(UiNotify.emNOTIFY_NOTIFY_PROCESS_MSG);
		end
		me.CenterMsg("当前不允许参与，正在自动寻路回安全区")
		local nX, nY = Map:GetDefaultPos(me.nMapTemplateId)
		AutoPath:GotoAndCall(me.nMapTemplateId, nX, nY, fnCallBack)
		Ui:CloseWindow("NotifyMsgList")
		return
	elseif not AsyncBattle.ASYNC_BATTLE_MAP_TYPE[ Map:GetClassDesc(me.nMapTemplateId) ]  then
		me.CenterMsg("当前地图不允许参与，请先返回襄阳或忘忧岛再尝试！")
		return
	end

	self.bOnAutoPath = nil;

	local fnProcess = tbFnProcess[tbData.szType]
	local bRet = fnProcess(self);
	if not bRet then
		return
	end

	tbData.nTimeOut = 0; --处理完设置其过期
	Ui:RemoveTimeOutMsg();
	Ui:CloseWindow("NotifyMsgList")
end

--总的未处理消息数，未读消息数
function tbUi:GetMsgNum()
	return #Ui.tbNotifyMsgDatas, Ui.nUnReadNotifyMsgNum
end

local tbCheckRemoveShowWhenOpen =
{
	["RobDebris"] = function (tbData )
		return FriendShip:GetFriendDataInfo(tbData.dwID)
	end,
	["MapExploreAttack"] =  function (tbData )
		return FriendShip:GetFriendDataInfo(tbData.dwID)
	end,
	["Revenge"] =  function (tbData )
		return FriendShip:GetFriendDataInfo(tbData.dwID)
	end,
	["WantedKill"] =  function (tbData )
		return FriendShip:GetFriendDataInfo(tbData.dwID)
	end,

}

function Ui:RemoveTimeOutMsg()
	local nTimeNow = GetTime()
	local tbAllMsgs = Ui.tbNotifyMsgDatas;
	for i = #tbAllMsgs, 1, -1 do
		local tbMsg = tbAllMsgs[i]
		if tbMsg.nTimeOut <= nTimeNow then
			table.remove(tbAllMsgs, i)
		else
			local fn = tbCheckRemoveShowWhenOpen[tbMsg.szType]
			if fn and not fn(tbMsg) then
				table.remove(tbAllMsgs, i)
			end
		end
	end
end

function tbUi:OnOpen()
	Ui.nUnReadNotifyMsgNum  = 0;
	Ui:RemoveTimeOutMsg()
	local tbAllMsgs = Ui.tbNotifyMsgDatas;

	if #tbAllMsgs == 0 then
		UiNotify.OnNotify(UiNotify.emNOTIFY_NOTIFY_PROCESS_MSG);
		return 0;
	end

	local fnSetData = function (itemClass, index)
		itemClass:SetData(tbAllMsgs[index]);
	end
	self.ScrollView:Update(tbAllMsgs, fnSetData)

end

function tbUi:OnClose()
	UiNotify.OnNotify(UiNotify.emNOTIFY_NOTIFY_PROCESS_MSG);
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:btnClose()
	Ui:CloseWindow(self.UI_NAME)
end



function tbUi.tbOnClick:btnClearall()
	local tbAllMsgs = Ui.tbNotifyMsgDatas;
	for i=1,#tbAllMsgs do
		table.remove(tbAllMsgs)
	end
	Ui:CloseWindow(self.UI_NAME)
end


--挂到UI上，防止未载NotifyMsgList ui时
function Ui:SynNotifyMsg(tbData)
	local szType = tbData.szType
	local Key = tbUniqueNotifyMsg[szType]
	if Key then
		for i, v in ipairs(self.tbNotifyMsgDatas) do
			if v.szType == szType and v[Key] ==  tbData[Key] then
				self.tbNotifyMsgDatas[i] = tbData
				return
			end
		end
	end
	table.insert(self.tbNotifyMsgDatas, 1, tbData)
	Ui:RemoveTimeOutMsg()

	self.nUnReadNotifyMsgNum = self.nUnReadNotifyMsgNum + 1;
	UiNotify.OnNotify(UiNotify.emNOTIFY_NOTIFY_PROCESS_MSG);
end

function Ui:RemoveNotifyMsg(szKey)
	local tbAllMsgs = Ui.tbNotifyMsgDatas;
	for i = #tbAllMsgs, 1, -1 do
		local tbMsg = tbAllMsgs[i]
		if tbMsg.szType == szKey then
			table.remove(tbAllMsgs, i)
		end
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_NOTIFY_PROCESS_MSG);
end

function Ui:GetNotifyMsgIcon()
	local szSprite = "New_02"
	local nPriority = nil
	local tbMsgKeyMap = {}

	for _,tbMsg in pairs(Ui.tbNotifyMsgDatas) do
		tbMsgKeyMap[tbMsg.szType] = true
	end

	for szType, tbIconInfo in pairs(tbIconPriority) do
		if tbMsgKeyMap[szType] and (not nPriority or nPriority < tbIconInfo.nPriority) then
			szSprite = tbIconInfo.szSprite
			nPriority = tbIconInfo.nPriority
		end
	end

	return szSprite
end

