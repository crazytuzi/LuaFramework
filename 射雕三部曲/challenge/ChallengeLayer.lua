--[[
    文件名: ChallengeLayer.lua
	描述: 挑战页面，夺宝、竞技场、九山兵阁、大罗金库、序列争霸争霸、主宰争霸 等模块等入口页面
	创建人: liaoyuangang
	创建时间: 2016.5.4
--]]

local ChallengeLayer = class("ChallengeLayer", function(params)
    return display.newLayer()
end)

function ChallengeLayer:ctor(params)
    self.autoOpenModule = params.autoOpenModule

    -- 添加标准缩放父结点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 初始化页面控件
    self.actionBtnList = {}
	self:initUI()

	-- 创建底部导航和顶部玩家信息部分
	local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
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

    -- 添加滑动事件
    self.curScrollY = 0
    self:addTouchEvent()

    -- 执行新手引导
    self:executeGuide()
end

-- 初始化页面控件
function ChallengeLayer:initUI()
    self.bgItemList = {}
    local billsList = {
        -- 大背景
        {
            bgImage = "tz_01.jpg", 
            pos = cc.p(317, 574), 
            effectOffset = cc.p(0, -6), 
            effectScale = 0,
        },

        -- 六大派，守卫光明顶
        {
            bgImage = "tz_04.png", 
            pos = cc.p(332, 773), 
            effectOffset = cc.p(1, -1), 
            effectScale = 0.07,
            btnImage = "tz_16.png", 
            btnOffset = cc.p(370, 500),
            
            clickRect = cc.size(210, 160),
            clickPos = cc.p(450, 500),
            moduleId = ModuleSub.eExpedition,
            action = function ( ... )
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eExpedition, true) then
                    return
                end
                MqAudio.playEffect("challenge_sword.mp3")
                LayerManager.addLayer({
                    name = "challenge.ExpediDifficultyLayer",
                })
            end,
            effectData = {
                [1] = {
                    effectName = "effect_ui_tiaozhan",
                    position = cc.p(480, 520),
                    loop = true,
                    animation = "luziguang",
                }
            }
        },

        -- 讨伐魔教
        {
            bgImage = "tz_07.png", 
            pos = cc.p(436, 583), 
            effectOffset = cc.p(23, -34), 
            effectScale = 0.14,
            btnImage = "tz_15.png", 
            btnOffset = cc.p(445, 580),

            clickRect = cc.size(200, 150),
            clickPos = cc.p(370, 570),
            moduleId = ModuleSub.eShengyuanWars,
            action = function ( ... )
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eShengyuanWars, true) then
                    return
                end
                LayerManager.addLayer({
                    name = "shengyuan.ShengyuanWarsStartLayer",
                })
            end,
            effectData = {
                [1] = {
                    effectName = "effect_ui_tiaozhan",
                    position = cc.p(360, 540),
                    loop = true,
                    animation = "daojian",
                }
            }
        },

        -- 武林争霸
        {
            bgImage = "tz_03.png", 
            pos = cc.p(203, 534), 
            effectOffset = cc.p(-26, -72), 
            effectScale = 0.2,
            btnImage = "tz_14.png", 
            btnOffset = cc.p(150, 370),

            clickRect = cc.size(200, 150),
            clickPos = cc.p(220, 370),
            moduleId = ModuleSub.ePVPInter,
            action = function ( ... )
                -- ui.showFlashView(TR("敬请期待"))
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.ePVPInter, true) then
                    return
                end

                LayerManager.addLayer({
                    name = "challenge.PvpInterLayer",
                })
            end,
            effectData = {
                [1] = {
                    effectName = "effect_ui_tiaozhan",
                    position = cc.p(260, 350),
                    loop = true,
                    animation = "huo",
                }
            }
        },

        -- 华山论剑(竞技场)
        {
            bgImage = "tz_02.png", 
            pos = cc.p(151, 334), 
            effectOffset = cc.p(-47, -163), 
            effectScale = 0.33,
            btnImage = "tz_13.png", 
            btnOffset = cc.p(270, 440), 

            clickRect = cc.size(210, 150),
            clickPos = cc.p(195, 440), 
            moduleId = ModuleSub.eChallengeArena,
            action = function ( ... )
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eChallengeArena, true) then
                    return
                end

                LayerManager.addLayer({
                    name = "challenge.PvpLayer",
                    data = {isFirstIn = true}
                })
            end,
            effectData = {
                [1] = {
                    effectName = "effect_ui_tiaozhan",
                    position = cc.p(180, 410),
                    loop = true,
                    animation = "shuichiguang",
                }
            }
        },

        -- 云1
        {
            bgImage = "tz_10.png", 
            pos = cc.p(270, 190), 
            effectOffset = cc.p(-25, -240), 
            effectScale = 0.31,
        },

        -- 武林大会(龙凤天)
        {
            bgImage = "tz_06.png", 
            pos = cc.p(443, 255), 
            effectOffset = cc.p(132, -126), 
            effectScale = 0.29,
            btnImage = "tz_17.png", 
            btnOffset = cc.p(315, 566), 

            clickRect = cc.size(190, 170),
            clickPos = cc.p(250, 560), 
            moduleId = ModuleSub.eChallengeWrestle,
            action = function ( ... )
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eChallengeWrestle, true) then
                    return
                end

                local layerParams = self.params and self.params.subData or {type = 2}
                LayerManager.addLayer({
                    name = "challenge.GDDHLayer",
                    data = layerParams,
                })
            end,
            effectData = {
                [1] = {
                    effectName = "effect_ui_tiaozhan",
                    position = cc.p(230, 500),
                    loop = true,
                    animation = "shizimen",
                }
            }
        },

        -- 云2
        {
            bgImage = "tz_09.png", 
            pos = cc.p(356, 101), 
            effectOffset = cc.p(155, -267), 
            effectScale = 0.36,
        },
        
        -- 比武招亲(神装殿)
        {
            bgImage = "tz_08.png", 
            pos = cc.p(167, 122), 
            effectOffset = cc.p(-197, -300), 
            effectScale = 0.42,
            btnImage = "tz_18.png", 
            btnOffset = cc.p(100, 280), 

            clickRect = cc.size(200, 175),
            clickPos = cc.p(165, 270), 
            moduleId = ModuleSub.ePracticeBloodyDemonDomain,
            action = function ( ... )
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.ePracticeBloodyDemonDomain, true) then
                    return
                end

                -- local redDotData = RedDotInfoObj:isValid(ModuleSub.ePracticeBloodyDemonDomain)
                -- if redDotData then
                --     local haveRedDotDebris, treasureDebrisModelId = TreasureDebrisObj:haveRedDotTreasureDebris(true)
                --     if haveRedDotDebris and (not self.params or not self.params.subData) then
                --         self.params = self.params or {}
                --         self.params.subData = self.params.subData or {}
                --         self.params.subData.debrisId = treasureDebrisModelId
                --     end
                -- end
                -- 进入夺宝页面后需要把夺宝页面的小红点取消掉，无论玩家是否在夺宝页面中夺宝
                -- RedDotInfoObj:setSocketRedDotInfo({[tostring(ModuleSub.ePracticeBloodyDemonDomain)] = {Default=false}})

                LayerManager.addLayer({
                    name = "challenge.BddLayer",
                    --data = self.params.subData,
                })
            end,
            effectData = {
                [1] = {
                    effectName = "effect_ui_tiaozhan",
                    position = cc.p(155, 215),
                    loop = true,
                    animation = "wuzi",
                }
            }
        },

        -- 行侠仗义(好友BOSS)
        {
            bgImage = "tz_05.png", 
            pos = cc.p(426, 137), 
            effectOffset = cc.p(236, -269), 
            effectScale = 0.42,
            btnImage = "tz_19.png", 
            btnOffset = cc.p(390, 290), 

            clickRect = cc.size(150, 180),
            clickPos = cc.p(350, 280), 
            moduleId = ModuleSub.eBattleBoss,
            action = function ( ... )
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eBattleBoss, true) then
                    return
                end
                MqAudio.playEffect("challenge_flag.mp3")
                LayerManager.addLayer({
                    name = "challenge.BattleBossLayer",
                })
            end,
            effectData = {
                [1] = {
                    effectName = "effect_ui_tiaozhan",
                    position = cc.p(320, 345),
                    loop = true,
                    animation = "qizhi",
                }
            }
        },
        -- 绝情谷
        {
            bgImage = "tz_11.png", 
            pos = cc.p(170, 970), 
            effectOffset = cc.p(236, -269), 
            effectScale = 0.42,
            btnImage = "tz_20.png", 
            btnOffset = cc.p(-10, 70), 

            clickRect = cc.size(170, 180),
            clickPos = cc.p(70, 80), 
            moduleId = ModuleSub.eKillerValley,
            action = function ( ... )
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eKillerValley, true) then
                    return
                end
                -- MqAudio.playEffect("challenge_flag.mp3")
                LayerManager.addLayer({
                    name = "killervalley.KillerValleyHomeLayer",
                })
            end,
        },
    }

    -- 创建各功能
    local zIndex = 1
    for i,v in ipairs(billsList) do
        local bgSprite = ui.newSprite(v.bgImage)
        bgSprite:setPosition(v.pos)
        self.mParentLayer:addChild(bgSprite)
        
        -- 保存控制参数
        bgSprite.startPos = v.pos
        bgSprite.effectOffset = v.effectOffset
        bgSprite.effectScale = v.effectScale
        table.insert(self.bgItemList, bgSprite)
        
        -- 创建特效
        if v.effectData ~= nil then
            for _, value in pairs(v.effectData) do
                local effect = ui.newEffect({
                    parent = bgSprite,
                    effectName = value.effectName,
                    position = value.position,
                    scale = value.scale,
                    loop = value.loop,
                    animation = value.animation
                })
            end
        end

        if v.btnImage then
            -- 显示标题
            local titleSprite = ui.newSprite(v.btnImage)
            titleSprite:setPosition(v.btnOffset)
            bgSprite:addChild(titleSprite)

            -- 有模块Id的按钮需要添加小红点的逻辑
            if v.moduleId then
                local function dealRedDotVisible(redDotSprite)
                    local redDotData = RedDotInfoObj:isValid(v.moduleId)
                    redDotSprite:setVisible(redDotData)
                end
                ui.createAutoBubble({refreshFunc=dealRedDotVisible, parent = titleSprite, 
                    position=cc.p(0.8, 0.9), eventName=RedDotInfoObj:getEvents(v.moduleId)})
            end

            -- 添加可点击区域
            local tempBtn = ui.newButton({
                normalImage = "c_83.png",
                size = v.clickRect,
                position = v.clickPos,
                clickAction = v.action,
            })
            bgSprite:addChild(tempBtn)
            if v.moduleId then  -- 保存功能按钮，引导使用
                self.actionBtnList[v.moduleId] = tempBtn
            end
            -- 默认打开
            if (self.autoOpenModule ~= nil) and (v.moduleId ~= nil) and (self.autoOpenModule == v.moduleId) and (v.action ~= nil) then
                self.autoOpenModule = nil
                Utility.performWithDelay(self.mParentLayer, function () 
                    v.action()
                    LayerManager.setRestoreData("challenge.ChallengeLayer", nil)
                end, 0.01)
            end
        end

        -- 光明顶添加气泡
        if v.moduleId == ModuleSub.eExpedition and ActivityObj:getActivityItem(ModuleSub.eTimedSalesRebornCoin) then
            -- 创建闪烁图标
            local retBtn = ui.newSprite("gmd_11.png")
            local btnSize = bgSprite:getContentSize()
            retBtn:setPosition(cc.p(btnSize.width * 0.68, btnSize.height * 0.87))
            retBtn:setAnchorPoint(cc.p(0.21, 0.08))
            bgSprite:addChild(retBtn)
            retBtn:runAction(cc.RepeatForever:create(cc.Sequence:create({
                cc.ScaleTo:create(0.7, 0.5),
                cc.ScaleTo:create(0.7, 1),
                })))
        end
    end
