local GUICenterBottom = {
	listChat
}
local var = {}

local btnInfo = {
	--["btnRole"] = "panel_role_main",
	--["btnBag"] = "menu_bag",
	--["btnDuanzao"] = {
	--	{name = "" , normal = "btn_main_other" , panel = "panel_equip"},
	--	{name = "" , normal = "btn_main_other" , panel = "menu_recycle"},
	--	{name = "" , normal = "btn_main_other" , panel = "panel_tongtianta"},
	--	},
	--["btnZuji"] = "panel_zuji",
	--["btnAchieve"] = "panel_all_baowu",
	--["btnOther"] = {
	--	{name = "" , normal = "btn_main_other" , panel = "menu_setting"},
	--	{name = "btn_main_guild" , normal = "btn_main_other" , panel = "main_guild"},
	--	{name = "btn_main_friend" , normal = "btn_main_other" , panel = "main_friend"},
	--	{name = "" , normal = "btn_main_other" , panel = "main_consign"},
	--	{name = "" , normal = "btn_main_other" , panel = "main_mail"},
	--	-- main_mail
	--	},

	--"btn_main_forge", "btn_main_official", "btn_main_compose", "btn_main_convert", 
	--"btn_main_friend", "btn_main_group", "btn_main_guild", "btn_main_mail", "btn_main_consign"
	["btnRole"] = "main_avatar",
	["btnBag"] = "menu_bag",
	["btnAchieve"] = "main_achieve",
	--["btnPaiHang"] = "main_furnace",
	["btnPaiHang"] = "main_forge",
	["btnHaoYou"] = "main_friend",
	["btnZuDui"] = "main_group",
	["btnBangHui"] = "main_guild",
	["btnSheZhi"] = "menu_setting",
	
	["btnEquip"] = {
		{name = "" , normal = "btn_main_forge" , panel = "main_forge"},
		{name = "" , normal = "btn_main_official" , panel = "main_official"},
		--{name = "" , normal = "btn_main_compose" , panel = "main_compose"},
		--{name = "" , normal = "btn_main_convert" , panel = "main_convert"},
	},
	--["btn_furnace"] = "main_furnace",
	["btnWing"] = "btn_main_wing",
	--["btnWing"] = "main_forge",
	--["btnBoss"] = "main_puzzle",
	
	["btnOther"] = { 
		{name = "" , normal = "btn_main_friend" , panel = "main_friend"},
		{name = "" , normal = "btn_main_group" , panel = "main_group"},
		{name = "" , normal = "btn_main_guild" , panel = "main_guild"},
		{name = "" , normal = "btn_main_mail" , panel = "main_mail"},
		{name = "" , normal = "btn_main_consign" , panel = "main_consign"},
		{name = "" , normal = "btn_main_rank" , panel = "btn_main_rank"},
		{name = "" , normal = "btn_main_set" , panel = "menu_setting"},
	},
}

