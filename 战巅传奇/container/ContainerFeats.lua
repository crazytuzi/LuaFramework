local ContainerFeats={}
local var = {}
local MAXITEM = 15--保存开箱子最大条数

local despBigBox ={
	[1] = 	"<font color=#E7BA52 size=18>宝箱说明：</font>",
	[2] =	"<font color=#f1e8d0>1.完成指定任务即可获得功勋值</font>",
	[3] =	"<font color=#f1e8d0>2.功勋达到一定数量时可以领取功勋宝箱,还可获得<font color=#ff0000>转生丹</font>,提升转生等级</font>",
	[4] =	"<font color=#f1e8d0>3.使用后随机获得以下物品:副本卷轴、护卫经验丹(小)、100绑元、金砖(小)、玛雅卷轴、护盾碎片(小)</font>",
}

function ContainerFeats.initView()
	var = {
		xmlPanel,
		xmlPage,
		progressBar,
		labBar,
		gxData=nil,
		taskData=nil,
		roleName,
		gongXunListInfos=nil,
		boxNum=0,--功勋宝箱个数
		gxNum=0,--功勋值
		fireworks=nil,
		fireworks2=nil,
		fireworks3=nil,
		curBoxNum=0,

	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerFeats.uif");
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerFeats.handlePanelData)
		ContainerFeats.initBtns()
		-- ContainerFeats.updateGongXun(nil)
		var.roleName = GameCharacter._mainAvatar:NetAttr(GameConst.net_name)
		GameUtilSenior.asyncload(var.xmlPanel, "imgBg", "ui/image/meritorious_bg.jpg")
		-- var.boxNum= display.newBMFontLabel({font = "image/typeface/gxnum.fnt",})
		-- 	:addTo(var.xmlPanel)
		-- 	:align(display.BOTTOM_LEFT,460,150)
		-- 	:setString("0")

		var.boxNum = ccui.TextAtlas:create("0123456789","image/typeface/num_2.png", 30, 40,"0")
			:setName("boxNum")
			:addTo(var.xmlPanel)
			:align(display.BOTTOM_LEFT,590,91)
			:setString("0")

		var.gxNum = ccui.TextAtlas:create("0123456789","image/typeface/num_1.png", 20, 24,"0")
			:setName("gxNum")
			:addTo(var.xmlPanel)
			:align(display.BOTTOM_LEFT,286,309)
			:setString("0")

		-- var.gxNum= display.newBMFontLabel({font = "image/typeface/num_23.fnt",})
		-- 	:addTo(var.xmlPanel)
		-- 	:align(display.BOTTOM_LEFT,156,353)
		-- 	:setString("0")
		var.xmlPanel:getWidgetByName("bar"):setLabelVisible(false)
		var.xmlPanel:getWidgetByName("awardList"):setVisible(false)
		-- ContainerFeats.successAnimate2()
		ContainerFeats.initDesp()
		GameSocket:PushLuaTable("gui.ContainerFeats.handlePanelData",GameUtilSenior.encode({actionid = "reqListData"}))
		-- ContainerFeats.successAnimate3()

		local awardItem=var.xmlPanel:getWidgetByName("icon3"):setScale(0.5):setTouchEnabled(true)
		local param={parent=awardItem , typeId=23040003,showBg = false}
		GUIItem.getItem(param)
		local awardItem2=var.xmlPanel:getWidgetByName("icon4"):setScale(0.5):setTouchEnabled(true)
		local param={parent=awardItem2 , typeId=23040003,showBg = false}
		GUIItem.getItem(param)
	end
	return var.xmlPanel
end

function ContainerFeats.handlePanelData(event)
	if event.type ~= "ContainerFeats" then return end
	local data = GameUtilSenior.decode(event.data)
	if data.cmd =="senderGongXunData" then
		var.gxData=data.data
		ContainerFeats.initPage("btnBuy")
	elseif data.cmd=="senderTaskData" then
		var.taskData=data.data
		ContainerFeats.initPage("btnTask")
	elseif data.cmd=="updateGongXun" then
		ContainerFeats.updateGongXun(data)
	elseif data.cmd=="updateGetRecord" then
		ContainerFeats.getMyGongXunListInfos(data.record)
		var.boxNum:setString(data.boxNum)
		var.curBoxNum=data.boxNum
		var.xmlPanel:getWidgetByName("awardList"):setVisible(true)
	elseif data.cmd=="updateGongXunFly" then
		ContainerFeats.iconFly(data.typeId)
	end
