local GUISkill = {}

--公共cd
local ATTACK_SKILL={
	-- GameConst.SKILL_TYPE_JiChuJianShu,
	-- GameConst.SKILL_TYPE_GongShaJianShu,
	-- GameConst.SKILL_TYPE_CiShaJianShu,
	-- GameConst.SKILL_TYPE_BanYueWanDao,
	GameConst.SKILL_TYPE_YeManChongZhuang,
	-- GameConst.SKILL_TYPE_LieHuoJianFa,
	-- GameConst.SKILL_TYPE_PoTianZhan,
	-- GameConst.SKILL_TYPE_ZhuRiJianFa,
	GameConst.SKILL_TYPE_HuoQiuShu,
	-- GameConst.SKILL_TYPE_KangJuHuoHuan,
	-- GameConst.SKILL_TYPE_YouHuoZhiGuang,
	GameConst.SKILL_TYPE_DiYuHuo,
	GameConst.SKILL_TYPE_LeiDianShu,
	-- GameConst.SKILL_TYPE_ShunJianYiDong,
	GameConst.SKILL_TYPE_DaHuoQiu,
	GameConst.SKILL_TYPE_BaoLieHuoYan,
	GameConst.SKILL_TYPE_HuoQiang,
	GameConst.SKILL_TYPE_JiGuangDianYing,
	GameConst.SKILL_TYPE_DiYuLeiGuang,
	-- GameConst.SKILL_TYPE_MoFaDun,
	-- GameConst.SKILL_TYPE_ShengYanShu,
	GameConst.SKILL_TYPE_BingPaoXiao,
	GameConst.SKILL_TYPE_HuoLongQiYan,
	GameConst.SKILL_TYPE_LiuXingHuoYu,

	-- GameConst.SKILL_TYPE_ZhiYuShu,
	-- GameConst.SKILL_TYPE_JinShenLiZhanFa,
	GameConst.SKILL_TYPE_ShiDuShu,
	GameConst.SKILL_TYPE_LingHunHuoFu,
	-- GameConst.SKILL_TYPE_ZhaoHuanKuLou,
	-- GameConst.SKILL_TYPE_YinShenShu,
	-- GameConst.SKILL_TYPE_JiTiYinShenShu,
	-- GameConst.SKILL_TYPE_YouLingDun,
	-- GameConst.SKILL_TYPE_ShenShengZhanJiaShu,
	-- GameConst.SKILL_TYPE_XinLingQiShi,
	-- GameConst.SKILL_TYPE_KunMoZhou,
	-- GameConst.SKILL_TYPE_QunTiZhiLiao,
	-- GameConst.SKILL_TYPE_ZhaoHuanShenShou,
	GameConst.SKILL_TYPE_QiGongBo,
	-- GameConst.SKILL_TYPE_ZhaoHuanYueLing,
};

local originRadius = 167
local touchRadius = 280

local var = {}
----------技能转盘代码
-- radian区间 -90 --- 270
local function convertRadian(position)
	local radian
	if position.x == 0 then
		if position.y == 0 then
			radian = 0
		elseif position.y > 0 then
			radian = 90
		else
			radian = -90
		end
	else
		radian = math.deg(math.atan(position.y / position.x))
		if position.y == 0 then
			if position.x > 0 then
				radian = 0
			else
				radian = 180
			end
		elseif position.y < 0 then
			if position.x < 0 then
				radian = radian + 180
			end
		else
			if position.x < 0 then
				radian = radian + 180
			end
		end
	end
	return radian
end

local function updateSkillPosition(radian)
	local skillBox, x, y, nowRadian
	local offset = 0
	for i = 1, 8 do
		skillBox = var.skillModel:getWidgetByName("box_skill"..i)
		nowRadian = skillBox.mRadian + radian
		if i == 1 then
			-- print("updateSkillPosition", radian, skillBox.mRadian)
			if nowRadian > 90 then
				offset = 90 - nowRadian
			elseif nowRadian < -30 then
				offset = -30 - nowRadian
			end
		end
		nowRadian = nowRadian + offset
		x = originRadius * math.cos(math.rad(nowRadian))
		y = originRadius * math.sin(math.rad(nowRadian))
		skillBox:setPosition(x, y)
	end
end

