battleRecord = {};
battleRecord.records = {};

green = "^22F567";
red = "^EC203D";
white = "^FFFFFF";
blue = "^22E4F5";
cunit = "^F59922";
cbuff = "^F914F1";
yellow = "^F4FD01";


function battleRecord.setColor(string, color)
	return " "..color..string..white.." ";
end

function battleRecord.setUnitColor(string)
	return battleRecord.setColor(string, cunit);
end

function battleRecord.setActionColor(string)
	return battleRecord.setColor(string, green);
end

function battleRecord.endBattle()
	local filehandle = fio.open("battleRecord.txt",1);
	if filehandle~=0 then
		for k, v in ipairs(battleRecord.records) do
			fio.write(filehandle, v);
			fio.write(filehandle, "\n");
		end
		fio.close(filehandle);
	end
	
	battleRecord.records = nil;
	battleRecord.records = {};
end

function battleRecord.getForceName(force)
	if force == enum.FORCE.FORCE_ATTACK then
		return battleRecord.setColor("进攻方", blue);
	elseif force == enum.FORCE.FORCE_GUARD then
		return battleRecord.setColor("防守方", blue);
	end
end


local turnCount = -1;

function battleRecord.pushRecord(record)
	tCount = sceneManager.battlePlayer().m_RoundNum;
	if tCount ~= turnCount then
		temp = string.format("\n第["..yellow.."%d"..red.."]回合:", sceneManager.battlePlayer().m_RoundNum);
		temp = battleRecord.setColor(temp, red);
		record = temp.."\n"..record;
		
		turnCount = tCount;
	end
	
	table.insert(battleRecord.records, record);
	--print(record);
end

function battleRecord.pushMoveRecord(caster, startPointX, startPointY, endPointX, endPointY)
	local record = string.format(battleRecord.setUnitColor("[%s(%d)]").."进行了"
	
	..battleRecord.setActionColor("移动")..
	"，从{%d, %d}移动到{%d, %d}", caster.m_name, caster.index, startPointX, startPointY, endPointX, endPointY);
	
	battleRecord.pushRecord(record);
end

function battleRecord.pushAttackRecord(caster)
	local record = string.format(battleRecord.setUnitColor("[%s(%d)]").."进行了"
	..battleRecord.setActionColor("普通攻击"), caster.m_name, caster.index);
	battleRecord.pushRecord(record);
end

function battleRecord.pushRetaliate(caster)
	local record = string.format(battleRecord.setUnitColor("[%s(%d)]").."进行了"
	..battleRecord.setActionColor("反击"), caster.m_name, caster.index);
	battleRecord.pushRecord(record);
end

function battleRecord.pushLock(caster)
	local record = string.format(battleRecord.setUnitColor("[%s(%d)]").."行动时锁住了", caster.m_name, caster.index);
	battleRecord.pushRecord(record);
end

function battleRecord.pushSkill(caster, skillName)
	local record = string.format(battleRecord.setUnitColor("[%s(%d)]").."释放了"
	..battleRecord.setActionColor("技能[%s]").."", caster.m_name, caster.index, skillName);
	battleRecord.pushRecord(record);
end

function battleRecord.pushMagic(magicName, force)
	local record = string.format("%s国王释放了"
	..battleRecord.setActionColor("技能[%s]").."", battleRecord.getForceName(force), magicName);
	battleRecord.pushRecord(record);
end

function battleRecord.pushAttackDamage(target, caster, damageValue)
	local record = string.format(battleRecord.setUnitColor("[%s(%d)]").."受到来自"
	..battleRecord.setUnitColor("[%s(%d)]").."的普通攻击造成的伤害["
	..battleRecord.setColor("%d", yellow).."]点", target.m_name, target.index, caster.m_name, caster.index, damageValue);
	battleRecord.pushRecord(record);
end

function battleRecord.pushRetailateDamage(target, caster, damageValue)
	local record = string.format(battleRecord.setUnitColor("[%s(%d)]").."受到来自"
	..battleRecord.setUnitColor("[%s(%d)]").."的反击造成的伤害["
	..battleRecord.setColor("%d", yellow).."]点", target.m_name, target.index, caster.m_name, caster.index, damageValue);
	battleRecord.pushRecord(record);
end

function battleRecord.pushSkillDamage(target, caster, skillName, damageValue)
	local record = string.format(battleRecord.setUnitColor("[%s(%d)]").."受到来自"
	..battleRecord.setUnitColor("[%s(%d)]").."的"
	..battleRecord.setActionColor("技能[%s]").."造成的伤害["
	..battleRecord.setColor("%d", yellow).."]点", target.m_name, target.index, caster.m_name, caster.index, skillName, damageValue);
	battleRecord.pushRecord(record);
end

function battleRecord.pushMagicDamage(target, skillName, damageValue, force)
	local record = string.format(battleRecord.setUnitColor("[%s(%d)]").."受到%s国王"
	..battleRecord.setActionColor("技能[%s]").."造成的伤害["
	..battleRecord.setColor("%d", yellow).."]点", target.m_name, target.index, battleRecord.getForceName(force), skillName, damageValue);	
	battleRecord.pushRecord(record);
end

