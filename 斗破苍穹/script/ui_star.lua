UIStar = { }
UIStar.curChooseG = 0
local function freshCurPai()
    local image_pai1 = ccui.Helper:seekNodeByName(UIStar.Widget, "image_pai1")
    local image_pai2 = ccui.Helper:seekNodeByName(UIStar.Widget, "image_pai2")
    local image_pai3 = ccui.Helper:seekNodeByName(UIStar.Widget, "image_pai3")
    if UIStar.curChooseG == 1 then
        utils.addFrameParticle(image_pai1, true, 1.5, false, 80, 40)
        utils.addFrameParticle(image_pai2, false)
        utils.addFrameParticle(image_pai3, false)
    elseif UIStar.curChooseG == 2 then
        utils.addFrameParticle(image_pai1, false)
        utils.addFrameParticle(image_pai2, true, 1.5, false, 80, 40)
        utils.addFrameParticle(image_pai3, false)
    elseif UIStar.curChooseG == 3 then
        utils.addFrameParticle(image_pai1, false)
        utils.addFrameParticle(image_pai2, false)
        utils.addFrameParticle(image_pai3, true, 1.5, false, 80, 40)
    end
end
local function callBack(pack)
    net.InstPlayerHoldStar = { }
    if pack.msgdata.message then
        local temp = pack.msgdata.message.InstPlayerHoldStar.message
        for key, value in pairs(temp) do
            -- table.insert( net.InstPlayerHoldStar , value )
            net.InstPlayerHoldStar[key] = value
            -- net.InstPlayerHoldStar = value
        end
    end
    UIStar.checkImageHint()
    UIStar.curChooseG = pack.msgdata.int.openGradeId
    freshCurPai()
    -- cclog("curChooseG : "..UIStar.curChooseG)
end
local function netSendData()
    local sendData = {
        header = StaticMsgRule.intoHoldStar,
        msgdata =
        {

        }
    }
    netSendPackage(sendData, callBack)
end
function UIStar.init()
    local basemap = ccui.Helper:seekNodeByName(UIStar.Widget, "image_basemap")
    local animation = ActionManager.getEffectAnimation(60)
    animation:getAnimation():setSpeedScale(0.7)
    animation:setPosition(cc.p(basemap:getContentSize().width / 2, basemap:getContentSize().height / 2))
    basemap:addChild(animation)
    local image_pai1 = ccui.Helper:seekNodeByName(UIStar.Widget, "image_pai1")
    local image_pai2 = ccui.Helper:seekNodeByName(UIStar.Widget, "image_pai2")
    local image_pai3 = ccui.Helper:seekNodeByName(UIStar.Widget, "image_pai3")
    local btn_back = ccui.Helper:seekNodeByName(UIStar.Widget , "btn_back")

    local function callBack1()
        -- cclog("111111111---------->")
        if net.InstPlayerHoldStar then
            for key, value in pairs(net.InstPlayerHoldStar) do
                --  cclog("111111111---------->"..value.int["3"].."  ".. key )
                if value.int["3"] == UIStarLighten.curChooseGrade then
                    UIStarLighten.setObj(value)
                    UIManager.showWidget("ui_star_lighten")
                    break
                end
            end
        end
    end
    local function errorCallBack1()
    end
    local function netSendData1()
        local sendData = {
            header = StaticMsgRule.selectHoldStarGrade,
            msgdata =
            {
                int =
                {
                    gradeId = UIStarLighten.curChooseGrade
                }
            }
        }
        netSendPackage(sendData, callBack1, errorCallBack1)
    end

    local function onEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == image_pai1 then
                UIStarLighten.setGradeId(1)
                netSendData1()
                -- UIManager.showWidget("ui_star_lighten")
            elseif sender == image_pai2 then
                UIStarLighten.setGradeId(2)
                netSendData1()
                -- UIManager.showWidget("ui_star_lighten")
            elseif sender == image_pai3 then
                UIStarLighten.setGradeId(3)
                netSendData1()
                -- UIManager.showWidget("ui_star_lighten")
            elseif sender == btn_back then
                UIMenu.onHomepage()
            end
        end
    end
    image_pai1:setTouchEnabled(true)
    image_pai1:addTouchEventListener(onEvent)
    image_pai2:setTouchEnabled(true)
    image_pai2:addTouchEventListener(onEvent)
    image_pai3:setTouchEnabled(true)
    image_pai3:addTouchEventListener(onEvent)

    btn_back:setPressedActionEnabled(true)
    btn_back:addTouchEventListener(onEvent)

    image_pai1:setLocalZOrder(1)
    image_pai2:setLocalZOrder(1)
    image_pai3:setLocalZOrder(1)
