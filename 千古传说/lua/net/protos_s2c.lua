local tblProto = {
	[0x500A] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5103] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', }},},
			{{true,{'info','playerId', 'time', }},}
		}
	end,
	[0x1D32] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 'v4', 'v4', 'v4', 'v4', },
			{'playerName', 'type', 'id', 'num', 'eggType', }
		}
	end,
	[0x0E94] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v8', 'b', }},{true,{'v4', 'v4', }},},
			{{true,{'unlockedlist','id', 'expireTime', 'firstGet', }},{true,{'lockedList','id', 'currentNum', }},}
		}
	end,
	[0x1051] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {false,{'v8', {false,{'v4', 'v4', }},}},},
			{'result', {false,{'gemchanged','userid', {false,{'gem','pos', 'id', }},}},}
		}
	end,
	[0x1507] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', {false,{'v4', 'v4', 'v4', }},},
			{'instanceId', {false,{'acupointInfo','position', 'level', 'breachLevel', }},}
		}
	end,
	[0x1F05] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'skill_point', }
		}
	end,
	[0x4415] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'coin', }
		}
	end,
	[0x5000] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v4', 'v8', 'v8', 'tv8', {false,{'v4', 'v4', 's', 'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v8', 'v4', 's', 'v4', {true,{'v4', 'v4', 'v4', 'v4', {true,{'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},}},{true,{'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},'v4', 'tv4', {true,{'v4', 'v4', }},'v4', 'v4', {true,{'v4', 'v4', 'v4', }},'s', 's', 's', {true,{'v8', 'v4', 'v8', 'v4', 'v4', {true,{'v4', 'v4', }},}},'v4', }},{true,{{false,{'v4', 'v4', }},'b', 'v4', }},'v4', 'v4', }},'v4', 'v4', 's', 'v4', {false,{'v4', 's', 'v4', 'v4', 'v8', 'v4', 'v4', }},'v4', 's', 's', 'v4', 'v4', }},},
			{'leftFreeRefreshTime', 'hireTime', 'brokerageTotal', {true,{'info','type', 'status', 'robStatus', 'startTime', 'endTime', 'formation', {false,{'guardInfo','playerId', 'profession', 'name', 'level', 'vipLevel', 'power', {true,{'warside','id', 'level', 'curexp', 'power', 'attributes', 'warIndex', {true,{'equipment','id', 'level', 'quality', 'refineLevel', {true,{'gem','pos', 'id', }},{true,{'recast','quality', 'ratio', 'index', }},}},{true,{'book','templateId', 'level', 'attribute', }},{true,{'meridians','index', 'level', 'attribute', }},'starlevel', 'fateIds', {true,{'spellId','skillId', 'level', }},'quality', 'martialLevel', {true,{'martial','id', 'position', 'enchantLevel', }},'immune', 'effectActive', 'effectPassive', {true,{'bibleInfo','instanceId', 'id', 'roleId', 'level', 'breachLevel', {true,{'essential','pos', 'id', }},}},'forgingQuality', }},{true,{'spell',{false,{'spellId','skillId', 'level', }},'choice', 'sid', }},'icon', 'headPicFrame', }},'power', 'playerId', 'name', 'profession', {false,{'robInfo','playerId', 'name', 'profession', 'power', 'battleId', 'icon', 'headPicFrame', }},'id', 'robResource', 'rewardResource', 'icon', 'headPicFrame', }},}
		}
	end,
	[0x2200] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'win', }
		}
	end,
	[0x1924] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v8', 'v8', 'v4', 'v4', 's', 'v4', 'v4', 'v4', 'v4', 'v4', }},'v4', },
			{{true,{'giftList','id', 'type', 'resType', 'resId', 'number', 'consumeType', 'consumeId', 'consumeNumber', 'isLimited', 'consumeAdd', 'needVipLevel', 'beginTime', 'endTime', 'maxType', 'maxNum', 'vipMaxNumMap', 'oldPrice', 'limitType', 'isHot', 'timeType', 'orderNo', }},'type', }
		}
	end,
	[0x0e30] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v8', 'v4', 'v4', },
			{'chatFree', 'chapterSweepFree', 'lastUpdate', 'crossFreeChat', 'vipDeclaration', }
		}
	end,
	[0x2600] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'myCode', }
		}
	end,
	[0x3404] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'martialId', }
		}
	end,
	[0x1920] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'consume', 'coin', 'mutil', }
		}
	end,
	[0x1042] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v8', 'v8', },
			{'roleId', 'equipment', 'drop', }
		}
	end,
	[0x4430] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x0e72] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', {true,{'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},},
			{'id', 'level', 'quality', 'refineLevel', {true,{'gem','pos', 'id', }},{true,{'recast','quality', 'ratio', 'index', }},}
		}
	end,
	[0x5162] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4902] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v4', 'v4', 'tv4', 'v4', 'v4', }},{true,{'v4', 'tv4', 'v4', 'b', }},'v4', 'v4', 'v4', 'v4', 'v4', 'b', },
			{'currentId', {true,{'gameLevel','sectionId', 'formationId', 'options', 'choice', 'score', }},{true,{'attribute','index', 'option', 'choice', 'skip', }},'maxPassCount', 'maxSweepCount', 'tokens', 'remainResetCount', 'chestGotMark', 'hasNotPass', }
		}
	end,
	[0x1052] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v8', 'v4', },
			{'result', 'userid', 'pos', }
		}
	end,
	[0x430E] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5404] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', {true,{'v4', 'v4', 'v4', 'v4', }},},
			{'roleId', 'rewardDay', {true,{'info','roleId', 'roleNum', 'roleSycee', 'isGetReward', }},}
		}
	end,
	[0x430F] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1F03] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', }},'v4', },
			{{true,{'skill_list','skillId', 'level', }},'skill_point', }
		}
	end,
	[0x1809] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'isSuccess', }
		}
	end,
	[0x1F04] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'skill_point', }
		}
	end,
	[0x1910] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'commodityId', }
		}
	end,
	[0x150B] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'baseRate', 'extraRate', 'payCount', }
		}
	end,
	[0x6010] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v8', 'v4', },
			{'result', 'instanceId', 'level', }
		}
	end,
	[0x5152] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v8', 'v4', }},{true,{'v8', 'v4', }},'v8', 'v4', 'v4', },
			{{true,{'battleRole','instanceId', 'position', }},{true,{'assistant','instanceId', 'position', }},'startTime', 'coin', 'employCount', }
		}
	end,
	[0x6004] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v8', 'v8', 'v4', 'v4', },
			{'result', 'roleId', 'essential', 'itemId', 'pos', }
		}
	end,
	[0x1D63] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'messageId', }
		}
	end,
	[0x1402] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', },
			{'hp', 'neigong', 'waigong', 'neifang', 'waifang', 'hurt', }
		}
	end,
	[0x3401] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', 'v4', },
			{'roleId', 'martialId', 'position', }
		}
	end,
	[0x7F01] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', {true,{'v4', 'v4', 'v4', }},}},},
			{{false,{'reward','type', {true,{'items','type', 'number', 'itemId', }},}},}
		}
	end,
	[0x5001] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x2102] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', }},},
			{{true,{'records','type', 'maxValue', 'todayUse', 'currentValue', 'todayBuyTime', 'cooldownRemain', 'waitTimeRemain', 'todayResetWait', }},}
		}
	end,
	[0x4508] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x3305] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'type', 'rewardId', }
		}
	end,
	[0x4604] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5907] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', },
			{'massacre', 'coin', 'experience', 'ranking', }
		}
	end,
	[0x5912] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'result', 'playerId', 'type', }
		}
	end,
	[0x5002] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x2702] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', }},},
			{{true,{'itemlist','type', 'number', 'itemId', }},}
		}
	end,
	[0x1B02] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', 'v4', 'v4', 's', 'v4', 'v4', 'v8', 'v4', 's', 'v4', 'tv4', 'v4', 'v4', 'v4', 'v4', 'v4', 's', }},},
			{{true,{'chat','chatType', 'content', 'playerId', 'roleId', 'quality', 'name', 'vipLevel', 'level', 'timestamp', 'guildId', 'guildName', 'competence', 'invitationGuilds', 'titleType', 'guideType', 'icon', 'headPicFrame', 'serverId', 'serverName', }},}
		}
	end,
	[0x1520] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', 'v4', 'v4', },
			{'userid', 'oldLevel', 'newLevel', 'skillId', }
		}
	end,
	[0x7F10] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v8', }},},
			{{true,{'resource','resource', 'num', }},}
		}
	end,
	[0x1700] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'curId', }
		}
	end,
	[0x3212] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', {false,{'v4', 'b', 'v4', 'v4', 'v4', }},}},},
			{{false,{'updateInfo','boxIndex', {false,{'prize','index', 'bIsget', 'type', 'itemId', 'number', }},}},}
		}
	end,
	[0x5802] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x3221] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4080] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 's', 'v4', 's', 'v4', 's', 'v4', 'b', }},},
			{{true,{'rankInfo','guildId', 'exp', 'name', 'memberCount', 'presidentName', 'power', 'declaration', 'level', 'apply', }},}
		}
	end,
	[0x0e98] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', 's', 'v4', 'v4', 'v8', 'v4', 'v4', 'b', 'v4', 's', 'v4', 'v4', 'v4', }},},
			{{false,{'info','playerId', 'name', 'vip', 'power', 'lastLoginTime', 'profession', 'level', 'online', 'guildId', 'guildName', 'minePower', 'icon', 'headPicFrame', }},}
		}
	end,
	[0x1b05] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv4', },
			{'playerId', }
		}
	end,
	[0x1D50] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 'v4', 'v4', 'v4', },
			{'playerName', 'templateId', 'number', 'operationType', }
		}
	end,
	[0x3208] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'s', 'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', }},'v4', 'v4', 'v4', }},},
			{{true,{'enemyList','name', 'section', 'anger', 'power', {true,{'roles','profession', 'lv', 'index', 'maxHp', 'currHp', 'quality', 'forgingQuality', }},'icon', 'headPicFrame', 'playerId', }},}
		}
	end,
	[0x3211] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v4', 'v4', 'v4', }},'v4', },
			{'section', {true,{'items','rewardId', 'getType', 'status', }},'status', }
		}
	end,
	[0x5900] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', 'v4', 'v4', 'v4', 's', 'v4', 'v4', 'v4', 'v4', {true,{'v8', 'v4', 'v4', 'v4', }},{true,{'v8', 'v4', 'v4', 'v4', }},'v4', }},'v4', 'v8', 'v8', 'v4', },
			{{true,{'opponent','id', 'name', 'level', 'power', 'icon', 'headPicFrame', 'guildName', 'massacreValue', 'rewardMassacre', 'rewardCoin', 'rewardExperience', {true,{'formation','instanceId', 'position', 'templateId', 'quality', }},{true,{'secondFormation','instanceId', 'position', 'templateId', 'quality', }},'secondPower', }},'eventId', 'refresheventTime', 'refreshOpponentTime', 'experience', }
		}
	end,
	[0x5164] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v8', 'v8', }},},
			{{true,{'count','playerId', 'todayCount', 'totalCount', 'createTime', 'lastUpdate', }},}
		}
	end,
	[0x4002] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 's', 'v4', 'v4', 'v4', 'v4', {true,{'v8', 'v4', 'v4', }},'v4', 'v4', }},'v4', 'v4', 'v4', 'v4', },
			{{true,{'rankInfo','ranking', 'playerId', 'value', 'name', 'level', 'vipLevel', 'goodNum', 'power', {true,{'formation','instanceId', 'position', 'templateId', }},'profession', 'headPicFrame', }},'lastValue', 'myRanking', 'myBestValue', 'praiseCount', }
		}
	end,
	[0x1D05] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'fightNotifyNum', 'socialNotifyNum', 'systemNotifyNum', }
		}
	end,
	[0x0F02] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {false,{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},{true,{'v4', 'v4', }},'v4', 'v4', {false,{'v4', 'v4', 'v4', 'v4', 'v4', 'tv8', 'tv8', 'v4', 'v4', 'v4', 'v4', }},},
			{'result', {false,{'teamexp','typeid', 'oldExp', 'oldLev', 'currExp', 'currLev', 'addExp', }},{true,{'explist','typeid', 'oldExp', 'oldLev', 'currExp', 'currLev', 'addExp', }},{true,{'itemlist','type', 'itemid', 'num', }},{true,{'reslist','type', 'num', }},'rank', 'climblev', {false,{'championsInfo','atkWinStreak', 'atkMaxWinStreak', 'defWinStreak', 'defMaxWinSteak', 'score', 'atkFormation', 'defFormation', 'atkWinCount', 'atkLostCount', 'defWinCount', 'defLostCount', }},}
		}
	end,
	[0x6002] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v8', },
			{'result', 'drop', }
		}
	end,
	[0x0d00] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'b', },
			{'statusCode', 'empty', }
		}
	end,
	[0x4513] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv4', 's', },
			{'id', 'name', }
		}
	end,
	[0x4602] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x3210] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'s', 'v4', 'v4', 'v4', }},},
			{'currSection', {true,{'enemy','name', 'section', 'star', 'roleId', }},}
		}
	end,
	[0x440b] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1a00] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 's', 'v4', 's', },
			{'id', 'billNo', 'price', 'goodName', }
		}
	end,
	[0x4603] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1604] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v8', 'v4', 'v4', 'v4', 'b', 'v8', 'v8', 'v8', }},},
			{{true,{'booklist','objID', 'resID', 'level', 'exp', 'lock', 'roleID', 'position', 'attrAdd', }},}
		}
	end,
	[0x1D21] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', }},},
			{{true,{'mail','id', 'status', }},}
		}
	end,
	[0x5800] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'type', }
		}
	end,
	[0x180E] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'isSuccess', }
		}
	end,
	[0x5011] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v8', }},},
			{{true,{'remind','status', 'endTime', }},}
		}
	end,
	[0x4310] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x6005] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v8', 'v4', },
			{'result', 'bible', 'pos', }
		}
	end,
	[0x1D0B] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 's', 'v4', 'v4', }},},
			{{true,{'rankingInfo','playerId', 'displayId', 'name', 'level', 'vipLevel', }},}
		}
	end,
	[0x1F06] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', }},},
			{{true,{'useSkill_list','skillId', 'pos', }},}
		}
	end,
	[0x1704] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'b', 'v8', }},},
			{{true,{'carbonList','index', 'leftTimes', 'isEnable', 'coolTime', }},}
		}
	end,
	[0x0e20] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v8', },
			{'fromPos', 'toPos', 'userId', }
		}
	end,
	[0x2601] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x2802] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'id', }
		}
	end,
	[0x0e61] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'userId', }
		}
	end,
	[0x6304] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', 's', 'v4', 's', }},{true,{'v4', 's', 'v4', 's', }},},
			{{false,{'own','rank', 'name', 'score', 'serverName', }},{true,{'list','rank', 'name', 'score', 'serverName', }},}
		}
	end,
	[0x4901] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'score', 'nextId', 'tokens', }
		}
	end,
	[0x0e42] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'resVersion', }
		}
	end,
	[0x1D0F] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 's', },
			{'playerId', 'name', }
		}
	end,
	[0x1A20] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 's', },
			{'QQ', 'telphone', }
		}
	end,
	[0x0e9a] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', {true,{'v4', 'v4', 'v8', 'v4', 's', 'v4', {true,{'v4', 'v4', 'v4', 'v4', {true,{'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},}},{true,{'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},'v4', 'tv4', {true,{'v4', 'v4', }},'v4', 'v4', {true,{'v4', 'v4', 'v4', }},'s', 's', 's', {true,{'v8', 'v4', 'v8', 'v4', 'v4', {true,{'v4', 'v4', }},}},'v4', }},},
			{'userid', {true,{'roleDetails','id', 'level', 'curexp', 'power', 'attributes', 'warIndex', {true,{'equipment','id', 'level', 'quality', 'refineLevel', {true,{'gem','pos', 'id', }},{true,{'recast','quality', 'ratio', 'index', }},}},{true,{'book','templateId', 'level', 'attribute', }},{true,{'meridians','index', 'level', 'attribute', }},'starlevel', 'fateIds', {true,{'spellId','skillId', 'level', }},'quality', 'martialLevel', {true,{'martial','id', 'position', 'enchantLevel', }},'immune', 'effectActive', 'effectPassive', {true,{'bibleInfo','instanceId', 'id', 'roleId', 'level', 'breachLevel', {true,{'essential','pos', 'id', }},}},'forgingQuality', }},}
		}
	end,
	[0x2206] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v4', }},},
			{{true,{'boxContent','index', 'resType', 'resId', 'number', }},}
		}
	end,
	[0x5010] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv4', },
			{'guardPlayerIds', }
		}
	end,
	[0x1921] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'count', }
		}
	end,
	[0x5904] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'result', }
		}
	end,
	[0x1011] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'statusCode', }
		}
	end,
	[0x0d01] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'statusCode', }
		}
	end,
	[0x1a12] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', }},},
			{{true,{'list','index', 'multiple', }},}
		}
	end,
	[0x5304] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'taskid', 'currstep', }
		}
	end,
	[0x0d11] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'resVersion', }
		}
	end,
	[0x2604] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'b', 'b', 'v4', 's', },
			{'myCode', 'invited', 'invitedAward', 'inviteCount', 'getRewardRecord', }
		}
	end,
	[0x5403] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'success', }
		}
	end,
	[0x1b07] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', 'v4', 'v4', 's', 'v4', 'v4', 'v8', 'v4', 's', 'v4', 'tv4', 'v4', 'v4', 'v4', 'v4', 'v4', 's', }},},
			{{true,{'infos','chatType', 'content', 'playerId', 'roleId', 'quality', 'name', 'vipLevel', 'level', 'timestamp', 'guildId', 'guildName', 'competence', 'invitationGuilds', 'titleType', 'guideType', 'icon', 'headPicFrame', 'serverId', 'serverName', }},}
		}
	end,
	[0x5005] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x2300] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 's', 's', 'v4', 's', 'v4', 'b', 's', 's', 's', 's', 's', 'v4', 'b', },
			{'id', 'name', 'title', 'type', 'resetCron', 'status', 'history', 'icon', 'details', 'reward', 'beginTime', 'endTime', 'showWeight', 'crossServer', }
		}
	end,
	[0x1801] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 's', 'v4', 'v4', 's', 'v4', 's', 's', },
			{'gangId', 'gangName', 'memberNum', 'masterId', 'masterName', 'myGangRole', 'bulletin', 'buffStr', }
		}
	end,
	[0x5402] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v4', }},'v4', },
			{{true,{'info','roleId', 'roleNum', 'roleSycee', 'isGetReward', }},'indexId', }
		}
	end,
	[0x441c] = function()
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
			{'useType', 'fromId', }
		}
	end,
	[0x5500] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v8', 'v4', 'v4', 'v8', 'v4', 'v4', 'v4', {true,{'v4', 'v4', }},{true,{'v8', 'v4', 'v4', 'v4', 's', 's', 'v4', 'v4', {true,{'v4', 'v4', }},'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v4', }},}},{true,{'v8', 'v4', 'v8', 'v4', 'v4', {true,{'v4', 'v4', }},}},}},},
			{{false,{'info','userid', 'id', 'level', 'curexp', 'quality', 'starlevel', 'starExp', {true,{'spellId','skillId', 'level', }},{true,{'equiplist','userid', 'id', 'level', 'quality', 'base_attr', 'extra_attr', 'grow', 'holeNum', {true,{'gem','pos', 'id', }},'star', 'starFailFix', 'refineLevel', {true,{'recast','quality', 'ratio', 'index', }},}},{true,{'bibleInfo','instanceId', 'id', 'roleId', 'level', 'breachLevel', {true,{'essential','pos', 'id', }},}},}},}
		}
	end,
	[0x1606] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v8', 'v4', 'v4', 'v4', 'b', 'v8', 'v8', 'v8', }},},
			{{true,{'booklist','objID', 'resID', 'level', 'exp', 'lock', 'roleID', 'position', 'attrAdd', }},}
		}
	end,
	[0x4512] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x3207] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'s', 'v4', 'v4', 'v4', }},},
			{'currSection', {true,{'allEnemys','name', 'section', 'star', 'roleId', }},}
		}
	end,
	[0x2303] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 's', 's', 's', 'v4', }},},
			{{true,{'progress','id', 'progress', 'extend', 'got', 'lastUpdate', 'resetRemaining', }},}
		}
	end,
	[0x1F02] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1E01] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'isSuccess', }
		}
	end,
	[0x5705] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', {true,{'v4', 'v4', 's', 'v4', 'v4', }},'v4', }},{true,{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', }},},
			{{true,{'atkGuildTeamInfos','eliteId', {true,{'battleInfo','playerId', 'power', 'name', 'profession', 'headPicFrame', }},'id', }},{true,{'replays','roundId', 'index', 'scene', 'team', 'atkPlayerId', 'defPlayerId', 'winPlayerId', 'replayId', }},}
		}
	end,
	[0x0e0f] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', {true,{'v4', 'v4', }},{true,{'v4', 'v4', }},},
			{'userId', {true,{'spellId','skillId', 'level', }},{true,{'allSpellId','skillId', 'level', }},}
		}
	end,
	[0x1812] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'isSuccess', }
		}
	end,
	[0x7f31] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1802] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', 'v4', },
			{'gangLevel', 'gangExp', 'myAllContribution', 'myTodayContribution', 'gangMoney', }
		}
	end,
	[0x4519] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'state', }
		}
	end,
	[0x6201] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v4', 'b', {true,{'s', 'v4', 'v4', 'v4', }},}},},
			{{true,{'list','roleId', 'x', 'y', 'scale', 'flipX', {true,{'msg','txt', 'delayF', 'delayB', 'index', }},}},}
		}
	end,
	[0x3300] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 's', 's', },
			{'type', 'status', 'startTime', 'endTime', }
		}
	end,
	[0x1023] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 's', },
			{'equipment', 'extra_attr', }
		}
	end,
	[0x1F01] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', }},{true,{'v4', 'v4', }},'v4', },
			{{true,{'skill_list','skillId', 'level', }},{true,{'useSkill_list','skillId', 'pos', }},'skill_point', }
		}
	end,
	[0x5906] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1D61] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', 'v8', 'v8', 'v4', 'v4', }},},
			{{true,{'msg','messageId', 'content', 'intervalTime', 'beginTime', 'endTime', 'repeatTime', 'priority', }},}
		}
	end,
	[0x4412] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', 'v4', 'v4', 'v4', 's', 'v8', 'v4', 'v4', 'v4', }},},
			{{true,{'infos','playerId', 'name', 'vip', 'profession', 'level', 'guildId', 'guildName', 'createTime', 'quality', 'icon', 'headPicFrame', }},}
		}
	end,
	[0x2105] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'type', }
		}
	end,
	[0x0F04] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v4', 'v4', 'v4', 'tv4', {false,{'v4', 'v4', }},{true,{'v4', 'v4', }},'s', 's', 's', 's', }},'v4', }},{false,{'v4', 'b', {true,{'b', 'v4', 'v4', 'v4', 'v4', 'b', {true,{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', }},'v4', }},{true,{'v4', 'v4', }},'v4', 'v4', {true,{'v4', 'v4', }},}},'v4', },
			{{false,{'beginInfo','fighttype', 'angerSelf', 'angerEnemy', {true,{'rolelist','typeid', 'roleId', 'maxhp', 'posindex', 'level', 'attr', {false,{'spellId','skillId', 'level', }},{true,{'passiveskill','skillId', 'level', }},'name', 'immune', 'effectActive', 'effectPassive', }},'index', }},{false,{'fightData','fighttype', 'win', {true,{'actionlist','bManualAction', 'roundIndex', 'attackerpos', 'skillid', 'skillLevel', 'bBackAttack', {true,{'targetlist','targetpos', 'effect', 'hurt', 'triggerBufferID', 'triggerBufferLevel', 'passiveEffect', 'passiveEffectValue', 'activeEffect', 'activeEffectValue', }},{true,{'stateList','frompos', 'targetpos', 'stateId', 'skillId', 'skillLevel', 'bufferId', 'bufferLevel', }},'triggerType', }},{true,{'livelist','posindex', 'currhp', }},'angerSelf', 'angerEnemy', {true,{'hurtcountlist','posindex', 'hurt', }},}},'rank', }
		}
	end,
	[0x2501] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', {true,{'v4', 'v4', }},},
			{'lastTime', {true,{'info','type', 'status', }},}
		}
	end,
	[0x5201] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5324] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1055] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'max', }
		}
	end,
	[0x4404] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'playerId', }
		}
	end,
	[0x1203] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'missionId', }
		}
	end,
	[0x440a] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', 'v4', 'v8', 'v4', 'v4', 'v8', 'v4', 'v4', }},},
			{{true,{'list','playerId', 'name', 'vip', 'power', 'lastLoginTime', 'profession', 'level', 'applyTime', 'icon', 'headPicFrame', }},}
		}
	end,
	[0x1D30] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 's', },
			{'playerId', 'name', }
		}
	end,
	[0x5121] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v8', 'v4', },
			{'playerId', 'instanceId', 'useType', }
		}
	end,
	[0x1019] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 's', },
			{'equipment', 'extra_attr', }
		}
	end,
	[0x1b06] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'playerId', }
		}
	end,
	[0x0e93] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv4', },
			{'newIcon', }
		}
	end,
	[0x4401] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', 'v4', 's', 'v4', 's', 'v4', 's', 'v4', 's', 'v4', 'v4', 'v4', 'v8', 'b', 's', }},},
			{{false,{'info','guildId', 'exp', 'name', 'memberCount', 'presidentName', 'power', 'declaration', 'level', 'notice', 'boom', 'state', 'operateId', 'operateTime', 'apply', 'bannerId', }},}
		}
	end,
	[0x4410] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5913] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'type', }
		}
	end,
	[0x1721] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', }},},
			{{true,{'info','id', 'star', }},}
		}
	end,
	[0x3302] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 's', 'v4', 'v4', },
			{'logonDayCount', 'logonReward', 'onlineRewardCount', 'onlineRewardLastGetTime', 'onlineRewardRemainingTimes', 'teamLevelReward', }
		}
	end,
	[0x5150] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 's', {true,{'v8', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', }},'v4', {true,{'v4', 'v4', 'v8', 'v4', }},}},},
			{{true,{'outline','playerId', 'power', 'playerName', {true,{'battleRole','instanceId', 'roleId', 'level', 'starLevel', 'martialLevel', 'position', 'quality', 'forgingQuality', }},'relation', {true,{'assistant','position', 'roleId', 'instanceId', 'quality', }},}},}
		}
	end,
	[0x4517] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 's', 's', 'v4', 'v4', 'v4', 'v4', 'tv8', 'tv8', 'v4', 'v4', 'v4', 'v4', 's', 's', }},},
			{{true,{'infos','round', 'index', 'atkPlayerId', 'defPlayerId', 'winPlayerId', 'replayId', 'atkPlayerName', 'defPlayerName', 'betPlayerId', 'coin', 'atkPower', 'defPower', 'atkFormation', 'defFormation', 'atkIcon', 'defIcon', 'atkHeadPicFrame', 'defHeadPicFrame', 'atkServerName', 'defServerName', }},}
		}
	end,
	[0x3405] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', {false,{'v4', 'v4', 'v4', 'v4', }},},
			{'roleId', {false,{'martial','id', 'position', 'enchantLevel', 'enchantProgress', }},}
		}
	end,
	[0x4702] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v4', 'v4', 'v4', }},},
			{'type', {true,{'rewardList','resType', 'resId', 'number', }},}
		}
	end,
	[0x4309] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{{false,{'v4', 's', 'v4', 'v4', 'v8', 'v4', 'v4', 'b', 'v4', 's', 'v4', 'v4', 'v4', }},'b', 'b', }},},
			{{false,{'friend',{false,{'info','playerId', 'name', 'vip', 'power', 'lastLoginTime', 'profession', 'level', 'online', 'guildId', 'guildName', 'minePower', 'icon', 'headPicFrame', }},'give', 'assistantGive', }},}
		}
	end,
	[0x0e0e] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', {true,{'v4', 'v4', }},{true,{'v4', 'v4', }},},
			{'userId', {true,{'spellId','skillId', 'level', }},{true,{'allSpellId','skillId', 'level', }},}
		}
	end,
	[0x1803] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'b', }},},
			{{true,{'memberList','playerId', 'playerName', 'playerLevel', 'generalId', 'fightPower', 'allContribution', 'todayContribution', 'role', 'isOnline', }},}
		}
	end,
	[0x0e32] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v8', }},},
			{{true,{'list','type', 'multiple', 'endTime', }},}
		}
	end,
	[0x3406] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v8', 'v4', {true,{'v4', 'v4', 'v4', 'v4', }},}},},
			{{true,{'roleMartial','roleId', 'martialLevel', {true,{'martialInfo','id', 'position', 'enchantLevel', 'enchantProgress', }},}},}
		}
	end,
	[0x1017] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'result', }
		}
	end,
	[0x1311] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v4', {false,{'v4', 'v4', 'v4','s', 'v4', 'v4', }},}},},
			{'level', {true,{'rolelist','rank', {false,{'role','playerId', 'profession', 'sex','name', 'level', 'power', }},}},}
		}
	end,
	[0x5707] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v8', 'v4', 's', 's', 'tv4', 'v4', 's', },
			{'maxGuildLevel', 'guildSize', 'openTime', 'guildId', 'guildName', 'bannerId', 'professions', 'myRank', 'names', }
		}
	end,
	[0x1807] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'isSuccess', }
		}
	end,
	[0x5600] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v8', 'v4', 'v8', 'b', }},},
			{{true,{'list','instanceId', 'roleFateId', 'endTime', 'forever', }},}
		}
	end,
	[0x4921] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'tv4', 'v4', 'b', }},},
			{{true,{'attribute','index', 'option', 'choice', 'skip', }},}
		}
	end,
	[0x4518] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x3403] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', },
			{'roleId', 'martialLevel', }
		}
	end,
	[0x1602] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'bookpos', }
		}
	end,
	[0x430d] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', 's', 'v4', 'v4', 'v8', 'v4', 'v4', 'b', 'v4', 's', 'v4', 'v4', 'v4', }},'b', },
			{{false,{'info','playerId', 'name', 'vip', 'power', 'lastLoginTime', 'profession', 'level', 'online', 'guildId', 'guildName', 'minePower', 'icon', 'headPicFrame', }},'apply', }
		}
	end,
	[0x4428] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'name', }
		}
	end,
	[0x1D31] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 's', 'v8', },
			{'playerId', 'name', 'time', }
		}
	end,
	[0x2005] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'taskid', 'currstep', }
		}
	end,
	[0x0e71] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 's', 'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v8', 'v4', 's', 'v4', {true,{'v4', 'v4', 'v4', 'v4', {true,{'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},}},{true,{'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},'v4', 'tv4', {true,{'v4', 'v4', }},'v4', 'v4', {true,{'v4', 'v4', 'v4', }},'s', 's', 's', {true,{'v8', 'v4', 'v8', 'v4', 'v4', {true,{'v4', 'v4', }},}},'v4', }},{true,{{false,{'v4', 'v4', }},'b', 'v4', }},'v4', 'v4', },
			{'playerId', 'profession', 'name', 'level', 'vipLevel', 'power', {true,{'warside','id', 'level', 'curexp', 'power', 'attributes', 'warIndex', {true,{'equipment','id', 'level', 'quality', 'refineLevel', {true,{'gem','pos', 'id', }},{true,{'recast','quality', 'ratio', 'index', }},}},{true,{'book','templateId', 'level', 'attribute', }},{true,{'meridians','index', 'level', 'attribute', }},'starlevel', 'fateIds', {true,{'spellId','skillId', 'level', }},'quality', 'martialLevel', {true,{'martial','id', 'position', 'enchantLevel', }},'immune', 'effectActive', 'effectPassive', {true,{'bibleInfo','instanceId', 'id', 'roleId', 'level', 'breachLevel', {true,{'essential','pos', 'id', }},}},'forgingQuality', }},{true,{'spell',{false,{'spellId','skillId', 'level', }},'choice', 'sid', }},'icon', 'headPicFrame', }
		}
	end,
	[0x4509] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', }},'v4', },
			{{true,{'infos','playerId', 'name', 'score', }},'myRank', }
		}
	end,
	[0x1D01] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 'v4', 'v4', 'v4', },
			{'playerName', 'equipId', 'number', 'operationType', }
		}
	end,
	[0x2603] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', 'v4', 's', },
			{'invited', 'inviteCount', 'getRewardRecord', }
		}
	end,
	[0x4312] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', 's', }},'s', 's', 's', 's', 'v4', },
			{{true,{'infos','friendId', 'provideRoles', 'demandRole', 'roleUseCount', }},'usePlayers', 'assistantPlayers', 'roleUseCount', 'provideRoles', 'demandRole', }
		}
	end,
	[0x0E96] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'code', }
		}
	end,
	[0x1702] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'curId', }
		}
	end,
	[0x5007] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v8', 'v8', 'tv8', {false,{'v4', 'v4', 's', 'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v8', 'v4', 's', 'v4', {true,{'v4', 'v4', 'v4', 'v4', {true,{'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},}},{true,{'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},'v4', 'tv4', {true,{'v4', 'v4', }},'v4', 'v4', {true,{'v4', 'v4', 'v4', }},'s', 's', 's', {true,{'v8', 'v4', 'v8', 'v4', 'v4', {true,{'v4', 'v4', }},}},'v4', }},{true,{{false,{'v4', 'v4', }},'b', 'v4', }},'v4', 'v4', }},'v4', 'v4', 's', 'v4', {false,{'v4', 's', 'v4', 'v4', 'v8', 'v4', 'v4', }},'v4', 's', 's', 'v4', 'v4', }},},
			{{true,{'info','type', 'status', 'robStatus', 'startTime', 'endTime', 'formation', {false,{'guardInfo','playerId', 'profession', 'name', 'level', 'vipLevel', 'power', {true,{'warside','id', 'level', 'curexp', 'power', 'attributes', 'warIndex', {true,{'equipment','id', 'level', 'quality', 'refineLevel', {true,{'gem','pos', 'id', }},{true,{'recast','quality', 'ratio', 'index', }},}},{true,{'book','templateId', 'level', 'attribute', }},{true,{'meridians','index', 'level', 'attribute', }},'starlevel', 'fateIds', {true,{'spellId','skillId', 'level', }},'quality', 'martialLevel', {true,{'martial','id', 'position', 'enchantLevel', }},'immune', 'effectActive', 'effectPassive', {true,{'bibleInfo','instanceId', 'id', 'roleId', 'level', 'breachLevel', {true,{'essential','pos', 'id', }},}},'forgingQuality', }},{true,{'spell',{false,{'spellId','skillId', 'level', }},'choice', 'sid', }},'icon', 'headPicFrame', }},'power', 'playerId', 'name', 'profession', {false,{'robInfo','playerId', 'name', 'profession', 'power', 'battleId', 'icon', 'headPicFrame', }},'id', 'robResource', 'rewardResource', 'icon', 'headPicFrame', }},}
		}
	end,
	[0x4423] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1601] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv4', 'v4', 'v4', },
			{'booklist', 'nextMaster', 'callMasterCount', }
		}
	end,
	[0x1313] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', {true,{'v4', 'v4', 'v4', }},},
			{'result', {true,{'items','type', 'number', 'itemId', }},}
		}
	end,
	[0x1080] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', },
			{'instanceId', 'refineLevel', }
		}
	end,
	[0x4414] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4417] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 's', 'v4', 'v4', 'v4', 'v4', 's', 'v8', 'v4', 'v4', 'v4', },
			{'playerId', 'name', 'vip', 'profession', 'level', 'guildId', 'guildName', 'createTime', 'quality', 'icon', 'headPicFrame', }
		}
	end,
	[0x1300] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 's', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'tv8', }},},
			{{true,{'playerList','rank', 'playerId', 'playerName', 'playerLevel', 'generalId', 'fightPower', 'challengeTotalCount', 'challengeWinCount', 'vipLevel', 'prevRank', 'bestRank', 'totalScore', 'activeChallenge', 'activeWin', 'continuityWin', 'maxContinuityWin', 'formation', }},}
		}
	end,
	[0x5706] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'state', }
		}
	end,
	[0x1056] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v4', 'v4', }},},
			{'maxLevel', {true,{'change','id', 'changeNum', }},}
		}
	end,
	[0x4930] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'sweepCount', }
		}
	end,
	[0x3002] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4416] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'type', 'guildId', }
		}
	end,
	[0x1D09] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'content', }
		}
	end,
	[0x1501] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', {true,{'v4', 'v4', 'v4', }},},
			{'instanceId', {true,{'acupointList','position', 'level', 'breachLevel', }},}
		}
	end,
	[0x1D07] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v8', 's', 'v4', 'v4', 'v4', 'b', }},},
			{{true,{'ganglist','time', 'playerName', 'playerLev', 'gangName', 'gangId', 'apply', }},}
		}
	end,
	[0x0F00] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v4', 'v4', 'v4', 'tv4', {false,{'v4', 'v4', }},{true,{'v4', 'v4', }},'s', 's', 's', 's', }},'v4', },
			{'fighttype', 'angerSelf', 'angerEnemy', {true,{'rolelist','typeid', 'roleId', 'maxhp', 'posindex', 'level', 'attr', {false,{'spellId','skillId', 'level', }},{true,{'passiveskill','skillId', 'level', }},'name', 'immune', 'effectActive', 'effectPassive', }},'index', }
		}
	end,
	[0x1200] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4','v4', }},'tv4', 'v4', 'v4', },
			{{true,{'missionlist','missionId', 'challengeCount', 'starLevel','resetCount', }},'openBoxIdList', 'useQuickPassTimes', 'useResetTimes', }
		}
	end,
	[0x3500] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'code', }
		}
	end,
	[0x0e27] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'capacity', }
		}
	end,
	[0x3215] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'coinInspireCount', 'sysceeInspireCount', }
		}
	end,
	[0x1813] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', {false,{'v4', 'v4', 'v4', }},},
			{'isSuccess', {false,{'item','type', 'number', 'itemId', }},}
		}
	end,
	[0x4082] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {false,{'v4', 's', 's', 'v4', 'v4', 'v8', }},{true,{'v4', 's', 's', 'v4', 'v4', 'v8', }},},
			{'myRank', {false,{'firstPass','guildId', 'name', 'presidentName', 'power', 'level', 'passTime', }},{true,{'rankInfos','guildId', 'name', 'presidentName', 'power', 'level', 'passTime', }},}
		}
	end,
	[0x1053] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {false,{'v8', 'v4', }},},
			{'result', {false,{'gemStatus','userid', 'holeNum', }},}
		}
	end,
	[0x1306] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 's', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'tv8', }},},
			{{true,{'playerList','rank', 'playerId', 'playerName', 'playerLevel', 'generalId', 'fightPower', 'challengeTotalCount', 'challengeWinCount', 'vipLevel', 'prevRank', 'bestRank', 'totalScore', 'activeChallenge', 'activeWin', 'continuityWin', 'maxContinuityWin', 'formation', }},}
		}
	end,
	[0x1065] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', }},},
			{{true,{'item','fragmentId', 'mergeId', 'number', }},}
		}
	end,
	[0x5806] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v4', 'v8', 'v8', }},},
			{{true,{'item','index', 'resType', 'resId', 'resNum', 'createTime', 'lastUpdate', }},}
		}
	end,
	[0x1510] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'result', }
		}
	end,
	[0x1D08] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'b', 'v8', 's', 's', 's', 'v4', {true,{'v4', 'v4', 'v4', }},{true,{'v4', 'v4', }},}},},
			{{true,{'notifyList','id', 'type', 'canGet', 'time', 'textTitle', 'textTitleSub', 'textContect', 'status', {true,{'itemlist','type', 'itemid', 'num', }},{true,{'reslist','type', 'num', }},}},}
		}
	end,
	[0x1D22] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'b', 'v8', 's', 's', 's', 'v4', {true,{'v4', 'v4', 'v4', }},{true,{'v4', 'v4', }},}},},
			{{true,{'mail','id', 'type', 'canGet', 'time', 'textTitle', 'textTitleSub', 'textContect', 'status', {true,{'itemlist','type', 'itemid', 'num', }},{true,{'reslist','type', 'num', }},}},}
		}
	end,
	[0x5003] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1020] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v8', 'v4', 'v4', }},{false,{'v8', 'v4', }},},
			{{false,{'success','equipment', 'star', 'grow', }},{false,{'fail','equipment', 'fail', }},}
		}
	end,
	[0x3003] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1202] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'boxId', }
		}
	end,
	[0x1D04] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 's', 'b', 'v4', },
			{'winerName', 'loserName', 'neili', 'rank', }
		}
	end,
	[0x1054] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'b', {false,{'v8', 'v4', 'v4', {false,{'s', 's', }},}},},
			{'result', 'success', {false,{'changed','userid', 'oldTemplateId', 'newTemplateId', {false,{'attr','base_attr', 'extra_attr', }},}},}
		}
	end,
	[0x4422] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', }},},
			{{true,{'infos','attributeType', 'level', }},}
		}
	end,
	[0x180C] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'isSuccess', }
		}
	end,
	[0x2302] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 's', 's', 's', 'v4', },
			{'id', 'progress', 'extend', 'got', 'lastUpdate', 'resetRemaining', }
		}
	end,
	[0x1605] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'b', },
			{'objID', 'lock', }
		}
	end,
	[0x3303] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v4', 'v4', 's', 's', }},},
			{'type', {true,{'rank','playerId', 'rankValue', 'name', 'otherDisplay', }},}
		}
	end,
	[0x1907] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv4', },
			{'commodityId', }
		}
	end,
	[0x0E97] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v8', 'b', }},{true,{'v4', 'v4', }},},
			{{true,{'unlockedlist','id', 'expireTime', 'firstGet', }},{true,{'lockedList','id', 'currentNum', }},}
		}
	end,
	[0x6303] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'success', 'boxIndex', 'round', }
		}
	end,
	[0x1D24] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5111] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v8', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 's', 's', 's', 's', 's', 'v4', 'v4', 's', 'v4', }},},
			{{true,{'role','instanceId', 'useType', 'roleId', 'level', 'martialLevel', 'starlevel', 'power', 'hp', 'spell', 'attributes', 'immune', 'effectActive', 'effectPassive', 'state', 'quality', 'name', 'forgingQuality', }},}
		}
	end,
	[0x4081] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 's', 'v4', 's', 'v4', 's', 'v4', 'b', }},},
			{{true,{'rankInfo','guildId', 'exp', 'name', 'memberCount', 'presidentName', 'power', 'declaration', 'level', 'apply', }},}
		}
	end,
	[0x2054] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v4', }},},
			{{true,{'tasklist','taskid', 'state', 'currstep', 'totalstep', }},}
		}
	end,
	[0x1B03] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'words', }
		}
	end,
	[0x3209] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', {true,{'s', 'v4', 'v4', 'v4', }},{true,{'v4', 'v4', {true,{'v4', 'b', 'v4', 'v4', 'v4', }},'v4', 'v4', }},'v4', },
			{'currSection', 'coinInspireCount', 'sysceeInspireCount', 'dailyMaxInspireCount', 'maxPass', 'lastPass', 'sweepPass', 'todaySweep', {true,{'allEnemys','name', 'section', 'star', 'roleId', }},{true,{'BloodyBoxList','index', 'status', {true,{'BloodyBoxList','index', 'bIsget', 'type', 'itemId', 'number', }},'needResType', 'needResNum', }},'resetCount', }
		}
	end,
	[0x1060] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'templateId', }
		}
	end,
	[0x4427] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v8', 'v4', 'v8', }},{true,{'v8', 'v4', 'v4', }},},
			{{true,{'playerPracticeInfos','pos', 'instanceId', 'attributeType', 'practiceTime', }},{true,{'partnerPracticeInfos','instanceId', 'attributeType', 'level', }},}
		}
	end,
	[0x4425] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4601] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v4', 'tv8', }},'tv4', 'v4', 'v8', },
			{'openPos', {true,{'roleInfos','type', 'roles', }},'agreeLevels', 'friendRoleId', 'friendProvideTime', }
		}
	end,
	[0x0e90] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'instanceId', }
		}
	end,
	[0x4922] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'tv4', 'v4', 'b', },
			{'index', 'option', 'choice', 'skip', }
		}
	end,
	[0x3600] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'b', 'v8', 'v8', }},},
			{{true,{'switchList','switchType', 'open', 'beginTime', 'endTime', }},}
		}
	end,
	[0x1312] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', {false,{'v4', 'v4', 'v4', 'v4', }},},
			{'hasrank', {false,{'rank','level', 'rank', 'reward', 'nexttime', }},}
		}
	end,
	[0x7F02] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v4', 'v4', 'v4', }},},
			{'type', {true,{'items','type', 'number', 'itemId', }},}
		}
	end,
	[0x2201] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v4', 'b', {false,{'v4', 'v4', 'v4', }},{false,{'v4', 'v4', 'v4','s', 'v4', 'v4', }},'v4', }},},
			{'type', {true,{'rolelist','index', 'empty', {false,{'product','resType', 'resId', 'number', }},{false,{'role','playerId', 'profession', 'sex','name', 'level', 'power', }},'reaminTime', }},}
		}
	end,
	[0x4514] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', 's', }},'v4', 's', 's', },
			{{true,{'rankInfos','playerId', 'name', 'power', 'guildName', }},'myRank', 'atkFormation', 'defFromation', }
		}
	end,
	[0x3407] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', 'v4', 'v4', 'v4', },
			{'roleId', 'position', 'martialId', 'costType', 'costValue', }
		}
	end,
	[0x5006] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 's', 'v4', 'v4', 'v8', }},},
			{{true,{'recordList','playerId', 'employerPlayerName', 'robPlayerName', 'brokerrage', 'extraBrokerrage', 'recordTime', }},}
		}
	end,
	[0x4000] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 's', 'v4', 'v4', 'v4', {true,{'v8', 'v4', 'v4', }},'v4', 'v4', }},'v4', 'v4', 'v4', 'v4', },
			{{true,{'rankInfo','ranking', 'playerId', 'power', 'name', 'level', 'vipLevel', 'goodNum', {true,{'formation','instanceId', 'position', 'templateId', }},'profession', 'headPicFrame', }},'lastPower', 'myRanking', 'myBestValue', 'praiseCount', }
		}
	end,
	[0x1013] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'userId', }
		}
	end,
	[0x3301] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 's', 's', }},},
			{{true,{'statusList','type', 'status', 'startTime', 'endTime', }},}
		}
	end,
	[0x4504] = function()
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
	[0x4706] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', 's', 'v4', 's', }},{true,{'v4', 's', 'v4', 's', }},},
			{{false,{'player','rank', 'name', 'score', 'serverName', }},{true,{'list','rank', 'name', 'score', 'serverName', }},}
		}
	end,
	[0x4413] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1805] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'isSuccess', }
		}
	end,
	[0x4419] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4','s', }},},
			{{true,{'dyns','type','mess', }},}
		}
	end,
	[0x1F07] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv4', },
			{'posList', }
		}
	end,
	[0x4070] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v8', 'tv4', },
			{'totalCount', 'todayCount', 'remaining', 'lastUpdate', 'targetId', }
		}
	end,
	[0x1C02] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'b', 'v4', 'v4', },
			{'cardType', 'firstGet', 'freeTimes', 'cdTime', }
		}
	end,
	[0x1D23] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x440c] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 's', 'v4', },
			{'secondlyProgress', 'lastPlayerName', 'worshipCount', }
		}
	end,
	[0x3402] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', {true,{'v4', 'v4', 'v4', 'v4', }},},
			{'roleId', 'martialLevel', {true,{'martialInfo','id', 'position', 'enchantLevel', 'enchantProgress', }},}
		}
	end,
	[0x5801] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'count', }
		}
	end,
	[0x2051] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v4', }},'v4', },
			{{true,{'tasklist','taskid', 'state', 'currstep', 'totalstep', }},'days', }
		}
	end,
	[0x1a03] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'totalRecharge', 'vipLevel', }
		}
	end,
	[0x2304] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'id', 'index', }
		}
	end,
	[0x1405] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'challengeTimes', 'remainChallengeTimes', }
		}
	end,
	[0x3200] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v8', 'v4', 'v4', 'v4', }},},
			{'capacity', {true,{'stations','roleId', 'index', 'currHp', 'maxHp', }},}
		}
	end,
	[0x1a04] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', }},},
			{{true,{'recordList','id', 'buyTimes', }},}
		}
	end,
	[0x3205] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'capacity', }
		}
	end,
	[0x4083] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', 'v4', 'v4', 'v4', 'v4', }},'v4', },
			{{true,{'infos','playerId', 'name', 'level', 'profession', 'hurt', 'icon', 'headPicFrame', }},'totleHurt', }
		}
	end,
	[0x4311] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv4', },
			{'friendIds', }
		}
	end,
	[0x1310] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'win', }
		}
	end,
	[0x1D06] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'b', 'v8', 's', 'v4', 'v4', 'v4', 'v4', }},},
			{{true,{'list','reportId', 'fightType', 'win', 'time', 'playerName', 'playerLev', 'playerPower', 'myRankPos', 'reward', }},}
		}
	end,
	[0x5321] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v8', 's', }},},
			{{true,{'invaite','playerId', 'recalledId', 'luanchTime', 'inviteCode', }},}
		}
	end,
	[0x1305] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', },
			{'myRank', 'fightPower', 'challengeTotalCount', 'challengeWinCount', 'bestRank', 'activeChallenge', 'activeWin', 'continuityWin', 'maxContinuityWin', }
		}
	end,
	[0x5805] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', 'v8', 'v8', },
			{'index', 'resType', 'resId', 'resNum', 'createTime', 'lastUpdate', }
		}
	end,
	[0x1607] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v8', 'v4', },
			{'bookObjID', 'roleID', 'position', }
		}
	end,
	[0x6300] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 'v4', 's', 's', 'v4', 'v4', 'v4', 'v8', {true,{'v4', 'v4', 'v4', 'v4', 'v4', }},{true,{'v4', {true,{'v4', 'v4', 'v4', }},}},},
			{'consumeSycee', 'isFirstFree', 'consumeGoods', 'boxCount', 'count', 'boxIndex', 'round', 'actTime', {true,{'configList','id', 'resType', 'resId', 'number', 'quality', }},{true,{'boxRewardList','count', {true,{'boxReward','resType', 'resId', 'number', }},}},}
		}
	end,
	[0x1B01] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'playerId', }
		}
	end,
	[0x4418] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5908] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', {true,{'v8', 'v4', 'v4', 'v4', }},{true,{'v8', 'v4', 'v4', 'v4', }},'v4', }},'v4', 'v4', 'v4', 'tv4', },
			{{true,{'rankInfo','playerId', 'name', 'level', 'power', 'profession', 'headPicFrame', 'massacreValue', 'ranking', {true,{'formation','instanceId', 'position', 'templateId', 'quality', }},{true,{'secondFormation','instanceId', 'position', 'templateId', 'quality', }},'secondPower', }},'lastValue', 'myRanking', 'myBestValue', 'challengeId', }
		}
	end,
	[0x1201] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4','v4', },
			{'missionId', 'challengeCount', 'starLevel','resetCount', }
		}
	end,
	[0x1016] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v8', },
			{'result', 'userid', }
		}
	end,
	[0x4408] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x0e01] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v8', 'v4', 'v4', 'v8', 'v4', 'v4', 'v4', {true,{'v4', 'v4', }},{true,{'v8', 'v4', 'v4', 'v4', 's', 's', 'v4', 'v4', {true,{'v4', 'v4', }},'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v4', }},}},{true,{'v8', 'v4', 'v8', 'v4', 'v4', {true,{'v4', 'v4', }},}},}},},
			{{true,{'rolelist','userid', 'id', 'level', 'curexp', 'quality', 'starlevel', 'starExp', {true,{'spellId','skillId', 'level', }},{true,{'equiplist','userid', 'id', 'level', 'quality', 'base_attr', 'extra_attr', 'grow', 'holeNum', {true,{'gem','pos', 'id', }},'star', 'starFailFix', 'refineLevel', {true,{'recast','quality', 'ratio', 'index', }},}},{true,{'bibleInfo','instanceId', 'id', 'roleId', 'level', 'breachLevel', {true,{'essential','pos', 'id', }},}},}},}
		}
	end,
	[0x4510] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1505] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', },
			{'userid', 'quality', }
		}
	end,
	[0x1D0A] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 's', 'v4', 'v4', }},},
			{{true,{'rankingInfo','playerId', 'displayId', 'name', 'level', 'vipLevel', }},}
		}
	end,
	[0x4704] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', 's', 'v4', 's', }},{true,{'v4', 's', 'v4', 's', }},},
			{{false,{'player','rank', 'name', 'score', 'serverName', }},{true,{'list','rank', 'name', 'score', 'serverName', }},}
		}
	end,
	[0x5113] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v8', 'v8', 'v8', },
			{'playerId', 'todayCount', 'totalCount', 'createTime', 'lastUpdate', 'instanceId', }
		}
	end,
	[0x3601] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'b', 'v8', 'v8', },
			{'switchType', 'open', 'beginTime', 'endTime', }
		}
	end,
	[0x7F11] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x2901] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', },
			{'type', 'days', 'times', 'remainWaitTime', }
		}
	end,
	[0x1511] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'userid', }
		}
	end,
	[0x440e] = function()
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
	[0x5302] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'taskid', }
		}
	end,
	[0x4507] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'status', }
		}
	end,
	[0x3000] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v8', 'v8', 'v4', 'v8', 'v8', 'v4', }},},
			{{true,{'info','id', 'startTime', 'endTime', 'status', 'leftFreeRefreshTime', 'leftYabiaoTime', 'nextRefreshCostSysee', }},}
		}
	end,
	[0x1307] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', },
			{'oldRank', 'currentRank', 'walk', 'sycee', }
		}
	end,
	[0x4304] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv4', 'v4', },
			{'playerIds', 'type', }
		}
	end,
	[0x1D41] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v4', 'v4', 'v4', 'tv4', {false,{'v4', 'v4', }},{true,{'v4', 'v4', }},'s', 's', 's', 's', }},'v4', }},{false,{'v4', 'b', {true,{'b', 'v4', 'v4', 'v4', 'v4', 'b', {true,{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', }},'v4', }},{true,{'v4', 'v4', }},'v4', 'v4', {true,{'v4', 'v4', }},}},'v4', },
			{{false,{'beginInfo','fighttype', 'angerSelf', 'angerEnemy', {true,{'rolelist','typeid', 'roleId', 'maxhp', 'posindex', 'level', 'attr', {false,{'spellId','skillId', 'level', }},{true,{'passiveskill','skillId', 'level', }},'name', 'immune', 'effectActive', 'effectPassive', }},'index', }},{false,{'fightData','fighttype', 'win', {true,{'actionlist','bManualAction', 'roundIndex', 'attackerpos', 'skillid', 'skillLevel', 'bBackAttack', {true,{'targetlist','targetpos', 'effect', 'hurt', 'triggerBufferID', 'triggerBufferLevel', 'passiveEffect', 'passiveEffectValue', 'activeEffect', 'activeEffectValue', }},{true,{'stateList','frompos', 'targetpos', 'stateId', 'skillId', 'skillLevel', 'bufferId', 'bufferLevel', }},'triggerType', }},{true,{'livelist','posindex', 'currhp', }},'angerSelf', 'angerEnemy', {true,{'hurtcountlist','posindex', 'hurt', }},}},'rank', }
		}
	end,
	[0x1D00] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 'v4', },
			{'playerName', 'cardId', }
		}
	end,
	[0x5322] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v8', 's', }},'tv4', },
			{{true,{'invaite','playerId', 'recalledId', 'luanchTime', 'inviteCode', }},'playerIds', }
		}
	end,
	[0x2207] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', {true,{'v4', 'v4', 'v4', }},},
			{'type', 'index', {true,{'product','resType', 'resId', 'number', }},}
		}
	end,
	[0x1806] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'isSuccess', }
		}
	end,
	[0x0d21] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v8', },
			{'serverStartup', 'lastLogon', }
		}
	end,
	[0x1a06] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5400] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v8', {true,{'v4', 'v4', 'v4', 'v4', }},},
			{'roleId', 'todayCount', 'rewardDay', 'rewardTime', {true,{'info','roleId', 'roleNum', 'roleSycee', 'isGetReward', }},}
		}
	end,
	[0x5104] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v8', 'v4', 's', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', }},},
			{{true,{'info','instanceId', 'playerId', 'name', 'relation', 'roleId', 'level', 'start', 'martial', 'power', 'quality', 'forgingQuality', }},}
		}
	end,
	[0x441d] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1014] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {false,{'v8', 'v4', {false,{'s', 's', }},}},},
			{'result', {false,{'levelChanged','userid', 'levelUp', {false,{'attr','base_attr', 'extra_attr', }},}},}
		}
	end,
	[0x2204] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'b', {false,{'v4', 'v4', 'v4', }},{false,{'v4', 'v4', 'v4','s', 'v4', 'v4', }},'v4', }},},
			{{true,{'info','index', 'empty', {false,{'product','resType', 'resId', 'number', }},{false,{'role','playerId', 'profession', 'sex','name', 'level', 'power', }},'reaminTime', }},}
		}
	end,
	[0x1D0E] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 'v4', },
			{'name', 'gameLevel', }
		}
	end,
	[0x0E95] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5009] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v8', 'v4', }},{true,{{false,{'v4', 'v4', 's', 'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v8', 'v4', 's', 'v4', {true,{'v4', 'v4', 'v4', 'v4', {true,{'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},}},{true,{'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},'v4', 'tv4', {true,{'v4', 'v4', }},'v4', 'v4', {true,{'v4', 'v4', 'v4', }},'s', 's', 's', {true,{'v8', 'v4', 'v8', 'v4', 'v4', {true,{'v4', 'v4', }},}},'v4', }},{true,{{false,{'v4', 'v4', }},'b', 'v4', }},'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},}},},
			{{true,{'myInfos','instanceId', 'currHp', }},{true,{'infos',{false,{'details','playerId', 'profession', 'name', 'level', 'vipLevel', 'power', {true,{'warside','id', 'level', 'curexp', 'power', 'attributes', 'warIndex', {true,{'equipment','id', 'level', 'quality', 'refineLevel', {true,{'gem','pos', 'id', }},{true,{'recast','quality', 'ratio', 'index', }},}},{true,{'book','templateId', 'level', 'attribute', }},{true,{'meridians','index', 'level', 'attribute', }},'starlevel', 'fateIds', {true,{'spellId','skillId', 'level', }},'quality', 'martialLevel', {true,{'martial','id', 'position', 'enchantLevel', }},'immune', 'effectActive', 'effectPassive', {true,{'bibleInfo','instanceId', 'id', 'roleId', 'level', 'breachLevel', {true,{'essential','pos', 'id', }},}},'forgingQuality', }},{true,{'spell',{false,{'spellId','skillId', 'level', }},'choice', 'sid', }},'icon', 'headPicFrame', }},{true,{'paratInfo','maxHp', 'currHp', 'index', }},}},}
		}
	end,
	[0x180B] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'isSuccess', }
		}
	end,
	[0x4432] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5700] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'sucess', }
		}
	end,
	[0x5320] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'playerId', }
		}
	end,
	[0x5702] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'sucess', }
		}
	end,
	[0x0F22] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', 'v4', 's', 's', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', },
			{'win', 'result', 'atkName', 'defName', 'atkProfession', 'defProfession', 'atkHurt', 'defHurt', 'atkIcon', 'defIcon', 'atkHeadPicFrame', 'defHeadPicFrame', }
		}
	end,
	[0x5100] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v8', 'v8', 'v4', 'v4', 'v4', }},},
			{{true,{'roleList','roleId', 'startTime', 'coin', 'indexId', 'count', }},}
		}
	end,
	[0x0e24] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1808] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'isSuccess', }
		}
	end,
	[0x5165] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v8', 'v8', },
			{'playerId', 'todayCount', 'totalCount', 'createTime', 'lastUpdate', }
		}
	end,
	[0x4421] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v8', {true,{'v4', 'b', {true,{'v4', 'v4', 'v4', }},}},'b', 'v8', 's', 'v4', },
			{'zoneId', 'resetCount', 'lockPlayerId', 'lockTime', {true,{'checkpoints','checkpointId', 'pass', {true,{'states','index', 'hp', 'maxHp', }},}},'pass', 'bastPassTime', 'lockPlayerName', 'profession', }
		}
	end,
	[0x5008] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x0e73] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v8', 'v4', 's', 'v4', {true,{'v4', 'v4', 'v4', 'v4', {true,{'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},}},{true,{'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},'v4', 'tv4', {true,{'v4', 'v4', }},'v4', 'v4', {true,{'v4', 'v4', 'v4', }},'s', 's', 's', {true,{'v8', 'v4', 'v8', 'v4', 'v4', {true,{'v4', 'v4', }},}},'v4', },
			{'id', 'level', 'curexp', 'power', 'attributes', 'warIndex', {true,{'equipment','id', 'level', 'quality', 'refineLevel', {true,{'gem','pos', 'id', }},{true,{'recast','quality', 'ratio', 'index', }},}},{true,{'book','templateId', 'level', 'attribute', }},{true,{'meridians','index', 'level', 'attribute', }},'starlevel', 'fateIds', {true,{'spellId','skillId', 'level', }},'quality', 'martialLevel', {true,{'martial','id', 'position', 'enchantLevel', }},'immune', 'effectActive', 'effectPassive', {true,{'bibleInfo','instanceId', 'id', 'roleId', 'level', 'breachLevel', {true,{'essential','pos', 'id', }},}},'forgingQuality', }
		}
	end,
	[0x441e] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1C00] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'b', 'v4', 'v4', }},},
			{{true,{'stateList','cardType', 'firstGet', 'freeTimes', 'cdTime', }},}
		}
	end,
	[0x6007] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 's', },
			{'result', 'itemId', }
		}
	end,
	[0x3220] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'remainResetTime', }
		}
	end,
	[0x1043] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v8', },
			{'roleId', 'equipment', }
		}
	end,
	[0x1a01] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'b', 'b', },
			{'id', 'isFirstPay', 'multiple', }
		}
	end,
	[0x1814] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'isSuccess', }
		}
	end,
	[0x4301] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', 'v4', 'v8', 'v4', 'v4', 'b', 'v4', 's', 'v4', 'v4', 'v4', }},},
			{{true,{'infos','playerId', 'name', 'vip', 'power', 'lastLoginTime', 'profession', 'level', 'online', 'guildId', 'guildName', 'minePower', 'icon', 'headPicFrame', }},}
		}
	end,
	[0x6008] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v8', },
			{'result', 'bible', }
		}
	end,
	[0x1720] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v4', 'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v4', }},}},},
			{'id', {true,{'result','exp', 'oldLevel', 'currentLevel', 'coin', {true,{'item','type', 'number', 'itemId', }},}},}
		}
	end,
	[0x4411] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4','s', },
			{'type','mess', }
		}
	end,
	[0x4505] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5804] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5909] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v8', 'v4', 'v4', }},},
			{{true,{'log','id', 'name', 'level', 'power', 'icon', 'headPicFrame', 'type', 'massacreValue', 'coin', 'experience', 'battleTime', 'firstRecordId', 'secondRecordId', }},}
		}
	end,
	[0x5910] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'result', }
		}
	end,
	[0x4516] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'s', 's', 'v4', 'v4', }},'s', 's', },
			{{true,{'ranks','name', 'serverName', 'power', 'playerId', }},'atkFormation', 'defFromation', }
		}
	end,
	[0x2103] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'battleType', }
		}
	end,
	[0x1710] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v4', 'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v4', }},}},},
			{'id', {true,{'result','exp', 'oldLevel', 'currentLevel', 'coin', {true,{'item','type', 'number', 'itemId', }},}},}
		}
	end,
	[0x180A] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'isSuccess', }
		}
	end,
	[0x1081] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 's', },
			{'equipment', 'lastExtra', }
		}
	end,
	[0x3001] = function()
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
	[0x1090] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v8', },
			{'srcId', 'targetId', }
		}
	end,
	[0x6501] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'result', }
		}
	end,
	[0x3100] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 's', 's', },
			{'equipStr', 'roleStr', 'bibleStr', }
		}
	end,
	[0x4005] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 's', 'v4', 'v4', 'v4', {true,{'v8', 'v4', 'v4', }},'v4', 'v4', 'v4', 'v4', }},'v4', 'v4', 'v4', 'v4', 'v4', 'v4', },
			{{true,{'rankInfo','ranking', 'playerId', 'power', 'name', 'level', 'vipLevel', 'goodNum', {true,{'formation','instanceId', 'position', 'templateId', }},'totalDamage', 'replayId', 'profession', 'headPicFrame', }},'last', 'myRanking', 'myBestValue', 'praiseCount', 'betterRewardValue', 'rewardId', }
		}
	end,
	[0x5914] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'result', }
		}
	end,
	[0x4201] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v8', 'v8', },
			{'id', 'total', 'best', 'todayTimes', 'todayPayTimes', 'totalTimes', 'totalPayTimes', 'lastUpdate', 'lastReward', }
		}
	end,
	[0x2800] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v8', 'v8', 'v8', }},},
			{{true,{'info','id', 'startTime', 'endTime', 'lastGotRewardTime', }},}
		}
	end,
	[0x4202] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v8', 'v8', }},},
			{{true,{'info','id', 'total', 'best', 'todayTimes', 'todayPayTimes', 'totalTimes', 'totalPayTimes', 'lastUpdate', 'lastReward', }},}
		}
	end,
	[0x1404] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'s', 'v4', 'v4', 'v4', 'v4', 'v4', }},},
			{{true,{'rankList','name', 'rolenum', 'viplevel', 'level', 'questnum', 'playerid', }},}
		}
	end,
	[0x4405] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x0e0d] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{{false,{'v4', 'v4', }},'b', 'v4', }},},
			{{true,{'spell',{false,{'spellId','skillId', 'level', }},'choice', 'sid', }},}
		}
	end,
	[0x0e0c] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', 'v4', }},{false,{'v4', 'v4', }},},
			{{false,{'oldSpellId','skillId', 'level', }},{false,{'spellId','skillId', 'level', }},}
		}
	end,
	[0x4403] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1904] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', {true,{'v4', 'v4', 'b', }},'v8', 'v4', 'v4', 'v8', }},},
			{{true,{'store','type', {true,{'commodity','commodityId', 'num', 'enabled', }},'nextAutoRefreshTime', 'nextRefreshCost', 'manualRefreshCount', 'opentime', }},}
		}
	end,
	[0x5903] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv8', 'tv8', },
			{'formation', 'secondFormation', }
		}
	end,
	[0x0e50] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', 'v4', 'v4', },
			{'userId', 'templateId', 'currentLevel', 'currentExp', }
		}
	end,
	[0x5202] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1301] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', {true,{'v4', 'v4', 's', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'tv8', }},},
			{'pageNumber', 'currentPage', {true,{'rankList','rank', 'playerId', 'playerName', 'playerLevel', 'generalId', 'fightPower', 'challengeTotalCount', 'challengeWinCount', 'vipLevel', 'prevRank', 'bestRank', 'totalScore', 'activeChallenge', 'activeWin', 'continuityWin', 'maxContinuityWin', 'formation', }},}
		}
	end,
	[0x0e60] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v8', 'v4', 'v4', 'v8', 'v4', 'v4', 'v4', {true,{'v4', 'v4', }},{true,{'v8', 'v4', 'v4', 'v4', 's', 's', 'v4', 'v4', {true,{'v4', 'v4', }},'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v4', }},}},{true,{'v8', 'v4', 'v8', 'v4', 'v4', {true,{'v4', 'v4', }},}},}},},
			{{false,{'info','userid', 'id', 'level', 'curexp', 'quality', 'starlevel', 'starExp', {true,{'spellId','skillId', 'level', }},{true,{'equiplist','userid', 'id', 'level', 'quality', 'base_attr', 'extra_attr', 'grow', 'holeNum', {true,{'gem','pos', 'id', }},'star', 'starFailFix', 'refineLevel', {true,{'recast','quality', 'ratio', 'index', }},}},{true,{'bibleInfo','instanceId', 'id', 'roleId', 'level', 'breachLevel', {true,{'essential','pos', 'id', }},}},}},}
		}
	end,
	[0x2701] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'b', 'v4', 'v4', },
			{'monthDay', 'isSign', 'month', 'monthDaySum', }
		}
	end,
	[0x4506] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4','s', },
			{'type','msg', }
		}
	end,
	[0x4521] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4','s', },
			{'type','msg', }
		}
	end,
	[0x0e33] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v8', },
			{'type', 'multiple', 'endTime', }
		}
	end,
	[0x0e21] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'levelUp', 'oldStamina', 'newStamina', }
		}
	end,
	[0x2055] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'taskid', 'currstep', }
		}
	end,
	[0x2205] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', },
			{'index', 'resType', 'resId', 'number', }
		}
	end,
	[0x1818] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'isSuccess', }
		}
	end,
	[0x1901] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', }},},
			{{true,{'commodity','commodityId', 'num', }},}
		}
	end,
	[0x1204] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', {true,{{true,{'v4', 'v4', 'v4', }},'v4', 'v4', 'v4', 'v4', }},},
			{'missionId', 'useQuickPassTimes', 'useResetTimes', 'challengeCount', {true,{'itemlist',{true,{'itemlist','type', 'number', 'itemId', }},'addExp', 'oldLev', 'currLev', 'addCoin', }},}
		}
	end,
	[0x0e92] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv4', },
			{'icon', }
		}
	end,
	[0x0e11] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'name', }
		}
	end,
	[0x0e34] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'type', 'isPrompt', }
		}
	end,
	[0x1804] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', 'v4', 'v4', }},},
			{{true,{'playerList','playerId', 'playerName', 'playerLevel', 'generalId', 'fightPower', }},}
		}
	end,
	[0x0e91] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'result', }
		}
	end,
	[0x5602] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', 'v8', 'b', },
			{'instanceId', 'roleFateId', 'endTime', 'forever', }
		}
	end,
	[0x6200] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv4', },
			{'id', }
		}
	end,
	[0x4407] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', 'v4', 'v8', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'b', 'v4', 'v4', 'v4', }},},
			{{true,{'infos','playerId', 'name', 'vip', 'power', 'lastLoginTime', 'profession', 'level', 'competence', 'totleDedication', 'todayDedication', 'makedCoubt', 'online', 'minePower', 'icon', 'headPicFrame', }},}
		}
	end,
	[0x5153] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'tv4', },
			{'operation', 'coin', }
		}
	end,
	[0x5110] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v8', 'v8', 'v8', }},},
			{{true,{'count','playerId', 'todayCount', 'totalCount', 'createTime', 'lastUpdate', 'instanceId', }},}
		}
	end,
	[0x1050] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'b', },
			{'result', 'success', }
		}
	end,
	[0x5161] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', {true,{'v8', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 's', 's', 's', 's', 's', 'v4', }},{true,{'v4', 'v4', 'v8', 'v4', }},},
			{'fromId', 'useType', {true,{'roleDetails','instanceId', 'position', 'roleId', 'level', 'martialLevel', 'starlevel', 'power', 'hp', 'spell', 'attributes', 'immune', 'effectActive', 'effectPassive', 'quality', }},{true,{'assistant','position', 'roleId', 'instanceId', 'quality', }},}
		}
	end,
	[0x3410] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', {true,{'v4', 'v4', 'v4', 'v4', }},},
			{'roleId', {true,{'martial','id', 'position', 'enchantLevel', 'enchantProgress', }},}
		}
	end,
	[0x0dff] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5807] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v8', },
			{'enableType', 'betToday', 'betTotal', 'lastUpdate', }
		}
	end,
	[0x7F12] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', },
			{'openTime', }
		}
	end,
	[0x1012] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'statusCode', }
		}
	end,
	[0x4511] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 's', 's', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'tv8', 'tv8', 'v4', 'v4', 'v4', 'v4', }},},
			{{true,{'infos','round', 'index', 'atkPlayerId', 'defPlayerId', 'winPlayerId', 'replayId', 'atkPlayerName', 'defPlayerName', 'betPlayerId', 'coin', 'atkProfession', 'defProfession', 'atkPower', 'defPower', 'atkFormation', 'defFormation', 'atkIcon', 'defIcon', 'atkHeadPicFrame', 'defHeadPicFrame', }},}
		}
	end,
	[0x1D40] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'b', 'v8', 'v4', 'v4', 'v4', 'v4', {false,{'v4', 's', 'v4', 'v4', 'v4', 'v4', }},{false,{'v4', 's', 'v4', 'v4', 'v4', 'v4', }},}},},
			{{true,{'report','reportId', 'fightType', 'win', 'time', 'ranking', 'fromRank', 'power', 'targetPower', {false,{'fromRole','playerId', 'name', 'profession', 'level', 'vipLevel', 'power', }},{false,{'targetRole','playerId', 'name', 'profession', 'level', 'vipLevel', 'power', }},}},}
		}
	end,
	[0x4001] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 's', 'v4', 'v4', 'v4', 'v4', 'v4', {true,{'v8', 'v4', 'v4', }},'v4', 'v4', }},'v4', 'v4', 'v4', 'v4', },
			{{true,{'rankInfo','ranking', 'playerId', 'power', 'name', 'level', 'vipLevel', 'totalChallenge', 'totalWin', 'goodNum', {true,{'formation','instanceId', 'position', 'templateId', }},'profession', 'headPicFrame', }},'lastValue', 'myRanking', 'myBestValue', 'praiseCount', }
		}
	end,
	[0x7f20] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'b', }},},
			{{true,{'stateList','functionId', 'newMark', }},}
		}
	end,
	[0x1304] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', 'v4', },
			{'win', 'myRank', }
		}
	end,
	[0x5301] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv4', },
			{'taskid', }
		}
	end,
	[0x6302] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v4', 's', {true,{'v4', 'v4', 'v4', }},'v8', }},},
			{'type', {true,{'HistoryList','playerId', 'playerName', {true,{'rewardList','resType', 'resId', 'number', }},'createTime', }},}
		}
	end,
	[0x6301] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v4', 'v4', 'v4', }},},
			{'index', {true,{'rewardList','resType', 'resId', 'number', }},}
		}
	end,
	[0x1b04] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', 'v4', 'v4', 's', 'v4', 'v4', 'v8', 'v4', 's', 'v4', 'tv4', 'v4', 'v4', 'v4', 'v4', 'v4', 's', }},},
			{{true,{'chat','chatType', 'content', 'playerId', 'roleId', 'quality', 'name', 'vipLevel', 'level', 'timestamp', 'guildId', 'guildName', 'competence', 'invitationGuilds', 'titleType', 'guideType', 'icon', 'headPicFrame', 'serverId', 'serverName', }},}
		}
	end,
	[0x2001] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v4', }},},
			{{true,{'tasklist','taskid', 'state', 'currstep', 'totalstep', }},}
		}
	end,
	[0x2053] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'taskid', }
		}
	end,
	[0x5170] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'playerId', 'useType', }
		}
	end,
	[0x1000] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v8', 'v4', 'v4', 'v4', 's', 's', 'v4', 'v4', {true,{'v4', 'v4', }},'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v4', }},}},{true,{'v8', 'v4', }},{true,{'v8', 'v4', 'v8', 'v4', 'v4', {true,{'v4', 'v4', }},}},},
			{{true,{'equipmentlist','userid', 'id', 'level', 'quality', 'base_attr', 'extra_attr', 'grow', 'holeNum', {true,{'gem','pos', 'id', }},'star', 'starFailFix', 'refineLevel', {true,{'recast','quality', 'ratio', 'index', }},}},{true,{'ItemInfo','id', 'num', }},{true,{'bibleInfo','instanceId', 'id', 'roleId', 'level', 'breachLevel', {true,{'essential','pos', 'id', }},}},}
		}
	end,
	[0x4920] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', 'tv4', 'v4', 'b', }},},
			{{false,{'info','index', 'option', 'choice', 'skip', }},}
		}
	end,
	[0x1D20] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'id', 'status', }
		}
	end,
	[0x2060] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', }},},
			{{true,{'info','id', 'number', }},}
		}
	end,
	[0x2052] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv4', },
			{'taskid', }
		}
	end,
	[0x2003] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'taskid', }
		}
	end,
	[0x5300] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v4', }},'v4', },
			{{true,{'tasklist','taskid', 'state', 'currstep', 'totalstep', }},'days', }
		}
	end,
	[0x5350] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', 'v4', },
			{'backTime', 'rewardGot', 'fromPlayerId', }
		}
	end,
	[0x2801] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x0e70] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4','s', 'v4', 'v4', },
			{'playerId', 'profession', 'sex','name', 'level', 'power', }
		}
	end,
	[0x100D] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', 'v4', 'v4', 's', 's', 'v4', 'v4', {true,{'v4', 'v4', }},'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v4', }},},
			{'userid', 'id', 'level', 'quality', 'base_attr', 'extra_attr', 'grow', 'holeNum', {true,{'gem','pos', 'id', }},'star', 'starFailFix', 'refineLevel', {true,{'recast','quality', 'ratio', 'index', }},}
		}
	end,
	[0x1D02] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 'v4', },
			{'playerName', 'bookId', }
		}
	end,
	[0x5114] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 's', 's', 's', 's', 's', 'v4', 'v4', 's', 'v4', },
			{'instanceId', 'useType', 'roleId', 'level', 'martialLevel', 'starlevel', 'power', 'hp', 'spell', 'attributes', 'immune', 'effectActive', 'effectPassive', 'state', 'quality', 'name', 'forgingQuality', }
		}
	end,
	[0x2203] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 'b', 'v4', 'v4', 'v4', },
			{'treasureExpression', 'hasMiningPoint', 'remainTime', 'type', 'index', }
		}
	end,
	[0x4406] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 's', 'v4', 's', 'v4', 's', 'v4', 's', 'v4', 'v4', 'v4', 'v8', 'b', 's', },
			{'guildId', 'exp', 'name', 'memberCount', 'presidentName', 'power', 'declaration', 'level', 'notice', 'boom', 'state', 'operateId', 'operateTime', 'apply', 'bannerId', }
		}
	end,
	[0x4431] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5323] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4400] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'tv4', 'tv4', 'v8', },
			{'guildId', 'competence', 'dedication', 'worship', 'coin', 'applyCount', 'makePlayers', 'drawTreasureChests', 'lastOutTime', }
		}
	end,
	[0x4522] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x6305] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', 's', 'v4', 's', }},{true,{'v4', 's', 'v4', 's', }},},
			{{false,{'own','rank', 'name', 'score', 'serverName', }},{true,{'list','rank', 'name', 'score', 'serverName', }},}
		}
	end,
	[0x4523] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4308] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', 's', 'v4', 'v4', 'v8', 'v4', 'v4', 'b', 'v4', 's', 'v4', 'v4', 'v4', }},},
			{{false,{'info','playerId', 'name', 'vip', 'power', 'lastLoginTime', 'profession', 'level', 'online', 'guildId', 'guildName', 'minePower', 'icon', 'headPicFrame', }},}
		}
	end,
	[0x4303] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4003] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v8', 'v4', 'v4', 's', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', }},'v4', 'v4', 'v4', 'v4', 'v8', 'v4', },
			{{true,{'rankInfo','ranking', 'playerId', 'instanceId', 'roleId', 'value', 'name', 'playerLevel', 'vipLevel', 'goodNum', 'roleLevel', 'martialLevel', 'starLevel', 'quality', 'profession', 'headPicFrame', }},'lastValue', 'myRanking', 'myBestValue', 'topRoleId', 'topInstanceId', 'praiseCount', }
		}
	end,
	[0x3214] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', {true,{'v4', 'b', 'v4', 'v4', 'v4', }},'v4', 'v4', }},'v4', 'v4', },
			{{true,{'BloodyBoxList','index', 'status', {true,{'BloodyBoxList','index', 'bIsget', 'type', 'itemId', 'number', }},'needResType', 'needResNum', }},'index', 'getType', }
		}
	end,
	[0x3213] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', {false,{'v4', 'b', 'v4', 'v4', 'v4', }},}},},
			{{false,{'updateInfo','boxIndex', {false,{'prize','index', 'bIsget', 'type', 'itemId', 'number', }},}},}
		}
	end,
	[0x5701] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1800] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 's', 'v4', 'v4', 'v4', 's', 'v4', }},},
			{{true,{'rankList','rank', 'gangId', 'gangName', 'gangLevel', 'memberNum', 'masterId', 'masterName', 'applyStatus', }},}
		}
	end,
	[0x6600] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v8', {true,{'v4', 'v4', }},}},},
			{{true,{'xiake','roleId', {true,{'data','acupoint', 'level', }},}},}
		}
	end,
	[0x4420] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x2002] = function()
		return {
			{"net.NetHelper", "receive"},
			{'tv4', },
			{'taskid', }
		}
	end,
	[0x3206] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v8', },
			{'fromPos', 'toPos', 'roleId', }
		}
	end,
	[0x0e51] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', },
			{'userId', 'currentExp', }
		}
	end,
	[0x5101] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v8', 'v8', 'v4', 'v4', 'v4', }},'v4', 'tv4', },
			{{false,{'role','roleId', 'startTime', 'coin', 'indexId', 'count', }},'operation', 'coin', }
		}
	end,
	[0x0d20] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v8', },
			{'serverStartup', 'lastLogon', }
		}
	end,
	[0x1603] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'bookpos', }
		}
	end,
	[0x4302] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{{false,{'v4', 's', 'v4', 'v4', 'v8', 'v4', 'v4', 'b', 'v4', 's', 'v4', 'v4', 'v4', }},'b', }},},
			{{true,{'list',{false,{'info','playerId', 'name', 'vip', 'power', 'lastLoginTime', 'profession', 'level', 'online', 'guildId', 'guildName', 'minePower', 'icon', 'headPicFrame', }},'apply', }},}
		}
	end,
	[0x1509] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', },
			{'userid', 'starLevel', }
		}
	end,
	[0x5303] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v4', }},},
			{{true,{'tasklist','taskid', 'state', 'currstep', 'totalstep', }},}
		}
	end,
	[0x1a02] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', 'v4', }},{false,{'v4', 'v4', }},'v4', },
			{{false,{'prev','totalRecharge', 'vipLevel', }},{false,{'current','totalRecharge', 'vipLevel', }},'sycee', }
		}
	end,
	[0x4923] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'tv4', },
			{'sectionId', 'options', }
		}
	end,
	[0x500E] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'b', 'v8', 'v4', 'v4', 'v4', 'v4', {false,{'v4', 's', 'v4', 'v4', 'v4', 'v4', }},{false,{'v4', 's', 'v4', 'v4', 'v4', 'v4', }},}},},
			{{true,{'report','reportId', 'fightType', 'win', 'time', 'ranking', 'fromRank', 'power', 'targetPower', {false,{'fromRole','playerId', 'name', 'profession', 'level', 'vipLevel', 'power', }},{false,{'targetRole','playerId', 'name', 'profession', 'level', 'vipLevel', 'power', }},}},}
		}
	end,
	[0x4501] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', 'v4', 'v4', 'v4', 'v4', 'tv8', 'tv8', 'v4', 'v4', 'v4', 'v4', }},'tv4', 'v4', 'v8', 'b', },
			{{false,{'info','atkWinStreak', 'atkMaxWinStreak', 'defWinStreak', 'defMaxWinSteak', 'score', 'atkFormation', 'defFormation', 'atkWinCount', 'atkLostCount', 'defWinCount', 'defLostCount', }},'boxes', 'matchCount', 'lastMatchTime', 'hosting', }
		}
	end,
	[0x5004] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1810] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'isSuccess', }
		}
	end,
	[0x1902] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v4', 'v4', 'b', }},'v8', 'v4', 'v4', 'v8', },
			{'type', {true,{'commodity','commodityId', 'num', 'enabled', }},'nextAutoRefreshTime', 'nextRefreshCost', 'manualRefreshCount', 'opentime', }
		}
	end,
	[0x1401] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', },
			{'titleid', 'hp', 'neigong', 'waigong', 'neifang', 'waifang', 'hurt', }
		}
	end,
	[0x1906] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'commodityId', 'num', }
		}
	end,
	[0x0F03] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'result', 'killnum', 'bloodnum', }
		}
	end,
	[0x440f] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1912] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'state', }
		}
	end,
	[0x1817] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', 's', },
			{'isSuccess', 'buffStr', }
		}
	end,
	[0x1930] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', }},},
			{{true,{'result','consume', 'coin', 'mutil', }},}
		}
	end,
	[0x2004] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v4', }},},
			{{true,{'tasklist','taskid', 'state', 'currstep', 'totalstep', }},}
		}
	end,
	[0x4910] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v4', }},'v4', }},'v4', 'v4', },
			{{true,{'result','exp', 'oldLevel', 'currentLevel', 'coin', {true,{'item','type', 'number', 'itemId', }},'id', }},'nextId', 'tokens', }
		}
	end,
	[0x6500] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'result', }
		}
	end,
	[0x2902] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x2301] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 's', 'v4', 's', 'v4', 'b', 's', 's', 's', 's', 's', 'v4', 'b', }},},
			{{true,{'info','id', 'name', 'title', 'type', 'resetCron', 'status', 'history', 'icon', 'details', 'reward', 'beginTime', 'endTime', 'showWeight', 'crossServer', }},}
		}
	end,
	[0x2101] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', },
			{'type', 'maxValue', 'todayUse', 'currentValue', 'todayBuyTime', 'cooldownRemain', 'waitTimeRemain', 'todayResetWait', }
		}
	end,
	[0x5803] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'index', }
		}
	end,
	[0x4010] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', {true,{'v4', 'v4', 's', 'v4', 'v4', 'v4', 'v4', 'v4', {true,{'v8', 'v4', 'v4', }},'v4', 'v4', }},},
			{'last', 'myIntegral', 'myRanking', 'betterRewardValue', 'rewardId', 'praiseCount', {true,{'rankInfo','ranking', 'playerId', 'name', 'level', 'vipLevel', 'integral', 'praiseCount', 'power', {true,{'formation','instanceId', 'position', 'templateId', }},'profession', 'headPicFrame', }},}
		}
	end,
	[0x1900] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'commodityId', 'num', }
		}
	end,
	[0x440d] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1925] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', }},'v8', 'v8', },
			{{true,{'info','id', 'resType', 'resId', 'resNumber', 'consumeType', 'consumeId', 'consumeNumber', }},'beginTime', 'endTime', }
		}
	end,
	[0x7FFF] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'errorCode', 'cmdId', }
		}
	end,
	[0x5112] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v8', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 's', 's', 's', 's', 's', 'v4', 'v4', 's', 'v4', }},},
			{'useType', {true,{'role','instanceId', 'useType', 'roleId', 'level', 'martialLevel', 'starlevel', 'power', 'hp', 'spell', 'attributes', 'immune', 'effectActive', 'effectPassive', 'state', 'quality', 'name', 'forgingQuality', }},}
		}
	end,
	[0x1015] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'tv8', },
			{'result', 'userid', }
		}
	end,
	[0x1908] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v8', },
			{'type', 'opentime', }
		}
	end,
	[0x5703] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', {true,{'v4', 'v4', 's', 'v4', 'v4', }},'v4', }},},
			{{true,{'infos','eliteId', {true,{'battleInfo','playerId', 'power', 'name', 'profession', 'headPicFrame', }},'id', }},}
		}
	end,
	[0x1E00] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', 'b', 'b', 'b', },
			{'openMusic', 'openVolume', 'openChat', 'vipVisible', }
		}
	end,
	[0x5905] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', 'v4', 'v4', 'v4', 'v4', 'v8', 'v4', 'v4', 'v4', 's', 'v4', {true,{'v8', 'v4', 'v4', 'v4', }},{true,{'v8', 'v4', 'v4', 'v4', }},'v4', }},},
			{{true,{'enemy','id', 'name', 'level', 'power', 'icon', 'headPicFrame', 'revengeNum', 'battleTime', 'rewardMassacre', 'rewardCoin', 'rewardExperience', 'guildName', 'massacreValue', {true,{'formation','instanceId', 'position', 'templateId', 'quality', }},{true,{'secondFormation','instanceId', 'position', 'templateId', 'quality', }},'secondPower', }},}
		}
	end,
	[0x1701] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', 'v4', },
			{'win', 'curId', }
		}
	end,
	[0x1E02] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'isSuccess', }
		}
	end,
	[0x1500] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v8', {true,{'v4', 'v4', 'v4', }},}},'v8', 'v4', 'v4', },
			{{true,{'trainlist','instanceId', {true,{'acupointList','position', 'level', 'breachLevel', }},}},'lastTime', 'totalRate', 'waitRemain', }
		}
	end,
	[0x5151] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x6006] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v8', },
			{'result', 'instanceId', }
		}
	end,
	[0x1816] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'isSuccess', }
		}
	end,
	[0x500D] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v8', {true,{'v4', 's', 'v4', 'v4', 'v4', }},'b', 'v4', 'v4', 'v4', 's', }},},
			{{true,{'results','time', {true,{'infos','playerId', 'name', 'profession', 'icon', 'headPicFrame', }},'sucess', 'challengePlayerCount', 'challengeGuardCount', 'id', 'robResource', }},}
		}
	end,
	[0x1041] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4',{false,{'v8', 'v4', 'v4', 'v4', 's', 's', 'v4', 'v4', {true,{'v4', 'v4', }},'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v4', }},}},{false,{'v8', 'v4', }},},
			{'type',{false,{'equipment','userid', 'id', 'level', 'quality', 'base_attr', 'extra_attr', 'grow', 'holeNum', {true,{'gem','pos', 'id', }},'star', 'starFailFix', 'refineLevel', {true,{'recast','quality', 'ratio', 'index', }},}},{false,{'item','id', 'num', }},}
		}
	end,
	[0x1923] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v8', 'v8', 'v4', 'v4', 's', 'v4', 'v4', 'v4', 'v4', 'v4', },
			{'id', 'type', 'resType', 'resId', 'number', 'consumeType', 'consumeId', 'consumeNumber', 'isLimited', 'consumeAdd', 'needVipLevel', 'beginTime', 'endTime', 'maxType', 'maxNum', 'vipMaxNumMap', 'oldPrice', 'limitType', 'isHot', 'timeType', 'orderNo', }
		}
	end,
	[0x441b] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1508] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', 'v4', },
			{'userid', 'level', 'curExp', }
		}
	end,
	[0x150A] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'b', {false,{'v4', 'v4', 'v4', }},'v8', 'v4', 'v4', },
			{'instanceId', 'success', {false,{'acupointInfo','position', 'level', 'breachLevel', }},'lastTime', 'totalRate', 'waitRemain', }
		}
	end,
	[0x1021] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'fail', }
		}
	end,
	[0x4409] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x0F20] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v4', 'v4', 'v4', 'tv4', {false,{'v4', 'v4', }},{true,{'v4', 'v4', }},'s', 's', 's', 's', }},},
			{'fighttype', 'angerSelf', 'angerEnemy', {true,{'rolelist','typeid', 'roleId', 'maxhp', 'posindex', 'level', 'attr', {false,{'spellId','skillId', 'level', }},{true,{'passiveskill','skillId', 'level', }},'name', 'immune', 'effectActive', 'effectPassive', }},}
		}
	end,
	[0x1504] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', 'v4', },
			{'userid', 'starlevel', 'starExp', }
		}
	end,
	[0x4520] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 's', 'v4', 'v4', 'v4', 's', 's', 'v4', 'v4', 'v4', 's', 's', 'v4', 'v4', },
			{'lastOpenTime', 'name', 'power', 'useCoin', 'framId', 'serverName', 'formation', 'myRank', 'serverUseCoin', 'serverFramId', 'serverPlayerName', 'serverServerName', 'serverRank', 'serverPower', }
		}
	end,
	[0x1D60] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 's', 'v4', 'v8', 'v8', 'v4', 'v4', },
			{'messageId', 'content', 'intervalTime', 'beginTime', 'endTime', 'repeatTime', 'priority', }
		}
	end,
	[0x1C01] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', }},{false,{'v4', 'b', 'v4', 'v4', }},},
			{{true,{'element','resType', 'resId', 'number', }},{false,{'state','cardType', 'firstGet', 'freeTimes', 'cdTime', }},}
		}
	end,
	[0x5601] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x7F00] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {false,{'v4', {true,{'v4', 'v4', 'v4', }},}},},
			{'statusCode', {false,{'reward','type', {true,{'items','type', 'number', 'itemId', }},}},}
		}
	end,
	[0x4004] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v8', 'v4', 'v4', 's', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 's', 's', 'v4', 'v4', }},'v4', 'v4', 'v4', 'v8', 'v4', 'v4', },
			{{true,{'rankInfo','ranking', 'playerId', 'instanceId', 'goodsId', 'value', 'name', 'playerLevel', 'vipLevel', 'goodNum', 'intensifyLevel', 'starLevel', 'gemId', 'baseAttribute', 'extraAttribute', 'profession', 'headPicFrame', }},'lastValue', 'myRanking', 'myBestValue', 'topInstanceId', 'topGoodsId', 'praiseCount', }
		}
	end,
	[0x1400] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'level', 'killcount', 'totalkillcount', }
		}
	end,
	[0x0e31] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', 'tv4', },
			{'all', 'module', }
		}
	end,
	[0x0F23] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{{true,{{true,{'v4', 'v4', 'v4', {true,{'v4', 'v4', }},{true,{'v4', 'v4', }},{true,{'v4', 'b', 'v4', 'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', 'v4', }},{false,{'v4', 'v4', }},}},{true,{'v4', 'v4', }},{true,{'v4', 'b', 'v4', 'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', 'v4', }},'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', 'v4', }},'v4', }},'b', 'v4', },
			{{true,{'rounds',{true,{'action',{true,{'target','position', 'effectType', 'effectValue', {true,{'passiveEffect','type', 'value', }},{true,{'activeEffect','type', 'value', }},{true,{'newState','fromPos', 'stateTrigger', 'triggerId', 'stateId', 'stateLevel', 'result', }},{true,{'lostState','position', 'stateId', 'repeatNum', }},{true,{'stateCycle','position', 'stateId', 'effectType', 'effectValue', }},{false,{'deepHurt','type', 'value', }},}},{true,{'skill','skillId', 'level', }},{true,{'newState','fromPos', 'stateTrigger', 'triggerId', 'stateId', 'stateLevel', 'result', }},{true,{'lostState','position', 'stateId', 'repeatNum', }},{true,{'stateCycle','position', 'stateId', 'effectType', 'effectValue', }},'type', 'fromPos', }},{true,{'lostState','position', 'stateId', 'repeatNum', }},{true,{'stateCycle','position', 'stateId', 'effectType', 'effectValue', }},'roundIndex', }},'win', 'totle', }
		}
	end,
	[0x1D03] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 'v4', 'v4', },
			{'playerName', 'gemId', 'level', }
		}
	end,
	[0x4084] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', }},'v4', 'v4', },
			{{true,{'infos','guildId', 'name', 'incBoom', }},'myGuildRank', 'incBoom', }
		}
	end,
	[0x4705] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', 's', {true,{'v4', 'v4', 'v4', }},'v8', }},},
			{{false,{'recordList','playerId', 'playerName', {true,{'rewardList','resType', 'resId', 'number', }},'createTime', }},}
		}
	end,
	[0x4060] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'targetId', }
		}
	end,
	[0x4011] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v4', }},},
			{'last', 'myIntegral', 'myRanking', 'betterRewardValue', 'rewardId', {true,{'rankInfo','rewardIndex', 'minIntegral', 'maxIntegral', }},}
		}
	end,
	[0x2503] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'b', }},},
			{{true,{'swithList','factionId', 'isOpen', }},}
		}
	end,
	[0x1722] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', }},},
			{{true,{'star','sectionId', 'star', 'passLimit', }},}
		}
	end,
	[0x2502] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'power', }
		}
	end,
	[0x4900] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5200] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'id', 'breachLevel', }
		}
	end,
	[0x0F21] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{{true,{{true,{'v4', 'v4', 'v4', {true,{'v4', 'v4', }},{true,{'v4', 'v4', }},{true,{'v4', 'b', 'v4', 'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', 'v4', }},{false,{'v4', 'v4', }},}},{true,{'v4', 'v4', }},{true,{'v4', 'b', 'v4', 'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', 'v4', }},'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', 'v4', }},'v4', }},{true,{'v4', 'v4', }},'tv4', 'b', },
			{{true,{'round',{true,{'action',{true,{'target','position', 'effectType', 'effectValue', {true,{'passiveEffect','type', 'value', }},{true,{'activeEffect','type', 'value', }},{true,{'newState','fromPos', 'stateTrigger', 'triggerId', 'stateId', 'stateLevel', 'result', }},{true,{'lostState','position', 'stateId', 'repeatNum', }},{true,{'stateCycle','position', 'stateId', 'effectType', 'effectValue', }},{false,{'deepHurt','type', 'value', }},}},{true,{'skill','skillId', 'level', }},{true,{'newState','fromPos', 'stateTrigger', 'triggerId', 'stateId', 'stateLevel', 'result', }},{true,{'lostState','position', 'stateId', 'repeatNum', }},{true,{'stateCycle','position', 'stateId', 'effectType', 'effectValue', }},'type', 'fromPos', }},{true,{'lostState','position', 'stateId', 'repeatNum', }},{true,{'stateCycle','position', 'stateId', 'effectType', 'effectValue', }},'roundIndex', }},{true,{'lastHp','position', 'currentHp', }},'energy', 'win', }
		}
	end,
	[0x3230] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v4', }},}},},
			{{true,{'result','sectionId', 'exp', 'oldLevel', 'currentLevel', 'coin', {true,{'item','type', 'number', 'itemId', }},}},}
		}
	end,
	[0x1061] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', },
			{'itemId', 'num', }
		}
	end,
	[0x4703] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v4', 's', {true,{'v4', 'v4', 'v4', }},'v8', }},},
			{'type', {true,{'recordList','playerId', 'playerName', {true,{'rewardList','resType', 'resId', 'number', }},'createTime', }},}
		}
	end,
	[0x1315] = function()
		return {
			{"net.NetHelper", "receive"},
			{{false,{'v4', 'v4', 's', 'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v8', 'v4', 's', 'v4', {true,{'v4', 'v4', 'v4', 'v4', {true,{'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},}},{true,{'v4', 'v4', 'v4', }},{true,{'v4', 'v4', 'v4', }},'v4', 'tv4', {true,{'v4', 'v4', }},'v4', 'v4', {true,{'v4', 'v4', 'v4', }},'s', 's', 's', {true,{'v8', 'v4', 'v8', 'v4', 'v4', {true,{'v4', 'v4', }},}},'v4', }},{true,{{false,{'v4', 'v4', }},'b', 'v4', }},'v4', 'v4', }},'v4', },
			{{false,{'player','playerId', 'profession', 'name', 'level', 'vipLevel', 'power', {true,{'warside','id', 'level', 'curexp', 'power', 'attributes', 'warIndex', {true,{'equipment','id', 'level', 'quality', 'refineLevel', {true,{'gem','pos', 'id', }},{true,{'recast','quality', 'ratio', 'index', }},}},{true,{'book','templateId', 'level', 'attribute', }},{true,{'meridians','index', 'level', 'attribute', }},'starlevel', 'fateIds', {true,{'spellId','skillId', 'level', }},'quality', 'martialLevel', {true,{'martial','id', 'position', 'enchantLevel', }},'immune', 'effectActive', 'effectPassive', {true,{'bibleInfo','instanceId', 'id', 'roleId', 'level', 'breachLevel', {true,{'essential','pos', 'id', }},}},'forgingQuality', }},{true,{'spell',{false,{'spellId','skillId', 'level', }},'choice', 'sid', }},'icon', 'headPicFrame', }},'starshards', }
		}
	end,
	[0x1314] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'times', }
		}
	end,
	[0x5401] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', 'v8', {true,{'v4', 'v4', 'v4', 'v4', }},},
			{'roleId', 'todayCount', 'rewardDay', 'rewardTime', {true,{'info','roleId', 'roleNum', 'roleSycee', 'isGetReward', }},}
		}
	end,
	[0x5012] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x0e28] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v8', 'v4', }},},
			{'capacity', {true,{'configure','userId', 'index', }},}
		}
	end,
	[0x1815] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 'v8', 'v4', 'v4', },
			{'buffStr', 'cdLeaveTime', 'buildLevel', 'status', }
		}
	end,
	[0x1a05] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'b', }},},
			{{true,{'rewardList','id', 'isHaveGot', }},}
		}
	end,
	[0x1308] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1a11] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'enable', }
		}
	end,
	[0x4424] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4903] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'tv4', 'v4', 'v4', }},},
			{{true,{'gameLevel','sectionId', 'formationId', 'options', 'choice', 'score', }},}
		}
	end,
	[0x5704] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 's', 's', 'v4', 'v4', 's', 's', }},},
			{{true,{'infos','round', 'index', 'atkGuildId', 'atkGuildName', 'atkBannerId', 'winGuildId', 'defGuildId', 'defGuildName', 'defBannerId', }},}
		}
	end,
	[0x180D] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'isSuccess', }
		}
	end,
	[0x1D42] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'b', 'v8', 'v4', 'v4', 'v4', 'v4', {false,{'v4', 's', 'v4', 'v4', 'v4', 'v4', }},{false,{'v4', 's', 'v4', 'v4', 'v4', 'v4', }},}},},
			{{true,{'report','reportId', 'fightType', 'win', 'time', 'ranking', 'fromRank', 'power', 'targetPower', {false,{'fromRole','playerId', 'name', 'profession', 'level', 'vipLevel', 'power', }},{false,{'targetRole','playerId', 'name', 'profession', 'level', 'vipLevel', 'power', }},}},}
		}
	end,
	[0x4925] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', },
			{'chestGotMark', }
		}
	end,
	[0x441a] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v8', {true,{'v4', 'b', {true,{'v4', 'v4', 'v4', }},}},'b', 'v8', 's', 'v4', }},{true,{'v4', 'v4', {true,{'v4', 'v4', }},'tv4', }},},
			{{true,{'guildZones','zoneId', 'resetCount', 'lockPlayerId', 'lockTime', {true,{'checkpoints','checkpointId', 'pass', {true,{'states','index', 'hp', 'maxHp', }},}},'pass', 'bastPassTime', 'lockPlayerName', 'profession', }},{true,{'playerZones','zoneId', 'challengeCount', {true,{'checkpoints','checkpointId', 'hurt', }},'dropAwards', }},}
		}
	end,
	[0x5163] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', {true,{'v8', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 's', 's', 's', 's', 's', 'v4', }},{true,{'v4', 'v4', 'v8', 'v4', }},}},},
			{{true,{'team','fromId', 'useType', {true,{'roleDetails','instanceId', 'position', 'roleId', 'level', 'martialLevel', 'starlevel', 'power', 'hp', 'spell', 'attributes', 'immune', 'effectActive', 'effectPassive', 'quality', }},{true,{'assistant','position', 'roleId', 'instanceId', 'quality', }},}},}
		}
	end,
	[0x4515] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 's', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 's', }},'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 's', 's', {true,{'s', 'v4', 's', 'v4', 'b', 'v8', 'v4', 'v4', 'v4', 'v4', 'v4', }},},
			{{true,{'ranks','playerId', 'name', 'score', 'atkWin', 'atkLost', 'defWin', 'defLost', 'atkWinStreak', 'defWinStreak', 'serverName', }},'myRank', 'score', 'atkWin', 'atkLost', 'defWin', 'defLost', 'atkWinStreak', 'defWinStreak', 'atkFormation', 'defFromation', {true,{'replays','atkName', 'atkRank', 'defNam', 'defRank', 'atkWin', 'createTime', 'replayId', 'atkUseIcon', 'atkFrameId', 'defUseIcon', 'defFrameId', }},}
		}
	end,
	[0x500F] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1D0C] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 's', 'v4', 'v4', 'v4', }},},
			{{true,{'rankingInfo','playerId', 'displayId', 'name', 'level', 'vipLevel', 'totalDamage', }},}
		}
	end,
	[0x1503] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v8', 'v4', 'v4', 'v8', },
			{'targetRoleID', 'targetRoleExp', 'targetRoleLev', 'transferRoleID', }
		}
	end,
	[0x7f30] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x1D33] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 's', },
			{'type', 'context', }
		}
	end,
	[0x4429] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', },
			{'bannerId', }
		}
	end,
	[0x0e41] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4','s', 'v4', 'v8', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v8', 's', 'v8', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 'v4', },
			{'playerId', 'profession', 'sex','name', 'level', 'coin', 'exp', 'inspiration', 'sycee', 'vipLevel', 'errantry', 'beginnersGuide', 'totalRecharge', 'serverTime', 'openlist', 'registTime', 'properties', 'integral', 'eggScore', 'jingLu', 'climbStar', 'useIcon', 'headPicFrame', 'experience', 'lowHonor', 'seniorHonor', }
		}
	end,
	[0x1D70] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 's', 'v4', },
			{'playerId', 'name', 'type', }
		}
	end,
	[0x4701] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', 'v4', 'v4', 'v4', 'v4', 'v4', 's', }},},
			{{true,{'configList','type', 'resType', 'resId', 'number', 'score', 'freeTime', 'reward', }},}
		}
	end,
	[0x1D0D] = function()
		return {
			{"net.NetHelper", "receive"},
			{'s', 's', 'v4', },
			{'oldName', 'newName', 'ranking', }
		}
	end,
	[0x1905] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v4', 'v4', },
			{'type', 'commodityId', 'num', }
		}
	end,
	[0x6001] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v8', 'v8', 'v8', },
			{'result', 'roleId', 'bible', 'drop', }
		}
	end,
	[0x3304] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4', {true,{'v4', 'v4', 's', 's', }},}},},
			{{true,{'rankList','type', {true,{'rank','playerId', 'rankValue', 'name', 'otherDisplay', }},}},}
		}
	end,
	[0x1040] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{'v4',{false,{'v8', 'v4', 'v4', 'v4', 's', 's', 'v4', 'v4', {true,{'v4', 'v4', }},'v4', 'v4', 'v4', {true,{'v4', 'v4', 'v4', }},}},{false,{'v8', 'v4', }},}},},
			{{true,{'changedList','type',{false,{'equipment','userid', 'id', 'level', 'quality', 'base_attr', 'extra_attr', 'grow', 'holeNum', {true,{'gem','pos', 'id', }},'star', 'starFailFix', 'refineLevel', {true,{'recast','quality', 'ratio', 'index', }},}},{false,{'item','id', 'num', }},}},}
		}
	end,
	[0x4426] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x4300] = function()
		return {
			{"net.NetHelper", "receive"},
			{{true,{{false,{'v4', 's', 'v4', 'v4', 'v8', 'v4', 'v4', 'b', 'v4', 's', 'v4', 'v4', 'v4', }},'b', 'b', }},'tv4', 'tv4', 'tv4', },
			{{true,{'friends',{false,{'info','playerId', 'name', 'vip', 'power', 'lastLoginTime', 'profession', 'level', 'online', 'guildId', 'guildName', 'minePower', 'icon', 'headPicFrame', }},'give', 'assistantGive', }},'givePlayers', 'drawPlayers', 'drawAssistantPlayers', }
		}
	end,
	[0x1303] = function()
		return {
			{"net.NetHelper", "receive"},
			{'b', },
			{'success', }
		}
	end,
	[0x1811] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v8', 'v4', 'v4', {true,{'v4', 'v4', 'v4', 'v4', 'v4', }},},
			{'buildLevel', 'cdLeaveTime', 'leaveRefleshNum', 'dayRefleshNum', {true,{'exchangeList','type', 'number', 'itemId', 'price', 'status', }},}
		}
	end,
	[0x6009] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', 'v8', 'v4', },
			{'result', 'instanceId', 'id', }
		}
	end,
	[0x1a10] = function()
		return {
			{"net.NetHelper", "receive"},
			{},
			{}
		}
	end,
	[0x5130] = function()
		return {
			{"net.NetHelper", "receive"},
			{'v4', {true,{'v8', 'v4', }},{true,{'v4', 'v4', 'v8', 'v4', }},'v8', },
			{'type', {true,{'role','instanceId', 'position', }},{true,{'assistant','position', 'roleId', 'instanceId', 'quality', }},'employRole', }
		}
	end,
}
return tblProto