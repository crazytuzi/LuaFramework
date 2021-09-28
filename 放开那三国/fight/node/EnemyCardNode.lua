-- FileName: EnemyCardNode.lua 
-- Author: lichenyang 
-- Date: 13-9-29 
-- Purpose: 战斗敌方卡牌层
EnemyCardNode = class("EnemyCardNode", function ( ... )
	return TeamNode:new()
end)

function EnemyCardNode:ctor( ... )
	self._isEnemy = true
end

--[[
	@des:创建敌方卡牌层
	@parm:pHid 敌方英雄id数组
	@ret:layer
--]]
function EnemyCardNode:createWithIds( pHids )
	local instance = EnemyCardNode:new()
	instance:initWithIds(pHids)
	instance:setIsEnemy(true)
	instance._originalPos = ccp(instance:getPositionX(), instance:getPositionY())
	return instance
end

--[[
	@des:创建敌方卡牌层
	@parm:pTeamInfo 敌方战斗team数据
	@ret:layer
--]]
function EnemyCardNode:createWithTeamInfo( pTeamInfo )
	local instance = EnemyCardNode:new()
	
	local hids = {}
	for k,v in pairs(pTeamInfo.arrHero) do
		hids[tonumber(v.position) + 1] = v.hid
	end
	instance:initWithIds(hids)
	instance:setIsEnemy(true)
	instance:initCraftNode(pTeamInfo.craft)
	instance._originalPos = ccp(instance:getPositionX(), instance:getPositionY())
	return instance
end

--[[
	@des:转换位置编号到屏幕坐标
	@parm:pPosNum 敌方站位编号
	@ret:layer
--]]
function EnemyCardNode:convertPNToPos( pPosNum )
	local pos = pPosNum -1
	local cardWidth = 640*0.2*g_fScaleX
    local startX = 0.20*640*g_fScaleX
    local startY = g_winSize.height - cardWidth*2.4
    return ccp(startX+pos%3*cardWidth*1.4, startY+math.floor(pos/3)*(cardWidth*1.2)*1.2)
end

--[[
	@des:得到阵容打击位置
--]]
function EnemyCardNode.getAtkPos()
	local x = g_winSize.width/2
	local y =g_winSize.height - 0.48*600*g_fScaleX - 184*0.5*g_fScaleX
	return ccp(x, y)
end

--[[
	@des:得到阵容高度
--]]
function EnemyCardNode:getHeight()
	local cardWidth = 640*0.35*g_fScaleX
	local startY = g_winSize.height - cardWidth*2.4/2
	return startY
end