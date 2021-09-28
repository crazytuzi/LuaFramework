-- Filename：	OrangeTableView.lua
-- Author：		Zhang Zihang
-- Date：		2014-9-9
-- Purpose：		橙将tableView

module ("OrangeTableView", package.seeall)

require "script/ui/item/ItemSprite"

local _countryInfo

--[[
	@des 	:创建tableView
	@param 	:相应国家的武将信息
	@return :创建好的tableView
--]]
function createTableView(p_countryInfo)
	_countryInfo = p_countryInfo

	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(580, 130)
		elseif fn == "cellAtIndex" then
			a2 = createCell((math.ceil(#_countryInfo/5) - 1 - a1)*5)
			r = a2
		elseif fn == "numberOfCells" then
			r = math.ceil(#_countryInfo/5)
		else
			print("other function")
		end

		return r
	end)

	return LuaTableView:createWithHandler(h, CCSizeMake(580,475))
end

--[[
	@des 	:创建cell
	@param 	:开始下标
	@return :创建好的cell
--]]
function createCell(p_beginIndex)
	local tCell = CCTableViewCell:create()

	for i = p_beginIndex + 1,p_beginIndex + 5 do
		if i <= #_countryInfo then
			local posX = 50 + 120*(i - p_beginIndex - 1)

			--武将头像
			local headSprite = ItemSprite.getHeroIconItemByhtid(_countryInfo[i],-570)
			headSprite:setAnchorPoint(ccp(0.5,1))
			headSprite:setPosition(ccp(posX,125))
			tCell:addChild(headSprite)

			--武将名字
			require "db/DB_Heroes"
			local heroInfo = DB_Heroes.getDataById(_countryInfo[i])
			local heroNameLabel = CCRenderLabel:create(heroInfo.name,g_sFontName,18,2,ccc3(0x00,0x00,0x00),type_stroke)
			heroNameLabel:setColor(ccc3(0xff,0x84,0x00))
			heroNameLabel:setAnchorPoint(ccp(0.5,0))
			heroNameLabel:setPosition(posX,5)
			tCell:addChild(heroNameLabel)
		end
	end

	return tCell
end