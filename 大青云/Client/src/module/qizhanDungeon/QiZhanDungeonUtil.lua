--[[
	2015年11月14日16:52:04
	wangyanwei
]]

_G.QiZhanDungeonUtil = {};

-- 获取副本的名字
function QiZhanDungeonUtil:GetRewardListCfg()
	local list = {};
	for i , cfg in ipairs(t_ridereward) do
		local vo = {};
		vo = cfg.layer;
		
		table.push(list,vo)
	end
	return list;
end

--获取副本中层数 adder:houxudong date:2016/6/28
function QiZhanDungeonUtil:GetListCount()
	local totalNum = 0;
	if #t_ridereward > 0 then
		totalNum = #t_ridereward
	end
	return totalNum;
end


--今日剩余进入次数
function QiZhanDungeonUtil:GetNowEnterNum()
	local dungeondata = QiZhanDungeonModel:GetQiZhanDungeonData();
	if not dungeondata then return end
	local cfg = t_consts[148];
	if not cfg then return end
	local num = cfg.val1 - dungeondata.enterNum ;
	if num < 0 then num = 0 end
	return num or 0;
end

function QiZhanDungeonUtil:SetMyTermPlayerData()

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

function QiZhanDungeonUtil:GetSelfTeamPlayerData()
	self:SetMyTermPlayerData();
	return self.selfTeamPlayerData;
end

--获取最大层数layer
function QiZhanDungeonUtil:GetMaxDungeonLayer()
	local layer = 0;
	for i , dungeonVO in pairs(t_ridedungeon) do
		layer = dungeonVO.id > layer and dungeonVO.id or layer;
	end
	return layer;
end

--当前地图是否在骑战副本中
function QiZhanDungeonUtil:GetInQiZhanDungeon()
	local nowMap = t_map[CPlayerMap:GetCurMapID()];
	if not nowMap then return end
	for i , cfg in pairs(t_ridedungeon) do
		if nowMap.id == cfg.map then
			return true
		end
	end
	return false;
end