local V4_ContainerCangJianShanZhuang = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerCangJianShanZhuang.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerCangJianShanZhuang.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerCangJianShanZhuang.handlePanelData)

		
		var.xmlPanel:getWidgetByName("V4_ContainerCangJianShanZhuang_2"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_CangJianShanZhuang.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",mapno=1}))
		end)
		
		--var.xmlPanel:getWidgetByName("my_rank_desc"):setRichLabel("<font color='#ee1818'><font size='12'>您当前玄辰币数量为：[  </font><font size='12' color='#FFFFFF'>188</font><font size='12'><font color='#ee1818'><font size='12'> ]颗</font></font>")

		V4_ContainerCangJianShanZhuang.showTitleAnimation()
		V4_ContainerCangJianShanZhuang.showRightAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerCangJianShanZhuang.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end



function V4_ContainerCangJianShanZhuang.showRightAnimation()
		
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

function V4_ContainerCangJianShanZhuang.handlePanelData(event)
	if event.type == "V4_ContainerCangJianShanZhuang" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
		end
	end
end


function V4_ContainerCangJianShanZhuang.onPanelOpen(extend)
	GameSocket:PushLuaTable("gui.V4_ContainerCangJianShanZhuang.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerCangJianShanZhuang.onPanelClose()

end

return V4_ContainerCangJianShanZhuang