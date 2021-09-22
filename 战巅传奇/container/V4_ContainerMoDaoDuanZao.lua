local V4_ContainerMoDaoDuanZao = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerMoDaoDuanZao.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerMoDaoDuanZao.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerMoDaoDuanZao.handlePanelData)

		V4_ContainerMoDaoDuanZao.showTitleAnimation()
		
		var.xmlPanel:getWidgetByName("duanzao_btn"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_MoDaoDuanZao.handlePanelData",GameUtilSenior.encode({actionid = "exchange"}))
		end)
					
		return var.xmlPanel
	end
end

function V4_ContainerMoDaoDuanZao.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end

function V4_ContainerMoDaoDuanZao.showMoDaoAnimation(data)
	
	GUIItem.getItem({parent = var.xmlPanel:getWidgetByName("equip"),typeId = data.typeid,mShowEquipFlag=true})
	
	var.xmlPanel:getWidgetByName("desc"):setRichLabel("<font color='#15C42D' size='12'>元宝："..data.needVcoin.." </font><br /><font size='12' color='#15C42D'>玄辰币："..data.needBindGameMoney.."</font><br /><font size='12' color='#15C42D'>RMB："..data.needBindVcoin.."</font>")
	
	local fashion = var.xmlPanel:getWidgetByName("fashion")
	
	local maxPicID = 0
	for i=1,100,1 do
		local filepath = string.format("ui/image/MoDao_NPC/%d%02d.png",data.res,i)
		if not cc.FileUtils:getInstance():isFileExist(filepath) then
			break
		else
			maxPicID = i
		end
	end
	
	local startNum = 0
	local function startShowBg()
	
		local filepath = string.format("ui/image/MoDao_NPC/%d%02d.png",data.res,startNum)
		asyncload_callback(filepath, fashion, function(filepath, texture)
			fashion:loadTexture(filepath)
		end)
		
		startNum= startNum+1
		if startNum ==maxPicID+1 then
			startNum =0
		end
	end
	var.xmlPanel:stopAllActions()
	var.xmlPanel:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg)}),tonumber(maxPicID+1)))
end

function V4_ContainerMoDaoDuanZao.handlePanelData(event)
	if event.type == "v4_PanelMoDaoDuanZao" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			V4_ContainerMoDaoDuanZao.showMoDaoAnimation(data.data)
		end
	end
end


function V4_ContainerMoDaoDuanZao.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.v4_MoDaoDuanZao.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerMoDaoDuanZao.onPanelClose()

end

return V4_ContainerMoDaoDuanZao