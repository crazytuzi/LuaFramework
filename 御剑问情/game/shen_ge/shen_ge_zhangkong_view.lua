ShenGeZhangKongView = ShenGeZhangKongView or BaseClass(BaseRender)

local POINTER_ANGLE_LIST = {
	[3] = 55,
	[1] = 125,
	[0] = -125,
	[2] = -55
}

local ATTR_NAME = {
	["gongji_pro"] = "gong_ji",
	["fangyu_pro"] = "fang_yu",
	["maxhp_pro"] = "max_hp",
	["shanbi_pro"] = "shan_bi",
	["baoji_pro"] = "bao_ji",
	["kangbao_pro"] = "jian_ren",
	["mingzhong_pro"] = "mingzhong_pro",
}

function ShenGeZhangKongView:__init(instance)
	self.is_rolling = false
	self.in_click = false
	self.is_tence = false
	self.cur_precent = nil

	self.shenge_cell = {}
	for i = 1,4 do
		if self.shenge_cell[i] == nil then
			self.shenge_cell[i] = ShenGeZhangKongCell.New(self:FindObj("ShengeCell"..i), i)
			self.shenge_cell[i]:OnFlush()
		end
	end

	self.center_pointer = self:FindObj("CenterPointer")
	self.play_ani_toggle = self:FindObj("PlayAniToggle").toggle
	self.tence_toggle = self:FindObj("TenceToggle").toggle
	self.shoot_start_point = self:FindObj("StartPoint")
	self.zi_dan = self:FindObj("Zidan")
	self.max_text_pos = self:FindObj("MaxTextPos")
	self.auto_buy_toggle = self:FindObj("AutoToggle")
    self.auto_buy_stone = 0
	self.play_ani_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self))
	self.tence_toggle:AddValueChangedListener(BindTool.Bind(self.OnTenceToggleChange, self))

	self:ListenEvent("OnClickGo", BindTool.Bind(self.OnClickGo, self))
	self:ListenEvent("QuestionClick", BindTool.Bind(self.QuestionClick, self))

	self.cost = self:FindVariable("Cost")
	self.item_amount = self:FindVariable("daoju")
	self.is_show_zidan = self:FindVariable("IsShowZidan")
	self.item_name = self:FindVariable("ItemName")
	self:SetNotifyDataChangeCallBack()

	self:Flush()
end

function ShenGeZhangKongView:__delete()
	self.changed_data = nil
	self:RemoveNotifyDataChangeCallBack()
	for i = 1, 4 do 
		if self.shenge_cell[i] ~= nil then 
			self.shenge_cell[i]:DeleteMe()
			self.shenge_cell[i] = nil
		end
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self.cur_precent = nil
end

function ShenGeZhangKongView:OnClickGo()
	if self.is_rolling or self.in_click then
		return
	end
	self.in_click = true
	self:SetItemNum()
	local is_auto_buy_toggle = self.auto_buy_toggle.toggle.isOn
	local buy_num = 1
	if self.is_tence == true then 
		buy_num = 10
	end

    if is_auto_buy_toggle then 
    	self.auto_buy_stone = 1
    end 

	if ItemData.Instance:GetItemNumInBagById(self.item_id) < buy_num and not is_auto_buy_toggle then
		-- 物品不足，弹出TIP框
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(self.item_id)
			self:SetItemNum()
			return
		end

		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.auto_buy_toggle.toggle.isOn = true
			end
		end
		if self.is_tence == true then
			TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id, nil, buy_num - ItemData.Instance:GetItemNumInBagById(self.item_id))
		else
			TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id, nil, 1)
		end
		self:SetItemNum()
		self.is_rolling = false
		self.in_click = false
		return
	end

	if ShenGeData.Instance:IsZhangkongAllMaxLevel() then
		self:ShowMaxText()

		return
	end

	self:ResetVariable()
	-- self:ResetHighLight()
	ShenGeData.Instance:SetZhangkongAniState(self.play_ani_toggle.isOn)
	if self.is_tence ~= nil then
		if self.is_tence == false then
			ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_STYTEM_REQ_TYPE_UPLEVEL_ZHANGKONG,0,self.auto_buy_stone)
		else
			ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_STYTEM_REQ_TYPE_UPLEVEL_ZHANGKONG, 1,self.auto_buy_stone)
		end
	end
