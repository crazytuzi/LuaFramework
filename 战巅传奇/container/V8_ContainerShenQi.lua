local V8_ContainerShenQi = {}
local var = {}

local currentTitleIndex = 0

function V8_ContainerShenQi.initView(extend)
	var = {
		xmlPanel,
		shenqi,
		biglevel=0,
		smalllevel=0,
		times=0,
		stons=0,
		items={},
	}
	--var.titleList = extend.mParam.titleList
	var.xmlPanel = GUIAnalysis.load("ui/layout/V8_ContainerShenQi.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V8_ContainerShenQi.handlePanelData)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA,V8_ContainerShenQi.handlePanelData)
		
		V8_ContainerShenQi.showTitleAnimation()
		
		--V8_ContainerShenQi.showMapList()
		
		var.xmlPanel:getWidgetByName("update_btn"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("gui.V8_ContainerShenQi.handlePanelData",GameUtilSenior.encode({actionid = "update"}))
		end)
		var.xmlPanel:getWidgetByName("activity_btn"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("gui.V8_ContainerShenQi.handlePanelData",GameUtilSenior.encode({actionid = "activity"}))
		end)
		var.xmlPanel:getWidgetByName("upgrade_btn"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("gui.V8_ContainerShenQi.handlePanelData",GameUtilSenior.encode({actionid = "upgrade"}))
		end)
		
		return var.xmlPanel
	end
end


function V8_ContainerShenQi.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	local startNum = 1
	local function startShowTitleBg()
	
		local filepath = string.format("ui/image/V8_ContainerShenQi/new_game_panel_title_%d.png",startNum)
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

function V8_ContainerShenQi.showRightAnimation(level)
	local attr_desc = {
		"<font color=#E6AE02 size=12>升级成功一次永久提升攻魔道</font> <font color=#25F00A size=12>"..var.shenqi[level].attr.."点</font>",
		"<font color=#E6AE02 size=12>升级10次激活一个神力结晶</font>",
		"<font color=#E6AE02 size=12>6个神力结晶可以将神器提升一阶</font>",
		"<font color=#F8ED16 size=12>神器提升到五阶自动开启下一个神器</font>",
	}
	V8_ContainerShenQi.updateList( var.xmlPanel:getWidgetByName("attr_desc"),attr_desc )
	
	local need_desc = {
		"<td width=49 color=#9BD826 size=12 ht=2>器灵：</td><td width=50 color=#25F00A size=12 ht=0>  1个</td>",
		"<td width=49 color=#9BD826 size=12 ht=2>成功率：</td><td width=50 color=#0C9EF9 size=12 ht=0>  "..(tonumber(var.shenqi[level].prob)/100).."%</td>",
	}
	V8_ContainerShenQi.updateList( var.xmlPanel:getWidgetByName("need_desc"),need_desc )
	
	var.xmlPanel:getWidgetByName("progress"):loadTexture(string.format("V8_ContainerShenQi_%d.png",tonumber(var.times)+31),ccui.TextureResType.plistType)
	var.xmlPanel:getWidgetByName("progress_label"):setString("进度："..((var.times/10)*100).."%")
	
	local smalllevel = var.smalllevel
	if tonumber(var.biglevel)>=level then
		smalllevel=5
	end
	if smalllevel>5 then
		smalllevel = 5
	end
	var.xmlPanel:getWidgetByName("show_title"):loadTexture(string.format("V8_ContainerShenQi_%d.png",tonumber(smalllevel)+122),ccui.TextureResType.plistType)
	var.xmlPanel:getWidgetByName("show_bg"):loadTexture(string.format("V8_ContainerShenQi_%d.png",tonumber(var.shenqi[level].show)),ccui.TextureResType.plistType)
	
	for i=1,6,1 do
		var.xmlPanel:getWidgetByName("stone_"..i):loadTexture("V8_ContainerShenQi_29.png",ccui.TextureResType.plistType)
	end
	for i=1,tonumber(var.stons),1 do
		var.xmlPanel:getWidgetByName("stone_"..i):loadTexture("V8_ContainerShenQi_28.png",ccui.TextureResType.plistType)
	end
	
	if tonumber(var.times)>=10 then
		--激活神力结晶
		var.xmlPanel:getWidgetByName("update_btn"):setVisible(false)
		var.xmlPanel:getWidgetByName("activity_btn"):setVisible(true)
		var.xmlPanel:getWidgetByName("upgrade_btn"):setVisible(false)
		var.xmlPanel:getWidgetByName("need_desc"):setVisible(false)	
		var.xmlPanel:getWidgetByName("stone_list"):setVisible(true)
		var.xmlPanel:getWidgetByName("progress_bg"):setVisible(true)	
	elseif tonumber(var.smalllevel)>5 then
		--进阶神器
		var.xmlPanel:getWidgetByName("update_btn"):setVisible(false)
		var.xmlPanel:getWidgetByName("activity_btn"):setVisible(false)
		var.xmlPanel:getWidgetByName("upgrade_btn"):setVisible(true)
		var.xmlPanel:getWidgetByName("need_desc"):setVisible(false)
		var.xmlPanel:getWidgetByName("stone_list"):setVisible(false)
		var.xmlPanel:getWidgetByName("progress_bg"):setVisible(false)
	elseif tonumber(var.stons)>=6 then
		var.xmlPanel:getWidgetByName("update_btn"):setVisible(true)
		var.xmlPanel:getWidgetByName("activity_btn"):setVisible(false)
		var.xmlPanel:getWidgetByName("upgrade_btn"):setVisible(false)
		var.xmlPanel:getWidgetByName("need_desc"):setVisible(false)
		var.xmlPanel:getWidgetByName("stone_list"):setVisible(false)
		var.xmlPanel:getWidgetByName("progress_bg"):setVisible(false)
	else
		var.xmlPanel:getWidgetByName("update_btn"):setVisible(true)
		var.xmlPanel:getWidgetByName("activity_btn"):setVisible(false)
		var.xmlPanel:getWidgetByName("upgrade_btn"):setVisible(false)
		var.xmlPanel:getWidgetByName("need_desc"):setVisible(true)
		var.xmlPanel:getWidgetByName("stone_list"):setVisible(true)
		var.xmlPanel:getWidgetByName("progress_bg"):setVisible(true)
	end
	
	if tonumber(var.biglevel)>=level then
		var.xmlPanel:getWidgetByName("update_container"):setVisible(false)
		var.xmlPanel:getWidgetByName("level_full"):setVisible(true)
	else
		var.xmlPanel:getWidgetByName("update_container"):setVisible(true)
		var.xmlPanel:getWidgetByName("level_full"):setVisible(false)
		
	end
	
	
	local right_tips = var.xmlPanel:getWidgetByName("show_animal")
	local startNum = tonumber(var.shenqi[level].show)+1
	local function startShowRightBg()
	
		local filepath = string.format("V8_ContainerShenQi_%d.png",startNum)
		right_tips:loadTexture(filepath,ccui.TextureResType.plistType)
		
		startNum= startNum+1
		if startNum ==tonumber(var.shenqi[level].show)+1+9 then
			startNum =tonumber(var.shenqi[level].show)+1
		end
	end
	right_tips:stopAllActions()
	right_tips:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowRightBg)}),tonumber(20)))
		
