-- FileName: PocketMainLayer.lua
-- Author:
-- Date: 2014-04-00
-- Purpose: 锦囊系统主显示界面

module ("PocketMainLayer", package.seeall)

require "db/DB_Item_pocket"
require "db/DB_Normal_config"
require "script/model/DataCache"
require "script/model/user/UserModel"

require "script/ui/formation/FormationLayer"
require "script/ui/pocket/PocketUpgradeLayer"
require "script/ui/pocket/PocketChooseLayer"
require "script/ui/main/MainScene"

require "script/ui/tip/AnimationTip"
require "script/ui/hero/HeroPublicLua"
require "script/model/affix/HeroAffixModel"
require "script/utils/LevelUpUtil"

local Star_Img_Path = "images/star/intimate/"

local _lockTag 				= 1
local _changeTag 			= 2
local _upgradeTag 			= 3
local _removeTag 			= 4
local _realPos 				= 0

local _pos 					= 0
local _scaleY 				= 0.53
local _scaleId 				= 0
local _pocketNum 			= 3
local _pTouch 				= 0 	-- 触摸优先级
local _curHeroIndex 		= 0		-- 当前英雄的index
local _downLabel 			= nil
local _attrSprite 			= nil	-- 滑动对照图
local _touchBeganPoint 		= nil	-- 第一次点击的坐标
local _curBodyImage 		= nil	-- 当前全身像
local _bgLayer 				= nil
local _bgSprite 			= nil
local _heroInfo 			= nil
local _bottomBgSprite 		= nil
local _progressSp			= nil	-- 经验条
local _worldPanel 			= nil	-- 弹出按钮框
local _arrowSprite 			= nil   -- 弹出框小三角
local _arrowLeft 			= nil
local _arrowRight 			= nil
local _isOnAnimation 		= false	-- 是否正在滑动

local _formationInfo 		= {}	-- 阵容table
local _pOpenTable 			= {}
local _pocketTable 			= {}
local _havePocketTable 		= {}
local _pLimitLevel 			= {}
_curAffixTable 		= {}

local function init()
	_realPos 				= 0
	_pos 					= 0
	_scaleId 				= 0
	_pTouch 				= 0 	-- 触摸优先级
	_curHeroIndex 			= 0		-- 当前英雄的index
	_pocketNum 				= 3

	_arrowLeft 			= nil
	_arrowRight 			= nil
	_attrSprite 			= nil	-- 单个名将的属性显示
	_touchBeganPoint 		= nil	-- 第一次点击的坐标
	_curBodyImage 			= nil	-- 当前名将的全身像
	_bgLayer 				= nil
	_bgSprite 				= nil
	_heroInfo 				= nil
	_downLabel 				= nil
	_bottomBgSprite 		= nil
	_progressSp				= nil	-- 经验条
	_worldPanel 			= nil	-- 弹出按钮框
	_arrowSprite 			= nil   -- 弹出框小三角
	
	_isOnAnimation 			= false	-- 是否正在滑动

	_havePocketTable 		= {}
	_formationInfo 			= {}	-- 阵容table
	_curAffixTable 			= {}
	_pOpenTable 			= {}
	_pocketTable 			= {}
	_pLimitLevel 			= {}
end

-- 点击中间按钮弹窗
local function pocketMenuItemCallback( tag, sender )
	for k,v in pairs(_pLimitLevel) do
		if(tonumber(v)==tonumber(tag))then
			_pos = tonumber(k)
			break
		end
	end
	_arrowSprite:setVisible(false)
	-- 判断是否达到开启等级
	if(not _pOpenTable[tonumber(tag)])then
		AnimationTip.showTip( GetLocalizeStringBy("llp_228",tag) )
	else
		-- 判断是否有锦囊 没有锦囊直接进入选择锦囊界面 有锦囊出弹板选择后续操作
		if(_havePocketTable[_pos]==false)then
			local layer = PocketChooseLayer.createLayer(nil,nil, _formationInfo[_curHeroIndex], _pos)
			MainScene.changeLayer(layer,"PocketChooseLayer")
		else
			-- 判断是否有已经被打开的弹窗 有关掉
			if(tag~=_scaleId)then
				_worldPanel:setScale(0)
				_bgSprite:removeChildByTag(10,true)
				createFadeOutMenu()
			end
			if(tag==tonumber(_pLimitLevel[1]))then
				_worldPanel:setPosition(ccp(sender:getPositionX()+50,sender:getPositionY()+sender:getContentSize().height*sender:getScale()*0.5+_arrowSprite:getContentSize().height))
			elseif(tag==tonumber(_pLimitLevel[2]))then
				_worldPanel:setPosition(ccp(sender:getPositionX(),sender:getPositionY()+sender:getContentSize().height*sender:getScale()*0.5+_arrowSprite:getContentSize().height))
			else
				_worldPanel:setPosition(ccp(sender:getPositionX()-50,sender:getPositionY()+sender:getContentSize().height*sender:getScale()*0.5+_arrowSprite:getContentSize().height))
			end
			_arrowSprite:setPosition(ccp(sender:getPositionX(),sender:getPositionY()+sender:getContentSize().height*sender:getScale()*0.5))
		    if(_worldPanel:getScale()<1)then
		    	local action = CCScaleTo:create(0.2, 1)
		    	_worldPanel:stopAllActions()
				_worldPanel:runAction(action)
		    else
		    	local action = CCScaleTo:create(0.2, 0)
		    	_worldPanel:stopAllActions()
				_worldPanel:runAction(action)
		    end

		    if(_worldPanel:getScale()<1)then
		    	_arrowSprite:setVisible(true)
		    else
				_arrowSprite:setVisible(false)
		    end
		    _scaleId = tag
		end
	end
