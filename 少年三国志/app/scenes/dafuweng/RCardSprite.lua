local RCardSprite = class("RCardSprite")
local EffectNode = require "app.common.effects.EffectNode"

RCardSprite.bgImg = {{"ui/dafuweng/fanpai_xingyun_zhengmian.png","ui/dafuweng/fanpai_xingyun_beimian.png"},
		{"ui/dafuweng/fanpai_haohua_zhengmian.png","ui/dafuweng/fanpai_haohua_beimian.png"}} --1正2背
		-- "ui/zhengrong/buzheng-caowei.png"
function RCardSprite:ctor()
	local node = Widget:create()
	local bgImg = ImageView:create()
	bgImg:loadTexture(RCardSprite.bgImg[1][2])
	node:addChild(bgImg,1)
	bgImg:setPositionXY(0,0)
	bgImg:setScale(1)

	local boardBg = ImageView:create()
	boardBg:loadTexture("putong_bg.png",UI_TEX_TYPE_PLIST)
	node:addChild(boardBg,2)
	boardBg:setPositionXY(0,0)
	boardBg:setVisible(false)
	local iconBoard = ImageView:create()
	boardBg:addChild(iconBoard,1)
	local icon = ImageView:create()
	boardBg:addChild(icon,2)
	local numLabel = GlobalFunc.createGameLabel("", 22, Colors.darkColors.DESCRIPTION, Colors.strokeBrown)
	boardBg:addChild(numLabel,3)
	numLabel:setPositionXY(55,-35)
	numLabel:setAnchorPoint(ccp(1,0.5))

	self.bgEffect = EffectNode.new("effect_around_card",function(event, frameIndex)

	    end
	)      
	self.bgEffect:play()
	node:addNode( self.bgEffect,50)
	self.bgEffect:setPositionXY(0,5)
	self.bgEffect:setScaleX(0.85)
	self.bgEffect:setScaleY(0.73)

	self.iconEffect = EffectNode.new("effect_around1",function(event, frameIndex)

	    end
	)      
	self.iconEffect:play()
	boardBg:addNode( self.iconEffect,50)
	self.iconEffect:setPositionXY(4,-4)
	self.iconEffect:setScale(1.7)
	self.iconEffect:setVisible(false)

	self.node = node
	self.bgImg = bgImg
	self.boardBg = boardBg
	self.iconBoard = iconBoard
	self.icon = icon
	self.numLabel = numLabel
	self.show = false
end

function RCardSprite:setIndex(index)
	self.index = index
end

function RCardSprite:setZTag(zTag)
	self.zTag = zTag
end

function RCardSprite:updateAward(id,info)
	local item = G_Goods.convert(info.type, info.value)
	self.iconBoard:loadTexture(G_Path.getEquipColorImage(item.quality,info.type))
	self.icon:loadTexture(item.icon)
	self.numLabel:setText("x"..info.size)
	self:showAward(id,true)
	self.show = false
	self.bgImg:setScale(1.05)
	self.boardBg:setPositionXY(0,20)
	local nameLabel = GlobalFunc.createGameLabel(item.name, 22, Colors.qualityColors[item.quality], Colors.strokeBrown)
	self.node:addChild(nameLabel,3)
	nameLabel:setPositionXY(0,-45)
	self.nameLabel = nameLabel
	self.iconEffect:setVisible(info.light>0)
end

function RCardSprite:updateData(id,info)
	if info then
		local item = G_Goods.convert(info.type, info.value)
		self.iconBoard:loadTexture(G_Path.getEquipColorImage(item.quality,info.type))
		self.icon:loadTexture(item.icon)
		self.numLabel:setText("x"..info.size)
		self:showAward(id,true)
		self.iconEffect:setVisible(info.light>0)
	else
		self:showAward(id,false)
	end
end

function RCardSprite:hideAward(id)
	self:showAward(id,false)
end

function RCardSprite:showAward(id,show)
	if show then
		self.boardBg:setVisible(true)
		self.show = true
		self.bgEffect:setVisible(false)
		self.bgImg:loadTexture(RCardSprite.bgImg[id][1])
	else
		self.boardBg:setVisible(false)
		self.show = false
		self.bgEffect:setVisible(true)
		self.bgImg:loadTexture(RCardSprite.bgImg[id][2])
	end
end

function RCardSprite:registerTouchEvent(container,callBack)
	self.bgImg:setTouchEnabled(true)
	self.bgImg:setName("bgImg"..self.index)
	container:registerWidgetClickEvent("bgImg"..self.index,function( )
		if not self.show and callBack then
			callBack()
		end
	end)
end

function RCardSprite:flip(id,show,callBack)
	if self.show == show then
		if callBack then
			callBack()
		end
		return
	end
	local seqArr = CCArray:create()
	seqArr:addObject(CCScaleTo:create(0.15,0,1))
	seqArr:addObject(CCCallFunc:create(function()
		self:showAward(id,show)
	end))
	seqArr:addObject(CCScaleTo:create(0.15,1,1))
	seqArr:addObject(CCCallFunc:create(function()
		if callBack then
			callBack()
		end
	end))
	self.node:runAction(CCSequence:create(seqArr))
end

function RCardSprite:move(offset,callBack,playEffect)
	local deltaX = 600
	local deltaY = 350/2+offset*2
	deltaY = self.index>4 and -deltaY or deltaY
	deltaX = ((self.index-1)%4-1.5)*deltaX/4
	local time = 0.3
	local seqArr = CCArray:create()
	seqArr:addObject(CCMoveBy:create(time,ccp(-deltaX,0)))
	seqArr:addObject(CCMoveBy:create(time,ccp(0,-deltaY)))
	seqArr:addObject(CCCallFunc:create(function()
		self.zTag = 30 - self.zTag
		self.node:setZOrder(self.zTag)
	end))
	-- seqArr:addObject(CCMoveBy:create(time,ccp(0,deltaY)))
	-- seqArr:addObject(CCMoveBy:create(time,ccp(deltaX,0)))
	-- seqArr:addObject(CCCallFunc:create(function()
	-- 	if callBack then
	-- 		callBack()
	-- 	end
	-- end))
	-- self.node:runAction(CCSequence:create(seqArr))

	seqArr:addObject(CCMoveBy:create(time/2,ccp(0,deltaY/2)))
	seqArr:addObject(CCCallFunc:create(function()
		local after = function ( ... )
			local seqArr2 = CCArray:create()
			seqArr2:addObject(CCMoveBy:create(time/2,ccp(0,deltaY/2)))
			seqArr2:addObject(CCMoveBy:create(time,ccp(deltaX,0)))
			seqArr2:addObject(CCCallFunc:create(function()
				if callBack then
					callBack()
				end
			end))
			self.node:runAction(CCSequence:create(seqArr2))
		end
		if playEffect then
 			playEffect(after)
	 	end
	end))
	self.node:runAction(CCSequence:create(seqArr))
end

function RCardSprite:setBasePositionXY(x,y)
	self.node:setPositionXY(x,y)
	self.basePos = ccp(x,y)
end

return RCardSprite
