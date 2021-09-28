 --[[--
 --
 -- @authors shan 
 -- @date    2014-12-19 16:39:26
 -- @version 
 --
 --]]


--[[ --
	@class GuildMgr
	@ guild - | guild 			-- module
			  |	guildMgr 		-- control
			  | giildScene		-- view


]]

local data_config_union_config_union = require("data.data_config_union_config_union") 
require("game.guild.utility.GuildGameConst") 
require("utility.richtext.richText") 

local data_union_union = require("data.data_union_union") 

local GuildMgr = class("GuildMgr")


---
-- guildMgr
--
function GuildMgr:ctor(  )
	-- body
	self.m_guildList = {}
	self.m_guild = nil
	self.m_isInUnion = false 	-- 是否在帮派中
	self.m_isChangeCover = false 	-- 是否更改自荐状态 true 更改，false 不更改
	self.m_hasApplyedNum = 0 	-- 已申请的帮派数 
end

--- 
-- request Guild info from server
--
-- 
function GuildMgr:RequestInfo( cb)
	
	RequestHelper.Guild.main({
		num = data_config_union_config_union[1]["guild_return_num"], 
		callback = function ( data )
			-- dump(data.rtnObj)
			self:initInfo(data.rtnObj)

			-- 请求数据结束后，进行回调
			if( cb ~= nil) then
				cb()
			end
		end
		})
end


