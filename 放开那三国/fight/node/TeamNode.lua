-- FileName: TeamNode.lua 
-- Author: lichenyang 
-- Date: 13-9-29 
-- Purpose: 战斗卡牌阵型类
TeamNode = class("TeamNode", function ( ... )
	return CCLayer:create()
end)

local Z_CARD 	= 10	
local Z_CRAFT 	= -1000

function TeamNode:ctor( ... )
	self._cardMap = {} 	--卡牌数组
	self._gridMap = {}	--卡牌格子
	self._frameMap = {} --卡牌边框
end

--[[
	@des:创建一个阵型
--]]
function TeamNode:createWithIds( pHids )
	local instance = TeamNode:new()
	instance:initWithIds(pHids)
	return instance
end

--[[
	@des:初始化卡牌
	@parm:pHids hid
--]]
function TeamNode:initWithIds( pHids )
	for i=1,6 do
		if pHids[i] and tonumber(pHids[i]) ~= 0 then
			--卡牌
			self:setHeroByPos(pHids[i], i)
		end
		self:setFrameByPos(i)
		self:setGridByPos(i)
	end
	self:setContentSize(CCSizeMake(640*g_fScaleX, 0.48*640*g_fScaleX))
end

--[[
	@des:修改武将
	@parm:pHid 武将id
	@parm:pPos 武将位置
--]]
function TeamNode:setHeroByPos( pHid, pPos )
	if self._cardMap[pHid] ~= nil then
		self._cardMap[pHid]:removeFromParentAndCleanup(true)
		self._cardMap[pHid] = nil
	end
	local card = CardSprite:createWithHid(pHid)
	print("setHeroByPos pPos", pHid, pPos)
	card._model:setPosNum(tonumber(pPos))
	card:setPosition(self:convertPNToPos(card._model:getPosNum()))
	card:setAnchorPoint(ccp(0.5, 0.5))
	card:setHpVisible(true)
	card:setRageVisible(true)
	self:addChild(card, tonumber(pPos))
	card:setScale(g_fScaleX)
	self._cardMap[tonumber(pHid)] = card
end

--[[
	@des:初始化法阵效果
	@parm:pCraftInfo 法阵信息
--]]
function TeamNode:initCraftNode( pCraftInfo )
	local craftNode = FightCraftNode:createWithInfo(pCraftInfo)
	if self._isEnemy == true then 
		craftNode:setPosition(ccps(0.5, 0.79))
	else
		craftNode:setPosition(ccps(0.5, 0.21))
	end
	FightScene.getFightLayer():addChild(craftNode, ZOrderType.WAR)
	craftNode:setScale(g_fElementScaleRatio)
end

--[[
	@des:得到card
	@parm:pHid
	@ret:void
--]]
function TeamNode:getCardByHid( pHid )
	return self._cardMap[tonumber(pHid)]
end

--[[
	@des:得到card
	@parm:pPos
	@ret:void
--]]
function TeamNode:getCardByPos( pPos )
	for k,v in pairs(self._cardMap) do
		if tonumber(v:getEntity():getPosNum()) == tonumber(pPos) then
			return v
		end
	end
	return nil
end


--[[
	@des:得到card
	@parm:pHid
	@ret:void
--]]
function TeamNode:getGridByPos( pPos )
	return self._gridMap[tonumber(pPos)]
end

--[[
	@des:得到卡牌边框
	@parm:pHid
	@ret:void
--]]
function TeamNode:getFrameByPos( pPos )
	return self._frameMap[tonumber(pPos)]
end

--[[
	@des:设置卡牌边框
	@parm:pHid
	@ret:void
--]]
function TeamNode:setFrameByPos( pPos )
	if self._frameMap[tonumber(pPos)] then 
		self._frameMap[tonumber(pPos)]:removeFromParentAndCleanup(true)
		self._frameMap[tonumber(pPos)] = nil
	end
	local frameSprite = CCSprite:create("images/battle/card/card_bg.png")
	frameSprite:setAnchorPoint(ccp(0.5, 0.5))
	frameSprite:setPosition(self:convertPNToPos(pPos))
	self:addChild(frameSprite, 1)
	frameSprite:setVisible(false)
	frameSprite:setScale(g_fScaleX)
	self._frameMap[tonumber(pPos)] = frameSprite
end

