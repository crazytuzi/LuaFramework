local V4_ContainerFanPai = {}
local var = {}
local fanTimes = 0
local freeIndex = 0
local rmbIndex = 0

function V4_ContainerFanPai.initView(extend)
	var = {
		xmlPanel,
		rmb=0,
		tips,
		canBuy,
	}
	var.tips=extend.mParam.tips
	var.canBuy = extend.mParam.canBuy
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerFanPai.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerFanPai.handlePanelData)
		
		
		var.xmlPanel:getWidgetByName("desc_1"):setText(extend.mParam.tips)
		
		var.xmlPanel:getWidgetByName("free_fan_1"):addClickEventListener(function ( sender )
			freeIndex = 1
			V4_ContainerFanPai.showFanPaiFreeAnimation("free_fan_1")
		end)
		var.xmlPanel:getWidgetByName("free_fan_2"):addClickEventListener(function ( sender )
			freeIndex = 2
			V4_ContainerFanPai.showFanPaiFreeAnimation("free_fan_2")
		end)
		var.xmlPanel:getWidgetByName("free_fan_3"):addClickEventListener(function ( sender )
			freeIndex = 3
			V4_ContainerFanPai.showFanPaiFreeAnimation("free_fan_3")
		end)
		var.xmlPanel:getWidgetByName("free_fan_4"):addClickEventListener(function ( sender )
			freeIndex = 4
			V4_ContainerFanPai.showFanPaiFreeAnimation("free_fan_4")
		end)
		
		var.xmlPanel:getWidgetByName("rmb_fan_1"):addClickEventListener(function ( sender )
			
			rmbIndex = 1
			V4_ContainerFanPai.showFanPaiRMBAnimation("rmb_fan_1")
		end)
		var.xmlPanel:getWidgetByName("rmb_fan_2"):addClickEventListener(function ( sender )
			rmbIndex = 2
			V4_ContainerFanPai.showFanPaiRMBAnimation("rmb_fan_2")
		end)
		var.xmlPanel:getWidgetByName("rmb_fan_3"):addClickEventListener(function ( sender )
			rmbIndex = 3
			V4_ContainerFanPai.showFanPaiRMBAnimation("rmb_fan_3")
		end)
		var.xmlPanel:getWidgetByName("rmb_fan_4"):addClickEventListener(function ( sender )
			rmbIndex = 4
			V4_ContainerFanPai.showFanPaiRMBAnimation("rmb_fan_4")
		end)
		
		fanTimes = 0
		
		V4_ContainerFanPai.showTitleAnimation()
		V4_ContainerFanPai.showRightAnimation()
		
		V4_ContainerFanPai.showBorderAnimation()
		
		return var.xmlPanel
	end
end

function V4_ContainerFanPai.checkMoney()
	if GameSocket.mCharacter.mVCoinBind < 10 then
		return false
	end
	return true
end

function V4_ContainerFanPai.showRightAnimation()
	local right_tips1 = var.xmlPanel:getWidgetByName("right_tips_1")
	local startNum = 1
	local function startShowRightBg1()
	
		local filepath = string.format("panel_djsj_%d.png",startNum)
		right_tips1:loadTexture(filepath,ccui.TextureResType.plistType)
		
		startNum= startNum+1
		if startNum ==21 then
			startNum =1
		end
	end
	right_tips1:stopAllActions()
	right_tips1:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowRightBg1)}),tonumber(20)))
		
	local right_tips2 = var.xmlPanel:getWidgetByName("right_tips_2")
	local startNum = 1
	local function startShowRightBg2()
	
		local filepath = string.format("panel_djsj_%d.png",startNum)
		right_tips2:loadTexture(filepath,ccui.TextureResType.plistType)
		
		startNum= startNum+1
		if startNum ==21 then
			startNum =1
		end
	end
	right_tips2:stopAllActions()
	right_tips2:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowRightBg2)}),tonumber(20)))
		
end


