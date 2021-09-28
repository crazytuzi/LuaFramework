HpBagView = HpBagView or BaseClass(BaseView)
function HpBagView:__init()
	self.ui_config = {"uis/views/hpbagview_prefab","HpBagView"}
	self.play_audio = true
end

function HpBagView:__delete()
end

function HpBagView:ReleaseCallBack()
	-- if self.item_cell01 then
	-- 	self.item_cell01:DeleteMe()
	-- end

	-- if self.item_cell02 then
	-- 	self.item_cell02:DeleteMe()
	-- end

	-- 清理变量和对象
	self.slider_value = nil
	self.cur_all_hp = nil
	self.hp_bag_name01 = nil
	self.hp_bag_value01 = nil
	self.hp_bag_gold01 = nil
	self.hp_bag_name02 = nil
	self.hp_bag_value02 = nil
	self.hp_bag_gold02 = nil
	self.hp_pro_text = nil
	self.tips = nil
	self.raw_image = nil
end

function HpBagView:LoadCallBack()

	self.slider_value = self:FindVariable("slider_value")
	self.cur_all_hp = self:FindVariable("cur_all_hp")
	self.hp_bag_name01 = self:FindVariable("hp_bag_name01")
	self.hp_bag_value01 = self:FindVariable("hp_bag_value01")
	self.hp_bag_gold01 = self:FindVariable("hp_bag_gold01")
	self.hp_bag_name02 = self:FindVariable("hp_bag_name02")
	self.hp_bag_value02 = self:FindVariable("hp_bag_value02")
	self.hp_bag_gold02 = self:FindVariable("hp_bag_gold02")
	self.hp_pro_text = self:FindVariable("hp_pro_text")
	self.tips = self:FindVariable("tips")

	self.raw_image = self:FindObj("RawImage").raw_image
	-- self.item_cell01 = ItemCell.New(self:FindObj("ItemCell01"))
	-- self.item_cell02 = ItemCell.New(self:FindObj("ItemCell02"))

	self:ListenEvent("Closen",BindTool.Bind(self.OnClosen,self))
	self:ListenEvent("on_slider_change", BindTool.Bind(self.SliderOnChange,self))
	self:ListenEvent("buy_click01",BindTool.Bind(self.OnBuyClick01,self))
	self:ListenEvent("buy_click02",BindTool.Bind(self.OnBuyClick02,self))
end

function HpBagView:OnBuyClick01()
	local fun = function ()
		HpBagCtrl.Instance:SendSupplyBuyItem(self.data[1].supply_type,self.data[1].supply_index,self.data[1].is_use_gold)
	end
 	TipsCtrl.Instance:ShowCommonTip(fun, nil, Language.Common.QuickBuyTip, nil, nil, true, false, "buy_hp_one")
end

function HpBagView:OnBuyClick02()
	local fun = function ()
		HpBagCtrl.Instance:SendSupplyBuyItem(self.data[2].supply_type,self.data[2].supply_index,self.data[2].is_use_gold)
	end
 	TipsCtrl.Instance:ShowCommonTip(fun, nil, Language.Common.QuickBuyTip, nil, nil, true, false, "buy_hp_two")
end

function HpBagView:SliderOnChange(value)
	if self.cur_percent == value then
		return
	end
	self.slider_value:SetValue(value)
	self.cur_percent = value
	self:FlushSliderData(self.cur_percent)
end

function HpBagView:OnFlush()
	self:FlushData()
end

function HpBagView:OnClosen()
	self:Close()
end

function HpBagView:CloseCallBack()
	if self.cur_percent == HpBagData.Instance:GetSupplySeverData().supply_range_per then
		return
	end

	local level = GameVoManager.Instance:GetMainRoleVo().level
	local supply_type = HpBagData.Instance:GetRecoverHpByLevel(level).supply_type
	HpBagCtrl.Instance:SendSupplySetRecoverRangePer(supply_type,self.cur_percent)
end

function HpBagView:OpenCallBack()
	self.cur_percent = HpBagData.Instance:GetSupplySeverData().supply_range_per
	self.slider_value:SetValue(self.cur_percent)
	self:FlushData()
end

function HpBagView:FlushData()
	self.data = HpBagData.Instance:GetSupplyData()
	local supply_left_value = HpBagData.Instance:GetSupplySeverData().supply_left_value or 0
	if supply_left_value > 0 then
		supply_left_value = CommonDataManager.ConverNum(supply_left_value)
		supply_left_value = supply_left_value
	end
	self.cur_all_hp:SetValue(supply_left_value)
	self.hp_bag_name01:SetValue(self.data[1].supply_item_name)
	self.hp_bag_value01:SetValue(string.format(HpBagData:HpNumberChangeCallback(self.data[1].supply_value)))
	self.hp_bag_gold01:SetValue(self.data[1].price)
	-- data01 = {item_id = 22901, num = 1, is_bind = 0}
	-- self.item_cell01:SetData(data01)

	self.hp_bag_name02:SetValue(self.data[2].supply_item_name)
	self.hp_bag_value02:SetValue(string.format(HpBagData:HpNumberChangeCallback(self.data[2].supply_value)))
	self.hp_bag_gold02:SetValue(self.data[2].price)
	-- data02 = {item_id = 22902, num = 1, is_bind = 0}
	-- self.item_cell02:SetData(data02)

	self:FlushSliderData(self.cur_percent)
end

function HpBagView:FlushSliderData(value)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local add_percent = HpBagData.Instance:GetPercent() / 10000
	local cur_addhp = math.ceil(main_role_vo.base_max_hp * add_percent)
	self.tips:SetValue(string.format(Language.Common.HpBag, value, cur_addhp))
	self.hp_pro_text:SetValue(string.format(Language.Common.HpBagText, value))
end