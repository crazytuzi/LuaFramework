SpiritHomeView = SpiritHomeView or BaseClass(BaseRender)

local MOVE_TIMER = 5
local MAX_MOVE_TIMER = 10
local CHAT_TIMER = 2
local ADD_MAX = 10

function SpiritHomeView:__init(instance)
	self.uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))

	self:ListenEvent("EventExplore", BindTool.Bind(self.OnClickGoExplore, self))
	self:ListenEvent("OpenPreview", BindTool.Bind(self.OnClickOpenPreview, self))
	self:ListenEvent("EventPlunder", BindTool.Bind(self.OnClickPlunder, self))
	self:ListenEvent("EventBack", BindTool.Bind(self.OnClickBack, self))
	self:ListenEvent("EventRevenge", BindTool.Bind(self.OnClickRevenge, self))

	self.add_item_list = {}
	self.add_finish_list = {}
	for i = 1, ADD_MAX do
		self.add_finish_list[i] = 0
	end

	self.render_list = {}
	for i = 1, 4 do
		self["game_obj" .. i] = self:FindObj("Render" .. i)
		if self["game_obj" .. i] ~= nil then
			self.render_list[i] = SpiritHomeRender.New(self["game_obj" .. i])
			self.render_list[i]:SetIndex(i)
		end
	end

	self.birth_pos = self:FindObj("BirthPos")
	self.model_pos = {}
	for i = 1, 5 do
		self["model_obj_" .. i] = self:FindObj("Spirit" .. i)
		self["show_spirit_" .. i] = self:FindVariable("ShowSpirit" .. i)
		--精灵当前坐标
		self.model_pos[i] = {x = 0, y = 0, dis = 0}
	end
	self.spirit_list = {}

	for i = 1, 5 do
		self:ListenEvent("ClickSpirit" .. i, BindTool.Bind(self.ClickSpirit, self, i))
	end

	local fight_obj = self:FindObj("FightRender")
	self.fight_render = SpiritHomeOtherRender.New(fight_obj)

	self.btn_preview_obj = self:FindObj("BtnPreviewObj")
	if self.btn_preview_obj ~= nil then
		self.btn_preview_pos = self.btn_preview_obj.transform.localPosition
	end

	self.question_image_obj = self:FindObj("QuestionImageObj")
	if self.question_image_obj ~= nil then
		self.question_image_pos = self.question_image_obj.transform.localPosition
	end

	self.chat_preview_obj = self:FindObj("ChatPreviewObj")
	if self.chat_preview_obj ~= nil then
		self.chat_preview_pos = self.chat_preview_obj.transform.localPosition
	end

	self.show_home_name = self:FindVariable("ShowHomeName")
	self.home_name = self:FindVariable("HomeName")

	self.show_btn_revenge = self:FindVariable("ShowRevenge")
	self.show_btn_explore = self:FindVariable("ShowExplore")
	self.home_flag = self:FindVariable("IsMyHome")
	self.is_show_back = self:FindVariable("ShowBtnBack")
	self.show_other_str = self:FindVariable("ShowOtherStr")
	self.other_str = self:FindVariable("OtherStr")
	self.show_preview_chat = self:FindVariable("ShowPreviewChat")
	self.my_harvert = self:FindVariable("MyHarvert")
	self.other_harvert = self:FindVariable("OtherHarvert")

	self.other_str_obj = self:FindObj("OtherStrObj")
	self.other_str_pos = self.other_str_obj.transform.localPosition
	self.timer_list = {}

	self:ListenEvent("ClickBg", BindTool.Bind(self.OnClickBg, self))
	self:ListenEvent("ClickTip", BindTool.Bind(self.OnClickTip, self))

	--设置地图信息
	self:InitHomeMap()

	--初始化邀请列表
	self:InitPlunder()

	self.red_point_list = {
		[RemindName.SpiritHomeReward] = self:FindVariable("ShowPreviewRed"),
		-- [RemindName.SpiritHomeRevnge] = self:FindVariable("ShowRevengeRed"),
		-- [RemindName.SpiritPlunder] = self:FindVariable("ShowPlunderRed")
	}

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function SpiritHomeView:__delete()
	self.is_first_plunder = false
	if self.render_list ~= nil and next(self.render_list) ~= nil then
		for k,v in pairs(self.render_list) do
			if v ~= nil then
				v:DeleteMe()
			end
		end

		self.render_list = nil
	end

	if self.spirit_list ~= nil then
		for k,v in pairs(self.spirit_list) do
			if v ~= nil and v.model ~= nil then
				if v.loop_tweener ~= nil then
					v.loop_tweener:Pause()
				end

				v.model:DeleteMe()
			end
		end

		self.spirit_list = {}
	end

	if self.time_quest ~= nil then
		for i = 1, 5 do
			if self.time_quest[i] ~= nil then
				GlobalTimerQuest:CancelQuest(self.time_quest[i])
			end
		end

		self.time_quest = nil
	end

	for k,v in pairs(self.timer_list) do
		if v ~= nil then
			CountDown.Instance:RemoveCountDown(v)
		end
	end
	self.timer_list = nil

	if self.fight_render ~= nil then
		self.fight_render:DeleteMe()
		self.fight_render = nil
	end

	self.view_root = nil

	for i = 1, 5 do
		self["model_obj_" .. i] = nil
		self["show_spirit_" .. i] = nil
		self.model_pos[i] = {x = 0, y = 0, dis = 0}
		self["game_obj" .. i] = nil
	end

	for k,v in pairs(self.add_item_list) do
		if not IsNil(v) then
			GameObject.Destroy(v)
		end
	end
	self.add_item_list = {}

	if self.other_tween ~= nil then
		self.other_tween:Pause()
		self.other_tween = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	self.birth_pos = nil
	self.home_flag = nil
	self.is_show_back = nil
	self.uicamera = nil
	self.show_btn_revenge = nil
	self.show_btn_explore = nil
	self.show_other_str = nil
	self.other_str = nil
	self.show_preview_chat = nil
	self.my_harvert = nil
	self.other_harvert = nil
	self.btn_preview_obj = nil
	self.question_image_obj = nil
	self.chat_preview_obj = nil
	self.show_home_name = nil
	self.home_name = nil
	self.red_point_list = nil
	self.other_str_obj = nil

	self:DeletePlunder()
end

function SpiritHomeView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function SpiritHomeView:OpenCallBack()
	Runner.Instance:AddRunObj(self, 8)
	self:Flush()
end

function SpiritHomeView:CloseCallBack()
	Runner.Instance:RemoveRunObj(self, 8)
end
function SpiritHomeView:InitHomeMap()
	SpiritData.Instance:InitMap(950, 500)
end

function SpiritHomeView:SetSelectPlunderIndex(index)
	self.select_plunder_index = index
end

