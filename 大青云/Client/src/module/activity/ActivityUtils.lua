--[[
活动Utils
lizhuangzhuang
2014年12月4日23:01:59
]]

_G.ActivityUtils = {};

--解析字符串转换成一天中的秒
--function

--- 判断当前地图是不是打宝塔地图
function ActivityUtils:IsYaotaMap(mapid)
	for k, v in pairs(t_yaota) do
		if v.mapid == mapid then
			return true
		end
	end
	return false
end

--- 根据地图ID获取打宝塔ID
function ActivityUtils:GetYaotaId(mapid)
	for k, v in pairs(t_yaota) do
		if v.mapid == mapid then
			return v.id
		end
	end
end

function ActivityUtils:GetCanInMascotComeActivity()
	local list = ActivityModel:GetActivityByType(ActivityConsts.T_MascotCome);
	for k, v in pairs(list) do
		if v:IsOpen() then
			return v;
		end
	end
	return nil;
end

-- 给进入活动的玩家随机产生新名字  @adder:houxudong date:2016/7/13 10:24
function ActivityUtils:makeNewName(  )
	local prof = MainPlayerModel.humanDetailInfo.eaProf
	local sex = 0;
	if prof == enProfType.eProfType_Sword or prof == enProfType.eProfType_Human then
		sex = 1;
	else
		sex = 0;
	end
	local prefix,name
	if sex == 1 then
		prefix = t_mansurname[math.random(#t_mansurname)].name;
		name = t_manname[math.random(#t_manname)].name;
	else
		prefix = t_womansurname[math.random(#t_womansurname)].name;
		name = t_womanname[math.random(#t_womanname)].name;
	end
	return prefix..name
end

-- 封神乱斗排行榜奖励数据
function ActivityUtils:BeicangjieRankRewardData( )
	local rewardList = {}
	for i,v in pairs(t_beicangjiereward) do
		local vo = {}
		vo.rank_range = v.rank_range
		vo.id = toint(split(v.rank_range,',')[1])
		vo.rewardOne = v.reward1
		table.push(rewardList,vo)
	end
	table.sort( rewardList, function(A,B)
		return A.id < B.id
	end )
	return rewardList
end