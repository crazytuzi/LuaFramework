local GUIMain={}

local var = {}

--传进来的pos应该是大地图上某个点的坐标(如果是摇杆则需要映射换算)

local stateImg = {
	[100] = "all",
	[101] = "peace",
	[102] = "team",
	[103] = "guild",
	[104] = "shane",
	[105] = "camp"
}

function GUIMain.initVar()
	var = {
		-- mainrole,
		destlayer,
		alivelayer,

		tick = 0,
		scene,
		-- mainrolePos,
		-- standStillTime = 0, --静止不动计时
		---------UI相关变量---------
		uiPlayer,
		playerBOSSBox,
		smallMonsterBox,
		playerHeadBox,--玩家头像

		bossHeadBox, --怪物头像

		xmlOperate=nil,
		-- uiListPlayers,

		hpBarPlayer,
		hpBarBottom,
		hpBarMonster,
		hpBarSmallMonster,
		hpLblPlayer,
		hpLblMonster,
		hpLblSmallMonster,

		hpBg,
		ghostType,
		closePlayer,
		closeMonster,

		showTargetID=0,
		selectTab={},

		nearbyGhosts = {},

		mAutoSelectedGhosts = {},

		attackTargetType,

		autoActionWidget,
		directFlyWidget,
		autoActionSprite,
		taskActionWidget,
		taskActionSprite,
		curAcitonId,
		upMountState=false,

		mFightAtlasRed,
		mFightAtlasGreen,
		hide_layer,

		mode_btn,
		-- attackModel,
		lastIndex,
		clickAnim={},
		isRunningAction=false,

		touchMap = false,
		hideState,
		ticklast=0,
		ticknum=0,
		ticktime=0,
		ticklow=0,
		tickhigh=0,

		fly_x,
		fly_y,

		lastAttackTime = 0,

		imgTaskTips = nil,
	}

	GUIMain.m_ltPartUI=nil
	GUIMain.m_rtPartUI=nil
	GUIMain.m_rbPartUI=nil
	GUIMain.m_lcPartUI=nil
	GUIMain.m_cbPartUI=nil
	GUIMain.m_rcPartUI=nil
	GUIMain.m_lbPartUI=nil
	GUIMain.InfoPart=nil

end

GUIMain.initVar();

function GUIMain.findingTouchStart(pos)
	if GameSocket.mJinGuFlag then
		return
	end
	if GameCharacter._mainAvatar and var.destlayer and not GameSocket.mMabiFlag and not GameSocket.mBingdongFlag then
		GameSocket.actionMoving = true
		GameCharacter._mainAvatar:findingTouchStart(var.destlayer:convertToNodeSpace(pos))
	end
end
function GUIMain.findingTouchMove(pos)
	if GameSocket.mJinGuFlag then
		return
	end
	if GameCharacter._mainAvatar and var.destlayer and not GameSocket.mMabiFlag and not GameSocket.mBingdongFlag then
		GameCharacter._targetNPCName = ""
		GameSocket.actionMoving = true
		GameCharacter.stopAutoDart()
		GameCharacter.stopAutoFight()
		GameCharacter._mainAvatar:findingTouchMove(var.destlayer:convertToNodeSpace(pos))

		-- if var.mainrole:NetAttr(GameConst.net_level) < 50 then GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_GUIDE, lv = 2 }) end -- 引导点击左侧任务栏
	end
end
function GUIMain.findingTouchEnd(pos)
	if GameSocket.mJinGuFlag then
		return
	end
	if GameCharacter._mainAvatar and var.destlayer and not GameSocket.mMabiFlag and not GameSocket.mBingdongFlag then
		GameCharacter._moveToNearAttack = false
		GameCharacter.stopAutoFight() --取消自动挂机
		GameSocket.actionMoving = false
		-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HANDLE_FLOATING , btn = "main_auto" , visible = false})
		GameCharacter._mainAvatar:findingTouchEnd(var.destlayer:convertToNodeSpace(pos))
	end
end

function GUIMain.setMainUIVisible(visible)

	local uiTable = {"m_ltPartUI","m_lcPartUI","m_lbPartUI","m_rtPartUI","m_rcPartUI","m_rbPartUI","m_layerRocker"}--,"m_rcPartUI"
	for _,v in ipairs(uiTable) do
		GUIMain[v]:setVisible(visible)
	end
	-- var.attackModel:setVisible(visible)
end

function GUIMain.handleShowPlot(event)
	if event then
		GUIMain.setMainUIVisible(not event.show)
	end
end

function GUIMain.handleMainUIVisible(event)
	if event then
		GUIMain.setMainUIVisible(event.visible)
	end
end

-- local tableIgnore = {"邪恶领地[副本]","白猪巢穴[副本]","玛法阁[副本]","蛛王谷[副本]","蛮荒祭坛[副本]","皇陵墓室[副本]","船舱底层[副本]","元神塔"}

-- function GUIMain.handleOneKeyHide(event)

-- 	if var.hideState~=nil and var.hideState==event.visible then return end

-- 	var.hideState = event.visible

-- 	local hideTable = {
-- 		[1]={parent=GUIMain.m_ltPartUI, needLev=0, targetName="btn_vip11",},
-- 		[2]={parent=GUIMain.m_lcPartUI, needLev=0, targetName="box_maintask"},
-- 		[3]={parent=GUIMain.m_rcPartUI, needLev=32, targetName="main_boss"},
-- 		[4]={parent=GUIMain.m_ltPartUI, needLev=0, targetName="previewIcon"},
-- 		[5]={parent=GUIMain.m_lcPartUI, needLev=0, targetName="btn_maintask",reverse=true},
-- 	}
-- 	local level = GameBaseLogic.GetMainRole():NetAttr(GameConst.net_level)
-- 	for i=1,#hideTable do
-- 		local obj = nil
-- 		if hideTable[i].parent and level>=hideTable[i].needLev then
-- 			obj = hideTable[i].parent:getWidgetByName(hideTable[i].targetName)
-- 		end
-- 		if obj then
-- 			if hideTable[i].targetName == "btn_vip" then			------------
-- 				obj:setVisible(false)
-- 			else
-- 				if not (table.indexof(tableIgnore,GameSocket.mNetMap.mName) and (i==5 or i==2)) then
-- 					local x = obj:getPositionX()
-- 					local y = obj:getPositionY()
-- 					local w = obj:getContentSize().width
-- 					local pos
-- 					local visible = event.visible
-- 					if hideTable[i].reverse then 
-- 						visible = not visible
-- 					end
-- 					if visible then
-- 						pos=1
-- 					else
-- 						pos=0
-- 					end
-- 					if obj:isVisible() ~= visible then
-- 						obj:setVisible(true):setCascadeOpacityEnabled(true)
-- 						obj:stopAllActions()

-- 						if i == 2 then
-- 							if pos == 0 then
-- 								obj:runAction(cca.seq({
-- 									cca.scaleTo(0.3,0,1),
-- 									cca.cb(function ()
-- 										obj:setVisible(visible)
-- 									end)
-- 								})
-- 								)
-- 							else	
-- 								obj:runAction(
-- 									cca.scaleTo(0.3,1,1)
-- 								)
-- 								obj:setVisible(visible)
-- 							end	
-- 						else	
-- 							obj:runAction(cca.seq({
-- 								cca.spawn({
-- 										cca.sineOut(cca.fadeTo(0.3,pos)),
-- 									}),
-- 									cca.cb(function ()
-- 										obj:setVisible(visible)
-- 									end)
-- 								})
-- 							)
-- 						end	
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- end

local function freshHP()
	if not var.showTargetID or var.showTargetID <= 0 then
		GUIMain.hideUIPlayer() 
		return 
	end
	local ghost = NetCC:getGhostByID(var.showTargetID)
	if ghost then

		-- print(math.floor(GameBaseLogic.getTime()/100),ava:NetAttr(GameConst.net_attacked_time))
		if ghost:NetAttr(GameConst.net_attacked_time) then
			if GameBaseLogic.getSkipTime() >= ghost:NetAttr(GameConst.net_attacked_time) or var.lastAttackTime~=ghost:NetAttr(GameConst.net_attacked_time) then
				var.lastAttackTime = ghost:NetAttr(GameConst.net_attacked_time)

				local hp = ghost:NetAttr(GameConst.net_hp)
				local maxHp = ghost:NetAttr(GameConst.net_maxhp)
				-- var.hpLblPlayer:setString(hp.."/"..maxHp)
				-- var.hpLblMonster:setString(hp.."/"..maxHp)
				-- var.hpLblSmallMonster:setString(hp.."/"..maxHp)
				local ghostType = ghost:NetAttr(GameConst.net_type)
				if ghostType == GameConst.GHOST_MONSTER and var.bossHeadBox:isVisible() then
					var.bossHeadBox:getWidgetByName("img_boss_hp"):setPercent(hp,maxHp):setFontSize(14):enableOutline(GameBaseLogic.getColor(0x490000),1)
				elseif ghostType == GameConst.GHOST_PLAYER or ghostType == GameConst.GHOST_THIS then
					local mp = ghost:NetAttr(GameConst.net_mp) or 1
					local maxMp = ghost:NetAttr(GameConst.net_maxmp) or 1
					var.uiPlayer:getWidgetByName("pos_hp"):setPercent(hp,maxHp):setFontSize( 14 ):enableOutline(GameBaseLogic.getColor(0x490000),1)
					var.uiPlayer:getWidgetByName("pos_mp"):setPercent(mp,maxMp):setFontSize( 14 ):enableOutline(GameBaseLogic.getColor(0x000049),1)
				end	
				if ghost:NetAttr(GameConst.net_dead) then --死的时候手动清空指向ghost的id
					GUIMain.hideUIPlayer()
					return
				end
			end
		end
	end
end


local function freshfight()
	local ghost = NetCC:getGhostByID(var.showTargetID)
	if ghost then
		local fight = ghost:NetAttr(GameConst.net_fight_point)
		if var.hide_layer and var.mFightAtlas then
			local award = "geen"
			if fight > GameSocket.mCharacter.mFightPoint then
				var.mFightAtlasRed:show():setString(fight)
				var.mFightAtlasGreen:hide()
				award = "red"
			else
				var.mFightAtlasGreen:show():setString(fight)
				var.mFightAtlasRed:hide()
				award = "green"
			end
			var.uiPlayer:getWidgetByName("imgATK"):loadTexture("img_ATK_"..award, ccui.TextureResType.plistType)
		end
	end
end

local function updateMonsterOwner(event)
	if GameUtilSenior.isObjectExist(var.bossHeadBox) then
		if var.bossHeadBox:isVisible() then
			if event and event.srcid ~= var.bossHeadBox.monsterID then return end
			local owner = GameSocket:getMonsterOwner(var.bossHeadBox.monsterID)
			if owner and owner.name then
				var.bossHeadBox:getWidgetByName("lbl_boss_owner"):setString("归属："..owner.name):show()
			else
				var.bossHeadBox:getWidgetByName("lbl_boss_owner"):setString(""):hide()
			end
		end
	end
end

function GUIMain.hideUIPlayer()
	-- if GameUtilSenior.isObjectExist(var.box_operate) and GameUtilSenior.isObjectExist(var.uiPlayer) then	
		var.showTargetID = 0
	-- 	var.box_operate:hide()
		if var.uiPlayer and var.uiPlayer:isVisible() then
			var.uiPlayer:hide()
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_EXTEND_VISIBLE, visible = true})
		end
		if var.xmlOperate then var.xmlOperate:hide() end
	-- end
end

--设置BOSS头像里的掉落显示
local function setBossDropShow(data)
	for i=1,6 do
		local dropItem=var.bossHeadBox:getWidgetByName("drop"..i)
		if data["drop"..i] and tonumber(data["drop"..i])>0 then
			local param={parent=dropItem, typeId=tonumber(data["drop"..i]), num=1}
			GUIItem.getItem(param)
			dropItem:setVisible(true)
		else
			dropItem:setVisible(false)
		end
	end
