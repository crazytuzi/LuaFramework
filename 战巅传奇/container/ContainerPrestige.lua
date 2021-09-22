local ContainerPrestige = {}
local var = {}

local despGW ={
	[1]="<font color=#E7BA52 size=18>一 声望获得途径：</font>",
	[2]="<font color=#f1e8d0>   1. 除魔任务</font>",
	[3]="<font color=#f1e8d0>   2. 声望兑换</font>",
	[4]="<font color=#f1e8d0>   3. 商城购买</font>",
    [5]="<font color=#f1e8d0>    </font>",
	[6]="<font color=#E7BA52 size=18>二 每日俸禄发放：</font>",
	[7]="<font color=#f1e8d0>   每天22:00,通过邮件发放对应官位俸禄</font>",
}

local despGY ={
	[1]="<font color=#E7BA52 size=18>官印说明：</font>",
	[2]="<font color=#f1e8d0>1.官职达到相应等级,可使用荣誉值兑换官印</font>",
	[3]="<font color=#f1e8d0>2.每次兑换的官印可以使用7天</font>",
	[4]="<font color=#f1e8d0>3.荣誉值可以通过在定时活动获得</font>",
	[5]="<font color=#f1e8d0>4.官印兑换后效果持续7天</font>",
	[6]="<font color=#f1e8d0>5.兑换多个官印时替换掉当前的效果</font>",
}

local btnTabName = {
	"btn_tab_post", "btn_tab_chop"
}

function ContainerPrestige.initView(extend)
	var = {
		xmlPanel,
		curTab,
		xmlGW=nil,
		xmlGY=nil,
		tabContent,
		richNeed=nil,
		richNeed2=nil,
		shopSwData=nil,
		gyData=nil,
		xmlBuyHonour=nil,
		fireworks=nil,
		selectGy=nil,
		curSelectIdx = 1,
		buffIndex=0,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerPrestige.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerPrestige.handlePanelData)
		ContainerPrestige.initTabs()

		var.xmlGW:getWidgetByName("curWf"):setVisible(false)
		var.xmlGW:getWidgetByName("curMf"):setVisible(false)
		var.xmlGW:getWidgetByName("nextWf"):setVisible(false)
		var.xmlGW:getWidgetByName("nextMf"):setVisible(false)
		var.xmlGW:getWidgetByName("curDesp4"):setVisible(false)
		var.xmlGW:getWidgetByName("curDesp5"):setVisible(false)
		var.xmlGW:getWidgetByName("nextDesp4"):setVisible(false)
		var.xmlGW:getWidgetByName("nextDesp5"):setVisible(false)
		return var.xmlPanel
	end
end

function ContainerPrestige.onPanelOpen()

end

function ContainerPrestige.onPanelClose()

end

function ContainerPrestige.handlePanelData(event)
	if event.type ~= "ContainerPrestige" then return end
	local data = GameUtilSenior.decode(event.data)
	-- print(event.data)
	if data.cmd =="senderShopWsData" then
		var.shopSwData={}
		var.shopSwData = data.data
		ContainerPrestige.initSwShop()
	elseif data.cmd=="exchangeSwSucceed" then
		ContainerPrestige.updateExchangeSucceed(data)
	elseif data.cmd=="updateGuanWei" then
		ContainerPrestige.updateGuanWeiShow(data)

	elseif data.cmd=="updateGuanYinList" then
		ContainerPrestige.initGuanYinList(data.dataList)
	elseif data.cmd=="updateGuanYin" then
		var.gyData={}
		var.gyData=data
		var.buffIndex=data.buffIndex
		ContainerPrestige.updateGuanYin(data.dataGy[data.curGyLev])
		if GameSocket.mNetBuff[GameCharacter.mID] then
			local buffData = GameSocket.mNetBuff[GameCharacter.mID][data.buffId]
			ContainerPrestige.updateCount(buffData)
		end
	elseif data.cmd=="senderBuyHonourData" then
		ContainerPrestige.initBuyHonour(data)

	elseif data.cmd=="showReplaceTip" then
		ContainerPrestige.showReplaceTip()

	end

end

