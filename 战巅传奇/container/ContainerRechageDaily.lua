local ContainerRechageDaily={}
local var = {}

function ContainerRechageDaily.initView()
	var = {
		xmlPanel = nil,	
		serverData = nil,
		vcionNum=nil,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerRechageDaily.uif")
	if var.xmlPanel then
		--GameUtilSenior.asyncload(var.xmlPanel, "panelBg", "ui/image/recharge_daily.png")
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerRechageDaily.handlePanelData)

		var.vcionNum = ccui.TextAtlas:create("0123456789","image/typeface/num_4.png", 16, 20,"0")
			:addTo(var.xmlPanel)
			:align(display.CENTER, 453,333)
			:setString(0)

		local function prsBtnClick(sender)
			-- print(sender.state)
			if sender.state==2 then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
			elseif sender.state==1 then
				GameSocket:PushLuaTable("gui.ContainerRechageDaily.onPanelData", GameUtilSenior.encode({actionid = "receive"}))
			end
		end
		local btnState = var.xmlPanel:getWidgetByName("btnState"):setVisible(false)
		GUIFocusPoint.addUIPoint(btnState,prsBtnClick)
		ContainerRechageDaily.addEffect()
		
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

function ContainerRechageDaily.onPanelOpen()
	GameSocket:PushLuaTable("gui.ContainerRechageDaily.onPanelData", GameUtilSenior.encode({actionid = "reqUpdateData"}))
end

function ContainerRechageDaily.onPanelClose()
	
end

function ContainerRechageDaily.handlePanelData(event)
	if event.type ~= "ContainerRechageDaily" then return end
	local data = GameUtilSenior.decode(event.data)
	-- print(event.data)
	if data.cmd =="updateRechargeAwards" then
		ContainerRechageDaily.updatePanel(data)
	end
end

function ContainerRechageDaily.updatePanel(data)
	if not data then return end
	var.vcionNum:setString(tostring(data.againc))
	var.xmlPanel:getWidgetByName("labAllVcion"):setString("每日充值点已计入。礼包总价值："..data.dataTable.value.."充值点")
	for i=1,4 do
		local awardItem = var.xmlPanel:getWidgetByName("icon"..i)
		local param={parent=awardItem, typeId=data.dataTable.ids[i], num=data.dataTable.nums[i]}
		GUIItem.getItem(param)
	end
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

function ContainerRechageDaily.addEffect()
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
return ContainerRechageDaily