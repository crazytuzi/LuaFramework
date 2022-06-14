-- this usertype is defined in cpp file, so you should parse it manually!

 
function buildData(data)
	if data.m_type == SERVER_ACTION_TYPE.ACTION then
		-- ACTION
		
	elseif data.m_type == SERVER_ACTION_TYPE.MOVE then
		-- MOVE
	 	data.move = {
			moveFlag = 0,
			points = {},
			pointCount = 0,
		}
	elseif data.m_type == SERVER_ACTION_TYPE.ATTACK then
		-- ATTACK
			data.attack = {
				target = 0,
				damageFlag = 0,
				value = 0,
			}
	elseif data.m_type == SERVER_ACTION_TYPE.RETALIATE then
		-- RETALIATE
		 	data.retaliate = {
			target = 0,
			damageFlag = 0,
			value = 0,
		}
	elseif data.m_type == SERVER_ACTION_TYPE.LOCK then
		-- LOCK
	elseif data.m_type == SERVER_ACTION_TYPE.DEAD then
		-- DEAD
		data.dead =
		{
			deadFlag = -1,
		}	
	elseif data.m_type == SERVER_ACTION_TYPE.SKILL then
		-- SKILL
			data.skill = {
			id = 0,
			sourceGUID = 0,
		}
	elseif data.m_type == SERVER_ACTION_TYPE.MAGIC then
		-- MAGIC
		data.magic = {
			id = 0,
			sourceGUID = 0,
			posx = 0,
			posy = 0,
		}
 
		 
	elseif data.m_type == SERVER_ACTION_TYPE.BUFF then
		data.buff = {
			operationCode = 0,
			id = 0,
			target = 0,
			skillID = 0,
			layer = 0,
			source = 0,
			cd = 0,
			hp = 0,
			addRet = 0,
			sourceGUID = 0,
			buffInnerCasterIndex = 0,
		}
 
	elseif data.m_type == SERVER_ACTION_TYPE.SUMMON then
		-- SUMMON
		data.summon = {
			id = 0,
			source = 0,
			targetID = 0,
			target = 0,
			count = 0,
			x = 0,
			y = 0,
			shipAttack = 0,
			shipDefence = 0,
			shipCritical = 0,
			shipResilience = 0,
			sourceGUID = 0,
		}
	elseif data.m_type == SERVER_ACTION_TYPE.DAMAGE then
		-- DAMAGE
		data.damage = {
			id = 0,
			target = 0,
			value = 0,
			source = 0,
			damageFlag = 0,
			sourceGUID = 0,
		}
	
	
	elseif data.m_type == SERVER_ACTION_TYPE.CURE then
		-- CURE
			data.cure = {
			id = 0,
			target = 0,
			value = 0,
			source = 0,
			sourceGUID = 0,
		}	
	elseif data.m_type == SERVER_ACTION_TYPE.REVIVE then
		data.revive = {
			id = 0,
			source = 0,
			targetID = 0,
			hp = 0,
			sourceGUID = 0,
			x = 0,
			y = 0,
		}
		
	elseif data.m_type == SERVER_ACTION_TYPE.ATTRIBUTE then
		-- attr
			data.attribute = {
			id = 0,
			target = 0,
			attrType = 0,
			attrValue = 0,
			source = 0,
			sourceGUID = 0,
			typeIndex = -1,
		}		
		
	elseif data.m_type == SERVER_ACTION_TYPE.MAGIC_OVER then
		data.magicOver =
		{
			force = -1,
		}		

	elseif data.m_type == SERVER_ACTION_TYPE.BATTLE_OVER then
		-- BATTLE_OVER
	end
	
end

