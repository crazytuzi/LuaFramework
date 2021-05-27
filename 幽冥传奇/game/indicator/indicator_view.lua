IndicatorView = IndicatorView or BaseClass(XuiBaseView)

function IndicatorView:__init()
    self:SetModal(true)

    self.texture_path_list[1] = "res/xui/indicator.png"
    self.texture_path_list[1] = "res/xui/npc_dialog.png"
    self.config_tab = {
        {"indicator_ui_cfg", 1, {0}},
    }
end

function IndicatorView:ReleaseCallBack()
    self.effect = nil
end

function IndicatorView:LoadCallBack(index, loaded_times)
    if loaded_times <= 1 then
        XUI.AddClickEventListener(self.node_t_list.btn_continue.node, BindTool.Bind(self.Close, self))
        local effect = RenderUnit.CreateEffect(909, self.node_t_list.btn_continue.node)
        effect:setPositionY(90)
    end
end

function IndicatorView:OpenCallBack()
    AudioManager.Instance:PlayOpenCloseUiEffect()
end

function IndicatorView:CloseCallBack()
    AudioManager.Instance:PlayOpenCloseUiEffect()
end

function IndicatorView:OnFlush(param_list, index)
    local id = param_list.all.id
    if id == nil then
        return
    end

    local cfg = IndicatorData.GetOpenCfgById(id)
    if cfg == nil then
        return
    end

    self.node_t_list.img_title.node:loadTexture(ResPath.GetIndicator(cfg.title))
    self.node_t_list.img_desc.node:loadTexture(ResPath.GetIndicator(cfg.desc))
    self.node_t_list.img_content.node:loadTexture(ResPath.GetIndicator(cfg.content))
    if self.effect == nil then
        self.effect = AnimateSprite:create()
        self.effect:setPosition(145, 270)
        self.root_node:addChild(self.effect, 999)
    end
    local anim_path, anim_name = ResPath.GetEffectUiAnimPath(cfg.effect)
    self.effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
end