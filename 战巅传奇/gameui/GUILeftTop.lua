local GUILeftTop={}

local var = {}
local nettick=0


local function handleSwitchUIMode(event)
	if not var.leftTop then return end
	local boxLeftTop = var.leftTop:getWidgetByName("box_left_top")
	if boxLeftTop then
		local posX, posY = boxLeftTop:getPosition()
		if event.mode == GameConst.UI_COMPLETE and posX < 0 then
			boxLeftTop:stopAllActions()
			boxLeftTop:runAction(cca.moveTo(0.5, 0, posY))
		elseif event.mode == GameConst.UI_SIMPLIFIED and posX > -500 then
			boxLeftTop:stopAllActions()
			boxLeftTop:runAction(cca.moveTo(0.5, -500, posY))
		end
	end

	local boxSimpleHead = var.leftTop:getWidgetByName("box_simple_head")
	if boxSimpleHead then
		local posX, posY = boxSimpleHead:getPosition()
		if event.mode == GameConst.UI_COMPLETE and posX > -500 then
			boxSimpleHead:stopAllActions()
			boxSimpleHead:runAction(cca.moveTo(0.5, -500, posY))
		elseif event.mode == GameConst.UI_SIMPLIFIED and posX < 0 then
			boxSimpleHead:stopAllActions()
			boxSimpleHead:runAction(cca.moveTo(0.5, 0, posY))
		end
	end
end

local function updateAvatarPower(event)
	if not GameCharacter._mainAvatar then return end
	if event.srcId == GameCharacter._mainAvatar:NetAttr(GameConst.net_id) then
		var.simplePowerBar:setPercent(event.power, event.maxPower)
	end
end

