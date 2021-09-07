LuckyDrawView = LuckyDrawView or BaseClass(BaseView)

local COLUMN = 23

function LuckyDrawView:__init()
	self.ui_config = {"uis/views/luckydrawview", "LuckyDrawView"}
	self:SetMaskBg()
end

function LuckyDrawView:__delete()
	-- body
end

function LuckyDrawView:LoadCallBack()
	self.data = LuckyDrawData.Instance
	self.can_add_lot_list_cfg = self.data:GetCanAddLotCfg()


	self.act_time = self:FindVariable("ActTime")
	self.gold_need = self:FindVariable("GoldNeed")
	self.set_gray = self:FindVariable("SetGray")

	self.play_ani_toggle = self:FindObj("PlayAniToggle").toggle
	self.hight_light = self:FindObj("HightLight")
	self.content_animator = self:FindObj("Content").animator
	self.bottle_list = self:FindObj("BottleList")
	--self.selcet_effect = self:FindObj("selcet_effect")
	local scroller_delegate = self.bottle_list.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.contain_cell_list = {}
	self.item_cell_list = {}
	self.hight_light_list = {}
	self.reward_item_list = {}
	for i=1,COLUMN do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self:FindObj("Item_"..i))
		self.item_cell_list[i]:SetData(self.data:GetJiangChiList()[i].reward_item)
		self.item_cell_list[i]:SetActivityEffect(self.data:GetJiangChiList()[i].show ~= 1)
	end

	for i=1,6 do
		self.reward_item_list[i] = ItemCell.New()
		self.reward_item_list[i]:SetInstanceParent(self:FindObj("reward_item_"..i))
		if self.data:GetRewardItemCfg()[i] then
			self.reward_item_list[i]:SetData(self.data:GetRewardItemCfg()[i].reward_item)
			self.reward_item_list[i]:SetActivityEffect(self.data:GetRewardItemCfg()[i].show ~= 1)
		else
			self.reward_item_list[i]:SetItemActive(false)
		end
	end

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))

	self:ListenEvent("ClickTip", handler or BindTool.Bind(self.ClickTip, self))
	self:ListenEvent("ClickJump", handler or BindTool.Bind(self.ClickJump, self))
	self:ListenEvent("CloseView", handler or BindTool.Bind(self.CloseView, self))
	self:ListenEvent("ClickStart", handler or BindTool.Bind(self.ClickStart, self))
	self:ListenEvent("ClickReward", handler or BindTool.Bind(self.ClickReward, self))
	self:ListenEvent("ClickReplacement", handler or BindTool.Bind(self.ClickReplacement, self))
	self.timer_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.TimerCallback, self), 1)
	self:TimerCallback()
	self:Flush()
end

function LuckyDrawView:OpenCallBack()
	--self.selcet_effect:SetActive(false)
end

function LuckyDrawView:ReleaseCallBack()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

	for k,v in pairs(self.reward_item_list) do
		v:DeleteMe()
	end
	self.reward_item_list = {}

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}

	self.hight_light_list = {}

	self.act_time = nil
	self.gold_need = nil

	self.hight_light = nil
	self.bottle_list = nil
	self.play_ani_toggle = nil
	self.content_animator = nil
	self.data = nil
	self.set_gray = nil
	--self.selcet_effect = nil

	if nil ~= self.rotate_timer then
		GlobalTimerQuest:CancelQuest(self.rotate_timer)
	end

	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end
end

function LuckyDrawView:GetNumberOfCells()
	return #self.can_add_lot_list_cfg
end

function LuckyDrawView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = LuckyDrawBottle.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetBottleIndex(cell_index - 1)
	contain_cell:SetData(self.can_add_lot_list_cfg[cell_index])
	contain_cell:Flush()
end

function LuckyDrawView:OnFlush()
	local need_pay_money = LuckyDrawData.Instance:GetNeedPayMoney()
	self.gold_need:SetValue(need_pay_money)
	self.bottle_list.scroller:RefreshAndReloadActiveCellViews(false)
end

function LuckyDrawView:FlushAnimation()
	self.hight_light.gameObject:SetActive(true)
	local index = self.now_index or 1
	local speed_index = index
	local result_index = (self.data:GetRewardIndex()) + 1
	if result_index % COLUMN == 0 then
		result_index = COLUMN
	else
		result_index = result_index % COLUMN
	end
	if self.play_ani_toggle.isOn then
		self.set_gray:SetValue(false)
		--self.selcet_effect:SetActive(true)
		if nil == self.item_cell_list[result_index] then return end
		local posx = self.item_cell_list[result_index].root_node.transform.position.x
		local posy = self.item_cell_list[result_index].root_node.transform.position.y
		local posz = self.item_cell_list[result_index].root_node.transform.position.z
		self.hight_light.transform.position = Vector3(posx, posy, posz)
		-- self.selcet_effect.transform.position = Vector3(posx, posy, posz)
		self.now_index = result_index

		if nil ~= self.rotate_timer then
			GlobalTimerQuest:CancelQuest(self.rotate_timer)
		end
		return
	else
		--self.selcet_effect:SetActive(false)
		local loop_num = GameMath.Rand(2, 3)
		self.move_motion = function ()
			local quest = self.rotate_timer
			local quest_list = GlobalTimerQuest:GetRunQuest(quest)
			if nil == quest or nil == quest_list then return end
			if index == (loop_num * 23) + result_index then
				if nil == self.item_cell_list[result_index] then return end
				local posx = self.item_cell_list[result_index].root_node.transform.position.x
				local posy = self.item_cell_list[result_index].root_node.transform.position.y
				local posz = self.item_cell_list[result_index].root_node.transform.position.z
				self.hight_light.transform.position = Vector3(posx, posy, posz)
				self.now_index = result_index

				-- self.selcet_effect:SetActive(true)
				-- self.selcet_effect.transform.position = Vector3(posx, posy, posz)
				
				if nil ~= self.rotate_timer then
					GlobalTimerQuest:CancelQuest(self.rotate_timer)
					self.set_gray:SetValue(false)
				end
				return
			else
				local read_index = ((index + 1) == 23 and 23) or ((index + 1) % 23 == 0 and 23) or ((index + 1) % 23)
				local posx = self.item_cell_list[read_index].root_node.transform.position.x
				local posy = self.item_cell_list[read_index].root_node.transform.position.y
				local posz = self.item_cell_list[read_index].root_node.transform.position.z
				self.hight_light.transform.position = Vector3(posx, posy, posz)
				-- 速度限制
				if index < speed_index + 3 then
					quest_list[2] = 0.25 -- 0.1 0.25 0.1 0.08
				elseif speed_index + 3 <= index and index <= speed_index + 6 then
					quest_list[2] = 0.1
				elseif index > ((loop_num * 23) + result_index) - 5 then
					quest_list[2] = 0.2
					if index > ((loop_num * 23) + result_index) - 2 then
						quest_list[2] = 0.3
					end
				else
					quest_list[2] = 0.08
				end
				index = index + 1
			end
		end

		if nil ~= self.rotate_timer then
			GlobalTimerQuest:CancelQuest(self.rotate_timer)
		end
		self.rotate_timer = GlobalTimerQuest:AddRunQuest(self.move_motion, 0.1)
	end
