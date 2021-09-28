--[[
    文件名：HomeBgLayer.lua
    描述：首页背景Layer的显示
    创建人：heguanghui
    创建时间：2017.3.6
-- ]]

local HomeBgLayer = class("HomeBgLayer", function(params)
	return ui.newStdLayer()
end)

--[[
]]
function HomeBgLayer:ctor()
    -- 背景图片
    self.mBgSprite = ui.newSprite("sy_44.jpg")
    self.mBgSprite:setPosition(320, 568)
    self:addChild(self.mBgSprite)

    --[[ 创建左上飘动的云
    self:createLeftTop()
    -- 创建右上飘动的云
    self:createRightTop()
    -- 创建下边飘动的云
    self:createBottom()

    -- 飘浮的岛屿
    local tempSprite = ui.newSprite("sy_28.png")
    tempSprite:setPosition(320, 473)
    self:addChild(tempSprite, 2) --]]

    -- 将时间戳转换为日期
    local curDate = os.date("*t", Player:getCurrentTime())
    -- 白天时间段
    local startTime, endTime = 6, 18
    
    -- 是否是白天
    if curDate.hour >= 6 and curDate.hour < 18 then
        self.mBgSprite:setTexture("sy_44.jpg")

        -- -- 创建杨过小龙女
        -- self:createYXEffect()

        -- -- 香炉
        -- local xiangluSprite = ui.newSprite("sy_38.png")
        -- xiangluSprite:setPosition(280, 370)
        -- self.mBgSprite:addChild(xiangluSprite)

        -- -- 剑
        -- local jianSprite = ui.newSprite("sy_39.png")
        -- jianSprite:setAnchorPoint(cc.p(1, 0))
        -- jianSprite:setPosition(635, 128)
        -- self.mBgSprite:addChild(jianSprite)

        -- -- 创建飘花动画
        -- self:createFlowerEffect()

        -- 创建周年庆双人特效
        self:createZhouNianBothHero()

        -- 创建周年庆水波特效
        self:createZhouNianWaveEffect()

        -- 创建岩石
        local rockSprite = ui.newSprite("sy_45.png")
        rockSprite:setAnchorPoint(cc.p(0.5, 0))
        rockSprite:setPosition(320, 0)
        self:addChild(rockSprite)

    else
        self.mBgSprite:setTexture("sy_42.jpg")

        self:createChunJieEffect()

        self:createBothHeroEffect()

        local bgSprite2 = ui.newSprite("sy_43.png")
        bgSprite2:setPosition(320, 568)
        self:addChild(bgSprite2)
    end

end

-- 创建春节特效
function HomeBgLayer:createChunJieEffect()
    ui.newEffect({
            parent = self,
            effectName = "effect_ui_chunjijiemian",
            animation = "80",
            position = cc.p(320, 568),
            loop = true,
        })
end

-- 创建春节双人特效
function HomeBgLayer:createBothHeroEffect()
    ui.newEffect({
            parent = self,
            effectName = "ui_effect_chunjieshuangren",
            position = cc.p(200, 240),
            loop = true,
        })
end

-- 创建周年庆双人特效
function HomeBgLayer:createZhouNianBothHero()
    local heroEffect = ui.newEffect({
            parent = self,
            effectName = "ui_effect_zhounianshuangren",
            position = cc.p(240, 140),
            loop = true,
        })
end

-- 创建周年庆水波特效
function HomeBgLayer:createZhouNianWaveEffect()
    ui.newEffect({
            parent = self,
            effectName = "effect_ui_zhounianqingzhujiemian",
            position = cc.p(320, 568),
            loop = true,
        })
end

-- 创建飘花动画
function HomeBgLayer:createFlowerEffect()
    ui.newEffect({
            parent = self.mBgSprite,
            effectName = "effect_ui_xinshouye",
            position = cc.p(320, 568),
            loop = true,
        })
end

-- 创建杨过小龙女
function HomeBgLayer:createYXEffect()
    self.ActionList = {}
    self.heroEffect = ui.newEffect({
        parent = self.mBgSprite,
        effectName = "hero_shouye",
        animation = "hejiu",
        position = cc.p(240, 340),
        loop = false,
        endRelease = false,
        completeListener = function ()
            self.ActionList.fangshou()
        end
    })
    -- 喝酒
    self.ActionList.hejiu =  function ()
        SkeletonAnimation.action({
                skeleton = self.heroEffect,
                action = "hejiu",
                loop = false,
                completeListener = function ()
                    self.ActionList.fangshou()
                end,
            })
        self.heroEffect:setTimeScale(1)
    end
    -- 放手
    self.ActionList.fangshou =  function ()
        SkeletonAnimation.action({
                skeleton = self.heroEffect,
                action = "fanfxia",
                loop = false,
                completeListener = function ()
                    self.ActionList.hejiu()
                end,
            })
        self.heroEffect:setTimeScale(0.5)
    end

    self.ActionList.hejiu()
