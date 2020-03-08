FactionBattle.FactionMonkey = FactionBattle.FactionMonkey or {}

-- 大师兄相关

FactionBattle.MONKEY_VOTE_TIME = 24 		   			-- 活动开启后允许投票的小时
FactionBattle.MONKEY_SESSION_LIMIT_COUNT = 3 	   		-- 举行超过几届门派竞技开始
FactionBattle.MONKEY_START_DAY = 1 						-- 活动每月几号开启
FactionBattle.MONKEY_END_DAY = 2 						-- 活动每月几号结束

FactionBattle.tbHonorVoteScore = 						-- 每票 头衔得分
{
	[0] = 1,
	[1] = 1,
	[2] = 2,
	[3] = 4,
	[4] = 8,
	[5] = 16,
	[6] = 32,
	[7] = 64,
	[8] = 128,
	[9] = 256,
	[10] = 256,
	[11] = 256,	
	[12] = 512,
	[13] = 512,
	[14] = 512,
	[15] = 1024,
	[16] = 1024,
	[17] = 1024,
	[18] = 1024,
	[19] = 1024,
	[20] = 2048,
	[21] = 4096,
}

FactionBattle.tbFactionMonkeyReward = {{"Item", 3358, 1}}

FactionBattle.MAX_VOTE 	 = 1 							-- 最大投票次数

FactionBattle.MONKEY_TITLE_ID = 						-- 大师兄称号ID
{
	[1] = {311, 380},
	[2] = {314, 314},
	[3] = {313, 313},
	[4] = {312, 386},
	[5] = {315, 367},
	[6] = {398, 316},
	[7] = {317, 317},
	[8] = {318, 318},
	[9] = {319, 319},
	[10] = {373, 320},
	[11] = {322, 392},
	[12] = {324, 324},
	[13] = {326, 326},
	[14] = {328, 328},
	[15] = {330, 331},
	[16] = {365, 366},
	[17] = {371, 372},
	[18] = {378, 379},
	[19] = {384, 385},
	[20] = {390, 391},
	[21] = {396, 397},
}

FactionBattle.MONKEY_TITLE_TIMEOUT = 30 * 24 * 60 * 60 	-- 称号过期时间

FactionBattle.nNewInfomationValidTime = 7 * 24 * 60 * 60 	-- 最新消息过期时间（距离推送时间）

