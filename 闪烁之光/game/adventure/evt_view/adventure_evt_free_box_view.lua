-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      神界冒险免费宝箱
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
AdventureEvtFreeBoxWindow = AdventureEvtFreeBoxWindow or BaseClass(BaseView)

local controller = AdventureController:getInstance()
local string_format = string.format

function AdventureEvtFreeBoxWindow:__init(data)
	self.win_type = WinType.Big
	self.data = data
	self.config = data.config
	self.layout_name = "adventure/adventure_evt_free_box_view"
	self.is_full_screen = false
	self.item_list = {}
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("adventure", "adventure"), type = ResourcesType.plist},
	}
	self.is_send_proto = false
	self.is_use_csb = false
	self.need_list = {}
end

function AdventureEvtFreeBoxWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

	self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 2)

	self.close_btn = self.container:getChildByName("close_btn")
	self.item_container = self.container:getChildByName("item_container")
    
	self.ack_button = self.container:getChildByName("ack_button")
	local label = self.ack_button:getTitleRenderer()
    label:setString(TI18N("打开"))
	label:enableOutline(Config.ColorData.data_color4[264], 2)

	self.title_label = self.container :getChildByName("title_label")
	self.title_label:setString(TI18N("宝箱"))
	self.reward_label = self.container:getChildByName("reward_label")
	self.reward_label:setString(TI18N("随机奖励预览"))

	local scroll_view_size = self.item_container:getContentSize()
	local setting = {
		item_class = BackPackItem, -- 单元类
		start_x = 10, -- 第一个单元的X起点
		space_x = 15, -- x方向的间隔
		start_y = 5, -- 第一个单元的Y起点
		space_y = 10, -- y方向的间隔
		item_width = BackPackItem.Width * 0.9, -- 单元的尺寸width
		item_height = BackPackItem.Height * 0.9, -- 单元的尺寸height
		row = 0, -- 行数，作用于水平滚动类型
		col = 5, -- 列数，作用于垂直滚动类型
		scale = 0.9
	}
	self.is_select = false
	self.item_scrollview = CommonScrollViewLayout.new(self.item_container, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, cc.size(scroll_view_size.width, scroll_view_size.height - 49), setting)

    self.open_desc = self.container:getChildByName("open_desc")
	self.open_desc:setString("")

    self.desc = self.container:getChildByName("desc")
    self.desc:setTextAreaSize(cc.size(556, 80))

	self:updatedata()
end


function AdventureEvtFreeBoxWindow:updatedata()
	if self.config then
		self.desc:setString(self.config.desc)
		if self.config.lose and next(self.config.lose[1] or {}) ~= nil then
			self:updateItemData(self.config.lose)
		end
		-- self:updateTipsLabel(self.config.base_items)
		self:createEffect(self.config.effect_str)
		if self.config.box_show_item and next(self.config.box_show_item or {}) ~= nil then
			self:updateRankItemData(self.config.box_show_item)
		end
	end
end

function AdventureEvtFreeBoxWindow:createEffect(bid)
	if bid ~= "" then
		if not tolua.isnull(self.container) and self.box_effect == nil then
			self.box_effect = createEffectSpine(bid, cc.p(360, 608), cc.p(0.5, 0.5), true, PlayerAction.action)
			self.box_effect:setScale(1.5)
			self.container:addChild(self.box_effect)
		end
	end
end

function AdventureEvtFreeBoxWindow:updateRankItemData(data)
	if not data then return end
	local list = {}
	for k, v in ipairs(data) do
		local vo = {}
		vo = deepCopy(Config.ItemData.data_get_data(v[1]))
		vo.num = v[2]
		table.insert(list, vo)
	end
	self.item_scrollview:setData(list)
	
	self.item_scrollview:addEndCallBack(function()
		local list = self.item_scrollview:getItemList()
		for k, v in pairs(list) do
			v:setDefaultTip()
			if v.data and v.data.num ~= 1 then
				v:setNum(v.data.num)
			end
		end
	end)
end

function AdventureEvtFreeBoxWindow:updateTipsLabel(data)
	-- if data then
	-- 	local str = ""
	-- 	for i, v in ipairs(data) do
	-- 		local name = Config.ItemData.data_get_data(v[1]).name
	-- 		str = str .. name .. v[2]
	-- 	end
	-- 	local final_str = TI18N("必定获得:") .. str
	-- 	self.open_desc:setString(final_str)
	-- end
end

function AdventureEvtFreeBoxWindow:register_event()
	if self.background then
		self.background:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				controller:openEvtViewByType(false)
			end
		end)
	end
	if self.close_btn then
		self.close_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				controller:openEvtViewByType(false)
			end
		end)
	end
	if self.ack_button then
		self.ack_button:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				if self.data then
					local ext_list = {{type = 1, val = 0}}
					if self.is_select == true then
						ext_list = {{type = 1, val = 1}}
					end
					controller:send20620(self.data.id, AdventureEvenHandleType.handle, ext_list)
				end
			end
		end)
	end
	if not self.update_box_event then
		self.update_box_event = GlobalEvent:getInstance():Bind(AdventureEvent.Update_Evt_Box_Result_Info, function(data)
			if data then
				self:updateResult(data)
			end
		end)
	end
end

function AdventureEvtFreeBoxWindow:updateResult(data)
	if self.box_effect then
		self.box_effect:setAnimation(0, PlayerAction.action_1, false)
	end
	delayOnce(function()
		controller:showGetItemTips(data.items)
		controller:openEvtViewByType(false)
	end, 1)
end

function AdventureEvtFreeBoxWindow:openRootWnd(type)
end

function AdventureEvtFreeBoxWindow:close_callback()
	if self.item_list then
		for i, item in ipairs(self.item_list) do
			if item then
				item:DeleteMe()
			end
		end
		self.item_list = {}
	end
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	if self.update_box_event then
		GlobalEvent:getInstance():UnBind(self.update_box_event)
		self.update_box_event = nil
	end
	controller:openEvtViewByType(false)
end 