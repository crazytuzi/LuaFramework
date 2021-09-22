local ContainerWholeActivities={}
local var = {}

function ContainerWholeActivities.initView(extend)
	var = {
		xmlPanel,
		curTab=nil,
		curXmlTab=nil,
		xmlRuiShou=nil,
		xmlChongZhi=nil,
		xmlLogin=nil,
		xmlDoubleExp=nil,
		xmlLottery=nil,
		xmlZheKou=nil,
		xmlXiaoFei=nil,
		xmlLangYa=nil,
		xmlLongXin=nil,
		xmlSczb=nil,
		xmlSmsd=nil,
		tabBtnArrs={},
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerActivitiesAction.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerWholeActivities.handlePanelData)
			GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "reqTabList",params={}}))
	end
	return var.xmlPanel
end

function ContainerWholeActivities.onPanelOpen(extend)
	if extend and extend.mParam then
		-- var.teHuiIndex=extend.mParam.index
	end
end

function ContainerWholeActivities.onPanelClose()
	
end

function ContainerWholeActivities.handlePanelData(event)
	if event.type ~= "ContainerWholeActivities" then return end
	local data = GameUtilSenior.decode(event.data)
	-- print(event.data)
	if data.cmd=="updateQinDianTabs" then
		ContainerWholeActivities.initTabList(data.tabTable)
		if data.actType==2 then
			var.xmlPanel:getWidgetByName("imgTitle"):loadTexture("title_hf", ccui.TextureResType.plistType):setVisible(true)
		elseif data.actType==1 then
			var.xmlPanel:getWidgetByName("imgTitle"):loadTexture("title", ccui.TextureResType.plistType):setVisible(true)
		end
	elseif data.cmd=="updateRuiShouCount" then--跟新瑞兽活动倒计时
		ContainerWholeActivities.updateCount(var.xmlRuiShou,data.time)

	elseif data.cmd=="updateRechargeData" then
		ContainerWholeActivities.updateRechargeData(data)

	elseif data.cmd=="updateLoginData" then
		ContainerWholeActivities.updateLoginData(data)

	elseif data.cmd=="updateDoubleExpCount" then
		ContainerWholeActivities.updateCount(var.xmlDoubleExp,data.time)

	elseif data.cmd=="updateLotteryData" then
		ContainerWholeActivities.updateLotteryData(data)

	elseif data.cmd=="updateQiangGouData" then
		ContainerWholeActivities.updateQiangGouData(data)

	elseif data.cmd=="updateXiaoFeiData" then
		ContainerWholeActivities.updateXiaoFeiData(data)


	elseif data.cmd=="updateLangYaData" then
		ContainerWholeActivities.updateLangYaData(data)

	elseif data.cmd=="updateLongXinData" then
		ContainerWholeActivities.updateLongXinData(data)

	elseif data.cmd=="updateWangChengData" then
		ContainerWholeActivities.updateSczbData(data)
	elseif data.cmd=="updateupdateSmsd" then
		ContainerWholeActivities.updateSmsd(data)

	elseif data.cmd=="updateTabRed" then
		ContainerWholeActivities.updateTabRed(data)
	end
end

