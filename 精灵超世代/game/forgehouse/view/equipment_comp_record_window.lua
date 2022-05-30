--****************
--合成记录
--****************
EquipmentCompRecordWindow = EquipmentCompRecordWindow or BaseClass(BaseView)

local controller = ForgeHouseController:getInstance()
function EquipmentCompRecordWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.layout_name = "forgehouse/forgehouse_comp_record"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad('bigbg', 'bigbg_3'), type = ResourcesType.single},
	}
end

function EquipmentCompRecordWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 2)
	main_container:getChildByName("Text_1_0"):setString(TI18N("合成记录"))

	self.empty_bg = main_container:getChildByName("empty_bg")
	self.empty_bg:setVisible(false)
	loadSpriteTexture(self.empty_bg, PathTool.getPlistImgForDownLoad('bigbg', 'bigbg_3'), LOADTEXT_TYPE)

	local good_cons = main_container:getChildByName("good_cons")
	local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = EquipmentCompRecordItem,      -- 单元类
        start_x = 10,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 651,               -- 单元的尺寸width
        item_height = 197,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic == true,
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

	self.btn_sure = main_container:getChildByName("btn_sure")
	self.btn_sure:getChildByName("Text_1"):setString(TI18N("确 定"))
end
function EquipmentCompRecordWindow:register_event()
	self:addGlobalEvent(ForgeHouseEvent.Composite_Record, function(data)
		if not data or next(data) == nil then return end
		if next(data.logs) ~= nil then
			self.empty_bg:setVisible(false)
		else
			self.empty_bg:setVisible(true)
		end
		if self.item_scrollview then
			self.item_scrollview:setData(data.logs)
		end
	end)
	registerButtonEventListener(self.btn_sure, function()
 		controller:openEquipmentCompRecordWindow(false)
    end,true,1)
end
function EquipmentCompRecordWindow:openRootWnd()
	controller:send11082()
end

function EquipmentCompRecordWindow:close_callback()
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil
	controller:openEquipmentCompRecordWindow(false)
end

------------------------------------------
-- 子项
EquipmentCompRecordItem = class("EquipmentCompRecordItem", function()
    return ccui.Widget:create()
end)

function EquipmentCompRecordItem:ctor()
	self:configUI()
end

function EquipmentCompRecordItem:configUI()
	self.size = cc.size(651,197)
    self:setContentSize(self.size)

    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("forgehouse/forgehouse_comp_record_item"))
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")
    main_container:getChildByName("Text_1"):setString(TI18N("合成物品："))
    main_container:getChildByName("Text_1_0"):setString(TI18N("材料消耗："))
    self.time_text = main_container:getChildByName("time_text")
    self.time_text:setString("")
    self.consume_text = main_container:getChildByName("consume_text")
    self.consume_text:setString("")
    
    local good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 10,                    -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 13,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.80,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.80,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                        -- 列数，作用于垂直滚动类型
        scale = 0.80,
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0, 0), ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    local consume_item = main_container:getChildByName("consume_item")
    consume_item:setScale(0.4)
    local item_config = Config.ItemData.data_get_data(1)
	local res = PathTool.getItemRes(item_config.icon)
    loadSpriteTexture(consume_item, res, LOADTEXT_TYPE)
end

function EquipmentCompRecordItem:setData(data)
	if not data or next(data) == nil then return end

	self.time_text:setString(TimeTool.getYMDHMS(data.time))
	self.consume_text:setString(data.coin)

	local list = {}
    for k, v in pairs(data.items) do
        local vo = deepCopy(Config.ItemData.data_get_data(v.bid))
        if vo then
            vo.quantity = v.num
            table.insert(list, vo)
        end
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

function EquipmentCompRecordItem:DeleteMe()
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil
	self:removeAllChildren()
	self:removeFromParent()
end