function GUILeftTop.init_ui(lefttop)
    var ={
    	leftTop,
    	boxHead,

    	simpleHpBar,
    	simplePowerBar,

    	hpBar,
    	mpBar,
    	pos_hp,
    	pos_mp,
    	lbl_hp,
    	lbl_mp,
    	-- taskFlag,
    	mFightAtlas,
    	mMoveSp={},
    	tagIndex=1000,
    	mScrollWidget,
    	-- mainAvatar = CCGhostManager:getMainAvatar(),
    	hide_layer,
    	pingState=0,
    	replaceWait=false,
    	preivewIcon,
    	levelUPAnim,
    	vipLevel=0,
    	buffLayer,
		onlineVIPTime=-1,  --保持在线领取VIP时间
		onlineVIPLevel=-1,   --保持在线领取ＶＩＰ等级
		onlineFirstPayGift=-1,  --第二天登录领取首充
	}
	var.leftTop = lefttop:align(display.LEFT_TOP, display.left, display.top)
	var.boxHead = lefttop:getWidgetByName("box_head")
	lefttop:setPosition(cc.p(display.left-20,display.top))

	lefttop:getWidgetByName("box_left_top"):setTouchEnabled(true)
	local btn_main_buff = lefttop:getWidgetByName("btn_main_buff"):setPressedActionEnabled(true)
	btn_main_buff:getTitleRenderer():setAdditionalKerning(0)
	local buffList = btn_main_buff:getWidgetByName("buffList"):hide()
	local buff_content = btn_main_buff:getWidgetByName("buff_content"):hide()
	btn_main_buff:addClickEventListener(function (sender)
		buff_content:setVisible(buffList.num and not buffList:isVisible())
		buffList:setVisible(not buffList:isVisible())
		if buffList:isVisible() and not buffList.num then
			buffList:setVisible(false)
		end
	end)
	var.buffLayer = lefttop:getWidgetByName("buffLayer"):hide():setPosition(display.cx,var.leftTop:getContentSize().height-display.cy)

	var.pos_hp=lefttop:getWidgetByName("pos_hp");
	var.pos_mp=lefttop:getWidgetByName("pos_mp");
	local function pushMenu(sender)
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_avatar"})
	end

	local function pushVip(sender)
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_vip" , } )
	end

	local vip_panel = nil
	local fight_bg = lefttop:getWidgetByName("fight_bg")
	local hide_layer = ccui.Layout:create()
	
	hide_layer:setAnchorPoint(cc.p(0,1))
	hide_layer:setContentSize(cc.size(300,30))
	hide_layer:setClippingEnabled(true)
	hide_layer:setPosition(cc.p(fight_bg:getContentSize().width+28,fight_bg:getContentSize().height/2+10))
	hide_layer:setName("hide_layer")
	hide_layer:setVisible(true)
	-- hide_layer:align(display.LEFT_BOTTOM, 140, display.height/2-81)
	var.boxHead:addChild(hide_layer)

	var.mFightAtlas = ccui.TextAtlas:create("0123456789","image/typeface/num_42.png", 10, 12,"0")
		:align(display.LEFT_BOTTOM, 7, -1)
		:addTo(fight_bg)
		:show()

	local str_hp = ""
	local str_maxhp = ""
	local str_mp = ""
	local str_maxmp = ""
	local str_level = ""
	-- local mModels
	local viplv = 0
	local str_power = ""
	local str_maxpower = ""

	if GameCharacter._mainAvatar then
		str_hp = GameCharacter._mainAvatar:NetAttr(GameConst.net_hp)
		str_maxhp = GameCharacter._mainAvatar:NetAttr(GameConst.net_maxhp)
		str_mp = GameCharacter._mainAvatar:NetAttr(GameConst.net_mp)
		str_maxmp = GameCharacter._mainAvatar:NetAttr(GameConst.net_maxmp)
		str_level = GameCharacter._mainAvatar:NetAttr(GameConst.net_level)

		str_power = GameCharacter._mainAvatar:NetAttr(GameConst.net_power) or 1
		str_maxpower = GameCharacter._mainAvatar:NetAttr(GameConst.net_maxpower) or 1
		-- mModels = GameSocket.mModels[GameCharacter._mainAvatar:NetAttr(GameConst.net_id)]
		viplv = GameSocket:getPlayerModel(GameCharacter._mainAvatar:NetAttr(GameConst.net_id),5)
	end

	--未开启VIP的话隐藏VIP
	local opened, level, funcName = GameSocket:checkFuncOpenedByID(20271)
	if not opened then
		lefttop:getWidgetByName("btn_vip"):setVisible(false)
	end
	var.vipLevel = lefttop:getWidgetByName("vipLevel"):setString(tostring(0))
	if viplv>0 then 
		var.vipLevel:setString(tostring(viplv))
	end
	lefttop:runAction(cca.repeatForever(
		cca.seq({
			cca.cb(function ()
				if var.onlineVIPLevel>0 then
					lefttop:getWidgetByName("btn_vip_tips"):show()
					lefttop:getWidgetByName("btn_vip_tips_time"):show()
					if var.onlineVIPTime>=0 then
						if var.onlineVIPTime>0 then
							var.onlineVIPTime= var.onlineVIPTime-1
						end
						GUILeftTop.doExtendAnimation(lefttop:getWidgetByName("btn_vip"))
						--lefttop:getWidgetByName("btn_vip_tips"):setText()
						if var.onlineVIPTime==0 then
							lefttop:getWidgetByName("btn_vip_tips"):setText("点击领取VIP"..var.onlineVIPLevel)
							lefttop:getWidgetByName("btn_vip_tips_time"):setText("")
						else
							if var.onlineVIPLevel==1 then
								lefttop:getWidgetByName("btn_vip_tips"):setText("保持在线可领VIP(仅限今日)")
							else
								lefttop:getWidgetByName("btn_vip_tips"):setText("保持在线可领VIP"..var.onlineVIPLevel)
							end
							lefttop:getWidgetByName("btn_vip_tips_time"):setText("即将领取："..GameUtilSenior.setTimeFormat(var.onlineVIPTime*1000,1))
						end
					end
				end
				if var.onlineVIPLevel==0 then
					lefttop:getWidgetByName("btn_vip_tips"):show()
					lefttop:getWidgetByName("btn_vip_tips_time"):show()
					lefttop:getWidgetByName("btn_vip_tips"):setText("明日登录游戏可提升VIP")
					if var.onlineFirstPayGift==1 then
						lefttop:getWidgetByName("btn_vip_tips_time"):setText("明日登录可领取首充礼包")
					elseif var.onlineFirstPayGift==2 then
						lefttop:getWidgetByName("btn_vip_tips_time"):setText("明日登录可领取6元钻石")
					else
						lefttop:getWidgetByName("btn_vip_tips_time"):hide()
					end
				end
				if var.onlineVIPLevel<0 then
					lefttop:getWidgetByName("btn_vip_tips"):hide()
					lefttop:getWidgetByName("btn_vip_tips_time"):hide()
				end
			end),
			cca.delay(1)
		})
	))

	--var.hpBar = lefttop:getWidgetByName("pos_hp"):setPercent(str_hp,str_maxhp):setFontSize( 14 ):enableOutline(GameBaseLogic.getColor(0x490000),1)
	--local lblHpBar = lefttop:getWidgetByName("pos_hp"):getLabel()
	--if lblHpBar then
	--	lblHpBar:getVirtualRenderer():setAdditionalKerning(2)
	--end

	--var.mpBar = lefttop:getWidgetByName("pos_mp"):setPercent(str_mp,str_maxmp):setFontSize( 14 ):enableOutline(GameBaseLogic.getColor(0x000049),1)
	--local lblMpBar = lefttop:getWidgetByName("pos_mp"):getLabel()
	--if lblMpBar then
	--	lblMpBar:getVirtualRenderer():setAdditionalKerning(2)
	--end

	var.simpleHpBar = lefttop:getWidgetByName("img_simple_hp"):setPercent(str_hp,str_maxhp)
	var.simpleHpBar:getLabel():hide()

	var.simplePowerBar = lefttop:getWidgetByName("img_simple_inner_power"):setPercent(str_power,str_maxpower)
	var.simplePowerBar:getLabel():hide()




	local btn_menu = lefttop:getWidgetByName("btn_menu")
	local btn_vip = lefttop:getWidgetByName("btn_vip")
	if PLATFORM_BANSHU then
		btn_vip:setVisible(false):setPressedActionEnabled(true)
	end

	if PLATFORM_BANSHU then btn_vip:hide() end

	GUIFocusPoint.addUIPoint(btn_menu, pushMenu)
	var.mScrollWidget = GUIRollWar.initWidget(GUILeftTop.freshFight)
	var.mScrollWidget:setPosition(cc.p(fight_bg:getContentSize().width,fight_bg:getContentSize().height/2+15))
	fight_bg:addChild(var.mScrollWidget)

	GUILeftTop.freshFight(GameSocket.mCharacter.mFightPoint)  --获取玩家攻击力
	table.insert(GUIFocusPoint.UIBtnTab, {btn_menu, pushMenu})
	if not PLATFORM_BANSHU then
		table.insert(GUIFocusPoint.UIBtnTab,{btn_vip,pushVip})
		GUIFocusPoint.addUIPoint(btn_vip,pushVip)
	end
	local head_key ={"new_main_ui_head.png","head_fzs","head_mfs","head_ffs","head_mds","head_fds"}

	-- GameCharacter._mainAvatar =  CCGhostManager:getMainAvatar()
	if GameCharacter._mainAvatar then
		local job = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)
		local gender = GameCharacter._mainAvatar:NetAttr(GameConst.net_gender)
		local id = (job-100) * 2 + gender - 199
		lefttop:getWidgetByName("rolemain_pic"):loadTexture(head_key[id],ccui.TextureResType.plistType)
	end
	lefttop:getWidgetByName("lblLevel"):setString(""..GameCharacter._mainAvatar:NetAttr(GameConst.net_level))
	lefttop:getWidgetByName("lblchrname"):setString(GameBaseLogic.chrName)

	var.levelUPAnim = GUIAnalysis.load("ui/layout/upToLevel.uif")
	if var.levelUPAnim then
		var.levelUPAnim:addTo(lefttop)
		:align(display.CENTER, display.cx, -display.cy/2)
		:hide()
	end
	lefttop:getWidgetByName("btn_exit")
		-- :align(display.LEFT_CENTER, display.left+5, 10)
		:hide()
		:addClickEventListener(function (sender)
			GameSocket:PushLuaTable("gui.moduleShortCut.reqShortCut", GameUtilSenior.encode({actionid = "exitCopy"}))
		end)

	cc.EventProxy.new(GameSocket, lefttop)
		:addEventListener(GameMessageCode.EVENT_SELF_HPMP_CHANGE, GUILeftTop.freshHPMP)
		:addEventListener(GameMessageCode.EVENT_LEVEL_CHANGE, GUILeftTop.handleLevelChange)
		:addEventListener(GameMessageCode.EVENT_ATTRIBUTE_CHANGE,GUILeftTop.updatefight)
		:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, GUILeftTop.handlePanelData)
		:addEventListener(GameMessageCode.EVENT_CHANGE_MAP, GUILeftTop.handleChangeMap)
		:addEventListener(GameMessageCode.EVENT_MODEL_SET, GUILeftTop.modelChange)
		:addEventListener(GameMessageCode.EVENT_BUFF_CHANGE, GUILeftTop.buffChange)
		:addEventListener(GameMessageCode.EVENT_SWITCH_UI_MODE, handleSwitchUIMode)
		:addEventListener(GameMessageCode.EVENT_INNERPOWER_CHANGE, updateAvatarPower)

	if GameSocket.previewData and GameSocket.previewData.show then
		GUILeftTop.initNotice(GameSocket.notice)
	end

	local boxAttack = lefttop:getWidgetByName("box_attack")
	GUIAttackType.init(boxAttack)

	GUILeftTop.buffChange({srcId = GameCharacter.mID})
	
	GameSocket:PushLuaTable("gui.ContainerVip.onPanelData",GameUtilSenior.encode({actionid = "onlineVIP",params={}}))
	
