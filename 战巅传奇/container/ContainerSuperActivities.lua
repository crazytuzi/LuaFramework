--[[
--超值回馈功能-精彩活动
--]]

local ContainerSuperActivities={}
local var = {}

function ContainerSuperActivities.initView(extend)
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
		xmlZhuanPan=nil,
		xmlRecharge=nil,
		tabArrs={},
		tabBtnArrs={},
		isTen=false,
		curAngle=0,--当前指针所在的角度
		yuTimes=0,--剩余抽奖次数
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerSuperActivities.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerSuperActivities.handlePanelData)
		--GameSocket:PushLuaTable("gui.ContainerSuperActivities.onPanelData",GameUtilSenior.encode({actionid = "reqTabList",params={}}))
	end
	return var.xmlPanel
end
--
function ContainerSuperActivities.onPanelOpen(extend)
	
	GameSocket:PushLuaTable("gui.ContainerSuperActivities.onPanelData",GameUtilSenior.encode({actionid = "reqTabList",params={}}))
end

function ContainerSuperActivities.onPanelClose()
end

function ContainerSuperActivities.handlePanelData(event)
	if event.type ~= "ContainerSuperActivities" and event.type ~= "PanelZhuanPan" then return end
	local data = GameUtilSenior.decode(event.data)
	-- print(event.data)
	if data.cmd=="updateJingCaiTabs" then
		ContainerSuperActivities.initTabList(data.tabTable)
	elseif data.cmd=="updateRuiShouCount" then--跟新瑞兽活动倒计时
		ContainerSuperActivities.updateCount(var.xmlRuiShou,data.time)

	elseif data.cmd=="updateczData" then--充值
		ContainerSuperActivities.updateRechargeData(data)
		
	elseif data.cmd=="updatexfData" then--消费
		ContainerSuperActivities.updateLoginData(data)

	elseif data.cmd=="updateDoubleExpCount" then--双倍
		ContainerSuperActivities.updateCount(var.xmlDoubleExp,data.time)
	elseif data.cmd=="updatejsczData" then--jisu
		ContainerSuperActivities.updatejsczData(data)
	elseif data.cmd=="updateTabRed" then---显示红点
		ContainerSuperActivities.updateTabRed(data)
	elseif data.cmd=="updateLangYaData" then
		ContainerSuperActivities.updateLangYaData(data)	
	elseif data.cmd=="updateLongXinData" then
		ContainerSuperActivities.updateLongXinData(data)
	elseif data.cmd=="updateLotteryData" then
		ContainerSuperActivities.updateLotteryData(data)
	elseif data.cmd=="updateQiangGouData" then
		ContainerSuperActivities.updateQiangGouData(data)
	elseif data.cmd=="updateRechargeRankData" then
		ContainerSuperActivities.updateRechargeRankData(data)
	------------------------------
	elseif data.cmd=="updateRecord" then
		if data.curWorldRecord then
			ContainerSuperActivities.updateContent(data.curWorldRecord,"worldList",236,2,false,18, true)
		end
		var.xmlZhuanPan:getWidgetByName("labYuTimes"):setString("剩余次数："..data.yuTimes.."次")
		var.yuTimes=data.yuTimes
		ContainerSuperActivities.updateCount(var.xmlZhuanPan,data.time)
	elseif data.cmd=="updateShowItems" then
		ContainerSuperActivities.updateShowItems(data.dataTable)
	elseif data.cmd=="startRotate" then
		ContainerSuperActivities.PointRotate(data.index)
	elseif data.cmd=="updateYuTimes" then
		var.xmlZhuanPan:getWidgetByName("labYuTimes"):setString("剩余次数："..data.yuTimes.."次")
		var.yuTimes=data.yuTimes
		if data.time then
			ContainerSuperActivities.updateCount(var.xmlZhuanPan,data.time)
		end
	elseif data.cmd=="openStartBtn" then
		var.xmlZhuanPan:getWidgetByName("btnGet"):setEnabled(true)
	end

end

