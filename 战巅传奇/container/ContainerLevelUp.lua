local ContainerLevelUp = {}
local var = {}

function ContainerLevelUp.initView(extend)
	var = {
		xmlPanel,
		level=nil,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerLevelUp.uif")
	if var.xmlPanel then
		ContainerLevelUp.PanelClick()
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerLevelUp.handlePanelData)


		var.level = ccui.TextAtlas:create("0123456789", "image/typeface/num_26.png", 32, 38, "0")
			:addTo(var.xmlPanel:getWidgetByName("panelBg"))
			:align(display.CENTER, 410,135)
			:setString(0)

		for i=1,10 do
			var.xmlPanel:getWidgetByName("num"..i):loadTexture("lv0", ccui.TextureResType.plistType)
		end
	end
	return var.xmlPanel
end

function ContainerLevelUp.PanelClick()
	local function prsBtnCall(sender)	
		-- GameSocket:PushLuaTable("gui.PanelZhuanPan.handlePanelData",GameUtilSenior.encode({actionid = "choujiang", param= var.isTen }))
		GameSocket:dispatchEvent({name=GameMessageCode.EVENT_CLOSE_PANEL,str="panel_levelTip"})
	end
	local btnGet = var.xmlPanel:getWidgetByName("panelBg"):setTouchEnabled(true)--:setScale(0.5)
	GUIFocusPoint.addUIPoint(btnGet,prsBtnCall)
end

function ContainerLevelUp.onPanelOpen(extend)	
	var.xmlPanel:getWidgetByName("panelBg"):runAction(
		cca.sineOut(cca.scaleTo(0.2, 1, 1))
	)
	if extend and extend.mParam then
		var.teHuiIndex=extend.mParam.exp
		ContainerLevelUp.showExpEffect(extend.mParam.exp,extend.mParam.upLevel)	
	end
end

function ContainerLevelUp.handlePanelData(event)
	if event.type ~= "ContainerLevelUp" then return end
	local data=GameUtilSenior.decode(event.data)
	-- print(event.data)
	if data.cmd=="recycleUpLevel" then
		ContainerLevelUp.showExpEffect(exp,level)
	end

end

function ContainerLevelUp.showExpEffect(exp,level)
	local numArrs = {}
	local length = string.len(tostring(exp))
	for i=length,1,-1 do
		local curNum = string.sub(tostring(exp),i,i)
		table.insert(numArrs,curNum)
	end

	for i=1,10 do
		local numImg = var.xmlPanel:getWidgetByName("num"..i)
		if i<=length then
			numImg:setVisible(true)
		else
			numImg:setVisible(false)
		end
	end
	var.xmlPanel:getWidgetByName("numBox"):setPositionX(500-(10-length)*25)

	local index = 1
	--数字翻滚
	local function numRoll(numImg)
		local time=0
		numImg:runAction(cca.repeatForever(cca.seq({cca.delay(0.015), cca.callFunc(function ()
			time = time+1
			numImg:loadTexture("lv"..time, ccui.TextureResType.plistType)
			if time>9 then
				numImg:loadTexture("lv"..numArrs[index], ccui.TextureResType.plistType)
				numImg:stopAllActions()
				index=index+1
				if index<=length then
					local numImg = var.xmlPanel:getWidgetByName("num"..index)
					numRoll(numImg)
				end
			end
		end)})))
	end

	local function moveAct(target)
		target:runAction(cca.seq({
			cca.delay(0.5), 
			cca.cb(function() 
				target:stopAllActions()
				local numImg = var.xmlPanel:getWidgetByName("num1")
				numRoll(numImg)
			end),
		}))
	end

	moveAct(var.xmlPanel:getWidgetByName("numBox"))
	var.level:setString(level or 1)
end

return ContainerLevelUp
