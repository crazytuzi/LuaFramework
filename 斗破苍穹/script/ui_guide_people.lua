require"Lang"
require "DictGuipStep"

UIGuidePeople = {
    widgetPeople = nil,
    widgetNode = nil,
    -- moveX        = 0,
}
local isSquare = nil -- 引导粒子是否采用矩形旋转
local isTest = false
UIGuidePeople.ObjTag = {
    layer = 999,
    dialog = 998,
    Particle1 = 100,
    Particle2 = 101,
    colorLayer = 102,
    finger = 103,
    listenerLayer = 104,
}
UIGuidePeople.flag = {
    normal = 0,
    accident = 1,
    taskInfo = 2,
} -- 1 为战斗意外获得 2 为战斗结束剧情
UIGuidePeople.callUpdate = nil
UIGuidePeople.guideFlag = nil
UIGuidePeople.guideStep = nil;
UIGuidePeople.levelStep = nil
UIGuidePeople.newBarrier = nil
UIGuidePeople.param = nil
UIGuidePeople.isSuccess = true
-- UIGuidePeople.currentFlag = nil  --1代表当前是副本引导，2代表当前是等级引导
-- xzli todo ui_homepage change
local handle = nil
local haveAdd = nil
----此方法是为了战斗后升级给levelStep赋值
function UIGuidePeople.AFSLevelGuide()
    cclog( "1111 :" , _level , "  " , utils.beforeLevel , "   " ,UIGuidePeople.levelStep )
    if utils.LevelUpgrade == true and net.InstPlayer.string["29"] ~= "f&f" and net.InstPlayer.string["14"] ~= "f&f" then
        if net.InstPlayer.int["4"] == guideInfo.tibuGuideLevel then
            UIGuidePeople.levelStep = guideInfo["7_1"].step
        elseif net.InstPlayer.int["4"] == guideInfo.jingjieGuideLevel then
            UIGuidePeople.levelStep = guideInfo["8_1"].step
        elseif net.InstPlayer.int["4"] == guideInfo.lineupGuideLevel then
            UIGuidePeople.levelStep = guideInfo["10_1"].step
        elseif net.InstPlayer.int["4"] == guideInfo.eliteGuideLevel then
            UIGuidePeople.levelStep = guideInfo["14_1"].step
        elseif net.InstPlayer.int["4"] == guideInfo.duelGuideLevel then
            UIGuidePeople.levelStep = guideInfo["11_1"].step
        elseif net.InstPlayer.int["4"] == guideInfo.resolveGuideLevel then
            UIGuidePeople.levelStep = guideInfo["12_1"].step
        elseif net.InstPlayer.int["4"] == guideInfo.constellGuideLevel then
            UIGuidePeople.levelStep = guideInfo["18_1"].step
        elseif net.InstPlayer.int["4"] == guideInfo.xiulianGuideLevel then
            UIGuidePeople.levelStep = guideInfo["20_1"].step
        elseif net.InstPlayer.int["4"] == guideInfo.yuanfenGuideLevel then
            UIGuidePeople.levelStep = guideInfo["26_1"].step
        elseif net.InstPlayer.int["4"] == guideInfo.xilianGuideLevel then
            UIGuidePeople.levelStep = guideInfo["28_1"].step
        elseif net.InstPlayer.int["4"] == guideInfo.xiangqianGuideLevel then
            UIGuidePeople.levelStep = guideInfo["16_1"].step
        elseif net.InstPlayer.int["4"] == guideInfo.lianqitaGuideLevel then
            UIGuidePeople.levelStep = guideInfo["28_1"].step
        elseif net.InstPlayer.int["4"] == guideInfo.dantaGuideLevel then
            UIGuidePeople.levelStep = guideInfo["32_1"].step
        elseif net.InstPlayer.int["4"] == guideInfo.mineGuideLevel then
            UIGuidePeople.levelStep = guideInfo["22_1"].step
        elseif net.InstPlayer.int["4"] == DictEnchantment["1"].needLevel then
            UIGuidePeople.levelStep = guideInfo["60_1"].step
        elseif net.InstPlayer.int["4"] == DictFunctionOpen[ tostring( StaticFunctionOpen.partner ) ].level then
            UIGuidePeople.levelStep = guideInfo["50_1"].step
        end
    else
        UIGuidePeople.levelStep = nil
    end
    if UIGuidePeople.levelStep then
        UIGuidePeople.sendGuideData(UIGuidePeople.levelStep, 2)
    end
end
-----这里触发等级引导------
function UIGuidePeople.levelGuideTrigger()
    print( _level , "  " , utils.beforeLevel , "   " ,UIGuidePeople.levelStep )
    if utils.LevelUpgrade == true or UIFightClearing.LevelUpgrade == true and net.InstPlayer.string["29"] ~= "f&f" and net.InstPlayer.string["14"] ~= "f&f" then
        local _level = net.InstPlayer.int["4"]
        if _level >= guideInfo.tibuGuideLevel and utils.beforeLevel < guideInfo.tibuGuideLevel then
            UIGuidePeople.levelStep = guideInfo["7_1"].step
        elseif _level >= guideInfo.jingjieGuideLevel and utils.beforeLevel < guideInfo.jingjieGuideLevel then
            UIGuidePeople.levelStep = guideInfo["8_1"].step
        elseif _level >= guideInfo.xiulianGuideLevel and utils.beforeLevel < guideInfo.xiulianGuideLevel then
            UIGuidePeople.levelStep = guideInfo["20_1"].step
        elseif _level >= guideInfo.lineupGuideLevel and utils.beforeLevel < guideInfo.lineupGuideLevel then
            UIGuidePeople.levelStep = guideInfo["10_1"].step
        elseif _level >= guideInfo.duelGuideLevel and utils.beforeLevel < guideInfo.duelGuideLevel then
            UIGuidePeople.levelStep = guideInfo["11_1"].step
        elseif _level >= guideInfo.resolveGuideLevel and utils.beforeLevel < guideInfo.resolveGuideLevel then
            UIGuidePeople.levelStep = guideInfo["12_1"].step
        elseif _level >= guideInfo.eliteGuideLevel and utils.beforeLevel < guideInfo.eliteGuideLevel then
            UIGuidePeople.levelStep = guideInfo["14_1"].step
        elseif _level >= guideInfo.constellGuideLevel and utils.beforeLevel < guideInfo.constellGuideLevel then
            UIGuidePeople.levelStep = guideInfo["18_1"].step
        elseif _level >= guideInfo.yuanfenGuideLevel and utils.beforeLevel < guideInfo.yuanfenGuideLevel then
            UIGuidePeople.levelStep = guideInfo["26_1"].step
            -- elseif _level >= guideInfo.xilianGuideLevel and utils.beforeLevel < guideInfo.xilianGuideLevel then
            --   UIGuidePeople.levelStep = guideInfo["28_1"].step
        elseif _level >= guideInfo.xiangqianGuideLevel and utils.beforeLevel < guideInfo.xiangqianGuideLevel then
            UIGuidePeople.levelStep = guideInfo["16_1"].step
        elseif _level >= guideInfo.lianqitaGuideLevel and utils.beforeLevel < guideInfo.lianqitaGuideLevel then
            UIGuidePeople.levelStep = guideInfo["28_1"].step
        elseif _level >= guideInfo.dantaGuideLevel and utils.beforeLevel < guideInfo.dantaGuideLevel then
            UIGuidePeople.levelStep = guideInfo["32_1"].step
        elseif _level >= guideInfo.mineGuideLevel and utils.beforeLevel < guideInfo.mineGuideLevel then
            UIGuidePeople.levelStep = guideInfo["22_1"].step
        elseif _level >= DictEnchantment["1"].needLevel and utils.beforeLevel < DictEnchantment["1"].needLevel then
            UIGuidePeople.levelStep = guideInfo["60_1"].step
        elseif _level >= DictFunctionOpen[ tostring( StaticFunctionOpen.partner ) ].level and utils.beforeLevel < DictFunctionOpen[ tostring( StaticFunctionOpen.partner ) ].level then
            UIGuidePeople.levelStep = guideInfo["50_1"].step
        end
    else
        UIGuidePeople.levelStep = nil
    end
    if UIGuidePeople.levelStep then
        UIGuidePeople.sendGuideData(UIGuidePeople.levelStep, 2)
        UIGuidePeople.checkLevelGuide()
    end
end

-----这里触发关卡引导---------------
function UIGuidePeople.checkTaskGuide()
    local barrierId = UIGuidePeople.param
    -- UIGuidePeople.newBarrier   =true
    if barrierId and UIGuidePeople.guideStep and UIGuidePeople.newBarrier then
        if barrierId == 2 then
            local function guide()
                local image_basemap = ccui.Helper:seekNodeByName(UIFightTask.Widget, "image_basemap")
                UIGuidePeople.addGuideUI(UIFightTask, image_basemap:getChildByName("box1"))
            end
            UIFightTask.Widget:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(guide)))
        elseif barrierId == 4 or barrierId == 5 or barrierId == 7 or barrierId == 18 or barrierId == 20 or barrierId == 25 or barrierId == DictFunctionOpen[tostring(StaticFunctionOpen.fight)].level then--斗魂引导
            UIManager.pushScene("ui_guide_system")
        elseif barrierId == 8 then
            UIGuidePeople.addGuideUI(UIFightTask, ccui.Helper:seekNodeByName(UIFightTask.Widget, "image_box_special"), guideInfo["8B1"].step)
        elseif barrierId == 15 then
            UIGuidePeople.addGuideUI(UIFightTask, ccui.Helper:seekNodeByName(UIFightTask.Widget, "image_box_special"), guideInfo["15B1"].step)
        else
            -- UIBeautyInfo.checkNewBeauty(barrierId)              ---检测美人开启--
            UIManager.flushWidget(UIFightTask)
            --- 检测下一关卡开启--
        end
    elseif UIGuidePeople.levelStep then
        UIGuidePeople.checkLevelGuide()
    elseif not UIFightWin.pushMiteerHint() and UIGuidePeople.newBarrier then
        --- 检测米特尔开启
        local isnew = UIGuideFight.checkNewChapter(barrierId)
        --- 检测新章节开启
        if not isnew then
            -- UIBeautyInfo.checkNewBeauty(barrierId)              ---检测美人开启--
            UIManager.flushWidget(UIFightTask)
            --- 检测下一关卡开启--
        end
    end
    UIGuidePeople.newBarrier = nil
end

function UIGuidePeople.checkLevelGuide()
    if UIGuidePeople.levelStep then
        if UIGuideSystem.Widget and UIGuideSystem.Widget:getParent() then
            return
        end
        UIManager.pushScene("ui_guide_system")
    end
end

