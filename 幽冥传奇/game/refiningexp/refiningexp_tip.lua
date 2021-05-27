RefiningExpTip = RefiningExpTip or BaseClass(BaseView)

function RefiningExpTip:__init()
    self:SetModal(true)
	self:SetIsAnyClickClose(true)
    self.texture_path_list[1] = 'res/xui/bag.png'
    self.config_tab = {
		{"refiningexp_ui_cfg", 2, {0}}
	}

end

function RefiningExpTip:ReleaseCallBack()
    
end

function RefiningExpTip:LoadCallBack(index, loaded_times)
    if loaded_times <= 1 then
        local txt = "您本次经验炼制会导致等级超出等级上限，{wordcolor;#ff0000;无法继续提升等级}，是否继续炼制？"
        RichTextUtil.ParseRichText(self.node_t_list.rich_desc.node, txt, 28, COLOR3B.G_W2)

        XUI.AddClickEventListener(self.node_t_list.btn_cancel.node, BindTool.Bind(self.OnClickCancel, self), true)
        XUI.AddClickEventListener(self.node_t_list.btn_ok.node, BindTool.Bind(self.OnClickOk, self), true)

        -- 点击前往突破等级上限
        local text = RichTextUtil.CreateLinkText("点击前往突破等级上限", 22, COLOR3B.GREEN, nil, true)
        text:setPosition(240, 110)
        self.node_t_list.layout_exp_tip.node:addChild(text, 9)
        XUI.AddClickEventListener(text, BindTool.Bind(self.OnClickTp, self), true)
    end
end

function RefiningExpTip:OpenCallBack()
    AudioManager.Instance:PlayOpenCloseUiEffect()
end

function RefiningExpTip:CloseCallBack()
    AudioManager.Instance:PlayOpenCloseUiEffect()
end

function RefiningExpTip:OnFlush(param_list, index)
   
end

function RefiningExpTip:OnClickCancel()
    self:Close()
end

function RefiningExpTip:OnClickOk()
    RefiningExpCtrl.Instance:SendRefiningExpReq(2)
end

function RefiningExpTip:OnClickTp()
    ViewManager.Instance:OpenViewByDef(ViewDef.Role.Level)
    self:Close()
end