--初始化活动页签列表
function ContainerWholeActivities.initTabList(data)
	local function prsBtnClick(sender)
		if var.curTab then var.curTab:setBrightStyle(ccui.BrightStyle.normal) end
		if var.curXmlTab then var.curXmlTab:hide() end
		if sender.nameStr=="tabName1" then --超级瑞兽
			ContainerWholeActivities.initRuiShou()
			var.curXmlTab=var.xmlRuiShou
		elseif sender.nameStr=="tabName2" then--充值有礼
			ContainerWholeActivities.initChongZhi()
			var.curXmlTab=var.xmlChongZhi
		elseif sender.nameStr=="tabName3" then--登录有礼
			ContainerWholeActivities.initLogin()
			var.curXmlTab=var.xmlLogin
		elseif sender.nameStr=="tabName4" then--全服双倍
			ContainerWholeActivities.initDoubleExp()
			var.curXmlTab=var.xmlDoubleExp
		elseif sender.nameStr=="tabName5" then--全民探宝 
			ContainerWholeActivities.initLottery()
			var.curXmlTab=var.xmlLottery
		elseif sender.nameStr=="tabName6" then--限时抢购
			ContainerWholeActivities.initQiangGou()
			var.curXmlTab=var.xmlZheKou
		elseif sender.nameStr=="tabName7" then--消费豪礼
			ContainerWholeActivities.initXiaoFei()
			var.curXmlTab=var.xmlXiaoFei

		elseif sender.nameStr=="tabName8" then--狼牙回馈
			ContainerWholeActivities.initLangYa()
			var.curXmlTab=var.xmlLangYa
		elseif sender.nameStr=="tabName9" then--龙心回馈
			ContainerWholeActivities.initLongXin()
			var.curXmlTab=var.xmlLongXin
		elseif sender.nameStr=="tabName10" then--沙城争霸
			ContainerWholeActivities.initSczb()
			var.curXmlTab=var.xmlSczb
		elseif sender.nameStr=="tabName11" then--神秘商店
			ContainerWholeActivities.initSmsd()
			var.curXmlTab=var.xmlSmsd
		end
		sender:setBrightStyle(ccui.BrightStyle.highlight)
		var.curTab=sender
	end

	local function updateList(item)
		local itemData=data[item.tag]
		if not itemData then return end
		local btn = item:getWidgetByName("btnMode")
		if btn and itemData.name then
			btn:setTitleText(itemData.name)
			btn.nameStr=itemData.nameStr
			btn:setName(itemData.nameStr)
			var.tabBtnArrs[itemData.nameStr]=btn
			GUIAnalysis.attachEffect(btn,"outline(0e0600,1)")
			GUIFocusPoint.addUIPoint(btn,prsBtnClick)
			if not var.curTab and item.tag==1 then
				prsBtnClick(btn)
			end
			-- btn:setSwallowTouches(false)
		end
	end
	var.tabBtnArrs={}
	local tabList = var.xmlPanel:getWidgetByName("tabList")
	tabList:reloadData(#data,updateList):setSliderVisible(false):setTouchEnabled(true)
	GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "updateRedpoint",params={}}))
end

--刷新红点显示
function ContainerWholeActivities.updateTabRed(data)
	if data.name then
		local tabList = var.xmlPanel:getWidgetByName("tabList")
		if var.tabBtnArrs[data.name] then
			local btn = var.tabBtnArrs[data.name]
			btn:getWidgetByName("imgRed"):setVisible(data.show)
		end
	end
end


--------------------------------------------------------------超级瑞兽------------------------------------------------------------------
function ContainerWholeActivities.initRuiShou()
	if not var.xmlRuiShou then
		var.xmlRuiShou=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_ruishou.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlRuiShou, "tabBg", "ui/image/Activities/activities_5.jpg")
   		GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "updateRsCount",params={}}))
		var.xmlRuiShou:getWidgetByName("btnVcion"):addClickEventListener(function( sender )
			GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "reqRuiShowGo",params={}}))
		end)
	else
		var.xmlRuiShou:show()
	end
end

--刷新超级瑞兽活动剩余时间
function ContainerWholeActivities.updateCount(parent,time)
	-- local time = itemData.needTime-data.onlineTime--秒
	if not parent then return end
	local labTime=parent:getWidgetByName("labCount")
	if time>0 then
		labTime:stopAllActions()
		labTime:setString(GameUtilSenior.setTimeFormat(time*1000,8))
		labTime:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function ()
			time = time-1
			if time > 0 then
				labTime:setString(GameUtilSenior.setTimeFormat(time*1000,8))
			else
				labTime:stopAllActions()
				labTime:setString("活动已结束")
				if parent==var.xmlRuiShou then parent:getWidgetByName("Image_6"):setVisible(false) end
			end
		end)})))
	else
		labTime:setString("活动已结束")
		if parent==var.xmlRuiShou then parent:getWidgetByName("Image_6"):setVisible(false) end
	end
end

