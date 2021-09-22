local V8_ContainerShiJieBoss = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V8_ContainerShiJieBoss.onPanelOpen(event)

end

function V8_ContainerShiJieBoss.initView(extend)
	var = {
		items={},
		xmlPanel,
		--mapList,
	}
	--var.mapList = extend.result.mapList
	var.xmlPanel = GUIAnalysis.load("ui/layout/V8_ContainerShiJieBoss.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V8_ContainerShiJieBoss.handlePanelData)

		V8_ContainerShiJieBoss.showTitleAnimation()
		
		for i=1,6,1 do
			var.xmlPanel:getWidgetByName("boss_bg_"..i):addClickEventListener(function ( sender )
				for j=1,6,1 do
					var.xmlPanel:getWidgetByName("boss_bg_select_"..j):setVisible(false)
				end
				var.xmlPanel:getWidgetByName("boss_bg_select_"..i):setVisible(true)
			end)
		end
		
		for i=1,6,1 do
			var.xmlPanel:getWidgetByName("boss_bg_btn_"..i):addClickEventListener(function ( sender )
				for j=1,6,1 do
					var.xmlPanel:getWidgetByName("boss_bg_select_"..j):setVisible(false)
				end
				var.xmlPanel:getWidgetByName("boss_bg_select_"..i):setVisible(true)
				local img = var.xmlPanel:getWidgetByName("boss_bg_btn_"..i)
				img.user_data="event:talk_event1"..i
				GameUtilSenior.touchlink(img,"panel_npctalk",nil)
			end)
		end
		
		--V8_ContainerShiJieBoss.showList()
					
		return var.xmlPanel
	end
end

function V8_ContainerShiJieBoss.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V8_ContainerShiJieBoss.updateList( list,strs )
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

function V8_ContainerShiJieBoss.handlePanelData(event)
	if event.type == "v4_PanelMoDaoDuanZao" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			V8_ContainerShiJieBoss.showMoDaoAnimation(data.data)
		end
	end
end


function V8_ContainerShiJieBoss.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.v4_MoDaoDuanZao.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V8_ContainerShiJieBoss.onPanelClose()

end

return V8_ContainerShiJieBoss