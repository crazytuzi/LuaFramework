--[[ 活动&福利 数据存储  ]]--
DATA_Activity = { }

-- 福利
--[[
    1 - 签到
    2 - 在线礼包
    3 - 等级礼包
    5 - 月卡
]]
-- 活动
--[[
    11 - 首次登陆
    12 - 登陆送奖励
    13 - 累计登陆送
    14 - 连续登陆送
    15 - 回归领奖
    16 - 指定时间段在线
    31 - 购买资源打折
    32 - 商城限购宝箱
    33 - 限购礼包
    51 - 原有系统掉落限时调整
    52 - 副本收益限时调整
    53 - 地图收益限时调整
    54 - 怪物收益限时调整
    55 - 任务收益限时调整
    71 - 副本累计参与送
    72 - 世界BOSS参与送
    73 - 熔炼N次返利
    74 - 熔炼指定部位返利
    75 - 强化N次返利
    76 - 强化指定部位返利
    78 - 组队击杀指定怪物
    79 - 任务送
    91 - 上交指定物品集齐送礼
    111 - 累计充值促销 
    112 - 首次充值x元赠送x奖励
    113 - 消费返利活动
    131 - 限时开活动本
    132 - 限时出任务
    133 - 限时开放地图
    151 - 在线时长奖励
    152 - 累计充值分段奖励
    153 - 累计副本次数
    154 - 累计击杀怪物数
    155 - 累计任务次数奖励
    156 - 角色等级分段奖励
]]
-- 盛典
--[[
    4 - 七日盛典
    6 - 半月盛典
]]


function DATA_Activity:clearData()
    DATA_Activity.clockFun = {}             --时钟函数
    DATA_Activity.activityData = {}         --所有活动数据
    DATA_Activity.giftData = {}             --所有福利数据
    DATA_Activity.firstData = { }            --首充按钮数据
    DATA_Activity.onLineData = { }            --在线礼包（玩法提醒用到在线时间数据）
    DATA_Activity.riteData = {}             --盛典数据
    DATA_Activity.payBackData = {}          --内测返利 按钮数据
    -- DATA_Activity.signData = {}             --每日签到 活动数据
    DATA_Activity.monthData = {}            --月卡 活动数据
    DATA_Activity.CData = {}                --当前选中活动数据
    DATA_Activity.activityLayer = nil
    DATA_Activity.rollData = {}             --跑马灯数据寄存
    DATA_Activity.isLoginShow = false       --是否登陆展示过

    self.m_callbacks = {};
end

function DATA_Activity:__init()
   	DATA_Activity:clearData()

    local timeFun = function()
        for k , v in pairs( DATA_Activity.clockFun ) do
            xpcall( v , function() DATA_Activity.clockFun[k] = nil end )
        end
    end
    cc.Director:getInstance():getScheduler():scheduleScriptFunc( timeFun , 1.0, false )
end

function DATA_Activity:__callback()
    package.loaded[ "src/layers/activity/template/temp" .. DATA_Activity.CData["modelID"] ] = nil
    local curLayer = require( "src/layers/activity/template/temp" .. DATA_Activity.CData["modelID"] ).new()
    return curLayer
end

function DATA_Activity:checkRed()
    -- local isNF_SIGN_IN = G_NFTRIGGER_NODE:isFuncOn(NF_SIGN_IN)
    --活动
    local mainActivityState = false
    if DATA_Activity.activityData and DATA_Activity.activityData.cellData then
        
        for k , v in pairs( DATA_Activity.activityData.cellData ) do
            if v.redState then
                mainActivityState = true
                DATA_Activity.activityData.redState = true
                break
            end
        end

        DATA_Activity.activityData.activityNum = 1              --默认激活
        for i = 1 , #DATA_Activity.activityData.cellData do
            local tempItem = DATA_Activity.activityData.cellData[i]
            if tempItem and tempItem[ "isActivity" ] == true then
                DATA_Activity.activityData["activityNum"] = i
            end
        end
    end
    if TOPBTNMG then TOPBTNMG:showRedMG("Activity", mainActivityState ) end   

    --七日盛典
    local weekListRed = false
    if DATA_Activity.riteData and DATA_Activity.riteData.cellData then
        for k,v in pairs(DATA_Activity.riteData.cellData) do
            if v.redState then
                weekListRed = true
                DATA_Activity.riteData.redState = true
                break
            end
        end
        DATA_Activity.riteData.activityNum = 1          --默认激活
        for i = 1,#DATA_Activity.riteData.cellData do
            local tempItem = DATA_Activity.riteData.cellData[i]
            if tempItem and tempItem["isActivity"] == true then
                DATA_Activity.riteData["activityNum"] = i
            end
        end
    end
    if TOPBTNMG then TOPBTNMG:showRedMG("Week", weekListRed ) end   

    --福利
    local mainActivityState = false
    if DATA_Activity.giftData and DATA_Activity.giftData.cellData then
        for k , v in pairs( DATA_Activity.giftData.cellData ) do
            if v.redState then
                mainActivityState = true
                DATA_Activity.giftData.redState = true
                break
            end
        end


        DATA_Activity.giftData.activityNum = 1              --默认激活
        for i = 1 , #DATA_Activity.giftData.cellData do
            local tempItem = DATA_Activity.giftData.cellData[i]
            if tempItem and tempItem[ "isActivity" ] == true then
                DATA_Activity.giftData["activityNum"] = i
            end
        end
    end


    if TOPBTNMG then TOPBTNMG:showRedMG("Gift", mainActivityState ) end    
   
    local isShowFirstPay = tablenums(DATA_Activity.firstData)>0 
    if TOPBTNMG and TOPBTNMG.firstPayBtn then TOPBTNMG.firstPayBtn:setVisible( isShowFirstPay ) end   --首充是否展示
    -- local isShowWeekList = tablenums(DATA_Activity.weekList)>0
    -- if TOPBTNMG then TOPBTNMG:showRedMG("Week", weekListRed ) end

    if TOPBTNMG and TOPBTNMG.firstPayBtn1 then TOPBTNMG.firstPayBtn1:setVisible( not isShowFirstPay ) end   --充值按钮否展示
    if TOPBTNMG and TOPBTNMG.payBackBtn then TOPBTNMG.payBackBtn:setVisible( tablenums(DATA_Activity.payBackData)>0 ) end   --内测返利 是否展示

    if DATA_Activity.activityLayer then DATA_Activity.activityLayer:refreshDataFun() end
    if DATA_Activity.giftLayer and DATA_Activity.giftLayer["refreshDataFun"] then DATA_Activity.giftLayer:refreshDataFun() end
   