--------------------------------------------------------------充值有礼------------------------------------------------------------------
function ContainerWholeActivities.initChongZhi()
	if not var.xmlChongZhi then
		var.xmlChongZhi=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_chongzhi.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlChongZhi, "tabBg", "ui/image/Activities/activities_1.jpg")

		var.xmlChongZhi:getWidgetByName("btnChongZhi"):addClickEventListener(function( sender )
			-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
			GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "openCharge"}))
		end)

		var.xmlChongZhi:getWidgetByName("btnLing"):addClickEventListener(function( sender )
			GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "lingRechargeAwards",params={}}))
		end)
	else
		var.xmlChongZhi:show()
	end
	GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "updateChongZhiData",params={}}))
end

function ContainerWholeActivities.updateRechargeData(data)
	ContainerWholeActivities.updateCount(var.xmlChongZhi,data.time)
	for i=1,6 do
		local itemData = data.awards[i]
		local awardItem=var.xmlChongZhi:getWidgetByName("icon"..i)
		if itemData then
			awardItem:setVisible(true)
			local param={parent=awardItem, typeId=itemData.id, num=itemData.num}
			GUIItem.getItem(param)
		else
			awardItem:setVisible(false)
		end
	end

	local btnLing = var.xmlChongZhi:getWidgetByName("btnLing")
	btnLing:removeChildByName("img_bln")
	if  data.ling==0 then
		var.xmlChongZhi:getWidgetByName("btnChongZhi"):setVisible(true)
		btnLing:setVisible(false)
		var.xmlChongZhi:getWidgetByName("imgYLQ"):setVisible(false)
	elseif data.ling==1 then
		var.xmlChongZhi:getWidgetByName("btnChongZhi"):setVisible(false)
		btnLing:setVisible(true)
		GameUtilSenior.addHaloToButton(btnLing, "btn_normal_light13")
		var.xmlChongZhi:getWidgetByName("imgYLQ"):setVisible(false)
	elseif data.ling==2 then
		var.xmlChongZhi:getWidgetByName("btnChongZhi"):setVisible(false)
		btnLing:setVisible(false)
		var.xmlChongZhi:getWidgetByName("imgYLQ"):setVisible(true)
	elseif data.ling==3 then
		var.xmlChongZhi:getWidgetByName("btnChongZhi"):setVisible(false)
		btnLing:setVisible(false)
		var.xmlChongZhi:getWidgetByName("imgYLQ"):setVisible(false)
	end
end

--------------------------------------------------------------登录有礼------------------------------------------------------------------
function ContainerWholeActivities.initLogin()
	if not var.xmlLogin then
		var.xmlLogin=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_login.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlLogin, "tabBg", "ui/image/Activities/activities_2.jpg")

		var.xmlLogin:getWidgetByName("btnLing"):addClickEventListener(function( sender )
			GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "lingLoginAwards",params={}}))
		end)
	else
		var.xmlLogin:show()
	end
	GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "updateLoginData",params={}}))
end

function ContainerWholeActivities.updateLoginData(data)
	ContainerWholeActivities.updateCount(var.xmlLogin,data.time)
	for i=1,5 do
		local itemData = data.awards[i]
		local awardItem=var.xmlLogin:getWidgetByName("icon"..i)
		if itemData then
			awardItem:setVisible(true)
			local param={parent=awardItem, typeId=itemData.id, num=itemData.num}
			GUIItem.getItem(param)
		else
			awardItem:setVisible(false)
		end
	end
	if data.ling>0 then
		var.xmlLogin:getWidgetByName("btnLing"):setVisible(false)
		var.xmlLogin:getWidgetByName("imgYLQ"):setVisible(true)
	else
		var.xmlLogin:getWidgetByName("btnLing"):setVisible(true)
		var.xmlLogin:getWidgetByName("imgYLQ"):setVisible(false)
	end
end

--------------------------------------------------------------全服双倍------------------------------------------------------------------
function ContainerWholeActivities.initDoubleExp()
	if not var.xmlDoubleExp then
		var.xmlDoubleExp=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_doubleexp.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlDoubleExp, "tabBg", "ui/image/Activities/activities_7.jpg")
		GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "updateDoubleCount",params={}}))
	else
		var.xmlDoubleExp:show()
	end
	
