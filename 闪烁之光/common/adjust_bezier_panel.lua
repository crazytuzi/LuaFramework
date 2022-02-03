--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-04-10 15:56:42
-- @description    : 
		-- 调试贝塞尔曲线界面
---------------------------------
AdjustBezierPanel = AdjustBezierPanel or BaseClass(CommonUI)

function AdjustBezierPanel:__init(ctrl)
    self.view_tag = ViewMgrTag.DEBUG_TAG
    self:createRootWnd()

    self.node_list = {}
    self.is_open = true
end

function AdjustBezierPanel:createRootWnd(  )
	self.root_wnd = ccui.Layout:create()
    self.root_wnd:setTouchEnabled(true)
    self.root_wnd:setContentSize(cc.size(SCREEN_WIDTH,SCREEN_HEIGHT))
    self.root_wnd:setAnchorPoint(0,0)

    self.mask_bg = ccui.Layout:create()
    self.mask_bg:setContentSize(cc.size(SCREEN_WIDTH,SCREEN_HEIGHT))
    self.mask_bg:setAnchorPoint(0,0)
    self.mask_bg:setBackGroundColor(cc.c3b(80,80,80))
    self.mask_bg:setBackGroundColorOpacity(255)
    self.mask_bg:setBackGroundColorType(1)
    self.root_wnd:addChild(self.mask_bg)

    ViewManager:getInstance():getLayerByTag(self.view_tag):addChild(self.root_wnd)

    self.close_btn = CustomButton.New(self.root_wnd,PathTool.getResFrame("common", "common_1028"),nil,nil,LOADTEXT_TYPE_PLIST)
    self.close_btn:setPosition(cc.p(680, 1000))
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
	    	self:hide()
        end
    end)

    local editbox_1_name = createLabel(26, 1, nil,100, 1040, "背景透明度", self.root_wnd, nil, cc.p(0.5, 0.5))
    self.editbox_1 = createEditBox(self.root_wnd, PathTool.getResFrame("common", "common_90018"), cc.size(100, 45), nil, 25, nil, 25, nil, nil, nil, LOADTEXT_TYPE_PLIST)
    self.editbox_1:setPosition(cc.p(100, 1000))
    self.editbox_1:registerScriptEditBoxHandler(function(strEventName,pSender)
        if strEventName == "return" then 
        	local text = pSender:getText()
        	if tonumber(text) then
        		self.mask_bg:setBackGroundColorOpacity(tonumber(text))
        	end
        end
    end)

    local editbox_2_name = createLabel(26, 1, nil,200, 1040, "起点", self.root_wnd, nil, cc.p(0.5, 0.5))
    self.editbox_2 = createEditBox(self.root_wnd, PathTool.getResFrame("common", "common_90018"), cc.size(60, 45), nil, 25, cc.c3b(255, 255, 255), 25, "X", nil, nil, LOADTEXT_TYPE_PLIST)
    self.editbox_2:setPosition(cc.p(200, 1000))
    self.editbox_3 = createEditBox(self.root_wnd, PathTool.getResFrame("common", "common_90018"), cc.size(60, 45), nil, 25, cc.c3b(255, 255, 255), 25, "Y", nil, nil, LOADTEXT_TYPE_PLIST)
    self.editbox_3:setPosition(cc.p(200, 960))

    local editbox_3_name = createLabel(26, 1, nil,300, 1040, "终点", self.root_wnd, nil, cc.p(0.5, 0.5))
    self.editbox_4 = createEditBox(self.root_wnd, PathTool.getResFrame("common", "common_90018"), cc.size(60, 45), nil, 25, cc.c3b(255, 255, 255), 25, "X", nil, nil, LOADTEXT_TYPE_PLIST)
    self.editbox_4:setPosition(cc.p(300, 1000))
    self.editbox_5 = createEditBox(self.root_wnd, PathTool.getResFrame("common", "common_90018"), cc.size(60, 45), nil, 25, cc.c3b(255, 255, 255), 25, "Y", nil, nil, LOADTEXT_TYPE_PLIST)
    self.editbox_5:setPosition(cc.p(300, 960))

    local editbox_4_name = createLabel(26, 1, nil,400, 1040, "中间点", self.root_wnd, nil, cc.p(0.5, 0.5))
    self.editbox_6 = createEditBox(self.root_wnd, PathTool.getResFrame("common", "common_90018"), cc.size(60, 45), nil, 25, cc.c3b(255, 255, 255), 25, "X", nil, nil, LOADTEXT_TYPE_PLIST)
    self.editbox_6:setPosition(cc.p(400, 1000))
    self.editbox_7 = createEditBox(self.root_wnd, PathTool.getResFrame("common", "common_90018"), cc.size(60, 45), nil, 25, cc.c3b(255, 255, 255), 25, "Y", nil, nil, LOADTEXT_TYPE_PLIST)
    self.editbox_7:setPosition(cc.p(400, 960))
    self.editbox_8 = createEditBox(self.root_wnd, PathTool.getResFrame("common", "common_90018"), cc.size(60, 45), nil, 25, cc.c3b(255, 255, 255), 25, "X", nil, nil, LOADTEXT_TYPE_PLIST)
    self.editbox_8:setPosition(cc.p(500, 1000))
    self.editbox_9 = createEditBox(self.root_wnd, PathTool.getResFrame("common", "common_90018"), cc.size(60, 45), nil, 25, cc.c3b(255, 255, 255), 25, "Y", nil, nil, LOADTEXT_TYPE_PLIST)
    self.editbox_9:setPosition(cc.p(500, 960))

    self.ok_btn = CustomButton.New(self.root_wnd,PathTool.getResFrame("common", "common_1042"),nil,nil,LOADTEXT_TYPE_PLIST)
    self.ok_btn:setSize(cc.size(164,69))
    self.ok_btn:setPosition(cc.p(580, 860))
    self.ok_btn:setBtnLabel(TI18N("确定"))
    self.ok_btn:setBtnLableColor(Config.ColorData.data_color4[174])
    self.ok_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
	    	self:onClickOkBtn()
        end
    end)
