--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 6/28/14
-- Time: 2:44 PM
-- To change this template use File | Settings | File Templates.
--
local data_item_item = require("data.data_item_item")

local BuyCountBox = class("BuyCountBox", function()
    return require("utility.ShadeLayer").new()
end)

function BuyCountBox:ctor(param, callback, errorCB)
    dump(param)

    local proxy = CCBProxy:create()
    local rootnode = {}

    local node = CCBuilderReaderLoad("shop/buy_item_count.ccbi", proxy, rootnode)
    node:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
    self:addChild(node)

    local function onClose()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        self:removeFromParentAndCleanup(true)
    end
--    local closeBtn = require("utility.CommonButton").new({
--        img = "#popwin_close.png",
--        listener = onClose
--    })
--    closeBtn:setPosition(-closeBtn:getContentSize().width / 2, -closeBtn:getContentSize().height / 2)
--    rootnode["closeBtnPos"]:addChild(closeBtn)

    
    rootnode["closeBtn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        onClose()
    end,
    CCControlEventTouchDown)

    rootnode["cancelBtn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        onClose()
    end,
    CCControlEventTouchDown)

    -- TODO  需要注意，此处商店第一个商品是货币，不显示已经拥有的数量 design by Chenjian
    if(data_item_item[param.itemId].type == 7 and  data_item_item[param.itemId].effecttype == 0 and data_item_item[param.itemId].auto == 1) then
        rootnode["haveLabel"]:setVisible(false)
    end

    rootnode["haveLabel"]:setString(tostring(string.format("共拥有 %d 个",param.havenum)) )

    local itemNameLabel = ui.newTTFLabelWithOutline({
            text = "",
            font = FONTS_NAME.font_haibao,
            size = 24,
            color = ccc3(255,243,0),
            align = ui.TEXT_ALIGN_CENTER,
            -- x = rootnode["nameLabel"]:getContentSize().width/2,
            -- y = rootnode["nameLabel"]:getContentSize().height/2
        })
    -- itemNameLabel:setAnchorPoint(ccp(0.5,0.5))
    itemNameLabel:setString(string.format("%s",param.name))
    itemNameLabel:setPosition(rootnode["nameLabel"]:getContentSize().width/2, rootnode["nameLabel"]:getContentSize().height/2)    
    rootnode["nameLabel"]:addChild(itemNameLabel)

    -- rootnode["nameLabel"]:setString(param.name)
    rootnode["costLabel"]:setString("0")

    local num = 1
    local remainnum = param.remainnum - 1
    
    local function getCost()
--        if  m>maxN-1
--        s=（price+maxN*addPrice）*n
--        else   if  m+n<maxN+2
--        s=n*now+n*(n-1)*addPrice/2
--        else
--            s=(maxN-m+1)*(price+m*addPrice)+(maxN-m+1)*(maxN-m)*addPrice/2+(m+n-maxN-1)*(price+maxN*addPrice)


        local tmpNum = (param.hadBuy + num)   --总共购买次数
        local costNum = 0
        if param.hadBuy > (param.maxN - 1) then
            costNum = (param.baseprice + param.maxN * param.addPrice) * num
            printf("%d = (%d + %d * %d) * %d = %d", costNum, param.baseprice, param.maxN, param.addPrice, num, costNum)
        elseif tmpNum < param.maxN + 2 then
            costNum = num * param.price + num * (num - 1) * param.addPrice / 2
            printf("%d * %d + %d * (%d - 1) * %d / 2", num, param.baseprice, num, num, param.addPrice)
        else
            costNum = (param.maxN - param.hadBuy + 1) * (param.baseprice + param.hadBuy * param.addPrice) +
                    (param.maxN - param.hadBuy + 1) * (param.maxN - param.hadBuy) * param.addPrice / 2 + (tmpNum - param.maxN - 1) * (param.baseprice + param.maxN * param.addPrice)
        end


--        local costNum = ((param.price + (param.baseprice + (tmpNum - 1) * param.addPrice)) * num) / 2
        return costNum
    end
    
    rootnode["costLabel"]:setString(tostring(getCost()))
    local function onNumBtn(event, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if(event == nil) then
            return
        end
        local tag = sender:getTag()
        if 1 == tag then -- +1

            if (-1 == param.maxnum) or (remainnum > 0) then
                num = num + 1
                remainnum = remainnum - 1
            else
                show_tip_label("已经达到最大购买数量")
            end

        elseif 2 == tag then -- +10

            if (-1 == param.maxnum) or (remainnum >= 10) then
                num = num + 10
                remainnum = remainnum - 10
            elseif remainnum > 0 and remainnum < 10 then
                num = num + remainnum
                remainnum = 0
            else
                show_tip_label("已经达到最大购买数量")
            end

        elseif 3 == tag then -- -1
            if (num > 1) then
                num = num - 1
                remainnum = remainnum + 1
            end

        elseif 4 == tag then -- -10
            print("-10:" .. num .. "," .. remainnum)
            if num > 1 and num < 10 then
                remainnum = remainnum + num - 1
                num = 1
            elseif num > 10 then
                num = num - 10
                remainnum = remainnum + 10
            elseif num == 10 then
                num = num - 10 + 1
                remainnum = remainnum + 10 - 1
            end
        end


        rootnode["buyCountLabel"]:setString(tostring(num))
        rootnode["costLabel"]:setString(tostring(getCost()))
--        printf("((%d + (%d + %d * %d)) * %d) / 2", param.price, param.baseprice, tmpNum, param.addPrice, num)
--        printf("basePrice = %d, addPrice = %d, curNum = %d, buyNum = %d, allMoney = %d", param.baseprice, param.addPrice, num, param.hadBuy, costNum)
    end

    rootnode["add10Btn"]:addHandleOfControlEvent(onNumBtn , CCControlEventTouchUpInside)
    rootnode["add1Btn"]:addHandleOfControlEvent(onNumBtn , CCControlEventTouchUpInside)
    rootnode["reduce10Btn"]:addHandleOfControlEvent(onNumBtn , CCControlEventTouchUpInside)
    rootnode["reduce1Btn"]:addHandleOfControlEvent(onNumBtn , CCControlEventTouchUpInside)

    onNumBtn(_, rootnode["add1Btn"])

    rootnode["confirmBtn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if num > 0 then
            RequestHelper.buy({
                callback = function(data)
                    dump(data)
                    -- device.showAlert("buy","cb")
                    if string.len(data["0"]) > 0 then
                        CCMessageBox(data["0"], "Tip")
                    else
                        local price = math.min(param.baseprice + param.addPrice * data["1"].hadBuy, param.baseprice + param.maxN * param.addPrice)
                        printf("======== %d", remainnum)
                        param.remainnum = remainnum
                        param.hadBuy = param.hadBuy + num
                        param.havenum = param.havenum + num
                        param.price = price
                        game.player:setGold(data["2"])
                        game.player:setSilver(data["3"])

                        if callback then
                            callback()
                        end

                        PostNotice(NoticeKey.CommonUpdate_Label_Gold)
                        PostNotice(NoticeKey.CommonUpdate_Label_Silver)

                        num = 0
                    end
                    onClose()
                end,
                errback = function ()
                    -- device.showAlert("error buy","cb")
                    errorCB()
                    onClose()
                end,
                id = tostring(param.id),
                n = tostring(num),
                coinType = tostring(param.coinType),
                coin = tostring(getCost())
            })

        end
    end,
    CCControlEventTouchDown)
end

return BuyCountBox

