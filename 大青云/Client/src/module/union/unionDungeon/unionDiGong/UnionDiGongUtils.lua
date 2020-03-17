--[[
帮派地宫-工具类
]]

_G.UnionDiGongUtils = {};

-- 当前地宫活动状态
function UnionDiGongUtils:GetCurState()
	local statelist = {};
	local weekday = CTimeFormat:toweekEx(GetServerTime());
	local actycfg = t_guildActivity[UnionDungeonConsts.ID_DiGong];
	if not actycfg then
		return nil;
	end
	local tfightday = actycfg.openParam1;
	local topenbidday = split( actycfg.openParam2, "," );
	local tbidday = split( actycfg.openTime, ":" );
	for id=1, #t_guilddigong do
		local digongVo = t_guilddigong[id];
		local curtime = GetDayTime();
		local hour,min,sec = CTimeFormat:sec2format(curtime);
		if MainPlayerController:GetServerOpenDay() < 7 then
			local timetable = split( digongVo.opentime1, ":" );
			--当前是开战日期
			local isfightday = false;
			for fightday=1,#topenbidday do
				if MainPlayerController:GetServerOpenDay() == tonumber(topenbidday[fightday]) then
					if hour == tonumber(tbidday[1]) and ( min >= tonumber(tbidday[2]) and min < actycfg.duration) then
						return UnionDiGongConsts.State_Fight;
					else
						return UnionDiGongConsts.State_ZhanLing;
					end
					break;
				end
			end
			--如果不是战斗时间
			--竞标前
			if hour < tonumber(timetable[1]) or (hour == tonumber(timetable[1]) and min < tonumber(timetable[2])) then
				return UnionDiGongConsts.State_ZhanLing;
			--竞标中
			elseif (hour == tonumber(timetable[1]) and min >= tonumber(timetable[2])) or
				   (hour > tonumber(timetable[1]) and hour < tonumber(timetable[1]) + toint(digongVo.duration1/60)) or
				   (hour == tonumber(timetable[1]) + toint(digongVo.duration1/60) and min < toint(digongVo.duration1%60)) then
				--第二个参数 竞标剩余时间
				return UnionDiGongConsts.State_Bid, (tonumber(timetable[1]) + digongVo.duration1/60 - hour)*60*60 + (60 - min) *60 - sec;
			--竞标结束后
			else
				return UnionDiGongConsts.State_ZhanLing;
			end
			
		--开服7天后
		else
			--争夺日
			if weekday == tonumber(tfightday) - 1 then
				if hour == tonumber(tbidday[1]) and ( min >= tonumber(tbidday[2]) and min < actycfg.duration) then
					return UnionDiGongConsts.State_Fight;
				else
					return UnionDiGongConsts.State_ZhanLing;
				end
				break;
			--竞标日期
			elseif weekday == tonumber(tfightday) - 2 then
				local timetable = split( digongVo.opentime2, ":" );
				--竞标前
				if hour < tonumber(timetable[1]) or (hour == tonumber(timetable[1]) and min < tonumber(timetable[2])) then
					return UnionDiGongConsts.State_ZhanLing;
				--竞标中
				elseif (hour == tonumber(timetable[1]) and min >= tonumber(timetable[2])) or
					   (hour > tonumber(timetable[1]) and hour < tonumber(timetable[1]) + toint(digongVo.duration1/60)) or
					   (hour == tonumber(timetable[1]) + toint(digongVo.duration1/60) and min < toint(digongVo.duration1%60)) then
					return UnionDiGongConsts.State_Bid, (tonumber(timetable[1]) + digongVo.duration2/60 - hour)*60*60 + (60 - min)*60 - sec;
				--竞标结束后
				else
					return UnionDiGongConsts.State_ZhanLing;
				end
			else
				return UnionDiGongConsts.State_ZhanLing;
			end
		end
	end
	
	return UnionDiGongConsts.State_Nil;
end

function UnionDiGongUtils:GetMyUnionRankInfo()
	local index = 1;
	for i, vo in ipairs(UnionDiGongModel:GetUnionBidList()) do
		if vo.unionName == UnionModel.MyUnionInfo.guildName then
			return index,vo.bidmoney;
		end
		index = index + 1;
	end
	
	return 0,0;
end

--得到当前地宫占领的帮派id
function UnionDiGongUtils:GetUnionIdById(id)
	local list = UnionDiGongModel:GetDiGongUnionList();
	local listvo = list[id];
	if not listvo then
		return nil;
	end
	
	return listvo.Unionid;
end

