--[[
    filename: ComBattle.Custome.BattlePatch
    description: 战斗代码补丁，用于各个项目战斗代码适配
    date: 2016.12.16

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

bd.project = "project_shediao"

-- 托管状态枚举
Enums.trustee = bd.trusteeState

bd.ui_config.skillHeaderMaskPic = "zb_15.png"
bd.ui_config.killRPTipPic = "zd_46.png"

bd.ui_config.roundLabelPos = bd.ui_config.autoPos({midX = 0, midY = 1136/2-31})
bd.ui_config.skipBtnPos = bd.ui_config.autoPos({midX = 260, midY = 1136/2-32})
bd.ui_config.trusteeBtnPos = bd.ui_config.autoPos({midX = 75 - bd.ui_config.DESIGN_CX, midY = 1136/2-32})

bd.ui_config.defaultFigureName = "hero_zhujiuzhen"

-- 加载页
bd.ui_config.loadingFrontPic = "ld_01.png"
bd.ui_config.loadingBgPic    = "ld_02.png"
bd.ui_config.loadingMapPic   = {
    "ld_03.jpg",
}
bd.ui_config.loadingFlagPic = "ld_04.png"

-- 出场时脚下特效
bd.ui_config.heroEntryEffect = {"effect_chuxian", }

-- 施法框
bd.ui_config.skillEffect = {"effect_ui_shifang", "zhanshi"}

-- 人物阴影
bd.ui_config.heroShadowPic = "ef_c_67.png"

-- 组队战开场图片
bd.ui_config.teamViewBg  = "jsxy_04.png"
bd.ui_config.teamBattle1 = "zd_45.png"
bd.ui_config.teamBattle2 = "zd_46.png"
bd.ui_config.teamBattle3 = "zd_47.png"

-- boss血条
bd.ui_config.bossHpBarBgPic    = "zd_10.png"
bd.ui_config.bossHpBarFrontPic = "zd_11.png"
-- boss怒气
bd.ui_config.bossRpBarBgPic    = "zd_10.png"
bd.ui_config.bossRpBarFrontPic = "zd_12.png"

bd.ui_config.skipBtnPic = "zd_05.png"

-- 血条
bd.ui_config.hpBarBgPic    = "zd_01.png"
bd.ui_config.hpBarFrontPic = "zd_02.png"
-- 怒气条
bd.ui_config.rpBarBgPic    = "zd_01.png"
bd.ui_config.rpBarFrontPic = "zd_03.png"

-- 托管按钮图片
bd.ui_config.trusteeBtnPic = {
    [bd.trusteeState.eNormal]            = "zd_08.png",
    [bd.trusteeState.eSpeedUp]           = "zd_06.png",
    [bd.trusteeState.eSpeedUpAndTrustee] = "zd_07.png",
}

-- 提示图片
bd.ui_config.effectTipPic = {
    [bd.adapter.config.damageType.eDODGE]    = "buff_shanbi.png", -- 闪避
    [bd.adapter.config.damageType.eCRITICAL] = "buff_baoji.png", -- 暴击
    [bd.adapter.config.damageType.eBLOCK]    = "buff_gedang.png", -- 格挡
}

-- 数值图片
bd.ui_config.effectNumberPic = {
    [bd.adapter.config.damageType.eNORMAL]       = {"zd_13.png", 30, 39, 46},
    [bd.adapter.config.damageType.eCRITICAL]     = {"zd_15.png", 40, 52, 46},
    [bd.adapter.config.damageType.eHEAL]         = {"zd_14.png", 30, 39, 46},
    [bd.adapter.config.damageType.eCRITICALHEAL] = {"zd_14.png", 30, 39, 46},
    [bd.adapter.config.damageType.eBLOCK]        = {"zd_13.png", 30, 39, 46},
}

--剧情对话背景图
bd.ui_config.chatBG = "xsyd_10.png"

-- 死亡特效
bd.ui_config.heroDeadEffect = {"effect_siwang", }

-- 怒技使用的zorder差值
bd.ui_config.diffz = 100

bd.ui_config.petBase = 30

-- 人物朝向
bd.ui_config.posSkew = {
    [1]  = false,
    [2]  = false,
    [3]  = false,

    [4]  = false,
    [5]  = false,
    [6]  = false,

    [7]  = true,
    [8]  = true,
    [9]  = true,

    [10] = true,
    [11] = true,
    [12] = true,

    [13] = true,
    [14] = true,
    [15] = true,

    [bd.ui_config.petBase+1]  = false,
    [bd.ui_config.petBase+2]  = true,
}

-- 人物站位
bd.ui_config.position = {
    [1]  = bd.ui_config.autoPos3D({midX = 170 - bd.ui_config.DESIGN_CX, midY = 950 - bd.ui_config.DESIGN_CY - 50, z = -700}),
    [2]  = bd.ui_config.autoPos3D({midX = 160 - bd.ui_config.DESIGN_CX, midY = 650 - bd.ui_config.DESIGN_CY - 50, z = -500}),
    [3]  = bd.ui_config.autoPos3D({midX = 150 - bd.ui_config.DESIGN_CX, midY = 350 - bd.ui_config.DESIGN_CY - 50, z = -300}),

    [4]  = bd.ui_config.autoPos3D({midX = 70 - bd.ui_config.DESIGN_CX - 50, midY = 800 - bd.ui_config.DESIGN_CY - 50, z = -600}),
    [5]  = bd.ui_config.autoPos3D({midX = 60 - bd.ui_config.DESIGN_CX - 50, midY = 500 - bd.ui_config.DESIGN_CY - 50, z = -400}),
    [6]  = bd.ui_config.autoPos3D({midX = 50 - bd.ui_config.DESIGN_CX - 50, midY = 200 - bd.ui_config.DESIGN_CY - 50, z = -200}),

    [7]  = bd.ui_config.autoPos3D({midX = -(170 - bd.ui_config.DESIGN_CX), midY = 950 - bd.ui_config.DESIGN_CY - 50, z = -700}),
    [8]  = bd.ui_config.autoPos3D({midX = -(160 - bd.ui_config.DESIGN_CX), midY = 650 - bd.ui_config.DESIGN_CY - 50, z = -500}),
    [9]  = bd.ui_config.autoPos3D({midX = -(150 - bd.ui_config.DESIGN_CX), midY = 350 - bd.ui_config.DESIGN_CY - 50, z = -300}),

    [10] = bd.ui_config.autoPos3D({midX = -(70 - bd.ui_config.DESIGN_CX) + 50, midY = 800 - bd.ui_config.DESIGN_CY - 50, z = -600}),
    [11] = bd.ui_config.autoPos3D({midX = -(60 - bd.ui_config.DESIGN_CX) + 50, midY = 500 - bd.ui_config.DESIGN_CY - 50, z = -400}),
    [12] = bd.ui_config.autoPos3D({midX = -(50 - bd.ui_config.DESIGN_CX) + 50, midY = 200 - bd.ui_config.DESIGN_CY - 50, z = -200}),

    [13] = bd.ui_config.autoPos3D({midX = 0, midY = 760 - bd.ui_config.DESIGN_CY, z = -350}),
    [14] = bd.ui_config.autoPos3D({midX = -100, midY = 630 - bd.ui_config.DESIGN_CY, z = -400}),
    [15] = bd.ui_config.autoPos3D({midX = 0, midY = 200 - bd.ui_config.DESIGN_CY, z = -50}),

    [bd.ui_config.petBase+1]  = bd.ui_config.autoPos3D({midX = 170 - bd.ui_config.DESIGN_CX-30, midY = 100 - bd.ui_config.DESIGN_CY - 50, z = -200}),
    [bd.ui_config.petBase+2]  = bd.ui_config.autoPos3D({midX = -(170 - bd.ui_config.DESIGN_CX-30), midY = 100 - bd.ui_config.DESIGN_CY - 50, z = -200}),
}

bd.interface.cacheHeroDaijiImage = function()end

--[[-------------------------------------------------------------------------

---------------------------------------------------------------------------]]
bd.patch = {
    nodeScale = 0.7,

    entryAudio = "hero_entry_audio.mp3",

    -- 预加载
    preloadSpines = {
        ["effect_ui_chuchangyanchen"] = true,
        ["effect_tongyisiwang"]       = true,
        ["effect_ui_shifang"]         = true,
        ["effect_tongyichufa"]        = true,
        ["effect_tongyiqieping_nan"]  = true,
        ["effect_tongyiqieping_nv"]   = true,
        ["effect_chuxian"]            = true,
        ["effect_shanping"]           = true,
        ["effect_ui_dianjitishi"]     = true,
        ["effect_nujifenwei"]         = true,
        ["effect_tongyisuduxian"]     = true,
        ["effect_siwang"]             = true,
    },

    preloadAudios = {
        ["effect_c_nujichufa.mp3"]         = true,
        ["hero_entry_audio.mp3"]            = true,
        ["effect_buff_siwangshanghai.mp3"] = true,
    },

    -- 技能切屏实现
    skillFeature = require("ComBattle.Custom.BDSkillFeature"),

    -- 回合技
    roundPetAction = require("ComBattle.Custom.BDRoundPetAction"),

    -- 获取道法形象
    getTaoImage = function(id)
        local item = TaoModel.items[id]
        return item and (item.prPic .. ".png")
    end,

    -- 获取loading提示
    getLoadingTips = function()
        if LoadingtipsModel then
            local max = #LoadingtipsModel.items
            return LoadingtipsModel.items[bd.func.random(1, max)].text
        end
        return ""
    end,

    getPreLoadFiles = function(battleData, battleSpdy)
        local pictures, largePics, audioFiles = {}, {}, {}

        local stageData = battleData.battle_.stageData
        -- 遍历关卡数据
        for _, data in ipairs(stageData) do
            local function load_hero(list)
                for i, hero in pairs(list) do
                    if next(hero) ~= nil then
                        local item = HeroModel.items[hero.HeroModelId]
                        if item.drawingPicA ~= "" then
                            largePics[item.drawingPicA] = true
                        end
                        if item.drawingPicB ~= "" then
                            largePics[item.drawingPicB] = true
                        end
                        if item.jointSkillSound ~= "" then
                            local sound = Utility.getJointSkilSound(item)
                            audioFiles[sound .. ".mp3"] = true
                        end
                    end
                end
            end

            -- 遍历主将
            load_hero(data.HeroList)
            if data.StorageList then
                for _, list in pairs(data.StorageList) do
                    load_hero(list)
                end
            end
        end

        return pictures, largePics, audioFiles
    end,

    outPos = {
        [1]  = bd.ui_config.autoPos3D({midX = -60, midY = 550 - bd.ui_config.DESIGN_CY, z = -350}),
        [2]  = bd.ui_config.autoPos3D({midX = -50, midY = 375 - bd.ui_config.DESIGN_CY, z = -150}),
        [3]  = bd.ui_config.autoPos3D({midX = -60, midY = 200 - bd.ui_config.DESIGN_CY, z = -50}),

        [4]  = bd.ui_config.autoPos3D({midX = -60, midY = 950 - bd.ui_config.DESIGN_CY, z = -700}),
        [5]  = bd.ui_config.autoPos3D({midX = -50, midY = 760 - bd.ui_config.DESIGN_CY, z = -500}),
        [6]  = bd.ui_config.autoPos3D({midX = -60, midY = 560 - bd.ui_config.DESIGN_CY, z = -300}),

        [7]  = bd.ui_config.autoPos3D({midX = 60, midY = 550 - bd.ui_config.DESIGN_CY, z = -350}),
        [8]  = bd.ui_config.autoPos3D({midX = 50, midY = 375 - bd.ui_config.DESIGN_CY, z = -150}),
        [9]  = bd.ui_config.autoPos3D({midX = 60, midY = 200 - bd.ui_config.DESIGN_CY, z = -50}),

        [10] = bd.ui_config.autoPos3D({midX = 60, midY = 950 - bd.ui_config.DESIGN_CY, z = -700}),
        [11] = bd.ui_config.autoPos3D({midX = 50, midY = 760 - bd.ui_config.DESIGN_CY, z = -500}),
        [12] = bd.ui_config.autoPos3D({midX = 60, midY = 560 - bd.ui_config.DESIGN_CY, z = -300}),
    },

    heroEnter = function(nodes, cb)
        bd.func.each({1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}, function(cont, i)
            local node = nodes[i]
            if not node then
                return cont()
            end

            local teaminfo = bd.layer.data:get_battle_teaminfo()
            local stageIdx = bd.layer.data:get_battle_stageIdx()
            if teaminfo and stageIdx > 1 and bd.interface.isEnemy(i) then
                return cont()
            end

            -- bd.adapter.audio.playSound(bd.patch.entryAudio)
            local jumpType = bd.interface.isEnemy(i) and bd.CONST.entryType.eJumpRight or bd.CONST.entryType.eJumpLeft

            local delay = math.random(0, 800) / 1000
            bd.func.performWithDelay(node, function()
                node:setVisible(true)
                require("ComBattle.Common.BDFigureEntry").exec[jumpType]({
                    isOut    = false,
                    node     = node,
                    callback = function()
                        return cont()
                    end,
                })
            end, delay)
        end, function()
            bd.func.each({1, 2}, function(cont, i)
                local node = nodes[bd.ui_config.petBase+i]
                if not node then
                    return cont()
                end
                local jumpType = bd.interface.isEnemy(bd.ui_config.petBase+i) and bd.CONST.entryType.eJumpRight or bd.CONST.entryType.eJumpLeft
                local delay = math.random(0, 800) / 1000
                bd.func.performWithDelay(node, function()
                    node:setVisible(true)
                    require("ComBattle.Common.BDFigureEntry").exec[jumpType]({
                        isOut    = false,
                        node     = node,
                        callback = function()
                            return cont()
                        end,
                    })
                end, delay)
            end, function()
                bd.func.performWithDelay(cb, 0.3)
            end)
        end)
    end,

    -- 弃用
    heroEnter_ = function(nodes, cb)
        local effectScale = 0.88

        local function createFlashEffect(node)
            local i = node.idx
            local ef = ui.newEffect({
                parent     = node:getParent(),
                scale      = bd.patch.nodeScale * effectScale,
                zorder     = node:getLocalZOrder(),
                effectName = "effect_ui_chuchang",
            })
            if bd.interface.isFriendly(i) then
                ef:setRotation3D(cc.vec3(0, 180, 0))
                ef:setPosition3D(cc.vec3(bd.ui_config.cx - 265* effectScale * Adapter.MinScale,
                    bd.patch.outPos[i].y + 200 * Adapter.MinScale * bd.patch.nodeScale,
                    bd.patch.outPos[i].z))
            else
                ef:setPosition3D(cc.vec3(bd.ui_config.cx + 265* effectScale * Adapter.MinScale,
                    bd.patch.outPos[i].y + 200 * Adapter.MinScale * bd.patch.nodeScale,
                    bd.patch.outPos[i].z))
            end
        end

        bd.func.each({1, 2, 3, 7, 8, 9}, function(cont, i)
            local node = nodes[i]
            if node then
                node:setVisible(true)
                node:runAction(cc.Sequence:create(
                    cc.MoveTo:create(0.1, bd.patch.outPos[i]),
                    cc.CallFunc:create(function()
                        createFlashEffect(node)
                    end),
                    cc.DelayTime:create(0.5),
                    cc.EaseBackOut:create(cc.MoveTo:create(0.3, bd.interface.getStandPos(i)))
                ))
            end
            bd.func.performWithDelay(cont, 0.2)
        end, function()
            bd.func.each({4, 5, 6, 10, 11, 12}, function(cont, i)
                local node = nodes[i]
                if node then
                    node:setVisible(true)
                    node:runAction(cc.Sequence:create(
                        cc.MoveTo:create(0.1, bd.patch.outPos[i]),
                        cc.CallFunc:create(function()
                            createFlashEffect(node)
                        end),
                        cc.DelayTime:create(0.5),
                        cc.EaseBackOut:create(cc.MoveTo:create(0.3, bd.interface.getStandPos(i))),
                        cc.CallFunc:create(cont)
                    ))
                else
                    cont()
                end
            end, function()
                bd.func.performWithDelay(cb, 0.3)
            end)
        end)
    end,
}


if not bd.patch.preloadPictures then
    bd.patch.preloadPictures = {}
end

-- 伤害数字
for k, v in pairs(bd.ui_config.effectNumberPic) do
    bd.patch.preloadPictures[v[1]] = true
end

-- 伤害类型
for k, v in pairs(bd.ui_config.effectTipPic) do
    bd.patch.preloadPictures[v] = true
end

bd.patch.preloadPictures[bd.ui_config.hpBarBgPic]         = true
bd.patch.preloadPictures[bd.ui_config.hpBarFrontPic]      = true
bd.patch.preloadPictures[bd.ui_config.rpBarBgPic]         = true
bd.patch.preloadPictures[bd.ui_config.rpBarFrontPic]      = true
bd.patch.preloadPictures[bd.ui_config.killRPTipPic]       = true
bd.patch.preloadPictures[bd.ui_config.skillHeaderMaskPic] = true
bd.patch.preloadPictures[bd.ui_config.heroShadowPic]      = true

bd.patch.buffTagImages = {
    "buff_bumie.png",
    "buff_chenmo.png",
    "buff_fanji.png",
    "buff_gedang.png",
    "buff_hudun.png",
    "buff_huifu.png",
    "buff_jdbaoji.png",
    "buff_jdfangyu.png",
    "buff_jdgedang.png",
    "buff_jdgongji.png",
    "buff_jdmianshang.png",
    "buff_jdmingzhong.png",
    "buff_jdnuqi.png",
    "buff_jdpoji.png",
    "buff_jdrenxing.png",
    "buff_jdshanbi.png",
    "buff_jdshanghai.png",
    "buff_lianji.png",
    "buff_mabi.png",
    "buff_mohua.png",
    "buff_qusan.png",
    "buff_shanbi.png",
    "buff_tsbaoji.png",
    "buff_tsfangyu.png",
    "buff_tsgedang.png",
    "buff_tsgongji.png",
    "buff_tsmianshang.png",
    "buff_tsminghzong.png",
    "buff_tsnuqi.png",
    "buff_tspoji.png",
    "buff_tsrenxing.png",
    "buff_tsshanbi.png",
    "buff_tsshanghai.png",
    "buff_wudi.png",
    "buff_xuanyun.png",
    "buff_zhongdu.png",
    "buff_bindong.png",
    "buff_dikang.png",
}

-- 挨打位置
bd.patch.attackMovePos = {
    bd.ui_config.autoPos3D({
        midX = 150,
        midY = 0,
        z    = -350,
    }),
    bd.ui_config.autoPos3D({
        midX = -150,
        midY = 0,
        z    = -350,
    }),
}
bd.patch.attackMoveOffset = {
    [1] = {
        cc.vec3(0, 0, 0),
    },
    [2] = {
        cc.vec3(-40, -70* bd.ui_config.MinScale, 50),
        cc.vec3(60* bd.ui_config.MinScale, 70* bd.ui_config.MinScale, -50),
    },
    [3] = {
        cc.vec3(60* bd.ui_config.MinScale, -140* bd.ui_config.MinScale, 50),
        cc.vec3(-55* bd.ui_config.MinScale, 0, 0),
        cc.vec3(95* bd.ui_config.MinScale, 125* bd.ui_config.MinScale, -50),
    },
    [4] = {
        cc.vec3(0, -130* bd.ui_config.MinScale, 50),
        cc.vec3(-100* bd.ui_config.MinScale, 0, 0),
        cc.vec3(30* bd.ui_config.MinScale, 150* bd.ui_config.MinScale, -50),
        cc.vec3(130* bd.ui_config.MinScale, -30* bd.ui_config.MinScale, 0),
    },
    [5] = {
        cc.vec3(110* bd.ui_config.MinScale, -180* bd.ui_config.MinScale, 90),
        cc.vec3(-120* bd.ui_config.MinScale, 0, 0),
        cc.vec3(30* bd.ui_config.MinScale, 80* bd.ui_config.MinScale, -50),
        cc.vec3(0, -80* bd.ui_config.MinScale, 50),
        cc.vec3(130* bd.ui_config.MinScale, 180* bd.ui_config.MinScale, -90),
    },
    [6] = {
        cc.vec3(110* bd.ui_config.MinScale, -180* bd.ui_config.MinScale, 90),
        cc.vec3(-120* bd.ui_config.MinScale, 0, 0),
        cc.vec3(30* bd.ui_config.MinScale, 80* bd.ui_config.MinScale, -50),
        cc.vec3(0, -80* bd.ui_config.MinScale, 50),
        cc.vec3(130* bd.ui_config.MinScale, 180* bd.ui_config.MinScale, -90),
        cc.vec3(120* bd.ui_config.MinScale, 0, 0),
    },
}

-- @攻击时移动被攻击者
function bd.patch.moveAttackTargets(attackNodes)
    local positions = bd.patch.attackMoveOffset[#attackNodes]
    if positions then
        local negative = bd.interface.isFriendly(attackNodes[1].idx)
        local basePos = negative and bd.patch.attackMovePos[2] or bd.patch.attackMovePos[1]

        for i = 1, #attackNodes do
            local node = attackNodes[i]
            local pos
            if negative then
                pos = cc.vec3(basePos.x - positions[i].x,
                            basePos.y - positions[i].y,
                            basePos.z - positions[i].z)
            else
                pos = cc.vec3(basePos.x + positions[i].x,
                            basePos.y + positions[i].y,
                            basePos.z + positions[i].z)
            end

            node:move_to(pos)
        end
    end
end
