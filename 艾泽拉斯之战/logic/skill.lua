skillSys = {}
skillSys.allSkill ={}
 
local  magicCDB = include("magic");
local  magicSummon = include("magicSummon");
local magicLianSuoShanDian = include("magicLianSuoShanDian");
local skillCDB = include("skillCBD");
local skillAnSha = include("skillAnSha");
local skillEjection = include("skillEjection");
local skillJianYu = include("skillJianYu");
local skillRevive = include("skillRevive");
local skillInternalConflict = include("skillInternalConflict");
local skillChuanCi = include("skillChuanCi");
local skillTianShenXiaFan = include("skillTianShenXiaFan");
local skillHuoJianJiZhong = include("skillHuoJianJiZhong");
local skillRepel = include("skillRepel");

local skillattribute = include("skillattribute");

skillSys.playingtimestamp = 0
skillSys.skillwholetime = 0
skillSys.unit = nil
skillSys.SKILL_CLASS = {}

skillSys.skilltype = {
	SKILL_CBD = 1,
	MAGIC_CBD = 2,
	SKILL_SUMMON = 3,
	REVIVE = 4,
	INTERNAL_CONFLICT = 5,
	TIAN_SHEN_XIA_FAN = 6,
	ATTRIBUTE = 7.
};

function skillSys.RegisterSkillClass(class,_type,id)
		if(skillSys.SKILL_CLASS[_type] == nil)then
			skillSys.SKILL_CLASS[_type] = {}
		end
		skillSys.SKILL_CLASS[_type][id] = class
end	

function skillSys.Init()
		
	skillSys.RegisterSkillClass(skillCDB, skillSys.skilltype.SKILL_CBD, -1);
	skillSys.RegisterSkillClass(skillAnSha, skillSys.skilltype.SKILL_CBD, enum.SKILL_TABLE_ID.AnSha); -- °µÉ±
	skillSys.RegisterSkillClass(skillAnSha, skillSys.skilltype.SKILL_CBD, enum.SKILL_TABLE_ID.AnSha2); -- °µÉ±2
	
	skillSys.RegisterSkillClass(skillEjection, skillSys.skilltype.SKILL_CBD, enum.SKILL_TABLE_ID.TanShe); -- µ¯Éä
	skillSys.RegisterSkillClass(skillEjection, skillSys.skilltype.SKILL_CBD, enum.SKILL_TABLE_ID.ZhiLiaoBo); -- µ¯Éä
	skillSys.RegisterSkillClass(skillEjection, skillSys.skilltype.SKILL_CBD, enum.SKILL_TABLE_ID.ShanDianLian); -- µ¯Éä
	skillSys.RegisterSkillClass(skillJianYu, skillSys.skilltype.SKILL_CBD, enum.SKILL_TABLE_ID.AoShuFeiDan); -- °ÂÊõ·Éµ¯
	skillSys.RegisterSkillClass(skillJianYu, skillSys.skilltype.SKILL_CBD, enum.SKILL_TABLE_ID.JianYu); -- ½£Óê
	skillSys.RegisterSkillClass(skillChuanCi, skillSys.skilltype.SKILL_CBD, enum.SKILL_TABLE_ID.ChuanCi); -- ´©´Ì
	skillSys.RegisterSkillClass(skillTianShenXiaFan, skillSys.skilltype.TIAN_SHEN_XIA_FAN, -1); -- ÌìÉñÏÂ·²
	skillSys.RegisterSkillClass(skillHuoJianJiZhong, skillSys.skilltype.SKILL_CBD, enum.SKILL_TABLE_ID.HuoJianJiZhong); -- GMÊæ¿Ë»ð¼ý»÷ÖÐ
	skillSys.RegisterSkillClass(skillRepel, skillSys.skilltype.SKILL_CBD, enum.SKILL_TABLE_ID.Repel); -- »÷ÍË
	skillSys.RegisterSkillClass(skillRepel, skillSys.skilltype.SKILL_CBD, enum.SKILL_TABLE_ID.Repel2); -- »÷ÍË
	
	skillSys.RegisterSkillClass(magicCDB, skillSys.skilltype.MAGIC_CBD, -1);
	skillSys.RegisterSkillClass(magicLianSuoShanDian, skillSys.skilltype.MAGIC_CBD, enum.MAGIC_TABEL_ID.LianSuoShanDian);
	skillSys.RegisterSkillClass(magicLianSuoShanDian, skillSys.skilltype.MAGIC_CBD, enum.MAGIC_TABEL_ID.ZhiLiaoBo);
	skillSys.RegisterSkillClass(magicLianSuoShanDian, skillSys.skilltype.MAGIC_CBD, enum.MAGIC_TABEL_ID.QianLiLianSuoShanDian);
	skillSys.RegisterSkillClass(magicLianSuoShanDian, skillSys.skilltype.MAGIC_CBD, enum.MAGIC_TABEL_ID.ShanDianLian);
	skillSys.RegisterSkillClass(magicLianSuoShanDian, skillSys.skilltype.MAGIC_CBD, enum.MAGIC_TABEL_ID.ZengQiangShanDianLian);
	
 	skillSys.RegisterSkillClass(magicSummon, skillSys.skilltype.SKILL_SUMMON, -1);
	skillSys.RegisterSkillClass(skillRevive, skillSys.skilltype.REVIVE, -1);
	skillSys.RegisterSkillClass(skillInternalConflict, skillSys.skilltype.INTERNAL_CONFLICT, -1);
	
	skillSys.RegisterSkillClass(skillattribute, skillSys.skilltype.ATTRIBUTE, -1);
 
