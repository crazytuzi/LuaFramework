-- Filename：	GodWeaponInfoLayer.lua
-- Author：		Zhang zihang
-- Date：		2014-12-12
-- Purpose：		神兵信息界面

module("GodWeaponInfoLayer", package.seeall)

require "script/audio/AudioUtil"
require "script/utils/BaseUI"
require "script/ui/item/GodWeaponItemUtil"
require "script/ui/hero/HeroPublicLua"
require "script/ui/godweapon/GodWeaponService"
require "script/ui/tip/AnimationTip"
require "script/ui/formation/ChangeEquipLayer"
require "script/ui/godweapon/godweaponfix/GodWeaponFixData"
require "db/DB_Heroes"

local _touchPriority			--触摸优先级
local _zOrder					--Z轴
local _bgLayer					--背景层
local _DBInfo					--神兵的DB数据信息
local _quality 					--品质
local _evolveNum				--进化次数
local _showEvolveNum			--显示的进化次数
local _itemInfo 				--物品信息
local _hid 						--武将hid
local _isChange 				--是否显示更换按钮
local _isWater 					--是否显示进化按钮
local _isEnhance 				--是否显示强化按钮
local _bgMenu 					--背景menu层
local _itemPos 					--在阵容中物品的位置
local _itemId 					--物品id
local _menuType 				--按钮类型
local _otherHeroInfo 			--对方阵容英雄信息
local _lockMenuItem 			--锁按钮
local _unLockMenuItem 			--解锁按钮
local _delegate					--回调
											--[[
													0 => 只有返回按钮
													1 => 更换、卸下、进阶、强化
													2 => 更换、卸下、强化
													3 => 进阶、强化
													4 => 强化
											--]]
local kMenuTypeZero = 0
local kMenuTypeOne = 1
local kMenuTypeTwo = 2
local kMenuTypeThree = 3
local kMenuTypeFour = 4

local kLockItem = 0
local kUnlockItem = 1

local kTypeTable = {
						[1] = GetLocalizeStringBy("key_2371"),
						[2] = GetLocalizeStringBy("zzh_1215"),
						[3] = GetLocalizeStringBy("zzh_1216"),
				   }
local kChange = 1000
local kWater = 1001
local kEnhance = 1002
local kTakeDown = 1003

local lastShowParameters = nil

--==================== Init ====================

--[[
	@des 	:初始化函数
--]]
function init()
	_touchPriority 	= nil
	_zOrder 		= nil
	_quality 		= 0
	_evolveNum 		= 0
	_showEvolveNum  = 0
	_menuType 		= kMenuTypeZero 			
	_bgLayer 		= nil
	_hid 			= nil
	_isChange 		= nil
	_isWater 		= nil
	_isEnhance		= nil
	_bgMenu 		= nil
	_itemPos 		= nil
	_itemId 		= nil
	_otherHeroInfo  = nil
	_lockMenuItem 	= nil
	_unLockMenuItem = nil
	_delegate 		= nil
	_DBInfo 		= {}
	_itemInfo 		= {}
end

--[[
	@des 	:点击事件函数
--]]
function onTouchesHandler()
	return true
end

--[[
	@des 	:事件函数
	@param 	:事件
--]]
function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif eventType == "exit" then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

--==================== CallBack ====================

--[[
	@des 	:关闭回调
--]]
function closeCallBack()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	removeLayer()
end

--[[
	@des 	:洗练回调
--]]
function waterCallBack()
	closeCallBack()

	require "script/ui/godweapon/godweaponfix/GodWeaponFixLayer"
	GodWeaponFixLayer.showLayer(_itemId)
	if _isChange == true then
		GodWeaponFixLayer.setChangeLayerMark( GodWeaponFixLayer.kTagFormation )
	else
		-- 设置界面记忆
		GodWeaponFixLayer.setChangeLayerMark( GodWeaponFixLayer.kTagBag )
	end
end

--[[
	@des 	:加锁回调
--]]
function lockCallBack()
	local overCallBack = function(p_type)
		--加锁
		if p_type == kUnlockItem then
			_itemInfo.va_item_text.lock = kUnlockItem
			AnimationTip.showTip(GetLocalizeStringBy("zzh_1300"))
			_lockMenuItem:setVisible(true)
			_unLockMenuItem:setVisible(false)
		--解锁
		else
			_itemInfo.va_item_text.lock = kLockItem
			AnimationTip.showTip(GetLocalizeStringBy("zzh_1301"))
			_lockMenuItem:setVisible(false)
			_unLockMenuItem:setVisible(true)
		end
	end
	--尚未加锁，则可以加锁
	if tonumber(_itemInfo.va_item_text.lock) == kUnlockItem then
		GodWeaponService.unLock(_itemId,overCallBack)
	else
		GodWeaponService.lock(_itemId,overCallBack)
	end

end

--[[
	@des 	:属性回调
--]]
function attrCallBack()
	require "script/ui/common/DetailAttrLayer"
	DetailAttrLayer.showLayer(DetailAttrLayer.kGodTag,_touchPriority - 10,_zOrder + 10,_itemInfo,nil,_hid)
end

