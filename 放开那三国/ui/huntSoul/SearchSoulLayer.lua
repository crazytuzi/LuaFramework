-- FileName: SearchSoulLayer.lua 
-- Author: Li Cong 
-- Date: 14-2-11 
-- Purpose: function description of module 


module("SearchSoulLayer", package.seeall)
require "script/ui/item/ItemUtil"
require "script/model/user/UserModel"

local _bgLayer 				= nil
local _bgSprite 			= nil
local _lineSprite 			= nil
local _topTableView 		= nil
local _fsoulData            = {}
local _curShowId 			= nil
local _curShowCost 			= nil
local _needGoldNum 			= nil
local _shenOpneId 			= nil
local _needItemId 			= nil
local lie_goldIcon 			= nil
local lie_goldFont 			= nil
local shenNumFont 	        = nil
local someroMenuItem		= nil
local huntMenuItem          = nil
local shen_goldIcon 		= nil
local longzhuAnimSprite     = nil
local dengAnimSprite1 		= nil
local dengAnimSprite2 		= nil
local liziAnimSprite1		= nil
local liziAnimSprite2		= nil
local _placeName 			= nil
local _dengName 			= nil
local _liziName             = nil
local _fnLizicallFun 		= nil
local liZimaskLayer 		= nil
local shenLiZiAnimSprite    = nil
local shenLongAnimSprite    = nil
local shenLongMaskLayer     = nil
local longzhuArray 			= {}
local moveMaskLayer 		= nil
local name_bg 				= nil
local name_sprite			= nil 
local _shenlonglingNum 		= 0
local _ninePosTable         = {
		-- 1
		{ pos = ccp(58,582), spriteScale = 0.4, sprite = nil, zorde = 10, placeId = nil},
		-- 2
		{ pos = ccp(80,562), spriteScale = 0.5, sprite = nil, zorde = 20, placeId = nil},
		-- 3
		{ pos = ccp(112,540), spriteScale = 0.7, sprite = nil, zorde = 30, placeId = nil},
		-- 4
		{ pos = ccp(170,508), spriteScale = 0.8, sprite = nil, zorde = 40, placeId = nil},
		-- 5
		{ pos = ccp(310,490), spriteScale = 1.0, sprite = nil, zorde = 50, placeId = nil},
		-- 6
		{ pos = ccp(471,508), spriteScale = 0.8, sprite = nil, zorde = 40, placeId = nil},
		-- 7
		{ pos = ccp(529,540), spriteScale = 0.7, sprite = nil, zorde = 30, placeId = nil},
		-- 8
		{ pos = ccp(562,562), spriteScale = 0.5, sprite = nil, zorde = 20, placeId = nil},
		-- 9
		{ pos = ccp(584,582), spriteScale = 0.4, sprite = nil, zorde = 10, placeId = nil},
	}

local _iconSpriteArr 		= {}
local _flyMaskLayer 		= nil
local _bombAnimSprite 		= nil
local _fsoulIconArr 		= {}

local _juhunzhuNum 			= 0
local _lianhunyinNun  		= 0
local _juNumFont  			= nil
local _lianNumFont 			= nil
local _fsExpNumFont 		= nil

-- 是否开开启额外掉落活动
local _isActivity 			= false

-- 初始化
function init( ... )
	_bgLayer 				= nil
	_bgSprite 				= nil
	_lineSprite 			= nil
	_topTableView 			= nil
	_fsoulData           	= {}
	_curShowId 				= nil
	_needGoldNum 			= nil
 	_shenOpneId 			= nil
	_needItemId 			= nil
	_curShowCost 			= nil
	lie_goldIcon 			= nil
	lie_goldFont 			= nil
	shenNumFont 	        = nil
	someroMenuItem			= nil
	huntMenuItem          	= nil
	shen_goldIcon 			= nil
	dengAnimSprite1 		= nil
	dengAnimSprite2 		= nil
	liziAnimSprite1			= nil
	liziAnimSprite2			= nil
	_placeName 				= nil
	_dengName 				= nil
	_liziName             	= nil
	_fnLizicallFun 			= nil
	liZimaskLayer 			= nil
	shenLiZiAnimSprite   	= nil
	shenLongAnimSprite   	= nil
	shenLongMaskLayer       = nil
	longzhuArray 			= {}
	moveMaskLayer 			= nil
	name_bg 				= nil
	name_sprite				= nil
	_shenlonglingNum 		= 0

	_iconSpriteArr 			= {}

	_flyMaskLayer 			= nil
	_fsoulIconArr 			= {}
	_isActivity 			= false

	_juhunzhuNum 			= 0
	_lianhunyinNun  		= 0
	_juNumFont  			= nil
	_lianNumFont 			= nil
	_fsExpNumFont 			= nil
end

-- 背包数据特殊操作
-- 添加新获得的战魂
-- t_newF:新战魂
function addNewFSData( t_newF )
	if( table.isEmpty(t_newF) )then 
		return
	end
	for k,v in pairs(t_newF) do
		local temp = {}
		temp.item_id = k
		temp.item_template_id = v
		table.insert(_fsoulData,temp)
	end
	local function fnSortFun( a, b )
        return tonumber(a.item_id) < tonumber(b.item_id)
    end 
	table.sort( _fsoulData, fnSortFun )
end

-- 刷新获得的材料数量
function addNewMaterialData( p_material )
	if( table.isEmpty(p_material) )then 
		return
	end
	for k,v in pairs(p_material) do
		if( tonumber(k) == 60033 )then
			-- 聚魂珠
			_juhunzhuNum = _juhunzhuNum + tonumber(v)
		elseif( tonumber(k) == 60034 )then
			-- 炼魂印
			_lianhunyinNun = _lianhunyinNun + tonumber(v)
		else
		end
	end

	if( not tolua.isnull(_juNumFont) )then 
		_juNumFont:setString(_juhunzhuNum)
	end
	if( not tolua.isnull(_lianNumFont) )then  
		_lianNumFont:setString(_lianhunyinNun)
	end
	if( not tolua.isnull(_fsExpNumFont) )then 
		_fsExpNumFont:setString(UserModel.getFSExpNum())
	end
end



