-- Filename：    QuickRobResultLayer.lua
-- Author：      DJN
-- Date：        2014-7-15
-- Purpose：     连续抢夺结算

module("QuickRobResultLayer", package.seeall)
require "script/audio/AudioUtil"
require "script/ui/treasure/QuickRobRewardLayer"
require "script/ui/treasure/QuickRobData"


local _bgLayer       --灰色背景屏蔽层
local _touchPriority --触摸优先级
local _ZOrder        --Z轴值
local m_QuickRobInfo --连续抢夺结果数据

----------------------------------------初始化函数
local function init()
    _bgLayer       = nil
    _touchPriority = nil
    _ZOrder        = nil
    m_QuickRobInfo = nil
   
end

----------------------------------------触摸事件函数
function onTouchesHandler(eventType,x,y)
    if eventType == "began" then
        print("onTouchesHandler,began")
        return true
    elseif eventType == "moved" then
        print("onTouchesHandler,moved")
    else
        print("onTouchesHandler,else")
    end
end

local function onNodeEvent(event)
    if event == "enter" then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
        _bgLayer:setTouchEnabled(true)
    elseif event == "exit" then
        _bgLayer:unregisterScriptTouchHandler()
    end
end

----------------------------------------关闭页面回调函数
--[[
    @des    :关闭按钮回调
    @param  :
    @return :
--]]
function closeMenuCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if _bgLayer then
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
    end
    --QuickRobRewardLayer.showLayer()
end

----------------------------------------转去抽奖页面回调函数
--[[
    @des    :抽取按钮回调
    @param  :
    @return :
--]]
local function lotteryMenuCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
    QuickRobRewardLayer.showLayer()
end

