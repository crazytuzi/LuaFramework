local V4_ContainerHuoDong = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerHuoDong.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerHuoDong.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerHuoDong.handlePanelData)
--
--		
		var.xmlPanel:getWidgetByName("btn_1"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_MeiRiHuoDong.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",mapno=1}))
		end)
		var.xmlPanel:getWidgetByName("btn_2"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_MeiRiHuoDong.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",mapno=2}))
		end)
		var.xmlPanel:getWidgetByName("btn_3"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_MeiRiHuoDong.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",mapno=3}))
		end)
		var.xmlPanel:getWidgetByName("btn_4"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_MeiRiHuoDong.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",mapno=4}))
		end)
		var.xmlPanel:getWidgetByName("btn_5"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_MeiRiHuoDong.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",mapno=5}))
		end)
		var.xmlPanel:getWidgetByName("btn_6"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_MeiRiHuoDong.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",mapno=6}))
		end)
		
--		--var.xmlPanel:getWidgetByName("my_rank_desc"):setRichLabel("<font color='#ee1818'><font size='12'>您当前玄辰币数量为：[  </font><font size='12' color='#FFFFFF'>188</font><font size='12'><font color='#ee1818'><font size='12'> ]颗</font></font>")
--
		V4_ContainerHuoDong.showTitleAnimation()
--		
--		V4_ContainerHuoDong.showBorderAnimation(1,90)
--		V4_ContainerHuoDong.showBorderAnimation(2,80)
--		V4_ContainerHuoDong.showBorderAnimation(3,80)
--		V4_ContainerHuoDong.showBorderAnimation(4,70)
--		V4_ContainerHuoDong.showBorderAnimation(5,70)
--		V4_ContainerHuoDong.showBorderAnimation(6,60)
--		V4_ContainerHuoDong.showBorderAnimation(7,60)
--		V4_ContainerHuoDong.showBorderAnimation(8,60)
--		V4_ContainerHuoDong.showBorderAnimation(9,50)
--		V4_ContainerHuoDong.showBorderAnimation(10,50)
		
					
		return var.xmlPanel
	end
end



function V4_ContainerHuoDong.showBorderAnimation(index,icon)
		
	local title_animal = var.xmlPanel:getWidgetByName("V4_ContainerHuoDong_icon_"..index)
	local startNum = 1
	local function startShowTitleBg()
	
		local filepath = string.format("V4_ContainerHuoDong_%d.png",icon+startNum-1)
		title_animal:loadTextureNormal(filepath,ccui.TextureResType.plistType)
		
		startNum= startNum+1
		if startNum ==11 then
			startNum =1
		end
	end
	title_animal:stopAllActions()
	title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowTitleBg)}),tonumber(10)))
		
end

function V4_ContainerHuoDong.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerHuoDong.handlePanelData(event)
	if event.type == "V4_ContainerHuoDong" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="rank" then
			var.xmlPanel:getWidgetByName("my_rank_desc"):setRichLabel("<font color='#CC3333'><font size='12'>当前塔层数：</font><font size='12' color='#F9F055'>"..data.floor.."/99层</font>")
			local size = 3
			if #data.Data < 3 then
				size = #data.Data
			end
			if size<1 then
				return
			end
			local list_container = var.xmlPanel:getWidgetByName("list_container"):setVisible(true)
			list_container:reloadData(size,function( subItem )
			
				local datalocal = data.Data[subItem.tag]
				subItem:getWidgetByName("role_name"):setText(datalocal.name)
				subItem:getWidgetByName("role_floor"):setText(datalocal.floor.."层")

			end)
			
			local size2 = 6
			if #data.Data < 9 then
				size2 = #data.Data-3
			end
			if size2<1 then
				return
			end
			local list_container_2 = var.xmlPanel:getWidgetByName("list_container_2"):setVisible(true)
			list_container_2:reloadData(size2,function( subItem )
			
				local datalocal = data.Data[subItem.tag+3]
				subItem:getWidgetByName("role_name"):setText(datalocal.name)
				subItem:getWidgetByName("role_floor"):setText(datalocal.floor.."层")

			end)
		end
	end
end


function V4_ContainerHuoDong.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.v4_fengyaota.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerHuoDong.onPanelClose()

end

return V4_ContainerHuoDong