--[[
	@des 	:众多按钮回调
--]]
function menuCallBack(p_tag)
	if p_tag == kChange then
		removeLayer()
		local changeEquipLayer = ChangeEquipLayer.createLayer( nil,_hid,_itemPos,nil,nil,true)
		MainScene.changeLayer(changeEquipLayer,"changeEquipLayer")
	elseif p_tag == kWater then
		-- 处理 神兵强化材料
		if tonumber(_itemInfo.itemDesc.isgodexp) == 1 then
			AnimationTip.showTip(GetLocalizeStringBy("lic_1439"))
			return
		end

		require "script/ui/godweapon/GodWeaponEvolveLayer"
  		GodWeaponEvolveLayer.createLayer(_itemId)
  		--设置界面记忆
  		local paramTag = _isChange ~= true and GodWeaponEvolveLayer.kBagTag or GodWeaponEvolveLayer.kFormationTag
  		GodWeaponEvolveLayer.setChangeLayerMark(paramTag)
		removeLayer()
	elseif p_tag == kEnhance then
		require "script/ui/godweapon/GodWeaponReinforceLayer"
		GodWeaponReinforceLayer.showReinforceLayer(_itemId)
		-- 设置界面记忆
		local paramTag = _isChange ~= true and GodWeaponReinforceLayer.kTagBag or GodWeaponReinforceLayer.kTagFormation
		GodWeaponReinforceLayer.setChangeLayerMark(paramTag)
		removeLayer()
	elseif p_tag == kTakeDown then
		if(ItemUtil.isGodWeaponBagFull(true,removeLayer))then
			return
		end

		local removeCallBack = function()
			local lastFightValue = FightForceModel.dealParticularValues(_hid)

			HeroModel.removeGodWeaponFromHeroBy(_hid,_itemPos)
			FormationLayer.refreshGodWeaponAndBottom()

			local nowFightValue = FightForceModel.dealParticularValues(_hid)

			ItemUtil.showAttrChangeInfo(lastFightValue,nowFightValue)

			UnionProfitUtil.refreshUnionProfitInfo()

			removeLayer()
		end

		GodWeaponService.removeGodWeapon(_hid,_itemPos,removeCallBack)
	end
end

--[[
	@des 	:删除页面
--]]
function removeLayer()
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil

	-- 记忆神兵背包位置
	require "script/ui/bag/BagLayer"
	BagLayer.setMarkGodWeaponItemId(_itemId)

	if _delegate ~= nil then
		_delegate()
	end
end

--==================== ScrollView ====================

function createTipLabel(p_layer,p_y)
	-- if _DBInfo.godamyfriend ~= nil and _DBInfo.triggereffect ~= nil then
	-- 	local effectLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1245"),g_sFontName,21)
	-- 	effectLabel:setColor(ccc3(0xff,0xff,0xff))
	-- 	effectLabel:setAnchorPoint(ccp(0.5,0))
	-- 	effectLabel:setPosition(ccp(g_winSize.width*0.5,p_y))
	-- 	effectLabel:setScale(g_fScaleX)
	-- 	p_layer:addChild(effectLabel)

	-- 	p_y = addPosY(effectLabel,p_y)
	-- end

	local tipString
	local colorNum
	--如果是通用神兵
	if tonumber(_DBInfo.originalevolve) == 0 then
		tipString = GetLocalizeStringBy("zzh_1243")
		colorNum = 5
	elseif tonumber(_DBInfo.originalevolve) == 2 then
		tipString = GetLocalizeStringBy("zzh_1244")
		colorNum = 7
	end
	local tipLabel_1 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1241"),g_sFontName,21)
	tipLabel_1:setColor(ccc3(0xff,0xff,0xff))
	local tipLabel_2 = CCLabelTTF:create(tipString,g_sFontName,21)
	tipLabel_2:setColor(HeroPublicLua.getCCColorByStarLevel(colorNum))
	local tipLabel_3 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1242"),g_sFontName,21)
	tipLabel_3:setColor(ccc3(0xff,0xff,0xff))

	local tipLabel = BaseUI.createHorizontalNode({tipLabel_1,tipLabel_2,tipLabel_3})
	tipLabel:setAnchorPoint(ccp(0.5,0))
	tipLabel:setPosition(ccp(g_winSize.width*0.5,p_y))
	tipLabel:setScale(g_fScaleX)
	p_layer:addChild(tipLabel)

	p_y = addPosY(tipLabel,p_y)

	return p_y
end

--[[
	@des 	:创建简介
	@param 	: $p_bgSprite 		:要添加的layer
	@param 	: $p_y 				:纵坐标
	@return :高度
--]]
function createIntroduction(p_layer,p_y)
	--简介
	local introduceLabel = CCLabelTTF:create(_DBInfo.info,g_sFontName,22,CCSizeMake(510,0),kCCTextAlignmentCenter)
	introduceLabel:setColor(ccc3(0xff,0xff,0xff))
	introduceLabel:setAnchorPoint(ccp(0.5,0))
	introduceLabel:setPosition(ccp(g_winSize.width*0.5,p_y))
	introduceLabel:setScale(g_fScaleX)
	p_layer:addChild(introduceLabel)
	
	p_y = addPosY(introduceLabel,p_y)

	--标题
	local titleNode = createInfoTitle(kTypeTable[1]) 
	titleNode:setAnchorPoint(ccp(0.5,0))
	titleNode:setPosition(ccp(g_winSize.width*0.5,p_y))
	titleNode:setScale(g_fScaleX)
	p_layer:addChild(titleNode)

	p_y = addPosY(titleNode,p_y)

	return p_y
end

