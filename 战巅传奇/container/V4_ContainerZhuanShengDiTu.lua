local V4_ContainerZhuanShengDiTu = {}
local var = {}

local mapList = {}

local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerZhuanShengDiTu.initView(extend)
	var = {
		xmlPanel,
		
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerZhuanShengDiTu.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerZhuanShengDiTu.handlePanelData)
		
		V4_ContainerZhuanShengDiTu.showTitleAnimation()
		V4_ContainerZhuanShengDiTu.showRightAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerZhuanShengDiTu.showUI()
	
	var.xmlPanel:getWidgetByName("dalu1"):addClickEventListener(function ( sender )
		V4_ContainerZhuanShengDiTu.showMapList(1)
	end)
	var.xmlPanel:getWidgetByName("dalu2"):addClickEventListener(function ( sender )
		V4_ContainerZhuanShengDiTu.showMapList(2)
	end)
	var.xmlPanel:getWidgetByName("dalu3"):addClickEventListener(function ( sender )
		V4_ContainerZhuanShengDiTu.showMapList(3)
	end)
	var.xmlPanel:getWidgetByName("dalu4"):addClickEventListener(function ( sender )
		V4_ContainerZhuanShengDiTu.showMapList(4)
	end)
	
	
	var.xmlPanel:getWidgetByName("map_enter_1"):addClickEventListener(function ( sender )
		local level = GameCharacter._mainAvatar:NetAttr(GameConst.net_level)
		local zslevel = GameCharacter._mainAvatar:NetAttr(GameConst.net_zslevel)
		if currentDaLuInfo.data[sender.mapInfoIndex].level > level or currentDaLuInfo.data[sender.mapInfoIndex].zslevel > zslevel then
			local str = "需要"
			if currentDaLuInfo.data[sender.mapInfoIndex].level>0 then
				str = str.."等级"..currentDaLuInfo.data[sender.mapInfoIndex].level.."级"
			end
			if currentDaLuInfo.data[sender.mapInfoIndex].zslevel>0 then
				str = str.."转升"..currentDaLuInfo.data[sender.mapInfoIndex].zslevel.."级"
			end
			GameSocket:alertLocalMsg(str.."才可进入本大陆！", "alert")
			return
		end
		GameSocket:PushLuaTable("npc.v4_zhuanshengditu.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",dalu=currentDaLuInfoIndex,mapindex=sender.mapInfoIndex,mapno=1}))
		
	end)	
	
	var.xmlPanel:getWidgetByName("btn_back"):addClickEventListener(function ( sender )
		V4_ContainerZhuanShengDiTu.showMapHome()
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

function V4_ContainerZhuanShengDiTu.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerZhuanShengDiTu.showRightAnimation()
		
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


function V4_ContainerZhuanShengDiTu.showMapHome()
	local bg = var.xmlPanel:getWidgetByName("bg")
	bg:loadTexture("panel_zsdt_1.png",ccui.TextureResType.plistType)
	var.xmlPanel:getWidgetByName("left_panel"):setVisible(true)
	var.xmlPanel:getWidgetByName("right_tips"):setVisible(true)
	var.xmlPanel:getWidgetByName("left_panel_map"):setVisible(false)
	var.xmlPanel:getWidgetByName("list_btn"):setVisible(false)
end

function V4_ContainerZhuanShengDiTu.showMapList(mapindex)
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
			
	local bg = var.xmlPanel:getWidgetByName("bg")
	bg:loadTexture("panel_zsdt_12.png",ccui.TextureResType.plistType)
	var.xmlPanel:getWidgetByName("left_panel"):setVisible(false)
	var.xmlPanel:getWidgetByName("right_tips"):setVisible(false)
	currentDaLuInfo = mapList[mapindex]
	currentDaLuInfoIndex = mapindex
	var.xmlPanel:getWidgetByName("left_panel_map"):setVisible(true)
	
	local list_btn = var.xmlPanel:getWidgetByName("list_btn"):setVisible(true)
	list_btn:reloadData(#currentDaLuInfo.data,function( subItem )
	
		local function  showMapDetail( sender )
			var.xmlPanel:getWidgetByName("map_enter_1").mapInfoIndex = sender.mapInfoIndex
			var.xmlPanel:getWidgetByName("map_enter_1"):loadTextureNormal("panel_zsdt_"..(tonumber(currentDaLuInfo.data[sender.mapInfoIndex].bigres)+0)..".png",ccui.TextureResType.plistType)
			var.xmlPanel:getWidgetByName("map_enter_1"):loadTexturePressed("panel_zsdt_"..(tonumber(currentDaLuInfo.data[sender.mapInfoIndex].bigres)+1)..".png",ccui.TextureResType.plistType)
		end
		
		local data = currentDaLuInfo.data[subItem.tag]
		subItem:getWidgetByName("select_map"):loadTextureNormal("panel_zsdt_"..(tonumber(data.res)+0)..".png",ccui.TextureResType.plistType)
		subItem:getWidgetByName("select_map"):loadTexturePressed("panel_zsdt_"..(tonumber(data.res)+1)..".png",ccui.TextureResType.plistType)
		subItem:getWidgetByName("select_map").mapInfoIndex = subItem.tag
		
		GUIFocusPoint.addUIPoint(subItem:getWidgetByName("select_map"), showMapDetail)
		if subItem.tag==1 then
			showMapDetail(subItem:getWidgetByName("select_map"))
		end
	end)

end

function V4_ContainerZhuanShengDiTu.handlePanelData(event)
	if event.type == "v4_PanelZhuanShengDiTu" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			mapList = data.mapList
			V4_ContainerZhuanShengDiTu.showUI()
		end
	end
end


function V4_ContainerZhuanShengDiTu.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.v4_zhuanshengditu.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerZhuanShengDiTu.onPanelClose()

end

return V4_ContainerZhuanShengDiTu