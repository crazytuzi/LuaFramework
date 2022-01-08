--[[
******赌石数据管理类*******

	-- by Stephen.tao
	-- 2016-03-08 11:17:40
]]

local GambleManager = class("GambleManager")

local itemArray = TFArray:new()
local GameItem = require('lua.gamedata.base.GameItem')
GambleManager.itemArray = itemArray

GambleManager.ItemChange = "GambleManager.ItemChange"
GambleManager.StateChangeMessage = "GambleManager.StateChangeMessage"

GambleManager.gambleMaxLevel = 5
GambleManager.bagMaxNum = 40
function GambleManager:ctor( Data )
	self:init(Data)
	self.levelState = 0

	TFDirector:addProto(s2c.BET_BY_TYPE_SUCCESS_NOTIFY, self, self.betByTypeSuccessNotify)
	TFDirector:addProto(s2c.BATCH_BET_AUTO_SUCCESS_NOTIFY, self, self.batchBetAutoSuccessNotify)
	TFDirector:addProto(s2c.PICK_SUCCESS_NOTIFY, self, self.pickSuccessNotify)
	TFDirector:addProto(s2c.PICKUP_SUCCESS_NOTIFY, self, self.pickupSuccessNotify)
	TFDirector:addProto(s2c.MERGE_AUTO_SUCCESS_NOTIFY, self, self.mergeAutoSuccessNotify)
	TFDirector:addProto(s2c.GAMBLING_ITEM_DETAILS, self, self.gamblingItemDetails)
	TFDirector:addProto(s2c.GAMBLING_ITEM_CACHE_LIST, self, self.gamblingItemCacheList)
	TFDirector:addProto(s2c.GAMBLING_STATE_DETAILS, self, self.gamblingStateDetails)
	self.zhenxuan_cost_tip = false
	self.gamble_cost_tip = {}
	for i=1,GambleManager.gambleMaxLevel do
		self.gamble_cost_tip[i] = false
	end
end

--背包清零
function GambleManager:restart()
	GambleManager.itemArray:clear()


	self.zhenxuan_cost_tip = false
	self.gamble_cost_tip = {}
	for i=1,GambleManager.gambleMaxLevel do
		self.gamble_cost_tip[i] = false
	end
	
	self.levelState = 0
	self:init()
end

function GambleManager:init( Data )

	-- for i=1,10 do
	-- 	local item = {}
	-- 	item.index = i;
	-- 	item.resType = 1;
	-- 	item.resId = 1000 + i;
	-- 	item.resNum = 5;
	-- 	itemArray:push(item)
	-- end
end

function GambleManager:getStateByIndex(index )
	local flag = bit_and(self.levelState,2^(index-1))
	if flag == 0 then
		return false
	end
	return true
end

--背包销毁
function GambleManager:dispose()

	GambleManager.itemArray = nil
end


--获取背包道具的数量
function GambleManager:getBagNum()
	return GambleManager.itemArray:length()
end

--通过当前顺序index获得道具
function GambleManager:getItemByIndex( index )
	return itemArray:getObjectAt(index)
end

function GambleManager:getItemNumById( id )
	local item = self:getItemById(id);
	if not item then
		return 0;
	end
	return item.num
end

--[[
	--增加道具
]]
function GambleManager:addItem( item )
	if item==nil then
		return
	end
	for v in itemArray:iterator() do
		if v.id == id then
			v.num = v.num + item.num
			return
		end
	end
	itemArray:pushBack(item)
end

--[[
	--通过id获得背包道具信息
	--@返回道具
]]
function GambleManager:getItemById( id )
	--print("getItem by : ",id)
	for v in itemArray:iterator() do
		if v.id == id then
			return v
		end
	end
end
--[[
	--通过id及个数删除背包物品
]]
function GambleManager:changeItemById( id , num)
	for v in itemArray:iterator() do
		if v.id == id then
			if v.num + num  > 0 then
				v.num = v.num + num
			else
				itemArray:removeObject(v)
				return
			end
		end
	end
end

