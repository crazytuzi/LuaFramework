-- FileName: NewServeActivityLayer.lua 
-- Author: fuqiongqiong
-- Date: 2016-5-4
-- Purpose: 新服活动主界面


module("NewServerActivityLayer",package.seeall)
require "script/ui/newServerActivity/NewServerActivityCell"
require "script/ui/newServerActivity/NewServerActivityData"
require "script/ui/newServerActivity/NewServerDef"
require "script/model/user/UserModel"
local _buyView
local _tableView
local _btnAry
local _dataInfo
local _bgLayer
local _data
local _labeldata
local _dowmBg
local _heightLable
local _tableViewBg
local _priority
local _zOrder
local _btn
local _day
local _time
local _countdownTime
local _kLableFour = 4
local _dayBtnAry
local _desk
local tagItem = 200
local _biaoqianNum 
local _strLable
local fourItemMenuBar
function init( ... )
    fourItemMenuBar        = nil
	_buyView 	   = nil 
	_tableView 	   = nil
	 _data         = {}
	 _labeldata	   = nil
     _biaoqianNum  = 1
     _bgLayer      = nil
     _dowmBg       = nil
     _day          = 1
     _heightLable  = nil
     _tableViewBg  = nil
     _priority     = nil
     _zOrder       = nil
     _btn          = nil
     _countdownTime = nil
     _time          = nil
     _desk          = nil
     _strLable      = nil
	_dataInfo	    = {}
	_btnAry 	    = {}
    _dayBtnAry      = {}
	_imagePath      = {
        tap_btn_n   = "images/common/btn/tab_button/btn1_n.png",
        tap_btn_h   = "images/common/btn/tab_button/btn1_h.png"
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
        print("moved")
    elseif(eventType == "end")then
        print("end")
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

--新服活动入口
function show()
    require "script/ui/newServerActivity/NewServerActivityData"
    local isShow = NewServerActivityData.isOpen()
    if(isShow == false) then
        AnimationTip.showTip(GetLocalizeStringBy("lcyx_3002"))
        return
    end
    require "script/ui/newServerActivity/NewServerActivityLayer"
    local bagLayer = NewServerActivityLayer.createLayer()
    MainScene.changeLayer(bagLayer, "bagLayer")
end

function createLayer( ... )
    init()
    MainScene.setMainSceneViewsVisible(false,false,false)
    _priority =  -400
    _zOrder =  10
    _bgLayer = CCLayer:create()
    _bgLayer:registerScriptHandler(onNodeEvent)
    --背景
    local bg = CCSprite:create("images/newserve/bigbg.png")
    bg:setScale(g_fBgScaleRatio)
    _bgLayer:addChild(bg)
    --创建上半部分人物背景
    local spriteBg = CCSprite:create("images/newserve/spritebg.png") --[[640,382]]
    _bgLayer:addChild(spriteBg)
    spriteBg:setAnchorPoint(ccp(0.5,1))
    spriteBg:setScale(g_fScaleX)
    spriteBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height-40*g_fScaleX))
    local callBack = function ( ... )
       createTopUI()
    end
    NewServerActivityController.getInfo(0,callBack)
    
    return _bgLayer
end



