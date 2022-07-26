require"Lang"
UIAllianceRunRank = {}
local _scrollView = nil
local _item = nil
local function setViewItem( item , data )
    local text_ranking = item:getChildByName("image_frame_player"):getChildByName( "text_ranking" )
    text_ranking:setString( data.id )
    local text_alliance = item:getChildByName("image_frame_player"):getChildByName( "text_alliance" )
    text_alliance:setString( Lang.ui_alliance_run_rank1..data.name )
    local text_lv = item:getChildByName("image_frame_player"):getChildByName( "text_lv" )
    text_lv:setString( Lang.ui_alliance_run_rank2..data.score )
    local image_box = item:getChildByName("image_frame_player"):getChildByName( "image_box" )
    --local dictData = utils.getItemProp( data.award )
   -- utils.showThingsInfo( image_box , dictData.tableTypeId , dictData.tableFieldId )
    local image_player = item:getChildByName("image_frame_player"):getChildByName( "image_player" )
    if data.flag <= 0 then
        image_player:loadTexture("image/" .. DictUI[tostring(DictUnionFlag["1"].smallUiId)].fileName)
    else
        image_player:loadTexture("image/" .. DictUI[tostring(DictUnionFlag[tostring(data.flag)].smallUiId)].fileName)
    end
    image_box:setTouchEnabled( true )
    image_box:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                UIAwardGet.setOperateType(UIAwardGet.operateType.dailyTaskBox, {
                    btnTitleText = "",
                    enabled = true,
                    things = data.award
                }, UIAllianceRunRank)
                UIManager.pushScene("ui_award_get")
            end
        end)
end
local function refreshView( data )
    _scrollView:removeAllChildren()
    utils.updateScrollView( UIAllianceRunRank , _scrollView , _item , data , setViewItem )
end
function UIAllianceRunRank.init()
    local btn_close = ccui.Helper:seekNodeByName( UIAllianceRunRank.Widget , "btn_close" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )

    _scrollView = ccui.Helper:seekNodeByName( UIAllianceRunRank.Widget , "view_info" )
    _item = _scrollView:getChildByName( "image_di_ranking" )
    _item:retain()
end
function UIAllianceRunRank.setup()
    local data = { }
    netSendPackage( { header = StaticMsgRule.lookTrutleRank , msgdata = {} } , function ( pack )
        local thingData = pack.msgdata.message.turtleRank.message
        if thingData then
            for key , value in pairs( thingData ) do
                data[ #data + 1 ] = { id = value.int.rank , name = value.string.unionName , score = value.int.score , award = value.string.reward , flag = value.int.flagId }
            end
            utils.quickSort( data , function ( obj1 , obj2 )
                if obj1.id > obj2.id then
                    return true
                else
                    return false
                end
            end)
        end
       -- local things = thingData[ "1" ].string
       refreshView( data )
    end)   
end
function UIAllianceRunRank.free()

end
