local MonsterSprite = class("MonsterSprite", function(strname) return SpriteMonster:create(strname) end)

MonsterSprite.boss_effect = nil
MonsterSprite.worldBossPic = nil

local commConst = require("src/config/CommDef");

function MonsterSprite:ctor(strname, params, id)
	self.is_monster = true
    self.m_guid = id;

	local monster_resid = self:getResId()

	local dir = params[ROLE_DIR] or 6
	if monster_resid == 31135 or monster_resid == 31136 or monster_resid == 31137 or monster_resid == 31138 then
		dir = 6
		self:setSpriteOneDir(dir)
	end
	self:initStandStatus(4, 6, 1.0, dir)
	self:initAttackStatus(4)
	-- self:set5DirMode(true)
	self.params = params

	if params and type(params) == "table" and params[ROLE_MODEL] then
		local role_model = params[ROLE_MODEL]

		-- log("new Monster..........params[ROLE_MODEL]:" .. role_model .. ",res_id:" .. strname)
		local monster_data = getConfigItemByKey("monster", "q_id", role_model)
		self:setMonsterId(role_model)
		-- self:setShow_H(monster_data.hp_high,true)
		local hph = tonumber(monster_data.hp_high)
		if hph and hph > 0 then
			self:setVisibleNameAndBlood(true)
			self:setNameAndBloodPos(true, 0, hph)
		end
		-- local name_str = ""
		if monster_data then
			local role_name = params[ROLE_NAME]
			local role_host_name = params[ROLE_HOST_NAME]

			local m_type = 9 + monster_data.q_type
			if m_type > 12 then m_type = 12 end
			self:setType(m_type)
			-- self:setType(7)
			-- self:setBaseUrl("1019/down")
			local role_max_hp = params[ROLE_MAX_HP] or monster_data.q_maxhp or 0
			self:setMaxHP(role_max_hp)
			params[ROLE_HP] = params[ROLE_HP] or role_max_hp
			self:setHP(params[ROLE_HP])
			-- name_str = monster_data.q_name.."["..monster_data.q_lvl.."]"

			local with_hostname_str = nil
			if role_host_name then
				if role_model == 80000 or role_model == 80001 or role_model == 80002 or role_model == 80003 then
					with_hostname_str = monster_data.q_name .. "\n" .. role_host_name
				else
					with_hostname_str = role_host_name .. "的" .. monster_data.q_name
				end
			end
			local name_label = self:getNameBatchLabel()
			self:setTheName(with_hostname_str or monster_data.q_name)
			if name_label then
				name_label:setString(role_name or with_hostname_str or monster_data.q_name)
			end
			self:setLevel(monster_data.q_lvl)
			if monster_data.q_type > 1 and(not isKingModel(role_model)) then
				local select_effect = Effects:create(false)
				-- select_effect:setPosition(cc.p(0,-20))
				select_effect:setAnchorPoint(cc.p(0.5, 0.5))
				self:addChild(select_effect, 0, 155)
				-- select_effect:playActionData("select",7,2,-1)
				select_effect:playActionData("newselect", 6, 2, -1)
				addEffectWithMode(select_effect, 1)
			end
			if G_ROLE_MAIN then
				local plistsmap = { [20003] = 2, [20009] = 2, [20019] = 2, [20032] = 3, [20033] = 3, [20087] = 3, [20079] = 5, [4000001] = 3, [4000002] = 4 }
				self:setPlistsNum(plistsmap[monster_data.q_featureid] or 1)
			end
			-- 帮派旗帜
			if role_model == 9003 then
				local height = 10
				name_label:setString("")
				local name = createLabel(self:getTitleNode(), monster_data.q_name, cc.p(0 + 6, height), cc.p(0.5, 0), 18, true, 200, nil, MColor.white)
				local role_status_name = params[ROLE_STATUS_NAME]
				if role_status_name and role_status_name ~= "" then
					self.BannerName = createLabel(self:getTitleNode(), game.getStrByKey("owner_faction") .. role_status_name, cc.p(6, 10 + 25), cc.p(0.5, 0), 18, true, 200, nil, MColor.green)
					self.BannerName:enableOutline(cc.c4b(50, 50, 50, 155), 1)
				end
			end

			if role_model == 31 or role_model == 23 or role_model == 21 then
				local height = -5
				name_label:setString("")
				local lab = createLabel(self:getTitleNode(), monster_data.q_name, cc.p(0 + 6, height), cc.p(0.5, 0), 18, true, 200, nil, MColor.yellow)
				lab:enableOutline(cc.c4b(0,0,0,255),1)
			elseif role_model == commConst.MULTI_GUARD_PRINCESS_ID then
				-- 公主
				name_label:setString("");
				createLabel(self:getTitleNode(),(role_name or with_hostname_str or monster_data.q_name), cc.p(0, 10), cc.p(0.5, 0), 18, true, 200, nil, MColor.yellow)
			end

			-- add light circle & world boss label if needed
			if monster_data.GuangQuan then
				local scaleNum = nil
				if monster_data.GuangQuan == 1 then
					-- big
					scaleNum = 2.0
				elseif monster_data.GuangQuan == 2 then
					-- middle
					scaleNum = 1.5
				elseif monster_data.GuangQuan == 3 then
					-- small
					scaleNum = 1.0
				end
				if scaleNum then
					local lc_name = "largeBossFoot";
					local lc_effect = Effects:create(false)
					-- lc_effect:setPosition(cc.p(0,0))
					lc_effect:setAnchorPoint(cc.p(0.5, 0.5))
					self:addChild(lc_effect)
					lc_effect:playActionData(lc_name, 13, 0.6, -1)
					lc_effect:setScale(scaleNum)
					addEffectWithMode(lc_effect, 3)
					self.boss_effect = lc_effect
				end
			end

			-- add boss pic label
			if monster_data.texiao then
				local titleNode = self:getTitleNode()
				if titleNode then
					if monster_data.texiao >= 1 and monster_data.texiao <= 4 then
						self.worldBossPic = createSprite(titleNode, "res/monster/head/title/" .. monster_data.texiao .. ".png", cc.p(0, 10), cc.p(0.5, 0), 2000 + monster_data.texiao, 1.0)
					end
				end
			end

			self:updateNameColor(self)
		end
	end
