local V4_ContainerWuJiaKongZhi = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerWuJiaKongZhi.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerWuJiaKongZhi.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerWuJiaKongZhi.handlePanelData)

		
		V4_ContainerWuJiaKongZhi.showTitleAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerWuJiaKongZhi.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerWuJiaKongZhi.onPanelOpen(extend)
end

function V4_ContainerWuJiaKongZhi.onPanelClose()

end

return V4_ContainerWuJiaKongZhi