local ContainerWarProtecter={}
local var = {}

local despCall ={
	[1] ="<font color=#E7BA52 size=18>召唤说明：</font>",
	[2] ="<font color=#f1e8d0>1.玩家死亡后，护卫将自动消失</font>",
	[3] ="<font color=#f1e8d0>2.护卫阶数越高，属性和技能越多</font>",
	[4] ="<font color=#f1e8d0>3.进阶时需要达到升级等级并消耗相   应护卫进阶丹</font>",
}

local skillTable = {
	{iconRes="hw_skill_1", skillName="半月斩",  skillZb="主动技能", openLev=1, skillDesp="扇形攻击",},
	{iconRes="hw_skill_2", skillName="增防",    skillZb="被动技能", openLev=2, skillDesp="自身防御增加50%",},
	{iconRes="hw_skill_3", skillName="增血",    skillZb="被动技能", openLev=3, skillDesp="自身血量增加50%",},
	{iconRes="hw_skill_4", skillName="增伤",    skillZb="被动技能", openLev=4, skillDesp="杀怪伤害增加50%",},
	{iconRes="hw_skill_5", skillName="伤害减少",skillZb="被动技能", openLev=5, skillDesp="受到的伤害减少50%",},
	{iconRes="hw_skill_6", skillName="圆月斩",  skillZb="主动技能", openLev=6, skillDesp="圆形攻击",},
	{iconRes="hw_skill_7", skillName="神圣攻击",skillZb="被动技能", openLev=7, skillDesp="无视防御攻击",},
	{iconRes="hw_skill_8", skillName="暴击",    skillZb="被动技能", openLev=8, skillDesp="10%概率触发暴击",},
	{iconRes="hw_skill_9", skillName="守护",    skillZb="被动技能", openLev=7, skillDesp="玩家角色受到的伤害减少",},
    {iconRes="hw_skill_10",skillName="聚力",    skillZb="被动技能", openLev=8, skillDesp="护卫属性的百分比增加到角色身上",},
}

function ContainerWarProtecter.initView()
	var = {
		xmlPanel,
		powerNum,
		curClothId=nil,
		curWeaponId=nil,
		xmlBuyExp=nil,
		buyExpData=nil,
		curVcion=0,
		curBVcion=0,
		curMoney=0,
		xmlBuyDan=nil,
		buyDanData=nil,
		richtext=nil,
		levelBar,
		expBar,
		hwLevel=1,--护卫等级
		skillIndex=nil,--记录当前查看tips的编号
		huWeiName=nil,
		xmlNewSkill=nil,
		huiState=false,--是否处于技能开启动画期间

	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerWarProtecter.uif");
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_GAME_MONEY_CHANGE, ContainerWarProtecter.updateGameMoney)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerWarProtecter.handlePanelData)
			
		var.powerNum= display.newBMFontLabel({font = "image/typeface/num_15.fnt",})
			:addTo(var.xmlPanel)
			:align(display.BOTTOM_CENTER,785,515)
			:setString(0)

		--ContainerWarProtecter.updateHuWei()
		ContainerWarProtecter.initSkillBtns()
		ContainerWarProtecter.initBtns()
		ContainerWarProtecter.initDesp()
		GameUtilSenior.asyncload(var.xmlPanel, "imgBg", "ui/image/war_ghost.jpg")
		var.levelBar=var.xmlPanel:getWidgetByName("levelBar"):setPercent(0,100):setFontSize(14):enableOutline(GameBaseLogic.getColor(0x000000),1)
		var.expBar=var.xmlPanel:getWidgetByName("expBar"):setPercent(0,100):setFontSize(14):enableOutline(GameBaseLogic.getColor(0x000000),1)

		var.xmlPanel:getWidgetByName("labCurTimes"):setVisible(false)
		var.xmlPanel:getWidgetByName("labTimesDesp"):setVisible(false)
		var.xmlPanel:getWidgetByName("btnZhaoHuan"):setEnabled(false):setVisible(false):setTouchEnabled(false)
		var.xmlPanel:getWidgetByName("btnZhaoHui"):setEnabled(false):setVisible(false):setTouchEnabled(false)
		var.xmlPanel:getWidgetByName("Image_33"):setScale(0.6)
		var.xmlPanel:getWidgetByName("Image_3"):setVisible(true)
		var.xmlPanel:getWidgetByName("Image_3_0"):setVisible(true)
		var.xmlPanel:getWidgetByName("Image_3_1"):setVisible(true)
	end
	return var.xmlPanel
