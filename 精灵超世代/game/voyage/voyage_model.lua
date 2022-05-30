-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-12-06
-- --------------------------------------------------------------------
VoyageModel = VoyageModel or BaseClass()

local table_insert = table.insert

function VoyageModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function VoyageModel:config()
	self.order_list = {}  -- 全部订单数据
	self.free_times = 0   -- 今日已经免费刷新次数
	self.coin_times = 0   -- 今日已经钻石刷新次数
end

-- 设置所有订单数据
function VoyageModel:setOrderList( data )
	self.order_list = {}
	for k,oData in pairs(data) do
		local order_vo = VoyageOrderVo.New()
		order_vo:updateData(oData)
		table_insert(self.order_list, order_vo)
	end
end

-- 获取所有订单数据
function VoyageModel:getAllOrderList(  )
	return self.order_list
end

-- 刷新某一订单数据
function VoyageModel:updateOneOrderData( data )
	for k,order_vo in pairs(self.order_list) do
		if order_vo.order_id == data.order_id then
			order_vo:updateData(data)
			break
		end
	end
end

-- 删除某一订单数据
function VoyageModel:deleteOneOrderData( order_id )
	for k,order_vo in pairs(self.order_list) do
		if order_vo.order_id == order_id then
			table.remove(self.order_list, k)
			break
		end
	end
end

-- 删除一些订单
function VoyageModel:deleteSomeOrderData( order_id_list )
	for i=#self.order_list,1,-1 do
		local order_vo = self.order_list[i]
		for k,v in pairs(order_id_list) do
			if v.order_id == order_vo.order_id then
				table.remove(self.order_list, i)
				break
			end
		end
	end
end

function VoyageModel:setFreeTimes( times )
	self.free_times = times
end
-- 获取今日已经免费刷新次数
function VoyageModel:getFreeTimes(  )
	return self.free_times
end

function VoyageModel:setCoinTimes( times )
	self.coin_times = times
end
-- 获取今日已经钻石刷新次数
function VoyageModel:getCoinTimes(  )
	return self.coin_times
end

-- 订单中是否有紫色（史诗）品质及以上的订单并且未接取
function VoyageModel:checkIsHaveHigherEpicOrder(  )
	local is_have = false
	for k,order_vo in pairs(self.order_list) do
		if order_vo.status == VoyageConst.Order_Status.Unget and order_vo.config and order_vo.config.quality >= VoyageConst.Order_Rarity.Epic then
			is_have = true
			break
		end
	end
	return is_have
end

-- 根据宝可梦id判断是否为任务中
function VoyageModel:checkHeroIsInTaskById( id )
	local is_in = false
	for k,order_vo in pairs(self.order_list) do
		if order_vo.assign_ids then
			for _,assign in pairs(order_vo.assign_ids) do
				if assign.partner_id and assign.partner_id == id then
					is_in = true
					break
				end
			end
		end
		if is_in then
			break
		end
	end
	return is_in
end

-- 根据订单剩余时间获取加速所需钻石数量
function VoyageModel:getQuickFinishNeedGoldByTime( lefttime )
	local gold_num = 0
	for k,config in pairs(Config.ShippingData.data_quick_cost) do
		if lefttime >= config.min and lefttime <= config.max then
			gold_num = config.gold
		end
	end
	return gold_num
end

-- 是否有订单缓存数据
function VoyageModel:checkIsHaveOrderData(  )
	return (next(self.order_list)~=nil)
end

-- 是否显示红点(是否有已完成的订单任务)
function VoyageModel:checkVoyageRedStatus(  )
	local is_show_red = false
	for k,order_vo in pairs(self.order_list) do
		if order_vo.status == VoyageConst.Order_Status.Finish then
			is_show_red = true
			break
		end
	end
	return is_show_red
end

-- 远航活动状态
function VoyageModel:setActivityStatus( status )
	self.activity_status = status
end

function VoyageModel:getActivityStatus(  )
	return self.activity_status or 0
end

function VoyageModel:__delete()
end