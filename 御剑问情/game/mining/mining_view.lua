require("game/mining/mining_mine_view")
require("game/mining/mining_sea_view")
require("game/mining/mining_challenge_view")

MiningView = MiningView or BaseClass(BaseView)

function MiningView:__init()
	self.ui_config = {"uis/views/mining_prefab","MiningView"}
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	-- self.def_index = TabIndex.mining_mine
end

function MiningView:LoadCallBack()
	--监听UI事件
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("OpenChallengeView", BindTool.Bind(self.OpenChallengeView, self))
	self:ListenEvent("OpenMiningMineView", BindTool.Bind(self.OpenMiningMineView, self))
	self:ListenEvent("OpenMiningSeaView", BindTool.Bind(self.OpenMiningSeaView, self))
	-- self:ListenEvent("AddGold", BindTool.Bind(self.HandleAddGold, self))

	self.mining_mine_content = self:FindObj("MiningView")
	self.mining_sea_content = self:FindObj("SeaView")
   	self.mining_challenge_content = self:FindObj("ChallengeView")

	--红点
	self.red_point_list = {
		[RemindName.MiningMine] = self:FindVariable("MiningRedPoint"),
		[RemindName.MiningSea] = self:FindVariable("SeaRedPoint"),
		[RemindName.MiningChallenge] = self:FindVariable("ChallengeRedPoint"),
	}

	self.mining_toggle = self:FindObj("MiningToggle")
	self.sea_toggle = self:FindObj("SeaToggle")
	self.challenge_toggle = self:FindObj("ChallengToggle")

	self.mining_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, TabIndex.mining_mining))
	self.sea_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, TabIndex.mining_sea))
	self.challenge_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, TabIndex.mining_challenge))

	self:InitTab()

	--引导用按钮
	self.btn_close = self:FindObj("BtnClose")

	-- self.gold = self:FindVariable("Gold")
	-- self.bind_gold = self:FindVariable("BindGold")

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.MiningView, BindTool.Bind(self.GetUiCallBack, self))

	-- 功能开启
	self.event_quest = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowOrHideTab, self))

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

--游戏中被删除时,退出游戏时也会调用
function MiningView:ReleaseCallBack()
	if self.mining_mine_view then
		self.mining_mine_view:CloseCallBack()
		self.mining_mine_view:DeleteMe()
		self.mining_mine_view = nil
	end

	if self.mining_sea_view then
		self.mining_sea_view:CloseCallBack()
		self.mining_sea_view:DeleteMe()
		self.mining_sea_view = nil
	end

	if self.mining_challenge_view then
		self.mining_challenge_view:DeleteMe()
		self.mining_challenge_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.event_quest then
		GlobalEventSystem:UnBind(self.event_quest)
	end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.MiningView)
	end

	-- 清理变量和对象
	self.mining_toggle = nil
	self.sea_toggle = nil
	self.challenge_toggle = nil
	self.btn_close = nil
	self.red_point_list = nil
	self.challenge_toggle = nil
	-- self.gold = nil
	-- self.bind_gold = nil
	self.mining_btn_challenge = nil
end

function MiningView:ShowOrHideTab()
	if self:IsOpen() then
		--[[local show_list = {}
		local open_fun_data = OpenFunData.Instance
		show_list[1] = open_fun_data:CheckIsHide("mining_mine")
		show_list[2] = open_fun_data:CheckIsHide("mining_sea")

		self.mining_toggle:SetActive(show_list[1])
		self.sea_toggle:SetActive(show_list[2])
		]]
		self.challenge_toggle:SetActive(OpenFunData.Instance:CheckIsHide("mining_challenge"))
	end
end

function MiningView:OpenCallBack()
	--开始引导
	FunctionGuide.Instance:TriggerGuideByName("mining_challenge")

	self:ShowOrHideTab()
	for k,v in pairs(self.red_point_list) do
		v:SetValue(RemindManager.Instance:GetRemind(k))
	end
	if self.mining_toggle.toggle.isOn then
		MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_MINING_INFO)
		if self.mining_mine_view then
			-- self.mining_mine_view:OpenCallBack()
		end
	elseif self.sea_toggle.toggle.isOn then
		MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_SEA_MINING_INFO)
		if self.mining_sea_view then
			self.mining_sea_view:OpenCallBack()
		end
	elseif self.challenge_toggle.toggle.isOn then
		if self.mining_challenge_view then
			-- self.mining_challenge_view:OpenCallBack()
		end
	end
end

