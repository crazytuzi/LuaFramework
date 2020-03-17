--[[
Npc常量
haohu
2014年8月14日14:50:09
]]
_G.classlist['NpcConsts'] = 'NpcConsts'
_G.NpcConsts = {}
NpcConsts.objName = 'NpcConsts'
NpcConsts.Type_Normal = 1; --普通Npc
NpcConsts.Type_Soldier = 2; --战斗Npc
NpcConsts.Type_Storage = 3; --仓库管理员
NpcConsts.Type_Shop = 4; --兑换商人
NpcConsts.Type_Festival = 5; --节日

_G.NPC_QUEST_ICON = {
	[QuestConsts.State_CanAccept] = "quest_npc_can_accept_icon.png",
	[QuestConsts.State_Going] = "quest_npc_un_finish_icon.png",
	[QuestConsts.State_CanFinish] = "quest_npc_finish_icon.png",
}

function NpcConsts:GetNpcHeadQuestIcon(npcQuestState)
	return NPC_QUEST_ICON[npcQuestState]
end