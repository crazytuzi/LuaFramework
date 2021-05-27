CrossLandView = CrossLandView or BaseClass(BaseView)

function CrossLandView:__init()
	self.title_img_path = ResPath.GetWord("word_strengthfb")
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
		--'res/xui/cross_land.png'
		"res/xui/cross_boss.png",
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
		{"cross_land_ui_cfg", 1, {0}},

	}

end

function CrossLandView:ReleaseCallBack()
end

function CrossLandView:LoadCallBack(index, loaded_times)
	self.data = CrossLandData.Instance				--数据
	XUI.AddClickEventListener(self.node_t_list.layout_shenhao.node, BindTool.Bind(self.OnClicLayout, self, 1), false)
	-- CrossLandData.Instance:AddEventListener(CrossLandData.INFO_CHANGE, BindTool.Bind(self.OnDataChange, self))
end

function CrossLandView:OnClicLayout(idx)
	ViewManager.Instance:OpenViewByDef(ViewDef.Temples)
end
function CrossLandView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CrossLandView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CrossLandView:OnDataChange(vo)
end
