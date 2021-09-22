local ContainerBossMonsterPuzzle={}
local var = {}
local despTable ={
	[1]="<font color=#E7BA52 size=18>回收说明：</font>",
	[2]="<font color=#f1e8d0>1、回收boss拼图可以获得炼魂值</font>",
    [3]="<font color=#f1e8d0>2、越高级的boss拼图获得的炼魂值越多</font>",
}
local despTable2 ={
	[1]="<font color=#E7BA52 size=18>炼魂说明：</font>",
	[2]="<font color=#f1e8d0>1、回收boss拼图可以获得炼魂值</font>",
    [3]="<font color=#f1e8d0>2、升级炼魂等级可以获得属性加成</font>",
}

function ContainerBossMonsterPuzzle.initView()
	var = {
		xmlPanel,
		xmlPinTu,
		xmlLinHun,
		xmlBuy,
		xmlHuiShou,
		curTab,
		lianHunLev,
		lianHunBar,
		curVcion,
		curBVcion,
		curMoney,
		buyData,
		curPicIndex=1,
		fireworks,
		fireworks2,
		fireworks3,
		fireworks4,
		bagData={},
		huiShouData={},
		pictrueIds={0,0,0,0,0,0,0,0,0},
		redsTable={},
		curTabIndex=1,

	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerBossMonsterPuzzle.uif");
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerBossMonsterPuzzle.handlePanelData)
			:addEventListener(GameMessageCode.EVENT_GAME_MONEY_CHANGE, ContainerBossMonsterPuzzle.updateGameMoney)
		ContainerBossMonsterPuzzle.initTabs()
	end
	return var.xmlPanel
end

function ContainerBossMonsterPuzzle.onPanelOpen()
	ContainerBossMonsterPuzzle.updateGameMoney(nil)
	var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab(var.curTabIndex)
end

function ContainerBossMonsterPuzzle.onPanelClose()

end

function ContainerBossMonsterPuzzle.handlePanelData(event)
	if event.type ~= "ContainerBossMonsterPuzzle" then return end
	local data = GameUtilSenior.decode(event.data)
	-- print(event.data)
	if data.cmd =="senderLinHunData" then
		ContainerBossMonsterPuzzle.initBuy(data)
	elseif data.cmd=="updatePinTuData" then
		ContainerBossMonsterPuzzle.updatePinTu(data)
	elseif data.cmd=="pinTuUseSuccessed" then
		GameSocket:PushLuaTable("gui.ContainerBossMonsterPuzzle.handlePanelData",GameUtilSenior.encode({actionid = "reqPinTuData",params={index=var.curPicIndex}}))

	----------------------------------炼魂通讯---------------------------------------
	elseif data.cmd=="updateLianHunData" then
		ContainerBossMonsterPuzzle.updateLianHun(data)

	----------------------------------回收通讯---------------------------------------
	elseif data.cmd=="huiShouSuccessed" then
		var.bagData=GameBaseLogic.getPinTuPos()
		var.huiShouData={}
		ContainerBossMonsterPuzzle.initLists()
	end
end

--初始化页签
function ContainerBossMonsterPuzzle.initTabs()
	local function pressTabH(sender)
		local tag = sender:getTag()
		if var.curTab then var.curTab:hide() end
		if tag==1 then
			var.curTab = ContainerBossMonsterPuzzle.initPinTu()
		elseif tag==2 then
			var.curTab = ContainerBossMonsterPuzzle.initLinHun()
		end
		var.curTabIndex=tag
	end
	var.tablisth = var.xmlPanel:getWidgetByName("box_tab")
	var.tablisth:addTabEventListener(pressTabH)
	var.tablisth:setSelectedTab(1)
end

