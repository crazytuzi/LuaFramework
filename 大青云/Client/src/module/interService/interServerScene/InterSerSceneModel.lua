--[[
跨服场景
wangshuai
]]

_G.InterSerSceneModel = Module:new();

InterSerSceneModel.isTest = false;
InterSerSceneModel.isActivity = false;

InterSerSceneModel.SSScoreNum = 0;

function InterSerSceneModel:SetSSSCoreNum(num)
	self.SSScoreNum = num;
end;

function InterSerSceneModel:GetSSSCoreNum()
	return self.SSScoreNum;
end;

function InterSerSceneModel:GetSceneIsIng()
	return self.isActivity;
end;

function InterSerSceneModel:SetSceneIsIng(bo)
	self.isActivity = bo;
end;

InterSerSceneModel.PanelInfo = {};--面板信息
function InterSerSceneModel:SetPanelInfo(lastTime,rewardState,questList)
	self.PanelInfo = {};
	self.PanelInfo.lastTime = lastTime;
	self.PanelInfo.rewardState = rewardState;
	self.PanelInfo.questList = questList;
end;

-- 得到剩余时间
function InterSerSceneModel:GetLastTime()
	return self.PanelInfo.lastTime or 0;
end;

function InterSerSceneModel:SetRewardState(result)
	self.PanelInfo.rewardState = result
end;

-- 得到领奖状态
function InterSerSceneModel:getRewardState()
	if self.PanelInfo.rewardState and self.PanelInfo.rewardState == 1 then 
		return true;
	end;	
	return false;
end;

-- 得到完成任务列表
function InterSerSceneModel:GetQuestRewardList()
	if self.isTest then 
		local list = {};
		for i=1,4  do 
			local vo = {};
			vo.questId = i;
			table.push(list,vo)
		end;
		do return list end;
	end;
	return self.PanelInfo.questList or {};
end;

--设置我的阵营
function InterSerSceneModel:SetMyCamp(camp)
	self.PanelInfo.Mycamp = camp;
end;

function InterSerSceneModel:GetMyCamp()
	return self.PanelInfo.Mycamp or 0;
end;

--   大boss状态列表
InterSerSceneModel.curBossMonsterList = {};
function InterSerSceneModel:SetBossMonsterState(monsterId,state,upTime)
	if not self.curBossMonsterList[monsterId] then 
		self.curBossMonsterList[monsterId] = {};
	end;
	self.curBossMonsterList[monsterId].monsterId = monsterId;
	self.curBossMonsterList[monsterId].state = state;
	self.curBossMonsterList[monsterId].upTime = upTime;
end;

function InterSerSceneModel:GetBossMonsterInfo()
	if self.isTest then 
		local list = {};
		for i=1,3 do 
			local vo = {};
			vo.monsterId = 100 + i;
			vo.state = math.random(2);
			vo.upTime = math.random(5000,1000)
			table.push(list,vo)
		end;
		do return list end;
	end;

	--重新排序
	local list = {};
	for i,info in pairs(self.curBossMonsterList) do 
		table.push(list,info)
	end;
		-- 排序
	table.sort(list,function(A,B)
			if A.monsterId < B.monsterId then
				return true;
			else
				return false;
			end
		end);

	return self.curBossMonsterList;
end;

-- 击杀排行榜 排行榜
InterSerSceneModel.skillRanklist = {};
function InterSerSceneModel:SetSkillRanklist(list)
	self.skillRanklist = {};
	for i,info in ipairs(list) do 
		local vo = {};
		vo.roleName = info.roleName;
		vo.num = info.num;
		vo.camp = info.camp;
		vo.rank = i;
		table.push(self.skillRanklist,vo)
	end;
end;

function InterSerSceneModel:GetSkillRankList()
	if self.isTest then 
		local list = {};
		for i=1,10  do 
			local vo = {};
			vo.roleName = "哈哈哈";
			vo.num = i;
			vo.camp = math.random(5);
			table.push(list,vo)
		end;
		do return list end;
	end;
	return self.skillRanklist;
end;

--被杀排行榜
InterSerSceneModel.beSkillRanklist = {};
function InterSerSceneModel:SetBeSkillRanklist(list)
	self.beSkillRanklist = {};
	for i,info in ipairs(list) do 
		local vo = {};
		vo.roleName = info.roleName;
		vo.num = info.num;
		vo.camp = info.camp;
		vo.rank = i;
		table.push(self.beSkillRanklist,vo)
	end;	
end;

function InterSerSceneModel:GetBeSkillRanklist()
	if self.isTest then 
		local list = {};
		for i=1,10  do 
			local vo = {};
			vo.roleName = "搓搓搓";
			vo.num = i;
			vo.camp = math.random(5);
			table.push(list,vo)
		end;
		do return list end;
	end;
	return self.beSkillRanklist;
end;

-- ////////////////////////////任务信息
-- 自己接取的任务信息
InterSerSceneModel.questMyinfo = {};
function InterSerSceneModel:SetQuestMyinfo(list)
	self.questMyinfo = {};
	for i,info in ipairs(list) do 
		local vo = {};
		vo.questId = info.questId;
		vo.questUId = info.questUId;
		vo.questState = info.questState;
		vo.condition = info.condition;
		self.questMyinfo[info.questUId] = vo;

	end;
end;

-- 更新我的任务信息
function InterSerSceneModel:UpdataMyQuestInfo(questId,questUId,questState,condition)
	if not self.questMyinfo[questUId] then 
		self.questMyinfo[questUId] = {};
	end;
	local vo = {};
	vo.questId = questId;
	vo.questUId = questUId;
	vo.questState = questState;
	vo.condition = condition;
	self.questMyinfo[questUId] = vo;
end;