end

-- -- 创建白云流水的动画
-- function HomeBgLayer:createCloudsEffect()
--     local function addEffect(effName, aniName, pos)
--         ui.newEffect({
--             parent = self.mBgSprite,
--             effectName = effName,
--             animation = aniName,
--             position = pos,
--             loop = true,
--             endRelease = false,
--         })
--     end
--     local function addSprite(imgName, pos)
--         local sprite = ui.newSprite(imgName)
--         sprite:setAnchorPoint(cc.p(0.5, 0))
--         sprite:setPosition(pos)
--         self.mBgSprite:addChild(sprite)
--     end

--     -- 云2和云3
--     addEffect("effect_ui_yun", "yun2", cc.p(70, 610))
--     addEffect("effect_ui_yun", "yun3", cc.p(610, 610))

--     -- 图22
--     addSprite("sy_22.png", cc.p(320, 0))

--     -- 云1
--     addEffect("effect_ui_yun", "yun1", cc.p(280, 160))
    
--     -- 水
--     addEffect("effect_ui_shui1", nil, cc.p(155, 575))
--     addEffect("effect_ui_shui7", nil, cc.p(175, 510))
--     addEffect("effect_ui_shui2", nil, cc.p(340, 590))
--     addEffect("effect_ui_shui3", nil, cc.p(490, 300))
--     addEffect("effect_ui_shui4", nil, cc.p(390, 220))
--     addEffect("effect_ui_shui5", nil, cc.p(240, 420))
--     addEffect("effect_ui_shui6", nil, cc.p(255, 360))

--     -- 图24
--     addSprite("sy_24.png", cc.p(320, 0))

--     -- 图23
--     addSprite("sy_23.png", cc.p(320, 0))
-- end

-- -- 创建左上飘动的云
-- function HomeBgLayer:createLeftTop()
--     -- 左上飘动的云(1)
--     local leftTop1Sprite = ui.newSprite("sy_19.png")
--     self:addChild(leftTop1Sprite)
--     -- 设置左上1的初始属性
--     local function initLeftTop1Sprite()
--         leftTop1Sprite:setScale(1.2)
--         leftTop1Sprite:setOpacity(255)
--         leftTop1Sprite:setPosition(-120, 900)
--         leftTop1Sprite:setRotation(0)
--     end
--     initLeftTop1Sprite()
--     local array1 = {
--         cc.Spawn:create({
--             cc.MoveTo:create(8, cc.p(300, 850)),
--             cc.ScaleTo:create(8, 0.8),
--             cc.FadeTo:create(8, 180),
--             cc.RotateTo:create(8, 20)
--         }),
--         cc.Spawn:create({
--             cc.MoveTo:create(2, cc.p(400, 830)),
--             cc.ScaleTo:create(2, 0.2),
--             cc.FadeTo:create(2, 10),
--         }),
--         cc.CallFunc:create(initLeftTop1Sprite),
--         cc.DelayTime:create(2),
--     }
--     leftTop1Sprite:runAction(cc.RepeatForever:create(cc.Sequence:create(array1)))

--     -- 左上飘动的云(2)
--     local leftTop2Sprite = ui.newSprite("sy_20.png")
--     self:addChild(leftTop2Sprite)
--     -- 设置左上2的初始属性
--     local function initLeftTop1Sprite()
--         leftTop2Sprite:setScale(1.2)
--         leftTop2Sprite:setOpacity(255)
--         leftTop2Sprite:setPosition(-250, 900)
--         leftTop2Sprite:setRotation(0)
--     end
--     initLeftTop1Sprite()
--     local array2 = {
--         cc.Spawn:create({
--             cc.MoveTo:create(10, cc.p(300, 850)),
--             cc.ScaleTo:create(10, 0.6),
--             cc.FadeTo:create(10, 180),
--             -- cc.RotateTo:create(8, 20)
--         }),
--         cc.Spawn:create({
--             cc.MoveTo:create(4, cc.p(450, 830)),
--             cc.ScaleTo:create(4, 0.2),
--             cc.FadeTo:create(4, 10),
--         }),
--         cc.CallFunc:create(initLeftTop1Sprite),
--         cc.DelayTime:create(2),
--     }
--     leftTop2Sprite:runAction(cc.RepeatForever:create(cc.Sequence:create(array2)))
-- end

-- -- 创建右上飘动的云
-- function HomeBgLayer:createRightTop()
--     local rightTopSprite = ui.newSprite("sy_21.png")
--     rightTopSprite:setAnchorPoint(cc.p(0.3, 0))
--     self:addChild(rightTopSprite)
--     -- 设置初始属性
--     local function initRightTopSprite()
--         rightTopSprite:setScale(0.3)
--         rightTopSprite:setOpacity(180)
--         rightTopSprite:setPosition(420, 800)
--         rightTopSprite:setRotation(0)
--     end
--     initRightTopSprite()