end

function ContainerWarProtecter.onPanelOpen()
	ContainerWarProtecter.updateGameMoney(nil)
	GameSocket:PushLuaTable("gui.ContainerWarProtecter.handlePanelData",GameUtilSenior.encode({actionid = "reqPanelData",params={}}))
end

function ContainerWarProtecter.onPanelClose()
	GameSocket:PushLuaTable("gui.ContainerWarProtecter.handlePanelData",GameUtilSenior.encode({actionid = "panelClose",params={}}))
end

function ContainerWarProtecter.handlePanelData(event)
	if event.type ~= "ContainerWarProtecter" then return end
	local data = GameUtilSenior.decode(event.data)
	-- print(event.data)
	if data.cmd =="senderExpData" then
		ContainerWarProtecter.initBuyExp(data)
	elseif data.cmd=="senderDanData" then
		ContainerWarProtecter.initBuyDan(data)
	elseif data.cmd=="updateHuWei" then
		ContainerWarProtecter.updateData(data)
	elseif data.cmd=="huWeiZhaoHuan" then--护卫召唤成功
		var.xmlPanel:getWidgetByName("btnZhaoHui"):setEnabled(true):setVisible(true):setTouchEnabled(true)
		var.xmlPanel:getWidgetByName("btnZhaoHuan"):setEnabled(false):setVisible(false):setTouchEnabled(false)
		var.xmlPanel:getWidgetByName("img_light"):setVisible(false)
	elseif data.cmd=="huWeiZhaoHui" then
		var.xmlPanel:getWidgetByName("btnZhaoHui"):setEnabled(false):setVisible(false):setTouchEnabled(false)
		var.xmlPanel:getWidgetByName("btnZhaoHuan"):setEnabled(true):setVisible(true):setTouchEnabled(true)
		ContainerWarProtecter.btnCallCd(data.curCD)
	elseif data.cmd=="updateBtnHalo" then
		ContainerWarProtecter.updateBtnHalo(data)
	end
end

function ContainerWarProtecter.updateBtnHalo(data)
	local btnExp = var.xmlPanel:getWidgetByName("btnBuyExp")
	local btnDan = var.xmlPanel:getWidgetByName("btnBuyDan")
	if tonumber(data.haloExp)<=0 then
		GameUtilSenior.addHaloToButton(btnExp, "btn_normal_light12")
	else
		btnExp:removeChildByName("img_bln")
	end
	if tonumber(data.haloDan)<=0 then
		GameUtilSenior.addHaloToButton(btnDan, "btn_normal_light12")
	else
		btnDan:removeChildByName("img_bln")
	end
end

--召唤按钮倒计时
 function ContainerWarProtecter.btnCallCd(cdTime)
 	local btnCall = var.xmlPanel:getWidgetByName("btnZhaoHuan"):setVisible(true)
 	btnCall:stopAllActions()
 	if cdTime<=0 then
 		btnCall:setTitleText("召唤护卫")
 	else
 		local time = cdTime
 		btnCall:setTitleText("冷却("..time..")")
 		btnCall:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function (target)
 			time = time - 1
 			if time and time > 0 then
 				btnCall:setTitleText("冷却("..time..")")
 			else
 				btnCall:setTitleText("召唤护卫")
 				target:stopAllActions()
 			end
 		end)})))
 	end
 end

