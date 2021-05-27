StuffTipsView = StuffTipsView or BaseClass(XuiBaseView)

function StuffTipsView:__init()
    self:SetModal(true)
	self:SetIsAnyClickClose(true)

    self.config_tab = {
		{"itemtip_ui_cfg", 10, {0}}
	}

    self.title_text = ""
    self.vertical_interval = 10
end

function StuffTipsView:ReleaseCallBack()
    if self.stuff_list then
        self.stuff_list:DeleteMe()
        self.stuff_list = nil
    end
end

function StuffTipsView:LoadCallBack(index, loaded_times)
    if loaded_times <= 1 then
        self.inner_content = XUI.CreateLayout(0, 0, 0, 0)
        self.node_t_list.img_bg.node:addChild(self.inner_content, 10)
    end
end

function StuffTipsView:OpenCallBack()
    AudioManager.Instance:PlayOpenCloseUiEffect()
end

function StuffTipsView:CloseCallBack()
    AudioManager.Instance:PlayOpenCloseUiEffect()
end

function StuffTipsView:OnFlush(param_list, index)
    self.node_t_list.lbl_title.node:setString(self.title_text)

    local data = param_list.all
    if data == nil then return end

    self:AjustWayItems(data)
end

function StuffTipsView:AjustWayItems(data)
    local ph = self.ph_list.ph_stuff_list
    if nil == self.stuff_list then
        self.stuff_list = ListView.New()
        self.stuff_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, WayItemRender, nil, nil, self.ph_list.ph_stuff_way)
        self.inner_content:addChild(self.stuff_list:GetView(), 300)
    end
    self.stuff_list:SetDataList(data)
    self.stuff_list:SetJumpDirection(ListView.Top)
    self.stuff_list:SetItemsInterval(10)
end

function StuffTipsView:SetTitleText(title_text)
    self.title_text = title_text
end


WayItemRender = WayItemRender or BaseClass(BaseRender)
function WayItemRender:__init()
end

function WayItemRender:CreateChild()
    BaseRender.CreateChild(self)
    XUI.AddClickEventListener(self.node_tree.btn_open.node, BindTool.Bind(self.OnClickOpen, self))
end

function WayItemRender:OnFlush()
    if self.data == nil then return end

    if self.data.go_to ~= nil then
        self.node_tree.btn_open.node:setTitleText(Language.Tip.ButtonLabel[17])
    elseif self.data.open_view ~= nil then
        self.node_tree.btn_open.node:setTitleText(Language.Tip.ButtonLabel[16])
    end
    self.node_tree.lbl_stuff_way.node:setString(self.data.stuff_way)
end

function WayItemRender:OnClickOpen()
    if self.data.click_callback ~= nil then
        self.data.click_callback()
        return
    end
    
    if self.data.go_to ~= nil then
        Scene.SendQuicklyTransportReq(self.data.go_to)
    elseif self.data.open_view ~= nil then
        ViewManager.Instance:Open(self.data.open_view, self.data.index, self.data.is_ignore_funopen)
    end
end

function WayItemRender:CreateSelectEffect()
end