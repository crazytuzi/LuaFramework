require("data.data_error_error")
RequestHelper = {}
local _network = require("utility.GameHTTPNetWork").new()
local loadingLayer = require("utility.LoadingLayer")
local GameErrorCB = function (errCode)
	if errCode == 100011 then
		device.showAlert(common:getLanguageString("@Hint"), common:getLanguageString("@chongxindl"), common:getLanguageString("@OK"), function (...)
			GameStateManager:ChangeState(GAME_STATE.STATE_VERSIONCHECK)
		end)
	elseif errCode == 100014 then
		device.showAlert(common:getLanguageString("@Hint"), common:getLanguageString("@banbencw"), common:getLanguageString("@OK"), function (...)
			GameStateManager:ChangeState(GAME_STATE.STATE_VERSIONCHECK)
		end)
	elseif errCode == 101 then
		device.showAlert(common:getLanguageString("@Hint"), common:getLanguageString("@HintSDKError"), common:getLanguageString("@OK"), function (...)
			GameStateManager:ChangeState(GAME_STATE.STATE_VERSIONCHECK)
		end)
	elseif errCode == 10000 then
	else
		show_tip_label(data_error_error[errCode].prompt)
	end
end

local function request(msg, callback, errback, url)
	local function cb(data)
		loadingLayer.hide()
		if data.err ~= nil and data.err ~= "" then
			local errStr = common:getLanguageString("@cuowushi") .. data.err
			if data.errCode==99 then
				local errorStr = string.sub(data.err, 12)
				show_tip_label(errorStr)
				return
			end
			if data_error_error[data.errCode] ~= nil then
				GameErrorCB(data.errCode)
			end
			ResMgr.removeMaskLayer()
			if errback ~= nil then
				errback(data)
			end
			return
		end
		if callback then
			callback(data)
		end
	end
	local function onFailed()
		loadingLayer.hide(function ()
			PostNotice(NoticeKey.UNLOCK_BOTTOM)
			ResMgr.removeBefLayer()
			show_tip_label(common:getLanguageString("@wangluoyc"))
		end)
		if errback ~= nil then
			errback(data)
		end
	end
	loadingLayer.start()
	if game.player.m_uid ~= "" then
		msg.acc = game.player.m_uid
		msg.serverKey = game.player.m_serverKey
	end
	_network:SendRequest(1, msg, cb, onFailed, url)
end
RequestHelper.request = request
function RequestHelper.setGuide(param)
	local _callback = param.callback
	local msg = {
	m = "help",
	a = "setGuide",
	guide = param.guide
	}
	request(msg, _callback)
end


function RequestHelper.getGuide(param)
	local _callback = param.callback
	local msg = {m = "help", a = "getGuide"}
	request(msg, _callback)
end

--[[function RequestHelper.getGuide(param)
local _callback = param.callback
local msg = {m = "help", a = "getGuide"}
request(msg, _callback)
end]]

function RequestHelper.getGuessInfo(param)
	local _callback = param.callback
	local msg = {m = "activity", a = "guessinfo"}
	request(msg, _callback)
end
function RequestHelper.guessing(param)
	local _callback = param.callback
	local msg = {m = "activity", a = "guessing"}
	request(msg, _callback)
end
function RequestHelper.guessChoseCard(param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "guesschoose",
	pos = param.pos
	}
	request(msg, _callback)
end
function RequestHelper.buyGuessTime(param)
	local _callback = param.callback
	local msg = {m = "activity", a = "guessbuy"}
	request(msg, _callback)
end
function RequestHelper.getActStatus(param)
	local _callback = param.callback
	local msg = {m = "activity", a = "status"}
	request(msg, _callback)
end
function RequestHelper.buyActTimes(param)
	local _callback = param.callback
	local msg = {
	m = "actbattle",
	a = "actBuy",
	aid = param.aid,
	act = param.act
	}
	request(msg, _callback)
end
function RequestHelper.buyEliteTimes(param)
	local _callback = param.callback
	local msg = {m = "actbattle", a = "buyElite"}
	request(msg, _callback)
end
function RequestHelper.buyBatTimes(param)
	local _callback = param.callback
	local msg = {
	m = "battle",
	a = "batBuy",
	id = param.id,
	act = param.act
	}
	dump(param.errback)
	request(msg, _callback, param.errback)
end
function RequestHelper.buyZhenShenTimes(param)
	local _callback = param.callback
	local msg = {
	m = "actbattle",
	a = "buyRealBodyBattleCnt"
	}
	dump("buyRealBodyBattleCnt")
	request(msg, _callback, param.errback)
end
function RequestHelper.setDramaValue(data)
	local _callback = data.callback
	local msg = {
	m = "help",
	a = "setUserParam",
	type = "helpStoryStep",
	param = data.param
	}
	request(msg, _callback)
end
function RequestHelper.getDramaValue(data)
	local _callback = data.callback
	local msg = {
	m = "help",
	a = "getUserParam",
	type = "helpStoryStep"
	}
	request(msg, _callback)
end
function RequestHelper.getBaseInfo(param)
	local _callback = param.callback
	local msg = {m = "usr", a = "playerInfo"}
	request(msg, _callback)
end
function RequestHelper.getNotice(param)
	local _callback = param.callback
	local msg = {m = "usr", a = "getNotice"}
	request(msg, _callback)
end
function RequestHelper.getBag(param)
	local _callback = param.callback
	local msg = {
	m = "packet",
	a = "list",
	acc = "1",
	t = 7
	}
	request(msg, _callback)
end
function RequestHelper.sell(param)
	local _callback = param.callback
	local ids = ""
	for _, v in ipairs(param.ids) do
		ids = ids .. tostring(v) .. ","
	end
	if string.sub(ids, string.len(ids)) == "," then
		ids = string.sub(ids, 1, string.len(ids) - 1)
	end
	local msg = {
	m = "packet",
	a = "sell",
	acc = "1",
	ids = ids
	}
	request(msg, _callback)
end
function RequestHelper.lockPet(param)
	local _callback = param.callback
	local msg = {
	m = "pet",
	a = "lock",
	cids = param.cids,
	lock = param.lock,
	acc = param.acc
	}
	request(msg, _callback)
end
function RequestHelper.lockHero(param)
	local _callback = param.callback
	local msg = {
	m = "card",
	a = "lock",
	id = param.id,
	lock = param.lock
	}
	request(msg, _callback)
end
function RequestHelper.addToBag(param)
	local _callback = param.callback
	local msg = {
	m = "packet",
	a = "add",
	acc = "1",
	item = param.item
	}
	request(msg, _callback)
end
function RequestHelper.useItem(param)
	local _callback = param.callback
	local msg = {
	m = "packet",
	a = "use",
	id = param.id,
	num = param.num,
	name = param.name
	}
	request(msg, _callback)
