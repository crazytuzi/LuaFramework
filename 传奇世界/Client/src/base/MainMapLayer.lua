local MainMapLayer = class("MainMapLayer",require("src/base/MapBaseLayer"))

local commConst = require("src/config/CommDef");

function MainMapLayer:ctor(strname,parent,r_pos,mapId,isfb)
	self.parent = parent
	self.parent.map_layer = self
	self:registerMsgHandler()
	self:initializePre()
	self.updata_time = 0
	self.monster_num = 0
    self.costStoneNum = 1
	self.isMine = nil
	self.isfb = nil
	self.isJjc = nil
    self.is3v3 = nil
	self.isStory = nil
	self.isFactionFb = nil
	self.on_safearea = nil
	self.common_cd = nil
	self.inviteFactionId = nil
	self:loadMapInfo(strname, mapId,r_pos)
	self.parent:addChild(self,-1)
	self:loadSpritesPre()
    self.m_mineData = {}
	local cb = function()
		self.has_loadmap = true
	end
	performWithDelay(self.item_Node, cb, 0.0)

    --self:setName("MainMapLayer")
end

function MainMapLayer:registerMsgHandler(unregist)
	local msgids = {SINPVP_SC_FIGHTRESULT,FRAME_SC_ENTITY_EXIT,FRAME_SC_MOVE_TO,SKILL_SC_HURT,SKILL_SC_SINGING,SKILL_SC_CRASHSKILL,TASK_SC_NOTIFY_PICK_ACTION,
	COPY_SC_ENTERCOPY,COPY_SC_GUARDFAILED,COPY_SC_DONEXTCIRCLE,COPY_SC_MULTICOPY_FLUSH_ROAD,COPY_SC_COPYREWARD,COPY_SC_CALLFRIENDRET,COPY_SC_NOTIFYSTATUEHP,
	COPY_SC_ONMONSTERKILL,COPY_SC_GUARDEXP,FRAME_SC_WORSHIP,COPY_SC_COPYTOWERRESULT,FACTION_INVADE_SC_FACTION,FACTION_INVADE_SC_GET_CUR_FACTION_INFO,
    COPY_SC_PROGRESSCOPY_RET, LITTERFUN_SC_MONATTACK_RANK, COPY_SC_SINGLECOPYBOSS, DIGMINE_SC_MAX_REWARD, FIGHTTEAM3V3_SC_GETAUDITIONDATARET, FIGHTTEAM3V3_SC_GETREGULATIONDATARET,
    COPY_SC_SINGLEINSTANCE_DATA, COPY_SC_SINGLEINST_INCDATA,DIGMINE_SC_SIMULATION_SYNC,MARRIAGE_SC_TOUR_OPT_BROADCAST,MAZE_SC_DATA_RET,SKILL_SC_PLAYER_DIE,
    EMOUNT_SC_ARREST_MOUNT,EMOUNT_SC_ARREST_MOUNT_NOTIFY,EMOUNT_SC_ARREST_MOUNT_END}
	local msg_hander =  require("src/MsgHandler")
	msg_hander.new(self,msgids,nil)
end

