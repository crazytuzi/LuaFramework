local CSGoldTrunbleActView = CSGoldTrunbleActView or BaseClass(CSActBaseView)

function CSGoldTrunbleActView:__init(view, parent)
	self:LoadView(parent)
end

function CSGoldTrunbleActView:__delete()

end

function CSGoldTrunbleActView:InitView()
	XUI.AddClickEventListener(self.tree.layout_draw_ten.node, function()
		ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.YBZP, 0)
	end, true)


	local event_proxy = EventProxy.New(self.act_model, self)
	event_proxy:AddEventListener("XFRY_DATA_CHANGE", BindTool.Bind(self.OnDataChange, self))
end

function CSGoldTrunbleActView:OnDataChange()
	self:RefreshView()
end

function CSGoldTrunbleActView:ShowIndexView(param_list)
	ActivityBrilliantCtrl.Instance.ActivityReq(3, self.act_id)
	self:RefreshView()
end

function CSGoldTrunbleActView:RefreshView(param_list)

end



function CSGoldTrunbleActView:SendRecPersonRewardReq(level)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSendActivityBrillantReq)
	protocol.type = 4
	protocol.cmd_id = ActivityBrilliantData.Instance:GetCmdIdByActId(self.act_model.act_id) or 0
	protocol.act_id = self.act_model.act_id
	protocol.activity_index = level
	protocol:EncodeAndSend()
end

------------------------------------------------------------------
return CSGoldTrunbleActView
