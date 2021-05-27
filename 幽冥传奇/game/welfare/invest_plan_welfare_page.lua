------------------------------------------------------------
--投资计划主View
------------------------------------------------------------
InvestPlanWelfarePage = InvestPlanWelfarePage or BaseClass()

function InvestPlanWelfarePage:__init()

end

function InvestPlanWelfarePage:__delete()
	self:RemoveEvent()

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

	self.view = nil
end

function InvestPlanWelfarePage:InitPage(view)
	self.view = view
	self:CreateCells()
	CommonAction.ShowMoveAction(self.view.node_t_list.show_invest_icon.node, cc.p(0, 35), 0.75)
	self:CreateStageEffect()
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_invest_des.node, Language.InvestPlan.InvestPlanDesc, 22)
	XUI.SetRichTextVerticalSpace(self.view.node_t_list.rich_invest_des.node, 8)
	XUI.AddClickEventListener(self.view.node_t_list.layout_invest_oprate.node, BindTool.Bind(self.OnOprateClick, self), true)
	if self.alert == nil then
		self.alert = Alert.New()
		local ok_func = function() 
						WelfareCtrl.Instance:InvestPlanInfoReq(1)
					end
		self.alert:SetOkFunc(ok_func)
		local str = string.format(Language.InvestPlan.AlertContent, WelfareData.GetInvestNeedIngot())
		self.alert:SetLableString(str)
	end
end

function InvestPlanWelfarePage:InitEvent()

end

function InvestPlanWelfarePage:RemoveEvent()
	
end

--更新视图界面
function InvestPlanWelfarePage:UpdateData(data)
	local invest_plan_data = WelfareData.Instance:GetInvestPlanData()
	self:ChangeOperateBtnWordImg(invest_plan_data)
	self.view.node_t_list.txt_invest_rest_day.node:setString(string.format(Language.InvestPlan.RestFetchDay, invest_plan_data.rest_day))
end	

function InvestPlanWelfarePage:CreateCells()
	if not self.cells_list then
		self.cells_list = {}
		local award_data = WelfareData.Instance:GetAwardData()
		if award_data then
			for i = 1, #award_data, 1 do
				local ph = self.view.ph_list["ph_invest_cell_" .. i]
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
					self.view.node_t_list.layout_invest_plan.node:addChild(cell:GetView(), 99)
					self.cells_list[i] = cell
				end
			end
		end
	end
end

function InvestPlanWelfarePage:CreateStageEffect()
	local ph_pic = self.view.ph_list.ph_invest_stage_eff
	if self.stage_effect == nil then
		self.stage_effect = RenderUnit.CreateEffect(989, 
			self.view.node_t_list.layout_invest_plan.node,
			9, nil, nil, ph_pic.x, ph_pic.y)
		self.stage_effect:setScale(1.2)
	end
end

function InvestPlanWelfarePage:ChangeOperateBtnWordImg(invest_plan_data)
	local res_name = Language.InvestPlan.InvestPlanTxt1

	if invest_plan_data.rest_day <= 0 then
		if invest_plan_data.fetch_state == InvestPlanFetchState.Not_Fetch then
			res_name = Language.InvestPlan.InvestPlanTxt1
		else
			res_name = Language.InvestPlan.InvestPlanTxt2
		end
	else
		if invest_plan_data.fetch_state == InvestPlanFetchState.Not_Fetch then
			res_name = Language.InvestPlan.InvestPlanTxt3
		else
			res_name = Language.InvestPlan.InvestPlanTxt2
		end
	end

	self.view.node_t_list.img_invest_word.node:setString(res_name)
end

function InvestPlanWelfarePage:OnOprateClick()
	local role_id = GameVoManager.Instance:GetUserVo():GetNowRole()
	local role_name = GameVoManager.Instance:GetMainRoleVo().name
	local server_id = GameVoManager.Instance:GetUserVo().real_server_id		--登陆的服ID
	local amount = WelfareData.GetInvestNeedMoney()
	-- print("role_id, role_name, server_id", role_id, role_name, server_id)
	local invest_plan_data = WelfareData.Instance:GetInvestPlanData()
	if invest_plan_data.rest_day <= 0 then
		self.alert:Open()	
		if invest_plan_data.fetch_state == InvestPlanFetchState.Not_Fetch then
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
			WelfareCtrl.Instance:InvestPlanAwarFetchReq()
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