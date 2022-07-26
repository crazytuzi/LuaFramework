
UILoginChoose ={}

UILoginChoose.scrollView= nil
UILoginChoose.listItem  = nil

local function setStateIcon(item,_state)
	local state = tonumber(_state)
	local iconBao = item:getChildByName("image_bao")
	local iconNew = item:getChildByName("image_new")
	iconBao:setVisible(false)
	iconNew:setVisible(false)
	if state == 1 then
		iconBao:setVisible(true)
	elseif state == 4 then
		iconNew:setVisible(true)
	end
end

local function setScrollViewItem(item,serverItem)
	local function selectedEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			UILogin.setCurrentServerItem(serverItem)
			UIManager.popScene()
		end
	end
	setStateIcon(item,serverItem.state)
	item:addTouchEventListener(selectedEvent)
	local ui_name = item:getChildByName("text_area")
	ui_name:setString(serverItem.name)
end

function UILoginChoose.init()
	UILoginChoose.scrollView = ccui.Helper:seekNodeByName(UILoginChoose.Widget, "view_area") -- 滚动层
	UILoginChoose.listItem = UILoginChoose.scrollView:getChildByName("image_area_recently")
end

function UILoginChoose.setup()
	UILoginChoose.scrollView:removeAllChildren()
	---最近登录的服务器------------
	local recentX = {}
	recentX[1] = ccui.Helper:seekNodeByName(UILoginChoose.Widget, "image_base_area")
	recentX[2] = ccui.Helper:seekNodeByName(UILoginChoose.Widget, "image_base_area1")
	recentX[3] = ccui.Helper:seekNodeByName(UILoginChoose.Widget, "image_base_area2")
	recentX[4] = ccui.Helper:seekNodeByName(UILoginChoose.Widget, "image_base_area3")
	local function uiServerEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			for i=1,4 do
				if sender == recentX[i] then
					UILogin.setCurrentServerItem(UILogin.serverHistory[i])
					break
				end
			end
			UIManager.popScene()
		end
	end
	for i=1,4 do
		recentX[i]:addTouchEventListener(uiServerEvent)
		local rct = UILogin.serverHistory[i]
		if rct then
			recentX[i]:setVisible(true)
			recentX[i]:getChildByName("text_area"):setString(rct.name)
			setStateIcon(recentX[i],rct.state)
		else
			recentX[i]:setVisible(false)
		end
	end
	
	if #UILogin.serverListAll > 0 then --todo 分页显示、分段显示
		for i = #UILogin.serverListAll,1,-1 do
			local item = UILoginChoose.listItem:clone()
			setScrollViewItem(item, UILogin.serverListAll[i])
			UILoginChoose.scrollView:addChild(item)
		end
		local spacing    = 15
		local viewWidth  = UILoginChoose.scrollView:getContentSize().width
		local viewHeight = UILoginChoose.scrollView:getContentSize().height
		local children   = UILoginChoose.scrollView:getChildren()
		local childCount = #children
		local itemHeight = UILoginChoose.listItem:getContentSize().height
		local innerHeight= childCount * (itemHeight + spacing) + spacing
		if innerHeight < viewHeight then
			innerHeight = viewHeight
		end
		UILoginChoose.scrollView:setInnerContainerSize(cc.size(viewWidth, innerHeight))
		local posX = viewWidth / 2
		local posY = innerHeight - itemHeight/2 - spacing
		for i = 1,#children do
			children[i]:setPosition(cc.p(posX,posY))
			posY = posY - itemHeight - spacing
		end

	end
end

function UILoginChoose.free( ... )
	UILoginChoose.scrollView:removeAllChildren()
end