function ContainerSuperActivities.tabPrsBtnClick(sender)

	if var.curTab then 
		var.curTab:setBrightStyle(ccui.BrightStyle.normal) 
		var.curTab:setTitleColor(cc.c3b(195, 173, 136))
	end
	if var.curXmlTab then var.curXmlTab:hide() end
	if sender.nameStr=="tabName1" then --超级瑞兽
		ContainerSuperActivities.initRuiShou()
		var.curXmlTab=var.xmlRuiShou
	elseif sender.nameStr=="tabName2" then--充值
		ContainerSuperActivities.initChongZhi()
		var.curXmlTab=var.xmlChongZhi
	elseif sender.nameStr=="tabName3" then-- 消费
		ContainerSuperActivities.initLogin()
		var.curXmlTab=var.xmlLogin
	elseif sender.nameStr=="tabName4" then--全服双倍
		ContainerSuperActivities.initDoubleExp()
		var.curXmlTab=var.xmlDoubleExp
	elseif sender.nameStr=="tabName5" then--全民探宝 
		ContainerSuperActivities.initLottery()
		var.curXmlTab=var.xmlLottery
	elseif sender.nameStr=="tabName6" then--限时抢购
		ContainerSuperActivities.initQiangGou()
		var.curXmlTab=var.xmlZheKou
	elseif sender.nameStr=="tabName7" then--充值豪礼
		ContainerSuperActivities.initRecharge()
		var.curXmlTab=var.xmlRecharge
	elseif sender.nameStr=="tabName8" then--狼牙回馈
		ContainerSuperActivities.initLangYa()
		var.curXmlTab=var.xmlLangYa
	elseif sender.nameStr=="tabName9" then--龙心回馈
		ContainerSuperActivities.initLongXin()
		var.curXmlTab=var.xmlLongXin
	elseif sender.nameStr=="tabName10" then--幸运转盘
		ContainerSuperActivities.initZhuanPan()
		var.curXmlTab=var.xmlZhuanPan
	
	end
	sender:setBrightStyle(ccui.BrightStyle.highlight)
	sender:setTitleColor(cc.c3b(253, 223, 174))
	var.curTab=sender
end

--初始化活动页签列表
function ContainerSuperActivities.initTabList(data)
	--var.curTab=nil
	local bDefaultTab = false;
	local function updateList(item)
		local itemData=data[item.tag]
		local btn = item:getWidgetByName("btnMode")
		btn:getWidgetByName("imgRed"):setVisible(false)
		if btn then
			btn:setTitleText(itemData.name)
			btn.nameStr=itemData.nameStr

			var.tabBtnArrs[itemData.nameStr]=btn
			GUIAnalysis.attachEffect(btn,"outline(000000,1)")
			GUIFocusPoint.addUIPoint(btn,ContainerSuperActivities.tabPrsBtnClick)
			-- if not var.curTab and item.tag==1 then
			-- 	ContainerSuperActivities.tabPrsBtnClick(btn)
			-- end
			if var.tabArrs["tabName4"] and bDefaultTab == false then
				bDefaultTab = true;
				ContainerSuperActivities.tabPrsBtnClick(var.tabArrs["tabName4"])
			end
			var.tabArrs[itemData.nameStr]=btn
			--print(var.tabArrs[itemData.nameStr],itemData.nameStr)
		end
		
	end
	var.tabBtnArrs={}
	local tabList = var.xmlPanel:getWidgetByName("tabList")
	tabList:reloadData(#data,updateList):setSliderVisible(false)

	

	GameSocket:PushLuaTable("gui.ContainerSuperActivities.onPanelData",GameUtilSenior.encode({actionid = "updateRedpoint",params={}}))----请求红点数据
end

--刷新红点显示
function ContainerSuperActivities.updateTabRed(data)

	if data.name then
		local tabList = var.xmlPanel:getWidgetByName("tabList")
		if var.tabBtnArrs[data.name] then
			local btn = var.tabBtnArrs[data.name]
			btn:getWidgetByName("imgRed"):setVisible(data.show)
		end
	end
end
--------------------------------------------------------------全民探宝------------------------------------------------------------------
function ContainerSuperActivities.initLottery()
	if not var.xmlLottery then
		var.xmlLottery=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_lottery.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlLottery, "tabBg", "ui/image/Activities/activities_9.jpg")
		var.xmlLottery:getWidgetByName("btnLottery"):addClickEventListener(function( sender )
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="extend_lottory"})
		end)
	else
		var.xmlLottery:show()
	end
	GameSocket:PushLuaTable("gui.ContainerSuperActivities.onPanelData",GameUtilSenior.encode({actionid = "updateLotteryData",params={}}))
end

