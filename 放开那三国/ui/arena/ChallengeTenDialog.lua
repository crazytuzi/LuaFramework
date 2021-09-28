-- FileName: ChallengeTenDialog.lua 
-- Author: licong 
-- Date: 15/10/13 
-- Purpose: 竞技场挑战10次


module("ChallengeTenDialog", package.seeall)

local _bgLayer  						= nil
local _bgSprite 						= nil
local _secondBg 						= nil

local _atkData 						= nil
local _flopData 						= nil
local _touchPriority  					= nil
local _zOrder 							= nil	
local _callFun 							= nil


--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init( ... )
	_bgLayer  							= nil
	_bgSprite 							= nil
	_secondBg 							= nil

	_atkData 							= nil
	_flopData 							= nil
	_touchPriority  					= nil
	_zOrder 							= nil
	_callFun 							= nil
end

--[[
	@des 	: touch事件处理
	@param 	: 
	@return : 
--]]
local function onTouchesHandler( eventType, x, y )
	return true
end

--[[
	@des 	: onNodeEvent事件
	@param 	: 
	@return : 
--]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end


--[[
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
function closeBtnCallFunc( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

   	if( _bgLayer ~= nil )then
   		_bgLayer:removeFromParentAndCleanup(true)
   		_bgLayer = nil
   	end

   	if(_callFun)then
   		_callFun()
   	end
end

--[[
	@des 	:得到翻盘奖励
	@param 	:
	@return :
--]]
function getRewardData( p_data )
	require "script/ui/item/ItemSprite"
	require "script/ui/item/ItemUtil"
    require "script/ui/hero/HeroPublicLua"
	local fontTab = {}
    for k,v in pairs(p_data) do
        if(k == "rob")then
           	local num = tonumber(v) or 0
            fontTab[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1946"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            fontTab[1]:setColor(ccc3(0xff,0xff,0xff))
          	fontTab[2] = CCRenderLabel:create(" X ".. num, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            fontTab[2]:setColor(ccc3(0x70,0xff,0x18))
        elseif(k == "item" or k == "treasFrag")then
            local itemData = ItemUtil.getItemById(v.id)
            local name_color = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
            local num = tonumber(v.num) or 1
            fontTab[1] = CCRenderLabel:create(itemData.name, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            fontTab[1]:setColor(name_color)
          	fontTab[2] = CCRenderLabel:create(" X ".. num, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            fontTab[2]:setColor(ccc3(0x70,0xff,0x18))
        elseif(k == "silver")then
            local quality = ItemSprite.getSilverQuality()
            local name_color = HeroPublicLua.getCCColorByStarLevel(quality)
            local num = tonumber(v) or 1
            fontTab[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1687"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            fontTab[1]:setColor(name_color)
          	fontTab[2] = CCRenderLabel:create(" X ".. num, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            fontTab[2]:setColor(ccc3(0x70,0xff,0x18))
        elseif(k == "gold")then
            local quality = ItemSprite.getGoldQuality()
            local name_color = HeroPublicLua.getCCColorByStarLevel(quality)
            local num = tonumber(v) or 1
            fontTab[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1491"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            fontTab[1]:setColor(name_color)
          	fontTab[2] = CCRenderLabel:create(" X ".. num, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            fontTab[2]:setColor(ccc3(0x70,0xff,0x18))
        elseif(k == "soul")then
            local quality = ItemSprite.getSoulQuality()
            local name_color = HeroPublicLua.getCCColorByStarLevel(quality)
            local num = tonumber(v) or 1
            fontTab[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1616"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            fontTab[1]:setColor(name_color)
          	fontTab[2] = CCRenderLabel:create(" X ".. num, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            fontTab[2]:setColor(ccc3(0x70,0xff,0x18))
        elseif(k == "hero")then
            require "script/ui/hero/HeroPublicCC"
            require "script/ui/hero/HeroPublicLua"
            require "db/DB_Heroes"
           	local heroData = DB_Heroes.getDataById(v.id)
            local name_color = HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
            local num = tonumber(v.num) or 1
            fontTab[1] = CCRenderLabel:create(heroData.name, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            fontTab[1]:setColor(name_color)
          	fontTab[2] = CCRenderLabel:create(" X ".. num, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            fontTab[2]:setColor(ccc3(0x70,0xff,0x18))
        else
        end
    end
    require "script/utils/BaseUI"
    local retSprite = BaseUI.createHorizontalNode(fontTab)
    return retSprite
end

--[[
	@des 	:创建展示tableView
	@param 	:
	@return :
--]]
function createCell( p_cellData, p_index )
	print("p_cellData .. p_index",p_index)
	print_t(p_cellData)

	local isWin = nil
	local coin = nil
	local soul = nil
	local exp = nil
	local prestige = nil
	if(p_cellData.appraisal ~= "E" and p_cellData.appraisal ~= "F")then
		-- 胜利 
		coin,soul,exp,prestige = ArenaData.getCoinAndSoulForWin()
		isWin = true
	else
		coin,soul,exp,prestige = ArenaData.getCoinAndSoulForFail()
		isWin = false
	end

	local cell = CCTableViewCell:create()
	 -- 大背景
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
    local cellBg = CCScale9Sprite:create("images/common/bg/change_bg.png",fullRect, insetRect)
    cellBg:setContentSize(CCSizeMake(450,175))
    cellBg:setAnchorPoint(ccp(0.5,0))
    cellBg:setPosition(ccp(235,0))
    cell:addChild(cellBg)

    -- 标题
    local titleBg= CCScale9Sprite:create("images/common/bg/9s_purple.png")
    titleBg:setContentSize(CCSizeMake(200,30))
	titleBg:setAnchorPoint(ccp(0,1))
	titleBg:setPosition(10, cellBg:getContentSize().height-15)
	cellBg:addChild(titleBg,11)
	-- 第x次
	local mingStr = CCRenderLabel:create(GetLocalizeStringBy("lic_1706",p_index), g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_stroke)
    mingStr:setAnchorPoint(ccp(0.5,0.5))
    mingStr:setColor(ccc3(0xff,0xf6,0x00))
    mingStr:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5))
    titleBg:addChild(mingStr)

    -- 银币
    local silverSp = CCSprite:create("images/arena/yibi.png")
    silverSp:setAnchorPoint(ccp(0,0.5))
    silverSp:setPosition(ccp(33,cellBg:getContentSize().height-70))
    cellBg:addChild(silverSp)
    local silverStr = CCLabelTTF:create("+".. coin , g_sFontName, 21)
    silverStr:setColor(ccc3(0x78,0x25,0x00))
    silverStr:setAnchorPoint(ccp(0,0.5))
    silverStr:setPosition(ccp(silverSp:getPositionX()+silverSp:getContentSize().width+5 ,silverSp:getPositionY()))
    cellBg:addChild(silverStr)
    -- exp
    local expSp = CCSprite:create("images/arena/exp.png")
    expSp:setAnchorPoint(ccp(0,0.5))
    expSp:setPosition(ccp(190,cellBg:getContentSize().height-70))
    cellBg:addChild(expSp)
    local expStr = CCLabelTTF:create("+".. exp , g_sFontName, 21)
    expStr:setColor(ccc3(0x78,0x25,0x00))
    expStr:setAnchorPoint(ccp(0,0.5))
    expStr:setPosition(ccp(expSp:getPositionX()+expSp:getContentSize().width+5 ,expSp:getPositionY()))
    cellBg:addChild(expStr)

    -- 耐力
    local nailiSp = CCSprite:create("images/arena/naili.png")
    nailiSp:setAnchorPoint(ccp(0,0.5))
    nailiSp:setPosition(ccp(33,cellBg:getContentSize().height-106))
    cellBg:addChild(nailiSp)
    local nailiStr = CCLabelTTF:create("-2" , g_sFontName, 21)
    nailiStr:setColor(ccc3(0x78,0x25,0x00))
    nailiStr:setAnchorPoint(ccp(0,0.5))
    nailiStr:setPosition(ccp(nailiSp:getPositionX()+nailiSp:getContentSize().width+5 ,nailiSp:getPositionY()))
    cellBg:addChild(nailiStr)

    -- 失败 or 胜利
    local jieSp = nil 
    if(isWin)then
    	jieSp = CCSprite:create("images/common/win.png")
    else
    	jieSp = CCSprite:create("images/common/failed.png")
    end
    jieSp:setAnchorPoint(ccp(0.5,0.5))
    jieSp:setPosition(ccp(370,cellBg:getContentSize().height*0.5))
    cellBg:addChild(jieSp)

    -- 翻牌奖励
    local fanBg = CCScale9Sprite:create("images/common/bg/bg_9s_3.png")
	fanBg:setContentSize(CCSizeMake(385, 30))
	fanBg:setAnchorPoint(ccp(0.5, 0))
	fanBg:setPosition(ccp(cellBg:getContentSize().width*0.5, 15))
	cellBg:addChild(fanBg)

	local fanSp = CCSprite:create("images/common/fanstr.png")
	fanSp:setAnchorPoint(ccp(0,0.5))
    fanSp:setPosition(ccp(124,fanBg:getContentSize().height*0.5))
    fanBg:addChild(fanSp)

    -- 奖励物品
    local nameSp = nil
    if( not table.isEmpty(_flopData[p_index]) and _flopData[p_index].real )then 
    	nameSp = getRewardData( _flopData[p_index].real )
    else
    	nameSp = CCRenderLabel:create(GetLocalizeStringBy("lic_1707"), g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_stroke)
    	nameSp:setColor(ccc3(0xff,0xff,0xff))
    end
    nameSp:setAnchorPoint(ccp(0,0.5))
    nameSp:setPosition(ccp(fanSp:getPositionX()+fanSp:getContentSize().width+5,fanBg:getContentSize().height*0.5))
    fanBg:addChild(nameSp)

	return cell
end

--[[
	@des 	:创建展示tableView
	@param 	:
	@return :
--]]
function createTableView( ... )
	local cellSize = CCSizeMake(470, 175)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			r = createCell(_atkData[a1+1],a1+1)
		elseif fn == "numberOfCells" then
			r =  #_atkData
		else
		end
		return r
	end)

	local tableView = LuaTableView:createWithHandler(h, CCSizeMake(470, 430))
	tableView:setBounceable(true)
	tableView:setTouchPriority(_touchPriority-4)
	tableView:ignoreAnchorPointForPosition(false)
	tableView:setAnchorPoint(ccp(0.5,0.5))
	tableView:setPosition(ccp(_secondBg:getContentSize().width*0.5,_secondBg:getContentSize().height*0.5))
	_secondBg:addChild(tableView)
	-- 设置单元格升序排列
	tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
end

--[[
	@des 	: 创建主界面
	@param 	: 
	@return : 
--]]
function createLayer( ... )

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))
	_bgLayer:registerScriptHandler(onNodeEvent) 

	-- 背景
	_bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
    _bgSprite:setContentSize(CCSizeMake(520, 620))
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.4))
    _bgLayer:addChild(_bgSprite)
    setAdaptNode(_bgSprite)

   -- 标题
	local topSprite = CCSprite:create("images/common/v_top.png")
	topSprite:setAnchorPoint(ccp(0.5, 0))
	topSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height - 110))
	_bgSprite:addChild(topSprite)
	-- 连战结算
	local titleSprite = CCSprite:create("images/copy/sweep.png")
	titleSprite:setAnchorPoint(ccp(0.5, 0.5))
	titleSprite:setPosition(ccp(topSprite:getContentSize().width*0.5, 130))
	topSprite:addChild(titleSprite)

    -- 共挑战XX次
    local num = table.count(_atkData)
    local textInfo = {
            width = 400, -- 宽度
            alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
            labelDefaultFont = g_sFontPangWa,      -- 默认字体
            labelDefaultSize = 25,          -- 默认字体大小
            labelDefaultColor = ccc3(0x78,0x25,0x00),
            linespace = 10, -- 行间距
            defaultType = "CCLabelTTF",
            elements =
            {   
                {
                    type = "CCRenderLabel",
                    text = num,
                    color = ccc3(0x00,0xff,0x18),
                },
            }
        }
    local tipDes = GetLocalizeLabelSpriteBy_2("lic_1708", textInfo)
    tipDes:setAnchorPoint(ccp(0.5, 0.5))
    tipDes:setPosition(ccp(_bgSprite:getContentSize().width*0.5,_bgSprite:getContentSize().height-50))
    _bgSprite:addChild(tipDes)

	-- 确定按钮
	local backMenuBar = CCMenu:create()
	backMenuBar:setPosition(ccp(0,0))
	_bgSprite:addChild(backMenuBar)
	backMenuBar:setTouchPriority(_touchPriority-5)

	local backBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200, 71),GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,2, ccc3(0x00, 0x00, 0x00))
	backBtn:setAnchorPoint(ccp(0.5, 0.5))
	backBtn:setPosition(ccp(_bgSprite:getContentSize().width*0.5, 55))
	backBtn:registerScriptTapHandler(closeBtnCallFunc)
	backMenuBar:addChild(backBtn)

	-- 二级界面
	_secondBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_secondBg:setContentSize(CCSizeMake(470, 450))
	_secondBg:setAnchorPoint(ccp(0.5, 1))
	_secondBg:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height-80))
	_bgSprite:addChild(_secondBg)

	-- 创建结果
	createTableView()
	
	return _bgLayer
end

--[[
	@des 	: 显示主界面
	@param 	: 
	@return : 
--]]
function showLayer( p_atkData, p_flopData, p_callFun, p_touchPriority, p_zOrder )
	-- 初始化
	init()

	_atkData = p_atkData
	_flopData = p_flopData
	_callFun = p_callFun
	_touchPriority = p_touchPriority or -500
	_zOrder = p_zOrder or 1010
	

	local runningScene = CCDirector:sharedDirector():getRunningScene()
    local layer = createLayer()
    runningScene:addChild(layer,_zOrder)
end