--刷新护卫数据
function ContainerWarProtecter.updateData(data)
	if not data then return end
	var.xmlPanel:getWidgetByName("curHp"):setString(data.curData["maxhp"])
	--var.xmlPanel:getWidgetByName("curGj"):setString(data.curData["wgmin"].."-"..data.curData["wgmax"])
	var.xmlPanel:getWidgetByName("curGj"):setString(data.curData["wgmax"])
	--var.xmlPanel:getWidgetByName("curWf"):setString(data.curData["wfmin"].."-"..data.curData["wfmax"])
	var.xmlPanel:getWidgetByName("curWf"):setString("无敌")
	--var.xmlPanel:getWidgetByName("curMf"):setString(data.curData["mfmin"].."-"..data.curData["mfmax"])
	var.xmlPanel:getWidgetByName("curMf"):setString("无敌")
	var.xmlPanel:getWidgetByName("curHx"):setString(data.curData["huixue"])

	var.xmlPanel:getWidgetByName("nextHp"):setString(data.nextData["maxhp"])
	--var.xmlPanel:getWidgetByName("nextGj"):setString(data.nextData["wgmin"].."-"..data.nextData["wgmax"])
	var.xmlPanel:getWidgetByName("nextGj"):setString(data.nextData["wgmax"])
	--var.xmlPanel:getWidgetByName("nextWf"):setString(data.nextData["wfmin"].."-"..data.curData["wfmax"])
	var.xmlPanel:getWidgetByName("nextWf"):setString("无敌")
	--var.xmlPanel:getWidgetByName("nextMf"):setString(data.nextData["mfmin"].."-"..data.curData["mfmax"])
	var.xmlPanel:getWidgetByName("nextMf"):setString("无敌")
	var.xmlPanel:getWidgetByName("nextHx"):setString(data.nextData["huixue"])

	-- var.powerNum:setString(data.curData["wgmax"])
	var.powerNum:setString(data.addFightPoint or 0)

	--var.xmlPanel:getWidgetByName("labFailDesp"):setString("10次内必定成功："..data.failNum.."/10")
	var.xmlPanel:getWidgetByName("labFailDesp"):setString("")
	--var.xmlPanel:getWidgetByName("labTiaoJian"):setString("护卫等级达到"..data.needLevel.."级")
	var.xmlPanel:getWidgetByName("labTiaoJian"):setString("人物等级达50级")
	--var.xmlPanel:getWidgetByName("labXiaoHao"):setString(data.curDanNum.."/"..data.needDanNum)
	var.xmlPanel:getWidgetByName("labXiaoHao"):setString(data.needDanNum)
	var.levelBar:setPercent(data.curLevel,data.needLevel)

	var.expBar:setPercent(data.curExp,data.needExp)

	var.xmlPanel:getWidgetByName("labHwName"):setString(data.name)

	-- var.xmlPanel:getWidgetByName("labCurTimes"):setString(data.enableNum)
	-- local labCount = var.xmlPanel:getWidgetByName("labTimesDesp")
	-- labCount:stopAllActions()
	-- if data.enableNum>=12 then
	-- 	labCount:setString("(已达今日最大召唤次数)")
	-- else
	-- 	local time = data.countTimes
	-- 	labCount:setString("("..GameUtilSenior.setTimeFormat(time*1000,3).."后增加一次)")
	-- 	labCount:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function (target)
	-- 		time = time - 1
	-- 		if time and time >= 0 then
	-- 			labCount:setString("("..GameUtilSenior.setTimeFormat(time*1000,3).."后增加一次)")
	-- 		else
	-- 			target:stopAllActions()
	-- 		end
	-- 	end)})))
	-- end
	for i=1,10 do
		local skillIcon = var.xmlPanel:getWidgetByName("skillIcon"..i):setVisible(true)
		local m = 0
		if not data.skillNum and var.huiState then m=1 end
		if (data.curJie-m)>=i then
			skillIcon:getVirtualRenderer():setState(0)
		else
			skillIcon:getVirtualRenderer():setState(1)
		end
		if data.skillNum and i==data.skillNum and var.huiState==false then
			skillIcon:getVirtualRenderer():setState(0)
		end
	end

	if var.huWeiName and var.huWeiName~=data.name then
		--护卫获得新技能
		if data.skillNum then
			ContainerWarProtecter.openNewSkill(data.skillNum)
		else
			ContainerWarProtecter.openNewSkill(data.curJie)
		end
	end
	var.huWeiName=data.name

	ContainerWarProtecter.updateHuWei(data.weapRes,data.clothRes)
	var.hwLevel=data.curJie
	-- print(data.curJie,"=====",data.skillNum)
	if data.state==1 then--有护卫
		var.xmlPanel:getWidgetByName("btnZhaoHui"):setEnabled(true):setVisible(true):setTouchEnabled(true)
		var.xmlPanel:getWidgetByName("btnZhaoHuan"):setEnabled(false):setVisible(false):setTouchEnabled(false)
		var.xmlPanel:getWidgetByName("img_light"):setVisible(false)
	else
		var.xmlPanel:getWidgetByName("btnZhaoHui"):setEnabled(false):setVisible(false):setTouchEnabled(false)
		var.xmlPanel:getWidgetByName("btnZhaoHuan"):setEnabled(true):setVisible(true):setTouchEnabled(true)
		var.xmlPanel:getWidgetByName("img_light"):setVisible(true)
		ContainerWarProtecter.btnCallCd(data.curCD)
	end
	local btnJinJie = var.xmlPanel:getWidgetByName("btnJinJie")
	if data.canUpgrade then
		GameUtilSenior.addHaloToButton(btnJinJie, "btn_normal_light3")
	else
		btnJinJie:removeChildByName("img_bln")
	end
	if data.up then
		local fireworks = cc.Sprite:create():addTo(var.xmlPanel):pos(473.48, 499)
		local animate = cc.AnimManager:getInstance():getPlistAnimate(4,50022,4,4,false,false,0,function(animate,shouldDownload)
							fireworks:runAction(cca.seq({
								cca.rep(animate, 1),
								cca.cb(function ()
									
								end),
								cca.removeSelf()
							}))
							if shouldDownload==true then
								fireworks:release()
							end
						end,
						function(animate)
							fireworks:retain()
						end)
		
	end