function rebuildData(datas)
	local _buildData = {}
	for i,data in ipairs (datas) do
		
		local d  = {}
		 
			d.m_round = data.m_round
			d.m_caster = data.m_caster
			d.m_type = data.m_type
		
		if data.m_type == SERVER_ACTION_TYPE.ACTION then
		elseif data.m_type == SERVER_ACTION_TYPE.MOVE then
			-- MOVE
			d.move =  data.move  
		 
		elseif data.m_type == SERVER_ACTION_TYPE.ATTACK then
			-- ATTACK
			d.attack   = data.attack  
				 
		elseif data.m_type == SERVER_ACTION_TYPE.RETALIATE then
			-- RETALIATE
			 d.retaliate =  data.retaliate  
			 
		elseif data.m_type == SERVER_ACTION_TYPE.LOCK then
			-- LOCK
		elseif data.m_type == SERVER_ACTION_TYPE.DEAD then
			-- DEAD
			d.dead  = data.dead
			 
		elseif data.m_type == SERVER_ACTION_TYPE.SKILL then
			-- SKILL
			d.skill = 	data.skill 
		 
		elseif data.m_type == SERVER_ACTION_TYPE.MAGIC then
			-- MAGIC
			d.magic  = data.magic 
			 
	 
			 
		elseif data.m_type == SERVER_ACTION_TYPE.BUFF then
			d.buff =  data.buff
			 
	 
		elseif data.m_type == SERVER_ACTION_TYPE.SUMMON then
			-- SUMMON
				d.summon   = data.summon  
			 
		elseif data.m_type == SERVER_ACTION_TYPE.DAMAGE then
			-- DAMAGE
				d.damage  = data.damage  
			 
		
		
		elseif data.m_type == SERVER_ACTION_TYPE.CURE then
			-- CURE
				d.cure  = data.cure 
			 
		elseif data.m_type == SERVER_ACTION_TYPE.REVIVE then
			 
			d.revive  = data.revive 
			
		elseif data.m_type == SERVER_ACTION_TYPE.ATTRIBUTE then
			-- attr
				 
				d.attribute  = data.attribute 	
			
		elseif data.m_type == SERVER_ACTION_TYPE.MAGIC_OVER then
			
			  d.magicOver  = data.magicOver 	
		elseif data.m_type == SERVER_ACTION_TYPE.BATTLE_OVER then
			-- BATTLE_OVER
		end
		table.insert(_buildData,d)
	end	
	return _buildData
end



