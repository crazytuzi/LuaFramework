local V4_ContainerHangHuiZhengDuoZhan = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerHangHuiZhengDuoZhan.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerHangHuiZhengDuoZhan.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerHangHuiZhengDuoZhan.handlePanelData)

		
		V4_ContainerHangHuiZhengDuoZhan.showTitleAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerHangHuiZhengDuoZhan.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerHangHuiZhengDuoZhan.onPanelOpen(extend)
end

function V4_ContainerHangHuiZhengDuoZhan.onPanelClose()

end

return V4_ContainerHangHuiZhengDuoZhan