end

--------------------------------------------------------------全民探宝------------------------------------------------------------------
function ContainerWholeActivities.initLottery()
	if not var.xmlLottery then
		var.xmlLottery=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_lottery.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlLottery, "tabBg", "ui/image/Activities/activities_9.jpg")
		GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "updateLotteryData",params={}}))
		var.xmlLottery:getWidgetByName("btnLottery"):addClickEventListener(function( sender )
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="extend_lottory"})
		end)
	else
		var.xmlLottery:show()
	end
end

function ContainerWholeActivities.updateLotteryData(data)
	ContainerWholeActivities.updateCount(var.xmlLottery,data.time)
	for i=1,4 do
		local itemData = data.equips[i]
		local awardItem=var.xmlLottery:getWidgetByName("icon"..i)
		if itemData then
			awardItem:setVisible(true)
			local param={parent=awardItem, typeId=itemData.id, num=itemData.num}
			GUIItem.getItem(param)
		else
			awardItem:setVisible(false)
		end
	end
end

--------------------------------------------------------------限时折扣------------------------------------------------------------------
function ContainerWholeActivities.initQiangGou()
	if not var.xmlZheKou then
		var.xmlZheKou=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_zhekou.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlZheKou, "tabBg", "ui/image/Activities/activities_4.jpg")
	else
		var.xmlZheKou:show()
	end
	GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "updateQiangGouData",params={}}))
end

function ContainerWholeActivities.updateQiangGouData(data)
	ContainerWholeActivities.updateCount(var.xmlZheKou,data.time)

	local function prsBtnClick(sender)
		GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "reqQiangGouGoods",params={index=sender.index}}))
	end

	local function updateList(item)
		local itemData=data.goods[item.tag]
		item:getWidgetByName("itemName"):setString(itemData.name)
		if itemData.moneyType==102 then
			item:getWidgetByName("labYuan"):setString("原价："..itemData.pricey.."元宝")
		elseif itemData.moneyType==103 then
			item:getWidgetByName("labYuan"):setString("原价："..itemData.pricey.."绑元")
		end
		item:getWidgetByName("labPrice"):setString(itemData.price)
		local btnBuy=item:getWidgetByName("btnBuy")
		btnBuy.index=item.tag
		GUIAnalysis.attachEffect(btnBuy,"outline(0e0600,1)")
		GUIFocusPoint.addUIPoint(btnBuy,prsBtnClick)

		if itemData.yuNum>0 then
			btnBuy:setVisible(true)
			item:getWidgetByName("imgYSQ"):setVisible(false)
		else
			btnBuy:setVisible(false)
			item:getWidgetByName("imgYSQ"):setVisible(true)
		end

		local param={parent=item:getWidgetByName("icon"), typeId=itemData.id, num=1}
		GUIItem.getItem(param)

		local yuNum = item:getWidgetByName("yuNum")
		if not yuNum then
			yuNum = ccui.TextAtlas:create("0123456789", "image/typeface/num_45.png", 13, 19, "0")
			:addTo(item)
			:align(display.LEFT_BOTTOM, 143,144)
			:setName("yuNum")
		end
		-- yuNum:setString(itemData.yuNum)
		yuNum:setString(itemData.num)
	end
	local zkList = var.xmlZheKou:getWidgetByName("zkList")
	zkList:reloadData(#data.goods,updateList):setSliderVisible(false):setTouchEnabled(false)
end

--------------------------------------------------------------消费豪礼------------------------------------------------------------------
function ContainerWholeActivities.initXiaoFei()
	if not var.xmlXiaoFei then
		var.xmlXiaoFei=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_xiaofei.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlXiaoFei, "tabBg", "ui/image/Activities/activities_10.jpg")
	else
		var.xmlXiaoFei:show()
	end
	GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "updateXiaoFeiData",params={}}))
end

