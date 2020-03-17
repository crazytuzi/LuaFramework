--[[
封妖Util
zhangshuhui
2014年12月04日14:20:20
]]

_G.FengYaoUtil = {};
FengYaoUtil.qualityMax = 5;--品质
FengYaoUtil.boxcount = 6--宝箱数

--获取列表VO
function FengYaoUtil:GetFengYaoListVO(fengyaoid)
	local vo = {};
	vo.fengyaoid = fengyaoid;
	local cfg = t_fengyao[fengyaoid];
	if cfg then
		local monsters = split(cfg.monster_id,',');
		vo.monsterid = tonumber(monsters[1]);
		vo.monsterNum = tonumber(monsters[2]);
		vo.quality = cfg.quality;
		vo.icon_normal = ResUtil:GetFengYaoIconUrl(cfg.icon_normal);
		vo.icon_select = ResUtil:GetFengYaoIconUrl(cfg.icon_select);
		vo.icon_disabled = ResUtil:GetFengYaoIconUrl(cfg.icon_disabled);
		vo.icon_name = ResUtil:GetFengYaoIconUrl(cfg.icon_name);
		vo.finish_score = cfg.finish_score;
		vo.expReward = cfg.expReward;
		vo.moneyReward = cfg.moneyReward;
		vo.zhenqiReward = cfg.zhenqiReward;
		vo.itemReward = cfg.itemReward;
		vo.itemReward_1 = cfg.itemReward_1;
		vo.endid = cfg.endid;
	end
	return vo;
end

--获取列表根据组id
function FengYaoUtil:GetFengYaoListByGroupid(fengyaogroupid)
	local list = {};
	
	for i = 1, self.qualityMax do
		local cfg = t_fengyao[fengyaogroupid*10+i];
		if cfg then
			local vo = {};
			if cfg then
				vo.fengyaoid = cfg.id;
				local monsters = split(cfg.monster_id,',');
				vo.monsterid = tonumber(monsters[1]);
				vo.quality = cfg.quality;
				vo.icon_normal = ResUtil:GetFengYaoIconUrl(cfg.icon_normal);
				vo.icon_select = ResUtil:GetFengYaoIconUrl(cfg.icon_select);
				vo.icon_disabled = ResUtil:GetFengYaoIconUrl(cfg.icon_disabled);
				vo.icon_name = ResUtil:GetFengYaoIconUrl(cfg.icon_name);
				vo.finish_score = cfg.finish_score;
				vo.expReward = cfg.expReward;
				vo.moneyReward = cfg.moneyReward;
				vo.zhenqiReward = cfg.zhenqiReward;
				vo.itemReward = cfg.itemReward;
				vo.itemReward_1 = cfg.itemReward_1;
				vo.endid = cfg.endid;
				table.insert(list ,vo);
			end
		end
	end
	
	table.sort(list,function(A,B)
		if A.fengyaoid < B.fengyaoid then
			return true;
		else
			return false;
		end
	end);
	
	return list;
end

--宝箱状态
function FengYaoUtil:IsGetBoxState(boxid)
	local ishave = false;
	for i,vo in pairs(FengYaoModel.fengyaoinfo.boxedlist) do
		if vo then
			if vo == boxid then
				ishave = true;
				break;
			end
		end
	end
	
	--已领奖
	if ishave == true then
		return FengYaoConsts.ShowType_GetBox;
	else
		local vo = t_fengyaojifen[boxid];
		if vo then
			--达到积分
			if FengYaoModel.fengyaoinfo.curScore >= vo.needStore then
				return FengYaoConsts.ShowType_NotGetBox;
			else
				return FengYaoConsts.ShowType_NoGetBox;
			end
		end
	end
	
	return FengYaoConsts.ShowType_NoGetBox;
end

--总积分数量
function FengYaoUtil:GetAllNeedStore()
	local needStore = 0;
	for i,vo in pairs(t_fengyaojifen) do
		if vo then
			if vo.needStore > needStore then
				needStore = vo.needStore;
			end
		end
	end
	
	return needStore;
end

--是否足够银两刷新难度
function FengYaoUtil:IsHaveGoldRefresh()
	local valinfo = t_consts[20];
	if valinfo == nil then
		return false;
	end
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	if playerinfo.eaBindGold + playerinfo.eaUnBindGold < valinfo.val1 then
		return false;
	end
	
	return true;
end

--是否足够元宝刷新难度
function FengYaoUtil:IsHaveMoneyRefresh()
	local valinfo = t_consts[20];
	if valinfo == nil then
		return false;
	end
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	if playerinfo.eaUnBindMoney+playerinfo.eaBindMoney < valinfo.val2 then
		return false;
	end
	
	return true;
end

--得到当前可领取的宝箱id
function FengYaoUtil:IsNextNotGetBoxid()
	local boxid = 0;
	local isallget = true;
	for i=1,self.boxcount do
		local vo = t_fengyaojifen[i];
		if vo then
			local boxstate = FengYaoUtil:IsGetBoxState(vo.id);
			if boxstate ~= FengYaoConsts.ShowType_GetBox then
				isallget = false;
			end
			--未领奖
			if boxstate == FengYaoConsts.ShowType_NotGetBox then
				boxid = vo.id;
				break;
			end
		end
	end
	if isallget == true then
		boxid = -1;
	end
	return boxid;
end

