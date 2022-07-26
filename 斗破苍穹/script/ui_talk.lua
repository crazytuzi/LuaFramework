require"Lang"

UITalk = {
    TAG_WORLD = 1,
    TAG_UNION = 2,
    TAG_PRIVATE_CHAT = 3
}
local uiText = nil
local otherNameText = nil
local otherName = nil
local uiDialog = nil
local uiDialogR = nil
local uiView = nil
local btn_world = nil
local btn_unio = nil
local btn_chat = nil
local btn_go = nil
local uiDialog_other = nil
local image_base_bq = nil
UITalk.time = { }
UITalk.scheduleIds = { }
local tag = UITalk.TAG_WORLD
FONTSIZE = 24
RECTWIDTH = 430
RECTHEIGHT = 64
DIALOGWIDTH = 150
UITalk.chatInfo = { }
UITalk.chatInfo_unio = { }
UITalk.chatInfo_user = { }
local isUpdate = false
local checkBox = nil

local function netCallbackFunc(data)

end

function updateDialog(index)
    if isUpdate then return end
    isUpdate = true

    local positionY = 0
    local myId = dp.getUserData().roleId
    local tempchatInfo = nil
    if index == UITalk.TAG_WORLD then
        tempchatInfo = UITalk.chatInfo
    elseif index == UITalk.TAG_UNION then
        tempchatInfo = UITalk.chatInfo_unio
    elseif index == UITalk.TAG_PRIVATE_CHAT then
        tempchatInfo = UITalk.chatInfo_user
    end
    if tag ~= index then
        tag = index
        uiView:setInnerContainerSize(cc.size(uiView:getContentSize().width, 684))
    end
    if uiView then
        uiView:removeAllChildren()
    end
    if uiView and tempchatInfo then
        for key = #tempchatInfo, 1, -1 do
            info = tempchatInfo[key]

            local userName = info.roleName
            local isR = tonumber(info.roleId) == myId
            local uiDialog1 = isR and uiDialogR:clone() or uiDialog:clone()

            local textBg = ccui.Helper:seekNodeByName(uiDialog1, "image_info")
            uiDialog1:setVisible(true)
            uiView:addChild(uiDialog1, 1, 100 + key)

            local nameText = ccui.Text:create()
            nameText:setName("name" .. key)
            nameText:setFontName(dp.FONT)
            local nameText1 = ccui.Text:create()
            nameText1:setName("nameR" .. key)
            nameText1:setFontName(dp.FONT)
            uiDialog1:addChild(nameText, 1)
            uiDialog1:addChild(nameText1, 1)

            local img_ar = ccui.Helper:seekNodeByName(uiDialog1, "image_arrow")
            img_ar:setLocalZOrder(100)
            local name = ccui.Helper:seekNodeByName(uiDialog1, "text_title")
            name:enableOutline(display.COLOR_BLACK, 1)
            nameText:enableOutline(display.COLOR_BLACK, 1)
            nameText1:enableOutline(display.COLOR_BLACK, 1)
            nameText:setFontSize(name:getFontSize())
            nameText1:setFontSize(name:getFontSize())
            if tag == UITalk.TAG_PRIVATE_CHAT then
                if tonumber(info.roleId) == myId then
                    name:setString(Lang.ui_talk1)
                    name:setTextColor(display.COLOR_WHITE)
                    nameText:setString(info.chatObjName)
                    nameText:setVisible(true)
                    nameText:setTextColor(cc.c3b(0, 255, 240))
                    nameText1:setString(Lang.ui_talk2)
                    nameText1:setVisible(true)
                    nameText1:setTextColor(display.COLOR_WHITE)
                    nameText:setPosition(name:getPositionX() - name:getContentSize().width, name:getPositionY())
                    nameText1:setPosition(nameText:getPositionX() - nameText:getContentSize().width, nameText:getPositionY())
                    nameText:setAnchorPoint(1, 0.5)
                    nameText1:setAnchorPoint(1, 0.5)
                else
                    name:setString(info.roleName)
                    name:setTextColor(cc.c3b(0, 255, 240))
                    nameText:setString(Lang.ui_talk3)
                    nameText:setVisible(true)
                    nameText:setTextColor(display.COLOR_WHITE)
                    nameText:setPosition(name:getPositionX() + name:getContentSize().width, name:getPositionY())
                    nameText1:setVisible(false)
                    nameText:setAnchorPoint(0, 0.5)
                end
            else
                name:setString(userName)
                name:setTextColor(cc.c3b(0, 255, 240))
                nameText:setVisible(false)
                nameText1:setVisible(false)
            end

            local text = ccui.RichText:create()
            text:setName("text" .. key)
            if isR then
                textBg:setAnchorPoint(1, 1)
            else
                textBg:setAnchorPoint(0, 1)
            end
            uiDialog1:addChild(text, 1)

            if (index == UITalk.TAG_UNION and string.match(info.contentText, "unionAssist:%d+|%d+_%d+_%d+|%d+|%d+")) == info.contentText then
                local str = string.sub(info.contentText, string.len("unionAssist:") + 1)
                str = utils.stringSplit(str, "|")
                local mine = {
                    mineType = tonumber(str[1] or 0),
                    reward = str[2] or "",
                    mineId = tonumber(str[3] or 0),
                    minerId = tonumber(str[4] or 0)
                }
                local elements = { }
                table.insert(elements, ccui.RichElementText:create(key, cc.c3b(61, 19, 10), 255, Lang.ui_talk4, dp.FONT, FONTSIZE))
                table.insert(elements, ccui.RichElementText:create(key, cc.c3b(242, 0, 230), 255, UIOre.MINE_NAMES[mine.mineType + 1], dp.FONT, FONTSIZE))
                table.insert(elements, ccui.RichElementText:create(key, cc.c3b(61, 19, 10), 255, Lang.ui_talk5, dp.FONT, FONTSIZE))

                local itemProp = utils.getItemProp(mine.reward)

                local image_guest_good = ccui.ImageView:create(itemProp.frameIcon)
                image_guest_good:setName("image_guest_good")
                image_guest_good:setContentSize(cc.size(105, 103))
                image_guest_good:setScale(0.8)

                local image_good = ccui.ImageView:create(itemProp.smallIcon)
                image_good:setName("image_good")
                image_good:setContentSize(cc.size(80, 80))
                image_good:ignoreContentAdaptWithSize(true)
                image_good:setPosition(52.5, 51.5)
                image_guest_good:addChild(image_good)

                local image_base_number = ccui.ImageView:create("ui/tk_di_shuzi.png")
                image_base_number:setName("image_base_number")
                image_base_number:setScale(0.8)
                image_base_number:setPosition(71, 86.67)
                image_guest_good:addChild(image_base_number)

                if itemProp.count > 1 then
                    local text_number = ccui.Text:create(tostring(itemProp.count), dp.FONT, 26)
                    text_number:setName("text_number")
                    text_number:setPosition(34, 18)
                    image_base_number:addChild(text_number)
                end

                utils.addBorderImage(itemProp.tableTypeId, itemProp.tableFieldId, image_guest_good)

                utils.showThingsInfo(image_guest_good, itemProp.tableTypeId, itemProp.tableFieldId)

                local text2 = ccui.Text:create(Lang.ui_talk6, dp.FONT, FONTSIZE)
                text2:setTextColor(cc.c3b(61, 19, 10))
                text2:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
                text2:setTextAreaSize(cc.size(text2:getContentSize().width, image_guest_good:getContentSize().height + 2))
                table.insert(elements, ccui.RichElementCustomNode:create(key, display.COLOR_WHITE, 255, text2))

                if mine.minerId ~= net.InstPlayer.int["1"] then
                    local button = ccui.Button:create("ui/tk_btn01.png")
                    button:setTouchEnabled(true)
                    button:setTitleFontName(dp.FONT)
                    button:ignoreContentAdaptWithSize(false)
                    button:setContentSize(cc.size(164 * 0.8, 73 * 0.8))
                    button:setTitleFontSize(FONTSIZE)
                    button:setTitleText(Lang.ui_talk7)
                    button:addTouchEventListener( function(sender, touchEventType)
                        if touchEventType == ccui.TouchEventType.ended then
                            audio.playSound("sound/button.mp3")
                            UIManager.showLoading()
                            netSendPackage( { header = StaticMsgRule.unionAssist, msgdata = { int = { mineId = mine.mineId, minerId = mine.minerId } } },
                            function(pack)
                                local msgdata = pack.msgdata
                                local type = msgdata.int.type

                                local function jumpToMine(dontRefresh)
                                    UIOre.jumpToMine(msgdata, mine.mineId)
                                    if not dontRefresh then
                                        UIManager.showLoading()
                                        netSendPackage( { header = StaticMsgRule.refreshMineZone, msgdata = { int = { pageIndex = UIOre.minePageIndex } } }, UIOre.refreshCurPageMine)
                                    end
                                end

                                if type == 1 then
                                    utils.PromptDialog(jumpToMine, string.format(Lang.ui_talk8, math.floor(msgdata.int.specialRewardAssistTime / 3600)))
                                elseif type == 2 then
                                    utils.PromptDialog(jumpToMine, Lang.ui_talk9)
                                else
                                    jumpToMine(true)
                                end
                            end )
                        end
                    end )

                    local text2 = ccui.RichText:create()
                    for i, element in ipairs(elements) do
                        text2:pushBackElement(element)
                    end
                    text2:setVerticalSpace(2)
                    text2:ignoreContentAdaptWithSize(false)
                    text2:setContentSize(cc.size(250, FONTSIZE))
                    text2:formatText()

                    local text2Size = text2:getContentSize()

                    local node = cc.Node:create()
                    node:setContentSize(text2Size)
                    text2:setPosition(text2Size.width / 2, text2Size.height / 2)
                    node:addChild(text2)
                    text:pushBackElement(ccui.RichElementCustomNode:create(key, display.COLOR_WHITE, 255, node))

                    text:setVerticalSpace(2)
                    text:ignoreContentAdaptWithSize(false)
                    text:setContentSize(cc.size(RECTWIDTH - 46, FONTSIZE))
                    text:formatText()
                    text:addChild(image_guest_good)
                    image_guest_good:setAnchorPoint(display.RIGHT_BOTTOM)
                    image_guest_good:setPositionX(250 - 15)
                    text:addChild(button)
                    button:setAnchorPoint(display.LEFT_CENTER)
                    button:setPosition(250 + 5, text:getContentSize().height / 2)
                else
                    for i, element in ipairs(elements) do
                        text:pushBackElement(element)
                    end
                    text:setVerticalSpace(2)
                    text:ignoreContentAdaptWithSize(false)
                    text:setContentSize(cc.size(250, FONTSIZE))
                    text:formatText()
                    text:addChild(image_guest_good)
                    image_guest_good:setAnchorPoint(display.RIGHT_BOTTOM)
                    image_guest_good:setPositionX(250 - 15)
                end
            else
                local start = 1
                while start <= string.len(info.contentText) do
                    local s, e, ls, le

                    local pattern = "#%d"
                    while true do
                        s, e = string.find(info.contentText, pattern .. "#", start)
                        if s and e and(not ls or ls == s) then
                            ls, le = s, e
                            pattern = pattern .. "#%d"
                        else
                            break
                        end
                    end

                    if ls and le then
                        if ls > start then
                            local str = string.sub(info.contentText, start, ls - 1)
                            text:pushBackElement(ccui.RichElementText:create(key, cc.c3b(61, 19, 10), 255, str, dp.FONT, FONTSIZE))
                        end
                        local str = string.sub(info.contentText, ls, le)
                        for bq in string.gmatch(str, "%d") do
                            if tonumber(bq) >= 1 and tonumber(bq) <= 9 then 
                                text:pushBackElement(ccui.RichElementImage:create(key, display.COLOR_WHITE, 255, "ui/bq0" .. tonumber(bq) .. ".png"))
                            else
                                text:pushBackElement(ccui.RichElementText:create(key, cc.c3b(61, 19, 10), 255, str , dp.FONT, FONTSIZE))
                            end
                        end
                        start = le + 1
                    else
                        local str = string.sub(info.contentText, start)
                        text:pushBackElement(ccui.RichElementText:create(key, cc.c3b(61, 19, 10), 255, str, dp.FONT, FONTSIZE))
                        break
                    end
                end
                text:setVerticalSpace(2)
                text:ignoreContentAdaptWithSize(true)
                text:formatText()
                local size = text:getVirtualRendererSize()
                if RECTWIDTH - 46 < size.width then
                    text:ignoreContentAdaptWithSize(false)
                    text:setContentSize(cc.size(RECTWIDTH - 46, FONTSIZE))
                    text:formatText()
                end
            end

            local size = text:getVirtualRendererSize()
            textBg:setContentSize(size.width + 46, size.height + 46)
            text:setPosition(textBg:getPositionX() +(isR and -1 or 1) * textBg:getContentSize().width / 2, textBg:getPositionY() - textBg:getContentSize().height / 2 + 4)
            if textBg:getPositionY() <= textBg:getContentSize().height then
                positionY = positionY + uiDialog1:getContentSize().height / 2 - textBg:getPositionY() + textBg:getContentSize().height
            else
                positionY = positionY + uiDialog1:getContentSize().height / 2
            end
            uiDialog1:setPositionY(positionY)

            local headIcon = ccui.Helper:seekNodeByName(uiDialog1, "image_title")
            local dictCard = DictCard[tostring(info.headId)]
            if dictCard then
                if tonumber(info.isAwake) == 1 then
                    headIcon:loadTexture("image/" .. DictUI[tostring(dictCard.awakeSmallUiId)].fileName)
                else
                    headIcon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
                end
            end
            headIcon:setTouchEnabled(true)
            headIcon:addTouchEventListener( function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local _info = tempchatInfo[uiDialog1:getTag() -100]
                    UIAllianceTalk.show( { playerId = _info.roleId, userName = _info.roleName, userLvl = _info.teamLvl, userFight = _info.fight, userUnio = _info.unioName, headId = _info.headId.."_".._info.isAwake, vip = _info.vipName })
                end
            end
            )

            local image_vip = ccui.Helper:seekNodeByName(uiDialog1, "image_vip")
            cclog("info.vipName .."..info.vipName)
            local vipIcon = image_vip:setVisible(tonumber(info.vipName) > 0)
            positionY = positionY - uiDialog1:getContentSize().height / 2 + image_vip:getPositionY() + image_vip:getContentSize().height / 2 + 20
        end

        uiView:setInnerContainerSize(cc.size(uiView:getContentSize().width, positionY))
        uiView:jumpToBottom()
    end
    isUpdate = false
