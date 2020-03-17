_G.MClientUtil = {};
function MClientUtil:GetCfgList()
	local cfgList = t_xianjie;
	local templist = {};
	local playerinfo = MainPlayerModel.humanDetailInfo;
	for i, info in ipairs(cfgList) do
		if playerinfo.eaLevel > info.level then
			local vo = {};
			vo.id = info.id
			vo.name = info.name;
			vo.level = info.level;
			vo.count = info.count;
			vo.num = info.num
			vo.level_up = info.level_up;
			vo.plus = info.plus;
			vo.fly = info.fly;
			table.push(templist, vo)
		end
	end
	table.sort(templist, function(A, B)
		if A.id < B.id then
			return true;
		else
			return false;
		end
	end);
	return templist;
end

function MClientUtil:GetHuoYueDuList()

	local cfgList = self:GetCfgList();
	local uilist = {};
	local playerinfo = MainPlayerModel.humanDetailInfo;

	for i, info in ipairs(cfgList) do

		local vo = {};
		local moneyicon = {};
		vo.level = info.level;
		vo.plus = info.plus;
		local serverData = HuoYueDuModel:GetIndexHuoyuelist(info.id);
		vo.id = info.id;
		vo.type = 1;
		if serverData then
			vo.taskname = string.format(info.name);
			vo.count = string.format(StrConfig['mclient107'], (info.count-serverData.num));
			vo.num = info.num;
			if serverData.num == info.count then--已完成
				vo.type = 0;
			end
		else
			vo.taskname = info.name;
			vo.count = string.format(StrConfig['mclient107'], info.count);
			vo.num = info.num;
		end;
		if playerinfo.eaLevel > info.level then
			table.insert(uilist, vo);
		end
	end;

	table.sort(uilist, function(A, B)

		if A.type == B.type then
			if A.level < B.level then
				return true;
			else
				return false;
			end
		else
			if A.type > B.type then
				return true;
			else
				return false;
			end
		end
	end);

	local list = {};
	for i, vo in pairs(uilist) do
		if vo.type == 0 or vo.id == 7 then--已完成的和世界boss不显示在列表中
			break;
		else
			table.insert(list, UIData.encode(vo));
		end
	end
	return list;
end
function MClientUtil:GetTimeStr()
	local curLv  = MainPlayerModel.humanDetailInfo.eaLevel;
	local curMonsterId = nil;
	local curBossId = nil;
	local timeStr = nil;
	for bossId , vo in pairs(ActivityWorldBoss.worldBossList) do
		local cfg = t_worldboss[bossId];
		if cfg then
			curMonsterId  = cfg.monster;
			local monsterCfg = t_monster[curMonsterId];
			if curLv >= monsterCfg.level then
				curBossId = bossId;
			else
				break;
			end
		end
	end
	local info = ActivityWorldBoss:GetWorldBossInfo(curBossId);
	local alive = info and info.state~=1 or false;
	if alive then
		timeStr = string.format("<font color='#00ff00'>%s</font>", StrConfig['worldBoss006']);
	else
		timeStr = string.format(StrConfig['worldBoss504'], PublicUtil:GetShowTimeStr(WorldBossUtils:GetNextBirthTime(curMonsterId)));
	end
	return timeStr;
end