function SpiritHomeView:InitPlunder()
	self.plunder_state = false
	self.is_first_plunder = true
	self.cell_list = {}

	self.list_view = self:FindObj("PlunderList")
	if self.list_view ~= nil then
		local list_delegate = self.list_view.list_simple_delegate
		list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	end

	self.move_obj = self:FindObj("MoveObj")
	self.bg_obj = self:FindObj("BgObj")
	self.btn_res = self:FindVariable("PlunderRes")
	self.plunder_x = self.move_obj.transform.localPosition
	self.show_plunder = self:FindVariable("ShowPlunder")
	self.harvert_limlit = self:FindVariable("HarvertLimlit")

	self:ListenEvent("PlunderFlush", BindTool.Bind(self.OnClickFlush, self))
end

function SpiritHomeView:DeletePlunder()
	self.plunder_state = false

	for k,v in pairs(self.cell_list) do
		if v ~= nil then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	self.select_plunder_index = nil

	self.list_view = nil
	self.move_obj = nil
	self.bg_obj = nil
	self.btn_res = nil
	self.show_plunder = nil
	self.harvert_limlit = nil
end

function SpiritHomeView:GetNumberOfCells()
	local num = 0
	num = #SpiritData.Instance:GetSpiritHomePlunderList()

	return num
end

function SpiritHomeView:RefreshCell(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = SpiritHomePeopleRender.New(cell.gameObject)
		self.cell_list[cell] = group_cell
		group_cell:SetToggleGroup(self.list_view.toggle_group)
	end

	local data_list = SpiritData.Instance:GetSpiritHomePlunderList()
	group_cell:SetIndex(data_index)
	group_cell:SetData(data_list[data_index + 1] or {})

	if self.select_plunder_index ~= nil and self.select_plunder_index == data_index then
		group_cell:SetSelctState(true)
	else
		group_cell:SetSelctState(false)
	end
end


function SpiritHomeView:SetRootParent(root)
	self.view_root = root
end

function SpiritHomeView:OnClickBg()
	if self.plunder_state then
		self:OnClickPlunder()
	end
end

function SpiritHomeView:OnClickTip()
	TipsCtrl.Instance:ShowHelpTipView(TipsOtherHelpData.Instance:GetTipsTextById(203))
end

function SpiritHomeView:ClickSpirit(index)
	local cfg = SpiritData.Instance:GetSpiritHomeRewardList(index)
	if cfg == nil or cfg.item_id <= 0 then
		return
	end

	TipsCtrl.Instance:OpenSpiritHomeHarvestView(index)
end

function SpiritHomeView:OnClickFlush()
	SpiritCtrl.Instance:SendJingLingHomeOperReq(JING_LING_HOME_OPER_TYPE.JING_LING_HOME_OPER_TYPE_REFRESH_LIST, 0)
end

function SpiritHomeView:OnClickGoExplore()
	local data = SpiritData.Instance:GetMySpiritInOther()
	if data ~= nil and data.item_id <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.PleaseEquipJingLing)
		return
	end

	SpiritCtrl.Instance:OpenChooseModeView()
	--TipsCtrl.Instance:OpenSpiritHomePreviewView()
	--SpiritCtrl.Instance:OpenSpiritHomeFightView(15016, 15010)
end

function SpiritHomeView:OnClickOpenPreview()
	TipsCtrl.Instance:OpenSpiritHomePreviewView()
end

function SpiritHomeView:OnClickBack()
	local flag = SpiritData.Instance:GetIsMyHome()
	if not flag then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		SpiritCtrl.Instance:SendJingLingHomeOperReq(JING_LING_HOME_OPER_TYPE.JING_LING_HOME_OPER_TYPE_GET_INFO,
		 main_role_vo.role_id)
	end
end

function SpiritHomeView:OnClickRevenge()
	SpiritCtrl.Instance:OpenSpiritHomeRevengeView()
end

function SpiritHomeView:OnClickPlunder()
	if self.move_obj == nil or self.bg_obj == nil then
		return
	end

	if self.is_first_plunder then
		self.is_first_plunder = false
		self:OnClickFlush()
	end

	self.plunder_state = not self.plunder_state
	if self.plunder_state and self.show_plunder ~= nil then
		self.show_plunder:SetValue(self.plunder_state)
	end

	local move_w = self.bg_obj.transform:GetComponent(typeof(UnityEngine.RectTransform)).rect.width or 0
	local move_dis = self.plunder_state and -1 or 1

	if self.btn_res ~= nil then
		local str = self.state and "btn_spirit_home" or "btn_spirit_home_close"
		self.btn_res:SetAsset(ResPath.GetSpiritImage(str))
	end

	local start_x = self.move_obj.transform.localPosition.x
	local move_vaule = start_x + move_dis * move_w

	local tween = self.move_obj.transform:DOLocalMoveX(move_vaule, 0.5)
	tween:SetEase(DG.Tweening.Ease.Linear)
	tween:OnComplete(function()
		if not self.plunder_state then
			if self.show_plunder ~= nil then
				self.show_plunder:SetValue(self.plunder_state)
			end

			if self.btn_res ~= nil then
				local str = "btn_spirit_home"
				self.btn_res:SetAsset(ResPath.GetSpiritImage(str))
			end

			self.select_plunder_index = nil
			if self.list_view ~= nil then
				self.list_view.scroller:ReloadData(0)
			end
		end
	end)
end

function SpiritHomeView:ClickBox(index)
	TipsCtrl.Instance:OpenSpiritHomeHarvestView(index)
end

function SpiritHomeView:ClickBoxOpera(index)
	local is_my = SpiritData.Instance:GetIsMyHome()
	if is_my then
		local cfg = SpiritData.Instance:GetSpiritHomeInfoByIndex(index)
		local limlit_timer = SpiritData.Instance:GetSpiritOtherCfgByName("home_reward_times_limit") or 0
		if cfg ~= nil and cfg.reward_times ~= nil and cfg.reward_times < limlit_timer then
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			local consume = SpiritData.Instance:GetSpiritOtherCfgByName("home_quick_gold") or 0
			local quick_time = SpiritData.Instance:GetSpiritOtherCfgByName("home_quick_time") or 0
			local interval = SpiritData.Instance:GetSpiritOtherCfgByName("home_reward_interval") or 0
			local has_item = math.floor(quick_time / interval)
			local str = string.format(Language.JingLing.SpiritHomeQuickTip, consume, math.ceil(quick_time / 60), math.ceil(interval / 60), has_item)
			TipsCtrl.Instance:ShowCommonTip(function()
				SpiritCtrl.Instance:SendJingLingHomeOperReq(JING_LING_HOME_OPER_TYPE.JING_LING_HOME_OPER_TYPE_QUICK, main_role_vo.role_id, index - 1)
				end, nil, str, nil, nil, true, nil, "spirit_home_quick")
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SpiritHomeQuickLimlit)
			return
		end
	else
        local cfg = SpiritData.Instance:GetMySpiritInOther()
        if cfg.item_id <= 0 then
            SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.PleaseEquipJingLing)
            return
        end

		TipsCtrl.Instance:OpenSpiritHomeConfirmView(index)
	end
end

function SpiritHomeView:FightOpera(reason, res_id, value)
end