end
function UIStar.setup()
    if not net.InstPlayerHoldStar then
        UIManager.showLoading()
        netSendData()
    end
    local image_fight = ccui.Helper:seekNodeByName(UIStar.Widget, "image_fight")
    local image_gold = ccui.Helper:seekNodeByName(UIStar.Widget, "image_gold")
    local image_silver = ccui.Helper:seekNodeByName(UIStar.Widget, "image_silver")
    local image_pai1 = ccui.Helper:seekNodeByName(UIStar.Widget, "image_pai1")
    local image_pai2 = ccui.Helper:seekNodeByName(UIStar.Widget, "image_pai2")
    local image_pai3 = ccui.Helper:seekNodeByName(UIStar.Widget, "image_pai3")
    if net.InstPlayer then
        image_fight:getChildByName("label_fight"):setString(tostring(utils.getFightValue()))
        image_gold:getChildByName("text_gold_number"):setString(tostring(net.InstPlayer.int["5"]))
        image_silver:getChildByName("text_silver_number"):setString(net.InstPlayer.string["6"])

        local level = net.InstPlayer.int["4"]
        if level < DictHoldStarGrade["1"].openLevel then
            image_pai1:loadTexture("ui/star_suo.png")
            --    image_pai1:getChildByName("text_pai1"):setString(DictHoldStarGrade["1"].openLevel.."级开启")
            image_pai1:setTouchEnabled(false)
        else
            image_pai1:loadTexture("ui/star_pai1.png")
            --    image_pai1:getChildByName("text_pai1"):setString("碧落观星台")
            image_pai1:setTouchEnabled(true)
        end
        if level < DictHoldStarGrade["2"].openLevel then
            image_pai2:loadTexture("ui/star_suo.png")
            --   image_pai2:getChildByName("text_pai2"):setString(DictHoldStarGrade["2"].openLevel.."级开启")
            image_pai2:setTouchEnabled(false)
        else
            image_pai2:loadTexture("ui/star_pai2.png")
            --     image_pai2:getChildByName("text_pai2"):setString("紫霄观星台")
            image_pai2:setTouchEnabled(true)
        end
        if level < DictHoldStarGrade["3"].openLevel then
            image_pai3:loadTexture("ui/star_suo.png")
            --   image_pai3:getChildByName("text_pai3"):setString(DictHoldStarGrade["3"].openLevel.."级开启")
            image_pai3:setTouchEnabled(false)
        else
            image_pai3:loadTexture("ui/star_pai3.png")
            --  image_pai3:getChildByName("text_pai3"):setString("赤焰观星台")
            image_pai3:setTouchEnabled(true)
        end

        freshCurPai()
    end
end
function UIStar.free()

end

function UIStar.checkImageHint()
    local level = net.InstPlayer.int["4"]
    if level < DictHoldStarGrade["1"].openLevel then
        return false
    end
    local t = os.date("*t")
    t = string.format("%d-%02d-%02d", t.year, t.month, t.day)

    if net.InstPlayerHoldStar then
        for key, value in pairs(net.InstPlayerHoldStar) do
            if value.string["7"] ~= "" and string.sub(value.string["7"], 1, #t) == t then
                cc.UserDefault:getInstance():setStringForKey(string.gsub(net.InstPlayer.string["2"], "@", "_") .. "holdstar", t)
                return false
            end
            if value.string["10"] ~= "" and string.sub(value.string["10"], 1, #t) == t then
                cc.UserDefault:getInstance():setStringForKey(string.gsub(net.InstPlayer.string["2"], "@", "_") .. "holdstar", t)
                return false
            end
            if value.string["12"] ~= "" and string.sub(value.string["12"], 1, #t) == t then
                cc.UserDefault:getInstance():setStringForKey(string.gsub(net.InstPlayer.string["2"], "@", "_") .. "holdstar", t)
                return false
            end
        end
        return true
    else
        return cc.UserDefault:getInstance():getStringForKey(string.gsub(net.InstPlayer.string["2"], "@", "_") .. "holdstar") ~= t
    end
end