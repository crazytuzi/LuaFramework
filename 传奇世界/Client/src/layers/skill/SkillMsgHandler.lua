
local tipLab = nil
local function skillDeal(buffer)
	local isUpdate = false

	local skillLev = 0
	local t = g_msgHandlerInst:convertBufferToTable("SkillFreshXpProtocol", buffer)
	local skillId = t.skillId
	local skillExp = t.exp
	local skillExpAdd = t.expAdd

	if skillId and skillExp and skillExpAdd and G_ROLE_MAIN then
		local skillcfgTemp = getConfigItemByKey("SkillCfg","skillID",skillId)
		local skillLvTemp = getConfigItemByKey("SkillLevelCfg","skillID",skillId*1000+skillLev)
		if skillcfgTemp then
			if skillcfgTemp.jnfenlie == 1 then
				if G_ROLE_MAIN.skills then
					for k,v in pairs(G_ROLE_MAIN.skills) do
						if skillId == v[1] then
							skillLev = v[2]
							v[4] = skillExp
							break
						end
					end
				end
				
				if g_EventHandler["skillexpupdate"] then
					g_EventHandler["skillexpupdate"](skillId,skillLev,skillExp,nil,skillExpAdd)
				else
					TIPS( { type = 2 , str = string.format(game.getStrByKey("skillUpdateTip1"),getConfigItemByKey("SkillCfg","skillID",skillId,"name"),tonumber(skillExpAdd)) } )			
					-- local effectNeedLabel = createLabel(getRunScene(), string.format(game.getStrByKey("skillUpdateTip1"),getConfigItemByKey("SkillCfg","skillID",skillId,"name"),tonumber(skillExpAdd)), cc.p(340,100), cc.p(0.5, 0.5), 20, false, nil, nil, MColor.white)
					-- effectNeedLabel:setScale(0.01)
					-- effectNeedLabel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.5), cc.ScaleTo:create(0.2, 1), cc.MoveBy:create(1, cc.p(0, 60)),
					-- cc.CallFunc:create(function() removeFromParent(effectNeedLabel) effectNeedLabel = nil end)))
					-- effectNeedLabel:runAction(cc.Sequence:create(cc.FadeOut:create(2)))							
				end			
				-- if skillLvTemp and skillcfgTemp.maxlv and skillLvTemp.sld and skillLvTemp.sld <= tonumber(skillExp) and skillcfgTemp.maxlv > skillLev then
				-- 	isUpdate = true
		  -- 			if G_MAINSCENE and G_MAINSCENE.red_points then
		 	-- 			G_MAINSCENE.red_points:insertRedPoint(4, 2)
		  --   		end
				-- end
				checkSkillRed()
			elseif skillcfgTemp.jnfenlie == 7 then
				if G_ROLE_MAIN.wingskills then
					for k,v in pairs(G_ROLE_MAIN.wingskills) do
						if skillId == v[1] then
							skillLev = v[2]
							v[4] = skillExp
							break
						end
					end
				end
				
				if g_EventHandler["wingskillexpupdate"] then
					g_EventHandler["wingskillexpupdate"](skillId,skillLev,skillExp,nil,skillExpAdd)
				else
					TIPS( { type = 2 , str = string.format(game.getStrByKey("skillUpdateTip1"),getConfigItemByKey("SkillCfg","skillID",skillId,"name"),tonumber(skillExpAdd)) } )			
					-- local effectNeedLabel = createLabel(getRunScene(), string.format(game.getStrByKey("skillUpdateTip1"),getConfigItemByKey("SkillCfg","skillID",skillId,"name"),tonumber(skillExpAdd)), cc.p(340,100), cc.p(0.5, 0.5), 20, false, nil, nil, MColor.white)
					-- effectNeedLabel:setScale(0.01)
					-- effectNeedLabel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.5), cc.ScaleTo:create(0.2, 1), cc.MoveBy:create(1, cc.p(0, 60)),
					-- cc.CallFunc:create(function() removeFromParent(effectNeedLabel) effectNeedLabel = nil end)))
					-- effectNeedLabel:runAction(cc.Sequence:create(cc.FadeOut:create(2)))							
				end			
				-- if skillLvTemp and skillcfgTemp.maxlv and skillLvTemp.sld and skillLvTemp.sld <= tonumber(skillExp) and skillcfgTemp.maxlv > skillLev then
				-- 	isUpdate = true
		  -- 			if G_MAINSCENE and G_MAINSCENE.red_points then
		 	-- 			G_MAINSCENE.red_points:insertRedPoint(4, 2)
		  --   		end
				-- end

			end
		end
	end

	if isUpdate == true then
		--开启技能升级引导
		if G_TUTO_DATA then
			for k,v in pairs(G_TUTO_DATA) do
				if v.q_id == 32 then
					if v.q_state == TUTO_STATE_HIDE then
						v.q_state = TUTO_STATE_OFF
					end
				end
			end
		end
	end
end
g_msgHandlerInst:registerMsgHandler(SKILL_SC_FRESHEXP, skillDeal)