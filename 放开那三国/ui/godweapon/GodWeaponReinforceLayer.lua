-- FileName: GodWeaponReinforceLayer.lua 
-- Author: licong 
-- Date: 14-12-15 
-- Purpose: 神兵强化界面


module("GodWeaponReinforceLayer", package.seeall)

require "script/utils/LevelUpUtil"
require "script/utils/BaseUI"
require "script/ui/item/GodWeaponItemUtil"
require "script/ui/item/ItemUtil"
require "script/ui/item/ItemSprite"
require "script/ui/godweapon/GodWeaponData"
require "script/ui/godweapon/GodWeaponService"


local _bgLayer 							= nil
local _bgSprite 						= nil
local _menuBar 							= nil -- Menu
local _costNumFont 						= nil -- 消耗的银币数量label
local _addMenuItemTab 					= {}  -- 五个加号按钮
local _addProgressGreenBar				= nil -- 绿色增长经验条
local _addExpNumFont 					= nil -- 增加的经验值label
local _bgProress 						= nil -- 经验条背景
local _godWeaponBodySprite 				= nil -- 神兵全身像
local _bottomBg 						= nil -- 底部背景
local _materialItemtab 					= {}  -- 材料按钮table
local _expNode 							= nil -- 经验条
local _maskLayer						= nil -- 特效屏蔽层


local _showItemId 						= nil -- 强化的物品itemid
local _showItemInfo 					= nil -- 强化物品的信息
local _quality 							= nil -- 神兵品质
local _evolveNum 						= nil -- 神兵进阶次数
local _evolveShowNum 					= nil -- 神兵进阶显示阶数
local _isOnHero 						= nil -- 神兵是否装备在英雄上
local _hid 								= nil -- 装备神兵的hid
local _curLv 							= nil -- 神兵当前等级
local _curExp 							= nil -- 神兵当前经验
local _curMaxLv 						= nil -- 神兵最大等级
local _nextNeedExp 						= nil -- 神兵下级需要经验
local _curCost 							= nil -- 当前强化费用
local _curAddExp 						= nil -- 当前增加的经验值
local _oldSelectList 					= {}  -- 旧的选择列表
local _newSelectList 					= {}  -- 新的选择列表
local _newCurLv 						= nil -- 强化后的等级
local _newScale 						= 1   -- 法阵缩放大小

local _showMark 						= nil -- 界面跳转tag

local _maxChooseNum 					= nil -- 最大选择数量

------------------------------ 常量 -----------------------------------
-- 五个材料位置
local _addPosX1 = {0.20,0.18,0.5,0.84,0.83}
local _addPosY1 = {0.55,0.42,0.33,0.42,0.54}

local _addPosX2 = {0.2,0.15,0.16,0.24,0.41,0.62,0.8,0.85,0.87,0.83}
local _addPosY2 = {0.56,0.5,0.43,0.37,0.33,0.33,0.37,0.43,0.5,0.56}

local _tagAddSp   		= 1010 -- 材料加号的tag
local _tagMaterial 		= 1011 -- 材料icon的tag
local _tagMaterialName 	= 1012 -- 材料名字

-- 页面跳转tag
kTagBag 				= 100
kTagFormation 			= 101

-- 界面优先级
local _layer_priority 	= -500

------------------------------------------------------------ 初始化 -------------------------------------------------------------------------------------
--[[
	@des 	:初始化
	@param 	:
	@return :
--]]
function init()
	_bgLayer 							= nil
	_bgSprite 							= nil
	_menuBar 							= nil
	_costNumFont 						= nil
	_addMenuItemTab 					= {} 
	_addProgressGreenBar				= nil 
	_addExpNumFont 						= nil 
	_bgProress 							= nil
	_godWeaponBodySprite 				= nil
	_bottomBg 							= nil
	_materialItemtab 					= {} 
	_expNode 							= nil
	_maskLayer							= nil

	_showItemId 						= nil
	_showItemInfo 						= nil 
	_quality 							= nil
	_evolveNum 							= nil
	_evolveShowNum 						= nil
	_isOnHero 							= nil
	_hid 								= nil
	_curLv 								= nil
	_curExp 							= nil
	_curMaxLv 							= nil
	_nextNeedExp 						= nil
	_curCost 							= nil
	_curAddExp 							= nil
	_oldSelectList 						= {} 
	_newSelectList 						= {}
	_newCurLv 							= nil
	_maxChooseNum 						= nil 
	_newScale 							= 1

end

