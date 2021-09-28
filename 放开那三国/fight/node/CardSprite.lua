-- FileName: CardSprite.lua 
-- Author: lichenyang 
-- Date: 13-9-29 
-- Purpose: 战斗卡牌类

require "script/animation/XMLActionSprite"
require "script/fight/entity/FightHeroEntity"
require "script/fight/model/FightModel"
require "script/fight/FightDef"
require "script/utils/BTNumerLabel"
CardSprite = class("CardSprite",function ( ... )
	return XMLActionSprite:new()
end)

XMLActionSprite.__index = CardSprite

function CardSprite:ctor( ... )
	self._model      	 = nil	--数据模型
	self._rageNum        = 0	--血量
	self._nameLabel      = nil	--名字
	self._cardSprite	 = nil	--卡牌精灵
	self._endCallback    = nil	--动作完成回调
	self._keyCallback    = nil	--关键帧回调
	self._changeCallback = nil	--动作帧改变回调
	self._hpLine		 = nil 	--卡牌血条
	self._rageIcons      = {}   --怒气图标
	self._rageEffectIcons= {}	--怒气特效图标
	self._buffers      	 = {} 	--bufferId 卡牌身上存在的buffer {bufferId =  buferrEffectIcon}
	self._isEnemy	     = nil  --是否是敌方卡牌
	self._hpNum			 = 0 	--玩家当前血量
	self._bufferIcons	 = {} 	--当前存在的buffer
	self._isDead	     = false--当前存在的buffer
end

--[[
	@des:创建卡牌
	@parm: pHtid 卡牌hid
--]]
function CardSprite:createWithHtid( pHtid )
	local card = CardSprite:new()
	card._model = FightHeroEntity:createWithHtid(pHtid)
    card:setAnchorPoint(ccp(0.5, 0))
    card:initCard()
    card:setCascadeOpacityEnabled(true)
    card:setCascadeColorEnabled(true)
    return card
end


--[[
	@des:创建卡牌
	@parm: pHid 玩家id
--]]
function CardSprite:createWithHid( pHid )
	local card = CardSprite:new()
	card._model = FightHeroEntity:createWithHid(pHid)
    card:setAnchorPoint(ccp(0.5, 0))
    card:initCard()
    card:setCascadeOpacityEnabled(true)
    card:setCascadeColorEnabled(true)
	return card
end