end

function ChallengeLayer:addTouchEvent()
    local maxOffsetY = 50
    self.lastTouchPos = nil
    local tempListener = cc.EventListenerTouchOneByOne:create()
    tempListener:setSwallowTouches(false)
    tempListener:registerScriptHandler(function (touch, event)
        self.lastTouchPos = touch:getLocation()
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN )
    tempListener:registerScriptHandler(function (touch, event)
        local curPos = touch:getLocation()
        local offsetY = self.lastTouchPos.y - curPos.y
        self.curScrollY = self.curScrollY + offsetY * 0.25
        self.curScrollY = math.max(self.curScrollY, 0)
        self.curScrollY = math.min(self.curScrollY, maxOffsetY)
        local curRate = self.curScrollY / maxOffsetY
        -- 设置各背景的滚动
        for i,v in ipairs(self.bgItemList) do
            v:setPosition(cc.p(v.startPos.x + v.effectOffset.x * curRate, v.startPos.y + v.effectOffset.y * curRate))
            v:setScale(1 + v.effectScale * curRate)
        end

        self.lastTouchPos = curPos
    end, cc.Handler.EVENT_TOUCH_MOVED )
    local eventDispatcher = self.mParentLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(tempListener, self.mParentLayer)
end

-- ========================== 新手引导 ===========================

