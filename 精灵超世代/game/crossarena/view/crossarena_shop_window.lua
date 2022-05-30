--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-05-08 17:22:36
-- @description    : 
		-- 跨服竞技场 声望商店
---------------------------------
local _controller = CrossarenaController:getInstance()
local _model = _controller:getModel()

CrossareanShopWindow = CrossareanShopWindow or BaseClass(BaseView)

function CrossareanShopWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "crossarena/crossarena_shop_window"

    self.role_vo = RoleController:getInstance():getRoleVo()
end

function CrossareanShopWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(main_container, 2)

	main_container:getChildByName("win_title"):setString(TI18N("声望商店"))
	main_container:getChildByName("title_time"):setString(TI18N("免费刷新:"))
	main_container:getChildByName("title_count"):setString(TI18N("刷新次数:"))

	self.close_btn = main_container:getChildByName("close_btn")
	self.refresh_btn = main_container:getChildByName("refresh_btn")
	local btn_size = self.refresh_btn:getContentSize()
	self.refresh_btn_label = createRichLabel(20, 1, cc.p(0.5, 0.5), cc.p(btn_size.width/2, btn_size.height/2))
	self.refresh_btn:addChild(self.refresh_btn_label)

	self.res_label = main_container:getChildByName("res_label")
	self.txt_time = main_container:getChildByName("txt_time")
	self.txt_count = main_container:getChildByName("txt_count")

	local list_panel = main_container:getChildByName("list_panel")
    local scroll_view_size = list_panel:getContentSize()
    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 4,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        item_width = 334,               -- 单元的尺寸width
        item_height = 160,              -- 单元的尺寸height
        -- row = 1,                        -- 行数，作用于水平滚动类型
        col = 2,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(list_panel, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0,0))

    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
end

function CrossareanShopWindow:createNewCell(  )
    local cell = MallItem.new()
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end

function CrossareanShopWindow:numberOfCells(  )
    if not self.show_list then return 0 end
    return #self.show_list
end

function CrossareanShopWindow:updateCellByIndex( cell, index )
    if not self.show_list then return end
    cell.index = index
    local cell_data = self.show_list[index]
    cell:setData(cell_data)
end

function CrossareanShopWindow:onCellTouched(cell)
    local index = cell.index
    local cell_data = self.show_list[index]
    if cell_data then
        if cell_data.has_buy == nil then
            if cell_data.ext and cell_data.ext[1] then
                cell_data.has_buy = cell_data.ext[1].val
            else
                cell_data.has_buy = 0
            end
        end

        cell_data.shop_type = MallConst.MallType.CrossarenaShop
        MallController:getInstance():openMallBuyWindow(true, cell_data)
    end
end

function CrossareanShopWindow:register_event(  )
	registerButtonEventListener(self.close_btn, function (  )
		_controller:openCrossarenaShopWindow(false)
	end, true, 2)

	registerButtonEventListener(self.background, function (  )
		_controller:openCrossarenaShopWindow(false)
	end, false, 2)

	registerButtonEventListener(self.refresh_btn, function (  )
		self:_onClickRefreshBtn()
	end, true)

	self:addGlobalEvent(MallEvent.Get_Buy_list, function ( data )
		if data.type == MallConst.MallType.CrossarenaShop then
			self.data = data
            self:setLessTime( data.refresh_time - GameNet:getInstance():getTime())
            self:setResetCount(data)
            for k,v in pairs(data.item_list) do
                v.shop_type = MallConst.MallType.CrossarenaShop
            end

            self.show_list = self.data.item_list or {}
            self.item_scrollview:reloadData()
        end
	end)

    if not self.role_lev_event and self.role_vo then
        self.role_lev_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
            if key and key == "cluster_coin" then 
                self:updateResNum()
            end
        end)
    end
end

function CrossareanShopWindow:_onClickRefreshBtn(  )
    MallController:getInstance():sender13405(MallConst.MallType.CrossarenaShop)
end

function CrossareanShopWindow:openRootWnd(  )
	MallController:getInstance():sender13403(MallConst.MallType.CrossarenaShop)
    self:updateResNum()
end

function CrossareanShopWindow:updateResNum(  )
    if self.role_vo then
        self.res_label:setString(self.role_vo.cluster_coin)
    end
end

function CrossareanShopWindow:setResetCount( data )
    if not data then return end
    local free_count = data.free_count or 0
    local btn_str = TI18N("免费刷新")

    if free_count <= 0 then
        local  config = Config.ExchangeData.data_shop_list[MallConst.MallType.CrossarenaShop]
        if config then
            local cost_list = config.cost_list
            local bid = cost_list[1][1]
            local num = cost_list[1][2]
            btn_str = string.format(TI18N("<img src=%s scale=0.3 visible=true />%s刷新"), PathTool.getItemRes(Config.ItemData.data_get_data(bid).icon), num)
        end
    else
        local asset_cfg = Config.ExchangeData.data_shop_exchage_cost["cluster_refresh_free"] 
        if asset_cfg then
            btn_str = string.format("<div fontsize=20>%s(%s/%s)</div>", TI18N("免费刷新"), free_count, asset_cfg.val)
        end
    end
    self.refresh_btn_label:setString(btn_str)

    self.txt_count:setVisible(true)
    local config = Config.ExchangeData.data_shop_exchage_cost.cluster_refresh_number
    local max_count = 0 
    if config then
        max_count = config.val
    end
    local count = data.count or 0
    local text = string.format("%s/%s", count, max_count)
    self.txt_count:setString(text)
end

function CrossareanShopWindow:setLessTime( less_time )
	if tolua.isnull(self.txt_time) then return end
    doStopAllActions(self.txt_time)
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.txt_time:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                doStopAllActions(self.txt_time)
            else
                self:setTimeFormatString(less_time)
            end
        end))))
    else
        self:setTimeFormatString(less_time)
    end
end

function CrossareanShopWindow:setTimeFormatString(time)
    if time > 0 then
        self.txt_time:setString(TimeTool.GetTimeFormat(time))
    else
        self.txt_time:setString("00:00:00")
    end
end

function CrossareanShopWindow:close_callback(  )
	if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.role_lev_event and self.role_vo then
        self.role_vo:UnBind(self.role_lev_event)
        self.role_lev_event = nil
    end
	_controller:openCrossarenaShopWindow(false)
end