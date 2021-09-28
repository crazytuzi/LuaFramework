--[[
    filename: ComBattle.UICtrl.BDSkillFeature
    description: 战斗切屏动画
    date: 2016.12.27

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

local BDSkillFeature = class("BDSkillFeature", function()
    return cc.LayerColor:create(cc.c4b(0, 0, 0, 0))
end)

require("common.Figure")
local s = bd.ui_config.MinScale


--[[
params:
{
    pos = {
        {
            pos = 1,
            skillId = xxx,
        },{
            ...
        }
    }, -- 施法者ID
    petID -- 外功切屏时使用
    callback, 结束后回调
    battleData
}
]]
function BDSkillFeature:ctor(params)
    bd.func.registerSwallowTouch({node = self})

    self.params = params
    self.battleData = params.battleData
    self:enableNodeEvents()
end

function BDSkillFeature:onEnterTransitionFinish()
    local params = self.params
    local battleData = params.battleData

    if g_editor_mode_hero_data then
        self:removeFromParent()
        params.callback()
        return
    end

    -- 技能信息
    local skillInfo = params.pos[1]
    local node = battleData:getHeroNode(skillInfo.pos)

    -- 获取合体技另外一个人物
    local pp = params.battleData:getHeroPartnerPos(skillInfo.pos)
    -- 是否合体怒击
    local combo = (not params.petID) and ld.checkComboSkill(skillInfo.skillId) and pp

    -- 切屏后显示的立绘
    local heroId = bd.interface.getHeroIdByFigure(node.figureName)
    local item = IllusionModel.items[heroId] or FashionModel.items[heroId] or HeroModel.items[node.heroId]
    local hdPicture = combo and (item.drawingPicB ~= "" and item.drawingPicB or item.drawingPicA) or item.drawingPicA

    if params.petID or hdPicture == "" then
        hdPicture = nil
    end

    if params.petID then
        local item = PetModel.items[params.petID]
        hdPicture = item.pic
    end

    -- 是否友方施法
    local friendly = bd.interface.isFriendly(skillInfo.pos)

    self.mIsCombo = combo

    -- 切屏完成后掉调用
    local after_qieping = bd.func.getChecker(function()
        -- 显示立绘
        self:addHDPicture(hdPicture, function()
            self:removeFromParent()
        end)
    end, 2) -- 需要调用两次after_qieping（最多两个切屏特效）

    -- 新需求，非合体技有立绘只放立绘
    if hdPicture and (not combo) then
        self:newRequest(node.heroId, node.figureName, hdPicture, function()
            self:removeFromParent()
        end)
        -- 提前回调
        bd.func.performWithDelay(function()
            params.callback()
        end, 0.42)
        return
    end

    -- 人物一
    -- 如果单人施法，则根据是否敌方显示蓝色或者红色
    self:addOneQiePingEffect(skillInfo.pos, combo or friendly, after_qieping)

    -- 合体怒击
    if combo then
        bd.func.performWithDelay(self, function()
            bd.audio.playSound("qieping_2_ren.mp3")
            self:showSkillNamePic(skillInfo.pos, skillInfo.skillId, true)
            -- 人物二必定显示红色
            self:addOneQiePingEffect(pp, false, after_qieping)
        end, 0.075)
    else
        if not self.params.petID then
            bd.audio.playSound("qieping_1_ren.mp3")
        end

        -- 技能名
        self:showSkillNamePic(skillInfo.pos, skillInfo.skillId, false, friendly)

        after_qieping()
    end

    -- 提前回调
    bd.func.performWithDelay(function()
        if not tolua.isnull(self) then
            self:setOpacity(0)
        end
        params.callback()
    end, hdPicture and 1.9 or 1.2)
end


-- 新需求，非合体技有立绘只放立绘
function BDSkillFeature:newRequest(heroId, figureName, hdPicture, cb)
    if not self.params.petID then
        local audio = bd.interface.getHeroFashionAudio(figureName) or bd.interface.getIllusionAudio(figureName) or bd.interface.getFashionAudio(figureName) or bd.interface.getAudioById(heroId)
        if audio then
            bd.audio.playSound(audio)
        end
    end

    self:addHDPicture(hdPicture, cb)
end


function BDSkillFeature:addOneQiePingEffect(idx, blue, cb)
    local node = self.battleData:getHeroNode(idx)
    local male = blue

    local baseNode = cc.Node:create()
    baseNode:setScale(bd.ui_config.MinScale)
    self:addChild(baseNode)

    if not self.params.petID then
        if self.mIsCombo and male then
            local heroId = bd.interface.getHeroIdByFigure(node.figureName)
            local item = IllusionModel.items[heroId] or FashionModel.items[heroId] or HeroModel.items[node.heroId]
            local sound = Utility.getJointSkilSound(item)
            bd.audio.playSound(sound .. ".mp3")
        else
            local audio = bd.interface.getFashionAudio(node.figureName) or bd.interface.getAudioById(node.heroId)
            if audio then
                if male or (not self.mIsCombo) then
                    bd.audio.playSound(audio)
                end
            end
        end
    end

    local pos = bd.ui_config.autoPos({midX = 0, midY = male and 200 or -200})
    baseNode:setPosition(pos)

    if not self.mIsCombo then
        baseNode:setPosition(bd.ui_config.autoPos({midX = 0, midY = male and 0 or -0}))
    end

    -- 底层和顶层动画
    local aniName = male and "effect_tongyiqieping_nan" or "effect_tongyiqieping_nv"

    -- 黑影
    local shadow = self:newEffect(baseNode, aniName)
    shadow:setPositionY(-17)
    SkeletonAnimation.action({
        skeleton         = shadow,
        action           = "zhezhao",
        completeListener = function()
            baseNode:removeFromParent()
            bd.func.performWithDelay(self, cb, 0)
        end,
    })
    -- shadow:setAnimation(0, "zhezhao", false)

    -- 遮罩
    local maskEffect = self:newEffect(baseNode, aniName)
    maskEffect:setAnimation(0, "zhezhao", false)

    local clipNode = cc.ClippingNode:create()
    clipNode:setStencil(maskEffect)
    clipNode:setAlphaThreshold(0.1)
    baseNode:addChild(clipNode, 5)

    -- 底图
    local di = self:newEffect(clipNode, aniName)
    di:setAnimation(0, "di", false)

    -- 人物下层发光
    local renwu_xia = self:newEffect(clipNode, aniName)
    renwu_xia:setAnimation(0, "renwu_xia", false)

    -- 人物
    local heroNode = Figure.newHero({
        figureName = node.figureName,
        scale      = 0.56,
    })
    if not male then
        heroNode:setRotationSkewY(180)
    end
    heroNode:setPosition(male and -670 or 770, male and -645 or 645)
    clipNode:addChild(heroNode)

    heroNode:runAction(cc.Sequence:create(
        cc.MoveTo:create(0.08, cc.p(male and -70 or 70, male and -510 or -560)),
        cc.MoveBy:create(2, cc.p(male and 60 or -60, male and 35 or -35))
    ))

    -- 人物上层发光
    local renwu_shang = self:newEffect(clipNode, aniName)
    renwu_shang:setAnimation(0, "renwu_shang", false)

    return clipNode, heroNode
end

function BDSkillFeature:newEffect(parent, aniName, scale)
    local skeleton = SkeletonAnimation.create({
        file   = aniName,
        scale  = scale or 1,
        parent = parent,
    })

    SkeletonAnimation.update({
        skeleton = skeleton,
        speed = 1.5,
    })

    return skeleton
end

-- @切屏后立绘
function BDSkillFeature:addHDPicture(picture, cb)
    if not picture then
        return cb()
    end

    bd.audio.playSound("qieping_lihui.mp3")

    local effect = ui.newEffect({
        parent           = self,
        effectName       = "effect_tongyisuduxian",
        animation        = "xia",
        scale            = bd.ui_config.MinScale,
        position         = cc.p(bd.ui_config.cx, bd.ui_config.cy),
        speed            = self.mIsComBo and 0.8 or 1,
        completeListener = cb,
    })

    local bindingLoad = effect:bindBoneNode("renwu")

    -- ui.newEffect({
    --     parent     = bindingLoad,
    --     effectName = "effect_lihui_xiaolongnv",
    -- })

    if cc.FileUtils:getInstance():isFileExist(picture .. ".skel") then
        ui.newEffect({
            parent     = bindingLoad,
            effectName = picture,
        })
    else
        bd.interface.newSprite({
            parent = bindingLoad,
            img    = picture .. ".png",
        })
    end

    ui.newEffect({
        parent     = self,
        effectName = "effect_tongyisuduxian",
        animation  = "shang",
        speed      = self.mIsComBo and 0.8 or 1,
        scale      = bd.ui_config.MinScale,
        position   = cc.p(bd.ui_config.cx, bd.ui_config.cy),
        completeListener = cb,
    })
end

function BDSkillFeature:camera(pos, callback)
    pos = bd.interface.getStandPos(pos)
    local time = 0.1

    local layer = self.battleData:get_battle_layer().parentLayer
    layer:setIgnoreAnchorPointForPosition(false)
    layer:setAnchorPoint(cc.p(pos.x / bd.ui_config.width, pos.y / bd.ui_config.height))
    layer:setPosition(pos)

    layer:runAction(cc.Sequence:create({
        cc.ScaleTo:create(time, 1.15),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(callback),
        cc.ScaleTo:create(time, 1),
    }))
end

function BDSkillFeature:showSkillNamePic(pos, skillID, isCombo, blue)
    local attackInfo
    if self.params.petID then
        local item = PetModel.items[self.params.petID]
        attackInfo = {
            picPosition  = 1,
            skillNamePic = item.skillNamePic,
        }
    else
        attackInfo = AttackModel.items[skillID]
        attackInfo.picPosition = 1
    end
    if attackInfo and attackInfo.picPosition ~= 0 then
        local node = self.battleData:getHeroNode(pos)
        local male = blue

        local posconfig = {
            -- 横着
            [1] = bd.ui_config.autoPos({ midX = male and 400 or -400,
                    midY = isCombo and (blue and -150 or 150) or (male and -200 or 200),}),
            -- 左边
            [2] = bd.ui_config.autoPos({ midX = -bd.ui_config.DESIGN_CX, midY = 0,}),
            -- 右边
            [3] = bd.ui_config.autoPos({ midX = bd.ui_config.DESIGN_CX, midY = 0,}),
        }

        local sp = bd.interface.newSprite({
            img   = attackInfo.skillNamePic .. ".png",
            scale = bd.ui_config.MinScale,
            pos   = posconfig[attackInfo.picPosition],
        })

        if sp then
            local outAction
            if attackInfo.picPosition == 1 then
                outAction = cc.Spawn:create(
                    cc.FadeIn:create(0.2),
                    cc.MoveTo:create(0.1, bd.ui_config.autoPos({midX = 0,
                        midY = isCombo and 0 or (male and -200 or 225),}))
                )
            elseif attackInfo.picPosition == 2 then
                sp:setAnchorPoint(cc.p(0, 0.5))
                outAction = cc.FadeIn:create(0.2)
            else
                sp:setAnchorPoint(cc.p(1, 0.5))
                outAction = cc.FadeIn:create(0.2)
            end

            self:addChild(sp, 1)
            sp:setOpacity(0)
            sp:runAction(cc.Sequence:create(
                outAction,
                cc.ScaleTo:create(1, 1.1 * bd.ui_config.MinScale),
                cc.FadeOut:create(0.1)
            ))
        end
    end
end

return BDSkillFeature