-- 初始化界面
function initSearchSoulLayer( ... )
    -- 分界线
    _lineSprite = CCScale9Sprite:create("images/hunt/down_line.png")
    _lineSprite:setAnchorPoint(ccp(0.5,0.5))
    _lineSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.62))
    _bgLayer:addChild(_lineSprite,10)
    _lineSprite:setScale(g_fScaleX)

    -- 按钮
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    _bgLayer:addChild(menuBar)

    -- 召唤神龙
    someroMenuItem = CCMenuItemImage:create("images/hunt/somero_n.png","images/hunt/somero_h.png")
    someroMenuItem:setAnchorPoint(ccp(0.5,0.5))
    someroMenuItem:setPosition(_bgLayer:getContentSize().width*0.15,120*g_fScaleX)
    menuBar:addChild(someroMenuItem)
    someroMenuItem:registerScriptTapHandler(someroMenuAction)
    someroMenuItem:setScale(g_fScaleX)

    -- 猎魂
    huntMenuItem = CCMenuItemImage:create("images/hunt/hunt_n.png","images/hunt/hunt_h.png")
    huntMenuItem:setAnchorPoint(ccp(0.5,0.5))
    huntMenuItem:setPosition(_bgLayer:getContentSize().width*0.5,90*g_fScaleX)
    menuBar:addChild(huntMenuItem)
    huntMenuItem:registerScriptTapHandler(huntMenuAction)
    huntMenuItem:setScale(g_fScaleX)
    -- 价格
    lie_goldIcon = CCSprite:create("images/common/coin.png")
	lie_goldIcon:setAnchorPoint(ccp(0, 0))
	_bgLayer:addChild(lie_goldIcon)
	lie_goldIcon:setScale(g_fScaleX)
	lie_goldFont = CCRenderLabel:create(_curShowCost, g_sFontName, 21, 1, ccc3(0, 0, 0), type_stroke)
	lie_goldFont:setColor(ccc3(0xff, 0xe4, 0x00))
	lie_goldFont:setAnchorPoint(ccp(0, 0))
	_bgLayer:addChild(lie_goldFont)
	lie_goldFont:setScale(g_fScaleX)
	-- 居中
	local posX = huntMenuItem:getPositionX()-(lie_goldIcon:getContentSize().width+lie_goldFont:getContentSize().width)*0.5*g_fScaleX
	local posY = huntMenuItem:getPositionY()+huntMenuItem:getContentSize().height*0.5*g_fScaleX
	lie_goldIcon:setPosition(posX, posY)
	lie_goldFont:setPosition(lie_goldIcon:getPositionX()+lie_goldIcon:getContentSize().width*g_fScaleX+2*g_fScaleX, posY+4*g_fScaleX)

	-- 掉材料提示
	local lvNum = HuntSoulData.getSoulMaterialLv() 
	 local textInfo = {
     		width = 640, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontPangWa,      -- 默认字体
	        labelDefaultSize = 20,          -- 默认字体大小
	        labelDefaultColor = ccc3(0xff, 0xe4, 0x00),
	        linespace = 10, -- 行间距
	        defaultType = "CCRenderLabel",
	        elements =
	        {	
	        	{
	            	type = "CCRenderLabel", 
	            	text = lvNum,
	            	color = ccc3(0xff, 0x00, 0xe1),
	        	}
	        }
	 	}
 	local tipDes = GetLocalizeLabelSpriteBy_2("lic_1654", textInfo)
    tipDes:setAnchorPoint(ccp(0.5,1))
    tipDes:setPosition(ccp(huntMenuItem:getContentSize().width*0.5,0))
    huntMenuItem:addChild(tipDes)

    -- 快速猎魂按钮
    local huntTenMenuItem = CCMenuItemImage:create("images/hunt/quick_n.png","images/hunt/quick_h.png")
    huntTenMenuItem:setAnchorPoint(ccp(0.5,0.5))
    huntTenMenuItem:setPosition(_bgLayer:getContentSize().width*0.85,120*g_fScaleX)
    menuBar:addChild(huntTenMenuItem)
    huntTenMenuItem:registerScriptTapHandler(quickHuntMenuAction)
    huntTenMenuItem:setScale(g_fScaleX)
    -- 猎十次 开启条件
    local isOpne,needLeve,needVip = HuntSoulData.getIsOpenHuntTen()
    if(isOpne)then
    	-- 不显示
    else
    	local goldFont = CCRenderLabel:create(string.format(GetLocalizeStringBy("key_3149"),needVip) .. needLeve ..GetLocalizeStringBy("key_2469") , g_sFontName, 21, 1, ccc3(0, 0, 0), type_stroke)
		goldFont:setColor(ccc3(0xff, 0xe4, 0x00))
		goldFont:setAnchorPoint(ccp(0, 1))
		_bgLayer:addChild(goldFont)
		goldFont:setScale(g_fScaleX)
		-- 居中
		local posX = huntTenMenuItem:getPositionX()-goldFont:getContentSize().width*0.5*g_fScaleX
		local posY = huntTenMenuItem:getPositionY()-huntTenMenuItem:getContentSize().height*0.5*g_fScaleX-5*g_fScaleX
		goldFont:setPosition(posX, posY-4*g_fScaleX)
    end
	
	-- 创建上部分tableView
	createTopTableView()

	-- 创建龙珠
	initLongzhu()
	
	-- 创建灯光
	createDeng()

	-- 场景名字
	name_bg = CCScale9Sprite:create("images/hunt/name_bg.png")
	name_bg:setContentSize(CCSizeMake(120,50))
	name_bg:setAnchorPoint(ccp(0.5,0.5))
	name_bg:setPosition(ccp(310,580))
	_bgSprite:addChild(name_bg,100)
	createPlaceName(_curShowId)

	-- 急速速猎魂按钮
	local isOpne,seeLv,useLv = HuntSoulData.getIsOpenFlyHunt()
	if( UserModel.getHeroLevel() >= seeLv )then
	    _flyHuntMenuItem = CCMenuItemImage:create("images/hunt/fly_n.png","images/hunt/fly_h.png")
	    _flyHuntMenuItem:setAnchorPoint(ccp(0.5,0.5))
	    _flyHuntMenuItem:setPosition(_bgLayer:getContentSize().width*0.85,220*g_fScaleX)
	    menuBar:addChild(_flyHuntMenuItem)
	    _flyHuntMenuItem:registerScriptTapHandler(flyHuntMenuItemMenuAction)
	    _flyHuntMenuItem:setScale(g_fScaleX)
	end

	-- 聚魂珠
	local juFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1729"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    juFont:setColor(ccc3(0xe4,0x00,0xff))
    juFont:setAnchorPoint(ccp(1,0.5))
    juFont:setPosition(ccp(95*g_fElementScaleRatio,_lineSprite:getPositionY()-_lineSprite:getContentSize().height*0.5*g_fScaleX-20*g_fElementScaleRatio))
    _bgLayer:addChild(juFont)
    juFont:setScale(g_fElementScaleRatio)

    -- 聚魂珠图标
    local juSp = CCSprite:create("images/common/juhunzhu_s.png")
    juSp:setAnchorPoint(ccp(0,0.5))
    juSp:setPosition(ccp(juFont:getContentSize().width,juFont:getContentSize().height*0.5-2))
    juFont:addChild(juSp)

    -- 聚魂珠数量
    _juNumFont = CCRenderLabel:create(_juhunzhuNum, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _juNumFont:setColor(ccc3(0x00,0xff,0x18))
    _juNumFont:setAnchorPoint(ccp(0,0.5))
    _juNumFont:setPosition(ccp(juSp:getContentSize().width+juSp:getPositionX(),juSp:getPositionY()))
    juFont:addChild(_juNumFont)

	-- 炼魂印
	local lianFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1730"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lianFont:setColor(ccc3(0xe4,0x00,0xff))
    lianFont:setAnchorPoint(ccp(1,0.5))
    lianFont:setPosition(ccp(juFont:getPositionX(),juFont:getPositionY()-juFont:getContentSize().height*0.5*g_fElementScaleRatio-20*g_fElementScaleRatio))
    _bgLayer:addChild(lianFont)
    lianFont:setScale(g_fElementScaleRatio)

    -- 炼魂印图标
    local lianSp = CCSprite:create("images/common/lianhunyin_s.png")
    lianSp:setAnchorPoint(ccp(0,0.5))
    lianSp:setPosition(ccp(lianFont:getContentSize().width,lianFont:getContentSize().height*0.5-2))
    lianFont:addChild(lianSp)

    -- 炼魂印数量
    _lianNumFont = CCRenderLabel:create(_lianhunyinNun, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _lianNumFont:setColor(ccc3(0x00,0xff,0x18))
    _lianNumFont:setAnchorPoint(ccp(0,0.5))
    _lianNumFont:setPosition(ccp(lianSp:getContentSize().width+lianSp:getPositionX(),lianSp:getPositionY()))
    lianFont:addChild(_lianNumFont)

    -- 战魂经验
	local fsExpFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1733"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fsExpFont:setColor(ccc3(0xe4,0x00,0xff))
    fsExpFont:setAnchorPoint(ccp(1,0.5))
    fsExpFont:setPosition(ccp(lianFont:getPositionX(),lianFont:getPositionY()-lianFont:getContentSize().height*0.5*g_fElementScaleRatio-20*g_fElementScaleRatio))
    _bgLayer:addChild(fsExpFont)
    fsExpFont:setScale(g_fElementScaleRatio)

    -- 战魂经验图标
    local fsExpSp = CCSprite:create("images/common/fs_exp_small.png")
    fsExpSp:setAnchorPoint(ccp(0,0.5))
    fsExpSp:setPosition(ccp(fsExpFont:getContentSize().width,fsExpFont:getContentSize().height*0.5-2))
    fsExpFont:addChild(fsExpSp)

    -- 战魂经验数量
    _fsExpNumFont = CCRenderLabel:create(UserModel.getFSExpNum(), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _fsExpNumFont:setColor(ccc3(0x00,0xff,0x18))
    _fsExpNumFont:setAnchorPoint(ccp(0,0.5))
    _fsExpNumFont:setPosition(ccp(fsExpSp:getContentSize().width+fsExpSp:getPositionX(),fsExpSp:getPositionY()))
    fsExpFont:addChild(_fsExpNumFont)
end

-- 创建场景名称
function createPlaceName( curShowId )
	local data = {"name_hui","name_lv","name_lan","name_zi","name_cheng"}
	if(name_sprite)then
		name_sprite:removeFromParentAndCleanup(true)
		name_sprite = nil
	end
	name_sprite = CCSprite:create("images/hunt/" .. data[curShowId] .. ".png")
	name_sprite:setAnchorPoint(ccp(0.5,0.5))
	name_sprite:setPosition(name_bg:getContentSize().width*0.5,name_bg:getContentSize().height*0.5)
	name_bg:addChild(name_sprite)
end


-- 创建上部分tableView 猎取的战魂
function createTopTableView( ... )
	_fsoulData = HuntSoulData.getFSBagSortByItemId()
	local cellSize = CCSizeMake(610,120)		--计算cell大小
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			r = CCSizeMake(cellSize.width*g_fScaleX, cellSize.height*g_fScaleX)
		elseif (fn == "cellAtIndex") then
		    a2 = CCTableViewCell:create()
		    a2:setContentSize(cellSize)
			local posArrX = {0.1,0.3,0.5,0.7,0.9}
			for i=1,5 do
				if(_fsoulData[a1*5+i] ~= nil)then
					-- print("++++ ++++")
					-- print_t(_fsoulData[a1*5+i])
					local itmeInfo = ItemUtil.getItemInfoByItemId(tonumber(_fsoulData[a1*5+i].item_id))
					local enhanceLv = 0
					if(itmeInfo ~= nil)then
						enhanceLv = tonumber(itmeInfo.va_item_text.fsLevel)
					end
					local iconSprite = ItemSprite.getItemSpriteById( tonumber(_fsoulData[a1*5+i].item_template_id), tonumber(_fsoulData[a1*5+i].item_id),refreshRecast,nil,-131,nil, -300, nil, true, enhanceLv)
					iconSprite:setAnchorPoint(ccp(0.5,0.5))
					iconSprite:setPosition(ccp(610*posArrX[i],120-iconSprite:getContentSize().height*0.5))
					a2:addChild(iconSprite)
					-- 名字
					-- print("---------- ",_fsoulData[a1*5+i].item_template_id)
					local itemData = ItemUtil.getItemById(_fsoulData[a1*5+i].item_template_id)
					-- print("*** itemData")
					-- print_t(itemData)
					local name_color = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
					local iconName = CCLabelTTF:create(itemData.name,g_sFontName,18)
					iconName:setColor(name_color)
					iconName:setAnchorPoint(ccp(0.5,0.5))
					iconName:setPosition(ccp(iconSprite:getContentSize().width*0.5,-10))
					iconSprite:addChild(iconName)
					-- 添加到数据按钮中 以itemId为key
					_fsoulIconArr[tonumber(_fsoulData[a1*5+i].item_id)] = iconSprite
				end
			end
			r = a2
			r:setScale(g_fScaleX)
		elseif (fn == "numberOfCells") then
			num = #_fsoulData
			r = math.ceil(num/5)
		else
		end
		return r
	end)
	local tableViewHeight = _bgLayer:getContentSize().height-_lineSprite:getPositionY()+_lineSprite:getContentSize().height*0.5*g_fScaleX
	-- print(_bgLayer:getContentSize().height)
	-- print("**** tableViewHeight",tableViewHeight)
	_topTableView  = LuaTableView:createWithHandler(handler, CCSizeMake(610*g_fScaleX,tableViewHeight))
	_topTableView:setBounceable(true)
	_topTableView:ignoreAnchorPointForPosition(false)
	_topTableView:setAnchorPoint(ccp(0.5, 0))
	_topTableView:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _lineSprite:getPositionY()-_lineSprite:getContentSize().height*0.5*g_fScaleX+10*g_fScaleX))
	_bgLayer:addChild(_topTableView,2)
	_topTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	if(table.count(_fsoulData) > 10)then
		_topTableView:setContentOffset(ccp(0,0))
	end
	_topTableView:setTouchPriority(-132)