--[[
	@des 	:初始化数据
	@param 	:
	@return :
--]]
function initReinforceData()
	-- 神兵是否在武将上
	_isOnHero = false
	-- 强化神兵的信息
	_showItemInfo = ItemUtil.getItemByItemId(_showItemId)
	if(_showItemInfo == nil)then
		_showItemInfo = ItemUtil.getGodWeaponInfoFromHeroByItemId(_showItemId)
		-- 神兵是装备上的
		_isOnHero = true
		-- 装备神兵的hid
		_hid = _showItemInfo.hid
	end
	-- 强化神兵的品质,进阶次数，显示阶数
	_quality,_evolveNum,_evolveShowNum = GodWeaponItemUtil.getGodWeaponQualityAndEvolveNum(nil,nil,_showItemInfo)
	
	-- 神兵当前等级
	_curLv = tonumber(_showItemInfo.va_item_text.reinForceLevel)
	-- 神兵当前经验
	_curExp = tonumber(_showItemInfo.va_item_text.reinForceExp)
	-- 当前强化的最大等级
	_curMaxLv = GodWeaponData.getCurMaxLv(nil,_showItemInfo)
	-- 下级需要的经验
	_nextNeedExp = LevelUpUtil.getNeedExpByIdAndLv(_showItemInfo.itemDesc.enhanceexpID, _curLv+1) or 0
	-- 强化需要费用
	_curCost = 0
	-- 当前增加的经验值
	_curAddExp = 0

	-- 最大选择数量
	local needLv = GodWeaponData.getReinforceTenNeedLv()
	if( UserModel.getHeroLevel() >= needLv )then
		_maxChooseNum = 10
		_addPosX = _addPosX2
		_addPosY = _addPosY2
		_newScale = 0.8
	else
		_maxChooseNum = 5
		_addPosX = _addPosX1
		_addPosY = _addPosY1
		_newScale = 1
	end
	-- 清空上次选择材料的列表
	GodWeaponData.cleanMaterialSelectList()
	-- 清空上次选择列表储存
	_oldSelectList = {}
end

---------------------------------------------------------------- 界面跳转记忆 --------------------------------------------------------------------
--[[
	@des 	:设置页面跳转记忆
	@param 	:p_mark:页面跳转mark
	@return :
--]]
function setChangeLayerMark( p_mark )
  	_showMark = p_mark
end

--[[
	@des 	:页面跳转记忆
	@param 	:
	@return :
--]]
function changeLayerMark()
  	if(_showMark == kTagBag)then
  		-- 背包
  		require "script/ui/bag/BagLayer"
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_GodWeapon)
		MainScene.changeLayer(bagLayer, "bagLayer")
  	elseif(_showMark == kTagFormation)then
  		-- 阵容
  		require("script/ui/formation/FormationLayer")
        local formationLayer = FormationLayer.createLayer(_hid, false, false, nil, 3)
        MainScene.changeLayer(formationLayer, "formationLayer")
        GodWeaponInfoLayer.showLastLayer()
  	else
  		-- 背包
  		require "script/ui/bag/BagLayer"
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_GodWeapon)
		MainScene.changeLayer(bagLayer, "bagLayer")
  	end
end

---------------------------------------------------------------- 按钮事件 -------------------------------------------------------------------

--[[
	@des 	:回调onEnter和onExit事件
	@param 	:
	@return :
--]]
function onNodeEvent( event )
	if (event == "enter") then
		
	elseif (event == "exit") then
		init()
	end
end

--[[
	@des 	:返回按钮回调
	@param 	:
	@return :
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

	-- 跳转界面
	changeLayerMark()
end

--[[
	@des 	:进阶按钮回调
	@param 	:
	@return :
--]]
function evolveBtnCallBack( tag, sender )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- 处理 神兵强化材料
	if( _showItemInfo ~= nil and tonumber(_showItemInfo.itemDesc.isgodexp) == 1 )then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1439"))
		return
	end

	-- 已进阶至最高等级
	local isMax = GodWeaponItemUtil.isMaxEvolveLv( _showItemInfo.item_template_id, _evolveNum )
	if(isMax == true)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1452"))
		return
	end

	-- 强化至%d级可以进阶
	if( _curLv < _curMaxLv )then 
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1421",_curMaxLv))
		return
	end

	-- 进阶界面
	require "script/ui/godweapon/GodWeaponEvolveLayer"
  	GodWeaponEvolveLayer.createLayer(_showItemId)

  	-- 记忆跳转
  	local backTag = nil
  	if(_showMark == kTagBag)then
  		-- 背包
  		backTag = GodWeaponEvolveLayer.kBagTag
  	elseif(_showMark == kTagFormation)then
  		-- 阵容
  		backTag = GodWeaponEvolveLayer.kFormationTag
  	else
  		-- 背包
  		backTag = GodWeaponEvolveLayer.kBagTag
  	end
  	GodWeaponEvolveLayer.setChangeLayerMark(backTag)
end

--[[
	@des 	:强化按钮回调
	@param 	:
	@return :
--]]
function enhanceBtnCallBack( tag, sender )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

   	-- 等级上限判断
   	if(_curLv >= _curMaxLv)then 
   		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1432"))
		return
   	end
   	-- 强化费用不足
   	if( UserModel.getSilverNumber() < _curCost ) then 
   		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("lic_1433"))
        return
    end

    -- 选择的材料列表
    local selectList = GodWeaponData.getMaterialSelectList()
    if( table.isEmpty(selectList) )then
    	require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("lic_1434"))
        return
    end

    -- 请求回调
    local nextFunction = function ( retData )
    	if(_isOnHero == true)then 
    		-- 修改英雄身上的数据
    		HeroModel.changeHeroGodWeaponReinforceBy(_hid,_showItemId, retData.reinForceLevel, retData.reinForceExp, retData.reinForceCost )
	    else
	    	-- 修改背包数据
	    	DataCache.changeGodWeaponLvAndExpInBag( _showItemId, retData.reinForceLevel, retData.reinForceExp, retData.reinForceCost )
	    end
        -- 扣除花费
        UserModel.addSilverNumber(-tonumber(retData.reinForceCost))

        -- 保存新的等级
        _newCurLv = tonumber(retData.reinForceLevel)

        -- 播放特效
    	materialEffect()
    end

    -- 添加特效屏蔽层
    if(_maskLayer ~= nil)then
		_maskLayer:removeFromParentAndCleanup(true)
		_maskLayer = nil
	end
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	_maskLayer = BaseUI.createMaskLayer(-5000,nil,nil,0)
	runningScene:addChild(_maskLayer, 10000)

    -- 发请求
    local itemIds = {}
    local itemNums = {}
    for k,v in pairs(selectList) do
    	print("vvvvv")
    	print_t(v)
    	table.insert(itemIds,v.item_id)
    	table.insert(itemNums,v.num)
    end
	GodWeaponService.reinForce(_showItemId, itemIds, itemNums, nextFunction)
