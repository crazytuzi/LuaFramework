require("game/shenshou/shenshou_equip_view")
require("game/shenshou/shenshou_fuling_view")
require("game/shenshou/shenshou_huanling_view")
require("game/shenshou/shenshow_fuling_selectmaterial_view")
require("game/shenshou/shenshou_compose_content_view")
require("game/shenshou/shenshou_fuling_tips")

ShenShouView = ShenShouView or BaseClass(BaseView)

function ShenShouView:__init()
	self.ui_config = {"uis/views/shenshouview_prefab","ShenShouView"}
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.def_index = TabIndex.shenshou_equip


	self.cur_toggle = INFO_TOGGLE
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function ShenShouView:__delete()
	
end

function ShenShouView:ReleaseCallBack()
	GlobalEventSystem:UnBind(self.open_trigger_handle)
	self.open_trigger_handle = nil 

	if self.equip_view then
		self.equip_view:DeleteMe()
		self.equip_view = nil
	end
	if self.fuling_view then
		self.fuling_view:DeleteMe()
		self.fuling_view = nil
	end
	if self.huanling_view then
		self.huanling_view:DeleteMe()
		self.huanling_view = nil
	end
	if self.compose_view then
		self.compose_view:DeleteMe()
		self.compose_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	-- 清理变量和对象
	self.gold = nil
	self.bind_gold = nil
	self.toggle_info = nil
	self.toggle_fuling = nil
	self.toggle_huanling = nil
	self.toggle_compose = nil
	self.equip_content = nil
	self.fuling_content = nil
	self.huanling_content = nil
	self.compose_content = nil
	self.red_point_list = {}

end

function ShenShouView:LoadCallBack()
	-- 监听UI事件
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.InitTab, self))

	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
	self:ListenEvent("ClickInfoView",
		BindTool.Bind(self.ClickInfoView, self))
	self:ListenEvent("ClickFulingView",
		BindTool.Bind(self.ClickFulingView, self))
	self:ListenEvent("ClickHuanlingView",
		BindTool.Bind(self.ClickHuanlingView, self))
	self:ListenEvent("ClickComposeView",
		BindTool.Bind(self.ClickComposeView, self))
	self:ListenEvent("ClickRecharge",
		BindTool.Bind(self.HandleAddGold, self))


	-- 获取变量
	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("BindGold")

	-- 页签
	self.toggle_info = self:FindObj("InfoTab")
	self.toggle_fuling = self:FindObj("FulingTab")
	self.toggle_huanling = self:FindObj("HuanlingTab")
	self.toggle_compose = self:FindObj("ComposeTab")

	self.equip_content = self:FindObj("EquipContent")
	self.fuling_content = self:FindObj("FulingContent")
	self.huanling_content = self:FindObj("HuanlingContent")
	self.compose_content = self:FindObj("ComposeContent")

	self.red_point_list = {
		[RemindName.ShenShou] = self:FindVariable("InfoRed"),
		[RemindName.ShenShouFuling] = self:FindVariable("FulingRed"),
		[RemindName.ShenShouHuanling] = self:FindVariable("HuanlingRed"),
		[RemindName.ShenShouCompose] = self:FindVariable("ComposeRed"),
	}

	for k, v in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
		v:SetValue(RemindManager.Instance:GetRemind(k) > 0)
	end

	self:Flush()
end

function ShenShouView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function ShenShouView:ClickInfoView()
	self:ShowIndex(TabIndex.shenshou_equip)
end

function ShenShouView:ClickFulingView()
	self:ShowIndex(TabIndex.shenshou_fuling)
end

function ShenShouView:ClickHuanlingView()
	self:ShowIndex(TabIndex.shenshou_huanling)
end

function ShenShouView:ClickComposeView()
	self:ShowIndex(TabIndex.shenshou_compose)
end

