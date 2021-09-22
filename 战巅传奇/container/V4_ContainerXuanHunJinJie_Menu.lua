local V4_ContainerXuanHunJinJie_Menu = {}
local var = {}

local mapList = {}

local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerXuanHunJinJie_Menu.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerXuanHunJinJie_Menu.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerXuanHunJinJie_Menu.handlePanelData)
		
		var.xmlPanel:getWidgetByName("xh_switch_btn"):addClickEventListener(function ( sender )
			var.xmlPanel:getWidgetByName("xh_btn"):setVisible(true)
			var.xmlPanel:getWidgetByName("xz_btn"):setVisible(false)
		end)
		var.xmlPanel:getWidgetByName("xz_switch_btn"):addClickEventListener(function ( sender )
			var.xmlPanel:getWidgetByName("xh_btn"):setVisible(false)
			var.xmlPanel:getWidgetByName("xz_btn"):setVisible(true)
		end)
		
		var.xmlPanel:getWidgetByName("xh_btn"):addClickEventListener(function ( sender )
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "v4_panel_xuanhunjinjie_xz"})
		end)
		var.xmlPanel:getWidgetByName("xz_btn"):addClickEventListener(function ( sender )
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "v4_panel_xuanhunjinjie_xh"})
		end)

		V4_ContainerXuanHunJinJie_Menu.showTitleAnimation()
		V4_ContainerXuanHunJinJie_Menu.showRightAnimation()
					
		return var.xmlPanel
	end
end


function V4_ContainerXuanHunJinJie_Menu.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerXuanHunJinJie_Menu.showRightAnimation()
		
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


function V4_ContainerXuanHunJinJie_Menu.handlePanelData(event)
	if event.type == "V4_ContainerXuanHunJinJie_Menu" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			mapList = data.mapList
			V4_ContainerXuanHunJinJie_Menu.showUI()
		end
	end
end


function V4_ContainerXuanHunJinJie_Menu.onPanelOpen(extend)
end

function V4_ContainerXuanHunJinJie_Menu.onPanelClose()

end

return V4_ContainerXuanHunJinJie_Menu