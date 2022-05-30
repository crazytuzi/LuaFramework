TimeSummonPreviewWindow = TimeSummonPreviewWindow or BaseClass(BaseView)
local _controller = TimesummonController:getInstance()
local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format
function TimeSummonPreviewWindow:__init(index,bool)
	self.win_type = WinType.Mini
	self.is_full_screen = true
	self.view_tag = ViewMgrTag.DIALOGUE_TAG 
	self.layout_name = "seerpalace/seerpalace_preview_window"
end

function TimeSummonPreviewWindow:open_callback(index,bool)
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")
	self.container = container
	self:playEnterAnimatianByObj(container, 1)
	local win_title = container:getChildByName("win_title")
	win_title:setString(TI18N("奖励预览"))

	self.list_panel = container:getChildByName("list_panel")
	self.scroll_view_size = self.list_panel:getContentSize()
	self.scroll_view = createScrollView(self.scroll_view_size.width, self.scroll_view_size.height, 0, 0, self.list_panel, ccui.ScrollViewDir.vertical)

end

function TimeSummonPreviewWindow:openRootWnd(index,type) 
		self:setData(index,type) 
end

function TimeSummonPreviewWindow:setData(index,type)
	local show_data = {}
	if type == TimesummonConst.ActonInfoType.EliteType	then
		show_data = Config.RecruitHolidayEliteData.data_hero_show[index]
	elseif type == TimesummonConst.ActonInfoType.ElfinType or type == TimesummonConst.ActonInfoType.ElfinType2 then
		show_data = Config.HolidaySpriteLotteryData.data_hero_show[index]
	elseif type == TimesummonConst.ActonInfoType.EliteType2 then
		show_data = Config.RecruitHolidayLuckyData.data_hero_show[index]
	else
		show_data = Config.RecruitHolidayData.data_hero_show[index]
	end

	
	if show_data then
		local hero_tab = {}
		for i,v in pairs(show_data) do
			table_insert(hero_tab,v)
		end
		table_sort(hero_tab,function(a,b) return a.id < b.id end)
	  
		local scale = 0.9
		local space_y = 40
		local content_h = space_y + (BackPackItem.Height*scale+30) * math.ceil(#hero_tab/4)
		local max_height = math.max(content_h, self.scroll_view_size.height)
		self.scroll_view:setInnerContainerSize(cc.size(self.scroll_view_size.width, max_height))
		for i,v in pairs(hero_tab) do
			delayRun(self.list_panel, i/60, function()
				local item_node = BackPackItem.new(false,true)
				item_node:setAnchorPoint(cc.p(0,1))
				item_node:setScale(scale)
		        item_node:setBaseData(v.id,v.num)
		        item_node:showItemEffect(false)
		        item_node:setSummonNumber(string_format("%0.3f",v.probability))
		        item_node:setDefaultTip()
		        local pos_x = 30 + (BackPackItem.Width*scale + 30) * ((i-1)%4)
		        local pos_y = max_height - ((BackPackItem.Height*scale + 30) * math.floor((i-1)/4))
		        item_node:setPosition(cc.p(pos_x, pos_y))
				self.scroll_view:addChild(item_node)
			end)
		end
	end
end



function TimeSummonPreviewWindow:register_event()
	registerButtonEventListener(self.background, handler(self, self._onClickBtnClose), false, 2)
end

function TimeSummonPreviewWindow:_onClickBtnClose()
	_controller:openTimeSummonpreviewWindow(false)

end

function TimeSummonPreviewWindow:close_callback()
	self.list_panel:stopAllActions()
	_controller:openTimeSummonpreviewWindow(false)
end