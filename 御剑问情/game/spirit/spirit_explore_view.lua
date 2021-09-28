SpiritExploreView = SpiritExploreView or BaseClass(BaseView)

local SIMPLE_STAGE = 1
local DIFFICULTY_STAGE = 2
local STAGE_NUM = 6
local BOX_NUM = 6
local STAGE_RES = {
	[0] = "icon_spirit_simple",
	[1] = "icon_spirit_diffi",
	[2] = "icon_spirit_purgatory",
}

local BOX_RES = {
	[0] = "box_simple_",
	[1] = "box_diffi_",
	[2] = "box_purgatory_",	
}

local BG_RES = {
	[0] = "Spirit_Explore_simple.png",
	[1] = "Spirit_Explore_Diffi.png",
	[2] = "Spirit_Explore_Purgatory.png",	
}

function SpiritExploreView:__init()
	self.ui_config = {"uis/views/spiritview_prefab","SpirteExplore"}
	self.full_screen = false
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true

	self.choose_stage = nil
	self.stage_list = {}
	self.box_list = {}
	self.item_list = {}
end

function SpiritExploreView:__delete()

end

function SpiritExploreView:ReleaseCallBack()
	for k, v in pairs(self.stage_list) do
		if v ~= nil then
			v:DeleteMe()
		end
	end

	self.stage_list = {}

	for k, v in pairs(self.box_list) do
		if v ~= nil then
			v:DeleteMe()
		end
	end
	self.box_list = {}

	for k,v in pairs(self.item_list) do
		if v ~= nil then
			v:DeleteMe()
		end
	end
	self.item_list = {}

	self.effect = nil

	self.cur_stage = nil
	self.has_tiems = nil
	self.big_bg_res = nil
	self.has_reset = nil
	self.buff_str = nil
	self.show_item_1 = nil
	self.show_item_2 = nil
	self.show_item_3 = nil
	self.show_item_4 = nil
	self.mode_res = nil
	self.btn_buff = nil
	self.cur_arrow = nil
	self.show_arrow = nil
end

function SpiritExploreView:LoadCallBack()
	self.stage_list = {}
	for i = 1, STAGE_NUM do
		local obj = self:FindObj("Stage" .. i)
		self.stage_list[i] = SpiritExpStageRender.New(obj)
	end

	self.box_list = {}
	for i = 1,  BOX_NUM do
		local obj = self:FindObj("box" .. i)
		self.box_list[i] = SpiritExpBoxRender.New(obj)
	end

	self.cur_stage = self:FindVariable("CurChooseStr")
	self.has_tiems = self:FindVariable("HasTimeStr")
	self.big_bg_res = self:FindVariable("BigBgRes")
	self.mode_res = self:FindVariable("ModeRes")

	self.cur_arrow = self:FindObj("Arrow")
	self.show_arrow = self:FindVariable("ShowArrow")
    
	for i = 1, STAGE_NUM do
		self:ListenEvent("EventStage" .. i, BindTool.Bind2(self.OnClickStage, self, i))
	end

	self.has_reset = self:FindVariable("HasReset")
	self.buff_str = self:FindVariable("BuffStr")

		for i = 1, 4 do
			local obj = self:FindObj("Item" .. i)
			if obj ~= nil then
				local item_cell = ItemCell.New()
				item_cell:SetInstanceParent(obj)
				self.item_list[i] = item_cell
			end
		end

	self.show_item_1 = self:FindVariable("ShowItem1")
	self.show_item_2 = self:FindVariable("ShowItem2")
	self.show_item_3 = self:FindVariable("ShowItem3")
	self.show_item_4 = self:FindVariable("ShowItem4")
	self.btn_buff = self:FindObj("BuffBtn")

	self:ListenEvent("EventReset", BindTool.Bind(self.OnClickReset, self))
	self:ListenEvent("CloseView", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("EventBuyBuff", BindTool.Bind(self.OnClickBuyBuff, self))
	self:ListenEvent("EventTip", BindTool.Bind(self.OnClickTip, self))
end

function SpiritExploreView:OpenCallBack()
	self:Flush()
end

function SpiritExploreView:OnClickTip()
	TipsCtrl.Instance:ShowHelpTipView(TipsOtherHelpData.Instance:GetTipsTextById(202))
end

function SpiritExploreView:OnClickStage(index)
	if self.stage_list ~= nil and index ~= nil and self.stage_list[index] ~= nil then
		self.stage_list[index]:CheckIsCanFight()
	end
end

function SpiritExploreView:OnClickReset()
	local count = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_JING_LING_EXPLORE_RESET)
	if count > 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SpiritExpNoReset)
		return
	end

	local cfg = SpiritData.Instance:GetSpiritExploreInfo()
	if cfg.explore_info_list == nil then
		return
	end
	local info_list = cfg.explore_info_list
	local cur_stage = SpiritData.Instance:GetCurChallenge()
	local cur_mode = SpiritData.Instance:GetSpiritExpMode()
	local check_flag = false
	for k,v in pairs(info_list) do
		if v ~= nil then
			local config = SpiritData.Instance:GetSpiritExpConfig(cur_mode, k - 1)
			if config == nil or next(config) == nil then
				return
			end
			if v.reward_times < config.free_times and k < cur_stage then
				check_flag = true
				break
			end
		end
	end

	if check_flag then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SpiritExpHasFree)
		return
	end

	SpiritCtrl.Instance:SendJingLingExploreOperReq(JL_EXPLORE_OPER_TYPE.JL_EXPLORE_OPER_TYPE_RESET)