function BattleResultParseRecordPtr()
	local tempArrayCount = 0;
	local data = {};

	-- recode
	data = {
		m_round = networkengine:parseInt(), -- 第几回合
		m_caster = networkengine:parseInt(), -- 动作发起者
		m_type = networkengine:parseInt(), -- 动作类型
		--[[
		move = {
			moveFlag = 0,
			points = {},
			pointCount = 0,
		},
		attack = {
			target = 0,
			damageFlag = 0,
			value = 0,
		},
		retaliate = {
			target = 0,
			damageFlag = 0,
			value = 0,
		},
		skill = {
			id = 0,
			sourceGUID = 0,
		},
		magic = {
			id = 0,
			sourceGUID = 0,
			posx = 0,
			posy = 0,
		},
		buff = {
			operationCode = 0,
			id = 0,
			target = 0,
			skillID = 0,
			layer = 0,
			source = 0,
			cd = 0,
			hp = 0,
			addRet = 0,
			sourceGUID = 0,
			buffInnerCasterIndex = 0,
		},
		summon = {
			id = 0,
			source = 0,
			targetID = 0,
			target = 0,
			count = 0,
			x = 0,
			y = 0,
			sourceGUID = 0,
		},
		damage = {
			id = 0,
			target = 0,
			value = 0,
			source = 0,
			damageFlag = 0,
			sourceGUID = 0,
		},
		cure = {
			id = 0,
			target = 0,
			value = 0,
			source = 0,
			sourceGUID = 0,
		},
		revive = {
			id = 0,
			source = 0,
			targetID = 0,
			hp = 0,
			sourceGUID = 0,
			x = 0,
			y = 0,
		},
		attribute = {
			id = 0,
			target = 0,
			attrType = 0,
			attrValue = 0,
			source = 0,
			sourceGUID = 0,
			typeIndex = -1,
		},		
		magicOver =
		{
			force = -1,
		}	
		,		
		dead =
		{
			deadFlag = -1,
		}	
		--]]
	};
	
	buildData(data)
	if data.m_type == SERVER_ACTION_TYPE.ACTION then
		-- ACTION
		
	elseif data.m_type == SERVER_ACTION_TYPE.MOVE then
		-- MOVE
		data.move.moveFlag = networkengine:parseInt();		
		data.move.pointCount = networkengine:parseInt();
		for j = 1, data.move.pointCount do
			data.move.points[j] = {
				x = networkengine:parseInt(),
				y = networkengine:parseInt(),
			}
		end
	elseif data.m_type == SERVER_ACTION_TYPE.ATTACK then
		-- ATTACK
		data.attack.target = networkengine:parseInt();
		data.attack.damageFlag = networkengine:parseInt();
		data.attack.value = networkengine:parseInt();
	elseif data.m_type == SERVER_ACTION_TYPE.RETALIATE then
		-- RETALIATE
		data.retaliate.target = networkengine:parseInt();
		data.retaliate.damageFlag = networkengine:parseInt();
		data.retaliate.value = networkengine:parseInt();
	elseif data.m_type == SERVER_ACTION_TYPE.LOCK then
		-- LOCK
	elseif data.m_type == SERVER_ACTION_TYPE.DEAD then
		-- DEAD
		data.dead.deadFlag = networkengine:parseInt();
	elseif data.m_type == SERVER_ACTION_TYPE.SKILL then
		-- SKILL
		data.skill.id = networkengine:parseInt();
		data.skill.sourceGUID = networkengine:parseInt();
	elseif data.m_type == SERVER_ACTION_TYPE.MAGIC then
		-- MAGIC
		data.magic.id = networkengine:parseInt();
		data.magic.sourceGUID = networkengine:parseInt();
		data.magic.posx = networkengine:parseInt();
		data.magic.posy = networkengine:parseInt();
 
		 
	elseif data.m_type == SERVER_ACTION_TYPE.BUFF then
		-- BUFF
		data.buff.operationCode = networkengine:parseInt();
		data.buff.target = networkengine:parseInt();
		data.buff.id = networkengine:parseInt();
		
		if data.buff.operationCode == 0 then
			-- BUFF_OPERATION_CODE_ADD
			data.buff.skillID = networkengine:parseInt();
			data.buff.cd = networkengine:parseInt();
			data.buff.layer = networkengine:parseInt();
			data.buff.source = networkengine:parseInt();
			data.buff.sourceGUID = networkengine:parseInt();
			data.buff.addRet = networkengine:parseInt();
			data.buff.buffInnerCasterIndex = networkengine:parseInt();
			
		elseif data.buff.operationCode == 1 then
			-- BUFF_OPERATION_CODE_EFFECT
			data.buff.cd = networkengine:parseInt();
			data.buff.layer = networkengine:parseInt();
			data.buff.sourceGUID = networkengine:parseInt();
		elseif data.buff.operationCode == 2 then
			-- BUFF_OPERATION_CODE_DELETE
			data.buff.skillID = networkengine:parseInt();
			data.buff.sourceGUID = networkengine:parseInt();
			data.buff.buffInnerCasterIndex = networkengine:parseInt();
			
		elseif data.buff.operationCode == 3 then
			-- BUFF_OPERATION_CODE_CHANGE_CD
			data.buff.skillID = networkengine:parseInt();
			data.buff.cd = networkengine:parseInt();
			data.buff.sourceGUID = networkengine:parseInt();
			data.buff.buffInnerCasterIndex = networkengine:parseInt();
			
		elseif data.buff.operationCode == 4 then
			-- BUFF_OPERATION_CODE_CHANGE_LAYER
			data.buff.skillID = networkengine:parseInt();
			data.buff.layer = networkengine:parseInt();
			data.buff.hp = networkengine:parseInt();
			data.buff.sourceGUID = networkengine:parseInt();
			data.buff.buffInnerCasterIndex = networkengine:parseInt();
			
		end
	elseif data.m_type == SERVER_ACTION_TYPE.SUMMON then
		-- SUMMON
		data.summon.id = networkengine:parseInt();
		data.summon.source = networkengine:parseInt();
		data.summon.targetID = networkengine:parseInt();
		data.summon.target = networkengine:parseInt();
		data.summon.count = networkengine:parseInt();
		data.summon.x = networkengine:parseInt();
		data.summon.y = networkengine:parseInt();
		
		data.summon.shipAttack = networkengine:parseInt();
		data.summon.shipDefence = networkengine:parseInt();
		data.summon.shipCritical = networkengine:parseInt();
		data.summon.shipResilience = networkengine:parseInt();
		 
		data.summon.sourceGUID = networkengine:parseInt();
	elseif data.m_type == SERVER_ACTION_TYPE.DAMAGE then
		-- DAMAGE
		data.damage.id = networkengine:parseInt();
		data.damage.target = networkengine:parseInt();
		data.damage.value = networkengine:parseInt();
		data.damage.source = networkengine:parseInt();
		data.damage.sourceGUID = networkengine:parseInt();		
		data.damage.damageFlag = networkengine:parseInt();
	
	elseif data.m_type == SERVER_ACTION_TYPE.CURE then
		-- CURE
		data.cure.id = networkengine:parseInt();
		data.cure.target = networkengine:parseInt();
		data.cure.value = networkengine:parseInt();
		data.cure.source = networkengine:parseInt();
		data.cure.sourceGUID = networkengine:parseInt();	
	elseif data.m_type == SERVER_ACTION_TYPE.REVIVE then
		data.revive.id = networkengine:parseInt();
		data.revive.source = networkengine:parseInt();
		data.revive.target = networkengine:parseInt();
		data.revive.hp = networkengine:parseInt();
		data.revive.x = networkengine:parseInt();
		data.revive.y = networkengine:parseInt();
		data.revive.sourceGUID = networkengine:parseInt();			
	elseif data.m_type == SERVER_ACTION_TYPE.ATTRIBUTE then
		-- attr
		data.attribute.id = networkengine:parseInt();
		data.attribute.targetType = networkengine:parseInt();
		data.attribute.target = networkengine:parseInt();
		data.attribute.typeIndex = networkengine:parseInt();
		data.attribute.attrType = networkengine:parseInt();
		data.attribute.attrValue = networkengine:parseInt();
		data.attribute.source = networkengine:parseInt();
		data.attribute.sourceGUID = networkengine:parseInt();	
		
	elseif data.m_type == SERVER_ACTION_TYPE.MAGIC_OVER then
		data.magicOver.force =  networkengine:parseInt();	
	elseif data.m_type == SERVER_ACTION_TYPE.BATTLE_OVER then
		-- BATTLE_OVER
	end
  
	
	return data;
