--DataManager.lua
--/*-----------------------------------------------------------------
--* Module:  DataManager.lua
--* Author:  Andy
--* Modified: 2015年9月22日
--* Purpose: 管理所有活动数据
-------------------------------------------------------------------*/

DataManager = class(nil, Singleton)

function DataManager:__init()
	self._signInData = {}	--签到配置数值
	self._sevenFestival = {}--七日盛典数值
	self._online = {}		--在线礼包数值
	self._level = {}		--等级礼包数值
	self._monthCard = {}	--月卡礼包数值

	self._activityModel = {}--运营活动模板
	self._activity = {}		--运营活动配置数值

	self:initialize()
end

function DataManager:initialize()
	self:loadSignin()
	self:loadSevenFestival()
	self:loadWelfare()

	self._activityModel = {
		startTime = 0,			--开始时间
		endTime	= 0,			--结束时间
		week = {},				--开放星期,{2, 4}指定时间内的周二周四开
		levelDown = 1,			--可见等级下限
		levelUp = 70,			--可见等级上限
		joinLevelDown = 1,		--参与等级下限
		joinLevelUp = 70,		--参与等级上限
		lableType = 1,			--活动标签页类型：推荐活动（0），超值特权（1），游戏公告（2）
		leftLabel = 1,			--活动左上角标签：1:限时（黄色）、2:火爆（红色）、3:最新（绿色）、4:免费（紫色）
		activityPic = 1,		--活动图标
		order = 4,				--显示顺序
		loopType = 0,			--循环类型：0、无周期，直接按配置的时间段 1、按日循环 2、按周循环 3、按月循环 4、按年循环
		name = "",				--活动名称
		desc = "",				--活动描述
		index = false,			--是否为锚点
		modelID = 10,			--模型ID
		link = "",				--立即前往
		------------------------- 以下参数非每个活动都有 ------------------------
		cycleStartTime = 0,		--指定时段开始时间
		cycleEndTime = 0,		--指定时段结束时间
		itemList = {},			--奖励道具
		discountList = {},		--折扣店列表
		args = {},				--副本ID/地图ID/怪物ID/任务ID
		dropID = 0,				--新掉落ID
		yieldRate = 0,			--游戏收益比例
		exchangeList = {},		--兑换列表
		arg1 = 0,				--附加参数1
		arg2 = 0,				--附加参数2
		arg3 = 0,				--附加参数3
	}
end

function DataManager:loadSignin()
	local signInData = {}
	for _, record in pairs(require "data.SignInDB" or {}) do
		local signIn = {}
		signIn.itemID = record.q_itemID
		signIn.num = record.q_num
		signIn.bind = toBool(record.q_bind)
		if not signInData[record.q_month] then
			signInData[record.q_month] = {}
		end
		signInData[record.q_month][record.q_day] = signIn
	end
	self._signInData = signInData
end

function DataManager:loadSevenFestival()
	local sevenFestival = {}
	for _, record in pairs(require "data.SevenFestivalDB") do
		local config = {}
		config.id = record.q_id
		config.day = record.q_day
		config.type = record.q_type
		config.num = record.q_num
		config.reward = loadstring("return "..(record.q_reward or {}))()
		sevenFestival[config.id] = config
	end
	self._sevenFestival = sevenFestival
end

function DataManager:loadWelfare()
	local levelConfig, onlineConfig, monthCard = {}, {}, {}
	for _, record in pairs(require "data.WelfareDB") do
		local sys, index, reward = record.q_sys or 0, record.q_index or 1, loadstring("return "..(record.q_reward or {}))()
		if sys == 1 then
			levelConfig[index] = reward
		elseif sys == 2 then
			onlineConfig[index] = reward
		elseif sys == 3 then
			monthCard[index] = reward
		end
	end
	self._level = levelConfig
	self._online = onlineConfig
	self._monthCard = monthCard
end

function DataManager:hotUpdata(sys)
	if sys == 1 then
		package.loaded["data.SignInDB"] = nil
		self:loadSignin()
	elseif sys == 2 then
		package.loaded["data.SevenFestivalDB"] = nil
		self:loadSevenFestival()
	elseif sys == 3 then
		package.loaded["data.WelfareDB"] = nil
		self:loadWelfare()
	end
