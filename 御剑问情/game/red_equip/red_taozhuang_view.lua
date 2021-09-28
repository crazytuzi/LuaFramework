require("game/red_equip/red_equip_view")
require("game/red_equip/yellow_equip_view")

RedTaoZhuangView = RedTaoZhuangView or BaseClass(BaseView)

function RedTaoZhuangView:__init()
	self.ui_config = {"uis/views/redequipview_prefab", "RedTaoZhuangView"}
	self.full_screen = false								-- 是否是全屏界面(ViewManager里面调用)
	self.play_audio = true								-- 播放音效
	-- self:SetMaskBg()
	self.def_index = TabIndex.shenshou_taozhuang_yellow 					-- 神兽套装

	-- self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function RedTaoZhuangView:__delete()
	self.full_screen = nil
	self.play_audio = nil
	self.remind_change = nil
end

function RedTaoZhuangView:ReleaseCallBack()
	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.red_equip_view then
		self.red_equip_view:DeleteMe()
		self.red_equip_view = nil
	end

	if self.yellow_equip_view then
		self.yellow_equip_view:DeleteMe()
		self.yellow_equip_view = nil
	end

	if self.toggle_list then
		for k,v in pairs(self.toggle_list) do
			if v then
				v = nil
			end
		end
		self.toggle_list = {}
	end

	if self.panel_list then
		for k,v in pairs(self.panel_list) do
			if v then
				v = nil
			end
		end
		self.panel_list = {}
	end

	-- if self.red_point_list then
	-- 	for k,v in pairs (self.red_point_list) do
	-- 		if v then
	-- 			v = nil
	-- 		end
	-- 	end
	-- 	self.red_point_list = nil
	-- end

	self.bind_gold = nil
	self.gold = nil
	self.orange_point = nil
	self.red_point = nil

	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

end

function RedTaoZhuangView:LoadCallBack()

	--监听UI事件
	self:ListenEvent("Close", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("ClickRedEquip", BindTool.Bind(self.ClickRedEquip, self))
	self:ListenEvent("ClickYellowEquip", BindTool.Bind(self.ClickYellowEquip, self))
	self:ListenEvent("AddGold",BindTool.Bind(self.HandleAddGold, self))

	-- 左边的标签页
	self.toggle_list = {}
	self.toggle_list[TabIndex.shenshou_taozhuang_red] = self:FindObj("ToggleEquip")				-- 红装
	self.toggle_list[TabIndex.shenshou_taozhuang_yellow] = self:FindObj("ToggleYellowEquip")	-- 橙装

	self.panel_list = {}
	self.panel_list[TabIndex.shenshou_taozhuang_red] = self:FindObj("EquipContent")				-- 红装
	self.panel_list[TabIndex.shenshou_taozhuang_yellow] = self:FindObj("YellowEquipContent")	-- 橙装

	self.red_point = self:FindVariable("RedPoint")
	self.orange_point = self:FindVariable("OrangePoint")

	--variable
	self.bind_gold = self:FindVariable("BindGold")
	self.gold = self:FindVariable("Gold")
	-- 面板列表

	-- self.red_point_list = {
	-- 	[RemindName.ShenQiJiangLing] = self:FindVariable("JianLingRedPoint"),
	-- 	[RemindName.ShenQiBaoJia] = self:FindVariable("BaoJiaPoint"),
	-- }

	-- for k, _ in pairs(self.red_point_list) do
	-- 	RemindManager.Instance:Bind(self.remind_change, k)
	-- end

	-- RemindManager.Instance:Fire(RemindName.ShenQi)
end

function RedTaoZhuangView:ShowIndexCallBack(index)
	self.show_index = index
	self.toggle_list[index].toggle.isOn = true
	self:LoadPrefabAsyn(index)
end

-- function RedTaoZhuangView:ReleaseAutoUpLevel()
-- 	if self.red_equip_view then
-- 		self.red_equip_view:SetUpLevelState(false)
-- 	end

-- 	if self.baojia_view then
-- 		self.baojia_view:SetUpLevelState(false)
-- 	end
-- end

function RedTaoZhuangView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "gold" or attr_name == "bind_gold" then
		local count = value
		if count > 99999 and count <= 99999999 then
			count = count / 10000
			count = math.floor(count)
			count = count .. "万"
		elseif count > 99999999 then
			count = count / 100000000
			count = math.floor(count)
			count = count .. "亿"
		end
		if attr_name == "bind_gold" then
			self.bind_gold:SetValue(count)
		else
			self.gold:SetValue(count)
		end
	end
end


function RedTaoZhuangView:OpenCallBack()
	--监听系统事件

	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])

	-- RemindManager.Instance:Fire(RemindName.ShenQiJiangLing)
	-- RemindManager.Instance:Fire(RemindName.ShenQiBaoJia)

	 -- 请求所有信息
	-- ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_INFO)
	self:FlushPointState()
end

function RedTaoZhuangView:CloseCallBack()

	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

-- function RedTaoZhuangView:RemindChangeCallBack(remind_name, num)
-- 	if nil ~= self.red_point_list[remind_name] then
-- 		self.red_point_list[remind_name]:SetValue(num > 0)
-- 	end
-- end

