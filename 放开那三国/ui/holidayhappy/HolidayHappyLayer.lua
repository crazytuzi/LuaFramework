-- FileName: HolidayHappyLayer.lua 
-- Author: fuqiongqiong
-- Date: 2016-5-27
-- Purpose: 节日狂欢主界面

module("HolidayHappyLayer",package.seeall)
require "script/ui/holidayhappy/HolidayHappyData"
require "script/ui/holidayhappy/HolidayHappyCell"
require "script/ui/holidayhappy/HolidayHappyController"
require "script/ui/holidayhappy/HolidayHappyLimitExchargeLayer"

local _tableView
local _priority
local _zOrder
local _btnAry
local _dataOfFestival
local _seasonBtnAry
local _data
local _tableViewBg
local _bgLayer 
local _kLableFour = 4
local _biaoqianNum 
local _seasonNum 
local _countdownTime
local _imageData
local _height 
local _redTipSprite
local _fourMenuBar = nil

function init( ... )
    _priority   = nil
    _zOrder     = nil
	_tableView  = nil
    _tableViewBg = nil
    _countdownTime = nil
    _bgLayer    = nil
    _biaoqianNum = nil
    _redTipSprite = nil
    _btnAry     = {}
    _dataOfFestival = nil
    _imageData = nil
    _height = nil
    _data = {}
    _seasonBtnAry   = {}
    _imagePath      = {
        tap_btn_n   = "images/common/btn_title_n.png",
        tap_btn_h   = "images/common/btn_title_h.png"
    }
    _fourMenuBar = nil
end

--开启时间调度器
function startSchedule()
    if(_timeCounter == nil)then
        _timeCounter = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTime, 1, false)
    end
end

--关闭时间调度器
function stopSchedule()
    if(_timeCounter)then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_timeCounter)
        _timeCounter = nil
    end
end

--更新倒计时
function updateTime( ... )
    local seasonNum = HolidayHappyData.getSeasonNum()
    if(seasonNum == 0)then
        local rewardData = HolidayHappyData.getDataOfFestival_act()
        seasonNum = #rewardData
    end
    local time = HolidayHappyData.remineTimeOfSeason(seasonNum)
    _countdownTime:setString(time)
    local timestr =  TimeUtil.getIntervalByTimeDesString(tonumber(HolidayHappyData.getOneDataOfFestival_act(seasonNum).end_time)) - TimeUtil:getSvrTimeByOffset() 
    if(timestr == 0)then
        stopSchedule()
        show()
    end
end
--事件注册
function onTouchesHandler( eventType )
    if(eventType == "began")then
        return true
    elseif(eventType == "moved")then
        
    elseif(eventType == "end")then
        
    end
end

function onNodeEvent( event )
    if(event == "enter")then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler,false, _priority,true)
        _bgLayer:setTouchEnabled(true)
    elseif(event == "exit")then
        stopSchedule()
        _bgLayer:unregisterScriptTouchHandler()
        -- _bgLayer = nil
    end
end

--节日狂欢入口
function show( ... )
    local isShow = HolidayHappyData.isOpen()
    if(isShow == false) then
        AnimationTip.showTip(GetLocalizeStringBy("lcyx_3002"))
        return
    end

    local holidayHappyLayer = create()
    MainScene.changeLayer(holidayHappyLayer, "holidayHappyLayer")
end

