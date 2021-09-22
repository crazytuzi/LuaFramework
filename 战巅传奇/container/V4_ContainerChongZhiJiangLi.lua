local V4_ContainerChongZhiJiangLi = {}
local var = {}


local currentAwardIndex = 1
local currentDaLuInfo = {}

function V4_ContainerChongZhiJiangLi.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerChongZhiJiangLi.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerChongZhiJiangLi.handlePanelData)
				
--		var.xmlPanel:getWidgetByName("activity_name"):setText(extend.mParam.name)
--		var.xmlPanel:getWidgetByName("activity_content"):setRichLabel(extend.mParam.desc)
		var.xmlPanel:getWidgetByName("btn_100"):addClickEventListener(function ( sender )
			currentAwardIndex = 1
			V4_ContainerChongZhiJiangLi.showAwards(1)
		end)
		var.xmlPanel:getWidgetByName("btn_500"):addClickEventListener(function ( sender )
			currentAwardIndex = 2
			V4_ContainerChongZhiJiangLi.showAwards(2)
		end)
		
		var.xmlPanel:getWidgetByName("btn_award"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_ChongZhiLiBao.handlePanelData",GameUtilSenior.encode({actionid = "award",index=currentAwardIndex}))
		end)
		
		V4_ContainerChongZhiJiangLi.showTitleAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerChongZhiJiangLi.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end

function V4_ContainerChongZhiJiangLi.showAwards(index)
	for i=1,#currentDaLuInfo[index].data,1 do
		GUIItem.getItem({parent = var.xmlPanel:getWidgetByName("equip_"..i),typeId = currentDaLuInfo[index].data[i].typeid,num = currentDaLuInfo[index].data[i].num})
	end
end


function V4_ContainerChongZhiJiangLi.handlePanelData(event)
	if event.type == "V4_ContainerChongZhiJiangLi" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			currentDaLuInfo = data.mapList
			V4_ContainerChongZhiJiangLi.showAwards(1)
		end
	end
end


function V4_ContainerChongZhiJiangLi.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.v4_ChongZhiLiBao.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerChongZhiJiangLi.onPanelClose()

end

return V4_ContainerChongZhiJiangLi