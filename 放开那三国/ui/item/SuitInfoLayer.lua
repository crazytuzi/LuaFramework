-- Filename：	SuitInfoLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-9-26
-- Purpose：		套装信息的展示

module("SuitInfoLayer", package.seeall)


require "script/ui/item/ItemUtil"
require "script/ui/main/MainScene"
require "script/ui/common/LuaMenuItem"

require "script/ui/item/EquipCardSprite"
require "script/ui/item/EquipBigSprite"
require "script/ui/formation/ChangeEquipLayer"

require "script/ui/item/EquipReinforceLayer"
require "script/ui/redequip/RedEquipLayer"

require "db/DB_Item_arm"

local Tag_Water 	= 9001
local Tag_Enforce	= 9002
local Tag_Change 	= 9003
local Tag_Remove 	= 9004
local kTagLock 		= 10000
local kTagUnlock 	= 10001
local _isRedCard 		    = false
local _bgLayer 				= nil
local _item_tmpl_id 		= nil
local _item_id 				= nil
local _isEnhance 			= false
local _isWater 				= false 
local _isChange 			= false 
local _itemDelegateAction	= nil
local _hid					= nil
local _pos_index			= nil	
local _menu_priority 		= nil	
local enhanceBtn 			= nil
-- 底部
local bottomSprite 			= nil
local bgSprite				= nil
-- 顶部
local topSprite				= nil
local contentSprite			= nil

local equips_ids_status, suit_attr_infos, suit_name = {}, {}, nil

-- 
local _showType 			= nil  --  2 <=> 好运

local _isShowLock 			= false -- 是否显示加锁按钮 false 不显示
local _lockBtn 				= nil  -- 加锁按钮
local _unlockBtn 			= nil -- 解锁按钮

local _isMenuVisible        = nil
local _isAvatarVisible      = nil
local _isBulletinVisible    = nil

local _quality              = nil

-- 初始化
local function init()
	_bgLayer 			= nil
	_item_tmpl_id 		= nil
	_item_id 			= nil
	_isEnhance 			= false
	_isWater 			= false 
	_isChange 			= false 
	_itemDelegateAction	= nil
	_hid				= nil
	_pos_index			= nil	
	_menu_priority		= nil
	enhanceBtn 			= nil
	bottomSprite 		= nil
	bgSprite			= nil
	-- 顶部
	topSprite			= nil
	contentSprite		= nil
	equips_ids_status, suit_attr_infos, suit_name = {}, {}, nil
	_showType 			= nil
	_isShowLock 		= false
	_isRedCard 		    = false
	_lockBtn 			= nil
	_unlockBtn 			= nil 

	_isMenuVisible      = nil
	_isAvatarVisible    = nil
	_isBulletinVisible  = nil

	_quality            = nil
end 

function setCardStatus( p_status )
	-- body
	_isRedCard = p_status
end