function GuildMgr:RequestGuildList(cb)
	RequestHelper.Guild.search({ 
 		unionName = "", 
 		startIndex = 0, 
 		total = data_config_union_config_union[1]["guild_return_num"], 
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


-- 成员列表
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


-- 审核列表 
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


-- 福利列表 
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


-- 大殿
function GuildMgr:RequestEnterMainBuilding(cb) 
	RequestHelper.Guild.enterMainBuilding({ 
		callback = function(data) 
            if cb ~= nil then 
            	cb(data) 
            end 
		end 
	})
end 


-- 帮派动态 
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


-- 帮派作坊  
function GuildMgr:RequestEnterWorkShop(cb) 
	RequestHelper.Guild.enterWorkShop({ 
		callback = function(data) 
            if cb ~= nil then 
            	cb(data) 
            end 
		end 
	})
end


-- 青龙堂 当前状态 
function GuildMgr:RequestBossHistory(cb) 
	RequestHelper.Guild.bossHistory({
		unionId = self.m_guild.m_id, 
        callback = function(data) 
            -- dump(data)
            self:setJopType(data.rtnObj.jobType) 
            if cb ~= nil then 
            	cb(data) 
            end 
        end 
    }) 
end


-- 青龙堂 boss界面 
function GuildMgr:RequestBossState(cb) 
	RequestHelper.Guild.bossState({
		unionId = self.m_guild.m_id, 
        callback = function(data) 
            -- dump(data)
            if cb ~= nil then 
            	cb(data) 
            end 
        end 
    }) 
end


-- 青龙堂 伤害排名 
function GuildMgr:RequestBossRank(cb, errcb)
	RequestHelper.Guild.bossTop({
		unionId = self.m_guild.m_id, 
		errback = function (data)
			if errcb ~= nil then 
				errcb() 
			end 
		end, 
        callback = function(data) 
            -- dump(data)
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
            -- dump(data)
            self:setJopType(data.rtnObj.jopType) 
            if cb ~= nil then 
            	cb(data) 
            end 
        end 
    }) 
end 


-- 进入帮派副本 
function GuildMgr:RequestFubenList(showType, cb, errcb)
	RequestHelper.Guild.enterUnionCopy({
		type = showType, 
		errback = function()
			if errcb ~= nil then 
				errcb() 
			end 
		end, 
        callback = function(data) 
            -- dump(data)
            self:setJopType(data.rtnObj.jopType) 
            if cb ~= nil then 
            	cb(data) 
            end 
        end 
    }) 
end 


-- 进入帮派单个副本 
function GuildMgr:RequestFubenInfo(param)
	local cb = param.cb 
	local errcb = param.errcb 
	RequestHelper.Guild.enterSingleCopy({
		id = param.id, 
		type = param.showType, 
		errback = function()
			if errcb ~= nil then 
				errcb() 
			end 
		end, 
        callback = function(data) 
            dump(data, "单个副本")  
            if cb ~= nil then 
            	cb(data.rtnObj)  
            end 
        end 
    }) 
end 


-- 帮派副本选择侠客界面
function GuildMgr:RequestFubenChooseCard(param)
	local cb = param.cb 
	local errcb = param.errcb 
	RequestHelper.Guild.chooseCard({
		errback = function()
			if errcb ~= nil then 
				errcb() 
			end 
		end, 
        callback = function(data)
        	dump(data)  
            if cb ~= nil then 
            	cb(data.rtnObj)  
            end 
        end 
    }) 
end 


---
-- @param guild info and list
-- 通过两个table是否存在来判断是否加入过帮派
-- 
function GuildMgr:initInfo( param )
	self.m_isInUnion = param.inUnion 
	self.m_isChangeCover = param.changeCover 
	self.m_coverVO = param.coverVO 
	self.m_totalGuildNum = param.totalNum or 0 
	self.m_hasApplyedNum = param.applyNum or 0 

	-- 初始化玩家帮派信息
	if(param.union ~= nil) then 
		self:setGuildInfo(param.union)

	-- 初始化帮派列表	
	elseif(param.unionList ~= nil) then
		local guildList = param.unionList
		local len = #guildList
		if(len > 0) then
			self.m_guildList = guildList
		end		
	end


end

---
-- getGuildList
--
function GuildMgr:getGuildList()
	if(self.m_guildList == nil) then
		if(GAME_DEBUG == true) then
			show_tip_label("guild list is nil")
		end
	end
	return self.m_guildList
end


function GuildMgr:setGuildList(guildList) 
	if guildList == nil then 
		self.m_guildList = {} 
	else
		self.m_guildList = guildList 
	end 
end 

---
-- getGuildInfo
--
function GuildMgr:getGuildInfo(  )
	if(self.m_guild == nil) then
		if(GAME_DEBUG == true) then
			show_tip_label(" guild info is nil")
		end
	end
	return self.m_guild
end


function GuildMgr:setGuildInfo(guildInfo) 
	if(self.m_guild == nil) then
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


function GuildMgr:getTotalGuildNum( ... )
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

	
-- 获取建筑最大等级
function GuildMgr:getMaxLevelByType(buildType)
	local maxLv = 0 
	for i, v in ipairs(data_union_union) do 
		if v.type == buildType then 
			if v.level > maxLv then 
				maxLv = v.level 
			end 
		end 
	end 
	return maxLv 
end 


-- 是否已达到最大等级 
function GuildMgr:checkIsReachMaxLevel(buildType, level)
	local reach = false 
	local maxLv = self:getMaxLevelByType(buildType) 
	if level >= maxLv then 
		reach = true 
	end 

	return reach 
end 


-- 获取建筑level当前在表里的id
function GuildMgr:getIdByTypeAndLevel(buildType, level)
	local id 
	for i, v in ipairs(data_union_union) do 
		if v.type == buildType and v.level == level then 
			id = v.id 
		end 
	end 

	ResMgr.showAlert(id, "未在data_union_union表里，找到id, buildType: " .. buildType .. "level: " .. level) 

	return id 
end 


-- 升级消耗的资金
function GuildMgr:getNeedCoin(buildType, level)
	local id = self:getIdByTypeAndLevel(buildType, level) 
	local needCoin = data_union_union[id].usemoney 

	ResMgr.showAlert(needCoin, "未在data_union_union表里，找到usemoney, buildType: " .. buildType .. "level: " .. level) 

	return needCoin 
end 


-- 获取升级到level+1需要的前置建筑等级 
function GuildMgr:getRequireBuildLevel(buildType, level)
	local needType 
	local needLevel 
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
		-- elseif needType == GUILD_BUILD_TYPE.houshandidong and needLv > self.m_guild.m_level then 
		-- 	bNeed = true 
		-- elseif needType == GUILD_BUILD_TYPE.baihu and needLv > self.m_guild.m_level then 
		-- 	bNeed = true 
		-- elseif needType == GUILD_BUILD_TYPE.fuben and needLv > self.m_guild.m_level then 
		-- 	bNeed = true 
		end 

		if bNeed == true then 
			str = "此建筑等级已达到上限，请先提升" .. GUILD_BUILD_NAME[needType] .. "等级" 
		end 
	end 

	return str 
end 

 
 -- 帮派副本 
 -- 根据id和章节type 获得item 
 function GuildMgr:getDataByIdAndType(id, type)
 	local data_union_fuben_union_fuben = require("data.data_union_fuben_union_fuben") 
 	local item 
 	for i, v in ipairs(data_union_fuben_union_fuben) do 
 		if v.guankanum == id and v.chapter == type then 
 			item = v 
 			break 
 		end 
 	end 

 	ResMgr.showAlert(item, "data_union_fuben_union_fuben找不到此副本id: " .. id .. ", 章节type: " .. type) 

 	return item 
 end 




return GuildMgr

