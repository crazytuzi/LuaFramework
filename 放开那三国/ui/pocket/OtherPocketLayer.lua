-- FileName: PocketMainLayer.lua
-- Author:
-- Date: 2014-04-00
-- Purpose: 锦囊系统主显示界面

module ("OtherPocketLayer", package.seeall)

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

local _arrowLeft 			= nil
local _arrowRight 			= nil
local _totalInfo 			= nil
local _changeTag 			= 1
local _upgradeTag 			= 2
local _removeTag 			= 3
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

local _isOnAnimation 		= false	-- 是否正在滑动

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
	_totalInfo 				= nil
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
	_curAffixTable 			= {}
	_pOpenTable 			= {}
	_pocketTable 			= {}
	_pLimitLevel 			= {}
end

-- 动画结束
local function animatedEndAction( nextHeroSprite )
	_curBodyImage:removeFromParentAndCleanup(true)
	_curBodyImage = nextHeroSprite
	_isOnAnimation = false
end

--创建锦囊按钮
local function createPocketItem( isOpen,p_index )
	print("shengyixian")
	-- 桌子
	local tableSprite = CCSprite:create("images/pocket/ii.png")
		  tableSprite:setAnchorPoint(ccp(0.5,0.5))
		  tableSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.25*p_index,_bottomBgSprite:getContentSize().height+95))
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
	pocketEffect:setPosition(ccp(_bgSprite:getContentSize().width*0.25*p_index,_bottomBgSprite:getContentSize().height+95))

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
    		
			pocketItem:setPosition(ccp(640*0.25*p_index,_bottomBgSprite:getContentSize().height+pocketItem:getContentSize().height*0.5+90))

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
			pocketItem:setPosition(ccp(640*0.25*p_index,_bottomBgSprite:getContentSize().height+pocketItem:getContentSize().height*0.5+115))
    	end
	else
		--未开启时状态
		normalSprite  = BTGraySprite:create("images/formation/potential/newadd.png")
    	selectSprite  = BTGraySprite:create("images/formation/potential/newadd.png")
    	pocketItem = CCMenuItemSprite:create(normalSprite,selectSprite)
	end
	return pocketItem
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

	_pocketNum = table.count(_pLimitLevel)
	for i=1,_pocketNum do
		local isOpen = RivalInfoData.isPocketOpen()
		_pOpenTable[tonumber(_pLimitLevel[i])] = isOpen

		local getMenuItem = createPocketItem(isOpen,i)
			  getMenuItem:setAnchorPoint(ccp(0.5,0.5))
			  getMenuItem.pos = i
			  getMenuItem.hid = _totalInfo[_curHeroIndex]
		pocketMenu:addChild(getMenuItem,1,tonumber(_pLimitLevel[i]))
	end
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
        desLabel:setAnchorPoint(ccp(0,1))
        desLabel:setColor(ccc3(0x51, 0xfb, 0xff))

        local sprite = CCSprite:create()
        	  sprite:setContentSize(desLabel:getContentSize())
        	  sprite:setAnchorPoint(ccp(0,1))
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
        	  desLabel2:setAnchorPoint(ccp(0,0))
        	  print("realHeightCount===",math.ceil(desLabel2:getContentSize().width/375))
        	  local realHeight = desLabel2:getContentSize().height*(math.ceil(desLabel2:getContentSize().width/375))+(math.ceil(desLabel2:getContentSize().width/375)-1)*5
        	  desLabel2:setDimensions(CCSizeMake(375, realHeight))
        	  desLabel2:setHorizontalAlignment(kCCTextAlignmentLeft) 
        	  desLabel2:setPosition(ccp(pSize.width*0.2+desLabel:getContentSize().width,0))
        tCell:addChild(desLabel2)
        desLabel:setPosition(ccp(pSize.width*0.2,realHeight))
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
            a2 = createCell(a1+1,CCSizeMake(640, 165),_pocketTable[tostring(a1+1)])
            r = a2
        elseif fn == "numberOfCells" then
            r = _pocketNum
        else
        end

        return r
    end)

    local tableViewResult = LuaTableView:createWithHandler(h, CCSizeMake(640, 165*2))
    	  tableViewResult:setVerticalFillOrder(kCCTableViewFillTopDown)
    return(tableViewResult)
