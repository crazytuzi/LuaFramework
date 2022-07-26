require"Lang"
UIBag = { }
local scrollView = nil
local listItem = nil
local btnItem = nil
local bagFlag = nil
local sellFlag = nil  -- 出售标志位
local expandNum = nil
local ExpandPrice = nil

local function compareThing(value1, value2)
    --  if DictThing[tostring(value1.int["3"])].isUse == 0 and DictThing[tostring(value2.int["3"])].isUse ~= 0 then
    if DictThing[tostring(value1.int["3"])].indexOrder > DictThing[tostring(value2.int["3"])].indexOrder then
        return true
    else
        return false
    end
end

local function compare(value1, value2)
    return value1.int["8"] > value2.int["8"]
end
local function netCallbackFunc(pack)
    if tonumber(pack.header) == StaticMsgRule.bagExpand then
        UIManager.showToast(Lang.ui_bag1)
    end
    UIManager.flushWidget(UITeamInfo)
    UIManager.flushWidget(UIBag)
end

local function ExpandCallBack()
    if ExpandPrice <= net.InstPlayer.int["5"] then
        if bagFlag == 1 then
            utils.sendExpandData(StaticBag_Type.item, netCallbackFunc)
        elseif bagFlag == 2 then
            utils.sendExpandData(StaticBag_Type.core, netCallbackFunc)
        end
    else
        UIManager.showToast(Lang.ui_bag2)
    end
end