end


function createSkillScrollView( ... )
	-- 创建scrollView
	local tableViewHeight = _bgLayer:getContentSize().height-_lineSprite:getPositionY()+_lineSprite:getContentSize().height*0.5*g_fScaleX
	listScrollView = CCScrollView:create()
	listScrollView:setTouchPriority(-132)
	listScrollView:setViewSize(CCSizeMake(610*g_fScaleX,tableViewHeight))
	listScrollView:setTouchEnabled(true)
    listScrollView:setBounceable(true)
    listScrollView:setDirection(kCCScrollViewDirectionVertical)
	listScrollView:ignoreAnchorPointForPosition(false)
	listScrollView:setAnchorPoint(ccp(0.5, 0))
	listScrollView:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _lineSprite:getPositionY()-_lineSprite:getContentSize().height*0.5*g_fScaleX+10*g_fScaleX))
	_bgLayer:addChild(listScrollView,2)

	local containerLayer = createContainerLayer()
	listScrollView:setContainer(containerLayer)
	containerLayer:setScale(g_fScaleX)
end

function createContainerLayer( ... )
	_fsoulData = HuntSoulData.getFSBagSortByItemId()
	local containerLayer = CCNode:create()
	-- 创建列表
	local fcount = table.count(_fsoulData)
	local row = math.ceil(fcount/5)
	containerLayer:setContentSize(CCSizeMake(610,row*120))
	for i=1,fcount do
		if(_fsoulData[i] ~= nil)then
			-- print("++++ ++++")
			-- print_t(_fsoulData[i])
			local iconSprite = ItemSprite.getItemSpriteById( tonumber(_fsoulData[i].item_template_id), tonumber(_fsoulData[i].item_id),nil,-131)
			iconSprite:setAnchorPoint(ccp(0.5,1))
			containerLayer:addChild(iconSprite)
			-- 名字
			-- print("---------- ",_fsoulData[i].item_template_id)
			local itemData = ItemUtil.getItemById(_fsoulData[i].item_template_id)
			-- print("*** itemData")
			-- print_t(itemData)
			local name_color = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
			local iconName = CCLabelTTF:create(itemData.name,g_sFontName,18)
			iconName:setColor(name_color)
			iconName:setAnchorPoint(ccp(0.5,0.5))
			iconName:setPosition(ccp(iconSprite:getContentSize().width*0.5,-10))
			iconSprite:addChild(iconName)

			-- 保存iconSprite
			_iconSpriteArr[#_iconSpriteArr+1] = iconSprite
		end
    end
	return containerLayer
end

function setIconSpritePosition( ... )
	local posArrX = {0.1,0.3,0.5,0.7,0.9}
	local fcount = table.count(_fsoulData)
	local row = math.ceil(fcount/5)
	local allHeight = row*120
	local curHeight = allHeight
	for i=1,row do
		for j=1,5 do
			if(_iconSpriteArr[(i-1)*5+j])then
				_iconSpriteArr[(i-1)*5+j]:setPosition(ccp(610*posArrX[j],curHeight))
			end
		end
		curHeight = curHeight - 120
	end
end


-- 召唤神龙按钮回调
function someroMenuAction(tag, itemBtn )
	require "script/ui/huntSoul/CallDragonDialog"
	CallDragonDialog.showTip()
end


-- 召唤一次神龙按钮回调
function oneSomeroCallFun( ... )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 战魂背包满了
	if(ItemUtil.isFightSoulBagFull(true))then
		return
	end
	-- 金币不足
	if(UserModel.getGoldNumber() < _needGoldNum and _shenlonglingNum <= 0) then
		require "script/ui/tip/LackGoldTip"
		LackGoldTip.showTip()
		return
	end
	-- 获得当前场景
	_curShowId = HuntSoulData.getHuntPlaceId()
	if(_curShowId >= _shenOpneId)then
		require "script/ui/tip/AnimationTip"
     	AnimationTip.showTip(GetLocalizeStringBy("key_1252"))
		return 
	end
	-- 消耗类型 0是神龙令 1是金币
   	local ntpye = nil
	local function createNextFun( tItems, tExtra)
		if(ntpye == 1)then
			-- 扣除金币
			UserModel.addGoldNumber(-tonumber(_needGoldNum))
		else
			-- 扣除神龙令个数
			_shenlonglingNum = _shenlonglingNum-1
		end
		-- 加物品
		addNewFSData( tItems )
		-- 龙珠移动
		replacePlace()
		-- 刷新
		shenRefreshUI()

		-- 富文本提示
		local textInfo = {}
		textInfo1 = {tipText=GetLocalizeStringBy("key_1091"), color=ccc3(255, 255, 255)}
		table.insert(textInfo,textInfo1)
		for k,v in pairs(tItems) do
			local itemData = ItemUtil.getItemById(v)
			local name_color = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
			local data = {}
			data.tipText = itemData.name
			data.color = name_color
			table.insert(textInfo,data)
		end
		-- 是否有额外掉落
		if(_isActivity)then
			textInfo2 = {tipText=GetLocalizeStringBy("lic_1221"), color=ccc3(255, 255, 255)}
			table.insert(textInfo,textInfo2)
			for k,v in pairs(tExtra) do
				local itemData = ItemUtil.getItemById(k)
				local name_color = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
				local data = {}
				data.tipText = itemData.name .. " * " .. v 
				data.color = name_color
				table.insert(textInfo,data)
			end
		end
		require "script/ui/tip/AnimationTip"
		AnimationTip.showRichTextTip(textInfo)
   	end
   	if(_shenlonglingNum > 0)then
   		-- 有神龙令
   		ntpye = 0
   	else
   		-- 花费金币
   		ntpye = 1
   	end
	HuntSoulService.skip(ntpye,createNextFun)
end

-- 召唤十次神龙按钮回调
function tenSomeroCallFun( ... )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 战魂背包满了
	if(ItemUtil.isFightSoulBagFull(true))then
		return
	end
	-- 道具背包满了
	if(ItemUtil.isPropBagFull(true))then
		return
	end
	-- 获得当前场景
	_curShowId = HuntSoulData.getHuntPlaceId()
	if(_curShowId >= _shenOpneId)then
		require "script/ui/tip/AnimationTip"
     	AnimationTip.showTip(GetLocalizeStringBy("key_1252"))
		return 
	end
	-- 金币不足
	if(UserModel.getGoldNumber() < _needGoldNum and _shenlonglingNum <= 0) then
		require "script/ui/tip/LackGoldTip"
		LackGoldTip.showTip()
		return
	end

	-- 是否能够召唤
	local costShenLonglingNum = 0
	local costGoldNum = 0
	if(_shenlonglingNum > 0)then
		if(_shenlonglingNum >= 10)then
			-- 可以
			costShenLonglingNum = 10
		else
			-- 有神龙令 金币不足 不可以召10次
			if(UserModel.getGoldNumber() < _needGoldNum*(10-_shenlonglingNum)) then
				require "script/ui/tip/LackGoldTip"
				LackGoldTip.showTip()
				return
			else
				-- 可以
				costGoldNum = _needGoldNum*(10-_shenlonglingNum)
				costShenLonglingNum = _shenlonglingNum
			end
		end
	else
		-- 没有神龙令  小于500金币 不可以召10次
		if(UserModel.getGoldNumber() < _needGoldNum*10 ) then
			require "script/ui/tip/LackGoldTip"
			LackGoldTip.showTip()
			return
		else
			-- 可以召唤10次的花费
			costGoldNum = _needGoldNum*10
		end
	end

	-- 小于50万银币 不可以召10次
	if( UserModel.getSilverNumber() < 500000 )then
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("lic_1151"))
        return
	end

	local function createNextFun( tItems, tExtra, p_material )
		--获得的战魂提示板子
		require "script/ui/huntSoul/ShowTenGetDialog"
		ShowTenGetDialog.showTip(tItems, tExtra, p_material)
		-- 加材料
		addNewMaterialData( p_material )
		-- 扣除金币
		UserModel.addGoldNumber(-tonumber(costGoldNum))
		-- 扣除神龙令个数
		_shenlonglingNum = _shenlonglingNum-costShenLonglingNum
		-- 加战魂物品
		for k,v in pairs(tItems) do
			addNewFSData( v )
		end
		-- 刷新背包
		_topTableView:reloadData()
		if(table.count(_fsoulData) > 10)then
			_topTableView:setContentOffset(ccp(0,0))
		end
		-- 龙珠移动
		replacePlace()
		-- 刷新金币数量
		HuntSoulLayer.refreshGold()
		-- 刷新
		refreshAllUI()
   	end
	HuntSoulService.skipHunt(createNextFun)