function ContainerPrestige.initTabs()
	local imgTitle = var.xmlPanel:getWidgetByName("imgTitle")
	local function pressTabV(sender)
		local tag = sender:getTag()
		if tag==1 then
			ContainerPrestige.initGuanWei()
			imgTitle:loadTexture("title_gw",ccui.TextureResType.plistType)
		elseif tag==2 then
			ContainerPrestige.initGuanYin()
			imgTitle:loadTexture("title_gy",ccui.TextureResType.plistType)
		end
	end
	var.tablistv = var.xmlPanel:getWidgetByName("tablistv")
	var.tablistv:addTabEventListener(pressTabV)
	var.tablistv:setSelectedTab(1)
	var.tablistv:getParent():setLocalZOrder(10)

	for i,v in ipairs(btnTabName) do
		var.tablistv:getItemByIndex(i):setName(v)
	end
end

------------------------------------------------------------------官位------------------------------------------------------------------
function ContainerPrestige.initGuanWei()
	if var.xmlGY then var.xmlGY:hide() end
	if var.xmlBuyHonour then var.xmlBuyHonour:hide() end
	if not var.xmlGW then
		var.tabContent=var.xmlPanel:getWidgetByName("tabContent")
		var.xmlGW = GUIAnalysis.load("ui/layout/ContainerPrestige_guanwei.uif")
				:addTo(var.tabContent):align(display.BOTTOM_LEFT, 0, 0)
				:show()
		GameUtilSenior.asyncload(var.xmlPanel, "imgGZ", "ui/image/staff_2.jpg")

		ContainerPrestige.initGwBtns()

		var.xmlGW:getWidgetByName("btnDesp"):setTouchEnabled(true)
		ContainerPrestige.initDesp(var.xmlGW,"btnDesp",despGW)
	else
		var.xmlGW:show()
	end
	GameSocket:PushLuaTable("gui.ContainerPrestige.onPanelData",GameUtilSenior.encode({actionid = "reqSwData",params={}}))
	if var.selectGy then
		var.selectGy:getWidgetByName("imgSelect"):setVisible(false)
		var.selectGy=nil
	end
end

local btnGwArrs = {"btnJump","btnGwUp","btnDhSw"}
function ContainerPrestige.initGwBtns()
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		-- print(senderName)
		if senderName=="btnJump" then
			var.tablistv:setSelectedTab(2)
		elseif senderName=="btnGwUp" then
			GameSocket:PushLuaTable("gui.ContainerPrestige.onPanelData",GameUtilSenior.encode({actionid = "reqShengGuan",params={}}))
		elseif senderName=="btnDhSw" then
			GameSocket:PushLuaTable("gui.ContainerPrestige.onPanelData",GameUtilSenior.encode({actionid = "exchangeSw",params={}}))
		end
	end
	for i=1,#btnGwArrs do
		local btn = var.xmlGW:getWidgetByName(btnGwArrs[i])
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
	end


end

--等级兑换声望成功后刷新相关数据
function ContainerPrestige.updateExchangeSucceed(data)
	var.xmlGW:getWidgetByName("labCurLev"):setString(data.curLevel)
	var.xmlGW:getWidgetByName("labNextLev"):setString(data.curLevel-1)
	var.xmlGW:getWidgetByName("labGetExp"):setString(data.exchangeSw)
	local btnUp = var.xmlGW:getWidgetByName("btnGwUp")
	if data.curSw>=data.upNeedSw then
		var.xmlGW:getWidgetByName("labCurSw"):setString(data.curSw):setColor(GameBaseLogic.getColor(0xB2A58B))
		if data.curGwLev and data.curGwLev < 19 then--满级20级
			GameUtilSenior.addHaloToButton(btnUp, "btn_normal_light13")
		end
	else
		var.xmlGW:getWidgetByName("labCurSw"):setString(data.curSw):setColor(GameBaseLogic.getColor(0xEF2F00))
		btnUp:removeChildByName("img_bln")
	end
	var.xmlGW:getWidgetByName("labNeedSw"):setString(data.upNeedSw)
end