end

--[[
	@des 	:自动添加按钮回调
	@param 	:
	@return :
--]]
function automaticAddBtnCallBack( tag, sender )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    local selectData = GodWeaponData.getMaterialForGodWeapon( _showItemId )
    if( table.isEmpty(selectData) )then
    	require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("lic_1435"))
        return
    end
    -- 清空选择列表
    GodWeaponData.cleanMaterialSelectList()

    -- 添加5个材料
    for i=1,_maxChooseNum do
    	if( not table.isEmpty(selectData[i]) )then
    		local num = 1
    		if( tonumber(selectData[i].itemDesc.maxStacking) > 1 )then
    			if( tonumber(selectData[i].item_num) >= _maxChooseNum)then
    				num = _maxChooseNum
    			else
    				num = tonumber(selectData[i].item_num)
    			end
			else
				num = 1
			end
    		GodWeaponData.addMaterialToSelectList(selectData[i].item_id,num)
    	end
    end

    -- 刷材料
    refreshMaterialUi()
end

--[[
	@des 	: 加号按钮回调
	@param 	:
	@return :
--]]
function addMenuItemCallBack( tag, sender )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    -- 该位置是否已经添加了材料
    if( tolua.cast(sender:getChildByTag(_tagMaterial),"CCSprite") ~= nil )then 
		-- 该位置已添加材料 点击图标则移除材料
		GodWeaponData.removeMaterialInSelectList(_oldSelectList[tostring(tag)].item_id)

		-- 刷新材料
		sender:stopAllActions()
		sender:setPosition(0,70)
		-- 刷新
		refreshMaterialUi()
		return
	end

    -- 显示选择列表
    require "script/ui/godweapon/GodWeaponSelectLayer"
    GodWeaponSelectLayer.showSelectLayer( _showItemId, refreshMaterialUi, _layer_priority-10, nil, _maxChooseNum )
end

---------------------------------------------------------------- 创建ui --------------------------------------------------------------------
--[[
	@des 	:强化提示等级
	@param 	:
	@return :
--]]
function upgradeEffect()
	-- 神兵上强化特效
    -- 提升的等级
    local addLv = _newCurLv - _curLv
	local upgradeAnimSprite = CCLayerSprite:layerSpriteWithNameAndCount("images/base/effect/item/qianghuachenggong", 1, CCString:create(""))
    upgradeAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
    upgradeAnimSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5,_bgSprite:getContentSize().height*0.7))
    _bgSprite:addChild(upgradeAnimSprite,30)
    -- 替换关键帧
    if(addLv >= 1) then
		local addSprite = CCSprite:create("images/common/upgrade.png")
		addSprite:setAnchorPoint(ccp(0.5, 0.5))
		-- 等级
		local levelLabel = CCRenderLabel:create(addLv, g_sFontPangWa, 70, 1, ccc3(0, 0, 0), type_stroke)
		levelLabel:setColor(ccc3(255, 255, 255))
		levelLabel:setAnchorPoint(ccp(0.5, 0.5))
		levelLabel:setPosition(ccp(addSprite:getContentSize().width*161.0/270, addSprite:getContentSize().height*43/83))
		addSprite:addChild(levelLabel)
		addSprite:setPosition(ccp(0, -100))
		upgradeAnimSprite:addChild(addSprite,999)
	end

    -- 特效结束回调
    local upgradeAnimationEndCallBack = function ( ... )
    end
    local upgradeDelegate = BTAnimationEventDelegate:create()
    upgradeDelegate:registerLayerEndedHandler( upgradeAnimationEndCallBack )
    upgradeAnimSprite:setDelegate(upgradeDelegate)

    -- 更新数据
	initReinforceData()

	-- 清除强化费用
	_costNumFont:setString(_curCost)

	-- 创建下部ui
	createBottomUi()

	-- 提示 主公可前往神兵列表进阶该神兵
	if( _curLv >= _curMaxLv )then 
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("lic_1453"))
	end 
	
end

--[[
	@des 	:神兵上特效
	@param 	:
	@return :
--]]
function godWeaponEffect()

	-- 神兵上强化特效
	local godWeaponAnimSprite = CCLayerSprite:layerSpriteWithNameAndCount("images/god_weapon/effect/shenbingqianghua/shenbingqianghua", 1, CCString:create(""))
    godWeaponAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
    godWeaponAnimSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5,_bgSprite:getContentSize().height*0.5))
    _bgSprite:addChild(godWeaponAnimSprite,31)

    -- 特效结束回调
    local godWeaponAnimationEndCallBack = function ( ... )
       -- 显示强化等级特效
       upgradeEffect()
        -- 清除特效屏蔽层
	    if(_maskLayer ~= nil)then
			_maskLayer:removeFromParentAndCleanup(true)
			_maskLayer = nil
		end
    end
    local godWeaponDelegate = BTAnimationEventDelegate:create()
    godWeaponDelegate:registerLayerEndedHandler( godWeaponAnimationEndCallBack )
    godWeaponAnimSprite:setDelegate(godWeaponDelegate)

