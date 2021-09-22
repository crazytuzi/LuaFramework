local V8_ContainerDaLu = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V8_ContainerDaLu.onPanelOpen(event)

end

function V8_ContainerDaLu.initView(extend)
	var = {
		items={},
		xmlPanel,
		mapInfo,
	}
	var.mapInfo = extend.mParam
	var.xmlPanel = GUIAnalysis.load("ui/layout/V8_ContainerDaLu.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V8_ContainerDaLu.handlePanelData)

		if var.mapInfo.mapIndex>0 then
			var.xmlPanel:getWidgetByName("bg"):loadTexture("V8_ContainerDaLu_"..var.mapInfo.mapIndex..".png", ccui.TextureResType.plistType)
		end
		V8_ContainerDaLu.updateDescList( var.xmlPanel:getWidgetByName("requireDesc"),var.mapInfo.req )
		
		V8_ContainerDaLu.showTitleAnimation()
		
		var.xmlPanel:getWidgetByName("duanzao_btn"):setPositionX(var.mapInfo.btnx)
		var.xmlPanel:getWidgetByName("duanzao_btn"):setPositionY(var.mapInfo.btny)

		var.xmlPanel:getWidgetByName("duanzao_btn"):addClickEventListener(function ( sender )
			var.xmlPanel:getWidgetByName("duanzao_btn").user_data="event:talk_event1"
			GameUtilSenior.touchlink(var.xmlPanel:getWidgetByName("duanzao_btn"),"panel_npctalk",nil)
		end)
		
		--V8_ContainerDaLu.showList()
					
		return var.xmlPanel
	end
end

function V8_ContainerDaLu.updateDescList( list,strs )
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

function V8_ContainerDaLu.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("bg")
	local startNum = 1
	local function startShowTitleBg()
	
		title_animal:loadTexture("ui_"..startNum..".png", ccui.TextureResType.plistType)
		
		startNum= startNum+1
		if startNum ==13 then
			startNum =1
		end
	end
	title_animal:stopAllActions()
	title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowTitleBg)}),tonumber(18)))
		
end

function V8_ContainerDaLu.showList()
	local tableview = var.xmlPanel:getWidgetByName("ListView")
	tableview:reloadData(#var.mapList.name, function(subItem)
		subItem:getWidgetByName("mapName"):setTitleText(var.mapList.name[subItem.tag])
		if subItem.tag==1 then
			subItem:getWidgetByName("mapName"):loadTextureNormal("common_big_zbhs_tab_btn_1.png",ccui.TextureResType.plistType)
		end
		table.insert(var.items,subItem)
		subItem:getWidgetByName("mapName"):setTouchEnabled(true):addClickEventListener(function( sender )
			for i,v in ipairs(var.items) do
				v:getWidgetByName("mapName"):loadTextureNormal("common_big_zbhs_tab_btn_2.png",ccui.TextureResType.plistType)
			end
			subItem:getWidgetByName("mapName"):loadTextureNormal("common_big_zbhs_tab_btn_1.png",ccui.TextureResType.plistType)
			V8_ContainerDaLu.showMapInfo(subItem.tag)
			local moveTo = subItem.tag - 2
			if subItem.tag<1 then
				moveTo = 1
			end
			tableview:autoMoveToIndex(moveTo)
			--if subItem.tag>5 then
			--	local moveTo = subItem.tag - 1
			--	tableview:autoMoveToIndex(moveTo)
			--else
			--	tableview:autoMoveToIndex(1)
			--end
		end)
	end,nil,false)
	V8_ContainerDaLu.showMapInfo(1)
end

function V8_ContainerDaLu.showMapInfo(index)
	V8_ContainerDaLu.updateList( var.xmlPanel:getWidgetByName("descList"),var.mapList.str[index] )
end

function V8_ContainerDaLu.updateList( list,strs )
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

function V8_ContainerDaLu.handlePanelData(event)
	if event.type == "v4_PanelMoDaoDuanZao" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			V8_ContainerDaLu.showMoDaoAnimation(data.data)
		end
	end
end


function V8_ContainerDaLu.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.v4_MoDaoDuanZao.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V8_ContainerDaLu.onPanelClose()

end

return V8_ContainerDaLu