function getInfoCallback (  )
    -- _bgLayer:removeAllChildrenWithCleanup(true)
    _seasonBtnAry = {}
    _tableView = nil
    local dataOfFestival = HolidayHappyData.getDataOfFestival_act()
    local seasonNum = HolidayHappyData.getSeasonNum()
    --第一季倒计时结束，请求回来后端还是第一季就前端自己置为第二季，避免出现前端比后端早结束导致的第二季界面不显示问题
    if(seasonNum == 1 ) then
        local cutTime = TimeUtil.getIntervalByTimeDesString(tonumber(HolidayHappyData.getOneDataOfFestival_act(seasonNum).end_time)) - BTUtil:getSvrTimeInterval()
        if (cutTime <= 0) then
            local rewardData = HolidayHappyData.getDataOfFestival_act()
            seasonNum = #rewardData
            HolidayHappyData.setSeasonNum(seasonNum)
        end
    end
    if(seasonNum==0)then
        local rewardData = HolidayHappyData.getDataOfFestival_act()
        seasonNum = #rewardData
    end
    _imageData = dataOfFestival[seasonNum]
    --背景
    local bg = CCSprite:create("images/holidayhappy/".._imageData.background)
    bg:setAnchorPoint(ccp(0.5,0.5))
    bg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    bg:setScale(g_fBgScaleRatio)
    _bgLayer:addChild(bg)

    --创建上半部分人物
    -- local spriteBg = CCSprite:create("images/holidayhappy/spritebg.png") --[[640,362]]
    local spriteBg = CCSprite:create("images/holidayhappy/".._imageData.character)
    _bgLayer:addChild(spriteBg)
    spriteBg:setScale(g_fScaleX)
    spriteBg:setAnchorPoint(ccp(0.5,1))
    spriteBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height))
    
    -- 背景特效
    if( _imageData.background_efc and string.len(_imageData.background_efc) > 0 )then
        require "script/animation/XMLSprite"
        local bgEffect = XMLSprite:create("images/holidayhappy/effect/".. _imageData.background_efc .. "/" .. _imageData.background_efc)
        bgEffect:setAnchorPoint(ccp(0.5,0.5))
        bgEffect:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
        _bgLayer:addChild(bgEffect,10)
        bgEffect:setScale(g_fElementScaleRatio)
    end

    -- 获得是活动的第几季
    _dataOfFestival = HolidayHappyData.getDataOfFestival_act()
    createUI()
    createSeasonButton()
end

function create( ... )
	init() 
    MainScene.setMainSceneViewsVisible(false,false,false)
    _priority =  -500
    _zOrder =  10
    _bgLayer = CCLayer:create()
    _bgLayer:registerScriptHandler(onNodeEvent)
    HolidayHappyController.getInfo(getInfoCallback)
    return _bgLayer
end