end

function AdjustBezierPanel:open(  )
	self.root_wnd:setVisible(true)
	self.root_wnd:setPosition(cc.p(0, 0))
	self.is_open = true
end

function AdjustBezierPanel:hide(  )
	self.root_wnd:setVisible(false)
	self.root_wnd:setPosition(cc.p(-1000, 0))
	self.is_open = false
end

function AdjustBezierPanel:isOpen(  )
	return self.is_open
end

function AdjustBezierPanel:onClickOkBtn(  )
	local start_x = tonumber(self.editbox_2:getText()) or 400
	local start_y = tonumber(self.editbox_3:getText()) or 400
	local end_x = tonumber(self.editbox_4:getText()) or 700
	local end_y = tonumber(self.editbox_5:getText()) or 700
	local pos_1_x = tonumber(self.editbox_6:getText()) or 500
	local pos_1_y = tonumber(self.editbox_7:getText()) or 700
	local pos_2_x = tonumber(self.editbox_8:getText()) or 0
	local pos_2_y = tonumber(self.editbox_9:getText()) or 0

	local posData = {}
	table.insert(posData, cc.p(start_x, start_y))
	if pos_1_x ~= 0 and pos_1_y ~= 0 then
		table.insert(posData, cc.p(pos_1_x, pos_1_y))
	end
	if pos_2_x ~= 0 and pos_2_y ~= 0 then
		table.insert(posData, cc.p(pos_2_x, pos_2_y))
	end
	table.insert(posData, cc.p(end_x, end_y))

	local distance = math.sqrt(math.pow(end_x-start_x, 2) + math.pow(end_y-start_y, 2))
	local add_value = 1/(distance/20)

	local pos_list = {}
    local time = 0
	while time < 1 do
		local pos = self:getBezierPos(posData, time)
		table.insert(pos_list, pos)
		time = time + add_value
	end

	for k,v in pairs(self.node_list) do
		v:setVisible(false)
	end
	for i,pos in ipairs(pos_list) do
		local node = self.node_list[i]
		if not node then
			node = createSprite(PathTool.getResFrame("common","common_1066"), pos.x, pos.y, self.root_wnd, cc.p(0.5, 0.5))
			self.node_list[i] = node
		end
		node:setPosition(pos)
		node:setVisible(true)
	end
end

function AdjustBezierPanel:factorial(n)
	if n == 0 then
		return 1
	else
		return n * self:factorial(n - 1)
	end
end 

function AdjustBezierPanel:getBezierPos(posData,t)
    local n = #posData -1
    local x = 0
    local y = 0
    for idx,pos in pairs(posData) do 
        x = x + pos.x *(self:factorial(n)/(self:factorial(n-idx+1)*self:factorial(idx-1))) * math.pow(1-t,n-idx+1) * math.pow(t,idx-1)
        y = y + pos.y *(self:factorial(n)/(self:factorial(n-idx+1)*self:factorial(idx-1))) * math.pow(1-t,n-idx+1) * math.pow(t,idx-1)
    end
    return cc.p(x,y)
end

function AdjustBezierPanel:__close()
    --移除
    doRemoveFromParent(self.root_wnd)
end

function AdjustBezierPanel:close()
    if tolua.isnull(self.root_wnd) then return end
    self:__close()
end
