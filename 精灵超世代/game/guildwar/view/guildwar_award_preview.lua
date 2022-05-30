--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-01-21 20:41:06
-- @description    : 
		-- 公会战宝箱奖励预览
---------------------------------
GuildwarAwardBoxPreview = GuildwarAwardBoxPreview or BaseClass(BaseView)

local _controller = GuildwarController:getInstance()

function GuildwarAwardBoxPreview:__init()
	self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "guildwar/guildwar_award_preview"
end

function GuildwarAwardBoxPreview:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)

	local win_title = container:getChildByName("win_title")
	win_title:setString(TI18N("奖励预览"))
	local tips_label_1 = container:getChildByName("tips_label_1")
	tips_label_1:setString(TI18N("黄金宝箱可开出下列物品"))
	local tips_label_2 = container:getChildByName("tips_label_2")
	tips_label_2:setString(TI18N("青铜宝箱可开出下列物品"))

	self.ok_btn = container:getChildByName("ok_btn")
	self.ok_btn:getChildByName("label"):setString(TI18N("确定"))

	local good_con_1 = container:getChildByName("good_con_1")
	local scroll_view_size = good_con_1:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width,               -- 单元的尺寸width
        item_height = BackPackItem.Height,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview_1 = CommonScrollViewLayout.new(good_con_1, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)

	local good_con_2 = container:getChildByName("good_con_2")
	local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width,               -- 单元的尺寸width
        item_height = BackPackItem.Height,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview_2 = CommonScrollViewLayout.new(good_con_2, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
end

function GuildwarAwardBoxPreview:register_event(  )
	registerButtonEventListener(self.background, function (  )
		_controller:openAwardBoxPreview(false)
	end, false, 2)

	registerButtonEventListener(self.ok_btn, function (  )
		_controller:openAwardBoxPreview(false)
	end, true, 2)
end

function GuildwarAwardBoxPreview:openRootWnd(  )
	self:setData()
end

function GuildwarAwardBoxPreview:setData(  )
	-- 金宝箱奖励
	local gold_config = Config.GuildWarData.data_box_award[1]
	if gold_config.award then
		local item_list = {}
		for i,bid in ipairs(gold_config.award) do
			local item_cfg = Config.ItemData.data_get_data(bid)
			if item_cfg then
				table.insert(item_list, deepCopy(item_cfg))
			end
		end
		self.item_scrollview_1:setData(item_list)
        self.item_scrollview_1:addEndCallBack(function (  )
            local list = self.item_scrollview_1:getItemList()
            for k,v in pairs(list) do
                v:setDefaultTip()
            end
        end)
	end

	-- 铜宝箱奖励
	local copper_config = Config.GuildWarData.data_box_award[2]
	if copper_config.award then
		local item_list = {}
		for i,bid in ipairs(copper_config.award) do
			local item_cfg = Config.ItemData.data_get_data(bid)
			if item_cfg then
				table.insert(item_list, deepCopy(item_cfg))
			end
		end
		self.item_scrollview_2:setData(item_list)
        self.item_scrollview_2:addEndCallBack(function (  )
            local list = self.item_scrollview_2:getItemList()
            for k,v in pairs(list) do
                v:setDefaultTip()
            end
        end)
	end
end

function GuildwarAwardBoxPreview:close_callback(  )
	if self.item_scrollview_1 then
		self.item_scrollview_1:DeleteMe()
		self.item_scrollview_1 = nil
	end

	if self.item_scrollview_2 then
		self.item_scrollview_2:DeleteMe()
		self.item_scrollview_2 = nil
	end
	_controller:openAwardBoxPreview(false)
end