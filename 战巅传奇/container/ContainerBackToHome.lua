local ContainerBackToHome = {}
local var = {}


function ContainerBackToHome.onPanelOpen(event)

end

function ContainerBackToHome.initView(extend)
	var = {
		items={},
		xmlPanel,
		remainTime = 5,
		map="回城",
	}
	var.remainTime = extend.mParam.remainTime
	if extend.mParam.map~=nil then
		var.map = extend.mParam.map
	end
	--GameUtilSenior.print_table(extend.mParam)
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerBackToHome.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerBackToHome.handlePanelData)
		
		--停止挂机、打怪、移动
		GameCharacter.stopAutoFight()
		GameCharacter.stopAutoPick()
		GameCharacter._mainAvatar:clearAutoMove()
		GameCharacter._autoMoving = false
		
		ContainerBackToHome.updateTips()
		
		return var.xmlPanel
	end
end

function ContainerBackToHome.updateTips()
	--print(var.map)
	var.xmlPanel:getWidgetByName("tips"):setString(var.remainTime.."秒后"..var.map.."，被攻击或移动将自动中止...")
end

function ContainerBackToHome.handlePanelData(event)
	if event.type == "ContainerBackToHome" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="remainTime" then
			--GameUtilSenior.print_table(data)
			var.remainTime = data.remainTime
			if data.map~=nil then
				var.map=data.map
			end
			ContainerBackToHome.updateTips()
		end
	end
end


function ContainerBackToHome.onPanelOpen(extend)
end

function ContainerBackToHome.onPanelClose()
	GameSocket:PushLuaTable("gui.ContainerBackToHome.handlePanelData",GameUtilSenior.encode({actionid = "stopBackToHome"}))
end

return ContainerBackToHome