function SpiritHomeView:ChangeSpirit(index, res_id, state, change_pos)
	if index == nil or res_id == nil then
		return
	end

	if self.spirit_list == nil then
		self.spirit_list = {}
	end

	local opera_type = res_id == 0 and "delete" or "add"

	if self["show_spirit_" .. index] ~= nil then
		self["show_spirit_" .. index]:SetValue(opera_type == "add" or false)
		--self.spirit_list[index].show = opera_type == "add" or false
	end

	if self.spirit_list[index] == nil then
		if self["model_obj_" .. index] ~= nil and opera_type == "add" then
			self:InitModel(index, res_id, state)
			--self:MoveSpirit(index)
			self.spirit_list[index].can_move = true
		end
	else
		if opera_type == "add" then
			if SpiritData.Instance:GetHomeIsChange() then
				if self.spirit_list[index].loop_tweener ~= nil then
					self.spirit_list[index].loop_tweener:Pause()
					if self.spirit_list[index].model then
						self.spirit_list[index].model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
					end
				end

				if self.time_quest ~= nil and self.time_quest[index] ~= nil then
					GlobalTimerQuest:CancelQuest(self.time_quest[index])
				end

				if self.timer_list[index] ~= nil then
					CountDown.Instance:RemoveCountDown(self.timer_list[index])
					self.timer_list[index] = nil
				end

				local borth_index = SpiritData.Instance:GetSpiritHinderList(nil, index, not SpiritData.Instance:GetIsMyHome())
				local pos_t = SpiritData.Instance:GetPosByIndex(borth_index)
				local pos = self.birth_pos.transform.localPosition
				--self["model_obj_" .. index].transform:SetLocalPosition(pos_t.x, pos_t.y, pos.z)
				self["model_obj_" .. index].transform.localPosition = Vector3(pos_t.x, pos_t.y, pos.z)
				if self.model_pos ~= nil and self.model_pos[index] ~= nil then
					self.model_pos[index] = {x = pos_t.x, y = pos_t.y, z = 0, dis = 0}
				end
			end

			if self.spirit_list[index].res_id ~= res_id then
				self.spirit_list[index].res_id = res_id
				self.spirit_list[index].model:SetMainAsset(ResPath.GetSpiritModel(res_id))
			end

			self:FlushTop(index, state)
			self:FlushBottom(index, state)

				-- if self.spirit_list[index].model ~= nil then
				-- 	self.spirit_list[index].model:SetTrigger("rest")
				-- end

			if self.spirit_list[index].move_timer ~= nil then
				self.spirit_list[index].move_timer = 0
			end

			if self.spirit_list[index].ran_time ~= nil then
				--self.spirit_list[index].ran_time = math.random(MOVE_TIMER, MAX_MOVE_TIMER)
				local ran_value = tonumber(string.format("%2d", math.random()))
				self.spirit_list[index].ran_time = math.random(MOVE_TIMER, MAX_MOVE_TIMER) + ran_value
			end

			if self.spirit_list[index].show ~= nil then
				self.spirit_list[index].show = true
			end

			if self.spirit_list[index].can_move ~= nil then
				self.spirit_list[index].can_move = true
			end
		elseif opera_type == "delete" then
			if self.spirit_list[index].loop_tweener ~= nil then
				self.spirit_list[index].loop_tweener:Pause()
			end

			if self["model_obj_" .. index] ~= nil and self.model_pos[index] ~= nil then
				self.model_pos[index] = self["model_obj_" .. index].transform.localPosition
				self.model_pos[index].dis = 0
			end

			if self.spirit_list[index].model then
				self.spirit_list[index].model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
			end

			if self.time_quest ~= nil and self.time_quest[index] ~= nil then
				GlobalTimerQuest:CancelQuest(self.time_quest[index])
			end

			if self.timer_list[index] ~= nil then
				CountDown.Instance:RemoveCountDown(self.timer_list[index])
				self.timer_list[index] = nil
			end

			if self.spirit_list[index].move_timer ~= nil then
				self.spirit_list[index].move_timer = 0
			end

			if self.spirit_list[index].can_move ~= nil then
				self.spirit_list[index].can_move = true
			end

			if self.spirit_list[index].show ~= nil then
				self.spirit_list[index].show = false
			end
		end

		-- if self["show_spirit_" .. index] ~= nil then
		-- 	self["show_spirit_" .. index]:SetValue(opera_type == "add" or false)
		-- 	--self.spirit_list[index].show = opera_type == "add" or false
		-- end
	end
end

function SpiritHomeView:FlushTop(index, state)
	if self.spirit_list[index] == nil or self.spirit_list[index].top == nil then
		return
	end

	local cfg = SpiritData.Instance:GetSpiritHomeInfoByIndex(index)
	if cfg == nil or next(cfg) == nil then
		return
	end

	if JING_LING_HOME_STATE.MY_IN_OTHER == state then
		self.spirit_list[index].top:SetActive(false)
	else
		self.spirit_list[index].top:SetActive(true)
		if self.spirit_list[index].btn_res ~= nil then
			-- local str_table = Language.JingLing.SpiritHomeTopBtnStr
			local str = state == 0 and "quick" or "PK"
			self.spirit_list[index].btn_res:SetAsset(ResPath.GetSpiritImage("btn_spirit_" .. str))
			-- self.spirit_list[index].btn_str:SetValue(str)
		end

		if self.spirit_list[index].box_res ~= nil then
			local cfg = SpiritData.Instance:GetSpiritHomeInfoByIndex(index)
			if cfg ~= nil then
				local box_color = SpiritData.Instance:GetSpiritBoxType(cfg.reward_times)
				self.spirit_list[index].box_res:SetAsset(ResPath.GetGuildBoxIcon(box_color, false))
			end
		end
	end
end

