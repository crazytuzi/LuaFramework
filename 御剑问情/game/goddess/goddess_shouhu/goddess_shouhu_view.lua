GoddessShouHuView = GoddessShouHuView or BaseClass(BaseRender)

function GoddessShouHuView:__init(instance)
	GoddessShouHuView.Instance = self
	self:ListenEvent("StartAdvance",
		BindTool.Bind(self.OnStartAdvance, self))
	self:ListenEvent("AutomaticAdvance",
		BindTool.Bind(self.OnAutomaticAdvance, self))
	self:ListenEvent("OnClickUse",
		BindTool.Bind(self.OnClickUse, self))
	self:ListenEvent("OnClickLastButton",
		BindTool.Bind(self.OnClickLastButton, self))
	self:ListenEvent("OnClickNextButton",
		BindTool.Bind(self.OnClickNextButton, self))

	self.shouhu_name = self:FindVariable("Name")
	self.shouhu_rank = self:FindVariable("Rank")
	self.shouhu_level = self:FindVariable("Level")
	self.exp_radio = self:FindVariable("ExpRadio")
	self.sheng_ming = self:FindVariable("HPValue")
	self.fight_power = self:FindVariable("FightPower")
	self.gong_ji = self:FindVariable("GongJi")
	self.fang_yu = self:FindVariable("FangYu")
	self.ming_zhong = self:FindVariable("MingZhong")
	self.shan_bi = self:FindVariable("ShanBi")
	self.bao_ji = self:FindVariable("BaoJi")
	self.jian_ren = self:FindVariable("JianRen")
	self.jia_shang = self:FindVariable("JiaShang")
	self.jian_shang = self:FindVariable("JianShang")
	self.quality = self:FindVariable("QualityBG")
	self.auto_btn_text = self:FindVariable("AutoButtonText")
	self.use_button = self:FindVariable("UseButton")
	self.use_image_sprite = self:FindVariable("UseImage")
	self.last_button = self:FindVariable("LeftButton")
	self.next_button = self:FindVariable("RightButton")

	self.cur_bless = self:FindVariable("CurBless")

	self.shouhu_display = self:FindObj("ShouhuDisplay")
	self.auto_buy_toggle = self:FindObj("AutoToggle")
	self.start_button = self:FindObj("StartButton")
	self.auto_button = self:FindObj("AutoButton")
	self.gray_use_button = self:FindObj("GrayUseButton")

	local toggle_group = self:FindObj("ItemGroup").toggle_group
	local item1 = ItemCell.New()
	item1:SetToggleGroup(toggle_group)
	item1:SetInstanceParent(self:FindObj("Item1"))
	local item2 = ItemCell.New()
	item2:SetInstanceParent(self:FindObj("Item2"))
	item2:SetToggleGroup(toggle_group)
	local item3 = ItemCell.New()
	item3:SetInstanceParent(self:FindObj("Item3"))
	item3:SetToggleGroup(toggle_group)
	self.item_cells = {item1, item2, item3}

	for k,v in pairs(self.item_cells) do
		local handler = function()
			local close_call_back = function()
				v:SetToggle(false)
			end
			v:SetHighLight(true)
			TipsCtrl.Instance:OpenItem(v:GetData(), nil, nil, close_call_back)
			self.select_item_info = v:GetData()
		end
		v:ListenClick(handler)
	end
	self.star_lists = {}
	for i = 1, 10 do
		self.star_lists[i] = self:FindObj("Star"..i)
	end

	self.is_can_auto = true
	local goddess_shouhu_data = GoddessShouhuData.Instance
	local data_list = goddess_shouhu_data:GetUpStartMat()
	for k,v in pairs(self.item_cells) do
		if data_list[k].num == 0 then
			v:SetIconGrayVisible(true)
		end
		v:SetData(data_list[k])
	end
	self.item_cells[1]:SetHighLight(true)
	self.select_item_info = self.item_cells[1]:GetData()
	self.cur_grade = goddess_shouhu_data:GetShouHuInfo().grade
	self:FlushView()
end

