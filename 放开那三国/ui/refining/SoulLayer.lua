-- Filename: SoulLayer.lua
-- Author: shengyixian
-- Date: 2015-9-24
-- Purpose: 化魂页面
module("SoulLayer",package.seeall)
require "script/ui/refining/RefiningUtils"
require "script/ui/refining/RefiningData"
-- 是否开启武将精华化魂
kIsHeroJHOpen = nil
-- kIsHeroJHOpen = false

local _layer = nil
--选择按钮的数量
local _kSelectNum = 5
--基础menu
local _baseMenu = nil
--存放按钮的容器 	
local _menuItemContainer = nil	
--化魂按钮
local _soulBtn = nil
--一键添加按钮
local _oneKeyBtn = nil
-- 一键添加武将精华
local _oneKeyJhBtn = nil
-- 按钮容器
local _fastContainer = nil
--x坐标位置
local kMenuPosXTable = { g_winSize.width*0.5 , 
						 g_winSize.width*0.5 - 220*g_fScaleX , 
						 g_winSize.width*0.5 + 220*g_fScaleX , 
						 g_winSize.width*0.5 - 130*g_fScaleX , 
						 g_winSize.width*0.5 + 130*g_fScaleX 
					   }
--y坐标位置
local kMenuPosYTable = { g_winSize.height*0.5 + 250*g_fScaleY , 
						 g_winSize.height*0.5 + 130*g_fScaleY , 
						 g_winSize.height*0.5 + 130*g_fScaleY , 
						 g_winSize.height*0.5 - 60*g_fScaleY , 
						 g_winSize.height*0.5 - 60*g_fScaleY 
					   }

function init( ... )
	_layer = nil
	_baseMenu = nil
	_menuItemContainer = {}
	_soulBtn = nil
	_oneKeyBtn = nil
	_oneKeyJhBtn = nil
	_fastContainer = nil
	kIsHeroJHOpen = DataCache.getSwitchNodeState(ksSwitchRedHero,false)
end
--[[
	@des 	:初始化界面
--]]
function initView( ... )
	-- body
	RefiningData.setFastBeginNum(0)
	_baseMenu = CCMenu:create()
	_baseMenu:setAnchorPoint(ccp(0,0))
	_baseMenu:setPosition(ccp(0,0))
	_layer:addChild(_baseMenu)
	createChooseMenu()
	createBaseMenuItem()
	createSilverUI()
end

function createLayer( ... )
	-- body
	init()
	_layer = CCLayer:create()
	initView()
	return _layer
end