local function initSkillBoxRadian()
	local skillBox, mPos
	for i = 1, 8 do
		skillBox = var.skillModel:getWidgetByName("box_skill"..i)
		mPos = cc.p(skillBox:getPosition())
		skillBox.mRadian = convertRadian(mPos)
	end
end
-- 技能位置微调
local function relocateSkillBox()
	local skillBox1 = var.skillModel:getWidgetByName("box_skill1")
	local radian = convertRadian(cc.p(skillBox1:getPosition()))
	local a = radian % 30;
	local perRadian = 1
	if not (a == 0) then
		local aimRadian = (a < 15) and math.floor(radian / 30) * 30 or math.ceil(radian / 30) * 30
		if aimRadian < -30 then
			aimRadian = -30
		elseif aimRadian > 90 then
			aimRadian = 90
		end
		local dir = aimRadian > radian and 1 or -1
		local times = math.floor(math.abs(aimRadian - radian) / perRadian)
		local remain = math.abs(aimRadian - radian) % perRadian
		initSkillBoxRadian()
		local index = 1
		local action, seq1, seq2
		if times > 0 then
			seq1 = transition.sequence({
		        cca.delay(0.01),
		        cca.cb(function ()
		        	updateSkillPosition(dir * perRadian * index)
		        	index = index + 1
		        end),
		    })
			action = cca.rep(seq1, times)
		end
		if remain > 0 then
			seq2 = transition.sequence({
		        cca.delay(0.01),
		        cca.cb(function ()
		        	updateSkillPosition(aimRadian - radian)
		        end),
		    })
		end
		if action then
			if seq2 then
				action = transition.sequence({
					action,seq2
				})
			end
		else
			action = seq2
		end
		if action then
			var.boxSkills:runAction(action)
		end
	end
end

local function initSkillTouch()
   	local touchID, TBPos, originRadian, clockTime, radius--, canRotate
   	-- local  originRadius = 200
   	local scale = 1
	local function onTouchBegan(touch,event)
 		-- print("SkillTouch onTouchBegan")
 		local touchPos = touch:getLocation()
 		local tempPos = var.boxSkills:convertToNodeSpace(touchPos)
 		-- if tempPos.x > 0 and tempPos.y < 0 then return false end
		if cc.pDistanceSQ(tempPos, cc.p(0, 0)) > touchRadius * touchRadius then return false end

		if not (tempPos.x > 0 and tempPos.y < 0) and not touchID then
			-- canRotate = false
			touchID = touch:getId()
			TBPos = tempPos
			originRadian = convertRadian(TBPos)
			radius = math.sqrt(TBPos.x * TBPos.x + TBPos.y * TBPos.y)
			scale = radius / originRadius
			if scale > 1 then scale = 1 end
			clockTime = GameBaseLogic.getTime()
			initSkillBoxRadian()
			var.mSkillRotation = 0
			return true
		end
		if touchPos.y < touchRadius and touchPos.x > display.width - touchRadius then
			var.mSkillRotation = 0
			return true
		end
	end

	local function onTouchMoved(touch,event)
		if touch:getId() ~= touchID then return end
		if GameBaseLogic.getTime() - clockTime > 15 then
			clockTime = GameBaseLogic.getTime()
			local lbPos = var.boxSkills:convertToNodeSpace(touch:getLocation())
			if not (lbPos.x > 0 and lbPos.y < 0) then
				-- if canRotate then
					var.mSkillRotation = (convertRadian(lbPos) - originRadian) * scale
					updateSkillPosition(var.mSkillRotation)
				-- elseif cc.pDistanceSQ(lbPos, TBPos) > 5 * 5 then
				-- 	canRotate = true
				-- end
			end
		end
	end

	local function onTouchEnded(touch,event)
		-- print("onTouchEnded")
		if touch:getId() ~= touchID then return end
		touchID = nil
		relocateSkillBox()
	end

	local function onTouchCancelled(touch,event)
		-- print("onTouchCancelled")
		-- if touch:getId() ~= touchID then return end
		touchID = nil
		TBPos = nil
		relocateSkillBox()
	end

	local _touchListener = cc.EventListenerTouchOneByOne:create()
	_touchListener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	_touchListener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	_touchListener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	_touchListener:registerScriptHandler(onTouchCancelled, cc.Handler.EVENT_TOUCH_CANCELLED)

	_touchListener:setSwallowTouches(true)
	local eventDispatcher = var.boxSkills:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(_touchListener, var.boxSkills)

	initSkillBoxRadian()
	updateSkillPosition(0)
