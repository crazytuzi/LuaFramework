require"Lang"
UIActivityFund = {}
local _startTime = nil
local _endTime = nil
local _curGold = nil
local _maxGold = nil
local DEBUG = false
local _goods = nil
local _type = {
    ENTER = 1 ,
    ACTIVE = 2
}
local _select = nil
--刷新基金选中
local function refreshFund( isNP )
    if _select then
        local image_fund1 = ccui.Helper:seekNodeByName( UIActivityFund.Widget , "image_fund1" )--基金一
        if isNP then
            utils.addFrameParticle( image_fund1 )
        elseif _select[ 1 ] == 1 then
            utils.addFrameParticle( image_fund1 , true , 1.2 , false , 60 , 20 )
        else
            utils.addFrameParticle( image_fund1 )
        end
        local image_fund2 = ccui.Helper:seekNodeByName( UIActivityFund.Widget , "image_fund2" )--基金二
        if isNP then
            utils.addFrameParticle( image_fund2 )
        elseif _select[ 2 ] == 1 then
            utils.addFrameParticle( image_fund2 , true , 1.2 , false , 60 , 20 )
        else
            utils.addFrameParticle( image_fund2 )
        end
        local image_fund3 = ccui.Helper:seekNodeByName( UIActivityFund.Widget , "image_fund3" )--基金三
        if isNP then
            utils.addFrameParticle( image_fund3 )
        elseif _select[ 3 ] == 1 then
            utils.addFrameParticle( image_fund3 , true , 1.2 , false , 60 , 20 )
        else
            utils.addFrameParticle( image_fund3 )
        end       
    end
end
--刷新界面上的信息
local function refreshInfo()
    if _goods then
        local image_fund1 = ccui.Helper:seekNodeByName( UIActivityFund.Widget , "image_fund1" )--基金一
        local image_good1 = image_fund1:getChildByName( "image_frame_good" ):getChildByName( "image_good" )
        local dictData1 = utils.getItemProp( _goods[ 1 ] )
        image_good1:loadTexture( dictData1.smallIcon )
        utils.addFrameParticle( image_good1 , true )
        utils.showThingsInfo( image_good1 , dictData1.tableTypeId , dictData1.tableFieldId )
        utils.addBorderImage( dictData1.tableTypeId , dictData1.tableFieldId , image_fund1:getChildByName( "image_frame_good" ) )
        local image_fund2 = ccui.Helper:seekNodeByName( UIActivityFund.Widget , "image_fund2" )--基金二
        local image_good2 = image_fund2:getChildByName( "image_frame_good" ):getChildByName( "image_good" )
        local dictData2 = utils.getItemProp( _goods[ 2 ] )
        image_good2:loadTexture( dictData2.smallIcon )
        utils.addFrameParticle( image_good2 , true )
        utils.addBorderImage( dictData2.tableTypeId , dictData2.tableFieldId , image_fund2:getChildByName( "image_frame_good" ) )
        utils.showThingsInfo( image_good2 , dictData2.tableTypeId , dictData2.tableFieldId )
        local image_fund3 = ccui.Helper:seekNodeByName( UIActivityFund.Widget , "image_fund3" )--基金三
        local image_good3 = image_fund3:getChildByName( "image_frame_good" ):getChildByName( "image_good" )  
        local dictData3 = utils.getItemProp( _goods[ 3 ] )
        image_good3:loadTexture( dictData3.smallIcon )
        utils.addFrameParticle( image_good3 , true )
        utils.showThingsInfo( image_good3 , dictData3.tableTypeId , dictData3.tableFieldId )
        utils.addBorderImage( dictData3.tableTypeId , dictData3.tableFieldId , image_fund3:getChildByName( "image_frame_good" ) )
    end
    local image_loading = ccui.Helper:seekNodeByName( UIActivityFund.Widget , "image_loading" )
    local bar = image_loading:getChildByName( "bar_loading" )
    local percent = _curGold / _maxGold
    if _curGold > _maxGold then
        percent = 1
    end
    bar:setPercent( percent * 100 )

    local noteX = bar:getPositionX() - bar:getContentSize().width / 2
    local barParticle = image_loading:getChildByName("barParticle")
    if not barParticle then
        barParticle = cc.ParticleSystemQuad:create("particle/ui_fire_effect01.plist")
        barParticle:setPositionType(cc.POSITION_TYPE_GROUPED)
        barParticle:setName("barParticle")
        barParticle:setPosition( cc.p( noteX , bar:getPositionY() ) )
        image_loading:addChild( barParticle , 100 )
    end
    local _color = cc.c4b(13, 153, 175, 255)
    if bar:getPercent() >= 50 then
        _color = cc.c4b(0, 255, 0, 255)
    end
    barParticle:setScale( 0.8 )
    barParticle:setStartColor(_color)
    barParticle:setPositionX( noteX + bar:getContentSize().width * percent )
