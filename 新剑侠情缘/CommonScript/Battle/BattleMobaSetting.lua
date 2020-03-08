Battle.tbCampSetting = {};
local tbCampSetting = Battle.tbCampSetting
local tbBatttleSetting = Battle.tbAllBattleSetting.BattleMoba

tbCampSetting.RandWildNpcSetting = {
	--NpcId, TitleId, buffid ,等级，持续帧数
	{{2436, 2502, 2504}, 206, 3760, 1, 3*15};  --持续回血
	{{2435, 2501, 2503}, 205, 3761, 1, 60*15};  --攻击加成
}


tbCampSetting.tbBossNpcTeamplate = {2448, 2495,2496}; --BOSS 的npc Id


tbCampSetting.tbInitFuncs = {
-- 		--建筑npc			  nNpcId, Team, BuildLevel(1-3 从低到高)，x.y,dir， szMaoLabelIndex(对应小地图文字index)
	{"AddBuildNpc", {2440, 2486, 2488},   1, 		1, 					9127,8443,  16, "WaiTa1", "外\n塔", "son_waita" };		
	{"AddBuildNpc", {2440, 2486, 2488},   1, 		2, 					7718,8441,  16, "NeiTa1", "内\n塔", "son_neita" };		
	{"AddBuildNpc", {2443, 2490, 2492},   1, 		3, 					6080,8435,  0,  "DaYin1", "大\n营", "son_daying"};		
	{"AddBuildNpc", {2442, 2487, 2489},   2, 		1, 					13401,8436, 45, "WaiTa2", "外\n塔", "jin_waita" };		
	{"AddBuildNpc", {2442, 2487, 2489},   2, 		2, 					14821,8433, 45, "NeiTa2", "内\n塔", "jin_neita" };		
	{"AddBuildNpc", {2444, 2491, 2493},   2, 		3, 					16474,8439, 0,  "DaYin2", "大\n营", "jin_daying"};		
};

tbCampSetting.tbNpcCreateWith = { --创建时会同时创建的npc, 死亡时会同时死亡
	[2440] = 2439;  --宋军炮塔-强度1
	[2442] = 2441;  --金军炮塔-强度1

	[2486] = 2439;  --宋军炮塔-强度2
	[2487] = 2441;  --金军炮塔-强度2
	
	[2488] = 2439;  --宋军炮塔-强度3
	[2489] = 2441;  --金军炮塔-强度3
};

tbCampSetting.tbCampActivesSaw = {
	--刷兵
	--开始时间，执行间隔（0就只执行一次），函数，NpcId,  nTeam， x  ,   y,  nDir, nMovePath
	--宋兵
	{10,  		45,        "AddCampNpcMovePath", {2431, 2478, 2482},       1,    6403,8443, 16 , 1   };
	{11,  		45,        "AddCampNpcMovePath", {2431, 2478, 2482},       1,    6403,8443, 16 , 1   };
	{12,  		45,        "AddCampNpcMovePath", {2431, 2478, 2482},       1,    6403,8443, 16 , 1   };
	{13,  		45,        "AddCampNpcMovePath", {2432, 2479, 2483},       1,    6403,8443, 16 , 1   };

	--金兵
	{10,  		45,        "AddCampNpcMovePath", {2433, 2480, 2484},       2,    16194,8440, 16 , 2   };
	{11,  		45,        "AddCampNpcMovePath", {2433, 2480, 2484},       2,    16194,8440, 16 , 2   };
	{12,  		45,        "AddCampNpcMovePath", {2433, 2480, 2484},       2,    16194,8440, 16 , 2   };
	{13,  		45,        "AddCampNpcMovePath", {2434, 2481, 2485},       2,    16194,8440, 16 , 2   };

	--刷野怪      		  nRebornTime, x , y, nDir
	{ 60, 0, "AddRandWildNpc", 60, 12384,10468, 38 };
	{ 60, 0, "AddRandWildNpc", 60, 10249,10387, 25 };
	{ 60, 0, "AddRandWildNpc", 60, 9827,6520,   13 };
	{ 60, 0, "AddRandWildNpc", 60, 9929,5319,   13 };
	{ 60, 0, "AddRandWildNpc", 60, 12692,5643,  48 };
	{ 60, 0, "AddRandWildNpc", 60, 12809,6920,  48 };

	--刷boss
	{ 180, 0, "AddBossNpc", 11324,5572, 30 };		

	--刷buff                 ,x  , y ,buff参数 
	{ 90,90, "AddRandBuff", 10398,7096, "3001|25;3002|25;3003|25;3004|25;1" };
	{ 90,90, "AddRandBuff", 11281,9337, "3001|25;3002|25;3003|25;3004|25;1" };
	{ 90,90, "AddRandBuff", 12054,7021, "3001|25;3002|25;3003|25;3004|25;1" };
	{ 90,90, "AddRandBuff", 11362,4678, "3001|25;3002|25;3003|25;3004|25;1" };
}

--建筑物一开始的无敌buff
tbCampSetting.tbBuffBuilding = {
	3766, 1, 15*60*12
};

