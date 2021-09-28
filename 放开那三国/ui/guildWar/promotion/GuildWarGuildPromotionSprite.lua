-- FileName: GuildWarGuildPromotionSprite.lua 
-- Author: bzx
-- Date: 15-1-13 
-- Purpose: 军团从16强到冠军的节点

require "script/ui/guild/GuildUtil"

GuildWarGuildPromotionSprite = class("GuildWarGuildPromotionSprite", function ( ... )
	return CCSprite:create()
end)

GuildWarGuildPromotionSprite._guildTrapeziumInfo		= {}
GuildWarGuildPromotionSprite._rank 						= 0
GuildWarGuildPromotionSprite._bg 						= nil
GuildWarGuildPromotionSprite._guildIcon 				= nil
GuildWarGuildPromotionSprite._fightForceLabel  			= nil
GuildWarGuildPromotionSprite._guildNameLabel  			= nil
GuildWarGuildPromotionSprite._serverNameLabel 			= nil
GuildWarGuildPromotionSprite._layerName 				= nil

--[[
	@desc: 		创建一个对象
	@p_guildId:	军团ID
	@p_rank:	指定排名
	@return:	GuildWarGuildPromotionSprite
--]]
function GuildWarGuildPromotionSprite:createByGuildId(p_guildId, p_rank)
	--local guildData = --todo
	local ret = self:createByGuildData(guildData, p_rank)
	return ret
end

--[[
	@desc:												创建一个对象
	@param:		table 	p_guildTrapeziumInfo			
	@param:		number 	p_rank							指定的排名
	@return:	GuildWarGuildPromotionSprite
--]]
function GuildWarGuildPromotionSprite:createByGuildData(p_guildTrapeziumInfo, p_rank, p_layerName)
	local ret = GuildWarGuildPromotionSprite:new()
	ret:init()
	ret:initData(p_guildTrapeziumInfo, p_rank, p_layerName)
	ret:loadBg()
	ret:showRankSprite()
	if p_guildTrapeziumInfo ~= nil then
		ret:loadGuildIcon()
		ret:loadFightForce()
		ret:loadName()
	end
	return ret
end

--[[
	@return:	nil
--]]
function GuildWarGuildPromotionSprite:init( ... )
	self._guildTrapeziumInfo = {}
	self._rank = 0
	self._bg = nil
	self._isShowBgEffect = false
	self._guildIcon = nil
	self._fightForceLabel = nil
	self._layerName = ""
end

--[[

	@return:	nil
--]]
function GuildWarGuildPromotionSprite:initData(p_guildTrapeziumInfo, p_rank, p_layerName)
	if p_guildTrapeziumInfo ~= nil then
		self._guildTrapeziumInfo = table.hcopy(p_guildTrapeziumInfo, {})
	end
	self._rank = p_rank
	self._isShowBgEffect = false
	self._layerName = p_layerName
end