--[[
	--通过id及个数删除背包物品
]]
function GambleManager:delItemByid( id)
	for v in itemArray:iterator() do
		if v.id == id then
			itemArray:removeObject(v)
			return
		end
	end   
end

function GambleManager:isBagFull()
	return GambleManager.itemArray:length() >= GambleManager.bagMaxNum
end


--请求赌石
function GambleManager:requestBetByType(type)
	showLoading()
	TFDirector:send(c2s.REQUEST_BET_BY_TYPE ,{2^(type-1)})
end

--一键赌石
function GambleManager:requestBatchBetAuto(count)
	showLoading()
	if count == nil then
		count = 0
	end
	TFDirector:send(c2s.REQUEST_BATCH_BET_AUTO ,{count})
end

--甄选
function GambleManager:requestPick()
	showLoading()
	TFDirector:send(c2s.REQUEST_PICK ,{})
end

--拾取
function GambleManager:requestPickup(index)
	showLoading()
	if index == nil then
		index = 0
	end
	TFDirector:send(c2s.REQUEST_PICKUP ,{index})
end

--一键合成
function GambleManager:requestMergeAuto()
	showLoading()
	TFDirector:send(c2s.REQUEST_MERGE_AUTO    ,{})
end

--赌石操作成功通知
function GambleManager:betByTypeSuccessNotify(event)
	hideLoading()
	local data = event.data
	-- TFDirector:dispatchGlobalEventWith(GambleManager.StateChangeMessage,{}); 
end
--一键赌石操作成功通知
function GambleManager:batchBetAutoSuccessNotify(event)
	hideLoading()
	local data = event.data
	-- data.count  --自动赌石次数。0表示服务器控制
end

--甄选操作成功通知
function GambleManager:pickSuccessNotify(event)
	hideLoading()
end

--拾取操作成功通知
function GambleManager:pickupSuccessNotify(event)
	hideLoading()
	local data = event.data
	local index = data.index
	if index == 0 then
		itemArray:clear()
	else
		itemArray:removeObjectAt(index)
	end

	TFDirector:dispatchGlobalEventWith(GambleManager.ItemChange,{0})
end
--一键合成操作成功通知
function GambleManager:mergeAutoSuccessNotify(event)
	hideLoading()
end



--[[
//赌石结果条目详情，单独发送为新增条目
// code = 0x5805
message GamblingItemDetails
{
	required int32 index = 1;			//索引，1~N
	required int32 resType = 2;			//资源类型
	required int32 resId = 3;			//资源ID
	required int32 resNum = 4;			//资源数量
	required int64 createTime = 5;		//创建时间，单位/秒
	required int64 lastUpdate = 6;		//最后更新时间,单位/秒
}
]]
--赌石结果条目详情，单独发送为新增条目
function GambleManager:gamblingItemDetails(event)
	hideLoading()
	local data = event.data
	local index = data.index
	local info = itemArray:getObjectAt(index)
	if info == nil then
		itemArray:push(data)
	else
		info = data
	end
	TFDirector:dispatchGlobalEventWith(GambleManager.ItemChange,{1})
end

--赌石结果条目详情，单独发送为新增条目
function GambleManager:gamblingItemCacheList(event)
	hideLoading()
	local data = event.data
	local num = itemArray:length()
	itemArray:clear()
	if data.item then
		for i=1,#data.item do
			local info = data.item[i]
			itemArray:push(info)
		end
	end
	num = itemArray:length() - num
	num = math.max(0,num)
	TFDirector:dispatchGlobalEventWith(GambleManager.ItemChange,{num})
end

--赌石状态详情
function GambleManager:gamblingStateDetails(event)
	hideLoading()
	local data = event.data
	self.levelState = data.enableType
	self.betToday = data.betToday
	self.betTotal = data.betTotal
	self.lastUpdate = data.lastUpdate
	TFDirector:dispatchGlobalEventWith(GambleManager.StateChangeMessage,{}); 
end

--赌石状态详情
function GambleManager:openGambleMainLayer()
	AlertManager:addLayerByFile("lua.logic.qiyu.GambleMainLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_0);
	AlertManager:show();
end


return GambleManager:new()
