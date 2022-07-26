require"Lang"
UIAlliance = { }

local unionDetail = nil
local _unionDynamicPersion = nil
local _countdownTime = 0

local netCallbackFunc = nil

local function scrollUnionDynamic(strDynamic)
    local fontSize = 23
    local scrollSpeed = 10
    local dynamicStrs = UIAllianceDynamic.getDynamicStrings(strDynamic)
    if dynamicStrs and #dynamicStrs > 0 then
        local _randomSize = (#dynamicStrs > 5) and 5 or #dynamicStrs
        local scrollText = nil
        local _randoms = utils.randoms(1, _randomSize, _randomSize)
        local _showIndex = 1
        scrollText = function()
            if dynamicStrs[_randoms[_showIndex]] == nil then
                return
            end
            local layout = ccui.Layout:create()
            local _width = 0
            local _height = 0
            local richText = utils.richTextFormat(dynamicStrs[_randoms[_showIndex]])
            for key, obj in pairs(richText) do
                local text = ccui.Text:create()
                text:setString(obj.text)
	            text:setFontName(dp.FONT)
	            text:setFontSize(fontSize)
	            text:setTextColor(obj.color)
                text:setAnchorPoint(cc.p(0, 0))
                text:setPosition(cc.p(_width, 0))
                layout:addChild(text)
                _width = _width + text:getContentSize().width
                if _height < text:getContentSize().height then
                    _height = text:getContentSize().height
                end
            end
            richText = nil
            layout:setContentSize(cc.size(_width, _height))
            local image_basemap = UIAlliance.Widget:getChildByName("image_basemap")
            local noticePanel = image_basemap:getChildByName("image_hint"):getChildByName("panel")
            layout:setPosition(cc.p(noticePanel:getContentSize().width, 0))
            noticePanel:addChild(layout)
            layout:runAction(cc.Sequence:create(cc.MoveTo:create(scrollSpeed, cc.p(-_width, 0)) , cc.CallFunc:create(function()
                _showIndex = _showIndex + 1
                noticePanel:removeAllChildren()
                if _showIndex > _randomSize then
                    _randoms = utils.randoms(1, _randomSize, _randomSize)
                    _showIndex = 1
                end
                scrollText()
            end)))
        end
        scrollText()
    end
end

--创建首页云朵
local function createCloud()
    local cloudW = 500
    local cloudH = 328
    local maxY = UIManager.screenSize.height - cloudH / 2.0
    local minY = cloudH / 2.0
    local function getParam()
        local y = math.random(minY, maxY)
        local scale =(UIManager.screenSize.height - y) / UIManager.screenSize.height * 1.5
        if scale < 0.5 then
            scale = 0.5
        elseif scale > 1.5 then
            scale = 1.5
        end
        local actiontime =(UIManager.screenSize.height - y) / UIManager.screenSize.height * 50
        if actiontime < 20 then
            actiontime = 20
        elseif actiontime > 40 then
            actiontime = 40
        end
        return y, scale, actiontime
    end
    local function callBack(actionBody)
        actionBody:stopAllActions()
        local callBackY, callBackScale, callBackTime = getParam()
        actionBody:setPosition(cc.p(- cloudW / 2, callBackY))
        actionBody:setScale(callBackScale)
        actionBody:setOpacity(255)
        local action = cc.Sequence:create(cc.DelayTime:create(math.random(1, 3)), cc.Spawn:create(cc.MoveBy:create(callBackTime, cc.p(UIManager.screenSize.width, 0)),
        cc.Sequence:create(cc.DelayTime:create(callBackTime / 3 * 2.0), cc.FadeTo:create(callBackTime / 3.0, 0), cc.CallFunc:create(callBack))), cc.CallFunc:create(callBack))
        actionBody:runAction(action)
    end
    local function createAction(delayTime, time)
        local action = cc.Sequence:create(cc.DelayTime:create(delayTime), cc.Spawn:create(cc.MoveBy:create(time, cc.p(UIManager.screenSize.width, 0)),
        cc.Sequence:create(cc.DelayTime:create(time / 3 * 2.0), cc.FadeTo:create(time / 3.0, 0), cc.CallFunc:create(callBack))), cc.CallFunc:create(callBack))
        return action
    end
    local cloudTable = { cloud1 = nil, cloud2 = nil, cloud3 = nil }
    cloudTable.cloud1 = cc.Sprite:create("image/ui_home_cloud.png")
    cloudTable.cloud2 = cc.Sprite:create("image/ui_home_cloud.png")
    cloudTable.cloud3 = cc.Sprite:create("image/ui_home_cloud.png")
    local cloudY1, scale1, time1 = getParam()
    cloudTable.cloud1:setPosition(cc.p(- cloudW / 2 + 100, cloudY1))
    cloudTable.cloud1:setScale(scale1)
    cloudTable.cloud1:runAction(createAction(0, time1))
    UIAlliance.Widget:addChild(cloudTable.cloud1)
    local cloudY2, scale2, time2 = getParam()
    cloudTable.cloud2:setPosition(cc.p(- cloudW / 2 + 50, cloudY2))
    cloudTable.cloud2:setScale(scale2)
    cloudTable.cloud2:runAction(createAction(1, time2))
    UIAlliance.Widget:addChild(cloudTable.cloud2)
    local cloudY3, scale3, time3 = getParam()
    cloudTable.cloud3:setPosition(cc.p(- cloudW / 2 + 50, cloudY3))
    cloudTable.cloud3:setScale(scale3)
    cloudTable.cloud3:runAction(createAction(2, time3))
    UIAlliance.Widget:addChild(cloudTable.cloud3)
end

local function initAllianceInfo(_msgData)
    local image_basemap = UIAlliance.Widget:getChildByName("image_basemap")
    local image_base_notice = image_basemap:getChildByName("image_base_notice")
    local image_di_system = image_basemap:getChildByName("image_di_system")
    local image_di_name = image_di_system:getChildByName("image_di_name")
    local ui_allianceNotice = ccui.Helper:seekNodeByName(image_base_notice, "text_notice")
    local ui_allianceNoticeBtn = ccui.Helper:seekNodeByName(image_base_notice, "btn_revise")
    local ui_allianceIcon = ccui.Helper:seekNodeByName(image_di_name, "image_lm")
    local ui_allianceName = image_di_name:getChildByName("text_name")
    local ui_allianceLevel = image_di_name:getChildByName("text_lv")
    local ui_allianceLevelPanel = image_basemap:getChildByName("text_lv")
    local ui_allianceDevote = image_di_name:getChildByName("text_devote")
    local ui_alliancePractice = image_di_name:getChildByName("text_practice")
    local ui_allianceToken = image_di_name:getChildByName("text_token")
    local ui_hallUpBtn = image_basemap:getChildByName("image_hall_up")

    --default
    ui_allianceIcon:loadTexture("image/" .. DictUI[tostring(DictUnionFlag["1"].smallUiId)].fileName)
    ui_allianceName:setString("???")
    ui_allianceLevel:setString("LV.0")
    ui_allianceLevelPanel:setString("LV.0")
    ui_allianceDevote:setString(Lang.ui_alliance1)
    ui_alliancePractice:setString(Lang.ui_alliance2)
    ui_allianceToken:setString(Lang.ui_alliance3)
    ui_allianceNotice:setString("")
    ui_hallUpBtn:setVisible(false)
    unionDetail = nil

    unionDetail = UIAlliance.getUnionDetail(_msgData)
    if unionDetail then
        ui_allianceIcon:loadTexture("image/" .. DictUI[tostring(DictUnionFlag[tostring(unionDetail.iconId)].smallUiId)].fileName)
        ui_allianceName:setString(unionDetail.name)
        ui_allianceLevel:setString("LV." .. unionDetail.level)
        ui_allianceLevelPanel:setString("LV." .. unionDetail.level)
        ui_allianceDevote:setString(Lang.ui_alliance4 .. net.InstUnionMember.int["5"])
        ui_alliancePractice:setString(Lang.ui_alliance5 .. unionDetail.practiceValue)
        ui_allianceToken:setString(Lang.ui_alliance6 .. unionDetail.unionWand)
        ui_allianceNotice:setString(unionDetail.notice)
    end
    ui_allianceNoticeBtn:setVisible(false)
    local selfGradeId = net.InstUnionMember.int["4"]
    if selfGradeId == 1 or selfGradeId == 2 then
        ui_allianceNoticeBtn:setVisible(true)
        if unionDetail and DictUnionLevelPriv[tostring(unionDetail.level)].exp > 0 and unionDetail.exp >= DictUnionLevelPriv[tostring(unionDetail.level)].exp then
            ui_hallUpBtn:setVisible(true)
            ui_hallUpBtn:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    UIAlliance.showDialog(string.format(Lang.ui_alliance7, 
                        DictUnionLevelPriv[tostring(unionDetail.level)].exp, unionDetail.level + 1), function()
                        UIManager.showLoading()
                        netSendPackage( {
                            header = StaticMsgRule.unionHoleUpgrade,
                            msgdata = { int = { instUnionMemberId = net.InstUnionMember.int["1"] } }
                        } , function()
                            UIManager.showToast(string.format(Lang.ui_alliance8, unionDetail.level + 1))
                            UIAlliance.setup(true)
                        end)
                    end)
                end
            end)
        end
    end
