local V4_ContainerShaChengZhuanShu = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerShaChengZhuanShu.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerShaChengZhuanShu.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerShaChengZhuanShu.handlePanelData)

		var.xmlPanel:getWidgetByName("exchange_1"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_ShaChengZhuanShu.handlePanelData",GameUtilSenior.encode({actionid = "enterMap"}))
		end)

		
		V4_ContainerShaChengZhuanShu.showTitleAnimation()
		V4_ContainerShaChengZhuanShu.showRightAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerShaChengZhuanShu.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerShaChengZhuanShu.showRightAnimation()
		
	local right_tips = var.xmlPanel:getWidgetByName("right_tips")
	local startNum = 1
	local function startShowRightBg()
	
		local filepath = string.format("panel_djsj_%d.png",startNum)
		right_tips:loadTexture(filepath,ccui.TextureResType.plistType)
		
		startNum= startNum+1
		if startNum ==21 then
			startNum =1
		end
	end
	right_tips:stopAllActions()
	right_tips:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowRightBg)}),tonumber(20)))
		
end


function V4_ContainerShaChengZhuanShu.onPanelOpen(extend)
end

function V4_ContainerShaChengZhuanShu.onPanelClose()

end

return V4_ContainerShaChengZhuanShu