require("game/marriage/baobao/baobao_image_view")
require("game/marriage/baobao/baobao_attr_view")
require("game/marriage/baobao/baobao_aptitude_view")
require("game/marriage/baobao/baobao_bless_view")
require("game/marriage/baobao/baobao_guard_view")

MarryBaoBaoView = MarryBaoBaoView or BaseClass(BaseView)
function MarryBaoBaoView:__init()
	self.ui_config = {"uis/views/marriageview_prefab", "BaoBaoContentView"}
	self.full_screen = true
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function MarryBaoBaoView:ReleaseCallBack()
	if self.image_view then
		self.image_view:DeleteMe()
		self.image_view = nil
	end
	if self.attr_view then
		self.attr_view:DeleteMe()
		self.attr_view = nil
	end
	if self.bless_view then
		self.bless_view:DeleteMe()
		self.bless_view = nil
	end
	if self.guard_view then
		self.guard_view:DeleteMe()
		self.guard_view = nil
	end
	if self.aptitude_view then
		self.aptitude_view:DeleteMe()
		self.aptitude_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.operate_result then
		GlobalEventSystem:UnBind(self.operate_result)
		self.operate_result = nil
	end

	if self.item_data_event then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	self.red_point_list = nil

	-- 清理变量
	self.toggle_baobao_arr = nil
	self.toggle_baobao_bless = nil
	self.toggle_baobao_guard = nil
	self.toggle_baobao_zizhi = nil
	self.baobao_arr_content = nil
	self.baobao_bless_content = nil
	self.baobao_guard_content = nil
	self.show_aptitude = nil
	self.show_button_zizhi = nil
	self.baobao_zizhi_content = nil

	self.gold = nil
	self.bind_gold = nil

	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function MarryBaoBaoView:LoadCallBack()

	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("bind_gold")

	self:ListenEvent("AddGold",BindTool.Bind(self.HandleAddGold, self))

	-- 页签
	self.toggle_baobao_arr = self:FindObj("TabBaoBaoArr")
	self.toggle_baobao_bless = self:FindObj("TabBaoBaoBless")
	self.toggle_baobao_guard = self:FindObj("TabBaoBaoGuard")
	self.toggle_baobao_zizhi = self:FindObj("TabBaoBaoZiZhi")

	-- 子面板
	self.baobao_arr_content = self:FindObj("BaoBaoArrContent")
	self.baobao_bless_content = self:FindObj("BaoBaoBlessContent")
	self.baobao_guard_content = self:FindObj("BaoBaoGuardContent")
	self.baobao_zizhi_content = self:FindObj("BaoBaoZiZhiContent")

	-- 监听UI事件
	self:ListenEvent("OnClickBaby",
		BindTool.Bind(self.OnClickBaby, self))
	self:ListenEvent("OnClickBless",
		BindTool.Bind(self.OnClickBless, self))
	self:ListenEvent("OnClickGuard",
		BindTool.Bind(self.OnClickGuard, self))
	self:ListenEvent("OnClickZiZhi",
		BindTool.Bind(self.OnClickZiZhi, self))

	self.image_view = BaoBaoImageView.New(self:FindObj("ImageView"))
	-- self.aptitude_view = BaoBaoAptitudeView.New(self:FindObj("AptitudeView"), self)
	-- self.attr_view = BaoBaoAttrView.New(self:FindObj("AttrView"))
	self:ListenEvent("CloseView",
		BindTool.Bind(self.ClickCloseView, self))

	self:ListenEvent("OpenZizhiClick",
		BindTool.Bind(self.OpenZizhiClick, self, true))

	self.show_aptitude = self:FindVariable("ShowAptitude")
	self.show_button_zizhi = self:FindObj("ShowButtonZiZhi")

	self.red_point_list = {
		[RemindName.MarryBaoBaoAttr] = self:FindVariable("ShowBaoBaoRedPoint"),
		[RemindName.MarryBaoBaoZiZhi] = self:FindVariable("ShowBaoBaoZiZhiPoint"),
		[RemindName.MarryBaoBaoGuard] = self:FindVariable("ShowBaoBaoGuardPoint"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	self.operate_result = GlobalEventSystem:Bind(OtherEventType.OPERATE_RESULT, BindTool.Bind1(self.OnOperateResult, self))

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end


function MarryBaoBaoView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function MarryBaoBaoView:ClickCloseView()
	self:Close()
end

function MarryBaoBaoView:OnOperateResult(operate, result, param1, param2)
	if operate == MODULE_OPERATE_TYPE.OP_BABY_JIE_UPGRADE then
		if self.attr_view then
			self.attr_view:OnOperateResult(operate, result, param1, param2)
		end
	elseif operate == MODULE_OPERATE_TYPE.OP_BABY_JL_UPGRADE then
		if self.guard_view then
			self.guard_view:OnOperateResult(operate, result, param1, param2)
		end
	end
end

function MarryBaoBaoView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if self.attr_view then
		self.attr_view:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	end
	if self.guard_view then
		self.guard_view:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	end
end

function MarryBaoBaoView:CloseCallBack()
	if self.cur_index == TabIndex.marriage_baobao_att then
		if self.attr_view then
			self.attr_view:CloseCallBack()
		end
	end
	if self.cur_index == TabIndex.marriage_baobao_guard then
		if self.guard_view then
			self.guard_view:CloseCallBack()
		end
	end

	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function MarryBaoBaoView:OpenCallBack()
	BaobaoCtrl.SendAllBabyInfoReq()
	local baby_list = BaobaoData.Instance:GetListBabyData() or {}
	local count = #baby_list
	-- 如果self.show_index 等于0的时候就是手动打开的面板
	-- 如果是背包使用物品就不用进到下面可以直接跳到想要的面板
	if self.show_index == 0 then
		if count > 0 then
			self:ChangeToIndex(TabIndex.marriage_baobao_att)
		else
			self:ChangeToIndex(TabIndex.marriage_baobao_bless)
		end
	end

	-- 监听系统事件
	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end
		-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
end

function MarryBaoBaoView:ShowOrHideTab()
	local baby_list = BaobaoData.Instance:GetListBabyData() or {}
	local count = #baby_list
	self.toggle_baobao_arr.gameObject:SetActive( count > 0 )
	self.toggle_baobao_guard.gameObject:SetActive( count > 0 )
	self.toggle_baobao_zizhi.gameObject:SetActive( count > 0 )
	if count <= 0 then
		self.toggle_baobao_bless.toggle.isOn = true
	end
end

function MarryBaoBaoView:ShowIndexCallBack(index)
	local baby_list = BaobaoData.Instance:GetListBabyData() or {}
	local count = #baby_list
	if count <= 0 then
		index = TabIndex.marriage_baobao_bless
	end
	BaobaoData.Instance:SetCurTabIndex(index)
	self.cur_index = index
	self:AsyncLoadView(index)
	if index == TabIndex.marriage_baobao_att then
		self.toggle_baobao_arr.toggle.isOn = true
		if self.attr_view then
			self.attr_view:FlushView()
		end
		self:FlushImageView()
	elseif index == TabIndex.marriage_baobao_bless then
		self.toggle_baobao_bless.toggle.isOn = true
	 	if self.bless_view then
			self.bless_view:FlushView()
		end
	elseif index == TabIndex.marriage_baobao_guard then
		self.toggle_baobao_guard.toggle.isOn = true
	 	if self.guard_view then
			self.guard_view:FlushView()
		end
		self:FlushImageView()
	elseif index == TabIndex.marriage_baobao_zizhi then
		self.toggle_baobao_zizhi.toggle.isOn = true
		if self.aptitude_view then
			self.aptitude_view:FlushView()
		end
		self:FlushImageView()
	end
	if index ~= TabIndex.marriage_baobao_att then
		if self.attr_view then
			self.attr_view:CloseCallBack()
		end
	end
	if index ~= TabIndex.marriage_baobao_guard then
		if self.guard_view then
			self.guard_view:CloseCallBack()
		end
	end
end

-- 共用面板
function MarryBaoBaoView:FlushImageView()
	if self.image_view then
		self.image_view:FlushView()
	end
end

-- 点击宝宝属性
function MarryBaoBaoView:OnClickBaby()
	self:ShowIndex(TabIndex.marriage_baobao_att)
end

-- 点击祈福
function MarryBaoBaoView:OnClickBless()
	self:ShowIndex(TabIndex.marriage_baobao_bless)
end

-- 点击守卫
function MarryBaoBaoView:OnClickGuard()
	self:ShowIndex(TabIndex.marriage_baobao_guard)
end

-- 点击资质
function MarryBaoBaoView:OnClickZiZhi()
	self:ShowIndex(TabIndex.marriage_baobao_zizhi)
end


function MarryBaoBaoView:AsyncLoadView(index)
	if index == TabIndex.marriage_baobao_att and self.baobao_arr_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/marriageview_prefab", "BaoBaoArrContent",
			function(obj)
				obj.transform:SetParent(self.baobao_arr_content.transform, false)
				obj = U3DObject(obj)
				self.attr_view = BaoBaoAttrView.New(obj)
				self.attr_view:FlushView()
			end)

	elseif index == TabIndex.marriage_baobao_bless and self.baobao_bless_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/marriageview_prefab", "BaoBaoBlessContent",
			function(obj)
				obj.transform:SetParent(self.baobao_bless_content.transform, false)
				obj = U3DObject(obj)
				self.bless_view = BaoBaoBlessView.New(obj)
				self.bless_view:FlushView()
			end)

	elseif index == TabIndex.marriage_baobao_guard and self.baobao_guard_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/marriageview_prefab", "BaoBaoGuardContent",
			function(obj)
				obj.transform:SetParent(self.baobao_guard_content.transform, false)
				obj = U3DObject(obj)
				self.guard_view = BaoBaoGuardView.New(obj)
				self.guard_view:FlushView()
			end)

	elseif index == TabIndex.marriage_baobao_zizhi and self.baobao_zizhi_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/marriageview_prefab", "BaoBaoZiZhiContent",
			function(obj)
				obj.transform:SetParent(self.baobao_zizhi_content.transform, false)
				obj = U3DObject(obj)
				self.aptitude_view = BaoBaoAptitudeView.New(obj)
				self.aptitude_view:FlushView()
			end)
	end
