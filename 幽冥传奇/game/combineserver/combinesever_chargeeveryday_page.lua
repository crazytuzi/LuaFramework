CombineServerChargeEveryDayPage = CombineServerChargeEveryDayPage or BaseClass()


function CombineServerChargeEveryDayPage:__init()
	
end	

function CombineServerChargeEveryDayPage:__delete()
	if self.reward_cell ~= nil then
		for k,v in pairs(self.reward_cell) do
			v:DeleteMe()
		end
		self.reward_cell = {}
	end
	self:RemoveEvent()
end	

--初始化页面接口
function CombineServerChargeEveryDayPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.reward_cell = {}
	self:CreateCells()
	self:InitEvent()
end	

--初始化事件
function CombineServerChargeEveryDayPage:InitEvent()
	XUI.AddClickEventListener(self.view.node_t_list["btn_charge"].node, BindTool.Bind1(self.OpenChargeView, self), true)
	self.number_rade = self:CreateNumber(210, 320, 33, 45)
	self.view.node_t_list["layout_charge_everyday"].node:addChild(self.number_rade:GetView(), 200)
end

--移除事件
function CombineServerChargeEveryDayPage:RemoveEvent()
end

--更新视图界面
function CombineServerChargeEveryDayPage:UpdateData(data)
	local cur_data = CombineServerData.Instance:GetChargeEveryDataConfig() or {}
	local data = cur_data.awards or {}
	for k, v in pairs(self.reward_cell) do
		if k <= #data then
			v:GetView():setVisible(true)
			v:SetData({item_id = data[k] and data[k].id, num = data[k] and data[k].count or 0, is_bind = data[k] and data[k].bind or 1})
		else
			v:GetView():setVisible(false)
		end
 	end
	local charge_num = CombineServerData.Instance:GetChargeNum() or 0
	self.number_rade:SetNumber((cur_data.needChargeSingle or 1))
	local path = nil 
	if CombineServerData.Instance:GetState() == 1 then
		path = ResPath.GetCommon("stamp_15")
		self.view.node_t_list["btn_charge"].node:setGrey(true)
		XUI.SetButtonEnabled(self.view.node_t_list["layout_charge_everyday"].node, false)
	else
		self.view.node_t_list["btn_charge"].node:setGrey(false)
		XUI.SetButtonEnabled(self.view.node_t_list["layout_charge_everyday"].node, true)
		if (cur_data.needChargeSingle or 1) <= charge_num then
			path = ResPath.GetCharge("bg_10") 
		else
			path = ResPath.GetCombineServer("charge_righttime")
		end
	end
	self.view.node_t_list["img_charge_bg"].node:loadTexture(path)
end	

function CombineServerChargeEveryDayPage:CreateCells()
	self.reward_cell = {}
	for i = 1, 6 do
		local ph = self.view.ph_list.ph_cell
		local cell = BaseCell.New()
		cell:SetPosition(ph.x + 90*(i-1), ph.y)
		self.view.node_t_list["layout_charge_everyday"].node:addChild(cell:GetView(), 103)
		table.insert(self.reward_cell, cell)
		self.act_eff = RenderUnit.CreateEffect(920, self.view.node_t_list["layout_charge_everyday"].node, 201, nil, nil, ph.x + 40 + 90*(i-1),  ph.y + 37)
	end	
end

function CombineServerChargeEveryDayPage:CreateNumber(x, y, w, h)
	local number_bar = NumberBar.New()
	number_bar:SetRootPath(ResPath.GetFightRoot("y_"))
	number_bar:SetPosition(x, y+5)
	number_bar:SetContentSize(w, h)
	number_bar:SetSpace(-2)
	return number_bar
end

function CombineServerChargeEveryDayPage:OpenChargeView()
	local cur_data = CombineServerData.Instance:GetChargeEveryDataConfig()
	if cur_data.needChargeSingle <= (CombineServerData.Instance:GetChargeNum() or 0) then
		CombineServerCtrl.Instance:GetChargEveryDayGift()
	else
		ViewManager.Instance:Open(ViewName.ChargePlatForm)
	end
end