end

function GUIMain.showUIPlayer(avaID)
	local map=NetCC:getMap()
	if map and map:getSwitch(GameConst.map_fightstate)==true then return end
	local avatar = CCGhostManager:getPixesGhostByID(avaID)
	if avatar and GameUtilSenior.isObjectExist(var.uiPlayer) then
		var.uiPlayer:show()
		var.bossHeadBox:hide()
		var.playerHeadBox:hide()

		local targetName = avatar:NetAttr(GameConst.net_name)
		local targetLevel =avatar:NetAttr(GameConst.net_level)
		local targetJob= avatar:NetAttr(GameConst.net_job)
		local targetGender= avatar:NetAttr(GameConst.net_gender)
		local guild= avatar:NetAttr(GameConst.net_guild_name)
		-- if var.ghostType == GameConst.GHOST_MONSTER then targetName = GameBaseLogic.clearNumStr(targetName) end
		var.showTargetID=avaID
		local hp = avatar:NetAttr(GameConst.net_hp)
		local maxHp = avatar:NetAttr(GameConst.net_maxhp)
		if var.ghostType == GameConst.GHOST_PLAYER or var.ghostType == GameConst.GHOST_THIS then
			local mp = avatar:NetAttr(GameConst.net_mp) or 1
			local maxMp = avatar:NetAttr(GameConst.net_maxmp) or 1
			-- print(hp,maxHp,mp,maxMp,targetName,targetJob,"==========111111111111111111")
			var.playerHeadBox:show()
			var.uiPlayer:getWidgetByName("img_target_icon_Player"):loadTexture("btn_skill_small2", ccui.TextureResType.plistType)
			--var.uiPlayer:getWidgetByName("img_target_icon_Player"):loadTexture(GameBaseLogic.getHeadRes(avatar:NetAttr(GameConst.net_job), avatar:NetAttr(GameConst.net_gender)), ccui.TextureResType.plistType)
			var.uiPlayer:getWidgetByName("pos_hp"):setPercent(hp,maxHp):setFontSize( 14 ):enableOutline(GameBaseLogic.getColor(0x490000),1)
			var.uiPlayer:getWidgetByName("pos_mp"):setPercent(mp,maxMp):setFontSize( 14 ):enableOutline(GameBaseLogic.getColor(0x000049),1)
			var.uiPlayer:getWidgetByName("labPlayerName"):setString(targetName)
			var.uiPlayer:getWidgetByName("labPlayerLevel"):setString(targetLevel)
			local data = {
				offx=150,
				offy=-150,
				showBg="hide",
				name=targetName,
				level=targetLevel,
				job=targetJob,
				gender = targetGender,
				guild= guild or "暂无帮会",
			}
			var.uiPlayer:getWidgetByName("img_target_icon_Player"):setTouchEnabled(true):addClickEventListener(function(sender)
				if not (avaID == GameCharacter.mID) then
					if not var.xmlOperate then
						-- var.xmlOperate= GUIFloatTips.showOperateTips(var.xmlOperate,var.uiPlayer,data)
						GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS,str="friendOperate", data = data})
					else
						if var.xmlOperate:isVisible() then
							var.xmlOperate:hide()
						else
							var.xmlOperate:show()
						end
					end
				end
			end)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_EXTEND_VISIBLE, visible = false})
		end
		-- print("GUIMain.showUIPlayer", avaID , var.ghostType, GameConst.GHOST_PLAYER, GameConst.GHOST_THIS, GameConst.GHOST_MONSTER, avatar:NetAttr(GameConst.net_isboss))

		--if var.ghostType == GameConst.GHOST_MONSTER and avatar:NetAttr(GameConst.net_isboss) == 1 then
		if var.ghostType == GameConst.GHOST_MONSTER then
			--print(hp,maxHp,"==========111111111111111111")
			var.bossHeadBox:show()
			var.bossHeadBox:getWidgetByName("lbl_boss_owner"):hide()

			var.bossHeadBox.monsterID = avatar:NetAttr(GameConst.net_id)
			updateMonsterOwner()

			var.bossHeadBox:getWidgetByName("img_boss_head"):loadTexture("btn_skill_small2", ccui.TextureResType.plistType)
			--var.bossHeadBox:getWidgetByName("img_boss_head"):loadTexture("image/icon/"..avatar:NetAttr(GameConst.net_cloth)..".png")

			var.bossHeadBox:getWidgetByName("img_boss_hp"):setPercent(hp,maxHp):setFontSize(14):enableOutline(GameBaseLogic.getColor(0x490000),1)

			var.bossHeadBox:getWidgetByName("lbl_boss_name"):setString(targetName)
			var.bossHeadBox:getWidgetByName("lbl_boss_level"):setString(targetLevel)

			GameSocket:PushLuaTable("gui.PanelBoss.onPanelData",GameUtilSenior.encode({actionid = "reqDropItems",params = {monid=avaID}}))

			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_EXTEND_VISIBLE, visible = false})
		end
	end
end

local function checkSelectAlive(srcid)
	if not srcid then return false end
	if GameCharacter.isMySlave(srcid) then return false end
	local ghost = NetCC:getGhostByID(srcid)
	if ghost then
		local gtype = ghost:NetAttr(GameConst.net_type)
		if gtype==GameConst.GHOST_MONSTER and ghost:NetAttr(GameConst.net_collecttime) and ghost:NetAttr(GameConst.net_collecttime)>0 then
		-- print(gtype,ghost:NetAttr(GameConst.net_collecttime))
			return true
		end
		if (gtype==GameConst.GHOST_PLAYER or gtype==GameConst.GHOST_MONSTER) and ghost:NetAttr(GameConst.net_dead) then
			return false
		end
		return true
	end
end

function GUIMain.handleGhostsTouched(point)
	
	local map=NetCC:getMap()
	if not map or not map:Attached() then
		return false
	end
	
	-- local function pushBtnAvatar(sender)
	-- 	-- if touchType == ccui.TouchEventType.ended then
	-- 	-- var.uiListPlayers:getWidgetByName("listPlayersBg"):setVisible(false)
	-- 	CCGhostManager:selectSomeOne(sender.avaID)
	-- 	-- end
	-- end
	local monsterID = CCGhostManager:isTouchGhost(point,GameConst.GHOST_MONSTER)
	local playerID = CCGhostManager:isTouchGhost(point,GameConst.GHOST_PLAYER)
	local itemIDs = CCGhostManager:isTouchGhosts(point,GameConst.GHOST_ITEM)
	-- print("GUIMain.handleGhostsTouched and touchID:",monsterID,playerID,itemIDs)
	if monsterID > 0 or playerID > 0 or #itemIDs>0 then
		if (GameCharacter.getAimGhostID() == monsterID and monsterID > 0) or (GameCharacter.getAimGhostID() == playerID and playerID > 0) then
			-- var.uiPlayer:show()
			if (not GameSocket.mSelectGridSkill) and (not GameSocket.mCastGridSkill) and GameCharacter._mainAvatar then
				local mAimGhost = GameCharacter.getAimGhost(GameCharacter.getAimGhostID())
				if mAimGhost then
					if mAimGhost.mType == GameConst.GHOST_MONSTER and mAimGhost.mCollectTime and mAimGhost.mCollectTime > 0 then
						-- if mAimGhost.mHp > 0 and not GameSocket.m_bCollecting then--进度条结束后m_bCollecting应该设为false
							GameCharacter._moveToNearAttack = true
						-- end
					else
						GameCharacter.startCastSkill(GameCharacter.checkDefaultSkillAttack())
					end
				end
			end
		elseif #itemIDs > 0 then
			GUIMain.startAutoMoveToPos(point)
			local mAimGhost = GameCharacter.getAimGhost(itemIDs[1])
			-- mAimGhost也有可能为npc(像素点击判断返回)
			if mAimGhost and mAimGhost:NetAttr(GameConst.net_type) == GameConst.GHOST_ITEM then
				GameCharacter._moveEndAutoPick = true
			end
			CCGhostManager:selectSomeOne(itemIDs[1])
			return true
		else
			local tid = (monsterID > 0) and monsterID or playerID
			if checkSelectAlive(tid) then
				CCGhostManager:selectSomeOne(tid)
			end
		end
		return true
	end
	
	local ghostID = CCGhostManager:isTouchGhosts(point)
	if #ghostID == 1 then
		if checkSelectAlive(ghostID[1]) then
			CCGhostManager:selectSomeOne(ghostID[1])
		end
		return true 
	elseif #ghostID > 1 then

		for i=1,#ghostID do
			if checkSelectAlive(ghostID[i]) then
				return true
			end
		end

		-- if checkSelectAlive(ghostID[1]) then
		-- 	CCGhostManager:selectSomeOne(ghostID[1])
		-- else
		-- 	CCGhostManager:selectSomeOne(ghostID[2])
		-- end
		-- GUIMain.hideUIPlayer()
		-- local listPlayers = var.uiListPlayers:getWidgetByName("listPlayers")
		-- listPlayers:removeAllChildren()
		-- var.uiListPlayers:getWidgetByName("listPlayersBg"):setVisible(true)
		-- for i,v in ipairs(ghostID) do
		-- 	local avatar = CCGhostManager:getPixesGhostByID(v)
		-- 	local BtnAvatar = ccui.Button:create()
		-- 	BtnAvatar:setTitleText(avatar:NetAttr(GameConst.net_name))
		-- 	BtnAvatar:loadTextures("btn_tab_01_sel.png","","",ccui.TextureResType.localType)
		-- 	BtnAvatar.avaID = v
		-- 	GUIFocusPoint.addUIPoint(BtnAvatar, pushBtnAvatar)
		-- 	listPlayers:pushBackCustomItem(BtnAvatar)
		-- end
		-- return true
	end
end

function GUIMain.handleGridSkillTouched(point)
	-- print("/////////////////handleGridSkillTouched/////////////////////", GameSocket.mSelectGridSkill);
	local pos, logicPos
	if GameSocket.mCastGridSkill then
		pos = var.destlayer:convertToNodeSpace(point)
		logicPos = NetCC:pixesPosToLogicPos(pos.x, pos.y)
		GameCharacter.pushGridSkillWait(GameSocket.mCastGridSkill, logicPos.x, logicPos.y)
	elseif GameSocket.mSelectGridSkill then
		pos = var.destlayer:convertToNodeSpace(point)
		logicPos = NetCC:pixesPosToLogicPos(pos.x, pos.y)
		local skill_type = GameSocket.mSelectGridSkill
		GameSocket.mSelectGridSkill = nil

		GameCharacter.pushGridSkillWait(skill_type, logicPos.x, logicPos.y)
		-- GameSocket:UseSkill(skill_type, logicPos.x, logicPos.y, 0)
	end
end

function GUIMain.startAutoMoveToPos(point)
	local pos = var.destlayer:convertToNodeSpace(point)
	local logicPos = NetCC:pixesPosToLogicPos(pos.x,pos.y)
	if GameCharacter._mainAvatar then
		GameCharacter._moveToNearAttack = false
		GameCharacter.stopAutoFight() --取消自动挂机

		-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HANDLE_FLOATING , btn = "main_auto" , visible = false})
		-- GameCharacter.stopAttackOfSoldier()
		GameCharacter._mainAvatar:startAutoMoveToPos(logicPos.x,logicPos.y)
	end
end