local function setScrollViewItem(flag, _Item, _obj)
    local image_frame_gem = _Item:getChildByName("image_frame_gem")
    local image_price = _Item:getChildByName("image_price")
    local price_text = image_price:getChildByName("text_price")
    local image = image_frame_gem:getChildByName("image_gem")
    local num = _Item:getChildByName("text_number")
    local name = _Item:getChildByName("text_gem_name")
    local description = ccui.Helper:seekNodeByName(_Item, "text_gem_describe")
    local btn_lineup = _Item:getChildByName("btn_lineup")
    local btn_change = _Item:getChildByName("btn_change")
    btn_lineup:setPressedActionEnabled(true)
    btn_change:setPressedActionEnabled(true)
    local tableFieldId = _obj.int["3"]
    local name_text = DictThing[tostring(tableFieldId)].name
    local smallUiId = DictThing[tostring(tableFieldId)].smallUiId
    local smallImage = DictUI[tostring(smallUiId)] and DictUI[tostring(smallUiId)].fileName or "frame_tianjia.png"
    local description_text = DictThing[tostring(tableFieldId)].description
    local num_text = _obj.int["5"]
    if tableFieldId == StaticThing.goldBox then
        num_text = num_text + _obj.int["4"]
    end
    local price = DictThing[tostring(tableFieldId)].sellCopper
    price_text:setString(string.format("×%d", price))
    if sellFlag then
        image_price:setVisible(true)
    else
        image_price:setVisible(false)
    end
    local qualityId = utils.addBorderImage(StaticTableType.DictThing, tableFieldId, image_frame_gem)
    utils.changeNameColor(name, qualityId)
    name:setString(name_text)
    num:setString(string.format(Lang.ui_bag3, num_text))
    image:loadTexture("image/" .. smallImage)
    if description_text ~= nil then
        description:setString(description_text)
    end
    local function btnUseFunc(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local _dictThingId = _obj.int["3"]
            if _dictThingId >= StaticThing.nXuanYiKaiShi and _dictThingId <= StaticThing.nXuanYiJieShu then
                local openBoxData = utils.stringSplit(DictThing[tostring(_dictThingId)].childThings, ";")
                for i, data in ipairs(openBoxData) do
                    data = utils.stringSplit(data, "_")
                    openBoxData[i] = { tableTypeId = tonumber(data[1]), tableFieldId = tonumber(data[2]), value = tonumber(data[3]) }
                end
                UIBoxGet.setData(openBoxData, UIBoxGet.STATE_RADIO, _obj.int["1"])
                UIManager.pushScene("ui_box_get")
            elseif _dictThingId == StaticThing.goldBox
                or _dictThingId == StaticThing.silverBox
                or _dictThingId == StaticThing.copperBox
                or _dictThingId == StaticThing.goldKey
                or _dictThingId == StaticThing.silverKey
                or _dictThingId == StaticThing.copperKey
                or(StaticThing.lihezuixiazhi <= _dictThingId and _dictThingId <= StaticThing.lihezuidazhi) then
                UIBoxUse.setData(_obj)
                UIManager.pushScene("ui_box_use")
            elseif _dictThingId == StaticThing.unionPracticeRoll then
                UIAllianceSkillInfo.show() 
            elseif _dictThingId == StaticThing.thing158 then  --改名
                UIBagChange.setType( 1 )
                UIManager.pushScene("ui_bag_change")
            elseif _dictThingId == StaticThing.thing159 then  --使用改名卡             
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.clickChangeNameCard , msgdata = { int = { type = 2 } } } , function ( pack )
                    UIBagChange.setType( 2 )
                    UIManager.pushScene("ui_bag_change")
                end )   
            elseif StaticThing.zhandouKaiShi <= _dictThingId and _dictThingId <= StaticThing.zhandouJieShu then
                local openBoxFightCallback = function(_isWin, _pushFightDialog)
                    UIManager.showLoading()
                    local sendData = {
                        header = StaticMsgRule.openBox,
                        msgdata = {
                            int = {
                                instPlayerThingId = _obj.int["1"],
                                num = 1,
                                isFightWin = _isWin --0-战斗失败、1-战斗胜利
                            }
                        }
                    }
					netSendPackage(sendData, function(_msgData)
                        local _boxData = utils.stringSplit(_msgData.msgdata.string["1"], ";")
	                    local _openBoxData = {}
	                    for key, obj in pairs(_boxData) do
		                    local _thing = utils.stringSplit(obj, "_")
		                    _openBoxData[#_openBoxData + 1] = (tonumber(_thing[1]) == 1 and DictGenerBoxThing[_thing[2]] or DictSpecialBoxThing[_thing[2]])
	                    end
                        if _pushFightDialog then
                            UIBagWinSmall.show({isWin = _isWin, thingData = _openBoxData[1]})
                        else
                            utils.showOpenBoxAnimationUI(_openBoxData)
                            UIManager.flushWidget(UIBag)
                        end
                    end)

                end
                --&&&&&&开箱子触发战斗的概率:50%
                local isFight = (utils.random(0, 1) == 1) and true or false
                if isFight then
                    UIBagHint.show({sureCallFunc = function() --//挑战回调
                        UIManager.showLoading()
                        netSendPackage({
                            header = StaticMsgRule.getArenaFightData,
                            msgdata = {}
                        }, function(_msgData)
                            pvp.loadGameData(_msgData)
                            utils.sendFightData(nil, dp.FightType.FIGHT_BAG_OPEN_BOX, function(isWin)
                                openBoxFightCallback(isWin, true)
                            end)
                            UIFightMain.loading()
                        end)
                    end, cancelCallFunc = function() --放弃回调
                        openBoxFightCallback(0)
                    end})
                else
                    openBoxFightCallback(0)
                end
            else
                -----背包使用-----------
                UISellProp.setData(_obj, "UIBagUse")
                UIManager.pushScene("ui_sell_prop")
            end
        end
    end
    local function btnSellFunc(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UISellProp.setData(_obj, UIBag)
            UIManager.pushScene("ui_sell_prop")
        end
    end
    if flag == 1 then
        -- 道具
        btn_change:setVisible(false)
        if sellFlag then
            btn_lineup:setVisible(true)
            btn_lineup:setTitleText(Lang.ui_bag4)
            btn_lineup:addTouchEventListener(btnSellFunc)
        else
            if tonumber(DictThing[tostring(tableFieldId)].isUse) == 0 then
                btn_lineup:setVisible(false)
            else
                btn_lineup:setVisible(true)
                btn_lineup:setTitleText(Lang.ui_bag5)
            end
            btn_lineup:addTouchEventListener(btnUseFunc)
        end
    elseif flag == 2 then
        -- 魔核
        local function btnEvent(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                sender:retain()
                if sender == btn_change then
                    UIGemSwitch.setData(_obj, UIBag)
                    UIManager.pushScene("ui_gem_switch")
                elseif sender == btn_lineup then
                    UIGemUpGrade.setData(_obj, UIBag)
                    UIManager.pushScene("ui_gem_upgrade")
                end
                cc.release(sender)
            end
        end
        btn_change:addTouchEventListener(btnEvent)
        if sellFlag then
            btn_lineup:setVisible(true)
            btn_change:setVisible(false)
            btn_lineup:setTitleText(Lang.ui_bag6)
            btn_lineup:addTouchEventListener(btnSellFunc)
        else
            btn_lineup:setVisible(true)
            btn_change:setVisible(true)
            btn_lineup:setTitleText(Lang.ui_bag7)
            btn_lineup:addTouchEventListener(btnEvent)
        end
    end
end

local function selectedBtnChange(flag)
    local btn_prop = ccui.Helper:seekNodeByName(UIBag.Widget, "btn_prop")
    local btn_gem = ccui.Helper:seekNodeByName(UIBag.Widget, "btn_gem")
    if flag == 1 then
        btn_gem:loadTextureNormal("ui/yh_btn01.png")
        btn_gem:getChildByName("text_gem"):setTextColor(cc.c4b(255, 255, 255, 255))
        btn_prop:loadTextureNormal("ui/yh_btn02.png")
        btn_prop:getChildByName("text_prop"):setTextColor(cc.c4b(51, 25, 4, 255))
    elseif flag == 2 then
        btn_prop:loadTextureNormal("ui/yh_btn01.png")
        btn_prop:getChildByName("text_prop"):setTextColor(cc.c4b(255, 255, 255, 255))
        btn_gem:loadTextureNormal("ui/yh_btn02.png")
        btn_gem:getChildByName("text_gem"):setTextColor(cc.c4b(51, 25, 4, 255))
    end
end

function UIBag.init()
    local btn_prop = ccui.Helper:seekNodeByName(UIBag.Widget, "btn_prop")
    -- 道具按钮
    local btn_gem = ccui.Helper:seekNodeByName(UIBag.Widget, "btn_gem")
    -- 魔核按钮
    local btn_expansion = ccui.Helper:seekNodeByName(UIBag.Widget, "btn_expansion")
    -- 扩充按钮
    local btn_sell = ccui.Helper:seekNodeByName(UIBag.Widget, "btn_sell")
    -- 出售按钮
    btn_prop:setPressedActionEnabled(true)
    btn_gem:setPressedActionEnabled(true)
    btn_expansion:setPressedActionEnabled(true)
    btn_sell:setPressedActionEnabled(true)

    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_prop then
                if bagFlag == 1 then
                    return
                end
                bagFlag = 1
                UIBag.setup()
            elseif sender == btn_gem then
                if bagFlag == 2 then
                    return
                end
                bagFlag = 2
                UIBag.setup()
            elseif sender == btn_expansion then
                local hint = ""
                if expandNum == nil then
                    expandNum = 0
                end
                ExpandPrice = DictSysConfig[tostring(StaticSysConfig.expandInitGold)].value + expandNum * DictSysConfig[tostring(StaticSysConfig.bagExpandGoldGrow)].value
                if bagFlag == 1 then
                    hint = Lang.ui_bag8 .. ExpandPrice .. Lang.ui_bag9
                else
                    hint = Lang.ui_bag10 .. ExpandPrice .. Lang.ui_bag11
                end
                utils.PromptDialog(ExpandCallBack, hint)
            elseif sender == btn_sell then
                if sellFlag == false then
                    btn_prop:setVisible(false)
                    btn_gem:setVisible(false)
                    btn_expansion:setVisible(false)
                    btn_sell:loadTextureNormal("ui/fh_btn.png")
                    btn_sell:loadTexturePressed("ui/fh_btn.png")
                    btn_sell:setScaleX(0.9)
                    btn_sell:setScaleY(0.8)
                    sellFlag = true
                else
                    sellFlag = false
                    btn_prop:setVisible(true)
                    btn_gem:setVisible(true)
                    btn_expansion:setVisible(true)
                    btn_sell:setScale(1)
                    btn_sell:loadTextureNormal("ui/chushou_btn.png")
                    btn_sell:loadTexturePressed("ui/chushou_btn.png")
                end
                UIBag.setup()
            end
        end
    end
    btn_prop:addTouchEventListener(btnEvent)
    btn_gem:addTouchEventListener(btnEvent)
    btn_expansion:addTouchEventListener(btnEvent)
    btn_sell:addTouchEventListener(btnEvent)
    scrollView = ccui.Helper:seekNodeByName(UIBag.Widget, "view_list_gem")
    --  滚动层
    listItem = scrollView:getChildByName("image_base_gem"):clone()
    btnItem = scrollView:getChildByName("btn_buy"):clone()
end

function UIBag.setup()
    if sellFlag == nil then
        sellFlag = false
        local btn_prop = ccui.Helper:seekNodeByName(UIBag.Widget, "btn_prop")
        -- 道具按钮
        local btn_gem = ccui.Helper:seekNodeByName(UIBag.Widget, "btn_gem")
        -- 魔核按钮
        local btn_expansion = ccui.Helper:seekNodeByName(UIBag.Widget, "btn_expansion")
        -- 扩充按钮
        local btn_sell = ccui.Helper:seekNodeByName(UIBag.Widget, "btn_sell")
        -- 出售按钮
        btn_prop:setVisible(true)
        btn_gem:setVisible(true)
        btn_expansion:setVisible(true)
        btn_sell:setScale(1)
        btn_sell:loadTextureNormal("ui/chushou_btn.png")
        btn_sell:loadTexturePressed("ui/chushou_btn.png")
    end
    local grid = 0
    if listItem:getReferenceCount() == 1 then
        listItem:retain()
    end
    if btnItem:getReferenceCount() == 1 then
        btnItem:retain()
    end
    if net.InstPlayerBagExpand then
        for key, obj in pairs(net.InstPlayerBagExpand) do
            if obj.int["3"] == StaticBag_Type.item and bagFlag == 1 then
                grid = obj.int["4"] + DictBagType[tostring(obj.int["3"])].bagUpLimit
                expandNum = obj.int["6"]
            end
            if obj.int["3"] == StaticBag_Type.core and bagFlag == 2 then
                grid = obj.int["4"] + DictBagType[tostring(obj.int["3"])].bagUpLimit
                expandNum = obj.int["6"]
            end
        end
    end
    if bagFlag == 1 and grid == 0 then
        grid = DictBagType[tostring(StaticBag_Type.item)].bagUpLimit
    elseif bagFlag == 2 and grid == 0 then
        grid = DictBagType[tostring(StaticBag_Type.core)].bagUpLimit
    end
    local text_ceiling = ccui.Helper:seekNodeByName(UIBag.Widget, "text_ceiling")
    scrollView:removeAllChildren()
    local BagThing = { }
    if net.InstPlayerThing then
        if bagFlag == 1 then
            for key, obj in pairs(net.InstPlayerThing) do
                if obj.int and obj.int["7"] == StaticBag_Type.item and obj.int["3"] ~= StaticThing.soulSource and obj.int["3"] ~= StaticThing.washRock and obj.int["3"] ~= StaticThing.fireScore then
                    table.insert(BagThing, obj)
                end
            end
            utils.quickSort(BagThing, compareThing)
        elseif bagFlag == 2 then
            for key, obj in pairs(net.InstPlayerThing) do
                if obj.int and obj.int["7"] == StaticBag_Type.core then
                    table.insert(BagThing, obj)
                end
            end
            utils.quickSort(BagThing, compare)
        end
    end
    selectedBtnChange(bagFlag)
    if BagThing then
        utils.updateView(UIBag, scrollView, listItem, BagThing, setScrollViewItem, bagFlag, btnItem)
    end
    text_ceiling:setString(string.format(Lang.ui_bag12, #BagThing, grid))
end
function UIBag.reset()
    bagFlag = 1
end
function UIBag.free()
    scrollView:removeAllChildren()
    sellFlag = nil
    ExpandPrice = nil
    expandNum = nil
    bagFlag = nil
end
