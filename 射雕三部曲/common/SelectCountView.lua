--[[
	文件名：SelectCountView.lua
	文件描述：数量选择控件
	创建人：liaoyuangang
	创建时间：2016.5.3
--]]

local SelectCountView = class("SelectCountView", function()
    return ccui.Layout:create()
end)

--[[
-- 参数params 中的各项为:
	{
		currSelCount = 1, -- 当前选择的数量，默认为 1
		maxCount = 100, --  选择的最大数目
		viewSize = cc.size(500, 200), -- 控件的显示大小
		changeCallback = nil, -- 选择数量改变的回调函数, 回调函数的参数为：changeCallback(selCount)
        extraNum, -- 需要倍数显示，显示extraNum倍
        isAddMaxBtn,    添加一键最大按钮
        isUseLabel,	是否使用文本显示数量
	}
]]
function SelectCountView:ctor(params)
    self.extraNum = params.extraNum
	self.mCurrSelCount = params.currSelCount or 1
	self.mMaxCount = params.maxCount
    self.mAddMaxBtn = params.isAddMaxBtn
    self.isUseLabel = params.isUseLabel or false
    -- 有需要倍数显示，必须用文本显示
    if self.extraNum then
    	self.isUseLabel = true
    end
	if not self.mMaxCount or self.mMaxCount < 1 or self.mMaxCount > 9999 then  
		self.mMaxCount = 9999 -- 不能超过10000
	end
	self.mViewSize = params.viewSize or cc.size(500, 200)
	self.changeCallback = params.changeCallback

	self:setContentSize(self.mViewSize)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setIgnoreAnchorPointForPosition(false)

    -- 显示选中数量的背景图和label
    local tempSprite = ui.newScale9Sprite("c_24.png",cc.size(130, 32))
    tempSprite:setPosition(self.mViewSize.width / 2, self.mViewSize.height / 2)
    self:addChild(tempSprite)
    -- 
    local textStr = tostring(self.mCurrSelCount)
    if self.extraNum then
        textStr = tostring(self.mCurrSelCount).."*"..tostring(self.extraNum)
    end
    -- 静态文本
    self.mSelCountLabel = ui.newLabel({
    	text = textStr,
    	color = cc.c3b(0x11, 0x11, 0x11),
    	align = cc.TEXT_ALIGNMENT_CENTER,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    })
    self.mSelCountLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.mSelCountLabel:setPosition(self.mViewSize.width / 2, self.mViewSize.height / 2)
    self:addChild(self.mSelCountLabel)
    self.mSelCountLabel:setVisible(self.isUseLabel)
    -- 输入框
    self.mSelCountEditBox = ui.newEditBox({
            image = "c_83.png",
            size = cc.size(120, 32),
            fontSize = 22,
            fontColor = cc.c3b(0x46, 0x22, 0x0d),
            placeColor = cc.c3b(255, 102, 243),
            listener = function (event, editBox)
     --        	if event == "changed" then
	    --         	local editStr = editBox:getText()
	    --         	if editStr == "" then
	    --         		self.mCurrSelCount = 1
     --        		elseif string.match(editStr, "%D") then
     --                    editBox:setText(self.mCurrSelCount)
     --                elseif tonumber(editStr) < 1 then
     --                	self.mCurrSelCount = 1
     --                	editBox:setText(self.mCurrSelCount)
     --                elseif tonumber(editStr) > self.mMaxCount then
     --                	self.mCurrSelCount = self.mMaxCount
     --                	editBox:setText(self.mCurrSelCount)
     --                	editBox:setFocusEnabled(true)
     --                else
     --                	self.mCurrSelCount = tonumber(editStr)
     --                end
	    -- 			if self.changeCallback then
					-- 	self.changeCallback(self.mCurrSelCount)
					-- end
            	if event == "ended" then
	            	local editStr = editBox:getText()
            		if string.match(editStr, "%D") then
                        editBox:setText(self.mCurrSelCount)
                    elseif editStr == "" or tonumber(editStr) < 1 then
                    	self.mCurrSelCount = 1
                    	editBox:setText(self.mCurrSelCount)
                    	if self.changeCallback then
    						self.changeCallback(self.mCurrSelCount)
    					end
                    elseif tonumber(editStr) > self.mMaxCount then
                    	editBox:setText(self.mMaxCount)
                    	self.mCurrSelCount = self.mMaxCount
    	    			if self.changeCallback then
    						self.changeCallback(self.mCurrSelCount)
    					end
                    else
                    	self.mCurrSelCount = tonumber(editStr)
    	    			if self.changeCallback then
    						self.changeCallback(self.mCurrSelCount)
    					end
                    end
            	end
            end
        })
    self.mSelCountEditBox:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    self.mSelCountEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.mSelCountEditBox:setText(self.mCurrSelCount)
    self.mSelCountEditBox:setMaxLength(4)
    self.mSelCountEditBox:setPosition(self.mViewSize.width / 2, self.mViewSize.height / 2)
    self.mSelCountEditBox:setPlaceHolder(TR("输入数量"))
    self:addChild(self.mSelCountEditBox)
    self.mSelCountEditBox:setVisible(not self.isUseLabel)

    -- －10、－1、＋1、＋10 按钮
    local tempPosY = self.mViewSize.height / 2
    local btnInfos = {
    	{
    		text = "-1",
    		position = cc.p(135, tempPosY),
    		clickAction = function()
    			self.mCurrSelCount = math.max(1, self.mCurrSelCount - 1)
    			self.mSelCountLabel:setString(tostring(self.mCurrSelCount))
    			self.mSelCountEditBox:setText(tostring(self.mCurrSelCount))
    			if self.changeCallback then
					self.changeCallback(self.mCurrSelCount)
				end
    		end,
            offset = -1,
    	},
    	{
    		text = "+1",
    		position = cc.p(self.mViewSize.width - 135, tempPosY),
    		clickAction = function()
    			self.mCurrSelCount = math.min(self.mMaxCount, self.mCurrSelCount + 1)
    			self.mSelCountLabel:setString(tostring(self.mCurrSelCount))
    			self.mSelCountEditBox:setText(tostring(self.mCurrSelCount))
    			if self.changeCallback then
					self.changeCallback(self.mCurrSelCount)
				end
    		end,
            offset = 1,
    	},
	}
    if not self.isAddMaxBtn then
        table.insert(btnInfos, {
            text = "-10",
            position = cc.p(50, tempPosY),
            clickAction = function()
                self.mCurrSelCount = math.max(1, self.mCurrSelCount - 10)
                self.mSelCountLabel:setString(tostring(self.mCurrSelCount))
                self.mSelCountEditBox:setText(tostring(self.mCurrSelCount))
                if self.changeCallback then
                    self.changeCallback(self.mCurrSelCount)
                end
            end,
            offset = -10,
        })

        table.insert(btnInfos, {
            text = "+10",
            position = cc.p(self.mViewSize.width - 50, tempPosY),
            clickAction = function()
                self.mCurrSelCount = math.min(self.mMaxCount, self.mCurrSelCount + 10)
                self.mSelCountLabel:setString(tostring(self.mCurrSelCount))
                self.mSelCountEditBox:setText(tostring(self.mCurrSelCount))
                if self.changeCallback then
                    self.changeCallback(self.mCurrSelCount)
                end
            end,
            offset = 10,
        })
    end

	for _, btnInfo in pairs(btnInfos) do
		btnInfo.normalImage = "bg_05.png"
		local tempBtn = ui.newButton(btnInfo)
		self:addChild(tempBtn)

		-- 设置按钮的触摸事件
        local size = tempBtn:getContentSize()
        local x = size.width / 2
        local y = size.height / 2 * 1.75
        -- 参数为增长速率
        SelectCountView.registerPressTouch(tempBtn, function(curRate)
            -- 计算数量
            local oldCount = self.mCurrSelCount
            self.mCurrSelCount = self.mCurrSelCount + math.floor(btnInfo.offset * curRate)
            self.mCurrSelCount = math.max(1, self.mCurrSelCount)
            self.mCurrSelCount = math.min(self.mMaxCount, self.mCurrSelCount)
            if oldCount == self.mCurrSelCount then return false end

            local isChanged = true
            if self.changeCallback then
                isChanged = self.changeCallback(self.mCurrSelCount) ~= false
            end

            -- 是否可以改变
            if isChanged then
                if self.extraNum then
                    self.mSelCountLabel:setString(tostring(self.mCurrSelCount).."*"..tostring(self.extraNum))
                else
                    self.mSelCountLabel:setString(tostring(self.mCurrSelCount))
                    self.mSelCountEditBox:setText(tostring(self.mCurrSelCount))
                end

                -- 动画
                ui.showFlashView({
                    parent = tempBtn,
                    text = TR("%+d", self.mCurrSelCount - oldCount),
                    textColor = Enums.Color.eOrange,
                    image = "",
                    beginPos = cc.p(x, y),
                    duration = 0.35,
                })
            else
                self.mCurrSelCount = oldCount
            end
            return isChanged
        end)
	end

	if self.changeCallback then
		self.changeCallback(self.mCurrSelCount)
	end

    -- 添加最大，最小按钮
    if self.mAddMaxBtn then
        -- 最小
        local minBtn = ui.newButton({
            normalImage = "bg_05.png",
            text = TR("最小"),
            position = cc.p(50, tempPosY),
            clickAction = function ()
                self.mCurrSelCount = 1
                self.mSelCountLabel:setString(tostring(self.mCurrSelCount))
                self.mSelCountEditBox:setText(tostring(self.mCurrSelCount))
                self.changeCallback(self.mCurrSelCount)
            end,
        })
        self:addChild(minBtn)
        -- 最大
        local maxBtn = ui.newButton({
            normalImage = "bg_05.png",
            text = TR("最大"),
            position = cc.p(self.mViewSize.width - 50, tempPosY),
            clickAction = function ()
                self.mCurrSelCount = self.mMaxCount
                self.mSelCountLabel:setString(tostring(self.mCurrSelCount))
                self.mSelCountEditBox:setText(tostring(self.mCurrSelCount))
                self.changeCallback(self.mCurrSelCount)
            end,
        })
        self:addChild(maxBtn)
    end