--创建主界面上半部分UI
function createTopUI( )
    local titleBg = XMLSprite:create("images/newserve/qitianle/qitianleTX_3/qitianleTX_3")
    titleBg:setScale(g_fScaleX)
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height-90*g_fScaleX))
    _bgLayer:addChild(titleBg)
    
    --倒计时背景
    local countDownBg = CCSprite:create("images/newserve/timelable.png")
    countDownBg:setAnchorPoint(ccp(0.5,1))
    countDownBg:setScale(g_fScaleX)
    countDownBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height - 130*g_fScaleX - titleBg:getContentSize().height*g_fScaleX))
    _bgLayer:addChild(countDownBg)

    _time = tonumber(NewServerActivityData.countDownTime())
    local  str 
    if(_time > 0)then
        --活动倒计时
        str = GetLocalizeStringBy("fqq_083")
    else
        --领取倒计时
        str = GetLocalizeStringBy("fqq_084")
        _time = NewServerActivityData.receiveCountDownTime()
    end
    
    _strLable = CCRenderLabel:create(str,g_sFontName,20,1,ccc3(0x00,0x00,0x00),type_stroke)
    _strLable:setColor(ccc3(0x00,0xff,0x18))
    _strLable:setAnchorPoint(ccp(0.5,0.5))
    _strLable:setPosition(ccp(countDownBg:getContentSize().width*0.35,countDownBg:getContentSize().height*0.5))
    countDownBg:addChild(_strLable)

     -- if(_countdownTime)then
     --    _countdownTime = nil
     -- end
    _countdownTime =CCRenderLabel:create(TimeUtil.getTimeDesByInterval(_time),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
    _countdownTime:setColor(ccc3(0x00,0xff,0x18))
    _countdownTime:setAnchorPoint(ccp(0,0.5))
    _countdownTime:setPosition(ccp(_strLable:getContentSize().width,_strLable:getContentSize().height*0.5))
    _strLable:addChild(_countdownTime)
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

    --创建下半部分UI
    -- if(_dowmBg)then
    --     _dowmBg = nil
    -- end
    -- 添加特效
    local texiao1 = XMLSprite:create("images/newserve/qitianle/qitianleTX_4/qitianleTX_4")
    texiao1:setAnchorPoint(ccp(0.5,1))
    texiao1:setPosition(ccp(g_winSize.width*0.5,g_winSize.height- 278*g_fScaleX))
    _bgLayer:addChild(texiao1)

    local borderBg = CCScale9Sprite:create("images/newserve/kuang.png")
    borderBg:setContentSize(CCSizeMake(g_winSize.width/g_fScaleX, (g_winSize.height- 278*g_fScaleX)/g_fScaleX) )
    borderBg:setAnchorPoint(ccp(0.5,1))
    borderBg:setScale(g_fScaleX)
    borderBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height- 278*g_fScaleX))
    _bgLayer:addChild(borderBg)


    _dowmBg = CCSprite:create()
    _dowmBg:setContentSize(CCSizeMake(g_winSize.width,g_winSize.height- 278*g_fScaleX))
    _dowmBg:setAnchorPoint(ccp(0.5,1))
    _dowmBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height- 278*g_fScaleX))
    _bgLayer:addChild(_dowmBg)

    --创建tableview背景
    local attr_full_rect = CCRectMake(0, 0, 75, 75)
    local attr_inset_rect = CCRectMake(30, 30, 15, 10)
    _tableViewBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", attr_full_rect, attr_inset_rect)
    _dowmBg:addChild(_tableViewBg)
    _tableViewBg:setPreferredSize(CCSizeMake(600*g_fScaleX, _dowmBg:getContentSize().height*0.85 - 73*g_fScaleX))
    _tableViewBg:setAnchorPoint(ccp(0.5, 1))
    _tableViewBg:setPosition(ccp(_dowmBg:getContentSize().width*0.5, _dowmBg:getContentSize().height*0.85 - 53*g_fScaleX))
    createDayButton()
    numItemButtonCallback(1)   
end

--更新倒计时
function updateTime( ... )
   local time = tonumber(NewServerActivityData.countDownTime())
    local  str 
    if(time > 0)then
        --活动倒计时
        str = GetLocalizeStringBy("fqq_083")
        _countdownTime:setString(TimeUtil.getTimeDesByInterval(time))
    elseif(time <= 0)then
        --领取倒计时
        str = GetLocalizeStringBy("fqq_084")
        _strLable:setString(str)
        time = NewServerActivityData.receiveCountDownTime()
        if(time <= 0)then
            _countdownTime:setString(GetLocalizeStringBy("fqq_097"))
        else
           _countdownTime:setString(TimeUtil.getTimeDesByInterval(time))  
        end
    end
    
    if(time <= 0)then
        stopSchedule()
    end
