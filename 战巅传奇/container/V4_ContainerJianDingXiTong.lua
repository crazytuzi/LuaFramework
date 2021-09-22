local V4_ContainerJianDingXiTong = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerJianDingXiTong.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerJianDingXiTong.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerJianDingXiTong.handlePanelData)

		
		--var.xmlPanel:getWidgetByName("ditu1"):addClickEventListener(function ( sender )
		--	GameSocket:PushLuaTable("npc.v4_sanrenditu.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",mapno=1}))
			
		--end)
		--var.xmlPanel:getWidgetByName("my_rank_desc"):setRichLabel("<font color='#ee1818'><font size='12'>您当前玄辰币数量为：[  </font><font size='12' color='#FFFFFF'>188</font><font size='12'><font color='#ee1818'><font size='12'> ]颗</font></font>")

		V4_ContainerJianDingXiTong.showTitleAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerJianDingXiTong.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerJianDingXiTong.handlePanelData(event)
	if event.type == "V4_ContainerJianDingXiTong" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
		end
	end
end


function V4_ContainerJianDingXiTong.onPanelOpen(extend)
	GameSocket:PushLuaTable("gui.V4_ContainerJianDingXiTong.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerJianDingXiTong.onPanelClose()

end

return V4_ContainerJianDingXiTong