end

function BattleResultHandler( value )
	--value = rebuildData(value)
	------------------------- log the battle recode--------------------------------------
	local typeMap = {
		[-1] = "INVALID",
		[0] = "ACTION",
		[1] = "MOVE",
		[2] = "ATTACK",
		[3] = "RETALIATE",
		[4] = "LOCK",
		[5] = "DEAD",
		[6] = "SKILL",
		[7] = "MAGIC",
		[8] = "BUFF",
		[9] = "SUMMON",
		[10] = "DAMAGE",
		[SERVER_ACTION_TYPE.CURE] = "CURE",
		[12] = "ATTRIBUTE",		
		[SERVER_ACTION_TYPE.REVIVE] = "REVIVE",		
		[SERVER_ACTION_TYPE.MAGIC_OVER] = "MAGIC_OVER",	
		[99] = "BATTLE_OVER",
 
	};
	
 
	local damageFlagMap = {
		[enum.DAMAGE_FLAG.DAMAGE_FLAG_INVALID] = "DAMAGE_FLAG_INVALID",
		[enum.DAMAGE_FLAG.DAMAGE_FLAG_NORMAL] = "DAMAGE_FLAG_NORMAL",
		[enum.DAMAGE_FLAG.DAMAGE_FLAG_DOGE] = "DAMAGE_FLAG_DOGE",
		[enum.DAMAGE_FLAG.DAMAGE_FLAG_IMMUNE] = "DAMAGE_FLAG_IMMUNE",
		[enum.DAMAGE_FLAG.DAMAGE_FLAG_BLOCK] = "DAMAGE_FLAG_BLOCK",
		[enum.DAMAGE_FLAG.DAMAGE_FLAG_ABSORB] = "DAMAGE_FLAG_ABSORB",
		[enum.DAMAGE_FLAG.DAMAGE_FLAG_TRANSFER] = "DAMAGE_FLAG_TRANSFER",		
		[enum.DAMAGE_FLAG.DAMAGE_FLAG_CRITICAL] = "DAMAGE_FLAG_CRITICAL",
		[enum.DAMAGE_FLAG.DAMAGE_FLAG_SKILLPROTECTED] = "DAMAGE_FLAG_SKILLPROTECTED",
	};
	
	local operationCodeMap = {
		[enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_INVALID] = "BUFF_OPERATION_CODE_INVALID",
		[enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_ADD] = "BUFF_OPERATION_CODE_ADD",
		[enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_EFFECT] = "BUFF_OPERATION_CODE_EFFECT",
		[enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_DELETE] = "BUFF_OPERATION_CODE_DELETE",
		[enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_CHANGE_CD] = "BUFF_OPERATION_CODE_CHANGE_CD",
		[enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_CHANGE_LAYER] = "BUFF_OPERATION_CODE_CHANGE_LAYER",
	};

	local moveFlagMap = {
		[enum.MOVE_FLAG.MOVE_FLAG_INVALID] = "MOVE_FLAG_INVALID",
		[enum.MOVE_FLAG.MOVE_FLAG_NORMAL] = "MOVE_FLAG_NORMAL",
		[enum.MOVE_FLAG.MOVE_FLAG_GOBACK] = "MOVE_FLAG_GOBACK",
		[enum.MOVE_FLAG.MOVE_FLAG_REPEL] = "MOVE_FLAG_REPEL",
		[enum.MOVE_FLAG.MOVE_FLAG_MEETHOOK] = "MOVE_FLAG_MEETHOOK",
		[enum.MOVE_FLAG.MOVE_FLAG_TRANSFER] = "MOVE_FLAG_TRANSFER",
		[enum.MOVE_FLAG.MOVE_FLAG_HOLD_POSITION] = "MOVE_FLAG_HOLD_POSITION",
	};
	
	local sourceMap = {
		[enum.SOURCE.SOURCE_INVALID] = "DAMAGE_SOURCE_INVALID",
		[enum.SOURCE.SOURCE_ATTACK] = "DAMAGE_SOURCE_ATTACK",
		[enum.SOURCE.SOURCE_RETALIATE] = "DAMAGE_SOURCE_RETALIATE",
		[enum.SOURCE.SOURCE_SKILL] = "DAMAGE_SOURCE_SKILL",
		[enum.SOURCE.SOURCE_MAGIC] = "DAMAGE_SOURCE_MAGIC",
		[enum.SOURCE.SOURCE_BUFF] = "DAMAGE_SOURCE_BUFF",		
		[enum.SOURCE.SOURCE_AURA] = "DAMAGE_SOURCE_AURA",
		[enum.SOURCE.SOURCE_FORCE_SKILL] = "DAMAGE_SOURCE_FORCE_SKILL",		
		[enum.SOURCE.SOURCE_FORCE_MAGIC] = "DAMAGE_SOURCE_FORCE_MAGIC",		
 
	};
	
	local nowRound = -1;
	for k, v in ipairs(value) do
		local typeInfo = "INVALID";
		if typeMap[v.m_type] then
			typeInfo = typeMap[v.m_type];
		end
		if v.m_round ~= nowRound then
			print("--------------------------------------round "..v.m_round.." -----------------------------------------------");
			nowRound = v.m_round;
		end
		print("round: "..v.m_round.." caster: "..v.m_caster.." m_type: "..typeInfo);
				
		if v.m_type == 0 then
			-- ACTION
			
		elseif v.m_type == 1 then
			-- MOVE
			print(v.move.moveFlag) print(v.move.pointCount)
			print("flag: "..moveFlagMap[v.move.moveFlag].."pointCount: "..v.move.pointCount);
			for pointIndex = 1, #v.move.points do
				print("point: "..pointIndex.." x: "..v.move.points[pointIndex].x.." y: "..v.move.points[pointIndex].y);
			end
		elseif v.m_type == 2 then
			-- ATTACK
			print("target: "..v.attack.target.." damageFlag: "..damageFlagMap[v.attack.damageFlag].." value: "..v.attack.value);

		elseif v.m_type == 3 then
			-- RETALIATE
			print("target: "..v.retaliate.target.." damageFlag: "..damageFlagMap[v.retaliate.damageFlag].." value: "..v.retaliate.value);
		elseif v.m_type == 4 then
			-- LOCK
		elseif v.m_type == 5 then
			-- DEAD
			print("dead flag"..v.dead.deadFlag )

		elseif v.m_type == 6 then
			-- SKILL
			print("skill id: "..v.skill.id.." guid: "..v.skill.sourceGUID);
		elseif v.m_type == 7 then
			-- MAGIC
			print("magic id: "..v.magic.id.." guid: "..v.magic.sourceGUID.." magic.posx:"..v.magic.posx.." magic.posy:"..v.magic.posy );
	 
			
		elseif v.m_type == 8 then
			-- BUFF
			print("operationCode: "..operationCodeMap[v.buff.operationCode].." target: "..v.buff.target.." id: "..v.buff.id.." guid: "..v.buff.sourceGUID);

			if v.buff.operationCode == 0 then
				-- BUFF_OPERATION_CODE_ADD
				print("skillID: "..v.buff.skillID.." cd: "..v.buff.cd.." layer: "..v.buff.layer.." source: "..sourceMap[v.buff.source].." buffInnerCasterIndex: "..v.buff.buffInnerCasterIndex.. " addRet:"..v.buff.addRet);
			
  
 
			
			elseif v.buff.operationCode == 1 then
				-- BUFF_OPERATION_CODE_EFFECT
				print("cd: "..v.buff.cd.." layer: "..v.buff.layer);
				
			elseif v.buff.operationCode == 2 then
				-- BUFF_OPERATION_CODE_DELETE
				print("skillID: "..v.buff.skillID.." buffInnerCasterIndex: "..v.buff.buffInnerCasterIndex);
				
			elseif v.buff.operationCode == 3 then
				-- BUFF_OPERATION_CODE_CHANGE_CD
				print("skillID: "..v.buff.skillID.." cd: "..v.buff.cd.." buffInnerCasterIndex: "..v.buff.buffInnerCasterIndex);
				
			elseif v.buff.operationCode == 4 then
				-- BUFF_OPERATION_CODE_CHANGE_LAYER
				print("skillID: "..v.buff.skillID.." layer: "..v.buff.layer.." hp: "..v.buff.hp.." buffInnerCasterIndex: "..v.buff.buffInnerCasterIndex);
			end
		elseif v.m_type == 9 then
			-- SUMMON
			print("id: "..v.summon.id.." source: "..sourceMap[v.summon.source].." sourceguid: "..v.summon.sourceGUID.." targetID: "..v.summon.target.." count: "..v.summon.count.." x: "..v.summon.x.." y: "..v.summon.y);
			
		elseif v.m_type == 10 then
			-- DAMAGE
			print("id: "..v.damage.id.." target: "..v.damage.target.." value: "..v.damage.value.." source: "..sourceMap[v.damage.source].." damageFlag: "..damageFlagMap[v.damage.damageFlag].." sourceguid: "..v.damage.sourceGUID);
		
		elseif v.m_type == 11 then
			-- CURE
				print("id: "..v.cure.id.." target: "..v.cure.target.." value: "..v.cure.value.." source: "..sourceMap[v.cure.source].." sourceguid: "..v.cure.sourceGUID);
		elseif v.m_type == SERVER_ACTION_TYPE.REVIVE then
				print("skillID: "..v.revive.id.." source: ".. v.revive.source .." target: "..v.revive.target.." hp: "..v.revive.hp.." sourceguid: "..v.revive.sourceGUID.." x "..v.revive.x.." y "..v.revive.y)
		
		elseif v.m_type == SERVER_ACTION_TYPE.ATTRIBUTE then
			print("source: "..sourceMap[v.attribute.source].." sourceguid: "..v.attribute.sourceGUID.."id: "..v.attribute.id.." target: "..v.attribute.target.." attrType: "..v.attribute.attrType.." attrValue: "..v.attribute.attrValue.." typeIndex: "..v.attribute.typeIndex);				
 
		elseif v.m_type == SERVER_ACTION_TYPE.MAGIC_OVER then
			print("magicOver.force "..v.magicOver.force)
 
		elseif v.m_type == SERVER_ACTION_TYPE.BATTLE_OVER then
			-- BATTLE_OVER

		end
	end
		
	print("--------------------------------------log end -----------------------------------------------");
	----------------------------log end ---------------------------------------------------
 	
 	--hpMonitor.parseRecord(value);
 		
	print("receive server battle recode  data !!!!!!!!!!!!!!!!!!!!!!")
	table.insert(sceneManager.battledata,value)
		 
			print("server  sceneManager.battledata     "..table.nums(sceneManager.battledata))	
		
	if(sceneManager._battlePlayer and sceneManager._battlePlayer:isEndBattle() == false)then
		print("resumeBattle");
		BUG_REPORT.onBattleResultHandler( value,false )
		sceneManager._battlePlayer:resumeBattle();
	else
		BUG_REPORT.onBattleResultHandler( value ,true)
		
		--global.changeGameState(function() 
			game.EnterProcess( game.GAME_STATE_BATTLE);
		--end);
		
	end
	
	  print("22222222222222222222222222222222222222222222222222222222222")
end
