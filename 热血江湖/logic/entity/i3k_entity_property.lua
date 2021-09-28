------------------------------------------------------
local require = require

--[[
	【重构】每次注册新的属性，需要改次文件的三处：
	1. 定义一个全局的 ePropType_xxxx = xxx
	2. 定义 self._valuexx	= {Base = 0,Percent = 0};	
	3. 在 self.ePropType_tab 表中添加对应的映射关系
]]
------------------------------------------------------
ePropType_Base			= 0;
ePropType_Skill			= 1;
ePropType_Equip			= 2;
ePropType_Talent		= 3;
ePropType_Reward		= 4;
ePropType_Weapon		= 5;
ePropType_FightSP		= 6;
ePropType_Faction		= 7;
ePropType_Profession	= 8;
ePropType_Passive		= 9;
ePropType_SuitEquip		= 10;
ePropType_Horse			= 11;
ePropType_Fashion		= 12;
ePropType_MissionMode	= 13;
ePropType_Collection	= 14;
ePropType_ClanChild		= 15;
ePropType_Longyin		= 16;
ePropType_Lilian		= 17;
ePropType_TitleIcon		= 18;
ePropType_MercenaryAchievement	= 19;
ePropType_MercenaryRelation	= 20;
ePropType_Armor				= 21;
ePropType_Marry				= 22;
ePropType_HorseSkill		= 23;
ePropType_Weapon_Talent 	= 24;
ePropType_OneTimeItem		= 25;
ePropType_UniqueSkill   	= 26;
ePropType_ArmorTalent		= 27;
ePropType_ArmorRune			= 28;
ePropType_MercenarySpirits	= 29
ePropType_SpecialCard		= 30
ePropType_HeirloomStrength	= 31;
ePropType_SkillPassive  	= 32;
ePropType_EpicTask			= 33;
ePropType_MartialSoul		= 34;
ePropType_Qiling			= 35;
ePropType_QilingTrans		= 36;
ePropType_StarSoul			= 37;
ePropType_Meridian			= 38;
ePropType_XingHun			= 39;
ePropType_BaGua				= 40;
ePropType_DestinyRoll		= 41;
ePropType_XiuXin			= 42;
ePropType_HideWeapon		= 43;--新增类型时要修改ResetPropertys方法
ePropType_Wujue				= 44;
ePropType_Metamorphosis		= 45;
ePropType_HorseEquip		= 46;
ePropType_PetGuard 			= 47;
ePropType_RoleFlying		= 48;
ePropType_ShenDou			= 49;
ePropType_CardPacket 		= 50;
ePropType_ArrayStone		= 51;
ePropType_WardZoneCard		= 52;
ePropType_Biography			= 53;
ePropType_CombatType		= 54;

ePropChangeType_Base		= 0;
ePropChangeType_Percent		= 1;