end

function MonsterSprite:updateNameColor(monster)
	if not monster or monster:getType() > 20 then return end

	local MRoleStruct = require("src/layers/role/RoleStruct")
	local monsterId = monster:getMonsterId()

	local monster_data = getConfigItemByKey("monster", "q_id", monsterId)
	if monster_data then

		local monsterLv = monster:getLevel()
		local name_label = monster:getNameBatchLabel()
		local roleLv = MRoleStruct:getAttr(ROLE_LEVEL) or 1
		local color = MColor.white

		if monsterLv then
			if monsterLv - roleLv < 0 or(monsterId >= 90000 and monsterId <= 92003) then
				color = MColor.gray
			elseif monsterLv - roleLv < 5 then
				color = MColor.green
			else
				color = MColor.red
			end

			local carCfg = { ["80000"] = true, ["80001"] = true, ["80002"] = true, ["80003"] = true }
			if carCfg[monsterId .. ""] then
				color = MColor.orange
				-- 不同行会非自己镖车橙色
				local tempParams = monster.params

				if tempParams then
					local strTab = { }
					if tempParams[ROLE_STATUS_NAME] then
						strTab = stringsplit(tempParams[ROLE_STATUS_NAME], "###")
					end
					table.insert(strTab, tempParams[ROLE_HOST_NAME])
					local selfName = MRoleStruct:getAttr(ROLE_NAME)
					local isExist = false
					for k, v in pairs(strTab) do
						if v == selfName then
							isExist = true
						end
					end

					if isExist then
						color = MColor.green
						-- 自己的镖车绿色
					end

					if tempParams[PLAYER_FACTIONID] ~= 0 then
						if tempParams[PLAYER_FACTIONID] == MRoleStruct:getAttr(PLAYER_FACTIONID) then
							color = MColor.blue
							-- 同行会的镖车蓝色
						end
					end
				end
			end

			local colorTab = { [0] = cc.c3b(255, 255, 255), [1] = cc.c3b(0, 255, 255), [2] = cc.c3b(140, 214, 239), [3] = cc.c3b(57, 181, 239) }
			local petCfg = { [20081] = true, [20085] = true, [20082] = true }
			if petCfg[monster_data.q_featureid] then
				if colorTab[monster_data.q_lvl] then
					color = colorTab[monster_data.q_lvl]
				end
			end

            -- 大刀侍卫，屠龙传说 BOSS 副本中，作为友方队员
            if monsterId == commConst.BROADSWORD_GRUARDS_ID and G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isfb and userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER then
                color = MColor.blue;
            end

            local tempParams = monster.params
    		if tempParams[PLAYER_NAME_COLOR] then
    			if tempParams[PLAYER_NAME_COLOR] == 1 then
    				color = MColor.blue
    			end
			end

			if name_label then
				name_label:setColor(color)
			end
		end
	end
end

function MonsterSprite:setNameColor(color)
	local name_label = self:getNameBatchLabel()
	if name_label then
		name_label:setColor(color)
	end
end

function MonsterSprite:setNameLabel(str)
	local name_label = self:getNameBatchLabel()
	if name_label then
		name_label:setString(str)
		self:setTheName(str)
	end
end

function MonsterSprite:setBannerOwer(monster, str)
	if not str then return end

	local nameStr = game.getStrByKey("biqi_str9")
	if str == "" then
		if monster.BannerName then
			monster.BannerName:setString("")
		end
	else
		nameStr = str
		if monster.BannerName then
			monster.BannerName:setString(game.getStrByKey("owner_faction") .. str)
		end
	end
end

function MonsterSprite:setMonsterActionByInfo(monster_info)
	if monster_info then
		local fcStand = tonumber(monster_info.q_stand)
		if fcStand ~= nil and fcStand > 0 then
			self:initStandStatus(4, fcStand, 1.0, 6)
		end

		local fcWalk = tonumber(monster_info.q_walk) or 0
		local fcWalkRate = tonumber(monster_info.q_walkrate) or 0
		if fcWalk > 0 or fcWalkRate > 0 then
			self:initWalkStatus(fcWalk, fcWalkRate)
		end

		local fcAttack = tonumber(monster_info.q_attack)
		if fcAttack ~= nil and fcAttack > 0 then
			self:initAttackStatus(fcAttack)
		end
	end
end

function MonsterSprite:doMonsterAppearActionByInfo(monster_info)

	local monster_id = self:getMonsterId()
	if monster_id == 0 or monster_id == 6008 or monster_id == 6060 then
		return
	end

	if monster_info then
		local appearFrameCount = tonumber(monster_info.q_appear) or 0
		if appearFrameCount > 0 then
			local appearDir = tonumber(monster_info.appear_dir) or 7
			self:appeared(0.8, appearFrameCount, appearDir)
		end
	end

end

return MonsterSprite