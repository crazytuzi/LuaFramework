local V4_ContainerQieGeXiTong = {}
local var = {}

local mapList = {}

local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}
local currentMapInfoIndex = 0

function V4_ContainerQieGeXiTong.initView(extend)
	var = {
		xmlPanel,
		title_list_cells
	}
	
	var.title_list_cells = {}
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerQieGeXiTong.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerQieGeXiTong.handlePanelData)
		
		V4_ContainerQieGeXiTong.showTitleAnimation()
		V4_ContainerQieGeXiTong.showRightAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerQieGeXiTong.showUI()
	
	var.xmlPanel:getWidgetByName("dalu1"):addClickEventListener(function ( sender )
		V4_ContainerQieGeXiTong.showMapList(1)
	end)
	var.xmlPanel:getWidgetByName("dalu2"):addClickEventListener(function ( sender )
		V4_ContainerQieGeXiTong.showMapList(2)
	end)
	var.xmlPanel:getWidgetByName("dalu3"):addClickEventListener(function ( sender )
		V4_ContainerQieGeXiTong.showMapList(3)
	end)
	var.xmlPanel:getWidgetByName("dalu4"):addClickEventListener(function ( sender )
		V4_ContainerQieGeXiTong.showMapList(4)
	end)
	
	
	var.xmlPanel:getWidgetByName("btn_upgrade"):addClickEventListener(function ( sender )
		
		local mParam = {
			name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "升级需消耗："..currentDaLuInfo.data[currentMapInfoIndex].fromItem..",元宝x"..currentDaLuInfo.data[currentMapInfoIndex].needVcoin..",玄辰币x"..currentDaLuInfo.data[currentMapInfoIndex].needBindGameMoney..",RMBx"..currentDaLuInfo.data[currentMapInfoIndex].needBindVcoin.."",
			btnConfirm = "是", btnCancel = "否",
			confirmCallBack = function ()
				GameSocket:PushLuaTable("npc.v4_QieGeXiTong.handlePanelData",GameUtilSenior.encode({actionid = "exchange",dalu=currentDaLuInfoIndex,mapindex=currentMapInfoIndex}))
			end
		}
		GameSocket:dispatchEvent(mParam)
		
	end)
	
	
	var.xmlPanel:getWidgetByName("btn_back"):addClickEventListener(function ( sender )
		V4_ContainerQieGeXiTong.showMapHome()
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

function V4_ContainerQieGeXiTong.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerQieGeXiTong.showRightAnimation()
		
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

function V4_ContainerQieGeXiTong.showAnimaTion()
	print(mapList[currentDaLuInfoIndex].data[currentMapInfoIndex].typeid)
	GUIItem.getItem({parent = var.xmlPanel:getWidgetByName("equip"),typeId = mapList[currentDaLuInfoIndex].data[currentMapInfoIndex].typeid})
	
	local stoneAnimal = var.xmlPanel:getChildByName("stoneAnimal"):setVisible(true)

	local maxPicID = 0
	for i=1,100,1 do
		local filepath = string.format("ui/image/QieGeHeCheng/%d%02d.png",(currentDaLuInfoIndex-1)*10+currentMapInfoIndex,i)
		if not cc.FileUtils:getInstance():isFileExist(filepath) then
			break
		else
			maxPicID = i
		end
	end
	
	local startNum = 0
	local function startShowBg()
	
		local filepath = string.format("ui/image/QieGeHeCheng/%d%02d.png",(currentDaLuInfoIndex-1)*10+currentMapInfoIndex,startNum)
		asyncload_callback(filepath, stoneAnimal, function(filepath, texture)
			stoneAnimal:loadTexture(filepath)
		end)
		
		startNum= startNum+1
		if startNum ==maxPicID+1 then
			startNum =0
		end
	end
	var.xmlPanel:stopAllActions()
	var.xmlPanel:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg)}),tonumber(maxPicID+1)))
	
	
end


function V4_ContainerQieGeXiTong.showMapHome()
	local bg = var.xmlPanel:getWidgetByName("bg")
	bg:loadTexture("panel_qgxt_33.png",ccui.TextureResType.plistType):setPosition(0,0)
	var.xmlPanel:getWidgetByName("btn_back"):setPosition(624,50)
	var.xmlPanel:getWidgetByName("left_panel"):setVisible(true)
	var.xmlPanel:getWidgetByName("right_tips"):setVisible(true)
	var.xmlPanel:getWidgetByName("left_panel_map"):setVisible(false)
	var.xmlPanel:getWidgetByName("list_btn"):setVisible(false)
	var.xmlPanel:getChildByName("stoneAnimal"):setVisible(false)
	var.xmlPanel:getChildByName("btn_upgrade"):setVisible(false)
	var.xmlPanel:getChildByName("equip"):setVisible(false)