end

netCallbackFunc = function(msgData)
    local code = tonumber(msgData.header)
    if code == StaticMsgRule.unionDetail then
        initAllianceInfo(msgData)
        _countdownTime = msgData.msgdata.int.seconds
    elseif code == StaticMsgRule.writeUnion then
        UIAlliance.setup(true)
    elseif code == StaticMsgRule.queryUnionWarOpen then
        local msgdata = msgData.msgdata
        if msgdata.int.state == 1 then
            UIWar.ambushReward = {}
            for i = 1, 3 do
                if msgdata.string and msgdata.string["rewardAmbush" .. i] and string.len(msgdata.string["rewardAmbush" .. i]) > 0 then
                    table.insert(UIWar.ambushReward, msgdata.string["rewardAmbush" .. i])
                else
                    break
                end
            end
            UIWar.allianceName = unionDetail.name
            UIManager.showScreen("ui_war", "ui_menu")
        else
            UIManager.showToast(msgdata.string and msgdata.string.strerror or Lang.ui_alliance9)
        end
    elseif code == StaticMsgRule.openOverlord then
        UIAllianceWar.show(msgData.msgdata)
    end
end

local function initPracticeRefreshTime()
    local _curTime = utils.getCurrentTime()
    local _date = os.date("*t", _curTime)
    -- 资金刷新时间： 20:30
    _date.hour = 20
    _date.min = 30
    _date.sec = 0
    local _startTimer = os.time(_date)
    if _curTime >= _startTimer then
        _countdownTime = 24 * 60 * 60 - _curTime + _startTimer
    else
        _countdownTime = _startTimer - _curTime
    end
