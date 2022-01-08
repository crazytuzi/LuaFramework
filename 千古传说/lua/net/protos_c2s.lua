local tblProto = {
	[0x440d] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'type', }
		}
	end,
	[0x4410] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5009] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'minePlayerId', 'id', }
		}
	end,
	[0x3500] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'code', }
		}
	end,
	[0x6010] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'instanceId', }
		}
	end,
	[0x3305] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'type', 'rewardId', }
		}
	end,
	[0x1A20] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 's', },
			{'QQ', 'telphone', }
		}
	end,
	[0x5131] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', {true,{'v8', 'v4', }},{true,{'v8', 'v4', }},}},'v4', 's', },
			{{false,{'formation','type', {true,{'role','instanceId', 'position', }},{true,{'assistant','instanceId', 'position', }},}},'battleType', 'params', }
		}
	end,
	[0x1607] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v8', 'v4', 'b', },
			{'bookObjID', 'roleID', 'position', 'mount', }
		}
	end,
	[0x5112] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'useType', }
		}
	end,
	[0x4300] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4428] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'Name', }
		}
	end,
	[0x5301] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'taskid', }
		}
	end,
	[0x1810] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'bulletin', }
		}
	end,
	[0x1806] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'playerId', }
		}
	end,
	[0x1b04] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'playerId', }
		}
	end,
	[0x3230] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x180B] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'gangId', }
		}
	end,
	[0x1509] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'userid', }
		}
	end,
	[0x2301] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4401] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 's', },
			{'name', 'bannerId', }
		}
	end,
	[0x1D42] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1815] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x3002] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5320] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'playerId', }
		}
	end,
	[0x6005] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', },
			{'bible', 'pos', }
		}
	end,
	[0x3211] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'section', }
		}
	end,
	[0x1080] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'instanceId', }
		}
	end,
	[0x1808] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1019] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'tv4', },
			{'equipment', 'lock_attr', }
		}
	end,
	[0x1A00] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'id', 'source', }
		}
	end,
	[0x5321] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1A10] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4601] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x441c] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'zoneId', }
		}
	end,
	[0x5111] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1605] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'objID', }
		}
	end,
	[0x2502] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1911] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'commodityId', }
		}
	end,
	[0x440b] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'guildId', }
		}
	end,
	[0x1400] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4304] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'type', 'playerId', }
		}
	end,
	[0x500F] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'type', 'minePlayerId', }
		}
	end,
	[0x4901] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'sectionId', 'choice', 'employType', }
		}
	end,
	[0x4313] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'friendId', }
		}
	end,
	[0x4413] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'playerId', }
		}
	end,
	[0x0D10] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 's', 'v4', 's', 's', 's', 's', 's', 's', 's', 's', 's', 's', },
			{'accountId', 'validateCode', 'serverId', 'token', 'deviceName', 'osName', 'osVersion', 'channel', 'sdk', 'deviceid', 'sdkVersion', 'MCC', 'IP', }
		}
	end,
	[0x4406] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'guildId', }
		}
	end,
	[0x1061] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'itemId', 'num', }
		}
	end,
	[0x1901] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5907] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5000] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4421] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'zoneId', }
		}
	end,
	[0x1900] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'commodityId', 'num', }
		}
	end,
	[0x5101] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', 'v4', },
			{'roleId', 'operation', 'indexId', }
		}
	end,
	[0x4431] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x6002] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v8', },
			{'roleId', 'bible', }
		}
	end,
	[0x2202] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'type', 'begin', 'end', }
		}
	end,
	[0x441b] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'zoneId', }
		}
	end,
	[0x180C] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'gangName', }
		}
	end,
	[0x1812] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5401] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'roleId', }
		}
	end,
	[0x1201] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'missionId', 'employType', }
		}
	end,
	[0x1011] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v8', },
			{'roleId', 'equipment', }
		}
	end,
	[0x3212] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'section', }
		}
	end,
	[0x5915] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1203] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'missionId', }
		}
	end,
	[0x3203] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'roleId', }
		}
	end,
	[0x1305] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5908] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1602] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'bookpos', }
		}
	end,
	[0x5100] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1304] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'playerId', }
		}
	end,
	[0x1816] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4516] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5900] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4307] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'friendId', }
		}
	end,
	[0x4305] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'friendId', }
		}
	end,
	[0x5161] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'playerId', 'useType', }
		}
	end,
	[0x5914] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x2303] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x0F23] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'replayId', }
		}
	end,
	[0x430d] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'name', }
		}
	end,
	[0x3303] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'type', }
		}
	end,
	[0x5400] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1701] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'mountainId', 'employType', }
		}
	end,
	[0x2051] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x0D01] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 'v4','v4', },
			{'name', 'sex','profession', }
		}
	end,
	[0x3404] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'b', },
			{'martialId', 'autoSynthesis', }
		}
	end,
	[0x1721] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5104] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1811] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4423] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'attributeType', }
		}
	end,
	[0x4920] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'targetId', 'index', }
		}
	end,
	[0x4511] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1205] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'missionId', 'time', }
		}
	end,
	[0x4311] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv4', },
			{'friendIds', }
		}
	end,
	[0x4420] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'zoneId', 'awardId', }
		}
	end,
	[0x4509] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x2601] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'inviteCode', }
		}
	end,
	[0x4312] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4514] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1802] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1800] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1809] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4603] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'tv8', },
			{'type', 'roles', }
		}
	end,
	[0x1081] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'tv4', },
			{'instanceId', 'lock_attr', }
		}
	end,
	[0x1020] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'tv8', {true,{'v4', 'v4', }},},
			{'equipment', 'eat_equipment', {true,{'stuff','id', 'number', }},}
		}
	end,
	[0x3003] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1511] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'userid', }
		}
	end,
	[0x4930] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5200] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x6501] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v8', },
			{'roleId', 'hereditaryId', }
		}
	end,
	[0x6500] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v8', },
			{'roleId', 'exchangeId', }
		}
	end,
	[0x7f30] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'targetId', 'type', }
		}
	end,
	[0x440e] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'num', }
		}
	end,
	[0x5804] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1702] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4200] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'targetId', 'employType', }
		}
	end,
	[0x0F24] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'replayId', }
		}
	end,
	[0x0e24] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4408] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 's', },
			{'type', 'mess', }
		}
	end,
	[0x3405] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', {true,{'v4', 'v4', }},},
			{'roleId', 'position', {true,{'material','id', 'number', }},}
		}
	end,
	[0x5003] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'id', }
		}
	end,
	[0x4512] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', },
			{'roundId', 'index', 'coin', 'betPlayerId', }
		}
	end,
	[0x0e22] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'from', 'target', }
		}
	end,
	[0x5904] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'type', 'goodsId', 'buyNum', }
		}
	end,
	[0x1A04] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5151] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v8', 'v4', }},{true,{'v8', 'v4', }},},
			{{true,{'battleRole','instanceId', 'position', }},{true,{'assistant','instanceId', 'position', }},}
		}
	end,
	[0x4517] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1060] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'fragmentId', }
		}
	end,
	[0x0e23] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'userId', }
		}
	end,
	[0x2001] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x0e21] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v8', 'v4', }},},
			{{false,{'battle','userId', 'index', }},}
		}
	end,
	[0x4923] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'sectionId', }
		}
	end,
	[0x3208] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'section', }
		}
	end,
	[0x4518] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', },
			{'roundId', 'index', 'coin', 'betPlayerId', }
		}
	end,
	[0x5007] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x0e73] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v8', },
			{'playerId', 'instanceId', }
		}
	end,
	[0x0e90] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'soulId', }
		}
	end,
	[0x0e98] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'playerId', }
		}
	end,
	[0x4426] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', 'v8', },
			{'instanceId', 'attributeType', 'inheritanceInstanceIdId', }
		}
	end,
	[0x3300] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'type', }
		}
	end,
	[0x5103] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x500D] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4301] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x0E96] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'id', }
		}
	end,
	[0x1308] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x430E] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'id', }
		}
	end,
	[0x0e70] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'playerId', }
		}
	end,
	[0x0e71] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'playerId', 'type', }
		}
	end,
	[0x4302] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4303] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv4', },
			{'playerIds', }
		}
	end,
	[0x2900] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'employType', }
		}
	end,
	[0x4523] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1050] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'b', },
			{'itemId', 'isTuhao', }
		}
	end,
	[0x3209] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5202] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5707] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1402] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1D11] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x0e11] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'Name', }
		}
	end,
	[0x0e80] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 's', },
			{'beginnersGuide', 'openlist', }
		}
	end,
	[0x0e91] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'iconId', }
		}
	end,
	[0x5001] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'id', }
		}
	end,
	[0x4419] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x2201] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'type', 'begin', 'end', }
		}
	end,
	[0x1700] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x0e99] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'playerId', 'serverId', }
		}
	end,
	[0x2200] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'type', 'index', 'employType', }
		}
	end,
	[0x1405] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1930] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'count', }
		}
	end,
	[0x1601] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'visitall', }
		}
	end,
	[0x2206] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1051] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', 'v4', },
			{'equipment', 'itemId', 'pos', }
		}
	end,
	[0x4701] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5801] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'count', }
		}
	end,
	[0x3200] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x2002] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'taskid', }
		}
	end,
	[0x3210] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'section', }
		}
	end,
	[0x1D10] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'notifyid', }
		}
	end,
	[0x1E02] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'content', }
		}
	end,
	[0x2203] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5160] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'playerId', 'useType', }
		}
	end,
	[0x6303] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'id', }
		}
	end,
	[0x1906] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'commodityId', 'num', }
		}
	end,
	[0x1313] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1b07] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'type', }
		}
	end,
	[0x2101] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'battleType', }
		}
	end,
	[0x6300] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x6301] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'count', }
		}
	end,
	[0x2300] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'id', }
		}
	end,
	[0x1315] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'playerId', }
		}
	end,
	[0x1312] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1314] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1311] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'type', 'begin', 'end', }
		}
	end,
	[0x1310] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'type', 'seatIndex', 'employType', }
		}
	end,
	[0xEE01] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4','v4', 'v4', },
			{'type','goodsId', 'number', }
		}
	end,
	[0x4412] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4424] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v8', 'v4', },
			{'pos', 'instanceId', 'attributeType', }
		}
	end,
	[0x4522] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'hosting', }
		}
	end,
	[0x430c] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'friendId', }
		}
	end,
	[0x1903] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'type', }
		}
	end,
	[0x1606] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'tv8', 'b', },
			{'objID', 'composedBookList', 'composeAll', }
		}
	end,
	[0x2802] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'id', }
		}
	end,
	[0x1D12] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'notifyid', }
		}
	end,
	[0x5800] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'type', }
		}
	end,
	[0x1804] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4404] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'playerId', }
		}
	end,
	[0x5403] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5910] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'eventId', }
		}
	end,
	[0xEE02] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'templateId', }
		}
	end,
	[0x6001] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v8', 'v4', },
			{'roleId', 'bible', 'itemid', }
		}
	end,
	[0xEE00] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'sectionId', }
		}
	end,
	[0x441e] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'zoneId', }
		}
	end,
	[0x2052] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'taskid', }
		}
	end,
	[0x5322] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x7f31] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'targetId', 'type', }
		}
	end,
	[0x3401] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', 'v4', 'b', },
			{'roleId', 'martialId', 'position', 'autoSynthesis', }
		}
	end,
	[0x2060] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5006] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'curCount', }
		}
	end,
	[0x1801] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1905] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'type', 'commodityId', 'num', }
		}
	end,
	[0x4407] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5300] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x2205] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'index', }
		}
	end,
	[0x1F07] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'pos', }
		}
	end,
	[0x1F06] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'skillId', 'pos', }
		}
	end,
	[0x1b05] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x441a] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x2105] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'type', }
		}
	end,
	[0x6006] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'instanceId', }
		}
	end,
	[0x4403] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'playerId', }
		}
	end,
	[0x5402] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'indexId', }
		}
	end,
	[0x2801] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'id', }
		}
	end,
	[0x2701] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x2702] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1902] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'type', }
		}
	end,
	[0x2903] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1065] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'type', }
		}
	end,
	[0x5323] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'inviteCode', }
		}
	end,
	[0x6302] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'curCount', 'count', 'type', }
		}
	end,
	[0x1503] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v8', 'v4', },
			{'fromId', 'targetId', 'type', }
		}
	end,
	[0x5004] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4702] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'type', 'count', }
		}
	end,
	[0x441d] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'zoneId', }
		}
	end,
	[0x1920] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1A05] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1056] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'maxLevel', }
		}
	end,
	[0x5404] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'roleId', }
		}
	end,
	[0x2104] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'battleType', }
		}
	end,
	[0x1910] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'commodityId', }
		}
	end,
	[0x1E01] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', 'b', 'b', 'b', },
			{'isOpenMusic', 'isOpenVolume', 'isOpenChat', 'vipVisible', }
		}
	end,
	[0x1E00] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1505] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'userid', }
		}
	end,
	[0x150B] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5802] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1504] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'tv8', {true,{'v4', 'v4', }},},
			{'userid', 'dogfoodlist', {true,{'roleSoulList','id', 'num', }},}
		}
	end,
	[0x4508] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'type', }
		}
	end,
	[0x1520] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', },
			{'userid', 'spellId', }
		}
	end,
	[0x441f] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'zoneId', 'checkpointId', 'employType', }
		}
	end,
	[0x1817] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x7f21] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'b', }},},
			{{true,{'stateList','functionId', 'newMark', }},}
		}
	end,
	[0x4510] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x180E] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'playerId', }
		}
	end,
	[0x1401] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'attr', }
		}
	end,
	[0x1803] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1510] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv8', {true,{'v4', 'v4', }},'b', },
			{'dogfoodlist', {true,{'roleSoulList','id', 'num', }},'force', }
		}
	end,
	[0x150A] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', },
			{'instanceId', 'pos', }
		}
	end,
	[0x4422] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x3410] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'instanceId', }
		}
	end,
	[0x1303] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x3001] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1013] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'forgingId', }
		}
	end,
	[0x1604] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5601] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', 'v4', 'v4', },
			{'instanceId', 'roleFateId', 'goodsId', 'goodsNum', }
		}
	end,
	[0x440a] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1017] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'itemId', 'num', }
		}
	end,
	[0x7F01] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'type', }
		}
	end,
	[0x1306] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5150] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'startIndex', 'length', }
		}
	end,
	[0x4409] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'type', 'playerId', }
		}
	end,
	[0x4050] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', },
			{'type', 'startIndex', 'length', 'guildZoneType', 'guildZoneId', 'guildCheckpoint', }
		}
	end,
	[0x4060] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'targetId', }
		}
	end,
	[0x2503] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x2501] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5201] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4910] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'length', }
		}
	end,
	[0x1054] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', },
			{'userId', 'ratioItemId', }
		}
	end,
	[0x4704] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4402] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv4', },
			{'guildIds', }
		}
	end,
	[0x0e0c] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'spellId', }
		}
	end,
	[0x5002] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'id', 'friendId', }
		}
	end,
	[0x4902] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4429] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'bannerId', }
		}
	end,
	[0x1B01] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 's', 's', 'v4', },
			{'chatType', 'content', 'playerName', 'playerId', }
		}
	end,
	[0x4900] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x3004] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1720] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'id', 'count', }
		}
	end,
	[0x4425] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'b', },
			{'pos', 'finish', }
		}
	end,
	[0x3000] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1204] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'missionId', }
		}
	end,
	[0x1202] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'chapterId', 'difficulty', 'boxId', }
		}
	end,
	[0x4520] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x500A] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'minePlayerId', 'id', }
		}
	end,
	[0x5324] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x500C] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'playerId', 'type', 'challengeIndex', }
		}
	end,
	[0x5008] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'friendId', 'id', }
		}
	end,
	[0x2103] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'battleType', 'times', }
		}
	end,
	[0x5005] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1F02] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'skillId', }
		}
	end,
	[0x1A06] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'id', }
		}
	end,
	[0x5152] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5803] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'index', }
		}
	end,
	[0x1D41] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'reportId', }
		}
	end,
	[0x6004] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', 'v4', },
			{'bible', 'essential', 'pos', }
		}
	end,
	[0x5704] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5010] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5110] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1D40] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1705] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'id', 'employType', }
		}
	end,
	[0x4011] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5705] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'round', 'index', }
		}
	end,
	[0x6008] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'instanceId', }
		}
	end,
	[0x5130] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v8', 'v4', }},{true,{'v8', 'v4', }},},
			{'type', {true,{'role','instanceId', 'position', }},{true,{'assistant','instanceId', 'position', }},}
		}
	end,
	[0x4515] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1D06] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'unread', }
		}
	end,
	[0x1300] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1D08] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'unread', }
		}
	end,
	[0x4501] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x7FFE] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'errorMessage', }
		}
	end,
	[0x3202] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'fromIndex', 'targetIndex', }
		}
	end,
	[0x5162] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', {true,{'v8', 'v4', }},},
			{'playerId', 'useType', {true,{'formation','instanceId', 'position', }},}
		}
	end,
	[0x1508] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'tv8', {true,{'v4', 'v4', }},},
			{'userid', 'dogfoodlist', {true,{'roleSoulList','id', 'num', }},}
		}
	end,
	[0x3403] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'roleId', }
		}
	end,
	[0x1502] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', },
			{'instanceId', 'pos', }
		}
	end,
	[0x1404] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'startIndex', 'length', }
		}
	end,
	[0x0D00] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 's', 'v4', 's', 's', 's', 's', 's', 's', 's', 's', 's', 's', },
			{'accountId', 'validateCode', 'serverId', 'token', 'deviceName', 'osName', 'osVersion', 'channel', 'sdk', 'deviceid', 'sdkVersion', 'MCC', 'IP', }
		}
	end,
	[0x4504] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1022] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'equipment', }
		}
	end,
	[0x2102] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'battleType', }
		}
	end,
	[0x1082] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'b', 'v8', 'v4', },
			{'equipmentId', 'lock', 'recastEquipmentId', 'index', }
		}
	end,
	[0x4505] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'tv8', },
			{'type', 'formations', }
		}
	end,
	[0x5163] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x0E95] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1053] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'equipment', }
		}
	end,
	[0x1052] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', },
			{'equipment', 'pos', }
		}
	end,
	[0x5901] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'id', }
		}
	end,
	[0x5905] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1C00] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x2800] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x101E] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'roleId', }
		}
	end,
	[0x1C01] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'b', },
			{'cardType', 'free', }
		}
	end,
	[0x1710] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'id', 'times', }
		}
	end,
	[0x430F] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv8', },
			{'ids', }
		}
	end,
	[0x3302] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4502] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x0e34] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1015] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv8', },
			{'equipment', }
		}
	end,
	[0x0F02] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'b', {true,{'b', 'v4', 'v4', 'v4', 'v4', 'b', {true,{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', }},'v4', }},{true,{'v4', 'v4', }},'v4', 'v4', {true,{'v4', 'v4', }},},
			{'fighttype', 'win', {true,{'actionlist','bManualAction', 'roundIndex', 'attackerpos', 'skillid', 'skillLevel', 'bBackAttack', {true,{'targetlist','targetpos', 'effect', 'hurt', 'triggerBufferID', 'triggerBufferLevel', 'passiveEffect', 'passiveEffectValue', 'activeEffect', 'activeEffectValue', }},{true,{'stateList','frompos', 'targetpos', 'stateId', 'skillId', 'skillLevel', 'bufferId', 'bufferLevel', }},'triggerType', }},{true,{'livelist','posindex', 'currhp', }},'angerSelf', 'angerEnemy', {true,{'hurtcountlist','posindex', 'hurt', }},}
		}
	end,
	[0x1014] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'equipment', }
		}
	end,
	[0x3214] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'section', 'index', 'getType', }
		}
	end,
	[0x1090] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v8', },
			{'srcId', 'targetId', }
		}
	end,
	[0x1814] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5153] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'operation', }
		}
	end,
	[0x1603] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'bookpos', }
		}
	end,
	[0x4432] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 's', },
			{'title', 'content', }
		}
	end,
	[0x1030] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'tv4', },
			{'itemId', 'indexId', }
		}
	end,
	[0x3220] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x2305] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'type', 'activityId', }
		}
	end,
	[0x440c] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x2304] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'id', 'index', }
		}
	end,
	[0x440f] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'type', 'playerId', }
		}
	end,
	[0x1807] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'playerId', }
		}
	end,
	[0x3407] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', },
			{'roleId', 'position', }
		}
	end,
	[0x5909] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x6304] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1904] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1021] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1018] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'itemId', }
		}
	end,
	[0x6007] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', }},},
			{{true,{'itemIdNum','itemId', 'number', }},}
		}
	end,
	[0x500E] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'id', }
		}
	end,
	[0x4925] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'index', }
		}
	end,
	[0x7F00] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'type', }
		}
	end,
	[0x3215] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'resType', }
		}
	end,
	[0x2602] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'id', }
		}
	end,
	[0x4405] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1301] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'startIndex', 'length', }
		}
	end,
	[0x1818] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x0E94] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1023] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'tv4', },
			{'equipment', 'lock_attr', }
		}
	end,
	[0x2605] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'inviteCode', }
		}
	end,
	[0x0e20] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v8', 'v4', }},},
			{{true,{'configure','userId', 'index', }},}
		}
	end,
	[0x5701] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1012] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v8', },
			{'roleId', 'equipment', }
		}
	end,
	[0x1403] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'gotype', 'employType', }
		}
	end,
	[0x5700] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'index', }
		}
	end,
	[0x4602] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'index', }
		}
	end,
	[0x3100] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x180A] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4414] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'type', 'guildId', }
		}
	end,
	[0x180D] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'gangId', }
		}
	end,
	[0x4604] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'pos', }
		}
	end,
	[0x1F05] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5164] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5911] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'type', 'playerId', }
		}
	end,
	[0x3213] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'section', 'index', }
		}
	end,
	[0x3207] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1016] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'equipment', }
		}
	end,
	[0x5702] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'index', 'playerId', }
		}
	end,
	[0x1813] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'index', }
		}
	end,
	[0x4513] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5120] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v8', 'v4', },
			{'playerId', 'instanceId', 'useType', }
		}
	end,
	[0x1D07] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'unread', }
		}
	end,
	[0x1D09] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'reportId', }
		}
	end,
	[0x5500] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'roleId', }
		}
	end,
	[0x5703] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4703] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'curCount', 'count', 'type', }
		}
	end,
	[0x1805] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'playerId', }
		}
	end,
	[0x3201] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v8', 'v4', }},},
			{{false,{'station','roleId', 'index', }},}
		}
	end,
	[0x2302] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'id', }
		}
	end,
	[0x4503] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1704] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1302] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4306] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'friendId', }
		}
	end,
	[0x4310] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'friendId', 'roleId', }
		}
	end,
	[0x6600] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', },
			{'roleId', 'acupoint', }
		}
	end,
}
return tblProto