local addSkillBuff = function(role_item, b_value, tag, skill_str, begin_speed, loop_speed)
    local buff_effect_node = role_item:getBuffSkillNode()
    -- 防止 C++ 对象不存在
    if buff_effect_node and MapView:getSkillNode() then
        if b_value then
			--BUFF特效放在人身上前面
            local order = 999990000
            buff_effect_node:setLocalZOrder(order - order % 10000 + tag)
            local skill_effect_node = buff_effect_node:getChildByTag(tag)
            if (skill_effect_node == nil) then
                -- 调用C++接口
                local skillEffect = CMagicCtrlMgr:getInstance():CreatePichesMagic(tag)
                if skillEffect then
                    -- print("CreatePichesMagic")
                    buff_effect_node:addChild(skillEffect)
                    skillEffect:setLocalZOrder(20)
                    skillEffect:setTag(tag)
                else
                    --            	print("skill_effect")
                    -- local skill_effect = Effects:create(false)
                    -- --skill_effect:setPosition(cc.p(0,10))
                    -- if begin_speed > 0 and loop_speed > 0 then						
                    --  local actions = {}
                    --  local c_ani_begin = skill_effect:createEffect2(skill_str.."/begin",begin_speed)
                    --  c_ani_begin:setLoops(1)	
                    --  actions[#actions+1] = cc.Animate:create(c_ani_begin)

                    --  local c_ani_loop = skill_effect:createEffect2(skill_str.."/loop",loop_speed)
                    --  c_ani_loop:setLoops(10000000)
                    --  actions[#actions+1] = cc.Animate:create(c_ani_loop)

                    --  local action = cc.Sequence:create(actions)
                    --  action:setTag(tag)
                    --  skill_effect:runAction(action)
                    --     skill_effect:setRenderMode(2)
                    --  buff_effect_node:addChild(skill_effect)
                    --  skill_effect:setLocalZOrder(20)
                    --  skill_effect:setTag(tag)

                    -- elseif loop_speed > 0 then
                    --  skill_effect:playActionData2(skill_str.."/loop",loop_speed,-1,0)
                    --     skill_effect:setRenderMode(2)
                    --  buff_effect_node:addChild(skill_effect)
                    --  skill_effect:setLocalZOrder(20)
                    --  skill_effect:setTag(tag)
                    -- end
                end
            else
                -- print("playActionData2")
                -- local skill_effect = tolua.cast(skill_effect_node,"Effects")
                -- if skill_effect then
                -- 	skill_effect:playActionData2(skill_str.."/loop",loop_speed,-1,0)
                -- end
            end
        else
            if (buff_effect_node:getChildByTag(tag)) then
                buff_effect_node:removeChildByTag(tag)
            end
        end
    end
end

local addBuffEffectPalsy = function(_value, _role, objId)
    if not _role then
        return
    end
    if _value then
        require("src/layers/char/CharText").new(_role:getTitleNode(), 3.0, HEADTEXT_PALSY, cc.p(1, 1))

        if G_ROLE_MAIN and objId == G_ROLE_MAIN.obj_id then
            charStateEffectTip(HEADTEXT_PALSY)
        end
        _role:standed()
        _role:stopInTheTime()
        _role:setColor(cc.c3b(210, 120, 10))

    else
        _role:standed()
        _role:setColor(cc.c3b(255, 255, 255))
    end
end

local addBuffEffectPoisonGreen = function(_value, _role)
    if _value then
        _role:setColor(cc.c3b(10, 210, 10))
    else
        _role:setColor(cc.c3b(255, 255, 255))
    end
end

local addBuffEffectPoisonRed = function(_value, _role)
    if _value then
        _role:setColor(cc.c3b(210, 10, 10))
    else
        _role:setColor(cc.c3b(255, 255, 255))
    end
end

local stopWalkSound = function()
    if G_MY_STEP_SOUND then
        AudioEnginer.stopEffect(G_MY_STEP_SOUND)
        G_MY_STEP_SOUND = nil
    end
end

local buffswitch = {
    [5] = function(value, objId, role_item)
    end,
    [6] = function(value, objId, role_item)
        if value then
            role_item:setColor(cc.c3b(10, 210, 10))
        else
            role_item:setColor(cc.c3b(255, 255, 255))
        end
    end,
    [7] = function(value, objId, role_item)
        if value then
            role_item:setOpacity(108)
        else
            role_item:setOpacity(255)
        end
    end,
    [8] = function(value, objId, role_item)
    end,
    [9] = function(value, objId, role_item)
        local status = role_item:getCurrActionState()
        if value then
            if status < ACTION_STATE_MABI then
                stopWalkSound()
                role_item:changeState(ACTION_STATE_MABI)
                -- role_item:stopInTheTime()
            end
        else
            if status == ACTION_STATE_MABI then
                role_item:standed()
            end
        end
    end,
    -- [323] = function()
    -- 	local status = role_item:getCurrActionState()
    -- 	if value then
    -- 		if status < ACTION_STATE_MABI then
    -- 			if G_MY_STEP_SOUND then
    -- 				AudioEnginer.stopEffect(G_MY_STEP_SOUND)
    -- 				G_MY_STEP_SOUND = nil
    -- 			end
    -- 			role_item:changeState(ACTION_STATE_MABI)
    -- 		end
    -- 	else
    -- 		role_item:setGray(false)
    -- 		if status == ACTION_STATE_MABI then
    -- 			role_item:changeState(1)
    -- 		end
    -- 	end
    -- end,
    [10] = function(value, objId, role_item)
        local status = role_item:getCurrActionState()
        if value then
            if status < ACTION_STATE_MABI then
                stopWalkSound()
                -- role_item:stopInTheTime()
                role_item:changeState(ACTION_STATE_MABI)
            end
        else
            if status == ACTION_STATE_MABI then
                role_item:standed()
            end
        end
    end,
    [11] = function(value, objId, role_item)
        addSkillBuff(role_item, value, 2004, "skill2004", 0, 180)
    end,

    [15] = function(value, objId, role_item)
        -- 无敌BUFF
        addSkillBuff(role_item, value, 11016, "skill11016", 0, 180)
    end,
    [25] = function(value, objId, role_item)
        -- 双倍攻击BUFF
        addSkillBuff(role_item, value, 11017, "skill11017", 0, 180)
    end,
    [35] = function(value, objId, role_item)
        -- 回血BUFF
        addSkillBuff(role_item, value, 11030, "skill11030", 0, 180)
    end,
    ["redtag"] = function(value, objId, role_item)
        -- 被箭塔瞄准s
        if value then
            if role_item and role_item:getChildByTag(78910)==nil then
                local select_effect = Effects:create(false)
                select_effect:setAnchorPoint(cc.p(0.5, 0.4))
                select_effect:playActionData("redtag", 8, 2, -1)
                select_effect:setOpacity(role_item:getOpacity())
                role_item:addChild(select_effect, 0, 78910)
                addEffectWithMode(select_effect, 3) 
            end
        else
            if role_item then
                role_item:removeChildByTag(78910)
            end
        end
    end,
    [110] = function(value, objId, role_item)
        addSkillBuff(role_item, value, 1008, "skill1008", 90, 90)
    end,
    [114] = function(value, objId, role_item)
        addSkillBuff(role_item, value, 2009, "skill2009", 0, 90)
    end,
    [118] = function(value, objId, role_item)
        -- 斗转星移
        addSkillBuff(role_item, value, 3010, "skill3010", 0, 90)
    end,
    [24] = function(value, objId, role_item)
        if G_MAINSCENE then
            G_MAINSCENE:QryMonsterNameColor(objId, value)
        end
    end,
    [30] = function(value, objId, role_item)
        if G_MAINSCENE and G_ROLE_MAIN and objId == G_ROLE_MAIN.obj_id then
            G_MAINSCENE:addTsxlEffect(value)
        end
    end,

    [108] = function(value, objId, role_item)

    end,

    [130] = function(value, objId, role_item)
        addBuffEffectPalsy(value, role_item, objId)
    end,

    [131] = function(value, objId, role_item)
        if value then
            log("[Exec update buffer by id 131] value true.")
        else
            log("[Exec update buffer by id 131] value false.")
        end
        addSkillBuff(role_item, value, 10002, "skill10002", 0, 90)
    end,

    [133] = function(value, objId, role_item)
        addBuffEffectPalsy(value, role_item, objId)
    end,

    -- 所有的冰冻效果
    [134] = function(value, objId, role_item)
        if value then
            log("[Exec update buffer by id 134] value true.")
            local chart = require("src/layers/char/CharText").new(role_item:getTitleNode(), 3.0, HEADTEXT_FROZEN, cc.p(1, 1))

            if G_ROLE_MAIN and objId == G_ROLE_MAIN.obj_id then
                charStateEffectTip(HEADTEXT_FROZEN)
            end
            role_item:standed()
            role_item:stopInTheTime()
            addSkillBuff(role_item, value, 4, "", 0, 0)

            --[[
                    local effNode = playCommonEffect(role_item, "se_frozen", 24, 2.0, 1, 11342)
					if effNode then
						effNode:setPosition(cc.p(0.0, 120.0))
					end
                    ]]
        else
            log("[Exec update buffer by id 134] value false.")
            role_item:standed()
            addSkillBuff(role_item, nil, 4, "", 0, 0)
            --[[
					local effectNode = role_item:getChildByTag(11342)
					if effectNode ~= nil then
						effectNode:removeFromParent()
					end
                    ]]
        end
        stopWalkSound()
    end,

    [135] = function(value, objId, role_item)
        addBuffEffectPoisonRed(value, role_item)
    end,

    [137] = function(value, objId, role_item)
        addBuffEffectPalsy(value, role_item, objId)
    end,

    [138] = function(value, objId, role_item)
        addBuffEffectPoisonGreen(value, role_item)
    end,

    [139] = function(value, objId, role_item)
        addBuffEffectPoisonRed(value, role_item)
    end,

    [140] = function(value, objId, role_item)
        addBuffEffectPalsy(value, role_item, objId)
    end,

    [141] = function(value, objId, role_item)
        addBuffEffectPoisonGreen(value, role_item)
    end,

    [142] = function(value, objId, role_item)
        addBuffEffectPoisonRed(value, role_item)
    end,

    [339] = function(value, objId, role_item)
        addBuffEffectPoisonGreen(value, role_item)
    end,
    [372] = function(value, objId, role_item)
        addBuffEffectPalsy(value, role_item, objId)
    end,
    -- 3V3观战
    [403] = function(value, objId, role_item)
        --如果自己第一次收到3v3观战buff提示tip
        if G_ROLE_MAIN and objId == G_ROLE_MAIN.obj_id and g_buffs[G_ROLE_MAIN.obj_id][403] == nil then
            TIPS { type = 1, str = game.getStrByKey("enter_watching_buff") }
        end
        if G_ROLE_MAIN and objId == G_ROLE_MAIN.obj_id then
            --观战隐身特效只对其他人生效
            return
        end
        if value then
            role_item:setVisible(false)
        else
            role_item:setVisible(true)
        end
    end,
}


function MainMapLayer:updateBuffById(objId, role_item, buff_id, value, isNew)
    -- print("buff_id1="..buff_id)
    local buff_id = getConfigItemByKey("buff", "id", buff_id, "lx") or buff_id
    -- print("buff_id2="..buff_id)
    -- print(objId,"buff_id ".. buff_id.." ",value)

    local bianshen_res_id = getConfigItemByKey("buff", "id", buff_id, "bianshen")
    if bianshen_res_id then
        if value then
            role_item:changeModeDisplay(true, tostring(bianshen_res_id))
        else
            role_item:changeModeDisplay(false, "")
        end
        game.setAutoStatus(game.getAutoStatus())
        role_item:reloadRes()
    elseif buff_id == 31 then
        local node = tolua.cast(self.item_Node:getChildByTag(objId), "SpritePlayer")
        if node then
            cclog("Mine Buff~~" .. tostring(objId == G_ROLE_MAIN.obj_id) .. "isExist" .. tostring(value) .. "isNew" .. tostring(isNew))
            if value and isNew then
                local rPos =(cc.p(node:getPosition()))
                local delay = 0.1
                -- local mines = require("src/config/MineDistribute")

                if objId == G_ROLE_MAIN.obj_id then
                    G_ROLE_MAIN:upOrDownRide(false)
                    game.setAutoStatus(AUTO_MINE)
                end

                local playAction = function()
                    local node = tolua.cast(self.item_Node:getChildByTag(objId), "SpritePlayer")
                    if node then
                        local dir = node:getCurrectDir()
                        if objId ~= G_ROLE_MAIN.obj_id then
                            local r_tile = self:space2Tile(rPos)
                            for k, v in pairs(self.mineTab) do
                                local mine_node = tolua.cast(self.item_Node:getChildByTag(v), "SpriteMonster")
                                local mPos = cc.p(mine_node:getPosition())
                                local m_tile = self:space2Tile(mPos)
                                local distance = cc.pGetDistance(r_tile, m_tile)
                                if distance < 2 then
                                    dir = self:getDirByTile(cc.p((m_tile.x - r_tile.x),(m_tile.y - r_tile.y)))
                                    print("dir", dir)
                                    break
                                end
                            end
                        elseif objId == G_ROLE_MAIN.obj_id and self.select_mine and tolua.cast(self.select_mine, "SpriteMonster") then
                            local mPos = cc.p(self.select_mine:getPosition())
                            dir = getDirBrPos(cc.p((mPos.x - rPos.x),(mPos.y - rPos.y)), dir)
                        end
                        node:setSpriteDir(dir)
                        node:excavateToTheDir(0.5, dir)
                        node.isMine = true
                    end
                end

                if objId ~= G_ROLE_MAIN.obj_id then
                    performWithDelay(self.item_Node, playAction, delay + 1.2)
                else
                    performWithDelay(self.item_Node, playAction, delay)
                    G_ROLE_MAIN:MineTipsTimer(node, true)
                end

                G_ROLE_MAIN:isChangeToHoe(node, true)
            elseif not value then
                G_ROLE_MAIN:isChangeToHoe(node, false)
                if objId == G_ROLE_MAIN.obj_id then
                    game.setAutoStatus(0)
                end
                G_ROLE_MAIN:MineTipsTimer(node, false)
                local a_state = node:getCurrActionState()
                if a_state == ACTION_STATE_EXCAVATE then
                    node:standed()
                end
            end
        end
    elseif buff_id == 126 then
        if G_ROLE_MAIN and objId == G_ROLE_MAIN.obj_id then
            if value then
                if G_MAINSCENE and(not G_MAINSCENE.skill_cds[1006]) then
                    TIPS( { type = 2, str = game.getStrByKey("active_leihuo") })
                    G_MAINSCENE:doSkillCdAction(1006, 1000)
                end
            else
                TIPS( { type = 2, str = game.getStrByKey("remove_leihuo") })
                if getGameSetById(GAME_SET_ID_AUTO_DOUBLE_FIRE) == 1 and G_ROLE_MAIN.double_fire then
                    G_ROLE_MAIN.double_fire = G_ROLE_MAIN.double_fire + 1
                    local span_flag = 2
                    if game.getAutoStatus() == AUTO_ATTACK or self.on_attack or self.skill_todo[1] then
                        span_flag = 3
                    end
                    if G_ROLE_MAIN.double_fire > span_flag then
                        G_ROLE_MAIN.double_fire = nil
                    end
                end
            end
        end
    elseif buff_id == 340 then
        local role_item = tolua.cast(self.item_Node:getChildByTag(objId), "SpritePlayer")
        if role_item and role_item:getOnRide() then
            G_ROLE_MAIN:upOrDownRide_ex(role_item, value, true, true)
        end
    elseif buffswitch[buff_id] then
        buffswitch[buff_id](value, objId, role_item)
    end
end

function MainMapLayer:onBuffUpdate(objId, buffs, just_skill_buff)
    if G_ROLE_MAIN and G_ROLE_MAIN.obj_id == objId then
        if buffs
            and (
                tablenums(buffs) > 0
                and not (tablenums(buffs) == 1 and buffs[403] ~= nil)
            ) then
            if self.parent.buff_btn then
                self.parent.buff_btn:setVisible(true)
            end
        else
            if self.parent.buff_btn then
                self.parent.buff_btn:setVisible(false)
            end
            if self.parent.buffLayer and self.parent.buffLayer.clearFun then
                self.parent.buffLayer:clearFun()
                self.parent.buffLayer = nil
            end
        end
    end

    if not tolua.cast(self.item_Node, "cc.Node") then
        return
    end
    local role_item = tolua.cast(self.item_Node:getChildByTag(objId), "SpriteMonster")
    if not role_item then
        return
    end

    -- if just_skill_buff then
    -- 	local skill_buffs = {[11]=true,[110]=true,[114]=true,[118]=true}
    -- 	if g_buffs and g_buffs[objId] then
    -- 		for k,v in pairs(g_buffs[objId])do
    -- 			local buff_id = getConfigItemByKey("buff","id",k,"lx") or k
    -- 			if skill_buffs[buff_id] then
    -- 				updateBuffById(k,v)
    -- 			end
    -- 		end
    -- 	end
    -- else

    local newTab = { }
    local newObjId = true
    if g_buffs[objId] then
        for k, v in pairs(g_buffs[objId]) do
            if not buffs[k] then
                self:updateBuffById(objId, role_item, k)
            end
        end

        for k, v in pairs(buffs) do
            if not g_buffs[objId][k] then
                self:updateBuffById(objId, role_item, k, v, true)
                newTab[k] = true
            end
        end
        newObjId = false
    end
    g_buffs[objId] = buffs
    -- dump(g_buffs[objId], "g_buffs[objId]")
    g_buffs_ex[objId] = { }
    for k, v in pairs(g_buffs[objId]) do
        local buff_id = getConfigItemByKey("buff", "id", k, "lx") or k
        g_buffs_ex[objId][buff_id] = v
        if not newTab[k] then
            self:updateBuffById(objId, role_item, k, v, true)
        end
    end
    -- print("objId   "..objId)
    -- 更新头像buff
    -- if self.monster_head and tolua.cast(self.monster_head,"cc.Node") and self.monster_head.monster_id == objId then
    -- 	self.monster_head:updateInfo(role_item)
    -- end
    
    -- end
end



function MainMapLayer:taskInit(mapId)
	--任务信息预加载
	local load_npc =  self.npc_tab and tablenums(self.npc_tab) == 0 
	if load_npc then
		local npc = getConfigItemByKey("NPC","q_id")
		local curTask = DATA_Mission:getLastTaskData()
		local branchTask = DATA_Mission:getBranchData()

		local branchNpc = {}
		if branchTask then
			for k , v in pairs( branchTask["list"] ) do
				if v.targetData then
					if v.targetData and v.targetData.cur_num then
						if v.targetData.cur_num >= v.targetData.count then
							branchNpc[ v.q_endnpc .. "" ] = 1 		--可交
						else
							if v.q_startnpc then
								branchNpc[ v.q_startnpc .. "" ] = 3 		--已接未完成
							end
						end
					end
				end

			end
		end

		for k,v in pairs(npc) do
			if v.q_map == mapId then
				local cj = 0
				if v.q_collect then
					cj = 1
				end
				if (v.q_id < 10456 or v.q_id > 10460) and (v.q_id < 10469 or v.q_id > 10473) then --万人迷、中州王 、先刷两个模型出来
					if v.q_newtype then
						self:addRoleNpc(v.q_x, v.q_y, tostring(v.q_resource), v.q_id)
					else
						self:addNpc(v.q_x, v.q_y, tostring(v.q_resource), v.q_id, cj)
					end
					--密令任务交接
					if branchNpc[ v.q_id .. "" ] then self:setNpcState( v.q_id , branchNpc[ v.q_id .. "" ] ) end
				end
			end
		end

		if curTask and ((curTask.q_endnpc and self.npc_tab[curTask.q_endnpc]) or (curTask.q_startnpc and self.npc_tab[curTask.q_startnpc])) then
			--1 等级不够 2进行中 3可交付 4 完成 5对话任务未完成
			if curTask.finished == 6 or curTask.finished == 3 then
				self:setNpcState( curTask.q_endnpc , 1 )
			else

			 	if curTask.finished == 2 then
			 		self:setNpcState( curTask.q_startnpc , 3 )
			 	else
			 		self:setNpcState( curTask.q_startnpc , 2 )
			 	end
			 end
		end
	end
end

function MainMapLayer:addTransfor(mapid)
	local transfor = getConfigItemByKey("HotAreaDB","q_id")
	for k,v in pairs(transfor) do
		if v.q_mapid == mapid then
			--cclog("addTransfor")
			local transforEffect = Effects:create(false)
			transforEffect:setAnchorPoint(cc.p(0.5,0.5))
			local t_pos = self:tile2Space(cc.p(v.q_x,v.q_y))
			transforEffect:setPosition(t_pos)
			self:addChild(transforEffect,3)
			transforEffect:playActionData("transfor",15,2,-1)
            transforEffect:setScale(1.1)
			local map_title = nil
			if mapid ~= 4101 then
				map_title = createSprite(self,"res/mapui/transfor/"..v.q_tar_mapid..".png",t_pos,cc.p(0.5,0.0),3)
				if map_title ~= nil then
					if v.CS_BOSS ~= nil and v.CS_BOSS == 1 then
						local title_size = map_title:getContentSize()
						local icon_x = t_pos.x
						local icon_y = t_pos.y+title_size.height/2+35
						createSprite(self,"res/mapui/bossmap_icon.png",cc.p(icon_x,icon_y),cc.p(0.5,0.0),3)
					end
				end
			end
			if self:isOpacity(cc.p(v.q_x,v.q_y)) then
				transforEffect:setOpacity(100)
				if map_title then
					map_title:setOpacity(150)
				end	
			else
				if map_title then
					map_title:setOpacity(200)
				end
			end
			if not v.q_sjcs_x then
				transforEffect:setColor(MColor.green)
			end
		end
	end
end

function MainMapLayer:setShaWarTransfor()
	cclog("setShaWarTransfor")
	if self.mapID ~= 4100 then
		return
	end
	-- 1    退出驻守点 94 85              驻守点 97 82
	-- 2    退出驻守点 108 86             驻守点 105 82
	-- 3    退出驻守点 112 83             驻守点 109 79
	-- 3    退出驻守点 116 80             驻守点 113 76
	
	if G_MAINSCENE:checkShaWarState() then
		G_SHAWAR_DATA.transfor = {{q_x=97.0,q_y=82.0,q_tar_mapid=4101.0,index = 1,btnNode = nil, offsetX = 56 - 69 +5, offsetY = 56  + 27 - 5,},
								  {q_x=105.0,q_y=82.0,q_tar_mapid=4101.0,index = 2,btnNode = nil, offsetX = 57 - 53 + 10, offsetY = 56 + 27 - 20,},
								  --{q_x=109.0,q_y=79.0,q_tar_mapid=4101.0,index = 3,btnNode = nil, offsetX = 57 - 53 + 10, offsetY = 56 + 27 - 20,},
								  {q_x=113.0,q_y=76.0,q_tar_mapid=4101.0,index = 4,btnNode = nil, offsetX = 57 - 53 + 10, offsetY = 56 + 27 - 20,},
				   }
	else
		G_SHAWAR_DATA.transfor = {
                                --{q_x=109.0,q_y=79.0,q_tar_mapid=4101.0,index = 3,btnNode = nil, offsetX = 57 - 53 + 10, offsetY = 56 + 27- 20,},
				                 }
	end

	for i=1,4 do
		self:removeChildByTag(4100 + i)
		self:removeChildByTag(4200 + i)
	end

	for k,v in pairs(G_SHAWAR_DATA.transfor) do
		local TempTransforNode = cc.Node:create()
		self:addChild(TempTransforNode, 5000, 4100 + v.index)

		local transforEffect = Effects:create(false)
		transforEffect:setAnchorPoint(cc.p(0.5,0.5))
		local t_pos = self:tile2Space(cc.p(v.q_x,v.q_y))
		local pos = cc.p(t_pos.x + v.offsetX, t_pos.y + v.offsetY)
		transforEffect:setPosition(pos)
		TempTransforNode:addChild(transforEffect,3, 2)
        if G_SHAWAR_DATA.holdData and G_SHAWAR_DATA.holdData[index] and G_SHAWAR_DATA.holdData[index].HoldID ~= "" then
		    transforEffect:playActionData("shachengtrans-no",15,2,-1)
        else
            transforEffect:playActionData("shachengtrans",15,2,-1)
        end
		addEffectWithMode(transforEffect, 3)


		local hodeCallBack = function()
                        self:cleanAstarPath(true,true)
			g_msgHandlerInst:sendNetDataByTableExEx(SHAWAR_CS_DEALHOLD, "DealHoldProtocol", {holeIndex = v.index, dealType = 2})
		end		
		local goInCallBack = function()
            local myFactionId = MRoleStruct:getAttr(PLAYER_FACTIONID)
            local isAttr = false
            for k,v in pairs(G_SHAWAR_DATA.startInfo.Attack) do
                if myFactionId ~= 0 and v == myFactionId then
                    isAttr = true
                    break
                end
            end
            if isAttr then 
			     g_msgHandlerInst:sendNetDataByTableExEx(SHAWAR_CS_DEALHOLD, "DealHoldProtocol", {holeIndex = v.index, dealType = 1})
            else
                TIPS( getConfigItemByKeys("clientmsg",{"sth","mid"},{15700,-18})) 
            end
		end

        local exitHold = function()
            g_msgHandlerInst:sendNetDataByTableExEx(SHAWAR_CS_DEALHOLD, "DealHoldProtocol", {holeIndex = v.index, dealType = 3})
        end
      

		local tempBtnNode = cc.Node:create()
		self:addChild(tempBtnNode, 9000, 4200 + v.index)
		local tempItem1 = createMenuItem( tempBtnNode , "res/empire/shaWar/btn2.png" , cc.p(pos.x - 120, pos.y + 80), hodeCallBack)

		local tempItem2 = createMenuItem( tempBtnNode , "res/empire/shaWar/btn1.png" , cc.p(pos.x + 120, pos.y + 80 ), goInCallBack)

        local tempItem3 = createMenuItem( tempBtnNode , "res/empire/shaWar/cheli.png", cc.p(pos.x + 120, pos.y + 80), exitHold)

		tempItem1:setVisible(false)
		tempItem2:setVisible(false)
        tempItem3:setVisible(false)

		v.btnNode = tempBtnNode
		v.btnNode.holdBtn = tempItem1
		v.btnNode.holdBtnCallBack = hodeCallBack
		v.btnNode.goinBtn = tempItem2
		v.btnNode.goinBtnCallBack = goInCallBack
        v.btnNode.shaExitBtn = tempItem3
	end
end

function MainMapLayer:shaWarCheckTouchItem( touch)
	if true or self.mapID ~= 4100 or nil == G_SHAWAR_DATA.transfor or not G_MAINSCENE:checkShaWarState() then 
		return false
	end

	for k,v in pairs(G_SHAWAR_DATA.transfor) do
		if v.btnNode then
			local pt = v.btnNode:convertTouchToNodeSpace(touch)
			local tabBtn = {{v.btnNode.holdBtn,v.btnNode.holdBtnCallBack}, 
							{v.btnNode.goinBtn,v.btnNode.goinBtnCallBack}
							}
			for i=1,#tabBtn do
				local node = tabBtn[i][1]
				local callback = tabBtn[i][2]
				if node and node:isVisible() then
					local pos = cc.p(node:getPosition())
					local conSize = node:getContentSize()
					local rect = cc.rect(pos.x - conSize.width/2, pos.y - conSize.height/2, conSize.width, conSize.height)
					if cc.rectContainsPoint(rect, pt) then
	       		   		if callback then
	       		   			callback()
	       				end
       					return true
	       			end	
				end
			end
		end
	end
	return false
end

function MainMapLayer:ShaWarTransforCheck()
	--dump(G_SHAWAR_DATA.transfor, "G_SHAWAR_DATA.transfor")
	if self.mapID ~= 4100 or nil == G_SHAWAR_DATA.transfor then 
		return 
	end
	
	local role_title_pos = G_ROLE_MAIN.tile_pos
	local MyfacID = require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)
	local defenseID = G_SHAWAR_DATA.startInfo.DefenseID	

	for k,v in pairs(G_SHAWAR_DATA.transfor) do
		if v.btnNode then
			local status = self:isNearBanner(1.5, cc.p(v.q_x, v.q_y))
			local tempHoldBtnVis = false
			local tempGoinBtnVis = false

			local index = v.index
			local specIndex = 3
			local holdData = G_SHAWAR_DATA.holdData and G_SHAWAR_DATA.holdData[index] or nil

			if status then
				--print("status true")
				if G_MAINSCENE:checkShaWarState() then
					--dump(holdData, "holdData")
					--dump(MyfacID , "MyfacID")
					if holdData and holdData.HoldID and holdData.HoldID ~= "" then
						local isMyFaction = false
						-- for i=1, #holdData.facID do
						-- 	if holdData.facID[i] ~= 0 and MyfacID == holdData.facID[i] then
						-- 		isMyFaction = true
						-- 		break
						-- 	end
						-- end
						local tempHoldFacId = holdData.facID or 0
						if G_ROLE_MAIN:getFactionRelation(tempHoldFacId, 3) then
							isMyFaction = true
						elseif G_ROLE_MAIN:getFactionRelation(tempHoldFacId, 1) then
							isMyFaction = true
						end

						if not isMyFaction then
							--print("isMyFaction not ")
							tempGoinBtnVis = false
							tempHoldBtnVis = false
							--dump(self.shaWarTransforTips, "self.shaWarTransforTips")
							if self.shaWarTransforTips == nil and holdData.HoldID ~= userInfo.currRoleStaticId then
								if index ~= specIndex then
									TIPS( {str = game.getStrByKey("shaWar_tranfTips"), type = 1} )
								else
									TIPS( {str = game.getStrByKey("shaWar_tranfTips1"), type = 1} )
								end
								self.shaWarTransforTips = index
							end
						else
							--print("isMyFaction true " )
							--dump(self.shaWarTransforTips, "self.shaWarTransforTips")
							tempGoinBtnVis = true
							tempHoldBtnVis = false
							if index == specIndex then
								if defenseID and (MyfacID ~= defenseID or defenseID == 0) then
									tempGoinBtnVis = false
									if self.shaWarTransforTips == nil and holdData.HoldID ~= userInfo.currRoleStaticId then
										TIPS( {str = game.getStrByKey("shaWar_tranfTips1"), type = 1} )
										self.shaWarTransforTips = index
									end
								end
							elseif holdData.HoldID == userInfo.currRoleStaticId then
								tempGoinBtnVis = false
								tempHoldBtnVis = false								
							end
						end
					else
						--print(" no Holder ... " .. index)
						tempHoldBtnVis = true
						tempGoinBtnVis = true
						if index == specIndex then
							if defenseID ~= MyfacID and defenseID ~= 0 then
								tempGoinBtnVis = false
							elseif defenseID ~= 0 and defenseID == MyfacID then
								tempHoldBtnVis = false
							elseif defenseID == 0 then
								tempGoinBtnVis = false
							end
						end
					end
				else
					if index == specIndex and (self.sendMsgIntoHG == nil or not self.sendMsgIntoHG) then
						g_msgHandlerInst:sendNetDataByTableExEx(SHAWAR_CS_DEALHOLD, "DealHoldProtocol", {holeIndex = index, dealType = 1})
						self.sendMsgIntoHG = true
					end
				end
			else
				--print("status false")
				tempHoldBtnVis = false
				tempGoinBtnVis = false
				if index == specIndex then
					self.sendMsgIntoHG = false
				end
				if self.shaWarTransforTips == index  then
					self.shaWarTransforTips = nil
				end
			end

			-- print(".....tempHoldBtnVis" .. (tempHoldBtnVis and "true" or "false"))
			-- print(".....tempGoinBtnVis" .. (tempGoinBtnVis and "true" or "false"))
			if v.btnNode.holdBtn then
				v.btnNode.holdBtn:setVisible(tempHoldBtnVis)
			end
			if v.btnNode.goinBtn then
				v.btnNode.goinBtn:setVisible(tempGoinBtnVis)
			end
		end

	end
end

function MainMapLayer:setSharWarMapBlock()
	if self.mapID ~= 4100 or true then
		return
	end
	local blockCfg 
	if G_MAINSCENE:checkShaWarState() then
		blockCfg = {{ pos = cc.p(56, 52), width = 1, height = 1,ty = 1 ,value = "0"},
					{ pos = cc.p(70, 44), width = 5, height = 5,ty = 2 ,value = "0"},
					}		
	else
		blockCfg = {{ pos = cc.p(56, 52), width = 1, height = 1,ty = 1 ,value = "1"},
					{ pos = cc.p(72, 44), width = 5, height = 5,ty = 2 ,value = "1"},
					}			
	end
	for k,v in pairs(blockCfg) do
		local pos = v.pos
		self:setBlockRectValue(cc.rect(pos.x, pos.y, v.width, v.height), v.value)
		if v.ty == 1 then
			self:setBlockRectValue(cc.rect(pos.x + v.width, pos.y, 0, 0), "1")
		else
			self:setBlockRectValue(cc.rect(pos.x , pos.y , 0, 0), "1")
		end
	end
end

function MainMapLayer:changeShaWarTransforCol()
    for k, v in pairs( G_SHAWAR_DATA.transfor ) do
        local index = v.index
        local node = self:getChildByTag(4100 + index)
        if node then
            node = node:getChildByTag(2)
            local holdData = G_SHAWAR_DATA.holdData and G_SHAWAR_DATA.holdData[index] or nil

            if G_MAINSCENE:checkShaWarState() and holdData and node then
                if holdData.HoldID ~= "" then
                    node:playActionData("shachengtrans-no",15,2,-1)
                else
                    node:playActionData("shachengtrans",15,2,-1)
                end
            end
        end
    end
end

--设置npc头顶图标
function MainMapLayer:setNpcState( npcid, finish )
	if self.npc_tab[npcid] and self.npc_tab[npcid].showTask then
		--状态  3灰色问号 2黄色叹号 1黄色问号
		self.npc_tab[npcid].showTask(self.npc_tab[npcid],finish)
	end
end
--恢复npc正常状态
function MainMapLayer:setNpcNormal( npcid )
	if self.npc_tab[npcid] and self.npc_tab[npcid].normalState then
		self.npc_tab[npcid].normalState(self.npc_tab[npcid])
	end
end

function MainMapLayer:setNo1NpcName()
	if G_NO_ONEINFO then
		local npcId = {10420, 10421, 10422,10423, 10424,10425}
		for i = 1,#npcId do
			local npcNode = self.npc_tab[npcId[i]]
			if npcNode and G_NO_ONEINFO[i] then
				npcNode:addNo1Name(G_NO_ONEINFO[i])
			end
		end
	end
end

function MainMapLayer:setCharmTopName(name)
	if self.mapID ~= 2100 then return end
	local npcId = 10454
	local npcNode = self.npc_tab[npcId]
	if npcNode then
		npcNode:showCharmTopName(name)
	else
		local npc = require("src/config/NPC")
		local npcCfg = npc[npcId]
		if npcCfg and self.mapID == 2100 then
			self:addNpc(npcCfg.q_x, npcCfg.q_y, tostring(npcCfg.q_resource), npcCfg.q_id, 0)
		end
	end
end

function MainMapLayer:setBiqiKingName()
	if self.mapID ~= 2100 then return end
	local npcId = 10455
	for i = 1, 6 do
		local tempNpcId = npcId + i - 1
		local npcNode = self.npc_tab[tempNpcId]
		if npcNode then
			self.item_Node:removeChildByTag(tempNpcId)
			self.npc_tab[tempNpcId] = nil
		end
	end

	if G_EMPIRE_INFO and G_EMPIRE_INFO.BIQI_KING then 
		if G_EMPIRE_INFO.BIQI_KING.sex   and G_EMPIRE_INFO.BIQI_KING.school 
		 and G_EMPIRE_INFO.BIQI_KING.name and G_EMPIRE_INFO.BIQI_KING.name ~= "" then
				npcId = G_EMPIRE_INFO.BIQI_KING.school + (G_EMPIRE_INFO.BIQI_KING.sex -1) * 3 + 10454
				--dump(npcId, "npcId")
				if npcId < 10455 and npcId > 10460 then
					npcId = 10455
				end
		else
			npcId = 10455
		end
	end

	local npcCfg = getConfigItemByKey("NPC","q_id", npcId)
	if npcCfg and self.mapID == 2100 then
		self:addNpc(npcCfg.q_x, npcCfg.q_y, tostring(npcCfg.q_resource), npcCfg.q_id, 0)
	end
end

function MainMapLayer:setShaKingName()
	if self.mapID ~= 3100 then return end
	local npcId = 10468
	for i = 1, 6 do
		local tempNpcId = npcId + i - 1
		local npcNode = self.npc_tab[tempNpcId]
		if npcNode then
			self.item_Node:removeChildByTag(tempNpcId)
			self.npc_tab[tempNpcId] = nil
		end
	end

	if G_SHAWAR_DATA and G_SHAWAR_DATA.KING then 
		if G_SHAWAR_DATA.KING.sex   and G_SHAWAR_DATA.KING.school 
		 and G_SHAWAR_DATA.KING.name and G_SHAWAR_DATA.KING.name ~= "" then
				npcId = G_SHAWAR_DATA.KING.school + (G_SHAWAR_DATA.KING.sex -1) * 3 + 10467
				--dump(npcId, "npcId")
				if npcId < 10468 and npcId > 10473 then
					npcId = 10468
				end
		else
			npcId = 10468
		end
	end

	local npcCfg = getConfigItemByKey("NPC","q_id", npcId)
	if npcCfg and self.mapID == 3100 then
		self:addNpc(npcCfg.q_x, npcCfg.q_y, tostring(npcCfg.q_resource), npcCfg.q_id, 0)
	end
end

function MainMapLayer:showTowerResult(netData, delTime)
	local func = function()
		self.isOver = true
		self.towerResTime = nil
		local ret = require("src/layers/fb/fbSubHall/FBTowerResult").new(self.towerEndData)
		G_MAINSCENE:addChild(ret, 100)
		self.towerResult = ret
		self.towerEndData = nil
	end

	self.towerEndData = netData or self.towerEndData
	G_MAINSCENE:showArrowPointToMonster(false)
	if self.towerEndData and self.isfb then
		if delTime and delTime > 0 then
			if not self.towerResTime then
				self.towerResTime = startTimerAction(self.item_Node, delTime, false, func)
			end
			self.timeLeft = delTime
			self.isOver = false
			if self.labTimeTitle then
				self.labTimeTitle:setString("拾取倒计时")
			end
			if self.labTime then
				self.labTime:setString("" .. delTime)
			end
		elseif not delTime or delTime == 0 then
			if self.towerResTime then
				self.item_Node:stopAction(self.towerResTime)
			end
			if self.timeBg then
				self.timeBg:setVisible(false)
			end
			func()
		end
	end
end

function MainMapLayer:showRobMineResult(robMineEndData, delTime)
    local robMineEndData = robMineEndData or {}
    self.isOver = true
    local ret = require("src/layers/story/robMine/StoryRobMineResult").new(robMineEndData)
    G_MAINSCENE:addChild(ret, 201)
end






function MainMapLayer:onRoleExit(buff)
	local proto = g_msgHandlerInst:convertBufferToTable("FrameEntityExitProtocol", buff)

	for k,v in pairs(proto.ids) do
		local objId = v

		if objId == self.role_id then
			print("!!!!!!!!!!!!!!!error  remove self!!!")
			return
		end		
		-- cclog("onRoleExit........ id:"..objId)
		if self.pick_item and self.pick_item == objId then
			self.pick_item = nil
		end
		local select_node = self.select_monster or self.select_role
		if select_node and tolua.cast(select_node,"cc.Node") and select_node:getTag() == objId then
			if self.monster_head and tolua.cast(self.monster_head,"cc.Node") then
				--removeFromParent(self.monster_head)
				--self.monster_head = nil
                self.monster_head:updateBloodAsUnknow()
			end
			self.select_role = nil
			self:resetSelectMonster()
            if  game.getAutoStatus()== AUTO_ATTACK and select_node:getType()>=12 then
                game.setAutoStatus(0)
            end
		end
		if self.select_mine and tolua.cast(self.select_mine,"SpriteMonster") and self.select_mine:getTag() == objId then
			self.select_mine = nil
		end
		self.item_Node:removeChildByTag(objId)
		if self.goods_tab[objId] then
			self.goods_tab[objId] = nil
			if self.on_pickup and self.has_send_pickup and self.has_send_pickup == objId then
				self.on_pickup = nil
				self.has_send_pickup = nil
				local status = game.getAutoStatus()
				if status == AUTO_ATTACK or status == AUTO_PICKUP then
					self:autoPickUp()
					resetGmainSceneTime()
				end
			end
		end
		self.pet = self.pet or {}
		self.pet[objId] = nil
		self.pet_tab[objId] = nil
		self.mineTab[objId] = nil
		self.role_tab[objId] = nil
		self.monster_tab[objId] = nil
		
		self.hide_flags[objId] = nil
		self.move_paths[objId] = nil
		self.spec_tab[objId] = nil

		MRoleStruct:objExitScene(objId)

		if self.BannerFlagId == objId then
			removeFromParent(self.BannerBtn)
			self.BannerBtn = nil
			self.BannerFlagId = 0
			self:NearBannerCheck()					
		end
	end
	if self.carry_owner_objid and self.carry_owner_objid[objId] then
		self.carry_owner_objid[objId] = nil
	end
	if self.banner_owner_objid and self.banner_owner_objid[objId] then
		self.banner_owner_objid[objId] = nil
	end
	if self.isfb and self.isOver and (not (self.goods_tab and tablenums(self.goods_tab) > 0)) then
		self:exitFbTimeStart()
	end
	-- if userInfo.lastFbType == commConst.CARBON_TOWER 
	-- 	and self.towerEndData 
	-- 	and self.towerEndData.isWin 
	-- 	and (not (self.goods_tab and tablenums(self.goods_tab) > 0)) then
	-- 	self:showTowerResult(nil, 0)
	-- end
end


-- function MainMapLayer:onSinging(buff,msgid)
-- 	local objId,tarId,stype,skillId,tpos_x,tpos_y = buff:readByFmt("iicsss")
-- 	--local objId,stype,skillId,tpos_x,tpos_y = buff:readByFmt("icsss")
-- 	--local tarId = 0
-- 	log("oid"..objId .. "hurt" .."targetId")
-- 	if not self.has_loadmap then
-- 		return
-- 	end
-- 	if  self.role_id ~= objId and skillId ~= 7000 then
-- 		local role_item = self:isValidStatus(objId)
-- 		if not  role_item then return end
-- 		local target_item = self:isValidStatus(tarId)
-- 		local r_pos = cc.p(role_item:getPosition())
-- 		local m_pos = cc.p(0,0)
-- 		if target_item then
-- 			m_pos = cc.p(target_item:getPosition())
-- 		else
-- 			m_pos = self:tile2Space(cc.p(tpos_x,tpos_y))
-- 		end
		
-- 		if role_item:getType() < 20 then

-- 			local dir = getDirBrPos(cc.p((m_pos.x-r_pos.x),(m_pos.y-r_pos.y)),role_item:getCurrectDir())
-- 			role_item:setSpriteDir(dir)
-- 			role_item:standed()
-- 			local play_times = {[6000]= 0.5,[6001]=0.65}
-- 			local ptime = play_times[skillId] or 0.45
-- 			local attFunc = function()
-- 				local role_item = self:isValidStatus(objId)
-- 				if role_item then
-- 					--local pos = self:tile2Space(self:space2Tile(r_pos))
-- 					--role_item:setPosition(pos)
-- 					--local dir = getDirBrPos(cc.p((m_pos.x-r_pos.x),(m_pos.y-r_pos.y)),role_item:getCurrectDir())
-- 					--role_item:setSpriteDir(dir)
-- 					role_item:attackOneTime(ptime,cc.p(0,0))
-- 					--print("r_pos:",math.floor(r_pos.x),"    ",math.floor(r_pos.y) ,"pos:",math.floor(pos.x),"    ",math.floor(pos.y))
-- 					--role_item:attackToPos(0.45,cc.p(0,0))
-- 				end
-- 			end
-- 			performWithDelay(self.item_Node,attFunc,0.0)

-- 			self.attack_pos = r_pos
-- 			if skillId > 2000 and skillId ~= 4001 then
-- 				self:playSkillEffect(0.4,skillId,role_item,target_item,m_pos)
-- 			end
			
-- 			AudioEnginer.randMonsterMus(role_item:getMonsterId(),1)

-- 			local stand = function() 
-- 				local role_item = self:isValidStatus(objId)
-- 				if role_item and ACTION_STATE_IDLE == role_item:getCurrActionState() then
-- 					role_item:standed()
-- 				end
-- 			end
-- 			local delay_time = ptime + 0.55
-- 			--if skillId == 6000 then delay_time = 1.5 end
-- 			performWithDelay(self.item_Node,stand,delay_time)
-- 		else
-- 			if skillId ~= 2004 then
-- 				G_ROLE_MAIN:upOrDownRide_ex(role_item,nil,nil,true)
-- 			end
			
-- 			local playSkill = function()
-- 				local role_item = self:isValidStatus(objId)
-- 				local target_item = self:isValidStatus(tarId)
-- 				if role_item then
-- 					if (getConfigItemByKey("SkillCfg","skillID",skillId,"needStartHand")== 1) then
-- 						role_item:magicUpToPos(0.5,m_pos)
-- 					else
-- 						local dir = getDirBrPos(cc.p((m_pos.x-r_pos.x),(m_pos.y-r_pos.y)),role_item:getCurrectDir())
-- 						role_item:setSpriteDir(dir)
-- 						role_item:attackOneTime(0.35,cc.p(0,0))
-- 						--role_item:attackToPos(0.35,m_pos)
-- 					end
-- 					self:playSkillEffect(0.4,skillId,role_item,target_item,m_pos)
-- 					local stand = function() 
-- 						local role_item = self:isValidStatus(objId)
-- 						if role_item and ACTION_STATE_IDLE == role_item:getCurrActionState() then
-- 							role_item:standed()
-- 						end
-- 					end
-- 					performWithDelay(self.item_Node,stand,1.55)
		
-- 				end
-- 			end

-- 			self.attackinfo[objId] = nil
-- 			playSkill()

-- 		end
-- 	end
-- end

function MainMapLayer:NearBannerCheck( )
	if isBattleArea(self.mapID) then
		local status = false
		if self.BannerFlagId ~= 0 then
			if self.BannerBtn then
				status = self:isNearBanner(3, G_EMPIRE_INFO.BATTLE_INFO.defaultPos)
				self.BannerBtn:setVisible(status)
			end
		end
		if G_MAINSCENE.biqiExitBtn then
			G_MAINSCENE.biqiExitBtn:setVisible(not status)
		end
	end
end

function MainMapLayer:doCheckPosition(tile_pos)
	local setInfoFunc = function(tilePos)
		if G_ROLE_MAIN then
			G_ROLE_MAIN.tile_pos = tilePos
			local status = self:isInSafeArea()
			if status and status < 1 then
				showMapTip()
			end
			if tilePos and self.parent.role_pos_label then 
				self.parent.role_pos_label:setString("("..tilePos.x..","..tilePos.y..")")
			end
			if (not self.parent.all_safe) and self.parent.safe_label then
				if status == -1 then
					self.parent.safe_label:setString(game.getStrByKey("safe_area"))
					self.parent.safe_label:setColor(MColor.green)
				elseif status == -2 then
                    if self.q_map_pk and self.q_map_pk == 0 then
                        self.parent.safe_label:setString(game.getStrByKey("fire_area"))    
                    else
                        self.parent.safe_label:setString(game.getStrByKey("pk_area"))
                    end
					self.parent.safe_label:setColor(cc.c3b(255, 42, 27))
				end
			end
		end
	end
	--local tile_pos = self:getCurTile()
	if G_ROLE_MAIN and not (tile_pos.x == G_ROLE_MAIN.tile_pos.x and tile_pos.y == G_ROLE_MAIN.tile_pos.y) then
		setInfoFunc(tile_pos)
		self:NearBannerCheck()
		self:ShaWarTransforCheck()
	end

	-- Check share task dig icon
	local show_icon = require("src/layers/teamTreasureTask/teamTreasureTaskLayer"):checkShowDigIcon(self.mapID, tile_pos)
	if self.parent then
		if show_icon then
			self.parent:createTaskDigIcon()
		else
			self.parent:removeTaskDigIcon()
		end
	end
end

function MainMapLayer:onMuBai(buff,msgid)
	local proto = g_msgHandlerInst:convertBufferToTable("FrameWorshipProtocol", buff)
    local monster_id,role_id = proto.id,proto.target
    local monster = self:isValidStatus(monster_id)
    local role_item = self:isValidStatus(role_id)
    local monster_modeid = 0
    if monster and role_item then
    	local mPos = self:space2Tile(cc.p(monster:getPosition()))
    	local rPos = self:space2Tile(cc.p(role_item:getPosition()))
    	local old_dir = getDirBrPos(cc.p((rPos.x-mPos.x),(mPos.y-rPos.y)), monster:getCurrectDir(), 0)
	    monster:moveInTheDir(1, cc.p(monster:getPosition()), old_dir)
	    monster_modeid = monster:getMonsterId()

	    local time = 1 * 2 /3
	    if monster_modeid == 9008 then
	    	time = 1 * 1/4
	    end
	    performWithDelay(self.item_Node, function()
	    	local monster = self:isValidStatus(monster_id)
	    	if monster then 
	    	 	monster:stopInTheTime() 
	    	end
	    end, time)

	    performWithDelay(self.item_Node,function()
	    	local monster = self:isValidStatus(monster_id)
	    	if monster then 
	    	 	monster:standed() 
	    	end
	    end, 3)	    
    end
    if role_id == self.role_id then
    	local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{ 1 , 4 })
		if msg_item  then
			local now_time = os.time()
			if (not self.now_time) or  (now_time - self.now_time > 10) then
				local monster_name = getConfigItemByKey("monster","q_id",monster_modeid,"q_name") or ""
				local msgStr = string.format( msg_item.msg , monster_name )
				TIPS( { type = msg_item.tswz , str = msgStr } )
				self.now_time = now_time
			end
		end
	end