--------------------------------------------------------拼图------------------------------------------------------------
function ContainerBossMonsterPuzzle.initPinTu()
	if not var.xmlPinTu then
		var.xmlPinTu=GUIAnalysis.load("ui/layout/ContainerBossMonsterPuzzle_pintu.uif")
							:addTo(var.xmlPanel:getWidgetByName("panel_bg"))
   							:show()
   		GameUtilSenior.asyncload(var.xmlPinTu, "imgLoadLeft", "ui/image/img_puzzle.jpg")
   		GameUtilSenior.asyncload(var.xmlPinTu, "imgBossPic", "ui/image/BossPictrues/1.jpg")
   		GameUtilSenior.asyncload(var.xmlPinTu, "box_mask", "ui/image/BossPictrues/imgMaskLine.png")
   		ContainerBossMonsterPuzzle.initPinTuBtns()
   		ContainerBossMonsterPuzzle.initMaskClick()
	else
		var.xmlPinTu:show()
	end
	GameSocket:PushLuaTable("gui.ContainerBossMonsterPuzzle.handlePanelData",GameUtilSenior.encode({actionid = "reqFristPinTuData",params={index=var.curPicIndex}}))
	return var.xmlPinTu
end

local btnArrs = {"btnHuiShou","btnBuyTu","btnJiHuo","btnPre","btnNext"}
function ContainerBossMonsterPuzzle.initPinTuBtns()
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		if senderName=="btnHuiShou" then
			ContainerBossMonsterPuzzle.initHuiShou()
		elseif senderName=="btnBuyTu" then

		elseif senderName=="btnJiHuo" then
			GameSocket:PushLuaTable("gui.ContainerBossMonsterPuzzle.handlePanelData",GameUtilSenior.encode({actionid = "reqJiHuoPictrue",params={index=var.curPicIndex}}))
		elseif senderName=="btnPre" then
			ContainerBossMonsterPuzzle.changePinTu(-1)
		elseif senderName=="btnNext" then
			ContainerBossMonsterPuzzle.changePinTu(1)
		end
	end
	for i=1,#btnArrs do
		local btn = var.xmlPinTu:getWidgetByName(btnArrs[i])
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
		if btnArrs[i]=="btnPre" then
			var.xmlPinTu:getWidgetByName(btnArrs[i]):setRotation(180)
			var.xmlPinTu:getWidgetByName("imgRedPre"):setRotation(180)
		end
	end
end

--拼图切换操作
function ContainerBossMonsterPuzzle.changePinTu(flag)
	if flag>0 and var.curPicIndex>=19 then return end
	if flag<0 and var.curPicIndex<=1 then return end
	var.curPicIndex=var.curPicIndex+flag
	var.xmlPinTu:getWidgetByName("labPage"):setString(var.curPicIndex.."/19")
	local btnNext = var.xmlPinTu:getWidgetByName("btnNext")
	local btnPre = var.xmlPinTu:getWidgetByName("btnPre")
	if var.curPicIndex>=19 then
		btnNext:setEnabled(false)
	else
		btnNext:setEnabled(true)
	end
	if var.curPicIndex<=1 then
		btnPre:setEnabled(false)
	else
		btnPre:setEnabled(true)
	end
	ContainerBossMonsterPuzzle.setBtnRedShow()
	GameSocket:PushLuaTable("gui.ContainerBossMonsterPuzzle.handlePanelData",GameUtilSenior.encode({actionid = "reqPinTuData",params={index=var.curPicIndex}}))
end

