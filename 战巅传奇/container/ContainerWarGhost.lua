local ContainerWarGhost={}
local var = {}
local attrStr = {
	{name = "最大生命值:",	img = "maxhp",	x1 = 1000,			pos = 5},
	{name = "物理攻击:",	img = "dc",		x1 = 1004,x2 = 1005,pos = 1},
	{name = "魔法攻击:",	img = "mc",		x1 = 1006,x2 = 1007,pos = 1},
	{name = "道术攻击:",	img = "sc",		x1 = 1008,x2 = 1009,pos = 1},
	{name = "物理防御:",	img = "ac",		x1 = 1010,x2 = 1011,pos = 2},
	{name = "魔法防御:",	img = "mac",	x1 = 1012,x2 = 1013,pos = 3},
	{name = "神圣攻击:",	img = "holydamage",		x1 = 1019,	pos = 4},
}
local despTable ={
	[1]="<font color=#E7BA52 size=18>规则说明：</font>",
	[2]="<font color=#f1e8d0>1、摇摇乐每天可摇取2次</font>",
    [3]="<font color=#f1e8d0>2、摇摇乐每天可免费改运10次</font>",
    [4]="<font color=#f1e8d0>3、免费改运次数用完之后，可以消耗元宝继续改运</font>",
    [5]="<font color=#f1e8d0>4、单个骰子摇到6点之后才能获得奖励</font>",
    [6]="<font color=#f1e8d0>5、摇到6点的骰子个数越多，获得的奖励越丰厚</font>",
    [7]="<font color=#f1e8d0>6、摇摇乐每天24：00整重置，请及时领取奖励</font>",
}
function ContainerWarGhost.initView()
	var = {
		xmlPanel,
		box_tab,
		huweiPage,

		tablisth,
		xmlYYL,
		curTab,
		testArr={0,0,0,0,0,0},
		sixNum=0,--记录6的个数
		actArr={},--存放6个动画骰子对象
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerWarGhost.uif");
	if var.xmlPanel then
		var.box_tab = var.xmlPanel:getWidgetByName("box_tab")
		var.box_tab:addTabEventListener(ContainerWarGhost.pushTabsButton)

		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerWarGhost.handlePanelData)
		
	end
	return var.xmlPanel
end

function ContainerWarGhost.onPanelOpen()
	var.box_tab:setSelectedTab(1)

	GameSocket:PushLuaTable("gui.ContainerWarGhost.handlePanelData",GameUtilSenior.encode({actionid = "checkRedPoint"}))
end

function ContainerWarGhost.onPanelClose()
end