end

function ShenGeZhangKongView:OnToggleChange(is_on)
	ShenGeData.Instance:SetZhangkongAniState(is_on)
end

function ShenGeZhangKongView:SetItemNum()
	self.item_id = ShenGeData.Instance:GetZhangkongItemID()
	local item_amount_val = ItemData.Instance:GetItemNumInBagById(self.item_id)
	local item_amount_str = ""
	self.item_amount:SetValue(item_amount_val)
	if item_amount_val == 0 then
		item_amount_str = "<color='#fe3030'>" .. item_amount_val .. "</color>"
	else
		item_amount_str = "<color='#0000f1'>" .. item_amount_val .. "</color>"
	end
	self.item_amount:SetValue(item_amount_str)
	local color = ITEM_COLOR[ItemData.Instance:GetItemConfig(self.item_id).color]
	item_name_str = "<color="..color..">" .. ItemData.Instance:GetItemName(self.item_id) .. "</color>"
	self.item_name:SetValue(item_name_str)
end

function ShenGeZhangKongView:OnTenceToggleChange(is_on)
	self.is_tence = is_on
end

function ShenGeZhangKongView:DataFlush()
	local changed_data = ShenGeData.Instance:GetZhankongSingleChangeInfo()
	if changed_data ~= nil then 
		self:ResetVariable()
		-- self:ResetHighLight()
		self:SaveVariable(changed_data)
		self:TurnPointer()
	end
end

function ShenGeZhangKongView:TurnPointer()
	if self.is_rolling then
		return
	end
	local angle = POINTER_ANGLE_LIST[self.changed_data.grid]
	if self.play_ani_toggle.isOn == false then
		self.is_rolling = true
		local time = 0
		local tween = self.center_pointer.transform:DORotate(
			Vector3(0, 0, -360 * 20),
			20,
			DG.Tweening.RotateMode.FastBeyond360)
		tween:SetEase(DG.Tweening.Ease.OutQuart)
		tween:OnUpdate(function ()
			time = time + UnityEngine.Time.deltaTime
			if time >= 1 then
				tween:Pause()
				local tween1 = self.center_pointer.transform:DORotate(
						Vector3(0, 0, -360 * 3 + angle),
						2,
						DG.Tweening.RotateMode.FastBeyond360)
				tween1:OnComplete(function ()
					-- self:ShowHightLight()
					self:PlayEffect()
				end)
			end
		end)
	else 
		self.in_click = false
		self.center_pointer.transform.localRotation = Quaternion.Euler(0, 0, angle)
		-- self:ShowHightLight()
		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_STYTEM_REQ_TYPE_RECLAC_ATTR)
		self:ShowFlyText()
	end
end

function ShenGeZhangKongView:ShowLightEffect()
	ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_STYTEM_REQ_TYPE_RECLAC_ATTR)
end

function ShenGeZhangKongView:GridFlush()
	local data_list = {}
	for i = 1, 4 do
		if self.shenge_cell[i] ~= nil then
			data_list[i] = ShenGeData.Instance:GetZhangkongInfoByGrid(i - 1)
			self.shenge_cell[i]:OnSingleDataChange(data_list[i], self.play_ani_toggle.isOn)
		end
	end
end

function ShenGeZhangKongView:OnFlush(param_list)
	self:GridFlush()
	self:SetCost()
	self:SetItemNum()
end

function ShenGeZhangKongView:SetCost()
	local cost = ShenGeData.Instance:GetZhangkongCost()
	self.cost:SetValue(cost)
end

-- function ShenGeZhangKongView:ShowHightLight()
-- 	local index = self.changed_data.grid + 1

-- 	if index ~= -1 then
-- 		if self.shenge_cell[index] ~= nil then
-- 			self.shenge_cell[index]:SetShowHightLight(true)
-- 		end
-- 	end
-- end

