local ContainerNpcMapV9 = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function ContainerNpcMapV9.onPanelOpen(event)

end

function ContainerNpcMapV9.initView(extend)
	var = {
		items={},
		xmlPanel,
		mapInfo,
	}
	var.mapInfo = extend.result.mapInfo
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerNpcMapV9.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerNpcMapV9.handlePanelData)

		ContainerNpcMapV9.showTitleAnimation()
		ContainerNpcMapV9.showBtnAnimation()
		ContainerNpcMapV9.showDropList()
		GameUtilSenior.addEffect(var.xmlPanel:getWidgetByName("boss"),"effectShuaiTou",GROUP_TYPE.CLOTH,var.mapInfo.boss,false,false,true)
		
		var.xmlPanel:getWidgetByName("duanzao_btn"):addClickEventListener(function ( sender )
			local duanzaoBtn = var.xmlPanel:getWidgetByName("duanzao_btn")
			duanzaoBtn.user_data="event:talk_"..var.mapInfo.event
			GameUtilSenior.touchlink(duanzaoBtn,"panel_npctalk",nil)
		end)
		
		var.xmlPanel:getWidgetByName("title_font"):setText(var.mapInfo.resData.talkTitle)
		
		ContainerNpcMapV9.showList()
					
		return var.xmlPanel
	end
end

function ContainerNpcMapV9.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end

function ContainerNpcMapV9.showBtnAnimation()
	local title_animal = var.xmlPanel:getWidgetByName("duanzao_btn")
	local startNum = 1
	local function startShowTitleBg()
	
		if startNum < 16 then
			local filepath = string.format("btn_%d.png",startNum)
			title_animal:loadTextureNormal(filepath,ccui.TextureResType.plistType)
		end
		
		startNum= startNum+1
		if startNum ==16 then
			startNum =1
		end
	end
	title_animal:stopAllActions()
	title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowTitleBg)}),tonumber(16)))	
end

function ContainerNpcMapV9.showDropList()
	for i=1,4 do
		if var.mapInfo.drop[i] then
			local awardItem=var.xmlPanel:getWidgetByName("equip_"..i)
			local param={parent=awardItem, typeId=tonumber(var.mapInfo.drop[i].id), num=tonumber(var.mapInfo.drop[i].num)}
			GUIItem.getItem(param)
		end		
	end
end

function ContainerNpcMapV9.showList()
	ContainerNpcMapV9.showMapInfo()
end

function ContainerNpcMapV9.showMapInfo()
	var.xmlPanel:getWidgetByName("descList"):setLocalZOrder(1)
	ContainerNpcMapV9.updateList( var.xmlPanel:getWidgetByName("descList"),var.mapInfo.str )
end

function ContainerNpcMapV9.updateList( list,strs )
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

function ContainerNpcMapV9.handlePanelData(event)
	if event.type == "v4_PanelMoDaoDuanZao" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			ContainerNpcMapV9.showMoDaoAnimation(data.data)
		end
	end
end


function ContainerNpcMapV9.onPanelOpen(extend)
	--GameSocket:PushLuaTable("npc.v4_MoDaoDuanZao.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function ContainerNpcMapV9.onPanelClose()

end

return ContainerNpcMapV9