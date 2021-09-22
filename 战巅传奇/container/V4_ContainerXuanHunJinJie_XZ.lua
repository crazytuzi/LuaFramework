local V4_ContainerXuanHunJinJie_XZ = {}
local var = {}

local mapList = {}

local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerXuanHunJinJie_XZ.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerXuanHunJinJie_XZ.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerXuanHunJinJie_XZ.handlePanelData)
			
		local str = ""
		str = str.."<font size='12' color='#EDE606'>点击图标可进行合成</font><br /><br />"
		str = str.."<font size='12' color='#4FFA18'>合成说明：</font><br />"
		str = str.."<font size='12' color='#FF33D7'>相对应的起源星座*1</font><br />"
		str = str.."<font size='12' color='#FF33D7'>相对应的洪荒星座*1</font><br />"
		str = str.."<font size='12' color='#18EDFA'>元宝*5000000</font><br />"
		str = str.."<font size='12' color='#18EDFA'>玄辰币*50000+RMB60点</font><br />"
		var.xmlPanel:getWidgetByName("desc"):setRichLabel(str)
		
		var.xmlPanel:getWidgetByName("update_1"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_XuanHunJinJie.handlePanelData",GameUtilSenior.encode({actionid = "exchange_xz",index=1}))
		end)
		var.xmlPanel:getWidgetByName("update_2"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_XuanHunJinJie.handlePanelData",GameUtilSenior.encode({actionid = "exchange_xz",index=2}))
		end)
		var.xmlPanel:getWidgetByName("update_3"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_XuanHunJinJie.handlePanelData",GameUtilSenior.encode({actionid = "exchange_xz",index=3}))
		end)
		var.xmlPanel:getWidgetByName("update_4"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_XuanHunJinJie.handlePanelData",GameUtilSenior.encode({actionid = "exchange_xz",index=4}))
		end)
		var.xmlPanel:getWidgetByName("update_5"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_XuanHunJinJie.handlePanelData",GameUtilSenior.encode({actionid = "exchange_xz",index=5}))
		end)
		var.xmlPanel:getWidgetByName("update_6"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_XuanHunJinJie.handlePanelData",GameUtilSenior.encode({actionid = "exchange_xz",index=6}))
		end)
		var.xmlPanel:getWidgetByName("update_7"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_XuanHunJinJie.handlePanelData",GameUtilSenior.encode({actionid = "exchange_xz",index=7}))
		end)
		var.xmlPanel:getWidgetByName("update_8"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_XuanHunJinJie.handlePanelData",GameUtilSenior.encode({actionid = "exchange_xz",index=8}))
		end)
		var.xmlPanel:getWidgetByName("update_9"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_XuanHunJinJie.handlePanelData",GameUtilSenior.encode({actionid = "exchange_xz",index=9}))
		end)
		var.xmlPanel:getWidgetByName("update_10"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_XuanHunJinJie.handlePanelData",GameUtilSenior.encode({actionid = "exchange_xz",index=10}))
		end)
		var.xmlPanel:getWidgetByName("update_11"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_XuanHunJinJie.handlePanelData",GameUtilSenior.encode({actionid = "exchange_xz",index=11}))
		end)
		var.xmlPanel:getWidgetByName("update_12"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_XuanHunJinJie.handlePanelData",GameUtilSenior.encode({actionid = "exchange_xz",index=12}))
		end)

		V4_ContainerXuanHunJinJie_XZ.showTitleAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerXuanHunJinJie_XZ.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end



function V4_ContainerXuanHunJinJie_XZ.handlePanelData(event)
	if event.type == "V4_ContainerXuanHunJinJie_XZ" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			mapList = data.mapList
			V4_ContainerXuanHunJinJie_XZ.showUI()
		end
	end
end


function V4_ContainerXuanHunJinJie_XZ.onPanelOpen(extend)
end

function V4_ContainerXuanHunJinJie_XZ.onPanelClose()

end

return V4_ContainerXuanHunJinJie_XZ