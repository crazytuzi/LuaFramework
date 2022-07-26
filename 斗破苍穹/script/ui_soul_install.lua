require"Lang"
UISoulInstall = {}
UISoulInstall.type = {
    LINEUP = 0 ,
    ALL = 1 ,
    ONE = 2 ,
    PVP = 3
}

local _type = nil
local _cardData = nil
local ui_pageView = nil
local ui_pageViewItem = nil
local _curPageViewIndex = -1
local _toPageViewIndex = -1
local _curCardData = nil
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
	    for i = 1, #formation1 do
		    local obj = nil
			obj = formation1[i]
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
local function getPvpLineupData( _cardId )
	local cardData = {}
    if _cardId then
        cardData[1] = {}
        cardData[1].dictId = net.InstPlayerCard[ tostring(_cardId) ].int["3"]         
	    cardData[1].instId = _cardId
        return cardData
    end
	local formation1, formation2 = {}, {}
	for key, obj in pairs(pvp.InstPlayerFormation) do
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
	return cardData
end
local function getCardTitleId()
    local instCardData = {}
    if _type == UISoulInstall.type.PVP then
        instCardData = pvp.InstPlayerCard[tostring(_curCardData.instId)]
    else
        instCardData = net.InstPlayerCard[tostring(_curCardData.instId)]
    end
    local titleId = tonumber( DictTitleDetail[tostring(instCardData.int["6"])].titleId )
    return titleId
end
local function pageViewEvent(sender, eventType)
	if eventType == ccui.PageViewEventType.turning and _curPageViewIndex ~= sender:getCurPageIndex() then
		_curPageViewIndex = sender:getCurPageIndex()
		_toPageViewIndex = _curPageViewIndex
        local pageView = sender:getPage(_curPageViewIndex)
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
          --  cclog( "dictId :".._curCardData.instId )
            local _fightSoul = {}
            if _type == UISoulInstall.type.PVP then
                if pvp.InstPlayerFightSoul then
                 --   cclog("pvp.InstPlayerFightSoul length :"..#pvp.InstPlayerFightSoul)
                    for key , value in pairs ( pvp.InstPlayerFightSoul ) do
                        if value.int[ "7" ] == _curCardData.instId then
                            table.insert( _fightSoul , value )
                        end
                    end
                end
            else
                if net.InstPlayerFightSoul then
                    for key , value in pairs ( net.InstPlayerFightSoul ) do
                        if value.int[ "7" ] == _curCardData.instId then
                            table.insert( _fightSoul , value )
                        end
                    end
                end
            end
            for i = 1 , 8 do
                if i <= getCardTitleId() then
                    local image_name = ccui.Helper:seekNodeByName( pageView , "image_name"..i )
                    local text_name = image_name:getChildByName( "text_name" )
                    text_name:setString( Lang.ui_soul_install1 )
                    local image_soul = ccui.Helper:seekNodeByName( pageView , "image_soul"..i )
                    local panel = image_soul:getChildByName( "panel_soul" )
                    local image_add = panel:getChildByName( "image_add" )
                    image_add:setVisible( true )
                    image_add:loadTexture( "ui/frame_tianjia.png" )
                    utils.addSoulParticle( panel )
                    ActionManager.setSoulEffectAction( -1 , panel )
                else
                    
                end
            end
            
            for key ,value in pairs ( _fightSoul ) do
                local image_name = ccui.Helper:seekNodeByName( pageView , "image_name"..value.int[ "8" ] )
                local text_name = image_name:getChildByName( "text_name" )
                local proType , proValue , sellSilver = utils.getSoulPro( value.int[ "3" ] , value.int[ "5" ] )
               -- text_name:setString( DictFightSoul[ tostring( value.int[ "3" ] ) ].name )
                if proValue < 1 then
                    text_name:setString( DictFightProp[tostring( proType )].name.."+"..( proValue * 100 ) .."%" )
                else
                    text_name:setString( DictFightProp[tostring( proType )].name.."+"..proValue )
                end
               -- utils.changeNameColor( text_name , value.int[ "4" ] , dp.Quality.fightSoul )
                
                local image_soul = ccui.Helper:seekNodeByName( pageView , "image_soul"..value.int[ "8" ] )
                local image_add = ccui.Helper:seekNodeByName( image_soul , "image_add" )
                image_add:setVisible( false )
                ActionManager.setSoulEffectAction( value.int[ "3" ] , image_soul:getChildByName("panel_soul") )
                utils.addSoulParticle( image_soul:getChildByName("panel_soul") , DictFightSoul[ tostring( value.int[ "3" ] )].effects , DictFightSoul[ tostring( value.int[ "3" ] )].fightSoulQualityId )
            end
		end
	end
end

local function isCanFightSoul( tag )
  --  cclog( " tag : "..tag )
   if net.InstPlayerFightSoul then
       for key , value in pairs ( net.InstPlayerFightSoul ) do
           if value.int[ "7" ] == _curCardData.instId and value.int[ "8" ] == tag then
                 return value
           end
       end
   end
   return nil
end

local function netCallBack( data )
  --  UIManager.flushWidget( UISoulInstall )
    UISoulInstall.refreshPageView()
    UIManager.flushWidget( UILineup )
end

function UISoulInstall.refreshPageView()
    if UISoulInstall.Widget and UISoulInstall.Widget:getParent() then
    else
        return
    end
    _curPageViewIndex = -1
   -- ui_pageView:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
		ui_pageView:scrollToPage(_toPageViewIndex)
--	end)))
    if UIGuidePeople.guideStep and UIGuidePeople.guideStep == guideInfo["45B6"].step then
        local btn_close = ccui.Helper:seekNodeByName( UISoulInstall.Widget , "btn_close" )
        UIGuidePeople.isGuide(btn_close,UISoulInstall)
    end
