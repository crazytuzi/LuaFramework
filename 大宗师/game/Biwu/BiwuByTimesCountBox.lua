--
-- Author: Daniel
-- Date: 2015-01-30 20:35:35
--

local BiwuByTimesCountBox = class("BiwuByTimesCountBox", function()
    return require("utility.ShadeLayer").new()
end)

function BiwuByTimesCountBox:ctor(param, successCallBack)
    dump(param)

    local proxy = CCBProxy:create()
    local rootnode = {}

    local node = CCBuilderReaderLoad("shop/biwu_buy_item_count.ccbi", proxy, rootnode)
    node:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
    self:addChild(node)

    local function onClose()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        self:removeFromParentAndCleanup(true)
    end

    ResMgr.setControlBtnEvent(rootnode["cancelBtn"],function() 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        onClose()
    end)

    ResMgr.setControlBtnEvent(rootnode["closeBtn"],function() 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        onClose()
    end)


    rootnode["haveLabel"]:setVisible(false)


    local itemNameLabel = ui.newTTFLabelWithOutline({
            text = "",
            font = FONTS_NAME.font_haibao,
            size = 24,
            color = ccc3(255,243,0),
            align = ui.TEXT_ALIGN_CENTER,
        })
    itemNameLabel:setString(string.format("%s",param.name))
    itemNameLabel:setPosition(rootnode["nameLabel"]:getContentSize().width/2, rootnode["nameLabel"]:getContentSize().height/2)    
    rootnode["nameLabel"]:addChild(itemNameLabel)
    rootnode["costLabel"]:setString("0")

    local num = 1
    local remainnum = param.remainnum - 1
    
    local function getCost()
    	local tmpNum = (param.hadBuy + num)
	    local costNum = 0
        if param.hadBuy > (param.maxN - 1) then
            costNum = (param.baseprice + param.maxN * param.addPrice) * num
        elseif tmpNum < param.maxN + 2 then
            costNum = num * param.price + num * (num - 1) * param.addPrice / 2
        else
            costNum = (param.maxN - param.hadBuy + 1) * (param.baseprice + param.hadBuy * param.addPrice) +
                    (param.maxN - param.hadBuy + 1) * (param.maxN - param.hadBuy) * param.addPrice / 2 + (tmpNum - param.maxN - 1) * (param.baseprice + param.maxN * param.addPrice)
        end
		return costNum
    end
    rootnode["tag_bug_time"]:setString(tostring(param.maxnum))
    rootnode["tag_bug_time"]:setVisible(true)
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
 end

    rootnode["add10Btn"]:addHandleOfControlEvent(onNumBtn , CCControlEventTouchUpInside)
    rootnode["add1Btn"]:addHandleOfControlEvent(onNumBtn , CCControlEventTouchUpInside)
    rootnode["reduce10Btn"]:addHandleOfControlEvent(onNumBtn , CCControlEventTouchUpInside)
    rootnode["reduce1Btn"]:addHandleOfControlEvent(onNumBtn , CCControlEventTouchUpInside)

    onNumBtn(_, rootnode["add1Btn"])

	ResMgr.setControlBtnEvent(rootnode["confirmBtn"],function() 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if num > 0 then
        	successCallBack(num,costNum)
        	self:removeFromParent()
        end
    end)
end

return BiwuByTimesCountBox