end

--[[
	@des 	:材料上特效
	@param 	:
	@return :
--]]
function materialEffect()

	-- 材料上加特效
	local conut = 0
	for k,v in pairs(_addMenuItemTab) do
		local materialSp = tolua.cast(v:getChildByTag(_tagMaterial),"CCSprite")
		local materialName = tolua.cast(v:getChildByTag(_tagMaterialName),"CCRenderLabel")
		local addSp = tolua.cast(v:getChildByTag(_tagAddSp),"CCSprite")
		if( materialSp ~= nil )then 
			-- 材料特效  
	        local materialAnimSprite = CCLayerSprite:layerSpriteWithNameAndCount("images/god_weapon/effect/wupindakai/wupindakai", 1, CCString:create(""))
	        materialAnimSprite:setAnchorPoint(ccp(0.5, 0))
	        materialAnimSprite:setPosition(ccp(v:getContentSize().width*0.5,v:getContentSize().height*0.5))
	        v:addChild(materialAnimSprite,10)

	        -- 特效结束回调
	        local animationFrameChanged = function ( p_frameIndex,p_xmlSprite )
	        	local tempSprite = tolua.cast(p_xmlSprite,"CCXMLSprite")
	        	if(tempSprite:getIsKeyFrame()) then
			       if(materialSp ~= nil)then
			       		materialSp:removeFromParentAndCleanup(true)
			       		materialSp = nil
			       end
			       if(materialName ~= nil)then
			       		materialName:removeFromParentAndCleanup(true)
			       		materialName = nil
			       end
			       addSp:setVisible(true)

			       -- 计数
			       conut = conut + 1
			       if( conut >= table.count(_newSelectList) )then 
			       		--  都消失了播放下一个特效
			       		godWeaponEffect()
			       end
			    end
	        end
	        local materialDelegate = BTAnimationEventDelegate:create()
	        materialAnimSprite:setDelegate(materialDelegate)
	        -- materialDelegate:registerLayerEndedHandler(animationFrameEndCallBack)
	        -- 关键帧处理函数
    		materialDelegate:registerLayerChangedHandler(animationFrameChanged)
		end
	end
end

--[[
	@des 	:刷新强化材料
	@param 	:
	@return :
--]]
function materialAction( p_node )
	local arrActions = CCArray:create()
	arrActions:addObject(CCMoveBy:create(1.5,ccp(0,10)))
	arrActions:addObject(CCMoveBy:create(1.5,ccp(0,-10)))
	local sequence = CCSequence:create(arrActions)
	local repeatSequence = CCRepeatForever:create(sequence)
	p_node:runAction(repeatSequence)
end