-- function ShenGeZhangKongView:ResetHighLight()
-- 	for i = 1,4 do
-- 		if self.shenge_cell[i] ~= nil then
-- 			self.shenge_cell[i]:SetShowHightLight(false)
-- 		end
-- 	end
-- end

function ShenGeZhangKongView:SaveVariable(data)
	self.changed_data = data
end

function ShenGeZhangKongView:ResetVariable()
	if self.changed_data ~= nil then
		self.changed_data = nil
	end
end

function ShenGeZhangKongView:ShowZidan()
	self.is_show_zidan:SetValue(true)
end

function ShenGeZhangKongView:ResetZidan()
	self.is_show_zidan:SetValue(false)
	self.zi_dan.transform.position = self.shoot_start_point.transform.position
end

function ShenGeZhangKongView:PlayEffect()
	self:ShowZidan()
	local timer = 0.5

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self.time_quest = GlobalTimerQuest:AddDelayTimer(function()
		local path = {}
		local item = self.zi_dan
		table.insert(path, self.shoot_start_point.transform.position)
		table.insert(path, self.shenge_cell[self.changed_data.grid + 1]:GetCellPoint().transform.position)
		local tweener = item.transform:DOPath(
			path,
			timer,
			DG.Tweening.PathType.Linear,
			DG.Tweening.PathMode.TopDown2D,
			1,
			nil)
		tweener:SetEase(DG.Tweening.Ease.Linear)
		tweener:SetLoops(0)

		local close_view = function ()
			ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_STYTEM_REQ_TYPE_RECLAC_ATTR)
			self:ResetZidan()
			self:ShowFlyText()
			self.is_rolling = false
			self.in_click = false
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
			if self.collective_flag then
				self:Close()
			end
		end
		tweener:OnComplete(close_view)
	end, 0)
end

function ShenGeZhangKongView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		if ItemData.Instance then
			ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
			self.item_data_event = nil
		end
	end
end

function ShenGeZhangKongView:SetNotifyDataChangeCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function ShenGeZhangKongView:ItemDataChangeCallback(item_id)
	local shen_data = ShenBingData.Instance
	if item_id == ShenBingDanId.ZiZhiDanId then
		self.show_red_zizhi:SetValue(shen_data:GetShenBingZiZhiRemind())
		return
	end

	local item_id_list = {}
	for i=1,3 do
		if self.item_id ~= nil and item_id == self.item_id then
			self:Flush()
			return
		end
	end
end


function ShenGeZhangKongView:ShowFlyText()
	local begin_obj = self.shenge_cell[self.changed_data.grid + 1]:GetTextPosition()
	local value = self.changed_data.add_exp
	local isbaoji = ShenGeData.Instance:IsExpBaoji(value)
	GameObjectPool.Instance:SpawnAsset("uis/views/spiritview_prefab", "exp_up_fly_word", function(obj)
			local variable_table = obj:GetComponent(typeof(UIVariableTable))
			local text = variable_table:FindVariable("fly_word")
			local Text = obj:GetComponent(typeof(UnityEngine.UI.Text))
			if isbaoji and variable_table then
				Text.fontSize = 26
				local str = string.format(Language.ShengeZhangkong.BaoJiFlyWord,value)
				text:SetValue(str) 
			else
				Text.fontSize = 24
				local str = string.format(Language.ShengeZhangkong.FlyWord,value)
				text:SetValue(str)
			end
			obj.transform:SetParent(begin_obj.transform, false)
			local tween = obj.transform:DOLocalMoveY(80, 1)
			tween:SetEase(DG.Tweening.Ease.Linear)
			tween:OnComplete(BindTool.Bind(self.OnMoveEnd, self, obj))
		end)
end

function ShenGeZhangKongView:OnMoveEnd(obj)
	if not IsNil(obj) then
		GameObject.Destroy(obj)
	end
end


function ShenGeZhangKongView:ShowMaxText()
	SysMsgCtrl.Instance:ErrorRemind(Language.ShengeZhangkong.AllLevelMax,1)
end