end
--更新下方tableview
function updateTableView( ... )
	-- body
	_pocketTable = {}
	_heroInfo = _totalInfo[_curHeroIndex]

	for k,v in pairs(_heroInfo.equipInfo.pocket) do
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
	--删menu
	_bgSprite:removeChildByTag(1,true)
	for i=1,_pocketNum do
		--删除特效
		_bgSprite:removeChildByTag(100+i,true)
		_bgSprite:removeChildByTag(200+i,true)
	end
	createMiddleMenu()
end

-- 移动英雄
local function switchNextHero( xOffset )
	if(_isOnAnimation==true)then
		return
	end
	local nextHeroIndex = 1
	-- 变换英雄身相索引
	if(xOffset < 0) then
		if(_curHeroIndex < #_totalInfo) then
			nextHeroIndex = _curHeroIndex+1
		else
			return
		end
	else
		if(_curHeroIndex > 1) then
			nextHeroIndex = _curHeroIndex-1
		else
			nextHeroSprite = 1
			return
		end
	end
	if(nextHeroIndex<0)then
		nextHeroIndex = 0
		_curAffixTable = FightForceModel.getHeroDisplayAffix(_totalInfo[nextHeroIndex])

		_heroInfo = HeroModel.getHeroByHid(tostring(_totalInfo[nextHeroIndex]))
		for k,v in pairs(_heroInfo.equip.pocket) do
			_pocketTable[k]=v
		end
		return
	elseif(nextHeroIndex > #_totalInfo)then
		nextHeroIndex = #_totalInfo
		_curAffixTable = FightForceModel.getHeroDisplayAffix(_totalInfo[nextHeroIndex])

		_heroInfo = HeroModel.getHeroByHid(tostring(_totalInfo[nextHeroIndex]))
		for k,v in pairs(_heroInfo.equip.pocket) do
			_pocketTable[k]=v
		end
		return
	end
	-- 存储变换后的锦囊信息
	_pocketTable = {}
	if( nextHeroIndex >= 0 and  nextHeroIndex <= #_totalInfo) then
		--存取变换后的英雄属性数据
		_heroInfo = _totalInfo[nextHeroIndex]
		for k,v in pairs(_heroInfo.equipInfo.pocket) do
			_pocketTable[k]=v
		end

		local dressId = nil
		if(not table.isEmpty( _heroInfo.dress) and tonumber(_heroInfo.dress["1"])~=0)then
			dressId = tonumber(_heroInfo.dress["1"])
		end	
		-- 新增幻化id, add by lgx 20160928
		local turnedId = tonumber(_heroInfo.turned_id)
		local nextHeroSprite = HeroUtil.getHeroBodySpriteByHTID(_heroInfo.htid, dressId, nil, turnedId)
			  nextHeroSprite:setScale(0.8)
			  nextHeroSprite:setAnchorPoint(ccp(0.5, 0))
		_bgSprite:addChild(nextHeroSprite)

		local bodyOffset = HeroUtil.getHeroBodySpriteOffsetByHTID(_heroInfo.htid, nil, turnedId)
		
		local curMoveToP = nil
		local nextMoveToP = ccp( _bgSprite:getContentSize().width * 0.5, _bgSprite:getContentSize().height * _scaleY-bodyOffset)
		local curPositionX = _curBodyImage:getPosition()
		if(xOffset<0)then
			curMoveToP = ccp( curPositionX -_bgSprite:getContentSize().width, _bgSprite:getContentSize().height * _scaleY-bodyOffset)
			nextHeroSprite:setPosition(curPositionX +_bgSprite:getContentSize().width, _bgSprite:getContentSize().height * _scaleY-bodyOffset)
		else
			curMoveToP = ccp(curPositionX + _bgSprite:getContentSize().width, _bgSprite:getContentSize().height * _scaleY-bodyOffset)
			nextHeroSprite:setPosition(curPositionX -_bgSprite:getContentSize().width, _bgSprite:getContentSize().height * _scaleY-bodyOffset)
		end
		_isOnAnimation = true
		-- 当前的武将移动
		_curBodyImage:runAction(CCMoveTo:create(0.2, curMoveToP))
		local actionArr = CCArray:create()
			  actionArr:addObject(CCMoveTo:create(0.2, nextMoveToP))
			  actionArr:addObject(CCDelayTime:create(0.1))
			  actionArr:addObject(CCCallFuncN:create(animatedEndAction))
		_curHeroIndex = nextHeroIndex
		if(_curHeroIndex==#_totalInfo)then
			_arrowLeft:setVisible(true)
			_arrowRight:setVisible(false)
		elseif(_curHeroIndex==1)then
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
	_heroInfo = _totalInfo[_curHeroIndex]

	-- 当前缓存锦囊数据
	_pocketTable = {}

	for k,v in pairs(_heroInfo.equipInfo.pocket) do
		_pocketTable[k]=v
	end
	--end
	-- 英雄身相
	local dressId = nil
	if(not table.isEmpty( _heroInfo.dress) and tonumber(_heroInfo.dress["1"])~=0)then
		dressId = tonumber(_heroInfo.dress["1"])
	end	
	
	-- 新增幻化id, add by lgx 20160928
	local turnedId = tonumber(_heroInfo.turned_id)
	_curBodyImage = HeroUtil.getHeroBodySpriteByHTID(_heroInfo.htid, dressId, nil, turnedId)
	_curBodyImage:setScale(0.8)
	_curBodyImage:setAnchorPoint(ccp(0.5, 0))

	local bodyOffset = HeroUtil.getHeroBodySpriteOffsetByHTID(_heroInfo.htid, nil, turnedId)
	_curBodyImage:setPosition(ccp( _bgSprite:getContentSize().width * 0.5, _bgSprite:getContentSize().height*_scaleY-bodyOffset))
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

	if(_curHeroIndex==#_totalInfo)then
			_arrowLeft:setVisible(true)
			_arrowRight:setVisible(false)
		elseif(_curHeroIndex==1)then
			_arrowLeft:setVisible(false)
			_arrowRight:setVisible(true)
		else
			_arrowLeft:setVisible(true)
			_arrowRight:setVisible(true)
		end
	-- end
end

--创建底边栏
local function createBottom( ... )
	local fullRect = CCRectMake(0,0,640,51)
	local insetRect = CCRectMake(314,27,13,6)
	_bottomBgSprite = CCScale9Sprite:create("images/god_weapon/view_bg.png",fullRect, insetRect)
	_bottomBgSprite:setPreferredSize(CCSizeMake(640,370))
	_bottomBgSprite:setScale(g_fBgScaleRatio)
	_bottomBgSprite:setAnchorPoint(ccp(0.5,0))
	_bottomBgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,0))
	_bgLayer:addChild(_bottomBgSprite)

	_downLabel = CCSprite:create("images/pocket/3.png")
	_bottomBgSprite:addChild(_downLabel)
	_downLabel:setAnchorPoint(ccp(0.5,0.5))
	_downLabel:setPosition(ccp(_bottomBgSprite:getContentSize().width*0.5,_bottomBgSprite:getContentSize().height-10*g_fScaleX))

	-- --创建锦囊属性和效果tableView
    local paramTable = {}
    paramTable.bgSize = CCSizeMake(_bottomBgSprite:getContentSize().width,_bottomBgSprite:getContentSize().height-30*g_fScaleX)
    _pocketDesTableView = createTableView(paramTable)
    _pocketDesTableView:setAnchorPoint(ccp(0,0))
    _pocketDesTableView:setPosition(ccp(0,5))
    _pocketDesTableView:setTouchPriority(_pTouch - 2)
    _bottomBgSprite:addChild(_pocketDesTableView)
end

--初始化阵容数据、创建滑动参照图、创建英雄身相
local function initInformationAndCreateHero()
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
        if(math.abs(xOffset) > 10)then
        	switchNextHero(xOffset)
        end
	end
end

local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -102000, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

local function closeAction( ... )
	-- body
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
end

--创建基础界面
function createBaseInterface()
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
  
	closeBtn:registerScriptTapHandler(closeAction)
	closeMenuBar:setTouchPriority(-1020001)
	closeMenuBar:addChild(closeBtn)

	-- 初始界面其余部分
	initInformationAndCreateHero()
end

function createLayer(pIndex,pInfo,pTouch,pZorder)
	--确定跳转到哪个英雄
	_totalInfo = pInfo
	_pTouch = pTouch or -102000

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)

	MainScene.setMainSceneViewsVisible(false,false,false)

	_curHeroIndex = pIndex
	--创建基础界面 传入返回回调
	createBaseInterface()

	return _bgLayer
end

function showLayer( pIndex,pInfo,pTouch,pZorder )
	print("~~~~~~~~")
	print_t(pInfo)
	print("~~~~~~~~")
	-- body
	local layer = createLayer(pIndex,pInfo,pTouch,pZorder)
	local runing_scene = CCDirector:sharedDirector():getRunningScene()
	runing_scene:addChild(layer,pZorder)
end