end
function RequestHelper.extendBag(param)
	local _callback = param.callback
	local msg = {
	m = "packet",
	a = "extend",
	type = param.type
	}
	request(msg, _callback)
end
function RequestHelper.recrute(param)
	local _callback = param.callback
	local _t = param.t
	local _n = param.n
	local msg = {
	m = "shop",
	a = "wine",
	acc = 1,
	t = _t,
	n = _n
	}
	request(msg, _callback)
end
function RequestHelper.getPubStat(param)
	local _callback = param.callback
	local msg = {
	m = "shop",
	a = "stat",
	acc = 1
	}
	request(msg, _callback)
end
function RequestHelper.getShopList(param)
	local _callback = param.callback
	local msg = {
	m = "shop",
	a = "list",
	acc = 1
	}
	request(msg, _callback)
end
function RequestHelper.buy(param)
	local auto = param.auto or 0
	local _callback = param.callback
	local msg = {
	m = "shop",
	a = "buy",
	id = param.id,
	n = param.n,
	coinType = param.coinType,
	coin = param.coin,
	auto = auto
	}
	request(msg, _callback, param.errback)
end
function RequestHelper.getLevelList(param)
	local _callback = param.callback
	local msg = {
	m = "battle",
	a = "world",
	acc = 1,
	id = param.id
	}
	request(msg, _callback)
end
function RequestHelper.getSubLevelList(param)
	local _callback = param.callback
	local msg = {
	m = "battle",
	a = "field",
	acc = 1,
	id = param.id
	}
	request(msg, _callback)
end
function RequestHelper.getEquipList(param)
	local _callback = param.callback
	local msg = {
	m = "packet",
	a = "list",
	t = 1
	}
	request(msg, _callback)
end
function RequestHelper.sendEquipQianghuaRes(param)
	local _callback = param.callback
	local msg = {
	m = "equip",
	a = "lvUp",
	auto = param.auto,
	id = param.id
	}
	request(msg, _callback)
end
function RequestHelper.sendEquipXiLianPropRes(param)
	local _callback = param.callback
	local msg = {
	m = "equip",
	a = "propState",
	id = param.id
	}
	request(msg, _callback)
end
function RequestHelper.sendEquipXiLianRes(param)
	local _callback = param.callback
	local msg = {
	m = "equip",
	a = "prop",
	t = param.t,
	n = param.n,
	id = param.id
	}
	request(msg, _callback)
end
function RequestHelper.getEquipDebrisList(param)
	local _callback = param.callback
	local msg = {
	m = "packet",
	a = "list",
	t = 3
	}
	request(msg, _callback)
end
function RequestHelper.sendHeChengEquipRes(param)
	local _callback = param.callback
	local msg = {
	m = "packet",
	a = "use",
	id = param.id,
	num = param.num
	}
	request(msg, _callback)
end
function RequestHelper.sendTiHuanEquipRes(param)
	local _callback = param.callback
	local msg = {
	m = "equip",
	a = "propRepl",
	id = param.id,
	num = param.num
	}
	request(msg, _callback)
end
function RequestHelper.sendSellEquipRes(param)
	local _callback = param.callback
	local msg = {
	m = "equip",
	a = "sell",
	eids = param.ids
	}
	request(msg, _callback)
end
function RequestHelper.gmAdd(param)
	local _callback = param.callfunc
	local msg = {
	m = "packet",
	a = "gmAdd",
	acc = 1,
	id = tostring(param.id),
	n = tostring(param.n),
	t = tostring(param.t)
	}
	request(msg, _callback)
end
function RequestHelper.gmAddAllCard(param)
	local _callback = param.callfunc
	local msg = {m = "gmCard", a = "allCard"}
	request(msg, _callback)
end
function RequestHelper.gmResetAllCounts(param)
	local _callback = param.callfunc
	local msg = {
	m = "help",
	a = "setUserParam",
	type = "actPveCnts",
	param = {
	0,
	0,
	0
	}
	}
	request(msg, _callback)
end
function RequestHelper.gmAddStar(param)
	local _callback = param.callfunc
	local msg = {
	m = "channel",
	a = "addStar",
	num = "1000"
	}
	request(msg, _callback)
end
function RequestHelper.getPetList(param)
	local _callback = param.callback
	local msg = {
	m = "packet",
	a = "list",
	t = tostring(BAG_TYPE.chongwu)
	}
	request(msg, _callback)
end
function RequestHelper.getPetDebrisList(param)
	local _callback = param.callback
	local msg = {
	m = "packet",
	a = "list",
	t = tostring(BAG_TYPE.chongwu_suipian)
	}
	request(msg, _callback)
end
function RequestHelper.getHeroList(param)
	local _callback = param.callback
	local msg = {
	m = "packet",
	a = "list",
	t = "8"
	}
	request(msg, _callback)
end
RequestHelper.split = {
status = function (param)
	local _callback = param.callback
	local msg = {
	m = "furnace",
	a = "flist",
	acc = 1
	}
	request(msg, _callback)
end,
refine = function (param)
	local _callback = param.callback
	local msg = {
	m = "furnace",
	a = "furnace",
	type = param.t,
	ids = param.ids
	}
	request(msg, _callback)
end,
reborn = function (param)
	local _callback = param.callback
	local msg = {
	m = "furnace",
	a = "reborn",
	type = param.t,
	id = param.id
	}
	request(msg, _callback)
end
}
function RequestHelper.getHeroDebrisList(param)
	local _callback = param.callback
	local msg = {
	m = "packet",
	a = "list",
	t = 5
	}
	request(msg, _callback)
end
function RequestHelper.getDebrisList(param)
	local _callback = param.callback
	if param.type == nil then
		show_tip_label(data_error_error[-2].prompt)
		return
	end
	local msg = {
	m = "packet",
	a = "list",
	t = param.type
	}
	request(msg, _callback, param.errback)
end
function RequestHelper.getLimitInitData(param)
	local _callback = param.callback
	local msg = {m = "activity", a = "limitCard"}
	request(msg, _callback)
end
function RequestHelper.drawLimitHero(param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "LimitDraw",
	isFree = param.isFree
	}
	request(msg, _callback)
end
function RequestHelper.sendHeChengHeroRes(param)
	local _callback = param.callback
	local msg = {
	m = "packet",
	a = "use",
	id = param.id,
	num = param.num
	}
	request(msg, _callback)
end
function RequestHelper.sendSellCardRes(param)
	local _callback = param.callback
	local msg = {
	m = "card",
	a = "sell",
	cids = param.ids
	}
	request(msg, _callback)
end
function RequestHelper.sendCheckPetInfo(param)
	local _callback = param.callback
	local msg = {
	m = "pet",
	a = "msg",
	cids = param.id
	}
	request(msg, _callback)
end
function RequestHelper.sendSellPetRes(param)
	local _callback = param.callback
	local msg = {
	m = "pet",
	a = "sell",
	cids = param.ids
	}
	request(msg, _callback)
