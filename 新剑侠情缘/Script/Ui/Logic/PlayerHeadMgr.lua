

local AvatarHead = luanet.import_type("AvatarHeadMgr")

print("tbPlayerHeadMgr", AvatarHead)

Ui.tbPlayerHeadMgr = Ui.tbPlayerHeadMgr or {}
local tbPlayerHeadMgr = Ui.tbPlayerHeadMgr

--NPC与玩家
local tbBloodType = 
{
	"TeammateBlood",		-- 友方血条，友方NPC
	"StripRed",		-- 可攻击的NPC
	"StripRed",			-- 可攻击玩家
	"StripPurple",		-- 开了屠杀的玩家
	"TeammateBlood2",		-- 队友
}

--怪物 （BOSS带扣血动画 小怪不带动画）
local tbMonsterBloodStyle =
{	
	[1] = --普通怪物1管血
	{
		"MonsterBlood",
		"MonsterBlood",
	},

	[2] = --boss1管血
	{
		"BossBlood",
		"MonsterBlood",
	},

	[3] = --boss2管血
	{
		"BossBlood", -- 组件名称
		"BossBlood", -- 1阶级血条样式
		"StripGreen", -- 2阶段血条样式
	},
}

function tbPlayerHeadMgr:Init()
	for nType, szType in pairs(tbBloodType) do
		AvatarHead.RegisterBloodType(nType, szType);
	end

	for nIndex, tbStyle in pairs(tbMonsterBloodStyle) do
		local szStyle = tbStyle[1];
		AvatarHead.RegisterMonsterBlood(nIndex, szStyle);
		for i = 2, #tbStyle do
			AvatarHead.RegisterMonsterBloodLevel(nIndex, tbStyle[i]);
		end
	end
end