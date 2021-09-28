-- Filename：	IconCell.lua
-- Author：		LLP
-- Date：		2014-4-24
-- Purpose：		头像Cell

module("IconCelldown", package.seeall)


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

	require "script/model/utils/HeroUtil"
   


	bgSprite = CCSprite:create("images/readyBattle/readyBattleBg.jpg")
	-- local iconMenuBar = CCMenu:create()
	-- iconMenuBar:setAnchorPoint(ccp(0,0))
	-- iconMenuBar:setPosition(ccp(0, 0))
	-- tCell:addChild(iconMenuBar)

	-- local htid = 20001
	-- if(userData.utid == "1") then
	-- 	htid = 20002
	-- end
	-- 头像
	for i=1,table.count(userData.defender.list) do
		local nameLabel = CCLabelTTF:create(tostring(userData.defender.list[i].uname), g_sFontPangWa, 21)

		local dressId = nil
   		local genderId = nil
    	if( not table.isEmpty(userData.defender.list[i].dress) and (userData.defender.list[i].dress["1"])~= nil and tonumber(userData.defender.list[i].dress["1"]) > 0 )then
        	dressId = userData.defender.list[i].dress["1"]
        	genderId = HeroModel.getSex(userData.defender.list[i].htid)
    	end

    	-- added by zhz ,vip特效
    	local vip = userData.defender.list[i].vip or 0

    	local iconSP = HeroUtil.getHeroIconByHTID(userData.defender.list[i].htid, dressId, genderId, vip)
		
		iconSP:setAnchorPoint(ccp(0.5, 0.5))
		
		iconSP:setPosition(ccp(iconSP:getContentSize().width*0.5+(i-1)*(iconSP:getContentSize().width), bgSprite:getContentSize().height*0.25-iconSP:getContentSize().height*0.5+2))

		tCell:addChild(iconSP,0,i)

		-- 名称
		local nameLabel = CCLabelTTF:create(tostring(userData.defender.list[i].uname),  g_sFontPangWa, 21)
		nameLabel:setAnchorPoint(ccp(0.5, 0.5))
		nameLabel:setColor(ccc3(0x36, 0xff, 0x00))
		nameLabel:setPosition(ccp(iconSP:getContentSize().width*0.5, -nameLabel:getContentSize().height*0.5))
	    iconSP:addChild(nameLabel,0,i)
	end

	return tCell
end
