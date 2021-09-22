local V9_ContainerShenQi = {}
local var = {}

local currentTitleIndex = 0

function V9_ContainerShenQi.initView(extend)
	var = {
		xmlPanel,
		shenqi,
		items={},
		currentIndex=1,
		updateData=false,
		group=1,
	}
	--var.titleList = extend.mParam.titleList
	var.xmlPanel = GUIAnalysis.load("ui/layout/V9_ContainerShenQi.uif")
	if var.xmlPanel then
	
		var.xmlPanel:getWidgetByName("progress"):setFontSize( 12 )._labelformat = ""
	
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V9_ContainerShenQi.handlePanelData)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA,V9_ContainerShenQi.handlePanelData)
		
		--V9_ContainerShenQi.showTitleAnimation()
		
		--V9_ContainerShenQi.showMapList()
		
		var.xmlPanel:getWidgetByName("update_btn"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("gui.V9_ContainerShenQi.handlePanelData",GameUtilSenior.encode({actionid = "update",group=var.group,currentIndex=var.currentIndex}))
		end)
		var.xmlPanel:getWidgetByName("activity_btn"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("gui.V9_ContainerShenQi.handlePanelData",GameUtilSenior.encode({actionid = "activity",group=var.group,currentIndex=var.currentIndex}))
		end)
		var.xmlPanel:getWidgetByName("upgrade_btn"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("gui.V9_ContainerShenQi.handlePanelData",GameUtilSenior.encode({actionid = "upgrade",group=var.group,currentIndex=var.currentIndex}))
		end)
		
		return var.xmlPanel
	end
end


function V9_ContainerShenQi.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	local startNum = 1
	local function startShowTitleBg()
	
		local filepath = string.format("ui/image/V9_ContainerShenQi/new_game_panel_title_%d.png",startNum)
		asyncload_callback(filepath, title_animal, function(filepath, texture)
			title_animal:loadTexture(filepath)
		end)
		
		startNum= startNum+1
		if startNum ==19 then
			startNum =1
		end
	end
	title_animal:stopAllActions()
	title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowTitleBg)}),tonumber(18)))
		
end