end

function MainMapLayer:isInSafeArea(tile_pos,check_all)
	if self.isStory then
        return false
    end
    local status = nil
	local r_tile = tile_pos or G_ROLE_MAIN.tile_pos
	if self.safe_centerpos then
		status = 1
		local distance = math.abs(r_tile.x-self.safe_centerpos.x)+math.abs(r_tile.y-self.safe_centerpos.y)
		if tile_pos then
			if (distance < self.q_radius) then
				self.on_safearea = true
			else
				self.on_safearea = nil
			end
			if self.red_safe_center then
				if self.on_safearea then
					return true
				else
					local distance = math.abs(r_tile.x-self.red_safe_center.x)+math.abs(r_tile.y-self.red_safe_center.y)
					return (distance < self.red_radius)
				end
			else
				return (distance < self.q_radius)
			end
		else 
			if self.on_safearea then
				if distance >= self.q_radius then
					self.on_safearea = nil
					status = -2
				else
					return status
				end
			else
				if distance < self.q_radius then
					self.on_safearea = true
					status = -1
					return status
				end
			end
		end
	else
		if tile_pos then
			return (not not (self.is_all_safe and check_all))
		end
	end
	if self.red_safe_center and (not self.on_safearea) then
		local distance = math.abs(r_tile.x-self.red_safe_center.x)+math.abs(r_tile.y-self.red_safe_center.y)
		if tile_pos then 
			return (distance < self.red_radius)
		else 
			if self.on_red_safearea then
				if distance >= self.red_radius then
					self.on_red_safearea = nil
					status = -2
				end
			else
				if distance < self.red_radius then
					self.on_red_safearea = true
					status = -1
				end
			end		
		end
	end
	return status
