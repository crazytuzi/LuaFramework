EscortTipsPage = EscortTipsPage or BaseClass(XuiBaseView)

function EscortTipsPage:__init()
	self.can_penetrate = false
	self.is_any_click_close = true
	self.config_tab = {
						{"escort_ui_cfg", 2, {0}}
					}

end

function EscortTipsPage:__delete()
	
end

function EscortTipsPage:ReleaseCallBack()
	
end

function EscortTipsPage:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		XUI.AddClickEventListener(self.node_t_list.btn_end.node, BindTool.Bind1(self.OnClose, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_true.node, BindTool.Bind1(self.OnEnsure, self))
	end
end

function EscortTipsPage:OnFlush(paramt,index)
	if not paramt then return end
	local content = ""
	local data = EscortData.Instance:GetRefreQualityData()
	for k, v in pairs(paramt) do
		if k == "overtime" then
			content = Language.Escort.EscortOverTime
		elseif k == "success" then
			if data.escort_num == EscortConfig.Times then
				self.node_t_list.btn_true.node:setTitleText(Language.Escort.EscortState[3])
				content = Language.Escort.EscortNoTime
			else
				self.node_t_list.btn_true.node:setTitleText(Language.Escort.EscortState[1])
				content = Language.Escort.EscortSuccess
			end
		end
		RichTextUtil.ParseRichText(self.node_t_list.txt_tips_info.node, content or "", 24, COLOR3B.G_Y)
	end
end

function EscortTipsPage:ShowIndexCallBack(index)
	self:Flush(index)
end

function EscortTipsPage:CloseCallBack()
end

function EscortTipsPage:OnClose()
	self:Close()
end

function EscortTipsPage:OnEnsure()
	local data = EscortData.Instance:GetRefreQualityData()
	if data.escort_num == EscortConfig.Times then
		ViewManager.Instance:Open(ViewName.Activity)
		self:Close()
	else
		local data = EscortConfig.EscortSrc
		ActivityCtrl.Instance:SendActiveGuidanceReq(17)
		--Scene.Instance:GetMainRole():LeaveFor(data.sceneid, data.x, data.y, MoveEndType.NpcTask, data.npcid)
		self:Close()
	end
end