--打开官位页签刷新数据
function ContainerPrestige.updateGuanWeiShow(data)
	ContainerPrestige.updateExchangeSucceed(data.dataSw)

	var.xmlGW:getWidgetByName("curWg"):setString(data.curData.dc.."-"..data.curData.dcmax)
	var.xmlGW:getWidgetByName("curMg"):setString(data.curData.mc.."-"..data.curData.mcmax)
	var.xmlGW:getWidgetByName("curDg"):setString(data.curData.sc.."-"..data.curData.scmax)
	var.xmlGW:getWidgetByName("curWf"):setString(data.curData.ac.."-"..data.curData.acmax)
	var.xmlGW:getWidgetByName("curMf"):setString(data.curData.mac.."-"..data.curData.macmax)
	var.xmlGW:getWidgetByName("curFL"):setString(data.curData.giveMoney.."金币")
	if data.curData.imgName then
		var.xmlGW:getWidgetByName("imgCurName"):loadTexture(data.curData.imgName, ccui.TextureResType.plistType):setVisible(true)
		var.xmlGW:getWidgetByName("labWu"):setVisible(false)
	else
		var.xmlGW:getWidgetByName("imgCurName"):loadTexture(data.curData.imgName, ccui.TextureResType.plistType):setVisible(false)
		var.xmlGW:getWidgetByName("labWu"):setVisible(true)
	end

	var.xmlGW:getWidgetByName("nextWg"):setString(data.nextData.dc.."-"..data.nextData.dcmax)
	var.xmlGW:getWidgetByName("nextMg"):setString(data.nextData.mc.."-"..data.nextData.mcmax)
	var.xmlGW:getWidgetByName("nextDg"):setString(data.nextData.sc.."-"..data.nextData.scmax)
	var.xmlGW:getWidgetByName("nextWf"):setString(data.nextData.ac.."-"..data.nextData.acmax)
	var.xmlGW:getWidgetByName("nextMf"):setString(data.nextData.mac.."-"..data.nextData.macmax)
	var.xmlGW:getWidgetByName("nextFL"):setString(data.nextData.giveMoney.."金币")
	if data.nextData.imgName then
		var.xmlGW:getWidgetByName("imgNextName"):loadTexture(data.nextData.imgName, ccui.TextureResType.plistType)
	end
	var.curSelectIdx = math.ceil(data.curGwLev/2)
	var.curSelectIdx = GameUtilSenior.bound(1,var.curSelectIdx,var.curSelectIdx)

	if data.curGwLev>0 then
		-- var.xmlGW:getWidgetByName("btnJump"):setTitleText("官印"..((data.curGwLev+1)-(data.curGwLev+1)%2)/2):setVisible(true)
		var.xmlGW:getWidgetByName("btnJump"):setTitleText(data.curGyName):setVisible(true)
	else
		var.xmlGW:getWidgetByName("labWu"):setVisible(true)
		var.xmlGW:getWidgetByName("imgCurName"):setVisible(false)
	end
	-- var.xmlGW:getWidgetByName("nextDH"):setString("官印"..((data.curGwLev+2)-(data.curGwLev+2)%2)/2)
	var.xmlGW:getWidgetByName("nextDH"):setString(data.nextGyName)

	if data.curGwLev>=20 then
		var.xmlGW:getWidgetByName("imgNextName"):setVisible(false)
		var.xmlGW:getWidgetByName("labMax"):setVisible(true):setString("已满级")
		var.xmlGW:getWidgetByName("nextWg"):setString("已满级")
		var.xmlGW:getWidgetByName("nextMg"):setString("已满级")
		var.xmlGW:getWidgetByName("nextDg"):setString("已满级")
		var.xmlGW:getWidgetByName("nextFL"):setString("已满级")
		var.xmlGW:getWidgetByName("nextDH"):setString("已满级")
	else
		var.xmlGW:getWidgetByName("imgNextName"):setVisible(true)
		var.xmlGW:getWidgetByName("labMax"):setVisible(false)
	end
	if data.up then
		local fireworks = cc.Sprite:create():addTo(var.xmlGW):pos(278.83, 326.2)
		--local animate = cc.AnimManager:getInstance():getPlistAnimateAsync(fireworks,4,50022,4,1)
		GameUtilSenior.addEffect(fireworks,"spriteEffect",GROUP_TYPE.EFFECT,50022,false,false,true)
	end
end