end

function SpiritExploreView:OnClickBuyBuff()
	TipsCtrl.Instance:OpenSpiritExpBuyBuffView()
end

function SpiritExploreView:OnClickClose()
	self:Close()
end

function SpiritExploreView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if "all" == k then
			self:FlushViewText()
			self:FlushStageList()
			self:FlushBoxList()
			self:FlushShowReward()
			self:FlushArrow()
			self:FlushBigBg()
			
			local count = SpiritData.Instance:GetExploreBuyBuffCount()
			if self.buff_str ~= nil then
				local percent = SpiritData.Instance:GetSpiritOtherCfgByName("explore_buff_add_per") or 0
				self.buff_str:SetValue(string.format(Language.JingLing.SpiritExploreCapUp, count * percent))
			end

			self:ShowEBuffFfect(count <= 0)
		end
	end
end

function SpiritExploreView:FlushBigBg(index)
	local cur_mode = SpiritData.Instance:GetSpiritExpMode()
	local bundle, asset = ResPath.GetRawImage(BG_RES[cur_mode])
	self.big_bg_res:SetAsset(bundle, asset)
end

function SpiritExploreView:FlushShowReward()
	if self.item_list == nil or next(self.item_list) == nil then
		return
	end
	local stage_index = SpiritData.Instance:GetCurChallenge()
	local cfg = SpiritData.Instance:GetExploreReward(stage_index)

	for k,v in pairs(self.item_list) do
		if v ~= nil then
			if cfg[k - 1] == nil then
				--v:SetItemActive(false)
				if self["show_item_" .. k] ~= nil then
					self["show_item_" .. k]:SetValue(false)
				end
			else
				--v:SetItemActive(true)
				v:SetData(cfg[k - 1])
				if self["show_item_" .. k] ~= nil then
					self["show_item_" .. k]:SetValue(true)
				end
			end
		end
	end
end

function SpiritExploreView:FlushArrow()
	local cur_stage = SpiritData.Instance:GetCurChallenge()
	local day_count = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_JING_LING_EXPLORE)
	local limlit_count = SpiritData.Instance:GetSpiritOtherCfgByName("explore_times") or 0
	local can_num = limlit_count - day_count
	if cur_stage > STAGE_NUM or can_num <= 0 then
		if self.show_arrow ~= nil then
			self.show_arrow:SetValue(false)
		end
	else
		if self.stage_list ~= nil and self.stage_list[cur_stage] ~= nil then
			self.show_arrow:SetValue(true)
			local pos = self.stage_list[cur_stage].root_node.transform.localPosition
			if self.cur_arrow ~= nil then
				self.cur_arrow.transform.localPosition = Vector3(pos.x + 150, pos.y, pos.z)
			end
		end
	end
