local V4_ContainerRMBHuiShou = {}
local var = {}
local page = 1


local currentDaLuInfoIndex = 0
local menuRes = {
	{res="panel_rmbhs_37.png",sel="panel_rmbhs_36.png"},
	{res="panel_rmbhs_37.png",sel="panel_rmbhs_36.png"},
	{res="panel_rmbhs_37.png",sel="panel_rmbhs_36.png"},
	{res="panel_rmbhs_37.png",sel="panel_rmbhs_36.png"},
	{res="panel_rmbhs_37.png",sel="panel_rmbhs_36.png"},
	{res="panel_rmbhs_37.png",sel="panel_rmbhs_36.png"},
}

function V4_ContainerRMBHuiShou.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerRMBHuiShou.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerRMBHuiShou.handlePanelData)

		V4_ContainerRMBHuiShou.menuClick(1)
		V4_ContainerRMBHuiShou.showTitleAnimation()
		V4_ContainerRMBHuiShou.initMenu()
		V4_ContainerRMBHuiShou.changeMenuRes(1)
		
		var.xmlPanel:getWidgetByName("left_arr_1"):addClickEventListener(function ( sender )
			page = page - 1
			if page>0 then
				GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "huishouList",page=page}))
			else
				page = 1
			end
		end)
		var.xmlPanel:getWidgetByName("right_arr_1"):addClickEventListener(function ( sender )
			page = page + 1
			if page<13 then
				GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "huishouList",page=page}))
			else
				page = 12
			end
		end)
		
		var.xmlPanel:getWidgetByName("left_arr_2"):addClickEventListener(function ( sender )
			page = page - 1
			if page>0 then
				GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "huigouList",page=page}))
			else
				page = 1
			end
		end)
		
		var.xmlPanel:getWidgetByName("right_arr_2"):addClickEventListener(function ( sender )
			page = page + 1
			if page<130 then
				GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "huigouList",page=page}))
			else
				page = 12
			end
		end)
		
		var.xmlPanel:getWidgetByName("left_arr_3"):addClickEventListener(function ( sender )
			page = page - 1
			if page>0 then
				GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "awardsuitList",page=page}))
			else
				page = 1
			end
		end)
		var.xmlPanel:getWidgetByName("right_arr_3"):addClickEventListener(function ( sender )
			page = page + 1
			if page<7 then
				GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "awardsuitList",page=page}))
			else
				page = 6
			end
		end)
		
		
		var.xmlPanel:getWidgetByName("left_arr_4"):addClickEventListener(function ( sender )
			page = page - 1
			if page>0 then
				GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "awardList",page=page}))
			else
				page = 1
			end
		end)
		var.xmlPanel:getWidgetByName("right_arr_4"):addClickEventListener(function ( sender )
			page = page + 1
			if page<22 then
				GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "awardList",page=page}))
			else
				page = 21
			end
		end)
				
		
		var.xmlPanel:getWidgetByName("left_arr_5"):addClickEventListener(function ( sender )
			page = page - 1
			if page>0 then
				GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "bossAwardList",page=page}))
			else
				page = 1
			end
		end)
		var.xmlPanel:getWidgetByName("right_arr_5"):addClickEventListener(function ( sender )
			page = page + 1
			if page<11 then
				GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "bossAwardList",page=page}))
			else
				page = 10
			end
		end)	
					
		return var.xmlPanel
	end
end

function V4_ContainerRMBHuiShou.initMenu()
	for i=1,6,1 do
		var.xmlPanel:getWidgetByName("menu_btn_"..i):addClickEventListener(function ( sender )
			V4_ContainerRMBHuiShou.changeMenuRes(i)
			V4_ContainerRMBHuiShou.menuClick(i)
		end)
	end
end

function V4_ContainerRMBHuiShou.changeMenuRes(index)
	for i=1,6,1 do
		if i~=index then
			var.xmlPanel:getWidgetByName("menu_btn_"..i):loadTextureNormal(menuRes[i].res,ccui.TextureResType.plistType)
			var.xmlPanel:getWidgetByName("menu_btn_"..i):loadTexturePressed(menuRes[i].sel,ccui.TextureResType.plistType)
		else
			var.xmlPanel:getWidgetByName("menu_btn_"..i):loadTextureNormal(menuRes[i].sel,ccui.TextureResType.plistType)
			var.xmlPanel:getWidgetByName("menu_btn_"..i):loadTexturePressed(menuRes[i].sel,ccui.TextureResType.plistType)
		end
	end
end