end

--神将形象展示
function ContainerWarProtecter.updateHuWei(weapRes,clothRes)
	local box = var.xmlPanel:getChildByName("box_cloth_weap")
	local img_role = box:getChildByName("img_role")
	local img_weapon = box:getChildByName("img_weapon")
	
	--设置衣服内观
	if not img_role then
		img_role = cc.Sprite:create()
		img_role:addTo(box):align(display.CENTER, 95, 190):setName("img_role")
	end

	local cloth = clothRes
	if cloth~=var.curClothId then
		img_role:setVisible(false)
		local filepath = "image/dress/"..cloth..".png"
		asyncload_callback(filepath, img_role, function(filepath, texture)
			img_role:setTexture(filepath)
			img_role:setVisible(true)
		end)
		var.curClothId=cloth
	end
	
    --设置武器内观
	if not img_weapon then
		img_weapon = cc.Sprite:create()
		img_weapon:addTo(box):align(display.CENTER, 95, 190):setName("img_weapon")
	end
	local weaponDef = weapRes
	if weaponDef then
		if weaponDef~=var.curWeaponId then
			img_weapon:setVisible(false)
			local filepath = "image/arm/"..weaponDef..".png"
			asyncload_callback(filepath, img_weapon, function(filepath, texture)
				img_weapon:setTexture(filepath)
				img_weapon:setVisible(true)
			end)
			var.curWeaponId=weaponDef
		end
	else
		-- img_weapon:setTexture(nil)
		img_weapon:setVisible(false)
		var.curWeaponId=nil
	end
end

