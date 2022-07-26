require"Lang"
UIStarReward = {}
local DictHoldStarGradeReward = nil
local function freshData()
    local objThing = {}
    local objThingValue = {}
    local curStars , freshCount = 0 , 0
    if UIStarLighten.objData then
        local temp = utils.stringSplit( UIStarLighten.objData.string["15"] , ";")
        for key ,value in pairs( temp ) do
            local obj = utils.stringSplit( value , "_" )
            objThing[tonumber(obj[1])] = tonumber(obj[2])
            objThingValue[tonumber(obj[1])] = tonumber(obj[3])
        end
        curStars = UIStarLighten.objData.int["5"]
        freshCount = UIStarLighten.objData.int["11"]
    end
    for i = 1 , 10 do
        local image_reward = ccui.Helper:seekNodeByName( UIStarReward.Widget , "image_reward"..i )
        --image_reward:getChildByName("image_title"):setVisible( false )
        local thing = DictHoldStarGradeReward[tostring(objThing[11-i])].thing
        local thingData = utils.getItemProp( thing )
        if thingData.flagIcon then
            image_reward:getChildByName("image_title"):setVisible( true )
        else
            image_reward:getChildByName("image_title"):setVisible( false )
        end
        image_reward:loadTexture( thingData.frameIcon )
        image_reward:getChildByName("text_name"):setTextColor(cc.c3b( 255 , 255 , 255))
        image_reward:getChildByName("text_name"):setString( thingData.name )
        image_reward:getChildByName("image_good"):loadTexture( thingData.smallIcon )
        image_reward:getChildByName("image_star"):getChildByName("text_star"):setString( DictHoldStarRewardPos[tostring(( 11 - i ))].starNum )
        image_reward:getChildByName("text_number"):setVisible(true)
        image_reward:getChildByName("text_number"):setString("x"..thingData.count)
        if i <= 9 then
            local image_wire = ccui.Helper:seekNodeByName( UIStarReward.Widget , "image_wire"..i )
            if curStars >= DictHoldStarRewardPos[tostring(( 11 - i ))].starNum then
                utils.GrayWidget( image_wire , false )               
                if objThingValue[11-i] == 1 then
                    utils.addFrameParticle( image_reward:getChildByName("image_good") , false )
                    image_reward:getChildByName("text_name"):setTextColor(cc.c3b( 255 , 0 , 0))
                    image_reward:getChildByName("text_name"):setString(Lang.ui_star_reward1)
                    image_reward:getChildByName("text_number"):setVisible( false )
                else
                    utils.addFrameParticle( image_reward:getChildByName("image_good") , true )                   
                end
            else
                utils.GrayWidget( image_wire , true )
                utils.addFrameParticle( image_reward:getChildByName("image_good") )
            end
        elseif i == 10 then
            if curStars >= DictHoldStarRewardPos[tostring(( 11 - i ))].starNum then
                if objThingValue[11-i] == 1 then
                    utils.addFrameParticle( image_reward:getChildByName("image_good") , false )
                    image_reward:getChildByName("text_name"):setTextColor(cc.c3b( 255 , 0 , 0))
                    image_reward:getChildByName("text_name"):setString(Lang.ui_star_reward2)
                    image_reward:getChildByName("text_number"):setVisible( false )
                else
                    utils.addFrameParticle( image_reward:getChildByName("image_good") , true )
                end
            else
                utils.addFrameParticle( image_reward:getChildByName("image_good") )
            end
        end
        utils.showThingsInfo( image_reward , thingData.tableTypeId , thingData.tableFieldId )
    end
    local btn_refresh = ccui.Helper:seekNodeByName( UIStarReward.Widget , "btn_refresh" )
    local text_left = btn_refresh:getChildByName( "text_left" )
    text_left:setString(Lang.ui_star_reward3..( DictVIP[ tostring( net.InstPlayer.int["19"] + 1 )].holdStarRewardRefreshTimes - freshCount))
    local text_star_number = ccui.Helper:seekNodeByName( UIStarReward.Widget , "text_star_number" )
    text_star_number:setString(Lang.ui_star_reward4..curStars)
    local text_number = ccui.Helper:seekNodeByName( btn_refresh , "text_number" )
    local goldNum = DictHoldStarRewardRefreshTimes["1"].needGold
    for key , value in pairs( DictHoldStarRewardRefreshTimes ) do
        if value.starTimes >= freshCount + 1 and value.endTimes <= freshCount + 1 then
            goldNum = value.needGold
            break
        end
    end
    text_number:setString(goldNum)
