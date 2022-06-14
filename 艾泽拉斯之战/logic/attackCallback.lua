attackCallback = {};

function attackCallback.skillCommon(casterActor, targetActor, skillName, callbackindex, callbacknum, attUserData)

	local casterIndex = casterActor:getUserData()
	local battle = sceneManager.battlePlayer();
	
	if(casterIndex == kingClass.INDEX_CASTER_KING )then
		_onKingCastDamage(battle.casterKing, callbackindex, callbacknum);
	else
		local castUnit = battle.m_AllCrops[casterActor:getUserData()];
		local tcropsUnit = battle.m_AllCrops[targetActor:getUserData()];
		if castUnit then
			-- 这里的userdata是技能id，做一些特殊的需求
			if attUserData == enum.SKILL_TABLE_ID.RouGou or
				attUserData == enum.SKILL_TABLE_ID.RouGou2 then
				-- 肉钩
				tcropsUnit:getActor():AddSkillAttack("tufuA_rougou01.att", castUnit.actor, false);
			else
			
			end
			__onTargetDanmage(castUnit,tcropsUnit,callbackindex,callbacknum);
		end
	end
		
end

function attackCallback.skillConsecutive(casterActor, targetActor, skillName, callbackindex, callbacknum, attUserData)
	local casterIndex = casterActor:getUserData();
	local targetIndex = targetActor:getUserData();
	local battle = sceneManager.battlePlayer();
	
	local castUnit = battle.m_AllCrops[casterIndex];
	local targetUnit = battle.m_AllCrops[targetIndex];
	
	if castUnit.m_Targets[attUserData] then
		targetUnit.callbackindex = callbackindex;
		targetUnit.callbacknum = callbacknum;
		targetUnit.hurtSourceActor  = castUnit;
		targetUnit:enterStateHurt( castUnit.m_TargetsDamage[attUserData], false);	
	end
	
end

attackCallback.Handler = {
	[enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON] = attackCallback.skillCommon;
	[enum.SKILL_CALLBACK_TYPE.SCT_SKIILL_CONSECUTIVE] = attackCallback.skillConsecutive;
};
