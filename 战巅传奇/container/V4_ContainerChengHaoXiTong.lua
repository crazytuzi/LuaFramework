local V4_ContainerChengHaoXiTong = {}
local var = {}

local mapList = {}

local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerChengHaoXiTong.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerChengHaoXiTong.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerChengHaoXiTong.handlePanelData)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA,V4_ContainerChengHaoXiTong.handlePanelData)
		
		V4_ContainerChengHaoXiTong.showTitleAnimation()
		V4_ContainerChengHaoXiTong.showRightAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerChengHaoXiTong.showUI()
	
	var.xmlPanel:getWidgetByName("dalu1"):addClickEventListener(function ( sender )
		V4_ContainerChengHaoXiTong.showMapList(1)
	end)
	var.xmlPanel:getWidgetByName("dalu2"):addClickEventListener(function ( sender )
		V4_ContainerChengHaoXiTong.showMapList(2)
	end)
	var.xmlPanel:getWidgetByName("dalu3"):addClickEventListener(function ( sender )
		V4_ContainerChengHaoXiTong.showMapList(3)
	end)
	var.xmlPanel:getWidgetByName("dalu4"):addClickEventListener(function ( sender )
		V4_ContainerChengHaoXiTong.showMapList(4)
	end)
	
		
	var.xmlPanel:getWidgetByName("upgrade"):addClickEventListener(function ( sender )
		local rmb = ""
		if currentDaLuInfo.data[sender.mapInfoIndex].needBindVcoin>0 then
			rmb = currentDaLuInfo.data[sender.mapInfoIndex].needBindVcoin.."RMB、"
		end
		local mParam = {
			name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "本操作需要支付"..rmb..currentDaLuInfo.data[sender.mapInfoIndex].needBindMoney.."玄辰币才可继续，是否支付?",
			btnConfirm = "是", btnCancel = "否",
			confirmCallBack = function ()
				GameSocket:PushLuaTable("npc.v4_ChengHaoXiTong.handlePanelData",GameUtilSenior.encode({actionid = "upgrade",dalu=currentDaLuInfoIndex,mapindex=sender.mapInfoIndex}))
			end
		}
		GameSocket:dispatchEvent(mParam)
	end)
	
	var.xmlPanel:getWidgetByName("btn_back"):addClickEventListener(function ( sender )
		V4_ContainerChengHaoXiTong.showMapHome()
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

function V4_ContainerChengHaoXiTong.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerChengHaoXiTong.showRightAnimation()
		
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


function V4_ContainerChengHaoXiTong.showMapHome()
	local bg = var.xmlPanel:getWidgetByName("bg")
	bg:loadTexture("panel_chxt_49.png",ccui.TextureResType.plistType)
	var.xmlPanel:getWidgetByName("left_panel"):setVisible(true)
	var.xmlPanel:getWidgetByName("right_tips"):setVisible(true)
	var.xmlPanel:getWidgetByName("left_panel_map"):setVisible(false)
	var.xmlPanel:getWidgetByName("list_btn"):setVisible(false)
	var.xmlPanel:getWidgetByName("panel_close"):setPosition(730,400)
	var.xmlPanel:getWidgetByName("title_animal"):setPosition(400,360)
end

function V4_ContainerChengHaoXiTong.showMapList(mapindex)
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
	bg:loadTexture("panel_chxt_4.png",ccui.TextureResType.plistType)
	var.xmlPanel:getWidgetByName("panel_close"):setPosition(680,440)
	var.xmlPanel:getWidgetByName("title_animal"):setPosition(370,400)
	var.xmlPanel:getWidgetByName("left_panel"):setVisible(false)
	var.xmlPanel:getWidgetByName("right_tips"):setVisible(false)
	currentDaLuInfo = mapList[mapindex]
	currentDaLuInfoIndex = mapindex
	var.xmlPanel:getWidgetByName("left_panel_map"):setVisible(true)
	
	local list_btn = var.xmlPanel:getWidgetByName("list_btn"):setVisible(true)
	print(#currentDaLuInfo.data)
	list_btn:reloadData(#currentDaLuInfo.data,function( subItem )
	
		local function  showMapDetail( sender )
			local data = currentDaLuInfo.data[subItem.tag]
			var.xmlPanel:getWidgetByName("title"):setText(data.name)
			var.xmlPanel:getWidgetByName("upgrade").mapInfoIndex = subItem.tag
			GameSocket:PushLuaTable("gui.ContainerTitle.onOpenPanel",GameUtilSenior.encode({actionid = "titleAttr",typeID=data.typeid}))
		end
		
		local data = currentDaLuInfo.data[subItem.tag]
		subItem:getWidgetByName("select_map"):loadTextureNormal("panel_chxt_"..(tonumber(data.res)+0)..".png",ccui.TextureResType.plistType)
		subItem:getWidgetByName("select_map").mapInfoIndex = subItem.tag
		--subItem:getWidgetByName("select_map"):addClickEventListener(V4_ContainerChengHaoXiTong.showMapDetail)
		--subItem:setTouchEnabled(true)
		--GUIFocusPoint.addUIPoint(subItem, showMapDetail)
		GUIFocusPoint.addUIPoint(subItem:getWidgetByName("select_map"), showMapDetail)
		if subItem.tag==1 then
			showMapDetail(subItem:getWidgetByName("select_map"))
		end
	end)

end

function V4_ContainerChengHaoXiTong.handlePanelData(event)
	if event.type == "v4_PanelChengHaoXiTong" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			mapList = data.mapList
			V4_ContainerChengHaoXiTong.showUI()
		end
	end
	if event.type == "ContainerTitle" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd == "titleAttr" then
			var.xmlPanel:getWidgetByName("label1"):setRichLabel("<font color='#44EBF9' size=12>攻击：</font><font size=12> "..data.Data.dc.." - "..data.Data.dc2.."</font>")
			var.xmlPanel:getWidgetByName("label2"):setRichLabel("<font color='#44EBF9' size=12>魔道：</font><font size=12> "..data.Data.mc.." - "..data.Data.mc2.."</font>")
			var.xmlPanel:getWidgetByName("label3"):setRichLabel("<font color='#5AFF3C' size=12>血量：</font><font size=12> "..data.Data.max_hp.."</font>")
			var.xmlPanel:getWidgetByName("label4"):setRichLabel("<font color='#5AFF3C' size=12>攻击伤害：</font><font size=12> +"..((data.Data.special_attr.beishang)/10000).."</font>")
			var.xmlPanel:getWidgetByName("label5"):setRichLabel("<font color='#5AFF3C' size=12>忽视防御：</font><font size=12> +"..((data.Data.special_attr.mIgnoreDCRatio)/10000).."</font>")
			var.xmlPanel:getWidgetByName("label6"):setRichLabel("<font color='#5AFF3C' size=12>打怪爆率：</font><font size=12> +"..((data.Data.special_attr.mMonsterDrop)/10000).."</font>")
		end
	end
end


function V4_ContainerChengHaoXiTong.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.v4_ChengHaoXiTong.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerChengHaoXiTong.onPanelClose()

end

return V4_ContainerChengHaoXiTong