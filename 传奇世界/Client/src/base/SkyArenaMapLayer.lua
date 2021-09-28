local SkyArenaMapLayer = class("SkyArenaMapLayer", require("src/base/MainMapLayer.lua"))

local commConst = require("src/config/CommDef");

function SkyArenaMapLayer:ctor(str_name, parent, pos, mapId, isFb)

	cclog("[SkyArenaMapLayer:ctor] called. name = %s, map_id = %s.", str_name, mapId)

	self.parent = parent
	self.parent.map_layer = self
	self.isSkyArena = true
	self.roleLastPos=nil
	self.mode_state = 1
	self.time_count = 11
	self.auto_state = 1
	self.auto_target = 1
	self.isDead=false
	self.countDownNum=nil
	----------------------------------------------------------
	self.gameOver=false
	self.scheduler = cc.Director:getInstance():getScheduler()
	self.schedulerHandle = self.scheduler:scheduleScriptFunc(function() self:autoAttackUpdate() end,0, false)
	self:initializePre()
	self:loadMapInfo(str_name, mapId, pos)
	self.parent:addChild(self, -1)
	self:loadSpritesPre()

	local mapParentNode = cc.Node:create()
	self.mapNode = mapParentNode
	if parent and parent.base_node then
		--parent:addChild(mapParentNode,100)
        parent.base_node:addChild(mapParentNode, 100);
	end

	local funcUpdate = function()
		self:timeUpdate()
	end
	startTimerActionEx(mapParentNode, 1.0, true, funcUpdate)

	self.has_loadmap = true

	----------------------------------------------------------
	--能量显示
	local arenaEnergy=require("src/layers/skyArena/skyArenaEnergy").new(mapParentNode)
	self.arenaEnergy=arenaEnergy
	self.saInfoPanel = require("src/layers/skyArena/skyArenaInfo").new(mapParentNode)
	
	self.saResultPanel = nil
--	self.saResultPanel = require("src/layers/skyArena/skyArenaResult").new(mapParentNode)
--	self.saResultPanel:setVisible(false)


	self.blackLayer = cc.LayerColor:create(cc.c4b(10, 10, 10, 10))
	SwallowTouches(self.blackLayer)
	mapParentNode:addChild(self.blackLayer, 2)
	--隐藏装备技能等按钮
	if G_MAINSCENE.full_mode then
		G_MAINSCENE:setFullShortNode(false)
	end
	--去掉邮件提示
	if G_MAINSCENE and G_MAINSCENE.mailFlag then
      removeFromParent( G_MAINSCENE.mailFlag ) 
      G_MAINSCENE.mailFlag = nil 
    end
    --去掉玩法提醒
	if G_MAINSCENE and G_MAINSCENE.wftxFlag then
      removeFromParent( G_MAINSCENE.wftxFlag ) 
      G_MAINSCENE.wftxFlag = nil 
    end
    self.effInitNode = cc.Node:create()
	mapParentNode:addChild(self.effInitNode)
	self.monsterEffect={[652]="1",[653]="1",[654]="1",[655]="1"}
	require("src/layers/skyArena/skyArenaRelive"):resetDeadTimes()
end


function SkyArenaMapLayer:updateSA(param)

	if param == 1 then
		if self.saInfoPanel then
			self.saInfoPanel:updatePanelInfo()
		end
	elseif param == 2 then
        self.mode_state = 5;
        self.gameOver=true
        if G_MAINSCENE and G_ROLE_MAIN then
            G_MAINSCENE.map_layer:removeWalkCb();
		    game.setAutoStatus(0);

            if G_MAINSCENE.buffLayer then 
                removeFromParent(G_MAINSCENE.buffLayer);
				G_MAINSCENE.buffLayer = nil;
			end
        end

		if self.saResultPanel then
			self.saResultPanel:updatePanelInfo()
		else
            -- 结束3V3
            AudioEngine.playEffect("sounds/liuVoice/37.mp3", false);
			self.saResultPanel = require("src/layers/skyArena/skyArenaResult").new(self.mapNode )
		end
	end

end