function SpiritHomeView:FlushBottom(index, state)
	if self.timer_list[index] ~= nil then
		CountDown.Instance:RemoveCountDown(self.timer_list[index])
		self.timer_list[index] = nil
	end

	if self.spirit_list[index] == nil or self.spirit_list[index].bottom == nil then
		return
	end

	local cfg = SpiritData.Instance:GetSpiritHomeInfoByIndex(index)
	if cfg == nil or next(cfg) == nil then
		return
	end

	if self.spirit_list[index].bottom_str == nil then
		return
	end

	if JING_LING_HOME_STATE.MY == state then
		local limlit = SpiritData.Instance:GetSpiritOtherCfgByName("home_reward_times_limit")
		if limlit == nil then
			return
		end

		if self.spirit_list[index].bottom_timer ~= nil then
			self.spirit_list[index].bottom_timer:SetValue(true)
		end

		if self.spirit_list[index].bottom_show_cap ~= nil then
			self.spirit_list[index].bottom_show_cap:SetValue(false)
		end

		if cfg.reward_times < limlit then
			local interval = SpiritData.Instance:GetSpiritOtherCfgByName("home_reward_interval")
			local total_time = cfg.reward_beging_time + interval - TimeCtrl.Instance:GetServerTime()
			--local total_time = (TimeCtrl.Instance:GetServerTime() - cfg.reward_beging_time) - (interval * cfg.reward_times)
			total_time = math.ceil(total_time)

			if self.spirit_list[index].bottom_timer_value ~= nil then
				self.spirit_list[index].bottom_timer_value = total_time
			end

			--if total_time > 0 then
				self.timer_list[index] = CountDown.Instance:AddCountDown(interval, 0.1, BindTool.Bind(self.UpdateBottom, self, index))
				--self.spirit_list[index].bottom:SetActive(true)
				--self.spirit_list[index].bottom_flag = -1
				--self:AdjustTopAndBot(index, true)
			--end
		else
			--self.spirit_list[index].bottom:SetActive(false)
			--self.spirit_list[index].bottom_flag = 1
			--self:AdjustTopAndBot(index, false)
			self.spirit_list[index].bottom_str:SetValue(Language.JingLing.SpiritHomeRewardLimlit)
		end
	elseif JING_LING_HOME_STATE.OTHER == state then
		if self.spirit_list[index].bottom_timer ~= nil then
			self.spirit_list[index].bottom_timer:SetValue(false)
		end

		if self.spirit_list[index].bottom_show_cap ~= nil then
			self.spirit_list[index].bottom_show_cap:SetValue(true)
		end

		if self.spirit_list[index].bottom_cap ~= nil then
			self.spirit_list[index].bottom_cap:SetValue(cfg.capability or 0)
		end

		--self.spirit_list[index].bottom:SetActive(true)
		--self.spirit_list[index].bottom_flag = 1
		--self:AdjustTopAndBot(index, true)
		--self.spirit_list[index].bottom_str:SetValue(string.format(Language.JingLing.HomeCapStr, cfg.capability or 0))
	elseif JING_LING_HOME_STATE.MY_IN_OTHER == state then
		--self.spirit_list[index].bottom:SetActive(false)
		--self.spirit_list[index].bottom_flag = -1
		--self:AdjustTopAndBot(index, false)
	end
end

function SpiritHomeView:ShowSpiritChat(index)
	if self.spirit_list[index] == nil or not self.spirit_list[index].show then
		return
	end

	if self.spirit_list[index].can_move ~= nil then
		self.spirit_list[index].can_move = false
	end


end

function SpiritHomeView:UpdateBottom(index, elapse_time, total_time)
	if self.spirit_list[index] ~= nil and self.spirit_list[index].bottom_str ~= nil and self.spirit_list[index].bottom_timer_value ~= nil then
		--local time_t = TimeUtil.Format2TableDHMS(math.floor(total_time - elapse_time))
		local time_value = 0
		local cfg = SpiritData.Instance:GetSpiritHomeInfoByIndex(index)
		if cfg == nil or next(cfg) == nil then
			return
		end

		time_value = TimeCtrl.Instance:GetServerTime() - cfg.last_get_time
		local time_t = TimeUtil.Format2TableDHMS(math.ceil(time_value))
		self.spirit_list[index].bottom_str:SetValue(string.format(Language.JingLing.NextRewardStr, time_t.hour, time_t.min, time_t.s))
	end

	if elapse_time - total_time >= 0 then
		if index ~= nil then
			self:CompleteBottom(index)
		end
	end
end

function SpiritHomeView:CompleteBottom(index)
	if self.timer_list[index] ~= nil then
		CountDown.Instance:RemoveCountDown(self.timer_list[index])
		self.timer_list[index] = nil
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	SpiritCtrl.Instance:SendJingLingHomeOperReq(JING_LING_HOME_REASON.JING_LING_HOME_REASON_DEF, main_role_vo.role_id)
end

function SpiritHomeView:ShowOtherStr()
	if self.other_str_obj == nil then
		return
	end

	if self.show_other_str ~= nil then
		self.show_other_str:SetValue(false)
	end

	local cfg = SpiritData.Instance:GetSpiritHomeInfoByIndex()
	if cfg == nil or cfg.name == nil then
		return
	end

	if self.other_tween ~= nil then
		self.other_tween:Pause()
	end

	self.other_str_obj.transform.localPosition = self.other_str_pos or Vector3(0, 0, 0)
	if self.other_str ~= nil then
		self.other_str:SetValue(string.format(Language.JingLing.SpiritHomeEnterOther, cfg.name))
	end

	if self.show_other_str ~= nil then
		self.show_other_str:SetValue(true)
	end
	-- if self.other_tween == nil then
	-- 	self.other_tween = self.other_str_obj.transform:DOLocalMoveY(100, 1)
	-- 	self.other_tween:SetEase(DG.Tweening.Ease.Linear)
	-- 	self.other_tween:OnComplete(function()
	-- 		if self.show_other_str ~= nil then
	-- 			self.show_other_str:SetValue(false)
	-- 		end
	-- 	end)
	-- else
	-- 	self.other_tween:Play()
	-- end

		self.other_tween = self.other_str_obj.transform:DOLocalMoveY(100, 1)
		self.other_tween:SetEase(DG.Tweening.Ease.Linear)
		self.other_tween:OnComplete(function()
			if self.show_other_str ~= nil then
				self.show_other_str:SetValue(false)
			end
		end)
end

function SpiritHomeView:AdjustTopAndBot(index, flag)
	-- if index == nil then
	-- 	return
	-- end

	-- if self.spirit_list[index] == nil then
	-- 	return
	-- end

	-- if self.spirit_list[index].top == nil or self.spirit_list[index].bottom == nil then
	-- 	return
	-- end

	-- if self.spirit_list[index].top_flag == nil or self.spirit_list[index].bottom_flag == nil then
	-- end

	-- local adjust_value = 10
	-- if (flag and self.spirit_list[index].top_flag == -1) or (not flag and self.spirit_list[index].top_flag >= 0) then
	-- 	local bottom_value = self.spirit_list[index].bottom_flag
	-- 	local transform = self.spirit_list[index].top.transform.localPosition
	-- 	self.spirit_list[index].top.transform.localPosition = Vector3(transform.x, transform.y + adjust_value * bottom_value , transform.z)
	-- 	self.spirit_list[index].top_flag = bottom_value + self.spirit_list[index].top_flag
	-- end
end

