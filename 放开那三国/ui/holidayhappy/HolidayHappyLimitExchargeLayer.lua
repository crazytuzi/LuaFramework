-- FileName: HolidayHappyLimitExchargeLayer.lua 
-- Author: fuqiongqiong
-- Date: 2016-6-5
-- Purpose: 

module("HolidayHappyLimitExchargeLayer",package.seeall)
require "script/ui/holidayhappy/HolidayHappyData"
require "script/ui/holidayhappy/HolidayHappyController"
local _data
local _tableviewBg
local _bglayer

function init( ... )
	_data = {}
    _tableviewBg = nil
    _bglayer = nil
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
        _bglayer:registerScriptTouchHandler(onTouchesHandler,false, _priority,true)
        _bglayer:setTouchEnabled(true)
    elseif(event == "exit")then
        _bglayer:unregisterScriptTouchHandler()
        _bglayer = nil
    end
end
function showLayer()
    init()
	_priority = -570
	_bglayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bglayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bglayer, 399)
	createLayer()
end

function createLayer( isRefresh )
    local refresh = isRefresh or false
    if(_bglayer:getChildByTag(10001))then
        _bglayer:removeChildByTag(10001,true)
    end
    --背景
    local bg = CCScale9Sprite:create("images/holidayhappy/tableviewbg.png") --174,133
    _bglayer:addChild(bg,1,10001)
    bg:setPreferredSize(CCSizeMake(630*g_fScaleX, _bglayer:getContentSize().height*0.8 ))
    bg:setAnchorPoint(ccp(0.5, 1))
    bg:setPosition(ccp(g_winSize.width*0.5, _bglayer:getContentSize().height*0.85 ))
    
    --限时兑换标题
    local title = CCSprite:create("images/holidayhappy/xianshititle.png")
    title:setScale(g_fScaleX)
    title:setAnchorPoint(ccp(0.5,0.5))
    title:setPosition(ccp(bg:getContentSize().width*0.5,bg:getContentSize().height))
    bg:addChild(title)
    --限时兑换
    local titleLable = CCRenderLabel:create(GetLocalizeStringBy("fqq_106"),g_sFontPangWa,27,1,ccc3(0x00,0x00,0x00),type_stroke)
    titleLable:setColor(ccc3(0xff,0xf6,0x00))
    titleLable:setAnchorPoint(ccp(0.5,0.5))
    titleLable:setPosition(ccp(title:getContentSize().width*0.5,title:getContentSize().height*0.5))
    title:addChild(titleLable)
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_priority - 10)
    bg:addChild(menuBar)
    -- menuBar:setTouchPrioty()
    --关闭按钮
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
    closeBtn:setAnchorPoint(ccp(0,0))
    closeBtn:setScale(g_fScaleX)
    closeBtn:setPosition(ccp(bg:getContentSize().width*0.88,bg:getContentSize().height*0.95))
    closeBtn:registerScriptTapHandler(closeCallback)
    menuBar:addChild(closeBtn)
    --兑换结束倒计时
    local lableExcharge = CCRenderLabel:create(GetLocalizeStringBy("fqq_104"),g_sFontName, 20, 1, ccc3(0x00, 0x00, 0x00),type_stroke)
    lableExcharge:setColor(ccc3(0x00,0xff,0x18))
    lableExcharge:setScale(g_fScaleX)
    bg:addChild(lableExcharge)
    lableExcharge:setAnchorPoint(ccp(0,1))
    lableExcharge:setPosition(ccp(bg:getContentSize().width*0.25,bg:getContentSize().height - title:getContentSize().height*0.5*g_fScaleX - 10*g_fScaleX))

    local endTime = HolidayHappyData.getExchangeEndTime()
    local endStr = TimeUtil.getTimeFormatYMDH(endTime)
    local endTimeLabel = CCRenderLabel:create(endStr, g_sFontName, 20, 1, ccc3(0x00, 0x00, 0x00), type_shadow)
    endTimeLabel:setColor(ccc3(0x00, 0xff, 0x18))
    endTimeLabel:setAnchorPoint(ccp(0, 0.5))
    endTimeLabel:setPosition(ccp(lableExcharge:getContentSize().width,lableExcharge:getContentSize().height*0.5))
    lableExcharge:addChild(endTimeLabel) 

    --tableView的背景
    _tableviewBg = CCScale9Sprite:create("images/holidayhappy/xianshibg.png")
    bg:addChild(_tableviewBg)
    _tableviewBg:setPreferredSize(CCSizeMake(bg:getContentSize().width*0.95, bg:getContentSize().height*0.73))
    _tableviewBg:setAnchorPoint(ccp(0.5, 1))
    _tableviewBg:setPosition(ccp(bg:getContentSize().width*0.5, bg:getContentSize().height - title:getContentSize().height*g_fScaleX*0.5 - 20*g_fScaleX - lableExcharge:getContentSize().height*g_fScaleX))
    createTableView()