--     local array = {
--         cc.Spawn:create({
--             cc.MoveTo:create(6, cc.p(600, 850)),
--             cc.ScaleTo:create(6, 1.0),
--             cc.FadeTo:create(6, 255),
--             cc.RotateTo:create(6, -7)
--         }),
--         cc.Spawn:create({
--             cc.MoveTo:create(7, cc.p(800, 900)),
--             cc.RotateTo:create(7, -25)
--         }),
--         cc.CallFunc:create(initRightTopSprite),
--         cc.DelayTime:create(2),
--     }
--     rightTopSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(array)))
-- end

-- -- 创建下边飘动的云
-- function HomeBgLayer:createBottom()
--     -- 创建靠后的云
--     local farImgList = {"sy_25.png", "sy_26.png", "sy_27.png"}
--     local farRepeatIndex = 0
--     local function createFarSprite()
--         local tempSprite = ui.newSprite(farImgList[repeatIndex] or farImgList[#farImgList])
--         self:addChild(tempSprite)
--         -- 设置初始属性
--         local function initSprite()
--             tempSprite:setPosition(-260, 100)
--             tempSprite:setScale(1.2)
--             tempSprite:setOpacity(255)
--         end
--         initSprite()
--         -- 执行动作
--         local needTime = 20
--         tempSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(
--             cc.Spawn:create({
--                 -- 运动轨迹
--                 cc.BezierTo:create(needTime, {cc.p(320, 400), cc.p(320, 400), cc.p(900, 100)}),
--                 -- 缩放
--                 cc.Sequence:create({
--                     cc.ScaleTo:create(needTime * 0.5, 0.5),
--                     cc.ScaleTo:create(0, -0.5, 0.5),
--                     cc.ScaleTo:create(needTime * 0.5, -1.2, 1.2),
--                 }),
--                 -- 透明度变化
--                 cc.Sequence:create({
--                     cc.DelayTime:create(1),
--                     cc.FadeTo:create(needTime * 0.5 - 2, 200),
--                     cc.FadeTo:create(0.5, 0),

--                     cc.DelayTime:create(1),

--                     cc.FadeTo:create(0.5, 200),
--                     cc.FadeTo:create(needTime * 0.5 - 2, 255),
--                 })
--             }),
--             cc.CallFunc:create(initSprite)
--         )))
--     end

--     -- 创建靠前的云
--     local nearImgList = {"sy_22.png", "sy_23.png", "sy_24.png"}
--     local nearRepeatIndex = 0
--     local function createNearSprite()
--         local tempSprite = ui.newSprite(nearImgList[nearRepeatIndex] or nearImgList[#nearImgList])
--         self:addChild(tempSprite)
--         -- 设置初始属性
--         local function initSprite()
--             tempSprite:setPosition(-260, 300)
--             tempSprite:setScale(1.2)
--             tempSprite:setOpacity(255)
--         end
--         initSprite()
--         -- 执行动作
--         local needTime = 10
--         tempSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(
--             cc.Spawn:create({
--                 -- 运动轨迹
--                 cc.BezierTo:create(needTime, {cc.p(320, 100), cc.p(320, 100), cc.p(900, 300)}),
--                 -- 缩放
--                 cc.Sequence:create({
--                     cc.ScaleTo:create(needTime * 0.5, 0.5),
--                     cc.ScaleTo:create(needTime * 0.5, 1.2),
--                 }),
--                 -- 透明度变化
--                 cc.Sequence:create({
--                     cc.DelayTime:create(1),
--                     cc.FadeTo:create(needTime * 0.5 - 2, 200),
--                     cc.FadeTo:create(0.5, 0),

--                     cc.DelayTime:create(1),

--                     cc.FadeTo:create(0.5, 200),
--                     cc.FadeTo:create(needTime * 0.5 - 2, 255),
--                 })
--             }),
--             cc.CallFunc:create(initSprite)
--         )))
--     end
--     self.mBgSprite:runAction(cc.Repeat:create(cc.Sequence:create(
--         cc.CallFunc:create(function()
--             if farRepeatIndex < #farImgList then   
--                 farRepeatIndex = farRepeatIndex + 1
--                 createFarSprite()
--             end
--             if nearRepeatIndex < #nearImgList then
--                 nearRepeatIndex = nearRepeatIndex + 1
--                 createNearSprite()
--             end
--         end),
--         cc.DelayTime:create(8)
--     ), math.max(#farImgList, #nearImgList)))
-- end

return HomeBgLayer