end
RequestHelper.formation = {
list = function (param)
	local _callback = param.callback
	local msg = {
	m = "fmt",
	a = "list",
	pos = "0",
	acc2 = param.acc2
	}
	request(msg, _callback)
end,
openBoxReq = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "LimitChests",
	acc = param.acc,
	index = param.index or -1
	}
	request(msg, _callback)
end,
putOnEquip = function (param)
	assert(param.pos >= 1 and param.pos <= 6, common:getLanguageString("@zhuangbeipos1"))
	local _callback = param.callback
	local msg = {
	m = "fmt",
	a = "embattle",
	pos = param.pos,
	subpos = param.subpos,
	id = param.id
	}
	request(msg, _callback)
end,
putOnSpirit = function (param)
	assert(param.pos >= 1 and param.pos <= 6, common:getLanguageString("@zhuangbeipos1"))
	assert(param.subpos >= 7 and param.subpos <= 14, common:getLanguageString("@zhuangbeipos2"))
	local _callback = param.callback
	local msg = {
	m = "fmt",
	a = "embattle",
	pos = tostring(param.pos),
	subpos = tostring(param.subpos),
	id = tostring(param.id)
	}
	request(msg, _callback)
end,
putOnPet = function (param)
	local _callback = param.callback
	local msg = {
	m = "fmt",
	a = "embattle",
	pos = param.pos,
	subpos = 15,
	id = param.id
	}
	request(msg, _callback)
end,
putOnCheats = function (param)
	assert(param.pos >= 1 and param.pos <= 6, common:getLanguageString("@zhuangbeipos1"))
	local _callback = param.callback
	local msg = {
	m = "fmt",
	a = "embattle",
	pos = param.pos,
	subpos = param.subpos,
	id = param.id
	}
	request(msg, _callback)
end,
set = function (param)
	local _callback = param.callback
	local msg = {
	m = "fmt",
	a = "embattle",
	subpos = "0",
	id = param.id,
	pos = param.pos
	}
	request(msg, _callback)
end,
unload = function (param)
	local _callback = param.callback
	local msg = {
	m = "fmt",
	a = "unload",
	pos = param.pos
	}
	request(msg, _callback)
end,
enemyList = function (param)
	local _callback = param.callback
	local msg = {
	m = "fmt",
	a = "list",
	pos = "0",
	acc2 = param.enemyAcc
	}
	request(msg, _callback)
end,
quickEquip = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "fmt",
	a = "fastChangeEquip",
	pos = param.pos,
	cardId = param.cardId,
	type = param.type
	}
	request(msg, _callback, _errback)
end
}
function RequestHelper.getPetSkillLvUpRes(param)
	local _callback = param.callback
	local msg = {
	m = "pet",
	a = "upPetSkl",
	id = param.id,
	sklId = param.sklId
	}
	request(msg, _callback)
end
function RequestHelper.getPetUsingItem(param)
	local _callback = param.callback
	local msg = {
	m = "pet",
	a = "clsItemInfo"
	}
	request(msg, _callback)
end
function RequestHelper.getPetJinJieRes(param)
	local _callback = param.callback
	local msg = {
	m = "pet",
	a = "clsUp",
	op = param.op,
	id = param.id
	}
	request(msg, _callback)
end
function RequestHelper.getJinJieRes(param)
	local _callback = param.callback
	local msg = {
	m = "card",
	a = "clsUp",
	op = param.op,
	id = param.id
	}
	request(msg, _callback)
end

function RequestHelper.getGilgulRes(param)
	local _callback = param.callback
	local msg = {
	m = "card",
	a = "glvUp",
	id = param.id,
	op = param.op,
	}
	request(msg, _callback)
end

function RequestHelper.getArenaData(param)
	local _callback = param.callback
	local msg = {m = "arena", a = "list"}
	request(msg, _callback)
end
function RequestHelper.getArenaRank(param)
	local _callback = param.callback
	local msg = {m = "arena", a = "rlist"}
	request(msg, _callback)
end
function RequestHelper.getCardQianghuaRes(param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "card",
	a = "lvUp",
	op = param.op,
	cids = param.cids
	}
	request(msg, _callback, _errback)
end

function RequestHelper.getPetQianghuaRes(param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "pet",
	a = "lvUp",
	op = param.op,
	petId = param.petId,
	count = param.count
	}
	request(msg, _callback, _errback)
end

RequestHelper.hero = {
info = function (param)
	local _callback = param.callback
	local msg = {
	m = "card",
	a = "msg",
	cid = param.cid
	}
	request(msg, _callback)
end,
shentongReset = function (param)
	local _callback = param.callback
	local msg = {
	m = "card",
	a = "shenReset",
	id = param.cid
	}
	request(msg, _callback)
end,
shentongUpgrade = function (param)
	local _callback = param.callback
	local msg = {
	m = "card",
	a = "shenUp",
	id = param.cid,
	ind = param.ind
	}
	request(msg, _callback)
end
}
RequestHelper.spirit = {
list = function (param)
	local _callback = param.callback
	local msg = {
	m = "packet",
	a = "list",
	t = "6"
	}
	request(msg, _callback)
end,
start = function (param)
	local _callback = param.callback
	local msg = {
	m = "yuan",
	a = "collect",
	acc = "1",
	t = param.t
	}
	request(msg, _callback)
end,
upgrade = function (param)
	local _callback = param.callback
	local msg = {
	m = "yuan",
	a = "lvUp",
	id = param.id,
	ids = param.ids
	}
	request(msg, _callback)
end,
nbstart = function (param)
	local _callback = param.callback
	local msg = {m = "yuan", a = "useItem"}
	request(msg, _callback)
end
}
RequestHelper.equip = {
list = function (param)
	local _callback = param.callback
	local msg = {
	m = "packet",
	a = "list",
	t = "1"
	}
	request(msg, _callback)
end
}
function RequestHelper.getXiaHunQianghuaRes(param)
	local _callback = param.callback
	local msg = {
	m = "card",
	a = "soulUp",
	op = param.op,
	id = param.id,
	n = param.n
	}
	request(msg, _callback)
end
function RequestHelper.sendZhenRongRes(param)
	local _callback = param.callback
	local msg = {
	m = "fmt",
	a = "embattle",
	subpos = "0",
	id = param.id,
	pos = param.pos
	}
	request(msg, _callback)
end
function RequestHelper.getKongFuList(param)
	local _callback = param.callback
	local msg = {
	m = "packet",
	a = "list",
	t = "4"
	}
	request(msg, _callback)
end
function RequestHelper.sendKongFuQiangHuaRes(param)
	local _callback = param.callback
	local msg = {
	m = "gong",
	a = "lvUp",
	op = param.op,
	cids = param.cids
	}
	request(msg, _callback)
end
function RequestHelper.HuoDongFuBenList(param)
	dump(param)
	local _callback = param.callback
	local msg = {
	m = "actbattle",
	a = "actPveState"
	}
	request(msg, _callback)