end

function DataManager:getSignConfig(month)
	return self._signInData[month] or {}
end

function DataManager:getSevenLoginConfig()
	return self._sevenFestival
end

function DataManager:getOnlineConfig()
	return self._online or {}
end

function DataManager:getLevelConfig()
	return self._level or {}
end

function DataManager:getMonthCardConfig()
	return self._monthCard or {}
end

function DataManager:getAllActivityConfig()
	return self._activity or {}
end

function DataManager:getActivityConfig(modelID, activityID)
	if self._activity[modelID] then
		return self._activity[modelID][activityID]
	end
end

function DataManager:getActivityConfigByModelID(modelID)
	return self._activity[modelID] or {}
end

--通过运营平台ID活动活动数据
function DataManager:getActivityConfigByActivityId(ActivityId)
	for _, models in pairs(self:getAllActivityConfig()) do
		for activityID, model in pairs(models) do
			if model.ActivityId == ActivityId then
				return model, activityID
			end
		end
	end
end

-- ActivityId:运营平台ID activityID:活动ID
function DataManager.onLoadActivityList(ActivityId, activityID, datas, endRecord)
	local model = unserialize(datas)
	if not g_ActivityMgr:isEmpty(model) then
		local modelID = model.modelID
		if not g_DataMgr._activity[modelID] then
			g_DataMgr._activity[modelID] = {}
		end
		model.ActivityId = ActivityId
		g_DataMgr._activity[modelID][activityID] = model
	else
		warning("[onLoadActivityList] unserialize datas error! table is empty. activityID:" .. tostring(activityID))
	end
	if endRecord then
		g_ActivityMgr:addActivityTable()
	end
end

function DataManager:isRealModelID(modelID)
	for _, type in pairs(ACTIVITY_MODEL) do
		if type >= ACTIVITY_MIN_ID and modelID == type then
			return true
		end
	end
	return false
end

function DataManager:checkReqData(data_body, rsp_body)
	if type(data_body) ~= "table" then
		local errMsg = "[checkReqData] Data is not a table"
		self:setRspErrCode(rsp_body, errMsg, "")
		return false
	end
	local modelID = data_body.Type
	if not self:isRealModelID(modelID) then
		local errMsg = "[checkReqData] Not this Type:"
		self:setRspErrCode(rsp_body, errMsg, modelID)
		return false
	end
	if not data_body.ActivityTitle or #data_body.ActivityTitle == 0 then
		local errMsg = "[checkReqData] ActivityTitle is null. Type:"
		self:setRspErrCode(rsp_body, errMsg, modelID)
		return false
	end
	if not data_body.ActivityContent or #data_body.ActivityContent == 0 then
		local errMsg = "[checkReqData] ActivityContent is null. Type:"
		self:setRspErrCode(rsp_body, errMsg, modelID)
		return false
	end
	return true
end