end
function GUILeftTop.updatePing( ping )
	-- body
	-- var.imgWifiState
	local outlineSize = 1
	var.pingTxt = var.leftTop:getWidgetByName("box_left_top"):getChildByName("txtPing")
	if not var.pingTxt then
		var.pingTxt = GameUtilSenior.newUILabel({fontSize = 16 , color = GameBaseLogic.getColor(0x18d129)}):addTo(var.leftTop:getWidgetByName("box_left_top")):setName("txtPing")
					 :setAnchorPoint(cc.p(0,0.5))
					 :pos(255,40)
					 :enableOutline(GameBaseLogic.getColor(0x00000), outlineSize)
	end
	var.pingTxt:setString(ping)
end
function GUILeftTop.updatefight()
	if var.mFightAtlas then
		GUILeftTop.freshFight(GameSocket.mCharacter.mFightPoint)
	end
end

function GUILeftTop.handlePanelData(event)
	local data = GameUtilSenior.decode(event.data)
	if event.type =="equippreview" then
		GUILeftTop.initNotice(data)
	end
	if event.type=="ContainerRewardLeft" then
		if data.cmd =="updateOnlineVIPData" then
			var.onlineVIPLevel = data.vip
			var.onlineVIPTime = data.onlineTime
			var.onlineFirstPayGift = data.firstPayGift
		end
	end

end

function GUILeftTop.changeAct()
	GUIRollWar.AddNewFight(var.mScrollWidget,1234,15668)
end


function GUILeftTop.freshHPMP(event)
	if MainRole and GameCharacter._mainAvatar and event.param then
		local hp = 		GameCharacter._mainAvatar:NetAttr(GameConst.net_hp)
		local maxhp = 	GameCharacter._mainAvatar:NetAttr(GameConst.net_maxhp)
		local mp =		GameCharacter._mainAvatar:NetAttr(GameConst.net_mp)
		local maxmp = 	GameCharacter._mainAvatar:NetAttr(GameConst.net_maxmp)

		local power = GameCharacter._mainAvatar:NetAttr(GameConst.net_power)
		local maxpower = GameCharacter._mainAvatar:NetAttr(GameConst.net_maxpower)

		-- var.hpBar:setPercentage(checkint(hp*100/maxhp))
		-- var.lbl_hp:setString(hp.."/"..maxhp)
		-- var.mpBar:setPercentage(checkint(mp*100/maxmp))
		-- var.lbl_mp:setString(mp.."/"..maxmp)
		--var.hpBar:setPercent(hp,maxhp)
		--var.mpBar:setPercent(mp,maxmp)

		var.simpleHpBar:setPercent(hp,maxhp)
		var.simplePowerBar:setPercent(power,maxpower)
	end
