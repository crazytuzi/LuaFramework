-- Filename: RivalInfoLayer.lua.
-- Author: zhz
-- Date: 2013-10-22
-- Purpose: 查看对手阵容的信息的layer

module ("RivalInfoLayer", package.seeall)
require "script/audio/AudioUtil"
require "script/network/RequestCenter"
require "script/ui/hero/HeroPublicCC"
require "script/ui/hero/HeroFightSimple"
require "db/DB_Heroes"
require "script/ui/item/ItemSprite"
require "script/ui/tip/AnimationTip"
require "script/model/DataCache"
require "script/model/hero/HeroModel"
require "script/model/utils/HeroUtil"
require "script/ui/active/RivalInfoData"
require "script/ui/active/RivalAttrFriendLayer"
require "script/ui/active/RivalPillLayer"
require "script/ui/pocket/OtherPocketLayer"
local _maskLayer
local _bgLayer 						-- 灰色的layer
local _rivalInfoLayer= nil
local _topSprite					-- 顶部的sprite，显示玩家姓名
local _headBgSp						-- 显示玩家的头像
local _formationBgSprite			-- 图的背景
local _tname						-- 用户的姓名go
local _vip							--用户的VIP等级
local _titleId 						--用户的称号ID
local _titleEffect					--用户的称号特效/图片
local topBgSp                       --顶部scrollview背景

-- 上面的ui
local _rivalName					-- 玩家的姓名
local _headScrowView				-- 头像的scrowView
local _allHeroScrowView				-- 全身像的ScrowView
local _formationInfo = {}			--阵容信息
local _topHeroArr