end
----------技能本身代码
local function getShortCutIdBySkillType(skill_type)
	local shortCut
	for i = GameConst.SHORT_BEGIN, GameConst.SHORT_SKILL_END do
		shortCut = GameSocket.mShortCut[i]
		if shortCut and shortCut.type == 2 and shortCut.param ~= 0 and skill_type == shortCut.param then
			return i
		end
	end
end

-- 获取未设置的技能位
local function getEmptyShortCutId()
	local shortCut
	for i = GameConst.SHORT_BEGIN, GameConst.SHORT_SKILL_END do
		shortCut = GameSocket.mShortCut[i]
		if not shortCut then
			return i
		end
	end
end

local function updateGridSkillState()
	local shortCut
	for i = GameConst.SHORT_BEGIN, GameConst.SHORT_SKILL_END do
		shortCut = GameSocket.mShortCut[i]
		if shortCut and shortCut.type == 2 and shortCut.param ~= 0 and GameCharacter.isSelectGridSkill(shortCut.param) then
			print("updateGridSkillState", GameSocket.mSelectGridSkill, shortCut.param)
			if not GameSocket.m_skillCD[shortCut.param] then
				var.boxSkill[i].mark:setVisible(false)
				var.boxSkill[i].mwidget:setTouchEnabled(false)
			end
			if GameSocket.mSelectGridSkill == shortCut.param then
				if GameSocket.m_netSkill[shortCut.param] then
					var.boxSkill[i].mark:setVisible(true)
					var.boxSkill[i].mark:setPercentage(100)
					var.boxSkill[i].mwidget:setTouchEnabled(false)
				end
			end
		end
	end
end


local function updateSkillState(skill_type)
	if GameBaseLogic.IsSwitchSkill(skill_type) then
		local index = getShortCutIdBySkillType(skill_type)
		-- print("updateSkillState", skill_type, index)
		if index then
			if skill_type == GameConst.SKILL_TYPE_BanYueWanDao then
				-- print("111111111111", GameSocket.m_bBanYueOn)
				var.boxSkill[index].mark:setVisible(not GameSocket.m_bBanYueOn)
				var.boxSkill[index].mark:setPercentage(100)
				var.boxSkill[index].mwidget:setTouchEnabled(false)
			elseif skill_type == GameConst.SKILL_TYPE_CiShaJianShu then
				-- print("2222222222222", GameSocket.m_bCiShaOn)
				var.boxSkill[index].mark:setVisible(not GameSocket.m_bCiShaOn)
				var.boxSkill[index].mark:setPercentage(100)
				var.boxSkill[index].mwidget:setTouchEnabled(false)
			end
		end
	end
end

local function onCDEnded(mark)
	var.boxSkill[mark.tag].mark:setVisible(false)
	var.boxSkill[mark.tag].mwidget:setTouchEnabled(false)
	var.boxSkill[mark.tag].button:setTouchEnabled(true):setSwallowTouches(false)
	if GameSocket.mShortCut[mark.tag] then
		local cdSkill = var.boxSkill[mark.tag].cdSkill
		
		if cdSkill then  GameSocket.m_skillCD[cdSkill] = nil end

		local skill_type = GameSocket.mShortCut[mark.tag].param

		if GameBaseLogic.IsSwitchSkill(skill_type) then
			updateSkillState(skill_type)
		end

		-- 重置烈火类技能
		if GameSocket.mLiehuoAction and GameSocket.mLiehuoType == skill_type then
			GameSocket.mLiehuoAction = false
			GameSocket.mLiehuoType = 0
		end
	end
end

