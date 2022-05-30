--******** 文件说明 ********
-- @Author:      xhj 
-- @description: 回归活动控制类
-- @DateTime:    2019-12-12 17:12:17
-- *******************************
ReturnActionController = ReturnActionController or BaseClass(BaseController)
local const_data = Config.HolidayReturnNewData.data_constant
function ReturnActionController:config()
    self.model = ReturnActionModel.New(self)
    self.dispather = GlobalEvent:getInstance()

    self.action_status_list = {} --红点
end

function ReturnActionController:getModel()
    return self.model
end

function ReturnActionController:registerEvents()
	if self.init_role_event == nil then
		self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
			GlobalEvent:getInstance():UnBind(self.init_role_event)
			self.init_role_event = nil
			self:sender27902()
			self.role_vo = RoleController:getInstance():getRoleVo()
            if self.role_update_event == nil and self.role_vo then
                self.role_update_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                    if key == "lev" then
                    	if self.model and self.model:getActionIsOpen() == 1 then
	                        self:sender27902()
	                    end
                    end
                end)
            end
		end)
	end

	if not self.close_item_event then
        self.close_item_event = GlobalEvent:getInstance():Bind(MainuiEvent.CLOSE_ITEM_VIEW, function(data)
            if self.red_bag_cache_data and next(self.red_bag_cache_data) ~= nil then
                self:openReturnRedbagInfoWindow(true, self.red_bag_cache_data)
                self.red_bag_cache_data = nil
            end
        end)
	end
end


function ReturnActionController:initProto()
	self:sender27900()
	self:sender27905()
	self:sender27908()
	self:sender27903()
end

function ReturnActionController:registerProtocals()
	self:RegisterProtocal(27900, "handle27900") -- 回归礼包信息
	self:RegisterProtocal(27901, "handle27901") -- 领取回归礼包
	self:RegisterProtocal(27902, "handle27902") -- 回归基础信息
	self:RegisterProtocal(27903, "handle27903") -- 回归抽奖信息
	self:RegisterProtocal(27904, "handle27904") -- 抽奖
	self:RegisterProtocal(27905, "handle27905") -- 回归任务信息
	self:RegisterProtocal(27906, "handle27906") -- 推送任务变化
	self:RegisterProtocal(27907, "handle27907") -- 任务奖励领取
	self:RegisterProtocal(27908, "handle27908") -- 回归签到信息
	self:RegisterProtocal(27909, "handle27909") -- 领取回归签到奖励
	self:RegisterProtocal(27910, "handle27910") -- (刷新)红包界面信息
	self:RegisterProtocal(27911, "handle27911") -- 领取/查看红包
	self:RegisterProtocal(27912, "handle27912") -- 是否有红包可领
	self:RegisterProtocal(27913, "handle27913") -- 红包传闻信息
	self:RegisterProtocal(27914, "handle27914") -- 回归商店信息
	self:RegisterProtocal(27915, "handle27915") -- 回归商店购买
	self:RegisterProtocal(27916, "handle27916") -- 使用红包道具飘字
end

--回归礼包信息
function ReturnActionController:sender27900()
    self:SendProtocal(27900,{})
end
function ReturnActionController:handle27900(data)
	self.model:setActionGiftData(data)
	self.dispather:Fire(ReturnActionEvent.Gift_Data_Event)
end

--领取回归礼包
function ReturnActionController:sender27901()
    self:SendProtocal(27901,{})
end
function ReturnActionController:handle27901(data)
	message(data.msg)
end

--回归基础信息
function ReturnActionController:sender27902()
    self:SendProtocal(27902,{})
end
function ReturnActionController:handle27902(data)
	self.model:setActionPeriod(data.period)
	self.model:setActionDay(data.open_day)
	self.model:setActionIsOpen(data.is_open)
	if data.is_open == 1 then
		self:initProto()
	end
end

--回归抽奖信息
function ReturnActionController:sender27903()
    self:SendProtocal(27903,{})
end
function ReturnActionController:handle27903(data)
	self.model:setActionSummonData(data)
	self.dispather:Fire(ReturnActionEvent.Summon_Data_Event,data)
end

--抽奖
function ReturnActionController:sender27904(type)
	local proto = {}
	proto.type = type
    self:SendProtocal(27904,proto)
end

function ReturnActionController:handle27904(data)
	message(data.msg)
end

--回归任务信息
function ReturnActionController:sender27905()
	local proto = {}
    self:SendProtocal(27905,proto)
end

function ReturnActionController:handle27905(data)
	self.model:setActionTaskData(data)
	self.dispather:Fire(ReturnActionEvent.Task_Event,data)
end

--推送任务变化
function ReturnActionController:sender27906()
    self:SendProtocal(27906,{})
end

function ReturnActionController:handle27906(data)
	self.model:updateActionTaskData(data)
	self.dispather:Fire(ReturnActionEvent.Task_Updata_Event)
end

--任务奖励领取
function ReturnActionController:sender27907(id)
	local proto = {}
	proto.id = id
    self:SendProtocal(27907,proto)
end

function ReturnActionController:handle27907(data)
	message(data.msg)
	if data and data.code == 1 then
		self.model:updateActionTaskDataById(data)
		self.dispather:Fire(ReturnActionEvent.Limin_Task_Event,data)	
	end
end

--回归签到信息
function ReturnActionController:sender27908()
	local protocal = {}
	self:SendProtocal(27908, protocal)
end

function ReturnActionController:handle27908(data)
	self.model:setServerSignData(data)
	self.dispather:Fire(ReturnActionEvent.Sign_Event,data)
end

