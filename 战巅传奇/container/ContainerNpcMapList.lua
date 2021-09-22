local ContainerNpcMapList = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function ContainerNpcMapList.onPanelOpen(event)

end

function ContainerNpcMapList.initView(extend)
	var = {
		items={},
		xmlPanel,
		mapList,
		tableview ,
	}
	var.mapList = extend.result.mapList
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerNpcMapList.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerNpcMapList.handlePanelData)

		ContainerNpcMapList.showTitleAnimation()
		
		var.xmlPanel:getWidgetByName("duanzao_btn"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_MoDaoDuanZao.handlePanelData",GameUtilSenior.encode({actionid = "exchange"}))
		end)
		
		if var.mapList.resData==nil or var.mapList.resData.index==nil then
			var.mapList.resData.index = 1
		else
			var.mapList.resData.index = tonumber(var.mapList.resData.index)
		end
		
		ContainerNpcMapList.showList()
				
		return var.xmlPanel
	end
end

function ContainerNpcMapList.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end

function ContainerNpcMapList.showList()
	var.tableview = var.xmlPanel:getWidgetByName("ListView")
	var.tableview:reloadData(#var.mapList.name, function(subItem)
		subItem:getWidgetByName("mapName"):setTitleText(var.mapList.name[subItem.tag])
		if subItem.tag==var.mapList.resData.index then
			subItem:getWidgetByName("mapName"):loadTextureNormal("common_big_zbhs_tab_btn_1.png",ccui.TextureResType.plistType)
		end
		if subItem.tag==#var.mapList.name-1 then
			local moveTo = var.mapList.resData.index - 2
			if var.mapList.resData.index<1 then
				moveTo = 1
			end
			var.tableview:autoMoveToIndex(moveTo)
		end
		table.insert(var.items,subItem)
		subItem:getWidgetByName("mapName"):setTouchEnabled(true):addClickEventListener(function( sender )
			for i,v in ipairs(var.items) do
				v:getWidgetByName("mapName"):loadTextureNormal("common_big_zbhs_tab_btn_2.png",ccui.TextureResType.plistType)
			end
			subItem:getWidgetByName("mapName"):loadTextureNormal("common_big_zbhs_tab_btn_1.png",ccui.TextureResType.plistType)
			ContainerNpcMapList.showMapInfo(subItem.tag)
			local moveTo = subItem.tag - 2
			if subItem.tag<1 then
				moveTo = 1
			end
			var.tableview:autoMoveToIndex(moveTo)
			--if subItem.tag>5 then
			--	local moveTo = subItem.tag - 1
			--	tableview:autoMoveToIndex(moveTo)
			--else
			--	tableview:autoMoveToIndex(1)
			--end
		end)
	end,nil,false)
	
	ContainerNpcMapList.showMapInfo(var.mapList.resData.index)
end

function ContainerNpcMapList.showMapInfo(index)
	ContainerNpcMapList.updateList( var.xmlPanel:getWidgetByName("descList"),var.mapList.str[index] )
end

function ContainerNpcMapList.updateList( list,strs )
	local t = {}
	if GameUtilSenior.isString(strs) then
		table.insert(t,strs)
	elseif GameUtilSenior.isTable(strs) then
		t = strs
	end
	list:removeAllItems()
	for i,v in ipairs(t) do
		local richLabel = GUIRichLabel.new({size = cc.size(list:getContentSize().width, 40), space=10,name = "hintMsg"..i})
		richLabel:setRichLabel(v,"panel_npctalk")
		list:pushBackCustomItem(richLabel)
	end
end

function ContainerNpcMapList.handlePanelData(event)
	if event.type == "v4_PanelMoDaoDuanZao" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			ContainerNpcMapList.showMoDaoAnimation(data.data)
		end
	end
end


function ContainerNpcMapList.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.v4_MoDaoDuanZao.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function ContainerNpcMapList.onPanelClose()

end

return ContainerNpcMapList