require("game/shen_ge/hun_qi/hunqi_content_view")
require("game/shen_ge/hun_qi/damo_content_view")
require("game/shen_ge/hun_qi/baozang_content_view")
require("game/shen_ge/hun_qi/hunyin_content_view")
require("game/shen_ge/hun_qi/hunyin_upgrade_view")
require("game/shen_ge/hun_qi/gather_soul_view")
require("game/shen_ge/hun_qi/xilian_content_view")

HunQiView = HunQiView or BaseClass(BaseView)
function HunQiView:__init()
	self.ui_config = {"uis/views/hunqiview_prefab", "HunQiView"}
	self.play_audio = true
	self.full_screen = true
	self.discount_close_time = 0
	self.discount_index = 0
	self.is_hunyin_inlay = true
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

	if self.hunyin_upgrade_view then
		self.hunyin_upgrade_view:DeleteMe()
		self.hunyin_upgrade_view = nil
	end

	if self.hunqi_juhun_view then
		self.hunqi_juhun_view:DeleteMe()
		self.hunqi_juhun_view = nil
	end

	if self.xilian_content_view then
		self.xilian_content_view:DeleteMe()
		self.xilian_content_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	self.tab_hunqi = nil
	self.tab_damo = nil
	self.tab_baozang = nil
	self.tab_hunyin = nil
--	self.tab_total_inlay = nil
	self.tab_juhun = nil
	self.tab_xilian = nil
	self.tab_hunyin_upgrade = nil
	self.bind_gold = nil
	self.gold = nil
	self.red_point_list = nil
	self.is_hunyin_open = nil
	self.open_trigger_list = nil


	self.horcruxes_content = nil
	self.damo_content = nil
	self.baozang_content = nil
	self.xilian_content = nil
	self.hunyin_content = nil
	self.hunyin_upgrade_content = nil

	if self.event_quest then
		GlobalEventSystem:UnBind(self.event_quest)
	end
end

function HunQiView:LoadCallBack()
	self:ListenEvent("OpenHunQi", BindTool.Bind(self.OpenHunQi, self))
	self:ListenEvent("OpenDaMo", BindTool.Bind(self.OpenDaMo, self))
	self:ListenEvent("OpenBaoZang", BindTool.Bind(self.OpenBaoZang, self))
	self:ListenEvent("OpenHunYin", BindTool.Bind(self.OpenHunYin, self))
	self:ListenEvent("OpenHunYinUpGrade", BindTool.Bind(self.OpenHunYinUpGrade, self))
	self:ListenEvent("OpenXiLian", BindTool.Bind(self.OpenXiLian, self))
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("HandleAddGold", BindTool.Bind(self.HandleAddGold, self))

	--魂器
	self.horcruxes_content = self:FindObj("HorcruxesContent")

	--打磨
	self.damo_content = self:FindObj("DaMoContent")

	--宝藏
	self.baozang_content = self:FindObj("BaoZangContent")

	--洗练
	self.xilian_content = self:FindObj("XiLianContent")

	--魂印
	self.open_trigger_list = {
		["hunqi_xilian"] = self:FindVariable("IsHunXiLianOpen"),
		["hunqi_hunyin"] = self:FindVariable("IsHunYinOpen"),
	}


	self.event_quest = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowOrHideTab, self))
	self:ShowOrHideTab()

	self.hunyin_content = self:FindObj("HunYinContent")
	self.hunyin_upgrade_content = self:FindObj("HunYinUpGradeContent")

	self.bind_gold = self:FindVariable("BindGold")
	self.gold = self:FindVariable("Gold")
	self.tab_hunqi = self:FindObj("TabHunQi")
	self.tab_damo = self:FindObj("TabDaMo")
	self.tab_baozang = self:FindObj("TabBaoZang")
	self.tab_hunyin = self:FindObj("TabHunYin")
	self.tab_hunyin_upgrade = self:FindObj("TabHunYinUpGrade")
	self.tab_juhun = self:FindObj("TabJuHun")
	self.tab_xilian = self:FindObj("TabXiLian")

	self.red_point_list = {
		[RemindName.HunQi_HunQi] = self:FindVariable("HunQiRemind"),
		-- [RemindName.HunQi_DaMo] = self:FindVariable("DaMoRemind"),
		[RemindName.HunQi_BaoZang] = self:FindVariable("BaoZangRemind"),
		[RemindName.HunYin_Inlay] = self:FindVariable("HunYinRemind"),
		[RemindName.HunYin_LingShu] = self:FindVariable("HunYinUpGradeRemind"),
		[RemindName.HunQi_JuHun] = self:FindVariable("JuHunRemind"),
		[RemindName.HunQi_XiLian] = self:FindVariable("XiLianRemind"),
	}

	for k in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
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
	self:ShowIndex(TabIndex.hunqi_content)
	if self.hunqi_content_view then
		self.hunqi_content_view:InitView()
	end
