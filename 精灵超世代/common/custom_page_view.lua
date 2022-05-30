--[[
封装分页组件，集合左右按钮/光点, 滚动创建每页视图
author:hp
使用例子:
	local function createPage(data_list, page, layout)
		--外部创建每一页视图（外部控制显示内容）
	end
	local page_view = CustomPageView.new(cc.size(500), true, true)
    page_view.per_page = 18
    page_view:addCreatePageCallBack(createPage)
    page_view:setViewData({}})
    self:addChild(self.scroll_view)
--]]
CustomPageView = class("CustomPageView", function()
    return cc.Node:create()
end)

function CustomPageView:ctor(size, is_arrow, is_light, light_gap, light_y,tot_page)
	self.view_size = size      --滚动大小
	self.is_arrow = is_arrow   --显示左右按钮
	self.is_light = is_light   --显示分页光点
	self.cur_page = 1          --当前页码
	self.tot_page = tot_page or 2          --总页码
	self.per_page = 1          --每页数量
	self.light_gap = light_gap or 20      --光点间距
	self.light_y   = light_y or 20        --光点Y轴
	self:init()
end

function CustomPageView:init()

	--分页组件
    self.page_view = ccui.PageView:create()
    self.page_view:setTouchEnabled(true)
    self.page_view:setContentSize(self.view_size)
    self:addChild(self.page_view)
    --滚动处理
    local pageViewEvent = function(sender, eventType)
        self:pageViewTurning(sender, eventType)
    end
    self.page_view:addEventListener(pageViewEvent)
	self:showArrow()
    self:showLight()
	--self:MoveFadeIn()
    -- showLayoutRect(self.page_view)
end

--显示左右按钮
function CustomPageView:showArrow()
	if not self.is_arrow then return end
	if not self.left_btn then
		self.right_btn = ccui.Button:create(PathTool.getResFrame("common","common_90034"), "", "", LOADTEXT_TYPE_PLIST)
	    self.right_btn:setPosition(self.view_size.width-28, self.view_size.height/2)
	    self:addChild(self.right_btn, 1)
	    self.right_btn:addTouchEventListener(function(sender, event_type)
	        if event_type == ccui.TouchEventType.ended then
				local target_index = self.page_view:getCurrentPageIndex() + 1
	            doScrollToPage(self.page_view, target_index)
	        end
	    end)

	    self.left_btn = ccui.Button:create(PathTool.getResFrame("common","common_90034"), "", "", LOADTEXT_TYPE_PLIST)
    	self.left_btn:setPosition(28, self.view_size.height/2)
    	self.left_btn:setScaleX(-1)
    	self:addChild(self.left_btn, 1)
    	self.left_btn:addTouchEventListener(function(sender, event_type)
	        if event_type == ccui.TouchEventType.ended then
				local target_index = self.page_view:getCurrentPageIndex() - 1
	            doScrollToPage(self.page_view, target_index)
	        end
	    end)
	end
end

--显示光点
function CustomPageView:showLight()
	if not self.is_light then return end
	if not self.lights then
		self.lights = {}
	end
	local len = #self.lights
	local count = self.tot_page
	local light_list = {}
	while count > 0 do
		count = count - 1
		local icon
		if #self.lights > 0 then
			icon = table.remove(self.lights)
		else
			icon = ccui.ImageView:create()
			self:addChild(icon)
		end
		table.insert(light_list, icon)
	end
	for k, v in pairs(self.lights) do
		v:removeFromParent()
		v = nil
	end
	self.lights = nil
	self.lights = light_list
	self:adjustLightPos(self.light_gap, self.light_y)
end

--调整光点坐标
function CustomPageView:adjustLightPos(gap, pos_y, offset_x)
	if not self.lights then return end
	self.light_gap = gap or 10
	self.light_y = pos_y or 10
	offset_x = offset_x or 0
	local width = 0
	local icon_w = 12
	for i=1, #self.lights do
		width = width + icon_w + self.light_gap
	end
	if offset_x == nil then offset_x = 0 end
	local start_x = (self.view_size.width - width)*0.5 + offset_x
	for i=1, #self.lights do
		--self.lights[i]:setPosition(cc.p(start_x+(i-1)*(self.lights[i]:getContentSize().width+self.light_gap),self.light_y))
		self.lights[i]:setPosition(start_x,self.light_y)
		start_x = start_x + icon_w + self.light_gap
	end
end


--调整案头位置
function CustomPageView:adjustArrowGap(gap)
	if self.left_btn then
	    self.left_btn:setPosition(cc.p(-gap, self.view_size.height/2))
    	self.right_btn:setPosition(cc.p(self.view_size.width+gap, self.view_size.height/2))
	end
end

function CustomPageView:adjustArrowPos(pos1_x, pos2_x, pos_y)
	if self.left_btn then
		self.left_btn:setPosition(self.left_btn:getPositionX()+pos1_x, self.left_btn:getPositionY()+pos_y)
		self.left_btn:setPosition(self.left_btn:getPositionX()+pos2_x, self.left_btn:getPositionY()+pos_y)
	end
end