FactionBattle.tbMailSetting =
{
	[1] = {szTitle = "掌门的贺信",szText = "    做得很好！你已经历生死较量，又得军心所向！此后你还需勤加练习，将来必能成为名动一方的豪侠，只是切勿沾沾自喜，与同门相处也莫要盛气凌人，将无兵卒，又有何用？谨记。"},
	[2] = {szTitle = "掌门的贺信",szText = "    峨嵋派一向以相互扶助，救死扶伤为己任，如今你成为了峨嵋大师姐，更是应当凡事心怀善念，一切以大局为重。同门之中，你武功最高，自然不免多担待一些，要保护好同门。任重而道远，不可懈怠。"},
	[3] = {szTitle = "掌门的贺信",szText = "    我桃花创立不过数十载，却已有你这般优秀的人才，着实令人欣喜不已，今日你成为桃花的大师姐，武艺自然是冠绝同门，可要切记勿要藏私，多与同门姐妹交流，桃花盛放所依者，是诸位的一同努力。"},
	[4] = {szTitle = "掌门的贺信",szText = "    做得不错，此番较技，称得上是潇洒自如，而与诸位同门之间的情谊，也助你成就今日之名。既身为大师兄，自然是样样都要强于同门，此事虽不易，然既入我门下，理应如此，否则如何能逍遥自在？"},
	[5] = {szTitle = "掌门的贺信",szText = "    如今战火不断，天下纷乱，值此多事之秋，吾派能够有你如此杰出的弟子，实在令老道欣慰，将来这掌门之位，不免从你们这些年轻弟子中选中，还望你除了修行武功，更需修心养性，切不可过于自负。"},
	[6] = {szTitle = "掌门的贺信",szText = "    哼，有点意思，能从同门中脱颖而出，说明你天赋卓绝，已掌握我天忍之精髓，所欠缺的，不过是时间，待得技艺日渐成熟，将来天下之中，已无你不可暗杀之人，终有一日，你会成为天忍最锋锐的刃。"},
	[7] = {szTitle = "掌门的贺信",szText = "    阿弥陀佛，善哉善哉。如今你学艺有成，技冠同门，自是令人欣喜，然需谨防心魔，戒骄戒躁，不可放下佛法修行，不可心高气傲，同门之间，多加指导，相互印证，佛武并修，未来自当如虎添翼。"},
	[8] = {szTitle = "掌门的贺信",szText = "    卿之技艺，已日渐成熟，同门翘楚甚多，却独你一人青出于蓝而胜于蓝，行走江湖，四处历练之际，需多加小心，莫要轻易相信他人，男女皆然。还有，照顾好那只小家伙，它才是你最忠诚的同伴。"},
	[9] = {szTitle = "掌门的贺信",szText = "    哼，你既身为唐门子弟，理应为唐家堡名扬武林尽一份力，总算是你天资颇佳，不负我等期望，去吧，要记住，韬光养晦如此之久，而你，要成为青年名侠中的翘楚，方乃我唐门踏出武林的第一步。"},
	[10] = {szTitle = "掌门的贺信",szText = "   不错不错，我昆仑韬光养晦如此之久，近些年来总算是出了这般优秀的子弟，你长年累月在这极寒之地修炼，着实不易，而今能在众多同门中脱颖而出，绝非侥幸，还得多在江湖走动，日后必成大器。"},
	[11] = {szTitle = "掌门的贺信",szText = "   丐帮自创立以来，数百年来被称为天下第一大帮，靠的并非冠绝武林的功夫，除了武林同道给面子，最重要的便是帮众弟子相互扶持，你既是其中翘楚，更应谨守此道，戒骄戒躁，方能一方有难，八方支援。"},
	[12] = {szTitle = "掌门的贺信",szText = "   哼，我等偏居一隅，却叫中原武林小瞧，道什么五毒教，如此也好，如今你学艺有成，是教中年轻一辈掌控五圣蛊最娴熟者，也是时候还以颜色，让那些中原蛮子知道我教中五圣的厉害！去吧，记住，一切小心！"},
	[13] = {szTitle = "掌门的贺信",szText = "   我藏剑山庄始于唐而兴于唐，如今经历卓非凡之祸，武林对于藏剑颇有微辞，然此并非武学衰败，亦非我藏剑无人，如今你身负重振藏剑之名的重任，还望你此后仗剑江湖，能够处处留心，让江湖众人都知道，我藏剑山庄，剑心依旧。"},
	[14] = {szTitle = "掌门的贺信",szText = "   长歌始于唐，原本乃风雅之地，承蒙各路文人异客集思广益，悟得独到武学，以此创立长歌，如今你已是门中第一人，还望你莫忘初心，习武之余，切不可放下一门技艺，此乃长歌区别于他派之根本。"},
	[15] = {szTitle = "掌门的贺信",szText = "   本派的武功融会各家之长，精深博大，只因僻处西陲，名头才不如他派响亮，如今你是同门中武功最高之人，还望你多加修炼，为扬名本派做好坚实的基础。"},
	[16] = {szTitle = "掌门的贺信",szText = "   哈哈哈，我霸刀山庄能有你如此出色的弟子，实在是我庄的福气，我们埋名养晦那么多年，重振庄名就要依靠你们这些年轻弟子了。"},
	[17] = {szTitle = "掌门的贺信",szText = "   如今战火不断，天下纷乱，值此多事之秋，吾派能够有你如此杰出的弟子，实在令老道欣慰，将来这掌门之位，不免从你们这些年轻弟子中选中，还望你除了修行武功，更需修心养性，切不可过于自负。"},
	[18] = {szTitle = "掌门的贺信",szText = "   如今战火不断，天下纷乱，值此多事之秋，吾派能够有你如此杰出的弟子，实在令我欣慰，将来这掌门之位，不免从你们这些年轻弟子中选中，还望你除了修行武功，更需修心养性，切不可过于自负。"},
	[19] = {szTitle = "掌门的贺信",szText = "   如今战火不断，天下纷乱，值此多事之秋，吾派能够有你如此杰出的弟子，实在令我欣慰，将来这掌门之位，不免从你们这些年轻弟子中选中，还望你除了修行武功，更需修心养性，切不可过于自负。"},
	[20] = {szTitle = "掌门的贺信",szText = "   如今战火不断，天下纷乱，值此多事之秋，万花谷能够有你如此杰出的弟子，实在令我欣慰，将来这谷主之位，不免从你们这些年轻弟子中选中，还望你除了修行武功，更需修心养性，切不可过于自负。"},
	[21] = {szTitle = "掌门的贺信",szText = "   如今战火不断，天下纷乱，值此多事之秋，杨门能够有你如此杰出的弟子，实在令我欣慰，将来这将领之位，不免从你们这些年轻弟子中选中，还望你除了修行武功，更需修心养性，切不可过于自负。"},
}

--门派大师兄聊天前缀
FactionBattle.MonkeyNamePrefix =
{
	[1] = {"#964","#857"},
	[2] = {"#963","#963"},
	[3] = {"#961","#961"},
	[4] = {"#962","#854"},
	[5] = {"#960","#929"},
	[6] = {"#815","#959"},
	[7] = {"#957","#957"},
	[8] = {"#958","#958"},
	[9] = {"#950","#950"},
	[10]= {"#860","#951"},
	[11]= {"#946","#816"}, 
	[12]= {"#947","#947"}, 
	[13]= {"#938","#938"}, 
	[14]= {"#939","#939"}, 
	[15]= {"#934","#933"}, 
	[16]= {"#930","#931"}, 
	[17]= {"#862","#861"}, 
	[18]= {"#855","#856"}, 
	[19]= {"#852","#853"}, 
	[20]= {"#818","#817"}, 
	[21]= {"#813","#814"}, 
}