end
local function netCallBack( pack )
    if pack.header == StaticMsgRule.oneKeyGet then
        if pack.msgdata.string then
            local thing = utils.stringSplit( pack.msgdata.string["1"] , ";")
            local thingData = {}
            for key , value in pairs( thing ) do
                local data = utils.getItemProp( value )
                thingData[ #thingData + 1 ] = { tableTypeId = data.tableTypeId , tableFieldId = data.tableFieldId , value = data.count }
            end
            if #thingData > 0 then
                UIBoxGet.setData(thingData)
                UIManager.pushScene("ui_box_get")
            end
        end
        UIStarReward.setup()
        UIManager.flushWidget( UIStarLighten )
    elseif pack.header == StaticMsgRule.refreshStarReward then
        UIStar.curChooseG = pack.msgdata.int.openGradeId  
        UIStarReward.setup()
        UIManager.flushWidget( UIStarLighten )
    elseif pack.header == StaticMsgRule.intoHoldStarReward then
        DictHoldStarGradeReward = {}
        local tempStr = pack.msgdata.string["1"]
        local tempTable = utils.stringSplit( tempStr , "/" )
        for key ,value in pairs( tempTable ) do
            local thingData = utils.stringSplit( value , "|" )
         --   cclog( "thingdata :" .. thingData[1].."  "..thingData[2])
            DictHoldStarGradeReward[tostring( thingData[1] )] = { thing = thingData[ 2 ] }
        end
        freshData()
    end
    
end
local function netSend( type )
    UIManager.showLoading()
    local sendData = {}
    if type == 1 then --一键领取
        sendData = {
            header = StaticMsgRule.oneKeyGet ,
            msgdata = {
                int = {
                    gradeId = UIStarLighten.curChooseGrade
                }
            }
        }
    elseif type == 2 then -- 刷新
        sendData = {
            header = StaticMsgRule.refreshStarReward ,
            msgdata = {
                int = {
                    gradeId = UIStarLighten.curChooseGrade
                }
            }
        }
    elseif type == 3 then--进入奖励界面
        sendData = {
            header = StaticMsgRule.intoHoldStarReward ,
            msgdata = {
                
            }
        }
    end
    netSendPackage( sendData , netCallBack )
end
function UIStarReward.init()
    local btn_close = ccui.Helper:seekNodeByName( UIStarReward.Widget , "btn_close" )
    local btn_refresh = ccui.Helper:seekNodeByName( UIStarReward.Widget , "btn_refresh" )
    local btn_one = ccui.Helper:seekNodeByName( UIStarReward.Widget , "btn_one" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_refresh then
                netSend( 2 )
            elseif sender == btn_one then
                netSend( 1 )
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    btn_refresh:setPressedActionEnabled( true )
    btn_refresh:addTouchEventListener( onEvent )
    btn_one:setPressedActionEnabled( true )
    btn_one:addTouchEventListener( onEvent )
end
function UIStarReward.checkHint() 
    local isHint = false
    if UIStarLighten.objData then
           local objThingValue = {}
        local temp = utils.stringSplit( UIStarLighten.objData.string["15"] , ";")
        for key ,value in pairs( temp ) do
             local obj = utils.stringSplit( value , "_" )
             objThingValue[tonumber(obj[1])] = tonumber(obj[3])
        end
        local curStars = UIStarLighten.objData.int["5"]
        for i = 1 , 10 do       
            if curStars >= DictHoldStarRewardPos[tostring(( i ))].starNum then            
                    if objThingValue[i] == 0 then
                        isHint = true
                        break           
                    end
             end
        end
    end
    return isHint
end

function UIStarReward.setup()
    netSend( 3 )  
end
function UIStarReward.free()
    DictHoldStarGradeReward = nil
end