--跟新元宝和绑元变化
function ContainerWarProtecter.updateGameMoney(event)
	if var.xmlPanel then
		local mainrole = GameSocket.mCharacter
		var.curVcion=mainrole.mVCoin or 0
		var.curBVcion=mainrole.mVCoinBind or 0
		var.curMoney=mainrole.mGameMoney or 0
		if var.xmlBuyExp then
			var.xmlBuyExp:getWidgetByName("lblVcoin"):setString(var.curVcion)
			var.xmlBuyExp:getWidgetByName("lblMoney"):setString(var.curMoney)
		end
		if var.xmlBuyDan then
			var.xmlBuyDan:getWidgetByName("lblVcoin"):setString(var.curVcion)
			var.xmlBuyDan:getWidgetByName("lblMoney"):setString(var.curMoney)
		end

	end
end

--护卫技能tips点击
function ContainerWarProtecter.initSkillBtns()
	local boxTips = var.xmlPanel:getWidgetByName("box_skill_tip")
	local function prsBtnClick(sender,touchType)
		local senderName = sender:getName()
		-- print(senderName,sender:getPositionX(),sender:getPositionY())
		if touchType == ccui.TouchEventType.began then
			if ContainerWarProtecter.updateSkillInfo(sender.index) then
				local size = boxTips:getContentSize()
				local pSize = sender:getContentSize()
				if sender.index >= 6 then
					boxTips:setPosition(sender:getPositionX()-pSize.width/2-size.width,sender:getPositionY()-size.height/2):setVisible(true)
				else
					boxTips:setPosition(sender:getPositionX()+pSize.width/2,sender:getPositionY()-size.height/2):setVisible(true)
				end
			end
		elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then	
			boxTips:setVisible(false)
		end
	end
	for i=1,10 do
		local btn = var.xmlPanel:getWidgetByName("skillBg"..i):setTouchEnabled(true)
		btn.index=i
		btn:addTouchEventListener(prsBtnClick)
	end
end

--设置护卫技能面板数据
function ContainerWarProtecter.updateSkillInfo(index)
	if var.skillIndex==index then return true end
	local boxTips = var.xmlPanel:getWidgetByName("box_skill_tip")
	var.skillIndex=index
	local skillData=skillTable[index]
	boxTips:getWidgetByName("skillIcon"):loadTexture(skillData.iconRes, ccui.TextureResType.plistType)
	boxTips:getWidgetByName("skillName"):setString(skillData.skillName)
	boxTips:getWidgetByName("skillZb"):setString(skillData.skillZb)
	boxTips:getWidgetByName("skillDesp"):setString(skillData.skillDesp)
	if index<=var.hwLevel then
		boxTips:getWidgetByName("skillOpen"):setString("该技能已经成功激活")
	else
		boxTips:getWidgetByName("skillOpen"):setString("护卫品阶提升值至"..index.."级开启")
	end
	return true
end


