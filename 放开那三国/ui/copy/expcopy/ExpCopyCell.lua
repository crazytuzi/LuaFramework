-- Filename: ExpCopyCell.lua
-- Author: lichenyang
-- Date: 2015-03-31
-- Purpose: 主角经验副本数据处理类

module("ExpCopyCell", package.seeall)

require "script/ui/copy/expcopy/ExpCopyRewardLayer"

function create( p_cellData, p_tableView )

    local isGray = nil
    if p_cellData.isOpen == true then
        isGray = false
    else
        isGray = true
    end
    

	local tCell = CCTableViewCell:create()

    local	cellFrame = BTGraySprite:create("images/copy/copyframe.png")
    local	cellBg = BTGraySprite:create("images/copy/ncopy/thumbnail/" .. p_cellData.strongholdpic)
    tCell:setContentSize(cellFrame:getContentSize())
    cellFrame:setAnchorPoint(ccp(0,0))
    tCell:addChild(cellFrame,1,1)
    cellBg:setGray(isGray)
    cellFrame:setGray(isGray)

    cellBg:setAnchorPoint(ccp(0,0))
    cellBg:setPosition(ccp(cellFrame:getContentSize().width*0.02, (cellFrame:getContentSize().height-cellBg:getContentSize().height)/2))
    cellFrame:addChild(cellBg,-1,-1)
	
	-- 名称背景
	local	nameBgSp = CCLayerGradient:create(ccc4(0, 0, 0, 0), ccc4(0, 0, 0, 255))
    nameBgSp:setContentSize(CCSizeMake(cellBg:getContentSize().width, cellBg:getContentSize().height * 0.35))
    nameBgSp:setAnchorPoint(ccp(0, 0))
	nameBgSp:setPosition(ccp(0, 0))
    cellBg:addChild(nameBgSp)
    
    --副本名称
	local	nameSprite = BTGraySprite:create("images/copy/acopy/challenge.png")
    nameSprite:setAnchorPoint(ccp(1, 0.5))
    nameSprite:setPosition(nameBgSp:getContentSize().width*0.9, nameBgSp:getContentSize().height*0.5);
    nameBgSp:addChild(nameSprite,1,1)
    nameSprite:setGray(isGray)
    print("create cell :", tCell)


    local copyName = CCRenderLabel:create(p_cellData.strongholdname, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00))
    copyName:setAnchorPoint(ccp(0.5, 0.5))
    copyName:setPosition(ccpsprite(0.5, 0.5, cellBg))
    copyName:setColor(ccc3(0xff,0xfc,0x19))
    cellBg:addChild(copyName)
    if isGray then
        copyName:setColor(ccc3(92,92,92))
    end

    --掉落预览按钮
    local menu = CCMenu:create()
    -- menu:setScrollView(p_tableView)
    menu:setAnchorPoint(ccp(0, 0))
    menu:setPosition(ccp(0, 0))
    menu:setTouchPriority(-450)
    cellBg:addChild(menu)

    local norSprite = BTGraySprite:create("images/copy/acopy/drop_review_btn_n.png")
    norSprite:setGray(isGray)
    local higSprite = BTGraySprite:create("images/copy/acopy/drop_review_btn_h.png")
    higSprite:setGray(isGray)

    local dropReviewBtn = CCMenuItemSprite:create(norSprite, higSprite)
    dropReviewBtn:setAnchorPoint(ccp(0.5, 0.5))
    dropReviewBtn:setPosition(ccpsprite(0.15, 0.5, cellBg))
    menu:addChild(dropReviewBtn)
    dropReviewBtn:registerScriptTapHandler(function ( ... )
        print("_cellData.exppreview", p_cellData.exppreview)
        
        local itemIds = string.split(p_cellData.exppreview, ",")
        ExpCopyRewardLayer.show(-460, 2500, itemIds)
    end)
    if isGray then
        dropReviewBtn:setEnabled(false)
    end
	return tCell
end