function MiningView:CloseCallBack()
	FunctionGuide.Instance:DelWaitGuideListByName("mining_challenge")

	if self.mining_challenge_view then
		self.mining_challenge_view:CloseCallBack()
	end

	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function MiningView:RemindChangeCallBack(key, value)
	if self.red_point_list[key] then
		self.red_point_list[key]:SetValue(value > 0)
	end
end

function MiningView:CloseView()
	self.show_index = -1
	self:Close()
end

function MiningView:ToggleChange(index, is_On)
	-- self:AsyncLoadView(index)
	if is_On then
		if index == TabIndex.mining_mining then
			RemindManager.Instance:AddNextRemindTime(RemindName.MiningMineRob, nil, RemindName.MiningMine)
		elseif index == TabIndex.mining_sea then
			RemindManager.Instance:AddNextRemindTime(RemindName.MiningSeaRob, nil, RemindName.MiningSea)
		elseif index == TabIndex.mining_challenge then
			RemindManager.Instance:AddNextRemindTime(RemindName.MiningChallenge, nil)
		end
		if index == self.show_index then
			return
		end

		if self.show_index == TabIndex.mining_mining then
			if self.mining_mine_view then
				self.mining_mine_view:CloseCallBack()
			end
		elseif self.show_index == TabIndex.mining_sea then
			if self.mining_sea_view then
				self.mining_sea_view:CloseCallBack()
			end
		end
		self.show_index = index
		if index == TabIndex.mining_mining then
			MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_MINING_INFO)
			if self.mining_mine_view then
				self.mining_mine_view:OpenCallBack()
			end
		elseif index == TabIndex.mining_sea then
			MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_SEA_MINING_INFO)
			if self.mining_sea_view then
				self.mining_sea_view:OpenCallBack()
			end
		elseif index == TabIndex.mining_challenge then
			if self.mining_challenge_view then
				self.mining_challenge_view:OpenCallBack()
			end
		end
	end
end

function MiningView:AsyncLoadView(index)
	if index == TabIndex.mining_mining and not self.mining_mine_view then
		UtilU3d.PrefabLoad("uis/views/mining_prefab", "MiningContentView",
			function(obj)
				obj.transform:SetParent(self.mining_mine_content.transform, false)
				obj = U3DObject(obj)
				self.mining_mine_view = MiningMineView.New(obj)
			end)
	end
	if index == TabIndex.mining_sea and not self.mining_sea_view then
		UtilU3d.PrefabLoad("uis/views/mining_prefab", "SeaContentView",
			function(obj)
				obj.transform:SetParent(self.mining_sea_content.transform, false)
				obj = U3DObject(obj)
				self.mining_sea_view = MiningSeaView.New(obj)
			end)
	end
	if index == TabIndex.mining_challenge and not self.mining_challenge_view then
		UtilU3d.PrefabLoad("uis/views/mining_prefab", "ChallengeView",
			function(obj)
				obj.transform:SetParent(self.mining_challenge_content.transform, false)
				obj = U3DObject(obj)
				self.mining_challenge_view = MiningChallengeView.New(obj)
				self.mining_challenge_view:OpenCallBack()
				self.mining_btn_challenge = self.mining_challenge_view:GetMiningBtnChallenge()
			end)
	end
end
--实际刷新的函数
local doFlushView =
{
	[TabIndex.mining_mining] = function(self)
		if nil == self.mining_toggle then return end

		self.mining_toggle.toggle.isOn = true
		if self.mining_mine_view then
			self.mining_mine_view:OpenCallBack()
		end
	end,
	[TabIndex.mining_sea] = function(self)
		if nil == self.sea_toggle then return end

		self.sea_toggle.toggle.isOn = true
		if self.mining_sea_view then
			self.mining_sea_view:OpenCallBack()
		end
	end,
	[TabIndex.mining_challenge] = function(self)
		if nil == self.challenge_toggle then return end

		self.challenge_toggle.toggle.isOn = true
		if self.mining_challenge_view then
			self.mining_challenge_view:Flush()
		end
	end,
}

--决定显示那个界面
function MiningView:ShowIndexCallBack(index)
	print_log(index)
	self:AsyncLoadView(index)
	if index == 0 or nil then
		index = TabIndex.mining_sea
	end

	if index == TabIndex.mining_challenge then
		if self.mining_challenge_view then
			self.mining_challenge_view:OpenCallBack()
		end
	end

	if index == TabIndex.mining_sea then
		if self.mining_sea_view then
			self.mining_sea_view:OpenCallBack()
		end
	end

	if index == TabIndex.mining_mining then
		if self.mining_mine_view then
			self.mining_mine_view:OpenCallBack()
		end
	end
	
	local func = doFlushView[index]
	if func ~= nil then
		func(self)
	end
