local ContainerBarrier = {}
--闯天关
local var = {}
local close = function ( str ) GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL,str = str}) end;
local open = function ( str,tab ) GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = str,tab = tab or 1}) end;
local titleRes = {"img_star_bu1","img_star_bu2","img_star_bu3"}
local box = {"box_6","box_12","box_18"}

function ContainerBarrier.initView( extend )
	var = {
		xmlPanel,
		curChapter = 1,
		curSection = 1,
		maxSection = 0,--当前总关卡
		pagesNum = 3,
		sectionData = {},
		-- progressBar,
		chapter,
		section,
		boxIndex = 0,
		box_baoxiang,
	}

	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerBarrier.uif")
	if var.xmlPanel then
		var.box_baoxiang = var.xmlPanel:getWidgetByName("box_baoxiang"):hide()
		local btn_left = var.xmlPanel:getWidgetByName("btn_left")
		var.xmlPanel:getWidgetByName("btn_left"):setRotation(-180)
		local btn_right = var.xmlPanel:getWidgetByName("btn_right")
		GUIFocusDot.addRedPointToTarget(btn_left)
		GUIFocusDot.addRedPointToTarget(btn_right)
		btn_left:getChildByName("redPoint"):setPosition(btn_left:getContentSize().width/2, btn_left:getContentSize().height*0.3)
											:setRotation(-180)
		btn_right:getChildByName("redPoint"):setPosition(btn_right:getContentSize().width/2, btn_right:getContentSize().height*0.7)
		var.PageView = var.xmlPanel:getWidgetByName("PageView")
		var.PageView:addEventListener(function (pageView,curpageData,index)
			--print("qqqqqqqqqqqqqqqq",index)
			var.chapter = index
			btn_left:setVisible(index>1)
			-- btn_right:setTouchEnabled(index<#var.sectionData)
			-- btn_right:setEnabled(index<#var.sectionData)
			-- if index<#var.sectionData then
			-- 	btn_right:setBright(false)
			-- else
			-- 	btn_right:setBright(true)
			-- end
			btn_right:setVisible(index<#var.sectionData)
			--print("qqqqqqqqqqqqqq#var.sectionData=",#var.sectionData)
			if curpageData then
				pageView:getRealPage(index):getWidgetByName("progressBar"):setPercent(curpageData.stars,curpageData.maxStar)
			end
			btn_right:setEnabled(index<var.curChapter or index==var.curChapter and var.curSection == 6)
			if btn_left:getChildByName("redPoint") then
				btn_left:getChildByName("redPoint"):setVisible(ContainerBarrier.isGiftUnGot(index-1))
			end
			if btn_right:getChildByName("redPoint") then
				btn_right:getChildByName("redPoint"):setVisible(ContainerBarrier.isGiftUnGot(index+1))
			end
			set_zhang_num(index)
		end)
		var.PageView:addPageInitFunc(ContainerBarrier.addPageByIndex)

		var.PageView:addPageUpdateFunc(function ( pageView )
			local page0 = pageView:getPage(0)
			if page0 then
				local posX = page0:getLeftBoundary()
				local percent = 1- math.abs((math.abs(posX)%830-830/2))/830*2
				var.xmlPanel:getWidgetByName("bottomLayout"):setPositionY(-80*percent)
				--var.xmlPanel:getWidgetByName("imgmiemoling"):setPositionY(500+50*percent)
				-- var.xmlPanel:getWidgetByName("btn_left"):setPositionX(30-150*percent)
				-- var.xmlPanel:getWidgetByName("btn_right"):setPositionX(815+150*percent)
			end
		end)
		var.layerInfo = var.xmlPanel:getWidgetByName("layerInfo"):hide()
			:setPosition(cc.p(var.xmlPanel:getContentSize().width/2, var.xmlPanel:getContentSize().height/2))
			:setSwallowTouches(true)
			:setTouchEnabled(true)
		var.layerinfobg = var.xmlPanel:getWidgetByName("layerinfobg"):hide()

		var.layerFirstPass = var.xmlPanel:getWidgetByName("layerFirstPass"):hide()
		ContainerBarrier.initPanel()

		GameUtilSenior.asyncload(var.xmlPanel, "Image_5", "ui/image/img_breakup_info_bg2.jpg")
		-- GameUtilSenior.asyncload(var.xmlPanel, "imgFirstPass", "ui/image/prompt_bg.png")

		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerBarrier.handlePanelData)

		return var.xmlPanel
	end
end

function set_zhang_num( index )
	local Image_chapternum = var.xmlPanel:getWidgetByName("Image_chapternum")
	local lbl_chapter_name = Image_chapternum:getWidgetByName("lbl_chapter_name")
	if not lbl_chapter_name then
		lbl_chapter_name = ccui.TextAtlas:create("1234567890","image/typeface/num_5.png", 30, 30,"1")
		:align(display.LEFT_CENTER, 32, 11)
		:setName("lbl_chapter_name")
		:addTo(Image_chapternum)
	end
	local btn_right = var.xmlPanel:getWidgetByName("btn_right")
	btn_right:setVisible(index<5)
	lbl_chapter_name:setString(index==10 and 0 or index)
end
function ContainerBarrier.onPanelOpen()
	var.chapter = 0;
	var.section = 0;
	local btnClose = GUIMain.m_GDivContainer:addButtonClose(var.layerinfobg)
	if btnClose then
		GUIFocusPoint.addUIPoint(btnClose,	function(pSender)
			var.layerInfo:hide()
		end)
	end
	btnClose = GUIMain.m_GDivContainer:addButtonClose(var.layerFirstPass)
	if btnClose then
		GUIFocusPoint.addUIPoint(btnClose,	function(pSender)
			var.layerInfo:hide()
		end)
	end

	GameSocket:PushLuaTable("gui.ContainerBarrier.onPanelData",GameUtilSenior.encode({actionid = "fresh",params = {}}))
end

function ContainerBarrier.initPanel()
	local btns = {"btn_challenge","btn_chart","box_6","box_12","box_18","btn_first_sure","btn_enter","btn_left","btn_right"};
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		if senderName == "btn_enter" then
			GameSocket:PushLuaTable("gui.ContainerBarrier.onPanelData",GameUtilSenior.encode({actionid = "enterMap",params = {var.chapter,var.section}}))
		elseif senderName=="btn_challenge" then
			var.layerFirstPass:hide()
			var.layerinfobg:show():setTouchEnabled(true)
			GameSocket:PushLuaTable("gui.ContainerBarrier.onPanelData",GameUtilSenior.encode({actionid = "getTaskInfo",params = {var.chapter,var.section}}))
		elseif senderName=="btn_chart" then
			close("menu_breakup")
			open("btn_main_rank",6)
		elseif senderName == "box_6" then
			var.boxIndex = 1
			GameSocket:PushLuaTable("gui.ContainerBarrier.onPanelData",GameUtilSenior.encode({actionid = "box",params = {1,var.chapter}}))
		elseif senderName == "box_12" then
			var.boxIndex = 2
			GameSocket:PushLuaTable("gui.ContainerBarrier.onPanelData",GameUtilSenior.encode({actionid = "box",params = {2,var.chapter}}))
		elseif senderName == "box_18" then
			var.boxIndex = 3
			GameSocket:PushLuaTable("gui.ContainerBarrier.onPanelData",GameUtilSenior.encode({actionid = "box",params = {3,var.chapter}}))
		elseif senderName == "btn_first_sure" then
			if sender:getTitleText() == "领取" then
				if sender.first then
					GameSocket:PushLuaTable("gui.ContainerBarrier.onPanelData",GameUtilSenior.encode({actionid = "getfirstbox",params = {sender.boxIndex,sender.chapter}}))
				else
					GameSocket:PushLuaTable("gui.ContainerBarrier.onPanelData",GameUtilSenior.encode({actionid = "getbox",params = {sender.boxIndex,sender.chapter}}))
				end
			else
				-- GameSocket:alertLocalMsg("奖励已领取", "alert")
			end
			ContainerBarrier.hideBoxInfo()
		elseif senderName == "btn_left" then
			var.PageView:scrollToPage(var.PageView:getCurPageIdx()-1)
			--print("------------------index",var.PageView:getCurPageIdx()-1)
			--if var.PageView:getCurPageIdx()-1~=0
			set_zhang_num(var.PageView:getCurPageIdx()-1)
		--end
			-- print("left",#var.PageView:getPages())
		elseif senderName == "btn_right" then
			var.PageView:scrollToPage(var.PageView:getCurPageIdx()+1)
			-- print("right",#var.PageView:getPages())
		end
	end
	for k,v in pairs(btns) do
		local btn = var.xmlPanel:getWidgetByName(v)
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
	end
end

function ContainerBarrier.handlePanelData(event)
	if event.type ~= "ContainerBarrier" then return end
	local data = GameUtilSenior.decode(event.data)
	if data.cmd == "fresh" then
		ContainerBarrier.initPageView(data)
	elseif data.cmd == "boxData" then
		ContainerBarrier.showBoxInfo(data)
	elseif data.cmd == "getTaskInfo" then
		var.layerInfo:show()
		ContainerBarrier.freshTaskInfo(data.config)
	elseif data.cmd == "freshBoxData" then
		ContainerBarrier.freshBoxRes(data)
	end
end

function ContainerBarrier.freshBoxRes(data)
	local boxCon = data.boxCon
	local firstCon = data.firstCon
	local index = data.index
	local first = data.first
	local stars = data.stars
	local chapter = data.chapter
	local res = "null"
	local page = var.PageView:getRealPage(chapter)
	if page then
		if not first then
			var.sectionData[chapter].boxCon = boxCon
			for i,v in ipairs(box) do
				local get = string.sub(boxCon,i,i) == "0" and true or false
				res = get and "img_box_"..i or "img_box_open"
				page:getWidgetByName(v):loadTextureNormal(res,ccui.TextureResType.plistType)
				page:getWidgetByName(v):setTouchEnabled(get)
				-- page:getWidgetByName(v):getWidgetByName("img_out_light"):setVisible(stars>=i*6 and get)
				if stars>=i*6 and get then
					GameUtilSenior.addHaloToButton(page:getWidgetByName(v), "img_light_box")
				elseif page:getWidgetByName(v):getWidgetByName("img_bln") then
					page:getWidgetByName(v):removeChildByName("img_bln")
				end
			end
		else
			var.sectionData[chapter].firstCon = firstCon
			boxfirst = page:getWidgetByName("boxfirst"..index)
			if boxfirst then
				if string.sub(firstCon,index,index) == "0" then
					res = "img_box_color" --可领取
					boxfirst:setTouchEnabled(true)
				else
					res = "img_box_grey_open" --已领取
					boxfirst:setTouchEnabled(false)
				end
				boxfirst:loadTextureNormal(res,ccui.TextureResType.plistType)
			end
		end
	end
end

local ataskPos = {
	{cc.p(148,34), cc.p(267,112), cc.p(618,146), cc.p(478,245), cc.p(244,260), cc.p(133,190), },
	{cc.p(-30,130), cc.p(40,310), cc.p(230,80), cc.p(350,180), cc.p(550,270), cc.p(650,100), },
}
local boxPos = {{cc.p(565,159), cc.p(438,302), cc.p(100,366), },{cc.p(230,270), cc.p(520,470), cc.p(820,300),},}
local bossPosAdd = {
	cc.p(0,0), cc.p(0,0), cc.p(0,0),
	cc.p(20,10), cc.p(-20,0), cc.p(0,0),
	cc.p(0,-20), cc.p(0,0), cc.p(-30,0),
}

function ContainerBarrier.freshTaskInfo(config)
	local lblinfo_power = var.layerinfobg:getWidgetByName("lblinfo_power")

	if not var.recommendPower then
		-- var.recommendPower = display.newBMFontLabel({font = "image/typeface/num_13.fnt",})
		-- :align(display.CENTER_LEFT, 0, 7)
		-- :setName("recommendPower")
		-- :setString("0")
		-- :addTo(var.xmlPanel:getWidgetByName("lblinfo_power"))

		var.recommendPower = ccui.TextAtlas:create("0123456789","image/typeface/num_4.png", 16, 20,"0")
		:setName("recommendPower")
		:addTo(var.xmlPanel:getWidgetByName("lblinfo_power"))
		:align(display.CENTER_LEFT, 0, 10)
		:setString("0")

	end
	var.recommendPower:setString(config.power)

	local lblinfo_level = var.layerinfobg:getWidgetByName("lblinfo_level")
	lblinfo_level:setString(config.limitlv)
	lblinfo_level:setColor(config.limitlv>GameCharacter._mainAvatar:NetAttr(GameConst.net_level) and cc.c3b(255,0,0) or cc.c3b(0,255,0))
	local lblinfo_num = var.layerinfobg:getWidgetByName("lblinfo_num")
	lblinfo_num:setString(config.ticket)

	var.layerinfobg:getWidgetByName("imgtaskinfo"):loadTexture(string.format("img_bu_%s",config.name),ccui.TextureResType.plistType)
	var.layerinfobg:getWidgetByName("taskimg"):loadTexture(string.format("img_big_%s",config.name), ccui.TextureResType.plistType)
	for i=1,2 do
		local icon = var.layerinfobg:getWidgetByName("awardicon"..i)
		local d = config.award[i]
		GUIItem.getItem({parent = icon, typeId = d.id, num = d.num })
	end
	local power = GameSocket.mCharacter.mFightPoint
	var.layerinfobg:getWidgetByName("lblinfo_danger"):setPositionX(#tostring(config.power)*19):setVisible(power<config.power)
end

function ContainerBarrier.changeTaskItemState(taskItem,bright)
	local i = taskItem.section
	if bright then
		var.curTaskItem = taskItem
		var.chapter = taskItem.chapter
		var.section = taskItem.section
	end
	taskItem:stopAllActions()
	if i%2 == 1 then
		taskItem:getWidgetByName("imgLight"):setVisible(bright)
	else
		if bright then
			taskItem:runAction(
				cca.seq({
					cca.delay(0),   --   0.25改成0  使宝箱和关卡的呼吸同步
					cca.cb(function( target )
						target:getWidgetByName("img_dragon_light"):setPositionY(24)
						target:getWidgetByName("img_dragon_light"):setVisible(true)
						target:getWidgetByName("img_dragon_light"):runAction(cca.repeatForever(cca.seq({
								cca.fadeOut(0.5),
								cca.fadeIn(0.5),
							})
						))
					end)
			}))
		else
			taskItem:getWidgetByName("img_dragon_light"):stopAllActions()
			taskItem:getWidgetByName("img_dragon_light"):setVisible(false)
		end
	end
end

function ContainerBarrier.clickTaskItem(sender,touchType)
	if sender:getParent()==var.curTaskItem then return end
	if touchType == ccui.TouchEventType.began then
		var.xmlPanel:getWidgetByName("lbl_section_info"):setString(sender.str)
		local curMaxSection = (sender.chapter-1)*6+sender.section
		local maxSection = (var.curChapter-1)*6+var.curSection
		if curMaxSection > maxSection+1 then
			-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", visible = true, lblConfirm = "通关之前所有关卡后开启", btnConfirm = "确定",btnCancel ="取消", })
			GameSocket:alertLocalMsg("通关之前所有关卡后开启", "alert")
		else
			if GameUtilSenior.isObjectExist(var.curTaskItem) then
				ContainerBarrier.changeTaskItemState(var.curTaskItem,false)
			end
			ContainerBarrier.changeTaskItemState(sender:getParent(),true)
			local curPage = var.PageView:getRealPage(sender.chapter)
			if curPage then
				for i=1,6 do
					local taskItem = curPage:getWidgetByName("taskItem"..i)
					if i ~= sender.section and taskItem then
						ContainerBarrier.changeTaskItemState(taskItem,i == sender.section)
					end
				end
			end
		end
	end
end

function ContainerBarrier.isGiftUnGot(chapter)
	local curpageData = var.sectionData[chapter]
	local redPointShow = false
	if curpageData then
		for ii,v in ipairs(box) do
			local get = string.sub(curpageData.boxCon,ii,ii) == "0" and true or false
			if curpageData.stars>=ii*6 and get then
				redPointShow = true
			end
		end
		local maxSection = (var.curChapter-1)*6+var.curSection
		for j=1,#curpageData.conf do
			local curMaxSection = (chapter-1)*6+j
			if j%2 == 0 then
				if curMaxSection <= maxSection then
					if string.sub(curpageData.firstCon,j,j) == "0" then
						redPointShow = true
					end
				end
			end
		end
	end
	return redPointShow
end

function ContainerBarrier.addPageByIndex( layout,curpageData,index )
	local i = index

	local modeltask = var.xmlPanel:getWidgetByName("modeltask")
	--layout:setBackGroundImage(string.format("ui/image/img_breakup_bg%d.jpg",2-index%2),ccui.TextureResType.localType)
	
	
		asyncload_callback(string.format("ui/image/img_breakup_bg%d.jpg",2-index%2), layout, function(filepath, texture)
			layout:setBackGroundImage(filepath)
		end)

	local box_baoxiang = layout:getWidgetByName("box_baoxiang")
	if not box_baoxiang then
		box_baoxiang = var.box_baoxiang:clone()
		box_baoxiang:addTo(layout):setName("box_baoxiang")--:pos(box_baoxiang:getPosition())

		GUILoaderBar.new({image = box_baoxiang:getWidgetByName("progressBar")})
		box_baoxiang:getWidgetByName("progressBar"):setLabelVisible(false)
		-- box_baoxiang:getWidgetByName("progressBar_forground"):setLocalZOrder(1)
	end
	box_baoxiang:show()
	box_baoxiang:getWidgetByName("progressBar"):setPercent(curpageData.stars,curpageData.maxStar)
	local res = ""
	for ii,v in ipairs(box) do
		local get = string.sub(curpageData.boxCon,ii,ii) == "0" and true or false
		res = get and "img_box_"..ii or "img_box_open"
		box_baoxiang:getWidgetByName(v):loadTextureNormal(res,ccui.TextureResType.plistType)
		if curpageData.stars>=ii*6 and get then
			GameUtilSenior.addHaloToButton(box_baoxiang:getWidgetByName(v), "img_light_box")
		elseif box_baoxiang:getWidgetByName(v):getWidgetByName("img_bln") then
			box_baoxiang:getWidgetByName(v):removeChildByName("img_bln")
		end
	end

	--lbl_chapter_name:setString("第"..GameUtilSenior.numberToChinese(index).."章")

	local taskPos = ataskPos[2-index%2]
	local maxSection = (var.curChapter-1)*6+var.curSection
	for j=1,#curpageData.conf do
		local curMaxSection = (i-1)*6+j
		local cursectionData = curpageData.conf[j];
		local taskItem = modeltask:clone():setTouchEnabled(true)
		layout:addChild(taskItem)

		local btntask = taskItem:getWidgetByName("btntask")
		local isBoss = cursectionData.name ~="normal"
		local res = isBoss and string.format("ui/image/breakup_%d_%d.png",i,j) or "img_breakup_normal"
		local img_circle = taskItem:getWidgetByName("img_circle")
		local modelbtn = taskItem:getWidgetByName("modelbtn"):setTouchEnabled(true)
		modelbtn:setContentSize(cc.size(160,180)):setScale9Enabled(true)

		if isBoss then
			asyncload_callback(res, modelbtn, function(filepath, texture)
			end)
		end
		
		modelbtn.chapter = i
		modelbtn.section = j
		btntask.chapter = i
		btntask.section = j

		taskItem.chapter = i
		taskItem.section = j
		taskItem:setName("taskItem"..j)
		taskItem:setPosition(taskPos[j])

		taskItem:getWidgetByName("img_dragon_light"):setVisible(var.chapter == i and j==var.curSection)
		-- taskItem:getWidgetByName("img_dragon_left"):setVisible(var.chapter == i and j==var.curSection)
		-- taskItem:getWidgetByName("img_dragon_right"):setVisible(var.chapter == i and j==var.curSection)
		taskItem:getWidgetByName("lbltask"):setString("挑战次数:"..cursectionData.con.passtimes.."/"..cursectionData.challengeTimes):enableOutline(cc.c4b(0, 0, 0, 255),1)
		taskItem:getWidgetByName("boss_name_bg"):setVisible(isBoss)
		--taskItem:getWidgetByName("img_moji"):setVisible(isBoss)
		taskItem:getWidgetByName("bossname"):setString(cursectionData.bossname):enableOutline(cc.c4b(0, 0, 0, 255),1)
		taskItem:getWidgetByName("lbltask_achieve"):setString(cursectionData.achieve):setVisible(false)--isBoss
		btntask:setTouchEnabled(false)
		if isBoss then
			-- taskItem:loadTexture("",ccui.TextureResType.plistType)
		else
			-- taskItem:loadTexture("",ccui.TextureResType.plistType)
		end
		btntask:loadTextures(res,res,"",isBoss and ccui.TextureResType.localType or ccui.TextureResType.plistType)
		modelbtn:addTouchEventListener(ContainerBarrier.clickTaskItem)

		modelbtn.str = string.format(":%d",cursectionData.ticket)
		if cursectionData.bosslv then
			modelbtn.str = string.format("等级:%d ",cursectionData.bosslv)..modelbtn.str
		end
		ContainerBarrier.changeTaskItemState(taskItem,curMaxSection == maxSection+1)
		for s=1,3 do
			taskItem:getWidgetByName("star"..s):setVisible(curMaxSection <= maxSection):getVirtualRenderer():setState(s<=cursectionData.con.stars and 0 or 1)
		end
		if curMaxSection <= maxSection+1 then
			btntask:setBright(true)
			if curMaxSection == maxSection+1 then
				--[[
				local function newCircle(tag)
					local circle = img_circle:clone()
					circle:pos(img_circle:getPositionX(),isBoss and 110 or 102)
						:setName("newCircle"..tag)
						:addTo(img_circle:getParent())
						:setOpacity(70)
						:show()
						:runAction(cca.loop(cca.seq({cca.scaleTo(0, 1.5),cca.scaleTo(1.5, 2.4),cca.delay(0.5),  })))
				end
				img_circle:stopAllActions():setVisible(false):runAction(cca.seq({
					cca.delay(0.5), cca.cb(function()newCircle(1) end),
					cca.delay(0.5), cca.cb(function()newCircle(2) end),
					cca.delay(0.5), cca.cb(function()newCircle(3) end),
					cca.delay(0.5), cca.cb(function()newCircle(4) end),
					-- cca.delay(0.4), cca.cb(function()newCircle(5) end),
				}))
				]]
				var.xmlPanel:getWidgetByName("lbl_section_info"):setString(modelbtn.str)
			end
		else
			--[[
			img_circle:setVisible(false):stopAllActions()
			for i=1,4 do
				local circlei = taskItem:getWidgetByName("newCircle"..i)
				if circlei then
					circlei:removeFromParent()
				end
			end
			]]
			btntask:setBright(false)
			taskItem:getWidgetByName("boss_name_bg"):getVirtualRenderer():setState(1)
		end

		if j%2 == 0 then
			local boxfirst = layout:getWidgetByName("boxfirst"..j)
			if not boxfirst then
				boxfirst = ccui.Button:create()
				boxfirst.chapter = i
				boxfirst.section = j
				boxfirst:addTo(layout):setLocalZOrder(3)
				boxfirst:setName("boxfirst"..j)
				boxfirst:addClickEventListener(function(sender)
					if  sender.chapter <var.curChapter or sender.chapter ==var.curChapter and sender.section <=var.curSection then
						GameSocket:PushLuaTable("gui.ContainerBarrier.onPanelData",GameUtilSenior.encode({actionid = "box",first = true,params = {j,sender.chapter}}))
					else
						GameSocket:alertLocalMsg("通关之前所有关卡后开启", "alert")
					end
				end)
			end
			local boxidx = math.floor(j/2)
			local res
			boxfirst:setTouchEnabled(true)
			if curMaxSection <= maxSection then
				if string.sub(curpageData.firstCon,j,j) == "0" then
					res = "img_box_color" --可领取
				else
					res = "img_box_grey_open" --已领取
					boxfirst:setTouchEnabled(false)
				end
			else
				res = "img_box_grey" --不可领取
			end
			boxfirst:loadTextureNormal(res,ccui.TextureResType.plistType)
			boxfirst:setPosition(boxPos[2-i%2][boxidx])
		end
		-- layout:addChild(taskItem)
	end


end

function ContainerBarrier.initPageView(data)
	var.sectionData = data.data
	var.pagesNum = #var.sectionData
	var.chapter = data.curChapter or 1
	var.section = data.curSection or 1
	var.curChapter = data.curChapter or 1
	var.curSection = data.curSection or 1
	var.maxSection = 6*(var.curChapter-1)+var.curSection
	local tempData = {}
	for i,v in ipairs(var.sectionData) do
		if i<=var.curChapter or i==var.curChapter+1 and var.curSection == 6 then
			table.insert(tempData,v)
		end
	end
	var.PageView:bindData(tempData)
	var.PageView:setCurPageIndex(var.curSection == 6 and var.curChapter+1 or var.curChapter)

	local imgmiemoling = var.xmlPanel:getWidgetByName("imgmiemoling")
	if not imgmiemoling.richlabel then
		imgmiemoling.richlabel = GUIRichLabel.new({name = "imgmiemolinglabel",ignoreSize = true})
		imgmiemoling.richlabel:addTo(imgmiemoling):align(display.CENTER,100,20)
	end
	imgmiemoling.richlabel:setRichLabel("<font color=#FFCC00>拥有副本卷轴:<font color=#fddfae>"..data.ticket.."</font></font>")

end

function ContainerBarrier.showBoxInfo(data)
	local index = data.index

	var.layerInfo:show()
	var.layerinfobg:hide()
	var.layerFirstPass:show()

	local firstList = var.layerFirstPass:getWidgetByName("firstList")
	firstList:setSliderVisible(false)
	local award = data.firstAward or data.award
	firstList:reloadData(#award, function(subItem)
		local icon = subItem:getWidgetByName("img_icon")
		local d = award[subItem.tag]
		GUIItem.getItem({parent = icon, typeId = d.id,num = d.num})
	end, 0, false)
	firstList:setPositionX(47+(4-#award)*40):setTouchEnabled(false)
	local btn_first_sure = var.layerFirstPass:getWidgetByName("btn_first_sure")
	btn_first_sure:setTitleText(data.btnState and "领取" or "确定")
	btn_first_sure.first = data.first
	btn_first_sure.boxIndex = data.index
	btn_first_sure.chapter = data.chapter

	var.layerFirstPass:getWidgetByName("lbl_first_task_name"):setString(data.taskName or "")
	local res = "img_first_pass_breakup"
	if not data.first and index then
		res = "img_star_bu"..index
	end
	var.layerFirstPass:getWidgetByName("img_firstpass_title"):loadTextureNormal(res,ccui.TextureResType.plistType)
end

function ContainerBarrier.hideBoxInfo()
	if GameUtilSenior.isObjectExist(var.layerInfo) then
		var.layerInfo:hide()
	end
	if GameUtilSenior.isObjectExist(var.layerinfobg) then
		var.layerinfobg:hide()
	end
	if GameUtilSenior.isObjectExist(var.layerFirstPass) then
		var.layerFirstPass:hide()
	end
end


function ContainerBarrier.onPanelClose()
	ContainerBarrier.hideBoxInfo()
	if GameUtilSenior.isObjectExist(var.curTaskItem) then
		ContainerBarrier.changeTaskItemState(var.curTaskItem,false)
	end
end

return ContainerBarrier