function SpiritHomeView:InitModel(index, res_id, state)
	self.spirit_list[index] = {}
	self.spirit_list[index].model = RoleModel.New("spirit_home_panel")
	self.spirit_list[index].model:SetDisplay(self["model_obj_" .. index].ui3d_display)
	self.spirit_list[index].show = true
	--移动时间
	self.spirit_list[index].move_timer = 0
	local ran_value = tonumber(string.format("%2d", math.random()))
	self.spirit_list[index].ran_time = math.random(MOVE_TIMER, MAX_MOVE_TIMER) + ran_value
	--是否可移动
	self.spirit_list[index].can_move = false
	self.spirit_list[index].res_id = res_id or 0
	self.spirit_list[index].state = state
	self.spirit_list[index].top_flag = 0
	self.spirit_list[index].bottom_flag = 0
	self.spirit_list[index].eff_pos = Vector3(0, 0, 0)
	self.spirit_list[index].bottom_timer_value = 0

	if self.birth_pos ~= nil then
		local pos = self.birth_pos.transform.localPosition
		--pos.x = pos.x + 100
		--self["model_obj_" .. index].transform:SetLocalPosition(pos.x, pos.y, pos.z)
		local borth_index = SpiritData.Instance:GetSpiritHinderList(nil, index, not SpiritData.Instance:GetIsMyHome())
		local pos_t = SpiritData.Instance:GetPosByIndex(borth_index)
		self["model_obj_" .. index].transform:SetLocalPosition(pos_t.x, pos_t.y, pos.z)

		-- if self.model_pos ~= nil and self.model_pos[index] ~= nil then
		-- 	self.model_pos[index] = {x = pos.x, y = pos.y, dis = 0}
		-- end

		if self.model_pos ~= nil and self.model_pos[index] ~= nil then
			self.model_pos[index] = {x = pos_t.x, y = pos_t.y, dis = 0}
		end
	end
	self.spirit_list[index].model:SetMainAsset(ResPath.GetSpiritModel(res_id))
	if self["show_spirit_" .. index] ~= nil then
		self["show_spirit_" .. index]:SetValue(true)
	end

	local function loadCall()
		if self.spirit_list[index].top == nil then
			UtilU3d.PrefabLoad("uis/views/spiritview_prefab", "SpiritHomeModelTop", function(obj)
				self.spirit_list[index].top = obj
				local root = self.spirit_list[index].model.draw_obj:GetPart(SceneObjPart.Main)
				local move_point = self.spirit_list[index].model.draw_obj
				local top = self.spirit_list[index].top
				top.transform:SetParent(self["model_obj_" .. index].transform, false)
				local point = move_point:GetAttachPoint(AttachPoint.UI)

				local variable_table = top:GetComponent(typeof(UIVariableTable))
				local event_table = top:GetComponent(typeof(UIEventTable))
				local ui_table = top:GetComponent(typeof(UINameTable))
				if variable_table then
					self.spirit_list[index].btn_res = variable_table:FindVariable("BtnRes")
					self.spirit_list[index].box_res = variable_table:FindVariable("BoxRes")
					self.spirit_list[index].show_chat_box = variable_table:FindVariable("ShowChatBox")
					self.spirit_list[index].chat_str= variable_table:FindVariable("ChatStr")
				end

				if event_table then
					event_table:ListenEvent("OpenBox", BindTool.Bind(self.ClickBox, self, index))
					event_table:ListenEvent("BoxOpera", BindTool.Bind(self.ClickBoxOpera, self, index))
				end

				if ui_table ~= nil then
					local box = ui_table:Find("Box")
					-- if point ~= nil and box ~= nil then
					-- 	local height = point.transform.localPosition.y
					-- 	local height_1 = box.transform:GetComponent(typeof(UnityEngine.RectTransform)).rect.height
					-- 	top.transform.localPosition = Vector3(0, height + height_1 / 2, 0)
						-- local box_trans = box.transform.localPosition
					-- 	self.spirit_list[index].eff_pos = Vector3(box_trans.x, box_trans.y + height_1 * 0.5, box_trans.z)
					-- end
					if point ~= nil then
						local uicamera = self["model_obj_" .. index].transform:FindHard("FitScale/UICamera"):GetComponent(typeof(UnityEngine.Camera))
						self.spirit_list[index].top.transform.localPosition = UIFollowTarget.CalculateScreenPosition(
						point.transform.position, uicamera, SpiritCtrl.Instance:GetSpiritCanvas(), self.spirit_list[index].top.transform.parent)
						local cur_pos = self.spirit_list[index].top.transform.localPosition
						self.spirit_list[index].top.transform.localPosition = Vector3((cur_pos.x + cur_pos.x / 2)+((cur_pos.x - cur_pos.x - cur_pos.x) - cur_pos.x /2), cur_pos.y + 130, 0)
					end
				end

				if state == JING_LING_HOME_STATE.MY_IN_OTHER then
					top:SetActive(false)
				else
					top:SetActive(true)
				end
				self:FlushTop(index, state)
			end)
		end

		if self.spirit_list[index].bottom == nil then
			UtilU3d.PrefabLoad("uis/views/spiritview_prefab", "SpiritHomeModelBottom", function(obj)
				self.spirit_list[index].bottom = obj
				local root = self.spirit_list[index].model.draw_obj:GetPart(SceneObjPart.Main)
				local move_point = self.spirit_list[index].model.draw_obj
				--local self.spirit_list[index].bottom = self.spirit_list[index].bottom
				self.spirit_list[index].bottom.transform:SetParent(self["model_obj_" .. index].transform, false)

				local variable_table = self.spirit_list[index].bottom:GetComponent(typeof(UIVariableTable))
				local event_table = self.spirit_list[index].bottom:GetComponent(typeof(UIEventTable))
				if variable_table then
					self.spirit_list[index].bottom_str = variable_table:FindVariable("Str")
					self.spirit_list[index].bottom_timer = variable_table:FindVariable("ShowTimer")
					self.spirit_list[index].bottom_show_cap = variable_table:FindVariable("ShowCap")
					self.spirit_list[index].bottom_cap = variable_table:FindVariable("CapValue")
				end
				local point = move_point:GetAttachPoint(AttachPoint.BuffBottom)
				if point ~= nil then
					local uicamera = self["model_obj_" .. index].transform:FindHard("FitScale/UICamera"):GetComponent(typeof(UnityEngine.Camera))
					self.spirit_list[index].bottom.transform.localPosition = UIFollowTarget.CalculateScreenPosition(
					point.transform.position, uicamera, SpiritCtrl.Instance:GetSpiritCanvas(), self.spirit_list[index].bottom.transform.parent)
					local cur_pos = self.spirit_list[index].bottom.transform.localPosition
					self.spirit_list[index].bottom.transform.localPosition = Vector3(cur_pos.x + 50, cur_pos.y -35, 0)
				end
				self:FlushBottom(index, state)
			end)
		end
	end

	self.spirit_list[index].model:SetLoadComplete(loadCall)
end

