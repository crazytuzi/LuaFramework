-- Filename：	CityMenuItem.lua
-- Author：		Cheng Liang
-- Date：		2014-4-28
-- Purpose：		资源城市

module("CityMenuItem", package.seeall)

require "db/DB_City"

Type_City_Normal 	= 1  	-- 正常显示的
Type_City_Quick 	= 2 	-- 快速入口用的

local cityNameColorArr = {
	ccc3(0xff,0xff,0xff),
	ccc3(0x00,0xff,0x18),
	ccc3(0x00,0xe4,0xff),
	ccc3(0xf9,0x59,0xff),
}

function createItem( cityId, cityType )
	cityId = tonumber(cityId)
	local fortInfo = nil
	if(GuildCity~=nil)then
		for k,v in pairs(GuildCity.models.normal) do
			if(cityId == tonumber(v.looks.look.armyID) )then
				fortInfo = v
				break
			end
		end
	else
		return nil
	end

	local cityDesc  = DB_City.getDataById(fortInfo.looks.look.armyID)

	local dstStr = "images/citybattle/".. cityDesc.icon
	-- print("pngIndex======"..pngIndex)
	local fortMenuItem = CCMenuItemImage:create(tostring(dstStr),tostring(dstStr))

	-- local rewardNode = ItemUtil.getNodeByStr(cityDesc.baseReward,true)
	-- rewardNode:setPosition(ccp(fortMenuItem:getContentSize().width*0.5,fortMenuItem:getContentSize().height))
	-- fortMenuItem:addChild(rewardNode)
	-- local rewardNode = ItemUtil.getNodeByStr(cityDesc.baseReward,true)
	-- rewardNode:setPosition(ccp(fortMenuItem:getContentSize().width*0.5,fortMenuItem:getContentSize().height))
	-- fortMenuItem:addChild(rewardNode)
	-- local parentNode = CCNode:create()
	local nameColor = cityNameColorArr[tonumber( cityDesc.cityLevel)]
	local nameLabel = CCRenderLabel:create( cityDesc.name , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    -- nameLabel:setAnchorPoint(ccp(0.5, 1))
    -- nameLabel:setPosition(ccp( nameLabel:getContentSize().width*0.5, nameLabel:getContentSize().height) )
    -- parentNode:addChild(nameLabel)
    --奖励node（图+数量）
    local rewardNode = ItemUtil.getNodeByStr(cityDesc.baseReward,true)
 --    rewardNode:setAnchorPoint(ccp(0,0.5))
	-- rewardNode:setPosition(ccp(nameLabel:getContentSize().width*0.5+rewardNode:getContentSize().width*0.5,rewardNode:getContentSize().height*0.5))
	-- parentNode:addChild(rewardNode)

	require "script/utils/BaseUI"
	local parentNode = BaseUI.createHorizontalNode({nameLabel,rewardNode})

	--parentNode:setContentSize(CCSizeMake(nameLabel:getContentSize().width+rewardNode:getContentSize().width,nameLabel:getContentSize().height))
	parentNode:setAnchorPoint(ccp(0.5,0))
	parentNode:setPosition(ccp(fortMenuItem:getContentSize().width*0.5,fortMenuItem:getContentSize().height))
	fortMenuItem:addChild(parentNode)

    -- 占领信息
    local occupyCityInfos = CityData.getOcupyCityInfos()
    if(not table.isEmpty(occupyCityInfos) )then
    	local m_occupy_info = occupyCityInfos[tostring(cityId)]
    	if( not table.isEmpty(m_occupy_info) )then
    		-- 背景
    		local occupySprite = CCSprite:create("images/citybattle/flag.png")
    		occupySprite:setAnchorPoint(ccp(0.5, 0.5))
    		occupySprite:setPosition(ccp(fortMenuItem:getContentSize().width*0.5, 0))
    		fortMenuItem:addChild(occupySprite)

    		-- 军团名称
    		local guildNameColor = ccc3(0xff, 0xf6,0x00)
    		if( tonumber(m_occupy_info.guild_id) ==  GuildDataCache.getGuildId() )then
    			guildNameColor = ccc3(0x00, 0xff,0x18)
    		end
    		local guildNameLabel = CCRenderLabel:create( m_occupy_info.guild_name , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    guildNameLabel:setColor(guildNameColor)
		    guildNameLabel:setAnchorPoint(ccp(0, 0))
		    guildNameLabel:setPosition(ccp( occupySprite:getContentSize().width * 0.2, occupySprite:getContentSize().height * 0.1) )
		    occupySprite:addChild(guildNameLabel)

    	end
    end


	if( cityType == Type_City_Normal )then
		-- 是否已经报名该城市
		-- if(not table.isEmpty(CityData.getSignCity()))then
		-- 	-- 是否已报名该城市
		-- 	for k,m_cityId in pairs(CityData.getSignCity()) do
		-- 		if( cityId == tonumber(m_cityId))then
		-- 			local signSprite = CCSprite:create("images/citybattle/att.png")
		-- 			signSprite:setAnchorPoint(ccp(0.5,0.5))
		-- 			signSprite:setPosition(ccp(0,signSprite:getContentSize().height*0.5+fortMenuItem:getContentSize().height*0.5))
		-- 			fortMenuItem:addChild(signSprite)
		-- 			break
		-- 		end
		-- 	end
		-- end

		-- 该城市是否可以领奖
		local rewardCity = CityData.getRewardCity()
		if( rewardCity and tonumber(rewardCity) >0 and tonumber(rewardCity) == cityId )then
			local Anisprite = CityReward.createBoxReward( cityId )
			fortMenuItem:addChild(Anisprite)
			Anisprite:setPosition(ccp(0,Anisprite:getContentSize().height*0.5+fortMenuItem:getContentSize().height*0.5))
		end
	end


	

	-- 争夺中特效
	local timesInfo = CityData.getTimeTable()
	if( TimeUtil.getSvrTimeByOffset() > tonumber(timesInfo.arrAttack[1][1]) - timesInfo.prepare and TimeUtil.getSvrTimeByOffset() < tonumber(timesInfo.arrAttack[2][2]) )then
		local attkArr = CityData.getAttackCity()
		for k,v in pairs(attkArr) do
			local delayNum = tonumber(timesInfo.arrAttack[2][2]) - TimeUtil.getSvrTimeByOffset()
			if( tonumber(v) == tonumber(cityId) and delayNum > 0 )then
				local spriteXml = CCLayerSprite:layerSpriteWithNameAndCount("images/base/effect/jtcczhandao/jtcczhandao", -1,CCString:create(""))
				spriteXml:setAnchorPoint(ccp(0,0))
				spriteXml:setPosition(ccp(fortMenuItem:getContentSize().width*0.5,fortMenuItem:getContentSize().height*0.3))
				fortMenuItem:addChild(spriteXml)
				-- 这个特效缩放会导致关键帧错乱
				-- if( cityType == Type_City_Normal )then
				-- 	spriteXml:setScale(0.7)
				-- end

				local function removeSpriteFun( ... )
					if(spriteXml)then
						spriteXml:removeFromParentAndCleanup(true)
						spriteXml = nil
					end
				end 
				local actionArray = CCArray:create()
				actionArray:addObject(CCDelayTime:create(delayNum))
				actionArray:addObject(CCCallFunc:create(removeSpriteFun))
				fortMenuItem:runAction(CCSequence:create(actionArray))
				break
			end
		end
	end
	
	return fortMenuItem
end




















