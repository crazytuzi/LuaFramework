--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 战令三期 奖励
-- @DateTime:    2019-06-24 11:40:40
-- *******************************
OrderActionRewardPanel1 = class("OrderActionRewardPanel1", function()
    return ccui.Widget:create()
end)
local table_sort = table.sort
local table_insert = table.insert
local math_ceil = math.ceil
local controller = OrderActionController:getInstance()
local model = controller:getModel()
local lev_reward_list = Config.HolidayWarOrderData.data_lev_reward_list
function OrderActionRewardPanel1:ctor(period)
    self.cur_period = period or 1
    self.cur_move_num = nil
    self:layoutUI()
    self:registerEvents()
end
function OrderActionRewardPanel1:layoutUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("orderaction/reward_panel1"))
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(651,558))

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:getChildByName("Image_1"):getChildByName("Text_1"):setString(TI18N("等级"))
    self.main_container:getChildByName("Image_1"):getChildByName("Text_1_0"):setString(TI18N("奖励"))
    self.main_container:getChildByName("Image_1"):getChildByName("Text_1_1"):setString(TI18N("进阶奖励"))
    self.main_container:getChildByName("Image_14"):getChildByName("Text_2"):setString(TI18N("奖励预览"))
    self.lev_num = self.main_container:getChildByName("Image_14"):getChildByName("lev_num")
    self.lev_num:setString("")
    self.slide_goods_item = self.main_container:getChildByName("slide_goods_item")
    self.slide_goods_item:setScrollBarEnabled(false)

    self.lock_image = self.main_container:getChildByName("lock_image")
    self.btn_change_advance = self.lock_image:getChildByName("btn_change_advance")
    self.lock_image:setVisible(true)
    if model:getGiftStatus() == 1 then
    	self.lock_image:setVisible(false)
    else
    	self.lock_image:setVisible(true)
    end
    local goods_item = self.main_container:getChildByName("goods_item")
    local scroll_view_size = goods_item:getContentSize()
    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 635,               -- 单元的尺寸width
        item_height = 116,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true,
    }
    self.reward_goods_item = CommonScrollViewSingleLayout.new(goods_item, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.reward_goods_item:setSwallowTouches(true)

    self.reward_goods_item:registerScriptHandlerSingle(handler(self,self.createTaskCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.reward_goods_item:registerScriptHandlerSingle(handler(self,self.numberOfTaskCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.reward_goods_item:registerScriptHandlerSingle(handler(self,self.updateTaskCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
end
function OrderActionRewardPanel1:createTaskCell()
	local cell = OrderActiodRewardItem1.new()
    return cell
end
function OrderActionRewardPanel1:numberOfTaskCells()
	if not self.reward_list then return 0 end
    return #self.reward_list
end
function OrderActionRewardPanel1:updateTaskCellByIndex(cell, index)
	if not self.reward_list then return end
    local cell_data = self.reward_list[index]
    if not cell_data then return end

    cell:setData(cell_data)
	self:setSlideGoodsItem(cell_data.lev)
end

--滑动物品显示
function OrderActionRewardPanel1:setSlideGoodsItem(lev_index)
	local count = #lev_reward_list[self.cur_period] or 1

    lev_index = math_ceil(lev_index*0.1)

	if self.cur_move_num == lev_index then return end
	self.cur_move_num = lev_index

	local cur_index = self.cur_move_num * 10
    if cur_index >= count then
        cur_index = count
    end
    if cur_index == 0 then cur_index = 1 end

	if not lev_reward_list[self.cur_period] then return end
	local data = lev_reward_list[self.cur_period][cur_index]
	if not data then return end

	self.lev_num:setString("("..data.lev..")")
	if not self.common_item then
		self.common_item = BackPackItem.new(nil,true,nil,0.8)
	    self.main_container:addChild(self.common_item)
	    self.common_item:setPosition(cc.p(263, 58))
	    self.common_item:setDefaultTip()
	end
	if data.reward and next(data.reward) ~= nil then
		self.common_item:setBaseData(data.reward[1][1], data.reward[1][2])
		self.common_item:setVisible(true)
	else
		self.common_item:setVisible(false)
	end

	local data_list = data.rmb_reward or {}
	local setting = {}
	setting.scale = 0.8
	setting.max_count = 3
	self.slide_goods_list = commonShowSingleRowItemList(self.slide_goods_item, self.slide_goods_list, data_list, setting)
end
--当等级变化的时候
function OrderActionRewardPanel1:setChangeLevelStatus(cur_lev)
	if lev_reward_list and lev_reward_list[self.cur_period] then
    	self.reward_list = {}
	    for i,v in pairs(lev_reward_list[self.cur_period]) do
	    	v.cur_lev = cur_lev
	    	v.status = 0
	    	v.rmb_status = 0
	    	v.is_locak = model:getGiftStatus()
	    	local lev_list = model:getLevShowData(v.lev)
	    	if lev_list then
		    	v.status = lev_list.status
	    		v.rmb_status = lev_list.rmb_status
		    end
		    if v.status == 1 and v.rmb_status == 1 then
		    else
		    	table_insert(self.reward_list,v)
		    end
	    end
        if next(self.reward_list) == nil then
            if self.common_item then
                self.common_item:setVisible(false)
            end
            if self.slide_goods_item then
                self.slide_goods_item:setVisible(false)
            end
            self.lev_num:setString(TI18N("(领取完毕)"))
            self.reward_goods_item:reloadData()
            commonShowEmptyIcon(self.main_container, true, {font_size = 22,scale = 1, text = TI18N("已领取所有奖励")})
        else
    	    table_sort(self.reward_list,function(a,b) return a.lev < b.lev end)
            self.reward_goods_item:reloadData()
        end
	end
end

function OrderActionRewardPanel1:registerEvents()
	--等级变化
	if not self.update_lev_event then
        self.update_lev_event = GlobalEvent:getInstance():Bind(OrderActionEvent.OrderAction_Updata_LevExp_Event,function(data)
            if data then
                self:setChangeLevelStatus(data.lev)
            end
        end)
    end
    if not self.update_levreward_event then
        self.update_levreward_event = GlobalEvent:getInstance():Bind(OrderActionEvent.OrderAction_LevReward_Event,function(lev)
            self:setChangeLevelStatus(lev)
        end)
    end

    --进阶卡情况
    if not self.update_lockopen_event then
        self.update_lockopen_event = GlobalEvent:getInstance():Bind(OrderActionEvent.OrderAction_BuyGiftCard_Event,function()
            local cur_lev = model:getCurLev()
            self:setChangeLevelStatus(cur_lev)
            if model:getGiftStatus() == 1 then
                self.lock_image:setVisible(false)
            else
                self.lock_image:setVisible(true)
            end
        end)
    end

    registerButtonEventListener(self.btn_change_advance, function()
        controller:openBuyCardView(true)
    end ,true, 1)
end
function OrderActionRewardPanel1:setVisibleStatus(bool)
    self:setVisible(bool)
end

function OrderActionRewardPanel1:DeleteMe()
	if self.update_lev_event then
        GlobalEvent:getInstance():UnBind(self.update_lev_event)
        self.update_lev_event = nil
    end
    
    if self.update_levreward_event then
        GlobalEvent:getInstance():UnBind(self.update_levreward_event)
        self.update_levreward_event = nil
    end
    if self.update_lockopen_event then
        GlobalEvent:getInstance():UnBind(self.update_lockopen_event)
        self.update_lockopen_event = nil
    end

	if self.reward_goods_item then
        self.reward_goods_item:DeleteMe()
        self.reward_goods_item = nil
    end
    if self.slide_goods_list then
        for i,v in pairs(self.slide_goods_list) do
            v:DeleteMe()
        end
        self.slide_goods_list = nil
    end
    if self.common_item then 
       self.common_item:DeleteMe()
       self.common_item = nil
    end
	self:removeAllChildren()
    self:removeFromParent()
end

------------------------------------------
-- 子项
OrderActiodRewardItem1 = class("OrderActiodRewardItem1", function()
    return ccui.Widget:create()
end)

function OrderActiodRewardItem1:ctor()
    self:configUI()
    self:register_event()
end

function OrderActiodRewardItem1:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("orderaction/reward_item1"))
    self:setContentSize(cc.size(635,116))
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.goods_item = main_container:getChildByName("goods_item")
    self.goods_item:setScrollBarEnabled(false)
    self.mark = main_container:getChildByName("mark")
    self.mark:setVisible(false)
    self.lev_num = main_container:getChildByName("lev_num")
    self.lev_num:setString("")
    self.common_goods_item = BackPackItem.new(nil,true,nil,0.8)
    main_container:addChild(self.common_goods_item)
    self.common_goods_item:setPosition(cc.p(263, 58))
    self.common_goods_item:addCallBack(function()
    	if self.data and self.data.lev and self.data.status then
    		if self.data.status == 0 then
	    		controller:send25304(self.data.lev)
	    	end
    	end
	end)
end
function OrderActiodRewardItem1:register_event()
end

function OrderActiodRewardItem1:setData(data)
    if not data then return end
    self.data = data

    self.lev_num:setString(data.lev or 1)

    local common = true
    if self.common_goods_item then
    	if data.reward and data.reward[1] then
    		self.common_goods_item:setBaseData(data.reward[1][1],data.reward[1][2])
    		self.common_goods_item:setVisible(true)
    		self.common_goods_item:showOrderWarLock(true)
    	else
    		self.common_goods_item:setVisible(false)
    	end
 
    	--领取状态
    	if data.status == 1 then
    		self.common_goods_item:IsGetStatus(true)
    	else
	    	self.common_goods_item:IsGetStatus(false)
	    end
    end

    local is_locak_status = true
    if data.cur_lev >= data.lev then
    	if self.common_goods_item then
	    	self.common_goods_item:showOrderWarLock(false)
	    	common = false
	    end
	    if data.is_locak == 1 then
	    	is_locak_status = false
	    else
	    	is_locak_status = true
	    end
    else
    	if self.common_goods_item then
	    	self.common_goods_item:showOrderWarLock(true)
	    	common = true
	    end
	    is_locak_status = true
    end
    if common == false then
    	if data.status == 1 then
    		self.common_goods_item:showItemEffect(false)
    	else
		    self.common_goods_item:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
		end
	else
		self.common_goods_item:showItemEffect(false)
	end
    --普通奖励
    if data.status ~= 0 then
    	common = false
    end
    self.common_goods_item:setDefaultTip(common)

    --进阶奖励
    local advance = true
    local effect_id
    if model:getGiftStatus() == 1 then
    	if data.rmb_status == 0 then
    		if data.cur_lev >= data.lev then
    			advance = false
    		end
    	end
    end
    if advance == false then
    	effect_id = 263
    end

    local data_list = data.rmb_reward or {}
	local setting = {}
	setting.start_x = 10
	setting.scale = 0.8
	setting.max_count = 3
	setting.lock = is_locak_status
	setting.is_tip = advance
	setting.show_effect_id = effect_id

	local function callback()
		if self.data and self.data.lev and self.data.rmb_status then
    		if self.data.rmb_status == 0 then
	    		controller:send25304(self.data.lev)
	    	end
    	end
	end
	setting.callback = callback
	self.item_list = commonShowSingleRowItemList(self.goods_item, self.item_list, data_list, setting)
end

function OrderActiodRewardItem1:DeleteMe()
	if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    if self.common_goods_item then 
       self.common_goods_item:DeleteMe()
       self.common_goods_item = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end