function V9_ContainerShenQi.showRightAnimation(index)

	local attr = var.shenqi[index].setting.attr
	if string.find(var.shenqi[index].setting.attrName,"神圣")==nil then
		attr = (attr/100).."%"
	end
	
	local attr_desc = {
		"<td width=49 color=#9BD826 size=12 ht=2>"..var.shenqi[index].attrName.."：</td><td width=50 color=#25F00A size=12 ht=0>  "..var.shenqi[index].attr.."</td>",
		"<td width=49 color=#9BD826 size=12 ht=2>"..var.shenqi[index].setting.attrName.."</td><td width=50 color=#25F00A size=12 ht=0>  "..attr.."</td>",
		--"<font color=#E6AE02 size=12>升级成功一次永久提升</font> <font color=#25F00A size=12>"..var.shenqi[index].attrName..""..var.shenqi[index].attr.."点</font>",
		"<font color=#E6AE02 size=12>升级</font> <font color=#25F00A size=12>"..var.shenqi[index].setting.update.."次</font><font color=#E6AE02 size=12>激活一个</font> <font color=#25F00A size=12>"..var.shenqi[index].title.."结晶</font>",
		"<font color=#25F00A size=12>6个"..var.shenqi[index].title.."结晶</font> <font color=#E6AE02 size=12>可以将</font> <font color=#25F00A size=12>"..var.shenqi[index].title.."提升一阶</font>",
		--"<font color=#F8ED16 size=12>神器提升到五阶自动开启下一个神器</font>",
	}
	V9_ContainerShenQi.updateList( var.xmlPanel:getWidgetByName("attr_desc"),attr_desc )
	
	local mainrole = GameSocket.mCharacter

	local need_desc = {
		--"<td width=49 color=#9BD826 size=12 ht=2>"..var.shenqi[index].need.."：</td><td width=50 color=#25F00A size=12 ht=0>  "..var.shenqi[index].needNum.."个</td>",
		--"<td width=49 color=#9BD826 size=12 ht=2>当前拥有：</td><td width=50 color=#25F00A size=12 ht=0>  "..var.shenqi[index].suipian.."个</td>",
		"<td width=49 color=#9BD826 size=12 ht=2>成功率：</td><td width=50 color=#0C9EF9 size=12 ht=0>  "..(tonumber(var.shenqi[index].setting.prob)/100).."%</td>",
		"<td width=49 color=#FF6633 size=12 ht=2>需要钻石：</td><td width=50 color=#FF6633 size=12 ht=0>  "..(var.shenqi[index].setting.needVcoin*1).."/次</td>",
		"<td width=49 color=#FF33CC size=12 ht=2>需要元宝：</td><td width=50 color=#FF33CC size=12 ht=0>  "..(var.shenqi[index].setting.needMoney*1).."/次</td>",
		--"<td width=49 color=#CC00FF size=12 ht=2>拥有邦定元宝：</td><td width=50 color=#CC00FF size=12 ht=0>  "..(mainrole.mGameMoneyBind or 0).."</td>",
	}
	V9_ContainerShenQi.updateList( var.xmlPanel:getWidgetByName("need_desc"),need_desc )
	
	--var.xmlPanel:getWidgetByName("progress"):loadTexture(string.format("V8_ContainerShenQi_%d.png",tonumber(var.shenqi[index].times)+31),ccui.TextureResType.plistType)
	var.xmlPanel:getWidgetByName("progress")._maxValue = var.shenqi[index].setting.update
	var.xmlPanel:getWidgetByName("progress")._labelformat = ""
	var.xmlPanel:getWidgetByName("progress"):setPercentWithAnimation(var.shenqi[index].times, var.shenqi[index].setting.update)
	var.xmlPanel:getWidgetByName("progress_label"):setString("进度："..math.floor((var.shenqi[index].times/var.shenqi[index].setting.update)*100).."%")
	
	local level =var.shenqi[index].level
	var.xmlPanel:getWidgetByName("show_title"):loadTexture(string.format("V8_ContainerShenQi_%d.png",tonumber(level)+122),ccui.TextureResType.plistType)
	--var.xmlPanel:getWidgetByName("show_bg"):loadTexture(string.format("V8_ContainerShenQi_%d.png",tonumber(var.shenqi[index].show)),ccui.TextureResType.plistType)
	
	for i=1,6,1 do
		var.xmlPanel:getWidgetByName("stone_"..i):loadTexture("V8_ContainerShenQi_29.png",ccui.TextureResType.plistType)
	end
	for i=1,tonumber(var.shenqi[index].stons),1 do
		var.xmlPanel:getWidgetByName("stone_"..i):loadTexture("V8_ContainerShenQi_28.png",ccui.TextureResType.plistType)
	end
	
	if var.shenqi[index].times==0 and var.shenqi[index].stons==0 and var.shenqi[index].level==0 then
		--激活神器
		var.xmlPanel:getWidgetByName("update_btn"):setVisible(false)
		var.xmlPanel:getWidgetByName("activity_btn"):setVisible(true)
		var.xmlPanel:getWidgetByName("activity_btn"):setTitleText("激活"..var.shenqi[index].title.."")
		GameUtilSenior.addHaloToButton(var.xmlPanel:getWidgetByName("activity_btn"), "btn_normal_light3")---呼吸灯
		var.xmlPanel:getWidgetByName("upgrade_btn"):setVisible(false)
		var.xmlPanel:getWidgetByName("need_desc"):setVisible(true)	
		var.xmlPanel:getWidgetByName("stone_list"):setVisible(true)
		var.xmlPanel:getWidgetByName("progress_bg"):setVisible(true)	
	elseif tonumber(var.shenqi[index].times)>=var.shenqi[index].setting.update then
		--激活结晶
		var.xmlPanel:getWidgetByName("update_btn"):setVisible(false)
		var.xmlPanel:getWidgetByName("activity_btn"):setVisible(true)
		var.xmlPanel:getWidgetByName("activity_btn"):setTitleText("激活结晶")
		GameUtilSenior.addHaloToButton(var.xmlPanel:getWidgetByName("activity_btn"), "btn_normal_light3")---呼吸灯
		var.xmlPanel:getWidgetByName("upgrade_btn"):setVisible(false)
		var.xmlPanel:getWidgetByName("need_desc"):setVisible(false)	
		var.xmlPanel:getWidgetByName("stone_list"):setVisible(true)
		var.xmlPanel:getWidgetByName("progress_bg"):setVisible(true)	
	elseif tonumber(var.shenqi[index].stons)>=6 then
		var.xmlPanel:getWidgetByName("update_btn"):setVisible(true)
		GameUtilSenior.addHaloToButton(var.xmlPanel:getWidgetByName("update_btn"), "upgrade_halo.png")---呼吸灯
		var.xmlPanel:getWidgetByName("activity_btn"):setVisible(false)
		var.xmlPanel:getWidgetByName("upgrade_btn"):setVisible(false)
		var.xmlPanel:getWidgetByName("need_desc"):setVisible(false)
		var.xmlPanel:getWidgetByName("stone_list"):setVisible(false)
		var.xmlPanel:getWidgetByName("progress_bg"):setVisible(false)
	else
		GameUtilSenior.removeHaloFromButton(var.xmlPanel:getWidgetByName("update_btn"))
		var.xmlPanel:getWidgetByName("update_btn"):setVisible(true)
		var.xmlPanel:getWidgetByName("activity_btn"):setVisible(false)
		var.xmlPanel:getWidgetByName("upgrade_btn"):setVisible(false)
		var.xmlPanel:getWidgetByName("need_desc"):setVisible(true)
		var.xmlPanel:getWidgetByName("stone_list"):setVisible(true)
		var.xmlPanel:getWidgetByName("progress_bg"):setVisible(true)
	end
	
	if var.shenqi[index].hasMax==true then
		var.xmlPanel:getWidgetByName("update_container"):setVisible(false)
		var.xmlPanel:getWidgetByName("level_full"):setVisible(true)
	else
		var.xmlPanel:getWidgetByName("update_container"):setVisible(true)
		var.xmlPanel:getWidgetByName("level_full"):setVisible(false)
	end
	
	print(var.shenqi[index].setting.res)
	var.xmlPanel:getWidgetByName("show_animal"):removeChildByName("effect")
	GameUtilSenior.addEffect(var.xmlPanel:getWidgetByName("show_animal"),"effect",4, var.shenqi[index].setting.res,false,false,true)