--[[
	@des 	:创建属性
	@param 	: $p_bgSprite 		:要添加的layer
	@param 	: $p_y 				:纵坐标
	@return :高度
--]]
function createAttribution(p_layer,p_y)
	local attrInfo = GodWeaponItemUtil.getWeaponAbility(nil,nil,_itemInfo)
	if table.isEmpty(attrInfo) then
		local noUnionLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1234"),g_sFontName,21)
		noUnionLabel:setAnchorPoint(ccp(0.5,0))
		noUnionLabel:setPosition(ccp(g_winSize.width*0.5,p_y))
		noUnionLabel:setScale(g_fScaleX)
		p_layer:addChild(noUnionLabel)

		p_y = addPosY(noUnionLabel,p_y)
	else

		--属性数量
		local attrNum = #attrInfo
		--显示条目数量
		local barNum = math.ceil(attrNum*0.5)
		p_y = 30*barNum*g_fScaleX + p_y
		local oriPosY = p_y - 30*g_fScaleX

		local posXTable = {g_winSize.width*0.63,g_winSize.width*0.18}
		local posYTable = {oriPosY,oriPosY - 30*g_fScaleX}

		for i = 1,attrNum do
			local nameLabel = CCLabelTTF:create(attrInfo[i].name .. "：",g_sFontPangWa,23)
			nameLabel:setColor(ccc3(0x00,0xff,0x18))
			local numLabel = CCLabelTTF:create("+" .. attrInfo[i].showNum,g_sFontName,21)
			numLabel:setColor(ccc3(0xff,0xff,0xff))

			local connectNode = BaseUI.createHorizontalNode({nameLabel,numLabel})
			connectNode:setAnchorPoint(ccp(0,0))
			connectNode:setPosition(ccp(posXTable[i%2 + 1],posYTable[math.ceil(i/2)]))
			connectNode:setScale(g_fScaleX)
			p_layer:addChild(connectNode)
		end
	end

	--标题
	local titleNode = createInfoTitle(kTypeTable[2]) 
	titleNode:setAnchorPoint(ccp(0.5,0))
	titleNode:setPosition(ccp(g_winSize.width*0.5,p_y))
	titleNode:setScale(g_fScaleX)
	p_layer:addChild(titleNode)

	p_y = addPosY(titleNode,p_y)

	return p_y
end

--[[
	@des 	:创建羁绊
	@param 	: $p_bgSprite 		:要添加的layer
	@param 	: $p_y 				:纵坐标
	@return :高度
--]]
function createCombination(p_layer,p_y)
	--如果武器没有羁绊
	if _DBInfo.godamyfriend == nil and _DBInfo.zhujue_union == nil then
		local noUnionLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1217"),g_sFontName,21)
		noUnionLabel:setAnchorPoint(ccp(0.5,0))
		noUnionLabel:setPosition(ccp(g_winSize.width*0.5,p_y))
		noUnionLabel:setScale(g_fScaleX)
		p_layer:addChild(noUnionLabel)

		p_y = addPosY(noUnionLabel,p_y)
	--有羁绊
	else
		local unionInfo = GodWeaponItemUtil.getGodWeaponUnionInfo(_DBInfo.id,_hid,_itemInfo,_otherHeroInfo)
		--unionInfo结构
		--[[ 	
				{
					[数组下标] =
								{
									dbInfo = {}, 		--db表中的信息
									isOpen = bool,		--是否开启
								}
				}
		--]]
		for i = #unionInfo,1,-1 do
			local desInfo = unionInfo[i].dbInfo
			--是否开启羁绊
			local unionOpen = unionInfo[i].isOpen
			local color_1
			local color_2

			if unionOpen then
				color_1 = ccc3(0x00,0xff,0x18)
				color_2 = ccc3(0x00,0xe4,0xff)
			else
				color_1 = ccc3(0x78,0x78,0x78)
				color_2 = ccc3(0x78,0x78,0x78)
			end

		  	local textInfo = {
		        width = 510, -- 宽度
		        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
		        elements =
		        {
		            {
		            	type = "CCLabelTTF",              							
		                text = desInfo.union_arribute_name .. "：",                     
		                font = g_sFontPangWa,
		                size = 23,
		                color = color_1,
		            },
		            {
		            	type = "CCLabelTTF",              							
		                text = desInfo.union_arribute_desc,                     
		                font = g_sFontName,
		                size = 21,
		                color = color_2,
		        	},
	        	}
			}

			local connectNode = LuaCCLabel.createRichLabel(textInfo)
			connectNode:setAnchorPoint(ccp(0.5,0))
			connectNode:setPosition(ccp(g_winSize.width*0.5,p_y))
			connectNode:setScale(g_fScaleX)
			p_layer:addChild(connectNode)

			p_y = addPosY(connectNode,p_y)
		end
	end

	--标题
	local titleNode = createInfoTitle(kTypeTable[3]) 
	titleNode:setAnchorPoint(ccp(0.5,0))
	titleNode:setPosition(ccp(g_winSize.width*0.5,p_y))
	titleNode:setScale(g_fScaleX)
	p_layer:addChild(titleNode)

	p_y = addPosY(titleNode,p_y)

	return p_y
end