end

function MainMapLayer:isNearBanner(midValue, centerPos,tile_pos)
	local r_tile = tile_pos or G_ROLE_MAIN.tile_pos
	if centerPos then
		return cc.pGetDistance(centerPos,r_tile) <= midValue
	else
		return false
	end
end

function MainMapLayer:taskCaiJi(caiji_id,num,isWeddingSys,caijiTaskId)
	-- body
	if self.caiji_id and caiji_id and self.caiji_num and num then
		return
	end

	self.caiji_id = caiji_id or self.caiji_id
	self.caiji_num = num or self.caiji_num
    -------------------------------------------------------
    -- wedding sys
    self.caijiTaskId = caijiTaskId or self.caijiTaskId
    self.isWeddingSys = isWeddingSys or self.isWeddingSys
    -------------------------------------------------------
	if self.caiji_id and (not caiji_id) then
        if not self.isWeddingSys then
            require("src/layers/mission/MissionNetMsg"):sendCollectTask(G_ROLE_MAIN.obj_id, self.caiji_id)
        else
            print("end caiji ---------------------------------------------------------")
            g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_TOUR_OPT, "MarriageTourOpt", {taskId=self.caijiTaskId,step=2})
        end
	elseif caiji_id and num and num > 0 then
        if not isWeddingSys then
            g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_START_PICK_UP, "TaskStartPickProtocol", { matID = caiji_id } )
        else
            print("begin caiji ---------------------------------------------------------")
            g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_TOUR_OPT, "MarriageTourOpt", {taskId=caijiTaskId,step=1})
        end
	 	
	end
	if self.caiji_num and self.caiji_num > 0 then
		self.caiji_num =  self.caiji_num - 1
		self:caiJiAction()
	else
		self.caiji_num = nil
		local state = G_ROLE_MAIN:getCurrActionState()
		if state == ACTION_STATE_DIG then
			G_ROLE_MAIN:standed()
		end
	end