end

--初始化图标
function MiningView:InitTab()
	self.mining_toggle:SetActive(false)
	self.sea_toggle:SetActive(false)
	self.challenge_toggle:SetActive(false)
end

function MiningView:OnChangeToggle(index)
	local func = doFlushView[index]
	if func ~= nil then
		func(self)
	end
end

function MiningView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end

	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == self.show_index then
			return NextGuideStepFlag
		end
		if index == TabIndex.mining_mining then
			if self.mining_toggle.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.mining_mining)
				return self.mining_toggle, callback
			end
		elseif index == TabIndex.mining_sea then
			if self.sea_toggle.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.mining_sea)
				return self.sea_toggle, callback
			end
		elseif index == TabIndex.mining_challenge then
			if self.challenge_toggle.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.mining_challenge)
				return self.challenge_toggle, callback
			end
		end
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end

	return nil
end

function MiningView:OpenChallengeView()
	self:ShowIndex(TabIndex.mining_challenge)
end

function MiningView:OpenMiningMineView()
	self:ShowIndex(TabIndex.mining_mining)
end

function MiningView:OpenMiningSeaView()
	self:ShowIndex(TabIndex.mining_sea)
end

function MiningView:OnFlush(param_list)
	local cur_index = self:GetShowIndex()
	for k,v in pairs(param_list) do
		if k == "all" then
			local func = doFlushView[cur_index]
			if func ~= nil then
				func(self)
			end
		elseif k == "record_list" then
			if cur_index == TabIndex.mining_mining then
				if self.mining_mine_view then
					self.mining_mine_view:UpdataRecordList()
				end
			elseif cur_index == TabIndex.mining_sea then
				if self.mining_sea_view then
					self.mining_sea_view:UpdataRecordList()
				end
			end
		elseif k == "record_red" then
			if cur_index == TabIndex.mining_mining then
				if self.mining_mine_view then
					self.mining_mine_view:UpdataRecordRed()
				end
			elseif cur_index == TabIndex.mining_sea then
				if self.mining_sea_view then
					self.mining_sea_view:UpdataRecordRed()
				end
			end
		end
	end
end

-- function MiningView:PlayerDataChangeCallback(attr_name, value, old_value)
-- 	local vo = GameVoManager.Instance:GetMainRoleVo()
-- 	if attr_name == "gold" then
-- 		local count = vo.gold
-- 		if count > 99999 and count <= 99999999 then
-- 			count = count / 10000
-- 			count = math.floor(count)
-- 			count = count .. Language.Common.Wan
-- 		elseif count > 99999999 then
-- 			count = count / 100000000
-- 			count = math.floor(count)
-- 			count = count .. Language.Common.Yi
-- 		end
-- 		self.gold:SetValue(count)
-- 	elseif attr_name == "bind_gold" then
-- 		local count = vo.bind_gold
-- 		if count > 99999 and count <= 99999999 then
-- 			count = count / 10000
-- 			count = math.floor(count)
-- 			count = count .. Language.Common.Wan
-- 		elseif count > 99999999 then
-- 			count = count / 100000000
-- 			count = math.floor(count)
-- 			count = count .. Language.Common.Yi
-- 		end
-- 		self.bind_gold:SetValue(count)
-- 	end
-- end

function MiningView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

----------------------------------------------------------------------------
--RecordListClientItem
----------------------------------------------------------------------------

RecordListClientItem = RecordListClientItem or BaseClass(BaseCell)

function RecordListClientItem:__init()
	-- 获取变量
	self.text_name = self:FindVariable("text_name")
end

function RecordListClientItem:__delete()
	self.text_name = nil
	self.data = nil
end

function RecordListClientItem:OnFlush()
	if not self.data then return end

	if self.data.type == -1 then
		self.text_name:SetValue("")
	else
		local name = ""
		local info_data = nil
		if self.data.type == MINING_VIEW_TYPE.MINE then
			info_data = MiningData.Instance:GetMiningMineCfg(self.data.quality)
		elseif self.data.type == MINING_VIEW_TYPE.SEA then
			info_data = MiningData.Instance:GetMiningSeaCfg(self.data.quality)
		end

		if info_data ~= nil then
			name = info_data.name
		end
		local color = MiningData.Instance:GetMiningNameColor(self.data.quality)
		local name_str  = "<color='".. color .. "'>" .. name .. "</color>"
		self.text_name:SetValue(string.format(Language.Mining.RecordClientName, self.data.rober_name, self.data.been_rob_name, name_str))
	end
end