--[[
	@des 	:创建洗练信息
	@param 	: $p_bgSprite 		:要添加的layer
	@param 	: $p_y 				:纵坐标
	@return :高度
--]]
function createWaterInfo(p_layer,p_y)
	--中文一到十
	local chineseNumTable = {"key_8107","key_8108","key_8109","key_8110","key_8111","key_8112","key_8113","key_8114","key_8115","key_8116"}
	--洗练图片table
	local iconTable = {"lv.png","lan.png","zi.png","cheng.png","hong.png"}
	--每个栏的颜色值信息
	local qualityInfo = GodWeaponFixData.getGodWeapinFixNeedQualityTab(nil,nil,_itemInfo)
	--洗练层数
	local atrrNum = GodWeaponFixData.getGodWeapinFixNum(nil,nil,_itemInfo)

	for i = atrrNum,1,-1 do
		--保存原始的p_y
		local paramPy = p_y

		local qualityNum = tonumber(qualityInfo[i])
		local isOpen = GodWeaponFixData.getGodWeapinFixIsOpneByFixNum(nil,nil,i,_itemInfo)

		--没有获得的物品没有这个字段
		local wateredArray = nil
		if _itemId ~= nil then
			wateredArray = _itemInfo.va_item_text.confirmed
		end
		--如果这一层有洗练信息
		if wateredArray ~= nil and wateredArray[tostring(i)] ~= nil then
			local waterInfo = GodWeaponFixData.getGodWeapinFixAttrInfoById(wateredArray[tostring(i)])

			local attrNumLabel = CCLabelTTF:create(waterInfo.dis,g_sFontName,23)
			attrNumLabel:setAnchorPoint(ccp(0.5,0))
			attrNumLabel:setPosition(ccp(g_winSize.width*0.5,p_y))
			attrNumLabel:setScale(g_fScaleX)
			p_layer:addChild(attrNumLabel)

			p_y = addPosY(attrNumLabel,p_y)

			local attrDesLabel = CCLabelTTF:create(waterInfo.name,g_sFontName,23)
			attrDesLabel:setAnchorPoint(ccp(0.5,0))
			attrDesLabel:setPosition(ccp(g_winSize.width*0.5,p_y))
			attrDesLabel:setScale(g_fScaleX)
			p_layer:addChild(attrDesLabel)

			local starNumLabel = CCLabelTTF:create(waterInfo.star,g_sFontName,23)
			local starSprite = CCSprite:create("images/formation/star.png")

			local connectNode = BaseUI.createHorizontalNode({starNumLabel,starSprite})
			connectNode:setAnchorPoint(ccp(0,0))
			connectNode:setPosition(ccp(g_winSize.width*0.5 + 180*g_fScaleX,p_y))
			connectNode:setScale(g_fScaleX)
			p_layer:addChild(connectNode)			

			p_y = addPosY(attrDesLabel,p_y)

			-- --如果开启了，显示颜色
			if isOpen then
				attrNumLabel:setColor(ccc3(0xff,0xff,0xff))
				attrDesLabel:setColor(GodWeaponFixData.getGodWeapinFixAttrColor(nil,i,wateredArray[tostring(i)],_itemInfo))
				starNumLabel:setColor(GodWeaponFixData.getGodWeapinFixAttrColor(nil,i,wateredArray[tostring(i)],_itemInfo))
			--如果没开启，置灰
			else
				attrNumLabel:setColor(ccc3(0x78,0x78,0x78))
				attrDesLabel:setColor(ccc3(0x78,0x78,0x78))
				starNumLabel:setColor(ccc3(0x78,0x78,0x78))
			end
		--如果没有洗练信息
		else
			if isOpen then
				local tipLabel
				--如果获得了该物品
				if _itemId ~= nil then
					tipLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1480"),g_sFontName,21)
				--没获得的
				else
					tipLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1275",GetLocalizeStringBy(chineseNumTable[i])),g_sFontName,21)
				end
				tipLabel:setColor(ccc3(0xff,0xff,0xff))
				tipLabel:setAnchorPoint(ccp(0.5,0))
				tipLabel:setPosition(ccp(g_winSize.width*0.5,p_y + 20*g_fScaleX))
				tipLabel:setScale(g_fScaleX)
				p_layer:addChild(tipLabel)

				p_y = addPosY(tipLabel,p_y,40)
			else
				--神兵进阶到什么品质开启
				local richInfo = {}
		        richInfo.defaultType = "CCLabelTTF"
		        richInfo.labelDefaultColor = ccc3(0xff,0xff,0xff)
		       	richInfo.labelDefaultSize = 21
		       	richInfo.labelDefaultFont = g_sFontName
		        richInfo.elements = {
		        	{
		        		text = HeroPublicLua.getCCColorDesByStarLevel(qualityNum) ,
		        		color = HeroPublicLua.getCCColorByStarLevel(qualityNum)
		        	}
		    	}
		    	local tipNode = GetLocalizeLabelSpriteBy_2("lic_1469",richInfo)
		    	tipNode:setAnchorPoint(ccp(0.5,0))
		    	tipNode:setPosition(ccp(g_winSize.width*0.5,p_y))
		    	tipNode:setScale(g_fScaleX)
		    	p_layer:addChild(tipNode)

		    	p_y = addPosY(tipNode,p_y)

		    	--提示文字
		    	local tipLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1468",GetLocalizeStringBy(chineseNumTable[i])),g_sFontName,21)
				tipLabel:setColor(ccc3(0x78,0x78,0x78))
				tipLabel:setAnchorPoint(ccp(0.5,0))
				tipLabel:setScale(g_fScaleX)
				tipLabel:setPosition(ccp(g_winSize.width*0.5,p_y))
				p_layer:addChild(tipLabel)

				p_y = addPosY(tipLabel,p_y)
			end
		end

		local iconSprite
		if isOpen then
			iconSprite = CCSprite:create("images/god_weapon/fix/" .. iconTable[i])
		else
			iconSprite = BTGraySprite:create("images/god_weapon/fix/" .. iconTable[i])
		end

		iconSprite:setAnchorPoint(ccp(0.5,0.5))
		iconSprite:setPosition(ccp(100*g_fScaleX,paramPy + (p_y - paramPy)*0.5))
		iconSprite:setScale(g_fScaleX)
		p_layer:addChild(iconSprite)

		local qualityColor = isOpen and HeroPublicLua.getCCColorByStarLevel(qualityNum) or ccc3(0x78,0x78,0x78)
		--标题
		local titleNode = createInfoTitle(GetLocalizeStringBy("lic_1456",GetLocalizeStringBy(chineseNumTable[i])),20,qualityColor) 
		titleNode:setAnchorPoint(ccp(0.5,0))
		titleNode:setPosition(ccp(g_winSize.width*0.5,p_y))
		titleNode:setScale(g_fScaleX)
		p_layer:addChild(titleNode)

		p_y = addPosY(titleNode,p_y)
	end

	return p_y
end

