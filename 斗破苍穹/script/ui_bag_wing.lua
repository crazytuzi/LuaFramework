require"Lang"
UIBagWing={}
UIBagWing.FlagType={
    WING=1,CHIP=2,FIGHT=3
}
local _flag = nil
local scrollView = nil
local _item = nil
local _itemPiece = nil
local _itemFight = nil
local _objThing = nil

local function setButtonNormal(button)
    button:getChildren()[1]:setTextColor(cc.c4b(255,255,255,255))
    button:loadTextureNormal("ui/yh_btn01.png")
end

local function setButtonSelect(button)
    button:getChildren()[1]:setTextColor(cc.c4b(51,25,4,255))
    button:loadTextureNormal("ui/yh_btn02.png")
end

local function selectedBtnChange(flag) 
    local btn_equipment = ccui.Helper:seekNodeByName(UIBagWing.Widget,"btn_equipment") -- 神羽
    local btn_chip = ccui.Helper:seekNodeByName(UIBagWing.Widget,"btn_chip")    -- 神羽碎片
    local btn_cave = ccui.Helper:seekNodeByName(UIBagWing.Widget,"btn_cave")    -- 神羽溶洞
    local btns = {btn_equipment,btn_chip,btn_cave}
    for i,v in ipairs(btns) do 
        if i == flag then
            setButtonSelect(v)
        else
            setButtonNormal(v)
        end
    end