--[[
	@des:初始化卡牌
--]]
function CardSprite:initCard()
	local starLv   = self._model:getStartLevel()
    --阴影背景
    local cardTypeDes = "card/"
    local rageIconName = "nomal.png"
    if self._model:getCardType() == CardType.BOSS 
    	or self._model:getCardType() == CardType.BLACK_BOSS then
    	cardTypeDes = "bigcard/"
    	rageIconName = "big.png"
    end
    if self._model:getCardType() == CardType.GOD_BOSS then
    	--武将形象
		--卡牌背景
		local cardPath = "images/battle/" .. cardTypeDes
		local shadowSpriet = CCSprite:create(cardPath .. "card_shadow.png")
		self:setContentSize(shadowSpriet:getContentSize())
		
		local tempBg = CCSprite:create(cardPath .. "card_" .. starLv .. ".png")

		self._bgSprite = CCSprite:create()
		self._bgSprite:setContentSize(tempBg:getContentSize())
		self._bgSprite:setAnchorPoint(ccp(0.5, 0))
		self._bgSprite:setPosition(self:getContentSize().width * 0.5, self:getContentSize().height * 0.1)
		self:addChild(self._bgSprite)

		--武将形象
		local bodyImagePath = self._model:getBodyImagePath()
		local offset = self._model:getBodyOffset()
		print("bodyImagePath:",bodyImagePath, offset)
		local bodySprite = CCSprite:create(bodyImagePath)
		bodySprite:setAnchorPoint(ccp(0.5, 0))
		bodySprite:setPosition(ccp(0.5*self._bgSprite:getContentSize().width, offset))
		self._bgSprite:addChild(bodySprite,4)
		return
	end
	--卡牌背景
	local cardPath = "images/battle/" .. cardTypeDes
	self:initWithFile(cardPath .. "card_shadow.png")
	
	self._bgSprite = CCSprite:create(cardPath .. "card_" .. starLv .. ".png")
	self._bgSprite:setAnchorPoint(ccp(0.5, 0))
	self._bgSprite:setPosition(self:getContentSize().width * 0.5, self:getContentSize().height * 0.09)
	self:addChild(self._bgSprite)
	self._bgSprite:setCascadeOpacityEnabled(true)

	--卡牌背景花纹
	local heroBgSprite = CCSprite:create(cardPath .. "card_hero_bg.png");
    heroBgSprite:setAnchorPoint(ccp(0.5,0))
    heroBgSprite:setPosition(self._bgSprite:getContentSize().width/2,self._bgSprite:getContentSize().height*0.17)
    self._bgSprite:addChild(heroBgSprite,0,8)

	--武将形象
	local bodyImagePath = self._model:getBodyImagePath()
	local offset = self._model:getBodyOffset()
	print("bodyImagePath:",bodyImagePath, offset)
	local bodySprite = CCSprite:create(bodyImagePath)
	bodySprite:setAnchorPoint(ccp(0.5, 0))
	bodySprite:setPosition(ccp(0.5*self._bgSprite:getContentSize().width, offset))
	self._bgSprite:addChild(bodySprite,4)

	--顶部花纹
	local topSprint = CCSprite:create(cardPath .. "card_" .. starLv .. "_top.png")
    topSprint:setAnchorPoint(ccp(0,1))
    topSprint:setPosition(0,self._bgSprite:getContentSize().height)
    self._bgSprite:addChild(topSprint,1,2)

    --血条背景
    self._hpLineBg = CCSprite:create(cardPath .. "hpline_bg.png")
    self._hpLineBg:setAnchorPoint(ccp(0.5,0.5))
    self._hpLineBg:setPosition(self._bgSprite:getContentSize().width*0.5,self._bgSprite:getContentSize().height*-0.05)
    self._bgSprite:addChild(self._hpLineBg,1)
    self._hpLineBg:setCascadeOpacityEnabled(true)
    self._bgSprite:setCascadeColorEnabled(true)
	self._hpLineBg:setVisible(false)

    --血条
    self._hpLine = CCSprite:create(cardPath .. "hpline.png")
    self._hpLine:setAnchorPoint(ccp(0,0.5))
    self._hpLine:setPosition(0,self._hpLineBg:getContentSize().height*0.5)
    self._hpLineBg:addChild(self._hpLine,1)
    
    --名称
    local nameColor = HeroPublicLua.getCCColorByStarLevel(self._model:getDBConfig().potential)
    self._nameLabel  = CCRenderLabel:create(self._model:getName(), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    self._nameLabel:setPosition(ccp(self:getContentSize().width/2, self:getContentSize().height))
    self._nameLabel:setAnchorPoint(ccp(0.5, 0))
    self._nameLabel:setColor(nameColor)
    self:addChild(self._nameLabel, 1000)

  	
  	self._rageSprite = CCSprite:create("images/battle/anger/"..rageIconName)
    self._rageSprite:setAnchorPoint(ccp(0.5,0))
    self._rageSprite:setPosition(self._bgSprite:getContentSize().width*0.7, 5)
    self._bgSprite:addChild(self._rageSprite,10,8881)
    self._rageSprite:setCascadeOpacityEnabled(true)
    self._rageSprite:setCascadeColorEnabled(true)
    
	local xSprite = CCSprite:create("images/battle/anger/X.png")
    xSprite:setAnchorPoint(ccp(0,0))
    xSprite:setPosition(self._rageSprite:getContentSize().width,0)
    self._rageSprite:addChild(xSprite,1,1299)
    
    self._numberSprite = BTNumerLabel:createWithPath("images/battle/anger",0)
    self._numberSprite:setAnchorPoint(ccp(0,0))
    self._numberSprite:setPosition(self._rageSprite:getContentSize().width+xSprite:getContentSize().width,0)
    self._rageSprite:addChild(self._numberSprite,1,1290)
    self._rageSprite:setVisible(false)

    local effectPath = "images/battle/effect/lvdou"
    if self._model:isOpenGodUnion() then
        effectPath = "images/battle/effect/honggouyu"
    end
    for i=1,4 do
    	--怒气满特效
		local rageEffectStar = XMLSprite:create(effectPath)
		rageEffectStar:setAnchorPoint(ccp(0.5,0.5))
		self._bgSprite:addChild(rageEffectStar)
		rageEffectStar:setVisible(false)

		local rageSpritePath = "images/battle/"
		local regeSpritePos = nil
		if(self:getContentSize().width>150)then
			rageEffectStar:setPosition(22+(i-1)*20,19)
			rageEffectStar:setScale(1.5)
			rageSpritePath = rageSpritePath .. "bigcard/anger.png"
			regeSpritePos = ccp(22+(i-1)*20,19)
		else
			rageEffectStar:setPosition(14+(i-1)*14,12)
			rageSpritePath = rageSpritePath .. "card/anger.png"
			regeSpritePos = ccp(14+(i-1)*14,12)
		end
		--怒气图标
		local rageSpriteStar = CCSprite:create(rageSpritePath)
		rageSpriteStar:setAnchorPoint(ccp(0.5,0.5))
		rageSpriteStar:setPosition(regeSpritePos)
		self._bgSprite:addChild(rageSpriteStar)
		rageSpriteStar:setVisible(false)
		
		self._rageEffectIcons[i] = rageEffectStar
		self._rageIcons[i] = rageSpriteStar
	end
	--死亡检查
	if self:getEntity():getInitHp() == 0 then
		self:setIsDead(true)
		print("card card is Dead", self:getEntity():getName())
	else
		print("MaxHp:",self._model:getMaxHp())
		--更新血量和怒气显示
		self:setHp(self._model:getInitHp())
		self:setRage(self._model:getRage())
		print(self:getEntity():getName() .. "[".. self:getEntity():getHid()  .."]".. "-Maxhp:"..self._hpNum)
	end
end


function CardSprite:getEntity()
	return self._model
end

function CardSprite:setIsEnemy( pIsEnemy )
	self._isEnemy = pIsEnemy
end

function CardSprite:isEnemy()
	return self._isEnemy
end

function CardSprite:clone()

end

--[[
	@des:设置卡牌血量
--]]
function CardSprite:setHp( pHpNum )
	if not self._hpLine then
		return
	end
	self._hpNum = pHpNum
	local scale = tonumber(self._hpNum)/tonumber(self._model:getMaxHp())
	local textureSize = self._hpLine:getTexture():getContentSize()
    scale = scale>1 and 1 or scale
    scale = scale<0 and 0 or scale
    print("setHp scale:", scale)
    self._hpLine:setTextureRect(CCRectMake(0,0,textureSize.width*scale,textureSize.height))
end

--[[
	@des:设置怒气值
--]]
function CardSprite:setRage( pNum )
	if not self._rageSprite then
		return
	end 
	self._rageNum = pNum
	self._numberSprite:setString(self._rageNum)
	if self._rageNum > 4 then
		self._rageSprite:setVisible(true)
		
	else
		self._rageSprite:setVisible(false)
	end
	for k,v in pairs(self._rageIcons) do
		v:setVisible(false)
	end
	for k,v in pairs(self._rageEffectIcons) do
		v:setVisible(false)
	end
	if self._rageNum >= 4 then
		for k,v in pairs(self._rageIcons) do
			v:setVisible(false)
		end
		for k,v in pairs(self._rageEffectIcons) do
			v:setVisible(true)
		end
	else
		for i=1,self._rageNum do
			self._rageIcons[i]:setVisible(true)
			self._rageEffectIcons[i]:setVisible(false)
		end
	end
end

--[[
	@des:增加卡牌血量
--]]
function CardSprite:addHp( pHpNum )
	print(self:getEntity():getName() .."[".. self:getEntity():getHid()  .."]".. "-SubHp:"..pHpNum)
	self._hpNum = self._hpNum + tonumber(pHpNum)
	self:setHp(self._hpNum)
	print(self:getEntity():getName() .."[".. self:getEntity():getHid()  .."]".. "-hp:"..self._hpNum)
end

--[[
	@des:增加卡牌怒气
--]]
function CardSprite:addRage( pRageNum )

	self._rageNum = self._rageNum + tonumber(pRageNum)
	self:setRage(self._rageNum)
end

--[[
	@des:隐藏或显示血量显示
--]]
function CardSprite:setHpVisible( pVisible )
	if not tolua.isnull(self._hpLineBg) then
		self._hpLineBg:setVisible(pVisible)
	end
end

--[[
	@des:隐藏或者显示怒气值
--]]
function CardSprite:setRageVisible( pVisible )
	if not tolua.isnull(self._rageSprite) then
		if self._rageNum > 4 and pVisible then
			self._rageSprite:setVisible(true)
		end
		if pVisible then
			self:setRage(self._rageNum)
		else
			for k,v in pairs(self._rageIcons) do
				v:setVisible(false)
			end
			for k,v in pairs(self._rageEffectIcons) do
				v:setVisible(false)
			end
		end
	end
end

--[[
	@des:隐藏或者显示卡牌名称
--]]
function CardSprite:setNameVisible( pVisible )
	if self._nameLabel then
		self._nameLabel:setVisible(pVisible)
	end
end

--[[
	@des:设置是否死亡
--]]
function CardSprite:setIsDead( pIsDead )
	self._isDead = pIsDead
end

--[[
	@des:是否死亡
--]]
function CardSprite:getIsDead()
	if tolua.isnull(self) then
		return true
	end
	return self._isDead
end

--[[
	@des:播放减血特效
	@parm:pBloodNum 显示减掉血的总量
	@parm:pSubCount 总减血次数
	@parm:pIsFatal	是否显示暴击效果
	@pram:bufferId  伤害的bufferId
	@ret:void
--]]
function CardSprite:showAddHpEffect( pHpNum, pSubCount, pIsFatal, pBufferId, pCallback)

	if self:getIsDead() then
		return
	end
	local numberPath = "images/battle/number/red"
	local sign = "-"
	if pIsFatal then
		numberPath = "images/battle/number/critical"
	end
	if tonumber(pHpNum) >= 0 then
		--加血
		numberPath = "images/battle/number/green"
		sign = "+"
	end
	if pSubCount < 1 then
		pSubCount = 1
	end
	local tipNodeInfo = {}
	--伤害标题
	if pBufferId then
		local dbBuffer = DB_Buffer.getDataById(pBufferId)
		if dbBuffer.damagetitle then
			local tipSprite = CCSprite:create("images/battle/number/"..dbBuffer.damagetitle)
			table.insert(tipNodeInfo, tipSprite)
		end
	end

	--伤害数字
	local hpNum = math.abs(math.floor(pHpNum/pSubCount)) .. ""
	local hpNumLabel = BTNumerLabel:createWithPath(numberPath,0)
	hpNumLabel:setString(sign .. hpNum)
	if pHpNum < 0 then
		self:setColor(ccc3(255,0,0))
	end
	table.insert( tipNodeInfo, hpNumLabel)

	--标题
	local tipNode = BaseUI.createHorizontalNode(tipNodeInfo)
	tipNode:setPosition(self:convertToWorldSpace(ccpsprite(0.5, 0.5, self)))
	tipNode:setAnchorPoint(ccp(0.5, 0.5))
	FightScene.getFightLayer():addChild(tipNode, ZOrderType.TIP)
	tipNode:setScale(g_fElementScaleRatio)
	if pSubCount>1 then
		local width = self:getContentSize().width
		local height = self:getContentSize().height
		local rx = width/2 + math.random(-width*0.3, width*0.3)
		local ry = height*0.5+math.random(-width*0.3,width*0.3)
		tipNode:setPosition(self:convertToWorldSpace(ccp(rx, ry)))
	end
	--掉血特效
	local actionArray = CCArray:create()
	actionArray:addObject(CCScaleTo:create(g_fElementScaleRatio*0.1,g_fElementScaleRatio*2))
	actionArray:addObject(CCScaleTo:create(g_fElementScaleRatio*0.05,g_fElementScaleRatio*1))
	actionArray:addObject(CCCallFuncN:create(function ( pNode )
		if not tolua.isnull(self) then
    		self:setColor(ccc3(255,255,255))
    	end
    end))
	actionArray:addObject(CCDelayTime:create(1))
	actionArray:addObject(CCScaleTo:create(g_fElementScaleRatio*0.08,g_fElementScaleRatio*0.01))
	actionArray:addObject(CCCallFuncN:create(function ( pNode )
    	pNode:removeFromParentAndCleanup(true)
    end))
    tipNode:runAction(CCSequence:create(actionArray))
end

--[[
	@des:显示怒气改变效果
--]]
function CardSprite:showAddRageEffect( pRageNum, pCallback )
	if self:getIsDead() then
		return
	end
	local upImage = "images/battle/number/angerup.png"
	local downImage = "images/battle/number/angerdown.png"
	local iconSprite = nil
	local moveOff = ccp(0,0)
	if pRageNum > 0 then
		iconSprite = CCSprite:create(upImage)
		iconSprite:setPosition(ccpsprite(0.5, 0.2, self))
		moveOff = ccpsprite(0, 0.7, self)
	else
		iconSprite = CCSprite:create(downImage)
		iconSprite:setPosition(ccpsprite(0.5, 0.8, self))
		moveOff = ccpsprite(0, -0.7, self)
	end
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	self:addChild(iconSprite, 200)

	local actionArray = CCArray:create()
	actionArray:addObject(CCMoveBy:create(1.5, moveOff))
	actionArray:addObject(CCCallFuncN:create(function ( pNode )
		pNode:removeFromParentAndCleanup(true)
	end))
	iconSprite:runAction(CCSequence:create(actionArray))
end


--[[
	@des:添加buffer图标
	@parm: buffer id
--]]
function CardSprite:addBufferIcon( pBufferId )
	print("CardSprite:addBufferIcon", pBufferId)
	--buffer已存在则不添加
	if self._bufferIcons[pBufferId] then
		self._bufferIcons[pBufferId].retain = self._bufferIcons[pBufferId].retain + 1 
		return
	end

	local bufferDBInfo = DB_Buffer.getDataById(pBufferId)
	local pos = bufferDBInfo.positon 
	local bufferIconName = bufferDBInfo.icon
	print("add buffer bufferIconName:", bufferIconName)
	if bufferIconName == nil then
		return
	end
	local posMap = {
        [CardEffectPos.HEAD] = ccpsprite(0.5, 0.85, self),
        [CardEffectPos.HERT] = ccpsprite(0.5, 0.5, self),
        [CardEffectPos.FOOT] = ccpsprite(0.5, 0.2, self),
    }
    local bufferPos = posMap[pos]
    --buffer持续特效添加
	local bufferIconPath = FightUtil.getEffectPath(bufferIconName, 30 ,true)
	local bufferEff      = XMLSprite:create(bufferIconPath)
	bufferEff:setPosition(bufferPos)
	self:addChild(bufferEff, 200)
	self._bufferIcons[pBufferId] = {}
	self._bufferIcons[pBufferId].icon   = bufferEff
	self._bufferIcons[pBufferId].retain = 1
	print("add buffer:", bufferIconPath)
end

--[[
	@des:删除buffer 图标
	@parm: bufferId
--]]
function CardSprite:removeBufferIcon( pBufferId )
	local bufferInfo = self._bufferIcons[pBufferId]
	if bufferInfo then
		bufferInfo.retain = bufferInfo.retain - 1
		if bufferInfo.retain <= 0 then
			bufferInfo.icon:removeFromParentAndCleanup(true)
			bufferInfo.icon = nil
			self._bufferIcons[pBufferId] = nil
		end
	end
end

--[[
	@des:清除buffer
--]]
function CardSprite:removeAllBuffer()
	for k,v in pairs(self._bufferIcons) do
		if not tolua.isnull(v) then
			v:removeFromParentAndCleanup(true)
		end
	end
	self._bufferIcons = {}
end