--刷新拼图的界面数据
function ContainerBossMonsterPuzzle.updatePinTu(data)
	GameUtilSenior.asyncload(var.xmlPinTu, "imgBossPic", "ui/image/BossPictrues/"..data.picName..".jpg")
	var.xmlPinTu:getWidgetByName("imgBossPic"):setScale(434/var.xmlPinTu:getWidgetByName("imgBossPic"):getContentSize().width,394/var.xmlPinTu:getWidgetByName("imgBossPic"):getContentSize().height)
	var.xmlPinTu:getWidgetByName("labWg"):setString(data.dc.."-"..data.dc2)
	var.xmlPinTu:getWidgetByName("labMg"):setString(data.mc.."-"..data.mc2)
	var.xmlPinTu:getWidgetByName("labDg"):setString(data.sc.."-"..data.sc2)
	var.xmlPinTu:getWidgetByName("labWf"):setString(data.ac.."-"..data.ac2)
	var.xmlPinTu:getWidgetByName("labMf"):setString(data.mac.."-"..data.mac2)
	-- var.xmlPinTu:getWidgetByName("labHp"):setString(data.hp)

	if data.picInfo then
		local btnJiHuo = var.xmlPinTu:getWidgetByName("btnJiHuo")
		if data.picInfo[10]>0 then--已被激活
			var.xmlPinTu:getWidgetByName("labBossInfo"):setString(data.bossName.."：9/9")
			var.xmlPinTu:getWidgetByName("box_mask"):setVisible(false)
			-- ContainerBossMonsterPuzzle.pinTuAnimate(true)
			btnJiHuo:removeChildByName("img_bln")
		else
			local openNum = 0
			for i=1,9 do
				local btnMask = var.xmlPinTu:getWidgetByName("imgMask"..i)
				btnMask:removeChildByName("img_bln")
				if data.picInfo[i]>0 then
					openNum=openNum+1
					btnMask:setVisible(false)
				else
					btnMask:setVisible(true)
					if data.haveState and data.haveState[i]>=1 then
						GameUtilSenior.addHaloToButton(btnMask, "pt_light"..i)
					end
				end
			end
			var.xmlPinTu:getWidgetByName("labBossInfo"):setString(data.bossName.."："..openNum.."/9")
			var.xmlPinTu:getWidgetByName("box_mask"):setVisible(true)
			-- ContainerBossMonsterPuzzle.pinTuAnimate(false)
			if openNum>=9 then
				GameUtilSenior.addHaloToButton(btnJiHuo, "btn_normal_light3")
			else
				btnJiHuo:removeChildByName("img_bln")
			end
		end
	end
	if data.haveState then
		var.pictrueIds=data.haveState
	end
	if data.upSucceed then
		ContainerBossMonsterPuzzle.pinTuAnimate()
		ContainerBossMonsterPuzzle.pinTuAnimate3()
	end
	var.curPicIndex=data.index
	var.xmlPinTu:getWidgetByName("labPage"):setString(var.curPicIndex.."/19")
	if var.curPicIndex==1 then
		var.xmlPinTu:getWidgetByName("btnPre"):setEnabled(false)
		var.xmlPinTu:getWidgetByName("btnNext"):setEnabled(true)
	elseif var.curPicIndex==19 then
		var.xmlPinTu:getWidgetByName("btnPre"):setEnabled(true)
		var.xmlPinTu:getWidgetByName("btnNext"):setEnabled(false)
	end
	var.redsTable=data.redData
	ContainerBossMonsterPuzzle.setBtnRedShow()
end

--设置左右按钮的红点
function ContainerBossMonsterPuzzle.setBtnRedShow()
	local imgRedPre=var.xmlPinTu:getWidgetByName("imgRedPre"):setVisible(false)
	local imgRedNext=var.xmlPinTu:getWidgetByName("imgRedNext"):setVisible(false)
	if var.curPicIndex>1 then
		for i=1,(var.curPicIndex-1) do
			if var.redsTable[i] and var.redsTable[i]>0 then
				imgRedPre:setVisible(true)
				break
			end
		end
	end
	if var.curPicIndex<19 then
		for i=(var.curPicIndex+1),19 do
			if var.redsTable[i] and var.redsTable[i]>0 then
				imgRedNext:setVisible(true)
				break
			end
		end
	end
end

--遮罩点击开启操作
function ContainerBossMonsterPuzzle.initMaskClick()
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		local typeId = var.pictrueIds[sender.index]
		GameSocket:PushLuaTable("gui.ContainerBossMonsterPuzzle.handlePanelData",GameUtilSenior.encode({actionid = "repOpenPinTuMask",params={index=var.curPicIndex,maskid=var.pictrueIds[sender.index]}}))
	end
	for i=1,9 do
		local btnMask = var.xmlPinTu:getWidgetByName("imgMask"..i):setTouchEnabled(true)
		btnMask.index=i
		GUIFocusPoint.addUIPoint(btnMask,prsBtnClick)
	end