function GUIMain.handleMapTouched(event)
	if GameSocket.mJinGuFlag then
		return
	end
	if event and event.pos and not GameSocket.mMabiFlag and not GameSocket.mBingdongFlag then
		var.touchMap = true
		-- if GameSocket.mSelectGridSkill then
		-- 	local pos = var.destlayer:convertToNodeSpace(event.pos)
		-- 	local logicPos = NetCC:pixesPosToLogicPos(pos.x,pos.y)
		-- 	GameSocket:UseSkill(GameConst.SKILL_TYPE_HuoQiang,logicPos.x,logicPos.y,0)
		-- 	GameSocket.mSelectGridSkill = false
		-- 	return
		-- end
		GameCharacter.stopAutoDart()
		GameCharacter._targetNPCName = ""
		GUIMain.startAutoMoveToPos(event.pos)
		local pos = var.destlayer:convertToNodeSpace(event.pos)
		if #var.clickAnim < 3 then
			GUIMain.addClickAnim(pos)
		else
			if var.clickAnim[1] then
				var.clickAnim[1]:removeFromParent()
				table.remove(var.clickAnim,1)
				GUIMain.addClickAnim(pos)
			end
		end
	end
end

function GUIMain.addClickAnim(pos)
	local frames = display.newFrames("click_%02d", 1, 6)
	local animation = display.newAnimation(frames, 1 / 12) -- 1 秒播放 9 桢
	local anim = cc.Sprite:create()
		:align(display.CENTER, pos.x, pos.y+10)
		:addTo(var.destlayer)
		:setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
	anim:playAnimationForever(animation)
	anim:runAction(
		cca.seq({
			cca.delay(0.5),
			cc.RemoveSelf:create(),
			cca.cb(function ()
				table.remove(var.clickAnim,1)
			end),
		})
	)
	table.insert(var.clickAnim,anim)
end

--切怪物优先级比较更简单
local function sortMon(monA, monB)
	if GameCharacter._mainAvatar and monA and monB then
		local disA = cc.pDistanceSQ(cc.p(GameCharacter.mX,GameCharacter.mY),cc.p(monA.mX,monA.mY))
		local disB = cc.pDistanceSQ(cc.p(GameCharacter.mX,GameCharacter.mY),cc.p(monB.mX,monB.mY))
		local isBossA = monA:NetAttr(GameConst.net_isboss)
		isBossA = type(isBossA) == "boolean" and 0 or isBossA
		local isBossB = monB:NetAttr(GameConst.net_isboss)
		isBossB = type(isBossB) == "boolean" and 0 or isBossB

		-- 优先判定归属
		if isBossA == isBossB then
			if isBossA == 1 then -- 同为Boss,优先少血,同少血则优先距离
				if monA.mHp == monB.mHp then
					return (disA > 0 and disA < disB)
				else
					return monA.mHp < monB.mHp
				end
			else --同为小怪, 优先距离,同距离则优先少血
				if disA == disB then
					return monA.mHp < monB.mHp
				else
					return (disA > 0 and disA < disB)
				end
			end
		else
			return isBossA == 1
		end
	end
end

local function sortPlayer(playerA, playerB)
	if GameCharacter._mainAvatar and playerA and playerB then
		local disA = cc.pDistanceSQ(cc.p(GameCharacter.mX,GameCharacter.mY),cc.p(playerA.mX,playerA.mY))
		local disB = cc.pDistanceSQ(cc.p(GameCharacter.mX,GameCharacter.mY),cc.p(playerB.mX,playerB.mY))
		if disA == disB then
			return playerA.mHp < playerB.mHp
		else
			return (disA > 0 and disA < disB)
		end
	end
end

-- local stateImg = {
-- 	[100] = "all",
-- 	[101] = "peace",
-- 	[102] = "team",
-- 	[103] = "guild",
-- 	[104] = "shane",
-- 	[105] = "camp"
-- }
--实时获取周围备选目标
local function getAimGhosts(ghostType, attackModel)
	local ghosts = {}
	if not GameCharacter._mainAvatar then return ghosts end
	local netGhosts = NetCC:getNearGhost(ghostType)
	local tempGhost
	GameCharacter.updateAttr()

	local myGuild = GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name)
	local myTeam = GameCharacter._mainAvatar:NetAttr(GameConst.net_teamid)

	for _,v in ipairs(netGhosts) do
		tempGhost = GameCharacter.getAimGhost(v)
		if tempGhost and cc.pDistanceSQ(cc.p(GameCharacter.mX, GameCharacter.mY),cc.p(tempGhost.mX,tempGhost.mY)) < 36 then
			if ghostType == GameConst.GHOST_MONSTER then
				table.insert(ghosts, tempGhost)
			elseif ghostType == GameConst.GHOST_PLAYER then
				if attackModel == 102 then --组队
					if not GameSocket:isGroupMember(tempGhost:NetAttr(GameConst.net_name)) then
						table.insert(ghosts, tempGhost)
					end
				elseif attackModel == 103 then -- 帮会
					if tempGhost:NetAttr(GameConst.net_guild_name) ~= myGuild then
						table.insert(ghosts, tempGhost)
					end
				elseif attackModel == 105 then -- 阵营
					if tempGhost:NetAttr(GameConst.net_teamid) ~= myTeam then
						table.insert(ghosts, tempGhost)
					end
				else --全体或者和平
					table.insert(ghosts, tempGhost)
				end
			end
		end
	end

	if ghostType == GameConst.GHOST_MONSTER then
		table.sort(ghosts, sortMon)
	elseif ghostType == GameConst.GHOST_PLAYER then
		table.sort(ghosts, sortPlayer)
	end
	return ghosts
end

function GUIMain.handleAutoChangeAim(event)
	GUIMain.hideUIPlayer()
	CCGhostManager:selectSomeOne(0)

	local curState = GameSocket.mAttackMode -- 99
	-- local curStateImg = stateImg[curState]
	local tempType = event.targetType or GameConst.GHOST_MONSTER

	-- 地上的攻击圈
	local filepath = (tempType == GameConst.GHOST_PLAYER) and "ui/image/skill_range_player.png" or "ui/image/skill_range_monster.png"
	--print(TILE_WIDTH, TILE_HEIGHT)
	local logicX = GameCharacter._mainAvatar:NetAttr(GameConst.net_x)
	local logicY = GameCharacter._mainAvatar:NetAttr(GameConst.net_y)
	local pos =  NetCC:logicPosToPixesPos(logicX, logicY)

	if GameCharacter._mainAvatar then
		local mainSprite = GameCharacter._mainAvatar:getSprite()
		local imgAttackRange = ccui.ImageView:create()
			-- :align(display.CENTER, pos.x + TILE_WIDTH * 0.5, pos.y - TILE_HEIGHT * 0.5)
			-- :addTo(var.alivelayer)
			:align(display.CENTER, TILE_WIDTH * 0.5, - TILE_HEIGHT * 0.5)
			:addTo(mainSprite)
			:setOpacity(0)
		--imgAttackRange:loadTexture(filepath, ccui.TextureResType.localType)
		
		asyncload_callback(filepath, imgAttackRange, function(path, texture)
			imgAttackRange:loadTexture(path)
		end)
		
		imgAttackRange:runAction(cca.seq({
			cca.fadeIn(0.25),
			cca.fadeOut(0.25), 
			cca.removeSelf()
		}))
	end
	

	-- print ("handleAutoChangeAim", var.attackTargetType, tempType)
	if not (var.attackTargetType == tempType) then
		var.attackTargetType = tempType
		var.nearbyGhosts = {}
		var.mAutoSelectedGhosts = {}
	end
	

	if not var.nearbyGhosts then var.nearbyGhosts={} end

	local allGhost = getAimGhosts(var.attackTargetType, curState)
	if not allGhost or #allGhost < 1 then return end

	if #var.nearbyGhosts < 1 then
		var.nearbyGhosts = NetCC:getNearGhost(var.attackTargetType)
	end
	local aimID
	if #var.mAutoSelectedGhosts < 1 then
		aimID = allGhost[1].mID
	else
		for i,v in ipairs(allGhost) do
			if not table.indexof(var.mAutoSelectedGhosts, v.mID) then
				aimID = v.mID
				break
			end
		end
		if not aimID then
			aimID = allGhost[1].mID
			var.mAutoSelectedGhosts = {}
		end
	end
	if aimID then
		table.insert(var.mAutoSelectedGhosts, aimID)
		CCGhostManager:selectSomeOne(aimID)
	end

	-- if #var.nearbyGhosts > 0 then
	-- 	local myGuild = GameBaseLogic.GetMainRole():NetAttr(GameConst.net_guild_name)
	-- 	local myTeam = GameBaseLogic.GetMainRole():NetAttr(GameConst.net_teamid)
	-- 	local curRolePos = cc.p(GameCharacter._mainAvatar:NetAttr(GameConst.net_x), GameCharacter._mainAvatar:NetAttr(GameConst.net_y))

	-- 	local distance
	-- 	local sortTable = {}
	-- 	local ptype, pkvalue, isBoss, team, guild

	-- 	for i,v in ipairs(var.nearbyGhosts) do
	-- 		local avatar = CCGhostManager:getPixesGhostByID(v)
	-- 		local dis = GameCharacter.getGhostDistance(avatar)
	-- 		if avatar and dis <= 6 and not avatar:NetAttr(GameConst.net_dead) then
	-- 			ptype = avatar:NetAttr(GameConst.net_type)
	-- 			pkvalue = avatar:NetAttr(GameConst.net_pkvalue) and avatar:NetAttr(GameConst.net_pkvalue) or 0
	-- 			isBoss = avatar:NetAttr(GameConst.net_isboss)
				
	-- 			if type(isBoss) == "boolean" then isBoss = 0 end

	-- 			team = (avatar:NetAttr(GameConst.net_teamid) == myTeam) and 1 or 0
	-- 			guild = (avatar:NetAttr(GameConst.net_guild_name) == myGuild) and 1 or 0

	-- 			distance = math.abs(avatar:NetAttr(GameConst.net_x) - curRolePos.x) + math.abs(avatar:NetAttr(GameConst.net_y) - curRolePos.y)
	-- 			-- print(curStateImg,v,ptype,pkvalue,isBoss,team,guild,distance,avatar:NetAttr(GameConst.net_isboss))
	-- 			table.insert(sortTable,{ghostId = v,ptype = ptype,pkvalue=pkvalue,isBoss = isBoss, team = team,guild = guild,distance=distance})
	-- 		end
	-- 	end
		
	-- 	local function sortT(A,B)
	-- 		if curState == 101 or curState == 100 then -- 和平和全体
	-- 			if A.isBoss == B.isBoss then
	-- 				if A.ptype == GameConst.GHOST_MONSTER and B.ptype ~= GameConst.GHOST_MONSTER then return false
	-- 				elseif A.ptype ~= GameConst.GHOST_MONSTER and B.ptype == GameConst.GHOST_MONSTER then return true 
	-- 				else return A.distance<B.distance end
	-- 			else
	-- 				return A.isBoss>B.isBoss
	-- 			end
	-- 		-- elseif curState == 104 then --捕杀
	-- 		-- 	if A.pkvalue == B.pkvalue then
	-- 		-- 		if A.isBoss == B.isBoss then
	-- 		-- 			return A.distance<B.distance
	-- 		-- 		else
	-- 		-- 			return A.isBoss > B.isBoss
	-- 		-- 		end
	-- 		-- 	else
	-- 		-- 		return A.pkvalue > B.pkvalue
	-- 		-- 	end
	-- 		elseif curState == 105 then
	-- 			if A.team == B.team then
	-- 				return A.distance<B.distance
	-- 			else
	-- 				return A.team>B.team
	-- 			end
	-- 		elseif curState == 103 then
	-- 			if A.guild == B.guild then
	-- 				return A.distance<B.distance
	-- 			else
	-- 				return A.guild>B.guild
	-- 			end
	-- 		elseif curState == "all" then
	-- 			return A.distance<B.distance
	-- 		else --阵营
	-- 			return A.distance<B.distance
	-- 		end
	-- 	end
	-- 	if #sortTable>1 then
	-- 		table.sort(sortTable,sortT)
	-- 	end
	-- 	if #sortTable>=1 then
	-- 		table.removebyvalue(var.nearbyGhosts, sortTable[1].ghostId)
	-- 		CCGhostManager:selectSomeOne(sortTable[1].ghostId)
	-- 		if #sortTable == 1 then
	-- 			var.nearbyGhosts = {}
	-- 		end
	-- 	end
	-- end
