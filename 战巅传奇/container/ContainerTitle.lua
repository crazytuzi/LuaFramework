local ContainerTitle = {}
local var = {}

local currentTitleIndex = 0

function ContainerTitle.initView(extend)
	var = {
		xmlPanel,
		titleList={},
		items={},
		autoVcoin=false,
	}
	if extend.mParam and extend.mParam.titleList then
		var.titleList = extend.mParam.titleList
	else
		GameSocket:PushLuaTable("gui.ContainerTitle.onOpenPanel",GameUtilSenior.encode({actionid = "updateTitleList"}))
	end
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerTitle.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerTitle.handlePanelData)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA,ContainerTitle.handlePanelData)
		
		ContainerTitle.showTitleAnimation()
		ContainerTitle.showRightAnimation()
		
		ContainerTitle.showMapList()
		
		var.xmlPanel:getWidgetByName("upgrade_btn"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("gui.ContainerTitle.onOpenPanel",GameUtilSenior.encode({actionid = "updateTitle",index=currentTitleIndex,autoVcoin=var.autoVcoin}))
		end)
		
		return var.xmlPanel
	end
end


function ContainerTitle.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end

function ContainerTitle.showRightAnimation()
		
	local right_tips = var.xmlPanel:getWidgetByName("upgrade_animal")
	local startNum = 132
	local function startShowRightBg()
	
		local filepath = string.format("ContainerTitle_%d.png",startNum)
		right_tips:loadTexture(filepath,ccui.TextureResType.plistType)
		
		startNum= startNum+1
		if startNum ==140 then
			startNum =132
		end
	end
	right_tips:stopAllActions()
	right_tips:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowRightBg)}),tonumber(20)))
		
end

