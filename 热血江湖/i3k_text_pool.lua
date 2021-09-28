------------------------------------------------------
local require = require


------------------------------------------------------
-- 文字特效类型
-- player, monster, mercenary, trap
eEffectID_Heal			= { style = { { aid =  1, prefix = 'heal_' },	{ aid =  2, prefix = 'heal_' }, { aid =  2, prefix = 'heal_' }, { aid = 20, prefix = 'heal_' } },	txt = "" };
eEffectID_HealCri		= { style = { { aid = 17, prefix = 'heal_' },	{ aid = 18, prefix = 'heal_' }, { aid = 19, prefix = 'heal_' }, { aid = 20, prefix = 'heal_' } },	txt = "暴击" };
eEffectID_SP			= { style = { { aid =  9, prefix = '' },		{ aid = 10, prefix = '' },		{ aid = 10, prefix = '' },		{ aid = 20, prefix = '' } },		txt = "" };
eEffectID_Damage 		= { style = { { aid =  3, prefix = 'dmg2_' },	{ aid =  4, prefix = 'dmg1_' }, { aid =  5, prefix = 'dmg3_' }, { aid = 20, prefix = 'dmg2_' } },	txt = "" };
eEffectID_DamageCri		= { style = { { aid =  6, prefix = 'dmg2_' },	{ aid =  7, prefix = 'dmg1_' }, { aid =  8, prefix = 'dmg3_' }, { aid = 20, prefix = 'dmg2_' } },	txt = "暴击" };
eEffectID_Dodge			= { style = { { aid = 11, prefix = '' },		{ aid = 12, prefix = '' },		{ aid = 13, prefix = '' },		{ aid = 20, prefix = '' } },		txt = "闪避" };
eEffectID_Buff			= { style = { { aid = 14, prefix = '' },		{ aid = 14, prefix = '' },		{ aid = 14, prefix = '' },		{ aid = 14, prefix = '' } },		txt = "" };
eEffectID_DeBuff		= { style = { { aid = 15, prefix = '' },		{ aid = 15, prefix = '' },		{ aid = 15, prefix = '' },		{ aid = 15, prefix = '' } },		txt = "" };
eEffectID_DodgeEx		= { style = { { aid =  3, prefix = 'dmg2_' },	{ aid =  4, prefix = 'dmg1_' },	{ aid =  5, prefix = 'dmg3_' },	{ aid = 20, prefix = 'dmg2_' } },	txt = "偏斜" };
eEffectID_Reduce		= { style = { { aid = 11, prefix = 'dmg2_' },	{ aid = 12, prefix = 'dmg1_' },	{ aid = 13, prefix = 'dmg3_' },	{ aid = 20, prefix = 'dmg2_' } },	txt = "吸收" };
eEffectID_ExSkill		= { style = { { aid = 22, prefix = '' },		{ aid = 22, prefix = '' },		{ aid = 22, prefix = '' },		{ aid = 22, prefix = '' } },		txt = "" };
eEffectID_NS			= { style = { { aid =  23, prefix = 'ns_' },	{ aid =  23, prefix = 'ns_' }, { aid =  23, prefix = 'ns_' }, { aid = 23, prefix = 'ns_' } },	txt = "内伤" };
eEffectID_YFNS			= { style = { { aid =  24, prefix = 'ns_' },	{ aid =  24, prefix = 'ns_' }, { aid =  24, prefix = 'ns_' }, { aid = 24, prefix = 'ns_' } },	txt = "引发内伤" };

------------------------------------------------------
i3k_text_effect_pool = i3k_class("i3k_text_effect_pool");
function i3k_text_effect_pool:ctor()
	self._effects	= i3k_queue.new();
	self._preTick	= 0;
	self._lastTick	= 350;
end

function i3k_text_effect_pool:OnUpdate(dTime)
	self._lastTick = self._lastTick + i3k_integer(dTime * 1000);

	local maxPopSize = 5;

	local es = self._effects:size();
	if es > 0 then
		if self._lastTick > self._preTick then
			self._lastTick	= 0;
			self._preTick	= 50;--200 * math.min(es, maxPopSize);

			local popSize = 0;

			local eff = self._effects:pop();
			repeat
				local en = self._effects:size();

				if eff then
					eff.pos.y = eff.pos.y + 0.35 * en;

					--local effHdr = g_i3k_effect_mgr:SetTextEffect(eff.type.aid, eff.pos, eff.text, eff.dur);
					local effHdr = g_i3k_effect_mgr:SetImageEffect(eff.type.aid, eff.pos, eff.type.prefix, eff.text, eff.dur);
				end

				eff = self._effects:pop();

				popSize = popSize + 1;
				if popSize >= maxPopSize then
					break;
				end
			until eff == nil
		end
	end
end

function i3k_text_effect_pool:AllocEffect(effType, pos, text, duration)
	local eff = { };
		eff.type	= effType;
		eff.pos		= pos;
		eff.text	= text;
		eff.dur		= duration;
	self._effects:push(eff);
end

function i3k_text_effect_pool:Size()
	return self._effects:size();
end

function i3k_text_effect_pool:Clear()
	self._effects:clear();
end

