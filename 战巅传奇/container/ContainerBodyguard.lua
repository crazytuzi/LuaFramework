--[[
--押送镖车功能
--]]

local ContainerBodyguard={}
local var = {}
local desp = "<font color=#B2A58B>1.只有在押送镖车周围，镖车才会前进<br>2.押送的镖车被攻击后不会停止<br>3.镖车被打碎会导致押送失败，获得部分奖励<br>4.放弃押镖没有任何奖励<br>5.押送成功后，可领取多倍奖励<br>6.打劫别人的镖车可以获得镖银奖励<br></font><font color=#FF3E3E>友情提示：当你被攻击时，可以向帮会或是好友求助！！！</font>"

function ContainerBodyguard.initView()
	var = {
		xmlPanel,

	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerBodyguard.uif");
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerBodyguard.handlePanelData)
		-- GameUtilSenior.asyncload(var.xmlPanel, "imgBg", "ui/image/panel_dart_bg.jpg")
		ContainerBodyguard.initBtns()
		ContainerBodyguard.initDartList()
		var.xmlPanel:getWidgetByName("labDesp"):setRichLabel(desp,"ContainerBodyguardHelp",16)
	end

	return var.xmlPanel
end

function ContainerBodyguard.onPanelOpen()
	GameSocket:PushLuaTable("gui.ContainerBodyguard.handlePanelData",GameUtilSenior.encode({actionid = "reqDartData",params={}}))
end

function ContainerBodyguard.onPanelClose()
	
end

function ContainerBodyguard.handlePanelData(event)
	if event.type ~= "ContainerBodyguard" then return end
	-- print(event.data)
	local data = GameUtilSenior.decode(event.data)
	if data.cmd =="updateDart" then
		 ContainerBodyguard.updatePanel(data)
	elseif data.cmd=="" then

	end
end

--刷新镖车面板数据
function ContainerBodyguard.updatePanel(data)
	var.xmlPanel:getWidgetByName("labTime"):setString(data.curData.limitTime.."分钟")
	var.xmlPanel:getWidgetByName("labAward"):setString(data.curData.awardDesp)
	var.xmlPanel:getWidgetByName("lanExp"):setString(data.curData.moneyNum)
	var.xmlPanel:getWidgetByName("labMoney"):setString(data.curData.expNum)  
	--var.xmlPanel:getWidgetByName("labYuFree"):setString(data.times)
	var.xmlPanel:getWidgetByName("labYuTimes"):setString(data.yuTimes)
	ContainerBodyguard.initDartList(data.curData.dartLev)
end

--初始化镖车列表
function ContainerBodyguard.initDartList(level)
	local function updateListDart(item)
		item:getWidgetByName("renderBg"):loadTexture("img_dart_"..item.tag,ccui.TextureResType.plistType)
		if level and level==item.tag then
			item:getWidgetByName("selectBg"):setVisible(true)
		else
			item:getWidgetByName("selectBg"):setVisible(false)
		end
	end

	local listDart = var.xmlPanel:getWidgetByName("listDart")
	listDart:reloadData(4,updateListDart):setSliderVisible(false):setTouchEnabled(false)
end

-----------------------------------------按钮操作-----------------------------------------------
local btnArrs = {"btnRefreshDart","btnStartDart"}
function ContainerBodyguard.initBtns()
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		if senderName=="btnRefreshDart" then
			GameSocket:PushLuaTable("gui.ContainerBodyguard.handlePanelData",GameUtilSenior.encode({actionid = "reqRefreshDart",params={}}))
		elseif senderName=="btnStartDart" then
			GameSocket:PushLuaTable("gui.ContainerBodyguard.handlePanelData",GameUtilSenior.encode({actionid = "reqStartDart",params={}}))
		end
	end
	for i=1,#btnArrs do
		local btn = var.xmlPanel:getWidgetByName(btnArrs[i])
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
	end
end



return ContainerBodyguard