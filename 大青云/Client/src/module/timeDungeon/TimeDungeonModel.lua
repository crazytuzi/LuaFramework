--[[
	2015年1月29日, AM 11:45:13
	wangyanwei
]]

_G.TimeDungeonModel = Module:new();

--进入副本
TimeDungeonModel.monsterConstsID = 10250000;   ---写死一段怪物ID  随等级+1 到 +150
TimeDungeonModel.bossConstsID = 10260000;   ---写死一段怪物BOSSID  随等级+1 到 +150

TimeDungeonModel.dungeonState = nil; --进入的难度
TimeDungeonModel.dungeonLevel = nil; --进入时记录人物等级，结算奖励时找进入时等级的奖励
function TimeDungeonModel:OnBackEnterDungeon(msg)
	if msg.result == -1 then
		FloatManager:AddNormal( StrConfig["timeDungeon049"] );
		return
	end
	if msg.result == -2 then
		FloatManager:AddNormal( StrConfig["timeDungeon050"] );
		return
	end
	if msg.result == -3 then
		FloatManager:AddNormal( StrConfig["timeDungeon051"] );
		return
	end
	if msg.result == -4 then
		FloatManager:AddNormal( StrConfig["timeDungeon052"] );
		return
	end
	if msg.result == -5 then
		FloatManager:AddNormal( StrConfig["timeDungeon053"] );
		return
	end
	if msg.result == -6 then
		FloatManager:AddNormal( StrConfig["timeDungeon054"] );
		return
	end
	if msg.result == -7 then
		FloatManager:AddNormal( StrConfig["timeDungeon055"] );
		return
	end
	if msg.result == -8 then
		FloatManager:AddNormal( StrConfig["timeDungeon056"] );
		return 
	end
	if msg.result ~= 1 then
		--FloatManager:AddNormal( StrConfig["timeDungeon057"] );
		return 
	end
	if UIDungeon:IsShow() then UIDungeon:Hide() end
	self.dungeonState = msg.state;
	UITimerDungeon:Hide();
	UIDungeonMain:Hide();
	UITimerDungeonInfo:Show();
	-- 打开使用经验丹
	if DungeonUtils:TestIsHaveExpBuff( ) == false and BagModel:GetItemNumInBag(BuffConsts.Type_Exp_One_Id) > 0 then
		-- UIExpBuffUseView:Show()    --暂时屏蔽组队升级副本 弹出1.5倍经验丹
	end
	UIDungeonNpcChat:Open(2000001);
	--记录进入时人物的等级
	self.dungeonLevel = MainPlayerModel.humanDetailInfo.eaLevel;
end

--得到挑战次数
TimeDungeonModel.enterNum = 0;
function TimeDungeonModel:OnSetEnterNum(num)
	self.enterNum = num;
	self:sendNotification(NotifyConsts.TimerDungeonEnterNum);

	if FuncManager:GetFuncIsOpen(FuncConsts.teamExper) then
		self:UpdateToQuest();
	end
end

--get剩余次数
function TimeDungeonModel:GetEnterNum()
	return self.enterNum;
end

-- get总次数
function TimeDungeonModel:GetTotalEnterNum( )
	local cfg = t_consts[85]
	if not cfg then return 0 end
	return cfg.param and cfg.param
end

function TimeDungeonModel:UpdateToQuest()
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_Team_EXP_Dungeon, 0 );
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;
	local enterNum = TimeDungeonModel:GetEnterNum(); --今日剩余次数
	if QuestModel:GetQuest(questId) then
		--次数不够不显示 yanghongbin/jianghaoran 2-16-8-22
		if enterNum <= 0 then
			QuestModel:Remove(questId);
		else
			QuestModel:UpdateQuest( questId, 0, state, goals )
		end
	else
		if enterNum <= 0 then
			return;
		end
		QuestModel:AddQuest( questId, 0, state, goals )
	end
end

--爬塔副本
TimeDungeonModel.paTAaEnterNum = 1;
function TimeDungeonModel:OnSetPataEnterNum(num)
	self.paTAaEnterNum = num;
	self:sendNotification(NotifyConsts.TimerDungeonEnterNum);
end

--get剩余次数
function TimeDungeonModel:GetPataEnterNum()
	return self.paTAaEnterNum;
end


--返回退出副本
function TimeDungeonModel:OnBackQuitDungeon(result)
	if result == 0 then
		return;
	end
	UITimerDungeonInfo:Hide();
	UITimeDungeonResult:Hide();
	MainMenuController:UnhideRight();
	MainMenuController:UnhideRightTop();
	UITimeTopSec:Hide();
	self.monsterDieNum = 0;
	self.expNum = 0;
	
	self.dungeonLevel = nil;
