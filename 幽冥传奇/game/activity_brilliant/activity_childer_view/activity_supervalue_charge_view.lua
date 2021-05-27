SupervalueChargeView = SupervalueChargeView or BaseClass(ActBaseView)

function SupervalueChargeView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function SupervalueChargeView:__delete()
	if nil~=self.supervalue_charge_list then
		self.supervalue_charge_list:DeleteMe()
	end
	self.supervalue_charge_list = nil

	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
end

function SupervalueChargeView:InitView()
	self:CreateSupervaleChargeList()
	self.cell_list = {}
	for i = 1, 6 do
		local ph = self.ph_list["ph_cell_"..i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x,ph.y)
		self.node_t_list.layout_supervalue_charge.node:addChild(cell:GetView(), 999)
		table.insert(self.cell_list,cell)
	end
	self.node_t_list.btn_get_charge.node:addClickEventListener(BindTool.Bind(self.OnClickGoChargeHandler, self))
end

function SupervalueChargeView:CreateSupervaleChargeList()
	if nil == self.supervalue_charge_list then
		local ph = self.ph_list.ph_supervalue_charge_list
		self.supervalue_charge_list = GridScroll.New()
		self.supervalue_charge_list:Create(ph.x, ph.y, ph.w, ph.h, 1, 158, SupervalueChargeRender, ScrollDir.Vertical, false, self.ph_list.ph_supervalue_charge)
		self.node_t_list.layout_supervalue_charge.node:addChild(self.supervalue_charge_list:GetView(), 100)
	end	
end


function SupervalueChargeView:RefreshView(param_list)
	local data = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CZLC)
	if data and data.config then 
		local cfg = data.config
		local info_data73 = ActivityBrilliantData.Instance:GetChaozhiInfo()
		local data_list = {}

		local list =  bit:d2b(info_data73.everyday_sign)
		local data_sign = {}
		for i = 1, #list do
			data_sign[i] = list[#list - i + 1]
		end
		for k, v in ipairs(cfg.everyday) do
			local data = {}
			data.index = 1
			data.cur_index = k
			data.sign = data_sign[k]
			data.paymoney = v.paymoney
			data.charge = info_data73.cur_day_charge
			data.award = v.award
			data.state = 0 
			if info_data73.cur_day_charge < v.paymoney then --未达标
				data.state = 2
			else
				if data_sign[k] == 0 then --未领取
					data.state = 3
				else
					data.state = 0
				end
			end
			table.insert(data_list, data)
		end
		if #data_list >= 2 then
			local function sort_list()	--可领取在上面,已领取在最后,未完成在中间
				return function(c, d)
					if c.state ~= d.state then
						return c.state > d.state
					end
					return c.cur_index < d.cur_index
				end
			end
			table.sort(data_list,sort_list())
		end
		--PrintTable(data_list)
		-- if list.everyday_grade then 
		-- 	local data = {}
		-- 	data.index = 1
		-- 	data.grade = list.everyday_grade
		-- 	data.charge = list.cur_day_charge
		-- 	data.sign = list.everyday_sign
		-- 	data.paymoney = cfg.everyday[list.everyday_grade].paymoney
		-- 	data.award = cfg.everyday[list.everyday_grade].award
		-- 	--end
		-- 	table.insert(data_list, data)
		-- end
		-- if list.cumulative_charge then 
		-- 	local data = {}
		-- 	data.index = 2
		-- 	data.grade = list.cumulative_grade
		-- 	data.charge = list.cumulative_charge
		-- 	data.sign = list.cumulative_sign
		-- 	if cfg.everyday and cfg.manyday[list.cumulative_grade] then
		-- 		data.paymoney = cfg.manyday[list.cumulative_grade].paymoney
		-- 		data.award = cfg.manyday[list.cumulative_grade].award
		-- 	end
		-- 	table.insert(data_list, data)
		-- end
		self.supervalue_charge_list:SetDataList(data_list)

		--累积充值
		local list2 =  bit:d2b(info_data73.cumulative_sign)

		local leiji_data = {}
		for i = 1, #list2 do
			leiji_data[i] = list2[#list2 - i + 1]
		end

		local many_reward = {}
		local manyday_paymoney = 0
		local grade = 0
		for k, v in ipairs(cfg.manyday) do
			if leiji_data[k] == 0 then
				manyday_paymoney = v.paymoney
				many_reward = v.award
				grade = k
				break
			end
		end

		if manyday_paymoney == 0 then
			many_reward = cfg.manyday[#cfg.manyday].award
			manyday_paymoney = cfg.manyday[#cfg.manyday].paymoney
			grade = #cfg.manyday
		end
		for k,v in pairs(self.cell_list) do
			v:GetView():setVisible(false)
		end

		for k, v in pairs(many_reward) do
			local cell = self.cell_list[k]
			if cell then
				cell:SetVisible(true)
				cell:SetData({item_id = v.id, num = v.count, is_bind = v.bind or 0})
			end
		end
		local str = string.format(Language.ActivityBrilliant.HasChargeFormat, info_data73.cumulative_charge >= manyday_paymoney and COLORSTR.GREEN or COLORSTR.RED,  info_data73.cumulative_charge, manyday_paymoney)
	    RichTextUtil.ParseRichText(self.node_t_list.rich_charge_money.node, str, 20)
	    XUI.RichTextSetCenter(self.node_t_list.rich_charge_money.node)
	    --self.node_t_list.rich_charge_money.node:setHorizontalAlignment(RichHAlignment.HA_RIGHT)

	    if info_data73.cumulative_charge >= manyday_paymoney then
			if leiji_data[grade] == 1 then 
				--self.node_t_list.btn_get_charge.node:setVisible(false)
				self.node_t_list.btn_get_charge.node:setEnabled(false)
				self.node_t_list.btn_get_charge.node:setTitleText("已领取")
				--self.node_t_list.img_stamp.node:setVisible(true)
			else
				self.node_t_list.btn_get_charge.node:setEnabled(true)
				self.node_t_list.btn_get_charge.node:setTitleText(Language.Common.LingQu)
			end
		else
			self.node_t_list.btn_get_charge.node:setEnabled(true)
			self.node_t_list.btn_get_charge.node:setTitleText(Language.Common.Recharge)
		end
	end
end

function SupervalueChargeView:OnClickGoChargeHandler()

	local data = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CZLC)
	if data and data.config then 
		local cfg = data.config
		local info_data73 = ActivityBrilliantData.Instance:GetChaozhiInfo()
			--累积充值
		local list2 =  bit:d2b(info_data73.cumulative_sign)

		local leiji_data = {}
		for i = 1, #list2 do
			leiji_data[i] = list2[#list2 - i + 1]
		end
		local index = 0
		local paymoney = 0
		for k, v in ipairs(cfg.manyday) do
			if leiji_data[k] == 0 then
				index = k
				paymoney = v.paymoney
				break
			end
		end
		if info_data73.cumulative_charge >= paymoney then
			ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.CZLC, 2, index)
		else
			ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
			ActivityBrilliantCtrl.Instance:CloseView(self.act_id)
		end
	end
end