FactionBattle.SAVE_GROUP_MONKEY  = 96
FactionBattle.KEY_VOTE			 = 1
FactionBattle.KEY_STARTTIME		 = 2

function FactionBattle:CheckCommondVote(pPlayer)
	-- 检查投票次数
	if self:RemainVote(pPlayer) <= 0 then
		return false,"您已经没有投票次数"
	end

	return true
end

function FactionBattle:RemainVote(pPlayer)
	return pPlayer.GetUserValue(FactionBattle.SAVE_GROUP_MONKEY, FactionBattle.KEY_VOTE);
end

function FactionBattle:GetMonkeyNamePrefix(nFaction, nSex)
	local szPrefix = FactionBattle.MonkeyNamePrefix[nFaction] and FactionBattle.MonkeyNamePrefix[nFaction][nSex]
	return szPrefix or ""
end

--活动时间不能跨天
function FactionBattle:IsMonthBattleOpen()
	if not MODULE_ZONESERVER then
		if GetTimeFrameState(self.CROSS_MONTHLY_FRAME) ~= 1 then
			return false
		end
	end
	if Activity:__IsActInProcessByType(WuLinDaHui.szActNameMain) then
		return false
	end
	--每月第一周的周一
	return Lib:IsMonthlyFirstWeekday(1)
end

--活动时间不能跨天
function FactionBattle:IsSeasonBattleOpen()
	if not MODULE_ZONESERVER then
		if GetTimeFrameState(self.CROSS_MONTHLY_FRAME) ~= 1 then
			return false
		end
	end
	if Activity:__IsActInProcessByType(WuLinDaHui.szActNameMain) then
		return false
	end

	local tbTime = Lib:LocalDate("*t", GetTime());

	--每季度的最后一个月
	if tbTime.month ~= 3 and tbTime.month ~= 6 and tbTime.month ~= 9 and tbTime.month ~= 12 then
		return false
	end

	--每月最后一周的周一
	return Lib:IsMonthlyLastWeekday(1)
end

function FactionBattle:GetNameFromCrossType(nCrossType)
	local tbNames = {
		[self.CROSS_TYPE.MONTH] = "月度赛",
		[self.CROSS_TYPE.SEASON] = "季度赛"
	}
	return tbNames[nCrossType] or "-"
end

function FactionBattle:GetCrossTypeName()
	if self:IsMonthBattleOpen() then
		return "月度赛", self.CROSS_TYPE.MONTH
	end

	if self:IsSeasonBattleOpen() then
		return "季度赛", self.CROSS_TYPE.SEASON
	end

	return ""
end

function FactionBattle:GetNextMonthlyBattleTime()
	local bTimeFrameOpen = (GetTimeFrameState(self.CROSS_MONTHLY_FRAME) == 1)
	local nTime = (bTimeFrameOpen and GetTime()) or CalcTimeFrameOpenTime(self.CROSS_MONTHLY_FRAME)
	local tbTime = Lib:LocalDate("*t", nTime);

	if not Lib:IsMonthlyFirstWeekday(1, nTime) or Lib:GetLocalDayTime() > Lib:ParseTodayTime("21:00") then

		nTime = os.time(tbTime);
		local nTmpTime = Lib:GetTimeByWeekInMonth(nTime, 1, 1, 21, 0, 0);

		if nTime > nTmpTime then
			tbTime.month = tbTime.month + 1;
			if tbTime.month > 12 then
				tbTime.month = 1;
				tbTime.year = tbTime.year + 1;
			end
			nTime = os.time(tbTime);
		else
			return nTmpTime;
		end
	else
		nTime = os.time({year = tbTime.year, month = tbTime.month, day = tbTime.day, hour = 21, min = 0, sec = 0})
	end
	return Lib:GetTimeByWeekInMonth(nTime, 1, 1, 21, 0, 0);
end

function FactionBattle:GetNextSeasonBattleTime()
	local bTimeFrameOpen = (GetTimeFrameState(self.CROSS_MONTHLY_FRAME) == 1)
	local nTime = (bTimeFrameOpen and GetTime()) or CalcTimeFrameOpenTime(self.CROSS_MONTHLY_FRAME)
	local tbTime = Lib:LocalDate("*t", nTime);
	local nOpenMonth = math.ceil(tbTime.month / 3) * 3;

	if nOpenMonth ~= tbTime.month then
		tbTime.month = nOpenMonth;
		tbTime.day = 1;
		tbTime.hour = 0;
		tbTime.min = 0;
	end

	local nNextTime = os.time(tbTime);
	local nOpenTime = Lib:GetTimeByWeekInMonth(nNextTime, -1, 1, 21, 0, 0);
	if nOpenTime < nTime then
		tbTime.month = nOpenMonth + 3;
		if tbTime.month > 12 then
			tbTime.year = tbTime.year + 1;
			tbTime.month = 3;
		end
	end

	nNextTime = os.time(tbTime);
	return Lib:GetTimeByWeekInMonth(nNextTime, -1, 1, 21, 0, 0);
end
