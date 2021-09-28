-- FileName: GuildBoxLayer.lua 
-- Author: licong 
-- Date: 14-11-13 
-- Purpose: 军团宝箱界面


module("GuildBoxLayer", package.seeall)

require "script/utils/BaseUI"
require "script/ui/item/ItemUtil"
require "script/ui/guild/guildbox/GuildBoxData"
require "script/ui/guild/guildbox/GuildBoxService"
require "script/ui/guild/GuildDataCache"

local _bgLayer                  		= nil
local _topTitleSpOne 					= nil -- 军团宝箱标题
local _topTitleSpTwo 					= nil -- 恭喜您获得
local _boxAnimSprite   					= nil -- 宝箱特效
local _openBoxAnimSprite                = nil -- 宝箱特效
local _showItemAnimSprite               = nil -- 显示物品特效
local _needMeritNumFont  				= nil -- 需要消耗的功勋值label
local _openMenuItemfont 				= nil -- 开启按钮上描述
local _listTableView  					= nil -- 奖励列表
local _upArrowSp 						= nil 
local _downArrowSp  					= nil
local _boxBgSp                          = nil -- 宝箱背景
local _openMenuItem                     = nil -- 开启按钮
local _boxItemSp                        = nil -- 获得的物品图标

local _listHight 						= nil
local _listWidth 						= nil
local _showItems 						= nil -- 奖励预览数据
local _openBoxMaxNum 					= nil
local _needMeritNum 					= nil
local _showItems 						= nil
local _myMeritNum 						= nil
local _alreadyOpenBoxNum 				= nil

--[[
    @des    :init
    @param  :
    @return :
--]]
function init( ... )
	_bgLayer                    		= nil
	_topTitleSpOne 						= nil
	_topTitleSpTwo 						= nil
	_boxAnimSprite   					= nil
    _openBoxAnimSprite                  = nil
    _showItemAnimSprite                 = nil
    _needMeritNumFont                   = nil
    _openMenuItemfont                   = nil
	_listTableView  					= nil
	_upArrowSp 							= nil 
 	_downArrowSp  						= nil
    _boxBgSp                            = nil
    _openMenuItem                       = nil
    _boxItemSp                          = nil

 	_listHight 							= nil
	_listWidth 							= nil
	_showItems 							= nil
	_openBoxMaxNum 						= nil
	_needMeritNum 						= nil
	_showItems 							= nil
	_myMeritNum 						= nil
	_alreadyOpenBoxNum 					= nil
end

-------------------------------------------------------- 事件 ---------------------------------------------------------
--[[
	@des 	:touch事件处理
	@param 	:
	@return :
--]]
local function layerTouch(eventType, x, y)
    return true
end

--[[
    @des    :回调onEnter和onExit事件
    @param  :
    @return :
--]]
function onNodeEvent( event )
    if (event == "enter") then
        _bgLayer:registerScriptTouchHandler(layerTouch,false,-620,true)
        _bgLayer:setTouchEnabled(true)
        GuildDataCache.setIsInGuildFunc(true)
    elseif (event == "exit") then
        GuildDataCache.setIsInGuildFunc(false)
    end
end