--[[
	@des:设置卡牌格子
--]]
function TeamNode:setGridByPos( pPos )
	--卡牌（用来在上面播放特效）
	local gridSprite = CCSprite:create()
	gridSprite:setAnchorPoint(ccp(0.5, 0.5))
	gridSprite:setContentSize(CCSizeMake(80,80))
	gridSprite:setPosition(self:convertPNToPos(pPos))
	self:addChild(gridSprite, 1)
	gridSprite:setScale(g_fScaleX)
	self._gridMap[pPos] = gridSprite	
end

--[[
	@des:计算坐标
	@parm:根据位置计算 pPosNum
	@ret:ret 描述
--]]
function TeamNode:convertPNToPos( pPosNum )
	local pos = pPosNum - 1
	local cardWidth = 640*0.2;
    local startX = 0.20*640;
    local startY = 960/g_fScaleX - cardWidth*2.4;
    return ccp(startX+pos%3*cardWidth*1.4, startY+math.floor(pos/3)*(cardWidth*1.2)*1.2)
end

--[[
	@des:播放行走动作
--]]
function TeamNode:playWalkEffect( )
	local playNum = 0
	local playCallback = function ()
		playNum = playNum + 1
		if playNum >= table.count(self._cardMap) then
			--播放行走音效
			playNum = 0
		end
	end
	local walkEffect = "walk0" .. math.floor(math.random()*5+1)
	self._walkMusicId = AudioUtil.playEffect("audio/effect/" .. walkEffect .. ".mp3", true)
	for k,v in pairs(self._cardMap) do
		if not v:getIsDead() then
			actionPath = FightUtil.getActionXmlPaht(CardAction.walk)
	        v:runXMLAction(actionPath, true)
	        v:registerActionEndCallback(playCallback)
	    end
	end
end

--[[
	@des:停止播放行走动作
--]]
function TeamNode:stopAction()
	for k,v in pairs(self._cardMap) do
        v:stop()
	end
	SimpleAudioEngine:sharedEngine():stopEffect(self._walkMusicId)
end

--[[
	@des:播放死亡动画
--]]
function TeamNode:playDeadEffect()
    for k,v in pairs(self._cardMap) do
    	if v:getIsDead() then
    		print("playDeadEffect",v:getEntity():getName())
    		v:setVisible(true)
    		v:setOpacity(255)
    		v:setCascadeOpacityEnabled(true)
    		local actionArray = CCArray:create()
		    actionArray:addObject(CCFadeIn:create(0.5))
		    actionArray:addObject(CCFadeOut:create(0.5))
		    local action = CCRepeatForever:create(CCSequence:create(actionArray))
    		v:runAction(action)
    	end
    end
end

--[[
	@des:显示血量
	@parm:pVisible 是否显示
	@ret:nil
--]]
function TeamNode:setHpVisible( pVisible )
	for k,v in pairs(self._cardMap) do
		v:setHpVisible(pVisible)
	end
end

--[[
	@des:显示怒气
	@parm:pVisible 是否显示
	@ret:nil
--]]
function TeamNode:setRageVisible( pVisible )
	for k,v in pairs(self._cardMap) do
		v:setRageVisible(pVisible)
	end
end

--[[
	@des:显示名称
	@parm:pVisible 是否显示
	@ret:nil
--]]
function TeamNode:setNameVisible( pVisible )
	for k,v in pairs(self._cardMap) do
		v:setNameVisible(pVisible)
	end
end

--[[
	@des:设置玩家是否是地方玩家
	@parm:pIsEnemey 
--]]
function TeamNode:setIsEnemy( pIsEnemey )
	for k,v in pairs(self._cardMap) do
		v:setIsEnemy(pIsEnemey)
	end
end

--[[
	@des:设置卡牌是否显示
--]]
function TeamNode:setCardVisible( pVisible )
	for k,v in pairs(self._cardMap) do
		v:setVisible(pVisible)
	end
end

--[[
	@des:设置卡牌框是否显示
--]]
function TeamNode:setCardFrameVisible( pVisible )
	for k,v in pairs(self._frameMap) do
		v:setVisible(pVisible)
		print("setCardFrameVisible", k)
	end
end

--[[
	@des:清除卡牌上所有的buffer
--]]
function TeamNode:removeBuffer()
	for k,v in pairs(self._cardMap) do
		v:removeAllBuffer()
	end
end

--[[
	@des:得到所有卡牌
--]]
function TeamNode:getCards()
	return self._cardMap;
end