function SkyArenaMapLayer:timeUpdate()
	if  self.gameOver then
		return
	end
	local mode_state = self.mode_state

	if mode_state == 1 then		-- init
		if self.effInitNode  then


			if self.timeNode==nil then
				local funcCB2=function ( ... )
					if self.mode_state==1 then
						self:playInitEffect(self.time_count)
						self.time_count = self.time_count - 1
					end
				end
				local funcCB=function ( ... )
					if self.mode_state==1 then
						if self.time_count>=4 then
							self:playInitEffect(self.time_count)
							if self.time_count==4 then
								startTimerActionEx(self.effInitNode, 1, true, funcCB2)
							end
							self.time_count = self.time_count - 1
						end
					end
				end
				self.timeNode=startTimerActionEx(self.effInitNode, 0.5, true, funcCB)
			end	
		end
		
		if self.time_count == 0 then
			removeFromParent(self.blackLayer)
			self.mode_state = 2
			self.time_count = 10

			if game then
				game.setMainRoleAttack(false)
			end
		end

	elseif mode_state == 2 then		-- second
		if self.effInitNode then
			self.effInitNode:removeFromParent()
			self.effInitNode=nil
		end
		if G_ROLE_MAIN:getPosition()~=self.roleLastPos then
			self.time_count=10
			self.roleLastPos=G_ROLE_MAIN:getPosition()
			return
		end
		if game.getAutoStatus()==AUTO_ATTACK and (self.select_role or self.select_monster or self.select_pet ) then
			self.time_count=10
			return
		end
		print("game.getAutoStatus()="..game.getAutoStatus())
		self.time_count = self.time_count - 1
		--print("self.time_count ="..self.time_count)
		if self.time_count == 0 then
			self.mode_state = 3
			self.auto_state=1
			print("[SkyArenaMapLayer:timeUpdate] convert to mode 3. auto attack.")
		end

		local bStopAutoAttack = self:checkStopAutoAttack()
		if bStopAutoAttack then
			self.mode_state = 4
			print(" mode_state == 2 [SkyArenaMapLayer:timeUpdate] convert to mode 4. manual attack.")
		end

	elseif mode_state == 3 then		-- auto attack

		

	elseif mode_state == 4 then     -- manual attack
		self.autoAttackTarget=nil
		
    else                            -- end

	end

end
function SkyArenaMapLayer:autoAttackUpdate()
	if  self.gameOver then
		return
	end
	if self.mode_state==3 then
		self:doAutoAttack()

		local bStopAutoAttack = self:checkStopAutoAttack()
		if bStopAutoAttack then
			self.mode_state = 4
			print("[SkyArenaMapLayer:timeUpdate] convert to mode 4. manual attack.")
		end
	elseif self.mode_state==4 then
		self.autoAttackTarget=nil
	end
	if self.mode_state~=3 and self.mode_state~=1 and self.mode_state~=2 then
		if game then
			game.setMainRoleAttack(false)
		end
		self.mode_state=2
		self.time_count = 10
	end
end
-----------------------------------------------------------

