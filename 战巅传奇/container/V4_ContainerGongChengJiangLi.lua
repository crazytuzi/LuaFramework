local V4_ContainerGongChengJiangLi = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerGongChengJiangLi.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerGongChengJiangLi.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerGongChengJiangLi.handlePanelData)

		
		var.xmlPanel:getWidgetByName("panel_gcjl_2"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_GongChengJiangLi.handlePanelData",GameUtilSenior.encode({actionid = "award"}))
		end)
		
		V4_ContainerGongChengJiangLi.showTitleAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerGongChengJiangLi.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerGongChengJiangLi.handlePanelData(event)
	if event.type == "V4_ContainerGongChengJiangLi" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
		end
	end
end


function V4_ContainerGongChengJiangLi.onPanelOpen(extend)
	--GameSocket:PushLuaTable("npc.v4_GongChengJiangLi.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerGongChengJiangLi.onPanelClose()

end

return V4_ContainerGongChengJiangLi