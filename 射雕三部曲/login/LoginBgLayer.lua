--[[
    文件名：LoginBgLayer.lua
	描述：登录背景公共页面，帐户登录和游戏服务器登录页面的公共背景
    创建人：heguanghui
    创建时间：2017.3.6
-- ]]

local LoginBgLayer = class("LoginBgLayer", function()
    return display.newLayer(cc.c4b(255, 255, 255, 255))
end)

function LoginBgLayer:ctor()
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 创建页面控件
	self:initUI()
end

-- 创建页面控件
function LoginBgLayer:initUI()
    -- 繁体背景
    local bgSprite = ui.newSprite("dl_04.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    local partnerID = IPlatform:getInstance():getConfigItem("PartnerID")
    -- 其他渠道背景
    if partnerID == "9904" or partnerID == "9905" or partnerID == "9400" or partnerID == "9401" then
        bgSprite:setTexture("xdl_12.jpg")
    end
    
    -- 特效
    if partnerID == "9904" or partnerID == "9905" or partnerID == "9400" or partnerID == "9401" then
        -- hero1
        local hero1 = ui.newEffect({
                parent = self.mParentLayer,
                position = cc.p(220, 650),
                effectName = "hero_dljsA",
                loop = true,
            })
        -- hero2
        local hero2 = ui.newEffect({
                parent = self.mParentLayer,
                position = cc.p(420, 100),
                scale = 0.75,
                effectName = "hero_dljsB",
                loop = true,
            })

        -- 界面特效
        local houEffect = ui.newEffect({
                parent = self.mParentLayer,
                position = cc.p(320, 568),
                effectName = "effect_ui_shediao1.5denglu",
                loop = true,
            })
    else
        -- 创建飘花特效
        local houEffect = ui.newEffect({
            parent = self.mParentLayer,
            position = cc.p(400, 800),
            animation = "qian",
            effectName = "effect_ui_jiemianpiaohua",
            loop = true,
        })
    end
    
    -- 创建log
    local isLogoVisible = partnerID == "9904" or partnerID == "9905" or partnerID == "9400" or partnerID == "9401"
    local configBgName = IPlatform:getInstance():getConfigItem("ChannelBackImage")
    if not configBgName or  configBgName == "" then
        configBgName = "xdl_04.png"
    end

    if isLogoVisible then
        local titleSprite = ui.newSprite(configBgName)
        titleSprite:setPosition(180, 1020)
        self.mParentLayer:addChild(titleSprite)
    end
end

-- 异步创建主要人物形象
function LoginBgLayer:asyncCreateHero()
    -- 添加人物
    local heroList = {
        {heroModelId = 12013605, position = cc.p(270, 410), scale = 0.3, isRotation = true},    -- 巫神
        {heroModelId = 12013601, position = cc.p(420, 380), scale = 0.32, isRotation = false},  --达尔豪
        {heroModelId = 12011301, position = cc.p(180, 290), scale = 0.3, isRotation = true},    --余婧秋
        {heroModelId = 12011302, position = cc.p(350, 230), scale = 0.35, isRotation = false},   --东伯雪鹰
    }

    -- 预加载角色资源
    require("Config.HeroModel")
    for index, heroInfo in ipairs(heroList) do
        Figure.newHero({
            heroModelID = heroInfo.heroModelId,
            shadow = false,
            parent = bgSprite,
            position = heroInfo.position,
            scale = heroInfo.scale,
            zorder = index,
            async = function (figureNode)
                if heroInfo.isRotation then
                    figureNode:setRotationSkewY(180)
                end
            end,
            needRace = false,
        })
    end
end

return LoginBgLayer
