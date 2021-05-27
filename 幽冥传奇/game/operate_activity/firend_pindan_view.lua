------------------------------------------------------------
-- 好友拼单View
------------------------------------------------------------
FriendPinDanView = FriendPinDanView or BaseClass(XuiBaseView)

function FriendPinDanView:__init()
	self.is_any_click_close = true
	-- self.texture_path_list[1] = 'res/xui/limit_activity.png'
	
	self.config_tab = { --类dom模式,数组顺序决定渲染顺序
		{"operate_activity_ui_cfg", 31, {0}},
	}
	
end

function FriendPinDanView:__delete()

end

function FriendPinDanView:ReleaseCallBack()
	if self.friend_list then
		self.friend_list:DeleteMe()
		self.friend_list = nil
	end
end

function FriendPinDanView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateList()
		XUI.AddClickEventListener(self.node_t_list.btn_close_window.node, BindTool.Bind(self.OnCloseHandler, self), true)
	end
	
end

function FriendPinDanView:OpenCallBack()
	
end

function FriendPinDanView:CloseCallBack()
	
end

function FriendPinDanView:ShowIndexCallBack(index)
	self:Flush(index)
end

function FriendPinDanView:OnFlush(param_t, index)
	for k, v in pairs(param_t) do
		if k == "all" then
			self.friend_list:SetDataList(v.data)
		end
	end
end

function FriendPinDanView:CreateList()
	if nil == self.friend_list then
		local ph = self.ph_list.ph_friend_pindan_list
		self.friend_list = ListView.New()
		self.friend_list:Create(ph.x, ph.y, ph.w, ph.h, nil, FriendPinDanRender, nil, nil, self.ph_list.ph_friend_pindan_item)
		self.friend_list:SetItemsInterval(5)
		self.friend_list:SetJumpDirection(ListView.Top)
		self.friend_list:SetIsUseStepCalc(false)
		-- self.friend_list:SetSelectCallBack(BindTool.Bind(self.SelectItemCallback, self))
		self.node_t_list.layout_friend_pindan.node:addChild(self.friend_list:GetView(), 20)
	end
end

