--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-12-06 15:13:41
-- @description    : 
		-- 远航商人主界面
---------------------------------
VoyageMainWindow = VoyageMainWindow or BaseClass(BaseView)

local controller = VoyageController:getInstance()
local model = controller:getModel()
local table_sort = table.sort

function VoyageMainWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "voyage/voyage_main_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("voyage", "voyage"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg","txt_cn_bigbg_22"), type = ResourcesType.single },
	}

	self.role_vo = RoleController:getInstance():getRoleVo()
	self.order_data = {}
end

function VoyageMainWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
	self:playEnterAnimatianByObj(main_container, 1)
	local win_title = main_container:getChildByName("win_title")
	win_title:setString(TI18N("远航商人"))
	-- local close_tips = main_container:getChildByName("close_tips")
	-- close_tips:setString(TI18N("点击空白区域关闭窗口"))

	self.refresh_btn = main_container:getChildByName("refresh_btn")
	local refresh_btn_size = self.refresh_btn:getContentSize()
	self.refresh_btn_label = createRichLabel(22, 1, cc.p(0.5, 0.5), cc.p(refresh_btn_size.width/2, refresh_btn_size.height/2))
	self.refresh_btn:addChild(self.refresh_btn_label)

	self.special_btn = main_container:getChildByName("special_btn")
	self.special_btn:getChildByName("label"):setString(TI18N("派遣特权"))
	self.explain_btn = main_container:getChildByName("explain_btn")
	self.receive_btn = main_container:getChildByName("receive_btn")
	self.receive_btn:getChildByName("label"):setString(TI18N("一键领取"))

	self.progress = main_container:getChildByName("progress")
	self.progress:setScale9Enabled(true)
	self.progress:setPercent(0)
	self.progress_value = main_container:getChildByName("progress_value")

	self.no_order_image = main_container:getChildByName("no_order_image")
	self.no_order_image:getChildByName("label"):setString(TI18N("刷新获取新的订单"))

	-- 刷新道具消耗
	local cost_config = Config.ShippingData.data_const["refresh_cost"]
	self.cost_item_bid = cost_config.val[1][1]
	self.cost_item_num = cost_config.val[1][2]
	self.item_count = main_container:getChildByName("item_count")
	local item_icon = main_container:getChildByName("item_icon")
	local item_config = Config.ItemData.data_get_data(self.cost_item_bid)
	loadSpriteTexture(item_icon, PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
	item_icon:setScale(0.6)

	local order_list = main_container:getChildByName("order_list")
	local bgSize = order_list:getContentSize()
	local scroll_view_size = cc.size(bgSize.width, bgSize.height-10)
    local setting = {
        --item_class = VoyageOrderItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 8,                   -- y方向的间隔
        item_width = 614,               -- 单元的尺寸width
        item_height = 137,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.order_scrollview = CommonScrollViewSingleLayout.new(order_list, cc.p(0,5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.order_scrollview:setSwallowTouches(false)

    self.order_scrollview:registerScriptHandlerSingle(handler(self,self._createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.order_scrollview:registerScriptHandlerSingle(handler(self,self._numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.order_scrollview:registerScriptHandlerSingle(handler(self,self._updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
end

function VoyageMainWindow:_createNewCell(  )
	local cell = VoyageOrderItem.new()
    return cell
end

function VoyageMainWindow:_numberOfCells(  )
	if not self.order_data then return 0 end
    return #self.order_data
end

function VoyageMainWindow:_updateCellByIndex( cell, index )
	if not self.order_data then return end
    cell.index = index
    local cell_data = self.order_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function VoyageMainWindow:register_event(  )
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), false, 2)
	registerButtonEventListener(self.explain_btn, handler(self, self._onClickExplainBtn))
	registerButtonEventListener(self.special_btn, handler(self, self._onClickSpecialBtn), true)
	registerButtonEventListener(self.refresh_btn, handler(self, self._onClickRefreshBtn), true)
	registerButtonEventListener(self.receive_btn, handler(self, self._onClickReceiveBtn), true)
	
	-- 更新所有订单数据
	self:addGlobalEvent(VoyageEvent.UpdateVoyageDataEvent, function ( )
		self:refreshOrderList()
		self:refreshBtnStatus()
	end)

	-- 删除订单
	self:addGlobalEvent(VoyageEvent.DeleteOrderDataEvent, function ( )
		self:refreshOrderList(true)
	end)

	-- 情报值更新
	if self.role_assets_event == nil then
        if self.role_vo == nil then self.role_vo = RoleController:getInstance():getRoleVo() end
        self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
            if key == "energy" then
                self:refreshProgressInfo()
            elseif key == "vip_lev" then
            	self:refreshBtnStatus()
            end
        end)
    end

    -- 刷新道具数量更新
    self:addGlobalEvent(BackpackEvent.ADD_GOODS, function ( bag_code, item_list )
    	if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
        self:checkNeedUpdateItemNum(item_list)
    end)

    self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function ( bag_code, item_list )
    	if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
        self:checkNeedUpdateItemNum(item_list)
    end)

    self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function ( bag_code, item_list )
    	if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
        self:checkNeedUpdateItemNum(item_list)
    end)
end

function VoyageMainWindow:openRootWnd(  )
	-- 判断本地是否有订单缓存数据，没有则请求
	if model:checkIsHaveOrderData() then
		self:refreshOrderList()
		self:refreshBtnStatus()
	else
		controller:requestVoyageInfo()
	end
	
	self:refreshProgressInfo()
	self:refreshItemNum()
	self:updateSpecialEffectStatus()
end

-- 更新所有订单列表
function VoyageMainWindow:refreshOrderList( keep_pos )
	self.order_data = model:getAllOrderList() or {}
	if next(self.order_data) == nil then
		self.no_order_image:setVisible(true)
		self.order_scrollview:reloadData()
	else
		-- 排序规则 已完成>可接取>进行中
		local temp_sort_index = {
			[VoyageConst.Order_Status.Finish] = 1,
			[VoyageConst.Order_Status.Unget] = 2,
			[VoyageConst.Order_Status.Underway] = 3,
		}
		local function sortFunc( objA, objB )
			local sort_index_a = temp_sort_index[objA.status]
			local sort_index_b = temp_sort_index[objB.status]
			-- 引导需要订单号为1的放在最前面
			if objA.order_id == 1 and objA.status == VoyageConst.Order_Status.Unget and objB.order_id ~= 1 then
				return true
			elseif objA.order_id ~= 1 and objB.order_id == 1 and objB.status == VoyageConst.Order_Status.Unget then
				return false
			elseif sort_index_a == sort_index_b then -- 状态一致
				-- 未接取的按照品质排序，已接取和已完成的按照完成时间排序
				if objA.status == VoyageConst.Order_Status.Unget then
					return objA.config.quality > objB.config.quality
				else
					return objA.end_time < objB.end_time
				end
			else
				return sort_index_a < sort_index_b
			end
		end
		table_sort(self.order_data, sortFunc)
		-- 引导需要
		for i,v in ipairs(self.order_data) do
			v.index = i
		end
		self.order_scrollview:reloadData(nil, nil, keep_pos)
		self.no_order_image:setVisible(false)
	end
end

-- 更新刷新按钮状态
function VoyageMainWindow:refreshBtnStatus(  )
	local refresh_config = Config.ShippingData.data_refresh[self.role_vo.vip_lev]
	if not refresh_config then return end
	
	local free_times = model:getFreeTimes()
	local free_count = refresh_config.free_times --免费刷新上限
	if free_times < free_count then
		self.refresh_btn_label:setString(string.format(TI18N("<div fontcolor=#ffffff shadow=0,-2,2,%s>免费刷新</div>"), Config.ColorData.data_new_color_str[2]))
		setChildUnEnabled(false, self.refresh_btn)
		return
	end
	-- 道具
	local count = BackpackController:getInstance():getModel():getItemNumByBid(self.cost_item_bid)
	if count >= self.cost_item_num then
		local item_config = Config.ItemData.data_get_data(self.cost_item_bid)
		local res = PathTool.getItemRes(item_config.icon)
		self.refresh_btn_label:setString(string.format(TI18N("<img src='%s' scale=0.4 /><div fontcolor=#ffffff shadow=0,-2,2,%s>%d %s</div>"), res, Config.ColorData.data_new_color_str[2], self.cost_item_num, TI18N("刷新")))
		setChildUnEnabled(false, self.refresh_btn)
		return
	end
	-- 钻石
	local coin_times = model:getCoinTimes()
	local coin_count = refresh_config.all_times
	if coin_times < coin_count then
		local bid = refresh_config.expend[1][1]
		local num = refresh_config.expend[1][2]
		local item_config = Config.ItemData.data_get_data(bid)
		local res = PathTool.getItemRes(item_config.icon)
		self.refresh_btn_label:setString(string.format(TI18N("<img src='%s' scale=0.3 /><div fontcolor=#ffffff shadow=0,-3,3,%s>%d %s</div>"), res, Config.ColorData.data_new_color_str[2], num, TI18N("刷新")))
		setChildUnEnabled(false, self.refresh_btn)
		return
	end

	self.refresh_btn_label:setString(string.format(TI18N("<div fontcolor=#ffffff shadow=0,-3,3,#854000>%s</div>"), Config.ColorData.data_new_color_str[2], TI18N("刷新")))
	setChildUnEnabled(true, self.refresh_btn)
end

-- 更新冒险情报进度
function VoyageMainWindow:refreshProgressInfo(  )
	if self.role_vo then
		local cur_energy = self.role_vo.energy
		local max_energy = self.role_vo.energy_max
		local percent = (cur_energy/max_energy)*100
		self.progress_value:setString(cur_energy .. "/" .. max_energy)
		self.progress:setPercent(percent)
	end
end

-- 更新刷新道具数量
function VoyageMainWindow:refreshItemNum(  )
	local count = BackpackController:getInstance():getModel():getItemNumByBid(self.cost_item_bid)
	self.item_count:setString(count)
end

function VoyageMainWindow:checkNeedUpdateItemNum( item_list )
	if item_list == nil or next(item_list) == nil then return end
	for k, v in pairs(item_list) do
		if v.config then
			local bid = v.config.id
			if self.cost_item_bid and bid == self.cost_item_bid then
				self:refreshItemNum()
				self:refreshBtnStatus()
				break
			end
		end
	end
end

-- 刷新特效显示状态
function VoyageMainWindow:updateSpecialEffectStatus(  )
	local one_time_pri = RoleController:getInstance():getModel():checkPrivilegeStatus(2)
	local three_time_pri = RoleController:getInstance():getModel():checkPrivilegeStatus(3)
	if one_time_pri or three_time_pri then
		self:handleEffect(true)
	else
		self:handleEffect(false)
	end
end

-- 激活特权特效显示
function VoyageMainWindow:handleEffect( status )
	if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        if not tolua.isnull(self.special_btn) and self.play_effect == nil then
        	local btn_size = self.special_btn:getContentSize()
            self.play_effect = createEffectSpine(PathTool.getEffectRes(628), cc.p(btn_size.width*0.5, btn_size.height*0.5), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.special_btn:addChild(self.play_effect)
        end
    end
end

-------------------@ 点击事件
function VoyageMainWindow:_onClickCloseBtn(  )
	controller:openVoyageMainWindow(false)
end

function VoyageMainWindow:_onClickExplainBtn( param, sender )
	local explain_config = Config.ShippingData.data_explain[1]
	if explain_config then
		local touch_pos = sender:getTouchBeganPosition()
		TipsManager:getInstance():showCommonTips(explain_config.desc, cc.p(touch_pos.x, touch_pos.y-800))
		-- TipsManager:getInstance():showCommonTips(explain_config.desc, sender:getTouchBeganPosition())
	end
end

function VoyageMainWindow:_onClickSpecialBtn( param, sender )
	local one_time_pri = RoleController:getInstance():getModel():checkPrivilegeStatus(2)
	local three_time_pri = RoleController:getInstance():getModel():checkPrivilegeStatus(3)
	local open_status = {one_time_pri, three_time_pri}
	local tips_str = ""
	for i=1,2 do
		local explain_config = Config.ShippingData.data_explain[i+1]
		if explain_config then
			local status = open_status[i]
			local str = explain_config.desc or ""
			if status then
				str = str .. TI18N("<div fontcolor=249003>                                        （已激活）</div>")
			else
				str = str .. TI18N("<div fontcolor=DE3E3E>                                        （未激活）</div>") .. string.format("<div href=xxx fontcolor=249003>%s</div>", TI18N("前往激活"))
			end
			if i == 1 then
				tips_str = str
			else
				tips_str = tips_str .. "<div>\n\n\n</div>" .. str
			end
		end
	end
	local touch_pos = sender:getTouchBeganPosition()
	self.common_tips = TipsManager:getInstance():showCommonTips(tips_str, cc.p(touch_pos.x, touch_pos.y-80))
	self.common_tips.tips_label:addTouchLinkListener(function(type, value, sender, pos, is_click)
		if value == "xxx" then
			TipsManager:getInstance():hideTips()
			self:_onClickGoToActivate()
		end
	end, { "click", "href" })
end

function VoyageMainWindow:_onClickRefreshBtn(  )
	if not controller:checkRefreshReqIsBack() then
		message(TI18N("刷新过快"))
		return
	end
	if model:checkIsHaveHigherEpicOrder() then
		local function fun()
			controller:requestRefreshOrder()
		end
		local str = string.format(TI18N("有紫色以上的远航任务未接取，是否继续？"))
		CommonAlert.show(str,TI18N("确定"),fun,TI18N("取消"),nil,CommonAlert.type.common)
	else
		controller:requestRefreshOrder()
	end
end

function VoyageMainWindow:_onClickReceiveBtn(  )
	controller:requestQuickReceiveOrder()
end

function VoyageMainWindow:_onClickGoToActivate(  )
	VipController:getInstance():openVipMainWindow(true, VIPTABCONST.PRIVILEGE)
end

function VoyageMainWindow:close_callback(  )
	if self.order_scrollview then
		self.order_scrollview:DeleteMe()
		self.order_scrollview = nil
	end
	if self.role_assets_event then
        if self.role_vo then
            self.role_vo:UnBind(self.role_assets_event)
        end
        self.role_assets_event = nil
        self.role_vo = nil
    end
    self:handleEffect(false)
	controller:openVoyageMainWindow(false)
end