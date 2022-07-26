require"Lang"
UIActivityShare = {}
local _scrollView = nil
local _item = nil
local pillTower = nil
local shareState = nil
local function scrollViewItem(_Item,obj)
	local text_info = ccui.Helper:seekNodeByName(_Item,"text_info")
	local image_good = ccui.Helper:seekNodeByName(_Item,"image_good")
	local text_number = ccui.Helper:seekNodeByName(_Item,"text_number")
    local btn_exchange= ccui.Helper:seekNodeByName(_Item,"btn_exchange")
    text_info:setString( obj.name )
    local thingData = utils.getItemProp( obj.rewards )
    text_number:setString(thingData.count..thingData.name)
    image_good:loadTexture(thingData.smallIcon)
  
    local data = utils.stringSplit(obj.conditions, "_")
    local shareType = nil
    if shareState and shareState[ tonumber( obj.id ) ] and shareState[ tonumber( obj.id ) ] == 1 then
        shareType = 3
    elseif tonumber( data[1] ) == 1 then
         if net.InstPlayer.int["4"] < tonumber( data[2] ) then 
            shareType = 1           
         else
            shareType = 2          
         end
    elseif tonumber(data[1]) == 2 then
         if net.InstUnionMember and net.InstUnionMember.int["2"] ~= 0 then
            shareType = 2
         else
            shareType = 1
         end
    elseif tonumber(data[1]) == 3 then --竞技场第一名
        --cclog("竞技场－－－－"..net.InstPlayerArena.int["4"])
        if net.InstPlayerArena and net.InstPlayerArena.int["4"] == 1 then
            shareType = 2
        else
            shareType = 1
        end
    elseif tonumber(data[1]) == 4 then --穿上一件翅膀
        
        local isEquipWing = false
        if net.InstPlayerWing then
            for key ,value in pairs ( net.InstPlayerWing ) do
                if value.int["6"] > 0 then
                   isEquipWing = true 
                   break
                end
            end
        end        
        if isEquipWing then
            shareType = 2
        else 
            shareType = 1
        end
    elseif tonumber(data[1]) == 5 then --参加一次丹塔
        if  pillTower > 0 then
            shareType = 2
        else
            shareType = 1
        end
    elseif tonumber(data[1]) == 6 then --装备异火
        shareType = 1
        if net.InstPlayerYFire then
            for key,value in pairs(net.InstPlayerYFire)  do
                if value.string["8"] and value.string["8"] ~= "" then             
                    shareType = 2
                    break
                end
            end           
        end
    end
    if shareType then
        if shareType == 1 then --条件不满足
            btn_exchange:setTitleText(Lang.ui_activity_share1)
            btn_exchange:setEnabled(false)
            btn_exchange:setBright( false )
        elseif shareType == 2 then 
            btn_exchange:setTitleText(Lang.ui_activity_share2)
            btn_exchange:setEnabled(true)
            btn_exchange:setBright( true )
            btn_exchange:setPressedActionEnabled(true)
        elseif shareType == 3 then
            btn_exchange:setTitleText(Lang.ui_activity_share3)
            btn_exchange:setEnabled(false)
            btn_exchange:setBright( false )
        end
    end
    local function btnEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
           if sender == btn_exchange then
                UIShare.setData( { id = obj.id , title = obj.title ,count =thingData.count ,description = obj.description} )
                UIManager.pushScene("ui_share")
           end              
        end
    end
    
    btn_exchange:addTouchEventListener(btnEvent)
end
function UIActivityShare.init()
    _scrollView = ccui.Helper:seekNodeByName( UIActivityShare.Widget , "view_info" )
    _item = _scrollView:getChildByName("image_base_good"):clone()
    _item:retain()
end

function UIActivityShare.setup()
    shareState = {}
    function callBack()
        _scrollView:removeAllChildren()
        local thing = {}
        for key ,value in pairs( DictActivityshare ) do
            table.insert( thing , value )
        end
        utils.updateScrollView( UIActivityShare.Widget , _scrollView , _item , thing , scrollViewItem , { topSpace = 10 , bottomSpace = 10 })
    end

    local function callBack1( pack )
        --分享状态
        local stateStr = pack.msgdata.string.list
        if stateStr and stateStr ~= "" then
            local state = utils.stringSplit( stateStr , ";" )
            for key ,value in pairs( state ) do
                shareState[ tonumber( value ) ] = 1
            end
        end

        if (not UIPilltower.UserData.historyMaxPoint) then
            UIManager.showLoading()
            netSendPackage({
                header = StaticMsgRule.dantaHandler,
                        msgdata = {int={p2=1}}
                }, function(_msgData)
                        if _msgData then
                            pillTower = _msgData.msgdata.int.r2
                            callBack()
                        end
                    end , function ( data )
                        pillTower = 0
                        callBack()
                    end , nil , true )
        else
            pillTower = UIPilltower.UserData.historyMaxPoint
            callBack()
        end
    end

    netSendPackage( { header = StaticMsgRule.enterSharing , msgdata = { } } , callBack1 )


end

function UIActivityShare.free()
    _scrollView:removeAllChildren()
    pillTower = nil
    shareState = nil
end
