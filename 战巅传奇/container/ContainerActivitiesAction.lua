--[[
--庆典活动功能
--]]

local ContainerActivitiesAction={}
local var = {}

function ContainerActivitiesAction.initView(extend)
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
		tabArrs={},
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerActivitiesAction.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerActivitiesAction.handlePanelData)
			GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "reqTabList",params={}}))
	end
	return var.xmlPanel
end

function ContainerActivitiesAction.onPanelOpen(extend)
	if extend and extend.mParam then
		-- var.teHuiIndex=extend.mParam.index
	end
	if var.tabArrs["tabName4"] then
		ContainerActivitiesAction.tabPrsBtnClick(var.tabArrs["tabName4"])
	end
end

function ContainerActivitiesAction.onPanelClose()
	
end

function ContainerActivitiesAction.handlePanelData(event)
	if event.type ~= "ContainerActivitiesAction" then return end
	local data = GameUtilSenior.decode(event.data)
	-- print(event.data)
	if data.cmd=="updateQinDianTabs" then
		ContainerActivitiesAction.initTabList(data.tabTable)
		if data.actType==2 then
			var.xmlPanel:getWidgetByName("imgTitle"):loadTexture("title_hf", ccui.TextureResType.plistType):setVisible(true)
		elseif data.actType==1 then
			var.xmlPanel:getWidgetByName("imgTitle"):loadTexture("title", ccui.TextureResType.plistType):setVisible(true)
		end
	elseif data.cmd=="updateRuiShouCount" then--跟新瑞兽活动倒计时
		ContainerActivitiesAction.updateCount(var.xmlRuiShou,data.time)

	elseif data.cmd=="updateRechargeData" then
		ContainerActivitiesAction.updateRechargeData(data)

	elseif data.cmd=="updateLoginData" then
		ContainerActivitiesAction.updateLoginData(data)

	elseif data.cmd=="updateDoubleExpCount" then
		ContainerActivitiesAction.updateCount(var.xmlDoubleExp,data.time)

	elseif data.cmd=="updateLotteryData" then
		ContainerActivitiesAction.updateLotteryData(data)

	elseif data.cmd=="updateQiangGouData" then
		ContainerActivitiesAction.updateQiangGouData(data)

	elseif data.cmd=="updateXiaoFeiData" then
		ContainerActivitiesAction.updateXiaoFeiData(data)


	elseif data.cmd=="updateLangYaData" then
		ContainerActivitiesAction.updateLangYaData(data)

	elseif data.cmd=="updateLongXinData" then
		ContainerActivitiesAction.updateLongXinData(data)

	elseif data.cmd=="updateWangChengData" then
		ContainerActivitiesAction.updateSczbData(data)
	elseif data.cmd=="updateupdateSmsd" then
		ContainerActivitiesAction.updateSmsd(data)
	end
end

function ContainerActivitiesAction.tabPrsBtnClick(sender)
	if var.curTab then var.curTab:setBrightStyle(ccui.BrightStyle.normal) end
	if var.curXmlTab then var.curXmlTab:hide() end
	if sender.nameStr=="tabName1" then --超级瑞兽
		ContainerActivitiesAction.initRuiShou()
		var.curXmlTab=var.xmlRuiShou
	elseif sender.nameStr=="tabName2" then--充值有礼
		ContainerActivitiesAction.initChongZhi()
		var.curXmlTab=var.xmlChongZhi
	elseif sender.nameStr=="tabName3" then--登录有礼
		ContainerActivitiesAction.initLogin()
		var.curXmlTab=var.xmlLogin
	elseif sender.nameStr=="tabName4" then--全服双倍
		ContainerActivitiesAction.initDoubleExp()
		var.curXmlTab=var.xmlDoubleExp
	elseif sender.nameStr=="tabName5" then--全民探宝 
		ContainerActivitiesAction.initLottery()
		var.curXmlTab=var.xmlLottery
	elseif sender.nameStr=="tabName6" then--限时抢购
		ContainerActivitiesAction.initQiangGou()
		var.curXmlTab=var.xmlZheKou
	elseif sender.nameStr=="tabName7" then--消费豪礼
		ContainerActivitiesAction.initXiaoFei()
		var.curXmlTab=var.xmlXiaoFei

	elseif sender.nameStr=="tabName8" then--狼牙回馈
		ContainerActivitiesAction.initLangYa()
		var.curXmlTab=var.xmlLangYa
	elseif sender.nameStr=="tabName9" then--龙心回馈
		ContainerActivitiesAction.initLongXin()
		var.curXmlTab=var.xmlLongXin
	elseif sender.nameStr=="tabName10" then--沙城争霸
		ContainerActivitiesAction.initSczb()
		var.curXmlTab=var.xmlSczb
	elseif sender.nameStr=="tabName11" then--神秘商店
		ContainerActivitiesAction.initSmsd()
		var.curXmlTab=var.xmlSmsd
	end
	sender:setBrightStyle(ccui.BrightStyle.highlight)
	var.curTab=sender
