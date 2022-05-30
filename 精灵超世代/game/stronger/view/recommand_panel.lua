-- --------------------------------------------------------------------
-- 变强 推荐阵容面板
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
RecommandPanel = class("RecommandPanel", function()
    return ccui.Widget:create()
end)

local offset_y = 5
local item_width = 606
local item_height = 166

function RecommandPanel:ctor()
	self.ctrl = StrongerController:getInstance()
	self.model = self.ctrl:getModel()
	self.role_vo = RoleController:getInstance():getRoleVo()
	self.item_list = {}
	self.cur_select = nil
	self.cur_index = 1

	self:configUI()
	self:register_event()
end

function RecommandPanel:configUI(  )
	self.root_wnd = ccui.Layout:create()
	self.root_wnd:setContentSize(cc.size(620,770))
	self.root_wnd:setAnchorPoint(0,0)
	self:addChild(self.root_wnd)

	-- local res = PathTool.getResFrame("common", "common_1034")
	-- self.bg = createScale9Sprite(res, self.root_wnd:getContentSize().width/2,self.root_wnd:getContentSize().height/2, LOADTEXT_TYPE_PLIST, self.root_wnd)
	-- self.bg:setContentSize(cc.size(617,772))
	-- self.bg:setAnchorPoint(0.5,0.5)

	-- self.scroll = createScrollView(self.bg:getContentSize().width,self.bg:getContentSize().height-15,1,10,self.bg,ccui.ScrollViewDir.vertical)
	self.scroll = createScrollView(617,772-15,1,10,self.root_wnd,ccui.ScrollViewDir.vertical)

	self:createItemList()
end

function RecommandPanel:createItemList(  )
	local list = deepCopy(Config.StrongerData.data_recommand)
	local show_list = {}
	local data = BattleDramaController:getInstance():getModel():getDramaData()
	for k,v in pairs(list) do
		if data.max_dun_id >= v.limit then 
			table.insert(show_list,v)
		end
	end
	table.sort(show_list,SortTools.KeyLowerSorter("sort"))

	self.max_height = math.max((item_height+offset_y)*#show_list,self.scroll:getContentSize().height)
	self.scroll:setInnerContainerSize(cc.size(self.scroll:getContentSize().width,self.max_height))

	for k,v in ipairs(show_list) do
		delayRun(self.scroll,0.05*k,function ()
			local item = RecommandItem.new()
			item:setData(v)
			self.scroll:addChild(item)
			item:setPosition(5,self.max_height-3-(item_height+offset_y)*(k-1))
			self.item_list[k] = item

			item:setBtnCallBack(function ( cell )
				if self.cur_select ~= nil and (self.cur_index and self.cur_index~=k) then 
					self.cur_select:setSelect(false)
					self.cur_select:showMessagePanel(false)
				end
				self.cur_select = cell
				self.cur_index = k
				local status = self.cur_select:getIsShow()
				if status then 
					--位置缩回去
					self.scroll:setInnerContainerSize(cc.size(self.scroll:getContentSize().width,self.max_height))
					local height = self.max_height
					for k,v in pairs(self.item_list) do
						v:setPosition(5,height-3-(item_height+offset_y)*(k-1))
					end
					self.cur_select:setSelect(false)
					self.cur_select:showMessagePanel(false)
				else
					self.cur_select:setSelect(true)
					self.cur_select:showMessagePanel(true)
					self:adjustPos()
				end

				--调整一下scrollview位置
				--[[
				local percent = 0
				local scroll_height = self.max_height
				-- if self.height then 
				if self.is_show then
					-- scroll_height = self.max_height+170
					scroll_height = self.max_height+self.height
				end
				if self.cur_select then
					-- local offset_height = (self.cur_index - 1) * 136
					local offset_height = (self.cur_index - 1) * item_height
				     -- percent = (self.cur_select:getPositionY())/scroll_height * 100
				     -- local temp_percent = offset_height / self.max_height * 100
				     -- if self.height then
				     --  offset_height = (self.cur_index - 1) * 270
				     --  temp_percent = offset_height / scroll_height * 100
				     -- end
				     if self.is_show then
				     	offset_height = offset_height + self.height
				     end
				     -- local offset_height = scroll_height - self.cur_select:getPositionY()
				     local temp_percent = offset_height / scroll_height * 100
				     self.scroll:jumpToPercentVertical(math.ceil(temp_percent))
				end
				]]

				if self.cur_select then 
					local offset_height = (self.cur_index - 1) * 136
					local temp_percent = offset_height / self.max_height * 100
					if self.height then 
						offset_height = (self.cur_index - 1) * 230
						temp_percent = offset_height / (self.max_height+self.height) * 100
					end
					self.scroll:jumpToPercentVertical(math.ceil(temp_percent))
				end
			end)
		end)
	end
end

function RecommandPanel:adjustPos(  )
	if self.cur_select ~= nil then 
		-- self.scroll:setInnerContainerSize(cc.size(self.scroll:getContentSize().width,self.max_height+170))
		-- self.height = 170
		-- local height = self.max_height+170
		-- for k,v in pairs(self.item_list) do
		-- 	if k<=self.cur_index then 
		-- 		v:setPosition(5,height-3-(item_height+offset_y)*(k-1))
		-- 	else
		-- 		v:setPosition(5,height-3-170-(item_height+offset_y)*(k-1))
		-- 	end
		-- end

		self.height = self.cur_select.msg_panel:getContentSize().height or 170
		self.scroll:setInnerContainerSize(cc.size(self.scroll:getContentSize().width,self.max_height +self.height))
		local height = self.max_height+self.height
		for k,v in pairs(self.item_list) do
			if k<=self.cur_index then 
				v:setPosition(5,height-3-(item_height+offset_y)*(k-1))
			else
				v:setPosition(5,height-3-self.height-(item_height+offset_y)*(k-1))
			end
		end
	end
end

function RecommandPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)    
end

