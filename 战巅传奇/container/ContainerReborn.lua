local ContainerReborn = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function ContainerReborn.onPanelOpen(event)

end

function ContainerReborn.initView(extend)
	var = {
		items={},
		xmlPanel,
		boxTab,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerReborn.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerReborn.handlePanelData)

		var.boxTab = var.xmlPanel:getWidgetByName("box_tab")
		var.boxTab:getParent():setLocalZOrder(10)
		var.boxTab:addTabEventListener(ContainerReborn.pushTabButtons)
		var.boxTab:setItemMargin(3)
		
		ContainerReborn.showTitleAnimation()
		ContainerReborn.showLeftAnimation()
		
		var.xmlPanel:getWidgetByName("update_btn"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("gui.ContainerReborn.handlePanelData",GameUtilSenior.encode({actionid = "reqZhuanSheng"}))
		end)
		
		--ContainerReborn.showList()
		ContainerReborn.updateGameMoney()
		
		local hideIndex = {2,4,6,7}
		local opened = GameSocket:checkFuncOpenedByID(10015)
		if not opened then
			table.insert(hideIndex,4)
		end
		local openedReborn = GameSocket:checkFuncOpenedByID(10014)
		if not openedReborn then
			table.insert(hideIndex,5)
		end
		--暂时不显示时装
		--table.insert(hideIndex,2)
		var.boxTab:hideTab(hideIndex)
		var.boxTab:setSelectedTab(5)
				
		return var.xmlPanel
	end
end

function ContainerReborn.pushTabButtons(sender)
	local opened, level, funcName
	opened = true
	local tag = sender:getTag()
	if tag ~= 5 and tag ~= 6 and tag~=7 and tag~=8 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="main_avatar",tab=tag})
	end	
	--if tag==5 then
	--	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "container_reborn"})
	--	return
	--end
	if tag==6 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "container_my_hunhuan"})
		return
	end
	if tag==7 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "container_my_zuji"})
		return
	end
	if tag==8 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_skill"})
		return
	end
end

--金币刷新函数
function ContainerReborn:updateGameMoney()
	local panel = var.xmlPanel
	if panel then
		local mainrole = GameSocket.mCharacter
		local moneyLabel = {
			{name="big_title_yb_text",btn="big_title_yb_btn",	pre=GameConst.str_vcoin,	value =	mainrole.mVCoin or 0	,	icon = "icon_coin"},
			{name="big_title_hmb_text",btn="big_title_hmb_btn",	pre=GameConst.str_vcoinb,	value =	mainrole.mVCoinBind or 0,	icon = "icon_coin_bind"},
			{name="big_title_jb_text",btn="big_title_jb_btn",	pre=GameConst.str_money,	value =	mainrole.mGameMoney or 0,	icon = "icon_money"},
			{name="lblBMoney",	pre=GameConst.str_moneyb,	value =	mainrole.mGameMoneyBind or 0,	icon = "icon_money"},
		}
		--建临时表遍历设属性
		for _,v in ipairs(moneyLabel) do
			if panel:getWidgetByName(v.name) then
				panel:getWidgetByName(v.name):setString(v.value)
				panel:getWidgetByName(v.btn):addClickEventListener( function (sender)
					GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
				end)
			end
		end
	end
end

function ContainerReborn.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("character_animal")
	local startNum = 1
	local function startShowTitleBg()
		
		title_animal:loadTexture(string.format("ContainerReborn_chr_%d.png",startNum), ccui.TextureResType.plistType)
		
		startNum= startNum+1
		if startNum ==13 then
			startNum =1
		end
	end
	title_animal:stopAllActions()
	title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowTitleBg)}),tonumber(18)))
		
end


function ContainerReborn.showLeftAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("left_animal")
	local startNum = 1
	local function startShowTitleBg()
		
		title_animal:loadTexture(string.format("ContainerReborn_desc_%d.png",startNum), ccui.TextureResType.plistType)
		
		startNum= startNum+1
		if startNum ==18 then
			startNum =1
		end
	end
	title_animal:stopAllActions()
	title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowTitleBg)}),tonumber(20)))
		
end


function ContainerReborn.showGeZiAnimation(index,startNumValue,endNumValue)
		
	local title_animal = var.xmlPanel:getWidgetByName("gezi_"..index)
	local startNum = startNumValue
	local function startShowTitleBg()
		
		title_animal:loadTexture(string.format("ContainerReborn_%d.png",startNum), ccui.TextureResType.plistType)
		
		startNum= startNum+1
		if startNum ==endNumValue+1 then
			startNum =startNumValue
		end
	end
	title_animal:stopAllActions()
	title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowTitleBg)}),tonumber(18)))
		
end


function ContainerReborn.updateList( list,strs )
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

function ContainerReborn.showMessage(msg)
	ContainerReborn.updateList( var.xmlPanel:getWidgetByName("attrList"),msg.attrList )
	ContainerReborn.updateList( var.xmlPanel:getWidgetByName("needList"),msg.needList )
	for i=1,tonumber(msg.maxLevel),1 do
		if var.xmlPanel:getWidgetByName("gezi_"..i) then
			var.xmlPanel:getWidgetByName("gezi_"..i):setVisible(true)
		end
	end
	local line1 = msg.curLevel
	if line1>10 then
		line1 = 10
	end
	for i=1,line1 do
		ContainerReborn.showGeZiAnimation(i,14,25)
	end
	local line2 = msg.curLevel
	if line2>20 then
		line2 = 20
	end
	for i=11,line2 do
		ContainerReborn.showGeZiAnimation(i-10,26,37)
	end
	local line3 = msg.curLevel
	if line3>30 then
		line3 = 30
	end
	for i=21,line3 do
		ContainerReborn.showGeZiAnimation(i-20,38,49)
	end
end

function ContainerReborn.handlePanelData(event)
	if event.type == "ContainerReborn" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="updateZhuanSheng" then
			ContainerReborn.showMessage(data)
		end
	end
end


function ContainerReborn.onPanelOpen(extend)
	GameSocket:PushLuaTable("gui.ContainerReborn.handlePanelData",GameUtilSenior.encode({actionid = "reqZsData"}))
end

function ContainerReborn.onPanelClose()

end

return ContainerReborn