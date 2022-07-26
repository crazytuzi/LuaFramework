require"Lang"
require "cocos.cocos2d.json"

net = {
    openId = nil,
}

-- 定义发送数据包的默认版本号
NET_MSG_VERSION_DEFAULT = 2

local heartBeatInterval = 60 -- 单位：秒
local heartBeatScheduleId = nil
local heartBeatTime_ = nil

local _isCloseServer = false
local _isErrorLogin = false
local _disconnect = false
local _netCallbackFuncs = { }
local _errorCallbackFuncs = { }
local _isShowErrorToastMsg = false
local _isNoShowErrorToast = false
local http = nil
local hasPromptUpdateDialog = false
local VERSION_FILE = "version"

local function showPromptDialog(info)
    local visibleSize = cc.Director:getInstance():getVisibleSize()

    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(500, 300))
    bg_image:setPosition(visibleSize.width / 2, visibleSize.height / 2)
    local bgSize = bg_image:getPreferredSize()

    local dialog = ccui.Layout:create()
    dialog:setContentSize(UIManager.screenSize)
    dialog:setTouchEnabled(true)
    dialog:setSwallowTouches(true)
    dialog:addChild(bg_image)

    local title = ccui.Text:create()
    title:setString(Lang.net1)
    title:setFontSize(35)
    title:setFontName(dp.FONT)
    title:setTextColor(cc.c4b(255, 255, 0, 255))
    title:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.85))
    bg_image:addChild(title)
    local msgLabel = ccui.Text:create()
    msgLabel:setString(info)
    msgLabel:setFontName(dp.FONT)
    msgLabel:setTextAreaSize(cc.size(425, 300))
    msgLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setFontSize(26)
    msgLabel:setTextColor(cc.c4b(255, 255, 255, 255))
    msgLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.6))
    bg_image:addChild(msgLabel)

    local sureBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
    sureBtn:setTitleText(Lang.net2)
    sureBtn:setTitleFontName(dp.FONT)
    sureBtn:setTitleColor(cc.c3b(255, 255, 255))
    sureBtn:setTitleFontSize(25)
    sureBtn:setPressedActionEnabled(true)
    sureBtn:setTouchEnabled(true)
    sureBtn:setPosition(bgSize.width / 2, bgSize.height * 0.25)
    bg_image:addChild(sureBtn)

    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == sureBtn then
                cc.JNIUtils:exitGame()
            end
            UIManager.uiLayer:removeChild(dialog, true)
        end
    end

    sureBtn:addTouchEventListener(btnEvent)

    cc.Director:getInstance():getRunningScene():addChild(dialog, 10000)
end

local function onCheckVersion()
    if http and http.status == 200 then
        local internalVersionFile = cc.FileUtils:getInstance():fullPathForFilename(VERSION_FILE)
        local externalVersionFile = device.writablePath .. VERSION_FILE
        local useExternal = cc.FileUtils:getInstance():isFileExist(externalVersionFile)
        local downloadResourceVersion = tonumber(http.response)
        local localResourcesVersion = tonumber(cc.FileUtils:getInstance():getStringFromFile(useExternal and externalVersionFile or internalVersionFile))
        if downloadResourceVersion > localResourcesVersion then
            showPromptDialog(Lang.net3)
            hasPromptUpdateDialog = true
        end
    end
    http = nil
end