function ShenShouView:AsyncLoadView(index)
	if index == TabIndex.shenshou_equip and self.equip_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/shenshouview_prefab", "InfoContent",
			function(obj)
				obj.transform:SetParent(self.equip_content.transform, false)
				obj = U3DObject(obj)
				self.equip_view = ShenShouEquipView.New(obj)
				self.equip_view:OpenCallBack()
			end)
	elseif index == TabIndex.shenshou_fuling and self.fuling_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/shenshouview_prefab", "FulingContent",
			function(obj)
				obj.transform:SetParent(self.fuling_content.transform, false)
				obj = U3DObject(obj)
				self.fuling_view = ShenShouFulingView.New(obj)
				self.fuling_view:OpenCallBack()
			end)
	elseif index == TabIndex.shenshou_huanling and self.huanling_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/shenshouview_prefab", "HuanlingContent",
			function(obj)
				obj.transform:SetParent(self.huanling_content.transform, false)
				obj = U3DObject(obj)
				self.huanling_view = ShenShouHuanlingView.New(obj)
				self.huanling_view:OpenCallBack()
			end)
	elseif index == TabIndex.shenshou_compose and self.compose_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/shenshouview_prefab", "ShenShouComposeContentView",
			function(obj)
				obj.transform:SetParent(self.compose_content.transform, false)
				obj = U3DObject(obj)
				self.compose_view = ShenShouComposeView.New(obj)
				self.compose_view:OpenCallBack()
			end)
	end
end

function ShenShouView:ShowIndexCallBack(index)
	self:AsyncLoadView(index)

	if index == TabIndex.shenshou_equip then
		self.toggle_info.toggle.isOn = true
		if self.equip_view then
			self.equip_view:OpenCallBack()
		end

	elseif index == TabIndex.shenshou_fuling then
		self.toggle_fuling.toggle.isOn = true
		if self.fuling_view then
			self.fuling_view:OpenCallBack()
		end

	elseif index == TabIndex.shenshou_huanling then
		self.toggle_huanling.toggle.isOn = true
		ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_HUANLING_INFO)
		if self.huanling_view then
			self.huanling_view:OpenCallBack()
		end

	elseif index == TabIndex.shenshou_compose then
		self.toggle_compose.toggle.isOn = true
		if self.compose_view then
			self.compose_view:OpenCallBack()
		end
	else
		self:ShowIndex(TabIndex.shenshou_equip)
	end
end

function ShenShouView:OpenCallBack()
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:Flush()
	self:InitTab()

	if self.equip_view then
		self.equip_view:OpenCallBack()
	end
end

function ShenShouView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:FlushRolePackageView(index)
end

function ShenShouView:SetRendering(value)
	if self.is_rendering ~= value then
		self.last_role_model_show_type = nil
	end

	BaseView.SetRendering(self, value)
end

function ShenShouView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function ShenShouView:EquipDataChangeListen()
	if UIScene.role_model then
		UIScene.role_model:EquipDataChangeListen()
	end
end

function ShenShouView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local count = 0
	if attr_name == "bind_gold" then
		count = value
	elseif attr_name == "gold" then
		count = value
	end
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
	elseif attr_name == "gold" then
		self.gold:SetValue(count)
	end
end

function ShenShouView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ShenShouView:InitTab()
	if not self:IsOpen() then return end
	local open_fun_data = OpenFunData.Instance
	self.toggle_info:SetActive(open_fun_data:CheckIsHide("yingling_ying"))
	self.toggle_fuling:SetActive(open_fun_data:CheckIsHide("yingling_fuling"))
	self.toggle_huanling:SetActive(open_fun_data:CheckIsHide("yingling_huanling"))
	self.toggle_compose:SetActive(open_fun_data:CheckIsHide("yingling_hecheng"))
end

function ShenShouView:OnFlush(param_t)
	local cur_index = self:GetShowIndex()
	if cur_index == TabIndex.shenshou_equip then
		if self.equip_view then
			self.equip_view:Flush(param_t)
		end
	elseif cur_index == TabIndex.shenshou_fuling then
		if self.fuling_view then
			self.fuling_view:Flush(param_t)
		end
	elseif cur_index == TabIndex.shenshou_huanling then
		if self.huanling_view then
			self.huanling_view:Flush(param_t)
		end
	elseif cur_index == TabIndex.shenshou_compose then
		if self.compose_view then
			self.compose_view:Flush(param_t)
		end
	end
end

function ShenShouView:Reset(...)
	ItemCell.Reset(self, ...)
	local toggle = self.root_node.toggle
	toggle.interactable = true
end

function ShenShouView:FlushAnimation()
	if self.huanling_view then
		self.huanling_view:FlushAnimation()
	end
end

ShenShouEquip = ShenShouEquip or BaseClass(ItemCell)