function SpiritHomeView:MoveSpirit(index)
	if self.spirit_list == nil or index == nil or self.spirit_list[index] == nil then
		return
	end

	if self.model_pos == nil or self.model_pos[index] == nil then
		return
	end

	local start_pos = self.model_pos[index]
	local start_index = SpiritData.Instance:GetIndexByPos(start_pos)
	--local end_index = SpiritData.Instance:GetMovePoint(start_index)
	local end_index = SpiritData.Instance:GetSpiritHinderList(start_index, index)
	if end_index == nil then
		return
	end

	local can_move = SpiritData.Instance:FindWay(start_index, end_index)
	if not can_move then
		return
	end


	local move_list = SpiritData.Instance:GetMovePathPoint(start_index, end_index)
	local timer = #move_list * 0.5
	if self.time_quest == nil then
		self.time_quest = {}
	end

	if self.time_quest[index] ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest[index])
	end

	self.spirit_list[index].model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	self.time_quest[index] = GlobalTimerQuest:AddDelayTimer(function()
			local item = self["model_obj_" .. index]
			local path = SpiritData.Instance:GetReadMoveList(move_list, item, start_pos)
			local move_call
			local call_num = 1
			local move_dir = 0
			local move_start_pos = start_pos
			local angle = 0
			move_call = function()
				if call_num <= #path then
					local tween = item.transform:DOLocalMove(path[call_num], 0.05)
					tween:SetEase(DG.Tweening.Ease.Linear)
					tween:OnComplete(move_call)
					self.spirit_list[index].loop_tweener = tween
					if call_num > 1 then
						move_start_pos = path[call_num - 1]
					end

					if move_list[call_num] ~= nil and move_list[call_num].dis ~= nil then
						local angle = 8 - move_list[call_num].dis < 0 and 0 or 8 - move_list[call_num].dis
						if call_num > 1 then
							self.spirit_list[index].model:SetRotation(Vector3(0, angle * 40, 0))
						end
					end

					call_num = call_num + 1
				else
					self.spirit_list[index].model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
					self.model_pos[index] = path[#path]
					--self.spirit_list[index].ran_time = math.random(MOVE_TIMER, MAX_MOVE_TIMER)
					local ran_value = tonumber(string.format("%2d", math.random()))
					self.spirit_list[index].ran_time = math.random(MOVE_TIMER, MAX_MOVE_TIMER) + ran_value
						self.spirit_list[index].move_timer = 0
					self.spirit_list[index].can_move = true
				end
			end

			move_call()
		end, 0)
end

function SpiritHomeView:Update(now_time, elapse_time)
	if self.spirit_list ~= nil then
		for i = 1, 5 do
			if self.spirit_list[i] ~= nil and self.spirit_list[i].show then
				if self.spirit_list[i].move_timer ~= nil and self.spirit_list[i].ran_time ~= nil then
					self.spirit_list[i].move_timer = self.spirit_list[i].move_timer + elapse_time
					if self.spirit_list[i].move_timer > self.spirit_list[i].ran_time and self.spirit_list[i].can_move then
						self.spirit_list[i].can_move = false
						self:MoveSpirit(i)
					end
				end
			end
		end
	end
end

function SpiritHomeView:ShowAddReward()
	local reward_list = SpiritData.Instance:GetQuickGetList()
	if reward_list == nil or reward_list.index == nil then
		return
	end

	local show_count = #reward_list.item_list
	local show_time = show_count >= ADD_MAX and ADD_MAX or show_count
	if self.spirit_list[reward_list.index] == nil then
		return
	end

	if self.spirit_list[reward_list.index].eff_pos == nil or self.spirit_list[reward_list.index].top == nil then
		return
	end

	for i = 1, ADD_MAX do
		if i <= show_time then
			self.add_finish_list[i] = 1
		else
			self.add_finish_list[i] = 0
		end
	end

	for i = 1, show_time do
		local item = reward_list.item_list[i]
		if item ~= nil then
			self:ShowFlyIcon(self.spirit_list[reward_list.index].top, self.spirit_list[reward_list.index].eff_pos, item.item_id, i)
		end
	end
end

function SpiritHomeView:ShowFlyIcon(begin_obj, end_pos, item_id, index)
	GameObjectPool.Instance:SpawnAsset("uis/views/spiritview_prefab", "SpiritRewardIcon", function(obj)
			local variable_table = obj:GetComponent(typeof(UIVariableTable))
			self.add_item_list[obj] = obj
			if variable_table then
				local image = variable_table:FindVariable("Image")
				image:SetAsset(ResPath.GetItemIcon(item_id))
			end
			obj.transform:SetParent(begin_obj.transform, false)
			--local obj_rect = end_obj:GetComponent(typeof(UnityEngine.RectTransform))
			--获取指引按钮的屏幕坐标
			--local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(self.uicamera, obj_rect.position)

			--转换屏幕坐标为本地坐标
			--local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(begin_obj.rect, screen_pos_tbl, self.uicamera, Vector2(0, 0))
			obj.transform.localPosition = Vector3(end_pos.x, end_pos.y + 100, end_pos.z)
			--local end_position = Vector3(local_pos_tbl.x, local_pos_tbl.y, 0)
			local tween = obj.transform:DOLocalMove(end_pos, 0.2 * index)
			tween:SetEase(DG.Tweening.Ease.Linear)
			tween:OnComplete(BindTool.Bind3(self.OnMoveChouEnd, self, obj, index))
		end)
end

function SpiritHomeView:OnMoveChouEnd(obj, index)
	if not IsNil(obj) then
		self.add_item_list[obj] = nil
		GameObject.Destroy(obj)

		self.add_finish_list[index] = 0
	end

	local check_show = true
	for k,v in pairs(self.add_finish_list) do
		if v == 1 then
			check_show = false
			break
		end
	end

	if check_show then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_RANK_JINYIN_QUICK_REWARD)
	end
end

function SpiritHomeView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if "all" == k then
			self:FlushHomeRender()
			self:FlushSpiritModel()
			self:FlushPreviewPos()

			if self.is_show_back ~= nil then
				self.is_show_back:SetValue(not SpiritData.Instance:GetIsMyHome())
			end

			if self.show_preview_chat ~= nil then
				self.show_preview_chat:SetValue(false)
			end

			if not SpiritData.Instance:GetIsMyHome() then
				if self.fight_render ~= nil then
					self.fight_render:SetData(SpiritData.Instance:GetEnterOtherSpirit())
				end
			end

			if self.harvert_limlit ~= nil then
				local cur, max = SpiritData.Instance:GetSpiritHarvertLimlit("my")
				local color = cur > 0 and TEXT_COLOR.GREEN or TEXT_COLOR.WHITE
				self.harvert_limlit:SetValue(string.format(Language.JingLing.SpiritHomeMyHarvertTip, cur, max))
			end

		elseif "enter_other_home" == k then
			if self.show_preview_chat ~= nil then
				self.show_preview_chat:SetValue(true)
			end

			if self.home_flag ~= nil then
				self.home_flag:SetValue(false)
			end

			if self.show_btn_explore ~= nil then
				self.show_btn_explore:SetValue(false)
			end

			self:ShowOtherStr()

			if self.show_btn_revenge ~= nil then
				self.show_btn_revenge:SetValue(false)
			end
			self:FlushSpiritModel(true)

			if self.is_show_back ~= nil then
				self.is_show_back:SetValue(not SpiritData.Instance:GetIsMyHome())
			end

			if self.fight_render ~= nil then
				self.fight_render:SetData(SpiritData.Instance:GetEnterOtherSpirit())
			end

			local cur = 0
			local max = 0
			if self.my_harvert ~= nil then
				cur, max = SpiritData.Instance:GetSpiritHarvertLimlit("my")
				self.my_harvert:SetValue(string.format(Language.JingLing.SpiritHomeMyHarvertTip2, cur, max))
			end

			if self.other_harvert ~= nil then
				cur, max = SpiritData.Instance:GetSpiritHarvertLimlit("enemy")
				self.other_harvert:SetValue(string.format(Language.JingLing.SpiritHomeOtherHarvertTip, cur, max))
			end

			if self.harvert_limlit ~= nil then
				local cur, max = SpiritData.Instance:GetSpiritHarvertLimlit("my")
				local color = cur > 0 and TEXT_COLOR.GREEN or TEXT_COLOR.WHITE
				self.harvert_limlit:SetValue(string.format(Language.JingLing.SpiritHomeMyHarvertTip, cur, max))
			end

			self:FlushPreviewPos()
		elseif "flush_plunder" == k then
			if self.plunder_state then
				if self.list_view ~= nil then
					self.list_view.scroller:ReloadData(0)
				end

				if self.harvert_limlit ~= nil then
					local cur, max = SpiritData.Instance:GetSpiritHarvertLimlit("my")
					local color = cur > 0 and TEXT_COLOR.GREEN or TEXT_COLOR.WHITE
					self.harvert_limlit:SetValue(string.format(Language.JingLing.SpiritHomeMyHarvertTip, cur, max))
				end
			end
		elseif "add_reward" == k then
			self:ShowAddReward()
		elseif "change_fight_choose" == k then
			if self.fight_render ~= nil then
				self.fight_render:SetData(SpiritData.Instance:GetEnterOtherSpirit())
			end
			self:FlushPreviewPos()
		elseif "flush_cap" == k then
			self:FlushHomeRender()
		end
	end