end

function HunQiView:OpenDaMo()
	self:ShowIndex(TabIndex.hunqi_damo)
	if not self.tab_damo.toggle.isOn and self.damo_content_view then
		self.damo_content_view:InitView()
	end
end

function HunQiView:OpenBaoZang()
	self:ShowIndex(TabIndex.hunqi_bao)
	RemindManager.Instance:Fire(RemindName.HunQi_BaoZang)
	if not self.tab_baozang.toggle.isOn and self.baozang_content_view then
		self.baozang_content_view:InitView()
	end
end

function HunQiView:OpenXiLian()
	self:ShowIndex(TabIndex.hunqi_xilian)
	if self.xilian_content_view then
		self.xilian_content_view:InitView()
	end
	HunQiData.Instance:SetXiLianRedPoint(false)
	RemindManager.Instance:Fire(RemindName.HunQi_XiLian)
end

--签文镶嵌
function HunQiView:OpenHunYin()
	self:ShowIndex(TabIndex.hunqi_hunyin_inlay)
	if self.hunyin_content_view then
		self.hunyin_content_view:InitView(true)
	end
end

--签文升级
function HunQiView:OpenHunYinUpGrade()
	self:ShowIndex(TabIndex.hunqi_hunyin_upgrade)
	if self.hunyin_upgrade_view then
		self.hunyin_upgrade_view:InitView(false)
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
	elseif self.tab_xilian.toggle.isOn then
		if self.xilian_content_view then
			self.xilian_content_view:InitView()
		end
	elseif self.tab_hunyin.toggle.isOn then
		if self.hunyin_content_view then
			self.hunyin_content_view:InitView(true)
		end
	elseif self.tab_hunyin_upgrade.toggle.isOn then
		if self.hunyin_upgrade_view then
			self.hunyin_upgrade_view:InitView(false)
		end
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

	--清除协助
	HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_REMOVE_HELP_BOX)
end

function HunQiView:InitPanel(index)
	if index == TabIndex.hunqi_content and not self.hunqi_content_view then
		UtilU3d.PrefabLoad("uis/views/hunqiview_prefab", "HorcruxesContent",
			function(obj)
				obj.transform:SetParent(self.horcruxes_content.transform, false)
				obj = U3DObject(obj)
				self.hunqi_content_view = HunQiContentView.New(obj)
				self.hunqi_content_view:InitView()
			end
		)
	elseif index == TabIndex.hunqi_damo and not self.damo_content_view  then
		UtilU3d.PrefabLoad("uis/views/hunqiview_prefab", "DaMoContent",
			function(obj)
				obj.transform:SetParent(self.damo_content.transform, false)
				obj = U3DObject(obj)
				self.damo_content_view = DaMoContentView.New(obj)
				self.damo_content_view:InitView()
			end
		)
	elseif index == TabIndex.hunqi_bao and not self.baozang_content_view  then
		UtilU3d.PrefabLoad("uis/views/hunqiview_prefab", "BaoZangContent",
			function(obj)
				obj.transform:SetParent(self.baozang_content.transform, false)
				obj = U3DObject(obj)
				self.baozang_content_view = BaoZangContentView.New(obj)
				self.baozang_content_view:InitView()
			end
		)
	elseif index == TabIndex.hunqi_xilian and not self.xilian_content_view  then
		UtilU3d.PrefabLoad("uis/views/hunqiview_prefab", "XiLianContent",
			function(obj)
				obj.transform:SetParent(self.xilian_content.transform, false)
				obj = U3DObject(obj)
				self.xilian_content_view = XiLianContentView.New(obj)
				self.xilian_content_view:InitView()
			end
		)
	elseif (index == TabIndex.hunqi_hunyin or index == TabIndex.hunqi_hunyin_inlay) and not self.hunyin_content_view  then
		UtilU3d.PrefabLoad("uis/views/hunqiview_prefab", "HunYinContent",
			function(obj)
				obj.transform:SetParent(self.hunyin_content.transform, false)
				obj = U3DObject(obj)
				self.hunyin_content_view = HunYinContentView.New(obj)
				self.hunyin_content_view:InitView(true)
			end
		)
	elseif index == TabIndex.hunqi_hunyin_upgrade and not self.hunyin_upgrade_view then
		UtilU3d.PrefabLoad("uis/views/hunqiview_prefab", "HunYinUpGradeContent",
			function(obj)
				obj.transform:SetParent(self.hunyin_upgrade_content.transform, false)
				obj = U3DObject(obj)
				self.hunyin_upgrade_view = HunYinUpGradeView.New(obj)
				self.hunyin_upgrade_view:InitView(false)
			end
		)
	end