function UIGuidePeople.sendGuideData(_guidStep, flag)
    if flag == 1 then
        UIGuidePeople.guideStep = _guidStep
    else
        UIGuidePeople.levelStep = _guidStep
    end
    if _guidStep == "2B4" or _guidStep == "2B10" or
        _guidStep == "4B5" or _guidStep == "5B4" or
        _guidStep == "5B9" or _guidStep == "6B7" or
        _guidStep == "7B4" or _guidStep == "8B3" or
        _guidStep == "7_3" or _guidStep == "7_7" or
        _guidStep == "8_5" or _guidStep == "12_4" or
        _guidStep == "16_4" or _guidStep == "20_5" or
        _guidStep == "20_6" or _guidStep == "20_8" or
        _guidStep == "18_6" then
        return
    end
    local data = {
        header = StaticMsgRule.guidStep,
        msgdata =
        {
            string =
            {
                step = _guidStep,
            }
        }
    }
    local function handle(package)
        UIManager.hideLoading()
        local code = tonumber(package.header)
        if code == StaticMsgRule.guidStep then
            UIGuidePeople.isSuccess = true
        end
    end
    if UIGuidePeople.isImportantStep(_guidStep, flag) then
        UIGuidePeople.isSuccess = false
        UIManager.showLoading()
        netSendPackage(data, handle)
    else
        UIGuidePeople.isSuccess = true
        netSendPackage(data)
    end
end

function UIGuidePeople.isImportantStep(_guidStep, flag)
    local LevelOrBarrierId = 0
    local step = 0
    local type = 0
    if flag == 1 then
        local str = utils.stringSplit(_guidStep, "B")
        LevelOrBarrierId = tonumber(str[1])
        step = tonumber(str[2])
        type = 2
    else
        local str = utils.stringSplit(_guidStep, "_")
        LevelOrBarrierId = tonumber(str[1])
        step = tonumber(str[2])
        type = 1
    end
    local tag = false
    for key, obj in pairs(DictGuipStep) do
        if obj.type == type and obj.LevelOrBarrierId == LevelOrBarrierId and obj.step == step then
            tag = true
            break
        end
    end
    return tag
end

local function cleanTaskStep()
    if UIGuidePeople.guideStep == guideInfo["15B6"].step or
        UIGuidePeople.guideStep == guideInfo["18B10"].step or
        UIGuidePeople.guideStep == guideInfo["25B7"].step or
        UIGuidePeople.guideStep == guideInfo["45B7"].step or
        UIGuidePeople.guideStep == guideInfo["20B5"].step then    
        if UIGuidePeople.guideStep == guideInfo["45B7"].step then
             UIGuidePeople.guideStep = nil
             if UIGuidePeople.levelStep then
                UIGuidePeople.nextCheckLevelGuide = UIGuidePeople.levelStep
               -- cclog( "UIGuidePeople.nextCheckLevelGuide : %s" , UIGuidePeople.nextCheckLevelGuide )
                UIGuidePeople.levelStep = nil
              --  cclog( "UIGuidePeople.nextCheckLevelGuide1111 : %s" , UIGuidePeople.nextCheckLevelGuide )
             end
        else
             UIGuidePeople.guideStep = nil
            UIGuidePeople.checkLevelGuide()
        end
    end
end

local function cleanLevelStep()
    if UIGuidePeople.levelStep == guideInfo["7_8"].step or
        UIGuidePeople.levelStep == guideInfo["8_5"].step or
        UIGuidePeople.levelStep == guideInfo["10_10"].step or
        UIGuidePeople.levelStep == guideInfo["14_2"].step or
        UIGuidePeople.levelStep == guideInfo["11_1"].step or
        UIGuidePeople.levelStep == guideInfo["12_7"].step or
        UIGuidePeople.levelStep == guideInfo["18_6"].step or
        UIGuidePeople.levelStep == guideInfo["20_8"].step or
        UIGuidePeople.levelStep == guideInfo["26_3"].step or
        UIGuidePeople.levelStep == guideInfo["16_5"].step or
        UIGuidePeople.levelStep == guideInfo["28_1"].step or
        UIGuidePeople.levelStep == guideInfo["32_1"].step or
        UIGuidePeople.levelStep == guideInfo["22_3"].step or 
        UIGuidePeople.levelStep == guideInfo["60_1"].step or 
        UIGuidePeople.levelStep == guideInfo["50_1"].step then
            UIGuidePeople.levelStep = nil
            utils.LevelUpgrade = false

    end
end
local function cleanGuideStep()
    if UIGuidePeople.guideStep then
        cleanTaskStep()
    else
        cleanLevelStep()
    end
