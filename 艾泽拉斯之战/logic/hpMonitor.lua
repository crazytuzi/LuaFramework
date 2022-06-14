hpMonitor = {};

-- 记录当前所有的军团的血量，从开战时开始统计
hpMonitor.hpData = {};
-- 对应每一个round记录一次hpData
hpMonitor.hpRoundData = {};

-- init
function hpMonitor.init()

	hpMonitor.hpData = {};
	hpMonitor.hpRoundData = {};
end

-- 初始化所有的军团的血量，开战前初始化，完全根据军团数量和表格的单兵血量
function hpMonitor.initHP(index, unitID, count)
	local soldierHP = dataConfig.configs.unitConfig[unitID].soldierHP;
	hpMonitor.hpData[index] = {};
	hpMonitor.hpData[index].hp = soldierHP * count;
	hpMonitor.hpData[index].soldierHP = soldierHP;
end

-- ATTACK RETALIATE DAMAGE 需要变成负数， CURE 是正数 
function hpMonitor.changeHP(index, value)	
	hpMonitor.hpData[index].hp = hpMonitor.hpData[index].hp + value;	
end

-- 直接sethp， 复活，
function hpMonitor.setHP(index, value)
	hpMonitor.hpData[index].hp = value;
end
--attr change的时候
function hpMonitor.attrChange(index, attrValue)
	
	if hpMonitor.hpData[index].hp and hpMonitor.hpData[index].hp <= 0 then
		return;
	end
		
	if hpMonitor.hpData[index].soldierHP ~= attrValue and hpMonitor.hpData[index].soldierHP ~= 0 then
		print("hpMonitor.hpData[index].hp "..hpMonitor.hpData[index].hp.." hpMonitor.hpData[index].soldierHP "..hpMonitor.hpData[index].soldierHP);
		hpMonitor.hpData[index].hp = math.floor(hpMonitor.hpData[index].hp * attrValue / hpMonitor.hpData[index].soldierHP );
		hpMonitor.hpData[index].soldierHP = attrValue;
	
		if hpMonitor.hpData[index].hp <= 0 then
			hpMonitor.hpData[index].hp = 1;
		end
			
		print("after hpMonitor.hpData[index].hp "..hpMonitor.hpData[index].hp.." hpMonitor.hpData[index].soldierHP "..hpMonitor.hpData[index].soldierHP);
	else
		print("other hpMonitor.hpData[index].hp "..hpMonitor.hpData[index].hp.." hpMonitor.hpData[index].soldierHP "..hpMonitor.hpData[index].soldierHP);
	end

end

-- 解析数据
function hpMonitor.parseRecord(value)

	local nowRound = -1;
	for k, v in ipairs(value) do
		
		if v.m_round ~= nowRound then
			nowRound = v.m_round;
			hpMonitor.flashRound(nowRound);
		end
		
				
		if v.m_type == 0 then
			-- ACTION
			
		elseif v.m_type == 1 then
			-- MOVE

		elseif v.m_type == 2 then
			-- ATTACK
			hpMonitor.changeHP(v.attack.target, -v.attack.value);
			
		elseif v.m_type == 3 then
			-- RETALIATE
			hpMonitor.changeHP(v.retaliate.target, -v.retaliate.value);
			
		elseif v.m_type == 4 then
			-- LOCK
		elseif v.m_type == 5 then
			-- DEAD
		elseif v.m_type == 6 then
			-- SKILL
		elseif v.m_type == 7 then
			-- MAGIC	
		elseif v.m_type == 8 then
			-- BUFF
		elseif v.m_type == 9 then
			-- SUMMON
			hpMonitor.initHP(v.summon.target, v.summon.targetID, v.summon.count);
			
		elseif v.m_type == 10 then
			-- DAMAGE
			hpMonitor.changeHP(v.damage.target, -v.damage.value);
			
		elseif v.m_type == 11 then
			-- CURE
			hpMonitor.changeHP(v.cure.target, v.cure.value);
			
		elseif v.m_type == SERVER_ACTION_TYPE.REVIVE then
			hpMonitor.setHP(v.revive.target, v.revive.hp);
			
		elseif v.m_type == SERVER_ACTION_TYPE.ATTRIBUTE then
			--print("hpMonitor SERVER_ACTION_TYPE.ATTRIBUTE");
 			if v.attribute.attrType == enum.UNIT_ATTR.UNIT_ATTR_SOLDIER_HP then
 				hpMonitor.attrChange(v.attribute.target, v.attribute.attrValue);
 			end
		elseif v.m_type == SERVER_ACTION_TYPE.MAGIC_OVER then
		elseif v.m_type == SERVER_ACTION_TYPE.BATTLE_OVER then
			-- BATTLE_OVER
		end
	end
	
	
end

-- 记录一个回合后的变化
function hpMonitor.flashRound(round)
	hpMonitor.hpRoundData[round] = {};
	for k, v in pairs(hpMonitor.hpData) do
		hpMonitor.hpRoundData[round][k] = {};
		hpMonitor.hpRoundData[round][k].hp = v.hp;
		hpMonitor.hpRoundData[round][k].soldierHP = v.soldierHP;
	end
end

-- check
function hpMonitor.checkUnit(round, unitInstance)
	
	do
		return;
	end
	--dump(hpMonitor.hpRoundData[round])
	
	if unitInstance and hpMonitor.hpRoundData[round] and hpMonitor.hpRoundData[round][unitInstance.index] then
		if hpMonitor.hpRoundData[round][unitInstance.index].hp ~= unitInstance:getTotalHP() then
			sceneManager._battlePlayer:pauseGame(true);
			local info = string.format("第%d回合，军团%d: %s, 血量变化异常, 请联系程序员!\n计算血量：%d 实际血量：%d", 
								round, unitInstance.index, unitInstance.m_name, hpMonitor.hpRoundData[round][unitInstance.index].hp, unitInstance:getTotalHP());
			print(info);
			eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.ERROR, textInfo = info,});
			
			if hpMonitor.hpRoundData[round-1] and hpMonitor.hpRoundData[round-1][unitInstance.index] then 
				print("hpMonitor.hpRoundData[round-1] "..hpMonitor.hpRoundData[round-1][unitInstance.index].hp);
			end
		else
			--print("hpMonitor.checkUnit ok round "..round.." index "..unitInstance.index);
		end
	end
end
