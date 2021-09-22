local V4_ContainerXuanHunJinJie_XH = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerXuanHunJinJie_XH.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerXuanHunJinJie_XH.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerXuanHunJinJie_XH.handlePanelData)
		
		var.xmlPanel:getWidgetByName("update_1"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_XuanHunJinJie.handlePanelData",GameUtilSenior.encode({actionid = "exchange",index=1}))
		end)
		var.xmlPanel:getWidgetByName("update_2"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_XuanHunJinJie.handlePanelData",GameUtilSenior.encode({actionid = "exchange",index=2}))
		end)
		var.xmlPanel:getWidgetByName("update_3"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_XuanHunJinJie.handlePanelData",GameUtilSenior.encode({actionid = "exchange",index=3}))
		end)
		var.xmlPanel:getWidgetByName("update_4"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_XuanHunJinJie.handlePanelData",GameUtilSenior.encode({actionid = "exchange",index=4}))
		end)
		var.xmlPanel:getWidgetByName("update_5"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_XuanHunJinJie.handlePanelData",GameUtilSenior.encode({actionid = "exchange",index=5}))
		end)
		var.xmlPanel:getWidgetByName("update_6"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_XuanHunJinJie.handlePanelData",GameUtilSenior.encode({actionid = "exchange",index=6}))
		end)
	
		var.xmlPanel:getWidgetByName("my_rank_desc"):setRichLabel("<font color='#FFA877' size='12'>进阶神器玄魂:需要<font size='12' color='#F9F055'>圣器</font>一个+<font size='12' color='#F9F055'>100000玄辰币</font>+<font size='12' color='#F9F055'>100RMB</font>点进阶一个.各大地图都可爆出！</font>")

		V4_ContainerXuanHunJinJie_XH.showTitleAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerXuanHunJinJie_XH.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end



function V4_ContainerXuanHunJinJie_XH.handlePanelData(event)
	if event.type == "v4_ContainerXuanHunJinJie" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			
		end
	end
end


function V4_ContainerXuanHunJinJie_XH.onPanelOpen(extend)
end

function V4_ContainerXuanHunJinJie_XH.onPanelClose()

end

return V4_ContainerXuanHunJinJie_XH