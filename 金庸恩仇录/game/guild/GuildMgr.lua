local data_config_union_config_union = require("data.data_config_union_config_union")
require("game.guild.utility.GuildGameConst")
require("utility.richtext.richText")
local data_union_union = require("data.data_union_union")
local GuildMgr = class("GuildMgr")

function GuildMgr:ctor()
	self.m_guildList = {}
	self.m_guild = nil
	self.m_isInUnion = false
	self.m_isChangeCover = false
	self.m_hasApplyedNum = 0
	self.m_guildFbInfolayer = nil
	self.m_bHasFbFight = false
end

function GuildMgr:RequestInfo(cb)
	RequestHelper.Guild.main({
	num = data_config_union_config_union[1].guild_return_num,
	callback = function(data)
		self:initInfo(data.rtnObj)
		if cb ~= nil then
			cb()
		end
	end
	})
end

function GuildMgr:RequestGuildList(cb)
	RequestHelper.Guild.search({
	unionName = "",
	startIndex = 0,
	total = data_config_union_config_union[1].guild_return_num,
	callback = function(data)
		dump(data)
		self:setGuildList(data.rtnObj.unionList)
		self.m_totalGuildNum = data.rtnObj.totalNum
		local jopType = data.rtnObj.jopType
		self:setJopType(jopType)
		if cb ~= nil then
			cb()
		end
	end
	})
end

function GuildMgr:RequestShowAllMember(cb)
	RequestHelper.Guild.showAllMember({
	callback = function(data)
		dump(data)
		self:setJopType(data.rtnObj.jopType)
		if cb ~= nil then
			cb(data)
		end
	end
	})
end

function GuildMgr:RequestShowApplyList(cb)
	RequestHelper.Guild.showApplyList({
	unionId = self.m_guild.m_id,
	callback = function(data)
		self:setJopType(data.rtnObj.jopType)
		if cb ~= nil then
			cb(data)
		end
	end
	})
end

function GuildMgr:RequestFuliList(cb)
	RequestHelper.Guild.enterWelfare({
	callback = function(data)
		self:setJopType(data.rtnObj.jopType)
		if cb ~= nil then
			cb(data)
		end
	end
	})
end

function GuildMgr:RequestEnterMainBuilding(cb)
	RequestHelper.Guild.enterMainBuilding({
	callback = function(data)
		if cb ~= nil then
			cb(data)
		end
	end
	})
end

function GuildMgr:RequestDynamicList(cb)
	RequestHelper.Guild.showDynamicList({
	callback = function(data)
		self:setJopType(data.rtnObj.jopType)
		if cb ~= nil then
			cb(data)
		end
	end
	})
end

function GuildMgr:RequestEnterWorkShop(cb)
	RequestHelper.Guild.enterWorkShop({
	callback = function(data)
		if cb ~= nil then
			cb(data)
		end
	end
	})
end

function GuildMgr:RequestBossHistory(cb)
	RequestHelper.Guild.bossHistory({
	unionId = self.m_guild.m_id,
	callback = function(data)
		self:setJopType(data.rtnObj.jobType)
		if cb ~= nil then
			cb(data)
		end
	end
	})
end

function GuildMgr:RequestBossState(cb)
	RequestHelper.Guild.bossState({
	unionId = self.m_guild.m_id,
	callback = function(data)
		if cb ~= nil then
			cb(data)
		end
	end
	})
end

function GuildMgr:RequestBossRank(cb, errcb)
	RequestHelper.Guild.bossTop({
	unionId = self.m_guild.m_id,
	errback = function(data)
		if errcb ~= nil then
			errcb()
		end
	end,
	callback = function(data)
		if cb ~= nil then
			cb(data)
		end
	end
	})
end

function GuildMgr:RequestShopList(showType, cb)
	RequestHelper.Guild.unionShopList({
	unionId = self.m_guild.m_id,
	shopflag = showType,
	callback = function(data)
		self:setJopType(data.rtnObj.jopType)
		if cb ~= nil then
			cb(data)
		end
	end
	})
end

function GuildMgr:RequestFubenList(showType, cb, errcb)
	RequestHelper.Guild.enterUnionCopy({
	type = showType,
	errback = function()
		if errcb ~= nil then
			errcb()
		end
	end,
	callback = function(data)
		self:setJopType(data.jopType)
		if cb ~= nil then
			cb(data)
		end
	end
	})
end

function GuildMgr:RequestFubenInfo(param)
	local cb = param.cb
	local errcb = param.errcb
	RequestHelper.Guild.enterSingleCopy({
	id = param.id,
	errback = function()
		if errcb ~= nil then
			errcb()
		end
	end,
	callback = function(data)
		dump(data, common:getLanguageString("@GuildSingleDungeon"))
		if cb ~= nil then
			cb(data)
		end
	end
	})
end

function GuildMgr:RequestFubenChooseCard(param)
	local cb = param.cb
	local errcb = param.errcb
	local sysId = param.sysId
	RequestHelper.Guild.chooseCard({
	sysId = sysId,
	errback = function()
		if errcb ~= nil then
			errcb()
		end
	end,
	callback = function(data)
		dump(data)
		if cb ~= nil then
			cb(data)
		end
	end
	})
end