function V4_ContainerFanPai.showFanPaiFreeAnimation(item)
	if fanTimes>0 then
		return;
	end
	fanTimes = 1
	local title_animal = var.xmlPanel:getWidgetByName(item)
	local startNum = 8
	local function startShowTitleBg()
	
		local filepath = string.format("V4_PanelFanPai_%d.png",startNum)
		title_animal:loadTextureNormal(filepath,ccui.TextureResType.plistType)
		title_animal:loadTexturePressed(filepath,ccui.TextureResType.plistType)
		
		startNum= startNum+1
		if startNum ==13 then
			title_animal:stopAllActions()
			title_animal:loadTextureNormal("V4_PanelFanPai_5.png",ccui.TextureResType.plistType)
			title_animal:loadTexturePressed("V4_PanelFanPai_5.png",ccui.TextureResType.plistType)
			GameSocket:PushLuaTable("npc.v4_ShenMiRen.handlePanelData",GameUtilSenior.encode({actionid = "lowAward"}))
		end
	end
	title_animal:stopAllActions()
	title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowTitleBg)}),tonumber(10)))
end

function V4_ContainerFanPai.showAllFreeAnimation(index)
	if index  == freeIndex then
		index = index + 1
		V4_ContainerFanPai.showAllFreeAnimation(index)
	end
	if index  < 5 then
		local title_animal = var.xmlPanel:getWidgetByName("free_fan_"..index)
		local startNum = 8
		local function startShowTitleBg()
		
			local filepath = string.format("V4_PanelFanPai_%d.png",startNum)
			title_animal:loadTextureNormal(filepath,ccui.TextureResType.plistType)
			title_animal:loadTexturePressed(filepath,ccui.TextureResType.plistType)
			
			startNum= startNum+1
			if startNum ==13 then
				title_animal:stopAllActions()
				title_animal:getWidgetByName("equip"):setVisible(true)
				title_animal:getWidgetByName("bg_animation"):setVisible(true)
				title_animal:loadTextureNormal("V4_PanelFanPai_5.png",ccui.TextureResType.plistType)
				title_animal:loadTexturePressed("V4_PanelFanPai_5.png",ccui.TextureResType.plistType)
				index = index + 1
				V4_ContainerFanPai.showAllFreeAnimation(index)
			end
		end
		title_animal:stopAllActions()
		title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowTitleBg)}),tonumber(10)))
	end
end


function V4_ContainerFanPai.showFanPaiRMBAnimation(item)
	if fanTimes==0 then
		GameSocket:alertLocalMsg("请先翻开上一层卡牌!", "alert")
		return
	end
	if fanTimes>1 then
		return;
	end
	local mParam = {
		name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = var.tips,
		btnConfirm = "是", btnCancel = "否",
		confirmCallBack = function ()
			--if var.rmb<10 then
			--	GameSocket:alertLocalMsg("充值点不足，无法翻卡!", "alert")
			--	return
			--end
			if not var.canBuy then
				GameSocket:alertLocalMsg("实力不足，无法翻卡!", "alert")
				return
			end
			fanTimes = 2
			local title_animal = var.xmlPanel:getWidgetByName(item):setLocalZOrder(999)
			local startNum = 13
			local function startShowTitleBg()
			
				local filepath = string.format("V4_PanelFanPai_%d.png",startNum)
				title_animal:loadTextureNormal(filepath,ccui.TextureResType.plistType)
				title_animal:loadTexturePressed(filepath,ccui.TextureResType.plistType)
				
				startNum= startNum+1
				if startNum ==18 then
					title_animal:stopAllActions()
					title_animal:loadTextureNormal("V4_PanelFanPai_3.png",ccui.TextureResType.plistType)
					title_animal:loadTexturePressed("V4_PanelFanPai_3.png",ccui.TextureResType.plistType)
					GameSocket:PushLuaTable("npc.v4_ShenMiRen.handlePanelData",GameUtilSenior.encode({actionid = "highAward"}))
				end
			end
			title_animal:stopAllActions()
			title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowTitleBg)}),tonumber(10)))
		end
	}
	GameSocket:dispatchEvent(mParam)
end


