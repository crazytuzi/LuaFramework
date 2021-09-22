local V8_ContainerXiLian = {}
local var = {}


function V8_ContainerXiLian.initView(extend)
	var = {
		xmlPanel,
		data={},
	}
	var.data = extend.mParam.data
	var.xmlPanel = GUIAnalysis.load("ui/layout/V8_ContainerXiLian.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V8_ContainerXiLian.handlePanelData)

		
		--var.xmlPanel:getWidgetByName("ditu1"):addClickEventListener(function ( sender )
		--	GameSocket:PushLuaTable("npc.v4_shouchongditu.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",mapno=1}))
		--	
		--end)
		
		V8_ContainerXiLian.showTitleAnimation()
		
		V8_ContainerXiLian.updateList( var.xmlPanel:getWidgetByName("descList"),var.data.desc )
		V8_ContainerXiLian.updateList( var.xmlPanel:getWidgetByName("right_lists"),var.data.list )
					
		return var.xmlPanel
	end
end

function V8_ContainerXiLian.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V8_ContainerXiLian.handlePanelData(event)
	if event.type == "V8_ContainerXiLian" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			for i=1,#data.itemList,1 do
				local awardItem=var.xmlPanel:getWidgetByName("equip_"..i)
				local param={parent=awardItem, typeId=data.itemList[i].typeid, num=data.itemList[i].num}
				GUIItem.getItem(param)
				local lowSprite = cc.Sprite:create()
				lowSprite:setPosition(30,30)
				awardItem:addChild(lowSprite)
				--local animate = cc.AnimManager:getInstance():getPlistAnimateAsync(lowSprite,4, 65078, 4, ,10000,3)
				GameUtilSenior.addEffect(lowSprite,"spriteEffect",GROUP_TYPE.EFFECT,65078,false,false,true)
			end
		end
	end
end

function V8_ContainerXiLian.updateList( list,strs )
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


function V8_ContainerXiLian.onPanelOpen(extend)
	GameSocket:PushLuaTable("item.YouLong_Function.handlePanelData",GameUtilSenior.encode({actionid = "jiaqun_gift"}))
end

function V8_ContainerXiLian.onPanelClose()

end

return V8_ContainerXiLian