end
function UIBagWing.freshViewItem( obj )
    item = scrollView:getChildByTag( 10000 + obj.int["1"] )
    if _flag == UIBagWing.FlagType.WING then
        local btn_intensify = ccui.Helper:seekNodeByName( item , "btn_intensify" )
        local btn_advance = ccui.Helper:seekNodeByName( item , "btn_advance" )
        local btn_change = ccui.Helper:seekNodeByName( item , "btn_change" )
        local function onEvent( sender , eventType )
            if eventType == ccui.TouchEventType.ended then
                if sender == btn_intensify then
                    UIWingIntensify.setData( obj )
                    UIManager.pushScene( "ui_wing_intensify" )
                elseif sender == btn_advance then
                    UIWingAdvance.setData( obj )
                    UIManager.pushScene( "ui_wing_advance" )
                elseif sender == btn_change then
                    if obj.int["3"] >= 5 then
                        UIManager.showToast(Lang.ui_bag_wing1)
                    else
                        UIWingChange.setData( obj )
                        UIManager.pushScene( "ui_wing_change" )
                    end                        


                end
            end
        end
        btn_intensify:setPressedActionEnabled( true )
        btn_intensify:addTouchEventListener( onEvent )
        btn_advance:setPressedActionEnabled( true )
        btn_advance:addTouchEventListener( onEvent )
        btn_change:setPressedActionEnabled( true )
        btn_change:addTouchEventListener( onEvent )

        local image_frame_wing = ccui.Helper:seekNodeByName( item , "image_frame_wing" )

        local image_wing_0 = image_frame_wing:getChildByName( "image_wing_0" )
        image_wing_0:loadTexture( "ui/wing_"..DictWing[ tostring( obj.int["3"] ) ].sname..".png" )
        
        local text_name_wing = ccui.Helper:seekNodeByName( item , "text_name_wing" )
        text_name_wing:setString( DictWing[ tostring( obj.int["3"] ) ].name )
        local text_lv = ccui.Helper:seekNodeByName( item , "text_lv" )
        if obj.int["5"] == 1 then
            text_lv:setString( Lang.ui_bag_wing2 )
        elseif obj.int["5"] == 2 then
            text_lv:setString( Lang.ui_bag_wing3 )
        elseif obj.int["5"] == 3 then
            text_lv:setString( Lang.ui_bag_wing4 )
        end
        
        local text_wing_for = ccui.Helper:seekNodeByName( item , "text_wing_for" )
        if obj.int["6"] ~= 0 then
            text_wing_for:setVisible( true )
            local cardName = DictCard[tostring(net.InstPlayerCard[tostring(obj.int["6"])].int["3"])].name
            text_wing_for:setString(Lang.ui_bag_wing5..cardName)
        else
            text_wing_for:setVisible( false )
        end

        local text_lv_wing = ccui.Helper:seekNodeByName( item , "text_lv_wing" )
        text_lv_wing:setString("LV." .. obj.int["4"])

        local image_di = ccui.Helper:seekNodeByName( item , "image_di" )
        local strengthenData , advanceData , proShow = utils.getWingInfo( obj.int["3"] , obj.int["4"] , obj.int["5"] , image_di ) 

        local image_wing = image_frame_wing:getChildByName( "image_wing" )
        local smallImage= DictUI[tostring(advanceData.smallUiId)].fileName
        image_wing:loadTexture( "image/"..smallImage )

    elseif _flag == UIBagWing.FlagType.CHIP then
        local btn_lineup = ccui.Helper:seekNodeByName( item , "btn_lineup" )
        local function onEventPiece( sender , eventType )
            if eventType == ccui.TouchEventType.ended then
                if sender == btn_lineup then
                    local title = btn_lineup:getTitleText()
                    if title == Lang.ui_bag_wing6 then
                        UIWingCommon.setData( obj )
                        UIManager.pushScene( "ui_wing_common" )
                    elseif title == Lang.ui_bag_wing7 then
                        UIManager.pushScene( "ui_wing_info" )
                    end
                end
            end
        end
        btn_lineup:setPressedActionEnabled( true )
        btn_lineup:addTouchEventListener( onEventPiece )

        local tableFieldId = obj.int["3"]
        local name_text=DictThing[tostring(tableFieldId)].name
        local smallUiId = DictThing[tostring(tableFieldId)].smallUiId
        local smallImage= DictUI[tostring(smallUiId)].fileName
        local description_text =DictThing[tostring(tableFieldId)].description
        btn_lineup:setBright( true )
        btn_lineup:setEnabled( true )
       -- cclog("---------------")
        if tableFieldId == StaticThing.thing306 then
            local condition = utils.stringSplit( DictWingAdvance["1"].nextStarNumConds , "_" )
          --  cclog( "condition[3] :"..condition[3])
            if obj.int["5"] >= tonumber( condition[3] ) then
                btn_lineup:setTitleText( Lang.ui_bag_wing8 )
            else
                btn_lineup:setBright( false )
                btn_lineup:setTitleText( Lang.ui_bag_wing9 )
            end
        else
            local condition = utils.stringSplit( DictWingAdvance[tostring(tableFieldId-StaticThing.thing306 + 1)].nextStarNumConds , "_" )
            --cclog( "condition[3] :"..condition[3])
            if obj.int["5"] >= tonumber( condition[3] ) then
                btn_lineup:setTitleText( Lang.ui_bag_wing10 )
            else
                btn_lineup:setTitleText( Lang.ui_bag_wing11 )
                btn_lineup:setEnabled( false )
                btn_lineup:setBright( false )
            end

        end
       -- cclog("---------------")
        local image_frame_chip = ccui.Helper:seekNodeByName( item , "image_frame_chip" )
        utils.addBorderImage( obj.int["6"] , obj.int["3"] , image_frame_chip )
        local image_chip = image_frame_chip:getChildByName( "image_chip" )
        image_chip:loadTexture( "image/"..smallImage )
        local text_chip_name = ccui.Helper:seekNodeByName( item , "text_chip_name" )
        text_chip_name:setString( name_text )
        local text_number = ccui.Helper:seekNodeByName( item , "text_number" )
        text_number:setString( Lang.ui_bag_wing12..obj.int["5"] )
        local text_gem_describe = ccui.Helper:seekNodeByName( item , "text_gem_describe" )
        text_gem_describe:setString(description_text)
    
    elseif _flag == UIBagWing.FlagType.FIGHT then
        error("no this function")
    end
end