function ShenShouEquip:__init()
	local toggle = self.root_node.toggle
	toggle.interactable = true
end

function ShenShouEquip:__delete()
	
end

function ShenShouEquip:SetData(data, is_from_bag)
	self:Reset()
	self.data = data
	if self.show_stars then
		for k, v in pairs(self.show_stars) do
			v:SetValue(false)
		end
	end
	if self.show_level_limit then
		self.show_level_limit:SetValue(false)
	end
	if self.show_prop_des then
		self.show_prop_des:SetValue(false)
	end
	if self.show_god_quality then
		self.show_god_quality:SetValue(false)
	end

	if self.show_gray then
		self.show_gray:SetValue(self.is_gray)
	end
	if self.show_red_point then
		self.show_red_point:SetValue(false)
	end

	if self.show_star_level then
		self.show_star_level:SetValue(false)
	end

	if self.show_up_arrow then
		self.show_up_arrow:SetValue(false)
	end

	if self.show_down_arrow then
		self.show_down_arrow:SetValue(false)
	end

	if nil ~= self.show_equip_grade then
		self.show_equip_grade:SetValue(false)
	end

	if nil ~= self.show_shen_ge_level then
		self.show_shen_ge_level:SetValue(false)
	end

	if nil ~= self.show_rome_image then
		self.show_rome_image:SetValue(false)
	end

	if nil ~= self.show_inlay_slot then
		self.show_inlay_slot:SetValue(false)
	end

	if nil ~= self.jueban then
		self.jueban:SetValue(false)
	end

	self:ShowToLeft(false)
	self:ShowRepairImage(false)
	self:ShowHaseGet(false)
	self:ShowGetEffect(false)
	self:ShowSpecialEffect(false)

	if not data or not next(data) then
		self.icon:ResetAsset()
		self.show_number:SetValue(false)
		self.show_strength:SetValue(false)
		self.show_prop_name:SetValue(false)
		self.bind:SetValue(false)
		self.number:SetValue(false)
		if self.show_quality then
			self.show_quality:SetValue(false)
		end
		if self.effect_obj then
			self.effect_obj:DeleteMe()
			-- GameObject.Destroy(self.effect_obj)
			self.effect_obj = nil
		end
		if self.show_time_limit then
			self.show_time_limit:SetValue(false)
		end
		self:SetRoleProf(false)
		return
	end
	self:SetInteractable(true)
	self:SetIconGrayScale(false)
	local shenshou_equip_cfg = ShenShouData.Instance:GetShenShouEqCfg(self.data.item_id)
	self.shenshou_equip_cfg = shenshou_equip_cfg
	if nil == shenshou_equip_cfg then return end

	--设置图标
	local bundle, asset = ResPath.GetItemIcon(shenshou_equip_cfg.icon_id)
	self.icon:SetAsset(bundle, asset)

	self.show_quality:SetValue(true)
	local quality = shenshou_equip_cfg.quality
	if shenshou_equip_cfg.is_equip == 1 then
		quality = quality + 1
	else
		quality = quality + 2
	end
	local bundle1, asset1 = ResPath.GetQualityIcon(quality)
	self.quality:SetAsset(bundle1, asset1)

	local star_count = 0
	if self.data.attr_list then
		for k,v in pairs(self.data.attr_list) do
			if v.attr_type > 0 then
				local random_cfg = ShenShouData.Instance:GetRandomAttrCfg(shenshou_equip_cfg.quality, v.attr_type) or {}
				if random_cfg.is_star_attr ==1 then
					star_count = star_count + 1
				end
			end
		end
	else
		star_count = self.data.param and self.data.param.star_level or 0
	end
	for i = 1, star_count do
		if self.show_stars[i] then
			self.show_stars[i]:SetValue(true)
		end
	end

	if self.name == "shenshou_bag" then
		local flag = ShenShouData.Instance:GetIsBetterShenShouEquip(self.data, self.select_shou_id or 0)
		self.show_up_arrow:SetValue(flag)
	else
		self.show_up_arrow:SetValue(false)
	end

	if self.data.strength_level and self.data.strength_level > 0 then
		self:ShowStrengthLable(true)
		self:SetStrength(self.data.strength_level)
	else
		self:ShowStrengthLable(false)
	end
end

function ShenShouEquip:SetShouId(select_shou_id)
	self.select_shou_id = select_shou_id
end