--领取回归签到奖励
function ReturnActionController:sender27909(day)
	local protocal = {}
	protocal.day = day
	self:SendProtocal(27909, protocal)
end

function ReturnActionController:handle27909(data)
	message(data.msg)
	if data and data.code == 1 then
		self.model:updataServerSignData(data)
	end
end

--(刷新)红包界面信息
function ReturnActionController:sender27910()
	local protocal = {}
	self:SendProtocal(27910, protocal)
end

function ReturnActionController:handle27910(data)
	self.model:setReturnRedbagData(data)
	self.dispather:Fire(ReturnActionEvent.Get_Redbag_Data_Event)
end

-- 领取红包(查看已领取的红包也走这条协议，并且会返回code=1,code为0会请求刷新红包列表)
function ReturnActionController:sender27911( red_packet_id )
	local protocal = {}
    protocal.red_packet_id = red_packet_id
    self:SendProtocal(27911, protocal)
end

function ReturnActionController:handle27911( data )
	if data.msg then
		message(data.msg)
	end
	if data.code == 0 then -- 领取失败，请求刷新红包界面
		self:sender27910()
	end
	if data.get_red_packet_list and next(data.get_red_packet_list) ~= nil then
		-- 获得物品界面正在显示，先缓存数据，关闭获得物品界面后再打开
		if MainuiController:getInstance():itemExhibitionIsOpen() == false then
			self.red_bag_cache_data = data
		else
			self:openReturnRedbagInfoWindow(true, data)
		end
	end
end

-- 主界面红包显示状态（纯后端推）
function ReturnActionController:handle27912( data )
	self.model:setReturnRedbagNumData(data)
	if data.code then
		self.dispather:Fire(ReturnActionEvent.Update_Return_Main_Redbag_Event, data.code)
	end
end

-- 红包传闻
function ReturnActionController:sender27913(  )
	self:SendProtocal(27913, {})
end

function ReturnActionController:handle27913( data )
	if data.get_red_packet_list then
		self.dispather:Fire(ReturnActionEvent.Get_Redbag_Msg_Data_Event, data.get_red_packet_list)
	end
end

-- 回归商店信息
function ReturnActionController:sender27914(  )
	self:SendProtocal(27914, {})
end

function ReturnActionController:handle27914( data )
	self.model:setServerShopData(data)
	self.dispather:Fire(ReturnActionEvent.Shop_Event,data)
end

-- 回归商店购买
function ReturnActionController:sender27915( id )
	local protocal = {}
	protocal.id = id
	self:SendProtocal(27915, protocal)
end

function ReturnActionController:handle27915( data )
	message(data.msg)
end

-- 使用红包道具飘字
function ReturnActionController:sender27916( )
	local protocal = {}
	self:SendProtocal(27916, protocal)
end

function ReturnActionController:handle27916( data )
	message(data.msg)
end

---------------------------------------

--打开或关闭回归活动界面
function ReturnActionController:openReturnActionMainPanel(status, action_bid)
	if status == false then
		if self.return_action_view ~= nil then
			self.return_action_view:close()
			self.return_action_view = nil
		end
	else
		if self.return_action_view == nil then
			self.return_action_view = ReturnActionMainWindow.New()
		end
		if self.return_action_view:isOpen() == false then
			self.return_action_view:open(action_bid)
		end
	end
end

-- 打开奖励预览 text_elite:内容描述类型
function ReturnActionController:openReturnActionSummonAwardView( status, period, data,text_elite )
	if status == true then
		if self.summon_award_view == nil then
			self.summon_award_view = ReturnActionSummonAwardView.New()
		end
		if self.summon_award_view:isOpen() == false then
			self.summon_award_view:open(period, data,text_elite)
		end
	else
		if self.summon_award_view then
			self.summon_award_view:close()
			self.summon_award_view = nil
		end
	end
end

-- 回归红包界面
function ReturnActionController:openReturnRedbagWindow( status )
	if status == true then
		if not self.petard_redbag_wnd then
			self.petard_redbag_wnd = ReturnActionRedbagWindow.New()
		end
		if self.petard_redbag_wnd:isOpen() == false then
			self.petard_redbag_wnd:open()
		end
	else
		if self.petard_redbag_wnd then
			self.petard_redbag_wnd:close()
			self.petard_redbag_wnd = nil
		end
	end
end

-- 回归单个红包信息界面
function ReturnActionController:openReturnRedbagInfoWindow( status, data )
	if status == true then
		if not self.redbag_info_wnd then
			self.redbag_info_wnd = ReturnActionRedbagInfoWindow.New()
		end
		if self.redbag_info_wnd:isOpen() == false then
			self.redbag_info_wnd:open(data)
		end
	else
		if self.redbag_info_wnd then
			self.redbag_info_wnd:close()
			self.redbag_info_wnd = nil
		end
		self.red_bag_cache_data = nil -- 清一下缓存数据
	end
end

--判断红点
function ReturnActionController:setReturnActionTabStatus(bid, status)
	local is_open = self.model:returnActionIsOpen()
 	if is_open then
		local num = 0
	    if status then 
	        num = 1
	    end
	    local vo = {
	        bid = bid,
	        num = num
	    }
		MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.return_action, vo)

		if self.action_status_list == nil then
            self.action_status_list = {}
        end
		local vo1 = {
            bid = bid,
            status = status
        }
        self.action_status_list[bid] = vo1
        self.dispather:Fire(ReturnActionEvent.RedPoint_Event, vo1)
	end
end
function ReturnActionController:getRedPointStatusData(bid)
	if self.action_status_list and self.action_status_list[bid] then
		return self.action_status_list[bid]
	end
	return nil
end


function ReturnActionController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end