end

function MainMapLayer:onCaiJiAction(ret_tab)
	-- body
	if ret_tab and G_ROLE_MAIN and ret_tab.actionRoleID ~= G_ROLE_MAIN.obj_id then
        
        local loop_index = 0
        self.last_caiji = nil
        local caijiAction_
		caijiAction_ = function()
			local role_item = tolua.cast(self.item_Node:getChildByTag(ret_tab.actionRoleID),"SpritePlayer")
			if role_item then
				local state = role_item:getCurrActionState()
                if state == ACTION_STATE_DIG then
                    if self.last_caiji then
                        role_item:standed()
                    else
                        self.last_caiji = true
                        performWithDelay(role_item,caijiAction_,2)
                    end
                else
                    if loop_index then
                        loop_index = loop_index + 1
                    end
                    if state == ACTION_STATE_IDLE then
                        if loop_index then
                            role_item:stopAllActions()
                            local dir = role_item:getCurrectDir()
                            if ret_tab.matID then
                                local select_npc = tolua.cast(self.item_Node:getChildByTag(ret_tab.matID),"SpriteMonster")
                                if select_npc then
                                    local pos = cc.p(select_npc:getPosition())
                                    pos.y = pos.y + 15
                                    local r_pos = cc.p(role_item:getPosition())
                                    dir = getDirBrPos(cc.p((pos.x-r_pos.x),(pos.y-r_pos.y)),dir)
                                end
                            end
                            role_item:digToTheDir(0.5,dir)
                            self.last_caiji = true
                            performWithDelay(role_item,caijiAction_,2.2-loop_index*0.2)
                            loop_index = nil
                        end
                    elseif loop_index and loop_index < 5 then
                        performWithDelay(role_item,caijiAction_,0.2)
                    end
				end
			end
		end
		caijiAction_()
	end
end

--使用道具
function MainMapLayer:taskUse( useValue )
	local function overFun()
		g_msgHandlerInst:sendNetDataByTableExEx( TASK_CS_REQ_USE_GOT_TASK , "RequestUseGotTaskProtocol" , { taskType = useValue } )
		local state = G_ROLE_MAIN:getCurrActionState()
		if state == ACTION_STATE_DIG then G_ROLE_MAIN:standed() end
	end
	self:caiJiAction( overFun )
end

function MainMapLayer:SpecTitleMap(flg)
	if flg then
		if not self.shaWarHoldPng and self.mapID == 4100 then
			local pos = G_MAINSCENE.map_layer:tile2Space(cc.p(97 , 88 ))
			pos.x = pos.x - 72
			pos.y = pos.y + 80
			self.shaWarHoldPng = createSprite(self, "res/empire/shaWar/map.png",pos, cc.p(0, 0))
			local tempTexture =  self.shaWarHoldPng:getTexture()  
			if tempTexture then
				tempTexture:setAliasTexParameters()
			end
		end
	else
		if self.shaWarHoldPng then
			removeFromParent(self.shaWarHoldPng)
			self.shaWarHoldPng = nil
		end
	end
end

function MainMapLayer:caiJiAction( overFun )
	-- body
	AudioEnginer.playEffect("sounds/actionMusic/caiyao.mp3",false)
	local devourpercent = 0
	local caiji_show = cc.Node:create()
	self.parent:addChild(caiji_show, 99)
	local spritebg = createSprite(caiji_show, "res/common/progress/cj1.png", cc.p(g_scrSize.width/2, 150))
	--spritebg:setScaleX(0.8)
	if G_ROLE_MAIN then 
		G_ROLE_MAIN:upOrDownRide(false) 
		local dir = G_ROLE_MAIN:getCurrectDir()
		if self.caiji_id then
			local select_npc = tolua.cast(self.item_Node:getChildByTag(self.caiji_id),"SpriteMonster")
			if select_npc then
				local pos = cc.p(select_npc:getPosition())
				pos.y = pos.y + 15
				local r_pos = cc.p(G_ROLE_MAIN:getPosition())
				dir = getDirBrPos(cc.p((pos.x-r_pos.x),(pos.y-r_pos.y)),dir)
			end
		end
		G_ROLE_MAIN:digToTheDir(0.5,dir)
	end
	local progress1 = cc.ProgressTimer:create(cc.Sprite:create("res/common/progress/cj2.png"))
	progress1:setPosition(cc.p(158,11))
	progress1:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	progress1:setAnchorPoint(cc.p(0.5,0.5))
	progress1:setBarChangeRate(cc.p(1, 0))
 	progress1:setMidpoint(cc.p(0,1))
 	progress1:setPercentage(0)
 	spritebg:addChild( progress1 )
 	local pro_end = createSprite(progress1, "res/common/progress/cj_p.png", cc.p(-30, 5))
	local update = function()
		if G_ROLE_MAIN then
			local state = G_ROLE_MAIN:getCurrActionState()
			if state == ACTION_STATE_DIG then
				devourpercent = devourpercent + 5
				progress1:setPercentage(devourpercent)
				pro_end:setPosition(cc.p(2.45*devourpercent-30,5))
				if devourpercent >= 100 then 
					removeFromParent(caiji_show) 
					if self["taskCaiJi"] then self:taskCaiJi() end 
					if overFun then overFun() end
				end
			else
				removeFromParent(caiji_show) 
				caiji_show = nil
			end
		end
	end
	schedule(caiji_show,update,0.11 )
	createSprite(spritebg, "res/common/progress/" .. ( overFun == nil and "cjing.png" or "used.png" ) , cc.p(158, 40))
 	--createLabel(caiji_show, game.getStrByKey("task_caiji"), cc.p(g_scrSize.width/2, 150),cc.p(0.5, 0.5),20)
 	--self:runAction(cc.Sequence:create(cc.DelayTime:create(1.6),cc.CallFunc:create(function() self:taskCaiJi() end)))