function ContainerWholeActivities.updateXiaoFeiData(data)
	ContainerWholeActivities.updateCount(var.xmlXiaoFei,data.time)
	for i=1,#data.awards do
		local itemDatas = data.awards[i].awards
		for j=1,#itemDatas do
			local itemData = itemDatas[j]
			local awardItem=var.xmlXiaoFei:getWidgetByName("icon"..i.."_"..j)
			if itemData then
				awardItem:setVisible(true)
				local param={parent=awardItem, typeId=itemData.id, num=itemData.num}
				GUIItem.getItem(param)
			else
				awardItem:setVisible(false)
			end
		end
		if data.awards[i].name~="" then
			var.xmlXiaoFei:getWidgetByName("labName"..i):setString(data.awards[i].name):setVisible(true)
			var.xmlXiaoFei:getWidgetByName("img"..i):setVisible(false)
		else
			var.xmlXiaoFei:getWidgetByName("labName"..i):setVisible(false)
			var.xmlXiaoFei:getWidgetByName("img"..i):setVisible(true)
		end
	end
	if data.myRank>0 then  
		var.xmlXiaoFei:getWidgetByName("labMyRank"):setString("第"..data.myRank.."名")
	else
		var.xmlXiaoFei:getWidgetByName("labMyRank"):setString("未上榜")
	end
	var.xmlXiaoFei:getWidgetByName("labMyXiaoFei"):setString("已消费元宝："..data.curXiaoFei)

end

--------------------------------------------------------------狼牙回馈------------------------------------------------------------------
function ContainerWholeActivities.initLangYa()
	if not var.xmlLangYa then
		var.xmlLangYa=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_huikui.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlLangYa, "tabBg", "ui/image/Activities/activities_3.jpg")
	else
		var.xmlLangYa:show()
	end
	var.xmlLangYa:getWidgetByName("labDesp"):setString("温馨提示：活动期间内使用相应狼牙碎片后，可领取狼牙碎片")
	var.xmlLangYa:getWidgetByName("imgTitleBg"):loadTexture("img_langya", ccui.TextureResType.plistType)
	GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "updateLangYaData",params={}}))
end

function ContainerWholeActivities.updateLangYaData(data)
	ContainerWholeActivities.updateCount(var.xmlLangYa,data.time)
	local function prsBtnClick(sender)
		GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "reqLangYaAwards",params={index=sender.index}}))
	end

	local allUse = data.allUse
	local function updateList(item)
		local itemData = data.dataTable[item.tag]
		item:getWidgetByName("labDesp"):setString("使用"..itemData.name.."x"..itemData.useNum)
		local param={parent=item:getWidgetByName("icon"), typeId=itemData.id, num=itemData.num}
		GUIItem.getItem(param)
		for i=1,#itemData.awards do
			local award = itemData.awards[i]
			local awardItem=item:getWidgetByName("icon"..i)
			if award then
				awardItem:setVisible(true)
				local param={parent=awardItem, typeId=award.id, num=award.num}
				GUIItem.getItem(param)
			else
				awardItem:setVisible(false)
			end
		end
		local btnLing = item:getWidgetByName("btnLing")
		local imgYlq = item:getWidgetByName("imgYLQ")
		if itemData.ling>0 then
			imgYlq:setVisible(true)
			btnLing:setVisible(false)
			btnLing:removeChildByName("img_bln")
		else
			imgYlq:setVisible(false)
			btnLing:setVisible(true)
			if allUse>=itemData.useNum then
				btnLing:setEnabled(true)
				GameUtilSenior.addHaloToButton(btnLing, "btn_normal_light3")
			else
				btnLing:removeChildByName("img_bln")
				btnLing:setEnabled(false)
			end
		end
		btnLing.index=item.tag
		GUIFocusPoint.addUIPoint(btnLing,prsBtnClick)
	end

	local awardsList = var.xmlLangYa:getWidgetByName("awardsList")
	awardsList:reloadData(#data.dataTable,updateList):setSliderVisible(true):setTouchEnabled(true)
end

--------------------------------------------------------------龙心回馈------------------------------------------------------------------
function ContainerWholeActivities.initLongXin()
	if not var.xmlLongXin then
		var.xmlLongXin=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_huikui.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlLongXin, "tabBg", "ui/image/Activities/img_longxin_bg.jpg")
	else
		var.xmlLongXin:show()
	end
	var.xmlLongXin:getWidgetByName("labDesp"):setString("温馨提示：活动期间内使用相应龙心碎片后，可领取龙心碎片")
	var.xmlLongXin:getWidgetByName("imgTitleBg"):loadTexture("img_longxin", ccui.TextureResType.plistType)
	GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "updateLongXinData",params={}}))