--[[
	@des 	:刷新强化材料
	@param 	:
	@return :
--]]
function refreshMaterialUi()
	if( tolua.cast(_bgLayer,"CCLayer") == nil )then
		return
	end
	if( table.isEmpty(_addMenuItemTab) )then
		return
	end
	-- 刷新材料icon
	_newSelectList = GodWeaponData.getMaterialSelectList()
	print("_oldSelectList")print_t(_oldSelectList)
	print("_newSelectList")print_t(_newSelectList)

	-- 删除多余
	for o_k,o_v in pairs(_oldSelectList) do
		local isIn = false
		for n_k,n_v in pairs(_newSelectList) do
			if( tonumber(o_v.item_id) == tonumber(n_v.item_id) )then 
				isIn = true
				break
			end
		end
		if(isIn == false)then
			-- 删除旧的图标
			tolua.cast(_addMenuItemTab[tonumber(o_k)]:getChildByTag(_tagMaterial),"CCSprite"):removeFromParentAndCleanup(true)
			tolua.cast(_addMenuItemTab[tonumber(o_k)]:getChildByTag(_tagMaterialName),"CCSprite"):removeFromParentAndCleanup(true)
			_addMenuItemTab[tonumber(o_k)]:getChildByTag(_tagAddSp):setVisible(true)
			_oldSelectList[o_k] = nil
		end
	end

	-- 添加新加的
	local newData = GodWeaponData.getDifferentInTab2(_oldSelectList,_newSelectList)
	print("newData...") print_t(newData)
	for k,v in pairs(_addMenuItemTab) do
		if( tolua.cast(_addMenuItemTab[k],"CCMenuItemSprite") ~= nil )then
			if( tolua.cast(v:getChildByTag(_tagMaterial),"CCSprite") == nil )then 
				if(newData[1] ~= nil)then
					local itemInfo = ItemUtil.getItemByItemId(newData[1].item_id)
					print("...") print_t(itemInfo)
					local iconSprite = ItemSprite.getItemBigSpriteById( tonumber(itemInfo.item_template_id) )
					iconSprite:setAnchorPoint(ccp(0.5,0.5))
					iconSprite:setPosition(_addMenuItemTab[k]:getContentSize().width*0.5,_addMenuItemTab[k]:getContentSize().height*0.5)
					_addMenuItemTab[k]:addChild(iconSprite,10,_tagMaterial)
					iconSprite:setScale(0.4)

					-- 材料的名字
					local quality,_,_ = GodWeaponItemUtil.getGodWeaponQualityAndEvolveNum(nil, nil,itemInfo)
					local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
					local nameStr = nil
					if( newData[1].num >1 )then
						nameStr = itemInfo.itemDesc.name .. "*" .. newData[1].num
					else
						nameStr = itemInfo.itemDesc.name
					end
					local nameLabel = CCRenderLabel:create(nameStr, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
				    nameLabel:setColor(nameColor)
				    nameLabel:setAnchorPoint(ccp(0.5,1))
				    nameLabel:setPosition(ccp(_addMenuItemTab[k]:getContentSize().width*0.5, 0))
				    _addMenuItemTab[k]:addChild(nameLabel,10,_tagMaterialName)
				    -- 储存上次选择列表
				    _oldSelectList[tostring(k)] = newData[1]
				    -- 取一个删一个
				    table.remove(newData,1)
				    -- 动画
				    _addMenuItemTab[k]:stopAllActions()
				    -- 重新设置位置
				    _addMenuItemTab[k]:setPosition(ccp(0,70))
				    materialAction(_addMenuItemTab[k])
				    _addMenuItemTab[k]:getChildByTag(_tagAddSp):setVisible(false)
				end
			end
		end
	end
	
	print("_oldSelectList1")print_t(_oldSelectList)

	if(not table.isEmpty(_newSelectList))then
		-- 刷新新增经验条
		_curAddExp = GodWeaponData.getOfferExpBySelectList( _newSelectList )
		local rate = nil
		local allExp = _curExp + _curAddExp
		local addLv,addSurplusExp,addNextNeedExp = LevelUpUtil.getLvByExp(_showItemInfo.itemDesc.enhanceexpID,allExp)

		if( addLv > _curLv )then 
			rate = 1
		else
			rate = addSurplusExp/addNextNeedExp
		end
		-- 显示
		_addProgressGreenBar:setVisible(true)
		_addProgressGreenBar:setContentSize(CCSizeMake(_bgProress:getContentSize().width*rate, _bgProress:getContentSize().height))
		-- 增长经验值
		_addExpNumFont:setVisible(true)
		_addExpNumFont:setString("+" .. _curAddExp)

		-- 更新消耗的银币
		_curCost = GodWeaponData.getCurReinforceCost( nil, _showItemInfo, _curAddExp)
		_costNumFont:setString(_curCost)
	else
		_curAddExp = 0
		_addProgressGreenBar:setVisible(false)
		_addExpNumFont:setVisible(false)
		_curCost = 0
		_costNumFont:setString(_curCost)
	end
end


--[[
	@des 	:创建强化材料
	@param 	:
	@return :
--]]
function createMaterialUi( )
    -- 材料加号
    for i=1,_maxChooseNum do
    	-- 五个小阵法特效
    	local smallAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/god_weapon/effect/shenbingjinjielan/shenbingjinjielan" ), -1,CCString:create(""))
	    smallAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
	    smallAnimSprite:setPosition(ccp(_bgSprite:getContentSize().width*_addPosX[i],_bgSprite:getContentSize().height*_addPosY[i]))
	    local zorder = 30
	    if( i < 7)then
	    	zorder = zorder + i
	    else
	    	zorder = zorder - (i-5)
	    end
	    _bgSprite:addChild(smallAnimSprite,zorder)
	    smallAnimSprite:setScale(_newScale)

	    -- 五个材料按钮
	    local menu = CCMenu:create()
	    menu:setAnchorPoint(ccp(0,0))
	    menu:setPosition(ccp(0,0))
	    menu:setTouchPriority(_layer_priority-2)
	    smallAnimSprite:addChild(menu,10)
	    
    	local addSprite = ItemSprite.createLucencyAddSprite()
    	local normalSp = CCSprite:create()
    	normalSp:setContentSize(addSprite:getContentSize())
    	local selectSp = CCSprite:create()
    	selectSp:setContentSize(addSprite:getContentSize())
    	local menuItem = CCMenuItemSprite:create(normalSp,selectSp)
    	menuItem:setAnchorPoint(ccp(0.5,0.5))
    	menuItem:setPosition(ccp(0,70))
    	menu:addChild(menuItem,1,i)

    	-- 加号按钮
    	addSprite:setAnchorPoint(ccp(0.5,0.5))
    	addSprite:setPosition(ccp(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.5))
    	menuItem:addChild(addSprite,1,_tagAddSp)

    	-- 加号按钮事件
    	menuItem:registerScriptTapHandler(addMenuItemCallBack)

    	-- 保存五个对象
    	table.insert(_addMenuItemTab,menuItem)
    end
end


--[[
	@des 	:创建神兵经验
	@param 	:
	@return :
--]]
function createGodWeaponExp( )
	if(tolua.cast(_bottomBg,"CCNode") ~= nil)then
		if(tolua.cast(_expNode,"CCNode") ~= nil)then
			_expNode:removeFromParentAndCleanup(true)
			_expNode = nil
		end
	end
   	-- 描述node
    local nodeArr = {}
    -- 等级
    local lvSp = CCSprite:create("images/common/lv.png")
    table.insert(nodeArr,lvSp)
    local lvFont = CCRenderLabel:create(_curLv .. " ", g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lvFont:setColor(ccc3(0xff, 0xf6, 0x00))
    table.insert(nodeArr,lvFont)
    -- 经验条
    local _,curSurplusExp,_ = LevelUpUtil.getLvByExp(_showItemInfo.itemDesc.enhanceexpID,_curExp)
    local rate = 0
    local expStr = nil
    if( _curLv < _curMaxLv )then 
		rate = curSurplusExp/_nextNeedExp
		if(rate > 1)then
			rate = 1
		end
		expStr = curSurplusExp .. "/" .. _nextNeedExp
	else
		rate = 1
		expStr = "Max"
	end
    -- expbg
    _bgProress = CCScale9Sprite:create("images/common/exp_bg.png")
	_bgProress:setContentSize(CCSizeMake(408, 23))
	table.insert(nodeArr,_bgProress)
	-- 蓝条
	local progressSp = CCScale9Sprite:create("images/common/exp_progress.png")
	progressSp:setContentSize(CCSizeMake(_bgProress:getContentSize().width*rate, _bgProress:getContentSize().height))
	progressSp:setAnchorPoint(ccp(0, 0.5))
	progressSp:setPosition(ccp(0, _bgProress:getContentSize().height * 0.5))
	_bgProress:addChild(progressSp,5)
	-- 经验值
	local expLabel = CCRenderLabel:create(expStr, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	expLabel:setColor(ccc3(0xff, 0xff, 0xff))
	expLabel:setAnchorPoint(ccp(0.5, 0.5))
	expLabel:setPosition(ccp(_bgProress:getContentSize().width*0.5, _bgProress:getContentSize().height*0.5))
	_bgProress:addChild(expLabel,10)
	-- 经验条节点
    _expNode = BaseUI.createHorizontalNode(nodeArr)
    _expNode:setAnchorPoint(ccp(0.5,0.5))
    _expNode:setPosition( _bottomBg:getContentSize().width*0.5 , _bottomBg:getContentSize().height-26 )
    _bottomBg:addChild(_expNode)

    _addProgressGreenBar = CCScale9Sprite:create("images/common/exp_progress_blue.png")
	_addProgressGreenBar:setContentSize(CCSizeMake(_bgProress:getContentSize().width*rate, _bgProress:getContentSize().height))
	_addProgressGreenBar:setAnchorPoint(ccp(0,0.5))
	_addProgressGreenBar:setPosition(ccp(1, _bgProress:getContentSize().height * 0.5))
	_bgProress:addChild(_addProgressGreenBar,2)
	local arrActions = CCArray:create()
	arrActions:addObject(CCFadeIn:create(0.8))
	arrActions:addObject(CCFadeOut:create(0.8))
	local sequence = CCSequence:create(arrActions)
	local action = CCRepeatForever:create(sequence)
	_addProgressGreenBar:runAction(action)
	_addProgressGreenBar:setVisible(false)

	-- 增加的经验显示
	_addExpNumFont = CCLabelTTF:create("",g_sFontName,21)
	_addExpNumFont:setColor(ccc3(0x00, 0x00, 0x00))
	_addExpNumFont:setAnchorPoint(ccp(0.5, 0.5))
	_addExpNumFont:setPosition(ccp(_bgProress:getContentSize().width*0.75, _bgProress:getContentSize().height*0.5))
	_bgProress:addChild(_addExpNumFont,10)
	_addExpNumFont:setVisible(false)

end

--[[
	@des 	:创建底部ui
	@param 	:
	@return :
--]]
function createBottomUi( )
	if(_bottomBg ~= nil)then
		_bottomBg:removeFromParentAndCleanup(true)
		_bottomBg = nil
	end
	_bottomBg = CCScale9Sprite:create("images/common/bg/9s_1.png")
	_bottomBg:setContentSize(CCSizeMake(640, 147))
	_bottomBg:setAnchorPoint(ccp(0.5, 1))
	_bottomBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.26))
	_bgLayer:addChild(_bottomBg)
	_bottomBg:setScale(g_fElementScaleRatio)

	-- 最大强化等级提示
	local tipStr = ""
	local isMax = GodWeaponItemUtil.isMaxEvolveLv( _showItemInfo.item_template_id, _evolveNum )
	if(isMax == true)then
		tipStr = GetLocalizeStringBy("lic_1452")
		tipColor = ccc3(0xe4,0x00,0xff)
	else
		if( _curLv < _curMaxLv )then 
			tipStr = GetLocalizeStringBy("lic_1421",_curMaxLv)
			tipColor = ccc3(0xe4,0x00,0xff)
		else
			tipStr = GetLocalizeStringBy("lic_1445")
			tipColor = ccc3(0x00,0xff,0x18)
		end
	end
    local maxReinforceFont = CCRenderLabel:create( tipStr , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    maxReinforceFont:setColor(tipColor)
	maxReinforceFont:setAnchorPoint(ccp(1,0.5))
	maxReinforceFont:setPosition(ccp(_bottomBg:getContentSize().width-40,_bottomBg:getContentSize().height + 23))
	_bottomBg:addChild(maxReinforceFont)
	-- 如果是经验神兵 不显示
	if( tonumber(_showItemInfo.itemDesc.isgodexp) == 1  )then  
		maxReinforceFont:setVisible(false)
	end

	-- 创建经验条
	createGodWeaponExp()

	-- 强化至下级属性：
	local tipFont = CCRenderLabel:create( GetLocalizeStringBy("lic_1443"),g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	tipFont:setColor(ccc3(0xff, 0xff, 0xff))
	tipFont:setAnchorPoint(ccp(0, 0.5))
	tipFont:setPosition(ccp(68, _bottomBg:getContentSize().height-55))
	_bottomBg:addChild(tipFont,10)

	-- 消耗的银币
    local fontTab = {}
    fontTab[1] = CCRenderLabel:create(GetLocalizeStringBy("lic_1420"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab[1]:setColor(ccc3(0xff,0xf6,0x00))
    fontTab[2] = CCSprite:create("images/common/coin.png")
    local costFont = BaseUI.createHorizontalNode(fontTab)
    costFont:setAnchorPoint(ccp(0,0.5))
	costFont:setPosition(ccp(393,tipFont:getPositionY()))
	_bottomBg:addChild(costFont)
	-- 消耗银币的数量
	_costNumFont = CCRenderLabel:create( " " .. _curCost , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _costNumFont:setColor(ccc3(0xff,0xff,0xff))
	_costNumFont:setAnchorPoint(ccp(0,0.5))
	_costNumFont:setPosition(ccp(costFont:getPositionX()+costFont:getContentSize().width,costFont:getPositionY()))
	_bottomBg:addChild(_costNumFont)

	-- 当前属性值
	local attrLabelTab = {}
    local attrTab = GodWeaponItemUtil.getWeaponAbility(nil,nil,_showItemInfo)
    print("attrTab") print_t(attrTab)
	local posX = {68,68,393,393}
	local posY = {54,22,54,22}
	if(not table.isEmpty(attrTab) )then
		for k,v in pairs(attrTab) do
			local attrLabel = CCLabelTTF:create(v.name .. "： " .. v.showNum ,g_sFontName,23)
			attrLabel:setColor(ccc3(0xff, 0xff, 0xff))
			attrLabel:setAnchorPoint(ccp(0, 0.5))
			attrLabel:setPosition(ccp(posX[k],posY[k]))
			_bottomBg:addChild(attrLabel)
			-- 保存label
			attrLabelTab[v.id] = attrLabel
		end
	end

	-- 下一级属性
	if( _curLv+1 <= _curMaxLv )then 
		local nextAttrTab = GodWeaponItemUtil.getAttrTable(_evolveNum,_curLv+1,_showItemInfo.itemDesc.id)
		print("nextAttrTab") print_t(nextAttrTab)
		local posX1 = {201,201,536,536}
		local posY1 = {54,22,54,22}
		if(not table.isEmpty(nextAttrTab) )then
			for k,v in pairs(attrTab) do
				for n_k,n_v in pairs(nextAttrTab) do
					if(tonumber(v.id) == tonumber(n_v.id))then
						local arrSp = CCSprite:create("images/common/right.png")
						arrSp:setAnchorPoint(ccp(0,0.5))
						arrSp:setPosition(ccp(posX1[k],posY1[k]))
						_bottomBg:addChild(arrSp)
						local nextAttrLabel = CCLabelTTF:create( n_v.showNum ,g_sFontName,23)
						nextAttrLabel:setColor(ccc3(0x00, 0xff, 0x18))
						nextAttrLabel:setAnchorPoint(ccp(0, 0.5))
						nextAttrLabel:setPosition(ccp(arrSp:getPositionX()+arrSp:getContentSize().width+5,arrSp:getPositionY()))
						_bottomBg:addChild(nextAttrLabel)
						break
					end
				end
			end
		end
	end
end

--[[
	@des 	:创建神兵全身像
	@param 	:
	@return :
--]]
function createGodWeaponBody( )
	-- 大阵法特效
	-- local bigAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/god_weapon/effect/shenbingjinjiehuang/shenbingjinjiehuang" ), -1,CCString:create(""))
    local bigAnimSprite = XMLSprite:create("images/god_weapon/effect/shenbingjinjiehuang/shenbingjinjiehuang")
    bigAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
    bigAnimSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5+10,_bgSprite:getContentSize().height*0.5-20 ))
    _bgSprite:addChild(bigAnimSprite,20)
    bigAnimSprite:setScale(1.3*bigAnimSprite:getScale())

	--神兵全身像
	_godWeaponBodySprite = GodWeaponItemUtil.getWeaponBigSprite(nil,nil,_hid,_showItemInfo)
	_godWeaponBodySprite:setAnchorPoint(ccp(0.5,0))
	_godWeaponBodySprite:setPosition(ccp(0,0))
	bigAnimSprite:addChild(_godWeaponBodySprite,5)
	_godWeaponBodySprite:setScale(_godWeaponBodySprite:getScale()/bigAnimSprite:getScale())
end

--[[
	@des 	:创建topUI
	@param 	:
	@return :
--]]
function createTopUi( )
    -- 神兵强化标题
    local titleSp = CCSprite:create("images/god_weapon/qianghua.png")
    titleSp:setAnchorPoint(ccp(0,1))
    titleSp:setPosition(ccp(10,_bgLayer:getContentSize().height-13*g_fElementScaleRatio ))
    _bgLayer:addChild(titleSp)
    titleSp:setScale(g_fElementScaleRatio)

    -- 返回按钮
    _menuBar = CCMenu:create()
    _menuBar:setAnchorPoint(ccp(0,0))
    _menuBar:setPosition(ccp(0,0))
    _menuBar:setTouchPriority(_layer_priority-2)
    _bgLayer:addChild(_menuBar)

    -- 创建返回按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(1, 1))
	closeMenuItem:setPosition(ccp( _bgLayer:getContentSize().width,_bgLayer:getContentSize().height ))
	_menuBar:addChild(closeMenuItem)
	closeMenuItem:registerScriptTapHandler(closeButtonCallback)
	closeMenuItem:setScale(g_fElementScaleRatio)

	--星星底
	local starBgSprite = CCSprite:create("images/recharge/transfer/star_bg.png")
	starBgSprite:setAnchorPoint(ccp(0.5,1))
	starBgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-5*g_fElementScaleRatio))
	_bgLayer:addChild(starBgSprite,10)
	starBgSprite:setScale(g_fElementScaleRatio)

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

	--名称底
	local nameBgSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	nameBgSprite:setContentSize(CCSizeMake(215,45))
	nameBgSprite:setAnchorPoint(ccp(0.5,1))
	nameBgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,starBgSprite:getPositionY()-starBgSprite:getContentSize().height*g_fElementScaleRatio))
	_bgLayer:addChild(nameBgSprite,10)
	nameBgSprite:setScale(g_fElementScaleRatio)

	--名字+阶数
	local nameLabel = CCRenderLabel:create(_showItemInfo.itemDesc.name .. GetLocalizeStringBy("lic_1428",_evolveShowNum) ,g_sFontPangWa,25,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(_quality))
	nameLabel:setAnchorPoint(ccp(0.5,0.5))
	nameLabel:setPosition(ccp(nameBgSprite:getContentSize().width*0.5,nameBgSprite:getContentSize().height*0.5))
	nameBgSprite:addChild(nameLabel)

	--五行图片
	local fiveSprite = CCSprite:create("images/god_weapon/five/" .. _showItemInfo.itemDesc.type .. ".png")
	fiveSprite:setAnchorPoint(ccp(1,1))
	fiveSprite:setPosition(ccp(20,nameBgSprite:getContentSize().height*0.5))
	nameBgSprite:addChild(fiveSprite,10)

	-- 强化按钮
	local enhanceBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png", "images/common/btn/btn_purple2_h.png",CCSizeMake(196, 73), GetLocalizeStringBy("lic_1422"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	enhanceBtn:setAnchorPoint(ccp(0.5, 0))
    enhanceBtn:setPosition(ccp(_bgLayer:getContentSize().width*0.15, _bgLayer:getContentSize().height*0.02))
	_menuBar:addChild(enhanceBtn)
	enhanceBtn:registerScriptTapHandler(enhanceBtnCallBack)
	enhanceBtn:setScale(g_fElementScaleRatio)

	-- 进阶按钮
    local evolveBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png",CCSizeMake(196, 73), GetLocalizeStringBy("lic_1423"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	evolveBtn:setAnchorPoint(ccp(0.5, 0))
    evolveBtn:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.02))
	_menuBar:addChild(evolveBtn)
	evolveBtn:registerScriptTapHandler(evolveBtnCallBack)
	evolveBtn:setScale(g_fElementScaleRatio)

    -- 自动添加按钮
    local automaticAddBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png",CCSizeMake(196, 73), GetLocalizeStringBy("lic_1429"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	automaticAddBtn:setAnchorPoint(ccp(0.5, 0))
    automaticAddBtn:setPosition(ccp(_bgLayer:getContentSize().width*0.85, _bgLayer:getContentSize().height*0.02))
	_menuBar:addChild(automaticAddBtn)
	automaticAddBtn:registerScriptTapHandler(automaticAddBtnCallBack)
	automaticAddBtn:setScale(g_fElementScaleRatio)