--[[
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

--[[
	@des 	:开启按钮回调
	@param 	:
	@return :
--]]
function openMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	print("openMenuItemCallback")

	-- -- 没有剩余次数了
    if( _alreadyOpenBoxNum >= _openBoxMaxNum )then  
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1318"))
		return
    end
    -- 功勋值不足
    if( _needMeritNum >= _myMeritNum )then  
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1319"))
		return
    end
    -- 背包满了
    if(ItemUtil.isBagFull() == true )then
        closeButtonCallback()
        return
    end

	local nextFunction = function ( retData )
    	-- 更新我的功勋值
    	_myMeritNum = _myMeritNum - _needMeritNum
    	GuildDataCache.setMyselfMeritNum(_myMeritNum)
    	-- 更新已经开启次数
    	_alreadyOpenBoxNum = _alreadyOpenBoxNum + 1
    	GuildDataCache.setGuildBoxAlreadyUseNum(_alreadyOpenBoxNum)

    	-- 更新我的功勋值UI
    	_myMeritNumFont:setString(_myMeritNum)
		-- 按钮上文字改为 继续开启
		_openMenuItemfont:setString(GetLocalizeStringBy("lic_1316"))
		-- 更新已用次数UI
		_surplusNumFont:setString( _openBoxMaxNum -_alreadyOpenBoxNum .. "/" .. _openBoxMaxNum)

		-- 显示获得的物品
		showGetItem( retData )
    end
	-- 发请求
	GuildBoxService.lottery(nextFunction)

    -- 测试用 显示获得的物品
    -- local data = {  
    --                 {item = 
    --                      {
    --                         [10043] = 1  
    --                      }
    --                 }
    --              }
    -- showGetItem( data[1] )
end

------------------------------------------------------------- ui ----------------------------------------------

--[[
	@des 	:显示获得的物品
	@param 	:p_retData 获得物品数据
	@return :
--]]
function showGetItem( p_retData )
    -- 隐藏开启按钮
    _openMenuItem:setVisible(false)

	-- 隐藏标题
	_topTitleSpOne:setVisible(false)
	_topTitleSpTwo:setVisible(false)
    _boxAnimSprite:setVisible(false)

    -- 删除上次物品图标
    if(_boxItemSp ~= nil)then
        _boxItemSp:removeFromParentAndCleanup(true)
        _boxItemSp = nil
    end

    -- 开宝箱特效
    if(_openBoxAnimSprite ~= nil)then
        _openBoxAnimSprite:removeFromParentAndCleanup(true)
        _openBoxAnimSprite = nil
    end
    _openBoxAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/guild/guildbox/effect/baoxiangdakai"), -1,CCString:create(""))
    _openBoxAnimSprite:setAnchorPoint(ccp(0.5, 0))
    _openBoxAnimSprite:setPosition(ccp(_boxBgSp:getContentSize().width*0.5,_boxBgSp:getContentSize().height*0.55))
    _boxBgSp:addChild(_openBoxAnimSprite)
    -- 代理
    local animationFrameChanged = function ( p_frameIndex,p_xmlSprite )
        local tempSprite = tolua.cast(p_xmlSprite,"CCXMLSprite")
        if(tempSprite:getIsKeyFrame()) then
            -- 创建获得物品的图标
            require "script/utils/ItemDropUtil"
            local drop = {}
            table.insert(drop,p_retData)
            print_t(drop)
            local itemData = ItemDropUtil.getDropItem(drop[1])
            _boxItemSp = ItemUtil.createGoodsIcon( itemData[1], -623, 1010, -650, nil ,true)
            _boxItemSp:setAnchorPoint(ccp(0.5,0.5))
            _boxItemSp:setPosition(ccp(_boxBgSp:getContentSize().width*0.5,_boxBgSp:getContentSize().height*0.55))
            _boxBgSp:addChild(_boxItemSp,1000)

            -- 物品图标action
            local thisScale = _boxItemSp:getScale()
            _boxItemSp:setScale(0)
            local actionArr = CCArray:create()
            local scale = CCScaleTo:create(0.5, 1*thisScale)
            actionArr:addObject(CCEaseElasticOut:create(scale, 0.3))
            actionArr:addObject(CCCallFunc:create(function ( ... )
                local _showItemAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/guild/guildbox/effect/baoxiangwupin"), -1,CCString:create(""))
                _showItemAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
                _showItemAnimSprite:setPosition(ccp(_boxItemSp:getContentSize().width*0.5,_boxItemSp:getContentSize().height*0.5))
                _boxItemSp:addChild(_showItemAnimSprite,-10)

                -- 隐藏开启按钮
                _openMenuItem:setVisible(true)
                -- 显示标题恭喜获得
                _topTitleSpTwo:setVisible(true)

            end))
            _boxItemSp:runAction( CCSpawn:create(actionArr) )

            local actionArr1 = CCArray:create()
            actionArr1:addObject(CCDelayTime:create(0.3))
            actionArr1:addObject(CCCallFunc:create(function ( ... )
                if(_openBoxAnimSprite ~= nil)then
                    _openBoxAnimSprite:removeFromParentAndCleanup(true)
                    _openBoxAnimSprite = nil
                end
            end))
            _boxItemSp:runAction( CCSequence:create(actionArr1) )
        end
    end
    local openBoxDelegate = BTAnimationEventDelegate:create()
    _openBoxAnimSprite:setDelegate(openBoxDelegate)
    -- 关键帧处理函数
    openBoxDelegate:registerLayerChangedHandler(animationFrameChanged)
end

--[[
	@des 	:刷新箭头
	@param 	:
	@return :
--]]
function refreshArrowSpFun( ... )
    if(_listTableView ~= nil)then
        local offset =  _listTableView:getContentSize().height+ _listTableView:getContentOffset().y-(_listHight/g_fScaleX-22*g_fScaleX)
        if(_upArrowSp~= nil )  then
            if(offset>1 or offset<-1) then
                _upArrowSp:setVisible(true)
            else
                _upArrowSp:setVisible(false)
            end
        end

        if(_downArrowSp ~= nil) then
            if( _listTableView:getContentOffset().y ~=0) then
                _downArrowSp:setVisible(true)
            else
                _downArrowSp:setVisible(false)
            end
        end

        local actionArray = CCArray:create()
        actionArray:addObject(CCDelayTime:create(1))
        actionArray:addObject(CCCallFunc:create(refreshArrowSpFun))
        _listTableView:runAction(CCSequence:create(actionArray))
    end
end

--[[
	@des 	:箭头动画
	@param 	:
	@return :
--]]
function arrowAction( arrow)
    local arrActions_2 = CCArray:create()
    arrActions_2:addObject(CCFadeOut:create(1))
    arrActions_2:addObject(CCFadeIn:create(1))
    local sequence_2 = CCSequence:create(arrActions_2)
    local action_2 = CCRepeatForever:create(sequence_2)
    arrow:runAction(action_2)
end

--[[
	@des 	:奖励预览列表
	@param 	:
	@return :
--]]
function createRewardList()
    -- 列表背景
    local fullRect = CCRectMake(0,0,75,75)
    local insetRect = CCRectMake(30,30,15,10)
    local listBg = CCScale9Sprite:create("images/astrology/astro_btnbg.png",fullRect, insetRect)
    _listHight = 221
    _listWidth = 635
    listBg:setContentSize(CCSizeMake(_listWidth,_listHight))
    listBg:setAnchorPoint(ccp(0.5,0))
    listBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,0))
    _bgLayer:addChild(listBg)
    listBg:setScale(g_fScaleX)
    -- 标题
    local fullRect = CCRectMake(0,0,75,35)
    local insetRect = CCRectMake(35,14,5,6)
    local titleSp = CCScale9Sprite:create("images/astrology/astro_labelbg.png",fullRect, insetRect)
    titleSp:setContentSize(CCSizeMake(182,35))
    titleSp:setAnchorPoint(ccp(0.5,0.5))
    titleSp:setPosition(ccp(listBg:getContentSize().width*0.5,listBg:getContentSize().height))
    listBg:addChild(titleSp)
    local titleFont = CCLabelTTF:create(GetLocalizeStringBy("key_2295"), g_sFontPangWa, 24)
    titleFont:setColor(ccc3(0xff,0xf6,0x00))
    titleFont:setAnchorPoint(ccp(0.5,0.5))
    titleFont:setPosition(ccp(titleSp:getContentSize().width*0.5,titleSp:getContentSize().height*0.5))
    titleSp:addChild(titleFont)

    -- 创建tableView
    local cellSize = CCSizeMake(630, 140)
    local needNum = 5
	local handler = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			a2 = CCTableViewCell:create()
			local posArrX = {0.1,0.3,0.5,0.7,0.9}
			for i=1,needNum do
				if(_showItems[a1*needNum+i] ~= nil)then
					local item_sprite = ItemUtil.createGoodsIcon(_showItems[a1*needNum+i], -622, 1010, -650, nil ,true,nil)
					item_sprite:setAnchorPoint(ccp(0.5,1))
					item_sprite:setPosition(ccp(630*posArrX[i],130))
					a2:addChild(item_sprite)
				end
			end
			r = a2
		elseif fn == "numberOfCells" then
			local num = #_showItems
			r = math.ceil(num/needNum)
		else
		end
		return r
	end)

    _listTableView = LuaTableView:createWithHandler(handler, CCSizeMake(_listWidth,_listHight-22*g_fScaleX))
    _listTableView:setBounceable(true)
    _listTableView:setAnchorPoint(ccp(0, 0))
    _listTableView:setPosition(ccp(11, 1))
    listBg:addChild(_listTableView)
    -- 设置单元格升序排列
    _listTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    -- 设置滑动列表的优先级
    _listTableView:setTouchPriority(-623)

    -- 向上箭头
    _upArrowSp = CCSprite:create( "images/common/arrow_up_h.png")
    _upArrowSp:setPosition(listBg:getContentSize().width, listBg:getContentSize().height-5)
    _upArrowSp:setAnchorPoint(ccp(1,1))
    listBg:addChild(_upArrowSp,1, 101)
    _upArrowSp:setVisible(false)

    -- 向下的箭头
    _downArrowSp = CCSprite:create( "images/common/arrow_down_h.png")
    _downArrowSp:setPosition(listBg:getContentSize().width, 5)
    _downArrowSp:setAnchorPoint(ccp(1,0))
    listBg:addChild(_downArrowSp,1, 102)
    _downArrowSp:setVisible(true)

    arrowAction(_downArrowSp)
    arrowAction(_upArrowSp)

    -- 刷新箭头
    refreshArrowSpFun()