-- 关闭按钮
function closeAction( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")

	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer=nil
	MainScene.setMainSceneViewsVisible(_isMenuVisible,_isAvatarVisible,_isBulletinVisible)
end

function closeAction_2( ... )
	closeAction()

	if _isChange ~= true then
		-- 记忆背包偏移
		require "script/ui/bag/BagLayer"
		BagLayer.setMarkEquipItemId( _item_id )
	end
	if(_itemDelegateAction)then
		_itemDelegateAction()
	end
end

--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		-- print("began")

	    return true
    elseif (eventType == "moved") then
    	
    else
        -- print("end")
	end
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then

		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _menu_priority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		print("exit")
		_bgLayer:unregisterScriptTouchHandler()
	end
end

-- 卸装回调
function removeArmingCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then
		--战斗力信息
		--added by Zhang Zihang
		local _lastFightValue = FightForceModel.dealParticularValues(_hid)
		
		local t_numerial = ItemUtil.getTop2NumeralByIID(_item_id)
		closeAction()
		HeroModel.removeEquipFromHeroBy(_hid, _pos_index)

		FormationLayer.refreshEquipAndBottom()
		if(_itemDelegateAction)then
			_itemDelegateAction()
		end

		--战斗力信息
		--added by Zhang Zihang
		local _nowFightValue = FightForceModel.dealParticularValues(_hid)

		require "script/model/hero/HeroModel"
		local heroInfo = HeroModel.getHeroByHid(_hid)
		if(HeroModel.isNecessaryHero(heroInfo.htid))then
			require "script/model/utils/UnionProfitUtil"
			UnionProfitUtil.refreshUnionProfitInfo()
		end
		
		--ItemUtil.showAttrChangeInfo(t_numerial, nil)
		ItemUtil.showAttrChangeInfo(_lastFightValue,_nowFightValue)
	end
end


-- 
function menuAction( tag, itemBtn )
	if(tag == 12345)then
		closeAction()
		return
	end
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	if(tag == Tag_Water) then
		-- 洗练装备
		if(not DataCache.getSwitchNodeState(ksSwitchEquipFixed, true)) then
			return	
		end
		closeAction()
		require "script/ui/item/EquipFixedLayer"
		EquipFixedLayer.show(_item_id, EquipFixedLayer.kEquipInfoLayerType, _quality)
	elseif(tag == Tag_Enforce)then
		closeAction()
		-- 强化装备
		local enforceLayer = EquipReinforceLayer.createLayer(_item_id, _itemDelegateAction, nil, _quality)
		local onRunningLayer = MainScene.getOnRunningLayer()
		onRunningLayer:addChild(enforceLayer, 10)
		if MainScene.getOnRunningLayerSign() == "formationLayer" then
			enforceLayer:setPositionY(MenuLayer.getHeight() * 2)
			enforceLayer:setScale(g_winSize.width / enforceLayer:getContentSize().width)
		end
	elseif(tag == Tag_Change)then
		closeAction()
		-- 更换装备
		local changeEquipLayer = ChangeEquipLayer.createLayer( nil, tonumber(_hid) ,tonumber(_pos_index))
		MainScene.changeLayer(changeEquipLayer, "changeEquipLayer")
	elseif(tag == Tag_Remove)then
		-- 卸装
		if(ItemUtil.isEquipBagFull(true, closeAction_2))then
			return
		end
		local args = Network.argsHandler(_hid, _pos_index)
		RequestCenter.hero_removeArming(removeArmingCallback,args)
	elseif(tag == kTagLock)then
		-- 加锁
		print("加锁")
		-- 网络回调
		local serviceCallFun = function ( cbFlag, dictData, bRet )
			if( dictData.err == "ok" )then
				if(dictData.ret == "ok" )then
					-- 修改缓存数据
					if(_hid)then
						-- 武将身上装备
						HeroModel.setHeroEquipLockStatusByHid(_hid,_item_id,1)
					else
						-- 背包装备
						DataCache.setBagEquipLockStatusByItemId(_item_id,1)
					end
					_lockBtn:setVisible(false)
					_unlockBtn:setVisible(true)
					-- 提示
					require "script/ui/tip/AnimationTip"
        			AnimationTip.showTip(GetLocalizeStringBy("lic_1162"))
				end
			end
		end
		local args = Network.argsHandler(_item_id)
		Network.rpc(serviceCallFun, "forge.lock", "forge.lock", args, true)
	elseif(tag == kTagUnlock)then
		-- 解锁
		print("解锁")
		-- 网络回调
		local serviceCallFun = function ( cbFlag, dictData, bRet )
			if( dictData.err == "ok" )then
				if(dictData.ret == "ok" )then
					-- 修改缓存数据
					if(_hid)then
						-- 武将身上装备
						HeroModel.setHeroEquipLockStatusByHid(_hid,_item_id,0)
					else
						-- 背包装备
						DataCache.setBagEquipLockStatusByItemId(_item_id,0)
					end
					_lockBtn:setVisible(true)
					_unlockBtn:setVisible(false)
					-- 提示
					require "script/ui/tip/AnimationTip"
        			AnimationTip.showTip(GetLocalizeStringBy("lic_1163"))
				end
			end
		end
		local args = Network.argsHandler(_item_id)
		Network.rpc(serviceCallFun, "forge.unlock", "forge.unlock", args, true)
	else
	end
end

-- 创建各种按钮
function createMenuBtn( )

	if(_showType == 2)then
		local m_actionMenuBar = CCMenu:create()
		m_actionMenuBar:setPosition(ccp(0, 0))	
		m_actionMenuBar:setTouchPriority(_menu_priority - 1)
		bgSprite:addChild(m_actionMenuBar)
		-- 确定按钮
		local normalBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200, 71),GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		normalBtn:setAnchorPoint(ccp(0.5, 0.5))
		normalBtn:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height*0.08))
		normalBtn:registerScriptTapHandler(menuAction)
		m_actionMenuBar:addChild(normalBtn,1, 12345)
		return
	end

	-------------------------------- 几个按钮 ------------------------------
	local actionMenuBar = CCMenu:create()
	actionMenuBar:setPosition(ccp(0, 0))	
	actionMenuBar:setTouchPriority(_menu_priority-1)
	bottomSprite:addChild(actionMenuBar)

	-- 更换
	local changeBtn = nil
	local waterBtn 	= nil
	if(_isChange == true) then
		--兼容东南亚英文版
		if (Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
			changeBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_1543"),ccc3(0xfe, 0xdb, 0x1c),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		else
			changeBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_1543"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		end
		-- LuaMenuItem.createItemImage("images/item/equipinfo/btn_change_n.png", "images/item/equipinfo/btn_change_h.png", menuAction )
		changeBtn:setAnchorPoint(ccp(0.5, 0.5))
	    changeBtn:registerScriptTapHandler(menuAction)
		actionMenuBar:addChild(changeBtn, 1, Tag_Change)
		-- changeBtn:setScale(MainScene.elementScale)

		-- 是否有更好的装备
		local equip_desc = DB_Item_arm.getDataById(_item_tmpl_id)
		if( HeroModel.isNecessaryHeroByHid(_hid) == false and ItemUtil.hasBetterEquipBy( equip_desc.type, equip_desc.base_score ) == true )then
			require "script/libs/LuaCCSprite"
			local redTipSprite = LuaCCSprite.createTipSpriteWithNum(0)
			redTipSprite:setAnchorPoint(ccp(1, 1))
			redTipSprite:setPosition(ccp(changeBtn:getContentSize().width, changeBtn:getContentSize().height))
			changeBtn:addChild(redTipSprite)
		end

		--兼容东南亚英文版
		if (Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
			removeBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_2933"),ccc3(0xfe, 0xdb, 0x1c),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		else
			removeBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_2933"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		end
		removeBtn:setAnchorPoint(ccp(0.5, 0.5))
	    removeBtn:registerScriptTapHandler(menuAction)
		actionMenuBar:addChild(removeBtn, 1, Tag_Remove)
		-- removeBtn:setScale(MainScene.elementScale)
		-- 洗练
		--兼容东南亚英文版
 		if (Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
 			waterBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_2475"),ccc3(0xfe, 0xdb, 0x1c),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
 		else
 			waterBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_2475"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
 		end
		waterBtn:setAnchorPoint(ccp(0.5, 0.5))
	    waterBtn:registerScriptTapHandler(menuAction)
		actionMenuBar:addChild(waterBtn, 1, Tag_Water)
	end
	-- 强化
	if(_isEnhance == true) then
		--兼容东南亚英文版
 		if (Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
 			enhanceBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_3391"),ccc3(0xfe, 0xdb, 0x1c),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
 		else
 			enhanceBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_3391"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
 		end
		-- LuaMenuItem.createItemImage("images/item/equipinfo/btn_enhance_n.png", "images/item/equipinfo/btn_enhance_h.png", menuAction )
		enhanceBtn:setAnchorPoint(ccp(0.5, 0.5))
	    enhanceBtn:registerScriptTapHandler(menuAction)
		actionMenuBar:addChild(enhanceBtn, 1, Tag_Enforce)
		-- enhanceBtn:setScale(MainScene.elementScale)
	end

	-- 加锁
	local equipInfo = nil
	if(_item_id)then
		if(_hid)then
			equipInfo = ItemUtil.getEquipInfoFromHeroByItemId(_item_id)
		else
			equipInfo = ItemUtil.getItemInfoByItemId(_item_id)
		end
	end
	print("SuitInfoLayer _isShowLock equipInfo")
	print_t(equipInfo)
	-- 五星装备才有加锁功能
	if(_isShowLock == true and tonumber(equipInfo.itemDesc.quality) == 5)then
		_lockBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(215,73), GetLocalizeStringBy("lic_1160"), ccc3(255,222,0))
		_lockBtn:registerScriptTapHandler(menuAction)
		_lockBtn:setAnchorPoint(ccp(0.5,0.5))
		actionMenuBar:addChild(_lockBtn,1, kTagLock)
		local lockIcon = CCSprite:create("images/hero/unlock.png")
	    lockIcon:setAnchorPoint(ccp(1,0.5))
	    lockIcon:setPosition(_lockBtn:getContentSize().width- 19,_lockBtn:getContentSize().height/2)
	    _lockBtn:addChild(lockIcon)

		_unlockBtn =LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(215,73), GetLocalizeStringBy("lic_1161"), ccc3(255,222,0))
		_unlockBtn:registerScriptTapHandler(menuAction)
		_unlockBtn:setAnchorPoint(ccp(0.5,0.5))
		actionMenuBar:addChild(_unlockBtn,1, kTagUnlock )
		local unlockIcon = CCSprite:create("images/hero/lock.png")
	    unlockIcon:setAnchorPoint(ccp(1,0.5))
	    unlockIcon:setPosition(_unlockBtn:getContentSize().width-19,_unlockBtn:getContentSize().height/2)
	    _unlockBtn:addChild(unlockIcon)

		if(equipInfo.va_item_text.lock and tonumber(equipInfo.va_item_text.lock)== 1  ) then
			_lockBtn:setVisible(false)
			_unlockBtn:setVisible(true)
		else
			_lockBtn:setVisible(true)
			_unlockBtn:setVisible(false)
		end
	end

	if(_isChange == true)then
		changeBtn:setPosition(ccp(bottomSprite:getContentSize().width*0.15, bottomSprite:getContentSize().height*0.4))
		enhanceBtn:setPosition(ccp(bottomSprite:getContentSize().width*0.615, bottomSprite:getContentSize().height*0.4))
		removeBtn:setPosition(ccp(bottomSprite:getContentSize().width*0.385, bottomSprite:getContentSize().height*0.4))
		waterBtn:setPosition(ccp(bottomSprite:getContentSize().width*0.85, bottomSprite:getContentSize().height*0.4))
	elseif(_isEnhance == true and _isShowLock == true and tonumber(equipInfo.itemDesc.quality) == 5)then
		enhanceBtn:setPosition(ccp(bottomSprite:getContentSize().width*0.7, bottomSprite:getContentSize().height*0.4))
		_lockBtn:setPosition(ccp(bottomSprite:getContentSize().width*0.3, bottomSprite:getContentSize().height*0.4))
		_unlockBtn:setPosition(ccp(bottomSprite:getContentSize().width*0.3, bottomSprite:getContentSize().height*0.4))
	elseif(_isEnhance == true ) then
		enhanceBtn:setPosition(ccp(bottomSprite:getContentSize().width*0.5, bottomSprite:getContentSize().height*0.4))
	else
	end
	
end

--[[
	@des 	: 创建装备简介
	@param 	: 
	@return : 
--]]
function createItemInfo( pDesc )
	local attrSp = CCScale9Sprite:create("images/copy/fort/textbg.png")
    local textInfo = {
     		width = 550, -- 宽度
	        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 22,          -- 默认字体大小
	        elements =
	        {	
	            {
	            	type = "CCLabelTTF", 
	            	text = pDesc,
	            	color = ccc3(0x78,0x25,0x00)
	        	}
	        }
	 	}
 	local fontNode = LuaCCLabel.createRichLabel(textInfo)
 	-- 计算高度
 	local needHeight = fontNode:getContentSize().height + 40
	print("needHeight===",needHeight)
	attrSp:setContentSize(CCSizeMake(590,needHeight))
	-- 标题
	local titleBg = CCScale9Sprite:create("images/hero/info/title_bg.png")
	titleBg:setContentSize(CCSizeMake(180,40))
	titleBg:setAnchorPoint(ccp(0,0.5))
	titleBg:setPosition(ccp(0,attrSp:getContentSize().height))
	attrSp:addChild(titleBg,5)
	-- 简介
	local titleFont = CCLabelTTF:create(GetLocalizeStringBy("key_2371"),g_sFontName,22)
	titleFont:setColor(ccc3(0x00,0x00,0x00))
	titleFont:setAnchorPoint(ccp(0,0.5))
	titleFont:setPosition(ccp(20,titleBg:getContentSize().height*0.5))
	titleBg:addChild(titleFont)
	-- 简介描述
	fontNode:setAnchorPoint(ccp(0.5,1))
 	fontNode:setPosition(ccp(attrSp:getContentSize().width*0.5,attrSp:getContentSize().height-25))
 	attrSp:addChild(fontNode)

	return attrSp
end


--[[
	@des 	: 判断武将身上的红装是否满足一定等级
	@param 	: 
	@return : 
--]]
function judgeRedEquipFormHero( equipId, needLv )
	local allEquipFromHero = HeroUtil.getEquipsByHid(equipId)
	local step = 0
	if allEquipFromHero ~= nil then
		for pos,equipData in pairs(allEquipFromHero) do
			if equipData.va_item_text ~= nil then
				local armDevLv = tonumber(equipData.va_item_text.armDevelop)
				if armDevLv ~= nil and armDevLv >= tonumber(needLv) then
					step = step + 1
				end
			end
		end
		if step == 4 then
			return true
		else
			return false
		end
	end
	return false
end

--[[
	@des 	: 创建装备进阶属性(全)
	@param 	: 
	@return : 
--]]
function createItemAllDevAttr( itemData )
	require "db/DB_Arm_suit"
	local suitAllAttrData = {}
	local tabLen = table.count(DB_Arm_suit.Arm_suit)
	for i=1,tabLen do
		table.insert(suitAllAttrData,DB_Arm_suit.getDataById(i))
	end

	local attrSp = CCScale9Sprite:create("images/copy/fort/textbg.png")
	
	local attrNum = table.count(suitAllAttrData)
	local needHeight = attrNum*30+25
	attrSp:setContentSize(CCSizeMake(590,needHeight))
	-- 标题
	local titleBg = CCScale9Sprite:create("images/hero/info/title_bg.png")
	titleBg:setContentSize(CCSizeMake(180,40))
	titleBg:setAnchorPoint(ccp(0,0.5))
	titleBg:setPosition(ccp(0,attrSp:getContentSize().height))
	attrSp:addChild(titleBg,5)
	-- 进阶属性  yr_4001
	local titleFont = CCLabelTTF:create(GetLocalizeStringBy("yr_4002"),g_sFontName,22)
	titleFont:setColor(ccc3(0x00,0x00,0x00))
	titleFont:setAnchorPoint(ccp(0,0.5))
	titleFont:setPosition(ccp(20,titleBg:getContentSize().height*0.5))
	titleBg:addChild(titleFont)

	local height = attrSp:getContentSize().height-22
	require "script/libs/LuaCCLabel"
	-- 当前进阶等级  itemData.va_item_text.armDevelop
	local curLv = 0
	if itemData ~= nil then
		curLv = tonumber(itemData.va_item_text.armDevelop)
	end
	for k,v in pairs(suitAllAttrData) do
		local richInfo = {
            linespace = 2, -- 行间距
            alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
            lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
            labelDefaultFont = g_sFontName,
            labelDefaultColor = ccc3(0x00,0x00,0x00),
            labelDefaultSize = 22,
            defaultType = "CCLabelTTF",
            elements = {}
        }
		local needLv = tonumber(v[2])
		local singleAttrData = string.split(v[3],",")
		for index,attr in pairs(singleAttrData) do
			local eachAttrData = string.split(attr,"|")
			local id = tonumber(eachAttrData[1])
			local val = tonumber(eachAttrData[2])
			local affixInfo,showNum,realNum = ItemUtil.getAtrrNameAndNum(id,val)
			local attrName = {
                newLine = false,
                text = affixInfo.sigleName .. ":",
                color = ccc3(0x00,0x00,0x00),
            }
            local attrVal = {
                newLine = false,
                text = showNum,
                color = ccc3(0x00,0x00,0x00),
            }
            if itemData ~= nil and judgeRedEquipFormHero(itemData.equip_hid,needLv) then
				attrName.color = ccc3(0x78,0x25,0x00)
				attrVal.color = ccc3(0x00,0x66,0x00)
			end
			if index > 1 then
				local black = {
					newLine = false,
                	text = "    ",
				}
				table.insert(richInfo.elements,black)
			end
			table.insert(richInfo.elements,attrName)
			table.insert(richInfo.elements,attrVal)
		end
		if itemData ~= nil then
			if not judgeRedEquipFormHero(itemData.equip_hid,needLv) then
				local attrRequire = {
		            newLine = false,
		            text = GetLocalizeStringBy("yr_4004",needLv),
		            color = ccc3(0xff,0x9c,0x00),
		        }
				table.insert(richInfo.elements,attrRequire)
			end
		else
			local attrRequire = {
		            newLine = false,
		            text = GetLocalizeStringBy("yr_4004",needLv),
		            color = ccc3(0xff,0x9c,0x00),
		        }
			table.insert(richInfo.elements,attrRequire)
		end
	    local richTextLayer = LuaCCLabel.createRichLabel(richInfo)
	    richTextLayer:setAnchorPoint(ccp(0,1))
	    richTextLayer:setPosition(ccp(attrSp:getContentSize().width*0.1,height))
	    attrSp:addChild(richTextLayer)

	    height = height - richTextLayer:getContentSize().height-6
	end

	return attrSp
end

--[[
	@des 	: 创建装备进阶属性
	@param 	: 
	@return : 
--]]
function createItemDevAttr( itemData )
	local attrSp = CCScale9Sprite:create("images/copy/fort/textbg.png")
	-- evolve_attr
	local allDevAttrData = nil
	if itemData ~= nil then
		allDevAttrData = string.split(itemData.itemDesc.evolve_attr,",")
	else
		allDevAttrData = string.split(DB_Item_arm.getDataById(_item_tmpl_id).evolve_attr,",")
	end
	
	local attrNum = table.count(allDevAttrData)
	local needHeight = attrNum*30+25
	attrSp:setContentSize(CCSizeMake(590,needHeight))
	-- 标题
	local titleBg = CCScale9Sprite:create("images/hero/info/title_bg.png")
	titleBg:setContentSize(CCSizeMake(180,40))
	titleBg:setAnchorPoint(ccp(0,0.5))
	titleBg:setPosition(ccp(0,attrSp:getContentSize().height))
	attrSp:addChild(titleBg,5)
	-- 进阶属性(全)  yr_4002
	local titleFont = CCLabelTTF:create(GetLocalizeStringBy("yr_4001"),g_sFontName,22)
	titleFont:setColor(ccc3(0x00,0x00,0x00))
	titleFont:setAnchorPoint(ccp(0,0.5))
	titleFont:setPosition(ccp(20,titleBg:getContentSize().height*0.5))
	titleBg:addChild(titleFont)

	local height = attrSp:getContentSize().height-22
	require "script/libs/LuaCCLabel"
	for k,v in pairs(allDevAttrData) do
		local singleAttrData = string.split(v,"|")
		local needLv = tonumber(singleAttrData[1])
		local id = tonumber(singleAttrData[2])
		local val = tonumber(singleAttrData[3])
		local affixInfo,showNum,realNum = ItemUtil.getAtrrNameAndNum(id,val)
		-- 当前进阶等级  itemData.va_item_text.armDevelop
		local curLv = 0
		if itemData ~= nil then
			curLv = tonumber(itemData.va_item_text.armDevelop)
		end
	    local richInfo = {
	            linespace = 1, -- 行间距
	            alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	            lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
	            labelDefaultFont = g_sFontName,
	            labelDefaultColor = ccc3(0x00,0x00,0x00),
	            labelDefaultSize = 22,
	            defaultType = "CCLabelTTF",
	            elements =
	            {
	                {
	                    newLine = false,
	                    text = affixInfo.sigleName .. ":",
	                    color = ccc3(0x00,0x00,0x00),
	                },
	                {
	                    newLine = false,
	                    text = showNum,
	                    color = ccc3(0x00,0x00,0x00),
	                },
	                {
	                    newLine = false,
	                    text = GetLocalizeStringBy("yr_4003",needLv),
	                    color = ccc3(0xff,0x9c,0x00),
	                },
	            }
	        }

		if curLv ~= nil and curLv >= needLv then
			richInfo.elements[1].color = ccc3(0x78,0x25,0x00)
			richInfo.elements[2].color = ccc3(0x00,0x66,0x00)
			richInfo.elements[3] = nil
		end
	    local richTextLayer = LuaCCLabel.createRichLabel(richInfo)
	    richTextLayer:setAnchorPoint(ccp(0,1))
	    richTextLayer:setPosition(ccp(attrSp:getContentSize().width*0.1,height))
	    attrSp:addChild(richTextLayer)

	    height = height - richTextLayer:getContentSize().height-6
	end

	return attrSp
end

--[[
	@des 	: 创建装备当前属性
	@param 	: 
	@return : 
--]]
function createItemCurAttr( itemData, t_numerial )
	local attrSp = CCScale9Sprite:create("images/copy/fort/textbg.png")
	local step = 0
	if itemData ~= nil then
		local fixData = EquipAffixModel.getEquipFixedAffix(itemData)
		local baseData = EquipAffixModel.getEquipAffixById(tonumber(itemData.item_id))
		local developData = EquipAffixModel.getDevelopAffixByInfo(itemData)
		local pTable = {}
		for k,v in pairs(baseData)do
			pTable[k]=v
		end
		for k,v in pairs(fixData)do
			if pTable[k] == nil then
				pTable[k] = v
			else
				pTable[k] = pTable[k] + v
			end
		end
		
		for k,v in pairs(developData)do
			if pTable[k] == nil then
				pTable[k] = v
			else
				pTable[k] = pTable[k] + v
			end
		end
		-- 计算高度
		for k,v in pairs(pTable) do
			if tonumber(v) > 0 then
				step = step + 1
			end
		end
		local retTab = {}
		for k,v in pairs(pTable) do
			local temp = {}
			temp.id = k
			temp.attrVal = v
			table.insert(retTab,temp)
		end
		table.sort(retTab,function ( pData1, pData2 )
			return tonumber(pData1.id) < tonumber(pData2.id)
		end)
		local needHeight = step*30+60
		print("needHeight===",needHeight)
		attrSp:setContentSize(CCSizeMake(590,needHeight))

		local enhanceLv = 0
		local equipInfo = nil
		if _item_id then
			if _hid then
				equipInfo = ItemUtil.getEquipInfoFromHeroByItemId(_item_id)
			else
				equipInfo = ItemUtil.getItemInfoByItemId(_item_id)
			end
			enhanceLv = equipInfo.va_item_text.armReinforceLevel
		end

		local height = attrSp:getContentSize().height-25
		local descString = GetLocalizeStringBy("key_2137") .. enhanceLv .. "/" .. itemData.itemDesc.level_limit_ratio * UserModel.getHeroLevel() .."\n"
		local descLabel = CCLabelTTF:create(descString,g_sFontName,22)
		descLabel:setColor(ccc3(0x00,0x00,0x00))
		descLabel:setAnchorPoint(ccp(0,1))
		descLabel:setPosition(ccp(attrSp:getContentSize().width*0.1,height))
		attrSp:addChild(descLabel)
		for k,v in pairs(retTab) do
			local attr_id = v.id
			local attr_value = v.attrVal
			if tonumber(attr_value) > 0 then
				height = height - 28
				local affixInfo,showNum,realNum = ItemUtil.getAtrrNameAndNum(attr_id,attr_value)
				local attrLabel = CCLabelTTF:create(affixInfo.sigleName .. ": " .. showNum,g_sFontName,22)
				attrLabel:setColor(ccc3(0x00,0x00,0x00))
				attrLabel:setAnchorPoint(ccp(0,1))
				attrLabel:setPosition(ccp(attrSp:getContentSize().width*0.1,height))
				attrSp:addChild(attrLabel)
			end
		end
	else
		local equip_desc = DB_Item_arm.getDataById(_item_tmpl_id)
		-- 映射关系
		local potentialityConfig = {hp = 1, gen_att = 9, phy_att = 2, magic_att =3, phy_def = 4, magic_def = 5}
		step = table.count(t_numerial)
		local needHeight = step*30+50
		print("needHeight===",needHeight)
		attrSp:setContentSize(CCSizeMake(590,needHeight))
		local height = attrSp:getContentSize().height-25
		local descString = GetLocalizeStringBy("key_2137") .. "0" .. "/"..equip_desc.level_limit_ratio * UserModel.getHeroLevel() .. "\n"
		for key,v_num in pairs(t_numerial) do
			if (key == "hp") then
				descString = descString .. GetLocalizeStringBy("key_2356")
			elseif (key == "gen_att") then
				descString = descString .. GetLocalizeStringBy("key_2489")
			elseif(key == "phy_att"  )then
				descString = descString .. GetLocalizeStringBy("key_2328")
			elseif(key == "magic_att")then
				descString = descString .. GetLocalizeStringBy("key_3236")
			elseif(key == "phy_def"  )then
				descString = descString .. GetLocalizeStringBy("key_1779")
			elseif(key == "magic_def")then
				descString = descString .. GetLocalizeStringBy("key_1246")
			end
			descString = descString .. v_num .. "\n"
		end

		local descLabel = CCLabelTTF:create(descString,g_sFontName,22,CCSizeMake(225,100),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		descLabel:setColor(ccc3(0x00,0x00,0x00))
		descLabel:setAnchorPoint(ccp(0,1))
		descLabel:setPosition(ccp(attrSp:getContentSize().width*0.1,attrSp:getContentSize().height-25))
		attrSp:addChild(descLabel)
	end
	-- 标题
	local titleBg = CCScale9Sprite:create("images/hero/info/title_bg.png")
	titleBg:setContentSize(CCSizeMake(180,40))
	titleBg:setAnchorPoint(ccp(0,0.5))
	titleBg:setPosition(ccp(0,attrSp:getContentSize().height))
	attrSp:addChild(titleBg,5)
	-- 当前属性
	local titleFont = CCLabelTTF:create(GetLocalizeStringBy("key_1293"),g_sFontName,22)
	titleFont:setColor(ccc3(0x00,0x00,0x00))
	titleFont:setAnchorPoint(ccp(0,0.5))
	titleFont:setPosition(ccp(20,titleBg:getContentSize().height*0.5))
	titleBg:addChild(titleFont)

	return attrSp
end

-- 创建scrollview中的套装信息内容
function createSuitUI()
	-- 套装背景
	local suitSprite = CCSprite:create("images/common/suit.png")
	-- 套装名称
	suit_name = suit_name or ""
	local suitNameLabel = CCRenderLabel:create(suit_name, g_sFontPangWa, 30, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    suitNameLabel:setColor(ccc3(0x78,0x25,0x00))
    suitNameLabel:setAnchorPoint(ccp(0.5,1))
    suitNameLabel:setPosition(ccp(suitSprite:getContentSize().width/2, suitSprite:getContentSize().height+8))
    suitSprite:addChild(suitNameLabel)
    -- 物品展示
    local position_scale_x = {0.2, 0.4, 0.6, 0.8, 0.9}
    local index = 0
    for item_tmpl_id, hadUnlock in pairs(equips_ids_status) do
    	index = index + 1
    	local itemDesc = ItemUtil.getItemById(item_tmpl_id)
    	-- 头像
    	local itemBtn = nil
    	if(_item_id)then
			if(_hid)then
				equipInfo = ItemUtil.getEquipInfoFromHeroByItemId(_item_id)
			else
				equipInfo = ItemUtil.getItemInfoByItemId(_item_id)
			end
		end
    	local quality = nil
		if _quality ~= -1 then
			quality = tonumber(_quality)
		elseif equipInfo ~= nil then
			quality = ItemUtil.getEquipQualityByItemInfo(equipInfo)
		end
		if quality == nil then
			quality = itemDesc.quality
		end
		print("===_quality",quality)
    	if(hadUnlock)then
    		itemBtn = ItemSprite.getItemSpriteByItemId(tonumber(item_tmpl_id),nil,nil,nil,quality)
    	else
    		itemBtn = ItemSprite.getItemGraySpriteByItemId(tonumber(item_tmpl_id),quality)
    	end
    	itemBtn:setAnchorPoint(ccp(0.5, 0.5))
    	itemBtn:setPosition(ccp(suitSprite:getContentSize().width*position_scale_x[index], suitSprite:getContentSize().height *0.55))
    	suitSprite:addChild(itemBtn)
    	-- 名字
    	local nameColor = HeroPublicLua.getCCColorByStarLevel(itemDesc.quality)
    	if quality == 7 then
    		nameColor = HeroPublicLua.getCCColorByStarLevel(itemDesc.new_quality+1)
    	end
    	local nameLabel = CCRenderLabel:create(itemDesc.name, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    nameLabel:setColor(nameColor)
	    nameLabel:setPosition(ccp(itemBtn:getContentSize().width*0.5 - nameLabel:getContentSize().width*0.5, 0))
	    --兼容东南亚英文版
 		if (Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
 			nameLabel:setVisible(false)
 		end
	    itemBtn:addChild(nameLabel)
    end

    --  套装属性的状态
    local suitTitleColor = ccc3(0x00,0xff,0x18)
    local suitAttrColor  = ccc3(0xff,0x9c,0x00)
    local sideColor = ccc3(0x00,0x00,0x00)

    local s_height = suitSprite:getContentSize().height - 190

    local suit_position_x = {180, 375, 180, 375, 180, 375}
    local suit_position_y_add = {0, 0, 30, 0, 30, 0}

    for k, suit_attr_info in pairs(suit_attr_infos) do
    	s_height = s_height - 10
    	if(suit_attr_info.hadUnlock == false) then
    		suitTitleColor = ccc3(155,155,155)
    		suitAttrColor = ccc3(155,155,155)
    		sideColor = ccc3(0,0,0)
    	end
    	-- 套装个数
    	local numLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2025") .. suit_attr_info.lock_num .. GetLocalizeStringBy("key_2625"),g_sFontPangWa,25,1,sideColor,type_stroke)
	    numLabel:setColor(suitTitleColor)
	    numLabel:setAnchorPoint(ccp(0,1))
	    numLabel:setPosition(ccp(50,s_height))
	    suitSprite:addChild(numLabel)
	    s_height = s_height - 5
	    local a_index = 0
	    for attr_id,attr_num in pairs(suit_attr_info.astAttr) do
	    	a_index = a_index + 1
	    	s_height = s_height-suit_position_y_add[a_index]

	    	local affixDesc,displayNum = ItemUtil.getAtrrNameAndNum(attr_id,attr_num)
	    	-- 属性名称
	    	local attr_name_num_label = CCRenderLabel:create(affixDesc.sigleName .. ": +" .. displayNum,g_sFontPangWa,18,1,sideColor,type_stroke)
			attr_name_num_label:setColor(suitAttrColor)
			attr_name_num_label:setAnchorPoint(ccp(0,1))
			attr_name_num_label:setPosition(ccp(suit_position_x[a_index],s_height))
			suitSprite:addChild(attr_name_num_label)
	    end
	    s_height = s_height - 30

	    -- 分割线
		local lineSprite = CCSprite:create("images/item/equipinfo/line.png")
		lineSprite:setAnchorPoint(ccp(0.5,1))
		lineSprite:setScaleX(5)
		lineSprite:setPosition(ccp(suitSprite:getContentSize().width*0.5,s_height))
		suitSprite:addChild(lineSprite)
		s_height = s_height - 20
    end

    return suitSprite
end

--[[
	@des 	: 装备进阶回调
	@param 	: 
	@return : 
--]]
function devBtnCallback( pEquipId )
	if DataCache.getSwitchNodeState(ksSwitchRedEquip) then
		local equipId = tonumber(pEquipId)
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
		-- 进入进阶
		RedEquipLayer.showLayer(equipId)
	end
end

--[[
	@des 	: 判断玩家等级是否满足进阶按钮显示等级
	@param 	: 
	@return : 
--]]
function judgeUserLvShowLv( ... )
	require "db/DB_Normal_config"
    local showLv = DB_Normal_config.getDataById(1).jinjiedisplay_lv
    local userLv = UserModel.getHeroLevel()
    if userLv >= showLv then
    	return true
    else
    	return false
    end
end

-- scrollview
function createInfoScrollview()
	-- 获取装备数据
	local equip_desc = DB_Item_arm.getDataById(_item_tmpl_id)
	-- 获得相关数值
	local t_numerial, t_numerial_PL, t_equip_score
	local equipData = nil
	if _item_id then
		t_numerial, t_numerial_PL, t_equip_score = ItemUtil.getTop2NumeralByIID(_item_id)
		-- 获取装备数据
		local a_bagInfo = DataCache.getBagInfo()
		for k,s_data in pairs(a_bagInfo.arm) do
			if( tonumber(s_data.item_id) == _item_id ) then
				equipData = s_data
				break
			end
		end
		-- 如果为空则是武将身上的装备
		if(table.isEmpty(equipData))then
			equipData = ItemUtil.getEquipInfoFromHeroByItemId(_item_id)
		end
	else
		t_numerial, t_numerial_PL, t_equip_score = ItemUtil.getTop2NumeralByTmplID(_item_tmpl_id)
	end
	-- scrollview content
	contentSprite = CCSprite:create()
	-- 装备大图标
	local itemId = nil
	if equipData ~= nil then
		itemId = equipData.item_id
	end
	local cardSprite = EquipBigSprite.createSprite(_item_tmpl_id,itemId,t_equip_score,_quality)  -- EquipCardSprite
	cardSprite:setAnchorPoint(ccp(0.5,1))
	contentSprite:addChild(cardSprite)
	-- 如果是橙装 已进阶的红装  则显示 进阶按钮
    if equipData ~= nil and judgeUserLvShowLv() and equip_desc.new_quality ~= nil then
    	local btnMenu = CCMenu:create()
    	btnMenu:setPosition(ccp(0,0))
    	btnMenu:setTouchPriority(-560)
    	cardSprite:addChild(btnMenu)
    	local devBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(160,73),GetLocalizeStringBy("key_1730"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
    	devBtn:setAnchorPoint(ccp(0.5,0))
    	devBtn:setPosition(ccp(cardSprite:getContentSize().width*0.5,20))
    	devBtn:registerScriptTapHandler(function( ... )
			devBtnCallback(equipData.item_id)
		end)
    	btnMenu:addChild(devBtn)
	end
	-- 创建scrollview中的套装信息内容
	local suitSprite = createSuitUI()
	suitSprite:setAnchorPoint(ccp(0.5,1))
	contentSprite:addChild(suitSprite)
	-- 创建装备属性相关
	local attrSprite = createItemCurAttr(equipData,t_numerial)
	attrSprite:setAnchorPoint(ccp(0.5,1))
	contentSprite:addChild(attrSprite)
	-- 创建进阶属性
	-- 创建进阶属性（全）
	local devAttrSprite = nil
	local devAllAttrSprite = nil
	if judgeUserLvShowLv() and equip_desc.new_quality ~= nil then
		devAttrSprite = createItemDevAttr(equipData)
		devAttrSprite:setAnchorPoint(ccp(0.5,1))
		contentSprite:addChild(devAttrSprite)
		
		devAllAttrSprite = createItemAllDevAttr(equipData)
		devAllAttrSprite:setAnchorPoint(ccp(0.5,1))
		contentSprite:addChild(devAllAttrSprite)
	end
	-- 创建装备简介
	local infoSprite = createItemInfo(equip_desc.info)
	infoSprite:setAnchorPoint(ccp(0.5,1))
	contentSprite:addChild(infoSprite)
	-- scrollView的高度
	local scrollviewHeight = 0
	if(_showType == 1)then
		scrollviewHeight = bgSprite:getContentSize().height-topSprite:getContentSize().height - bottomSprite:getContentSize().height
	else
		scrollviewHeight = bgSprite:getContentSize().height-topSprite:getContentSize().height - 150
	end
	-- 内容的高度
	local contentHeight = nil
	if judgeUserLvShowLv() and equip_desc.new_quality ~= nil then
		contentHeight = cardSprite:getContentSize().height+suitSprite:getContentSize().height+attrSprite:getContentSize().height+infoSprite:getContentSize().height+devAttrSprite:getContentSize().height+devAllAttrSprite:getContentSize().height+110
	else
		contentHeight = cardSprite:getContentSize().height+suitSprite:getContentSize().height+attrSprite:getContentSize().height+infoSprite:getContentSize().height+50
	end
	-- 算
	for k, suit_attr_info in pairs(suit_attr_infos) do
    	contentHeight = contentHeight + 30
	    contentHeight = contentHeight + 5
	    local t_count = math.ceil(table.count(suit_attr_info.astAttr)/2)
	    contentHeight = contentHeight + t_count*30
	    contentHeight = contentHeight + 30
    end
    -- 减去最后一个
    contentHeight = contentHeight-50
	if(contentHeight<scrollviewHeight)then
		contentHeight = scrollviewHeight
	end
	contentSprite:setContentSize(CCSizeMake(bgSprite:getContentSize().width, contentHeight))
	
	cardSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,contentHeight-10))
	suitSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,cardSprite:getPositionY()-cardSprite:getContentSize().height-10))
	attrSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,suitSprite:getPositionY()-suitSprite:getContentSize().height-240))
	if judgeUserLvShowLv() and equip_desc.new_quality ~= nil then
		devAttrSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,attrSprite:getPositionY()-attrSprite:getContentSize().height-30))
		devAllAttrSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,devAttrSprite:getPositionY()-devAttrSprite:getContentSize().height-30))
		infoSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,devAllAttrSprite:getPositionY()-devAllAttrSprite:getContentSize().height-30))
	else
		infoSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,attrSprite:getPositionY()-attrSprite:getContentSize().height-30))
	end
	-- scrollView
	local suitScrollView = CCScrollView:create()
	suitScrollView:setContainer(contentSprite)
	suitScrollView:setTouchEnabled(true)
	suitScrollView:setDirection(kCCScrollViewDirectionVertical)
	suitScrollView:setViewSize( CCSizeMake(bgSprite:getContentSize().width, scrollviewHeight) )
	suitScrollView:setBounceable(true)
	if(_showType == 1)then
		suitScrollView:setPosition(ccp(0, bottomSprite:getContentSize().height))
	else
		suitScrollView:setPosition(ccp(0, 100))
	end
	suitScrollView:setTouchPriority(_menu_priority-1)
	suitScrollView:setContentOffset(ccp(0, -(contentHeight - scrollviewHeight) ))
	bgSprite:addChild(suitScrollView)
