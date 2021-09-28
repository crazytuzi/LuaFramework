-- Filename: ClothTipLayer.lua
-- Author: zhang zihang
-- Date: 2015-4-28
-- Purpose: 该文件用于: 炼化5星时装提示

module ("ClothTipLayer", package.seeall)

require "script/model/user/UserModel"
require "db/DB_Heroes"

local _bgLayer = nil
local _touchProperty 
local _zOrder
local _callBackFn

local function init()
	_bgLayer = nil
	_touchProperty= nil
	_zOrder= nil
	_callBackFn= nil

end

local function onTouchesHandler(  )
	return true
end

local function onNodeEvent( event )
    if (event == "enter") then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchProperty, true)
        _bgLayer:setTouchEnabled(true)
    elseif (event == "exit") then

        _bgLayer:unregisterScriptTouchHandler()
    end
end

function closeCb()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil

    --require "script/ui/recycle/BreakDownLayer"
    --BreakDownLayer.cancelBreakDown()
end

function okCb()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil

	if(_callBackFn~= nil) then 
		_callBackFn()
	end
end

-- 
function showLayer( itemInfo, callBackFn,touchProperty, zOrder )
	init()

	_callBackFn= callBackFn
	_touchProperty = touchProperty or -555
	_zOrder = zOrder or _zOrder

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
    _bgLayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bgLayer, 999)

	require "script/ui/main/MainScene"
    local myScale = MainScene.elementScale
	local mySize = CCSizeMake(550,350)

	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    local breakSayBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    breakSayBg:setContentSize(mySize)
    breakSayBg:setScale(myScale)
    breakSayBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    breakSayBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(breakSayBg)

    local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_3158"), g_sFontPangWa,35,2,ccc3(0xff,0xff,0xff),type_shadow)
	labelTitle:setPosition(ccp(breakSayBg:getContentSize().width/2, breakSayBg:getContentSize().height-35))
	labelTitle:setAnchorPoint(ccp(0.5,1))
	labelTitle:setColor(ccc3(0x78,0x25,0x00))
	breakSayBg:addChild(labelTitle)

	-- .. itemInfo.itemDesc.name .. GetLocalizeStringBy("key_1079") .. tonumber(itemInfo.itemDesc.quality) ..GetLocalizeStringBy("key_3330"),
	local content = CCLabelTTF:create(GetLocalizeStringBy("key_2364") , g_sFontName ,24)
	content:setColor(ccc3(0x78,0x25,0x00))
    if table.count(itemInfo) > 3 then
        content:setPosition(ccp(breakSayBg:getContentSize().width/2, breakSayBg:getContentSize().height/2+60))
    else
        content:setPosition(ccp(breakSayBg:getContentSize().width/2, breakSayBg:getContentSize().height/2+40))
    end
    content:setAnchorPoint(ccp(0.5,0.5))
    breakSayBg:addChild(content)

    require "script/ui/hero/HeroPublicLua"
    require "script/utils/BaseUI"

    if table.count(itemInfo) > 3 then
        local contentTable = {}
        for i = 1,3 do

        	local fashionName
			local oldhtid = UserModel.getAvatarHtid()
			local model_id = DB_Heroes.getDataById(tonumber(oldhtid)).model_id
			local nameArray = lua_string_split(itemInfo[i].itemDesc.name, ",")
			for k,v in pairs(nameArray) do
		    	local array = lua_string_split(v, "|")
		    	if(tonumber(array[1]) == tonumber(model_id)) then
					fashionName = array[2]
					break
		    	end
		    end
        	
            local content = CCRenderLabel:create("[" .. fashionName .. "]", g_sFontName ,24,1,ccc3(0x0,0x0,0x0), type_stroke)
            content:setColor(HeroPublicLua.getCCColorByStarLevel(itemInfo[i].itemDesc.quality))
            local content2 = CCLabelTTF:create("，", g_sFontName ,24)
            content2:setColor(ccc3(0x78,0x25,0x00))
            local aleteNode = BaseUI.createHorizontalNode({content, content2})
            table.insert(contentTable,aleteNode)
        end

        local aleteNode = BaseUI.createHorizontalNode(contentTable)
        aleteNode:setAnchorPoint(ccp(0.5, 0.5))
        aleteNode:setPosition(ccp(breakSayBg:getContentSize().width/2, breakSayBg:getContentSize().height/2+20))
        breakSayBg:addChild(aleteNode)

        local contentTable = {}
        for i = 4,#itemInfo do

            local fashionName
            local oldhtid = UserModel.getAvatarHtid()
            local model_id = DB_Heroes.getDataById(tonumber(oldhtid)).model_id
            local nameArray = lua_string_split(itemInfo[i].itemDesc.name, ",")
            for k,v in pairs(nameArray) do
                local array = lua_string_split(v, "|")
                if(tonumber(array[1]) == tonumber(model_id)) then
                    fashionName = array[2]
                    break
                end
            end

            local content = CCRenderLabel:create("[" .. fashionName .. "]", g_sFontName ,24,1,ccc3(0x0,0x0,0x0), type_stroke)
            content:setColor(HeroPublicLua.getCCColorByStarLevel(itemInfo[i].itemDesc.quality))
            local content2 = CCLabelTTF:create("，", g_sFontName ,24)
            content2:setColor(ccc3(0x78,0x25,0x00))
            local aleteNode = BaseUI.createHorizontalNode({content, content2})
            table.insert(contentTable,aleteNode)
        end

        local aleteNode = BaseUI.createHorizontalNode(contentTable)
        aleteNode:setAnchorPoint(ccp(0.5, 0.5))
        aleteNode:setPosition(ccp(breakSayBg:getContentSize().width/2, breakSayBg:getContentSize().height/2-20))
        breakSayBg:addChild(aleteNode)
    else
        local contentTable = {}
        for i = 1,#itemInfo do

            local fashionName
            local oldhtid = UserModel.getAvatarHtid()
            local model_id = DB_Heroes.getDataById(tonumber(oldhtid)).model_id
            local nameArray = lua_string_split(itemInfo[i].itemDesc.name, ",")
            for k,v in pairs(nameArray) do
                local array = lua_string_split(v, "|")
                if(tonumber(array[1]) == tonumber(model_id)) then
                    fashionName = array[2]
                    break
                end
            end

            local content = CCRenderLabel:create("[" .. fashionName .. "]", g_sFontName ,24,1,ccc3(0x0,0x0,0x0), type_stroke)
            content:setColor(HeroPublicLua.getCCColorByStarLevel(itemInfo[i].itemDesc.quality))
            local content2 = CCLabelTTF:create("，", g_sFontName ,24)
            content2:setColor(ccc3(0x78,0x25,0x00))
            local aleteNode = BaseUI.createHorizontalNode({content, content2})
            table.insert(contentTable,aleteNode)
        end

        local aleteNode = BaseUI.createHorizontalNode(contentTable)
        aleteNode:setAnchorPoint(ccp(0.5, 0.5))
        aleteNode:setPosition(ccp(breakSayBg:getContentSize().width/2, breakSayBg:getContentSize().height/2))
        breakSayBg:addChild(aleteNode)
    end
    

    local content2 = CCLabelTTF:create(GetLocalizeStringBy("key_1079"), g_sFontName ,24)
    content2:setColor(ccc3(0x78,0x25,0x00))
    local content4 = CCLabelTTF:create( GetLocalizeStringBy("key_3294"), g_sFontName ,24)
    content4:setColor(ccc3(0x78,0x25,0x00))
    
    local aleteNode = BaseUI.createHorizontalNode({content2, content3,content4})
    aleteNode:setAnchorPoint(ccp(0.5, 0.5))
    if table.count(itemInfo) > 3 then
        aleteNode:setPosition(ccp(breakSayBg:getContentSize().width/2, breakSayBg:getContentSize().height/2-60))
    else
        aleteNode:setPosition(ccp(breakSayBg:getContentSize().width/2, breakSayBg:getContentSize().height/2-40))
    end
    
    breakSayBg:addChild(aleteNode)

    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-600)
    breakSayBg:addChild(menu,99)

    local width = nil
    local cancelBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    cancelBtn:setPosition(ccp(breakSayBg:getContentSize().width*0.75,35))
    cancelBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(cancelBtn)
    local closeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2326"), g_sFontPangWa,30,2,ccc3(0x00,0x00,0x0),type_stroke)
    closeLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    width = (cancelBtn:getContentSize().width - closeLabel:getContentSize().width)/2
    closeLabel:setPosition(ccp(width,54))
    cancelBtn:addChild(closeLabel)
    cancelBtn:registerScriptTapHandler(closeCb)

    local okBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    okBtn:setPosition(ccp(breakSayBg:getContentSize().width*0.25,35))
    okBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(okBtn)
    local closeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1465"), g_sFontPangWa,30,2,ccc3(0x00,0x00,0x0),type_stroke)
    closeLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    width = (okBtn:getContentSize().width - closeLabel:getContentSize().width)/2
    closeLabel:setPosition(ccp(width,54))
    okBtn:addChild(closeLabel)
    okBtn:registerScriptTapHandler(okCb)
    
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.03,mySize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)
end