end

function V9_ContainerShenQi.showMapList()	
	if not var.updateData then
		var.currentIndex = var.shenqi[1].index
	end
	local list_btn = var.xmlPanel:getWidgetByName("list_btn"):setVisible(true)
	list_btn:reloadData(#var.shenqi,function( subItem )
		table.insert(var.items,subItem)
		local function  showMapDetail( sender )
			--print("var.currentIndex",sender.index)
			var.currentIndex = sender.index
			var.updateData = true
			for i,v in ipairs(var.items) do
				v:getWidgetByName("title_btn"):loadTexture("btn_"..v.index..".png",ccui.TextureResType.plistType)
			end
			sender:getWidgetByName("title_btn"):loadTexture("btn_"..sender.index.."_sel.png",ccui.TextureResType.plistType)
			V9_ContainerShenQi.showRightAnimation(subItem.tag)
		end
		subItem:getWidgetByName("title_btn"):loadTexture("btn_"..var.shenqi[subItem.tag].index..".png",ccui.TextureResType.plistType)
		---GUIFocusPoint.addUIPoint(subItem:getWidgetByName("title_btn"), showMapDetail)
		subItem.index = var.shenqi[subItem.tag].index
		subItem:setTouchEnabled(true)
		subItem:addClickEventListener(showMapDetail)
		
		--print(subItem.index,var.currentIndex)
		if subItem.index==var.currentIndex then
			--print(var.currentIndex)
			showMapDetail(subItem)
		end
	end)

end

function V9_ContainerShenQi.updateList( list,strs )
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


function V9_ContainerShenQi.handlePanelData(event)
	if event.type == "V9_ContainerShenQi" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			var.shenqi=data.shenqi
			V9_ContainerShenQi.showMapList()
		end
	end
end


function V9_ContainerShenQi.onPanelOpen(extend)
	var.group = extend.tab
	GameSocket:PushLuaTable("gui.V9_ContainerShenQi.handlePanelData",GameUtilSenior.encode({actionid = "getMessage",group=var.group}))
end

function V9_ContainerShenQi.onPanelClose()

end

return V9_ContainerShenQi