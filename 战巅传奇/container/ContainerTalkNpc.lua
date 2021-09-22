local ContainerTalkNpc = {}

local var = {}
local AP = {
	display.CENTER,
	display.LEFT_BOTTOM,
	display.LEFT_CENTER,
	display.LEFT_TOP,
	display.CENTER_TOP,
	display.RIGHT_TOP,
	display.RIGHT_CENTER,
	display.RIGHT_BOTTOM,
	display.CENTER_BOTTOM,
}
local listItemPos = {75, 250, 400, 500,600}

local function createButton (tempTab)
	local btnTemp = ccui.Button:create(tempTab.res or "btn_new2", tempTab.res or "btn_new2_sel", "", ccui.TextureResType.plistType)
		:pos(tempTab.posX, tempTab.posY)
		:setTitleText(tempTab.name)
		:setTitleFontSize(tempTab.fontSize or 24)
		:setTitleColor(GameBaseLogic.getColor("0xf1e8d0"))
		:setTitleFontName(FONT_NAME)

	if tempTab.w then
		btnTemp:setScale9Enabled(true)
		btnTemp:setContentSize(cc.size(tempTab.w or btnTemp:getContentSize().width, tempTab.h or btnTemp:getContentSize().height))
	end
	
	btnTemp:getTitleRenderer():enableOutline(GameBaseLogic.getColor("0x0e0600"),1)
	-- btnTemp:enableOutline(cc.c3b(0, 0, 0), 1)
	-- btnTemp:getTitleRenderer():setAdditionalKerning(2)
	btnTemp:setPressedActionEnabled(true)
	btnTemp:setZoomScale(-0.12)
	return btnTemp
end

local function updateFixedBox(talkTab)
	if not (talkTab and talkTab.fixed_tab) then return end
	local fixedTab = talkTab.fixed_tab
	local boxFixed = var.xmlPanel:getWidgetByName("box_fixed")
	boxFixed:removeAllChildren()
	if #fixedTab > 0 then
		for i=1,#fixedTab do
			local tempTab = fixedTab[i]
			if tempTab.mtype == "button" then
				local btnTemp = createButton(tempTab)

				boxFixed:addChild(btnTemp)
				btnTemp:addTouchEventListener(function (pSender,touch_type)
					if touch_type == ccui.TouchEventType.ended then
						GameSocket:PushLuaTable(talkTab.func, tempTab.funcIndex)
						if not tempTab.haveNext then
							GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "panel_npctalk"} )
						end
					end
				end)
			end
		end
	end

end

function ContainerTalkNpc.initView(event)
	var = {
		xmlPanel,
		uiuif,
		scrollView,
		scrollState = true,
		img,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerTalkNpc.uif")
	if var.xmlPanel then

		var.scrollView = var.xmlPanel:getWidgetByName("npc_scroll")
		if var.scrollView then
			ContainerTalkNpc.updateNpc(event.talk_tab)
		end
		
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_FRESH_NPC, ContainerTalkNpc.handleFreshNpc)
			:addEventListener(GameMessageCode.EVENT_REQCHART_LIST, ContainerTalkNpc.handleChartList)
		return var.xmlPanel
	end
end

function ContainerTalkNpc.handleFreshNpc(event)
	if event and event.talk_tab then
		if var.scrollView then
			ContainerTalkNpc.updateNpc(event.talk_tab)
		end
	end
end