function ContainerWarGhost.pushTabsButton(tab)
	local function click(sender)
		--if sender.up then
			GameSocket:PushLuaTable("gui.ContainerWarGhost.handlePanelData",GameUtilSenior.encode({actionid = "upwuhun"}))
			return
		--end
		--[[
		local attrType,attrData = sender.attrType,sender.attrData
		if attrType and attrData then
			local sx,sy = sender:getPosition()
			local x = i<=3 and sx+30 or (i==4 and sx-78 or sx-180)
			local y = i==4 and sy-30 or sy
			preShowLayer:show():setPosition(x,y)
			preShowLayer:stopAllActions():runAction(cca.seq({
				cca.delay(3),
				cca.hide()
			}))
			local p1,p2
			for i,v in ipairs(attrStr) do
				if not v.x2 then
					p1 = table.indexof(attrType, v.x1)
					if p1 then
						preShowLayer:getWidgetByName("preShowAttrStr"):setString(v.name)
						preShowLayer:getWidgetByName("preShowAttr"):setString(attrData[p1])
					end
				elseif v.x1 and v.x2 then
					p1 = table.indexof(attrType, v.x1)
					p2 = table.indexof(attrType, v.x2)
					if p1 and p2 then
						preShowLayer:getWidgetByName("preShowAttrStr"):setString(v.name)
						preShowLayer:getWidgetByName("preShowAttr"):setString(attrData[p1].."-"..attrData[p2])
					end
				end
			end
		end
		]]--
	end
	if tab:getTag() == 2 then
		if GameUtilSenior.isObjectExist(var.huweiPage) then
			var.huweiPage:hide()
		end
		var.curTab = ContainerWarGhost.initYaoYaoLe()
	elseif tab:getTag() == 1 then
		if GameUtilSenior.isObjectExist(var.curTab) then
			var.curTab:hide()
		end
		if not GameUtilSenior.isObjectExist(var.huweiPage) then
			var.huweiPage = GUIAnalysis.load("ui/layout/ContainerWarGhost_wuhun.uif");
			var.huweiPage:addTo(var.xmlPanel):align(display.CENTER, 464, 284.5)

			--GameUtilSenior.asyncload(var.xmlPanel, "img_wuhun_bg", "ui/image/war_ghost_bg.jpg")
			local lblgetvalue = var.huweiPage:getWidgetByName("lblgetvalue"):setTouchEnabled(true)
			lblgetvalue:addClickEventListener(click)
			--lblgetvalue:addClickEventListener(function (sender)
			--	var.box_tab:setSelectedTab(1)
			--end)
			--var.xmlPanel:getWidgetByName("wuhun_progressbar"):hide()
			local attrlayer = var.huweiPage:getWidgetByName("attrlayer")
			local jobId = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)
			
			attrlayer:getWidgetByName("attr1"):setString(attrStr[jobId-98].name)
			-- attrlayer:getWidgetByName("attr1"):loadTexture(attrStr[jobId-98].img, ccui.TextureResType.plistType)
			

			local preShowLayer = var.huweiPage:getWidgetByName("preShowLayer"):hide():setLocalZOrder(5)
			for i=1,7 do
				var.huweiPage:getWidgetByName("circle"..i):setPressedActionEnabled(true):setLocalZOrder(2):addClickEventListener(click)
				var.huweiPage:getWidgetByName("Image_"..i):addClickEventListener(click)
			end
		end
		var.huweiPage:show()
		GameSocket:PushLuaTable("gui.ContainerWarGhost.handlePanelData",GameUtilSenior.encode({actionid = "freshwuhun"}))
	end
end

function ContainerWarGhost.handlePanelData(event)
	if event.type ~= "ContainerWarGhost" then return end
	local data = GameUtilSenior.decode(event.data)
	if data.cmd =="freshwuhun" then
		ContainerWarGhost.freshPageWuhun(data)
	elseif data.cmd =="checkRedPoint" then
		var.box_tab:getItemByIndex(2):setRedPointVisible(data.red)
		if var.box_tab:getItemByIndex(2):getChildByName("redPoint") then
			var.box_tab:getItemByIndex(2):getChildByName("redPoint"):setPosition(114, 105)
		end
	-------------------------------------------------------------
	elseif data.cmd =="updateTimesShow" then
		ContainerWarGhost.updateTimesShow(data)
	elseif data.cmd=="updateShowInfo" then
		ContainerWarGhost.updateEndShow(data)
	elseif data.cmd=="hideLingBox" then
		var.xmlYYL:getWidgetByName("box_yaoshai"):setVisible(false)
		ContainerWarGhost.setDespShow(false)
		var.xmlYYL:getWidgetByName("labGetWuHun"):setString("+0")
		var.xmlYYL:getWidgetByName("labWuHun"):setString(data.wuHunNum)
		var.xmlYYL:getWidgetByName("imgTitle"):loadTexture("img_six0", ccui.TextureResType.plistType)
		var.sixNum=0
		var.testArr={0,0,0,0,0,0}
		local btnWuHun = var.xmlYYL:getWidgetByName("btnWuHun")
		if data.isShowBtn then
			btnWuHun:setVisible(true)
			--GameUtilSenior.addHaloToButton(btnWuHun, "btn_normal_light9")
		else
			btnWuHun:setVisible(false)
			btnWuHun:removeChildByName("img_bln")
		end
		local btnShaiZi = var.xmlYYL:getWidgetByName("btnShaiZi"):setVisible(true)
		if data.yuTimes>0 then
			--GameUtilSenior.addHaloToButton(btnShaiZi, "btn_normal_light9")
		else
			btnShaiZi:removeChildByName("img_bln")
		end
		var.xmlYYL:getWidgetByName("btnLing"):removeChildByName("img_bln")
	elseif data.cmd=="startYaoAction" then	
		local target = var.xmlYYL:getWidgetByName("box_yaoshai"):setVisible(true)
		ContainerWarGhost.setDespShow(true)
		ContainerWarGhost.reqResult(target,"shouci")
		ContainerWarGhost.startAction()
		ContainerWarGhost.startRandom()
		
	elseif data.cmd=="startGaiYunAction" then	
		local target = var.xmlYYL:getWidgetByName("box_yaoshai"):setVisible(true)
		ContainerWarGhost.setDespShow(true)
		ContainerWarGhost.reqResult(target,"gaiyun")
		ContainerWarGhost.startAction()
		ContainerWarGhost.agianRandom()
		
	elseif data.cmd=="setBtnEnable" then
		ContainerWarGhost.setBtnState(true)
	end