end

-- 动画结束
local function animatedEndAction( nextHeroSprite )
	_curBodyImage:removeFromParentAndCleanup(true)
	_curBodyImage = nextHeroSprite
	_isOnAnimation = false
end

--创建锦囊按钮
local function createPocketItem( isOpen,p_index )
	-- 桌子
	local sealSprite = nil
	local tableSprite = CCSprite:create("images/pocket/ii.png")
	tableSprite:setAnchorPoint(ccp(0.5,0.5))
	if(_havePocketTable[p_index]==true)then
		sealSprite = BagUtil.getSealSpriteByItemTempId(_pocketTable[tostring(p_index)].item_template_id)
	else
		sealSprite = CCScale9Sprite:create("images/common/bg/seal_9s_bg.png")
	end
	tableSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.25*p_index,_bottomBgSprite:getContentSize().height+80+sealSprite:getContentSize().height*g_fScaleX))

	_bgSprite:addChild(tableSprite,1,100+p_index)

	-- 桌子特效
	local pocketEffect = nil
	if(p_index==1)then
		pocketEffect = XMLSprite:create("images/pocket/jinnangmiaojilv/".."jinnangmiaojilv")
	elseif(p_index==2)then
		pocketEffect = XMLSprite:create("images/pocket/jinnangmiaojilan/".."jinnangmiaojilan")
	else
		pocketEffect = XMLSprite:create("images/pocket/jinnangmiaojihuang/".."jinnangmiaojihuang")
	end
	_bgSprite:addChild(pocketEffect,0,200+p_index)
	pocketEffect:setAnchorPoint(ccp(0.5,0.5))
	pocketEffect:setPosition(ccp(_bgSprite:getContentSize().width*0.25*p_index,_bottomBgSprite:getContentSize().height+80+sealSprite:getContentSize().height*g_fScaleX))
	--如果该位置开启并且有锦囊创建锦囊
		--没有锦囊创建闪烁加号
	local normalSprite  = nil
    local selectSprite  = nil
    local pocketItem = nil
	if(isOpen)then
		if(_havePocketTable[p_index]==true)then
			local temId = tonumber(_pocketTable[tostring(p_index)].item_template_id)
			normalSprite  = ItemSprite.getItemBigSpriteById(temId)
    		selectSprite  = ItemSprite.getItemBigSpriteById(temId)
    		pocketItem = CCMenuItemSprite:create(normalSprite,selectSprite)
    		pocketItem:setScale(0.7)

    		local pocketData = DB_Item_pocket.getDataById(temId)

    		local nameBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
				  nameBg:setPreferredSize(CCSizeMake(158, 37))
				  nameBg:setAnchorPoint(ccp(0.5, 0))
				  nameBg:setPosition(ccp(pocketItem:getContentSize().width*0.5,pocketItem:getContentSize().height+nameBg:getContentSize().height*0.5))
			tableSprite:addChild(nameBg,10)

			local nameColor = HeroPublicLua.getCCColorByStarLevel(pocketData.quality)
    		local pocketNameLabel = CCLabelTTF:create(pocketData.name,g_sFontPangWa,23)
    			  pocketNameLabel:setColor(nameColor)
    			  pocketNameLabel:setAnchorPoint(ccp(0.5,0.5))
    			  pocketNameLabel:setPosition(ccp(nameBg:getContentSize().width*0.5,nameBg:getContentSize().height*0.5))
    		nameBg:addChild(pocketNameLabel)
    		
    		local pocketLevelSprite = CCSprite:create("images/common/lv.png")
    			  pocketLevelSprite:setAnchorPoint(ccp(1,1))
    			  pocketLevelSprite:setPosition(ccp(tableSprite:getContentSize().width*0.5,0))
    		tableSprite:addChild(pocketLevelSprite)
    		
    		local pocketLevelLable = CCLabelTTF:create(_pocketTable[tostring(p_index)].va_item_text.pocketLevel,g_sFontName,20)
    			  pocketLevelLable:setAnchorPoint(ccp(0,1))
    			  pocketLevelLable:setPosition(ccp(tableSprite:getContentSize().width*0.5,0))
    		tableSprite:addChild(pocketLevelLable)

    		local sealSprite = BagUtil.getSealSpriteByItemTempId(_pocketTable[tostring(p_index)].item_template_id)
		    sealSprite:setAnchorPoint(ccp(0.5, 1))
		    sealSprite:setPosition(ccp(tableSprite:getContentSize().width*0.5, -pocketLevelLable:getContentSize().height))
		    tableSprite:addChild(sealSprite)
    		
			pocketItem:setPosition(ccp(640*0.25*p_index,_bottomBgSprite:getContentSize().height+pocketItem:getContentSize().height*0.5+75+sealSprite:getContentSize().height*g_fScaleX))

    		local upAction = CCMoveTo:create(1.5, ccp(pocketItem:getPositionX(),pocketItem:getPositionY()+10))
			local downAction = CCMoveTo:create(1.5, ccp(pocketItem:getPositionX(),pocketItem:getPositionY()-10))
			local actionArray = CCArray:create()
		    actionArray:addObject(upAction)
		    actionArray:addObject(downAction)
		    pocketItem:runAction(CCRepeatForever:create(CCSequence:create(actionArray)))
		else
			--添加按钮闪烁
			normalSprite  = CCSprite:create("images/formation/potential/newadd.png")
    		selectSprite  = CCSprite:create("images/formation/potential/newadd.png")
    		pocketItem = CCMenuItemSprite:create(normalSprite,selectSprite)

    		local arrActions_2 = CCArray:create()
				  arrActions_2:addObject(CCFadeOut:create(1))
				  arrActions_2:addObject(CCFadeIn:create(1))
			local sequence_2 = CCSequence:create(arrActions_2)
			local action_2 = CCRepeatForever:create(sequence_2)
			pocketItem:runAction(action_2)
			pocketItem:setPosition(ccp(640*0.25*p_index,_bottomBgSprite:getContentSize().height+pocketItem:getContentSize().height*0.5+115+sealSprite:getContentSize().height*g_fScaleX))
    	end
	else
		--未开启时状态
		normalSprite  = BTGraySprite:create("images/formation/potential/newadd.png")
    	selectSprite  = BTGraySprite:create("images/formation/potential/newadd.png")
    	pocketItem = CCMenuItemSprite:create(normalSprite,selectSprite)
    	pocketItem:setPosition(ccp(640*0.25*p_index,_bottomBgSprite:getContentSize().height+pocketItem:getContentSize().height*0.5+115+sealSprite:getContentSize().height*g_fScaleX))
	end
	return pocketItem