-- 执行新手引导
function ChallengeLayer:executeGuide()
    local inGuide = Guide.helper:executeGuide({
        -- 点击行侠仗义
        [11305] = {clickNode = self.actionBtnList[ModuleSub.eBattleBoss]},
        -- 点击华山论剑
        [11602] = {clickNode = self.actionBtnList[ModuleSub.eChallengeArena]},
        -- 点击比武招亲
        [115102] = {clickNode = self.actionBtnList[ModuleSub.ePracticeBloodyDemonDomain]},
        -- 点击武林大会
        [11702] = {clickNode = self.actionBtnList[ModuleSub.eChallengeWrestle]},
        -- 点击光明顶
        [403] = {clickNode = self.actionBtnList[ModuleSub.eExpedition], hintPos = cc.p(display.cx, 320 * Adapter.MinScale)},
        -- 点击武林争霸
        [5003] = {clickNode = self.actionBtnList[ModuleSub.ePVPInter], hintPos = cc.p(display.cx, 320 * Adapter.MinScale)},
        -- 点击决战桃花岛
        [6003] = {clickNode = self.actionBtnList[ModuleSub.eShengyuanWars]},
        -- 点击绝情谷
        [10033] = {clickNode = self.actionBtnList[ModuleSub.eKillerValley], hintPos = cc.p(display.cx, 320 * Adapter.MinScale)},
    })
    if inGuide then
        self.mParentLayer:setTouchEnabled(false)
    end
end

return ChallengeLayer