end
-------------------------------------------------------天罡------------------------------------------------------------

function ContainerWarGhost.runAmination(target,name,animateId,times,callBack)
	local times = checknumber(times)
	local anchor =cc.p(0.5,0.5)
	local sprite = target:getChildByName(name) 
	if not sprite then
		sprite = cc.Sprite:create()
			:addTo(target)
			:setName(name)
			:setLocalZOrder(6)
	end
	sprite:align(display.CENTER,target:getContentSize().width/2,target:getContentSize().height/2)
	sprite:stopAllActions():hide()
	local animate = cc.AnimManager:getInstance():getPlistAnimate(4,animateId,4,4,false,false,0,function(animate,shouldDownload)
							if animate then
								if times ==0 then
									sprite:show()
									sprite:runAction(cca.repeatForever(animate))
								else
									sprite:runAction(cca.seq({
										cca.rep(animate,times),
										cca.cb(function()
											if type(callBack) == "function" then callBack() end
										end),
										cca.removeSelf()
									}))
								end
							end
							if shouldDownload==true then
								sprite:release()
							end
						end,
						function(animate)
							sprite:retain()
						end)
	
end

function ContainerWarGhost.freshPageWuhun(data)
	--默认1阶0级
	var.xmlPanel:getWidgetByName("lblneedvalue"):setString(data.score)
	-- for k,v in pairs(data) do
	-- 	print("----",k,v)
	-- end
	local level = data.level
	local jie = data.jie --math.ceil((data.level+1)/7)
	local ji = data.ji-- data.level >0 and (data.level%7 == 0 and 7 or data.level%7) or 1
	local nextji = data.nextji-- data.level%7==0 and 1 or data.level%7+1

	local wuhun_jie = var.xmlPanel:getWidgetByName("wuhun_jie")
	--wuhun_jie:loadTexture("wuhun_jie"..jie, ccui.TextureResType.plistType)
	local filepath = "ui/image/TianGang/wuhun_jie"..jie..".png"
	asyncload_callback(filepath, wuhun_jie, function(filepath, texture)
		wuhun_jie:setVisible(true)
		wuhun_jie:loadTexture(filepath)
	end)
	
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	local filepath_title_animal = "ui/image/TianGang/title_animal_"..jie..".png"
	asyncload_callback(filepath_title_animal, title_animal, function(filepath_title_animal, texture)
		title_animal:setVisible(true)
		title_animal:loadTexture(filepath_title_animal)
	end)
	
	
	local right_animal = var.xmlPanel:getWidgetByName("right_animal")
	local startNum = 1
	local function startShowBg()
					
		if startNum<61 then
			local filepath = "ui/image/TianGang/right_animal_"..startNum..".png"
			asyncload_callback(filepath, right_animal, function(filepath, texture)
				right_animal:setVisible(true)
				right_animal:loadTexture(filepath)
			end)
		end
		
		startNum= startNum+1
		if startNum ==61 then
			startNum =1
		end
	end
	right_animal:stopAllActions()
	right_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg)}),tonumber(61)))
		
	local maxPicID = 17
	local role_animal = var.xmlPanel:getWidgetByName("role_animal")
	local startNum = 1
	local function startShowBg1()
		
		if startNum<18 then
			local filepath = "ui/image/TianGang/role_"..jie.."_"..startNum..".png"
			asyncload_callback(filepath, role_animal, function(filepath, texture)
				role_animal:setVisible(true)
				role_animal:loadTexture(filepath)
			end)
		end
		
		startNum= startNum+1
		if startNum ==maxPicID+1 then
			startNum =1
		end
	end
	role_animal:stopAllActions()
	role_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg1)}),tonumber(maxPicID+1)))
	--[[
	local wuhun_progressbar = var.xmlPanel:getWidgetByName("wuhun_progressbar")
	local progressBar = var.huweiPage:getChildByName("progressBar")
	if not progressBar then
		progressBar = cc.ProgressTimer:create(wuhun_progressbar:getVirtualRenderer():getSprite():clone())
		progressBar:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
		progressBar:addTo(var.huweiPage):align(display.CENTER, 460, 306)
		progressBar:setLocalZOrder(1):setRotation(-120)
		progressBar:setMidpoint(cc.p(0.5,0.5))--设置旋转中心点
		progressBar:setName("progressBar")
	end
	local percent = GameUtilSenior.bound(0, data.percentage, 100)
	progressBar:setPercentage(percent*(240)/360)
	]]--

	local circleAttrLayer = var.huweiPage:getWidgetByName("circleAttrLayer"):setLocalZOrder(4):hide()
	local attrlayer = var.huweiPage:getWidgetByName("attrlayer")
	local circle = var.huweiPage:getWidgetByName("circle"..1)
	local image = var.huweiPage:getWidgetByName("Image_"..1)
	ContainerWarGhost.runAmination(circle,"effect",0)

	for i=1,7 do
		circle = var.huweiPage:getWidgetByName("circle"..i)
		image = var.huweiPage:getWidgetByName("Image_"..i)
		circle.attrType = data.attrTotal[i].attrType
		circle.attrData = data.attrTotal[i].attrData
		image.attrType = data.attrTotal[i].attrType
		image.attrData = data.attrTotal[i].attrData
		circle.up = nextji == i
		local texture = ""
		if i<nextji then
			--circle:setBright(true)
			circle:setVisible(true)
		else
			--circle:setBright(false)
			circle:setVisible(false)
		end
		-- 呼吸灯
		-- circle:loadTextures(texture,texture,texture, ccui.TextureResType.plistType)

		-- if level == 49 then
		-- 	ContainerWarGhost.runAmination(circle,"effect",6542000)
		-- elseif i == 7 then
		-- 	ContainerWarGhost.runAmination(circle,"effect",6543000)
		-- elseif i <= nextji then
		-- 	ContainerWarGhost.runAmination(circle,"effect",6542000)
		-- else
		-- 	ContainerWarGhost.runAmination(circle,"effect",0)			
		-- end
		if circle:getChildByName("img_bln") then
			circle:removeChildByName("img_bln")
		end
	end
	if data.needValue then
		circleAttrLayer:getWidgetByName("needwuhun"):setString(data.needValue):setColor(data.needValue>data.score and GameBaseLogic.getColor(0xff0000) or GameBaseLogic.getColor(0x00ff00))
	end
	--local circle = var.huweiPage:getWidgetByName("circle"..nextji)
	--if data.needValue<=data.score then
	--	GameUtilSenior.addHaloToButton(circle, "img_wuhun_guangquan")
	--end
	--[[
	local attrv = data.attrTotal[nextji]
	if attrv then
		local circle = var.huweiPage:getWidgetByName("circle"..nextji)
		circleAttrLayer:show():setPosition(circle:getPositionX()-18, circle:getPositionY()+12)
		local attrType = attrv.attrType
		local attrData = attrv.attrData
		local p1,p2
		for i,v in ipairs(attrStr) do
			if not v.x2 then
				p1 = table.indexof(attrType, v.x1)
				if p1 then
					circleAttrLayer:getWidgetByName("attrstr"):setString(v.name)
					circleAttrLayer:getWidgetByName("attrdata"):setString(attrData[p1])
				end
			elseif v.x1 and v.x2 then
				p1 = table.indexof(attrType, v.x1)
				p2 = table.indexof(attrType, v.x2)
				if p1 and p2 then
					circleAttrLayer:getWidgetByName("attrstr"):setString(v.name)
					circleAttrLayer:getWidgetByName("attrdata"):setString(attrData[p1].."-"..attrData[p2])
				end
			end
		end
	end
	]]--

	local p1,p2
	for i,v in ipairs(attrStr) do
		local attr = attrlayer:getWidgetByName("attr"..v.pos)
		local attrNum = attrlayer:getWidgetByName("attrNum"..v.pos)--:setString("999-999")
		if data.attrTypeAll and data.attrDataAll then
			if not v.x2 then
				p1 = table.indexof(data.attrTypeAll, v.x1)
				if p1 then
					attr:setString(v.name)
					-- attr:loadTexture(v.img, ccui.TextureResType.plistType)
					attrNum:setString(data.attrDataAll[p1])
				end
			elseif v.x1 and v.x2 then
				p1 = table.indexof(data.attrTypeAll, v.x1)
				p2 = table.indexof(data.attrTypeAll, v.x2)
				if p1 and p2 then
					attr:setString(v.name)
					-- attr:loadTexture(v.img, ccui.TextureResType.plistType)
					attrNum:setString(data.attrDataAll[p1].."-"..data.attrDataAll[p2])
				end
			end
		end
	end

