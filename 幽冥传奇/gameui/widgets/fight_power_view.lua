FightPowerView = FightPowerView or BaseClass()

function FightPowerView:__init(x, y, parent_node, zorder, has_frame)
    self.view = XUI.CreateLayout(x, y, 0, 0)
    parent_node:addChild(self.view, zorder)

    self.fight_power_word = XUI.CreateImageView(-20, 0, ResPath.GetCommon("part_101"), true)
    self.fight_power_word:setAnchorPoint(1, 0.5)
    self.view:addChild(self.fight_power_word, 100)

    self.num_bar = NumberBar.New()
    self.num_bar:Create(-20, - 22, 0, 0, ResPath.GetCommon("num_133_"))
    self.num_bar:SetSpace(-8)
    self.view:addChild(self.num_bar:GetView(), 101)

    local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1126)
    self.eff = AnimateSprite:create(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
    self.eff:setPosition(35, 10)
    self.eff:setScale(1)
    self.view:addChild(self.eff, 2)

    if has_frame then
        self.frame_img = XUI.CreateImageView(0, 0, ResPath.GetCommon("bg_211"), true)
        self.view:addChild(self.frame_img, 1)
    end
end

function FightPowerView:__delete()
    if self.num_bar then
        self.num_bar:DeleteMe()
        self.num_bar = nil
    end
    self.fight_power_word = nil
    self.eff = nil
    self.view = nil
end

function FightPowerView:GetView()
    return self.view
end

function FightPowerView:SetNumber(num)
    self.num_bar:SetNumber(num)
end

function FightPowerView:SetScale(scale)
    self.view:setScale(scale)
end

function FightPowerView:LoadTexturePower(path)
    self.fight_power_word:loadTexture(path)
end