--快捷购买声望
function ContainerPrestige.initSwShop()
	local listSW = var.xmlGW:getWidgetByName("listSW")
	listSW:reloadData(#var.shopSwData,ContainerPrestige.updateShop)
end

function ContainerPrestige.updateShop(item)
	local itemData = var.shopSwData[item.tag]
	item:getWidgetByName("labName"):setString(itemData.name)
	item:getWidgetByName("labPrice"):setString(itemData.money)
	local awardItem=item:getWidgetByName("icon")
	local param={parent=awardItem , typeId=itemData.id}
	GUIItem.getItem(param)

	local function prsBtnItem(sender)
		GameSocket:PushLuaTable("gui.ContainerPrestige.onPanelData",GameUtilSenior.encode({actionid = "swBuy",params={index=sender.storeId}}))
	end
	local btnBuy = item:getWidgetByName("btnBuy")
	btnBuy.storeId=itemData.storeId
	GUIFocusPoint.addUIPoint(btnBuy , prsBtnItem)
	GUIAnalysis.attachEffect(btnBuy,"outline(076900,1)")
end


------------------------------------------------------------------官印------------------------------------------------------------------
function ContainerPrestige.initGuanYin()
	if var.xmlGW then var.xmlGW:hide() end
	if not var.xmlGY then
		var.tabContent=var.xmlPanel:getWidgetByName("tabContent")
		var.xmlGY = GUIAnalysis.load("ui/layout/ContainerPrestige_guanyin.uif")
				:addTo(var.tabContent):align(display.BOTTOM_LEFT, 0, 0)
				:show()
		GameUtilSenior.asyncload(var.xmlPanel, "imgGY", "ui/image/staff.jpg")
		var.xmlGY:getWidgetByName("btnDesp"):setTouchEnabled(true)
		ContainerPrestige.initDesp(var.xmlGY,"btnDesp",despGY)

		ContainerPrestige.initGyBtns()

		var.richNeed=GUIRichLabel.new({size=cc.size(300,0), space=3, name="richWidget"})
		var.richNeed:addTo(var.xmlGY):pos(304,155)
		local text = "<font color=#E5DDCA>正八品校尉正八品校尉</font><font color=#30ff00>(未完成)</font>"
		var.richNeed:setRichLabel(text,"ContainerPrestige",20)

		var.richNeed2=GUIRichLabel.new({size=cc.size(300,0), space=3, name="richWidget"})
		var.richNeed2:addTo(var.xmlGY):pos(304,124)
		local text = "<font color=#E5DDCA>20000/60000</font><font color=#30ff00>(未完成)</font>"
		var.richNeed2:setRichLabel(text,"ContainerPrestige",20)
		var.xmlGY:getWidgetByName("btnDown"):setRotation(180)
	else
		var.xmlGY:show()
	end
	GameSocket:PushLuaTable("gui.ContainerPrestige.onPanelData",GameUtilSenior.encode({actionid = "reqGyData",params={}}))
	-- ContainerPrestige.initGuanYinList(nil)
	-- ContainerPrestige.updateGuanYin(nil)
end

local btnGyArrs = {"btnDH","btnGetRy","btnUp","btnDown"}
function ContainerPrestige.initGyBtns()
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		if senderName=="btnDH" then
			GameSocket:PushLuaTable("gui.ContainerPrestige.onPanelData",GameUtilSenior.encode({actionid = "reqShengYin",params={level=var.curSelectIdx,pass=0}}))
		elseif senderName=="btnGetRy" then
			if var.xmlBuyHonour and var.xmlBuyHonour:isVisible() then
				var.xmlBuyHonour:hide()
			else
				GameSocket:PushLuaTable("gui.ContainerPrestige.onPanelData",GameUtilSenior.encode({actionid = "reqBuyHonourData",params={}}))
			end
		elseif senderName=="btnUp" then
			var.xmlGY:getWidgetByName("listGY"):moveToNextItem()
		elseif senderName=="btnDown" then
			var.xmlGY:getWidgetByName("listGY"):moveToPreItem()
		end
	end
	for i=1,#btnGyArrs do
		local btn = var.xmlGY:getWidgetByName(btnGyArrs[i])
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
	end
end

function ContainerPrestige.initGuanYinList(data)
	local function prsBtnClick(sender)
		var.curSelectIdx = sender.tag
		if var.gyData and var.gyData.dataGy and var.gyData.dataGy[sender.tag] then
			ContainerPrestige.updateGuanYin(var.gyData.dataGy[sender.tag])
		end
		if var.selectGy then
			var.selectGy:getWidgetByName("imgSelect"):setVisible(false)
		end
		sender:getWidgetByName("imgSelect"):setVisible(true)
		var.selectGy=sender
		if sender.tag==var.buffIndex then
			var.xmlGY:getWidgetByName("labBuffDesp"):setVisible(true)
			var.xmlGY:getWidgetByName("labBuffTime"):setVisible(true)
		else
			var.xmlGY:getWidgetByName("labBuffDesp"):setVisible(false)
			var.xmlGY:getWidgetByName("labBuffTime"):setVisible(false)
		end
	end

	local function updateList(item)
		item:setTouchEnabled(true)
		GUIFocusPoint.addUIPoint(item,prsBtnClick)
		if item.tag == var.curSelectIdx then
			prsBtnClick(item)
		end
		item:getWidgetByName("icon"):loadTexture(tostring(item.tag),ccui.TextureResType.plistType)
		item:getWidgetByName("imgSelect"):setVisible(var.curSelectIdx==item.tag)
	end

	local listGY = var.xmlGY:getWidgetByName("listGY")
	listGY:reloadData(#data,updateList):setSliderVisible(false)
	var.dataCount = math.ceil(#data/9)
	listGY:autoMoveToIndex(var.curSelectIdx)
end

--官印动画
function ContainerPrestige.successAnimate(id)
	if id=="" then return end
	if not var.fireworks then
		var.fireworks = cc.Sprite:create():addTo(var.xmlGY):pos(0,0)
		var.fireworks:setBlendFunc({src=gl.SRC_ALPHA,dst=gl.ONE})
	end
	var.fireworks:stopAllActions()
	--local animate = cc.AnimManager:getInstance():getPlistAnimateAsync(var.fireworks,4,id,4,10000,4)
	GameUtilSenior.addEffect(var.fireworks,"spriteEffect",GROUP_TYPE.EFFECT,id,false,false,true)
	if true then
		var.fireworks:pos(528,320)
		-- var.fireworks:runAction(cca.loop(
		-- 		cca.seq({
		-- 			cc.EaseInOut:create(cca.moveBy(0.8, 0, 13),1),
		-- 			cc.EaseInOut:create(cca.moveBy(0.5, 0, -13),1),
		-- 		})
		-- 	)
		-- )
	end
end

function ContainerPrestige.updateGuanYin(data)
	if not data then return end
	ContainerPrestige.successAnimate(data.effectid)
	-- var.xmlGY:getWidgetByName("labName"):setString("官印"..math.ceil(data.gwLevel/2))
	var.xmlGY:getWidgetByName("labName"):setString(data.name)
	var.xmlGY:getWidgetByName("labDesp"):setString("PK伤害:"..(data.addS/100).."%")
	var.xmlGY:getWidgetByName("labDesp2"):setString("PK免伤:"..(data.addM/100).."%")
	var.xmlGY:getWidgetByName("labDesp3"):setString("攻击增加:"..(data.addAct/100).."%"):setVisible(false)
	var.xmlGY:getWidgetByName("labJie"):setString("")
	-- print(data.curGyLev)
	local num = math.ceil(data.gwLevel / 2)
	GameUtilSenior.asyncload(var.xmlGY, "imgBigShow", "ui/image/Official/img_gy"..num..".png")--设置官印展示图  #FF3E3E
	if var.gyData.curRy>=data.needRy then
		local text = "<font color=#E5DDCA>"..var.gyData.curRy.."/"..data.needRy.."</font>".."<font color=#30ff00>(已达成)</font>"
		var.richNeed2:setRichLabel(text,"ContainerPrestige",20)
	else
		local text2 = "<font color=#FF3E3E>"..var.gyData.curRy.."</font>".."<font color=#E5DDCA>/"..data.needRy.."</font>".."<font color=#FF3E3E>(未达成)</font>"
		var.richNeed2:setRichLabel(text2,"ContainerPrestige",20)
	end
	if var.gyData.curGwLev>=data.gwLevel then
		local text3 = "<font color=#E5DDCA>"..data.gwName.."</font>".."<font color=#30ff00>(已达成)</font>"
		var.richNeed:setRichLabel(text3,"ContainerPrestige",20)
	else
		local text4 = "<font color=#E5DDCA>"..data.gwName.."</font>".."<font color=#FF3E3E>(未达成)</font>"
		var.richNeed:setRichLabel(text4,"ContainerPrestige",20)
	end
	if var.curSelectIdx and var.curSelectIdx==var.buffIndex then
		var.xmlGY:getWidgetByName("labBuffDesp"):setVisible(true)
		var.xmlGY:getWidgetByName("labBuffTime"):setVisible(true)
	else
		var.xmlGY:getWidgetByName("labBuffDesp"):setVisible(false)
		var.xmlGY:getWidgetByName("labBuffTime"):setVisible(false)
	end
end

function ContainerPrestige.showReplaceTip()
	local mParam = {
		name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "兑换新的官印将替换掉现有的官印，是否继续？",
		btnConfirm = "是", btnCancel = "否",
		confirmCallBack = function ()
			GameSocket:PushLuaTable("gui.ContainerPrestige.onPanelData",GameUtilSenior.encode({actionid = "reqShengYin",params={level=var.curSelectIdx,pass=1}}))
		end
	}
	GameSocket:dispatchEvent(mParam)
end

--buff倒计时
function ContainerPrestige.updateCount(buffData)
	if not buffData then
		var.xmlGY:getWidgetByName("labBuffDesp"):setVisible(false)
		var.xmlGY:getWidgetByName("labBuffTime"):setVisible(false)
		return
	end
	local time = buffData.timeRemain-(os.time()-buffData.starttime)
	local labTime=var.xmlGY:getWidgetByName("labBuffTime")
	if time>0 then
		labTime:stopAllActions()
		labTime:setString(GameUtilSenior.setTimeFormat(time*1000,8))
		labTime:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function ()
			time = time-1
			if time > 0 then
				labTime:setString(GameUtilSenior.setTimeFormat(time*1000,8))
			else
				labTime:stopAllActions()
			end
		end)})))
	else

	end
