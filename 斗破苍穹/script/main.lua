require"Lang"

-- 重新加载lua模块
-- string:<moduleName> 要重新加载的模块名
-- string:[tableName]  要重新加载的表名
function reloadModule(moduleName, tableName)
    if type(tableName) == "string" then
        _G[tableName] = nil
    end
    if type(moduleName) == "string" then
        _G.package.loaded[moduleName] = nil
        require(moduleName)
    end
end

cc.FileUtils:getInstance():setPopupNotify(false)

--IOS_PREVIEW = true

require "config"
require "cocos.init"
require "constants"
require "SectorView"
require "net"
require "uimanager"
require "SDK"
-- cclog
cclog = function(...)
    print(string.format(...))
end
-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    if device.platform ~= "windows" and onLuaException then
        onLuaException(tostring(msg), debug.traceback())
    end
    cclog("----------------------------------------")
    if UIGuidePeople.guideStep or UIGuidePeople.levelStep then
        UIGuidePeople.guideStep = nil
        UIGuidePeople.levelStep = nil
        UIGuidePeople.free()
    else
        local childs = UIManager.uiLayer:getChildren()
        for key, obj in pairs(childs) do
            if (not tolua.isnull(obj)) and(not obj:isEnabled()) then
                obj:setEnabled(true)
            end
        end
    end
end

local function main()
    if SDK.getChannel() == "anysdk" then
        require "DictRecharge"
    elseif SDK.getDeviceInfo().packageName == "com.y2game.doupocangqiong" then
        require "DictRechargeForIOSBrushList"
    elseif SDK.getDeviceInfo().packageName == "com.dpdl.20161009.zy" then
        require "DictRechargeForIOSBrushList2"
      --  SHOW_VIDEO = true
    end
    if IOS_PREVIEW then
        for k, v in pairs(DictRecharge) do
            if v.firstAmt > 0 then
                v.firstAmt = -1
                v.firstAmtDes = v.noFirstAmtDes
            end
        end
    end
    if false and device.platform == "android" then
        -- todo 解决IOS，暂不缩进了，Android发现也有问题。
        local lastTime = os.time()
        local lastClock = os.clock()
        local isMessaging = false
        local happenTimes = 0
        cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        function(dt)
            if isMessaging then
                return
            end
            local currClock = os.clock()
            local currTime = os.time()
            if lastClock > 2140 and currClock < -2140 then
                -- todo未完整测试
                lastClock = currClock
                return
            end
            local daltaClock = currClock - lastClock
            local daltaTime = currTime - lastTime
            local factor = daltaTime / daltaClock
            if factor > 1.1 then
                -- cclog("+++倍数 " .. factor)
                happenTimes = happenTimes + 1
                if happenTimes > 5 then
                    -- cc.Director:getInstance():getScheduler():unscheduleScriptEntry(sID)
                    -- utils.PromptDialog(function(p)end,"游戏不允许使用外挂！请立即退出游戏！",nil,1001)
                    isMessaging = true
                    netDisconnect()
                    local visibleSize = cc.Director:getInstance():getVisibleSize()
                    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
                    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
                    bg_image:setPreferredSize(cc.size(500, 300))
                    bg_image:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2))
                    local bgSize = bg_image:getPreferredSize()
                    local msgLabel = ccui.Text:create()
                    msgLabel:setString(Lang.main1)
                    msgLabel:setFontName(dp.FONT)
                    msgLabel:setTextAreaSize(cc.size(425, 300))
                    msgLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
                    msgLabel:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
                    msgLabel:setFontSize(26)
                    msgLabel:setTextColor(cc.c4b(255, 255, 255, 255))
                    msgLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.6))
                    bg_image:addChild(msgLabel)
                    local sureBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
                    sureBtn:setTitleText(Lang.main2)
                    sureBtn:setTitleFontName(dp.FONT)
                    sureBtn:setTitleColor(cc.c3b(255, 255, 255))
                    sureBtn:setTitleFontSize(25)
                    sureBtn:setPressedActionEnabled(true)
                    sureBtn:setTouchEnabled(true)
                    sureBtn:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.25))
                    bg_image:addChild(sureBtn)
                    local function btnEvent(sender, eventType)
                        if eventType == ccui.TouchEventType.ended then
                            cc.JNIUtils:exitGame()
                        end
                    end
                    sureBtn:addTouchEventListener(btnEvent)
                    local colorLayer = cc.LayerColor:create(cc.c4b(128, 128, 128, 128))
                    colorLayer:setAnchorPoint(cc.p(0.5, 0.5))
                    colorLayer:setPosition(0, 0)
                    colorLayer:addChild(bg_image)
                    colorLayer:setTouchEnabled(true)
                    colorLayer:registerScriptTouchHandler( function(type)
                        -- if type == "ended" then
                        -- cc.JNIUtils:exitGame()
                        -- end
                        return true
                    end
                    , false, 0, true)
                    cc.Director:getInstance():getRunningScene():addChild(colorLayer, 123)
                end
                -- elseif factor < 0.9 then --todo不管减速
                -- cclog("---倍数 " .. factor)
            else
                -- cclog("~~~正常速度")
                happenTimes = 0
            end
            lastClock = currClock
            lastTime = currTime
        end
        , 1, false)
    end
    -- todo 解决IOS，暂不缩进了，Android发现也有问题。
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    --[[
	local glView = cc.Director:getInstance():getOpenGLView()
	cc.SCREEN_RESOLUTION = glView:getFrameSize()
	if not (cc.sizeEqualToSize(cc.SCREEN_RESOLUTION, cc.size(640,1136))) then
	glView:setDesignResolutionSize(640, 960, cc.ResolutionPolicy.SHOW_ALL)
	end
	]]

    SDK.init()

    math.randomseed(os.time())

    UIManager.init()
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(UIManager.gameScene)
    else
        cc.Director:getInstance():runWithScene(UIManager.gameScene)
    end
    AudioEngine.setMusicVolume(0.5)