--[[
	@des 	:创建scrollView
	@param 	: $p_bgSprite 		:scrollView的背景图
	@param 	: $p_bgSize 		:背景图大小
--]]
function createInfoScrollView(p_bgSprite,p_bgSize)
	--scrollView高度
	local viewHeight = p_bgSize.height*0.89

	--scrollView
	local contentScrollView = CCScrollView:create()
	contentScrollView:setViewSize(CCSizeMake(p_bgSize.width,viewHeight))
	contentScrollView:setDirection(kCCScrollViewDirectionVertical)
	contentScrollView:setAnchorPoint(ccp(0,0))
	contentScrollView:setPosition(ccp(0,p_bgSize.height*0.05))
	contentScrollView:setTouchPriority(_touchPriority - 1)
	p_bgSprite:addChild(contentScrollView)

	--内部的layer
	local scrolLayer = CCLayer:create()
	contentScrollView:setContainer(scrolLayer)

	--layer高度
	local layerHeight = 5*g_fScaleX

	--创建简介
	layerHeight = createIntroduction(scrolLayer,layerHeight)
	--创建羁绊
	layerHeight = createCombination(scrolLayer,layerHeight)
	--不是经验神兵才有洗练信息
	if tonumber(_DBInfo.isgodexp) ~= 1 then
		layerHeight = createWaterInfo(scrolLayer,layerHeight)
	end

	--创建属性
	layerHeight = createAttribution(scrolLayer,layerHeight)

	--如果不是经验物品
	if tonumber(_DBInfo.isgodexp) == 0 then
		layerHeight = createTipLabel(scrolLayer,layerHeight)
	end

	scrolLayer:setContentSize(CCSizeMake(p_bgSize.width,layerHeight))
	scrolLayer:setPosition(ccp(0,viewHeight - layerHeight))
end

--==================== UI ====================

--[[
	@des 	:创建背景UI
--]]
function createBgUI()
	--主背景
	local bgSprite = CCSprite:create("images/god_weapon/info_bg.jpg")
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	bgSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bgSprite)

	--标题
	local titleSprite = CCSprite:create("images/god_weapon/weapon_info.png")
	titleSprite:setAnchorPoint(ccp(0,1))
	titleSprite:setPosition(ccp(g_winSize.width*0.02,g_winSize.height*0.98))
	titleSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(titleSprite)
end

--[[
	@des 	:创建物品图像UI
--]]
function createWeaponUI()
	--星星和名字的位置
	local starPosY = g_winSize.height*0.98
	local namePosY = g_winSize.height*0.43
	--神兵位置
	local itemPosY = (starPosY - namePosY)*0.5 + namePosY

	--神兵图
	local godArmSprite = GodWeaponItemUtil.getWeaponBigSprite(nil,nil,_hid,_itemInfo,nil,true)
	godArmSprite:setAnchorPoint(ccp(0.5,0))
	godArmSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	godArmSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(godArmSprite)

	--星星底
	local starBgSprite = CCSprite:create("images/recharge/transfer/star_bg.png")
	starBgSprite:setAnchorPoint(ccp(0.5,1))
	starBgSprite:setPosition(ccp(g_winSize.width*0.5,starPosY))
	starBgSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(starBgSprite)

	--星星
	--星星数
	local starNum = tonumber(_quality)
	--位置table
	local posXTable = (starNum%2 == 0) and {112.5,140.5,87.5,165.5,62.5,190.5} or {128,103,153,78,178,53,203}
	local posY = starBgSprite:getContentSize().height - 10

	for i = 1,starNum do
		local starSprite = CCSprite:create("images/formation/star.png")
		starSprite:setAnchorPoint(ccp(0.5,1))
		starSprite:setPosition(ccp(posXTable[i],posY))
		starBgSprite:addChild(starSprite)
	end

	local itemLevel,curExp,needExp,isMax = GodWeaponItemUtil.getLvAndExp(nil,nil,_itemInfo)

	--名称底
	local lvSprite = CCSprite:create("images/common/lv.png")
	local lvLabel = CCRenderLabel:create(itemLevel,g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_shadow)
	lvLabel:setColor(ccc3(0xff,0xf6,0x00))
	local nameBgSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	nameBgSprite:setContentSize(CCSizeMake(215,45))
	-- nameBgSprite:setAnchorPoint(ccp(0.5,0))
	-- nameBgSprite:setPosition(ccp(g_winSize.width*0.5,namePosY))
	-- nameBgSprite:setScale(g_fElementScaleRatio)
	-- _bgLayer:addChild(nameBgSprite)

	local superConnect = BaseUI.createHorizontalNode({lvSprite,lvLabel,nameBgSprite})
	superConnect:setAnchorPoint(ccp(0.5,0))
	superConnect:setPosition(ccp(g_winSize.width*0.5,namePosY))
	superConnect:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(superConnect)

	local bgSize = nameBgSprite:getContentSize()

	--名字
	local nameLabel = CCLabelTTF:create(_DBInfo.name,g_sFontPangWa,25)
	nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(_quality))
	local plusLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1224",_showEvolveNum),g_sFontPangWa,25)
	plusLabel:setColor(HeroPublicLua.getCCColorByStarLevel(_quality))
	local connectNode = BaseUI.createHorizontalNode({nameLabel,plusLabel})
	connectNode:setAnchorPoint(ccp(0.5,0.5))
	connectNode:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.5))
	nameBgSprite:addChild(connectNode)

	--五行图片
	local fiveSprite = CCSprite:create("images/god_weapon/five/" .. _DBInfo.type .. ".png")
	fiveSprite:setAnchorPoint(ccp(0.5,0))
	fiveSprite:setPosition(ccp(g_winSize.width*0.31,g_winSize.height*0.53))
	fiveSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(fiveSprite)
end

