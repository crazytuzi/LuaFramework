--[[
--开服活动功能
--]]

local ContainerActivities={}
local var = {}

local lxczTable ={
	[1] ="<font color=#E7BA52 size=18>连续充值说明：</font>",
	[2] ="<font color=#f1e8d0>1、每天充值奖励，请在当天达到条件后领取，过期将无法领取奖励</font>",
    [3] ="<font color=#f1e8d0>2、</font>",
    [4] ="<font color=#f1e8d0>3、</font>",
}

function ContainerActivities.initView(extend)
	var = {
		xmlPanel,
		curXmlTab=nil,
		xmlBoss=nil,
		xmlOnline=nil,
		xmlTeHui=nil,
		xmlJinJi=nil,
		xmlSbk=nil,
		xmlLeiChong=nil,
		xmlLxcz=nil,
		xmlSevenDay = nil,
		lxczData={},
		curDangTab=nil,--连续充值档次

		jinJiIndex=1,

		curTabName=nil,--记录当前点击的页签名

		bossData=nil,--全名BOSS数据
		bossGroup=1,--全名BOSS当前显示的组id
		xmlDaily = nil,
		dailyTabData = nil,
		xmlFifteen = nil,
		fifteenCeels = {},
		fifteenTabData = nil,
		fifteenNowSelect = nil,

		curTab=nil,
		teHuiIndex=1,
		tabBtnsArr={},
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerActivities.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerActivities.handlePanelData)
		-- ContainerActivities.initTabs()
		GameSocket:PushLuaTable("gui.ContainerActivities.onPanelData",GameUtilSenior.encode({actionid = "reqTabList",params={}}))
	end
	return var.xmlPanel
end

function ContainerActivities.onPanelOpen(extend)
	if extend and extend.mParam then
		var.teHuiIndex=extend.mParam.index
	end
end

function ContainerActivities.onPanelClose()

end

function ContainerActivities.handlePanelData(event)
	if event.type ~= "ContainerReward" then return end
	local data = GameUtilSenior.decode(event.data)
	-- print(event.data)
	if data.cmd =="updateBossData" then
		var.bossData={}
		var.bossData=data.dataTable
		ContainerActivities.updateBoss(0)
	elseif data.cmd=="updateTeHuiData" then--特惠礼包
		ContainerActivities.updateTeHuiShow(data.dataTable)
	elseif data.cmd=="updateLeiChongData" then--累计充值
		ContainerActivities.updateRechargeData(data)

	elseif data.cmd=="updateLxczData" then--连续充值
		ContainerActivities.manageLxczData(data)

	elseif data.cmd=="updateActTabs" then
		var.tabBtnsArr={}
		ContainerActivities.initTabList(data.tabTable)
	elseif data.cmd=="updateLevelJingJi" then--等级竞技数据
		ContainerActivities.initJinJiList(data)
	elseif data.cmd=="updateShenYiJingJi" then--神翼竞技数据
		ContainerActivities.initJinJiList(data)
	elseif data.cmd=="updateLongXinJingJi" then--龙心竞技数据
		ContainerActivities.initJinJiList(data)
	elseif data.cmd=="updateLangYaJingJi" then--狼牙竞技数据
		ContainerActivities.initJinJiList(data)
	elseif data.cmd=="updateRankData" then--排名数据
		ContainerActivities.updateRankInfo(data.rankTable)
	elseif data.cmd=="updataSevenDay" then --七天狂欢
		ContainerActivities.updataSevenDay(data)

	elseif data.cmd=="updateTabRedShow" then--刷新红点
		ContainerActivities.updateTabRedShow(data.index,data.isshow)
	end


end