end

--------------------------------------------------------摇摇乐------------------------------------------------------------
function ContainerWarGhost.initYaoYaoLe()
	if not var.xmlYYL then
		var.xmlYYL=GUIAnalysis.load("ui/layout/ContainerWarGhost_yaoyaole.uif")
							:addTo(var.xmlPanel)
   							:align(display.CENTER,464, 284.5)
   							:show()
   		--GameUtilSenior.asyncload(var.xmlYYL, "yaoyaoleBg", "ui/image/panel_rrl_bg.jpg")
   		--GameUtilSenior.asyncload(var.xmlYYL, "shaiBg", "ui/image/img_shaizi_bg.png")
   		
   		var.xmlYYL:getWidgetByName("shaiBg"):setTouchEnabled(true)

   		var.xmlYYL:getWidgetByName("imgZiH"):setVisible(false)
		-- var.xmlYYL:getWidgetByName("imgZiS"):setVisible(false)

   		var.xmlYYL:getWidgetByName("btnShaiZi"):addClickEventListener(function (sender)--摇骰子
   			GameSocket:PushLuaTable("gui.PanelYaoYaoLe.handlePanelData", GameUtilSenior.encode({actionid = "reqStartYao"}))
		end)

		var.xmlYYL:getWidgetByName("btnLing"):addClickEventListener(function (sender)
			if var.sixNum<6 then
				local mParam = {
					name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "当前天罡不是最佳值是否领取？",
					btnConfirm = "是", btnCancel = "否",
					confirmCallBack = function ()
						GameSocket:PushLuaTable("gui.PanelYaoYaoLe.handlePanelData", GameUtilSenior.encode({actionid = "reqLingWuHun"}))
					end
				}
				GameSocket:dispatchEvent(mParam)
			else
				GameSocket:PushLuaTable("gui.PanelYaoYaoLe.handlePanelData", GameUtilSenior.encode({actionid = "reqLingWuHun"}))
			end
		end)

		var.xmlYYL:getWidgetByName("btnWuHun"):addClickEventListener(function (sender)
			--print("sadfasdsa")
			var.box_tab:setSelectedTab(1)
		end)

		var.xmlYYL:getWidgetByName("btnGaiYun"):addClickEventListener(function (sender)
			ContainerWarGhost.setBtnState(false)
			GameSocket:PushLuaTable("gui.PanelYaoYaoLe.handlePanelData", GameUtilSenior.encode({actionid = "reqStartGaiYun"}))
		end)

		local labDesp = var.xmlYYL:getWidgetByName("labDesp")
		labDesp:setTouchEnabled(true)
		labDesp:addTouchEventListener(function (pSender, touchType)
			if touchType == ccui.TouchEventType.began then
				ContainerWarGhost.yaoYaoDesp()
			elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then	
				GDivDialog.handleAlertClose()
			end
		end)
	else
		var.xmlYYL:show()
	end
	var.xmlYYL:getWidgetByName("box_yaoshai"):setVisible(false)
	ContainerWarGhost.setDespShow(false)
	var.xmlYYL:getWidgetByName("btnWuHun"):setVisible(false)
	var.xmlYYL:getWidgetByName("btnShaiZi"):setVisible(false)
	GameSocket:PushLuaTable("gui.PanelYaoYaoLe.handlePanelData", GameUtilSenior.encode({actionid = "reqYaoYaoLeTimes",}))
	return var.xmlYYL
