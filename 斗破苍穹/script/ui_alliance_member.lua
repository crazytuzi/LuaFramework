require"Lang"
UIAllianceMember = { }

local BUTTON_TEXT_APPOINT = Lang.ui_alliance_member1
local BUTTON_TEXT_KICKOUT = Lang.ui_alliance_member2
local BUTTON_TEXT_IMPEACH = Lang.ui_alliance_member3
local BUTTON_TEXT_CHECK = Lang.ui_alliance_member4
local BUTTON_TEXT_EXIT = Lang.ui_alliance_member5
local BUTTON_TEXT_GIVEREWARD = Lang.ui_alliance_member6

local ORDER_ASC = 0  -- 升序（从小到大）
local ORDER_DESC = 1 -- 降序（从大到小）

local userData = nil
local ui_scrollView = nil
local ui_svItem = nil

local memberList = nil
local _curCommand = nil
local _prevOrderTag = nil

local netCallbackFunc = nil

local function cleanScrollView()
    if ui_svItem and ui_svItem:getReferenceCount() == 1 then
        ui_svItem:retain()
    end
    if ui_scrollView then
        ui_scrollView:removeAllChildren()
    end
end

local function layoutScrollView(_listData, _initItemFunc)
    local SCROLLVIEW_ITEM_SPACE = 0
    cleanScrollView()
    ui_scrollView:jumpToTop()
    local _innerHeight = 0
    if not _listData then _listData = { } end
    for key, obj in pairs(_listData) do
        local scrollViewItem = ui_svItem:clone()
        _initItemFunc(scrollViewItem, obj, key)
        ui_scrollView:addChild(scrollViewItem)
        _innerHeight = _innerHeight + scrollViewItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
    end
    _innerHeight = _innerHeight + SCROLLVIEW_ITEM_SPACE
    if _innerHeight < ui_scrollView:getContentSize().height then
        _innerHeight = ui_scrollView:getContentSize().height
    end
    ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, _innerHeight))
    local childs = ui_scrollView:getChildren()
    local prevChild = nil
    for i = 1, #childs do
        if i == 1 then
            childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
        else
            childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
        end
        prevChild = childs[i]
    end
    ActionManager.ScrollView_SplashAction(ui_scrollView)
end

