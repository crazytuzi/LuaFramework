--[[
 --
 -- add by vicky
 -- 2014.09.22
 --
 --]]
local data_item_item = require("data.data_item_item")
local UseCountBox = class("UseCountBox", function()
    return require("utility.ShadeLayer").new()
end)

function UseCountBox:ctor(param)
    dump(param)

    local havenum = param.havenum or 1
    local name = param.name 
    local listener = param.listener
    local expend = param.expend

    local proxy = CCBProxy:create()
    local rootnode = {}

    local node = CCBuilderReaderLoad("bag/use_item_count.ccbi", proxy, rootnode)
    -- node:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
    node:setPosition(display.width/2, display.height/2) 
    self:addChild(node) 

    local function onClose()
        self:removeFromParentAndCleanup(true)
    end

    rootnode["cancelBtn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        onClose()
    end,
    CCControlEventTouchDown) 

    rootnode["haveLabel"]:setString(tostring(string.format("共拥有 %d 个",param.havenum)) )

    if string.utf8len(param.name) < 3 then 
        rootnode["chose_lbl"]:setString("请选择使用       的数量") 
    elseif string.utf8len(param.name) < 5 then 
        rootnode["chose_lbl"]:setString("请选择使用           的数量") 
    elseif string.utf8len(param.name) < 8 then 
        rootnode["chose_lbl"]:setString("请选择使用                   的数量") 
    end 

    local itemNameLabel = ui.newTTFLabelWithOutline({
            text = string.format("%s",param.name),
            font = FONTS_NAME.font_haibao,
            size = 24,
            color = ccc3(255,243,0), 
            align = ui.TEXT_ALIGN_CENTER 
        })
    itemNameLabel:setPosition(0, 0)
    rootnode["nameLabel"]:removeAllChildren()
    rootnode["nameLabel"]:addChild(itemNameLabel)

    local num = 0
    local remainnum = 50 
    if havenum < remainnum then 
        remainnum = havenum 
    end 

    local function onNumBtn(event, sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        local tag = sender:getTag() 

        if 1 == tag then -- +1

            if remainnum < 1 then 
                show_tip_label("已经达到最大使用数量")
            else
                if expend.id and expend.num <= num then
                    show_tip_label(string.format("%s数量不足", data_item_item[expend.id].name))
                else
                    num = num + 1
                    remainnum = remainnum - 1
                end
            end

        elseif 2 == tag then -- +10

            if remainnum < 1 then 
                show_tip_label("已经达到最大使用数量")
            elseif remainnum < 10 then

                if expend.id and expend.num <= num then
                    show_tip_label(string.format("%s数量不足", data_item_item[expend.id].name))
                else
                    if expend.id and expend.num < (num + remainnum) then
                        num = num + (expend.num - num)
                        remainnum = remainnum - (expend.num - num)
                    else
                        num = num + remainnum
                        remainnum = 0
                    end
                end
            else
                if expend.id and expend.num <= num then
                    show_tip_label(string.format("%s数量不足", data_item_item[expend.id].name))
                else
                    if expend.id and expend.num < (num + 10) then

                        num = num + (expend.num - num)
                        remainnum = remainnum - (expend.num - num)
                    else
                        num = num + 10
                        remainnum = remainnum - 10
                    end
                end
            end

        elseif 3 == tag then -- -1
            if (num > 1) then
                num = num - 1
                remainnum = remainnum + 1
            end

        elseif 4 == tag then -- -10
            if num > 1 and num <= 10 then
                remainnum = remainnum + num - 1
                num = 1
            elseif num > 10 then
                num = num - 10
                remainnum = remainnum + 10
            end
        end

        rootnode["useCountLabel"]:setString(tostring(num))
    end

    rootnode["add10Btn"]:addHandleOfControlEvent(onNumBtn , CCControlEventTouchUpInside)
    rootnode["add1Btn"]:addHandleOfControlEvent(onNumBtn , CCControlEventTouchUpInside)
    rootnode["reduce10Btn"]:addHandleOfControlEvent(onNumBtn , CCControlEventTouchUpInside)
    rootnode["reduce1Btn"]:addHandleOfControlEvent(onNumBtn , CCControlEventTouchUpInside)

    onNumBtn(_, rootnode["add1Btn"])

    rootnode["confirmBtn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if num > 0 then
            listener(num)
            onClose()
        end
    end,
    CCControlEventTouchDown)
end

return UseCountBox

