-- FileName: PlayerBackLayer.lua 
-- Author: fuqiongqiong
-- Date: 2016-8-19
-- Purpose: 老玩家回归活动Layer

module("PlayerBackLayer",package.seeall)
require "script/ui/playerBack/PlayerBackData"
require "script/ui/playerBack/PlayerBackController"
require "script/ui/playerBack/PlayerBackCell"

local _bgLayer
local _labeldata
local _data 
local _dataInfo
local _tableView
local _biaoqianNum
local _buyView
local _countdownTime
local _timeCounter 
local _height
local _buyView 
local _desk

function init( ... )
	_bgLayer = nil
    _labeldata = nil
    _data      = {}
    _dataInfo  = {}
    _tableView = nil
    _biaoqianNum = 1
    _buyView   = nil
    _countdownTime = nil
    _timeCounter = nil
    _height = nil
    _buyView = nil
    _desk = nil
   _imagePath      = {
        tap_btn_n   = "images/common/btn_title_n.png",
        tap_btn_h   = "images/common/btn_title_h.png"
    }
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
        _bgLayer = nil
    end
end

--玩家回归活动入口
function show()
    local isShow = PlayerBackData.isOpen()
    local isOver = PlayerBackData.isPlayerBackOver()
    if(isShow == false or isOver == true) then
        AnimationTip.showTip(GetLocalizeStringBy("lcyx_3002"))
        return
    end
    local bagLayer = createLayer()
    MainScene.changeLayer(bagLayer, "bagLayer")
end


function createLayer( ... )
	init()
	MainScene.setMainSceneViewsVisible(false,false,false)
    _priority =  -400
    _zOrder   =  10
    _bgLayer  = CCLayer:create()
    _bgLayer:registerScriptHandler(onNodeEvent)
    --背景
    local bg = CCSprite:create("images/playerBack/bigbg.png")
    bg:setScale(g_fBgScaleRatio)
    _bgLayer:addChild(bg)
    --创建上半部分人物背景
    local spriteBg = CCSprite:create("images/playerBack/spritebg.png") 
    _bgLayer:addChild(spriteBg)
    spriteBg:setAnchorPoint(ccp(0,1))
    spriteBg:setScale(g_fScaleX)
    spriteBg:setPosition(ccp(0,g_winSize.height-20*g_fScaleX))
    local callBack = function ( ... )
       createTopUI()
    end
    PlayerBackController.getInfo(callBack)
    
    return _bgLayer
end