function ShenGeZhangKongView:QuestionClick()
	local tips_id = 189 
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

--------------------------------------------------------
ShenGeZhangKongCell = ShenGeZhangKongCell or BaseClass(BaseCell)
function ShenGeZhangKongCell:__init(instance, index)
	self:CellInit(index)
end

function ShenGeZhangKongCell:CellInit(index)
	self.grade = self:FindVariable("ShengeRank")
	self.type = self:FindVariable("Type")
	self.shenge_pro = self:FindVariable("Increased")
	self.show_hight_light = self:FindVariable("ShowHightLight")
	self.slider_text = self:FindVariable("SliderText")
	self.name = self:FindVariable("Name")
	self.exp_text = self:FindVariable("ExpText")
	self.pro_text = self:FindVariable("ProText")
	self.is_max_level = self:FindVariable("IsMaxLevel")
	self.zhan_dou_li = self:FindVariable("ZhanDouLi")
	self.effect_start_point = self:FindObj("StartPoint")
	self.text_pos = self:FindObj("TextPos")

	self.is_show_star = {}
	self.star_position = {}
	self.star_gray ={}

	for i = 1, 5 do 
		self.is_show_star[i] = self:FindVariable("star"..i)
		self.star_position[i] = self:FindObj("Star"..i)
		self.star_gray[i] = self:FindObj("StarGray"..i)
	end

	self.grid = index - 1
end

function ShenGeZhangKongCell:__delete()
	self:RemoveSliderTween()
end

function ShenGeZhangKongCell:GetCellPoint()
	return self.effect_start_point
end

function ShenGeZhangKongCell:GetTextPosition()
	return self.text_pos
end

function ShenGeZhangKongCell:GetEndPoint(level)
	local index = level
	return self.star_position[index]
end

-- function ShenGeZhangKongCell:SetShowHightLight(is_on)
-- 	self.show_hight_light:SetValue(is_on)
-- end

function ShenGeZhangKongCell:SetExpValue(cur_exp, max_exp, is_level_change, is_tween, callback)	
	if  self.level ~= nil then
		if self.level == 100 then
			self.cur_exp = max_exp or self.max_exp
			self.max_exp = max_exp or self.max_exp
		else
			self.cur_exp = cur_exp or self.cur_exp
			self.max_exp = max_exp or self.max_exp
		end
		self.exp_text:SetValue(self.cur_exp.."/"..self.max_exp)

		local target_percent = self.cur_exp / self.max_exp
		-- if is_level_change then
		-- 	target_percent = target_percent + 1
		-- end

		self:SetSliderValue(target_percent, is_tween, callback)
	end
end

function ShenGeZhangKongCell:SetSliderValue(target_percent, is_tween, callback)
	if nil == self.cur_precent or not is_tween or self.cur_precent == target_percent then
		self.cur_precent = target_percent
		self.slider_text:SetValue(self.cur_precent)
		if nil ~= callback then
			callback()
		end
		
		return
	end

	self:RemoveSliderTween()
	self.slider_timer_quest = GlobalTimerQuest:AddRunQuest(function()

		self.cur_precent = math.min((self.cur_precent + 0.03), target_percent)
		local show_precent = self.cur_precent % 1.0
		self.slider_text:SetValue(show_precent)

		if self.cur_precent >= target_percent then
			self:RemoveSliderTween()
			if nil ~= callback then
				callback()
			end
		end

	 end, 0.03)
end

function ShenGeZhangKongCell:RemoveSliderTween()
	if nil ~= self.slider_timer_quest then
		GlobalTimerQuest:CancelQuest(self.slider_timer_quest)
		self.slider_timer_quest = nil
	end
end

