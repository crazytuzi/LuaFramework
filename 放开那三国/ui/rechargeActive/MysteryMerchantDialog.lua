-- Filename：	MysteryMerchantDialog.lua
-- Author：		bzx
-- Date：		2014-04-12
-- Purpose：		神秘商人出现时的对话框

module ("MysteryMerchantDialog", package.seeall)

require "script/ui/main/MainScene"
require "script/model/user/UserModel"
require "script/ui/recycle/RecycleMain" 
require "script/ui/rechargeActive/ActiveCache"
require "script/libs/LuaCC"
require "script/network/PreRequest"
require "script/ui/rechargeActive/RechargeActiveMain"
require "script/ui/rechargeActive/MysteryMerchantLayer"

local _layer
local _item_datas
local _priority
local _is_showed
local _is_closed

function init()
    _layer = nil
    _item_datas = {}
    _priority = -403
    _is_closed = false
end

function setClosed(is_closed)
    _is_closed = is_closed
end

function checkAndShow()
    if _is_closed == true then
        ActiveCache.MysteryMerchant:requestData(nil, true)
        _is_closed = false
        _is_showed = true
        return
    end
    
    if (not _is_showed) and ActiveCache.MysteryMerchant:isAppear() then
        local copy_data = ActiveCache.MysteryMerchant:getCopyData()
        show(copy_data)
        _is_showed = true
    end
end

function setShowed(is_showed)
    _is_showed = is_showed
end

function show(item_datas)
    _layer = create(item_datas)
    if _layer == nil then
        return false
    end
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(_layer, 1000)
    return true
end

function create(item_datas)
    init()
    if table.isEmpty(item_datas) then
        print_t(item_datas)
        print(GetLocalizeStringBy("key_2844"))
        return _layer
    end
    
    for i = 1, #item_datas, 1 do
        local item_id = item_datas[i]
        local item_data_array = string.split(DB_Copy_mysticalgoods.getDataById(item_id)[2], "|")
        local item_data = {}
        item_data._type = tonumber(item_data_array[1])
        item_data._tid = tonumber(item_data_array[2])
        item_data._count = tonumber(item_data_array[3])
        table.insert(_item_datas, item_data)
    end
    _layer = CCLayer:create()
    _layer:registerScriptHandler(onNodeEvent)
    --AnimationTip.showTip(GetLocalizeStringBy("key_1242"))
    
    -- 背景
    local bg = CCSprite:create("images/recharge/mystery_merchant/dialog.png")
    _layer:addChild(bg)
    bg:setAnchorPoint(ccp(1, 0.5))
    bg:setPosition(g_winSize.width, g_winSize.height * 0.52)
    bg:setScale(g_fScaleX)
    
    -- 文字
    local text = CCSprite:create("images/recharge/mystery_merchant/text.png")
    bg:addChild(text)
    text:setPosition(ccpsprite(0.36, 0.49, bg))
    
    -- 物品栏
    local item_bar = CCScale9Sprite:create("images/recharge/vip_benefit/desButtom.png")
    bg:addChild(item_bar)
    item_bar:setPreferredSize(CCSizeMake(420, 120))
    item_bar:setPosition(ccpsprite(0.32, 0.28, bg))

    -- 按钮
    local menu = CCMenu:create()
    bg:addChild(menu)
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_priority - 1)
    
    -- 前往按钮
	local go_btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(198,73),GetLocalizeStringBy("key_2807"),ccc3(0xfe, 0xbd, 0x1c))
    menu:addChild(go_btn)
    go_btn:setAnchorPoint(ccp(0.5, 0.5))
    go_btn:setPosition(ccpsprite(0.61, 0.2, bg))
	go_btn:registerScriptTapHandler(callbackDialogGo)
    
    -- 关闭按钮
    local close_btn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	close_btn:registerScriptTapHandler(callbackCloseDialog)
	close_btn:setAnchorPoint(ccp(0.5, 0.5))
    close_btn:setPosition(ccpsprite(0.94, 0.6, bg))
	menu:addChild(close_btn)
    
    print("tablebegin")
    print_t(_item_datas)
    -- 物品预览
    for i = 1, 3, 1 do
        local item_data = _item_datas[i]
        local item_icon = ActiveUtil.getItemIcon(item_data._type, item_data._tid, _priority - 1)
        item_icon:setPosition(ccp(23 + 120 * i, 57))
        item_icon:setAnchorPoint(ccp(1, 0.5))
        item_bar:addChild(item_icon)
    end
    return _layer
end

-- 前往按钮的回调
function callbackDialogGo()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local callfunc_get_mystery_merchant_info = function()
        local layer = RechargeActiveMain.create(RechargeActiveMain._tagMysteryMerchant)
        MainScene.changeLayer(layer, "layer")
        _layer:removeFromParentAndCleanup(true)
    end
    ActiveCache.MysteryMerchant:requestData(callfunc_get_mystery_merchant_info)
end

-- 关闭按钮的回调
function callbackCloseDialog()
    local callfunc_get_mystery_merchant_info = function()
        require "script/audio/AudioUtil"
        AudioUtil.playEffect("audio/effect/guanbi.mp3")
        _layer:removeFromParentAndCleanup(true)
    end
    ActiveCache.MysteryMerchant:requestData(callfunc_get_mystery_merchant_info, true)
end

function onNodeEvent(event)
	if (event == "enter") then
		_layer:registerScriptTouchHandler(onTouchesHandler, false, _priority, true)
		_layer:setTouchEnabled(true)
	elseif (event == "exit") then
		_layer:unregisterScriptTouchHandler()
	end
end

function onTouchesHandler( eventType, x, y )
	if eventType == "began" then
        print("began")
	    return true
    end
end
