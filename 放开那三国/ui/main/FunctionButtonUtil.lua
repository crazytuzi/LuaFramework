-- Filename：	FunctionButtonUtil.lua
-- Author：		chengliang
-- Date：		2015-1-16
-- Purpose：		功能按钮菜单

module("FunctionButtonUtil" , package.seeall)


local _menu              = nil
local _functionMaksLayer = nil
local _menuPanel         = nil
local _functionBtn       = nil
local _itemSprite        = nil
local _mask_layer_tag    = 5000
_ksTagFriend       = 2004       -- 好友
_ksTagMenu         = 2006       -- 菜单
_ksTagMail         = 2003       -- 邮件
_ksTagRank         = 5005       -- 排行榜系统入口   add by DJN
_ksTagAchievement  = 5002       -- 成就


local IMG_PATH="images/main/"
local IMG_PATH_SUB = IMG_PATH .. "sub_icons/"
-- 获取主页菜单图片完整路径
local function getImagePath(filename, isHighlighted)
    if isHighlighted then
        return IMG_PATH_SUB .. filename .. "_h.png"
    end
    return IMG_PATH_SUB .. filename .. "_n.png"
end

function createButton()
    local normal = CCMenuItemImage:create("images/main/sub_icons/function_h.png", "images/main/sub_icons/function_h.png")
    local hight  = CCMenuItemImage:create("images/main/sub_icons/function_n.png", "images/main/sub_icons/function_n.png")
    hight:setAnchorPoint(ccp(0.5, 0.5))
    normal:setAnchorPoint(ccp(0.5, 0.5))
    menu_item = CCMenuItemToggle:create(normal)
    menu_item:setAnchorPoint(ccp(0, 0))
    menu_item:addSubItem(hight)
    menu_item:registerScriptTapHandler(functionCallback)
    _functionBtn = menu_item

    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(ccp(0, 0))
    menu:setTouchPriority(-400)
    menu:addChild(menu_item)

    _itemSprite = CCSprite:create()
    _itemSprite:setContentSize(normal:getContentSize())
    _itemSprite:setAnchorPoint(ccp(0.5, 0.5))
    _itemSprite:addChild(menu, 10)

    addSubButton()
    return _itemSprite
end

--[[
	@des:功能按钮回调函数
--]]
function functionCallback(tag, sender)
    local toggleItem  = tolua.cast(sender, "CCMenuItemToggle")
    local selectIndex = toggleItem:getSelectedIndex()

    if(selectIndex == 0) then
        print("toogle 0 select index:", selectIndex)
        _menuPanel:stopAllActions()
        local action = CCScaleTo:create(0.2, 0)
        _menuPanel:runAction(action)
        if(_functionMaksLayer) then
            _functionMaksLayer:removeFromParentAndCleanup(true)
        end
    else
        print("toogle select index:",selectIndex)
        showFuctionMaskLayer()
        _menuPanel:stopAllActions()
        local action = CCScaleTo:create(0.2, 1 * MainScene.elementScale)
        _menuPanel:runAction(action)
    end
end

function addSubButton( ... )
    -- init function panel
    _menuPanel = CCScale9Sprite:create("images/main/sub_icons/menu_bg.png")
    _menuPanel:setContentSize(CCSizeMake(520,147))
    _menuPanel:setAnchorPoint(ccp(1, 0))
    _menuPanel:setPosition(_functionBtn:getPositionX()*MainScene.elementScale + _functionBtn:getContentSize().width/2*MainScene.elementScale, _functionBtn:getPositionY()*MainScene.elementScale + _functionBtn:getContentSize().height/2*MainScene.elementScale)
    _itemSprite:addChild(_menuPanel, 5, 1)
    _functionBtn:setSelectedIndex(0)
    _menuPanel:setScale(0)

    _menu = CCMenu:create()
    _menu:setAnchorPoint(ccp(0,0))
    _menu:setPosition(ccp(0,0))
    _menuPanel:addChild(_menu,1,1)
    _menu:setTouchPriority(-400)

    --好友按钮
    local friendButton=CCMenuItemImage:create(getImagePath("friend"), getImagePath("friend", true))
    friendButton:registerScriptTapHandler(friendCallback)
    _menu:addChild(friendButton, 1, _ksTagFriend)
    friendButton:setAnchorPoint(ccp(0, 0.5))
    --邮件按钮
    local mailButton=CCMenuItemImage:create(getImagePath("mail"), getImagePath("mail", true))
    mailButton:registerScriptTapHandler(mailCallback)
    _menu:addChild(mailButton, 1, _ksTagMail)
    mailButton:setAnchorPoint(ccp(0, 0.5))

    --成就按钮
    local achievementButton=CCMenuItemImage:create(getImagePath("achiev"), getImagePath("achiev", true))
    achievementButton:registerScriptTapHandler(achievementCallback)
    _menu:addChild(achievementButton, 1, _ksTagAchievement)
    achievementButton:setAnchorPoint(ccp(0, 0.5))

    refreshRedBtn()
    --菜单按钮
    local menuButton=CCMenuItemImage:create(getImagePath("menu"), getImagePath("menu", true))
    menuButton:registerScriptTapHandler(menuCallback)
    _menu:addChild(menuButton, 1, _ksTagMenu)
    menuButton:setAnchorPoint(ccp(0, 0.5))

    --add by DJN 2014/9/3 新增排行榜系统 -------------------------------------------------------------------------------
    require "script/model/user/UserModel"
    --if(UserModel.getHeroLevel()>20)then
    --排行榜系统按钮
    local rankButton  = CCMenuItemImage:create(getImagePath("rank"), getImagePath("rank", true))
    rankButton:registerScriptTapHandler(rankCallback)
    _menu:addChild(rankButton, 1, _ksTagRank)
    rankButton:setAnchorPoint(ccp(0, 0.5))

    _menuPanel:setContentSize(CCSizeMake(540,147))
    local mw = (_menuPanel:getContentSize().width - 40)/5
    local py = _menuPanel:getContentSize().height/2
    rankButton:setPosition(17 + mw*0,py)
    friendButton:setPosition(27 + mw*1, py)
    achievementButton:setPosition(27 + mw*2, py)
    mailButton:setPosition(27 +mw*3, py)
    menuButton:setPosition(27+ mw*4, py)