end

function ContainerWarGhost.reqResult(target,type)
	target:runAction(cca.seq({
		cca.delay(1), 
		cca.cb(function() 
			target:stopAllActions()
			if type=="shouci" then
				GameSocket:PushLuaTable("gui.PanelYaoYaoLe.handlePanelData", GameUtilSenior.encode({actionid = "startYaoShaiZi",}))
			elseif type=="gaiyun" then
				GameSocket:PushLuaTable("gui.PanelYaoYaoLe.handlePanelData", GameUtilSenior.encode({actionid = "startGaiYun",}))
			end
			-- ContainerWarGhost.endRandom()
		end),
	}))
end

--第一次摇骰子图片动画
function ContainerWarGhost.startRandom()
	ContainerWarGhost.setBtnState(false)
	for i=1,6 do
		local time=i
		local numImg = var.xmlYYL:getWidgetByName("imgSe"..i)
		numImg:runAction(cca.repeatForever(cca.seq({cca.delay(0.1), cca.callFunc(function ()
			time = time+1
			if time>6 then time=1 end
			numImg:loadTexture("img_se"..time, ccui.TextureResType.plistType)
		end)})))
	end
	-- local index = 0
	-- local imgTitle = var.xmlYYL:getWidgetByName("imgTitle")
	-- imgTitle:runAction(cca.repeatForever(cca.seq({cca.delay(0.1), cca.callFunc(function ()
	-- 	index = index+1
	-- 	if index>6 then index=0 end
	-- 	imgTitle:loadTexture("img_six"..index, ccui.TextureResType.plistType)
	-- end)})))
