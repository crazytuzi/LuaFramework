------------------------------------------------------------
-- 试炼
------------------------------------------------------------

local TrialWorldView = BaseClass(SubView)

function TrialWorldView:__init()
	-- self.texture_path_list[1] = 'res/xui/shangcheng.png'
	self.config_tab = {
		{"trial_ui_cfg", 4, {0}},
	}
end

function TrialWorldView:__delete()
end

function TrialWorldView:ReleaseCallBack()

	-- if self.shop_mystical_grid then
	-- 	self.shop_mystical_grid:DeleteMe()
	-- 	self.shop_mystical_grid = nil
	-- end

end

function TrialWorldView:LoadCallBack(index, loaded_times)

	--按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_return"].node, BindTool.Bind(self.OnReturn, self), true)


	-- 数据监听
	-- EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleAttrChange, self))
end

--显示索引回调
function TrialWorldView:ShowIndexCallBack(index)
	self:Flush()
end

----------视图函数----------

function TrialWorldView:OnFlush()
	local section, difficult  = ExperimentData.GetSectionAndDifficult()

	local cfg_section_count = TrialConfig and TrialConfig.section_count or 1
	local cfg_difficult = TrialConfig and TrialConfig.difficult or 1

	if self.node_t_list["trial_difficult_icon_" .. difficult] then
		local x, y = self.node_t_list["trial_difficult_icon_" .. difficult].node:getPosition()
		self.node_t_list["img_difficult_select"].node:setPosition(x, y)
	end

	for i = 1, cfg_section_count do
		if self.node_t_list["trial_section_lv_" .. i] then
			local path = ResPath.GetExperiment("trial_section_lv_" .. i)
			self.node_t_list["trial_section_lv_" .. i].node:loadTexture(path)
		end

		if self.node_t_list["trial_difficult_" .. i] then
			local path = ResPath.GetExperiment("trial_difficult_" .. difficult)
			self.node_t_list["trial_difficult_" .. i].node:loadTexture(path)
		end

		if self.node_t_list["lock_close_" .. i] then
			local vis = (section - 1) < i
			self.node_t_list["lock_close_" .. i].node:setVisible(vis)
			if section == i then
				local path = ResPath.GetExperiment("trial_5")
				self.node_t_list["lock_close_" .. i].node:loadTexture(path)
			else
				local path = ResPath.GetCommon("lock_close_3")
				self.node_t_list["lock_close_" .. i].node:loadTexture(path)
			end
		end
	end
end


----------end----------

function TrialWorldView:OnReturn()
	ViewManager.Instance:OpenViewByDef(ViewDef.Experiment.Trial.TrialChild)
end

--------------------


return TrialWorldView