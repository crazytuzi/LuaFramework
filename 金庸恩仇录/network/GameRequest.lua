GameRequest = {}
local _network = require("utility.GameHTTPNetWork").new()
local function request(msg, callback, errcallback, url)
	msg.acc = game.player.m_uid
	msg.serverKey = game.player.m_serverKey
	_network:SendRequest(1, msg, callback, errcallback, url)
end

--英雄
GameRequest.hero = {
list = function (param, callback)
	local msg = {
	m = "packet",
	a = "list",
	t = 8
	}
	request(msg, callback)
end
}

GameRequest.heroPart = {
list = function (param, callback)
	local msg = {
	m = "packet",
	a = "list",
	t = 5
	}
	request(msg, callback)
end
}

--好友聊天
GameRequest.friend = {
updateChatList = function (param)
	local _callback = param.callback
	local msg = {
	m = "friend",
	a = "updateChatList"
	}
	request(msg, _callback, param.errback)
end
}

--武学技能请求模块
GameRequest.skill = {
list = function (param, callback)
	local msg = {
	m = "packet",
	a = "list",
	t = "4"
	}
	request(msg, callback)
end,
sell = function (param, callback)
	local ids = ""
	for _, v in ipairs(param.ids) do
		ids = ids .. tostring(v) .. ","
	end
	if string.sub(ids, string.len(ids)) == "," then
		ids = string.sub(ids, 1, string.len(ids) - 1)
	end
	local msg = {
	m = "gong",
	a = "sell",
	cids = ids
	}
	request(msg, callback)
end,
qianghua = function (param, callback)
	local msg = {
	m = "gong",
	a = "lvUp",
	op = param.op,
	cids = param.cids
	}
	request(msg, callback)
end,
refine = function (param, callback)
	local msg = {
	m = "gong",
	a = "propUp",
	op = param.op,
	id = param.id
	}
	request(msg, callback)
end
}

--装备请求模块
GameRequest.equip = {
list = function (param, callback)
	local msg = {
	m = "packet",
	a = "list",
	t = "1"
	}
	request(msg, callback)
end,
qianghua = function (param, callback)
	local msg = {
	m = "equip",
	a = "lvUp",
	id = param.id,
	auto = param.auto
	}
	request(msg, callback)
end,
xlstate = function (param, callback)
	local msg = {
	m = "equip",
	a = "propState",
	id = param.id
	}
	request(msg, callback)
end,
xl = function (param, callback)
	local msg = {
	m = "equip",
	a = "prop",
	id = param.id,
	t = param.t,
	n = param.num
	}
	request(msg, callback)
end,
replace = function (param, callback)
	local msg = {
	m = "equip",
	a = "propRepl",
	id = param.id
	}
	request(msg, callback)
end
}
GameRequest.equipPart = {
list = function (param, callback)
	local msg = {
	m = "packet",
	a = "list",
	t = "3"
	}
	request(msg, callback)
end
}

--阵容请求模
GameRequest.fmt = {
list = function (param, callback)
	local msg = {
	m = "fmt",
	a = "list",
	pos = "0",
	acc2 = param.acc2
	}
	request(msg, callback)
end,
putOnEquip = function (param, callback)
	assert(param.pos >= 1 and param.pos <= 6, common:getLanguageString("@zhuangbeipos1"))
	assert(1 <= param.subpos and param.subpos <= 4, common:getLanguageString("@zhuangbeipos3"))
	local msg = {
	m = "fmt",
	a = "embattle",
	pos = param.pos,
	subpos = param.subpos,
	id = param.id
	}
	request(msg, callback)
end,
putOnSpirit = function (param, callback)
	assert(param.pos >= 1 and param.pos <= 6, common:getLanguageString("@zhuangbeipos1"))
	assert(param.subpos >= 7 and param.subpos <= 14, common:getLanguageString("@zhuangbeipos2"))
	local msg = {
	m = "fmt",
	a = "embattle",
	pos = tostring(param.pos),
	subpos = tostring(param.subpos),
	id = tostring(param.id)
	}
	request(msg, callback)
end
}

--精元请求模块
GameRequest.spirit = {
list = function (param, callback)
	local msg = {
	m = "packet",
	a = "list",
	t = "6"
	}
	request(msg, callback)
end,
start = function (param, callback)
	local msg = {
	m = "yuan",
	a = "collect",
	acc = "1",
	t = param.t
	}
	request(msg, callback)
end,
upgrade = function (param, callback)
	local msg = {
	m = "yuan",
	a = "lvUp",
	id = param.id,
	ids = param.ids
	}
	request(msg, callback)
end,
converts = function (param)
	local msg = {
	m = "yuan",
	a = "exchangeExp",
	ids = param.ids
	}
	request(msg, param.callback)
end,
resolves = function (param)
	local callback = param.callback
	local msg = {
	m = "yuan",
	a = "exchangeItem",
	count = param.count
	}
	request(msg, callback)
end
}
GameRequest.cheats = {
list = function (param, callback)
	local msg = {
	m = "packet",
	a = "list",
	t = BAG_TYPE.cheats
	}
	request(msg, callback)
end
}