end
local function callBack( pack )
    if DEBUG then
        if pack.header == _type.ENTER then
            _goods = {
                "3_1_50" ,
                "3_1_400" ,
                "3_1_750"
            }
            refreshInfo()
        end
    end

    if pack.header == StaticMsgRule.openFundInvokerPanel then
        _curGold = pack.msgdata.int.fundChongZhi
        _goods[ 1 ] = pack.msgdata.string.fundLastReward1
        _goods[ 2 ] = pack.msgdata.string.fundLastReward2
        _goods[ 3 ] = pack.msgdata.string.fundLastReward3
        refreshInfo()
        _select[ 1 ] = pack.msgdata.int.fundJiHuo1
        _select[ 2 ] = pack.msgdata.int.fundJiHuo2
        _select[ 3 ] = pack.msgdata.int.fundJiHuo3
        local btn_activation = ccui.Helper:seekNodeByName( UIActivityFund.Widget , "btn_activation" )--激活
        local image_fund1 = ccui.Helper:seekNodeByName( UIActivityFund.Widget , "image_fund1" )--基金一
        local image_fund2 = ccui.Helper:seekNodeByName( UIActivityFund.Widget , "image_fund2" )--基金二
        local image_fund3 = ccui.Helper:seekNodeByName( UIActivityFund.Widget , "image_fund3" )--基金三

        if _curGold >= DictSysConfig[ tostring( StaticSysConfig.Fund1OpenGold ) ].value then
           image_fund1:loadTexture( "ui/fund_open.png" )
        else
           image_fund1:loadTexture( "ui/fund_close.png" )
        end
        if _curGold >= DictSysConfig[ tostring( StaticSysConfig.Fund2OpenGold ) ].value then
           image_fund2:loadTexture( "ui/fund_open.png" )
        else
           image_fund2:loadTexture( "ui/fund_close.png" )
        end
        if _curGold >= DictSysConfig[ tostring( StaticSysConfig.Fund3OpenGold ) ].value then
            image_fund3:loadTexture( "ui/fund_open.png" )
        else
            image_fund3:loadTexture( "ui/fund_close.png" )
        end

        if _select[ 1 ] == 1 or _select[ 2 ] == 1 or _select[ 3 ] == 1 then           
            utils.GrayWidget( btn_activation , true )
            btn_activation:setTouchEnabled( false )
            image_fund1:setTouchEnabled( false )
            image_fund2:setTouchEnabled( false )
            image_fund3:setTouchEnabled( false )

            if _select[ 1 ] == 1 then
                --fund_open
                image_fund1:getChildByName("image_yjh"):setVisible( true )    
            else
                image_fund1:getChildByName("image_yjh"):setVisible( false )            
            end
            if _select[ 2 ] == 1 then
                image_fund2:getChildByName("image_yjh"):setVisible( true )
            else
                image_fund2:getChildByName("image_yjh"):setVisible( false ) 
            end
            if _select[ 3 ] == 1 then
                image_fund3:getChildByName("image_yjh"):setVisible( true )
            else
                image_fund3:getChildByName("image_yjh"):setVisible( false ) 
            end
            refreshFund( true )
        else
            utils.GrayWidget( btn_activation , false )
            btn_activation:setTouchEnabled( true )
            image_fund1:setTouchEnabled( true )
            image_fund2:setTouchEnabled( true )
            image_fund3:setTouchEnabled( true )
            image_fund1:getChildByName("image_yjh"):setVisible( false )
            image_fund2:getChildByName("image_yjh"):setVisible( false )
            image_fund3:getChildByName("image_yjh"):setVisible( false )
            refreshFund()
        end
        
    elseif pack.header == StaticMsgRule.fundInvokerData then
        UIActivityFund.setup()
    end