function battleRecord.pushSkillCure(target, caster, skillName, damageValue)
	local record = string.format(battleRecord.setUnitColor("[%s(%d)]").."受到来自"
	..battleRecord.setUnitColor("[%s(%d)]").."的"
	..battleRecord.setActionColor("技能[%s]").."治疗效果["..green.."%d"..white.."]点", target.m_name, target.index, caster.m_name, caster.index, skillName, damageValue);
	battleRecord.pushRecord(record);
end

function battleRecord.pushMagicCure(target, skillName, damageValue, force)
	local record = string.format(battleRecord.setUnitColor("[%s(%d)]").."受到%s国王"
	..battleRecord.setActionColor("技能[%s]").."治疗效果["..green.."%d"..white.."]点", target.m_name, target.index, battleRecord.getForceName(force), skillName, damageValue);
	battleRecord.pushRecord(record);
end

function battleRecord.pushSkillAddBuff(target, caster, skillName, buffName)
	local record = string.format(battleRecord.setUnitColor("[%s(%d)]").."受到来自"
	..battleRecord.setUnitColor("[%s(%d)]").."的"
	..battleRecord.setActionColor("技能[%s]").."添加的"
	..battleRecord.setColor("BUFF[%s]", cbuff).."", target.m_name, target.index, caster.m_name, caster.index, skillName, buffName);
	battleRecord.pushRecord(record);
end

function battleRecord.pushMagicAddBuff(target, skillName, buffName, force)
	local record = string.format(battleRecord.setUnitColor("[%s(%d)]").."受到%s国王"
	..battleRecord.setActionColor("技能[%s]").."添加的"
	..battleRecord.setColor("BUFF[%s]", cbuff).."", target.m_name, target.index, battleRecord.getForceName(force), skillName, buffName);
	battleRecord.pushRecord(record);
end

function battleRecord.pushDeleteBuffBySkill(target, buffName, skillName)
	local record = nil;
	if skillName then
		record = string.format(battleRecord.setUnitColor("[%s(%d)]").."的"

	..battleRecord.setColor("BUFF[%s]", cbuff).."被"
	..battleRecord.setActionColor("技能[%s]").."删除掉了", target.m_name, target.index, buffName, skillName);
	else
		record = string.format(battleRecord.setUnitColor("[%s(%d)]").."的"
	..battleRecord.setColor("BUFF[%s]", cbuff).."删除掉了", target.m_name, target.index, buffName);
	end
	
	battleRecord.pushRecord(record);
end

function battleRecord.pushBuffEffectDamage(target, buffID, damageValue)
	local buffInfo = dataConfig.configs.buffConfig[buffID];
	if buffInfo then
		local record = string.format(battleRecord.setUnitColor("[%s(%d)]").."受到"
	..battleRecord.setColor("BUFF[%s]", cbuff).."造成的伤害["
	..battleRecord.setColor("%d", yellow).."]点", target.m_name, target.index, buffInfo.name, damageValue);
		battleRecord.pushRecord(record);
	end
end

function battleRecord.pushBuffEffectCure(target, buffID, cureValue)
	local buffInfo = dataConfig.configs.buffConfig[buffID];
	if buffInfo then
		local record = string.format(battleRecord.setUnitColor("[%s(%d)]").."受到"
	..battleRecord.setColor("BUFF[%s]", cbuff).."的治疗效果["..green.."%d"..white.."]点", target.m_name, target.index, buffInfo.name, cureValue);
		battleRecord.pushRecord(record);
	end
end

function battleRecord.pushDead(target)
		local record = string.format(battleRecord.setUnitColor("[%s(%d)]").."进入死亡状态", target.m_name, target.index);
		battleRecord.pushRecord(record);
end

function battleRecord.pushDamageFlag(hurtFlag)
	
	local record = "";
	if(enum.DAMAGE_FLAG.DAMAGE_FLAG_NORMAL == hurtFlag)then--正常伤害
		
	elseif(enum.DAMAGE_FLAG.DAMAGE_FLAG_DOGE == hurtFlag)then ---闪避					
		record = "本次伤害被"..battleRecord.setColor("闪避", green);
	elseif(enum.DAMAGE_FLAG.DAMAGE_FLAG_IMMUNE == hurtFlag)then --免疫				
		record = "本次伤害被"..battleRecord.setColor("免疫", red);
	elseif(enum.DAMAGE_FLAG.DAMAGE_FLAG_BLOCK == hurtFlag)then -- 格挡			
		record = "本次伤害被"..battleRecord.setColor("格挡", green);
	elseif(enum.DAMAGE_FLAG.DAMAGE_FLAG_ABSORB == hurtFlag)then -- 吸收	
		record = battleRecord.setActionColor("吸收 o(╯□╰)o");
	elseif(enum.DAMAGE_FLAG.DAMAGE_FLAG_TRANSFER == hurtFlag)then -- 迁移	
		record = "本次伤害被"..battleRecord.setColor("迁移", green).."抵消";
	elseif(enum.DAMAGE_FLAG.DAMAGE_FLAG_CRITICAL == hurtFlag)then -- 暴击				
		record = "本次伤害是"..battleRecord.setColor("暴击", red);
	end	
	battleRecord.pushRecord(record);
end