function GoddessShouHuView:OpenCallBack()
	self.auto_jinjie = false
	self.auto_btn_text:SetValue("自动进阶")
	self.start_button.grayscale.GrayScale = 0
	self.start_button.button.interactable = true
	self:SetModle()
	self:FlushButton()
end

function GoddessShouHuView:__delete()
	if self.shouhu_model ~= nil then
		self.shouhu_model:DeleteMe()
		self.shouhu_model = nil
	end

	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}

	self:RemoveTimerQuest()
end

function GoddessShouHuView:FlushView()
	local shouhu_data = GoddessShouhuData.Instance
	local show_info = shouhu_data:GetShowHuShowValue(self.cur_grade)
	self.shouhu_name:SetValue(show_info.image_name)
	self.shouhu_rank:SetValue(show_info.grade_name)
	self.sheng_ming:SetValue(show_info.star_exp_info.maxhp)
	self.gong_ji:SetValue(show_info.star_exp_info.gongji)
	self.fang_yu:SetValue(show_info.star_exp_info.fangyu)
	self.ming_zhong:SetValue(show_info.star_exp_info.mingzhong)
	self.shan_bi:SetValue(show_info.star_exp_info.shanbi)
	self.bao_ji:SetValue(show_info.star_exp_info.baoji)
	self.jian_ren:SetValue(show_info.star_exp_info.jianren)
	self.shouhu_level:SetValue(show_info.shou_hu_level)
	-- self.jia_shang:SetValue(show_info.star_exp_info.)
	-- self.jian_shang:SetValue(show_info.star_exp_info.)
	self.exp_radio:SetValue(show_info.grade_bless_val/show_info.fix_exp)
	self.cur_bless:SetValue(show_info.grade_bless_val .. "/" .. show_info.fix_exp)
	for i=1,10 do
		if i <= (show_info.shou_hu_level%10) then
			self.star_lists[i].grayscale.GrayScale = 0
		else
			self.star_lists[i].grayscale.GrayScale = 255
		end
	end
	if show_info.used_change then
		self.cur_grade = shouhu_data:GetShouHuInfo().grade
		self:SetModle()
		TipsCtrl.Instance:ShowOpenFunctionView(OPEN_FUNCTION_TYPE.GODDESS_HALO)
	end
	self:FlushUseState()
	self:FlushButton()
	self:FlushItemNum()
end

function GoddessShouHuView:FlushItemNum()
	for k,v in pairs(self.item_cells) do
		local num = ItemData.Instance:GetItemNumInBagById(v:GetData().id)
		v:SetNum(num)
		if num == 0 then
			v:SetIconGrayVisible(true)
		else
			v:SetIconGrayVisible(false)
		end
	end
end

function GoddessShouHuView:SetModle()
	if self.shouhu_model == nil then
		self.shouhu_model = RoleModel.New()
		self.shouhu_model:SetDisplay(self.shouhu_display.ui3d_display)
	end
	local res_id = 0
	if self.cur_grade > 1 then
		res_id = HaloData.Instance:GetHaloImageCfg()[self.cur_grade].res_id
	end
	self.shouhu_model:SetMainAsset(ResPath.GetHaloModel(res_id))
	self.shouhu_display.ui3d_display:ResetRotation()
end

function GoddessShouHuView:CheckCanAdvance()
	if ItemData.Instance:GetItemNumInBagById(self.select_item_info.id) <= 0 then
		if ShopData.Instance:CheckIsInShop(self.select_item_info.id) then
			local func = function(item_id, item_num, is_bind, is_use)
				MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, self.select_item_info.id, nil, 1)
			return false
		else
			TipsCtrl.Instance:ShowItemGetWayView(self.select_item_info.id)
			return false
		end
	end
	return true
end

function GoddessShouHuView:OnStartAdvance()
	if not self:CheckCanAdvance() then return end
	local shouhu_data = GoddessShouhuData.Instance
	GoddessShouhuCtrl.Instance:SendXiannvShouhuUpStarLevel(shouhu_data:GetMatInfo(self.select_item_info.id).up_star_item_index, 0)
end

