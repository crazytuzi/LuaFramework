--[[
    文件名: MeetCaishenLayer.lua
	描述: 奇遇-天降财神
	创建人: yanghongsheng
	创建时间: 2017.4.10
--]]

--[[
    params =  {
        meetInfo   :    奇遇数据
        showMeetId :    选中界面ID
        selIndex   :    选中页索引
    }
]]

local MeetCaishenLayer = class("MeetCaishenLayer", function()
    return display.newLayer()
end)

function MeetCaishenLayer:ctor(params)
	--当前奇遇数据
    self.mMeetInfo = params.meetInfo[params.selIndex]
    -- 选中界面ID
	self.mSelIndex = params.selIndex

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 供奉财神
    self.worshipBtn = nil
    -- 需要消耗的供奉
    self.diamondUse = 1000
    -- 消耗的供奉显示
    self.mUseLabel = nil
    -- -- 剩余次数
    -- self.remainderNum = 10
    -- -- 剩余次数显示
    -- self.remainderLabel = nil
    -- 滚动的老虎机
    self.mSlotMachine = nil

	-- 初始化页面控件
	self:initUI()
	-- 请求数据
	self:requestGetMeetDiamond()
end

function MeetCaishenLayer:initUI()
	-- 背景图
    local bgSprite = ui.newSprite("cdjh_40.jpg")
    bgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    bgSprite:setPosition(320,568)
    self.mParentLayer:addChild(bgSprite)

    -- 财神（特效）
    local caishenEffect = ui.newEffect({
            parent = self.mParentLayer,
            effectName = "ui_effect_tianjiangcaishen",
            position = cc.p(320, 480),
            scale = 1.7,
            loop = true,
        })
    -- -- 背景图2
    -- local bg2Sprite = ui.newSprite("cdjh_57.png")
    -- bg2Sprite:setAnchorPoint(cc.p(0.5, 0.5))
    -- bg2Sprite:setPosition(320,568)
    -- self.mParentLayer:addChild(bg2Sprite)

    -- 财神离开时间
    local leaveTimeLabel = ui.newLabel({
    	text = TR("财神离开倒计时      %s", "00:00:00"),
    	color = cc.c3b(0x43, 0x65, 0x07),
    	size = 20,
    	})
    leaveTimeLabel:setPosition(320, 443)
    bgSprite:addChild(leaveTimeLabel)

    --定时更新倒计时
    Utility.schedule(leaveTimeLabel, function()
        local lastTime = self.mMeetInfo.EndTime - Player:getCurrentTime()
        if lastTime > 0 then
            leaveTimeLabel:setString(TR("财神离开倒计时      %s", MqTime.formatAsHour(lastTime)))
        end
    end, 1.0)

    -- 供奉财神
    local worshipBtn = ui.newButton({
    	normalImage = "c_28.png",
    	text = TR("供奉财神"),
    	fontSize = 24,
    	-- outlineColor = Enums.Color.eRed,
    	clickAction = function ()
    		if Utility.isResourceEnough(ResourcetypeSub.eDiamond, self.diamondUse, true) then
                self:requestMeetDiamondOp()
            end
    	end
    	})
    worshipBtn:setPosition(320, 250)
    bgSprite:addChild(worshipBtn)
    self.worshipBtn = worshipBtn

    -- -- 剩余次数
    -- local remainderTimesLabel = ui.newLabel({
    -- 	text = TR("剩余  %d  次", 10),
    -- 	color = cc.c3b(0xbc, 0x90, 0x72),
    -- 	size = 20,
    -- 	})
    -- remainderTimesLabel:setPosition(320, 180)
    -- bgSprite:addChild(remainderTimesLabel)
    -- self.remainderLabel = remainderTimesLabel

    -- 每次需要使用元宝数量
    local resourceImage = Utility.getDaibiImage(ResourcetypeSub.eDiamond, 0)
    local useDiamond = ui.newLabel({
    	text = TR("{%s}%d/次", resourceImage, self.diamondUse),
    	color = cc.c3b(0xff, 0xf1, 0xb1),
    	size = 20,
    	})
    useDiamond:setPosition(320, 150)
    bgSprite:addChild(useDiamond)
    self.mUseLabel = useDiamond

    -- 创建滚动的老虎机
    self.mSlotMachine = self:createSlotMachine(self.mParentLayer)
    self.mSlotMachine:set_number(0)
end