end
--创建1~7天按钮
function createDayButton( ... )
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_priority - 10)
    _dowmBg:addChild(menuBar)
    if(table.count(_dayBtnAry) ~= 0)then
        _dayBtnAry = {}
    end

	for i=1,7 do
        local normal = CCSprite:create("images/newserve/button-h.png")
        normal:setScale(g_fScaleX)
        normal:setAnchorPoint(ccp(0,0))
        normal:setPosition(ccp(g_winSize.width/9*i,_dowmBg:getContentSize().height-60*g_fScaleX))
        _dowmBg:addChild(normal)

        local numItemButton = CCMenuItemImage:create("images/newserve/h-"..i..".png","images/newserve/n-"..i..".png","images/newserve/n-"..i..".png")
        menuBar:addChild(numItemButton,1,i)
        numItemButton:setAnchorPoint(ccp(0.5,0))
        numItemButton:setScale(g_fScaleX)
        numItemButton:setPosition(ccp(normal:getPositionX()+normal:getContentSize().width*g_fScaleX*0.5,normal:getPositionY()+normal:getContentSize().height*g_fScaleX - 15*g_fScaleX))
        numItemButton:registerScriptTapHandler(numItemButtonCallback)

        local texiao1 = XMLSprite:create("images/newserve/qitianle/qitianleTX_2/qitianleTX_2")
        texiao1:setAnchorPoint(ccp(0.5,0.5))
        texiao1:setPosition(ccpsprite(0.5,0.5,numItemButton))
        numItemButton:addChild(texiao1,1,tagItem+i)
        if(i ~=1)then
            texiao1:setVisible(false)
        end
        local day = NewServerActivityData.getCurDay()
        if(day >= i)then
            --当小于等于开服天数时
            print("NewServerActivityData",i)
            local isNoEnter = NewServerActivityData.isRedTipOfOpenBuy(i)
            if (isNoEnter or NewServerActivityData.isRedTipOfDayButton(i))then
                --创建小红点
                local redTipSprite = RedTipSprite()
                redTipSprite:setAnchorPoint(ccp(1,1))
                redTipSprite:setPosition(ccp(numItemButton:getContentSize().width*0.98,numItemButton:getContentSize().height*0.98))
                numItemButton:addChild(redTipSprite,1,400)
            end
        end
        
        table.insert(_dayBtnAry,numItemButton)
        if (i == 1) then
            numItemButton:setEnabled(false)
        end

    end
end

--创建下半部分标签（标签内容可能会随着天数变化而改变）
function numItemButtonCallback( PDay )
    _biaoqianNum  = 1
    for i=1,#_dayBtnAry do
        if(i == PDay )then
            _dayBtnAry[PDay]:setEnabled(false)
            local item = _dayBtnAry[PDay]
            local texiaoSprite = item:getChildByTag(tagItem+PDay)
            texiaoSprite:setVisible(true)
        else
            _dayBtnAry[i]:setEnabled(true)
            local item = _dayBtnAry[i]
           local texiaoSprite = item:getChildByTag(tagItem+i)
           texiaoSprite:setVisible(false)
        end
    end
    --点击第几天 存的就是第几天的数据
    _labeldata = nil
    
    --存的当天的所有任务id
    _data = {}

    if(NewServerActivityData.isCan(PDay))then
        ------万不得已
        if(fourItemMenuBar~=nil)then
            fourItemMenuBar:removeFromParentAndCleanup(true)
            fourItemMenuBar = nil
        end
        if(_buyView )then
            _buyView:removeFromParentAndCleanup(true)
            _buyView = nil
            _desk:removeFromParentAndCleanup(true)
            _desk = nil
        end
        _day = PDay --(使用_day的原因是:假如今天是开服第2天，我点击了第3天，会只弹出一个奖励框，记录一下之前按钮的位置)
        _labeldata = NewServerActivityData.getTapInfoByDay(PDay)
        -- print("数据数据_labeldata")
        -- print_t(_labeldata)
        --创建4个标签，我把开服抢购设为最后一个标签
        fourItemMenuBar = CCMenu:create()
        fourItemMenuBar:setPosition(ccp(0,0))
        fourItemMenuBar:setTouchPriority(_priority - 10)
        _dowmBg:addChild(fourItemMenuBar)

        local labelArray = {
            _labeldata.mission1_desc,
            _labeldata.mission2_desc,
            _labeldata.mission3_desc,
            GetLocalizeStringBy("fqq_085")
        }

        _btnAry = {}
        for i=1,4 do
            local btnLableBtn = createBtn(labelArray[i],i)
            btnLableBtn:setScale(g_fScaleX)
            btnLableBtn:setAnchorPoint(ccp(0,1))
            btnLableBtn:setPosition(ccp(40*i*g_fScaleX+(i-1)*btnLableBtn:getContentSize().width*g_fScaleX-(i-1)*40*g_fScaleX,_dowmBg:getContentSize().height*0.85))
            _heightLable = btnLableBtn:getContentSize().height*g_fScaleX
            if i == 1 then
                btnLableBtn:setEnabled(false)
            else
                btnLableBtn:setEnabled(true)
            end
            fourItemMenuBar:addChild(btnLableBtn,1,i)
            table.insert(_btnAry,btnLableBtn)
        end
        _dataInfo = string.split(_labeldata.mission_1,"|")
        local data2 = {}
        local data1 = {}
        local data0 = {} 
        for i=1,#_dataInfo do
            local dbInfo = NewServerActivityData.getDBInfoByTaskId(_dataInfo[i])
            local status =  NewServerActivityData.priorityOrder(dbInfo.id)
            if(tonumber(status) == 1)then
                local data = _data[i]
                dbInfo.type = 2
                table.insert(data2,dbInfo)
            elseif tonumber(status) == 0 then
                dbInfo.type = 1
                table.insert(data1,dbInfo)
            else
                dbInfo.type = 0
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
        
        createtableView()
    else
        local callBack = function ( ... )
            _labeldata = NewServerActivityData.getTapInfoByDay(_day)
            _dayBtnAry[_day]:setEnabled(false)
            _dayBtnAry[PDay]:setEnabled(true)
            local item = tolua.cast(_dayBtnAry[_day],"CCMenuItemSprite")
            local texiaoSprite = tolua.cast(item:getChildByTag(tagItem+_day),"CCSprite")
            texiaoSprite:setVisible(true)
            local item = tolua.cast(_dayBtnAry[PDay],"CCMenuItemSprite")
            local texiaoSprite = tolua.cast(item:getChildByTag(tagItem+PDay),"CCSprite")
            texiaoSprite:setVisible(false)
        end
        local dta = NewServerActivityData.getTapInfoByDay(PDay)
        local achie_reward = ItemUtil.getItemsDataByStr(dta.preview)
        ReceiveReward.showRewardWindow( achie_reward,callBack, 999, -635,GetLocalizeStringBy("key_2295"))
    end
		