end

function SpiritExploreView:FlushViewText(data)
	local cfg = SpiritData.Instance:GetSpiritExploreInfo()
	if cfg == nil or next(cfg) == nil then
		return
	end

	if self.has_tiems ~= nil then
		local day_count = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_JING_LING_EXPLORE)
		local limlit_count = SpiritData.Instance:GetSpiritOtherCfgByName("explore_times") or 0
		local can_num = limlit_count - day_count
		local color = can_num <= 0 and TEXT_COLOR.RED or TEXT_COLOR.GREEN
		self.has_tiems:SetValue(ToColorStr(can_num, color))
	end

	local mode = cfg.explore_mode or 0
	if self.mode_res ~= nil then
		self.mode_res:SetAsset(ResPath.GetSpiritImage("spirit_mode_" .. mode))
	end

	if self.has_reset ~= nil then
		local day_count = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_JING_LING_EXPLORE_RESET)
		local limlit_count = SpiritData.Instance:GetSpiritOtherCfgByName("explore_other_buy") or 0	
		self.has_reset:SetValue(string.format(Language.JingLing.SpiritHasReset, limlit_count - day_count))	
	end
end

function SpiritExploreView:FlushStageList()
	local cfg = SpiritData.Instance:GetSpiritExploreInfo()
	if cfg.explore_info_list == nil then
		return
	end
	local info_list = cfg.explore_info_list

	for i = 1, STAGE_NUM do
		if self.stage_list[i] ~= nil then
			info_list[i].index = i
			self.stage_list[i]:SetData(info_list[i])
		end
	end
end

function SpiritExploreView:FlushBoxList()
	local cfg = SpiritData.Instance:GetSpiritExploreInfo()
	if cfg.explore_info_list == nil then
		return
	end
	local info_list = cfg.explore_info_list

	for i = 1, BOX_NUM do
		if self.box_list[i] ~= nil then
			info_list[i].index = i
			self.box_list[i]:SetData(info_list[i])
		end
	end
end

function SpiritExploreView:ShowEBuffFfect(flag)
	if self.effect == nil then
	  	PrefabPool.Instance:Load(AssetID("effects2/prefab/ui_x/ui_tishitexiao_t_prefab", "UI_tishitexiao_T"), function (prefab)
			if not prefab or self.effect then return end

			-- if self.is_is_destroy_effect_loading then
			-- 	self.is_loading = false
			-- 	self.is_is_destroy_effect_loading = false
			-- 	return
			-- end

			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			local transform = obj.transform
			transform.localPosition = Vector3(transform.localPosition.x, transform.localPosition.y, transform.localPosition.z)
			transform.localScale = Vector3(0.9, 0.9, 0.9)
			if self.btn_buff ~= nil then
				transform:SetParent(self.btn_buff.transform, false)
			end
			self.effect = obj.gameObject
			self.is_loading = false
			self.effect:SetActive(flag)
		end)
	else
		self.effect:SetActive(flag)
	end
end
-------------------------------------------------------
SpiritExpStageRender = SpiritExpStageRender or BaseClass(BaseRender)

function SpiritExpStageRender:__init()
	self.stage_str = self:FindVariable("StageStr")
	self.bg_res = self:FindVariable("StageRes")
	self.level_text = self:FindVariable("LevelNum")
	self.img_bg = self:FindObj("StageBg")
	self.is_lock = true
end

function SpiritExpStageRender:__delete()
	self.stage_str = nil
	self.level_text = nil
	self.img_bg = nil
	self.bg_res = nil
end

function SpiritExpStageRender:SetData(data)
	self.data = data
	self:Flush()