--距离下次刷新的时间 n分钟刷一次
function FengYaoUtil:GetTimeNextRefresh()
	local curtime = GetDayTime();
	local hour,min,sec = CTimeFormat:sec2format(curtime);
	--得到下次刷新的时间
	local istoday = true;
	local isupdate = false;
	local remaintime = 0;
	remaintime = t_consts[19].val1 * 60 - toint(curtime % (t_consts[19].val1 * 60));
	if toint(curtime % (t_consts[19].val1 * 60)) == 0 then
		isupdate = true;
		remaintime = t_consts[19].val1 * 60;
	end
	istoday = true;
	if DAY - curtime < t_consts[19].val1 then
		istoday = false;
	end
	return istoday, remaintime, isupdate;
end

--距离下次刷新的时间 读具体时间
function FengYaoUtil:GetTimeNextRefresh1()
	local curtime = GetDayTime();
	--获取刷新时间列表
	local str = t_consts[19].param;
	
	local list = {};
	local t = split(str,'#');
	for i=1,#t do
		table.push(list,CTimeFormat:daystr2sec(t[i]));
	end
	
	table.sort(list,function(A,B)
		if A < B then
			return true;
		else
			return false;
		end
	end);
	
	--得到下次刷新的时间
	local istoday = true;
	local isupdate = false;
	local remaintime = 0;
	for k, cfg in pairs(list) do
		if curtime == cfg then
			isupdate = true;
		end
		if curtime < cfg then
			remaintime = cfg - curtime;
			break;
		end
	end
	
	if remaintime == 0 then
		remaintime = DAY - curtime + list[1];
		istoday = false;
	end
	
	return istoday, remaintime, isupdate;
end

--得到当前悬赏的monster_id
function FengYaoUtil:GetCurMonsterId()
	--领取状态
	if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Accepted then
		local cfg = t_fengyao[FengYaoModel.fengyaoinfo.fengyaoId];
		if cfg then
			local monsters = split(cfg.monster_id,',');
			return tonumber(monsters[1]);
		end
	end
	
	return 0;
end
--得到当前悬赏monster的名字
function FengYaoUtil:GetCurMonsterName()
	local cfg = t_monster[FengYaoUtil:GetCurMonsterId()];
	if not cfg then return; end
	return cfg.name;
end

--得到当前是否是未刷新状态（0-10）
function FengYaoUtil:GetIsNotRefreshState()
	local curtime = GetDayTime();
	local hour,min,sec = CTimeFormat:sec2format(curtime);
	if hour < 10 then
		return true;
	end
	
	return false;
end

function FengYaoUtil:GetDQMultipleRewardMap()
	local dqMultipleRewardMap = {};
	local str = t_consts[74].param
	local table = split( str, "#" )
	for i = 1, #table do
		local multipleInfo = split( table[i], "," )
		local multipleType = i
		local multiple     = tonumber( multipleInfo[1] )
		local label        = ""
		if multipleType == 1 then
			label = StrConfig["quest504"]
		elseif multipleType == 2 then
			local playerinfo = MainPlayerModel.humanDetailInfo;
			local groupcfg = t_fengyaogroup[playerinfo.eaLevel];
			if groupcfg then
				local valNum = getNumShow(groupcfg.times);
				local url = ResUtil:GetMoneyIconURL( _G.enAttrType.eaUnBindGold )
				label = string.format( StrConfig["quest505"], multiple, valNum, url )
			end
		elseif multipleType == 3 then
			local url = ResUtil:GetMoneyIconURL( _G.enAttrType.eaUnBindMoney )
			label = string.format( StrConfig["quest506"], multiple, getNumShow(t_consts[51].val2), url )
		end
		dqMultipleRewardMap[multipleType] = { multiple = multiple, label = label }
	end
	return dqMultipleRewardMap
end

--是否能手动刷新状态
function FengYaoUtil:GetIsStateRefresh()
	local playerinfo = MainPlayerModel.humanDetailInfo;
	if playerinfo.eaLevel >= toint(t_consts[107].fval) then
		return 1;
	end
	if playerinfo.eaLevel < t_consts[107].val1 and VipController:GetVipLevel() < t_consts[107].val2 then
		return 2;
	end
	if playerinfo.eaUnBindMoney < t_consts[107].val3 then
		return 3;
	end
	
	return 1;
end

--是否有悬赏奖励或者积分奖励
function FengYaoUtil:GetIsGetReward()
	if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_NoAward or FengYaoUtil:IsNextNotGetBoxid() > 0 then
		return true;
	end
	return false;
end

--检测宝箱可以领取状态
FengYaoUtil.isCanReward = false
function FengYaoUtil:GetCanScoreReward()
	for i=1,6 do                                                                  --判断宝箱可以领取状态
		local vo = t_fengyaojifen[i];
		if vo then
			local boxstate = self:IsGetBoxState(vo.id);
			if boxstate == FengYaoConsts.ShowType_NotGetBox then  
				WriteLog(LogType.Normal,true,'---------------------UILoadingScene:OnShow()',vo.id)
				 self.isCanReward = true;
			end
		end
		vo = {};
	end
	return  self.isCanReward;
end

--检测奖励领取状态和宝箱可以领取状态
--adder：houxudong
--date:2016/7/29 22:38:00
FengYaoUtil.isCan = false
function FengYaoUtil:GetCanShowRedPoint(  )
	if self.isCan ~=nil then
		 self.isCan = nil;
	end
	self.isCan = false;
	if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_NoAward then   --判断领取状态
		 self.isCan = true;
	end

	for i=1,6 do                                                                  --判断宝箱可以领取状态
		local vo = t_fengyaojifen[i];
		if vo then
			local boxstate = self:IsGetBoxState(vo.id);
			if boxstate == FengYaoConsts.ShowType_NotGetBox then              
				 self.isCan = true;
			end
		end
		vo = {};
	end
	return  self.isCan;
end

