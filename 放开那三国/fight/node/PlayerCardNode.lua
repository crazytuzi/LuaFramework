-- FileName: PlayerCardNode.lua 
-- Author: lichenyang 
-- Date: 13-9-29 
-- Purpose: 战斗玩家卡牌层

PlayerCardNode = class("PlayerCardNode", function ( ... )
	return TeamNode:new()
end)

function PlayerCardNode:ctor( ... )
	self._isEnemy = false
	self._walkMusicId = nil
end

--[[
	@des:创建玩家卡牌层
	@parm:pHid 玩家英雄id数组
	@ret:layer
--]]
function PlayerCardNode:createWithIds( pHids )
	local instance = PlayerCardNode:new()
	instance:initWithIds(pHids)
	local x,y = instance:getPosition()
	instance:setIsEnemy(false)
	instance._originalPos = ccp(x,y)
	instance:registerTouchEvent()
	return instance
end

--[[
	@des:创建玩家卡牌层
	@parm:pTeamInfo 玩家战斗team数据
	@ret:layer
--]]
function PlayerCardNode:createWithTeamInfo( pTeamInfo )
	local instance = PlayerCardNode:new()
	local hids = {}
	for k,v in pairs(pTeamInfo.arrHero) do
		hids[tonumber(v.position) + 1] = v.hid
	end
	instance:initWithIds(hids)
	instance:setIsEnemy(false)
	instance:initCraftNode(pTeamInfo.craft)
	instance._originalPos = ccp(instance:getPositionX(), instance:getPositionY())
	instance:registerTouchEvent()
	return instance
end

--[[
	@des:转换位置编号到屏幕坐标
	@parm:pPosNum 玩家站位编号
	@ret:layer
--]]
function PlayerCardNode:convertPNToPos( pPosNum )
	local pos = pPosNum - 1
	local cardWidth = 640*0.2*g_fScaleX
    local startX = 0.20*640*g_fScaleX
    local startY = 0.48*600*g_fScaleX
    return ccp(math.floor(startX+pos%3*cardWidth*1.4), math.floor(startY-math.floor(pos/3)*(cardWidth*1.2)*1.2))
end

--[[
	@des:得到阵容打击位置
--]]
function PlayerCardNode.getAtkPos()
	local x = g_winSize.width/2
	local y = 0.48*600*g_fScaleX + 144*0.5*g_fScaleX
	return ccp(x,y)
end

--[[
	@des:得到阵容高度
--]]
function PlayerCardNode:getHeight()
	local cardWidth = 640*0.2*g_fScaleX
	local startY = cardWidth*2.4/2
	return startY
end

--[[
	@des:切换为当前可换阵型状态
--]]
function PlayerCardNode:setSwitchMode( pIsSwitch )
	self:setTouchEnabled(pIsSwitch)
	self:setTouchPriority(-460)
	self:setCardFrameVisible(pIsSwitch)
end

--[[
	@des:得到当前玩家阵型
--]]
function PlayerCardNode:getFormation()
	local fmt = {}
	for k,v in pairs(self._cardMap) do
		fmt[v:getEntity():getPosNum()-1] = k
	end
	return fmt
end


--[[
	@des:注册touch时间
--]]
function PlayerCardNode:registerTouchEvent()
	local targetCard = nil
	local targetPos  = nil
	local oldPos 	 = nil
	local maxOrder 	 = 10
	local tarHid     = nil
	local onTouchCallFunc = function ( eventType, x, y  )
		if(eventType == "began") then
			for k,v in pairs(self._cardMap) do
				local rect = getSpriteScreenRect(v)
				if rect:containsPoint(ccp(x, y)) then
					targetCard = v
					targetPos  = v:getEntity():getPosNum()
					local ox, oy = v:getPosition()
					oldPos = ccp(ox, oy)
					self:reorderChild(v, maxOrder)
					tarHid = targetCard:getEntity():getHid()
					break
				end
			end
			return true
		elseif(eventType == "moved") then
			if not tolua.isnull(targetCard) then
				local ox, oy = targetCard:getPosition()
				targetCard:setPosition(x/g_fScaleX, y/g_fScaleX)
			end
		else
			if not tolua.isnull(targetCard) then
				local isChange = false
				for k,v in pairs(self._frameMap) do
					local rect = getSpriteScreenRect(v)
					if rect:containsPoint(ccp(x, y)) then
						if tonumber(targetPos) ~= tonumber(k) then
							if self:getCardByPos(k) then
								local tempCard = self:getCardByPos(k)
								self:setHeroByPos(tempCard:getEntity():getHid(), targetPos)
								self:setHeroByPos(tarHid, k)
							else
								self:setHeroByPos(tarHid, k)
							end
							isChange = true
						end
					end
				end
				if isChange == false then
					self:reorderChild(targetCard, targetPos)
					targetCard:runAction(CCMoveTo:create(0.5, oldPos))
				end
			end
		end
	end
	self:registerScriptTouchHandler(onTouchCallFunc, false, -460, true)
end