--得到剩余时间
function UnionDiGongUtils:GetHaveTime()
	local statelist = {};
	local weekday = CTimeFormat:toweekEx(GetServerTime());
	local actycfg = t_guildActivity[UnionDungeonConsts.ID_DiGong];
	if not actycfg then
		return nil;
	end
	local tfightday = actycfg.openParam1;
	local topenbidday = actycfg.openParam2;
	local tbidday = split( actycfg.openTime, ":" );
	for id=1, #t_guilddigong do
		local digongVo = t_guilddigong[id];
		local curtime = GetDayTime();
		local hour,min,sec = CTimeFormat:sec2format(curtime);
		if MainPlayerController:GetServerOpenDay() < 7 then
			local timetable = split( digongVo.opentime1, ":" );
			--当前是开战日期
			local isfightday = false;
			for fightday=1,#topenbidday do
				if MainPlayerController:GetServerOpenDay() == tonumber(topenbidday[fightday]) then
					if hour == tonumber(tbidday[1]) and ( min >= 0 and min < actycfg.duration) then
						return 0;
					elseif hour < tonumber(tbidday[1]) then
						return tonumber(tbidday[1]) - hour;
					else
						if MainPlayerController:GetServerOpenDay() == 6 then
							return 24 - hour + (7 - weekday - 1) * 24 + (tonumber(tfightday) - 1)*24 + tonumber(tbidday[1]);
						else
							return  (24 - hour + tonumber(tbidday[1])) + 24;
						end
					end
				else
					return 24 - hour + tonumber(tbidday[1]);
				end
			end
		--开服7天后
		else
			--争夺日
			if weekday == tonumber(tfightday) - 1 then
				--处于争斗中
				if hour == tonumber(tbidday[1]) and ( min >= 0 and min < actycfg.duration) then
					return 0;
				--争斗前
				elseif hour < tonumber(tbidday[1]) then
					return tonumber(tbidday[1]) - hour;
				--争斗后
				else
					return 24 - hour + (7 - weekday - 1) * 24 + (tonumber(tfightday) - 1)*24 + tonumber(tbidday[1]);
				end
			elseif weekday < tonumber(tfightday) - 1 then
				return ((tonumber(tfightday) - 1) - weekday) * 24 + 24 - hour + tonumber(tbidday[1]);
			else
				return 24 - hour + (7 - weekday - 1) * 24 + (tonumber(tfightday) - 1)*24 + tonumber(tbidday[1]);
			end
		end
	end
	
	return 0;
end

--当前帮派可使用的竞标资金
function UnionDiGongUtils:GetUnionBidMoney(id)
	local unionMoney = UnionModel:GetMyUnionMoney();
	local canbidmoney = UnionDiGongUtils:GetCanBidMoney(id);
	local dimon = t_guilddigong[id];
	if canbidmoney == 0 then
		return dimon.price;
	end
	
	if unionMoney > canbidmoney then
		return canbidmoney;
	end
	
	return unionMoney;
end

--得到竞标资金
function UnionDiGongUtils:GetCanBidMoney(id)
	local dimon = t_guilddigong[id];
	local list = UnionDiGongModel:GetUnionBidList();
	local index = 1;
	for i, vo in ipairs(list) do
		if #list == 1 then
			--是不是自己的帮派
			if UnionModel:GetMyUnionName() and UnionModel:GetMyUnionName() == vo.unionName then
				return vo.bidmoney + dimon.bidprice;
			else
				return dimon.price;
			end
		end
		if index == 1 then
			--是不是自己的帮派
			if UnionModel:GetMyUnionName() and UnionModel:GetMyUnionName() == vo.unionName then
				return vo.bidmoney + dimon.bidprice;
			end
		end
		if index == 2 then
			return vo.bidmoney + dimon.bidprice;
		end
		index = index + 1;
	end
	
	return 0;
end

--得到竞标扣除的资金
function UnionDiGongUtils:GetBiddedMoney(id)
	local dimon = t_guilddigong[id];
	local list = UnionDiGongModel:GetUnionBidList();
	local index = 1;
	for i, vo in ipairs(list) do
		if #list == 1 then
			--自己的帮派
			if UnionModel:GetMyUnionName() and UnionModel:GetMyUnionName() == vo.unionName then
				return vo.bidmoney;
			end
		end
		if index == 1 then
			--自己的帮派
			if UnionModel:GetMyUnionName() and UnionModel:GetMyUnionName() == vo.unionName then
				return vo.bidmoney;
			end
		end
		if index == 2 then
			--自己的帮派
			if UnionModel:GetMyUnionName() and UnionModel:GetMyUnionName() == vo.unionName then
				return vo.bidmoney;
			end
		end
		index = index + 1;
	end
	
	return 0;
end

--得到其他活动中是否有前两名竞标
function UnionDiGongUtils:GetIsOtherBidMoney(id)
	local list = UnionDiGongModel:GetDiGongUnionList();
	if not list then
		return false;
	end
	if UnionModel.MyUnionInfo and UnionModel.MyUnionInfo.guildId and UnionModel.MyUnionInfo.guildId ~= '0_0' then
		for i,vo in pairs(list) do
			if i ~= id then
				if vo.unionid1 == UnionModel.MyUnionInfo.guildId then
					return true;
				end
				if vo.unionid2 == UnionModel.MyUnionInfo.guildId then
					return true;
				end
			end
		end
	end
	return false;
end

--得到柱子归属帮派名称
function UnionDiGongUtils:GetZhuZiUnionName(id)
	local list = UnionDiGongController.curBuildState;
	for i,info in ipairs(list) do 
		if info.id == (UnionDiGongConsts.ZhuZiBaseid + id) then
			return info.unionName;
		end;
	end;
	return "";
end

--是否该帮派参与争夺战
function UnionDiGongUtils:GetIsDiGongWarUniont()
	local list = UnionDiGongModel:GetDiGongUnionList();
	if not list then
		return false;
	end
	if UnionModel.MyUnionInfo and UnionModel.MyUnionInfo.guildId and UnionModel.MyUnionInfo.guildId ~= '0_0' then
		for i,vo in pairs(list) do
			if i ~= id then
				if vo.unionid1 == UnionModel.MyUnionInfo.guildId then
					return true;
				end
				if vo.unionid2 == UnionModel.MyUnionInfo.guildId then
					return true;
				end
			end
		end
	end
	return false;
end