function SkyArenaMapLayer:playInitEffect(time_count)

	local centerX = display.cx
	local centerY = display.cy
	if time_count>1 then

		if time_count>1 and time_count<=4   then
			--startTimerAction(mapParentNode, 0.7, false, function()  
				local effect = Effects:create(false)
				self.effInitNode:addChild(effect,1)
				addEffectWithMode(effect, 1)
				effect:setPosition(cc.p(centerX, centerY))
				effect:setScale(1.613)
				effect:playActionData("beforebegin", 7, 0.9, 1)
			--end)
		end
	end
	if time_count<=10 then
		if self.countDownNum==nil then
			self.countDownNum =  createSprite( self.effInitNode , "res/layers/skyArena/count_down/count_down"..(time_count)..".png" , cc.p(centerX, centerY) , cc.p( 0.5 , 0.5 ),3)
		else
			self.countDownNum:setTexture("res/layers/skyArena/count_down/count_down"..(time_count)..".png")
			self.countDownNum:setScale(1)
			if time_count<=4 then
				local actions = {}
				actions[#actions+1] = cc.ScaleTo:create(1,1.3)
				self.countDownNum:stopAllActions()
				self.countDownNum:runAction(cc.Sequence:create(actions))
			end
		end
	end
	if time_count == 1 then

		
		local effect = Effects:create(false)
		effect:setAsyncLoad(false)
		self.effInitNode:addChild(effect)
		effect:setPosition(cc.p(centerX, centerY))
		effect:playActionData("begin", 14, 1.6, 1,0.1)
		effect:setScale(1.5)
		--开始3V3
		AudioEngine.playEffect("sounds/liuVoice/36.mp3", false)
	end

end

-----------------------------------------------------------

-- function SkyArenaMapLayer:showReliveLayer(objId)
-- 	cclog("[SkyArenaMapLayer:showReliveLayer] called. objId = %s.", objId)
-- 	if G_ROLE_MAIN and objId == G_ROLE_MAIN.obj_id then
-- 		local hp = MRoleStruct:getAttr(ROLE_HP)
-- 		if hp <= 0 then
-- 			self:showRelivePanel()
-- 		end
-- 	end
-- end

function SkyArenaMapLayer:showRelivePanel()
	if self.saRelivePanel == nil then
		self.autoAttackTarget=nil
		self.auto_state=1
		self.saRelivePanel = require("src/layers/skyArena/skyArenaRelive").new(self.mapNode)
	end
end
--公平竞技场箭塔破损效果
function SkyArenaMapLayer:showDamagedEffect(monsterNode,hp,roleMaxHp)
	local maxHp=monsterNode:getMaxHP()
	if roleMaxHp then
		maxHp=roleMaxHp
		--print("roleMaxHp="..roleMaxHp)
	end
	--print("公平竞技场箭塔破损效果更新".."hp="..hp.."maxHp="..maxHp)
	local monsterId=monsterNode:getMonsterId()
	if monsterId and self.monsterEffect[monsterId] and maxHp>0 then
		local effectName="basefire"
		if monsterId==652 or monsterId==655 then
			effectName="bartfire"
		end
		if hp/maxHp<0.4 then
			effectName=effectName.."2"
		elseif hp/maxHp<0.8 then
			effectName=effectName.."1"
		else
			return
		end
		if self.monsterEffect[monsterId]~=effectName or roleMaxHp then
			if self.monsterEffect[monsterId]~="1" then
				monsterNode:getTitleNode():removeChildByName(self.monsterEffect[monsterId])
			end
			local effect = Effects:create(false)
		    effect:setPlistNum(-1)
		    effect:setAnchorPoint(cc.p(0.5,0.5))
		    effect:setPosition(cc.p(0, 0))
		    if effectName=="bartfire1" then
		    	effect:setPosition(cc.p(20, -100))
		    	effect:setScale(1.05)
		    elseif  effectName=="bartfire2" then
		    	effect:setPosition(cc.p(40, -80))
		    	effect:setScale(1.1)
		    end
		    effect:playActionData2(effectName, 100, -1, 0)
		    effect:setName(effectName)
		    monsterNode:getTitleNode():addChild(effect, 101)
			self.monsterEffect[monsterId]=effectName
		end
		local effectNode=monsterNode:getTitleNode():getChildByName(effectName)
		if effectNode and hp==0 then
			effectNode:setPosition(cc.p(20, -230))
		end
	end
end

function SkyArenaMapLayer:hideRelivePanel()
	if self.saRelivePanel then
		removeFromParent(self.saRelivePanel)
		self.saRelivePanel = nil
		self.auto_state=1
	end
end

-----------------------------------------------------------

function SkyArenaMapLayer:checkStopAutoAttack()
	local bAttack = false
	if game then
		bAttack = game.getMainRoleAttack()
	end
	return bAttack
end

function SkyArenaMapLayer:stopAutoAttack()
	self.mode_state=4
end
function SkyArenaMapLayer:startAutoAttack()
	if self.select_role then
		self:touchRoleFunc(self.select_role, true)
		return
	end
	self.mode_state=3
	self.auto_state=1
	if game then
		game.setMainRoleAttack(false)
	end
	self:doAutoAttack()

end
function SkyArenaMapLayer:doAutoAttack()
	if  self.gameOver then
		return
	end
	if not G_ROLE_MAIN:isAlive() then
		return
	end
	if G_MAINSCENE.hang_node then
		G_MAINSCENE.hang_node:setOpacity(0)
        G_MAINSCENE.m_stopHangSpr:setVisible(true);
	end
	local stopDistance = 5
	local target_pos_1 = nil;
	local target_pos_2 = nil;
	local target_monid_1 = 0;
	local target_monid_2 = 0;
	local selfPos = nil;


	local schoolSelf = MRoleStruct:getAttr(ROLE_SCHOOL)
	if schoolSelf == 1 then
		stopDistance = 2
	end

	local selfTeamId = MRoleStruct:getAttr(PLAYER_TEAMID)

	local TeamIdA = 1
	if G_SKYARENA_DATA and G_SKYARENA_DATA.TeamData then
		if G_SKYARENA_DATA.TeamData.TA_id then
			TeamIdA = G_SKYARENA_DATA.TeamData.TA_id
		end
	end
	if selfTeamId == TeamIdA then
		target_pos_1 = cc.p(41, 24)
		target_pos_2 = cc.p(54, 13)

        -- 各自的对方箭塔本营
        target_monid_1 = commConst.PVP3V3_SELF_BARTIZAN_ID;
        target_monid_2 = commConst.PVP3V3_SELF_CAMP_ID;
	else
		target_pos_1 = cc.p(22, 39)
		target_pos_2 = cc.p(8, 49)

        -- 各自的对方箭塔本营
        target_monid_1 = commConst.PVP3V3_OTHER_BARTIZAN_ID;
        target_monid_2 = commConst.PVP3V3_OTHER_CAMP_ID;
	end
	--cclog("[SkyArenaMapLayer:doAutoAttack] selfTeamId = %s, TeamIdA = %s. tpos1(%s,%s), tpos2(%s,%s).",selfTeamId, TeamIdA, target_pos_1.x, target_pos_1.y, target_pos_2.x, target_pos_2.y)

	if G_ROLE_MAIN then
		local sPos = cc.p(G_ROLE_MAIN:getPosition())
		selfPos = self:space2Tile(sPos)
	end


	local state = self.auto_state
	

	-----------------------------------------------------------

	local checkPos = function(id)

		local checkPos = target_pos_1
		if id == 2 then
			checkPos = target_pos_2
		end

		if math.abs(selfPos.x - checkPos.x) <= stopDistance and math.abs(selfPos.y - checkPos.y) <= stopDistance then
			return true
		end

		return false
	end


	local getAttackTarget = function()

		local target_mon_2 = nil

		for k,v in pairs(self.monster_tab) do
			local monster_node = self:isValidStatus(v)

			if monster_node then
				local monId = monster_node:getMonsterId()

				if monId == target_monid_1 then
					local teamId = MRoleStruct:getAttr(PLAYER_TEAMID, v) or 0
					print("getAttackTarget monster 1 find. monTeamId = ."..teamId)
					if teamId ~= selfTeamId then
						if monster_node:isAlive() then
							print("箭塔活者")
							return monster_node
						else
							print("箭塔死了")
						end
					end
				elseif monId == target_monid_2 then
					local teamId = MRoleStruct:getAttr(PLAYER_TEAMID, v) or 0
					print("getAttackTarget monster 2 find. monTeamId = ."..teamId)
					if teamId ~= selfTeamId then
						if monster_node:isAlive() then
							target_mon_2 = monster_node
						end
					end
				end
			end
		end

		return target_mon_2
	end

	-- local autoTarget=getAttackTarget()
	-- if autoTarget then
	-- 	local monId = autoTarget:getMonsterId()
	-- 	if monId==target_monid_1 then
	-- 		self.auto_target=1
	-- 	elseif monId==target_monid_2 then
	-- 		self.auto_target=2
	-- 	end
	-- end
	local auto_target = self.auto_target
	-------------------------------------------------------

	if state == 1 then		-- idle

		local bCPos = checkPos(auto_target)

		if not bCPos then

			-- move to pos
			local destPos = target_pos_1
			if auto_target == 2 then
				destPos = target_pos_2
			end

			self:moveMapByPos(destPos, false)

			self.auto_state = 2

		else

			self.auto_state = 3

		end

	elseif state == 2 then	-- move
		local bCPos = checkPos(auto_target)
		if bCPos then
			print("到达地点，开始找目标")
			self:cleanAstarPath(true, true)
			self.auto_state = 3
		end

	elseif state == 3 then	-- attack

			local currTarget = self.autoAttackTarget

			if currTarget == nil then
				currTarget = getAttackTarget()

				if currTarget then
					print("选中目标，开始攻击")
					self:touchMonsterFunc(currTarget, true)
					game.setAutoStatus(AUTO_ATTACK)
					self.autoAttackTarget=currTarget
				else
					print("找不到目标，改成寻路")
					self.auto_state = 1
					self.auto_target = 2
				end
			else
				local bAlive = currTarget:isAlive()
				if not bAlive then
					-- stop auto attack
					self.autoAttackTarget = nil
					self.auto_target = 2
					print("箭塔死了，攻击营地")
					self.auto_state=1
					game.setAutoStatus(0)
				else 
					--print("xxxxxxxxxxxxx")
				end
			end

	elseif state == 4 then	-- finish
		--print("44444444444444444444")

	end

end

-----------------------------------------------------------
 --公平竞技场统一外观显示
function SkyArenaMapLayer:getclothes(school,sex )
	 local weaponId = getConfigItemByKeys("roleData", {"w_id","q_level"},{school,-1},"w_id")
    local clothesKey="cMen_id"
    if sex==2 then
        clothesKey="cWomen_id"
    end
    local clothesId = getConfigItemByKeys("roleData", {"w_id","q_level"},{school,-1},clothesKey)
    local wingId = getConfigItemByKeys("roleData", {"w_id","q_level"},{school,-1},"wing_id")
    return clothesId,weaponId,wingId
end
return SkyArenaMapLayer