--显示页码数据
function CustomPageView:showPage(page)
	if page>self.tot_page or page< 1 then return end
	self.cur_page = page
	if self.is_light and self.lights then
		local light, is_shine
		for i=1, #self.lights do
			light = self.lights[i]
			if i == page then
				is_shine = true
			else
				is_shine = false
			end
			if is_shine ~= light.shine then
				light.shine = is_shine
				if is_shine then

					light:loadTexture(PathTool.getResFrame("common","common_1065"), LOADTEXT_TYPE_PLIST)
				else
					light:loadTexture(PathTool.getResFrame("common","common_1066"), LOADTEXT_TYPE_PLIST)
				end
			end
		end
	end
    if self.is_arrow then
	    if self.cur_page == 1 and self.cur_page < self.tot_page then
	        setChildUnEnabled(true, self.left_btn)
	        self.left_btn:setTouchEnabled(false)
	        setChildUnEnabled(false, self.right_btn)
	        self.right_btn:setTouchEnabled(true)
	    elseif self.cur_page == 1 and self.cur_page >= self.tot_page then
	        setChildUnEnabled(true, self.left_btn)
	        self.left_btn:setTouchEnabled(false)
	        setChildUnEnabled(true, self.right_btn)
	        self.right_btn:setTouchEnabled(false)
	    elseif self.cur_page > 1 and self.cur_page < self.tot_page then
	        setChildUnEnabled(false, self.left_btn)
	        self.left_btn:setTouchEnabled(true)
	        setChildUnEnabled(false, self.right_btn)
	        self.right_btn:setTouchEnabled(true)
	    elseif self.cur_page > 1 and self.cur_page == self.tot_page then
	        setChildUnEnabled(false, self.left_btn)
	        self.left_btn:setTouchEnabled(true)
	        setChildUnEnabled(true, self.right_btn)
	        self.right_btn:setTouchEnabled(false)
	    end
	end
end

--分页滚动处理
function CustomPageView:pageViewTurning(sender, eventType)
    if eventType == ccui.PageViewEventType.turning then
		local cur_page = self.page_view:getCurrentPageIndex()
        if self.cur_page ~= (cur_page + 1) then
            self.cur_page = cur_page + 1
            --给外面的回调
            if self.turn_call_back then
                self.turn_call_back(self.cur_page, self.pages_num)
            end
            --翻页的时候，创建下一页的数据
            if (self.cur_page + 1) <= self.tot_page and self.cur_page == self.page_view:getChildrenCount() then
            	delayRun(self, 0.05, function ()
            		self:createPageItem(self.cur_page)
            	end)
            end
        	self:showPage(self.cur_page)
        end
    end
end

function CustomPageView:MoveFadeIn()
        local function onTouchBegan(touch, event)
            local touch_pos = touch:getLocation()
            local node_pos = self.page_view:convertToNodeSpace(touch_pos)
            -- 点击的范围在这里面才有效
            if node_pos.x > 0 and node_pos.y > 0 and node_pos.x < self.page_view:getContentSize().width and node_pos.y < self.page_view:getContentSize().height and self.tot_page >= 2  then
                self.page_view:setOpacity(55)
                self.cur_Location = true 
            else
                self.cur_Location = false
                return false
            end
            return true
	    end

	    local function onTouchMoved(touch, event)
	       self.page_view:runAction(cc.Sequence:create(cc.FadeOut:create(0.3)))
	    end

	    local function onTouchEnded(touch, event)
	        self.page_view:setOpacity(255)
	        self.page_view:runAction(cc.Sequence:create(cc.FadeIn:create(0.3)))
	    end

	    local listener = cc.EventListenerTouchOneByOne:create()
	    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
	    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
	    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
	    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self.page_view)
end

--增加翻页的回调
function CustomPageView:addTurnCallBack(call_back)
    self.turn_call_back = call_back
end

--创建页面的回调
function CustomPageView:addCreatePageCallBack(call_back)
	self.create_call_back = call_back
end

--设置滚动数据，处理分页
function CustomPageView:setViewData(data_list)
	self.data_list = data_list
    self.tot_page = math.floor((#data_list-1)/self.per_page) + 1
    self.cur_page = 1
    --一开始加载创建页码
    local len_arr = 1
    if self.cur_page == 1 and self.tot_page >= 2 then
        len_arr = 2
    end
    for i = 1 , len_arr do
        self:createPageItem(i-1)
    end
    if self.turn_call_back then
        self.turn_call_back(self.cur_page, self.pages_num)
    end
    delayRun(self.page_view, 0.05, function() doScrollToPage(self.page_view, 2) end)
    self:showPage(1)
    if self.lights and (#self.lights ~=self.tot_page) then
    	self:showLight()
    end
end

--创建页面内容
function CustomPageView:createPageItem(page)
    local layout = self.page_view:getItem(page)
    if not layout then
        layout = ccui.Layout:create()
        layout:setCascadeOpacityEnabled(true)
        layout:setContentSize(self.view_size)
        self.page_view:insertPage(layout, page)
        self.page_view:setCurrentPageIndex(math.max(0,self.page_view:getCurrentPageIndex()))
        if self.create_call_back then
        	self.create_call_back(self.data_list, page+1, layout)
        end
    end
end

-- 移除创建对象
function CustomPageView:removeAllLayouts()
	self.page_view:removeAllPages()
end

function CustomPageView:removePageAtIndex(idx)
	self.page_view:removePageAtIndex(idx)
end

--销毁数据
function CustomPageView:dispose()
	self:removeAllChildren()
	if self:getParent() then
		self:removeFromParent()
	end
end