local function showSkillCD(tag, cdtime, skill_type)
	-- print("showSkillCD", tag, cdtime)
	local shortCut = GameSocket.mShortCut[tag]
	if not (shortCut and shortCut.param) then return end
	if not GameSocket.m_netSkill[shortCut.param] then return end

	if not GameSocket.m_skillCD[shortCut.param] and not (shortCut.param == GameSocket.mSelectGridSkill) then
		GameSocket.m_skillCD[shortCut.param] = true
		var.boxSkill[tag].mark:setVisible(true)
		var.boxSkill[tag].button:setTouchEnabled(false)
		var.boxSkill[tag].cdSkill = shortCut.param
		var.boxSkill[tag].mark:stopActionByTag(5)
		local action = cc.Sequence:create(cc.ProgressFromTo:create(cdtime-1/60,100,0),cc.CallFunc:create(onCDEnded))
		action:setTag(5)
		var.boxSkill[tag].mark:runAction(action)
		var.boxSkill[tag].mwidget:setTouchEnabled(true):setSwallowTouches(false)

	elseif GameSocket.m_skillCD[shortCut.param] and skill_type == GameSocket.mLiehuoType and cdtime > 1.0 then
		GameSocket.m_skillCD[shortCut.param] = true
		var.boxSkill[tag].mark:stopActionByTag(5)
		local action = cc.Sequence:create(cc.ProgressFromTo:create(cdtime-1/60,100,0),cc.CallFunc:create(onCDEnded))
		action:setTag(5)
		var.boxSkill[tag].mark:runAction(action)
		var.boxSkill[tag].mwidget:setTouchEnabled(true):setSwallowTouches(false)
	end
end

local function handleSkillCD(event)
	if event and event.type then
		local mSkillCD, mPublicCD = GameBaseLogic.getSkillCDTime(event.type)
		-- print("handleSkillCD", event.type, mSkillCD, mPublicCD)
		if mSkillCD and mPublicCD then
			local shortCut, mSkillCD1, mPublicCD1
			for i = GameConst.SHORT_BEGIN, GameConst.SHORT_SKILL_END do
				shortCut = GameSocket.mShortCut[i]
				if shortCut and shortCut.type == 2 and shortCut.param ~= 0 and GameSocket.m_netSkill[shortCut.param] then
					-- print("111111", i, shortCut.param)
					if shortCut.param == event.type then -- 执行技能本身cd
						if not GameBaseLogic.IsSwitchSkill(shortCut.param) then -- 开关类技能的打开和关闭无cd
							showSkillCD(i, mSkillCD / 1000, event.type)
						end
					else
						 -- 执行技能公共cd组的其他技能cd
						mSkillCD1 = nil
						mPublicCD1 = nil
						if GameBaseLogic.IsSwitchSkill(shortCut.param) then -- 开关技能关闭状态不计算cd
							if (shortCut.param == GameConst.SKILL_TYPE_CiShaJianShu and GameSocket.m_bCiShaOn) or 
								(shortCut.param == GameConst.SKILL_TYPE_BanYueWanDao and GameSocket.m_bBanYueOn) then
								mSkillCD1, mPublicCD1 = GameBaseLogic.getSkillCDTime(shortCut.param)
							end
						else
							mSkillCD1, mPublicCD1 = GameBaseLogic.getSkillCDTime(shortCut.param)
						end
						if mSkillCD1 and mPublicCD1 and mPublicCD1 == mPublicCD then -- 公共cd的技能
							showSkillCD(i, mPublicCD1 / 1000, event.type)
						end
					end
				end
			end
		end
	end
end

local function startUseSkill(tag)
	local shortCut = GameSocket.mShortCut[tag]
	if shortCut and shortCut.param ~= 0 then
		GameCharacter.quickAttack(shortCut.param)
		-- GameCharacter.startCastSkill(shortCut.param)
	end
end

local function pushSkillButtons(pSender,touchType)
	-- if pSender.tag > 4 then return end
	local shortCut = GameSocket.mShortCut[pSender.tag]
	if not (shortCut and shortCut.param ~= 0 and GameSocket.m_netSkill[shortCut.param]) then 
		if touchType == ccui.TouchEventType.ended then
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_quickset"})
		end
		return
	end
	-- if not GameSocket.m_netSkill[shortCut.param] then return end
	-- print(GameSocket.m_skillCD[shortCut.param])
	if GameSocket.m_skillCD[shortCut.param] then print("skill is cding ") return end
	if touchType == ccui.TouchEventType.began then
		var.boxSkill[pSender.tag]:runAction(cc.ScaleTo:create(0.3,0.95))

	elseif touchType == ccui.TouchEventType.canceled then

		pSender:stopAllActions()
		var.boxSkill[pSender.tag]:runAction(
			cc.Sequence:create(
				cc.ScaleTo:create(0.2,1.05),
				cc.ScaleTo:create(0.2,1.0)
			)
		)

	elseif touchType == ccui.TouchEventType.ended then
		pSender:stopAllActions()
		var.boxSkill[pSender.tag]:runAction(
			cc.Sequence:create(
				cc.ScaleTo:create(0.2,1.05),
				cc.ScaleTo:create(0.2,1.0)
			)
		)

		if math.abs(var.mSkillRotation) <= 15 then
			var.boxSkill[pSender.tag].icon:stopAllActions()
			startUseSkill(pSender.tag)
		end
	end
