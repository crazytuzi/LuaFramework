local ContainerHunHuan = {}
local var = {}

local currentTitleIndex = 0

function ContainerHunHuan.initView(extend)
	var = {
		xmlPanel,
		titleList={},
		items={},
		autoVcoin=false,
	}
	if extend.mParam and extend.mParam.titleList then
		var.titleList = extend.mParam.titleList
	else
		GameSocket:PushLuaTable("gui.ContainerHunHuan.handlePanelData",GameUtilSenior.encode({actionid = "updateHunHuanList"}))
	end
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerHunHuan.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerHunHuan.handlePanelData)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA,ContainerHunHuan.handlePanelData)
		
		ContainerHunHuan.showTitleAnimation()
		ContainerHunHuan.showRightAnimation()
		
		ContainerHunHuan.showMapList()
		
		var.xmlPanel:getWidgetByName("upgrade_btn"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("gui.ContainerHunHuan.handlePanelData",GameUtilSenior.encode({actionid = "updateHunHuan",index=currentTitleIndex,autoVcoin=var.autoVcoin}))
		end)
		
		return var.xmlPanel
	end
end


function ContainerHunHuan.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end

function ContainerHunHuan.showRightAnimation()
		
	local right_tips = var.xmlPanel:getWidgetByName("upgrade_animal")
	local startNum = 132
	local function startShowRightBg()
	
		local filepath = string.format("ContainerHunHuan_%d.png",startNum)
		right_tips:loadTexture(filepath,ccui.TextureResType.plistType)
		
		startNum= startNum+1
		if startNum ==140 then
			startNum =132
		end
	end
	right_tips:stopAllActions()
	right_tips:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowRightBg)}),tonumber(20)))
		
end