end



function MainMapLayer:addDigAction()
--	AudioEnginer.playEffect("sounds/actionMusic/wakuang.mp3", false)

	local dig_percent = 0
	local showNode = cc.Node:create()
	self.parent:addChild(showNode, 99)
	local spriteBg = createSprite(showNode, "res/common/progress/cj1.png", cc.p(display.cx, 150))

	if G_ROLE_MAIN then
		G_ROLE_MAIN:upOrDownRide(false)
	end

	local progCtrl = cc.ProgressTimer:create(cc.Sprite:create("res/common/progress/cj2.png"))
	if progCtrl then
		progCtrl:setPosition(cc.p(160, 11))
		progCtrl:setType(cc.PROGRESS_TIMER_TYPE_BAR)
		progCtrl:setBarChangeRate(cc.p(1, 0))
		progCtrl:setMidpoint(cc.p(0, 1))
		progCtrl:setPercentage(0)

		if spriteBg then
			spriteBg:addChild(progCtrl)
		end
	end

	----------------------------------------------------------

	local update = function()
		if G_ROLE_MAIN then
			local state = G_ROLE_MAIN:getCurrActionState()
			if state == ACTION_STATE_IDLE then
				dig_percent = dig_percent + 3.33
				if progCtrl then
					progCtrl:setPercentage(dig_percent)
				end
				if dig_percent >= 100 then
					removeFromParent(showNode)
					showNode = nil

					----------------------------------------------------------

					local MainRoleId = 0
					if userInfo then
						MainRoleId = userInfo.currRoleId
					end
					g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_LETOUT_MONSTER, "LetoutMonsterProtocol", {})
					cclog("TASK_CS_LETOUT_MONSTER sent. role_id = %s.", MainRoleId)
				end
			else
				removeFromParent(showNode)
				showNode = nil
			end
		end
	end

	schedule(showNode, update, 0.1)
end


function MainMapLayer:showDangerTime(time)
	if not time or time <= 0 then
		return
	end


	local layer = require("src/base/DangerEffectLayer").new()
	layer:EffectUpdate()
	self.mDangerLayer = layer
	G_MAINSCENE.base_node:addChild(layer)
	layer:setLocalZOrder(200)

    local tmpStr = game.getStrByKey("rescue_princess_danger");
    if userInfo and userInfo.lastFbType == commConst.CARBON_MULTI_GUARD then  -- 多人守卫
        tmpStr = game.getStrByKey("multiDanger");
        --local labelBg = createScale9Sprite(layer, "res/common/scalable/1.png", cc.p(g_scrSize.width/2, g_scrSize.height/2+90), cc.size(g_scrSize.width*2/3, 50));
        local labelBg = createSprite(layer, "res/fb/multiple/13.png", cc.p(g_scrSize.width/2, g_scrSize.height/2+158));
        if labelBg ~= nil then
            labelBg:setScale(1);
            local actions = {};
            for i=1, 5 do
                actions[#actions+1] = cc.ScaleTo:create( 0.2  , 1.2 );
                actions[#actions+1] = cc.EaseBackInOut:create( cc.ScaleTo:create( 0.4  , 1 ) );
            end
            actions[#actions+1] = cc.CallFunc:create(function()
                labelBg:removeFromParent();
            end);
            labelBg:runAction(cc.Sequence:create(actions));
        end
    else
        createLabel(layer, tmpStr, cc.p(g_scrSize.width/2, g_scrSize.height/2+90), nil, 26, true):setColor(MColor.red)
    end

	startTimerAction(layer, 1, true, function()
		if time > 1 then
			time = time - 1
		else
			removeFromParent(layer)
		end
	end)
end

function MainMapLayer:onEntityHurt(entity, objId, hurt, cur_blood, ishit, resist_type)

	log("[MainMapLayer:onEntityHurt] called. objId = %d, hurt = %d, cur_blood = %d, resist_type = %d.", objId, hurt, cur_blood, resist_type)

	local buffs = g_buffs[objId]
	if buffs == nil then
		return
	end

	for k, v in pairs(buffs) do
		local buff_hurttype = getConfigItemByKey("buff", "id", tonumber(k), "lx")
		log("[MainMapLayer:onEntityHurt] lx = %d.", buff_hurttype)
		if buff_hurttype == 129 then	-- magic immunity
			if resist_type == 2 then	-- magic resist
				log("[MainMapLayer:onEntityHurt] magic resist.")
				local chart = require("src/layers/char/CharText").new(entity:getTitleNode(), 3.0, HEADTEXT_IMMUNITY, cc.p(1, 1))
			end
		end

		if resist_type == 4 then
			require("src/layers/char/CharText").new(entity:getTitleNode(), 3.0, HEADTEXT_JOUK, cc.p(1, -10))
		end
	end

end

--------------------------------------------------------------------------------------------------------------------------------------------
-- FbMapLayer -- 重载的基类函数
function MainMapLayer:updateMonsterInfo(flushRoad1, flushRoad2, flushRoad3, flushRoad4)
end

function MainMapLayer:UpdateMultiCarbonInfo()
end
--------------------------------------------------------------------------------------------------------------------------------------------

function MainMapLayer:networkHander(buff,msgid)
	local switch = {
		[FRAME_SC_ENTITY_EXIT] = function()
			if (not G_ROLE_MAIN) or (not self.has_loadmap) then return end
			self:onRoleExit(buff)
		end,
		-- [SKILL_SC_SINGING] = function()
		-- 	if (not G_ROLE_MAIN) or (not self.has_loadmap) then return end
		-- 	self:onSinging(buff)
		-- end,
        [FRAME_SC_WORSHIP] = function()
        	if (not G_ROLE_MAIN) or (not self.has_loadmap) then return end
			self:onMuBai(buff)
        end,
		[COPY_SC_ENTERCOPY] = function() 
            local proto = g_msgHandlerInst:convertBufferToTable("EnterCopyRetProtocol", buff);          

            self.isfinished = false;
            self.currCircle = proto.curCircle;
            self.timeLeft = proto.remainTime;
            
            if userInfo.lastFbType ~= commConst.CARBON_MULTI_GUARD and userInfo.lastFbType ~= commConst.CARBON_PRINCESS then
            	self.timeLeft = self.timeLeft-2
            	self.currNum = 0
            	if self.monsterData and self.monsterData[self.currCircle] and self.monsterData[self.currCircle][3] then
            		self.currNum = tonumber(self.monsterData[self.currCircle][3])
            	end
	            self.deadNum = 0
                if self.updateProgress then
	                self:updateProgress()
                end
	        else
	        	if self.timeLeft == 0 then
	        		local timeTostart = 8
					local pic1 = createSprite(G_MAINSCENE,"res/fb/multiple/09.png",cc.p(g_scrSize.width/2,500/640*g_scrSize.height),cc.p(0.5,0.5),102)
					local pic2 = createSprite(G_MAINSCENE,"res/fb/multiple/08.png",cc.p(g_scrSize.width/2,500/640*g_scrSize.height),cc.p(0.5,0.5),102)
					local timeToStartPic = MakeNumbers:create("res/component/number/3.png",timeTostart,-2)
					timeToStartPic:setPosition(cc.p(g_scrSize.width/2,445/640*g_scrSize.height))
					--timeTostartPic:setLocalZOrder(102)
					G_MAINSCENE:addChild(timeToStartPic)
					--local a
					local cb = function()
						timeTostart = timeTostart-1
						if timeTostart > 0 then
							if timeToStartPic then
								removeFromParent(timeToStartPic)
								timeToStartPic=nil
							end
							timeToStartPic = MakeNumbers:create("res/component/number/3.png",timeTostart,-2)
							timeToStartPic:setPosition(cc.p(g_scrSize.width/2,445/640*g_scrSize.height))
							--timeTostartPic:setLocalZOrder(102)
							G_MAINSCENE:addChild(timeToStartPic)
						else
							if pic1 then removeFromParent(pic1)  pic1 = nil end
							if pic2 then removeFromParent(pic2)  pic2 = nil end
							if timeToStartPic then removeFromParent(timeToStartPic) timeToStartPic = nil end
						end
					end
					schedule(pic2,cb,1.0)
	        	end
	        end
	        dump(self.timeLeft)
            --G_ROLE_MAIN:upOrDownRide(false)
        end,

        [COPY_SC_MULTICOPY_FLUSH_ROAD] = function()
            local proto = g_msgHandlerInst:convertBufferToTable("MultiCopyFlushRoadProtocol", buff);
            if proto then
                self.currCircle = proto.currCircle;
                local flushRoad1 = proto.flushRoad1;
                local flushRoad2 = proto.flushRoad2;
                local flushRoad3 = proto.flushRoad3;
                local flushRoad4 = proto.flushRoad4;

                if userInfo and userInfo.lastFbType == commConst.CARBON_MULTI_GUARD then
                    self:updateMonsterInfo(flushRoad1, flushRoad2, flushRoad3, flushRoad4);
                    self.m_nowPrizeCircle = proto.currentPrizeStage;
                    self:UpdateMultiCarbonInfo();
                elseif userInfo and userInfo.lastFbType == commConst.CARBON_PRINCESS then
                    self:updateMonsterInfo(flushRoad1, flushRoad2, flushRoad3, flushRoad4);
                end
	        	
            end
        end,

        [COPY_SC_DONEXTCIRCLE] = function() 
            
            local proto = g_msgHandlerInst:convertBufferToTable("DoNextCircleProtocol", buff)
            
            self.currCircle = proto.curCircle;
            self.timeLeft = proto.remainTime;

            cclog("[COPY_SC_DONEXTCIRCLE] called. circle=[%d], time=[%d].", self.currCircle, self.timeLeft)
            if userInfo.lastFbType ~= commConst.CARBON_MULTI_GUARD and userInfo.lastFbType ~= commConst.CARBON_PRINCESS and userInfo.lastFbType ~= 3 then
	            if userInfo.lastFbType == 4 then
	            	userInfo.currDefenseFloor = proto.curCircle;
	            	setLocalRecordByKey(2,"subFbType",""..userInfo.currDefenseFloor)
	            	--self:updateMonsterInfo()

		        	if userInfo.currDefenseFloor == commConst.CARBON_MULTI_GUARD then
						self:showDangerTime(10)
					end	            	
                elseif userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER then
                    if self.m_dragonCarbon == commConst.DRAGON_BLOOD_CITY then
                        self.m_dragonCollect = self.m_dragonCollect + 1;

                        local cfgReqStr = "";
                        cfgReqStr = self.m_dragonReq .. "  ("  .. self.m_dragonCollect .. "/3)";
                        if self.m_dragonProgressLal then
                            self.m_dragonProgressLal:setString(cfgReqStr);
                        end
                    end

                    -- 交由下一秒显示
                    self.m_willNext = true;
	            else
	            	self.currNum = 0
	            	if self.monsterData and self.monsterData[self.currCircle] and self.monsterData[self.currCircle][3] then
	            		self.currNum = tonumber(self.monsterData[self.currCircle][3])
	            	end
		            self.deadNum = 0
		            self:updateProgress()
		            self.isNewRound = 1
	            end
	        elseif userInfo.lastFbType == 3 then
	        	if self.towerResult then
	        		removeFromParent(self.towerResult)
	        		self.towerResult = nil
	        	end
	        	if self.labTimeTitle then
	        		self.labTimeTitle:setString("战斗倒计时")
	        	end
	        	if self.timeBg then
					self.timeBg:setVisible(true)
				end
				if self.labTime then
					self.labTime:setString("" .. self.timeLeft)
				end
	        	self.isOver = false
            	self.currNum = 0
            	if self.monsterData and self.monsterData[self.currCircle] and self.monsterData[self.currCircle][3] then
            		self.currNum = tonumber(self.monsterData[self.currCircle][3])
            	end
		        self.deadNum = 0
		        if self.currCircle == 1 then
					local fbId = userInfo.lastFb
					local itemDate = getConfigItemByKey("FBTower", "q_id", fbId)
					if itemDate and itemDate.q_copyLayer then
						TIPS( { str = string.format("开始挑战通天塔第%d层", tonumber(itemDate.q_copyLayer or 1) ) } )
					end
		        else
	        		TIPS({str = string.format(game.getStrByKey("fb_monsterComm"), tonumber(self.currCircle)) })
	        	end
	        	--self:showNextCircleMonsterWay()
	        else
                -- 多人守卫
                if self.currCircle%5 == 0 then
                    self:showDangerTime(3.2);
                else
                    TIPS({str = string.format(game.getStrByKey("fb_monsterComm"), tonumber(self.currCircle)) })
                end
	        end
        end,

        [COPY_SC_GUARDEXP] = function()
        	cclog("COPY_SC_GUARDEXP")
        	local total = buff:popInt()
        	local curr = buff:popInt()
        	local totalNode = MakeNumbers:create("res/component/number/9.png",total-curr,-2)
        	local currNode = MakeNumbers:createWithSymbol("res/mainui/number/2.png",curr,0)
        	local bg = createSprite(G_MAINSCENE.base_node,"res/fb/defense/expGet.png",cc.p(g_scrSize.width/2,g_scrSize.height/2-100),cc.p(0.5,0.5))
        	
        	bg:addChild(totalNode)
        	bg:addChild(currNode)
        	currNode:setPosition(cc.p(270,140))
        	totalNode:setPosition(cc.p(84,50))
        	--local ct = currNode:getChildren()
        	-- for k,v in pairs(ct) do
        	-- 	v:runAction(cc.Sequence:create(cc.FadeOut:create(0.5),cc.MoveTo:create(0.3,cc.p(286,90))))
        	-- end
        	currNode:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.MoveTo:create(1.0,cc.p(90,50))),
        										cc.Hide:create(),
        										cc.CallFunc:create(function() 
        																removeFromParent(totalNode) 
        																totalNode = MakeNumbers:create("res/component/number/9.png",total,-2)
        																bg:addChild(totalNode)
        																totalNode:setPosition(cc.p(84,50))
        															end),
        										cc.DelayTime:create(3.0),
        										cc.CallFunc:create(function() removeFromParent(bg) end)
        										))
        	--bg:runAction(cc.Sequence:create(cc.DelayTime:create(3.0),))
    	end,

        [COPY_SC_COPYREWARD] = function() 
        	cclog("COPY_SC_COPYREWARD")
        	
        	local retTable = g_msgHandlerInst:convertBufferToTable("CopyRewardProtocol", buff)
            -- 0表示失败，1表示成功
            -- 针对多人守卫，每波发奖，2表示发奖
        	local isWin = (retTable.copyResult == 1);
        	
        	if isWin then
	        	self.time = retTable.copyUseTime
	        	--cclog("time"..self.time)
	        	reward = {}
	        	reward.Num = retTable.rewardCount
	        	cclog("COPY_SC_COPYREWARD reward.Num~~~~~~~~~~~~~~"..reward.Num)
	        	reward.item={}
	        	local tempData = retTable.info
	        	for i=1, reward.Num do
	        		reward.item[i]={tempData[i].rewardId, tempData[i].rewardCount, tempData[i].bind, tempData[i].strength}
	        	end
	        	reward.hasLottery = false

	        	self.reward = reward
	        	if userInfo.lastFbType ~= commConst.CARBON_MULTI_GUARD then
	        		self:updateProgress(true)
	        	end
	        else
                -- 失败
                if retTable.copyResult == 0 then
	        	    game.setAutoStatus(0)
                elseif retTable.copyResult == 2 and userInfo.lastFbType == commConst.CARBON_MULTI_GUARD then
	        	    reward = {}
	        	    reward.Num = retTable.rewardCount
	        	    reward.item={}
	        	    local tempData = retTable.info
	        	    for i=1, reward.Num do
	        		    reward.item[i]={tempData[i].rewardId, tempData[i].rewardCount, tempData[i].bind, tempData[i].strength}
	        	    end
	        	    reward.hasLottery = false

	        	    self.reward = reward
                end
				--self:showOverView(false)
	        end

	        if userInfo.lastFbType == commConst.CARBON_MULTI_GUARD then
                -- 真正结束
                if retTable.copyResult ~= 2 then
                    -- 多人守卫 主角如果死亡次数过多可能会隐身了
                    if G_ROLE_MAIN then
                        G_ROLE_MAIN:setVisible(true);
                    end
                    if G_MAINSCENE.relive_layer then
        	            removeFromParent(G_MAINSCENE.relive_layer)
        	            G_MAINSCENE.relive_layer = nil;
    	            end
                    
                    if isWin then
                        -- 赢的情况下，直接算打过第5波
                        self.m_nowPrizeCircle = 5;
                    end
                    self:UpdateMultiCarbonInfo();

        		    performWithDelay(self.item_Node,function() self:showOverView(isWin) end, 2.0)
                else
                    -- 声望、经验数目
                    local expNum = 0;
                    local prestigeNum = 0;
                    ---------------------------------------------------------------------------------------------
		            for i=1, self.reward.Num do
                        ---------------------------------------------------------------------------------------------
                         if self.reward.item[i][1] == commConst.ITEM_ID_PRESTIGE then
                            prestigeNum = prestigeNum + tonumber(self.reward.item[i][2]);
                        elseif self.reward.item[i][1] == commConst.ITEM_ID_EXP then
                            expNum = expNum + tonumber(self.reward.item[i][2]);
                        end
                        ---------------------------------------------------------------------------------------------
                    end

                    if expNum > 0 then
                        -- 经验展示
		                self:showExpNumer(expNum, nil, 0.1, "res/mainui/number/4.png" , commConst.ePickUp_XP )
                    end
	                if prestigeNum > 0 then
		                -- 声望展示
		                self:showExpNumer(prestigeNum, nil, 0.1, "res/mainui/number/5.png" , commConst.ePickUp_Prestige)
                    end
                end
        	elseif userInfo.lastFbType == 3 then  --通天塔副本失败会走这个
        		local towerEndData = {}
        		towerEndData.isWin = isWin
        		self:showTowerResult(towerEndData, 0)
            elseif userInfo ~= nil and userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER then
                self:RemoveMasterThunderEff(isWin);                
        	else
        		performWithDelay(self.item_Node,function() self:showOverView(isWin) end, 1.0)
        	end
        end,

        [COPY_SC_CALLFRIENDRET] = function()
        	cclog("COPY_SC_CALLFRIENDRET")
        	--实体id 怪物id 名字 武器 衣服 坐骑 翅膀 战斗力 职业 血量
        	local retTable = g_msgHandlerInst:convertBufferToTable("CallFriendRetProtocol", buff)

        	params={}
		    params[ROLE_SCHOOL] = retTable.friendSchool
		    params[PLAYER_SEX] = retTable.friendSex
