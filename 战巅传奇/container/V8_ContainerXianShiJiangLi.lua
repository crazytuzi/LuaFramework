local V8_ContainerXianShiJiangLi = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V8_ContainerXianShiJiangLi.onPanelOpen(event)

end

function V8_ContainerXianShiJiangLi.initView(extend)
	var = {
		items={},
		xmlPanel,
		index=1,
		page=1,
		totalPage=1,
	}
	--var.mapList = extend.result.mapList
	var.xmlPanel = GUIAnalysis.load("ui/layout/V8_ContainerXianShiJiangLi.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V8_ContainerXianShiJiangLi.handlePanelData)

		--var.xmlPanel:getWidgetByName("box_tab"):setTabRes("V8_ContainerXianShiJiangLi_34.png","V8_ContainerXianShiJiangLi_33.png",ccui.TextureResType.plistType)
		
		--V8_ContainerXianShiJiangLi.showTitleAnimation()
		
		var.xmlPanel:getWidgetByName("navi_first"):addClickEventListener(function ( sender )
			if var.page~=1 then
				GameSocket:PushLuaTable("gui.V8_ContainerXianShiJiangLi.handlePanelData",GameUtilSenior.encode({actionid = "getMessage",index=var.index,page=1}))
			end
		end)
		var.xmlPanel:getWidgetByName("navi_pre"):addClickEventListener(function ( sender )
			if var.page-1>=1 then
				GameSocket:PushLuaTable("gui.V8_ContainerXianShiJiangLi.handlePanelData",GameUtilSenior.encode({actionid = "getMessage",index=var.index,page=var.page-1}))
			end
		end)
		var.xmlPanel:getWidgetByName("navi_next"):addClickEventListener(function ( sender )
			if var.page+1<=var.totalPage then
				GameSocket:PushLuaTable("gui.V8_ContainerXianShiJiangLi.handlePanelData",GameUtilSenior.encode({actionid = "getMessage",index=var.index,page=var.page+1}))
			end
		end)
		var.xmlPanel:getWidgetByName("navi_end"):addClickEventListener(function ( sender )
			if var.page~=var.totalPage then
				GameSocket:PushLuaTable("gui.V8_ContainerXianShiJiangLi.handlePanelData",GameUtilSenior.encode({actionid = "getMessage",index=var.index,page=var.totalPage}))
			end
		end)
		
		var.xmlPanel:getWidgetByName("box_tab"):addTabEventListener(V8_ContainerXianShiJiangLi.pushTabButtons)
		
		
		
		if extend.tab then
			var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab( tonumber(extend.tab) )
			if tonumber(extend.tab)==6 then
				var.xmlPanel:getWidgetByName("box_tab"):hideTab({1,2,3,4,5,7})
			elseif tonumber(extend.tab)==7 then
				var.xmlPanel:getWidgetByName("box_tab"):hideTab({1,2,3,4,5,6})
			else
				var.xmlPanel:getWidgetByName("box_tab"):hideTab({1,4,6,7})
			end
		else
			var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab( 2 )
			var.xmlPanel:getWidgetByName("box_tab"):hideTab(6,7)
		end
		
		return var.xmlPanel
	end
end


function V8_ContainerXianShiJiangLi.pushTabButtons(sender)
	local tag = sender:getTag()
	if tag==1 then
		var.index=1
		var.xmlPanel:getWidgetByName("title_image"):loadTexture("title.png", ccui.TextureResType.plistType)
		V8_ContainerXianShiJiangLi.updateList( var.xmlPanel:getWidgetByName("title_richDesc"),"<td color=#BF7700 size=15 width=8>序号</td><td color=#BF7700 size=15 width=40>装备</td><td color=#BF7700 size=15 width=18>奖励金额</td><td color=#BF7700 size=15 width=20>领取人</td><td color=#BF7700 size=15 width=13>领取奖励</td>" )
	end
	if tag==2 then
		var.index=2
		var.xmlPanel:getWidgetByName("title_image"):loadTexture("title.png", ccui.TextureResType.plistType)
		V8_ContainerXianShiJiangLi.updateList( var.xmlPanel:getWidgetByName("title_richDesc"),"<td color=#BF7700 size=15 width=8>序号</td><td color=#BF7700 size=15 width=40>装备</td><td color=#BF7700 size=15 width=18>奖励金额</td><td color=#BF7700 size=15 width=20>领取人</td><td color=#BF7700 size=15 width=13>领取奖励</td>" )
	end
	if tag==3 then
		var.index=3
		var.xmlPanel:getWidgetByName("title_image"):loadTexture("title.png", ccui.TextureResType.plistType)
		V8_ContainerXianShiJiangLi.updateList( var.xmlPanel:getWidgetByName("title_richDesc"),"<td color=#BF7700 size=15 width=8>序号</td><td color=#BF7700 size=15 width=8>类型</td><td color=#BF7700 size=15 width=42>怪物</td><td color=#BF7700 size=15 width=16>奖励金额</td><td color=#BF7700 size=15 width=26>领取人</td>" )
	end
	if tag==4 then
		var.index=4
		var.xmlPanel:getWidgetByName("title_image"):loadTexture("title.png", ccui.TextureResType.plistType)
		V8_ContainerXianShiJiangLi.updateList( var.xmlPanel:getWidgetByName("title_richDesc"),"<td color=#BF7700 size=15 width=8>序号</td><td color=#BF7700 size=15 width=40>装备</td><td color=#BF7700 size=15 width=18>奖励金额</td><td color=#BF7700 size=15 width=20>数量</td><td color=#BF7700 size=15 width=13>领取奖励</td>" )
	end
	if tag==5 then
		var.index=5
		var.xmlPanel:getWidgetByName("title_image"):loadTexture("title_auto.png", ccui.TextureResType.plistType)
		V8_ContainerXianShiJiangLi.updateList( var.xmlPanel:getWidgetByName("title_richDesc"),"<td color=#BF7700 size=15 width=8>序号</td><td color=#BF7700 size=15 width=14>是否收费</td><td color=#BF7700 size=15 width=35>装备</td><td color=#BF7700 size=15 width=20>回收金额</td><td color=#BF7700 size=15 width=22>开启</td>" )
	end
	if tag==6 then
		var.index=6
		var.xmlPanel:getWidgetByName("title_image"):loadTexture("title_exchange.png", ccui.TextureResType.plistType)
		V8_ContainerXianShiJiangLi.updateList( var.xmlPanel:getWidgetByName("title_richDesc"),"<td color=#BF7700 size=15 width=8>序号</td><td color=#BF7700 size=15 width=24>项目</td><td color=#BF7700 size=15 width=37>条件</td><td color=#BF7700 size=15 width=17>获得</td><td color=#BF7700 size=15 width=13>兑换</td>" )
	end
	if tag==7 then
		var.index=7
		var.xmlPanel:getWidgetByName("title_image"):loadTexture("title_toushi.png", ccui.TextureResType.plistType)
		V8_ContainerXianShiJiangLi.updateList( var.xmlPanel:getWidgetByName("title_richDesc"),"<td color=#BF7700 size=15 width=8>序号</td><td color=#BF7700 size=15 width=39>掉落物品</td><td color=#BF7700 size=15 width=35>开启条件</td><td color=#BF7700 size=15 width=17>开启</td>" )
	end
	GameSocket:PushLuaTable("gui.V8_ContainerXianShiJiangLi.handlePanelData",GameUtilSenior.encode({actionid = "getMessage",index=var.index,page=1}))
end

function V8_ContainerXianShiJiangLi.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end

function V8_ContainerXianShiJiangLi.showDescList(data)
	local tableview = var.xmlPanel:getWidgetByName("ListView")
	tableview:reloadData(#data.list, function(subItem)
		V8_ContainerXianShiJiangLi.updateList( subItem:getWidgetByName("richDesc"),data.list[subItem.tag] )
	end,nil,false)
	var.page= data.page
	var.totalPage = data.totalPage
	var.xmlPanel:getWidgetByName("tips"):setString(data.page.." / "..data.totalPage)
end

function V8_ContainerXianShiJiangLi.updateList( list,strs )
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

function V8_ContainerXianShiJiangLi.handlePanelData(event)
	if event.type == "V8_ContainerXianShiJiangLi" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			V8_ContainerXianShiJiangLi.showDescList(data)
		end
	end
end


function V8_ContainerXianShiJiangLi.onPanelOpen(extend)
	
end

function V8_ContainerXianShiJiangLi.onPanelClose()

end

return V8_ContainerXianShiJiangLi