end

--初始化活动页签列表
function ContainerActivitiesAction.initTabList(data)
	-- local function prsBtnClick(sender)
	
	-- end

	local function updateList(item)
		local itemData=data[item.tag]
		local btn = item:getWidgetByName("btnMode")
		if btn and itemData.name then
			btn:setTitleText(itemData.name)
			btn.nameStr=itemData.nameStr
			btn:setName(itemData.nameStr)
			GUIAnalysis.attachEffect(btn,"outline(0e0600,1)")
			GUIFocusPoint.addUIPoint(btn,ContainerActivitiesAction.tabPrsBtnClick)
			if not var.curTab and item.tag==1 then
				ContainerActivitiesAction.tabPrsBtnClick(btn)
			end
		end
		var.tabArrs[itemData.nameStr]=btn
	end

	local tabList = var.xmlPanel:getWidgetByName("tabList")
	tabList:reloadData(#data,updateList):setSliderVisible(false)

	GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "updateRedpoint",params={}}))
end


--------------------------------------------------------------超级瑞兽------------------------------------------------------------------
function ContainerActivitiesAction.initRuiShou()
	if not var.xmlRuiShou then
		var.xmlRuiShou=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_ruishou.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlRuiShou, "tabBg", "ui/image/Activities/activities_5.jpg")
   		GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "updateRsCount",params={}}))
		var.xmlRuiShou:getWidgetByName("btnVcion"):addClickEventListener(function( sender )
			GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "reqRuiShowGo",params={}}))
		end)
	else
		var.xmlRuiShou:show()
	end
end

--刷新超级瑞兽活动剩余时间
function ContainerActivitiesAction.updateCount(parent,time)
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
function ContainerActivitiesAction.initChongZhi()
	if not var.xmlChongZhi then
		var.xmlChongZhi=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_chongzhi.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlChongZhi, "tabBg", "ui/image/Activities/activities_1.jpg")

		var.xmlChongZhi:getWidgetByName("btnChongZhi"):addClickEventListener(function( sender )
			-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
			GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "openCharge"}))
		end)

		var.xmlChongZhi:getWidgetByName("btnLing"):addClickEventListener(function( sender )
			GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "lingRechargeAwards",params={}}))
		end)

		local imgOne = var.xmlChongZhi:getWidgetByName("Image_1")
		if imgOne then
			imgOne:loadTexture("5", ccui.TextureResType.plistType)
		end
	else
		var.xmlChongZhi:show()
	end
	GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "updateChongZhiData",params={}}))
end

function ContainerActivitiesAction.updateRechargeData(data)
	ContainerActivitiesAction.updateCount(var.xmlChongZhi,data.time)
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
	var.xmlChongZhi:getWidgetByName("btnLing"):removeChildByName("img_bln")
	if  data.ling==0 then
		var.xmlChongZhi:getWidgetByName("btnChongZhi"):setVisible(true)
		var.xmlChongZhi:getWidgetByName("btnLing"):setVisible(false)
		var.xmlChongZhi:getWidgetByName("imgYLQ"):setVisible(false)
	elseif data.ling==1 then
		var.xmlChongZhi:getWidgetByName("btnChongZhi"):setVisible(false)
		var.xmlChongZhi:getWidgetByName("btnLing"):setVisible(true)
		GameUtilSenior.addHaloToButton(var.xmlChongZhi:getWidgetByName("btnLing"), "btn_normal_light9")
		var.xmlChongZhi:getWidgetByName("imgYLQ"):setVisible(false)
	elseif data.ling==2 then
		var.xmlChongZhi:getWidgetByName("btnChongZhi"):setVisible(false)
		var.xmlChongZhi:getWidgetByName("btnLing"):setVisible(false)
		var.xmlChongZhi:getWidgetByName("imgYLQ"):setVisible(true)
	elseif data.ling==3 then
		var.xmlChongZhi:getWidgetByName("btnChongZhi"):setVisible(false)
		var.xmlChongZhi:getWidgetByName("btnLing"):setVisible(false)
		var.xmlChongZhi:getWidgetByName("imgYLQ"):setVisible(false)
	end