end

--[[
	@des:显示功能按钮子菜单
--]]
function showFuctionMaskLayer( ... )
    local touchRect = getSpriteScreenRect(_menuPanel)
    local layer = CCLayer:create()
    layer:setPosition(ccp(0, 0))
    layer:setAnchorPoint(ccp(0, 0))
    layer:setTouchEnabled(true)
    layer:setTouchPriority(-300)
    layer:registerScriptTouchHandler(function ( eventType,x,y )
        if(eventType == "began") then
            if(touchRect:containsPoint(ccp(x,y))) then
                return false
            else
                _menuPanel:stopAllActions()
                local action = CCScaleTo:create(0.2, 0)
                _menuPanel:runAction(action)
                layer:removeFromParentAndCleanup(true)
                _functionMaksLayer = nil
                _functionBtn:setSelectedIndex(0)
                return true
            end
        end
    end,false, -300, true)
    local gw,gh = g_winSize.width/MainScene.elementScale, g_winSize.height/MainScene.elementScale
    local layerColor = CCLayerColor:create(ccc4(0,0,0,layerOpacity or 150),gw*80,gh*80)
    layerColor:setPosition(ccp(0,0))
    layerColor:setAnchorPoint(ccp(0.5,0.5))
    layerColor:ignoreAnchorPointForPosition(false)
    layer:addChild(layerColor)
    _functionMaksLayer = layer
    _itemSprite:addChild(layer,4, _mask_layer_tag)
end

function friendCallback( ... )
    require "script/ui/friend/FriendLayer"
    local friendLayer = FriendLayer.creatFriendLayer()
    MainScene.changeLayer(friendLayer, "friendLayer")
end

function mailCallback( ... )
    local mailButton = getMainMenuItem(_ksTagMail)
    if(mailButton ~= nil)then
        local button = tolua.cast(mailButton,"CCMenuItemImage")
        if(button:getChildByTag(10) ~= nil)then
            button:removeChildByTag(10,true)
            require "script/ui/mail/MailData"
            MailData.setHaveNewMailStatus( "false" )
        end
    end
    -- 进入邮件系统
    require "script/ui/mail/Mail"
    MainScene.changeLayer(Mail.createMailLayer(), "Mail")
end

function achievementCallback( ... )
    require "script/model/user/UserModel"
    if(tonumber(UserModel.getHeroLevel()) >= 20)then
        require "script/ui/rank/RankLayer"
        local ccRankLayer = RankLayer.showLayer()
        MainScene.changeLayer(ccRankLayer, "RankLayer")
    else
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("djn_51"))
    end
end

function menuCallback( ... )
    require "script/ui/menu/CCMenuLayer"
    local ccMenuLayer = CCMenuLayer.createMenuLayer()
    MainScene.changeLayer(ccMenuLayer, "ccMenu")
end

function rankCallback( ... )
    require "script/model/user/UserModel"
    if(tonumber(UserModel.getHeroLevel()) >= 20)then
        require "script/ui/rank/RankLayer"
        local ccRankLayer = RankLayer.showLayer()
        MainScene.changeLayer(ccRankLayer, "RankLayer")
    else
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("djn_51"))
    end
end


--刷新功能按钮上的红点
function refreshRedBtn()
	-- body
	if(_main_base_layer~=nil)then
		local isRed = AchieveInfoData.getRedStatus()
		print("isRed2",isRed)
		showTipSprite(_main_base_layer:getChildByTag(999):getChildByTag(0),isRed)
		showTipSprite(_main_base_layer:getChildByTag(1):getChildByTag(1):getChildByTag(_ksTagAchievement),isRed)
	end
end

