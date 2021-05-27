------------------------------------------------------------
-- 分享列表
------------------------------------------------------------
SharelistView = SharelistView or BaseClass(BaseView)

function SharelistView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/bag.png'
	self.texture_path_list[2] = 'res/xui/blessing.png'
	self.config_tab = {
		{"blessing_ui_cfg", 4, {0}},
	}

end

function SharelistView:__delete()
end

function SharelistView:ReleaseCallBack()
	
end

function SharelistView:OpenCallBack()
	
end
function SharelistView:ShowIndexCallBack(index)
	self:Flush()
end
function SharelistView:CloseCallBack()
	BlessingData.Instance:InitShareData()
	BlessingCtrl:SendFortune(4)
end

function SharelistView:LoadCallBack(index, loaded_times)
	if loaded_times<= 1 then
		self:CreateShareList()

		EventProxy.New(BlessingData.Instance, self):AddEventListener(BlessingData.SHARE_DATA, BindTool.Bind(self.OnShareData, self))
	end
end

function SharelistView:OnShareData()
	self:Flush()
end

function SharelistView:CreateShareList()
	local ph = self.ph_list.ph_fx_list
	self.share_fx_list = ListView.New()
	self:AddObj("share_fx_list")
	self.share_fx_list:Create(ph.x, ph.y, ph.w, ph.h, nil, SharelistView.ShareRender, nil, nil, self.ph_list.ph_fx_item)
	-- self.share_fx_list:GetView():setAnchorPoint(0, 0)
	self.share_fx_list:SetItemsInterval(5)
	self.share_fx_list:SetJumpDirection(ListView.Top)
	-- self.share_fx_list:SetDelayCreateCount(10)
	self.node_t_list.layout_fx_list.node:addChild(self.share_fx_list:GetView(), 100)
end

function SharelistView:OnFlush(param_t, index)
	local data = BlessingData.Instance:GetShareData()
	self.share_fx_list:SetDataList(data)
end

-- 分享好友列表
SharelistView.ShareRender = BaseClass(BaseRender)
local ShareRender = SharelistView.ShareRender
function ShareRender:__init()	

end

function ShareRender:__delete()	
end

function ShareRender:CreateChild()
	BaseRender.CreateChild(self)

	XUI.AddClickEventListener(self.node_tree.btn_accept.node, BindTool.Bind2(self.OnAccept, self))
end

function ShareRender:OnFlush()
	if self.data == nil then return end

	local data = BlessingData.Instance:GetHyInfo(self.data.share_name)

	self.node_tree.icon_head.node:loadTexture(ResPath.GetBlessing("img_sex_" .. data.sex))
	self.node_tree.lbl_role_name.node:setString(self.data.share_name)
	self.node_tree.lbl_tole_guild.node:setString("运势：" .. Language.Blessing.FortuneType[self.data.fortune_lv])
end

function ShareRender:OnAccept()
	BlessingCtrl.Instance:SendFortune(3, 0, self.data.share_id)
	BlessingData.Instance:RemoveData(self.data.share_id)
end