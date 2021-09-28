--[[
    文件名：SphereProgress
	描述：球形进度条，实现在一个圆形的进度条，在进度位置有一个椭圆形的面，
	创建人：liaoyuangang
	创建时间：2016.05.28
-- ]]

local SphereProgress = class("SphereProgress", function()
    return cc.Layer:create()
end)

--[[
    {
        bgImage = "",   -- 背景图片
        barImage = "",  -- 进度图片
        faceImage = "", -- 进度位置球面的图片（一张椭圆型的图片）
        currValue = 1,  -- 当前进度
        maxValue = 100, -- 最大值
        needLabel = true,   -- 是否需要文字显示进度
        percentView = true  -- 以百分比方式显示(needLabel == true有效)
        font = _FONT_NUMBER, -- 文本的字体
        size = 20, -- 文本的大小
        color = Enums.Color.eWhite, 文本颜色
    }
--]]
function SphereProgress:ctor(params)
    -- 当前的进度
    self.mCurrValue = params.currValue or 50
    -- 进度的最大值
    self.mMaxValue = params.maxValue or 100
    -- 提示信息是否以百分比显示
    self.mIsPercentView = params.needLabel and params.percentView

    -- 控件的大小
    self.mViewSize = ui.getImageSize(params.bgImage)
    -- 进度图片的大小
    self.mBarSize = ui.getImageSize(params.barImage)

    -- 设置控件的大小
    self:setContentSize(self.mViewSize)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setIgnoreAnchorPointForPosition(false)

    -- 创建进度条背景图片
    self.mBgSprite = ui.newSprite(params.bgImage)
    self.mBgSprite:setPosition(cc.p(self.mViewSize.width / 2, self.mViewSize.height / 2))
    self:addChild(self.mBgSprite)

    -- 创建进度bar
    local tempSprite = ui.newSprite(params.barImage)
    self.mProgressTimer = cc.ProgressTimer:create(tempSprite)
    self.mProgressTimer:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.mProgressTimer:setMidpoint(cc.p(0, 0))
    self.mProgressTimer:setBarChangeRate(cc.p(0, 1))
    self.mProgressTimer:setPosition(self.mViewSize.width / 2, self.mViewSize.height / 2)
    self:addChild(self.mProgressTimer)

    -- 创建进度位置球面的图片
    self.mFaceSprite = ui.newSprite(params.faceImage)
    self.mFaceSprite:setScale(0)
    self.mFaceSprite:setPosition(self.mViewSize.width / 2, (self.mViewSize.height - self.mBarSize.height) / 2)
    self:addChild(self.mFaceSprite)

    -- 创建进度提示的Label
    if params.needLabel then
        self.mProgressLabel = ui.newLabel({
            text = "",
            font = params.font,
            size = params.size,
            color = params.color or Enums.Color.eYellow,
            align = ui.TEXT_ALIGN_CENTER,
            valign = ui.TEXT_VALIGN_CENTER,
            x = self.mViewSize.width / 2,
            y = self.mViewSize.height / 2,
        })
        self:addChild(self.mProgressLabel)
    end
    
    local function onNodeEvent(event)
        if "enter" == event then
            self:setCurrValue(self.mCurrValue, 0)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

-- 获取进度提示文字
function SphereProgress:getProgressStr()
    if self.mIsPercentView then
        local percent = math.min(math.ceil(self.mCurrValue / self.mMaxValue * 100), 100)
        return string.format("%d%%",percent)
    else
        return string.format("%d / %d", self.mCurrValue, self.mMaxValue)
    end
end

-- 获取进度位置球面的缩放比例
function SphereProgress:getFaceScale(currValue)
    local ret = math.sqrt(2 * currValue * self.mMaxValue - currValue * currValue) / self.mMaxValue * 2
end

-- 设置进度值
--[[
-- 参数:
    currValue: 当前进度
    duration: 进度效果的持续时间
--]]
function SphereProgress:setCurrValue(currValue, duration)
    duration = duration or 0.3
    currValue = math.max(0, currValue)
    local toProg = math.min(100, (self.mMaxValue > 0) and ((currValue / self.mMaxValue) * 100) or 0)
    local fromProg = (self.mMaxValue > 0) and ((self.mCurrValue / self.mMaxValue) * 100) or 0
    if toProg < fromProg then
        fromProg = 0
    end

    -- 设置进度条的动画
    local actionArray = {
        cc.ProgressFromTo:create(duration, fromProg, toProg),
        cc.CallFunc:create(function()
            if self.mProgressLabel then
                local progStr = self:getProgressStr()
                self.mProgressLabel:setString(progStr)
            end
        end),
    }
    self.mProgressTimer:runAction(cc.Sequence:create(actionArray))

    -- 设置球面的动画
    local toScale = math.sqrt(2 * toProg * 50 - toProg * toProg) / 50
    local toPosY = (self.mViewSize.height - self.mBarSize.height) / 2 + self.mBarSize.height * toProg / 100
    self.mFaceSprite:stopAllActions()
    if duration > 0 then
        self.mFaceSprite:runAction(cc.Spawn:create(
            cc.ScaleTo:create(duration, toScale),
            cc.MoveTo:create(duration, cc.p(self.mViewSize.width / 2, toPosY))
        ))
    else
        self.mFaceSprite:setScale(toScale)
        self.mFaceSprite:setPosition(self.mViewSize.width / 2, toPosY)
    end
    
    self.mCurrValue = currValue
end

-- 设置最大进度值
--[[
-- 参数
    maxValue: 需要设置最大进度值
 ]]
function SphereProgress:setMaxValue(maxValue)
    self.mMaxValue = math.max(0, maxValue)
    self:setCurrValue(self.mCurrValue, 0)
end

return SphereProgress