end	

function skillSys.OnTick(t)

	if(skillSys.curSkill)then
				
		if skillSys.curSkill:getPreCameraTimer() <=0 then
		  
		  skillSys.curSkill:setPreCameraTimer(0);
		  
		  skillSys.curSkill:onEndPreCamera();
		  
		  local res = skillSys.curSkill:OnTick(t)
		  if(res == true)then			
				skillSys.curSkill = nil
		  end	
		 	return res
		else
			-- ÓÉÓÚÓÐÇ°ÖÃµÄÉãÏñ»ú¾µÍ·±íÏÖ
			skillSys.curSkill:setPreCameraTimer(skillSys.curSkill:getPreCameraTimer()-t);
			return false;
		end
	end
							
	return true				
end

function skillSys.getSkillClass(_type,id)
	--print("skillSys.getSkillClass ".._type)
	if(skillSys.SKILL_CLASS[_type][id])then
		return skillSys.SKILL_CLASS[_type][id]
	end
	return skillSys.SKILL_CLASS[_type][-1]
end

function skillSys.Play(cropsUnit,action)
	local param = nil	
	param = action._param.targets;		
	local skillId = action._param.skillid
	local skilltype = nil
	
	if action._type == ACTION_TYPE.SKILL then
		skilltype = skillSys.skilltype.SKILL_CBD	
	elseif action._type == ACTION_TYPE.MAGIC then
		skilltype = skillSys.skilltype.MAGIC_CBD			
	elseif action._type == ACTION_TYPE.SUMMON then
		skilltype = skillSys.skilltype.SKILL_SUMMON	
	end		
	
	 
	local skillInsatnce  = skillSys.createSkill(false,skilltype, skillId, param, cropsUnit,action);
	
	if action._type == ACTION_TYPE.SKILL then
		local skillinifo = dataConfig.configs.skillConfig[skillId];
		if cropsUnit and skillinifo and skillinifo.sound then
			if cropsUnit:getForces() == enum.FORCE.FORCE_ATTACK then
				if skillinifo.sound[1] then
					LORD.SoundSystem:Instance():playEffect(skillinifo.sound[1]);
				end
			else
				if skillinifo.sound[2] then
					LORD.SoundSystem:Instance():playEffect(skillinifo.sound[2]);
				end
			end
		end
	end
	
	skillInsatnce:play()
	skillSys.curSkill = skillInsatnce
end

function skillSys.createSkill(issubSkill,_type, skillId, param, cropsUnit,action)
	local skillInsatnce = nil
	local class = skillSys.getSkillClass(_type, skillId)
	--print("skillSys.createSkill  "..skillId.." _type ".._type.." targetCount: "..#param);
	skillInsatnce = class.new(skillId)
	skillInsatnce:Init({caster = cropsUnit, targets = param,})	
	skillInsatnce.originAction = action	
	skillInsatnce.isSub = issubSkill
	
	table.insert(skillSys.allSkill,skillInsatnce)		
	
	local casterIsKing =  iskindof(cropsUnit,"kingClass")
	if(casterIsKing)then
	
		skillInsatnce.casterIsKing  = casterIsKing
		
		cropsUnit.force = skillInsatnce.originAction._id;
		
		if(skillInsatnce.originAction._id == battlePlayer.force)then
			skillInsatnce.caster_self_king = true
		else
			skillInsatnce.caster_self_king = false	
		end			
		
		eventManager.dispatchEvent( {name = global_event.GUIDE_ON_KING_PLAY_MAGIC,arg1= skillInsatnce.caster_self_king , arg2 = skillId })	
		--[[local mp = dataManager.playerData:getMp()	
		local skillinfo =  dataManager.kingMagic:getSkillConfig(skillId)	
		mp = mp - skillinfo.cost		 
		if(mp < 0)then
			mp = 0
		end		
		dataManager.playerData:setMp(mp) 
		---]]
		if( skillInsatnce.caster_self_king == true )then
			if(not skillInsatnce:isSubSkill())then
				dataManager.kingMagic:onMagicCaster(skillId)
			end	
		else
						
		end	
		if(not skillInsatnce:isSubSkill())then
			eventManager.dispatchEvent( {name = global_event.BATTLE_UI_KING_CASERTMAGIC,magicId = skillId, self = (skillInsatnce.caster_self_king == true)} )	
			eventManager.dispatchEvent({name = global_event.BATTLE_UI_SWITCH_TO_SKILL_ROUND,show = false,self = (skillInsatnce.caster_self_king == true)});
			
			if skillInsatnce.caster_self_king == true then
				eventManager.dispatchEvent({name = global_event.BATTLE_UI_FLY_MAGIC_AWAY });
			end
			
		end
	end	
	return skillInsatnce
end