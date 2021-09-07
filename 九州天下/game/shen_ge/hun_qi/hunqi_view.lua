require("game/shen_ge/hun_qi/hunqi_content_view")
require("game/shen_ge/hun_qi/damo_content_view")
require("game/shen_ge/hun_qi/baozang_content_view")
require("game/shen_ge/hun_qi/hunyin_content_view")
require("game/shen_ge/hun_qi/gather_content_view")

HunQiView = HunQiView or BaseClass(BaseView)
function HunQiView:__init()
	self.ui_config = {"uis/views/hunqiview", "HunQiView"}
	self:SetMaskBg()
	self.play_audio = true
	--self.full_screen = true
	self.discount_close_time = 0
	self.discount_index = 0
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function HunQiView:__delete()

end

function HunQiView:ReleaseCallBack()
	if self.hunqi_content_view then
		self.hunqi_content_view:DeleteMe()
		self.hunqi_content_view = nil
	end

	if self.damo_content_view then
		self.damo_content_view:DeleteMe()
		self.damo_content_view = nil
	end

	if self.baozang_content_view then
		self.baozang_content_view:DeleteMe()
		self.baozang_content_view = nil
	end

	if self.hunyin_content_view then
		self.hunyin_content_view:DeleteMe()
		self.hunyin_content_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.discount_timer then
		GlobalTimerQuest:CancelQuest(self.discount_timer)
		self.discount_timer = nil
	end

	if self.gather_content_view then
		self.gather_content_view:DeleteMe()
		self.gather_content_view = nil
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	self.tab_hunqi = nil
	self.tab_damo = nil
	self.tab_baozang = nil
	self.tab_hunyin = nil
	self.tab_total_inlay = nil
	self.tab_lingshu_update = nil
	self.bind_gold = nil
	self.gold = nil
	self.show_bipin_icon = nil
	self.discount_time = nil
	self.red_point_list = nil
	self.is_hunyin_open = nil
	self.open_trigger_list = nil
	self.tab_gather = nil
	if self.event_quest then
		GlobalEventSystem:UnBind(self.event_quest)
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end
end

function HunQiView:LoadCallBack()
	self:ListenEvent("OpenHunQi", BindTool.Bind(self.OpenHunQi, self))
	self:ListenEvent("OpenDaMo", BindTool.Bind(self.OpenDaMo, self))
	self:ListenEvent("OpenBaoZang", BindTool.Bind(self.OpenBaoZang, self))
	self:ListenEvent("OpenHunYin", BindTool.Bind(self.OpenHunYin, self))
	self:ListenEvent("OpenGather", BindTool.Bind(self.OpenGather, self))
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("HandleAddGold", BindTool.Bind(self.HandleAddGold, self))
	self:ListenEvent("OnClickBiPin", BindTool.Bind(self.OnClickBiPin, self))
	self:ListenEvent("OnClickTotalInlay", BindTool.Bind(self.OnClickTotalInlay, self))
	self:ListenEvent("OnClickLingshuUpdate", BindTool.Bind(self.OnClickLingshuUpdate, self))

	self.show_bipin_icon = self:FindVariable("ShowBiPingIcon")
	self.discount_time = self:FindVariable("BiPinTime")

	--魂器
	local horcruxes_content = self:FindObj("HorcruxesContent")
	horcruxes_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.hunqi_content_view = HunQiContentView.New(obj)
		self.hunqi_content_view:InitView()
	end)

	--打磨
	local damo_content = self:FindObj("DaMoContent")
	damo_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.damo_content_view = DaMoContentView.New(obj)
		self.damo_content_view:InitView()
	end)

	--宝藏
	local baozang_content = self:FindObj("BaoZangContent")
	baozang_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.baozang_content_view = BaoZangContentView.New(obj)
		self.baozang_content_view:InitView()
	end)


	--魂印
	self.open_trigger_list = {
		["hunqi_hunyin"] = self:FindVariable("IsHunYinOpen"),
	}

	-- 聚魂
	local gather_content = self:FindObj("GatherSoulContent")
	gather_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.gather_content_view = GatherContentView.New(obj)
		self.gather_content_view:InitView()
	end)

	self.event_quest = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowOrHideTab, self))
	self:ShowOrHideTab()

	local hunyin_content = self:FindObj("HunYinContent")
	hunyin_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.hunyin_content_view = HunYinContentView.New(obj)
		self.hunyin_content_view:InitView(self.is_hunyin_inlay)
	end)

	self.bind_gold = self:FindVariable("BindGold")
	self.gold = self:FindVariable("Gold")
	self.tab_hunqi = self:FindObj("TabHunQi")
	self.tab_damo = self:FindObj("TabDaMo")
	self.tab_baozang = self:FindObj("TabBaoZang")
	self.tab_hunyin = self:FindObj("TabHunYin")
	self.tab_total_inlay = self:FindObj("TabTotalInlay")
	self.tab_lingshu_update = self:FindObj("TabLingshuUpdate")
	self.tab_gather = self:FindObj("TabGather")
	self.red_point_list = {
		[RemindName.HunYin_LingShu] = self:FindVariable("UpdateRedPoint"),
		[RemindName.HunYin_Inlay] = self:FindVariable("InlayRedPoint"),
		[RemindName.HunQiRemind]  = self:FindVariable("HunQiRedPoint"),
		[RemindName.HunYinRemind] = self:FindVariable("HunYinRedPoint"),
		[RemindName.Gatheremind] = self:FindVariable("GatherRedPoint"),
	}

	for k in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