end

function GUILeftTop.handleLevelChange(event)
	-- GUILeftTop.alertLevelMsg(tonumber(var.leftTop:getWidgetByName("lblLevel"):getString()),tonumber(event.level),true)
	var.leftTop:getWidgetByName("lblLevel"):setString(""..event.level)
	if not GameUtilSenior.isObjectExist(var.levelUPAnim) then return end
	local level
	if event.level and type(event.level) =="number" then
		-- local curLevel = var.levelUPAnim.level or 1
		-- if event.level - curLevel <2 then
		-- 	var.levelUPAnim:getWidgetByName("img_up"):loadTexture("img_levelto",ccui.TextureResType.plistType)
		-- else
		-- 	var.levelUPAnim:getWidgetByName("img_up"):loadTexture("img_upnow",ccui.TextureResType.plistType)
		-- end
		-- level = event.level
		-- var.levelUPAnim.level = event.level
		GUILeftTop.refreshLevel(event.level)
		-- var.levelUPAnim:getWidgetByName("img_lv"):loadTexture("img_level",ccui.TextureResType.plistType)
	-- elseif event.zslevel and type(event.zslevel) =="number" then
	-- 	var.levelUPAnim:getWidgetByName("img_up"):loadTexture("img_levelto",ccui.TextureResType.plistType)
	-- 	var.levelUPAnim:getWidgetByName("img_lv"):loadTexture("img_zhuan",ccui.TextureResType.plistType)
	-- 	level = event.zslevel
	end
	-- local levelchar = var.levelUPAnim:getChildByName("levelchar")
	-- if not levelchar then
	-- 	levelchar = ccui.TextAtlas:create("0123456789", "image/typeface/exp.png", 31, 56, "0")
	-- 	levelchar:addTo(var.levelUPAnim)
	-- 	:align(display.LEFT_CENTER, 200, 160)
	-- 	:setName("levelchar")
	-- end
	-- levelchar:setString(level)
	-- var.levelUPAnim:getWidgetByName("img_lv"):setPositionX(200 + 32*math.ceil(math.log10(level+1)))
	-- local lightSprite = var.levelUPAnim:getChildByName("lightSprite")
	-- if not lightSprite then
	-- 	lightSprite = cc.Sprite:createWithSpriteFrameName("img_light01")
	-- 	lightSprite:setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
	-- 	lightSprite:setName("lightSprite")
	-- 	lightSprite:addTo(var.levelUPAnim):align(display.CENTER, 60, 150)--:hide()
	-- end
	-- lightSprite:setPosition(60,150):setScale(0.2):stopAllActions()
	-- lightSprite:runAction(cca.seq({
	-- 	cca.delay(0.3),
	-- 	cca.show(),
	-- 	cca.spawn({
	-- 		cca.scaleTo(0.5,1),
	-- 		cca.moveBy(0.5, 330, 0),
	-- 		}),
	-- 	cca.hide()
	-- 	}))
	-- var.levelUPAnim:stopAllActions():setPosition(display.cx, -display.cy/2):setScale(1)
	-- var.levelUPAnim:runAction(cca.seq({
	-- 	cca.show(),
	-- 	cca.spawn({
	-- 		cca.scaleTo(0.1,1.1),
	-- 		cca.moveBy(0.1, 0, 20),
	-- 		}),
	-- 	cca.delay(1.5),
	-- 	cca.hide()
	-- 	}))
end

function GUILeftTop.refreshLevel(targetLevel)
	var.leftTop:getWidgetByName("lblLevel"):setString(""..targetLevel)
	GameSocket:alertLocalMsg("恭喜您升级到"..targetLevel.."级","post")
	local temp = {}
	local param = {}
	param.hp = GameCharacter._mainAvatar:NetAttr(GameConst.net_hp)
	param.maxhp = GameCharacter._mainAvatar:NetAttr(GameConst.net_maxhp)
	param.mp = GameCharacter._mainAvatar:NetAttr(GameConst.net_mp)
	param.maxmp = GameCharacter._mainAvatar:NetAttr(GameConst.net_maxmp)
	temp.param = param
	GUILeftTop.freshHPMP(temp)
end

