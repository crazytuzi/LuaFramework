---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/12/11 10:27:09
-- @description: 位面 buff项
---------------------------------
local _string_format = string.format

PlanesBuffItem = class('PlanesBuffItem',function()
    return ccui.Widget:create()
end)

function PlanesBuffItem:ctor(callback)
    self.callback = callback
    self:configUI()
    self:registerEvent()
end

function PlanesBuffItem:configUI()
    self.size = cc.size(195, 362)
    self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("planes/planes_buff_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    container:setSwallowTouches(false)
    self.container = container

    self.pos_node = container:getChildByName("pos_node")
    self.name_txt = container:getChildByName("name_txt")
    self.icon_sp = container:getChildByName("icon_sp")
    self.quality_sp = container:getChildByName("quality_sp")
    self.effect_sp = container:getChildByName("effect_sp")
    self.effect_sp:setVisible(false)

    self.desc_txt = createRichLabel(16, cc.c4b(251, 228, 184), cc.p(0.5, 1), cc.p(self.size.width*0.5, 150), 0, 0, self.size.width-20)
    container:addChild(self.desc_txt)
end

function PlanesBuffItem:registerEvent()
    registerButtonEventListener(self.container, handler(self, self.onClickItem), true)
end

function PlanesBuffItem:onClickItem(  )
    if self.is_select then return end
    if self.callback then
        self.callback(self)
    end
end

function PlanesBuffItem:setIsSelect( status )
    self.is_select = status
    if status == true then
        self:setPositionY(320)
        self:handleSelectEffect(true)
    else
        self:setPositionY(290)
        self:handleSelectEffect(false)
    end
end

--卡牌边光特效
function PlanesBuffItem:handleCardEffect( status )
    if status == true then
        action = PlayerAction.action_9
        if self.buff_cfg then
            if self.buff_cfg.quality == PlanesafkConst.Buff_Quility.Blue then
                action = PlayerAction.action_9
            elseif self.buff_cfg.quality == PlanesafkConst.Buff_Quility.Purple then
                action = PlayerAction.action_8
            elseif self.buff_cfg.quality == PlanesafkConst.Buff_Quility.Orange then
                action = PlayerAction.action_7
            end
        end
        if not tolua.isnull(self.pos_node) and self.card_effect == nil then
            self.card_effect = createEffectSpine(Config.EffectData.data_effect_info[1701], cc.p(0, 0), cc.p(0.5, 0.5), true, action)
            self.pos_node:addChild(self.card_effect)
        end
    else
        if self.card_effect then
            self.card_effect:clearTracks()
            self.card_effect:removeFromParent()
            self.card_effect = nil
        end
    end
end

-- 选中时出现的特效
function PlanesBuffItem:handleSelectEffect( status )
    if status == true then
        action = PlayerAction.action_4
        if self.buff_cfg then
            if self.buff_cfg.quality == PlanesafkConst.Buff_Quility.Blue then
                action = PlayerAction.action_6
            elseif self.buff_cfg.quality == PlanesafkConst.Buff_Quility.Purple then
                action = PlayerAction.action_5
            elseif self.buff_cfg.quality == PlanesafkConst.Buff_Quility.Orange then
                action = PlayerAction.action_4
            end
        end
        self.is_enter_effect = true
        if not tolua.isnull(self.pos_node) and self.select_effect == nil then
            self.select_effect = createEffectSpine(Config.EffectData.data_effect_info[1701], cc.p(0, 0), cc.p(0.5, 0.5), false, action, handler(self, self.onSelectEffectEnd))
            self.pos_node:addChild(self.select_effect)
        end
    else
        if self.select_effect then
            self.select_effect:clearTracks()
            self.select_effect:removeFromParent()
            self.select_effect = nil
        end
    end
end

-- 选中进入特效后播放选中循环特效
function PlanesBuffItem:onSelectEffectEnd(  )
    if self.select_effect and self.is_enter_effect then
        self.is_enter_effect = false
        local action = PlayerAction.action_1
        if self.buff_cfg then
            if self.buff_cfg.quality == PlanesafkConst.Buff_Quility.Blue then
                action = PlayerAction.action_3
            elseif self.buff_cfg.quality == PlanesafkConst.Buff_Quility.Purple then
                action = PlayerAction.action_2
            elseif self.buff_cfg.quality == PlanesafkConst.Buff_Quility.Orange then
                action = PlayerAction.action_1
            end
        end
        self.select_effect:setAnimation(0, action, true)
    end
end

function PlanesBuffItem:setData(buff_cfg)
    if not buff_cfg then return end

    self.buff_cfg = buff_cfg
    if not self.buff_cfg then return end

    -- 名称
    self.name_txt:setString(self.buff_cfg.name)
    self.name_txt:setTextColor(self:getNameColorByQuality(self.buff_cfg.quality))

    -- 描述
    self.desc_txt:setString(self.buff_cfg.desc)

    -- 图标
    local icon_res = _string_format("resource/planes/buff_icon/%s.png", self.buff_cfg.res_id)
    self.icon_sp_load = loadSpriteTextureFromCDN(self.icon_sp, icon_res, ResourcesType.single, self.icon_sp_load)

    -- 品质图标
    local qua_icon_res = self:getQualityIconRes(self.buff_cfg.quality)
    loadSpriteTexture(self.quality_sp, qua_icon_res, LOADTEXT_TYPE_PLIST)

    -- 效果图标
    local effect_res
    local range_cfg = self.buff_cfg.range
    if range_cfg and range_cfg[1] and next(range_cfg[1]) ~= nil then
        local effect_type = range_cfg[1][1]
        local effect_val = range_cfg[1][2]
        if effect_type == "career_type" then -- 职业
            effect_res = self:getCareerRes(effect_val)
            self.effect_sp:setScale(1)
        elseif effect_type == "camp_type" then -- 阵营
            effect_res = PathTool.getHeroCampTypeIcon(effect_val)
            self.effect_sp:setScale(0.82)
        elseif effect_type == "partner" then -- 英雄
            self.hero_item = PlayerHead.new(PlayerHead.type.circle)
            self.hero_item:setScale(0.5)
            self.hero_item:setPosition(97, 26)
            self.container:addChild(self.hero_item)
            self.hero_item:setHeadRes(effect_val)
        else
            self.effect_sp:setScale(1)
            effect_res = PathTool.getResFrame("planes", "planes_buff_6", false, "planes_buff")
        end
    else -- 全部
        self.effect_sp:setScale(1)
        effect_res = PathTool.getResFrame("planes", "planes_buff_6", false, "planes_buff")
    end

    if effect_res then
        self.effect_sp:setVisible(true)
        loadSpriteTexture(self.effect_sp, effect_res, LOADTEXT_TYPE_PLIST)
        if self.hero_item then
            self.hero_item:setVisible(false)
        end
    else
        if self.hero_item then
            self.hero_item:setVisible(true)
        end
        self.effect_sp:setVisible(false)
    end

    self:handleCardEffect(true)
end

function PlanesBuffItem:getBuffId(  )
    if self.buff_cfg then
        return self.buff_cfg.buff_id
    end
end

-- 根据品质获取名称字色
function PlanesBuffItem:getNameColorByQuality( quality )
    if quality == PlanesafkConst.Buff_Quility.Orange then 
        return Config.ColorData.data_color4[246] 
    elseif quality == PlanesafkConst.Buff_Quility.Purple then 
        return Config.ColorData.data_color4[245] 
    else
        return Config.ColorData.data_color4[244]
    end
end

-- 根据品质获取品质图标资源
function PlanesBuffItem:getQualityIconRes( quality )
    if quality == PlanesafkConst.Buff_Quility.Blue then
        return PathTool.getResFrame("planes", "planes_buff_10", false, "planes_buff")
    elseif quality == PlanesafkConst.Buff_Quility.Purple then
        return PathTool.getResFrame("planes", "planes_buff_12", false, "planes_buff")
    elseif quality == PlanesafkConst.Buff_Quility.Orange then
        return PathTool.getResFrame("planes", "planes_buff_8", false, "planes_buff")
    else
        return PathTool.getResFrame("planes", "planes_buff_10", false, "planes_buff")
    end
end

-- 获取职业图标
function PlanesBuffItem:getCareerRes( val )
    if val == 2 then -- 法
        return PathTool.getResFrame("planes", "planes_buff_3", false, "planes_buff")
    elseif val == 3 then -- 物
        return PathTool.getResFrame("planes", "planes_buff_2", false, "planes_buff")
    elseif val == 4 then -- 肉
        return PathTool.getResFrame("planes", "planes_buff_4", false, "planes_buff")
    elseif val == 5 then -- 辅
        return PathTool.getResFrame("planes", "planes_buff_5", false, "planes_buff")
    end
end

function PlanesBuffItem:suspendAllActions(  )
end

function PlanesBuffItem:DeleteMe()
    if self.icon_sp_load then
        self.icon_sp_load:DeleteMe()
        self.icon_sp_load = nil
    end
    if self.hero_item then
        self.hero_item:DeleteMe()
        self.hero_item = nil
    end
    self:handleCardEffect(false)
    self:handleSelectEffect(false)
    self:removeAllChildren()
	self:removeFromParent()
end