--    if dp.RELEASE then
        UIManager.showScreen("ui_tips")
 --   else
--        UIManager.showScreen("test_login")
 --   end
   -- cc.JNIUtils:showGameNotice(dp.NOTICE_URL)
    cc.Director:getInstance():getScheduler():scheduleScriptFunc( function(dt)
        collectgarbage("collect")
        printInfo("LUA MEMORY %f", collectgarbage("count"))
    end , 60, false)
    if SDK.getChannel() == "dev" then
        onLuaException = nil
        cc.JNIUtils.setUserInfo = nil
    end
end

function resetSceneTimes()
     
    --cclog("次日重置时间和次数")

    UIAwardSign.DictActivitySignIn1 = { }
    UIAwardSign.DictActivitySignIn2 = { }
    UIStar.curChooseG = 0
    if utils.countDownScheduleId ~= nil then
        if utils.countDownScheduleId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(utils.countDownScheduleId)
        end
        net.countDown = 24 * 3600
        utils.countDownScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(resetSceneTimes, tonumber(net.countDown), false)

        -----------将购买体力丹和耐力丹的次数清零-------------------
        -- if net.InstPlayer  then
        -- 	net.InstPlayer.int["25"] = 0
        -- 	net.InstPlayer.int["26"] = 0
        -- end
        -----将副本的挑战次数清零------
        if net.InstPlayerChapter then
            for key, obj in pairs(net.InstPlayerChapter) do
                obj.int["4"] = 0
                obj.int["8"] = 0
            end
        end
        if net.InstPlayerChapterType then
            for key, obj in pairs(net.InstPlayerChapterType) do
                obj.int["4"] = 0
                obj.int["6"] = 0
            end
        end
        if net.InstPlayerBarrier then
            for key, obj in pairs(net.InstPlayerBarrier) do
                obj.int["4"] = 0
                obj.int["8"] = 0
            end
        end
        if net.InstPlayerPagoda then
            net.InstPlayerPagoda.int["5"] = 0
            net.InstPlayerPagoda.int["6"] = 0
        end
        if net.InstPlayerArenaConvert then
            for ipacKey, ipacObj in pairs(net.InstPlayerArenaConvert) do
                if DictArenaConvert[tostring(ipacObj.int["3"])].convertType ~= 1 then
                    ipacObj.int["4"] = 0
                end
            end
        end

        if net.InstPlayerDailyTask then
            for key, obj in pairs(net.InstPlayerDailyTask) do
                obj.int["4"] = 0
                -- 重置次数
                obj.int["5"] = 0
                -- 未领取
            end
        end
        ---------------------------
        UIActivityHJY.isReset = true
        UIManager.flushWidget(UIActivityHJY)
        ---------------------------------------
        UIFightTaskChoose.ResetData()
        local tableTime = utils.changeTimeFormat(net.serverLoginTime)
        local _date = os.date("*t", utils.getCurrentTime())
        dp.loginDay = _date.day
        local function CallbackFunc(pack)
            --------------签到-------------
            if net.InstActivitySignIn then
                for key, obj in pairs(net.InstActivitySignIn) do
                    if obj.int["3"] == 1 then
                        obj.int["4"] = 0
                        obj.int["5"] = 0
                    end
                end
            end
            -----------------------------
            if pack.msgdata.message.DictActivitySignIn1.message then
                UIAwardSign.DictActivitySignIn1 = pack.msgdata.message.DictActivitySignIn1.message
            end
            if pack.msgdata.message.DictActivitySignIn2.message then
                UIAwardSign.DictActivitySignIn2 = pack.msgdata.message.DictActivitySignIn2.message
            end
            if not UIGuidePeople.guideStep and not UIGuidePeople.levelStep then
                UIManager.flushWidget(UIAwardSign)
            end
        end
        if tonumber(tableTime[2]) ~= tonumber(_date.month) then
            netSendPackage( { header = StaticMsgRule.initSignIn, }, CallbackFunc)
        end
        if not UIGuidePeople.guideStep and not UIGuidePeople.levelStep then
            if UIShop.Widget then
                UIShop.getShopList(1)
            end
            UIManager.flushWidget(UITaskDay)
            UIManager.flushWidget(UIFightTaskChoose)
            UIManager.flushWidget(UIFight)
            UIManager.flushWidget(UIHomePage)
        end
        UIManager.flushWidget(UIActivityDailyDeals)
        -- UIHomePage.setBtnTimePoint(true)
        UIActivityVipWelfare.reset()
    end