end

-- 猎魂按钮回调
function huntMenuAction( ... )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 战魂背包满了
	if(ItemUtil.isFightSoulBagFull(true))then
		return
	end
	-- 道具背包满了
	if(ItemUtil.isPropBagFull(true))then
		return
	end
	if(UserModel.getSilverNumber() < _curShowCost) then
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("key_2327"))
        return
    end

	local function createNextFun( tItems, p_white, p_green, p_blue, p_purple, p_exp, p_silver, p_material )
		-- 加材料
		addNewMaterialData( p_material )

		if( not table.isEmpty(tItems) )then  
			-- 添加新物品
			addNewFSData( tItems )
			-- 刷新背包
			local itemId = nil
			for k,v in pairs(tItems) do
				itemId = tonumber(k)
			end
			_topTableView:reloadData()
			if(table.count(_fsoulData) > 10)then
				_topTableView:setContentOffset(ccp(0,0))
			end
			-- 不显示新的
			_fsoulIconArr[itemId]:setVisible(false)
			-- 飞翔动画
			createFlyAction(tItems)

			-- 富文本提示
			local textInfo = {}
			textInfo1 = {tipText=GetLocalizeStringBy("key_1231"), color=ccc3(255, 255, 255)}
			table.insert(textInfo,textInfo1)
			for k,v in pairs(tItems) do
				local itemData = ItemUtil.getItemById(v)
				local name_color = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
				local data = {}
				data.tipText = itemData.name
				data.color = name_color
				table.insert(textInfo,data)
			end

			if( not table.isEmpty(p_material) ) then 
				-- 富文本提示
				textInfo2 = {tipText=GetLocalizeStringBy("lic_1638"), color=ccc3(255, 255, 255)}
				table.insert(textInfo,textInfo2)
				for k,v in pairs(p_material) do
					local itemData = ItemUtil.getItemById(k)
					local name_color = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
					local data = {}
					data.tipText = itemData.name .. "*" .. v
					data.color = name_color
					table.insert(textInfo,data)
				end
			end

			require "script/ui/tip/AnimationTip"
			AnimationTip.showRichTextTip(textInfo)
		else
			-- 龙珠移动
			replacePlace()
			-- 刷新UI
			refreshAllUI()

			if( not table.isEmpty(p_material) ) then 
				-- 富文本提示
				local textInfo = {}
				textInfo1 = {tipText=GetLocalizeStringBy("lic_1638"), color=ccc3(255, 255, 255)}
				table.insert(textInfo,textInfo1)
				for k,v in pairs(p_material) do
					local itemData = ItemUtil.getItemById(k)
					local name_color = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
					local data = {}
					data.tipText = itemData.name .. "*" .. v
					data.color = name_color
					table.insert(textInfo,data)
				end
				require "script/ui/tip/AnimationTip"
				AnimationTip.showRichTextTip(textInfo)
			end
		end
	end
	HuntSoulService.huntSoul(1,createNextFun)
end

-- 快速猎魂按钮回调
function quickHuntMenuAction(tag, itemBtn )
	require "script/ui/huntSoul/QuickHuntDialog"
	QuickHuntDialog.showTip()
end