--创建上半部分人物背景
function  createTopUI( ... )
    local titleBg = CCSprite:create("images/playerBack/title.png")
    titleBg:setScale(g_fScaleX*1.2)
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height-30*g_fScaleX))
    _bgLayer:addChild(titleBg)
    
    --倒计时背景
    local countDownBg = CCSprite:create("images/playerBack/timelable.png")
    countDownBg:setAnchorPoint(ccp(0.5,1))
    countDownBg:setScale(g_fScaleX)
    countDownBg:setPosition(ccp(g_winSize.width*0.55,g_winSize.height - 50*g_fScaleX - titleBg:getContentSize().height*g_fScaleX*1.2))
    _bgLayer:addChild(countDownBg)

    local labelStr = CCRenderLabel:create(GetLocalizeStringBy("fqq_137"), g_sFontPangWa, 26, 1, ccc3(0x00, 0x00, 0x00 ), type_stroke)
    labelStr:setColor(ccc3(0xff, 0xf6, 0x00))
    labelStr:setAnchorPoint(ccp(0.5,0.5))
    labelStr:setPosition(ccp(countDownBg:getContentSize().width*0.35,countDownBg:getContentSize().height*0.75))
    countDownBg:addChild(labelStr)
    local labelStr1 = CCRenderLabel:create(GetLocalizeStringBy("fqq_138"), g_sFontPangWa, 26, 1, ccc3(0x00, 0x00, 0x00 ), type_stroke)
    labelStr1:setColor(ccc3(0xff, 0xf6, 0x00))
    labelStr1:setAnchorPoint(ccp(0.5,0.5))
    labelStr1:setPosition(ccp(countDownBg:getContentSize().width*0.35,countDownBg:getContentSize().height*0.7 - labelStr:getContentSize().height))
    countDownBg:addChild(labelStr1)

    local pictureLable = CCSprite:create("images/playerBack/gift.png")
    pictureLable:setAnchorPoint(ccp(0,0.5))
    pictureLable:setPosition(ccp(labelStr1:getContentSize().width,labelStr1:getContentSize().height*0.5))
    labelStr1:addChild(pictureLable)
     --活动时间倒计时Lable
    local strLable = CCRenderLabel:create(GetLocalizeStringBy("fqq_136"),g_sFontName,22,1,ccc3(0x00,0x00,0x00),type_stroke)
    strLable:setColor(ccc3(0x00,0xff,0x18))
    strLable:setAnchorPoint(ccp(0.5,0.5))
    strLable:setPosition(ccp(countDownBg:getContentSize().width*0.35,countDownBg:getContentSize().height*0.25))
    countDownBg:addChild(strLable)
     _height = g_winSize.height - 60*g_fScaleX - titleBg:getContentSize().height*g_fScaleX*1.2 - countDownBg:getContentSize().height*g_fScaleX
     --倒计时
     local time = PlayerBackData.countDownTime()
    _countdownTime =CCRenderLabel:create(time,g_sFontName,22,1,ccc3(0x00,0x00,0x00),type_stroke)
    _countdownTime:setColor(ccc3(0x00,0xff,0x18))
    _countdownTime:setAnchorPoint(ccp(0,0.5))
    _countdownTime:setPosition(ccp(strLable:getContentSize().width,strLable:getContentSize().height*0.5))
    strLable:addChild(_countdownTime)
    startSchedule()
    -- 按钮
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_priority - 10)
    _bgLayer:addChild(menuBar,10)
    --关闭按钮
    local returnButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    returnButton:setScale(g_fScaleX)
    returnButton:setAnchorPoint(ccp(1,1))
    returnButton:setPosition(ccp(g_winSize.width-20,g_winSize.height-20))
    returnButton:registerScriptTapHandler(closeCallBack)
    menuBar:addChild(returnButton)

    _dowmBg = CCSprite:create()
    _dowmBg:setContentSize(CCSizeMake(g_winSize.width,_height- 65*g_fScaleX))
    _dowmBg:setAnchorPoint(ccp(0.5,1))
    _dowmBg:setPosition(ccp(g_winSize.width*0.5,_height- 62*g_fScaleX))
    _bgLayer:addChild(_dowmBg)
    
    --创建tableview背景
    _tableViewBg = CCScale9Sprite:create("images/playerBack/bg_ng_attr.png")
    _dowmBg:addChild(_tableViewBg)
    _tableViewBg:setPreferredSize(CCSizeMake(630*g_fScaleX, _dowmBg:getContentSize().height))
    _tableViewBg:setAnchorPoint(ccp(0.5, 1))
    _tableViewBg:setPosition(ccp(g_winSize.width*0.5, _dowmBg:getContentSize().height)) 
   
    --创建4个页签
    createFourLable()
end

--更新倒计时
function updateTime( ... )
    --获取时间
    local time = PlayerBackData.countDownTime()
    _countdownTime:setString(time)
    local timestr =  tonumber(PlayerBackData.countDownTimestr()) - tonumber(TimeUtil.getSvrTimeByOffset())
    --判断如果等于0，就关掉时间调度器
    if(timestr == 0)then
        stopSchedule()
    end   
end