end

function V8_ContainerShenQi.showMapList()	
	local list_btn = var.xmlPanel:getWidgetByName("list_btn"):setVisible(true)
	list_btn:reloadData(#var.shenqi,function( subItem )
		table.insert(var.items,subItem)
		local function  showMapDetail( sender )
			for i,v in ipairs(var.items) do
				if var.biglevel>=v.tag-1 then
					v:getWidgetByName("title_btn"):loadTextureNormal(var.shenqi[v.tag].open,ccui.TextureResType.plistType)
					v:getWidgetByName("title_btn"):loadTexturePressed(var.shenqi[v.tag].sel,ccui.TextureResType.plistType)
				else
					v:getWidgetByName("title_btn"):loadTextureNormal(var.shenqi[v.tag].close,ccui.TextureResType.plistType)
					v:getWidgetByName("title_btn"):loadTexturePressed(var.shenqi[v.tag].close,ccui.TextureResType.plistType)
				end
			end
			sender:loadTextureNormal(var.shenqi[subItem.tag].select,ccui.TextureResType.plistType)
			sender:loadTexturePressed(var.shenqi[subItem.tag].select,ccui.TextureResType.plistType)
			V8_ContainerShenQi.showRightAnimation(subItem.tag)
		end
		if var.biglevel>=subItem.tag-1 then
			subItem:getWidgetByName("title_btn"):loadTextureNormal(var.shenqi[subItem.tag].open,ccui.TextureResType.plistType)
			subItem:getWidgetByName("title_btn"):loadTexturePressed(var.shenqi[subItem.tag].sel,ccui.TextureResType.plistType)
			GUIFocusPoint.addUIPoint(subItem:getWidgetByName("title_btn"), showMapDetail)
		else
			subItem:getWidgetByName("title_btn"):loadTextureNormal(var.shenqi[subItem.tag].close,ccui.TextureResType.plistType)
			subItem:getWidgetByName("title_btn"):loadTexturePressed(var.shenqi[subItem.tag].close,ccui.TextureResType.plistType)
		end
		
		local index = var.biglevel+1
		if index>6 then
			index = 6
		end
		if subItem.tag==index then
			showMapDetail(subItem:getWidgetByName("title_btn"))
		end
	end)

end

function V8_ContainerShenQi.updateList( list,strs )
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


function V8_ContainerShenQi.handlePanelData(event)
	if event.type == "V8_ContainerShenQi" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			var.shenqi=data.shenqi
			var.biglevel=data.biglevel
			var.smalllevel=data.smalllevel
			var.stons=data.stons
			var.times=data.times
			V8_ContainerShenQi.showMapList()
		end
	end
end


function V8_ContainerShenQi.onPanelOpen(extend)
	GameSocket:PushLuaTable("gui.V8_ContainerShenQi.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V8_ContainerShenQi.onPanelClose()

end

return V8_ContainerShenQi