end

function GUIMain.handlePanelData(event)
	local serverData = GameUtilSenior.decode(event.data)
	if event.type == "PanelOne" then
		if serverData and serverData.panelName then
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = serverData.panelName})
		end
	elseif event.type == "Transfer" then
		GameMusic.play(GameConst.SOUND.convey)
	elseif event.type == "Medicine" then
		GameMusic.play(GameConst.SOUND.medicine)
	elseif event.type == "showBossDropItems" then
		setBossDropShow(serverData)
	elseif event.type == "LoadAward" then
		-- GameBaseLogic.isGetLoadAwarded = tonumber(event.data)
		-- if false then 							---------

			-- GUIRightTop.setDownLoadBtnVisible(false,false)
			-- GameBaseLogic.downLoading=false
			-- cc.DownManager:getInstance():setAllowDown(GameBaseLogic.downLoading)

		-- else
		-- 	if GameBaseLogic.isGetLoadAwarded<1 or GameBaseLogic.needLoadNum>0 then
		-- 		if (GameBaseLogic.wifiOK or G_ShieldGSM>0) and GameBaseLogic.isGetLoadAwarded<1 and GameBaseLogic.needLoadNum>0 then
		-- 			--这里显示下载按钮并播放动画
		-- 			GameBaseLogic.downLoading=true
		-- 			cc.DownManager:getInstance():setAllowDown(GameBaseLogic.downLoading)
		-- 			GUIRightTop.setDownLoadBtnVisible(true,true)
		-- 			GUIRightTop.setDownLoadBtnAnim(true)
		-- 		else
		-- 			--这里只显示下载按钮
		-- 			GameBaseLogic.downLoading=false
		-- 			GUIRightTop.setDownLoadBtnAnim(false)
		-- 			GUIRightTop.setDownLoadBtnVisible(true,false)
		-- 			cc.DownManager:getInstance():setAllowDown(GameBaseLogic.downLoading)
		-- 		end
		-- 	else
		-- 		--这里隐藏下载按钮
		-- 		GUIRightTop.setDownLoadBtnVisible(false,false)
		-- 		GameBaseLogic.downLoading=false
		-- 		cc.DownManager:getInstance():setAllowDown(GameBaseLogic.downLoading)
		-- 	end
		-- end
	elseif event.type == "ContainerHangUp" then
		if serverData.cmd == "start" then
			var.scene:stopAllActions()
			var.scene:runAction(cca.seq({
				cca.rep(cca.delay(1),60),
				cca.cb(function(target) GameBaseLogic.ExitToReSelect() end),
			}))
		elseif serverData.cmd == "stop" then
		 	var.scene:stopAllActions()
		end
	end
end

function GUIMain.onKeyboard(event)
	-- if event.key=="back" then
	-- 	if PLATFORM_ANZHI then
	-- 		GameCCBridge.callPlatformFunc({func="showExit"})
	-- 	elseif device.platform == "windows" then
	-- 		GameUtilSenior.showAlert("提示","要重新登录吗？",{"确定","取消"},function (event)
	-- 			if event.buttonIndex == 1 then
	-- 				GameBaseLogic.ExitToRelogin()
	-- 		    end
	-- 		end,var.scene)
	-- 	end
	-- end
end

function GUIMain.get_mainrole_pixespos()
	if var.destlayer then
		-- local mainrole=CCGhostManager:getMainAvatar()
		if GameCharacter._mainAvatar then
			return GameCharacter._mainAvatar:getSprite():convertToWorldSpace(cc.p(TILE_WIDTH/2,-TILE_HEIGHT/2))
		end
	end
end

local function showTaskTips(event)
	if event and event.tips then
		if var.scene then
			if GameUtilSenior.isObjectExist(var.imgTaskTips) then
				var.imgTaskTips:removeFromParent()
				var.imgTaskTips = nil
			end

			-- local params = {
			-- 	text= event.tips, 
			-- 	fontSize= 24, 
			-- 	color = GameBaseLogic.getColor(0xfff3b3), 
			-- 	outlineColor = GameBaseLogic.getColor(0x601902),
			-- 	outlineStrength = 1
			-- }
			-- var.imgTaskTips = GameUtilSenior.newUILabel(params)
			var.imgTaskTips = ccui.ImageView:create()
				:align(display.BOTTOM_CENTER, display.cx, display.cy - 160)
				:addTo(var.scene, 10)
			asyncload_callback(string.format("ui/image/%s.png",event.tips), var.imgTaskTips, function(filepath, texture)
				var.imgTaskTips:loadTexture(filepath)
			end)	
				-- :enableGlow(GameBaseLogic.getColor4(0xf57c06))
				-- :enableOutline(GameBaseLogic.getColor(0x601902),1)

			var.imgTaskTips:runAction(cca.seq({
				cca.delay(6),
				cca.removeSelf()
			}))
		end
	end
end

function game_scene_update(dx)
	-------------------------------------刷新选中角色状态----------------------------------
	if not MAIN_IS_IN_GAME then
		return
	end

	GameBaseLogic.ClockTick=GameBaseLogic.ClockTick+1

	-- if var.ticknum>10 then
	-- 	local fps=var.ticktime/var.ticknum
	-- 	if CONFIG_FPS>30 and fps>33 then
	-- 		var.tickhigh=var.tickhigh+1
	-- 		if var.tickhigh>30 then
	-- 			var.tickhigh=0
	-- 			var.ticklow=0
	-- 			set_fps(30)
	-- 		end
	-- 	end
	-- 	if CONFIG_FPS<40 and fps<33.5 then
	-- 		var.ticklow=var.ticklow+1
	-- 		if var.ticklow>30 then
	-- 			var.ticklow=0
	-- 			var.tickhigh=0
	-- 			set_fps(40)
	-- 		end
	-- 	end
	-- 	var.ticknum=0
	-- 	var.ticklast=0
	-- 	var.ticktime=0
	-- end

	-- if var.ticklast==0 then
	-- 	var.ticklast=GameBaseLogic.getTime()
	-- else
	-- 	local realtime=GameBaseLogic.getTime()-var.ticklast
	-- 	var.ticklast=realtime+var.ticklast
	-- 	if realtime<900 then
	-- 		var.ticktime=realtime+var.ticktime
	-- 		var.ticknum=var.ticknum+1
	-- 	end
	-- end
	GameCharacter.update()
	var.tick = var.tick or 0
	var.tick = var.tick + 1
	if var.tick < 10 then return end
	var.tick = 0

	if var.showTargetID and var.showTargetID > 0 then
		freshHP()
		-- freshSmallMonsterHP()
		-- freshfight()
	end

	-- TODO 所有的循环函数都要仔细review，防止有效率坑
	GUIRightTop.update() --- 小地图刷新
	GUIRightBottom.update()
	GUILeftTop.update() -- 数据状态

	GUILeftCenter.update()

	GDivTask.updateGuidePosition() --引导层
	-------------------------------------

	-- if GameSocket.mUiState then
	-- 	if GameSocket.mTradeInfo.mTradeTarget ~= "" and GameBaseLogic.panelTradeOpen == false then
	-- 		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_trade"})
	-- 		GameSocket.mUiState = false
	-- 	elseif GameSocket.mTradeInfo.mTradeTarget == "" and GameBaseLogic.panelTradeOpen == true then
	-- 		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL,str="panel_trade"})
	-- 		GameSocket.mUiState = false
	-- 	end
	-- end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_SCENE_GAME_UPDATE, "game_scene_update")

function GUIMain.onSocketError(event)
	local waitLayer = var.scene:getChildByName("waitLayer")
	if not waitLayer then
		waitLayer = display.newColorLayer(cc.c4b(0,0,0,255*0.4))
		-- waitLayer:setContentSize(cc.size(display.width,display.height))
		waitLayer:setName("waitLayer")
		waitLayer:setLocalZOrder(9999)
		var.scene:addChild(waitLayer)

		local layerBg = ccui.ImageView:create()
		layerBg:loadTexture("null",ccui.TextureResType.plistType)
			:setContentSize(cc.size(display.width,display.height))
			:setCapInsets(cc.rect(10,10,30,30))
			:setScale9Enabled(true)
			:setTouchEnabled(true):setTouchSwallowEnabled(true):setOpacity(200)
			:addTo(waitLayer):align(display.LEFT_BOTTOM, 0, 0)
		local loadingCircle = ccui.ImageView:create()
		loadingCircle:loadTexture("Loading_bottom",ccui.TextureResType.plistType)
			:addTo(waitLayer):align(display.CENTER, display.cx, display.cy)
	end
	local circle1 = waitLayer:getChildByName("circle1")
	if not circle1 then
		circle1 = ccui.ImageView:create()
		circle1:loadTexture("Loading_Circle01",ccui.TextureResType.plistType)
			:addTo(waitLayer):align(display.CENTER, display.cx, display.cy)		
	end
	circle1:runAction(cca.loop(cca.rotateBy(1.5, 360)))
	local circle2 = waitLayer:getChildByName("circle2")
	if not circle2 then
		circle2 = ccui.ImageView:create()
		circle2:loadTexture("Loading_Circle02",ccui.TextureResType.plistType)
			:addTo(waitLayer):align(display.CENTER, display.cx, display.cy)		
	end
	circle2:runAction(cca.loop(cca.rotateBy(1.5, -360)))

	MAIN_IS_IN_GAME = false
	waitLayer:stopAllActions()
	var.scene:stopAllActions()

	cc.SocketManager:getInstance():stopSocket()

	waitLayer:runAction(cca.seq({
		cca.rep(cca.seq({
			cca.delay(5),
			cca.cb(function(target)
				if MAIN_IS_IN_GAME then
					target:stopAllActions():hide()
					return
				end
				GameSocket:disconnect(true)
				GameSocket:connect(GameBaseLogic.serverIP, GameBaseLogic.serverPort,2 and GameSocket.kuaFuState or 0)
			end)
		}),6),
		cca.cb(function(target)
			GameBaseLogic.ExitToRelogin()
		end)
	}))
end