end
function RequestHelper.JingyingFuBenList(param)
	dump(param)
	local _callback = param.callback
	local msg = {m = "actbattle", a = "elite"}
	request(msg, _callback)
end
function RequestHelper.JingyingFuBenBattle(param)
	local _callback = param.callback
	local msg = {
	m = "actbattle",
	a = "elitePve",
	id = param.id,
	npc = param.npc
	}
	request(msg, _callback)
end
function RequestHelper.getItemSaleData(param)
	local _callback = param.callback
	local msg = {
	m = "shop",
	a = "oList",
	id = param.id
	}
	request(msg, _callback)
end
RequestHelper.channel = {
info = function (param)
	local _callback = param.callback
	local msg = {m = "channel", a = "main"}
	request(msg, _callback)
end,
upgrade = function (param)
	local _callback = param.callback
	local msg = {
	m = "channel",
	a = "lvUp",
	t = param.t
	}
	request(msg, _callback)
end,
reset = function (param)
	local _callback = param.callback
	local msg = {m = "channel", a = "reset"}
	request(msg, _callback)
end
}
function RequestHelper.ArenaBattle(param)
	local _callback = param.callback
	local msg = {
	m = "arena",
	a = "dare",
	rank = param.rank
	}
	request(msg, _callback)
end
function RequestHelper.JingYingBattle(param)
	local _callback = param.callback
	local msg = {
	m = "actbattle",
	a = "elitePve",
	id = param.id
	}
	request(msg, _callback)
end
function RequestHelper.HuoDongBattle(param)
	local _callback = param.callback
	local msg = {
	m = "actbattle",
	a = "actPve",
	aid = param.aid,
	npc = param.npc
	}
	request(msg, _callback)
end
RequestHelper.dailyLoginReward = {
getInfo = function (param)
	local _callback = param.callback
	local msg = {m = "gift", a = "signCheck"}
	request(msg, _callback)
end,
getReward = function (param)
	local _callback = param.callback
	local msg = {
	m = "gift",
	a = "signGet",
	day = param.day
	}
	request(msg, _callback)
end
}
RequestHelper.levelReward = {
getInfo = function (param)
	local _callback = param.callback
	local msg = {m = "gift", a = "lvCheck"}
	request(msg, _callback)
end,
getReward = function (param)
	local _callback = param.callback
	local msg = {
	m = "gift",
	a = "lvGet",
	lv = param.level
	}
	request(msg, _callback)
end
}
RequestHelper.kaifuReward = {
getInfo = function (param)
	local _callback = param.callback
	local msg = {m = "logingift", a = "loginCheck"}
	request(msg, _callback)
end,
getReward = function (param)
	local _callback = param.callback
	local msg = {
	m = "logingift",
	a = "getGift",
	day = param.day
	}
	request(msg, _callback)
end
}
RequestHelper.game = {
login = function (param)
	local _callback = param.callback
	local msg = {
	m = "usr",
	a = "enter",
	rid = param.roleId,
	name = param.name
	}
	request(msg, _callback)
end,
register = function (param)
	dump(param)
	local deviceinfo = CSDKShell.GetDeviceInfo()
	dump(deviceinfo)
	local _callback = param.callback
	local msg = {
	a = "reg",
	m = "usr",
	SessionId = param.sessionId,
	uac = param.acc,
	name = param.name,
	rid = param.rid,
	deviceinfo = deviceinfo,
	sid = game.player.m_serverID,
	loginName = game.player.m_loginName,
	platformID = param.platformID,
	chn_flag = param.chn_flag or ""
	}
	request(msg, _callback)
end,
loginGame = function (param)
	dump(param)
	local deviceinfo = CSDKShell.GetDeviceInfo()
	dump(deviceinfo)
	local _callback = param.callback
	local msg = {
	a = "login",
	m = "usr",
	SessionId = param.sessionId,
	uac = param.uin,
	deviceinfo = deviceinfo,
	loginName = game.player.m_loginName,
	platformID = param.platformID,
	chn_flag = param.chn_flag or ""
	}
	request(msg, _callback)
end
}
RequestHelper.rewardCenter = {
getInfo = function (param)
	local _callback = param.callback
	local msg = {m = "gift", a = "cList"}
	request(msg, _callback)
end,
getReward = function (param)
	local t = 1
	if param.isGetAll then
		t = 2
	end
	local _callback = param.callback
	local msg = {
	m = "gift",
	a = "cGet",
	t = t,
	objId = param.objId
	}
	request(msg, _callback)
end
}
RequestHelper.onlineReward = {
getRewardList = function (param)
	local _callback = param.callback
	local msg = {
	m = "gift",
	a = "onLineCheck"
	}
	request(msg, _callback)
end,
getReward = function (param)
	local _callback = param.callback
	local msg = {m = "gift", a = "onLineGet"}
	request(msg, _callback)
end
}
function RequestHelper.sendRankListReq(param)
	local _callback = param.callback
	local msg = {
	m = "rank",
	a = "list",
	type = param.listType
	}
	request(msg, _callback)
end
function RequestHelper.getRewardCenter(param)
	local _callback = param.callback
	local msg = {m = "arena", a = "reward"}
	request(msg, _callback)
end
function RequestHelper.sendCheckRankList(param)
	local _callback = param.callback
	local msg = {
	m = "arena",
	a = "check",
	acc2 = param.acc2,
	rank = param.rank
	}
	request(msg, _callback)
end
function RequestHelper.getPlayerInfo(param)
	local _callback = param.callback
	local msg = {m = "card", a = "uinfo"}
	request(msg, _callback)
end
RequestHelper.nbHuodong = {
state = function (param)
	local _callback = param.callback
	local msg = {m = "usr", a = "sleep"}
	request(msg, _callback)
end,
sleep = function (param)
	local _callback = param.callback
	local msg = {m = "usr", a = "sleepOp"}
	request(msg, _callback)
end
}
RequestHelper.Duobao = {
getNeiWaiGongList = function (param)
	local _callback = param.callback
	local msg = {m = "snatch", a = "list"}
	request(msg, _callback)
end,
synth = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "snatch",
	a = "synth",
	id = param.id,
	t = param.t
	}
	request(msg, _callback, _errback)
end,
getSnatchList = function (param)
	local _callback = param.callback
	local msg = {
	m = "snatch",
	a = "sList",
	id = param.id
	}
	request(msg, _callback)
end,
snatch = function (param)
	local _callback = param.callback
	local msg = {
	m = "snatch",
	a = "snatch",
	id = param.id,
	data = param.data
	}
	request(msg, _callback)
end,
rob10 = function (param)
	local _callback = param.callback
	local msg = {
	m = "snatch",
	a = "snatchTen",
	id = param.id,
	data = param.data
	}
	request(msg, _callback)