function V4_ContainerFanPai.showAllRMBAnimation(index)
	if index  == rmbIndex then
		index = index + 1
		V4_ContainerFanPai.showAllRMBAnimation(index)
	end
	if index  < 5 then
		local title_animal = var.xmlPanel:getWidgetByName("rmb_fan_"..index)
		local startNum = 13
		local function startShowTitleBg()
		
			local filepath = string.format("V4_PanelFanPai_%d.png",startNum)
			title_animal:loadTextureNormal(filepath,ccui.TextureResType.plistType)
			title_animal:loadTexturePressed(filepath,ccui.TextureResType.plistType)
			
			startNum= startNum+1
			if startNum ==18 then
				title_animal:stopAllActions()
				title_animal:getWidgetByName("equip"):setVisible(true)
				title_animal:getWidgetByName("bg_animation"):setVisible(true)
				title_animal:loadTextureNormal("V4_PanelFanPai_3.png",ccui.TextureResType.plistType)
				title_animal:loadTexturePressed("V4_PanelFanPai_3.png",ccui.TextureResType.plistType)
				index = index + 1
				V4_ContainerFanPai.showAllRMBAnimation(index)
			end
		end
		title_animal:stopAllActions()
		title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowTitleBg)}),tonumber(10)))
	end
end


function V4_ContainerFanPai.showBorderAnimation()
	local container = {"free_fan_1","free_fan_2","free_fan_3","free_fan_4","rmb_fan_1","rmb_fan_2","rmb_fan_3","rmb_fan_4",}
	for i=1,#container,1 do
		local title_animal = var.xmlPanel:getWidgetByName(container[i]):getWidgetByName("bg_animation")
		local startNum = 18
		local function startShowTitleBg()
		
			local filepath = string.format("V4_PanelFanPai_%d.png",startNum)
			title_animal:loadTexture(filepath,ccui.TextureResType.plistType)
			
			startNum= startNum+1
			if startNum ==30 then
				startNum =18
			end
		end
		title_animal:stopAllActions()
		title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowTitleBg)}),tonumber(12)))
	end
end

function V4_ContainerFanPai.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerFanPai.handlePanelData(event)
	if event.type == "V4_ContainerShenMiRen" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			var.rmb=data.rmb
		end
		if data.cmd =="lowAward" then
			local showCounter = 1
			for i=1,4,1 do
				local showAwardTypeID = 0;
				if showCounter==1 then
					showAwardTypeID = data.showitem1.type_id
				end
				if showCounter==2 then
					showAwardTypeID = data.showitem2.type_id
				end
				if showCounter==3 then
					showAwardTypeID = data.showitem3.type_id
				end
				local freeFan = var.xmlPanel:getWidgetByName("free_fan_"..i)
				if i==freeIndex then
					local equip_block = freeFan:getWidgetByName("equip")
					GUIItem.getItem({parent = equip_block,typeId = data.awardItem.type_id})
					equip_block:setVisible(true)
					freeFan:getWidgetByName("bg_animation"):setVisible(true)
				else
					if showCounter==1 then
						V4_ContainerFanPai.showAllFreeAnimation(i)
					end
					showCounter = showCounter + 1
					local equip_block = freeFan:getWidgetByName("equip")
					GUIItem.getItem({parent = equip_block,typeId = showAwardTypeID})
				end
			end
		end
		if data.cmd =="highAward" then
			local showCounter = 1
			for i=1,4,1 do
				local showAwardTypeID = 0;
				if showCounter==1 then
					showAwardTypeID = data.showitem1.type_id
				end
				if showCounter==2 then
					showAwardTypeID = data.showitem2.type_id
				end
				if showCounter==3 then
					showAwardTypeID = data.showitem3.type_id
				end
				local freeFan = var.xmlPanel:getWidgetByName("rmb_fan_"..i)
				if i==rmbIndex then
					local equip_block = freeFan:getWidgetByName("equip")
					GUIItem.getItem({parent = equip_block,typeId = data.awardItem.type_id})
					equip_block:setVisible(true)
					freeFan:getWidgetByName("bg_animation"):setVisible(true)
				else
					if showCounter==1 then
						V4_ContainerFanPai.showAllRMBAnimation(i)
					end
					showCounter = showCounter + 1
					local equip_block = freeFan:getWidgetByName("equip")
					GUIItem.getItem({parent = equip_block,typeId = showAwardTypeID})
				end
			end
		end
	end
end


function V4_ContainerFanPai.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.v4_ShenMiRen.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerFanPai.onPanelClose()

end

return V4_ContainerFanPai