end

--------------------------------------------------------------登录有礼------------------------------------------------------------------
function ContainerActivitiesAction.initLogin()
	if not var.xmlLogin then
		var.xmlLogin=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_login.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlLogin, "tabBg", "ui/image/Activities/activities_2.jpg")

		var.xmlLogin:getWidgetByName("btnLing"):addClickEventListener(function( sender )
			GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "lingLoginAwards",params={}}))
		end)
	else
		var.xmlLogin:show()
	end
	GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "updateLoginData",params={}}))
end

function ContainerActivitiesAction.updateLoginData(data)
	ContainerActivitiesAction.updateCount(var.xmlLogin,data.time)
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
		var.xmlLogin:getWidgetByName("btnLing"):removeChildByName("img_bln")
	else
		var.xmlLogin:getWidgetByName("btnLing"):setVisible(true)
		var.xmlLogin:getWidgetByName("imgYLQ"):setVisible(false)
		GameUtilSenior.addHaloToButton(var.xmlLogin:getWidgetByName("btnLing"), "btn_normal_light9")
	end
end

--------------------------------------------------------------全服双倍------------------------------------------------------------------
function ContainerActivitiesAction.initDoubleExp()
	if not var.xmlDoubleExp then
		var.xmlDoubleExp=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_doubleexp.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlDoubleExp, "tabBg", "ui/image/Activities/activities_7.jpg")
		GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "updateDoubleCount",params={}}))
	else
		var.xmlDoubleExp:show()
	end
	
end

--------------------------------------------------------------全民探宝------------------------------------------------------------------
function ContainerActivitiesAction.initLottery()
	if not var.xmlLottery then
		var.xmlLottery=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_lottery.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlLottery, "tabBg", "ui/image/Activities/activities_9.jpg")
		GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "updateLotteryData",params={}}))
		var.xmlLottery:getWidgetByName("btnLottery"):addClickEventListener(function( sender )
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="extend_lottory"})
		end)
	else
		var.xmlLottery:show()
	end
end

function ContainerActivitiesAction.updateLotteryData(data)
	ContainerActivitiesAction.updateCount(var.xmlLottery,data.time)
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
function ContainerActivitiesAction.initQiangGou()
	if not var.xmlZheKou then
		var.xmlZheKou=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_zhekou.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlZheKou, "tabBg", "ui/image/Activities/activities_4.jpg")
	else
		var.xmlZheKou:show()
	end
	GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "updateQiangGouData",params={}}))
end

function ContainerActivitiesAction.updateQiangGouData(data)
	ContainerActivitiesAction.updateCount(var.xmlZheKou,data.time)

	local function prsBtnClick(sender)
		GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "reqQiangGouGoods",params={index=sender.index}}))
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
			yuNum = ccui.TextAtlas:create("0123456789", "image/typeface/num_45.png", 22, 32, "0")
			:addTo(item)
			:align(display.LEFT_BOTTOM, 111,156)
			:setName("yuNum")
		end
		-- yuNum:setString(itemData.yuNum)
		yuNum:setString(itemData.num)
	end
	local zkList = var.xmlZheKou:getWidgetByName("zkList")
	zkList:reloadData(#data.goods,updateList):setSliderVisible(false):setTouchEnabled(false)
end

--------------------------------------------------------------消费豪礼------------------------------------------------------------------
function ContainerActivitiesAction.initXiaoFei()
	if not var.xmlXiaoFei then
		var.xmlXiaoFei=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_xiaofei.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlXiaoFei, "tabBg", "ui/image/Activities/activities_10.jpg")
	else
		var.xmlXiaoFei:show()
	end
	GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "updateXiaoFeiData",params={}}))
end