--创建4个页签
function createFourLable( ... )
	_labeldata = PlayerBackData.getAllInfo()
    local fourItemMenuBar = CCMenu:create()
    fourItemMenuBar:setPosition(ccp(0,0))
    fourItemMenuBar:setTouchPriority(_priority - 10)
    _bgLayer:addChild(fourItemMenuBar)

    local labelArray = {
        _labeldata.task1_desc,
        _labeldata.task2_desc,
        _labeldata.task3_desc,
        _labeldata.task4_desc
    }

    _btnAry = {}
    for i=1,4 do
        local btnLableBtn = createTextOfFourLable(labelArray[i],i)
        btnLableBtn:setScale(g_fScaleX)
        btnLableBtn:setAnchorPoint(ccp(0,1))
        btnLableBtn:setPosition(ccp(18*i*g_fScaleX+(i-1)*btnLableBtn:getContentSize().width*g_fScaleX-(i-1)*40*g_fScaleX,_height))
        _heightLable = btnLableBtn:getContentSize().height*g_fScaleX 
        if i == 1 then
            btnLableBtn:setEnabled(false)
        else
            btnLableBtn:setEnabled(true)
        end
        fourItemMenuBar:addChild(btnLableBtn,1,i)
        table.insert(_btnAry,btnLableBtn)
    end
    

    local data2 = {}
    local data1 = {}
    local data0 = {} 
    local dataExit = PlayerBackData.getActivityInfo()
    -- _dataInfo = string.split(dataExit.task_1,"|")
    for k,v in pairs(dataExit.gift) do
        table.insert(_dataInfo,tonumber(k))
    end
    for i=1,#_dataInfo do
        local dbInfo = PlayerBackData.getRewardInfo(_dataInfo[i])
        local status = PlayerBackData.getButtonStatues(tonumber(dbInfo.id))
        if(tonumber(status) == 1)then
            table.insert(data2,dbInfo)
        elseif tonumber(status) == 0 then
            table.insert(data1,dbInfo)
        else
            table.insert(data0,dbInfo)
        end
    end
   
        local function keySort ( _data1, _data2 )
            return tonumber(_data1.id) < tonumber(_data2.id)
        end
        table.sort(data1,keySort)
        for k,v in pairs(data2) do
            table.insert(_data,v)
        end
        for k,v in pairs(data1) do
            table.insert(_data,v)
        end
        for k,v in pairs(data0) do
            table.insert(_data,v)
        end

    --创建第一个界面(回归礼包，默认的一个界面)
    createUIOfGiftBack()
end

--创建4个标签的文字内容
function createTextOfFourLable( text ,pIndex)
	local tapBtnN = CCScale9Sprite:create(_imagePath.tap_btn_n)
    tapBtnN:setPreferredSize(CCSizeMake(172,66))
    tapBtnN:setScale(0.87)
    local tapBtnH = CCScale9Sprite:create(_imagePath.tap_btn_h)
    tapBtnH:setPreferredSize(CCSizeMake(172,66))
    tapBtnH:setScale(0.87)
    local label1 = CCRenderLabel:create(text, g_sFontPangWa, 27, 2, ccc3(0x00, 0x00, 0x00 ), type_stroke)
    label1:setColor(ccc3(0x4b, 0x88, 0xbe))
    label1:setAnchorPoint(ccp(0.5,0.5))
    label1:setPosition(ccp(tapBtnN:getContentSize().width*0.5,tapBtnN:getContentSize().height*0.5))
    tapBtnH:addChild(label1) 

    local label2 = CCRenderLabel:create(text, g_sFontPangWa, 29, 1, ccc3(0x00, 0x00, 0x00 ), type_stroke)
    label2:setColor(ccc3(0xff, 0xf6, 0x00))
    label2:setAnchorPoint(ccp(0.5,0.5))
    label2:setPosition(ccp(tapBtnH:getContentSize().width*0.5,tapBtnH:getContentSize().height*0.5))
    tapBtnN:addChild(label2)
    local btn = CCMenuItemSprite:create(tapBtnN, nil,tapBtnH)
    btn:setScale(0.87)
    btn:setAnchorPoint(ccp(0.5,0.5))
    btn:registerScriptTapHandler(changeLabel)

     if(pIndex ~= 4)then
        --如果是前3个按钮
        local dataExit = PlayerBackData.getActivityInfo()
        -- local missionTable = string.split(_labeldata["task_"..pIndex],"|")
        local dataInfo = dataExit.gift
        if(pIndex == 2)then
            dataInfo = dataExit.task
            -- print("dataInfo~~~~")
            -- print_t(dataInfo)
        elseif pIndex == 3 then
             dataInfo = dataExit.recharge
        end
        local missionTable = {}
      
        for k,v in pairs(dataInfo) do
            table.insert(missionTable,tonumber(k))
        end
        local isTip = PlayerBackData.isRedTipOfForeThree(missionTable)
        if(isTip)then
            --如果有可领取的物品
            local redTipSprite = redTipSprite()
             redTipSprite:setAnchorPoint(ccp(1,1))
             redTipSprite:setPosition(ccp(btn:getContentSize().width*0.93,btn:getContentSize().height*0.98))
             btn:addChild(redTipSprite,1,300)
        end
    else
        local isNoEnter = PlayerBackData.isRedTipOfLimitBuy()
        if(isNoEnter)then
            _redTipSprite = redTipSprite()
            _redTipSprite:setAnchorPoint(ccp(1,1))
            _redTipSprite:setPosition(ccp(btn:getContentSize().width*0.93,btn:getContentSize().height*0.98))
            btn:addChild(_redTipSprite,1,300)
        end
    end
    return btn
