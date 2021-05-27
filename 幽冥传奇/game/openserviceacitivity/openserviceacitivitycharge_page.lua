-- 开服累计充值
OpenServiceChargeAddPage = OpenServiceChargeAddPage or BaseClass()

function OpenServiceChargeAddPage:__init()
	
	
end	

function OpenServiceChargeAddPage:__delete()
	self:RemoveEvent()
	if self.charge_list_view ~= nil then
		self.charge_list_view:DeleteMe()
		self.charge_list_view = nil 
	end
end	

--初始化页面接口
function OpenServiceChargeAddPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateList()
	self:InitEvent()
end	
--初始化事件
function OpenServiceChargeAddPage:InitEvent()
	self.view.node_t_list.layout_charge_add["btn_charge"].node:addClickEventListener(BindTool.Bind(self.OpenView, self))
end

--移除事件
function OpenServiceChargeAddPage:RemoveEvent()
	
end

function OpenServiceChargeAddPage:CreateList()
	if self.charge_list_view == nil then
		local ph = self.view.ph_list.ph_item_list_5
		self.charge_list_view = ListView.New()
		self.charge_list_view:Create(ph.x, ph.y, ph.w, ph.h, direction, OpenChargeRewardAwardItem, nil, false, self.view.ph_list.ph_list_item_5)
		self.charge_list_view:SetItemsInterval(3)
		self.charge_list_view:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_charge_add.node:addChild(self.charge_list_view:GetView(), 100)
	end
end

--更新视图界面
function OpenServiceChargeAddPage:UpdateData(data)
	local data = OpenServiceAcitivityData.Instance:GetChargeRewardData()
	self.charge_list_view:SetDataList(data)
	local charge_money = OpenServiceAcitivityData.Instance:GetChargeMoney()
	local txt = string.format(Language.OpenServiceAcitivity.ChargeMoney, charge_money)
	self.view.node_t_list.layout_charge_add.txt_my_charge.node:setString(txt)
end

function OpenServiceChargeAddPage:OpenView()
	ViewManager.Instance:Open(ViewName.ChargePlatForm)
end