end

function ContainerFeats.onPanelOpen()
	ContainerFeats.getGongXunListInfos()
	GameSocket:PushLuaTable("gui.ContainerFeats.handlePanelData",GameUtilSenior.encode({actionid = "reqGongXunData"}))
end

function ContainerFeats.onPanelClose()

end

local dunTable = {30,60,90,120}
function ContainerFeats.updateGongXun(data)
	local curGx = data.curGx
	local bar = var.xmlPanel:getWidgetByName("bar")
	-- bar:setPercentWithAnimation(10,100)
	-- bar:setLabelVisible(false)
	if bar then
		bar:setPercent(curGx,120):setFontSize(18):enableOutline(GameBaseLogic.getColor(0x000049),1)
	end
	-- bar:resetLabelFormat( "fkjjkjdkj%d/%ddsds" )
	var.boxNum:setString(data.curBoxNum)
	var.curBoxNum=data.curBoxNum
	-- ContainerFeats.successAnimate2()
	var.gxNum:setString(curGx)
	for i=1,#dunTable do
		local btnBox = var.xmlPanel:getWidgetByName("btnBox"..i):setTouchEnabled(true)
		if curGx>=dunTable[i] then
			btnBox:setEnabled(true)
			if data.stateTable[i]>=1 then
				var.xmlPanel:getWidgetByName("imgLing"..i):setVisible(true)
				btnBox:setTouchEnabled(false)
				btnBox:removeChildByName("img_bln")
			else
				var.xmlPanel:getWidgetByName("imgLing"..i):setVisible(false)
				GameUtilSenior.addHaloToButton(btnBox, "btn_normal_light10",{x = 28,y =27})
			end
		else
			var.xmlPanel:getWidgetByName("imgLing"..i):setVisible(false)
			btnBox:setEnabled(false)
		end
	end
	-- if data.curRank==0 or data.curRank>100 then
	-- 	var.xmlPanel:getWidgetByName("labRank"):setString("百名之外")
	-- else
	-- 	var.xmlPanel:getWidgetByName("labRank"):setString("第"..data.curRank.."名")
	-- end
	if var.curBoxNum > 0 then
		GameUtilSenior.addHaloToButton(var.xmlPanel:getWidgetByName("btnBigBox"), "img_gongxun_baoxiangguang_da.png",{x = 96,y =91.5})
	else
		var.xmlPanel:getWidgetByName("btnBigBox"):removeChildByName("img_bln")
	end
	if data.needClear==0 then
		ContainerFeats.clearBoxRecord()
	end
end

--计算刻度显示
-- function getNeedDun(num)
-- 	local newNum = 0
-- 	if num>=800 then
-- 		newNum=800
-- 	elseif num>=600 then
-- 		newNum=655+(num-600)*(160/200)
-- 	elseif num>=400 then
-- 		newNum=485+(num-400)*(160/200)
-- 	elseif num>=200 then
-- 		newNum=315+(num-200)*(160/200)
-- 	elseif num>=100 then
-- 		newNum=145+(num-100)*(160/100)
-- 	else
-- 		newNum=num*(160/100)
-- 	end
-- 	return newNum
-- end

--开宝箱动画
function ContainerFeats.successAnimate(id)
	if id=="" then return end
	if var.fireworks then var.fireworks:removeFromParent() end
	var.fireworks = cc.Sprite:create():addTo(var.xmlPanel):pos(295,180)
	local animate = cc.AnimManager:getInstance():getPlistAnimate(4,id,4,3,false,false,0,function(animate,shouldDownload)
							if animate then
								var.fireworks:runAction(cca.seq({
									cca.rep(animate,1),
									cca.removeSelf(),
									cca.cb(function ()
										var.fireworks=nil
										var.xmlPanel:getWidgetByName("btnBigBox"):setVisible(true)
										ContainerFeats.successAnimate2()
									end),
								}))
							end
							if shouldDownload==true then
								var.fireworks:release()
							end
						end,
						function(animate)
							var.fireworks:retain()
						end)
	