end

function SpiritHomeView:FlushPreviewPos()
	local is_my = SpiritData.Instance:GetIsMyHome()

	if self.btn_preview_obj ~= nil and self.btn_preview_pos ~= nil then
		if not is_my then
			self.btn_preview_obj.transform.localPosition = Vector3(self.btn_preview_pos.x, self.btn_preview_pos.y, self.btn_preview_pos.z)
		else
			self.btn_preview_obj.transform.localPosition = self.btn_preview_pos
		end
	end

	if self.question_image_obj ~= nil and self.question_image_pos ~= nil then
		if not is_my then
			self.question_image_obj.transform.localPosition = Vector3(self.question_image_pos.x, self.question_image_pos.y - 437, self.question_image_pos.z)
		else
			self.question_image_obj.transform.localPosition = self.question_image_pos
		end
	end

	if self.chat_preview_obj ~= nil and self.chat_preview_pos ~= nil then
		if not is_my then
			self.chat_preview_obj.transform.localPosition = Vector3(self.chat_preview_pos.x, self.chat_preview_pos.y, self.chat_preview_pos.z)
		else
			self.chat_preview_obj.transform.localPosition = self.chat_preview_pos
		end
	end

	if self.show_home_name ~= nil then
		if not is_my and self.home_name ~= nil then
			self.home_name:SetValue(string.format("%s%s",SpiritData.Instance:GetSpiritHomeName(),Language.JingLing.SpiritHomeNameTail))
		end

		self.show_home_name:SetValue(not is_my)
	end
end

function SpiritHomeView:FlushSpiritModel(change_pos)
	local cfg = SpiritData.Instance:GetSpiritHomeModelCfg()
	for k,v in pairs(cfg) do
		if v ~= nil then
			self:ChangeSpirit(v.index, v.res_id, v.state, change_pos)
		end
	end
end

function SpiritHomeView:FlushHomeRender()
	local cfg = SpiritData.Instance:GetSpiritHomeInfoByIndex()
	--local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local flag = SpiritData.Instance:GetIsMyHome()

	if self.home_flag ~= nil then
		self.home_flag:SetValue(flag)
	end

	if self.show_btn_explore ~= nil then
		self.show_btn_explore:SetValue(flag)
	end

	if self.show_btn_revenge ~= nil then
		self.show_btn_revenge:SetValue(flag)
	end

	if self.render_list ~= nil and cfg ~= nil and cfg.item_list ~= nil then
		for k,v in pairs(self.render_list) do
			if v ~= nil then
				v:SetData(cfg.item_list[k] or {})
			end
		end
	end
end

------------------------------------------------------------------
SpiritHomeRender = SpiritHomeRender or BaseClass(BaseRender)
function SpiritHomeRender:__init(instance)
	self.is_show_choose = self:FindVariable("IsShowChoose")

	self.choose_res = self:FindVariable("ChoosePath")

	self.cap_str = self:FindVariable("CapStr")
	self.btn_str = self:FindVariable("BtnStr")
	self.show_red = self:FindVariable("ShowRed")

	self.cell_obj = self:FindObj("Cell")
	if self.cell_obj ~= nil then
		self.item_cell = ItemCell.New()
		self.item_cell:SetInstanceParent(self.cell_obj)
	end

	self:ListenEvent("SpiritOpera", BindTool.Bind(self.OnClickOpera, self))
	self:ListenEvent("OpenChoose", BindTool.Bind(self.OnClickOpera, self))

	self.is_lock = true
end

function SpiritHomeRender:__delete()
	if self.item_cell ~= nil then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.is_show_choose = nil
	self.choose_res = nil
	self.cap_str = nil
	self.btn_str = nil
	self.cell_obj = nil
	self.show_red = nil

	self.is_lock = true
end

function SpiritHomeRender:OnClickOpera()
	if self.data ~= nil and self.data.item_id ~= nil and self.data.item_id > 0 then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		if self.index ~= nil then
			local cfg = SpiritData.Instance:GetSpiritHomeInfoByIndex(self.index)
			local limlit_timer = SpiritData.Instance:GetSpiritOtherCfgByName("home_reward_times_limit") or 0
			if cfg == nil or next(cfg) == nil then
				return
			end

			if limlit_timer - cfg.reward_times <= 0 then
				SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SpiritHomeRewardMax)
				return
			end
			SpiritCtrl.Instance:SendJingLingHomeOperReq(JING_LING_HOME_OPER_TYPE.JING_LING_HOME_OPER_TYPE_OUT, main_role_vo.role_id,
					 self.index - 1)
			end

		return
	end

	if self.index ~= nil then
		TipsCtrl.Instance:OpenSpiritHomeSendView(self.index)
	end
end

function SpiritHomeRender:OnClickOpen()
	-- if self.index ~= nil then
	-- 	TipsCtrl.Instance:OpenSpiritHomeSendView(self.index)
	-- end
end

function SpiritHomeRender:SetData(data)
	self.data = data
	self:Flush()
end

function SpiritHomeRender:OnFlush()
	if self.data == nil or next(self.data) == nil then
		return
	end

	self:FlushValue()
end

function SpiritHomeRender:SetIndex(index)
	self.index = index
end