end

-- 
local function create()

	local myScale = _bgLayer:getContentSize().width/640/MainScene.elementScale

	local anchorPoint = ccp(0.5,1)
	local contengSize = CCSizeMake(_bgLayer:getContentSize().width/MainScene.elementScale,  _bgLayer:getContentSize().height/MainScene.elementScale)
	local position = ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height)
	if(_showType == 2)then
		anchorPoint = ccp(0.5, 0.5)
		contengSize = CCSizeMake(640, 750)
		position = ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.5)
	end
	bgSprite = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png")
	bgSprite:setContentSize(contengSize)
	bgSprite:setAnchorPoint(anchorPoint)
	bgSprite:setPosition(position)
	_bgLayer:addChild(bgSprite, 1)
	if(_showType == 2)then
		myScale = _bgLayer:getContentSize().width/640
		bgSprite:setScale(myScale)
	end

	-- 顶部
	topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height))
	bgSprite:addChild(topSprite, 2)
	if(_showType == 1)then
		topSprite:setScale(myScale)
		-- 标题
		local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2541"), g_sFontPangWa, 33, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	    titleLabel:setAnchorPoint(ccp(0.5,0.5))
	    titleLabel:setPosition(ccp( ( topSprite:getContentSize().width )/2, topSprite:getContentSize().height*0.6))
	    topSprite:addChild(titleLabel)
	
	elseif(_showType == 2)then
		-- 好运
		local goodluck = CCSprite:create("images/common/luck.png")
		goodluck:setPosition(ccp(topSprite:getContentSize().width/2,topSprite:getContentSize().height*0.6))
		goodluck:setAnchorPoint(ccp(0.5,0.5))
		topSprite:addChild(goodluck)
	end
	

	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	topSprite:addChild(closeMenuBar)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 0.5))
    closeBtn:setPosition(ccp(topSprite:getContentSize().width*1.01, topSprite:getContentSize().height*0.54))
    closeBtn:registerScriptTapHandler(closeAction_2)
	closeMenuBar:addChild(closeBtn)
	closeMenuBar:setTouchPriority(_menu_priority-1)

	if(_showType == 2)then
		--武将名称
		local explainLabel1 = CCRenderLabel:create(GetLocalizeStringBy("key_1682"), g_sFontPangWa,33,1,ccc3(0x00,0x00,0x00),type_shadow)
		explainLabel1:setPosition(ccp(bgSprite:getContentSize().width/2-100, bgSprite:getContentSize().height-90))
		explainLabel1:setColor(ccc3(0xff,0xf0,0x00))
		explainLabel1:setAnchorPoint(ccp(0.5,0.5))
		bgSprite:addChild(explainLabel1)
		
		-- 获取装备数据
		local equip_desc = DB_Item_arm.getDataById(_item_tmpl_id)
		
		local explainLabel2 = CCRenderLabel:create(equip_desc.name, g_sFontPangWa,33,1,ccc3(0x00,0x00,0x00),type_shadow)
		explainLabel2:setPosition(ccp(bgSprite:getContentSize().width/2+20, bgSprite:getContentSize().height-90))
		explainLabel2:setColor(ccc3(0x0b,0xe5,0x00))
		explainLabel2:setAnchorPoint(ccp(0,0.5))
		bgSprite:addChild(explainLabel2)
	end

	if(_showType == 1)then
		-- 底部
		bottomSprite = CCSprite:create("images/common/sell_bottom.png")
		bottomSprite:setAnchorPoint(ccp(0.5, 0))
		bottomSprite:setPosition(ccp(_bgLayer:getContentSize().width/2,0))
		_bgLayer:addChild(bottomSprite,2)
		bottomSprite:setScale(myScale)
	end
