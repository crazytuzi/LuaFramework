local V4_ContainerGaoJiHuiShou = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerGaoJiHuiShou.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerGaoJiHuiShou.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerGaoJiHuiShou.handlePanelData)

		var.xmlPanel:getWidgetByName("exchange_1"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_GaoJiHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "exchange_1"}))
		end)

		
		var.xmlPanel:getWidgetByName("exchange_2"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_GaoJiHuiShou.handlePanelData",GameUtilSenior.encode({actionid = "exchange_2"}))
		end)
		
		V4_ContainerGaoJiHuiShou.showTitleAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerGaoJiHuiShou.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerGaoJiHuiShou.handlePanelData(event)
	if event.type == "V4_ContainerGongChengJiangLi" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
		end
	end
end


function V4_ContainerGaoJiHuiShou.onPanelOpen(extend)
	---GameSocket:PushLuaTable("gui.v4_GongChengJiangLi.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerGaoJiHuiShou.onPanelClose()

end

return V4_ContainerGaoJiHuiShou