end

--卸下命令回来后的回调
function afterRemove( pChangeInfo,pAdd,pHid )
	-- 飞字属性下降了多少
	if(not table.isEmpty(pChangeInfo))then
		local tipArr = PocketData.removeAttrNumAndAtrrName(pChangeInfo,pAdd,pHid)
		LevelUpUtil.showFlyText(tipArr)
	end
end

function lockCallBack( ... )
	-- body
	local lockSprite = _bgSprite:getChildByTag(1):getChildByTag(_pLimitLevel[_pos]):getChildByTag(1000)
	lockSprite:setVisible(true)
	_worldPanel:setScale(0)
	_bgSprite:removeChildByTag(10,true)
	HeroModel.changeHeroPocketLockStatus(_formationInfo[_curHeroIndex],_pos)
	createFadeOutMenu()
	local temId = tonumber(_pocketTable[tostring(_pos)].item_template_id)
	local pocketData = DB_Item_pocket.getDataById(temId)
	AnimationTip.showTip( GetLocalizeStringBy("llp_259",pocketData.name) )
end

function unlockCallBack( ... )
	-- body
	local lockSprite = _bgSprite:getChildByTag(1):getChildByTag(_pLimitLevel[_pos]):getChildByTag(1000)
	lockSprite:setVisible(false)
	_worldPanel:setScale(0)
	_bgSprite:removeChildByTag(10,true)
	HeroModel.changeHeroPocketLockStatus(_formationInfo[_curHeroIndex],_pos)
	createFadeOutMenu()
	local temId = tonumber(_pocketTable[tostring(_pos)].item_template_id)
	local pocketData = DB_Item_pocket.getDataById(temId)
	AnimationTip.showTip( GetLocalizeStringBy("llp_260",pocketData.name) )
end

--装配 强化 卸下按钮回调
local function controlPocketItemCallBack(tag,sender)
	-- 更换按钮
	if(tag==_changeTag)then
		local layer = PocketChooseLayer.createLayer(nil,nil, _formationInfo[_curHeroIndex], _pos)
		MainScene.changeLayer(layer,"PocketChooseLayer")
	else
		--当前位置是否装配锦囊判断 没装备无法强化卸下
		if(_havePocketTable[_pos]==false)then
			AnimationTip.showTip( GetLocalizeStringBy("llp_241") )
		else
			if(tag==_lockTag)then
				local lockSprite = _bgSprite:getChildByTag(1):getChildByTag(_pLimitLevel[_pos]):getChildByTag(1000)
				if(not lockSprite:isVisible())then
					PocketService.lockPocket(_heroInfo.equip.pocket[tostring(_pos)].item_id,lockCallBack)
				else
					PocketService.unlockPocket(_heroInfo.equip.pocket[tostring(_pos)].item_id,unlockCallBack)
				end
			elseif(tag==_upgradeTag)then
				local pocketData = DB_Item_pocket.getDataById(tonumber(_heroInfo.equip.pocket[tostring(_pos)].item_template_id))
				local descArray = string.split(pocketData.level_effect,",")
				--最大等级提示
				if(tonumber(_heroInfo.equip.pocket[tostring(_pos)].va_item_text.pocketLevel)==tonumber(descArray[table.count(descArray)]))then
					AnimationTip.showTip(GetLocalizeStringBy("llp_247"))
					return
				end
				local layer = PocketUpgradeLayer.createPocketLayer(_heroInfo.equip.pocket[tostring(_pos)].item_id,nil,_formationInfo[_curHeroIndex])
	    		MainScene.changeLayer(layer,"PocketUpgradeLayer")
			elseif(tag==_removeTag)then
				--背包满
				if(ItemUtil.isPocketBagFull(true))then
					return
				end
				_pocketTable[tostring(_pos)] = _heroInfo.equip.pocket[tostring(_pos)]
				PocketController.removePocketCallback(_formationInfo[_curHeroIndex],_pos,_pocketTable[tostring(_pos)])
			end
		end
	end
