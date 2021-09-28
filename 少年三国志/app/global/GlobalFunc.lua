GlobalFunc = {}



-- 初始化公共组件
function GlobalFunc.initComponent(parent,ComponentList)
    if parent then
        if type(ComponentList) ~= "table" then
            print("initComponent init wrong param 2 is table ")
        else
            for i=1,table.getn(ComponentList) do
                local ui = parent:getUILayerComponent(ComponentList[i])
                if ui then
                    local node = require("app.scenes.common.".. ComponentList[i]).new()
                    node:initGUIComponent(ui,ComponentList[i])
                    ui._componentNode = node
                    parent:addChild(node)
                else
                    __Log("componen [%s] is not found!", ComponentList[i])
                end
            end
        end
    end
end

function GlobalFunc.sz_T2S(_t)
    local szRet = "{"
    function doT2S(_i, _v)
        if "number" == type(_i) then
            szRet = szRet .. "[" .. _i .. "] = "
            if "number" == type(_v) then
                szRet = szRet .. _v .. ","
            elseif "string" == type(_v) then
                szRet = szRet .. '"' .. _v .. '"' .. ","
            elseif "table" == type(_v) then
                szRet = szRet .. sz_T2S(_v) .. ","
            else
                szRet = szRet .. "nil,"
            end
        elseif "string" == type(_i) then
            szRet = szRet .. '["' .. _i .. '"] = '
            if "number" == type(_v) then
                szRet = szRet .. _v .. ","
            elseif "string" == type(_v) then
                szRet = szRet .. '"' .. _v .. '"' .. ","
            elseif "table" == type(_v) then
                szRet = szRet .. sz_T2S(_v) .. ","
            else
                szRet = szRet .. "nil,"
            end
        end
    end
    table.foreach(_t, doT2S)
    szRet = szRet .. "}"
    return szRet
end

-- 设置widget中组件文字

function GlobalFunc.addTimer(interval, callback)
    local scheduler = require "framework.scheduler"
    return scheduler.scheduleGlobal(callback,interval)
end

function GlobalFunc.removeTimer(timerHandler)
    local scheduler = require "framework.scheduler"
    scheduler.unscheduleGlobal(timerHandler)
end


--数字转汉字  例如 6---> 六, 16--->十六, 20--->二十, 26->二十六
function GlobalFunc.numberToChinese(num)
    local numList={"一","二","三","四","五","六","七","八","九","十"}
    if num <= 10 then
        return numList[num]
    elseif num < 20 then
        return "十"..numList[math.floor(num%10)]
    elseif math.floor(num%10) == 0 and num < 100 then
        return numList[math.floor(num/10)].."十"
    elseif num < 100 then
        return numList[math.floor(num/10)].."十"..numList[math.floor(num%10)]
    elseif num < 1000 then
        if math.floor((num%100)/10) == 0 then
            if math.floor(num%10) == 0 then
                return numList[math.floor(num/100)].."百"
            else
                return numList[math.floor(num/100)].."百".."零"..numList[math.floor(num%10)]
            end
        else
            -- 擦，这里在遇到110、120 。。。会歇菜
            return numList[math.floor(num/100)].."百"..numList[math.floor((num%100)/10)].."十"..(numList[math.floor(num%10)] or "")
        end
    end
end

function GlobalFunc.ConvertNumToCharacter(num)
    -- 过亿了
    if num >= math.pow(10,8) then
        return (num-num%math.pow(10,4))/math.pow(10,4) .. G_lang:get("LANG_WAN")
    end
    if num >= math.pow(10,6) then
        return (num-num%math.pow(10,4))/math.pow(10,4) .. G_lang:get("LANG_WAN")
    end
    return num
end

function GlobalFunc.ConvertNumToCharacter2(num)
    -- 过亿了
    if num >= math.pow(10,8) then
        return (num-num%math.pow(10,8))/math.pow(10,8) .. G_lang:get("LANG_YI")
    end
    if num >= math.pow(10,4) then
        return (num-num%math.pow(10,4))/math.pow(10,4) .. G_lang:get("LANG_WAN")
    end
    return num
end

function GlobalFunc.ConvertNumToCharacter3(num)
    -- 过亿了
    if num >= math.pow(10,8) then
        return (num-num%math.pow(10,8))/math.pow(10,8) .. G_lang:get("LANG_YI")
    end
    if num >= math.pow(10,5) then
        return (num-num%math.pow(10,4))/math.pow(10,4) .. G_lang:get("LANG_WAN")
    end
    return num
end

function GlobalFunc.ConvertNumToCharacter4(num)
    if num >= math.pow(10,6) then
        return (num-num%math.pow(10,4))/math.pow(10,4) .. G_lang:get("LANG_WAN")
    end
    return num
end