end

local function practiceRefreshTime()
    _countdownTime = _countdownTime - 1
    if _countdownTime < 0 then
        _countdownTime = 0
    end
    if UIAlliance.Widget then
        local hour = math.floor(_countdownTime / 3600 % 24) --小时
	    local minute = math.floor(_countdownTime / 60 % 60) --分
	    local second = math.floor(_countdownTime % 60) --秒
        local image_basemap = UIAlliance.Widget:getChildByName("image_basemap")
        local ui_TextTime = image_basemap:getChildByName("image_di_skill"):getChildByName("text_skill_time")
        ui_TextTime:setString(string.format(Lang.ui_alliance10, hour, minute, second))
        if _countdownTime == 0 then
            initPracticeRefreshTime()
        end
    end
end

function UIAlliance.updateTimer(interval)
    if _countdownTime then
        _countdownTime = _countdownTime - interval
        if _countdownTime < 0 then
            _countdownTime = 0
        end
    end
end

function UIAlliance.init()
    local image_basemap = UIAlliance.Widget:getChildByName("image_basemap")
    local image_base_notice = image_basemap:getChildByName("image_base_notice")
    local image_di_system = image_basemap:getChildByName("image_di_system")
    local ui_allianceNotice = ccui.Helper:seekNodeByName(image_base_notice, "text_notice")
    local ui_allianceNoticeBtn = ccui.Helper:seekNodeByName(image_base_notice, "btn_revise")
    local btn_back = ccui.Helper:seekNodeByName(image_basemap, "btn_back")
    local btn_help = image_basemap:getChildByName("btn_help")
    local btn_assigned = image_basemap:getChildByName("btn_assigned")

    --联盟活动
    local panel_activity = image_basemap:getChildByName("panel_activity")

    --联盟大厅
    local panel_hall = image_basemap:getChildByName("panel_hall")

    --联盟商店
    local panel_shop = image_basemap:getChildByName("panel_shop")

    --联盟修炼
    local panel_skill = image_basemap:getChildByName("panel_skill")

    --联盟神兽
    local panel_animal = image_basemap:getChildByName("panel_animal")

    --联盟BOSS
    local panel_boss = image_basemap:getChildByName("panel_boss")

    --联盟任务
    local panel_task = image_basemap:getChildByName("panel_task")

    ----------------------------------------
    --管理
    local btn_manage = ccui.Helper:seekNodeByName(image_di_system, "btn_manage")

    --成员
    local btn_member = ccui.Helper:seekNodeByName(image_di_system, "btn_member")

    --动态
    local btn_notice = ccui.Helper:seekNodeByName(image_di_system, "btn_notice")

    --排行
    local btn_rank = ccui.Helper:seekNodeByName(image_di_system, "btn_rank")

    --联盟争霸
    local btn_wait = ccui.Helper:seekNodeByName(image_di_system, "btn_wait")
    local btn_war = ccui.Helper:seekNodeByName(image_di_system, "btn_war")

    ui_allianceNoticeBtn:setPressedActionEnabled(true)
    btn_back:setPressedActionEnabled(true)
    btn_help:setPressedActionEnabled(true)
    btn_manage:setPressedActionEnabled(true)
    btn_member:setPressedActionEnabled(true)
    btn_notice:setPressedActionEnabled(true)
    btn_rank:setPressedActionEnabled(true)
    btn_wait:setPressedActionEnabled(true)
    btn_war:setPressedActionEnabled(true)
    btn_assigned:setPressedActionEnabled(true)

    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                UIMenu.onHomepage()
            elseif sender == btn_help then
                UIAllianceHelp.show( { titleName = Lang.ui_alliance11, type = 0 })
            elseif sender == ui_allianceNoticeBtn then
                UIAllianceHint.show( { title = Lang.ui_alliance12, desc = ui_allianceNotice:getString(), callbackFunc = netCallbackFunc })
            elseif sender == panel_hall then
                UIAllianceHall.show()
            elseif sender == panel_shop then
                UIAllianceShop.show( { unionDetail = unionDetail })
            elseif sender == panel_activity then
                UIAllianceActivity.show({ allianceLevel = unionDetail.level })
            elseif sender == panel_skill then
                UIAllianceSkill.show()
            elseif sender == panel_animal then
                UIManager.showToast(Lang.ui_alliance13)
            elseif sender == panel_boss then
                if unionDetail.level < 10 then
                    UIManager.showToast(Lang.ui_alliance14)
                else
                    UIAllianceBoss.show()
                end
            elseif sender == panel_task then
                UIManager.showToast(Lang.ui_alliance15)
            elseif sender == btn_manage then --联盟管理
                UIAllianceManage.show()
            elseif sender == btn_member then --联盟成员
                UIAllianceMember.show( { unionDetail = unionDetail } )
            elseif sender == btn_notice then --联盟动态
                UIAllianceDynamic.show()
            elseif sender == btn_rank then --联盟排行
                UIAllianceRanking.show()
            elseif sender == btn_wait then
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.queryUnionWarOpen, msgdata = { } }, netCallbackFunc)
            elseif sender == btn_war then
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.openOverlord, msgdata = { } }, netCallbackFunc)
            elseif sender == btn_assigned then
                UIManager.pushScene("ui_alliance_war_grant")
            end
        end
    end

    panel_activity:addTouchEventListener(onButtonEvent)
    panel_hall:addTouchEventListener(onButtonEvent)
    panel_shop:addTouchEventListener(onButtonEvent)
    panel_skill:addTouchEventListener(onButtonEvent)
    panel_animal:addTouchEventListener(onButtonEvent)
    panel_boss:addTouchEventListener(onButtonEvent)
    panel_task:addTouchEventListener(onButtonEvent)

    ui_allianceNoticeBtn:addTouchEventListener(onButtonEvent)
    btn_back:addTouchEventListener(onButtonEvent)
    btn_help:addTouchEventListener(onButtonEvent)
    btn_manage:addTouchEventListener(onButtonEvent)
    btn_member:addTouchEventListener(onButtonEvent)
    btn_notice:addTouchEventListener(onButtonEvent)
    btn_rank:addTouchEventListener(onButtonEvent)
    btn_wait:addTouchEventListener(onButtonEvent)
    btn_war:addTouchEventListener(onButtonEvent)
    btn_assigned:addTouchEventListener(onButtonEvent)

    createCloud()