end

function createFadeOutMenu()
	--子菜单背景
	_worldPanel = CCScale9Sprite:create("images/main/sub_icons/menu_bg.png")
	_worldPanel:setAnchorPoint(ccp(0.5, 0))
	_worldPanel:setScale(0)
	_bgSprite:addChild(_worldPanel,1,10)
	
	--子菜单背景上的按钮
	local colorMenu = CCMenu:create()
		  colorMenu:setTouchPriority(-1002)
		  colorMenu:setPosition(ccp(0, 0))
		  colorMenu:setAnchorPoint(ccp(0, 0))
	_worldPanel:addChild(colorMenu,3)
	_worldPanel:setContentSize(CCSizeMake(300,100))

	local normalImageTable = {"images/pocket/lock1.png","images/pocket/genghuan1.png","images/pocket/qianghua1.png","images/pocket/xiaxia.png"}
	local selectImageTable = {"images/pocket/lock1.png","images/pocket/genghuan2.png","images/pocket/qianghua2.png","images/pocket/xiaxia2.png"}
	if(_pocketTable[tostring(_pos)]~=nil and _pocketTable[tostring(_pos)].va_item_text~=nil and _pocketTable[tostring(_pos)].va_item_text.lock~=nil)then
		normalImageTable[1] = "images/pocket/unlock1.png"
		selectImageTable[1] = "images/pocket/unlock2.png"
	end
	--菜单上的按钮
	for i=1,4 do
		local colorButton = CCMenuItemImage:create(normalImageTable[i], selectImageTable[i])
			  colorButton:setAnchorPoint(ccp(0.5, 0.5))
			  colorButton:setPosition(ccp(_worldPanel:getContentSize().width*(0.18+(i-1)*0.22),_worldPanel:getContentSize().height*0.5))
			  colorButton:registerScriptTapHandler(controlPocketItemCallBack)
		colorMenu:addChild(colorButton,1,i)
	end

	--小三角
	_arrowSprite = CCSprite:create("images/common/arrow_panel.png")
	_arrowSprite:setAnchorPoint(ccp(0.5,1))
	_arrowSprite:setScale(-1)
	_bgSprite:addChild(_arrowSprite,1,190)
end 

--创建中间锦囊按钮Menu以及点击后弹出的菜单
local function createMiddleMenu()
	local pocketMenu = CCMenu:create()
		  pocketMenu:setPosition(ccp(0,0))
	_bgSprite:addChild(pocketMenu,1,1)

	--该位置是否开启table
	_pOpenTable = {}

    local normal_config = DB_Normal_config.getDataById(1)
    _pLimitLevel = string.split(normal_config.pocket_limit,",")

	_pocketNum = 3

	for i=1,_pocketNum do
		local isOpen = (tonumber(UserModel.getHeroLevel())>=tonumber(_pLimitLevel[i]))
		_pOpenTable[tonumber(_pLimitLevel[i])] = isOpen

		local getMenuItem = createPocketItem(isOpen,i)
			  getMenuItem:setAnchorPoint(ccp(0.5,0.5))
			  getMenuItem:registerScriptTapHandler(pocketMenuItemCallback)
			  getMenuItem.pos = i
			  getMenuItem.hid = _formationInfo[_curHeroIndex]
		pocketMenu:addChild(getMenuItem,1,tonumber(_pLimitLevel[i]))
		
		local lockSp= CCSprite:create("images/hero/lock.png")
			  lockSp:setScale(10/7)
			  lockSp:setAnchorPoint(ccp(0,0.5))
			  lockSp:setPosition(ccp(getMenuItem:getContentSize().width, getMenuItem:getContentSize().height*0.5))
		getMenuItem:addChild(lockSp,1,1000)
	end
	for i=1,3 do
		if(_pocketTable[tostring(i)]~=nil and _pocketTable[tostring(i)].va_item_text~=nil and _pocketTable[tostring(i)].va_item_text.lock~=nil)then
			pocketMenu:getChildByTag(_pLimitLevel[i]):getChildByTag(1000):setVisible(true)
		else
			pocketMenu:getChildByTag(_pLimitLevel[i]):getChildByTag(1000):setVisible(false)
		end
	end

	--创建点击锦囊后弹出的弹版
	createFadeOutMenu()
end