end

local function sendData( type )
    local sendData = {}
    cclog( "type " .. type )
    if type == 0 then -- 一键附魂
        sendData = {
            header = StaticMsgRule.oneKeyStick ,
            msgdata = {
                int = {
                    instPlayerCardId = _curCardData.instId
                }
            }
        }
    elseif type == 1 then -- 一键卸下
        sendData = {
            header = StaticMsgRule.oneKeyDrop ,
            msgdata = {
                int = {
                    instPlayerCardId = _curCardData.instId
                }
            }
        }
    end
    netSendPackage( sendData , netCallBack )
end

function UISoulInstall.init()
	local btn_close = ccui.Helper:seekNodeByName( UISoulInstall.Widget , "btn_close" )
    local btn_l = ccui.Helper:seekNodeByName( UISoulInstall.Widget , "btn_arrow_l" )
    local btn_r = ccui.Helper:seekNodeByName( UISoulInstall.Widget , "btn_arrow_r" )
    local btn_get = ccui.Helper:seekNodeByName( UISoulInstall.Widget , "btn_get" )
    local btn_cancel = ccui.Helper:seekNodeByName( UISoulInstall.Widget , "btn_cancel")
    local btn_down = ccui.Helper:seekNodeByName( UISoulInstall.Widget , "btn_down" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_get then
                UIManager.hideWidget("ui_team_info")
                UIManager.showWidget( "ui_soul_get" )
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
            elseif sender == btn_cancel then
                sendData( 0 )
            elseif sender == btn_down then
                sendData( 1 )
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    btn_l:setPressedActionEnabled( true )
    btn_l:addTouchEventListener( onEvent )
    btn_r:setPressedActionEnabled( true )
    btn_r:addTouchEventListener( onEvent )
    btn_get:setPressedActionEnabled( true )
    btn_get:addTouchEventListener( onEvent )
    btn_cancel:setPressedActionEnabled( true )
    btn_cancel:addTouchEventListener( onEvent )
    btn_down:setPressedActionEnabled( true )
    btn_down:addTouchEventListener( onEvent )

    ui_pageView = ccui.Helper:seekNodeByName(UISoulInstall.Widget, "view_page")
	ui_pageViewItem = ui_pageView:getChildByName("panel")
    ui_pageViewItem:retain()
end
function UISoulInstall.setPageIndex( pageViewIndex )
    _toPageViewIndex = pageViewIndex
end
function UISoulInstall.setup()
    if _type == UISoulInstall.type.LINEUP then
        _cardData = getLineupData()
    elseif _type == UISoulInstall.type.PVP then
        _cardData = getPvpLineupData()
    elseif _type == UISoulInstall.type.ONE then
        local btn_l = ccui.Helper:seekNodeByName( UISoulInstall.Widget , "btn_arrow_l" )
        local btn_r = ccui.Helper:seekNodeByName( UISoulInstall.Widget , "btn_arrow_r" )
        btn_l:setVisible( false )
        btn_r:setVisible( false )
    end
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
			local dictCardData = DictCard[tostring(obj.dictId)]
			if dictCardData then
				local qualityId = dictCardData.qualityId
                local _isAwake = 0
				if obj.instId and obj.instId > 0 then
                    local instCardData = {}
                    if _type == UISoulInstall.type.PVP then
					    instCardData = pvp.InstPlayerCard[tostring(obj.instId)]
                    else
                        instCardData = net.InstPlayerCard[tostring(obj.instId)]
                    end
					qualityId = instCardData.int["4"]
                    _isAwake = instCardData.int["18"]
				end
--				pageViewItem:getChildByName("image_property"):loadTexture(utils.getCardTypeImage(dictCardData.cardTypeId))
				local ui_nameBgImg = pageViewItem:getChildByName("image_di_soul"):getChildByName( "image_di_name" )
--				local middleImg = utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.middle, true)
--				ui_nameBgImg:loadTexture(middleImg)
				ui_nameBgImg:getChildByName("text_name"):setString((_isAwake == 1 and Lang.ui_soul_install2 or "") .. dictCardData.name)