--[[
	@des 	:创建物品信息UI
--]]
function createInfoUI()
	--scrollView背景图
	local scrollViewBgSprite = CCScale9Sprite:create(CCRectMake(84,10,12,8),"images/god_weapon/view_bg_2.png")
	scrollViewBgSprite:setContentSize(CCSizeMake(g_winSize.width,g_winSize.height*0.32))
	scrollViewBgSprite:setAnchorPoint(ccp(0.5,0))
	scrollViewBgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.09))
	_bgLayer:addChild(scrollViewBgSprite)

	local viewBgSize = scrollViewBgSprite:getContentSize()

	--花边
	local buttomSprite = CCSprite:create("images/god_weapon/buttom_flower.png")
	buttomSprite:setAnchorPoint(ccp(0.5,0))
	buttomSprite:setPosition(ccp(viewBgSize.width*0.5,0))
	buttomSprite:setScale(g_fScaleX)
	scrollViewBgSprite:addChild(buttomSprite)

	local xOffset = 10*g_fScaleX

	--左青龙
	local leftFlowerSprite = CCSprite:create("images/god_weapon/flower.png")
	leftFlowerSprite:setAnchorPoint(ccp(0,0.5))
	leftFlowerSprite:setPosition(ccp(-xOffset,viewBgSize.height))
	leftFlowerSprite:setScale(g_fScaleX)
	scrollViewBgSprite:addChild(leftFlowerSprite)

	--右白虎
	local rightFlowerSprite = CCSprite:create("images/god_weapon/flower.png")
	rightFlowerSprite:setScaleX(-g_fScaleX)
	rightFlowerSprite:setScaleY(g_fScaleX)
	rightFlowerSprite:setAnchorPoint(ccp(0,0.5))
	rightFlowerSprite:setPosition(ccp(viewBgSize.width + xOffset,viewBgSize.height))
	scrollViewBgSprite:addChild(rightFlowerSprite)


	--标题
	local titleSprite = CCSprite:create("images/god_weapon/view_info.png")
	titleSprite:setAnchorPoint(ccp(0.5,0.5))
	titleSprite:setPosition(ccp(viewBgSize.width*0.5,viewBgSize.height))
	titleSprite:setScale(g_fElementScaleRatio)
	scrollViewBgSprite:addChild(titleSprite)

	--创建scrollView
	createInfoScrollView(scrollViewBgSprite,viewBgSize)
end

--[[
	@des 	:创建按钮相关UI
--]]
function createMenuUI()
	--背景menu
	_bgMenu = CCMenu:create()
	_bgMenu:setAnchorPoint(ccp(0,0))
	_bgMenu:setPosition(ccp(0,0))
	_bgMenu:setTouchPriority(_touchPriority - 1)
	_bgLayer:addChild(_bgMenu)

	--返回按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(1,1))
	closeMenuItem:setPosition(ccp(g_winSize.width*0.98,g_winSize.height*0.99))
	closeMenuItem:setScale(g_fElementScaleRatio)
	closeMenuItem:registerScriptTapHandler(closeCallBack)
	_bgMenu:addChild(closeMenuItem)

	--类型0，只有一个返回按钮
	if _menuType == kMenuTypeZero then
		createReturnMenu()
	elseif _menuType == kMenuTypeOne then
		createChangeMenu()
		createTakeDownMenu()
		createWaterMenu()
		createEnhanceMenu()
	elseif _menuType == kMenuTypeTwo then
		createChangeMenu()
		createTakeDownMenu()
		createEnhanceMenu()
	elseif _menuType == kMenuTypeThree then
		createWaterMenu()
		createEnhanceMenu()
	elseif _menuType == kMenuTypeFour then
		createEnhanceMenu()
	end

	--已经获得的物品，且不是经验神兵可以有洗练按钮
	--因为牵扯到查看对方阵容的问题，所以用是不是只有一个按钮来判断是否已经获得
	if _menuType ~= kMenuTypeZero and tonumber(_itemInfo.itemDesc.isgodexp) ~= 1 then
		local waterMenuItem = CCMenuItemImage:create("images/god_weapon/xi_n.png","images/god_weapon/xi_h.png")
		waterMenuItem:setAnchorPoint(ccp(0.5,0.5))
		waterMenuItem:setPosition(ccp(g_winSize.width*0.85,g_winSize.height*0.58))
		waterMenuItem:setScale(g_fElementScaleRatio * 1.1)
		waterMenuItem:registerScriptTapHandler(waterCallBack)
		_bgMenu:addChild(waterMenuItem)
	end

	--详细属性
	if _menuType ~= kMenuTypeZero and tonumber(_itemInfo.itemDesc.isgodexp) ~= 1 then
		local attrMenuItem = CCMenuItemImage:create("images/god_weapon/detail_n.png","images/god_weapon/detail_h.png")
		attrMenuItem:setAnchorPoint(ccp(0.5,0.5))
		attrMenuItem:setPosition(ccp(g_winSize.width*0.85,g_winSize.height*0.48))
		attrMenuItem:setScale(g_fElementScaleRatio)
		attrMenuItem:registerScriptTapHandler(attrCallBack)
		_bgMenu:addChild(attrMenuItem)
	end

	local lockVisible
	if _itemInfo.va_item_text ~= nil and tonumber(_itemInfo.va_item_text.lock) == kUnlockItem then
		lockVisible = true
	else
		lockVisible = false
	end

	--加锁
	if _menuType ~= kMenuTypeZero and tonumber(_itemInfo.itemDesc.isgodexp) ~= 1 then
		_lockMenuItem = CCMenuItemImage:create("images/god_weapon/lock/" .. kUnlockItem .. "_n.png","images/god_weapon/lock/" .. kUnlockItem .. "_h.png")
		_lockMenuItem:setAnchorPoint(ccp(0.5,0.5))
		_lockMenuItem:setPosition(ccp(g_winSize.width*0.85,g_winSize.height*0.68))
		_lockMenuItem:setScale(g_fElementScaleRatio)
		_lockMenuItem:setVisible(lockVisible)
		_lockMenuItem:registerScriptTapHandler(lockCallBack)
		_bgMenu:addChild(_lockMenuItem)

		_unLockMenuItem = CCMenuItemImage:create("images/god_weapon/lock/" .. kLockItem .. "_n.png","images/god_weapon/lock/" .. kLockItem .. "_h.png")
		_unLockMenuItem:setAnchorPoint(ccp(0.5,0.5))
		_unLockMenuItem:setPosition(ccp(g_winSize.width*0.85,g_winSize.height*0.68))
		_unLockMenuItem:setScale(g_fElementScaleRatio)
		_unLockMenuItem:setVisible(not lockVisible)
		_unLockMenuItem:registerScriptTapHandler(lockCallBack)
		_bgMenu:addChild(_unLockMenuItem)		
	end