-- 创建滚动的老虎机
function MeetCaishenLayer:createSlotMachine(parent)
    local viewSize = cc.size(500, 110)

    -- 裁剪节点
    local clippingNode = cc.ClippingNode:create()
    clippingNode:setIgnoreAnchorPointForPosition(false)
    clippingNode:setAnchorPoint(cc.p(0.5, 0.5))
    clippingNode:setPosition(cc.p(320, 350))
    clippingNode:setContentSize(viewSize)
    parent:addChild(clippingNode)
    local machine = clippingNode

    -- 模板
    local tempNode = ui.newScale9Sprite("c_83.png", viewSize)
    tempNode:setPosition(viewSize.width * 0.5, viewSize.height * 0.5 - 1)
    clippingNode:setStencil(tempNode)

    -- 添加滚动节点
    local xOffset = 100
    local nodesList = {}
    for i = 1, 5 do
        local node = self:createSlotOne(viewSize.height, i == 1)
        node:setIgnoreAnchorPointForPosition(false)
        node:setAnchorPoint(cc.p(0.5, 0.5))
        node:setPosition(55 + (i - 1) * xOffset, viewSize.height / 2)
        machine:addChild(node)
        nodesList[i] = node
    end

    local multiple = 0

    -- 设置倍数
    function machine:set_number(num)
        multiple = num

        local fmt = string.format("%%0%dd", #nodesList)
        local s = string.format(fmt, num)

        for idx = 1, #nodesList do
            local index = tonumber(string.sub(s, idx, idx))
            nodesList[idx]:setIndex(index)
        end
    end

    -- 所有数字开始滚动,速度达到峰值后调用callback
    function machine:start(callback)
        for i = 1, #nodesList do
            if i == #nodesList then
                nodesList[i]:start(callback)
            else
                nodesList[i]:start()
            end
        end
    end

    -- 获取当前倍数
    function machine:get_num()
        return multiple
    end

    -- 停止滚动,当所有数字停止后调用callback
    function machine:stop_at(count, callback)
        multiple = count

        local fmt = string.format("%%0%dd", #nodesList)
        local s = string.format(fmt, count)

        for idx = #nodesList, 1, -1 do
            local actionList = {}
            table.insert(actionList, cc.DelayTime:create((#nodesList - idx) + 0.1))
            table.insert(actionList, cc.CallFunc:create(function()
                local index = tonumber(string.sub(s, idx, idx))
                nodesList[idx]:stop_at(index, function()
                    if idx == 1 then
                        local _ = callback and callback()
                    end
                end)
            end))
            nodesList[idx]:runAction(cc.Sequence:create(unpack(actionList)))
        end
    end

    return machine
end

-- 创建单个滚动节点
function MeetCaishenLayer:createSlotOne(height, ifMusic)
    local cardSize = cc.size(110, 200)
    local slot = cc.Node:create()
    slot:setContentSize(cc.size(cardSize.width, height))

    local yOffset = cardSize.height + 40 -- 每个数字之间距离
    local totalC = yOffset * 10 --周长

    -- 初始化
    local data = {}
    for i = 0, 9 do
        data[i] = {
            value  = i,
            sprite = nil,
            posX = cardSize.width / 2,
            posY   = (yOffset * i + height / 2) % totalC
        }

        -- 数字
        local label = ui.newNumberLabel{
            text = i,
            imgFile = "cdjh_41.png"
        }
        label:setPosition(cardSize.width / 2, cardSize.height / 2)
        slot:addChild(label)
        data[i].label = label
    end

    local math_abs = math.abs
    local halfCardHeight = cardSize.height / 2
    -- 更新位置
    local function distanceUpdate(distance)
        local middleOneOffset = 99999999
        local middleOneIndex = 0 -- 最接近中间的数字
        for i = 0, 9 do
            local y = data[i].posY

            -- 当 y - distance == -halfCardHeight 时，卡牌牌移出视图下边界,所以加totalC将卡牌放回到顶部
            y = (y - distance + totalC + halfCardHeight) % totalC - halfCardHeight

            data[i].posY = y

            local offset = math_abs(y - (height / 2))
            if offset < middleOneOffset then
                middleOneIndex = i
                middleOneOffset = offset
            end
        end

        return middleOneIndex
    end

    -- 运动模型
    local motionModel = require("common.MotionModel").new()
    local stop_at_index = -1     -- [停止标识]当大于等于0时,开始减速
    local stopped_callback = nil -- [停止后回调]
    local check_index = -1       -- [确认标识]当速度为0时强制将中间数字设为该值
    local last_middle_index = -1 -- [上一个在中间的数字]
    local function onUpdate(delta)
        motionModel:time_passed(delta) -- 输入时间计算位移
        local moved_distance = motionModel:get_distance()
        motionModel:set_distance(0) -- 重设位移为0，方便下次获取新的位移

        local middleOneIndex = distanceUpdate(moved_distance) -- 更新所有数字的位置

        -- 数字有变化时播放音效
        if last_middle_index ~= middleOneIndex and ifMusic then
            last_middle_index = middleOneIndex

            MqAudio.playEffect("activity_caishen.mp3")
        end

        ------------- 设置sprite显示位置
        -- middleOneIndex上两个
        local frontOne = (middleOneIndex + 9) % 10
        data[frontOne].label:setPositionY(data[frontOne].posY)
        local frontTwo = (middleOneIndex + 8) % 10
        data[frontTwo].label:setPositionY(data[frontTwo].posY)

        -- 当前
        data[middleOneIndex].label:setPositionY(data[middleOneIndex].posY)

        -- middleOneIndex下一个
        local nextOne = (middleOneIndex + 1) % 10
        data[nextOne].label:setPositionY(data[nextOne].posY)
        local nextTwo = (middleOneIndex + 2) % 10
        data[nextTwo].label:setPositionY(data[nextTwo].posY)

        -- 别的
        -- ...已经移出视图范围不管

        if check_index ~= -1 then
            slot:setIndex(check_index)
            check_index = -1
            if ifMusic then
                MqAudio.playEffect("caishensongxi.mp3")
            end
            if stopped_callback then
                stopped_callback()
                stopped_callback = nil
            end
        end

        -- 减速停止
        if stop_at_index >= 0 then
            local wait_check_index = stop_at_index -- 缓存

            local S = (data[stop_at_index].posY + totalC - height / 2) % totalC
            print("减速阶段 to:", wait_check_index)
            if S < yOffset then
                S = S + totalC
            end
            local a = motionModel:try_stop_at(S, 0) -- 输入位移和末速度计算加速度(减速度)
            motionModel:ajust_speed(0, a, function()
                check_index = wait_check_index
            end)

            stop_at_index = - 1
        end
    end

    -- 开始加速,当加速到峰值后调用callback
    function slot:start(callback)
        local vMax = yOffset * 5 -- 最大速度
        local a = yOffset * 5  -- 加速度

        slot:scheduleUpdateWithPriorityLua(onUpdate, 1)
        print("加速阶段")
        motionModel:ajust_speed(vMax, a, callback)
    end

    -- 减速停止,当速度为0时调用callback
    function slot:stop_at(index, callback)
        stop_at_index = index
        stopped_callback = function()
            slot:unscheduleUpdate()
            local _ = callback and callback()
        end
    end

    -- 直接设置显示数字并停止滚动
    function slot:setIndex(index)
        local bottomIndex = (index - 3 + 10) % 10
        local posY = (height / 2) - (yOffset * 3)
        for i = 0, 9 do
            data[bottomIndex % 10].posY = posY
            data[bottomIndex % 10].label:setPositionY(data[bottomIndex % 10].posY)
            bottomIndex = bottomIndex + 1
            posY = posY + yOffset
        end
        slot:unscheduleUpdate()
    end

    return slot
end

--转动
function MeetCaishenLayer:rolling(value)
    local stopNum = value.Value.BaseGetGameResourceList[1].PlayerAttr[1].Num
    -- 屏蔽层
    self.mLockLayer = cc.Layer:create()
    ui.registerSwallowTouch({node = self.mLockLayer})
    display.getRunningScene():addChild(self.mLockLayer, 255)

    local speed_ok = false  --标识速度是否达到峰值

    -- 开始滚动
    self.mSlotMachine:start(function()
        print("speed_ok")
        speed_ok = true
    end)

    local function stop_slotmachine()
        if speed_ok then
            self.mSlotMachine:stop_at(stopNum, function()
                ui.ShowRewardGoods(value.Value.BaseGetGameResourceList, true) --显示奖励
                self.mLockLayer:removeFromParent()
                --奇遇结束
                self:meetIsDone()
                HttpClient:modifyCache(value)
            end)
        else
            self:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.5),
                cc.CallFunc:create(stop_slotmachine)
            ))

        end
    end
    stop_slotmachine()
end

function MeetCaishenLayer:refreshUI()
	local info = QuickexpMeetDiamondModel.items[self.mData.TargetId]
    --刷新消耗
    local daibi = Utility.getDaibiImage(ResourcetypeSub.eDiamond)
    self.mUseLabel:setString(TR("消耗:{%s}%d", daibi, info.useDiamond))
    self.diamondUse = info.useDiamond
    self.worshipBtn:setTouchEnabled(true)
    --奇遇结束
    if self.mMeetInfo.IsDone then
        self:meetIsDone()
    end
end

--奇遇完成
function MeetCaishenLayer:meetIsDone()
    self.mMeetInfo.IsDone = true
    self.worshipBtn:setVisible(false)
    self.mMeetInfo.redDotSprite:setVisible(false)
    -- self.mHadGet:setVisible(true)
    -- self.mMeetInfo.timeLabel:setVisible(false)
end

-------------------服务器请求相关---------------------

--获取奇遇数据
function MeetCaishenLayer:requestGetMeetDiamond()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "QuickExp",
        methodName = "GetMeetDiamondInfo",
        svrMethodData = {self.mMeetInfo.Id},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            dump(response.Value)
            self.mData = response.Value
            --dump(response.Value, "获取财神信息")
            self:refreshUI()
        end
    })
end

-- 拜财神按钮点击事件
function MeetCaishenLayer:requestMeetDiamondOp()
    self.worshipBtn:setTouchEnabled(false)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "QuickExp",
        methodName = "MeetDiamondOp",
        svrMethodData = {self.mMeetInfo.Id},
        callbackNode = self,
        autoModifyCache = false,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            --dump(response.Value, "点击摇动")
            self:rolling(response)
        end
    })
end


return MeetCaishenLayer
