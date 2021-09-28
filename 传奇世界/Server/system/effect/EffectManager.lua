--EffectManager.lua
require ("system.effect.EffectConstant")
require ("system.effect.ItemRandom")
require ("system.effect.Effect")
require ("system.effect.ChangeAttEffect")
require ("system.effect.ItemGiftEffect")
require ("system.effect.SendEffect")
require ("system.effect.AddConquerTaskEffect")
require ("system.effect.LearnSkillEffect")
require ("system.effect.AddBuffEffect")
require ("system.effect.ExtendBagEffect")
require ("system.effect.ActivityEffect")
require ("system.effect.CommandBookEffect")
require ("system.effect.EnvoyExpEffect")
require ("system.effect.TreasureExpEffect")
require ("system.effect.MarriageDrinkEffect")


EffectTypeMap = {
	[EffectType.ChangeAttribute] = ChangeAttEffect,
	[EffectType.Send] = SendEffect,
	[EffectType.AddBuff] = AddBuffEffect,
	[EffectType.RandSend] = SendEffect,
	[EffectType.LearnSkill] = LearnSkillEffect,
	[EffectType.ItemGift] = ItemGiftEffect,
	[EffectType.ItemChest] = ItemGiftEffect,
	[EffectType.AddConquerTask] = AddConquerTaskEffect,
	[EffectType.ItemDropChest] = ItemGiftEffect,
	[EffectType.ActivityUse] = ActivityEffect,
	[EffectType.CommandBook] = CommandBookEffect,
	[EffectType.EnvoyExpEffect] = EnvoyExpEffect,
	[EffectType.TreasureExpEffect] = TreasureExpEffect,
	[EffectType.MarriageDrinkEffect] = MarriageDrinkEffect,
}

__initConfig()
initConstName()