i3k_entity_property = i3k_class("i3k_entity_property");
function i3k_entity_property:ctor(entity, id, type) -- type = 0: int; = 1 float
	self._entity 	= entity;
	self._id		= id;
	self._valueB	= {Base = 0,Percent = 0}; 	-- 基础属性
	self._valueE	= {Base = 0,Percent = 0}; 	-- 附加属性
	self._valueP	= {Base = 0,Percent = 0};	-- 装备附加属性
	self._valueT	= {Base = 0,Percent = 0};	-- 心法属性
	self._valueR	= {Base = 0,Percent = 0};	-- 奖励属性
	self._valueS	= {Base = 0,Percent = 0};	-- 神兵属性
	self._valueF	= {Base = 0,Percent = 0};	-- 战斗能量属性
	self._valueFS	= {Base = 0,Percent = 0};	-- 宗派技能属性
	self._valuePF	= {Base = 0,Percent = 0};	-- 职业属性
	self._valuePS	= {Base = 0,Percent = 0};	-- 被动属性
	self._valueSE	= {Base = 0,Percent = 0};	-- 套装属性
	self._valueH	= {Base = 0,Percent = 0};	-- 坐骑属性
	self._valueFD	= {Base = 0,Percent = 0};	-- 时装属性
	self._valueMM	= {Base = 0,Percent = 0};	-- 任务变身属性
	self._valueC	= {Base = 0,Percent = 0};	-- 收藏品属性
	self._valueCC	= {Base = 0,Percent = 0};	-- 宗门弟子属性
	self._valueLY	= {Base = 0,Percent = 0};	-- 龙印属性
	self._valueLL	= {Base = 0,Percent = 0};	-- 历练属性
	self._valueTI	= {Base = 0,Percent = 0};	-- 头衔属性
	self._valueMA	= {Base = 0,Percent = 0};	-- 随从成就属性
	self._valueRL	= {Base = 0,Percent = 0};	-- 随从合修属性
	self._valueAM	= {Base = 0,Percent = 0};	-- 内甲属性
	self._valueMY	= {Base = 0,Percent = 0};	-- 结婚属性
	self._valueHS	= {Base = 0,Percent = 0};	-- 坐骑骑术属性
	self._valueTL   = {Base = 0,Percent = 0};   -- 神兵天赋属性
	self._valueOI	= {Base = 0,Percent = 0};	-- 限制物品属性
	self._valueUS	= {Base = 0,Percent = 0};	-- 神兵特技属性
	self._valueAMT	= {Base = 0,Percent = 0};	-- 内甲天赋
	self._valueAMR	= {Base = 0,Percent = 0};	-- 内甲符文
	self._valueMS	= {Base = 0,Percent = 0};	-- 随从心法
	self._valueSC	= {Base = 0,Percent = 0};	-- 特权卡
	self._valueHA	= {Base = 0,Percent = 0};	-- 传家宝精化
	self._valueSP 	= {Base = 0,Percent = 0};	-- 被动技能
	self._valueEPT 	= {Base = 0,Percent = 0};	-- 史诗技能
	self._valueMAS 	= {Base = 0,Percent = 0};	-- 武魂属性
	self._valueSD	= {Base = 0,Percent = 0};	-- 星盘属性
	self._valueQL	= {Base = 0,Percent = 0}; 	-- 神兵器灵属性
	self._valueQLT	= {Base = 0,Percent = 0}; 	-- 神兵器灵变身属性
	self._valueJM	= {Base = 0,Percent = 0}; 	-- 经脉系统属性
	self._valueXH	= {Base = 0,Percent = 0}; 	-- 星魂系统属性
	self._valueBG	= {Base = 0,Percent = 0}; 	-- 八卦系统属性
	self._valueDR	= {Base = 0,Percent = 0};	-- 五转之路天命轮
	self._valueXX	= {Base = 0,Percent = 0};	-- 修心属性
	self._valueHW	= {Base = 0,Percent = 0};	-- 暗器属性
	self._valueGS 	= {Base = 0,Percent = 0};	-- 神斗属性
	self._valueHX	= {Base = 0,Percent = 0};	-- 幻形
	self._valueWJ	= {Base = 0,Percent = 0};	-- 武决
	self._valueHE	= {Base = 0,Percent = 0};	-- 骑战装备属性
	self._valuePG 	= {Base = 0,Percent = 0};	-- 守护灵兽
	self._valueRF 	= {Base = 0,Percent = 0};	-- 角色飞升
	self._valueCP	= {Base = 0,Percent = 0};	-- 图鉴属性
	self._valueWZC	= {Base = 0, Percent = 0};  --战区效果
	self._valueAS	= {Base = 0,Percent = 0};	-- 阵法石
	self._valueBIO	= {Base = 0,Percent = 0};	-- 外传职业，只有在外传试炼副本里才刷新
	self._valueCBT	= {Base = 0,Percent = 0};	-- 拳师姿态属性
	self._value		= 0;
	self._valueBase		= 0;
	self._valuePercent	= 0;
	self._type 		= type;

	local p = i3k_db_prop_id[id];
	if p then
		self._desc 			= p.desc;
		self._canNegative	= p.canNegative == 1;
		self._propCfg		= p;
	end


	self.ePropType_tab =
	{
		[ePropType_Base]                = { value = self._valueB },
		[ePropType_Skill]               = { value = self._valueE },
		[ePropType_Equip]               = { value = self._valueP },
		[ePropType_Talent]              = { value = self._valueT },
		[ePropType_Reward]              = { value = self._valueR },
		[ePropType_Weapon]              = { value = self._valueS },
		[ePropType_FightSP]             = { value = self._valueF },
		[ePropType_Faction]             = { value = self._valueFS },
		[ePropType_Profession]          = { value = self._valuePF },
		[ePropType_Passive]             = { value = self._valuePS },
		[ePropType_SuitEquip]           = { value = self._valueSE },
		[ePropType_Horse]               = { value = self._valueH },
		[ePropType_HorseSkill]          = { value = self._valueHS },
		[ePropType_Fashion]             = { value = self._valueFD },
		[ePropType_MissionMode]         = { value = self._valueMM },
		[ePropType_Collection]          = { value = self._valueC },
		[ePropType_ClanChild]           = { value = self._valueCC },
		[ePropType_Longyin]             = { value = self._valueLY },
		[ePropType_Lilian]              = { value = self._valueLL },
		[ePropType_TitleIcon]           = { value = self._valueTI },
		[ePropType_MercenaryAchievement]= { value = self._valueMA },
		[ePropType_MercenaryRelation]   = { value = self._valueRL },
		[ePropType_Armor]               = { value = self._valueAM },
		[ePropType_ArmorTalent]         = { value = self._valueAMT },
		[ePropType_ArmorRune]           = { value = self._valueAMR },
		[ePropType_Marry]               = { value = self._valueMY },
		[ePropType_Weapon_Talent]       = { value = self._valueTL },
		[ePropType_OneTimeItem]         = { value = self._valueOI },
		[ePropType_UniqueSkill]         = { value = self._valueUS },
		[ePropType_MercenarySpirits]    = { value = self._valueMS },
		[ePropType_SpecialCard]         = { value = self._valueSC },
		[ePropType_HeirloomStrength]    = { value = self._valueHA },
		[ePropType_SkillPassive]        = { value = self._valueSP },
		[ePropType_EpicTask]            = { value = self._valueEPT },
		[ePropType_MartialSoul]         = { value = self._valueMAS },
		[ePropType_StarSoul]            = { value = self._valueSD },
		[ePropType_Qiling]              = { value = self._valueQL },
		[ePropType_QilingTrans]         = { value = self._valueQLT },
		[ePropType_Meridian]            = { value = self._valueJM },
		[ePropType_XingHun]			    = { value = self._valueXH },
		[ePropType_BaGua]				= { value = self._valueBG },
		[ePropType_DestinyRoll]			= { value = self._valueDR },
		[ePropType_XiuXin]				= { value = self._valueXX },
		[ePropType_HideWeapon]			= { value = self._valueHW },
		[ePropType_CardPacket] 			= { value = self._valueCP },
		[ePropType_ShenDou]			    = { value = self._valueGS },
		[ePropType_Metamorphosis]		= { value = self._valueHX },
		[ePropType_Wujue]				= { value = self._valueWJ },
		[ePropType_HorseEquip]			= { value = self._valueHE },
		[ePropType_PetGuard]			= { value = self._valuePG },
		[ePropType_RoleFlying] 			= { value = self._valueRF },
		[ePropType_WardZoneCard]		= { value = self._valueWZC },
		[ePropType_ArrayStone]			= { value = self._valueAS },
		[ePropType_Biography]			= { value = self._valueBIO },
		[ePropType_CombatType]			= { value = self._valueCBT },
	}

	self._maxPropID = #self.ePropType_tab

		end