function createUI( ... )
    --节日标题
    local titilebg = CCSprite:create("images/holidayhappy/".._imageData.title)
    titilebg:setAnchorPoint(ccp(0.5,0.5))
    titilebg:setScale(g_fScaleX)
    titilebg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height - 40*g_fScaleX))
    _bgLayer:addChild(titilebg)

    -- 特效
    if( _imageData.title_efc and string.len(_imageData.title_efc) > 0 )then
        require "script/animation/XMLSprite"
        local titileEffect = XMLSprite:create("images/holidayhappy/effect/".. _imageData.title_efc .. "/" .. _imageData.title_efc)
        titileEffect:setAnchorPoint(ccp(0.5,0.5))
        titileEffect:setPosition(ccp(g_winSize.width*0.5,g_winSize.height - 40*g_fScaleX))
        _bgLayer:addChild(titileEffect)
        titileEffect:setScale(g_fScaleX)
    end
	-- 按钮
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_priority - 10)
    _bgLayer:addChild(menuBar,10)
    --关闭按钮
    local returnButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    returnButton:setScale(g_fScaleX)
    returnButton:setAnchorPoint(ccp(1,1))
    returnButton:setPosition(ccp(g_winSize.width-20*g_fScaleX,g_winSize.height-20*g_fScaleX))
    returnButton:registerScriptTapHandler(closeCallBack)
    menuBar:addChild(returnButton)

    --限时兑换按钮
    local limitExchargeButton = CCMenuItemImage:create("images/holidayhappy/duihuan-n.png","images/holidayhappy/duihuan-h.png")
    limitExchargeButton:setAnchorPoint(ccp(1,1))
    limitExchargeButton:setScale(g_fScaleX)
    limitExchargeButton:setPosition(ccp(g_winSize.width-28*g_fScaleX - returnButton:getContentSize().width*g_fScaleX,g_winSize.height-10*g_fScaleX))
    limitExchargeButton:registerScriptTapHandler(limitExchargeButtonCallBack)
    menuBar:addChild(limitExchargeButton)
    --添加红点
    if(HolidayHappyData.isRedTipOfExchange2())then
        if(HolidayHappyData.isRedTipOfExchange() )then
            _redTipSprite = redTipSprite()
            _redTipSprite:setAnchorPoint(ccp(1,1))
            _redTipSprite:setPosition(ccp(limitExchargeButton:getContentSize().width*0.98,limitExchargeButton:getContentSize().height*0.98))
            limitExchargeButton:addChild(_redTipSprite,100,300)
        end
    end
    

    --活动时间
    local beginTime = HolidayHappyData.startTimeLable()
    local endTime = HolidayHappyData.endTimeLable()
    local endTimeLabel = CCRenderLabel:create(GetLocalizeStringBy("fqq_099") .. beginTime .. "-" .. endTime, g_sFontName, 25, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    endTimeLabel:setColor(ccc3(0x00, 0xff, 0x18))
    endTimeLabel:setAnchorPoint(ccp(0.5, 1))
    endTimeLabel:setScale(g_fScaleX)
    endTimeLabel:setPosition(ccp(g_winSize.width*0.5,g_winSize.height - 25*g_fScaleX - titilebg:getContentSize().height*g_fScaleX))
    _height = endTimeLabel:getPositionY() - endTimeLabel:getContentSize().height*g_fScaleX
    _bgLayer:addChild(endTimeLabel) 
    _tableViewBg = CCScale9Sprite:create("images/holidayhappy/tableviewbg.png")
    _bgLayer:addChild(_tableViewBg)
    _tableViewBg:setPreferredSize(CCSizeMake(630*g_fScaleX, _height-58*g_fScaleX-95*g_fScaleX -115*g_fScaleX))
    _tableViewBg:setAnchorPoint(ccp(0.5, 1))
    _tableViewBg:setPosition(ccp(g_winSize.width*0.5, _height-(58+85+110)*g_fScaleX ))
    local seasonNum = HolidayHappyData.getSeasonNum()
    if(seasonNum == 0)then
        local rewardData = HolidayHappyData.getDataOfFestival_act()
        seasonNum = #rewardData
    end
    _seasonNum = seasonNum
    seasonItemButtonCallback(seasonNum)
end
--创建第一季，第二季按钮
function createSeasonButton( ... )
    --获取现在处于第几季
    local seasonNum = HolidayHappyData.getSeasonNum()
    if(seasonNum == 0)then
        local rewardData = HolidayHappyData.getDataOfFestival_act()
        seasonNum = #rewardData
    end
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_priority - 10)
    _bgLayer:addChild(menuBar)
    
    _seasonBtnAry = {}
    local rewardData = HolidayHappyData.getDataOfFestival_act()
    for i=1,#rewardData do
        local dataArray = string.split(_imageData["Button"..i],",")
        local seasonItemButton = CCMenuItemImage:create("images/holidayhappy/"..dataArray[1],"images/holidayhappy/"..dataArray[2],"images/holidayhappy/"..dataArray[2])
        menuBar:addChild(seasonItemButton,1,i)
        seasonItemButton:setAnchorPoint(ccp(0.5,1))
        seasonItemButton:setScale(g_fScaleX)
        seasonItemButton:setPosition(ccp(g_winSize.width*0.6+seasonItemButton:getContentSize().width*g_fScaleX*(i-1)*1.3,_height-85*g_fScaleX))
        seasonItemButton:registerScriptTapHandler(seasonItemButtonCallback)
        --弹框
        if (i == seasonNum) then
            local tankuang = CCSprite:create("images/holidayhappy/tankuang.png")
            tankuang:setAnchorPoint(ccp(0.5,0))
            tankuang:setPosition(ccp(seasonItemButton:getContentSize().width*0.5,seasonItemButton:getContentSize().height-10))
            seasonItemButton:addChild(tankuang,1,100)

            --防止在第二季结束时，拉取到的信息还是第二级的，强制转为0,类似于第一季跳转第二季时
            if(seasonNum == 2 ) then
                local cutTime = TimeUtil.getIntervalByTimeDesString(tonumber(HolidayHappyData.getOneDataOfFestival_act(seasonNum).end_time)) - BTUtil:getSvrTimeInterval()
                if (cutTime <= 0) then
                    seasonNum = 0
                    HolidayHappyData.setSeasonNum(seasonNum)
                end
            end
            
            local seasonNum = HolidayHappyData.getSeasonNum()
            if(seasonNum == 0)then
               local  time = GetLocalizeStringBy("fqq_096")
               local countdownTime =CCRenderLabel:create(time,g_sFontName,20,1,ccc3(0x00,0x00,0x00),type_stroke)
               countdownTime:setColor(ccc3(0x00,0xff,0x18))
               countdownTime:setAnchorPoint(ccp(0.5,0.5))
               countdownTime:setPosition(ccp(tankuang:getContentSize().width*0.5,tankuang:getContentSize().height*0.6))
               tankuang:addChild(countdownTime) 
            else
               local seasonNum = HolidayHappyData.getSeasonNum()
                if(seasonNum == 0)then
                    local rewardData = HolidayHappyData.getDataOfFestival_act()
                    seasonNum = #rewardData
                end
                local time = HolidayHappyData.remineTimeOfSeason(seasonNum)
                --活动倒计时
                local strLable = CCRenderLabel:create(GetLocalizeStringBy("fqq_100"),g_sFontName,20,1,ccc3(0x00,0x00,0x00),type_stroke)
                strLable:setColor(ccc3(0x00,0xff,0x18))
                strLable:setAnchorPoint(ccp(0.5,1))
                strLable:setPosition(ccp(tankuang:getContentSize().width*0.5,tankuang:getContentSize().height*0.9))
                tankuang:addChild(strLable)

                _countdownTime =CCRenderLabel:create(time,g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
                _countdownTime:setColor(ccc3(0x00,0xff,0x18))
                _countdownTime:setAnchorPoint(ccp(0.5,1))
                _countdownTime:setPosition(ccp(tankuang:getContentSize().width*0.5,tankuang:getContentSize().height*0.89 - strLable:getContentSize().height))
                tankuang:addChild(_countdownTime) 
            end
            
            local seasonNum = HolidayHappyData.getSeasonNum()
            if(seasonNum ~= 0)then
                local cutTime = TimeUtil.getIntervalByTimeDesString(tonumber(HolidayHappyData.getOneDataOfFestival_act(seasonNum).end_time)) - BTUtil:getSvrTimeInterval() 
                if (cutTime > 0) then
                    startSchedule()
                end
            end
            
            --当为第一季时，第一季按钮为不可点击状态，为第二季时，第二季按钮为不可点击状态
            seasonItemButton:setEnabled(false)
        end
        table.insert(_seasonBtnAry,seasonItemButton)
    end
    -- seasonItemButtonCallback(seasonNum)
    -- createFourLabelButton()
end

--点击季度按钮的回调
function seasonItemButtonCallback( tag )
    
    --判断第二季是否开启，若没开启，提示第二季活动未开启
    local seasonNum = HolidayHappyData.getSeasonNum()
    if(seasonNum == 0)then
        local rewardData = HolidayHappyData.getDataOfFestival_act()
        seasonNum = #rewardData
    end
    -- if(tag > seasonNum)then
    --     --如果在第一季的时候点击了第二季的按钮，提示第二季活动还未开启
    --     require "script/ui/tip/AnimationTip"
    --     AnimationTip.showTip(GetLocalizeStringBy("fqq_101"))
    --     _seasonBtnAry[tag]:setEnabled(true)
    --     _seasonBtnAry[seasonNum]:setEnabled(false)
    --     return
    -- elseif(tag < seasonNum)then
    --     require "script/ui/tip/AnimationTip"
    --     AnimationTip.showTip(GetLocalizeStringBy("fqq_119"))
    -- end
    -- if(tag > seasonNum)then
    --     --如果在第一季的时候点击了第二季的按钮，提示第二季活动还未开启
    --     require "script/ui/tip/AnimationTip"
    --     AnimationTip.showTip(GetLocalizeStringBy("fqq_101"))
    --     _seasonBtnAry[tag]:setEnabled(true)
    --     _seasonBtnAry[seasonNum]:setEnabled(false)
    --     return
    if(tag < seasonNum)then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_119"))
    end
    _seasonNum = tag
    for i=1,#_seasonBtnAry do
        if(i == tag )then
            _seasonBtnAry[tag]:setEnabled(false)
            
        else
            _seasonBtnAry[i]:setEnabled(true)
        
        end
    end
    --获取数据
    local seasondata = {}
    local rewardData = HolidayHappyData.getDataOfFestival_act()
    seasonNum1 = #rewardData
    for i=1,seasonNum1 do
        local data = _dataOfFestival[i]
        table.insert(seasondata,data)
    end
    
    _seasonData = seasondata[tag]
    local dataInfo = string.split(_seasonData.mission_1,"|")
    local data0 = {}
    local data1 = {}
    local data2 = {}
    local data3 = {}
    local dataZheKou = {}
        for i=1,#dataInfo do
            local dbInfo = HolidayHappyData.getDataOfFestival_rewardByTaskId(tonumber(dataInfo[i]))
            local statues = HolidayHappyData.getStatusOfButton(dbInfo.bigtype,dbInfo.id,_seasonNum)
            local buttonStatuesLog = HolidayHappyData.buqianFunc(dbInfo.id,_seasonNum)
            if(tonumber(dbInfo.bigtype) == 2 )then
                table.insert(data0,dbInfo)
                 local function keySort ( data1, data2 )
                  return tonumber(data1.id) < tonumber(data2.id)
                end
                _data = {}
                table.sort(data0,keySort)
                for k,v in pairs(data0) do
                    table.insert(_data,v)
                end
            else
                if(statues == 1 or buttonStatuesLog ==1)then
                    --可领取
                     dbInfo.type = 3
                     table.insert(data1,dbInfo)
                elseif buttonStatuesLog == 3 then
                    --补签
                    dbInfo.type = 2
                    table.insert(data2,dbInfo)
                elseif statues == 0 then
                    --前往
                    dbInfo.type = 1
                    table.insert(data0,dbInfo)
                elseif statues == 2 or buttonStatuesLog ==2 then
                    --已领取
                    dbInfo.type = 0
                    table.insert(data3,dbInfo)
                end
                local function keySort ( data1, data2 )
                  return tonumber(data1.id) < tonumber(data2.id)
                end
                _data = {}
               
                table.sort(data0,keySort)
                table.sort(data1,keySort)
                table.sort(data2,keySort)
                table.sort(data3,keySort)

                for k,v in pairs(data1) do
                    table.insert(_data,v)
                end
                for k,v in pairs(data2) do
                    table.insert(_data,v)
                end
                for k,v in pairs(data0) do
                    table.insert(_data,v)
                end
                 for k,v in pairs(data3) do
                    table.insert(_data,v)
                end 
            end
        end          
          
    createFourLabelButton()
    createtableView()
end
--四个活动页签
function createFourLabelButton()
    _biaoqianNum = 1
    if( not tolua.isnull(_fourMenuBar) )then 
        _fourMenuBar:removeFromParentAndCleanup(true)
        _fourMenuBar = nil
    end
	_fourMenuBar = CCMenu:create()
    _fourMenuBar:setPosition(ccp(0,0))
    _fourMenuBar:setTouchPriority(-540)
    _tableViewBg:addChild(_fourMenuBar)
	local labelArray = {
            _seasonData.mission1_desc,
            _seasonData.mission2_desc,
            _seasonData.mission3_desc,
            _seasonData.mission4_desc
        }
        _btnAry = {}
    for i=1,4 do
            local btnLableBtn = createBtn(labelArray[i],i)
            btnLableBtn:setScale(g_fScaleX)
            btnLableBtn:setAnchorPoint(ccp(0,0))
            btnLableBtn:setPosition(ccp(20*i*g_fScaleX+(i-1)*btnLableBtn:getContentSize().width*g_fScaleX-(i-1)*40*g_fScaleX,_tableViewBg:getContentSize().height*0.99))
            _heightLable = btnLableBtn:getContentSize().height*g_fScaleX
            if i == 1 then
                btnLableBtn:setEnabled(false)
            else
                btnLableBtn:setEnabled(true)
            end
            _fourMenuBar:addChild(btnLableBtn,1,i)
            table.insert(_btnAry,btnLableBtn)
        end
        
end

--创建页签的背景
function createBtn( text ,pMissionId)
    local tapBtnN = CCScale9Sprite:create(_imagePath.tap_btn_n)
    tapBtnN:setPreferredSize(CCSizeMake(163,66))
    tapBtnN:setScale(0.87)
    local tapBtnH = CCScale9Sprite:create(_imagePath.tap_btn_h)
    tapBtnH:setPreferredSize(CCSizeMake(163,66))
    tapBtnH:setScale(0.87)
    local label1 = CCRenderLabel:create(text, g_sFontPangWa, 25, 2, ccc3(0x00, 0x00, 0x00 ), type_stroke)
    label1:setColor(ccc3(0x4b, 0x88, 0xbe))
    label1:setAnchorPoint(ccp(0.5,0.5))
    label1:setPosition(ccp(tapBtnN:getContentSize().width*0.5,tapBtnN:getContentSize().height*0.45))
    tapBtnH:addChild(label1) 

    local label2 = CCRenderLabel:create(text, g_sFontPangWa, 25, 1, ccc3(0x00, 0x00, 0x00 ), type_stroke)
    label2:setColor(ccc3(0xff, 0xf6, 0x00))
    label2:setAnchorPoint(ccp(0.5,0.5))
    label2:setPosition(ccp(tapBtnH:getContentSize().width*0.5,tapBtnH:getContentSize().height*0.5))
    tapBtnN:addChild(label2)
    local btn = CCMenuItemSprite:create(tapBtnN, nil,tapBtnH)
    btn:setScale(0.87)
    btn:setAnchorPoint(ccp(0.5,0.5))
    btn:registerScriptTapHandler(changeLabel)
    if(pMissionId ~= 4)then
        --如果是前3个按钮
        local missionTable = string.split(_seasonData["mission_"..pMissionId],"|")
        local isTip = HolidayHappyData.isRedTipOfLabel(missionTable)
        if(isTip)then
            --如果有可领取的物品
            local redTipSprite = redTipSprite()
             redTipSprite:setAnchorPoint(ccp(1,1))
             redTipSprite:setScale(0.9)
             redTipSprite:setPosition(ccp(btn:getContentSize().width*0.87*0.98,btn:getContentSize().height*0.87*0.98))
             btn:addChild(redTipSprite,100,300)
        end
    else
        local isNoEnter = HolidayHappyData.isRedTipOfLabelLast(_seasonData.id)
        if(isNoEnter)then
            local redTipSprite = redTipSprite()
            redTipSprite:setAnchorPoint(ccp(1,1))
            redTipSprite:setPosition(ccp(btn:getContentSize().width*0.98,btn:getContentSize().height*0.98))
            btn:addChild(redTipSprite,100,300)
        end
    end
    return btn
end

--标签页来回切换的回调方法
function changeLabel( pValue)
    _biaoqianNum = pValue
    for i=1,#_btnAry do
        if(i == pValue )then
            _btnAry[pValue]:setEnabled(false)
        else
            _btnAry[i]:setEnabled(true)
        end
    end
    if(_kLableFour == pValue)then
        --如果切到第四个限时折扣
         local seasonNum = HolidayHappyData.getSeasonNum()
        if(seasonNum == 0)then
            local rewardData = HolidayHappyData.getDataOfFestival_act()
            seasonNum = #rewardData
        end
        HolidayHappyDef.setHolidayHappyEnter(seasonNum) --传一个代表季度的参数
        --把红点移除掉
        local item = tolua.cast(_btnAry[pValue],"CCMenuItemSprite")
        local tipSprite = tolua.cast(item:getChildByTag(300),"CCSprite")
        if(tipSprite)then
            tipSprite:removeFromParentAndCleanup(true)
        end
    end 
    _data = {} 
    local data0 = {}
    local data1 = {}
    local data2 = {}
    local data3 = {}
    local dataZheKou = {}
    local dataInfo = string.split(_seasonData["mission_"..pValue],"|")
        for i=1,#dataInfo do
            local dbInfo = HolidayHappyData.getDataOfFestival_rewardByTaskId(tonumber(dataInfo[i]))
            local statues = HolidayHappyData.getStatusOfButton(dbInfo.bigtype,dbInfo.id,_seasonNum)
            local buttonStatuesLog = HolidayHappyData.buqianFunc(dbInfo.id,_seasonNum)
            if(tonumber(dbInfo.bigtype) == 2 )then
                table.insert(data0,dbInfo)
                 local function keySort ( data1, data2 )
                  return tonumber(data1.id) < tonumber(data2.id)
                end
                _data = {}
                table.sort(data0,keySort)
                for k,v in pairs(data0) do
                    table.insert(_data,v)
                end
            else
                if(statues == 1 or buttonStatuesLog ==1)then
                    --可领取
                     dbInfo.type = 3
                     table.insert(data1,dbInfo)
                elseif buttonStatuesLog == 3 then
                    --补签
                    dbInfo.type = 2
                    table.insert(data2,dbInfo)
                elseif statues == 0 then
                    --前往
                    dbInfo.type = 1
                    table.insert(data0,dbInfo)
                elseif statues == 2 or buttonStatuesLog ==2 then
                    --已领取
                    dbInfo.type = 0
                    table.insert(data3,dbInfo)
                end
            end 

                local function keySort ( data1, data2 )
                    return tonumber(data1.id) < tonumber(data2.id)
                end
                _data = {}
               
                table.sort(data0,keySort)
                table.sort(data1,keySort)
                table.sort(data2,keySort)
                table.sort(data3,keySort)

                    for k,v in pairs(data1) do
                        table.insert(_data,v)
                    end
                    for k,v in pairs(data2) do
                        table.insert(_data,v)
                    end
                    for k,v in pairs(data0) do
                        table.insert(_data,v)
                    end
                     for k,v in pairs(data3) do
                        table.insert(_data,v)
                    end
         end
        refreshTableview()
end

--切换签前3个页签时的刷新方法
function refreshTableview( ... )
    _tableView:reloadData()
end

--创建tableview
function createtableView(isRun)
         local data = _data
        if(tolua.isnull(_bgLayer))then  
            return
        end
        local isrun = isRun or false
        if(isrun)then
            local data0 = {}
            local data1 = {}
            local data2 = {}
            local data3 = {}
           
            for i=1,#_data do
                local dbInfo = data[i]
                local statues = HolidayHappyData.getStatusOfButton(dbInfo.bigtype,dbInfo.id,_seasonNum)
                local buttonStatuesLog = HolidayHappyData.buqianFunc(dbInfo.id,_seasonNum)
                    if(statues == 1 or buttonStatuesLog ==1)then
                        --可领取
                         dbInfo.type = 3
                         table.insert(data1,dbInfo)
                    elseif buttonStatuesLog == 3 then
                        --补签
                        dbInfo.type = 2
                        table.insert(data2,dbInfo)
                    elseif statues == 0 then
                        --前往
                        dbInfo.type = 1
                        table.insert(data0,dbInfo)
                    elseif statues == 2 or buttonStatuesLog ==2 then
                        --已领取
                        dbInfo.type = 0
                        table.insert(data3,dbInfo)
                    end
                    
                    local function keySort ( data1, data2 )
                        return tonumber(data1.id) < tonumber(data2.id)
                    end
                    _data = {}
                   
                    table.sort(data0,keySort)
                    table.sort(data1,keySort)
                    table.sort(data2,keySort)
                    table.sort(data3,keySort)

                        for k,v in pairs(data1) do
                            table.insert(_data,v)
                        end
                        for k,v in pairs(data2) do
                            table.insert(_data,v)
                        end
                        for k,v in pairs(data0) do
                            table.insert(_data,v)
                        end
                        for k,v in pairs(data3) do
                            table.insert(_data,v)
                        end
                end
                 local dataZheKou = {}
                for i=1,#_data do
                    local dbInfo = _data[i]
                    if(tonumber(dbInfo.bigtype) == 2 )then
                        table.insert(dataZheKou,dbInfo)
                         local function keySort ( data1, data2 )
                          return tonumber(data1.id) < tonumber(data2.id)
                        end
                        _data = {}
                        table.sort(dataZheKou,keySort)
                        for k,v in pairs(dataZheKou) do
                            table.insert(_data,v)
                        end
                    end
                end
        end
   

    if(_tableView)then
        _tableView:removeFromParentAndCleanup(true)
        _tableView = nil
    end
    local h = LuaEventHandler:create(function ( fn,p_table,a1,a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(620*g_fScaleX,190*g_fScaleX)
        elseif fn == "cellAtIndex" then
            a2 = HolidayHappyCell.createCell(_data[a1 + 1], a1 + 1,_priority - 30,_day)
            r = a2
        elseif fn == "numberOfCells" then
            r = table.count(_data)
        elseif fn == "cellTouched" then          
        end
        return r
    end)
    _tableView = LuaTableView:createWithHandler(h,CCSizeMake(620*g_fScaleX, _tableViewBg:getContentSize().height - 40))
    _tableViewBg:addChild(_tableView)
    _tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _tableView:setAnchorPoint(ccp(0.5,0.5))
    _tableView:setPosition(ccp(_tableViewBg:getContentSize().width*0.5,_tableViewBg:getContentSize().height*0.5))
    _tableView:ignoreAnchorPointForPosition(false)
    _tableView:setTouchPriority(_priority - 2)
end

--前3个页签的红点刷新
function refreshRedTipOfLable( pMissionId )
	local missionTable = string.split(_seasonData["mission_"..pMissionId],"|")
        local isTip = HolidayHappyData.isRedTipOfLabel(missionTable)
        if not (isTip)then
             local item = _btnAry[pMissionId]
            local redSptite = item:getChildByTag(300)
            if(redSptite)then
            redSptite:removeFromParentAndCleanup(true)
            end
        end
end

--红点
function redTipSprite( ... )
    local tipSprite= CCSprite:create("images/common/tip_2.png")
     return tipSprite       
end

--限时兑换的回调
function limitExchargeButtonCallBack( ... )
    HolidayHappyLimitExchargeLayer.showLayer()
end
--限时兑换红点刷新
function refreshRedTipOfExcharge( ... )   
        if(_redTipSprite)then
            _redTipSprite:removeFromParentAndCleanup(true)
        end 
end
--返回按钮的回调
function closeCallBack( ... )
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    require "script/ui/main/MainBaseLayer"
    local main_base_layer = MainBaseLayer.create()
    MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
    MainScene.setMainSceneViewsVisible(true,true,true)
end
function getbiaoqianNum( ... )
   return _biaoqianNum
end

function getSeasonNumOfClick( ... )
   return _seasonNum
end

--0点刷新
function rfreshZero( ... )
    --判断活动是否开启
    if( not HolidayHappyData.isOpen())then
        return
    else
        --判断是否在当前页面
        if( _bgLayer == nil)then
            return
        else
            --刷新页面(主要针对累计登陆的天数问题)
            local callback = function ( ... )
                changeLabel(_biaoqianNum)
            end
            HolidayHappyController.getInfo(callback)
        end
    end
end