end

----------------------------------------------------快捷购买荣誉--------------------------------------------------------
function ContainerPrestige.initBuyHonour(data)
	if not var.xmlBuyHonour then
		var.xmlBuyHonour = GUIAnalysis.load("ui/layout/ContainerPrestige_buyHonour.uif")
				:addTo(var.xmlGY):align(display.CENTER, 520, 340)
				:show()
		GameUtilSenior.asyncload(var.xmlBuyHonour, "imgBg", "ui/image/img_rybuy_bg.png")
		local function prsBtnItem(sender)
			var.xmlBuyHonour:hide()
		end
		GUIFocusPoint.addUIPoint(var.xmlBuyHonour:getWidgetByName("btnback"), prsBtnItem)
		var.xmlBuyHonour:getWidgetByName("btnChongZhi"):addClickEventListener(function (sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
		end)
	else
		var.xmlBuyHonour:show()
	end
	var.xmlBuyHonour:getWidgetByName("lblVcoin"):setString(data.curVcion)
	var.xmlBuyHonour:getWidgetByName("lblBVcoin"):setString(data.curBVcion)

	local listData = data.data
	local function updateBuyHonour(item)
		local itemData = listData[item.tag]
		item:getWidgetByName("labName"):setString(itemData.name)
		item:getWidgetByName("labPrice"):setString(itemData.money)
		local awardItem=item:getWidgetByName("icon")
		local param={parent=awardItem , typeId=itemData.id}
		GUIItem.getItem(param)

		local function prsBtnItem(sender)
			GameSocket:PushLuaTable("gui.ContainerPrestige.onPanelData",GameUtilSenior.encode({actionid = "reqBuyHonour",params={index=sender.storeId}}))
		end
		local btnBuy = item:getWidgetByName("btnBuy")
		btnBuy.storeId=itemData.storeId
		GUIFocusPoint.addUIPoint(btnBuy , prsBtnItem)
		GUIAnalysis.attachEffect(btnBuy,"outline(0e0600,1)")
	end
	local listBuyHonour = var.xmlBuyHonour:getWidgetByName("listBuyHonour")
	listBuyHonour:reloadData(#listData,updateBuyHonour):setSliderVisible(false)
end

--------------------问号说明-------------------------
function ContainerPrestige.initDesp(xmlPanel,btnName,despTable)
	local btnDesp=xmlPanel:getWidgetByName(btnName)
	btnDesp:addTouchEventListener(function (pSender, touchType)
		if touchType == ccui.TouchEventType.began then
			ContainerPrestige.guanZhiDesp(despTable)
		elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then
			GDivDialog.handleAlertClose()
		end
	end)
end

function ContainerPrestige.guanZhiDesp(despTable)
	local mParam = {
	name = GameMessageCode.EVENT_PANEL_ON_ALERT,
	panel = "tips",
	infoTable = despTable,
	visible = true,
	}
	GameSocket:dispatchEvent(mParam)

end


return ContainerPrestige