-- 猎十次按钮回调
function huntTenMenuAction( ... )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local isOpne,needLeve = HuntSoulData.getIsOpenHuntTen()
	if(isOpne == false)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_2946"))
		return
	end
	-- 战魂背包满了
	if(ItemUtil.isFightSoulBagFull(true))then
		return
	end
	-- 道具背包满了
	if(ItemUtil.isPropBagFull(true))then
		return
	end
	-- 银币不足
	local maxCost = HuntSoulData.getMaxCostByNum(10)
	if(UserModel.getSilverNumber() < maxCost) then
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("key_2546") .. maxCost .. GetLocalizeStringBy("key_2897"))
        return
    end
	local function createNextFun( tItems, p_white, p_green, p_blue, p_purple, p_exp, p_silver, p_material )
		-- 加材料
		addNewMaterialData( p_material )
		-- 添加新物品
		addNewFSData( tItems )
		-- 刷新背包
		_topTableView:reloadData()
		if(table.count(_fsoulData) > 10)then
			_topTableView:setContentOffset(ccp(0,0))
		end
		-- 龙珠移动
		replacePlace()
		-- 刷新UI
		refreshAllUI()

		-- 富文本提示
		local textInfo = {}
		textInfo1 = {tipText=GetLocalizeStringBy("key_1231"), color=ccc3(255, 255, 255)}
		table.insert(textInfo,textInfo1)
		for k,v in pairs(tItems) do
			local itemData = ItemUtil.getItemById(v)
			local name_color = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
			local data = {}
			data.tipText = itemData.name
			data.color = name_color
			table.insert(textInfo,data)
		end

		if( not table.isEmpty(p_material) ) then 
			-- 富文本提示
			textInfo2 = {tipText=GetLocalizeStringBy("lic_1638"), color=ccc3(255, 255, 255)}
			table.insert(textInfo,textInfo2)
			for k,v in pairs(p_material) do
				local itemData = ItemUtil.getItemById(k)
				local name_color = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
				local data = {}
				data.tipText = itemData.name .. "*" .. v
				data.color = name_color
				table.insert(textInfo,data)
			end
		end
		require "script/ui/tip/AnimationTip"
		AnimationTip.showRichTextTip(textInfo)
   	end
	HuntSoulService.huntSoul(10,createNextFun)
end

-- 猎魂50次回调
function fiftyHuntCallFun( ... )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local isOpne,needLeve = HuntSoulData.getIsOpenHuntFifty()
	if(isOpne == false)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_2946"))
		return
	end
	-- 战魂背包满了
	if(ItemUtil.isFightSoulBagFull(true))then
		return
	end
	-- 道具背包满了
	if(ItemUtil.isPropBagFull(true))then
		return
	end
	-- 银币不足
	local maxCost = HuntSoulData.getMaxCostByNum(50)
	if(UserModel.getSilverNumber() < maxCost) then
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("key_2546") .. maxCost .. GetLocalizeStringBy("key_2897"))
        return
    end
	local function createNextFun( tItems, p_whiteNum, p_greenNum, p_blueNum, p_purpleNum, p_exp, p_costCoin, p_material )
		-- 加材料
		addNewMaterialData( p_material )
		-- 添加新物品
		addNewFSData( tItems )
		-- 刷新背包
		_topTableView:reloadData()
		if(table.count(_fsoulData) > 10)then
			_topTableView:setContentOffset(ccp(0,0))
		end
		-- 龙珠移动
		replacePlace()
		-- 刷新UI
		refreshAllUI()

		--获得的战魂提示板子
		require "script/ui/huntSoul/ShowFiftyHuntDialog"
		ShowFiftyHuntDialog.showTip(tItems,p_whiteNum, p_greenNum, p_blueNum, p_purpleNum,p_exp, p_costCoin, p_material)
   	end
	HuntSoulService.huntSoul(50,createNextFun)
end

-- 刷新全部UI
function refreshAllUI( ... )
	-- 刷新银币数量
	HuntSoulLayer.refreshCoin()
	-- 刷新当前场景费用
	-- 当前场景id
	_curShowId = HuntSoulData.getHuntPlaceId()
	-- 场景名字
	createPlaceName(_curShowId)
	-- 当前场景花费
	_curShowCost = HuntSoulData.getCostByPlaceId(_curShowId)
	-- 猎魂价格
	if(lie_goldIcon)then
		lie_goldIcon:removeFromParentAndCleanup(true)
		lie_goldIcon = nil
	end
    lie_goldIcon = CCSprite:create("images/common/coin.png")
	lie_goldIcon:setAnchorPoint(ccp(0, 0))
	_bgLayer:addChild(lie_goldIcon)
	lie_goldIcon:setScale(g_fScaleX)
	if(lie_goldFont)then
		lie_goldFont:removeFromParentAndCleanup(true)
		lie_goldFont = nil
	end
	lie_goldFont = CCRenderLabel:create(_curShowCost, g_sFontName, 21, 1, ccc3(0, 0, 0), type_stroke)
	lie_goldFont:setColor(ccc3(0xff, 0xe4, 0x00))
	lie_goldFont:setAnchorPoint(ccp(0, 0))
	_bgLayer:addChild(lie_goldFont)
	lie_goldFont:setScale(g_fScaleX)
	-- 居中
	local posX = huntMenuItem:getPositionX()-(lie_goldIcon:getContentSize().width+lie_goldFont:getContentSize().width)*0.5*g_fScaleX
	local posY = huntMenuItem:getPositionY()+huntMenuItem:getContentSize().height*0.5*g_fScaleX
	lie_goldIcon:setPosition(posX, posY)
	lie_goldFont:setPosition(lie_goldIcon:getPositionX()+lie_goldIcon:getContentSize().width*g_fScaleX+2*g_fScaleX, posY+4*g_fScaleX)

	-- 下一个场景特效
	nextLongZhu()
	if g_system_type == kBT_PLATFORM_ANDROID then
        require "script/utils/LuaUtil"
        checkMem()
    else
        CCTextureCache:sharedTextureCache():removeUnusedTextures()
    end
end

-- 召唤神龙刷新
function shenRefreshUI( ... )
	-- 刷新金币数量
	HuntSoulLayer.refreshGold()
	-- 刷新背包
	_topTableView:reloadData()
	if(table.count(_fsoulData) > 10)then
		_topTableView:setContentOffset(ccp(0,0))
	end
	-- 刷新当前场景费用
	-- 当前场景id
	_curShowId = HuntSoulData.getHuntPlaceId()
	-- 场景名字
	createPlaceName(_curShowId)
	-- 当前场景花费
	_curShowCost = HuntSoulData.getCostByPlaceId(_curShowId)
	-- 猎魂价格
	if(lie_goldIcon)then
		lie_goldIcon:removeFromParentAndCleanup(true)
		lie_goldIcon = nil
	end
    lie_goldIcon = CCSprite:create("images/common/coin.png")
	lie_goldIcon:setAnchorPoint(ccp(0, 0))
	_bgLayer:addChild(lie_goldIcon)
	lie_goldIcon:setScale(g_fScaleX)
	if(lie_goldFont)then
		lie_goldFont:removeFromParentAndCleanup(true)
		lie_goldFont = nil
	end
	lie_goldFont = CCRenderLabel:create(_curShowCost, g_sFontName, 21, 1, ccc3(0, 0, 0), type_stroke)
	lie_goldFont:setColor(ccc3(0xff, 0xe4, 0x00))
	lie_goldFont:setAnchorPoint(ccp(0, 0))
	_bgLayer:addChild(lie_goldFont)
	lie_goldFont:setScale(g_fScaleX)
	-- 居中
	local posX = huntMenuItem:getPositionX()-(lie_goldIcon:getContentSize().width+lie_goldFont:getContentSize().width)*0.5*g_fScaleX
	local posY = huntMenuItem:getPositionY()+huntMenuItem:getContentSize().height*0.5*g_fScaleX
	lie_goldIcon:setPosition(posX, posY)
	lie_goldFont:setPosition(lie_goldIcon:getPositionX()+lie_goldIcon:getContentSize().width*g_fScaleX+2*g_fScaleX, posY+4*g_fScaleX)

	-- 神龙特效
	createShenLong()
	if g_system_type == kBT_PLATFORM_ANDROID then
	    require "script/utils/LuaUtil"
	    checkMem()
	else
	    CCTextureCache:sharedTextureCache():removeUnusedTextures()
	end
end