end
----判断等级引导----
local function isLevelStep(data, uiItem)
    if UIGuidePeople.levelStep then
        if haveAdd then
            return
        end
        if UIGuidePeople.levelStep and uiItem then
            cclog("当前" .. WidgetManager.getWidgetName(uiItem) .. "等级引导步数=" .. UIGuidePeople.levelStep)
        end
        local _level = net.InstPlayer.int["4"]
        if _level >= guideInfo.tibuGuideLevel and utils.beforeLevel < guideInfo.tibuGuideLevel then
            if UIGuidePeople.levelStep == guideInfo["7_1"].step then
                if type(data) == "userdata" and uiItem == UIBagCard then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            elseif UIGuidePeople.levelStep == guideInfo["7_2"].step then
                if type(data) == "userdata" and uiItem == UIBagCard then
                    UIGuidePeople.addGuideUI(UIMenu, data)
                end
            elseif UIGuidePeople.levelStep == guideInfo["7_3"].step then
                if type(data) == "table" and uiItem == UILineup then
                    if data[1] == 2 then
                        UILineup.guideEvent = data[2]
                    elseif data[1] == 4 then
                        UIGuidePeople.addGuideUI(UILineup, data[2])
                    end
                end
            elseif UIGuidePeople.levelStep == guideInfo["7_4"].step then
                if data[1] == 3 and uiItem == UILineup then
                    UIGuidePeople.addGuideUI(UILineup, data[2])
                end
            elseif UIGuidePeople.levelStep == guideInfo["7_5"].step then
                if type(data) == "userdata" and uiItem == UICardChange then
                    UIGuidePeople.addGuideUI(UICardChange, data)
                end
            elseif UIGuidePeople.levelStep == guideInfo["7_6"].step then
                if not data and uiItem == UICardChange then
                    -- UIGuidePeople.addGuideUI(UIMenu, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_property"))
                    UIManager.showScreen("ui_notice","ui_team_info","ui_homepage","ui_menu")
                    HomePageController:scrollToPageNow(0)
                    UIGuidePeople.addGuideUI(UIHomePage , ccui.Helper:seekNodeByName(UIHomePage.Widget,"panel_fuben"))
                end
            elseif UIGuidePeople.levelStep == guideInfo["7_7"].step then
                if type(data) == "userdata" and uiItem == UIFight then
                    UIGuidePeople.addGuideUI(UIFight, data)
                end
            end
        elseif _level >= guideInfo.jingjieGuideLevel and utils.beforeLevel < guideInfo.jingjieGuideLevel then
            if UIGuidePeople.levelStep == guideInfo["8_1"].step then
                if type(data) == "table" and uiItem == UILineup then
                    if data[1] == 5 and UILineup.reset == nil then
                        UIGuidePeople.addGuideUI(UILineup, data[2])
                    elseif data[1] == 3 and UILineup.reset ~= nil then
                        UIGuidePeople.addGuideUI(UILineup, data[2])
                    elseif data[1] == 2 then
                        UILineup.guideEvent = data[2]
                    end
                elseif type(data) == "function" and uiItem == UILineup then
                    data()
                end
            elseif UIGuidePeople.levelStep == guideInfo["8_2"].step then
                if data == nil and uiItem == UICardInfo then
                    UIGuidePeople.addGuideUI(UICardInfo, ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_realm"))
                end
            elseif UIGuidePeople.levelStep == guideInfo["8_3"].step then
                if data == nil and uiItem == UICardJingJie then
                    UIGuidePeople.addGuideUI(uiItem, ccui.Helper:seekNodeByName(UICardJingJie.Widget, "btn_break"))
                end
            elseif UIGuidePeople.levelStep == guideInfo["8_4"].step then
                if data == nil and uiItem == UICardJingJie then
                    UIGuidePeople.addGuideUI(uiItem, ccui.Helper:seekNodeByName(UICardJingJie.Widget, "btn_close"))
                end
            end
        elseif _level >= guideInfo.lineupGuideLevel and utils.beforeLevel < guideInfo.lineupGuideLevel then
            if UIGuidePeople.levelStep == guideInfo["10_1"].step then
                if type(data) == "userdata" and uiItem == UIHomePage then
                    UIGuidePeople.addGuideUI(UIHomePage, data)
                end
            elseif UIGuidePeople.levelStep == guideInfo["10_2"].step then
                if type(data) == "userdata" and uiItem == UIAwardGift then
                    UIGuidePeople.addGuideUI(UIAwardGift, data)
                end
            elseif UIGuidePeople.levelStep == guideInfo["10_3"].step then
                if uiItem == UIAwardGet then
                    UIGuidePeople.addGuideUI(UIAwardGet, data)
                end
            elseif UIGuidePeople.levelStep == guideInfo["10_4"].step then
                if data == nil and uiItem == UIAwardGet then
                    UIGuidePeople.addGuideUI(UIAwardGift, ccui.Helper:seekNodeByName(UIAwardGift.Widget, "btn_close"))
                end
            elseif UIGuidePeople.levelStep == guideInfo["10_5"].step then
                if data == nil and uiItem == UIAwardGift then
                    UIGuidePeople.addGuideUI(UIMenu, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_troops"))
                end
            elseif UIGuidePeople.levelStep == guideInfo["10_6"].step then
                if type(data) == "table" and uiItem == UILineup then
                    if data[1] == 2 then
                        UILineup.guideEvent = data[2]
                    elseif data[1] == 4 then
                        UIGuidePeople.addGuideUI(UILineup, data[2])
                    end
                end
            elseif UIGuidePeople.levelStep == guideInfo["10_7"].step then
                if type(data) == "table" and uiItem == UILineup then
                    if data[1] == 3 then
                        UIGuidePeople.addGuideUI(UILineup, data[2])
                    end
                end
            elseif UIGuidePeople.levelStep == guideInfo["10_8"].step then
                if type(data) == "userdata" and uiItem == UICardChange then
                    UIGuidePeople.addGuideUI(UICardChange, data)
                end
            elseif UIGuidePeople.levelStep == guideInfo["10_9"].step then
                if data == nil and uiItem == UICardChange then
                    UIGuidePeople.addGuideUI(UILineup, ccui.Helper:seekNodeByName(UILineup.Widget, "btn_recommend"))
                end
            end
        elseif _level >= guideInfo.eliteGuideLevel and utils.beforeLevel < guideInfo.eliteGuideLevel then
            if UIGuidePeople.levelStep == guideInfo["14_1"].step then
                if type(data) == "userdata" and uiItem == UIFight then
                    UIGuidePeople.addGuideUI(UIFight, data, guideInfo["14_1"].step)
                elseif not data and uiItem == UIFightPreView then
                    UIGuidePeople.addGuideUI(UIFightPreView, ccui.Helper:seekNodeByName(UIFightPreView.Widget, "btn_fight"))
                elseif uiItem == UIFightTask then
                    UIGuidePeople.checkLevelGuide()
                end
            end
        elseif _level >= guideInfo.duelGuideLevel and utils.beforeLevel < guideInfo.duelGuideLevel then
            if UIGuidePeople.levelStep == guideInfo["11_1"].step then
                if type(data) == "userdata" and uiItem == UIHomePage then
                    UIGuidePeople.addGuideUI(UIHomePage, data , guideInfo["11_1"].step )
                elseif uiItem == UIFightTask then
                    UIGuidePeople.checkLevelGuide()
                end
            end
        elseif _level >= guideInfo.resolveGuideLevel and utils.beforeLevel < guideInfo.resolveGuideLevel then
            if UIGuidePeople.levelStep == guideInfo["12_1"].step then
                if not data and uiItem == UIResolve then
                    UIGuidePeople.addGuideUI(uiItem, ccui.Helper:seekNodeByName(UIResolve.Widget, "btn_card"))
                end
            elseif UIGuidePeople.levelStep == guideInfo["12_2"].step then
                if not data and uiItem == UIResolve then
                    UIGuidePeople.addGuideUI(uiItem, ccui.Helper:seekNodeByName(UIResolve.Widget, "image_base_tab"):getChildByName("btn_resolve"))
                end
            elseif UIGuidePeople.levelStep == guideInfo["12_3"].step then
                if type(data) == "userdata" and uiItem == UIResolve then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            elseif UIGuidePeople.levelStep == guideInfo["12_4"].step then
                if not data and uiItem == UIMenu then
                    UIGuidePeople.addGuideUI(uiItem, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_home"))
                end
            elseif UIGuidePeople.levelStep == guideInfo["12_5"].step then
                if not data and uiItem == UIHomePage then
                    UIGuidePeople.addGuideUI(UIHomePage, ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_activity"))
                end
            elseif UIGuidePeople.levelStep == guideInfo["12_6"].step then
                if type(data) == "userdata" and uiItem == UIActivityPanel then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            end
        elseif _level >= guideInfo.constellGuideLevel and utils.beforeLevel < guideInfo.constellGuideLevel then
            if UIGuidePeople.levelStep == guideInfo["18_1"].step then
                if type(data) == "table" and uiItem == UILineup then
                    if data[1] == 5 and UILineup.reset == nil then
                        UIGuidePeople.addGuideUI(UILineup, data[2])
                    elseif data[1] == 3 and UILineup.reset ~= nil then
                        UIGuidePeople.addGuideUI(UILineup, data[2])
                    elseif data[1] == 2 then
                        UILineup.guideEvent = data[2]
                    end
                elseif type(data) == "function" and uiItem == UILineup then
                    data()
                end
            elseif UIGuidePeople.levelStep == guideInfo["18_2"].step then
                if data == nil and uiItem == UICardInfo then
                    UIGuidePeople.addGuideUI(UICardInfo, ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_medicine"))
                end
            elseif UIGuidePeople.levelStep == guideInfo["18_3"].step then
                if type(data) == "userdata" and uiItem == UIMedicine then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            elseif UIGuidePeople.levelStep == guideInfo["18_4"].step then
                if not data and uiItem == UIMedicineAlchemy then
                    UIGuidePeople.addGuideUI(uiItem, ccui.Helper:seekNodeByName(UIMedicineAlchemy.Widget, "btn_alchemy"))
                end
            elseif UIGuidePeople.levelStep == guideInfo["18_5"].step then
                if not data and uiItem == UIMedicineAlchemy then
                    UIGuidePeople.addGuideUI(uiItem, ccui.Helper:seekNodeByName(UIMedicineAlchemy.Widget, "btn_use"))
                end
            end
        elseif _level >= guideInfo.xiulianGuideLevel and utils.beforeLevel < guideInfo.xiulianGuideLevel then
            if UIGuidePeople.levelStep == guideInfo["20_1"].step then
                if type(data) == "table" and uiItem == UILineup then
                    if data[1] == 5 and UILineup.reset == nil then
                        UIGuidePeople.addGuideUI(UILineup, data[2])
                    elseif data[1] == 3 and UILineup.reset ~= nil then
                        UIGuidePeople.addGuideUI(UILineup, data[2])
                    elseif data[1] == 2 then
                        UILineup.guideEvent = data[2]
                    end
                elseif type(data) == "function" and uiItem == UILineup then
                    data()
                end
            elseif UIGuidePeople.levelStep == guideInfo["20_2"].step then
                if data == nil and uiItem == UICardInfo then
                    UIGuidePeople.addGuideUI(UICardInfo, ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_xiulian"))
                end
            elseif UIGuidePeople.levelStep == guideInfo["20_3"].step or UIGuidePeople.levelStep == guideInfo["20_4"].step then
                if not data and uiItem == UICardRealm then
                    UIGuidePeople.addGuideUI(uiItem, ccui.Helper:seekNodeByName(UICardRealm.Widget, "btn_practice"))
                end
            elseif UIGuidePeople.levelStep == guideInfo["20_5"].step then
                if not data and uiItem == UICardRealm then
                    UIGuidePeople.addGuideUI(uiItem, ccui.Helper:seekNodeByName(UICardRealm.Widget, "checkbox_practice_tianmu_ten"))
                end
            elseif UIGuidePeople.levelStep == guideInfo["20_6"].step or UIGuidePeople.levelStep == guideInfo["20_7"].step then
                if not data and uiItem == UICardRealm then
                    UIGuidePeople.addGuideUI(uiItem, ccui.Helper:seekNodeByName(UICardRealm.Widget, "btn_practice"))
                end
            elseif UIGuidePeople.levelStep == guideInfo["20_8"].step then
                if not data and uiItem == UICardRealm then
                    UIGuidePeople.addGuideUI(uiItem, ccui.Helper:seekNodeByName(UICardRealm.Widget, "btn_exit"))
                end
            end
        elseif _level >= 26 and utils.beforeLevel < 26 then
            if UIGuidePeople.levelStep == guideInfo["26_1"].step then
                if type(data) == "table" and uiItem == UILineup then
                    if data[1] == 2 then
                        UILineup.guideEvent = data[2]
                    elseif data[1] == 7 then
                        UIGuidePeople.addGuideUI(UILineup, data[2])
                    end
                end
            elseif UIGuidePeople.levelStep == guideInfo["26_2"].step then
                if type(data) == "table" and uiItem == UILineup then
                    if data[1] == 3 then
                        UIGuidePeople.addGuideUI(UILineup, data[2])
                    end
                end
            end
            --[[
    elseif _level >= guideInfo.xilianGuideLevel and utils.beforeLevel < guideInfo.xilianGuideLevel then
      if UIGuidePeople.levelStep == guideInfo["28_1"].step then
        if type(data)== "table"  and uiItem == UIBagEquipment  then
            UIGuidePeople.addGuideUI(uiItem,data[2])
        end
      elseif UIGuidePeople.levelStep == guideInfo["28_2"].step then
        if not data and uiItem == UIEquipmentClean  then
           local param = ccui.Helper:seekNodeByName(UIEquipmentClean.Widget, "btn_clean")
           UIGuidePeople.addGuideUI(uiItem,param)
        end
      end
  --]]
        elseif _level >= guideInfo.xiangqianGuideLevel and utils.beforeLevel < guideInfo.xiangqianGuideLevel then
            if UIGuidePeople.levelStep == guideInfo["16_1"].step then
                if type(data) == "table" and uiItem == UIBagEquipment then
                    UIGuidePeople.addGuideUI(uiItem, data[3])
                end
            elseif UIGuidePeople.levelStep == guideInfo["16_2"].step then
                if not data and uiItem == UIGemInlay then
                    local param = ccui.Helper:seekNodeByName(UIGemInlay.Widget, "image_inlay_gem1")
                    UIGuidePeople.addGuideUI(uiItem, param:getChildByName("btn_punch"))
                end
            elseif UIGuidePeople.levelStep == guideInfo["16_3"].step then
                if not data and uiItem == UIGemInlay then
                    local param = ccui.Helper:seekNodeByName(UIGemInlay.Widget, "image_inlay_gem1")
                    UIGuidePeople.addGuideUI(uiItem, param:getChildByName("btn_punch"))
                end
            elseif UIGuidePeople.levelStep == guideInfo["16_4"].step then
                if type(data) == "userdata" and uiItem == UIGemList then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            end
        elseif _level >= guideInfo.lianqitaGuideLevel and utils.beforeLevel < guideInfo.lianqitaGuideLevel then
            if UIGuidePeople.levelStep == guideInfo["28_1"].step then
                if type(data) == "userdata" and uiItem == UIHomePage then
                    UIGuidePeople.addGuideUI(UIHomePage, data , guideInfo["28_1"].step)
                end
            end
        elseif _level >= guideInfo.dantaGuideLevel and utils.beforeLevel < guideInfo.dantaGuideLevel then
            if UIGuidePeople.levelStep == guideInfo["32_1"].step then
                if type(data) == "userdata" and uiItem == UIHomePage then
                    UIGuidePeople.addGuideUI(UIHomePage, data, guideInfo["32_1"].step)
                end
            end
        elseif _level >= guideInfo.mineGuideLevel and utils.beforeLevel < guideInfo.mineGuideLevel then
            if UIGuidePeople.levelStep == guideInfo["22_1"].step then
                if type(data) == "userdata" and uiItem == UIHomePage then
                    UIGuidePeople.addGuideUI(UIHomePage, data)
                end
            elseif UIGuidePeople.levelStep == guideInfo["22_2"].step then
                if data == nil and uiItem == UIOre then
                    local function formatTime(countdown)
                        return string.format("%02d:%02d", math.floor(countdown / 3600), math.floor(countdown / 60) % 60)
                    end
                    local startTime = formatTime(UIOre.activityTimes[1])
                    local endTime = formatTime(UIOre.activityTimes[2])
                    local startTime2 = formatTime(UIOre.activityTimes[3])
                    local endTime2 = formatTime(UIOre.activityTimes[4])
                    guideInfo["22_3"].Info.text = string.format(guideInfo["22_3"].Info.text, startTime, endTime, startTime2, endTime2)
                    UIGuidePeople.addGuideUI(UIOre)
                end
            end
        end
    end
end

----判断关卡引导----
function UIGuidePeople.isGuide(data, uiItem)
    if UIGuidePeople.guideStep then
        if haveAdd then
            return
        end
        if UIGuidePeople.guideStep and uiItem then
            cclog("当前" .. WidgetManager.getWidgetName(uiItem) .. "关卡引导步数=" .. UIGuidePeople.guideStep)
        end
        if UIGuidePeople.param == 1 then
            if UIGuidePeople.guideStep == guideInfo["1B1"].step then
                -- if uiItem == UIBeautyInfo then
                --   UIGuidePeople.addGuideUI(UIBeautyInfo,ccui.Helper:seekNodeByName(UIBeautyInfo.Widget, "btn_go"),guideInfo["1B1"].step)
                -- elseif uiItem == UIHomePage then
                --   UIGuidePeople.addGuideUI(UIHomePage,ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_beruty"))
                -- end
                -- elseif (uiItem == UIBeauty and UIGuidePeople.guideStep == guideInfo["1B2"].step) then
                --   if type(data)== "userdata" then
                --     UIGuidePeople.addGuideUI(UIBeauty,data)
                --   end
                -- elseif (uiItem == UIBeauty and UIGuidePeople.guideStep == guideInfo["1B3"].step) then
                --   if type(data)== "userdata" then
                --     UIGuidePeople.addGuideUI(UIBeauty,data)
                --   end
                -- elseif UIGuidePeople.guideStep == guideInfo["1B4"].step then
                --   if type(data) == "userdata" and uiItem == UIBeauty  then
                --     UIGuidePeople.addGuideUI(uiItem,data)
                --   end
                -- elseif UIGuidePeople.guideStep == guideInfo["1B5"].step then
                if uiItem == UIFightTask then
                    UIGuidePeople.addGuideUI(UIFightTask, data, 0)
                end
            end
        elseif UIGuidePeople.param == 2 then
            if UIGuidePeople.guideStep == guideInfo["2B1"].step then
                -- if uiItem == UIBeautyInfo then
                --   UIGuidePeople.addGuideUI(UIBeautyInfo,ccui.Helper:seekNodeByName(UIBeautyInfo.Widget, "btn_close"),guideInfo["2B1"].step)
                -- end
            elseif UIGuidePeople.guideStep == guideInfo["2B2"].step then
                if type(data) == "userdata" and uiItem == UIAwardGet then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["2B3"].step then
                if type(data) == "userdata" and uiItem == UIAwardGet then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["2B4"].step then
                if uiItem == UIAwardGet then
                    UIGuidePeople.addGuideUI(UIFightTask, ccui.Helper:seekNodeByName(UIFightTask.Widget, "btn_back"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["2B5"].step then
                if not data and uiItem == UIMenu then
                    UIGuidePeople.addGuideUI(UIMenu, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_troops"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["2B6"].step then
                --- 添加卡牌
                if type(data) == "table" and uiItem == UILineup then
                    if data[1] == 2 then
                        UILineup.guideEvent = data[2]
                    elseif data[1] == 4 then
                        UIGuidePeople.addGuideUI(UILineup, data[2])
                    end
                end
            elseif UIGuidePeople.guideStep == guideInfo["2B7"].step then
                if type(data) == "table" and uiItem == UILineup then
                    if data[1] == 3 then
                        UIGuidePeople.addGuideUI(uiItem, data[2])
                    end
                end
            elseif UIGuidePeople.guideStep == guideInfo["2B8"].step then
                if type(data) == "userdata" and uiItem == UICardChange then
                    UIGuidePeople.addGuideUI(UICardChange, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["2B9"].step then
                if uiItem == UICardChange then
                    UIManager.showScreen("ui_notice","ui_team_info","ui_homepage","ui_menu")
                    HomePageController:scrollToPageNow(0)
                    UIGuidePeople.addGuideUI(UIHomePage , ccui.Helper:seekNodeByName(UIHomePage.Widget,"panel_fuben"))
                    -- UIGuidePeople.addGuideUI(UIMenu, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_property"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["2B10"].step then
                if type(data) == "userdata" and uiItem == UIFight then
                    UIGuidePeople.addGuideUI(UIFight, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["2B11"].step then
                if uiItem == UIFightTask then
                    UIGuidePeople.addGuideUI(UIFightTask, data)
                end
            end
        elseif UIGuidePeople.param == 3 then
            if UIGuidePeople.guideStep == guideInfo["3B1"].step then
                if uiItem == UIFightTask then
                    UIGuidePeople.addGuideUI(UIFightTask, data, guideInfo["3B1"].step)
                end
            end
        elseif UIGuidePeople.param == 4 then
            if UIGuidePeople.guideStep == guideInfo["4B1"].step then
                if type(data) == "table" and uiItem == UILineup then
                    if data[1] == 5 and UILineup.reset == nil then
                        UIGuidePeople.addGuideUI(UILineup, data[2])
                    elseif data[1] == 3 and UILineup.reset ~= nil then
                        UIGuidePeople.addGuideUI(UILineup, data[2])
                    elseif data[1] == 2 then
                        UILineup.guideEvent = data[2]
                    end
                elseif type(data) == "function" and uiItem == UILineup then
                    data()
                end
            elseif UIGuidePeople.guideStep == guideInfo["4B2"].step then
                if data == nil and uiItem == UICardInfo then
                    UIGuidePeople.addGuideUI(UICardInfo, ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_advance"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["4B3"].step then
                if data == nil and uiItem == UICardAdvance then
                    UIGuidePeople.addGuideUI(UICardAdvance, ccui.Helper:seekNodeByName(UICardAdvance.Widget, "btn_break"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["4B4"].step then
                if data == nil and uiItem == UICardAdvance then
                    UIGuidePeople.addGuideUI(UICardAdvance, ccui.Helper:seekNodeByName(UICardAdvance.Widget, "btn_close"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["4B5"].step then
                if data == nil and uiItem == UICardAdvance then
                    UIGuidePeople.addGuideUI(UICardInfo, ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_close"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["4B6"].step then
                if data == nil and uiItem == UICardInfo then
                    -- UIGuidePeople.addGuideUI(UIMenu, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_property"))
                    UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
                    HomePageController:scrollToPageNow(0)
                    UIGuidePeople.addGuideUI(UIHomePage , ccui.Helper:seekNodeByName(UIHomePage.Widget,"panel_fuben"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["4B7"].step then
                if type(data) == "userdata" and uiItem == UIFight then
                    UIGuidePeople.addGuideUI(UIFight, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["4B8"].step then
                if uiItem == UIFightTask then
                    UIGuidePeople.addGuideUI(UIFightTask, data)
                end
            end
        elseif UIGuidePeople.param == 5 then
            if UIGuidePeople.guideStep == guideInfo["5B1"].step then
                if type(data) == "userdata" and uiItem == UIShop then
                    UIGuidePeople.addGuideUI(UIShop, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["5B2"].step then
                if data == nil and uiItem == UIShopRecruitJewel then
                    local ui_image_one = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "image_di_one")
                    UIGuidePeople.addGuideUI(UIShopRecruitJewel, ui_image_one:getChildByName("btn_recruit"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["5B3"].step then
                if data == nil and uiItem == UIShopRecruitTen then
                    UIGuidePeople.addGuideUI(UIShopRecruitTen, ccui.Helper:seekNodeByName(UIShopRecruitTen.Widget, "btn_exit"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["5B4"].step then
                if data == nil and uiItem == UIShopRecruitTen then
                    local dictData = DictLevelProp[tostring(net.InstPlayer.int["4"])]
                    local countItem = dictData.inTeamCard + dictData.benchCard
                    local number = 0
                    for key, obj in pairs(net.InstPlayerFormation) do
                        if obj.int["4"] == 1 or obj.int["4"] == 2 then
                            number = number + 1
                        end
                    end
                    if countItem > number then
                        UIGuidePeople.addGuideUI(UIMenu, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_troops"))
                    else
                        UIGuidePeople.guideStep = nil
                    end
                end
            elseif UIGuidePeople.guideStep == guideInfo["5B5"].step then
                if type(data) == "table" and uiItem == UILineup then
                    if data[1] == 2 then
                        UILineup.guideEvent = data[2]
                    elseif data[1] == 4 then
                        UIGuidePeople.addGuideUI(UILineup, data[2])
                    end
                end
            elseif UIGuidePeople.guideStep == guideInfo["5B6"].step then
                if type(data) == "table" and uiItem == UILineup then
                    if data[1] == 3 then
                        UIGuidePeople.addGuideUI(UILineup, data[2])
                    end
                end
            elseif UIGuidePeople.guideStep == guideInfo["5B7"].step then
                if type(data) == "userdata" and uiItem == UICardChange then
                    UIGuidePeople.addGuideUI(UICardChange, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["5B8"].step then
                if uiItem == UICardChange then
                    -- UIGuidePeople.addGuideUI(UIMenu, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_property"))
                    UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
                    HomePageController:scrollToPageNow(0)
                    UIGuidePeople.addGuideUI(UIHomePage , ccui.Helper:seekNodeByName(UIHomePage.Widget,"panel_fuben"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["5B9"].step then
                if type(data) == "userdata" and uiItem == UIFight then
                    UIGuidePeople.addGuideUI(UIFight, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["5B10"].step then
                if uiItem == UIFightTask then
                    UIGuidePeople.addGuideUI(UIFightTask, data)
                end
            end
        elseif UIGuidePeople.param == 6 then
            if UIGuidePeople.guideStep == guideInfo["6B1"].step then
                if uiItem == UIFightTask then
                    UIGuidePeople.addGuideUI(UIFightTask, ccui.Helper:seekNodeByName(UIFightTask.Widget, "btn_back"), guideInfo["6B1"].step)
                elseif uiItem == UIMenu then
                    UIGuidePeople.addGuideUI(uiItem, ccui.Helper:seekNodeByName(uiItem.Widget, "btn_troops"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["6B2"].step then
                if type(data) == "table" and uiItem == UILineup then
                    if data[1] == 5 and UILineup.reset == nil then
                        UIGuidePeople.addGuideUI(UILineup, data[2])
                    elseif data[1] == 3 and UILineup.reset ~= nil then
                        UIGuidePeople.addGuideUI(UILineup, data[2])
                    elseif data[1] == 2 then
                        UILineup.guideEvent = data[2]
                    end
                elseif type(data) == "function" and uiItem == UILineup then
                    data()
                end
            elseif UIGuidePeople.guideStep == guideInfo["6B3"].step then
                if not data and uiItem == UICardInfo then
                    UIGuidePeople.addGuideUI(UICardInfo, ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_upgrade"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["6B4"].step then
                if type(data) == "table" and uiItem == UICardUpgrade then
                    UIGuidePeople.addGuideUI(UICardUpgrade, data[1])
                end
            elseif UIGuidePeople.guideStep == guideInfo["6B5"].step then
                if type(data) == "userdata" and uiItem == UICardUpgrade then
                    UIGuidePeople.addGuideUI(UICardUpgrade, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["6B6"].step then
                if data == nil and uiItem == UICardUpgrade then
                    UIGuidePeople.addGuideUI(UICardUpgrade, ccui.Helper:seekNodeByName(UICardUpgrade.Widget, "btn_close"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["6B7"].step then
                if data == nil and uiItem == UICardUpgrade then
                    UIGuidePeople.addGuideUI(UICardInfo, ccui.Helper:seekNodeByName(UICardInfo.Widget, "btn_close"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["6B8"].step then
                if data == nil and uiItem == UICardInfo then
                    -- UIGuidePeople.addGuideUI(UIMenu, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_property"))
                    UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
                    HomePageController:scrollToPageNow(0)
                    UIGuidePeople.addGuideUI(UIHomePage , ccui.Helper:seekNodeByName(UIHomePage.Widget,"panel_fuben"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["6B9"].step then
                if type(data) == "userdata" and uiItem == UIFight then
                    UIGuidePeople.addGuideUI(UIFight, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["6B10"].step then
                if uiItem == UIFightTask then
                    UIGuidePeople.addGuideUI(UIFightTask, data)
                end
            end
        elseif UIGuidePeople.param == 7 then
            --- 等级礼包
            if UIGuidePeople.guideStep == guideInfo["7B1"].step then
                if type(data) == "userdata" and uiItem == UIHomePage then
                    UIGuidePeople.addGuideUI(UIHomePage, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["7B2"].step then
                if type(data) == "userdata" and uiItem == UIAwardGift then
                    UIGuidePeople.addGuideUI(UIAwardGift, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["7B3"].step then
                if uiItem == UIAwardGet then
                    UIGuidePeople.addGuideUI(UIAwardGet, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["7B4"].step then
                if data == nil and uiItem == UIAwardGet then
                    UIGuidePeople.addGuideUI(UIAwardGift, ccui.Helper:seekNodeByName(UIAwardGift.Widget, "btn_close"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["7B5"].step then
                if data == nil and uiItem == UIAwardGift then
                    -- UIGuidePeople.addGuideUI(UIMenu, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_property"))
                    UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
                    HomePageController:scrollToPageNow(0)
                    UIGuidePeople.addGuideUI(UIHomePage , ccui.Helper:seekNodeByName(UIHomePage.Widget,"panel_fuben"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["7B6"].step then
                if type(data) == "userdata" and uiItem == UIFight then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["7B7"].step then
                if uiItem == UIFightTask then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            end
        elseif UIGuidePeople.param == 8 then
            if UIGuidePeople.guideStep == guideInfo["8B1"].step then
                if type(data) == "userdata" and uiItem == UIFightTask then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["8B2"].step then
                if type(data) == "userdata" and uiItem == UIAwardGet then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["8B3"].step then
                if not data and uiItem == UIAwardGet then
                    UIGuideFight.checkNewChapter(8)
                elseif not data and uiItem == UIGuideFight then
                    UIGuidePeople.addGuideUI(uiItem, ccui.Helper:seekNodeByName(UIGuideFight.Widget, "image_system"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["8B4"].step then
                if uiItem == UIFightTask then
                    UIGuidePeople.addGuideUI(UIFightTask, data)
                end
            end
        elseif UIGuidePeople.param == 15 then
            if UIGuidePeople.guideStep == guideInfo["15B1"].step then
                if type(data) == "userdata" and uiItem == UIFightTask then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["15B2"].step then
                if type(data) == "userdata" and uiItem == UIAwardGet then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["15B3"].step then
                if not data and uiItem == UIAwardGet then
                    UIGuideFight.checkNewChapter(15)
                elseif not data and uiItem == UIGuideFight then
                    UIGuidePeople.addGuideUI(uiItem, ccui.Helper:seekNodeByName(UIGuideFight.Widget, "image_system"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["15B4"].step then
                if uiItem == UIFightTask then
                    UIGuidePeople.addGuideUI(UIFightTask, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["15B5"].step then
                if not data and uiItem == UIFightTaskChoose then
                    local btn_help = ccui.Helper:seekNodeByName(UIFightTaskChoose.Widget, "btn_help")
                    UIGuidePeople.addGuideUI(UIFightTaskChoose, btn_help)
                end
            end
        elseif UIGuidePeople.param == 18 then
            if UIGuidePeople.guideStep == guideInfo["18B1"].step then
                if type(data) == "userdata" and uiItem == UILineup then
                    UIGuidePeople.addGuideUI(UILineup, data)
                elseif type(data) == "function" and uiItem == UILineup then
                    data()
                end
            elseif UIGuidePeople.guideStep == guideInfo["18B2"].step then
                if type(data) == "table" and uiItem == UIBagEquipmentSell then
                    UIGuidePeople.addGuideUI(uiItem, data[2])
                end
            elseif UIGuidePeople.guideStep == guideInfo["18B3"].step then
                if type(data) == "userdata" then
                    UIGuidePeople.addGuideUI(UILineup, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["18B4"].step then
                if type(data) == "userdata" and uiItem == UIEquipmentInfo then
                    UIGuidePeople.addGuideUI(UIEquipmentInfo, data)
                elseif type(data) == "userdata" and uiItem == UIEquipmentNew then
                    UIGuidePeople.addGuideUI(UIEquipmentNew, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["18B5"].step then
                if data == nil and uiItem == UIEquipmentIntensify then
                    UIGuidePeople.addGuideUI(UIEquipmentIntensify, ccui.Helper:seekNodeByName(UIEquipmentIntensify.Widget, "btn_onekey"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["18B6"].step then
                if data == nil and uiItem == UIEquipmentIntensify then
                    UIGuidePeople.addGuideUI(UIEquipmentIntensify, ccui.Helper:seekNodeByName(UIEquipmentIntensify.Widget, "btn_close"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["18B7"].step then
                if data == nil and uiItem == UIEquipmentIntensify then
                    local btn = ccui.Helper:seekNodeByName(UIEquipmentInfo.Widget, "btn_close")
                    if btn then
                        UIGuidePeople.addGuideUI(UIEquipmentInfo, btn)
                    else
                        btn = ccui.Helper:seekNodeByName(UIEquipmentNew.Widget, "btn_close")
                        UIGuidePeople.addGuideUI(UIEquipmentNew, btn)
                    end

                end
            elseif UIGuidePeople.guideStep == guideInfo["18B8"].step then
                if data == nil and uiItem == UIEquipmentInfo then
                    -- UIGuidePeople.addGuideUI(UIMenu, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_property"))
                    UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
                    HomePageController:scrollToPageNow(0)
                    UIGuidePeople.addGuideUI(UIHomePage , ccui.Helper:seekNodeByName(UIHomePage.Widget,"panel_fuben"))
                elseif data == nil and uiItem == UIEquipmentNew then
                    -- UIGuidePeople.addGuideUI(UIMenu, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_property"))
                    UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
                    HomePageController:scrollToPageNow(0)
                    UIGuidePeople.addGuideUI(UIHomePage , ccui.Helper:seekNodeByName(UIHomePage.Widget,"panel_fuben"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["18B9"].step then
                if type(data) == "userdata" and uiItem == UIFight then
                    UIGuidePeople.addGuideUI(UIFight, data)
                end
            end
        elseif UIGuidePeople.param == 20 then
            if UIGuidePeople.guideStep == guideInfo["20B1"].step then
                if type(data) == "userdata" and uiItem == UIHomePage then
                    -- UIHomePage.controller:scrollToPageNow(1)
                    UIGuidePeople.addGuideUI(UIHomePage, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["20B2"].step then
                if uiItem == UILoot and data == 1 then
                    UIGuidePeople.addGuideUI(uiItem, ccui.Helper:seekNodeByName(UILoot.Widget, "btn_loot_treasure"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["20B3"].step then
                if uiItem == UILoot and type(data) == "table" and data[1] == 2 then
                    UIGuidePeople.addGuideUI(uiItem, data[2])
                end
            elseif UIGuidePeople.guideStep == guideInfo["20B4"].step then
                if uiItem == UILootHint and data == nil then
                    UIGuidePeople.addGuideUI(uiItem, ccui.Helper:seekNodeByName(UILootHint.Widget, "btn_loot"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["20B5"].step then
                if uiItem == UILootChoose then
                    if type(data) == "function" then
                        data()
                    else
                        UIGuidePeople.addGuideUI(uiItem, data)
                    end
                end
            elseif UIGuidePeople.guideStep == guideInfo["20B6"].step then
                if type(data) == "userdata" and uiItem == UILootFight then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["20B7"].step then
                if uiItem == UILootFight then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["20B8"].step then
                if uiItem == UILoot and type(data) == "userdata" then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["20B9"].step then
                UIGuidePeople.addGuideUI(UIMenu, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_troops"))
            elseif UIGuidePeople.guideStep == guideInfo["20B10"].step then
                if type(data) == "userdata" and uiItem == UILineup then
                    UIGuidePeople.addGuideUI(uiItem, data)
                elseif type(data) == "function" and uiItem == UILineup then
                    data()
                else
                    if UIGuidePeople.guideStep or UIGuidePeople.levelStep then
                        UIGuidePeople.guideStep = nil
                        UIGuidePeople.levelStep = nil
                        UIGuidePeople.free()
                    end
                end
            elseif UIGuidePeople.guideStep == guideInfo["20B11"].step then
                if uiItem == UIBagGongFaList and type(data) == "userdata" then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["20B12"].step then
                if uiItem == UIBagGongFaList then
                    -- UIGuidePeople.addGuideUI(UIMenu, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_property"))
                    UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
                    HomePageController:scrollToPageNow(0)
                    UIGuidePeople.addGuideUI(UIHomePage , ccui.Helper:seekNodeByName(UIHomePage.Widget,"panel_fuben"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["20B13"].step then
                if type(data) == "userdata" and uiItem == UIFight then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            end
        elseif UIGuidePeople.param == 25 then
            if UIGuidePeople.guideStep == guideInfo["25B1"].step then
                if type(data) == "userdata" and uiItem == UIHomePage then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["25B2"].step then
                if type(data) == "userdata" and uiItem == UIAwardSign then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["25B3"].step then
                if uiItem == UIAwardSign then
                    UIGuidePeople.addGuideUI(UIAwardSign, ccui.Helper:seekNodeByName(UIAwardSign.Widget, "btn_close"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["25B4"].step then
                if not data and uiItem == UIAwardSign then
                    UIManager.pushScene("ui_guide_system")
                end
            elseif UIGuidePeople.guideStep == guideInfo["25B5"].step then
                if not data and uiItem == UITaskDay then
                    local child = ccui.Helper:seekNodeByName(UITaskDay.Widget, "view_award_lv"):getChildren()[1]
                    local button = child:getChildByName("btn_prize")
                    UIGuidePeople.addGuideUI(uiItem, button)
                end
            elseif UIGuidePeople.guideStep == guideInfo["25B6"].step then
                if type(data) == "userdata" and uiItem == UIFight then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            end
        elseif UIGuidePeople.param == DictFunctionOpen[tostring(StaticFunctionOpen.fight)].level then----斗魂引导
       --     cclog( "UIGuidePeople.guideStep : "..UIGuidePeople.guideStep )
            if UIGuidePeople.guideStep == guideInfo["45B1"].step then
                if uiItem == UISoulGet then
                    UIGuidePeople.addGuideUI(uiItem, ccui.Helper:seekNodeByName(UISoulGet.Widget, "image_card1"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["45B2"].step then
                if uiItem == UISoulGet then
                    UIGuidePeople.addGuideUI(uiItem, ccui.Helper:seekNodeByName(UISoulGet.Widget, "image_card2"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["45B3"].step then
                if uiItem == UISoulGet then
                    UIGuidePeople.addGuideUI(uiItem, ccui.Helper:seekNodeByName(UISoulGet.Widget, "btn_expansion"))
                end
            elseif UIGuidePeople.guideStep == guideInfo["45B4"].step then
                if type(data) == "userdata" and uiItem == UISoulInstall then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["45B5"].step then
                if type(data) == "userdata" and uiItem == UISoulList then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end
            elseif UIGuidePeople.guideStep == guideInfo["45B6"].step then
                if type(data) == "userdata" and uiItem == UISoulInstall then
                    UIGuidePeople.addGuideUI(uiItem, data)
                end  
            end
        end
    else
        isLevelStep(data, uiItem)
    end
end

function UIGuidePeople.setGuide()
    -- if net.InstPlayerCard == nil then
    --   UIManager.showScreen("ui_choose")
    --   return
    -- end

    -- 角色ID： net.InstPlayer.int["1"]
    -- 角色名： net.InstPlayer.string["3"]
    -- 角色等级:net.InstPlayer.int["4"]
    local role = dp.getUserData()
    local aa = {
        "v1",tostring(role.roleId),role.roleName,tostring(role.roleLevel),tostring(role.serverId),role.serverName or "",tostring(SDK.firstCreate)
    }
    SDK.doSubmitExtendData(aa)
    SDK.reYunOnLogin({ roleId = tostring(role.roleId ) })
    SDK.firstCreate = 0
    if device.platform ~= "windows" and cc.JNIUtils.setUserInfo then
        cc.JNIUtils:setUserInfo(role.serverName .. "_" .. role.accountId .. "_" .. role.roleName)
    end
    if SDK.getChannel() == "uc" then
    elseif SDK.getChannel() =="360" then       
        local role = dp.getUserData()
        print("firstCreate:",SDK.firstCreate)
        if SDK.firstCreate == 1 then          
            local params = {"enterServer" , tostring(role.serverId) ,role.serverName , tostring(role.roleId), role.roleName ,"0" ,"无","无",tostring(role.roleLevel) ,tostring(utils.getFightValue()) , tostring(role.vipLevel) ,"0","元宝",tostring(net.InstPlayer.int["5"]),"0","无","0","无","无"}
            SDK.doSubmitExtendData(params)        
            local params1 = {"createRole" , tostring(role.serverId) ,role.serverName , tostring(role.roleId), role.roleName ,"0" ,"无","无",tostring(role.roleLevel) ,tostring(utils.getFightValue()) , tostring(role.vipLevel) ,"0","元宝",tostring(net.InstPlayer.int["5"]),"0","无","0","无","无"}
            SDK.doSubmitExtendData(params1)
        else       
            local params = {"enterServer" , tostring(role.serverId) ,role.serverName , tostring(role.roleId), role.roleName ,"0" ,"无","无",tostring(role.roleLevel) ,tostring(utils.getFightValue()) , tostring(role.vipLevel) ,"0","元宝",tostring(net.InstPlayer.int["5"]),"0","无","0","无","无"}
            SDK.doSubmitExtendData(params)     
        end
    elseif SDK.getChannel() == "oppo" then
        local role = dp.getUserData()
        -- 用户所在服，用户名称，用户等级
        local params = { role.serverName, role.roleName, tostring(role.roleLevel) }
        SDK.doSubmitUserInfo(params)
    end

    UIGuidePeople.guideStep = nil
    UIGuidePeople.levelStep = nil
    local level = net.InstPlayer.int["4"]
    utils.beforeLevel = level
    if net.InstPlayer.string["29"] == "f&f" or net.InstPlayer.string["14"] == "f&f" then
        UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
       -- UIManager.pushScene("ui_activity_hint")
        utils.guangGao()
        return
    end
    local guideBarrier = net.InstPlayer.string["29"]
    local _step = utils.stringSplit(guideBarrier, "&")
    -- 关卡步骤
    local guideLevel = net.InstPlayer.string["14"]
    local _levelStep = utils.stringSplit(guideLevel, "&")
    -- 等级步骤
    local levelStr = utils.stringSplit(_levelStep[1], "_")
    local barrierId = nil
    local step = nil
    if _step[1] ~= "" then
        AudioEngine.playMusic("sound/bg_music.mp3", true)
        local str = utils.stringSplit(_step[1], "B")
        barrierId = tonumber(str[1])
        step = tonumber(str[2])
        UIGuidePeople.param = barrierId
        if barrierId == 1 then
            UIGuidePeople.guideStep = guideInfo["1B1"].step
            UIFightTask.setChapterId(1)
            UIManager.showScreen("ui_fight_task")
            -- UIManager.flushWidget(UIFightTask)
            --[[
      if step <= 3 then
        UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
        UIGuidePeople.addGuideUI(UIHomePage,ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_beruty"),guideInfo["1B2"].step)
      else
        UIGuidePeople.guideStep = guideInfo["1B5"].step
        UIFightTask.setChapterId(1)
        UIManager.showScreen("ui_fight_task")
      end
      --]]
        elseif barrierId == 2 then
            if step < 4 then
                UIGuidePeople.guideStep = guideInfo["2B1"].step
                UIFightTask.setChapterId(1)
                UIManager.showScreen("ui_fight_task")
                local function guide()
                    local image_basemap = ccui.Helper:seekNodeByName(UIFightTask.Widget, "image_basemap")
                    UIGuidePeople.addGuideUI(UIFightTask, image_basemap:getChildByName("box1"))
                end
                UIFightTask.Widget:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(guide)))
            elseif step >= 4 and step <= 9 then
                UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
                UIGuidePeople.addGuideUI(UIMenu, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_troops"), guideInfo["2B6"].step)
            else
                UIGuidePeople.guideStep = guideInfo["2B11"].step
                UIFightTask.setChapterId(1)
                UIManager.showScreen("ui_fight_task")
            end
        elseif barrierId == 3 then
            UIGuidePeople.guideStep = guideInfo["3B1"].step
            UIFightTask.setChapterId(1)
            UIManager.showScreen("ui_fight_task")
        elseif barrierId == 4 then
            if step <= 4 then
                UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
                UIGuidePeople.addGuideUI(UIMenu, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_troops"), guideInfo["4B1"].step)
            else
                UIGuidePeople.guideStep = guideInfo["4B8"].step
                UIFightTask.setChapterId(1)
                UIManager.showScreen("ui_fight_task")
            end
        elseif barrierId == 5 then
            if step <= 3 then
                UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
                UIGuidePeople.addGuideUI(UIMenu, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_shop"), guideInfo["5B1"].step)
            elseif step > 3 and step <= 8 then
                UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
                UIGuidePeople.addGuideUI(UIMenu, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_troops"), guideInfo["5B5"].step)
            else
                UIGuidePeople.guideStep = guideInfo["5B10"].step
                UIFightTask.setChapterId(1)
                UIManager.showScreen("ui_fight_task")
            end
        elseif barrierId == 6 then
            if step <= 6 then
                UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
                UIGuidePeople.addGuideUI(UIMenu, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_troops"), guideInfo["6B2"].step)
            else
                UIGuidePeople.guideStep = guideInfo["6B10"].step
                UIFightTask.setChapterId(1)
                UIManager.showScreen("ui_fight_task")
            end
        elseif barrierId == 7 then
            --      if step <=2 then
            --        UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
            --        UIGuidePeople.addGuideUI(UIHomePage,ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_lv"),guideInfo["7B1"].step)
            if step <= 3 then
                UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
                UIGuidePeople.addGuideUI(UIHomePage, ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_fuli"), guideInfo["7B1"].step)
            else
                UIGuidePeople.guideStep = guideInfo["7B7"].step
                UIFightTask.setChapterId(1)
                UIManager.showScreen("ui_fight_task")
            end
        elseif barrierId == 8 then
            if step <= 2 then
                UIFightTask.setChapterId(1)
                UIManager.showScreen("ui_fight_task")
                UIGuidePeople.addGuideUI(UIFightTask, ccui.Helper:seekNodeByName(UIFightTask.Widget, "image_box_special"), guideInfo["8B1"].step)
            else
            
                UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
               -- UIManager.pushScene("ui_activity_hint")
                utils.guangGao()
            end
        elseif barrierId == 18 then
            local function checkIsHaveEquip()
                local FormationNum = utils.getDictTableNum(net.InstPlayerFormation)
                local number = 0
                if net.InstPlayerLineup then
                    for key, obj in pairs(net.InstPlayerLineup) do
                        if obj.int["4"] == StaticEquip_Type.equip then
                            number = number + 1
                        end
                    end
                end
                local EquipNum = 0
                if net.InstPlayerEquip then
                    for key, obj in pairs(net.InstPlayerEquip) do
                        if obj.int["3"] == StaticEquip_Type.equip then
                            EquipNum = EquipNum + 1
                        end
                    end
                end
                if FormationNum > number and EquipNum > number then
                    return true
                else
                    return false
                end
            end
            if checkIsHaveEquip() then
                if step <= 3 then
                    UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
                    UIGuidePeople.addGuideUI(UIMenu, ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_troops"), guideInfo["18B1"].step)
                elseif step > 3 and step <= 6 then
                    UIGuidePeople.guideStep = guideInfo["18B3"].step
                    UILineup.friendState = 0
                    UIManager.showWidget("ui_notice", "ui_lineup", "ui_menu")
                else
                
                    UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
                    --UIManager.pushScene("ui_activity_hint")
                     utils.guangGao()
                end
            else
            
                UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
                --UIManager.pushScene("ui_activity_hint")
                 utils.guangGao()
            end     
        elseif barrierId == 45 then
            if step < 3 then
                UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
                UIGuidePeople.addGuideUI(UIHomePage, ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_soul"), guideInfo["45B1"].step) 
            else
            
                UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
                --UIManager.pushScene("ui_activity_hint")  
                utils.guangGao()               
            end
        else
            --- 18级引导重连---
            -- if level == guideInfo.resolveGuideLevel and tonumber(levelStr[1]) == guideInfo.resolveGuideLevel then
            --   if tonumber(levelStr[2]) <= 3 then
            --       UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
            --       UIGuidePeople.addGuideUI(UIHomePage,ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_resolve"),guideInfo["12_1"].step)
            --   else
            --       UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
            --   end
            -- elseif level == guideInfo.constellGuideLevel and tonumber(levelStr[1]) == guideInfo.constellGuideLevel then
            --   if tonumber(levelStr[2]) <= 5 then
            --       UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
            --       UIGuidePeople.addGuideUI(UIMenu,ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_troops"),guideInfo["20_1"].step)
            --   else
            --       UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
            --   end
            -- else
            
            UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
            -- end
            --UIManager.pushScene("ui_activity_hint")
             utils.guangGao()
        end
    elseif level == 1 and _step[1] == "" then
        UIGuidePeople.newBarrier = true
        UIManager.uiLayer:removeAllChildren()
        --        local visibleSize = cc.Director:getInstance():getVisibleSize()
        --        local text = ccui.Text:create("三年前萧家", dp.FONT, 35)
        --        text:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2))
        --        UIManager.uiLayer:addChild(text)
        local function callfunc()
            --            text:retain()
            UIFightTask.setChapterId(1)
            UIManager.showScreen("ui_fight_task")
            local taskStory = FightTaskInfo.getData(1, 1)
            local function callBack()
                local param = { }
                param.barrierLevelId = 1
                param.chapterId = 1
                param.barrierId = 1
                if FightTaskData.FightData[1][1] then
                    FightTaskData.FightData[1][1].record = nil
                    UIFightMain.setData(FightTaskData.FightData[1][1], param, dp.FightType.FIGHT_TASK.COMMON)
                else
                    utils.sendFightData(param, dp.FightType.FIGHT_TASK.COMMON)
                end
                UIFightMain.loading()
            end
            if taskStory then
                UIGuideInfo.PlayStory(taskStory, 1, "begin", callBack)
            else
                callBack()
            end
            --            cc.release(text)
        end
        callfunc()
        --        text:runAction(cc.Sequence:create(cc.FadeOut:create(2), cc.CallFunc:create(callfunc)))
        --   elseif levelStr[1] then
        --    local levelFlag = tonumber(levelStr[1])
        --    local levelStep = tonumber(levelStr[2])
        --    if levelFlag==10 then
        --        if levelStep <=3 then
        --            UIGuidePeople.addGuideUI(UIHomePage,ccui.Helper:seekNodeByName(UIHomePage.Widget, "btn_fuli"),guideInfo["10_1"].step)
        --        elseif levelStep < 6 then
        --            UIGuidePeople.addGuideUI(UIMenu,ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_troops"),guideInfo["10_5"].step)
        --        end
        --    end
    else
    
        UIManager.showScreen("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
        --UIManager.pushScene("ui_activity_hint")
         utils.guangGao()
    end
end


local function addPeople(widget_child)
    UIGuidePeople.widgetPeople = ccui.Widget:create()
    local ui_image_di = ccui.ImageView:create("ui/ql1.png")
    local ui_info_di = ccui.ImageView:create("ui/ql2.png")
    local description = ccui.Text:create()
    description:setFontName(dp.FONT)
    description:setFontSize(20)
    description:setTextAreaSize(cc.size(ui_info_di:getContentSize().width * 0.6, 200))
    description:setAnchorPoint(cc.p(0, 1))
    local effect = nil
    local scriptPosY = nil
    if isTest then
        description:setString(Lang.ui_guide_people1)
    else
        if UIGuidePeople.guideStep then
            description:setString(guideInfo[UIGuidePeople.guideStep].Info.text)
            effect = guideInfo[UIGuidePeople.guideStep].effect
            scriptPosY = guideInfo[UIGuidePeople.guideStep].posY
        elseif UIGuidePeople.levelStep then
            description:setString(guideInfo[UIGuidePeople.levelStep].Info.text)
            effect = guideInfo[UIGuidePeople.levelStep].effect
            scriptPosY = guideInfo[UIGuidePeople.levelStep].posY
        end
    end
    description:setTextColor(cc.c4b(51, 25, 4, 255))
    description:setPosition(cc.p(ui_info_di:getContentSize().width * 0.3 - 10, ui_info_di:getContentSize().height * 0.7))
    ui_image_di:setPosition(cc.p(- ui_image_di:getContentSize().width / 2 + 55, 0))
    ui_info_di:setPosition(cc.p(ui_info_di:getContentSize().width / 2, -25))
    ui_info_di:addChild(description)
    UIGuidePeople.widgetPeople:addChild(ui_image_di)
    UIGuidePeople.widgetPeople:addChild(ui_info_di)
    ui_info_di:setVisible(false)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local Pos = widget_child:getParent():convertToWorldSpace(cc.p(widget_child:getPosition()))
    local positionY = 0
    if Pos.y > visibleSize.height / 2 then
        positionY = Pos.y - ui_image_di:getContentSize().height / 2 - 40
    else
        positionY = Pos.y + ui_image_di:getContentSize().height / 2 + 40
    end
    ----------判断脚本坐标-----------
    if scriptPosY then
        positionY = scriptPosY
    end
    UIGuidePeople.widgetPeople:setPosition(cc.p(visibleSize.width / 2, positionY))
    ui_image_di:setScale(0.7)
    local function playEffect()
        ui_info_di:setVisible(true)
        ui_info_di:runAction(cc.MoveBy:create(0.08, cc.p(-60, 0)))
        if effect then
            local soundPath = "sound/guide/" .. effect
            if cc.FileUtils:getInstance():isFileExist(soundPath) then
                handle = AudioEngine.playEffect(soundPath)
            end
        end
    end
    ui_image_di:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.05, 1), cc.CallFunc:create(playEffect)))
end


----引导添加粒子旋转的方法
--- layer 添加的层
--- pos 坐标
-- size 大小
-- isSquare 是否是方形
local function addButtonParticle(layer, Pos, size, isSquare)
    local particle1 = cc.ParticleSystemQuad:create("particle/btn_xing_b.plist")
    local path1 = nil
    if isSquare then
        particle1:setPosition(cc.p(Pos.x - size.width / 2, Pos.y - size.height / 2))
        path1 = utils.MyPathFun(0, size.height, size.width, 0.8, 1)
    else
        particle1:setPosition(cc.p(Pos.x, Pos.y - 55))
        path1 = utils.MyPathFun(70, 110, 0, 0.8, 1)
    end
    layer:addChild(particle1, UIGuidePeople.ObjTag.Particle1, UIGuidePeople.ObjTag.Particle1)
    particle1:runAction(path1)
    local particle2 = cc.ParticleSystemQuad:create("particle/btn_xing_y.plist")
    local path2 = nil
    if isSquare then
        particle2:setPosition(cc.p(Pos.x + size.width / 2, Pos.y + size.height / 2))
        path2 = utils.MyPathFun(0, size.height, size.width, 0.8, 2)
    else
        particle2:setPosition(cc.p(Pos.x, Pos.y + 55))
        path2 = utils.MyPathFun(70, 110, 0, 0.8, 2)
    end
    layer:addChild(particle2, UIGuidePeople.ObjTag.Particle2, UIGuidePeople.ObjTag.Particle2)
    particle2:runAction(path2)
end

local leftBox = cc.rect(0, 0, 70, 70)
local rightBox = cc.rect(570, 0, 70, 70)
local pw = ""

function UIGuidePeople.addGuideUI(uiItem, widget_child, step, callBackFunc)
    if UITalkFly.layer then
        UITalkFly.hide()
    end
    if not step then
        -- 不添就自动加1 添了就不变
        if UIGuidePeople.guideStep then
            local str = utils.stringSplit(UIGuidePeople.guideStep, "B")
            local str1 = tonumber(str[1])
            local str2 = tonumber(str[2]) + 1
            step = str1 .. "B" .. str2
            -- UIGuidePeople.currentFlag = 1
        elseif UIGuidePeople.levelStep then
            local str = utils.stringSplit(UIGuidePeople.levelStep, "_")
            local str1 = tonumber(str[1])
            local str2 = tonumber(str[2]) + 1
            step = str1 .. "_" .. str2
            -- UIGuidePeople.currentFlag = 2
        end
    end
    if step ~= 0 then
        UIGuidePeople.setUIEnabled(false)
        if not string.find(step, "B") then
            UIGuidePeople.sendGuideData(step, 2)
        else
            UIGuidePeople.sendGuideData(step, 1)
        end
        if UIGuidePeople.guideStep and uiItem then
            cclog("已添加,关卡引导步数变为=" .. UIGuidePeople.guideStep)
        elseif UIGuidePeople.levelStep and uiItem then
            cclog("已添加,等级引导步数变为=" .. UIGuidePeople.levelStep)
        end
    end
    haveAdd = true
    UIGuidePeople.guideFlag = true
    if uiItem.Widget then
        uiItem.Widget:setEnabled(false)
    end
    if UIGuidePeople.isPushScene then
        uiItem.Widget:getChildren()[1]:setScale(dp.DIALOG_SCALE)
    end

    if not widget_child then
        if step ~= 0 then
            if (UIGuidePeople.guideStep and guideInfo[UIGuidePeople.guideStep].Info) or
                (not UIGuidePeople.guideStep and UIGuidePeople.levelStep and guideInfo[UIGuidePeople.levelStep].Info) then
                if uiItem.Widget and uiItem.Widget:getParent() then
                    local layout = ccui.Layout:create()
                    layout:setContentSize(display.size)
                    layout:setTouchEnabled(true)
                    UIManager.uiLayer:addChild(layout, 20000)
                    addPeople(layout)
                    layout:addChild(UIGuidePeople.widgetPeople)
                    UIGuidePeople.widgetPeople:retain()
                    layout:addTouchEventListener( function(sender, eventType)
                        if eventType == ccui.TouchEventType.ended then
                            UIGuidePeople.widgetPeople:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0.1), cc.CallFunc:create(function()
                                UIGuidePeople.free()
                                layout:removeSelf()
                            end)))
                        end
                    end )
                end
            end
        end
        return
    end

    UIGuidePeople.widgetNode = ccui.Widget:create()
    local Pos = widget_child:getParent():convertToWorldSpace(cc.p(widget_child:getPosition()))
    local size = widget_child:getBoundingBox()
    local anchorPoint = cc.p(widget_child:getAnchorPoint())
    if anchorPoint.x == 0 and anchorPoint.y == 1 then
        Pos = cc.p(Pos.x + size.width / 2, Pos.y - size.height / 2)
    elseif anchorPoint.x == 0 and anchorPoint.y == 0 then
        Pos = cc.p(Pos.x + size.width / 2, Pos.y + size.height / 2)
    end
    if uiItem == UIFightTask then
        Pos.y = Pos.y + 10
    end
    local radius = 55
    ----------添加人物-----------------------------
    local isAddPeople = false
    if step ~= 0 then
        if (UIGuidePeople.guideStep and guideInfo[UIGuidePeople.guideStep].Info) or
            (not UIGuidePeople.guideStep and UIGuidePeople.levelStep and guideInfo[UIGuidePeople.levelStep].Info) then
            isAddPeople = true
            addPeople(widget_child)
        end
    end
    -----测试专用------------------
    if isTest then
        isAddPeople = true
        addPeople(widget_child, callBackFunc)
    end
    ------添加手指-----------------------------
    local finger = ccui.ImageView:create("ui/hand.png")
    finger:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(5, 10)),
    cc.MoveBy:create(0.5, cc.p(-5, -10)), cc.DelayTime:create(0.5))))
    finger:setAnchorPoint(cc.p(0, 1))
    local _pos = nil
    if Pos.x + size.width > cc.Director:getInstance():getVisibleSize().width then
        finger:setFlippedX(true)
        if isAddPeople then
            UIGuidePeople.pos = cc.p(Pos.x, Pos.y + 10)
            local _x, _y = UIGuidePeople.widgetPeople:getPosition()
            _pos = cc.p(_x, _y - 50)
        else
            _pos = cc.p(Pos.x, Pos.y + 10)
        end
    else
        if isAddPeople then
            UIGuidePeople.pos = cc.p(Pos.x, Pos.y + 10)
            local _x, _y = UIGuidePeople.widgetPeople:getPosition()
            _pos = cc.p(_x + 200, _y - 50)
        else
            _pos = cc.p(Pos.x, Pos.y + 10)
        end
    end
    finger:setPosition(_pos)
    --------添加粒子---------------------------------
    addButtonParticle(UIGuidePeople.widgetNode, Pos, size, isSquare)
    ---------------------------------------------
    UIGuidePeople.widgetNode:addChild(finger, UIGuidePeople.ObjTag.finger, UIGuidePeople.ObjTag.finger)
    if isAddPeople then
        UIGuidePeople.widgetNode:getChildByTag(UIGuidePeople.ObjTag.finger):setVisible(false)
        UIGuidePeople.widgetNode:getChildByTag(UIGuidePeople.ObjTag.Particle1):setVisible(false)
        UIGuidePeople.widgetNode:getChildByTag(UIGuidePeople.ObjTag.Particle2):setVisible(false)
    end
    local listen_layer = cc.Layer:create()
    -- 首先在场景的最上方再添加一个layer
    local function onTouchBegan(touch, event)
        local locationInNode = event:getCurrentTarget():convertToNodeSpace(touch:getLocation())
        local rect = cc.rect(Pos.x - radius, Pos.y - radius, radius * 2, radius * 2)
        if cc.rectContainsPoint(rect, locationInNode) and(uiItem.Widget and uiItem.Widget:getParent()) then
            if tolua.type(widget_child) == "ccui.Button" then
                widget_child:setHighlighted(true)
            end
        end
        return true
    end
    local function onTouchMoved(touch, event)
        local locationInNode = event:getCurrentTarget():convertToNodeSpace(touch:getLocation())
        local rect = cc.rect(Pos.x - radius, Pos.y - radius, radius * 2, radius * 2)
        if not cc.rectContainsPoint(rect, locationInNode) and(uiItem.Widget and uiItem.Widget:getParent()) then
            if tolua.type(widget_child) == "ccui.Button" then
                widget_child:setHighlighted(false)
            end
        end
    end
    local function onTouchEnded(touch, event)
        if UIGuidePeople.isSuccess then
            local locationInNode = event:getCurrentTarget():convertToNodeSpace(touch:getLocation())
            local rect = cc.rect(Pos.x - radius, Pos.y - radius, radius * 2, radius * 2)
            if cc.rectContainsPoint(rect, locationInNode) and((uiItem.Widget and uiItem.Widget:getParent()) or UIGuidePeople.guideStep == guideInfo["2B4"].step) then
                chargeFlag = 0
                if UIGuidePeople.levelStep == guideInfo["26_3"].step then
                    uiItem.guideEvent(widget_child, ccui.TouchEventType.ended)
                    UIGuidePeople.free()
                    return
                end
                UIGuidePeople.free()
                if UIGuidePeople.guideStep == guideInfo["2B4"].step then
                    --- 移除虎加动画
                    UIManager.uiLayer:removeChildByTag(100)
                    UIGuidePeople.isGuide(nil, UIAwardGet)
                elseif UIGuidePeople.guideStep == guideInfo["2B2"].step then
                    UIAwardGet.setOperateType(UIAwardGet.operateType.box, DictBarrier["2"], UIFightTask)
                    UIManager.pushScene("ui_award_get")
                elseif UIGuidePeople.guideStep == guideInfo["2B8"].step or
                    UIGuidePeople.guideStep == guideInfo["5B7"].step or
                    UIGuidePeople.levelStep == guideInfo["7_5"].step or
                    UIGuidePeople.levelStep == guideInfo["8_2"].step or
                    UIGuidePeople.levelStep == guideInfo["10_8"].step or
                    UIGuidePeople.levelStep == guideInfo["18_2"].step or
                    UIGuidePeople.levelStep == guideInfo["20_2"].step or
                    UIGuidePeople.guideStep == guideInfo["6B3"].step or
                    UIGuidePeople.guideStep == guideInfo["4B2"].step then
                        uiItem.guideEvent(widget_child, ccui.TouchEventType.ended)
                elseif uiItem == UIFightMain or uiItem == TestLogin then
                    callBackFunc()
                else
                    if tolua.type(widget_child) == "ccui.Button" then
                        widget_child:setHighlighted(false)
                    end
                    widget_child:releaseUpEvent()
                end
            end
            ------------------用于打开充值-----------------------------
            if cc.rectContainsPoint(leftBox, locationInNode) then
                pw = pw .. "1"
            elseif cc.rectContainsPoint(rightBox, locationInNode) then
                pw = pw .. "2"
            else
                pw = ""
            end
            if string.len(pw) == 3 then
                if pw == "121" then
                    local editBox = cc.EditBox:create(cc.size(228, 54), cc.Scale9Sprite:create("image/dl_1.png"))
                    editBox:setAnchorPoint(cc.p(0.5, 0.5))
                    editBox:setFontColor(cc.c3b(255, 0, 0))
                    editBox:setFont(dp.FONT, 25)
                    editBox:setPosition(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2)
                    editBox:setPlaceHolder(Lang.ui_guide_people2)
                    editBox:setEnabled(true)
                    editBox:setTouchEnabled(true)
                    editBox:setFocused(true)
                    local button = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png", "ui/tk_btn01.png")
                    button:setTitleText(Lang.ui_guide_people3)
                    button:setTitleFontSize(30)
                    button:addTouchEventListener( function(button, type)
                        if type == 2 then
                            if editBox:getText() == "0919" then
                                UIManager.popScene(true)
                                UIGuidePeople.setUIEnabled(true)
                                UIGuidePeople.free()
                                utils.checkGOLD(1)
                            else
                                editBox:removeFromParent()
                                button:removeFromParent()
                            end
                        end
                        pw = ""
                    end
                    )
                    button:setPosition(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2 - editBox:getContentSize().height / 2 - 50)
                    listen_layer:addChild(button, 1000, 1000)
                    listen_layer:addChild(editBox, 1001, 1001)
                else
                    pw = ""
                end
            end
            ---------------------------------------------------------------
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    -- 创建一个触摸监听(单点触摸）
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = listen_layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, listen_layer)
    UIGuidePeople.widgetNode:addChild(listen_layer, UIGuidePeople.ObjTag.listenerLayer, UIGuidePeople.ObjTag.listenerLayer);
    UIGuidePeople.widgetNode:retain()
    if not tolua.isnull(UIGuidePeople.widgetPeople) then
        UIGuidePeople.widgetPeople:retain()
    end
    if not UIGuidePeople.isPushScene or(UIGuidePeople.guideStep == guideInfo["1B1"].step or UIGuidePeople.guideStep == guideInfo["2B1"].step) and(uiItem ~= UIFightWin and uiItem ~= UIFightUpgrade) then
        UIGuidePeople.addGuideWidget()
    end
end


function UIGuidePeople.free()
    if UIManager.uiLayer:getChildByTag(UIGuidePeople.ObjTag.layer) ~= nil then
        UIManager.uiLayer:removeChildByTag(UIGuidePeople.ObjTag.layer)
    end
    if UIManager.uiLayer:getChildByTag(UIGuidePeople.ObjTag.dialog) ~= nil then
        UIManager.uiLayer:removeChildByTag(UIGuidePeople.ObjTag.dialog)
    end
    if not tolua.isnull(UIGuidePeople.widgetNode) then
        UIGuidePeople.widgetNode:release()
    end
    if not tolua.isnull(UIGuidePeople.widgetPeople) then
        UIGuidePeople.widgetPeople:release()
    end
    UIGuidePeople.widgetNode = nil
    UIGuidePeople.widgetPeople = nil
    UIGuidePeople.isPushScene = false
    if handle then
        local step = nil
        if UIGuidePeople.guideStep then
            local str = utils.stringSplit(UIGuidePeople.guideStep, "B")
            local str1 = tonumber(str[1])
            local str2 = tonumber(str[2]) + 1
            step = str1 .. "B" .. str2
        elseif UIGuidePeople.levelStep then
            local str = utils.stringSplit(UIGuidePeople.levelStep, "_")
            local str1 = tonumber(str[1])
            local str2 = tonumber(str[2]) + 1
            step = str1 .. "_" .. str2
        end
        if step and guideInfo[step] and guideInfo[step].effect then
            AudioEngine.stopEffect(handle)
            handle = nil
        end
    end
    cleanGuideStep()
    if not UIGuidePeople.guideStep and not UIGuidePeople.levelStep and UITalkFly.layer then
        UITalkFly.fShow()
    end
    haveAdd = nil
end

local function update(dt)
    if not UIGuidePeople.guideStep and not UIGuidePeople.levelStep then
        UIGuidePeople.guideFlag = nil

    end
    if UIGuidePeople.guideFlag then
        local allWidget = WidgetManager.getAllWidgetClass()
        for key, obj in pairs(allWidget) do
            if obj.Widget and obj.Widget:isEnabled() and obj ~= UIFightMain and obj ~= UIFightUpgrade
                and obj ~= UIFightGetAccident and obj ~= UIGuideInfo and obj ~= UIGuideSystem and obj ~= UIAwardSignHint then
                obj.Widget:setEnabled(false)
            end
        end
    else
        UIGuidePeople.setUIEnabled(true)
    end
end

function UIGuidePeople.setUIEnabled(Enabled)
    if not Enabled then
        if not UIGuidePeople.callUpdate then
            UIGuidePeople.callUpdate = true
            UIManager.gameLayer:scheduleUpdateWithPriorityLua(update, 0)
        end
    else
        UILineup.setSectorViewEnabled(true)
        UIGuidePeople.callUpdate = nil
        UIManager.gameLayer:unscheduleUpdate()
        local allWidget = WidgetManager.getAllWidgetClass()
        for key, obj in pairs(allWidget) do
            if obj.Widget then
                obj.Widget:setEnabled(true)
            end
        end
    end
end

function UIGuidePeople.addGuideWidget()
    if UIManager.uiLayer:getChildByTag(UIGuidePeople.ObjTag.layer) == nil then
        local function showParticle()
            UIGuidePeople.widgetNode:getChildByTag(UIGuidePeople.ObjTag.Particle1):setVisible(true)
            UIGuidePeople.widgetNode:getChildByTag(UIGuidePeople.ObjTag.Particle2):setVisible(true)
        end
        local function addUIAction()
            UIManager.uiLayer:addChild(UIGuidePeople.widgetNode, UIGuidePeople.ObjTag.layer, UIGuidePeople.ObjTag.layer)
            local finger = UIGuidePeople.widgetNode:getChildByTag(UIGuidePeople.ObjTag.finger)
            local pos_f = cc.p(finger:getPosition())
            local speed = 1000
            local time = cc.pGetDistance(pos_f, UIGuidePeople.pos) / speed
            finger:setVisible(true)
            finger:runAction(cc.Sequence:create(cc.MoveTo:create(time, UIGuidePeople.pos), cc.CallFunc:create(showParticle)))
        end
        if not tolua.isnull(UIGuidePeople.widgetNode) and not tolua.isnull(UIGuidePeople.widgetPeople) then
            UIManager.uiLayer:addChild(UIGuidePeople.widgetPeople, UIGuidePeople.ObjTag.dialog, UIGuidePeople.ObjTag.dialog)
            UIManager.uiLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.8), cc.CallFunc:create(addUIAction)))
        else
            if not tolua.isnull(UIGuidePeople.widgetNode) then
                UIManager.uiLayer:addChild(UIGuidePeople.widgetNode, UIGuidePeople.ObjTag.layer, UIGuidePeople.ObjTag.layer)
            end
        end
    end
end