--字符串分割
function GlobalFunc.lua_string_split(str, split_char)
    local sub_str_tab = {};
    while (true) do
        local pos = string.find(str, split_char);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str;
            break;
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        str = string.sub(str, pos + 1, #str);
    end

    return sub_str_tab;
end

function GlobalFunc.matchText( text )
    local blacklist = require("app.cfg.black_list")
    return blacklist:isMatchText(text)
end

function GlobalFunc.filterText( text )
    local blacklist = require("app.cfg.black_list")
    return blacklist:filterBlack(text)
end

-- layer: the layer which includes stars control
-- stars: a table which includes the control's names
-- star: the star value will show
-- align: 
--      1 : left algin  (default value)
--      2 : center algin
--      3 : right  algin
-- size:
--      only valid when align is 2, we will reset position of each
--      star by the size

function GlobalFunc.showStars( layer, stars, star, align, size ) 
    if layer == nil or type(stars) ~= "table" then
        return 
    end
    
    local length = #stars
    if length < 1 then
        return 
    end
    
    if align == 2 then
        local offset = length - star
        local showStartIndex = math.floor(offset/2)
        showStartIndex = showStartIndex + 1

        local visibleStar = {}
        for i, value in pairs(stars) do
            local flag = (i >= showStartIndex and i < showStartIndex + star)
            layer:showWidgetByName(value, flag)
            if flag then
                table.insert(visibleStar, #visibleStar + 1, value)
            end
        end

        if size then 
            local starCtrl = layer:getWidgetByName(stars[1])
            local starSize = starCtrl and starCtrl:getSize() or nil

            if starSize then
                local showStarCount = #visibleStar
                local loopi = 1
                local startPos = (size.width - showStarCount*starSize.width)/2
                for key, value in pairs(visibleStar) do 
                    starCtrl = layer:getWidgetByName(value)
                    if starCtrl then
                        starCtrl:setPosition(ccp(startPos + (loopi - 0.5)*starSize.width, size.height/2))
                        loopi = loopi + 1
                    end
                end
            end
        end
    elseif align == 3 then
        for i, value in pairs(stars) do
            layer:showWidgetByName(value, length - i < star)
        end        
    else
        for i, value in pairs(stars) do
            layer:showWidgetByName(value, i <= star)
        end
    end
end

function GlobalFunc.loadStars( layer, stars, star, algin, enableStar, disableStar )
    if layer == nil or type(stars) ~= "table" or type(enableStar) ~= "string" or type(disableStar) ~= "string" then
        return 
    end
    
    local length = #stars
    if length < 1 then
        return 
    end
    
    if align == 2 then
        local offset = length - star
        local showStartIndex = offset/2
        showStartIndex = showStartIndex + 1
        for i, value in pairs(stars) do
            local starImg = layer:getImageViewByName(value)
            if starImg then
                starImg:loadTexture((i >= showStartIndex and i < showStartIndex + star) and enableStar or disableStar, UI_TEX_TYPE_PLIST)
            end
            --layer:showWidgetByName(value, (i >= showStartIndex and i < showStartIndex + star))
        end
    elseif align == 3 then
        for i, value in pairs(stars) do
            local starImg = layer:getImageViewByName(value)
            if starImg then
                starImg:loadTexture(length - i < star and enableStar or disableStar, UI_TEX_TYPE_PLIST)
            end
            --layer:showWidgetByName(value, length - i < star)
        end
    else
        for i, value in pairs(stars) do
            local starImg = layer:getImageViewByName(value)
            if starImg then
                starImg:loadTexture(i <= star and enableStar or disableStar, UI_TEX_TYPE_PLIST)
            end
            --layer:showWidgetByName(value, i <= star)
        end
    end
end


--[[
    获取knight突破数  string
    
    advanced_level = 5   return +1 
    advanced_level = 7   return +1
    advanced_level = 8   return +2
    advanced_level = 9   return +3
]]
function GlobalFunc.getAdvanceString(knight)
    if knight == nil or knight.advanced_level == nil then
        return ""
    end
    if knight.advanced_level == 5 or knight.advanced_level == 7 then
        return "+1"
    elseif knight.advanced_level == 8 then
        return "+2"
    elseif knight.advanced_level == 9 then
        return "+3"
    end
    return ""
end
    

--[[
    --体力或者精力不足时候，调用购买弹窗
    _type == 1  体力丹
    _type == 2  精力丹
    _type == 3  出征令
    _type == 4  免战牌大
    _type == 5  免战牌小
]]

function GlobalFunc.showPurchasePowerDialog(_type)
    -- local ItemConst = require("app.const.ItemConst")
    require("app.cfg.shop_price_info")
    require("app.cfg.basic_figure_info")

    local currItemNum = 0

    local ShopVipConst = require("app.const.ShopVipConst")
    local itemId = 0
    if _type == 1 then
        itemId = ShopVipConst.TI_LI_DAN
        currItemNum = G_Me.userData.vit        
    elseif _type == 2 then
        itemId = ShopVipConst.JING_LI_DAN
        currItemNum = G_Me.userData.spirit
    elseif _type == 3 then
        itemId = ShopVipConst.CHU_ZHENG_LING
        currItemNum = G_Me.userData.battle_token
    elseif _type == 4 then
        itemId = ShopVipConst.MIAN_ZHAN_PAI_DA
    elseif _type == 5 then
        itemId = ShopVipConst.MIAN_ZHAN_PAI_XIAO
    else
        assert("传入type:%s不对",_type)
        return
    end

    -- 如果是体力丹、精力丹、征讨令则需要判断如果有对应的道具，则优先弹出批量使用的弹窗
    if _type == 1 or _type == 2 or _type == 3 then
        local item = shop_score_info.get(itemId)
        local itemInfo = G_Me.bagData.propList:getItemByKey(item.value)
        if itemInfo == nil then
            local layer = require("app.scenes.shop.PurchasePowerDialog").create(itemId)
            uf_sceneManager:getCurScene():addChild(layer,2)
            return
        end            
        local ownNum = itemInfo["num"]
        if ownNum == 0 then
            local layer = require("app.scenes.shop.PurchasePowerDialog").create(itemId)
            uf_sceneManager:getCurScene():addChild(layer,2)
            return
        else
            local localItem = item_info.get(item.value)        
            local max_limit = basic_figure_info.get(_type).max_limit
            if currItemNum + localItem.item_value > max_limit then
                --预判是否超出上限了
                G_MovingTip:showMovingTip(G_lang:get("LANG_ITEM_EXCEED"))
                return
            end         
            local itemInfo = item_info.get(item.value)   
            require("app.scenes.bag.BagUseItemMultiTimesLayer").show(false, ownNum, itemInfo, currItemNum, max_limit)
            return
        end
    end


    -- _type = 1 体力
    -- _type = 2 精力
    -- _type = 23 出征令
    -- _type = 7 免战牌大
    -- _type = 8 免战牌小
    local layer = require("app.scenes.shop.PurchasePowerDialog").create(itemId)
    uf_sceneManager:getCurScene():addChild(layer,2)
end

local _doFly1 = function ( ctrl, offset, vertical, delay, addition, func )
        if not ctrl then
            return 
        end

        if delay <= 0 then 
            if func then 
                func()
            end
        end

        addition = addition or 30
        if offset < 0 then 
            addition = -addition
        end
        local ease1 = CCEaseIn:create(CCMoveBy:create(delay, ccp(vertical and 0 or (offset + addition), vertical and (offset + addition) or 0)), delay)
        local ease2 = CCEaseIn:create(CCMoveBy:create(0.1, ccp(vertical and 0 or -addition, vertical and -addition or 0)), 0.1)
        local arr = CCArray:create()
        arr:addObject(ease1)
        arr:addObject(ease2)
        if func then 
            arr:addObject(CCCallFunc:create(function (  )
                func()
            end))
        end     
        ctrl:runAction(CCSequence:create(arr))   
    end

local _doFly2 = function ( ctrl, delay, offsetPosx, offsetPosy, additionPosx, additionPosy, func )
    if not ctrl then
        return 
    end

    if delay <= 0 then 
        if func then 
            func()
        end
    end

    if offsetPosx < 0 then
        additionPosx = -additionPosx
    end
    if offsetPosy < 0 then 
        additionPosy = -additionPosy
    end

    local ease1 = CCEaseIn:create(CCMoveBy:create(delay, ccp(offsetPosx + additionPosx, offsetPosy + additionPosy)), delay)
    local ease2 = CCEaseIn:create(CCMoveBy:create(0.1, ccp(-additionPosx, -additionPosy)), 0.1)
    local arr = CCArray:create()
    arr:addObject(ease1)
    arr:addObject(ease2)
    arr:addObject(CCCallFunc:create(function (  )
        if func then
            func()
        end
    end))
    ctrl:runAction(CCSequence:create(arr)) 
end

function GlobalFunc.showVipNeedDialog(_type)
    local nextdata = G_Me.vipData:getNextWholeData(_type)
    local nextVip = nextdata.level
    local nextTimes = nextdata.data
    if nextVip == -1 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_MSGBOX_VIPMAX".._type))
        return
    end
    -- 如果是武将背包或者宝物背包，则需要加上原来已有的容量
    if _type == require("app.const.VipConst").KNIGHTBAGVIPEXTRA then
        require("app.cfg.role_info")
        local roleInfo = role_info.get(G_Me.userData.level)
        local initialCount = roleInfo and roleInfo.knight_bag_num_client
        nextTimes = nextTimes + initialCount
    end

    if _type == require("app.const.VipConst").TREASUREBAGVIPEXTRA then
        require("app.cfg.role_info")
        local roleInfo = role_info.get(G_Me.userData.level)
        local initialCount = roleInfo and roleInfo.treasure_bag_num_client
        nextTimes = nextTimes + initialCount
    end

    local str = G_lang:get("LANG_MSGBOX_VIPLEVEL".._type,{vip_level=nextVip,times=nextTimes})
    MessageBoxEx.showYesNoMessage(nil,str,false,function()
        require("app.scenes.shop.recharge.RechargeLayer").show()  
    end,nil,nil,MessageBoxEx.OKNOButton.OKNOBtn_Vip)
end

function GlobalFunc.sayAction(widget,hide,callback,move,hideTime,scale)
    hide = hide or false
    move = move or false
    hideTime = hideTime or 2.1
    scale = scale or 1
    local baseScale = CCScaleTo:create(0.5,scale)
    local animeDelay = CCDelayTime:create(hideTime)
    widget:setScale(0.1)
    widget:setVisible(true)
    if move then
        local basePos = ccp(widget:getPosition())
        local rect = widget:getContentSize()
        local dstPos = ccp(basePos.x,basePos.y+rect.height/2)
        local animeMove = CCMoveTo:create(0.5,basePos)
        widget:setPosition(dstPos)
        baseScale = CCSpawn:createWithTwoActions(baseScale, animeMove)
    end
    local animeScale = CCEaseBounceOut:create(baseScale)
    if not hide then
        widget:runAction(animeScale)
    else
        local arr = CCArray:create()
        arr:addObject(animeScale)
        arr:addObject(animeDelay)
        arr:addObject(CCCallFunc:create(function()
                    widget:setVisible(false)
                    if callback then
                        callback()
                    end
            end))
        local anime = CCSequence:create(arr)
        widget:runAction(anime)
    end
end

function GlobalFunc.shakeAction(widget,time)
    local basePos = ccp(widget:getPosition())
    local leftPos = ccp(basePos.x-5,basePos.y)
    local rightPos = ccp(basePos.x+5,basePos.y)
    local moveLeft = CCMoveTo:create(0.03,leftPos)
    local moveRight = CCMoveTo:create(0.03,rightPos)
    local shake = CCSequence:createWithTwoActions(moveLeft,moveRight)
    local action = CCRepeatForever:create(shake)
    widget:runAction(action)
    if time > 0 then
        local animeDelay = CCDelayTime:create(time)
        local stop = CCSequence:createWithTwoActions(animeDelay,CCCallFunc:create(function()
                widget:stopAllActions()
                widget:setPosition(basePos)
            end))
        widget:runAction(stop)
    end
end

function GlobalFunc.flyFromWidget( ctrls, startWidget, delay, addition, func )
    if not ctrls or type(ctrls) ~= "table" or not startWidget then
        return false
    end

    if delay < 0 then 
        return false
    end

    addition = addition or 0
    if addition < 0 then 
        addition = -addition
    end

    local startPosx, startPosy = startWidget:convertToWorldSpaceXY(0, 0)

    for key, value in pairs(ctrls) do 
        local oldPosx, oldPosy = value:getPosition()

        local anchorPtx, anchorPty = value:getAnchorPointXY()
        local size = value:getSize()
        local newPosx, newPosy = value:convertToNodeSpaceXY(startPosx, startPosy)
        value:setPositionXY(oldPosx + newPosx + (anchorPtx - 0.5)*size.width, 
            oldPosy + newPosy + (anchorPty - 0.5)*size.height)

        local bevelDist = math.sqrt(newPosy*newPosy + newPosx*newPosx)
        local maxYAddtion = addition*math.abs(newPosy)/bevelDist
        local maxXAddition = addition*math.abs(newPosx)/bevelDist
        _doFly2(value, delay, 
            -newPosx - (anchorPtx - 0.5)*size.width, -newPosy - (anchorPty - 0.5)*size.height, 
            maxXAddition, maxYAddtion, (key == #ctrls) and func or nil)
    end
end

function GlobalFunc.flyIntoScreenLR( ctrls, isLeft, delay, scale, addition, func )
    if not ctrls or type(ctrls) ~= "table" then
        return false
    end

    if delay < 0 then 
        return false
    end

    scale = scale or 1
    if scale < 0 then 
        scale = -scale
    end
    
    local size = CCDirector:sharedDirector():getWinSize()
    for key, value in pairs(ctrls) do 
        local posx, posy = value:convertToWorldSpaceXY(0, 0)
        local oldPosx, oldPosy = value:getPosition()
        local ctrlSize = value:getSize()
        local startPosx = isLeft and (-ctrlSize.width) or (size.width + ctrlSize.width)       
        if isLeft then 
            value:setPosition(ccp(oldPosx - scale*(posx - startPosx), oldPosy))
            _doFly1(value, scale*(posx - startPosx), false, delay + 0.1*(key - 1), addition, (key == #ctrls) and func or nil)
        else
            value:setPosition(ccp(oldPosx + scale*(startPosx - posx), oldPosy))
            _doFly1(value, - scale*(startPosx - posx), false, delay + 0.1*(key - 1), addition, (key == #ctrls) and func or nil)
        end        
    end
end

function GlobalFunc.flyOutScreenLR( ctrls, isLeft, delay, scale, addition, func )
    if not ctrls or type(ctrls) ~= "table" then
        return false
    end

    if delay < 0 then 
        return false
    end

    scale = scale or 1
    if scale < 0 then 
        scale = -scale
    end
    
    local size = CCDirector:sharedDirector():getWinSize()
    for key, value in pairs(ctrls) do 
        local posx, posy = value:convertToWorldSpaceXY(0, 0)
        --local oldPosx, oldPosy = value:getPosition()
        local ctrlSize = value:getSize()
        local endPosx = isLeft and (-ctrlSize.width) or (size.width + ctrlSize.width)       
        if isLeft then 
            --value:setPosition(ccp(oldPosx - scale*(posx - startPosx), oldPosy))
            _doFly1(value, -scale*(posx - endPosx), false, delay + 0.1*(key - 1), addition, (key == #ctrls) and func or nil)
        else
            --value:setPosition(ccp(oldPosx + scale*(startPosx - posx), oldPosy))
            _doFly1(value, scale*(endPosx - posx), false, delay + 0.1*(key - 1), addition, (key == #ctrls) and func or nil)
        end        
    end
end

function GlobalFunc.flyIntoScreenTB( ctrls, isTop, delay, scale, addition, func )
    if not ctrls or type(ctrls) ~= "table" then
        return false
    end

    if delay < 0 then 
        return false
    end

    scale = scale or 1
    if scale < 0 then 
        scale = -scale
    end
    
    local size = CCDirector:sharedDirector():getWinSize()
    for key, value in pairs(ctrls) do 
        local posx, posy = value:convertToWorldSpaceXY(0, 0)
        local oldPosx, oldPosy = value:getPosition()
        local ctrlSize = value:getSize()
        local startPosy = isTop and (size.height + ctrlSize.height) or -ctrlSize.height     
        if isTop then 
            value:setPosition(ccp(oldPosx, oldPosy + scale*(startPosy - posy)))            
            _doFly1(value, -scale*(startPosy - posy), true, delay + 0.1*(key - 1), addition, (key == #ctrls) and func or nil)
        else
            value:setPosition(ccp(oldPosx, oldPosy - scale*(posy - startPosy)))
            _doFly1(value, scale*(posy - startPosy), true, delay + 0.1*(key - 1), addition, (key == #ctrls) and func or nil)
        end        
    end
end

function GlobalFunc.flyOutScreenTB( ctrls, isTop, delay, scale, addition, func )
    if not ctrls or type(ctrls) ~= "table" then
        return false
    end

    if delay < 0 then 
        return false
    end

    scale = scale or 1
    if scale < 0 then 
        scale = -scale
    end
    
    local size = CCDirector:sharedDirector():getWinSize()
    for key, value in pairs(ctrls) do 
        local posx, posy = value:convertToWorldSpaceXY(0, 0)
        local oldPosx, oldPosy = value:getPosition()
        local ctrlSize = value:getSize()
        local startPosy = isTop and (size.height + ctrlSize.height) or -ctrlSize.height     
        if isTop then 
            -- value:setPosition(ccp(oldPosx, oldPosy + scale*(startPosy - posy)))            
            _doFly1(value, scale*(startPosy - posy), true, delay + 0.1*(key - 1), addition, (key == #ctrls) and func or nil)
        else
            -- value:setPosition(ccp(oldPosx, oldPosy - scale*(posy - startPosy)))
            _doFly1(value, -scale*(posy - startPosy), true, delay + 0.1*(key - 1), addition, (key == #ctrls) and func or nil)
        end        
    end
end

function GlobalFunc.flyFromMiddleToSize( ctrl, delay1, delay2, func1, func2 )
    if not ctrl then 
        return 
    end

    if delay1 < 0 then 
        delay1 = 0
    end
    
    if delay1 <= 0 then 
        if func1 then 
            func1()
        end
        if func2 then 
            func2()
        end
    end

    local ctrlSize = ctrl:getSize()
    local ctrlSizeCopy = CCSizeMake(ctrlSize.width, ctrlSize.height)
    local startWidth = ctrlSize.width*0.2
    ctrl:setSize(CCSizeMake(startWidth, ctrlSize.height))
    local resetSize = function ( number )
        ctrl:setSize(CCSizeMake(number, ctrlSizeCopy.height))
    end
    
    local maxExtendLen = ctrlSizeCopy.width
    if delay2 and delay2 > 0 then
        maxExtendLen = ctrlSizeCopy.width*1.2
    end

    local numberChange1 = CCNumberGrowupAction:create(startWidth, maxExtendLen, delay1, function ( number )
        resetSize(number)
    end)
    local ease1 = CCEaseIn:create(numberChange1, delay1)
    local numberChange2 = CCNumberGrowupAction:create(maxExtendLen, ctrlSizeCopy.width, delay2, function ( number )
        resetSize(number)
    end)
    local ease2 = CCEaseOut:create(numberChange2, delay2)
    local arr = CCArray:create()
    arr:addObject(ease1)
    arr:addObject(CCCallFunc:create(function (  )
        if func1 then
            func1()
        end
    end))
    if delay2 and delay2 > 0 then 
        arr:addObject(ease2)
        arr:addObject(CCCallFunc:create(function (  )
            if func2 then
                func2()
            end
        end))
    end
    ctrl:runAction(CCSequence:create(arr)) 
end


function GlobalFunc.flyDown( ctrls, time, delay, scale, fun )
    if not ctrls then 
        return 
    end

    if time < 0 then 
        time = 0
    end
    
    if time == 0 then 
        if fun then 
            fun()
        end
    end

    local gaizhange = function ( ctrl, time, delay, scale, fun )
        if not ctrl then 
            return 
        end

        scale = scale or 2
        delay = delay or 0
        ctrl:setVisible(false)
        ctrl:setScale(scale)
        local arr = CCArray:create()
        arr:addObject(CCDelayTime:create(delay))
        arr:addObject(CCCallFunc:create(function ( ... )
            ctrl:setVisible(true)
        end))
        local scaleAction1 = CCScaleTo:create(time, 0.8)
        local scaleAction2 = CCScaleTo:create(0.1, 1)
        arr:addObject(CCEaseIn:create(CCSequence:createWithTwoActions(scaleAction1, scaleAction2), time + 0.1))        
        arr:addObject(CCCallFunc:create(function ( ... )
            if fun then 
                fun()
            end
            --local soundConst = require("app.const.SoundConst")
            --G_SoundManager:playSound(soundConst.GameSound.STAR_SOUND)
        end))
        ctrl:runAction(CCSequence:create(arr))
    end

    local count = #ctrls
    for key, value in pairs(ctrls) do 
        gaizhange(value, time, delay*(key - 1), scale, key == count and fun or nil)
    end
end

function GlobalFunc.createGameLabel( txt, size, color, strokeColor, labelSize, fixWidth )
   local label = Label:create()
   if labelSize then 
    label:setTextAreaSize(labelSize)
   end
   if fixWidth then 
    label:setFixedWidth(true)
   end
   label:setFontSize(size or 20)
   label:setFontName("ui/font/FZYiHei-M20S.ttf")
   label:setColor(color or ccc3(255, 255, 255))
   if strokeColor ~= nil then
        label:createStroke(strokeColor, 1)
   end
   label:setText(txt or "")
   
   return label
end

function GlobalFunc.createGameRichtext( txt, size, color, strokeColor )
    local winSize = CCDirector:sharedDirector():getWinSize()
    local richtext = CCSRichText:create(winSize.width, winSize.height/10)
    richtext:setFontSize(size or 20)
    richtext:setFontName("ui/font/FZYiHei-M20S.ttf")
    richtext:setColor(color or ccc3(255, 255, 255))
    if strokeColor ~= nil then
        richtext:enableStroke(strokeColor)
    end
    richtext:setShowTextFromTop(true)
    richtext:appendContent(txt or "", color or ccc3(255, 255, 255))
    richtext:reloadData()
    richtext:adapterContent()
   
   return richtext
end

-- create a rich-text from a normal template label
function GlobalFunc.createRichTextFromTemplate(template, parent, content, strokeColor, align)
    local posX, posY = template:getPositionX(), template:getPositionY()
    local anchorX, anchorY = template:getAnchorPointXY()
    local anchor
    local size = template:getSize()
    local richText = CCSRichText:create(size.width, size.height)
    richText:setFontName(template:getFontName())
    richText:setFontSize(template:getFontSize())
    richText:setPosition(ccp(posX, posY))
    richText:setAnchorPoint(ccp(anchorX, anchorY))

    if strokeColor ~= nil then
        richText:enableStroke(strokeColor)
    end

    richText:setShowTextFromTop(true)
    richText:appendContent(content, Colors.uiColors.WHITE)
    richText:setTextAlignment(align or kCCTextAlignmentCenter)
    richText:reloadData()
    parent:addChild(richText)

    return richText
end

function GlobalFunc.showTipsAnimation(layer,widgetName)
    local widget = layer:getWidgetByName(widgetName)
    if widget == nil then
        return
    end
    local action01 = CCScaleTo:create(1.2,1.2)
    local action02 = CCScaleBy:create(0.8,0.8)
    local arr = CCArray:create()
    arr:addObject(action01)
    arr:addObject(action02)
    widget:runAction(CCRepeatForever:create(CCSequence:create(arr)))
end

function GlobalFunc.sceneToPack( sceneName, params )
    return {name = sceneName, param = params}
end

function GlobalFunc.packToScene( pack )
    if type(pack) ~= "table" or not pack.name  then 
        return nil 
    end

    if pack.param then 
        return require(pack.name).new( unpack(pack.param))
    else
        return require(pack.name).new( )
    end
end

function GlobalFunc.savePack( obj, pack )
    if obj then 
        obj.__pack__ = pack
    end
end

function GlobalFunc.getPack( obj )
    if obj then 
        return obj.__pack__
    end

    return nil
end
    
local _scene_pairs_ = {
    ["MainScene"]           = "app.scenes.mainscene.MainScene",
    ["PlayingScene"]        = "app.scenes.mainscene.PlayingScene",
    ["ActivityMainScene"]   = "app.scenes.activity.ActivityMainScene",
    ["ArenaScene"]          = "app.scenes.arena.ArenaScene",
    ["BagScene"]            = "app.scenes.bag.BagScene",
    ["BagSellScene"]        = "app.scenes.bag.BagSellScene",
    ["EverydayMainScene"]   = "app.scenes.dailytask.EverydayMainScene",
    ["Day7Scene"]           = "app.scenes.day7.Day7Scene",
    ["DungeonGateScene"]    = "app.scenes.dungeon.DungeonGateScene",
    ["DungeonMainScene"]    = "app.scenes.dungeon.DungeonMainScene",
    ["EquipmentDevelopeScene"] = "app.scenes.equipment.EquipmentDevelopeScene",
    ["EquipmentMainScene"]  = "app.scenes.equipment.EquipmentMainScene",
    ["FriendMainScene"]     = "app.scenes.friend.FriendMainScene",
    ["FundMainScene"]       = "app.scenes.fund.FundMainScene",
    ["HallOfFrameScene"]    = "app.scenes.hallofframe.HallOfFrameScene",
    ["HeroScene"]           = "app.scenes.hero.HeroScene",
    ["HeroDevelopScene"]    = "app.scenes.herofoster.HeroDevelopScene",
    ["HeroFosterScene"]     = "app.scenes.herofoster.HeroFosterScene",
    ["MailScene"]           = "app.scenes.mail.MailScene",
    ["MoShenBattleScene"]   = "app.scenes.moshen.MoShenBattleScene",
    ["MoShenScene"]         = "app.scenes.moshen.MoShenScene",
    ["RecycleScene"]        = "app.scenes.recycle.RecycleScene",
    ["SanguozhiMainScene"]  = "app.scenes.sanguozhi.SanguozhiMainScene",
    ["SecretShopScene"]     = "app.scenes.secretshop.SecretShopScene",
    ["ShopScoreScene"]      = "app.scenes.shop.score.ShopScoreScene",
    ["ShopScene"]           = "app.scenes.shop.ShopScene",
    ["StoryDungeonGateScene"] = "app.scenes.storydungeon.StoryDungeonGateScene",
    ["StoryDungeonMainScene"] = "app.scenes.storydungeon.StoryDungeonMainScene",
    ["TipsInfoList2Scene"]  = "app.scenes.tipsinfo.TipsInfoList2Scene",
    ["TipsInfoList3Scene"]  = "app.scenes.tipsinfo.TipsInfoList3Scene",
    ["TowerScene"]          = "app.scenes.tower.TowerScene",
    ["TreasureComposeScene"] = "app.scenes.treasure.TreasureComposeScene",
    ["TreasureDevelopeScene"] = "app.scenes.treasure.TreasureDevelopeScene",
    ["TreasureMainScene"]   = "app.scenes.treasure.TreasureMainScene",
    ["TreasureRobScene"]    = "app.scenes.treasure.TreasureRobScene",
    ["VipMapScene"]     = "app.scenes.vip.VipMapScene",
    ["WushScene"]   = "app.scenes.wush.WushScene",
    ["CityScene"]   = "app.scenes.city.CityScene",
    ["LegionScene"] = "app.scenes.legion.LegionScene",
    ["LegionListScene"] = "app.scenes.legion.LegionListScene",
    ["LegionDungeionScene"] = "app.scenes.legion.LegionNewDungeionScene",
    ["LegionSacrificeScene"] = "app.scenes.legion.LegionSacrificeScene",
    ["LegionHallScene"] = "app.scenes.legion.LegionHallScene",
    ["HardDungeonMainScene"] = "app.scenes.harddungeon.HardDungeonMainScene",
    ["TimeDungeonMainScene"] = "app.scenes.timedungeon.TimeDungeonMainScene",
    ["TitleScene"] = "app.scenes.title.TitleScene",
    ["CrossWarScene"] = "app.scenes.crosswar.CrossWarScene",
    ["ArenaRobRiceScene"] = "app.scenes.arena.ArenaRobRiceScene",
    ["RebelBossMainScene"] = "app.scenes.moshen.rebelboss.RebelBossMainScene",
    ["DressMainScene"] = "app.scenes.dress.DressMainScene",
    ["CrusadeScene"] = "app.scenes.crusade.CrusadeScene",
    ["PetShopScene"]     = "app.scenes.pet.shop.PetShopScene",
    ["PetBagMainScene"] = "app.scenes.pet.bag.PetBagMainScene",
    ["PetDevelopeScene"] = "app.scenes.pet.develop.PetDevelopeScene",
    ["GroupBuyScene"] = "app.scenes.groupbuy.GroupBuyScene",
    ["TrigramsScene"] = "app.scenes.trigrams.TrigramsScene",
    ["WheelScene"] = "app.scenes.wheel.WheelScene",
    ["RichScene"] = "app.scenes.dafuweng.RichScene",
    ["DailyPvpMainScene"] = "app.scenes.dailypvp.DailyPvpMainScene",
    ["HeroSoulScene"] = "app.scenes.herosoul.HeroSoulScene",
}

function GlobalFunc.getScenePath( sceneName )
    if type(sceneName) == "string" then 
        return _scene_pairs_[sceneName]
    end

    return nil
end

function GlobalFunc.generateScenePack( ... )
    local curSceneName = G_SceneObserver:getSceneName() or ""
    local scenePath = _scene_pairs_[curSceneName]
    if type(scenePath) ~= "string" then 
        return 
    end

    return GlobalFunc.sceneToPack(scenePath)
end

function GlobalFunc.generateSceneBySceneName( sceneName, params )
    local scenePath = GlobalFunc.getScenePath(sceneName)
    if not scenePath then 
        return 
    end

    return GlobalFunc.packToScene({name=scenePath, param=params})
end

function GlobalFunc.createPackScene( obj )
    local pack = GlobalFunc.getPack(obj)
    if not pack then
        return nil 
    end

    return GlobalFunc.packToScene(pack)
end

function GlobalFunc.popSceneWithDefault( sceneName, ... )
    if CCDirector:sharedDirector():getSceneCount() > 1 then 
        uf_sceneManager:popScene()
    elseif type(sceneName) == "string" then
        uf_sceneManager:replaceScene(require(sceneName).new( ... ))
    else
        assert("popSceneWithDefault", "wrong param!")
    end
end

function GlobalFunc.formatText( mainText, values )
    if not mainText or type(values) ~= "table" then 
        return ""
    end

    local tempText = mainText
    for k,v in pairs(values) do
        tempText = string.gsub(tempText, "#" .. k .. "#", v)            
    end

    return tempText
end


function GlobalFunc.showChatBtn( show )
    if G_topLayer then 
        G_topLayer:show(show)
    end
end

--显示魔神弹窗
--[[
    rebId 叛军Id
    rebelLevel  叛军level
    func,回调事件...例如扫荡中,需要停止扫荡
    func中含有参数 func(bool)
    bool为true表示点击了确定
    bool为false表示点击了取消
]]
function GlobalFunc.showRebelDialog(rebId,rebelLevel,func)
    require("app.scenes.moshen.MoShenAppearDialog").show(rebId,rebelLevel,func)
end

-- 设置颜色变暗，目标针对所有含有setColor的对象

local darkColor = ccc3(255/2, 255/2, 255/2)
local originalColor = ccc3(255, 255, 255)

function GlobalFunc.setDark(target, isDark)
    
    assert(target and target.setColor, "The target should not be nil or do not have setColor method !")
    target.setColor(target, isDark and darkColor or originalColor)
    
end

-- 根据美术需求设置颜色变灰，目标针对所有含有setColor的对象(一般仅针对图片文字)

local grayColor = ccc3(0xcc, 0xcc, 0xcc)
local originalColor = ccc3(255, 255, 255)

function GlobalFunc.setGray(target, isGray)
    
    assert(target and target.setColor, "The target should not be nil or do not have setColor method !")
    target.setColor(target, isGray and grayColor or originalColor)
    
end

function GlobalFunc.isTimeToday( timeStamp )
    timeStamp = timeStamp or 0

    if G_ServerTime:isBeforeToday(timeStamp) then
        return -1
    else
        return 1
    end

   
end


function GlobalFunc.showBaseInfo( goodType, value, scenePack )
    if type(goodType) ~= "number" or type(value) ~= "number" then 
        return 
    end

    if goodType == G_Goods.TYPE_KNIGHT then 
        require("app.scenes.common.baseInfo.BaseInfoKnight").showWidthBaseId(value, scenePack)
    elseif goodType == G_Goods.TYPE_EQUIPMENT then
        require("app.scenes.common.baseInfo.BaseInfoEquip").showWidthBaseId(value, scenePack)
       -- require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_EQUIPMENT, value)
    elseif goodType == G_Goods.TYPE_TREASURE then
        require("app.scenes.common.baseInfo.BaseInfoTreasure").showWidthBaseId(value, scenePack)
        --require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_TREASURE, value)
    elseif goodType ==G_Goods.TYPE_FRAGMENT then
        --侠客|装备|战宠碎片
        local goods = fragment_info.get(value)
        if goods.fragment_type == 1 then
            require("app.scenes.common.baseInfo.BaseInfoKnight").showWidthFragmentId(value, scenePack)
        elseif goods.fragment_type == 2 then
            require("app.scenes.common.baseInfo.BaseInfoEquip").showWidthFragmentId(value, scenePack)
            --require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_FRAGMENT, value) 
        elseif goods.fragment_type == 3 then
            -- 战宠碎片
            require("app.scenes.common.baseInfo.BaseInfoPet").showWidthFragmentId(value, scenePack)
        end
    elseif goodType == G_Goods.TYPE_TREASURE_FRAGMENT then
        require("app.scenes.common.baseInfo.BaseInfoTreasure").showWidthFragmentId(value, scenePack)
    elseif goodType == G_Goods.TYPE_PET then
        -- 战宠
        require("app.scenes.common.baseInfo.BaseInfoPet").showWidthBaseId(value, scenePack)
    elseif goodType == G_Goods.TYPE_HERO_SOUL then
        require("app.scenes.herosoul.HeroSoulInfoLayer").show(value)
    end
end

--[[
获取战斗结果

    战斗评价 图片
    不死人 = 完胜  -------------------1
    死一人 = 胜利  -------------------2
    死二、三、四、五人 = 险胜；-------3
    对方剩余1人 = 惜败； -------------4
    对方剩余2、3、4、5人 = 失败；-----5
    对方不死人 = 惨败  -------------- 6

lineup01 我方上阵
lineup02 敌方上阵人数
   num01 我方剩余人数
   num02 敌方剩余人数

   isWin 当回合数超出时候，双方都有人时,该参数才有效
]]

-- getPackParams
-- function GlobalFunc.getBattleResult(lineup01,,num01,num02,isWin)
function GlobalFunc.getBattleResult(battleLayer)
    local FightEnd = require("app.scenes.common.fightend.FightEnd")
    -- local WAN_SHENG = "1"
    -- local SHENG_LI = "2"
    -- local XIAN_SHENG = "3"
    -- local XI_BAI = "4"
    -- local SHI_BAI = "5"
    -- local CAN_BAI = "6"

    --[[
        统一用宏表示
    ]]
    local WAN_SHENG     = FightEnd.RESULT_WANSHENG
    local SHENG_LI      = FightEnd.RESULT_SHENG_LI
    local XIAN_SHENG    = FightEnd.RESULT_XIAN_SHENG
    local XI_BAI        = FightEnd.RESULT_XI_BAI
    local SHI_BAI       = FightEnd.RESULT_SHI_BAI
    local CAN_BAI       = FightEnd.RESULT_CAN_BAI
    --[[
        FightEnd.RESULT_WANSHENG    = "1"
        FightEnd.RESULT_SHENG_LI    = "2"
        FightEnd.RESULT_XIAN_SHENG  = "3"
        FightEnd.RESULT_XI_BAI      = "4"
        FightEnd.RESULT_SHI_BAI     = "5"
        FightEnd.RESULT_CAN_BAI     = "6"
    ]]
    if not battleLayer then
        return nil
    end
    -- local num01 = battleLayer:getHeroKnightAmount()
    -- local num02 = battleLayer:getEnemyKnightAmount()
    local num01 = battleLayer:getLeftHeroKnightAmount()
    local num02 = battleLayer:getLeftEnemyKnightAmount()
    
    local lineup01 = battleLayer:getHeroKnightUpAmount()
    local lineup02 = battleLayer:getEnemyKnightUpAmount()
    local isWin = battleLayer:getPackParams("msg")
    if lineup01 == 0 or lineup02 == 0 or isWin == nil then
        return SHENG_LI
    end
    isWin = isWin.is_win

    --我方人数为0,失败
    local result =  SHENG_LI
    if num01 == 0 then
        -- 按照对方上阵人数计算
        if lineup02 <= 2 then
            result = SHI_BAI
        else
            if lineup02-num02 == 0 then  
                result = CAN_BAI
            elseif num02 == 1 then
                result = XI_BAI
            else
                result = SHI_BAI
            end
        end
    elseif num02 == 0 then
        if lineup01 <= 2 then
            result = SHENG_LI
        else
            if lineup01-num01 == 0 then
                result = WAN_SHENG
            elseif lineup01-num01 == 1 then
                result = SHENG_LI
            else
                result = XIAN_SHENG
            end
        end
    elseif isWin then
        result = SHENG_LI
    else
        result = SHI_BAI
    end

    return result
end

--[[
    战斗评价 图片
    不死人 = 完胜  -------------------1
    死一人 = 胜利  -------------------2
    死二、三、四、五人 = 险胜；-------3
    对方剩余1人 = 惜败； -------------4
    对方剩余2、3、4、5人 = 失败；-----5
    对方不死人 = 惨败  -------------- 6
    
    --1星   失败

]]
function GlobalFunc.getHardDungeonBattleResult(isWin,star)
    if not isWin then
        return "5"
    end
    star = star or 1
    print("星数 = " .. star)
    if star == 3 then
        return "1"
    elseif star == 2 then
        return "2"
    else
        return "3"
    end
end

function GlobalFunc.isNowDaily( ... )
    local hour = 0
    if not G_ServerTime then 
        local time = os.time()
        local tab = G_ServerTime:getDateObject(time)
        --local tab = os.date("*t", time)
        hour = tab and tab.hour or 10
    else
        hour = G_ServerTime:getCurrentHHMMSS()
    end

    if G_Me and G_Me.userData and type(G_Me.userData.level) == "number" and G_Me.userData.level < 20 then 
        return true
    end

    return (hour >= 6 and hour < 18)
end

function GlobalFunc.showDayEffect( scenePart, parent )
    if not parent then 
        return 
    end

    local EffectNode = require "app.common.effects.EffectNode"
    local isDaily = GlobalFunc.isNowDaily()
    
    local effects = {}
    if isDaily then 
        effects = G_Path.getDayEffect(scenePart)
    else
        effects = G_Path.getNightEffect(scenePart)
    end

    local isWidget = (parent.getWidgetType ~= nil)

    for key, value in pairs(effects) do 
        local effect  = nil 
        if value ~= "effect_zjmbt" then
            effect = EffectNode.new(value)
        else
            effect = EffectNode.new(value, function(event, frameIndex)
                if event and event == "hit" then 
                    G_SoundManager:playSound("audio/kxdh3.mp3")
                end
             end)
        end
        if effect then 
            effect:play()
            if isWidget then 
                parent:addNode(effect)
            else
                parent:addChild(effect)
            end
        end
    end
end

function GlobalFunc.replaceForAppVersion( image )
    if not image or not image.loadTexture then 
        return false
    end

    local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    if appstoreVersion then 
        image:loadTexture("ui/arena/xiaozhushou_hexie.png", UI_TEX_TYPE_LOCAL)
    end

    return appstoreVersion
end

function GlobalFunc.uploadLog(info)

    local ComSdkUtils = require("upgrade.ComSdkUtils")

    --info 只能含有2个参数, 
    --event_id
    --param1, 必须是string类型

    if #info == 1 then
        table.insert(info, {param1=""})
    elseif #info >= 2 then
        local newinfo = {}
        for i, v in ipairs(info) do
            table.insert(newinfo, v)
            if #newinfo >= 2 then
                break
            end
        end
        info = newinfo
    end


    ComSdkUtils.call("stGameEvent", info)

    
end

function GlobalFunc.table_is_empty(t)

        return _G.next( t ) == nil

end

function GlobalFunc.trace(str)

    
end


local remote_logid = 1
function GlobalFunc.add_remote_log(str)
    local device = G_PlatformProxy:getDeviceId()
    local request = uf_netManager:createHTTPRequestGet("http://logceshi2.n.m.youzu.com/test?" .. tostring(device) .."&" .. str .."&id=" .. remote_logid)
    remote_logid = remote_logid + 1
    request:start()
end



function GlobalFunc.url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str    
end

function GlobalFunc.save_event_log(str, params)
    local versionUrl = require("upgrade.ComSdkUtils").getVersionUrl(VERSION_URL_TMPL)
    if params == nil then
        params = {}
    end
    params['d'] = G_PlatformProxy:getDeviceId()
    --services/nconfig?action=get_config
    --  ->
    -- nconfig/services/events?action=event
    local domain = string.match(versionUrl ,"^(http://.*)/services/")    
    local url = tostring(domain) .. "/services/events?action=add&event=" .. tostring(str)
    for k,v in pairs(params) do 
        url = url .. '&' .. k .. "=" .. tostring(v)
    end

    local request = uf_netManager:createHTTPRequestGet(url)
    request:start()
end

--创建一堆标准的icon
--{panel,award,click,name,offset,left,maxX,yoffset,numType}
function GlobalFunc.createIconInPanel(data)
    local panel = data.panel
    local award = data.award
    local count = #award
    local offset = data.offset or 10
    local click = data.click or false
    local name = data.name or false
    local left = data.left or false
    local maxX = data.maxX or 0
    local itemx = 100
    local itemy = name and 155 or 100
    local offsety = name and 0 or -55
    local yoffset = data.yoffset or 10
    local numType = data.numType or 0
    local panelSize = panel:getContentSize()
    local index = 0
    local iconList = {}
    for k , v in pairs(award) do 
        if maxX > 0 then
            local posx = panelSize.width/2 - maxX/2*itemx - offset*(maxX-1)/2 + (itemx + offset)*(index%maxX)
            if left then
                posx = (itemx + offset)*(index%maxX) + offset
            end
            local totalHeight = math.floor((count-1)/maxX)+1
            local curHeight = totalHeight - math.floor(index/maxX) - 1
            local posy = (panelSize.height - itemy*totalHeight-yoffset*(totalHeight-1))/2 + offsety + itemy*curHeight+yoffset*curHeight
            index = index + 1
            local iconLight = nil
            if rawget(v,"light") then
                iconLight = v.light
            end
            local _forceSize = nil
            if rawget(v,"forceSize") then
                _forceSize = v.forceSize
            end
            local item = GlobalFunc.createIcon({type=v.type,value=v.value,size=v.size,forceSize=_forceSize,click=click,name=name,light=iconLight,numType=numType})
            panel:addChild(item)
            item:setPosition(ccp(posx,posy))
            table.insert(iconList,#iconList+1,item)
        else
            local posx = panelSize.width/2 - count/2*itemx - offset*(count-1)/2 + (itemx + offset)*index
            if left then
                posx = (itemx + offset)*index + offset
            end
            local posy = (panelSize.height - itemy)/2 + offsety
            index = index + 1
            local iconLight = nil
            if rawget(v,"light") then
                iconLight = v.light
            end
            local _forceSize = nil
            if rawget(v,"forceSize") then
                _forceSize = v.forceSize
            end
            local item = GlobalFunc.createIcon({type=v.type,value=v.value,size=v.size,forceSize=_forceSize,click=click,name=name,light=iconLight,numType=numType})
            panel:addChild(item)
            item:setPosition(ccp(posx,posy))
            table.insert(iconList,#iconList+1,item)
        end
    end
    return iconList
end

--创建一堆标准的icon
--{panel,award,click,name,offset,left,maxX,yoffset,numType}
function GlobalFunc.createIconInPanel2(data)
    local panel = data.panel
    local award = data.award
    local count = #award
    local offset = data.offset or 10
    local click = data.click or false
    local name = data.name or false
    local left = data.left or false
    local maxX = data.maxX or 0
    local itemx = 100
    local itemy = name and 140 or 100
    local offsety = name and 0 or -55
    local yoffset = data.yoffset or 10
    local numType = data.numType or 0
    local panelSize = panel:getContentSize()
    local index = 0
    local iconList = {}
    for k , v in pairs(award) do 
        if maxX > 0 then
            local posx = panelSize.width/2 - maxX/2*itemx - offset*(maxX-1)/2 + (itemx + offset)*(index%maxX)
            if left then
                posx = (itemx + offset)*(index%maxX) + offset
            end
            local totalHeight = math.floor((count-1)/maxX)+1
            local curHeight = totalHeight - math.floor(index/maxX) - 1
            local posy = (panelSize.height - itemy*totalHeight-yoffset*(totalHeight-1))/2 + offsety + itemy*curHeight+yoffset*curHeight
            index = index + 1
            local iconLight = nil
            if rawget(v,"light") then
                iconLight = v.light
            end
            local _forceSize = nil
            if rawget(v,"forceSize") then
                _forceSize = v.forceSize
            end
            local item = GlobalFunc.createIcon({type=v.type,value=v.value,size=v.size,forceSize=_forceSize,click=click,name=name,light=iconLight,numType=numType})
            panel:addChild(item)
            item:setPosition(ccp(posx,posy))
            table.insert(iconList,#iconList+1,item)
        else
            local posx = panelSize.width/2 - count/2*itemx - offset*(count-1)/2 + (itemx + offset)*index
            if left then
                posx = (itemx + offset)*index + offset
            end
            local posy = (panelSize.height - itemy)/2 + offsety
            index = index + 1
            local iconLight = nil
            if rawget(v,"light") then
                iconLight = v.light
            end
            local _forceSize = nil
            if rawget(v,"forceSize") then
                _forceSize = v.forceSize
            end
            local item = GlobalFunc.createIcon({type=v.type,value=v.value,size=v.size,forceSize=_forceSize,click=click,name=name,light=iconLight,numType=numType})
            panel:addChild(item)
            item:setPosition(ccp(posx,posy))
            table.insert(iconList,#iconList+1,item)
        end
    end
    return iconList
end

function GlobalFunc.refreshIcon(data)
    local iconList = data.iconList
    local award = data.award
    for k , item in pairs(iconList) do 
        local data = award[k]
        local g = G_Goods.convert(data.type, data.value)
        if g then
            item:setVisible(true)
            item:getImageViewByName("Image_icon"):loadTexture(g.icon)
            item:getImageViewByName("Image_ball"):loadTexture(G_Path.getEquipIconBack(g.quality))
            item:getButtonByName("Button_board"):loadTextureNormal(G_Path.getEquipColorImage(g.quality,data.type))
            item:getButtonByName("Button_board"):loadTextureDisabled(G_Path.getEquipColorImage(g.quality,data.type))
            item:getLabelByName("Label_name"):setText(g.name)
            item:getLabelByName("Label_num"):setText("x"..data.size)
            item:getLabelByName("Label_num"):setVisible(true)
            item:getLabelByName("Label_num"):createStroke(Colors.strokeBrown, 1)
            item:regisgerWidgetTouchEvent("Button_board", function ( widget, param )
                if param == TOUCH_EVENT_ENDED then -- 点击事件
                    require("app.scenes.common.dropinfo.DropInfo").show(data.type, data.value)  
                end
            end)
        else
            item:setVisible(false)
        end
    end
end

--创建一个标准的icon
--{type=0,value=0,size=0,click=false,name=false,light=false,forceSize=false,iconName,numType}
function GlobalFunc.createIcon(data)
        if data == nil then
            return nil
        end
        local item = CCSItemCellBase:create("ui_layout/common_Icon.json")
        local g = G_Goods.convert(data.type, data.value)
        if not g then
            item:setVisible(false)
        end
        if g then
            item:getImageViewByName("Image_icon"):loadTexture(g.icon)
            item:getImageViewByName("Image_ball"):loadTexture(G_Path.getEquipIconBack(g.quality))
            item:getButtonByName("Button_board"):loadTextureNormal(G_Path.getEquipColorImage(g.quality,data.type))
            item:getButtonByName("Button_board"):loadTextureDisabled(G_Path.getEquipColorImage(g.quality,data.type))
        end
        if rawget(data, "name") and data.name == true then
            item:getLabelByName("Label_name"):createStroke(Colors.strokeBrown, 1)
            if g then item:getLabelByName("Label_name"):setText(g.name) end
            item:getLabelByName("Label_name"):setColor(Colors.qualityColors[g.quality])
            item:getLabelByName("Label_name"):setVisible(true)
            item:getLabelByName("Label_name"):setPositionY(item:getLabelByName("Label_name"):getPositionY() - 5)
        else
            item:getLabelByName("Label_name"):setVisible(false)
        end

        if rawget(data, "labelsize") and data.labelsize == true then
            item:getLabelByName("Label_NameAutoSize"):setVisible(true)
            
            item:getLabelByName("Label_NameAutoSize"):createStroke(Colors.strokeBrown, 1)
            if g then item:getLabelByName("Label_NameAutoSize"):setText(g.name) end
            item:getLabelByName("Label_NameAutoSize"):setColor(Colors.qualityColors[g.quality])
            item:getLabelByName("Label_NameAutoSize"):setPositionY(item:getLabelByName("Label_NameAutoSize"):getPositionY() - 5)
        else
            item:getLabelByName("Label_NameAutoSize"):setVisible(false)
        end

        if (rawget(data, "forceSize") and data.forceSize == true )  or (rawget(data, "size") and data.size > 0) then
            item:getLabelByName("Label_num"):setVisible(true)
            local num = data.size
            local numType = rawget(data,"numType") 
            if numType and numType == 1 then
                num = GlobalFunc.ConvertNumToCharacter(num)
            elseif numType and numType == 2 then
                num = GlobalFunc.ConvertNumToCharacter2(num)
            elseif numType and numType == 3 then
                num = GlobalFunc.ConvertNumToCharacter3(num)
            elseif numType and numType == 4 then
                num = GlobalFunc.ConvertNumToCharacter4(num)
            end
            if g then item:getLabelByName("Label_num"):setText("x"..num) end
            item:getLabelByName("Label_num"):createStroke(Colors.strokeBrown, 1)
            item:getLabelByName("Label_num"):setPositionX(item:getLabelByName("Label_num"):getPositionX() - 5)
        else
            item:getLabelByName("Label_num"):setVisible(false)
        end
        if rawget(data, "click") and data.click == true then
            item:getButtonByName("Button_board"):setTouchEnabled(true)
            if g then
                item:regisgerWidgetTouchEvent("Button_board", function ( widget, param )
                    if param == TOUCH_EVENT_ENDED then -- 点击事件
                        require("app.scenes.common.dropinfo.DropInfo").show(data.type, data.value)  
                    end
                end)
            end
        else
            item:getButtonByName("Button_board"):setTouchEnabled(false)
        end
        if rawget(data, "light") and data.light then
            if g then
                local node = require("app.common.effects.EffectNode").new("effect_around1")     
                node:setScale(1.7) 
                node:setPosition(ccp(5,-5))
                node:play()
                item:getImageViewByName("Image_board"):addNode(node,10)
            end
        end
        return item

end


function GlobalFunc.getDungeonData(id)
    --可配置活动去读dungeon_info_holiday
    --圣诞活动去读dungeon_info_holiday
    
    -- 多语言版本，只需要翻译一张dungeon_info表就可以了
    local func = function(id)
        if G_Me.activityData.custom:isDungeonActive() then
            require("app.cfg.dungeon_info_config")
            return dungeon_info_config.get(id)
        else
            if G_Me.activityData.holiday:isActivate() then
                require("app.cfg.dungeon_info_holiday")
                return dungeon_info_holiday.get(id)
            else
                require("app.cfg.dungeon_info")
                return dungeon_info.get(id)
            end
        end
    end

    require("app.cfg.dungeon_info")
    local tTmpl = func(id)
    local tNormalTmpl = dungeon_info.get(id)
    if tTmpl and tNormalTmpl then
        tTmpl.talk = tNormalTmpl.talk
    end

    return tTmpl
end

function GlobalFunc.getHardDungeonData(id)
    if G_Me.activityData.custom.isDungeonActive and G_Me.activityData.custom:isDungeonActive() then
        require("app.cfg.hard_dungeon_info_config")
        return hard_dungeon_info_config.get(id)
    else
        if G_Me.activityData.holiday.isHardActivate and G_Me.activityData.holiday:isHardActivate() then
            require("app.cfg.hard_dungeon_info_holiday")
            return hard_dungeon_info_holiday.get(id)
        else
            require("app.cfg.hard_dungeon_info")
            return hard_dungeon_info.get(id)
        end
    end    
end

function GlobalFunc.getOnlineTime( t )
    if type(t) ~= "number" then 
        return ""
    end

    local str = ""
    if t == 0 then 
        str = G_lang:get("LANG_FRIEND_ONLINE1")
        return str
    end

     t = G_ServerTime:getTime() - t

    local min=math.floor(t/60)
    local hour=math.floor(min/60)
    local day=math.floor(hour/24)

    if day >= 31 then 
        str = G_lang:get("LANG_FRIEND_ONLINE5")
    elseif day >= 8 then
        str = G_lang:get("LANG_FRIEND_ONLINE6")
    elseif day >= 1 then
        str = G_lang:get("LANG_FRIEND_ONLINE2", {time=day})
    elseif hour >= 1 then 
        str = G_lang:get("LANG_FRIEND_ONLINE3", {time=hour})
    else
        if min == 0 then
            min = 1
        end
        str = G_lang:get("LANG_FRIEND_ONLINE4", {time=min})
    end
    return str
end

--时间戳转成时分秒形式 add by kaka
function GlobalFunc.formatTimeToHourMinSec( time )

	local timeStr = ""

	if type(time) == "number" and time > 0 then
	    local second = time%60
	    local min=math.floor(time/60)
	    local hour=math.floor(min/60)
	    min = min % 60
	    if hour > 0 then
	        timeStr = timeStr..hour..G_lang:get("LANG_HOUR")
	    end
	    if min > 0 or hour > 0 then
	        timeStr = timeStr..min..G_lang:get("LANG_MINUTE")
	    end
	    if second > 0 or min > 0 or hour > 0 then
	        timeStr = timeStr..second..G_lang:get("LANG_SECEND")
	    end
	end

    return timeStr

end


function GlobalFunc.saveBattle(t, s)
    
end

-- 返回金友龙宝宝的id
function GlobalFunc.getGoldDragonId()
    return 2003
end

-- 返回武将变身需要花费的元宝数
function GlobalFunc.getKnightTransformCost(nSourceKnightId, nTargetKnightBaseId)
    require("app.cfg.knight_advance_info")
    require("app.cfg.knight_awaken_info")
    require("app.cfg.knight_transform_info")

    -- 自己1张卡，突破消耗的卡片，觉醒消耗的卡片
    local nPriceFactor1 = 1 -- source武将的价格系数
    local nPriceFactor2 = 1 -- target武将的价格系数
    local nTargetConst = 1  -- target武将常量,目标卡牌常量

    local nCost = 0
    local nCardNum = 0
    local tSourceKnight = G_Me.bagData.knightsData:getKnightByKnightId(nSourceKnightId)
    local tSourceKnightTmpl = nil
    local nAdvanceLevel = 0
    local nAwakenLevel = 0
    local nCost2 = 0 -- 红转红消耗的武将精华
    if tSourceKnight then
        tSourceKnightTmpl = knight_info.get(tSourceKnight["base_id"])
        nAdvanceLevel = tSourceKnightTmpl.advanced_level
        nAwakenLevel = tSourceKnight.awaken_level
    end
    local tTargetKnightTmpl = knight_info.get(nTargetKnightBaseId)
    -- 价格系数
    for i=1, knight_transform_info.getLength() do
        local tTransformTmpl = knight_transform_info.indexOf(i)
        if tTransformTmpl and tTransformTmpl.advanced_code == tSourceKnightTmpl.advance_code then
            nPriceFactor1 = tTransformTmpl.cost 
        end
        if tTransformTmpl and tTransformTmpl.advanced_code == tTargetKnightTmpl.advance_code then
            nPriceFactor2 = tTransformTmpl.cost 
            nTargetConst = tTransformTmpl.constant
            nCost2 = tTransformTmpl.cost_2
        end
    --    __Log("-- nPriceFactor1 = %.2f, nPriceFactor2 = %.2f", nPriceFactor1, nPriceFactor2)
    end

    local nAdvanceCardNum = 0
    local nAwakenCardNum = 0

    if tSourceKnightTmpl and tTargetKnightTmpl then
        -- 突破吃掉的卡片
        for i=1, knight_advance_info.getLength() do
            local tAdvanceTmpl = knight_advance_info.indexOf(i)
            if tAdvanceTmpl and tAdvanceTmpl.knight_type == 2 then 
                if tAdvanceTmpl.advanced_level < nAdvanceLevel then
                    for j=1, 4 do 
                        local type = tAdvanceTmpl["cost"..j.."_type"]
                        local value = tAdvanceTmpl["cost"..j.."_value"]
                        local size = tAdvanceTmpl["cost"..j.."_num"]
                        if type == 1 then
                            nCardNum = nCardNum + size
                            nAdvanceCardNum = nAdvanceCardNum + size
                        end
                    end
                end
            end
        end

        -- 觉醒吃掉的卡片
        for i=1, knight_awaken_info.getLength() do
            local tAwakenTmpl = knight_awaken_info.indexOf(i) 
            if tAwakenTmpl and tAwakenTmpl.awaken_code == tSourceKnightTmpl.awaken_code then
                if tAwakenTmpl.awaken_level < nAwakenLevel then
                    for j=1, 2 do
                        local type = tAwakenTmpl["cost_"..j.."_type"]
                        local value = tAwakenTmpl["cost_"..j.."_value"]
                        local size = tAwakenTmpl["cost_"..j.."_size"]
                        if type == 1 then
                            nCardNum = nCardNum + size
                            nAwakenCardNum = nAwakenCardNum + size
                        end
                    end
                end
            end
        end

        -- 化神
        -- 一张卡牌合成需要的碎片数
        local tFragmentTmpl = fragment_info.get(tSourceKnightTmpl.fragment_id)
        if tFragmentTmpl then
            local nPiece = tFragmentTmpl.max_num
            local nFrag = rawget(tSourceKnight, "frag_consume") and tSourceKnight.frag_consume or 0
            nCardNum = nCardNum + nFrag / nPiece
        end
    end

    -- 武将自己的卡片也要消耗掉
    nCardNum = nCardNum + 1

    --[[
        if(原卡牌价值系数>=目标卡牌价值系数)   
            消耗元宝=目标卡牌常量*原卡牌同名卡张数
        else    
            消耗元宝=（目标卡牌常量+（目标卡牌价值系数-原卡牌价值系数））*原卡牌同名卡张数
        end
    ]]
    if nPriceFactor1 >= nPriceFactor2 then
        nCost = nTargetConst * nCardNum
    else
        nCost = (nTargetConst + (nPriceFactor2-nPriceFactor1)) * nCardNum
    end

   -- __Log("-- nCardNum = %.2f", nCardNum)

    -- 红色武将精华（真红转真红）
    local nJingHua = math.floor(nCost2 * nCardNum)

    return math.floor(nCost), nJingHua
end

-- 将一行内容水平居中于界面
-- 要求：- 一行中的内容(label, image等)锚点需为(0,0.5)，且都挂在一个panel上
--       - 该panel在界面背景图片上，背景的锚点需为(0.5,0.5)
function GlobalFunc.centerContent(panel)
    local children = {}
    if device.platform == "wp8" or device.platform == "winrt" then
        children = panel:getChildrenWidget() or {}
    else
        children = panel:getChildren() or {}
    end
    if not children then 
        return 0
    end
    local count = children:count()

    -- calculate the total width of whole contents
    local totalWidth = 0
    for i = 0, count - 1 do
        local obj = children:objectAtIndex(i)
        if obj:isVisible() then
            obj:setPositionX(totalWidth)
            totalWidth = totalWidth + obj:getContentSize().width
        end
    end

    -- get parent's attribute
    local parent        = panel:getParent()
    local parentWidth   = parent:getContentSize().width
    local parentAnchorX = parent:getAnchorPointXY()

    -- calculate the position of the panel
    local center = parentWidth / 2 - parentWidth * parentAnchorX
    local x =  center - totalWidth / 2
    panel:setPositionX(x)
end

-- 将text分成n个汉字一行 retType  0返回一行，1返回一个表
function GlobalFunc.autoNewLine(text,n,retType)
    if not retType then
        retType = 0
    end
    local result = ""
    local retTable = {}
    if not text or n < 1 then 
        return result
    end 
    n = n * 3
    while #text > n do 
        result = result .. string.sub(text, 1, n) .. "\n"
        table.insert(retTable,string.sub(text, 1, n))
        text = string.sub(text, n+1, #text)
    end
    result = result .. text
    table.insert(retTable,text)
    if retType == 0 then 
        return result
    else 
        return retTable
    end
end 

function GlobalFunc.addHeadIcon(parent,level)
    parent:removeNodeByTag(333)
    if level ~= 10 and level ~= 12 then
        return
    end
    local EffectNode = require "app.common.effects.EffectNode"
    local _effect = EffectNode.new("effect_vip_v" .. tostring(level))  
    if level == 10 then 
        _effect:setPositionXY(0,-40)   
    end
    _effect:play()
    parent:addNode(_effect,1,333)
    -- print ("level = " .. tostring(level) .. "\n")
end

function GlobalFunc.updateLabel(target, name, params)
    local RebelBossCommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
    RebelBossCommonFunc._updateLabel(target, name, params)
end

function GlobalFunc.updateImageView(target, name, params)
    local RebelBossCommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
    RebelBossCommonFunc._updateImageView(target, name, params)
end

function GlobalFunc.autoAlign(basePosition, items, align)
    local RebelBossCommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
    return RebelBossCommonFunc._autoAlignNew(basePosition, items, align)
end

-- 过关斩将星星描述
function GlobalFunc.getExDungeonBattleResult(nStar)
    local WAN_SHENG = "1"
    local SHENG_LI = "2"
    local XIAN_SHENG = "3"
    local XI_BAI = "4"
    local SHI_BAI = "5"
    local CAN_BAI = "6"

    nStar = nStar or 0
    local result = SHENG_LI
    if nStar == 0 then
        result = SHI_BAI
    elseif nStar == 1 then
        result = XIAN_SHENG
    elseif nStar == 2 then
        result = SHENG_LI
    elseif nStar == 3 then
        result = WAN_SHENG
    end
    return result
end


--经常为了打patch，需要保存old函数， 然后执行新函数
--runOldFlag 取值为before（默认）,after, "",表示是先执行老代码还是先执行新代码，还是直接忽略老代码
function GlobalFunc.replaceFunction(classTbl, funcName, newFunc, runOldFlag)
    local oldName = funcName .. "Old"
    if classTbl[oldName] == nil then 
        classTbl[oldName] = classTbl[funcName]
        if runOldFlag == nil then 
            runOldFlag = "before"
        end
        classTbl[funcName] = function(self, ...)
            if runOldFlag == "before" then 
                classTbl[oldName](self, ...)
            end
            newFunc(self, ...)
            if runOldFlag == "after" then 
                classTbl[oldName](self, ...)
            end
        end 
        return true 
    end 
    return false
end

-- 一行居中显示的富文本
function GlobalFunc.createRichTextSingleRow(labelTmpl)
    labelTmpl:setText("")
    local size = labelTmpl:getSize()
    local parent = labelTmpl:getParent()
    size = CCSizeMake(display.width, 40)

    local labelRichText = CCSRichText:createSingleRow()
    labelRichText:setFontName(labelTmpl:getFontName())
    labelRichText:setFontSize(labelTmpl:getFontSize())
    labelRichText:setShowTextFromTop(true)
    labelRichText:enableStroke(Colors.strokeBrown)
    labelRichText:setAnchorPoint(ccp(0.5, 0.5))
    local x, y = labelTmpl:getPosition()
    labelRichText:setPosition(ccp(x, y))
    parent:addChild(labelRichText, 5)

    return labelRichText
end

-- nId, 对应shop_price_info的id
-- nCount=1, 表示第一次购买的价格
function GlobalFunc.getPrice(nId, nCount)
    local tList = {}
    for i=1, shop_price_info.getLength() do
        local tTmpl = shop_price_info.indexOf(i)
        if tTmpl and tTmpl.id == nId then
            table.insert(tList, #tList+1, tTmpl)
        end
    end
    --dump(tList)

    local nPrice = 0
    for i=1, #tList do
        local tTmpl = tList[i]
        local tTmplNext = tList[i+1]
        if tTmplNext then   
            if tTmpl.num <= nCount and tTmplNext.num > nCount then
                nPrice = tTmpl.price
                break
            end
        else
            nPrice = tTmpl.price
        end
    end
    return nPrice
end

return GlobalFunc
