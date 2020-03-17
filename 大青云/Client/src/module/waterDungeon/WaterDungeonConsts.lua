--[[
流水副本 常量
2015年6月24日14:45:04
haohu
]]

_G.WaterDungeonConsts = {}

-- 每日次数上限
WaterDungeonConsts.timePerDay = 1
-- 副本结算面板倒计时
WaterDungeonConsts.resultPanelTime = 60
-- 奖励显示经验ID
WaterDungeonConsts.uiExpItemId = "110622103,0#110622002,5#110622104,0"

--奖励规则

function WaterDungeonConsts:GetReward( )
	local leavel = MainPlayerModel.humanDetailInfo.eaLevel;  --获得当前玩家等级 
	local column = math.ceil(leavel/5)
	local cfg = t_liushuifuben[column]
	if not cfg then return; end
	return cfg.water_reward
end

-- 总波数
local maxWave
function WaterDungeonConsts:GetMaxWave()
	if not maxWave then
		maxWave = t_consts[79].val1
	end
	return maxWave
end

-- 每波怪物数量
local monsterPerWave
function WaterDungeonConsts:GetWaveMonsterNum()
	if not monsterPerWave then
		monsterPerWave = t_consts[79].val2
	end
	return monsterPerWave
end

-- 副本持续时间 s
local limitTime
function WaterDungeonConsts:GetLimitTime()
	if not limitTime then
		limitTime = t_consts[79].val3 * 60 -- 配的分钟, 换算为秒
	end
	return limitTime
end


-- 经验加成buff效果(t_buffeffect)
WaterDungeonConsts.MultipleExpEff1 = 10120001 -- 经验收益加 0.5  --1级生命药水
WaterDungeonConsts.MultipleExpEff2 = 10120002 -- 经验收益加 1
WaterDungeonConsts.MultipleExpEff3 = 10120003 -- 经验收益加 2
WaterDungeonConsts.MultipleExpEff4 = 10120004 -- 经验收益加 4
WaterDungeonConsts.MultipleExpEff5 = 10120005 -- 经验收益加 9

local multipleExpEffDic
function WaterDungeonConsts:IsMultipleExpEff( buffEffectId )
	if not multipleExpEffDic then
		multipleExpEffDic = {
			[ WaterDungeonConsts.MultipleExpEff1 ] = true,
			[ WaterDungeonConsts.MultipleExpEff2 ] = true,
			[ WaterDungeonConsts.MultipleExpEff3 ] = true,
			[ WaterDungeonConsts.MultipleExpEff4 ] = true,
			[ WaterDungeonConsts.MultipleExpEff5 ] = true
		}
	end
	return multipleExpEffDic[ buffEffectId ] == true
end

-- 经验副本进入消耗的道具
local enterCostItem, enterCostItemNum
function WaterDungeonConsts:GetEnterItem()
	if not enterCostItem or not enterCostItemNum then
		local str = t_consts[122].param    --取得消耗的道具
		if not str then return nil,nil end    
		local tab = split(str, ",")
		enterCostItem, enterCostItemNum = tonumber( tab[1] ), tonumber( tab[2] )
	end
	return enterCostItem, enterCostItemNum
end

-- 经验副本每日付费次数
local payTime
function WaterDungeonConsts:GetPayTime()
	if not payTime then
		payTime = t_consts[122].val1
	end
	return payTime
end

----------------------New Venus-----------------------

-- 经验副本总进入次数
local dailyAllTime
function WaterDungeonConsts:GetDailyAllTime()
	if not dailyAllTime then
		dailyAllTime = t_consts[122].val1
	end
	return dailyAllTime
end

-- 经验副本免费进入次数
local dailyFreeTime
function WaterDungeonConsts:GetDailyFreeTime()
	if not dailyFreeTime then
		dailyFreeTime = t_consts[122].val2
	end
	return dailyFreeTime
end

-- 经验副本付费进入次数
local dailyPayTime
function WaterDungeonConsts:GetDailyPayTimes()
	if not dailyPayTime then
		dailyPayTime = t_consts[122].val1 - t_consts[122].val2
	end
	return dailyPayTime
end

-- 经验副本进入需要CD时间
local needCdTime
function WaterDungeonConsts:needCdTimes(  )
	if not needCdTime then
		needCdTime = t_consts[122].val3
	end
	return needCdTime
end