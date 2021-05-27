CombinedServerActView = CombinedServerActView or BaseClass(BaseView)

function CombinedServerActView:LoadPartyView()
	self.node_t_list.btn_pd_go.node:addClickEventListener(BindTool.Bind(self.OnClickPartyHandler, self))
end

function CombinedServerActView:DeletePartyView()
	-- body
end

function CombinedServerActView:FlushPartyView(param_t)
     local act_id = CombinedServerActData.GetActIdByIndex(self:GetShowIndex())
	if act_id == CombinedActId.YB_Party then
	  self.node_t_list.img_pd_word.node:loadTexture(ResPath.GetCombind("combind_word3"))
	 elseif act_id == CombinedActId.CB_Party then 
	  self.node_t_list.img_pd_word.node:loadTexture(ResPath.GetCombind("combind_word4"))
	 elseif act_id == CombinedActId.ZH_Party then
	  self.node_t_list.img_pd_word.node:loadTexture(ResPath.GetCombind("combind_word5"))
	 elseif act_id == CombinedActId.BS_Party then
	  self.node_t_list.img_pd_word.node:loadTexture(ResPath.GetCombind("combind_word6"))
     elseif act_id == CombinedActId.LH_Party then
      self.node_t_list.img_pd_word.node:loadTexture(ResPath.GetCombind("combind_word9"))
	end
end


function CombinedServerActView:OnClickPartyHandler()
	local act_id = CombinedServerActData.GetActIdByIndex(self:GetShowIndex())
	CombinedServerActCtrl.SendSendCombinedReq(act_id)
end