end

--拼图激活特效
function ContainerBossMonsterPuzzle.pinTuAnimate(isshow)
	if not var.fireworks3 then
		var.fireworks3 = cc.Sprite:create():addTo(var.xmlPinTu):pos(246,296)
	end
	local animate = cc.AnimManager:getInstance():getPlistAnimate(4,6552000,4,4,false,false,0,function(animate,shouldDownload)
							if animate then
								var.fireworks3:setVisible(true)
								var.fireworks3:stopAllActions()
								var.fireworks3:runAction(cca.seq({
									cca.rep(animate,1),
									cca.cb(function (target)
										var.fireworks3:setVisible(false)
										ContainerBossMonsterPuzzle.pinTuAnimate2()
									end)
									-- cca.removeSelf(),
								}))
							end
							if shouldDownload==true then
								var.xmlPinTu:release()
								var.fireworks3:release()
							end
						end,
						function(animate)
							var.xmlPinTu:retain()
							var.fireworks3:retain()
						end)
end

--拼图激活特效
function ContainerBossMonsterPuzzle.pinTuAnimate2()
	if not var.fireworks4 then
		var.fireworks4 = cc.Sprite:create():addTo(var.xmlPinTu):pos(246,296)
	end
	local animate = cc.AnimManager:getInstance():getPlistAnimate(4,6552000,4,4,false,false,0,function(animate,shouldDownload)
							if animate then
								var.fireworks4:setVisible(true)
								var.fireworks4:stopAllActions()
								var.fireworks4:runAction(cca.seq({
									cca.rep(animate:reverse(),1),
									cca.cb(function (target)
										var.fireworks4:setVisible(false)
									end)
									-- cca.removeSelf(),
								}))
							end
							if shouldDownload==true then
								var.xmlPinTu:release()
								var.fireworks4:release()
							end
						end,
						function(animate)
							var.xmlPinTu:retain()
							var.fireworks4:retain()
						end)
end

--图片由暗到亮
function ContainerBossMonsterPuzzle.pinTuAnimate3()
	local value = 100
	local bigPic = var.xmlPinTu:getWidgetByName("imgBossPic"):setOpacity(value)
	bigPic:stopAllActions()
	bigPic:runAction(cca.repeatForever(cca.seq({cca.delay(0.05), cca.callFunc(function ()
		value = value+5
		bigPic:setOpacity(value)
		if value>=255 then
			bigPic:stopAllActions()
		end
	end)})))
end

--------------------------------------------------------炼魂------------------------------------------------------------
function ContainerBossMonsterPuzzle.initLinHun()
	if not var.xmlLinHun then
		var.xmlLinHun=GUIAnalysis.load("ui/layout/ContainerBossMonsterPuzzle_lianhun.uif")
							:addTo(var.xmlPanel:getWidgetByName("panel_bg"))
   							:show()
   		local btnDesp = var.xmlLinHun:getWidgetByName("Image_240_18"):setTouchEnabled(true)
		btnDesp:addTouchEventListener(function (pSender, touchType)
			if touchType == ccui.TouchEventType.began then
				ContainerBossMonsterPuzzle.huiShouDesp(despTable2)
			elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then
				GDivDialog.handleAlertClose()
			end
		end)
   		ContainerBossMonsterPuzzle.initPinTuBtns()
   		var.lianHunBar=var.xmlPanel:getWidgetByName("linHunBar"):setPercent(20,100):setFontSize(18):enableOutline(GameBaseLogic.getColor(0x000000),1)
   		var.lianHunLev = ccui.TextAtlas:create("0123456789", "image/typeface/num_27.png", 20, 25, "0")
			:addTo(var.xmlLinHun)
			:align(display.CENTER, 350,503)
			:setString(12)
		ContainerBossMonsterPuzzle.initLinHunBtns()
		ContainerBossMonsterPuzzle.lianHunAnimate()
	else
		var.xmlLinHun:show()
	end
	GameSocket:PushLuaTable("gui.ContainerBossMonsterPuzzle.handlePanelData",GameUtilSenior.encode({actionid = "reqLianHunData",params={}}))
	return var.xmlLinHun