end,
useMianzhan = function (param)
	local _callback = param.callback
	local msg = {
	m = "snatch",
	a = "use",
	t = param.t
	}
	request(msg, _callback)
end
}
function RequestHelper.sendNormalBattle(param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "battle",
	a = "pve",
	id = param.id,
	type = param.type
	}
	request(msg, _callback, _errback)
end
RequestHelper.Mail = {
getMailList = function (param)
	local _callback = param.callback
	local msg = {
	m = "mail",
	a = "mlist",
	type = param.type,
	mailId = param.mailId
	}
	request(msg, _callback)
end,
sendMail = function (param)
	local _callback = param.callback
	local msg = {
	m = "mail",
	a = "sendFriend",
	recname = param.recname,
	msg = param.msg
	}
	request(msg, _callback)
end
}
function RequestHelper.getBattleReward(param)
	local _callback = param.callback
	local msg = {
	m = "battle",
	a = "award",
	id = param.id,
	t = param.t
	}
	request(msg, _callback)
end

function RequestHelper.getHandBook(param)
	local _callback = param.callback
	local msg = {m = "handbook", a = "getAll", flag = param.flag}
	request(msg, _callback)
end

RequestHelper.lianzhan = {
clearCDTime = function (param)
	local _callback = param.callback
	local msg = {
	m = "battle",
	a = "cdClear",
	id = param.id,
	t = param.t
	}
	request(msg, _callback)
end,
battle = function (param)
	local _callback = param.callback
	local msg = {
	m = "battle",
	a = "pves",
	id = param.id,
	type = param.type,
	n = param.n
	}
	request(msg, _callback)
end
}
RequestHelper.chat = {
getList = function (param)
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
getGuildId = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {m = "chat", a = "facId"}
	request(msg, _callback, _errback)
end
}
RequestHelper.jianghu = {
list = function (param)
	local _callback = param.callback
	local msg = {m = "road", a = "list"}
	request(msg, _callback)
end,
send = function (param)
	local _callback = param.callback
	local msg = {
	m = "road",
	a = "use",
	cardId = param.cardId,
	itemId = param.itemId,
	multi = param.multi
	}
	request(msg, _callback)
end
}
RequestHelper.exchange = {
getData = function (param)
	local _callback = param.callback
	local msg = {
	m = "arena",
	a = "excList",
	shopType = param.shopType
	}
	request(msg, _callback)
end,
exchange = function (param)
	local _callback = param.callback
	local msg = {
	m = "arena",
	a = "exchange",
	id = param.id,
	shopType = param.shopType,
	num = param.num
	}
	request(msg, _callback)
end
}
function RequestHelper.getCDKeyReward(param)
	local _callback = param.callback
	local msg = {
	m = "gift",
	a = "cdkey",
	pfid = param.pfid,
	cdkey = param.cdkey,
	chn_flag = param.chn_flag or ""
	}
	request(msg, _callback)
end
RequestHelper.shenmi = {
getData = function (param)
	local _callback = param.callback
	local msg = {
	m = "shenmi",
	a = "list",
	refresh = param.refresh
	}
	request(msg, _callback)
end,
checkTime = function (param)
	local _callback = param.callback
	local msg = {m = "shenmi", a = "verify"}
	request(msg, _callback)
end,
exchange = function (param)
	local _callback = param.callback
	local msg = {
	m = "shenmi",
	a = "exchange",
	id = param.id
	}
	request(msg, _callback)
end
}
RequestHelper.worldBoss = {
history = function (param)
	local _callback = param.callback
	local msg = {m = "bossbattle", a = "history"}
	request(msg, _callback)
end,
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
pay = function (param)
	local _callback = param.callback
	local msg = {
	m = "bossbattle",
	a = "pay",
	use = param.use
	}
	request(msg, _callback)
end,
battle = function (param)
	local _callback = param.callback
	local msg = {m = "bossbattle", a = "pve"}
	request(msg, _callback)
end,
result = function (param)
	local _callback = param.callback
	local msg = {m = "bossbattle", a = "result"}
	request(msg, _callback)
end
}
RequestHelper.GameIap = {
main = function (param)
	dump(param)
	local _callback = param.callback
	local msg = {
	m = "iap",
	a = "main",
	appid = param.appid or "",
	payway = param.payway or ""
	}
	dump(msg)
	request(msg, _callback)
end
}
RequestHelper.monthCard = {
getData = function (param)
	local _callback = param.callback
	local payway = param.payway
	print("pay way is :" .. tostring(payway))
	if payway == nil or payway == "" then
		payway = ""
	end
	local msg = {
	m = "mCard",
	a = "actPage",
	payway = payway
	}
	request(msg, _callback)
end,
getReward = function (param)
	local _callback = param.callback
	local msg = {m = "mCard", a = "get"}
	request(msg, _callback)
end
}
RequestHelper.huashan = {
state = function (param)
	local _callback = param.callback
	local msg = {m = "swordfight", a = "enterSword"}
	request(msg, _callback, param.errorback)
end,
zhandouli = function (param)
	local _callback = param.callback
	local msg = {
	m = "swordfight",
	a = "combat",
	fmt = param.fmt
	}
	request(msg, _callback)
end,
fight = function (param)
	local _callback = param.callback
	local msg = {
	m = "swordfight",
	a = "fight",
	floor = param.floor,
	fmt = param.fmt
	}
	request(msg, _callback)
end,
reset = function (param)
	local _callback = param.callback
	local msg = {
	m = "swordfight",
	a = "reset",
	gold = param.gold
	}
	request(msg, _callback)
end,
getaward = function (param)
	local _callback = param.callback
	local msg = {
	m = "swordfight",
	a = "award",
	floor = param.floor
	}
	request(msg, _callback)
end
}
RequestHelper.vipFuli = {
getData = function (param)
	local _callback = param.callback
	local msg = {m = "iap", a = "vipDayGift"}
	request(msg, _callback)
end,
getReward = function (param)
	local _callback = param.callback
	local msg = {
	m = "iap",
	a = "getVipDayGift"
	}
	request(msg, _callback)
end
}
RequestHelper.vipLibao = {
getData = function (param)
	local _callback = param.callback
	local msg = {
	m = "iap",
	a = "vipLvGiftList"
	}
	request(msg, _callback)
end,
getReward = function (param)
	local _callback = param.callback
	local msg = {
	m = "iap",
	a = "vipLvGiftGet",
	vipLv = param.vipLv
	}
	request(msg, _callback)
end
}
RequestHelper.leijiLogin = {
getListData = function (param)
	local _callback = param.callback
	local msg = {m = "activity", a = "happyGift"}
	request(msg, _callback)
end,
getStatusData = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "happyStatus"
	}
	request(msg, _callback)
end,
getReward = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "happyGet",
	day = param.day
	}
	request(msg, _callback)
end
}
RequestHelper.yueqian = {
monthSignStatus = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "monthSignStatus"
	}
	request(msg, _callback)