end

--- ==================== 触摸相关 =======================
-- 注册触摸事件
function SelectCountView.registerPressTouch(node, callback)
    local container = {}

    -- 增长速率
    container.upgradeRate = 1
    -- 按下持续时间
    container.totalTouchTime = 0.0
    -- 终止
    local stop = function ()
        container.isRunning = false
        container.upgradeRate = 1
        container.totalTouchTime = 0.0

        -- 触摸闪断
        -- node:setTouchEnabled(false)
        -- node:setTouchEnabled(true)

        -- 结束定时器
        if container.delayTimer ~= nil then
            node:stopAction(container.delayTimer)
            container.delayTimer = nil
        elseif container.repeatTimer ~= nil then
            node:stopAction(container.repeatTimer)
            container.repeatTimer = nil
        end
    end

    -- 进行一次操作
    local once = function ()
        -- 按累计时间来计算增长速率
        if (container.totalTouchTime - 1) / (container.upgradeRate) > 1 then
            container.upgradeRate = container.upgradeRate * 2
        end
        -- 最大倍率不超过
        container.upgradeRate = math.min(container.upgradeRate, 20)
        local ret = callback(container.upgradeRate)
        if not ret then 
            stop() 
        end
    end

    -- 准备进行
    local start = function ()
        container.isRunning = true
        container.upgradeRate = 1
        container.totalTouchTime = 0.0

        -- 延迟定时器
        container.delayTimer = Utility.performWithDelay(node, function()
            container.delayTimer = nil
            -- 重复定时器
            container.repeatTimer = Utility.schedule(node, function ()
                -- 执行一次
                once()
                -- 累计按下时间
                container.totalTouchTime = container.totalTouchTime + 0.1
            end, 0.1)
        end, 0.6)
        
        -- 首先回调一次
        once()
    end

    -- 注册
    local boundingBox = node:getBoundingBox()
    node:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.moved then
            if not container.isRunning then return end

            -- 当触点还在控件内部时
            local touchPos = sender:getTouchMovePosition()
            touchPos = node:getParent():convertToNodeSpace(touchPos)
            if cc.rectContainsPoint(boundingBox, touchPos) == true then return end
        elseif eventType == ccui.TouchEventType.began then
            start()
            return
        end
        stop()
    end)
end

return SelectCountView