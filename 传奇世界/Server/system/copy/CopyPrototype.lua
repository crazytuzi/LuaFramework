--CopyPrototype.lua


CopyPrototype = class()

function CopyPrototype:__init(data)
	assert(type(data) == "table", "Invalid CopyBookPrototype data")
	self.data = data
end

function CopyPrototype:__release()
	self.data = nil
end

function CopyPrototype:tostring()
	return string.format("CopyPrototype: {data: %s}", toString(self.data))
end

function CopyPrototype:__getValue(name, item, default)
	if not item then
		return default
	end

	local value = self.data[name]
	if value == nil then
		value = default
	end

	return value
end

function CopyPrototype:getData()
	return self.data
end

--原型ID
function CopyPrototype:getCopyID()
	return self.data.copyID
end

--名字
function CopyPrototype:getName()
	return self.data.name
end

--所需等级
function CopyPrototype:getLevel()
	return self.data.level
end

--此副本最大数量
function CopyPrototype:getMaxCount()
	return self.data.maxCount
end

--副本时间
function CopyPrototype:getPeriod()
	return self.data.period
end

--CD次数
function CopyPrototype:getCDCount()
	return self.data.cdCount
end

--评级时间
function CopyPrototype:getRatingTime()
	return self.data.ratingTime
end

--是否可以复活
function CopyPrototype:getRelive()
	return self.data.relive
end

--是否可以使用道具复活
function CopyPrototype:getReliveMat()
	return self.data.reliveMat
end

--复活点坐标
function CopyPrototype:getRelivePos()
	return self.data.relivePos
end

--是否可以扫荡
function CopyPrototype:getAutoProgress()
	return self.data.autoProgress
end

--副本类型
function CopyPrototype:getCopyType()
	return self.data.copyType
end

--爬塔以及守护副本层数
function CopyPrototype:getCopyLayer()
	return self.data.copyLayer
end

--下一个副本
function CopyPrototype:getNextCopy()
	return self.data.nextCopy
end

--一共有几个阶段
function CopyPrototype:getMaxCircle()
	return self.data.maxCircle
end

--第一次通关的奖励
function CopyPrototype:getFirstReward()
	return self.data.firstReward
end

--能否传送
function CopyPrototype:getCanTransmit()
	return self.data.canTransmit
end

--通关奖励
function CopyPrototype:getRewardID()
	return self.data.rewardID
end

--通行令表
function CopyPrototype:getPassItem()
	return self.data.passItem
end

--守护副本特殊奖励
function CopyPrototype:getSpecReward()
	return self.data.specReward
end

--抽奖奖励
function CopyPrototype:getShakeReward()
	return self.data.shakeReward
end

function CopyPrototype:getMapID()
	return self.data.mapID
end

function CopyPrototype:getMainID()
	return self.data.mainID
end

--扫荡守护副本需要钱币类型
function CopyPrototype:getMonType()
	return self.data.monType
end

--扫荡守护副本需要钱币值
function CopyPrototype:getMonValue()
	return self.data.monValue
end

function CopyPrototype:getOpenTime()
	return self.data.openTime or nil
end	

function CopyPrototype:getMonsters()
	return self.data.monsters
end

function CopyPrototype:getMonstersById(id)
	if id==1 then
		return self.data.monsters1
	elseif id==2 then
		return self.data.monsters2
	elseif id==3 then
		return self.data.monsters3
	elseif id==4 then
		return self.data.monsters4
	else
		return {}
	end
end

function CopyPrototype:getEnterPos()
	return self.data.enterPos
end

function CopyPrototype:getReliveType()
	return self.data.reliveType
end

--雕像位置
function CopyPrototype:getStatuePos()
	return self.data.statuePos
end

--雕像坐标
function CopyPrototype:getStatueHP()
	return self.data.statueHP
end

function CopyPrototype:getResetting()
	return self.data.resetting
end

function CopyPrototype:getInnerCD()
	return self.data.innerCD
end

function CopyPrototype:getMaxMemCnt()
	return self.data.maxMemCnt or 1
end

function CopyPrototype:getCardPrize()
	return self.data.cardprize
end

--[[function CopyPrototype:getStarTime()
	return self.data.starTime
end--]]

function CopyPrototype:getCopyStarPrize()
	return self.data.starPrize
end

function  CopyPrototype:getCopyFirstPrize()
	return self.data.firstReward
end

--得到副本内协助怪物
function CopyPrototype:getAssistMon()
	return self.data.assistMon
end