function scene_game_enter(_scene)
	print("GUIMain--------------------",_scene)
	-- GameMusic.stop(GameMusic.curMusic)

	GUIMain.initVar()

	var.tick = 0

	GameSocket:GameEnterMap()
	
	if not PLATFORM_APP_STORE then
		if GameBaseLogic.GetMainRole() then
			if GameBaseLogic.newRole then
				GameBaseLogic.newRole = false
			end

		end
	end
	MAIN_IS_IN_GAME = true

	var.scene = _scene

	GameBaseLogic.downLoading=true
	cc.DownManager:getInstance():setAllowDown(GameBaseLogic.downLoading)
	cc.SocketManager:getInstance():setSendPing(true)
	-- var.mainrole = CCGhostManager:getMainAvatar()

	-- GameCharacter._mainAvatar = GameCharacter._mainAvatar or CCGhostManager:getMainAvatar()

	local shakedb=var.scene:getChildByName("shake_db")
	if shakedb then
		var.destlayer=shakedb:getChildByName("map_dest")
		if var.destlayer then
			var.alivelayer=shakedb:getChildByName("map_alive")
		end
	end

	-- local function initAttackModel()
	-- 	var.attackModel = GUIAnalysis.load("ui/layout/AttackModel.uif")
	-- 	if var.attackModel then
	-- 		var.attackModel:align(display.LEFT_CENTER, 0, display.height-150)
	-- 			:addTo(var.scene,15)
	-- 		GUIAttackType.init(var.attackModel)
	-- 	end
	-- end

	local function initPanelAndPlot()
		GUIMain.m_GDivContainer = require("gameui.GDivContainer").new()
		if GUIMain.m_GDivContainer then
			var.scene:addChild(GUIMain.m_GDivContainer,50)
		end
	end

	local function initGhostHeadUI()
		var.uiPlayer = GUIAnalysis.load("ui/layout/GUICharacter.uif")
			:addTo(var.scene, 8)
			:align(display.CENTER_TOP, display.cx , display.height)
			:hide()
		var.uiPlayer:getWidgetByName("playerBg"):setTouchEnabled(false)
		var.playerHeadBox = var.uiPlayer:getWidgetByName("box_player"):hide()
		var.uiPlayer:getWidgetByName("pos_hp"):setPercent(10,10):setFontSize( 14 )
		var.uiPlayer:getWidgetByName("pos_mp"):setPercent(10,10):setFontSize( 14 )

		var.bossHeadBox = var.uiPlayer:getWidgetByName("box_boss"):hide()

		for i=1,6 do
			local dropItem=var.bossHeadBox:getWidgetByName("drop"..i)
			dropItem:setScale(0.395)
		end

		var.closePlayer = var.uiPlayer:getWidgetByName("btnClosePlayer"):setTouchEnabled(true)
		var.closePlayer:addClickEventListener(function(sender)
				GUIMain.hideUIPlayer()
				CCGhostManager:selectSomeOne(0)
				GameCharacter._lastAimID = 0
			end)
		var.closePlayer:setSwallowTouches(true)

	end

	local function initGuidePart()
		----------------------新手欢迎界面----------------------
		-- if GameCharacter._mainAvatar:NetAttr(GameConst.net_level) == 1 then
		--if GameCharacter._mainAvatar:NetAttr(GameConst.net_level) == 1 and GameSocket.mTasks[1000].mState == 100014 then
		if GameSocket.mTasks[1000].mState == 100014 then
			GameSocket:dispatchEvent({
				name = GameMessageCode.EVENT_SHOW_TIPS, str = "welcome",
			})
		end
		
		----------------------end----------------------
		-- if var.mainrole:NetAttr(GameConst.net_level) > 1 then 
		-- 	GameSocket:PushLuaTable("gui.AwardSign.firstOpen")
		-- end
		-----------------------夺宝历练---------------------
		-- GameSocket:PushLuaTable("gui.AwardExercise.onPanelData","open")

		----------------------向服务器请求红点信息----------------------
		GameSocket:PushLuaTable("gui.moduleRedPoint.reqRedPointInfo") 
		----------------------客户端检测红点信息----------------------
		---背包更好装备检测---
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CHECK_BETTER_EQUIP})
		-------------------------邮件个数检测------------------------------------
		GameSocket:getMails()
		-------------------------背包是否满------------------------------------
		GameSocket:checkBagFull()
		-------------------------下载奖励------------------------------------
		GameSocket:PushLuaTable("gui.PanelLoadAward.onPanelData","downall")
		
		-------------------------离线挂机------------------------------------
		if not PLATFORM_TEST then
			GameSocket:PushLuaTable("gui.ContainerHangUp.onPanelData",GameUtilSenior.encode({actionid = "check"}))
		end
		-- -------------------------背包宝箱检测------------------------------------
		-- GameBaseLogic.enterGameBoxMatch()
		-------------------------是否正在抢红包------------------------------------
		-- GameSocket:PushLuaTable("npc.hongbao.isGrabHongBaoTime","")

		-- if GameSocket.isAfterStory then
		-- 	GameSocket.mNeedContinueTask = true
		-- 	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CONTINUE_TASK})
		-- end
		GameSocket:FriendFresh()
		GUIMain.handleHPMPChange()

		GameSocket:PushLuaTable("player.onClientData", GameUtilSenior.encode({actionid = "enterGame"})) 
	end
	--上线设置红点（特殊情况）
	local function checkShowRed()
		for k,v in pairs(GameSocket.skillRed) do
			if v==true then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_REDPOINT, lv = 2022,index =1})
				break
			end
		end
		GameSocket:checkBagRedDot()
	end

	local function initGameLayer()
		local layer_info = {
			{name = "m_layerGuide",		script = "GDivTask",		zOrder = 200},
			{name = "m_layerRocker",	script = "GDivWheel",		zOrder = 6},
			{name = "m_layerTips",		script = "GDivToast",		zOrder = 106},
			{name = "m_layerTouch",		script = "GDivControl",		zOrder = 300},
			{name = "m_layerAlert",		script = "GDivDialog",		zOrder = 110},
			{name = "m_tipsManager",	script = "GUIFloatTipsManager",	zOrder = 105},
			{name = "m_layerVoice",		script = "GDivRecord",		zOrder = 100},
			-- {name = "m_layerBattle",	script = "GDivSkill",		zOrder = 8},
		}

		local index = 1
		var.scene:runAction(cca.seq({
				cca.rep(
					cca.seq({
						-- cca.delay(1 / 60),
						cca.cb(function ()
							if MAIN_IS_IN_GAME then
								print("initGameLayer", index)
								local v = layer_info[index]
								GUIMain[v.name] = _G[v.script].init()
								if GUIMain[v.name] then
									var.scene:addChild(GUIMain[v.name], v.zOrder)
								end
								index = index + 1
							end
						end)
				}),#layer_info),
				-- cca.cb(function ()
				-- 	initAttackModel()
				-- end),
				-- cca.delay(1 / 60),
				cca.cb(function ()
					if MAIN_IS_IN_GAME then
						initPanelAndPlot()
					end
				end),
				-- cca.delay(1 / 60),
				cca.cb(function ()
					if MAIN_IS_IN_GAME then
						initGhostHeadUI()
					end
				end),
				-- cca.delay(1 / 60),
				cca.cb(function ()
					if MAIN_IS_IN_GAME then
						initGuidePart()
					end
				end),
				cca.cb(function ()
					if MAIN_IS_IN_GAME then
						GUIItemUsage.init(var.scene)
					end
				end),
				cca.cb(function ()
					if MAIN_IS_IN_GAME then
						GUIExtendEquipAttr.init(var.scene)
					end
				end),

				cca.cb(function ()
					if MAIN_IS_IN_GAME then
						GUIFunctionBeta.init(var.scene)
					end
				end),
				cca.cb(function ()
					if MAIN_IS_IN_GAME then
						GUIFocusDot.init(var.scene)
						checkShowRed()

						if G_OpenRocker == 0 then
							GUIMain.m_layerRocker:setVisible(false)
						end
						
					end
				end)
		}))
	end

	local part_infos = {
		{name = "m_tcPartUI",xml = "GUITopCenter", script = "GUITopCenter",	zOrder = 10},
		{name = "m_cbPartUI",xml = "GUICenterBottom", script = "GUICenterBottom", zOrder = 15},
		{name = "m_ltPartUI",xml = "GUILeftTop", script = "GUILeftTop",		zOrder = 11},
		{name = "m_rtPartUI",xml = "GUIRightTop", script = "GUIRightTop",		zOrder = 9},
		{name = "m_rcPartUI",xml = "GUIRightCenter", script = "GUIRightCenter",		zOrder = 16},
		{name = "m_rbPartUI",xml = "GUIRightBottom", script = "GUIRightBottom",	zOrder = 9},
		{name = "m_lcPartUI",xml = "GUILeftCenter", script = "GUILeftCenter",	zOrder = 10},
		{name = "m_lbPartUI",xml = "GUILeftBottom", script = "GUILeftBottom",	zOrder = 30},
		{name = "GUILeftHuoDongAnNiu",xml = "GUILeftHuoDongAnNiu", script = "GUILeftHuoDongAnNiu",	zOrder = 31},
		{name = "InfoPart",	 xml = "GUIInfo", script = "GUIInfo",	zOrder = 300},
	}

	local index = 1

	var.scene:runAction(cca.seq({
		cca.rep(
			cca.seq({
				-- cca.delay(1 / 60),
				cca.cb(function ()
					if MAIN_IS_IN_GAME then
						local v = part_infos[index]
						print("initGamePartUI", index,v.xml)
						GUIMain[v.name] = GUIAnalysis.load("ui/layout/"..v.xml..".uif")
						if GUIMain[v.name] then
							var.scene:addChild(GUIMain[v.name], v.zOrder)
							_G[v.script].init_ui(GUIMain[v.name])
						end
						index = index + 1
					end
				end)
		}),#part_infos),
		cca.cb(initGameLayer)
	}))

	cc.EventProxy.new(GameSocket,var.scene)
			:addEventListener(GameMessageCode.EVENT_SHOW_PLOT, GUIMain.handleShowPlot) 
			:addEventListener(GameMessageCode.EVENT_MAINUI_VISIBLE, GUIMain.handleMainUIVisible)
			-- :addEventListener(GameMessageCode.EVENT_ATTACKMODE_CHANGE, GUIMain.updatePKState)
			:addEventListener(GameMessageCode.EVENT_MAP_TOUCHED, GUIMain.handleMapTouched)
			:addEventListener(GameMessageCode.EVENT_HANDLE_CHG_AVA, GUIMain.handleAutoChangeAim)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, GUIMain.handlePanelData)
			-- :addEventListener(GameMessageCode.EVENT_KEYBOARD_PASSED, GUIMain.onKeyboard)
			:addEventListener(GameMessageCode.EVENT_SOCKET_ERROR, GUIMain.onSocketError)
			:addEventListener(GameMessageCode.EVENT_START_PROGRESS, GUIMain.onShowProgressbar)
			:addEventListener(GameMessageCode.EVENT_STOP_PROGRESS, GUIMain.onHideProgressbar)
			-- :addEventListener(GameMessageCode.EVENT_ITEM_GOT_ANIMATION, GUIMain.handleItemGotAnimation)
			:addEventListener(GameMessageCode.EVENT_BUFF_GOT_ANIMATION, GUIMain.handleBuffGotAnimation)
			:addEventListener(GameMessageCode.EVENT_MAP_ENTER, GUIMain.updatePkEnable)
			-- :addEventListener(GameMessageCode.EVENT_VOICE_MODEL_CHANGE, GUIMain.onVoiceModelChange)
			:addEventListener(GameMessageCode.EVENT_SCENE_SHAKE, GUIMain.onShakeScene)
			:addEventListener(GameMessageCode.EVENT_SHOW_TASK_ANIM, GUIMain.onSwitchTaskAnim)
			:addEventListener(GameMessageCode.EVENT_PLATFORM_LOGOUT, GUIMain.onPlatformLogout)
			-- :addEventListener(GameMessageCode.EVENT_ONEKEY_VISIBLE, GUIMain.handleOneKeyHide)
			:addEventListener(GameMessageCode.EVENT_CONNECT_ON,GUIMain.onConnect)
			:addEventListener(GameMessageCode.EVENT_SELF_HPMP_CHANGE,GUIMain.handleHPMPChange)
			:addEventListener(GameMessageCode.EVENT_SHOW_FLY,GUIMain.handleTaskFly)
			:addEventListener(GameMessageCode.EVENT_MONSTER_OWNER_CHANGE, updateMonsterOwner)
			:addEventListener(GameMessageCode.EVENT_SHOW_TASK_TIPS, showTaskTips)
	-- listPlayersBg:getWidgetByName("btnClose2"):addClickEventListener(function(sender)
	-- 	listPlayersBg:setVisible(false)
	-- 	-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HANDLE_FLOATING , btn = "main_change" , visible = false})
	-- end)

	CCGhostManager:foreachGhosts("show_dart_halo", GameConst.GHOST_DART)
	CCGhostManager:foreachGhosts("handleMonsterVisible", GameConst.GHOST_MONSTER)
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_SCENE_GAME_ENTER,"scene_game_enter")

