local V4_ContainerShouChongDiTu = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerShouChongDiTu.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerShouChongDiTu.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerShouChongDiTu.handlePanelData)

		
		var.xmlPanel:getWidgetByName("ditu1"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_shouchongditu.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",mapno=1}))
			
		end)

		V4_ContainerShouChongDiTu.showTitleAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerShouChongDiTu.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerShouChongDiTu.handlePanelData(event)
	if event.type == "V4_ContainerShouChongDiTu" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
		end
	end
end


function V4_ContainerShouChongDiTu.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.v4_shouchongditu.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerShouChongDiTu.onPanelClose()

end

return V4_ContainerShouChongDiTu