end

function V4_ContainerQieGeXiTong.showMapList(mapindex)
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
	bg:loadTexture("panel_qgxt_32.png",ccui.TextureResType.plistType):setPosition(0,-30)
	var.xmlPanel:getWidgetByName("btn_back"):setPosition(695,25)
	var.xmlPanel:getWidgetByName("btn_upgrade"):setVisible(true)
	var.xmlPanel:getChildByName("equip"):setVisible(true)
	var.xmlPanel:getWidgetByName("left_panel"):setVisible(false)
	var.xmlPanel:getWidgetByName("right_tips"):setVisible(false)
	currentDaLuInfo = mapList[mapindex]
	currentDaLuInfoIndex = mapindex
	var.xmlPanel:getWidgetByName("left_panel_map"):setVisible(true)
	
	local list_btn = var.xmlPanel:getWidgetByName("list_btn"):setVisible(true)
	var.title_list_cells = {}
	list_btn:reloadData(#currentDaLuInfo.data,function( subItem )
	
		local function  showMapDetail( sender )
			V4_ContainerQieGeXiTong.switchTONextBtn(sender.mapInfoIndex)
		end
		
		local data = currentDaLuInfo.data[subItem.tag]
		subItem:getWidgetByName("select_map"):loadTextureNormal("panel_qgxt_"..(tonumber(data.res)+0)..".png",ccui.TextureResType.plistType)
		subItem:getWidgetByName("select_map"):loadTexturePressed("panel_qgxt_"..(tonumber(data.res)+1)..".png",ccui.TextureResType.plistType)
		subItem:getWidgetByName("select_map").mapInfoIndex = subItem.tag
		
		local needCellpre = var.title_list_cells[subItem.tag];
		if not needCellpre then
			needCellpre = subItem;
			needCellpre:setName(subItem:getName()..subItem.tag);
		end
		var.title_list_cells[subItem.tag] = needCellpre;
		
		GUIFocusPoint.addUIPoint(subItem:getWidgetByName("select_map"), showMapDetail)
		if subItem.tag==1 then
			showMapDetail(subItem:getWidgetByName("select_map"))
		end
	end)

end

function V4_ContainerQieGeXiTong.switchTONextBtn(nextIndex)
	if currentMapInfoIndex > 0 and var.title_list_cells[currentMapInfoIndex] then
		local data = currentDaLuInfo.data[currentMapInfoIndex]		
		var.title_list_cells[currentMapInfoIndex]:getWidgetByName("select_map"):loadTextureNormal("panel_qgxt_"..(tonumber(data.res)+0)..".png",ccui.TextureResType.plistType)
		var.title_list_cells[currentMapInfoIndex]:getWidgetByName("select_map"):loadTexturePressed("panel_qgxt_"..(tonumber(data.res)+1)..".png",ccui.TextureResType.plistType)
	end
	
	currentMapInfoIndex = nextIndex
	local data = currentDaLuInfo.data[currentMapInfoIndex]
	var.title_list_cells[currentMapInfoIndex]:getWidgetByName("select_map"):loadTextureNormal("panel_qgxt_"..(tonumber(data.res)+1)..".png",ccui.TextureResType.plistType)
	var.title_list_cells[currentMapInfoIndex]:getWidgetByName("select_map"):loadTexturePressed("panel_qgxt_"..(tonumber(data.res)+1)..".png",ccui.TextureResType.plistType)
	V4_ContainerQieGeXiTong.showAnimaTion()
end

function V4_ContainerQieGeXiTong.handlePanelData(event)
	if event.type == "v4_PanelQieGeXiTong" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			mapList = data.mapList
			V4_ContainerQieGeXiTong.showUI()
		end
		if data.cmd =="next" then
			V4_ContainerQieGeXiTong.switchTONextBtn(data.mapindex)
		end
	end
end


function V4_ContainerQieGeXiTong.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.v4_QieGeXiTong.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerQieGeXiTong.onPanelClose()

end

return V4_ContainerQieGeXiTong