function ContainerSuperActivities.updateLotteryData(data)
	ContainerSuperActivities.updateCount(var.xmlLottery,data.time)
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
function ContainerSuperActivities.initQiangGou()
	
	if not var.xmlZheKou then
		var.xmlZheKou=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_zhekou.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlZheKou, "tabBg", "ui/image/Activities/activities_4.jpg")
	else
		var.xmlZheKou:show()
	end
	GameSocket:PushLuaTable("gui.ContainerSuperActivities.onPanelData",GameUtilSenior.encode({actionid = "updateQiangGouData",params={}}))
end

function ContainerSuperActivities.updateQiangGouData(data)
	ContainerSuperActivities.updateCount(var.xmlZheKou,data.time)

	local function prsBtnClick(sender)
		GameSocket:PushLuaTable("gui.ContainerSuperActivities.onPanelData",GameUtilSenior.encode({actionid = "reqQiangGouGoods",params={index=sender.index}}))
	end

	local function updateList(item)
		local itemData=data.goods[item.tag]
		local id = GameSocket:getItemDefByID(itemData.id)
		item:getWidgetByName("itemName"):setString(id.mName)
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

--------------------------------------------------------------充值豪礼------------------------------------------------------------------
function ContainerSuperActivities.initRecharge()
	if not var.xmlRecharge then
		var.xmlRecharge=GUIAnalysis.load("ui/layout/ContainerSuperActivities_xiaofei.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlRecharge, "tabBg", "ui/image/img_jingcai_czrank.png")
	else
		var.xmlRecharge:show()
	end
	GameSocket:PushLuaTable("gui.ContainerSuperActivities.onPanelData",GameUtilSenior.encode({actionid = "updateRechargeData",params={}}))
end

function ContainerSuperActivities.updateRechargeRankData(data)
	ContainerSuperActivities.updateCount(var.xmlRecharge,data.time)
	for i=1,#data.awards do
		local itemDatas = data.awards[i].awards
		for j=1,#itemDatas do
			local itemData = itemDatas[j]
			local awardItem=var.xmlRecharge:getWidgetByName("icon"..i.."_"..j)
			if itemData then
				awardItem:setVisible(true)
				local param={parent=awardItem, typeId=itemData.id, num=itemData.num}
				GUIItem.getItem(param)
			else
				awardItem:setVisible(false)
			end
		end
		if data.awards[i].name~="" then
			var.xmlRecharge:getWidgetByName("labName"..i):setString(data.awards[i].name):setVisible(true)
			var.xmlRecharge:getWidgetByName("img"..i):setVisible(false)
		else
			var.xmlRecharge:getWidgetByName("labName"..i):setVisible(false)
			var.xmlRecharge:getWidgetByName("img"..i):setVisible(true)
		end
	end
	if data.myRank>0 then  
		var.xmlRecharge:getWidgetByName("labMyRank"):setString("第"..data.myRank.."名")
	else
		var.xmlRecharge:getWidgetByName("labMyRank"):setString("未上榜")
	end
	var.xmlRecharge:getWidgetByName("labName1_0_0_1"):setString("充值满200RMB")
	
	var.xmlRecharge:getWidgetByName("labMyXiaoFei"):setString("已充值RMB："..data.curXiaoFei)
	var.xmlRecharge:getWidgetByName("labMyXiaoFei"):setString("已充值RMB："..data.curXiaoFei)
	var.xmlRecharge:getWidgetByName("labMyXiaoFei"):setString("已充值RMB："..data.curXiaoFei)


end


--------------------------------------------------------------全服双倍------------------------------------------------------------------
function ContainerSuperActivities.initDoubleExp()
	if not var.xmlDoubleExp then
		var.xmlDoubleExp=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_doubleexp.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlDoubleExp, "tabBg", "ui/image/Activities/activities_7.jpg")
		
	else
		var.xmlDoubleExp:show()
	end
	GameSocket:PushLuaTable("gui.ContainerSuperActivities.onPanelData",GameUtilSenior.encode({actionid = "updateDoubleCount",params={}}))
end