local function onCheckForceUpdate()
    if http and http.status == 200 then
        local response = json.decode(http.response)
        local code = response.code
        local message = response.message

        if code == 2 or code == 4 then
            -- 强更 or 验证异常
            showPromptDialog(message)
            hasPromptUpdateDialog = true
        else
            -- 有包更新 or 不需要强更
            local updateUrl = response.res_url

            if string.byte(updateUrl, #updateUrl, #updateUrl) ~= '/' then
                updateUrl = updateUrl .. "/"
            end

            http = cc.XMLHttpRequest:new()
            http.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
            http:registerScriptHandler(onCheckVersion)
            http:open("GET", updateUrl .. VERSION_FILE)
            http:send()
            return
        end
    end
    http = nil
end

local resUpdateId = nil
local function doCheckForceUpdate()
    local di = SDK.getDeviceInfo()
    http = cc.XMLHttpRequest:new()
    http.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    http:registerScriptHandler(onCheckForceUpdate)
    http:open("GET", "http://dpver.huayigame.com/501?" ..
    "channel_id=" .. cc.JNIUtils:getChannelId() ..
    "&product_id=" .. cc.JNIUtils:getProductId() ..
    "&code_version=" .. dp.PROGRAM_VER ..
    "&imei=" ..(di.imei or "") ..
    "&phone_code=" ..(di.phone_code or "") ..
    "&screen_width=" ..(di.screen_width or di.screenWidth or "") ..
    "&screen_height=" ..(di.screen_height or di.screenHeight or "") ..
    "&os_version=" ..(di.devOS or di.systemVersion or "") ..
    "&udid=" ..(di.udid or "") ..
    "&mac=" ..(di.mac or di.macAddr or "") ..
    "&ua=" .. string.urlencode(di.ua or "") ..
    "&serial_code=" ..(di.serial_code or "") ..
    "&channel_sub=" ..(di.packageName or ""))
    http:setRequestHeader("Content-Type", "application/octet-stream")
    http:send()
    if resUpdateId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(resUpdateId)
        resUpdateId = nil
    end
end

function net.checkResUpdate()
    if device.platform == "windows" or hasPromptUpdateDialog then return end
    if not resUpdateId then
        resUpdateId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(doCheckForceUpdate, 1, false)
    end
end

local function heartBeatUpdate(dt)
    if heartBeatTime_ == nil then
        heartBeatTime_ = os.time()
    end
    if tonumber(os.time()) - tonumber(heartBeatTime_) >= heartBeatInterval then
        heartBeatTime_ = os.time()
        local heartBeatData = {
            header = StaticMsgRule.heartbeat,
            msgdata =
            {
            }
        }
        netSendPackage(heartBeatData)
    end
end

local function stopHeartBeat()
    if heartBeatScheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(heartBeatScheduleId)
        heartBeatScheduleId = nil
        heartBeatTime_ = nil
    end
end

function net.connect(ip, port, openId, params)
    UIManager.showLoading()
    net.ip = ip
    net.port = port
    net.openId = openId
    net.params = params
    net.timeout = 0
    -- 永不超时
    netConnect(ip, port, net.timeout)
end

function netConnect(ip, port, timeout)
    cc.SocketClient:getInstance():connect(ip, port, timeout)
end

function netDisconnect()
    stopHeartBeat()
    cc.SocketClient:getInstance():disconnect()
    _disconnect = false
    cclog("-------->>>  socket连接断开！")
end

function netIsConnected()
    return cc.SocketClient:getInstance():isConnected()
end

function netOnConnected()
    cclog("-------->>>  socket连接成功！")

    local product_id = cc.JNIUtils:getProductId()

    local deviceInfo = SDK.getDeviceInfo()
    if device.platform == "ios" then
        deviceInfo.devOs = deviceInfo.systemName
    end
    local msgdata = {
        string =
        {
            openId = net.openId,
            zoneid = dp.serverId,
            channel = "",
            -- 应用宝qq/wx保留
            token = net.params,
            aloneServerId = product_id,
            clientVersion = (dp.PROGRAM_VER and dp.PROGRAM_VER or ""),
            devOs = (deviceInfo.devOs and deviceInfo.devOs or ""),
            imei = (deviceInfo.imei and deviceInfo.imei or ""),
            idfa = (deviceInfo.idfa and deviceInfo.idfa or ""),
            ua = (deviceInfo.currentDeviceModel and deviceInfo.currentDeviceModel or ""),
            connecttype = (deviceInfo.netState and deviceInfo.netState or "")
        }
    }


print( "netstate :" , deviceInfo.netState , "ua:" , deviceInfo.currentDeviceModel)
    if _disconnect then
        utils.disCount = 0
        _disconnect = false
        netSendPackage( { msgdata = msgdata, header = StaticMsgRule.relink, })
        UIGiftRecharge.checkPay()
    else
        netSendPackage( { msgdata = msgdata, header = StaticMsgRule.login, })
    end
    heartBeatScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(heartBeatUpdate, 0, false)
end

function netOnConnectFailed()
    UIManager.hideLoading()
    cclog("-------->>>  socket连接失败！")
    if _disconnect then
        utils.netErrorDialog(Lang.net4)
    elseif _isCloseServer then
        UIManager.showToast(Lang.net5)
    else
        UIManager.showToast(Lang.net6)
    end
end

function netOnConnectTimeout()
    cclog("-------->>>  socket连接超时！")
    stopHeartBeat()
end

function netOnDisconnected()
    cclog("-------->>>  socket连接中断！")
    if not _isCloseServer then
        if _isErrorLogin then
            utils.netErrorDialog(Lang.net7, true)
            _isErrorLogin = false
        else
            _disconnect = true
            utils.netErrorDialog(Lang.net8)
        end
    end
    stopHeartBeat()
end

function netSendPackage(pack, netCallbackFunc, errorCallbackFunc, isShowErrorToastMsg , isNoShowErrorToast )
    cc.SocketClient:getInstance():sendPackage(pack)
    heartBeatTime_ = os.time()
    _netCallbackFuncs[pack.header] = netCallbackFunc
    _errorCallbackFuncs[pack.header] = errorCallbackFunc
    _isShowErrorToastMsg =(isShowErrorToastMsg == nil) and false or isShowErrorToastMsg
    _isNoShowErrorToast =(isNoShowErrorToast == nil) and false or isNoShowErrorToast
end

-- 网络数据包序号错误
function netOnSequenceError()
end

-- 网络数据包校验和错误
function netOnChecksumError()
end

function netOnPackage(pack)
    UIManager.hideLoading()
    if not dp.RELEASE then
        cclog("=================[服务器返回的数据包]=================")
        if pack.header ~= StaticMsgRule.unionReplay then
            utils.recursionTab(pack, "pack")
        end
        cclog("=================[服务器返回的数据包]=================")
    end
    if pack.msgdata.int and tonumber(pack.msgdata.int.isOk) == 0 then
        if pack.msgdata.string.retMsg ~= "" then
            if pack.msgdata.string.retMsg == Lang.net9 then
                _isErrorLogin = true
            elseif pack.msgdata.string.retMsg == ":" then
                -- 重连时验证Token失效了
                utils.netErrorDialog(Lang.net10, -1)
            else
                if pack.msgdata.string.retMsg == Lang.net11 then
                    netDisconnect()
                else
                    local protoCode = tonumber(pack.header)
                    if _errorCallbackFuncs[protoCode] then
                        _errorCallbackFuncs[protoCode](pack)
                    end
                    _errorCallbackFuncs[protoCode] = nil
                end
                if not _isNoShowErrorToast and pack.msgdata.string.retMsg ~= "hide" then
                    UIManager.showToast(pack.msgdata.string.retMsg, _isShowErrorToastMsg)
                end
                _isShowErrorToastMsg = false
                _isNoShowErrorToast = false
            end
        end
        if tonumber(pack.header) == StaticMsgRule.guidStep then
            UIGuidePeople.isSuccess = true
        end
    else
        local protoCode = tonumber(pack.header)
        cclog( "protoCode :"..protoCode )
        if protoCode == StaticMsgRule.updateData then
            if pack.msgdata and pack.msgdata.message then
                local beforeLevel = net.InstPlayer.int["4"]
                -- 等级
                local isFresh = false
                local isFreshFightSoul = false
                local isFreshFightSoulHunt = false
                local isFreshHoldStar = false
                local isFreshHomePage = false
                -- zy 修改申请加入联盟停留在主页面，被盟主批准后，“招人了”图标及时消失
                for key, obj in pairs(pack.msgdata.message) do
                    local tableName, flag, instId = obj.string.a, obj.string.b, obj.int.c
                    if flag == "add" then
                        local _isFilter = false
                        if net.FilterData then
                            for _filterKey, _filterObj in pairs(net.FilterData) do
                                if tableName == _filterObj then
                                    -- net[tableName] = obj.message[tostring(instId)]
                                    net[tableName] = { }
                                    for _k, _obj in pairs(obj.message[tostring(instId)]) do
                                        net[tableName][_k] = _obj
                                    end
                                    _isFilter = true
                                    break
                                end
                            end
                        end
                        if not _isFilter then
                            if net[tableName] == nil then
                                net[tableName] = { }
                            end
                            net[tableName][tostring(instId)] = obj.message[tostring(instId)]
                        end
                        if tableName == "InstPlayerAward" then
                            UIManager.flushWidget(UIHomePage)
                            UIManager.flushWidget(UIAwardGift)
                        end
                        if tableName == "InstPlayerMail" then
                            UIManager.flushWidget(UIActivityEmail)
                            UIManager.flushWidget(UIOreEmail)
                            if UIHomePage.Widget then
                                UIHomePage.yj = 1
                                UIManager.flushWidget(UIHomePage)
                            end
                            if UIOre.Widget then
                                UIOre.yj = 1
                                UIManager.flushWidget(UIOre)
                            end
                        end
                    elseif flag == "delete" then
                        -- if net[tableName][tostring(instId)] == nil then
                        --  net[tableName] = nil
                        -- end
                        local _isFilter = false
                        if net.FilterData then
                            for _filterKey, _filterObj in pairs(net.FilterData) do
                                if tableName == _filterObj then
                                    _isFilter = true
                                    break
                                end
                            end
                        end
                        if _isFilter then
                            net[tableName] = nil
                        else
                            net[tableName][tostring(instId)] = nil
                        end
                    elseif flag == "update" then
                        for k_, data in pairs(obj.message[tostring(instId)]) do
                            for i_, value in pairs(data) do
                                if net[tableName] then
                                    if tableName == "InstUnionMember" then
                                        -- zy 修改申请入盟被批准后报错的问题
                                        if net[tableName][k_] == nil then
                                            net[tableName][k_] = { }
                                        end
                                        net[tableName][k_][i_] = value
                                    elseif net[tableName][tostring(instId)] then
                                        -- cclog("tableName:"..tableName.."instId :"..instId.. " _k ".. " type  ".. type(k_) ..k_.." _i ".." type  ".. type(i_)..i_.."  value "..value.." "..type(value) )
                                        net[tableName][tostring(instId)][k_][i_] = value
                                    else
                                        if net[tableName][k_] == nil then
                                            net[tableName][tostring(instId)] = { k_ = data }
                                        else
                                            net[tableName][k_][i_] = value
                                        end
                                    end
                                end
                            end
                        end


                    end
                    -----元宝实时更新
                    if tableName == "InstPlayer" then
                        UIManager.flushWidget(UITowerTest)
                        UIManager.flushWidget(UITowerStrong)
                        UIManager.flushWidget(UITeamInfo)
                        if UIShop.Widget and UIShop.Widget:getParent() then
                            ccui.Helper:seekNodeByName(UIShop.Widget, "text_gold_number"):setString(tostring(net.InstPlayer.int["5"]))
                        end
                        if UIActivityFund.Widget and UIActivityFund.Widget:getParent() then
                            UIManager.flushWidget( UIActivityFund )
                        end
                        if UIActivitySeven.Widget and UIActivitySeven.Widget:getParent() then
                            UIActivitySeven.setup()
                        end
                        if UIActivitySevenNew.Widget and UIActivitySevenNew.Widget:getParent() then
                            UIActivitySevenNew.setup()
                        end
                    elseif tableName == "InstActivity" then
                        if not isFresh then
                            isFresh = true
                        end
                    elseif tableName == "InstPlayerFightSoul" then
                        if not isFreshFightSoul then
                            isFreshFightSoul = true
                        end
                    elseif tableName == "InstPlayerFightSoulHuntRule" then
                        if not isFreshFightSoulHunt then
                            isFreshFightSoulHunt = true
                        end
                    elseif tableName == "InstUnionMember" then
                        if not isFreshHomePage then
                            isFreshHomePage = true
                        end
                    elseif tableName == "InstUnionLootDyna" then
                        UIAllianceEscort.updateEscortDyna()
                    end
                    if tableName == "InstPlayerHoldStar" then
                        if not isFreshHoldStar then
                            isFreshHoldStar = true
                        end
                    end
                end
                if isFreshHoldStar then
                    UIStar.checkImageHint()
                    UIManager.flushWidget(UIStar)
                    --  UIManager.flushWidget(UIStarLighten)
                    UIManager.flushWidget(UIStarReward)
                end
                if isFreshHomePage then
                    UIManager.flushWidget(UIHomePage)
                end
                if isFresh then
                    UIManager.flushWidget(UIActivityCard)
                    UIManager.flushWidget(UIActivityHJY)
                end
                ---------------猎魂------
                if isFreshFightSoul then
                    UIManager.flushWidget(UISoulGet)
                end
                if isFreshFightSoulHunt then
                    if UISoulGet.Widget and UISoulGet.Widget:getParent() then
                        UISoulGet.freshImageCare()
                    end
                end
                -----------判断是否升级------------
                local nowLevel = net.InstPlayer.int["4"]
                if nowLevel > beforeLevel then
                    utils.beforeLevel = beforeLevel
                    utils.LevelUpgrade = true
                    SDK.doUpgradeEvent(tostring(nowLevel))
                end

                ---------------------------
            end
        elseif protoCode == StaticMsgRule.heartbeat then
            cclog("------------>>>  心跳检测")
        elseif protoCode == StaticMsgRule.pushRechargeSucc then
            cclog("------------>>>  充值成功")
            SDK.doPaySuccessTD(pack.msgdata.string["1"])
            local orderID = pack.msgdata.string["1"]
            local count = ""
            if pack.msgdata.int and pack.msgdata.int["2"] then
                count = pack.msgdata.int["2"]
            end
            local role = dp.getUserData()
            SDK.reYunOnPay( { roleId = role.roleId , orderId = orderID , amount = count } )
            --zhangyue统计
            SDK.zhangYueOnPay( { roleId = role.roleId , roleName = role.roleName ,orderId = orderID , amount = count } )
            if UIActivityFund.Widget and UIActivityFund.Widget:getParent() then
                UIManager.flushWidget( UIActivityFund )
            end
            UIActivityRecharge.checkImageHint(UIActivityRecharge.flushTitleHint)
            if UIActivityVip.flushTitleHint then UIActivityVip.flushTitleHint(UIActivityVip.checkImageHint()) end
            UIActivityVipWelfare.checkImageHint(UIActivityVipWelfare.flushTitleHint)
        else
            if protoCode == StaticMsgRule.login then
                net.accountId = pack.msgdata.string.accountId
              -- cclog("uid-----------"..net.accountId)
                require("fight").tryPreload()
                net.InstPlayer = pack.msgdata.message.InstPlayer
                if net.GameDataTable == nil then
                    net.GameDataTable = { }
                    net.GameDataTable[#net.GameDataTable + 1] = "InstPlayer"
                end
                net.loadGameData(pack)
                if pack.msgdata.string and pack.msgdata.string.name then
                    UIName.defaultName = pack.msgdata.string.name
                    -- 默认昵称
                end
                UITeam.initRecoverState(pack.msgdata.message.energy.int["1"], pack.msgdata.message.vigor.int["1"])
                dp.startTimer()
                -- if pack.msgdata.string.DailyDealState and pack.msgdata.string.DailyDealState == "1" then
                -- UIHomePage.setBtnTimePoint(false)
                -- else
                -- UIHomePage.setBtnTimePoint(true)
                -- end
                if pack.msgdata.string.registerTime then
                    net.InstPlayer.registerTime = pack.msgdata.string.registerTime
                end
                UIHomePage.actLimitRecInfo = pack.msgdata.string.actLimitRecInfo
                if net.InstPlayer.string["3"] == "" then
                    -- 名称为空
                    UIManager.splashVideo()
                else
                    UIGuidePeople.setGuide()
                end
                UIGiftRecharge.checkPay()
                UIShop.disCount = pack.msgdata.int["multipleExp"] / 100
                cclog("UIShop.disCount :" .. UIShop.disCount)
                if UIMenu and UIMenu.Widget then
                    UIMenu.refreshIcon()
                end
                if pack.msgdata.int.closeServerTime then
                    UIHomePage.showCloseServerDialog(pack.msgdata.int.closeServerTime)
                end
                if pack.msgdata.string.fireFamIcon and tonumber( pack.msgdata.string.fireFamIcon ) == 1 then
                    net.isShowFireTip = true
                else
                    net.isShowFireTip = false
                end
                UIHomePage.fireShow()
                UITalk.chatInfo = { }
                UITalk.chatInfo_unio = { }
                UITalk.chatInfo_user = { }
                -- cc.JNIUtils:yvSetConfigServerId(tostring(dp.serverId))
                -- cc.JNIUtils:yvCpLogin(string.format("{\"nickname\":\"%s\",\"uid\":\"%s\"}", net.InstPlayer.string["3"], net.InstPlayer.string["2"]))
            elseif protoCode == StaticMsgRule.pushCloseServerData then
                if pack.msgdata.string and pack.msgdata.string["1"] then
                    _isCloseServer = true
                    utils.netErrorDialog(pack.msgdata.string["1"], true)
                else
                    UIHomePage.showCloseServerDialog(pack.msgdata.int["2"])
                end
            elseif protoCode == StaticMsgRule.pushWorldBossData then
                if UIBoss.Widget and UIBoss.Widget:getParent() then
                    UIBoss.pushData(pack)
                end
            elseif protoCode == StaticMsgRule.pushUnionBoss then
                if UIAllianceBoss.Widget and UIAllianceBoss.Widget:getParent() then
                    UIAllianceBoss.pushData(pack)
                end
            elseif protoCode == StaticMsgRule.pushChatData then
                -- if UITalk.Widget then
                UITalk.pushData(pack)
                -- end
            elseif protoCode == StaticMsgRule.pushRunningTor then
                cclog( "推送小乌龟！" )
                if UIAllianceRun.Widget and UIAllianceRun.Widget:getParent() then
                    UIAllianceRun.pushData( pack )
                end
            elseif protoCode == StaticMsgRule.pushLimitRecharge then
                if UIHomePage.actLimitRecInfo then
                    local _state = pack.msgdata.int.state
                    UIHomePage.actLimitRecInfo = string.sub(UIHomePage.actLimitRecInfo, 1, string.len(UIHomePage.actLimitRecInfo) - 1) .. _state
                    if _state == 1 then
                        if UIHomePage.Widget and UIHomePage.Widget:getParent() then
                            UIHomePage.setBtnLimitPoint(true)
                        end
                    end
                    if UIActivityLimit.Widget and UIActivityLimit.Widget:getParent() then
                        UIActivityLimit.setup()
                    end
                end
            elseif protoCode == StaticMsgRule.pushMarquee then
                -- 推送跑马灯
                local param = { }
                if pack.msgdata.string["1"] ~= "" then
                    table.insert(param, pack.msgdata.string["1"])
                end
                if pack.msgdata.string["2"] ~= "" then
                    table.insert(param, pack.msgdata.string["2"])
                end
                table.insert(UINotice.preViewThing, param)
            elseif protoCode == StaticMsgRule.push1314 then
                cclog("1314朵鲜花推送")
                --1314朵鲜花推送
                UIHomePage.showFlower()
                UIActivityGoddess.showFlower()
            elseif protoCode == StaticMsgRule.pushUnionWar then
                UIWar.onWarEvent(pack.msgdata)
            elseif protoCode == StaticMsgRule.pushOverLord then
                UIAllianceWar.refresh(pack.msgdata)
            else
                local callback = _netCallbackFuncs[protoCode]
                if callback then
                    callback(pack)
                    if callback == _netCallbackFuncs[protoCode] then
                        _netCallbackFuncs[protoCode] = nil
                    end
                end
            end
            if utils.isChangeFightValue(protoCode) then
                netSendPackage( { header = StaticMsgRule.fightValue, msgdata = { int = { fightValue = utils.getFightValue() } } })
            end
        end
    end
end

function checkNetCallbackFuncs(protoCode)
    return _netCallbackFuncs[protoCode]
end

-- @pack
-- @tableName
-- @isFilter true--在数据库表中一个玩家只拥有一条记录,false--在表中一个玩家可以拥有多条记录
local function addInstTable(pack, tableName, isFilter)
    if pack.msgdata.message[tableName] and pack.msgdata.message[tableName].message then
        net[tableName] = pack.msgdata.message[tableName].message
    end
    if isFilter then
        if pack.msgdata.message[tableName] then
            if net[tableName] then
                local _tempData = nil
                for key, obj in pairs(net[tableName]) do
                    _tempData = obj
                end
                net[tableName] = _tempData
            end
        end
        if net.FilterData == nil then
            net.FilterData = { }
        end
        net.FilterData[#net.FilterData + 1] = tableName
    end
    net.GameDataTable[#net.GameDataTable + 1] = tableName
end

function net.loadGameData(pack)
    addInstTable(pack, "InstPlayerCard")
    addInstTable(pack, "InstPlayerFormation")
    addInstTable(pack, "InstPlayerPagoda", true)
    addInstTable(pack, "InstPlayerArena", true)
    addInstTable(pack, "InstPlayerArenaConvert")
    addInstTable(pack, "InstPlayerEquip")
    addInstTable(pack, "InstPlayerLineup")
  --  addInstTable(pack, "InstPlayerPartner")
    addInstTable(pack, "InstPlayerTrain")
    addInstTable(pack, "InstPlayerWash")
    addInstTable(pack, "InstPlayerThing")
    addInstTable(pack, "InstPlayerKungFu")
    addInstTable(pack, "InstPlayerFire")
    addInstTable(pack, "InstPlayerPill")
    addInstTable(pack, "InstPlayerPillRecipe")
    addInstTable(pack, "InstPlayerPillRecipeThing")
    addInstTable(pack, "InstPlayerPillThing")
    addInstTable(pack, "InstPlayerConstell")
    addInstTable(pack, "InstPlayerBagExpand")
    addInstTable(pack, "InstEquipGem")
    addInstTable(pack, "InstPlayerChapter")
    addInstTable(pack, "InstPlayerChapterType")
    addInstTable(pack, "InstPlayerBarrier")
    addInstTable(pack, "InstChapterActivity")
    addInstTable(pack, "InstPlayerCardSoul")
    addInstTable(pack, "InstPlayerLoot")
    addInstTable(pack, "InstPlayerChip")
    addInstTable(pack, "InstPlayerManualSkill")
    addInstTable(pack, "InstPlayerManualSkillLine", true)
    addInstTable(pack, "InstActivity")
    addInstTable(pack, "InstAuctionShop")
    addInstTable(pack, "InstActivityOnlineRewards")
    addInstTable(pack, "InstActivityOpenServiceBag")
    addInstTable(pack, "InstActivityLevelBag")
    addInstTable(pack, "InstHJYStore")
    addInstTable(pack, "SysActivity")
    addInstTable(pack, "InstActivitySignIn")
    addInstTable(pack, "InstPlayerAward")
    addInstTable(pack, "InstPlayerMagic")
    addInstTable(pack, "InstPlayerDailyTask")
    addInstTable(pack, "InstPlayerAchievement")
    addInstTable(pack, "InstPlayerAchievementValue")
    addInstTable(pack, "InstPlayerBeautyCard")
    addInstTable(pack, "InstPlayerMail")
    addInstTable(pack, "InstPlayerGrabTheHour")
    addInstTable(pack, "InstPlayerPrivateSale")
    addInstTable(pack, "InstUnionMember", true)
    addInstTable(pack, "InstUnionApply")
    addInstTable(pack, "InstUnionBox", true)
    addInstTable(pack, "InstUnionPractice", true)
    addInstTable(pack, "InstPlayerTryToPractice", true)
    addInstTable(pack, "DictActivityBanner")
    addInstTable(pack, "InstPlayerFightSoul")
    addInstTable(pack, "InstPlayerFightSoulHuntRule")
    addInstTable(pack, "InstPlayerYFire")
    addInstTable(pack, "InstPlayerWing")
    addInstTable(pack, "InstPlayerRedEquip")
    addInstTable(pack, "InstPlayerHoldStar")
    addInstTable(pack, "InstPlayerPartnerLuckPos")
    addInstTable(pack, "InstUnionLootDyna")
    addInstTable(pack, "InstActivityPerfectVictory")
    addInstTable(pack, "InstPlayerEquipBox")
    addInstTable(pack, "InstPlayerEnchantment" , true)

    if pack.msgdata.int.yj then
        -- 有邮件
        UIHomePage.yj = pack.msgdata.int.yj
    end
    if pack.msgdata.string.dateTime then
        net.serverLoginTime = pack.msgdata.string.dateTime
        --- 服务器传过来的当前时间
        net.LoginTime = os.time()
        ----本地登录时间
        utils.time_stamp = os.time()
        local tableTime = utils.changeTimeFormat(net.serverLoginTime)
        dp.loginDay = tonumber(tableTime[3])
        net.countDown = 24 * 3600 - tonumber(tableTime[4])
        --- 距离24点剩余的时间
        utils.countDownScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(resetSceneTimes, tonumber(net.countDown), false)
        --- 隔天重置体力和耐力-----
        -- if net.InstPlayer  then
        -- 	if net.InstPlayer.string["27"] ~= "" then
        -- 		local EnemyTableTime =utils.changeTimeFormat(net.InstPlayer.string["27"])
        -- 		if tonumber(tableTime[3]) ~= tonumber(EnemyTableTime[3])  then
        -- 			net.InstPlayer.int["25"] =0
        -- 		end
        -- 	end
        -- 	if net.InstPlayer.string["28"] ~= "" then
        -- 		local VigorTableTime =utils.changeTimeFormat(net.InstPlayer.string["28"])
        -- 		if tonumber(tableTime[3]) ~= tonumber(VigorTableTime[3])  then
        -- 			net.InstPlayer.int["26"] =0
        -- 		end
        -- 	end
        -- end
        --------------签到-------------
        if net.InstActivitySignIn then
            for key, obj in pairs(net.InstActivitySignIn) do
                if obj.string["8"] ~= "" and obj.int["3"] == 1 then
                    local updateTime = obj.string["8"]
                    local TableTime = utils.changeTimeFormat(updateTime)
                    if tonumber(tableTime[2]) ~= tonumber(TableTime[2]) then
                        obj.int["4"] = 0
                        -- 签到天数
                        obj.int["5"] = 0
                        -- 是否领取双倍奖励
                    end
                end
            end
        end
        -------------隔天重置天焚炼气塔重置和搜寻次数-------------
        if net.InstPlayerPagoda then
            if net.InstPlayerPagoda.string["8"] ~= "" then
                -- 操作时间不为空
                local _timeT = utils.changeTimeFormat(net.InstPlayerPagoda.string["8"])
                if tonumber(tableTime[3]) ~= tonumber(_timeT[3]) then
                    --[[

					local searchNum, resetNum = 0, 0

					for vipKey, vipObj in pairs(DictVIP) do

						if net.InstPlayer.int["19"] == vipObj.level then

							searchNum = vipObj.pagodaSearchNum

							resetNum = vipObj.pagodaResetNum

							break

						end

					end

					net.InstPlayerPagoda.int["5"] = resetNum

					net.InstPlayerPagoda.int["6"] = searchNum

					--]]
                    net.InstPlayerPagoda.int["5"] = 0
                    -- 重置次数
                    net.InstPlayerPagoda.int["6"] = 0
                    -- 搜寻次数
                end
            end
        end
        -------隔天重置竞技场可兑换物品的兑换次数-------
        if net.InstPlayerArenaConvert then
            for ipacKey, ipacObj in pairs(net.InstPlayerArenaConvert) do
                if ipacObj.string["5"] ~= "" then
                    -- 操作时间不为空
                    local _tempTime = utils.changeTimeFormat(ipacObj.string["5"])
                    if tonumber(tableTime[3]) ~= tonumber(_tempTime[3]) and DictArenaConvert[tostring(ipacObj.int["3"])].convertType ~= 1 then
                        ipacObj.int["4"] = 0
                        -- 兑换次数
                    end
                end
            end
        end
        -----隔天重置各个副本关卡的挑战次数-----
        if net.InstPlayerBarrier then
            for key, obj in pairs(net.InstPlayerBarrier) do
                if obj.string["8"] ~= "" then
                    -- 操作时间不为空
                    local updateTime = obj.string["8"]
                    local TableTime = utils.changeTimeFormat(updateTime)
                    if tonumber(tableTime[3]) ~= tonumber(TableTime[3]) then
                        obj.int["4"] = 0
                        -- 已战斗次数
                    end
                end
            end
        end
        -----隔天重置各个副本类型的挑战次数------
        if net.InstPlayerChapterType then
            for key, obj in pairs(net.InstPlayerChapterType) do
                if obj.string["7"] ~= "" then
                    -- 操作时间不为空
                    local updateTime = obj.string["7"]
                    local TableTime = utils.changeTimeFormat(updateTime)
                    if tonumber(tableTime[3]) ~= tonumber(TableTime[3]) then
                        obj.int["4"] = 0
                        -- 已挑战次数
                    end
                end
            end
        end
        -----隔天重置各个副本章节的挑战次数
        if net.InstPlayerChapter then
            for key, obj in pairs(net.InstPlayerChapter) do
                if obj.string["9"] ~= "" then
                    -- 操作时间不为空
                    local updateTime = obj.string["9"]
                    local TableTime = utils.changeTimeFormat(updateTime)
                    if tonumber(tableTime[3]) ~= tonumber(TableTime[3]) then
                        obj.int["4"] = 0
                        -- 已挑战次数
                    end
                end
            end
        end
    end
end
