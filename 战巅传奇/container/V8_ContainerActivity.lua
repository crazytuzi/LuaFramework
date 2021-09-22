local V8_ContainerActivity = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V8_ContainerActivity.initView(extend)
	var = {
		xmlPanel,
		currentIndex=0,
		lastIndex=0,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V8_ContainerActivity.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V8_ContainerActivity.handlePanelData)

		V8_ContainerActivity.showTitleAnimation()
		
		var.xmlPanel:getWidgetByName("btn_1"):addClickEventListener(function ( sender )
			var.currentIndex=1
			V8_ContainerActivity.showBtnPress(1)
			var.lastIndex = 1
		end)
		var.xmlPanel:getWidgetByName("btn_2"):addClickEventListener(function ( sender )
			var.currentIndex=2
			V8_ContainerActivity.showBtnPress(2)
			var.lastIndex = 2
		end)
		var.xmlPanel:getWidgetByName("btn_3"):addClickEventListener(function ( sender )
			var.currentIndex=3
			V8_ContainerActivity.showBtnPress(3)
			var.lastIndex = 3
		end)
		var.xmlPanel:getWidgetByName("btn_4"):addClickEventListener(function ( sender )
			var.currentIndex=4
			V8_ContainerActivity.showBtnPress(4)
			var.lastIndex = 4
		end)
		var.xmlPanel:getWidgetByName("btn_5"):addClickEventListener(function ( sender )
			var.currentIndex=5
			V8_ContainerActivity.showBtnPress(5)
			var.lastIndex = 5
		end)
		var.xmlPanel:getWidgetByName("btn_6"):addClickEventListener(function ( sender )
			var.currentIndex=6
			V8_ContainerActivity.showBtnPress(6)
			var.lastIndex = 6
		end)
		var.xmlPanel:getWidgetByName("btn_7"):addClickEventListener(function ( sender )
			var.currentIndex=7
			V8_ContainerActivity.showBtnPress(7)
			var.lastIndex = 7
		end)
		var.xmlPanel:getWidgetByName("btn_8"):addClickEventListener(function ( sender )
			var.currentIndex=8
			V8_ContainerActivity.showBtnPress(8)
			var.lastIndex = 8
		end)
					
		return var.xmlPanel
	end
end

function V8_ContainerActivity.showBtnPress(name)
	if var.currentIndex~=0 and var.lastIndex~=0 and var.lastIndex==var.currentIndex then
		local img = var.xmlPanel:getWidgetByName("btn_"..name)
		img.user_data="event:talk_event"..name
		GameUtilSenior.touchlink(img,"panel_npctalk",nil)
		return
	end
	for i=1,8,1 do
		var.xmlPanel:getWidgetByName("btn_"..i):loadTextureNormal("V8_ContainerActivity_btn_normal.png",ccui.TextureResType.plistType)
	end
	var.xmlPanel:getWidgetByName("btn_"..name):loadTextureNormal("V8_ContainerActivity_btn.png",ccui.TextureResType.plistType)
end

function V8_ContainerActivity.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end

function V8_ContainerActivity.showMoDaoAnimation(data)
	
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

function V8_ContainerActivity.handlePanelData(event)
	if event.type == "v4_PanelMoDaoDuanZao" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			V8_ContainerActivity.showMoDaoAnimation(data.data)
		end
	end
end


function V8_ContainerActivity.onPanelOpen(extend)
	var.currentIndex=0
	var.lastIndex=0
end

function V8_ContainerActivity.onPanelClose()

end

return V8_ContainerActivity