function GoddessShouHuView:OnAutomaticAdvance()
	if self.auto_jinjie then
		self.auto_jinjie = false
		self.auto_btn_text:SetValue("自动进阶")
		self.start_button.grayscale.GrayScale = 0
		self.start_button.button.interactable = true
	else
		if not self:CheckCanAdvance() then return end
		self.auto_jinjie = true
		self.auto_btn_text:SetValue("停止进阶")
		self.start_button.grayscale.GrayScale = 255
		self.start_button.button.interactable = false
	end
	if self.upgrade_timer_quest == nil then
		GoddessShouhuCtrl.Instance:SendXiannvShouhuUpStarLevel(GoddessShouhuData.Instance:GetMatInfo(self.select_item_info.id).up_star_item_index, 0)
	end
end

function GoddessShouHuView:AutoUpGradeOnce()
	if self.auto_jinjie then
		local shouhu_data = GoddessShouhuData.Instance
		local timer_cal = shouhu_data:GetShouHuGradeCfg(shouhu_data:GetShouHuInfo().grade).next_time or 0.1
		self:RemoveTimerQuest()
		self.upgrade_timer_quest = GlobalTimerQuest:AddRunQuest(function()
			timer_cal = timer_cal - UnityEngine.Time.deltaTime
			if timer_cal <= 0 then
				self:OnStartAdvance()
				GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
				self.upgrade_timer_quest = nil
			end
		end, 0)
	end
end

function GoddessShouHuView:RemoveTimerQuest()
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function GoddessShouHuView:ReSetAutoState()
	self.auto_jinjie = false
	self.auto_btn_text:SetValue("自动进阶")
	self.start_button.grayscale.GrayScale = 0
	self.start_button.button.interactable = true
end

function GoddessShouHuView:OnClickUse()
	GoddessShouhuCtrl.Instance:SendUseXiannvShouhuImage(GoddessShouhuData.Instance:GetImageByGrade(self.cur_grade))
end

function GoddessShouHuView:OnClickLastButton()
	self.cur_grade = self.cur_grade - 1
	self:AfterClickButton()
end

function GoddessShouHuView:OnClickNextButton()
	self.cur_grade = self.cur_grade + 1
	self:AfterClickButton()
end

function GoddessShouHuView:AfterClickButton()
	self:FlushButton()
	local goddess_shouhu_data = GoddessShouhuData.Instance
	local shouhu_grade_cfg = goddess_shouhu_data:GetShouHuGradeCfg(self.cur_grade)
	self.shouhu_rank:SetValue(shouhu_grade_cfg.gradename)
	self.shouhu_name:SetValue(goddess_shouhu_data:GetShouHuImageCfg(shouhu_grade_cfg.image_id).image_name)
	self:SetModle()
	self:FlushUseState()
end

function GoddessShouHuView:FlushUseState()
	local goddess_shouhu_data = GoddessShouhuData.Instance
	local is_use_grade = GoddessShouhuData.Instance:GetIsUseGrade(self.cur_grade)
	local grade = goddess_shouhu_data:GetShouHuInfo().grade
	self.use_button:SetValue(not is_use_grade and self.cur_grade ~= 1 and self.cur_grade <= goddess_shouhu_data:GetShouHuInfo().grade)
	self.use_image_sprite:SetValue(is_use_grade and self.cur_grade ~= 1)
end

function GoddessShouHuView:FlushButton()
	if self.cur_grade - 1 < 1 then
		self.last_button:SetValue(false)
	else
		self.last_button:SetValue(true)
	end
	local show_info = GoddessShouhuData.Instance:GetShouHuInfo()
	if self.cur_grade + 1 > show_info.grade + 1 then
		self.next_button:SetValue(false)
	else
		self.next_button:SetValue(true)
	end
end

function GoddessShouHuView:GetAutoJinJieState()
	return self.auto_jinjie
end

--物品不足进阶失败时
function GoddessShouHuView:AutoJInjieFail()
	self.auto_jinjie = false
	self.auto_btn_text:SetValue("自动进阶")
	self.start_button.grayscale.GrayScale = 0
	self.start_button.button.interactable = true
	if self.upgrade_timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function GoddessShouHuView:GetSelectItemId()
	return self.select_item_info.id
end