end

--返回副本信息
TimeDungeonModel.expNum = nil;
TimeDungeonModel.monsterDieNum = nil;
function TimeDungeonModel:OnBackDungeonInfo(msg)
	self.expNum = msg.exp;
	self.monsterDieNum = msg.num;
	self:sendNotification(NotifyConsts.TimerDungeonMonsterChange);
end

--返回倒计时
TimeDungeonModel.timeNum = nil;
function TimeDungeonModel:OnBackTimeNum(num)
	self.timeNum = num;
	-- UITimeTopSec:Open(0);
	local func = function ()
		if self.timeNum == 0 then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
			self:sendNotification(NotifyConsts.TimerDungeonTimeNum);
			return;
		end
		-- if self.timeNum <= 900 then  --小于15分钟
			self:sendNotification(NotifyConsts.TimerDungeonTimeNum);
		-- end
		if self.timeNum == 10 then
			-- UITimeTopSec:Open(1);   --屏蔽组队经验副本倒计时显示
		end
		self.timeNum = self.timeNum - 1;
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
end

function TimeDungeonModel:OnClearTimeKey()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

--返回波数
TimeDungeonModel.monsterWave = nil;
TimeDungeonModel.monsterID = nil;
TimeDungeonModel.monsterNum = nil;
function TimeDungeonModel:OnBackNum(cfg)
	self.monsterWave = cfg.num;
	self.monsterID = cfg.monID;
	self.monsterNum = cfg.monNum;
	self:sendNotification(NotifyConsts.TimerDungeonWaveChange);
end

--得到波数
function TimeDungeonModel:GetMonsterWave()
	return self.monsterWave;
end

--得到杀怪个数
function TimeDungeonModel:GetMonsterNumHandler()
	return self.monsterDieNum;
end

--得到经验总量
function TimeDungeonModel:GetDungeonExpHandler()
	return self.expNum;
end

--返回通关结果
TimeDungeonModel.resultInfo = {};
function TimeDungeonModel:OnBackDungeonResult(msg)
	for i , v in pairs(msg) do
		self.resultInfo[i] = v;
	end
	UITimeDungeonResult:Open(self.resultInfo);
	self.timeNum = 0;
	self:sendNotification(NotifyConsts.TimerDungeonTimeNum);
	self:OnClearTimeKey();
	UITimerDungeonInfo:Hide();
end

--等到身上对应物品的个数
function TimeDungeonModel:OnGetRoleItemNum()
	local cfg = {};
	for i , v in ipairs(t_monkeytime) do
		cfg[i] = BagModel:GetItemNumInBag(v.key_id);
	end
	return cfg;
end

--得到怪物id跟BOSSid   还有个数
function TimeDungeonModel:GetBossMonsterID()
	return self.monsterID;
end

--得到这波怪物个数
function TimeDungeonModel:GetMonsterNum()
	return self.monsterNum;
end

--是否开启定时副本
function TimeDungeonModel:GetIsOpenTimeDungeon()
	if MainPlayerModel.humanDetailInfo.eaLevel < t_monkeytime[1].level_limit then
		return false,-2; -- 进入等级不足
	end

	if self.enterNum <= 0 then
		return false,-3 -- 进入次数不足
	end
	
	return true
end



--////组队信息\\\\--

TimeDungeonModel.timeDungeonTeamList = {};          --灵光魔冢组队数据
TimeDungeonModel.pataDungeonTeamList = {};          --爬塔副本组队数据
TimeDungeonModel.makinoBattleDungeonTeamList = {};  --牧野之战副本组队数据

function TimeDungeonModel:SetAllTeamData(teamList,dungeonType)
	self.timeDungeonTeamList = {};
	self.pataDungeonTeamList = {};
	self.makinoBattleDungeonTeamList = {};
	if dungeonType == DungeonConsts.fubenType_pata then
		for i , v in ipairs(teamList) do
		local vo = {};
		vo.roomID = v.roomID;
		vo.dungeonIndex = v.dungeonIndex;
		vo.capName = v.capName;
		vo.att = v.att;
		vo.lock = v.lock;
		vo.roomNum = v.roomNum;
		table.push(self.pataDungeonTeamList,vo);
		end
		self.pataSelfTeamData = {};
	end
	if dungeonType == DungeonConsts.fubenType_lingguang then
		for i , v in ipairs(teamList) do
		local vo = {};
		vo.roomID = v.roomID;
		vo.dungeonIndex = v.dungeonIndex;
		vo.capName = v.capName;
		vo.att = v.att;
		vo.lock = v.lock;
		vo.roomNum = v.roomNum;
		table.push(self.timeDungeonTeamList,vo);
		end
		self.selfTeamData = {};
	end
	-- 牧野之战
	if dungeonType == DungeonConsts.fubenType_makinoBattle then
		for i , v in ipairs(teamList) do
		local vo = {};
		vo.roomID = v.roomID;
		vo.dungeonIndex = v.dungeonIndex;
		vo.capName = v.capName;
		vo.att = v.att;
		vo.lock = v.lock;
		vo.roomNum = v.roomNum;
		table.push(self.makinoBattleDungeonTeamList,vo);
		end
		self.MakinoBattleSelfTeamData = {};
	end