end

function LuckyDrawView:CloseView()
	self:Close()
end

function LuckyDrawView:ClickStart()
	local ok_fun = function ()
		self.set_gray:SetValue(true)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW, RA_TIANMING_DIVINATION_OPERA_TYPE.RA_TIANMING_DIVINATION_OPERA_TYPE_START_CHOU, 0, 0)
	end
	local need_pay_money = LuckyDrawData.Instance:GetNeedPayMoney()
	local cfg = string.format(Language.LuckyDraw.LuckyStart, need_pay_money)
	TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg, nil, nil, true, false, "chongzhi1")
end

function LuckyDrawView:ClickReplacement()
	local ok_fun = function ()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW, RA_TIANMING_DIVINATION_OPERA_TYPE.RA_TIANMING_DIVINATION_OPERA_TYPE_RESET_ADD_LOT_TIMES, 0, 0)
	end
	local cfg = string.format(Language.LuckyDraw.Replacement)
	TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg, nil, nil, true, false, "chongzhi2")
end

function LuckyDrawView:ClickReward()
	local bool = self.content_animator:GetBool("open")
	bool = not bool
	self.content_animator:SetBool("open", bool)
end

function LuckyDrawView:ClickTip()
	TipsCtrl.Instance:ShowHelpTipView(TipsOtherHelpData.Instance:GetTipsTextById(237))
end

function LuckyDrawView:ClickJump()
	ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_warehouse)
end

function LuckyDrawView:TimerCallback()
	local time_tab = LuckyDrawData.Instance:GetRestTime()
	local str = TimeUtil.FormatSecond2DHMS(time_tab, 1)
	self.act_time:SetValue(str)
end


--------------------LuckyDrawBottle----------------------
LuckyDrawBottle = LuckyDrawBottle or BaseClass(BaseCell)
function LuckyDrawBottle:__init()
	self.add_num = self:FindVariable("Num")
	self.image_res = self:FindVariable("Image")
	self.pay_money = self:FindVariable("PayMoney")
	self.anim = self:FindObj("Anim")

	self:ListenEvent("ClickBuy", BindTool.Bind(self.OnClick, self))
end

function LuckyDrawBottle:__delete()
	self.add_num = nil
	self.image_res = nil
	self.anim = nil
end

function LuckyDrawBottle:SetData(data)
	self.data = data
	self:Flush()
end

function LuckyDrawBottle:SetBottleIndex(cell_index)
	self.bottle_index = cell_index
end

function LuckyDrawBottle:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	local can_add_lot_cfg = LuckyDrawData.Instance:GetCanAddLotCfg()
	local add_lot_list = LuckyDrawData.Instance:GetAddLotList()
	self.add_num:SetValue(add_lot_list[self.bottle_index])

	local add_lot = add_lot_list[self.bottle_index]
	local index = add_lot < 4 and add_lot or 3 --最高加注 3

	local pay_money = LuckyDrawData.Instance:GetConsumeCfg(index).add_consume_gold
	self.pay_money:SetValue(pay_money)

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.reward_item.item_id)
	if nil == item_cfg then return end
	self.image_res:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
end

function LuckyDrawBottle:OnClick()
	local ok_fun = function ()
		-- self.root_node.animator:SetTrigger("scale")
	self.anim.animator:SetTrigger("scale")
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW, RA_TIANMING_DIVINATION_OPERA_TYPE.RA_TIANMING_DIVINATION_OPERA_TYPE_ADD_LOT_TIMES,
		 self.bottle_index, param_3)
	end
	local add_lot_list = LuckyDrawData.Instance:GetAddLotList()
	if add_lot_list[self.bottle_index] >= 4 then
		TipsCtrl.Instance:ShowSystemMsg(Language.LuckyDrawBottle.Desc)
		return 
	end

	local pay_money = LuckyDrawData.Instance:GetConsumeCfg(add_lot_list[self.bottle_index]).add_consume_gold
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.reward_item.item_id)
	local cfg = string.format(Language.LuckyDraw.AddLotTips, pay_money, item_cfg.name)
	TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg, nil, nil, true, false, "chongzhi3")
end