end

function HunQiView:CloseCallBack()
	PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
	self.data_listen = nil

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.baozang_content_view then
		self.baozang_content_view:StopCountDown()
	end
end

function HunQiView:OnClickBiPin()
	ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {self.discount_index})
end

function HunQiView:ItemDataChangeCallback(item_id)
	--打磨物品变化
	local identify_item_list = HunQiData.Instance:GetIdentifyItemList()
	if identify_item_list then
		for k, v in ipairs(identify_item_list) do
			if v.consume_item_id == item_id then
				self:Flush("damo")
				return
			end
		end
	end

	--炼魂物品变化
	for _, v in ipairs(HunQiData.ElementItemList) do
		if item_id == v then
			self:Flush("element_red")
			return
		end
	end

	-- if self.tab_hunqi.toggle.isOn then
	-- 	if self.hunqi_content_view then
	-- 		self.hunqi_content_view:FlushView()
	-- 	end	
	-- end
end


function HunQiView:ShowOrHideTab(name)
	if nil ~= self.open_trigger_list[name] then
		local is_enable = OpenFunData.Instance:CheckIsHide(name)
		self.open_trigger_list[name]:SetValue(is_enable)
	else
		for k,v in pairs(self.open_trigger_list) do
			local is_enable = OpenFunData.Instance:CheckIsHide(k)
			v:SetValue(is_enable)
		end
	end
end

function HunQiView:OnClickClose()
	self:Close()
end

function HunQiView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function HunQiView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "bind_gold" then
		self.bind_gold:SetValue(CommonDataManager.ConverMoney(value))
	end
	if attr_name == "gold" then
		self.gold:SetValue(CommonDataManager.ConverMoney(value))
	end
end

function HunQiView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		if remind_name == RemindName.HunQi_BaoZang then
			if num > 0 then
				HunQiData.Instance:SetIsCheckBoxRemind(true)
			end
		end
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function HunQiView:OpenHunQi()
	if not self.tab_hunqi.toggle.isOn and self.hunqi_content_view then
		self.hunqi_content_view:InitView()
	end
	self:Flush("hunqi")
end

function HunQiView:OpenDaMo()
	if not self.tab_damo.toggle.isOn and self.damo_content_view then
		self.damo_content_view:InitView()
	end
end

function HunQiView:OpenBaoZang()
	RemindManager.Instance:Fire(RemindName.HunQi_BaoZang)
	if not self.tab_baozang.toggle.isOn and self.baozang_content_view then
		self.baozang_content_view:InitView()
	end
end


--魂印
function HunQiView:OpenHunYin()
	self.show_index = TabIndex.hunqi_hunyin
	self:OnClickTotalInlay()
	self.tab_lingshu_update.toggle.isOn = false
	self.tab_total_inlay.toggle.isOn = true
-- 	if not self.tab_hunyin.toggle.isOn then
-- 		GlobalTimerQuest:AddDelayTimer(function()
-- 			self.tab_total_inlay.toggle.isOn = true
-- 			if self.hunyin_content_view then
-- 				self.hunyin_content_view:InitView(true)
-- 			else
-- 				self.is_hunyin_inlay = true
-- 			end
-- 		end, 0)
-- 	end
end

function HunQiView:OpenGather()
	if not self.tab_gather.toggle.isOn and self.gather_content_view then
		self.gather_content_view:InitView()
	end
	
end


function HunQiView:OnClickTotalInlay()
	HunQiData.Instance:SetCurrenSelectPage(1)
	if self.hunyin_content_view then
		self.hunyin_content_view:InitView(true)
	else
		self.is_hunyin_inlay = true
	end
end

function HunQiView:OnClickLingshuUpdate()
	HunQiData.Instance:SetCurrenSelectPage(2)
	if self.hunyin_content_view then
		self.hunyin_content_view:InitView(false)
	else
		self.is_hunyin_inlay = false
	end
end