local function setScrollViewItem(_item, _data)
    local selfGradeId = net.InstUnionMember.int["4"]
    local image_info = _item:getChildByName("image_di_info")
    local ui_frameImg = image_info:getChildByName("image_frame_title")
    local ui_icon = ui_frameImg:getChildByName("image_title")
    local ui_vipFlag = ui_frameImg:getChildByName("image_vip")
    local ui_name = image_info:getChildByName("text_name")
    local ui_onlineTime = image_info:getChildByName("text_time")
    local ui_level = image_info:getChildByName("text_lv")
    local ui_fight = image_info:getChildByName("text_fight")
    local ui_todayOffer = image_info:getChildByName("text_congratulate_tody")
    local ui_totalOffer = image_info:getChildByName("text_congratulate_all")
    local ui_memberFlag = _item:getChildByName("image_job")
    local ui_gradeName = ui_memberFlag:getChildByName("text_name")
    ui_name:setString(_data.string["10"])
    local _onlineState = _data.long["12"]
    -- 在线状态 0:在线
    if _onlineState == 0 then
        ui_onlineTime:setString(Lang.ui_alliance_member7)
    else
        ui_onlineTime:setString(UIAlliance.getOnlineState(_onlineState / 1000))
    end
    local dictCard = DictCard[tostring(utils.stringSplit(_data.string["13"],"_")[1])]
    local isAwake = tonumber(utils.stringSplit(_data.string["13"],"_")[2])
    if dictCard then
        if isAwake == 1 then
            ui_icon:loadTexture("image/" .. DictUI[tostring(dictCard.awakeSmallUiId)].fileName)
        else
            ui_icon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
        end
    end
    if _data.int["14"] > 0 then
        ui_vipFlag:setVisible(true)
    else
        ui_vipFlag:setVisible(false)
    end
    ui_level:setString(Lang.ui_alliance_member8 .. _data.int["11"])
    ui_fight:setString(Lang.ui_alliance_member9 .. _data.int["15"])
    ui_todayOffer:setString(Lang.ui_alliance_member10 .. _data.int["6"])
    ui_totalOffer:setString(Lang.ui_alliance_member11 .. _data.int["5"])
    local gradeId = _data.int["4"]
    local grades = UIAlliance.getAllianceGrade(gradeId)
    if grades then
        ui_memberFlag:loadTexture(grades.icon)
    end
    ui_gradeName:setString(DictUnionGrade[tostring(gradeId)].name)
    local btn_left = _item:getChildByName("btn_on")
    local btn_middle = _item:getChildByName("btn_out")
    local btn_right = _item:getChildByName("btn_look")
    btn_left:setPressedActionEnabled(true)
    btn_middle:setPressedActionEnabled(true)
    btn_right:setPressedActionEnabled(true)
    -- 如果当前是我自己
    if net.InstPlayer.int["1"] == _data.int["3"] then
        _item:loadTexture("ui/jjc_di01.png")
        btn_left:setVisible(false)
        btn_middle:setVisible(false)
        btn_right:setVisible(true)
        btn_right:setTitleText(BUTTON_TEXT_EXIT)
        ui_onlineTime:setTextColor(cc.c3b(255, 255, 0))
    else
        ui_onlineTime:setTextColor(cc.c3b(139, 69, 19))
        if selfGradeId == 1 or selfGradeId == 2 then
            btn_left:setVisible(true)
            btn_left:setTitleText(BUTTON_TEXT_APPOINT)
            btn_middle:setVisible(true)
            btn_middle:setTitleText(BUTTON_TEXT_KICKOUT)
            btn_right:setVisible(true)
            btn_right:setTitleText(BUTTON_TEXT_CHECK)
            if selfGradeId == 2 then
                if gradeId == 1 then
                    -- 副盟主遇到盟主
                    btn_left:setVisible(false)
                elseif gradeId == 2 then
                    -- 副盟主遇到副盟主
                    btn_left:setVisible(false)
                    btn_middle:setVisible(false)
                end
            end
        else
            btn_left:setVisible(false)
            btn_middle:setVisible(false)
            btn_right:setVisible(true)
            btn_right:setTitleText(BUTTON_TEXT_CHECK)
        end
        -- 如果当前是盟主
        if gradeId == 1 then
            btn_middle:setVisible(true)
            btn_middle:setTitleText(BUTTON_TEXT_IMPEACH)
        end
    end

    if userData.ui == UIAllianceWarGrant then
        btn_left:show():setPositionX(539)
        btn_left:setTitleText(BUTTON_TEXT_GIVEREWARD)
        btn_middle:setVisible(false)
        btn_right:setVisible(false)
    else
        btn_left:setPositionX(271)
        btn_left:setTitleText(BUTTON_TEXT_APPOINT)
    end

    ui_icon:setTouchEnabled(true)
    ui_icon:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIAllianceTalk.show( { playerId = _data.int["3"], userName = _data.string["10"], userLvl = _data.int["11"], userFight = _data.int["15"], userUnio = userData.unionDetail.name, headId = _data.string["13"], vip = _data.int["14"] })
        end
    end )
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_left then
                if sender:getTitleText() == BUTTON_TEXT_APPOINT then
                    -- UIManager.showToast("任命！~" .. BUTTON_TEXT_APPOINT)
                    local memberCounts = { }
                    for _k, _o in pairs(memberList) do
                        local _gardeId = _o.int["4"]
                        memberCounts[_gardeId] =(memberCounts[_gardeId] and memberCounts[_gardeId] or 0) + 1
                    end
                    UIAllianceAppoint.show( { unionDetail = userData.unionDetail, instUnionMemberId = _data.int["1"], playerName = _data.string["10"], memberCounts = memberCounts })
                    memberCounts = nil
                elseif sender:getTitleText() == BUTTON_TEXT_GIVEREWARD then
                    userData.callback(_data.int["3"])
                end
            elseif sender == btn_middle then
                if sender:getTitleText() == BUTTON_TEXT_KICKOUT then
                    -- UIManager.showToast("踢出！~" .. BUTTON_TEXT_KICKOUT)
                    UIAlliance.showDialog(Lang.ui_alliance_member12 .. _data.string["10"] .. Lang.ui_alliance_member13, function()
                        UIManager.showLoading()
                        _curCommand = BUTTON_TEXT_KICKOUT
                        netSendPackage( {
                            header = StaticMsgRule.exitUnion,
                            msgdata = { int = { instUnionMemberId = _data.int["1"], type = - 1 } }
                        } , netCallbackFunc)
                    end )
                elseif sender:getTitleText() == BUTTON_TEXT_IMPEACH then
                    -- UIManager.showToast("弹劾！~" .. BUTTON_TEXT_KICKOUT)
                    --                    if _onlineState < (5 * 24 * 60 * 60 * 1000) then
                    --                        return UIManager.showToast("盟主需要离开5天以上才可弹劾")
                    --                    end
                    UIManager.showLoading()
                    netSendPackage( {
                        header = StaticMsgRule.isWishUnionAccCon,
                        msgdata = { int = { leaderUnionMemId = _data.int["1"], accuseUnionMemId = net.InstUnionMember.int["1"] } }
                    } , function(_messageData)
                        UIAlliance.showDialog(string.format(Lang.ui_alliance_member14, DictSysConfig[tostring(StaticSysConfig.accLeaderConsGolds)].value), function()
                            UIManager.showLoading()
                            netSendPackage( {
                                header = StaticMsgRule.accuseLeader,
                                msgdata = { int = { leaderUnionMemId = _data.int["1"], accuseUnionMemId = net.InstUnionMember.int["1"] } }
                            } , netCallbackFunc)
                        end )
                    end )
                end
            elseif sender == btn_right then
                if sender:getTitleText() == BUTTON_TEXT_CHECK then
                    UIManager.showLoading()
                    netSendPackage( { header = StaticMsgRule.enemyPlayerInfo, msgdata = { int = { playerId = _data.int["3"] } } }, netCallbackFunc)
                elseif sender:getTitleText() == BUTTON_TEXT_EXIT then
                    -- UIManager.showToast("退出！~" .. BUTTON_TEXT_EXIT)
                    if gradeId == 1 then
                        UIManager.showToast(Lang.ui_alliance_member15)
                    else
                        UIAlliance.showDialog(Lang.ui_alliance_member16, function()
                            UIManager.showLoading()
                            _curCommand = BUTTON_TEXT_EXIT
                            netSendPackage( {
                                header = StaticMsgRule.exitUnion,
                                msgdata = { int = { instUnionMemberId = _data.int["1"], type = - 2 } }
                            } , netCallbackFunc)
                        end )
                    end
                end
            end
        end
    end
    btn_left:addTouchEventListener(onButtonEvent)
    btn_middle:addTouchEventListener(onButtonEvent)
    btn_right:addTouchEventListener(onButtonEvent)