--------------------------------------------------------------超级瑞兽------------------------------------------------------------------
function ContainerSuperActivities.initRuiShou()
	if not var.xmlRuiShou then
		var.xmlRuiShou=GUIAnalysis.load("ui/layout/ContainerActivitiesAction_ruishou.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlRuiShou, "tabBg", "ui/image/Activities/activities_5.jpg")
   		
		var.xmlRuiShou:getWidgetByName("btnVcion"):addClickEventListener(function( sender )
			GameSocket:PushLuaTable("gui.ContainerSuperActivities.onPanelData",GameUtilSenior.encode({actionid = "reqRuiShowGo",params={}}))
		end)
	else
		var.xmlRuiShou:show()
	end
	GameSocket:PushLuaTable("gui.ContainerSuperActivities.onPanelData",GameUtilSenior.encode({actionid = "updateRsCount",params={}}))
end

--刷新超级瑞兽活动剩余时间
function ContainerSuperActivities.updateCount(parent,time)
	-- local time = itemData.needTime-data.onlineTime--秒
	if not parent then return end
	local labTime=parent:getWidgetByName("labCount"):setString("活动暂未开始")
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

--------------------------------------------------------------累计充值-----------------------------------------------------------------
local despljcz ={
	[1]="<font color=#E7BA52 size=18>累计充值说明：</font>",
	[2]="<font color=#f1e8d0>活动期间，累计充值RMB达到指定档次可领取对应奖励</font>",
}
function ContainerSuperActivities.despljcz()
	local mParam = {
		name = GameMessageCode.EVENT_PANEL_ON_ALERT,
		panel = "tips", 
		infoTable = despljcz,
		visible = true, 
	}
	GameSocket:dispatchEvent(mParam)
end

function ContainerSuperActivities.initChongZhi()
	
	if not var.xmlChongZhi then
		var.xmlChongZhi=GUIAnalysis.load("ui/layout/ContainerSuperActivities_cz.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		var.xmlChongZhi:getWidgetByName("Button_ask"):setTouchEnabled(true):addTouchEventListener(function (pSender, touchType)
			if touchType == ccui.TouchEventType.began then
				ContainerSuperActivities.despljcz()
			elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then	
				GDivDialog.handleAlertClose()
			end
		end)
	else
		var.xmlChongZhi:show()
	end
	GameSocket:PushLuaTable("gui.ContainerSuperActivities.onPanelData",GameUtilSenior.encode({actionid = "updateChongZhiData",params={}}))
end

function ContainerSuperActivities.updateRechargeData(data)

	--var.xmlChongZhi:getWidgetByName("labCount"):

	ContainerSuperActivities.updateCount(var.xmlChongZhi,data.time)
	local list = var.xmlChongZhi:getWidgetByName("list_daily")
	local function LingCallBack(sender) ---------累计消费领取
		GameSocket:PushLuaTable("gui.ContainerSuperActivities.onPanelData",GameUtilSenior.encode({actionid = "getljczAward",params = {index=sender.key}}))
	end
	local function LingCallBack2(sender)
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = "panel_charge"})
	end
	local function updateLJCZList(item)
		item:getWidgetByName("lbl_daily_title_cell"):setString("累计充值"..data.datas[item.tag].need.."RMB")
		for i=1,5 do
			local awardItem = item:getWidgetByName("model_item_box_"..i)
			awardItem:setVisible(i<=#data.datas[item.tag].award)
			if i<=#data.datas[item.tag].award then
				local param={parent=awardItem , typeId=data.datas[item.tag].award[i].id, num = data.datas[item.tag].award[i].num}
				GUIItem.getItem(param)
				local itemdef = GameSocket.mItemDesp[param.typeId]
				awardItem:removeChildByName("effectSprite")
				if itemdef then
					local effectID = 65078
					if itemdef.mItemBg > 0 then
						effectID = itemdef.mItemBg + effectID - 3
					end
					GameUtilSenior.addEffect(awardItem,"effectSprite",4,effectID,{x = 33 , y = 32})
				end
			end
		end
		local btnLing = item:getWidgetByName("btnLing")
		local state=item:getWidgetByName("img_daily_state")
		btnLing.key = data.datas[item.tag].index
		if data.cznum>=data.datas[item.tag].need and data.datas[item.tag].con ==1 then ---已领取
			state:loadTexture("txt_yilingqu", ccui.TextureResType.plistType)
			state:setVisible(true)
			btnLing:setVisible(false)
		elseif data.cznum>=data.datas[item.tag].need and data.datas[item.tag].con ==0  then  ---可领取
			btnLing:setBright(true)
			btnLing:setVisible(true)
			btnLing:loadTextureNormal("btn_green",ccui.TextureResType.plistType)
			GameUtilSenior.addHaloToButton(btnLing, "btn_normal_light3")---呼吸灯
			state:setVisible(false)
			GUIFocusPoint.addUIPoint(btnLing , LingCallBack)
		else---未达成
			state:loadTexture("txt_weidaicheng", ccui.TextureResType.plistType)
			btnLing:setVisible(false)
			state:setVisible(true)
			--state:setVisible(false)
			--btnLing:loadTextureNormal("btn_new2",ccui.TextureResType.plistType)
			--btnLing:setTitleText("立即前往")
			--GUIFocusPoint.addUIPoint(btnLing , LingCallBack2)
		end 
		
	end

	list:reloadData(#data.datas,updateLJCZList)
end

-------------------------------------------------------------累计消费------------------------------------------------------------------
local despljxf ={
	[1]="<font color=#E7BA52 size=18>累计消费说明：</font>",
	[2]="<font color=#f1e8d0>活动期间，累计消费元宝达到指定档次可领取对应奖励</font>",
}
function ContainerSuperActivities.despljxf()
	local mParam = {
		name = GameMessageCode.EVENT_PANEL_ON_ALERT,
		panel = "tips", 
		infoTable = despljxf,
		visible = true, 
	}
	GameSocket:dispatchEvent(mParam)
end

function ContainerSuperActivities.initLogin()
	if not var.xmlLogin then
		var.xmlLogin=GUIAnalysis.load("ui/layout/ContainerSuperActivities_xf.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		var.xmlLogin:getWidgetByName("Button_ask"):addTouchEventListener(function (pSender, touchType)
			if touchType == ccui.TouchEventType.began then
				ContainerSuperActivities.despljxf()
			elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then	
				GDivDialog.handleAlertClose()
			end
		end)
	else
		var.xmlLogin:show()
	end
	GameSocket:PushLuaTable("gui.ContainerSuperActivities.onPanelData",GameUtilSenior.encode({actionid = "updateljxfData",params={}}))
end

function ContainerSuperActivities.updateLoginData(data)
	ContainerSuperActivities.updateCount(var.xmlLogin,data.time)
	local list = var.xmlLogin:getWidgetByName("list_daily")
	local function LingCallBack(sender) ---------累计消费领取
			GameSocket:PushLuaTable("gui.ContainerSuperActivities.onPanelData",GameUtilSenior.encode({actionid = "getljxfAward",params = {index=sender.key}}))
	end
	local function updateLJCZList(item)
		--print(data.datas[item.tag].shengyu,data.datas[item.tag].times)
		item:getWidgetByName("lbl_daily_title_cell"):setString("累计消费"..data.datas[item.tag].need.."元宝")
		
		
		for i=1,5 do
			local awardItem = item:getWidgetByName("model_item_box_"..i)
			awardItem:setVisible(i<=#data.datas[item.tag].award)
			if i<=#data.datas[item.tag].award then
				-- local index=0
				-- if data.datas[item.tag].award[i].job then
				-- 	index = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)-100
				-- end
				local param={parent=awardItem , typeId=data.datas[item.tag].award[i].id, num = data.datas[item.tag].award[i].num}
				GUIItem.getItem(param)
			end
		end
		local btnLing = item:getWidgetByName("btnLing")
		local state=item:getWidgetByName("img_daily_state")
		btnLing.key = data.datas[item.tag].index
		if data.xfnum>=data.datas[item.tag].need and data.datas[item.tag].con ==1 then ---已领取
			state:loadTexture("txt_yilingqu", ccui.TextureResType.plistType)
			state:setVisible(true)
			btnLing:setVisible(false)
		elseif data.xfnum>=data.datas[item.tag].need and data.datas[item.tag].con ==0  then  ---可领取
			btnLing:setBright(true)
			btnLing:setVisible(true)
			GameUtilSenior.addHaloToButton(btnLing, "btn_normal_light3")---呼吸灯
			state:setVisible(false)
		else---未达成
			state:loadTexture("txt_weidaicheng", ccui.TextureResType.plistType)
			btnLing:setVisible(false)
			state:setVisible(true)
		end 
		GUIFocusPoint.addUIPoint(btnLing , LingCallBack)
	end

	list:reloadData(#data.datas,updateLJCZList)
end

--------------------------------------------------------------then--狼牙回馈------------------------------------------------------------------
function ContainerSuperActivities.initLangYa()
	if not var.xmlLangYa then
		var.xmlLangYa=GUIAnalysis.load("ui/layout/ContainerSuperActivities_huikui.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		var.xmlLangYa:getWidgetByName("imgTitleBg"):loadTexture("img_langyaditu",ccui.TextureResType.plistType)
   		--GameUtilSenior.asyncload(var.xmlLangYa, "tabBg", "ui/image/Activities/activities_3.jpg")
	else
		var.xmlLangYa:show()
	end
	var.xmlLangYa:getWidgetByName("imgTitleBg"):loadTexture("img_langya", ccui.TextureResType.plistType)
	GameSocket:PushLuaTable("gui.ContainerSuperActivities.onPanelData",GameUtilSenior.encode({actionid = "updateLangYaData",params={}}))
end

function ContainerSuperActivities.updateLangYaData(data)
	ContainerSuperActivities.updateCount(var.xmlLangYa,data.time)
	var.xmlLangYa:getWidgetByName("LabDesp"):setString("温馨提示：活动期间内获取相应狼牙碎片后，可领取狼牙碎片")
	var.xmlLangYa:getWidgetByName("labDesp2"):setString("获取数量")
	
	local function prsBtnClick(sender)
		GameSocket:PushLuaTable("gui.ContainerSuperActivities.onPanelData",GameUtilSenior.encode({actionid = "reqLangYaAwards",params={index=sender.index}}))
	end

	local allUse = data.allUse
	local function updateList(item)
		local itemData = data.dataTable[item.tag]
		item:getWidgetByName("labDesp"):setString("获取"..itemData.name.."x"..itemData.useNum)
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
function ContainerSuperActivities.initLongXin()
	if not var.xmlLongXin then
		var.xmlLongXin=GUIAnalysis.load("ui/layout/ContainerSuperActivities_huikui.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		--GameUtilSenior.asyncload(var.xmlLongXin, "tabBg", "ui/image/Activities/activities_3.jpg")
   		var.xmlLongXin:getWidgetByName("imgTitleBg"):loadTexture("img_longxinditu",ccui.TextureResType.plistType)
	else
		var.xmlLongXin:show()
	end
	var.xmlLongXin:getWidgetByName("imgTitleBg"):loadTexture("img_longxin", ccui.TextureResType.plistType)
	GameSocket:PushLuaTable("gui.ContainerSuperActivities.onPanelData",GameUtilSenior.encode({actionid = "updateLongXinData",params={}}))
end

function ContainerSuperActivities.updateLongXinData(data)
	ContainerSuperActivities.updateCount(var.xmlLongXin,data.time)
	var.xmlLongXin:getWidgetByName("LabDesp"):setString("温馨提示：活动期间内获取相应龙心碎片后，可领取龙心碎片")
	var.xmlLongXin:getWidgetByName("labDesp2"):setString("获取数量")
	local function prsBtnClick(sender)
		GameSocket:PushLuaTable("gui.ContainerSuperActivities.onPanelData",GameUtilSenior.encode({actionid = "reqLongXinAwards",params={index=sender.index}}))
	end

	local allUse = data.allUse
	local function updateList(item)
		local itemData = data.dataTable[item.tag]
		item:getWidgetByName("labDesp"):setString("获取"..itemData.name.."x"..itemData.useNum)
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
	awardsList:reloadData(#data.dataTable,updateList):setSliderVisible(true):setTouchEnabled(true)
end

--------------------------------------------------------------幸运转盘------------------------------------------------------------------
function ContainerSuperActivities.initZhuanPan()
	if not var.xmlZhuanPan then
		var.xmlZhuanPan=GUIAnalysis.load("ui/layout/ContainerSuperActivities_zp.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlZhuanPan, "img_bg", "ui/image/activity_lottery_bg.jpg")

		ContainerSuperActivities.PanelClick()

		var.btn_ten = var.xmlZhuanPan:getWidgetByName("btn_ten")
		var.btn_ten:addClickEventListener(function (sender)
			var.isTen = not var.isTen
			sender:loadTextureNormal( (var.isTen and "btn_checkbox_big_sel") or "btn_checkbox_big", ccui.TextureResType.plistType)
		end)

		var.xmlZhuanPan:getWidgetByName("btnChongZhi"):addClickEventListener(function (sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
		end)
	
		GameSocket:PushLuaTable("gui.PanelZhuanPan.handlePanelData",GameUtilSenior.encode({actionid = "getPanelData"}))
	else
		var.xmlZhuanPan:show()
	end
	GameSocket:PushLuaTable("gui.PanelZhuanPan.handlePanelData",GameUtilSenior.encode({actionid = "updateYuTimes"}))
end

function ContainerSuperActivities.PanelClick()
	local function prsBtnCall(sender)	
		GameSocket:PushLuaTable("gui.PanelZhuanPan.handlePanelData",GameUtilSenior.encode({actionid = "choujiang", param= var.isTen }))
		ContainerSuperActivities.PointRotate()
		if (var.yuTimes>0 and not var.isTen) or (var.yuTimes>=10 and var.isTen) then
			var.xmlZhuanPan:getWidgetByName("btnGet"):setEnabled(false)
		end
	end
	local btnGet = var.xmlZhuanPan:getWidgetByName("btnGet")
	GUIFocusPoint.addUIPoint(btnGet,prsBtnCall)
end

--刷新转盘显示
function ContainerSuperActivities.updateShowItems(data)
	if not data then return end
	for i=1,#data do
		local awardItem=var.xmlZhuanPan:getWidgetByName("icon"..data[i].index)
		local param={parent=awardItem , typeId=data[i].id, num=1}
		GUIItem.getItem(param)
	end
	ContainerSuperActivities.addEffect()
end

function ContainerSuperActivities.addEffect()
	for i=1,10 do
		local awardItem = var.xmlZhuanPan:getWidgetByName("icon"..i)
		local effectSprite = cc.Sprite:create()
			:setAnchorPoint(cc.p(0.5,0.5))
			:setPosition(cc.p(23,23))
			:addTo(awardItem)
			:setScale(1)
		--cc.AnimManager:getInstance():getPlistAnimateAsync(effectSprite,4, 65080, 4, 0, 5)
		GameUtilSenior.addEffect(effectSprite,"spriteEffect",GROUP_TYPE.EFFECT,65080,false,false,true)
	end
end

function ContainerSuperActivities.updateContent(data,curScrollName,listsize,Margin,removeAll,tsize, action)
	local scroll = var.xmlZhuanPan:getWidgetByName(curScrollName):setItemsMargin(Margin or 0):setClippingEnabled(true)
	scroll:setDirection(ccui.ScrollViewDir.vertical)
	scroll:setScrollBarEnabled(false)
	if removeAll then scroll:removeAllChildren() end
	for i=1, #data do
		local richWidget = GUIRichLabel.new({size=cc.size(listsize,30),space=2})
		local textsize = tsize or 18
		-- local tempInfo = GameUtilSenior.encode(data[i])
		richWidget:setRichLabel(data[i],30,textsize)
		richWidget:setVisible(true)
		scroll:pushBackCustomItem(richWidget)
		if #scroll:getItems()>30 then
			scroll:removeItem(0)
		end
	end

	if action then
		scroll:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.1),
			cc.CallFunc:create(function ()
					scroll:scrollToBottom(1,true)
				end)
			)
		)
	else
		scroll:scrollToBottom(0,true)
	end
end

-----------------------------------------------------旋转动画----------------------------------------------------------
function ContainerSuperActivities.PointRotate(index)
	if not index or index<=0 then return end
	local boxPoint=var.xmlZhuanPan:getWidgetByName("boxPoint")
	local needRotate = 36*index-15-var.curAngle
	var.curAngle=36*index-15

	if needRotate<=0 then needRotate=360+needRotate end

	local needTime = 0.01*(100*needRotate/270)

	-- print(needTime,needRotate)

	local function moveAct2(target)
		target:runAction(cca.seq({
			cc.EaseIn:create(cca.rotateBy(needTime,needRotate),needTime),  --135/270 --度数计算时间
			cca.cb(function ()
				target:stopAllActions()
				--结束后开始抽奖刷新记录+播放飞动画
				GameSocket:PushLuaTable("gui.PanelZhuanPan.handlePanelData",GameUtilSenior.encode({actionid = "rotateStop"}))
				var.xmlZhuanPan:getWidgetByName("btnGet"):setEnabled(true)
			end),
		}))
	end

	local function moveAct(target)
		target:runAction(cca.seq({
			cca.rotateBy(0.3*4,360*4),
			cca.cb(function ()
				target:stopAllActions()
				moveAct2(target)
			end),
		}))
	end
	-- moveAct(iconFly)
	moveAct(boxPoint)
end






return ContainerSuperActivities