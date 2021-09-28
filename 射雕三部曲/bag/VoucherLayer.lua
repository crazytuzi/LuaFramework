--[[
    文件名：VoucherLayer.lua
    描述：代金券
    创建人：yanxingrui
    创建时间：2016.10.9
-- ]]

local VoucherLayer = class("VoucherLayer", function()
    return cc.LayerColor:create(cc.c4b(0, 0, 0, 192))
end)

--[[
     params:
    {
        modelId      -- 必需
        isUse        -- 非必需，判断是否使用
        callback     -- 非必需
        Id           -- 非必需
    }
]]--
function VoucherLayer:ctor(params)
    dump(params, "参数列表")
    --参数处理
    -- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})
    self.modelId = params.modelId
    self.Id = params.Id or EMPTY_ENTITY_ID
    self.isUse = params.isUse or false
    self.callback = params.callback or nil

    --初始化层
    self:initLayer()

    --获取数据
    self:loadData()
   
    --添加关闭按钮
    local closeButton = ui.newButton{
        normalImage = "c_29.png",
        position = cc.p(self.mBgSize.width * 0.93, self.mBgSize.height * 0.925),
        clickAction = function ()
            LayerManager.removeLayer(self)
        end,
    }
    self.mBgSprite:addChild(closeButton)
end

function VoucherLayer:initLayer()
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 背景
    self.mBgSprite = ui.newScale9Sprite("c_30.png", cc.size(600, 430))
    self.mBgSprite:setPosition(320, 568)
    self.mBgSize = self.mBgSprite:getContentSize()
    self.mParentLayer:addChild(self.mBgSprite)

    -- 标题
    local titleLabel = ui.newLabel({
        text = TR("代金券"),
        size = Enums.Fontsize.eTitleDefault,
        color = cc.c3b(0xff, 0xee, 0xd0),
        outlineColor = cc.c3b(0x3a, 0x24, 0x18),
        x = self.mBgSize.width * 0.5,
        y = self.mBgSize.height * 0.925,
    })
    self.mBgSprite:addChild(titleLabel)

    --灰色底板
    local underGrayBg = ui.newScale9Sprite("c_17.png", cc.size(540, 170))
    underGrayBg:setPosition(300, 180)
    self.mBgSprite:addChild(underGrayBg)
    -- local function DIYfunc(boxRoot, bgSprite, bgSize)
    --     self.mShowBox = boxRoot
    -- end

    --创建修改教诲对话框
    -- local boxSize = cc.size(600, 430)
    -- LayerManager.addLayer({
    --     name = "commonLayer.MsgBoxLayer",
    --     cleanUp = false,
    --     data = {
    --         bgSize = boxSize,   --背景size
    --         title = TR("代金券"),     --标题
    --         btnInfos = {},      --按钮列表
    --         DIYUiCallback = DIYfunc,    --DIY回调
    --         btnInfos = {},
    --         closeBtnInfo = {
    --             normalImage = "c_49.png",
    --             clickAction = function()
    --                 LayerManager.removeLayer(self)
    --             end
    --         }
    --     },
    -- })
    -- local bgsprite = ui.newScale9Sprite("c_51.png", cc.size(520, 260))
    -- bgsprite:setPosition(275, 230)
    -- self.mBgSprite:addChild(bgsprite)
end