local function setScrollViewItem( item , obj )
    item:setTag( 10000 + obj.int["1"] )
    if _flag == UIBagWing.FlagType.WING then
        local btn_intensify = ccui.Helper:seekNodeByName( item , "btn_intensify" )
        local btn_advance = ccui.Helper:seekNodeByName( item , "btn_advance" )
        local btn_change = ccui.Helper:seekNodeByName( item , "btn_change" )
        local function onEvent( sender , eventType )
            if eventType == ccui.TouchEventType.ended then              
                if sender == btn_intensify then
                    if obj.int["6"] == 0 then
                        UIWingIntensify.setData( obj )
                    else
                        UIWingIntensify.setData( obj , net.InstPlayerCard[tostring(obj.int["6"])].int["3"] )
                    end
                    UIManager.pushScene( "ui_wing_intensify" )
                elseif sender == btn_advance then
                    if obj.int["6"] == 0 then
                        UIWingAdvance.setData( obj )
                    else
                        UIWingAdvance.setData( obj , net.InstPlayerCard[tostring(obj.int["6"])].int["3"] )
                    end
                    UIManager.pushScene( "ui_wing_advance" )
                elseif sender == btn_change then
                    if obj.int["3"] >= 5 then
                        UIManager.showToast(Lang.ui_bag_wing13)
                    else
                        if obj.int["6"] == 0 then
                            UIWingChange.setData( obj )
                        else
                            UIWingChange.setData( obj , net.InstPlayerCard[tostring(obj.int["6"])].int["3"] )
                        end
                        UIManager.pushScene( "ui_wing_change" )
                    end
                end
            end
        end
        btn_intensify:setPressedActionEnabled( true )
        btn_intensify:addTouchEventListener( onEvent )
        btn_advance:setPressedActionEnabled( true )
        btn_advance:addTouchEventListener( onEvent )
        btn_change:setPressedActionEnabled( true )
        btn_change:addTouchEventListener( onEvent )

        

        local image_frame_wing = ccui.Helper:seekNodeByName( item , "image_frame_wing" )

        local image_wing_0 = image_frame_wing:getChildByName( "image_wing_0" )
        if obj.int["3"] >= 5 then
            image_wing_0:loadTexture( "ui/wing_all.png" )
        else
            image_wing_0:loadTexture( "ui/wing_"..DictWing[ tostring( obj.int["3"] ) ].sname..".png" )
        end
        local text_name_wing = ccui.Helper:seekNodeByName( item , "text_name_wing" )
        text_name_wing:setString( DictWing[ tostring( obj.int["3"] ) ].name )
        local text_lv = ccui.Helper:seekNodeByName( item , "text_lv" )
        if obj.int["5"] == 1 then
            text_lv:setString( Lang.ui_bag_wing14 )
        elseif obj.int["5"] == 2 then
            text_lv:setString( Lang.ui_bag_wing15 )
        elseif obj.int["5"] == 3 then
            text_lv:setString( Lang.ui_bag_wing16 )
        end
        
        local text_wing_for = ccui.Helper:seekNodeByName( item , "text_wing_for" )
        if obj.int["6"] ~= 0 then
            text_wing_for:setVisible( true )
            local cardName = DictCard[tostring(net.InstPlayerCard[tostring(obj.int["6"])].int["3"])].name
            text_wing_for:setString(Lang.ui_bag_wing17..cardName)
        else
            text_wing_for:setVisible( false )
        end
        local image_di = ccui.Helper:seekNodeByName( item , "image_di" )
        local strengthenData , advanceData , proShow = utils.getWingInfo( obj.int["3"] , obj.int["4"] , obj.int["5"] , image_di ) 

        local text_lv_wing = ccui.Helper:seekNodeByName( item , "text_lv_wing" )
        text_lv_wing:setString("LV." .. obj.int["4"])

        local image_wing = image_frame_wing:getChildByName( "image_wing" )
        local smallImage= DictUI[tostring(advanceData.smallUiId)].fileName
        image_wing:loadTexture( "image/"..smallImage )

    elseif _flag == UIBagWing.FlagType.CHIP then
        local btn_lineup = ccui.Helper:seekNodeByName( item , "btn_lineup" )
        local function onEventPiece( sender , eventType )
            if eventType == ccui.TouchEventType.ended then
                if sender == btn_lineup then
                    local title = btn_lineup:getTitleText()
                    if title == Lang.ui_bag_wing18 then
                        UIManager.pushScene( "ui_wing_common" )
                    elseif title == Lang.ui_bag_wing19 then
                        UIManager.pushScene( "ui_wing_info" )
                    end
                end
            end
        end
        btn_lineup:setPressedActionEnabled( true )
        btn_lineup:addTouchEventListener( onEventPiece )

        local tableFieldId = obj.int["3"]
        local name_text=DictThing[tostring(tableFieldId)].name
        local smallUiId = DictThing[tostring(tableFieldId)].smallUiId
        local smallImage= DictUI[tostring(smallUiId)].fileName
        local description_text =DictThing[tostring(tableFieldId)].description
        btn_lineup:setEnabled( true )
        btn_lineup:setBright( true )
        if tableFieldId == StaticThing.thing306 then
            local condition = utils.stringSplit( DictWingAdvance["1"].nextStarNumConds , "_" )
            cclog( "condition[3] :"..condition[3])
            if obj.int["5"] >= tonumber( condition[3] ) then
                btn_lineup:setTitleText( Lang.ui_bag_wing20 )
            else
                btn_lineup:setBright( false )
                btn_lineup:setTitleText( Lang.ui_bag_wing21 )
            end
        else
            local condition = utils.stringSplit( DictWingAdvance[tostring(tableFieldId-StaticThing.thing306 + 1)].nextStarNumConds , "_" )
            cclog( "condition[3] :"..condition[3])
            if obj.int["5"] >= tonumber( condition[3] ) then
                btn_lineup:setTitleText( Lang.ui_bag_wing22 )
            else
                btn_lineup:setTitleText( Lang.ui_bag_wing23 )
                btn_lineup:setEnabled( false )
                btn_lineup:setBright( false )
            end

        end

        local image_frame_chip = ccui.Helper:seekNodeByName( item , "image_frame_chip" )
        utils.addBorderImage( obj.int["6"] , obj.int["3"] , image_frame_chip )
        local image_chip = image_frame_chip:getChildByName( "image_chip" )
        image_chip:loadTexture( "image/"..smallImage )
        local text_chip_name = ccui.Helper:seekNodeByName( item , "text_chip_name" )
        text_chip_name:setString( name_text )
        local text_number = ccui.Helper:seekNodeByName( item , "text_number" )
        text_number:setString( Lang.ui_bag_wing24..obj.int["5"] )
        local text_gem_describe = ccui.Helper:seekNodeByName( item , "text_gem_describe" )
        text_gem_describe:setString(description_text)
    
    elseif _flag == UIBagWing.FlagType.FIGHT then
        local btn_add_number = item:getChildByName("btn_add_number")
        --- 剩余次数
        local numberText = item:getChildByName("label_left_number")
        --- 剩余次数
        local image_base_star = item:getChildByName("image_base_star")
        --- 得星
        local image_base_di = item:getChildByName("image_base_di")
        local text_hint = image_base_di:getChildByName("text_hint")
        --- 开启条件
        local image_pass = item:getChildByName("image_pass")
        -- 已通关图片
        local image_win_di = item:getChildByName("image_win_di")
        

        local function onTouchEvent(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                sender:setScale(1.05)
            elseif eventType == ccui.TouchEventType.ended then
                sender:setScale(1)
                local ctpid = sender:getTag() - 10000
                UIFightPreView.setChapterId(ctpid)
                UIManager.pushScene("ui_fight_preview")

            end
        end
        item:addTouchEventListener(onTouchEvent)
        local backGroundPictureS = obj.backGroundPictureS
        item:loadTexture("image/" .. backGroundPictureS)
        item:getChildByName("image_hint"):setVisible(false)

        image_pass:hide()
        image_win_di:hide()
        btn_add_number:setVisible(false)
        numberText:setVisible(false)
        image_base_star:setVisible(false)

        local chapterId = obj.id
        local InstPlayerlevel = net.InstPlayer.int["4"]
        --- 玩家等级
        local openLevel = obj.openLeve
        -- 开启等级
        if InstPlayerlevel < openLevel then
            utils.GrayWidget(item, true)
            image_base_di:setVisible(true)
            text_hint:setString(Lang.ui_fight21 .. openLevel .. Lang.ui_fight22)
            return
        else
            utils.GrayWidget(item, false)
            image_base_di:setVisible(false)
        end
    end
end
function UIBagWing.init()
    local btn_sell = ccui.Helper:seekNodeByName( UIBagWing.Widget , "btn_sell" )
    local btn_chip = ccui.Helper:seekNodeByName( UIBagWing.Widget , "btn_chip" )
    local btn_equipment = ccui.Helper:seekNodeByName(UIBagWing.Widget,"btn_equipment")
    -- local image_hint = ccui.Helper:seekNodeByName(UIBagWing.Widget , "image_hint")
    -- local btn_go = ccui.Helper:seekNodeByName(image_hint,"btn_go")
    local image_hint = UIBagWing.Widget:getChildByName("image_basemap"):getChildByName("image_hint")
    local btn_go = image_hint:getChildByName("btn_go")


    -- local btn_help = ccui.Helper:seekNodeByName( UIBagWing.Widget , "btn_help" )
    local btn_cave = ccui.Helper:seekNodeByName(UIBagWing.Widget , "btn_cave")
    local btn_back = ccui.Helper:seekNodeByName(UIBagWing.Widget , "btn_back")
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_sell then
                if _flag == UIBagWing.FlagType.WING then
                    UIBagWingSell.setType( UIBagWingSell.type.SELL )
                else
                    UIBagWingSell.setType( UIBagWingSell.type.SELL_PIECE )
                end                
                UIManager.pushScene("ui_bag_wing_sell")
            elseif sender == btn_chip then
                if _flag == UIBagWing.FlagType.CHIP then
                    return 
                end
                _flag = 2
                UIBagWing.setup()
            elseif sender == btn_equipment then
                if _flag == UIBagWing.FlagType.WING then
                    return
                end
                _flag = 1
                UIBagWing.setup()
            elseif sender == btn_go then
                UIFight.setFlag(1,2)
                 UIManager.showScreen("ui_notice", "ui_team_info", "ui_fight", "ui_menu")
                 UIFightPreView.setChapterId(DictChapter["300"].id)
                 UIManager.pushScene("ui_fight_preview")
            -- elseif sender == btn_help then
            --     UIAllianceHelp.show( { type = 10 , titleName = Lang.ui_bag_wing25 } )
            elseif sender == btn_cave then
                if _flag == UIBagWing.FlagType.FIGHT then
                    return
                end
                _flag = UIBagWing.FlagType.FIGHT
                UIBagWing.setup()
            elseif sender == btn_back then
                UIMenu.onHomepage()
            end
        end
    end
    btn_sell:setPressedActionEnabled( true )
    btn_sell:addTouchEventListener( onEvent )
    btn_chip:setPressedActionEnabled( true )
    btn_chip:addTouchEventListener( onEvent )
    btn_equipment:setPressedActionEnabled( true )
    btn_equipment:addTouchEventListener( onEvent )
    btn_go:setPressedActionEnabled( true )
    btn_go:addTouchEventListener(onEvent)
    -- btn_help:setPressedActionEnabled( true )
    -- btn_help:addTouchEventListener(onEvent)
    btn_cave:setPressedActionEnabled( true )
    btn_cave:addTouchEventListener(onEvent)
    btn_back:setPressedActionEnabled( true )
    btn_back:addTouchEventListener(onEvent)
    
    scrollView = ccui.Helper:seekNodeByName( UIBagWing.Widget , "view_list_equipment")
    _item = scrollView:getChildByName("image_base_wing")
    _item:retain()
    _itemPiece = scrollView:getChildByName("image_base_chip")
    _itemPiece:retain()
    _itemFight = scrollView:getChildByName("image_base_fight")
    _itemFight:retain()
end
    
function UIBagWing.setup()
    if not _flag then
        _flag = UIBagWing.FlagType.FIGHT
    end
    selectedBtnChange( _flag )
    _objThing = {}
    local item = nil
    -- local image_hint = ccui.Helper:seekNodeByName(UIBagWing.Widget , "image_hint")
    -- local text_hint = ccui.Helper:seekNodeByName(image_hint,"text_hint")
    -- local btn_go = ccui.Helper:seekNodeByName(image_hint,"btn_go")
    local image_hint = UIBagWing.Widget:getChildByName("image_basemap"):getChildByName("image_hint") 
    local btn_go = image_hint:getChildByName("btn_go")
    local text_hint = image_hint:getChildByName("text_hint")

    local text_number = UIBagWing.Widget:getChildren()[1]:getChildByName("text_number")

    if _flag == UIBagWing.FlagType.WING then
      --  _objThing = { 1 , 2 , 3 , 4 }
        text_number:setVisible(false)
        if net.InstPlayerWing then
            for key , value in pairs( net.InstPlayerWing ) do
                table.insert( _objThing , value )
            end
        end
        utils.quickSort( _objThing , function ( obj1 , obj2 )
            if obj1.int["6"] == 0 and obj2.int["6"] ~= 0 then
                return true
            elseif obj2.int["6"] == 0 and obj1.int["6"] ~= 0 then
                return false
            elseif obj1.int["5"] < obj2.int["5"] then
                return true
            elseif obj1.int["5"] > obj2.int["5"] then
                return false
            elseif obj1.int["4"] < obj2.int["4"] then
                return true
            else
                return false
            end
        end)
        if #_objThing > 0 then
            image_hint:setVisible( false )
        else
            image_hint:setVisible( true )
            text_hint:setVisible( true )
            text_hint:setString(Lang.ui_bag_wing26)
            btn_go:setVisible( false )
        end
        item = _item
    elseif _flag == UIBagWing.FlagType.CHIP then
       -- _objThing = { 1 , 2 , 3 }
       text_number:setVisible(false)
        item = _itemPiece
        if net.InstPlayerThing then
            for key, obj in pairs(net.InstPlayerThing) do
                if obj.int["7"] == StaticBag_Type.wing then 
                     table.insert(_objThing,obj)
                end
            end
        end
        utils.quickSort( _objThing , function ( obj1 , obj2 )
            if obj1.int["3"] < obj2.int["3"] then
                return true
            else
                return false
            end
        end)
        if #_objThing > 0 then
            image_hint:setVisible( false )
        else
            image_hint:setVisible( true )
            text_hint:setString(Lang.ui_bag_wing27)
            text_hint:setVisible( true )
            btn_go:setVisible( true )
        end
    elseif _flag == UIBagWing.FlagType.FIGHT then
        -- 当天次数逻辑
        local eliteBarrierNum = 0
        local eliteBuyNum = 0
        if net.InstPlayerChapterType then
            for key, obj in pairs(net.InstPlayerChapterType) do
                if obj.int["3"] == 4 then
                    eliteBarrierNum = obj.int["4"]
                    eliteBuyNum = obj.int["6"]
                end
            end
        end
        if eliteBarrierNum == nil then
            eliteBarrierNum = 0
        end
        if eliteBuyNum == nil then
            eliteBuyNum = 0
        end

        UIFight.selectedPickFlag = 2
        UIFight.EliteBarrierTimes = DictSysConfig[tostring(StaticSysConfig.chapterEliteNum)].value - eliteBarrierNum
        cclog("----------------------------------- ui_bag_win ----------------------------------------------------")
        cclog("eliteBarrierNum = " .. eliteBarrierNum)
        cclog("eliteBuyNum = ".. eliteBuyNum)
        cclog("UIFight.EliteBarrierTimes = " ..UIFight.EliteBarrierTimes)
        if UIFight.EliteBarrierTimes < 0 then
            UIFight.EliteBarrierTimes = 0
        end
        
        -- local baseMoney = DictSysConfig[tostring(StaticSysConfig.chapterEliteBuyGold)].value
        -- local oneAddMoney = DictSysConfig[tostring(StaticSysConfig.chapterEliteBuyGoldAdd)].value
        -- eliteBuyBarrierTimeMoney = baseMoney + eliteBuyNum * oneAddMoney

        text_number:setVisible(true)
        text_number:setString(Lang.ui_fight59 .. UIFight.EliteBarrierTimes)

        item = _itemFight
        for key, DictChapterObj in pairs(DictChapter) do
            if DictChapterObj.type == 4 then
                DictChapterObj.int = {}
                DictChapterObj.int["1"] = DictChapterObj.id
                table.insert(_objThing, DictChapterObj)

            end
        end
        utils.quickSort( _objThing,function(obj1,obj2)
            return obj1.id > obj2.id
        end)
        image_hint:setVisible(false)
        text_hint:setVisible(false)
    end
    scrollView:removeAllChildren()
    utils.updateScrollView( UIBagWingSell , scrollView , item , _objThing , setScrollViewItem )
    local btn_chip = ccui.Helper:seekNodeByName( UIBagWing.Widget , "btn_chip" )
    utils.addImageHint(UIBagWing.checkImageHint(),btn_chip,100,18,10)
end
function UIBagWing.free()
    _flag = nil
    _objThing = nil
end

function UIBagWing.checkImageHint()
    local objThing={}
    if net.InstPlayerThing then
        for key, obj in pairs(net.InstPlayerThing) do
             if obj.int["7"] == StaticBag_Type.wing then 
                 table.insert(objThing,obj)
             end
        end
    end
    local result = false
    for key, obj in pairs(objThing) do
        local tableFieldId = obj.int["3"]       
        if tableFieldId == StaticThing.thing306 then
            local condition = utils.stringSplit( DictWingAdvance["1"].nextStarNumConds , "_" )
            if obj.int["5"] >= tonumber( condition[3] ) then
                result = true
                break
            end
        end
    end
    return result
end
