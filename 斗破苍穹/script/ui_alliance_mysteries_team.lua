require"Lang"
UIAllianceMysteriesTeam = {}
local _scrollView = nil
local _item = nil
local function setScrollViewItem( item , _data )
    local isM = 0 
    if type( _data ) == "number" then
        isM = 1
    end
    cclog( "  "..isM )
    local btn_no = item:getChildByName( "btn_no" )
    local function onItemEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_no then
                local sendData = {
                    header = StaticMsgRule.makeTeam ,
                    msgdata = { 
                        int = {
                            id = ( isM == 1 and -1 or _data.int["3"] )
                        }
                    }
                }
                netSendPackage( sendData , function ( pack )
                    UIAllianceMysteries.setPersionN( 2 , ( isM == 1 and -1 or _data.string["13"] ) )
                    UIManager.popScene()
                end )
            end
        end
    end
    btn_no:setPressedActionEnabled( true )
    btn_no:addTouchEventListener( onItemEvent )

    local ui_icon = ccui.Helper:seekNodeByName( item , "image_title" )
    local ui_vipFlag = ccui.Helper:seekNodeByName( item , "image_vip" )
    local ui_level = ccui.Helper:seekNodeByName( item , "text_lv" )
    local ui_fight = ccui.Helper:seekNodeByName( item , "text_fight" )
    local ui_name = ccui.Helper:seekNodeByName( item , "text_name" )
    if isM == 1 then
        ui_name:setString(Lang.ui_alliance_mysteries_team1)
        local dictCard = DictCard[tostring(51)]
	    if dictCard then
		    ui_icon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
	    end
		ui_vipFlag:setVisible(false)
        ui_level:setString(Lang.ui_alliance_mysteries_team2..200)
	    ui_fight:setString(Lang.ui_alliance_mysteries_team3..0)
    else
        ui_name:setString(_data.string["10"])
        local dictCardId = utils.stringSplit(_data.string["13"],"_")[1]
        local isAwake = utils.stringSplit(_data.string["13"],"_")[2]
        local dictCard = DictCard[tostring(dictCardId)]
	    if dictCard then
            if tonumber(isAwake) == 1 then
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
        ui_level:setString(Lang.ui_alliance_mysteries_team4.._data.int["11"])
	    ui_fight:setString(Lang.ui_alliance_mysteries_team5.._data.int["15"])
    end
end
local function callBack( pack )
    if pack.header == StaticMsgRule.enterUnionTeam then
        local data = { }
        if pack.msgdata.string.members and pack.msgdata.string.members == "" then
            data[ 1 ] = -1
        else
            local members = utils.stringSplit( pack.msgdata.string.members , ";" )           
            if UIAllianceMysteries.members then
                for i = 1 , #members do
                    for key , value in pairs ( UIAllianceMysteries.members ) do
                        if tonumber( members[ i ] ) == value.int[ "3" ] then
                            table.insert( data , value )
                        end
                    end
                end
            end
        end
        utils.updateScrollView( UIAllianceMysteriesTeam.Widget , _scrollView , _item , data , setScrollViewItem )
    end
end
local function netSendData( type )
    local sendData = {}
    if type == 1 then
        sendData = {
            header = StaticMsgRule.enterUnionTeam ,
            msgdata = {
            }
        }
    elseif type == 2 then
    end
    netSendPackage( sendData , callBack )
end
function UIAllianceMysteriesTeam.init()
    ccui.Helper:seekNodeByName( UIAllianceMysteriesTeam.Widget , "btn_clean" ):setVisible( false )
    ccui.Helper:seekNodeByName( UIAllianceMysteriesTeam.Widget , "btn_closed" ):setVisible( false )
    ccui.Helper:seekNodeByName( UIAllianceMysteriesTeam.Widget , "text_rank" ):setVisible( false )
    ccui.Helper:seekNodeByName( UIAllianceMysteriesTeam.Widget , "text_title" ):setString( Lang.ui_alliance_mysteries_team6 )
    local btn_close = ccui.Helper:seekNodeByName( UIAllianceMysteriesTeam.Widget , "btn_close" )
    local function onEvent( sender , eventType )
         if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            end
         end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )

    _scrollView = ccui.Helper:seekNodeByName( UIAllianceMysteriesTeam.Widget , "view_info" )
    _item = _scrollView:getChildByName( "image_di_alliance" ):clone()
    _item:retain()
    _item:getChildByName( "btn_yes" ):setVisible( false )
    _item:getChildByName( "btn_no" ):setTitleText( Lang.ui_alliance_mysteries_team7 )
end

function UIAllianceMysteriesTeam.setup()
    _scrollView:removeAllChildren()
    netSendData( 1 )  
end
function UIAllianceMysteriesTeam.free()

end
