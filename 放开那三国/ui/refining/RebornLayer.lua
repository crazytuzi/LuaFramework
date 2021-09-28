-- Filename: RebornLayer.lua
-- Author: zhang zihang
-- Date: 2015-2-28
-- Purpose: 重生页面

module ("RebornLayer", package.seeall)

require "script/ui/tip/LackGoldTip"
require "script/ui/refining/RefiningController"
require "script/ui/hero/HeroPublicUI"
require "script/ui/refining/preview/RebornPreviewDialog"
require "script/ui/refining/preview/RefiningPreviewController"
require "script/ui/refining/preview/RefiningPreviewData"

local _layer 				--创建的layer
local _baseMenu 			--基础menu
local _goldNumLabel 		--所需金币label
local _menuItemSprite 		--选择框
local _resurrectMenuItem    --重生按钮
local _goldNum 				--所需金币数
local _hadNoticeStr			--武将或神兵觉醒提示

--x坐标位置
local kPosX = g_winSize.width*0.5
--y坐标位置
local kPosY = g_winSize.height*0.5 + 130*g_fScaleX

--==================== Init ====================
--[[
	@des 	:初始化函数
--]]
function init()
	_layer = nil
	_baseMenu = nil
	_goldNumLabel = nil
	_menuItemSprite = nil
	_resurrectMenuItem = nil
	_goldNum = 0
	_hadNoticeStr = nil
end

--==================== CallBack ====================
--[[
	@des 	:选择回调
--]]
function selectCallBack(p_tag)
	require "script/ui/refining/RefiningSelectLayer"
	RefiningSelectLayer.createLayer()
end

-- 增加重生预览 modify by lgx 20160509
--[[
	@desc 	: 重生普通武将预览回调方法
	@param 	: pSelectedInfo 选择的武将或宝物等信息
	@param  : pData 重生获得预览信息
	@return : 
--]]
function previewRebornCallBack( pSelectedInfo, pData )
	local previewData = RefiningPreviewData.solveRebornPreviewData(pSelectedInfo,pData)
	-- print("-----------------previewRebornCallBack-----------------")
	-- print_t(pSelectedInfo)
	-- print_t(pData)
	-- print_t(previewData)
	-- print("-----------------previewRebornCallBack-----------------")
	-- 确认重生回调
	local confirmCallback = function()
		-- 实际确认重生
		RefiningController.sureToResurrect()
	end
	RebornPreviewDialog.showDialog(previewData, _goldNum, _hadNoticeStr, confirmCallback, -1000, 1000)
end

--[[
	@des 	:开始重生回调
--]]
function gotoResurrectCallBack()
	
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	--选择table
	local selectTable = RefiningData.getSelectArray()
	local userInfo = UserModel.getUserInfo()
	--如果是空
	if table.isEmpty(selectTable) then
		AnimationTip.showTip(GetLocalizeStringBy("key_1748"))
		return
	elseif tonumber(userInfo.gold_num) < _goldNum then
		LackGoldTip.showTip()
		return
	end

	-- 记录武将或神兵觉醒提示
	_hadNoticeStr = nil

	local selectInfo = selectTable[1]
	local curTag = RefiningData.getCurSelectTag()
	if curTag == RefiningData.kHeroTag then
		if  ItemUtil.isPropBagFull(true) then
			return
		elseif HeroPublicUI.showHeroIsLimitedUI() then
			return
		elseif ItemUtil.isTreasBagFull(true) then
			return		
		end

		local heroInfo = HeroModel.getHeroByHid(selectInfo.hid)
		--有觉醒
		if heroInfo["talent"]["confirmed"]["1"] ~= nil then
			_hadNoticeStr = GetLocalizeStringBy("lgx_1063")
		--在活动中
		elseif ActiveCache.isUnhandleTransfer(heroInfo.hid) then
			_hadNoticeStr = GetLocalizeStringBy("lgx_1064")
		end
	elseif curTag == RefiningData.kEquipTag then
		if ItemUtil.isPropBagFull(true) then
			return
		end

	elseif curTag == RefiningData.kTreasureTag then
		if ItemUtil.isPropBagFull(true) then
			return
		elseif ItemUtil.isTreasBagFull(true) then
			return
		end

	elseif curTag == RefiningData.kClothTag then
		if ItemUtil.isPropBagFull(true) then
			return
		end

	elseif curTag == RefiningData.kGodTag then
		if ItemUtil.isPropBagFull(true) then
			return
		elseif ItemUtil.isGodWeaponBagFull(true) then
			return	
		end
		if selectInfo.va_item_text.confirmed ~= nil then
			_hadNoticeStr = GetLocalizeStringBy("lgx_1065")
		end
	elseif curTag == RefiningData.kPocketTag then	
		if ItemUtil.isPocketBagFull(true) then
			return 
		end
	elseif curTag == RefiningData.kTallyTag then
		if ItemUtil.isTallyBagFull(true) then
			return
		end
	elseif curTag == RefiningData.kChariotTag then
		-- 战车
		if ItemUtil.isChariotBagFull(true) then
			return
		end
	end
	-- 重生预览
	
	local path = CCFileUtils:sharedFileUtils():getWritablePath() .. 'test'
	mFile = io.open(path, 'ab+')
	mFile:write("ccc" .. "\n")
	mFile:flush()
	RefiningPreviewController.previewReborn(previewRebornCallBack)
