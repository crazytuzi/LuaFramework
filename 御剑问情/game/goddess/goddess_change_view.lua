--------------------------------------------------------------------------
--GoddessChangeView 	女神阵营面板
--------------------------------------------------------------------------
GoddessChangeView = GoddessChangeView or BaseClass(BaseRender)
function GoddessChangeView:__init(instance)
	if instance == nil then
		return
	end
	self:InitView()
end

function GoddessChangeView:InitView()
	self.attribute_content = self:FindObj("attribute_content")
	ChangeRightView.New(self.attribute_content)
end


--------------------------------------------------------------------------
--ChangeRightView 	右面板
--------------------------------------------------------------------------
ChangeRightView = ChangeRightView or BaseClass(BaseRender)
function ChangeRightView:__init(instance)
	if instance == nil then
		return
	end
	ChangeRightView.Instance = self
	self:InitView()
end

function ChangeRightView:InitView()
	self:ListenEvent("activate_btn",BindTool.Bind(self.ActiveBtnOnClick, self))
	self.power_value = self:FindVariable("power_value")
	self.attack_value = self:FindVariable("attack_value")
	self.defense_value = self:FindVariable("defense_value")
	self.hp_value = self:FindVariable("hp_value")
	self.rate_value = self:FindVariable("rate_value")
	self.obligate_value = self:FindVariable("obligate_value")
	self.damage_value = self:FindVariable("damage_value")
	self.need_mat_label = self:FindVariable("need_mat_label")
	self.need_mat_value = self:FindVariable("need_mat_value")
	self.have_mat_value = self:FindVariable("have_mat_value")
end

function ChangeRightView:ActiveBtnOnClick()
	print("点击激活按钮")
end