end

----将进入后台的时间差值补回来----
local function updateAllSchduleAction()
    if utils.intervalTime > 0 then
        dp.updateTimer(utils.intervalTime)
        if utils.countDownScheduleId ~= nil then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(utils.countDownScheduleId)
            utils.countDownScheduleId = nil
            net.countDown = net.countDown - utils.intervalTime
            if net.countDown > 0 then
                utils.countDownScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(resetSceneTimes, tonumber(net.countDown), false)
            else
                resetSceneTimes()
            end
        end
        if UIShop.Widget ~= nil then
            UIShop.setTimeInterval(utils.intervalTime)
        end
        if UIActivityMiteer.Widget ~= nil then
            UIActivityMiteer.setTimeInterval(utils.intervalTime)
        end

        if UIActivityHJY.Widget then
            UIActivityHJY.setTimeInterval(utils.intervalTime)
        end

        if UILoot.Widget then
            UILoot.setTimeInterval(utils.intervalTime)
        end
        if UIArena.Widget then
            UIArena.updateTimer(utils.intervalTime)
        end
        UITeam.updateTimer(utils.intervalTime)
        if UIBoss.Widget then
            UIBoss.updateTimer(utils.intervalTime)
        end
        if UIAlliance.Widget then
            UIAlliance.updateTimer(utils.intervalTime)
        end
        if UIAllianceSkill.Widget then  
            UIAllianceSkill.updateTimer(utils.intervalTime)
        end
        if UIHomePage.Widget then
            UIHomePage.updateTimer(utils.intervalTime)
        end
        if UIActivityFireShop.Widget then
            UIActivityFireShop.updateTimer(utils.intervalTime)
        end
        if UIAllianceBoss.Widget then
            UIAllianceBoss.updateTimer(utils.intervalTime)
        end
        UIAllianceWar.updateTimer(utils.intervalTime)
        UIAllianceWarInfo.updateTimer(utils.intervalTime)
    end
end

----进入后台 -----------------
function applicationDidEnterBackground()
    cclog("applicationDidEnterBackground")
    --    if device.platform == "ios" then
    utils.enterBackgroundTime = os.time()
    --    else
    --     if netIsConnected() then
    -- 	    netSendPackage({header=StaticMsgRule.getSysTime, msgdata={}}, function(_msgData)
    -- 		    utils.enterBackgroundTime = utils.GetTimeByDate(_msgData.msgdata.string["1"])
    -- 	    end)
    --     end
    --    end
end

----进入前台 -----------------
function applicationWillEnterForeground()
    if not dp.musicSwitch then
        AudioEngine.pauseMusic()
    end
    cclog("applicationWillEnterForeground")
    --    if device.platform == "ios" then
    utils.intervalTime = os.time() - utils.enterBackgroundTime
    cclog("utils.intervalTime= " .. utils.intervalTime)
    if utils.enterBackgroundTime ~= 0 then
        updateAllSchduleAction()
    end
    --    else
    --     if netIsConnected() then
    -- 	    netSendPackage({header=StaticMsgRule.getSysTime, msgdata={}}, function(_msgData)
    -- 		    utils.intervalTime = utils.GetTimeByDate(_msgData.msgdata.string["1"]) - utils.enterBackgroundTime
    -- 		    cclog("utils.intervalTime= " ..utils.intervalTime)
    -- 		    if utils.enterBackgroundTime ~= 0 then
    -- 			    updateAllSchduleAction()
    -- 		    end
    -- 	    end)
    --     end
    --    end

    if SHOW_VIDEO then
        if device.platform == "ios" and UIManager.videoPlayer then
            UIManager.videoPlayer:resume()
            UIManager.videoPlayer = nil
        end
    end
    net.checkResUpdate()
end

xpcall(main, __G__TRACKBACK__)