end

local function setBtnTime(time)
    local sec = time % 60
    btn_go:setTitleText(string.format(Lang.ui_talk10, sec))
end

local function refreshBtn(index1, index2)
    if index1 ~= index2 then
        isUpdate = false
        if UITalk.time[index2] and UITalk.time[index2] ~= 0 then
            btn_go:setTouchEnabled(false)
            btn_go:setBright(false)
            setBtnTime(UITalk.time[index2])
        else
            btn_go:setTouchEnabled(true)
            btn_go:setBright(true)
            btn_go:setTitleText(Lang.ui_talk11)
        end
        if index1 == UITalk.TAG_WORLD and btn_world then
            btn_world:loadTextureNormal("ui/yh_btn01.png")
            btn_world:setTitleColor(cc.c4b(255, 255, 255, 255))
        elseif index1 == UITalk.TAG_UNION and btn_unio then
            btn_unio:loadTextureNormal("ui/yh_btn01.png")
            btn_unio:setTitleColor(cc.c4b(255, 255, 255, 255))
        elseif index1 == UITalk.TAG_PRIVATE_CHAT and btn_chat then
            btn_chat:loadTextureNormal("ui/yh_btn01.png")
            btn_chat:setTitleColor(cc.c4b(255, 255, 255, 255))
        end
        if index2 == UITalk.TAG_WORLD and btn_world then
            btn_world:loadTextureNormal("ui/yh_btn02.png")
            btn_world:setTitleColor(cc.c4b(51, 25, 4, 255))
            uiDialog_other:setVisible(false)
            ccui.Helper:seekNodeByName(UITalk.Widget, "image_shadow"):setVisible(false)
            ccui.Helper:seekNodeByName(UITalk.Widget, "image_bian"):setVisible(false)
        elseif index2 == UITalk.TAG_UNION and btn_unio then
            btn_unio:loadTextureNormal("ui/yh_btn02.png")
            btn_unio:setTitleColor(cc.c4b(51, 25, 4, 255))
            uiDialog_other:setVisible(false)
            ccui.Helper:seekNodeByName(UITalk.Widget, "image_shadow"):setVisible(false)
            ccui.Helper:seekNodeByName(UITalk.Widget, "image_bian"):setVisible(false)
        elseif index2 == UITalk.TAG_PRIVATE_CHAT and btn_chat then
            btn_chat:loadTextureNormal("ui/yh_btn02.png")
            btn_chat:setTitleColor(cc.c4b(51, 25, 4, 255))
            uiDialog_other:setVisible(true)
            ccui.Helper:seekNodeByName(UITalk.Widget, "image_shadow"):setVisible(true)
            ccui.Helper:seekNodeByName(UITalk.Widget, "image_bian"):setVisible(true)
        end
    end