local function createArrtributeChangeDes( p_index,p_data,p_growdata,p_cell,pIndex,pSize,pPosY,pWidth )
	-- body
	local baseArr = string.split(p_data,"|")
	local growArr = string.split(p_growdata,"|")
	local attStr = DB_Affix.getDataById(tonumber(baseArr[1]))
	local attLabel = CCLabelTTF:create(attStr.sigleName.."+",g_sFontName,19)
		  attLabel:setAnchorPoint(ccp(0,0))
	
	local attDesLabel = CCLabelTTF:create(baseArr[2]+growArr[2]*(tonumber(_pocketTable[tostring(pIndex)].va_item_text.pocketLevel)),g_sFontName,19)
		  attLabel:addChild(attDesLabel,0,p_index)
	attDesLabel:setAnchorPoint(ccp(0,1))

	p_cell:addChild(attLabel,0,p_index)
	
	local p_width = 210
	local posHang,posLie = math.modf((p_index-1)/2)

	if(posLie==0.5)then
		attLabel:setPosition(ccp(pSize.width*0.2+pWidth+p_width,pPosY-posHang*attLabel:getContentSize().height))
	else
		attLabel:setPosition(ccp(pSize.width*0.2+pWidth,pPosY-posHang*attLabel:getContentSize().height))
	end
	
	attDesLabel:setPosition(ccp(attLabel:getContentSize().width,attLabel:getContentSize().height))
end

--锦囊附加状态cell
local function createCell( pIndex,pSize,pData )
	-- body
	local tCell = CCTableViewCell:create()

	local pocketData = nil
	if(not table.isEmpty(pData))then
		pocketData = DB_Item_pocket.getDataById(tonumber(pData.item_template_id))
	end

    local pocketnamelabel = nil
    if(not table.isEmpty(pData))then
    	local nameColor = HeroPublicLua.getCCColorByStarLevel(pocketData.quality)
        pocketnamelabel = CCLabelTTF:create(pocketData.name,g_sFontPangWa,25)
        pocketnamelabel:setColor(nameColor)
    else
        pocketnamelabel = CCLabelTTF:create(GetLocalizeStringBy("llp_230"),g_sFontPangWa,25)
        pocketnamelabel:setColor(ccc3(0xff,0xf6,0x00))
    end
    
    pocketnamelabel:setAnchorPoint(ccp(0.5,1))
    pocketnamelabel:setPosition(ccp(pSize.width*0.5,pSize.height))

    local leftLine = CCScale9Sprite:create("images/god_weapon/cut_line.png")
    	  leftLine:setAnchorPoint(ccp(1,0.5))
    	  leftLine:setPosition(ccp(pSize.width*0.5-pocketnamelabel:getContentSize().width,pSize.height-pocketnamelabel:getContentSize().height*0.5))
    tCell:addChild(leftLine)

    local rightLine = CCScale9Sprite:create("images/god_weapon/cut_line.png")
    	  rightLine:setScale(-1)
    	  rightLine:setAnchorPoint(ccp(1,0.5))
    	  rightLine:setPosition(ccp(pSize.width*0.5+pocketnamelabel:getContentSize().width,pSize.height-pocketnamelabel:getContentSize().height*0.5))
    tCell:addChild(rightLine)

    --锦囊名字
    local desLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_232"),g_sFontName,20)
    if(not table.isEmpty(pocketData) and pocketData~=nil)then
    	_havePocketTable[pIndex]=true

    	desLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_250").."：",g_sFontPangWa,20)
        desLabel:setPosition(ccp(pSize.width*0.2,pSize.height*0.25))
        desLabel:setColor(ccc3(0x51, 0xfb, 0xff))

        local sprite = CCSprite:create()
        	  sprite:setContentSize(desLabel:getContentSize())
        	  sprite:setAnchorPoint(ccp(0,0))
        	  sprite:setPosition(ccp(desLabel:getContentSize().width,desLabel:getContentSize().height))
        desLabel:addChild(sprite)

        --锦囊描述
        local descArray = string.split(pocketData.level_effect,",")
			local effectStr = nil
			for k,v in pairs(descArray) do
				local levelDescArray = string.split(v,"|")
				if(tonumber(pData.va_item_text.pocketLevel )>=tonumber(levelDescArray[1]))then
					effectStr = DB_Awake_ability.getDataById(levelDescArray[2])
					effectStr = effectStr.des
				end
			end

        local desLabel2 = CCLabelTTF:create(effectStr,g_sFontName,20)
        	  desLabel2:setAnchorPoint(ccp(0,1))
        	  desLabel2:setDimensions(CCSizeMake(340, 0))
        	  desLabel2:setHorizontalAlignment(kCCTextAlignmentLeft) 
        	  desLabel2:setPosition(ccp(0,0))
        sprite:addChild(desLabel2)

        local attLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_249").."：",g_sFontPangWa,20)
        	  attLabel:setPosition(ccp(pSize.width*0.2,pSize.height-pocketnamelabel:getContentSize().height-attLabel:getContentSize().height))
        	  attLabel:setColor(ccc3(124,252,0))
        tCell:addChild(attLabel)

        local baseArr = string.split(pocketData.baseAtt,",")
		local growArr = string.split(pocketData.growAtt,",")
		local baseNum = table.count(baseArr)
		for i=1,baseNum do
			createArrtributeChangeDes(i,baseArr[i],growArr[i],tCell,pIndex,pSize,attLabel:getPositionY(),attLabel:getContentSize().width)
		end
    else
    	_havePocketTable[pIndex]=false

    	desLabel:setColor(ccc3(0x99,0x99,0x99))
    	desLabel:setAnchorPoint(ccp(0.5,0.5))
    	desLabel:setPosition(ccp(pSize.width*0.5,pSize.height*0.5))
    end
    
    tCell:addChild(desLabel)
    tCell:addChild(pocketnamelabel)
    local pocketNameLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1149"),g_sFontName,20)
    return tCell