function V4_ContainerRMBHuiShou.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	local startNum = 1
	local function startShowTitleBg()
	
		local filepath = string.format("ui/image/ContainerTitle/new_game_panel_title_%d.png",startNum)
		asyncload_callback(filepath, title_animal, function(filepath, texture)
			title_animal:loadTexture(filepath)
		end)
		
		startNum= startNum+1
		if startNum ==31 then
			startNum =1
		end
	end
	title_animal:stopAllActions()
	title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowTitleBg)}),tonumber(30)))
		
end

function V4_ContainerRMBHuiShou.menuClick(index)
	page = 1
	for i=1,6,1 do
		var.xmlPanel:getWidgetByName("list_container_"..i):setVisible(false)
		var.xmlPanel:getWidgetByName("container_"..i):setVisible(false)
	end
	var.xmlPanel:getWidgetByName("list_container_"..index):setVisible(true)
	var.xmlPanel:getWidgetByName("container_"..index):setVisible(true)
	
	if index==1 then
		GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "huishouList",page=page}))
	end
	if index==2 then
		GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "huigouList",page=page}))
	end
	if index==3 then
		GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "awardsuitList",page=page}))
	end
	if index==4 then
		GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "awardList",page=page}))
	end
	if index==5 then
		GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "bossAwardList",page=page}))
	end
	if index==6 then
		GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "exchangeMoneyList"}))
	end
end

function V4_ContainerRMBHuiShou.showList1(dataremote)
			
	local list_container = var.xmlPanel:getWidgetByName("list_container_1"):setVisible(true)
	list_container:reloadData(#dataremote,function( subItem )
		local datalocal = dataremote[subItem.tag]
		datalocal = string.split(datalocal, ":")
		subItem:getWidgetByName("no_1"):setText("No."..subItem.tag+(page-1)*10)
		--subItem:getWidgetByName("equip_info_1"):setText(datalocal[3])	
		subItem:getWidgetByName("equip_name_1"):setText(datalocal[2])
		subItem:getWidgetByName("price_1"):setText(datalocal[4].."钻石")
		subItem:getWidgetByName("btn_1"):setText(datalocal[5])
		--subItem:getWidgetByName("btn_1").itemIndex = subItem.tag+(page-1)*10
		--subItem:getWidgetByName("btn_1"):addClickEventListener(function ( sender )
		--	GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "huishou",index=sender.itemIndex}))
		--end)
	end)
	
end


function V4_ContainerRMBHuiShou.showList2(dataremote)
	
	local list_container = var.xmlPanel:getWidgetByName("list_container_2"):setVisible(true)
	list_container:reloadData(#dataremote,function( subItem )
		local datalocal = dataremote[subItem.tag]
		datalocal = string.split(datalocal, ":")
		subItem:getWidgetByName("no_1"):setText("No."..subItem.tag+(page-1)*10)
		--subItem:getWidgetByName("equip_info_1"):setText(datalocal[2])	
		subItem:getWidgetByName("equip_name_1"):setText(datalocal[2])
		--subItem:getWidgetByName("equip_num_1"):setText(datalocal[6])
		subItem:getWidgetByName("price_1"):setText(datalocal[4].."钻石")
		subItem:getWidgetByName("btn_1"):setText(datalocal[5])
		--subItem:getWidgetByName("btn_1").itemIndex = subItem.tag+(page-1)*10
		--subItem:getWidgetByName("btn_1"):addClickEventListener(function ( sender )
		--	GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "huigou",index=sender.itemIndex}))
		--end)
		
	end)
	
end


function V4_ContainerRMBHuiShou.showList3(dataremote)
		
	local list_container = var.xmlPanel:getWidgetByName("list_container_3"):setVisible(true)
	list_container:reloadData(#dataremote,function( subItem )
		local datalocal = dataremote[subItem.tag]
		datalocal = string.split(datalocal, ":")
		subItem:getWidgetByName("no_1"):setText("No."..subItem.tag+(page-1)*10)
		subItem:getWidgetByName("equip_name_1"):setText(datalocal[2])
		--subItem:getWidgetByName("equip_info_1"):setText(datalocal.price.."RMB")
		subItem:getWidgetByName("price_1"):setText(datalocal[4].."钻石")
		subItem:getWidgetByName("btn_1"):setText(datalocal[5])
		--subItem:getWidgetByName("btn_1").itemIndex = subItem.tag+(page-1)*10
		--subItem:getWidgetByName("btn_1"):addClickEventListener(function ( sender )
		--	GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "awardsuit",index=sender.itemIndex}))
		--end)
		
	end)
	
