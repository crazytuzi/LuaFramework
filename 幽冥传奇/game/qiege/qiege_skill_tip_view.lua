QiegeSkillTipView = QiegeSkillTipView or BaseClass(BaseView)

function QiegeSkillTipView:__init()
	self.is_any_click_close = true		
	self.texture_path_list = {
		'res/xui/qiege.png',
		
		}	
	self.config_tab = {
		{"qiege_ui_cfg", 5, {0}},
		
	}
	self.data = nil
end

function QiegeSkillTipView:__delete( ... )
	-- body
end

function QiegeSkillTipView:LoadCallBack(loaded_times, index)
	XUI.AddClickEventListener(self.node_t_list.btn_get.node, BindTool.Bind1(self.GetReward, self), true)
	

	self.info_change = GlobalEventSystem:Bind(QIEGE_EVENT.GetRewardInfo, BindTool.Bind1(self.OnFlush, self))
end

function QiegeSkillTipView:CreateCell( ... )

end

function QiegeSkillTipView:ReleaseCallBack( ... )
	if self.info_change then
		GlobalEventSystem:UnBind(self.info_change)
		self.info_change = nil
	end

	-- if self.shen_bin_cell then
	-- 	self.shen_bin_cell:DeleteMe()
	-- 	self.shen_bin_cell = nil
	-- end


end

function QiegeSkillTipView:OpenCallBack()
	-- body
end

function QiegeSkillTipView:SetQieGeTipData(data)
	self.data = data 
	self:Flush(index)
end

function QiegeSkillTipView:ShowIndexCallBack(index)
	self:Flush(index)
end

function QiegeSkillTipView:FlushView()
	self:Flush(index)
end

function QiegeSkillTipView:OnFlush()
	if self.data == nil then
		return 
	end
	local data = QieGeData.Instance:GetQieGeEffectData()
	local level =  QieGeData.Instance:GetLevel()
	local cur_data = data[self.data] or {}
	self.node_t_list.text_name.node:setString(cur_data.name or "")
	local item_cfg = ItemData.Instance:GetItemConfig(cur_data.reward[1].id)
	self.node_t_list.text_had.node:setString(string.format(Language.QieGe.showDesc0, item_cfg.name, cur_data.item_num))
	RichTextUtil.ParseRichText(self.node_t_list.active_condition.node, cur_data.condition)
	RichTextUtil.ParseRichText(self.node_t_list.rich_desc.node, cur_data.desc)
	local bool = false 
	if level >= cur_data.need_level  then
		bool = true
	end
	local text = bool and Language.QieGe.BtnText2[1] or Language.QieGe.BtnText2[2]
	self.node_t_list.btn_get.node:setTitleText(text)
	XUI.SetButtonEnabled(self.node_t_list.btn_get.node, bool)

	local path = ResPath.GetQieGePath("splic2")
	if self.data == 2 then
		path = ResPath.GetQieGePath("splic3")
	elseif self.data == 3 then
		path = ResPath.GetQieGePath("splic4")
	end
	self.node_t_list.img_cell_show.node:loadTexture(path)
end


function QiegeSkillTipView:GetReward()
	if self.data then
		local data = QieGeData.Instance:GetQieGeEffectData()
		local cur_data = data[self.data] or {}
		QieGeCtrl.Instance:SendGetQieGeReweardReq(cur_data.key)
	end
end