end


--[[
	@des 	:初始化强化界面
	@param 	:
	@return :
--]]
function initReinforceLayer( )
	-- 创建上部分ui
	createTopUi()

	-- 创建神兵全身像
	createGodWeaponBody()

	-- 创建底部属性框Ui
	createBottomUi()

	-- 创建强化材料
	createMaterialUi()
end

--[[
	@des 	:创建神兵强化界面
	@param 	:p_item_id
	@return :
--]]
function createReinforceLayer( p_item_id )
	-- 初始化变量
	init()

	-- 接收参数
	_showItemId = tonumber(p_item_id)

	-- 隐藏下排按钮
	MainScene.setMainSceneViewsVisible(false, false, false)

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent) 

    -- 大背景
    _bgSprite = CCSprite:create("images/god_weapon/qianghua.jpg")
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fBgScaleRatio)
	
    -- 初始化数据
    initReinforceData()

    -- 初始化界面
    initReinforceLayer()

    return _bgLayer
end


--[[
	@des 	:创建神兵强化界面
	@param 	:p_item_id,p_CallBack:关闭强化后回调
	@return :
--]]
function showReinforceLayer( p_item_id  )
	local layer = createReinforceLayer( p_item_id )
	MainScene.changeLayer(layer, "GodWeaponReinforceLayer")
end