--背包请求模块
GameRequest.packet = {
list = function (param, callback)
	local msg = {
	m = "packet",
	a = "list",
	t = "7"
	}
	request(msg, callback)
end,
gmAdd = function (param, callback)
	local msg = {
	m = "packet",
	a = "gmAdd",
	id = tostring(param.id),
	n = tostring(param.n),
	t = tostring(param.t)
	}
	request(msg, callback)
end
}

--赠送模块
GameRequest.gift = {
list = function (param, callback)
	local msg = {
	m = "packet",
	a = "list",
	t = tostring(BAG_TYPE.lipin)
	}
	request(msg, callback)
end
}
GameRequest.pet = {
list = function (param, callback)
	local msg = {
	m = "packet",
	a = "list",
	t = tostring(BAG_TYPE.chongwu)
	}
	request(msg, callback)
end
}

--广播请求模块
GameRequest.Broadcast = {
-- 获取广播列表
getBroadcastList = function (param)
	local _callback = param.callback
	local msg = {m = "broad", a = "list"}
	request(msg, _callback)
end,

getBIBroadcastList = function (param)
	local _callback = param.callback
	local msg = {
	m = "broad",
	a = "marQueeList",
	channelId = param.channelId,
	serverId = param.serverId,
	chn_flag = game.player.chn_flag or ""
	}
	request(msg, _callback)
end,

-- 刷新广播列表
updateList = function (param)
	local _callback = param.callback
	local msg = {m = "usr", a = "heart"}
	request(msg, _callback)
end,

updateData = function (param)
	local _callback = param.callback
	local msg = {
	m = "usr",
	a = "updateItemType"
	}
	request(msg, _callback)
end
}

--游戏版本请求模块
GameRequest.game = {
version = function (param, callback)
	local msg = {a = "list"}
	request(msg, callback)
end
}

-- 登陆
GameRequest.login = {
list = function (param, callback)
	local msg = {
	m = "usr",
	a = "enter",
	rid = "101",
	name = param.name
	}
	request(msg, callback)
end
}

-- 在线奖励
GameRequest.onlineReward = {
list = function (param, callback)
	local msg = {
	m = "gift",
	a = "onLineCheck"
	}
	request(msg, callback)
end
}
GameRequest.helpLineList = {
list = function (param, callback)
	local msg = {m = "fmt", a = "helpLine"}
	request(msg, callback)
end
}


--获取领奖中心信息
GameRequest.rewardCenter = {
list = function (param, callback)
	local msg = {m = "gift", a = "cList"}
	request(msg, callback)
end
}


--聊天相关
GameRequest.chat = {
--获取聊天信息列表
getList = function (param)
	dump("getlist")
	dump(param)
	local _callback = param.callback
	local msg = {
	m = "chat",
	a = "list",
	para = param.account,
	type = param.type,
	name = param.name,
	lasttime = param.lasttime
	}
	request(msg, _callback)
end,

-- 发送聊天信
sendMsg = function (param)
	local _callback = param.callback
	local msg = {
	m = "chat",
	a = "send",
	recname = param.recname,
	type = param.type,
	msg = param.msg,
	para1 = param.para1,
	para2 = param.para2,
	para3 = param.para3
	}
	request(msg, _callback)
end,

-- 获取未读的消息数
getUnRead = function (param)
	local _callback = param.callback
	local msg = {
	m = "chat",
	a = "unread",
	type = param.type,
	name = param.name
	}
	request(msg, _callback)
end
}

--日志
GameRequest.log = {
send = function (param)
	local _callback = param.callback
	local msg = {
	m = "help",
	a = "clog",
	type = "client_log",
	info = param.log
	}
	request(msg, _callback)
end
}

--世界boss战相关
GameRequest.worldBoss = {
rank = function (param)
	local _callback = param.callback
	local msg = {m = "bossbattle", a = "top"}
	request(msg, _callback)
end,
state = function (param)
	local _callback = param.callback
	local msg = {m = "bossbattle", a = "state"}
	request(msg, _callback)
end,
result = function (param)
	local _callback = param.callback
	local msg = {m = "bossbattle", a = "result"}
	request(msg, _callback)
end
}

-- 帮派
GameRequest.Guild = {
-- 检测活动时间
checkTime = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "checkTime",
	id = param.id
	}
	request(msg, _callback, _errback)
end,
bossState = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "bossState",
	unionId = param.unionId
	}
	request(msg, _callback, _errback)
end,
-- boss活动结果
bossResult = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "bossResult",
	unionId = param.unionId
	}
	request(msg, _callback, _errback)
end,
autoState = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "requireActivity"
	}
	request(msg, _callback, _errback)
end,
cancelAutoState = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "cancelActivity",
	id = param.id
	}
	request(msg, _callback, _errback)
end,
setTimeState = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "setActivity",
	id = param.id,
	time = param.time
	}
	request(msg, _callback, _errback)
end
}
return GameRequest