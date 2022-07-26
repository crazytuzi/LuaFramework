require"Lang"
UIFightActivityChoose={}
local barrierLevel = 1
local chapter ={}
local activityBarrierTimes =nil
local scrollView= nil
local thingItem= nil
local dropThing={}
local sDropThing = {}
local _dropThings = nil
local ui_text_left_number = nil
local  flag = nil
local isFirstAccess = true
UIFightActivityChoose.wingTo = false
local function setLocalOrder(_tag)
    local image_card_difficulty = {}
    for i =1,3 do  
        image_card_difficulty[i] = ccui.Helper:seekNodeByName(UIFightActivityChoose.Widget, "image_card_difficulty" .. i)
        local image_bg = ccui.Helper:seekNodeByName(UIFightActivityChoose.Widget, "image_base_difficulty" .. i)
        if _tag == i then 
            image_bg:setLocalZOrder(1)
        else 
            image_bg:setLocalZOrder(0)
        end
    end
    for key,obj in pairs(DictBarrier) do
        if chapter.chapterId == obj.chapterId and barrierLevel ==  obj.type  then
            chapter.barrierId = obj.id
            chapter.openLevel = obj.openLevel
            local cardId = obj.cardId
            local bigUiId = DictCard[tostring(cardId)].bigUiId
            local imageName = DictUI[tostring(bigUiId)].fileName
            image_card_difficulty[barrierLevel]:loadTexture("image/" .. imageName)
        elseif chapter.chapterId == obj.chapterId and barrierLevel ~=  obj.type  then
            local cardId = obj.cardId
            local bigUiId = DictCard[tostring(cardId)].bigUiId
            local imageName = DictUI[tostring(bigUiId)].fileName
            image_card_difficulty[obj.type]:loadTexture("image/" .. imageName)
        end
    end
end

local function setScrollViewItem(_item,objTable , isSpecial )
    local thingIcon = _item:getChildByName("image_good")
    if isSpecial then
        _item:getChildByName("image_title"):setVisible( true )
    else
        _item:getChildByName("image_title"):setVisible( false )
    end
    local thingName = thingIcon:getChildByName("text_good_name")
    local tableTypeId,tableFieldId, thingNum = objTable[1], objTable[2], objTable[3]
    local name,Icon = utils.getDropThing(tableTypeId,tableFieldId)
    thingName:setString(name)
    thingIcon:loadTexture(Icon)
    --utils.addBorderImage(tableTypeId,tableFieldId,_item)
    if isSpecial then
       _item:loadTexture("ui/quality_teshu.png")
    else
       utils.addBorderImage(tableTypeId,tableFieldId,_item)
    end