end



--标签页来回切换的回调方法
function changeLabel( pValue)
  
    for i=1,#_btnAry do
        if(i == pValue )then
            _btnAry[pValue]:setEnabled(false)
        else
            _btnAry[i]:setEnabled(true)
        end
    end

    local data2 = {}
    local data1 = {}
    local data0 = {} 
    _data = {}
    local dataExit = PlayerBackData.getActivityInfo()
    local dataInfoa = dataExit.gift
    if(pValue == 2)then
        dataInfoa = dataExit.task
    elseif pValue == 3 then
         dataInfoa = dataExit.recharge
    elseif pValue == 4 then
        dataInfoa = dataExit.shop
    end
    -- local str = "task_"..pValue
    local dataInfo = {}
    for k,v in pairs(dataInfoa) do
       table.insert(dataInfo,tonumber(k))
    end
    -- print("dataInfo存储的数据")
    -- print_t(dataInfo)
        for i=1,#dataInfo do
            local dbInfo = PlayerBackData.getRewardInfo(tonumber(dataInfo[i]))
            local status = PlayerBackData.getButtonStatues(tonumber(dbInfo.id))
            if(tonumber(status) == 1)then
                local data = _data[i]
                table.insert(data2,dbInfo)
            elseif tonumber(status) == 0 then
                table.insert(data1,dbInfo)
            else
                table.insert(data0,dbInfo)
            end
        end
   
        local function keySort ( _data1, _data2 )
            return tonumber(_data1.id) < tonumber(_data2.id)
        end
        table.sort(data1,keySort)
        for k,v in pairs(data2) do
            table.insert(_data,v)
        end
        for k,v in pairs(data1) do
            table.insert(_data,v)
        end
        for k,v in pairs(data0) do
            table.insert(_data,v)
        end


    if(PlayerBackDef.kTypeOfTaskFour == pValue)then
        --如果切到第四个限时折扣
            local isNoEnter = PlayerBackData.isRedTipOfLimitBuy()
            if(isNoEnter)then
                --如果红点已经消失了，就不用再调这个方法
                 refreshRedTipOfExcharge()
            end
            PlayerBackDef.setPlayerBackEnter(1)
    end

    if(_biaoqianNum == PlayerBackDef.kTypeOfTaskOne)then
        --如果标签记录的是在第一个界面 
       if(_buyView )then
            _buyView:removeFromParentAndCleanup(true)
            _buyView = nil
        end
        if(_desk)then
            _desk:removeFromParentAndCleanup(true)
            _desk = nil
        end
        createTableView()
    else
        if PlayerBackDef.kTypeOfTaskOne == pValue then
            --当前界面不是第一个，点击第一个时
            if(_tableView)then
                _tableView:removeFromParentAndCleanup(true)
                _tableView = nil
            end
                createUIOfGiftBack() 
        else
            rfreshTableView()
        end      
    end
      _biaoqianNum = pValue
