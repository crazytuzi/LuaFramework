--****************
--一键合成
--****************
EquipmentAllSynthesisWindow = EquipmentAllSynthesisWindow or BaseClass(BaseView)

local controller = ForgeHouseController:getInstance()
local table_insert = table.insert
function EquipmentAllSynthesisWindow:__init(data)
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.data = data
	self.layout_name = "forgehouse/forgehouse_all_synthesis"
end

function EquipmentAllSynthesisWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 1)
	main_container:getChildByName("Text_6"):setString(TI18N("一键合成"))

	self.btn_sure = main_container:getChildByName("btn_sure")
	self.btn_sure:getChildByName("Text_4_0"):setString(TI18N("确 定"))
	self.btn_comp = main_container:getChildByName("btn_comp")
	self.btn_comp:getChildByName("Text_4"):setString(TI18N("取 消"))

	local good_cons = main_container:getChildByName("good_cons")
	local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 18,                    -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 5,                    -- 第一个单元的Y起点
        space_y = 8,                   -- y方向的间隔
        item_width = BackPackItem.Width,               -- 单元的尺寸width
        item_height = BackPackItem.Height,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 5,                         -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)

    self.comp_coin_num = createRichLabel(26, Config.ColorData.data_new_color4[6], cc.p(0,0.5), cc.p(43,377), nil, nil, 600)
	main_container:addChild(self.comp_coin_num)
end
function EquipmentAllSynthesisWindow:register_event()
	registerButtonEventListener(self.btn_sure, function()
		local send_id = controller:getModel():getCompSendID()
		if send_id then
	 		controller:send11081(send_id)
	 	end
    end,true,1)
    registerButtonEventListener(self.btn_comp, function()
 		controller:openEquipmentAllSynthesisWindow(false)
    end,true,1)
end
function EquipmentAllSynthesisWindow:openRootWnd()
	if not self.data or next(self.data) == nil then return end
	local item_config = Config.ItemData.data_get_data(1)
	local res = PathTool.getItemRes(item_config.icon)
	local str = string.format(TI18N("是否消耗 <img src='%s' scale=0.3 />%s 以及材料合成以下装备"),res,MoneyTool.GetMoneyString(self.data.coin))
	self.comp_coin_num:setString(str)

	local list = {}
	for i,v in pairs(self.data.list) do
		local vo = {}
		vo.bid = v.bid
		vo.quantity = v.num
		table_insert(list, vo)
	end
	self.item_scrollview:setData(list)
	self.item_scrollview:addEndCallBack(function()
        local list = self.item_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
            v:setSwallowTouches(false)
        end
    end)
end

function EquipmentAllSynthesisWindow:close_callback()
	if self.item_scrollview then 
       self.item_scrollview:DeleteMe()
       self.item_scrollview = nil
    end
	controller:openEquipmentAllSynthesisWindow(false)
end