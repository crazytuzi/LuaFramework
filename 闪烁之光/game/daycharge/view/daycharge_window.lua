-- --------------------------------------------------------------------
-- 每日首充界面
-- --------------------------------------------------------------------
DayChargeWindow = DayChargeWindow or BaseClass(BaseView)

local controller = DayChargeController:getInstance()
function DayChargeWindow:__init()
	self.win_type = WinType.Big
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.layout_name = "action/action_day_charge_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("exchange", "exchange"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg/action", "txt_cn_action_bigbg_2"), type = ResourcesType.single},
	}
	self.first_effect = {}
	self.item_list = {}
end

function DayChargeWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setAnchorPoint(cc.p(0.5, 0.5))
	self.background:setPosition(360,640)
	self.background:setScale(display.getMaxScale())
	
	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    
	self.btn_charge = self.main_container:getChildByName("btn_charge")
	self.btn_charge:setVisible(false)
	self.btn_get = self.main_container:getChildByName("btn_get")
	self.btn_get:setVisible(false)

	self.charge_num = CommonNum.new(5, self.main_container, 1, 1, cc.p(0, 0.5))
    self.charge_num:setPosition(241, 614)
    self.diamond = self.main_container:getChildByName("Sprite_9")
    
	local good_cons = self.main_container:getChildByName("good_cons")
	local scroll_view_size = good_cons:getContentSize()
    local setting = {
        start_x = 5, -- 第一个单元的X起点
        space_x = 14, -- x方向的间隔
        start_y = 15, -- 第一个单元的Y起点
        space_y = 0, -- y方向的间隔
        item_width = BackPackItem.Width * 0.9, -- 单元的尺寸width
        item_height = BackPackItem.Height * 0.9, -- 单元的尺寸height
        row = 1, -- 行数，作用于水平滚动类型
        col = 0, -- 列数，作用于垂直滚动类型
        scale = 0.9
    }

	self.item_scrollview = CommonScrollViewSingleLayout.new(good_cons, cc.p(0, 0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

	self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
	self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
	self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    self.item_scrollview:setSwallowTouches(false)
    self.item_scrollview:setClickEnabled(false)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function DayChargeWindow:createNewCell()
    local cell = BackPackItem.new()
	cell:setDefaultTip()
	cell:setScale(0.9)
    return cell
end

--获取数据数量
function DayChargeWindow:numberOfCells()
    if not self.item_list then return 0 end
    return #self.item_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function DayChargeWindow:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.item_list[index]
    if not data then return end
    cell:setData(data)
end


function DayChargeWindow:openRootWnd()
	controller:sender21010()

	local role_vo = RoleController:getInstance():getRoleVo()
	local open_day = Config.ChargeData.data_daily_reward_length
	local reward_data = Config.ChargeData.data_daily_reward

	for i,v in pairs(reward_data) do
		if role_vo.open_day >= v.min and role_vo.open_day <= v.max then
			open_day = v.id
			break
		end
	end

	if self.item_scrollview then
		local list = {}
		for i,v in pairs(reward_data[open_day].reward) do
			local vo = {}
			vo.bid = v[1]
			vo.quantity = v[2]
			table.insert(list, vo)
		end
		self.item_list = list
	    self.item_scrollview:reloadData()
	end

    self.charge_num:setCallBack(function()
    	self.diamond:setPositionX(self.charge_num:getPositionX()+self.charge_num:getContentSize().width)
    end)
    self.diamond:setPositionX(self.charge_num:getPositionX()+self.charge_num:getContentSize().width)

    self.first_effect[1] = createEffectSpine(PathTool.getEffectRes(650), cc.p(360, 673), cc.p(0.5, 0.5), true, PlayerAction.action)
    self.main_container:addChild(self.first_effect[1])

    self.first_effect[2] = createEffectSpine(PathTool.getEffectRes(651), cc.p(360, 305), cc.p(0.5, 0.5), true, PlayerAction.action)
    self.main_container:addChild(self.first_effect[2])
    self.first_effect[2]:setVisible(false)
end

function DayChargeWindow:register_event()
	self:addGlobalEvent(DayChargetEvent.DAY_FIRST_CHARGE_EVENT, function(data)
		if not data then return end
		local reward_data = Config.ChargeData.data_constant.day_charge_goal
		local num = reward_data.val - data.num
		if num <= 0 then
			num = 0
		end
		self.charge_num:setNum(num)
		if data.status == 0 then
			self.first_effect[2]:setVisible(true)
			self.btn_charge:setVisible(true)
			self.btn_get:setVisible(false)
		elseif data.status == 1 then
			self.first_effect[2]:setVisible(false)
			self.btn_charge:setVisible(false)
			self.btn_get:setVisible(true)
		end
	end)
	registerButtonEventListener(self.background, function()
		controller:openDayFirstChargeView(false)
	end, false, 2)
	registerButtonEventListener(self.btn_charge, function()
		VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
		--MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
	end, true, 1)
	registerButtonEventListener(self.btn_get, function()
		controller:sender21011()
	end, true, 1)
end

function DayChargeWindow:close_callback()
	doStopAllActions(self.main_container)
	if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.charge_num then
        self.charge_num:DeleteMe()
        self.charge_num = nil
    end
    for i,v in pairs(self.first_effect) do
	    if v then
	        v:clearTracks()
	        v:removeFromParent()
	        v = nil
	    end
	end
	controller:openDayFirstChargeView(false)
end