end

--[[
	@des 	:创建UI
--]]
function createUI()
	--创建背景UI
	createBgUI()
	--创建神兵UI
	createWeaponUI()
	--创建神兵信息UI
	createInfoUI()
	--创建按钮UI
	createMenuUI()
end

-- 显示上一次显示的界面
function showLastLayer( ... )
	if lastShowParameters ~= nil then
		showLayer(unpack(lastShowParameters))
	end
end
--==================== Entrance ====================

--[[
	@des 	:入口函数
	@param 	: $p_itemTid 			: 神兵模板id
	@param 	: $p_itemId 			: 神兵itemid
									  p_itemId和p_itemTid至少要有1个
									  有p_itemId的情况下不考虑p_itemTid
	@param  : $p_isEnhance 			: 是否显示强化按钮
	@param  : $p_isWater 			: 是否显示进化按钮
	@param  : $p_isChange 			: 是否显示更换按钮
	@param  : $p_hid 				: 武将hid
	@param  : $p_pos_index 			: 武将装备在身上的位置id
	@param 	: $p_touchPriority 		: 触摸优先级，默认为-550
	@param 	: $p_zOrder 			: Z轴，默认为999
	@param  : $p_otherFormationInfo : 阵容中其他人的信息，在查看对方阵容中用
	@param  : $p_otherHeroInfo 		: 查看对方阵容的时候，那个英雄的信息
	@param  : $p_delegate  			: 关闭界面后的回调
--]]
function showLayer(p_itemTid,p_itemId,p_isEnhance,p_isWater,p_isChange,p_hid,p_pos_index,p_touchPriority,p_zOrder,p_otherFormationInfo,p_otherHeroInfo,p_delegate)
	lastShowParameters = {p_itemTid,p_itemId,p_isEnhance,p_isWater,p_isChange,p_hid,p_pos_index,p_touchPriority,p_zOrder,p_otherFormationInfo,p_otherHeroInfo,p_delegate}
	init()

	_delegate = p_delegate

	--对查看对方阵容的特殊处理
	if p_otherFormationInfo ~= nil then
		_itemInfo = p_otherFormationInfo
		_itemInfo.itemDesc = ItemUtil.getItemById(tonumber(_itemInfo.item_template_id))
		--itemId
		_itemId = tonumber(_itemInfo.item_id)
	--正常处理
	else
		--得到物品信息
		_itemInfo = GodWeaponItemUtil.getGodWeaponInfo(p_itemTid,p_itemId)
		--itemId
		_itemId = p_itemId
	end

	--查看对方阵容的时候，对方那个人的信息，用于判断对方神兵羁绊是否开启
	if p_otherHeroInfo ~= nil then
		_otherHeroInfo = p_otherHeroInfo
		_otherHeroInfo.localInfo = DB_Heroes.getDataById(p_otherHeroInfo.htid)
	end

	--物品的db信息
	_DBInfo = _itemInfo.itemDesc
	--得到品质，进化次数，显示的进化次数
	_quality,_evolveNum,_showEvolveNum = GodWeaponItemUtil.getGodWeaponQualityAndEvolveNum(nil,nil,_itemInfo)
	--武将hid
	_hid = p_hid
	--是否按钮显示
	_isEnhance = p_isEnhance
	_isWater = p_isWater
	--_isWater = true
	_isChange = p_isChange
	--物品位置
	_itemPos = p_pos_index
	--触摸优先级和Z轴
	_touchPriority = p_touchPriority or -700
	_zOrder = p_zOrder or 1500

	--判断按钮显示类型
	decideMenuType()

	-- 叠加神兵特殊处理
	if(_itemInfo.item_num and tonumber(_itemInfo.item_num) > 1 )then
		_menuType 		= kMenuTypeZero 
	end

	--创建背景屏蔽层
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)

    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder)

    --创建UI
    createUI()
end

--==================== Tools ====================

--[[
	@des 	:创建两个分割线中间标题的node
	@param 	:标题string
	@param 	:标题字体大小
	@param 	:标题颜色
	@return :node
--]]
function createInfoTitle(p_string,p_size,p_color)
	local frontSize = p_size or 24
	local frontColor = p_color or ccc3(0xff,0xf6,0x00)

	--左分隔符
	local leftSprite = CCSprite:create("images/god_weapon/cut_line.png")
	leftSprite:setAnchorPoint(ccp(0,0.5))
	--右分隔符
	local rightSprite = CCSprite:create("images/god_weapon/cut_line.png")
	rightSprite:setScaleX(-1)
	rightSprite:setAnchorPoint(ccp(0,0.5))
	--名称
	local nameLabel = CCLabelTTF:create(p_string,g_sFontPangWa,frontSize)
	nameLabel:setColor(frontColor)
	nameLabel:setAnchorPoint(ccp(0.5,0.5))

	local nodeContentSize = CCSizeMake(leftSprite:getContentSize().width*2 + 115,nameLabel:getContentSize().height)

	--底层node
	local bgNode = CCNode:create()
	bgNode:setContentSize(nodeContentSize)

	local yPos = nodeContentSize.height*0.5
	
	leftSprite:setPosition(ccp(0,yPos))
	nameLabel:setPosition(ccp(nodeContentSize.width*0.5,yPos))
	rightSprite:setPosition(ccp(nodeContentSize.width,yPos))

	bgNode:addChild(leftSprite)
	bgNode:addChild(rightSprite)
	bgNode:addChild(nameLabel)

	return bgNode
