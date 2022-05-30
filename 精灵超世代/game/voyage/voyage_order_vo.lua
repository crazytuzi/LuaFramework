--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-12-06 16:53:42
-- @description    : 
		-- 远航订单数据
---------------------------------

VoyageOrderVo = VoyageOrderVo or BaseClass(EventDispatcher)

function VoyageOrderVo:__init(  )
	self.order_id = 0 	-- 订单唯一id
	self.order_bid = 0 	-- 订单bid
	self.status = VoyageConst.Order_Status.Finish  -- 订单状态
	self.end_time = 0 	-- 订单结束时间（接取后生效）
	self.assign_ids = {} -- 订单派遣的宝可梦id列表
	self.config = {} 	-- 订单配置表数据
	self.old_status = 0
end

function VoyageOrderVo:updateData( data )
	self.old_status = self.status
	for key, value in pairs(data) do
        self[key] = value
        if key == "order_bid" then
        	self.config = Config.ShippingData.data_order[value] or {}
        end
    end 
    self:dispatchUpdateAttrByKey()
end

function VoyageOrderVo:dispatchUpdateAttrByKey()
    self:Fire(VoyageEvent.UpdateOrderDataEvent) 
end

function VoyageOrderVo:__delete(  )
	
end