end

--待机宝箱
function ContainerFeats.successAnimate2()
	if var.fireworks then var.fireworks:removeFromParent() end
	var.fireworks = cc.Sprite:create():addTo(var.xmlPanel):pos(290,165)
	local id = 60060
	if var.curBoxNum>=10 then id = 60061 end
	local animate = cc.AnimManager:getInstance():getPlistAnimate(4,id,4,8,false,false,0,function(animate,shouldDownload)
							if animate then
								if var.curBoxNum>0 then
									var.fireworks:runAction(cca.seq({
										cca.rep(animate,10000),
										cca.removeSelf(),
									}))
									var.fireworks:setVisible(true)
								else
									var.fireworks:runAction(cca.seq({
										cca.rep(animate,0),
									}))
									var.fireworks:setVisible(false)
								end
							end
							if shouldDownload==true then
								var.fireworks:release()
							end
						end,
						function(animate)
							var.fireworks:retain()
						end)
end

--宝箱底座特效
function ContainerFeats.successAnimate3()
	if not var.fireworks3 then
		var.fireworks3 = cc.Sprite:create():addTo(var.xmlPanel):pos(290,160):setVisible(false)
	end
	local animate = cc.AnimManager:getInstance():getPlistAnimate(4,65200,4,4,false,false,0,function(animate,shouldDownload)
							if animate then
								var.fireworks3:stopAllActions()
								var.fireworks3:runAction(cca.seq({
									cca.rep(animate,10000),
									cca.removeSelf(),
								}))
							end
							if shouldDownload==true then
								var.fireworks3:release()
							end
						end,
						function(animate)
							var.fireworks3:retain()
						end)
	
end

function ContainerFeats.setBoxClick()

end
-----------------------------------------按钮操作-----------------------------------------------
local btnArrs = {"btnGet","btnBigBox","btnBox1","btnBox2","btnBox3","btnBox4"}
function ContainerFeats.initBtns()
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		if senderName=="btnRankAward" then
			GameSocket:PushLuaTable("gui.ContainerFeats.handlePanelData",GameUtilSenior.encode({actionid = "addGongXun"}))
		elseif senderName=="btnGet" then
			GameSocket:PushLuaTable("gui.ContainerFeats.handlePanelData",GameUtilSenior.encode({actionid = "reqListData"}))
			if var.xmlPage then
				if not var.xmlPage:isVisible() then
					var.xmlPage:show()
				else
					var.xmlPage:hide()
					var.xmlPanel:getWidgetByName("awardList"):setVisible(true)
				end
			end
		elseif senderName=="btnBigBox" then--点击开箱子操作
			GameSocket:PushLuaTable("gui.ContainerFeats.handlePanelData",GameUtilSenior.encode({actionid = "repOpenBox"}))
			-- GameUtilSenior.setCountDown(sender,1,1,ContainerFeats.setBoxClick)
		elseif senderName=="btnBox1" then
			GameSocket:PushLuaTable("gui.ContainerFeats.handlePanelData",GameUtilSenior.encode({actionid = "repLingBox",params={index=1}}))
		elseif senderName=="btnBox2" then
			GameSocket:PushLuaTable("gui.ContainerFeats.handlePanelData",GameUtilSenior.encode({actionid = "repLingBox",params={index=2}}))
		elseif senderName=="btnBox3" then
			GameSocket:PushLuaTable("gui.ContainerFeats.handlePanelData",GameUtilSenior.encode({actionid = "repLingBox",params={index=3}}))
		elseif senderName=="btnBox4" then
			GameSocket:PushLuaTable("gui.ContainerFeats.handlePanelData",GameUtilSenior.encode({actionid = "repLingBox",params={index=4}}))
		end
	end
	for i=1,#btnArrs do
		local btn = var.xmlPanel:getWidgetByName(btnArrs[i])
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
		if btnArrs[i]=="btnBigBox" then
			-- btn:setOpacity(0)
		end
	end