function GUIMain.onConnect(event)
	local waitLayer = var.scene:getChildByName("waitLayer")
	if waitLayer then
		waitLayer:hide():stopAllActions()
	end
	cc.NetClient:getInstance():initClient()
	display.replaceScene(GPageReEnter.new())
end

function show_dart_halo(ghostType, mPixesAvatar)
	if ghostType ~= GameConst.GHOST_DART then return end
	if not mPixesAvatar then return end
	if not MainRole then return end

	local nameSprite = mPixesAvatar:getNameSprite()
	if nameSprite then
		show_dart_name(nameSprite, mPixesAvatar:NetAttr(GameConst.net_name))
	end

	local netOwner = mPixesAvatar:NetAttr(GameConst.net_item_owner) or -1
	if not (MainRole and GameCharacter._mainAvatar) then return end
	if GameCharacter._mainAvatar:NetAttr(GameConst.net_id) ~= netOwner then return end
	-- my dart
	GameCharacter.mDartSprite = mPixesAvatar:getSprite()
	if not GameCharacter.mDartSprite then return end
	GameCharacter.mDartClothSprite = mPixesAvatar:getDressSprite(0)
	if not GameUtilSenior.isObjectExist(GameCharacter.mDartHalo) then
		GameCharacter.mDartHalo = ccui.ImageView:create()
			:align(display.CENTER)
			:addTo(var.alivelayer, -1)
			--:loadTexture("ui/image/dart_notice.png", ccui.TextureResType.localType)
		
		asyncload_callback("ui/image/dart_notice.png", GameCharacter.mDartHalo, function(path, texture)
			GameCharacter.mDartHalo:loadTexture(path)
		end)
	end
end

GUIMain.showDartHalo = show_dart_halo

function GUIMain.onPlatformLogout(event)
	GameBaseLogic.ExitToRelogin()
end

function GUIMain.pushOperateBtn(sender)
	local btnName = sender:getName()
	local avatar = CCGhostManager:getPixesGhostByID(GameCharacter.getAimGhostID())
	local pName = avatar:NetAttr(GameConst.net_name)
	local exeFuncs = {
		["btnInviteGroup"] = function ()--邀请组队
			local pID = avatar:NetAttr(GameConst.net_id)
			local nearByGroupInfo = GameSocket.nearByGroupInfo[pID]

			if #GameSocket.mGroupMembers <= 0 then--本人没有队伍
				if nearByGroupInfo then--选中玩家有队伍
					GameSocket:alertLocalMsg("已申请入队，请等待批准","alert")
					GameSocket:JoinGroup(nearByGroupInfo.group_id)
				else--两个人都没队伍
					GameSocket:InviteGroup(pName)
				end
			else--本人有队伍
				if nearByGroupInfo then--被邀请人有队伍
					GameSocket:alertLocalMsg("对方有队伍，无法组队","alert")
				else--被邀请人无队伍
					if GameSocket.mCharacter.mGroupLeader ~= GameCharacter._mainAvatar:NetAttr(GameConst.net_name) then--不是队长
						GameSocket:alertLocalMsg("队长才能邀请组队","alert")
					else
						GameSocket:InviteGroup(pName)
					end

				end
			end
		end,
		["btnApplyTrade"] = function ()
			if pName == GameSocket.mTradeInviter then
				GameSocket:AgreeTradeInvite(pName)
				table.remove(GameSocket.tipsMsg["tip_trade"], 1)
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_BOTTOM,str="tip_trade"})
			else
				if not GameSetting.getConf("CloseTrad") then
					GameSocket:TradeInvite(pName)
				else
					GameSocket:alertLocalMsg(GameConst.str_close_trade, "alert")
				end
			end
			GameSocket:PushLuaTable("count.onClientData", GameUtilSenior.encode({cmd = "点击交易"}))
		end,
		["btnCheckEquip"] = function ()
			-- GameSocket:dispatchEvent({name=GameMessageCode.EVENT_OPEN_PANEL,str="panel_check_equip", pName = pName})
			GameSocket:CheckPlayerEquip(pName)
		end,
		["btnAddFriend"] = function ()
			if GameSocket.mFriends and GameSocket.mFriends[pName] and GameSocket.mFriends[pName].title == 100 then
				GameSocket:alertLocalMsg("该玩家已经是您的好友","alert")
			else
				GameSocket:FriendChange(pName,100)
			end
		end,
		["btnPrivateChat"] = function ()
			if GameSocket.mFriends[pName] and GameSocket.mFriends[pName].title == 102 then
				GameSocket:alertLocalMsg("已屏蔽["..pName.."]无法私聊", "alert")
			else
				GameSocket:privateChatTo(pName)
			end
		end,
	}
	if exeFuncs[btnName] and type(exeFuncs[btnName]) == "function" and avatar then
		exeFuncs[btnName]()
		GUIMain.hideUIPlayer()
		CCGhostManager:selectSomeOne(GameCharacter.getAimGhostID())
	end
end

function scene_game_exit(_scene)

	var.scene:stopAllActions()

	clearFramesCallback()

	GameBaseLogic.downLoading=false
	cc.DownManager:getInstance():setAllowDown(GameBaseLogic.downLoading)

	--销毁相关定时器
	GameCharacter.initVar()

	var.tick = 0

	MAIN_IS_IN_GAME = false

	GUIMain.initVar()
	GDivDialog.exit()
	--clear game
	cc.GhostManager:getInstance():remAllSkill()
	cc.GhostManager:getInstance():remAllEffect()
	cc.GhostManager:getInstance():remAllPixesGhost()
	cc.NetClient:getInstance():remAllNetGhost()
	cc.CacheManager:getInstance():releaseUnused(false)
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_SCENE_GAME_EXIT,"scene_game_exit")



function GUIMain.updatePkEnable(event)
	var.clickAnim={}
	--var.attackModel.PkEnable = event.PkEnable
	-- var.attackModel:getWidgetByName("attack_camp"):setBright(checkint(event.PkEnable) > 0)
end

function GUIMain.updatePKState(event)
	
	local curState = GameSocket.mAttackMode -- 99
	if not var.mode_btn or not curState then return end
	if not stateImg[curState] then return end
	
	var.mode_btn:loadTextures("attack_"..stateImg[curState], "attack_"..stateImg[curState].."_sel", "", ccui.TextureResType.plistType)
	
	local needUpdate
	if curState == 105 then
		if G_AttackCamp == 0 then 
			G_AttackCamp = 1
			needUpdate = true
		end
	elseif curState == 103 then
		if G_AttackGuild == 0 then
			G_AttackGuild = 1
			needUpdate = true
		end
	else
		if G_AttackGuild == 1 or G_AttackCamp == 1 then
			G_AttackGuild = 0
			G_AttackCamp = 0
			needUpdate = true
		end
	end
	if needUpdate then CCGhostManager:updatePlayerName() end
end

function GUIMain.getGuideWidget(param, str)
	-- print("GUIMain.getGuideWidget/////////////", str)
	local widget
	if param.root == "GDivContainer" and GameUtilSenior.isObjectExist(GUIMain.m_GDivContainer) then
		widget = GUIMain.m_GDivContainer:getGuideWidget(param.panel, param.node)
	elseif GUIMain[param.root] then
		widget = GameUtilSenior.getChildFromNode(GUIMain[param.root], param.node)
		--print("GUIMain.getGuideWidget", widget)
		-- widget = ccui.Helper:seekWidgetByName(GUIMain[param.root], param.node)
		-- GUIMain[param.root]:getWidgetByName(param.node)
	elseif param.root == "mSubMenu" then
		widget = GameUtilSenior.getChildFromNode(GUIMain["m_rbPartUI"], param.node)
	end
	return widget
end

-- function handle_avatar_protectbody(pixesAvatar)
	-- if not pixesAvatar then return end
	-- pixesAvatar:remEffect("haloLater")
	-- pixesAvatar:remEffect("haloPre")
	-- local lowlevel = pixesAvatar:NetAttr(GameConst.net_low)
	-- local low = GameBaseLogic.getLow(lowlevel)
	-- local resTable = GameBaseLogic.getQiangHuaResid(low)
	-- if resTable then
	-- 	pixesAvatar:addEffect("haloPre",resTable.resPre,10,cc.p(0,50),0,true)--腰间光换前
	-- 	pixesAvatar:addEffect("haloLater",resTable.resLater,-10,cc.p(0,50),0,true)--腰间光环后
	-- end
-- end
-- cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_PROTECTBODY_CHANGE, "handle_avatar_protectbody")

function ghost_map_meet(srcid)
	if not MainRole then return end
	if var.nearbyGhosts and table.indexof(var.nearbyGhosts, srcid) == false then--新的ghost则塞到table中
		table.insert(var.nearbyGhosts, srcid)
	end
	-- local pixesAvatar = CCGhostManager:getPixesAvatarByID(srcid)
	-- -- 是否怪物
	-- if pixesAvatar and pixesAvatar:NetAttr(GameConst.net_type) == GameConst.GHOST_MONSTER then
	-- 	show_monster_title(pixesAvatar)
	-- end
	-- if pixesAvatar then handle_avatar_protectbody(pixesAvatar) end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_MAP_MEET,"ghost_map_meet")

function ghost_map_bye(srcid)--对象死亡也会触发
	-- print("ghost_map_byeghost_map_byeghost_map_byeghost_map_bye")
	if var.nearbyGhosts then
		table.removebyvalue(var.nearbyGhosts, srcid)
	end
	-- if not MainRole then return end
	-- print("-----------------ghost_map_bye",srcid, var.showTargetID)

	if var.showTargetID <= 0 then
		GUIMain.hideUIPlayer()
	elseif srcid == var.showTargetID then
		-- local ghost = NetCC:getGhostByID(var.showTargetID)
		-- -- print("getGhostByID", ghost)
		-- if ghost then
		-- 	if ghost.attack_time then
		-- 		if GameBaseLogic.getTime() >= ghost.attack_time then		
		-- 			GUIMain.hideUIPlayer()
		-- 			CCGhostManager:selectSomeOne(0)
		-- 		end
		-- 	end
		-- 	if ghost:NetAttr(GameConst.net_dead) then
		-- 		GUIMain.hideUIPlayer()
		-- 		CCGhostManager:selectSomeOne(0)
		-- 	end
		-- else
			GUIMain.hideUIPlayer()
			CCGhostManager:selectSomeOne(0)
		-- end
		-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HANDLE_FLOATING , btn = "main_change" , visible = false})
	end

	if srcid==GameCharacter.getAimGhostID() then
		GameCharacter.setAimGhostID(0)
		if var.uiPlayer then
			var.uiPlayer:hide()
		end
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_EXTEND_VISIBLE, visible = true})
	end

	if GameSocket.mNetBuff then
		GameSocket.mNetBuff[srcid]=nil
	end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_MAP_BYE,"ghost_map_bye")

function after_add_net_ghost(srcid)--mapmeet绘制其他玩家完成后会调用此方法
	if GameSocket.mNetMap.mMapID == "chiwooBattle" then
		local team_label = {"<蚩尤>", "<轩辕>"}
		local meetPlayer = CCGhostManager:getPixesGhostByID(srcid)
		local team_id = meetPlayer:NetAttr(GameConst.net_teamid)
		local nameAddLabel = team_label[team_id] and team_label[team_id] or ""
		local nameColor = cc.c4f(255, 0, 0, 255)
		if team_id == 2 then
			nameColor = cc.c4f(0, 0, 255, 255)
		end
		local nameSprite = GUIPixesObject.getPixesGhost(srcid):getNameSprite()
		local mNameLabel = nameSprite:getChildByName("mNameLabel")
		if GameUtilSenior.isObjectExist(mNameLabel) then
			mNameLabel:setTextColor(nameColor)
			mNameLabel:setString(nameAddLabel..meetPlayer:NetAttr(GameConst.net_name))
		end
		GameUtilSenior.updateNamePos(nameSprite)
	end
	-- if srcid == GameCharacter._lastAimID then--刚才选中的ghost
	-- 	CCGhostManager:selectSomeOne(srcid)
	-- end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_AFTER_ADD_NET_GHOST,"after_add_net_ghost")