--[[
	@des 	:创建基础按钮
--]]
function createBaseMenuItem()
	_soulBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(250,73),GetLocalizeStringBy("key_10338"),ccc3(0xfe,0xdb, 0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
	_soulBtn:setAnchorPoint(ccp(0.5,0.5))
	if kIsHeroJHOpen then
    	_soulBtn:setPosition(ccp(g_winSize.width * 0.5,270 * g_fScaleY))
    else
    	_soulBtn:setPosition(ccp(g_winSize.width*0.75,200 * g_fScaleY))
    end
    _soulBtn:registerScriptTapHandler(soulHandler)
    _soulBtn:setScale(g_fElementScaleRatio)
	_baseMenu:addChild(_soulBtn)
	--几个快速选择按钮
	_fastContainer = {}
	local btnSize = CCSizeMake(250,73)
	local btnInfoTable = {
						{ nameString = GetLocalizeStringBy("key_8332"),headPath = "",
						  anchor = ccp(0.5,0.5),pos = ccp(g_winSize.width * 0.25,200 * g_fScaleY),tags = RefiningData.kHeroTag },
						{ nameString = GetLocalizeStringBy("syx_1056"),headPath = "",
						  anchor = ccp(0.5,0.5),pos = ccp(g_winSize.width*0.75,200 * g_fScaleY),tags = RefiningData.kHeroJHTag },
					 }
	for i,fastInfo in ipairs(btnInfoTable) do
		local btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",btnSize,fastInfo.nameString,ccc3(0xfe,0xdb, 0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
		btn:setAnchorPoint(fastInfo.anchor)
		btn:setPosition(fastInfo.pos)
		btn:registerScriptTapHandler(fastAddCallBack)
		btn:setScale(g_fElementScaleRatio)
		_baseMenu:addChild(btn,1,fastInfo.tags)
		_fastContainer[fastInfo.tags] = btn
		if not kIsHeroJHOpen then
			break
		end
	end
end

--[[
	@des 	:快速添加回调
	@param  :tag值
	@param  :按钮
--]]
function fastAddCallBack(p_tag,p_menuItem)
	local curTag = RefiningData.getCurSelectTag()
	-- RefiningData.resetChooseData()
	if p_tag ~= curTag then
		RefiningData.setCurSelectTag(p_tag)
		RefiningData.setFastBeginNum(0)
	end
	--适合的table
	local fitTable = {}
	local tipString = nil
	if p_tag == RefiningData.kHeroTag then
		tipString = GetLocalizeStringBy("syx_1057")
	elseif p_tag == RefiningData.kHeroJHTag then
		tipString = GetLocalizeStringBy("syx_1058")
	end
	RefiningController.oneKeyAdd()
	fitTable = RefiningData.getSelectArray()
	--如果选择为空
	if table.isEmpty(fitTable) then
		AnimationTip.showTip(tipString)
	else

	end
end

--[[
	@des 	:创建选择按钮
--]]
function createChooseMenu()
	--选择table
	local selectTable = RefiningData.getSelectArray()

	for i = 1,_kSelectNum do
		local menuItemSprite = RefiningUtils.createSelectMenuItem(selectTable[i])
		menuItemSprite:setAnchorPoint(ccp(0.5,0.5))
		menuItemSprite:setPosition(ccp(kMenuPosXTable[i],kMenuPosYTable[i]))
		menuItemSprite:registerScriptTapHandler(selectCallBack)
		menuItemSprite:setScale(g_fElementScaleRatio)
		_baseMenu:addChild(menuItemSprite)
		--加入容器中
		table.insert(_menuItemContainer,menuItemSprite)
	end
end
--[[
	@des 	:所需银币
--]]
function createSilverUI()
	local tipLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1657"),g_sFontName,23,2,ccc3(0x00,0x00,0x00),type_shadow)
	if kIsHeroJHOpen then
		tipLabel:setPosition(ccp(g_winSize.width/2 - 40*g_fScaleX,340 * g_fScaleY))
	else
		tipLabel:setPosition(ccp(g_winSize.width/2 - 40*g_fScaleX,300 * g_fScaleY))
	end
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
	goldBgSprite:setPosition(ccp(g_winSize.width/2 - 40*g_fScaleX + 5,tipLabel:getPositionY() + 7 * g_fScaleY))
	_layer:addChild(goldBgSprite)
	local goldSprite = CCSprite:create("images/common/coin_silver.png")
	goldSprite:setPosition(25,goldBgSprite:getContentSize().height/2)
	goldSprite:setAnchorPoint(ccp(0.5,0.5))
	goldBgSprite:addChild(goldSprite)
	_goldNumLabel = CCRenderLabel:create(RefiningData.getSoulSilver(),g_sFontName,23,2,ccc3(0x00,0x00,0x00),type_shadow)
	_goldNumLabel:setPosition(ccp(45,goldSprite:getContentSize().height*0.5))
	_goldNumLabel:setAnchorPoint(ccp(0,0.5))
	_goldNumLabel:setColor(ccc3(0xff,0xff,0xff))
	goldSprite:addChild(_goldNumLabel)
end
--[[
	@des 	:选择按钮回调
--]]
function selectCallBack(p_tag)
	require "script/ui/refining/RefiningSelectLayer"
	RefiningSelectLayer.createLayer()
end

--[[
	@des 	:选择按钮不可见
--]]
function menuItemUnVisible()
	for i = 1,#_menuItemContainer do
		_menuItemContainer[i]:setVisible(false)
	end
end
--[[
	@des 	:一键添加按钮回调
--]]
function oneKeyHandler( ... )
	-- body
	RefiningController.oneKeyAdd()
end
--[[
	@des 	:一键添加后刷新
--]]
function updateMenuItemContainer()
	for i = 1,_kSelectNum do
		_menuItemContainer[i]:removeFromParentAndCleanup(true)
		_menuItemContainer[i] = nil
	end
	_menuItemContainer = {}
	createChooseMenu()
	updateAfterSoul()
end
--[[
	@des 	:清除按钮上有图片的显示
--]]
function clearAndShowItem()
	for i = 1,_kSelectNum do
		_menuItemContainer[i]:removeFromParentAndCleanup(true)
		_menuItemContainer[i] = nil
		_menuItemContainer[i] = RefiningUtils.createSelectMenuItem()
		_menuItemContainer[i]:setAnchorPoint(ccp(0.5,0.5))
		_menuItemContainer[i]:setPosition(ccp(kMenuPosXTable[i],kMenuPosYTable[i]))
		_menuItemContainer[i]:registerScriptTapHandler(selectCallBack)
		_menuItemContainer[i]:setScale(g_fElementScaleRatio)
		_baseMenu:addChild(_menuItemContainer[i])
	end
	_goldNumLabel:setString(0)
end
--[[
	@des 	:化魂按钮回调
--]]
function soulHandler()
	local selectTable = RefiningData.getSelectArray()
	print("selectTable")
	print_t(selectTable)
	--如果没有选择，则提示
	if table.isEmpty(selectTable) then
		AnimationTip.showTip(GetLocalizeStringBy("key_10340"))
		return
	end
	--得到当前选择tag
	local curTag = RefiningData.getCurSelectTag()
	if curTag == RefiningData.kHeroJHTag then
		-- 化魂的后得到将星的总个数,用于化魂前奖励展示
		local jhNum = 0
		for i,v in ipairs(selectTable) do
			jhNum = jhNum + v.selectNum * v.diss_num
		end
		require "script/ui/recycle/SeeRewardDialog"
		local reward = ItemUtil.getItemsDataByStr(nil,{{type = 26,id = 0,num = jhNum}})
		SeeRewardDialog.show(reward,function ( ... )
			_soulBtn:setEnabled(false)
			RefiningController.sureToSoul(curTag)
		end)
	else
		_soulBtn:setEnabled(false)
		RefiningController.sureToSoul(curTag)
	end
end

function showReward(data)
	require "script/ui/recycle/ShowRewardDialog"
	ShowRewardDialog.showLayer(data)
	ShowRewardDialog.setTitle(GetLocalizeStringBy("key_10336"))
	clearAndShowItem()
end

--[[
	@des 	:设置按钮不可点
--]]
function disableMenuItem()
	for k,v in pairs(_fastContainer) do
		v:setEnabled(false)
	end
end

--[[
	@des 	:设置按钮可点
--]]
function enableMenuItem()
	for k,v in pairs(_fastContainer) do
		v:setEnabled(true)
	end
end
--[[
	@des 	:更新银币的显示
--]]
function updateSilver()
	-- body
	_goldNumLabel:setString(RefiningData.getSoulSilver())
end
--[[
	@des 	:化魂成功后刷新界面
--]]
function updateAfterSoul( ... )
	updateSilver()
	_soulBtn:setEnabled(true)
end