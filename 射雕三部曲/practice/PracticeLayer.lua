--[[
    文件名: PracticeLayer.lua
    描述: 修炼页面，零脉、丹道、至尊秘藏、巨灵阵、西漠、神兽之森等模块等入口页面
    创建人: heguanghui
    创建时间: 2016.5.4
--]]

local PracticeLayer = class("PracticeLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数
    params 中的各项为：
    {
        innerPos: 滑动控件 InnerContainer 的位置，用于恢复页面时使用，普通调用不需要传入该参数
    }
]]
function PracticeLayer:ctor(params)
    params = params or {}
    self.mInnerPos = params.innerPos

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化页面控件
    self:initUI()

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.ePractice,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(595, 1040),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn)

    -- 执行新手引导
    self:executeGuide()
end

-- 初始化页面控件
function PracticeLayer:initUI()
    -- 创建背景图
    local bgSprite = ui.newSprite("ll_07.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    -- 创建背景动作图片
    self:createBgUI()

    -- 创建页面中的中间部分按钮
    self:createMiddleBtn()
end

-- 创建页面中的中间部分按钮
function PracticeLayer:createBgUI()
    local function addEffect(effName, pos)
        ui.newEffect({
            parent = self.mParentLayer,
            effectName = effName,
            position = pos,
            loop = true,
            endRelease = false,
        })
    end
    local function addSprite(imgName, pos, anchor)
        local sprite = ui.newSprite(imgName)
        sprite:setAnchorPoint(anchor or cc.p(0.5, 0.5))
        sprite:setPosition(pos)
        self.mParentLayer:addChild(sprite)
    end

    -- 显示云彩
    ui.newEffect({
           parent = self.mParentLayer,
           effectName = "effect_ui_lilian",
           position = cc.p(0, 600),
           loop = true,
           speed = 0.5,
           endRelease = false,
       })

    -- 显示城楼
    addSprite("ll_24.png", cc.p(200, 790))
    addSprite("ll_08.png", cc.p(320, 568))

    -- 显示站岗的士兵
    addEffect("ui_effect_shibing", cc.p(320, 570))

    -- 显示算命先生
    local oldMan = ui.newEffect({
                       parent = self.mParentLayer,
                       effectName = "ui_effect_suanming",
                       position = cc.p(90, 460),
                       animation = "",
                       endRelease = false,
                   })
    oldMan:setAnimation(0, "daiji", true)
    addSprite("ll_22.png", cc.p(120, 490))

    -- 显示铁匠铺和女娃娃
    local smith = ui.newEffect({
                       parent = self.mParentLayer,
                       effectName = "ui_effect_datiege",
                       position = cc.p(320, 565),
                       endRelease = false,
                       loop = true,
                       animation = "animation3",
                   })
    --smith:setAnimation(0, "animation3", false)


    addSprite("ll_23.png", cc.p(575, 525))
    addEffect("ui_effect_xiaonvwawa", cc.p(325, 565))

    -- 显示吃饭和喝酒的人群
    addSprite("ll_17.png", cc.p(470, 325))
    addEffect("ui_effect_chifan_b", cc.p(320, 570))
    addSprite("ll_15.png", cc.p(390, 300))
    addSprite("ll_16.png", cc.p(320, 260))
    addEffect("ui_effect_chifan_a", cc.p(320, 570))

    addSprite("ll_14.png", cc.p(0, 125), cc.p(0, 0))

    local drankMan = ui.newEffect({
                        parent = self.mParentLayer,
                        effectName = "ui_effect_hejiu",
                        position = cc.p(110, 110),
                        animation = "",
                        endRelease = false,
                     })
    drankMan:setAnimation(0, "daiji", true)

    addSprite("ll_22.png", cc.p(120, 490))

    addSprite("ll_13.png", cc.p(640, 10), cc.p(1, 0))
    addSprite("ll_21.png", cc.p(465, 225))

    -- 左下角的花瓣图片
    addSprite("ll_09.png", cc.p(0, 0), cc.p(0, 0))

    local oldManSchedule = Utility.schedule(
        self.mParentLayer,
        function()
            oldMan:setAnimation(0, "animation", false)
            oldMan:addAnimation(0, "daiji", true)
        end,
        10
    )

    local drankManSchedule = Utility.schedule(
        self.mParentLayer,
        function()
            drankMan:setAnimation(0, "animation", false)
            drankMan:addAnimation(0, "daiji", true)
        end,
        15
    )

    -- 白鸟
    addSprite("bhd_10.png", cc.p(520, 900))

end

function PracticeLayer.playMusic(musicName)
    local musictype = Utility.getMusicType()

    -- 国语
    if musictype == Enums.MusicType.eML then
        MqAudio.playEffect(musicName..".mp3")
    -- 粤语
    elseif musictype == Enums.MusicType.eHK then
        MqAudio.playEffect(musicName.."_tw.mp3")
    end
end

-- 创建页面中的中间部分按钮
function PracticeLayer:createMiddleBtn()
    -- 配置可点击区域
    local btnInfoList = {
        { -- 闯荡江湖
            clickRect = cc.size(70, 140),   -- 可点击区域大小
            clickPos = cc.p(220, 600),      -- 可点击区域位置
            titleImage = "ll_02.png",       -- 标题图片
            titlePos = cc.p(10, 90),        -- 标题位置（相对于可点击区域）
            moduleId = ModuleSub.eQuickExp,
            clickAction = function()
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eQuickExp, true) then
                    return
                end

                -- MqAudio.playEffect("lilian_chuangdangjianghu.mp3")
                self.playMusic("lilian_chuangdangjianghu")

                LayerManager.addLayer({
                    name = "quickExp.QuickExpLayer",
                })
            end
        },
        { --拼酒
            clickRect = cc.size(150, 150),
            clickPos = cc.p(440, 260),
            titleImage = "ll_06.png",
            titlePos = cc.p(30, 100),
            moduleId = ModuleSub.ePracticeLightenStar,
            clickAction = function()
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.ePracticeLightenStar, true) then
                    return
                end
                MqAudio.playEffect("pinjie_click.mp3")
                LayerManager.addLayer({
                    name ="practice.LightenStarLayer",
                })
            end
        },
        { -- 拜师学艺
            clickRect = cc.size(110, 180),
            clickPos = cc.p(80, 545),
            titleImage = "ll_01.png",
            titlePos = cc.p(20, 100),
            moduleId = ModuleSub.eTeacher,
            clickAction = function()
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eTeacher, true) then
                    return
                end
                -- MqAudio.playEffect("lilian_baishixueyi.mp3")
                self.playMusic("lilian_baishixueyi")

                LayerManager.addLayer({
                    name ="practice.BsxyLayer",
                })
            end
        },

        { --江湖悬赏
            clickRect = cc.size(140, 130),
            clickPos = cc.p(370, 590),
            titleImage = "ll_03.png",
            titlePos = cc.p(20, 80),
            moduleId = ModuleSub.eXrxs,
            clickAction = function()
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eXrxs, true) then
                    return
                end
                -- MqAudio.playEffect("lilian_jianghuxuanshang.mp3")
                self.playMusic("lilian_jianghuxuanshang")

                LayerManager.addLayer({
                    name ="challenge.GGZJLayer",
                })
            end
        },
        { -- 据守襄阳
            clickRect = cc.size(260, 190),
            clickPos = cc.p(220, 800),
            titleImage = "ll_04.png",
            titlePos = cc.p(90, 120),
            moduleId = ModuleSub.eTeambattle,
            clickAction = function ()
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eTeambattle, true) then
                    return
                end
                -- MqAudio.playEffect("lilian_jushouxiangyang.mp3")
                self.playMusic("lilian_jushouxiangyang")
                LayerManager.addLayer({
                    name ="teambattle.TeambattleHomeLayer",
                })
            end
        },
        { --武器锻造
            clickRect = cc.size(120, 140),
            clickPos = cc.p(570, 570),
            titleImage = "ll_05.png",
            titlePos = cc.p(-10, 110),
            moduleId = ModuleSub.eChallengeGrab,
            clickAction = function ()
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eChallengeGrab, true) then
                    return
                end
                -- MqAudio.playEffect("lilian_wuqiduanzao.mp3")
                self.playMusic("lilian_wuqiduanzao")
                LayerManager.addLayer({
                    name ="challenge.ForgingMainLayer",
                })
            end
        },
        { -- 冰火岛
            clickRect = cc.size(120, 200),
            clickPos = cc.p(500, 900),
            titleImage = "bhd_11.png",
            titlePos = cc.p(-10, 50),
            moduleId = ModuleSub.eIceFire,
            clickAction = function ()
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eIceFire, true) then
                    return
                end
                LayerManager.addLayer({name = "ice.IcefireEntryLayer", cleanUp = false})
            end
        },
    }
    local extraBtn = {
        { --草帽
            clickRect = cc.size(120, 140),
            clickPos = cc.p(470, 440),
            clickAction = function (pSender)
                pSender:setEnabled(false)
                -- MqAudio.playEffect("lilian_caomao.mp3")
                self.playMusic("lilian_caomao")
            end
        },
        { --老者
            clickRect = cc.size(120, 170),
            clickPos = cc.p(320, 380),
            clickAction = function (pSender)
                pSender:setEnabled(false)
                -- MqAudio.playEffect("lilian_laozhe.mp3")
                self.playMusic("lilian_laozhe")
            end
        },
        { --喝酒的人
            clickRect = cc.size(160, 240),
            clickPos = cc.p(130, 290),
            clickAction = function (pSender)
                pSender:setEnabled(false)
                -- MqAudio.playEffect("lilian_hejiu.mp3")
                self.playMusic("lilian_hejiu")
            end
        },

    }
    for i, btnInfo in ipairs(extraBtn) do
        local tempBtn = ui.newButton({
            normalImage = "c_83.png",
            size = btnInfo.clickRect,
            position = btnInfo.clickPos,
            clickAction = btnInfo.clickAction,
        })
        self.mParentLayer:addChild(tempBtn)
    end

    self.itemBtnList = {}
    self.titleBtnList = {}
    -- 创建Layout
    for index, btnInfo in ipairs(btnInfoList) do
        -- 创建按钮
        local tempBtn = ui.newButton({
            normalImage = "c_83.png",
            size = btnInfo.clickRect,
            position = btnInfo.clickPos,
            clickAction = btnInfo.clickAction,
        })
        self.mParentLayer:addChild(tempBtn)
        -- 保存引导使用
        self.itemBtnList[btnInfo.moduleId] = tempBtn
        
        -- 创建标题按钮
        local titleBtn = ui.newButton({
            normalImage = btnInfo.titleImage,
            position = btnInfo.titlePos,
            clickAction = btnInfo.clickAction,
        })
        tempBtn:addChild(titleBtn)
        self.titleBtnList[btnInfo.moduleId] = titleBtn

        -- 处理小红点
        if btnInfo.moduleId then
            local function dealRedDotVisible(redDotSprite)
                local redDotData = RedDotInfoObj:isValid(btnInfo.moduleId)
                redDotSprite:setVisible(redDotData)
            end
            ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = RedDotInfoObj:getEvents(btnInfo.moduleId), parent = titleBtn, position = cc.p(1.1, 1.0)})
        end
    end
end

-- ========================== 新手引导 ===========================
-- 执行新手引导
function PracticeLayer:executeGuide()
    local isGuide = Guide.helper:executeGuide({
        -- 点击闯荡江湖
        [11002] = {clickNode = self.itemBtnList[ModuleSub.eQuickExp], hintPos = cc.p(display.cx, 300 * Adapter.MinScale)},
        -- 点击悬赏
        [11502] = {clickNode = self.itemBtnList[ModuleSub.eXrxs]},
        -- 点击斗酒
        [112102] = {clickNode = self.itemBtnList[ModuleSub.ePracticeLightenStar]},
        -- 点击拜师学艺
        [10901] = {clickNode = self.itemBtnList[ModuleSub.eTeacher]},
        -- 点击守卫襄阳
        [11902] = {clickNode = self.itemBtnList[ModuleSub.eTeambattle]},
    })
    if isGuide then
        -- 引导时不允许点击标题进入
        for k,v in pairs(self.titleBtnList) do
            v:setClickAction(function () end)
        end
    end
end

return PracticeLayer