end

--[[
	@des 	:增加y坐标的值
	@param 	: $p_node 		:新增加的node
	@param 	: $p_y 			:y坐标
	@param 	: $p_ex 		:额外高度，默认为5
	@param 	:y坐标
	@return :增加后的y坐标
--]]
function addPosY(p_node,p_y,p_ex)
	local exHeight = p_ex or 5
	return (exHeight + p_node:getContentSize().height)*g_fScaleX + p_y
end

--[[
	@des 	:决定按钮显示类型，默认为只显示返回按钮 
--]]
function decideMenuType()
	if _hid ~= nil then
		--如果穿在人身上，且在阵容中调用，则显示更换，卸下，进化、强化
		if _isChange == true then
			_menuType = kMenuTypeOne
		--否则为背包中调用，显示，进化，强化
		else
			_menuType = kMenuTypeThree
		end
	--人没穿，且可以强化，则显示进化，强化
	elseif _isEnhance == true then
		--如果没有穿在身上，且开启了强化，则显示强化、进化
		_menuType = kMenuTypeThree
	end
end

--[[
	@des 	:创建返回按钮
--]]
function createReturnMenu()
	local returnBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,75),GetLocalizeStringBy("key_2661"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
	returnBtn:setAnchorPoint(ccp(0.5,0))
	returnBtn:setPosition(ccp(g_winSize.width*0.5,10*g_fElementScaleRatio))
	returnBtn:registerScriptTapHandler(closeCallBack)
	returnBtn:setScale(g_fElementScaleRatio)
	_bgMenu:addChild(returnBtn)
end

--[[
	@des 	:创建更换按钮
--]]
function createChangeMenu()
	local changeBtn
	if _menuType == kMenuTypeOne then
		changeBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(155,75),GetLocalizeStringBy("key_1543"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
	elseif _menuType == kMenuTypeTwo then
		changeBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,75),GetLocalizeStringBy("key_1543"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
	end
	changeBtn:setAnchorPoint(ccp(0,0))
	changeBtn:setPosition(ccp(5*g_fElementScaleRatio,10*g_fElementScaleRatio))
	changeBtn:registerScriptTapHandler(menuCallBack)
	changeBtn:setScale(g_fElementScaleRatio)
	_bgMenu:addChild(changeBtn,1,kChange)
end

--[[
	@des 	:创建洗练按钮
--]]
function createWaterMenu()
	local waterBtn
	if _menuType == kMenuTypeOne then
		waterBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(155,75),GetLocalizeStringBy("lic_1423"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
		waterBtn:setAnchorPoint(ccp(0.5,0))
		waterBtn:setPosition(ccp(g_winSize.width*0.5 + 80*g_fElementScaleRatio,10*g_fElementScaleRatio))
	elseif _menuType == kMenuTypeThree then
		waterBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,75),GetLocalizeStringBy("lic_1423"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
		waterBtn:setAnchorPoint(ccp(0,0))
		waterBtn:setPosition(ccp(g_winSize.width*0.09,10*g_fElementScaleRatio))
	end
	waterBtn:registerScriptTapHandler(menuCallBack)
	waterBtn:setScale(g_fElementScaleRatio)
	_bgMenu:addChild(waterBtn,1,kWater)
end

--[[
	@des 	:创建卸下按钮
--]]
function createTakeDownMenu()
	local takeDownBtn
	if _menuType == kMenuTypeOne then
		takeDownBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(155,75),GetLocalizeStringBy("zzh_1235"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
		takeDownBtn:setAnchorPoint(ccp(0.5,0))
		takeDownBtn:setPosition(ccp(g_winSize.width*0.5 - 80*g_fElementScaleRatio,10*g_fElementScaleRatio))
	elseif _menuType == kMenuTypeTwo then
		takeDownBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,75),GetLocalizeStringBy("zzh_1235"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
		takeDownBtn:setAnchorPoint(ccp(0.5,0))
		takeDownBtn:setPosition(ccp(g_winSize.width*0.5,10*g_fElementScaleRatio))
	end
	takeDownBtn:registerScriptTapHandler(menuCallBack)
	takeDownBtn:setScale(g_fElementScaleRatio)
	_bgMenu:addChild(takeDownBtn,1,kTakeDown)
end

--[[
	@des 	:创建强化按钮
--]]
function createEnhanceMenu()
	local enhanceBtn
	if _menuType == kMenuTypeOne then
		enhanceBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(155,75),GetLocalizeStringBy("key_3391"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
	else
		enhanceBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(200,75),GetLocalizeStringBy("key_3391"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
	end
	enhanceBtn:registerScriptTapHandler(menuCallBack)
	enhanceBtn:setScale(g_fElementScaleRatio)
	_bgMenu:addChild(enhanceBtn,1,kEnhance)

	if _menuType == kMenuTypeOne or _menuType == kMenuTypeTwo then
		enhanceBtn:setAnchorPoint(ccp(1,0))
		enhanceBtn:setPosition(ccp(g_winSize.width - 5*g_fElementScaleRatio,10*g_fElementScaleRatio))
	elseif _menuType == kMenuTypeThree then
		enhanceBtn:setAnchorPoint(ccp(1,0))
		enhanceBtn:setPosition(ccp(g_winSize.width*0.91,10*g_fElementScaleRatio))
	elseif _menuType == kMenuTypeFour then
		enhanceBtn:setAnchorPoint(ccp(0.5,0))
		enhanceBtn:setPosition(ccp(g_winSize.width*0.5,10*g_fElementScaleRatio))
	end
end