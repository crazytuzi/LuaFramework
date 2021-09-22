local V4_ContainerDengJiXiTong = {}
local var = {}

local mapList = {}

local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerDengJiXiTong.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerDengJiXiTong.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerDengJiXiTong.handlePanelData)
		
		V4_ContainerDengJiXiTong.showTitleAnimation()
		V4_ContainerDengJiXiTong.showRightAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerDengJiXiTong.showUI()
	
	var.xmlPanel:getWidgetByName("dalu1"):addClickEventListener(function ( sender )
		V4_ContainerDengJiXiTong.showMapList(1)
	end)
	var.xmlPanel:getWidgetByName("dalu2"):addClickEventListener(function ( sender )
		V4_ContainerDengJiXiTong.showMapList(2)
	end)
	var.xmlPanel:getWidgetByName("dalu3"):addClickEventListener(function ( sender )
		V4_ContainerDengJiXiTong.showMapList(3)
	end)
	var.xmlPanel:getWidgetByName("dalu4"):addClickEventListener(function ( sender )
		V4_ContainerDengJiXiTong.showMapList(4)
	end)
	
	var.xmlPanel:getWidgetByName("buy1"):addClickEventListener(function ( sender )
		GameSocket:PushLuaTable("npc.v4_DengJiXiTong.handlePanelData",GameUtilSenior.encode({actionid = "buy1"}))
	end)
	
	var.xmlPanel:getWidgetByName("buy2"):addClickEventListener(function ( sender )
		GameSocket:PushLuaTable("npc.v4_DengJiXiTong.handlePanelData",GameUtilSenior.encode({actionid = "buy2"}))
	end)
	
	var.xmlPanel:getWidgetByName("upgrade"):addClickEventListener(function ( sender )
		GameSocket:PushLuaTable("npc.v4_DengJiXiTong.handlePanelData",GameUtilSenior.encode({actionid = "upgrade"}))
	end)
	
	
	local level = GameCharacter._mainAvatar:NetAttr(GameConst.net_level)
	local zslevel = GameCharacter._mainAvatar:NetAttr(GameConst.net_zslevel)
	
	for i=1,4,1 do
		if mapList[i].level <= level and mapList[i].zslevel <= zslevel then
			var.xmlPanel:getWidgetByName("dalu"..i):loadTextureNormal("panel_djsj_"..(21+i)..".png",ccui.TextureResType.plistType)
			var.xmlPanel:getWidgetByName("dalu"..i):loadTexturePressed("panel_djsj_"..(29+i)..".png",ccui.TextureResType.plistType)
		end
	end
end

function V4_ContainerDengJiXiTong.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerDengJiXiTong.showRightAnimation()
		
	local right_tips = var.xmlPanel:getWidgetByName("right_tips")
	local startNum = 1
	local function startShowRightBg()
	
		local filepath = string.format("panel_djsj_%d.png",startNum)
		right_tips:loadTexture(filepath,ccui.TextureResType.plistType)
		
		startNum= startNum+1
		if startNum ==21 then
			startNum =1
		end
	end
	right_tips:stopAllActions()
	right_tips:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowRightBg)}),tonumber(20)))
		
end



function V4_ContainerDengJiXiTong.showMapList(mapindex)
	local level = GameCharacter._mainAvatar:NetAttr(GameConst.net_level)
	local zslevel = GameCharacter._mainAvatar:NetAttr(GameConst.net_zslevel)
	if mapList[mapindex].open~=1 then
		GameSocket:alertLocalMsg("该大陆暂未开放!", "alert")
		return
	end
	if mapList[mapindex].level > level or mapList[mapindex].zslevel > zslevel then
		local str = "需要"
		if mapList[mapindex].level>0 then
			str = str.."等级"..mapList[mapindex].level.."级"
		end
		if mapList[mapindex].zslevel>0 then
			str = str.."转升"..mapList[mapindex].zslevel.."级"
		end
		GameSocket:alertLocalMsg(str.."才可进入本大陆！", "alert")
		return
	end
	
	var.xmlPanel:getWidgetByName("container"):setContentSize(cc.size(393,332))
	local bg = var.xmlPanel:getWidgetByName("bg")
	var.xmlPanel:getWidgetByName("panel_close"):setPosition(360,290)
	var.xmlPanel:getWidgetByName("title_animal"):setPosition(200,230)
	var.xmlPanel:getWidgetByName("left_panel"):setVisible(false)
	var.xmlPanel:getWidgetByName("right_tips"):setVisible(false)
	var.xmlPanel:getWidgetByName("upgrade"):setVisible(true)
	if mapindex==1 then
		var.xmlPanel:getWidgetByName("buy1"):setVisible(true)
		var.xmlPanel:getWidgetByName("buy2"):setVisible(true)
		bg:loadTexture("panel_djxt_2.png",ccui.TextureResType.plistType):setContentSize(cc.size(393,332))
	else
		bg:loadTexture("panel_djxt_3.png",ccui.TextureResType.plistType):setContentSize(cc.size(393,332))
		var.xmlPanel:getWidgetByName("upgrade"):setPosition(150,50)
	end
	currentDaLuInfo = mapList[mapindex]
	currentDaLuInfoIndex = mapindex
	

end

function V4_ContainerDengJiXiTong.handlePanelData(event)
	if event.type == "v4_PanelDengJiXiTong" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			mapList = data.mapList
			V4_ContainerDengJiXiTong.showUI()
		end
	end
end


function V4_ContainerDengJiXiTong.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.v4_DengJiXiTong.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerDengJiXiTong.onPanelClose()

end

return V4_ContainerDengJiXiTong