--				ccui.Helper:seekNodeByName(ui_nameBgImg, "AtlasLabel_36"):setString(tostring(dictCardData.nickname))
				local ui_cardImg = pageViewItem:getChildByName("image_card")

                ui_cardImg:setVisible(false)
				local cardAnim, cardAnimName
                if dictCardData.animationFiles and string.len(dictCardData.animationFiles) > 0 then
                    cardAnim, cardAnimName = ActionManager.getCardAnimation(_isAwake == 1 and dictCardData.awakeAnima or dictCardData.animationFiles)
                else
                    cardAnim, cardAnimName = ActionManager.getCardBreatheAnimation("image/" .. DictUI[tostring(_isAwake == 1 and dictCardData.awakeBigUiId or dictCardData.bigUiId)].fileName)
                end
				cardAnim:setScale(ui_cardImg:getScale())
				cardAnim:setPosition(cc.p(pageViewItem:getContentSize().width / 2, pageViewItem:getContentSize().height / 2))
				pageViewItem:addChild(cardAnim , -1)
			end
            local panel_soul = {}
            for i = 1 , 8 do
                local image_soul = ccui.Helper:seekNodeByName( pageViewItem , "image_soul"..i )
                local panel = image_soul:getChildByName( "panel_soul" )
                panel:getChildByName( "image_add" ):loadTexture( "ui/mg_suo.png" )
              --  image_soul:setLocalZOrder( 1 )
                table.insert( panel_soul , panel )
            end
            local name = { Lang.ui_soul_install3 , Lang.ui_soul_install4 , Lang.ui_soul_install5 , Lang.ui_soul_install6 , Lang.ui_soul_install7 , Lang.ui_soul_install8 , Lang.ui_soul_install9 , Lang.ui_soul_install10 }
            for i = 1 , 8 do
                local image_name = ccui.Helper:seekNodeByName( pageViewItem , "image_name"..i )
                local text_name = image_name:getChildByName( "text_name" )
                text_name:setString( name[ i ] )
             --   text_name:setLocalZOrder( 1 )
            end
            local function onEvent( sender , eventType )
                _tag = 0
                if eventType == ccui.TouchEventType.ended then
                    for key  ,value in pairs( panel_soul ) do
                        if sender == value then
                            _tag = key
                            break
                        end
                    end
                    if _tag > 0 then
                        if _tag <= getCardTitleId() then
                            local thingData = isCanFightSoul( _tag )
                            local cardId = { instPlayerCardId = _curCardData.instId , position = _tag }
                            if thingData then
                                UISoulInfo.setInfo( 1 , thingData , cardId )
                                UIManager.pushScene( "ui_soul_info" )
                            else
                                UISoulList.setType( UISoulList.type.EQUIP , cardId )
                                UIManager.pushScene( "ui_soul_list" )
                            end
                        else
                            UIManager.showToast( Lang.ui_soul_install11 )
                        end
                    end
                end
            end
            
            if _type == UISoulInstall.type.PVP then
            else
                for key1 ,value in pairs( panel_soul ) do
                    value:addTouchEventListener( onEvent )                   
                end
            end
			ui_pageView:addPage(pageViewItem)
		end
		ui_pageView:addEventListener(pageViewEvent)
	end

	--ui_pageView:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
		ui_pageView:scrollToPage(_toPageViewIndex)
	--end)))


    if _type == UISoulInstall.type.PVP then
        local btn_get = ccui.Helper:seekNodeByName( UISoulInstall.Widget , "btn_get" )
        local btn_cancel = ccui.Helper:seekNodeByName( UISoulInstall.Widget , "btn_cancel")
        local btn_down = ccui.Helper:seekNodeByName( UISoulInstall.Widget , "btn_down" )
        btn_get:setVisible( false )
        btn_cancel:setVisible(false)
        btn_down:setVisible( false )
    end
    if UIGuidePeople.guideStep and UIGuidePeople.guideStep == guideInfo["45B4"].step then
        local obj = ui_pageView:getPage( _toPageViewIndex )
        local value = ccui.Helper:seekNodeByName( obj , "image_soul1" ):getChildByName( "panel_soul" )
        UIGuidePeople.isGuide(value,UISoulInstall)
    elseif UIGuidePeople.guideStep and UIGuidePeople.guideStep == guideInfo["45B6"].step then
        local btn_close = ccui.Helper:seekNodeByName( UISoulInstall.Widget , "btn_close" )
        UIGuidePeople.isGuide(btn_close,UISoulInstall)
    end
end

function UISoulInstall.setType( type , pageIndex , _objId )
    _type = type 
    if pageIndex then
        UISoulInstall.setPageIndex( pageIndex )
    else 
        UISoulInstall.setPageIndex( 0 )
    end
    if type == UISoulInstall.type.ONE then
      --  cclog( "_objId :".._objId )
        _cardData = getLineupData( _objId )
    end
end

function UISoulInstall.free()
    _type = nil
    _cardData = nil
    _curCardData = nil
end
