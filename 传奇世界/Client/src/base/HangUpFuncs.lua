local HangUpFuncs = {}
--找到对应的公平竞技场的技能
local judgeIsArenaSkill=function(skillId )
	return getConfigItemByKey("SkillCfg","skillID",skillId,"arenaSkillID")
end
HangUpFuncs["judgeIsArenaSkill"]=judgeIsArenaSkill
-- @param: taget_objId 目标对象
-- @param: 当前选择的对象
HangUpFuncs["getSkillId"] = function(taget_objId, selNode,monster_tab)
	local MRoleStruct = require("src/layers/role/RoleStruct")
	local skill_id = nil 
	local is_wait_attack = false
	local mp = MRoleStruct:getAttr(ROLE_MP)
	local level = MRoleStruct:getAttr(ROLE_LEVEL)
	local school = MRoleStruct:getAttr(ROLE_SCHOOL)
    
    
	local getSkillId = function(s_id)
		local has_learn = nil
		local has_set = nil
		local s_lv = nil;
        -- skill_map 可能为空，so，无法获得技能.
        if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.skill_map then
            s_lv = G_MAINSCENE.map_layer.skill_map[s_id];
        end
		if isSettingSkillSeted(s_id) == false then
			has_set = false
		else
			has_set = true
		end
		local useMP=nil
		--如果公平竞技场，判断是否是公平竞技场可以用的技能
		if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
			has_set=true
			s_lv=1
			local skyArenaSkillId=judgeIsArenaSkill(s_id)
			if not skyArenaSkillId then
				return false
			end
			useMP=getConfigItemByKey("SkillLevelCfg","skillID",skyArenaSkillId*1000+1,"useMP")
		end
		--print(tostring(s_id).." "..tostring(has_set))
		if s_lv and has_set then
			if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
			else
				useMP = getConfigItemByKey("SkillLevelCfg","skillID",s_id*1000+s_lv,"useMP")
			end
			local coolTimeShare = getConfigItemByKey("SkillCfg","skillID",s_id,"coolTimeShare")
			local MskillOp = require "src/config/skillOp"
			local coolTime = MskillOp:skillCoolTime(s_id,s_lv)
			if (not coolTimeShare) or (coolTimeShare < coolTime )then
				coolTimeShare = coolTime
			end
			if (not useMP) or (mp >= useMP) or G_MAINSCENE.map_layer.isStory == true then
				if coolTimeShare and coolTimeShare > 1000 and coolTimeShare < 1500 then
                    -- 服务器过来的强制cd
					return (G_MAINSCENE and (not G_MAINSCENE.skill_cds[s_id]));
				else
					return (not coolTimeShare) or (coolTimeShare < 450) or (G_MAINSCENE and (not G_MAINSCENE.skill_cds[s_id]))
				end
			else 
				return false
			end
		end
		return s_lv and has_set
	end
	
    -- 选择怪/人 [不论是否有目标]
    if selNode == nil and game.getAutoStatus() == AUTO_ATTACK then
        selNode = HangUpFuncs["GetNearestNeighbor"](selNode,monster_tab);
        --print("selNode:",selNode:getMonsterId())
    end
    local isTargetNearRole = function(selNode)
    	if selNode and G_ROLE_MAIN then
    		if selNode:getLevel() > G_ROLE_MAIN:getLevel() then
    			return false
    		end
    		local sel_pos = selNode:getServerTile()
    		return math.max(math.abs(sel_pos.x-G_ROLE_MAIN.tile_pos.x),math.abs(sel_pos.y-G_ROLE_MAIN.tile_pos.y)) <= 1
    	end
    	return false
	end
    local isSelRole = false;
    if game.getAutoStatus() ~= AUTO_ATTACK or (selNode ~= nil and selNode:getType() >= 12) then  -- 选中人  boss 怪  ，和 非挂机状态下 使用单体技能
        isSelRole = true;
    end

	local skills = {}
	local obj_id = G_ROLE_MAIN.obj_id
	if school == 1 then
		if getGameSetById(GAME_SET_ID_AUTO_DOUBLE_FIRE) == 1 then
			if G_ROLE_MAIN.double_fire and g_buffs_ex and g_buffs_ex[obj_id] and g_buffs_ex[obj_id][126] and g_buffs_ex[obj_id][126] > 0 then
				return 1006,false
	        end
		elseif g_buffs_ex and g_buffs_ex[obj_id] and g_buffs_ex[obj_id][126] and g_buffs_ex[obj_id][126] > 0 then -- 放烈火
			return 1006	,false
		end
        -- 优先判断作用自己技能
        if (not (g_buffs_ex and g_buffs_ex[obj_id] and g_buffs_ex[obj_id][110])) and getGameSetById(GAME_SET_ZHANSHI_DEFENSE) == 1 and getSkillId(1008) then
            return 1008, false;
        end
        if getGameSetById(GAME_SET_AUTOCRASH) == 1 and isTargetNearRole(selNode) then
        	if getSkillId(1010) then
        		return 1010 ,false
        	elseif getSkillId(1005) then
        		return 1005 ,false
        	end
        end
        -- 锁定人
        if isSelRole then
            skills = {1009,1102,1003,1002,1000}
        else
            -- 是否可以释放群攻的抱月刀
            if getSkillId(1004) and HangUpFuncs["canGroupAttack"](selNode, 1004) then
                return 1004, false;
            end

            skills = {1009,1102,1003,1002,1000}
        end 
	elseif school == 2 then
        -- 优先判断作用自己技能
		if (not (g_buffs_ex and g_buffs_ex[obj_id] and g_buffs_ex[obj_id][114])) and getGameSetById(GAME_SET_FASHI_DEFENSE) == 1 and getSkillId(2009) then
			return 2009, false;
		elseif getGameSetById(GAME_SET_FIRERING) == 1 and getSkillId(2005) and isTargetNearRole(selNode) then
        	return 2005 ,false
        elseif isSelRole then
			skills = {2010,2202,2002,2001}
        else
            -- 是否可以释放群攻技
            if getSkillId(2008) and HangUpFuncs["canGroupAttack"](selNode, 2008)  then
                return 2008, false;
            end

            if getSkillId(2003) and HangUpFuncs["canGroupAttack"](selNode, 2003)  then
                return 2003, false;
            end

            skills = {2010,2202,2002,2001}
        end
	else    -- 道士挂机设置
		if G_MAINSCENE and G_MAINSCENE.map_layer then 
			local map = G_MAINSCENE.map_layer
			local has_my_pet = false
			if map.pet then
				for k,v in pairs(map.pet)do 
					if v:getMonsterId() ~=9995 then
						has_my_pet = true
                        break;
					end
				end
			end
            -- 未召唤宠物
			if (((not map.pet) or (not has_my_pet) )) and (not map.has_do_pet) then 
                if getGameSetById(GAME_SET_ID_AUTO_SUMMON_GW) == 1 and getSkillId(3012) then            -- 强化骷髅
                    map.has_do_pet = true;
                    return 3012,false
				elseif getGameSetById(GAME_SET_ID_AUTO_SUMMON) == 1 and getSkillId(3007) then        -- 召唤神兽
					map.has_do_pet = true
					return 3007,false
				elseif getGameSetById(GAME_SET_ID_AUTO_SUMMON_GW) == 1 and getSkillId(3008) then        -- 骷髅召唤术
					map.has_do_pet = true
					return 3008,false
				end
			end
			map.has_do_pet = nil
            -- 是否可释放斗转星移
            if map.pet and has_my_pet and (not (g_buffs_ex and g_buffs_ex[obj_id] and g_buffs_ex[obj_id][118])) and getGameSetById(GAME_SET_DAOSHI_DEFENSE) == 1 and getSkillId(3010) then
                return 3010,false
            end

            -- 是否可释放神圣战甲术
			if ((not g_buffs_ex) or (not g_buffs_ex[obj_id]) 
				or (not g_buffs_ex[obj_id][8])) and getSkillId(3006) then
				return 3006,false
			end

            -- 对方是否有中毒效果
			if taget_objId then
				local obj_id = taget_objId
				if ((not g_buffs_ex) or (not g_buffs_ex[obj_id]) 
					or (not g_buffs_ex[obj_id][6])) then
                    ---------------无中毒, 设置了自动施毒---------------
					if getSkillId(3303) then            -- 强化施毒
                        return 3303,false
				    elseif getSkillId(3004) then        -- 施毒术
					    return 3004,false
				    end
				end
			end
			if getGameSetById(GAME_SET_LIONSHOUT) == 1 and getSkillId(3009) and isTargetNearRole(selNode) then
        		return 3009 ,false
        	end
            -- 释放单体技
			skills = {3011,3002,1001}
		end
	end

	for i=1,#skills do 
		if getSkillId(skills[i]) then
			skill_id = skills[i]
			break
		end
	end
    return skill_id,is_wait_attack
