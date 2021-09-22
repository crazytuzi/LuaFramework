local V9_ContainerBossList = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V9_ContainerBossList.onPanelOpen(event)

end

function V9_ContainerBossList.initView(extend)
	var = {
		items={},
		xmlPanel,
		index=1,
		page=1,
		totalPage=1,
	}
	--var.mapList = extend.result.mapList
	var.xmlPanel = GUIAnalysis.load("ui/layout/V9_ContainerBossList.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V9_ContainerBossList.handlePanelData)

		--var.xmlPanel:getWidgetByName("box_tab"):setTabRes("V9_ContainerBossList_34.png","V9_ContainerBossList_33.png",ccui.TextureResType.plistType)
		
		--V9_ContainerBossList.showTitleAnimation()
		
		var.xmlPanel:getWidgetByName("navi_first"):addClickEventListener(function ( sender )
			if var.page~=1 then
				GameSocket:PushLuaTable("gui.V9_ContainerBossList.handlePanelData",GameUtilSenior.encode({actionid = "getMessage",index=var.index,page=1}))
			end
		end)
		var.xmlPanel:getWidgetByName("navi_pre"):addClickEventListener(function ( sender )
			if var.page-1>=1 then
				GameSocket:PushLuaTable("gui.V9_ContainerBossList.handlePanelData",GameUtilSenior.encode({actionid = "getMessage",index=var.index,page=var.page-1}))
			end
		end)
		var.xmlPanel:getWidgetByName("navi_next"):addClickEventListener(function ( sender )
			if var.page+1<=var.totalPage then
				GameSocket:PushLuaTable("gui.V9_ContainerBossList.handlePanelData",GameUtilSenior.encode({actionid = "getMessage",index=var.index,page=var.page+1}))
			end
		end)
		var.xmlPanel:getWidgetByName("navi_end"):addClickEventListener(function ( sender )
			if var.page~=var.totalPage then
				GameSocket:PushLuaTable("gui.V9_ContainerBossList.handlePanelData",GameUtilSenior.encode({actionid = "getMessage",index=var.index,page=var.totalPage}))
			end
		end)
		
		var.xmlPanel:getWidgetByName("box_tab"):addTabEventListener(V9_ContainerBossList.pushTabButtons)
		
		
		var.xmlPanel:getWidgetByName("box_tab"):setItemMargin(3)
		if extend.tab then
			var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab( tonumber(extend.tab) )
		else
			var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab( 1 )
		end
		
		return var.xmlPanel
	end
end


function V9_ContainerBossList.pushTabButtons(sender)
	local tag = sender:getTag()
	
	var.index=tag
	var.xmlPanel:getWidgetByName("title_image"):loadTexture("title_exchange.png", ccui.TextureResType.plistType)
	V9_ContainerBossList.updateList( var.xmlPanel:getWidgetByName("title_richDesc"),"<td color=#BF7700 size=15 width=8>序号</td><td color=#BF7700 size=15 width=27>BOSS</td><td color=#BF7700 size=15 width=17>刷新间隔</td><td color=#BF7700 size=15 width=17>是否可进</td><td color=#BF7700 size=15 width=17>是否存在</td><td color=#BF7700 size=15 width=13>进入</td>" )
	
	GameSocket:PushLuaTable("gui.V9_ContainerBossList.handlePanelData",GameUtilSenior.encode({actionid = "getMessage",index=var.index,page=1}))
end

function V9_ContainerBossList.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end

function V9_ContainerBossList.showDescList(data)
	local tableview = var.xmlPanel:getWidgetByName("ListView")
	tableview:reloadData(#data.list, function(subItem)
		V9_ContainerBossList.updateList( subItem:getWidgetByName("richDesc"),data.list[subItem.tag] )
	end,nil,false)
	var.page= data.page
	var.totalPage = data.totalPage
	var.xmlPanel:getWidgetByName("tips"):setString(data.page.." / "..data.totalPage)
end

function V9_ContainerBossList.updateList( list,strs )
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

function V9_ContainerBossList.handlePanelData(event)
	if event.type == "V9_ContainerBossList" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			V9_ContainerBossList.showDescList(data)
		end
	end
end


function V9_ContainerBossList.onPanelOpen(extend)
	
end

function V9_ContainerBossList.onPanelClose()

end

return V9_ContainerBossList