--初始化页签列表
function ContainerActivities.initTabList(data)
	if not data then return end
	local function prsBtnClick(sender)
		if var.curTab then var.curTab:setBrightStyle(ccui.BrightStyle.normal) end
		if var.curXmlTab then var.curXmlTab:hide() end
		if sender.nameStr=="tehui" then--特惠礼包
			ContainerActivities.initTeHui()
			var.curXmlTab=var.xmlTeHui
		elseif sender.nameStr=="qmboss" then--全名BOSS
			ContainerActivities.initBoss()
			var.curXmlTab= var.xmlBoss
		elseif sender.nameStr=="lxcz" then--连续充值
			ContainerActivities.initLxRecharge()
			var.curXmlTab= var.xmlLxcz

		elseif sender.nameStr=="leichong" then--累计充值
			ContainerActivities.initLeiChong()
			var.curXmlTab= var.xmlLeiChong

		elseif sender.nameStr=="dengji" then--等级竞技
			ContainerActivities.initJingJi(sender.nameStr)
			var.curXmlTab= var.xmlJinJi
			GameSocket:PushLuaTable("gui.AwardHall_jingji.handlePanelData",GameUtilSenior.encode({actionid = "reqLevelJingJi",params={}}))
			var.jinJiIndex=1
		elseif sender.nameStr=="shenyi" then--神翼竞技
			ContainerActivities.initJingJi(sender.nameStr)
			var.curXmlTab= var.xmlJinJi
			GameSocket:PushLuaTable("gui.AwardHall_jingji.handlePanelData",GameUtilSenior.encode({actionid = "reqShenYiJingJi",params={}}))
			var.jinJiIndex=2
		elseif sender.nameStr=="longxin" then--龙心竞技
			ContainerActivities.initJingJi(sender.nameStr)
			var.curXmlTab= var.xmlJinJi
			GameSocket:PushLuaTable("gui.AwardHall_jingji.handlePanelData",GameUtilSenior.encode({actionid = "reqLongXinJingJi",params={}}))
			var.jinJiIndex=3
		elseif sender.nameStr=="langya" then--狼牙竞技
			ContainerActivities.initJingJi(sender.nameStr)
			var.curXmlTab= var.xmlJinJi
			GameSocket:PushLuaTable("gui.AwardHall_jingji.handlePanelData",GameUtilSenior.encode({actionid = "reqLangYaJingJi",params={}}))
			var.jinJiIndex=4
		elseif sender.nameStr=="shabake" then--沙巴克
			ContainerActivities.initShaBaKe()
			var.curXmlTab= var.xmlSbk
		elseif sender.nameStr=="sevenDay" then--七天狂欢
			ContainerActivities.initSevenDay()
			var.curXmlTab= var.xmlSevenDay
		end
		sender:setBrightStyle(ccui.BrightStyle.highlight)
		var.curTab=sender
	end

	local function updateList(item)
		local itemData=data[item.tag]
		if not (itemData and itemData.name) then return end
		local btn = item:getWidgetByName("btnMode"):setTitleText(itemData.name):setTitleColor(GameBaseLogic.getColor(0xfddfae))
		btn.nameStr=itemData.nameStr
		btn:setSwallowTouches(false)
		var.tabBtnsArr[itemData.index]=btn
		GUIAnalysis.attachEffect(btn,"outline(0e0600,1)")
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
		if not var.curTab and item.tag==1 then
			prsBtnClick(btn)
		end
	end

	local tabList = var.xmlPanel:getWidgetByName("tabList")
	tabList:reloadData(#data,updateList):setSliderVisible(false):setTouchEnabled(true)

	GameSocket:PushLuaTable("gui.AwardHall_jingji.handlePanelData",GameUtilSenior.encode({actionid = "updateRedpoint",params={}}))
end

--设置页签红点信息
function ContainerActivities.updateTabRedShow(index,isshow)
	if not var.tabBtnsArr[index] then return end
	local btn=var.tabBtnsArr[index]
	if btn then
		if isshow then
			btn:getWidgetByName("imgRed"):setVisible(true)
		else
			btn:getWidgetByName("imgRed"):setVisible(false)
		end
	end
end

--------------------------------------------------------------连续充值------------------------------------------------------------------
function ContainerActivities.lxczDesp()
	local mParam = {
	name = GameMessageCode.EVENT_PANEL_ON_ALERT,
	panel = "tips",
	infoTable = lxczTable,
	visible = true,
	}
	GameSocket:dispatchEvent(mParam)

end

function ContainerActivities.initLxRecharge()
	if not var.xmlLxcz then
		var.xmlLxcz=GUIAnalysis.load("ui/layout/ContainerActivities_lxrecharge.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlLxcz, "img_bg", "ui/image/recharge_continue.jpg")
   		for i=1,3 do
			local btn = var.xmlLxcz:getWidgetByName("btnTab"..i)
			GUIFocusPoint.addUIPoint(btn,ContainerActivities.lxczBtnClick)
			btn:getWidgetByName("imgRed"):setVisible(false)
		end
		-- var.xmlLxcz:getWidgetByName("btnDesp"):setVisible(false):addTouchEventListener(function (pSender, touchType)
		-- 	if touchType == ccui.TouchEventType.began then
		-- 		ContainerActivities.lxczDesp()
		-- 	elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then
		-- 		GDivDialog.handleAlertClose()
		-- 	end
		-- end)
	else
		var.xmlLxcz:show()
	end
	GameSocket:PushLuaTable("gui.AwardHall_lxrecharge.handlePanelData",GameUtilSenior.encode({actionid = "reqLxczData",params={}}))
end

--初始化档次按钮
function ContainerActivities.lxczBtnClick(sender)
	local senderName = sender:getName()
	if senderName=="btnTab1" then
		ContainerActivities.updateLxczData(var.lxczData[1])
	elseif senderName=="btnTab2" then
		ContainerActivities.updateLxczData(var.lxczData[2])
	elseif senderName=="btnTab3" then
		ContainerActivities.updateLxczData(var.lxczData[3])
	end
	if var.curDangTab then
		var.curDangTab:setBrightStyle(0)
		var.curDangTab:getWidgetByName("labDesp"):setColor(GameBaseLogic.getColor(0xc3ad88))
	end
	sender:setBrightStyle(1)
	sender:getWidgetByName("labDesp"):setColor(GameBaseLogic.getColor(0xfddfae))
	var.curDangTab=sender
end

--分类连续充值档次数据
function ContainerActivities.manageLxczData(data)
	var.lxczData={{},{},{}}
	local redArr = {false,false,false}
	for i=1,#data.dataTable do
		local itemData = data.dataTable[i]
		if itemData.needNum==1000 then
			table.insert(var.lxczData[1],itemData)
			if itemData.flag==2 then
				redArr[1]=true
			end
		elseif itemData.needNum==5000 then
			table.insert(var.lxczData[2],itemData)
			if itemData.flag==2 then
				redArr[2]=true
			end
		elseif itemData.needNum==10000 then
			table.insert(var.lxczData[3],itemData)
			if itemData.flag==2 then
				redArr[3]=true
			end
		end
	end
	local btn = var.xmlLxcz:getWidgetByName("btnTab"..data.typedang)
	ContainerActivities.lxczBtnClick(btn)
	ContainerActivities.updateLxczData(var.lxczData[data.typedang])
	ContainerActivities.updateCount(var.xmlLxcz,data.time)
	for i=1,3 do
		var.xmlLxcz:getWidgetByName("btnTab"..i):getWidgetByName("imgRed"):setVisible(redArr[i])
	end
end

function ContainerActivities.updateLxczData(data)
	local function LingCallBack(sender)
		GameSocket:PushLuaTable("gui.AwardHall_lxrecharge.handlePanelData",GameUtilSenior.encode({actionid = "reqLxczLing",params={index=sender.key}}))
	end

	local function updateLJCZList(item)
		local itemData = data[item.tag]
		item:getWidgetByName("lbl_daily_title_cell"):setString("连续"..itemData.needDays.."天每日充值"..itemData.needNum.."RMB可领"):enableOutline(GameBaseLogic.getColor(0x000000), 1)
		-- if itemData.needDays==3 then
		-- 	item:getWidgetByName("rendBg"):loadTexture("img_render_bg3", ccui.TextureResType.plistType)
		-- elseif itemData.needDays==7 then
		-- 	item:getWidgetByName("rendBg"):loadTexture("img_render_bg2", ccui.TextureResType.plistType)
		-- else
		-- 	item:getWidgetByName("rendBg"):loadTexture("img_render_bg", ccui.TextureResType.plistType)
		-- end
		for i=1,6 do
			local awardItem = item:getWidgetByName("model_item_box_"..i)
			awardItem:setVisible(i<=#itemData.ids)
			if i<=#itemData.ids then
				local param={parent=awardItem , typeId=itemData.ids[i], num = itemData.nums[i]}
				GUIItem.getItem(param)
--图片特效
				awardItem:removeChildByName("effectSprite")
				local effectSprite = awardItem:getChildByName("effectSprite")	
				if not effectSprite then 
					effectSprite = cc.Sprite:create()
						:setAnchorPoint(cc.p(0.5,0))
						:setPosition(cc.p(32,-318))
						:addTo(awardItem)
						:setScale(1.12)
						:setName("effectSprite")
						--:setLocalZOrder(10)
					--cc.AnimManager:getInstance():getPlistAnimateAsync(effectSprite,4, itemData.effectRes[i], 4, 0, 5)
					GameUtilSenior.addEffect(effectSprite,"spriteEffect",GROUP_TYPE.EFFECT,itemData.effectRes[i],false,false,true)
					effectSprite:setBlendFunc({src=gl.SRC_ALPHA,dst=gl.ONE})
				end
			end
		end
		local btnLing = item:getWidgetByName("btnLing")
		local state=item:getWidgetByName("img_daily_state")
		btnLing.key = itemData.index
		if itemData.flag==2 then
			btnLing:setVisible(true)
			state:setVisible(false)
			GameUtilSenior.addHaloToButton(btnLing, "btn_normal_light3")---呼吸灯
		else
			btnLing:setVisible(false)
			state:setVisible(true)
			btnLing:removeChildByName("img_bln")
			if itemData.flag==1 then
				state:loadTexture("img_wwc", ccui.TextureResType.plistType)
			elseif itemData.flag==3 then
				state:loadTexture("img_ylq", ccui.TextureResType.plistType)
			end
		end
		GUIFocusPoint.addUIPoint(btnLing , LingCallBack)
	end
	local result = {}
	local result2 = {}
	for i=1,#data do
		local itemData = data[i]
		if itemData.flag==3 then
			table.insert(result,itemData)
		else
			table.insert(result2,itemData)
		end
	end
	table.insertto(result2,result)
	data=result2
	local list = var.xmlLxcz:getWidgetByName("listCz")
	list:reloadData(#data,updateLJCZList)
end


--------------------------------------------------------------累计充值------------------------------------------------------------------
function ContainerActivities.initLeiChong()
	if not var.xmlLeiChong then
		var.xmlLeiChong=GUIAnalysis.load("ui/layout/ContainerActivities_leichong.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlLeiChong, "img_bg", "ui/image/recharge_total.jpg")
	else
		var.xmlLeiChong:show()
	end
	GameSocket:PushLuaTable("gui.AwardHall_leichong.handlePanelData",GameUtilSenior.encode({actionid = "reqLeiChongData",params={}}))
end

--累计充值倒计时
function ContainerActivities.updateCount(parent,time)
	-- local time = itemData.needTime-data.onlineTime--秒
	if not parent then return end
	local labTime=parent:getWidgetByName("labCount"):enableOutline(GameBaseLogic.getColor4(0x000000), 1)
	if time>0 then
		labTime:stopAllActions()
		labTime:setString("剩余时间："..GameUtilSenior.setTimeFormat(time*1000,8))
		labTime:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function ()
			time = time-1
			if time > 0 then
				labTime:setString("剩余时间："..GameUtilSenior.setTimeFormat(time*1000,8))
			else
				labTime:stopAllActions()
				labTime:setString("活动已结束")
			end
		end)})))
	else
		labTime:setString("活动已结束")
		if parent==var.xmlRuiShou then parent:getWidgetByName("Image_6"):setVisible(false) end
	end