end

--创建文本
function createBtn( text ,pMissionId)
    local insertRect = CCRectMake(35,20,1,1)
    local tapBtnN = CCScale9Sprite:create(insertRect,_imagePath.tap_btn_n)
    tapBtnN:setPreferredSize(CCSizeMake(140,53))
    local tapBtnH = CCScale9Sprite:create(insertRect,_imagePath.tap_btn_h)
    tapBtnH:setPreferredSize(CCSizeMake(140,57))
    
    local label1 = CCRenderLabel:create(text, g_sFontName, 20, 2, ccc3(0xff, 0xf9, 0xd0 ), type_stroke)
    label1:setColor(ccc3(0x7c, 0x48, 0x01))
    label1:setAnchorPoint(ccp(0.5,0.5))
    label1:setPosition(ccp(tapBtnN:getContentSize().width*0.5,tapBtnN:getContentSize().height*0.45))
    tapBtnH:addChild(label1) 

    local label2 = CCRenderLabel:create(text, g_sFontName, 20, 1, ccc3(0xd7, 0xa5, 0x56 ), type_stroke)
    label2:setColor(ccc3(0x76, 0x3b, 0x0b))
    label2:setAnchorPoint(ccp(0.5,0.5))
    label2:setPosition(ccp(tapBtnH:getContentSize().width*0.5,tapBtnH:getContentSize().height*0.4))
    tapBtnN:addChild(label2)
    local btn = CCMenuItemSprite:create(tapBtnN, nil,tapBtnH)
    btn:setAnchorPoint(ccp(0.5,0.5))
    btn:registerScriptTapHandler(changeLabel)
    if(pMissionId ~= 4)then
        --如果是前3个按钮
        local missionTable = string.split(_labeldata["mission_"..pMissionId],"|")
        local isTip = NewServerActivityData.isRedTipOfReceive(missionTable)
        if(isTip)then
            --如果有可领取的物品
            local redTipSprite = RedTipSprite()
             redTipSprite:setAnchorPoint(ccp(1,1))
             redTipSprite:setPosition(ccp(btn:getContentSize().width*0.98,btn:getContentSize().height*0.98))
             btn:addChild(redTipSprite,1,300)
        end
    else
        local isNoEnter = NewServerActivityData.isRedTipOfOpenBuy(_labeldata.id)
        print("isNoEnter = NewServerActivityData.isRedTipOfOpenBuy(_labeldata.id)",isNoEnter)
        if(isNoEnter)then
            local redTipSprite = RedTipSprite()
            redTipSprite:setAnchorPoint(ccp(1,1))
            redTipSprite:setPosition(ccp(btn:getContentSize().width*0.98,btn:getContentSize().height*0.98))
            btn:addChild(redTipSprite,1,300)
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
        --如果切到第四个开服抢购
        local isNoEnter = NewServerActivityData.isRedTipOfOpenBuy(_labeldata.id)
        if(isNoEnter)then
            --如果红点已经消失了，就不用再调这个方法
             refreshNumLableTip()
        end
        NewServerActivityData.setNewServerActivityEnter(_day)
        --把红点移除掉
        local item = tolua.cast(_btnAry[pValue],"CCMenuItemSprite")
        local tipSprite = tolua.cast(item:getChildByTag(300),"CCSprite")
        if(tipSprite)then
            tipSprite:removeFromParentAndCleanup(true)
        end
        -- refreshNormalRedTip()
        --创建开服抢购的部分
        sellGoodsView()
    else
        local str = "mission_"..pValue
        local dataInfo = string.split(_labeldata[str],"|")
        if(not table.isEmpty(_data))then
            _data = {}
        end
        local data2 = {}
        local data1 = {}
        local data0 = {} 
        for i=1,#dataInfo do
            local dbInfo = NewServerActivityData.getDBInfoByTaskId(dataInfo[i])
            local status =  NewServerActivityData.priorityOrder(dbInfo.id)
            if(tonumber(status) == 1)then
                local data = _data[i]
                dbInfo.type = 2
                table.insert(data2,dbInfo)
            elseif tonumber(status) == 0 then
                dbInfo.type = 1
                table.insert(data1,dbInfo)
            else
                dbInfo.type = 0
                table.insert(data0,dbInfo)
            end
            -- table.insert(_data,dbInfo)
        end
    --     local function keySort ( _data1, _data2 )
    --     return tonumber(_data1.type) > tonumber(_data2.type)
    --     end
        local function keySort ( _data1, _data2 )
            return tonumber(_data1.id) < tonumber(_data2.id)
        end
         table.sort(_data,keySort)
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
        -- local function keySort ( _data1, _data2 )
        --     return tonumber(_data1.type) > tonumber(_data2.type)
        -- end 
        -- table.sort(_data,keySort)
        if(_buyView )then
            _buyView:removeFromParentAndCleanup(true)
            _buyView = nil
            _desk:removeFromParentAndCleanup(true)
            _desk = nil
            createtableView()
        else
            refreshTableview()
        end
         	
    end
