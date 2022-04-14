--
-- @Author: LaoY
-- @Date:   2018-12-21 19:55:42
--


MtTreasureConstant = {}

-- 缓存的key
MtTreasureConstant.CacheSkipKey = "MtTreasure_Skip"
-- 可以跳过功能的等级
MtTreasureConstant.SKipLevel = 240

MtTreasureConstant.NPCList = {
	1500001,
	1500002,
	1500003,
	1500004,
}

-- 星力石ID 自动增加上限值
MtTreasureConstant.StarPowerStoneID = 10601
local value = Config.db_game["mchunt_power_max"] and Config.db_game["mchunt_power_max"].value or 400
MtTreasureConstant.StarPowerMax 	= tonumber(value)

MtTreasureConstant.LinkShopID = "180@1@1@2@1222"

-- 寻路到NPC，触发对话的延迟时间
MtTreasureConstant.TouchNPCTime = 0.6

--魔物选择
MtTreasureConstant.SelectDes = "You feel demons haunting before countdown ends or the demons flee select one and go."

--收服方式选择
MtTreasureConstant.DigDes = [[
You found an elf involved with magic power,so in which way can you seal the card?
<color=#e21b1b>In different areas</color>,the ways that magic elves live vary.The way you used to <color=#e21b1b>tame</color> may affect the final outcome.
]]

MtTreasureConstant.TalkShow = {
	[1] = {
		[1] = [[
I was born in the wild forests and protected by the goddess of earth.The dark night persists until wisdom was born. Now, I travel through the universe, seeking the one that maximizes my power.
		]],
		[2] = [[
I won't fail you, Let us steer the wind and reach the top of the world.
		]],
	},
	[2] = {
		[1] = [[
I was born in the vast ocean.My soul, travels through the tranquil waters. Magic power, it grew with the blessing of Poseidon. Now, I travel all seas, seeking the one that maximizes my power. Let us travel above the seas.
		]],
		[2] = [[
I won't fail you, Let us steer the wind and reach the top of the world.
		]],
	},
	[3] = {
		[1] = [[
I was born into the blazing flame and resurrected in the infernal flame that devours everything. Now, I come to this desolated land, seeking the one that maximizes my power.
		]],
		[2] = [[
I won't fail you, Let us steer the wind and reach the top of the world.
		]],
	},
	[4] = {
		[1] = [[
I, come from the grand cosmos which grants me immortality.The ancient stardusts, they grant my soul eternity. Among the nebulas, I soar, I seek, the one who truly motivates me.
		]],
		[2] = [[
Let me be by your side forever.
		]],
	},
}