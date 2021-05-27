------------------------------------------------------------
--投资计划主View
------------------------------------------------------------
InvestPlanView = InvestPlanView or BaseClass(XuiBaseView)

function InvestPlanView:__init()
	self.texture_path_list[1] = "res/xui/invest_plan.png"
	self:SetModal(true)
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"invest_plan_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}

	self.title_img_path = ResPath.GetInvestPlanRes("txt_biaoti")

end

function InvestPlanView:__delete()
end



function InvestPlanView:ReleaseCallBack()
	if self.stage_effect then
		self.stage_effect:removeFromParent()
		self.stage_effect = nil
	end
	if self.cells_list then
		for k, v in pairs(self.cells_list) do
			v:DeleteMe()
		end
		self.cells_list = nil
	end
	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil
	end
end

function InvestPlanView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateCells()
		CommonAction.ShowJumpAction(self.node_t_list.show_icon.node, 18)
		self:CreateStageEffect()
		RichTextUtil.ParseRichText(self.node_t_list.rich_des.node, Language.InvestPlan.InvestPlanDesc, 22)
		XUI.SetRichTextVerticalSpace(self.node_t_list.rich_des.node, 8)
		XUI.AddClickEventListener(self.node_t_list.layout_oprate.node, BindTool.Bind(self.OnOprateClick, self), true)
		if self.alert == nil then
			self.alert = Alert.New()
			local ok_func = function() 
							InvestPlanCtrl.Instance:InvestPlanInfoReq(1)
						end
			self.alert:SetOkFunc(ok_func)
			local str = string.format(Language.InvestPlan.AlertContent, InvestPlanData.GetInvestNeedIngot())
			self.alert:SetLableString(str)
			-- self.alert:SetShowCheckBox(true)
		end
	end
end

function InvestPlanView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function InvestPlanView:ShowIndexCallBack(index)
	self:Flush(index)
end

function InvestPlanView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "all" then
			local invest_plan_data = InvestPlanData.Instance:GetInvestPlanData()
			self:ChangeOperateBtnWordImg(invest_plan_data)
			self.node_t_list.txt_rest_day.node:setString(string.format(Language.InvestPlan.RestFetchDay, invest_plan_data.rest_day))
		end
	end
end

function InvestPlanView:CreateCells()
	if not self.cells_list then
		self.cells_list = {}
		local award_data = InvestPlanData.Instance:GetAwardData()
		if award_data then
			for i = 1, #award_data, 1 do
				local ph = self.ph_list["ph_cell_" .. i]
				if ph then
					local cell = BaseCell.New()
					cell:SetPosition(ph.x, ph.y)
					cell:SetData(award_data[i])
					local cell_effect = AnimateSprite:create()
					local path, name = ResPath.GetEffectUiAnimPath(920)
					if path and name then
						cell_effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
					end
					cell_effect:setPosition(ph.w / 2, ph.h / 2)
					cell_effect:setScale(1.2)
					cell:GetView():addChild(cell_effect, 300)
					self.node_t_list.layout_invest_plan.node:addChild(cell:GetView(), 99)
					self.cells_list[i] = cell
				end
			end
		end
	end
end

function InvestPlanView:CreateStageEffect()
	local ph_pic = self.ph_list.ph_stage_eff
	if self.stage_effect == nil then
		self.stage_effect = RenderUnit.CreateEffect(989, 
			self.node_t_list.layout_invest_plan.node,
			9, nil, nil, ph_pic.x, ph_pic.y)
		self.stage_effect:setScale(1.2)
	end
end

function InvestPlanView:ChangeOperateBtnWordImg(invest_plan_data)
	local res_name = "word_1"

	if invest_plan_data.rest_day <= 0 then
		if invest_plan_data.fetch_state == InvestPlanFetchState.Not_Fetch then
			res_name = "word_1"
		else
			res_name = "word_2"
		end
	else
		if invest_plan_data.fetch_state == InvestPlanFetchState.Not_Fetch then
			res_name = "word_3"
		else
			res_name = "word_2"
		end
	end

	self.node_t_list.img_word.node:loadTexture(ResPath.GetInvestPlanRes(res_name))
end

function InvestPlanView:OnOprateClick()
	local role_id = GameVoManager.Instance:GetUserVo():GetNowRole()
	local role_name = GameVoManager.Instance:GetMainRoleVo().name
	local server_id = GameVoManager.Instance:GetUserVo().real_server_id		--登陆的服ID
	local amount = InvestPlanData.GetInvestNeedMoney()
	-- print("role_id, role_name, server_id", role_id, role_name, server_id)
	local invest_plan_data = InvestPlanData.Instance:GetInvestPlanData()
	if invest_plan_data.rest_day <= 0 then
		if invest_plan_data.fetch_state == InvestPlanFetchState.Not_Fetch then
			self.alert:Open()	
		-- 	if amount and amount ~= 0 and role_id and role_name and server_id then
		-- 		-- Log("First Recharge:", role_name, role_id, server_id)
		-- 		AgentAdapter:Pay(role_id, role_name, amount, server_id, callback)
		-- 	else
		-- 		SysMsgCtrl.Instance:ErrorRemind("充值操作失败！")
		-- 	end
		-- else
		-- 	-- Log("Recharge2:", role_name, role_id, server_id)
		-- 	AgentAdapter:Pay(role_id, role_name, amount, server_id, callback)	
		end
	else
		if invest_plan_data.fetch_state == InvestPlanFetchState.Not_Fetch then
			-- print("领取奖励")
			InvestPlanCtrl.Instance:InvestPlanAwarFetchReq()
		else
			self.alert:Open()
			-- if amount and amount ~= 0 and role_id and role_name and server_id then
			-- 	-- Log("Recharge Again:", role_name, role_id, server_id)
			-- 	AgentAdapter:Pay(role_id, role_name, amount, server_id, callback)
			-- else
			-- 	SysMsgCtrl.Instance:ErrorRemind("充值操作失败！")
			-- end
		end
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end