end

function UIAlliance.setup(flag)
--    initPracticeRefreshTime()
    dp.addTimerListener(practiceRefreshTime)
    UIManager.showLoading()
    netSendPackage( {
        header = StaticMsgRule.unionDetail,
        msgdata = { int = { instUnionMemberId = net.InstUnionMember.int["1"] } }
    } , netCallbackFunc)

    local image_basemap = UIAlliance.Widget:getChildByName("image_basemap")
    local image_hall_up = image_basemap:getChildByName("image_hall_up")
    image_hall_up:setVisible(false)
    local image_base_notice = image_basemap:getChildByName("image_base_notice")
    local ui_allianceNoticeBtn = ccui.Helper:seekNodeByName(image_base_notice, "btn_revise")
    ui_allianceNoticeBtn:setVisible(false)
    if not flag then
        local noticePanel = image_basemap:getChildByName("image_hint"):getChildByName("panel")
        noticePanel:removeAllChildren()
        UIAlliance.setDynamicHint(false)
        netSendPackage( {
            header = StaticMsgRule.unionDynamic,
            msgdata = { int = { instUnionMemberId = net.InstUnionMember.int["1"], type = 2 } }
        } , function(_msgData)
            scrollUnionDynamic(_msgData.msgdata.string.union)
            local persionDynamic = _msgData.msgdata.string.persion
            if _unionDynamicPersion ~= persionDynamic then
                UIAlliance.setDynamicHint(true)
            end
        end)
    end

    local ui_bossHint = image_basemap:getChildByName("panel_boss"):getChildByName("image_hint")
    ui_bossHint:setVisible(false)
    netSendPackage( { header = StaticMsgRule.clickUnionBossBtn, msgdata = { } }, function(_msgData)
        local allianceBossState = nil
        if _msgData.msgdata.int and _msgData.msgdata.int.unionBossState then
            allianceBossState = _msgData.msgdata.int.unionBossState
        end
        local drawState = _msgData.msgdata.int.drawState -- 0-未参与,1-可领取,2-已领取
        if allianceBossState == 0 and drawState == 1 then
            ui_bossHint:setVisible(true)
        end
    end)

    local image_di_system = image_basemap:getChildByName("image_di_system")
    local btn_manage = ccui.Helper:seekNodeByName(image_di_system, "btn_manage")
    local manage_hint = btn_manage:getChildByName("image_hint")
    manage_hint:setVisible(false)
    local selfGradeId = net.InstUnionMember.int["4"]
    if selfGradeId == 1 or selfGradeId == 2 then
        netSendPackage( { header = StaticMsgRule.obtainApply, msgdata = { int = { instUnionMemberId = net.InstUnionMember.int["1"] } } }, function(_msgData)
            -- //审核状态 0-关闭  1-开启
            local _applyState = _msgData.msgdata.int["1"]
            if _applyState == 1 then
                local unionApply = _msgData.msgdata.message.unionApply
		        if unionApply and unionApply.message then
                    local applyLists = {}
			        for key, obj in pairs(unionApply.message) do
				        applyLists[#applyLists + 1] = obj
			        end
                    if #applyLists > 0 then
                        manage_hint:setVisible(true)
                    end
		        end
            end
        end )
    end
end

function UIAlliance.setDynamicHint(_isVisible, persionDynamic)
    if UIAlliance.Widget then
        local image_basemap = UIAlliance.Widget:getChildByName("image_basemap")
        local image_di_system = image_basemap:getChildByName("image_di_system")
        local btn_notice = ccui.Helper:seekNodeByName(image_di_system, "btn_notice")
        local image_hint = btn_notice:getChildByName("image_hint")
        image_hint:setVisible(_isVisible)
        if persionDynamic then
            _unionDynamicPersion = persionDynamic
        end
    end
end

function UIAlliance.show()
    if net.InstUnionMember and net.InstUnionMember.int["2"] ~= 0 then
		UIManager.hideWidget("ui_team_info")
		UIManager.hideWidget("ui_menu")
		UIManager.showWidget("ui_alliance")
	else
		UIManager.pushScene("ui_alliance_rank")
	end
end

function UIAlliance.showMemberForAllianceWarGrant(callback)
    UIAllianceMember.show( { unionDetail = unionDetail, ui = UIAllianceWarGrant, callback = callback } )
end

function UIAlliance.free()
    dp.removeTimerListener(practiceRefreshTime)
    _countdownTime = 0
end

-- 按照一个月30天计算
local function getTime(_secsNums)
    -- 年
    local _year = math.floor(_secsNums / 3600 / 24 / 30 / 12 % 12)
    -- 月
    local _month = math.floor(_secsNums / 3600 / 24 / 30 % 30)
    -- 周
    local _week = math.floor(_secsNums / 3600 / 24 / 7 % 7)
    -- 天
    local _day = math.floor(_secsNums / 3600 / 24 % 24)
    -- 小时
    local _hour = math.floor(_secsNums / 3600 % 24)
    -- 分
    local _minute = math.floor(_secsNums / 60 % 60)
    -- 秒
    local _second = math.floor(_secsNums % 60)
    return { year = _year, month = _month, day = _day, week = _week, hour = _hour, min = _minute, sec = _second }
end

function UIAlliance.getOnlineState(_second)
    local _onlineState = Lang.ui_alliance16
    local onlineTime = getTime(_second)
    if onlineTime.year > 0 then
        return _onlineState .. onlineTime.year .. Lang.ui_alliance17
    elseif onlineTime.month > 0 then
        return _onlineState .. onlineTime.month .. Lang.ui_alliance18
    elseif onlineTime.week > 0 then
        return _onlineState .. onlineTime.week .. Lang.ui_alliance19
    elseif onlineTime.day > 0 then
        return _onlineState .. onlineTime.day .. Lang.ui_alliance20
    elseif onlineTime.hour > 0 then
        return _onlineState .. onlineTime.hour .. Lang.ui_alliance21
    elseif onlineTime.min > 0 then
        return _onlineState .. onlineTime.min .. Lang.ui_alliance22
    else
        return _onlineState
    end
end

--- 获取联盟的称号(职位)信息
function UIAlliance.getAllianceGrade(_gradeId)
    if net.InstUnionMember then
        local obj = DictUnionGrade[tostring(_gradeId)]
        if obj and unionDetail.gradeType == obj.type then
            local flagImg = ""
            if _gradeId == 1 or _gradeId == 2 then
                flagImg = "ui/lm_mz.png"
            elseif _gradeId == 4 or _gradeId == 5 then
                flagImg = "ui/lm_fmz.png"
            elseif _gradeId == 3 then
                flagImg = "ui/lm_cy.png"
            end
            obj.icon = flagImg
            return obj
        end
    end
end

function UIAlliance.getUnionDetail(_msgData)
    if _msgData then
        local unionDetail = _msgData.msgdata.message.unionDetail
        return {
            name = unionDetail.string["2"], --名称
            exp = unionDetail.int["3"], --经验（建设度）
            level = unionDetail.int["4"], --等级
            gradeType = unionDetail.int["5"], --职位类型
            maxMemberCount = unionDetail.int["6"], --最大成员数
            curMemberCount = unionDetail.int["7"], --当前成员数
            notice = unionDetail.string["10"], --公告
            manifesto = unionDetail.string["11"], --宣言
            plan = unionDetail.int["12"], --进度
            constructionNum = unionDetail.int["13"], --捐献人数
            practiceValue = UIAllianceSkill.getPracticeValue(), --修炼值
            unionWand = utils.getThingCount(StaticThing.unionWand), --联盟令
            materials = unionDetail.string["16"], --材料（材料ID_数量;）
            leaderName = unionDetail.string["17"], --盟主名字
            iconId = unionDetail.int["18"], --联盟旗帜ID
        }
    end
end

function UIAlliance.showDialog(_msgContent, _callBackFunc)
    local dialog = ccui.Layout:create()
    dialog:setContentSize(UIManager.screenSize)
    dialog:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    dialog:setBackGroundColor(cc.c3b(0, 0, 0))
    dialog:setBackGroundColorOpacity(130)
    dialog:setTouchEnabled(true)
    dialog:retain()

    local bg_image = ccui.ImageView:create("ui/tk_di_xiao.png")
    bg_image:setScale9Enabled(true)
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setContentSize(cc.size(550, 450))
    bg_image:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
    bg_image:setCapInsets(cc.rect(24, 58, 546, 486))
    dialog:addChild(bg_image)
    local bgSize = bg_image:getContentSize()

    local title = ccui.Text:create()
    title:setString(Lang.ui_alliance23)
    title:setFontName(dp.FONT)
    title:setFontSize(35)
    title:setTextColor(cc.c3b(51, 25, 4))
    title:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.91))
    bg_image:addChild(title)

    local closeBtn = ccui.Button:create("ui/btn_x.png", "ui/btn_x.png")
    closeBtn:setPressedActionEnabled(true)
    closeBtn:setTouchEnabled(true)
    closeBtn:setAnchorPoint(cc.p(1, 1))
    closeBtn:setPosition(cc.p(bgSize.width, bgSize.height))
    bg_image:addChild(closeBtn)

    local cancelBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
    cancelBtn:setTitleText(Lang.ui_alliance24)
    cancelBtn:setTitleFontName(dp.FONT)
    cancelBtn:setTitleColor(cc.c3b(255, 255, 255))
    cancelBtn:setTitleFontSize(35)
    cancelBtn:setPressedActionEnabled(true)
    cancelBtn:setTouchEnabled(true)
    cancelBtn:setPosition(cc.p(bgSize.width * 0.25, bgSize.height * 0.11))
    bg_image:addChild(cancelBtn)

    local sureBtn = ccui.Button:create("ui/tk_btn_red.png", "ui/tk_btn_red.png")
    sureBtn:setTitleText(Lang.ui_alliance25)
    sureBtn:setTitleFontName(dp.FONT)
    sureBtn:setTitleColor(cc.c3b(255, 255, 255))
    sureBtn:setTitleFontSize(35)
    sureBtn:setPressedActionEnabled(true)
    sureBtn:setTouchEnabled(true)
    sureBtn:setPosition(cc.p(bgSize.width * 0.75, bgSize.height * 0.11))
    bg_image:addChild(sureBtn)

    local msgRectSize = cc.size(bgSize.width * 0.95, bgSize.height * 0.61)

    local messagePanel = ccui.Layout:create()
    messagePanel:setContentSize(msgRectSize)
