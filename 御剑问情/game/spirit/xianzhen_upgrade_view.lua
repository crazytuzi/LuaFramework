XianZhenUpGradeView = XianZhenUpGradeView or BaseClass(BaseRender)

function XianZhenUpGradeView:__init(instance)
	self.lingzhen_lv = self:FindObj("lingzhen_lv"):GetComponent(typeof(UnityEngine.UI.Text))
	--self.exp_slider = self:FindObj("exp_slider"):GetComponent(typeof(UnityEngine.UI.Slider))
	-- self.cur_spiritvalue_rate = self:FindObj("cur_spiritvalue_rate")
	-- self.cur_lingzhen_rate = self:FindObj("cur_lingzhen_rate"):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.cur_addlife = self:FindObj("cur_addlife"):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.next_spiritvalue_rate = self:FindObj("next_spiritvalue_rate"):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.next_lingzhen_rate = self:FindObj("next_lingzhen_rate"):GetComponent(typeof(UnityEngine.UI.Text))
	--self.star_linext_addlifest = self:FindObj("next_addlife"):GetComponent(typeof(UnityEngine.UI.Text))
	self.star_list = self:FindObj("star_list")
	self.fly_word_pos = self:FindObj("fly_word_pos")
	self.zhentuPos = self:FindObj("zhentuPos")
	self.baoji_lizi = self:FindObj("baoji_lizi"):GetComponent(typeof(UnityEngine.ParticleSystem))
	self.auto_buy_toggle = self:FindObj("AutoBuyToggle")
    
	self.image_star_list = {}
	for i=1,4 do
		self.image_star_list[i] = self:FindVariable("image_star_" .. i)
	end

	self.cost_item_text = self:FindVariable("text_cost")
	self.cur_lingzhen_rate = self:FindVariable("cur_lingzhen_rate")
	self.cur_addlife = self:FindVariable("cur_addlife")
	self.next_lingzhen_rate = self:FindVariable("next_lingzhen_rate")
	self.next_addlife = self:FindVariable("next_addlife")
	self.exp_rate = self:FindVariable("exp_rate")
	self.is_maxlevel = self:FindVariable("is_maxlevel")
	self.slider_value = self:FindVariable("slider_value")
	self.is_play_baoji_effet = self:FindVariable("is_play_baoji_effet")
	self.text_zhenfa_name = self:FindVariable("text_zhenfa_name")
	self.is_show_auto_buy = self:FindVariable("is_show_auto_buy")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("itemcell"))
	self:ListenEvent("OnClickUpGarde", BindTool.Bind(self.OnClickUpGarde, self))
	self:ListenEvent("OnAutoBuyClick", BindTool.Bind(self.OnAutoBuyClick, self)) 
	local item_id = SpiritData.Instance:GetSpiritOtherCfg().xianzhen_stuff_id or 0
	local item_num = ItemData.Instance:GetItemNumInBagById(item_id)
	self.have_num = item_num

	self.is_auto_buy = false
	self.exp = nil
	self.assetRes = 0
	self.is_click = false
end

function XianZhenUpGradeView:__delete()
	self.exp = nil
	self.star_list = nil
	self.fly_word_pos = nil
	self.lingzhen_lv = nil
	self.exp_slider = nil
	self.is_play_baoji_effet = nil
	-- self.zhentuPos = nil
	self.is_show_auto_buy = nil
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function XianZhenUpGradeView:OnFlush()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local zhenfa_level = spirit_info.xianzhen_level
	local zhenfa_exp = spirit_info.xianzhen_exp
	local xianzhen_up_count = spirit_info.xianzhen_up_count
	local cur_zhenfa_cfg = SpiritData.Instance:GetZhenfaCfgByLevel(zhenfa_level)
	
	if nil == cur_zhenfa_cfg then 
		print_error("cur_zhenfa_cfg is nil !!!")
		return
	end
	local zhenfa_effect_res = cur_zhenfa_cfg.effect
	self:SetZhenFaLevelEffect(zhenfa_effect_res)
	if zhenfa_level == SpiritData.Instance:GetZhenfaMaxLevel() then
		self.lingzhen_lv.text = "LV." .. zhenfa_level
		self.is_maxlevel:SetValue(true)
	end

	self.is_show_auto_buy:SetValue(not (zhenfa_level == SpiritData.Instance:GetZhenfaMaxLevel()))

	local zhenfa_max_hp = cur_zhenfa_cfg.maxhp
	local common_rate = cur_zhenfa_cfg.convert_rate

	local next_zhenfa_cfg = SpiritData.Instance:GetZhenfaCfgByLevel(zhenfa_level + 1)
	if nil == next_zhenfa_cfg then
		next_zhenfa_cfg = cur_zhenfa_cfg
	end
	local leveup_need_exp = cur_zhenfa_cfg.need_exp
	self.lingzhen_lv.text = "LV." .. zhenfa_level
	if nil == self.exp then
		self.exp = zhenfa_exp
	else
		if zhenfa_exp > self.exp then
			if zhenfa_exp - self.exp > 10 * cur_zhenfa_cfg.stuff_num then
				local value = zhenfa_exp - self.exp
				self:ShowFlyText(self.fly_word_pos,value,true)
				self.is_play_baoji_effet:SetValue(true)
				self.baoji_lizi:Play()
			else
				local value = zhenfa_exp - self.exp
				self:ShowFlyText(self.fly_word_pos,value,false)
			end
		else
			local value = self.exp - zhenfa_exp
			if self.is_click and value ~= 0 then
				self:ShowFlyText(self.fly_word_pos,value,false)
			end
		end

		self.exp = zhenfa_exp
	end

	--self.exp_slider.value = zhenfa_exp / leveup_need_exp
	self.slider_value:SetValue(zhenfa_exp / leveup_need_exp)
	self.exp_rate:SetValue(zhenfa_exp .. "/" .. leveup_need_exp)

	-- local activate_bundle, activate_asset = ResPath.GetSpiritIcon("full_star")
	-- local gray_bundle, gray_asset = ResPath.GetSpiritIcon("full_star")
	
	for i,v in ipairs(self.image_star_list) do
		if zhenfa_level == SpiritData.Instance:GetZhenfaMaxLevel() then
			v:SetValue(false)
		else
			if i <= xianzhen_up_count then
				v:SetValue(true)
			else
				v:SetValue(false)
			end
		end

	end
	self.cur_lingzhen_rate:SetValue(common_rate / 100 .. "%")
	self.cur_addlife:SetValue(zhenfa_max_hp)
	self.next_lingzhen_rate:SetValue(next_zhenfa_cfg.convert_rate / 100 .. "%")
	self.next_addlife:SetValue(next_zhenfa_cfg.maxhp)

	local item_id = SpiritData.Instance:GetSpiritOtherCfg().xianzhen_stuff_id or 0
	local item_cfg = ItemData.Instance:GetItemConfig(item_id) or {}
	local item_num = ItemData.Instance:GetItemNumInBagById(item_id)

	local data = {item_id = item_cfg.id, num = 0}
	self.item_cell:SetData(data)
	--local item_num = ItemData.Instance:GetItemNumInBagById(item_id)
	if self.have_num >= cur_zhenfa_cfg.stuff_num then
	 	local str = string.format(Language.JingLing.ZhenFaCostDesc, "", self.have_num,cur_zhenfa_cfg.stuff_num)
	 	self.cost_item_text:SetValue(str)
	else
	 	local str = string.format(Language.JingLing.ZhenFaLessCostDesc,  "", self.have_num,cur_zhenfa_cfg.stuff_num)
	 	self.cost_item_text:SetValue(str)
	end
	
	self.auto_buy_toggle.toggle.isOn = self.is_auto_buy
	local name_color = ITEM_COLOR[cur_zhenfa_cfg.xianzhen_color or 0] or TEXT_COLOR.WHITE
	local xianzhen_name = ToColorStr(cur_zhenfa_cfg.xianzhen_name, name_color)
	self.text_zhenfa_name:SetValue(xianzhen_name)