end

--炼魂火特效
function ContainerBossMonsterPuzzle.lianHunAnimate()
	if not var.fireworks then
		var.fireworks = cc.Sprite:create():addTo(var.xmlLinHun):pos(246,310)
	end
	local animate = cc.AnimManager:getInstance():getPlistAnimate(4,6550000,4,4,false,false,0,function(animate,shouldDownload)
							if animate then
								var.fireworks:stopAllActions()
								var.fireworks:runAction(cca.seq({
									cca.rep(animate,10000),
									cca.removeSelf(),
								}))
							end
							if shouldDownload==true then
								var.xmlPinTu:release()
								var.fireworks:release()
							end
						end,
						function(animate)
							var.xmlPinTu:retain()
							var.fireworks:retain()
						end)
end

--炼魂火升级特效
function ContainerBossMonsterPuzzle.lianHunAnimate2()
	var.fireworks2 = cc.Sprite:create():addTo(var.xmlLinHun):pos(300,400)
	local animate = cc.AnimManager:getInstance():getPlistAnimate(4,50022,4,4,false,false,0,function(animate,shouldDownload)
							if animate then
								var.fireworks2:stopAllActions()
								var.fireworks2:runAction(cca.seq({
									cca.rep(animate,1),
									cca.removeSelf(),
								}))
							end
							if shouldDownload==true then
								var.xmlPinTu:release()
								var.fireworks2:release()
							end
						end,
						function(animate)
							var.xmlPinTu:retain()
							var.fireworks2:retain()
						end)
end

local btnArrs2 = {"btnShengJi","btnHuiShou","btnBuyTu"}
function ContainerBossMonsterPuzzle.initLinHunBtns()
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		if senderName=="btnHuiShou" then
			ContainerBossMonsterPuzzle.initHuiShou()
		elseif senderName=="btnBuyTu" then
			ContainerBossMonsterPuzzle.clickBtnBuy("lianhun")
		elseif senderName=="btnShengJi" then
			GameSocket:PushLuaTable("gui.ContainerBossMonsterPuzzle.handlePanelData",GameUtilSenior.encode({actionid = "shengJiLianHun",params={}}))
		end
	end
	for i=1,#btnArrs2 do
		local btn = var.xmlLinHun:getWidgetByName(btnArrs2[i])
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
	end
end

--刷新拼图的界面数据
function ContainerBossMonsterPuzzle.updateLianHun(data)
	local job = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)
	if data and data.dataTable then
		var.xmlLinHun:getWidgetByName("labWg"):setString(data.dataTable.wgmin.."-"..data.dataTable.wgmax)
		var.xmlLinHun:getWidgetByName("labMg"):setString(data.dataTable.mgmin.."-"..data.dataTable.mgmax)
		var.xmlLinHun:getWidgetByName("labDg"):setString(data.dataTable.dgmin.."-"..data.dataTable.dgmax)
		var.xmlLinHun:getWidgetByName("labWf"):setString(data.dataTable.wfmin.."-"..data.dataTable.wfmax)
		var.xmlLinHun:getWidgetByName("labMf"):setString(data.dataTable.mfmin.."-"..data.dataTable.mfmax)
		if job==100 then
			var.xmlLinHun:getWidgetByName("labHp"):setString(data.dataTable.zhanhp)
		elseif job==101 then
			var.xmlLinHun:getWidgetByName("labHp"):setString(data.dataTable.fahp)
		elseif job==102 then
			var.xmlLinHun:getWidgetByName("labHp"):setString(data.dataTable.daohp)
		end
	end
	var.lianHunLev:setString(data.curLevel)
	var.lianHunBar:setPercent(data.ownExp,data.needExp)

	local btnShengJi = var.xmlLinHun:getWidgetByName("btnShengJi")
	if tonumber(data.ownExp)>=tonumber(data.needExp) then
		GameUtilSenior.addHaloToButton(btnShengJi, "btn_normal_light3")
	else
		btnShengJi:removeChildByName("img_bln")
	end
	if data.upSucceed then
		ContainerBossMonsterPuzzle.lianHunAnimate2()
	end