end

local function updateTime()
    local keys = table.keys(UITalk.time)
    for i, key in ipairs(keys) do
        if UITalk.time[key] ~= 0 then
            UITalk.time[key] = UITalk.time[key] -1
        end
        if tag == key and UITalk.Widget and UITalk.Widget:getParent() and btn_go then
            if UITalk.time[key] ~= 0 then
                setBtnTime(UITalk.time[key])
            else
                btn_go:setTouchEnabled(true)
                btn_go:setBright(true)
                btn_go:setTitleText(Lang.ui_talk12)
            end
        end
        if UITalk.time[key] == 0 and UITalk.scheduleIds[key] then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(UITalk.scheduleIds[key])
            UITalk.scheduleIds[key] = nil
        end
    end

end

local function updateUser(userName)
    if otherName and userName then
        -- cclog("otherUserName : "..userName )
        otherName:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        otherName:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        otherName:setString(userName)
    end
end

local function updateTable(myTable)
    if myTable and #myTable > 50 then
        table.remove(myTable, 1)
    end
end

function UITalk.pushData(data)
    cclog("---->聊天推送")
    if data and data.msgdata and data.msgdata.int and data.msgdata.string then
        local info = { }
        info.channelType = data.msgdata.int["1"]

        if info.channelType == tag and UITalk.Widget and UITalk.Widget:getParent() then
            info.contentText = data.msgdata.string["2"]
            info.chatObjName = data.msgdata.string["4"]
            local otherInfo = data.msgdata.string["3"]
            local otherInfo1 = utils.stringSplit(otherInfo, "|")
            info.headId = tonumber(otherInfo1[1])
            info.roleName = otherInfo1[2]
            info.vipName = otherInfo1[3]
            info.teamLvl = otherInfo1[4]
            info.fight = otherInfo1[5]
            info.unio = otherInfo1[6]
            info.roleId = otherInfo1[7]
            info.unioName = otherInfo1[8]
            info.isAwake = otherInfo1[9]
            if tag == UITalk.TAG_WORLD then
                table.insert(UITalk.chatInfo, info)
                updateTable(UITalk.chatInfo)
            elseif tag == UITalk.TAG_UNION and tonumber(info.unio) == net.InstUnionMember.int["2"] then
                table.insert(UITalk.chatInfo_unio, info)
                updateTable(UITalk.chatInfo_unio)
            elseif tag == UITalk.TAG_PRIVATE_CHAT then
                if info.roleName == dp.getUserData().roleName or info.chatObjName == dp.getUserData().roleName then
                    table.insert(UITalk.chatInfo_user, info)
                    updateTable(UITalk.chatInfo_user)
                end
            end
            if UITalk.Widget and UITalk.Widget:getParent() then
                updateDialog(tag)
            end
        else
            info.contentText = data.msgdata.string["2"]
            info.chatObjName = data.msgdata.string["4"]
            local otherInfo = data.msgdata.string["3"]
            local otherInfo1 = utils.stringSplit(otherInfo, "|")
            info.headId = tonumber(otherInfo1[1])
            info.roleName = otherInfo1[2]
            info.vipName = otherInfo1[3]
            info.teamLvl = otherInfo1[4]
            info.fight = otherInfo1[5]
            info.unio = otherInfo1[6]
            info.roleId = otherInfo1[7]
            info.unioName = otherInfo1[8]
            info.isAwake = otherInfo1[9]
            local isShow = false
            if info.channelType == UITalk.TAG_WORLD then
                  table.insert( UITalk.chatInfo , info )
                  updateTable( UITalk.chatInfo )
            elseif info.channelType == UITalk.TAG_UNION and tonumber(info.unio) == net.InstUnionMember.int["2"] then
                table.insert(UITalk.chatInfo_unio, info)
                updateTable(UITalk.chatInfo_unio)
                isShow = true
                UITalk.unionF = 1
                if UITalk.Widget then
                    UITalk.flush()
                end
            elseif info.channelType == UITalk.TAG_PRIVATE_CHAT then
                if info.roleId == dp.getUserData().roleId or info.chatObjName == dp.getUserData().roleName then
                    table.insert(UITalk.chatInfo_user, info)
                    updateTable(UITalk.chatInfo_user)
                    isShow = true
                    UITalk.userF = 1
                end
                if UITalk.Widget then
                    UITalk.flush()
                end
            end
            if isShow and UITalkFly.layer then
                UITalkFly.showTips(true)
            end
        end
    end