end

--创建tableview
function createtableView(isRun)
        local isrun = isRun or false
        if(_tableView)then
            _tableView:removeFromParentAndCleanup(true)
            _tableView = nil
        end
        if(isrun)then
            local data2 = {}
            local data1 = {}
            local data0 = {} 
            for i=1,#_data do
               local status =  NewServerActivityData.priorityOrder(_data[i].id)
                    if(status == 1)then
                        local data = _data[i]
                        _data[i].type = 2
                        table.insert(data2,_data[i])
                    elseif status == 0 then
                        _data[i].type = 1
                        table.insert(data1,_data[i])
                    else
                        _data[i].type = 0
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
            -- local function keySort ( _data1, _data2 )
            --     return tonumber(_data1.type) > tonumber(_data2.type)
            -- end
            -- table.sort(_data,keySort)
        end
    print("新服活动信息输出~~")
    print_t(_data)
    local h = LuaEventHandler:create(function ( fn,p_table,a1,a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(600*g_fScaleX,182*g_fScaleX)
        elseif fn == "cellAtIndex" then
            a2 = NewServerActivityCell.createCell(_data[a1 + 1], a1 + 1,_priority - 30,_day)
            r = a2
            print("NewServerActivityCell.createCell")
        elseif fn == "numberOfCells" then
            r = table.count(_data)
            print("table.count(_data)",table.count(_data))
        elseif fn == "cellTouched" then
                   
        end
        return r
    end)
    _tableView = LuaTableView:createWithHandler(h,CCSizeMake(600*g_fScaleX, _dowmBg:getContentSize().height*0.85 - _heightLable - 25*g_fScaleX))
    _tableViewBg:addChild(_tableView)
    _tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _tableView:setAnchorPoint(ccp(0.5,0.5))
    _tableView:setPosition(ccp(_tableViewBg:getContentSize().width*0.5,_tableViewBg:getContentSize().height*0.5))
    _tableView:ignoreAnchorPointForPosition(false)
    _tableView:setTouchPriority(_priority - 2)
end

--如果为开服抢购,出现的就不是Cell了
function sellGoodsView( ... )
	if(_tableView)then
		_tableView:removeFromParentAndCleanup(true)
		_tableView = nil
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
    
    --特效添加
    local texiao1 = XMLSprite:create("images/newserve/qitianle/qitianleTX_1_down/qitianleTX_1_down")
    texiao1:setAnchorPoint(ccp(0.5,0.5))
    texiao1:setPosition(ccp(_desk:getContentSize().width*0.5,_desk:getContentSize().height*1.1))
    _desk:addChild(texiao1,1)

    local rewardInDb = ItemUtil.getItemsDataByStr(_labeldata.limitbuy)
    local icon,itemName,itemColor = ItemUtil.createGoodsIcon(rewardInDb[1], -450, 3000, -480,function ( ... )
        end,nil,nil,false)
    icon:setAnchorPoint(ccp(0.5,0.5))
    icon:setPosition(ccp(_desk:getContentSize().width*0.5,_desk:getContentSize().height*1.1))
    _desk:addChild(icon,2)

    local texiao2 = XMLSprite:create("images/newserve/qitianle/qitianleTX_1_up/qitianleTX_1_up")
    texiao2:setAnchorPoint(ccp(0.5,0.5))
    texiao2:setPosition(ccp(_desk:getContentSize().width*0.5,_desk:getContentSize().height*1.1))
    _desk:addChild(texiao2,3)

    local nameLabel = CCRenderLabel:create(itemName, g_sFontName,20,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    icon:addChild(nameLabel)
    nameLabel:setAnchorPoint(ccp(0.5,1))
    nameLabel:setColor(itemColor)
    nameLabel:setPosition(ccp(icon:getContentSize().width*0.5,5))

    --价格背景
    local priceBg = CCSprite:create("images/newserve/jiagedi.png")
    priceBg:setAnchorPoint(ccp(0,0))
    priceBg:setPosition(ccp(_desk:getContentSize().width*0.15,_desk:getContentSize().height*0.23))
    _desk:addChild(priceBg)
    --原价
    local richInfo1 = {
        lineAlignment = 2,
        labelDefaultColor = ccc3( 0xff, 0xf6, 0x00),
        labelDefaultFont = g_sFontPangWa,
        labelDefaultSize = 20,
        defaultType = "CCRenderLabel",
        elements = {
            {
                ["type"] = "CCSprite",
                image = "images/common/gold.png",
            },
            {
                text = tonumber(_labeldata.cost),
                type = "CCRenderLabel",
                color = ccc3( 0xff, 0xf6, 0x00),
            }
        }
    }
    local priceLabel = GetLocalizeLabelSpriteBy_2("fqq_070", richInfo1)
    priceLabel:setAnchorPoint(ccp(0.5, 0.5))
    priceLabel:setPosition(ccp(priceBg:getContentSize().width*0.5,priceBg:getContentSize().height*0.5))
    priceBg:addChild(priceLabel)

    local priceBg2 = CCSprite:create("images/newserve/jiagedi.png")
    priceBg2:setAnchorPoint(ccp(0,0))
    priceBg2:setPosition(ccp(_desk:getContentSize().width*0.5,_desk:getContentSize().height*0.23))
    _desk:addChild(priceBg2)
    --现价
    local richInfo2 = {
        lineAlignment = 2,
        labelDefaultColor = ccc3( 0xff, 0xf6, 0x00),
        labelDefaultFont = g_sFontPangWa,
        labelDefaultSize = 20,
        defaultType = "CCRenderLabel",
        elements = {
            {
                ["type"] = "CCSprite",
                image = "images/common/gold.png",
            },
            {
                text = tonumber(_labeldata.discount),
                type = "CCRenderLabel",
                color = ccc3( 0xff, 0xf6, 0x00),
            }
        }
    }
    local priceLabel2 = GetLocalizeLabelSpriteBy_2("fqq_071", richInfo2)
    priceLabel2:setAnchorPoint(ccp(0.5, 0.5))
    priceLabel2:setPosition(ccp(priceBg2:getContentSize().width*0.5,priceBg2:getContentSize().height*0.5))
    priceBg2:addChild(priceLabel2)
    local isRedTip = isRedLine()
     --红色的划线
    local noSprite = CCSprite:create("images/recharge/limit_shop/no_more.png")
    noSprite:setAnchorPoint(ccp(0.5,0.5))
    noSprite:setPosition(ccp(priceLabel:getContentSize().width*0.5,priceLabel:getContentSize().height/2))
    priceLabel:addChild(noSprite)
    noSprite:setVisible(isRedTip)

    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_priority-10)
    _desk:addChild(menu)
    --购买按钮
    local normalSprite  = CCSprite:create("images/newserve/buttonbuy-h.png")
    local selectSprite  = CCSprite:create("images/newserve/buttonbuy-n.png")
    local disabledSprite = BTGraySprite:create("images/newserve/buttonbuy-h.png")
    _btn = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
    _btn:setAnchorPoint(ccp(0.5,1))
    _btn:setPosition(ccp(_desk:getContentSize().width*0.5,priceLabel2:getPositionY()+20*g_fScaleX))
    _btn:registerScriptTapHandler(buycallBcak)
    menu:addChild(_btn)
    local isCanBuy = NewServerActivityData.isBuyGoods(_labeldata.id)
    if(NewServerDef.kAlreadyBuy ==isCanBuy)then
     _btn:setEnabled(false)
    end
    --仅限前xx人购买
    local richInfo = {
        lineAlignment = 2,
        labelDefaultColor = ccc3( 0xff, 0x84, 0x00),
        labelDefaultFont = g_sFontName,
        labelDefaultSize = 20,
        defaultType = "CCRenderLabel",
        elements = {
            
            {
                text = _labeldata.limited_num,
                type = "CCRenderLabel",
                color = ccc3( 0xff, 0x84, 0x00),
            }
        }
    }
    local label = GetLocalizeLabelSpriteBy_2("fqq_088", richInfo)
    label:setAnchorPoint(ccp(0.5, 1))
    label:setPosition(ccp(_btn:getContentSize().width*0.2,0))
    _btn:addChild(label)

    --剩余XX件
    _remainNum = NewServerActivityData.getremainBuyNum(_labeldata.id)

    --（剩余
    local remainTimeLabel1 = CCRenderLabel:create(GetLocalizeStringBy("fqq_089"),g_sFontName, 20,1, ccc3(0x00,0,0),type_stroke)
    remainTimeLabel1:setColor(ccc3(0xff,0x84,0x00))
    remainTimeLabel1:setAnchorPoint(ccp(0,0.5))
    remainTimeLabel1:setPosition(ccp(label:getContentSize().width, label:getContentSize().height*0.5))
    label:addChild(remainTimeLabel1)

    
    _remainTimeLabel = CCRenderLabel:create(_remainNum,g_sFontName,20,1, ccc3(0x00,0,0),type_stroke)
    _remainTimeLabel:setColor(ccc3(0xff,0x84,0x00))
    _remainTimeLabel:setAnchorPoint(ccp(0,0.5))
    _remainTimeLabel:setPosition(ccp(remainTimeLabel1:getContentSize().width,remainTimeLabel1:getContentSize().height*0.5))
    remainTimeLabel1:addChild(_remainTimeLabel)

    --件）
    local remainTimeLabel2 = CCRenderLabel:create(GetLocalizeStringBy("fqq_090"),g_sFontName,20,1, ccc3(0x00,0,0),type_stroke)
    remainTimeLabel2:setColor(ccc3(0xff,0x84,0x00))
    remainTimeLabel2:setAnchorPoint(ccp(0,0.5))
    remainTimeLabel2:setPosition(ccp(_remainTimeLabel:getContentSize().width,_remainTimeLabel:getContentSize().height*0.5))
    _remainTimeLabel:addChild(remainTimeLabel2)

end
--判断红线是否存在
function isRedLine( ... )
    if(tonumber(_labeldata.cost >= tonumber(_labeldata.discount)))then
        return false
    else
        return true
    end
end


--切换签前3个页签时的刷新方法
function refreshTableview( ... )
    _tableView:reloadData()
end

--购买的回调
function buycallBcak( ... )
    if (tonumber(NewServerActivityData.countDownTime()) <= 0)then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_095"))
        return
    end
    local callBack = function ( ... )
        --判断剩余量
        local remainNum = NewServerActivityData.getremainBuyNum(_labeldata.id)
        print("remainNum~~~~~~~",remainNum)
        if(remainNum <= 0)then
             AnimationTip.showTip(GetLocalizeStringBy("fqq_087"))
             return
        end
       --判断金币
        local goldCost =tonumber(_labeldata.discount)
        if goldCost > UserModel.getGoldNumber() then
            AnimationTip.showTip(GetLocalizeStringBy("key_1092"))
            return
        end
        
        --判断背包
        require "script/ui/item/ItemUtil"
        if(ItemUtil.isBagFull() == true )then
            return
        end
        local callBackfun = function ( ... )
        --减掉金币
        UserModel.addGoldNumber(-goldCost)
        -- --修改缓存
        print("_labeldata.id",_labeldata.id)
        NewServerActivityData.setPurchaseBuyflag(_labeldata.id,1)
        --弹出奖励框
        local achie_reward = ItemUtil.getItemsDataByStr( _labeldata.limitbuy)
        ReceiveReward.showRewardWindow( achie_reward,nil, 999, -510 )
        ItemUtil.addRewardByTable(achie_reward)
            _btn:setEnabled(false)
            _remainNum = _remainNum - 1
            _remainTimeLabel:setString(_remainNum)
        end
        NewServerActivityController.buy(_labeldata.id,callBackfun)
    end

    local goldCost =tonumber(_labeldata.discount)
            -- 提示
        local richInfo = {
            elements = {
                
                {
                    text = goldCost
                },
                {
                    ["type"] = "CCSprite",
                    image = "images/common/gold.png"
                 }
            }
        }
        local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("fqq_091"), richInfo)  
        local alertCallback = function ( isConfirm, _argsCB )
            if not isConfirm then
                return
            end
            
            callBack()
        end
        require "script/ui/tip/RichAlertTip"
        RichAlertTip.showAlert(newRichInfo, alertCallback, true, nil, GetLocalizeStringBy("key_8129"), nil, nil, nil, nil)