end

--改运时的摇骰子动画
function ContainerWarGhost.agianRandom()
	for i=1,#var.testArr do
		if var.testArr[i]~=6 then
			local time=i
			local numImg = var.xmlYYL:getWidgetByName("imgSe"..i)
			numImg:runAction(cca.repeatForever(cca.seq({cca.delay(0.1), cca.callFunc(function ()
				time = time+1
				if time>6 then time=1 end
				numImg:loadTexture("img_se"..time, ccui.TextureResType.plistType)
			end)})))
		end
	end
	-- local index = var.sixNum
	-- local imgTitle = var.xmlYYL:getWidgetByName("imgTitle")
	-- imgTitle:runAction(cca.repeatForever(cca.seq({cca.delay(0.1), cca.callFunc(function ()
	-- 	index = index+1
	-- 	if index>6 then index=var.sixNum end
	-- 	imgTitle:loadTexture("img_six"..index, ccui.TextureResType.plistType)
	-- end)})))
end

--摇骰子结果
function ContainerWarGhost.endRandom()
	local sixNum = 0
	for i=1,#var.testArr do
		local time=var.testArr[i]
		local numImg = var.xmlYYL:getWidgetByName("imgSe"..i)
		numImg:stopAllActions()
		numImg:loadTexture("img_act"..time, ccui.TextureResType.plistType)
		if time==6 then
			sixNum=sixNum+1
		end
	end

	local imgTitle = var.xmlYYL:getWidgetByName("imgTitle")
	imgTitle:loadTexture("img_six"..sixNum, ccui.TextureResType.plistType)
	imgTitle:stopAllActions()
	ContainerWarGhost.hideAction()
	ContainerWarGhost.setBtnState(true)
	local btnLing = var.xmlYYL:getWidgetByName("btnLing")
	if sixNum==6 then
		GameUtilSenior.addHaloToButton(btnLing, "btn_normal_light3")
	else
		btnLing:removeChildByName("img_bln")
	end
	var.sixNum=sixNum