function ContainerActivitiesAction.updateXiaoFeiData(data)
	ContainerActivitiesAction.updateCount(var.xmlXiaoFei,data.time)
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
function ContainerActivitiesAction.initLangYa()
	if not var.xmlLangYa then
		var.xmlLangYa=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_huikui.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlLangYa, "tabBg", "ui/image/Activities/activities_3.jpg")
	else
		var.xmlLangYa:show()
	end
	var.xmlLangYa:getWidgetByName("imgTitleBg"):loadTexture("img_langya", ccui.TextureResType.plistType)
	GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "updateLangYaData",params={}}))
end

function ContainerActivitiesAction.updateLangYaData(data)
	ContainerActivitiesAction.updateCount(var.xmlLangYa,data.time)
	local function prsBtnClick(sender)
		GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "reqLangYaAwards",params={index=sender.index}}))
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
				GameUtilSenior.addHaloToButton(btnLing, "btn_normal_light3")
			else
				btnLing:removeChildByName("img_bln")
			end
		end
		btnLing.index=item.tag
		GUIFocusPoint.addUIPoint(btnLing,prsBtnClick)
	end

	local awardsList = var.xmlLangYa:getWidgetByName("awardsList")
	awardsList:reloadData(#data.dataTable,updateList):setSliderVisible(false):setTouchEnabled(false)
end

--------------------------------------------------------------龙心回馈------------------------------------------------------------------
function ContainerActivitiesAction.initLongXin()
	if not var.xmlLongXin then
		var.xmlLongXin=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_huikui.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlLongXin, "tabBg", "ui/image/Activities/img_longxin_bg.jpg")
	else
		var.xmlLongXin:show()
	end
	var.xmlLongXin:getWidgetByName("imgTitleBg"):loadTexture("img_longxin", ccui.TextureResType.plistType)
	GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "updateLongXinData",params={}}))
end

function ContainerActivitiesAction.updateLongXinData(data)
	ContainerActivitiesAction.updateCount(var.xmlLongXin,data.time)
	local function prsBtnClick(sender)
		GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "reqLongXinAwards",params={index=sender.index}}))
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
			else
				btnLing:removeChildByName("img_bln")
			end
		end
		btnLing.index=item.tag
		GUIFocusPoint.addUIPoint(btnLing,prsBtnClick)
	end

	local awardsList = var.xmlLongXin:getWidgetByName("awardsList")
	awardsList:reloadData(#data.dataTable,updateList):setSliderVisible(false):setTouchEnabled(false)
end


--------------------------------------------------------------沙城争霸------------------------------------------------------------------
function ContainerActivitiesAction.initSczb()
	if not var.xmlSczb then
		var.xmlSczb=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_sczb.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlSczb, "tabBg", "ui/image/Activities/activities_6.jpg")
	else
		var.xmlSczb:show()
	end
	GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "updateSczbData",params={}}))
end

function ContainerActivitiesAction.updateSczbData(data)
	ContainerActivitiesAction.updateCount(var.xmlSczb,data.time)
	local function prsBtnClick(sender)
		GameSocket:PushLuaTable("gui.ContainerActivitiesAction.onPanelData",GameUtilSenior.encode({actionid = "reqSczbAwards",params={index=sender.index}}))
	end

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
		local btnLing = item:getWidgetByName("btnLing")
		local imgYlq = item:getWidgetByName("imgYLQ")
		btnLing.index=item.tag
		GUIFocusPoint.addUIPoint(btnLing,prsBtnClick)
		if itemData.ling>0 then
			imgYlq:setVisible(true)
			btnLing:setVisible(false)
		else
			imgYlq:setVisible(false)
			btnLing:setVisible(true)
		end
	end

	local cityList = var.xmlSczb:getWidgetByName("cityList")
	cityList:reloadData(#data.dataTable,updateList):setSliderVisible(false):setTouchEnabled(false)
end

--------------------------------------------------------------神秘商店------------------------------------------------------------------
function ContainerActivitiesAction.initSmsd()
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

function ContainerActivitiesAction.updateSmsd(data)
	ContainerActivitiesAction.updateCount(var.xmlSmsd,data.timei)
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
			btnLing:setBright(itemData.con ~= 1)
			--btnLing:setTitleText(itemData.ling == 1 and "已领取" or "领取")
			GUIFocusPoint.addUIPoint(btnLing , LingCallBack)
		end

		local list = var.xmlSmsd:getWidgetByName("cityList")
		list:reloadData(#data.iteminfo,updateList)

end


return ContainerActivitiesAction