--    messagePanel:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    messagePanel:setPosition(cc.p((bgSize.width - msgRectSize.width) / 2, bgSize.height * 0.22))
    messagePanel:setBackGroundColor(cc.c3b(255, 255, 255))
    messagePanel:setClippingEnabled(true)
    bg_image:addChild(messagePanel)

    if string.find(_msgContent, "/color") then
        local messages = utils.richTextFormat(_msgContent)
        local _tempMsg = ""
        for key, obj in pairs(messages) do
            _tempMsg = _tempMsg .. obj.text
        end
        local _tempStrs = utils.stringSplit(_tempMsg, "\n")
        if #_tempStrs == 2 then
            local _tempObjs = {}
            local _tempObjsFlagIndex = nil
            for key, obj in pairs(messages) do
                if string.find(obj.text, "\n") then
                    for _k, _o in pairs(utils.stringSplit(obj.text, "\n")) do
                        _tempObjs[#_tempObjs + 1] = { text = _o, color = obj.color }
                        if _tempObjsFlagIndex == nil then
                            _tempObjsFlagIndex = #_tempObjs
                        end
                    end
                else
                    _tempObjs[#_tempObjs + 1] = { text = obj.text, color = obj.color }
                end
            end

            local _width = 0
            local _height = 0
            local msgLayout1 = ccui.Layout:create()
            for k = 1, _tempObjsFlagIndex do
                local obj = _tempObjs[k]
                local text = ccui.Text:create()
                text:setString(obj.text)
                text:setFontName(dp.FONT)
                text:setFontSize(30)
                text:setTextColor(obj.color)
                text:setAnchorPoint(cc.p(0, 0))
                text:setPosition(cc.p(_width, 0))
                msgLayout1:addChild(text)
                _width = _width + text:getContentSize().width
                if _height < text:getContentSize().height then
                    _height = text:getContentSize().height
                end
            end
            msgLayout1:setContentSize(cc.size(_width, _height))
            _width = 0
            _height = 0
            local msgLayout2 = ccui.Layout:create()
            for k = _tempObjsFlagIndex+1, #_tempObjs do
                local obj = _tempObjs[k]
                local text = ccui.Text:create()
                text:setString(obj.text)
                text:setFontName(dp.FONT)
                text:setFontSize(30)
                text:setTextColor(obj.color)
                text:setAnchorPoint(cc.p(0, 0))
                text:setPosition(cc.p(_width, 0))
                msgLayout2:addChild(text)
                _width = _width + text:getContentSize().width
                if _height < text:getContentSize().height then
                    _height = text:getContentSize().height
                end
            end
            msgLayout2:setContentSize(cc.size(_width, _height))
            msgLayout1:setPosition(cc.p((msgRectSize.width - msgLayout1:getContentSize().width) / 2, msgRectSize.height / 2))
            msgLayout2:setPosition(cc.p((msgRectSize.width - msgLayout2:getContentSize().width) / 2, msgRectSize.height / 2 - msgLayout2:getContentSize().height))
            messagePanel:addChild(msgLayout1)
            messagePanel:addChild(msgLayout2)
        elseif #_tempStrs == 3 then
            for key, obj in pairs(_tempStrs) do
                local text = ccui.Text:create()
                text:setString(obj)
                text:setFontName(dp.FONT)
                text:setFontSize(30)
                text:setTextColor(messages[key].color)
                if key == 1 then
                    text:setPosition(cc.p(msgRectSize.width / 2, msgRectSize.height / 2 + text:getContentSize().height))
                elseif key == 3 then
                    text:setPosition(cc.p(msgRectSize.width / 2, msgRectSize.height / 2 - text:getContentSize().height))
                else
                    text:setPosition(cc.p(msgRectSize.width / 2, msgRectSize.height / 2))
                end
                messagePanel:addChild(text)
            end
        else
        end
    else
        local msgLabel = ccui.Text:create()
        msgLabel:setString(_msgContent)
        msgLabel:setFontName(dp.FONT)
        msgLabel:setTextAreaSize(msgRectSize)
        msgLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        msgLabel:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        msgLabel:setFontSize(30)
        msgLabel:setTextColor(cc.c3b(255, 255, 255))
        msgLabel:setPosition(cc.p(msgRectSize.width / 2, msgRectSize.height / 2))
        messagePanel:addChild(msgLabel)
    end

    bg_image:setScale(0.1)
    UIManager.uiLayer:addChild(dialog, 10000)
    bg_image:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.06, 1)))

    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.uiLayer:removeChild(dialog, true)
            cc.release(dialog)
            if sender == sureBtn then
                if _callBackFunc then
                    _callBackFunc()
                end
            end
        end
    end
    closeBtn:addTouchEventListener(onButtonEvent)
    cancelBtn:addTouchEventListener(onButtonEvent)
    sureBtn:addTouchEventListener(onButtonEvent)
end
