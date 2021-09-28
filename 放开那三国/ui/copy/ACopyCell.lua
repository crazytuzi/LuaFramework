-- Filename：	CopyCell.lua
-- Author：		Cheng Liang
-- Date：		2013-7-3
-- Purpose：		活动副本Cell

module("CopyCell", package.seeall)

require "script/model/DataCache"

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
	print("createCopyCell ------AAAAAA")
	local tCell = CCTableViewCell:create()

	
	local isLevelOpen = true
	if(cellValues.copyInfo.limit_lv > UserModel.getHeroLevel())then
		isLevelOpen = false
	end

    local isGray = false

    if(isLevelOpen)then
    	if not DataCache.getSwitchNodeState(ksExpCopy, false) and tonumber(cellValues.copy_id) == 300005 then
	    	isGray = true
		end
		if( cellValues.copyInfo.id == 300004 and CopyUtil.isHeroExpCopyOpen() == false)then		
			isGray = true
		end
	else
		isGray = true
    end

    
	-- cell的外框 
    local cellFrame = BTGraySprite:create("images/copy/acopy/copyframe.png")
    cellFrame:setAnchorPoint(ccp(0,0))
    cellFrame:setGray(isGray)

    -- cell的背景 缩略图
    local cellBgIconName = "images/copy/acopy/thumbnail/" .. cellValues.copyInfo.thumbnail
	local cellBg = BTGraySprite:create(cellBgIconName)
	
	if(isLevelOpen and cellValues.copyInfo.id == 300004 and CopyUtil.isHeroExpCopyOpen() == false)then
		local numLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2093"), g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    numLabel:setColor(ccc3(0x36, 0xff, 0x00))
	    numLabel:setAnchorPoint(ccp(0.5, 0.5))
	    numLabel:setPosition(ccp(cellBg:getContentSize().width*0.5 , cellBg:getContentSize().height*0.3))
	    cellBg:addChild(numLabel)
	end

	cellBg:setAnchorPoint(ccp(0,0))
    cellBg:setPosition(ccp(cellFrame:getContentSize().width*0.02, (cellFrame:getContentSize().height-cellBg:getContentSize().height)/2))
    cellFrame:addChild(cellBg,-1,-1)
	tCell:addChild(cellFrame,1,1)
	cellBg:setGray(isGray)
	local cellFrameSize = cellFrame:getContentSize()
    
    --名称背景图
    local nameBg = CCSprite:create("images/copy/acopy/namebg.png" )
    if( cellValues.copyInfo.id == 300004 and CopyUtil.isHeroExpCopyOpen() == false or isGray)then
		nameBg = BTGraySprite:create("images/copy/acopy/namebg.png" )
	end
    nameBg:setPosition(ccp(cellFrame:getContentSize().width*0.05, cellFrame:getContentSize().height*0.65))
    cellFrame:addChild(nameBg, Tag_NameBg, Tag_NameBg)

    --副本名称
    local nameSprite = CCSprite:create("images/copy/acopy/nameimage/" .. cellValues.copyInfo.image)
    if( cellValues.copyInfo.id == 300004 and CopyUtil.isHeroExpCopyOpen() == false or isGray)then
		nameSprite = BTGraySprite:create("images/copy/acopy/nameimage/" .. cellValues.copyInfo.image)
	end
    nameSprite:setAnchorPoint(ccp(0.5,0.5))
    nameSprite:setPosition(nameBg:getContentSize().width/2, nameBg:getContentSize().height/2);
    nameBg:addChild(nameSprite, Tag_NameSprite, Tag_NameSprite)

    -- if( cellValues.copyInfo.id == 300001 or cellValues.copyInfo.id == 300002 or cellValues.copyInfo.id == 300004)then
    	-- 摇钱树
    	-- 次数
    	local leftTimes = cellValues.can_defeat_num
    	if( cellValues.copyInfo.id == 300004 )then
    		leftTimes = DataCache.getHeroExpDefeatNum()
    	end
	    local numLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1992") .. leftTimes, g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    numLabel:setColor(ccc3(0x36, 0xff, 0x00))
	    numLabel:setAnchorPoint(ccp(1, 0.5))
	    numLabel:setPosition(ccp(cellBg:getContentSize().width*0.9 , cellBg:getContentSize().height*0.8))
	    cellBg:addChild(numLabel)
	    numLabel:setVisible(not isGray)

	    if(isLevelOpen and cellValues.copyInfo.id == 300001)then
		    local tipSprite = CCSprite:create("images/copy/acopy/tip_" .. cellValues.copyInfo.id .. ".png")
		    tipSprite:setAnchorPoint(ccp(0.5,0.5))
		    tipSprite:setPosition(cellBg:getContentSize().width/2, cellBg:getContentSize().height*0.1);
		    cellBg:addChild(tipSprite)
			
			local item_temp_id = CopyUtil.getCanDefeatItemTemplateIdBy(300001)
			local number = ItemUtil.getCacheItemNumBy( item_temp_id )
			local itemName = ItemUtil.getItemNameByItmTid(item_temp_id)

			-- 消耗的物品 80 00 80
			local fontLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1698"), g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    fontLabel:setColor(ccc3(0x36, 0xff, 0x00))

			local energyLabel = CCRenderLabel:create(itemName, g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    energyLabel:setColor(ccc3(255, 0, 0xe1))

		    local fontLabel2 = CCRenderLabel:create(GetLocalizeStringBy("key_3316"), g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    fontLabel2:setColor(ccc3(0x36, 0xff, 0x00))

		    -- 拥有
		    local fontLabel3 = CCRenderLabel:create(GetLocalizeStringBy("key_2032") .. number .. ")", g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    fontLabel3:setColor(ccc3(0x36, 0xff, 0x00))

		    -- change by zhz
		    require "script/utils/BaseUI"
		    local fontNode=  BaseUI.createHorizontalNode({fontLabel,energyLabel,fontLabel2, fontLabel3})
		    fontNode:setPosition( cellBg:getContentSize().width*0.99 , cellBg:getContentSize().height*0.6)
		    fontNode:setAnchorPoint(ccp(1,0.5))
		    cellBg:addChild(fontNode)

		    -- 摇钱树等级
		    local nodeArr = {}
		    local curFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1271"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    curFont:setColor(ccc3(0xff, 0xff, 0xff))
		    table.insert(nodeArr,curFont)
		    -- 等级
		    local lvSp = CCSprite:create("images/common/lv.png")
		    table.insert(nodeArr,lvSp)
		    local boosLevelNum = DataCache.getTreeBossLevel()
		    local lvFont = CCRenderLabel:create(boosLevelNum .. " ", g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    lvFont:setColor(ccc3(0xff, 0xf6, 0x00))
		    table.insert(nodeArr,lvFont)
		    -- 最大等级
		    local maxLv = DataCache.getConfigTreeMaxLv()
		    local realExpNum = 0
		    local needExpNum = 0
		    local rate = 0
		    if(boosLevelNum < maxLv)then
			    -- 经验条
			    realExpNum = DataCache.getTreeBossExp()
				needExpNum = DataCache.getTreeBossMaxExp(DataCache.getTreeBossLevel() + 1)
				rate = realExpNum/needExpNum
				if(rate > 1)then
					rate = 1
				end
			else
				rate = 1
			end
		    -- expbg
		    local bgProress = CCScale9Sprite:create("images/common/exp_bg.png")
			bgProress:setContentSize(CCSizeMake(181, 23))
			table.insert(nodeArr,bgProress)
			-- 蓝条
			local progressSp = CCScale9Sprite:create("images/common/exp_progress.png")
			progressSp:setContentSize(CCSizeMake(181*rate, 23))
			progressSp:setAnchorPoint(ccp(0, 0.5))
			progressSp:setPosition(ccp(0, bgProress:getContentSize().height * 0.5))
			bgProress:addChild(progressSp)
			-- 经验值
			if(boosLevelNum < maxLv)then
				local expLabel = CCRenderLabel:create(realExpNum .. "/" .. needExpNum, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
				expLabel:setColor(ccc3(0xff, 0xff, 0xff))
				expLabel:setAnchorPoint(ccp(0.5, 0.5))
				expLabel:setPosition(ccp(bgProress:getContentSize().width*0.5, bgProress:getContentSize().height*0.5))
				bgProress:addChild(expLabel,10)
			else
				local maxSprrite = CCSprite:create("images/common/max.png")
				maxSprrite:setAnchorPoint(ccp(0.5, 0.5))
				maxSprrite:setPosition(ccp(bgProress:getContentSize().width*0.5, bgProress:getContentSize().height * 0.5))
				bgProress:addChild(maxSprrite,10)
			end
			-- 提示
		    local expNode = BaseUI.createHorizontalNode(nodeArr)
		    expNode:setAnchorPoint(ccp(0.5,0.5))
		    expNode:setPosition( cellBg:getContentSize().width*0.5 , cellBg:getContentSize().height*0.35)
		    cellBg:addChild(expNode)
		else
		 --    -- 体力 去掉，changed by zhz
			-- local energyLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1299") .. cellValues.copyInfo.attack_energy, g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
		 --    energyLabel:setColor(ccc3(0x36, 0xff, 0x00))
		 --    energyLabel:setAnchorPoint(ccp(1, 0.5))
		 --    energyLabel:setPosition(ccp( cellBg:getContentSize().width*0.95 , cellBg:getContentSize().height*0.6))
		 --    cellBg:addChild(energyLabel)
	    end

	    if(isLevelOpen == false and cellValues.copyInfo.id == 300001)then
		    local tipSprite = BTGraySprite:create("images/copy/acopy/tip_" .. cellValues.copyInfo.id .. ".png")
		    tipSprite:setAnchorPoint(ccp(0.5,0.5))
		    tipSprite:setPosition(cellBg:getContentSize().width/2, cellBg:getContentSize().height*0.1);
		    cellBg:addChild(tipSprite)
		end

		--增加英雄天命 2016.5.27 zhangqiang
	    if( isLevelOpen and ( cellValues.copyInfo.id == 300001 or cellValues.copyInfo.id == 300002 or cellValues.copyInfo.id == HeroDestineyCopyData.kHeroDestineyTid) )then
	      -- 增加次数的按钮
		    local menuBar= CCMenu:create()
		    menuBar:setPosition(ccp(0,0))
		    cellBg:addChild(menuBar)

		    local addAtkBtn = CCMenuItemImage:create("images/common/btn/btn_plus_h.png", "images/common/btn/btn_plus_n.png")
		    addAtkBtn:setPosition(ccp(cellBg:getContentSize().width*0.9 , cellBg:getContentSize().height*0.82 ))
		    addAtkBtn:setAnchorPoint(ccp(0,0.5))
		    addAtkBtn:registerScriptTapHandler(addAtkAction)
		    menuBar:addChild(addAtkBtn, 11,cellValues.copyInfo.id )
		end
    -- end
    if(isLevelOpen == false) then
    	local openSprite = CCSprite:create("images/copy/acopy/lock_bg.png")
    	openSprite:setAnchorPoint(ccp(0.5,0.5))
    	openSprite:setPosition(ccp(cellBg:getContentSize().width*0.5 , cellBg:getContentSize().height*0.5))
    	cellBg:addChild(openSprite)
    	local lockSprite = CCSprite:create("images/copy/acopy/lock.png")
    	lockSprite:setAnchorPoint(ccp(0.5,0.5))
    	lockSprite:setPosition(ccp(openSprite:getContentSize().width*0.1, openSprite:getContentSize().height*0.5))
    	openSprite:addChild(lockSprite)
    	local openLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1823",tonumber(cellValues.copyInfo.limit_lv)), g_sFontPangWa, 32)
		openLabel:setColor(ccc3(0xff, 0xf6, 0x00))
		openLabel:setAnchorPoint(ccp(0.5, 0.5))
		openLabel:setPosition(ccp(openSprite:getContentSize().width*0.6, openSprite:getContentSize().height*0.5))
		openSprite:addChild(openLabel,10)
    end

	if(isAnimate == true) then
		print("createCopyCell......" .. animatedIndex)
		cellFrame:setPosition(ccp(cellFrame:getContentSize().width, 0))
		cellFrame:runAction(CCMoveTo:create(0.05 * (animatedIndex ),ccp(0,0)))
	end

	return tCell
end


-- added by zhz
function addAtkAction( tag, item )
	require "script/ui/tip/BuyCopyAtkLayer"
	local copyId = tonumber(tag)
	local cType = nil
	local buyAtkNum = 0
	local defaultNum =0 
	-- 摇钱树
	if(copyId == 300001) then
		cType = 2
		buyAtkNum= DataCache.getGoldTreeAtkNum()
		defaultNum= DataCache.getGoldTreeDefeatNum()

	-- 经验书
	elseif(copyId == 300002 ) then
		cType = 3
		buyAtkNum = DataCache.getTreasureBuyAtkNum()
		defaultNum = DataCache.getTreasureExpDefeatNum()
	elseif(copyId == 300005) then
		cType = 5
		require "script/ui/copy/expcopy/ExpCopyData"
		buyAtkNum = ExpCopyData.getCanBuyAtkNum()
		defaultNum = ExpCopyData.getCanDefeatNum()
	elseif(copyId == HeroDestineyCopyData.kHeroDestineyTid) then   --增加英雄天命 2016.5.27 zhangqiang
		cType = 6
		buyAtkNum = HeroDestineyCopyData.getBuyNum()
		defaultNum = HeroDestineyCopyData.getLeftAtkNum()
	end	

	if(defaultNum >0) then
		AnimationTip.showTip(GetLocalizeStringBy("key_1607"))
		return
	end

	-- BuyCopyAtkLayer.showLayer( cType ,buyAtkNum , CopyLayer.refreshACopyView )
	if cType == 6 then
		require "script/ui/copy/heroDestineyCopy/HeroDestineyCopyCtrl"
		HeroDestineyCopyCtrl.showAttckBuyLayer()
	else
		BuyCopyAtkLayer.showLayer( cType ,buyAtkNum , CopyLayer.refreshACopyView )
	end
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

    --体力
    local costEnergyLabel = tolua.cast(cellFrame:getChildByTag(Tag_CostEnergy), "CCLabelTTF")
    costEnergyLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1299") .. cellValues.copyInfo.energy, g_sFontName, 20)
	costEnergyLabel:setColor(ccc3(0x36, 0xff, 0x00))
	costEnergyLabel:setPosition(ccp(cellFrame:getContentSize().width*0.8, cellFrame:getContentSize().height*0.1))
    cellFrame:addChild(costEnergyLabel, Tag_CostEnergy, Tag_CostEnergy)

	if(isAnimate == true) then
		print("setCellValue-------" .. animatedIndex)
		cellFrame:setPosition(ccp(cellFrame:getContentSize().width, 0))
		cellFrame:runAction(CCMoveTo:create(g_cellAnimateDuration * (animatedIndex ),ccp(0,0)))
	end
end