end

function XianZhenUpGradeView:OnClickUpGarde()
	self.is_click = true
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local zhenfa_level = spirit_info.xianzhen_level
	local cur_zhenfa_cfg = SpiritData.Instance:GetZhenfaCfgByLevel(zhenfa_level)
	local item_id = SpiritData.Instance:GetSpiritOtherCfg().xianzhen_stuff_id or 0
	local item_num = ItemData.Instance:GetItemNumInBagById(item_id)
	if item_num >= cur_zhenfa_cfg.stuff_num then
		self.have_num = self.have_num - cur_zhenfa_cfg.stuff_num
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVEL_XIANZHEN, 0)
	else
		if self.is_auto_buy then
			self.have_num = 0
			SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVEL_XIANZHEN, 1)
		else
		    --打开购买物品界面
			local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
				self.is_auto_buy = is_buy_quick
				self.have_num = self.have_num + item_num
				self:Flush()
			end
			local nofunc = function()
			end
		    TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nofunc, 1)
		end
	end
end

function XianZhenUpGradeView:OnAutoBuyClick(is_auto_buy)
	self.is_auto_buy = is_auto_buy
end

function XianZhenUpGradeView:ShowFlyText(begin_obj, value,isbaoji)
	GameObjectPool.Instance:SpawnAsset("uis/views/spiritview_prefab", "exp_up_fly_word", function(obj)
			local variable_table = obj:GetComponent(typeof(UIVariableTable))
			local text = variable_table:FindVariable("fly_word")
			local Text = obj:GetComponent(typeof(UnityEngine.UI.Text))
			if isbaoji and variable_table then
				Text.fontSize = 26
				local str = string.format(Language.JingLing.ZhenFaBaojiFlyWord,value)
				text:SetValue(str) 
			else
				Text.fontSize = 24
				local str = string.format(Language.JingLing.ZhenFaFlyWord,value)
				text:SetValue(str)
			end
			obj.transform:SetParent(begin_obj.transform, false)
			local tween = obj.transform:DOLocalMoveY(80, 0.5)
			tween:SetEase(DG.Tweening.Ease.Linear)
			tween:OnComplete(BindTool.Bind(self.OnMoveEnd, self, obj))
		end)
end

function XianZhenUpGradeView:OnMoveEnd(obj)
	if not IsNil(obj) then
		GameObject.Destroy(obj)
	end
end

function XianZhenUpGradeView:SetZhenFaLevelEffect(assetRes)
	if self.assetRes ~= assetRes then
		local bundle, asset = ResPath.GetZhenfaEffect(assetRes)
		self.assetRes = assetRes
		PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
			if prefab then
				if self.zhenfa_effect_obj  ~= nil then
					GameObject.Destroy(self.zhenfa_effect_obj)
					self.zhenfa_effect_obj = nil
				end
				local obj = GameObject.Instantiate(prefab)
				local transform = obj.transform
				transform:SetParent(self.zhentuPos.transform, false)
				self.zhenfa_effect_obj = obj.gameObject
				PrefabPool.Instance:Free(prefab)
			end
		end)
	end
end

function XianZhenUpGradeView:CloseCallBack()
	self.is_auto_buy = false
	self.is_click = false
end