tbCampSetting.nRevieTime = 15 ; --玩家死亡复活时间, 秒为单位

tbCampSetting.szBuildNpcAiFile = "Setting/Npc/Ai/battle/MobaTower.ini"
tbCampSetting.szBossHelpAiFile = "Setting/Npc/Ai/battle/moba_xiongwang_tuita.ini"
tbCampSetting.tbBuidLowAttackBuff = {3767, 1, 15}; --玩家打建筑物伤害降低时 给塔加上的buff

tbCampSetting.nBuildDamagePFlagBuffId = 1717; --建筑物的塔下无小兵时受玩家伤害降低的buffid，一直存在
tbCampSetting.nPlayerDamagePFlagBuffId = 3754; --塔下无小兵时受玩家伤害降低的buffid，1s检测，无小兵时给玩家加上，1s持续时间
tbCampSetting.nBuildDamagePFlagRanage = 800; --塔的800范围内有玩家没小兵就降低伤害


tbCampSetting.nBossDmgNotChangeInterval = 10; --10秒没有对boss的输出 就减输出
tbCampSetting.nBossLastDmgPercent = 0.15; --最后一击伤害加成
tbCampSetting.nBossReBorntTime = 3*60;--boss 的重生时间，从捕获后开始算
tbCampSetting.tbBossReBorntNotifyTime = { 20, 10 };--boss 的重生前多少秒会公告提示
tbCampSetting.nBossHelpTime = 150;  --boss 协助的时间，结束后被删除
tbCampSetting.tbBossHelpMovePath = { --boss 协助走的路线
	{ 6403,8443,16, 1 }; --宋 x,y,ndir. movePath
	{ 16194,8440,45 , 2 }; --金
}

tbCampSetting.tbFightPowerNpcLevel = {
	-- 大于等于该玩家平均等级，对应npc的等级， 不同的战力等级范围对应不同的npcid，
	{nPlyerLevel = 0,       tbFigPowerLevel = { 0, 1200000, 1500000  };}; 
	{nPlyerLevel = 90,      tbFigPowerLevel = { 0, 1600000, 2000000  };}; 
	{nPlyerLevel = 100,     tbFigPowerLevel = { 0, 2700000, 3500000  };}; 
	{nPlyerLevel = 110,     tbFigPowerLevel = { 0, 3300000, 4500000  };}; 
	{nPlyerLevel = 120,     tbFigPowerLevel = { 0, 4000000, 5000000  };}; 
};



local fnCheck = function ()
	assert(tbCampSetting.tbFightPowerNpcLevel[1].nPlyerLevel == 0)
	local LastV;
	local nFPLevels = 3
	for i,v in ipairs(tbCampSetting.tbFightPowerNpcLevel) do
		if LastV then
			assert(v.nPlyerLevel >= LastV.nPlyerLevel, i)
		end
		assert(#v.tbFigPowerLevel == nFPLevels, i)
		assert(v.tbFigPowerLevel[1] <= v.tbFigPowerLevel[2])
		assert(v.tbFigPowerLevel[2] <= v.tbFigPowerLevel[3])
		LastV = v;
	end


	local tbBuildNpc = {} --确认是各有三个的
	for i,v in ipairs(tbCampSetting.tbInitFuncs) do
		if v[1] == "AddBuildNpc" then
			tbBuildNpc[v[3]] = tbBuildNpc[v[3]] or {}
			tbBuildNpc[v[3]][ v[4] ] = 1
			assert(#v[2]  == nFPLevels,  i)
		end 
	end
	assert(#tbBuildNpc[1] == 3)
	assert(#tbBuildNpc[2] == 3)
	
	local tbCampActives = {};
	
	local tbSche = Battle.STATE_TRANS[tbBatttleSetting.nUseSchedule]
	local nTotalFightTime = tbSche[2].nSeconds

	for i,v in ipairs(tbCampSetting.tbCampActivesSaw) do
		local nTime1, nTime2 = v[1], v[2];
		-- tbCampActives[nTime1] = tbCampActives[nTime1] or {};
		local tbRepeat = {nTime1};
		if nTime2 ~= 0 then
			local nRepeatTime = math.floor((nTotalFightTime - nTime1) / nTime2) 
			if nRepeatTime > 0 then
				for i2=1,nRepeatTime do
					table.insert(tbRepeat, nTime1 + i2 * nTime2)
				end
			end
		end

		for _,v2 in ipairs(tbRepeat) do
			tbCampActives[v2] = tbCampActives[v2] or {};
			table.insert(tbCampActives[v2], { unpack(v, 3) })
		end

		if v[3] == "AddBossNpc" then
			tbCampSetting.nBossBornTime = nTime1;		
		end
	end
	tbCampSetting.tbCampActives = tbCampActives;
	
end

tbCampSetting.nTotalFightTime = Battle.STATE_TRANS[tbBatttleSetting.nUseSchedule][2].nSeconds;

if MODULE_GAMESERVER then
	fnCheck();
end