end



function V4_ContainerRMBHuiShou.showList4(dataremote)
	
	local list_container = var.xmlPanel:getWidgetByName("list_container_4"):setVisible(true)
	list_container:reloadData(#dataremote,function( subItem )
		local datalocal = dataremote[subItem.tag]
		datalocal = string.split(datalocal, ":")
		subItem:getWidgetByName("no_1"):setText("No."..subItem.tag+(page-1)*10)
		subItem:getWidgetByName("equip_name_1"):setText(datalocal[2])	
		--subItem:getWidgetByName("equip_info_1"):setText(datalocal[3].."RMB")
		subItem:getWidgetByName("price_1"):setText(datalocal[4].."钻石")
		subItem:getWidgetByName("btn_1"):setText(datalocal[5])
		--subItem:getWidgetByName("btn_1").itemIndex = subItem.tag+(page-1)*10
		--subItem:getWidgetByName("btn_1"):addClickEventListener(function ( sender )
		--	GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "awarditem",index=sender.itemIndex}))
		--end)
		
	end)
	
end


function V4_ContainerRMBHuiShou.showList5(dataremote)
		
	local list_container = var.xmlPanel:getWidgetByName("list_container_5"):setVisible(true)
	list_container:reloadData(#dataremote,function( subItem )
		local datalocal = dataremote[subItem.tag]
		datalocal = string.split(datalocal, ":")
		subItem:getWidgetByName("no_1"):setText("No."..subItem.tag+(page-1)*10)
		subItem:getWidgetByName("equip_name_1"):setText(datalocal[2])
		--subItem:getWidgetByName("equip_info_1"):setText(datalocal[2])
		--subItem:getWidgetByName("equip_num_1"):setText(datalocal[3])
		subItem:getWidgetByName("price_1"):setText(datalocal[4].."钻石")
		subItem:getWidgetByName("btn_1"):setText(datalocal[5])
		
	end)
	
end


function V4_ContainerRMBHuiShou.showList6(dataremote)
		
	local list_container = var.xmlPanel:getWidgetByName("list_container_6"):setVisible(true)
	list_container:reloadData(#dataremote,function( subItem )
		local datalocal = dataremote[subItem.tag]
		datalocal = string.split(datalocal, ":")
		subItem:getWidgetByName("no_1"):setText("No."..subItem.tag+(page-1)*10)
		--subItem:getWidgetByName("equip_info_1"):setText(datalocal.vcoin)
		subItem:getWidgetByName("equip_name_1"):setText(datalocal[2])
		--subItem:getWidgetByName("equip_num_1"):setText(datalocal.bindgamemoney)
		subItem:getWidgetByName("price_1"):setText(datalocal[4].."钻石")
		subItem:getWidgetByName("btn_1"):setText(datalocal[5])
		--subItem:getWidgetByName("btn_1").itemIndex = subItem.tag
		--subItem:getWidgetByName("btn_1"):addClickEventListener(function ( sender )
		--	GameSocket:PushLuaTable("npc.v4_RMBHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "exchangeMoney",index=sender.itemIndex}))
		--end)
		
	end)
	
end

function V4_ContainerRMBHuiShou.handlePanelData(event)
	if event.type == "v4_PanelRMBHuiShou" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="huishou" then
			V4_ContainerRMBHuiShou.showList1(data.itemList)
		end
		if data.cmd =="huigou" then
			V4_ContainerRMBHuiShou.showList2(data.itemList)
		end
		if data.cmd =="awardsuit" then
			local remain = (86400-tonumber(data.remain))/60
			if remain<0 then
				remain=0
			end
			--var.xmlPanel:getWidgetByName("time_3"):setText(remain.."分钟")
			V4_ContainerRMBHuiShou.showList3(data.itemList)
		end
		if data.cmd =="awardList" then
			local remain = (86400-tonumber(data.remain))/60
			if remain<0 then
				remain=0
			end
			--var.xmlPanel:getWidgetByName("time_4"):setText(remain.."分钟")
			V4_ContainerRMBHuiShou.showList4(data.itemList)
		end
		if data.cmd =="bossAwardList" then
			V4_ContainerRMBHuiShou.showList5(data.itemList)
		end		
		if data.cmd =="exchangeMoneyList" then
			V4_ContainerRMBHuiShou.showList6(data.itemList)
		end		
	end
end

function V4_ContainerRMBHuiShou.onPanelOpen(extend)
end

function V4_ContainerRMBHuiShou.onPanelClose()

end

return V4_ContainerRMBHuiShou