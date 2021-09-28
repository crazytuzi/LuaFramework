--[[
    filename: Guide.GuideConfig.lua
    description: 新手引导步骤相关配置
    date: 2017.02.07

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

local GuideConfig = {
    -- 引导开关(true表示开启引导)
    IF_OPEN = true,

    -- 剧情引导是否上传所有步骤（以前用于运营统计剧情点）
    ifUploadAnyway = false,

    -- 点击战役结点的引导（结点界面、结算界面等使用）
    battleEvent = {1020004, 10201, 10211, 10213, 10215 -- 第一章节点
                    , 10305, 10313, 10407, 10408, 10409 -- 第二章节点
                    , 9004
                },

    -- 点击战斗中的跳过按钮
    clickSkipEvent = {9052, },

    -- 获取启动时的引导纠正表
    -- 用法见 @Guide.manager:correctGuide
    -- 将value置为-1表示跳过该引导
    bootCorrectTable = {
        [1020005] = 1020001,  -- 战斗完成纠正到下一结点(1-1)
        [10212] = 10211,    -- 战斗完成纠正到下一结点
        [10202] = 10204,    -- 战斗完成纠正到商城
        [10206] = 10207,    -- 招募完成，跳到上阵
        [10214] = 10215,    -- 战斗完成纠正到下一结点
        [10216] = 10302,    -- 第一章战斗完指向阵容
        [10306] = 10308,    -- 战斗完成直接跳向队伍界面
        [104] = 10402,      -- 战斗完成直接跳向队伍界面
        [10404]  = 10406,   -- 一键强化之后跳向副本
        [10405]  = 10406,   -- 一键强化之后跳向副本
        [104071] = 10408,   -- 第二章第三节打完
        [104081] = 10409,   -- 第二章第四节打完

        [1101] = 11001,     -- 闯荡江湖开启
        -- [11004] = -1,       -- 中途失败，则结束引导(奇遇可能已不存在，帮不再引导)
        -- [11006] = -1,       -- 中途失败，则结束引导

        [1081] = 108,       -- 开启武林谱
        [10803] = 10804,    -- 战斗完成跳回武林谱
        [11307] = -1,       -- 搜索恶徒标记已完成此引导

        [1091] = 109,       -- 开启拜师学艺
        [10904] = -1,       -- 拜师之后就算完成

        [1121] = 112,       -- 开启神兵功能
        [1131] = 113,       -- 开启神兵升级
        [115011] = 11501,   -- 开启江湖悬赏
        [120] = 1201,       -- 开启自动战斗(挂机)
        [1121011] = 112101, -- 开启斗酒
        [116] = 11601,      -- 开启华山论剑
        [11604] = 11607,    -- 华山论剑战斗完成
        [1151011] = 115101, -- 比武招亲开启
        [115104] = 115105,  -- 比武招亲战斗完成
        [117] = 11701,      -- 武林大会开启
        [117501] = 11709,   -- 武林大会战斗完成
        [118] = 11801,      -- 开启装备锻造
        [11806] = 11807,    -- 锻造返回引导为队伍
        [1191] = 119,       -- 开启守卫襄阳
        [1190304] = -1,     -- 襄阳打完就算完成

        [801] = 802,        -- 每日任务开启
        [901] = 902,        -- 帮派开启
        [904] = 905,        -- 帮派开启
        [9001] = 9002,      -- 大侠之路
        [10001] = 10002,    -- 群侠谱
        [10014] = 10018,    -- 练气返回
        [10014] = 10018,    -- 练气返回
        [10015] = 10018,    -- 练气返回
        [10016] = -1,    -- 练气返回
        [10021] = 10022,    -- 侠影戏
        [10031] = 10032,    -- 绝情谷
        [10066] = 10067,    -- 珍兽
    },


    -- 启动时在Guide.manager:restoreGuide()里面调用，用于恢复新手引导到指定页面
    restoreOnBoot = function(eventID)
        -- 没做过引导，播放CG
        if eventID == 0 then
            Guide.helper:playerFirstBattle()

        -- 第一场战斗
        elseif eventID == 101 then
            Guide.helper:playerFirstBattle()

        -- 恢复到战役界面
        elseif table.indexof(Guide.config.battleEvent, eventID)
            or table.indexof({1020001, 1020003, 10406}, eventID) then
            LayerManager.showSubModule(ModuleSub.eBattle)

        -- 恢复到队伍界面
        elseif table.indexof({10207, 10209, 10302, 10308, 10402, 10404, 11807}, eventID) then
            LayerManager.showSubModule(ModuleSub.eFormation)

        -- 恢复到商城
        elseif table.indexof({10204}, eventID) then
            LayerManager.showSubModule(ModuleSub.eStore)

        -- 行侠仗义
        elseif table.indexof({11305, }, eventID) then
            LayerManager.showSubModule(ModuleSub.eChallenge)

        -- 进入武林谱
        elseif table.indexof({10804, }, eventID) then
            LayerManager.showSubModule(ModuleSub.eBattleElite)

        -- 进入华山论剑
        elseif table.indexof({11607, }, eventID) then
            LayerManager.showSubModule(ModuleSub.eChallengeArena)

        -- 进入比武招亲
        elseif table.indexof({115105, }, eventID) then
            LayerManager.showSubModule(ModuleSub.ePracticeBloodyDemonDomain)

        -- 进入武林大会
        elseif table.indexof({11709, }, eventID) then
            LayerManager.showSubModule(ModuleSub.eChallengeWrestle)

        -- 进入武器锻造
        elseif table.indexof({11204, 11208}, eventID) then
            LayerManager.showSubModule(ModuleSub.eChallengeGrab, {modelId = 15032601})

        -- 进入江湖悬赏
        elseif table.indexof({11504}, eventID) then
            LayerManager.showSubModule(ModuleSub.eXrxs)

        -- 其他情况进入主界面
        else
            Guide.helper:showHomeLayer(eventID)
        end
    end,


    -- 在普通按钮上点击，并且不需要特殊处理时
    -- 可以用这个table来hook按钮的点击事件，自动调用nextStep，减少代码侵入
    -- [事件ID] = [是否上传]
    -- Guide.manager:nextStep(事件ID, 是否上传)
    clickNormalButton = {
        [10200] = false,    -- 指向江湖
        [10209] = false,    -- 上阵完成，指向江湖
        [10217] = false,    -- 第一章打完返回按钮
        [10301] = false,    -- 江湖主界面指向队伍
        [10304] = false,    -- 升10次后点击江湖
        [10308] = false,    -- 主角培养
        [10312] = false,    -- 突破后指引江湖
        [10405] = false,    -- 一键强化之后点击江湖
        [10406] = false,    -- 江湖引导点击第二章
        -- 闯荡江湖
        [11001] = false,    -- 闯荡江湖，点击历练
        [11002] = false,    -- 点击闯荡江湖
        -- [11004] = false,    -- 点击奇遇
        -- [11008] = true,     -- 返回按钮，结束引导
        -- 武林谱
        [108] = false,      -- 武林谱开启，点击江湖
        [10803] = false,    -- 武林谱战斗完成，点击确定
        [113051] = false,   -- 点击挑战
        [11305] = false,    -- 点击行侠仗义
        -- 拜师学艺
        [109] = false,      -- 拜师学艺开启，点击历练
        [10901] = false,    -- 点击拜师学艺
        [10905] = true,     -- 点击时装，引导完成
        -- 悬赏
        [11501] = false,    -- 功能开启，点击历练
        [11502] = false,    -- 点击悬赏
        [11504] = false,    -- 悬赏点击人像
        -- 悬赏失败
        [4001] = false,     -- 开启悬赏失败引导
        [4002] = false,     -- 佣兵招募按钮
        [4004] = false,     -- 布阵+号
        [4005] = false,     -- 招募按钮
        [4008] = false,     -- 布阵确定按钮
        [4009] = false,     -- 再次悬赏点击人像
        -- 神兵
        [11201] = false,    -- 进队伍按钮
        [11204] = false,    -- 进入矿场
        [11209] = false,    -- 锻造完成，进入队伍
        -- 神兵升级
        [113] = false,      -- 进队伍按钮
        [11302] = false,    -- 点击神兵强化按钮
        -- 装备锻造
        [11801] = false,    -- 进队伍按钮
        [11804] = false,    -- 点击锻造按钮
        [11806] = false,    -- 锻造完成，关闭界面
        [11807] = false,    -- 培养共鸣
        [11808] = true,     -- 共鸣点锻造，引导结束
        -- 斗酒
        [112101] = false,   -- 点击历练
        [112102] = false,   -- 点击拼酒
        -- 华山论剑
        [11601] = false,    -- 点击挑战
        [11602] = false,    -- 点击华山论剑
        [11604] = false,    -- 战斗翻牌
        [11605] = false,    -- 翻牌后确定
        [11607] = false,    -- 点击兑换
        [11608] = true,     -- 兑换商店关闭, 引导结束
        -- 自动战斗
        [1201] = false,     -- 点击江湖
        [1202] = false,     -- 点击挂机
        -- 比武招亲
        [115101] = false,   -- 点击挑战
        [115102] = false,   -- 点击比武招亲
        [115104] = false,   -- 战斗完成关闭
        [115107] = true,    -- 商店关闭，引导结束
        -- 武林大会
        [11701] = false,    -- 点击挑战
        [11702] = false,    -- 点击武林大会
        [117501] = false,   -- 战斗翻牌
        [117502] = false,   -- 战斗关闭
        [11709] = false,    -- 兑换按钮
        [11710] = true,     -- 兑换商店关闭，引导结束
        -- 守卫襄阳
        [11901] = false,    -- 点击历练
        [11902] = false,    -- 点击襄阳
        [1190301] = false,  -- 组队开战
        [1190302] = false,  -- 点击邀请
        [1190303] = false,  -- 点击自动匹配
        [1190304] = false,  -- 战斗完成，确认
        [11903041] = true,  -- 指向商店，引导结束
        -- 每日任务
        [802] = false,      -- 指向任务
        [803] = true,       -- 引导完成
        -- 帮派
        [902] = false,      -- 指向帮派
        [903] = false,      -- 指向帮派
        [904] = true,      -- 指向帮派
        [905] = true,      -- 指向帮派
        -- 守卫光明顶
        [402] = false,      -- 指向挑战
        [403] = true,       -- 指向守卫光明顶，引导完成
        -- 武林争霸
        [5002] = false,     -- 指向挑战
        [5003] = true,      -- 指向武林争霸，引导完成
        -- 决战桃花岛
        [6002] = false,     -- 指向挑战
        [6003] = true,      -- 指向决战桃花岛，引导完成
        -- 经脉, 队伍中保存最后一步
        [7002] = false,     -- 指向队伍
        -- 门派
        [8002] = true,      -- 指向门派，引导完成
        -- 大侠之路
        [9003] = false,
        -- 指向练气炼丹
        [10012] = false,
        [10014] = false,
        [10015] = false,
        -- 指向绝情谷
        [10032] = false,
        [10033] = false,
        -- 珍兽
        [10063] = false,
        [10064] = false,
        [10065] = true,
        [10066] = false,
        [10068] = false,
        [10069] = true,
    },


    -- 功能开启界面的图标及跳转函数
    moduleOpenConfig = {
        -- 守卫光明顶
        [401] = {
            icon = "tb_185.png",
            jump = "home",
        },
        -- 武林争霸
        [5001] = {
            icon = "tb_186.png",
            jump = "home",
        },
        -- 决战桃花岛
        [6001] = {
            icon = "tb_187.png",
            jump = "home",
        },
        -- 经脉
        [7001] = {
            icon = "tb_188.png",
            jump = "home",
        },
        -- 门派
        [8001] = {
            icon = "tb_190.png",
            jump = "home",
        },
        -- 练气
        [10011] = {
            icon = "tb_268.png",
            jump = "home",
        },
        -- 名望
        [10041] = {
            icon = "tb_274.png",
            jump = "home",
        },
        -- 江湖杀
        [10051] = {
            icon = "tb_300.png",
            jump = "home",
        },
        -- 珍兽
        [10061] = {
            icon = "tb_311.png",
            jump = "home",
        },
    },


    -- 引导步骤的额外参数
    -- scaleX/scaleY/hintPos 等写在这里，后面调整时不需要去找引导的执行代码
    eventParams = {
        -- [109] = {clickScaleX = 0.6},
        -- [304] = {hintPos = cc.p(display.cx, 120 * Adapter.MinScale),},
    },


    -- 调用GuideHelper:showTeamLayer时，应该显示哪个人物位置
    -- [eventID] -> showIndex
    eventToTeamIdx = {
        -- 人物升级，显示2号位
        -- [204] = 2,
    },


    -- 调用GuideHelper:showHomeLayer时的传入参数
    homeLayerData = {
        -- [2909] = {
        --     mapData = {
        --         eliteChapterId = 11,
        --         isNeedel       = true,
        --         isTask         = true,
        --         ismoveTotarget = true,
        --     },
        -- }
    },

    -- 调用GuideHelper:showBattleNormalLayer时，传入BattleNormalLayer的数据
    eventToBattleData = {
        -- [137]  = {chapterId = 11, },
        -- [1382] = {chapterId = 12, },
    },

    -- 用于运营统计的特殊ID
    recordID = 0,
}

return GuideConfig
