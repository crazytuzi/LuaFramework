--[[
    文件名：ShengyuanHangupPopLayer.lua
    描述： 防挂机弹窗
    创建人：chenzhong
    创建时间：2018.5.28
-- ]]

local ShengyuanHangupPopLayer = class("ShengyuanHangupPopLayer", function(params)
    return cc.LayerColor:create()
end)

-- 四张图片配置
local picConfig = {
    [1] = {imageName = "fgj_04.png"},
    [2] = {imageName = "fgj_05.png"},
    [3] = {imageName = "fgj_06.png"},
    [4] = {imageName = "fgj_07.png"},
}
-- 滑块图片的大小
local rectWidth, rectHeight = 50, 50

--[[
    callBack
]]
-- 初始化
function ShengyuanHangupPopLayer:ctor(params)
   -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("防挂机"),
        bgSize = cc.size(590, 450),
        closeImg = "",
    })
    self:addChild(bgLayer)
    self.mBgSprite = bgLayer.mBgSprite
    self.mBgSize = bgLayer.mBgSprite:getContentSize()

    self.mCallBack = params.callBack

    -- 添加中间背景图
    self:addMiddleUI()    
    -- 添加滑动按钮
    self:addSliderBtn()
end

-- 添加中间背景图
function ShengyuanHangupPopLayer:addMiddleUI()
    -- 添加点亮图片
    function addLightPic(parent, pos)
        local lightSprite = ui.newSprite("fgj_08.png")
        lightSprite:setPosition(pos)
        parent:addChild(lightSprite)
    end
    -- 随机一张图片
    local randNum = math.random(1, 4)
    local randSprite = ui.newSprite(picConfig[randNum].imageName)
    randSprite:setPosition(self.mBgSize.width/2, self.mBgSize.height-70)
    randSprite:setAnchorPoint(0.5, 1)
    self.mBgSprite:addChild(randSprite)
    local randSpriteSize = randSprite:getContentSize()
    self.randSprite = randSprite

    -- 随机取出位置
    local posX = math.random(randSpriteSize.width/3, (randSpriteSize.width-rectWidth-20)) -- 放到中间偏右
    local posY = math.random(rectHeight+20, (randSpriteSize.height-rectHeight-20))
    local currentPosY = randSpriteSize.height - posY  -- 因为矩形方块从右上角开始所以需要减一次计算高度
    local rectSprite = ui.newSprite(picConfig[randNum].imageName)
    rectSprite:setAnchorPoint(0, 1)
    rectSprite:setPosition(10, currentPosY) --背景图有白边 默然向右10个像素
    randSprite:addChild(rectSprite)
    rectSprite:setTextureRect(cc.rect(posX, posY, rectWidth, rectHeight))
    addLightPic(rectSprite, cc.p(rectWidth/2, rectHeight/2))
    self.rectSprite = rectSprite

    -- 添加一块灰色小背景
    local rectGaySprite = ui.newScale9Sprite("c_17.png", cc.size(rectWidth, rectHeight))
    rectGaySprite:setAnchorPoint(0, 1)
    rectGaySprite:setPosition(posX, currentPosY)
    randSprite:addChild(rectGaySprite)
    addLightPic(rectGaySprite, cc.p(rectWidth/2, rectHeight/2))
    self.rectGaySprite = rectGaySprite
end

function ShengyuanHangupPopLayer:addSliderBtn()
    local randSpriteSize = self.randSprite:getContentSize()
    -- 添加滑块按钮背景
    local sliderBg = ui.newSprite("fgj_01.png")
    sliderBg:setAnchorPoint(0.5, 0)
    sliderBg:setPosition(cc.p(self.mBgSize.width/2, 30))
    self.mBgSprite:addChild(sliderBg)
    local sliderSize = sliderBg:getContentSize()
    -- 滑动按钮
    local sliderBtn = ui.newButton({normalImage = "fgj_02.png",})
    sliderBtn:setAnchorPoint(cc.p(0.5, 0.5))
    sliderBtn:setPosition(cc.p(0, sliderSize.height/2))
    sliderBg:addChild(sliderBtn)

    -- 添加提示语
    local tipLabel = ui.newLabel({
        text = TR("按住左边滑块，拖动完成上方拼图"),
        size = 22,
    })
    tipLabel:setAnchorPoint(0, 0.5)
    tipLabel:setPosition(80, sliderSize.height/2)
    sliderBg:addChild(tipLabel)
    
    sliderBtn:addTouchEventListener(function(sender, event)
        if event == ccui.TouchEventType.began then
            tipLabel:setVisible(false)
        elseif event == ccui.TouchEventType.moved then   
            local touchPos = sliderBg:convertToNodeSpace(sender:getTouchMovePosition())
            if touchPos.x <= 0 then 
                sliderBtn:setPositionX(0)
                self.rectSprite:setPositionX(10)
            elseif touchPos.x >= sliderSize.width then 
                sliderBtn:setPositionX(sliderSize.width)
                self.rectSprite:setPositionX(randSpriteSize.width-rectWidth-10)--背景图有白边 默然向左10个像素
            else 
                sliderBtn:setPositionX(touchPos.x)
                self.rectSprite:setPositionX(10+touchPos.x/sliderSize.width*(randSpriteSize.width-rectWidth-20))
            end 

        elseif event == ccui.TouchEventType.ended or event == ccui.TouchEventType.canceled then
            -- 判断是否移动到灰色小背景上
            if self:rectIntersectsRect(self.rectSprite:getBoundingBox(), self.rectGaySprite:getBoundingBox()) then 
                ui.showFlashView({text = TR("验证成功！")})
                if self.mCallBack then 
                    self.mCallBack()
                end 
                LayerManager.removeLayer(self)
            else
                ui.showFlashView({text = TR("验证失败，请重新尝试！")})
                -- 重新随机加载中间图片
                self:refreshLayer()
                -- 滑块按钮位置复原
                sliderBtn:setPosition(cc.p(0, sliderSize.height/2))
                tipLabel:setVisible(true)
            end 
        end
    end)
end

-- 判断是否重合
function ShengyuanHangupPopLayer:rectIntersectsRect(rect1, rect2)
    local diatancWidth = 5 -- 误差像素
    local intersect = rect1.x >= (rect2.x - diatancWidth) and rect1.x <= (rect2.x + diatancWidth)
    return intersect
end

function ShengyuanHangupPopLayer:refreshLayer()
    if not tolua.isnull(self.randSprite) then 
        self.randSprite:removeAllChildren()
        self.randSprite = nil
        self.rectSprite = nil
        self.rectGaySprite = nil
    end 
    -- 添加中间背景图片
    self:addMiddleUI()
end

return ShengyuanHangupPopLayer