-- 创建龙珠特效
function getLongZhuNameById( placeId )
	local placeName = nil
	local dengName = nil
	local liziName = nil
	if(tonumber(placeId) == 1)then
		placeName = "lzhui"
	elseif(tonumber(placeId) == 2)then
		placeName = "lzlv"
		dengName = "lvdeng"
		liziName = "dllv"
	elseif(tonumber(placeId) == 3)then
		placeName = "lzlan"
		dengName = "landeng"
		liziName = "dllan"
	elseif(tonumber(placeId) == 4)then
		placeName = "lzzi"
		dengName = "zideng"
		liziName = "dlzi"
	else
		placeName = "lzcheng"
		dengName = "huangdeng"
		liziName = "dlhuang"
	end
	return placeName,dengName,liziName
end

-- 创建粒子特效
function createLiZi( callFun )
	if(_liziName)then
		_fnLizicallFun = callFun
		if(liziAnimSprite1)then
			liziAnimSprite1:release()
			liziAnimSprite1:removeFromParentAndCleanup(true)
			liziAnimSprite1 = nil
		end
		if(liZimaskLayer)then
			liZimaskLayer:removeFromParentAndCleanup(true)
			liZimaskLayer = nil
		end
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		liZimaskLayer = BaseUI.createMaskLayer(-5000,nil,nil,0)
		runningScene:addChild(liZimaskLayer, 10000)
		-- 粒子特效播完回调
		local function fnliziAnimSprite1End( ... )
			if(liziAnimSprite1)then
				liziAnimSprite1:release()
				liziAnimSprite1:removeFromParentAndCleanup(true)
				liziAnimSprite1 = nil
				if(_fnLizicallFun)then
					_fnLizicallFun()
					_fnLizicallFun = nil
				end
				if(liZimaskLayer)then
					liZimaskLayer:removeFromParentAndCleanup(true)
					liZimaskLayer = nil
				end
			end
		end
		local function fnliziAnimSprite2End( ... )
			if(liziAnimSprite2)then
				liziAnimSprite2:release()
				liziAnimSprite2:removeFromParentAndCleanup(true)
				liziAnimSprite2 = nil
			end
		end
		local liziPos1X = {8,10,3,9}
		local liziPosY = {294,357,438,540}
	    liziAnimSprite1 = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/longzhu/lizi/" .. _liziName .. "/" .. _liziName ), -1,CCString:create(""))
	    liziAnimSprite1:setAnchorPoint(ccp(0, 0.5))
	    liziAnimSprite1:setPosition(ccp(liziPos1X[_curShowId-1],liziPosY[_curShowId-1]))
	    _bgSprite:addChild(liziAnimSprite1,888)
	    liziAnimSprite1:retain()
	    -- 注册代理
	    local downDelegate = BTAnimationEventDelegate:create()
	    downDelegate:registerLayerEndedHandler(fnliziAnimSprite1End)
	    liziAnimSprite1:setDelegate(downDelegate)
	  	if(liziAnimSprite2)then
	  		liziAnimSprite2:release()
			liziAnimSprite2:removeFromParentAndCleanup(true)
			liziAnimSprite2 = nil
		end
		local liziPos2X = {632,630,637,631}
	    liziAnimSprite2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/longzhu/lizi/" .. _liziName .. "/" .. _liziName ), -1,CCString:create(""))
	    liziAnimSprite2:setAnchorPoint(ccp(1, 0.5))
	    liziAnimSprite2:setPosition(ccp(liziPos2X[_curShowId-1],liziPosY[_curShowId-1]))
	    _bgSprite:addChild(liziAnimSprite2,888)
	    liziAnimSprite2:retain()
	    liziAnimSprite2:setScaleX(liziAnimSprite2:getScaleX()*-1)
	    -- 注册代理
	    local downDelegate = BTAnimationEventDelegate:create()
	    downDelegate:registerLayerEndedHandler(fnliziAnimSprite2End)
	    liziAnimSprite2:setDelegate(downDelegate)
	else
		callFun()
		if(liZimaskLayer)then
			liZimaskLayer:removeFromParentAndCleanup(true)
			liZimaskLayer = nil
		end
	end
end

function createDeng( ... )
	if(_dengName)then
		if(dengAnimSprite1)then
			dengAnimSprite1:release()
			dengAnimSprite1:removeFromParentAndCleanup(true)
			dengAnimSprite1 = nil
		end
		local dengPos1X = {8,10,3,9}
		local dengPosY = {294,357,438,540}
	    dengAnimSprite1 = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/longzhu/deng/" .. _dengName .. "/" .. _dengName ), -1,CCString:create(""))
	    dengAnimSprite1:setAnchorPoint(ccp(0, 0.5))
	    dengAnimSprite1:setPosition(ccp(dengPos1X[_curShowId-1],dengPosY[_curShowId-1]))
	    _bgSprite:addChild(dengAnimSprite1,888)
	    dengAnimSprite1:retain()
	   if(dengAnimSprite2)then
	   		dengAnimSprite2:release()
			dengAnimSprite2:removeFromParentAndCleanup(true)
			dengAnimSprite2 = nil
		end
		local dengPos2X = {632,630,637,631}
	    dengAnimSprite2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/longzhu/deng/" .. _dengName .. "/" .. _dengName ), -1,CCString:create(""))
	    dengAnimSprite2:setAnchorPoint(ccp(1, 0.5))
	    dengAnimSprite2:setPosition(ccp(dengPos2X[_curShowId-1],dengPosY[_curShowId-1]))
	    _bgSprite:addChild(dengAnimSprite2,888)
	    dengAnimSprite2:setScaleX(dengAnimSprite2:getScaleX()*-1)
	    dengAnimSprite2:retain()
	else
		if(dengAnimSprite1)then
			dengAnimSprite1:release()
			dengAnimSprite1:removeFromParentAndCleanup(true)
			dengAnimSprite1 = nil
		end
		if(dengAnimSprite2)then
			dengAnimSprite2:release()
			dengAnimSprite2:removeFromParentAndCleanup(true)
			dengAnimSprite2 = nil
		end
	end	
end

-- 下一场景龙珠特效
function nextLongZhu( ... )
	local actionArr = CCArray:create()
	actionArr:addObject(CCCallFunc:create(function ( ... )
	    	-- 去除上一个场景的灯光
			if(dengAnimSprite1)then
				dengAnimSprite1:release()
				dengAnimSprite1:removeFromParentAndCleanup(true)
				dengAnimSprite1 = nil
			end
    	end))
	actionArr:addObject(CCDelayTime:create(0.1))
    actionArr:addObject(CCCallFunc:create(function ( ... )
	    	-- 得到下一个特效的名字
			_placeName,_dengName,_liziName = getLongZhuNameById(_curShowId)
			-- 爆下个场景离子特效
			createLiZi( replaceLongZhu )
    	end))
    local seq = CCSequence:create(actionArr)
	_bgSprite:runAction(seq)
end

-- 场景替换特效
function replaceLongZhu( ... )
	if(_dengName)then
		if(dengAnimSprite1)then
			dengAnimSprite1:release()
			dengAnimSprite1:removeFromParentAndCleanup(true)
			dengAnimSprite1 = nil
		end
		local dengPos1X = {8,10,3,9}
		local dengPosY = {294,357,438,540}
	    dengAnimSprite1 = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/longzhu/deng/" .. _dengName .. "/" .. _dengName ), -1,CCString:create(""))
	    dengAnimSprite1:setAnchorPoint(ccp(0, 0.5))
	    dengAnimSprite1:setPosition(ccp(dengPos1X[_curShowId-1],dengPosY[_curShowId-1]))
	    _bgSprite:addChild(dengAnimSprite1,888)
	    dengAnimSprite1:retain()
	   if(dengAnimSprite2)then
	   		dengAnimSprite2:release()
			dengAnimSprite2:removeFromParentAndCleanup(true)
			dengAnimSprite2 = nil
		end
		local dengPos2X = {632,630,637,631}
	    dengAnimSprite2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/longzhu/deng/" .. _dengName .. "/" .. _dengName ), -1,CCString:create(""))
	    dengAnimSprite2:setAnchorPoint(ccp(1, 0.5))
	    dengAnimSprite2:setPosition(ccp(dengPos2X[_curShowId-1],dengPosY[_curShowId-1]))
	    _bgSprite:addChild(dengAnimSprite2,888)
	    dengAnimSprite2:retain()
	    dengAnimSprite2:setScaleX(dengAnimSprite2:getScaleX()*-1)
	else
		if(dengAnimSprite1)then
			dengAnimSprite1:release()
			dengAnimSprite1:removeFromParentAndCleanup(true)
			dengAnimSprite1 = nil
		end
		if(dengAnimSprite2)then
			dengAnimSprite2:release()
			dengAnimSprite2:removeFromParentAndCleanup(true)
			dengAnimSprite2 = nil
		end
	end	
