local V4_ContainerShenMiRen = {}
local var = {}

function V4_ContainerShenMiRen.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerShenMiRen.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerShenMiRen.handlePanelData)

		
		var.xmlPanel:getWidgetByName("V4_PanelShenMiRen_13"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_ShenMiRen.handlePanelData",GameUtilSenior.encode({actionid = "enterNextMap",mapno=0}))
		end)
		
		var.xmlPanel:getWidgetByName("V4_PanelShenMiRen_17"):addClickEventListener(function ( sender )
			var.xmlPanel:getWidgetByName("V4_PanelShenMiRen_1"):setVisible(true)
			var.xmlPanel:getWidgetByName("V4_PanelShenMiRen_2"):setVisible(true)
			var.xmlPanel:getWidgetByName("V4_PanelShenMiRen_3"):setVisible(true)
			var.xmlPanel:getWidgetByName("V4_PanelShenMiRen_4"):setVisible(true)
			var.xmlPanel:getWidgetByName("V4_PanelShenMiRen_5"):setVisible(true)
			var.xmlPanel:getWidgetByName("V4_PanelShenMiRen_6"):setVisible(true)
		end)
		
		var.xmlPanel:getWidgetByName("V4_PanelShenMiRen_1"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_ShenMiRen.handlePanelData",GameUtilSenior.encode({actionid = "enterNextMap",mapno=1}))
		end)
		var.xmlPanel:getWidgetByName("V4_PanelShenMiRen_2"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_ShenMiRen.handlePanelData",GameUtilSenior.encode({actionid = "enterNextMap",mapno=2}))
		end)
		var.xmlPanel:getWidgetByName("V4_PanelShenMiRen_3"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_ShenMiRen.handlePanelData",GameUtilSenior.encode({actionid = "enterNextMap",mapno=3}))
		end)
		var.xmlPanel:getWidgetByName("V4_PanelShenMiRen_4"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_ShenMiRen.handlePanelData",GameUtilSenior.encode({actionid = "enterNextMap",mapno=4}))
		end)
		var.xmlPanel:getWidgetByName("V4_PanelShenMiRen_5"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_ShenMiRen.handlePanelData",GameUtilSenior.encode({actionid = "enterNextMap",mapno=5}))
		end)
		var.xmlPanel:getWidgetByName("V4_PanelShenMiRen_6"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_ShenMiRen.handlePanelData",GameUtilSenior.encode({actionid = "enterNextMap",mapno=6}))
		end)
		
		
		--var.xmlPanel:getWidgetByName("my_rank_desc"):setRichLabel("<font color='#ee1818'><font size='12'>您当前玄辰币数量为：[  </font><font size='12' color='#FFFFFF'>188</font><font size='12'><font color='#ee1818'><font size='12'> ]颗</font></font>")

		V4_ContainerShenMiRen.showTitleAnimation()
		
		--V4_ContainerShenMiRen.showBorderAnimation(1,90)
		--V4_ContainerShenMiRen.showBorderAnimation(2,80)
		--V4_ContainerShenMiRen.showBorderAnimation(3,80)
		--V4_ContainerShenMiRen.showBorderAnimation(4,70)
		--V4_ContainerShenMiRen.showBorderAnimation(5,70)
		---V4_ContainerShenMiRen.showBorderAnimation(6,60)
		--V4_ContainerShenMiRen.showBorderAnimation(7,60)
		--V4_ContainerShenMiRen.showBorderAnimation(8,60)
		--V4_ContainerShenMiRen.showBorderAnimation(9,50)
		--V4_ContainerShenMiRen.showBorderAnimation(10,50)
		
		var.xmlPanel:getWidgetByName("my_rank_desc"):setRichLabel("<font color='#CC3333'><font size='12'>当前塔层数：</font><font size='12' color='#FF9933'>0/90层</font>")
					
		return var.xmlPanel
	end
end



function V4_ContainerShenMiRen.showBorderAnimation(index,icon)
		
	local title_animal = var.xmlPanel:getWidgetByName("V4_PanelShenMiRen_icon_"..index)
	local startNum = 1
	local function startShowTitleBg()
	
		local filepath = string.format("V4_PanelShenMiRen_%d.png",icon+startNum-1)
		title_animal:loadTextureNormal(filepath,ccui.TextureResType.plistType)
		
		startNum= startNum+1
		if startNum ==11 then
			startNum =1
		end
	end
	title_animal:stopAllActions()
	title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowTitleBg)}),tonumber(10)))
		
end

function V4_ContainerShenMiRen.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerShenMiRen.handlePanelData(event)
	if event.type == "V4_ContainerShenMiRen" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			var.xmlPanel:getWidgetByName("my_rank_desc"):setRichLabel("<font color='#CC3333'><font size='12'>当前塔层数：</font><font size='12' color='#F9F055'>"..data.floor.."/99层</font>")
		end
	end
end


function V4_ContainerShenMiRen.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.v4_ShenMiRen.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerShenMiRen.onPanelClose()

end

return V4_ContainerShenMiRen