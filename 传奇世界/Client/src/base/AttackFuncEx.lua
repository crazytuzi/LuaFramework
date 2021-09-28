
local attackToPos = function(role_item,start_pos,dest_pos,times) 
	local dir = getDirBrPos(cc.p((dest_pos.x-start_pos.x),(dest_pos.y-start_pos.y)),role_item:getCurrectDir())
	role_item:setSpriteDir(dir)
	return role_item:attackOneTime(times,cc.p(0,0))
end

local isSafeAreaPlaySkill = function(skill_id)
	if skill_id == nil then
		return false
	end
	local pass_skill_id_list = {1008,3010,2004,2009,3006,3008,3007,3003,3012}
	for i = 1, #pass_skill_id_list do
		if skill_id == pass_skill_id_list[i] then
			return true
		end
	end
	return false
end

--统计安全日志一段时间内的攻击次数和最小攻击间隔时间
local lastCheckTime = 0
local attackTimes = 0
local g_svrStartTime = 0
local g_clientStartTime = 0
local myUpdate_checkAttack = nil
local timeAttackPrev = os.clock()
local timeAttackNext = 0
local timeDelta = 0

local function CountCDMin()
	attackTimes = attackTimes + 1
	
	timeAttackNext = os.clock()
    local newTimeDelta = math.ceil((timeAttackNext - timeAttackPrev)*1000.0)
    if newTimeDelta < timeDelta then
    	timeDelta = newTimeDelta
    end
    --print("CD min delta time is " .. timeDelta)
    timeAttackPrev = timeAttackNext
end

local function sendCheckSkillSpeedResult()
	local t = {}
	t.svrStartTime = g_svrStartTime
	t.clientStartTime = g_clientStartTime
	t.clientEndTime = os.time()
	t.skillTotal = attackTimes
	if attackTimes > 1 then
		t.skillCdMin = timeDelta
	else
		t.skillCdMin = 0
	end
	
	g_msgHandlerInst:sendNetDataByTable(SKILL_CS_SPEEDCHECK_END, "SkillSpeedCheckEnd", t)

	--print("SKILL_CS_SPEEDCHECK_END +++++++++++++++++++++++++++++++++")
	--print("result " .. "svrStartTime" .. t.svrStartTime .. "clientStartTime" .. t.clientStartTime .. "clientEndTime" .. t.clientEndTime 
		--.. "skillTotal" .. t.skillTotal .. "skillCdMin" .. t.skillCdMin)
end

local function updateAttackTimes()
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(myUpdate_checkAttack)
	sendCheckSkillSpeedResult()
end

onStartCheckClientSkillSpeed = function(svrStartTime, lastTime)
	--print("onStartCheckClientSkillSpeed Success ---------------")
	attackTimes = 0
    timeDelta = 60000
	g_svrStartTime = svrStartTime
	lastCheckTime = lastTime
	g_clientStartTime = os.time()
	myUpdate_checkAttack = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateAttackTimes, lastTime, false)
end