end

function SpiritExpStageRender:OnFlush()
	if self.data == nil or next(self.data) == nil then
		return
	end

	local cur_stage = SpiritData.Instance:GetCurChallenge()
	local cur_mode = SpiritData.Instance:GetSpiritExpMode()
	local gray = 255
	if cur_stage >= self.data.index then
		self.level_text:SetValue(cur_mode + 1)
		gray = 0
	else 
		self.level_text:SetValue(4)
	end

	if self.img_bg ~= nil then
		if self.img_bg.grayscale ~= nil then
			self.img_bg.grayscale.GrayScale = gray
		end
	end


	if self.bg_res ~= nil then
		local bundle, asset = ResPath.GetSpiritImage(STAGE_RES[cur_mode])
		self.bg_res:SetAsset(bundle, asset)
	end

	if self.stage_str ~= nil then
		self.stage_str:SetValue(self.data.index or 0)
	end
end

function SpiritExpStageRender:CheckIsCanFight()
	-- if not self.is_lock then
	-- 	ViewManager.Instance:Open(ViewName.SpiritExpFightView)
	-- end
	local cur_stage = SpiritData.Instance:GetCurChallenge()
	local my_spirit = SpiritData.Instance:GetMySpiritInOther()
	if my_spirit.item_id == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.NoCanExploreSpirit)
		return
	end

	if self.data == nil or self.data.index == nil then
		return
	end

	if cur_stage > self.data.index then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.StageIsChanglle)
		return
	end

	if cur_stage < self.data.index then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.NeedChanglleLast)
		return
	end

	SpiritCtrl.Instance:OpenExpFightView(self.data.index)
	--SpiritCtrl.Instance:SendJingLingExploreOperReq(JL_EXPLORE_OPER_TYPE.JL_EXPLORE_OPER_TYPE_EXPLORE)
end

-------------------------------------------------------
SpiritExpBoxRender = SpiritExpBoxRender or BaseClass(BaseRender)

function SpiritExpBoxRender:__init()
	self.icon_res = self:FindVariable("IconPath")
	self.box_bg = self:FindObj("BoxBg")
	self.free_state = self:FindVariable("NoFree")
	self.consume_str = self:FindVariable("Consume")
	self.no_has_times = self:FindVariable("NoHasTimes")

	self:ListenEvent("EventOpen", BindTool.Bind(self.OnClickOpen, self))
end

function SpiritExpBoxRender:__delete()
	self.icon_res = nil
	self.box_bg = nil
	self.free_state = nil
	self.consume_str = nil
	self.no_has_times = nil
end

function SpiritExpBoxRender:SetData(data)
	self.data = data
	self:Flush()
end

function SpiritExpBoxRender:OnClickOpen()
	--ViewManager.Instance:Open(ViewName.SpiritExpRewardView)
	if self.data == nil or self.data.index == nil then
		return
	end
	local cur_stage = SpiritData.Instance:GetCurChallenge()
	if cur_stage <= self.data.index then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.ExploreNeedPass)
		return
	end

	local cur_mode = SpiritData.Instance:GetSpiritExpMode()
	local cfg = SpiritData.Instance:GetSpiritExpConfig(cur_mode, self.data.index - 1)
	if cfg == nil or next(cfg) == nil then
		return
	end
	local other_buy_time = SpiritData.Instance:GetSpiritOtherCfgByName("explore_other_buy") or 0
	local has_free = self.data.reward_times < cfg.free_times
	local all_time = cfg.free_times + other_buy_time
	local is_buy = 0
	if self.data.reward_times >= all_time then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SpiritExpRewardLimlit)
		return
	end


	if has_free then
		SpiritCtrl.Instance:SendJingLingExploreOperReq(JL_EXPLORE_OPER_TYPE.JL_EXPLORE_OPER_TYPE_FETCH, self.data.index -1, is_buy)
		SpiritData.Instance:SetExploreGetStageIndex(self.data.index)
	else
		local consume = 0
		local has_count = cfg.free_times + other_buy_time - self.data.reward_times > 0
		local consume_index = other_buy_time - self.data.reward_times + cfg.free_times
		consume_index = other_buy_time - consume_index + 1
		if has_count then
			if cfg["fetch_gold_" .. consume_index] ~= nil then
				consume = cfg["fetch_gold_" .. consume_index]
				is_buy = 1
			end
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SpiritExpRewardLimlit)
			return
		end

		local str = string.format(string.format(Language.JingLing.SpiritExpRewardAlert, consume))
		TipsCtrl.Instance:ShowCommonAutoView(true, str, function ()
			SpiritCtrl.Instance:SendJingLingExploreOperReq(JL_EXPLORE_OPER_TYPE.JL_EXPLORE_OPER_TYPE_FETCH, self.data.index -1, is_buy) 
			SpiritData.Instance:SetExploreGetStageIndex(self.data.index)
		end)		
	end
