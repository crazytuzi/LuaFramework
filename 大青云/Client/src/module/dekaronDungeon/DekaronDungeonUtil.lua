--[[
	2016年1月8日14:56:58
	wangyanwei
	挑战副本
]]

_G.DekaronDungeonUtil = {};

function DekaronDungeonUtil:GetRewardListCfg()
	local list = {};
	for i , cfg in ipairs(t_tiaozhanreward) do
		local vo = {};
		vo = cfg.layer;
		
		table.push(list,vo)
	end
	return list;
end

--今日剩余进入次数
function DekaronDungeonUtil:GetNowEnterNum()
	local dungeondata = DekaronDungeonModel:GetDekaronDungeonData();
	if not dungeondata then return end
	local cfg =t_consts[148];
	if not cfg then return end
	local num = cfg.val1 - dungeondata.enterNum ;
	if num < 0 then num = 0 end
	return num;
end

function DekaronDungeonUtil:SetMyTermPlayerData()

	self.selfTeamPlayerData = {};
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
		vo.level = v.level;
		vo.cap = v.teamPos == 1;
		vo.line = v.line;
		vo.roleID = v.roleID;
		table.push(self.selfTeamPlayerData,vo);
	end
end

function DekaronDungeonUtil:GetSelfTeamPlayerData()
	self:SetMyTermPlayerData();
	return self.selfTeamPlayerData;
end

--获取最大层数layer
function DekaronDungeonUtil:GetMaxDungeonLayer()
	local layer = 0;
	for i , dungeonVO in pairs(t_tiaozhanfuben) do
		layer = dungeonVO.id > layer and dungeonVO.id or layer;
	end
	return layer;
end

--当前地图是否在骑战副本中
function DekaronDungeonUtil:GetInDekaronDungeon()
	local nowMap = t_map[CPlayerMap:GetCurMapID()];
	if not nowMap then return end
	for i , cfg in pairs(t_tiaozhanfuben) do
		if nowMap.id == cfg.map then
			return true
		end
	end
	return false;
end