-- FileName: FightCraftNode.lua 
-- Author: lichenyang 
-- Date: 15-07-22 
-- Purpose: 战斗敌方卡牌层

FightCraftNode = class("FightCraftNode", function ( ... )
	return CCSprite:create()
end)

function FightCraftNode:ctor( ... )
	
end

--[[
	@des:创建阵法特效
	@parm:craftInfo 阵法信息{level = 0, id = 0}
	@ret:XMLSprite
--]]
function FightCraftNode:createWithInfo( pCraftInfo )
	local instance = FightCraftNode:new()
	if not pCraftInfo then
		return  instance
	end
	if tonumber(pCraftInfo.id )~= 0 then
        local needOpenLevel = tonumber(DB_Method.getDataById(pCraftInfo.id).needmethodlv)
        if tonumber(pCraftInfo.level) >= needOpenLevel then
        	local effectName = DB_Method.getDataById(pCraftInfo.id).effect
            local effectPath = "images/warcraft/effect/" .. effectName .. "/" ..effectName
            local carftEffect = XMLSprite:create(effectPath)
            carftEffect:setCascadeColorEnabled(true)
            carftEffect:setColor(ccc3(200, 200, 200))
            instance:addChild(carftEffect, 1)
        end
    end
    return instance
end