end

--[[
	@des 	:初始化军团宝箱界面
	@param 	:
	@return :
--]]
function initGuildBoxLayer( ... )

	_bgLayer = CCLayerColor:create(ccc4(8,8,8,150))
    _bgLayer:registerScriptHandler(onNodeEvent) 
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,1000,1)

    -- 军团宝箱
    _topTitleSpOne = CCSprite:create("images/guild/guildbox/title.png")
    _topTitleSpOne:setAnchorPoint(ccp(0.5,1))
    _topTitleSpOne:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-50*g_fElementScaleRatio))
    _bgLayer:addChild(_topTitleSpOne)
    _topTitleSpOne:setScale(g_fElementScaleRatio)
    -- 军团宝箱中的物品包罗万象快去试试手气吧~
    local titleFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1311"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleFont:setAnchorPoint(ccp(0.5,1))
    titleFont:setColor(ccc3(0x00, 0xff, 0x18))
    titleFont:setPosition(ccp(_topTitleSpOne:getContentSize().width*0.5,-24))
    _topTitleSpOne:addChild(titleFont)

    -- 恭喜您获得
    _topTitleSpTwo = CCSprite:create("images/guild/guildbox/box_item_title.png")
    _topTitleSpTwo:setAnchorPoint(ccp(0.5,1))
    _topTitleSpTwo:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-50*g_fElementScaleRatio))
    _bgLayer:addChild(_topTitleSpTwo)
    _topTitleSpTwo:setScale(g_fElementScaleRatio)
    _topTitleSpTwo:setVisible(false)

    -- 宝箱背景
    _boxBgSp = CCSprite:create("images/guild/guildbox/box_bg.png")
    _boxBgSp:setAnchorPoint(ccp(0.5,0.5))
    _boxBgSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.6))
    _bgLayer:addChild(_boxBgSp)
    _boxBgSp:setScale(g_fElementScaleRatio)

    -- 宝箱特效
    _boxAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/guild/guildbox/effect/jtbaoxiang"), -1,CCString:create(""))
    _boxAnimSprite:setAnchorPoint(ccp(0.5,0))
    _boxAnimSprite:setPosition(ccp(_boxBgSp:getContentSize().width*0.5,_boxBgSp:getContentSize().height*0.32))
    _boxBgSp:addChild(_boxAnimSprite)

    -- 开启消耗的功勋
    local fontTab1 = {}
    fontTab1[1] = CCRenderLabel:create(GetLocalizeStringBy("lic_1312"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab1[1]:setColor(ccc3(0xff,0xf6,0x00))
    fontTab1[2] = CCSprite:create("images/common/gongxun.png")
    fontTab1[3] = CCRenderLabel:create(": ", g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab1[3]:setColor(ccc3(0xff,0xf6,0x00))
    local needMeritFont = BaseUI.createHorizontalNode(fontTab1)
    needMeritFont:setAnchorPoint(ccp(0,0.5))
	_bgLayer:addChild(needMeritFont)
	needMeritFont:setScale(g_fElementScaleRatio)
	-- 功勋值
    -- font bg
    local fontBg1 = CCSprite:create()
    fontBg1:setAnchorPoint(ccp(0,0.5))
	_bgLayer:addChild(fontBg1)
	fontBg1:setScale(g_fElementScaleRatio)
    
    _needMeritNumFont = CCRenderLabel:create(_needMeritNum, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontBg1:setContentSize(_needMeritNumFont:getContentSize())
    
    _needMeritNumFont:setColor(ccc3(0xff,0xff,0xff))
    _needMeritNumFont:setAnchorPoint(ccp(0,0.5))
    _needMeritNumFont:setPosition(ccp(0,fontBg1:getContentSize().height*0.5))
    fontBg1:addChild(_needMeritNumFont)

	-- 居中
	local posX = (_bgLayer:getContentSize().width-needMeritFont:getContentSize().width*g_fElementScaleRatio-fontBg1:getContentSize().width*g_fElementScaleRatio)*0.5
	needMeritFont:setPosition(ccp(posX,_bgLayer:getContentSize().height*0.45))
	fontBg1:setPosition(ccp(needMeritFont:getPositionX()+needMeritFont:getContentSize().width*g_fElementScaleRatio,needMeritFont:getPositionY()))


	-- 我的功勋
    local fontTab2 = {}
    fontTab2[1] = CCRenderLabel:create(GetLocalizeStringBy("lic_1313"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab2[1]:setColor(ccc3(0xff,0xf6,0x00))
    fontTab2[2] = CCSprite:create("images/common/gongxun.png")
    fontTab2[3] = CCRenderLabel:create(": ", g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab2[3]:setColor(ccc3(0xff,0xf6,0x00))
    local myMeritFont = BaseUI.createHorizontalNode(fontTab2)
    myMeritFont:setAnchorPoint(ccp(0,0.5))
	_bgLayer:addChild(myMeritFont)
	myMeritFont:setScale(g_fElementScaleRatio)
	-- 功勋值
    -- font bg
    local fontBg2 = CCSprite:create()
    fontBg2:setAnchorPoint(ccp(0,0.5))
    _bgLayer:addChild(fontBg2)
    fontBg2:setScale(g_fElementScaleRatio)

    _myMeritNumFont = CCRenderLabel:create(_myMeritNum, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontBg2:setContentSize(_myMeritNumFont:getContentSize())
    
    _myMeritNumFont:setColor(ccc3(0x00,0xff,0x18))
    _myMeritNumFont:setAnchorPoint(ccp(0,0.5))
    _myMeritNumFont:setPosition(ccp(0,fontBg2:getContentSize().height*0.5))
    fontBg2:addChild(_myMeritNumFont)
   
	-- 居中
	local posX = (_bgLayer:getContentSize().width-myMeritFont:getContentSize().width*g_fElementScaleRatio-fontBg2:getContentSize().width*g_fElementScaleRatio)*0.5
	myMeritFont:setPosition(ccp(posX,_bgLayer:getContentSize().height*0.4))
	fontBg2:setPosition(ccp(myMeritFont:getPositionX()+myMeritFont:getContentSize().width*g_fElementScaleRatio,myMeritFont:getPositionY()))

	-- 按钮
	local menuBar = CCMenu:create()
    menuBar:setTouchPriority(-625)
	menuBar:setPosition(ccp(0, 0))
	menuBar:setAnchorPoint(ccp(0, 0))
	_bgLayer:addChild(menuBar)

	-- 开启按钮
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_purple2_n.png")
    normalSprite:setContentSize(CCSizeMake(198,70))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_purple2_h.png")
    selectSprite:setContentSize(CCSizeMake(198,70))
    _openMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
    _openMenuItem:setAnchorPoint(ccp(0.5,0.5))
    _openMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.3, _bgLayer:getContentSize().height*0.35))
    _openMenuItem:registerScriptTapHandler(openMenuItemCallback)
    menuBar:addChild(_openMenuItem)
    _openMenuItem:setScale(g_fElementScaleRatio)
    -- 开启文字
    _openMenuItemfont = CCRenderLabel:create( GetLocalizeStringBy("lic_1315"), g_sFontPangWa, 30, 1, ccc3(0x00,0x00,0x00), type_stroke)
    _openMenuItemfont:setAnchorPoint(ccp(0.5,0.5))
    _openMenuItemfont:setColor(ccc3(0xfe,0xdb,0x1c))
    _openMenuItemfont:setPosition(ccp(_openMenuItem:getContentSize().width*0.5,_openMenuItem:getContentSize().height*0.5))
    _openMenuItem:addChild(_openMenuItemfont)

    -- 退出
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn1_d.png")
    normalSprite:setContentSize(CCSizeMake(192,70))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn1_n.png")
    selectSprite:setContentSize(CCSizeMake(192,70))
    local closeMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
    closeMenuItem:setAnchorPoint(ccp(0.5,0.5))
    closeMenuItem:setPosition(ccp(_bgLayer:getContentSize().width*0.7, _bgLayer:getContentSize().height*0.35))
    closeMenuItem:registerScriptTapHandler(closeButtonCallback)
    menuBar:addChild(closeMenuItem)
    closeMenuItem:setScale(g_fElementScaleRatio)
    local  itemfont = CCRenderLabel:create( GetLocalizeStringBy("lic_1314"), g_sFontPangWa, 35, 1, ccc3(0x00,0x00,0x00), type_stroke)
    itemfont:setAnchorPoint(ccp(0.5,0.5))
    itemfont:setColor(ccc3(0xfe,0xdb,0x1c))
    itemfont:setPosition(ccp(closeMenuItem:getContentSize().width*0.5,closeMenuItem:getContentSize().height*0.5))
    closeMenuItem:addChild(itemfont)

    -- 今日剩余开启次数
    local surplusFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1317"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	surplusFont:setColor(ccc3(0xff,0xff,0xff))
	surplusFont:setAnchorPoint(ccp(0,0.5))
	_bgLayer:addChild(surplusFont)
	surplusFont:setScale(g_fElementScaleRatio)
	-- 剩余次数
    local fontBg3 = CCSprite:create()
    fontBg3:setAnchorPoint(ccp(0,0.5))
    _bgLayer:addChild(fontBg3)
    fontBg3:setScale(g_fElementScaleRatio)

	_surplusNumFont = CCRenderLabel:create( _openBoxMaxNum -_alreadyOpenBoxNum .. "/" .. _openBoxMaxNum, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	fontBg3:setContentSize(_surplusNumFont:getContentSize())

    _surplusNumFont:setColor(ccc3(0x00,0xff,0x18))
	_surplusNumFont:setAnchorPoint(ccp(0,0.5))
    _surplusNumFont:setPosition(ccp(0,fontBg3:getContentSize().height*0.5))
	fontBg3:addChild(_surplusNumFont)

	-- 居中
	local posX = (_bgLayer:getContentSize().width-surplusFont:getContentSize().width*g_fElementScaleRatio-fontBg3:getContentSize().width*g_fElementScaleRatio)*0.5
	surplusFont:setPosition(ccp(posX,_bgLayer:getContentSize().height*0.30))
	fontBg3:setPosition(ccp(surplusFont:getPositionX()+surplusFont:getContentSize().width*g_fElementScaleRatio,surplusFont:getPositionY()))

	-- 创建奖励预览
	createRewardList()
end

--[[
	@des 	: 显示军团宝箱界面
	@param 	:
	@return :
--]]
function initGuildBoxData( ... )
	-- 开启宝箱最大次数
	_openBoxMaxNum = GuildBoxData.getOpenBoxMaxNum()
	-- 已经开启的次数
	_alreadyOpenBoxNum = GuildDataCache.getGuildBoxAlreadyUseNum()
	-- 开启一次需要的功勋值
	_needMeritNum = GuildBoxData.getOpenBoxCostMeritNum()
	-- 奖励预览数据
	local rewardStr = GuildBoxData.getBoxRewardPreview()
	print("rewardStr",rewardStr)
	_showItems = ItemUtil.getItemsDataByStr(rewardStr)
	-- 我的功勋值
	_myMeritNum = GuildDataCache.getMyselfMeritNum()

	print("_showItems:")
	print_t(_showItems)
end

--[[
	@des 	: 显示军团宝箱界面
	@param 	:
	@return :
--]]
function showGuildBoxLayer()
	-- 初始化
	init()

	-- 初始化数据
	initGuildBoxData()

	-- 初始化开宝箱界面
	initGuildBoxLayer()
end