function HunQiView:OpenCallBack()
	if self.tab_hunqi.toggle.isOn then
		if self.hunqi_content_view then
			self.hunqi_content_view:InitView()
		end
	elseif self.tab_damo.toggle.isOn then
		if self.damo_content_view then
			self.damo_content_view:InitView()
		end
	elseif self.tab_baozang.toggle.isOn then
		if self.baozang_content_view then
			self.baozang_content_view:InitView()
		end
	elseif self.tab_gather.toggle.isOn then
		if self.gather_content_view then
			self.gather_content_view:InitView()
		end
	elseif self.tab_hunyin.toggle.isOn then
		GlobalTimerQuest:AddDelayTimer(function()
			self.tab_total_inlay.toggle.isOn = true
			if self.hunyin_content_view then
				self.hunyin_content_view:InitView(true)
			else
				self.is_hunyin_inlay = true
			end
		end, 0)
	else
		self.tab_hunqi.toggle.isOn = true
		if self.hunqi_content_view then
			self.hunqi_content_view:InitView()
		end
	end

	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])

	--监听物品变化
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	local discount_info, index = DisCountData.Instance:GetDiscountInfoByType(9, true)
	self.discount_index = index
	self.show_bipin_icon:SetValue(discount_info ~= nil)
	self.discount_close_time = discount_info and discount_info.close_timestamp or 0
	if discount_info and self.discount_timer == nil then
		self:UpdateTimer()
		self.discount_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateTimer, self), 1)
	end

	--清除协助
	HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_REMOVE_HELP_BOX)
end

function HunQiView:UpdateTimer()
	local time = self.discount_close_time - TimeCtrl.Instance:GetServerTime()
	if time <= 0 then
		GlobalTimerQuest:CancelQuest(self.discount_timer)
		self.discount_timer = nil
		self.show_bipin_icon:SetValue(false)
	else
		if time > 3600 then
			self.discount_time:SetValue(TimeUtil.FormatSecond(time, 1))
		else
			self.discount_time:SetValue(TimeUtil.FormatSecond(time, 2))
		end
	end
end

function HunQiView:ShowIndexCallBack(index)
	if index == TabIndex.hunqi_content then
		self.tab_hunqi.toggle.isOn = true
		if self.hunqi_content_view then
			self.hunqi_content_view:InitView()
		end
	elseif index == TabIndex.hunqi_damo then
		self.tab_damo.toggle.isOn = true
		if self.damo_content_view then
			self.damo_content_view:InitView()
		end
	elseif index == TabIndex.hunqi_xilina then
		self.tab_baozang.toggle.isOn = true
		if self.baozang_content_view then
			self.baozang_content_view:InitView()
		end
	elseif index == TabIndex.hunqi_gather then
		self.tab_gather.toggle.isOn = true
		if self.gather_content_view then
			self:OpenGather()
		end
	elseif index == TabIndex.hunqi_hunyin_inlay or index == TabIndex.hunqi_hunyin_upgrade then
		self.tab_hunyin.toggle.isOn = true
		local is_inlay = false
		if index == TabIndex.hunqi_hunyin_inlay then
			self.tab_total_inlay.toggle.isOn = true
			is_inlay = true
		else
			self.tab_lingshu_update.toggle.isOn = true
		end
		if self.hunyin_content_view then
			self.hunyin_content_view:InitView(is_inlay)
		else
			self.is_hunyin_inlay = is_inlay
		end
	end
end

function HunQiView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "hunqi" and self.tab_hunqi.toggle.isOn then
			if self.hunqi_content_view then
				self.hunqi_content_view:FlushView()
			end
		elseif k == "damo" and self.tab_damo.toggle.isOn then
			if self.damo_content_view then
				self.damo_content_view:FlushView()
			end
		elseif k == "baozang" and self.tab_baozang.toggle.isOn then
			if self.baozang_content_view then
				self.baozang_content_view:FlushView()
			end
		elseif k == "hunyin" and self.tab_hunyin.toggle.isOn then
			if self.hunyin_content_view then
				self.hunyin_content_view:FlushView()
			end
		elseif k == "item_change" then
			if self.tab_hunqi.toggle.isOn and self.hunqi_content_view then
				self.hunqi_content_view:FlushCostDes()
			elseif self.tab_damo.toggle.isOn and self.damo_content_view then
				self.damo_content_view:FlushItemList()
			elseif self.tab_baozang.toggle.isOn and self.baozang_content_view then
				self.baozang_content_view:FlushBoxCount()
			end
		elseif k == "gather_time" and self.tab_hunqi.toggle.isOn then
			if self.hunqi_content_view then
				self.hunqi_content_view:FlushLeftContent()
			end
		-- elseif k == "hunqi_upgrade" and self.tab_hunqi.toggle.isOn then
			-- if self.hunqi_content_view then
			-- 	self.hunqi_content_view:UpGradeResult(v[1])
			-- end
		elseif k == "element_red" and self.tab_hunqi.toggle.isOn then
			if self.hunqi_content_view then
				self.hunqi_content_view:FlushElementRed()
			end
		elseif k == "gather_content" and self.tab_gather.toggle.isOn then
			if self.hunqi_content_view then
				self.gather_content_view:FlushView()
			end
		end
	end
end