--增加运营活动
function DataManager:addActivity(data_body, rsp_body)
	if not self:checkReqData(data_body, rsp_body) then
		return
	end
	local ActivityId = data_body.ActivityId
	local model = self:getActivityConfigByActivityId(ActivityId)
	if model then
		local errMsg = "[addActivity] ActivityId already exists! ActivityId:"
		self:setRspErrCode(rsp_body, errMsg, ActivityId)
		return
	end
	local modelID = tonumber(data_body.Type)
	if not modelID then
		local errMsg = "[addActivity] Type is nil"
		self:setRspErrCode(rsp_body, errMsg, "")
		return
	end
	model = table.deepCopy1(self._activityModel)
	if not self:writeActivityData(model, data_body, rsp_body) then
		return
	end
	if not self._activity[modelID] then
		self._activity[modelID] = {}
	end
	local activityID = g_ActivityMgr:createActivityID()
	local datas = serialize(model)
	g_entityDao:updateActivityList(ActivityId, activityID, datas, #datas)
	model.ActivityId = ActivityId
	self._activity[modelID][activityID] = model
	g_ActivityMgr:addActivityTable()
	g_ActivityMgr:sendAllActivityList()
end

--删除运营活动
function DataManager:deleteActivity(data_body, rsp_body)
	if type(data_body) ~= "table" then
		local errMsg = "[deleteActivity] Data is not a table"
		self:setRspErrCode(rsp_body, errMsg, "")
		return
	end
	local ActivityId = data_body.ActivityId
	local model, activityID = self:getActivityConfigByActivityId(ActivityId)
	if model then
		local modelID = model.modelID
		g_ActivityMgr:deleteActivity(modelID, activityID)
		self._activity[modelID][activityID] = nil
		g_ActivityMgr:sendAllActivityList()
		g_entityDao:deleteActivityList(ActivityId)
	else
		local errMsg = "[deleteActivity] Not exists activity. ActivityId:"
		self:setRspErrCode(rsp_body, errMsg, ActivityId)
	end
end

--更新运营活动
function DataManager:updateActivity(data_body, rsp_body)
	if not self:checkReqData(data_body, rsp_body) then
		return
	end
	local ActivityId = data_body.ActivityId
	local model, activityID = self:getActivityConfigByActivityId(ActivityId)
	if model then
		local modelCopy = table.deepCopy1(model)
		local Type = tonumber(data_body.Type)
		if not Type then
			local errMsg = "[updateActivity] Type is nil"
			self:setRspErrCode(rsp_body, errMsg, "")
			return
		end
		local modelID = modelCopy.modelID
		if modelID ~= Type then
			local errMsg = "[updateActivity] Update activity error(type error). update type:" .. Type .. "now type:" .. modelID
			self:setRspErrCode(rsp_body, errMsg, "")
			return
		end
		if not self:writeActivityData(modelCopy, data_body, rsp_body) then
			return
		end
		local datas = serialize(modelCopy)
		g_entityDao:updateActivityList(ActivityId, activityID, datas, #datas)
		modelCopy.ActivityId = ActivityId
		self._activity[modelID][activityID] = modelCopy
		g_ActivityMgr:sendAllActivityList()
	else
		local errMsg = "[updateActivity] Not exists activity. ActivityId:"
		self:setRspErrCode(rsp_body, errMsg, ActivityId)
	end
end

function DataManager:writeActivityData(model, data_body, rsp_body)
	local switch = {
		[ACTIVITY_MODEL.PAY]				= g_DataMgr.writeActivityDataType6,
		[ACTIVITY_MODEL.FIRSTCHARGE] 		= g_DataMgr.writeActivityDataType6,
		[ACTIVITY_MODEL.TOTALCHARGE]		= g_DataMgr.writeActivityDataType6,
		[ACTIVITY_MODEL.TOTALCHARGE2]		= g_DataMgr.writeActivityDataType8,
		[ACTIVITY_MODEL.LEVEL_ACTIVITY] 	= g_DataMgr.writeActivityDataType8,
		[ACTIVITY_MODEL.ONLINE_ACTIVITY]	= g_DataMgr.writeActivityDataType8,
		[ACTIVITY_MODEL.LOGIN]				= g_DataMgr.writeActivityDataType1,
		[ACTIVITY_MODEL.TOTAL_LOGIN]		= g_DataMgr.writeActivityDataType1,
		[ACTIVITY_MODEL.CONTINUOUS_LOGIN]	= g_DataMgr.writeActivityDataType1,
		[ACTIVITY_MODEL.SPECIFIC_ONLINE]	= g_DataMgr.writeActivityDataType1,
		[ACTIVITY_MODEL.JOIN_WORLD_BOSS]	= g_DataMgr.writeActivityDataType4,
		[ACTIVITY_MODEL.TOTAL_JOIN_COPY]	= g_DataMgr.writeActivityDataType4,
		[ACTIVITY_MODEL.TOTAL_KILL_MONSTER]	= g_DataMgr.writeActivityDataType8,
		[ACTIVITY_MODEL.DISCOUNT]			= g_DataMgr.writeActivityDataType2,
		[ACTIVITY_MODEL.SPECIFIC_ITEM]		= g_DataMgr.writeActivityDataType5,
		[ACTIVITY_MODEL.COPY_REWARD]		= g_DataMgr.writeActivityDataType3,
		[ACTIVITY_MODEL.SMELT] = g_DataMgr.writeActivityDataType4,
		[ACTIVITY_MODEL.SMELT_SPECIAL] = g_DataMgr.writeActivityDataType4,
		[ACTIVITY_MODEL.STRENGTHEN]	= g_DataMgr.writeActivityDataType4,
		[ACTIVITY_MODEL.STRENGTHEN_SPECIAL]	= g_DataMgr.writeActivityDataType4,
		[ACTIVITY_MODEL.TASK] = g_DataMgr.writeActivityDataType4,
		[ACTIVITY_MODEL.TASK_REWARD] = g_DataMgr.writeActivityDataType3,
		[ACTIVITY_MODEL.MONSTER_REWARD] = g_DataMgr.writeActivityDataType3,
		[ACTIVITY_MODEL.BAPTIZE] = g_DataMgr.writeActivityDataType4,
		[ACTIVITY_MODEL.BAPTIZE_SPECIAL] = g_DataMgr.writeActivityDataType4,
	}
	local modelID = tonumber(data_body.Type)
	if switch[modelID] and type(switch[modelID]) == "function" then
		model.startTime = tonumber(data_body.BeginTime) or 0
		model.endTime = tonumber(data_body.EndTime) or 0
		model.week = data_body.Week or {}
		model.levelDown = tonumber(data_body.LevelDownlimit) or 0
		model.levelUp = tonumber(data_body.LevelUplimit) or 0
		model.joinLevelDown = tonumber(data_body.JoinlevelDownlimit) or 0
		model.joinLevelUp = tonumber(data_body.JoinlevelUplimit) or 0
		model.lableType = tonumber(data_body.LabelType) or 0
		model.leftLabel = tonumber(data_body.LeftLabel) or 1
		model.activityPic = tonumber(data_body.ActivityPic) or 1
		model.order = tonumber(data_body.ShowOrder) or 1
		model.loopType = tonumber(data_body.LoopType) or 0
		model.name = tostring(data_body.ActivityTitle) or ""
		model.desc = tostring(data_body.ActivityContent) or ""
		model.modelID = modelID
		model.link = tostring(data_body.Link) or ""
		return switch[modelID](model, data_body, rsp_body)
	else
		local errMsg = "[writeActivityData] Cannot find deal function. modelID:"
		self:setRspErrCode(rsp_body, errMsg, modelID)
		return false
	end
end

--[[
注册／登陆／在线类
11: 首次登陆12: 登陆送奖励 13：累计登陆送 14：连续登陆送  16：指定时间段在线
]]
function DataManager.writeActivityDataType1(model, data_body, rsp_body)
	if model.modelID == ACTIVITY_MODEL.SPECIFIC_ONLINE then
		model.cycleStartTime = tonumber(data_body.CycleBeginTime)
		if not model.cycleStartTime then
			local errMsg = "[cycleStartTime] cycleStartTime param error! cycleStartTime is null"
			g_DataMgr:setRspErrCode(rsp_body, errMsg, "")
			return false
		end
		model.cycleEndTime = tonumber(data_body.CycleEndTime)
		if not model.cycleEndTime then
			local errMsg = "[cycleEndTime] cycleEndTime param error! cycleEndTime is null"
			g_DataMgr:setRspErrCode(rsp_body, errMsg, "")
			return false
		end
	elseif model.modelID ~= ACTIVITY_MODEL.LOGIN then
		model.arg1 = tonumber(data_body.Arg1)
		if not model.arg1 then
			local errMsg = "[Arg1] Arg1 param error! Arg1 is null"
			g_DataMgr:setRspErrCode(rsp_body, errMsg, "")
			return false
		end
		if model.arg1 <= 0 then
			local errMsg = "[Arg1] Arg1 param error! Arg1 <= 0, Arg1:"
			g_DataMgr:setRspErrCode(rsp_body, errMsg, model.arg1)
			return false
		end
	end
	local result = false
	model.itemList, result = g_DataMgr:delaItemList(data_body.ItemList1, rsp_body, true)
	return result
end

--[[
出售类
31：购买资源打折
]]
function DataManager.writeActivityDataType2(model, data_body, rsp_body)
	for _, list in pairs(data_body.GoodList) do
		local listInfo = model.discountList[list.GroupId]
		if not listInfo then
			listInfo = {}
			listInfo.groupID = list.GroupId				--组ID
			listInfo.groupName = list.GroupName			--组名称
			listInfo.oldType = list.OriginType			--原货币类型(元宝、绑定元宝、金币)
			listInfo.oldPrice = list.OriginPrice		--原道具原价
			listInfo.disType = list.DiscountType		--物品折扣价货币类型
			listInfo.disPrice = list.DiscountPrice		--折扣价
			listInfo.disDesc = list.Discount			--折扣比例(显示用)
			listInfo.itemList = {}						--购买获得的物品列表
			model.discountList[list.GroupId] = listInfo
		end
		local itemID, count, bind = tonumber(list.ItemId), tonumber(list.ItemNum), toNumber(list.IsBind, 1) == 1
		if not g_ActivityMgr:validItemID(itemID) then
			local errMsg = "[GoodList] Item id error! cannot find this itemID:"
			g_DataMgr:setRspErrCode(rsp_body, errMsg, itemID)
			return false
		end
		table.insert(listInfo.itemList, {itemID = itemID, count = count, bind = bind})
	end
	return true
end

--[[
收益调整类
52：副本收益限时调整 54：怪物收益限时调整 55：任务收益限时调整
]]
function DataManager.writeActivityDataType3(model, data_body, rsp_body)
	model.args = data_body.SysId or {}
	model.dropID = tonumber(data_body.DropId) or 0
	model.yieldRate = tonumber(data_body.YieldRate) or 1
	model.arg1 = data_body.Arg1
	return true
end

--[[
达标类
71：副本累计参与送　72：世界BOSS参与送　73：熔炼N次返利 74：熔炼指定部位返利 75：强化N次返利 76：强化指定部位返利
77：组队击杀指定怪物 78：任务送
]]
function DataManager.writeActivityDataType4(model, data_body, rsp_body)
	local result = false
	model.args = data_body.SysId or {}
	model.itemList, result = g_DataMgr:delaItemList(data_body.ItemList1, rsp_body)
	model.arg2 = tonumber(data_body.Arg2)
	model.arg1 = tonumber(data_body.Arg1)
	return result
end

--[[
兑换类
91：上交指定物品集齐送礼
]]
function DataManager.writeActivityDataType5(model, data_body, rsp_body)
	for _, list in pairs(data_body.NeedItemList) do
		local listInfo = model.exchangeList[list.GroupId]
		if not listInfo then
			listInfo = {}
			listInfo.groupID = list.GroupId
			listInfo.groupName = list.SegmentName
			listInfo.needItemList = {}
			listInfo.givenItemList = {}
			model.exchangeList[list.GroupId] = listInfo
		end
		local itemID, count, bind = tonumber(list.ItemId), tonumber(list.Num), toNumber(list.IsBind, 1) == 1
		if not g_ActivityMgr:validItemID(itemID) then
			local errMsg = "[NeedItemList] Item id error! cannot find this itemID:"
			g_DataMgr:setRspErrCode(rsp_body, errMsg, itemID)
			return false
		end
		if not count then
			local errMsg = "[NeedItemList] Item count is nil"
			g_DataMgr:setRspErrCode(rsp_body, errMsg, "")
			return false
		end
		table.insert(listInfo.needItemList, {itemID = itemID, count = count, bind = bind})
	end
	for _, list in pairs(data_body.GivenItemList) do
		local listInfo = model.exchangeList[list.GroupId]
		if listInfo then
			local itemID, count, bind = tonumber(list.ItemId), tonumber(list.Num), toNumber(list.IsBind, 1) == 1
			if not g_ActivityMgr:validItemID(itemID) then
				local errMsg = "[GivenItemList] Item id error! cannot find this itemID:"
				g_DataMgr:setRspErrCode(rsp_body, errMsg, itemID)
				return false
			end
			if not count then
				local errMsg = "[GivenItemList] Item count is nil"
				g_DataMgr:setRspErrCode(rsp_body, errMsg, "")
				return false
			end
			table.insert(listInfo.givenItemList, {itemID = itemID, count = count, bind = bind})
		end
	end
	return true
end

--[[
充值类
111：累积充值促销 112：首次充值x元赠送x奖励　113：消费返还活动
]]
function DataManager.writeActivityDataType6(model, data_body, rsp_body)
	if model.modelID ~= ACTIVITY_MODEL.FIRSTCHARGE then
		model.arg1 = tonumber(data_body.Arg1)
		if not model.arg1 then
			local errMsg = "[Arg1] Arg1 param error! Arg1 is null"
			g_DataMgr:setRspErrCode(rsp_body, errMsg, "")
			return false
		end
		if model.arg1 <= 0 then
			local errMsg = "[Arg1] Arg1 param error! Arg1 <= 0, Arg1:"
			g_DataMgr:setRspErrCode(rsp_body, errMsg, model.arg1)
			return false
		end
	end
	local result = false
	model.itemList, result = g_DataMgr:delaItemList(data_body.ItemList1, rsp_body, true)
	return result
end

--[[
分段类
151：在线时长奖励 152：累计充值分段奖励 154：累计击杀怪物数 156.角色等级分段奖励
]]
function DataManager.writeActivityDataType8(model, data_body, rsp_body)
	if model.modelID == ACTIVITY_MODEL.TOTAL_KILL_MONSTER then
		model.arg1 = tonumber(data_body.Arg1)
		if not model.arg1 then
			local errMsg = "[Arg1] Arg1 param error! Arg1 is null"
			g_DataMgr:setRspErrCode(rsp_body, errMsg, "")
			return false
		end
		if model.arg1 <= 0 then
			local errMsg = "[Arg1] Arg1 param error! Arg1 <= 0, Arg1:"
			g_DataMgr:setRspErrCode(rsp_body, errMsg, model.arg1)
			return false
		end
	end
	model.args = data_body.SysId or {}
	local result = false
	model.itemList, result = g_DataMgr:delaItemList(data_body.ItemList1, rsp_body)
	return result
end

function DataManager:delaItemList(itemList, rsp_body, notIndex)
	local items = {}
	for _, item in pairs(itemList or {}) do
		--bind 0:非绑定 1:绑定
		local index, itemID, count, bind = tonumber(item.Arg), tonumber(item.ItemId), tonumber(item.ItemNum), toNumber(item.IsBand, 1) == 1
		if not index then
			local errMsg = "[ItemList1] Arg error(not Arg)! default zero(0)"
			self:setRspErrCode(rsp_body, errMsg, "")
			return {}, false
		end
		if not g_ActivityMgr:validItemID(itemID) then
			local errMsg = "[ItemList1] Item id error! cannot find this itemID:"
			self:setRspErrCode(rsp_body, errMsg, itemID)
			return {}, false
		end
		if notIndex and index ~= 0 then
			local errMsg = "[ItemList1] Arg error! Arg must be equal to zero(0). Now Arg is:"
			self:setRspErrCode(rsp_body, errMsg, index)
			return {}, false
		end
		if index == 0 then
			table.insert(items, {itemID = itemID, count = count, bind = bind})
		else
			if not items[index] then
				items[index] = {}
			end
			table.insert(items[index], {itemID = itemID, count = count, bind = bind})
		end
	end
	return items, true
end

function DataManager:setRspErrCode(rsp_body, errMsg, param)
	param = tostring(param) or "nil"
	errMsg = errMsg .. param
	warning(errMsg)
	rsp_body.Result = -111
	rsp_body.RetMsg = errMsg
end

-- GM命令清除活动配置
function DataManager:clearConfig()
end

function DataManager.getInstance()
	return DataManager()
end

g_DataMgr = DataManager.getInstance()
g_entityDao:loadActivityList()