end

function UITalk.init()
    image_base_bq = ccui.Helper:seekNodeByName(UITalk.Widget, "image_base_bq")
    image_base_bq:setVisible(false)
    local btn_biaoqing = ccui.Helper:seekNodeByName(UITalk.Widget, "btn_biaoqing")
    local btn_back = ccui.Helper:seekNodeByName(UITalk.Widget, "btn_close")
    uiDialog_other = ccui.Helper:seekNodeByName(UITalk.Widget, "image_name")
    otherName = ccui.Helper:seekNodeByName(uiDialog_other, "text_name")
    otherName:setLocalZOrder(10)
    btn_go = ccui.Helper:seekNodeByName(UITalk.Widget, "btn_go");
    local uiTextImg = ccui.Helper:seekNodeByName(UITalk.Widget, "image_talk")
    local uiBaseImg = ccui.Helper:seekNodeByName(UITalk.Widget, "image_basemap")
    btn_world = ccui.Helper:seekNodeByName(UITalk.Widget, "btn_word")
    btn_unio = ccui.Helper:seekNodeByName(UITalk.Widget, "btn_alliance")
    btn_chat = ccui.Helper:seekNodeByName(UITalk.Widget, "btn_ chat")
    uiDialog = ccui.Helper:seekNodeByName(UITalk.Widget, "image_frame_title")
    uiDialog:setVisible(false)
    uiDialog:retain()
    uiDialogR = ccui.Helper:seekNodeByName(UITalk.Widget, "image_frame_title_l")
    uiDialogR:setVisible(false)
    uiDialogR:retain()
    uiView = ccui.Helper:seekNodeByName(UITalk.Widget, "view_talk")
    
    checkBox = ccui.Helper:seekNodeByName(UITalk.Widget, "box_choose")
    local function tick(ref, type)
        if ref == checkBox then
            if type == ccui.CheckBoxEventType.selected then
                UITalkFly.curState = 1
                cc.UserDefault:getInstance():setIntegerForKey("showFly", 1)
                UITalkFly.show()
            else
                UITalkFly.curState = 0
                cc.UserDefault:getInstance():setIntegerForKey("showFly", 0)
                UITalkFly.hide()
            end
        end
    end
    checkBox:addEventListener(tick)
    
    local btn_bq = { }
    for i = 1, 9 do
        table.insert(btn_bq, ccui.Helper:seekNodeByName(image_base_bq, "btn" .. i))
    end
    local function compareTwoStr( str1 )   
        local str2 = cc.UserDefault:getInstance():getStringForKey ("talk1" , "")
        local str3 = cc.UserDefault:getInstance():getStringForKey ("talk2" , "" )