function select_some_one(selected,pixesGhost)
	-- print(pixesGhost:NetAttr(GameConst.net_id))
	local pid = pixesGhost:NetAttr(GameConst.net_id)
	local pixesAvatar = CCGhostManager:getPixesAvatarByID(pid)
	local pixesGhost = CCGhostManager:getPixesGhostByID(pid)
	local ptype = pixesGhost:NetAttr(GameConst.net_type)
	-- print("////////////////select_some_one////////////////", selected, pid);
	if pixesAvatar or pixesGhost then
		if selected == 0 then
			if pixesAvatar then pixesAvatar:remEffect("selected") end
			if pixesGhost and ptype == GameConst.GHOST_ITEM then pixesGhost:remEffect("selected") end
			if GameCharacter.getAimGhostID() == pid then
				GameCharacter.setAimGhostID(0)
			end
		elseif selected == 1 then
			if GameSocket.mLastAimGhost ~= pid then
				GameSocket.mLastAimGhost = pid
				GameSocket.mChangeAimFirst = true
			end
			GameCharacter._moveToNearAttack = false
			
			if ptype == GameConst.GHOST_NPC then
				if GameCharacter.getGhostDistance(pixesGhost) <= 2 then
					GameSocket:NpcTalk(pid,"100")
				else
					GameCharacter.startAutoMoveToMap(GameSocket.mNetMap.mMapID,pixesGhost:NetAttr(GameConst.net_x),pixesGhost:NetAttr(GameConst.net_y),3)
				end
			elseif ptype == GameConst.GHOST_ITEM then-- 捡物品
				-- GUIMain.startAutoMoveToPos(point)
				-- GameCharacter._moveEndAutoPick=true
				-- GUIMain.showGUIItemEffect(pid)
			elseif ptype == GameConst.GHOST_NEUTRAL then
				if GameCharacter.getGhostDistance(pixesGhost) <= 2 then
					-- GameSocket:NpcTalk(pid,"100")
					GameSocket:PushLuaTable("mon.menpaiNeutral.onTalk999",GameUtilSenior.encode({actionid = "talk",pid = pid,name = pixesGhost:NetAttr(GameConst.net_name)}))
				else
					GameCharacter.startAutoMoveToMap(GameSocket.mNetMap.mMapID,pixesGhost:NetAttr(GameConst.net_x),pixesGhost:NetAttr(GameConst.net_y),3)
				end
			else 
				if var.ghostType and var.ghostType ~= ptype then
					var.nearbyGhosts = {}
				end
				var.ghostType=ptype
				if ptype == GameConst.GHOST_PLAYER then
					GameCharacter._lastAimID=pid
					GUIMain.showUIPlayer(pid)
				elseif ptype == GameConst.GHOST_MONSTER then
					
					-- if pixesGhost:NetAttr(GameConst.net_show_head) and pixesGhost:NetAttr(GameConst.net_show_head) > 0 then
						GUIMain.showUIPlayer(pid)
					-- else
						-- GUIMain.hideUIPlayer()
					-- end
				elseif ptype == GameConst.GHOST_THIS then
					GUIMain.showUIPlayer(pid)
				else
					GUIMain.hideUIPlayer()
				end
				GameCharacter.setAimGhostID(pid)--当前指向的角色id
				-- GameCharacter.getAimGhost(GameCharacter.getAimGhostID())
				-- print("************change aimGhostId***********", GameCharacter.getAimGhostID());
			end

			if ptype==GameConst.GHOST_NPC and var.selectTab.npc then
				local savatar=CCGhostManager:getPixesAvatarByID(var.selectTab.npc)
				if savatar then
					savatar:remEffect("selected")
				end
				var.selectTab.npc=nil
			elseif ptype~=GameConst.GHOST_NPC and var.selectTab.oth then
				local savatar=CCGhostManager:getPixesAvatarByID(var.selectTab.oth)
				if savatar then
					savatar:remEffect("selected")
				end
				var.selectTab.oth=nil
			end
			-- if ptype~=GameConst.GHOST_ITEM then
				local res=50003
				-- if ptype == GameConst.GHOST_NPC then
				-- 	res=904111
				-- elseif ptype == GameConst.GHOST_PLAYER then
				-- 	res=903111
				-- elseif ptype == GameConst.GHOST_ITEM then
				-- 	res=905111
				-- end
				if pixesAvatar and pixesAvatar.addEffect then
					-- table.insert(var.selectTab,pid)
					if ptype==GameConst.GHOST_NPC then
						var.selectTab.npc=pid
					else
						var.selectTab.oth=pid
					end
					pixesGhost:addEffect("selected",res,-10,cc.p(TILE_WIDTH/2,-TILE_HEIGHT/2),4)
				end
			-- end
		end
	end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_SELECT_SOME_ONE,"select_some_one")

function GUIMain.onHideProgressbar(event)
	-- if var.progressBar then
	-- 	var.progressBar:stopAllActions()
	-- 	var.progressBar:setPercentage(0)
	-- end
	GUITopCenter.hideProgressBar()
	-- if var.progressPanel then
	-- 	var.progressPanel:setVisible(false)
	-- end
	-- GameSocket.m_bCollecting = false
	-- GameSocket.m_bReqMountUp = false
end

function GUIMain.onShowProgressbar(event,cbt)
	
	GUITopCenter.showProgressBar(event)
	-- if event then
	-- 	if not var.progressPanel then
	-- 		var.progressPanel = GUIAnalysis.load("ui/layout/DTPart.uif")
	-- 		var.progressPanel:align(display.CENTER, GameConst.VISIBLE_WIDTH/2, GameConst.VISIBLE_HEIGHT/3)
	-- 		:addTo(var.scene,9)
	-- 	end
	-- 	var.progressPanel:getWidgetByName("labtxt"):setString(event.info)

	-- 	if not var.progressBar then
	-- 		var.progressBar = display.newProgressTimer("#img_menu_HP", display.PROGRESS_TIMER_BAR)
	-- 		var.progressBar:setAnchorPoint(0.5,0.5)
	-- 		var.progressBar:setMidpoint(cc.p(0, 0.5))--设置进度条的起点，cc.p(0, 0.5)表示从最左边的中间为起点；
	-- 		var.progressBar:setBarChangeRate(cc.p(1.0, 0))--设置进度条变化速度，cc.p(1.0, 0)表示只在x轴上变化；
	-- 		var.progressBar:align(display.LEFT_TOP, 70,58)
	-- 		:addTo(var.progressPanel,10)
	-- 		:setPercentage(0)
	-- 	end

	-- 	if cbt and var.progressPanel:isVisible() then
	-- 		return
	-- 	end

	-- 	var.progressPanel:setVisible(true)
	-- 	GameSocket.m_bReqMountUp = true
	-- 	var.progressBar:runAction(
	-- 		cca.seq({
	-- 			cc.ProgressFromTo:create(event.time,0,100),
	-- 			cca.cb(
	-- 				function()
	-- 					var.progressPanel:setVisible(false)
	-- 					var.progressBar:setPercentage(0)
	-- 					GameSocket.m_bCollecting = false
	-- 					GameSocket.m_bReqMountUp = false
	-- 				end
	-- 			)
	-- 		})
	-- 	)
	-- end
end

function GUIMain.showAutoActionAnima(actionid,param)
	if var.curAcitonId == actionid or not var.scene then return end
	if not var.autoActionWidget then
		var.autoActionWidget = ccui.Widget:create()
			:align(display.CENTER, display.cx, display.cy - 80 )
			:addTo(var.scene)
		var.autoActionSprite = cc.Sprite:create()
			:align(display.CENTER, var.autoActionWidget:getContentSize().width * 0.5, var.autoActionWidget:getContentSize().height * 0.5)
			:addTo(var.autoActionWidget)
	end
	var.autoActionWidget:hide()
	var.autoActionSprite:stopAllActions()
	local animate = cc.AnimManager:getInstance():getPlistAnimate(4,actionid,4,4,false,false,0,function(animate,shouldDownload)
							if animate then 
								var.curAcitonId = actionid
								var.autoActionWidget:show() 
								var.autoActionSprite:runAction(cca.repeatForever(animate))
							end
							if shouldDownload==true then
								var.autoActionWidget:release()
								var.autoActionSprite:release()
							end
						end,
						function(animate)
							var.autoActionWidget:retain()
							var.autoActionSprite:retain()
						end)
	
end

function GUIMain.showTaskActionAnima(actionid)
	if not var.scene then return end
	local taskActionWidget = ccui.Widget:create()
		:align(display.CENTER, display.cx, display.cy)
		:addTo(var.scene, 100)

	local animate = cc.AnimManager:getInstance():getPlistAnimate(4,actionid,4,4,false,false,0,function(animate,shouldDownload)
							if animate then
								local taskActionSprite = cc.Sprite:create()
									:align(display.CENTER, 0, 200)
									:addTo(taskActionWidget)

								taskActionSprite:runAction(cca.seq({
									animate,
									cca.removeSelf()
								}))
							end
							if shouldDownload==true then
								taskActionWidget:release()
							end
						end,
						function(animate)
							taskActionWidget:retain()
						end)
	
end

function GUIMain.hideAutoActionAnima(actionid)
	if actionid == var.curAcitonId then
		if var.autoActionWidget then var.autoActionWidget:hide() end
		if var.directFlyWidget then var.directFlyWidget:hide() end
		if var.autoActionSprite then var.autoActionSprite:stopAllActions() end
		var.curAcitonId = nil
	end
end

function GUIMain.onSwitchTaskAnim(event)
	if event and event.effect_type then
		GUIMain.showTaskActionAnima(event.effect_type)
	end
end

function GUIMain.handleItemGotAnimation(event)
	if event and event.typeid then
		local itemdef = GameSocket:getItemDefByID(event.typeid)
		if itemdef then
			asyncload_callback("image/icon/"..itemdef.mIconID..".png", var.scene, function(filepath, texture)
				if GameCharacter._mainAvatar then
					local fromPos = GameCharacter._mainAvatar:getSprite():convertToWorldSpace(cc.p(0,0))
					local toPos = GameUtilSenior.getWidgetCenterPos(GUIMain.m_rbPartUI:getWidgetByName("main_bag"))

					local iconGhost = ccui.ImageView:create(filepath, ccui.TextureResType.localType)
						:align(display.CENTER, fromPos.x + TILE_WIDTH/2, fromPos.y - TILE_HEIGHT/2)
						:addTo(var.scene, 40)
					iconGhost:setScale(70 / iconGhost:getContentSize().width)
						:runAction(
							cca.seq({
								cca.moveTo(1, toPos.x, toPos.y),
								cca.removeSelf()
							})
						)
				end
			end)
		end
	end
end