end

function ContainerActivities.updateRechargeData(data)
	ContainerActivities.updateCount(var.xmlLeiChong,data.time)

	local function LingCallBack(sender)
		GameSocket:PushLuaTable("gui.AwardHall_leichong.handlePanelData",GameUtilSenior.encode({actionid = "lingLeiChongData",params={index=sender.key}}))
	end

	local function updateLJCZList(item)
		local itemData = data.dataTable[item.tag]
		item:getWidgetByName("lbl_daily_title_cell"):setString("累计充值"..itemData.needNum.."RMB"):enableOutline(GameBaseLogic.getColor(0x000000), 1)
		for i=1,5 do
			local awardItem = item:getWidgetByName("model_item_box_"..i)
			awardItem:setVisible(i<=#itemData.ids)
			if i<=#itemData.ids then
				local param={parent=awardItem , typeId=itemData.ids[i], num = itemData.nums[i]}
				GUIItem.getItem(param)
--图片特效	
				awardItem:removeChildByName("effectSprite")
				local effectSprite = awardItem:getChildByName("effectSprite")	
				if not effectSprite then 
					effectSprite = cc.Sprite:create()
							:setAnchorPoint(cc.p(0.5,0))
							:setPosition(cc.p(32,-318))
							:addTo(awardItem)
							:setScale(1.12)
							:setName("effectSprite")
							--:setLocalZOrder(10)
					--cc.AnimManager:getInstance():getPlistAnimateAsync(effectSprite,4, itemData.effectRes[i], 4, 0, 5)
					GameUtilSenior.addEffect(effectSprite,"spriteEffect",GROUP_TYPE.EFFECT,itemData.effectRes[i],false,false,true)
					effectSprite:setBlendFunc({src=gl.SRC_ALPHA,dst=gl.ONE})
				end
			end
		end
		local btnLing = item:getWidgetByName("btnLing")
		local state=item:getWidgetByName("img_daily_state")
		btnLing.key = itemData.index
		if itemData.flag==2 then
			btnLing:setVisible(true)
			state:setVisible(false)
			GameUtilSenior.addHaloToButton(btnLing, "btn_normal_light3")---呼吸灯
		else
			btnLing:setVisible(false)
			state:setVisible(true)
			btnLing:removeChildByName("img_bln")
			if itemData.flag==1 then
				state:loadTexture("img_wwc", ccui.TextureResType.plistType)
			elseif itemData.flag==3 then
				state:loadTexture("img_ylq", ccui.TextureResType.plistType)
			end
		end
		GUIFocusPoint.addUIPoint(btnLing , LingCallBack)
	end
	local result = {}
	local result2 = {}
	for i=1,#data.dataTable do
		local itemData = data.dataTable[i]
		if itemData.flag==3 then
			table.insert(result,itemData)
		else
			table.insert(result2,itemData)
		end
	end
	table.insertto(result2,result)
	data.dataTable=result2
	local list = var.xmlLeiChong:getWidgetByName("list_daily")
	list:reloadData(#data.dataTable,updateLJCZList)
end


--------------------------------------------------------------全名BOSS------------------------------------------------------------------
function ContainerActivities.initBoss()
	if not var.xmlBoss then
		var.xmlBoss=GUIAnalysis.load("ui/layout/ContainerActivities_boss.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlBoss, "bossBg", "ui/image/ContainerReward/tab_boss_bg.jpg")
   		ContainerActivities.initBossBtns()
	else
		var.xmlBoss:show()
	end
	GameSocket:PushLuaTable("gui.AwardHall_boss.handlePanelData",GameUtilSenior.encode({actionid = "reqBossData",params={}}))
end

--收到数据刷新界面
function ContainerActivities.updateBoss(add)
	var.bossGroup=var.bossGroup+add
	if var.bossGroup>4 then
		var.bossGroup=4
	elseif var.bossGroup<1 then
		var.bossGroup=1
	end
	var.xmlBoss:getWidgetByName("img_boss_title"):loadTexture("img_boss_title"..var.bossGroup, ccui.TextureResType.plistType)
	ContainerActivities.updateBossShow(var.bossData[var.bossGroup].boss,var.bossData[var.bossGroup].ling)
	ContainerActivities.updateAwardShow(var.bossData[var.bossGroup].awards)
end

--跟新BOSS显示
function ContainerActivities.updateBossShow(data,isling)
	local killNum = 0
	local function updateList(item)
		local itemData = data[item.tag]
		item:getWidgetByName("head"):loadTexture("image/icon/"..itemData.headid..".png")
		if itemData.kill==1 then
			item:getWidgetByName("headMask"):loadTexture("img_boss_an",ccui.TextureResType.plistType)
			item:getWidgetByName("imgYtz"):setVisible(true)
			killNum=killNum+1
		else
			item:getWidgetByName("headMask"):loadTexture("img_boss_liang",ccui.TextureResType.plistType)
			item:getWidgetByName("imgYtz"):setVisible(false)
		end
		item:getWidgetByName("bossName"):setString(itemData.name)
		if killNum>=4 then
			var.xmlBoss:getWidgetByName("btnGo"):setVisible(false)
			if isling>0 then
				var.xmlBoss:getWidgetByName("img_ylq"):setVisible(true)
				var.xmlBoss:getWidgetByName("btnGetAward"):setVisible(false)
			else
				var.xmlBoss:getWidgetByName("img_ylq"):setVisible(false)
				var.xmlBoss:getWidgetByName("btnGetAward"):setVisible(true)
			end
		else
			var.xmlBoss:getWidgetByName("btnGo"):setVisible(true)
			var.xmlBoss:getWidgetByName("btnGetAward"):setVisible(false)
			var.xmlBoss:getWidgetByName("img_ylq"):setVisible(false)
		end

	end
	local bossList = var.xmlBoss:getWidgetByName("bossList")
	bossList:reloadData(#data,updateList):setSliderVisible(false):setTouchEnabled(false)
end

--跟新奖励显示
function ContainerActivities.updateAwardShow(data)
	local function updateList(item)
		local itemData = data[item.tag]
		local awardItem=item:getWidgetByName("icon")
		local param={parent=awardItem, typeId=itemData.id, num=itemData.num}
		GUIItem.getItem(param)
--图片特效
		awardItem:removeChildByName("effectSprite")
		local effectSprite = awardItem:getChildByName("effectSprite")	
		if not effectSprite then 
			effectSprite = cc.Sprite:create()
					:setAnchorPoint(cc.p(0.5,0))
					:setPosition(cc.p(32,-318))
					:addTo(awardItem)
					:setScale(1.12)
					:setName("effectSprite")
					--:setLocalZOrder(10)
			--cc.AnimManager:getInstance():getPlistAnimateAsync(effectSprite,4, itemData.effectRes, 4, 0, 5)
			GameUtilSenior.addEffect(effectSprite,"spriteEffect",GROUP_TYPE.EFFECT,itemData.effectRes,false,false,true)
			effectSprite:setBlendFunc({src=gl.SRC_ALPHA,dst=gl.ONE})
		end
	end
	local awardList = var.xmlBoss:getWidgetByName("awardList")
	awardList:reloadData(#data,updateList):setSliderVisible(false):setTouchEnabled(false)
end

--全民BOSS按钮操作
local btnArrs = {"btnLeft","btnRight","btnGetAward","btnGo"}
function ContainerActivities.initBossBtns()
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		if senderName=="btnLeft" then
			ContainerActivities.updateBoss(-1)
		elseif senderName=="btnRight" then
			ContainerActivities.updateBoss(1)
		elseif senderName=="btnGetAward" then
			GameSocket:PushLuaTable("gui.AwardHall_boss.handlePanelData",GameUtilSenior.encode({actionid = "reqGetAward",params={index=var.bossGroup}}))
		elseif senderName=="btnGo" then
			GameSocket:PushLuaTable("gui.AwardHall_boss.handlePanelData",GameUtilSenior.encode({actionid = "reqGo",params={index=var.bossGroup}}))
		end
	end
	for i=1,#btnArrs do
		local btn = var.xmlPanel:getWidgetByName(btnArrs[i])
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
	end
end

--------------------------------------------------------------特惠礼包------------------------------------------------------------------
function ContainerActivities.initTeHui()
	if not var.xmlTeHui then
		var.xmlTeHui=GUIAnalysis.load("ui/layout/ContainerActivities_tehui.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlTeHui, "teHuiBg1", "ui/image/ContainerReward/img_th_bg.jpg")
   		ContainerActivities.initTeHuiBtns()
	else
		var.xmlTeHui:show()
	end
end

--特惠礼包按钮操作
local btnThArrs = {"btnTh1","btnTh2","btnTh3","btnTh4","btnThLing"}
function ContainerActivities.initTeHuiBtns()
	local curId = 0
	local imgSelect = var.xmlTeHui:getWidgetByName("imgSelect")
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		-- print(senderName)
		if senderName=="btnTh1" then
			GameSocket:PushLuaTable("gui.AwardHall_tehui.handlePanelData",GameUtilSenior.encode({actionid = "reqTeHuiData",params={index=1}}))
			curId=1
			GameUtilSenior.asyncload(var.xmlTeHui, "teHuiBg2", "ui/image/ContainerReward/th_shenzhuang.jpg")
			imgSelect:setPositionX(100)
		elseif senderName=="btnTh2" then
			GameSocket:PushLuaTable("gui.AwardHall_tehui.handlePanelData",GameUtilSenior.encode({actionid = "reqTeHuiData",params={index=2}}))
			curId=2
			GameUtilSenior.asyncload(var.xmlTeHui, "teHuiBg2", "ui/image/ContainerReward/th_shengyi.jpg")
			imgSelect:setPositionX(276)
		elseif senderName=="btnTh3" then
			GameSocket:PushLuaTable("gui.AwardHall_tehui.handlePanelData",GameUtilSenior.encode({actionid = "reqTeHuiData",params={index=3}}))
			curId=3
			GameUtilSenior.asyncload(var.xmlTeHui, "teHuiBg2", "ui/image/ContainerReward/th_zhizun.jpg")
			imgSelect:setPositionX(453)
		elseif senderName=="btnTh4" then
			GameSocket:PushLuaTable("gui.AwardHall_tehui.handlePanelData",GameUtilSenior.encode({actionid = "reqTeHuiData",params={index=4}}))
			curId=4
			GameUtilSenior.asyncload(var.xmlTeHui, "teHuiBg2", "ui/image/ContainerReward/th_zhuzai.jpg")
			imgSelect:setPositionX(625)
		elseif senderName=="btnThLing" then
			GameSocket:PushLuaTable("gui.AwardHall_tehui.handlePanelData",GameUtilSenior.encode({actionid = "buyGiftBag",params={index=curId}}))
		end
	end
	for i=1,#btnThArrs do
		local btn = var.xmlTeHui:getWidgetByName(btnThArrs[i])
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
		if var.teHuiIndex==i then
			prsBtnClick(btn)
		end
	end
end

--刷新展示物品
function ContainerActivities.updateTeHuiShow(data)
	for i=1,8 do
		local itemData = data.award[i]
		local awardItem=var.xmlTeHui:getWidgetByName("icon"..i)
		if itemData then
			local param={parent=awardItem, typeId=itemData.id, num=itemData.num}
			GUIItem.getItem(param)
--图片特效
			awardItem:removeChildByName("effectSprite")
			local effectSprite = awardItem:getChildByName("effectSprite")	
			if not effectSprite then 
				effectSprite = cc.Sprite:create()
					:setAnchorPoint(cc.p(0.5,0))
					:setPosition(cc.p(32,-318))
					:addTo(awardItem)
					:setScale(1.12)
					:setName("effectSprite")
					--:setLocalZOrder(10)
				--cc.AnimManager:getInstance():getPlistAnimateAsync(effectSprite,4, itemData.effectRes, 4, 0, 5)
				GameUtilSenior.addEffect(effectSprite,"spriteEffect",GROUP_TYPE.EFFECT,itemData.effectRes,false,false,true)
				effectSprite:setBlendFunc({src=gl.SRC_ALPHA,dst=gl.ONE})
			end
			awardItem:setVisible(true)
		else
			awardItem:setVisible(false)
		end
	end
	if data.buy==1 then
		var.xmlTeHui:getWidgetByName("btnThLing"):setVisible(false)
	else
		var.xmlTeHui:getWidgetByName("btnThLing"):setVisible(true)
	end
	-- var.xmlTeHui:getWidgetByName("labNeedVcion"):setString(data.vcion)
end

--------------------------------------------------------------沙巴克------------------------------------------------------------------
function ContainerActivities.initShaBaKe()
	if not var.xmlSbk then
		var.xmlSbk=GUIAnalysis.load("ui/layout/ContainerActivities_shabake.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlSbk, "img_sbk_bg", "ui/image/ContainerReward/img_act_sbkbg.jpg")
   		for i=1,5 do
   			local awardItem=var.xmlSbk:getWidgetByName("icon"..i)
			local param={parent=awardItem, typeId=40000005, num=1}
			GUIItem.getItem(param)
--图片特效
			awardItem:removeChildByName("effectSprite")
			local effectSprite = awardItem:getChildByName("effectSprite")	
			if not effectSprite then 
				effectSprite = cc.Sprite:create()
					:setAnchorPoint(cc.p(0.5,0))
					:setPosition(cc.p(32,-318))
					:addTo(awardItem)
					:setScale(1.12)
					:setName("effectSprite")
					--:setLocalZOrder(10)
				--cc.AnimManager:getInstance():getPlistAnimateAsync(effectSprite,4, 65080, 4, 0, 5)
				GameUtilSenior.addEffect(effectSprite,"spriteEffect",GROUP_TYPE.EFFECT,65080,false,false,true)
				effectSprite:setBlendFunc({src=gl.SRC_ALPHA,dst=gl.ONE})
			end
   		end
	else
		var.xmlSbk:show()
	end
end

--------------------------------------------------------------初始化竞技模块xml------------------------------------------------------------------
function ContainerActivities.initJingJi(tabname)
	if not var.xmlJinJi then
		var.xmlJinJi=GUIAnalysis.load("ui/layout/ContainerActivities_jingji.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlJinJi, "img_rank_bg", "ui/image/ContainerReward/img_actr_rankbg.jpg")
   		ContainerActivities.showSeePanel(true)
	else
		var.xmlJinJi:show()
	end
	var.curTabName=tabname
	var.xmlJinJi:getWidgetByName("rankBox"):setVisible(false)
	if tabname=="dengji" then
		var.xmlJinJi:getWidgetByName("labMuBiao"):setString("目标等级")
	else
		var.xmlJinJi:getWidgetByName("labMuBiao"):setString("目标阶数")
	end
end

--------------------------------------------------------------等级竞技------------------------------------------------------------------
function ContainerActivities.initJinJiList(data)
	if not data then return end
	local rankTable = data.rankTable
	local mingTable = data.mingTable

	--查看排名和领取奖励
	local function prsBtnClick(sender)
		local btnName = sender:getName()
		-- print(btnName,sender.index,var.curTabName)
		if btnName=="btnSee" then
			ContainerActivities.showSeePanel()
		elseif btnName=="btnLing" then
			if var.curTabName=="dengji" then
				GameSocket:PushLuaTable("gui.AwardHall_jingji.handlePanelData",GameUtilSenior.encode({actionid = "reqLevelAwrads",params={index=sender.index}}))
			elseif var.curTabName=="shenyi" then
				GameSocket:PushLuaTable("gui.AwardHall_jingji.handlePanelData",GameUtilSenior.encode({actionid = "reqShenYiAwrads",params={index=sender.index}}))
			elseif var.curTabName=="longxin" then
				GameSocket:PushLuaTable("gui.AwardHall_jingji.handlePanelData",GameUtilSenior.encode({actionid = "reqLongXinAwrads",params={index=sender.index}}))
			elseif var.curTabName=="langya" then
				GameSocket:PushLuaTable("gui.AwardHall_jingji.handlePanelData",GameUtilSenior.encode({actionid = "reqLangYaAwrads",params={index=sender.index}}))
			end
		end
	end

	--排名奖励列表
	local function updateRankList(item)
		local itemData = rankTable[item.tag]
		item:getWidgetByName("labRank"):setString(itemData.name):enableOutline(GameBaseLogic.getColor4(0x000000), 1)
		for i=1,2 do
			local awardItem=item:getWidgetByName("icon"..i)
			local param={parent=awardItem, typeId=itemData.award[i].id, num=itemData.award[i].num}
			GUIItem.getItem(param)
--图片特效
			awardItem:removeChildByName("effectSprite")
			local effectSprite = awardItem:getChildByName("effectSprite")	
			if not effectSprite then 
				effectSprite = cc.Sprite:create()
					:setAnchorPoint(cc.p(0.5,0))
					:setPosition(cc.p(32,-318))
					:addTo(awardItem)
					:setScale(1.12)
					:setName("effectSprite")
					--:setLocalZOrder(10)
				--cc.AnimManager:getInstance():getPlistAnimateAsync(effectSprite,4, itemData.award[i].effectRes, 4, 0, 5)
				GameUtilSenior.addEffect(effectSprite,"spriteEffect",GROUP_TYPE.EFFECT,itemData.award[i].effectRes,false,false,true)
				effectSprite:setBlendFunc({src=gl.SRC_ALPHA,dst=gl.ONE})
			end
		end
		GUIFocusPoint.addUIPoint(item:getWidgetByName("btnSee"),prsBtnClick)
		--倒计时设置
		local labCount = item:getWidgetByName("labCount")
		labCount:stopAllActions()
		local time = data.todaytime
		if time<=0 then
			labCount:setString("已结束")
		else
			labCount:setString(GameUtilSenior.setTimeFormat(time*1000,2))
			labCount:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function ()
				time = time - 1
				if time > 0 then
					labCount:setString(GameUtilSenior.setTimeFormat(time*1000,2))
				else
					labCount:stopAllActions()
					labCount:setString("已结束")
				end
			end)})))
		end
	end

	if not var.xmlJinJi then return end
	local rankList = var.xmlJinJi:getWidgetByName("rankList")
	rankList:reloadData(#rankTable,updateRankList):setSliderVisible(false)

	--全民奖励列表
	local function updateMingList(item)
		local itemData = mingTable[item.tag]
		local labLevel = item:getWidgetByName("labLevel")
		local imgIconRes = ""
		if data.cmd=="updateLevelJingJi" then
			if itemData.needLev>0 then
				labLevel:setString(itemData.needLev.."级"):enableOutline(GameBaseLogic.getColor4(0x000000), 1)
			elseif itemData.needZLev>0 then
				labLevel:setString(itemData.needZLev.."转"):enableOutline(GameBaseLogic.getColor4(0x000000), 1)
			end
			imgIconRes="img_level_icon"
		else
			labLevel:setString(itemData.needLev.."阶"):enableOutline(GameBaseLogic.getColor4(0x000000), 1)
			if data.cmd=="updateShenYiJingJi" then
				imgIconRes="wing"..itemData.needLev
			elseif data.cmd=="updateLongXinJingJi" then
				imgIconRes="longzhu"..itemData.needLev
			elseif data.cmd=="updateLangYaJingJi" then
				imgIconRes="langya"..itemData.needLev
			end
		end
		item:getWidgetByName("imgIcon"):loadTexture(imgIconRes, ccui.TextureResType.plistType)

		for i=1,3 do
			local awardItem=item:getWidgetByName("icon"..i)
			local param={parent=awardItem, typeId=itemData.award[i].id, num=itemData.award[i].num}
			GUIItem.getItem(param)
--图片特效	
			awardItem:removeChildByName("effectSprite")
			local effectSprite = awardItem:getChildByName("effectSprite")	
			if not effectSprite then 
				effectSprite = cc.Sprite:create()
					:setAnchorPoint(cc.p(0.5,0))
					:setPosition(cc.p(32,-318))
					:addTo(awardItem)
					:setScale(1.12)
					:setName("effectSprite")
					--:setLocalZOrder(10)
				--cc.AnimManager:getInstance():getPlistAnimateAsync(effectSprite,4, itemData.award[i].effectRes, 4, 0, 5)
				GameUtilSenior.addEffect(effectSprite,"spriteEffect",GROUP_TYPE.EFFECT,itemData.award[i].effectRes,false,false,true)
				effectSprite:setBlendFunc({src=gl.SRC_ALPHA,dst=gl.ONE})
			end
		end

		if itemData.allNum then--设置剩余数量
			if (itemData.allNum-itemData.lingNum)>0 then
				item:getWidgetByName("labYuNum"):setString((itemData.allNum-itemData.lingNum).."/"..itemData.allNum):enableOutline(GameBaseLogic.getColor4(0x000000), 1)
			else
				item:getWidgetByName("labYuNum"):setString((itemData.allNum-itemData.lingNum).."/"..itemData.allNum):enableOutline(GameBaseLogic.getColor4(0x000000), 1)
			end
		else
			item:getWidgetByName("labYuNum"):setString("不限"):setColor(GameBaseLogic.getColor(0x18d129)):enableOutline(GameBaseLogic.getColor4(0x000000), 1)
		end

		if itemData.ling then--设置全名的领取状态
			local imgFlag = item:getWidgetByName("imgFlag"):setVisible(false)
			local btnLing = item:getWidgetByName("btnLing"):setVisible(false)
			if itemData.ling==2 then
				imgFlag:loadTexture("img_wwc", ccui.TextureResType.plistType):setVisible(true)--未完成
			elseif itemData.ling==3 then
				imgFlag:loadTexture("img_ylq", ccui.TextureResType.plistType):setVisible(true)--已领取
			elseif itemData.ling==1 then
				btnLing:setVisible(true)
			end
			btnLing.index=itemData.index
			GUIFocusPoint.addUIPoint(btnLing,prsBtnClick)
		end

	end

	local mingList = var.xmlJinJi:getWidgetByName("mingList")
	mingList:reloadData(#data.mingTable,updateMingList):setSliderVisible(false)

	var.xmlJinJi:getWidgetByName("labTimeDesp"):setString(data.actTime)
	var.xmlJinJi:getWidgetByName("labDesp"):setString(data.actDesp)
end

--初始化查看排名面板
function ContainerActivities.showSeePanel(load)
	local function prsBtnClick(sender)
		var.xmlJinJi:getWidgetByName("rankBox"):setVisible(false)
	end
	local rankBox = var.xmlJinJi:getWidgetByName("rankBox")
	if load then
		-- GameUtilSenior.asyncload(var.xmlJinJi, "rankBox", "ui/image/ContainerReward/img_rank_seebg.png")
		local btnCloseRank = var.xmlJinJi:getWidgetByName("btnCloseRank")
		GUIFocusPoint.addUIPoint(btnCloseRank,prsBtnClick)
		rankBox:setTouchEnabled(true):hide()
		-- GameSocket:PushLuaTable("gui.AwardHall_jingji.handlePanelData",GameUtilSenior.encode({actionid = "reqRankInfo",params={index=var.jinJiIndex}}))
	else
		if rankBox:isVisible() then
			rankBox:hide()
		else
			-- rankBox:show()
			GameSocket:PushLuaTable("gui.AwardHall_jingji.handlePanelData",GameUtilSenior.encode({actionid = "reqRankInfo",params={index=var.jinJiIndex}}))
		end
	end
end

function ContainerActivities.updateRankInfo(data)
	for i=1,5 do
		if data[i] and data[i]~="" then
			var.xmlJinJi:getWidgetByName("labRank"..i):setString(data[i])
		else
			var.xmlJinJi:getWidgetByName("labRank"..i):setString("虚位以待")
		end
	end
	var.xmlJinJi:getWidgetByName("rankBox"):setVisible(true)
end



---------------------------------------七天狂欢-----------------------------------------------
function ContainerActivities.initSevenDay()
	if not var.xmlSevenDay then
		var.xmlSevenDay=GUIAnalysis.load("ui/layout/ContainerActivities_sevenday.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlSevenDay, "img_bg", "ui/image/activity_7.jpg")
   		GameSocket:PushLuaTable("gui.AwardHall_sevenday.handlePanelData",GameUtilSenior.encode({actionid = "updataSevenDay"}))
	else
		var.xmlSevenDay:show()
	end
end

function ContainerActivities.updataSevenDay(data)
	local list = var.xmlSevenDay:getWidgetByName("list_rank")
	local function updateRankList(item)
		local index = item.tag
		local itemDatas = data.awards[index].awards
		for j=1,#itemDatas do
			local itemData = itemDatas[j]
			local awardItem=item:getWidgetByName("icon1_"..j)
			if itemData then
				awardItem:setVisible(true)
				local param={parent=awardItem, typeId=itemData.id, num=itemData.num}
				GUIItem.getItem(param)
			else
				awardItem:setVisible(false)
			end
		end
		if data.awards[index].name~="" then
			item:getWidgetByName("labName1"):setString(data.awards[index].name):setVisible(true)
			item:getWidgetByName("img1"):setVisible(false)
		else
			item:getWidgetByName("labName1"):setVisible(false)
			item:getWidgetByName("img1"):setVisible(true)
		end
		item:getWidgetByName("img_rank"):loadTexture("seven_Num_"..index, ccui.TextureResType.plistType)
	end
	list:reloadData(#data.awards,updateRankList)
	if data.myRank>0 then  
		var.xmlSevenDay:getWidgetByName("labMyRank"):setString("第"..data.myRank.."名")
	else
		var.xmlSevenDay:getWidgetByName("labMyRank"):setString("未上榜")
	end
	var.xmlSevenDay:getWidgetByName("labName1_0_0_1"):setString("充值满20万RMB")
	var.xmlSevenDay:getWidgetByName("labMyXiaoFei"):setString(data.curXiaoFei)

	ContainerActivities.updateCount(var.xmlSevenDay,data.time)
end


return ContainerActivities