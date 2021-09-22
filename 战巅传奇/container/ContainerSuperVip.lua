local ContainerSuperVip = {}
local var = {}

function ContainerSuperVip.initView(event)
	var = {
		xmlPanel,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerSuperVip.uif")
	if var.xmlPanel then
		GameUtilSenior.asyncload(var.xmlPanel, "img_border", "ui/image/img_supervip_bg.jpg")
		
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerSuperVip.handlePanelData)
		local str = "1.专属通道：美女客服一对一贴身服务，优先解答您的疑问及需求。\n2.专属大礼包：完善您的资料即可获得我们赠送的神秘大礼包\n3.优先权：游戏内的第一手资料优先知晓。"
		var.xmlPanel:getWidgetByName("lblinfo"):setString(str)
		var.xmlPanel:getWidgetByName("btn_charge"):addClickEventListener(function()
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = "panel_charge"})
		end)

		return var.xmlPanel
	end
end

function ContainerSuperVip.handlePanelData(event)
	if event.type == "ContainerSuperVip" then
		local pData = GameUtilSenior.decode(event.data)
		if pData then
			local lblqq = var.xmlPanel:getWidgetByName("lblqq")
			lblqq:setString(pData.qqinfo)
		end
	end
end
function ContainerSuperVip.onPanelOpen()
	GameSocket:PushLuaTable("gui.ContainerSuperVip.handlePanelData",GameUtilSenior.encode({actionid = "fresh",tag = GameCCBridge.getPlatformId()}))	
end

function ContainerSuperVip.onPanelClose()
	
end
return ContainerSuperVip