function GUILeftTop.alertLevelMsg(curLevel,targetLevel,delay)

	local levelDiff = targetLevel-curLevel or 1
	local levelText,moveToX,moveToY
	if levelDiff <= 1 then
		levelText = "提升到    级!"
		moveToX=display.width/2-18
		moveToY=-220
	else
		moveToX=display.width/2-140
		moveToY=-220
		levelText = "提升到    级!瞬间直升了    级!"
	end	

	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SCENE_SHAKE})

	local parentLayer = cc.Layer:create():addTo(var.leftTop)

	levelUp = ccui.Text:create("", FONT_NAME, 36)
	:setColor(GameConst.color(9))
	:addTo(parentLayer)
	:align(display.CENTER, 100, -220)
	:size(cc.size(display.width, display.height))
	:setString(targetLevel)

	depict = ccui.Text:create("", FONT_NAME, 30)
	:setColor(cc.c3b(200,200,0))
	:addTo(parentLayer)
	:align(display.CENTER, 50, -220)
	:size(cc.size(display.width, display.height))
	:setString(levelText)

	depict:runAction(
		cca.seq({
			cca.moveTo(0.5, display.width/2-40, -220),
			cca.delay(1.5),
			cca.hide(),
		}))

	levelUp:runAction(
		cca.seq({
			cca.moveTo(0.5, moveToX, moveToY),
			cca.delay(1.5),
			cca.hide(),
		}))

	if levelDiff > 1 then
		levelDir = ccui.Text:create("", FONT_NAME, 36)
		:setColor(GameConst.color(9))
		:addTo(parentLayer)
		:align(display.CENTER, 100, -220)
		:size(cc.size(display.width, display.height))
		:setString(levelDiff)

		levelDir:runAction(
		cca.seq({
			cca.moveTo(0.5, display.width/2+110, -220),
			cca.delay(1.5),
			cca.moveTo(0.5, 0, 400),
			cca.scaleTo(0.5,0.3,0.3),
			cca.hide(),
			cca.callFunc(function ()
				if delay then
					GUILeftTop.refreshLevel(targetLevel)
				end	
			end)	

		}))
	else
		GUILeftTop.refreshLevel(targetLevel)
	end	

end