end

--开功勋宝箱记录
function ContainerFeats.updateContent(data,curScrollName,listsize ,Margin,need2RemoveAll,tsize)
	local scroll = var.xmlPanel:getWidgetByName(curScrollName):setItemsMargin(Margin or 0):setClippingEnabled(true)
	scroll:setDirection(ccui.ScrollViewDir.vertical)
	scroll:setScrollBarEnabled(false)
	if need2RemoveAll or curScrollName == "myscrollInfo" then
		scroll:removeAllChildren()
	end
	for i=1, #data do
		local richWidget = GUIRichLabel.new({size = cc.size(listsize,0),space = 8})
		local textsize = tsize or 18
		-- local tempInfo = GameUtilSenior.decode(data[i])
		richWidget:setRichLabel("<font color=#f1e8d0>"..data[i].."</font>",18,textsize)
		richWidget:setVisible(true)
		scroll:pushBackCustomItem(richWidget)
	end
	scroll:runAction(cc.Sequence:create(
		cc.DelayTime:create(0.1),
		cc.CallFunc:create(function ()
				scroll:scrollToBottom(1,true)
			end)
		)
	)
end

--获得开箱子的本地记录
function ContainerFeats.getGongXunListInfos()
	var.gongXunListInfos = GameSetting.getInfos(var.roleName, "GongXunOpenAward")
	if not var.gongXunListInfos then
		var.gongXunListInfos={}
	else
		ContainerFeats.updateContent(var.gongXunListInfos,"awardList",520,2,true,18)
	end

end

--每日清空一次开宝箱记录
function ContainerFeats.clearBoxRecord()
	GameSetting.setInfos(var.roleName,{},"GongXunOpenAward")
	GameSocket:PushLuaTable("gui.ContainerFeats.handlePanelData",GameUtilSenior.encode({actionid = "clearDataSuccess"}))
end

--每来一条记录并删除多余的
function ContainerFeats.getMyGongXunListInfos(itemStr)
	if var.xmlPage then
		var.xmlPage:hide()
	end
	if not var.gongXunListInfos then
		var.gongXunListInfos = GameSetting.getInfos(var.roleName,"GongXunOpenAward")
	end
	if itemStr then
		table.insert(var.gongXunListInfos,itemStr)
	end
	-- if #var.gongXunListInfos>MAXITEM then
	-- 	table.remove(var.gongXunListInfos,1)
	-- end
	GameSetting.setInfos(var.roleName,var.gongXunListInfos,"GongXunOpenAward")
	ContainerFeats.updateContent(var.gongXunListInfos,"awardList",520,2,true,18)
	var.xmlPanel:getWidgetByName("btnBigBox"):setVisible(true)
	-- ContainerFeats.successAnimate(60062)
end

