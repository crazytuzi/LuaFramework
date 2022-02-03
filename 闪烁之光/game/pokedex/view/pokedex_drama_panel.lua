--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-10-12 17:51:47
-- @description    : 
		-- 剧情回顾
---------------------------------
PokedexDramaLookPanel = class("PokedexDramaLookPanel", function()
    return ccui.Widget:create()
end)

function PokedexDramaLookPanel:ctor( callback )
	self.ctrl = BattleDramaController:getInstance()

	self.callback = callback
	self.cur_type = 1 -- 当前显示的类型（1章节名 2章节内容）
	self.stack_item = {}
	self.stack_pool = {}
	self.stack_max = 3 -- 最多创建个数
	self.capter_data = {}

	self:configUI()
	self:register_event()
end

function PokedexDramaLookPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("pokedex/pokedex_drama_panel"))
	self.root_wnd:setPosition(0,0)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.title_panel = self.main_container:getChildByName("title_panel")
    self.content_panel = self.main_container:getChildByName("content_panel")

    self.title_list = self.title_panel:getChildByName("title_list")
    self.content_list = self.content_panel:getChildByName("content_list")

    self:changeViewTypeShow(1)
end

function PokedexDramaLookPanel:initTitlePanel(  )
	local scroll_view_size = self.title_list:getContentSize()
    local setting = {
        item_class = PokedexDramaTitleItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 5,                   -- y方向的间隔
        item_width = 620,               -- 单元的尺寸width
        item_height = 76,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1                         -- 列数，作用于垂直滚动类型
    }

    self.title_scrollview = CommonScrollViewLayout.new(self.title_list, cc.p(0,5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.title_scrollview:setSwallowTouches(false)

    self:refreshTitleList()
end

function PokedexDramaLookPanel:initContentPanel(  )
	local scroll_view_size = self.content_list:getContentSize()
	self.content_scrollview = createScrollView(scroll_view_size.width,scroll_view_size.height,0,0,self.content_list)
	self.content_scrollview:setSwallowTouches(false)
	self.content_scroll_view_size = scroll_view_size
	self.content_container = self.content_scrollview:getInnerContainer()

	self.content_scrollview:addEventListener(function(sender, eventType)
        if eventType == ccui.ScrollviewEventType.containerMoved then
            self:checkRectIntersectsRect()
        end
    end)

	local bg_title = self.content_panel:getChildByName("bg_title")
	local bg_title_size = bg_title:getContentSize()
    self.content_title_label = createLabel(26,cc.c3b(104,69,42),nil,bg_title_size.width/2,bg_title_size.height/2+10,"",bg_title,nil,cc.p(0.5, 0.5))
end

function PokedexDramaLookPanel:changeViewTypeShow( viewType )
	if viewType == 1 then
		if not self.init_title then
			self.init_title = true
			self:initTitlePanel()
		end
		--[[if self.content_scrollview then
			self.content_scrollview:removeAllChildren()
		end--]]
		--[[self.stack_item = {}
		self.stack_pool = {}
		self.last_pos_y = nil--]]
		for k,item in pairs(self.stack_item) do
			item:setVisible(false)
		end
	elseif viewType == 2 then
		if not self.init_content then
			self.init_content = true
			self:initContentPanel()
		end
		self:refreshContentList()
		if self.callback then
			self.callback(true)
		end
	end
	self.title_panel:setVisible(viewType == 1)
	self.content_panel:setVisible(viewType == 2)
end

function PokedexDramaLookPanel:showPlayingDunDrama( dun_id )
	local config_data = Config.DramaChatData.data_info[dun_id]
	if config_data then
		local capter_id = config_data.bid
		self:_onClickTitleItemCallBack(dun_id, capter_id)
	end
end

function PokedexDramaLookPanel:refreshTitleList(  )
	if self.title_scrollview then
		local title_data = self:getAllDramaTitleData()
		self.title_scrollview:setData(title_data, handler(self, self._onClickTitleItemCallBack))
	end
end

function PokedexDramaLookPanel:_onClickTitleItemCallBack( dun_id, capter_id )
	self.cur_dun_id = dun_id
	self.cur_capter_id = capter_id
	self:changeViewTypeShow(2)
end

-- 获取所有章节名称数据
function PokedexDramaLookPanel:getAllDramaTitleData(  )
	local title_data = {}
	local temp_data = {}
	-- 取出每个章节关卡id最小的数据，进入剧情时会根据关卡id来滚动到相应的位置
	for k,config in pairs(Config.DramaChatData.data_info) do
		temp_data[config.bid] = temp_data[config.bid] or {}
		table.insert(temp_data[config.bid], config)
	end

	for bid,datalist in pairs(temp_data) do
		local temp_drama = {}
		for k,config in pairs(datalist) do
			if not temp_drama.id or temp_drama.id > config.id then
				temp_drama = deepCopy(config)
			end
		end
		if next(temp_drama) ~= nil then
			table.insert(title_data, temp_drama)
		end
	end

	local function sortFunc( objA, objB )
		return objA.bid < objB.bid
	end
	table.sort(title_data, sortFunc)
	return title_data
end

-- 获取对应章节的所有已开启的数据
function PokedexDramaLookPanel:getOneCapterData( capter_id )
	local capter_data = {}
	local dunData = BattleDramaController:getInstance():getModel():getDramaData()
	if not dunData then return {} end
	for k,config in pairs(Config.DramaChatData.data_info) do
		if config.bid == capter_id and dunData.dun_id > config.id then
			local temp_data = deepCopy(config)
			table.insert(capter_data, temp_data)
		end
	end

	local function sortFunc( objA, objB )
		return objA.id < objB.id
	end
	table.sort(capter_data, sortFunc)
	return capter_data
end

function PokedexDramaLookPanel:checkRectIntersectsRect(  )
	local item_list = self.stack_item
	local pool_list = self.stack_pool

	if item_list == nil or tableLen(self.capter_data) <= self.stack_max then 
		return
	end

	local container_y = self.content_container:getPositionY()
    if self.last_pos_y == nil then
        self.last_pos_y = container_y 
    end

    local sum = #item_list 
    local container_y_abs = math.abs( container_y )

    for k, item in pairs(item_list) do
        local need_clear = false
        local item_y = item:getPositionY()
        local item_size = item:getContentSize()
        if container_y > 0 then
            if item_y > (self.content_scroll_view_size.height - container_y + 30) then
                need_clear = true
            end
        else
            if item_y  < (container_y_abs - item_size.height) then
                need_clear = true
            elseif item_y > (container_y_abs + self.content_scroll_view_size.height + 30) then
                need_clear = true
            end
        end
        if need_clear == true then
            item:setVisible(false)
            table.insert(pool_list, item)
            item_list[k] = nil
        end
    end
    self:supplementItemList(item_list, self.last_pos_y, container_y)
    self.last_pos_y = container_y
end

function PokedexDramaLookPanel:supplementItemList( item_list, last_y, cur_y )
	if item_list == nil or tableLen(item_list) == 0 or tableLen(self.capter_data) <= self.stack_max then 
		return
	end
    local cur_table_num = tableLen(item_list)

    if cur_table_num < self.stack_max then
        local min_index = 0
        local max_index = 0
        for k,item in pairs(item_list) do
            if min_index == 0 then
                min_index = item.tmp_index
            end
            if max_index == 0 then
                max_index = item.tmp_index
            end
            if min_index >= item.tmp_index then
                min_index = item.tmp_index 
            end
            if max_index <= item.tmp_index then
                max_index = item.tmp_index 
            end
        end
        if cur_y > last_y then -- 向上,那么就创建到下面
            for i=1,(self.stack_max-cur_table_num) do
            	if self.capter_data[max_index+i] then
            		self:createDramaContentItem(self.capter_data[max_index+i])
            	end
            end
        else
            for i=1,(self.stack_max - cur_table_num) do
                if (min_index -i) > 0 then
                	if self.capter_data[min_index-i] then
                		self:createDramaContentItem(self.capter_data[min_index-i])
                	end
                end
            end 
        end
    end
end

function PokedexDramaLookPanel:refreshContentList(  )
	if self.cur_dun_id and self.cur_capter_id then
		local capter_data = self:getOneCapterData(self.cur_capter_id)

		-- 章节名称
		if capter_data and capter_data[1] then
			local capter_str = string.format(TI18N("第%d章   %s"), capter_data[1].bid, capter_data[1].name)
			self.content_title_label:setString(capter_str)
		end

		local innerSizeHeight = 0
		for i,data in ipairs(capter_data) do
			data._index = i
			innerSizeHeight = innerSizeHeight + data.height
		end
		innerSizeHeight = math.max(innerSizeHeight, self.content_scroll_view_size.height)

		local temp_height = 0
		local start_index = 1
		local start_percent = 0
		for i,data in ipairs(capter_data) do
			if self.cur_dun_id == data.id then
				start_index = i - 1
				start_percent = temp_height/innerSizeHeight*100
			end
			local pos_y = innerSizeHeight - temp_height - data.height
			temp_height = temp_height + data.height
			data._pos = cc.p(0, pos_y)
		end

		if start_index < 1 or #capter_data <= 3 then
			start_index = 1
		elseif (start_index + 2) > #capter_data then
			start_index = #capter_data - 2
		end
		self.content_scrollview:setInnerContainerSize(cc.size(self.content_scroll_view_size.width, innerSizeHeight))

		self.capter_data = capter_data

		local temp_index = 0
		if self.time_ticket == nil and next(self.capter_data or {}) ~= nil then
            self.time_ticket = GlobalTimeTicket:getInstance():add(function()
                if self.capter_data == nil then
                    self:clearTimeTicket()
                else
                    local data = self.capter_data[start_index]
                    if data ~= nil then
                        self:createDramaContentItem(data)
                    end
                    start_index = start_index + 1
                    temp_index = temp_index + 1
                    if temp_index >= 3 then
                        self:clearTimeTicket()
                    end
                end
            end, 4 / display.DEFAULT_FPS)
        end

        self.content_scrollview:scrollToPercentVertical(start_percent,0.1,true)
	end
end

function PokedexDramaLookPanel:clearTimeTicket()
	if self.time_ticket ~= nil then
		GlobalTimeTicket:getInstance():remove(self.time_ticket)
		self.time_ticket = nil
	end
end

function PokedexDramaLookPanel:createDramaContentItem( data )
	self:onCheckDeleteContentItem()
	local contentItem = table.remove(self.stack_pool, 1)
	if contentItem == nil then
		contentItem = PokedexDramaContentItem.new()
		self.content_scrollview:addChild(contentItem)
	else
		contentItem:setVisible(true)
	end
	contentItem.tmp_index = data._index
	contentItem:setData(data)

	self.stack_item[#self.stack_item+1] = contentItem
	return contentItem
end

function PokedexDramaLookPanel:onCheckDeleteContentItem(  )
	if #self.stack_item >= self.stack_max then
        local del_item = table.remove(self.stack_item, 1)
        if del_item then
        	del_item:setVisible(false)
        	table.insert(self.stack_pool, del_item)
        end
    end
end

function PokedexDramaLookPanel:register_event(  )
	
end

function PokedexDramaLookPanel:DeleteMe(  )
	self:clearTimeTicket()

	for k,v in pairs(self.stack_item) do
		if v.DeleteMe then
			v:DeleteMe()
		end
	end

	for k,v in pairs(self.stack_pool) do
		if v.DeleteMe then
			v:DeleteMe()
		end
	end

	if self.title_scrollview then
		self.title_scrollview:DeleteMe()
		self.title_scrollview = nil
	end
end

-------------------------------------------------
--@ 章节名称 item
PokedexDramaTitleItem = class("PokedexDramaTitleItem", function()
    return ccui.Widget:create()
end)

function PokedexDramaTitleItem:ctor()
	self:configUI()
	self:register_event()
end

function PokedexDramaTitleItem:configUI(  )
	self.size = cc.size(620,76)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("pokedex/pokedex_drama_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.title_label = self.main_container:getChildByName("title_label")
    self.name_label = self.main_container:getChildByName("name_label")

    self.bg = self.main_container:getChildByName("bg")
    self.bg:setSwallowTouches(false)
end

function PokedexDramaTitleItem:register_event(  )
	self.bg:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.is_open then
				if self.callback then
					self.callback(self.data.id, self.data.bid)
				end
			elseif self.data and self.data.id then
				local config = Config.DungeonData.data_drama_dungeon_info(self.data.id)
				if config then
					message(string.format(TI18N("通关%s开启"), config.name))
				end
			end
		end
	end)

	-- 关卡更新
	if not self.update_drama_dun_event then
        self.update_drama_dun_event = GlobalEvent:getInstance():Bind(Battle_dramaEvent.BattleDrama_Update_Dun_Id,function ()
            self:refreshOpenStatus()
        end)
    end
end

function PokedexDramaTitleItem:setData( data )
	self.data = data or {}

	self.title_label:setString(string.format(TI18N("第%d章"), data.bid))
	self.name_label:setString(TI18N(data.name))

	self:refreshOpenStatus()
end

-- 是否已经开启
function PokedexDramaTitleItem:refreshOpenStatus(  )
	self.is_open = false
	local dunData = BattleDramaController:getInstance():getModel():getDramaData()
	if self.data and dunData and dunData.dun_id > self.data.id then
		self.is_open = true
		setChildUnEnabled(false, self)
		self.title_label:setTextColor(cc.c4b(104,69,42,255))
		self.name_label:setTextColor(cc.c4b(104,69,42,255))
	else
		self.is_open = false
		setChildUnEnabled(true, self)
		self.title_label:setTextColor(cc.c4b(58,58,58,255))
		self.name_label:setTextColor(cc.c4b(58,58,58,255))
	end
end

function PokedexDramaTitleItem:addCallBack( callback )
	self.callback = callback
end

function PokedexDramaTitleItem:DeleteMe(  )
	if self.update_drama_dun_event then
        GlobalEvent:getInstance():UnBind(self.update_drama_dun_event)
        self.update_drama_dun_event = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end

-------------------------------------------------
--@ 章节内容 item
PokedexDramaContentItem = class("PokedexDramaContentItem", function()
    return ccui.Widget:create()
end)

function PokedexDramaContentItem:ctor()
	self.ctrl = BattleDramaController:getInstance()

	self:configUI()
	self:register_event()
end

function PokedexDramaContentItem:configUI(  )
	self:setAnchorPoint(cc.p(0, 0))

	self.title_bg = createImage(self, PathTool.getResFrame("pokedex","pokedex_37"), 0, 0, cc.p(0.5, 0.5), true, 1, true)
	self.title_bg:setScale9Enabled(true)
    self.title_bg:setCapInsets(cc.rect(138, 19, 1, 1))
    self.title_bg:setContentSize(cc.size(520, 38))

    self.title_label = createLabel(26,cc.c3b(254,242,222),nil,520/2,38/2,"",self.title_bg,nil,cc.p(0.5, 0.5))

    self.lable_list = {}
end

function PokedexDramaContentItem:register_event(  )
	
end

function PokedexDramaContentItem:setData( data )
	if not data then return end
	self.size = cc.size(630, data.height)

	self:setContentSize(self.size)
	self:setPosition(data._pos)

	self.title_bg:setPosition(cc.p(self.size.width/2, self.size.height-30))

	self.title_label:setString(data.title)

	-- 旁白和剧情内容
	local temp_drama = {}
	local temp_msg = ""
	for i,content in ipairs(data.content) do
		if not content[2] or content[2] == "" then
			if temp_msg ~= "" then
				local msg_data = {}
				msg_data.flag = 2 -- 对话
				msg_data.msg = WordCensor:getInstance():relapceFaceIconTag(temp_msg)[2]
				table.insert(temp_drama, msg_data)
				temp_msg = ""
			end

			local aside_data = {}
			aside_data.flag = 1 -- 旁白
			aside_data.msg = content[3] or ""
			table.insert(temp_drama, aside_data)
		else
			local name_str = string.format("<div fontcolor=#aa5a3f>%s</div>", content[2])
			temp_msg = temp_msg .. name_str .. ": " .. content[3] .. " \n"
			if i == #data.content then
				local msg_data = {}
				msg_data.flag = 2 -- 对话
				msg_data.msg = WordCensor:getInstance():relapceFaceIconTag(temp_msg)[2]
				table.insert(temp_drama, msg_data)
			end
		end
	end
	
	for k,label in pairs(self.lable_list) do
		label:setVisible(false)
	end
	local start_y = self.size.height - 80
	local temp_y = 0
	local space_y = 40
	local max_width = {
		[1] = 560,
		[2] = 560
	}
	local start_x = {
		[1] = 40,
		[2] = 40
	}
	for i,drama_data in ipairs(temp_drama) do
		local label = self.lable_list[i]
		if not label then
			label = createRichLabel(24, cc.c3b(104,69,42), cc.p(0, 0), nil, 15)
			self:addChild(label)
			table.insert(self.lable_list, label)
		end
		label:setVisible(true)
		label:setMaxWidth(max_width[drama_data.flag])
		label:setString(drama_data.msg)
		local label_size = label:getContentSize()
		local pos_y = start_y - temp_y - label_size.height - space_y*(i-1)
		local pos_x = start_x[drama_data.flag]
		label:setPosition(cc.p(pos_x, pos_y))
		temp_y = temp_y + label_size.height
	end
end

function PokedexDramaContentItem:DeleteMe(  )
	
end