local ContainerExp = {}
local var = {}

function ContainerExp.initView()
	var = {
		xmlPanel,
		expNum,
		levNum
	}
	-- var.xmlPanel = cc.XmlLayout:widgetFromXml("ui/layout/ContainerExp/ContainerExp.xml")
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerExp.uif")
	if var.xmlPanel then
		ContainerExp.onPanelOpen()
		-- var.levNum = ccui.TextAtlas:create("0123456789", "image/typeface/num_29.png", 35, 56, "0")
		-- 	:addTo(var.xmlPanel)
		-- 	:align(display.LEFT_TOP, 540,250)
		-- 	:setString(0)
		ContainerExp.PanelClick()

		-- GameUtilSenior.runDelayCallfunc(var.xmlPanel, 0.1, function()
		-- 	GameUtilSenior.asyncload(var.xmlPanel:getParent(), "innerBg", "ui/image/makeExp_bg.jpg", true)
		-- end)

		-- var.xmlPanel:runAction(cca.seq({cca.delay(0.1), cca.callFunc(function() 
		-- 	GameUtilSenior.asyncload(var.xmlPanel:getParent(), "innerBg", "ui/layout/ContainerExp/makeExp_bg.jpg", true)
		-- end)}))
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerExp.handlePanelData)
		var.xmlPanel:getWidgetByName("imageLeft"):setScale(0.86)
		var.xmlPanel:getWidgetByName("imageRight"):setScale(0.86)
	end
	return var.xmlPanel
end

function ContainerExp.PanelClick()
	local function prsBtnCall(sender)
		GameSocket:PushLuaTable("gui.ContainerExp.handlePanelData","getMakeExp")--请求领取经验
	end
	local btnGet = var.xmlPanel:getWidgetByName("btnGet")
	GUIFocusPoint.addUIPoint(btnGet,prsBtnCall)
end

function ContainerExp.onPanelOpen()
	GameSocket:PushLuaTable("gui.ContainerExp.handlePanelData","getPanelData")--刷新面板数据
end


function ContainerExp.handlePanelData(event)
	local data=GameUtilSenior.decode(event.data)
	if event.type=="panelNeedData" then
		ContainerExp.updatePanelData(data)
	end

end
 
function ContainerExp.updatePanelData(data)
	var.xmlPanel:getWidgetByName("labelexp"):setString(data.exp)
	var.xmlPanel:getWidgetByName("labVcion"):setString(data.vcion)
	var.xmlPanel:getWidgetByName("labLev"):setString(data.upLev)
	var.xmlPanel:getWidgetByName("lab_times"):setString(data.times)

	local labTime = var.xmlPanel:getWidgetByName("lbl_time")
	--if labTime:getString()=="" then data.time=3000*1000 end --处理掉线是不现实倒计时
	if data.time>0 then
		labTime:stopAllActions()
		labTime:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function ()
			data.time = data.time - 1000
			if data.time > 0 then
				labTime:setString(GameUtilSenior.setTimeFormat(data.time,2))
			else
				labTime:stopAllActions()
			end
		end)})))
	end

end

return ContainerExp
