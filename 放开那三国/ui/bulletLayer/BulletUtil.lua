module ("BulletUtil", package.seeall)
require "script/ui/bulletLayer/InputChatLayer"

local item = nil
local p_type = 0
local p_touch = -400
local p_zorder = 100
math.randomseed(os.time())

function itemClick( tag,pSender )
	-- body
	InputChatLayer.showLayer(p_type,p_touch,p_zorder)
end

function createItem( pType,pTouch,pZorder )
	-- body
	p_type = pType
	p_touch = pTouch or -400
	p_zorder = pZorder or 100
	item = LuaMenuItem.createItemImage("images/bulletscreen/bullet1.png", "images/bulletscreen/bullet2.png" )
	item:setAnchorPoint(ccp(0.5, 0.5))
	item:registerScriptTapHandler(itemClick)
	return item
end
--获取可随机的table
function getCanRandomTable( prandomTable )
	-- body
	local canRandomTable = {}

	for i=1,7 do
		local hasSame = false
		for k,v in pairs(prandomTable)do
			if(i==v)then
				hasSame = true
				break
			end
		end
		if(hasSame==false)then
			table.insert(canRandomTable,i)
		end
	end
	return canRandomTable
end

--随机数
function createRandomNum( prandomTable )
	-- body
	local canRandomTable = getCanRandomTable(prandomTable)
	if(table.count(canRandomTable)==1)then
		return canRandomTable[1]
	else
		local randomNum = table.count(canRandomTable)

		local randomIndex = math.random(1,randomNum)

		return canRandomTable[randomIndex]
	end
end