end

--获取灵光队伍cfg
function TimeDungeonModel:GetTeamData(teamID)
	local cfg = nil;
	for i , v in ipairs(self.timeDungeonTeamList) do
		if v.roomID == teamID then
			cfg = v;
			return cfg;
		end
	end
	return nil;
end

--获取爬塔队伍cfg
function TimeDungeonModel:GetPataTeamData(teamID)
	local cfg = nil;
	for i , v in ipairs(self.pataDungeonTeamList) do
		if v.roomID == teamID then
			cfg = v;
			return cfg;
		end
	end
	return nil;
end

--获取牧野之战队伍cfg
function TimeDungeonModel:GetMakinoBattleTeamData(teamID)
	local cfg = nil;
	for i , v in ipairs(self.makinoBattleDungeonTeamList) do
		if v.roomID == teamID then
			cfg = v;
			return cfg;
		end
	end
	return nil;
end

-------------------------------------灵光魔冢副本队伍数据-----------------------------------
--获取灵光副本全部队伍数据
function TimeDungeonModel:GetAllTeamData()
	return self.timeDungeonTeamList;
end

--退出队伍清除数据
function TimeDungeonModel:ClearMyTeamData()
	self.timeDungeonTeamList = nil;
end

--获取灵光副本可加入的队伍
function TimeDungeonModel:GetAllOpenTeam()
	local list = {};
	local cfg = self:GetAllTeamData();
	for i , v in ipairs(cfg) do
		if v.roomNum < 4 and v.lock == 1 and v.att <= MainPlayerModel.humanDetailInfo.eaFight then
			table.push(list,v);
		end
	end
	return list;
end


-------------------------------------爬塔副本队伍数据-----------------------------------
--获取爬塔副本全部队伍数据
function TimeDungeonModel:GetAllPataTeamData()
	return self.pataDungeonTeamList;
end

--退出队伍清除数据
function TimeDungeonModel:ClearPataTeamList(  )
	self.pataDungeonTeamList = nil;
end

--获取爬塔副本可加入的队伍
--@加入条件 队伍人数少于4，房间不加锁，玩家战斗力大于设置战斗力
function TimeDungeonModel:GetAllPataOpenTeam()
	local list = {};
	local cfg = self:GetAllPataTeamData();
	for i , v in ipairs(cfg) do
		if v.roomNum < 4 and v.lock == 1 and v.att <= MainPlayerModel.humanDetailInfo.eaFight then
			table.push(list,v);
		end
	end
	return list;
end

-------------------------------------牧野之战副本队伍数据-----------------------------------
--获取牧野之战副本全部队伍数据
function TimeDungeonModel:GetAllMakinoBattleTeamData()
	return self.makinoBattleDungeonTeamList;
end

--退出牧野之战队伍清除数据
function TimeDungeonModel:ClearMakinoBattleTeamList(  )
	self.makinoBattleDungeonTeamList = nil;
end

--获取牧野之战副本可加入的队伍
--@加入条件 队伍人数少于4，房间不加锁，玩家战斗力大于设置战斗力
function TimeDungeonModel:GetAllMakinoBattleOpenTeam()
	local list = {};
	local cfg = self:GetAllMakinoBattleTeamData();
	for i , v in ipairs(cfg) do
		if v.roomNum < 4 and v.lock == 1 and v.att <= MainPlayerModel.humanDetailInfo.eaFight then
			table.push(list,v);
		end
	end
	return list;
end

----------------------------------------------------------------------------------
TimeDungeonModel.selfTeamPlayerData = {};
TimeDungeonModel.selfTeamData = {};                  -- 玩家自身的队伍数据
TimeDungeonModel.pataSelfTeamData = {};              -- 爬塔副本玩家自身队伍数据
TimeDungeonModel.MakinoBattleSelfTeamData = {};      -- 牧野之战玩家自身队伍数据