function ContainerTitle.showMapList()
	local level = GameCharacter._mainAvatar:NetAttr(GameConst.net_level)
	local zslevel = GameCharacter._mainAvatar:NetAttr(GameConst.net_zslevel)
	
	local currentIndex = 1
	
	local list_btn = var.xmlPanel:getWidgetByName("list_btn"):setVisible(true)
	list_btn:reloadData(#var.titleList,function( subItem )
		table.insert(var.items,subItem)
		local function  showMapDetail( sender )
			for i,v in ipairs(var.items) do
				v:getWidgetByName("title_btn_font"):loadTexture(string.format("ContainerTitle_left_btn_%d_1.png",v.index),ccui.TextureResType.plistType)
				--v:getWidgetByName("title_btn_font"):loadTexturePressed(string.format("ContainerTitle_left_btn_%d_3.png",v.index),ccui.TextureResType.plistType)
				v:getWidgetByName("title_btn"):loadTexture("ContainerTitle_2.png",ccui.TextureResType.plistType)
				v:getWidgetByName("title_btn_animal"):setVisible(false)
			end
			subItem:getWidgetByName("title_btn"):loadTexture("ContainerTitle_3.png",ccui.TextureResType.plistType)
			subItem:getWidgetByName("title_btn_font"):loadTexture(string.format("ContainerTitle_left_btn_%d_2.png",var.titleList[subItem.tag].index),ccui.TextureResType.plistType)
			--subItem:getWidgetByName("title_btn_font"):loadTexturePressed(string.format("ContainerTitle_left_btn_%d_2.png",var.titleList[subItem.tag].index),ccui.TextureResType.plistType)
			subItem:getWidgetByName("title_btn_animal"):setVisible(true)
			var.xmlPanel:getWidgetByName("title_pre"):loadTexture(string.format("ContainerTitle_left_pre_%d.png",var.titleList[subItem.tag].index), ccui.TextureResType.plistType)
			
			local strs = {
				"<font size=12 color=#33FF99>切割属性："..(var.titleList[subItem.tag].holyDam).."</font>",
				"<font size=12 color=#FFFF99>攻击增加："..(var.titleList[subItem.tag].attack).."</font>",
				"<font size=12 color=#99FF66>防御增加："..(var.titleList[subItem.tag].attack).."</font>",
				"<font size=12 color=#FF00FF>血量增加："..(var.titleList[subItem.tag].hp).."</font>",
				"<font size=12 color=#FF0066>暴击几率："..(var.titleList[subItem.tag].baoji/100).."%</font>",
				"<font size=12 color=#FF6600>倍伤增加："..(var.titleList[subItem.tag].beishang/100).."%</font>",
				--"<font size=12 color=#33FF99>减伤提升："..(var.titleList[subItem.tag].jianshang/100).."%</font>",
				"<font size=12 color=#99FF00>血量增幅："..(var.titleList[subItem.tag].hprate/100).."%</font>",
				"<font size=12 color=#00FF00>爆率提升："..(var.titleList[subItem.tag].drop/100).."%</font>",
				--"<font size=12 color=#FF6600>称号福利：专属打怪地图</font>",
				--"<font size=12 color=#33FF99>称号爆率是绝对真实有效</font>",
				--"<font size=12 color=#99FF00>称号升级必须要逐级提升</font>",
				--"<font size=12 color=#00FF00>顶级称号具有额外的属性</font>",
			}
			ContainerTitle.updateList( var.xmlPanel:getWidgetByName("descList"),strs )
			local moneyStr = "进阶材料："..var.titleList[subItem.tag].money.."元宝"
			if var.titleList[subItem.tag].vcoin>0 then
				moneyStr = moneyStr.."、"..var.titleList[subItem.tag].vcoin.."钻石"
			end
			if var.titleList[subItem.tag].czd>0 then
				moneyStr = moneyStr.."、"..var.titleList[subItem.tag].czd.."充值点"
			end
			var.xmlPanel:getWidgetByName("descNeed"):setText(moneyStr)
			if var.titleList[subItem.tag].itemnum>0 then
				var.xmlPanel:getWidgetByName("descNeed2"):setText("进阶材料：称号证明x"..var.titleList[subItem.tag].itemnum.."")
			end
			if var.titleList[subItem.tag].itemnum2>0 then
				var.xmlPanel:getWidgetByName("descNeed3"):setText("进阶材料：忘忧神石x"..var.titleList[subItem.tag].itemnum2.."")
			end
			currentTitleIndex = var.titleList[subItem.tag].index
			
			local btnAutoVcoin = var.xmlPanel:getWidgetByName("btn_auto_vcoin")
			btnAutoVcoin:addClickEventListener(function (csender)
				var.autoVcoin = not var.autoVcoin
				csender:loadTextureNormal( (var.autoVcoin and "btn_checkbox_s_has_bg") or "btn_checkbox", ccui.TextureResType.plistType):setContentSize(cc.size(30,30)):setScale9Enabled(true):setCapInsets(cc.rect(0,0,30,30))
				if var.autoVcoin then
					var.xmlPanel:getWidgetByName("descNeed"):setText("进阶费用："..var.titleList[sender.tag].money.."钻石")
				else
					var.xmlPanel:getWidgetByName("descNeed"):setText("进阶材料："..var.titleList[sender.tag].itemnum.."个称号升级证明")
				end
			end)
		end
		subItem:getWidgetByName("title_btn_font"):loadTexture(string.format("ContainerTitle_left_btn_%d_1.png",var.titleList[subItem.tag].index),ccui.TextureResType.plistType)
		subItem:getWidgetByName("title_btn"):loadTexture("ContainerTitle_2.png",ccui.TextureResType.plistType)
		--subItem:getWidgetByName("title_btn_font"):loadTexturePressed(string.format("ContainerTitle_left_btn_%d_3.png",var.titleList[subItem.tag].index),ccui.TextureResType.plistType)
		subItem.index = var.titleList[subItem.tag].index
		subItem:setTouchEnabled(true)
		subItem:addClickEventListener(function ( sender )
			currentIndex = sender.tag
			showMapDetail(sender)
		end)
		--GUIFocusPoint.addUIPoint(subItem, showMapDetail)
		
		--动画
		local title_animal = subItem:getWidgetByName("title_btn_animal"):setVisible(false)
		local startNum = 50
		local function startShowTitleBg()
			
			title_animal:loadTexture(string.format("ContainerTitle_%d.png",startNum), ccui.TextureResType.plistType)
			
			startNum= startNum+1
			if startNum ==112 then
				startNum =50
			end
		end
		title_animal:stopAllActions()
		title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.01),cca.cb(startShowTitleBg)}),tonumber(63)))
		
		if subItem.tag==currentIndex then
			showMapDetail(subItem)
		end
	end)

end

function ContainerTitle.updateList( list,strs )
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


function ContainerTitle.handlePanelData(event)
	if event.type == "ContainerTitle" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="updateTitleList" then
			var.titleList = data.Data
			ContainerTitle.showMapList()
		end
	end
end


function ContainerTitle.onPanelOpen(extend)
	--GameSocket:PushLuaTable("npc.v4_ChengHaoXiTong.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function ContainerTitle.onPanelClose()

end

return ContainerTitle