end

-----------------------------------------拼图回收-----------------------------------------------
function ContainerBossMonsterPuzzle.initHuiShou()
	if not var.xmlHuiShou then
		var.xmlHuiShou = GUIAnalysis.load("ui/layout/ContainerBossMonsterPuzzle_huishou.uif")
				:addTo(var.xmlPanel:getWidgetByName("panel_bg"),20):align(display.CENTER, 465, 295)
				:show()
		--GameUtilSenior.asyncload(var.xmlHuiShou, "imgBg", "ui/image/img_bosspic_hsbg.png")

		local btnDesp = var.xmlHuiShou:getWidgetByName("btnDesp"):setTouchEnabled(true)
		btnDesp:addTouchEventListener(function (pSender, touchType)
			if touchType == ccui.TouchEventType.began then
				ContainerBossMonsterPuzzle.huiShouDesp(despTable)
			elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then
				GDivDialog.handleAlertClose()
			end
		end)

		var.xmlHuiShou:getWidgetByName("btnback"):addClickEventListener(function (sender)--关闭回收
   			var.xmlHuiShou:hide()
		end)

		var.xmlHuiShou:getWidgetByName("btn_add"):addClickEventListener(function (sender)--一键添加
   			var.bagData={}
   			var.huiShouData=GameBaseLogic.getPinTuPos()
   			ContainerBossMonsterPuzzle.initLists()
		end)

		var.xmlHuiShou:getWidgetByName("btn_huishou"):addClickEventListener(function (sender)--一键回收
   			if #var.huiShouData>0 then
   				GameSocket:PushLuaTable("gui.ContainerBossMonsterPuzzle.handlePanelData",GameUtilSenior.encode({actionid = "startHuiShow",params={posArr=var.huiShouData}}))
   			end
		end)
	else
		var.xmlHuiShou:show()
	end

	var.bagData=GameBaseLogic.getPinTuPos()
	var.huiShouData={}
	ContainerBossMonsterPuzzle.initLists()
end

function ContainerBossMonsterPuzzle.initLists()
	local listBag = var.xmlPanel:getWidgetByName("list_bag"):setSliderVisible(false)
	listBag:reloadData(60,ContainerBossMonsterPuzzle.updateBagList)

	local listShou = var.xmlPanel:getWidgetByName("list_shou"):setSliderVisible(false)
	listShou:reloadData(60,ContainerBossMonsterPuzzle.updateShouList)

end

function ContainerBossMonsterPuzzle.updateBagList(item)
	if var.bagData[item.tag] then
		local param = {
			parent = item,
			pos = var.bagData[item.tag],
			-- iconType = GameConst.ICONTYPE.DEPOT,
			-- titleText = GameConst.str_take_out,
			tipsType = GameConst.TIPS_TYPE.UPGRADE,
			enmuPos = 6,
			customCallFunc = function()
				local curValue = var.bagData[item.tag]
				table.removebyvalue(var.bagData,curValue)
				table.insert(var.huiShouData,curValue)
				ContainerBossMonsterPuzzle.initLists()
			end,
			doubleCall = function()
				local curValue = var.bagData[item.tag]
				table.removebyvalue(var.bagData,curValue)
				table.insert(var.huiShouData,curValue)
				ContainerBossMonsterPuzzle.initLists()
			end
		}
		GUIItem.getItem(param)
	else
		if item:getWidgetByName("item_icon") then
			item:getWidgetByName("item_icon"):removeFromParent()
		end
	end
end

