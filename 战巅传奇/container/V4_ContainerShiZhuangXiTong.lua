local V4_ContainerShiZhuangXiTong = {}
local var = {}

local mapList = {}

local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerShiZhuangXiTong.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerShiZhuangXiTong.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerShiZhuangXiTong.handlePanelData)
		
		V4_ContainerShiZhuangXiTong.showTitleAnimation()
		V4_ContainerShiZhuangXiTong.showRightAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerShiZhuangXiTong.showUI()
	
	var.xmlPanel:getWidgetByName("dalu1"):addClickEventListener(function ( sender )
		V4_ContainerShiZhuangXiTong.showMapList(1)
	end)
	var.xmlPanel:getWidgetByName("dalu2"):addClickEventListener(function ( sender )
		V4_ContainerShiZhuangXiTong.showMapList(2)
	end)
	var.xmlPanel:getWidgetByName("dalu3"):addClickEventListener(function ( sender )
		V4_ContainerShiZhuangXiTong.showMapList(3)
	end)
	var.xmlPanel:getWidgetByName("dalu4"):addClickEventListener(function ( sender )
		V4_ContainerShiZhuangXiTong.showMapList(4)
	end)
	
	var.xmlPanel:getWidgetByName("btn_back"):addClickEventListener(function ( sender )
		V4_ContainerShiZhuangXiTong.showMapHome()
	end)
	
	
	var.xmlPanel:getWidgetByName("left_arr"):addClickEventListener(function ( sender )
		currentMapInfoIndex = currentMapInfoIndex-1
		if currentMapInfoIndex<1 then
			currentMapInfoIndex = #currentDaLuInfo.data
		end
		V4_ContainerShiZhuangXiTong.showFashion(currentMapInfoIndex)
	end)
	
	var.xmlPanel:getWidgetByName("right_arr"):addClickEventListener(function ( sender )
		currentMapInfoIndex = currentMapInfoIndex+1
		if currentMapInfoIndex>#currentDaLuInfo.data then
			currentMapInfoIndex = 1
		end
		V4_ContainerShiZhuangXiTong.showFashion(currentMapInfoIndex)
	end)
	
	
	var.xmlPanel:getWidgetByName("duanzao_1"):addClickEventListener(function ( sender )
		
		local mParam = {
			name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "升级需消耗："..currentDaLuInfo.data[currentMapInfoIndex].fromItemCloth..",元宝x"..currentDaLuInfo.data[currentMapInfoIndex].needVcoin..",玄辰币x"..currentDaLuInfo.data[currentMapInfoIndex].needBindGameMoney..",RMBx"..currentDaLuInfo.data[currentMapInfoIndex].needBindVcoin.."",
			btnConfirm = "是", btnCancel = "否",
			confirmCallBack = function ()
				GameSocket:PushLuaTable("npc.v4_ShiZhuangXiTong.handlePanelData",GameUtilSenior.encode({actionid = "exchange",dalu=currentDaLuInfoIndex,mapindex=currentMapInfoIndex,mapno=1}))
			end
		}
		GameSocket:dispatchEvent(mParam)
		
	end)
	var.xmlPanel:getWidgetByName("duanzao_2"):addClickEventListener(function ( sender )
		
		local mParam = {
			name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "升级需消耗："..currentDaLuInfo.data[currentMapInfoIndex].fromItemWeapon..",元宝x"..currentDaLuInfo.data[currentMapInfoIndex].needVcoin..",玄辰币x"..currentDaLuInfo.data[currentMapInfoIndex].needBindGameMoney..",RMBx"..currentDaLuInfo.data[currentMapInfoIndex].needBindVcoin.."",
			btnConfirm = "是", btnCancel = "否",
			confirmCallBack = function ()
				GameSocket:PushLuaTable("npc.v4_ShiZhuangXiTong.handlePanelData",GameUtilSenior.encode({actionid = "exchange",dalu=currentDaLuInfoIndex,mapindex=currentMapInfoIndex,mapno=2}))
			end
		}
		GameSocket:dispatchEvent(mParam)
		
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

function V4_ContainerShiZhuangXiTong.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerShiZhuangXiTong.showRightAnimation()
		
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


function V4_ContainerShiZhuangXiTong.showMapHome()
	local bg = var.xmlPanel:getWidgetByName("bg")
	bg:loadTexture("panel_szxt_12.png",ccui.TextureResType.plistType):setPosition(0,0)
	var.xmlPanel:getWidgetByName("btn_back"):setPosition(624,50)
	var.xmlPanel:getWidgetByName("left_panel"):setVisible(true)
	var.xmlPanel:getWidgetByName("right_tips"):setVisible(true)
	var.xmlPanel:getWidgetByName("left_panel_map"):setVisible(false)
	var.xmlPanel:getWidgetByName("duanzao_1"):setVisible(false)
	var.xmlPanel:getWidgetByName("duanzao_2"):setVisible(false)
	var.xmlPanel:getWidgetByName("equip_1"):setVisible(false)
	var.xmlPanel:getWidgetByName("equip_2"):setVisible(false)
	var.xmlPanel:getWidgetByName("fashion"):setVisible(false)
end

function V4_ContainerShiZhuangXiTong.showMapList(mapindex)
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
	bg:loadTexture("panel_szxt_7.png",ccui.TextureResType.plistType):setPosition(0,-20)
	var.xmlPanel:getWidgetByName("btn_back"):setPosition(654,15)
	var.xmlPanel:getWidgetByName("left_panel"):setVisible(false)
	var.xmlPanel:getWidgetByName("right_tips"):setVisible(false)
	var.xmlPanel:getWidgetByName("duanzao_1"):setVisible(true)
	var.xmlPanel:getWidgetByName("duanzao_2"):setVisible(true)
	var.xmlPanel:getWidgetByName("equip_1"):setVisible(true)
	var.xmlPanel:getWidgetByName("equip_2"):setVisible(true)
	var.xmlPanel:getWidgetByName("fashion"):setVisible(true)
	currentDaLuInfo = mapList[mapindex]
	currentDaLuInfoIndex = mapindex
	var.xmlPanel:getWidgetByName("left_panel_map"):setVisible(true)
	V4_ContainerShiZhuangXiTong.showFashion(1)

end

function V4_ContainerShiZhuangXiTong.showFashion(index)
	local fashion = var.xmlPanel:getWidgetByName("fashion")
	currentMapInfoIndex = index
	GUIItem.getItem({parent = var.xmlPanel:getWidgetByName("equip_1"),typeId = currentDaLuInfo.data[currentMapInfoIndex].typeidCloth})
	GUIItem.getItem({parent = var.xmlPanel:getWidgetByName("equip_2"),typeId = currentDaLuInfo.data[currentMapInfoIndex].typeidWeapon})
	local filepath = string.format("ui/image/Fashion_NPC/%d.png",currentDaLuInfo.data[currentMapInfoIndex].res)
	asyncload_callback(filepath, fashion, function(filepath, texture)
		fashion:loadTexture(filepath)
	end)
	
end

function V4_ContainerShiZhuangXiTong.handlePanelData(event)
	if event.type == "v4_PanelShiZhuangXiTong" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			mapList = data.mapList
			V4_ContainerShiZhuangXiTong.showUI()
		end
	end
end


function V4_ContainerShiZhuangXiTong.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.v4_ShiZhuangXiTong.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerShiZhuangXiTong.onPanelClose()

end

return V4_ContainerShiZhuangXiTong