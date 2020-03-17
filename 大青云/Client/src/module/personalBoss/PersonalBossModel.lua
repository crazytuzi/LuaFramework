--[[
	2015年10月31日16:28:25
	wangyanwei
	个人BOSSmodel
]]

_G.PersonalBossModel = Module:new();

PersonalBossModel.personalList = nil;
--地宫boss
PersonalBossModel.PalaceBossList = {}
function PersonalBossModel:PersonalBossUpDate(list)
	self.personalList = {};
	if #list < 1 then
		self:InitPersonalList();
	else
		self:SetPersonalBossDate(list);
	end
end

--没有任何数据 进行初始化
function PersonalBossModel:InitPersonalList()
	local list = {};
	 
	for index , PersonalBossVO in ipairs(t_personalboss) do
		local vo = {};
		vo.index 	= index;
		vo.id 		= PersonalBossVO.id;				--配表ID
		vo.num 		= PersonalBossVO.freeTime;			--今日剩余进入次数
		vo.level 	= PersonalBossVO.playerLevel;		--等级限制
		vo.bossId 	= PersonalBossVO.bossId;			--怪物ID
		vo.isfirst 	= true;								--是否存在首通状态  true  存在
		table.push(list,vo);
	end
	
	self.personalList = list;
end

function PersonalBossModel:SetPersonalBossDate(list)
	local Personallist = {};
	for index , PersonalBossVO in ipairs(t_personalboss) do
		local vo = nil;
		for _ , PersonalBossItem in pairs(list) do
			if PersonalBossVO.id == PersonalBossItem.id then
				vo = {};
				vo.index 	= index;
				vo.id 		= PersonalBossItem.id;
				vo.num 		= PersonalBossVO.freeTime - PersonalBossItem.num;
				vo.level 	= PersonalBossVO.playerLevel;
				vo.bossId 	= PersonalBossVO.bossId;
				vo.isfirst 	= PersonalBossItem.isfirst ~= 0;	--是否存在首通状态  true  存在
			end
		end
		if not vo then
			vo = {};
			vo.index = index;
			vo.id 		= PersonalBossVO.id;				--配表ID
			vo.num 		= PersonalBossVO.freeTime;			--今日剩余进入次数
			vo.level 	= PersonalBossVO.playerLevel;		--等级限制
			vo.bossId 	= PersonalBossVO.bossId;			--怪物ID
			vo.isfirst 	= true;
		end
		table.push(Personallist,vo);
	end
	
	self.personalList = Personallist;
end

--进入成功后扣除相应ID的剩余进入次数
function PersonalBossModel:removePersonalBossNum(id,num)
	if not self.personalList then self:InitPersonalList(); end
	
	for index , personalVO in ipairs(self.personalList)do
		if personalVO.id == id then
			local cfg = t_personalboss[id];
			if not cfg then return end
			
			personalVO.num = cfg.freeTime - num;
			-- break
		end
	end
end

--首通后改变首通状态
function PersonalBossModel:SetFirstState(id)
	if not self.personalList then self:InitPersonalList(); end
	for index , personalVO in ipairs(self.personalList)do
		if personalVO.id == id then
			personalVO.isfirst = false;
			break
		end
	end
end

function PersonalBossModel:EndTimeNum()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

--进入后开始计时
PersonalBossModel.startPersonalBossID = nil;
function PersonalBossModel:SetBossID(id)
	self.startPersonalBossID = id;
end

function PersonalBossModel:StartTime()
	local cfg = t_consts[136];
	if not cfg then return end
	local secNum = cfg.val2 * 60;
	if secNum == 0 then secNum = 120 end
	
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	local func = function ()
		secNum = secNum - 1;
		if secNum < 0 then secNum = 0 end
		Notifier:sendNotification(NotifyConsts.PersonalBossTime,{timeNum = secNum});
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
end

--获取现在进行的个人BOSS副本ID
function PersonalBossModel:OnGetPersonalBossID()
	return self.startPersonalBossID;
end

--获取个人BOSS数据
function PersonalBossModel:GetPersonalBossDate()
	if not self.personalList then self:InitPersonalList(); end
	return self.personalList
end

--根据ID获取个人BOSSdata
function PersonalBossModel:GetIDPersonalBossDate(id)
	local list = self:GetPersonalBossDate();
	
	for index , personalVO in ipairs(list)do
		if personalVO.id == id then 
			return personalVO;
		end
	end
	
	return nil
end

--剩余道具进入次数
PersonalBossModel.itemEnterNum = 0;
function PersonalBossModel:SetItemEnterNum(num)
	local cfg = t_consts[136];
	if not cfg then return end
	self.itemEnterNum = cfg.val1 - num;
end

function PersonalBossModel:GetItemEnterNum()
	return self.itemEnterNum;
end

--进入成功后扣除一次道具进入次数
function PersonalBossModel:removeItemEnterNum()
	self.itemEnterNum = self.itemEnterNum - 1;
	if self.itemEnterNum < 0 then self.itemEnterNum = 0; end
end

--自动挑战次数
PersonalBossModel.autoNum = 0;
function PersonalBossModel:SetAutoNum(num)
	if not num then self.autoNum = 0 return end
	self.autoNum = num - 1;
end

function PersonalBossModel:RemoveAutoNum()
	self.autoNum = self.autoNum - 1;
end

function PersonalBossModel:GetAutoNum()
	return self.autoNum;
end

function PersonalBossModel:SetAutoFlag(autoFlag)
	self.autoFlag = autoFlag
end

function PersonalBossModel:GetAutoFlag()
	return self.autoFlag
end


-------------------------------------------------------------------BOSS-------------------------------------------------

PersonalBossModel.fieldBossList = {}

function PersonalBossModel:FieldBossUpDate(list)
	for k, v in pairs(list) do
		self:SetFieldBossDate(v)
	end
end

function PersonalBossModel:SetFieldBossDate(list)
	if not self.fieldBossList[list.tid] then
		self.fieldBossList[list.tid] = {}
	end
	local vo = self.fieldBossList[list.tid]
	vo.line = list.line
	vo.state = list.state
	vo.lastKillRoleID = list.lastKillRoleID
	vo.lastKillRoleName = list.lastKillRoleName
	vo.lastKillTime = list.lastKillTime 

	--- list.type = 0 请求   1 开启  2 重生  3 死亡
	--- 刷新界面显示
end

--- 获取野外BOSS信息
function PersonalBossModel:GetFieldBossInfo(id)
	return self.fieldBossList[id]
end


--秘境boss
function PersonalBossModel:PalaceBossUpDate(list)

	for id, cfg in pairs(list) do
		if not self.PalaceBossList[id] then
		    self.PalaceBossList[id] = {}
 	    end
		local vo = self.PalaceBossList[id];
		vo.id=cfg.id
		vo.state = cfg.state
		vo.lastKillRoleID = cfg.lastKillRoleID
		vo.lastKillRoleName = cfg.lastKillRoleName
		vo.lastKillTime = cfg.lastKillTime
	end
	--self.PalaceBossList[id]
end
--- 获取秘境BOSS信息
function PersonalBossModel:GetPalaceBossInfo(id)
	return self.PalaceBossList[id]
end
function PersonalBossModel:GetPalaceBossList()
	table.sort(self.PalaceBossList,function(A,B) 
        if A.id<B.id then 
   		    return true
   	    else
   		    return false
   	    end
   	end)
	return self.PalaceBossList
end