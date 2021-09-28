-- Filename：	IconCell.lua
-- Author：		LLP
-- Date：		2014-4-24
-- Purpose：		头像Cell

module("IconCell", package.seeall)


require "script/ui/item/ItemSprite"
require "script/model/utils/HeroUtil"
require "script/utils/LuaUtil"
require "script/libs/LuaCC"
require "script/ui/hero/HeroPublicCC"

local Tag_CellBg = 10001
local _matchCallbackAction = nil

--[[
	@desc	
	@para 	
	@return 
--]]
function createCell(userData)
	local tCell = CCTableViewCell:create()

	-- local iconMenuBar = CCMenu:create()
	-- iconMenuBar:setAnchorPoint(ccp(0,0))
	-- iconMenuBar:setPosition(ccp(0, 0))
	-- tCell:addChild(iconMenuBar)

	-- local htid = 20001
	-- if(userData.utid == "1") then
	-- 	htid = 20002
	-- end
	-- 头像
	for i=1,table.count(userData.attacker.list) do
		local nameLabel = CCLabelTTF:create(tostring(userData.attacker.list[i].uname), g_sFontPangWa, 21)
		local dressId = nil
   		local genderId = nil
    	if(not table.isEmpty(userData.attacker.list[i].dress) and (userData.attacker.list[i].dress["1"])~= nil and tonumber(userData.attacker.list[i].dress["1"]) > 0 )then
        	dressId = userData.attacker.list[i].dress["1"]
        	genderId = HeroModel.getSex(userData.attacker.list[i].htid)
    	end
    	local iconSP = HeroUtil.getHeroIconByHTID(userData.attacker.list[i].htid, dressId, genderId)
		iconSP:setAnchorPoint(ccp(0.5, 0.5))
		iconSP:setPosition(ccp(iconSP:getContentSize().width*0.5+(i-1)*(iconSP:getContentSize().width), iconSP:getContentSize().height*0.5+nameLabel:getContentSize().height+2))
		tCell:addChild(iconSP,0,i)

		-- 名称
		local nameLabel = CCLabelTTF:create(tostring(userData.attacker.list[i].uname), g_sFontPangWa, 21)
		nameLabel:setAnchorPoint(ccp(0.5, 0.5))
		nameLabel:setColor(ccc3(0x36, 0xff, 0x00))
		nameLabel:setPosition(ccp(iconSP:getContentSize().width*0.5, -nameLabel:getContentSize().height*0.5+2))
	    iconSP:addChild(nameLabel,0,i)
	end

	return tCell
end