local roleStartToAttack = function(self,skillid,loop_time)
	self.stopNextSkill = false
	local role_item = G_ROLE_MAIN
	local state = role_item:getCurrActionState()
	local is_change_mode = role_item:isChangeModeDisplay()
	if state == ACTION_STATE_COLLIDE or state > ACTION_STATE_SPECAIL or is_change_mode then
		performWithDelay(self,function() self.on_attack = nil end,0)
		self.skill_todo = {} 
		self:removeWalkCb()
		if is_change_mode then
			self:resetHangup()
			TIPS( { type = 2 , str = "^c(red)变身状态无法使用伤害技能^" } )
		end
		return false
	end
	local area_R,attack_R = 16,8
	if self.isfb then area_R = 80 end 
	local target_node = nil
	local m_pos = nil
	local m_tile_pos = nil
	local effectRangeType = 1
	local m_name = MRoleStruct:getAttr(ROLE_NAME)
	local r_pos = cc.p(role_item:getPosition())
	local r_tile_pos = self:space2Tile(r_pos)
	local skill_times = {0.35, 0, 0, 0.5, 1.0}
	if (not skillid) or skillid ~= 2004 then
		if (self.select_role) or (skillid and (skillid>=7000 or skillid == 1005 or skillid == 1035 or  skillid == 1010 or  skillid == 1038))then
			self:removeWalkCb()
		elseif state==ACTION_STATE_WALK or state==ACTION_STATE_RUN then
			self:setRockDir(10)
			return false
		else
			self:removeWalkCb()
		end
	elseif skillid == 2004 then
		if not (state==ACTION_STATE_WALK or state==ACTION_STATE_RUN) then
			role_item:magicUpToPos(skill_times[4],cc.p(0,0))
		end
		if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
			skillid=2034
		end
		CountCDMin()
		g_msgHandlerInst:sendNetDataByTable(SKILL_CS_USESKILL, "SkillUseProtocol", {skillId=skillid,targetId=0,targetX=r_tile_pos.x,targetY=r_tile_pos.y})
		if (not self.common_cd) then
			G_MAINSCENE:doSkillAction(skillid)
		end
		resetGmainSceneTime()
		return true
	end
	self:setRockDir(10)
	if self:isInSafeArea(r_tile_pos) then
		if not isSafeAreaPlaySkill(skillid) then
			performWithDelay(self,function() self.on_attack = nil end,0)
			self.skill_todo = {}
			TIPS( getConfigItemByKeys("clientmsg",{"sth","mid"},{3000,-16})  ) 
			return false
		end
	end
	local m_loop_time = loop_time or 0
	if m_loop_time > 5 then
		if game.getAutoStatus() == AUTO_ATTACK then
			resetGmainSceneTime()
		end
		return false
	end
	m_loop_time = m_loop_time + 1
	local mp =  MRoleStruct:getAttr(ROLE_MP)
	local skill_id = skillid or self.c_skill_id
	if skill_id then
		local skill_info = getConfigItemByKey("SkillCfg","skillID",skill_id)
		if skill_info then
			attack_R = skill_info.useDistance
			effectRangeType = skill_info.effectRangeType
		end
	end
	local Hangup = require("src/base/HangUpFuncs")
	local isInRect = Hangup["isInRect"]
	local pkmode = require("src/layers/pkmode/PkModeLayer"):getCurMode()
	local select_node = require("src/base/SelectRoleLayer")
	local monster_tab = {}

	-- 有选中目标情况
	local sel_node = self.select_role or self.select_monster
	if sel_node then
		sel_node  = tolua.cast(sel_node,"SpriteMonster")
		if not (sel_node and sel_node:isAlive()) then
			self:resetTouchTag()
			sel_node = nil
		end
	end
	local unSend = nil
	local unsendTips = function(t_id,s_id) 
		unSend = true
		sel_node = nil
		TIPS( getConfigItemByKeys("clientmsg",{"sth","mid"},{s_id or 3000,t_id})  ) 
		--self:resetHangup()
		if t_id and t_id == -12 or t_id == -13 then
			if game.getAutoStatus() == AUTO_ATTACK then
				self.select_role = nil
			end
			self.stopNextSkill = true
		elseif getGameSetById(GAME_SET_ID_ELUDE_MONSTER) ~= 1 or getGameSetById(GAME_SET_SMARTFIGHT) == 0 then
			self:resetHangup()
		end
		performWithDelay(self,function() self.on_attack = nil end,0)
		self.skill_todo = {}
	end

	local m_teamId = MRoleStruct:getAttr(PLAYER_TEAMID)
	if self.select_monster and  tolua.cast(self.select_monster,"SpriteMonster") then
		local s_tag = self.select_monster:getTag()
		if not select_node:isCanAttackMonster(pkmode,s_tag) then
			self:resetSelectMonster()
			unsendTips(-12)
		else
			if m_teamId then
				local teamId = MRoleStruct:getAttr(PLAYER_TEAMID,s_tag)
				if (teamId and teamId == m_teamId) then
					self:resetSelectMonster()
				end
			end 
		end
	end
	local isDartMonster = function(m_id)
		local mode_id = MRoleStruct:getAttr(ROLE_MODEL,m_id)
		return mode_id >=80000 and mode_id <= 80003
	end
	--除镖车外 其他护送 自动不选
	for k,v in pairs(self.monster_tab)do
		local teamId = MRoleStruct:getAttr(PLAYER_TEAMID,v)
		if select_node:isCanAttackMonster(pkmode,v) and ((not teamId) or (self.mapID == 5005) or (((not m_teamId) or m_teamId ~= teamId) and isDartMonster(v))) then
			monster_tab[k] = v
		end
	end
	if sel_node and sel_node:isAlive() then
		if sel_node:getType() >= 20 then
			local sel_tile_pos = self:space2Tile( cc.p(sel_node:getPosition()))
			if not isInRect(sel_tile_pos,r_tile_pos,area_R) then
				sel_node = nil
			elseif self:isInSafeArea(r_tile_pos) then
				unsendTips(-15)
			elseif self:isInSafeArea(sel_tile_pos) then
				unsendTips(-14)
			elseif not select_node:isCanAttack(pkmode,sel_node:getTag()) then
				unsendTips(-12)
			end
		end
	else
		sel_node = nil	
	end
	local hasTheBuffById = function(obj_id,buff_id)
		local buffs = g_buffs_ex[obj_id]
	    if buffs == nil or buffs[buff_id] == nil or buffs[buff_id] <= 0  then
	      return false
	    else
	      return true
	    end
	end
	if sel_node and sel_node:getType() >= 20 and effectRangeType ~= 9 then 
		if hasTheBuffById(sel_node:getTag(),16) then
			unsendTips(-13)
		end
	end
	if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
		--无敌BUFF飘免疫两个字
		if sel_node then
			--print("无敌BUFF飘免疫两个字2sel_node:getTag()="..sel_node:getTag())
			local buffs=g_buffs[sel_node:getTag()]
			if buffs then
				for k, v in pairs(buffs) do
					--print("k="..k.."v="..v)
					if k==391 or k==335 then
						local monster_node =  tolua.cast(sel_node,"SpriteMonster")
						local chart = require("src/layers/char/CharText").new(monster_node:getTitleNode(), 3.0, HEADTEXT_IMMUNITY, cc.p(1, 1))
					end
				end
			end
		end
	end
	if effectRangeType == 9 then
		if pkmode == 1 or pkmode == 2 or pkmode == 5 then
			for k,v in pairs(self.role_tab)do 
				if not select_node:isCanAttack(pkmode,v,true) then
					monster_tab[k] = v 
				end
			end
		end
	elseif pkmode >= 1 then
		for k,v in pairs(self.role_tab)do 
			if select_node:isCanAttack(pkmode,v) then
				monster_tab[k] = v 
			end
		end
	elseif pkmode == 0 then
		if sel_node and sel_node:getType() >= 20 then
			unsendTips(-12)
		end
	end

	if not skillid then
		local taget_objId = nil
		if sel_node then taget_objId = sel_node:getTag() end
		local is_wait_attack = false
		skill_id,is_wait_attack = Hangup.getSkillId(taget_objId, sel_node,monster_tab)
		--如果公平竞技场，转换成公平竞技场可以用的技能
	   	if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
	   		--print("转换成公平竞技场可以用的技能")
			skill_id=Hangup.judgeIsArenaSkill(skill_id)
			--print("skyArenaSkillId="..skill_id)
		end
	end
	if not skill_id then return end

	if MRoleStruct:getAttr(ROLE_SCHOOL) == 1 then
		local has_lhbuff = hasTheBuffById(G_ROLE_MAIN.obj_id,126)
		if skill_id == 1006 and (not has_lhbuff) then
			--print("++++++++++sendSkill count openFire")
			g_msgHandlerInst:sendNetDataByTable(SKILL_CS_OPENFIRE,"SkillOpenFireProtocol",{skillId = 1006})
			return false
		elseif skill_id == 1036 and (not has_lhbuff) then
			g_msgHandlerInst:sendNetDataByTable(SKILL_CS_OPENFIRE,"SkillOpenFireProtocol",{skillId = 1036})
			return false
		elseif has_lhbuff and skill_id~=1005 and skill_id~=1035 and skill_id~=1010 and skill_id~=1038 and skill_id~=1008 then
			if getGameSetById(GAME_SET_ID_AUTO_DOUBLE_FIRE) == 1 then
				if G_ROLE_MAIN.double_fire then
					skill_id = 1006
					if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
						skill_id = 1036
					end
				end
			else
				skill_id = 1006
				if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
					skill_id = 1036
				end
			end
		end
	end
	local skillLv = self.skill_map and self.skill_map[skill_id] or 1

	if self.on_pickup and (state >= ACTION_STATE_IDLE and state < ACTION_STATE_HURT) then
		return
	elseif (not sel_node) and self:autoPickUp() then
		return
	elseif game.getAutoStatus() == AUTO_ATTACK and (not self:isHideMode()) and (not self.select_role) and G_MAINSCENE.hangup_tile and (not isInRect(G_MAINSCENE.hangup_tile,r_tile_pos,20 )) then
		self:resetSelectMonster()
		self:moveMapByPos(G_MAINSCENE.hangup_tile,false)
		return
	end
	if (not G_ROLE_MAIN:CanWarAttack()) and  G_ROLE_MAIN:upOrDownRide(false) and game.getAutoStatus() == AUTO_ATTACK then
		resetGmainSceneTime()
		return
	end
	if G_ROLE_MAIN.isHoe then G_ROLE_MAIN:isChangeToHoe(role_item, false) end
	local useMP = getConfigItemByKey("SkillLevelCfg","skillID",skill_id*1000+skillLv,"useMP")
	--print("useMP",useMP,"skill_id",skill_id,"mp",mp)
	if useMP and mp < useMP then-- and (not G_MAINSCENE.skill_cds[skill_id]) then
		if self.skill_todo[1] and skill_id==self.skill_todo[1] then
			table.remove(self.skill_todo,1)
		end
		TIPS( getConfigItemByKeys("clientmsg",{"sth","mid"},{3000,-24})  )
		return false
	end 
	local skill_info = getConfigItemByKey("SkillCfg","skillID",skill_id)
	if skill_info then
		attack_R = skill_info.useDistance
	end
	if skill_info and (skill_info.effectRangeType < 8 or skill_info.effectRangeType == 13) then
		if sel_node then
			m_tile_pos = sel_node:getServerTile()
			if isInRect(m_tile_pos,r_tile_pos,area_R) then
				target_node = sel_node
			else
				m_tile_pos = nil
			end
		else
			self:resetTouchTag()
			m_pos = nil
			m_tile_pos = nil
		end
		if not target_node and ( skill_info.effectRangeType ~= 4)then
			--print(" select target_node")
			if Hangup.noneed_getTarget then
				Hangup.noneed_getTarget = nil
			else
				target_node = Hangup.GetNearestNeighbor(nil,monster_tab)
			end
			-- if not target_node then
			-- 	TIPS( { type = 1 , str = "找不到可攻击的目标" } )
			-- end
		end
		if target_node and (game.getAutoStatus() == AUTO_ATTACK) and MRoleStruct:getAttr(ROLE_SCHOOL) == 3 and (skill_id ~= 3004 and skill_id ~= 3303 and skill_id ~= 3035 and skill_id ~= 3042) then
			local mtarget_tag = target_node:getTag()
			if target_node:getHP() > 1 and isSettingSkillSeted(3004) and (not hasTheBuffById(mtarget_tag,6)) then
				skill_id = Hangup.getSkillId(mtarget_tag,target_node,monster_tab)  
				skill_info = getConfigItemByKey("SkillCfg","skillID",skill_id)
				if skill_info then
					attack_R = skill_info.useDistance
				end
			end		
		end
	end
	if skill_info and skill_info.effectRangeType >= 8 and (skill_info.effectRangeType ~= 13) then
		if skill_info.effectRangeType == 9 then
			if (game.getAutoStatus() ~= AUTO_ATTACK) and  tolua.cast(self.select_role,"SpritePlayer") then
				target_node = self.select_role 
			else
				target_node = role_item
			end
		else
			target_node = role_item
		end
	end
	
	if target_node then
		sel_node = target_node 
		m_tile_pos = m_tile_pos or target_node:getServerTile()
		m_pos = self:tile2Space(m_tile_pos)
	end

	local sendSkill = function(skillId, monsterId,targets,target_id)
		if unSend then 
			return 
		end
		m_tile_pos = m_tile_pos or r_tile_pos
		--print("send skill",attack_id,monsterId,skillId,m_tile_pos.x,m_tile_pos.y,#targets)
	    --g_msgHandlerInst:sendNetDataByFmt(SKILL_CS_USESKILL,fat_str,G_ROLE_MAIN.obj_id,monsterId,skillId,m_tile_pos.x,m_tile_pos.y,1,monsterId)
	    --print("++++++++++sendSkill count")
	    CountCDMin()
	    g_msgHandlerInst:sendNetDataByTable(SKILL_CS_USESKILL, "SkillUseProtocol", {skillId=skillId,targetId=monsterId,targetX=m_tile_pos.x,targetY=m_tile_pos.y})
	    if G_ROLE_MAIN.double_fire and (skillId == 1006 or skillId == 1036) then
    		G_ROLE_MAIN.double_fire = G_ROLE_MAIN.double_fire + 1
    		g_buffs_ex[G_ROLE_MAIN.obj_id][126] = 0
    		if(G_ROLE_MAIN.double_fire >= 3)then
    			G_ROLE_MAIN.double_fire = nil
    		else
    			g_msgHandlerInst:sendNetDataByTable(SKILL_CS_OPENFIRE,"SkillOpenFireProtocol",{skillId = skillId})
    		end
    	end
    	if skillId == 1008 or skillId == 2009 or skillId == 3010 then
    		resetGmainSceneTime()
    	end
		local sex = MRoleStruct:getAttr(PLAYER_SEX)
		if  MRoleStruct:getAttr(ROLE_SCHOOL) == 1 then
			if skillId == 1006 or skillId == 1036 then
				if sex == 1 then
					AudioEnginer.playEffect("sounds/actionMusic/22222.mp3",false)
				elseif sex == 2 then
					AudioEnginer.playEffect("sounds/actionMusic/33333.mp3",false)
				end
				earthQuake(0.1,0.5)
			elseif skillId and skillId ~= 1005 and skillId ~= 1035 and skillId ~= 7000 then
			 	if 1 == math.floor(math.random(1,10)) then
			 		if sex == 1 then
						AudioEnginer.playEffect("sounds/actionMusic/22222.mp3",false)
					elseif sex == 2 then
						AudioEnginer.playEffect("sounds/actionMusic/33333.mp3",false)
					end
			 	end
			end
		end
		if (not self.common_cd) then
			G_MAINSCENE:doSkillAction(skillId)
		end
	end
	local do_attack = false
	target_node = tolua.cast(target_node,"SpriteMonster")
	if skill_info and skill_info.effectRangeType == 8 and target_node and target_node:isAlive() then --对自己释放
        --------------------------------------------------------------------------------------------------
		local whichAction = 1;
        local tmpRootD = CMagicCtrlMgr:getInstance():GetMagicRootD3(skill_id);
        if tmpRootD >= 0 then
            whichAction = tmpRootD % 10;
        elseif skill_info then
            -- 做攻击动作
            if skill_info.needStartHand == 0 then
                whichAction = 1;
            -- 做施法动作
            elseif skill_info.needStartHand == 1 then
                whichAction = 2;
            -- 不做动作
            elseif skill_info.needStartHand == 2 then
                whichAction = 0;
            end
        end
		if whichAction == 1 then
			do_attack=role_item:attackToPos(skill_times[1],m_pos)
		elseif whichAction == 2 then
			do_attack=role_item:magicUpToPos(skill_times[4],m_pos)
        elseif whichAction == 0 then    -- 不需要施法动作
            do_attack = true;
		end
		--------------------------------------------------------------------------------------------------
		
		if do_attack and skill_id ~= 2004 then
            if CMagicCtrlMgr:getInstance():IsMagicCanDisplay(skill_id) == 3 then
                local itmpDir = role_item:getCurrectDir();
                local iTmpSkillId = skill_id;
                if role_item:getOnRide() then
                    iTmpSkillId = 20000 + skill_id;
                end
                CMagicCtrlMgr:getInstance():CreateMagic(iTmpSkillId, 0, role_item:getTag(), target_node:getTag(), itmpDir);
            else
			    self:playSkillEffect(0.15,skill_id,role_item,target_node)
            end
		else
			self.parent:doSkillAction(skill_id) -------------------------------------------
		end
		sendSkill(skill_id,target_node:getTag(),{target_node})
		return true
	end
	local pushFunc = function(buff,fat,...)
	  if buff then
	  	buff:writeByFmt(fat,...)
	  end
	end
	if skill_info and skill_info.effectRangeType == 4 or skill_id == 3009 or skill_id == 3039 then
		if unSend then return true end 
		local title_scale = 2
		--local sel_node = tolua.cast(self.select_role or self.select_monster,"SpriteMonster")
		--剧情中播放推人技能是需要预选好目标方向
		if sel_node then
	        if skill_id == 3009 or skill_id == 3039 then
	        	title_scale = 1
	            role_item:setDirByNowPoint(m_pos or self:tile2Space(m_tile_pos))
	        else
	        	if (getGameSetById(GAME_SET_AUTOCRASHKILL) == 0 or game.getAutoStatus() == AUTO_ATTACK) and isInRect(m_tile_pos,r_tile_pos,1) then
					role_item:setDirByNowPoint(m_pos or self:tile2Space(m_tile_pos))
				end
			end
		end
        --野蛮冲撞
		local dir = role_item:getCurrectDir()
		local span_pos = self:getTileByDir(dir)		
		--local luaEventMgr = LuaEventManager:instance()
		--local mbuff = luaEventMgr:getLuaEvent(SKILL_CS_CRASHSKILL)
		local dest_tile_pos = cc.p(r_tile_pos.x+span_pos.x*title_scale,r_tile_pos.y+span_pos.y*title_scale)
		--pushFunc(mbuff,"isssc",role_item:getTag(),dest_tile_pos.x,dest_tile_pos.y,skill_id,0)
		--print("++++++++++sendSkill count crash")
		CountCDMin()
		g_msgHandlerInst:sendNetDataByTable(SKILL_CS_CRASHSKILL, "SkillCrashProtocol", {skillId=skill_id,x=dest_tile_pos.x,y=dest_tile_pos.y})
		self:cleanAstarPath(true,true)
		role_item:changeState(ACTION_STATE_MABI)
		local resetState = function()
			local item = tolua.cast(role_item,"SpritePlayer")
			if item then
				if item:getCurrActionState() == ACTION_STATE_MABI then
					item:standed()
				end
			end
		end
		performWithDelay(self,resetState,1)
    	--LuaSocket:getInstance():sendSocket(mbuff)
		--if (not self.common_cd) then
			G_MAINSCENE:doSkillAction(skill_id)
		--end
		return true
	elseif skill_id == 2005 or skill_id == 2035 then
		if unSend then return true end 
		local mbuff = nil
		if not self:isInSafeArea(r_tile_pos) then
			--print("++++++++++sendSkill count crash")
			CountCDMin()
			g_msgHandlerInst:sendNetDataByTable(SKILL_CS_CRASHSKILL, "SkillCrashProtocol", {skillId=skill_id,x=r_tile_pos.x,y=r_tile_pos.y})
			self:cleanAstarPath(true,true)
			role_item:changeState(ACTION_STATE_MABI)
			local resetState = function()
				local item = tolua.cast(role_item,"SpritePlayer")
				if item then
					if item:getCurrActionState() == ACTION_STATE_MABI then
						item:standed()
					end
				end
			end
			performWithDelay(self,resetState,1)  			
			if (not self.common_cd) then
				G_MAINSCENE:doSkillAction(skill_id)
			end
		else
			unsendTips(-16)
		end
		return true
	end

	if m_tile_pos and isInRect(m_tile_pos,r_tile_pos,attack_R) or (skillid == 2003) then
		if self:getRockDirSet() then
			local func = function()
				self:removeWalkCb()
				if self:roleStartToAttack(skill_id,m_loop_time) then
					self.parent:doSkillAction(skill_id,nil,cd)
				end
			end
			self:registerWalkCb(func)
			self:setAttackFlag(true)
			return false
		elseif state==ACTION_STATE_WALK or state==ACTION_STATE_RUN or state > ACTION_STATE_CREATE then
			return false
		end
		if m_tile_pos and skill_info and (r_tile_pos.x == m_tile_pos.x and r_tile_pos.y == m_tile_pos.y) and (skill_info.effectRangeType < 8) then
			local dir = math.ceil(math.random(1,8))
			local dir_map = {{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1},{0,-1},{1,-1}}
			local can_move_pos = cc.p(r_tile_pos.x-dir_map[dir][1],r_tile_pos.y-dir_map[dir][2])
			while self:isBlock(can_move_pos) and dir < 8 do
				dir = dir + 1
				can_move_pos = cc.p(r_tile_pos.x-dir_map[dir][1],r_tile_pos.y-dir_map[dir][2])
			end	
			local func = function()
				self:removeWalkCb()
				if self.common_cd then return end
				local cd = nil
				if (skill_id == 1006 or skill_id == 1036) and hasTheBuffById(G_ROLE_MAIN.obj_id,126) then
					cd = 0.9
				end
				if skillid and self:roleStartToAttack(skill_id,m_loop_time) then
					self.parent:doSkillAction(skill_id,nil,cd)
					resetGmainSceneTime()
				end
			end
			self:registerWalkCb(func)
			self:moveMapByPos(can_move_pos,false)
			return false
		end 
		local ride_skills = {[1050]=true,[1051]=true,[2050]=true,[2051]=true,[3050]=true,[3051]=true}
		if ride_skills[skillid] then
			--骑战技能
			--print("++++++++++sendSkill count")
			CountCDMin()

            --print("do skill",skillid,m_tile_pos.x,m_tile_pos.y);
            local tmpTargetGuid = 0;
            if target_node then
                tmpTargetGuid = target_node:getTag();
            end
			g_msgHandlerInst:sendNetDataByTable(SKILL_CS_USESKILL, "SkillUseProtocol", {skillId=skillid, targetId=tmpTargetGuid, targetX=m_tile_pos.x, targetY=m_tile_pos.y})

            if skillid == 3050 then
                local whichAction = 1;
                local tmpRootD = CMagicCtrlMgr:getInstance():GetMagicRootD3(skill_id);
                if tmpRootD >= 0 then
                    whichAction = tmpRootD % 10;
                elseif skill_info then
                    -- 做攻击动作
                    if skill_info.needStartHand == 0 then
                        whichAction = 1;
                    -- 做施法动作
                    elseif skill_info.needStartHand == 1 then
                        whichAction = 2;
                    -- 不做动作
                    elseif skill_info.needStartHand == 2 then
                        whichAction = 0;
                    end
                end
		        if whichAction == 1 then
			        do_attack=role_item:attackToPos(skill_times[1],m_pos)
		        elseif whichAction == 2 then
			        do_attack=role_item:magicUpToPos(skill_times[4],m_pos)
                elseif whichAction == 5 then
                    do_attack=role_item:AttackDSUpToPos(skill_times[5],m_pos)
                elseif whichAction == 0 then    -- 不需要施法动作
                    do_attack = true;
		        end

                local itmpDir = MapView:GetDirByPos(r_pos, m_pos)           		
                CMagicCtrlMgr:getInstance():CreateMagic(skillid, 0, role_item:getTag(), target_node:getTag(), itmpDir);
            else
                self:cleanAstarPath(true,true)
                role_item:changeState(ACTION_STATE_MABI)
                local resetState = function()
	                local item = tolua.cast(role_item,"SpritePlayer")
	                if item then
		                if item:getCurrActionState() == ACTION_STATE_MABI then
			                item:standed()
		                end
	                end
                end

                -- 骑战恢复 standed 
                local mabiTime = 1.5;

                performWithDelay(self,resetState,mabiTime);
            end

            G_MAINSCENE:doSkillAction(skillid)
		elseif not unSend then
			target_node = tolua.cast(target_node,"SpriteMonster")
			if not m_pos then m_pos = r_pos end

            --------------------------------------------------------------------------------------------------
		    local whichAction = 1;
            local tmpRootD = CMagicCtrlMgr:getInstance():GetMagicRootD3(skill_id);
            if tmpRootD >= 0 then
                whichAction = tmpRootD % 10;
            elseif skill_info then
                -- 做攻击动作
                if skill_info.needStartHand == 0 then
                    whichAction = 1;
                -- 做施法动作
                elseif skill_info.needStartHand == 1 then
                    whichAction = 2;
                -- 不做动作
                elseif skill_info.needStartHand == 2 then
                    whichAction = 0;
                end
            end
		    if whichAction == 1 then
			    if not m_pos then m_pos = self:tile2Space(m_tile_pos) end
				do_attack = attackToPos(role_item,r_pos,m_pos,skill_times[1])
		    elseif whichAction == 2 then
			    local dir = getDirBrPos(cc.p((m_pos.x-r_pos.x),(m_pos.y-r_pos.y)),role_item:getCurrectDir())
				role_item:setSpriteDir(dir)
				do_attack=role_item:magicUpToPos(skill_times[4],cc.p(0,0))
            elseif whichAction == 0 then
                do_attack = true;
		    end
		    --------------------------------------------------------------------------------------------------

			if do_attack and skill_id ~= 2004 then
	            if target_node and target_node:isAlive() then
		            if CMagicCtrlMgr:getInstance():IsMagicCanDisplay(skill_id) == 3 then
		                local itmpDir = MapView:GetDirByPos(r_pos, m_pos)
                        if skill_id == 1000 or skill_id == 1001 then	            		
                            local iTmpSkillId = skill_id;
                            if role_item:getOnRide() then
                                iTmpSkillId = 20000 + skill_id;
                            end            		
                            CMagicCtrlMgr:getInstance():CreateMagic(iTmpSkillId, 0, role_item:getTag(),target_node:getTag(), itmpDir);
		            		performWithDelay(self,function() 
		            				AudioEnginer.playEffect("sounds/skillMusic/1000.mp3",false) 
		            		end,0.3)
                        elseif skill_id == 2202 or skill_id == 2040 then
                            -- 获取自身强化小火球等级
                            local iFireBallNum = 2;
                            if G_ROLE_MAIN and G_ROLE_MAIN.skills then
                                local iTmpLevel = 0;
                                for i = 1, #G_ROLE_MAIN.skills do
                                    if G_ROLE_MAIN.skills[i][1] == 2202 then
                                        iTmpLevel = G_ROLE_MAIN.skills[i][2];
                                        break;
                                    end
                                end                              
                                
                                local skillLevelInfo = getConfigItemByKey("SkillLevelCfg", "skillID", 2202*1000+iTmpLevel);
                                if skillLevelInfo then
                                    -- 初级、中级、高级强化火球连续释放2个火球
                                    if(skillLevelInfo.skill_color <= 3) then
							            iFireBallNum = 2;
                                    -- 专家级、大师级强化火球连续释放3个火球
						            elseif(skillLevelInfo.skill_color >=4 and skillLevelInfo.skill_color<= 5) then
							            iFireBallNum = 3;
                                    -- 宗师级、权威级强化火球连续释放4个火球
						            elseif(skillLevelInfo.skill_color >=6 and skillLevelInfo.skill_color<= 7) then
							            iFireBallNum = 4;
                                    -- 王者级强化火球连续释放5个火球
						            else
							            iFireBallNum = 5;
                                    end
                                end
                            end

                            CMagicCtrlMgr:getInstance():CreateMagic(2202, 0, role_item:getTag(),target_node:getTag(), itmpDir);
                            for i = 0, iFireBallNum - 2, 1 do
						        CMagicCtrlMgr:getInstance():CreateMagic(60001 + i, 0, role_item:getTag(),target_node:getTag(), itmpDir);
					        end
                        else
		                   local iTmpSkillId = skill_id;
                            if role_item:getOnRide() then
                                iTmpSkillId = 20000 + skill_id;
                            end
		                    CMagicCtrlMgr:getInstance():CreateMagic(iTmpSkillId, 0, role_item:getTag(),target_node:getTag(), itmpDir);
		            	end
                        
		            else		            	
					   self:playSkillEffect(0.15,skill_id,role_item,targ_node,m_pos)
		            end
		            if skill_id == 2003 and (not isInRect(m_tile_pos,r_tile_pos,attack_R)) then
		            	performWithDelay(self,function() self.on_attack = nil end,0)
		            end
		        elseif skill_id == 2003 then
		        	local itmpDir = role_item:getCurrectDir()
		            local iTmpSkillId = 2003;
                    if role_item:getOnRide() then
                        iTmpSkillId = 20000 + 2003;
                    end
		            CMagicCtrlMgr:getInstance():CreateMagic(iTmpSkillId, 0, role_item:getTag(),role_item:getTag(), itmpDir)
		            performWithDelay(self,function() self.on_attack = nil end,0)
		        end
			end
			
			if do_attack and sendSkill and target_node and target_node:isAlive() or (skillid == 2003) then
				local target_tag = 0 
				if target_node then 
					target_tag = target_node:getTag()
				end			
				sendSkill(skill_id,target_tag, {target_node})
			end
		end
		return true
	elseif m_tile_pos and isInRect(m_tile_pos,r_tile_pos,area_R) and (skill_id~=2004) and (skillid ~= 2003) then	
			local func = function()
				self:removeWalkCb()
				if self.common_cd then return end
				local cd = nil
				if (skill_id == 1006 or skill_id == 1036) and hasTheBuffById(G_ROLE_MAIN.obj_id,126) then
					cd = 0.9
				end
				if self:roleStartToAttack(skill_id,m_loop_time) then
					self.parent:doSkillAction(skill_id,nil,cd)
					resetGmainSceneTime()
				end
			end
			--print("registerWalkCb")
			local can_attack_pos = m_tile_pos
			local is_near = false
			if attack_R == 1 then
				is_near = true
			else
				local dir = getDirBrPos(cc.p((m_tile_pos.x-r_tile_pos.x),(m_tile_pos.y-r_tile_pos.y)))+1
				local dir_map = {{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1},{0,-1},{1,-1}}
				can_attack_pos = cc.p(m_tile_pos.x-dir_map[dir][1]*attack_R,m_tile_pos.y-dir_map[dir][2]*attack_R)
				while self:isBlock(can_attack_pos) do
					if attack_R > 1 then
						attack_R = attack_R - 1
						can_attack_pos = cc.p(m_tile_pos.x-dir_map[dir][1]*attack_R,m_tile_pos.y-dir_map[dir][2]*attack_R)
					else 
						can_attack_pos = m_tile_pos
						is_near = true
						break
					end
				end
			end
			if self.select_role and m_pos then
				local dir = getDirBrPos(cc.p((m_pos.x-r_pos.x),(m_pos.y-r_pos.y)),role_item:getCurrectDir())
				self:setRockDir(dir)
				if skill_id == 2003 and (game.getAutoStatus() == AUTO_ATTACK) then  skill_id = nil end	 
				if self.rock_action then
					self.item_Node:stopAction(self.rock_action)
					self.rock_action = nil
				end
				self.rock_action = performWithDelay(self.item_Node,function() 
					self.rock_action = nil
					if self:roleStartToAttack(skill_id,m_loop_time) then
						resetGmainSceneTime()
					end
					end,0.08)
			else
				self:registerWalkCb(func)
				self:moveMapByPos(can_attack_pos,is_near)
				local checkPath = function()
					if self:getRolePathNum() > 22 then
						self:resetSelectMonster()
						self:cleanAstarPath(true,true)
					end
					self.rock_action = nil
				end
				if game.getAutoStatus() == AUTO_ATTACK then
					if self.rock_action then
						self.item_Node:stopAction(self.rock_action)
						self.rock_action = nil
					end
					self.rock_action = performWithDelay(self,checkPath,0.1)
				end
			end
		--end
	elseif skillid and (game.getAutoStatus() ~= AUTO_ATTACK) then
		if state ~= ACTION_STATE_EXCAVATE then
            
            --------------------------------------------------------------------------------------------------
		    local whichAction = 1;
            local tmpRootD = CMagicCtrlMgr:getInstance():GetMagicRootD3(skill_id);
            if tmpRootD >= 0 then
                whichAction = tmpRootD % 10;
            elseif skill_info then
                -- 做攻击动作
                if skill_info.needStartHand == 0 then
                    whichAction = 1;
                -- 做施法动作
                elseif skill_info.needStartHand == 1 then
                    whichAction = 2;
                -- 不做动作
                elseif skill_info.needStartHand == 2 then
                    whichAction = 0;
                end
            end
		    if whichAction == 1 then
			    do_attack=role_item:attackToPos(skill_times[1],{x=0,y=0})
		    elseif whichAction == 2 then
			    do_attack=role_item:magicUpToPos(skill_times[4],{x=0,y=0})
            elseif whichAction == 0 then
                do_attack = true;
		    end
		    --------------------------------------------------------------------------------------------------
			
			if do_attack then

				--self.parent:doSkillCdAction(skill_id)
				if skill_id ~= 2004 then
	                if CMagicCtrlMgr:getInstance():IsMagicCanDisplay(skill_id) == 3 then
                        if skill_id == 2202 then
                            -- 获取自身强化小火球等级
                            local iFireBallNum = 2;
                            if G_ROLE_MAIN and G_ROLE_MAIN.skills then
                                local iTmpLevel = 0;
                                for i = 1, #G_ROLE_MAIN.skills do
                                    if G_ROLE_MAIN.skills[i][1] == 2202 then
                                        iTmpLevel = G_ROLE_MAIN.skills[i][2];
                                        break;
                                    end
                                end

                                local skillLevelInfo = getConfigItemByKey("SkillLevelCfg", "skillID", 2202*1000+iTmpLevel);
                                if skillLevelInfo then
                                    if(skillLevelInfo.skill_color <= 3) then
							            iFireBallNum = 2;
						            elseif(skillLevelInfo.skill_color >=4 and skillLevelInfo.skill_color<= 5) then
							            iFireBallNum = 3;
						            elseif(skillLevelInfo.skill_color >=6 and skillLevelInfo.skill_color<= 7) then
							            iFireBallNum = 4;
						            else
							            iFireBallNum = 5;
                                    end
                                end
                            end

                            CMagicCtrlMgr:getInstance():CreateMagic(2202, 0, role_item:getTag(), 0, 0);
                            for i = 0, iFireBallNum - 2, 1 do
						        CMagicCtrlMgr:getInstance():CreateMagic(60001 + i, 0, role_item:getTag(), 0, 0);
					        end
                        else
	                        local iTmpSkillId = skill_id;
                            if role_item:getOnRide() then
                                iTmpSkillId = 20000 + skill_id;
                            end

                            CMagicCtrlMgr:getInstance():CreateMagic(iTmpSkillId, 0, role_item:getTag(), 0, 0);
                        end
	                else
					    self:playSkillEffect(0.15,skill_id,role_item)
	                end
				end
			end
			self.skill_todo = {}
			if skill_id~=1006 and skill_id~=1036 then
				G_MAINSCENE:doSkillAction(skill_id)
			end
		end
		return true
	end
	return false
end


return roleStartToAttack