-- Filename：	CopyCell.lua
-- Author：		Cheng Liang
-- Date：		2013-7-2
-- Purpose：		精英副本Cell

module("CopyCell", package.seeall)



local Status_Display 		= 0 			-- 只显示
local Status_Fire 			= 1 			-- 可攻打
local Status_Passed 		= 2 			-- 已通过

local Tag_NameBg 			= 1001 			
local Tag_NameSprite		= 1002
local Tag_PreConditionText 	= 1003
local Tag_CostEnergy 		= 1004

--[[
	@desc	副本Cell的创建
	@para 	table cellValues,
			int animatedIndex, 
			boolean isAnimate
	@return CCTableViewCell
--]]
function createCopyCell(cellValues, animatedIndex, isAnimate)
	local tCell = CCTableViewCell:create()

	-- cell的外框 
    local cellFrame = nil
    if (cellValues.copyInfo.status == Status_Display) then
    	cellFrame = BTGraySprite:create("images/copy/ecopy/copyframe.png")
    else
    	cellFrame = CCSprite:create("images/copy/ecopy/copyframe.png")
    end
    cellFrame:setAnchorPoint(ccp(0,0))
    tCell:setContentSize(cellFrame:getContentSize())

    -- cell的背景 缩略图
    local cellBgIconName = "images/copy/ecopy/thumbnail/" .. cellValues.copyInfo.thumbnail
	-- local cellBg = CCSprite:create("images/copy/ecopy/thumbnail/" .. cellValues.copyInfo.thumbnail)
	local cellBg = nil
	if (cellValues.copyInfo.status == Status_Display) then
    	cellBg = BTGraySprite:create(cellBgIconName)
    else
    	cellBg = CCSprite:create(cellBgIconName)
    end
	cellBg:setAnchorPoint(ccp(0,0))
    cellBg:setPosition(ccp(cellFrame:getContentSize().width*0.02, (cellFrame:getContentSize().height-cellBg:getContentSize().height)/2))
    cellFrame:addChild(cellBg,-1,-1)
	tCell:addChild(cellFrame,1,1)
	local cellFrameSize = cellFrame:getContentSize()
    
    --名称背景图
    local nameBg = nil
    if (cellValues.copyInfo.status == Status_Display) then
    	nameBg = BTGraySprite:create("images/copy/ecopy/namebg.png")
    else
    	nameBg = CCSprite:create("images/copy/ecopy/namebg.png" )
    end
    nameBg:setPosition(ccp(cellFrame:getContentSize().width*0.05, cellFrame:getContentSize().height*0.65))
    cellFrame:addChild(nameBg, Tag_NameBg, Tag_NameBg)

    --副本名称
    -- local nameSprite = CCSprite:create("images/copy/ecopy/nameimage/" .. cellValues.copyInfo.image)
    local nameSprite = nil
    local nameSpriteIcon = "images/copy/ecopy/nameimage/" .. cellValues.copyInfo.image
    if (cellValues.copyInfo.status == Status_Display) then
    	nameSprite = BTGraySprite:create(nameSpriteIcon)
    else
    	nameSprite = CCSprite:create(nameSpriteIcon)
    end
    nameSprite:setAnchorPoint(ccp(0.5,0.5))
    nameSprite:setPosition(nameBg:getContentSize().width/2, nameBg:getContentSize().height/2);
    nameBg:addChild(nameSprite, Tag_NameSprite, Tag_NameSprite)

    if (cellValues.copyInfo.status == Status_Display) then
    	-- package.loaded["db/DB_Copy"] = nil
    	require "db/DB_Copy"
	    local preCopyInfo = DB_Copy.getDataById(cellValues.copyInfo.pre_copyid)
	    local preName = CopyUtil.getOpenCondition(cellValues.copyInfo.id)
	    -- DB_Copy.release()
	    --开启条件
	    local preConditionLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1547") .. preName, g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
        preConditionLabel:setColor(ccc3(0xff, 0x90, 0x00))
        preConditionLabel:setPosition(ccp(cellFrameSize.width*0.9-preConditionLabel:getContentSize().width, cellFrameSize.height*0.85))
        cellFrame:addChild(preConditionLabel, Tag_PreConditionText, Tag_PreConditionText)
    else
        -- 体力 -- 注释 by zhz
        -- local energyLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1299") .. cellValues.copyInfo.energy, g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
        -- energyLabel:setColor(ccc3(0x36, 0xff, 0x00))
        -- energyLabel:setAnchorPoint(ccp(1, 0.5))
        -- energyLabel:setPosition(ccp( cellBg:getContentSize().width*0.95 , cellBg:getContentSize().height*0.1))
        -- cellBg:addChild(energyLabel)
    end
    
    -- if (cellValues.copyInfo.status ~= Status_Display) then
    --     --体力
    --     local costEnergyLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1299") .. cellValues.copyInfo.energy, g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    -- 	costEnergyLabel:setColor(ccc3(0x36, 0xff, 0x00))
    -- 	costEnergyLabel:setPosition(ccp(cellFrameSize.width*0.75, cellFrameSize.height*0.3))
    --     cellFrame:addChild(costEnergyLabel, Tag_CostEnergy, Tag_CostEnergy)
    -- end
    
	if(isAnimate == true) then
		print("createCopyCell......" .. animatedIndex)
		cellFrame:setPosition(ccp(cellFrame:getContentSize().width, 0))
		cellFrame:runAction(CCMoveTo:create(0.05 * (animatedIndex ),ccp(0,0)))
	end
    if (cellValues.copyInfo.status == Status_Passed) then
        addSweepFunc(tCell:getContentSize(),cellFrame,cellValues.copyInfo)       
    end
	return tCell
