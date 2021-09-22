local V4_ContainerSanRenDiTu = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerSanRenDiTu.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerSanRenDiTu.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerSanRenDiTu.handlePanelData)

		
		var.xmlPanel:getWidgetByName("ditu1"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_sanrenditu.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",mapno=1}))
			
		end)
		var.xmlPanel:getWidgetByName("ditu2"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_sanrenditu.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",mapno=2}))
		end)
		var.xmlPanel:getWidgetByName("ditu3"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_sanrenditu.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",mapno=3}))
		end)
		var.xmlPanel:getWidgetByName("ditu4"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_sanrenditu.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",mapno=4}))
		end)
		var.xmlPanel:getWidgetByName("ditu5"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_sanrenditu.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",mapno=5}))
		end)

		V4_ContainerSanRenDiTu.showTitleAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerSanRenDiTu.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerSanRenDiTu.handlePanelData(event)
	if event.type == "V4_ContainerSanRenDiTu" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
		end
	end
end


function V4_ContainerSanRenDiTu.onPanelOpen(extend)
	GameSocket:PushLuaTable("gui.V4_ContainerSanRenDiTu.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerSanRenDiTu.onPanelClose()

end

return V4_ContainerSanRenDiTu