end

local function updateSkillShortCut(event)
	local needUpdateSkill = nil
	if event and event.skill_type then
		needUpdateSkill = event.skill_type
	end

	local path, shortCut, skill_id, netSkill, pSize
	for i = GameConst.SHORT_BEGIN, GameConst.SHORT_SKILL_END do
		path = nil
		if not needUpdateSkill then path = "image/icon/null.png" end		
		shortCut = GameSocket.mShortCut[i]
		if shortCut and shortCut.param ~= 0 then
			skill_id = shortCut.param

			netSkill = GameSocket.m_netSkill[skill_id]
			if netSkill then
				if (not needUpdateSkill) or needUpdateSkill == netSkill.mTypeID then
					path = "image/icon/skill"..netSkill.mTypeID..".png"
					if GameSocket.mCastGridSkill == netSkill.mTypeID then
						path = "image/icon/skill"..netSkill.mTypeID.."_open.png"
					end
					if netSkill.mLevel > 10 then
						path = "image/icon/skill"..netSkill.mTypeID.."_angry.png"
					end
					updateSkillState(netSkill.mTypeID)
				end
			end
		end
		if path then
			asyncload_callback(path, var.boxSkill[i].icon, function(filepath, texture)
			end)
			var.boxSkill[i].icon:loadTexture(path)
			pSize = var.boxSkill[i].icon:getContentSize()
			var.boxSkill[i].mark:align(display.CENTER, pSize.width * 0.5, pSize.height * 0.5)
		end
	end
	-- GameBaseLogic.isNewSkill = false
end

local function initSkillButtons()
	local pSize
	for i=1,8 do
		var.boxSkill[i] = var.skillModel:getWidgetByName("box_skill"..i)
		var.boxSkill[i].tag = i
		var.boxSkill[i].button = var.boxSkill[i]:getWidgetByName("btn_skill"..i)
		var.boxSkill[i].button.tag = i
		var.boxSkill[i].button:setLocalZOrder(1)
		var.boxSkill[i]:getWidgetByName("Image_10"):setLocalZOrder(4)
		var.boxSkill[i].icon = var.boxSkill[i]:getWidgetByName("img_skill"..i)
		--	:align(display.CENTER, var.boxSkill[i]:getContentSize().width * 0.5-1, var.boxSkill[i]:getContentSize().height * 0.5-1)
			:scale(1):setLocalZOrder(3)--:setContentSize(cc.size(62,62))
		--var.boxSkill[i].icon:setPosition(var.boxSkill[i]:getContentSize().width * 0.5-8, var.boxSkill[i]:getContentSize().height * 0.5-9)
		if not pSize then
			pSize = var.boxSkill[i].icon:getContentSize()
		end

		var.boxSkill[i].mark = cc.ProgressTimer:create(cc.Sprite:create("image/icon/mark_circle.png"))
			:align(display.CENTER, pSize.width * 0.5, pSize.height * 0.5)
			:addTo(var.boxSkill[i].icon, 100)
			:setScale(1)
			:setReverseDirection(true)
		var.boxSkill[i].mark:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
		
		var.boxSkill[i].mark.tag = i
	
		asyncload_callback("image/icon/mark_circle.png", var.boxSkill[i].mark, function(filepath, texture)
			var.boxSkill[i].mark:setSprite(cc.Sprite:create("image/icon/mark_circle.png"))
		end)
		

		var.boxSkill[i].mwidget = ccui.Widget:create()
		var.boxSkill[i].mwidget:setContentSize(cc.size(80,80))
			:align(display.CENTER, pSize.width * 0.5, pSize.height * 0.5)
			:addTo(var.boxSkill[i].icon, 101)
		var.boxSkill[i].mwidget:setTouchEnabled(false)
		var.boxSkill[i].mwidget:setTag(i)
		var.boxSkill[i].mwidget:addClickEventListener(function (pSender,touchType)
			-- print("onTouchEnded")
			if pSender then
				local tag = pSender:getTag()
				if GameCharacter._autoFight and tag then
					local shortCut = GameSocket.mShortCut[tag]
					-- print(GameSocket.mCDWaitNextSKill,shortCut , shortCut.param)
					if shortCut and shortCut.param then
						GameSocket.mCDWaitNextSKill = shortCut.param
					end
				end
			end
		end)


		var.boxSkill[i].button:setPressedActionEnabled(false)
		var.boxSkill[i].button:setSwallowTouches(false)
		var.boxSkill[i].button:addTouchEventListener(pushSkillButtons)
	end
	updateSkillShortCut()