----------------------------------------UI函数
--[[
    @des    :创建结算背景
    @param  :
    @return :
--]]
local function createBgUI()
    require "script/ui/main/MainScene"
    local bgSize = CCSizeMake(508,750)
    local bgScale = MainScene.elementScale
    
    --主黄色背景
    local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
    bgSprite:setContentSize(CCSizeMake(bgSize.width,bgSize.height))
    bgSprite:setAnchorPoint(ccp(0.5,0.5))
    bgSprite:setPosition(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.4)
    bgSprite:setScale(bgScale)
    _bgLayer:addChild(bgSprite)

 
    --二级棕色背景
    require "script/utils/BaseUI"
    secondBgSprite = BaseUI.createContentBg(CCSizeMake(462,437))
    secondBgSprite:setAnchorPoint(ccp(0.5,0.5))
    secondBgSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height*0.5-5))
    bgSprite:addChild(secondBgSprite)

    --顶部花篮
    local top_back = CCSprite:create("images/common/v_top.png")
    top_back:setAnchorPoint(ccp(0.5,0))
    top_back:setPosition(ccp(bgSprite:getContentSize().width*0.5 , bgSprite:getContentSize().height-170))
    bgSprite:addChild(top_back)
    --花篮上的字
    local str_top = CCSprite:create("images/treasure/sum_of_treasure.png")
    str_top:setAnchorPoint(ccp(0.5,0))
    str_top:setPosition(ccp(top_back:getContentSize().width*0.5, 100))
    top_back:addChild(str_top)

    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority-1)
    bgSprite:addChild(bgMenu)

    --战斗胜利，可以抽奖
    if ( m_QuickRobInfo.ret.appraisal ~= "E" and m_QuickRobInfo.ret.appraisal ~= "F" )then
        --底部按钮上方提示字的底
        local str_line = CCScale9Sprite:create("images/common/line2.png")
        str_line:setContentSize(CCSizeMake(290,52))
        str_line:setAnchorPoint(ccp(0.5,0.5))
        str_line:setPosition(bgSprite:getContentSize().width*0.5,120)
        bgSprite:addChild(str_line)
        --底部按钮上方提示的字
        local str = CCRenderLabel:create(GetLocalizeStringBy("djn_3"),g_sFontPangWa , 24, 1 ,ccc3(0x00,0x00,0x00), type_stroke)
        str:setAnchorPoint(ccp(0.5,0.5))
        str:setColor(ccc3(0xff,0xe4,0x00))
        str:setPosition(str_line:getContentSize().width*0.5+3,str_line:getContentSize().height*0.5)
        str_line:addChild(str)
       
        --自动抽取x次按钮
        local lotteryMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(270, 73),GetLocalizeStringBy("djn_1")..m_QuickRobInfo.ret.donum..GetLocalizeStringBy("djn_2"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
        lotteryMenuItem:setAnchorPoint(ccp(0.5,0))
        lotteryMenuItem:setPosition(ccp(bgSprite:getContentSize().width*0.5,25))
        lotteryMenuItem:registerScriptTapHandler(lotteryMenuCallBack)
        bgMenu:addChild(lotteryMenuItem)
        
    --战斗失败，不能抽奖
    else 
        local confirmMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1465"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
        confirmMenuItem:setAnchorPoint(ccp(0.5,0))
        confirmMenuItem:setPosition(ccp(bgSprite:getContentSize().width*0.5,25))
        confirmMenuItem:registerScriptTapHandler(closeMenuCallBack)
        bgMenu:addChild(confirmMenuItem)
    end

    --抢夺结果
    --local str_result_a = GetLocalizeStringBy("key_1946 ")
    --local str_result2 = GetLocalizeStringBy("key_3010 ")

    --抢夺*次这句话
    local tmp_height = 637
    local result_label_a = CCRenderLabel:create(GetLocalizeStringBy("key_1946"),g_sFontPangWa , 21, 1 ,ccc3(0x00,0x00,0x00), type_stroke)
    result_label_a:setColor(ccc3(0xff,0xe4,0x00))
    result_label_a:setAnchorPoint(ccp(1,0.5))
    --战斗胜利的时候。抢夺*次这句话要靠左，不然一行放不下容易写到板子外面
    if (m_QuickRobInfo.ret.reward.fragNum)then
        result_label_a:setPosition(ccp(70,tmp_height))
    else
        result_label_a:setPosition(ccp(110,tmp_height))
    end

    bgSprite:addChild(result_label_a)

    local result_label_b = CCRenderLabel:create(m_QuickRobInfo.ret.donum,g_sFontPangWa , 25, 1 ,ccc3(0x00,0x00,0x00), type_stroke)
    result_label_b:setColor(ccc3(0x00,0xff,0x18))
    result_label_b:setAnchorPoint(ccp(0,0.5))
    result_label_b:setPosition(ccp(result_label_a:getPositionX()+1,tmp_height))
    bgSprite:addChild(result_label_b)

    local result_label_c = CCRenderLabel:create(GetLocalizeStringBy("key_3010")..",",g_sFontPangWa , 21, 1 ,ccc3(0x00,0x00,0x00), type_stroke)
    result_label_c:setColor(ccc3(0xff,0xe4,0x00))
    result_label_c:setAnchorPoint(ccp(0,0.5))
    result_label_c:setPosition(ccp(result_label_b:getContentSize().width+result_label_b:getPositionX()+1,tmp_height))
    bgSprite:addChild(result_label_c)
     
    --抢到了碎片的情况
    if(m_QuickRobInfo.ret.reward.fragNum)then

        
        --创建页面上部结果展示抢夺结果的那句话

        local result_label_d = CCRenderLabel:create(GetLocalizeStringBy("key_2886"),g_sFontPangWa , 21, 1 ,ccc3(0x00,0x00,0x00), type_stroke)
        result_label_d:setColor(ccc3(0xff,0xe4,0x00))
        result_label_d:setAnchorPoint(ccp(1,0.5))
        result_label_d:setPosition(ccp(result_label_c:getContentSize().width+result_label_c:getPositionX()+20,tmp_height))
        bgSprite:addChild(result_label_d)
        
        local record = m_QuickRobInfo.ret.donum
        local result_label_e = CCRenderLabel:create(record,g_sFontPangWa , 25, 1 ,ccc3(0x00,0x00,0x00), type_stroke)
        result_label_e:setColor(ccc3(0x00,0xff,0x18))
        result_label_e:setAnchorPoint(ccp(0,0.5))
        result_label_e:setPosition(ccp(result_label_d:getPositionX()+1,tmp_height))
        bgSprite:addChild(result_label_e)
      
        local result_label_f = CCRenderLabel:create(GetLocalizeStringBy("djn_4"),g_sFontPangWa , 21, 1 ,ccc3(0x00,0x00,0x00), type_stroke)
        result_label_f:setColor(ccc3(0xff,0xe4,0x00))
        result_label_f:setAnchorPoint(ccp(0,0.5))
        result_label_f:setPosition(ccp(result_label_e:getContentSize().width+result_label_e:getPositionX()+1,tmp_height))
        bgSprite:addChild(result_label_f)

        --得到碎片名字
        require "db/DB_Item_treasure_fragment"
        local tableInfo = DB_Item_treasure_fragment.getDataById(QuickRobData.getItemid())
        local fragmentName = tableInfo.name
        --得到品质颜色
        require "script/ui/hero/HeroPublicLua"
        local nameColor = HeroPublicLua.getCCColorByStarLevel(tableInfo.quality)

        local result_label_g = CCRenderLabel:create(fragmentName,g_sFontPangWa , 30, 1 ,ccc3(0x00,0x00,0x00), type_stroke)
        result_label_g:setColor(nameColor)
        result_label_g:setAnchorPoint(ccp(0,0.5))
        result_label_g:setPosition(ccp(result_label_f:getContentSize().width+result_label_f:getPositionX()+1,tmp_height))
        bgSprite:addChild(result_label_g)

        local result_label_h = CCRenderLabel:create("!",g_sFontPangWa , 21, 1 ,ccc3(0x00,0x00,0x00), type_stroke)
        result_label_h:setColor(ccc3(0xff,0xe4,0x00))
        result_label_h:setAnchorPoint(ccp(0,0.5))
        result_label_h:setPosition(ccp(result_label_g:getContentSize().width+result_label_g:getPositionX()+1,tmp_height-2))
        bgSprite:addChild(result_label_h)

        local result_label_i = CCRenderLabel:create(GetLocalizeStringBy("djn_5"),g_sFontPangWa , 21, 1 ,ccc3(0x00,0x00,0x00), type_stroke)
        result_label_i:setColor(ccc3(0xff,0xe4,0x00))
        result_label_i:setAnchorPoint(ccp(0,0))
        result_label_i:setPosition(ccp(196,593))
        bgSprite:addChild(result_label_i)

    --没抢到碎片的情况
    else
  
        local failed_icon = CCSprite:create("images/treasure/failed.png")
        failed_icon:setAnchorPoint(ccp(0,0.5))
        failed_icon:setPosition(ccp(200,637))
        bgSprite:addChild(failed_icon)
    end
    
end

--[[
    @des    :创建tabelView
    @param  :
    @return :
--]]
function createRankTabView( ... )
    tableView_hight = secondBgSprite:getContentSize().height
    tableView_width = secondBgSprite:getContentSize().width
    -- 显示单元格背景的size
    local cell_bg_size = { width = tableView_width, height = 104 } 
    
    -- print_t(m_ranklistTabViewInfo)
    require "script/ui/treasure/QuickRobResultCell"
    --require "script/ui/main/MainScene"
    local handler = LuaEventHandler:create(function(fn, table, a1, a2)
        local r
        --local line_count = 0
        if (fn == "cellSize") then
            r = CCSizeMake(cell_bg_size.width , cell_bg_size.height)   
        elseif (fn == "cellAtIndex") then
            a2 = QuickRobResultCell.createCell(m_QuickRobInfo,a1+1)
            r=a2
        elseif (fn == "numberOfCells") then
            if(m_QuickRobInfo.ret.reward.fragNum ~= nil)then
                r = tonumber(m_QuickRobInfo.ret.donum) +1
            else
                r = tonumber(m_QuickRobInfo.ret.donum)
            end      
        elseif (fn == "cellTouched") then
            -- print ("a1: ", a1, ", a2: ", a2)
            -- print ("cellTouched, index is: ", a1:getIdx())
        elseif (fn == "scroll") then
            -- print ("scroll, index is: ")
        else
            -- print (fn, " event is not handled.")
        end
        return r
    end)

    m_rankTableView = LuaTableView:createWithHandler(handler, CCSizeMake(tableView_width,tableView_hight))
    m_rankTableView:setBounceable(true)
    m_rankTableView:setAnchorPoint(ccp(0, 0))
    m_rankTableView:setPosition(ccp(0,0))
    secondBgSprite:addChild(m_rankTableView)
    -- 设置单元格升序排列
    m_rankTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    -- 设置滑动列表的优先级
    m_rankTableView:setTouchPriority(_touchPriority-1)

    
end
--add by DJN 2015/5/5
--原来对于抢10次的金币和银币的发放是在奖励界面关闭的回调中，现在需求更改，改成只要抢完10次就更新奖励，不管玩家有没有打开奖励界面
function prizeReward( ... )
    local m_QuickRobInfo = QuickRobData.getQuickRobData() or {}
    QuickRobData.UpdateSilverInCard(m_QuickRobInfo.ret)
end
----------------------------------------入口函数
function showLayer(p_touchPriority,p_ZOrder)
    
        init()

        _touchPriority = p_touchPriority or -499
        _ZOrder = p_ZOrder or 999

        _bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
        _bgLayer:registerScriptHandler(onNodeEvent)
        local curScene = CCDirector:sharedDirector():getRunningScene()
        curScene:addChild(_bgLayer,_ZOrder)

        -- 得到列表数据
        m_QuickRobInfo = QuickRobData.getQuickRobData() or {}

        createBgUI()
        -- 创建tableview
        createRankTabView()  
        --更新奖励数据
        prizeReward()  

    return _bgLayer


end
