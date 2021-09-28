
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

local roleStartToAttack = function(self,skillid)  
    if G_ROLE_MAIN == nil then
        return
    end

    --剧情中，一秒内技能只能放一次
    if self.isStory and G_MAINSCENE and G_MAINSCENE.storyNode then
        local lastTime = G_MAINSCENE.storyNode.m_lastAttackTime
        if lastTime then
            local curTime = os.time()
            if curTime >= lastTime and curTime < lastTime + 1 then
            	self:setRockDir(10)
                return false
            end
        end
    end
    
    self.stopNextSkill = false
    local MRoleStruct = require("src/layers/role/RoleStruct")
	local role_item = G_ROLE_MAIN
	local state = role_item:getCurrActionState()
	if skillid ~= 2004 then
		if state == ACTION_STATE_COLLIDE or state > ACTION_STATE_SPECAIL  then 
			self:removeWalkCb()
			return false
		elseif (self.select_role) or (skillid and (skillid>=7000 or skillid == 1005 or skillid == 1035 or  skillid == 1010 or  skillid == 1038))then
			self:removeWalkCb()
		elseif state==ACTION_STATE_WALK or state==ACTION_STATE_RUN then
			self:setRockDir(10)
			return false
		else
			self:removeWalkCb()
		end
	end
	self:setRockDir(10)
	local area_R,attack_R = 16,8
	if self.isfb then area_R = 80 end 
	local target_node = nil
	local m_pos = nil
	local monster_id = nil
	local effectRangeType = 1
	local m_name = MRoleStruct:getAttr(ROLE_NAME)
	local r_pos = cc.p(role_item:getPosition())
	local r_tile_pos = self:space2Tile(r_pos)

	if self:isInSafeArea(r_tile_pos) then
		if not isSafeAreaPlaySkill(skillid) then
			self.on_attack = nil
			self.skill_todo = {}
			return false
		end
	end
	--print("roleStartToAttack: 000000")
	local mp =  MRoleStruct:getAttr(ROLE_MP)
	local skill_id = skillid or self.c_skill_id
	if skill_id then
		local skill_info = getConfigItemByKey("SkillCfg","skillID",skill_id)
		if skill_info then
			attack_R = skill_info.useDistance
			effectRangeType = skill_info.effectRangeType
		end
	end
	local isInRect = function(pos1,pos2,r,h_type)
		if h_type then
			--log("h_type1.."..h_type)
			if h_type == 6 or  h_type == 7 then
				r = h_type-5
			elseif h_type == 5 then
				r = 1
			elseif h_type == 10 then
				r = 16
			elseif h_type == 9 then
				r = 2
			elseif h_type == 2 then
				if target_node then
					local taget_pos = self:space2Tile(cc.p(target_node:getPosition()))
					if (taget_pos.x-pos1.x == pos2.x-taget_pos.x and taget_pos.y-pos1.y == pos2.y-taget_pos.y)
						or (taget_pos.x==pos1.x and taget_pos.y==pos1.y) then
						return true
					end
				end
				return false
			elseif h_type == 3 then
				if math.abs(pos1.x-pos2.x) <= 1 and math.abs(pos1.y-pos2.y) <= 1 then
					return true
				end
				return false
			else
				return false
			end
		end
		--log("h_type"..r)
		if r and math.abs(pos1.x-pos2.x) <= r and math.abs(pos1.y-pos2.y) <= r then
			return true
		end
		return false
	end
	local pkmode = require("src/layers/pkmode/PkModeLayer"):getCurMode()
	local monster_tab = {}
	local m_teamId = MRoleStruct:getAttr(PLAYER_TEAMID)
	if m_teamId then
		for k,v in pairs(self.monster_tab)do
			local teamId = MRoleStruct:getAttr(PLAYER_TEAMID,v)
			if not (teamId and teamId == m_teamId) then
				monster_tab[k] = v
			end
		end
		if self.select_monster and  tolua.cast(self.select_monster,"SpriteMonster") then
			local teamId = MRoleStruct:getAttr(PLAYER_TEAMID,self.select_monster:getTag())
			if (teamId and teamId == m_teamId) then
				self.select_monster = nil
			end
		end
	else
		for k,v in pairs(self.monster_tab)do
			monster_tab[k] = v
		end	
	end
	-- 有选中目标情况
    if self.isStory then
        if self.select_role and not G_MAINSCENE.storyNode:isMonster(self.select_role) then
            self.select_role = nil
        end

        if self.select_monster and not G_MAINSCENE.storyNode:isMonster(self.select_monster) then
            self.select_monster = nil
        end
    end

	local sel_node = self.select_role or self.select_monster
	if sel_node then
		sel_node  = tolua.cast(sel_node,"SpriteMonster")
		if not (sel_node and sel_node:isAlive()) then
			self:resetTouchTag()
            if self.isStory then
                return
            end
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
		self.on_attack = nil
		self.skill_todo = {}
	end
	if sel_node and sel_node:isAlive() then
		if sel_node:getType() >= 20 then
			local sel_tile_pos = self:space2Tile( cc.p(sel_node:getPosition()))
			if not isInRect(sel_tile_pos,r_tile_pos,attack_R) then
				sel_node = nil
			elseif self:isInSafeArea(r_tile_pos) then
				unsendTips(-15)
			elseif self:isInSafeArea(sel_tile_pos) then
				unsendTips(-14)
			end
		end
	else
		sel_node = nil	
	end
	local hasTheBuffById = function(obj_id,buff_id)
		local buffs = g_buffs_ex[obj_id]
	    if buffs == nil or buffs[buff_id] == nil then
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

	local select_node = require("src/base/SelectRoleLayer")
    if self.isStory then
    --    if self.select_role and not G_MAINSCENE.storyNode:isMonster(self.select_role) then
    --        self.select_role = nil
    --    end
        
        if G_MAINSCENE.storyNode.playerTab and G_MAINSCENE.storyNode.playerTab[2] then
            for k,v in pairs(G_MAINSCENE.storyNode.playerTab[2])do 
			    monster_tab[v:getTag()] = v:getTag() 
	        end
        end     
	elseif effectRangeType == 9 then
		if pkmode == 1 or pkmode == 2 or pkmode == 5 then
			for k,v in pairs(self.role_tab)do 
				if not select_node:isCanAttack(pkmode,v,true) then
					monster_tab[k] = v 
				end
			end
		end
	else
		for k,v in pairs(self.role_tab)do 
			local can_attack,iswudi = select_node:isCanAttack(pkmode,v)
			if can_attack or (iswudi) then
				monster_tab[k] = v 
			elseif sel_node and sel_node:getTag() == v then
				unsendTips(-12)
			end
		end
	end

	if (not skillid) and (not self:isHideMode()) and (not self.select_monster) and DATA_Mission then
		monster_id = DATA_Mission:getTaskMonsterID()
		--print("monster_id:"..tostring(monster_id))
	end
	if not skillid then
		local Hangup = require("src/base/HangUpFuncs")
		local taget_objId = nil
		if MRoleStruct:getAttr(ROLE_SCHOOL) > 1 then
			local select_node = self.select_monster or self.select_role
			select_node = tolua.cast(select_node,"SpriteMonster")
			if select_node and select_node:getHP() > 1 then
				if isInRect(self:space2Tile(cc.p(select_node:getPosition())),r_tile_pos,attack_R) then
					taget_objId = select_node:getTag()
				end
			end
		end
		local is_wait_attack = false
		skill_id,is_wait_attack = Hangup.getSkillId(taget_objId, sel_node) 
        if self.isStory then
            if skill_id == 3004 then
                skill_id = 3011
            end
        end
	end
	if not skill_id then return end
	
	local skillLv = self.skill_map and self.skill_map[skill_id] or 1

	if MRoleStruct:getAttr(ROLE_SCHOOL) == 1 then
		local has_lhbuff = hasTheBuffById(G_ROLE_MAIN.obj_id,126)
		if skill_id == 1006 and (not has_lhbuff) and (not self.isStory)  then
			return false
		elseif has_lhbuff and skill_id~=1005 and skill_id~=1035 and skill_id~=1010 and skill_id~=1038 and skill_id~=1008 then
			if getGameSetById(GAME_SET_ID_AUTO_DOUBLE_FIRE) == 1 then
				if G_ROLE_MAIN.double_fire then
					skill_id = 1006
				end
			else
				skill_id = 1006
			end
		end
	end

	skill_times = {0.35,0,0,0.5}
	if role_item == G_ROLE_MAIN and skill_id < 7000 then
		if self.on_pickup and (state > ACTION_STATE_IDLE and state < ACTION_STATE_HURT) then
			return
		elseif (not sel_node) and self:autoPickUp() then
			return
		-- elseif game.getAutoStatus() == AUTO_ATTACK and (not self:isHideMode()) and (not self.select_role) and G_MAINSCENE.hangup_tile and (not isInRect(G_MAINSCENE.hangup_tile,r_tile_pos,20 )) then
		-- 	self:resetSelectMonster()
		-- 	self:moveMapByPos(G_MAINSCENE.hangup_tile,false)
		-- 	return
		end
		if G_ROLE_MAIN:upOrDownRide_ex(role_item,false) and game.getAutoStatus() == AUTO_ATTACK then
			resetGmainSceneTime()
			return
		end
	end
	local useMP = getConfigItemByKey("SkillLevelCfg","skillID",skill_id*1000+skillLv,"useMP")
	--print("useMP",useMP,"skill_id",skill_id,"mp",mp)
	if useMP and mp < useMP and (not self.isStory) then-- and (not G_MAINSCENE.skill_cds[skill_id]) then
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
	--print("roleStartToAttack: 11111111111111")
	if skill_info.effectRangeType < 8 then
		local select_node = self.select_monster or self.select_role
		select_node = tolua.cast(select_node,"SpriteMonster")
		if select_node and select_node:isAlive() then
			m_pos = cc.p(select_node:getPosition())
			if isInRect(self:space2Tile(m_pos),r_tile_pos,area_R) then
				target_node = select_node
			end
		else
			self:resetTouchTag()
			m_pos = nil
		end
		if not target_node and ( skill_info.effectRangeType ~= 4)then
			--print(" select target_node")
			local min_distance = area_R
			if self.isfb then min_distance = 100 end 
			if self.isJjc then
				local enemyBody = tolua.cast(self.enemyBody,"SpritePlayer")
				if enemyBody and enemyBody:isAlive() then
					target_node = enemyBody 
				end
			elseif skill_id and skill_id ~= 2005 and skill_id ~= 2035 then
				local has_get_task_monster = false
				for k,v in pairs(monster_tab)do
					local monster_node = self:isValidStatus(v)
					if monster_node and monster_node:isVisible() then
						local m_tile_pos = nil
						if self.isStory then
							local m_pos = cc.p(monster_node:getPosition())
							m_tile_pos = self:space2Tile(m_pos)
						else
							m_tile_pos = monster_node:getServerTile()
						end
						local distance = math.max(math.abs(m_tile_pos.x-r_tile_pos.x),math.abs(m_tile_pos.y-r_tile_pos.y))
						local monster_node_id = monster_node:getMonsterId() 
						local roleId = MRoleStruct:getAttr(ROLE_MODEL,v) or 0
						local m_type = monster_node:getType() or 0
						local level = monster_node:getLevel() or 0
						local owner_name = MRoleStruct:getAttr(ROLE_HOST_NAME,v) or "0"
						local special_montab = {[9005]=true,[9008]=true,[53000]= true,[53001]= true}
						if monster_node:getType() < 20 and (m_name == owner_name or monster_node_id >= 90000 or special_montab[monster_node_id] or isKingModel(monster_node_id)) then -- 不自动选神宠 与30级以下玩家
							monster_tab[k] = nil
							monster_node = nil
						elseif isInRect(m_tile_pos,r_tile_pos,area_R) then
							if monster_id and monster_id == monster_node_id then
								if (not target_node) or monster_id ~= target_node:getMonsterId() then
									target_node = monster_node
								elseif distance < min_distance then	
									min_distance = distance
									target_node = monster_node
								end
								has_get_task_monster = true
							elseif distance < min_distance and (not has_get_task_monster) then	
								min_distance = distance
								target_node = monster_node
							end
						end
					end
				end
			end
			if target_node then
				--print(" get target_node")
				if target_node:getType() >= 20 then
					self:touchRoleFunc(target_node)
				else
					self:touchMonsterFunc(target_node)
				end
				if (not skillid) and MRoleStruct:getAttr(ROLE_SCHOOL) == 3 and skill_id ~= 3004 then
					if target_node:getHP() > 1 then
						skill_id = require("src/base/HangUpFuncs").getSkillId(target_node:getTag()) 
						skill_info = getConfigItemByKey("SkillCfg","skillID",skill_id)
						if skill_info then
							attack_R = skill_info.useDistance
						end
					end		
				end
			end
		end
	elseif skill_info.effectRangeType <= 9 then
		if skill_info.effectRangeType == 9 then
			if (game.getAutoStatus() ~= AUTO_ATTACK) and  tolua.cast(self.select_role,"SpritePlayer") then
				target_node = self.select_role 
			else
				target_node = role_item
			end
		else
			target_node = role_item
		end
	else
		target_node = role_item
	end
	local m_tile_pos = nil
	if target_node then
		m_pos = cc.p(target_node:getPosition())
		if self.isStory then
			m_tile_pos = self:space2Tile(m_pos)
		else
			m_tile_pos = target_node:getServerTile()
		end
	end

	local sendSkill = function(skillId, monsterId,targets,target_id)
		if unSend or self.isMine then 
			if self.isMine then
				if (not skillid) then
					G_MAINSCENE:doSkillAction(skill_id)
				end
			end
			return 
		end
        if self.isStory then
		    G_MAINSCENE.storyNode:onSkillSend(skillId,targets)
        end

		if (not self.common_cd) then
			G_MAINSCENE:doSkillAction(skillId)
		end
	end
	local do_attack = false
	target_node = tolua.cast(target_node,"SpriteMonster")
	if skill_info.effectRangeType == 8 and target_node and target_node:isAlive() then --对自己释放
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
        elseif whichAction == 0 then
            do_attack = true;
		end
        --------------------------------------------------------------------------------------------------
		if do_attack and skill_id ~= 2004 then
            if CMagicCtrlMgr:getInstance():IsMagicCanDisplay(skill_id) == 3 then
                local itmpDir = role_item:getCurrectDir();
                CMagicCtrlMgr:getInstance():CreateMagic(skill_id, 0, role_item:getTag(), target_node:getTag(), itmpDir);
            else
			    self:playSkillEffect(0.15,skill_id,role_item,target_node)
            end
		else
			self.parent:doSkillAction(skill_id) -------------------------------------------
		end
		sendSkill(skill_id,target_node:getTag(),{target_node})
		return true
	elseif skill_info.effectRangeType == 10 then 
		local func = function()
			local target_tab = {}
			local r_tile_p = self:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
			local getTargetsFunc = function(tabs,noshow)
				local special_montab = {[51100]=true,[52100]=true,[51200]=true,[52200]=true,[51300]=true,[52300]=true,
										[51101]=true,[52101]=true,[51201]=true,[52201]=true,[51301]=true,[52301]=true,
										[9005]=true,[9008]=true,[53000]= true,[53001]= true}

				for k,v in pairs(tabs)do
					local monster_node = self:isValidStatus(v) 
					
					if monster_node and monster_node:isVisible() and v~= G_ROLE_MAIN.obj_id then
						if skill_info.limitTarCount == #target_tab then
							break
						end
						local m_pos = cc.p(monster_node:getPosition())
						local t_tile_pos = self:space2Tile(m_pos)
						local monster_node_id = monster_node:getMonsterId() 
						if (not special_montab[monster_node_id]) and isInRect(t_tile_pos,r_tile_p,4,skill_info.effectRangeType) then
							table.insert(target_tab,monster_node)	
						end
					end
				end
			end
			getTargetsFunc(self.monster_tab)
			--getTargetsFunc(self.role_tab,true)
			sendSkill(skill_id,0,target_tab)
		end
		--func()
		performWithDelay(self.item_Node,func,0.1)

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
			do_attack=role_item:attackToPos(skill_times[1],cc.p(0,0))
		elseif whichAction == 2 then
			do_attack=role_item:magicUpToPos(skill_times[4],cc.p(0,0))
        elseif whichAction == 0 then
            do_attack = true;
		end
        --------------------------------------------------------------------------------------------------

		if do_attack then
			self:playSkillEffect(0.15,skill_id,role_item,target_node)
		end
		--sendSkill(skill_id,0,target_tab)
		return true
	end
	local pushFunc = function(buff,fat,...)
	  if buff then
	  	buff:writeByFmt(fat,...)
	  end
	end
	if skill_info.effectRangeType == 4 or skill_id == 3009 then
		--剧情中播放推人技能是需要预选好目标方向
        if self.isStory then
            local myNode = target_node
            --if myNode == nil then
                myNode = G_MAINSCENE.storyNode:getNearestMonsterForCollide()                
            --end

            if myNode ~= nil then
                role_item:setDirByNowPoint(cc.p(myNode:getPosition()))

                --剧情一定要冲撞到，是否需要移动主角
				local myNode_TilePos = self:space2Tile(cc.p(myNode:getPosition()))
                local myDtX = r_tile_pos.x - myNode_TilePos.x
                local myDtY = r_tile_pos.y - myNode_TilePos.y
                if myDtX*myDtY ~= 0 and math.abs(myDtX) ~= math.abs(myDtY) then
                    --计算主角移动的合适位置点
                    local can_attack_pos = cc.p(0,0)

                    if math.abs(myDtY / myDtX) < 0.41 then
                        can_attack_pos.x = r_tile_pos.x
                        can_attack_pos.y = myNode_TilePos.y
                    elseif math.abs(myDtY / myDtX) > 2.41 then
                        can_attack_pos.x = myNode_TilePos.x
                        can_attack_pos.y = r_tile_pos.y
                    else
                        local maxDt = math.abs(myDtY)
                        if math.abs(myDtX) > maxDt then maxDt = math.abs(myDtX) end
                        can_attack_pos.x = myNode_TilePos.x + math.abs(myDtX) / myDtX * maxDt
                        can_attack_pos.y = myNode_TilePos.y + math.abs(myDtY) / myDtY * maxDt
                    end

                    local func = function()
				        self:removeWalkCb()
                        self:roleStartToAttack(skill_id)
			        end

		            self:registerWalkCb(func)
		            self:moveMapByPos(can_attack_pos,false)
                    return
                end
            end           
        else
            if skill_id == 3009 then
                local tnode = sel_node
                if tnode ~= nil then
                    role_item:setDirByNowPoint(cc.p(tnode:getPosition()))
                end
            end
        end
        
        --野蛮冲撞
		local dir = role_item:getCurrectDir()
		local span_pos = self:getTileByDir(dir)
		local actions = {}
		local cmonsters = {}
		local flags = {}
		local block_index = 10
		for i=1,9 do
			local dest_pos = cc.p(r_tile_pos.x+span_pos.x*i,r_tile_pos.y+span_pos.y*i)
			if self:isBlock(dest_pos) then
				block_index = i-1
				break
			end
		end
		local role_level = MRoleStruct:getAttr(ROLE_LEVEL)
		local temp_block_index = block_index
		local getCrashTaget = function(re_targets)
			if skill_id == 3009 and (not self.isStory) then 
				local can_crash = false
				for k,v in pairs(re_targets)do
					local monster_node = self:isValidStatus(v) 
					if monster_node then
						local monser_id = monster_node:getMonsterId()
						if monser_id and (isKingModel(monser_id) or self:isTree(monser_id)) then
						elseif monster_node:getType() ~= 12 and v~= G_ROLE_MAIN.obj_id then
							local m_tile_pos = nil
							if self.isStory then
								local m_pos = cc.p(monster_node:getPosition())
								m_tile_pos = self:space2Tile(m_pos)
							else
								m_tile_pos = monster_node:getServerTile()
							end
							local dest_pos = cc.p(r_tile_pos.x+span_pos.x,r_tile_pos.y+span_pos.y)	
							if monster_node:getLevel() <= role_level and ((m_tile_pos.x==r_tile_pos.x and r_tile_pos.y == m_tile_pos.y) 
								or (m_tile_pos.x==dest_pos.x and m_tile_pos.y == dest_pos.y)) then
								can_crash = true
							end   
						end					
					end		
				end

				if not can_crash then
					return
				end
			end
			for k,v in pairs(re_targets)do
				local monster_node = self:isValidStatus(v) 
				--tolua.cast(self.item_Node:getChildByTag(v),"SpriteMonster")
				if monster_node then
					local monser_id = monster_node:getMonsterId()
					if monser_id and (isKingModel(monser_id) or self:isTree(monser_id)) then
					elseif monster_node:getType() ~= 12 and v~= G_ROLE_MAIN.obj_id then
						local m_tile_pos = nil
						if self.isStory then
							local m_pos = cc.p(monster_node:getPosition())
							m_tile_pos = self:space2Tile(m_pos)
						else
							m_tile_pos = monster_node:getServerTile()
						end
						for i=0,9 do
							local dest_pos = cc.p(r_tile_pos.x+span_pos.x*i,r_tile_pos.y+span_pos.y*i)
							if m_tile_pos.x == dest_pos.x and m_tile_pos.y == dest_pos.y then
                                if self.isStory then
                                    if not G_MAINSCENE.storyNode:isCanMove(monster_node) then
                                        if block_index > i then
									        block_index = i
								        end
                                    end
                                else
	                          		if monster_node:getLevel() > role_level then
									    if block_index > i then
										    block_index = i
	                                    end
	                                end		
                                end								
							end
						end
					end
				end
			end
			for k,v in pairs(re_targets)do
				local monster_node = self:isValidStatus(v) 
				--tolua.cast(self.item_Node:getChildByTag(v),"SpriteMonster")
				if monster_node and monster_node:isVisible() then
					local monser_id = monster_node:getMonsterId()
					if monser_id and (isKingModel(monser_id) or self:isTree(monser_id)) then
					elseif monster_node:getType() ~= 12 and v~= G_ROLE_MAIN.obj_id then
						local m_tile_pos = nil
						if self.isStory then
							local m_pos = cc.p(monster_node:getPosition())
							m_tile_pos = self:space2Tile(m_pos)
						else
							m_tile_pos = monster_node:getServerTile()
						end
						for i=0,block_index-1 do
							local dest_pos = cc.p(r_tile_pos.x+span_pos.x*i,r_tile_pos.y+span_pos.y*i)
							if m_tile_pos.x == dest_pos.x and m_tile_pos.y == dest_pos.y then
								if self.isStory then
                                    if G_MAINSCENE.storyNode:isMonster(monster_node) then
                                        cmonsters[#cmonsters+1] = {tag=i,monster=monster_node}
								        flags[i] = true
                                    end
                                else
                                    cmonsters[#cmonsters+1] = {tag=i,monster=monster_node}
								    flags[i] = true
                                end                             
							end
						end
					end
				end
			end
		end
		getCrashTaget(self.monster_tab)
		getCrashTaget(self.role_tab)
		if temp_block_index > block_index and skill_id ~= 3009 then 
			TIPS( { type = 2 , str = game.getStrByKey("lost_strong") } )
		end
		local move_flag ,move_step = 0,0
		for i=1,block_index-1 do
			if flags[i] then
				move_flag = move_flag + 1
			end
		end
		local mbuff = nil
		
		local luaEventMgr = LuaEventManager:instance()
		mbuff = luaEventMgr:getLuaEvent(SKILL_CS_CRASHSKILL)
		local dest_tile_pos = r_tile_pos
		local dest_pos = r_pos
		local collode_speed = 0.12
		local step_num = 0
		for i=0,4 do	
			if block_index <= i then
				break
			end
			step_num = step_num + 1
			dest_tile_pos = cc.p(r_tile_pos.x+span_pos.x*step_num,r_tile_pos.y+span_pos.y*step_num)
			if i+1+move_flag >= block_index then
				break
			end
			move_step = move_step + 1
		end	
		dest_pos = self:tile2Space(dest_tile_pos)
		if self.isStory then
			if skill_id ~= 3009 then
				self:cleanAstarPath(true,true)
				if self.play_step then
					AudioEnginer.stopEffect(self.play_step) 
					self.play_step = nil
				end
				collode_speed = 0.18
				if self:isOpacity(dest_tile_pos) then
					role_item:setOpacity(100)
				else
					role_item:setOpacity(255)
				end	
				role_item:standed()	
				role_item:setLocalZOrder(dest_tile_pos.y)
				if step_num > 0 then
					local coll_times = collode_speed*step_num
					role_item:collideInTheDir(coll_times,dest_pos,dir)
					self:scroll2Tile(dest_tile_pos,coll_times)
				end
			end
		end
		--local motion_streak = cc.MotionStreak:create(2.0,1.0,50.0,cc.c3b(255,255,0),textrue)
		--role_item:addChild(sprite)
		local span_tile = cc.p(dest_tile_pos.x-r_tile_pos.x,dest_tile_pos.y-r_tile_pos.y)
		local step_num = math.abs(span_tile.x)
		if math.abs(span_tile.y) > math.abs(span_tile.x) then
			step_num = math.abs(span_tile.y)
		end
		local t_num = 0
		if not self:isInSafeArea(r_tile_pos) then
			t_num = #cmonsters
		-- elseif step_num > 0 then
		-- 	unsendTips(-16)
		end
		if skill_id ~= 3009 then
			pushFunc(mbuff,"isssc",role_item:getTag(),dest_tile_pos.x,dest_tile_pos.y,skill_id,t_num)
		else
			if span_tile.x == 0 and span_tile.y == 0 then
				dest_tile_pos = cc.p(r_tile_pos.x+span_pos.x,r_tile_pos.y+span_pos.y)
			end
			pushFunc(mbuff,"isssc",role_item:getTag(),dest_tile_pos.x,dest_tile_pos.y,skill_id,t_num)
		end
		local onCollideMonster = function()
			for k,v in pairs(cmonsters)do
				local flag = move_step
				if v.tag > 1 then 
					for i=1,v.tag do
						if not flags[i] then
							flag = flag - 1
						end
					end 
				end
				local objId = v.monster:getTag()
				--v.monster:standed()
				local c_m_pos = cc.p(v.monster:getPosition())
				local tile_pos = self:space2Tile(c_m_pos)
				local move_tile = cc.p(tile_pos.x+span_pos.x*flag,tile_pos.y+span_pos.y*flag)
				if self.isStory then
                    if objId and self.role_actions[objId] then
			            self.item_Node:stopAction(self.role_actions[objId])
			            self.role_actions[objId] = nil
			            self.rock_status[objId] = nil
		            end
                   
                    v.monster:stopAllActions()
                    v.monster:standed()

                    local moveto_pos = self:tile2Space(move_tile)
					local dir = getDirBrPos(cc.p((r_pos.x-moveto_pos.x),(r_pos.y-moveto_pos.y)),v.monster:getCurrectDir())
					v.monster:setSpriteDir(dir)
					local m_type = v.monster:getType()
					if m_type < 20 then
						v.monster:walkInTheDir(collode_speed*step_num,moveto_pos,dir)
					else
						v.monster:moveInTheDir(collode_speed*step_num,moveto_pos,dir)
					end
					local doStand = function()
						local monster = tolua.cast(v.monster,"SpriteMonster")
						if monster then
							monster:setPosition(moveto_pos)
							monster:standed()
						end
					end
					performWithDelay(self.item_Node,doStand,collode_speed*step_num)
					--v.monster:runAction(cc.MoveTo:create(collode_speed*step_num,self:tile2Space(move_tile)))
					v.monster:setLocalZOrder(move_tile.y)
					if self:isOpacity(move_tile) then
						v.monster:setOpacity(100)
					else
						v.monster:setOpacity(255)
					end
				end
				pushFunc(mbuff,"iss",v.monster:getTag(),move_tile.x,move_tile.y)
			end
		end	
		if t_num > 0 then
			onCollideMonster()
		end
		if self.isStory then
			if skill_id ~= 3009 then
				local delay_time = collode_speed*step_num+0.05
				if delay_time < 0 then delay_time = 0 end
				--self.common_cd = true
				actions[#actions+1] = cc.DelayTime:create(delay_time)
				actions[#actions+1] = cc.CallFunc:create(function()
						G_ROLE_MAIN.tile_pos = dest_tile_pos
						self:initDataAndFunc(dest_tile_pos)
						role_item:standed()
						self.common_cd = nil
					end)
				actions[#actions+1] = cc.DelayTime:create(0.05)
				actions[#actions+1] = cc.CallFunc:create(function()
						if self.skill_todo[1] then
							if self.skill_todo[1] ~= skill_id then
								if self:roleStartToAttack(self.skill_todo[1]) then
									self.parent:doSkillAction(self.skill_todo[1], self.skill_map and self.skill_map[self.skill_todo[1]]  or 1)--skills[i][2])
								end
							else
								table.remove(self.skill_todo,1)
							end
						elseif (not skillid) and self.select_role and tolua.cast(self.select_role,"SpritePlayer") then
							self:roleStartToAttack()
						end
				end)
				--if role_item:getCurrActionState()~= 6 then
					self.item_Node:runAction(cc.Sequence:create(actions))
				--end

                CMagicCtrlMgr:getInstance():CreateMagic(1010, 0, role_item:getTag(), 0, role_item:getCurrectDir());
			else
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
					AudioEnginer.randSkillMusic(skill_id,true)
					local skill_effect = Effects:create(false)
					skill_effect:setPosition(r_pos)
					skill_effect:playActionData("3009/hit",12,0.5,-1)
					addEffectWithMode(skill_effect,3)
					self.item_Node:addChild(skill_effect,200)
					local ro = math.atan2(dest_pos.x-r_pos.x,dest_pos.y-r_pos.y)
					skill_effect:setRotation(ro*180/3.1415926-90)
					local actions = {}
					--actions[#actions+1] = cc.DelayTime:create(0.1)
					actions[#actions+1] = cc.MoveTo:create(collode_speed*step_num,dest_pos)
					actions[#actions+1] =  cc.CallFunc:create(function()
						removeFromParent(skill_effect) 
						skill_effect = nil
					end)
					skill_effect:runAction(cc.Sequence:create(actions))

                    CMagicCtrlMgr:getInstance():CreateMagic(3009, 0, role_item:getTag(), 0, role_item:getCurrectDir());
				end	
			end
		end
        if(not self.isStory) then
        	--if skill_id ~= 3009 then
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
        	--end
            LuaSocket:getInstance():sendSocket(mbuff)
        else
            local target_tab = {}
			for k,v in pairs(cmonsters)do
			    table.insert(target_tab,v.monster)
			end
          
            G_MAINSCENE.storyNode:onSkillSend(skill_id,target_tab)
        end
		--sendSkill(skill_id,target_tag,target_tab)
		if (not self.common_cd) then
			G_MAINSCENE:doSkillAction(skill_id)
		end
		return true
	elseif skill_id == 2005 or skill_id == 2035 then
		local kjhh_targets = {}
		local t_poss = {}
		local role_level = MRoleStruct:getAttr(ROLE_LEVEL)
		local getKjhhTaget = function(re_targets)
			local temp_targets = {} 
			for k,v in pairs(re_targets)do
				local monster_node = self:isValidStatus(v) 
				--tolua.cast(self.item_Node:getChildByTag(v),"SpriteMonster")
				if monster_node then
					local monser_id = monster_node:getMonsterId()
					if monser_id and (isKingModel(monser_id) or self:isTree(monser_id)) then
					elseif monster_node:getType() ~= 12 and v~= G_ROLE_MAIN.obj_id then
						local m_tile_pos = nil
						if self.isStory then
							local m_pos = cc.p(monster_node:getPosition())
							m_tile_pos = self:space2Tile(m_pos)
						else
							m_tile_pos = monster_node:getServerTile()
						end
						if cc.pGetDistance(m_tile_pos,r_tile_pos) <= 3 then
							temp_targets[#temp_targets+1] = monster_node
						end	 
					end
				end
			end	
			for k,v in pairs(temp_targets)do 
				local m_tile_pos = nil
				if self.isStory then
					local m_pos = cc.p(v:getPosition())
					m_tile_pos = self:space2Tile(m_pos)
				else
					m_tile_pos = v:getServerTile()
				end
				local move_distance =  cc.pGetDistance(m_tile_pos,r_tile_pos) 
                if self.isStory then
                    if G_MAINSCENE.storyNode:isCanMove(v) and G_MAINSCENE.storyNode:isMonster(v) then
                        kjhh_targets[#kjhh_targets+1] = v
					    t_poss[#t_poss+1] = m_tile_pos
                    end
                else
				    if move_distance < 2 then
				    	kjhh_targets[#kjhh_targets+1] = v
					    t_poss[#t_poss+1] = m_tile_pos
				    end	
                end
			end
			for k,v in pairs(kjhh_targets)do 
				local m_tile_pos = nil
				if self.isStory then
					local m_pos = cc.p(v:getPosition())
					m_tile_pos = self:space2Tile(m_pos)
				else
					m_tile_pos = v:getServerTile()
				end
				local span_tile = cc.p(m_tile_pos.x-r_tile_pos.x,m_tile_pos.y-r_tile_pos.y)
				while (span_tile.x == 0 and span_tile.y == 0) do
					span_tile.x = math.floor(math.random(-1,1))
					span_tile.y = math.floor(math.random(-1,1))
				end
				local next_tile = cc.p(m_tile_pos.x+span_tile.x,m_tile_pos.y+span_tile.y)
				if not self:isBlock(next_tile) then
					local is_stop = nil
					for a,b in pairs(temp_targets)do
						local t_tile_pos = nil
						if self.isStory then
							t_tile_pos = self:space2Tile(cc.p(b:getPosition()))
						else
							t_tile_pos = b:getServerTile()
						end
						local dir1 = self:getDirByTile(span_tile)
						local dir2 = self:getDirByTile(cc.p(t_tile_pos.x-m_tile_pos.x,t_tile_pos.y-m_tile_pos.y))
						local move_distance = math.max(math.abs(t_tile_pos.x-r_tile_pos.x),math.abs(t_tile_pos.y-r_tile_pos.y))
						if move_distance >= 2 and move_distance < 3 and dir1 == dir2 then
							is_stop = true
							break
						end
					end
					if not is_stop then 
						t_poss[k] = next_tile
						next_tile = cc.p(next_tile.x+span_tile.x,next_tile.y+span_tile.y)
						if not self:isBlock(next_tile) then
							for a,b in pairs(temp_targets)do
								local t_tile_pos = nil
								if self.isStory then
									t_tile_pos = self:space2Tile(cc.p(b:getPosition()))
								else
									t_tile_pos = b:getServerTile()
								end
								local dir1 = self:getDirByTile(span_tile)
								local dir2 = self:getDirByTile(cc.p((t_tile_pos.x-m_tile_pos.x)/2,(t_tile_pos.y-m_tile_pos.y)/2))
								local move_distance =  math.max(math.abs(t_tile_pos.x-r_tile_pos.x),math.abs(t_tile_pos.y-r_tile_pos.y))
								if move_distance >= 3 and move_distance < 4  and dir1 == dir2 then
									is_stop = true
									break
								end
							end
							if not is_stop then 
								t_poss[k] = next_tile
							end
						end
					end
				end
			end
		end		
		getKjhhTaget(self.monster_tab)
		getKjhhTaget(self.role_tab)
		local mbuff = nil
		local t_num = 0
			for k,v in pairs(kjhh_targets)do
				if self.isStory then
					if t_poss[k] then
						local doMove = function()
							local tar_pos = self:tile2Space(t_poss[k])
							local monster = tolua.cast(v,"SpriteMonster")
							if monster then
								local objId = monster:getTag()
								monster:standed()
								local dir = getDirBrPos(cc.p((r_pos.x-tar_pos.x),(r_pos.y-tar_pos.y)),monster:getCurrectDir())
								v:setSpriteDir(dir)
								local m_type = monster:getType()
								if m_type < 20 then
									monster:walkInTheDir(0.4,tar_pos,dir)
								else
									monster:moveInTheDir(0.4,tar_pos,dir)
								end
							end
							local doStand = function()
								local monster = tolua.cast(v,"SpriteMonster")
								if monster then
									monster:setPosition(tar_pos)
									monster:standed()
								end
							end
							performWithDelay(self.item_Node,doStand,0.6)
						end
						performWithDelay(self.item_Node,doMove,0.1)
						v:setLocalZOrder(t_poss[k].y)
						if self:isOpacity(t_poss[k]) then
							v:setOpacity(100)
						else
							v:setOpacity(255)
						end
					end
				end
			end 
		--end
		--self.parent:doSkillCdAction(skill_id)
        if(not self.isStory) then
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
        else
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
				--self.parent:doSkillAction(skill_id) --------------------------------------------
	            if CMagicCtrlMgr:getInstance():IsMagicCanDisplay(skill_id) == 3 then
	                local itmpDir = role_item:getCurrectDir();
	                CMagicCtrlMgr:getInstance():CreateMagic(skill_id, 0, role_item:getTag(), 0, itmpDir);
	            else
				    self:playSkillEffect(0.15,skill_id,role_item);
	            end
			end	
            G_MAINSCENE.storyNode:onSkillSend(skill_id,kjhh_targets)
        end

		if (not self.common_cd) then
			G_MAINSCENE:doSkillAction(skill_id)
		end
		return true
	end
	local getTarFunc = nil
	if m_tile_pos and isInRect(m_tile_pos,r_tile_pos,attack_R) or (skillid == 2003) then
		if self:getRockDirSet() then
			local func = function()
				self:removeWalkCb()
				if self:roleStartToAttack(skill_id) then
					self.parent:doSkillAction(skill_id,nil,cd)
				end
			end
			self:registerWalkCb(func)
			self:setAttackFlag(true)
			return false
		elseif state==ACTION_STATE_WALK or state==ACTION_STATE_RUN or state > ACTION_STATE_CREATE then
			return false
		end
		if m_tile_pos and (r_tile_pos.x == m_tile_pos.x and r_tile_pos.y == m_tile_pos.y) and (skill_info.effectRangeType < 8) then
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
				if skill_id == 1006 and hasTheBuffById(G_ROLE_MAIN.obj_id,126) then
					cd = 0.9
				end
				if skillid and self:roleStartToAttack(skill_id) then
					self.parent:doSkillAction(skill_id,nil,cd)
					resetGmainSceneTime()
				end
			end
			self:registerWalkCb(func)
			self:moveMapByPos(can_move_pos,false)
			return false
		end 
		target_node = tolua.cast(target_node,"SpriteMonster")
		local target_tab = {target_node}
		local has_get_target = nil
		if game.getAutoStatus() == AUTO_ATTACK and (skill_id == 1004 or skill_id == 2008 or skill_id == 2003) then
			--if target_node then
				has_get_target = true
				local target_tag = target_node and target_node:getTag() or 0
				local owner_name = MRoleStruct:getAttr(ROLE_HOST_NAME,target_tag) or "0"
				if owner_name ~= m_name then
					for k,v in pairs(monster_tab)do
						local monster_node = self:isValidStatus(v)
						if monster_node and monster_node:isVisible() then
							local owner_name = MRoleStruct:getAttr(ROLE_HOST_NAME,v) or "0"
							if owner_name ~= m_name and target_tag ~= v then
								local t_tile_pos = nil
								if self.isStory then
									local m_pos = cc.p(monster_node:getPosition())
									t_tile_pos = self:space2Tile(m_pos)
								else
									t_tile_pos = monster_node:getServerTile()
								end
								local t_tar_tile = r_tile_pos
								if skill_info.effectCenterPos == 2 then
									t_tar_tile = m_tile_pos
								end
								if isInRect(t_tile_pos,t_tar_tile,2,skill_info.effectRangeType) then
									if skill_id ~= 2003 or monster_node:getType() < 20 then
										table.insert(target_tab,monster_node)
										if not target_node then
											target_node = monster_node
											target_tag = target_node:getTag()
										end
									end
								end
							end
						end
					end
				else
					target_tab = {}
				end
				if #target_tab <=1 then
					if skill_id == 1004 then
						skill_id = 1003
					else
						if self.skill_map[2010] then
							local useMP = getConfigItemByKey("SkillLevelCfg","skillID",2010*1000+self.skill_map[2010],"useMP")
							if useMP and useMP < mp then
								skill_id = 2010
							elseif self.skill_map[2002] then
								skill_id = 2002
							end
						elseif self.skill_map[2002] then
							skill_id = 2002
						end
					end
				end
			--end
		end
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
			if m_tile_pos then m_pos = self:tile2Space(m_tile_pos) end
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
	                local itmpDir = MapView:GetDirByPos(cc.p(role_item:getPosition()), m_pos)
	                CMagicCtrlMgr:getInstance():CreateMagic(skill_id, 0, role_item:getTag(),target_node:getTag(), itmpDir)
	            else
				   self:playSkillEffect(0.15,skill_id,role_item,targ_node,m_pos)
	            end
	            if skill_id == 2003 and (not isInRect(m_tile_pos,r_tile_pos,attack_R)) then
	            	performWithDelay(self,function() self.on_attack = nil end,0)
	            end
	        elseif skill_id == 2003 then
	        	local itmpDir = role_item:getCurrectDir()
	            CMagicCtrlMgr:getInstance():CreateMagic(skill_id, 0, role_item:getTag(),role_item:getTag(), itmpDir)
	            performWithDelay(self,function() self.on_attack = nil end,0)
	        end
		end
		
		if do_attack and sendSkill and target_node and target_node:isAlive() or (skillid == 2003) then
			local target_tag = 0 
			local target_id = 0 
			if target_node then 
				target_tag = target_node:getTag()
				target_id = target_node:getMonsterId() or 0
			end
			local owner_name = MRoleStruct:getAttr(ROLE_HOST_NAME,target_tag) or "0"
			if (owner_name == m_name) then
				target_node = nil
			end
			local getTarFunc = function(tabs)
				for k,v in pairs(tabs)do
					local monster_node = self:isValidStatus(v) 
					--tolua.cast(self.item_Node:getChildByTag(v),"SpriteMonster")
					if target_tag~=v and (v~= G_ROLE_MAIN.obj_id or skill_info.effectRangeType == 9) and  monster_node and monster_node:isVisible() then
						if skill_info.limitTarCount == #target_tab then
							break
						end
						local owner_name = MRoleStruct:getAttr(ROLE_HOST_NAME,v) or "0"
						if (owner_name == m_name) then

						else
							local t_tar_tile = r_tile_pos
							if skill_info.effectCenterPos == 2 then
								t_tar_tile = m_tile_pos
							end
							local t_tile_pos = nil
							if self.isStory then
								local m_pos = cc.p(monster_node:getPosition())
								t_tile_pos = self:space2Tile(m_pos)
							else
								t_tile_pos = monster_node:getServerTile()
							end
							if isInRect(t_tile_pos,t_tar_tile,2,skill_info.effectRangeType) then
								table.insert(target_tab,monster_node)
								if not target_node then
									target_node = monster_node
									target_tag = target_node:getTag()
								end
							end
						end
					end
				end
			end

			if (not has_get_target) then
				getTarFunc(monster_tab)
			end
			sendSkill(skill_id,target_tag,target_tab)
		end
		return true
	elseif m_tile_pos and isInRect(m_tile_pos,r_tile_pos,area_R) and (skill_id~=2004) and (skillid ~= 2003) then	

		-- local skills_crash_id = nil
		-- local isHaveCrash = function(s_id)
		-- 	local s_lv = self.skill_map[s_id]
		-- 	if s_lv then
		-- 		local useMP = getConfigItemByKey("SkillLevelCfg","skillID",s_id*1000+s_lv,"useMP")
		-- 		local coolTimeShare = getConfigItemByKey("SkillCfg","skillID",s_id,"coolTimeShare")
		-- 		local MskillOp = require "src/config/skillOp"
		-- 		local coolTime = MskillOp:skillCoolTime(s_id,s_lv)
		-- 		if (not coolTimeShare) or (coolTimeShare < coolTime )then
		-- 			coolTimeShare = coolTime
		-- 		end
		-- 		if (not useMP) or (mp >= useMP) then
		-- 			skills_crash_id = s_id
		-- 			return (G_MAINSCENE and (not G_MAINSCENE.skill_cds[s_id]))
		-- 		else 
		-- 			return false
		-- 		end
		-- 	end
		-- 	return false
		-- end
		-- if self.select_role and MRoleStruct:getAttr(ROLE_SCHOOL)==1 and (not isInRect(m_tile_pos,r_tile_pos,4)) and (not skillid) and (isHaveCrash(1010) or isHaveCrash(1005)) then
		-- 	local dir = getDirBrPos(cc.p((m_pos.x-r_pos.x),(m_pos.y-r_pos.y)),role_item:getCurrectDir())
		-- 	role_item:setSpriteDir(dir)
		-- 	if self:roleStartToAttack(skills_crash_id) then
		-- 		self.parent:doSkillAction(skills_crash_id)
		-- 	end
		--else
			local func = function()
				self:removeWalkCb()
				if self.common_cd then return end
				local cd = nil
				if skill_id == 1006 and hasTheBuffById(G_ROLE_MAIN.obj_id,126) then
					cd = 0.9
				end
				if skillid and self:roleStartToAttack(skill_id) then
					self.parent:doSkillAction(skill_id,nil,cd)
					resetGmainSceneTime()
				elseif (not skillid) and self.select_role and MRoleStruct:getAttr(ROLE_SCHOOL)==1 and tolua.cast(self.select_role,"SpritePlayer") then
					local now_r_pos = cc.p(G_ROLE_MAIN:getPosition())
					local now_tile_pos = self:space2Tile(now_r_pos)
					local now_mtile_pos = self.select_role:getServerTile()
					if (not isInRect(now_mtile_pos,now_tile_pos,attack_R)) and (not self.common_cd) then
						if self:roleStartToAttack(skill_id) then
							resetGmainSceneTime()
						end
					end
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
					if self:roleStartToAttack(skill_id) then
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
				end
				if game.getAutoStatus() == AUTO_ATTACK then
					performWithDelay(self,checkPath,0.1)
				end
				if skill_id == 2003 then
					local paths = self:getRolePath()
					if target_node then
						local r_tile_pos = paths[#paths]
						local target_tab = {}
						local target_tag = target_node:getTag()
						local owner_name = MRoleStruct:getAttr(ROLE_HOST_NAME,target_tag) or "0"
						if owner_name ~= m_name then
							for k,v in pairs(monster_tab)do
								local monster_node = self:isValidStatus(v)
								if monster_node and monster_node:isVisible() then
									local owner_name = MRoleStruct:getAttr(ROLE_HOST_NAME,v) or "0"
									if owner_name ~= m_name and target_tag ~= v and r_tile_pos ~= nil then
										local t_tile_pos = nil
										if self.isStory then
											local m_pos = cc.p(monster_node:getPosition())
											t_tile_pos = self:space2Tile(m_pos)
										else
											t_tile_pos = monster_node:getServerTile()
										end
										if isInRect(t_tile_pos,r_tile_pos,2,skill_info.effectRangeType) then
											if monster_node:getType() < 20 then
												table.insert(target_tab,monster_node)
											end
										end
									end
								end
							end
						else
							target_tab = {}
						end
						if #target_tab <=1 then
							if self.skill_map[2010] then
								local useMP = getConfigItemByKey("SkillLevelCfg","skillID",2010*1000+self.skill_map[2010],"useMP")
								if useMP and useMP <= MRoleStruct:getAttr(ROLE_MP) then
									skill_id = 2010
								elseif self.skill_map[2002] then
									skill_id = 2002
								end
							elseif self.skill_map[2002] then
								skill_id = 2002
							end
							if skill_id ~= 2003 then
								self:removeWalkCb()
								if self:roleStartToAttack(skill_id) then
									resetGmainSceneTime()
								end
							end
						end
					end
				end
			end
		--end
	elseif skillid and (game.getAutoStatus() ~= AUTO_ATTACK) then
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
                    CMagicCtrlMgr:getInstance():CreateMagic(skill_id, 0, role_item:getTag(), 0, 0);
                else
				    self:playSkillEffect(0.15,skill_id,role_item)
                end
			end
		end
		self.skill_todo = {}
		return true
	end
	return false
end


return roleStartToAttack