end
--[[
    @des    : 添加扫荡功能
    @param  : 
    @return : 
--]]
function addSweepFunc( cellSize,cellFrame,pCopyInfo )
    local sweepCallBack = function ( pData )
        require "script/ui/copy/Fight10Border"
        local fight10Border = Fight10Border.createLayer(pCopyInfo.name, pData.reward, pData.extra_reward)
        local runningScene = CCDirector:sharedDirector():getRunningScene()
        runningScene:addChild(fight10Border, 2001)
    end
    -- 确认扫荡回调
    local sureToSweep = function ( isConfirm )
        -- body
        if not isConfirm then
            return
        end
        -- 背包是否已满
        if (ItemUtil.isBagFull()) then
            return
        end
        print("开始扫荡！")
        require "script/ui/copy/CopyController"
        CopyController.sweep(pCopyInfo.id,sweepCallBack)
    end
    -- 按钮回调
    local btnCB = function ( ... )
        AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
        AlertTip.showAlert( GetLocalizeStringBy("syx_1064"), sureToSweep, true, nil)
    end
    -- 扫荡按钮
    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(ccp(0,0))
    cellFrame:addChild(menu)
    menu:setTouchPriority(-504)
    local sweepBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png","images/common/btn/btn_blue_hui.png")
    sweepBtn:setAnchorPoint(ccp(0.5,0.5))
    sweepBtn:setPosition(ccp(cellSize.width * 0.8,cellSize.height * 0.5))
    menu:addChild(sweepBtn)
    sweepBtn:registerScriptTapHandler(btnCB)
    local labelColor = nil
    if (DataCache.getEliteCopyData().can_defeat_num ~= 0) then
        labelColor = ccc3( 0xfe, 0xdb, 0x1c)
    else
        sweepBtn:setEnabled(false)
        labelColor = ccc3( 0x80, 0x80, 0x80)
    end
    local btnLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1063"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    btnLabel:setColor(labelColor)
    btnLabel:setPosition(ccpsprite(0.5, 0.5, sweepBtn))
    btnLabel:setAnchorPoint(ccp(0.5, 0.5))
    sweepBtn:addChild(btnLabel)
end

function setCellValue( copyCell, cellValues, animatedIndex, isAnimate)
	local cellFrame = tolua.cast(copyCell:getChildByTag(1), "CCSprite")
	--获取名称背景
	local nameBg = tolua.cast(cellFrame:getChildByTag(Tag_NameBg), "CCSprite")
	--获取副本名称
	local nameSprite = tolua.cast(nameBg:getChildByTag(Tag_NameSprite), "CCSprite")
	if (nameSprite) then
		nameSprite:removeFromParentAndCleanup(true)
	end
	nameSprite = CCSprite:create("images/copy/ecopy/nameimage/" .. cellValues.copyInfo.image)
    nameSprite:setAnchorPoint(ccp(0.5,0.5))
    nameSprite:setPosition(nameBg:getContentSize().width/2, nameBg:getContentSize().height/2);
    nameBg:addChild(nameSprite, Tag_NameSprite, Tag_NameSprite)

    --开启条件
    local preConditionLabel = tolua.cast(cellFrame:getChildByTag(Tag_PreConditionText), "CCLabelTTF")
    if (preConditionLabel) then
		preConditionLabel:removeFromParentAndCleanup(true)
	end
	preConditionLabel = CCLabelTTF:create(GetLocalizeStringBy("key_10021"), g_sFontName, 20)
	preConditionLabel:setColor(ccc3(0xff, 0x90, 0x00))
	preConditionLabel:setPosition(ccp(cellFrame:getContentSize().width*0.7, cellFrame:getContentSize().height*0.8))
    cellFrame:addChild(preConditionLabel, Tag_PreConditionText, Tag_PreConditionText)

 --    --体力
 --    local costEnergyLabel = tolua.cast(cellFrame:getChildByTag(Tag_CostEnergy), "CCLabelTTF")
 --    costEnergyLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1299") .. cellValues.copyInfo.energy, g_sFontName, 20)
	-- costEnergyLabel:setColor(ccc3(0x36, 0xff, 0x00))
	-- costEnergyLabel:setPosition(ccp(cellFrame:getContentSize().width*0.8, cellFrame:getContentSize().height*0.1))
 --    cellFrame:addChild(costEnergyLabel, Tag_CostEnergy, Tag_CostEnergy)

	if(isAnimate == true) then
		print("setCellValue-------" .. animatedIndex)
		cellFrame:setPosition(ccp(cellFrame:getContentSize().width, 0))
		cellFrame:runAction(CCMoveTo:create(g_cellAnimateDuration * (animatedIndex ),ccp(0,0)))
	end
