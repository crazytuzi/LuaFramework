---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/11/20 15:58:58
-- @description: 特权充值确认框
---------------------------------
local _controller = MallController:getInstance()
local _table_insert = table.insert

ChargeSureWindow = ChargeSureWindow or BaseClass(BaseView)

function ChargeSureWindow:__init()
	self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.layout_name = "forgehouse/forgehouse_all_synthesis"
end

function ChargeSureWindow:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container , 2) 
	main_container:getChildByName("Image_7"):getChildByName("Text_6"):setString(TI18N("购买确认"))

	self.btn_sure = main_container:getChildByName("btn_sure")
	self.btn_sure:getChildByName("Text_4_0"):setString(TI18N("购 买"))
	self.btn_comp = main_container:getChildByName("btn_comp")
	self.btn_comp:getChildByName("Text_4"):setString(TI18N("取 消"))

	local good_cons = main_container:getChildByName("good_cons")
	local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 115,                    -- 第一个单元的X起点
        space_x = 40,                    -- x方向的间隔
        start_y = 50,                    -- 第一个单元的Y起点
        space_y = 8,                   -- y方向的间隔
        item_width = BackPackItem.Width,               -- 单元的尺寸width
        item_height = BackPackItem.Height,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 5,                         -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)

    self.tips_txt = createLabel(26, 274, nil, 26, 376, TI18N("购买该特权立即获得:"), main_container, nil, cc.p(0, 0.5))
end

function ChargeSureWindow:register_event(  )
    registerButtonEventListener(self.btn_sure, handler(self, self.onClickSureBtn), true)

    registerButtonEventListener(self.btn_comp, function (  )
        _controller:openChargeSureWindow(false)
    end, true, 2)
end

function ChargeSureWindow:onClickSureBtn(  )
    if self.data then
        VipController:getInstance():sender24501(self.data.id)
        _controller:openChargeSureWindow(false)
    end
end

function ChargeSureWindow:openRootWnd( data )
    self:setData(data)
end

function ChargeSureWindow:setData( data )
    if not data then return end

    self.data = data 

    local item_list = {}
    local role_vo = RoleController:getInstance():getRoleVo()
    local privilege_award_cfg = Config.PrivilegeData.data_privilege_award[data.id]
    if privilege_award_cfg then
        local award_data = {}
        for k,v in pairs(privilege_award_cfg) do
            if v.min <= role_vo.lev and v.max >= role_vo.lev then
                award_data = deepCopy(v.reward)
                break
            end
        end
        for k,v in pairs(award_data) do
            local vo = deepCopy(Config.ItemData.data_get_data(v[1]))
            if vo then
                vo.quantity = v[2]
                _table_insert(item_list,vo)
            end
        end
    end
    self.item_scrollview:setData(item_list)
	self.item_scrollview:addEndCallBack(function()
        local list = self.item_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
            v:setSwallowTouches(false)
        end
    end)
end

function ChargeSureWindow:close_callback(  )
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    _controller:openChargeSureWindow(false)
end