end,
getReward = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "monthSignGet",
	day = param.day,
	month = param.month
	}
	request(msg, _callback, param.errback)
end
}
RequestHelper.dengjiTouzi = {
getData = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "investPlanStatus"
	}
	request(msg, _callback)
end,
getReward = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "investPlanGet",
	lv = param.lv
	}
	request(msg, _callback)
end,
buy = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "investPlanBuy",
	lv = param.lv
	}
	request(msg, _callback)
end
}
RequestHelper.Guild = {
main = function (param)
	local _callback = param.callback
	local msg = {
	m = "union",
	a = "enterUnion",
	num = param.num
	}
	request(msg, _callback)
end,
apply = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "applyUnion",
	uid = param.id,
	type = param.type
	}
	request(msg, _callback, _errback)
end,
create = function (param)
	local _callback = param.callback
	local msg = {
	m = "union",
	a = "createUnion",
	type = param.type,
	name = param.name
	}
	request(msg, _callback)
end,
rank = function (param)
	local _callback = param.callback
	local msg = {
	m = "union",
	a = "showUnionRank"
	}
	request(msg, _callback)
end,
search = function (param)
	local _callback = param.callback
	local msg = {
	m = "union",
	a = "searcheUnion",
	unionName = param.unionName,
	start = param.startIndex,
	total = param.total
	}
	request(msg, _callback)
end,
modify = function (param)
	local _callback = param.callback
	local msg = {
	m = "union",
	a = "modifyUnionInfo",
	msg = param.text,
	type = param.type
	}
	request(msg, _callback)
end,
demise = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {m = "union", a = "abdication"}
	request(msg, _callback, _errback)
end,
zijian = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "coverLeader",
	leaderId = param.leaderId
	}
	request(msg, _callback, _errback)
end,
updateUnionLeader = function (param)
	local _callback = param.callback
	local msg = {
	m = "union",
	a = "updateUnionLeader"
	}
	request(msg, _callback)
end,
showAllMember = function (param)
	local _callback = param.callback
	local msg = {
	m = "union",
	a = "showAllMember"
	}
	request(msg, _callback)
end,
showApplyList = function (param)
	local _callback = param.callback
	local msg = {
	m = "union",
	a = "showApplyList",
	unionId = param.unionId
	}
	request(msg, _callback)
end,
handleApply = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "handleApply",
	unionId = param.unionId,
	applyRoleId = param.applyRoleId,
	type = param.type
	}
	request(msg, _callback, _errback)
end,
refuseAll = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {m = "union", a = "refuseAll"}
	request(msg, _callback, _errback)
end,
kcikRole = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "kcikRole",
	appRoleId = param.appRoleId
	}
	request(msg, _callback, _errback)
end,
setPosition = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "setposition",
	appRoleId = param.appRoleId,
	jopType = param.jopType
	}
	request(msg, _callback, _errback)
end,
exitUnion = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "exitUnion",
	uid = param.uid
	}
	request(msg, _callback, _errback)
end,
enterWelfare = function (param)
	local _callback = param.callback
	local msg = {
	m = "union",
	a = "enterWelfare"
	}
	request(msg, _callback)
end,
getReward = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "getReward",
	id = param.id
	}
	request(msg, _callback, _errback)
end,
openActivities = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "openActivities",
	id = param.id
	}
	request(msg, _callback, _errback)
end,
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
enterMainBuilding = function (param)
	local _callback = param.callback
	local msg = {
	m = "union",
	a = "enterMainBuilding"
	}
	request(msg, _callback)
end,
unionDonate = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "unionDonate",
	unionid = param.unionid,
	donatetype = param.donatetype
	}
	request(msg, _callback, _errback)
end,
unionLevelUp = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "unionLevelUp",
	unionId = param.unionid,
	buildtype = param.buildtype
	}
	request(msg, _callback, _errback)
end,
showDynamicList = function (param)
	local _callback = param.callback
	local msg = {
	m = "union",
	a = "showDynamicList"
	}
	request(msg, _callback)
end,
enterWorkShop = function (param)
	local _callback = param.callback
	local msg = {
	m = "union",
	a = "enterWorkShop"
	}
	request(msg, _callback)
end,
unionWorkShopProduct = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "unionWorkShopProduct",
	unionid = param.unionid,
	overtimeflag = param.workType,
	worktype = param.workId
	}
	request(msg, _callback, _errback)
end,
unionWorkShopGetReward = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "unionWorkShopGetReward",
	unionId = param.unionId
	}
	request(msg, _callback, _errback)
end,
checkWorkShopTime = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "checkWorkShopTime",
	type = param.type
	}
	request(msg, _callback, _errback)
end,
bossHistory = function (param)
	local _callback = param.callback
	local msg = {
	m = "union",
	a = "bossHistory",
	unionId = param.unionId
	}
	request(msg, _callback)
end,
bossCreate = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "bossCreate",
	unionId = param.unionId
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
bossTop = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "bossTop",
	unionId = param.unionId
	}
	request(msg, _callback, _errback)
end,
bossPay = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "bossPay",
	unionId = param.unionId,
	use = param.use
	}
	request(msg, _callback, _errback)
end,
bossPve = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "bossPve",
	unionId = param.unionId
	}
	request(msg, _callback, _errback)
end,
unionShopList = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "unionShopList",
	shopflag = param.shopflag,
	unionId = param.unionId
	}
	request(msg, _callback, _errback)
end,
checkUnionShopTime = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "checkUnionShopTime"
	}
	request(msg, _callback, _errback)
end,
exchangeGoods = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "exchangeGoods",
	id = param.id,
	count = param.count,
	type = param.type
	}
	request(msg, _callback, _errback)
end,
enterUnionCopy = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "enterUnionCopy",
	type = param.type
	}
	request(msg, _callback, _errback)
end,
enterSingleCopy = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "querySingleCopy",
	type = param.type,
	id = param.id
	}
	request(msg, _callback, _errback)
end,
showHurtList = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "showHurtList"
	}
	request(msg, _callback, _errback)
end,
getFubenReward = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "receiveRewards",
	id = param.id
	}
	request(msg, _callback, _errback)
end,
chooseCard = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "chooseCard",
	sysid = param.sysId
	}
	request(msg, _callback, _errback)
end,
unionFBfight = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "union",
	a = "unionFBfight",
	id = param.id,
	sysid = param.sysid,
	fmt = param.fmt
	}
	request(msg, _callback, _errback)