-----------------------------------------快捷购买护卫经验丹-----------------------------------------------
function ContainerWarProtecter.initBuyExp(data)
	if not var.xmlBuyExp then
		var.xmlBuyExp = GUIAnalysis.load("ui/layout/ContainerWarProtecter_buyExp.uif")
				:addTo(var.xmlPanel):align(display.CENTER, 234, 280)
				:show()
		local function prsBtnItem(sender)
			local senderName = sender:getName()
			if senderName=="btnback" then
				var.xmlBuyExp:hide()
			elseif senderName=="btnUse" then
				GameSocket:PushLuaTable("gui.ContainerWarProtecter.handlePanelData",GameUtilSenior.encode({actionid = "reqExpDanUse",params={}}))
			end
		end 
		GUIFocusPoint.addUIPoint(var.xmlBuyExp:getWidgetByName("btnback"), prsBtnItem)
		GUIFocusPoint.addUIPoint(var.xmlBuyExp:getWidgetByName("btnUse"), prsBtnItem)
		var.xmlBuyExp:getWidgetByName("imgBg"):setTouchEnabled(true)
		var.xmlBuyExp:getWidgetByName("btnChongZhi"):setTouchEnabled(true):addClickEventListener(function ()
   			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
   		end)

		var.richtext=GUIRichLabel.new({size=cc.size(350,0), space=3, name="richWidget"})
		var.richtext:addTo(var.xmlBuyExp):pos(30,435)
		local text = "拥有战神经验珠(小)：<font color=#00ff00>0</font>"
		var.richtext:setRichLabel(text,"ContainerWarProtecter",16)
	else
		var.xmlBuyExp:show()
	end
	var.buyExpData=data.data
	local listBuyExp = var.xmlBuyExp:getWidgetByName("listBuyExp")
	if #var.buyExpData > 0 then
		listBuyExp:reloadData(#var.buyExpData,ContainerWarProtecter.updateBuyExp):setSliderVisible(false)
	end
	var.xmlBuyExp:getWidgetByName("lblVcoin"):setString(var.curVcion)
	var.xmlBuyExp:getWidgetByName("lblMoney"):setString(var.curMoney)
	ContainerWarProtecter.updateOwnUse(data.ownData)
end

function ContainerWarProtecter.updateOwnUse(data)
	local text = "拥有"..data.itemName.."：<font color=#00ff00>"..data.num.."</font>"
	var.richtext:setRichLabel(text,"ContainerWarProtecter",16)
end

function ContainerWarProtecter.updateBuyExp(item)
	local itemData = var.buyExpData[item.tag]
	if itemData.bvcion>0 then
		item:getWidgetByName("vcoin"):loadTexture("vcoin_bind", ccui.TextureResType.plistType)
		item:getWidgetByName("labPrice"):setString(itemData.bvcion)
	else
		item:getWidgetByName("vcoin"):loadTexture("vcoin", ccui.TextureResType.plistType)
		item:getWidgetByName("labPrice"):setString(itemData.vcion)
	end
	if itemData.con then
		item:getWidgetByName("labYuTimes"):setVisible(true):setString("剩余："..(itemData.maxNum-itemData.con).."/"..itemData.maxNum)
	else
		item:getWidgetByName("labYuTimes"):setVisible(false)
	end
	item:getWidgetByName("labName"):setString(itemData.name)
	local awardItem=item:getWidgetByName("icon")
	local param={parent=awardItem , typeId=itemData.id, num=awardItem.num}
	GUIItem.getItem(param)

	local function prsBtnItem(sender)
		GameSocket:PushLuaTable("gui.ContainerWarProtecter.handlePanelData",GameUtilSenior.encode({actionid = "reqBuyTheExp",params={index=sender.index}}))
	end 
	local btnBuy = item:getWidgetByName("btnBuy")
	btnBuy.index=item.tag
	GUIFocusPoint.addUIPoint(btnBuy , prsBtnItem)
end

-----------------------------------------快捷购买进阶丹-----------------------------------------------
function ContainerWarProtecter.initBuyDan(data)
	if not var.xmlBuyDan then
		var.xmlBuyDan = GUIAnalysis.load("ui/layout/ContainerWarProtecter_buyDan.uif")
				:addTo(var.xmlPanel):align(display.CENTER, 234, 280)
				:show()
		local function prsBtnItem(sender)
			var.xmlBuyDan:hide()
		end 
		GUIFocusPoint.addUIPoint(var.xmlBuyDan:getWidgetByName("btnback"), prsBtnItem)
		var.xmlBuyDan:getWidgetByName("imgBg"):setTouchEnabled(true)
		var.xmlBuyDan:getWidgetByName("btnChongZhi"):setTouchEnabled(true):addClickEventListener(function ()
   			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
   		end)
	else
		var.xmlBuyDan:show()
	end
	var.buyDanData=data.data
	local listBuyDan = var.xmlBuyDan:getWidgetByName("listBuyDan")
	listBuyDan:reloadData(#var.buyDanData,ContainerWarProtecter.updateBuyDan):setSliderVisible(false)
	var.xmlBuyDan:getWidgetByName("lblVcoin"):setString(var.curVcion)
	var.xmlBuyDan:getWidgetByName("lblMoney"):setString(var.curMoney)
end

function ContainerWarProtecter.updateBuyDan(item)
	local itemData = var.buyDanData[item.tag]
	if itemData.bvcion>0 then
		item:getWidgetByName("vcoin"):loadTexture("vcoin_bind", ccui.TextureResType.plistType)
		item:getWidgetByName("labPrice"):setString(itemData.bvcion)
	else
		item:getWidgetByName("vcoin"):loadTexture("vcoin", ccui.TextureResType.plistType)
		item:getWidgetByName("labPrice"):setString(itemData.vcion)
	end
	if itemData.con then
		item:getWidgetByName("labYuTimes"):setVisible(true):setString("剩余："..(itemData.maxNum-itemData.con).."/"..itemData.maxNum)
	else
		item:getWidgetByName("labYuTimes"):setVisible(false)
	end
	item:getWidgetByName("labName"):setString(itemData.name)
	local awardItem=item:getWidgetByName("icon")
	local param={parent=awardItem, typeId=itemData.id, num=itemData.num}
	GUIItem.getItem(param)

	local function prsBtnItem(sender)
		GameSocket:PushLuaTable("gui.ContainerWarProtecter.handlePanelData",GameUtilSenior.encode({actionid = "reqBuyTheDan",params={index=sender.index}}))
	end 
	local btnBuy = item:getWidgetByName("btnBuy")
	btnBuy.index=item.tag
	GUIFocusPoint.addUIPoint(btnBuy , prsBtnItem)
end

-----------------------------------------按钮操作-----------------------------------------------
local btnArrs = {"btnJinJie","btnZhaoHuan","btnZhaoHui","btnBuyExp","btnBuyDan"}
function ContainerWarProtecter.initBtns()
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		-- print(senderName)
		if senderName=="btnJinJie" then
			GameSocket:PushLuaTable("gui.ContainerWarProtecter.handlePanelData",GameUtilSenior.encode({actionid = "reqJinJie",params={}}))
		elseif senderName=="btnZhaoHuan" then
			GameSocket:PushLuaTable("gui.ContainerWarProtecter.handlePanelData",GameUtilSenior.encode({actionid = "reqZhaoHuan",params={}}))
		elseif senderName=="btnZhaoHui" then
			GameSocket:PushLuaTable("gui.ContainerWarProtecter.handlePanelData",GameUtilSenior.encode({actionid = "reqZhaoHui",params={}}))
		elseif senderName=="btnBuyExp" then
			if var.xmlBuyDan then var.xmlBuyDan:hide() end
			if var.xmlBuyExp and var.xmlBuyExp:isVisible() then
				var.xmlBuyExp:hide()
			else
				GameSocket:PushLuaTable("gui.ContainerWarProtecter.handlePanelData",GameUtilSenior.encode({actionid = "reqBuyExpData",params={}}))
			end
		elseif senderName=="btnBuyDan" then
			if var.xmlBuyExp then var.xmlBuyExp:hide() end
			if var.xmlBuyDan and var.xmlBuyDan:isVisible() then
				var.xmlBuyDan:hide()
			else
				GameSocket:PushLuaTable("gui.ContainerWarProtecter.handlePanelData",GameUtilSenior.encode({actionid = "reqBuyDanData",params={}}))
			end
		end
	end
	for i=1,#btnArrs do
		local btn = var.xmlPanel:getWidgetByName(btnArrs[i])
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
	end
	local imgLight = var.xmlPanel:getWidgetByName("img_light")
	imgLight:stopAllActions()
	imgLight:runAction(cca.repeatForever(cca.seq({
			cca.fadeOut(0.5),
			cca.fadeIn(0.5),
		})
	))
end

-----------------------------------------------------召唤说明----------------------------------------------------------
function ContainerWarProtecter.initDesp()
	-- local btnDesp=var.xmlPanel:getWidgetByName("btnDesp"):setTouchEnabled(true)
	-- btnDesp:addTouchEventListener(function (pSender, touchType)
	-- 	if touchType == ccui.TouchEventType.began then
	-- 		ContainerWarProtecter.openCallDesp()
	-- 	elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then	
	-- 		GDivDialog.handleAlertClose()
	-- 	end
	-- end)
end

function ContainerWarProtecter.openCallDesp()
	local mParam = {
	name = GameMessageCode.EVENT_PANEL_ON_ALERT,
	panel = "tips", 
	infoTable = despCall,
	visible = true, 
	}
	GameSocket:dispatchEvent(mParam)

end


-----------------------------------------------------新技能提示----------------------------------------------------------
function ContainerWarProtecter.openNewSkill(skillLev)
	if skillLev<=0 or skillLev>10 then return end
	var.xmlPanel:getWidgetByName("skillIcon"..skillLev):getVirtualRenderer():setState(1)
	var.huiState=true
	if not var.xmlNewSkill then
		var.xmlNewSkill = GUIAnalysis.load("ui/layout/ContainerWarProtecter_newSkill.uif")
				:addTo(var.xmlPanel):align(display.LEFT_BOTTOM, 0, 0)
				:show()
		local function prsBtnItem(sender)
			var.xmlNewSkill:hide()
			ContainerWarProtecter.iconFly(sender.level,2)	
		end 
		local imgBg=var.xmlNewSkill:getWidgetByName("imgBg"):setTouchEnabled(true)
		local boxSkill=var.xmlNewSkill:getWidgetByName("box_new_skill"):setTouchEnabled(true)
		GUIFocusPoint.addUIPoint(imgBg, prsBtnItem)
		GUIFocusPoint.addUIPoint(boxSkill, prsBtnItem)
	else
		var.xmlNewSkill:show()
	end
	var.xmlNewSkill:getWidgetByName("skillName"):setString("【"..skillTable[skillLev].skillName.."】")
	var.xmlNewSkill:getWidgetByName("skillIcon"):loadTexture(skillTable[skillLev].iconRes, ccui.TextureResType.plistType)
	ContainerWarProtecter.iconFly(skillLev,1)
	var.xmlNewSkill:getWidgetByName("imgBg").level=skillLev
	var.xmlNewSkill:getWidgetByName("box_new_skill").level=skillLev
end

local flyPos = {{62,437},{62,356},{62,276},{62,194},{62,114},{415,437},{415,356},{415,276},{415,194},{415,114}}
function ContainerWarProtecter.iconFly(level,start)
	if not flyPos[level] then return end
	local flyIcon=var.xmlPanel:getWidgetByName("flyIcon"):setPosition(300,321):setVisible(true):loadTexture(skillTable[level].iconRes, ccui.TextureResType.plistType)
	-- local tempPos = GameUtilSenior.getWidgetCenterPos(boxSkill.icon)
	-- local endPos = var.skillModel:convertToNodeSpace(tempPos)
	local targetPosx = var.xmlPanel:getWidgetByName("skillBg"..level):getPositionX()
	local targetPosy = var.xmlPanel:getWidgetByName("skillBg"..level):getPositionY()
	local function moveAct2(target)
		target:stopAllActions()
		target:runAction(cca.seq({
			cca.moveTo(0.5, targetPosx, targetPosy),
			cca.cb(function ()
				-- target:stopAllActions()
				var.xmlNewSkill:hide()
				var.huiState=false
			end),
		}))
	end

	local function moveAct(target)
		target:stopAllActions()
		target:runAction(cca.seq({
			cca.delay(7), 
			cca.cb(function() 
				-- target:stopAllActions()
				var.xmlNewSkill:hide()
				moveAct2(target) 
			end),
		}))
	end
	if start==1 then
		moveAct(flyIcon)
	else
		moveAct2(flyIcon)
	end
end


return ContainerWarProtecter