end

-- 处理数据
local function handleData()
	equips_ids_status, suit_attr_infos, suit_name = ItemUtil.getSuitInfoByIds(_item_tmpl_id, _hid)
	print("======>")
	print("suit_name",suit_name)
	print("equips_ids_status")
	print_t(equips_ids_status)
	print("suit_attr_infos")
	print_t(suit_attr_infos)
end

-- 创建Layer
function createLayer( template_id,  item_id, isEnhance, isWater, isChange, itemDelegateAction, hid_c, pos_index, menu_priority, showType, p_isShowLock, pQuality)
	print("itemDelegateAction", template_id,  item_id, isEnhance, isWater, isChange, itemDelegateAction, menu_priority)
	init()
	_menu_priority		= menu_priority
	_item_tmpl_id 		= template_id
	_item_id 			= item_id
	_isEnhance			= isEnhance
	_isWater 			= isWater
	_isChange 			= isChange
	_itemDelegateAction = itemDelegateAction
	_hid				= hid_c
	_pos_index 			= pos_index
	_showType			= showType or 1
	_isShowLock 		= p_isShowLock
	_quality            = pQuality
	print("===|SuitInfoLayer createLayer quality|===",_quality)
	-- 按钮状态
	_isMenuVisible      = MainScene.isMenuVisible()
	_isAvatarVisible    = MainScene.isAvatarVisible()
	_isBulletinVisible  = MainScene.isBulletinVisible()

	if _isChange == true then
		RedEquipLayer.setChangeLayerMark(RedEquipLayer.kTagFormation)
	else
		RedEquipLayer.setChangeLayerMark(RedEquipLayer.kTagBag)
	end

	if(_menu_priority == nil) then
		_menu_priority = -434
	end

	if(_showType == 1)then
		_bgLayer = MainScene.createBaseLayer(nil, false, false, true)
	elseif(_showType == 2)then
		_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
		_menu_priority = -520
	end
	_bgLayer:registerScriptHandler(onNodeEvent)
	handleData()
	create()
	createMenuBtn()
	createInfoScrollview()

	return _bgLayer
end

-- 新手引导
function getGuideObject()
	return enhanceBtn
end