function RecommandPanel:register_event(  )
end

function RecommandPanel:DeleteMe()
	doStopAllActions(self.scroll)

	if self.item_list and self.item_list ~= nil then 
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end
	
end



-- --------------------------------------------------------------------
-- 变强 推荐阵容面板子项
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
RecommandItem = class("RecommandItem", function()
    return ccui.Widget:create()
end)

function RecommandItem:ctor()
	self.ctrl = StrongerController:getInstance()
	self.model = self.ctrl:getModel()
	self.role_vo = RoleController:getInstance():getRoleVo()
	self.item_list = {}

	self:configUI()
	self:register_event()
end

function RecommandItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("stronger/recommand_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,1)
    self:setCascadeOpacityEnabled(true)
	self:setContentSize(cc.size(item_width,item_height))
	self:setTouchEnabled(true)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.bg = self.main_container:getChildByName("bg")
    self.title = self.main_container:getChildByName("title")

    self.btn = self.main_container:getChildByName("btn")

    self.scroll_con = self.main_container:getChildByName("scroll_con")
    local scroll_view_size = self.scroll_con:getContentSize()
    local scale = 0.8
    local setting = {
        item_class = HeroExhibitionItem,      -- 单元类
        start_x = 2,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 2,                    -- 第一个单元的Y起点
        space_y = 2,                   -- y方向的间隔
        item_width = HeroExhibitionItem.Width*scale,               -- 单元的尺寸width
        item_height = HeroExhibitionItem.Height*scale,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
    	scale = scale
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.scroll_con, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
end

function RecommandItem:register_event(  )
	self.btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
        	playButtonSound2()
			if self.btn_callback then
				self:btn_callback()
			end
        end
    end)

    self:addTouchEventListener(function(sender, event_type) 
		if event_type == ccui.TouchEventType.ended then
				self.touch_end = sender:getTouchEndPosition()
				local is_click = true
				if self.touch_began ~= nil then
					is_click =
						math.abs(self.touch_end.x - self.touch_began.x) <= 20 and
						math.abs(self.touch_end.y - self.touch_began.y) <= 20
				end
				if is_click == true then
					playButtonSound2()
					if self.callback then
						self:callback()
					end
				end
			elseif event_type == ccui.TouchEventType.moved then
			elseif event_type == ccui.TouchEventType.began then
				self.touch_began = sender:getTouchBeganPosition()
			elseif event_type == ccui.TouchEventType.canceled then
			end
	end)
end

function RecommandItem:addCallBack( value )
	self.callback =  value
end

function RecommandItem:setBtnCallBack( value )
	self.btn_callback = value
end

function RecommandItem:getIsShow(  )
	return self.is_show
end

function RecommandItem:setData( data )
	self.data = data
	self.title:setString(data.name)
	local show_list = {}
	for k,v in ipairs(data.hero_list[1]) do
		local config = deepCopy(Config.PartnerData.data_partner_base[v])
		if config then
			table.insert(show_list, config)
		end
	end
	local extendData = {hide_star = true, scale = 0.73, can_click = true}
	local click_item_callback = function ( item, hero_vo )
		if hero_vo and hero_vo.bid then
			HeroController:getInstance():openHeroTipsPanelByBid(hero_vo.bid)
		end
	end
	self.item_scrollview:setData(show_list, click_item_callback, nil, extendData)
end

function RecommandItem:setSelect(bool)
	-- local res 
	-- if bool then 
	-- 	res = PathTool.getResFrame("common","common_1020")
	-- else
	-- 	res = PathTool.getResFrame("common","common_1029")
	-- end
	-- self.bg:loadTexture(res, LOADTEXT_TYPE_PLIST)
end

function RecommandItem:showMessagePanel( bool )
	self.is_show = bool
	if bool then 
		if self.msg_panel == nil then
			self:createMessagePanel()
		end
	end
	self.msg_panel:setVisible(bool)
end

function RecommandItem:createMessagePanel( )
	local default_height = 168
	local title_y = 150
	local desc_y = 129
	if self.msg_panel == nil then 
		local res = PathTool.getResFrame("common","common_1021")
		self.msg_panel = createScale9Sprite(res, 10, -5, LOADTEXT_TYPE_PLIST, self.main_container)
		self.msg_panel:setContentSize(cc.size(585,default_height))
		self.msg_panel:setAnchorPoint(0,1)
	end

	-- if not self.msg_touch_layer then
	-- 	self.msg_touch_layer = ccui.Layout:create()
	--     self.msg_touch_layer:setContentSize(585, 168)
	--     self.msg_touch_layer:setPosition(cc.p(585/2, 168/2))
	--     self.msg_touch_layer:setAnchorPoint(cc.p(0.5, 0.5))
	--     self.msg_touch_layer:setTouchEnabled(true)
	--     self.msg_panel:addChild(self.msg_touch_layer)
	--     self.msg_touch_layer:addTouchEventListener(function(sender, event_type)
	--         if event_type == ccui.TouchEventType.ended then
	--             if self.btn_callback then
	-- 				self:btn_callback()
	-- 			end
	--         end
	--     end)
	-- end

	-- local res = PathTool.getResFrame("common","common_1033")
	-- local line = createImage(self.msg_panel, res, 165, 147, cc.p(0.5,0.5), true)
	-- local line2 = createImage(self.msg_panel, res, 425, 147, cc.p(0.5,0.5), true)
	-- line2:setFlippedX(true)

	local title = createRichLabel(22, 175, cc.p(0.5,0.5), cc.p(self.msg_panel:getContentSize().width/2,title_y))
	title:setString(TI18N("阵容分析"))
	self.msg_panel:addChild(title)

	self.desc = createRichLabel(20, 175, cc.p(0,1), cc.p(20,desc_y), 5, 0, 550)
	self.msg_panel:addChild(self.desc)
	self.desc:setString(self.data.desc)

	self.msg_panel:setContentSize(cc.size(585,self.desc:getSize().height + self.title:getSize().height + 50))
	title:setPosition(self.msg_panel:getContentSize().width/2, self.msg_panel:getContentSize().height - (default_height - title_y) )
	self.desc:setPosition(20, self.msg_panel:getContentSize().height - (default_height - desc_y) )

	self.packup = createLabel(20,cc.c3b(164,127,81),nil,575,10,TI18N("收起"),self.msg_panel,nil,cc.p(1,0))

	if not self.msg_touch_layer then
		self.msg_touch_layer = ccui.Layout:create()
	    self.msg_touch_layer:setContentSize(585, self.msg_panel:getContentSize().height)
	    self.msg_touch_layer:setPosition(cc.p(585/2, self.msg_panel:getContentSize().height/2))
	    self.msg_touch_layer:setAnchorPoint(cc.p(0.5, 0.5))
	    self.msg_touch_layer:setTouchEnabled(true)
	    self.msg_panel:addChild(self.msg_touch_layer)
	    self.msg_touch_layer:addTouchEventListener(function(sender, event_type)
	        if event_type == ccui.TouchEventType.ended then
	            if self.btn_callback then
					self:btn_callback()
				end
	        end
	    end)
	end
end

function RecommandItem:DeleteMe()
	if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
	
end
