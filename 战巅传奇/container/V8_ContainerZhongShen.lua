local V8_ContainerZhongShen = {}
local var = {}

function V8_ContainerZhongShen.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V8_ContainerZhongShen.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V8_ContainerZhongShen.handlePanelData)
			
		--GameUtilSenior.asyncload(var.xmlPanel, "bg", "ui/image/v4_jianqiao_bg.png")
		
		 var.xmlPanel:getWidgetByName("btn_ts"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("gui.V8_ContainerZhongShen.handlePanelData",GameUtilSenior.encode({actionid = "uplv"}))
		end)
				
		--V8_ContainerZhongShen.showTitleAnimation()
		
		return var.xmlPanel
	end
end

function V8_ContainerZhongShen.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end

function V8_ContainerZhongShen.showAnimation(jianqiao_level)
		
	local equip_animation = var.xmlPanel:getWidgetByName("equip_animation")
	local startNum = 1
	local function startShowBg()
	
		local filepath = string.format("ui/image/ZhongShenLu/%d_%d.png",jianqiao_level,startNum)
		asyncload_callback(filepath, equip_animation, function(filepath, texture)
			equip_animation:loadTexture(filepath)
		end)
		
		startNum= startNum+1
		if startNum ==13 then
			startNum =1
		end
	end
	var.xmlPanel:stopAllActions()
	var.xmlPanel:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg)}),tonumber(12)))
		
end

function V8_ContainerZhongShen.updateList( list,strs )
	local t = {}
	if GameUtilSenior.isString(strs) then
		table.insert(t,strs)
	elseif GameUtilSenior.isTable(strs) then
		t = strs
	end
	list:removeAllItems()
	for i,v in ipairs(t) do
		local richLabel = GUIRichLabel.new({size = cc.size(list:getContentSize().width, 40), space=10,name = "hintMsg"..i})
		print(v)
		richLabel:setRichLabel(v,"panel_npctalk")
		list:pushBackCustomItem(richLabel)
	end
end

function V8_ContainerZhongShen.handlePanelData(event)
	if event.type == "V8_ContainerZhongShen" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			var.xmlPanel:getWidgetByName("title"):loadTexture("V8_ContainerZhongShen_"..(136+tonumber(data.level))..".png",ccui.TextureResType.plistType)
			V8_ContainerZhongShen.updateList( var.xmlPanel:getWidgetByName("attrList"),data.attrList)
			V8_ContainerZhongShen.updateList( var.xmlPanel:getWidgetByName("descList"),data.descList)
			V8_ContainerZhongShen.updateList( var.xmlPanel:getWidgetByName("upgradeList"),data.upgradeList)
			V8_ContainerZhongShen.showAnimation(math.ceil(tonumber(data.level)/2))
		end
	end
end


function V8_ContainerZhongShen.onPanelOpen(extend)
	GameSocket:PushLuaTable("gui.V8_ContainerZhongShen.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V8_ContainerZhongShen.onPanelClose()

end

return V8_ContainerZhongShen