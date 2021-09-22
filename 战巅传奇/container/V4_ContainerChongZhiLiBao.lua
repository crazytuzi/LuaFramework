local V4_ContainerChongZhiLiBao = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerChongZhiLiBao.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerChongZhiLiBao.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerChongZhiLiBao.handlePanelData)
				
--		var.xmlPanel:getWidgetByName("activity_name"):setText(extend.mParam.name)
--		var.xmlPanel:getWidgetByName("activity_content"):setRichLabel(extend.mParam.desc)
		var.xmlPanel:getWidgetByName("duanzao_btn"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("gui.ContainerActivityList.enterMapFromClient",GameUtilSenior.encode({name = extend.mParam.name}))
		end)
		
		V4_ContainerChongZhiLiBao.showTitleAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerChongZhiLiBao.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerChongZhiLiBao.handlePanelData(event)
	if event.type == "V4_ContainerChongZhiLiBao" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
		end
	end
end


function V4_ContainerChongZhiLiBao.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.v4_GongChengJiangLi.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerChongZhiLiBao.onPanelClose()

end

return V4_ContainerChongZhiLiBao