local V4_ContainerChengHaoDiTu = {}
local var = {}

local mapList = {}

local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}
local myTitleAttr = 0

function V4_ContainerChengHaoDiTu.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerChengHaoDiTu.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerChengHaoDiTu.handlePanelData)
		
		V4_ContainerChengHaoDiTu.showTitleAnimation()
		V4_ContainerChengHaoDiTu.showRightAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerChengHaoDiTu.showUI()
	
	var.xmlPanel:getWidgetByName("dalu1"):addClickEventListener(function ( sender )
		V4_ContainerChengHaoDiTu.showMapList(1)
	end)
	var.xmlPanel:getWidgetByName("dalu2"):addClickEventListener(function ( sender )
		V4_ContainerChengHaoDiTu.showMapList(2)
	end)
	var.xmlPanel:getWidgetByName("dalu3"):addClickEventListener(function ( sender )
		V4_ContainerChengHaoDiTu.showMapList(3)
	end)
	var.xmlPanel:getWidgetByName("dalu4"):addClickEventListener(function ( sender )
		V4_ContainerChengHaoDiTu.showMapList(4)
	end)
	
	var.xmlPanel:getWidgetByName("btn_back"):addClickEventListener(function ( sender )
		V4_ContainerChengHaoDiTu.showMapHome()
	end)
	
	local level = GameCharacter._mainAvatar:NetAttr(GameConst.net_level)
	local zslevel = GameCharacter._mainAvatar:NetAttr(GameConst.net_zslevel)
	
	for i=1,4,1 do
		if mapList[i].level <= level and mapList[i].zslevel <= zslevel and mapList[i].chenghao<=myTitleAttr then
			var.xmlPanel:getWidgetByName("dalu"..i):loadTextureNormal("panel_djsj_"..(21+i)..".png",ccui.TextureResType.plistType)
			var.xmlPanel:getWidgetByName("dalu"..i):loadTexturePressed("panel_djsj_"..(29+i)..".png",ccui.TextureResType.plistType)
		end
	end
end

function V4_ContainerChengHaoDiTu.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerChengHaoDiTu.showRightAnimation()
		
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


function V4_ContainerChengHaoDiTu.showMapHome()
	local bg = var.xmlPanel:getWidgetByName("bg")
	bg:loadTexture("panel_djsj_21.png",ccui.TextureResType.plistType)
	var.xmlPanel:getWidgetByName("left_panel"):setVisible(true)
	var.xmlPanel:getWidgetByName("right_tips"):setVisible(true)
	var.xmlPanel:getWidgetByName("left_panel_map"):setVisible(false)
end

function V4_ContainerChengHaoDiTu.showMapList(mapindex)
	local level = GameCharacter._mainAvatar:NetAttr(GameConst.net_level)
	local zslevel = GameCharacter._mainAvatar:NetAttr(GameConst.net_zslevel)
	if mapList[mapindex].open~=1 then
		GameSocket:alertLocalMsg("该大陆暂未开放!", "alert")
		return
	end
	if mapList[mapindex].level > level or mapList[mapindex].zslevel > zslevel or mapList[mapindex].chenghao>myTitleAttr then
		local str = "需要"
		if mapList[mapindex].chenghao>0 then
			str = str.."称号攻击属性"..mapList[mapindex].chenghao..""
		end
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
	bg:loadTexture("panel_chdt_45.png",ccui.TextureResType.plistType)
	var.xmlPanel:getWidgetByName("left_panel"):setVisible(false)
	var.xmlPanel:getWidgetByName("right_tips"):setVisible(false)
	currentDaLuInfo = mapList[mapindex]
	currentDaLuInfoIndex = mapindex
	var.xmlPanel:getWidgetByName("left_panel_map"):setVisible(true)
	
	local left_panel_map = var.xmlPanel:getWidgetByName("left_panel_map")
	left_panel_map:removeAllChildren()
	
	for i=1,#currentDaLuInfo.data,1 do
		local data = currentDaLuInfo.data[i]
		local pos = string.split(data.res,",")
		local node=ccui.Button:create()
		node:addTo(left_panel_map):loadTextureNormal("panel_chdt_"..(tonumber(data.bigres)+0)..".png",ccui.TextureResType.plistType)
		node:loadTexturePressed("panel_chdt_"..(tonumber(data.bigres)+1)..".png",ccui.TextureResType.plistType)
		node:setName(data.name)
			:setPosition(pos[1],pos[2])
			:setContentSize(cc.size(148,107))
		node.mapInfoIndex = i
		
		node:addClickEventListener(function ( sender )
			V4_ContainerChengHaoDiTu.enterMap(sender)
		end)
	end
	

end

function V4_ContainerChengHaoDiTu.enterMap(sender)
	local level = GameCharacter._mainAvatar:NetAttr(GameConst.net_level)
	local zslevel = GameCharacter._mainAvatar:NetAttr(GameConst.net_zslevel)
	if currentDaLuInfo.data[sender.mapInfoIndex].level > level or currentDaLuInfo.data[sender.mapInfoIndex].zslevel > zslevel or currentDaLuInfo.data[sender.mapInfoIndex].chenghao>myTitleAttr then
		local str = "需要"
		if currentDaLuInfo.data[sender.mapInfoIndex].chenghao>0 then
			str = str.."称号属性"..currentDaLuInfo.data[sender.mapInfoIndex].chenghao..""
		end
		if currentDaLuInfo.data[sender.mapInfoIndex].level>0 then
			str = str.."等级"..currentDaLuInfo.data[sender.mapInfoIndex].level.."级"
		end
		if currentDaLuInfo.data[sender.mapInfoIndex].zslevel>0 then
			str = str.."转升"..currentDaLuInfo.data[sender.mapInfoIndex].zslevel.."级"
		end
		GameSocket:alertLocalMsg(str.."才可进入本大陆！", "alert")
		return
	end
	
	GameSocket:PushLuaTable("npc.v4_chenghaoditu.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",dalu=currentDaLuInfoIndex,mapindex=sender.mapInfoIndex,mapno=1}))
end

function V4_ContainerChengHaoDiTu.handlePanelData(event)
	if event.type == "V4_ContainerChengHaoDiTu" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			mapList = data.mapList
			myTitleAttr = data.titleAttr
			V4_ContainerChengHaoDiTu.showUI()
		end
	end
end


function V4_ContainerChengHaoDiTu.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.v4_chenghaoditu.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerChengHaoDiTu.onPanelClose()

end

return V4_ContainerChengHaoDiTu