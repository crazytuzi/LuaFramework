-- Filename：	GuildCopyCell.lua
-- Author：		zhz
-- Date：		2013-2-17
-- Purpose：		副本Cell

module("GuildCopyCell", package.seeall)
require "script/ui/guild/copy/GuildTeamData"



function createCell( cellValues)

	local tCell = CCTableViewCell:create()

	-- 外框
    local cellFrame = nil
    -- 背景
	local cellBg = nil

	if(cellValues.isGray == true)then
    	cellFrame = BTGraySprite:create("images/copy/ecopy/copyframe.png")
    	cellBg = BTGraySprite:create("images/copy/ecopy/thumbnail/" ..  cellValues.thumbnail)
    else
    	cellFrame = CCSprite:create("images/copy/ecopy/copyframe.png")
    	cellBg = CCSprite:create("images/copy/ecopy/thumbnail/" .. cellValues.thumbnail)
    end

    cellFrame:setAnchorPoint(ccp(0,0))
    cellFrame:setPosition(ccp(0,0))
    tCell:addChild(cellFrame,1,1)
    
    tCell:setContentSize(cellFrame:getContentSize())
    cellBg:setAnchorPoint(ccp(0,0))
    cellBg:setPosition(ccp(cellFrame:getContentSize().width*0.02, (cellFrame:getContentSize().height-cellBg:getContentSize().height)/2))
    cellFrame:addChild(cellBg,-1,-1)
	
    
	-- 名称背景
	local nameBgSp = nil
	if(cellValues.isGray and cellValues.isGray == true)then
		nameBgSp = BTGraySprite:create("images/copy/ecopy/namebg.png")
	else
		nameBgSp = CCSprite:create("images/copy/ecopy/namebg.png")
	end
	nameBgSp:setAnchorPoint(ccp(0.5, 0.5))
	nameBgSp:setPosition(ccp(cellFrame:getContentSize().width* 115/640, cellFrame:getContentSize().height*0.7))
    cellFrame:addChild(nameBgSp)
    --副本名称
    local nameSprite = nil
    if( cellValues.isGray == true)then
		nameSprite = BTGraySprite:create("images/copy/guildcopy/nameimage/" .. cellValues.img)
	else
		nameSprite = CCSprite:create("images/copy/guildcopy/nameimage/" .. cellValues.img)
	end
	nameSprite:setAnchorPoint(ccp(0.5, 0.5))
    nameSprite:setPosition(nameBgSp:getContentSize().width*0.5, nameBgSp:getContentSize().height*0.5);
    nameBgSp:addChild(nameSprite,1,1)
    

    if(cellValues.isGray == true ) then
    	local openConditionLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1423") .. GuildTeamData.getOpenStr(cellValues), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        openConditionLabel:setColor(ccc3(0xff, 0x90, 0x00))
        openConditionLabel:setPosition(ccp(cellFrame:getContentSize().width*0.9-openConditionLabel:getContentSize().width, cellFrame:getContentSize().height*0.85))
        cellFrame:addChild(openConditionLabel)
    else
    	if( GuildTeamData.isGuildCopyPass(cellValues)) then
    		local passedSprite = CCSprite:create("images/copy/passed.png")
		    passedSprite:setAnchorPoint(ccp(0, 0.5))
		    passedSprite:setPosition(ccp(cellFrame:getContentSize().width*0.75, cellFrame:getContentSize().height*0.7))
		    cellFrame:addChild(passedSprite,2,2)
    	end

        local starBgSp = CCSprite:create("images/copy/starbg.png")
        starBgSp:setPosition(ccp(cellFrame:getContentSize().width*0.5, cellFrame:getContentSize().height*0.12))
        cellFrame:addChild(starBgSp,3,3)

        local teamNumber= GuildTeamData.getTeamNumByCopyId(cellValues.id)
        local numberColor= ccc3(0x00,0xff,0x18)
        if(teamNumber<=0) then
            numberColor= ccc3(0xff,0xff,0xff)
        end

    	local curTeamLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3400")  , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    	curTeamLabel:setColor(ccc3(0x00,0xff,0x18))
        local teamNumLabel = CCRenderLabel:create( tostring(teamNumber), g_sFontName,21,1,ccc3(0x00,0x00,0x00), type_stroke)
        teamNumLabel:setColor(numberColor)
        local teamNumNode= BaseUI.createHorizontalNode({curTeamLabel,teamNumLabel})
        teamNumNode:setAnchorPoint(ccp(0,1))
    	teamNumNode:setPosition(starBgSp:getContentSize().width/2, starBgSp:getContentSize().height*0.7)
    	starBgSp:addChild(teamNumNode, 4)
    end

    local menubar= CCMenu:create()
    menubar:setPosition(ccp(0,0))
    cellFrame:addChild(menubar)

    local dropItem= CCMenuItemImage:create("images/common/btn/btn_drop/btn_drop_n.png","images/common/btn/btn_drop/btn_drop_h.png" )
    dropItem:setPosition(30,30)
    dropItem:setAnchorPoint(ccp(0,0))
    menubar:addChild(dropItem,1, cellValues.id )
    dropItem:registerScriptTapHandler(dropAction)


    return tCell
	
end

-- 掉落回调
function dropAction( tag, item )
    print(" drop tag is : ", tag)
    local copyId= tonumber(tag)

   local items=  GuildTeamData.getCopyItemsById(copyId)
    print_t(items)

    require "script/ui/teamGroup/VictoryDropLayer"
    VictoryDropLayer.showLayer(items)

end