end

function MarryBaoBaoView:OpenZizhiClick(value)
	local baby_list = BaobaoData.Instance:GetListBabyData() or {}
	if #baby_list <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.HaveNotBaby)
		return
	end
	self.is_show_aptitude = value
	self.show_aptitude:SetValue(value)

	if self.is_show_aptitude then
		self.aptitude_view:FlushView()
	else
		self.attr_view:FlushView()
	end
end

function MarryBaoBaoView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "special" then
			if self.attr_view and self.cur_index == TabIndex.marriage_baobao_att and self.toggle_baobao_arr.toggle.isOn then
				self.attr_view:FlushSpecial()
			end
		end
	end

	if self.cur_index == TabIndex.marriage_baobao_att and self.toggle_baobao_arr.toggle.isOn then
		if self.attr_view then
			self.attr_view:FlushView()
		end
		self:FlushImageView()
	elseif self.cur_index == TabIndex.marriage_baobao_bless and self.toggle_baobao_bless.toggle.isOn then
		if self.bless_view then
			self.bless_view:FlushView()
		end
	elseif self.cur_index == TabIndex.marriage_baobao_guard and self.toggle_baobao_guard.toggle.isOn then
		if self.guard_view then
			self.guard_view:FlushView()
		end
		self:FlushImageView()
	elseif self.cur_index == TabIndex.marriage_baobao_zizhi and self.toggle_baobao_zizhi.toggle.isOn then
		if self.aptitude_view then
			self.aptitude_view:FlushView()
		end
		self:FlushImageView()
	end
	self:ShowOrHideTab()
end


function MarryBaoBaoView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo then
		if attr_name == "gold" then
			local count, str = CommonDataManager.ConverNum2(vo.gold or 0)
			str = str or ""
			count = count or 0
			self.gold:SetValue(math.floor(count) .. str)
		end
		if attr_name == "bind_gold" then
			local count, str = CommonDataManager.ConverNum2(vo.bind_gold or 0)
			str = str or ""
			count = count or 0
			self.bind_gold:SetValue(math.floor(count) .. str)
		end
	end
end

function MarryBaoBaoView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function MarryBaoBaoView:ResetValue()
	if self.guard_view then
		self.guard_view:ResetValue()
	end
end