end


---------------------------- 无目标，选取最近的目标 ----------------------------
HangUpFuncs["GetNearestNeighbor"] = function(selNode,monster_tab)
    local target_node = selNode;

    if G_MAINSCENE ~= nil and G_MAINSCENE.map_layer ~= nil and G_ROLE_MAIN and not G_MAINSCENE.map_layer.isStory then
        local area_R = 16;
        local min_distance = 16
        local tar_data = nil
        local monster_id = nil
		if G_MAINSCENE.map_layer.isfb or G_MAINSCENE.map_layer.isSkyArena then
            min_distance = 100
            area_R = 80
        end 

        if G_MAINSCENE.map_layer.isJjc then
			local enemyBody = tolua.cast(G_MAINSCENE.map_layer.enemyBody, "SpritePlayer")
			if enemyBody and enemyBody:isAlive() then
				target_node = enemyBody 
			end
        else
        	if not monster_tab then
	            local select_node = require("src/base/SelectRoleLayer")
	            local pkmode = require("src/layers/pkmode/PkModeLayer"):getCurMode()
	            -- 怪物列表
	            monster_tab = {}
	            if G_MAINSCENE.map_layer.monster_tab ~= nil then
		            for k,v in pairs(G_MAINSCENE.map_layer.monster_tab) do
			            monster_tab[k] = v
		            end

	                if pkmode > 0 and G_MAINSCENE.map_layer.role_tab ~= nil then
	                    for k,v in pairs(G_MAINSCENE.map_layer.role_tab) do
	                        if select_node:isCanAttack(pkmode,v) then
					            monster_tab[k] = v 
	                        end
	                    end
	                end
	            end
	        end
            local has_get_task_monster = false
            if (game.getAutoStatus() == AUTO_ATTACK) and (not selNode) and (not G_MAINSCENE.map_layer:isHideMode()) and DATA_Mission then
            	--monster_id = DATA_Mission:getTaskMonsterID();
            	 --print("get monster_id")
            	tar_data = DATA_Mission:getLastTarget()
				if tar_data then
					monster_id = tar_data.id
				end
            end
            local MRoleStruct = require("src/layers/role/RoleStruct")
            --print("monster_id",monster_id)
            local m_name = MRoleStruct:getAttr(ROLE_NAME)
            local role_item = G_ROLE_MAIN;
            local r_pos = cc.p(role_item:getPosition())
            local r_tile_pos = G_MAINSCENE.map_layer:space2Tile(r_pos)
            local target_monsterid = nil
            for k,v in pairs(monster_tab)do
                local monster_node = G_MAINSCENE.map_layer:isValidStatus(v)
                if monster_node and monster_node:isVisible() then
                    local m_tile_pos = monster_node:getServerTile()
					local distance =  math.max(math.abs(m_tile_pos.x-r_tile_pos.x),math.abs(m_tile_pos.y-r_tile_pos.y))
                    local monster_node_id = monster_node:getMonsterId() 
					local roleId = MRoleStruct:getAttr(ROLE_MODEL,v) or 0
					local m_type = monster_node:getType() or 0
					local level = monster_node:getLevel() or 0
					local owner_name = MRoleStruct:getAttr(ROLE_HOST_NAME,v) or "0"
					local special_montab = {[9005]=true,[9008]=true,[53000]= true,[53001]= true}
					local teamID = MRoleStruct:getAttr(PLAYER_TEAMID,v) 
					local myTeamID = MRoleStruct:getAttr(PLAYER_TEAMID) 
					if m_name == owner_name or (monster_node_id >= 90000 and m_type < 20) or special_montab[monster_node_id] or isKingModel(monster_node_id) then -- 不自动选神宠 与30级以下玩家
						monster_tab[k] = nil
						monster_node = nil
					elseif G_MAINSCENE and G_MAINSCENE.map_layer and (G_MAINSCENE.map_layer.mapID == 5010 or G_MAINSCENE.map_layer.mapID == 5005) and  teamID and myTeamID and myTeamID==teamID and myTeamID>0 then
						monster_tab[k] = nil
						monster_node = nil
					elseif distance < area_R then
						if monster_id and monster_id == monster_node_id then
							if (not target_monsterid) or monster_id ~= target_monsterid or distance < min_distance then
								target_node = monster_node
								target_monsterid = monster_id
								min_distance = distance
							end
							has_get_task_monster = true
						elseif distance < min_distance and (not has_get_task_monster) then	
							min_distance = distance
							target_node = monster_node
							target_monsterid = monster_node_id
						end
					end
				end
			end
			--print("target_monsterid",target_monsterid)
			if target_node and (not has_get_task_monster) and tar_data and monster_id then
				if tar_data.pos and tar_data.mapid and (tar_data.mapid == G_MAINSCENE.map_layer.mapID) then
					target_node = nil
					HangUpFuncs.noneed_getTarget = true
					if math.max(math.abs(tar_data.pos.x-G_ROLE_MAIN.tile_pos.x),math.abs(tar_data.pos.y-G_ROLE_MAIN.tile_pos.y)) > 5 then
						G_MAINSCENE.map_layer:moveMapByPos(tar_data.pos,false)
						G_MAINSCENE.hangup_tile = tar_data.pos
					end
				end
			end
        end

		if target_node then
			if target_node:getType() > 20 then
				G_MAINSCENE.map_layer:touchRoleFunc(target_node)
			else
				G_MAINSCENE.map_layer:touchMonsterFunc(target_node)
			end
		end
	end

    -- 周围没有怪物，选择人
    if target_node == nil then
        	    
    end
    return target_node;