end

--[[
	@des 	:扣除金币
--]]
function minusGoldNum()
	UserModel.addGoldNumber(tonumber(-_goldNum))
	_goldNum = 0
	_goldNumLabel:setString(_goldNum)
end

--==================== UI ====================
--[[
	@des 	:按钮不可点
--]]
function disableMenuItem()
	_resurrectMenuItem:setEnabled(false)
end

--[[
	@des 	:设置按钮可点
--]]
function enableMenuItem()
	_resurrectMenuItem:setEnabled(true)
end

--[[
	@des 	:按钮不可见
--]]
function menuItemUnVisible()
	_menuItemSprite:setVisible(false)
end

--[[
	@des 	:清除按钮上有图片的显示
--]]
function clearItemSprite()
	_menuItemSprite:removeFromParentAndCleanup(true)
	_menuItemSprite = nil
	_menuItemSprite = RefiningUtils.createSelectMenuItem()
	_menuItemSprite:setAnchorPoint(ccp(0.5,0.5))
	_menuItemSprite:setPosition(ccp(kPosX,kPosY))
	_menuItemSprite:registerScriptTapHandler(selectCallBack)
	_menuItemSprite:setScale(g_fElementScaleRatio)
	_baseMenu:addChild(_menuItemSprite)
end

--[[
	@des 	:创建选择按钮
--]]
function createChooseMenu()
	--选择table
	local selectTable = RefiningData.getSelectArray()

	_menuItemSprite = RefiningUtils.createSelectMenuItem(selectTable[1])
	_menuItemSprite:setAnchorPoint(ccp(0.5,0.5))
	_menuItemSprite:setPosition(ccp(kPosX,kPosY))
	_menuItemSprite:registerScriptTapHandler(selectCallBack)
	_menuItemSprite:setScale(g_fElementScaleRatio)
	_baseMenu:addChild(_menuItemSprite)
end