function InterSerSceneModel:GetMyQuestNum()
	local num = 0 ;
	for i,info in pairs(self.questMyinfo) do 
		num = num + 1;
	end;
	return num
end;

--删除我的任务信息
function InterSerSceneModel:RemoveAQuestInfo(questId) 
	-- for i,info in pairs(self.questMyinfo) do 
	-- 	if info.questUId == questId then 
	-- 		print(info.questUId,questId)
	-- 		print("删除啊啊啊啊",i)
	-- 		table.remove(self.questMyinfo,i,1);
	-- 		break;
	-- 	end;
	-- end;
	-- trace(self.questMyinfo)
	if not self.questMyinfo[questId] then 
		print("a questId no delete",debug.traceback())
		return 
	end;
	self.questMyinfo[questId] = nil;
end;

function InterSerSceneModel:GetMyQuestInfo()
	if self.isTest then 
		local list = {};
		for i=1,8  do 
			local vo = {};
			if i > 4 then 
				i = i - 4;
			end;
			vo.questId = i;
			vo.questUId = "sdsdee#";
			vo.questState = 0;
			vo.condition = i * 10;
			table.push(list,vo)
		end;
		do return list end;
	end;
	local list = {};
	for i,info in pairs(self.questMyinfo) do 
		table.push(list,info)
	end;
	return list;
end;


--当前任务列表
InterSerSceneModel.curQuestInfo = {};
function InterSerSceneModel:SetCurQuestInfo(dayNum,lastNum,list)
	self.curQuestInfo = {};
	self.curQuestInfo.dayNum = dayNum;
	self.curQuestInfo.lastNum = lastNum;
	self.curQuestInfo.questList = list;
end;

function InterSerSceneModel:GetCurDayNum()
	return self.curQuestInfo.dayNum or 0;
end;

function InterSerSceneModel:GetQuestUpdataNum()
	return self.curQuestInfo.lastNum or 0;
end;

function InterSerSceneModel:GetCurQuestInfo()
	if self.isTest then 
		local list = {};
		for i=1,8  do 
			local vo = {};
			if i > 4 then 
				i = i - 4;
			end;
			vo.questId = i;
			table.push(list,vo)
		end;
		do return list end;
	end;
	return self.curQuestInfo.questList or {};
end;

--///////////////////////队伍
InterSerSceneModel.myTeamInfo = {};
function InterSerSceneModel:SetMyTeamInfo(teamlist)
	self.myTeamInfo = {};
	for i,info in ipairs(teamlist) do 
		local vo = {};
		vo.roleID = info.roleID;
		vo.roleName = info.roleName;
		vo.status = info.status;
		vo.lvl = info.lvl;
		vo.fight = info.fight;
		table.push(self.myTeamInfo,vo)
	end;
end;

function InterSerSceneModel:GetMyTeamNum()
	local num = 0;
	for i,info in ipairs(self.myTeamInfo) do 
		num = num + 1;
	end;
	return num;
end;

function InterSerSceneModel:GetMyTeamInfo()
	if self.isTest then 
		local list = {};
		for i=1,5 do 
			local vo = {};
			vo.roleID = i == 3 and "253960_1455593652" or "ssc233d##"
			vo.roleName = "哈哈哈";
			vo.status = i == 3 and 1 or 2;
			vo.lvl = i*32;
			vo.fight = i*5568;
			table.push(list,vo)
		end;
		do return list end
	end;
	return self.myTeamInfo;
end;

function InterSerSceneModel:GetMyIsHavaTeam()
	self.myTeamInfo = self:GetMyTeamInfo();
	if self.myTeamInfo and #self.myTeamInfo > 0 then 
		for i,info in ipairs(self.myTeamInfo) do
			local myroleid = MainPlayerController:GetRoleID();
			if info.roleID == myroleid then 
				return true,info.status;
			end;
		end;
		return false;
	end;
	return false;
end

function InterSerSceneModel:GetIsTeamLeader()
	self.myTeamInfo = self:GetMyTeamInfo();
	if self.myTeamInfo and #self.myTeamInfo > 0 then 
		for i,info in ipairs(self.myTeamInfo) do
			local myroleid = MainPlayerController:GetRoleID();
			if info.roleID == myroleid then 
				if info.status == 1 then 
					return true,info.status;
				end;
			end;
		end;
		return false;
	end;
	return false;
end;

-- 附近队伍信息
InterSerSceneModel.nearbyTeamInfo = {};
function InterSerSceneModel:SetNearbyTeamInfo(teamlist)
	self.nearbyTeamInfo = {};
	for i,info in ipairs(teamlist) do 
		local vo = {};
		vo.teamId = info.teamId;
		vo.leaderName = info.leaderName;
		vo.maxRoleFight = info.maxRoleFight;
		vo.roleNum = info.roleNum;
		table.push(self.nearbyTeamInfo,vo)
	end;
end;

function InterSerSceneModel:GetNearbyTeamInfo()
	if self.isTest then 
		local list = {};
		for i=1,5 do 
			local vo = {};
			vo.teamId = i == 3 and "253960_1455593652" or "ssc233d##"
			vo.leaderName = "哈哈哈";
			vo.status = i == 3 and 1 or 2;
			vo.maxRoleFight = i*32;
			vo.roleNum = i;
			table.push(list,vo)
		end;
		do return list end;
	end;
	return self.nearbyTeamInfo;
end;

-- 附近玩家信息
InterSerSceneModel.nearbyRole = {};
function InterSerSceneModel:SetNearbyRole(roleList)
	self.nearbyRole = {};
		for i,info in ipairs(roleList) do 
		local vo = {};
		vo.roleID = info.roleID;
		vo.roleName = info.roleName;
		vo.level = info.level;
		vo.fight = info.fight;
		table.push(self.nearbyRole,vo)
	end;
end;