end

----------主攻按钮代码
local function initMainAttackButton()
	-- var.btnMainAttack:setScale(1.42)
	var.btnMainAttack:setTouchEnabled(true):setSwallowTouches(true)
	var.btnMainAttack:setZoomScale(0)
	local shortcutMain = var.skillModel:getWidgetByName("shortcut_main"):setLocalZOrder(2):scale(1.1)--:setContentSize(cc.size(92,92))

	asyncload_callback("image/icon/skill100.png", shortcutMain, function(filepath, texture)
		shortcutMain:loadTexture(filepath)
	end)

	--local shortcutMianHalo = var.skillModel:getWidgetByName("shortcut_main_halo"):hide()
	--local shortcutMianSel = var.skillModel:getWidgetByName("shortcut_main_sel"):hide()
	--local shortcutSemiarPlayer = var.skillModel:getWidgetByName("shortcut_semiar_player"):setScaleY(-1):hide()
	--local shortcutSemiarMonster = var.skillModel:getWidgetByName("shortcut_semiar_monster"):hide()

	local function cloneActionWidget(mWidget)
		local mClone = mWidget:clone()
		mClone:addTo(mWidget:getParent())
		mClone:setLocalZOrder(-1)
		return mClone
	end

	local TBPos, lockTarget

	local function changeAttackTarget(moveDis)
		local shortcutSemiar
		if moveDis > 30 then -- 向下
			GameSocket:alertLocalMsg("攻击怪物","alert")
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HANDLE_CHG_AVA, targetType = GameConst.GHOST_MONSTER})
			--shortcutSemiar = cloneActionWidget(shortcutSemiarMonster)
		elseif moveDis < -30 then -- 向上
			GameSocket:alertLocalMsg("攻击玩家","alert")
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HANDLE_CHG_AVA, targetType = GameConst.GHOST_PLAYER})
			--shortcutSemiar = cloneActionWidget(shortcutSemiarPlayer)
		end
		--if shortcutSemiar then
		--	shortcutSemiar:stopAllActions()
		--	shortcutSemiar:setOpacity(0)
		--	shortcutSemiar:runAction(cca.seq({
		--		cca.show(),
		--		cca.fadeIn(0.25),
		--		cca.fadeOut(0.25),
		--		cca.hide()
		--	}))
		--	return true
		--end
		return false
	end

	local function pushMainAttackButton( sender, touchType )
		if touchType == ccui.TouchEventType.began then
			TBPos = sender:getTouchBeganPosition()
			--shortcutMianSel:show()
		elseif touchType == ccui.TouchEventType.canceled then
			local TMPos = sender:getTouchMovePosition()
			changeAttackTarget(TBPos.y - TMPos.y)
			--shortcutMianSel:hide()
		elseif touchType == ccui.TouchEventType.ended then
			--shortcutMianSel:hide()
			local TEPos = sender:getTouchEndPosition()
			if not changeAttackTarget(TBPos.y - TEPos.y) then
				GameCharacter.quickAttack()
				--local mainHalo = cloneActionWidget(shortcutMianHalo)
				--mainHalo:stopAllActions()
				--mainHalo:setScale(0.9)
				--mainHalo:setOpacity(255)
				--mainHalo:runAction(cca.seq({
				--	cca.show(),
				--	cca.spawn({
				--		cca.scaleTo(0.5, 1.2),
				--		cca.fadeOut(0.5)
				--	}),
				--	cca.hide()
				--}))
			end--
		end
	end
	var.btnMainAttack:addTouchEventListener(pushMainAttackButton)
end


