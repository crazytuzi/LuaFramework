--[[
	id:int#61000-61999：主线
62000-62999：支线
63000-63999：日常
ID
	npcID:int#对话npc
	dialog:string#对白
]]

local cfg={
	[61000]={
		id=61000,
		npcID=1101,
		dialog="话说你差不多该用得上仓库了吧。讨伐大妖总得吨上不少武器和物资呢。你去见下暖暖吧"
	},
	[61001]={
		id=61001,
		npcID=1101,
		dialog="再快的马也跑不过时光呐……你怎么在这，啊，我刚在自说自话。你别在意"
	},
	[61002]={
		id=61002,
		npcID=1100,
		dialog="最近的库存有点紧呢。"
	}
}

function cfg:Get( key )
	return cfg[key]
end
return cfg