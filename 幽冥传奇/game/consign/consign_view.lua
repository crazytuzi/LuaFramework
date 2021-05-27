ConsignView = ConsignView or BaseClass(BaseView)

function ConsignView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.title_img_path = ResPath.GetWord("word_consign")	
	self.texture_path_list[1] = 'res/xui/consign.png'
	self.config_tab = {
		-- {"common_ui_cfg", 1, {0}},
		{"consign_ui_cfg", 1, {0}},
		-- {"common_ui_cfg", 2, {0}, nil, 999},
	}
	
	self.btn_info = {
		ViewDef.Consign.Buy,
		ViewDef.Consign.Sell,		
		ViewDef.Consign.Consign,
		ViewDef.Consign.RedDrill,
	}
	self.remind_list = {}
end

function ConsignView:__delete()
end

function ConsignView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function ConsignView:LoadCallBack(index, loaded_times)
	local name_list = {}
	for k, v in pairs(self.btn_info) do
		name_list[#name_list + 1] = v.name
	end
	self.tabbar = Tabbar.New()
	self.tabbar:SetTabbtnTxtOffset(- 10, 0)
	self.tabbar:SetClickItemValidFunc(function(index)
		return ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	end)
	self.tabbar:SetTabbtnTxtOffset(2, 12)
	self.tabbar:CreateWithNameList(self:GetRootNode(), 30, 530, nil, name_list, true, ResPath.GetCommon("toggle_110"), 25, true)
	
end

function ConsignView:OpenCallBack()
end

function ConsignView:CloseCallBack(is_all)
end

function ConsignView:ShowIndexCallBack(index)
	self:FlushBtns()
	self:Flush()
end

function ConsignView:OnFlush(param_t, index)
end
------------------------------------------------------
function ConsignView:FlushBtns()
	for k, v in pairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(v) then
			self.tabbar:ChangeToIndex(k)
			self.node_t_list.layout_my_item.node:setVisible(k == 2)
		end
	end
end