end
}
RequestHelper.friend = {
getFriendList = function (param)
	local _callback = param.callback
	local msg = {
	m = "friend",
	a = "getFriendList"
	}
	request(msg, _callback)
end,
sendChatContent = function (param)
	local _callback = param.callback
	local msg = {
	m = "friend",
	a = "sendChatContent",
	content = param.content,
	account = param.account
	}
	request(msg, _callback, param.errback)
end,
updateChatContent = function (param)
	local _callback = param.callback
	local msg = {
	m = "friend",
	a = "updateChatContent",
	account = param.account
	}
	request(msg, _callback, param.errback)
end,
removeFriend = function (param)
	local _callback = param.callback
	local msg = {
	m = "friend",
	a = "removeFriend",
	account = param.account
	}
	request(msg, _callback, param.errback)
end,
recommendList = function (param)
	local _callback = param.callback
	local msg = {
	m = "friend",
	a = "recommendList",
	num = param.num,
	flag = param.flag
	}
	request(msg, _callback, param.errback)
end,
applyFriend = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "friend",
	a = "applyFriend",
	content = param.content,
	account = param.account
	}
	request(msg, _callback, _errback)
end,
searchFriend = function (param)
	local _callback = param.callback
	local msg = {
	m = "friend",
	a = "searchFriend",
	type = param.type,
	searchNum = param.searchNum,
	flag = param.flag,
	content = param.content
	}
	request(msg, _callback, param.errback)
end,
sendNaili = function (param)
	local _callback = param.callback
	local msg = {
	m = "friend",
	a = "sendNaili",
	account = param.account
	}
	request(msg, _callback, param.errback)
end,
getNaili = function (param)
	local _callback = param.callback
	local msg = {
	m = "friend",
	a = "getNaili",
	account = param.account
	}
	request(msg, _callback, param.errback)
end,
getNailiAll = function (param)
	local _callback = param.callback
	local msg = {
	m = "friend",
	a = "getNailiAll"
	}
	request(msg, _callback, param.errback)
end,
acceptFriend = function (param)
	local _callback = param.callback
	local msg = {
	m = "friend",
	a = "acceptFriend",
	account = param.account
	}
	request(msg, _callback, param.errback)
end,
rejectFriend = function (param)
	local _callback = param.callback
	local msg = {
	m = "friend",
	a = "rejectFriend",
	account = param.account
	}
	request(msg, _callback, param.errback)
end,
acceptAll = function (param)
	local _callback = param.callback
	local msg = {m = "friend", a = "acceptAll"}
	request(msg, _callback, param.errback)
end,
rejectAll = function (param)
	local _callback = param.callback
	local msg = {m = "friend", a = "rejectAll"}
	request(msg, _callback, param.errback)
end,
pullBack = function (param)
	local _callback = param.callback
	local msg = {
	m = "friend",
	a = "black",
	type = param.type,
	facc = param.facc
	}
	request(msg, _callback, param.errback)
end,
getRelation = function (param)
	local _callback = param.callback
	local msg = {
	m = "friend",
	a = "relation",
	facc = param.facc
	}
	request(msg, _callback, param.errback)
end,
pkWithFriend = function (param)
	local _callback = param.callback
	local msg = {
	m = "friend",
	a = "battle",
	facc = param.facc
	}
	request(msg, _callback)
end
}
RequestHelper.dialyTask = {
getTaskList = function (param)
	local _callback = param.callback
	local msg = {
	m = "mission",
	a = "list",
	missionType = param.missionType
	}
	request(msg, _callback, param.errback)
end,
getGift = function (param)
	local _callback = param.callback
	local msg = {
	m = "mission",
	a = "dailyReward",
	id = param.id
	}
	request(msg, _callback, param.errback)
end,
getTaskGift = function (param)
	local _callback = param.callback
	local msg = {
	m = "mission",
	a = "reward",
	id = param.id
	}
	request(msg, _callback, param.errback)
end,
checkBPSignIn = function (param)
	local _callback = param.callback
	local msg = {
	m = "union",
	a = "checkInUnion"
	}
	request(msg, _callback, param.errback)
end,
getChongZhiList = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "payFeedBack"
	}
	request(msg, _callback, param.errback)
end
}
RequestHelper.biwuSystem = {
getBaseInfo = function (param)
	local _callback = param.callback
	local msg = {m = "tournament", a = "getInfo"}
	request(msg, _callback, param.errback)
end,
getRefreshHero = function (param)
	local _callback = param.callback
	local msg = {m = "tournament", a = "refresh"}
	request(msg, _callback, param.errback)
end,
getEnemyList = function (param)
	local _callback = param.callback
	local msg = {m = "tournament", a = "enemyList"}
	request(msg, _callback, param.errback)
end,
getExchangeList = function (param)
	local _callback = param.callback
	local msg = {
	m = "tournament",
	a = "exchangeList"
	}
	request(msg, _callback, param.errback)
end,
getTianbangList = function (param)
	local _callback = param.callback
	local msg = {m = "tournament", a = "rankList"}
	request(msg, _callback, param.errback)
end,
addChallengeTimes = function (param)
	local _callback = param.callback
	local msg = {
	m = "tournament",
	a = "buy",
	num = param.times
	}
	request(msg, _callback, param.errback)
end,
exChangeItem = function (param)
	local _callback = param.callback
	local msg = {
	m = "tournament",
	a = "exchange",
	itemId = param.id,
	num = param.num
	}
	request(msg, _callback, param.errback)
end,
getFightData = function (param)
	local _callback = param.callback
	local msg = {
	m = "tournament",
	a = "challenge",
	roleId = param.roleId,
	type = param.type
	}
	request(msg, _callback, param.errback)
end,
checkFight = function (param)
	local _callback = param.callback
	local msg = {
	m = "tournament",
	a = "check",
	roleId = param.roleId,
	type = param.type
	}
	request(msg, _callback, param.errback)
end
}
RequestHelper.yaBiaoSystem = {
getBaseInfo = function (param)
	local _callback = param.callback
	local msg = {m = "detainDart", a = "enterFace"}
	request(msg, _callback, param.errback)
end,
refreshAllEnemy = function (param)
	local _callback = param.callback
	local msg = {
	m = "detainDart",
	a = "refreshOthers"
	}
	request(msg, _callback, param.errback)
end,
refreshSigleEnemy = function (param)
	local _callback = param.callback
	local msg = {
	m = "detainDart",
	a = "repairOthers",
	repairIds = param.repairIds
	}
	request(msg, _callback, param.errback)
end,
carSelectState = function (param)
	local _callback = param.callback
	local msg = {m = "detainDart", a = "choiceDart"}
	request(msg, _callback, param.errback)
end,
callNBCar = function (param)
	local _callback = param.callback
	local msg = {
	m = "detainDart",
	a = "refreshDart",
	tag = param.tag
	}
	request(msg, _callback, param.errback)
end,
carSelectOk = function (param)
	local _callback = param.callback
	local msg = {m = "tournament", a = "getInfo"}
	request(msg, _callback, param.errback)
end,
getCarInfo = function (param)
	local _callback = param.callback
	local msg = {
	m = "detainDart",
	a = "dartData",
	roleID = param.roleID,
	dartkey = param.dartkey
	}
	request(msg, _callback, param.errback)
end,
beginRunWithSpeedUp = function (param)
	local _callback = param.callback
	local msg = {m = "detainDart", a = "speedUp"}
	request(msg, _callback, param.errback)
end,
beginRun = function (param)
	local _callback = param.callback
	local msg = {m = "detainDart", a = "start"}
	request(msg, _callback, param.errback)
end,
forceGetCar = function (param)
	local _callback = param.callback
	local msg = {
	m = "detainDart",
	a = "robDart",
	otherID = param.otherID,
	dartkey = param.dartkey
	}
	request(msg, _callback, param.errback)
end,
getRewords = function (param)
	local _callback = param.callback
	local msg = {
	m = "detainDart",
	a = "acceptAward"
	}
	request(msg, _callback, param.errback)
end
}
RequestHelper.exchangeSystem = {
getExchangeList = function (param)
	local _callback = param.callback
	local msg = {m = "exch", a = "list"}
	request(msg, _callback, param.errback)
end,
giftPreView = function (param)
	local _callback = param.callback
	local msg = {m = "exch", a = "award"}
	request(msg, _callback, param.errback)
end,
refresh = function (param)
	local _callback = param.callback
	local msg = {
	m = "exch",
	a = "refresh",
	exchId = param.id
	}
	request(msg, _callback, param.errback)
end,
exchange = function (param)
	local _callback = param.callback
	local msg = {
	m = "exch",
	a = "exch",
	exchId = param.id
	}
	request(msg, _callback, param.errback)
end
}
RequestHelper.tanbaoSystem = {
getBaseInfo = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "rouletteEnter"
	}
	request(msg, _callback, param.errback)