function ContainerHunHuan.showMapList()
	local level = GameCharacter._mainAvatar:NetAttr(GameConst.net_level)
	local zslevel = GameCharacter._mainAvatar:NetAttr(GameConst.net_zslevel)
	
	local currentIndex = 1
	
	local list_btn = var.xmlPanel:getWidgetByName("list_btn"):setVisible(true)
	list_btn:reloadData(#var.titleList,function( subItem )
		table.insert(var.items,subItem)
		local function  showMapDetail( sender )
			for i,v in ipairs(var.items) do
				v:getWidgetByName("title_btn_font"):loadTexture(string.format("ContainerHunHuan_left_btn_%d_1.png",v.index),ccui.TextureResType.plistType)
				--v:getWidgetByName("title_btn_font"):loadTexturePressed(string.format("ContainerHunHuan_left_btn_%d_3.png",v.index),ccui.TextureResType.plistType)
				v:getWidgetByName("title_btn"):loadTexture("ContainerHunHuan_2.png",ccui.TextureResType.plistType)
				v:getWidgetByName("title_btn_animal"):setVisible(false)
			end
			subItem:getWidgetByName("title_btn"):loadTexture("ContainerHunHuan_3.png",ccui.TextureResType.plistType)
			subItem:getWidgetByName("title_btn_font"):loadTexture(string.format("ContainerHunHuan_left_btn_%d_2.png",var.titleList[subItem.tag].index),ccui.TextureResType.plistType)
			--subItem:getWidgetByName("title_btn_font"):loadTexturePressed(string.format("ContainerHunHuan_left_btn_%d_2.png",var.titleList[subItem.tag].index),ccui.TextureResType.plistType)
			subItem:getWidgetByName("title_btn_animal"):setVisible(true)
			var.xmlPanel:getWidgetByName("title_pre"):loadTexture(string.format("ContainerHunHuan_left_pre_%d.png",var.titleList[subItem.tag].index), ccui.TextureResType.plistType)
			
			local strs = {
				"<font size=14 color=#FFFF99>增加切割："..(var.titleList[subItem.tag].holyDam).."</font>",
				--"<font size=14 color=#FFFF99>触发鞭尸："..(var.titleList[subItem.tag].bianshi/100).."%</font>",
				--"<font size=14 color=#00FF00>升级消耗："..var.titleList[subItem.tag].money.."元宝</font>",
				"<font size=14 color=#FF00FF>元宝升级："..(var.titleList[subItem.tag].moneyProb/100).."%成功率</font>",
				--"<font size=14 color=#FF0066>升级消耗："..var.titleList[subItem.tag].vcoin.."钻石</font>",
				"<font size=14 color=#FF6600>钻石升级："..(var.titleList[subItem.tag].vcoinProb/100).."%成功率</font>",
				"<font size=14 color=#33FF99>以上条件任选其一即可</font>",
				--"<font size=14 color=#99FF00>魂环升级必须要逐级提升</font>",
			}
			ContainerHunHuan.updateList( var.xmlPanel:getWidgetByName("descList"),strs )
			var.xmlPanel:getWidgetByName("descNeed"):setText("进阶费用："..var.titleList[subItem.tag].money.."元宝或"..var.titleList[subItem.tag].vcoin.."钻石")
			currentTitleIndex = var.titleList[subItem.tag].index
		end
		subItem:getWidgetByName("title_btn_font"):loadTexture(string.format("ContainerHunHuan_left_btn_%d_1.png",var.titleList[subItem.tag].index),ccui.TextureResType.plistType)
		--subItem:getWidgetByName("title_btn_font"):loadTexturePressed(string.format("ContainerHunHuan_left_btn_%d_3.png",var.titleList[subItem.tag].index),ccui.TextureResType.plistType)
		subItem:getWidgetByName("title_btn"):loadTexture("ContainerHunHuan_2.png",ccui.TextureResType.plistType)
		subItem.index = var.titleList[subItem.tag].index
		subItem:setTouchEnabled(true)
		subItem:addClickEventListener(function ( sender )
			currentIndex = sender.tag
			showMapDetail(sender)
		end)
		--GUIFocusPoint.addUIPoint(subItem:getWidgetByName("title_btn_font"), showMapDetail)
		
		local btnAutoVcoin = var.xmlPanel:getWidgetByName("btn_auto_vcoin")
		btnAutoVcoin:addClickEventListener(function (sender)
			var.autoVcoin = not var.autoVcoin
			sender:loadTextureNormal( (var.autoVcoin and "btn_checkbox_s_has_bg") or "btn_checkbox", ccui.TextureResType.plistType):setContentSize(cc.size(30,30)):setScale9Enabled(true):setCapInsets(cc.rect(0,0,30,30))
		end)
		
		--动画
		local title_animal = subItem:getWidgetByName("title_btn_animal")
		local startNum = 50
		local function startShowTitleBg()
			
			title_animal:loadTexture(string.format("ContainerHunHuan_%d.png",startNum), ccui.TextureResType.plistType)
			
			startNum= startNum+1
			if startNum ==112 then
				startNum =50
			end
		end
		title_animal:stopAllActions()
		title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.01),cca.cb(startShowTitleBg)}),tonumber(63)))
		
		if subItem.tag==currentIndex then
			showMapDetail(subItem:getWidgetByName("title_btn_font"))
		end
	end)

end

function ContainerHunHuan.updateList( list,strs )
	local t = {}
	if GameUtilSenior.isString(strs) then
		table.insert(t,strs)
	elseif GameUtilSenior.isTable(strs) then
		t = strs
	end
	list:removeAllItems()
	for i,v in ipairs(t) do
		local richLabel = GUIRichLabel.new({size = cc.size(list:getContentSize().width, 40), space=10,name = "hintMsg"..i})
		richLabel:setRichLabel(v,"panel_npctalk")
		list:pushBackCustomItem(richLabel)
	end
end


function ContainerHunHuan.handlePanelData(event)
	if event.type == "ContainerHunHuan" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="updateHunHuanList" then
			var.titleList = data.Data
			ContainerHunHuan.showMapList()
		end
	end
end


function ContainerHunHuan.onPanelOpen(extend)
	--GameSocket:PushLuaTable("npc.v4_ChengHaoXiTong.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function ContainerHunHuan.onPanelClose()

end

return ContainerHunHuan