MarriageRingView = MarriageRingView or BaseClass(BaseRender)

local EFFECT_CD = 1

function MarriageRingView:__init()
	self.effect_root = self:FindObj("EffectRoot")
	self.effect_cd = 0

	self.ring_cell = ItemCell.New()
	self.ring_cell:SetInstanceParent(self:FindObj("RingCell"))
	self.ring_cell:SetData(nil)
	self.ring_cell:SetInteractable(false)
	self.now_ring_item_id = 0

	self.heart_list = {}
	local obj_group = self:FindObj("HeartGroup")
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, "Little_Heart") ~= nil then
			self.heart_list[count] = U3DObject(obj)
			count = count + 1
		end
	end
	self.ring_item_cell = ItemCellReward.New()
	self.ring_item_cell:SetInstanceParent(self:FindObj("RingItemCell"))

	self.ring_had_active = self:FindVariable("RingHadActive")
	self.progress_value = self:FindVariable("ProgressValue")
	self.progress_text = self:FindVariable("ProgressText")
	self.had_ring_item = self:FindVariable("HadRingItem")
	self.ring_can_upgrade = self:FindVariable("RingCanUpgrade")
	self.power = self:FindVariable("Power")
	self.button_text = self:FindVariable("ButtonText")
	self.is_max = self:FindVariable("IsMax")
	self.now_level = self:FindVariable("NowLevel")
	self.now_gongji = self:FindVariable("NowGongJi")
	self.now_fangyu = self:FindVariable("NowFangYu")
	self.now_hp = self:FindVariable("NowHp")
	self.next_level = self:FindVariable("NextLevel")
	self.next_gongji = self:FindVariable("NextGongJi")
	self.next_fangyu = self:FindVariable("NextFangYu")
	self.next_hp = self:FindVariable("NextHp")

	self:ListenEvent("UpgradeRingClick", BindTool.Bind(self.UpgradeRingClick, self))
	self:ListenEvent("AutoUpgradeClick", BindTool.Bind(self.AutoUpgradeRingClick, self))
	self:ListenEvent("OpenMail", BindTool.Bind(self.OpenMail, self))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))

	self.start_level = 0		--开始自动升级的等级
	self.now_ring_level = 0

	self.init_proess = true
	self.button_text:SetValue(Language.Common.AutoUpgrade)
end

function MarriageRingView:ShowOrHideTab()
end

function MarriageRingView:__delete()
	if self.ring_cell then
		self.ring_cell:DeleteMe()
		self.ring_cell = nil
	end

	if self.ring_item_cell then
		self.ring_item_cell:DeleteMe()
		self.ring_item_cell = nil
	end
	self.obj_group = nil
	self.effect_cd = 0

	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function MarriageRingView:CloseCallBack()
	self:StopAutoUpgrade()
end

--升级戒指按下时
function MarriageRingView:UpgradeRingClick()
	local flag, item_id = MarriageData.Instance:GetRingInfo()
	if flag == 0 then
		--满级了
		TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Ring_Max_Level)
	elseif flag == 1 then
		--未满级-可升级
		MarriageCtrl.Instance:SendUpgradeRing(1, 0)
	elseif flag == 2 then
		--不够材料
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
		-- TipsCtrl.Instance:ShowCommonBuyView(BindTool.Bind(self.BuyFunc, self), item_id, nil, 1)
	elseif flag == 3 then
		--未激活
		if self:CheckIsMarry() then
			--已结婚
			TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Activate_Ring)
		else
			--未结婚
			self:ShowGoToMarryTips()
		end
	end
end

--自动升级戒指
function MarriageRingView:AutoUpgradeRingClick()
	if self.time_quest ~= nil then
		self:StopAutoUpgrade()
	else
		local flag, item_id = MarriageData.Instance:GetRingInfo()

		local function ok_callback()
			self.start_level = self.now_ring_level
			local time_per_once = MarriageData.Instance:GetRingUpgradeItem().interval_time
			self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.AutoUpgrade, self), time_per_once)
		end

		if flag == 0 then
			--满级了
			TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Ring_Max_Level)
		elseif flag == 1 then
			--未满级-可升级
			local des = Language.Marriage.AutoUpLevelRing
			TipsCtrl.Instance:ShowCommonAutoView("auto_ring_up", des, ok_callback)
		elseif flag == 2 then
			--不够材料
			TipsCtrl.Instance:ShowItemGetWayView(item_id)
		elseif flag == 3 then
			--未激活
			if self:CheckIsMarry() then
				--已结婚
				TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Activate_Ring)
			else
				--未结婚
				self:ShowGoToMarryTips()
			end
		end
	end
end

--前往结婚提示板
function MarriageRingView:ShowGoToMarryTips()
	local click_func = BindTool.Bind(self.GoToMarryClick, self)
	TipsCtrl.Instance:ShowOneOptionView(Language.Marriage.Not_Marry_Can_Not_Use, click_func, Language.Marriage.Go_To_Marry)
end

--是否已婚
function MarriageRingView:CheckIsMarry()
	return MarriageData.Instance:CheckIsMarry()
end

--前往结婚
function MarriageRingView:GoToMarryClick()
	if self:CheckIsMarry() then
		if not ScoietyData.Instance:GetTeamState() then
			local param_t = {}
			param_t.must_check = 0
			param_t.assign_mode = 2
			ScoietyCtrl.Instance:CreateTeamReq(param_t)
		end
		ScoietyCtrl.Instance:InviteUserReq(GameVoManager.Instance:GetMainRoleVo().lover_uid)
	else
		ViewManager.Instance:Open(ViewName.Wedding)
	end