end,
preViewItem = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "roulettePreview",
	id = param.id
	}
	request(msg, _callback, param.errback)
end,
startFind = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "rouletteOp",
	num = param.num,
	indexId = param.indexId
	}
	request(msg, _callback, param.errback)
end,
getReword = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "rouletteGetCredit",
	index = param.index
	}
	request(msg, _callback, param.errback)
end
}
RequestHelper.wabaoSystem = {
getBaseInfo = function (param)
	local _callback = param.callback
	local msg = {m = "activity", a = "mazeEnter"}
	request(msg, _callback, param.errback)
end,
refresh = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "mazeRefresh",
	type = param.retype
	}
	request(msg, _callback, param.errback)
end,
beginDig = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "mazeDig",
	type = param.type
	}
	request(msg, _callback, param.errback)
end
}
RequestHelper.chongwuChouKa = {
getBaseInfo = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "petchoukatimes"
	}
	request(msg, _callback, param.errback)
end,
qifu = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "petchouka",
	n = param.count
	}
	request(msg, _callback, param.errback)
end
}
RequestHelper.tuanGouSystem = {
getBaseInfo = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "getGroupBuyingItemInfo"
	}
	request(msg, _callback, param.errback)
end,
buyGoodsInfo = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "buyGroupBuyingItem",
	shoppingId = param.shoppingId,
	goodsCount = param.goodsCount,
	groupType = param.groupType
	}
	request(msg, _callback, param.errback)
end
}
RequestHelper.xianshiShopSystem = {
getBaseInfo = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "enterLimitShop"
	}
	request(msg, _callback, param.errback)
end,
getReword = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "exchangeLimitGoods",
	id = param.id,
	count = param.count
	}
	request(msg, _callback, param.errback)
end
}
RequestHelper.creditShopSystem = {
getBaseInfo = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "integralShop"
	}
	request(msg, _callback, param.errback)
end,
getReword = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "integralExchange",
	id = param.id,
	count = param.count
	}
	request(msg, _callback, param.errback)
end
}
RequestHelper.kaifukuanghuan = {
getBaseInfo = function (param)
	local _callback = param.callback
	local msg = {
	m = "revelry",
	a = "enterRevelry",
	type = param.type or 0
	}
	request(msg, _callback, param.errback)
end,
halfBuy = function (param)
	local _callback = param.callback
	local msg = {
	m = "revelry",
	a = "halfBuy",
	dayIndex = param.dayIndex,
	type = param.type or 0
	}
	request(msg, _callback, param.errback)
end,
getItem = function (param)
	local _callback = param.callback
	local msg = {
	m = "revelry",
	a = "getaward",
	option = param.option,
	dayIndex = param.dayIndex,
	id = param.id,
	type = param.type or 0
	}
	request(msg, _callback, param.errback)
end
}
function RequestHelper.checkGold(param, url)
	local _callback = param.callback
	local msg = {
	m = "tx",
	a = "chengeGold",
	serverId = tostring(game.player.m_serverID),
	pfid = param.pfid,
	openid = param.openid,
	openkey = param.accesstoken,
	pay_token = param.pay_token,
	pf = param.pf,
	channelid = param.channelid,
	deviceid = param.deviceid,
	paymenttype = param.paymenttype,
	pfkey = param.pfkey
	}
	printf(url)
	request(msg, _callback, nil, url)
end
RequestHelper.challengeFuben = {
actDetail = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "actbattle",
	a = "actDetail",
	aid = param.aid,
	sysId = param.sysId
	}
	request(msg, _callback, _errback)
end,
save = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "actbattle",
	a = "save",
	aid = param.aid,
	fmt = param.fmt,
	sysId = param.sysId
	}
	request(msg, _callback, _errback)
end,
actPve = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "actbattle",
	a = "actPve",
	aid = param.aid,
	sysId = param.sysId,
	npc = param.npc,
	npcLv = param.npcLv,
	fmt = param.fmt
	}
	request(msg, _callback, _errback)
end,
rbPveBattle = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "actbattle",
	a = "rbPveBattle",
	id = param.id,
	npc = param.npc,
	fmt = param.fmt
	}
	request(msg, _callback, _errback)
end,
check = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "actbattle",
	a = "check",
	aid = param.aid
	}
	request(msg, _callback, _errback)
end
}
RequestHelper.qianghuaDashi = {
getBaseData = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "quench",
	a = "master",
	acc = param.acc,
	order = param.order
	}
	request(msg, _callback, _errback)
end
}
RequestHelper.zhuangbeiculian = {
getBaseInfo = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "quench",
	a = "view",
	acc = param.acc,
	order = param.order
	}
	request(msg, _callback, _errback)
end,
startCulian = function (param)
	local _callback = param.callback
	local _errback = param.errback
	local msg = {
	m = "quench",
	a = "quench",
	acc = param.acc,
	order = param.order,
	pos = param.pos,
	qnum = param.qnum,
	cnum = param.cnum,
	minExp = param.minExp
	}
	request(msg, _callback, _errback)
end
}

RequestHelper.vipqiandao = {
vipqiandaoStatus = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "getDeluxeSignInfo"
	}
	request(msg, _callback)
end,

getReward = function (param)
	local _callback = param.callback
	local msg = {
	m = "activity",
	a = "getDeluxeSignReward"
	}
	request(msg, _callback)
end
}

return RequestHelper