end

-- 创建神龙特效
function createShenLong( ... )
	if(shenLongAnimSprite )then
		shenLongAnimSprite:release()
		shenLongAnimSprite:removeFromParentAndCleanup(true)
		shenLongAnimSprite = nil
	end
	local function fnshenLongAnimSprite( ... )
		if(shenLongAnimSprite )then
			shenLongAnimSprite:release()
			shenLongAnimSprite:removeFromParentAndCleanup(true)
			shenLongAnimSprite = nil
		end
	end
	shenLongAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/longzhu/longbowen/longbowen"), -1,CCString:create(""))
    shenLongAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
    shenLongAnimSprite:setPosition(ccp(310,490))
    _bgSprite:addChild(shenLongAnimSprite,888)
    shenLongAnimSprite:retain()
	-- 注册代理
    local downDelegate = BTAnimationEventDelegate:create()
    downDelegate:registerLayerEndedHandler(fnshenLongAnimSprite)
    shenLongAnimSprite:setDelegate(downDelegate)

    -- 创建离子特效
	shenLiZi()
end


-- 神龙离子特效
function shenLiZi( ... )
	if(shenLiZiAnimSprite)then
		shenLiZiAnimSprite:release()
		shenLiZiAnimSprite:removeFromParentAndCleanup(true)
		shenLiZiAnimSprite = nil
	end
	-- 神龙离子回调
	local function fnshenLiZiAnimSprite( ... )
		if(shenLiZiAnimSprite)then
			shenLiZiAnimSprite:release()
			shenLiZiAnimSprite:removeFromParentAndCleanup(true)
			shenLiZiAnimSprite = nil
		end
	end
	shenLiZiAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/longzhu/juxing/juxing"), -1,CCString:create(""))
    shenLiZiAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
    shenLiZiAnimSprite:setPosition(ccp(310,490))
    _bgSprite:addChild(shenLiZiAnimSprite,888)
    shenLiZiAnimSprite:retain()
	-- 注册代理
    local downDelegate = BTAnimationEventDelegate:create()
    downDelegate:registerLayerEndedHandler(fnshenLiZiAnimSprite)
    shenLiZiAnimSprite:setDelegate(downDelegate)
    -- 创建下一场景
	nextLongZhu()
end

-- 创建龙珠 1，2，3，4，5
function createLongZhuAnimSpriteById( id )
	local placeName = {"lzhui","lzlv","lzlan","lzzi","lzcheng"}
	local animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/longzhu/zhuzi/" .. placeName[tonumber(id)] .. "/" .. placeName[tonumber(id)] ), -1,CCString:create(""))
	return animSprite
end

-- 根据当前显示的场景id得到5个龙珠的坐标下标 
function getLongZhuPosIndex( showId )
	local pos = {}
	local nine = {1,2,3,4,5,6,7,8,9}
	local index1 = 5
	for i=1, showId do
		pos[showId - i +1] = nine[index1]
		index1 = index1 - 1
	end
	local index2 = 5
	for i=showId+1,5 do
		index2 = index2 + 1
		pos[i] = nine[index2]
	end
	return pos
end

-- 场景替换
function replacePlace( ... )
	print("移动----------")
	-- 加移动屏蔽层 
	if(moveMaskLayer)then 
		moveMaskLayer:removeFromParentAndCleanup(true)
		moveMaskLayer = nil
	end
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	moveMaskLayer = BaseUI.createMaskLayer(-5000,nil,nil,0)
	runningScene:addChild(moveMaskLayer, 10000)
	-- 记录上一个场景
	local oldPlaceId = _curShowId
	-- 当前场景id
	_curShowId = HuntSoulData.getHuntPlaceId()
	-- 当前场景各个龙珠的位置
	local curPosTable = getLongZhuPosIndex(_curShowId)
	-- 上个场景当前所需要的位置
	local newPos = curPosTable[oldPlaceId]
	-- print("curPosTable .. ")
	-- print_t(curPosTable)
	-- print(oldPlaceId,newPos)
	local times = 0.4
	-- -- 判断向左移动 还是向右移动
	if(5 < newPos)then
		-- 向右移动
		local step = newPos - 5
		local time_num = times/step

		moveLongzhu(step, time_num, 1)

	
		-- moveOneRight(step,time_num)
	elseif(5 == newPos)then
		-- 不动
		if(moveMaskLayer)then 
			moveMaskLayer:removeFromParentAndCleanup(true)
			moveMaskLayer = nil
		end
		return
	else
		-- 向左移动
		local step = 5 - newPos
		local time_num = times/step
		
		moveLongzhu(step, time_num, -1)

		-- moveOneLeft(step,time_num)
	end
end


-- directData 加减一个值
-- function moveLongzhu(step_num, time_num, directData)
-- 	if(step_num <= 0) then
-- 		if(moveMaskLayer)then 
-- 			moveMaskLayer:removeFromParentAndCleanup(true)
-- 			moveMaskLayer = nil
-- 		end
-- 		return
-- 	end
-- 	for i=1,5 do
-- 		local nowPos = longzhuArray[i].pos
-- 		local nextPos = nowPos + directData
-- 		local desPosition = _ninePosTable[nextPos].pos
-- 		longzhuArray[i].pos = nextPos

-- 		local actionArr = CCArray:create()
-- 		-- actionArr:addObject(CCMoveTo:create(time_num, desPosition))

-- 		local spawnActions 	= CCArray:create()
-- 		spawnActions:addObject(CCMoveTo:create(time_num, desPosition))

-- 		spawnActions:addObject(CCScaleTo:create(0.1, _ninePosTable[nextPos].spriteScale))
-- 		local spawn = CCSpawn:create(spawnActions)
		
-- 		actionArr:addObject(spawn)

--         actionArr:addObject(CCCallFunc:create(function ( ... )
--         	_bgSprite:reorderChild(longzhuArray[i].sprite,_ninePosTable[nextPos].zorde)
-- 				-- -- for循环控制
-- 				if(i == 5) then
-- 					step_num = step_num - 1
-- 					moveLongzhu(step_num,time_num, directData)
-- 				end
--         	end))
--         local seq = CCSequence:create(actionArr)
		
-- 		longzhuArray[i].sprite:runAction(seq)
-- 	end
-- end

-- 优化版方法
function moveLongzhu(step_num, time_num, directData)
	for i=1,5 do
		local actionArr = CCArray:create()
		for j=1,step_num do
			local nowPos = longzhuArray[i].pos
			local nextPos = nowPos + directData
			local desPosition = _ninePosTable[nextPos].pos
			longzhuArray[i].pos = nextPos
        	_bgSprite:reorderChild(longzhuArray[i].sprite,_ninePosTable[nextPos].zorde)

			local actions = CCArray:create()
			actions:addObject(CCMoveTo:create(time_num, desPosition))
			actions:addObject(CCScaleTo:create(time_num, _ninePosTable[nextPos].spriteScale))
			local spawn = CCSpawn:create(actions)
			actionArr:addObject(spawn)
		end
        actionArr:addObject(CCCallFunc:create(function ( ... )
	        	if(moveMaskLayer)then 
					moveMaskLayer:removeFromParentAndCleanup(true)
					moveMaskLayer = nil
				end
        	end))
        local seq = CCSequence:create(actionArr)
		longzhuArray[i].sprite:runAction(seq)
	end
end