end

--返回按钮的回调
function closeCallBack( ... )
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    require "script/ui/main/MainBaseLayer"
    local main_base_layer = MainBaseLayer.create()
    MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
    MainScene.setMainSceneViewsVisible(true,true,true)
end

--刷新第X天上面的红点(关于第4个标签的)
function refreshNumLableTip( ... )
    if   not  NewServerActivityData.isRedTipOfDayButton(_labeldata.id) then
        local item = _dayBtnAry[_day]
        local redSptite = item:getChildByTag(400)
        redSptite:setVisible(false)
    end    
end
--刷新标签页的红点提示
function refreshLableTip( pMissionId )
    local missionTable = string.split(_labeldata["mission_"..pMissionId],"|")
    -- print("_labeldata[mission_..pMissionId]")
    -- print_t(missionTable)
        local isTip = NewServerActivityData.isRedTipOfReceive(missionTable)
        if not (isTip)then
             local item = _btnAry[pMissionId]
            local redSptite = item:getChildByTag(300)
            if(redSptite)then
            redSptite:removeFromParentAndCleanup(true)
        end
        end
end
--刷新第X天上面的红点
function refreshNormalRedTip()
    local isNoEnter = NewServerActivityData.isRedTipOfOpenBuy(_labeldata.id)
    if not (NewServerActivityData.isRedTipOfDayButton(_day)) then
        if(not isNoEnter)then
            local item = _dayBtnAry[_day]
            local redSptite = item:getChildByTag(400)
            redSptite:setVisible(false)
        end
   end
end
--红点
function RedTipSprite( ... )
    local tipSprite= CCSprite:create("images/common/tip_2.png")
     return tipSprite       
end
function getbiaoqianNum( ... )
   return _biaoqianNum
end