function ShenGeZhangKongCell:SetStar(star, grade, is_tween)
	-- 第10阶开始复用月亮资源
	local pre_index = grade > 9 and (grade % 5 + 5) or grade
	local index = pre_index +1
	-- 5的倍数的时候特殊处理
	pre_index = (grade > 9 and grade % 5 == 0) and 10 or pre_index
	self.star = star or 0

	--星星获取的代码路径在res_path文件下的GetZhangkongStarRes方法调用
	function showstar()
		for i = 1, 5 do
			self.star_gray[i].grayscale.GrayScale = 0
			if i < self.star then
					self.is_show_star[i]:SetAsset(ResPath.GetZhangkongStarRes(index))
			elseif i == self.star then
				self.is_show_star[i]:SetAsset(ResPath.GetZhangkongStarRes(index))
			elseif i > self.star then
				if pre_index == 0 or index == 0 then
					self.star_gray[i].grayscale.GrayScale = 255
					self.is_show_star[i]:SetAsset(ResPath.GetZhangkongStarRes(1))
				else
					self.is_show_star[i]:SetAsset(ResPath.GetZhangkongStarRes(pre_index))
				end
			end
		end
	end

	if not is_tween then
		showstar()
		return
	end

	TipsCtrl.Instance:ShowFlyEffectManager(ViewName.ShenGeView, "effects2/prefab/ui/ui_huobanshengji_lizi_prefab", "UI_huobanshengji_lizi", self:GetCellPoint(), self:GetEndPoint(star), nil, 1, showstar)
end

function ShenGeZhangKongCell:CheckMaxLevel()
	if self.level == 100 then 
		return true
	else
		return false
	end
end

function ShenGeZhangKongCell:OnSingleDataChange(data, is_shield_play)
	if data ~= nil then
		if self.grid == data.grid then
			if self.level ~= data.level then
				self.level = data.level
				self.is_max_level:SetValue(self:CheckMaxLevel())
				local detail_data = ShenGeData.Instance:GetDetailData(self.grid, self.level)
				if is_shield_play then
					self:SetStar(data.star, data.grade, false)
					self:SetExpValue(data.exp, data.cfg_exp, true, false)
				else
					self:SetExpValue(data.exp, data.cfg_exp, true, true, function ()
						self:SetStar(data.star, data.grade, true)
					end)
				end

				local value = data.shenge_pro / 100
				self.shenge_pro:SetValue(value - value % 0.1)
				self.grade:SetValue(data.grade + 1)
				self.name:SetValue(data.name)
				self:SetProText(data.attr_list)
				
				self.zhan_dou_li:SetValue(self:GetZhandDouLi(data.attr_list))
			else
				self:SetExpValue(data.exp, data.cfg_exp, false, not is_shield_play)
			end
		end
	end
end

function ShenGeZhangKongCell:GetZhandDouLi(data)
	local data_attr = {}
	for i,v in ipairs(data) do
		if v ~= nil then
			data_attr[ATTR_NAME[v.name]] = v.val
		end
	end
	return CommonDataManager.GetCapability(data_attr)
end

function ShenGeZhangKongCell:SetProText(text_list)
	local text = ""
	for k,v in pairs(text_list) do
		if v ~= nil then
			if text ~= "" then 
				text = text.."\n"
			end
			local name = Language.ShengeZhangkong.ProName[v.name]
			if self.level == 0 then
				text = text..name .. "+" .. 0
			else
				text = text..name .. "+" .. v.val
			end
		end
	end
	self.pro_text:SetValue(text)
end

function ShenGeZhangKongCell:OnFlush()
	local data = ShenGeData.Instance:GetZhangkongInfoByGrid(self.grid)
	self.type:SetValue(Language.ShengeZhangkong.Type[self.grid])
	
	if data ~= nil  then
		self.level = data.level
		self.is_max_level:SetValue(self:CheckMaxLevel())
		self.grade:SetValue(data.grade + 1)
		self:SetExpValue(data.exp, data.cfg_exp, false, true)
		self.exp_val = data.exp
		self:SetStar(data.star, data.grade, false)
		local value = data.shenge_pro / 100
		self.shenge_pro:SetValue(value - value % 0.1)
		self.name:SetValue(data.name)
		self:SetProText(data.attr_list)
		if self.level == 0 then
			self.zhan_dou_li:SetValue(0)
		else
			self.zhan_dou_li:SetValue(self:GetZhandDouLi(data.attr_list))
		end

	end
end