end

--播放骰子动画
local posArrs = {{350,165},{410,155},{470,165},{350,115},{410,105},{470,115}}
function ContainerWarGhost.startAction()
	local function startAct2(index)
		local curAct
		if var.actArr[index] then
			curAct = var.actArr[index]
		else
			curAct = cc.Sprite:create():addTo(var.xmlPanel):pos(posArrs[index][1],posArrs[index][2])
			var.actArr[index]=curAct
		end
		if var.testArr and #var.testArr then
			if var.testArr[index]==6 then
				curAct:setVisible(false)
			else
				curAct:setVisible(true)
			end
		else
			curAct:setVisible(true)
		end
		local animate = cc.AnimManager:getInstance():getPlistAnimate(4,6541000,4,4,false,false,0,function(animate,shouldDownload)
							if animate then
									curAct:stopAllActions()
									curAct:runAction(cca.seq({
										cca.rep(animate,math.random(9,13)),
										-- cca.removeSelf(),
									}))
							end
							if shouldDownload==true then
								curAct:release()
							end
						end,
						function(animate)
							curAct:retain()
						end)
		
	end
	local function startAct(target,index)
		target:runAction(cca.seq({
			cca.delay(0), 
			cca.cb(function() 
				target:stopAllActions()
				index=index+1
				if index<=6 then
					startAct2(index)
					startAct(target,index)
				end
			end),
		}))
	end
	startAct(var.xmlYYL:getWidgetByName("labGetWuHun"),0)
end

--结束时收起骰子动画
function ContainerWarGhost.hideAction()
	if var.actArr and #var.actArr then
		for i=1,#var.actArr do
			local curAct = var.actArr[i]
			curAct:stopAllActions()
			curAct:setVisible(false)
			var.xmlYYL:getWidgetByName("imgAct"..i):loadTexture("img_act"..var.testArr[i], ccui.TextureResType.plistType)
		end
	end
end

--设置按钮状态(动画期间禁止操作按钮)
function ContainerWarGhost.setBtnState(state)
	local btnGaiYun = var.xmlYYL:getWidgetByName("btnGaiYun")
	local btnLing = var.xmlYYL:getWidgetByName("btnLing")
	if state then
		btnGaiYun:setEnabled(true)
		btnLing:setEnabled(true)
	else
		btnGaiYun:setEnabled(false)
		btnLing:setEnabled(false)
	end
end