-----------------------------------------------------随身商店和功勋任务-----------------------------------------------------------
function ContainerFeats.initPage(name)
	if not var.xmlPage then
		var.xmlPage = GUIAnalysis.load("ui/layout/ContainerFeats_Page.uif")
				:addTo(var.xmlPanel):align(display.CENTER, 615, 308)
				:hide()
	end
	if name=="btnBuy" then
		local listBuy = var.xmlPage:getWidgetByName("listBuy")
		listBuy:reloadData(#var.gxData,ContainerFeats.updateBuy):setSliderVisible(false)
	end
	if name=="btnTask" then
		local listTask = var.xmlPage:getWidgetByName("listTask")
		listTask:reloadData(#var.taskData,ContainerFeats.updateTask):setSliderVisible(false)
	end

end

function ContainerFeats.updateTask(item)
	local itemData = var.taskData[item.tag]
	item:getWidgetByName("labTaskName"):setString(itemData.taskName)

	local posX, posY = item:getWidgetByName("labTask"):getPosition()
	local richDesp = item:getWidgetByName("richDesp")
	if not richDesp then
		richDesp = GUIRichLabel.new({
			size = cc.size(250, 25),
			fontSize = 18,
			space=0,
			name = "richDesp",
		}):align(display.LEFT_CENTER, posX, posY):addTo(item):setName("richDesp")
	end
	item:getWidgetByName("labTask"):setString("")
	richDesp:setRichLabel("<font color=#18D129>"..itemData.taskDesp.."</font>", "", 18)

	item:getWidgetByName("labAward"):setString(itemData.taskAward.."点功勋")
	local function prsBtnItem(sender)
		GameSocket:PushLuaTable("gui.ContainerFeats.handlePanelData",GameUtilSenior.encode({actionid = "reqTaskChuan",params={index=sender.index}}))
	end
	local btnChuan = item:getWidgetByName("btnChuan")
	btnChuan.index=itemData.id
	GUIFocusPoint.addUIPoint(btnChuan , prsBtnItem)
	GUIAnalysis.attachEffect(btnChuan,"outline(0e0600,1)")
	if not itemData.panelName and not itemData.npcId then
		btnChuan:setVisible(false)
	else
		btnChuan:setVisible(true)
	end
	if itemData.isCom>0 then
		item:getWidgetByName("imgFlag"):setVisible(true)
		btnChuan:setVisible(false)
	else
		item:getWidgetByName("imgFlag"):setVisible(false)
	end
end

function ContainerFeats.updateBuy(item)
	local itemData = var.gxData[item.tag]
	item:getWidgetByName("labName"):setString(itemData.name)
	item:getWidgetByName("labPrice"):setString(itemData.vcion)
	local awardItem=item:getWidgetByName("icon")
	local param={parent=awardItem , typeId=itemData.id}
	GUIItem.getItem(param)

	local function prsBtnItem(sender)
		GameSocket:PushLuaTable("gui.ContainerFeats.handlePanelData",GameUtilSenior.encode({actionid = "buyGongXun",params={index=sender.index}}))
	end
	local btnBuy = item:getWidgetByName("btnBuy")
	btnBuy.index=item.tag
	GUIFocusPoint.addUIPoint(btnBuy , prsBtnItem)
	GUIAnalysis.attachEffect(btnBuy,"outline(0e0600,1)")
end


-----------------------------------------------------开宝箱说明----------------------------------------------------------
function ContainerFeats.initDesp()
	local btnDesp=var.xmlPanel:getWidgetByName("Text_12")
	btnDesp:setTouchEnabled(true)
	btnDesp:addTouchEventListener(function (pSender, touchType)
		if touchType == ccui.TouchEventType.began then
			ContainerFeats.openBigBoxDesp()
		elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then
			GDivDialog.handleAlertClose()
		end
	end)
end

function ContainerFeats.openBigBoxDesp()
	local mParam = {
	name = GameMessageCode.EVENT_PANEL_ON_ALERT,
	panel = "tips",
	infoTable = despBigBox,
	visible = true,
	}
	GameSocket:dispatchEvent(mParam)

end

-----------------------------------------------------飞动画----------------------------------------------------------
function ContainerFeats.iconFly(id)
	local iconFly=var.xmlPanel:getWidgetByName("iconFly"):setPosition(287,234):setVisible(true):setLocalZOrder(100):setScale(1)
	local param={parent=iconFly, typeId=id, num=1}
	GUIItem.getItem(param)

	-- local tempPos = GameUtilSenior.getWidgetCenterPos(boxSkill.icon)
	-- local endPos = var.skillModel:convertToNodeSpace(tempPos)

	local function moveAct3(target)
		target:runAction(cca.seq({
			cca.delay(0.5),
			cca.moveTo(1, 660, 0),
			cca.cb(function ()
				target:stopAllActions()
				target:setVisible(false)
			end),
		}))
	end

	local function moveAct2(target)
		target:runAction(cca.seq({
			cca.delay(0.8),
			cca.cb(function()
				target:stopAllActions()
				moveAct3(target)
			end),
		}))
	end

	local function moveAct(target)
		target:runAction(cca.seq({
			cca.moveTo(0.2, 350, 295),
			cca.cb(function ()
				target:stopAllActions()
				moveAct2(target)
			end),
		}))
	end
	-- moveAct(iconFly)
	moveAct3(iconFly)
end

return ContainerFeats