function i3k_entity_property:setPropType(pt, valuetype, value)
    local TYPE_BASE     = ePropChangeType_Base
    local TYPE_PERCENT  = ePropChangeType_Percent

    local cfg = self.ePropType_tab[pt]
		if valuetype == ePropChangeType_Base then
        cfg.value.Base = i3k_integer(value)
		elseif valuetype == ePropChangeType_Percent then
        cfg.value.Percent = i3k_integer(value)
		end
		end

function i3k_entity_property:getValueBase()
    local base = 0
    for _, v in pairs(self.ePropType_tab) do
        base = base + v.value.Base
		end
    return base
		end
function i3k_entity_property:getValuePercent()
    local percent = 0
    for _, v in pairs(self.ePropType_tab) do
        percent = percent + v.value.Percent
		end
    return percent
		end

function i3k_entity_property:Set(value, pt, silent,valuetype)
	local value_o = self._value;
	if not valuetype then
		valuetype = ePropChangeType_Base
		end
	self:setPropType(pt, valuetype, value)

	self._valueBase = self:getValueBase()
    self._valuePercent = self:getValuePercent() + 10000

	local valueBase = self._valueBase
	if self._type ~= 0 then
		valueBase = self._valueBase / 10000
	end

	self._value = valueBase * (self._valuePercent/10000)

	if self._type == 0 then
		self._value = i3k_integer(self._value);
	end

	if self._value < 0 then
		if not self._canNegative then
			self._value = 0;
		end
	end

	if self._value ~= value_o and not silent and self._entity then
		local entityType = self._entity:GetEntityType()
		local condition = self._entity:IsPlayer() or entityType == eET_Pet or entityType == eET_Summoned or entityType == eET_Mercenary
		if condition and self._propCfg and self._propCfg.minValue ~= 0 then
			if self._value < self._propCfg.minValue then
				self._value = self._propCfg.minValue
			end
		end
		self._entity:OnPropUpdated(self._id, self._value);
	end
