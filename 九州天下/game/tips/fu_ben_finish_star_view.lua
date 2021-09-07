FuBenFinishStarView = FuBenFinishStarView or BaseClass(BaseView)

function FuBenFinishStarView:__init()
	self.ui_config = {"uis/views/fubenview", "VictoryFinishViewWithStar"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].Shengli) or 0
	end
	self.leave_time = 0

	self:SetMaskBg()
end

function FuBenFinishStarView:LoadCallBack()
	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickClose, self))
	self.victory_items = {}
	for i = 1, 6 do
		local item_obj = self:FindObj("VItem"..i)
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(item_obj)
		self.victory_items[i - 1] = {item_obj = item_obj, item_cell = item_cell}
	end
	self.victory_text = self:FindVariable("VictoryText_1")
	self.enter_text = self:FindVariable("EnterBtnzText")
	self.star_list = {}
	for i = 1, 3 do
		self.star_list[i]= self:FindObj("Star" .. i)
	end
	self.star_num = 0
end

function FuBenFinishStarView:OpenCallBack()
	self.enter_text:SetValue(Language.Common.Confirm)
	self:Flush("finish")
end

function FuBenFinishStarView:ReleaseCallBack()
	for k,v in pairs(self.victory_items) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end
	for k,v in pairs(self.star_list) do
		v = nil
	end
	self.victory_items = {}
	self.victory_text = nil
	self.enter_text = nil
	self.star_num = 0
end

function FuBenFinishStarView:SetCloseCallBack(callback)
	self.close_callback = callback
end

function FuBenFinishStarView:CloseCallBack()
	if self.close_callback then
		self.close_callback()
		self.close_callback = nil
	end
	self.leave_time = 0
	if self.leave_timer then
		GlobalTimerQuest:CancelQuest(self.leave_timer)
		self.leave_timer = nil
	end

	if self.play_count_down then
		CountDown.Instance:RemoveCountDown(self.play_count_down)
		self.play_count_down = nil
	end
end

function FuBenFinishStarView:OnClickClose()
	FuBenCtrl.Instance:SendExitFBReq()
	self:Close()
end

function FuBenFinishStarView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "finish" then
			if v.data ~= nil then
				for i, j in pairs(self.victory_items) do
					if v.data[i] then
						j.item_cell:SetData(v.data[i])
						j.item_obj:SetActive(true)
					else
						j.item_obj:SetActive(false)
					end
				end
			end
			if v.pass_time then
				local str_pass = string.format(Language.Mount.ShowHeightGreenStr, TimeUtil.FormatSecond(v.pass_time, 4))
				self.victory_text:SetValue(str_pass)
			end
			if v.star then
				self.star_num = v.star
				self:StartPlayEffect()
			end
		end
	end
end

function FuBenFinishStarView:StartPlayEffect()
	self.root_node:GetComponent(typeof(UnityEngine.CanvasGroup)).alpha = 1
	local count = self.star_num
	for i = 1, 3 do
		self.star_list[i].canvas_group.alpha = 0
	end
	--创建计时器分步显示item
	self.step = 0

	if self.play_count_down then
		CountDown.Instance:RemoveCountDown(self.play_count_down)
		self.play_count_down = nil
	end

	self.play_count_down = CountDown.Instance:AddCountDown(2, 0.5, BindTool.Bind(self.PlayTime, self, self.star_list, count))
end

function FuBenFinishStarView:PlayTime(group_cell, count, elapse_time, total_time)
	if self.step >= count or elapse_time >= total_time then
		if self.play_count_down then
			CountDown.Instance:RemoveCountDown(self.play_count_down)
			self.play_count_down = nil
		end
		for i = 1, 3 do
			self.star_list[i].canvas_group.alpha = 1
			self.star_list[i].grayscale.GrayScale = 0
		end
		if self.star_num < 3 then
			for i = self.star_num + 1, 3 do
				self.star_list[i].grayscale.GrayScale = 255
			end
		end
		return
	end
	self.step = self.step + 1

	local item_num = self.step
	-- GameObjectPool.Instance:SpawnAsset("effects2/prefab/ui/ui_choujiang_prefab", "UI_choujiang", BindTool.Bind(self.LoadEffect, self, item_num, group_cell))
	group_cell[self.step].canvas_group.alpha = 1
end

function FuBenFinishStarView:LoadEffect(item_num, group_cell, obj)
	if not obj then
		return
	end
	local transform = obj.transform
	transform:SetParent(group_cell[item_num].transform, false)
	local function Free()
		if IsNil(obj) then
			return
		end
		GameObjectPool.Instance:Free(obj)
	end
	GlobalTimerQuest:AddDelayTimer(Free, 1)
end