end


--刷新icon状态
--[[
    tmp.activityName = activity[3]      -- 活动名称
    tmp.redDot = activity[4]            -- 小红点提示
    tmp.index = activity[5]             -- 
    tmp.order = activity[6]             -- 限时顺序
    tmp.labelType = activity[7]         
    tmp.leftLabel = activity[8]         
    table.insert(data, tmp)

    list.tab = tab                      -- 活动入口ID
    list.data = data
    table.insert(lists, list)
]]
function DATA_Activity:__refreshIconState( buff )
    print("[DATA_Activity:__refreshIconState]");
    DATA_Activity.firstData = {}
    DATA_Activity.onLineData = {}
    DATA_Activity.payBackData = {}
    DATA_Activity.activityData = {}
    DATA_Activity.giftData = {}
    DATA_Activity.riteData = {}

    -- DATA_Activity.signData = {}
    DATA_Activity.monthData = {}
    local t = g_msgHandlerInst:convertBufferToTable("ActivityListRet", buff) 
    local list = t.list
    local tab = {}
    local isWeekListExist,m4,m6 = false,0,0

    -- 获取当前活动记录
    local dateStr = os.date( "%x" , os.time() );
    local recordActivityDate = getLocalRecordByKey( 2 , "recordActivityDate" .. tostring( userInfo.currRoleStaticId or 0 )  )
    recordActivityDate = recordActivityDate or "";
    local isNeedRecordDate = false;
    
    for i = 1 , #list do
        tab[i] = { }
        tab[i][ "tableID" ] = list[i].tab   --标签ID
        local data = list[i].data

        local tempTab = {}
        for j = 1 , #data do

            local temp = {}
            temp["modelID"] =  data[j].modelID                      -- 模板ID
            temp["activityID"] =  data[j].activityID                -- 活动ID
            temp["key"] =  ""                                       -- 活动KEY
            temp["desc"] =  data[j].activityName                    -- 活动名称
            temp["redState"] =  data[j].redDot                      -- 状态 小红点提示

            -- 每天第一次上线，所有活动都有小红点
            if recordActivityDate ~= dateStr then
                isNeedRecordDate = true;
                
                local tmpRecord = getLocalRecordByKey(1, "activityRed" .. data[j].activityID, 0);
                if tmpRecord ~= 2 then
                    setLocalRecordByKey(1, "activityRed" .. data[j].activityID, 1);
                end
            end
            
            temp["isActivity"] = data[j].index                      -- 活动是否设置锚点 是否激活( true 激活 false不激活 )
            temp["order"] = data[j].order;                          -- 显示顺序 小的在前
            temp["lableType"] = data[j].lableType;                  -- 活动标签页类型: 推荐活动(0), 超值特权(1), 游戏公告(2)
            temp["leftLabel"] = data[j].leftLabel;                  -- 活动左上角标签: 0-默认无标签, 1-限时(黄色), 2-火爆(红色), 3-最新(绿色), 4-免费(紫色)
            temp["link"] = data[j].link;                            -- 立即前往的链接
            temp["pic"] = data[j].pic;                              -- 活动标签按钮图片

            temp["callback"] = function()  
                                        print( "modelID      ............ " .. temp["modelID"] )
                                        DATA_Activity.CData = temp 
                                        return DATA_Activity:__callback()
                                    end
            if temp["modelID"] == 112 then    -- 首充另外处理
                DATA_Activity.firstData = temp
            elseif temp["modelID"] == 1  then    -- 每日签到
                if not ( G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_SIGN_IN) ) then
                    temp["redState"] =  false
                end
                tempTab[ #tempTab + 1 ] = temp
            elseif temp["modelID"] == 2  then    -- 在线礼包
                DATA_Activity.onLineData = temp
                tempTab[ #tempTab + 1 ] = temp
            elseif temp["modelID"] == 5 then    --月卡活动
                DATA_Activity.monthData = temp
                tempTab[ #tempTab + 1 ] = temp
            elseif temp["modelID"] == 12 and temp["redState"] == true then    --内测返利另外处理
                DATA_Activity.payBackData  = temp 
            else
                tempTab[ #tempTab + 1 ] = temp
            end 
            if temp["modelID"] == 6 then
                if TOPBTNMG then
                    -- TOPBTNMG:showMG("Week" , true)
                    local wb = TOPBTNMG:getBtn( "Week" )
                    wb:setVisible(true)
                    local sevenPic = getSpriteFrame("mainui/topbtns/21.png")
                    if sevenPic then
                        wb:setSpriteFrame(sevenPic)
                    else                    
                        cc.SpriteFrameCache:getInstance():addSpriteFramesWithFileEx("res/mainui/mainui@0.plist", false, false)
                        wb:setSpriteFrame(getSpriteFrame("mainui/topbtns/21.png"))
                    end                    
                    isWeekListExist = true
                end
                m6 = 1
            elseif temp["modelID"] == 4 then
                isWeekListExist = true
                m4 = 1
            end
        end        
        tab[i][ "cellData" ] = tempTab
        tab[i][ "redState" ] = false 
        tab[i][ "callback" ] = function() end
        tab[i][ "key" ] = tab[i][ "tableID" ]
        if tab[i][ "tableID" ] == 0 then
            DATA_Activity.activityData = tab[i]
        elseif tab[i][ "tableID" ] == 1 then
            DATA_Activity.giftData = tab[i]
        elseif tab[i]["tableID"] == 2 then
            DATA_Activity.riteData = tab[i]
        end        
    end
    DATA_Activity:addStatic()               --添加前端配置    
    DATA_Activity:checkRed()                --红点处理

    if isNeedRecordDate then
        setLocalRecordByKey( 2 , "recordActivityDate" .. tostring( userInfo.currRoleStaticId or 0 )  , dateStr );
    end
    if TOPBTNMG then
        if not isWeekListExist then
            local weekBtn =  TOPBTNMG:getBtn( "Week" )
            if weekBtn then
                weekBtn:setVisible(false)
            end
            -- TOPBTNMG:showMG("Week",false)
        else
            -- local weekBtn =  TOPBTNMG:getBtn( "Week" )
            -- if weekBtn then
            --     weekBtn:setVisible(true)
            -- end
            TOPBTNMG:showMG("Week",true)
        end
    end
    if m4 == 0 and m6 == 1 then
        if DATA_Activity.riteLayer then
            DATA_Activity.riteLayer:changePage(2)

        end
    end
end


--打开对应活动界面
function DATA_Activity:openID( _targerID )
    if _targerID == 5 then  --月卡
        __GotoTarget( { ru = "a25" } ) 
    end
end

function DATA_Activity:addStatic()
    --重新添加数据 便于刷新
    -- local celarCfg = { -5 , -6 , -7 , }
    local celarCfg = { -5 , -6 , }
    DATA_Activity.giftData["cellData"] = DATA_Activity.giftData["cellData"] or {}
    for key , value in pairs( celarCfg ) do
        for k , v in pairs(DATA_Activity.giftData["cellData"]) do
            if v.modelID == value then
               table.remove(DATA_Activity.giftData["cellData"] ,k)
               break
            end
        end
    end


    --激活码( 暂时屏蔽 )
    -- if tonumber( g_Channel_tab and  g_Channel_tab.adChannel or 0 ) ~= 2 then
    --     local tempItem = nil
    --     tempItem = { modelID = -6 , activityID = -1 , key = "activation_Code" , isActivity = false , callback = function() DATA_Activity.CData = tempItem return DATA_Activity:__callback() end , redState = false , desc = game.getStrByKey("title_jhm") }
    --     DATA_Activity.giftData["cellData"][ #DATA_Activity.giftData["cellData"] + 1 ] = tempItem
    -- end


end

--活动数据请求
function DATA_Activity:formatData( buff )
    local t = g_msgHandlerInst:convertBufferToTable("ActivityRet", buff) 
    local modelID =  t.modelID      --模板ID
    local activityID =  t.activityID   --活动ID
    if not DATA_Activity.CData["modelID"] then return end  
    if DATA_Activity.CData["modelID"] ~= modelID or DATA_Activity.CData["activityID"] ~= activityID then return end

    local data = { }
    
    data.contentText = t.desc
    --活动时间
    data.startTick = t.startTick;
    data.endTick = t.endTick;
    
    print("t.startTick=" .. t.startTick);
    print("t.endTick=" .. t.endTick);
    print("modelID =" .. modelID .. " activityID=" .. activityID);

    if DATA_Activity.activityLayer and data.contentText then
        -- 格式化时间
        local function formatTimeStr(time)
            local tmpStr = "";
            local tmpTime = os.date("*t", time);
            if tmpTime ~= nil then
                tmpStr = tmpTime.year .. ".";
                if tmpTime.month > 9 then
                    tmpStr = tmpStr .. tmpTime.month .. ".";
                else
                    tmpStr = tmpStr .. "0" .. tmpTime.month .. ".";
                end

                if tmpTime.day > 9 then
                    tmpStr = tmpStr .. tmpTime.day .. " ";
                else
                    tmpStr = tmpStr .. "0" .. tmpTime.day .. " ";
                end

                if tmpTime.hour > 9 then
                    tmpStr = tmpStr .. tmpTime.hour .. ":";
                else
                    tmpStr = tmpStr .. "0" .. tmpTime.hour .. ":";
                end

                if tmpTime.min > 9 then
                    tmpStr = tmpStr .. tmpTime.min .. ":";
                else
                    tmpStr = tmpStr .. "0" .. tmpTime.min .. ":";
                end

                if tmpTime.sec > 9 then
                    tmpStr = tmpStr .. tmpTime.sec;
                else
                    tmpStr = tmpStr .. "0" .. tmpTime.sec;
                end
            end

            return tmpStr;
        end

        local tmpTimeStr = formatTimeStr(data.startTick) .. " " .. game.getStrByKey("horizontal_line") .. " " ..  formatTimeStr(data.endTick);
        DATA_Activity.activityLayer.timeText:setString( tmpTimeStr )

        DATA_Activity.activityLayer.setContentText( data.contentText )
    end


    switchCfg = {
        --签到
        ["1"] = function() 
            local sign = t.sign

            data.month = sign.month
            data.day = sign.day 
            data.totalDay = #sign.signInData
            local awards= {}
            for i = 1 , 31 do
                local cfg = getConfigItemByKeys( "SignInDB" , { "q_month" ,"q_day" } , { 12 , i } ) 
                if cfg then
                    awards[i] = {}
                    awards[i]["id"] = cfg.q_itemID            --奖励ID
                    awards[i]["num"] = cfg.q_num           --奖励个数
                    awards[i]["showBind"] = true;
                    awards[i]["isBind"] = cfg.q_bind       --绑定(1绑定0不绑定)
                end
            end
            data.awardData = awards
            -- data.awardData = FORMAT_AWARDS( sign.signInData )
            data.hadDay = sign.signDay
            data.isGet = sign.isToday
            data.addRegDay = sign.reSignDay
            data.cost = sign.reSignCount
        end ,
        --在线礼包
        ["2"] = function() 
            local online = t.online
            data.list = {}
            for i = 1 , #online do
                data.list[i] = {}
                data.list[i].index = online[i].time
                data.list[i].time = online[i].time       --领取条件（在线多少分钟领取）
                data.list[i].sec =  online[i].endTime        --结束剩余时间（秒）
                data.list[i].state = online[i].status     -- 达成状态(0:可领取 1:未达成 2:已领取)
                data.list[i].awards = FORMAT_AWARDS( online[i].reward )
            end
        end,
        --等级礼包
        ["3"] = function() 
            local level = t.level
            data.list = {}
            for i = 1 , #level do
                local itemData = {}      
                itemData.index = i                   
                itemData.level = level[i].level          --达成等级
                itemData.state = level[i].status         --达成状态(0:可领取 1:未达成 2:已领取)
                itemData.awards = FORMAT_AWARDS( level[i].reward )
                data.list[i] = itemData
            end
        end,
        -- 七日盛典
        ["4"] = function() 
            -- local sevenLogin = t.sevenLogin
            -- data.totalDayNum = #sevenLogin       --活动天数
            -- data.list = {}
            -- for i = 1 , data.totalDayNum do
            --     data.loginDayNum = sevenLogin[i].login       --已登录天数
            --     local itemData = {}     --单条数据
            --     itemData.index = sevenLogin[i].day         --第几天
            --     itemData.awards = FORMAT_AWARDS( sevenLogin[i].reward )
            --     itemData.state = sevenLogin[i].status    --Int (0可领取，1不可领取，2已领取)
            --     data.list[i] = itemData
            -- end
            -- if data.loginDayNum == 0 then data.loginDayNum = 1 end
            local weekTab = t.sevenFestival
            data.list = {}
            --for k,v in pairs(weekTab) do
            for i=1,#weekTab do
                local itemData = {}
                itemData.index = weekTab[i].index
                itemData.status = weekTab[i].status
                itemData.prog = weekTab[i].prog
                itemData.awards = FORMAT_AWARDS(weekTab[i].reward)
                data.list[i] = itemData
            end            
        end ,
        ["5"] = function() 
            --月卡
            local monthCard = t.monthCard
            data.dayNum = monthCard.surplus    --月卡剩余天数（0代表没有充值月卡或月卡已用完）
            data.state = monthCard.status    --(0可领取，1未达成，2已领取)
            data.awards = FORMAT_AWARDS( monthCard.reward )

        end ,
        ["6"] = function()
            --半月盛典
            local weekTab = t.sevenFestival
            data.list = {}
            --for k,v in pairs(weekTab) do
            for i=1,#weekTab do
                local itemData = {}
                itemData.index = weekTab[i].index
                itemData.status = weekTab[i].status
                itemData.prog = weekTab[i].prog
                itemData.awards = FORMAT_AWARDS(weekTab[i].reward)
                data.list[i] = itemData
            end            
        end,
        -------------------------------------------------------------------------------
        -- 首次登陆
        ["11"] = function() 
            data.awards = FORMAT_AWARDS(t.model1.reward);
            data.state = t.model1.status;

            self:SetDoneActivity(data.state, activityID);
            self:LocalChangeRedDot(data.state, activityID);
        end ,
        -- 登陆送奖励
        ["12"] = function() 
            data.awards = FORMAT_AWARDS(t.model1.reward);
            data.state = t.model1.status;

            self:SetDoneActivity(data.state, activityID);
            self:LocalChangeRedDot(data.state, activityID);
        end ,
        -- 累计登陆送
        ["13"] = function()
            data.awards = FORMAT_AWARDS(t.model1.reward);
            data.state = t.model1.status;
            data.arg1 = t.model1.arg1;
            data.progress = t.model1.progress;

            self:SetDoneActivity(data.state, activityID);
            self:LocalChangeRedDot(data.state, activityID);
        end,
        -- 连续登陆送
        ["14"] = function()
            data.awards = FORMAT_AWARDS(t.model1.reward);
            data.state = t.model1.status;
            data.arg1 = t.model1.arg1;
            data.progress = t.model1.progress;

            self:SetDoneActivity(data.state, activityID);
            self:LocalChangeRedDot(data.state, activityID);
        end,
        -- 回归领奖
        ["15"] = function() 
        end,
        -- 指定时间段在线
        ["16"] = function()
            data.awards = FORMAT_AWARDS(t.model1.reward);
            data.state = t.model1.status;
            data.startTime = t.model1.cycleStartTime;
            data.endTime = t.model1.cycleEndTime;

            self:SetDoneActivity(data.state, activityID);
            self:LocalChangeRedDot(data.state, activityID);
        end,
        -- 购买资源打折
        ["31"] = function()
            
            local purchase = t.model2;
            data.list = {};
            for i = 1, #purchase do
                local itemData = {};
                itemData.index = purchase[i].index;                     -- 组id
                itemData.state = purchase[i].status;                    -- 达成状态(0:可领取 1:未达成 2:已领取)
                itemData.groupName = purchase[i].groupName;             -- 打折包名字
                itemData.oldType = purchase[i].oldType;                 -- 原价类型(1元宝2绑元3金币)
                itemData.oldPrice = purchase[i].oldPrice;               -- 原价
                itemData.disType = purchase[i].disType;                 -- 现价类型
                itemData.disPrice = purchase[i].disPrice;               -- 现价
                itemData.disDesc = purchase[i].disDesc;                 -- 折扣了多少
                itemData.awards = FORMAT_AWARDS(purchase[i].reward);

                data.list[i] = itemData;
            end

            self:SetDoneActivity(data.list, activityID);
            self:LocalChangeRedDot(data.list, activityID);
            
            --[[-- 测试数据
            data.list = {};
            for i = 1, 5 do
                local itemData = {};
                itemData.index = i;                     -- 组id
                itemData.state = i%2;                   -- 达成状态(0:可领取 1:未达成 2:已领取)
                itemData.groupName = "白金特惠礼包";             -- 打折包名字
                itemData.oldType = i%3+1;                 -- 原价类型(1元宝2绑元3金币)
                itemData.oldPrice = 388+i*5;               -- 原价
                itemData.disType = i%3+1;                 -- 现价类型
                itemData.disPrice = 188+i*5;               -- 现价
                itemData.disDesc = "zhekoule89yuan";                 -- 折扣了多少
                itemData.awards = {};
                for i=1, 5 do
                    itemData.awards[i] = {};
                    itemData.awards[i].showBind = true;
                    itemData.awards[i].isBind = (i%2==0);
                    itemData.awards[i].num = 5;
                    itemData.awards[i].streng = 0;
                    itemData.awards[i].time = 0;
                    itemData.awards[i].id = 1304;
                end

                data.list[i] = itemData;
            end
            ]]
        end , 
        -- 商城限购宝箱
        ["32"] = function() 
        end,
        -- 限购礼包
        ["33"] = function() 
        end,
        -- 原有系统掉落限时调整
        ["51"] = function() 
        end,
        -- 副本收益限时调整
        ["52"] = function() 
            --self:SetDoneActivity(2, activityID);
            self:LocalChangeRedDot(2, activityID);
        end,
        -- 地图收益限时调整
        ["53"] = function() 
        end,
        -- 怪物收益限时调整
        ["54"] = function()
            --self:SetDoneActivity(2, activityID);
            self:LocalChangeRedDot(2, activityID);
        end,
        -- 任务收益限时调整
        ["55"] = function()
            --self:SetDoneActivity(2, activityID);
            self:LocalChangeRedDot(2, activityID);
        end,
        -- 副本累计参与送
        ["71"] = function()
            local joinNums = t.model8;
            data.list = {}
            for i = 1 , #joinNums do
                local itemData = {}      
                itemData.index = i;                   
                itemData.level = joinNums[i].index;            -- 参与次数
                itemData.state = joinNums[i].status;           -- 达成状态(0:可领取 1:未达成 2:已领取)
                itemData.progress = joinNums[i].progress;      -- 当前进度
                itemData.awards = FORMAT_AWARDS( joinNums[i].reward )
                data.list[i] = itemData;
            end

            self:SetDoneActivity(data.list, activityID);
            self:LocalChangeRedDot(data.list, activityID);
        end,
        -- 世界BOSS参与送
        ["72"] = function()
            local joinNums = t.model8;
            data.list = {}
            for i = 1 , #joinNums do
                local itemData = {}      
                itemData.index = i;                   
                itemData.level = joinNums[i].index;            -- 参与次数
                itemData.state = joinNums[i].status;           -- 达成状态(0:可领取 1:未达成 2:已领取)
                itemData.progress = joinNums[i].progress;      -- 当前进度
                itemData.awards = FORMAT_AWARDS( joinNums[i].reward )
                data.list[i] = itemData;
            end

            self:SetDoneActivity(data.list, activityID);
            self:LocalChangeRedDot(data.list, activityID);
        end,
        -- 熔炼N次返利
        ["73"] = function()
            local monsters = t.model8;
            data.list = {}
            for i = 1 , #monsters do
                local itemData = {}      
                itemData.index = i;                   
                itemData.level = monsters[i].index;             -- 熔炼N次
                itemData.state = monsters[i].status;               -- 达成状态(0:可领取 1:未达成 2:已领取)
                itemData.progress = monsters[i].progress;          -- 当前进度
                itemData.awards = FORMAT_AWARDS( monsters[i].reward )
                data.list[i] = itemData;
            end

            self:SetDoneActivity(data.list, activityID);
            self:LocalChangeRedDot(data.list, activityID);
        end,
        -- 熔炼指定部位返利
        ["74"] = function()
            local monsters = t.model8;
            data.list = {}
            for i = 1 , #monsters do
                local itemData = {}      
                itemData.index = i;                   
                itemData.level = monsters[i].index;             -- 熔炼N次
                itemData.state = monsters[i].status;               -- 达成状态(0:可领取 1:未达成 2:已领取)
                itemData.progress = monsters[i].progress;          -- 当前进度
                itemData.awards = FORMAT_AWARDS( monsters[i].reward )
                data.list[i] = itemData;
            end

            self:SetDoneActivity(data.list, activityID);
            self:LocalChangeRedDot(data.list, activityID);
        end,
        -- 强化N次返利
        ["75"] = function()
            local monsters = t.model8;
            data.list = {}
            for i = 1 , #monsters do
                local itemData = {}      
                itemData.index = i;                   
                itemData.level = monsters[i].index;             -- 强化N次
                itemData.state = monsters[i].status;               -- 达成状态(0:可领取 1:未达成 2:已领取)
                itemData.progress = monsters[i].progress;          -- 当前进度
                itemData.awards = FORMAT_AWARDS( monsters[i].reward )
                data.list[i] = itemData;
            end

            self:SetDoneActivity(data.list, activityID);
            self:LocalChangeRedDot(data.list, activityID);
        end,
        -- 强化指定部位返利
        ["76"] = function() 
            local monsters = t.model8;
            data.list = {}
            for i = 1 , #monsters do
                local itemData = {}      
                itemData.index = i;                   
                itemData.level = monsters[i].index;             -- 强化N次
                itemData.state = monsters[i].status;               -- 达成状态(0:可领取 1:未达成 2:已领取)
                itemData.progress = monsters[i].progress;          -- 当前进度
                itemData.awards = FORMAT_AWARDS( monsters[i].reward )
                data.list[i] = itemData;
            end

            self:SetDoneActivity(data.list, activityID);
            self:LocalChangeRedDot(data.list, activityID);
        end,
        -- 组队击杀指定怪物
        ["77"] = function()
            local monsters = t.model8;
            data.list = {}
            for i = 1 , #monsters do
                local itemData = {}      
                itemData.index = i;                   
                itemData.level = monsters[i].index;             -- 组队击杀怪物几只
                itemData.state = monsters[i].status;               -- 达成状态(0:可领取 1:未达成 2:已领取)
                itemData.progress = monsters[i].progress;          -- 当前进度
                itemData.awards = FORMAT_AWARDS( monsters[i].reward )
                data.list[i] = itemData;
            end

            self:SetDoneActivity(data.list, activityID);
            self:LocalChangeRedDot(data.list, activityID);
        end,
        -- 任务送
        ["78"] = function()
            local monsters = t.model8;
            data.list = {}
            for i = 1 , #monsters do
                local itemData = {}      
                itemData.index = i;                   
                itemData.level = monsters[i].index;             -- 完成 诏令、悬赏 N次
                itemData.state = monsters[i].status;               -- 达成状态(0:可领取 1:未达成 2:已领取)
                itemData.progress = monsters[i].progress;          -- 当前进度
                itemData.awards = FORMAT_AWARDS( monsters[i].reward )
                data.list[i] = itemData;
            end

            self:SetDoneActivity(data.list, activityID);
            self:LocalChangeRedDot(data.list, activityID);
        end,
        -- 洗练N次返利
        ["79"] = function()
            local monsters = t.model8;
            data.list = {}
            for i = 1 , #monsters do
                local itemData = {}      
                itemData.index = i;                   
                itemData.level = monsters[i].index;             -- 洗练N次
                itemData.state = monsters[i].status;               -- 达成状态(0:可领取 1:未达成 2:已领取)
                itemData.progress = monsters[i].progress;          -- 当前进度
                itemData.awards = FORMAT_AWARDS( monsters[i].reward )
                data.list[i] = itemData;
            end

            self:SetDoneActivity(data.list, activityID);
            self:LocalChangeRedDot(data.list, activityID);
        end,
        -- 洗练指定部位
        ["80"] = function()
            local monsters = t.model8;
            data.list = {}
            for i = 1 , #monsters do
                local itemData = {}      
                itemData.index = i;                   
                itemData.level = monsters[i].index;             -- 洗练指定部位N次
                itemData.state = monsters[i].status;               -- 达成状态(0:可领取 1:未达成 2:已领取)
                itemData.progress = monsters[i].progress;          -- 当前进度
                itemData.awards = FORMAT_AWARDS( monsters[i].reward )
                data.list[i] = itemData;
            end

            self:SetDoneActivity(data.list, activityID);
            self:LocalChangeRedDot(data.list, activityID);
        end,
        -- 上交指定物品集齐送礼
        ["91"] = function()
            local exchange = t.model5;
            data.list = {};
            for i = 1, #exchange do
                local itemData = {}
                itemData.index = exchange[i].index;                     -- 组id
                itemData.state = exchange[i].status;                    -- 达成状态(0:可兑换 1:未达成 2:已领取)
                itemData.needs = FORMAT_AWARDS(exchange[i].need)
                itemData.rewards = FORMAT_AWARDS(exchange[i].reward)
                data.list[i] = itemData;
            end

            self:SetDoneActivity(data.list, activityID);
            self:LocalChangeRedDot(data.list, activityID);
        end,
        -- 累计充值促销
        ["111"] = function()
            data.awards = FORMAT_AWARDS( t.model6.reward )
            data.state = t.model6.status    --Int (0可领取，1不可领取，2已领取)   
            data.money = t.model6.arg1;
            data.progress = t.model6.progress;

            self:SetDoneActivity(data.state, activityID);
            self:LocalChangeRedDot(data.state, activityID);
        end ,
        -- 首次充值x元赠送x奖励
        ["112"] = function() 
            local firstCharge = t.model6
            data.awards = FORMAT_AWARDS( firstCharge.reward )
            data.state = firstCharge.status    --Int (0可领取，1不可领取，2已领取)   
            data.money = firstCharge.arg1; 
            
            self:SetDoneActivity(data.state, activityID);   
            self:LocalChangeRedDot(data.state, activityID);   
        end, 
        -- 消费返利活动
        ["113"] = function() 
            data.awards = FORMAT_AWARDS( t.model6.reward )
            data.state = t.model6.status    --Int (0可领取，1不可领取，2已领取)   
            data.money = t.model6.arg1;
            data.progress = t.model6.progress;

            self:SetDoneActivity(data.state, activityID);
            self:LocalChangeRedDot(data.state, activityID);
        end,
        -- 限时开活动本
        ["131"] = function() 
        end,
        -- 限时出任务
        ["132"] = function() 
        end,
        -- 限时开放地图
        ["133"] = function()
        end,
        -- 在线时长奖励
        ["151"] = function()
            local time = t.model8;
            data.list = {}
            for i = 1 , #time do
                local itemData = {}      
                itemData.index = i;              
                itemData.level = time[i].index;              --达成时长[s]
                itemData.state = time[i].status;            --达成状态(0:可领取 1:未达成 2:已领取)
                if i == 1 then
                    data.onlineTime = time[i].progress;     -- 当前进度
                end
                itemData.awards = FORMAT_AWARDS( time[i].reward )
                data.list[i] = itemData;
            end

            self:SetDoneActivity(data.list, activityID);
            self:LocalChangeRedDot(data.list, activityID);
        end,
        -- 累计充值分段奖励
        ["152"] = function() 
            local money = t.model8;
            data.list = {}
            for i = 1 , #money do
                local itemData = {}      
                itemData.index = i;                   
                itemData.level = money[i].index;            -- 达成充值金额
                itemData.state = money[i].status;           -- 达成状态(0:可领取 1:未达成 2:已领取)
                itemData.progress = money[i].progress;      -- 当前进度
                itemData.awards = FORMAT_AWARDS( money[i].reward )
                data.list[i] = itemData;
            end

            self:SetDoneActivity(data.list, activityID);
            self:LocalChangeRedDot(data.list, activityID);
        end,
        -- 累计副本次数
        ["153"] = function() 
        end,
        -- 累计击杀怪物数
        ["154"] = function()
            local monsters = t.model8;
            data.list = {}
            for i = 1 , #monsters do
                local itemData = {}      
                itemData.index = i;                   
                itemData.level = monsters[i].index;             -- 击杀怪物次数
                itemData.state = monsters[i].status;               -- 达成状态(0:可领取 1:未达成 2:已领取)
                itemData.progress = monsters[i].progress;          -- 当前进度
                itemData.awards = FORMAT_AWARDS( monsters[i].reward )
                data.list[i] = itemData;
            end

            self:SetDoneActivity(data.list, activityID);
            self:LocalChangeRedDot(data.list, activityID);
        end,
        -- 累计任务次数奖励
        ["155"] = function()
            local rank = t.rank
            data.listData = {}
            for m = 1, #rank do
                local dataTemp = {}
                dataTemp.listSequence = rank[m].tab
                dataTemp.listNumber = rank[m].rankID
                dataTemp.first = rank[m].nameNo1
                dataTemp.second = rank[m].nameNo2
                dataTemp.third = rank[m].nameNo3
                dataTemp.myRank = rank[m].selfRank
                dataTemp.downTime = rank[m].leftTime      --剩余时间(单位秒)

                local record = rank[m].record
                dataTemp.list = {}
                for i = 1 , #record do                                                  
                    local itemData = {}
                    itemData.lv = record[i].level --等级
                    itemData.index = i           --索引
                  
                    itemData.status = record[i].status --领取状态(0可领取，1不可领取，2已领取)
                    itemData.awards = FORMAT_AWARDS( record[i].reward )

                    dataTemp.list[i] = itemData
                end
                data.listData[m] = dataTemp
            end                          

        end,
        -- 角色等级分段奖励
        ["156"] = function() 
            local level = t.model8;
            data.list = {}
            for i = 1 , #level do
                local itemData = {}      
                itemData.index = i;                   
                itemData.level = level[i].index;            --达成等级
                itemData.state = level[i].status;           --达成状态(0:可领取 1:未达成 2:已领取)
                itemData.awards = FORMAT_AWARDS( level[i].reward )
                data.list[i] = itemData;
            end

            self:SetDoneActivity(data.list, activityID);
            self:LocalChangeRedDot(data.list, activityID);
        end,
        
    }
    
    switchCfg[ modelID .. "" ]()
    
    local needSortID = {
        ["2"] = true ,
        ["3"] = true ,
        ["31"] = true,
        ["71"] = true,
        ["72"] = true,
        ["73"] = true,
        ["74"] = true,
        ["75"] = true,
        ["76"] = true,
        ["77"] = true,
        ["78"] = true,
        ["79"] = true,
        ["80"] = true,
        ["151"] = true,
        ["152"] = true,
        ["154"] = true,
        ["156"] = true,
        ["功能达标"] = true
    }
    if needSortID[ modelID .. ""] then
    	table.sort( data.list , function( a , b )
    		        local _bool = false
			        if a["state"] < b["state"] then
			            _bool = true
			        elseif a["state"] == b["state"] then
                        -- 分段 level 控制顺序
                        if (modelID == 3) or (modelID == 71) or (modelID == 72) or (modelID == 73) or (modelID == 74) or (modelID == 75) or (modelID == 76) or
                            (modelID == 77) or (modelID == 78) or (modelID == 79) or (modelID == 80) or
                            (modelID == 151) or (modelID == 152) or (modelID == 154) or (modelID == 156) then
                            if a["level"] < b["level"] then
			        		    _bool = true
			        	    end
                        else
			        	    if a["index"] < b["index"] then
			        		    _bool = true
			        	    end
                        end
			        end
			        return _bool
    		end )
    end

    DATA_Activity.CData["netData"] = data
end

function DATA_Activity:LocalChangeRedDot(param, id)
    if self.activityData and self.activityData.cellData and #(self.activityData.cellData) > 0 then
        for i=1, #(self.activityData.cellData) do
            if id == self.activityData.cellData[i].activityID then
                -- 针对新添加的活动，去除红点
                if self.activityData.cellData[i].redState == true then
                    local newActivityRemoveRedDot = true;
                    if type(param) == "table" then
                        for i=1, #param do
                            if param[i].state == 0 then
                                newActivityRemoveRedDot = false;
                                break;
                            end
                        end
                    else
                        if param == 0 then
                            newActivityRemoveRedDot = false;
                        end
                    end

                    if newActivityRemoveRedDot then
                        self.activityData.cellData[i].redState = false;

                        if DATA_Activity.activityLayer then
                            if DATA_Activity.activityLayer.UpdateSelectCell then
                                DATA_Activity.activityLayer:UpdateSelectCell();
                            end
                        end

                        -- 主界面的小红点也需要去除
                        local mainActivityState = false
                        if self.activityData and self.activityData.cellData then
        
                            for k , v in pairs( self.activityData.cellData ) do
                                if v.redState then
                                    mainActivityState = true
                                    self.activityData.redState = true
                                    break
                                end
                            end
                        end
                        if TOPBTNMG then TOPBTNMG:showRedMG("Activity", mainActivityState ) end
                    end
                end

                ------------------------------
                break;
            end
        end
    end
end

function DATA_Activity:SetDoneActivity(param, id)
    if type(param) == "table" then
        local isActivityDone = true;
        for i=1, #param do
            if param[i].state < 2 then
                isActivityDone = false;
                break;
            end
        end
        
        if isActivityDone then
            local tmpRecord = getLocalRecordByKey(1, "activityRed" .. id, 0);
            if tmpRecord ~= 2 then
                setLocalRecordByKey(1, "activityRed" .. id, 2);
            end
        end
    else
        if param == 2 then
            local tmpRecord = getLocalRecordByKey(1, "activityRed" .. id, 0);
            if tmpRecord ~= 2 then
                setLocalRecordByKey(1, "activityRed" .. id, 2);
            end
        end
    end
end

-- 页签排序
function DATA_Activity:SortActivityPage()
    if self.activityData and self.activityData.cellData and #(self.activityData.cellData) > 0 then
        -- 刷新数据时, 排序
        --local tmpDoneA = DATA_Activity.m_doneActivityId[a.activityID];
        --local tmpDoneB = DATA_Activity.m_doneActivityId[b.activityID];

        local sortFunc = function(cellData)
            -- 冒泡排序, 弃用lua自带的排序
            local len = #(cellData);
            for i=1, len do
                for j=i, len do
                    if cellData[i].order > cellData[j].order then
                        local temp = cellData[i];
                        cellData[i] = cellData[j];
                        cellData[j] = temp;
                    end
                end
            end
	    end

        sortFunc(self.activityData.cellData);
    end
end

--活动数据请求
function DATA_Activity:readData( callback ,idx)
    local function saveDataFun( buff )
        DATA_Activity.CData = DATA_Activity.CData or {}
        DATA_Activity.CData["netData"] = nil
        DATA_Activity:formatData( buff ) 
        if DATA_Activity.CData["netData"] then
            if callback then callback()  end
        end
    end
    g_msgHandlerInst:registerMsgHandler( ACTIVITY_RET , saveDataFun )
    if idx then
        g_msgHandlerInst:sendNetDataByTableExEx(ACTIVITY_REQ, "ActivityReq", { modelID = DATA_Activity.CData["modelID"] , activityID = DATA_Activity.CData["activityID"] , flag = 0 ,index = idx })
    else
        g_msgHandlerInst:sendNetDataByTableExEx(ACTIVITY_REQ, "ActivityReq", { modelID = DATA_Activity.CData["modelID"] , activityID = DATA_Activity.CData["activityID"] , flag = 0 })
    end
    addNetLoading( ACTIVITY_REQ , ACTIVITY_RET )
end

--活动领取请求 
function DATA_Activity:getAward( params )
    
    local idx = params.idx 
    local rankId = params.rankId 
    local awards = params.awards 
    local function askGetFun()
        if idx and rankId then   --榜单id
            g_msgHandlerInst:sendNetDataByTableExEx(ACTIVITY_REQ, "ActivityReq", { modelID = DATA_Activity.CData["modelID"] , activityID = DATA_Activity.CData["activityID"] , flag = 1 , index = idx , rankID = rankId })
        elseif idx then
            g_msgHandlerInst:sendNetDataByTableExEx(ACTIVITY_REQ, "ActivityReq", { modelID = DATA_Activity.CData["modelID"] , activityID = DATA_Activity.CData["activityID"] , flag = 1 , index = idx  })
        else
            g_msgHandlerInst:sendNetDataByTableExEx(ACTIVITY_REQ, "ActivityReq", { modelID = DATA_Activity.CData["modelID"] , activityID = DATA_Activity.CData["activityID"] , flag = 1 })
        end
    end
    if awards then
        Awards_Panel( { awards = awards , award_tip = game.getStrByKey("get_awards") , getCallBack = askGetFun } )
    else
        askGetFun()
    end
end



--注册时钟函数
function DATA_Activity:regClockFun( key , _fun )
    DATA_Activity.clockFun[ key .. "" ] = _fun
end

--暂存tableView偏移位
function DATA_Activity:setTempOffPos( _pos )
    DATA_Activity.tableViewOffPos = _pos
end

--获取暂存tableView偏移位
function DATA_Activity:getTempOffPos()
    return DATA_Activity.tableViewOffPos
end

















-- local function collectionStr()
--     if not DATA_Activity then return ""end
--     local data = DATA_Activity:getRollTipsData()
    
--     local keys = {}
--     local length = 0
--     for key , v  in pairs( data ) do
--         length = length + 1
--         keys[ #keys + 1 ] = v.id
--     end
--     local overStr = ""
--     if length>1 then
--         table.sort( keys, function(a , b ) return a<b end )

--         local str = {}
--         for i = 1 , #keys do
--             local itemData = data[ keys[i] .. "" ]
--             if itemData and itemData[ "msg" ] and itemData["isShow"] == true then
--                 data[ keys[i] .. "" ]["isShow"] = false
--                 str[ #str + 1 ] = itemData[ "msg" ]
--             end
--         end
--         overStr = table.concat( str , "                  " )
--     elseif length == 1 then
--         data[ keys[1] .. "" ]["isShow"] = false
--         overStr = data[ keys[1] .. "" ][ "msg" ]
--     end

--     return overStr , length
-- end





--滚动公告初始化（跑马灯）
function DATA_Activity:initRollTips( tempData )

    DATA_Activity.rollData = tempData or {}

    local selfAdChannel = tonumber(g_Channel_tab and  g_Channel_tab.adChannel or 0 )   --自己渠道ID

    local function timeHandler()
        local function rollTipsTimeRefresh()
           
            if tablenums( DATA_Activity.rollData ) == 0  then
                DATA_Activity:regClockFun( "rollTipsClock", nil )
                return
            end

            for key , v in pairs( DATA_Activity.rollData ) do

                if v.delay then
                    --如果有延时
                    v.delay = v.delay - 1
                    if v.delay <=0 then
                        v.delay = nil
                        v.stateTime = 0
                        v.isShow = true
                        TIPS( { type = 5 } )
                    end
                else
                    if v.num > 0 then
                        if not v.isShow  then
                            v.stateTime = v.stateTime + 1
                            if v.stateTime >= v.interval then
                                v.stateTime = 0
                                v.isShow = true
                                v.num = v.num - 1 
                            end
                        end
                    else
                        DATA_Activity.rollData[ key ] = nil 
                    end
                end

            end

        end

        DATA_Activity:regClockFun( "rollTipsClock", rollTipsTimeRefresh )
        TIPS( { type = 5 } )
    end
    if tempData then timeHandler() end
    local function saveDataFun( buff )
        local t = g_msgHandlerInst:convertBufferToTable("GetHorseMsgRetProtocol", buff) 
        local msgNum = #t.horseMsg                   --消息条数
        for i,v in ipairs(t.horseMsg) do
            local key = v.msgID                        --消息ID
            DATA_Activity.rollData[ key .. "" ] = { id = key }
            DATA_Activity.rollData[ key .. "" ]["msg"] = v.message       --消息内容
            local interval = v.interval     --间隔时间
            local num = v.times          --次数
            local delay = v.delay                 --延时N

            DATA_Activity.rollData[ key .. "" ]["interval"] = interval      --间隔时间
            DATA_Activity.rollData[ key .. "" ]["num"] = num                --展示次数
            DATA_Activity.rollData[ key .. "" ]["isShow"] = true           --是否展示
            if delay > 0 then
                DATA_Activity.rollData[ key .. "" ]["delay"] = delay            --是否展示
                DATA_Activity.rollData[ key .. "" ]["isShow"] = false
            end
            

            DATA_Activity.rollData[ key .. "" ]["stateTime"] = 0            --状态改变计时

            -- local adChannel = buff:popChar()                                     --渠道不ID  0为所有渠道  不为0时 代表有多少个渠道号

            if DATA_Activity.rollData[ key .. "" ]["num"] == 0 then DATA_Activity.rollData[ key .. "" ] = nil end

            -- if adChannel~=0 then 
            --     local isExist = false
            --     for i = 1 , adChannel do
            --         local channelId = buff:popInt()  
            --         if channelId == selfAdChannel then
            --             isExist = true
            --         end
            --     end
            --     if not isExist then
            --         DATA_Activity.rollData[ key .. "" ] = nil 
            --     end
            -- end 

        end
        timeHandler()
    end
    local function saveDataUpFun( buff )
      local selfAdChannel = tonumber(g_Channel_tab and  g_Channel_tab.adChannel or 0)    --自己渠道ID

        local t = g_msgHandlerInst:convertBufferToTable("UpdateHorseMsgProtocol", buff) 

        local key = t.msgID          --消息ID
        local msg = t.message       --消息内容
        local interval = t.interval     --间隔时间
        local num = t.times          --次数

        -- local adChannel = buff:popChar()    --渠道不ID  0为所有渠道  不为0时判断是否与自己渠道相同   
        -- if adChannel~=0 then 
        --     local isExist = false
        --     for i = 1 , adChannel do
        --         local channelId = buff:popInt()  --多个渠道号
        --         if channelId == selfAdChannel then
        --             isExist = true
        --         end
        --     end
          
        --     if isExist then
        --         if num == 0 then 
        --             DATA_Activity.rollData[ key .. "" ] = nil 
        --         else
        --             DATA_Activity.rollData[ key .. "" ] = { id = key , msg = msg ,  interval = interval , num = num , isShow = true , stateTime = 0 } 
        --         end
        --     end

        -- else
            if num == 0 then 
                DATA_Activity.rollData[ key .. "" ] = nil
            else
                DATA_Activity.rollData[ key .. "" ] = { id = key , msg = msg , interval = interval , num = num , isShow = true , stateTime = 0  } 
            end
        -- end 
        timeHandler()

    end
    g_msgHandlerInst:registerMsgHandler( CHAT_SC_GET_HORSE_MSG_RET , saveDataFun )
    g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_GET_HORSE_MSG, "GetHorseMsgProtocol", {})
    g_msgHandlerInst:registerMsgHandler( CHAT_SC_UPDATE_HORSE_MSG , saveDataUpFun )    --更新单条数据
      
    -- DATA_Activity.rollData = { 
    --     [ "64" ] = { id = 64 ,  msg = "vvvvvvvvvvvvvv" ,  interval = 6 , num = 100 , delay = 5 , isShow = false , stateTime = 0 } ,
    --     [ "65" ] = { id = 65 ,  msg = "ppppppppp" ,  interval = 6 , num = 100 , isShow = true , stateTime = 0 } ,
    -- }
    -- timeHandler( DATA_Activity.rollData )
    
end

function DATA_Activity:getRollTipsData()
  return DATA_Activity.rollData
end

function DATA_Activity:ExecuteCallback(name, para)
    if self.m_callbacks == nil then
        return;
    end

    if self.m_callbacks[name] ~= nil then
        self.m_callbacks[name](para);
    end
end

function DATA_Activity:RegisterCallback(name, func)
    self.m_callbacks[name] = func;
end

return DATA_Activity