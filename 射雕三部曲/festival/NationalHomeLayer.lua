--[[
	文件名：FestivalHomeLayer.lua
	描述：国庆活动首页
	创建人: heguanghui
	创建时间: 2017.09.22
--]]

local FestivalHomeLayer = class("FestivalHomeLayer", function()
	return display.newLayer(cc.c4b(0, 0, 0, 128))
end)


-- 构造函数
function FestivalHomeLayer:ctor()
    ui.registerSwallowTouch({node = self})
    local bgLayer = ui.newStdLayer()
    self:addChild(bgLayer)
    -- 显示背景
    local bgSprite = ui.newSprite("jrhd_170.jpg")
    bgSprite:setPosition(320, 568)
    bgLayer:addChild(bgSprite)
    self.mBgSprite = bgSprite

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(595, 1080),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mBgSprite:addChild(self.mCloseBtn)
    
	-- 初始化UI
	self:initUI()
end

-- 初始化UI
function FestivalHomeLayer:initUI()
	local btnList = {
        -- {-- 孔明灯
        --     normalImage = "xn_44.png",
        --     moduleId = ModuleSub.eCommonHoliday19,
        --     position = cc.p(78, 580),
        --     roleList = {[1] = TR("1.活动开启后进入点亮孔明灯选择奖励。"),
        --         [2] = TR("2.选择奖励后每日祈福能让奖励翻倍增加。"),
        --         [3] = TR("3.祈福期结束后可以直接领取奖励。")},
        --     clickAction = function ()
        --         LayerManager.addLayer({name = "festival.KongminLightLayer"})
        --     end
        -- },
        -- {-- 限时掉落
        --     normalImage = "xn_42.png",
        --     position = cc.p(84.5, 275),
        --     moduleId = ModuleSub.eTimedHolidayDrop,
        --     roleList = {[1] = TR("世界杯期间，参与世界杯特色限时掉落活动，可获得世界杯特色材料。"),},
        --     clickAction = function ()
        --         LayerManager.showSubModule(ModuleSub.eTimedHolidayDrop)
        --     end
        -- },
        -- {-- 神雕回礼
        --     normalImage = "xn_39.png",
        --     position = cc.p(398.5, 275),
        --     roleList = {[1] = TR("欢庆世界杯，神雕回礼再度来袭。"),},
        --     moduleId = ModuleSub.eCommonHoliday16,
        --     clickAction = function ()
        --         LayerManager.addLayer({name = "activity.ActivityHawkGiftLayer"})
        --     end
        -- },
        -- {-- 周年大礼
        --     normalImage = "zn_4.png",
        --     position = cc.p(445, 535),
        --     roleList = {[1] = TR("周年庆期间参与周年大礼，即可获得大量稀有道具！"),},
        --     moduleId = ModuleSub.eTimedFiveFu,
        --     clickAction = function ()
        --         LayerManager.addLayer({name = "festival.CollectFiveFuLayer"})
        --     end
        -- },
        -- {-- 祝福任务
        --     normalImage = "zn_2.png",
        --     position = cc.p(182, 403),
        --     roleList = {[1] = TR("周年庆期间，发布祝福任务，领取丰厚奖励！"),},
        --     moduleId = ModuleSub.eTimedBlessingTask,
        --     clickAction = function ()
        --         LayerManager.addLayer({name = "festival.BlessingTaskLayer"})
        --     end
        -- },
        -- {-- 周年掉落
        --     normalImage = "jrhd_125.png",
        --     position = cc.p(320, 195),
        --     roleList = {[1] = TR("活动期间参与限时掉落，各种道具等你来拿!"),},
        --     moduleId = ModuleSub.eTimedHolidayDrop,
        --     clickAction = function ()
        --         LayerManager.showSubModule(ModuleSub.eTimedHolidayDrop)
        --     end
        -- },
        -- {-- 猜灯迷
        --     normalImage = "xn_88.png",
        --     position = cc.p(150, 700),
        --     roleList = {[1] = TR("元宵猜灯谜，趣味知识大问答!"),},
        --     moduleId = ModuleSub.eCommonHoliday21,
        --     clickAction = function ()
        --         LayerManager.addLayer({name = "festival.GuessLightRiddle"})
        --     end
        -- },
        -- {-- 密地挖宝
        --     normalImage = "xn_91.png",
        --     position = cc.p(520, 370),
        --     roleList = {[1] = TR("浪漫情人节，一起来挖宝！"),},
        --     moduleId = ModuleSub.eTimedDigTreasure,
        --     clickAction = function ()
        --         LayerManager.addLayer({name = "festival.DigTreasureLayer"})
        --     end
        -- },
        -- {-- 铸倚天
        --     normalImage = "xn_92.png",
        --     position = cc.p(130, 370),
        --     roleList = {[1] = TR("新年捐献送好礼，一起享用年夜饭！"),},
        --     moduleId = ModuleSub.eChristmasActivity17,
        --     clickAction = function ()
        --         LayerManager.showSubModule(ModuleSub.eChristmasActivity17)
        --     end
        -- },
        -- {-- 神兵谷
        --     normalImage = "jrhd_163.png",
        --     position = cc.p(320, 430),
        --     roleList = {[1] = TR("活动期间将开启神兵谷活动，幻化侠客，破境材料，龙元龙骨等你来拿！"),},
        --     moduleId = ModuleSub.eCommonHoliday27,
        --     clickAction = function ()
        --         LayerManager.addLayer({name = "activity.ActivityTreasureLayer"})
        --     end
        -- },
        -- {-- 金猪赛跑
        --     normalImage = "jrhd_161.png",
        --     position = cc.p(320, 770),
        --     roleList = {[1] = TR("活动期间限时开启金猪赛跑活动，可用积分兑换丰厚奖励！"),},
        --     moduleId = ModuleSub.eCommonHoliday29,
        --     clickAction = function ()
        --         LayerManager.addLayer({name = "activity.ActivityPigCompetitionLayer"})
        --     end
        -- },
        {-- 巅峰挑战
            normalImage = "jrhd_167.png",
            position = cc.p(160, 512),
            roleList = {[1] = TR("周年庆期间开启巅峰挑战活动，活跃即可领取大量奖励！"),},
            moduleId = ModuleSub.eTimedChallenge,
            clickAction = function ()
                LayerManager.addLayer({name = "festival.TopChallengeLayer", cleanUp = true,})
            end
        },
        {-- 累计登录
            normalImage = "jrhd_168.png",
            position = cc.p(160, 270),
            roleList = {[1] = TR("周年庆登录有好礼，稀有道具登录就送！"),},
            moduleId = ModuleSub.eTimedAcumulateLogin,
            clickAction = function ()
                LayerManager.showSubModule(ModuleSub.eTimedAcumulateLogin)
            end
        },
        {-- 剑冢
            normalImage = "jrhd_166.png",
            position = cc.p(478, 270),
            roleList = {[1] = TR("周年庆期间开启独孤剑冢活动，奖励更为丰厚!"),},
            moduleId = ModuleSub.eTimedvegetables,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.VegetablesHomeLayer",
                })
            end
        },
        {-- 江湖秘藏
            normalImage = "jrhd_169.png",
            position = cc.p(478, 512),
            roleList = {[1] = TR("江湖密藏限时开启，完成任务送大礼！"),},
            moduleId = ModuleSub.eCommonHoliday31,
            clickAction = function ()
                LayerManager.addLayer({
                    name = "activity.ActivityWorldSecretLayer",
                })
            end
        },
        {-- 更多活动
            normalImage = "jrhd_20.png",
            position = cc.p(320, 70),
            clickAction = function ()
                LayerManager.showSubModule(ModuleSub.eTimedActivity)
            end
        },
    }
    for _, btnInfo in ipairs(btnList) do 
        local tempBtn = ui.newButton(btnInfo)
        self.mBgSprite:addChild(tempBtn)

        if btnInfo.moduleId then
            local function dealRedDotVisible(redDotSprite)
                redDotSprite:setVisible(RedDotInfoObj:isValid(btnInfo.moduleId))
                -- 小红点位置有点偏下(重新设置Y位置)
                redDotSprite:setPositionY(tempBtn:getContentSize().height-30)
            end
            ui.createAutoBubble({parent = tempBtn, eventName = RedDotInfoObj:getEvents(btnInfo.moduleId), refreshFunc = dealRedDotVisible})

            -- 添加未开启
            local isOpen = ModuleInfoObj:moduleIsOpen(btnInfo.moduleId) and ActivityObj:getActivityItem(btnInfo.moduleId)
            if btnInfo.moduleId == ModuleSub.eShowTheWorldBoss then -- 恶魔来袭不属于活动单独处理
                isOpen = RedDotInfoObj:isValid(btnInfo.moduleId)
            end 
            local btnSize = tempBtn:getContentSize()
            if not isOpen then
                local lockSprite = ui.newSprite("jrhd_165.png")
                lockSprite:setPosition(0, -20)
                lockSprite:setRotation(-30)
                tempBtn:getExtendNode2():addChild(lockSprite)
                tempBtn:setBright(false)
                -- lockSprite:setScale(0.7)

                -- 显示规则
                tempBtn:setClickAction(function()
                    MsgBoxLayer.addXinNianRuleHintLayer(TR("规则"), btnInfo.roleList)
                end)
            end
            -- local smallTextSprite = ui.newSprite(isOpen and "jrhd_22.png" or "jrhd_30.png")
            -- smallTextSprite:setPosition(btnSize.width/2, 10)
            -- smallTextSprite:setAnchorPoint(cc.p(0.5, 0))
            -- tempBtn:addChild(smallTextSprite)
        end
    end

    -- 添加倒计时
    self.mTimeLabel = ui.newLabel({
        text = TR("距活动开始还有: %s", MqTime.toCoutDown(0)),
        color = cc.c3b(0xff, 0xfd, 0xca),
        outlineColor = cc.c3b(0xdf, 0x2a, 0x00),
        size = 22,
    })
    self.mTimeLabel:setAnchorPoint(cc.p(1, 0.5))
    self.mTimeLabel:setPosition(588, 660)
    self.mBgSprite:addChild(self.mTimeLabel)
    local function calcTimeLabel()
        local remainTime = 1518451200 - Player:getCurrentTime()
        remainTime = (remainTime < 0) and 0 or remainTime
        self.mTimeLabel:setString(TR("距活动开始还有: %s", MqTime.toCoutDown(remainTime)))
        self.mTimeLabel:setVisible(remainTime > 0)
    end
    calcTimeLabel()
    -- 定时器
    Utility.schedule(self.mBgSprite, calcTimeLabel, 1)
end


return FestivalHomeLayer