end

netCallbackFunc = function(_msgData)
    local code = tonumber(_msgData.header)
    if code == StaticMsgRule.unionMember then
        local unionMember = _msgData.msgdata.message.unionMember
        memberList = { }
        local onlineList, unOnlineList = { }, { }
        for key, obj in pairs(unionMember.message) do
            -- 		memberList[#memberList + 1] = obj
            if obj.long["12"] == 0 then
                onlineList[#onlineList + 1] = obj
            else
                unOnlineList[#unOnlineList + 1] = obj
            end
        end
        utils.quickSort(onlineList, function(obj1, obj2)
            if DictUnionGrade[tostring(obj1.int["4"])].gradeId > DictUnionGrade[tostring(obj2.int["4"])].gradeId then
                return true
            elseif obj1.int["5"] < obj2.int["5"] then
                return true
            end
        end )
        utils.quickSort(unOnlineList, function(obj1, obj2)
            if DictUnionGrade[tostring(obj1.int["4"])].gradeId > DictUnionGrade[tostring(obj2.int["4"])].gradeId then
                return true
            elseif obj1.long["12"] > obj2.long["12"] then
                return true
            elseif obj1.int["5"] < obj2.int["5"] then
                return true
            end
        end )
        for key, obj in pairs(onlineList) do
            memberList[#memberList + 1] = obj
        end
        for key, obj in pairs(unOnlineList) do
            memberList[#memberList + 1] = obj
        end
        if _prevOrderTag then
            _prevOrderTag:setTag(_prevOrderTag:getTag() == ORDER_ASC and ORDER_DESC or ORDER_ASC)
            _prevOrderTag:releaseUpEvent()
        else
            layoutScrollView(memberList, setScrollViewItem)
        end
        onlineList = nil
        unOnlineList = nil
    elseif code == StaticMsgRule.enemyPlayerInfo then
        pvp.loadGameData(_msgData)
        UIManager.pushScene("ui_arena_check")
    elseif code == StaticMsgRule.exitUnion then
        if _curCommand == BUTTON_TEXT_EXIT then
            UIManager.showToast(Lang.ui_alliance_member17)
            UIMenu.onHomepage()
        elseif _curCommand == BUTTON_TEXT_KICKOUT then
            UIManager.showToast(Lang.ui_alliance_member18)
            userData.unionDetail.curMemberCount = userData.unionDetail.curMemberCount - 1
            UIAllianceMember.setup()
        end
    elseif code == StaticMsgRule.accuseLeader then
        UIManager.showToast(Lang.ui_alliance_member19)
        UIAllianceMember.setup()
    end
end

local function setDefaultOrderTag()
    local image_basemap = UIAllianceMember.Widget:getChildByName("image_basemap")
    -- 战力
    local btn_fight = image_basemap:getChildByName("btn_fight")
    btn_fight:setTitleColor(cc.c3b(127, 127, 127))
    btn_fight:getChildByName("image_arrow"):setVisible(false)
    btn_fight:setTag(ORDER_DESC)

    -- 贡献
    local btn_contribute = image_basemap:getChildByName("btn_contribute")
    btn_contribute:setTitleColor(cc.c3b(127, 127, 127))
    btn_contribute:getChildByName("image_arrow"):setVisible(false)
    btn_contribute:setTag(ORDER_DESC)

    -- 等级
    local btn_lv = image_basemap:getChildByName("btn_lv")
    btn_lv:setTitleColor(cc.c3b(127, 127, 127))
    btn_lv:getChildByName("image_arrow"):setVisible(false)
    btn_lv:setTag(ORDER_DESC)

    -- 职位
    local btn_position = image_basemap:getChildByName("btn_position")
    btn_position:setTitleColor(cc.c3b(127, 127, 127))
    btn_position:getChildByName("image_arrow"):setVisible(false)
    btn_position:setTag(ORDER_DESC)
end

function UIAllianceMember.init()
    local image_basemap = UIAllianceMember.Widget:getChildByName("image_basemap")
    local btn_back = image_basemap:getChildByName("btn_back")

    -- 战力
    local btn_fight = image_basemap:getChildByName("btn_fight")

    -- 贡献
    local btn_contribute = image_basemap:getChildByName("btn_contribute")

    -- 等级
    local btn_lv = image_basemap:getChildByName("btn_lv")

    -- 职位
    local btn_position = image_basemap:getChildByName("btn_position")

    btn_back:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                if userData.ui == UIAllianceWarGrant then
                    UIAlliance.show()
                    local btn_assigned = ccui.Helper:seekNodeByName(UIAlliance.Widget, "btn_assigned")
                    btn_assigned:releaseUpEvent()
                else
                    UIAlliance.show()
                end
            elseif (sender == btn_fight or sender == btn_contribute or sender == btn_lv or sender == btn_position) and memberList then
                local _order =(sender == _prevOrderTag) and(sender:getTag() == ORDER_ASC and ORDER_DESC or ORDER_ASC) or ORDER_DESC
                setDefaultOrderTag()
                sender:setTag(_order)
                sender:setTitleColor(cc.c3b(255, 0, 0))
                local image_arrow = sender:getChildByName("image_arrow")
                image_arrow:loadTexture(_order == ORDER_ASC and "ui/ore_jt.png" or "ui/ore_rjian.png")
                image_arrow:setVisible(true)
                _prevOrderTag = sender
                if sender == btn_fight then
                    if _order == ORDER_DESC then
                        utils.quickSort(memberList, function(obj1, obj2)
                            if obj1.int["15"] < obj2.int["15"] then
                                return true
                            end
                        end )
                    elseif _order == ORDER_ASC then
                        utils.quickSort(memberList, function(obj1, obj2)
                            if obj1.int["15"] > obj2.int["15"] then
                                return true
                            end
                        end )
                    end
                elseif sender == btn_contribute then
                    if _order == ORDER_DESC then
                        utils.quickSort(memberList, function(obj1, obj2)
                            if obj1.int["5"] < obj2.int["5"] then
                                return true
                            end
                        end )
                    elseif _order == ORDER_ASC then
                        utils.quickSort(memberList, function(obj1, obj2)
                            if obj1.int["5"] > obj2.int["5"] then
                                return true
                            end
                        end )
                    end
                elseif sender == btn_lv then
                    if _order == ORDER_DESC then
                        utils.quickSort(memberList, function(obj1, obj2)
                            if obj1.int["11"] < obj2.int["11"] then
                                return true
                            end
                        end )
                    elseif _order == ORDER_ASC then
                        utils.quickSort(memberList, function(obj1, obj2)
                            if obj1.int["11"] > obj2.int["11"] then
                                return true
                            end
                        end )
                    end
                elseif sender == btn_position then
                    if _order == ORDER_DESC then
                        utils.quickSort(memberList, function(obj1, obj2)
                            if DictUnionGrade[tostring(obj1.int["4"])].gradeId > DictUnionGrade[tostring(obj2.int["4"])].gradeId then
                                return true
                            end
                        end )
                    elseif _order == ORDER_ASC then
                        utils.quickSort(memberList, function(obj1, obj2)
                            if DictUnionGrade[tostring(obj1.int["4"])].gradeId < DictUnionGrade[tostring(obj2.int["4"])].gradeId then
                                return true
                            end
                        end )
                    end
                end
                layoutScrollView(memberList, setScrollViewItem)
            end
        end
    end
    btn_back:addTouchEventListener(onButtonEvent)
    btn_fight:addTouchEventListener(onButtonEvent)
    btn_contribute:addTouchEventListener(onButtonEvent)
    btn_lv:addTouchEventListener(onButtonEvent)
    btn_position:addTouchEventListener(onButtonEvent)

    ui_scrollView = image_basemap:getChildByName("view_member")
    ui_svItem = ui_scrollView:getChildByName("image_di_menber"):clone()
end

function UIAllianceMember.setup()
    layoutScrollView(nil, setScrollViewItem)
    UIManager.showLoading()
    netSendPackage( {
        header = StaticMsgRule.unionMember,
        msgdata = { int = { instUnionMemberId = net.InstUnionMember.int["1"] } }
    } , netCallbackFunc)
    setDefaultOrderTag()
    local image_basemap = UIAllianceMember.Widget:getChildByName("image_basemap")
    local image_di_dowm = image_basemap:getChildByName("image_di_dowm")
    local text_number = ccui.Helper:seekNodeByName(image_di_dowm, "text_number")
    text_number:setString(string.format(Lang.ui_alliance_member20, userData.unionDetail.curMemberCount, userData.unionDetail.maxMemberCount))
end

function UIAllianceMember.show(_tableParams)
    userData = _tableParams and _tableParams or { }
    UIManager.showWidget("ui_alliance_member")
end

function UIAllianceMember.free()
    cleanScrollView()
    userData = nil
    _curCommand = nil
    _prevOrderTag = nil
    memberList = nil
end
