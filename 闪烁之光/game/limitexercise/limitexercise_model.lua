--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 限时试炼之境数据模块
-- @DateTime:    2019-05-29 19:02:01
-- *******************************
LimitExerciseModel = LimitExerciseModel or BaseClass()

function LimitExerciseModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

local round_list = Config.HolidayBossNewData.data_round_list
function LimitExerciseModel:config()
end

--存储基本数据
function LimitExerciseModel:setLimitExerciseData(data)
	self.limitexercise_data = data
end
function LimitExerciseModel:getLimitExerciseData()
	if self.limitexercise_data then
		return self.limitexercise_data
	end
	return nil
end

--轮次
function LimitExerciseModel:getCurrentRound()
	if self.limitexercise_data and self.limitexercise_data.round then 
		local round_data = Config.HolidayBossNewData.data_round_list
		if round_data and round_data[self.limitexercise_data.round] then
			return round_data[self.limitexercise_data.round].unit_round
		end
	end
	return 1
end
--难度
function LimitExerciseModel:getCurrentDiff()
	if self.limitexercise_data then
		return self.limitexercise_data.difficulty or 1
	end
	return 1
end
--正在挑战的关卡id
function LimitExerciseModel:getCurrentChangeID()
	if self.limitexercise_data then
		return self.limitexercise_data.order or 1
	end
	return 1
end
--当前关卡的血量
function LimitExerciseModel:getCurrentBossHp()
	if self.limitexercise_data then
		return self.limitexercise_data.hp_per or 0
	end
	return nil
end
--购买成功之后需修改剩余挑战次数的值
function LimitExerciseModel:setChangeCount(count,buy_count)
	if self.limitexercise_data and self.limitexercise_data.count and self.limitexercise_data.buy_count then
		self.limitexercise_data.count = count
		self.limitexercise_data.buy_count = buy_count
	end
end

--当前伙伴已使用次数
function LimitExerciseModel:setHeroUseId(data)
	self.hero_use_list = {}
	for i,v in pairs(data) do
		self.hero_use_list[v.id] = v.count
	end
end
function LimitExerciseModel:getHeroUseId(id)
	if self.hero_use_list and self.hero_use_list[id] then
		return self.hero_use_list[id]
	end
	return 0
end
--宝箱状态
function LimitExerciseModel:getBoxStatus()
	if self.limitexercise_data then
		return self.limitexercise_data.status or 0
	end
	return 0
end
--关卡类型
function LimitExerciseModel:getCurrentType()
	if self.limitexercise_data then
		return self.limitexercise_data.order_type or 0
	end
	return nil
end

--是否是UP英雄
function LimitExerciseModel:isUpHero(bid)
	local _bool = false
	local round = self:getCurrentRound()
	if round and round_list[round] then
		for i,v in pairs(round_list[round].up_hero) do
			if v == bid then
				_bool = true
				break
			end
		end
	end
	return _bool
end

--获取今日购买次数
function LimitExerciseModel:getDayBuyCount()
	if self.limitexercise_data then
		return self.limitexercise_data.buy_count or 0
	end
	return 0
end
--剩余挑战次数
function LimitExerciseModel:getReaminCount()
	if self.limitexercise_data then
		return self.limitexercise_data.count or 0
	end
	return 0
end
function LimitExerciseModel:__delete()
end