local function handleNewSkillMaster(event)
	print("/////////handleNewSkillMaster//////////////", event.skillId, GameUtilSenior.encode(event.position));
	-- local 
	local index = getShortCutIdBySkillType(event.skillId)
	local boxSkill
	if not index then
		local emptyId = getEmptyShortCutId()
		if emptyId then
			
			local shortCut = {}
			shortCut.cut_id = emptyId
			shortCut.type = 2
			shortCut.param = event.skillId
			shortCut.itemnum = 1
			GameSocket.mShortCut[shortCut.cut_id] = shortCut
			GameSocket:SaveShortcut(true)
			boxSkill = var.boxSkill[emptyId]
		end
	else
		boxSkill = var.boxSkill[index]
	end

	if boxSkill then
	
		asyncload_callback("image/icon/skill"..event.skillId..".png", var.skillModel, function(filepath, texture)
		end)
		local startPos = var.skillModel:convertToNodeSpace(event.position)
		local flyIcon = ccui.ImageView:create("image/icon/skill"..event.skillId..".png", ccui.TextureResType.localType)
			:align(display.CENTER, startPos.x, startPos.y)
			:addTo(var.skillModel)
			:scale(52/72)
		local tempPos = GameUtilSenior.getWidgetCenterPos(boxSkill.icon)
		local endPos = var.skillModel:convertToNodeSpace(tempPos)
		flyIcon:runAction(cca.seq({
			cca.moveTo(1, endPos.x, endPos.y),
			cca.cb(function ()
				updateSkillShortCut()
			end),
			cca.removeSelf()
		}))
	end
end

local function onSkillLevelUp(event)
	if not event.skill_type then return end
	local skillType = event.skill_type
	local shortCut
	for i = GameConst.SHORT_BEGIN, GameConst.SHORT_SKILL_END do
		shortCut = GameSocket.mShortCut[i]
		if shortCut and shortCut.type == 2 and shortCut.param ~= 0 and event.skill_type == shortCut.param then
			-- print("updateGridSkillState", GameSocket.mSelectGridSkill, shortCut.param)
			local netSkill = GameSocket.m_netSkill[shortCut.param]
			local nsd = GameBaseLogic.getSkillDesp(shortCut.param)

			if netSkill and nsd then
				local icon = nsd.skill_id
				if netSkill.mLevel > 10 then
					icon = icon.."_angry"
				end
				
				asyncload_callback("image/icon/skill"..icon..".png", var.boxSkill[i].icon, function(filepath, texture)
				end)
				var.boxSkill[i].icon:loadTexture("image/icon/skill"..icon..".png")
			end
			break
		end
	end
end

function GUISkill.init(skillModel)
	var = {
		skillModel,
		boxSkills,
		btnMainAttack,
		boxSkill = {},
		mShortCut = {},

		mSkillRotation = 0, --每次转动技能转盘的角度
	}
	var.skillModel = skillModel

	if var.skillModel then
		var.boxSkills = var.skillModel:getWidgetByName("box_skills")
		var.btnMainAttack = var.skillModel:getWidgetByName("btn_main_attack")--:setContentSize(cc.size(95,95))

		var.skillModel:getWidgetByName("img_skill_scroll_arrow"):setRotation(-20.73):setScale(0.8)
		var.skillModel:getWidgetByName("img_skill_scroll_arrow_0"):setRotation(289.33):setScale(-0.8,0.8)

		initSkillTouch()
		initSkillButtons()
		initMainAttackButton()

		-- 初始化开关类技能状态
		updateSkillState(GameConst.SKILL_TYPE_BanYueWanDao)
		updateSkillState(GameConst.SKILL_TYPE_CiShaJianShu)

		cc.EventProxy.new(GameSocket, skillModel)
			:addEventListener(GameMessageCode.EVENT_SKILL_COOLDOWN, handleSkillCD)
			:addEventListener(GameMessageCode.EVENT_SET_SHORTCUT, updateSkillShortCut)
			:addEventListener(GameMessageCode.EVENT_GRID_SKILL_STATE, updateGridSkillState)
			:addEventListener(GameMessageCode.EVENT_GROUND_SKILL_STATE, updateSkillShortCut)
			:addEventListener(GameMessageCode.EVENT_FLY_NEW_SKILL, handleNewSkillMaster)
			:addEventListener(GameMessageCode.EVENT_SKILL_STATE, function (event)
				-- print("----------------------------------")
				if not GameSocket.m_skillCD[event.skill_type] then
					updateSkillState(event.skill_type)
				end
			end)
			:addEventListener(GameMessageCode.EVENT_SKILL_LEVEL_UP, onSkillLevelUp)
	end
end

return GUISkill