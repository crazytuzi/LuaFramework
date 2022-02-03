--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-12-06 17:35:00
-- @description    : 
		-- 远航订单item
---------------------------------
VoyageOrderItem = class("VoyageOrderItem", function()
    return ccui.Widget:create()
end)

local controller = VoyageController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local string_format = string.format

function VoyageOrderItem:ctor()
	self:configUI()
	self:register_event()
end

function VoyageOrderItem:configUI(  )
	self.size = cc.size(631, 171)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("voyage/voyage_order_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    self.rarity_image = container:getChildByName("rarity_image")
    self.order_name = container:getChildByName("order_name")

    self.get_btn = container:getChildByName("get_btn")
    local btn_size = self.get_btn:getContentSize()
    self.get_btn_label = createRichLabel(26, 1, cc.p(0.5, 0.5), cc.p(btn_size.width/2, btn_size.height/2))
    self.get_btn:addChild(self.get_btn_label)

    self.progress_bg = container:getChildByName("progress_bg")
    self.progress = self.progress_bg:getChildByName("progress")
    self.progress:setScale9Enabled(true)
    self.progress_value = self.progress_bg:getChildByName("progress_value")
    self.progress_bg:setVisible(false)

    local goods_list = container:getChildByName("goods_list")
    local bgSize = goods_list:getContentSize()
	local scroll_view_size = cc.size(bgSize.width, bgSize.height)
	local scale = 0.7
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 20,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*scale,               -- 单元的尺寸width
        item_height = BackPackItem.Height*scale,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
    	scale = scale
    }
    self.good_scrollview = CommonScrollViewLayout.new(goods_list, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.good_scrollview:setSwallowTouches(false)
end

function VoyageOrderItem:register_event(  )
	registerButtonEventListener(self.get_btn, handler(self, self._onClickGetBtn), true)
end

function VoyageOrderItem:_onClickGetBtn( param, sender, event_type )
	if self.data then
		if self.data.status == VoyageConst.Order_Status.Unget then
			controller:openVoyageDispatchWindow(true, self.data)
		elseif self.data.status == VoyageConst.Order_Status.Underway then
			controller:requestFinishOrder(self.data.order_id, 1)
		elseif self.data.status == VoyageConst.Order_Status.Finish then
			controller:requestFinishOrder(self.data.order_id, 0)
		end
		-- 引导需要
		if sender.guide_call_back ~= nil then
			sender.guide_call_back(sender)
		end
	end
end

function VoyageOrderItem:setData( data )
	if self.data ~= nil then
        if self.update_self_event ~= nil then
            self.data:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
    end

    if self.update_price_event ~= nil then
    	GlobalEvent:getInstance():UnBind(self.update_price_event)
        self.update_price_event = nil
    end

    -- 远航活动开启/关闭时价格刷新
    if self.update_price_event == nil then
    	self.update_price_event = GlobalEvent:getInstance():Bind(VoyageEvent.UpdateActivityStatusEvent, function (  )
    		self:refreshOrderBtnStatus()
    	end)
    end

	if data ~= nil then
		self.data = data
        if self.update_self_event == nil then
            self.update_self_event = self.data:Bind(VoyageEvent.UpdateOrderDataEvent, function()
                self:refreshOrderInfo()
            end)
        end
        self:refreshOrderInfo()
	end
end

function VoyageOrderItem:refreshOrderInfo(  )
	if not self.data then return end

	local config = self.data.config
	if not config or next(config) == nil then return end
	self.config = config
	-- 稀有度背景
	local rarity_res = PathTool.getResFrame("voyage", VoyageConst.Order_Rarity_Res[config.quality])
	self.rarity_image:loadTexture(rarity_res, LOADTEXT_TYPE_PLIST)
	self.rarity_image:setCapInsets(cc.rect(15, 15, 1, 5))

	self.order_name:setString(config.name)
	self.order_name:enableOutline(VoyageConst.Order_Rarity_Color[config.quality], 2)

	-- 奖励
	local award_data = {}
	for i,v in ipairs(config.award) do
		local bid = v[1]
		local num = v[2]
		local vo = deepCopy(Config.ItemData.data_get_data(bid))
        vo.quantity = num
        table_insert(award_data, vo)
	end
	self.good_scrollview:setData(award_data)
	self.good_scrollview:addEndCallBack(function ()
		local list = self.good_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
        end
	end)

	-- 引导需要
	if self.get_btn and self.data.index then
		self.get_btn:setName("get_btn_" .. self.data.index)
	end
	self:refreshOrderBtnStatus()
end

-- 刷新按钮状态显示
function VoyageOrderItem:refreshOrderBtnStatus(  )
	if self.data.status == VoyageConst.Order_Status.Unget then
		if not self.expend_label then
			self.expend_label = createRichLabel(24, cc.c3b(158,80,27), cc.p(0.5, 0.5), cc.p(530, 120))
			self.container:addChild(self.expend_label)
		end
		local expend = self.config.expend[1]
		if expend then
			local bid = expend[1]
			local num = expend[2]
			local item_config = Config.ItemData.data_get_data(bid)
			local res = PathTool.getItemRes(item_config.icon)
			if model:getActivityStatus() == 1 then
				local discount_cfg = Config.ShippingData.data_const["discount"]
				if discount_cfg then
					num = num * discount_cfg.val/1000
				end
			end
			self.expend_label:setString(string_format(TI18N("消耗: <img src='%s' scale=0.5 /> %d"), res, num))
		end
		self.get_btn_label:setString(TI18N("<div fontcolor=#ffffff outline=2,#294a15>接取</div>"))
		self.get_btn:loadTexture(PathTool.getResFrame("common", "common_1098"), LOADTEXT_TYPE_PLIST)
        self.get_btn:setCapInsets(cc.rect(11, 11, 28, 1))
		
		self:openOrderTimer(false)
		self.expend_label:setVisible(true)
		self.progress_bg:setVisible(false)
	elseif self.data.status == VoyageConst.Order_Status.Underway then
		self.get_btn:loadTexture(PathTool.getResFrame("common", "common_1098"), LOADTEXT_TYPE_PLIST)
        self.get_btn:setCapInsets(cc.rect(11, 11, 28, 1))
		local cur_time = GameNet:getInstance():getTime()
		self.left_time = self.data.end_time - cur_time
		if self.left_time < 0 then self.left_time = 0 end
		local gold_num = model:getQuickFinishNeedGoldByTime(self.left_time)
		self.get_btn_label:setString(string_format(TI18N("<img src='%s' scale=0.3 /><div fontcolor=#ffffff outline=2,#294a15>%d 加速</div>"), PathTool.getItemRes(3), gold_num))

		-- 进度
		local percent = 100 - (self.left_time/self.config.need_time)*100
		self.progress:setPercent(percent)
		self.progress_value:setString(TimeTool.GetTimeFormat(self.left_time))

		self:openOrderTimer(true)
		-- 只有未领取,转到领取的时候拨一下特效
		if self.data.old_status == VoyageConst.Order_Status.Unget then
			self.data.old_status = self.data.status
			self:handleEffect(true)
		end
		if self.expend_label then
			self.expend_label:setVisible(false)
		end
		self.progress_bg:setVisible(true)
	elseif self.data.status == VoyageConst.Order_Status.Finish then
		self.get_btn_label:setString(TI18N("<div fontcolor=#ffffff outline=2,#764519>完成</div>"))
		self.get_btn:loadTexture(PathTool.getResFrame("common", "common_1027"), LOADTEXT_TYPE_PLIST)
        self.get_btn:setCapInsets(cc.rect(11, 11, 28, 1))
		self.progress:setPercent(100)
		self.progress_value:setString(TI18N("完成"))

		self:openOrderTimer(false)
		if self.expend_label then
			self.expend_label:setVisible(false)
		end
		self.progress_bg:setVisible(true)
	end
end

-- 剩余时间定时器
function VoyageOrderItem:openOrderTimer( status )
	if status == true then
		if self.order_timer == nil then
			self.order_timer = GlobalTimeTicket:getInstance():add(function ()
				self.left_time = self.left_time - 1
				if self.left_time >= 0 then
					local percent = 100 - (self.left_time/self.config.need_time)*100
					self.progress:setPercent(percent)
					self.progress_value:setString(TimeTool.GetTimeFormat(self.left_time))
				else
					self.progress:setPercent(100)
					self.progress_value:setString(TI18N("完成"))
					GlobalTimeTicket:getInstance():remove(self.order_timer)
            		self.order_timer = nil
				end
			end, 1)
		end
	else
		if self.order_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.order_timer)
            self.order_timer = nil
        end
	end