end

--刷新tableView（刷新回归任务2，单笔充值3，限时折扣4）
function rfreshTableView( ... )
	_tableView:reloadData()
end

--创建tableview
function createTableView( isRfresh )
    if(_bgLayer == nil)then
    print("_bgLayer为空")  
        return
    end
    if(_tableView)then
        _tableView:removeFromParentAndCleanup(true)
        _tableView = nil
    end
    local isRfresh = isRfresh or false

    if(isRfresh)then
            local data2 = {}
            local data1 = {}
            local data0 = {} 
            for i=1,#_data do
               local status =  PlayerBackData.getButtonStatues(tonumber(_data[i].id))
                    if(status == 1)then
                        table.insert(data2,_data[i])
                    elseif status == 0 then
                        table.insert(data1,_data[i])
                    else
                        table.insert(data0,_data[i])
                    end
            end
             local function keySort ( _data1, _data2 )
                return tonumber(_data1.id) < tonumber(_data2.id)
            end
            _data = {}
                table.sort(data1,keySort)
                for k,v in pairs(data2) do
                    table.insert(_data,v)
                end
                for k,v in pairs(data1) do
                    table.insert(_data,v)
                end
                for k,v in pairs(data0) do
                    table.insert(_data,v)
                end
        end

	local h = LuaEventHandler:create(function ( fn,p_table,a1,a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(600*g_fScaleX,182*g_fScaleX)
        elseif fn == "cellAtIndex" then
            a2 = PlayerBackCell.createCell(_data[a1 + 1], a1 + 1,_priority - 30)
            r = a2
        elseif fn == "numberOfCells" then
            r = table.count(_data)
        elseif fn == "cellTouched" then
                   
        end
        return r
    end)
    _tableView = LuaTableView:createWithHandler(h,CCSizeMake(600*g_fScaleX, _tableViewBg:getContentSize().height*0.95))
    _tableViewBg:addChild(_tableView)
    _tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _tableView:setAnchorPoint(ccp(0.5,0.5))
    _tableView:setPosition(ccp(_tableViewBg:getContentSize().width*0.5,_tableViewBg:getContentSize().height*0.5))
    _tableView:ignoreAnchorPointForPosition(false)
    _tableView:setTouchPriority(_priority - 2)
end

--创建礼包回归1
function createUIOfGiftBack( ... )
    if(_buyView)then
        _buyView:removeFromParentAndCleanup(true)
        _buyView = nil
    end
    if( _desk)then
        _desk:removeFromParentAndCleanup(true)
        _desk = nil
    end
    --背景
    _buyView = CCSprite:create("images/newserve/buybg.png")
    local xishu = _tableViewBg:getContentSize().height/515
    _buyView:setScaleY(xishu)
    _buyView:setAnchorPoint(ccp(0.5,1))
    _buyView:setScaleX(g_fScaleX)
    _buyView:setPosition(ccp(_tableViewBg:getContentSize().width*0.5,_tableViewBg:getContentSize().height))
    _tableViewBg:addChild(_buyView)

    --桌子
    _desk = CCSprite:create("images/newserve/zhuozi.png")
    _desk:setAnchorPoint(ccp(0.5,0.5))
    _desk:setScale(g_fScaleX)
    _desk:setPosition(ccp(_tableViewBg:getContentSize().width*0.5,_tableViewBg:getContentSize().height*0.4))
    _tableViewBg:addChild(_desk)
    
   local rewrardInfo = string.split(_data[1].reward,",")
   for i=1,#rewrardInfo do
        local rewardInDb = ItemUtil.getItemsDataByStr(rewrardInfo[i])
        local icon,itemName,itemColor = ItemUtil.createGoodsIcon(rewardInDb[1], -450, 3000, -480,nil,nil,nil,false,false)
        -- if(rewardInDb[1].type == "exp_num")then
        --     --获取离线天数
        --     icon,itemName,itemColor = ItemUtil.createGoodsIcon(rewardInDb[1], -450, 3000, -480,nil,nil,nil,false,false)
        -- end
        icon:setAnchorPoint(ccp(0,0.5))
        icon:setPosition(ccp(135*i+(i-1)*icon:getContentSize().width-(i-1)*20 - (i-1)*60,_desk:getContentSize().height*1.14))
        _desk:addChild(icon,2)
        


        --阴影圈
        local shadow = CCSprite:create("images/newserve/touying.png")
        shadow:setAnchorPoint(ccp(0.5,1))
        shadow:setPosition(ccp(icon:getContentSize().width*0.5,10))
        icon:addChild(shadow)
        
        local statue = PlayerBackData.getButtonStatues(tonumber(_data[1].id))
        if(statue == PlayerBackDef.kTaskStausCanGet)then
            --未领取时
            if(rewardInDb[1].type == "exp_num" or rewardInDb[1].type == "silver")then
                --第二种奖励时
                 local day = PlayerBackData.getDayOfLeaf()
                 local num = tonumber(rewardInDb[1].num)*day
                 print("local num = tonumber(rewardInDb[1].num)*day",num)
                 local numLable = num
                 if(tonumber(num/10000) >0 and tonumber(num/10000) <100)then
                    --显示万
                    if(num%10000 == 0)then
                        numLable = (num/10000)..GetLocalizeStringBy("key_2593")
                    else
                        numLable = num
                    end  
                elseif tonumber(num/1000000) >0 and tonumber(num/1000000) <100 then 
                    --显示百万
                    if(num%1000000 == 0)then
                        numLable = (num/1000000)..GetLocalizeStringBy("fqq_143")
                    else
                        numLable = num
                    end
                end

                if(rewardInDb[1].type == "exp_num")then
                    --显示离线天数
                    local day = PlayerBackData.getDayOfLeaf() 
                    local richInfo = {
                        lineAlignment = 2,
                        labelDefaultColor = ccc3(0x00,0xff,0x18),
                        labelDefaultFont = g_sFontName,
                        labelDefaultSize = 19,
                        defaultType = "CCRenderLabel",
                        elements = {
                           
                            {
                                text = day,
                            }
                        }
                    }
                    local dayLabel = GetLocalizeLabelSpriteBy_2("fqq_142", richInfo)
                    icon:addChild(dayLabel)
                    dayLabel:setAnchorPoint(ccp(0.5,0))
                    dayLabel:setPosition(ccp(icon:getContentSize().width*0.5,3))
                end
                local nameLabel = CCRenderLabel:create(numLable..itemName, g_sFontName,20,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
                icon:addChild(nameLabel)
                nameLabel:setAnchorPoint(ccp(0.5,1))
                nameLabel:setColor(itemColor)
                nameLabel:setPosition(ccp(icon:getContentSize().width*0.5, -shadow:getContentSize().height*0.55)) 
            else
                --第一种正常显示
                local day = PlayerBackData.getDayOfLeaf()
                local dayLabel =  CCRenderLabel:create(day, g_sFontName,20,1,ccc3(0x00,0x00,0x00),type_stroke)
                dayLabel:setColor(ccc3(0x00,0xff,0x18))
                icon:addChild(dayLabel)
                dayLabel:setAnchorPoint(ccp(1,0))
                dayLabel:setPosition(ccp(icon:getContentSize().width-5,3))
                local nameLabel = CCRenderLabel:create(itemName, g_sFontName,20,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
                icon:addChild(nameLabel)
                nameLabel:setAnchorPoint(ccp(0.5,1))
                nameLabel:setColor(itemColor)
                nameLabel:setPosition(ccp(icon:getContentSize().width*0.5, -shadow:getContentSize().height*0.55))   
            end
        else
            --已领取时
            if(rewardInDb[1].type == "exp_num" or rewardInDb[1].type == "silver")then
                --第二种奖励正常显示
                local nameLabel = CCRenderLabel:create(itemName, g_sFontName,20,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
                icon:addChild(nameLabel)
                nameLabel:setAnchorPoint(ccp(0.5,1))
                nameLabel:setColor(itemColor)
                nameLabel:setPosition(ccp(icon:getContentSize().width*0.5, -shadow:getContentSize().height*0.55)) 
            else
                --第一个显示(银币)item
                local nameLabel = CCRenderLabel:create(itemName, g_sFontName,20,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
                icon:addChild(nameLabel)
                nameLabel:setAnchorPoint(ccp(0.5,1))
                nameLabel:setColor(itemColor)
                nameLabel:setPosition(ccp(icon:getContentSize().width*0.5, -shadow:getContentSize().height*0.55)) 
            end
       
        end 
           
   end  

    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_priority-10)
    _desk:addChild(menu)
    local statue = PlayerBackData.getButtonStatues(tonumber(_data[1].id))
    if(statue == PlayerBackDef.kTaskStausCanGet)then
        --领取按钮
        _btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(119, 64),GetLocalizeStringBy("fqq_062"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
        _btn:setAnchorPoint(ccp(0.5,1))
        _btn:setPosition(ccp(_desk:getContentSize().width*0.5, _desk:getContentSize().height*0.4))
        _btn:registerScriptTapHandler(receiveCallBack)
        menu:addChild(_btn,1,_data[1].id)
    else
         --已领取
        local receive_alreadySp = CCSprite:create("images/sign/receive_already.png")
        receive_alreadySp:setPosition(ccp(_desk:getContentSize().width*0.5, _desk:getContentSize().height*0.4))
        receive_alreadySp:setAnchorPoint(ccp(0.5,1))
        _desk:addChild(receive_alreadySp) 
    end	

end

--返回回调
function closeCallBack( ... )
     AudioUtil.playEffect("audio/effect/guanbi.mp3")
    require "script/ui/main/MainBaseLayer"
    local main_base_layer = MainBaseLayer.create()
    MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
    MainScene.setMainSceneViewsVisible(true,true,true)
end

--领取奖励回调
function receiveCallBack( tag )
    if( PlayerBackData.isPlayerBackOver())then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_114"))
        return
    end
     --判断背包
    require "script/ui/item/ItemUtil"
    if(ItemUtil.isBagFull() == true )then
        return
    end
    local pRewardData = PlayerBackData.getRewardInfo(tag)
    --是否需要多选一
    local isChoose = pRewardData.choice_award --0 为不需要  1需要
    if(isChoose == 0)then
         PlayerBackController.gainReward(tonumber(pRewardData.id),0,nil)
     else
        local strReward = pRewardData.reward
        UseGiftLayer.showTipLayer(nil,strReward,function( rewardId )
        PlayerBackController.gainReward(tonumber(pRewardData.id),rewardId,nil)
    end)
    end
end


--红点
function redTipSprite( ... )
    local tipSprite= CCSprite:create("images/common/tip_2.png")
     return tipSprite       
end

--前3个页签的红点刷新
function refreshRedTipOfLable( pMissionId )
    local missionTable = string.split(_labeldata["task_"..pMissionId],"|")
        local isTip = PlayerBackData.isRedTipOfForeThree(missionTable)
        if not (isTip)then
             local item = _btnAry[pMissionId]
            local redSptite = item:getChildByTag(300)
            if(redSptite)then
            redSptite:removeFromParentAndCleanup(true)
            end
        end
end

--限时折扣红点刷新
function refreshRedTipOfExcharge( ... )   
        if(_redTipSprite)then
            _redTipSprite:removeFromParentAndCleanup(true)
        end 
end


--获取现在页面处于第几个页签
function getbiaoqianNum( ... )
   return _biaoqianNum
end