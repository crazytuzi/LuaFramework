--[[
    filename: ComBattle.UICtrl.BDUIConfig.lua
    description: 战斗模块UI界面相关定义
    date: 2016.08.15

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

local width  = display.width
local height = display.height
local cx     = width / 2
local cy     = height / 2
local DESIGN_WIDTH = 640
local DESIGN_HEIGHT = 1136
local DESIGN_CX    = DESIGN_WIDTH / 2
local DESIGN_CY    = DESIGN_HEIGHT / 2

local AutoScaleX = display.width / DESIGN_WIDTH
local AutoScaleY = display.height / DESIGN_HEIGHT
local MinScale   = math.min(AutoScaleX, AutoScaleY)
local MaxScale   = math.max(AutoScaleX, AutoScaleY)


--[[
x / left / right / midX
y / bottom / top / midY
-- right: 距离右边宽度
-- top:   距离顶部高度
-- midX:  距离中心距离
-- midY:  距离中心距离
--]]
local function autoPos(x, y)
    local params
    if type(x) == "table" then
        params = x
    else
        params = {x = x, y = y}
    end

    local x = params.x or params.left
    if not x then
        if params.right then
            x = (width - (params.right * MinScale)) / AutoScaleX
        elseif params.midX then
            x = ((width / 2) + (params.midX * MinScale)) / AutoScaleX
        end
    end

    local y = params.y or params.bottom
    if not y then
        if params.top then
            y = (height - (params.top * MinScale)) / AutoScaleY
        elseif params.midY then
            y = ((height / 2) + (params.midY) * MinScale) / AutoScaleY
        end
    end

    return cc.p((x or 0) * AutoScaleX, (y or 0) * AutoScaleY)
end

--[[
x / left / right / midX
y / bottom / top / midY
z
-- right: 距离右边宽度
-- top:   距离顶部高度
-- midX:  距离中心距离
-- midY:  距离中心距离
--]]
local function autoPos3D(x, y, z)
    local params
    if type(x) == "table" then
        params = x
    else
        params = {x = x, y = y, z = z}
    end
    local p = autoPos(params)
    local z = (params.z or 0) * MinScale
    return cc.vec3(p.x, p.y, z)
end

local BDUIConfig = {
    --剧情中用到的手指图片
    guideFigurePic = "xsyd_02.png",

    --对话背景
    chatBG = "xsyd_10.png",

    -- 托管按钮图片
    trusteeBtnPic = {
        [bd.trusteeState.eNormal]            = "zd_43.png",
        [bd.trusteeState.eSpeedUp]           = "zd_41.png",
        [bd.trusteeState.eSpeedUpAndTrustee] = "zd_42.png",
    },
    trusteeBtnPos = autoPos({midX = 80 - DESIGN_CX, top = 38}),

    -- 跳过按钮
    skipBtnPic = "zd_39.png",
    skipBtnPos = autoPos({midX = 596 - DESIGN_CX, top = 38}),

    -- 挑战信息
    chanllengLabelPos = autoPos({midX = 320 - 25, top = 86}),

    -- 回合数
    -- roundLabelPos = autoPos({x = 370, top = 38}),

    -- @加载界面进度条
    loadingBgPic = "loading02.png",
    loadingFrontPic = "loading03.png",
    -- 加载界面背景
    loadingMapPic = {
        "ld_03.jpg",
        "ld_04.jpg",
        "ld_05.jpg",
    },

    -- 施法框 mask
    skillHeaderMaskPic = "c_12.png",
    skillEffect = {"effect_ui_shifang", "zhanshi"},
    -- 是否在人物身上施法
    skillOnHero = false,

    -- 施法蓄力闪烁
    castingEffect = {"effect_tongyichufa", },

    -- 出场时脚下特效
    heroEntryEffect = {"effect_tongyi_zhandouchuxian", },

    -- 人物死亡特效
    heroDeadEffect = {"effect_tongyisiwang", },

    -- 人物阴影
    heroShadowPic = "c_192.png",

    -- 血条
    hpBarBgPic    = "zd_34.png",
    hpBarFrontPic = "zd_35.png",
    -- 怒气条
    rpBarBgPic    = "zd_34.png",
    rpBarFrontPic = "zd_36.png",

    -- boss血条
    bossHpBarBgPic    = "fb_77.png",
    bossHpBarFrontPic = "fb_78.png",
    -- boss怒气
    bossRpBarBgPic    = "fb_77.png",
    bossRpBarFrontPic = "fb_79.png",

    -- 击杀怒气
    killRPTipPic = "zd_44.png",

    -- 组队战开场图片
    teamViewBg  = "jzzyk_22.png",
    teamBattle1 = "jyzf_53.png",
    teamBattle2 = "jyzf_54.png",
    teamBattle3 = "jyzf_55.png",

    -- 特殊处理的buff
    specialBuffEffect = {
        unDead  = {"effect_buff_qiangzhibusi", "animation", },
        rebirth = {"effect_buff_fuhuo", "animation", },
        zhiming = {"effect_buff_ddzmsh", "animation", },
    },

    -- 数值图片
    effectNumberPic = {
        [bd.adapter.config.damageType.eNORMAL]       = {"zd_01.png", 27, 40, 46},
        [bd.adapter.config.damageType.eCRITICAL]     = {"zd_03.png", 32, 51, 46},
        [bd.adapter.config.damageType.eHEAL]         = {"zd_02.png", 27, 40, 46},
        [bd.adapter.config.damageType.eCRITICALHEAL] = {"zd_02.png", 27, 40, 46},
        [bd.adapter.config.damageType.eBLOCK]        = {"zd_01.png", 27, 40, 46},
    },

    -- 提示图片
    effectTipPic = {
        [bd.adapter.config.damageType.eDODGE]    = "zd_08.png", -- 闪避
        [bd.adapter.config.damageType.eCRITICAL] = "zd_14.png", -- 暴击
        [bd.adapter.config.damageType.eBLOCK]    = "zd_04.png", -- 格挡
    },

    buffEffectPostOffset = {
        effect_buff_zhongdu        = cc.p(0, 155),
        effect_buff_mianyi         = cc.p(0, 135),
        effect_buff_mianyishanghai = cc.p(0, 135),
        effect_buff_jianyi         = cc.p(0, 0),
        effect_buff_zengyi         = cc.p(0, 0),
        effect_buff_fuhuo          = cc.p(0, 0),
        effect_buff_hudun          = cc.p(0, 0),
        effect_buff_ddzmsh         = cc.p(0, 135),
        effect_buff_siwangshanghai = cc.p(0, 0),
        effect_buff_chenmo         = cc.p(0, 135),
        effect_buff_lianji         = cc.p(0, 210),
        effect_buff_fanji          = cc.p(5, 210),
        effect_buff_qcfmxg         = cc.p(0, 320),
        effect_buff_xuanyun        = cc.p(0, 0),
        effect_buff_qiangzhibusi   = cc.p(0, 150),
        effect_buff_qiangzhibusi   = cc.p(0, 150),
        effect_buff_bindong        = cc.p(0, 50),
    },

    buffEffectScale = {
        effect_buff_jianyi = 2,
    },

    -- 人物朝向
    posSkew = {
        [1]  = false,
        [2]  = true,
        [3]  = true,

        [4]  = false,
        [5]  = false,
        [6]  = true,

        [7]  = false,
        [8]  = false,
        [9]  = true,

        [10] = false,
        [11] = false,
        [12] = true,

        [13] = false,
        [14] = false,
        [15] = true,
    },

    -- 人物站位
    position = {
        [1]  = autoPos3D({midX = 70 - DESIGN_CX, midY = 300 - DESIGN_CY, z = -100}),
        [2]  = autoPos3D({midX = 300 - DESIGN_CX, midY = 315 - DESIGN_CY, z = -100}),
        [3]  = autoPos3D({midX = 530 - DESIGN_CX, midY = 330 - DESIGN_CY, z = -100}),

        [4]  = autoPos3D({midX = 80 - DESIGN_CX,  midY = 100 - DESIGN_CY, z = 0}),
        [5]  = autoPos3D({midX = 350 - DESIGN_CX, midY = 115 - DESIGN_CY, z = 0}),
        [6]  = autoPos3D({midX = 580 - DESIGN_CX, midY = 130 - DESIGN_CY, z = 0}),

        [7]  = autoPos3D({midX = -50 - DESIGN_CX, midY = 740 - DESIGN_CY, z = -500}),
        [8]  = autoPos3D({midX = 180 - DESIGN_CX, midY = 750 - DESIGN_CY, z = -500}),
        [9]  = autoPos3D({midX = 410 - DESIGN_CX, midY = 760 - DESIGN_CY, z = -500}),

        [10] = autoPos3D({midX = -80 - DESIGN_CX, midY = 980 - DESIGN_CY, z = -700}),
        [11] = autoPos3D({midX = 100 - DESIGN_CX, midY = 985 - DESIGN_CY, z = -700}),
        [12] = autoPos3D({midX = 280 - DESIGN_CX, midY = 990 - DESIGN_CY, z = -700}),

        [13] = autoPos3D({midX = 130 - DESIGN_CX, midY = 510 - DESIGN_CY, z = -200}),
        [14] = autoPos3D({midX = 320 - DESIGN_CX, midY = 510 - DESIGN_CY, z = -200}),
        [15] = autoPos3D({midX = 530 - DESIGN_CX, midY = 510 - DESIGN_CY, z = -200}),
    },

    autoPos   = autoPos,
    autoPos3D = autoPos3D,

    width  = width,
    height = height,
    cx     = cx,
    cy     = cy,

    DESIGN_WIDTH = DESIGN_WIDTH,
    DESIGN_HEIGHT = DESIGN_HEIGHT,
    DESIGN_CX    = DESIGN_CX,
    DESIGN_CY    = DESIGN_CY,

    MaxScale   = MaxScale,
    MinScale   = MinScale,
    AutoScaleX = AutoScaleX,
    AutoScaleY = AutoScaleY,

    width  = width,
    height = height,
    cx     = cx,
    cy     = cy,


    -- 控件层次
    zOrderMap   = -65535,   -- 地图
    zOrderHeros = height * 0.2,      -- 主将层次
    zOrderSkillMask = -height,  -- 施法时蒙版
    zOrderScreen = height * 0.3,     -- 屏幕特效
    zOrderTouch = height * 0.4,      -- 施法框
    zOrderSkill = height * 0.7,      -- 施法时切屏动画
    zOrderFirst = height * 0.8,      -- 开场BUFF，先手值比拼
    zOrderCtrl  = height * 0.9,      -- 托管、跳过按钮

    zOrderBuffTag = 12,
    zOrderLabel   = 15,
}


BDUIConfig.attackPos = {}

local genAttackPos = function(fromPos)
    local posList = {}
    if fromPos > 6 then
        posList = {1, 2, 3, 4, 5, 6}
    else
        posList = {7, 8, 9, 10, 11, 12}
    end

    local delayList = {1, 0, 1, 2, 1, 2}

    local t = {}
    for i, v in pairs(posList) do
        local tmppos = clone(BDUIConfig.position[v])

        local diffPos = {cc.p(math.random(-30, 30), math.random(-30, 30))}

        for k, p in pairs(diffPos) do
            if v >=4 and v <= 9 then
                p.y = -math.abs(p.y)
            end

            local posx = tmppos.x + p.x * BDUIConfig.MinScale
            local posy = tmppos.y + p.y * BDUIConfig.MinScale

            table.insert(t, {pos = cc.vec3(posx, posy, tmppos.z), target = v, delay = delayList[i]})
        end
    end

    return t
end

for i = 1, 12 do
    BDUIConfig.attackPos[i] = genAttackPos(i)
end


return BDUIConfig
