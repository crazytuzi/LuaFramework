local ContainerRechargeGift={}
local var = {}

function ContainerRechargeGift.initView()
	var = {
		xmlPanel = nil,	
		serverData = nil,
		vcionNum=nil,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerRechargeGift.uif")
	if var.xmlPanel then
		--GameUtilSenior.asyncload(var.xmlPanel, "panelBg", "ui/image/recharge_daily.png")
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerRechargeGift.handlePanelData)

		var.vcionNum = ccui.TextAtlas:create("0123456789","image/typeface/num_4.png", 16, 20,"0")
			:addTo(var.xmlPanel)
			:align(display.CENTER, 469,330)
			:setString(0)

		local function prsBtnClick(sender)
			-- print(sender.state)
			if sender.state==2 then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
			elseif sender.state==1 then
				GameSocket:PushLuaTable("gui.ContainerRechargeGift.onPanelData", GameUtilSenior.encode({actionid = "receive"}))
			end
		end
		local btnState = var.xmlPanel:getWidgetByName("btnState"):setVisible(false)
		GUIFocusPoint.addUIPoint(btnState,prsBtnClick)
		
		local startNum = 1
		local function startShowBg()
			
			local filepath = string.format("%d.png",startNum)
			var.xmlPanel:getWidgetByName("libao_bg"):loadTexture(filepath, ccui.TextureResType.plistType)
				
			startNum= startNum+1
			if startNum ==13 then
				startNum =1
			end
		end
		var.xmlPanel:getWidgetByName("libao_bg"):stopAllActions()
		var.xmlPanel:getWidgetByName("libao_bg"):runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg)}),tonumber(13)))

	end
	return var.xmlPanel
end

function ContainerRechargeGift.onPanelOpen()
	GameSocket:PushLuaTable("gui.ContainerRechargeGift.onPanelData", GameUtilSenior.encode({actionid = "reqUpdateData"}))
end

function ContainerRechargeGift.onPanelClose()
	
end

function ContainerRechargeGift.handlePanelData(event)
	if event.type ~= "ContainerRechargeGift" then return end
	local data = GameUtilSenior.decode(event.data)
	-- print(event.data)
	if data.cmd =="updateRechargeAwards" then
		ContainerRechargeGift.updatePanel(data)
	end
end

function ContainerRechargeGift.updatePanel(data)
	if not data then return end
	var.vcionNum:setString(tostring(data.againc))
	var.xmlPanel:getWidgetByName("labAllVcion"):setString("礼包总价值："..data.dataTable.value.."充值")
	--[[
	for i=1,4 do
		local awardItem = var.xmlPanel:getWidgetByName("icon"..i)
		local param={parent=awardItem, typeId=data.dataTable.ids[i], num=data.dataTable.nums[i]}
		GUIItem.getItem(param)
	end
	]]
	
	local function updateList(item)
		local tag = item.tag
		local num = 1
		if data.dataTable.nums[tag] then
			num = data.dataTable.nums[tag]
		end
		local param = {
			parent = item,
			typeId=data.dataTable.ids[tag], 
			num=num,
			compare = true
		}
		GUIItem.getItem(param)
	end
	
	local listBag = var.xmlPanel:getWidgetByName("listBag")
	listBag:reloadData(#data.dataTable.ids,updateList)--:setSliderVisible(false)
	
	local btnState = var.xmlPanel:getWidgetByName("btnState")
	if data.againc==0 and data.ling==0 then
		btnState:loadTextures("btn_lqjl.png", "btn_lqjl.png", "", ccui.TextureResType.plistType)
		btnState.state=1--标记为领取
		GameUtilSenior.addHaloToButton(btnState, "light_hole.png")
	end
	if data.againc>0 and data.ling==0 then
		if data.dataTable.need==700 or data.dataTable.need==600 then
			btnState:loadTextures("btn_cdxq.png", "btn_cdxq.png", "", ccui.TextureResType.plistType)
		else
			btnState:loadTextures("btn_jxcz.png", "btn_jxcz.png", "", ccui.TextureResType.plistType)
		end
		btnState.state=2--继续充值
		btnState:removeChildByName("img_bln")
	end
	if data.hideBtn then
		btnState:setVisible(false)
	else
		btnState:setVisible(true)
	end
	var.xmlPanel:getWidgetByName("imgYlq"):setVisible(data.hideBtn)
end

return ContainerRechargeGift