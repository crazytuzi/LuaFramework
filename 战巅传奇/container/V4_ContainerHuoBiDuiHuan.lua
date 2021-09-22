local V4_ContainerHuoBiDuiHuan = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerHuoBiDuiHuan.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerHuoBiDuiHuan.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerHuoBiDuiHuan.handlePanelData)

		
		var.xmlPanel:getWidgetByName("V4_ContainerHuoBiDuiHuan_1"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_huobiduihuan.handlePanelData",GameUtilSenior.encode({actionid = "duihuan",num=100}))
		end)

		var.xmlPanel:getWidgetByName("V4_ContainerHuoBiDuiHuan_2"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_huobiduihuan.handlePanelData",GameUtilSenior.encode({actionid = "duihuan",num=1000}))
		end)
		
		var.xmlPanel:getWidgetByName("V4_ContainerHuoBiDuiHuan_3"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_huobiduihuan.handlePanelData",GameUtilSenior.encode({actionid = "duihuan",num=10000}))
		end)
		
		var.xmlPanel:getWidgetByName("V4_ContainerHuoBiDuiHuan_10"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_huobiduihuan.handlePanelData",GameUtilSenior.encode({actionid = "tiqu",num=50}))
		end)
		var.xmlPanel:getWidgetByName("V4_ContainerHuoBiDuiHuan_11"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_huobiduihuan.handlePanelData",GameUtilSenior.encode({actionid = "tiqu",num=100}))
		end)
		var.xmlPanel:getWidgetByName("V4_ContainerHuoBiDuiHuan_12"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_huobiduihuan.handlePanelData",GameUtilSenior.encode({actionid = "tiqu",num=500}))
		end)
		var.xmlPanel:getWidgetByName("V4_ContainerHuoBiDuiHuan_13"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_huobiduihuan.handlePanelData",GameUtilSenior.encode({actionid = "tiqu",num=1000}))
		end)
		var.xmlPanel:getWidgetByName("V4_ContainerHuoBiDuiHuan_14"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_huobiduihuan.handlePanelData",GameUtilSenior.encode({actionid = "tiqu",num=5000}))
		end)
		var.xmlPanel:getWidgetByName("V4_ContainerHuoBiDuiHuan_15"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_huobiduihuan.handlePanelData",GameUtilSenior.encode({actionid = "tiqu",num=10000}))
		end)
		
		V4_ContainerHuoBiDuiHuan.showTitleAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerHuoBiDuiHuan.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerHuoBiDuiHuan.handlePanelData(event)
	if event.type == "V4_ContainerHuoBiDuiHuan" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			var.xmlPanel:getWidgetByName("my_rank_desc"):setRichLabel("<font color='#ee1818'><font size='12'>您当前玄辰币数量为：[  </font><font size='12' color='#FFFFFF'>"..data.bindGameMoney.."</font><font size='12'><font color='#ee1818'><font size='12'> ] 颗</font></font>")
		end
	end
end


function V4_ContainerHuoBiDuiHuan.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.v4_huobiduihuan.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerHuoBiDuiHuan.onPanelClose()

end

return V4_ContainerHuoBiDuiHuan