end

function HunQiView:ShowIndexCallBack(index)
	self:InitPanel(index)
	if index == TabIndex.hunqi_content then
		self.tab_hunqi.toggle.isOn = true
	elseif index == TabIndex.hunqi_damo then
		self.tab_damo.toggle.isOn = true
	elseif index == TabIndex.hunqi_bao then
		self.tab_baozang.toggle.isOn = true
	elseif index == TabIndex.hunqi_xilian then
		self.tab_xilian.toggle.isOn = true
	elseif index == TabIndex.hunqi_hunyin or index == TabIndex.hunqi_hunyin_inlay then
		self.tab_hunyin.toggle.isOn = true
	elseif index == TabIndex.hunqi_hunyin_upgrade then
		self.tab_hunyin_upgrade.toggle.isOn = true
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
		elseif k == "hunyin" then
			if self.tab_hunyin.toggle.isOn then
				if self.hunyin_content_view then
					self.hunyin_content_view:FlushView()
				end
			end

			if self.tab_hunyin_upgrade.toggle.isOn then
				if self.hunyin_upgrade_view then
					self.hunyin_upgrade_view:FlushView()
				end
			end
		elseif k == "resolve" then
			if self.tab_hunyin.toggle.isOn then
				if self.hunyin_content_view then
					self.hunyin_content_view:Flush("resolve")
				end
			end

			if self.tab_hunyin_upgrade.toggle.isOn then
				if self.hunyin_upgrade_view then
					self.hunyin_upgrade_view:Flush("resolve")
				end
			end

		elseif k == "xilian" and self.tab_xilian.toggle.isOn then
			if self.xilian_content_view then
				self.xilian_content_view:FlushView()
			end
		elseif k == "item_change" then
			if self.tab_hunqi.toggle.isOn and self.hunqi_content_view then
				self.hunqi_content_view:FlushCostDes()
			elseif self.tab_damo.toggle.isOn and self.damo_content_view then
				self.damo_content_view:FlushItemList()
			elseif self.tab_baozang.toggle.isOn and self.baozang_content_view then
				self.baozang_content_view:FlushBoxCount()
			elseif self.tab_hunyin.toggle.isOn and self.hunyin_content_view then
				self.hunyin_content_view:FlushAllInfo()
			elseif self.tab_hunyin_upgrade.toggle.isOn and self.hunyin_upgrade_view then
				self.hunyin_upgrade_view:FlushAllInfo()
			end
		elseif k == "gather_time" and self.tab_hunqi.toggle.isOn then
			if self.hunqi_content_view then
				self.hunqi_content_view:FlushLeftContent()
			end
		elseif k == "hunqi_upgrade" and self.tab_hunqi.toggle.isOn then
			if self.hunqi_content_view then
				self.hunqi_content_view:UpGradeResult(v[1])
			end
		elseif k == "element_red" and self.tab_hunqi.toggle.isOn then
			if self.hunqi_content_view then
				self.hunqi_content_view:FlushElementRed()
			end
		end
	end
end

function HunQiView:GetCurrentSelectHunQi()
	return self.hunyin_content_view:GetCurrentSelectHunQi()
end