function ContainerBossMonsterPuzzle.updateShouList(item)
	if var.huiShouData[item.tag] then
		local param = {
			parent = item,
			pos = var.huiShouData[item.tag],
			-- iconType = GameConst.ICONTYPE.DEPOT,
			-- titleText = GameConst.str_take_out,
			tipsType = GameConst.TIPS_TYPE.UPGRADE,
			enmuPos = 3,
			customCallFunc = function()
				local curValue = var.huiShouData[item.tag]
				table.removebyvalue(var.huiShouData,curValue)
				table.insert(var.bagData,curValue)
				ContainerBossMonsterPuzzle.initLists()
			end,
			doubleCall = function()
				local curValue = var.huiShouData[item.tag]
				table.removebyvalue(var.huiShouData,curValue)
				table.insert(var.bagData,curValue)
				ContainerBossMonsterPuzzle.initLists()
			end,
		}
		GUIItem.getItem(param)
	else
		if item:getWidgetByName("item_icon") then
			item:getWidgetByName("item_icon"):removeFromParent()
		end
	end
end

function ContainerBossMonsterPuzzle.huiShouDesp(desptable)
	local mParam = {
	name = GameMessageCode.EVENT_PANEL_ON_ALERT,
	panel = "tips",
	infoTable = desptable,
	visible = true,
	}
	GameSocket:dispatchEvent(mParam)

end

-----------------------------------------拼图材料购买-----------------------------------------------
function ContainerBossMonsterPuzzle.initBuy(data)
	if not var.xmlBuy then
		var.xmlBuy = GUIAnalysis.load("ui/layout/ContainerBossMonsterPuzzle_buy.uif")
				:addTo(var.xmlLinHun):align(display.CENTER, 750, 250)
				:show()
		GameUtilSenior.asyncload(var.xmlBuy, "imgBg", "ui/image/img_bosspic_buy.png")
		local function prsBtnItem(sender)
			var.xmlBuy:hide()
		end
		GUIFocusPoint.addUIPoint(var.xmlBuy:getWidgetByName("btnback"), prsBtnItem)
		var.xmlBuy:getWidgetByName("btnChongZhi"):setTouchEnabled(true):addClickEventListener(function ()
   			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
   		end)

	else
		var.xmlBuy:show()
	end
	var.buyData=data.data
	local listBuy = var.xmlBuy:getWidgetByName("listBuy")
	listBuy:reloadData(#var.buyData,ContainerBossMonsterPuzzle.updateBuy):setSliderVisible(false)
	var.xmlBuy:getWidgetByName("lblbindcoin"):setString(var.curBVcion)
	var.xmlBuy:getWidgetByName("lblcoin"):setString(var.curVcion)
end

function ContainerBossMonsterPuzzle.updateBuy(item)
	local itemData = var.buyData[item.tag]
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

--跟新元宝和绑元变化
function ContainerBossMonsterPuzzle.updateGameMoney(event)
	if var.xmlPanel then
		local mainrole = GameSocket.mCharacter
		var.curVcion=mainrole.mVCoin or 0
		var.curBVcion=mainrole.mVCoinBind or 0
		var.curMoney=mainrole.mGameMoney or 0
		if var.xmlBuy then
			var.xmlBuy:getWidgetByName("lblVcoin"):setString(var.curVcion)
			var.xmlBuy:getWidgetByName("lblMoney"):setString(var.curMoney)
		end
	end
end

--点击购买按钮操作
function ContainerBossMonsterPuzzle.clickBtnBuy(type)
	if var.xmlBuy and var.xmlBuy:isVisible() then
		var.xmlBuy:hide()
	else
		if type=="pintu" then
			GameSocket:PushLuaTable("gui.ContainerBossMonsterPuzzle.handlePanelData", GameUtilSenior.encode({actionid = "reqPinTuBuyData"}))
		elseif type=="lianhun" then
			GameSocket:PushLuaTable("gui.ContainerBossMonsterPuzzle.handlePanelData", GameUtilSenior.encode({actionid = "reqLinHunBuyData"}))
		end
	end
end



return ContainerBossMonsterPuzzle