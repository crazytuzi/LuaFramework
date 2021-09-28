--Filename:CardTurnView.lua
--Author：zhz
--Date：2013-11-16
--Purpose:创建卡牌翻转效果

-- module("CardTurnView", package.seeall)

CardTurnView = class("CardTurnView", function ()
	local nodeContent = CCNode:create()
	return nodeContent


end)

CardTurnView.__index = CardTurnView

CardTurnView.kInAngleZ   =  270  		--//里面卡牌的起始Z轴角度  
CardTurnView.kInDeltaZ   =  90   		--//里面卡牌旋转的Z轴角度差  
CardTurnView.kOutAngleZ  = 0  			--//封面卡牌的起始Z轴角度  
CardTurnView.kOutDeltaZ  = 90   		--//封面卡牌旋转的Z轴角度差  

CardTurnView.m_isOpened = nil
CardTurnView.inCard = nil
CardTurnView.outCard =nil 

--[[
	@des 	:创建翻牌的效果
	@param 	: inCard: 里面牌的图片， outCard:外面牌的图片，duration: 时间间隔， callback :回调函数
	@return : 
]]
function CardTurnView:create( inCard, outCard )--, callBack)
	local cardNode = CardTurnView:new()

	cardNode.m_isOpened = false

	-- 里面的图片
	cardNode.inCard = inCard
	cardNode.inCard:setPosition(ccp(0,0))
	cardNode.inCard:setVisible(false)
	cardNode.inCard:setAnchorPoint(ccp(0.5,0.5))
	cardNode:addChild(cardNode.inCard)

	-- 外面的图片
	cardNode.outCard =  outCard 
	print("outCard 2 is : ", outCard)
	cardNode.outCard:setPosition(ccp(0,0))
	cardNode.outCard:setAnchorPoint(ccp(0.5,0.5))
	cardNode:addChild(cardNode.outCard)

	return cardNode
end


-- 打开卡牌的函数
function CardTurnView:openCard( duration ,delayTime, callback)


	local duration =  duration or 0.5
	-- local duration = 4
	-- -- delayTime = 4
	-- local actionArr = CCArray:create()
	-- actionArr:addObject(CCDelayTime:create(delayTime))
	-- actionArr:addObject( CCShow:create())
	-- actionArr:addObject( CCOrbitCamera:create(duration, 1, 0, 180, -90, 0, 0))
	-- -- actionArr:addObject(CCDelayTime:create(delayTime))

	-- actionArr:addObject(CCCallFuncN:create(function ( ... )
	-- 		self.outCard:setVisible(false)
	-- 		self.inCard:setVisible(true)
	-- 	end))

	-- self.outCard:runAction(CCSequence:create(actionArr))


	-- local actionArr_2 = CCArray:create()
	-- actionArr_2:addObject( CCDelayTime:create(duration ))
	-- actionArr_2:addObject( CCDelayTime:create(delayTime ))
	-- actionArr_2:addObject(CCOrbitCamera:create(duration, 1, 0, 270, -90, 0, 0))
	-- if(callback ~= nil) then
	-- 	actionArr_2:addObject(CCCallFuncN:create(function ( ... )
	-- 		callback()
	-- 	end))
	-- end
	

	-- self.inCard:runAction(CCSequence:create(actionArr_2))

	-- self.inCard:setVisible(false)



	local action1 = CCOrbitCamera:create(duration, 1, 0, 180, -90, 0, 0)
	local action2 = CCCallFunc:create(function ( ... )
		self.inCard:setVisible(true)
		self.inCard:runAction(CCOrbitCamera:create(duration, 1, 0, 90, -90, 0, 0))

		local actionArr2 = CCArray:create()
		-- actionArr2:addObject(CCDelayTime:create(delayTime))
		actionArr2:addObject(CCCallFunc:create(function ( ... )
			self.outCard:setVisible(false)
		end))
		self.outCard:runAction(CCSequence:create(actionArr2))
	end)

	local acitonArray = CCArray:create()
	acitonArray:addObject(action1)
	acitonArray:addObject(action2)
	if(callback ~= nil) then
		acitonArray:addObject(CCCallFuncN:create(function ( ... )
			callback()
		end))
	end

	self.outCard:runAction(CCSequence:create(acitonArray))


end








