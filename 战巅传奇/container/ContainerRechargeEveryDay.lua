local ContainerRechargeEveryDay={}
local var = {}

function ContainerRechargeEveryDay.initView()
	var = {
		xmlPanel = nil,	
		serverData = nil,
		vcionNum=nil,
		vcionDay=nil,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerRechargeEveryDay.uif")
	if var.xmlPanel then
		--GameUtilSenior.asyncload(var.xmlPanel, "panelBg", "ui/image/recharge_daily.png")
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerRechargeEveryDay.handlePanelData)

		var.vcionNum = ccui.TextAtlas:create("0123456789","image/typeface/num_4.png", 16, 20,"0")
			:addTo(var.xmlPanel)
			:align(display.CENTER, 595,334)
			:setString(0)
			
		
		var.vcionDay = ccui.TextAtlas:create("0123456789","image/typeface/num_4.png", 16, 20,"0")
			:addTo(var.xmlPanel)
			:align(display.CENTER, 437,334)
			:setString(0)

		local function prsBtnClick(sender)
			-- print(sender.state)
			if sender.state==2 then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
			elseif sender.state==1 then
				GameSocket:PushLuaTable("gui.ContainerRechargeEveryDay.onPanelData", GameUtilSenior.encode({actionid = "receive"}))
			end
		end
		local btnState = var.xmlPanel:getWidgetByName("btnState"):setVisible(false)
		GUIFocusPoint.addUIPoint(btnState,prsBtnClick)
		ContainerRechargeEveryDay.addEffect()
		
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

function ContainerRechargeEveryDay.onPanelOpen()
	GameSocket:PushLuaTable("gui.ContainerRechargeEveryDay.onPanelData", GameUtilSenior.encode({actionid = "reqUpdateData"}))
end

function ContainerRechargeEveryDay.onPanelClose()
	
end

function ContainerRechargeEveryDay.handlePanelData(event)
	if event.type ~= "ContainerRechargeEveryDay" then return end
	local data = GameUtilSenior.decode(event.data)
	-- print(event.data)
	if data.cmd =="updateRechargeAwards" then
		ContainerRechargeEveryDay.updatePanel(data)
	end
end

function ContainerRechargeEveryDay.updatePanel(data)
	if not data then return end
	var.vcionNum:setString(tostring(data.againc))
	var.vcionDay:setString(tostring(data.day))
	var.xmlPanel:getWidgetByName("labAllVcion"):setString("中断充值将失去后续资格")
	for i=1,4 do
		local awardItem = var.xmlPanel:getWidgetByName("icon"..i)
		local param={parent=awardItem, typeId=data.dataTable.ids[i], num=data.dataTable.nums[i]}
		GUIItem.getItem(param)
	end
	local btnState = var.xmlPanel:getWidgetByName("btnState")
	if data.btn==2 then
		btnState:loadTextures("btn_lqjl.png", "btn_lqjl.png", "", ccui.TextureResType.plistType)
		btnState.state=1--标记为领取
		GameUtilSenior.addHaloToButton(btnState, "light_hole.png")
	end
	if data.btn==1 then
		if data.dataTable.need==700 or data.dataTable.need==600 then
			btnState:loadTextures("btn_cdxq.png", "btn_cdxq.png", "", ccui.TextureResType.plistType)
		else
			btnState:loadTextures("btn_jxcz.png", "btn_jxcz.png", "", ccui.TextureResType.plistType)
		end
		btnState.state=2--继续充值
		btnState:removeChildByName("img_bln")
	end
	if data.ling==1 then
		btnState:setVisible(false)
	else
		btnState:setVisible(true)
	end
	var.xmlPanel:getWidgetByName("imgYlq"):setVisible(data.hideBtn)
end

function ContainerRechargeEveryDay.addEffect()
	for i=1,4 do
		local awardItem = var.xmlPanel:getWidgetByName("icon"..i)
		local effectSprite = cc.Sprite:create()
			:setAnchorPoint(cc.p(0.5,0.5))
			:setPosition(cc.p(29,28))
			:addTo(awardItem)
			:setLocalZOrder(10)
		--cc.AnimManager:getInstance():getPlistAnimateAsync(effectSprite,4, 65078, 4, 0, 5)
		GameUtilSenior.addEffect(effectSprite,"spriteEffect",GROUP_TYPE.EFFECT,65078,false,false,true)
		effectSprite:setBlendFunc({src=gl.SRC_ALPHA,dst=gl.ONE})
	end
end
return ContainerRechargeEveryDay