--        if str2 and str2 ~= "" and str3 and str3 ~= "" and utils.utf8len( str1 ) < 30 then
--            cc.UserDefault:getInstance():setStringForKey("talk1", str3)
--            cc.UserDefault:getInstance():setStringForKey("talk2", str1)
--            return false
--        end     

        local len1 = string.len( str1 )
 --       cclog( "len1 :" .. len1.. str1 .. utils.utf8len( str1 ) )
--        local len2 = string.len( str2 )
        local strT1 = {}
        local i = 1
        while i <= len1 do
            local a = string.sub( str1 , i , i )
            if string.byte( a ) > 127 then
                table.insert( strT1 , string.sub( str1 , i , i + 2 ) )
                i = i + 3
            else
                table.insert( strT1 , a )
                i = i + 1
            end        
--            cclog( strT1[#strT1] )  
        end
--        local strT2 = {}
--        i = 1
--        while i <= len1 do
--            local a = string.sub( str2 , i , i )
--            if string.byte( a ) > 127 then
--                table.insert( strT2 , string.sub( str2 , i , i + 2 ) )
--                i = i + 3
--            else
--                table.insert( strT2 , a )
--                i = i + 1
--            end 
--            cclog( strT2[#strT2] )  
--        end
     --   cclog( "str2 :"..str2 )
        local sameCount = 0
        if str2 and str2 ~= "" then
            for key ,value in pairs( strT1 ) do
                if string.find( str2 , value ) then
                    sameCount = sameCount + 1
                end
            end
    --        cclog( "sameCount :" .. sameCount .. "  " .. #strT1 .. "  " ..  utils.utf8len( str2 ) )
            if sameCount >= 10 and ( sameCount > #strT1 / 2 or sameCount > utils.utf8len( str2 ) / 2  ) then
                return true
            end
        end
        
        sameCount = 0
        
      --  cclog( "str3 :"..str3 )
        if str3 and str3 ~= "" then
            for key ,value in pairs( strT1 ) do
                if string.find( str3 , value ) then
                    sameCount = sameCount + 1
                end
            end
     --       cclog( "sameCount1 :" .. sameCount )
            if sameCount >= 10 and ( sameCount > #strT1 / 2 or sameCount > utils.utf8len( str3 ) / 2 ) then
                return true
            end
        end
        if utils.utf8len( str1 ) >= 15 then
            cc.UserDefault:getInstance():setStringForKey("talk1", str3)
            cc.UserDefault:getInstance():setStringForKey("talk2", str1)
        end
        return false
    end
    local function onBtnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                image_base_bq:setVisible(false)
                UIManager.popScene()
            elseif sender == btn_go then
                local text = uiText:getText()
                if utils.utf8len(text) == 0 then
                    UIManager.showToast(Lang.ui_talk13)
                elseif utils.utf8len(text) > 50 then
                    UIManager.showToast(Lang.ui_talk14)
                elseif #text > 0 then
                    -- 聊天内容 --其他信息：头像卡牌Id_角色名_vip等级_战队等级_战力_所属联盟
                    if tag == UITalk.TAG_UNION and(not net.InstUnionMember or(net.InstUnionMember and net.InstUnionMember.int["2"] == 0)) then
                        UIManager.showToast(Lang.ui_talk15)
                    elseif tag == UITalk.TAG_WORLD and dp.getUserData().roleLevel < 16 then
                        UIManager.showToast(Lang.ui_talk16)
                    elseif tag == UITalk.TAG_WORLD and utils.getFightValue() <= 70000 then
                        UIManager.showToast(Lang.ui_talk17)
                    elseif tag == UITalk.TAG_PRIVATE_CHAT and dp.getUserData().roleLevel < 10 then
                        UIManager.showToast(Lang.ui_talk18)
                    else
                        if tag == UITalk.TAG_WORLD and compareTwoStr( uiText:getText() ) then
                            return
                        end
                        local role = dp.getUserData()
                        local unioId = "0"
                        if net.InstUnionMember then
                            unioId = tostring(net.InstUnionMember.int["2"])
                        end
                        local chatName = ""
                        if tag == UITalk.TAG_PRIVATE_CHAT and otherNameText then
                            chatName = otherName:getString()
                            cclog("chatName :" .. chatName)
                        end
                        UIManager.showLoading()
                        netSendPackage(
                        {
                            header = StaticMsgRule.chat,
                            msgdata =
                            {
                                int = { channelType = tag },
                                string =
                                {
                                    content = uiText:getText(),
                                    chatObjName = chatName,
                                    otherSendInfo = tostring(net.InstPlayer.int["32"]) .. "|" .. role.roleName .. "|" .. tostring(role.vipLevel) .. "|" .. tostring(net.InstPlayer.int["4"] .. "|" .. tostring(utils.getFightValue()) .. "|" .. unioId .. "|" .. tostring(role.roleId))
                                }
                            }
                        } , netCallbackFunc)
                        --
                        uiText:setText("")
                        if tag == UITalk.TAG_WORLD or tag == UITalk.TAG_UNION then
                            UITalk.time[tag] = 5
                            btn_go:setTouchEnabled(false)
                            btn_go:setBright(false)
                            setBtnTime(UITalk.time[tag])
                            UITalk.scheduleIds[tag] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTime, 1, false)
                        end
                    end
                end
            elseif sender == btn_world then
                -- cclog( "btn_world"..tag )
                if tag ~= UITalk.TAG_WORLD then
                    refreshBtn(tag, 1)
                    updateDialog(1)
                end
            elseif sender == btn_unio then
                -- cclog( "btn_unio"..tag )
                if tag ~= 2 then
                    UITalk.unionF = nil
                    UITalk.flush()
                    refreshBtn(tag, 2)
                    updateDialog(2)
                end
            elseif sender == btn_chat then
                -- cclog( "btn_chat" )
                if tag ~= 3 then
                    UITalk.userF = nil
                    UITalk.flush()
                    refreshBtn(tag, 3)
                    updateDialog(3)
                    updateUser("")
                end
            elseif sender == btn_biaoqing then
                -- cclog("send biaoqing")
                if not image_base_bq:isVisible() then
                    image_base_bq:setVisible(true)
                else
                    image_base_bq:setVisible(false)
                end
            else
                if image_base_bq:isVisible() then
                    for i = 1, 9 do
                        if sender == btn_bq[i] then
                            local te = uiText:getText()
                            if string.find(te, "#", string.len(te)) then
                                uiText:setText(te .. i .. "#")
                            else
                                uiText:setText(te .. "#" .. i .. "#")
                            end
                            image_base_bq:setVisible(false)
                        end
                    end
                end
            end
        end
    end
    btn_back:addTouchEventListener(onBtnEvent)
    btn_go:addTouchEventListener(onBtnEvent)
    btn_unio:addTouchEventListener(onBtnEvent)
    btn_world:addTouchEventListener( onBtnEvent )
    btn_chat:addTouchEventListener(onBtnEvent)
    btn_biaoqing:addTouchEventListener(onBtnEvent)
    for i = 1, 9 do
        btn_bq[i]:addTouchEventListener(onBtnEvent)
    end

    uiText = cc.EditBox:create(uiTextImg:getContentSize(), ccui.Scale9Sprite:create("ui/zb_k04.png"))
    uiText:setPosition(uiTextImg:getPosition())
    uiText:setMaxLength(50)
    uiText:setName("uiText")
    uiBaseImg:addChild(uiText, 1)
    uiTextImg:removeFromParent()
    uiTextImg = nil

    local function editboxEventHandler(eventType)
        if eventType == "began" then
            -- 当编辑框获得焦点并且键盘弹出的时候被调用

        elseif eventType == "ended" then
            -- 当编辑框失去焦点并且键盘消失的时候被调用
            otherName:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            otherName:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            otherName:setString(otherNameText:getText())
            otherNameText:setText("")
        elseif eventType == "changed" then
            -- 当编辑框的文本被修改的时候被调用
        elseif eventType == "return" then
            -- 当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
        end
    end

    otherNameText = cc.EditBox:create(uiDialog_other:getContentSize(), ccui.Scale9Sprite:create("ui/mg_mingzi_k.png"))
    otherNameText:setFontSize(20)
    -- otherNameText:setMaxLength( 8 )
    otherNameText:setPosition(otherName:getPosition())
    uiDialog_other:addChild(otherNameText, 1)
    otherNameText:registerScriptEditBoxHandler(editboxEventHandler)
    -- otherName:removeFromParent()
    -- otherName = nil
    -- uiView:setInnerContainerSize( cc.size( uiView:getContentSize().width , 1200 ) )

    local function editboxEventHandler1(eventType)
        if eventType == "began" then
            -- 当编辑框获得焦点并且键盘弹出的时候被调用

            local te = uiText:getText()
            uiText:setText(te)
        elseif eventType == "ended" then
            -- 当编辑框失去焦点并且键盘消失的时候被调用
            -- local te = uiText:getText()
            -- uiText:setText( te )
        elseif eventType == "changed" then
            -- 当编辑框的文本被修改的时候被调用
        elseif eventType == "return" then
            -- 当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
            -- local te = uiText:getText()
            --  uiText:setText( te )
        end
    end
    uiText:registerScriptEditBoxHandler(editboxEventHandler1)
end
function UITalk.freshToUser(name)
    if tag ~= 3 then
        refreshBtn(tag, 3)
        updateDialog(3)
    end
    updateUser(name)
end

function UITalk.setup()
    -- netSendPackage({header = StaticMsgRule.openChatWindow, msgdata = {}} , netCallbackFunc )
    uiDialog_other:setVisible(false)
    refreshBtn(0, 1)
    updateDialog(1)
    if UITalkFly.layer then
        if UITalkFly.isVisible() then
            checkBox:setSelected(true)
        else
            checkBox:setSelected(false)
        end
        UITalkFly.showTips(false)
    end
    UITalk.flush()
end

function UITalk.flush()
    if UITalk.Widget and btn_unio and btn_chat then
        local unionImg = ccui.Helper:seekNodeByName(btn_unio, "image_hint")
        local chatImg = ccui.Helper:seekNodeByName(btn_chat, "image_hint")
        if UITalk.unionF then
            unionImg:setVisible(true)
        else
            unionImg:setVisible(false)
        end
        if UITalk.userF then
            chatImg:setVisible(true)
        else
            chatImg:setVisible(false)
        end
        if not UITalk.unionF and not UITalk.userF then
            UITalkFly.showTips(false)
        end
    end
end

function UITalk.onEnter()

end

function UITalk.free()
    if UITalk.Widget then
        if uiDialog then
            uiDialog:release()
            uiDialog = nil
        end
        if uiDialogR then
            uiDialogR:release()
            uiDialogR = nil
        end
    end
end