function GUIMain.handleBuffGotAnimation(event)
	local buff_tab = {[0] = { path = "status_dun"},
					[7]  = "status_exp",
					[10] = "status_wu",
					[11] = "status_mo",
					[12] = "status_dao",
					[14] = "status_add_exp",
					[30] = "status_xue",
					[39] = "status_vip",
					[40] = "status_guild",
					[50] = "status_zs",
					[56] = "status_mount",
					[68] = "status_wing",
					[79] = "status_guild",
					[80] = "status_yuan",
	}
	if event and event.buff_id then
		if buff_tab[event.buff_id] then
			local fromPos = cc.p(display.cx,display.cy)
			local toPos = GameUtilSenior.getWidgetCenterPos(GUIMain.m_rtPartUI:getWidgetByName("main_buff"))

			local iconBg = ccui.ImageView:create("img_gezi_80", ccui.TextureResType.plistType)
				:align(display.CENTER, fromPos.x + TILE_WIDTH/2, fromPos.y - TILE_HEIGHT/2)
				:addTo(var.scene, 150)
			local res_path = event.buff_level and buff_tab[event.buff_id].."_"..event.buff_level or buff_tab[event.buff_id]
			
			asyncload_callback("image/icon/"..res_path..".png", iconGhost, function(filepath, texture)
				local iconGhost = ccui.ImageView:create()
				iconGhost:loadTexture(filepath)
					:align(display.LEFT_TOP,10,83)
					:addTo(iconBg)
				iconBg:setScale(70 / iconGhost:getContentSize().width)
					:runAction(
						cca.seq({
							cca.moveTo(1, toPos.x, toPos.y),
							cca.removeSelf()
						})
					)
			end)
		end
	end
end

function mainrole_auto_move(moveState, tx, ty)
	if moveState == 0 then
		GameBaseLogic.isAutoMove = false
		GUIMain.hideAutoActionAnima(50004)
		GameBaseLogic.aimPos = nil
	elseif moveState == 1 then
		GameBaseLogic.isAutoMove = true
		-- print("mainrole_auto_move", tx, ty, var.touchMap, GameCharacter._autoFight)
		if not var.touchMap and not GameCharacter._autoFight then
			GUIMain.showAutoActionAnima(50004)

			-- if var.directFlyWidget then var.directFlyWidget:hide() end

			--小飞鞋
			local flag
			if GameCharacter._mainAvatar then
				flag = GameCharacter._mainAvatar:PAttr(GameConst.AVATAR_AUTOMOVE_FLAG)
			end
			-- if GameCharacter._targetNPCName and GameCharacter._targetNPCName~="" then

				-- var.fly_x=tx
				-- var.fly_y=ty

				-- if not var.directFlyWidget and var.scene then
				-- 	var.directFlyWidget = ccui.Button:create()
				-- 		:align(display.CENTER, display.cx + 100, display.cy - 65 )
				-- 		:addTo(var.scene, 10)
				-- 	var.directFlyWidget:loadTextureNormal("image/icon/fly.png",ccui.TextureResType.localType)
				-- 	var.directFlyWidget:setTouchEnabled(true)
				-- 	var.directFlyWidget:addClickEventListener(function(pSender)
				-- 		if GameSocket.mCrossAutoMove and GameSocket.mTargetMap ~= "" then
				-- 			GameSocket:PushLuaTable("player.reqDirectFly",GameUtilSenior.encode({param={map_id=GameSocket.mTargetMap, x=GameSocket.mTargetMapX, y=GameSocket.mTargetMapY}}))
				-- 		elseif var.fly_x and var.fly_y then
				-- 			local map_id = GameSocket.mNetMap.mMapID
				-- 			GameSocket:PushLuaTable("player.reqDirectFly",GameUtilSenior.encode({param={map_id=map_id, x=var.fly_x, y=var.fly_y}}))
				-- 		end
				-- 	end)
				-- end

				-- var.directFlyWidget:show()
			-- end
		end
		var.touchMap = false
		-- 记录目标点
		if not (tx == 0 and ty == 0) then
			GameBaseLogic.aimPos = cc.p(tx, ty)
		end
	end

	-- if GameSocket.m_AutoMoveFlag == 9 and GameSocket.m_AutoMovePos and GameCharacter._mainAvatar:isReachedTarget(GameSocket.m_AutoMovePos) then
	-- 	var.m_pos_wabao = GameSocket.m_AutoMovePos
	-- 	GameSocket.m_AutoMovePos = nil
	-- 	-- GameSocket:dispatchEvent({name=GameMessageCode.EVENT_START_PROGRESS,time = 5,info="正在挖宝！"})
	-- 	GUIMain.onShowProgressbar({time = 5,info="正在挖宝！"},true)
	-- end
end

cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_MAINROLE_AUTOMOVE,"mainrole_auto_move")

function GUIMain.handleTaskFly(event)  --显示免费使用道具点击可以直接飞往目的地
	if true then
		return   --暂时不显示小飞鞋
	end
	if event and event.info then
		-- local flyId = event.info
		if not var.directFlyWidget and var.scene then
			var.directFlyWidget = ccui.Button:create()
				:align(display.CENTER, display.cx + 100, display.cy - 65 )
				:addTo(var.scene, 10)
			--var.directFlyWidget:loadTextureNormal("image/icon/fly.png",ccui.TextureResType.localType)
			
			asyncload_callback("image/icon/fly.png", var.directFlyWidget, function(path, texture)
				var.directFlyWidget:loadTextureNormal(path)
			end)
			
			var.directFlyWidget:setTouchEnabled(true)
			var.directFlyWidget:addClickEventListener(function(pSender)
				-- if GameCharacter._mainAvatar then GameCharacter._mainAvatar:clearAutoMove() end
				GameSocket:PushLuaTable("player.reqDirectFly",GameUtilSenior.encode({flyId = pSender.flyId}))
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_FLY})
			end)
		end
		var.directFlyWidget.flyId = event.info
		var.directFlyWidget:show()
	else
		if var.directFlyWidget then var.directFlyWidget:hide() end
	end
end
--[[
function GUIMain.initVoiceSetting()
	local VoiceModel = GameSetting.getConf("VoiceModel")
	local MicOnOrOff = GameSetting.getConf("MicOnOrOff")
	local SpkOnOrOff = GameSetting.getConf("SpkOnOrOff")
	local groupId = GameSocket.mCharacter.mGroupID
	
	-- GameCCBridge.logoutRoom()
	local guild_name = GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name)
	if guild_name and guild_name~="" or groupId and groupId>0 then
		local pGuild = GameSocket:getGuildByName(guild_name)
		if VoiceModel =="guild" and pGuild and pGuild.mGuildSeedId then
			-- GameCCBridge.loginRoom(pGuild.mGuildSeedId)
		elseif VoiceModel =="group" and groupId and groupId>0  then
			-- GameCCBridge.loginRoom(groupId)
		end
	end
end

function GUIMain.onVoiceModelChange(event)
	if event then
		local VoiceModel = GameSetting.getConf("VoiceModel")
		local netChat = {}
		netChat.m_strType = GameConst.str_chat_system
		netChat.m_uSrcId = 0
		if event.isLeader then
			netChat.m_strMsg = GameConst.str_you
		elseif VoiceModel =="guild" then
			netChat.m_strMsg = GameConst.str_guild_leader
		elseif VoiceModel =="guild" then
			netChat.m_strMsg = GameConst.str_gLeader
		end
		if event.model == "0" then
			netChat.m_strMsg = netChat.m_strMsg .. GameConst.str_change_voice_model1
		elseif event.model == "2" then
			if VoiceModel =="guild" then
				netChat.m_strMsg = netChat.m_strMsg .. GameConst.str_change_voice_model2
			elseif VoiceModel =="group" then
				netChat.m_strMsg = netChat.m_strMsg .. GameConst.str_change_voice_model3
			end
		end
		GUIMain.initVoiceSetting()
		self:addToMsgHistory(netChat)
	end
end
]]
-- function GUIMain.onVoiceSDKLogin(success,msg,voiceModel)
-- 	if success == "0" then
-- 		local VoiceModel = GameSetting.getConf("VoiceModel")
-- 		local MicOnOrOff = GameSetting.getConf("MicOnOrOff")
-- 		local SpkOnOrOff = GameSetting.getConf("SpkOnOrOff")
-- 		-- local VoiceAuthority = GameSetting.getConf("VoiceAuthority")
-- 		if voiceModel == "0" then
-- 			GameSetting.setConf("VoiceAuthority",1)
-- 		elseif voiceModel == "2" then
-- 			GameSetting.setConf("VoiceAuthority",2)
-- 		end
-- 		if MicOnOrOff then
-- 			-- GameCCBridge.openMic()
-- 		else
-- 			-- GameCCBridge.closeMic()
-- 		end
-- 		-- GameCCBridge.playAudio(SpkOnOrOff)
-- 	else
-- 		-- GameSocket:alertLocalMsg("语音服务器登录失败，请手动登录！", "alert")
-- 	end
-- end

function GUIMain.getCurHpIndex(ghost,perHp,all)
	local curIndex = all
	for i=1,all do
		if ghost:NetAttr(GameConst.net_hp) <= perHp*i then
			curIndex = i
			return curIndex
		end 
	end
	return 0
end

function GUIMain.onShakeScene(event)
	if var.scene and not var.isRunningAction then
		var.scene:stopAllActions()
		var.isRunningAction = true
		local times = 2
		var.scene:runAction(
			cca.seq({
				cca.rep(
					cca.seq({
						cca.moveBy(0.05, var.scene:getPositionX(), var.scene:getPositionY()-40),
						cca.moveBy(0.05, var.scene:getPositionX(), var.scene:getPositionY()+40)
						}),
					times
				),cca.cb(function()
					var.isRunningAction = false
				end)
			})
		)
	end
end

--像素点击判断
local speicalTouch = {
	41072,
	42024,
}
function check_touch_pos(mtype, cloth)
	if table.indexof(speicalTouch, cloth) then
		if GameCCBridge.getConfigString("platform_tag") == "rxsc" and GameCCBridge.getConfigString("version_code") == "0.6.3" then
			return false
		end
		return true
	end
end

local touchRect = {
	[41072] = {	--王城雕像
			["rectBottom"]	= cc.rect(31, 23, 204, 150),
			["rectBody"] 	= cc.rect(54, 143, 133, 234),
			},
	[42024] = {	--王城雕像
			["rectBottom"]	= cc.rect(31, 23, 150, 100),
			["rectBody"] 	= cc.rect(54, 143, 100, 150),
			},
}

function handleTouchPixels(cloth, x, y)
	if not table.indexof(speicalTouch, cloth) then
		return false
	end
	local temp = {"Bottom","Body"}
	print("Touch: X = "..x..", Y = "..y)
	for i = 1,#temp do
		if touchRect[cloth] and cc.rectContainsPoint(touchRect[cloth]["rect"..temp[i]], cc.p(x, y)) then
			return true
		end
	end
end

function GUIMain.handleHPMPChange(event)
	if var.scene then
		local deathNotice = var.scene:getChildByName("deathNotice")
		if not deathNotice then
			deathNotice = ccui.ImageView:create("ui/image/death_notice.png",ccui.TextureResType.localType)
				:setName("deathNotice")
				:setScale9Enabled(true)
				:setContentSize(display.width, display.height)
				:setAnchorPoint(cc.p(0.5,0.5))
				:setPosition(display.cx,display.cy)
				:addTo(var.scene)
				:setLocalZOrder(400)
				:stopAllActions()
				:hide()
		end
		if deathNotice and GameCharacter._mainAvatar  then
			local percent = GameCharacter._mainAvatar:NetAttr(GameConst.net_hp)/GameCharacter._mainAvatar:NetAttr(GameConst.net_maxhp)
			if 0== deathNotice:getNumberOfRunningActions() and percent<=0.2 and percent>0 and not GameSetting.getConf("ShieldRedWaring") then
				deathNotice:show():runAction(cca.repeatForever(cca.seq({
					cca.fadeIn(0.4),
					cca.fadeOut(0.4)
				})))
			elseif percent>0.2 or percent==0 or GameSetting.getConf("ShieldRedWaring") then
				deathNotice:stopAllActions():hide()
			end
		end
	end
end


return GUIMain