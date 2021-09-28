--FactionInvadeConstant.lua
--/*-----------------------------------------------------------------
--* Module:  FactionInvadeConstant.lua
--* Author:  Chu Zhihua
--* Modified: 2016年5月20日
--* Purpose: Implementation of the class FactionInvadeConstant
-------------------------------------------------------------------*/


FACTION_INVADE_NO_INVADE_FACTION = -54		--没有可以入侵的行会
FACTION_INVADE_FIRE_CLOSE = -55 	--该行会没有开启行会篝火
FACTION_INVADE_NO_FACTION = -56		--该行会不存在
FACTION_INVADE_SAME_FACTION = -57	--不能入侵自己所属行会
FACTION_INVADE_NO_JOIN_FACTION = -58		--请先加入一个行会
FACTION_INVADE_BROADCAST_MSG = -63		--XXX行会入侵了你的行会驻地


--行会入侵虚弱buff
FACTION_INVADE_WEAK_BUFF = {
	[1] = 341,		--行会等级差为1
	[2] = 342,		--行会等级差为2
	[3] = 343,		--行会等级差为3
	[4] = 344,		--行会等级差为4
	[5] = 345,		--行会等级差为5
	[6] = 346,		--行会等级差为6
	[7] = 347,		--行会等级差为7
	[8] = 348,		--行会等级差为8
}