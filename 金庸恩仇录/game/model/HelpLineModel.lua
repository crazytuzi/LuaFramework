local HelpLineModel = {}
HelpLineModel.totalProArr = nil --强化属性
HelpLineModel.supports = nil --当前助阵侠客
HelpLineModel.currentPage = 1
HelpLineModel.fu = 0 --阵位符
local data_helper_helper = require("data.data_helper_helper")


function HelpLineModel:initData(data)
	HelpLineModel.totalProArr = data.totalProArr or {}
	HelpLineModel.supports = data.supports or {}
	HelpLineModel.fu = data.fu or 0
end

function HelpLineModel:setTotalProArrData(data)
	HelpLineModel.totalProArr = data or {}
end

function HelpLineModel:setPage(index)
	HelpLineModel.currentPage = index
end

function HelpLineModel:getHeroHelpTbl()
	local tbl = {}
	local index = 0
	for key, hero in pairs(HelpLineModel.supports) do
		if hero.roleCard then
			tbl[hero.roleCard.resId] = hero.roleCard
			index = index + 1
		end
	end
	tbl.num = index
	return tbl
end

function HelpLineModel:setHeroHelpState(heroTbl)
	local tbl = {}
	local newHero = {}
	for key, hero in pairs(HelpLineModel.supports) do
		if hero.roleCard then
			tbl[hero.roleCard.resId] = hero.roleCard
		end
	end
	for key, hero in pairs(heroTbl) do
		if tbl[hero.resId] then
			if hero.id == tbl[hero.resId].id then
				newHero[#newHero + 1] = hero
			end
		else
			newHero[#newHero + 1] = hero
		end
	end
	return newHero
end

function HelpLineModel:getCurrentPage(index)
	local currentData = {}
	local index = index or HelpLineModel.currentPage
	currentData.data = HelpLineModel.supports[index] or nil
	currentData.type = data_helper_helper[index].type
	currentData.goldType = data_helper_helper[index].goldType
	currentData.Expend = data_helper_helper[index].Expend
	currentData.index = index
	return currentData
end

function HelpLineModel:setHelpData(index, cardData)
	if HelpLineModel.supports[index] then
		HelpLineModel.supports[index] = cardData
	end
end

function HelpLineModel:setZhenWeiData(data)
	HelpLineModel.fu = data.fu or 0
	HelpLineModel.totalProArr = data.totalProArr or {}
	if HelpLineModel.supports[data.supportPos] then
		HelpLineModel.supports[data.supportPos].level = data.level
	end
	game.player:setSilver(data.silver)
	PostNotice(NoticeKey.CommonUpdate_Label_Silver)
end

function HelpLineModel:setCurrentPage(index)
	HelpLineModel.currentPage = index
end

function HelpLineModel:getHelpList()
	local helpHeroList = {}
	for k, v in pairs(HelpLineModel.supports) do
		if v.roleCard ~= nil then
			helpHeroList[k] = v.roleCard
		end
	end
	return helpHeroList
end

--当前阵位消耗
function HelpLineModel:getCost(pos)
	local index = pos or HelpLineModel.currentPage
	local goldType = data_helper_helper[index].goldType
	local expend = data_helper_helper[index].expend
	return goldType, expend
end

--开放助阵位
function HelpLineModel:addHelp(data)
	dump(data)
	if data and data[1] then
		local supportPos = data[1]
		local level = data[2]
		local gold = data[3]
		local v = {}
		v.level = level
		v.resId = 0
		HelpLineModel.supports[supportPos] = v
		game.player:setGold(gold)
		PostNotice(NoticeKey.CommonUpdate_Label_Silver)
		PostNotice(NoticeKey.CommonUpdate_Label_Gold)
	end
end

--改变阵位侠客
function HelpLineModel:changeHelp(param)
	local msg = {
	m = "fmt",
	a = "changeHelp",
	id = param.id,
	pos = param.pos
	}
	RequestHelper.request(msg, param.callback, param.errback)
end

--请求开放阵位
function HelpLineModel:openHelp(param)
	local msg = {
	m = "fmt",
	a = "openHelp",
	pos = param.pos
	}
	RequestHelper.request(msg, param.callback, param.errback)
end

--升级阵位
function HelpLineModel:upLevelHelp(param)
	local msg = {
	m = "fmt",
	a = "upLevelHelp",
	pos = param.pos
	}
	RequestHelper.request(msg, param.callback, param.errback)
end

--获取阵位详情
function HelpLineModel:getHelpInfo(param)
	local msg = {m = "fmt", a = "helpLine"}
	local function callback(data)
		HelpLineModel:initData(data)
		if param.callback ~= nil then
			param.callback()
		end
	end
	RequestHelper.request(msg, callback, param.errback)
end

return HelpLineModel