end


--------------------------- 是否满足怪物群攻条件 ------------------------------
HangUpFuncs["canGroupAttack"] = function(selNode, groupSkillId)
    local isCanGroupAttack = false;    
    
    if G_MAINSCENE ~= nil and G_MAINSCENE.map_layer ~= nil and G_ROLE_MAIN and not G_MAINSCENE.map_layer.isStory and selNode ~= nil and game.getAutoStatus() == AUTO_ATTACK then
        -- 怪物列表
        local monster_tab = {}
        if G_MAINSCENE ~= nil and G_MAINSCENE.map_layer ~= nil and G_MAINSCENE.map_layer.monster_tab ~= nil then
	         monster_tab = G_MAINSCENE.map_layer.monster_tab
        end

        local MRoleStruct = require("src/layers/role/RoleStruct")

        local m_name = MRoleStruct:getAttr(ROLE_NAME)
        local role_item = G_ROLE_MAIN;
        -- 可能已经G_ROLE_MAIN失效
        local role_item = tolua.cast(role_item, "SpritePlayer");
        if role_item == nil then
            return false;
        end
        
        local r_pos = cc.p(role_item:getPosition());
        local r_tile_pos = G_MAINSCENE.map_layer:space2Tile(r_pos)

        local effectRange = 0;
        local skill_info = getConfigItemByKey("SkillCfg","skillID",groupSkillId)
		if skill_info then
			effectRange = skill_info.effectRangeType;
			--print(groupSkillId,skill_info.effectCenterPos,skill_info.useDistance)
            if skill_info.effectCenterPos == 2 then
                if selNode then -- 以选中怪物为目标点
                    r_tile_pos = selNode:getServerTile()
	            end
	        else
	        	if selNode then
	        		local t_tile_pos =  selNode:getServerTile()
	        		if not HangUpFuncs["isInRect"](t_tile_pos, r_tile_pos, skill_info.useDistance) then
	        			return isCanGroupAttack
	        		end
	        	end
			end
		end        

        local target_tab = {selNode};
        local target_tag = selNode:getTag()
        local owner_name = MRoleStruct:getAttr(ROLE_HOST_NAME, target_tag) or "0"
        if owner_name ~= m_name then
		    for k,v in pairs(monster_tab)do
			    local monster_node = G_MAINSCENE.map_layer:isValidStatus(v)
			    if monster_node and monster_node:isVisible() then
				    local owner_name = MRoleStruct:getAttr(ROLE_HOST_NAME,v) --or "0"
				    if (not owner_name) and target_tag ~= v then
					    local t_tile_pos =  monster_node:getServerTile()
					    if HangUpFuncs["isInRect"](t_tile_pos, r_tile_pos, 2, effectRange, monster_node) then
						    isCanGroupAttack = true
					    end
				    end
			    end
		    end

		end
    end

    return isCanGroupAttack;
end

HangUpFuncs["isInRect"] = function(pos1,pos2,r,h_type,target_node)
    if G_MAINSCENE ~= nil and G_MAINSCENE.map_layer ~= nil then
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
				    local taget_pos = target_node:getServerTile()
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
    end

	return false
end

return HangUpFuncs