end

function VoyageOrderItem:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
		if not tolua.isnull(self.container) and self.play_effect == nil then
			local container_size = self.container:getContentSize()
			self.play_effect = createEffectSpine(PathTool.getEffectRes(629), cc.p(container_size.width * 0.5, container_size.height * 0.5), cc.p(0.5, 0.5), false, PlayerAction.action)
			self.container:addChild(self.play_effect, 1)
		elseif self.play_effect then
			self.play_effect:setToSetupPose()
			self.play_effect:setAnimation(0, PlayerAction.action, false)
		end
	end
end

function VoyageOrderItem:suspendAllActions()
    if self.data ~= nil then
        if self.update_self_event ~= nil then
            self.data:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
        self.data = nil
    end
    if self.update_price_event ~= nil then
    	GlobalEvent:getInstance():UnBind(self.update_price_event)
        self.update_price_event = nil
    end
    self:openOrderTimer(false)
    self:handleEffect(false)
end

function VoyageOrderItem:DeleteMe(  )
	if self.good_scrollview then
		self.good_scrollview:DeleteMe()
		self.good_scrollview = nil
	end
	if self.data ~= nil then
        if self.update_self_event ~= nil then
            self.data:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
        self.data = nil
    end
    if self.update_price_event ~= nil then
    	GlobalEvent:getInstance():UnBind(self.update_price_event)
        self.update_price_event = nil
    end
    self:handleEffect(false)
    self:openOrderTimer(false)
	self:removeAllChildren()
	self:removeFromParent()
end