function RedTaoZhuangView:OnFlush(param_t)
	-- if self.show_index == TabIndex.baojia and nil ~= self.baojia_view then
	-- 	self.baojia_view:Flush()
	if self.show_index == TabIndex.shenshou_taozhuang_red and nil ~= self.red_equip_view then
		self.red_equip_view:Flush()
	elseif self.show_index == TabIndex.shenshou_taozhuang_yellow and nil ~= self.yellow_equip_view then
		self.yellow_equip_view:Flush()
	end
	self:FlushPointState()
end

function RedTaoZhuangView:FlushPointState()
	local red_point_state = RedEquipData.Instance:GetRedPointState()
	local orange_point_state = RedEquipData.Instance:GetOrangePointState()
	if self.red_point then
		self.red_point:SetValue(red_point_state)
	end

	if self.orange_point then
		self.orange_point:SetValue(orange_point_state)
	end

	if self.show_index == TabIndex.shenshou_taozhuang_red then
		if self.red_equip_view then
			self.red_equip_view:Flush()
		end
	elseif self.show_index == TabIndex.shenshou_taozhuang_yellow then
		if self.yellow_equip_view then
			self.yellow_equip_view:Flush()
		end
	end
end

function RedTaoZhuangView:ToggleChange(index)
	if self.show_index == index then
		return
	end

	self:ShowIndex(index)
end

function RedTaoZhuangView:LoadPrefabAsyn(index)
	if index == TabIndex.shenshou_taozhuang_red then
		if nil == self.red_equip_view then
			UtilU3d.PrefabLoad("uis/views/redequipview_prefab", "RedEquipView",
				function(obj)
					obj.transform:SetParent(self.panel_list[index].transform, false)
					obj = U3DObject(obj)
					self.red_equip_view = RedEquipView.New(obj)
					self.red_equip_view:Flush()
			end)
		else
			self.red_equip_view:Flush()
		end
	elseif index == TabIndex.shenshou_taozhuang_yellow then
		if nil == self.yellow_equip_view then
			UtilU3d.PrefabLoad("uis/views/redequipview_prefab", "YellowEquipView",
				function(obj)
					obj.transform:SetParent(self.panel_list[index].transform, false)
					obj = U3DObject(obj)
					self.yellow_equip_view = YellowEquipView.New(obj)
					self.yellow_equip_view:Flush()
			end)
		else
			self.yellow_equip_view:Flush()
		end
	-- elseif index == TabIndex.fenjie then
	-- 	if nil == self.fenjie_view then
	-- 		local fenjie_content = self:FindObj("RecyleContent")
	-- 		UtilU3d.PrefabLoad(url, "RecykleContent",
	-- 			function(obj)
	-- 				obj.transform:SetParent(fenjie_content.transform, false)
	-- 				obj = U3DObject(obj)
	-- 				self.fenjie_view = FenjieView.New(obj)
	-- 				self.fenjie_view:Flush()
	-- 		end)
	-- 	else
	-- 		self.fenjie_view:Flush()
	-- 	end
	end

end

function RedTaoZhuangView:CloseView()
	self:Close()
end

function RedTaoZhuangView:ClickRedEquip()
	-- if nil ~= self.red_equip_view then
	-- 	self.red_equip_view:SetLevel(0)
	-- 	self.red_equip_view:ClearEffect()
	-- end
	self:ToggleChange(TabIndex.shenshou_taozhuang_red)
	-- ShenqiData.Instance:ChangeOpenJiangLing()
	-- RemindManager.Instance:Fire(RemindName.ShenQiJiangLing)
end

function RedTaoZhuangView:ClickYellowEquip()
	-- if nil ~= self.red_equip_view then
	-- 	self.red_equip_view:SetLevel(0)
	-- 	self.red_equip_view:ClearEffect()
	-- end
	self:ToggleChange(TabIndex.shenshou_taozhuang_yellow)
	-- ShenqiData.Instance:ChangeOpenJiangLing()
	-- RemindManager.Instance:Fire(RemindName.ShenQiJiangLing)
end

-- function RedTaoZhuangView:ClickBaoJia()
-- 	if nil ~= self.baojia_view then
-- 		self.baojia_view:SetLevel(0)
-- 		self.baojia_view:ClearEffect()
-- 	end
-- 	self:ToggleChange(TabIndex.baojia)
-- 	ShenqiData.Instance:ChangeOpenBaoJia()
-- 	RemindManager.Instance:Fire(RemindName.ShenQiBaoJia)
-- end

-- function RedTaoZhuangView:ClickFenJie()
-- 	self:ToggleChange(TabIndex.fenjie)
-- end

-- function RedTaoZhuangView:FlushCellUpLevelState()
-- 	if self.red_equip_view then
-- 		self.red_equip_view:FlushItemUpState()
-- 	end

-- 	if self.baojia_view then
-- 		self.baojia_view:FlushItemUpState()
-- 	end
-- end

-- function RedTaoZhuangView:ShenbingUpgradeOptResult(result)
-- 	self.red_equip_view:FlushUpgradeOptResult(result)
-- end

-- function RedTaoZhuangView:BaojiaUpgradeOptResult(result)
-- 	self.baojia_view:FlushUpgradeOptResult(result)
-- end

function RedTaoZhuangView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end