end

function MarriageRingView:StopAutoUpgrade()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.button_text:SetValue(Language.Common.AutoUpgrade)
end

function MarriageRingView:OpenMail()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_mail)
end

function MarriageRingView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(9)
end

--播放升级特效
function MarriageRingView:PlayUpStarEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		EffectManager.Instance:PlayAtTransformCenter(
			"effects2/prefab/ui_x/ui_sjcg_prefab",
			"UI_sjcg",
			self.effect_root.transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

function MarriageRingView:AutoUpgrade()
	local ring_cfg = MarriageData.Instance:GetRingCfg()
	local _,big_lev = math.modf(ring_cfg.equip_id/10)
	big_lev = string.format("%.2f", big_lev or 0) * 100
	local level = big_lev + ring_cfg.star
	local stop_big_level = math.modf((self.start_level + 10)/10)
	local stop_level = stop_big_level * 10
	if level >= stop_level then
		self:StopAutoUpgrade()
		return
	end

	local flag, item_id = MarriageData.Instance:GetRingInfo()
	if flag == 1 then
		MarriageCtrl.Instance:SendUpgradeRing(1, 0)
		self.button_text:SetValue(Language.Common.Stop)
	elseif flag == 2 then
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
		self:StopAutoUpgrade()
	else
		self:StopAutoUpgrade()
	end
end

function MarriageRingView:Flush()
	--戒指图标
	local ring_cfg = MarriageData.Instance:GetRingCfg()
	local ring_id = nil
	if ring_cfg ~= nil then
		ring_id = ring_cfg.equip_id
	else
		ring_id = MarriageData.Instance:GetLevelOneRingCfg().equip_id
	end
	if self.now_ring_item_id ~= ring_id then
		self.ring_cell:SetData({item_id = ring_id, is_bind = 0}, true)
		self.ring_cell:SetInteractable(false)
		self.now_ring_item_id = ring_id
	end

	--设置戒指信息
	local flag, item_id = MarriageData.Instance:GetRingInfo()
	if flag == 3 then
		--未激活
		self.ring_had_active:SetValue(false)
		if self.init_proess then
			self.init_proess = false
			self.progress_value:InitValue(0)
		else
			self.progress_value:SetValue(0)
		end
	else
		--已激活
		self.ring_had_active:SetValue(true)
		local ring_cfg2, is_max = MarriageData.Instance:GetRingCfg()
		local ring_exp = MarriageData.Instance:GetRingExp()
		if is_max then
			self.progress_text:SetValue("- / -")
			if self.init_proess then
				self.init_proess = false
				self.progress_value:InitValue(1)
			else
				self.progress_value:SetValue(1)
			end
		else
			local progress_value = ring_exp / ring_cfg2.exp
			if self.init_proess then
				self.init_proess = false
				self.progress_value:InitValue(progress_value)
			else
				self.progress_value:SetValue(progress_value)
			end
			self.progress_text:SetValue(ring_exp.." ".."/".." "..ring_cfg2.exp)
		end
		--能否升级
		self.ring_can_upgrade:SetValue(flag == 1)
	end

	--设置材料信息
	local id = MarriageData.Instance:GetRingUpgradeItem().stuff_id
	local num = ItemData.Instance:GetItemNumInBagById(id)
	self.had_ring_item:SetValue(num)
	local data = {}
	data.item_id = id
	self.ring_item_cell:SetData(data)

	if ring_cfg then
		local attrs = CommonDataManager.GetAttributteByClass(ring_cfg, true)
		local capability = CommonDataManager.GetCapability(attrs)
		local item_cfg = ItemData.Instance:GetItemConfig(ring_cfg.equip_id)
		self.power:SetValue(capability)
		for k,v in pairs(self.heart_list) do
			--v.grayscale.GrayScale = 255
			local no_light = v.transform:GetChild(0).gameObject
			local light = v.transform:GetChild(1).gameObject
			no_light:SetActive(true)
			light:SetActive(false)
		end
		for i=1,ring_cfg.star do
			--self.heart_list[i].grayscale.GrayScale = 0
			local no_light = self.heart_list[i].transform:GetChild(0).gameObject
			local light = self.heart_list[i].transform:GetChild(1).gameObject
			no_light:SetActive(false)
			light:SetActive(true)
		end

		local _,big_lev = math.modf(ring_cfg.equip_id/10)
		big_lev = string.format("%.2f", big_lev or 0) * 100
		local level = big_lev + ring_cfg.star

		if self.now_ring_level > 0 and level > self.now_ring_level then
			--播放升级特效
			self:PlayUpStarEffect()
		end

		self.now_ring_level = level		--记录开始升级前的等级

		--设置当前信息
		self.now_level:SetValue(level)
		self.now_gongji:SetValue(ring_cfg.gongji)
		self.now_fangyu:SetValue(ring_cfg.fangyu)
		self.now_hp:SetValue(ring_cfg.maxhp)

		--获取下一级效果
		local next_cfg = MarriageData.Instance:GetNextRingCfg()
		if next_cfg then
			self.is_max:SetValue(false)
			self.next_level:SetValue(level + 1)
			self.next_gongji:SetValue(next_cfg.gongji)
			self.next_fangyu:SetValue(next_cfg.fangyu)
			self.next_hp:SetValue(next_cfg.maxhp)
		else
			self.is_max:SetValue(true)
		end
	end
end