end

function SpiritExpBoxRender:OnFlush()
	if self.data == nil or next(self.data) == nil then
		return
	end

	local cur_stage = SpiritData.Instance:GetCurChallenge()
	local cur_mode = SpiritData.Instance:GetSpiritExpMode()
	local cfg = SpiritData.Instance:GetSpiritExpConfig(cur_mode, self.data.index - 1)
	if cfg == nil or next(cfg) == nil then
		return
	end
	local other_buy_time = SpiritData.Instance:GetSpiritOtherCfgByName("explore_other_buy") or 0

	local gray = 255
	local state = "close"
	local is_has_free = self.data.reward_times < cfg.free_times
	local has_time = self.data.reward_times < cfg.free_times + other_buy_time
	local has_count = cfg.free_times + other_buy_time - self.data.reward_times > 0
	local consume_index = other_buy_time - self.data.reward_times + cfg.free_times
	consume_index = other_buy_time - consume_index + 1
	if cur_stage > self.data.index then
		if has_time then
			gray = 0
		else
			state = "open"
		end
	end

	if self.box_bg ~= nil then
		if self.box_bg.grayscale ~= nil then
			self.box_bg.grayscale.GrayScale = gray
		end

	-- 	self.box_bg.animator:SetBool("Reward", false)
	-- 	self.box_bg.transform.localRotation = Vector3(0, 0, 0)
	end
	if self.icon_res ~= nil then
		local bundle, asset
		if self.index == 6 then
			local box_res = 0

			if cur_mode == 1 then
				box_res = 1
			elseif cur_mode == 2 then
				box_res = 4
			end

			bundle, asset = ResPath.GetGuildBoxIcon(box_res, state == "open")
		else
			-- 精灵探险已经屏蔽，已删除这个图片资源
			--bundle, asset = ResPath.GetSpiritImage(BOX_RES[cur_mode] .. state)
		end
		--self.icon_res:SetAsset(bundle, asset)
	end	

	self:ShowReward(gray == 0 and is_has_free)

	if self.free_state ~= nil then
		self.free_state:SetValue(not is_has_free)
	end

	local consume = 0
	local str_t = ""

	if self.no_has_times ~= nil then
		self.no_has_times:SetValue(not has_count)
	end

	if has_count then
		if cfg["fetch_gold_" .. consume_index] ~= nil then
			consume = cfg["fetch_gold_" .. consume_index]
		end
		str_t = string.format(Language.JingLing.SpiritHomeOpenBox, consume)
	else
		str_t = Language.JingLing.SpiritExpRewardLimlit
	end

	if self.consume_str ~= nil then
		self.consume_str:SetValue(str_t)
	end
end

function SpiritExpBoxRender:ShowReward(is_show)
	if self.box_bg ~= nil then
		self.box_bg.animator.enabled = is_show
		self.box_bg.animator:SetBool("Reward",is_show)
		if not is_show then
			--self.box_bg.animator.enabled = false
			self.box_bg.transform.localRotation = Vector3(0, 0, 0)
		end
	end
end