end


--[[
	@desc	副本 灰度Cell的创建
	@para 	table cellValues,
			int animatedIndex, 
			boolean isAnimate
	@return CCTableViewCell
--]]
function createGrayCell(cellValues, animatedIndex, isAnimate)
	print("createCopyCell ------EEEEEEEE")
	local tCell = CCTableViewCell:create()

	-- cell的外框 
    local cellFrame = nil
    if (cellValues.copyInfo.status == Status_Display) then
    	cellFrame = BTGraySprite:create("images/copy/ecopy/copyframe.png")
    else
    	cellFrame = CCSprite:create("images/copy/ecopy/copyframe.png")
    end
    cellFrame:setAnchorPoint(ccp(0,0))

    -- cell的背景 缩略图
	-- local cellBg = CCSprite:create("images/copy/ecopy/thumbnail/" .. cellValues.copyInfo.thumbnail)
	local cellBg = CCSprite:create("images/copy/ecopy/thumbnail/copy1.png" )
	if (cellValues.copyInfo.status == Status_Display) then
    	cellBg = BTGraySprite:create("images/copy/ecopy/thumbnail/copy1.png")
    else
    	cellBg = CCSprite:create("images/copy/ecopy/thumbnail/copy1.png" )
    end
	cellBg:setAnchorPoint(ccp(0,0))
    cellBg:setPosition(ccp(cellFrame:getContentSize().width*0.02, (cellFrame:getContentSize().height-cellBg:getContentSize().height)/2))
    cellFrame:addChild(cellBg,-1,-1)
	tCell:addChild(cellFrame,1,1)
	local cellFrameSize = cellFrame:getContentSize()
    
    --名称背景图
    local nameBg = nil
    if (cellValues.copyInfo.status == Status_Display) then
    	nameBg = BTGraySprite:create("images/copy/ecopy/namebg.png")
    else
    	nameBg = CCSprite:create("images/copy/ecopy/namebg.png" )
    end
    nameBg:setPosition(ccp(cellFrame:getContentSize().width*0.05, cellFrame:getContentSize().height*0.65))
    cellFrame:addChild(nameBg, Tag_NameBg, Tag_NameBg)

    --副本名称
    -- local nameSprite = CCSprite:create("images/copy/ecopy/nameimage/" .. cellValues.copyInfo.image)
    local nameSprite = nil
    if (cellValues.copyInfo.status == Status_Display) then
    	nameSprite = BTGraySprite:create("images/copy/ecopy/nameimage/name_copy1.png")
    else
    	nameSprite = CCSprite:create("images/copy/ecopy/nameimage/name_copy1.png" )
    end
    nameSprite:setAnchorPoint(ccp(0.5,0.5))
    nameSprite:setPosition(nameBg:getContentSize().width/2, nameBg:getContentSize().height/2);
    nameBg:addChild(nameSprite, Tag_NameSprite, Tag_NameSprite)

    if (cellValues.copyInfo.status == Status_Display) then
    	package.loaded["db/Copy"] = nil
    	require "db/DB_Copy"
	    local preCopyInfo = DB_Copy.getDataById(cellValues.copyInfo.pre_copyid)
	    local preName = CopyUtil.getOpenCondition(cellValues.copyInfo.id)
        
	
	    --开启条件
	    local preConditionLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1547") .. preName, g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
		preConditionLabel:setColor(ccc3(0xff, 0x90, 0x00))
		preConditionLabel:setPosition(ccp(cellFrameSize.width*0.8-preConditionLabel:getContentSize().width, cellFrameSize.height*0.7))
	    cellFrame:addChild(preConditionLabel, Tag_PreConditionText, Tag_PreConditionText)
    end
    
    --体力
    local costEnergyLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1299") .. cellValues.copyInfo.energy, g_sFontName, 20)
	costEnergyLabel:setColor(ccc3(0x36, 0xff, 0x00))
	costEnergyLabel:setPosition(ccp(cellFrameSize.width*0.75, cellFrameSize.height*0.2))
    cellFrame:addChild(costEnergyLabel, Tag_CostEnergy, Tag_CostEnergy)
    
	if(isAnimate == true) then
		cellFrame:setPosition(ccp(cellFrame:getContentSize().width, 0))
		cellFrame:runAction(CCMoveTo:create(0.05 * (animatedIndex ),ccp(0,0)))
	end

	return tCell
end

