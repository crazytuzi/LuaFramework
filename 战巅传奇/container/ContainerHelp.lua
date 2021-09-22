local ContainerHelp = {}
local var = {}


function ContainerHelp.initView(extend)
	var = {
		xmlPanel,
		
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerHelp.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerHelp.handlePanelData)

		
		--var.xmlPanel:getWidgetByName("ditu1"):addClickEventListener(function ( sender )
		--	GameSocket:PushLuaTable("npc.v4_shouchongditu.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",mapno=1}))
		--	
		--end)
		
		ContainerHelp.showTitleAnimation()
					
		return var.xmlPanel
	end
end

function ContainerHelp.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end

function ContainerHelp.updateList( list,strs )
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

function ContainerHelp.handlePanelData(event)
	if event.type == "ContainerHelp" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			for i=1,#data.desc,1 do
				ContainerHelp.updateList( var.xmlPanel:getWidgetByName("descList"),data.desc)
			end
		end
	end
end


function ContainerHelp.onPanelOpen(extend)
	GameSocket:PushLuaTable("gui.ContainerHelp.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function ContainerHelp.onPanelClose()

end

return ContainerHelp