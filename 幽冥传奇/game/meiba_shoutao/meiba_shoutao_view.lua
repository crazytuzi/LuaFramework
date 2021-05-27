MeiBaShouTaoView = MeiBaShouTaoView or BaseClass(BaseView)

function MeiBaShouTaoView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
		'res/xui/meiba_shoutao.png'
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}
	
	self.title_img_path = ResPath.GetWord("MeiBaShouTao")
	
	require("scripts/game/meiba_shoutao/hand_add_view").New(ViewDef.MeiBaShouTao.HandAdd)
	require("scripts/game/meiba_shoutao/hand_compose_view").New(ViewDef.MainGodEquipView.ReXueFuzhuang.MeiBaShouTao)
end

function MeiBaShouTaoView:ReleaseCallBack()
end

function MeiBaShouTaoView:LoadCallBack(index, loaded_times)
	self.data = MeiBaShouTaoData.Instance				--数据
	-- MeiBaShouTaoData.Instance:AddEventListener(MeiBaShouTaoData.INFO_CHANGE, BindTool.Bind(self.OnDataChange, self))
end

function MeiBaShouTaoView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function MeiBaShouTaoView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function MeiBaShouTaoView:OnDataChange(vo)
end