end

function ContainerWholeActivities.updateLongXinData(data)
	ContainerWholeActivities.updateCount(var.xmlLongXin,data.time)
	local function prsBtnClick(sender)
		GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "reqLongXinAwards",params={index=sender.index}}))
	end

	local allUse = data.allUse
	local function updateList(item)
		local itemData = data.dataTable[item.tag]
		item:getWidgetByName("labDesp"):setString("使用"..itemData.name.."x"..itemData.useNum)
		for i=1,#itemData.awards do
			local award = itemData.awards[i]
			local awardItem=item:getWidgetByName("icon"..i)
			if award then
				awardItem:setVisible(true)
				local param={parent=awardItem, typeId=award.id, num=award.num}
				GUIItem.getItem(param)
			else
				awardItem:setVisible(false)
			end
		end
		local btnLing = item:getWidgetByName("btnLing")
		local imgYlq = item:getWidgetByName("imgYLQ")
		if itemData.ling>0 then
			imgYlq:setVisible(true)
			btnLing:setVisible(false)
			btnLing:removeChildByName("img_bln")
		else
			imgYlq:setVisible(false)
			btnLing:setVisible(true)
			if allUse>=itemData.useNum then
				GameUtilSenior.addHaloToButton(btnLing, "btn_normal_light3")
				btnLing:setEnabled(true)
			else
				btnLing:removeChildByName("img_bln")
				btnLing:setEnabled(false)
			end
		end
		btnLing.index=item.tag
		GUIFocusPoint.addUIPoint(btnLing,prsBtnClick)
	end

	local awardsList = var.xmlLongXin:getWidgetByName("awardsList")
	awardsList:reloadData(#data.dataTable,updateList):setSliderVisible(false):setTouchEnabled(true)
end


--------------------------------------------------------------沙城争霸------------------------------------------------------------------
function ContainerWholeActivities.initSczb()
	if not var.xmlSczb then
		var.xmlSczb=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_sczb.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlSczb, "tabBg", "ui/image/Activities/activities_6.jpg")
	else
		var.xmlSczb:show()
	end
	GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "updateSczbData",params={}}))
end

function ContainerWholeActivities.updateSczbData(data)
	ContainerWholeActivities.updateCount(var.xmlSczb,data.time)
	local function prsBtnClick(sender)
		GameSocket:PushLuaTable("gui.ContainerWholeActivities.onPanelData",GameUtilSenior.encode({actionid = "reqSczbAwards",params={index=sender.index}}))
	end
	local H = tonumber(os.date("%H",os.time()))
	local function updateList(item)
		local itemData = data.dataTable[item.tag]
		for i=1,#itemData.awards do
			local award = itemData.awards[i]
			local awardItem=item:getWidgetByName("icon"..i)
			if award then
				awardItem:setVisible(true)
				local param={parent=awardItem, typeId=award.id, num=award.num}
				GUIItem.getItem(param)
			else
				awardItem:setVisible(false)
			end
		end
		item:getWidgetByName("itemName"):setString("合区第"..itemData.mergeDay.."天")
		local btnLing = item:getWidgetByName("btnLing"):setVisible(false)
		local imgYlq = item:getWidgetByName("imgYLQ"):setVisible(false)
		-- btnLing.index=item.tag
		-- GUIFocusPoint.addUIPoint(btnLing,prsBtnClick)
		-- if H<21 then
		-- 	btnLing:setEnabled(false)
		-- else
		-- 	btnLing:setEnabled(true)
		-- end
		-- if itemData.ling>0 then
		-- 	imgYlq:setVisible(true)
		-- 	btnLing:setVisible(false)
		-- else
		-- 	imgYlq:setVisible(false)
		-- 	btnLing:setVisible(true)
		-- end
	end

	local cityList = var.xmlSczb:getWidgetByName("cityList")
	cityList:reloadData(#data.dataTable,updateList):setSliderVisible(false):setTouchEnabled(false)
end

--------------------------------------------------------------神秘商店------------------------------------------------------------------
function ContainerWholeActivities.initSmsd()
	if not var.xmlSmsd then
		var.xmlSmsd=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_smsd.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlSmsd, "tabBg", "ui/image/Activities/activities_8.jpg")
	else
		var.xmlSmsd:show()
	end

	local function prsBtnCall(sender)	
		GameSocket:PushLuaTable("gui.PanelMysteryStore.handlePanelData",GameUtilSenior.encode({actionid = "buy_fresh"}))	
	end
	local btnGet = var.xmlSmsd:getWidgetByName("Button_3")
	GUIFocusPoint.addUIPoint(btnGet,prsBtnCall)

	GameSocket:PushLuaTable("gui.PanelMysteryStore.handlePanelData",GameUtilSenior.encode({actionid = "getPanelData"}))