-- Middle UI , 装备
-- 后端传得装备  武器[1，戒指2，护甲3，头盔4，项链5 锁6， 宝物：1是名马  2是名书
-- 后端传得戒指和锁不显示   

local _equiptArr={}					--装备的数组
local _equipBorderArr={}			--装备的底板
local _fightSoulNameArr
local _fightSoulBorderArr
local _fightSoulArr
local _equipNameArr={}

local _touchBeganPoint				-- 开始触摸的点
local _touchLastPoint               -- 上一次触摸点
local  _isOnAnimation				-- 是否正在滑动
local _curHeroSprite				-- 当前显示的英雄的全身像
local _leftHeroSprite
local _rightHeroSprite
local _curHeroItem					--当前显示英雄的按钮
local _count						-- 英雄的数量
local _uid							--  英雄的uid
local _curIndex						-- 英雄的index
local _leftIndex
local _rightIndex
local _lastIndex
-- local _containerLayer				-- 
local _curCardSize=nil

-- 底部的ui
local _heroNameLabel				-- 英雄的姓名
local _evolveLevelLabel				-- 英雄的转生次数
local _levelLabel					-- 等级
local _fightForceLabel				-- 战斗力
local _lifeLabel					-- 生命
local _attLabel						-- 攻击力	
local _phyDefLabel					-- 物理防御
local _magDefLabel					-- 魔法防御
local _skillLabelArr 				-- 6个羁绊label

local _equipMenuNode
local _equipMenuOriginPosition

local _tagArray   --根据顶端icon的index（即第几个icon） 来获取icon被加入menu时设定的的tag的数组
local _indexArray --根据顶端icon的tag（即被加入menu时设定的的tag） 来获取icon的index(即是当前第几个icon)的数组
----------------------- below is for 小伙伴 ---------------------
local _ksTagFriend 							= 1001 			-- 点击小伙伴的头像的tag
local _littleFriendLayerOriginPosition 
local _isInLittleFriend

local  _inType 								-- 1, 正常得阵容界面，2 ，为小伙伴， 3为宠物, 4为阵法 5为第二套小伙伴


----------------------- below is for 宠物 -----------------------
local _ksTagPet							  = 1002
local _petLayerOriginPosition		


---
local _isNpc					-- 是否为NPc

local _menuVisible
local _avatarVisible
local _bulletinVisible

local _curHeroOffset = nil
local _leftHeroOffset = nil
local _rightHeroOffset = nil

-------------------------------阵法---------------------------------------
local _layerData = nil
local _kDirection = { left = 1, right = 2}


local _ksTagPolicy = 1003             -- 点击阵容的图标的tag
--local xxxx = 1004                   --tag 需连续，且大于1003
-----------------------------神兵相关  add by DJN 2014/12/24---------------------
local _f_godweaponBtn = nil          --神兵按钮
local God_TYPE_1 					= 1   -- 神兵1
local God_TYPE_2 					= 2   -- 神兵2
local God_TYPE_3 					= 3   -- 神兵3
local God_TYPE_4 					= 4   -- 神兵4 
local God_TYPE_5					= 5	  -- 神兵5  
local godWeaponPositions = { God_TYPE_1, God_TYPE_2, God_TYPE_3, God_TYPE_4 ,God_TYPE_5} 
local _equipGodWeaponMenu 			= nil -- 5个神兵按钮menu
local _godweaponBtnTable            = {}  -- 5个神兵按钮
---------------------------------------------------------------------------------
--local _menuItemTouchPriority = nil
-----------------------------第二套小伙伴  add by DJN 2014/3/18---------------------
local _ksTagAttrFriend              = 1004 --第二套小伙伴
local _isInAttrLittleFriend
local _secondFriendLayer
---------------------------------------------------------------------------------
----------------------------丹药 -------------------------------------------------
local _f_pillBtn            --丹药入口按钮
------------------------------------------------------------------------------------ 
---------------------------锦囊 --------------------------------------------------
local _f_pocketBtn          --锦囊入口按钮
------------------------------------------------------------------------------------ 
---------------------------兵符--------------------------------------------------
local _f_tallyBtn           --兵符入口按钮
------------------------------------------------------------------------------------ 
-- 战车 --
local _ksTagChariot = 1005 	-- 战车
local _isInChariot	= nil 	-- 是否在战车界面
local _chariotLayer = nil 	-- 战车界面
local kChariotType	= 6		-- 战车类型def

--战魂位置
local _fightSoulPosTable = { {1,3,5,7,9} , {2,4,6,8,10} } 
local _fightSoulViewTab = {}
local _fightSoulOffsetTab = {}
local tagUp = 998
local tagDown = 999

local _scrollOffset = nil
local _leftSoulTableView --左侧战魂tableview
local _rightSoulTableView
local _fightSoulVisiable --当前战魂是否可见

function init( )
	_maskLayer =nil
	_bgLayer = nil
	_count = 0 
	_topHeroArr= {}
	_topSprite = nil
	topBgSp = nil
	_evolveLevelLabel= nil
	_levelLabel =nil
	_rivalInfoLayer = nil
	_headBgSp = nil 
	_formationBgSprite = nil
	_formationInfo = {}
	_curIndex = 1
	_skillLabelArr= {}
	_equiptArr= {}
	_equipBorderArr={}
	_equipNameArr={}
	_fightSoulBorderArr= {}
	_fightSoulArr={}
	_fightSoulNameArr= {}
	_isOnAnimation= false
	_curCardSize	= CCSizeMake(6400, 620)
	_headScrowView =nil
	_allHeroScrowView = nil
	_isNpc = false
	_menuVisible= MenuLayer.getObject():isVisible()
	_avatarVisible= MainScene.getAvatarLayerObj():isVisible()
	_bulletinVisible= MainScene.isBulletinVisible()
	_equipMenuNode = nil
	_equipMenuOriginPosition=nil
	_littleFriendLayerOriginPosition= nil
	_isInLittleFriend = nil
	_inType =1
	_lastIndex=1
	_petLayerOriginPosition= nil
	_vip 	= 0
	_titleId = 0
	_titleEffect = nil
	_curHeroOffset = nil
	_leftHeroSprite = nil
	_rightHeroSprite = nil
	_leftHeroOffset = nil
	_rightHeroOffset = nil
	_leftIndex = nil
	_rightIndex = nil
	---------------阵法----------------
	_layerData = {
		[_ksTagPolicy] = { 
			layer = nil,
			-- doShowFunc = doOpenPolicy,
			doShowFunc = RivalInfoData.shouldShowWarcraft
		},
	}

	_f_godweaponBtn = nil

	_equipGodWeaponMenu 			= nil
	_godweaponBtnTable              = {}

	_isInAttrLittleFriend           = nil

	_tagArray = {}
	_indexArray = {}
	_secondFriendLayer = nil
	_f_pillBtn = nil
	_leftSoulTableView = nil
	_rightSoulTableView = nil
	_fightSoulVisiable = false

	_f_pocketBtn = nil
	_f_tallyBtn = nil
	_newBtnTable = {}
end

function getBtnFromTable( pIndex )
	return _newBtnTable[pIndex]
end

function addBtnToTable( pBtn,pIndex )
	_newBtnTable[pIndex] = pBtn
end
local function createTopUI( )
	topBgSp = CCSprite:create("images/formation/topbg.png")
	topBgSp:setAnchorPoint(ccp(0.5,1))
	topBgSp:setPosition(ccp(_formationBgSprite:getContentSize().width/2, _formationBgSprite:getContentSize().height- 25))
	_formationBgSprite:addChild(topBgSp,2)

	local _titileSprite = CCSprite:create("images/common/title_bg.png")
	-- _titileSprite:setScale(g_fScaleX/g_fElementScaleRatio)
	_titileSprite:setPosition(ccp(0, _formationBgSprite:getContentSize().height))
	_titileSprite:setAnchorPoint(ccp(0,1))
	_formationBgSprite:addChild(_titileSprite,2)

    local topMenuBar = CCMenu:create()
    topMenuBar:setPosition(ccp(0, 0))
    topBgSp:addChild(topMenuBar)

	--左右翻页的按钮
	require "script/ui/common/LuaMenuItem"
	--左按钮
	local leftBtn = LuaMenuItem.createItemImage("images/formation/btn_left.png",  "images/formation/btn_left.png", topMenuItemAction )
	leftBtn:setAnchorPoint(ccp(0.5, 0.5))
	leftBtn:setPosition(ccp(topBgSp:getContentSize().width*0.06, topBgSp:getContentSize().height/2))
	topMenuBar:addChild(leftBtn, 10001, 10001)
	-- 右按钮
	local rightBtn = LuaMenuItem.createItemImage("images/formation/btn_right.png",  "images/formation/btn_right.png", topMenuItemAction )
	rightBtn:setAnchorPoint(ccp(1, 0.5))
	rightBtn:setPosition(ccp(topBgSp:getContentSize().width*0.96, topBgSp:getContentSize().height/2))
	topMenuBar:addChild(rightBtn, 10002, 10002)


	-- 关闭按钮
	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(-1000)
	_formationBgSprite:addChild(menu,4)
	local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeBtn:setAnchorPoint(ccp(1,1))
	closeBtn:setPosition(ccp(_formationBgSprite:getContentSize().width*1.01, _formationBgSprite:getContentSize().height*1.01))
	closeBtn:registerScriptTapHandler(closeCb)
	menu:addChild(closeBtn)
end

-- 刷新顶部的ui
function refreshTopUI(  )
	--计算顶部的offset
	local topTableViewOffset= _headScrowView:getContentOffset()
	local cellSize = CCSizeMake(125, 100)
	local curStartPositon = (1-_curIndex) * cellSize.width
	local curEndPosition = (-_curIndex) * cellSize.width
	if(curStartPositon > topTableViewOffset.x) then
		_headScrowView:setContentOffsetInDuration(ccp( curStartPositon , 0), 0.2)
	elseif (curEndPosition < topTableViewOffset.x - 4 * cellSize.width ) then
		_headScrowView:setContentOffsetInDuration(ccp( - ( _curIndex - 4 )*cellSize.width , 0), 0.2)
	end

	handleUnseletced(_curHeroItem)
	_curHeroItem= _topHeroArr[_curIndex]
	hanleSelected(_curHeroItem)
end
--刷新丹药按钮
function refreshPillBtn( ... )
	if _formationInfo[_curIndex] ~= nil then
		if _formationInfo[_curIndex].localInfo == nil then
		 	_formationInfo[_curIndex].localInfo = HeroUtil.getHeroLocalInfoByHtid(_formationInfo[_curIndex].htid)
		end
		
		if _formationInfo[_curIndex].localInfo.potential >= 5 and
		 (tonumber(_formationInfo[_curIndex].evolve_level) >= 1 or _formationInfo[_curIndex].localInfo.star_lv >= 6 ) then
			_f_pillBtn:setVisible(true)
		else
			_f_pillBtn:setVisible(false)
		end
	else
		_f_pillBtn:setVisible(false)
	end

end
--刷新锦囊按钮
function refreshPocketBtn( ... )
	local visible = RivalInfoData.isPocketOpen()
	setPocketVisible(visible)
end
--刷新兵符按钮
function refreshTallyBtn( ... )
	local visible = RivalInfoData.isTallyOpen()
	setTallyVisible(visible)
end

function refreshDestinyBtn( ... )
	local visible = RivalInfoData.isDestinyOpen(_formationInfo[_curIndex],_formationInfo)
	print("visible====",visible)
	setDestinyVisible(visible)
end
-- 处理点击headSorite 的回调函数
local function headItemCallBack( tag,item )
	
	if(_isOnAnimation == true) then
		return
	end
	-- handleUnseletced(_curHeroItem)
	-- _curHeroItem = item
	-- hanleSelected(_curHeroItem)

	local curTag = getTagByIndex(_curIndex)
	--if(_curIndex == tag) then
	if(curTag == tag) then
		return
	end

	local nextType = nil
	if tag <= #_formationInfo then
		--点击阵容中武将头像时
		nextType = 1
	elseif(tag== _ksTagFriend) then
		-- moveFormationOrLittleFriendAnimated( true, true)
		nextType = 2
	elseif(tag== _ksTagPet ) then
		-- moveFriendOrPetAnimated(true,true)
		nextType = 3
	elseif(tag == _ksTagPolicy)then
		--tag >= 1003
		nextType = 4
	elseif(tag == _ksTagAttrFriend)then
	    --add by DJN 第二套小伙伴，不能通过滑动来切入，只能通过顶端的按钮点入 无nextType一说
	    --print("点击了第二套小伙伴")
	elseif(tag == _ksTagChariot)then
		-- 点击战车item
		nextType = kChariotType
	end

	local direction = (tag - curTag) > 0 and _kDirection.left or _kDirection.right	
	moveLayerOut( _inType, nextType, curTag, true, direction )

    if(tag ~= _ksTagAttrFriend)then
		moveLayerIn(nextType, tag, true)		
		if(curTag == _ksTagAttrFriend)then
			--add by DJN 对第二套小伙伴的消除写在这里
			if(_secondFriendLayer ~= nil)then
				_secondFriendLayer:removeFromParentAndCleanup(true)
				_secondFriendLayer = nil
			end
		end
	elseif(tag == _ksTagAttrFriend)then 
	    updateInData(5,_ksTagAttrFriend) 
	    _isOnAnimation = false	
	    --创建第二套小伙伴的界面
	    --local myScale = _formationBgSprite:getContentSize().width/topBgSp:getContentSize().width
		_secondFriendLayer = RivalAttrFriendLayer.createSecondFriendLayer(_formationBgSprite:getContentSize().width, (_formationBgSprite:getContentSize().height-(topBgSp:getContentSize().height + 20 )))
		--_secondFriendLayer:setScale(1/MainScene.elementScale)
		_secondFriendLayer:ignoreAnchorPointForPosition(false)
		_secondFriendLayer:setAnchorPoint(ccp(0.5,0))
		_secondFriendLayer:setPosition(ccp(_formationBgSprite:getContentSize().width*0.5,0))
		_formationBgSprite:addChild(_secondFriendLayer,100)
		
    end
	-- refreshTopUI()
end

-- 通过武将的信息获得英雄的全身像 和全身像的偏移量
function getHeroSopriteByInfo( formationInfo )
	local iconName= nil
	local dressId= nil
	-- if(not table.isEmpty( formationInfo.equipInfo.dress) and not table.isEmpty(formationInfo.equipInfo.dress["1"]))then
	-- 	dressId = tonumber(formationInfo.equipInfo.dress["1"].item_template_id)
	-- end	


	if formationInfo.dress ~= nil then
		dressId = tonumber(formationInfo.dress["1"])
	end	

	-- 新增幻化id, add by lgx 20160928
	local turnedId = tonumber(formationInfo.turned_id)
	local heroSprite = HeroUtil.getHeroBodySpriteByHTID(tonumber(formationInfo.htid),dressId, nil, turnedId )

	-- 全身像偏移量
	local offset = HeroUtil.getHeroBodySpriteOffsetByHTID(tonumber(formationInfo.htid),dressId, turnedId )

	return heroSprite,offset
	
end

function getHeroHeadIcon( formationInfo )
	local htid= nil
	local dressId = nil
	-- print_t(formationInfo)
	-- if(not table.isEmpty( formationInfo.equipInfo.dress) and not table.isEmpty(formationInfo.equipInfo.dress["1"]))then
	-- 	dressId = tonumber(formationInfo.equipInfo.dress["1"].item_template_id)
	-- end	


	if formationInfo.dress ~= nil then
	 	dressId = tonumber(formationInfo.dress["1"])
	end	

	-- 新增幻化id, add by lgx 20160928
	local turnedId = tonumber(formationInfo.turned_id)
	local headIcon = HeroUtil.getHeroIconByHTID(tonumber(formationInfo.htid),dressId ,nil , _vip , turnedId)
	local headItem= CCMenuItemSprite:create(headIcon, headIcon)

	return headItem
end

function getHeroInfoByFormation(formationInfo )
	local heroLocalInfo = nil
	-- if(not table.isEmpty( formationInfo.equipInfo.dress) and not table.isEmpty(formationInfo.equipInfo.dress["1"]))then
	-- 	local dressInfo = ItemUtil.getItemById(tonumber(formationInfo.equipInfo.dress["1"].item_template_id))
	-- 	heroLocalInfo = DB_Heroes.getDataById(getStringByFashionString(dressInfo.changeModel, formationInfo.htid))
	-- else
	-- 	heroLocalInfo = DB_Heroes.getDataById(tonumber(formationInfo.htid))		
	-- end	


	if formationInfo.dress ~= nil then
		local dressInfo = ItemUtil.getItemById(tonumber(formationInfo.dress["1"]))
		heroLocalInfo = DB_Heroes.getDataById(getStringByFashionString(dressInfo.changeModel, formationInfo.htid))
	else
		heroLocalInfo = DB_Heroes.getDataById(tonumber(formationInfo.htid))		
	end	

	return heroLocalInfo
end

-- 创建初始化的图片
function createHeroSprite(  )
	local heroSprite,heroOffset = getHeroSopriteByInfo(_formationInfo[1] )
	heroSprite:setPosition(ccp(_formationBgSprite:getContentSize().width/2,200-heroOffset))
	heroSprite:setAnchorPoint(ccp(0.5,0))
	_formationBgSprite:addChild(heroSprite)
	_curHeroSprite = heroSprite
	_curHeroOffset = heroOffset
	_index = 1

	if _formationInfo[2] ~= nil then
		_rightHeroSprite, _rightHeroOffset = getHeroSopriteByInfo(_formationInfo[2] )
		_rightIndex = 2
		_rightHeroSprite:setPosition(ccp(_formationBgSprite:getContentSize().width*1.5,200-_rightHeroOffset))
		_rightHeroSprite:setAnchorPoint(ccp(0.5,0))
		_formationBgSprite:addChild(_rightHeroSprite)
	end
end


--处理selected函数的方法
function hanleSelected(Item)
	Item:selected()
	Item:getChildByTag(33):setVisible(true)
	--Item:addChild(csFrame,-1,33)
end

-- 处理unseletded
function handleUnseletced(preSeletced )
	preSeletced:unselected()
	preSeletced:getChildByTag(33):setVisible(false)
end


-- 创建头像ui
local function createHeadUI( )

	local width ,height = 125*(#_formationInfo),145

	if(RivalInfoData.hasFriend() ) then
		width = width+ 125
	end
	if( RivalInfoData.hasPet() ) then
		width = width+125
	end
	if( RivalInfoData.hasAttrFriend() ) then
		width = width+125
	end
	-- 添加战车
	if (RivalInfoData.isChariotOpen()) then
		width = width+125
	end

	--
	local count = 1003
	while _layerData[count] ~= nil do
		if _layerData[count].doShowFunc() then
			width = width+125
		end
		count = count + 1
	end

	local index = #_formationInfo 

	_headScrowView = CCScrollView:create()
	_headScrowView:setTouchPriority(-1005)

    _headScrowView:setContentSize(CCSizeMake(width , height))
    _headScrowView:setViewSize(CCSizeMake(505,height))
    _headScrowView:setPosition(66,620)
    _headScrowView:setDirection(kCCScrollViewDirectionHorizontal)
    _headScrowView:setContentOffset(ccp(0,0))
    _formationBgSprite:addChild(_headScrowView,10,2000)

    local headMenu = CCMenu:create()
    headMenu:setPosition(ccp(0,0))
    headMenu:setTouchPriority(-1003)
    -- headMenu:setScrollView(_headScrowView)
    _headScrowView:addChild(headMenu,-1)

    for i =1, #_formationInfo do 
		local menuItem = getHeroHeadIcon(_formationInfo[i]) --HeroPublicCC.getCMISHeadIconByHtid(_formationInfo[i].htid)
		headMenu:addChild(menuItem,1,i)
		menuItem:setAnchorPoint(ccp(0,0.5))
		menuItem:setPosition(ccp(125*(i-1) , _headScrowView:getContentSize().height/2))
		menuItem:registerScriptTapHandler(headItemCallBack)

		local sQualityLightedImg="images/hero/quality/highlighted.png"
		local csFrame = CCSprite:create(sQualityLightedImg)
		csFrame:setAnchorPoint(ccp(0.5, 0.5))
		csFrame:setPosition(menuItem:getContentSize().width/2, menuItem:getContentSize().height/2)
		menuItem:addChild(csFrame,0,33)
		csFrame:setVisible(false)
		table.insert(_topHeroArr,menuItem)
		if(i == 1)  then 
			-- menuItem:selected()
			hanleSelected(menuItem)
			_curHeroItem = menuItem
		end
		_tagArray[i] = i
		_indexArray[i] = i
	end

	if(RivalInfoData.hasFriend() == true) then

		local menuItem= RivalInfoData.getFriendItem()
		headMenu:addChild(menuItem,1,_ksTagFriend)
		menuItem:setAnchorPoint(ccp(0,0.5))
		menuItem:setPosition(ccp(125*( index) , _headScrowView:getContentSize().height/2))
		menuItem:registerScriptTapHandler(headItemCallBack)

		local sQualityLightedImg="images/hero/quality/highlighted.png"
		local csFrame = CCSprite:create(sQualityLightedImg)
		csFrame:setAnchorPoint(ccp(0.5, 0.5))
		csFrame:setPosition(menuItem:getContentSize().width/2, menuItem:getContentSize().height/2)
		menuItem:addChild(csFrame,0,33)
		csFrame:setVisible(false)
		table.insert(_topHeroArr,menuItem)
		index= index+1
        
        _tagArray[index] = _ksTagFriend
		_indexArray[_ksTagFriend] = index

	end

	if(RivalInfoData.hasPet() == true) then
		
		local menuItem= RivalInfoData.getPetItem()
		headMenu:addChild(menuItem,1,_ksTagPet)
		menuItem:setAnchorPoint(ccp(0,0.5))
		menuItem:setPosition(ccp(125*( index) , _headScrowView:getContentSize().height/2))
		menuItem:registerScriptTapHandler(headItemCallBack)

		local sQualityLightedImg="images/hero/quality/highlighted.png"
		local csFrame = CCSprite:create(sQualityLightedImg)
		csFrame:setAnchorPoint(ccp(0.5, 0.5))
		csFrame:setPosition(menuItem:getContentSize().width/2, menuItem:getContentSize().height/2)
		menuItem:addChild(csFrame,0,33)
		csFrame:setVisible(false)
		table.insert(_topHeroArr,menuItem)

		index = index + 1

		_tagArray[index] = _ksTagPet
		_indexArray[_ksTagPet] = index
	end

	---阵法按钮
	if _layerData[_ksTagPolicy].doShowFunc() then
		local policyBtn = RivalInfoData.getWarcraftItem()
		headMenu:addChild(policyBtn, 1, _ksTagPolicy)
		policyBtn:registerScriptTapHandler(headItemCallBack)
		policyBtn:setAnchorPoint(ccp(0,0.5))
		policyBtn:setPosition(125*( index) , _headScrowView:getContentSize().height/2)

		local sQualityLightedImg="images/hero/quality/highlighted.png"
		local policyHighlight = CCSprite:create(sQualityLightedImg)
		policyHighlight:setAnchorPoint(ccp(0.5, 0.5))
		policyHighlight:setPosition(policyBtn:getContentSize().width/2, policyBtn:getContentSize().height/2)
		policyBtn:addChild(policyHighlight,0,33)
		policyHighlight:setVisible(false)
		table.insert(_topHeroArr,policyBtn)
		index = index + 1

		_tagArray[index] = _ksTagPolicy
		_indexArray[_ksTagPolicy] = index
	end
    
    if(RivalInfoData.hasAttrFriend() == true) then
		
		local menuItem= RivalInfoData.getAttrFriendItem()
		headMenu:addChild(menuItem,1,_ksTagAttrFriend)
		menuItem:setAnchorPoint(ccp(0,0.5))
		menuItem:setPosition(ccp(125*( index) , _headScrowView:getContentSize().height/2))
		menuItem:registerScriptTapHandler(headItemCallBack)

		local sQualityLightedImg="images/hero/quality/highlighted.png"
		local csFrame = CCSprite:create(sQualityLightedImg)
		csFrame:setAnchorPoint(ccp(0.5, 0.5))
		csFrame:setPosition(menuItem:getContentSize().width/2, menuItem:getContentSize().height/2)
		menuItem:addChild(csFrame,0,33)
		csFrame:setVisible(false)
		table.insert(_topHeroArr,menuItem)

		index = index + 1

		_tagArray[index] = _ksTagAttrFriend
		_indexArray[_ksTagAttrFriend] = index
	end

	-- 战车
	if (RivalInfoData.isChariotOpen()) then
		local menuItem= RivalInfoData.getChariotItem()
		headMenu:addChild(menuItem,1,_ksTagChariot)
		menuItem:setAnchorPoint(ccp(0,0.5))
		menuItem:setPosition(ccp(125*(index) , _headScrowView:getContentSize().height/2))
		menuItem:registerScriptTapHandler(headItemCallBack)

		local sQualityLightedImg = "images/hero/quality/highlighted.png"
		local csFrame = CCSprite:create(sQualityLightedImg)
		csFrame:setAnchorPoint(ccp(0.5, 0.5))
		csFrame:setPosition(menuItem:getContentSize().width/2, menuItem:getContentSize().height/2)
		menuItem:addChild(csFrame,0,33)
		csFrame:setVisible(false)
		table.insert(_topHeroArr,menuItem)

		index = index + 1

		_tagArray[index] = _ksTagChariot
		_indexArray[_ksTagChariot] = index
	end

	createHeroSprite()
end

-- 刷新中部的UI 包括
function refreshMiddleUI(  )
	--首先刷新名字和转生次数
	local curHeroData = DB_Heroes.getDataById(_formationInfo[_curIndex].htid)
	-- if(tonumber(curHeroData.id) == 20001 or tonumber(curHeroData.id)== 20002) then
	if(HeroModel.isNecessaryHero(curHeroData.id)) then
		_heroNameLabel:setString(_tname)
	else
		-- _heroNameLabel:setString(curHeroData.name)
		require "script/ui/redcarddestiny/RedCardDestinyData"
    	local nameStr = RedCardDestinyData.getHeroRealName(nil,_formationInfo[_curIndex])
    	_heroNameLabel:setString(nameStr)
	end
	
	local nameColor = HeroPublicLua.getCCColorByStarLevel(curHeroData.star_lv)
	_heroNameLabel:setColor(nameColor)

	local evolveStr = nil
	if curHeroData.star_lv == 6 or curHeroData.star_lv == 7 then
		evolveStr = GetLocalizeStringBy("zz_99",  _formationInfo[_curIndex].evolve_level)
	else
		evolveStr = "+" .. _formationInfo[_curIndex].evolve_level
	end
	_evolveLevelLabel:setString(evolveStr)
	local width = _heroNameLabel:getPositionX()+_heroNameLabel:getContentSize().width

	local centerX = _heroNameBg:getContentSize().width*0.5
	local t_length = _heroNameLabel:getContentSize().width + _evolveLevelLabel:getContentSize().width + 5
	local s_x = centerX - t_length*0.5

	_heroNameLabel:setPosition(ccp(s_x, _heroNameBg:getContentSize().height*0.5))
	_evolveLevelLabel:setPosition(ccp(s_x+_heroNameLabel:getContentSize().width + 5, _heroNameBg:getContentSize().height*0.55))

	-- 添加称号
	if (_titleId > 0 and _titleEffect == nil) then
		require "script/ui/title/TitleUtil"
		_titleEffect = TitleUtil.createTitleNormalSpriteById(_titleId)
		_titleEffect:setAnchorPoint(ccp(0.5, 0.5))
		_titleEffect:setPosition(ccp(_formationBgSprite:getContentSize().width/2, _formationBgSprite:getContentSize().height*0.75))
		_formationBgSprite:addChild(_titleEffect, 11)
	end

	-- 刷新装备
	for k=1, 6 do	
		if(_equiptArr[k]~= nil) then
			_equiptArr[k]:removeFromParentAndCleanup(true)
			_equiptArr[k]= nil
		end
	end

	-- local armTable = _formationInfo[_curIndex].equipInfo.arming
	-- local treasTable = _formationInfo[_curIndex].equipInfo.treasure
	for k ,armTable in pairs(_formationInfo[_curIndex].equipInfo.arming) do
		-- 加上k~= 2 的限制是除去戒指
		if(not table.isEmpty(armTable) and tonumber(armTable.item_template_id)>0 ) then
			k=  tonumber(k) 
			k=  changeEquiptPos(k)
			
			local itemSprite= RivalInfoData.getItemSprite(armTable) --ItemSprite.getItemSpriteById(armTable.item_template_id,nil,nil, nil,-1011,19001)
			_equiptArr[k]= itemSprite
			_equiptArr[k]:setPosition(ccp(_equipBorderArr[k]:getContentSize().width/2,_equipBorderArr[k]:getContentSize().height/2))
			_equiptArr[k]:setAnchorPoint(ccp(0.5,0.5))
			_equipBorderArr[k]:addChild(_equiptArr[k])

			--装备名称
			local eQuality = ItemUtil.getEquipQualityByItemInfo( armTable )
			local e_nameLabel = ItemUtil.getEquipNameByItemInfo(armTable,g_sFontName,20)
			_equiptArr[k]:addChild(e_nameLabel)
			e_nameLabel:setAnchorPoint(ccp(0.5,1))
			e_nameLabel:setPosition(ccpsprite(0.5,-0.1,_equiptArr[k]))
		end
	end

	-- 宝物
	for k,treasure in pairs(_formationInfo[_curIndex].equipInfo.treasure) do
		if(not table.isEmpty(treasure) and tonumber(treasure.item_template_id)>0 ) then
			k=  tonumber(k)
			k= changeTreasurePos(k) 

			local itemSprite = RivalInfoData.getTreasureItem(treasure) --ItemSprite.getItemSpriteById(armTable.item_template_id,nil,nil, nil,-1011,19001)
			_equiptArr[k]= itemSprite
			_equiptArr[k]:setPosition(ccp(_equipBorderArr[k]:getContentSize().width/2,_equipBorderArr[k]:getContentSize().height/2))
			_equiptArr[k]:setAnchorPoint(ccp(0.5,0.5))
			_equipBorderArr[k]:addChild(_equiptArr[k])
		end
	end
	--刷新丹药按钮
	refreshPillBtn()
	--刷新锦囊按钮
	refreshPocketBtn()
	--刷新兵符按钮
	refreshTallyBtn()
	--天命
	refreshDestinyBtn()
end
function refreshRichLabel(p_oldLabel,p_newLabel)
	if(not p_oldLabel)then
		return
	end
	local parent = p_oldLabel:getParent()
	local oldAnchor = p_oldLabel:getAnchorPoint()
	local oldPosX = p_oldLabel:getPositionX()
	local oldPosY = p_oldLabel:getPositionY()
	p_oldLabel:removeFromParentAndCleanup(true)
	-- p_oldLabel = nil
	-- p_oldLabel = p_newLabel
	if(p_newLabel)then
		parent:addChild(p_newLabel)
		p_newLabel:setAnchorPoint(oldAnchor)
		p_newLabel:setPosition(ccp(oldPosX,oldPosY))
	end
	-- body
end


-- 战魂格子是否开启
function isFightSoulOpenByPos( posIndex )
	require "db/DB_Normal_config"
	local dbInfo = DB_Normal_config.getDataById(1)
	posIndex = tonumber(posIndex)
	local openLvArr = string.split(dbInfo.fightSoulOpenLevel, ",")
	local isOpen = false
	local openLv = tonumber(openLvArr[posIndex])
	local userLv= tonumber(_formationInfo[1].level)
	if( userLv >= openLv )then
		isOpen = true
	else
		isOpen = false
	end

	return isOpen, openLv
end

-- 后端传得装备  武器1，护甲2，头盔3，项链4 ， 宝物：1是名马  2是名书
-- 后端传得戒指和锁不显示   
-- 显示的顺寻： 武器-头盔-衣服-项链 -马-书
function changeEquiptPos( k )
	if(k==1 ) then
		return 1
	elseif(k==2) then
		return 3
	elseif(k==3) then
		return 2
	elseif(k==4) then
		return 4
	-- elseif(k==5) then
	-- 	return 4
	-- elseif(k==6) then
	-- 	return 0
	end
end

function changeTreasurePos(k)
	if(k== 1) then
		return 5
	elseif(k==2) then
		return 6
	end
end
function itemDelegateAction(  )
	MainScene.setMainSceneViewsVisible(_menuVisible, _avatarVisible, _bulletinVisible)
end


-- 创建中间的ui，装备和头像
local function createMiddleUI( )

	_equipMenuNode = CCNode:create()
	_equipMenuOriginPosition = ccp(0, 0)
	_equipMenuNode:setPosition(_equipMenuOriginPosition)
	_formationBgSprite:addChild(_equipMenuNode,3)

	local iconMenu = CCMenu:create()
	iconMenu:setPosition(ccp(0,0))
	iconMenu:setTouchPriority(-1009)
	_equipMenuNode:addChild(iconMenu)

	-- 后端传得装备  武器1，戒指2，护甲3，头盔4，项链5 锁6， 宝物：1是名马  2是名书
	-- 后端传得戒指和锁不显示   
	-- 显示的顺寻： 武器-头盔-衣服-项链 -马-书
	local btnXPositions = {489, 45, 489, 45,  480,35}
	local btnYPositions = {495, 495, 364, 364,210,210}
	local emptyEquipIcons = {
								"images/formation/emptyequip/weapon.png", 		"images/formation/emptyequip/helmet.png",	
								"images/formation/emptyequip/armor.png",		"images/formation/emptyequip/necklace.png",
								"images/formation/emptyequip/horse.png",		"images/formation/emptyequip/book.png",
							}
	for i=1,6 do
		local equipborderSprite
		if( i==5 or i==6 ) then
			equipborderSprite = CCSprite:create("images/common/t_equipborder.png")
		else
			equipborderSprite = CCSprite:create("images/common/equipborder.png")
		end
		equipBorderSp = CCMenuItemSprite:create(equipborderSprite,equipborderSprite)
		iconMenu:addChild(equipBorderSp)
		equipBorderSp:setPosition(ccp(btnXPositions[i],btnYPositions[i]))
		-- equipBorderSp:setVisible(false)
		--_equipMenuNode:addChild(equipBorderSp,12)
		table.insert(_equipBorderArr,equipBorderSp)
		local tempSprite= CCSprite:create(emptyEquipIcons[i])
		tempSprite:setAnchorPoint(ccp(0.5,0.5))
		tempSprite:setPosition(ccp(equipBorderSp:getContentSize().width/2, equipBorderSp:getContentSize().height/2))
		equipBorderSp:addChild(tempSprite)
	
	end

	createFightSoulUI()
	setFightSoulVisible(false)

	local menuBar= CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-1001)
	_bottomBg:addChild(menuBar)

	-- 切换装备阵容按钮
	_f_equipBtn = CCMenuItemImage:create("images/common/btn/btn_equip_n.png", "images/common/btn/btn_equip_h.png")
	_f_equipBtn:setAnchorPoint(ccp(0.5, 0))
	_f_equipBtn:setPosition(ccp(_formationBgSprite:getContentSize().width*0.45,123 ))
	_f_equipBtn:registerScriptTapHandler(EquiptTOSoulAction)
	_f_equipBtn:setVisible(false)
	menuBar:addChild(_f_equipBtn,1, 101)
	
	-- 切换战魂阵容界面
	_f_fightSoulBtn = CCMenuItemImage:create("images/common/btn/btn_fightSoul_n.png", "images/common/btn/btn_fightSoul_h.png")
	_f_fightSoulBtn:setAnchorPoint(ccp(0.5, 0))
	_f_fightSoulBtn:setVisible(true)
	_f_fightSoulBtn:setPosition(_formationBgSprite:getContentSize().width*0.45,130)
	_f_fightSoulBtn:registerScriptTapHandler(EquiptTOSoulAction)
	menuBar:addChild(_f_fightSoulBtn,1,102)

	-- 神兵按钮
	_f_godweaponBtn = CCMenuItemImage:create("images/formation/god_n.png","images/formation/god_h.png")
	_f_godweaponBtn:setAnchorPoint(ccp(0,0))
	_f_godweaponBtn:setPosition(ccp(_formationBgSprite:getContentSize().width*0.5, 130))
	_f_godweaponBtn:registerScriptTapHandler(godweaponAction)
	menuBar:addChild(_f_godweaponBtn,1,103)

	-- 丹药按钮
	_f_pillBtn = CCMenuItemImage:create("images/pill/pill_icon_n.png","images/pill/pill_icon_h.png")
	_f_pillBtn:setAnchorPoint(ccp(0,0))
	_f_pillBtn:setPosition(ccp(_formationBgSprite:getContentSize().width*0.25, 200))
	_f_pillBtn:registerScriptTapHandler(pillAction)
	menuBar:addChild(_f_pillBtn,1,104)
	_f_pillBtn:setVisible(false)


	-- _f_pocketBtn = CCMenuItemImage:create("images/formation/pocket_n.png", "images/formation/pocket_h.png")
	-- _f_pocketBtn:setAnchorPoint(ccp(0.5,0))
	-- _f_pocketBtn:setPosition(ccp(_formationBgSprite:getContentSize().width*0.5, 230))
	-- _f_pocketBtn:registerScriptTapHandler(pocketAction)	
	-- menuBar:addChild(_f_pocketBtn,1,105)
	-- setPocketVisible(false)

	-- _f_tallyBtn = CCMenuItemImage:create("images/formation/tally_n.png", "images/formation/tally_h.png")
	-- _f_tallyBtn:setAnchorPoint(ccp(0.5,0))
	-- _f_tallyBtn:setPosition(ccp(_formationBgSprite:getContentSize().width*0.75, 200))
	-- _f_tallyBtn:registerScriptTapHandler(pocketAction)	
	-- menuBar:addChild(_f_tallyBtn,1,106) 
	-- _f_tallyBtn:setVisible(false)

	local richInfo = {
        defaultType = "CCMenuItem",
        touchPriority = -5000,
        elements =
        {
            {
            	create = function ( ... )
				    _f_pocketBtn = CCMenuItemImage:create("images/formation/pocket_n.png", "images/formation/pocket_h.png")
					_f_pocketBtn:registerScriptTapHandler(pocketAction)	
					setPocketVisible(false)
					return _f_pocketBtn
            	end
            },
            {
            	create = function ( ... )
					_f_tallyBtn = CCMenuItemImage:create("images/formation/tally_n.png", "images/formation/tally_h.png")
					_f_tallyBtn:registerScriptTapHandler(tallyAction)	
					_f_tallyBtn:setVisible(false)
					return _f_tallyBtn
            	end
            },
            {
            	create = function ( ... )
					local destinyBtn = CCMenuItemImage:create("images/formation/destiny_n.png", "images/formation/destiny_h.png")
					destinyBtn:registerScriptTapHandler(destinyAction)	
					destinyBtn:setVisible(false)
					addBtnToTable(destinyBtn,1)
					return destinyBtn
            	end
            },
        }
    }
    _menuItemLabel = LuaCCLabel.createRichLabel(richInfo)
    _menuItemLabel:setAnchorPoint(ccp(0.5, 0))
    _menuItemLabel:setPosition(ccp(_formationBgSprite:getContentSize().width*0.5, 230))
    _bottomBg:addChild(_menuItemLabel)

	createBottomFrame()
	--refreshStarBg()
	createGodweaponUI()
	setGodWeaponVisible(false)

end
--点击锦囊的回调
function pocketAction( ... )
	-- print("_formationInfo")
	-- print_t(_formationInfo)
	-- print("_formationInfo")
	OtherPocketLayer.showLayer(_curIndex,_formationInfo,-102000,19001)
end
--设置锦囊是否可见
function setPocketVisible( p_param )
	if(_f_pocketBtn)then
		_f_pocketBtn:setVisible(p_param)
	end
end
--点击兵符的回调
function tallyAction( ... )
	local hid = RivalInfoData.getHeroIDByPos(_curIndex)
	require "script/ui/tally/TallyMainLayer"
	TallyMainLayer.show(hid, false, nil, -102000, 19001)
end
--设置兵符是否可见
function setTallyVisible( p_param )
	if(_f_tallyBtn)then
		_f_tallyBtn:setVisible(p_param)
	end
end

--点击兵符的回调
function destinyAction( ... )
	-- ChatUserInfoLayer.closeClick()
	-- closeCb()
	require "script/ui/redcarddestiny/RedCardDestinyLayer"
	local pInfo = RivalInfoData.getAllFormationInfo()
	local hid = _formationInfo[_curIndex].hid
    local layer = RedCardDestinyLayer.createLayer(2,hid,-102000,pInfo)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(layer,19002,798)
    -- MainScene.changeLayer(layer, "RedCardDestinyLayer")
    -- MainScene.setMainSceneViewsVisible(false,false,false)
end
--设置兵符是否可见
function setDestinyVisible( p_param )
	local destinyBtn = getBtnFromTable(1)
	if(destinyBtn)then
		destinyBtn:setVisible(p_param)
	end
end
------------------------------------add by DJN 2015/6/28 -------------------------------------------------------------
--点击丹药按钮的回调
function pillAction( ... )
	RivalPillLayer.createLayer(_curIndex)
end
----------------------------------add by DJN 2014/12/24 ---------------------------------------------------------------
---------神兵按钮回调  
function godweaponAction()
	_f_godweaponBtn:setVisible(false)

	setFightSoulVisible(false)
	setEquiptVisible(false)
    setGodWeaponVisible(true)
	--refreshGodweaponUI()
end
function createGodweaponUI( ... )
	_equipGodWeaponMenu = CCMenu:create()
	local equipMenuOriginPosition = ccp(0, 0)
	_equipGodWeaponMenu:setPosition(equipMenuOriginPosition)
	_formationBgSprite:addChild(_equipGodWeaponMenu,3)
	_equipGodWeaponMenu:setTouchPriority(-1013)
end
---------刷新神兵UI

function refreshGodweaponUI()

	if(table.isEmpty(_godweaponBtnTable) == false) then
		for i=1,table.count(_godweaponBtnTable) do
			_godweaponBtnTable[i]:removeFromParentAndCleanup(true)
			_godweaponBtnTable[i] = nil
		end
		_godweaponBtnTable = {}

	end

	--数据
	local weaponInfo = _formationInfo[_curIndex].equipInfo.godWeapon or {}
	-- 顺序 
	local btnXPositions = {0.85, 0.15,0.15, 0.85,0.15}
	local btnYPositions = {0.62, 0.71, 0.53, 0.445, 0.36}
	local hid = _formationInfo[_curIndex].hid

	local godWeaponData = _formationInfo[_curIndex].equipInfo.godWeapon

	for btnIndex,xScale in pairs(btnXPositions) do
		-- 装备底框
		local equipBorderSp = CCSprite:create("images/common/equipborder.png")
		equipBorderSp:setAnchorPoint(ccp(0.5,0.5))
		
		local equipBtn = nil
		local redTipSprite = nil
		-- 装备
		if(table.isEmpty(godWeaponData) == false)then
			local equipInfo = godWeaponData["" .. godWeaponPositions[btnIndex]]
			if( table.isEmpty(equipInfo) == false and  tonumber(equipInfo.item_template_id) > 0) then
				local p_godweaponInfo = equipInfo
				p_godweaponInfo.itemDesc = ItemUtil.getItemById(p_godweaponInfo.item_template_id)
				local equipSprite = ItemSprite.getItemSpriteById(tonumber(equipInfo.item_template_id),nil, 
					                nil,nil,-1012, 19100,-1012,nil,nil, nil,nil,p_godweaponInfo)
				_godweaponBtnTable[btnIndex] = LuaMenuItem.createItemSprite(equipSprite, equipSprite)
				-- 名称
				local equipDesc = ItemUtil.getItemById(tonumber(equipInfo.item_template_id))
				local quality,_,_ = GodWeaponItemUtil.getGodWeaponQualityAndEvolveNum(tonumber(equipInfo.item_template_id), tonumber(equipInfo.item_id),p_godweaponInfo)
				local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
				local e_nameLabel =  CCRenderLabel:create(equipDesc.name , g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    e_nameLabel:setColor(nameColor)
			    e_nameLabel:setPosition(ccp( (_godweaponBtnTable[btnIndex]:getContentSize().width- e_nameLabel:getContentSize().width)/2, -_godweaponBtnTable[btnIndex]:getContentSize().height*0.1))
			    _godweaponBtnTable[btnIndex]:addChild(e_nameLabel)
				-- 强化等级
				local lvSprite = CCSprite:create("images/base/potential/lv_" .. quality .. ".png")
				lvSprite:setAnchorPoint(ccp(0,1))
				lvSprite:setPosition(ccp(-1, _godweaponBtnTable[btnIndex]:getContentSize().height))
				_godweaponBtnTable[btnIndex]:addChild(lvSprite)
				local lvLabel =  CCRenderLabel:create(equipInfo.va_item_text.reinForceLevel , g_sFontName, 18, 1, ccc3( 0, 0, 0), type_stroke)
			    lvLabel:setColor(ccc3(255,255,255))
			    lvLabel:setAnchorPoint(ccp(0.5,0.5))
			    lvLabel:setPosition(ccp( lvSprite:getContentSize().width*0.5, lvSprite:getContentSize().height*0.5))
			    lvSprite:addChild(lvLabel)
			    -- 印章 神兵类型 金木水火土
			    local sealSprite = CCSprite:create("images/god_weapon/godtype/" .. equipDesc.type .. ".png" )
			    -- sealSprite:setAnchorPoint(ccp(0.5, 0))
			    -- sealSprite:setPosition(ccp(equipSprite:getContentSize().width*0.5, equipSprite:getContentSize().height*1.1))
			    equipSprite:addChild(sealSprite)

			     --如果btnIndex为偶数，图标在右边
		        if(btnIndex == 1 or btnIndex == 4)then
		            sealSprite:setAnchorPoint(ccp(1, 0.5))
		            sealSprite:setPosition(ccp(150, equipBorderSp:getContentSize().height*0.5))
		        else
		            sealSprite:setAnchorPoint(ccp(0, 0.5))
		            sealSprite:setPosition(ccp(-50, equipBorderSp:getContentSize().height*0.5))
		        end

			end
		end

		if(_godweaponBtnTable[btnIndex] == nil)then
			_godweaponBtnTable[btnIndex] = LuaMenuItem.createItemImage("images/formation/emptyequip/weapon.png", "images/formation/emptyequip/weapon.png")
		end

		equipBorderSp:setPosition(ccp(_godweaponBtnTable[btnIndex]:getContentSize().width*0.5,_godweaponBtnTable[btnIndex]:getContentSize().height*0.5))
		_godweaponBtnTable[btnIndex]:addChild(equipBorderSp, -1)
		_godweaponBtnTable[btnIndex]:setAnchorPoint(ccp(0.5, 0.5))
		_godweaponBtnTable[btnIndex]:setPosition(ccp(_formationBgSprite:getContentSize().width*xScale,_formationBgSprite:getContentSize().height*btnYPositions[btnIndex]))
        _godweaponBtnTable[btnIndex]:registerScriptTapHandler(godweaponCb)
		_equipGodWeaponMenu:addChild(_godweaponBtnTable[btnIndex],1,btnIndex)
	end
end
-- 隐藏神兵阵容
function setGodWeaponVisible( isVisible )
	_equipGodWeaponMenu:setVisible(isVisible)
	_equipGodWeaponMenu:setEnabled(isVisible)

end
----点神兵后的神兵详细信息弹板
function godweaponCb(tag)
	require "script/ui/godweapon/GodWeaponInfoLayer"
	local curGodInfo = _formationInfo[_curIndex].equipInfo.godWeapon
	tag = string.format("%d",tag)	
	if(table.isEmpty(curGodInfo[tag]) == true) then return end
	GodWeaponInfoLayer.showLayer(curGodInfo[tag].item_template_id,curGodInfo[tag].item_id,
		                        nil,nil,nil,nil,nil,-1013,19100,curGodInfo[tag],_formationInfo[_curIndex])
	
	-- body
end
-----------------------------------------------------------------------------------------------------------------------------------------------
-- 刷新 -- 星星底 和底部的frame
function refreshStarBg()

	if ((_titleEffect ~= nil) and (not tolua.isnull(_titleEffect))) then
		if(_curIndex<= 1 ) then -- 主角显示称号
			_titleEffect:setVisible(true)
		else
			_titleEffect:setVisible(false)
		end
	end

	if( _inType ==1) then
		_bottomFrame:setVisible(false)
	else
		_bottomFrame:setVisible(true)
	end
end


-- 设置装备按钮可见
function setEquiptVisible( visible )
	for i=1, #_equipBorderArr do
		_equipBorderArr[i]:setVisible(visible)
	end
end

-- 创建底框的UI
function createBottomFrame( ... )

	_bottomFrame= CCSprite:create("images/main/base_bottom_border.png")
	_bottomFrame:setAnchorPoint(ccp(0.5,0))
	_bottomFrame:setPosition(_formationBgSprite:getContentSize().width/2,-2)
	_formationBgSprite:addChild(_bottomFrame,11)

end

--创建战魂背景
function createFightSoulUI( )
		-- 顺序 
	-- local fightSoul= _formationInfo[_curIndex].equipInfo.fightSoul
	-- local btnXPositions = {0.15, 0.85, 0.15, 0.85, 0.15, 0.85, 0.15, 0.85}
	-- local btnYPositions = {530, 530, 420, 420,310 ,310, 200,200}

	
	-- _fightSoulMenuBar = CCNode:create()
	-- _equipMenuOriginPosition = ccp(0, 0)
	-- _fightSoulMenuBar:setPosition(_equipMenuOriginPosition)
	-- _formationBgSprite:addChild(_fightSoulMenuBar,3)

	-- for i, xScale in pairs(btnXPositions) do
	-- 	local equipBorderSp= CCSprite:create("images/common/f_bg.png")
	-- 	--战魂底
	-- 	equipBorderSp:setPosition(ccp(btnXPositions[i]*_formationBgSprite:getContentSize().width,btnYPositions[i]))
	-- 	equipBorderSp:setAnchorPoint(ccp(0.5,0))
	-- 	-- _formationBgSprite:addChild(equipBorderSp,12)
	-- 	table.insert(_fightSoulBorderArr ,equipBorderSp)
	-- 	_fightSoulMenuBar:addChild(equipBorderSp)
	-- end

-------
	if(tolua.cast(_fightSoulMenuBar,"CCSprite") ~= nil)then
		_fightSoulMenuBar:removeFromParentAndCleanup(true)
		_fightSoulMenuBar = nil
	end
	_fightSoulMenuBar = CCSprite:create()
	_fightSoulMenuBar:setContentSize(_formationBgSprite:getContentSize())
	_equipMenuOriginPosition = ccp(0, 0)
	_fightSoulMenuBar:setPosition(_equipMenuOriginPosition)
	_formationBgSprite:addChild(_fightSoulMenuBar,3)


end
--刷新战魂UI
function refreshFightSoulUI( ... )

	if(tolua.cast(_fightSoulMenuBar,"CCSprite") ~= nil)then
		_fightSoulMenuBar:removeFromParentAndCleanup(true)
		_fightSoulMenuBar = nil
	end
	_fightSoulMenuBar = CCSprite:create()
	_fightSoulMenuBar:setContentSize(_formationBgSprite:getContentSize())
	_equipMenuOriginPosition = ccp(0, 0)
	_fightSoulMenuBar:setPosition(_equipMenuOriginPosition)
	_formationBgSprite:addChild(_fightSoulMenuBar,3)

	--创建两个tableView
	-- if(_leftSoulTableView == nil or _rightSoulTableView == nil )then
		local viewPosX = {0.15,0.85}
		for i = 1,2 do
			local fullRect = CCRectMake(0,0,134,59)
			local insetRect = CCRectMake(31,33,90,20)
			local innerViewBg = CCScale9Sprite:create("images/common/bg_down.png", fullRect,insetRect)
			innerViewBg:setContentSize(CCSizeMake(134,400))
			_fightSoulMenuBar:addChild(innerViewBg,1,i)
			innerViewBg:setAnchorPoint(ccp(0.5,0))
			innerViewBg:setPosition(ccpsprite(viewPosX[i],200/_fightSoulMenuBar:getContentSize().height,_fightSoulMenuBar))

			-- if(i == 1)then
			-- 	_leftSoulTableView = createInnerView(i)
			-- 	innerViewBg:addChild(_leftSoulTableView,1,111)
			-- 	_leftSoulTableView:ignoreAnchorPointForPosition(false)
			-- 	_leftSoulTableView:setAnchorPoint(ccp(0.5,0.5))
			-- 	_leftSoulTableView:setPosition(innerViewBg:getContentSize().width*0.5,innerViewBg:getContentSize().height*0.5)
			-- elseif(i == 2)then
			-- 	_rightSoulTableView= createInnerView(i)
			-- 	innerViewBg:addChild(_rightSoulTableView,1,111)
			-- 	_rightSoulTableView:ignoreAnchorPointForPosition(false)
			-- 	_rightSoulTableView:setAnchorPoint(ccp(0.5,0.5))
			-- 	_rightSoulTableView:setPosition(innerViewBg:getContentSize().width*0.5,innerViewBg:getContentSize().height*0.5)
			-- end
			local innerView = createInnerView(i)
			innerViewBg:addChild(innerView,1,111)
			innerView:ignoreAnchorPointForPosition(false)
			innerView:setAnchorPoint(ccp(0.5,0.5))
			innerView:setPosition(innerViewBg:getContentSize().width*0.5,innerViewBg:getContentSize().height*0.5)

			createShiningArrow(innerView,tagUp)
			createShiningArrow(innerView,tagDown)

			arrowVisible(innerView,tagUp,false)
		end
	-- _leftSoulTableView:reloadData()
	-- _rightSoulTableView:reloadData()

	--_fightSoulMenuBar:setVisible(false)
	schedule(_fightSoulMenuBar,updateArrow,1)

	
	setFightSoulVisible(_fightSoulVisiable)


	-- body
end
-- 设置战魂是否可见
function setFightSoulVisible( visible)
	-- for i=1, #_fightSoulBorderArr do
	-- 	_fightSoulBorderArr[i]:setVisible(visible)
	-- end
	_fightSoulMenuBar:setVisible(visible)
	_fightSoulVisiable = visible
end

function EquiptTOSoulAction( tag, item)
	if(tag == 101) then
		_f_equipBtn:setVisible(false)
		_f_fightSoulBtn:setVisible(true)
		setFightSoulVisible(false)
		setEquiptVisible(true)
		-------add by DJN --------
		_f_godweaponBtn:setVisible(true)
		setGodWeaponVisible(false)
		----------------------------
	elseif(tag== 102) then
		_f_equipBtn:setVisible(true)
		_f_fightSoulBtn:setVisible(false)
		setFightSoulVisible(true)
		setEquiptVisible(false)
		-------add by DJN --------
		_f_godweaponBtn:setVisible(true)
		setGodWeaponVisible(false)
		----------------------------
	end
end

-- 创建 hero 的姓名， 战斗力，生命 等ui
local function createPropertyUI(  )

	_bottomBg = CCSprite:create("images/formation/bottombg.png")
	_bottomBg:setPosition(_formationBgSprite:getContentSize().width/2, 0)
	_bottomBg:setAnchorPoint(ccp(0.5,0))
	_formationBgSprite:addChild(_bottomBg,2)

	-- 英雄的名字
	_heroNameBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	_heroNameBg:setContentSize(CCSizeMake(240, 36))
	_heroNameBg:setAnchorPoint(ccp(0.5,0))
	_heroNameBg:setPosition(ccp(_bottomBg:getContentSize().width*0.5, 197))
	_bottomBg:addChild(_heroNameBg,2)
	--_heroNameLabel= CCRenderLabel:
	_heroNameLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1167"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	-- _heroNameLabel:setColor(nameColor)
	_heroNameLabel:setAnchorPoint(ccp(0, 0.5))
	_heroNameBg:addChild(_heroNameLabel,11)
	-- 转生次数
	_evolveLevelLabel= CCRenderLabel:create("+" , g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_evolveLevelLabel:setAnchorPoint(ccp(0, 0.5))
	_evolveLevelLabel:setColor(ccc3(0x00, 0xff, 0x18))
	_heroNameBg:addChild(_evolveLevelLabel,11)

	local centerX = _heroNameBg:getContentSize().width*0.5
	local t_length = _heroNameLabel:getContentSize().width + _evolveLevelLabel:getContentSize().width + 5
	local s_x = centerX - t_length*0.5
	_heroNameLabel:setPosition(ccp(s_x, _heroNameBg:getContentSize().height*0.55))
	_evolveLevelLabel:setPosition(ccp(s_x+_heroNameLabel:getContentSize().width + 5, _heroNameBg:getContentSize().height*0.55))

	-- 战斗力
	_fightForceLabel = CCRenderLabel:create("123123" , g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_fightForceLabel:setPosition(ccp(450,89))
	_fightForceLabel:setAnchorPoint(ccp(0,0))
	_fightForceLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	_bottomBg:addChild(_fightForceLabel,5)

	-- 生命
	local lifeTitleLabel= CCLabelTTF:create(GetLocalizeStringBy("key_1754"), g_sFontName, 23)
	lifeTitleLabel:setPosition(ccp(351,51))
	lifeTitleLabel:setColor(ccc3(0x78, 0x25, 0x00))
	_bottomBg:addChild(lifeTitleLabel,5)

	_lifeLabel = CCLabelTTF:create("2344", g_sFontName, 23)
	_lifeLabel:setColor(ccc3(0x00, 0x00, 0x00))
	_lifeLabel:setPosition(ccp(409,51))
	_bottomBg:addChild(_lifeLabel,5)

	-- 攻击
	local attTitleLabel= CCLabelTTF:create(GetLocalizeStringBy("key_2966"), g_sFontName, 23)
	attTitleLabel:setPosition(ccp(483,55))
	attTitleLabel:setColor(ccc3(0x78, 0x25, 0x00))
	_bottomBg:addChild(attTitleLabel)

	_attLabel = CCLabelTTF:create("2344", g_sFontName, 23)
	_attLabel:setColor(ccc3(0x00, 0x00, 0x00))
	_attLabel:setPosition(ccp(545,55))
	_bottomBg:addChild(_attLabel,5)

	-- 物防
	local phyDefTitleLabel= CCLabelTTF:create(GetLocalizeStringBy("key_1567"), g_sFontName, 23)
	phyDefTitleLabel:setPosition(ccp(351,25))
	phyDefTitleLabel:setColor(ccc3(0x78, 0x25, 0x00))
	_bottomBg:addChild(phyDefTitleLabel,5)

	 _phyDefLabel = CCLabelTTF:create("2344", g_sFontName, 23)
	_phyDefLabel:setColor(ccc3(0x00, 0x00, 0x00))
	_phyDefLabel:setPosition(ccp(409,25))
	_bottomBg:addChild(_phyDefLabel,5)

	-- -- 法防
	local magDefTitleLabel= CCLabelTTF:create(GetLocalizeStringBy("key_3147"), g_sFontName, 23)
	magDefTitleLabel:setPosition(ccp(483,25))
	magDefTitleLabel:setColor(ccc3(0x78, 0x25, 0x00))
	_bottomBg:addChild(magDefTitleLabel,5)

	 _magDefLabel = CCLabelTTF:create("2344", g_sFontName, 23)
	_magDefLabel:setColor(ccc3(0x00, 0x00, 0x00))
	_magDefLabel:setPosition(ccp(545,25))
	_bottomBg:addChild(_magDefLabel,5)

	-- 显示战斗力
	_userFightLineSp= CCSprite:create("images/common/line2.png")
	_userFightLineSp:setPosition(394,130)
	_bottomBg:addChild(_userFightLineSp)

	local fightForceSp =CCSprite:create("images/common/fight_value.png")
	fightForceSp:setPosition(3,_userFightLineSp:getContentSize().height/2 )
	fightForceSp:setAnchorPoint(ccp(0,0.5))
	_userFightLineSp:addChild(fightForceSp )

	_userFightValue=CCRenderLabel:create("", g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_userFightValue:setColor(ccc3(0xff, 0xf6, 0x00))
	_userFightValue:setPosition( fightForceSp:getContentSize().width+6,_userFightLineSp:getContentSize().height/2)
	_userFightValue:setAnchorPoint(ccp(0,0.5))
	_userFightLineSp:addChild(_userFightValue)


end

-- 羁绊ui,和等级ui
local function createUnionUI(  )
	
	local jipanBg = CCSprite:create("images/common/line2.png")
    jipanBg:setAnchorPoint(ccp(0.5,0.5))
    jipanBg:setPosition(ccp(165,101 ))
    _bottomBg:addChild(jipanBg)

    local jipanSp = CCSprite:create("images/formation/text.png")
    jipanSp:setAnchorPoint(ccp(0.5,0.5))
    jipanSp:setPosition(ccp(jipanBg:getContentSize().width * 0.5, jipanBg:getContentSize().height*0.5))
    jipanBg:addChild(jipanSp)

    -- 等级及等级上限
	_LevelLabel = CCRenderLabel:create("20/20", g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_LevelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	_LevelLabel:setAnchorPoint(ccp(0, 0))
	_LevelLabel:setPosition(ccp(90,154 ))
	_bottomBg:addChild(_LevelLabel)	

    -- 六个羁绊
    local x_scale = { 70, 175, 278, 70, 175, 278}
    local y_scale = { 52, 52, 52 ,24 ,24, 24}
    for i=1,6 do
    	local tempLabel = CCLabelTTF:create("", g_sFontName, 23)
		--tempLabel:setColor(ccc3(0x78, 0x25, 0x00))
		tempLabel:setColor(ccc3(155,155,155))
		tempLabel:setAnchorPoint(ccp(0.5, 0))
		tempLabel:setPosition(ccp( x_scale[i], y_scale[i]))
		_bottomBg:addChild(tempLabel)
		table.insert(_skillLabelArr, tempLabel)
    end
end


-- 刷新羁绊的ui
function refreshUnionUI(  )

	printTable("_formationInfo", _formationInfo)

	local heroData = DB_Heroes.getDataById(_formationInfo[_curIndex].htid)
	local link_group= heroData.link_group1
	if(link_group)then
		require "db/DB_Union_profit"
		local s_name_arr= string.split(link_group, ",")
		for k,v in ipairs(_skillLabelArr) do
			if(k<= #s_name_arr)then
				local t_union_profit = DB_Union_profit.getDataById(s_name_arr[k])
				if( not table.isEmpty(t_union_profit) and t_union_profit.union_arribute_name)then
					v:setString(t_union_profit.union_arribute_name)
					v:setColor(ccc3(155,155,155))
					-- 设置颜色
					-- print("_curIndex is  ", _curIndex)
					if RivalInfoData.IsjudgeUnion(s_name_arr[k], _formationInfo[_curIndex].htid, _formationInfo[_curIndex].hid) then
						v:setColor(ccc3(0x78, 0x25, 0x00))
					end
				end
			else
				v:setString("")
			end
		end
	else
		for k,v in pairs(_skillLabelArr) do 
			v:setString("")
		end
	end

	-- 刷新等级
	local limitLevel = _formationInfo[1].level  -- HeroModel.getHeroLimitLevel(_formationInfo[_curIndex].htid, _formationInfo[_curIndex].evolve_level)
	_LevelLabel:setString( _formationInfo[_curIndex].level .. "/" .. limitLevel)
end


-- 刷新所有的ui
function refreshAllUI(  )
	refreshPropertyUI()
	refreshUnionUI()
	refreshMiddleUI()
	refreshFightSoulUI()
	refreshGodweaponUI()

end

-- 刷新属性的UI
function refreshPropertyUI( )
	local heroData= DB_Heroes.getDataById(_formationInfo[_curIndex].htid)
	_fightForceLabel:setString("" .. heroData.heroQuality )
	_lifeLabel:setString("" .. math.ceil(_formationInfo[_curIndex].max_hp) )
	_attLabel:setString("" .. math.ceil(_formationInfo[_curIndex].general_atk) )
	_phyDefLabel:setString("" .. math.ceil(_formationInfo[_curIndex].physical_def))
	_magDefLabel:setString("" .. math.ceil(_formationInfo[_curIndex].magical_def))


	if( HeroModel.isNecessaryHero( tonumber(_formationInfo[_curIndex].htid)) and RivalInfoData.getHeroFightForce()>0 ) then
		_userFightValue:setString( RivalInfoData.getHeroFightForce() )
		_userFightLineSp:setVisible(true)
	else
		_userFightLineSp:setVisible(false)
	end

end

-- 处理阵容信息
local function handleInfo(allFormationInfo  )
	for i=1,#allFormationInfo.squad do
		for k,v in pairs (allFormationInfo.arrHero) do
			if( allFormationInfo.squad[i] == v.hid) then
				table.insert(_formationInfo, v)
			end
		end
	end
end

-- 网络数据的回调
function userBattleCallback( cbFlag, dictData, bRet )
	if(dictData.err ~= "ok" or table.isEmpty(dictData.ret) )then
		AnimationTip.showTip(GetLocalizeStringBy("key_1834"))
		return
	end
	print_t(dictData.ret)
	local allFormationInfo
	for k,v in pairs (dictData.ret) do 
		allFormationInfo = v
	end
	_tname= allFormationInfo.uname
	_guildName= allFormationInfo.guild_name
	_vip =  allFormationInfo.vip or 0
	_titleId = tonumber(allFormationInfo.title) or 0 -- 记录下称号ID

	allFormationInfo.uid= _uid
	-- print("all _formationInfo  is :============================ ")
	-- print_t(allFormationInfo)
	DataCache.addFormaton(allFormationInfo)
	_curIndex =1
	handleInfo(allFormationInfo)
	RivalInfoData.setAllFormationInfo(allFormationInfo)
	RivalInfoData.handleInfo()
	createHeadUI( )
	refreshAllUI()
	refreshRivalName()

	-- 创建小伙伴的UI
	if(RivalInfoData.hasFriend() ) then
		createLittleFriendUI()
	end
	if(RivalInfoData.hasPet() ) then
		createPetUI()
	end
	--createHeroScrowView()

	-- 创建阵法UI
	if _layerData[_ksTagPolicy].doShowFunc() then
		require "script/ui/warcraft/OthersWarcraftLayer"
		_layerData[_ksTagPolicy].layer = OthersWarcraftLayer.creaateByWarcraftData()
		-- _layerData[_ksTagPolicy].layer = CCLayerColor:create(ccc4(0,0,0,125))
		_layerData[_ksTagPolicy].layer:setAnchorPoint(ccp(0,0))
		_layerData[_ksTagPolicy].layer:setPosition(_formationBgSprite:getContentSize().width,0)
		_formationBgSprite:addChild(_layerData[_ksTagPolicy].layer,1)
	end

	-- 创建战车UI
	if (RivalInfoData.isChariotOpen()) then
		createChariotUI()
	end
end

function setTname(name  )
	_tname= name
end

function getTname( )
	return _tname
end


local function getHeroData( htid)
	local value = {}

	value.htid = htid
	local db_hero = DB_Heroes.getDataById(htid)
	value.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)

	if(HeroModel.isNecessaryHero( tonumber(htid) )) then
		print("getHeroData isNecessaryHero")
		value.name = _tname
		value.masterTalent = RivalInfoData.getMasterTalent()
		print_t(_formationInfo)
		print("value.masterTalent")
		print_t(value.masterTalent)
	else
		print("getHeroData not NecessaryHero")
		value.name = db_hero.name
	end

	value.level = tonumber(_formationInfo[_curIndex].level)
	value.star_lv = db_hero.star_lv
	value.hero_cb = menu_item_tap_handler
	value.head_icon = "images/base/hero/head_icon/" .. db_hero.head_icon_id
    value.quality_bg = "images/hero/quality/"..value.star_lv .. ".png"
	value.quality_h = "images/hero/quality/highlighted.png"
	value.type = "HeroFragment"
	value.isRecruited = false
	value.evolve_level =  tonumber(_formationInfo[_curIndex].evolve_level)
	value.htid = tonumber( _formationInfo[_curIndex].htid)
	--添加怒气和普通技能id
	value.rage_skill = tonumber(_formationInfo[_curIndex].rage_skill)
	value.attack_skill = tonumber(_formationInfo[_curIndex].attack_skill)

	local formationInfo =  _formationInfo[_curIndex]
	local dressId= nil
	-- 新增幻化id, add by lgx 20160928
	local turnedId = nil
	-- if( not table.isEmpty(formationInfo) ) then 
	-- 	if(not table.isEmpty( formationInfo.equipInfo.dress) and not table.isEmpty(formationInfo.equipInfo.dress["1"]))then
	-- 		dressId = tonumber(formationInfo.equipInfo.dress["1"].item_template_id)
	-- 	end	
	-- end

	if( not table.isEmpty(formationInfo) ) then 
		if formationInfo.dress ~= nil then
			dressId = tonumber(formationInfo.dress["1"])
		end
		if formationInfo.turned_id ~= nil then
			turnedId = tonumber(formationInfo.turned_id)
		end	
	end

	value.dressId = dressId
	value.turned_id = turnedId
	
	return value
end

-- 点击英雄头像的回调函数
function heroSpriteCb( heroInfo)

	_formationBgSprite:setVisible(false)

	--closeCb()
	require "script/ui/hero/HeroInfoLayer"
	local data = getHeroData(heroInfo.htid)
	data.heroInfo = heroInfo
	local tArgs = {}
	tArgs.sign = "RivalInfoLayer"
	tArgs.fnCreate = RivalInfoLayer.createLayer
	tArgs.reserved =  {index= 10001}
	HeroInfoLayer.createLayer(data, {isPanel=true}, 19003,-1011, nil, setFormationView, true )
	-- MainScene.changeLayer(HeroInfoLayer.createLayer(data, tArgs), "HeroInfoLayer")
end


function setFormationView( ... )
	_formationBgSprite:setVisible(true)
end

-- layer 的回调函数
local function layerToucCb(eventType, x, y)
	-- local heroStartPositionX = _curHeroSprite:getPositionX()
	if (eventType == "began") then	
		_touchBeganPoint = ccp(x,y)
		_touchLastPoint = ccp(x,y)
		local touchSize = CCSizeMake(640, _formationBgSprite:getContentSize().height - topBgSp:getContentSize().height)
		if _inType == 1 then
			local vPosition = _curHeroSprite:convertToNodeSpace(_touchBeganPoint)
			local minY = _curHeroSprite:getContentSize().height > (touchSize.height - _curHeroSprite:getPositionY())
			             and (touchSize.height - _curHeroSprite:getPositionY()) or _curHeroSprite:getContentSize().height
			if not _isOnAnimation and vPosition.x>0  and vPosition.x < _curHeroSprite:getContentSize().width 
			   and vPosition.y > 0 and vPosition.y < minY then 
			    return true
			end
		elseif(_inType == 5)then
			--add by DJN 第二套小伙伴的滑动不做处理
				return false
		elseif(_inType == kChariotType)then
			-- 战车界面滑动不做处理
			return false
	    else
	    	local vPosition = _formationBgSprite:convertToNodeSpace(_touchBeganPoint)
	    	if vPosition.x > 0 and vPosition.x < touchSize.width and vPosition.y > 0 and vPosition.y < touchSize.height then
		    	return true
		    end
		end
		return false
    elseif (eventType == "moved") then
    	local offsetX = x - _touchBeganPoint.x
    	local deltaX = x - _touchLastPoint.x
    	local direction = offsetX < 0 and _kDirection.left or _kDirection.right
    	_touchLastPoint = ccp(x,y)
    	-- 阵容滑动到最后一个时，阵容层不滑动，直接切换
    	if (_inType == 1 and _curIndex == #_formationInfo) then return end

    	--小伙伴、宠物界面，不能横向移动
    	if _inType == 2 or _inType == 3 or _inType == 4 then return end
    	--if _inType == 2 or _inType == 3 or _inType == 4 then return end

    	local curTag = getTagByIndex(_curIndex)
    	local nextTag, nextType = getNextTag(curTag, direction)
    	if nextTag ~= nil and nextType ~= nil then
	    	moveLayerByOffsetX(_inType, nextType, curTag, deltaX, direction)
	    	moveLayerByOffsetX(nextType, nextType, nextTag, deltaX, direction)
	    else
	    	moveLayerByOffsetX(_inType, nextType, curTag, deltaX, direction)
	    end
	elseif eventType == "cancelled" then
		-- do nothing
    else
    	local offsetX = x - _touchBeganPoint.x

    	--小伙伴、宠物界面，角度范围内滑动时不切换
    	local tangent = (y - _touchBeganPoint.y) / offsetX
    	if (_inType == 2 or _inType == 3) and (tangent <= -0.5 or tangent >= 0.5) then
    		return
    	end
    	-- modified by bzx
    	-- if offsetX == 0 then
    	if math.abs(offsetX) < 10 then
    		if _inType == 1 then
	    		heroSpriteCb(_formationInfo[_curIndex]) 
	    	end
    		return
    	end
    	local direction = offsetX < 0 and _kDirection.left or _kDirection.right
    	local curTag = getTagByIndex(_curIndex)
    	local nextTag, nextType = getNextTag(curTag, direction)
    	if nextTag ~= nil and nextTag ~= nil then
	    	moveLayerOut(_inType, nextType, curTag, true, direction)
	    	moveLayerIn(nextType, nextTag, true)
	    else
	    	--moveLayerIn(_inType, curTag, true)
	    	moveCurBack()
	    end
	end
end

-- 创建小伙伴
function createLittleFriendUI()
	-- 小伙伴
	require "script/ui/active/RivalFriendLayer"
	_littleFriendLayer = RivalFriendLayer.createLittleFriendLayer( )
	_littleFriendLayerOriginPosition = ccp( _formationBgSprite:getContentSize().width, 0)
	_littleFriendLayer:setPosition(_littleFriendLayerOriginPosition)
	_littleFriendLayer:setAnchorPoint(ccp(0,0))
	_formationBgSprite:addChild(_littleFriendLayer,1)
end
-- 创建第二套小伙伴
-- add by DJN
function createArrLittleFriendUI()
	-- 小伙伴
	require "script/ui/active/RivalFriendLayer"
	_littleFriendLayer = RivalFriendLayer.createLittleFriendLayer( )
	_littleFriendLayerOriginPosition = ccp( _formationBgSprite:getContentSize().width, 0)
	_littleFriendLayer:setPosition(_littleFriendLayerOriginPosition)
	_littleFriendLayer:setAnchorPoint(ccp(0,0))
	_formationBgSprite:addChild(_littleFriendLayer,1)
end
-- 动画结束回调
function overAnimationDelegate()
	-- print("_isOnAnimation _isOnAnimation ")
	_isOnAnimation = false
end

-- 创建出战宠物的UI
function createPetUI( )
	-- 小伙伴
	require "script/ui/active/RivalPetLayer"
	_petLayer = RivalPetLayer.createPetLayer( )
	_petLayerOriginPosition = ccp( _formationBgSprite:getContentSize().width, 0)
	_petLayer:setPosition(_petLayerOriginPosition)
	_petLayer:setAnchorPoint(ccp(0,0))
	_formationBgSprite:addChild(_petLayer,1)
end

--[[
	@desc 	: 创建装备战车的UI
	@param 	:
	@return :
--]]
function createChariotUI()
	require "script/ui/active/RivalChariotLayer"
	local layerWidth = _formationBgSprite:getContentSize().width
	local layerHeight = _formationBgSprite:getContentSize().height-(topBgSp:getContentSize().height + 20)
	_chariotLayer = RivalChariotLayer.createLayer(CCSizeMake(layerWidth,layerHeight))
	_chariotLayer:setPosition(ccp(_formationBgSprite:getContentSize().width, 0))
	_chariotLayer:setAnchorPoint(ccp(0,0))
	_formationBgSprite:addChild(_chariotLayer,1)
end

function refreshRivalName()
    --changed by DJN 2014/11/03  和服后玩家名字过长显示不全，把玩家名字和军团名字字号缩小
	--_rivalName =CCRenderLabel:create("" .. _tname, g_sFontPangWa, 33, 1,ccc3(0x00,0x00,0x00), type_stroke)
	_rivalName =CCRenderLabel:create("" .. _tname, g_sFontPangWa, 25, 1,ccc3(0x00,0x00,0x00), type_stroke)
	_rivalName:setColor(ccc3(0xff,0xe4,0x00))
	if(_guildName~= nil ) then
		-- _guildNameLabel =CCRenderLabel:create("   [" .. _guildName .. "]", g_sFontPangWa, 32, 1,ccc3(0x00,0x00,0x00), type_stroke)
		_guildNameLabel =CCRenderLabel:create("   [" .. _guildName .. "]", g_sFontPangWa, 24, 1,ccc3(0x00,0x00,0x00), type_stroke)
	else
		--_guildNameLabel =CCRenderLabel:create("", g_sFontPangWa, 32, 1,ccc3(0x00,0x00,0x00), type_stroke)
		_guildNameLabel =CCRenderLabel:create("", g_sFontPangWa, 24, 1,ccc3(0x00,0x00,0x00), type_stroke)
	end
	_guildNameLabel:setColor(ccc3(0xff,0xff,0xff))
	local _titileSprite = CCSprite:create("images/common/title_bg.png")
	local rilavNode= BaseUI.createHorizontalNode({_rivalName, _guildNameLabel})	
	rilavNode:setPosition(ccp( _titileSprite:getContentSize().width*0.5,_titileSprite:getContentSize().height*0.5+3))
	rilavNode:setAnchorPoint(ccp(0.5,0.5))
	_titileSprite:addChild(rilavNode)
	_titileSprite:setPosition(ccp(0, _formationBgSprite:getContentSize().height))
	_titileSprite:setAnchorPoint(ccp(0,1))
	_formationBgSprite:addChild(_titileSprite,2)	
end



-- -- 是否是小伙伴切换到阵型
-- function isFormationToFriend()
	
-- 	if( _curIndex== #_formationInfo ) then
-- 		return true
-- 	end 
-- 	return false
-- end


-- 关闭按钮的回调函数
function closeCb( tag,item )
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
   -- local scene = CCDirector:sharedDirector():getRunningScene()
   --  scene:removeChildByTag(2013,true)

   if(_maskLayer~= nil) then
   		_maskLayer:removeFromParentAndCleanup(true)
   		_maskLayer= nil
   		_bgLayer=nil
    	itemDelegateAction()
    end
end


local function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(layerToucCb,false,-999,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer =nil
	end
end




--[[
	@des 	:弹出查看对手阵容的layer
	@param 	:当不是npc时，uid 为玩家的hid，当是npc时，uid为army表的id,  p_serverId :嘉年华查看跨服的对方阵容时使用
	@retrun :
]]
-- isKufuBattle  是否是跨服比武调用    为真表示是  add by yangrui 15-10-16
function createLayer(uid , isNpc, npcName,menuVisible,avatarVisible,bulletinVisible ,p_pid,p_serverId, isKufuBattle)

	if(uid == 0) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2163"))
		return
	end
	init()
	_isInChariot	= nil 	-- 是否在战车界面
	_chariotLayer 	= nil 	-- 战车界面

	_isNpc = isNpc or false
	RivalInfoData.setNpc(_isNpc)
	_tname = npcName
	-- _menuVisible= menuVisible~=nil or true
	if(menuVisible~= nil) then
		_menuVisible= menuVisible
	end
	if(avatarVisible~= nil) then 
		_avatarVisible= avatarVisible 
	end
	if( bulletinVisible ~= nil ) then 
		_bulletinVisible= bulletinVisible 
	end
		
	require "script/model/user/UserModel"
	_maskLayer = BaseUI.createMaskLayer(-998)

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))
	_bgLayer:registerScriptTouchHandler(layerToucCb,false,-999,true)
	_bgLayer:setTouchEnabled(true)

	_maskLayer:addChild(_bgLayer,0,910)

	local scene = CCDirector:sharedDirector():getRunningScene()
 	scene:addChild(_maskLayer,19000,2013)

	local myScale = MainScene.elementScale
	local layerSize = CCSizeMake(640,802)

 	-- _formationBgSprite = CCSprite:create("images/active/beijing.png") 
 	_formationBgSprite=CCSprite:create()  
 	_formationBgSprite:setContentSize(CCSizeMake(640,804))
 	_formationBgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _formationBgSprite:setAnchorPoint(ccp(0.5,0.5))
  
    _formationBgSprite:setScale(g_fScaleX)
    _bgLayer:addChild(_formationBgSprite)

    _heroPriginPosition = ccp(_formationBgSprite:getContentSize().width/2, 200 )

    	-- 背景
	_backgroundSprite = CCSprite:create("images/formation/formationbg.png")
	_backgroundSprite:setPosition(_formationBgSprite:getContentSize().width/2, 5)
	_backgroundSprite:setAnchorPoint(ccp(0.5,0))
	_formationBgSprite:addChild(_backgroundSprite)

    local leftFrameSp= CCScale9Sprite:create("images/common/frame.png")
    leftFrameSp:setContentSize(CCSizeMake(16, 800))
    leftFrameSp:setPosition(0,1)
    _formationBgSprite:addChild(leftFrameSp,1)

    local rightFrameSp= CCScale9Sprite:create("images/common/frame.png")
    rightFrameSp:setContentSize(CCSizeMake(16, 800))
    rightFrameSp:setPosition(640,1)
    rightFrameSp:setAnchorPoint(ccp(1,0))
    _formationBgSprite:addChild(rightFrameSp,1)



    --
    createTopUI()
    createPropertyUI()
    createUnionUI()
    createMiddleUI()

    -- 网络请求，获取对手的信息
    _uid= uid or  UserModel.getUserUid()

   
    -- local allFormationInfo=  DataCache.getFromation(_uid)
    if(isNpc) then
    	_curIndex =1
	 	_formationInfo= RivalInfoData.getNpcDataById(uid)
		-- print("_formationInfo   is : ")
		-- print_t(allFormationInfo)
		createHeadUI( )
		refreshAllUI()
		refreshRivalName()
    elseif p_serverId then
    	if isKufuBattle then  -- add by yangrui 15-10-16
    		require "script/ui/kfbw/KuafuService"
    		KuafuService.getFighterDetail( p_serverId, p_pid, userBattleCallback )
    	else
	    	require "script/ui/world_carnival/WorldCarnivalService"
	    	WorldCarnivalService.getFighterDetail(userBattleCallback,p_serverId,p_pid)
	    end
    else
	   	local args = CCArray:create()
		args:addObject(CCInteger:create(_uid))
		local args2 =CCArray:create()
		args2:addObject(args)
	    RequestCenter.user_getBattleDataOfUsers(userBattleCallback, args2)
	end

	--MainScene.removeAllChildLayer()

end

----------------------------阵法 函数相关-----------------------------

-- function doOpenPolicy( ... )
-- 	if _isNpc then return false end
-- 	return true
-- end

--移动英雄相关
local function moveHeroLeftByOffsetX( pOffsetX )
	_curHeroSprite:setPositionX(_curHeroSprite:getPositionX() + pOffsetX)
	if _rightHeroSprite ~= nil then
		_rightHeroSprite:setPositionX(_rightHeroSprite:getPositionX() + pOffsetX)
	end
	if _leftHeroSprite ~= nil then
		_leftHeroSprite:setPositionX(_leftHeroSprite:getPositionX() + pOffsetX)
	end
end

function moveHeroRightByOffsetX( pOffsetX )
	_curHeroSprite:setPositionX(_curHeroSprite:getPositionX() + pOffsetX)
	if _leftHeroSprite ~= nil then
		_leftHeroSprite:setPositionX(_leftHeroSprite:getPositionX() + pOffsetX)
	end
	if _rightHeroSprite ~= nil then
		_rightHeroSprite:setPositionX(_rightHeroSprite:getPositionX() + pOffsetX)
	end 
end

local function moveHeroLeftToPosX(pNextTag, pPosX)
	--点击顶部头像按钮，前后不连续时，需要更新右边将要进入的英雄形象
	if _rightIndex ~= pNextTag then
		if _rightHeroSprite ~= nil then
			_rightHeroSprite:removeFromParentAndCleanup(true)
		end
		_rightHeroSprite, _rightHeroOffset = getHeroSopriteByInfo(_formationInfo[pNextTag])
		_rightIndex = pNextTag
		_rightHeroSprite:setPosition(ccp(_formationBgSprite:getContentSize().width*1.5,200-_rightHeroOffset))
		_rightHeroSprite:setAnchorPoint(ccp(0.5,0))
		_formationBgSprite:addChild(_rightHeroSprite)
	end

	_isOnAnimation = true
	local animationDuration = 0.1
	local offsetX = pPosX - _rightHeroSprite:getPositionX()
	_curHeroSprite:stopAllActions()
	_curHeroSprite:runAction(CCMoveTo:create(animationDuration, ccp(_curHeroSprite:getPositionX() + offsetX, _curHeroSprite:getPositionY())))

	local endCb = function ( ... )
		if _leftHeroSprite ~= nil then
			_leftHeroSprite:removeFromParentAndCleanup(true)
			_leftHeroSprite = nil
		end
		local preIndex = pNextTag - 1
		if preIndex < 1 then
			_leftHeroSprite, _leftHeroOffset, _leftIndex = nil, nil, nil
		else
			if _curIndex == preIndex then
				_leftHeroSprite, _leftHeroOffset, _leftIndex = _curHeroSprite, _curHeroOffset, _curIndex
			else
				--因_curIndex ~= preIndex，所以移到左边的_curHeroSprite没用了，需先移除，否则下面第9行会导致内存泄漏
				_curHeroSprite:removeFromParentAndCleanup(true)
				_leftHeroSprite, _leftHeroOffset = getHeroSopriteByInfo(_formationInfo[preIndex])
				_leftIndex = preIndex
				_leftHeroSprite:setPosition(ccp(-_formationBgSprite:getContentSize().width*0.5,200-_leftHeroOffset))
				_leftHeroSprite:setAnchorPoint(ccp(0.5,0))
				_formationBgSprite:addChild(_leftHeroSprite)
			end
		end

		_curHeroSprite, _curHeroOffset, _curIndex = _rightHeroSprite, _rightHeroOffset, _rightIndex

		local nextTag = pNextTag + 1
		if _formationInfo[nextTag] ~= nil then
			_rightHeroSprite, _rightHeroOffset = getHeroSopriteByInfo(_formationInfo[nextTag])
			_rightIndex = nextTag
			_rightHeroSprite:setPosition(ccp(_formationBgSprite:getContentSize().width*1.5,200-_rightHeroOffset))
			_rightHeroSprite:setAnchorPoint(ccp(0.5,0))
			_formationBgSprite:addChild(_rightHeroSprite)
		else
			_rightHeroSprite, _rightHeroOffset, _rightIndex = nil, nil, nil
		end

		updateInData(1, pNextTag)
		-- refreshAllUI()
		_isOnAnimation = false
	end
	_rightHeroSprite:stopAllActions()
	_rightHeroSprite:runAction(CCSequence:createWithTwoActions(
							   CCMoveTo:create(animationDuration, ccp(pPosX, _rightHeroSprite:getPositionY())),
							   CCCallFunc:create(endCb)))
end

local function moveHeroRightToPosX( pNextTag, pPosX )
	--点击顶部头像按钮，前后不连续时，需要更新右边将要进入的英雄形象
	if _leftIndex ~= pNextTag then
		if _leftHeroSprite ~= nil then
			_leftHeroSprite:removeFromParentAndCleanup(true)
		end
		_leftHeroSprite, _leftHeroOffset = getHeroSopriteByInfo(_formationInfo[pNextTag])
		_leftIndex = pNextTag
		_leftHeroSprite:setPosition(ccp(-_formationBgSprite:getContentSize().width*0.5,200-_leftHeroOffset))
		_leftHeroSprite:setAnchorPoint(ccp(0.5,0))
		_formationBgSprite:addChild(_leftHeroSprite)
	end

	_isOnAnimation = true
	local animationDuration = 0.1
	local offsetX = pPosX - _leftHeroSprite:getPositionX()
	_curHeroSprite:stopAllActions()
	_curHeroSprite:runAction(CCMoveTo:create(animationDuration, ccp(_curHeroSprite:getPositionX() + offsetX, _curHeroSprite:getPositionY())))

	local endCb = function ( ... )
		if _rightHeroSprite ~= nil then
			_rightHeroSprite:removeFromParentAndCleanup(true)
			_rightHeroSprite = nil
		end
		local nextIndex = pNextTag + 1
		if nextIndex > #_formationInfo then
			_rightHeroSprite,_rightHeroOffset,_rightIndex = nil, nil, nil
		else
			if _curIndex == nextIndex then
				_rightHeroSprite, _rightHeroOffset, _rightIndex = _curHeroSprite, _curHeroOffset, _curIndex
			else
				--因_curIndex ~= nextIndex，所以移到右边的_curHeroSprite没用了，需先移除，否则下面第9行会导致内存泄漏
				_curHeroSprite:removeFromParentAndCleanup(true)
				_rightHeroSprite, _rightHeroOffset = getHeroSopriteByInfo(_formationInfo[nextIndex])
				_rightIndex = nextIndex
				_rightHeroSprite:setPosition(ccp(_formationBgSprite:getContentSize().width*1.5,200-_rightHeroOffset))
				_rightHeroSprite:setAnchorPoint(ccp(0.5,0))
				_formationBgSprite:addChild(_rightHeroSprite)
			end
		end

		_curHeroSprite, _curHeroOffset, _curIndex = _leftHeroSprite, _leftHeroOffset, _leftIndex

		local preTag = pNextTag - 1
		if _formationInfo[preTag] ~= nil then
			_leftHeroSprite, _leftHeroOffset = getHeroSopriteByInfo(_formationInfo[preTag])
			_leftIndex = preTag
			_leftHeroSprite:setPosition(ccp(-_formationBgSprite:getContentSize().width*0.5,200-_leftHeroOffset))
			_leftHeroSprite:setAnchorPoint(ccp(0.5,0))
			_formationBgSprite:addChild(_leftHeroSprite)
		else
			_leftHeroSprite, _leftHeroOffset, _leftIndex = nil, nil, nil
		end
		
		updateInData(1, pNextTag)
		-- refreshAllUI()
		_isOnAnimation = false
	end
	_leftHeroSprite:stopAllActions()
	_leftHeroSprite:runAction(CCSequence:createWithTwoActions(
							   CCMoveTo:create(animationDuration, ccp(pPosX, _leftHeroSprite:getPositionY())),
							   CCCallFunc:create(endCb)))
end

function moveHeroByOffsetX( pOffsetX, pDirection )
	if pDirection == _kDirection.left then
		moveHeroLeftByOffsetX(pOffsetX)
	else
		moveHeroRightByOffsetX(pOffsetX)
	end
end

function moveHero(pCurTag, pNextTag)
	--英雄形象的anchorpoint ＝ ccp(0.5, 0)
	local direction = pNextTag > pCurTag and _kDirection.left or _kDirection.right
	if direction == _kDirection.left then
		moveHeroLeftToPosX(pNextTag, _formationBgSprite:getContentSize().width*0.5)
	else
		moveHeroRightToPosX(pNextTag, _formationBgSprite:getContentSize().width*0.5)
	end
end

--formation layer 移动相关
function updateHeroSprite( pTag )
	local leftTag, midTag, rightTag = pTag - 1, pTag, pTag + 1
	if _leftHeroSprite ~= nil then
		_leftHeroSprite:removeFromParentAndCleanup(true)
		_leftHeroSprite = nil
	end
	if leftTag < 1 then
		_leftHeroSprite, _leftHeroOffset, _leftIndex = nil, nil, nil
	else
		_leftHeroSprite, _leftHeroOffset = getHeroSopriteByInfo(_formationInfo[leftTag])
		_leftIndex = leftTag
		_leftHeroSprite:setPosition(ccp(-_formationBgSprite:getContentSize().width*0.5,200-_leftHeroOffset))
		_leftHeroSprite:setAnchorPoint(ccp(0.5,0))
		_formationBgSprite:addChild(_leftHeroSprite)
	end

	_curHeroSprite:removeFromParentAndCleanup(true)
	_curHeroSprite, _curHeroOffset = getHeroSopriteByInfo(_formationInfo[midTag])
	-- _curIndex = midTag
	_curHeroSprite:setPosition(ccp(-_formationBgSprite:getContentSize().width*0.5 + _equipMenuNode:getPositionX() + 640,
		                           200-_curHeroOffset))
	_curHeroSprite:setAnchorPoint(ccp(0.5,0))
	_formationBgSprite:addChild(_curHeroSprite)

	if _rightHeroSprite ~= nil then
		_rightHeroSprite:removeFromParentAndCleanup(true)
		_rightHeroSprite = nil
	end
	if rightTag > #_formationInfo then
		_rightHeroSprite, _rightHeroOffset, _rightIndex = nil,nil,nil
	else
		_rightHeroSprite, _rightHeroOffset = getHeroSopriteByInfo(_formationInfo[rightTag])
		_rightIndex = rightTag
		_rightHeroSprite:setPosition(ccp(_formationBgSprite:getContentSize().width*1.5,200-_rightHeroOffset))
		_rightHeroSprite:setAnchorPoint(ccp(0.5,0))
		_formationBgSprite:addChild(_rightHeroSprite)
	end
end

function moveFormationByOffsetX(pTag, pOffsetX)
	-- if _curIndex <= #_formationInfo and pTag ~= _curIndex then
	if pTag ~= _curIndex then
		updateHeroSprite( pTag )
	end
	_equipMenuNode:setPositionX(_equipMenuNode:getPositionX() + pOffsetX)
	_fightSoulMenuBar:setPositionX(_fightSoulMenuBar:getPositionX() + pOffsetX)
	_equipGodWeaponMenu:setPositionX(_equipGodWeaponMenu:getPositionX() + pOffsetX)
	_curHeroSprite:setPositionX(_curHeroSprite:getPositionX() + pOffsetX)
	_bottomBg:setPositionX(_bottomBg:getPositionX() + pOffsetX)
	_bottomBg:setAnchorPoint(ccp(0.5,0))
end

function moveFormationAtPosX(pTag, pPosX)
	local offsetX = pPosX - _equipMenuNode:getPositionX()
	moveFormationByOffsetX(pTag, offsetX)
end

function moveFormationToPosX(pTag, pPosX, endCb)
	--if _curIndex <= #_formationInfo and pTag ~= _curIndex then
	if pTag ~= _curIndex then
		updateHeroSprite( pTag )
	end
	_isOnAnimation = true
	local animationDuration = 0.1
	local offsetX = pPosX - _equipMenuNode:getPositionX()
	_equipMenuNode:runAction(CCMoveTo:create(animationDuration, ccp(_equipMenuNode:getPositionX()+offsetX, _equipMenuNode:getPositionY())))
	_fightSoulMenuBar:runAction(CCMoveTo:create(animationDuration, ccp(_fightSoulMenuBar:getPositionX()+offsetX, _fightSoulMenuBar:getPositionY())))
	_equipGodWeaponMenu:runAction(CCMoveTo:create(animationDuration, ccp(_equipGodWeaponMenu:getPositionX()+offsetX, _equipGodWeaponMenu:getPositionY())))
	_curHeroSprite:runAction(CCMoveTo:create(animationDuration, ccp(_curHeroSprite:getPositionX()+offsetX, _curHeroSprite:getPositionY())))
	_bottomBg:runAction(CCMoveTo:create(animationDuration, ccp(_bottomBg:getPositionX()+offsetX, _bottomBg:getPositionY())))
	_bottomBg:setAnchorPoint(ccp(0.5,0))

	-- 延迟回调
	if endCb ~= nil then
		local overAnimation = CCSequence:createWithTwoActions(CCDelayTime:create(animationDuration+0.05),CCCallFunc:create(endCb))
		_formationBgSprite:runAction(overAnimation)
	end
end

function moveFormationIn( pTag, pAnimated )
	local endCb = function ( ... )
		updateInData(1, pTag)
		_isOnAnimation = false
	end
	if(pAnimated == true)then
		moveFormationToPosX(pTag, 0, endCb)
	else
		moveFormationAtPosX(pTag,0)
		updateInData(1, pTag)
	end
end

function moveFormationOut( pTag, pAnimated, pDirection)
	local endCb = function ( ... )
		updateOutData(pTag)
	end

	local posX = pDirection == _kDirection.right and _formationBgSprite:getContentSize().width or -_formationBgSprite:getContentSize().width
	if(pAnimated == true)then
		moveFormationToPosX(pTag, posX,endCb)
	else
		moveFormationAtPosX(pTag, posX)
		updateOutData(pTag)
	end
end

--little friend layer 移动相关
function moveFriendByOffsetX(pOffsetX)
	_littleFriendLayer:setPositionX(_littleFriendLayer:getPositionX() + pOffsetX)
end

function moveFriendAtPosX(pPosX)
	_littleFriendLayer:setPositionX(pPosX)
end

function moveFriendToPosX( pPosX, endCb )
	_isOnAnimation = true
	local animationDuration = 0.1
	_littleFriendLayer:runAction(CCMoveTo:create(animationDuration, ccp(pPosX, _littleFriendLayer:getPositionY())))

	-- 延迟回调
	if endCb ~= nil then
		local overAnimation = CCSequence:createWithTwoActions(CCDelayTime:create(animationDuration+0.05),CCCallFunc:create(endCb))
		_formationBgSprite:runAction(overAnimation)
	end
end

function moveFriendIn( pAnimated )
	local endCb = function ( ... )
		updateInData(2, _ksTagFriend)
		_isOnAnimation = false
	end

	if(pAnimated == true)then
		moveFriendToPosX(0, endCb)
	else
		moveFriendAtPosX(0)
		updateInData(2, _ksTagFriend)
	end
end

function moveFriendOut( pAnimated, pDirection )
	local endCb = function ( ... )
		updateOutData(_ksTagFriend)
	end

	local posX = pDirection == _kDirection.right and _formationBgSprite:getContentSize().width or -_formationBgSprite:getContentSize().width
	if(pAnimated == true)then
		moveFriendToPosX(posX,endCb)
	else
		moveFriendAtPosX(posX)
		endCb()
	end
end

--pet layer 移动相关
function movePetByOffsetX(pOffsetX)
	_petLayer:setPositionX(_petLayer:getPositionX() + pOffsetX)
end

function movePetAtPosX(pPosX)
	_petLayer:setPositionX(pPosX)
end

function movePetToPosX( pPosX, endCb )
	_isOnAnimation = true
	local animationDuration = 0.1
	_petLayer:runAction(CCMoveTo:create(animationDuration, ccp(pPosX, _petLayer:getPositionY())))

	-- 延迟回调
	if endCb ~= nil then
		local overAnimation = CCSequence:createWithTwoActions(CCDelayTime:create(animationDuration+0.05),CCCallFunc:create(endCb))
		_formationBgSprite:runAction(overAnimation)
	end
end

function movePetIn( pAnimated )
	local endCb = function ( ... )
		updateInData(3, _ksTagPet)
		_isOnAnimation = false
	end
	if(pAnimated == true)then
		movePetToPosX(0, endCb)
	else
		movePetAtPosX(0)
		updateInData(3, _ksTagPet)
	end
end

function movePetOut( pAnimated, pDirection )
	local endCb = function ( ... )
		updateOutData(_ksTagPet)
	end

	local posX = pDirection == _kDirection.right and _formationBgSprite:getContentSize().width or -_formationBgSprite:getContentSize().width
	if(pAnimated == true)then
		movePetToPosX(posX,endCb)
	else
		movePetAtPosX(posX)
		endCb()
	end
end

--other layer 移动相关
function moveOtherByOffsetX(pLayerTag, pOffsetX)
	_layerData[pLayerTag].layer:setPositionX(_layerData[pLayerTag].layer:getPositionX() + pOffsetX)
end

function moveOtherAtPosX(pLayerTag, pPosX)
	_layerData[pLayerTag].layer:setPositionX(pPosX)
end

function moveOtherToPosX( pLayerTag, pPosX, endCb )
	_isOnAnimation = true
	print_t(_layerData)
	local animationDuration = 0.1
	_layerData[pLayerTag].layer:runAction(CCMoveTo:create(animationDuration, ccp(pPosX, _layerData[pLayerTag].layer:getPositionY())))

	-- 延迟回调
	if endCb ~= nil then
		local overAnimation = CCSequence:createWithTwoActions(CCDelayTime:create(animationDuration+0.05),CCCallFunc:create(endCb))
		_formationBgSprite:runAction(overAnimation)
	end			
end

function moveOtherIn( pLayerTag, pAnimated )
	local endCb = function ( ... )
		updateInData(4, pLayerTag)
		_isOnAnimation = false
	end
	if(pAnimated == true)then
		moveOtherToPosX(pLayerTag, 0, endCb)
	else
		moveOtherAtPosX(pLayerTag, 0)
		updateInData(4, pLayerTag)
	end
end

function moveOtherOut( pLayerTag, pAnimated, pDirection )
	local endCb = function ( ... )
		updateOutData(pLayerTag)
	end

	local posX = pDirection == _kDirection.right and _formationBgSprite:getContentSize().width or -_formationBgSprite:getContentSize().width
	if(pAnimated == true)then
		moveOtherToPosX(pLayerTag, posX, endCb)
	else
		moveOtherAtPosX(pLayerTag, posX)
		endCb()
	end
end

-- 战车移动相关 开始 --
--[[
	@desc 	: 移动战车界面至指定OffsetX
	@param 	: pOffsetX 指定偏移
	@return :
--]]
function moveChariotByOffsetX( pOffsetX )
	_chariotLayer:setPositionX(_chariotLayer:getPositionX() + pOffsetX)
end

--[[
	@desc 	: 设置战车界面X坐标
	@param 	: pPosX 指定X坐标
	@return :
--]]
function moveChariotAtPosX( pPosX )
	_chariotLayer:setPositionX(pPosX)
end

--[[
	@desc 	: 移动战车界面至指定PosX
	@param 	: pPosX 指定X坐标 endCb 动画结束回调
	@return :
--]]
function moveChariotToPosX( pPosX, endCb )
	_isOnAnimation = true
	local animationDuration = 0.1
	_chariotLayer:runAction(CCMoveTo:create(animationDuration, ccp(pPosX, _chariotLayer:getPositionY())))

	-- 延迟回调
	if endCb ~= nil then
		local overAnimation = CCSequence:createWithTwoActions(CCDelayTime:create(animationDuration+0.05),CCCallFunc:create(endCb))
		_formationBgSprite:runAction(overAnimation)
	end
end

--[[
	@desc 	: 移进战车界面
	@param 	: pAnimated 是否动画
	@return :
--]]
function moveChariotIn( pAnimated )
	local endCb = function ( ... )
		updateInData(kChariotType, _ksTagChariot)
		_isOnAnimation = false
	end
	if(pAnimated == true)then
		moveChariotToPosX(0, endCb)
	else
		moveChariotAtPosX(0)
		updateInData(kChariotType, _ksTagChariot)
	end
end

--[[
	@desc 	: 移出战车界面
	@param 	: pAnimated 是否动画
	@return :
--]]
function moveChariotOut( pAnimated, pDirection )
	local endCb = function ( ... )
		updateOutData(_ksTagChariot)
	end

	local posX = pDirection == _kDirection.right and _formationBgSprite:getContentSize().width or -_formationBgSprite:getContentSize().width
	if(pAnimated == true)then
		moveChariotToPosX(posX,endCb)
	else
		moveChariotAtPosX(posX)
		endCb()
	end
end

-- 战车移动相关 结束 --

function moveLayerByOffsetX( pType, pNextType, pTag, pOffsetX, pDirection)
	if pType == 1 then
		if (_curIndex == #_formationInfo and pDirection == _kDirection.left  and pNextType ~= nil)
		   or (_curIndex > #_formationInfo and pDirection == _kDirection.right) then
			moveFormationByOffsetX(pTag, pOffsetX)
		else
			--switchNextHero(pTag, pOffsetX)
			moveHeroByOffsetX(pOffsetX, pDirection)
		end
	elseif pType == 2 then
		moveFriendByOffsetX(pOffsetX)
	elseif pType == 3 then
		movePetByOffsetX(pOffsetX)
	elseif pType == kChariotType then
		-- 战车
		moveChariotByOffsetX(pOffsetX)
	else
		moveOtherByOffsetX(pTag, pOffsetX)
	end
end

function updateInData( pType, pTag )
	_curIndex = getIndexByTag(pTag)
	RivalInfoData.setCurIndex(_curIndex)

	refreshStarBg()
	refreshTopUI()
	if pType == 1 then
		refreshAllUI()
	end

	_isInLittleFriend = pType == 2 and true or false
	_isInPet = pType == 3 and true or false
	_isInAttrLittleFriend = pType == 5 and true or false
	-- 战车
	_isInChariot = pType == kChariotType and true or false

	_inType = pType 

	handleUnseletced(_curHeroItem)
	_curHeroItem= _topHeroArr[_curIndex]
	hanleSelected(_curHeroItem)
end

function updateOutData( pTag )
	_lastIndex = getIndexByTag( pTag )
end

function moveLayerIn( pType, pTag, pAnimated )
	if pType == 1 then
		--_curIndex = _lastIndex
		-- _curIndex = pTag
		if _inType ~= 1 then
			moveFormationIn(pTag, pAnimated)
		else
			moveHero(_curIndex, pTag)
		end
		--swicthIndexHero(pTag)
		-- moveHero(_curIndex, pTag)
		-- moveFormationIn(pTag, pAnimated)
	elseif pType == 2 then
		moveFriendIn(pAnimated)
	elseif pType == 3 then
		movePetIn(pAnimated)
	elseif pType == kChariotType then
		--pType == 6 战车
		moveChariotIn(pAnimated)
	else
		--pType == 4
		moveOtherIn(pTag, pAnimated)
	end
end

function moveCurBack()
	local duration = 0.1
	if _inType == 1 then
		_curHeroSprite:runAction(CCMoveTo:create(duration, ccp(_formationBgSprite:getContentSize().width*0.5, _curHeroSprite:getPositionY())))
	elseif _inType == 2 then
		_littleFriendLayer:runAction(CCMoveTo:create(duration, ccp(0, 0)))
	elseif _inType == 3 then
		_petLayer:runAction(CCMoveTo:create(duration, ccp(0, 0)))
	elseif _inType == kChariotType then
		-- 战车
		_chariotLayer:runAction(CCMoveTo:create(duration, ccp(0, 0)))
	else 
		--_inType == 4
		local curTag = getTagByIndex(_curIndex)
		_layerData[curTag].layer:runAction(CCMoveTo:create(duration, ccp(0, 0)))
	-- elseif _inType == 3 then
	-- 	_petLayer:runAction(CCMoveTo:create(duration, ccp(0, 0)))	
	end

end

function moveLayerOut( pType, pNextType, pTag, pAnimated, pDirection )
	if pType == 1 then
		if pType ~= pNextType then
			moveFormationOut(pTag, pAnimated, pDirection)
		end
	elseif pType == 2 then
		moveFriendOut(pAnimated, pDirection)
	elseif pType == 3 then
		movePetOut(pAnimated, pDirection)
	elseif(pType == 4)then
		moveOtherOut(pTag, pAnimated, pDirection)
	elseif(pType == kChariotType)then
		moveChariotOut(pAnimated, pDirection)
	end

	updateOutData(pTag)
end
--得到阵法的index
local function getIndexByTagFor4( pTag )
	local index = 0
	if RivalInfoData.hasFriend() and RivalInfoData.hasPet() then
		index = #_formationInfo+2
	elseif RivalInfoData.hasFriend() or RivalInfoData.hasPet() then
		index = #_formationInfo+1
	else
		index = #_formationInfo
	end

	local count = 1003
	while _layerData[count] ~= nil do
		if _layerData[count].doShowFunc() then
			index = index+1
			if count == pTag then break end
		end
		count = count + 1
	end

	return index
end
--得到阵法的tag
local function getTagByIndexFor4( pIndex )
	local count = 0
	if RivalInfoData.hasFriend() and RivalInfoData.hasPet() then
		count = #_formationInfo+2
	elseif RivalInfoData.hasFriend() or RivalInfoData.hasPet() then
		count = #_formationInfo+1
	else
		count = #_formationInfo
	end
	count = pIndex - count

	local tag = 1003
	while _layerData[tag] ~= nil do
		if _layerData[tag].doShowFunc() then
			count = count - 1
			if count == 0 then break end
		end
		tag = tag + 1
	end
	return tag
end
--得到第二套小伙伴的index add By DJN
local function getIndexByTagForAttr( pTag )
	local index = 0
	index = getIndexByTagFor4() +1
	return index
end
function getIndexByTag( pTag )
	-- local index = 0
	-- if pTag <= #_formationInfo then
	-- 	index = pTag
	-- elseif pTag == _ksTagFriend then
	-- 	index = #_formationInfo + 1
	-- elseif pTag == _ksTagPet then
	-- 	index = #_formationInfo + (RivalInfoData.hasFriend() and 2 or 1)
	-- elseif pTag == _ksTagPolicy then
	-- 	index = getIndexByTagFor4( pTag )
	-- elseif(pTag == _ksTagAttrFriend)then
 --        index  = getIndexByTagForAttr(pTag)
	-- end
	-- return index
	return _indexArray[tonumber(pTag)]
end
--我靠 奇葩函数
function getTagByIndex( pIndex )
	-- local tag = 0
	-- local formationNum = #_formationInfo
	-- if pIndex <= formationNum then
	-- 	tag = pIndex
	-- elseif pIndex == formationNum + 1 then
	-- 	if RivalInfoData.hasFriend() then
	-- 		tag = _ksTagFriend
	-- 	elseif RivalInfoData.hasPet() then
	-- 		tag = _ksTagPet
	-- 	elseif _layerData[_ksTagPolicy].doShowFunc() then
	-- 		tag = getTagByIndexFor4(pIndex)
	-- 	elseif RivalInfoData.hasAttrFriend() then
	-- 		tag = _ksTagAttrFriend
	-- 	end
	-- elseif pIndex == formationNum + 2 then
	-- 		if RivalInfoData.hasPet() then
	-- 			tag = _ksTagPet
	-- 		elseif _layerData[_ksTagPolicy].doShowFunc() then
	-- 			tag = getTagByIndexFor4(pIndex)
	-- 		elseif RivalInfoData.hasAttrFriend() then
	-- 			tag = _ksTagAttrFriend
	-- 		end
	-- elseif pIndex == formationNum + 3 then
	-- 	tag = getTagByIndexFor4(pIndex)
	-- end
	-- return tag
	return _tagArray[tonumber(pIndex)]
end

--用于触摸移动时获取下一个界面的tag 和 type
--当滑动到最右边或最左边时nextTag, nextType = nil, nil
function getNextTag( pCurTag, pDirection )
	local nextTag, nextType = nil, nil
	local formationNum = #_formationInfo
	if pCurTag <= formationNum then
		if pCurTag == formationNum and pDirection == _kDirection.left then
			if RivalInfoData.hasFriend() then
				nextTag, nextType = _ksTagFriend, 2
		    elseif RivalInfoData.hasPet() then
				nextTag, nextType = _ksTagPet, 3
		    else
		    	local count = 1003
		    	while _layerData[count] do
		    		if _layerData[count].doShowFunc() then
		    			break
		    		end
		    		count = count + 1
		    	end

		    	if _layerData[count] then
		    		nextTag, nextType = count, 4
		    	else
		    		-- 最右端 do nothing
		    	end
		    end
	    elseif pCurTag == 1 and pDirection == _kDirection.right then
	    	-- 最左端 do noting
		else
			if pDirection == _kDirection.left then
				nextTag, nextType = pCurTag + 1, 1
			else
				nextTag, nextType = pCurTag - 1, 1
			end
		end
    elseif pCurTag == _ksTagFriend then
    	-- local deltaX = x - _touchBeganPoint.x
    	-- moveFriendByOffsetX(deltaX)
    	if pDirection == _kDirection.left then
    		if RivalInfoData.hasPet() then
    			nextTag, nextType = _ksTagPet, 3
    		else
    			local count = 1003
		    	while _layerData[count] do
		    		if _layerData[count].doShowFunc() then
		    			break
		    		end
		    		count = count + 1
		    	end

		    	if _layerData[count] then
		    		nextTag, nextType = count, 4
		    	else
		    		-- 最右端 do nothing
		    	end
    		end
    	else
    		nextTag, nextType = formationNum, 1
    	end
	elseif pCurTag == _ksTagPet then
    	if pDirection == _kDirection.left then
    		local count = 1003
	    	while _layerData[count] do
	    		if _layerData[count].doShowFunc() then
	    			break
	    		end
	    		count = count + 1
	    	end

	    	if _layerData[count] then
	    		nextTag, nextType = count, 4
	    	else
	    		-- 最右端 do nothing
	    	end
    	else
    		if RivalInfoData.hasFriend() then
    			nextTag, nextType = _ksTagFriend, 2
	    	else
	    		nextTag, nextType = formationNum, 1
	    	end
    	end
    else
    	--pCurTag >= 1003
    	if pDirection == _kDirection.left then
    		local count = pCurTag + 1
	    	while _layerData[count] do
	    		if _layerData[count].doShowFunc() then
	    			break
	    		end
	    		count = count + 1
	    	end
	    	
			if _layerData[count] then
	    		nextTag, nextType = count, 4
	    	else
	    		-- 最右端 do nothing
	    	end
    	else
    		local count = pCurTag - 1
    		while _layerData[count] do
    			if _layerData[count].doShowFunc() then
	    			break
	    		end
	    		count = count - 1
    		end

    		if _layerData[count] then
	    		nextTag, nextType = count, 4
	    	else
	    		-- pCurTag之前没有位于type 4 中的layer
	    		if RivalInfoData.hasPet() then
	    			nextTag, nextType = _ksTagPet, 3
    			elseif RivalInfoData.hasFriend() then
    				nextTag, nextType = _ksTagFriend, 2
    			else
    				nextTag, nextType = formationNum, 1
    			end
	    	end	
    	end
    end	
    return nextTag, nextType
end
--------------------------------------------------------------------------------------
--[[
	@des 	:战魂按钮滑动tebleview
	@param 	:p_index:左1右2
	@return :
--]]
function createInnerView(p_index)
	local fightSoulNum = table.count(_fightSoulPosTable[p_index])
	local cellHeightY = 110

	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(110,cellHeightY)
		elseif fn == "cellAtIndex" then
			a2 = createInnerCell(p_index,fightSoulNum - a1)
			r = a2
		elseif fn == "numberOfCells" then
			r = fightSoulNum
		else
			print("other function")
		end

		return r
	end)

	_scrollOffset = {360 - cellHeightY*fightSoulNum,360 - cellHeightY*fightSoulNum}

	local pingbiLayer = CCLayer:create()
	-- local pingbiLayer = CCLayerColor:create(ccc4(255,0,0,255))

	local cardLayerTouch = function(eventType, x, y)
		local rect = getSpriteScreenRect(pingbiLayer)
		if(rect:containsPoint(ccp(x,y))) then
			return true
		else
			return false
		end
	end

	pingbiLayer:setContentSize(CCSizeMake(105,360))
	pingbiLayer:setTouchEnabled(true)
	pingbiLayer:registerScriptTouchHandler(cardLayerTouch,false,-1009,true)

	local fightSoulView = LuaTableView:createWithHandler(h, CCSizeMake(105,360))
	fightSoulView:setBounceable(true)
	fightSoulView:setTouchPriority(-1012)
	pingbiLayer:addChild(fightSoulView,1,1)
	fightSoulView:ignoreAnchorPointForPosition(false)
	fightSoulView:setAnchorPoint(ccp(0.5,0.5))
	fightSoulView:setPosition(pingbiLayer:getContentSize().width*0.5,pingbiLayer:getContentSize().height*0.48)

	-- 存储tableView
	_fightSoulViewTab[p_index] = fightSoulView

	-- 设置偏移量
	local offset = getViewOffset(p_index)
	if(offset ~= nil)then
		print("offset:",offset)
		fightSoulView:setContentOffset(offset)
	end


	return pingbiLayer
end

--[[
	@des 	:存offset
	@param 	:p_index:左1右2
	@return :
--]]
function saveViewOffset()
	if(tolua.cast(_fightSoulViewTab[1],TOLUA_CAST_TABLEVIEW) ~= nil and tolua.cast(_fightSoulViewTab[2],TOLUA_CAST_TABLEVIEW) ~= nil )then
		print("--saveViewOffset")
		_fightSoulOffsetTab[1] = _fightSoulViewTab[1]:getContentOffset()
		_fightSoulOffsetTab[2] = _fightSoulViewTab[2]:getContentOffset()
		print("_fightSoulOffsetTab[1]",_fightSoulOffsetTab[1],"_fightSoulOffsetTab[2]",_fightSoulOffsetTab[2])
	end
end

--[[
	@des 	:战魂按钮滑动cell
	@param 	:p_index:左1右2
	@return :
--]]
function getViewOffset(p_index)
	return _fightSoulOffsetTab[p_index]
end

--[[
	@des 	:战魂按钮滑动cell
	@param 	:p_index:左1右2，p_pos位置
	@return :
--]]
function createInnerCell(p_index,p_pos)
	local innerCell = CCTableViewCell:create()

	local bgSprite = CCSprite:create("images/common/f_bg.png")
	bgSprite:setAnchorPoint(ccp(0,0))
	bgSprite:setPosition(ccp(0,10))
	innerCell:addChild(bgSprite)

	local item = getFightSoulPositionIcon(_fightSoulPosTable[p_index][p_pos])
	item:setAnchorPoint(ccp(0.5,0.5))
	item:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height/2))
	bgSprite:addChild(item,1,_fightSoulPosTable[p_index][p_pos])

	return innerCell
end

--[[
	@des 	:战魂按钮item
	@param 	:p_pos位置
	@return :
--]]
function getFightSoulPositionIcon( p_pos )
	local menuItemSp = nil

		local fightSoul= _formationInfo[_curIndex].equipInfo.fightSoul
		if( not table.isEmpty(fightSoul) and not table.isEmpty(fightSoul[""..p_pos])) then
			
			menuItemSp = RivalInfoData.getFightSoulItem(fightSoul[""..p_pos],p_pos) 
		else
			local isOpen , openLv= isFightSoulOpenByPos(p_pos)
			if(isOpen == false) then
				menuItemSp = CCSprite:create("images/formation/potential/newlock.png")
			else
				menuItemSp = CCSprite:create()
				menuItemSp:setContentSize(CCSizeMake(50,50))
			end


		end	
	return menuItemSp
end


-- 8个换战魂的按钮
function refreshFightSoulMenu1()
	if(tolua.cast(_fightSoulMenuBar,"CCMenu") ~= nil)then
		_fightSoulMenuBar:removeFromParentAndCleanup(true)
		_fightSoulMenuBar = nil
	end
	_fightSoulMenuBar = CCMenu:create()
	_equipMenuOriginPosition = ccp(0, 0)
	_fightSoulMenuBar:setPosition(_equipMenuOriginPosition)
	bgLayer:addChild(_fightSoulMenuBar,3)

	-- 顺序 
	local btnXPositions = {0.15, 0.85, 0.15, 0.85, 0.15, 0.85, 0.15, 0.85}
	local btnYPositions = {0.75, 0.75, 0.61, 0.61, 0.47, 0.47, 0.33, 0.33}

	local icon_file = "images/common/f_bg.png"

	local hid = m_formationInfo[curHeroIndex]

	for btnIndex,xScale in pairs(btnXPositions) do
		local menuItem = CCMenuItemImage:create(icon_file, icon_file)
		
		if(hid>0)then
			local isOpen, openLv = FormationUtil.isFightSoulOpenByPos(btnIndex)
			if( isOpen == true)then
				local fightSoulInfos = nil
				if(hid>0)then
					local heroRemoteInfo = nil
					local allHeros = HeroModel.getAllHeroes()
					for t_hid, t_hero in pairs(allHeros) do
						if( tonumber(t_hid) ==  hid) then
							heroRemoteInfo = t_hero
							break
						end
					end
					fightSoulInfos = heroRemoteInfo.equip.fightSoul
				end
				if( (not table.isEmpty(fightSoulInfos) ) and ( not table.isEmpty(fightSoulInfos["" .. btnIndex]) ) )then
					-- 有战魂
					local fightSoulInfo = fightSoulInfos["" .. btnIndex]
					-- getItemSpriteById( item_tmpl_id, item_id, itemDelegateAction, isNeedChangeBtn, menu_priority, zOrderNum, info_layer_priority, isRobTreasure, isDisplayLevel, enhanceLv )
					local t_menuItem = ItemSprite.getItemSpriteById(tonumber(fightSoulInfo.item_template_id), tonumber(fightSoulInfo.item_id), FormationLayer.equipInfoDelegeate, true, -240, nil, -550, nil, true, tonumber(fightSoulInfo.va_item_text.fsLevel))
					-- local t_menuItem = ItemSprite.getItemSpriteById(tonumber(fightSoulInfo.item_template_id), tonumber(fightSoulInfo.item_id), nil, true)
					-- 名称
					local equipDesc = ItemUtil.getItemById(tonumber(fightSoulInfo.item_template_id))
					local nameColor = HeroPublicLua.getCCColorByStarLevel(equipDesc.quality)
					local e_nameLabel =  CCRenderLabel:create(equipDesc.name , g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
				    e_nameLabel:setColor(nameColor)
				    e_nameLabel:setAnchorPoint(ccp(0.5, 0))
				    e_nameLabel:setPosition(ccp( t_menuItem:getContentSize().width/2, -t_menuItem:getContentSize().height*0.1))
				    t_menuItem:addChild(e_nameLabel, 4)

					menuItem:addChild(t_menuItem)
				else
					-- 未添加战魂
					menuItem:registerScriptTapHandler(fightSoulAction)
				
					local iconSp = CCSprite:create("images/formation/potential/newadd.png")
					iconSp:setAnchorPoint(ccp(0.5, 0.5))
					iconSp:setPosition(ccp(menuItem:getContentSize().width*0.5, menuItem:getContentSize().height*0.5))
					menuItem:addChild(iconSp)

					local arrActions_2 = CCArray:create()
					arrActions_2:addObject(CCFadeOut:create(1))
					arrActions_2:addObject(CCFadeIn:create(1))
					local sequence_2 = CCSequence:create(arrActions_2)
					local action_2 = CCRepeatForever:create(sequence_2)
					iconSp:runAction(action_2)
					
				end
			else
				
				local lockSp = CCSprite:create("images/formation/potential/newlock.png")
				lockSp:setAnchorPoint(ccp(0.5, 0.5))
				lockSp:setPosition(ccp(menuItem:getContentSize().width/2, menuItem:getContentSize().height*0.5))
				menuItem:addChild(lockSp)
				-- if( tonumber(btnIndex) <=6 )then
				
					local tipLabel = CCRenderLabel:create( openLv, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
				    tipLabel:setAnchorPoint(ccp(0.5, 0.5))
				    tipLabel:setColor(ccc3(0xff, 0xff, 0xff))
				    tipLabel:setPosition(ccp( menuItem:getContentSize().width* 0.5, menuItem:getContentSize().height*0.7))
				    menuItem:addChild(tipLabel)
				    menuItem:registerScriptTapHandler(fightSoulAction)

				    local openLvSp = CCSprite:create("images/formation/potential/jikaifang.png")
					openLvSp:setAnchorPoint(ccp(0.5, 0.5))
					openLvSp:setPosition(ccp(menuItem:getContentSize().width*0.5, menuItem:getContentSize().height*0.4))
					menuItem:addChild(openLvSp)
				-- else
				-- 	local tipLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3325"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
				--     tipLabel:setAnchorPoint(ccp(0.5, 0.5))
				--     tipLabel:setColor(ccc3(0xff, 0xff, 0xff))
				--     tipLabel:setPosition(ccp( menuItem:getContentSize().width* 0.5, menuItem:getContentSize().height*0.5))
				--     menuItem:addChild(tipLabel)
				-- end
			end
		else
			
			menuItem:registerScriptTapHandler(fightSoulAction)
		end
		
		menuItem:setAnchorPoint(ccp(0.5, 0.5))
		menuItem:setPosition(MainScene.getMenuPositionInTruePoint(bgLayer:getContentSize().width*xScale,bgLayer:getContentSize().height*btnYPositions[btnIndex]))
		
		_fightSoulMenuBar:addChild(menuItem, 1, btnIndex)


	end

	if(_curFormationType == FORMATION_TYPE_FIGHTSOUL)then
		setFightSoulVisible(true)
	else
		setFightSoulVisible(false)
	end
end

function createShiningArrow(p_parent,p_direction)

	local imagesPath = nil
	local posY = nil
	local arrowSp = CCSprite:create("images/common/xiajiao.png")
	arrowSp:setAnchorPoint(ccp(0.5,0))
	if p_direction == tagUp then
		arrowSp:setRotation(180)
		posY = p_parent:getContentSize().height -20
	else
		
		posY =  -10
	end
	arrowSp:setPosition(p_parent:getContentSize().width/2,posY)
	p_parent:addChild(arrowSp,10,p_direction)

	--动画
	local arrActions = CCArray:create()
	arrActions:addObject(CCFadeOut:create(1))
	arrActions:addObject(CCFadeIn:create(1))
	local sequence = CCSequence:create(arrActions)
	local action = CCRepeatForever:create(sequence)
	arrowSp:runAction(action)
end
function arrowVisible(p_parent,p_direction,p_visible)
	tolua.cast(p_parent:getChildByTag(p_direction),"CCSprite"):setVisible(p_visible)
end
function updateArrow()
	for i = 1,2 do
		local innerTableViewBg = tolua.cast(_fightSoulMenuBar:getChildByTag(i),"CCScale9Sprite")
		local pingbiLayer = tolua.cast(innerTableViewBg:getChildByTag(111),"CCLayer")
		local innerTableView = tolua.cast(pingbiLayer:getChildByTag(1),TOLUA_CAST_TABLEVIEW)

		if innerTableView ~= nil then
			local contentOffset = innerTableView:getContentOffset()
			if tonumber(innerTableView:getContentOffset().y) <= _scrollOffset[i] then
				arrowVisible(pingbiLayer,tagUp,false)
				arrowVisible(pingbiLayer,tagDown,true)
			elseif tonumber(innerTableView:getContentOffset().y) >= 0 then
				arrowVisible(pingbiLayer,tagDown,false)
				arrowVisible(pingbiLayer,tagUp,true)
			else
				arrowVisible(pingbiLayer,tagUp,true)
				arrowVisible(pingbiLayer,tagDown,true)
			end
		end
	end
end
