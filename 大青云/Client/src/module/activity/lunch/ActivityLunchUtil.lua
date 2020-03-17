--[[
大摆筵席的公用方法
houxudong
2016年8月18日11:15:26
]]

_G.ActivityLunchUtil = {};

-- 将秒转为00:00:00或00:00格式
-- 参数time            传进来的秒数
-- 参数alwaysShowHour  是否一直显示小时
function ActivityLunchUtil:ParseTime(time, alwaysShowHour)
	local timeStr = "";
	if not time then time = 0 end
	local hour, min, sec = CTimeFormat:sec2format(time);
	if alwaysShowHour or hour > 0 then
		timeStr = string.format("%02d:%02d:%02d", hour, min, sec);
	else
		timeStr = string.format("%02d:%02d", min, sec);
	end
	return timeStr;
end

--获取活动剩余时间 
function ActivityLunchUtil:GetLevelTime()
	local totalTime = ActivityLunchConsts.totalTime;
	local nowTime = GetServerTime();
	local y, m, d = CTimeFormat:todate(nowTime,true,true)
	local activityId = ActivityLunch:GetId()
	local cfg = t_activity[activityId]
	if not cfg then return; end
	local times = cfg.openTime;
	if not times then return; end
	local thm = split(times,':')
	local startTime = GetTimeByDate(y,m,d,thm[1],thm[2],thm[3])
	local passTime = nowTime - startTime
	if passTime >= 0 and passTime <= ActivityLunchConsts.totalTime then
		return  ActivityLunchConsts.totalTime - passTime;
	end
	return 1;
end

-- 检测套餐的消耗
function ActivityLunchUtil:CheckMealCost(mealType)
	local normalCfg = t_lunch[mealType]
	if not normalCfg then
		Debug("not find normal Meal Data in lunch table....")
		return
	end
	if not normalCfg.cost_type then
		Debug("not find cost_type in lunch table....")
		return
	end
	local cost = normalCfg.cost
	local itemOrPlayerInfo = false   --默认消耗物品
	local costName = ''      --消耗名称
	local needNum = 0        --消耗需要的数量
	local needVipLevel = 0   --需要的vip等级
	local id = 0             --id
	if normalCfg.cost_type == ActivityLunchConsts.ITEM_COST_TYPE then
		id = toint(split(cost,',')[1])
		if id <= 1000 then   --消耗玩家身上的属性
			costName = enAttrTypeName[toint(split(cost,',')[1])]
			itemOrPlayerInfo = true
		else
			local itemCfg = t_item[id]
			if not itemCfg then
				Debug("not find itemCfg in item table....",id)
			end
			costName = itemCfg.name and itemCfg.name or ''
		end
		needNum = toint(split(cost,',')[2]) and toint(split(cost,',')[2]) or 0
	elseif normalCfg.cost_type == ActivityLunchConsts.VIP_COST_TYPE then
		needVipLevel = toint(cost)
	elseif normalCfg.cost_type == ActivityLunchConsts.NOTHING_COST_TYPE then
		print("not cost anything.....")
	end
	return normalCfg.cost_type,itemOrPlayerInfo,id,costName,needNum,needVipLevel
end