function GUICenterBottom.init_ui(centerBottom)
	var = {
		layerHpMp,
		layerLeftBtn,
		can_move = true,
		notPk = false,
	}
	var.centerBottom = centerBottom
	var.centerBottom:align(display.CENTER_BOTTOM, display.cx, display.bottom)

	var.layerHpMp = var.centerBottom:getWidgetByName("layerHpMp")
	var.layerHpMp:setTouchEnabled(true)
	var.layerLeftBtn = var.centerBottom:getWidgetByName("layerLeftBtn")
	GUICenterBottom.listChat = var.centerBottom:getWidgetByName("list_chat")
	GUICenterBottom.listChat:setSwallowTouches(false):setGravity(ccui.ListViewGravity.bottom)
	var.Panel_btn = var.centerBottom:getWidgetByName("Panel_btn")
	var.imgRight = var.centerBottom:getWidgetByName("imgRight")
	var.imgLeft = var.centerBottom:getWidgetByName("imgLeft")
	var.expBar = var.centerBottom:getWidgetByName("progressBarExp")
	local btnBag = var.layerLeftBtn:getWidgetByName("btnBag")
	local btnShowOrHide = var.centerBottom:getWidgetByName("btnShowOrHide")
	btnShowOrHide:addClickEventListener(function ( ... )
		GUICenterBottom.handleSetPKNoraml()
	end)
	GUICenterBottom.listChat:addClickEventListener(function (pSender)
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_chat" ,} )
		GameSocket:PushLuaTable("count.onClientData", GameUtilSenior.encode({cmd = "点击聊天"}))
	end)
	cc.EventProxy.new(GameSocket,centerBottom)
		:addEventListener(GameMessageCode.EVENT_EXP_CHANGE,GUICenterBottom.handleExpChange)
		:addEventListener(GameMessageCode.EVENT_SELF_HPMP_CHANGE, GUICenterBottom.handlefreshHPMP)
		:addEventListener(GameMessageCode.EVENT_BAG_UNFULL, GUICenterBottom.showBagFull)
	var.expBar = var.centerBottom:getWidgetByName("progressBarExp")
		:setFontSize(12)
		:setFormatString("EXP:%s/%s")
		:setFormat2String( "(%.2f%%)" )
		:setPercent(GameSocket.mCharacter.mCurExperience,GameSocket.mCharacter.mCurrentLevelMaxExp)

	local label = var.expBar:getLabel()
	--label:setPositionY(var.expBar:getContentSize().height)
	label:setTextColor(cc.c3b(255, 247, 235))
	label:enableOutline(cc.c3b(0, 0, 0),1)
	var.hpBar = var.centerBottom:getWidgetByName("progressHpBar"):setRotation(-90):setScale(1.3)
	var.mpBar = var.centerBottom:getWidgetByName("progressMpBar"):setRotation(-90)
	
	--动态血条
	local startNum = 1
	local function startShowBg()
		local filepath = string.format("new_main_ui_xuetiao%02d.png",startNum)
		var.hpBar:loadTexture(filepath,ccui.TextureResType.plistType)
		
		startNum= startNum+1
		if startNum ==49 then
			startNum =1
		end
	end
	var.hpBar:stopAllActions()
	var.hpBar:runAction(cca.repeatForever(cca.seq({cca.delay(0.2),cca.cb(startShowBg)}),tonumber(16)))
	
	--动态蓝条
	local startMpNum = 1
	local function startShowMpBg()
		local filepath = string.format("new_main_ui_lantiao%02d.png",startMpNum)
		var.mpBar:loadTexture(filepath,ccui.TextureResType.plistType)
		
		startMpNum= startMpNum+1
		if startMpNum ==2 then
			startMpNum =1
		end
	end
	var.mpBar:stopAllActions()
	var.mpBar:runAction(cca.repeatForever(cca.seq({cca.delay(0.2),cca.cb(startShowMpBg)}),tonumber(16)))
	
	--GameUtilSenior.addEffect(var.centerBottom:getWidgetByName("btnVip"),"spriteEffect",4,200001,{x=-37,y=120},false,true)
	GUIFocusPoint.addUIPoint(var.centerBottom:getWidgetByName("btnVip"),function(sender)
		--print("asdasdasdasdasd")
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="V9_FengShen"})
	end)


	var.layerMoreBtn = var.centerBottom:getWidgetByName("layerMoreBtn")

	for k,v in pairs(btnInfo) do
		GUIFocusPoint.addUIPoint(var.centerBottom:getWidgetByName(k),function(sender)
			if GameUtilSenior.isTable(v) then
				--GUICenterBottom.handleShowMoreBtn( v,sender )
				GUICenterBottom.showMoreBtn( v,sender )
			else
				if v ~= "" then
					if k=="btnPaiHang" then
						GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = v,tab=6})
					else
						GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = v})
					end
					var.layerMoreBtn:setVisible(false)
				end
			end	
		end)
	end
	GameUtilSenior.clickOtherPlace(var.centerBottom,var.layerMoreBtn:getLocalZOrder()-1,function(event)
		var.layerMoreBtn:hide()
	end)
	GUICenterBottom.handlefreshHPMP()
	--GUICenterBottom.handleSetPKNoraml() --默认显示菜单
end
function GUICenterBottom.showBagFull(event)
	local btnMainBag = var.centerBottom:getWidgetByName("btnBag")
	local image = btnMainBag:getChildByName("img_bag_full")
	local img_red_dot = btnMainBag:getChildByName("img_red_dot")
	if not img_red_dot then
		-- img_red_dot
		local size = btnMainBag:getContentSize()
		img_red_dot=ccui.ImageView:create()
		local imageSize = img_red_dot:getContentSize()
		img_red_dot:setName("img_red_dot")
		img_red_dot:setPositionX(60)
		img_red_dot:setPositionY(65)
		btnMainBag:addChild(img_red_dot)
		img_red_dot:loadTexture("img_red_dot",ccui.TextureResType.plistType)
	end
	if not image then
		local size = btnMainBag:getContentSize()
		image=ccui.ImageView:create()
		local imageSize = image:getContentSize()
		image:setName("img_bag_full")
		image:setPositionX(60)
		image:setPositionY(65)
		btnMainBag:addChild(image)
		
	end
	GameUtilSenior.asyncload(btnMainBag, "img_bag_full", "ui/image/bag_full_icon.png")
	image:setVisible(event.vis or false)
	img_red_dot:setVisible(event.vis or false)