--		    if params[ROLE_SCHOOL] == 2 then params[PLAYER_SEX] = 2 end
		    params[ROLE_HP] = retTable.friendHp
		    params[ROLE_MAX_HP] = retTable.friendHp
		    params[ROLE_NAME] = retTable.friendName
		    --cclog("bring name "..params[ROLE_NAME])
		    params[PLAYER_EQUIP_WEAPON] = retTable.friendWeapon
		    params[PLAYER_EQUIP_UPPERBODY] = retTable.friendCloth
		    params[PLAYER_EQUIP_WING] = retTable.friendWing
		    dump(params, "params")
            -- 下次创建备用，主角退出地图删除
            self.m_friendsData[retTable.friendId] = params
       	end,

       	[COPY_SC_NOTIFYSTATUEHP] = function()
       		local proto = g_msgHandlerInst:convertBufferToTable("CopyNotifyStatueHpProtocol", buff)

       		self.currBlood = proto.statueHp;
            
            if self.progress ~= nil then
       		    self.progress:setPercentage(self.currBlood*100/tonumber(self.fbData.statuelife))
            end
            if self.labProgress ~= nil then
			    self.labProgress:setString(tostring(self.currBlood.."/"..self.fbData.statuelife))
            end

            -- 主动更新公主头上的血条
            if userInfo ~= nil and userInfo.lastFbType ~= nil and (userInfo.lastFbType == commConst.CARBON_MULTI_GUARD or userInfo.lastFbType == commConst.CARBON_PRINCESS) then
                if self.MulityObjId ~= nil then
                    self:bloodupdate(self.MulityObjId, self.currBlood, true);
                end
            end
       	end,

       	[COPY_SC_ONMONSTERKILL] = function()
       		if (userInfo == nil) then
                return;
            end

            local proto = g_msgHandlerInst:convertBufferToTable("CopyOnMonsterKillProtocol", buff)

            -- 杀死了一个怪物
       		local id = tonumber(proto.monsterSid);
            local carbonId = proto.copyId;

            -- 针对断线重连情况，v[2] 总数不变, 并且每一项都得重新计算
            if (userInfo.lastFbType == commConst.CARBON_MULTI_GUARD or userInfo.lastFbType == commConst.CARBON_PRINCESS) then
                if proto.monsters and #(proto.monsters) > 0 then
                    for i=1, #(proto.monsters) do
                        local tmpKilledMonsterNum = proto.monsters[i].monsterNum;
                        local tmpKilledId = tonumber(proto.monsters[i].monsterSid);
                        if self.monsterStatics then
	                        for k,v in pairs(self.monsterStatics) do
	       			            if tmpKilledId == v[1] then
	                                if v[2] > 0 and v[2] >= tmpKilledMonsterNum then
	                                    v[3]:setString(game.getStrByKey("fb_numLeft2") .. " " .. (v[2]-tmpKilledMonsterNum))
	                                end
	                                break;
	       			            end
	       		            end
	       		        end
                    end
                end
            elseif userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER then
                if carbonId == commConst.DRAGON_BABEL then
                    self.m_dragonCollect = self.m_dragonCollect + 5;

                    local cfgReqStr = "";
                    if self.m_dragonCollect <= 100 then
                        if self.m_dragonCollect == 100 then
                            self.m_dragonReq = game.getStrByKey("dragonSeal") .. game.getStrByKey("dragonBabel");
                            cfgReqStr = self.m_dragonReq .. "  (0/1)";
                        else
                            -- 第一阶段
                            if self.m_dragonReq then
                                cfgReqStr = self.m_dragonReq .. "  ("  .. self.m_dragonCollect .. "%)";
                            end
                        end
                    else
                        -- 第二阶段
                        if self.m_dragonReq then
                            cfgReqStr = self.m_dragonReq .. "  (1/1)";
                        end
                    end

                    if self.m_dragonProgressLal then
                        self.m_dragonProgressLal:setString(cfgReqStr);
                    end
                elseif carbonId == commConst.DRAGON_ASURA_SHRINE then
                    self.m_dragonCollect = self.m_dragonCollect + 1;

                    local cfgReqStr = "";
                    if self.m_dragonCollect <= 30 then
                        if self.m_dragonReq then
                            cfgReqStr = self.m_dragonReq .. "  ("  .. self.m_dragonCollect .. "/30)";
                        end
                    end

                    if self.m_dragonProgressLal then
                        self.m_dragonProgressLal:setString(cfgReqStr);
                    end
                end
            end
       	end,

        [COPY_SC_SINGLECOPYBOSS] = function()
            local proto = g_msgHandlerInst:convertBufferToTable("CopySingleCopyBossProtocol", buff)

            self.m_dragonBossGuid = proto.bossid;
            if userInfo and userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER then
                if self.m_dragonCarbon == commConst.DRAGON_BABEL then
                    self:resetHangup();
                    self.select_role = nil;
                    self:resetSelectMonster();

                    -- 捆住通天教主
                    if self.item_Node then
                        local babel = self.item_Node:getChildByTag(self.m_dragonBossGuid);
                        if babel then
                            babel = tolua.cast(babel,"SpriteMonster");
                            if babel then
                                babel:stopInTheTime();
                                -- 雷电困人
                                local effectLoop = Effects:create(false)
                                effectLoop:playActionData("kmz_loop", 8, 1, -1)   
                                effectLoop:setAnchorPoint(cc.p(0.5, 0.4))
                                addEffectWithMode(effectLoop, 3)

                                local topNode = babel:getTopNode()
                                if topNode ~= nil then
                                    topNode:addChild(effectLoop, 9999, 123)
                                end
                            end
                        end
                    end
                    -------------------------------------------------------------------------
                end
            end
        end,

       	[SINPVP_SC_FIGHTRESULT] = function()
            --print("SINPVP_SC_FIGHTRESULT")
			local t = g_msgHandlerInst:convertBufferToTable("SinpvpFightRetProtocol", buff)
            self.isWin = t.result
            self.prizeId = t.rewardID
            if self.prizeId and self.prizeId >= 0 then
	            if self.isWin then
		            self.newRank = t.curRank
		            self.historyRank = t.history
		        end
	            local func = function() if G_MAINSCENE and G_MAINSCENE.map_layer.mapID == 6004 then self:showOverView() end end
	            performWithDelay(self.item_Node,func,0.5)
	        end
        end,

        [COPY_SC_COPYTOWERRESULT] = function()
        	print("COPY_SC_COPYTOWERRESULT")
        	local retTable = g_msgHandlerInst:convertBufferToTable("CopyTowerResultProtocol", buff)
        	local roldeId = retTable.roleId
        	local ret = retTable.result
        	local isWin = (ret == 1) and true or false
        	local towerEndData = {}
        	if isWin then        	
	        	towerEndData.myTime = retTable.useTime      -- 自己的最快时间

	        	local fastInfo = retTable.info
        		towerEndData.fastName = ""
        		towerEndData.fastTime = 0
        		towerEndData.bestBattle = 0
	        	if fastInfo then
	        		towerEndData.fastTime = fastInfo.useTime  -- 本职业的最快时间
	        		if towerEndData.fastTime > 0 then
						towerEndData.fastName = fastInfo.name
		        		towerEndData.bestBattle = fastInfo.battle
	        		end
	        	end

	        	towerEndData.copyStar = retTable.bestStar    -- 本副本获得的最大星数
	        	towerEndData.thisTime = retTable.newTime    -- 这次的用时
	        	towerEndData.thisStar = retTable.newStar    -- 这次获得的星数
	        	local num = retTable.prizeNum

	        	local rawerInfo = retTable.rewardInfo
	        	towerEndData.awardNum = num
	        	towerEndData.awardData = {}
	        	for i=1, num do
	        		towerEndData.awardData[i]  = {rawerInfo[i].rewardId , rawerInfo[i].rewardCount}
	        	end
	        else
	        	game.setAutoStatus(0)
	        end

	        towerEndData.isWin = isWin
	        dump(towerEndData, "towerEndData")
    		self:showTowerResult(towerEndData, 0)
    	end,

        [COPY_SC_PROGRESSCOPY_RET] = function()
            local msgItem = getConfigItemByKeys("clientmsg",{"sth","mid"},{EVENT_COPY_SETS,13});
            if msgItem then
                TIPS( { type = msgItem.tswz , str = msgItem.msg } );
            end

            DragonData:ExecuteCallback("DragonDetail", 0);
        end,

        [LITTERFUN_SC_MONATTACK_RANK] = function()
        	--怪物攻城的排名信息
			local retTable = g_msgHandlerInst:convertBufferToTable("MonattackRankProtocol", buff)
        	local rankInfo = {}
        	rankInfo.myNum = retTable.myScore  --我的积分
        	rankInfo.myRank = retTable.myRank --我的排名
        	local tableNum = retTable.RankNum
        	local tempInfo = retTable.scoreRankInfo

        	tableNum = tempInfo and tablenums(tempInfo) or 0
        	rankInfo.rankData = {}
        	for i=1, tableNum do
        		rankInfo.rankData[i] = {}
        		rankInfo.rankData[i].Num = tempInfo[i].Score
        		rankInfo.rankData[i].Name = tempInfo[i].name
        	end
        	--dump(rankInfo, "rankInfo")
        	if G_MAINSCENE then
        		G_MAINSCENE:showActivityRank(rankInfo)
        	end
        end,
        [FACTION_INVADE_SC_FACTION] = function()
        	local retTable = g_msgHandlerInst:convertBufferToTable("FactionInvadeGetFactionRet", buff)
        	local infos = retTable.facInfos

        	local num = infos and tablenums(infos) or 0

        	local netData = {}
        	for i=1,num do
        		local tempInfo = infos[i]
        		local record = {}
        		record.facID = tempInfo.facID
        		record.facName = tempInfo.facName
        		record.facLeaderName = tempInfo.facLeaderName
        		record.facLevel = tempInfo.facLevel
        		record.facBattle = tempInfo.facBattle
        		table.insert(netData, record)
        	end

        	--dump(netData, "FACTION_INVADE_SC_FACTION")
        	if num > 0 then
        		__GotoTarget( {ru = "a183", data = netData} )
        	else
                local msgItem = getConfigItemByKeys("clientmsg",{"sth","mid"},{7000,-54});
                if msgItem then
                    TIPS( { type = msgItem.tswz , str = msgItem.msg } );
                end
			end
    	end,
    	[FACTION_INVADE_SC_GET_CUR_FACTION_INFO] = function()
        	local retTable = g_msgHandlerInst:convertBufferToTable("FactionInvadeCurFactionInfoRet", buff)
        		
        	local facId = retTable.facID
        	local facName = retTable.facName
        	
        	if G_MAINSCENE then
        		G_MAINSCENE:checkFactionFire(facId, facName)
        	end
    	end,
    	[DIGMINE_SC_MAX_REWARD] = function()
    		local retTable = g_msgHandlerInst:convertBufferToTable("DigMineMaxReward", buff)

            local node = getRunScene():getChildByName("digminefullTip")
            if not node then
        		local ret = MessageBoxYesNo(nil, game.getStrByKey("digminefullTip"), function() __GotoTarget( { ru = "a129", Value = 10, notFly = true} ) end, nil, "立即前往", "稍后")
        		ret:setName("digminefullTip")

        		-- performWithDelay(self.item_Node, function() 
        		-- 	local node = getRunScene():getChildByName("digminefullTip")
        		-- 	if node then
        		-- 		removeFromParent(node)
        		-- 	end
        		-- end, 20)
            end

    		G_ROLE_MAIN:MineTipsTimer(G_ROLE_MAIN, false)
    	end,
        [FIGHTTEAM3V3_SC_GETAUDITIONDATARET] = function()
            local t = g_msgHandlerInst:convertBufferToTable("FightTeam3vGetAuditionDataRetProtocol", buff)
            local node_dialogVSJueSai = require("src/layers/VS/VSEntrance.lua").new(t)
            getRunScene():addChild(node_dialogVSJueSai, 200)
        end,
        [FIGHTTEAM3V3_SC_GETREGULATIONDATARET] = function()
            local t = g_msgHandlerInst:convertBufferToTable("FightTeam3vGettRegulationDataRetProtocol", buff)
            local dialog_jueSai = require("src/layers/VS/VSJueSaiDialog").new(t)
            dialog_jueSai:setPosition(cc.p(display.cx, display.cy))
            getRunScene():addChild(dialog_jueSai, 200)
        end,
        [TASK_SC_NOTIFY_PICK_ACTION] = function()
    		local retTable = g_msgHandlerInst:convertBufferToTable("TaskNotifyPickActionProtocol", buff)
    		self:onCaiJiAction(retTable)
    	end,
        [MARRIAGE_SC_TOUR_OPT_BROADCAST] = function()
            local retTable = g_msgHandlerInst:convertBufferToTable("MarriageTourOptBroadCast", buff)
            retTable.actionRoleID = retTable.id
            local data = getConfigItemByKey("MarriageTourTask","q_taskid",retTable.taskId)
            retTable.matID = data.q_CI_id
    		self:onCaiJiAction(retTable)
            print("MARRIAGE_SC_TOUR_OPT_BROADCAST ---------------------------------------------------",retTable.step)
        end,
        [COPY_SC_SINGLEINSTANCE_DATA] = function()
            local proto = g_msgHandlerInst:convertBufferToTable("SingleInstanceDataRetProtocol", buff);
            if proto then
                DragonData:SetCarbonInfo(proto);
            end
        end,
        [COPY_SC_SINGLEINST_INCDATA] = function()
            local proto = g_msgHandlerInst:convertBufferToTable("SingleInstIncDataProtocol", buff);
            if proto then
                if proto.new_daily ~= nil and proto.new_daily > 0 then
                    DragonData.m_dailyCarbon = proto.new_daily;

                    DragonData:ExecuteCallback("DragonSliayer", 1);
                end

                if proto.new_inst ~= nil and proto.new_inst > 0 then
                    DragonData:AddPassedCarbon(proto.new_inst);
                    if self.mapID == 5008 then
                        self.robMineHasTalkNpc = true 
                    end
                end
            end
        end,
        [DIGMINE_SC_SIMULATION_SYNC] = function()
            --print("get_message_of new , DIGMINE_SC_SIMULATION_SYNC<><><><>>>>><><><><><><>")
            local proto = g_msgHandlerInst:convertBufferToTable("DigMineSimulationSync" , buff)
            if proto then 
                self.m_mineData = {}
                self.m_mineData.totalProgress = proto.totalProgress
                self.m_mineData.progress = proto.progress
                self.m_mineData.mineCount = proto.mineCount
                self.m_mineData.timeout = proto.timeout
               -- print("DIGMINE_SC_SIMULATION_SYNC<><><><>>>>><><> ,totalProgress="..proto.totalProgress.."progress="..proto.progress.."mineCount="..proto.mineCount.."timeout="..proto.timeout )
                if self.updateMineState then
                   -- print("get_message_of new , DIGMINE_SC_SIMULATION_SYNC<><><><>>>>><><><><><><>")

                    self:updateMineState()
                end
            end
        end,
        [MAZE_SC_DATA_RET] = function()
            local t = g_msgHandlerInst:convertBufferToTable("MazeDataRet", buff)
            local node_entryDialog = require("src/layers/mysteriousArea/ma_entryDialog").new(t)
            getRunScene():addChild(node_entryDialog)
        end,
        [SKILL_SC_PLAYER_DIE] = function()
            local proto = g_msgHandlerInst:convertBufferToTable("SkillPlayerDie" , buff)
            local num = proto.needStoneNum or 1
            self.costStoneNum = num
            if g_EventHandler ~= nil and g_EventHandler["ReliveNumChange"] then
                g_EventHandler["ReliveNumChange"](num)
            end
        end,
        [EMOUNT_SC_ARREST_MOUNT] = function()
            --print("EMOUNT_SC_ARREST_MOUNT")
            -- local proto = g_msgHandlerInst:convertBufferToTable("MountArrestRetProtocol" , buff)
            -- local objid = proto.dwEntityId
            -- local func = function()
            --     g_msgHandlerInst:sendNetDataByTable(EMOUNT_CS_ARREST_MOUNT,"EMOUNT_CS_ARREST_MOUNT_END",{ dwEntityId = objid })
            -- end
            -- performWithDelay(self,2,func)
        end,
        [EMOUNT_SC_ARREST_MOUNT_NOTIFY] = function()
      
            local proto = g_msgHandlerInst:convertBufferToTable("MountArrestNtfProtocol" , buff)
            --optional uint32 dwRoleEntityId = 1;  //抓取者实体ID
            --optional uint32 dwMonsterEntityId = 2;  //抓取怪物实体ID
            local role_id = proto.dwRoleEntityId
            local monster_id = proto.dwMonsterEntityId
              --print("EMOUNT_SC_ARREST_MOUNT_NOTIFY",monster_id)
            local func = function()
                 --print("send EMOUNT_CS_ARREST_MOUNT_END",monster_id,EMOUNT_CS_ARREST_MOUNT_END)
                g_msgHandlerInst:sendNetDataByTable(EMOUNT_CS_ARREST_MOUNT_END,"MountArrestEndProtocol",{ dwEntityId = monster_id })
            end
            
            if role_id == G_ROLE_MAIN.obj_id then
                local r_pos = cc.p(G_ROLE_MAIN:getPosition())
                local monster = tolua.cast(self.item_Node:getChildByTag(monster_id),"SpriteMonster")
                if monster then
                    local m_pos = cc.p(monster:getPosition())
                    local dir = getDirBrPos(cc.p((m_pos.x-r_pos.x),(m_pos.y-r_pos.y)),G_ROLE_MAIN:getCurrectDir())
                    G_ROLE_MAIN:setSpriteDir(dir)
                end
                --getDirBrPos
                performWithDelay(self,func,2)
            else
                local role = tolua.cast(self.item_Node:getChildByTag(role_id),"SpritePlayer")
                if role then
                    local r_pos = cc.p(role:getPosition())
                    local monster = tolua.cast(self.item_Node:getChildByTag(monster_id),"SpriteMonster")
                    if monster then
                        local m_pos = cc.p(monster:getPosition())
                        local dir = getDirBrPos(cc.p((m_pos.x-r_pos.x),(m_pos.y-r_pos.y)),role:getCurrectDir())
                        role:setSpriteDir(dir)
                    end
                end
            end
            CMagicCtrlMgr:getInstance():CreateMagic(11034, 0,role_id, monster_id, 0);
        end,
        [EMOUNT_SC_ARREST_MOUNT_END] = function()
            --print("EMOUNT_SC_ARREST_MOUNT_END")
            --local proto = g_msgHandlerInst:convertBufferToTable("MountArrestEndRetProtocol" , buff)
        
        end,
	}
 	if switch[msgid] then
 		switch[msgid]()
 	end
end

return MainMapLayer
