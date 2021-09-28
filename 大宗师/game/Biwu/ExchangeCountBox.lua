--[[
 --
 -- add by vicky
 -- 2014.10.06 
 --
 --]]

 local ExchangeCountBox = class("ExchangeCountBox", function()
    return require("utility.ShadeLayer").new()
 end)


 function ExchangeCountBox:ctor(param)
    dump(param)
    self.shopType = param.shopType or ARENA_SHOP_TYPE
    local reputation = param.reputation 
    local itemData = param.itemData 
    local havenum = itemData.had 
    local remainnum = itemData.limitNum 
    local listener = param.listener 
    local closeFunc = param.closeFunc 

    local proxy = CCBProxy:create()
    local rootnode = {}

    local node = CCBuilderReaderLoad("arena/biwu_exchange_item_count.ccbi", proxy, rootnode) 
    node:setPosition(display.width/2, display.height/2) 
    self:addChild(node) 

    if self.shopType == HUASHAN_SHOP_TYPE then
        rootnode["lingshi_node"]:setVisible(true)
        rootnode["shengwang_node"]:setVisible(false)
    end

    local function onClose()
        if closeFunc ~= nil then 
            closeFunc() 
        end 
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

    rootnode["haveLabel"]:setString("共拥有" .. tostring(havenum) .. "个")

    if string.utf8len(itemData.name) < 3 then 
        rootnode["chose_lbl"]:setString("请选择兑换       的次数") 
    elseif string.utf8len(itemData.name) < 5 then 
        rootnode["chose_lbl"]:setString("请选择兑换           的次数") 
    elseif string.utf8len(itemData.name) < 8 then 
        rootnode["chose_lbl"]:setString("请选择兑换                   的次数") 
    end 


    -- 名称
    local nameColor = ccc3(255, 255, 255)
    if itemData.iconType == ResMgr.ITEM or itemData.iconType == ResMgr.EQUIP then 
        nameColor = ResMgr.getItemNameColor(itemData.id)
    elseif itemData.iconType == ResMgr.HERO then 
        nameColor = ResMgr.getHeroNameColor(itemData.id)
    end

    local nameLbl = ui.newTTFLabelWithShadow({
        text = itemData.name,
        size = 24,
        color = nameColor,
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_haibao,
        align = ui.TEXT_ALIGN_CENTER 
        })

    nameLbl:setPosition(0, 0)
    rootnode["nameLabel"]:removeAllChildren()
    rootnode["nameLabel"]:addChild(nameLbl) 


    local num = 0 

    local function onNumBtn(event, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        local tag = sender:getTag() 

        if 1 == tag then -- +1 
            if remainnum < 1 then 
                show_tip_label("已经达到最大兑换数量")
            else
                num = num + 1 
                remainnum = remainnum - 1 
            end

        elseif 2 == tag then -- +10 
            if remainnum < 1 then 
                show_tip_label("已经达到最大兑换数量")
            elseif remainnum < 10 then 
                num = num + remainnum
                remainnum = 0 
            else
                num = num + 10 
                remainnum = remainnum - 10 
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

        rootnode["exchangeCountLabel"]:setString(tostring(num))
        rootnode["costLabel"]:setString(tostring(num * itemData.needReputation))
    end

    rootnode["add10Btn"]:addHandleOfControlEvent(onNumBtn , CCControlEventTouchUpInside)
    rootnode["add1Btn"]:addHandleOfControlEvent(onNumBtn , CCControlEventTouchUpInside)
    rootnode["reduce10Btn"]:addHandleOfControlEvent(onNumBtn , CCControlEventTouchUpInside)
    rootnode["reduce1Btn"]:addHandleOfControlEvent(onNumBtn , CCControlEventTouchUpInside)

    onNumBtn(_, rootnode["add1Btn"])

	ResMgr.setControlBtnEvent(rootnode["confirmBtn"],function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if num > 0 then
            if num * itemData.needReputation > reputation then
                show_tip_label("荣誉不足！")
            else
                listener(num)
                onClose()
            end
        else
            show_tip_label("请选择兑换次数")
        end 
    end)
 end

 return ExchangeCountBox