end

function ContainerWholeActivities.updateSmsd(data)
	ContainerWholeActivities.updateCount(var.xmlSmsd,data.timei)
	local time = var.xmlSmsd:getWidgetByName("labDesp2")
		if data.time>0 then
			time:setString(GameUtilSenior.setTimeFormat((data.time-os.time()-1)*1000,8))
			time:stopAllActions()
			time:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function ()
				if data.time-os.time()-1 > 0  then
					time:setString(GameUtilSenior.setTimeFormat((data.time-os.time()-1)*1000,8))
				else
					time:stopAllActions()
					GameSocket:PushLuaTable("gui.PanelMysteryStore.handlePanelData",GameUtilSenior.encode({actionid = "time_fresh"}))	
				end
			end)})))
		else
			time:setString("00时00分00秒")
		end

		local function updateList(item)
			local itemData = data.iteminfo[item.tag]
			local function LingCallBack(sender)
				GameSocket:PushLuaTable("gui.PanelMysteryStore.handlePanelData",GameUtilSenior.encode({actionid = "buy_mystery",param =itemData.index}))
			end
			local awardItem = item:getWidgetByName("icon1")
			local param={parent=awardItem , typeId=itemData.id, num = itemData.num}
			GUIItem.getItem(param)
			--item:getWidgetByName("labName"):setString(itemData.timeDesp)
			local btnLing = item:getWidgetByName("btnLing")

			local itemdef = GameSocket:getItemDefByID(itemData.id)
	
			item:getWidgetByName("itemName"):setString(itemdef.mName)

			item:getWidgetByName("txt_moneynum"):setString(itemData.moneyNum)

			if itemData.money==100 then 
				item:getWidgetByName("imgMoney"):loadTexture("coin", ccui.TextureResType.plistType)
			elseif  itemData.money==101 then 
				item:getWidgetByName("imgMoney"):loadTexture("coin_bind", ccui.TextureResType.plistType)
			elseif  itemData.money==102 then 
				item:getWidgetByName("imgMoney"):loadTexture("vcoin", ccui.TextureResType.plistType)
			else
				item:getWidgetByName("imgMoney"):loadTexture("vcoin_bind", ccui.TextureResType.plistType)
			end
			--btnLing.key = item.tag
			-- btnLing:setBright(itemData.con ~= 1)
			if itemData.con>=1 then
				btnLing:setEnabled(false)
			else
				btnLing:setEnabled(true)
			end
			--btnLing:setTitleText(itemData.ling == 1 and "已领取" or "领取")
			GUIFocusPoint.addUIPoint(btnLing , LingCallBack)
		end

		local list = var.xmlSmsd:getWidgetByName("cityList")
		list:reloadData(#data.iteminfo,updateList)

end


return ContainerWholeActivities