function ContainerTalkNpc.updateNpc(talkTab)
	if var.scrollView then var.scrollView:removeAllChildren() end
	if talkTab then
		if talkTab.title then
			if  var.scrollState then
				var.scrollView:setContentSize(cc.size(var.scrollView:getContentSize().width,var.scrollView:getContentSize().height - 40))
				var.scrollView:setInnerContainerSize(cc.size(var.scrollView:getContentSize().width,var.scrollView:getContentSize().height))
				var.scrollState = false
			end
			local lblTitle = var.xmlPanel:getWidgetByName("lbl_Title")
			lblTitle:setString(talkTab.title.str):show()
				:setFontSize(talkTab.title.fontSize or 24)
				:setColor(talkTab.title.color and GameBaseLogic.getColor(tonumber(talkTab.title.color)) or display.COLOR_WHITE)
				:show()
		else
			var.scrollView:setContentSize(cc.size(800,340))
			var.xmlPanel:getWidgetByName("lbl_Title"):hide()
			for i = 1,2 do
				local tempImage = var.xmlPanel:getWidgetByName("titleImg_"..i)
				if tempImage then
					tempImage:hide()
				end
			end
			var.scrollState = true
		end
		local maxHeight = 0
		for i,v in ipairs(talkTab.con_tab) do
			if maxHeight<v.posY then
				maxHeight = v.posY
			end
		end

		var.scrollView:setInnerContainerSize(cc.size(var.scrollView:getContentSize().width,maxHeight+30))
		-- if talkTab.scrollHeight and talkTab.scrollHeight > 0 then
		-- 	var.scrollView:setInnerContainerSize(cc.size(var.scrollView:getContentSize().width,talkTab.scrollHeight))
		-- end
	--print(GameUtilSenior.encode(talkTab.con_tab))
		if #talkTab.con_tab > 0 then
			for i=1,#talkTab.con_tab do
				local tempTab = talkTab.con_tab[i]
				if tempTab.mtype == "text" then
					local tempLabel = ccui.Text:create()
						:setFontSize(tempTab.fontSize or 20)
						:setString(tempTab.str)
						:align(tempTab.anch and AP[tempTab.anch] or display.LEFT_CENTER,tempTab.posX,tempTab.posY)
						:setColor(tempTab.color and GameBaseLogic.getColor(tonumber(tempTab.color)) or display.COLOR_WHITE)
					var.scrollView:addChild(tempLabel)
					if tempTab.time then
						tempLabel:runAction(cca.loop(cca.seq({
							cca.cb(function(target)
								target:setString(tempTab.str..os.date("%Y-%m-%d %H:%M:%S",tempTab.time))
								tempTab.time = tempTab.time+1
							end),
							cca.delay(1)
						})))
					end
				elseif tempTab.mtype == "button" then

					local tempBtn = createButton(tempTab)

					tempBtn:addTouchEventListener(function (pSender,touch_type)
							if touch_type == ccui.TouchEventType.ended then
								GameSocket:PushLuaTable(talkTab.func,tempTab.funcIndex)
								if not tempTab.haveNext then
									GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "panel_npctalk"} )
								end
							end
						end)
					var.scrollView:addChild(tempBtn)
				elseif tempTab.mtype == "itemicon" then
					local itemIcon = ccui.ImageView:create(tempTab.res or "img_gezi_80",ccui.TextureResType.plistType)
					local param = {
						parent = itemIcon,
						typeId = tempTab.id,
					}
					GUIItem.getItem(param)
					itemIcon:setPosition(cc.p(tempTab.posX,tempTab.posY))
					var.scrollView:addChild(itemIcon)
				elseif tempTab.mtype == "image" then
					local tempImage = ccui.ImageView:create()
						:loadTexture(tempTab.res, ccui.TextureResType.plistType)
					local tempImageWidth = tempImage:getContentSize().width
					tempImage:align(tempTab.anch and AP[tempTab.anch] or display.LEFT_CENTER, tempTab.posX ,tempTab.posY)
						:setScale9Enabled(true)
					tempImage:setContentSize(cc.size(tempTab.imgState == "rule" and var.scrollView:getContentSize().width or tempImage:getContentSize().width, tempImage:getContentSize().height))
					var.scrollView:addChild(tempImage)
				elseif tempTab.mtype == "uif" then
					var.uiuif = GUIAnalysis.load("ui/layout/"..tempTab.res..".uif")
					if var.uiuif then
						var.scrollView:addChild(var.uiuif)
						local lblTitle = {"排行","姓名","职业","等级","土豪值"}
						for i,v in ipairs(lblTitle) do
							var.uiuif:getWidgetByName("lbl_param_"..i):setPositionX(listItemPos[i]-10):setString(v):setAnchorPoint(cc.p(0,0.5))
						end
						ContainerTalkNpc.handleChartList()
						GameSocket:GetChartInfo(110, 1)
					end
				end
			end
		end

		updateFixedBox(talkTab)
	end
end

function ContainerTalkNpc.handleChartList(event)
	local tuhaolist = var.xmlPanel:getWidgetByName("list_chart")
	local chartData = GameSocket.mChartData[110] or {}
	if tuhaolist then
		function updateItem(item)
			item:getWidgetByName("img_bg"):loadTexture("img_bg_"..item.tag%2+1, ccui.TextureResType.plistType)
			local tag		= item.tag
			local name 		= chartData[tag] and chartData[tag].name or ""
			local job 		= chartData[tag] and GameConst.job_name[chartData[tag].job] or ""
			local lv 		= chartData[tag] and chartData[tag].lv or ""
			local tuhao 	= chartData[tag] and chartData[tag].param or ""
			local strData = {tag,name,job,lv,tuhao}
			for i = 1, #strData do
				local lbl_listItem = item:getWidgetByName("lbl_listItem_"..i):align(display.CENTER)
				lbl_listItem:setString(strData[i])
				lbl_listItem:pos(listItemPos[i], 27)
			end
			local img_rank = item:getWidgetByName("img_rank")
			if tag <= 3 then
				img_rank:show():align(display.CENTER):pos(75, 27):loadTexture("img_chart_"..tag, ccui.TextureResType.plistType)
			else
				img_rank:hide()
			end
		end
		tuhaolist:reloadData(100, updateItem,0,false)
	end
end

return ContainerTalkNpc