--[[
	@des 	:创建所需金币
--]]
function createGoldUI()
	local tipLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1642"),g_sFontName,23,2,ccc3(0x00,0x00,0x00),type_shadow)
	tipLabel:setPosition(ccp(g_winSize.width/2 - 40*g_fScaleX,g_winSize.height*260/960))
	tipLabel:setScale(g_fElementScaleRatio)
	tipLabel:setAnchorPoint(ccp(1,1))
	tipLabel:setColor(ccc3(0x00,0xe4,0xff))
	_layer:addChild(tipLabel)

	local fullRect = CCRectMake(0, 0, 34, 32)
	local insetRect = CCRectMake(12, 12, 10, 6)
	local goldBgSprite = CCScale9Sprite:create("images/common/checkbg.png",fullRect,insetRect)
	goldBgSprite:setPreferredSize(CCSizeMake(180,36))
	goldBgSprite:setAnchorPoint(ccp(0,1))
	goldBgSprite:setScale(g_fElementScaleRatio)
	goldBgSprite:setPosition(ccp(g_winSize.width/2 - 40*g_fScaleX,g_winSize.height*265/960))
	_layer:addChild(goldBgSprite)

	local goldSprite = CCSprite:create("images/common/gold.png")
	goldSprite:setPosition(25,goldBgSprite:getContentSize().height/2)
	goldSprite:setAnchorPoint(ccp(0.5,0.5))
	goldBgSprite:addChild(goldSprite)

	--选择table
	local selectTable = RefiningData.getSelectArray()
	--如果不为空
	if not table.isEmpty(selectTable) then
		local curData = selectTable[1]
		local curTag = RefiningData.getCurSelectTag()
		if curTag == RefiningData.kHeroTag then
			_goldNum = (curData.evolve_level+1)*(curData.rebirth_basegold) + curData.rebirth_addgold
		elseif curTag == RefiningData.kEquipTag then
			_goldNum = curData.itemDesc.resetCostGold
		elseif curTag == RefiningData.kTreasureTag then
			_goldNum = curData.itemDesc.rebirthGold
		elseif curTag == RefiningData.kClothTag then
			_goldNum = curData.itemDesc.resetGold*(curData.va_item_text.dressLevel)
		elseif curTag == RefiningData.kGodTag then
			local godString = curData.itemDesc.reborn_cost
			local splitString = string.split(godString,",")
			for i = 1,#splitString do
				local secondString = string.split(splitString[i],"|")
				if tonumber(secondString[1]) == tonumber(curData.va_item_text.evolveNum) then
					_goldNum = tonumber(secondString[2])
					break
				end 
			end
		elseif curTag == RefiningData.kPocketTag then
			require "db/DB_Normal_config"
			local quality = curData.itemDesc.quality
			local costList = DB_Normal_config.getDataById(1).pocket_reborn
			costList  = string.split(costList,",")
			_goldNum = tonumber(costList[quality])
		elseif curTag == RefiningData.kTallyTag then
			_goldNum = RefiningData.getTallyRebornCost(curData.item_template_id)
		elseif curTag == RefiningData.kChariotTag then
			-- 战车
			_goldNum = RefiningData.getChariotRebornCost(curData.item_template_id)
		end
	end
	
	_goldNumLabel = CCRenderLabel:create(_goldNum,g_sFontName,23,2,ccc3(0x00,0x00,0x00),type_shadow)
	_goldNumLabel:setPosition(ccp(50,goldSprite:getContentSize().height*0.5))
	_goldNumLabel:setAnchorPoint(ccp(0,0.5))
	_goldNumLabel:setColor(ccc3(0xff,0xff,0xff))
	goldSprite:addChild(_goldNumLabel)
end

--[[
	@des 	:创建重生按钮
--]]
function createMenuItem()
	_resurrectMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,73),GetLocalizeStringBy("key_2251"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
	_resurrectMenuItem:setAnchorPoint(ccp(0.5, 0.5))
    _resurrectMenuItem:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*180/960))
    _resurrectMenuItem:registerScriptTapHandler(gotoResurrectCallBack)
	_resurrectMenuItem:setScale(g_fElementScaleRatio)
	_baseMenu:addChild(_resurrectMenuItem)
end

--[[
	@des 	:创建UI
--]]
function createUI()
	--创建选择按钮
	createChooseMenu()
	--创建所需金币框
	createGoldUI()
	--创建重生按钮
	createMenuItem()
end

--[[
	@des 	:创建最基础的layer和menu
--]]
function createBaseUI()
	--背景layer
	_layer = CCLayer:create()
	--基础menu
	_baseMenu = CCMenu:create()
	_baseMenu:setAnchorPoint(ccp(0,0))
	_baseMenu:setPosition(ccp(0,0))
	_layer:addChild(_baseMenu)
end

--==================== Entrance ====================
--[[
	@des 	:初始化函数
	@return :创建好的layer
--]]
function createLayer()
	init()

	--创建最基本的layer和menu
	createBaseUI()

	--创建UI
	createUI()

	return _layer
end