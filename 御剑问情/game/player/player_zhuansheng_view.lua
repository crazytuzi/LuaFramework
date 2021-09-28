PlayerZhuanShengView = PlayerZhuanShengView or BaseClass(BaseRender)

local EFFECT_CD = 1

function PlayerZhuanShengView:__init(instance, parent_view)
	PlayerZhuanShengView.Instance = self
	self.parent_view = parent_view
	self.weapon_list = self:FindObj("WeaponList")
	self.item_list = {}
	self.effect_cd = 0
	for i=1,8 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item"..i))
		self.item_list[i]:SetToggleGroup(self.weapon_list.toggle_group)
		self.item_list[i]:ListenClick(BindTool.Bind(self.OnClickEquipItem, self, i))
	end
	self:AddListenEvent()

end

function PlayerZhuanShengView:__delete()

	if self.flush_resolve_event ~= nil then
		GlobalEventSystem:UnBind(self.flush_resolve_event)
		self.flush_resolve_event = nil
	end

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.cur_strengthen = nil
	self.effect_cd = nil
	self.parent_view = nil
end

function PlayerZhuanShengView:AddListenEvent()
	self:ListenEvent("OnClickHelp",BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickGoKill",BindTool.Bind(self.OnClickGoKill, self))
end

function PlayerZhuanShengView:OnClickGoKill()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.kf_boss)
end

function PlayerZhuanShengView:OnClickHelp()
	local tip_id = 3
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

----------------------转生界面-----------------------------
function PlayerZhuanShengView:OnClickEquipItem(index)
	local zhuansheng_info = ZhuanShengData.Instance:GetZhuanShengInfo()
	local equip_list = zhuansheng_info.zhuansheng_equip_list
	if equip_list[index - 1].item_id > 0 then
		local close_call_back = function()
			self.item_list[index]:SetHighLight(false)
		end
		--弹出武器信息显示面板
		TipsCtrl.Instance:OpenItem(equip_list[index - 1],TipsFormDef.FROM_ZHUANSHENG_VIEW, nil, close_call_back)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NormalEquipGetTip)
	end
end

function PlayerZhuanShengView:SetDefultToggle()
	self:FlushWeaponViewInfo()
end

function PlayerZhuanShengView:FlushWeaponViewInfo()
	--刷新转生装备面板信息
	local zhuansheng_info = ZhuanShengData.Instance:GetZhuanShengInfo()
	local zhuansheng_cfg = ZhuanShengData.Instance:GetZsCfgByZsLevel(zhuansheng_info.zhuansheng_level)
	if zhuansheng_info and zhuansheng_cfg then
		if self.cur_strengthen and self.cur_strengthen ~= zhuansheng_info.zhuansheng_level and self.effect_cd < Status.NowTime then
			self.effect_cd = Status.NowTime + EFFECT_CD
		end

		self:FlushItemList(zhuansheng_info,zhuansheng_cfg)

		self.cur_strengthen = zhuansheng_info.zhuansheng_level
	end
end

function PlayerZhuanShengView:FlushItemList(zhuansheng_info,zhuansheng_cfg)
	--刷新装备list
	local equip_list = ZhuanShengData.Instance:GetEquipShowList()
	for i=1,8 do
		local data = zhuansheng_info.zhuansheng_equip_list[i-1]
		if data.item_id <= 0 then
			local temp_data = {item_id = equip_list[i-1].rare_item_id, is_gray = true}
			data.is_gray = true
			self.item_list[i]:SetData({item_id = equip_list[i-1].rare_item_id})
			local item_cfg, big_type = ItemData.Instance:GetItemConfig(temp_data.item_id)
			if item_cfg then
				self.item_list[i]:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
			end
			self.item_list[i]:ShowQuality(false)
			self.item_list[i]:SetRoleProf(false)
		else
			data.is_gray = false
			self.item_list[i]:ShowQuality(true)
			self.item_list[i]:SetData(data)
		end
		self.item_list[i]:SetIconGrayScale(data.is_gray)
		-- self.item_list[i]:ShowHighLight(not data.is_gray)
	end
end