end
--创建tableview
function createTableView( ... )
    
	local taskIdArray = HolidayHappyData.getAllDataOfTypeOfTaskThree()
    _data = {}
    local dataInfo = {}
	for k,v in pairs(taskIdArray) do
		local data = HolidayHappyData.getDataOfFestival_rewardByTaskId(tonumber(v))
        
		table.insert(dataInfo,data)
	end
    local function keySort ( data1, data2 )
        return tonumber(data1.id) < tonumber(data2.id)
    end       
    table.sort(dataInfo,keySort)
    for k,v in pairs(dataInfo) do
        table.insert(_data,v)
    end
    local h = LuaEventHandler:create(function ( fn,p_table,a1,a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(600 * g_fScaleX,190 * g_fScaleX)
        elseif fn == "cellAtIndex" then
            a2 = createCell(_data[a1 + 1])
            r = a2
        elseif fn == "numberOfCells" then
            r = table.count(_data)
        elseif fn == "cellTouched" then          
        end
        return r
    end)
    local tableView = LuaTableView:createWithHandler(h,CCSizeMake(630*0.95*g_fScaleX, _tableviewBg:getContentSize().height - 15*g_fScaleX))
    _tableviewBg:addChild(tableView)
    tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    tableView:setAnchorPoint(ccp(0.5,0.5))
    tableView:setPosition(ccp(_tableviewBg:getContentSize().width*0.5,_tableviewBg:getContentSize().height*0.5))
    tableView:ignoreAnchorPointForPosition(false)
    tableView:setTouchPriority(_priority - 2)
   
    local itemTable = {}
    for k1,v1 in pairs(_data) do
        --当前拥有物品数量
        local need = string.split(v1.need,",")
        for k2,v2 in pairs(need) do
            local rewardInDb = ItemUtil.getItemsDataByStr(need[k2])
            local type,id,num =HolidayHappyData.getItemData(v2)
            local icon,itemName,itemColor = ItemUtil.createGoodsIcon(rewardInDb[1], -630, 3000, -640,function ( ... )
            end,nil,nil,false)
            itemTable[id] = {}
            itemTable[id].itemName = itemName
            local allNum = ItemUtil.getCacheItemNumBy(id)
            itemTable[id].allNum = allNum
        end
    end
    local k1 = 1
    for k,v in pairs(itemTable) do
        local lable = CCRenderLabel:create(GetLocalizeStringBy("fqq_123"),g_sFontName,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        _tableviewBg:addChild(lable)
        lable:setScale(g_fScaleX)
        lable:setColor(ccc3(0x00,0xe4,0xff))
        lable:setAnchorPoint(ccp(0.5,0))
        lable:setPosition(ccp(_tableviewBg:getContentSize().width*0.6,-_tableviewBg:getContentSize().height*0.08 - lable:getContentSize().height*g_fScaleX*(k1-1)*1.2))  
        local nameLabel = CCRenderLabel:create(GetLocalizeStringBy("fqq_110")..v.itemName, g_sFontName,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        lable:addChild(nameLabel)
        nameLabel:setColor(ccc3(0x00,0xe4,0xff))
        nameLabel:setAnchorPoint(ccp(1,0.5))
        nameLabel:setPosition(ccp(-lable:getContentSize().width,lable:getContentSize().height*0.5)) 
        local numLabel = CCRenderLabel:create(v.allNum, g_sFontName,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        lable:addChild(numLabel)
        numLabel:setColor(ccc3(0xff,0xff,0xff))
        numLabel:setAnchorPoint(ccp(0,0.5))
        numLabel:setPosition(ccp(lable:getContentSize().width*1.02,lable:getContentSize().height*0.5)) 
        k1 = k1+1
    end
end



function createCell( pData )
	local cell = CCTableViewCell:create()
    cell:setScale(g_fScaleX)
    cell:setContentSize(CCSizeMake(600, 190))
	local bg = CCScale9Sprite:create("images/common/bg/bg_9s_9.png")
	bg:setPreferredSize(CCSizeMake(600,190))
    -- bg:setScale(g_fScaleX)
	cell:addChild(bg)
	local whiteBg = CCScale9Sprite:create("images/common/bg/goods_bg.png")
	whiteBg:setContentSize(CCSizeMake(437,130))
	whiteBg:setAnchorPoint(ccp(0,1))
	whiteBg:setPosition(ccp(20,155))
	bg:addChild(whiteBg)

	local need = string.split(pData.need,",")
	local exchange = pData.exchange
	if(table.count(need) == 1)then
		--如果为1对1
		 for k,v in pairs(need) do
		local rewardInDb = ItemUtil.getItemsDataByStr(need[k])
            local icon,itemName,itemColor = ItemUtil.createGoodsIcon(rewardInDb[1], -630, 3000, -640,function ( ... )
        end,nil,nil,false)
            icon:setAnchorPoint(ccp(0,0.5))
        icon:setPosition(ccp(25*k+(k-1)*icon:getContentSize().width,75))
        whiteBg:addChild(icon)
        local nameLabel = CCRenderLabel:create(itemName, g_sFontName,20,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        icon:addChild(nameLabel)
        nameLabel:setAnchorPoint(ccp(0.5,1))
        nameLabel:setColor(itemColor)
        nameLabel:setPosition(ccp(icon:getContentSize().width*0.57,0)) 
		 local denghao = CCSprite:create("images/recharge/change/deng.png")
         denghao:setAnchorPoint(ccp(0.5,0.5))
         denghao:setPosition(ccp(whiteBg:getContentSize().width*0.5,whiteBg:getContentSize().height*0.5))
         whiteBg:addChild(denghao)
		 local rewardInDb = ItemUtil.getItemsDataByStr(exchange)
		   local icon,itemName,itemColor = ItemUtil.createGoodsIcon(rewardInDb[1], -630, 3000, -640,function ( ... )
        end,nil,nil,false)
        icon:setAnchorPoint(ccp(1,0.5))
        icon:setPosition(ccp(whiteBg:getContentSize().width-30,75))
        whiteBg:addChild(icon)
        local nameLabel = CCRenderLabel:create(itemName, g_sFontName,20,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        icon:addChild(nameLabel)
        nameLabel:setAnchorPoint(ccp(0.5,1))
        nameLabel:setColor(itemColor)
        nameLabel:setPosition(ccp(icon:getContentSize().width*0.57,0)) 

		end
	else
		--如果为2对1
		local jiahao  = CCSprite:create("images/formation/potential/newadd.png") 
		 for k,v in pairs(need) do
		local rewardInDb = ItemUtil.getItemsDataByStr(need[k])
            local icon,itemName,itemColor = ItemUtil.createGoodsIcon(rewardInDb[1], -630, 3000, -700,function ( ... )
        end,nil,nil,false)
        icon:setAnchorPoint(ccp(0,0.5))
        icon:setPosition(ccp(25*k+(k-1)*jiahao:getContentSize().width+(k-1)*icon:getContentSize().width,75))
        whiteBg:addChild(icon)
        local nameLabel = CCRenderLabel:create(itemName, g_sFontName,20,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        icon:addChild(nameLabel)
        nameLabel:setAnchorPoint(ccp(0.5,1))
        nameLabel:setColor(itemColor)
        nameLabel:setPosition(ccp(icon:getContentSize().width*0.57,0))
        end 
       jiahao:setAnchorPoint(ccp(0,0.5))
       jiahao:setPosition(ccp(125,whiteBg:getContentSize().height*0.5))
       whiteBg:addChild(jiahao)
       local denghao = CCSprite:create("images/recharge/change/deng.png")
       denghao:setAnchorPoint(ccp(0,0.5))
       denghao:setPosition(ccp(235+jiahao:getContentSize().width,whiteBg:getContentSize().height*0.5))
       whiteBg:addChild(denghao)
       local rewardInDb = ItemUtil.getItemsDataByStr(exchange)
       local icon,itemName,itemColor = ItemUtil.createGoodsIcon(rewardInDb[1], -630, 3000, -640,function ( ... )
        end,nil,nil,false)
       icon:setAnchorPoint(ccp(1,0.5))
        icon:setPosition(ccp(whiteBg:getContentSize().width-10,75))
        whiteBg:addChild(icon)
        local nameLabel = CCRenderLabel:create(itemName, g_sFontName,20,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        icon:addChild(nameLabel)
        nameLabel:setAnchorPoint(ccp(0.5,1))
        nameLabel:setColor(itemColor)
        nameLabel:setPosition(ccp(icon:getContentSize().width*0.57,0)) 
	end

	--兑换按钮
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_priority - 10)
    bg:addChild(menuBar)
        local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_blue_n.png")
        normalSprite:setContentSize(CCSizeMake(120,65))
        local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_blue_h.png")
        selectSprite:setContentSize(CCSizeMake(120,65))
        local disSprite  = CCScale9Sprite:create("images/common/btn/btn_blue_hui.png")
        disSprite:setContentSize(CCSizeMake(120,65))
        local item = CCMenuItemSprite:create(normalSprite,selectSprite,disSprite)
        item:setAnchorPoint(ccp(1,0.5))
        item:setPosition(ccp(bg:getContentSize().width-20,bg:getContentSize().height*0.5))
        menuBar:addChild(item,1,tonumber(pData.id))
        item:registerScriptTapHandler(exchargeCallbck)
        --“兑换”字
        local buyLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2689"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
        buyLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
        buyLabel:setAnchorPoint(ccp(0.5,0.5))
        buyLabel:setPosition(ccp(item:getContentSize().width *0.5,item:getContentSize().height *0.5))
        item:addChild(buyLabel)

	--剩余次数
	local remainTimes = pData.exchangetime - HolidayHappyData.getAlreadyExchangeTimes(pData.id)
	local reaminLable = CCLabelTTF:create(GetLocalizeStringBy("fqq_105"),g_sFontName,20)
    reaminLable:setAnchorPoint(ccp(0.5,1))
    reaminLable:setPosition(ccp(item:getContentSize().width*0.5,-3))
	reaminLable:setColor(ccc3(0xff,0xff,0xff))
	item:addChild(reaminLable)

	local remainTimesLabel = CCLabelTTF:create(remainTimes,g_sFontName,21)
    remainTimesLabel:setColor(ccc3(0xff,0xff,0xff))
    remainTimesLabel:setAnchorPoint(ccp(0.5,1))
    remainTimesLabel:setPosition(ccp(reaminLable:getContentSize().width*0.3,-5))
    reaminLable:addChild(remainTimesLabel)

    local allTimesLabel = CCLabelTTF:create("/"..pData.exchangetime,g_sFontName,21)
    allTimesLabel:setColor(ccc3(0xff,0xff,0xff))
    allTimesLabel:setAnchorPoint(ccp(0,0.5))
    allTimesLabel:setPosition(ccp(remainTimesLabel:getContentSize().width,remainTimesLabel:getContentSize().height*0.5))
    remainTimesLabel:addChild(allTimesLabel)
    if(remainTimes == 0)then
        item:setEnabled(false)
        buyLabel:setColor(ccc3(0xff,0xff,0xff))
    end
	return cell
end

--关闭按钮的回调
function closeCallback( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bglayer) then
		_bglayer:removeFromParentAndCleanup(true)
		_bglayer = nil
	end
end

--兑换的回调
function exchargeCallbck( tag )
    --活动结束
    if (HolidayHappyData.isAllActiveEnd())then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_114"))
        return
    end
    
    if( not HolidayHappyData.exchangeCondition(tag))then
        --提示兑换条件不足
         require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_109"))
        return
    end
     HolidayHappyBuyLayer.showPurchaseLayer(tag,2)
  
end