end

function i3k_entity_property:GetValue(changValue)
	self._valueBase = self:getValueBase()
    self._valuePercent = self:getValuePercent() + 10000

	local valueBase = self._valueBase
	if self._type ~= 0 then
		valueBase = self._valueBase / 10000
	end

	if self._propCfg and changValue ~= 0 and self._propCfg.isChangeForAll == 1 then
		self._valuePercent = self._valuePercent - changValue
	end

	self._value = valueBase * (self._valuePercent/10000)

	if self._type == 0 then
		self._value = i3k_integer(self._value);
	end

	if self._value < 0 then
		if not self._canNegative then
			self._value = 0;
		end
	end

	return self._value;
end

function i3k_entity_property:GetValuePure()
	local res = (self._valueBase - self._valuePS.Base - self._valueF.Base - self._valueHS.Base - self._valueTL.Base - self._valueUS.Base 
	- self._valueAMT.Base - self._valueAMR.Base - self._valueSP.Base - self._valueQLT.Base - self._valueJM.Base - self._valueWZC.Base);
	if self._type ~= 0 then
		res = res / 10000
	end
	return res
end

function i3k_entity_property:ResetPropertys()
	for i = ePropType_Base, self._maxPropID do
		self:Set(0, i,false,ePropChangeType_Base);
		self:Set(0, i,false,ePropChangeType_Percent);
	end
end

function i3k_entity_property:GetPropertyPart(syllable)
	if self[syllable] then
		return self[syllable]
	end
	return nil
end
function i3k_entity_property:printProps()
	for k, v in pairs(self) do
		if string.match(k, "_value") and type(v) == "table" then
			if v.Base ~= 0 or v.Percent ~= 0 then
				i3k_log(k, "base ", v.Base, " percent ", v.Percent)
			end
		end
	end
end