end
local function scrollviewUpdate()
    local tt = {}
    for key ,value in pairs( dropThing ) do
        tt[#tt + 1 ] = value
    end
    for key ,value in pairs( sDropThing ) do
        tt[#tt + 1 ] = value
    end
    for i = 1 , #tt do
        local obj = tt[ i ]
       local Item = thingItem:clone()
       if i <= #dropThing then
            setScrollViewItem(Item, obj)
       else
            setScrollViewItem(Item, obj ,true)
       end
       scrollView:addChild(Item)
    end
end
function UIFightActivityChoose.init()
    local btn_close = ccui.Helper:seekNodeByName(UIFightActivityChoose.Widget, "btn_close")
    local btn_fight = ccui.Helper:seekNodeByName(UIFightActivityChoose.Widget, "btn_fight")
    local btn_one = ccui.Helper:seekNodeByName(UIFightActivityChoose.Widget, "btn_one")
    btn_close:setPressedActionEnabled(true)
    btn_fight:setPressedActionEnabled(true)
    btn_one:setPressedActionEnabled(true)
    local image_card_difficulty ={}
    local btn_add = ccui.Helper:seekNodeByName(UIFightActivityChoose.Widget, "btn_add")
    ui_text_left_number = ccui.Helper:seekNodeByName( UIFightActivityChoose.Widget , "text_left_number")
    btn_add:setEnabled(false)
    btn_add:setVisible( false )
    local function TouchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender== btn_close then 
                AudioEngine.playEffect("sound/button.mp3")
                UIManager.popScene()
                if UIFightActivityChoose.wingTo then
                    UILineup.friendState = 0
                    UIManager.showWidget("ui_notice", "ui_lineup")
                    UIManager.showWidget("ui_menu")
                    UILineup.toWingInfo()
--                    UIManager.pushScene("ui_wing_info")
--                    local btn_medicine = ccui.Helper:seekNodeByName(UIWingInfo.Widget, "btn_intensify")
--                    btn_medicine:releaseUpEvent()
                end
            elseif sender == btn_add then 
                AudioEngine.playEffect("sound/button.mp3")
                if activityBarrierTimes > 0 then 
                    UIManager.showToast(Lang.ui_fight_activity_choose1)
                else
                    local buyNum =0
                    local haveBarrierNum =0 
                    local instPlayerChapterId = nil
                    for key,ActivityObj in pairs(net.InstPlayerChapter) do
                        if ActivityObj.int["3"] == chapter.chapterId then
                            haveBarrierNum = ActivityObj.int["4"]
                            if ActivityObj.int["8"] ~= nil then 
                               buyNum = ActivityObj.int["8"]
                            end
                            instPlayerChapterId = ActivityObj.int["1"]
                        end
                    end
                    local VipNum = net.InstPlayer.int["19"]
                    local baseMoney = DictSysConfig[tostring(StaticSysConfig.activityChapterInitGold)].value
                    local oneAddMoney  = DictSysConfig[tostring(StaticSysConfig.activityChapterInitGoldAdd)].value
                    local BuyBarrierTimeMoney  = baseMoney + buyNum*oneAddMoney
                    local VipTime = 0
                    if chapter.chapterId == DictSysConfig[tostring(StaticSysConfig.slbz)].value then 
                        VipTime= DictVIP[tostring(VipNum+1)].silverActivityChapterBuyTimes
                    elseif chapter.chapterId == DictSysConfig[tostring(StaticSysConfig.tsxc)].value then 
                        VipTime= DictVIP[tostring(VipNum+1)].talentActivityChapterBuyTimes
                    elseif chapter.chapterId == DictSysConfig[tostring(StaticSysConfig.yhgt)].value then 
                        VipTime= DictVIP[tostring(VipNum+1)].expActivityChapterBuyTimes
                    elseif chapter.chapterId == DictSysConfig[tostring(StaticSysConfig.wysm)].value then 
                        VipTime= DictVIP[tostring(VipNum+1)].soulActivityChapterBuyTimes
                    end
                    local prompt = Lang.ui_fight_activity_choose2 .. BuyBarrierTimeMoney ..Lang.ui_fight_activity_choose3 .. buyNum .. Lang.ui_fight_activity_choose4 .. VipNum .. Lang.ui_fight_activity_choose5 .. VipTime ..Lang.ui_fight_activity_choose6
                    if instPlayerChapterId~= nil then
                        if VipNum == 0 then
                            UIManager.showToast(Lang.ui_fight_activity_choose7)
                            return
                        end
                        if buyNum < VipTime then 
                            utils.PromptDialog(UIFight.sendActivityBarrierTimeRequest,prompt,instPlayerChapterId)
                        else
                            UIManager.showToast(Lang.ui_fight_activity_choose8)
                        end
                    else
                        UIManager.showToast(Lang.ui_fight_activity_choose9)
                    end
                end
            elseif sender == image_card_difficulty[1] then
                barrierLevel =1
                UIFightActivityChoose.setup()
            elseif sender == image_card_difficulty[2] then
                barrierLevel =2 
                UIFightActivityChoose.setup()
            elseif sender == image_card_difficulty[3] then
                barrierLevel =3
                UIFightActivityChoose.setup()
            elseif sender == btn_fight then
                AudioEngine.playEffect("sound/fight.mp3")
                if activityBarrierTimes > 0 then
                    local nowLevel = net.InstPlayer.int["4"]
                    if nowLevel >= chapter.openLevel then 
                        for key,obj in pairs(DictBarrierLevel) do
                            if obj.barrierId == chapter.barrierId and obj.level == barrierLevel then 
                                chapter.barrierLevelId = obj.id
                            end
                        end
                        UIManager.popScene()
                        utils.sendFightData(chapter,dp.FightType.FIGHT_TASK.ACTIVITY)
                        UIFightMain.loading()
                        cc.UserDefault:getInstance():setIntegerForKey("UIFightActivityChooseBarrierLevel",barrierLevel)
                    else
                        UIManager.showToast(string.format(Lang.ui_fight_activity_choose10,chapter.openLevel))
                    end
                else
                    UIManager.showToast(Lang.ui_fight_activity_choose11)
                end
            elseif sender == btn_one then
                AudioEngine.playEffect("sound/fight.mp3")

                if activityBarrierTimes > 0 then
                    local nowLevel = net.InstPlayer.int["4"]
                    if nowLevel >= chapter.openLevel then
                    else
                        UIManager.showToast(string.format(Lang.ui_fight_activity_choose12,chapter.openLevel))
                        return
                    end
                else
                    UIManager.showToast(Lang.ui_fight_activity_choose13)
                    return
                end

                if net.InstPlayer.int["19"] >= 5 or net.InstPlayer.int["4"] >= 65 then
                    UIManager.showLoading()
                    netSendPackage( {
                        header = StaticMsgRule.activityWar,
                        msgdata =
                        {
                            int =
                            {
                                ghostId = 1, --加入此参数表示扫荡
                                barrierId = chapter.barrierId,
                            }
                        }
                    } , function(_msgData)
                        
                        local dropData = { }
                        local dropIds = { }
                        if _msgData.msgdata.string["1"] then
                            dropIds = utils.stringSplit(_msgData.msgdata.string["1"], ";")
                            -- 副本获得掉落字典表ID
                        end
                        if _msgData.msgdata.string["2"] then
                            local sThings = utils.stringSplit(_msgData.msgdata.string["2"], ";")
                            for key ,value in pairs( sThings ) do
                                table.insert( dropIds , value )
                            end
                        end
                        for key, id in pairs(dropIds) do
                            local data = utils.stringSplit(id, "_")
                            local flag = false
                            if next(dropData) then
                                for _key, _obj in pairs(dropData) do
                                    if _obj.id == id then
                                        flag = true
                                        _obj.num = _obj.num + 1
                                    end
                                end
                            end
                            if flag == false then
                                local _data = { }
                                _data.id = id
                                _data.tableTypeId = data[1]
                                _data.tableFieldId = data[2]
                                _data.value = data[3]
                                _data.num = 1
                                table.insert(dropData, _data)
                            end
                        end
                        local _itemThings = ""
                        for key, obj in pairs(dropData) do
                            local _value = 0
                            if tonumber(obj.tableTypeId) ~= StaticTableType.DictCard then
                                _value = obj.num * obj.value
                            else
                                _value = obj.num
                            end
                            _itemThings = _itemThings .. obj.tableTypeId .. "_" .. obj.tableFieldId .. "_" .. _value
                            if key ~= #dropData then
                                _itemThings = _itemThings .. ";"
                            end
                        end
                        UIAwardGet.setOperateType(UIAwardGet.operateType.award, utils.stringSplit(_itemThings, ";"))
                        UIManager.pushScene("ui_award_get")

                        UIManager.flushWidget(UIFight)
                        UIManager.flushWidget(UIFightActivityChoose)
                    end )
                else
                    UIManager.showToast(Lang.ui_fight_activity_choose14)
                end
            end
        end
    end
    for i=1,3 do
        image_card_difficulty[i] =ccui.Helper:seekNodeByName(UIFightActivityChoose.Widget, "image_card_difficulty" .. i)
        image_card_difficulty[i]:addTouchEventListener(TouchEvent)
        image_card_difficulty[i]:setEnabled(true)
        image_card_difficulty[i]:setTouchEnabled(true)
    end
    btn_close:addTouchEventListener(TouchEvent)
    btn_fight:addTouchEventListener(TouchEvent)
    btn_one:addTouchEventListener(TouchEvent)
   -- btn_add:addTouchEventListener(TouchEvent)
    scrollView = ccui.Helper:seekNodeByName(UIFightActivityChoose.Widget, "view_get")
    thingItem = scrollView:getChildByName("image_frame_good"):clone()
    if thingItem:getReferenceCount() == 1 then
       thingItem:retain()
    end
end
function UIFightActivityChoose.setup()
    
    scrollView:removeAllChildren()
    if isFirstAccess then
        local tempLevel = cc.UserDefault:getInstance():getIntegerForKey("UIFightActivityChooseBarrierLevel",1)
        isFirstAccess = false
        barrierLevel = tempLevel
    end
    setLocalOrder(barrierLevel)
    dropThing = {}
    sDropThing = {}
    
    if chapter.barrierId ~= nil then
        local things = DictBarrier[tostring(chapter.barrierId)].things
        if chapter.chapterId == DictSysConfig[tostring(StaticSysConfig.wysm)].value then
            things = _dropThings[barrierLevel]
        end
        local thingsTable = utils.stringSplit(things,";")
        for key,obj in pairs(thingsTable) do
             dropThing[#dropThing+1] = utils.stringSplit(obj,"_")
        end
    end

    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.sendActivityDrop , msgdata = { int = { chapterId = tonumber( chapter.chapterId ) }} } , function (pack)
        local sThings = pack.msgdata.string["1"]
        local ssThings = {}
        if sThings then
            ssThings = utils.stringSplit( sThings , ";" )
        end
        for key ,value in pairs( ssThings ) do
            sDropThing[ #sDropThing + 1 ] = utils.stringSplit( value , "_")
        end
        if next(dropThing) or next( sDropThing ) then
            scrollviewUpdate()
            local innerHieght, space, _col = 0, 15, 4
            local childs = scrollView:getChildren()
            if #childs < _col then
              innerHieght = thingItem:getContentSize().height + thingItem:getChildByName("image_good"):getChildByName("text_good_name"):getContentSize().height + space
            elseif #childs % _col == 0 then
              innerHieght = (#childs / _col) * (thingItem:getContentSize().height + thingItem:getChildByName("image_good"):getChildByName("text_good_name"):getContentSize().height + space) + space
            else
              innerHieght = math.ceil(#childs / _col) * (thingItem:getContentSize().height + thingItem:getChildByName("image_good"):getChildByName("text_good_name"):getContentSize().height + space) + space
            end
            if innerHieght < scrollView:getContentSize().height then
              innerHieght = scrollView:getContentSize().height
            end
            scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, innerHieght))
        
            local prevChild = nil
            local _tempI, x, y = 1, 0, 0
            for i = 1, #childs do
              x = _tempI * (scrollView:getContentSize().width / _col) - (scrollView:getContentSize().width / _col) / 2
              _tempI = _tempI + 1
              if i < _col then
                y = scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - space
                prevChild = childs[i]
                childs[i]:setPosition(cc.p(x, y))
              elseif i % _col == 0 then
                childs[i]:setPosition(cc.p(x, y))
                y = prevChild:getBottomBoundary() - prevChild:getChildByName("image_good"):getChildByName("text_good_name"):getContentSize().height - childs[i]:getContentSize().height / 2 - space
                _tempI = 1
                prevChild = childs[i]
              else
                y = prevChild:getBottomBoundary() - prevChild:getChildByName("image_good"):getChildByName("text_good_name"):getContentSize().height - childs[i]:getContentSize().height / 2 - space
                childs[i]:setPosition(cc.p(x, y))
              end
            end
        end
    end)

    
    local DictChapterObj = DictChapter[tostring(chapter.chapterId)]
    local haveBarrierNum =0
    if net.InstPlayerChapter then
        for key,ActivityObj in pairs(net.InstPlayerChapter) do
            if ActivityObj.int["3"] == DictChapterObj.id then
                haveBarrierNum = ActivityObj.int["4"]
            end
        end
    end
    
    
    activityBarrierTimes = DictChapterObj.fightNum - haveBarrierNum
    if flag and flag == 3 then
        local VipNum = net.InstPlayer.int["19"] 
        if VipNum >= 0 then
            local VipTime1 = 0
            if chapter.chapterId == DictSysConfig[tostring(StaticSysConfig.slbz)].value then 
                VipTime1= DictVIP[tostring(VipNum+1)].silverActivityChapterBuyTimes
            elseif chapter.chapterId == DictSysConfig[tostring(StaticSysConfig.tsxc)].value then 
                VipTime1= DictVIP[tostring(VipNum+1)].talentActivityChapterBuyTimes
            elseif chapter.chapterId == DictSysConfig[tostring(StaticSysConfig.yhgt)].value then 
                VipTime1= DictVIP[tostring(VipNum+1)].expActivityChapterBuyTimes
            elseif chapter.chapterId == DictSysConfig[tostring(StaticSysConfig.wysm)].value then 
                VipTime1= DictVIP[tostring(VipNum+1)].soulActivityChapterBuyTimes
            elseif chapter.chapterId == DictSysConfig[tostring(StaticSysConfig.shcx)].value then 
                VipTime1= DictVIP[tostring(VipNum+1)].wingChapterNum
            elseif chapter.chapterId == DictSysConfig[tostring(StaticSysConfig.jxcl)].value then
                VipTime1 = DictVIP[tostring(VipNum + 1)].awareChapterNum
            end
           activityBarrierTimes = activityBarrierTimes + VipTime1
        end
        
    end
     
    ui_text_left_number:setString(string.format(Lang.ui_fight_activity_choose15,activityBarrierTimes))
end
function UIFightActivityChoose.setChapter(_chapterId , _flag , _things)
    chapter.chapterId =_chapterId
    barrierLevel =1
    flag = _flag
    if chapter.chapterId == DictSysConfig[tostring(StaticSysConfig.wysm)].value then
        _dropThings = _things
    end
end

function UIFightActivityChoose.free()
    isFirstAccess = true
    if thingItem and thingItem:getReferenceCount() >= 1 then
       thingItem:release()
       thingItem = nil
    end
    if scrollView then
        scrollView:removeAllChildren()
        scrollView = nil
    end
    flag = nil
    _dropThings = nil
end