--刷新摇摇乐次数显示
function ContainerWarGhost.updateTimesShow(data)
	var.xmlYYL:getWidgetByName("labSzNum"):setString(data.yuTimes)
	var.xmlYYL:getWidgetByName("labYunNum"):setString(data.mfgyTimes)
	var.xmlYYL:getWidgetByName("labWuHun"):setString(data.wuHunNum)
	if data.curWnNum>0 then
		var.xmlYYL:getWidgetByName("box_yaoshai"):setVisible(true)
		ContainerWarGhost.setDespShow(true)
		if data.mfgyTimes>0 then
			var.xmlYYL:getWidgetByName("Panel_10"):setVisible(false)
			var.xmlYYL:getWidgetByName("btnGaiYun"):setTitleText("免费改运")
			GameUtilSenior.addHaloToButton(var.xmlYYL:getWidgetByName("btnGaiYun"), "btn_normal_light3")
		else
			var.xmlYYL:getWidgetByName("Panel_10"):setVisible(true)
			var.xmlYYL:getWidgetByName("btnGaiYun"):setTitleText("钻石改运") 
			var.xmlYYL:getWidgetByName("btnGaiYun"):removeChildByName("img_bln")
		end
		var.testArr=data.curResult
		ContainerWarGhost.endRandom()
	else
		var.xmlYYL:getWidgetByName("box_yaoshai"):setVisible(false)
		ContainerWarGhost.setDespShow(false)
	end
	var.xmlYYL:getWidgetByName("labGetWuHun"):setString("+"..data.curWnNum)
	local btnWuHun = var.xmlYYL:getWidgetByName("btnWuHun")
	if data.isShowBtn then
		btnWuHun:setVisible(true)
		--GameUtilSenior.addHaloToButton(btnWuHun, "btn_normal_light9")
	else
		btnWuHun:setVisible(false)
		btnWuHun:removeChildByName("img_bln")
	end
	local btnShaiZi = var.xmlYYL:getWidgetByName("btnShaiZi"):setVisible(true)
	if data.yuTimes>0 then
		--GameUtilSenior.addHaloToButton(btnShaiZi, "btn_normal_light9")
	else
		btnShaiZi:removeChildByName("img_bln")
	end
end

--设置摇骰子结果
function ContainerWarGhost.updateEndShow(data)
	var.testArr=data.curResult
	ContainerWarGhost.endRandom()
	var.xmlYYL:getWidgetByName("labSzNum"):setString(data.yuTimes)
	var.xmlYYL:getWidgetByName("labGetWuHun"):setString("+"..data.curWnNum)
	var.xmlYYL:getWidgetByName("labYunNum"):setString(data.mfgyTimes)
	if data.mfgyTimes>0 then
		var.xmlYYL:getWidgetByName("Panel_10"):setVisible(false)
		var.xmlYYL:getWidgetByName("btnGaiYun"):setTitleText("免费改运")
		GameUtilSenior.addHaloToButton(var.xmlYYL:getWidgetByName("btnGaiYun"), "btn_normal_light3")
	else
		var.xmlYYL:getWidgetByName("Panel_10"):setVisible(true)
		var.xmlYYL:getWidgetByName("btnGaiYun"):setTitleText("元宝改运")
		var.xmlYYL:getWidgetByName("btnGaiYun"):removeChildByName("img_bln")
	end
	local btnShaiZi = var.xmlYYL:getWidgetByName("btnShaiZi")
	if data.yuTimes>0 then
		--GameUtilSenior.addHaloToButton(btnShaiZi, "btn_normal_light9")
	else
		btnShaiZi:removeChildByName("img_bln")
	end
end

function ContainerWarGhost.setDespShow(isshow)
	var.xmlYYL:getWidgetByName("imgZiH"):setVisible(not isshow)
	-- var.xmlYYL:getWidgetByName("imgZiS"):setVisible(isshow)
end

function ContainerWarGhost.yaoYaoDesp()
	local mParam = {
	name = GameMessageCode.EVENT_PANEL_ON_ALERT,
	panel = "tips", 
	infoTable = despTable,
	visible = true, 
	}
	GameSocket:dispatchEvent(mParam)

end



return ContainerWarGhost