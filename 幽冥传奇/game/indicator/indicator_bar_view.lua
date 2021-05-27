IndicatorBar = IndicatorBar or BaseClass(XuiBaseView)

function IndicatorBar:__init()
    self.texture_path_list[1] = "res/xui/indicator.png"
end

function IndicatorBar:ReleaseCallBack()
    if self.numberbar then
        self.numberbar:DeleteMe()
        self.numberbar = nil
    end
end

function IndicatorBar:LoadCallBack(index, loaded_times)
    self.img_indicator_bar = XUI.CreateImageView(0, 0, ResPath.GetIndicator("indicator_bar"), true)
    self.root_node:addChild(self.img_indicator_bar)

    local cs = self.img_indicator_bar:getContentSize()
    self.root_node:setContentWH(cs.width, cs.height)
    self.img_indicator_bar:setPosition(cs.width / 2, cs.height / 2)
    XUI.AddClickEventListener(self.img_indicator_bar, BindTool.Bind(self.OnClickBar, self), false)

    self.img_icon = XUI.CreateImageView(cs.width - 43, cs.height / 2, "", true)
    self.root_node:addChild(self.img_icon)

    self.img_word_cond = XUI.CreateImageView(cs.width / 2 - 20, cs.height / 2 - 5, ResPath.GetIndicator("word_open_lv"), true)
    self.root_node:addChild(self.img_word_cond)

    self.numberbar = NumberBar.New()
    self.numberbar:Create(100, 23, 50, 30, ResPath.GetCommon("num_116_"))
    self.numberbar:SetGravity(NumberBarGravity.Center)
    self.numberbar:SetSpace(-5)
    self.root_node:addChild(self.numberbar:GetView())

    local effect = RenderUnit.CreateEffect(1222, self.root_node)
    effect:setPosition(cs.width - 45, cs.height / 2)

    local sw, sh = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
    self.root_node:setAnchorPoint(1, 0.5)
    self.root_node:setPosition(sw - 60, sh / 2 + 210)
    self.root_node:setLocalZOrder(-1)
    self.root_node:setScale(0.7)
end

function IndicatorBar:OnFlush(param_list, index)
    local level = param_list.all.level
    local icon = param_list.all.icon
    self.id = param_list.all.id

    self.img_icon:loadTexture(icon and ResPath.GetIndicator(icon) or "")
    if type(level) == "number" then
        self.numberbar:SetNumber(level)
    end
end

function IndicatorBar:OnClickBar()
    ViewManager.Instance:Open(ViewName.Indicator)
    ViewManager.Instance:FlushView(ViewName.Indicator, 0, "all", {id = self.id})
end