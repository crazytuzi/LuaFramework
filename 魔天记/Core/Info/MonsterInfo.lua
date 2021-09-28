require "Core.Info.FightRoleInfo";

MonsterInfo = class("MonsterInfo", FightRoleInfo);

MonsterInfoType = {
	-- 怪物类型
	NORMAL = 1;-- 普通
	ELITE = 2;-- 精英
	BOSS = 3;-- boss
	CONVOY = 4, --护送
	FIGHT_NPC = 5 --战斗npc
	
}

function MonsterInfo:New(kind, level)
	self = {};
	setmetatable(self, {__index = MonsterInfo});
	self:_InitDefAttribute();
	self.baseSkills = {};
	self.skills = {};
	
	self:_Init(kind, level);
	return self;
end

function MonsterInfo:_Init(kind, level)
	local monsterCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MONSTER);
	local baseInfo = monsterCfg[kind];

	if(baseInfo) then
		local lv = level or baseInfo.level;
		-- local attr = self:_InitAttribute(baseInfo.attr_calc, lv);
		 baseInfo = ConfigManager.TransformConfig(baseInfo)	 
		 table.copyTo(baseInfo, self);
		 
		self.position = Convert.PointFromServer(baseInfo.x, baseInfo.y, baseInfo.z);
		self:_SetBaseAttribute(baseInfo);
		--怪物不需要计算属性
		--self:_SetBaseAttribute(attr);
		self:_InitDefaultSkills();
		self.kind = baseInfo.id;
		self.hp = self.hp_max;
		self.mp = self.mp_max;
		self.level = lv;
		self.mapItemType = MapItemType.Monster
		
	end
end

--不需要计算属性
-- function MonsterInfo:_InitAttribute(attrCalc, level)
-- 	local arrtCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MONSTER_ATTR);
-- 	local bInfo = nil;
-- 	for i, v in pairs(attrCalc) do
-- 		local t = arrtCfg[v .. "_" .. level];
-- 		if(t) then
-- 			if(bInfo) then
-- 				t = ConfigManager.TransformConfig(t)
-- 				self:_MergeAttribute(t, bInfo);
-- 			else
-- 				bInfo = ConfigManager.Clone(t);
-- 			end
-- 		end
-- 	end
-- 	return bInfo;
-- end

function MonsterInfo:_MergeAttribute(s, d)
	for i, v in pairs(s) do
		if(d[i]) then
			d[i] = d[i] + v;
		end
	end
end

function MonsterInfo:SetLevel(level)
	if(self.level ~= level) then
		self.level = level
		-- local attr = self:_InitAttribute(self.attr_calc, level);
		-- if(attr) then
		-- 	self:_SetBaseAttribute(att);			
		-- end
	end
end