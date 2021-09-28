--[[
    filename: BDInterface
    description: 与环境、配置、项目相关的函数
    date: 2016.08.12

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

local BDInterface = {}

-- @base64解码
function BDInterface.b64decode(s)
    if (not s) or (s == "") then
        return nil
    end

    local b64 = CommunicationDataEncodeClass:new_local()
    b64:SetKey("")

    return b64:DecryptDataWithBase64(s)
end


-- @飘窗
function BDInterface.showFlashView(params)
    ui.showFlashView(params.text)
end

--@ 创建sprite
-- params:
-- {
--      <img>/<image>               图片路径
--      [pos]/[position]            位置
--      [anchor]/[anchorPoint]      锚点
--      [zorder]/[zOrder]           zOrder
--      [parent]                    父节点
-- }
function BDInterface.newSprite(params)
    local sprite = cc.Sprite:create(params.img or params.image)
    if sprite then
        local pos = params.pos or params.position
        local _ = pos and sprite:setPosition(pos)

        local anchor = params.anchor or params.anchorPoint
        local _ = anchor and sprite:setAnchorPoint(anchor)

        local zorder = params.zOrder or params.zorder
        local _ = zorder and sprite:setLocalZOrder(zorder)

        if params.parent then
            params.parent:addChild(sprite)
        end

        if params.scale then
            sprite:setScale(params.scale)
        end
    end

    return sprite
end


-- @创建label
-- <text>           文字
function BDInterface.newLabel(params)
    local nLabel = cc.Label:createWithTTF(params.text
                    , params.font or bd.adapter.config.font.DEFAULT
                    , params.size or bd.adapter.config.fontSize.DEFAULT)
    if params.x or params.y then
        nLabel:setPosition(params.x or 0, params.y or 0)
    end

    if params.outlineColor then
        nLabel:enableOutline(params.outlineColor, params.outlineSize or 2)
    end

    if params.color then
        nLabel:setColor(params.color)
    end

    if params.anchorPoint then
        nLabel:setAnchorPoint(params.anchorPoint)
    end

    if params.align then
        nLabel:setAlignment(params.align)
    end

    if params.valign then
        nLabel:setVerticalAlignment(params.valign)
    end

    if params.dimensions then
        nLabel:setDimensions(params.dimensions.width , params.dimensions.height)
    end

    if params.parent then
        params.parent:addChild(nLabel)
    end

    return nLabel
end

--@ 创建按钮
function BDInterface.newButton(params)
    if not params or not params.normalImage then
        return
    end
    if params.textureResType and params.texturePlist and params.texturePlist ~= "" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames(params.texturePlist)
    end

    local lightedImage = params.lightedImage or params.selectedImage or params.normalImage
    local disabledImage = params.disabledImage or ""
    local button = ccui.Button:create(params.normalImage, lightedImage, disabledImage, params.textureResType or ccui.TextureResType.localType)
    button:setPressedActionEnabled(true)

    if params.size then
        button:setScale9Enabled(true)
        button:setContentSize(params.size)
    else
        -- if params.text and not params.fixedSize then
        --     local textCount = string.utf8len(params.text)
        --     local size = ButtonSize[textCount]
        --     if size then
        --         button:setScale9Enabled(true)
        --         button:setContentSize(size)
        --     end
        -- end
    end

    local titlePosRateX = params.titlePosRateX or 0.5
    local titlePosRateY = params.titlePosRateY or 0.5
    local buttonSize = button:getContentSize()

    button:getExtendNode2():setPosition(buttonSize.width/2, buttonSize.height/2)

    -- 判断是否带字符串显示·
    if params.text then
        local tempStr = params.text
        if string.utf8len(tempStr) == 2 then
            tempStr = string.utf8sub(params.text, 1, 1) .. " " .. string.utf8sub(params.text, 2, 2)
        end
        local titleLabel = BDInterface.newLabel({
            text         = tempStr,
            font         = params.fontName or Enums.Font.eDefault,
            size         = params.fontSize or Enums.Fontsize.eBtnDefault,
            color        = params.textColor or Enums.Color.eBtnText,
            outlineColor = params.outlineColor,
            outlineSize  = params.outlineSize,
            x            = buttonSize.width * (titlePosRateX - 0.5),
            y            = buttonSize.height * (titlePosRateY - 0.5),
            dimensions   = params.textWidth and cc.size(params.textWidth, 0),
        })
        titleLabel:setAnchorPoint(cc.p(0.5, 0.5))

        button:getExtendNode2():addChild(titleLabel)
        button.mTitleLabel = titleLabel
    end

    -- 创建title image
    if params.titleImage then
        button.titleSprite = BDInterface.newSprite({
            img = params.titleImage,
            pos = cc.p(buttonSize.width * (titlePosRateX - 0.5), buttonSize.height * (titlePosRateY - 0.5)),
        })
        button:getExtendNode2():addChild(button.titleSprite, 1)
    end

    -- 修改titleImage
    button.setTitleImage = function(target, titleImage)
        if target.titleSprite == nil then
            target.titleSprite = BDInterface.newSprite(titleImage)
            target:getExtendNode2():addChild(target.titleSprite, 1)
        else
            target.titleSprite:setTexture(titleImage)
        end
    end

    -- 设置位置
    if params.position then
        button:setPosition(params.position)
    end

    -- 设置缩放
    if params.scale then
        button:setScale(params.scale)
    end

    -- 设置瞄点
    if params.anchorPoint then
        button:setAnchorPoint(params.anchorPoint)
    end

    -- 修改Label
    function button:setTitleText(text)
        if self.mTitleLabel then
            local tempStr = text
            if string.utf8len(tempStr) == 2 then
                tempStr = string.utf8sub(text, 1, 1) .. " " .. string.utf8sub(text, 2, 2)
            end

            self.mTitleLabel:setString(tempStr)
        end
    end

    -- 修改颜色
    function button:setTitleColor(color)
        if self.mTitleLabel then
            self.mTitleLabel:setTextColor(color)
        end
    end

    function button:setTitleRateY(posRateY)
        local size  = button:getContentSize()
        local y = size.height * (posRateY - 0.5)
        self.mTitleLabel:setPositionY(y)
    end

    -- 定位
    function button:align(anchorPoint, x, y)
        if anchor then
            self:setAnchorPoint(anchor)
        end
        if x and y then
            self:setPosition(x, y)
        end
        return self
    end

    -- 点击事件
    function button:setClickAction(clickAction)
        self.mClickAction = clickAction
    end

    -- 设置点击事件
    button:setClickAction(params.clickAction)

    button:addTouchEventListener(function(sender, event)
        if event == ccui.TouchEventType.began then
            button.mBeginPos = sender:getTouchBeganPosition()
        elseif event == ccui.TouchEventType.ended then
            local beginPos = button.mBeginPos
            local endPos = sender:getTouchEndPosition()
            local distance = math.sqrt(math.pow(endPos.x - beginPos.x, 2) + math.pow(endPos.y - beginPos.y, 2))
            if distance < (40 * Adapter.MinScale) then
                if not params.clickAudio then
                    bd.adapter.audio.playSound("button.mp3")
                elseif params.clickAudio ~= "" then
                    bd.adapter.audio.playSound(params.clickAudio)
                end

                if button.mClickAction then
                    button.mClickAction(button)
                end
            end
        end
    end)

    return button
end


-- @创建进度条
--[[
{
    bgImage = "",   -- 背景图片
    barImage = "",  -- 进度图片
    currValue = 1,  -- 当前进度
    maxValue = 100, -- 最大值
    contentSize = null, -- 进度条的大小，默认为背景图或进度图片大小
    barType = ProgressBarType.eHorizontal, -- 进度条类型，水平进度／垂直进度条，取值为ProgressBarType的枚举值。
    needLabel = true,   -- 是否需要文字显示进度
    needHideBg = false, -- 是否需要隐藏背景
    percentView = true  -- 以百分比方式显示(needLabel == true有效)
    font = _FONT_NUMBER, -- 文本的数字
    size = 20, -- 文本的大小
    color = Enums.Color.eWhite, 文本颜色
    shadowColor = nil,  -- 阴影的颜色，可选设置，不设置表示不需要阴影
    outlineColor = nil, -- 描边的颜色，可选设置，不设置表示不需要描边
    outlineSize = 1,    -- 描边的大小，可选设置，如果 outlineColor 为nil，该参数无效，默认为 1
}
]]
function BDInterface.newProgress(...)
    return require("common.ProgressBar").new(...)
end



-- @播放特效
--[[
    params:
        parent         父节点(可选)
        effectName     动画效果
        position       坐标（可选）
        position3D     3d坐标（可选）
        scale          缩放（可选）
        loop           是否循环（可选）
        animation      动作名（可选）
        speed          播放速度（可选）
        skin           皮肤（可选）
        startListener  动作开始回调（可选）
        endListener    动作结束回调（可选）
        completeListener 动作完成回调（可选）
        eventListener  事件回调（可选）
        endRelease     结束时释放（可选,默认为true）
        zorder         排序（可选）
        rotationX      x轴翻转（可选）
        rotationY      y轴翻转（可选）
        rotationZ      z轴翻转（可选）
        [watchSpeed]   监视战斗速度，并更新自己的速度 默认true
    return:
        effect         SkeletonAnimation对象
--]]
function BDInterface.newEffect(params)
    require("common.SkeletonAnimation")
    if not params.effectName then
        error("------ERROR--------")
        return
    end
    if params.endRelease == nil then
        params.endRelease = true
    end
    --循环
    params.loop = params.loop or false
    --缩放
    params.scale = (params.scale or 1)
    --动作名
    params.animation = params.animation or "animation"

    local effect = SkeletonAnimation.create({
        file       = params.effectName,
        parent     = params.parent,
        position   = params.position,
        position3D = params.position3D,
        zorder     = params.zorder,
        scale      = params.scale,
    })

    local posOffset = bd.ui_config.buffEffectPostOffset[params.effectName]
    if posOffset then
        local origin_setPosition = effect.setPosition
        function effect:setPosition(x, y)
            if type(x) == "table" then
                y = x.y
                x = x.x
            end

            x = x + posOffset.x
            y = y + posOffset.y

            origin_setPosition(effect, x, y)
        end

        local origin_setPosition3D = effect.setPosition3D
        function effect:setPosition3D(x, y, z)
            if type(x) == "table" then
                y = x.y
                z = x.z
                x = x.x
            end

            x = x + posOffset.x
            y = y + posOffset.y

            origin_setPosition3D(effect, cc.vec3(x, y, z))
        end

        if params.position then
            effect:setPosition(params.position)
        elseif params.position3D then
            effect:setPosition3D(params.position3D)
        end
    end

    -- 加载外部事件
    if cc.FileUtils:getInstance():isFileExist(params.effectName .. ".event") and effect:eventLoaded() == false then
    -- if cc.FileUtils:getInstance():isFileExist(params.effectName .. ".event") then
        effect:clearEvent()

        local eventPath = cc.FileUtils:getInstance():fullPathForFilename(params.effectName .. ".event")
        effect:loadEvent(eventPath)
    end


    local startListener = nil
    local endListener = nil
    local completeListener = nil
    local eventListener = nil
    if params.startListener then
        startListener = function(p)
            p.self = effect
            params.startListener(p)
        end
    end

    endListener = function(p)
        if params.endListener then
            p.self = effect
            params.endListener(p)
        end
        if params.endRelease then
            effect:removeFromParent()
        end
    end

    if params.completeListener then
        completeListener = function(p)
            p.self = effect
            params.completeListener(p)
        end
    end
    if params.eventListener then
        eventListener = function(p)
            p.self = effect
            BDInterface.handleShakeEvent(p)
            params.eventListener(p)
        end
    end
    SkeletonAnimation.action({
        skeleton         = effect,
        action           = params.animation,
        loop             = params.loop,
        startListener    = startListener,
        endListener      = endListener,
        completeListener = completeListener,
        eventListener    = eventListener,
    })

    params.speed = (params.speed or 1) * bd.layer.data:get_battle_speed()
    SkeletonAnimation.update({
        skeleton = effect,
        speed    = params.speed,
    })

    if (params.skin) then
        SkeletonAnimation.update({
            skeleton = effect,
            skin     = params.skin,
        })
    end

    local rotationX = 0
    if (params.rotationX) then
        rotationX = params.rotationX
    end

    local rotationY = 0
    if (params.rotationY) then
        rotationY = 180
    end

    local rotationZ = 0
    if (params.rotationZ) then
        rotationZ = params.rotationZ
    end

    effect:setRotation3D({x = rotationX, y = rotationY, z = rotationZ})

    -- 监听战斗速度
    if params.watchSpeed ~= false then
        effect:enableNodeEvents()
        local function update_speed(speed)
            if tolua.isnull(effect) then
                bd.func.performWithDelay(function()
                    bd.layer.data:off("battle_speed", update_speed)
                end, 0)
                return
            end
            SkeletonAnimation.update({
                skeleton = effect,
                speed    = (params.speed or 1) * speed,
            })
        end
        bd.layer.data:on("battle_speed", update_speed)
        function effect:onExitTransitionStart()
            bd.layer.data:off("battle_speed", update_speed)
        end
    end

    return effect
end

-- @通过npcid获取npc数据
function BDInterface.getInfoByNpcId(npcId)
    require("Config.BattleNodeGuidenpcRelation")
    return BattleNodeGuidenpcRelation.items[npcId]
end


-- @通过heroId获取形象名
function BDInterface.getFigureNameByHeroId(heroId)
    if IllusionModel then
        local item = IllusionModel.items[heroId]
        if item and item.largePic then
            return item.largePic
        end
    end

    if FashionModel then
        local item = FashionModel.items[heroId]
        if item and item.actionPic then
            return item.actionPic
        end
    end

    if bd.data_config.HeroModel.items[heroId] then
        return bd.data_config.HeroModel.items[heroId].largePic
    end
    return "hero_hanqinglei"
end


-- @获取卡牌品质
require("Config.QualityModel")
function BDInterface.getBaseQuality(heroModelID)
    if bd.data_config.HeroModel.items[heroModelID] then
        return bd.data_config.HeroModel.items[heroModelID].quality
    end
end


-- @获取品质对应的颜色
BDInterface.getQualityColor = Utility.getQualityColor


-- @获取普攻id
function BDInterface.getNAIDByHeroId(heroId)
    if IllusionModel and IllusionModel.items[heroId] then
        return IllusionModel.items[heroId].NAID
    end

    if FashionModel and FashionModel.items[heroId] then
        return FashionModel.items[heroId].NAID
    end

    if bd.data_config.HeroModel.items[heroId] then
        return bd.data_config.HeroModel.items[heroId].NAID
    end
end


-- @获取技能id
function BDInterface.getRAIDByHeroId(heroId)
    if IllusionModel and IllusionModel.items[heroId] then
        return IllusionModel.items[heroId].RAID
    end

    if FashionModel and FashionModel.items[heroId] then
        return FashionModel.items[heroId].RAID
    end

    if bd.data_config.HeroModel.items[heroId] then
        return bd.data_config.HeroModel.items[heroId].RAID
    end
end

-- @获取玩家阵容中对应插槽的人物数据
function BDInterface.getFormationSlot(slotId)
    if FormationObj then
        return FormationObj:getSlotInfoBySlotId(slotId)
    end
end


-- @获取技能施法需要的怒气
function BDInterface.getSkillRage(skillID)
    local item = bd.data_config.AttackModel.items[skillID]
    return item and item.useRP or 999999
end


-- @获取技能id对应的技能特效
function BDInterface.getSkillById(skillId)
    if type(skillId) == "table" then
        skillId = skillId[1]
    end

    if skillId == -1 then
        return require(string.format("BattleSkillConfig.config_default"))
    end

    -- 如果是编辑器模式下
    if g_editor_mode_hero_data and g_editor_mode_hero_data.heroID then
        local heroid = g_editor_mode_hero_data.heroID

        require("Config.FashionModel")
        local heroData = FashionModel.items[heroid] or bd.data_config.HeroModel.items[heroid]

        local ret = ""
        if heroData.NAID == skillId then
            ret = g_editor_mode_hero_data.pugongCode or "config_default"
        else
            ret = g_editor_mode_hero_data.nujiCode or "config_default"
        end

        if ret == "" then
            ret = "config_default"
        end

        return require(string.format("BattleSkillConfig.%s", ret))
    end



    local skillConfigName = bd.data_config.AttackModel.items[skillId] and bd.data_config.AttackModel.items[skillId].effectCode

    if skillConfigName and skillConfigName ~= "" and skillConfigName ~= "0" then
    else
        skillConfigName = "config_default"
    end

    -- 如果文件不存在，设置为默认
    if cc.FileUtils:getInstance():isFileExist(string.format("BattleSkillConfig/%s.lua", skillConfigName)) == false and
        cc.FileUtils:getInstance():isFileExist(string.format("BattleSkillConfig/%s.luac", skillConfigName)) == false then
        skillConfigName = "config_default"
    end

    return require(string.format("BattleSkillConfig.%s", skillConfigName))
end

-- 获取宠物的移动类型和移动offset
function BDInterface.getPet3MoveConfig(modelId, step, skillId)
    local skillType = "normal"
    local moveType = 1
    local moveOffset = 0

    local item = ZhenshouStepupModel.items[modelId][step]
    if item.baseAtkBuffID ~= skillId then
        skillType = "skill"
    end

    local modelData = ZhenshouModel.items[modelId]
    if skillType == "normal" then
        moveType = modelData.atkMoveType
        moveOffset = modelData.atkOffSet
    else
        moveType = modelData.skillMoveType
        moveOffset = modelData.skillOffSet
    end

    return moveType, moveOffset
end

function BDInterface.getPet3SkillById(modelId, step, skillId)
    local skillType = "normal"
    local skillConfigName = ""

    local item = ZhenshouStepupModel.items[modelId][step]
    if item.baseAtkBuffID ~= skillId then
        skillType = "skill"
    end

    local modelData = ZhenshouModel.items[modelId]
    if skillType == "normal" then
        skillConfigName = modelData.atkEffectCode
    else
        skillConfigName = modelData.skillEffectCode
    end

    if skillConfigName and skillConfigName ~= "" and skillConfigName ~= "0" then
    else
        skillConfigName = "config_default"
    end

    -- 如果文件不存在，设置为默认
    if cc.FileUtils:getInstance():isFileExist(string.format("BattleSkillConfig/%s.lua", skillConfigName)) == false and
        cc.FileUtils:getInstance():isFileExist(string.format("BattleSkillConfig/%s.luac", skillConfigName)) == false then
        skillConfigName = "config_default"
    end

    return require(string.format("BattleSkillConfig.%s", skillConfigName))
end

-- @通过HeroModelID获取音效
function BDInterface.getAudioById(heroId)
    local skillSound = Utility.getHeroSound(heroId)
    return skillSound and skillSound ~= "" and skillSound .. ".mp3"
end


-- @获取资源名称
function BDInterface.getResourceName(type, modelID)
    return Utility.getGoodsName(type, modelID)
end


-- @获取宝藏挑战类型
function BDInterface.getXXBZType(rewardTypeID , rewardModelID)
    -- 奖励类型
    return bd.interface.getResourceName(rewardTypeID, rewardModelID)
end


-- @获取宝藏挑战奖励数值
function BDInterface.getXXBZValue(id, total)
    if not XxbzRewardBaseRelation then
        return 0
    end

    local baseReward = 0
    require("Config.XxbzRewardBaseRelation")
    for i , v in pairs(XxbzRewardBaseRelation.items) do
        if (v.treasureID or v.rewardID) == id then
            if total >= v.needLower then
                baseReward = v.rewardNum
            end
        end
    end

    -- 奖励系数
    local fix = 0
    local base = 0
    require("Config.XxbzRewardConditionRelation")
    for i , v in pairs(XxbzRewardConditionRelation.items) do
        if (v.treasureID or v.rewardID) == id then
            if v.conditionLower <= total then
                fix = v.rewardNumR
                base = v.baseNum
            end
        end
    end
    --当前这一步的奖励
    local cValue = math.ceil(total * fix / 1000000 + base)

    return baseReward + cValue
end

function BDInterface.getFashionAvatar(figure)
    for _, v in pairs(FashionModel.items) do
        if v.actionPic == figure then
            return v.smallPic .. ".png"
        end
    end
end

function BDInterface.getFashionAudio(figure)
    for _, v in pairs(FashionModel.items) do
        if v.actionPic == figure and v.skillSound then
            local skillSound = Utility.getHeroSound(v)
            return skillSound and skillSound ~= "" and skillSound .. ".mp3"
        end
    end
end

function BDInterface.getFashionSkillPic(figure)
    for _, v in pairs(FashionModel.items) do
        if v.actionPic == figure and v.skillPic then
            return v.skillPic .. ".png"
        end
    end
end

-- 根据幻化角色找modelId
function BDInterface.getIllusionId(figure)
    for _, v in pairs(IllusionModel.items) do
        if v.largePic == figure then
            return v.modelId
        end
    end
    -- 穿了时装
    for _, v in pairs(HeroFashionRelation.items) do
        if v.largePic == figure then
            return v.modelId
        end
    end
    return 0
end

-- 幻化头像
function BDInterface.getIllusionAvatar(illusionModelId)
    return IllusionModel.items[illusionModelId] and IllusionModel.items[illusionModelId].smallPic..".png" or nil
end

-- 幻化技能音效
function BDInterface.getIllusionAudio(figure)
    for _, v in pairs(IllusionModel.items) do
        if v.largePic == figure and v.skillSound then
            local skillSound = Utility.getHeroSound(v)
            return skillSound and skillSound ~= "" and skillSound .. ".mp3"
        end
    end
end

-- 侠客时装技能音效
function BDInterface.getHeroFashionAudio(figure)
    for _, heroFashionInfo in pairs(HeroFashionRelation.items) do
        if heroFashionInfo.largePic == figure then
            local tempModelId = heroFashionInfo.modelId

            if HeroModel.items[tempModelId] then
                return HeroModel.items[tempModelId].skillSound .. ".mp3"
            end

            if IllusionModel.items[tempModelId] then
                return IllusionModel.items[tempModelId].skillSound .. ".mp3"
            end
        end
    end
end

-- @角色头像
function BDInterface.getAvatar(heroId, step)
    local avatar
    if heroId then
        if step and step > 0 and HeroStepImageRelation then
            if HeroStepImageRelation.items[heroId] and HeroStepImageRelation.items[heroId].step <= step then
                avatar = HeroStepImageRelation.items[heroId].smallPic .. ".png"
            end
        elseif bd.data_config.HeroModel.items[heroId] then
            avatar = bd.data_config.HeroModel.items[heroId].smallPic .. ".png"
        end
    end

    if avatar and Utility.isFileExist(avatar) then
        return avatar
    end

    bd.log.info(TR("获取头像失败！heroId:%s", heroId))
    return "tx_12605.png"
end

function BDInterface.getAvatarAdv(heroId, illusionModelId)
    local item = HeroModel.items[heroId]
    local illusionInfo = IllusionModel.items[illusionModelId]

    if illusionInfo then
        return illusionInfo.jpintPic and illusionInfo.jpintPic ~= "" and illusionInfo.jpintPic..".png"
    elseif item and item.jpintPic and item.jpintPic ~= "" then
        return item.jpintPic .. ".png"
    end
end


-- @获取技能攻击类型
function BDInterface.getTargetEnum(skillId)
    return bd.data_config.AttackModel.items[from.skillId].targetEnum
end


-- @技能目标数量
function BDInterface.getTargetNum(skillId)
    return bd.data_config.AttackModel.items[from.skillId].targetNum
end


-- @判断是否友方位置
function BDInterface.isFriendly(posId)
    return ((posId >= 1) and (posId <= 6)) or (posId == bd.ui_config.petBase+1)
end


-- @判断是否敌方位置
function BDInterface.isEnemy(posId)
    return ((posId >= 7) and (posId <= 12)) or (posId == bd.ui_config.petBase+2)
end


-- @获取对应角色的名字
function BDInterface.getHeroNodeName(node)
    if node.name2_ then return node.name2_ end

    local name = node.name
    if not name then
        local heroModel = bd.data_config.HeroModel.items[node.heroId]
        if heroModel then
            if heroModel.specialType == Enums.HeroType.eMianHero and bd.interface.isFriendly(node.idx) then
                name = BDInterface.getPlayerName()
            else
                name = bd.data_config.HeroModel.items[node.heroId].name
            end
        end
        if not name then
            bd.log.dataerr(TR("获取角色名失败！heroId:%d", node.heroId))
            return "404"
        end
    end

    --突破次数
    if node.step and node.step ~= 0 then
        if node.step > 10 and node.step <= 15 then
            name = string.format("%s+%d", name, node.step-10)
        elseif node.step > 15 and node.step <= 20 then
            name = string.format("%s+%d", name, node.step-15)
        elseif node.step > 20 and node.step <= 25 then
            name = string.format("%s+%d", name, node.step-20)
        else
            name = string.format("%s+%d", name, node.step)
        end
    end

    node.name2_ = name

    return name
end

-- @获取对应珍兽的名字
function BDInterface.getPetNodeName(node)
    if node.name2_ then return node.name2_ end

    local name = node.name
    if not name then
        local heroModel = bd.data_config.ZhenshouModel.items[node.heroId]
        if heroModel then
            name = bd.data_config.ZhenshouModel.items[node.heroId].name
        end
        if not name then
            bd.log.dataerr(string.format("获取角色名失败！heroId:%d", node.heroId))
            return "404"
        end
    end

    --突破次数
    if node.step and node.step ~= 0 then
        name = string.format("%s+%d", name, node.step)
    end

    node.name2_ = name

    return name
end

-- @获取玩家名
function BDInterface.getPlayerName()
    if PlayerAttrObj then
        return PlayerAttrObj:getPlayerAttrByName("PlayerName")
    end
    return "testName"
end


-- @获取新手引导NPC
function BDInterface.getGuideNPC(config)
    local item = BattleNodeGuidenpcRelation.items[config]
    if not item then
        return
    end

    item = clone(item)

    local heroItem = bd.data_config.HeroModel.items[item.heroModelID]
    if heroItem then
        item.RAID = item.RAID or heroItem.RAID
        item.NAID = item.NAID or heroItem.NAID
        item.name = item.name or heroItem.name
        item.quality = item.quality or heroItem.quality
        item.largePic = item.largePic or heroItem.largePic
    end

    return item
end



function BDInterface.midvec3(pos1, pos2)
    return cc.vec3((pos1.x + pos2.x)/2, (pos1.y + pos2.y)/2, (pos1.z + pos2.z)/2)
end



-- @获取攻击时移动位置和特效位置
--[[
    return: movePos, effectPos, skew
        movePos     人物移动位置，不需要移动时为nil
        effectPos   特效播放位置
        skew        是否翻转(true / false)

    宠物3传入覆盖的值moveType, moveOffset
]]
function BDInterface.getAttackPos(atom, petMoveType, petMoveOffset)
    local skillID = atom.skillId
    local toNum = #atom.to
    local toPos = atom.to[1].posId
    local fromPos = atom.from.posId
    local position = bd.ui_config.position

    local targetEnum, targetNum, moveType, moveOffset
    local movePos, moveTo, effectPos, skew

    if not atom.isPet3 then
        local skillItem = bd.data_config.AttackModel.items[skillID]

        targetEnum = skillItem.targetEnum
        targetNum = skillItem.targetNum
        moveType = skillItem.moveType
        moveOffset = skillItem.moveOffset or 0

        -- 获取编辑器传过来的值 moveType
        if g_editor_mode_hero_data then
            local heroid = g_editor_mode_hero_data.heroID

            require("Config.FashionModel")
            local heroData = FashionModel.items[heroid] or bd.data_config.HeroModel.items[heroid]

            if heroData.NAID == skillID then
                moveType = g_editor_mode_hero_data.pugongMoveType
                moveOffset = g_editor_mode_hero_data.pugongMoveOffset
            else
                moveType = g_editor_mode_hero_data.nujiMoveType
                moveOffset = g_editor_mode_hero_data.nujiMoveOffset
            end
        end
    else
        local skillItem = bd.data_config.BuffModel.items[skillID]

        targetEnum = skillItem.targetEnum
        targetNum = skillItem.targetNum

        moveType = petMoveType or 2
        moveOffset = petMoveOffset or 0
    end

    moveOffset = bd.ui_config.MinScale * moveOffset

    -- 横排
    if targetEnum == bd.CONST.targetEnum.eRowFront or targetEnum == bd.CONST.targetEnum.eRowBack then
        local _, p2, _ = bd.func.getRow(toPos)
        moveTo = p2
        effectPos = clone(position[p2])

        -- 如果敌方只剩一个
        if toNum == 1 then
            moveTo = toPos
        end
    -- 竖排
    elseif targetEnum == bd.CONST.targetEnum.eOneColumn then
        local p1, _ = bd.func.getCol(toPos)
        effectPos = clone(position[p1])
        moveTo = p1

        -- movePos = clone(position[moveTo])
        -- movePos.y = movePos.y + (bd.interface.isEnemy(toPos) and -100 * bd.ui_config.MinScale or 100 * bd.ui_config.MinScale)

        skew = bd.ui_config.posSkew[fromPos]
    -- 随机
    elseif targetEnum == bd.CONST.targetEnum.eRandom and targetNum > 1 then
        moveTo = 14
        if bd.interface.isEnemy(toPos) then
            effectPos = BDInterface.midvec3(position[8], position[11])
        else
            effectPos = BDInterface.midvec3(position[2], position[5])
        end

    -- 全体
    elseif targetEnum == bd.CONST.targetEnum.eAll then
        moveTo = 14
        if bd.interface.isEnemy(toPos) then
            effectPos = BDInterface.midvec3(position[8], position[11])
        else
            effectPos = BDInterface.midvec3(position[2], position[5])
        end

    -- 多个伤害
    elseif toNum > 1 then
        moveTo = 14
        effectPos = clone(position[toPos])

    -- 其他所有视为单体
    else
        moveTo = toPos
        effectPos = clone(position[toPos])
    end

    if moveType == 2 then
        -- 移动到中场
        moveTo = 14
        movePos = nil
    elseif moveType == 0 then
        -- 远程不需要移动
        moveTo = nil
        movePos = nil
        skew = bd.ui_config.posSkew[fromPos]

        return movePos, effectPos, skew
    end

    local fromCol = ((fromPos - 1) % 3) + 1
    local toCol = ((moveTo - 1) % 3) + 1

    if skew == nil then
        if moveTo == 14 then
            -- 移动到中场时:
            if fromCol == 1 then
                -- 第一列的攻击者朝右
                skew = false
            else
                -- 第二，三列的攻击者朝左
                skew = true
            end
        elseif toCol == 1 then
            -- 攻击第一列时，站在右边向左攻击
            skew = true
        elseif toCol == 3 then
            -- 攻击第三列时，站在左边向右攻击
            skew = false
        elseif toCol == 2 then
            -- 攻击中间列时:
            if fromCol == 1 then
                -- 第一列的攻击者，站在左边朝右攻击
                skew = false
            else
                -- 第二，三列的攻击者朝左
                skew = true
            end
        end
    end

    if moveType == 2 then
        skew = false
    end
    -- 射雕没有翻转
    skew = bd.ui_config.posSkew[fromPos]
    -- 射雕竖排攻击调整
    if (nil == movePos) and moveTo then
        if(targetEnum == bd.CONST.targetEnum.eOneColumn) and moveTo ~= 14 then
            movePos = clone(position[moveTo])
            movePos.y = movePos.y - 100 * bd.ui_config.MinScale
        else
            movePos = clone(position[moveTo])
        end

        movePos.x = movePos.x + (60 * bd.ui_config.MinScale * (skew and 1 or -1))
        movePos.x = movePos.x + moveOffset * (skew and 1 or -1)

    end

    return movePos, effectPos, skew
end


function BDInterface.getActionValue_daji(value)
    local tmp = string.sub(value,1,4)
    if tmp == "daji" then
        tmp = string.sub(value, 5, string.len(value))
        if tmp ~= "" then
            return tonumber(tmp)
        else
            return 1
        end
    end
    return nil
end


--限次抖动
--params.node      节点
--params.direction 方向(point)
--params.time      抖动次数
--params.duration  抖动间隔
function BDInterface.shakeTimes(params)
    if (params.node.shakeNodePos) then
        params.node:stopActionByTag(bd.CONST.actionTag.eShake)
        params.node:setPosition(params.node.shakeNodePos)
    else
        params.node.shakeNodePos = params.node:getPosition3D()
    end

    local array = {}
    local weekFactor = 1 / (params.time + 2)

    local tmp = cc.vec3(0,0,0)
    for i = 0 , params.time do
        local toPos = cc.vec3(  ( params.direction.x * (1 - weekFactor * i) - tmp.x) ,
                                ( params.direction.y * (1 - weekFactor * i) - tmp.y) ,
                                ( params.direction.z * (1 - weekFactor * i) - tmp.z) )
        tmp = toPos
        table.insert(array , cc.MoveBy:create(params.duration, toPos))
        table.insert(array , cc.MoveBy:create(0.01, cc.vec3(-toPos.x , -toPos.y , -toPos.z)))
    end
    table.insert(array , cc.CallFunc:create(function()
        --params.node:setPosition3D(params.node.shakeNodePos)
        params.node.shakeNodePos = nil
    end))
    local action = cc.Sequence:create(array)
    action:setTag(bd.CONST.actionTag.eShake)
    params.node:runAction(action)
end


function BDInterface.handleShakeEvent(p)
    if (p.event.name == "shake") then
        local layer = bd.layer.parentLayer

        if (p.event.stringValue == "flash") then
            local aniIndex = p.event.intValue
            local aniTable = {
                [0] = "hei_bai",
                [1] = "bai_kong",
                [2] = "baiping",
                [3] = "zi_kong",
                [4] = "hei_kong",
                [5] = "heiping",
                [6] = "hong_kong",
                [7] = "hongping",
                [8] = "cheng_kong",
                [9] = "danlan_kong",
                [10] = "danlv_kong",
                [11] = "huang_kong",
                [12] = "juhong_kong",
                [13] = "lan_kong",
                [14] = "lv_kong",
                [15] = "meihong_kong",
            }

            local flashEffect = bd.interface.newEffect({
                effectName = "effect_shanping",
                animation  = aniTable[aniIndex],
                position   = cc.p(bd.ui_config.cx, bd.ui_config.cy) ,
                parent     = layer,
                endRelease = true,
                scale      = bd.ui_config.AutoScaleX,
            })
            flashEffect:setLocalZOrder(100)
        else
            local tmp = ld.split(p.event.stringValue , ",")
            if #(tmp) == 4 then
                --方向抖动
                local rotationY = (p.self:getRotationSkewX() == 180) and true or false
                local rotationX = (p.self:getRotationSkewY() == 180) and true or false

                BDInterface.shakeTimes({
                    node = layer,
                    time = tmp[4],
                    direction = cc.vec3(rotationY and -tonumber(tmp[1]) or tonumber(tmp[1]), rotationX and -tonumber(tmp[2]) or tonumber(tmp[2]), tonumber(tmp[3])),
                    duration = 0.1
                })
            end
        end
    end
end

-- 闪屏效果
function BDInterface.flashScreen(aniName)
    local scaleValue = bd.ui_config.AutoScaleX
    if g_editor_mode_hero_data then
        scaleValue = bd.ui_config.MinScale
    end

    local flashEffect = bd.interface.newEffect({
        effectName     = "effect_shanping",
        animation      = aniName,
        position       = cc.p(bd.ui_config.cx, bd.ui_config.cy) ,
        parent         = bd.layer.parentLayer,
        endRelease     = true,
        displayOnScene = false,
        scale          = scaleValue,
    })
    flashEffect:setLocalZOrder(bd.ui_config.zOrderScreen)
end


-- 全屏特效
function BDInterface.screenEffect (aniName, animation)
    local scaleValue = bd.ui_config.AutoScaleX
    if g_editor_mode_hero_data then
        scaleValue = bd.ui_config.MinScale
    end

    local flashEffect = bd.interface.newEffect({
        effectName     = aniName,
        animation      = animation,
        position       = cc.p(bd.ui_config.cx, bd.ui_config.cy) ,
        parent         = bd.layer.parentLayer,
        endRelease     = true,
        displayOnScene = false,
        scale          = scaleValue,
    })
    flashEffect:setLocalZOrder(100)
end


function BDInterface.getStandPos(pos)
    return clone(bd.ui_config.position[pos])
end


function BDInterface.getHeroZOrder(pos)
    return -pos.y
end


-- 玩家性别
-- true表示男性
function BDInterface.getPlayerSex(pos)
    local playerHeroModelId = FormationObj:getSlotInfoBySlotId(1).ModelId
    return not Utility.getModelSex(playerHeroModelId)
end


--通过形象反查heroid
function BDInterface.getHeroIdByFigure(figure)
    -- 普通怪
    -- if "hero_baiyuan" == figure then
    --     return 12010513
    -- end
    require("Config.IllusionModel")
    for i , v in pairs(IllusionModel.items) do
        if v.largePic == figure then
            return v.modelId
        end
    end

    require("Config.HeroFashionRelation")
    for i , v in pairs(HeroFashionRelation.items) do
        if v.largePic == figure then
            return v.modelId
        end
    end

    require("Config.FashionModel")
    for i , v in pairs(FashionModel.items) do
        if v.actionPic == figure then
            return v.ID
        end
    end

    for i , v in pairs(bd.data_config.HeroModel.items) do
        if v.largePic == figure then
            return v.ID
        end
    end
    return 0
end


-- @创建主将（用于某些项目需要在骨骼上加其他东西）
function BDInterface.newFigureNode(params)
    return require("ComBattle.UICtrl.BDFigureNode").new(params)
end


-- 缓存角色的待机动作第一帧
function BDInterface.cacheHeroDaijiImage(parent, figurePic)
    -- 判断是否创建过
    parent.tmpCacheTexList = parent.tmpCacheTexList or {}

    local imageName = figurePic .. "-daiji.png"

    if parent.tmpCacheTexList[imageName] == true then
        return
    end

    local skeletonNode = bd.interface.newEffect({
        effectName = figurePic,
        animation  = "daiji",
        position   = cc.p(320, 100) ,
        scale      = 0.5,
    })

    skeletonNode:setSkin("skin_01")
    skeletonNode:setTimeScale(0)
    skeletonNode:update(0)

    local figureBoundingBox = skeletonNode:getBoundingBox()
    local fixScale = 680 / figureBoundingBox.height
    fixScale = math.min(fixScale * 0.4, 0.4)

    skeletonNode:setScale(fixScale)

    local target = cc.RenderTexture:create(600, 680, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    -- target:beginWithClear(1, 0, 0, 1)
    target:begin()
    skeletonNode:visit()
    target:endToLua()
    target:retain()

    parent.tmpCacheTexList[imageName] = true

    bd.func.performWithDelay(parent, function( ... )
        local image = target:newImage()

        local tx = cc.Director:getInstance():getTextureCache():__defalut_addImage(image, imageName)

        -- 在连续挂机中可能被释放
        local sp = cc.Sprite:createWithTexture(tx)
        if sp then
            sp:setVisible(false)
            parent:addChild(sp)
        end

        image:release()
        target:release()
    end, 0)
end

-- @获取模块名
function BDInterface.getModuleName(m)
    require("Config.ModuleSubModel")
    for _, v in pairs(ModuleSubModel.items) do
        if v.alias == m then
            return v.name
        end
    end
end


-- @创建转生图片
function BDInterface.createRebornSprite(reborn)
    -- 见BattlePatch.lua
    return
end


return BDInterface
