local CSLuckTrunbleActView = CSLuckTrunbleActView or BaseClass(CSActBaseView)

function CSLuckTrunbleActView:__init(view, parent)
	self:LoadView(parent)
end

function CSLuckTrunbleActView:__delete()

end

function CSLuckTrunbleActView:InitView()
	XUI.AddClickEventListener(self.tree.btn_draw_204.node, function()
		ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.XYZP, 0)
	end, true)


	local event_proxy = EventProxy.New(self.act_model, self)
	event_proxy:AddEventListener("XFRY_DATA_CHANGE", BindTool.Bind(self.OnDataChange, self))
end

function CSLuckTrunbleActView:OnDataChange()
	self:RefreshView()
end

function CSLuckTrunbleActView:ShowIndexView(param_list)
	ActivityBrilliantCtrl.Instance.ActivityReq(3, self.act_id)
	self:RefreshView()
end

function CSLuckTrunbleActView:RefreshView(param_list)

end



function CSLuckTrunbleActView:SendRecPersonRewardReq(level)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSendActivityBrillantReq)
	protocol.type = 4
	protocol.cmd_id = ActivityBrilliantData.Instance:GetCmdIdByActId(self.act_model.act_id) or 0
	protocol.act_id = self.act_model.act_id
	protocol.activity_index = level
	protocol:EncodeAndSend()
end

------------------------------------------------------------------
return CSLuckTrunbleActView