-- 初始化场景位置
function initLongzhu( ... )
	-- 初始化5龙珠的位置
	local curPosTable = getLongZhuPosIndex(_curShowId)
	for i=1,5 do
		local sprite = createLongZhuAnimSpriteById(i)
		longzhuArray[i] = {}
		longzhuArray[i].sprite = sprite
		longzhuArray[i].pos = curPosTable[i]

		sprite:setAnchorPoint(ccp(0.5,0.5))
		sprite:setPosition(_ninePosTable[curPosTable[i]].pos)
		_bgSprite:addChild(sprite,_ninePosTable[curPosTable[i]].zorde)
		sprite:setScale(_ninePosTable[curPosTable[i]].spriteScale)
	end
end

-- 创建飞翔效果
function createFlyAction( tItems )
	-- 移除屏蔽层
	if(_flyMaskLayer)then 
		_flyMaskLayer:removeFromParentAndCleanup(true)
		_flyMaskLayer = nil
	end
	_flyMaskLayer = BaseUI.createMaskLayer(-5000,nil,nil,0)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_flyMaskLayer, 10000)
	
	-- 爆炸回调
	if(_bombAnimSprite)then
		_bombAnimSprite:release()
		_bombAnimSprite:removeFromParentAndCleanup(true)
		_bombAnimSprite = nil
	end
	local function fnbombAnimSprite( ... )
		if(_bombAnimSprite)then
			_bombAnimSprite:release()
			_bombAnimSprite:removeFromParentAndCleanup(true)
			_bombAnimSprite = nil
		end
	end
	_bombAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/bcwh/bcwh"), -1,CCString:create(""))
    _bombAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
	local desPosition = _bgSprite:convertToWorldSpace(ccp(310,490))
    _bombAnimSprite:setPosition(desPosition)
    runningScene:addChild(_bombAnimSprite,10010)
    _bombAnimSprite:retain()
    setAdaptNode(_bombAnimSprite)
	-- 注册代理
    local downDelegate = BTAnimationEventDelegate:create()
    downDelegate:registerLayerEndedHandler(fnbombAnimSprite)
    _bombAnimSprite:setDelegate(downDelegate)
	-- 飞翔动画
	createSoulFlyAction(tItems)
end

-- 战魂飞动画
function createSoulFlyAction( tItems )
	if( table.isEmpty(tItems) )then 
		return
	end
	local item_template_id = nil
	local desIcon = nil
	for k,v in pairs(tItems) do
		item_template_id = tonumber(v)
		desIcon = _fsoulIconArr[tonumber(k)]
	end
	local srcPosition = _bgSprite:convertToWorldSpace(ccp(310,490))
	local itemIcon = ItemSprite.getItemSpriteByItemId( item_template_id )
	itemIcon:setAnchorPoint(ccp(0.5,0.5))
	itemIcon:setPosition(srcPosition)
	_flyMaskLayer:addChild(itemIcon)
	setAdaptNode(itemIcon)
	local actionArr = CCArray:create()
	actionArr:addObject(CCDelayTime:create(0.2))
    -- actionArr:addObject(CCScaleTo:create(0.5,0))
    actionArr:addObject(CCCallFunc:create(function ( ... )
    	local temp = ccp(desIcon:getContentSize().width/2,desIcon:getContentSize().height/2 )
		local desPosition = desIcon:convertToWorldSpace(ccp(temp.x,temp.y))
        local actionArr1 = CCArray:create()
        actionArr1:addObject( CCMoveTo:create(0.4, desPosition) )
    	actionArr1:addObject(CCCallFunc:create(function ( ... )
    		-- 显示新图标
    		desIcon:setVisible(true)
    		-- 龙珠移动
			replacePlace()
    		-- 刷新UI
			refreshAllUI()
        	-- 移除屏蔽层
        	if(_flyMaskLayer)then
        		_flyMaskLayer:removeFromParentAndCleanup(true)
        		_flyMaskLayer = nil
        	end
    		if(itemIcon)then
        		itemIcon:removeFromParentAndCleanup(true)
        	end
   		end))
    	local seq1 = CCSequence:create(actionArr1)
    	itemIcon:runAction(seq1)
    end))
    local seq = CCSequence:create(actionArr)
    _bgSprite:runAction(seq)
end


-- 创建猎魂layer
function createSearchSoulLayer( layerSize )
	init()
	_bgLayer = CCLayer:create()
	_bgLayer:setContentSize(layerSize)

	-- 大背景
	_bgSprite = CCScale9Sprite:create("images/hunt/hunt_bg.jpg")
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fScaleX)
    
    -- 是否开启额外掉落活动
    require "script/ui/rechargeActive/ActiveCache"
	_isActivity = ActiveCache.getIsExtraDropAcitiveInHunt()
	local function createNextFun( ... )
		-- 当前场景id
		_curShowId = HuntSoulData.getHuntPlaceId()

		-- 当前场景花费
		_curShowCost = HuntSoulData.getCostByPlaceId(_curShowId)

		-- 召唤神龙
		_shenOpneId,_needGoldNum,_needItemId = HuntSoulData.getOpenShenLongCost()

		-- 拥有神龙令的个数
		_shenlonglingNum = ItemUtil.getCacheItemNumBy(_needItemId)

		-- 聚魂珠
		_juhunzhuNum = ItemUtil.getCacheItemNumBy(60033)
		-- 炼魂印
		_lianhunyinNun = ItemUtil.getCacheItemNumBy(60034)

		-- 得到特效的名字
		_placeName,_dengName,_liziName = getLongZhuNameById(_curShowId)

		-- 初始化猎魂界面
		initSearchSoulLayer()
   	end
	HuntSoulService.getHuntInfo(createNextFun)

	return _bgLayer
end

--[[
	@des 	: 急速猎魂按钮回调
	@param 	: 
	@return :
--]]
function flyHuntMenuItemMenuAction( tag, itemBtn)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- 战魂背包满了
	if(ItemUtil.isFightSoulBagFull(true))then
		return
	end
	-- 道具背包满了
	if(ItemUtil.isPropBagFull(true))then
		return
	end

	require "script/ui/huntSoul/FlyHuntDialog"
	FlyHuntDialog.showTip()
end

--[[
	@des 	: 急速猎魂按钮回调
	@param 	: 
	@return :
--]]
function flyHuntResultCallFun( p_tItems, p_fs_exp, p_costCoin, p_material )
	-- 加材料
	addNewMaterialData( p_material )
	-- 添加新物品
	addNewFSData( p_tItems )
	-- 刷新背包
	_topTableView:reloadData()
	if(table.count(_fsoulData) > 10)then
		_topTableView:setContentOffset(ccp(0,0))
	end
	-- 龙珠移动
	replacePlace()
	-- 刷新UI
	refreshAllUI()

	--获得的战魂提示板子
	require "script/ui/huntSoul/FlyHuntResultDialog"
	FlyHuntResultDialog.showTip( p_tItems, p_fs_exp, p_costCoin, p_material , 1010, -550 )
end

--[[
	@des 	: 重铸刷新
	@param 	: 
	@return :
--]]
function refreshRecast( p_args )
	if( tolua.isnull (_bgLayer)  )then 
		return
	end
	-- 加材料
	if( not table.isEmpty(p_args[1]) )then 
		for k,v in pairs(p_args[1]) do
			if( tonumber(v.tid) == 60033 )then
				-- 聚魂珠
				_juhunzhuNum = _juhunzhuNum + tonumber(v.num)
			elseif( tonumber(v.tid) == 60034 )then
				-- 炼魂印
				_lianhunyinNun = _lianhunyinNun + tonumber(v.num)
			else
			end
		end

		if( not tolua.isnull(_juNumFont) )then 
			_juNumFont:setString(_juhunzhuNum)
		end
		if( not tolua.isnull(_lianNumFont) )then  
			_lianNumFont:setString(_lianhunyinNun)
		end
		if( not tolua.isnull(_fsExpNumFont) )then 
			_fsExpNumFont:setString(UserModel.getFSExpNum())
		end
	end

	if( not tolua.isnull (_topTableView) )then 
		-- 刷新背包
		_fsoulData = HuntSoulData.getFSBagSortByItemId()
		_topTableView:reloadData()
		if(table.count(_fsoulData) > 10)then
			_topTableView:setContentOffset(ccp(0,0))
		end
	end
	-- 刷新银币数量
	HuntSoulLayer.refreshCoin()
end