function TimeDungeonModel:SetMyTeamData(dungeonType,dungeonIndex,lock,lockAttNum,autoStart)
	self.selfTeamData = {};
	self.pataSelfTeamData = {};
	self.MakinoBattleSelfTeamData = {};
	if dungeonType == DungeonConsts.fubenType_pata then
		self.pataSelfTeamData.dungeonType = dungeonType;
		self.pataSelfTeamData.dungeonIndex = dungeonIndex;
		self.pataSelfTeamData.lock = lock;
		self.pataSelfTeamData.lockAttNum = lockAttNum;
		self.pataSelfTeamData.autoStart = autoStart;
	end
	if dungeonType == DungeonConsts.fubenType_lingguang then
		self.selfTeamData.dungeonType = dungeonType;
		self.selfTeamData.dungeonIndex = dungeonIndex;
		self.selfTeamData.lock = lock;
		self.selfTeamData.lockAttNum = lockAttNum;
		self.selfTeamData.autoStart = autoStart;
	end
	-- 牧野之战
	if dungeonType == DungeonConsts.fubenType_makinoBattle then
		self.MakinoBattleSelfTeamData.dungeonType = dungeonType;
		self.MakinoBattleSelfTeamData.dungeonIndex = dungeonIndex;
		self.MakinoBattleSelfTeamData.lock = lock;
		self.MakinoBattleSelfTeamData.lockAttNum = lockAttNum;
		self.MakinoBattleSelfTeamData.autoStart = autoStart;
	end
end

--返回灵光魔冢玩家自身队伍信息
function TimeDungeonModel:GetSelfTeamData()
	return self.selfTeamData;
end

--返回爬塔玩家自身队伍信息
function TimeDungeonModel:GetPataSelfTeamData()
	return self.pataSelfTeamData;
end

--返回牧野之战玩家自身队伍信息
function TimeDungeonModel:GetMakinobattleTeamData()
	return self.MakinoBattleSelfTeamData;
end

--设置玩家组队数据
function TimeDungeonModel:SetMyTermPlayerData()

	self.selfTeamPlayerData = {};         --灵光副本组队数据
	self.selfPataTeamPlayerData = {};     --爬塔副本组队数据
	self.MakinoBattlePlayerTeamData = {}; --牧野之战副本组队数据
	local teamList = TeamModel:GetMemberList();
	
	local newTeamList1 = {};
	for _ , player in pairs (teamList) do
		if player:IsCaptain() then
			table.push(newTeamList1,player)
		end
	end
	
	local newTeamList2 = {};
	for _ , player in pairs (teamList) do
		if not player:IsCaptain() then
			table.push(newTeamList2,player)
		end
	end
	table.sort(newTeamList2,function (A,B)
		return A.index < B.index;
	end)
	for i , v in ipairs(newTeamList2) do
		table.push(newTeamList1,v);
	end
	for i , v in ipairs(newTeamList1) do
		local vo = {};
		vo.index = v.index;
		vo.memName = v.roleName;
		vo.roomType = v.roomType == 0;
		vo.level = v.level;
		vo.attLimit = v.fight;
		vo.headID = v.iconID;
		vo.cap = v.teamPos == 1;
		vo.line = v.line;
		vo.roleID = v.roleID;
		table.push(self.selfTeamPlayerData,vo);
		table.push(self.selfPataTeamPlayerData,vo);
		table.push(self.MakinoBattlePlayerTeamData,vo);
	end
end

--灵光副本获取玩家自己的组队配置数据
function TimeDungeonModel:GetSelfTeamPlayerData()
	self:SetMyTermPlayerData();
	return self.selfTeamPlayerData;
end

--爬塔副本获取玩家自己的组队配置数据
function TimeDungeonModel:GetPataSelfTeamPlayerData()
	self:SetMyTermPlayerData();
	return self.selfPataTeamPlayerData;
end

--牧野之战副本获取玩家自己的组队配置数据
function TimeDungeonModel:GetMakinoSelfTeamPlayerData()
	self:SetMyTermPlayerData();
	return self.MakinoBattlePlayerTeamData;
end


--获取自己在队伍中的准备状态
function TimeDungeonModel:GetInTeamState()
	--//得到主玩家在队伍的信息
	local teamCfg = TeamModel:GetMemberById(MainPlayerController:GetRoleID());
	if not teamCfg then return false end
	return teamCfg.roomType == 0;
end

--获取当前有的最高难度
function TimeDungeonModel:GetMaxTimeDungeon()
	local maxIndex = nil;
	for i = 1, 5 do
		local cfg = t_monkeytime[i];
		if cfg then
			local id = cfg.key_id;
			local itemCfg = t_item[id];
			if itemCfg then
				local itemNum = BagModel:GetItemNumInBag(itemCfg.id);
				if itemNum > 0 then
					maxIndex = i;
				end
			end
		end
	end
	return maxIndex;
end