end
local function netSendData( type )
    if DEBUG then
        _curGold = 1000
        callBack( { header = type } )
        return
    end
    local sendData = nil
    if type == _type.ENTER then
        sendData = {
            header = StaticMsgRule.openFundInvokerPanel ,
            msgdata = {}
        }
    elseif type == _type.ACTIVE then
        sendData = {
            header = StaticMsgRule.fundInvokerData ,
            msgdata = {
                int = {
                    fund1 = _select[ 1 ] , 
                    fund2 = _select[ 2 ] , 
                    fund3 = _select[ 3 ]
                }
            }
        }
    end
    UIManager.showLoading()
    netSendPackage( sendData , callBack )
end
function UIActivityFund.init()
    local btn_reward = ccui.Helper:seekNodeByName( UIActivityFund.Widget , "btn_reward" )--基金奖励
    local btn_activation = ccui.Helper:seekNodeByName( UIActivityFund.Widget , "btn_activation" )--激活
    local btn_help = ccui.Helper:seekNodeByName( UIActivityFund.Widget , "btn_help" )--帮助
    local image_fund1 = ccui.Helper:seekNodeByName( UIActivityFund.Widget , "image_fund1" )--基金一
    local image_fund2 = ccui.Helper:seekNodeByName( UIActivityFund.Widget , "image_fund2" )--基金二
    image_fund2:getChildByName( "text_fund" ):setString( Lang.ui_activity_fund1 )
    local image_fund3 = ccui.Helper:seekNodeByName( UIActivityFund.Widget , "image_fund3" )--基金三
    image_fund3:getChildByName( "text_fund" ):setString( Lang.ui_activity_fund2 )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_reward then
                UIManager.pushScene( "ui_activity_fund_reward" )
            elseif sender == btn_activation then
                if _select[ 1 ] == 0 and _select[ 2 ] == 0 and _select[ 3 ] == 0 then
                    UIManager.showToast( Lang.ui_activity_fund3 )
                else
                    local allGold = 0
                    local str = ""
                    if _select[ 1 ] == 1 then
                        allGold = allGold + DictSysConfig[ tostring( StaticSysConfig.Fund1CostGold ) ].value
                        str = str .. Lang.ui_activity_fund4
                    end
                    if _select[ 2 ] == 1 then
                        allGold = allGold + DictSysConfig[ tostring( StaticSysConfig.Fund2CostGold ) ].value
                        if str == "" then
                            str = str .. Lang.ui_activity_fund5
                        else
                            str = str .. Lang.ui_activity_fund6
                        end
                    end
                    if _select[ 3 ] == 1 then
                        allGold = allGold + DictSysConfig[ tostring( StaticSysConfig.Fund3CostGold ) ].value
                        if str == "" then
                            str = str .. Lang.ui_activity_fund7
                        else
                            str = str .. Lang.ui_activity_fund8
                        end
                    end
                    local count = 0
                    if _curGold >= DictSysConfig[ tostring( StaticSysConfig.Fund3OpenGold ) ].value then
                        count = 3
                    elseif _curGold >= DictSysConfig[ tostring( StaticSysConfig.Fund2OpenGold ) ].value then
                        count = 2
                    elseif _curGold >= DictSysConfig[ tostring( StaticSysConfig.Fund1OpenGold ) ].value then
                        count = 1
                    end
                    utils.showDialog( Lang.ui_activity_fund9..allGold..Lang.ui_activity_fund10.. Lang.ui_activity_fund11..str , function ()
                        netSendData( _type.ACTIVE )
                    end)
                end            
            elseif sender == btn_help then
                UIAllianceHelp.show( { type = 26 , titleName = Lang.ui_activity_fund12 } )
            elseif sender == image_fund1 then
                if _select[ 1 ] == 1 then
                    _select[ 1 ] = 0
                else
                    _select[ 1 ] = 1
                end
                refreshFund()
            elseif sender == image_fund2 then
                if _select[ 2 ] == 1 then
                    _select[ 2 ] = 0
                else
                    _select[ 2 ] = 1
                end
                refreshFund()
            elseif sender == image_fund3 then
                if _select[ 3 ] == 1 then
                    _select[ 3 ] = 0
                else
                    _select[ 3 ] = 1
                end
                refreshFund()
            end
        end
    end
    btn_reward:setPressedActionEnabled( true )
    btn_reward:addTouchEventListener( onEvent )
    btn_activation:setPressedActionEnabled( true )
    btn_activation:addTouchEventListener( onEvent )
    btn_help:setPressedActionEnabled( true )
    btn_help:addTouchEventListener( onEvent )
    image_fund1:setTouchEnabled( true )
    image_fund1:addTouchEventListener( onEvent )
    image_fund2:setTouchEnabled( true )
    image_fund2:addTouchEventListener( onEvent )
    image_fund3:setTouchEnabled( true )
    image_fund3:addTouchEventListener( onEvent )

    local image_loading = ccui.Helper:seekNodeByName( UIActivityFund.Widget , "image_loading" )
    local bar_loading = image_loading:getChildByName( "bar_loading" )
    local noteX = bar_loading:getPositionX() - bar_loading:getContentSize().width / 2
    cclog( "noteX :"..noteX )
    local image_note1 = image_loading:getChildByName( "image_note1" )
    image_note1:setPositionX( noteX + bar_loading:getContentSize().width * DictSysConfig[ tostring( StaticSysConfig.Fund1OpenGold ) ].value / DictSysConfig[ tostring( StaticSysConfig.Fund3OpenGold ) ].value )
    local image_note2 = image_loading:getChildByName( "image_note2" )
    image_note2:setPositionX( noteX + bar_loading:getContentSize().width * DictSysConfig[ tostring( StaticSysConfig.Fund2OpenGold ) ].value / DictSysConfig[ tostring( StaticSysConfig.Fund3OpenGold ) ].value )

    local image_gold2 = image_loading:getChildByName( "image_gold2" )
    image_gold2:setPositionX( noteX + bar_loading:getContentSize().width * DictSysConfig[ tostring( StaticSysConfig.Fund1OpenGold ) ].value / DictSysConfig[ tostring( StaticSysConfig.Fund3OpenGold ) ].value )
    local image_gold3 = image_loading:getChildByName( "image_gold3" )
    image_gold3:setPositionX( noteX + bar_loading:getContentSize().width * DictSysConfig[ tostring( StaticSysConfig.Fund2OpenGold ) ].value / DictSysConfig[ tostring( StaticSysConfig.Fund3OpenGold ) ].value )
    
end
function UIActivityFund.setup()
    _select = { 0 , 0 , 0 }
    _goods = {}
    _maxGold = DictSysConfig[ tostring( StaticSysConfig.Fund3OpenGold ) ].value
    local text_time = ccui.Helper:seekNodeByName( UIActivityFund.Widget , "text_time" )--活动时间：10月10日12点--11月11日11点
    text_time:setString( Lang.ui_activity_fund13.._startTime[ 2 ]..Lang.ui_activity_fund14.._startTime[ 3 ]..Lang.ui_activity_fund15.._startTime[ 4 ]..Lang.ui_activity_fund16.._endTime[ 2 ]..Lang.ui_activity_fund17.._endTime[ 3 ]..Lang.ui_activity_fund18.._endTime[ 4 ]..Lang.ui_activity_fund19 )
    netSendData( _type.ENTER )
end
function UIActivityFund.free()
    _startTime = nil
    _endTime = nil
    _select = nil
    _curGold = nil
    _maxGold = nil
    _goods = nil
end
function UIActivityFund.onActivity(_params)
    local data = _params  
    _startTime = utils.changeTimeFormat( data.string["4"] )
    _endTime = utils.changeTimeFormat( data.string["5"] )  
end