function GUILeftTop.fightChange(add, all)

	local hander
	local fight_bg = var.leftTop:getWidgetByName("fight_bg")
	local hide_layer = fight_bg:getWidgetByName("hide_layer")
	local mAdd = GUIRollWar.IntToStringTab(add)
	local mAll = GUIRollWar.IntToStringTab(all)
	if mAdd and mAll then
		local sprite_bg = ccui.Widget:create()
		sprite_bg:setPosition(cc.p((GameConst.VISIBLE_WIDTH-GameConst.VISIBLE_X)/2,-(GameConst.VISIBLE_Y+GameConst.VISIBLE_HEIGHT)/2))
		sprite_bg:setName("sprite_bg_"..var.tagIndex)
		sprite_bg:setTag(var.tagIndex)
		var.leftTop:addChild(sprite_bg)
		for i = 0, 10 do
			local fight_sprite
			if i <= #mAdd then
				if i == 0 then
					fight_sprite = ccui.ImageView:create()
					fight_sprite:loadTexture("img_power",ccui.TextureResType.plistType)
					if add < 0 then
						fight_sprite:loadTexture("img_power",ccui.TextureResType.plistType)
					end
				else
					fight_sprite = ccui.ImageView:create()
					--fight_sprite:loadTexture("new_main_ui_img_power_"..mAdd[i]..".png",ccui.TextureResType.plistType)
					fight_sprite:setVisible(true)
				end
				-- fight_sprite:setScale(1.5)
				fight_sprite:setPosition(cc.p(15*(i-1-math.floor(#mAdd/2)),0))
				sprite_bg:addChild(fight_sprite)
			end
		end

		local function runNumScroll()
			hide_layer:setVisible(false)
			for i = 1000, var.tagIndex - 1 do
				if var.leftTop:getChildByTag(i) then
					if not var.leftTop:getChildByTag(i):getActionByTag(i) then
						var.leftTop:getChildByTag(i):stopAllActions()
						var.leftTop:removeChildByTag(i)
					end
				end
			end
			if var.mScrollWidget then
				var.mScrollWidget:setVisible(true)
				GUIRollWar.AddNewFight(var.mScrollWidget, add, all)
			end
		end

		local function runActionBottom()
			if hander then
				Scheduler.unscheduleGlobal(hander)
				hander = nil
			end
			if sprite_bg then
				local action = cc.Sequence:create(
							cc.EaseSineOut:create(cc.MoveTo:create(1.0, cc.p(fight_bg:getPositionX()+fight_bg:getContentSize().width+24*#mAll-60,
								fight_bg:getPositionY()-fight_bg:getContentSize().height - 80))),cc.CallFunc:create(runNumScroll))
				action:setTag(var.tagIndex)
				sprite_bg:runAction(action)
				var.tagIndex = var.tagIndex + 1
			end
		end
		hander = Scheduler.scheduleGlobal(runActionBottom,0.01)
	end
end

function GUILeftTop.freshFight(number)
	if var.mScrollWidget then
		var.mScrollWidget:setVisible(false)
		if var.leftTop:getChildByTag(var.tagIndex-1) and not var.leftTop:getChildByTag(var.tagIndex-1):getActionByTag(var.tagIndex-1) then
			var.leftTop:getChildByTag(var.tagIndex-1):stopAllActions()
			var.leftTop:removeChildByTag(var.tagIndex-1)
		end
	end
	
	var.mFightAtlas:setString(number)
	-- local mModels = GameSocket.mModels[GameCharacter._mainAvatar:NetAttr(GameConst.net_id)]
	local viplv = GameSocket:getPlayerModel(GameCharacter._mainAvatar:NetAttr(GameConst.net_id),5)
	if viplv>0 then 
		var.vipLevel:setString(tostring(viplv))
	end
end

function GUILeftTop.modelChange(event)
	if event.modelId == 5 then
		local viplv = GameSocket:getPlayerModel(GameCharacter._mainAvatar:NetAttr(GameConst.net_id),5)
		if viplv>0 then 
			var.vipLevel:setString(tostring(viplv))
		end
	end
end

function GUILeftTop.resetTick()
	-- if not nettick then return end

	-- if nettick<-40 then
	-- 	nettick=-40
	-- elseif nettick<-15 then
	-- 	nettick=-15
	-- elseif nettick<-3 then
	-- 	nettick=-3
	-- end
end

function GUILeftTop.update()
	if not var.leftTop then return end

	--防止刚进游戏就超时
	if var.pingState==0 then GameSocket.mPingDelay=GameBaseLogic.ClockTick end
	local delay = 0
	if GameSocket.mPingDelay~= 0 then
		delay=(GameBaseLogic.ClockTick-GameSocket.mPingDelay)*(1000/CONFIG_FPS)
	end
	-- print(GameSocket.mPingDelay,delay)
	local state=1
	if delay<1500 then
		state=1
		-- if nettick==0 then
		-- 	nettick=-3
		-- 	cc.SocketManager:setTICK(nettick)
		-- end
	elseif delay>=1500 and delay<2400 then
		state=1
		-- if nettick>-15 then
		-- 	nettick=-15
		-- 	cc.SocketManager:setTICK(nettick)
		-- end
	-- elseif delay>=2000 and delay<5000  then
	-- 	state=2
	-- 	if nettick>-40 then
	-- 		nettick=-40
	-- 		cc.SocketManager:setTICK(nettick)
	-- 	else
	-- 		nettick=-1000
	-- 		cc.SocketManager:setTICK(nettick)
	-- 	end
	-- elseif delay>=5000 and delay<8000  then
	-- 	state=3
	-- 	if nettick>-1000 then
	-- 		nettick=-1000
	-- 		cc.SocketManager:setTICK(nettick)
	-- 	end
	elseif delay>=10000 and var.pingState>0 and not var.replaceWait then
		-- state=4
		-- var.replaceWait=true
		-- var.leftTop:runAction(
		-- 	cca.seq({
		-- 		cca.delay(0.1),
		-- 		cca.cb(function()

		-- 			-- GameBaseLogic.downLoading=false
		-- 			-- cc.DownManager:getInstance():setAllowDown(GameBaseLogic.downLoading)

		-- 			GameSocket:dispatchEvent({ name = GameMessageCode.EVENT_SOCKET_ERROR, code=0})
		-- 		end)
		-- 	})
		-- )
	end
	
	-- if var.pingState~=state then
	-- 	var.leftTop:getWidgetByName("imgWifiState"):loadTexture("img_WiFi_0"..state,ccui.TextureResType.plistType)
	-- end

	var.pingState=state
end

-------------------------------开放预告-----------------------------------
local iconTable = {
	[1] = {20005,20006,20007},
	[2] = {29002,29002,29002},
	[3] = {40005,40006,40007},
	[4] = {20005,20006,20007}
}

local previewRes = {
	["level"] = "preview_shortdesp_level",
	["upgrade"] = "preview_shortdesp_upgrade",
	["recycle"] = "preview_shortdesp_recycle",
	["mon"] = "preview_shortdesp_kill",
	["boss"] = "preview_shortdesp_kill",
}

local euqipRes = {
	
}

function GUILeftTop.initNotice(data)
	-- GUILeftTop.initLevOpenNotice(data)
	if GameSocket.previewData and GameSocket.previewData.show then
		local function updatePreviewIcon()
			if var.preivewIcon then
				local item = var.preivewIcon:getWidgetByName("item"):setCascadeOpacityEnabled(true)
				-- local param={
				-- 	parent=item , 
				-- 	typeId=GameSocket.previewData.showEquip
				-- }
				-- GUIItem.getItem(param)
				-- item:setTouchEnabled(false)
				--var.preivewIcon:getWidgetByName("item"):loadTexture("image/icon/"..GameSocket.previewData.showEquip..".png", ccui.TextureResType.localType)
				
				
				asyncload_callback("image/icon/"..GameSocket.previewData.showEquip..".png", var.preivewIcon:getWidgetByName("item"), function(path, texture)
					var.preivewIcon:getWidgetByName("item"):loadTexture(path)
				end)
				
				local condition = GameSocket.previewData.condition
				if previewRes[condition.mType] then
					var.preivewIcon:getWidgetByName("imgShortDesp"):loadTexture(previewRes[condition.mType], ccui.TextureResType.plistType):show()
				else
					var.preivewIcon:getWidgetByName("imgShortDesp"):hide()
				end
				if condition.mType == "level" then
					var.preivewIcon:getWidgetByName("lblNeedLevel"):setString(condition.num):show()
				else
					var.preivewIcon:getWidgetByName("lblNeedLevel"):hide()
				end
			end
		end

		if not var.preivewIcon then
			local pSize = var.leftTop:getContentSize()
			asyncload_frames("ui/sprite/PreviewIcon", ".png", function ()
				var.preivewIcon = GUIAnalysis.load("ui/layout/PreviewIcon.uif")
					:align(display.RIGHT_CENTER, pSize.width*0.4, pSize.height * 0.6)
					:addTo(var.leftTop)
					:setTouchEnabled(true)
					:setName("previewIcon")
				GUIFocusPoint.addUIPoint(var.preivewIcon, function (pSender)
					GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_equippreview"})
				end)

				local frames = {}
				local spriteFrameCache = cc.SpriteFrameCache:getInstance()
				for i=1,3 do
					local frameName = string.format("preview_light_%d", i)
					local frame = spriteFrameCache:getSpriteFrame(frameName)
					frames[#frames + 1] = frame
				end

				local animation = display.newAnimation(frames, 1 / 4) -- 0.5 秒播放 8 桢
				local lightSprite = cc.Sprite:create()
					:align(display.CENTER, 58, 55)
					:addTo(var.preivewIcon, -1)
				lightSprite:playAnimationForever(animation)
				updatePreviewIcon()
			end,var.leftTop)
		else
			updatePreviewIcon()
		end
	else
		if var.preivewIcon then
			var.preivewIcon:removeFromParent()
			var.preivewIcon = nil
		end
	end
end

function GUILeftTop.initLevOpenNotice(data)
	
	local pSize = var.leftTop:getContentSize()
	if not var.openNotice then
		var.openNotice = GUIAnalysis.load("ui/layout/PanelOpenNotice.uif")
								:align(display.RIGHT_CENTER, pSize.width*0.5, pSize.height * 0.55)
								:addTo(var.leftTop)
								:setTouchEnabled(false)	
								:setLocalZOrder(0)
								-- :setScale(0.7)

		local imgBg = var.openNotice:getWidgetByName("imgBg")
		local filepath = "ui/image/img_newfunc_frame2.png"
		asyncload_callback(filepath, imgBg, function(filepath, texture)
			imgBg:loadTexture(filepath)
		end)

		var.openNotice:setTouchEnabled(true)
		var.openNotice:addTouchEventListener(function(pSender,pType)
			if pType == ccui.TouchEventType.began then
				transition.pauseTarget(pSender)
			elseif pType == ccui.TouchEventType.ended or pType == ccui.TouchEventType.canceled then
				transition.resumeTarget(pSender)
			end
		end)
		var.openNotice:stopAllActions()
		-- var.openNotice:runAction(cca.repeatForever(
		-- 	cca["sineInOut"](cca.spawn({
		-- 		cca.seq({cca.moveBy(0.8, 3, 3), cca.moveBy(0.8, -3, -3)}),
		-- 		cca.seq({cca.scaleTo(0.8, 0.95), cca.scaleTo(0.8, 1.0)})
		-- 	}))
		-- ))
	end

	if data.nextData then
		local funcIcon = var.openNotice:getWidgetByName("imgIcon")
		if data.nextData.mType == "menu"then
			asyncload_callback("image/icon/"..data.nextData.func..".png", funcIcon, function(filepath, texture)
				funcIcon:loadTexture(filepath, ccui.TextureResType.localType)
			end)
			funcIcon:setScale(0.7)
		elseif data.nextData.mType == "rtpart" then
			funcIcon:setScale(0.8)
			funcIcon:loadTexture(data.nextData.func, ccui.TextureResType.plistType) 
		elseif  data.nextData.mType == "rcpart" then
			funcIcon:setScale(0.7)
			funcIcon:loadTexture(data.nextData.func, ccui.TextureResType.plistType) 
		end
		var.openNotice:getWidgetByName("labDesp"):setString(data.nextData.level.."级开放"..data.nextData.name)

	end

	if data.sum==999 then
		var.openNotice:setVisible(false)
		var.openNotice = nil
	end
end

function GUILeftTop.handleChangeMap(event)
	var.leftTop:getWidgetByName("btn_exit"):hide()
	--mapId:地图id或特殊标记 
	--btnShow：是否显示退出地图按钮(true:显示 false:关闭)
	--iconsShow：是否隐藏顶部功能按钮(true:打开 false:关闭)
	-- local mapIds = {
	-- 	["未知暗点"]={mapId="v200" , btnShow=true , iconsShow=true},
	-- 	["玛雅神殿"]={mapId="v203" , btnShow=true , iconsShow=false},
	-- 	["玛雅二层"]={mapId="v204" , btnShow=true , iconsShow=false},
	-- 	["玛雅三层"]={mapId="v205" , btnShow=true , iconsShow=false},
	-- 	["boss之家"]={mapId="v206" , btnShow=true , iconsShow=false},
	-- 	["boss二层"]={mapId="v207" , btnShow=true , iconsShow=false},
	-- 	["转生神殿"]={mapId="v212" , btnShow=true , iconsShow=false},
	-- }
	-- for k,v in pairs(mapIds) do
	-- 	if string.find(GameSocket.mNetMap.mMapID , v.mapId) then
	-- 		var.leftTop:getWidgetByName("btn_exit"):show()
	-- 		GUIRightTop.setIconsVisible(v.iconsShow)
	-- 		break
	-- 	end
	-- end
	-- if GameSocket.mNetMap.mMapID=="v200" and var.openNotice then
	-- 	var.openNotice:setVisible(false)
	-- elseif var.openNotice then
	-- 	var.openNotice:setVisible(true)
	-- end
end
--[[
	buffDef-id,level,uisort,effres,starttime,timemax,efftype,icon,desp,ui,name,type
]]
function GUILeftTop.getMyBuff(buffId)
	local myBuffs = {}
	if GameSocket.mNetBuff[GameCharacter.mID] then
		for k,v in pairs(GameSocket.mNetBuff[GameCharacter.mID]) do
			if GameUtilSenior.isTable(v.buffdef) and v.buffdef.ui%10 > 0 then--ui>0显示
				if not buffId then
					table.insert(myBuffs,v)
				elseif buffId == k then
					return v
				end
			end
		end
		if #myBuffs>1 then
			table.sort(myBuffs,function(a,b)
				return a.buffdef.uisort<b.buffdef.uisort
			end)
		end
	end
	return myBuffs
end

function GUILeftTop.showBuffDesp(srcId,buffId)
	if srcId and buffId then
		local buffDef = NetCC:getBuffDef(buffId)
		local myBuff = GUILeftTop.getMyBuff(buffId)
		if myBuff and buffDef and buffDef.name then
			var.buffLayer:show()
			local buff_icon = var.buffLayer:getWidgetByName("buff_icon")
			local buffDesp = var.buffLayer:getWidgetByName("buffDesp")
			buff_icon:loadTexture(buffDef.icon,ccui.TextureResType.plistType)
			-- buff_icon:setContentSize(30, 30)
			buff_icon:setScale(28/20):pos(15,15)
			var.buffLayer:getWidgetByName("buffname"):setString(buffDef.name)
			local desp = buffDef.desp
			-- desp = string.gsub(buffDef.desp,"%b<>",function(s)
			-- 	if string.find(s,"br") then 
			-- 		return "\n"
			-- 	else 
			-- 		return s 
			-- 	end 
			-- end)
			desp = string.gsub(desp,"%%","%%%%")
			local timeRemain
			local validType = math.floor(buffDef.ui/10)
			if validType == 4 then
				desp = desp.."<br>剩余血量：<font color=#00ff00>"..myBuff.timeRemain.."</font>";
			elseif validType == 1 then
				timeRemain = myBuff.timeRemain + myBuff.starttime-os.time()
				desp = desp.."<br>剩余时间：<font color=#00ff00>%s</font>";
			end
			var.buffLayer:stopAllActions()
			local richDesp = buffDesp:getWidgetByName("richDesp")
			if not richDesp then
				richDesp = GUIRichLabel.new({space = 3, size = buffDesp:getContentSize(),name="richDesp",anchor=cc.p(0,1)}):addTo(buffDesp):setPosition(cc.p(0,buffDesp:getContentSize().height))
			end
			local strdesp
			if timeRemain then
				strdesp = string.format(desp,GameUtilSenior.setTimeFormat(timeRemain*1000))
				richDesp:setRichLabel(strdesp,"",16)
				var.buffLayer:runAction(cca.rep(cca.seq({
					cca.delay(1),
					cca.cb(function(target)
						if timeRemain>0 then
							timeRemain = timeRemain -1
							strdesp = string.format(desp,GameUtilSenior.setTimeFormat(timeRemain*1000))
							richDesp:setRichLabel(strdesp,"",16)
						else
							var.buffLayer:hide():stopAllActions()
						end
					end)
					}),timeRemain)
				)
			else
				richDesp:setRichLabel(desp,"",16)
			end
		end
	else
		var.buffLayer:hide():stopAllActions()
	end
end

function GUILeftTop.buffChange(event)
	if GameCharacter._mainAvatar and event.srcId == GameCharacter.mID and (not event.opCode or event.opCode<=4) then
		local myBuffs = GUILeftTop.getMyBuff()
		local btn_main_buff = var.leftTop:getWidgetByName("btn_main_buff")
		--btn_main_buff:setTitleText("BUFF*"..table.nums(myBuffs).."   ")
		local buffList = btn_main_buff:getWidgetByName("buffList"):setTouchEnabled(false)
		local buff_content = var.leftTop:getWidgetByName("buff_content")
		local width = (#myBuffs>5 and 5 or #myBuffs)*33+3
		local height = math.ceil(#myBuffs/5)*33+3
		buffList.num = #myBuffs>0
		buff_content:setContentSize(cc.size(width,height))
		if buffList:isVisible() then
			buffList:setVisible(buffList.num)
		end
		buffList:reloadData(#myBuffs, function( subItem )
			local d = myBuffs[subItem.tag]
			local icon = "null"
			-- if buffdef then
			icon =d.buffdef.icon 
			-- end
			local buffbtn = subItem:getWidgetByName("icon")
			buffbtn.buffId = d.buffId
			buffbtn.srcId = event.srcId
			
			buffbtn:loadTextureNormal(icon,ccui.TextureResType.plistType)
			-- buffbtn:setContentSize(28, 28)
			buffbtn:setScale(28/20):pos(15,15)
			buffbtn:setTouchEnabled(true)
			buffbtn:setEnabled(d.enable)
			if not buffbtn.touch then
				buffbtn.touch = true
				buffbtn:addTouchEventListener(function(sender,TouchType)
					if TouchType == ccui.TouchEventType.began then
						GUILeftTop.showBuffDesp(sender.srcId,sender.buffId)
					elseif TouchType ~= ccui.TouchEventType.moved then
						GUILeftTop.showBuffDesp()
					end
				end)
			end
		end, 0, false)
	end
end

function GUILeftTop.doExtendAnimation(v)

	btnName = v:getName()
	animaSprite = v:getChildByName("animaSprite")
	pSize = v:getContentSize()
	if animaSprite then animaSprite:stopAllActions():hide() end
	if not animaSprite then
		animaSprite = cc.Sprite:create()
			:align(display.CENTER, 0.5 * pSize.width, 0.5 * pSize.height)
			:addTo(v)
			:setName("animaSprite")
	end
	animate = cc.AnimManager:getInstance():getPlistAnimate(4, 60040, 4, 5,false,false,0,function(animate,shouldDownload)
					animaSprite:show():runAction(animate)
					animaSprite:setBlendFunc({src=gl.SRC_ALPHA,dst=gl.ONE})
					if shouldDownload==true then
						animaSprite:release()
						var.boxExtend:release()
						v:release()
					end
				end,
				function(animate)
					animaSprite:retain()
					var.boxExtend:retain()
					v:retain()
				end)

end


return GUILeftTop