end

--[[
    @des    :创建tableView
    @param  :参数table
    @return :创建好的tableView
--]]
local function createTableView(p_param)
    local h = LuaEventHandler:create(function(fn,p_table,a1,a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(640, 165)
        elseif fn == "cellAtIndex" then
            a2 = createCell(a1+1,CCSizeMake(640, 150),_pocketTable[tostring(a1+1)])
            r = a2
        elseif fn == "numberOfCells" then
            r = _pocketNum
        else
        end

        return r
    end)

    local tableViewResult = LuaTableView:createWithHandler(h, CCSizeMake(640, 150*2))
    	  tableViewResult:setVerticalFillOrder(kCCTableViewFillTopDown)
    return(tableViewResult)
end
--更新下方tableview
function updateTableView( ... )
	-- body
	_pocketTable = {}
	_heroInfo = HeroModel.getHeroByHid(tostring(_formationInfo[_curHeroIndex]))

	for k,v in pairs(_heroInfo.equip.pocket) do
		_pocketTable[k]=v
	end

	_bottomBgSprite:removeChild(_pocketDesTableView,true)
	-- --创建tableView
    local paramTable = {}
    paramTable.bgSize = CCSizeMake(_bottomBgSprite:getContentSize().width,_bottomBgSprite:getContentSize().height-30*g_fScaleX)

    _pocketDesTableView = createTableView(paramTable)
    _pocketDesTableView:setAnchorPoint(ccp(0,0))
    _pocketDesTableView:setPosition(ccp(0,5))
    _pocketDesTableView:setTouchPriority(_pTouch - 2)
    _bottomBgSprite:addChild(_pocketDesTableView)
end

--刷新中间按钮
function updateMiddleMenu( ... )
	-- body
	_worldPanel:setScale(0)
	--删menu
	_bgSprite:removeChildByTag(1,true)
	for i=1,3 do
		--删除特效
		_bgSprite:removeChildByTag(100+i,true)
		_bgSprite:removeChildByTag(200+i,true)
	end
	createMiddleMenu()
end

-- 移动英雄
local function switchNextHero( xOffset )
	local nextHeroIndex = -1
	-- 变换英雄身相索引
	if(xOffset < 0) then
		if(_curHeroIndex <= #_formationInfo) then
			nextHeroIndex = _curHeroIndex+1
		end
	else
		if(_curHeroIndex >= 1) then
			nextHeroIndex = _curHeroIndex-1
		end
	end
	
	if(nextHeroIndex<0)then
		nextHeroIndex = 0
		_curAffixTable = FightForceModel.getHeroDisplayAffix(_formationInfo[nextHeroIndex])

		_heroInfo = HeroModel.getHeroByHid(tostring(_formationInfo[nextHeroIndex]))
		for k,v in pairs(_heroInfo.equip.pocket) do
			_pocketTable[k]=v
		end
		return
	elseif(nextHeroIndex > #_formationInfo)then
		nextHeroIndex = #_formationInfo
		_curAffixTable = FightForceModel.getHeroDisplayAffix(_formationInfo[nextHeroIndex])

		_heroInfo = HeroModel.getHeroByHid(tostring(_formationInfo[nextHeroIndex]))
		for k,v in pairs(_heroInfo.equip.pocket) do
			_pocketTable[k]=v
		end
		return
	end
	-- 存储变换后的锦囊信息
	_pocketTable = {}
	
	if( nextHeroIndex >= 0 and  nextHeroIndex <= #_formationInfo) then
		--存取变换后的英雄属性数据
		_curAffixTable = FightForceModel.getHeroDisplayAffix(_formationInfo[nextHeroIndex])

		_heroInfo = HeroModel.getHeroByHid(tostring(_formationInfo[nextHeroIndex]))
		for k,v in pairs(_heroInfo.equip.pocket) do
			_pocketTable[k]=v
		end

		local dressId = nil
		if HeroModel.isNecessaryHero(_heroInfo.htid) then
			dressId = UserModel.getDressIdByPos(1)
		end
		-- 新增幻化id, add by lgx 20160928
		local turnedId = tonumber(_heroInfo.turned_id)
		local nextHeroSprite = HeroUtil.getHeroBodySpriteByHTID(_heroInfo.htid, dressId, nil, turnedId)
			  nextHeroSprite:setScale(0.8)
			  nextHeroSprite:setAnchorPoint(ccp(0.5, 0))
		_bgSprite:addChild(nextHeroSprite)

		local bodyOffset = HeroUtil.getHeroBodySpriteOffsetByHTID(_heroInfo.htid, nil, turnedId)
		
		local curMoveToP = nil
		local nextMoveToP = ccp( _bgSprite:getContentSize().width * 0.5, _bgSprite:getContentSize().height * _scaleY-bodyOffset+50)
		local curPositionX = _curBodyImage:getPosition()
		if(xOffset<0)then
			curMoveToP = ccp( curPositionX -_bgSprite:getContentSize().width, _bgSprite:getContentSize().height * _scaleY-bodyOffset+50)
			nextHeroSprite:setPosition(curPositionX +_bgSprite:getContentSize().width, _bgSprite:getContentSize().height * _scaleY-bodyOffset+50)
		else
			curMoveToP = ccp(curPositionX + _bgSprite:getContentSize().width, _bgSprite:getContentSize().height * _scaleY-bodyOffset)
			nextHeroSprite:setPosition(curPositionX -_bgSprite:getContentSize().width, _bgSprite:getContentSize().height * _scaleY-bodyOffset+50)
		end
		_isOnAnimation = true
		-- 当前的武将移动
		_curBodyImage:runAction(CCMoveTo:create(0.2, curMoveToP))
		local actionArr = CCArray:create()
			  actionArr:addObject(CCMoveTo:create(0.2, nextMoveToP))
			  actionArr:addObject(CCDelayTime:create(0.1))
			  actionArr:addObject(CCCallFuncN:create(animatedEndAction))
		_curHeroIndex = nextHeroIndex
		if(_curHeroIndex==#_formationInfo)then
			_arrowLeft:setVisible(true)
			_arrowRight:setVisible(false)
		elseif(_curHeroIndex==0)then
			_arrowLeft:setVisible(false)
			_arrowRight:setVisible(true)
		else
			_arrowLeft:setVisible(true)
			_arrowRight:setVisible(true)
		end
		nextHeroSprite:runAction(CCSequence:create(actionArr))
		updateTableView()
		updateMiddleMenu()
	end
end

-- 创建英雄的全身像
local function createHeroSprite()
	-- 获取英雄信息
	_heroInfo = HeroModel.getHeroByHid(tostring(_formationInfo[_curHeroIndex]))

	-- 当前缓存锦囊数据
	_pocketTable = {}

	if(not table.isEmpty(_heroInfo.equip.pocket))then
		for k,v in pairs(_heroInfo.equip.pocket) do
			_pocketTable[k]=v
		end
	end
	--end
	-- 英雄身相
	local dressId = nil
	if HeroModel.isNecessaryHero(_heroInfo.htid) then
		dressId = UserModel.getDressIdByPos(1)
	end

	-- 新增幻化id, add by lgx 20160928
	local turnedId = tonumber(_heroInfo.turned_id)
	_curBodyImage = HeroUtil.getHeroBodySpriteByHTID(_heroInfo.htid, dressId, nil, turnedId)
	_curBodyImage:setScale(0.8)
	_curBodyImage:setAnchorPoint(ccp(0.5, 0))

	local bodyOffset = HeroUtil.getHeroBodySpriteOffsetByHTID(_heroInfo.htid, nil, turnedId)
	_curBodyImage:setPosition(ccp( _bgSprite:getContentSize().width * 0.5, _bgSprite:getContentSize().height*_scaleY-bodyOffset+50))
	_bgSprite:addChild(_curBodyImage)

	_arrowLeft= CCSprite:create("images/common/arrow_left.png")
	_arrowLeft:setPosition(ccp(0,_bgLayer:getContentSize().height*0.5)) 
	_arrowLeft:setAnchorPoint(ccp(0,0.5))
	_arrowLeft:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(_arrowLeft)

	_arrowRight = CCSprite:create("images/common/arrow_right.png")
	_arrowRight:setPosition(ccp(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height*0.5)) 
	_arrowRight:setAnchorPoint(ccp(1,0.5))
	_arrowRight:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(_arrowRight)

	if(_curHeroIndex==#_formationInfo)then
		_arrowLeft:setVisible(true)
		_arrowRight:setVisible(false)
	elseif(_curHeroIndex==0)then
		_arrowLeft:setVisible(false)
		_arrowRight:setVisible(true)
	else
		_arrowLeft:setVisible(true)
		_arrowRight:setVisible(true)
	end
	-- end
end

--初始化阵容信息
local function initFormationInfo( ... )
	-- body
	local index = 0
	local realIndex = 0
	local real_formation = DataCache.getSquad()

	for i = 1,table.count(real_formation) do
        if(tonumber(real_formation[tostring(i-1)]) >0 )then
            _formationInfo[i-1] = real_formation[tostring(i-1)]
        end
    end
    --判断传入的hid在什么位置
    for k,v in pairs(_formationInfo)do
    	if(v==tonumber(_realPos))then
    		_curHeroIndex = k
    		break
    	end
    end
end

--创建底边栏
local function createBottom( ... )
	local fullRect = CCRectMake(0,0,640,51)
	local insetRect = CCRectMake(314,27,13,6)
	_bottomBgSprite = CCScale9Sprite:create("images/god_weapon/view_bg.png",fullRect, insetRect)
	_bottomBgSprite:setPreferredSize(CCSizeMake(640,350))
	_bottomBgSprite:setScale(g_fBgScaleRatio)
	_bottomBgSprite:setAnchorPoint(ccp(0.5,0))
	_bottomBgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,0))
	_bgLayer:addChild(_bottomBgSprite)

	_downLabel = CCSprite:create("images/pocket/3.png")
	_downLabel:setAnchorPoint(ccp(0.5,0.5))
	_downLabel:setPosition(ccp(_bottomBgSprite:getContentSize().width*0.5,_bottomBgSprite:getContentSize().height-7*g_fScaleX))
	_bottomBgSprite:addChild(_downLabel)
	-- --创建锦囊属性和效果tableView
    local paramTable = {}
    paramTable.bgSize = CCSizeMake(_bottomBgSprite:getContentSize().width,_bottomBgSprite:getContentSize().height-_downLabel:getContentSize().height)
    _pocketDesTableView = createTableView(paramTable)
    _pocketDesTableView:setAnchorPoint(ccp(0,0))
    _pocketDesTableView:setPosition(ccp(0,5))
    _pocketDesTableView:setTouchPriority(_pTouch - 2)
    _bottomBgSprite:addChild(_pocketDesTableView)
end

--初始化阵容数据、创建滑动参照图、创建英雄身相
local function initInformationAndCreateHero()
	--初始化阵容数据
	initFormationInfo()

	--初始化英雄属性数据
	_curAffixTable = FightForceModel.getHeroDisplayAffix(_realPos)

	--创建滑动对照图片
	local fullRect = CCRectMake(0,0,75,75)
	local insetRect = CCRectMake(30,30,15,15)
	_attrSprite = CCScale9Sprite:create(Star_Img_Path .. "attr9s.png", fullRect, insetRect)
	_attrSprite:setContentSize(CCSizeMake(255, 350))
	_attrSprite:setAnchorPoint(ccp(0, 0.5))
	_attrSprite:setPosition(ccp( _bgSprite:getContentSize().width +  54*MainScene.elementScale , _bgSprite:getContentSize().height * 555/960))
	_attrSprite:setVisible(false)
	_bgSprite:addChild(_attrSprite, 10)

	--创建英雄身相
	createHeroSprite()

	--创建下边
	createBottom()

	--创建中间按钮
	createMiddleMenu()
end

local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
		_worldPanel:setScale(0)
		_bgSprite:removeChildByTag(10,true)
		createFadeOutMenu()
		_touchBeganPoint = ccp(x, y)
		local vPosition = _curBodyImage:convertToNodeSpace(_touchBeganPoint)
		if( not _isOnAnimation and vPosition.x>0 and vPosition.y>70 and vPosition.x < _curBodyImage:getContentSize().width and vPosition.y < _curBodyImage:getContentSize().height ) then
			local mPosition = _attrSprite:convertToNodeSpace(_touchBeganPoint)
			if( mPosition.x>0 and mPosition.y>70 and mPosition.x < _attrSprite:getContentSize().width and mPosition.y < _attrSprite:getContentSize().height)then
				return false
			else
				return true
			end
		else
			return false
	    end
    elseif (eventType == "moved") then
    else
    	local xOffset = x - _touchBeganPoint.x;
        if(math.abs(xOffset) > 10 and y>480*g_fElementScaleRatio)then
        	switchNextHero(xOffset)
        end
	end
end

local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _pTouch, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

local function closeAction( ... )
	-- body
    local formationLayer = FormationLayer.createLayer()
    MainScene.changeLayer(formationLayer, "formationLayer")
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
end

function showFlyLabel( pChangeInfo,pOldInfo )
	--闪特效
	local tipArr = nil
	if(not table.isEmpty(pChangeInfo) and pOldInfo==nil)then
		tipArr = PocketData.newAttrNumAndAtrrName(pChangeInfo)
	elseif(pOldInfo~=nil)then
		tipArr = PocketData.diffAttrNumAndAtrrName(pChangeInfo,pOldInfo)
	end
	if(tipArr)then
		LevelUpUtil.showFlyText(tipArr)
	end
end
--创建基础界面
function createBaseInterface( pCallBack )
	_bgSprite = CCSprite:create("images/pocket/normal.jpg")
	_bgSprite:setAnchorPoint(ccp(0.5,0.5))
	_bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	_bgSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(_bgSprite)
	
	local layerNameSprite = CCSprite:create("images/pocket/1.png")
		  layerNameSprite:setAnchorPoint(ccp(0,1))
		  layerNameSprite:setPosition(ccp(20*g_fElementScaleRatio,_bgLayer:getContentSize().height-20*g_fElementScaleRatio))
		  layerNameSprite:setScale(g_fElementScaleRatio)

	_bgLayer:addChild(layerNameSprite)
	
	-- 关闭按钮Menu
	local closeMenuBar = CCMenu:create()
		  closeMenuBar:setPosition(ccp(0, 0))

	_bgLayer:addChild(closeMenuBar)

	-- 关闭按钮Item
	local closeBtn = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
		  closeBtn:setScale(g_fElementScaleRatio)
		  closeBtn:setAnchorPoint(ccp(1, 1))
    	  closeBtn:setPosition(ccp(_bgLayer:getContentSize().width, _bgLayer:getContentSize().height))

    --如果没有回调自动跳转回阵容界面
    if(pCallBack~=nil)then
 		closeBtn:registerScriptTapHandler(pCallBack)
 	else
	    closeBtn:registerScriptTapHandler(closeAction)
	end

	closeMenuBar:addChild(closeBtn)

	-- 初始界面其余部分
	initInformationAndCreateHero()
end

function createLayer(pHid,pCallBack,pTouch,pZorder,pChangeInfo,pOldInfo)
	--确定跳转到哪个英雄
	_realPos = pHid

	_pTouch = pTouch or -127

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)

	MainScene.setMainSceneViewsVisible(false,false,false)

	_curHeroIndex = 0
	--创建基础界面 传入返回回调
	createBaseInterface(pCallBack)
	--装备新锦囊时飘字
	showFlyLabel(pChangeInfo,pOldInfo)

	return _bgLayer
end