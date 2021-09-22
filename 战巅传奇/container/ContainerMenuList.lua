local ContainerMenuList = {}

local var = {}

local btn_order = {
	{btn = "menu_mail",			str = "邮件", lv=1},
	{btn = "btn_main_rank",		str = "排行", lv=75},

	{btn = "menu_gongxun",		str = "功勋", lv=1},
	{btn = "menu_duanzao",		str = "锻造", lv=1},
	{btn = "menu_huwei",		str = "护卫", lv=1},
	
	-- {btn = "menu_title",		str = "称号", lv=1},
	{btn = "menu_depot",	    str = "仓库", lv=1},
	{btn = "menu_skill",	    str = "技能", lv=1},
	-- {btn = "menu_innerpower",	str = "内功", lv=1},
	{btn = "menu_team",			str = "组队", lv=1},
	{btn = "menu_shenjiang",	str = "神将", lv=1},--lv=17
	{btn = "menu_friend",		str = "好友", lv=1},
	-- {btn = "menu_forge",		str = "锻造", lv=32},
	{btn = "menu_recycle",		str = "回收", lv=1},
	{btn = "menu_furnace",		str = "熔炉", lv=1},
	-- {btn = "menu_escort",		str = "押镖", lv=49},
	{btn = "menu_guild",		str = "帮会", lv=1},
	{btn = "main_achieve",		str = "成就", lv=1},
	{btn = "menu_wing",			str = "翅膀", lv=1},
	{btn = "menu_official",		str = "官印", lv=1},
	-- {btn = "menu_mount",		str = "坐骑", lv=75},
	-- {btn = "menu_spirit",		str = "元神", lv=80},
	-- {btn = "menu_zhuling",		str = "注灵"},
	-- {btn = "menu_zhuansheng",	str = "转生", lv=80},

	

	
	
-- "menu_innerpower",屏蔽内功--"menu_spirit","menu_skill", "main_achieve","menu_m
}

local btn_side = {
	["menu_back"]	= "返回",
	["menu_store"]	= "商城",
	["menu_set"]	= "设置",
	["menu_avatar"]	= "角色",
	["menu_equip"]	= "装备",
	["menu_bag"]	= "背包",
}

function ContainerMenuList.initView()
	var = {
		xmlPanel,
		menuTable = {},
		firstLoad = true,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerMenuList.uif")
	if var.xmlPanel then
		var.xmlPanel.movable = true
	 	var.xmlPanel:setTouchEnabled(true)
	 	for k,v in pairs(btn_side) do
	 		local btnMenu = var.xmlPanel:getWidgetByName(k)
	 		if btnMenu then
	 			btnMenu.str = v
		 		GUIFocusPoint.addUIPoint(btnMenu, ContainerMenuList.pushMenuButton)
		 	end
	 	end
	 	return var.xmlPanel
	end
end

function ContainerMenuList.onPanelOpen()
	var.menuTable = {}
	local menuBox = var.xmlPanel:getWidgetByName("menuBox")
	if var.firstLoad or GameSocket.menuChange then --有新功能开启或者重新加载面板
		var.firstLoad = false
		GameSocket.menuChange = false
		menuBox:removeAllChildren()
	 	local boxSize = menuBox:getContentSize()
	 	local menuNum = #btn_order
	 	local totalY = (menuNum % 4 > 0) and math.floor((menuNum) / 4 ) + 1 or menuNum / 4
	 	menuBox:setInnerContainerSize(cc.size(boxSize.width, boxSize.height / 3 * totalY))
	 	local innerSize = menuBox:getInnerContainerSize()
	 	local index = 1
	 	for i,v in ipairs(btn_order) do
	 		if GameSocket.m_func["menu"][v.btn] then
	 			table.insert(var.menuTable, index, {name = v.btn, str = v.str, show = true,lv=v.lv})
	 			index = index +1
	 		else
	 			table.insert(var.menuTable, {name = v.btn, str = v.str, show = false,lv=v.lv})
	 		end
	 	end
	 	for i,v in ipairs(var.menuTable) do
 			local index_x = ( i - 1 ) % 4
	 		local index_y = math.floor(( i - 1 ) / 4)
	 		local btnMenu = ccui.Button:create()
	 			:align(display.CENTER, 60 + index_x * 120, innerSize.height - 70 - index_y * 140)
	 			:addTo(menuBox)
	 			:setScale9Enabled(true)
	 			:setContentSize(cc.size(119, 134))
	 			:setTouchEnabled(v.show)
	 			:setName(v.name)
	 		btnMenu.str = v.str
	 		local resList = {"image/icon/"..v.name..".png", "image/icon/"..v.name.."_sel.png"}
	 		-- asyncload_list(resList,btnMenu,function (filelist,res)
				
			asyncload_callback("image/icon/"..v.name..".png", btnMenu, function(filepath, texture)
				asyncload_callback("image/icon/"..v.name.."_sel.png", btnMenu, function(filepath1, texture1)
					btnMenu:loadTextures(resList[1],resList[2],"",ccui.TextureResType.localType)
				end)
			end)
			
			--btnMenu:loadTextures(resList[1],resList[2],"",ccui.TextureResType.localType)


			if not v.show then
		 		btnMenu:setBright(false)
		 		local openlab = ccui.Text:create()
					:setFontSize(18)
					:setString(v.lv.."级开放")
					:setColor(cc.c3b(200,200,200))
					:addTo(btnMenu)
					:setPosition(55,3)
		 	end
	 		GUIFocusPoint.addUIPoint(btnMenu, ContainerMenuList.pushMenuButton)
			-- end)
	 	end
	end
end

function ContainerMenuList.pushMenuButton(sender)
	local btnName = sender:getName()
		print(sender.str)
	if btnName=="menu_depot" then
		GameSocket:PushLuaTable("gui.ContainerBag.handlePanelData",GameUtilSenior.encode({actionid = "reqOpenDepot",params = {}}))	
		return
	end
	if btnName == "menu_back" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "panel_menu"})
	else
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = btnName})
		print(sender.str)
		GameSocket:PushLuaTable("count.onClientData", GameUtilSenior.encode({cmd = sender.str}))
	end
end

function ContainerMenuList.onPanelClose()
	
end

return ContainerMenuList