function SpiritHomeRender:FlushValue()
	if self.is_show_choose ~= nil then
		self.is_show_choose:SetValue(self.data.item_id and self.data.item_id <= 0)
	end

	if self.cap_str ~= nil then
		self.cap_str:SetValue(string.format(Language.JingLing.HomeCapStr, self.data.capability or 0))
	end

	if self.btn_str ~= nil then
		local str_t = Language.JingLing
		local str = (self.data.item_id and self.data.item_id <= 0) and str_t.BtnSreed or str_t.SpiritHomeSendBtnStr[2]
		self.btn_str:SetValue(str)
	end

	if self.item_cell ~= nil then
		local real_data = SpiritData.Instance:GetJingLingDataById(self.data.item_id)
		self.item_cell:SetData(real_data)
	end

	if self.show_red ~= nil then
		self.show_red:SetValue(SpiritData.Instance:GetHasHomeRenderRed(self.index))
	end
end





-----------------------------------------------------------------------------
SpiritHomePeopleRender = SpiritHomePeopleRender or BaseClass(BaseRender)

function SpiritHomePeopleRender:__init()
	self.is_select = false

	self.plunder_str = self:FindVariable("Plunder")
	self.name_str = self:FindVariable("Name")
	self.show_img_rank = self:FindVariable("ShowImgRank")
	self.rank_text = self:FindVariable("TextRank")
	self.rank_img = self:FindVariable("RankRes")
	self.icon_img = self:FindVariable("IconRes")
	self.def_res = self:FindVariable("DefRes")
	self.head_flag = self:FindVariable("HeadFlag")

	self.role_head = self:FindObj("RoleHead")

	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClickItem, self))
end

function SpiritHomePeopleRender:__delete()
	self.is_select = false

	self.plunder_str = nil
	self.name_str = nil
	self.show_img_rank = nil
	self.rank_text = nil
	self.rank_img = nil
	self.icon_img = nil
	self.role_head = nil
	self.def_res = nil
	self.head_flag = nil
end

function SpiritHomePeopleRender:OnClickItem()
	if self.data == nil or self.data.role_id == nil then
		return
	end

	if self.index ~= nil then
		SpiritCtrl.Instance:SetSelectPlunderIndex(self.index)
	end
	SpiritCtrl:SendJingLingHomeOperReq(JING_LING_HOME_OPER_TYPE.JING_LING_HOME_OPER_TYPE_GET_INFO, self.data.role_id)
end

function SpiritHomePeopleRender:SetIndex(index)
	self.index = index
end

function SpiritHomePeopleRender:GetIndex()
	return self.index
end

function SpiritHomePeopleRender:SetData(data)
	self.data = data
	self:Flush()
end

function SpiritHomePeopleRender:FlushAll(data)
	if self.name_str ~= nil then
		self.name_str:SetValue(data.name)
	end

	local rank = self.index and self.index + 1 or 0
	if self.show_img_rank ~= nil then
		self.show_img_rank:SetValue(rank <= 3)
	end

	if self.rank_text ~= nil and rank > 3 then
		self.rank_text:SetValue(rank)
	end

	if self.rank_img ~= nil and rank <= 3 then
		self.rank_img:SetAsset(ResPath.GetRankIcon(rank))
	end

	CommonDataManager.NewSetAvatar(data.role_id, self.head_flag, self.def_res, self.role_head, data.sex, data.prof, false)

end

function SpiritHomePeopleRender:OnFlush(param_t)
	if self.data == nil or next(self.data) == nil then
		return
	end

	self:FlushAll(self.data)
end

function SpiritHomePeopleRender:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function SpiritHomePeopleRender:SetSelctState(state)
	self.root_node.toggle.isOn = state
	-- self.is_select = state
end


-----------------------------------------------------
------------------------------------------------------------------
SpiritHomeOtherRender = SpiritHomeOtherRender or BaseClass(BaseRender)
function SpiritHomeOtherRender:__init(instance)
	self.is_show_choose = self:FindVariable("IsShowChoose")

	self.choose_res = self:FindVariable("ChoosePath")

	self.cap_str = self:FindVariable("CapStr")
	self.btn_str = self:FindVariable("BtnStr")
	-- self.my_harvert = self:FindVariable("MyHarvert")
	-- self.other_harvert = self:FindVariable("OtherHarvert")

	self.cell_obj = self:FindObj("Cell")
	if self.cell_obj ~= nil then
		self.item_cell = ItemCell.New()
		self.item_cell:SetInstanceParent(self.cell_obj)
	end

	self:ListenEvent("SpiritOpera", BindTool.Bind(self.OnClickOpera, self))
	self:ListenEvent("OpenChoose", BindTool.Bind(self.OnClickOpen, self))

	self.is_lock = true
end

function SpiritHomeOtherRender:__delete()
	if self.item_cell ~= nil then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.is_show_choose = nil
	self.choose_res = nil
	self.cap_str = nil
	self.btn_str = nil
	self.cell_obj = nil
	--self.my_harvert = nil
	--self.other_harvert = nil

	self.is_lock = true
end

function SpiritHomeOtherRender:OnClickOpera()
	-- local put_index = nil
	-- if self.index ~= nil then
	-- 	TipsCtrl.Instance:OpenSpiritHomeSendView(self.index)
	-- end
	TipsCtrl.Instance:OpenSpiritHomeSendView()
end

function SpiritHomeOtherRender:OnClickOpen()
	-- if self.index ~= nil then
	-- 	TipsCtrl.Instance:OpenSpiritHomeSendView(self.index)
	-- end
	TipsCtrl.Instance:OpenSpiritHomeSendView()
end

function SpiritHomeOtherRender:SetData(data)
	self.data = data
	self:Flush()
end

function SpiritHomeOtherRender:OnFlush()
	if self.data == nil then
		return
	end

	self:FlushValue()
end

function SpiritHomeOtherRender:SetIndex(index)
	self.index = index
end

function SpiritHomeOtherRender:FlushValue()
	if self.is_show_choose ~= nil then
		local show_choose = true
		if self.data.item_id ~= nil and self.data.item_id > 0 then
			show_choose = false
		end
		self.is_show_choose:SetValue(show_choose)
	end

	if self.cap_str ~= nil then
		self.cap_str:SetValue(string.format(Language.JingLing.HomeCapStr, self.data.cap or 0))
	end

	if self.btn_str ~= nil then
		local str_t = Language.JingLing
		local str = (self.data.item_id and self.data.item_id <= 0) and str_t.BtnSreed or str_t.BtnReplace
		self.btn_str:SetValue(str)
	end

	if self.item_cell ~= nil then
		self.item_cell:SetData({item_id = self.data.item_id or 0})
	end

	-- local cur = 0
	-- local max = 0
	-- if self.my_harvert ~= nil then
	-- 	cur, max = SpiritData.Instance:GetSpiritHarvertLimlit("my")
	-- 	self.my_harvert:SetValue(string.format(Language.JingLing.SpiritHomeMyHarvertTip, cur, max))
	-- end

	-- if self.other_harvert ~= nil then
	-- 	cur, max = SpiritData.Instance:GetSpiritHarvertLimlit("enemy")
	-- 	self.other_harvert:SetValue(string.format(Language.JingLing.SpiritHomeOtherHarvertTip, cur, max))
	-- end
end