function GuildMgr:initInfo(param)
	self.m_isInUnion = param.inUnion
	self.m_isChangeCover = param.changeCover
	self.m_coverVO = param.coverVO
	self.m_totalGuildNum = param.totalNum or 0
	self.m_hasApplyedNum = param.applyNum or 0
	if param.union ~= nil then
		self:setGuildInfo(param.union)
	elseif param.unionList ~= nil then
		local guildList = param.unionList
		local len = #guildList
		if len > 0 then
			self.m_guildList = guildList
		else
			self.m_guildList = {}
		end
	end
end

function GuildMgr:getGuildList()
	if self.m_guildList == nil and (device.platform == "windows" or device.platform == "mac") then
		show_tip_label("guild list is nil")
	end
	return self.m_guildList
end

function GuildMgr:setGuildList(guildList)
	if guildList == nil or #guildList == 0 then
		self.m_guildList = {}
	else
		self.m_guildList = guildList
	end
end

function GuildMgr:getGuildInfo()
	if self.m_guild == nil and (device.platform == "windows" or device.platform == "mac") then
		show_tip_label(" guild info is nil")
	end
	return self.m_guild
end

function GuildMgr:setGuildInfo(guildInfo)
	if self.m_guild == nil then
		self.m_guild = require("game.guild.Guild").new(guildInfo)
	else
		self.m_guild:init(guildInfo)
	end
end

function GuildMgr:getIsInUnion()
	return self.m_isInUnion
end

function GuildMgr:getIsChangeCover()
	return self.m_isChangeCover
end

function GuildMgr:setIsChangeCover(change)
	self.m_isChangeCover = change
end
function GuildMgr:getTotalGuildNum(...)
	return self.m_totalGuildNum
end

function GuildMgr:getCoverVo()
	return self.m_coverVO
end

function GuildMgr:setCoverVo(coverVO)
	self.m_coverVO = coverVO
end

function GuildMgr:getHasApplyedNum()
	return self.m_hasApplyedNum
end
function GuildMgr:setIsInUnion(inUnion)
	self.m_isInUnion = inUnion
end

function GuildMgr:setJopType(jopType)
	if self.m_guild ~= nil then
		self.m_guild.m_jopType = jopType or self.m_guild.m_jopType
	end
end

function GuildMgr:getMaxLevelByType(buildType)
	local maxLv = 0
	for i, v in ipairs(data_union_union) do
		if v.type == buildType and maxLv < v.level then
			maxLv = v.level
		end
	end
	return maxLv
end

function GuildMgr:checkIsReachMaxLevel(buildType, level)
	local reach = false
	local maxLv = self:getMaxLevelByType(buildType)
	if level >= maxLv then
		reach = true
	end
	return reach
end

function GuildMgr:getIdByTypeAndLevel(buildType, level)
	local id
	for i, v in ipairs(data_union_union) do
		if v.type == buildType and v.level == level then
			id = v.id
		end
	end
	ResMgr.showAlert(id, common:getLanguageString("@ServerdidntFindIDinUnion") .. buildType .. common:getLanguageString("@Level") .. level)
	return id
end

function GuildMgr:getNeedCoin(buildType, level)
	local id = self:getIdByTypeAndLevel(buildType, level)
	local needCoin = data_union_union[id].usemoney
	ResMgr.showAlert(needCoin, common:getLanguageString("@ServerdidntFindIDinUnion") .. common:getLanguageString("@Level") .. level)
	return needCoin
end

function GuildMgr:getRequireBuildLevel(buildType, level)
	local needType, needLevel
	for i, v in ipairs(data_union_union) do
		if v.type == buildType and v.level == level then
			if v.requirements ~= nil then
				needType = v.requirements[1]
				needLevel = v.requirements[2]
			end
			break
		end
	end
	return needType, needLevel
end

function GuildMgr:getRequireStr(buildType, level)
	local str
	local needType, needLv = self:getRequireBuildLevel(buildType, level)
	if needType ~= nil and needLv ~= nil then
		local bNeed = false
		if needType == GUILD_BUILD_TYPE.dadian and needLv > self.m_guild.m_level then
			bNeed = true
		elseif needType == GUILD_BUILD_TYPE.zuofang and needLv > self.m_guild.m_workshoplevel then
			bNeed = true
		elseif needType == GUILD_BUILD_TYPE.shop and needLv > self.m_guild.m_shoplevel then
			bNeed = true
		elseif needType == GUILD_BUILD_TYPE.qinglong and needLv > self.m_guild.m_greenDragonTempleLevel then
			bNeed = true
		elseif needType == GUILD_BUILD_TYPE.fuben and needLv > self.m_guild.m_level then
			bNeed = true
		end
		if bNeed == true then
			str = common:getLanguageString("@GuildBuildingLvMax") .. GUILD_BUILD_NAME[needType] .. common:getLanguageString("@Level", "")
		end
	end
	return str
end

function GuildMgr:setFbInfoLayer(layer)
	self.m_guildFbInfolayer = layer
end

function GuildMgr:forceUpdateFbInfoLayer(param)
	if self.m_guildFbInfolayer ~= nil then
		self.m_guildFbInfolayer:forceUpdate(param)
	end
end

function GuildMgr:setFbHasFight(bFight)
	self.m_bHasFbFight = bFight
end

function GuildMgr:getFbHasFight()
	return self.m_bHasFbFight
end

return GuildMgr