function VoucherLayer:netLayer(data)
    --参数处理
    local getTime1 = data.GetTime                 --道具获得时间戳
    local ChargeMoney = data.ChargeMoney          --已充值金额
    --local getTime1 = nil 
    local item = data.GoodsVoucherConfig         --道具代金券配置信息
    local useIntraday = item.UseIntraday and 1 or 0        --是否当天使用:1表示当天使用，0表示不当天使用
    local useVoucherLimit = item.UseVoucherLimit --使用限制额度
    local startTime1 = item.UseStartTime         --开始时间
    --local startTime1 = 956656000
    local endTime1 = item.UseEndTime              --结束时间
    self.validTime1 = item.ValidTime             --有效时间

    -- 注册关闭监控事件
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then
            if self.timerHanlerCrashInfo then 
                --print("qqqqqqqqqqqqqq")
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timerHanlerCrashInfo)
                self.timerHanlerCrashInfo = nil
            end    
        end
    end)

    --按钮
    self:isButton()

    --充值额度
    if useVoucherLimit > 0 then
        self.rechargeLabel = ui.newLabel({
            text = TR("单日充值%s%s元%s可使用获得道具:", Enums.Color.eRedH, useVoucherLimit, "#46220d"),
            color = cc.c3b(0x46, 0x22, 0x0d),
            x = self.mBgSize.width * 0.5,
            y = self.mBgSize.height * 0.56,
        })
        self.rechargeLabel:setAnchorPoint(cc.p(0.5, 0.5))
        self.mBgSprite:addChild(self.rechargeLabel)
    else
        -- 使用获得标题
        local useLabel = ui.newLabel({
            text = TR("使用可获得道具:"),
            color = cc.c3b(0x46, 0x22, 0x0d),
            x = self.mBgSize.width * 0.5,
            y = self.mBgSize.height * 0.56,
        })
        useLabel:setAnchorPoint(cc.p(0.5, 0.5))
        self.mBgSprite:addChild(useLabel)
    end

    --把时间戳转化为年月日
    local startTime = os.date("*t",startTime1)
    local endTime = os.date("*t",endTime1)

    -- 使用期限
    local useStr = TR("%s使用期限 :  %d/%d/%d %d:%d到%d/%d/%d %d:%d","#46220d",
        startTime.year,startTime.month,startTime.day,startTime.hour,startTime.min,
        endTime.year,endTime.month,endTime.day,endTime.hour,endTime.min)
    local useTimeLabel = ui.newLabel({
        text = useStr,
        color = cc.c3b(0x46, 0x22, 0x0d),
        })
    useTimeLabel:setAnchorPoint(cc.p(0, 0.5))
    useTimeLabel:setPosition(40, self.mBgSize.height * 0.78)
    self.mBgSprite:addChild(useTimeLabel)

    -- 剩余时间
    local litTimeLabel = ui.newLabel({
        text = "",
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    litTimeLabel:setAnchorPoint(cc.p(0, 0.5))
    litTimeLabel:setPosition(40, self.mBgSize.height * 0.68)
    self.mBgSprite:addChild(litTimeLabel)
    self.litTimeLabel = litTimeLabel

    local function setTime(obj, startTime, endTime)
        obj:setString(TR("%s使用期限 :  %s%d/%d/%d %d:%d到%d/%d/%d %d:%d","#46220d",
            Enums.Color.eRedH,startTime.year,startTime.month,startTime.day,startTime.hour,startTime.min,
            endTime.year,endTime.month,endTime.day,endTime.hour,endTime.min))
        -- dump(startTime, "111")
        -- dump(endTime, "222")
    end

    --判断开始时间是否为无效时间
    --local stavalid = (startTime.year <= 2000) and (startTime.month >= 1) and (startTime.day >= 1) and (startTime.hour >= 0) and (startTime.min >= 0) and (startTime.sec >= 0)
    local stavalid = startTime1 < 946656000
    --判断开始时间是否为无效时间
    --local endvalid = (endTime.year >= 2020) and (endTime.month >= 1) and (endTime.day >= 1) and (endTime.hour >= 0) and (endTime.min >= 0) and (endTime.sec >= 0) 
    local endvalid = endTime1 > 1577808000
    --有效时间显示规则及使用期限的规则
    if getTime1 then 

        local getTime = os.date("*t",getTime1)
        --获取得到道具的时间的次日0点的时间戳并将它转化为年月日
        local totalscends = getTime.hour * 3600 + getTime.min * 60 + getTime.sec 
        local nextgetTime1 = getTime1 - totalscends + 24 * 3600
        local nextgetTime = os.date("*t",nextgetTime1)
        dump(getTime1,"cccccccccccc")
        dump(totalscends, "totalscends")

        --获取得到道具的时间的次日0点的时间戳加上有效时间
        local nextvulidTime1 = nextgetTime1 + self.validTime1 * 3600
        local nextvulidTime = os.date("*t",nextvulidTime1)
        --将得到道具的时间加上有效时间转化为年月日
        local getvalidTime1 = getTime1 + self.validTime1 * 3600
        local getvalidTime = os.date("*t",getvalidTime1)

        if stavalid and endvalid then
            useTimeLabel:setVisible(false) 
            if useIntraday == 1 then --今日可用 进入倒计时
                print("rrrrrrrrrr")
                self.finTime = getvalidTime1
                print(self.finTime)
            else --明日可用
                litTimeLabel:setString(TR("有效时间 : %s小时(明日可以使用)",self.validTime1))
            end  
            
        elseif stavalid and not endvalid then 
            useTimeLabel:setString(TR("使用期限 :  %d/%d/%d %d:%d 之前",endTime.year,endTime.month,endTime.day,endTime.hour,endTime.min))    
            if getTime1 and self.validTime1 > 0 then
                if getTime1 >= endTime1 then 
                    useTimeLabel:setString(TR("这是个无效的道具"))
                    self.finTime = 0
                else
                    if (getTime1 + self.validTime1 * 3600) >= endTime1 then
                        if useIntraday == 1 then --今日可用 进入倒计时
                            setTime(useTimeLabel, getTime, endTime)
                            self.finTime = endTime1
                        else --明日可用
                            if nextgetTime1 >= endTime1 then 
                                useTimeLabel:setString(TR("这是个无效的道具"))
                                self.finTime = 0
                            else
                                setTime(useTimeLabel, nextgetTime, nextvulidTime)
                                self.finTime = nextvulidTime1
                            end
                        end  
                    else 
                        if useIntraday == 1 then --今日可用 进入倒计时
                            setTime(useTimeLabel, getTime, getvalidTime)
                            self.finTime = getvalidTime1
                        else --明日可用
                            if nextgetTime1 >= getvalidTime1 then 
                                useTimeLabel:setString(TR("这是个无效的道具"))
                                self.finTime = 0
                            else
                                setTime(useTimeLabel, nextgetTime, nextvulidTime)
                                self.finTime = nextvulidTime1
                            end
                        end        
                    end         
                end
            end     
        elseif not stavalid and endvalid then
            useTimeLabel:setString(TR("使用期限 :  %d/%d/%d %d:%d 之后",startTime.year,startTime.month,startTime.day,startTime.hour,startTime.min))    
            if getTime1 and self.validTime1 > 0 then
                if getTime1 <= startTime1 then 
                    if (getTime1 + self.validTime1 * 3600) <= startTime1 then 
                        useTimeLabel:setString(TR("这是个无效的道具"))
                        self.finTime = 0
                    else
                        if useIntraday == 1 then --今日可用 进入倒计时
                            setTime(useTimeLabel, startTime, getvalidTime)       
                            self.finTime = getvalidTime1
                        else --明日可用
                            if nextgetTime1 >= startTime1 then
                                setTime(useTimeLabel, nextgetTime, nextvulidTime)
                                self.finTime = nextvulidTime1
                            else
                                setTime(useTimeLabel, startTime, getvalidTime)
                                self.finTime = getvalidTime1
                            end
                        end                
                    end  
                else
                    if useIntraday == 1 then --今日可用 进入倒计时
                        setTime(useTimeLabel, getTime, getvalidTime)
                        self.finTime = getvalidTime1
                    else --明日可用
                        if nextgetTime1 >= getvalidTime1 then 
                            useTimeLabel:setString(TR("这是个无效的道具"))
                            self.finTime = 0
                        else
                            setTime(useTimeLabel, nextgetTime, nextvulidTime)
                            self.finTime = nextvulidTime1
                        end
                    end           
                end     
            end 
        elseif not stavalid and not endvalid then
            setTime(useTimeLabel, startTime, endTime)
            if getTime1 and self.validTime1 > 0 then     
                if getTime1 >= endTime1 or (getTime1 + self.validTime1 * 3600) <= startTime1 then 
                    useTimeLabel:setString(TR("这是个无效的道具"))
                    self.finTime = 0
                else
                    if getTime1 <= startTime1 and (getTime1 + self.validTime1 * 3600) <= endTime1 then 
                        if useIntraday == 1 then --今日可用 进入倒计时
                            setTime(useTimeLabel, startTime, getvalidTime)
                            self.finTime = getvalidTime1
                        else --明日可用
                            if nextgetTime1 >= startTime1 then
                                setTime(useTimeLabel, nextgetTime, nextvulidTime)
                                self.finTime = nextvulidTime1
                            else
                                setTime(useTimeLabel, startTime, getvalidTime)
                                self.finTime = getvalidTime1
                            end
                        end
                    elseif getTime1 <= startTime1 and (getTime1 + self.validTime1 * 3600) > endTime1 then 
                        if useIntraday == 1 then --今日可用 进入倒计时
                            setTime(useTimeLabel, startTime, endTime)      
                            self.finTime = endTime1
                        else --明日可用
                            if nextgetTime1 >= startTime1 then
                                setTime(useTimeLabel, nextgetTime, nextvulidTime)       
                                self.finTime = nextvulidTime1
                            else
                                setTime(useTimeLabel, startTime, endTime)       
                                self.finTime = endTime1
                            end
                        end 
                    elseif getTime1 > startTime1 and (getTime1 + self.validTime1 * 3600) < endTime1 then 
                        if useIntraday == 1 then --今日可用 进入倒计时
                            setTime(useTimeLabel, getTime, getvalidTime)      
                            self.finTime = getvalidTime1
                        else --明日可用
                            if nextgetTime1 >= getvalidTime1 then 
                                useTimeLabel:setString(TR("这是个无效的道具"))
                                self.finTime = 0
                            else
                                setTime(useTimeLabel, nextgetTime, nextvulidTime)       
                                self.finTime = nextvulidTime1
                            end
                        end
                    elseif getTime1 > startTime1 and (getTime1 + self.validTime1 * 3600) >= endTime1 then
                         if useIntraday == 1 then --今日可用 进入倒计时
                            setTime(useTimeLabel, getTime, endTime)
                            self.finTime = endTime1
                        else --明日可用
                            if nextgetTime1 >= endTime1 then 
                                useTimeLabel:setString(TR("这是个无效的道具"))
                                self.finTime = 0
                            else
                                setTime(useTimeLabel, nextgetTime, nextvulidTime)      
                                self.finTime = nextvulidTime1
                            end
                        end         
                    end       
                end
            end      
        end 
    else 
        if stavalid and endvalid then 
            useTimeLabel:setVisible(false)
        elseif not stavalid and endvalid then  
            useTimeLabel:setString(TR("使用期限 :  %d/%d/%d %d:%d 之后",startTime.year,startTime.month,startTime.day,startTime.hour,startTime.min))    
        elseif stavalid and not endvalid then
            useTimeLabel:setString(TR("使用期限 :  %d/%d/%d %d:%d 之前",endTime.year,endTime.month,endTime.day,endTime.hour,endTime.min))    
        end
    end

--剩余时间的判断
    --判断是否得到获得时间
    if getTime1 then

        --获取得到道具的时间的次日0点的时间戳
        local getTime = os.date("*t",getTime1)
        local totalscends = getTime.hour * 3600 + getTime.min * 60 + getTime.sec 
        local nextgetTime1 = getTime1 - totalscends + 24 * 3600

        --判断是否过期
        if useIntraday == 1 then 
            if self.validTime1 > 0 and (Player:getCurrentTime() - getTime1) >= (self.validTime1 * 3600) then
                self.litTimeLabel:setString(TR(" 已过期 "))
                if isUse == true then
                    self.useButton:setEnabled(false)
                end
            else
                --剩余时间倒计时
                --初始化剩余时间标签
                if self.validTime1 > 0 and self.finTime then
                    --倒计时的时间长度
                    if self.finTime == 0 then 
                        self.litTimeLabel:setVisible(false)
                    else 
                        local litTime = MqTime.formatAsDay(self.finTime - Player:getCurrentTime())    
                        self.litTimeLabel:setString(TR("剩余时间 :  %s%s", Enums.Color.eNormalGreenH, litTime))
                        --初始化充值标签  
                        if self.rechargeLabel then
                            if ChargeMoney >= useVoucherLimit then 
                                self.rechargeLabel:setString(TR("达到充值金额条件"))
                            else 
                                --今日在充值金额
                                local todayChargeMoney = useVoucherLimit - ChargeMoney
                                self.rechargeLabel:setString(TR("今日再充值%s%s元%s可使用获得道具:", Enums.Color.eRedH,
                                    todayChargeMoney, "#46220d"))
                            end
                        end   
                        
                    end    
                end
                local scheduler = cc.Director:getInstance():getScheduler()
                self.timerHanlerCrashInfo = scheduler:scheduleScriptFunc(function()
                    if self.validTime1 > 0 and self.finTime then
                        --倒计时的时间长度
                        local litTime = MqTime.formatAsDay(self.finTime - Player:getCurrentTime()) 
                        if self.finTime == 0 then 
                            self.litTimeLabel:setVisible(false)
                        else    
                            self.litTimeLabel:setString(TR("剩余时间 :  %s%s",Enums.Color.eNormalGreenH, litTime))

                            --判断今日是否还需充值  
                            if self.rechargeLabel then
                                if ChargeMoney >= useVoucherLimit then 
                                    self.rechargeLabel:setString(TR("达到充值金额条件"))
                                else 
                                    --今日在充值金额
                                    local todayChargeMoney = useVoucherLimit - ChargeMoney
                                    self.rechargeLabel:setString(TR("今日再充值%s%s元%s可使用获得道具:", Enums.Color.eRedH,
                                        todayChargeMoney, "#46220d"))
                                end
                            end   
                            
                        end    
                    end
                end, 1, false)
            end
        else
            if self.validTime1 > 0 and (Player:getCurrentTime() - nextgetTime1) >= (self.validTime1 * 3600) then
                self.litTimeLabel:setString(TR(" 已过期 "))
                if isUse == true then
                    self.useButton:setEnabled(false)
                end
            else
                --剩余时间倒计时
                --初始化剩余时间标签
                if self.validTime1 > 0 and self.finTime then
                    --倒计时的时间长度
                    if self.finTime == 0 then 
                        self.litTimeLabel:setVisible(false)
                    else 
                        local litTime = MqTime.formatAsDay(self.finTime - Player:getCurrentTime())    

                        --明日可以使用的道具，并且当前时间晚于得到时间的第二天的00：00则进行倒计时
                        if Player:getCurrentTime() >= nextgetTime1 then                
                            self.litTimeLabel:setString(TR("剩余时间 :  %s%s",Enums.Color.eNormalGreenH, litTime))
                            --初始化充值标签  
                            if self.rechargeLabel then
                                if ChargeMoney >= useVoucherLimit then 
                                    self.rechargeLabel:setString(TR("达到充值金额条件"))
                                else 
                                    --今日在充值金额
                                    local todayChargeMoney = useVoucherLimit - ChargeMoney
                                    self.rechargeLabel:setString(TR("今日再充值%s%s元%s可使用获得道具:", Enums.Color.eRedH,
                                        todayChargeMoney, "#46220d"))
                                end
                            end   
                        else 
                            self.litTimeLabel:setString(TR("有效时间 : %s小时(明日使用)",self.validTime1))   
                        end    
                    end    
                end
                local scheduler = cc.Director:getInstance():getScheduler()
                self.timerHanlerCrashInfo = scheduler:scheduleScriptFunc(function()
                    if self.validTime1 > 0 and self.finTime then
                        --倒计时的时间长度
                        local litTime = MqTime.formatAsDay(self.finTime - Player:getCurrentTime()) 
                        if self.finTime == 0 then 
                            self.litTimeLabel:setVisible(false)
                        else    
                            --明日可以使用的道具，并且当前时间晚于得到时间的第二天的00：00则进行倒计时
                            if Player:getCurrentTime() >= nextgetTime1 then                
                                self.litTimeLabel:setString(TR("剩余时间 :  %s%s",Enums.Color.eNormalGreenH, litTime))

                                --判断今日是否还需充值  
                                if self.rechargeLabel then
                                    if ChargeMoney >= useVoucherLimit then 
                                        self.rechargeLabel:setString(TR("达到充值金额条件"))
                                    else 
                                        --今日在充值金额
                                        local todayChargeMoney = useVoucherLimit - ChargeMoney
                                        self.rechargeLabel:setString(TR("今日再充值%s%s元%s可使用获得道具:", Enums.Color.eRedH,
                                            todayChargeMoney, "#46220d"))
                                    end
                                end   
                            else 
                                self.litTimeLabel:setString(TR("有效时间 : %s小时(明日使用)",self.validTime1))   
                            end    
                        end    
                    end
                end, 1, false)
            end    
        end
    else
        --把有效时间戳转化为时分秒的形式
        --local validTime = MqTime.formatAsDay(self.validTime1 * 3600)        
        if useIntraday == 1 then 
            local uiStr =  TR("有效时间 : %s小时",self.validTime1)
            litTimeLabel:setString(uiStr)
        else 
            local uiStr =  TR("有效时间 :%s小时(明日使用)",self.validTime1)
            litTimeLabel:setString(uiStr)
        end    
    end
    --判断有效期是否为零
    if self.validTime1 == 0 then
        litTimeLabel:setVisible(false)
        useTimeLabel:setPosition(cc.p(self.mBgSize.width * 0.5,self.mBgSize.height * 0.73))
        if Player:getCurrentTime() < startTime1 or Player:getCurrentTime() > endTime1 then
            self.useButton:setEnabled(false)
        end
    end

    local tempItemId = self.modelId
    if math.floor(tempItemId / 100000) == 169 then    --代金券特殊处理
        tempItemId = math.floor(tempItemId / 100) * 100 + 1
    end

    --获取奖品
    local goodsCode = GoodsVoucherModel.items[tempItemId].goodsOutputOddsCode
    print(goodsCode, "ggg")
    local rewardList = GoodsOutputRelation.items[goodsCode]
    local list = {}
    for i = 1, #rewardList do
        local cardData = {
            resourceTypeSub = rewardList[i].outputTypeID,
            modelId = rewardList[i].outputModelID,
            num = rewardList[i].outputNum,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
        }
        table.insert(list, cardData)
    end

    local card = ui.createCardList({
        cardDataList = list,
    })
    card:setAnchorPoint(cc.p(0.5, 0.5))
    card:setPosition(self.mBgSize.width * 0.5,150)
    self.mBgSprite:addChild(card)

end

function VoucherLayer:isButton()

    if self.isUse == true then
        -- 取消按钮
        local cancelButton = ui.newButton{
            normalImage = "c_33.png",
            text = TR("取消"),
            position = cc.p(self.mBgSize.width * 0.72, self.mBgSize.height * 0.14),
            clickAction = function ()
                LayerManager.removeLayer(self)
            end,
        }
        self.mBgSprite:addChild(cancelButton)

        -- 使用按钮
        self.useButton = ui.newButton{
            normalImage = "c_28.png",
            text = TR("使用"),
            position = cc.p(self.mBgSize.width * 0.28, self.mBgSize.height * 0.14),
            clickAction = function ()
                self:useVoucher()
            end,
        }
        self.mBgSprite:addChild(self.useButton)

    else
        --确认按钮
        local confirmButton = ui.newButton{
            normalImage = "c_28.png",
            text = TR("确认"),
            position = cc.p(self.mBgSize.width * 0.5, self.mBgSize.height * 0.14),
            clickAction = function ()
                LayerManager.removeLayer(self)
            end,
        }
        self.mBgSprite:addChild(confirmButton)
    end
end

----------------------请求接口------------------
function VoucherLayer:loadData()
    HttpClient:request({
        moduleName = "Goods",
        methodName = "GoodsVoucherConfigItem",
        svrMethodData = {self.Id, self.modelId},
        callback = function (response)
            dump(response, "ppp")
            if not response or response.Status ~= 0 then
                return
            end
            self:netLayer(response.Value)
        end,
     })
end

function VoucherLayer:useVoucher()
    HttpClient:request({
        moduleName = "Goods",
        methodName = "GoodsUse",
        svrMethodData = {self.Id, self.modelId, 1},
        callback = function(response)
            dump(response, "resggg...")
            if not response or response.Status ~= 0 then
                return
            end

            -- 显示奖励
            resourceList = clone(response.Value.BaseGetGameResourceList or {})

            if resourceList[1] and table.nums(resourceList[1]) > 0 then
                MsgBoxLayer.addGameDropLayer(resourceList, "", "", TR("获得"), nil, nil)
            else
                ui.showFlashView(TR("使用成功"))
            end

            if self.callback then
                self.callback()
            end

            LayerManager.removeLayer(self)
        end,
    })
end

return VoucherLayer