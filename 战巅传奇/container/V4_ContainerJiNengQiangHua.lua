local V4_ContainerJiNengQiangHua = {}
local var = {}
local bookIndex = 1

local lblhint = {
	"<font color=#D3C105 size=12>一级：需要技能书页：10张</font>",
	"<font color=#D3C105 size=12>二级：需要技能书页：50张</font>",
	"<font color=#D3C105 size=12>三级：需要技能书页：100张</font>",
	"<font color=#E45F09 size=12>四级：需要技能书页：200张</font>",
	"<font color=#E45F09 size=12>五级：需要技能书页：300张</font>",
	"<font color=#E45F09 size=12>六级：需要技能书页：400张</font>",
}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

local currentBookIndex = 7
local currentBookSize = 16

function V4_ContainerJiNengQiangHua.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerJiNengQiangHua.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerJiNengQiangHua.handlePanelData)

		
		var.xmlPanel:getWidgetByName("V4_ContainerJiNengQiangHua_1"):addClickEventListener(function ( sender )
			currentBookIndex = 7
			currentBookSize = 16
			var.xmlPanel:getWidgetByName("V4_ContainerJiNengQiangHua_7"):loadTexture("V4_ContainerJiNengQiangHua_7.png",ccui.TextureResType.plistType)
			var.xmlPanel:getWidgetByName("V4_ContainerJiNengQiangHua_7"):stopAllActions():setPosition(-40,10)
			V4_ContainerJiNengQiangHua.switchTo(1)
		end)
		
		var.xmlPanel:getWidgetByName("V4_ContainerJiNengQiangHua_2"):addClickEventListener(function ( sender )
			currentBookIndex = 23
			currentBookSize = 10
			var.xmlPanel:getWidgetByName("V4_ContainerJiNengQiangHua_7"):loadTexture("V4_ContainerJiNengQiangHua_23.png",ccui.TextureResType.plistType)
			var.xmlPanel:getWidgetByName("V4_ContainerJiNengQiangHua_7"):stopAllActions():setPosition(0,35)
			V4_ContainerJiNengQiangHua.switchTo(2)
		end)
		
		var.xmlPanel:getWidgetByName("V4_ContainerJiNengQiangHua_3"):addClickEventListener(function ( sender )
			currentBookIndex = 33
			currentBookSize = 10
			var.xmlPanel:getWidgetByName("V4_ContainerJiNengQiangHua_7"):loadTexture("V4_ContainerJiNengQiangHua_33.png",ccui.TextureResType.plistType)
			var.xmlPanel:getWidgetByName("V4_ContainerJiNengQiangHua_7"):stopAllActions():setPosition(0,35)
			V4_ContainerJiNengQiangHua.switchTo(3)
		end)
		
		var.xmlPanel:getWidgetByName("V4_ContainerJiNengQiangHua_43"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("npc.v4_JiNengQiangHua.handlePanelData",GameUtilSenior.encode({actionid = "qianghua",index=bookIndex}))
		end)
		
		
		local btn_info = var.xmlPanel:getWidgetByName("show_tips")
		btn_info:setTouchEnabled(true):addTouchEventListener(function(sender,eventType)
			if eventType == ccui.TouchEventType.began then
				GameSocket:dispatchEvent({
					name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "tips", visible = true, infoTable = lblhint,
				})
			elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled  then
				GameSocket:dispatchEvent({
					name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "all", visible = false })
			end
		end)
		
		V4_ContainerJiNengQiangHua.showTitleAnimation()
		V4_ContainerJiNengQiangHua.showBookAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerJiNengQiangHua.switchTo(index)
	bookIndex = index
	var.xmlPanel:getWidgetByName("V4_ContainerJiNengQiangHua_46"):loadTexture("V4_ContainerJiNengQiangHua_"..(45+index)..".png",ccui.TextureResType.plistType)
	V4_ContainerJiNengQiangHua.showBookAnimation()
end

function V4_ContainerJiNengQiangHua.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerJiNengQiangHua.showBookAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("V4_ContainerJiNengQiangHua_7")
	local startNum = 1
	local function startShowTitleBg()
	
		local filepath = string.format("V4_ContainerJiNengQiangHua_%d.png",currentBookIndex+startNum-1)
		title_animal:loadTexture(filepath,ccui.TextureResType.plistType)
		
		startNum= startNum+1
		if startNum >=currentBookSize then
			startNum =1
		end
	end
	title_animal:stopAllActions()
	title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowTitleBg)}),tonumber(currentBookSize)))
		
end




function V4_ContainerJiNengQiangHua.handlePanelData(event)
	if event.type == "V4_ContainerJiNengQiangHua" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
		end
	end
end


function V4_ContainerJiNengQiangHua.onPanelOpen(extend)
	GameSocket:PushLuaTable("gui.V4_ContainerJiNengQiangHua.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerJiNengQiangHua.onPanelClose()

end

return V4_ContainerJiNengQiangHua