end
function GUICenterBottom.showMoreBtn( arr,sender)
	local panel = var.centerBottom:getWidgetByName("Panel_"..sender:getName())
	for i=1,#arr do
		if arr[i].panel~="" then
			var.centerBottom:getWidgetByName(arr[i].normal):addClickEventListener(function ( ... )
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = arr[i].panel})
				panel:hide()
			end)
			if not GameSocket:checkFuncOpened(arr[i].panel) then
				var.centerBottom:getWidgetByName(arr[i].normal):setBright(false)
				var.centerBottom:getWidgetByName(arr[i].normal):getChildByName("Image_2"):getVirtualRenderer():setState(1)
			else
				var.centerBottom:getWidgetByName(arr[i].normal):setBright(true)
				var.centerBottom:getWidgetByName(arr[i].normal):getChildByName("Image_2"):getVirtualRenderer():setState(0)
			end
		end
	end
	local pos = {}
	if sender:getName()=="btnOther" then
		pos.x = sender:getPositionX()-375
		pos.y = 130
	else
		pos.x = sender:getPositionX()-285
		pos.y = 130
	end
	panel:setPosition(pos):setVisible(not panel:isVisible())
	if var.last_panel and var.last_panel~=panel then
	 	var.last_panel:setVisible(false)
	end
	var.last_panel=panel
end

--展示更多功能按钮
function GUICenterBottom.handleShowMoreBtn( arr,sender )
	var.layerMoreBtn:removeAllChildren()
	local tabBtn = {}
	local width = 0
	local height = 0
	local spaceX = 2
	local size
	local sizeWidth = {}
	for i,v in ipairs(arr) do
		if v and v.normal ~= "" then
			local node=ccui.Button:create()
			node:loadTextureNormal(v.normal,ccui.TextureResType.plistType)
			node:setName(v.name)
			node:setAnchorPoint(cc.p(0,0))
			GUIFocusPoint.addUIPoint(node,function ()
				if v.panel ~= "" then
					GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = v.panel})
				end
				var.layerMoreBtn:hide()
			end)
			tabBtn[#tabBtn + 1] = node
			size = node:getContentSize()
			sizeWidth[#sizeWidth + 1] = width
			width = width + size.width + 2
			if size.height > height then height = size.height end
		end
	end
	height = height + 10
	width = width + 10
	local startX = 5
	local startY = 5
	var.layerMoreBtn:setContentSize(cc.size(width,height))
	for i,v in ipairs(tabBtn) do
		v:setPositionX(sizeWidth[i] + startX)
		v:setPositionY(startY)
		var.layerMoreBtn:addChild(v)
	end
	var.layerMoreBtn:show()
	-- local pos = sender:convertToNodeSpace(cc.p(sender:getParent():getPositionX(),sender:getParent():getPositionY()))
	local pos = {}
	pos.x = sender:getPositionX()-280
	pos.y = 100
	var.layerMoreBtn:setPosition(pos)
end
--点击中间的球 打开不同的模式
function GUICenterBottom.handleSetPKNoraml()
	if var.can_move then
		var.can_move = false
	else
		return
	end
	var.notPk = not var.notPk
	var.layerLeftBtn:setVisible(var.notPk)
	--[[
	暂时隐藏按钮
	var.Panel_btn:setVisible(true)
	var.Panel_btn:runAction(cca.seq({
		cca.moveTo(0.2, var.Panel_btn:getPositionX(), var.Panel_btn:getPositionY()+80*(var.notPk and 1 or -1)),
		cca.cb(function ()
			var.can_move = true
		end)
	}))
	]]--
	GUILeftBottom.set_chat_visible(not var.notPk)
	GUIRightBottom.set_Skill_Pos(var.notPk)
	--GUIRightTop.set_box_func_preview_visible(not var.notPk)
	GUIFunctionBeta.set_GUIFunctionBeta_visible(not var.notPk)
	if var.last_panel then
	 	var.last_panel:setVisible(false)
	end
	-- var.imgLeft:setVisible(var.notPk)
	-- var.imgRight:setVisible(var.notPk)
end
----事件监听函数
function GUICenterBottom.handlefreshHPMP( event )
	if GameCharacter and GameCharacter._mainAvatar and event and event.param then
		local hp = 		GameCharacter._mainAvatar:NetAttr(GameConst.net_hp)
		local maxhp = 	GameCharacter._mainAvatar:NetAttr(GameConst.net_maxhp)
		local mp =		GameCharacter._mainAvatar:NetAttr(GameConst.net_mp)
		local maxmp = 	GameCharacter._mainAvatar:NetAttr(GameConst.net_maxmp)
		var.hpBar:setPercent(hp/maxhp*100)
		var.mpBar:setPercent(mp/maxmp*100)
		
		--var.hpBar:setPercentWithAnimation(hp,maxhp)
		--var.mpBar:setPercentWithAnimation(mp,maxmp)
	end
end
function GUICenterBottom.handleExpChange(event)
	if var.expBar then
		var.expBar:setPercent(GameSocket.mCharacter.mCurExperience,GameSocket.mCharacter.mCurrentLevelMaxExp)
	end
end
return GUICenterBottom