-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-12-06
-- --------------------------------------------------------------------
VoyageController = VoyageController or BaseClass(BaseController)

function VoyageController:config()
    self.model = VoyageModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function VoyageController:getModel()
    return self.model
end

function VoyageController:registerEvents()
	--[[if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.init_role_event = nil

            -- 上线时请求
            local lev_config = Config.ShippingData.data_const["guild_lev"]
            local role_vo = RoleController:getInstance():getRoleVo()
            if lev_config and lev_config.val <= role_vo.lev then
            	self:requestVoyageInfo()
            	self:requestActivityStatus()
            end
        end)
    end--]]

    -- 断线重连的时候
    --[[if self.re_link_game_event == nil then
        self.re_link_game_event = GlobalEvent:getInstance():Bind(LoginEvent.RE_LINK_GAME, function()
            local lev_config = Config.ShippingData.data_const["guild_lev"]
            local role_vo = RoleController:getInstance():getRoleVo()
            if lev_config and lev_config.val <= role_vo.lev then
            	self:requestVoyageInfo()
            	self:requestActivityStatus()
            end
        end)
    end--]]
end

------------------@ c2s
-- 请求远航数据
function VoyageController:requestVoyageInfo(  )
	self:SendProtocal(23800, {})
end

-- 请求接取订单
function VoyageController:requestReceiveOrder( order_id, assign_ids )
	local protocal = {}
    protocal.order_id = order_id
    protocal.assign_ids = assign_ids
    self:SendProtocal(23802, protocal)
end

-- 请求完成订单
function VoyageController:requestFinishOrder( order_id, type )
	local protocal = {}
    protocal.order_id = order_id
    protocal.type = type
    self:SendProtocal(23803, protocal)
end

-- 请求刷新
function VoyageController:requestRefreshOrder(  )
	self.request_flag = true -- 标记刷新请求是否已经返回
	self:SendProtocal(23804, {})
end

-- 请求远航活动状态
function VoyageController:requestActivityStatus(  )
	local protocal = {}
    self:SendProtocal(23805, protocal)
end

-- 请求一键领取
function VoyageController:requestQuickReceiveOrder(  )
	self:SendProtocal(23806, {})
end

------------------@ s2c
function VoyageController:registerProtocals()
	self:RegisterProtocal(23800, "handle23800")     -- 远航数据（订单、刷新次数等）
	self:RegisterProtocal(23801, "handle23801")     -- 远航订单数据
	self:RegisterProtocal(23802, "handle23802")     -- 远航接取订单
	self:RegisterProtocal(23803, "handle23803")     -- 远航完成订单
	self:RegisterProtocal(23804, "handle23804")     -- 远航刷新订单
	self:RegisterProtocal(23805, "handle23805")     -- 远航活动状态
	self:RegisterProtocal(23806, "handle23806")     -- 一键领取
end

-- 远航数据（订单、刷新次数等）
function VoyageController:handle23800( data )
	if data.order_list then
		self.model:setOrderList(data.order_list)
	end
	if data.free_times then
		self.model:setFreeTimes(data.free_times)
	end
	if data.coin_times then
		self.model:setCoinTimes(data.coin_times)
	end
	GlobalEvent:getInstance():Fire(VoyageEvent.UpdateVoyageDataEvent)
	GlobalEvent:getInstance():Fire(VoyageEvent.UpdateVoyageRedEvent)
end

-- 远航订单数据更新
function VoyageController:handle23801( data )
	if data then
		self.model:updateOneOrderData(data)
		GlobalEvent:getInstance():Fire(VoyageEvent.UpdateVoyageRedEvent)
	end
end

-- 接取订单返回
function VoyageController:handle23802( data )
	message(data.msg)
	if data.flag == TRUE then
		self:openVoyageDispatchWindow(false)
	end
end

-- 完成订单返回
function VoyageController:handle23803( data )
	message(data.msg)
	if data.flag == TRUE and data.order_id then
		self.model:deleteOneOrderData(data.order_id)
		GlobalEvent:getInstance():Fire(VoyageEvent.DeleteOrderDataEvent)
		GlobalEvent:getInstance():Fire(VoyageEvent.UpdateVoyageRedEvent)
	end
end

-- 刷新订单返回
function VoyageController:handle23804( data )
	message(data.msg)
	self.request_flag = false -- 标记刷新请求是否已经返回
end

-- 刷新订单请求数据是否已经返回(防止快速点击刷新按钮)
function VoyageController:checkRefreshReqIsBack(  )
	if not self.request_flag then
		return true
	end
	return false
end

-- 远航活动状态
function VoyageController:handle23805( data )
	if data.flag then
		self.model:setActivityStatus(data.flag)
		GlobalEvent:getInstance():Fire(VoyageEvent.UpdateActivityStatusEvent)
	end
end

-- 一键领取
function VoyageController:handle23806( data )
	if data.msg then
		message(data.msg)
	end
	if data.flag == TRUE then
		self.model:deleteSomeOrderData(data.order_list)
		GlobalEvent:getInstance():Fire(VoyageEvent.DeleteOrderDataEvent)
		GlobalEvent:getInstance():Fire(VoyageEvent.UpdateVoyageRedEvent)
	end
end

--------------------------@ 界面相关
-- 打开远航主界面
function VoyageController:openVoyageMainWindow( status, not_tips )
	if status == true then
		if not self:checkVoyageIsOpen(not_tips) then
			return
		end
		-- 打开界面的时候，把刷新协议返回标识重置(避免万一协议没返回，就一直无法刷新)
		self.request_flag = false

		if not self.voyage_main_window then
			self.voyage_main_window = VoyageMainWindow.New()
		end
		if self.voyage_main_window:isOpen() == false then
			self.voyage_main_window:open()
		end
	else
		if self.voyage_main_window then
			self.voyage_main_window:close()
			self.voyage_main_window = nil
		end
	end
end

-- 引导需要
function VoyageController:getVoyageMainRoot(  )
	if self.voyage_main_window then
		return self.voyage_main_window.root_wnd
	end
end

-- 打开远航派遣界面
function VoyageController:openVoyageDispatchWindow( status, data )
	if status == true then
		if not self.voyage_dispatch_window then
			self.voyage_dispatch_window = VoyageDispatchWindow.New()
		end
		if self.voyage_dispatch_window:isOpen() == false then
			self.voyage_dispatch_window:open(data)
		end
	else
		if self.voyage_dispatch_window then
			self.voyage_dispatch_window:close()
			self.voyage_dispatch_window = nil
		end
	end
end

-- 引导需要
function VoyageController:getVoyageDispatchRoot(  )
	if self.voyage_dispatch_window then
		return self.voyage_dispatch_window.root_wnd
	end
end

-- 远航是否开启
function VoyageController:checkVoyageIsOpen( not_tips )
	local is_open = false
	local lev_config = Config.ShippingData.data_const["guild_lev"]
    local role_vo = RoleController:getInstance():getRoleVo()
    if lev_config and lev_config.val <= role_vo.lev then
    	is_open = true
    elseif not not_tips then
    	message(lev_config.desc)
    end
    return is_open
end

function VoyageController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end