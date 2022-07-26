require"Lang"
UIWingInfo={}
local _cardData = nil
local _curPageViewIndex = nil
local _toPageViewIndex = 0
local ui_pageViewItem = nil
local ui_pageView = nil
local thingData = nil
local function netCallBack( data )
    UIManager.flushWidget( UIWingInfo )
    UIManager.flushWidget( UILineup )
end
local function sendData()
    local sendData = {
        header = StaticMsgRule.wingPutOff ,
        msgdata = {
            int = {
                instPlayerWingId = thingData.int["1"]
            }
        }
    }
    netSendPackage( sendData , netCallBack )
end
local function getLineupData( _cardId )
	local cardData = {}
    if _cardId then
        cardData[1] = {}
        cardData[1].dictId = net.InstPlayerCard[ tostring(_cardId) ].int["3"]         
	    cardData[1].instId = _cardId
        return cardData
    end
    if UILineup.friendState == 1 then
        local formation1 = {}
	    for key, obj in pairs(net.InstPlayerFormation) do
		    if obj.int["4"] == 3 and obj.int["10"] > 0 then	--小伙伴
			    formation1[#formation1 + 1] = obj
		    end
	    end
	    local function compareFunc(obj1, obj2)
		    if obj1.int["10"] > obj2.int["10"] then
			    return true
		    end
		    return false
	    end
	    utils.quickSort(formation1, compareFunc)
	    for i = 1, (#formation1) do
		    local obj = nil
		    if formation1[i] then
			    obj = formation1[i]
		    end
		    if obj then
			    if cardData[i] == nil then
				    cardData[i] = {}
			    end
			    cardData[i].dictId = obj.int["6"]           
			    cardData[i].instId = obj.int["3"]
       --         cclog( "---------------->"..obj.int["6"].."  "..obj.int["3"].. "   "..obj.int["1"] )
		    end
	    end
    else
	    local formation1, formation2 = {}, {}
	    for key, obj in pairs(net.InstPlayerFormation) do
		        if obj.int["4"] == 1 then	--主力
			        formation1[#formation1 + 1] = obj
		        elseif obj.int["4"] == 2 then --替补
			        formation2[#formation2 + 1] = obj
		        end
	    end
	    local function compareFunc(obj1, obj2)
		    if obj1.int["1"] > obj2.int["1"] then
			    return true
		    end
		    return false
	    end
	    utils.quickSort(formation1, compareFunc)
	    utils.quickSort(formation2, compareFunc)
	    for i = 1, (#formation1 + #formation2) do
		    local obj = nil
		    if formation1[i] then
			    obj = formation1[i]
		    elseif formation2[i - #formation1] then
			    obj = formation2[i - #formation1]
		    end
		    if obj then
			    if cardData[i] == nil then
				    cardData[i] = {}
			    end
			    cardData[i].dictId = obj.int["6"]           
			    cardData[i].instId = obj.int["3"]
       --         cclog( "---------------->"..obj.int["6"].."  "..obj.int["3"].. "   "..obj.int["1"] )
		    end
	    end
    end
	return cardData
end
local function propThing( obj )
    thingData = nil
    if net.InstPlayerWing then
        for key , value in pairs( net.InstPlayerWing ) do
            if value.int["6"] == obj.instId then
                thingData = value               
                break
            end
        end
    end
    local btn_change = ccui.Helper:seekNodeByName( UIWingInfo.Widget , "btn_change" )
    if thingData then
        btn_change:loadTextureNormal( "ui/change.png" )
        btn_change:loadTexturePressed( "ui/change.png" )       
    else
        btn_change:loadTextureNormal( "ui/wing_dress.png" )
        btn_change:loadTexturePressed( "ui/wing_dress.png" )
    end
    local image_name = ccui.Helper:seekNodeByName( UIWingInfo.Widget , "image_name" )
    image_name:getChildByName("text_name"):setString(Lang.ui_wing_info1)
    local image_quality = ccui.Helper:seekNodeByName( UIWingInfo.Widget , "image_quality" )
    --image_quality:setString("羽毛属性")
    local image_down = ccui.Helper:seekNodeByName( UIWingInfo.Widget , "image_down" )
    ccui.Helper:seekNodeByName( image_down , "text_name" ):setString(Lang.ui_wing_info2)
    ccui.Helper:seekNodeByName( image_down , "text_lv" ):setString("")
    local image_wing_di = ccui.Helper:seekNodeByName( UIWingInfo.Widget , "image_wing_di" )
    for i = 1 , 8 do
--        local text_name = image_wing_di:getChildByName( "text_name"..i )
--        text_name:setString( "属性："..i )
        local text_add = image_wing_di:getChildByName( "text_add"..i )
        text_add:setVisible( false )
    end
    local cardWingLucks = nil
        for key  ,value in pairs(DictWingLuck) do
            if value.cardId == obj.dictId then
                cardWingLucks = value
                break
            end
        end
    local image_wing_luck = ccui.Helper:seekNodeByName(UIWingInfo.Widget ,"image_wing_luck")

    local btn_up = ccui.Helper:seekNodeByName( UIWingInfo.Widget , "btn_up" )
    if thingData then
        local strengthenData , advanceData , proShow = utils.getWingInfo( thingData.int["3"] , thingData.int["4"] , thingData.int["5"] , image_wing_di , false )
        image_name:getChildByName("text_name"):setVisible( true )
        image_name:getChildByName("text_name"):setString(DictWing[tostring(thingData.int["3"])].name)
        image_quality:setVisible( true )
        if  thingData.int["3"] >= 5 then
            image_quality:loadTexture( "ui/wing_all.png" )
        else
            image_quality:loadTexture( "ui/wing_"..DictWing[ tostring( thingData.int["3"] ) ].sname..".png" )
        end
        local str = Lang.ui_wing_info3
        if thingData.int["5"] == 1 then
        elseif thingData.int["5"] == 2 then
            str = Lang.ui_wing_info4
        elseif thingData.int["5"] == 3 then
            str = Lang.ui_wing_info5
        end
        ccui.Helper:seekNodeByName( image_down , "text_name" ):setTextColor(cc.c3b(255,255,255))
        ccui.Helper:seekNodeByName( image_down , "text_name" ):setString(str)
        ccui.Helper:seekNodeByName( image_down , "text_lv" ):setString("LV." .. thingData.int["4"])
        local pageViewItem = ui_pageView:getPage(_curPageViewIndex)
        local actionName = DictWing[tostring(thingData.int["3"])].actionName
        if actionName and actionName ~= "" then
            utils.addArmature( pageViewItem , 54 + thingData.int["5"] , actionName , pageViewItem:getContentSize().width / 2, pageViewItem:getContentSize().height / 2 - 30 , -2 , pageViewItem:getChildByName("image_card"):getScale() )
        else
            utils.addArmature( pageViewItem , 54 + thingData.int["5"] , "0"..thingData.int["5"]..DictWing[tostring(thingData.int["3"])].sname , pageViewItem:getContentSize().width / 2, pageViewItem:getContentSize().height / 2 - 30 , -2 , pageViewItem:getChildByName("image_card"):getScale() )
        end
        btn_up:setVisible( false )
        
        if cardWingLucks then
            local wingLucks = utils.stringSplit( cardWingLucks.lucks , ";" )
            local wingDes = utils.stringSplit( cardWingLucks.description , "#" )           
            for i = 1 , 3 do
                local wingLuckName = image_wing_luck:getChildByName("text_name_wing"..i)
                if i == 1 then
                    wingLuckName:setString(Lang.ui_wing_info6..wingDes[i])
                elseif i == 2 then
                    wingLuckName:setString(Lang.ui_wing_info7..wingDes[i])
                elseif i == 3 then
                    wingLuckName:setString(Lang.ui_wing_info8..wingDes[i])
                end
                local str = ""
                if i == 3 then
                    str = Lang.ui_wing_info9..DictWing[ tostring( wingLucks[ 3 ] ) ].description..Lang.ui_wing_info10
                else
                    -- cclog( "wingLucks[ i ]  :" .. wingLucks[ i ] )
                    if tonumber( wingLucks[ i ] ) == 1 then
                        str = Lang.ui_wing_info11
                    elseif tonumber( wingLucks[ i ] ) == 2 then
                        str = Lang.ui_wing_info12
                    elseif tonumber( wingLucks[ i ] ) == 3 then
                        str = Lang.ui_wing_info13
                    end
                end
                local wingCondition = image_wing_luck:getChildByName("text_wing"..i)
                wingCondition:setString(str)
                wingLuckName:setTextColor(cc.c4b(255, 255, 255, 255))
                wingLuckName:setVisible(true)
				wingCondition:setVisible(true)
                if thingData then
                    if i < 3 and tonumber( wingLucks[ i ] ) <= thingData.int["5"] then
                        wingLuckName:setTextColor(cc.c4b(18, 239, 18, 255))
						wingCondition:setVisible(false)
                    elseif i == 3 and ( tonumber( wingLucks[ i ] ) == thingData.int["3"] or thingData.int["3"] >= 5 ) then
                        wingLuckName:setTextColor(cc.c4b(18, 239, 18, 255))
						wingCondition:setVisible(false)
                    end
                end
            end
        end
    else
        image_name:getChildByName("text_name"):setVisible( false )
        image_quality:setVisible( false )
        ccui.Helper:seekNodeByName( image_down , "text_name" ):setTextColor(cc.c3b(255,255,0))
        local instCardData = net.InstPlayerCard[tostring(obj.instId)] --卡牌实例数据
        local titleDetailId = instCardData.int["6"] --具体称号ID
              
        local levelId = DictSysConfig[tostring(StaticSysConfig.wingTitleId)].value
        if DictTitleDetail[tostring(titleDetailId)].titleId >= levelId then
            ccui.Helper:seekNodeByName( image_down , "text_name" ):setString(Lang.ui_wing_info14)
            btn_up:setVisible( false )
        else
            btn_up:setVisible( true )
            local dictTitleDetailData = DictTitle[tostring(levelId)]
            ccui.Helper:seekNodeByName( image_down , "text_name" ):setString( dictTitleDetailData.name..Lang.ui_wing_info15)
        end
        for i = 1 , 8 do        
            local text_name = image_wing_di:getChildByName( "text_name"..i )
            text_name:setVisible( false )
        end


         if cardWingLucks then
            local wingLucks = utils.stringSplit( cardWingLucks.lucks , ";" )
            local wingDes = utils.stringSplit( cardWingLucks.description , "#" )           
            for i = 1 , 3 do
                local wingLuckName = image_wing_luck:getChildByName("text_name_wing"..i)
                wingLuckName:setTextColor(cc.c4b(255, 255, 255, 255))
                wingLuckName:setVisible(true)
                if i == 1 then
                    wingLuckName:setString(Lang.ui_wing_info16..wingDes[i])
                elseif i == 2 then
                    wingLuckName:setString(Lang.ui_wing_info17..wingDes[i])
                elseif i == 3 then
                    wingLuckName:setString(Lang.ui_wing_info18..wingDes[i])
                end
                 local str = ""
                if i == 3 then
                    str = Lang.ui_wing_info19..DictWing[ tostring( wingLucks[ 3 ] ) ].description..Lang.ui_wing_info20
                else
                    -- cclog( "wingLucks[ i ]  :" .. wingLucks[ i ] )
                    if tonumber( wingLucks[ i ] ) == 1 then
                        str = Lang.ui_wing_info21
                    elseif tonumber( wingLucks[ i ] ) == 2 then
                        str = Lang.ui_wing_info22
                    elseif tonumber( wingLucks[ i ] ) == 3 then
                        str = Lang.ui_wing_info23
                    end
                end
                image_wing_luck:getChildByName("text_wing"..i):setVisible( true )
                image_wing_luck:getChildByName("text_wing"..i):setString( str )
            end
        end
    end
end
local function pageViewEvent(sender, eventType)
	if eventType == ccui.PageViewEventType.turning and _curPageViewIndex ~= sender:getCurPageIndex() then
		_curPageViewIndex = sender:getCurPageIndex()
		_toPageViewIndex = _curPageViewIndex
		if _cardData then
			local id = sender:getPage(_curPageViewIndex):getTag()
			for key, obj in pairs(_cardData) do
				if id == tonumber(obj.dictId) then
					_curCardData = obj
					break
				end
			end
		end
		if _curCardData then
            propThing( _curCardData )
            if thingData then
                if UIFightActivityChoose.wingTo then
                    UIFightActivityChoose.wingTo = false
                     UIWingIntensify.setData( thingData , ui_pageView:getPage(_curPageViewIndex):getTag() )
                     UIManager.pushScene("ui_wing_intensify")
                elseif UIFightPreView.wingTo then
                     UIFightPreView.wingTo = false
                     UIWingAdvance.setData( thingData , ui_pageView:getPage(_curPageViewIndex):getTag() )
                     UIManager.pushScene("ui_wing_advance")
                end
            else
                UIFightActivityChoose.wingTo = false
                UIFightPreView.wingTo = false
            end
        end
	end
end
function UIWingInfo.init()
    local btn_close = ccui.Helper:seekNodeByName( UIWingInfo.Widget , "btn_close" )
    local btn_l = ccui.Helper:seekNodeByName( UIWingInfo.Widget , "btn_arrow_l" )
    local btn_r = ccui.Helper:seekNodeByName( UIWingInfo.Widget , "btn_arrow_r" )
    local btn_change = ccui.Helper:seekNodeByName( UIWingInfo.Widget , "btn_change" )
    local btn_unload = ccui.Helper:seekNodeByName( UIWingInfo.Widget , "btn_unload")
    local btn_inlay = ccui.Helper:seekNodeByName( UIWingInfo.Widget , "btn_inlay")
    local btn_intensify = ccui.Helper:seekNodeByName( UIWingInfo.Widget , "btn_intensify" )
    local btn_clean = ccui.Helper:seekNodeByName( UIWingInfo.Widget , "btn_clean" )
    local btn_help = ccui.Helper:seekNodeByName( UIWingInfo.Widget , "btn_help" )
    local btn_up = ccui.Helper:seekNodeByName( UIWingInfo.Widget , "btn_up" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_l then
				local index = ui_pageView:getCurPageIndex() - 1
				if index < 0 then
					index = 0
				end
				ui_pageView:scrollToPage(index)
			elseif sender == btn_r then
				local index = ui_pageView:getCurPageIndex() + 1
				if index > #ui_pageView:getPages() then
					index = #ui_pageView:getPages()
				end
				ui_pageView:scrollToPage(index)     
            elseif sender == btn_change then--更换
                if thingData then
                    UIBagWingSell.setType( UIBagWingSell.type.CHANGE , _curCardData )
                else
                    UIBagWingSell.setType( UIBagWingSell.type.EQUIP, _curCardData )
                end              
                UIManager.pushScene("ui_bag_wing_sell")
            elseif sender == btn_unload then--卸下
                if thingData then
                    sendData()
                else
                    UIManager.showToast(Lang.ui_wing_info24)
                end
            elseif sender == btn_inlay then--转换
                if thingData then
                    if thingData.int["3"] >= 5 then
                        UIManager.showToast(Lang.ui_wing_info25)
                    else
                        UIWingChange.setData( thingData , ui_pageView:getPage(_curPageViewIndex):getTag() )
                        UIManager.pushScene("ui_wing_change")
                    end
                else
                    UIManager.showToast(Lang.ui_wing_info26)
                end
            elseif sender == btn_intensify then--强化
                if thingData then
                    UIWingIntensify.setData( thingData , ui_pageView:getPage(_curPageViewIndex):getTag() )
                    UIManager.pushScene("ui_wing_intensify")
                else
                    UIManager.showToast(Lang.ui_wing_info27)
                end
            elseif sender == btn_clean then--进阶
                if thingData then
                    UIWingAdvance.setData( thingData , ui_pageView:getPage(_curPageViewIndex):getTag() )
                    UIManager.pushScene("ui_wing_advance")
                else
                    UIManager.showToast(Lang.ui_wing_info28)
                end
            elseif sender == btn_help then
                UIAllianceHelp.show( { type = 10 , titleName = Lang.ui_wing_info29 } )
            elseif sender == btn_up then
               -- cclog("wing命宫 ："..ui_pageView:getPage(_curPageViewIndex):getTag())
                local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.state)].level
                if net.InstPlayer.int["4"] < openLv then
                    UIManager.showToast(Lang.ui_wing_info30..openLv..Lang.ui_wing_info31)
                    return
                end
                 UICardJingJie.show({InstPlayerCard_id = _curCardData.instId})
            end
        end
    end

    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    btn_l:setPressedActionEnabled( true )
    btn_l:addTouchEventListener( onEvent )
    btn_r:setPressedActionEnabled( true )
    btn_r:addTouchEventListener( onEvent )
    btn_change:setPressedActionEnabled( true )
    btn_change:addTouchEventListener( onEvent )
    btn_unload:setPressedActionEnabled( true )
    btn_unload:addTouchEventListener( onEvent )
    btn_inlay:setPressedActionEnabled( true )
    btn_inlay:addTouchEventListener( onEvent )
    btn_intensify:setPressedActionEnabled( true )
    btn_intensify:addTouchEventListener( onEvent )
    btn_clean:setPressedActionEnabled( true )
    btn_clean:addTouchEventListener( onEvent )
    btn_help:setPressedActionEnabled( true )
    btn_help:addTouchEventListener( onEvent )
    btn_up:setPressedActionEnabled( true )
    btn_up:addTouchEventListener( onEvent )

    ui_pageView = ccui.Helper:seekNodeByName( UIWingInfo.Widget , "view_card" )
    ui_pageViewItem = ccui.Helper:seekNodeByName( UIWingInfo.Widget , "panel_card")
    ui_pageViewItem:retain()
end
function UIWingInfo.setup()
    _cardData = getLineupData()
    if ui_pageView then
		ui_pageView:removeAllPages()
	end
	if ui_pageView then
		ui_pageView:removeAllChildren()
	end
    _curPageViewIndex = -1
    local _pageIndex = 0
    if _cardData then
		for key, obj in pairs(_cardData) do
			local pageViewItem = ui_pageViewItem:clone()
			pageViewItem:setTag(obj.dictId)
			if _tempCardId == obj.dictId then
				_pageIndex = key - 1
			end
            local isAwake = net.InstPlayerCard[tostring(obj.instId)].int["18"]
			local dictCardData = DictCard[tostring(obj.dictId)]
			if dictCardData then
				local ui_cardImg = pageViewItem:getChildByName("image_card")
                ui_cardImg:setVisible(false)
				local cardAnim, cardAnimName
                if dictCardData.animationFiles and string.len(dictCardData.animationFiles) > 0 then
                    cardAnim, cardAnimName = ActionManager.getCardAnimation(isAwake == 1 and dictCardData.awakeAnima or dictCardData.animationFiles)
                else
                    cardAnim, cardAnimName = ActionManager.getCardBreatheAnimation("image/" .. DictUI[tostring(isAwake == 1 and dictCardData.awakeBigUiId or dictCardData.bigUiId)].fileName)
                end
				cardAnim:setScale(ui_cardImg:getScale())
				cardAnim:setPosition(cc.p(pageViewItem:getContentSize().width / 2, pageViewItem:getContentSize().height / 2 - 30 ))
				pageViewItem:addChild(cardAnim , -1)
			end
			ui_pageView:addPage(pageViewItem)
		end
		ui_pageView:addEventListener(pageViewEvent)
	end

	ui_pageView:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(function()
		ui_pageView:scrollToPage(_toPageViewIndex)
	end)))
end
function UIWingInfo.setData( pageViewIndex )
    _toPageViewIndex = pageViewIndex
end
function UIWingInfo.free()
    _cardData = nil
    _curPageViewIndex = nil
    thingData = nil
end