--[[ 
	@desc:		显示背景
	@return:	nil
--]]
function GuildWarGuildPromotionSprite:loadBg( ... )
	if self._rank == 16 then
		self._bg = CCSprite:create("images/guild_war/16_bg.png")
		self._bg:setContentSize(CCSizeMake(115, 113))
	elseif self._rank == 4 then
		self._bg = CCSprite:create("images/guild_war/4_bg.png")
	elseif self._rank == 1 then
		self._bg = CCSprite:create("images/guild_war/champion_bg.png")
	end
	self:setContentSize(self._bg:getContentSize())
	self:addChild(self._bg)
	self._bg:setAnchorPoint(ccp(0.5, 0.5))
	self._bg:setPosition(ccpsprite(0.5, 0.5, self))

	-- 背景上面添加排名标识
	local rankText = ""
	if self._rank ~= 1 then
		rankText = GetLocalizeStringBy("key_8242", self._rank)
	end
	local rankLabel = CCRenderLabel:create(rankText, g_sFontPangWa, 27, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    self._bg:addChild(rankLabel)
    rankLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    rankLabel:setAnchorPoint(ccp(0.5, 0.5))
    rankLabel:setPosition(ccpsprite(0.5, 0.5, self))
    self:showBgEffect()  
end

--[[
	@desc:		显示背景特效
	@return:	nil
--]]
function GuildWarGuildPromotionSprite:showBgEffect( ... )
	local bgEffect = nil
	if self._rank == 4 then
		bgEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/guild_war/effect/juntuansiqiang/juntuansiqiang"), -1, CCString:create(""))
		bgEffect:setPosition(ccpsprite(0.5, 0.5, self))
	elseif self._rank == 1 then
		bgEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/guild_war/effect/juntuanguanjun/juntuanguanjun"), -1, CCString:create(""))
		bgEffect:setPosition(ccpsprite(0.5, 0.51, self))
	end
	if bgEffect ~= nil then
	    self:addChild(bgEffect, -2)
	    bgEffect:setAnchorPoint(ccp(0.5, 0.5))
	end
end

--[[
	@desc:		显示军团Icon
	@return:	nil
--]]
function GuildWarGuildPromotionSprite:loadGuildIcon( ... )
	local guildIcon = GuildUtil.getGuildIcon(self._guildTrapeziumInfo.guildInfo.guild_badge)
	self._bg:addChild(guildIcon)
	guildIcon:setAnchorPoint(ccp(0.5, 0.5))
	if self._rank == 1 then
		guildIcon:setPosition(ccpsprite(0.5, 0.5, self))
	else
		guildIcon:setPosition(ccpsprite(0.5, 0.48, self))
	end
	self._guildIcon = guildIcon
	self:loadCheeredSprite()
	self:loadFailedOrWon()
end

--[[
	@desc:		显示助威标识
	@return:	nil
--]]
function GuildWarGuildPromotionSprite:loadCheeredSprite( ... )
	local guildId, guildServerId = GuildWarMainData.getCheerGuild()
	if (self._layerName == "GuildWar16Layer" and self._rank ~= 4)
		or (self._layerName == "GuildWar4Layer" and self._rank ~= 1)  then
		if guildServerId == tonumber(self._guildTrapeziumInfo.guildInfo.guild_server_id) 
			and guildId == tonumber(self._guildTrapeziumInfo.guildInfo.guild_id) then
			
			local cheeredSprite = CCSprite:create("images/lord_war/yizhuwei.png")
	        self._guildIcon:addChild(cheeredSprite)
	        cheeredSprite:setAnchorPoint(ccp(0, 0.5))
	        cheeredSprite:setPosition(ccp(45, 100))
		end
	end
end

--[[
	@desc:		显示失败或者胜利的标识
	@return:	nil
--]]
function GuildWarGuildPromotionSprite:loadFailedOrWon( ... )
	local resultSprite = nil
	if self._guildTrapeziumInfo.guildStatus == GuildWarDef.kGuildFail then
		resultSprite = CCSprite:create("images/olympic/lost.png")
	elseif self._guildTrapeziumInfo.guildStatus == GuildWarDef.kGuildWin then
		resultSprite = CCSprite:create("images/olympic/win.png")
	end
	if resultSprite ~= nil then
		self._guildIcon:addChild(resultSprite, 10)
		resultSprite:setAnchorPoint(ccp(0.5, 0.5))
		resultSprite:setPosition(ccp(12, 80))
	end
end

--[[
	@desc:		显示战斗力
	@return:	nil
--]]
function GuildWarGuildPromotionSprite:loadFightForce( ... )
	local fightSp = CCSprite:create("images/lord_war/fight_bg.png")
	self:addChild(fightSp)
	fightSp:setAnchorPoint(ccp(0.5,0.5))
	fightSp:setPosition(ccp(self:getContentSize().width * 0.5 + 5, 2))
	-- 战斗力数值
	local fightForceLabel = CCRenderLabel:create(self._guildTrapeziumInfo.guildInfo.fight_force, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
   	fightSp:addChild(fightForceLabel)
    fightForceLabel:setColor(ccc3(0xff,0x00,0x00))
    fightForceLabel:setAnchorPoint(ccp(0,0.5))
    fightForceLabel:setPosition(ccp(34, fightSp:getContentSize().height*0.5))
   	self._fightForceLabel = fightLable
end

--[[
	@desc:		显示军团名称和服务器名
	@return: 	nil
--]]
function GuildWarGuildPromotionSprite:loadName( ... )
	local fontName = nil
	if self._rank >= 4 then
		fontName = g_sFontPangWa
	else
		fontName = g_sFontName
	end
	local guildNameLabel = CCRenderLabel:create(self._guildTrapeziumInfo.guildInfo.guild_name, fontName, 22, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	self:addChild(guildNameLabel)
    guildNameLabel:setColor(ccc3(0xff, 0xff, 0xff))
    guildNameLabel:setAnchorPoint(ccp(0.5, 0.5))
   	guildNameLabel:setPosition(ccp(self:getContentSize().width * 0.5, -18))
   	-- 如果是自己的军团变色
    if self._guildTrapeziumInfo.guildInfo.guild_server_id == GuildWarMainData.getMyServerId() 
      and self._guildTrapeziumInfo.guildInfo.guildId == tostring(GuildDataCache.getMineSigleGuildId()) then
        guildNameLabel:setColor(ccc3(0xE4, 0x00, 0xFF))
    end

    -- 服务器名字
    local serverNameLabel = CCRenderLabel:create( string.format("(%s)", self._guildTrapeziumInfo.guildInfo.guild_server_name), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    self:addChild(serverNameLabel)
    serverNameLabel:setColor(ccc3(0xff,0xff,0xff))
    serverNameLabel:setAnchorPoint(ccp(0.5,0.5))
    serverNameLabel:setPosition(ccp(self:getContentSize().width * 0.5, -40))
end

--[[	
	@desc:		显示背景上面的排名标识
	@return: 	nil
--]]
function GuildWarGuildPromotionSprite:showRankSprite( ... )
	if self._rank == 1 then
		-- local rankSprite = CCSprite:create("images/guild_war/champion_title.png")
		-- self._bg:addChild(rankSprite)
		-- rankSprite:setAnchorPoint(ccp(0.5,0))
		-- rankSprite:setPosition(ccp(self._bg:getContentSize().width * 0.5, self._bg:getContentSize().height - 10))
		-- 特效
		local rankAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/guild_war/effect/guanjunbiaoti/guanjunbiaoti"), -1,CCString:create(""))
		self._bg:addChild(rankAnimSprite)
	 	rankAnimSprite:setAnchorPoint(ccp(0.5, 0))
		rankAnimSprite:setPosition(ccp(self._bg:getContentSize().width * 0.5, self._bg:getContentSize().height + 30))
		-- rankAnimSprite:setPosition(ccpsprite(0.5, 0.2, rankSprite))
	end
end

--[[
	@desc: 		播放晋级特效
	@return:	nil
--]]
function GuildWarGuildPromotionSprite:showWinEffect( ... )
	local  winEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/kuang/kuang"), -1, CCString:create(""))
    self:addChild(winEffect,11)
    winEffect:setAnchorPoint(ccp(0.5,0.5))
    winEffect:setPosition(hero_node:getContentSize().width * 0.5,hero_node:getContentSize().height/2)
    winEffect:retain()
    
    -- 注册代理
    -- 胜利特效
    local winEffectCallBack = function( ... )
        if( winEffect ~= nil )then
            winEffect:release()
            winEffect:removeFromParentAndCleanup(true)
            winEffect = nil
        end
    end
    local downDelegate = BTAnimationEventDelegate:create()
    downDelegate:registerLayerEndedHandler(winEffectCallBack)
    winEffect:setDelegate(downDelegate)
end