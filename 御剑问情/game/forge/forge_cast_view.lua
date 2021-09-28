-- --装备-品质
ForgeCast = ForgeCast or BaseClass(ForgeBaseView)

function ForgeCast:__init()
	ForgeCast.Instcance = self
	self.cur_effect_obj = self:FindObj("CurrentEffect")
	-- self.effect_fly_begin_point = self:FindObj("effect_fly_begin_point")

	self.current_effect = CastEffectCell.New(self.cur_effect_obj, nil, FORGE_TYPE.SHENZHU)

	-- 绑定点击事件
	self.mother_view:SetClickCallBack(TabIndex.forge_cast, BindTool.Bind(self.OnClick, self))
	--升级按钮
	self:ListenEvent("SendCast", BindTool.Bind(self.SendCast, self))
	self:ListenEvent("ClickGoGet", BindTool.Bind(self.ClickGoGet, self))
	self:ListenEvent("OpenTotalCast", BindTool.Bind(self.OpenTotalCast, self))
	self:ListenEvent("CloseTotalCast", BindTool.Bind(self.CloseTotalCast, self))
	-- self:ListenEvent("IconClick", BindTool.Bind(self.IconClick, self))
	self:ListenEvent("HelpClick", BindTool.Bind(self.HelpClick, self))

	-- self.effect_point_list = {}
	-- self.effect_gameobject_list = {}
	-- self.star_img_list = {}
	self.show_level_list = {}

	for i=1,10 do
		-- self.effect_point_list[i] = self:FindObj("effect_point_"..i)
		self.show_level_list[i] = self:FindVariable("show_level_"..i)
		-- self.show_effect_list[i] = self:FindVariable("show_effect_"..i)
	end
	self.now_level = 0

	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self:FindObj("CurEquipCell"))

	self.cur_name = self:FindVariable("CurName")
	self.cur_level = self:FindVariable("CurLevel")
	self.is_show_cur_level = self:FindVariable("ShowCurLevel")

	self.model_display_cur = self:FindObj("ModelDisplayCur")
	if nil ~= self.model_display_cur then
		self.model_cur = RoleModel.New()
		self.model_cur:SetDisplay(self.model_display_cur.ui3d_display)
	end
	self.effect_cur = self:FindVariable("effect_cur")
	self.effect_glow_cur = self:FindVariable("effect_glow_cur")
	self.show_zhanli = self:FindVariable("show_zhanli")
	self.show_zhanli:SetValue(false)
end

function ForgeCast:OnClick()
	local cur_item_data = ForgeData.Instance:GetCurItemData()
	self.now_level = 0 
	self:SetEquipModel(cur_item_data)
	self:Flush()
end

function ForgeCast:__delete()
	self.mother_view = nil

	if nil ~= self.model_cur then
		self.model_cur:DeleteMe()
		self.model_cur = nil
	end

	if nil ~= self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end

	if nil ~= self.model_next then
		self.model_next:DeleteMe()
		self.model_next = nil
	end

	if nil ~= self.current_effect then
		self.current_effect:DeleteMe()
		self.current_effect = nil
	end

	self:CancelReleaseTimer()
end

function ForgeCast:HelpClick()
	local tips_id = 153    -- 神铸tips
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ForgeCast:CancelReleaseTimer()
	if nil ~= self.temp_timer then
		GlobalTimerQuest:CancelQuest(self.temp_timer)
		self.temp_timer = nil
	end

	if nil ~= self.asset_delay then
		GlobalTimerQuest:CancelQuest(self.asset_delay)
		self.asset_delay = nil
	end
end

function ForgeCast:SetEquipModel(data)
	--设置模型
	self.equip_cell:SetData(data)
	self.equip_cell:ShowStrengthLable(false)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then
		return
	end
	self.cur_name:SetValue(item_cfg.name)
	-- local color = item_cfg.color
	-- local bundle, asset = ResPath.GetForgeEquipBgEffect(color)
	-- local bundle_glow, asset_glow = ResPath.GetForgeEquipGlowEffect(color)

	-- local model_index = "000" .. data.data_index + 1

	-- if data.param.shen_level <= 10 then
	-- 	if nil ~= self.model_cur then
	-- 		self.model_cur:SetMainAsset(ResPath.GetForgeEquipModel(model_index))
	-- 		self:FlushFlyAniCur()
	-- 	end
	-- 	if nil ~= self.model_next then
	-- 		self.model_next:SetMainAsset(ResPath.GetForgeEquipModel(model_index))
	-- 		self:FlushFlyAniNext()
	-- 	end

	-- 	if nil ~= self.asset_delay then
	-- 		GlobalTimerQuest:CancelQuest(self.asset_delay)
	-- 		self.asset_delay = nil
	-- 	end
	-- 	-- self.asset_delay = GlobalTimerQuest:AddDelayTimer(function()
	-- 	-- 	if self.cur_effect_obj:GetActive() then
	-- 	-- 		self.effect_cur:SetAsset(bundle, asset)
	-- 	-- 		self.effect_glow_cur:SetAsset(bundle_glow, asset_glow)
	-- 	-- 		GlobalTimerQuest:CancelQuest(self.asset_delay)
	-- 	-- 		self.asset_delay = nil
	-- 	-- 	end
	-- 	-- end, 0.1)
	-- end
end

--model_cur
function ForgeCast:FlushFlyAniCur()
	if self.tweener_cur then
		self.tweener_cur:Pause()
	end
	self.model_display_cur.rect:SetLocalScale(0, 0, 0)
	local target_scale = Vector3(1, 1, 1)
	self.tweener_cur = self.model_display_cur.rect:DOScale(target_scale, 0.5)
end
--model_next
function ForgeCast:FlushFlyAniNext()
	if self.tweener_next then
		self.tweener_next:Pause()
	end
end

function ForgeCast:CloseUpStarView()
	if self.tweener_cur then
		self.tweener_cur:Pause()
		self.tweener_cur = nil
	end
	if self.tweener_next then
		self.tweener_next:Pause()
		self.tweener_next = nil
	end
	if self.tweener_max then
		self.tweener_max:Pause()
		self.tweener_max = nil
	end
end

function ForgeCast:SetNextCfg()
	self.next_cfg = ForgeData.Instance:GetCastCfg(self.data, true)

end

function ForgeCast:IconClick()
	TipsCtrl.Instance:ShowItemGetWayView(self.next_cfg.stuff_id)
end

--不显示数据
function ForgeCast:ShowEmpty()
end

function ForgeCast:FlyEffect()
	local item_data = ForgeData.Instance:GetCurItemData() or {}
	local param = item_data.param or {}

 	local level = param.shen_level or 0
 	if level < self.now_level then
 		return
 	end
 	self.now_level = level
	self:FlushStar(level)
	-- local shen_level = ForgeData.Instance:GetCurItemData().param.shen_level
	-- local temp = shen_level%5
	-- local index = temp ~= 0 and temp or 5
	-- self.show_effect_list[index]:SetValue(false)
	-- self.show_effect_list[index]:SetValue(true)
	-- TipsCtrl.Instance:ShowFlyEffectManager(ViewName.Forge, "effects/prefabs", "UI_guangdian1", self.effect_fly_begin_point, self.effect_point_list[index], nil, 1)
end

--点击了前往获取
function ForgeCast:ClickGoGet()
	ViewManager.Instance:Open(ViewName.Treasure)
end

function ForgeCast:OpenCallback()
	self:CancelReleaseTimer()
end

--打开全身神铸
function ForgeCast:OpenTotalCast()
	local level, current_cfg, next_cfg = ForgeData.Instance:GetFullCastLevel()
	TipsCtrl.Instance:ShowTotalAttrView(Language.Forge.ForgeCastSuitAtt, level, current_cfg, next_cfg)
end

--关闭全身神铸
function ForgeCast:CloseTotalCast()
	self.full_cast_tips:SetActive(false)
end

function ForgeCast:OnFlush(paramt)
	for k,v in pairs(paramt) do
		if k == "shen_fly_effect" then
			self:FlyEffect()
		else
			local cur_data = ForgeData.Instance:GetCurItemData()
			if cur_data ~= nil and next(cur_data) then
				self.show_zhanli:SetValue(true)
			else
				self.show_zhanli:SetValue(false)
			end
			self:FlyEffect()
			self:CommonFlush()
		end
	end
	self.current_effect:FlushCallBack()
end

function ForgeCast:FlushEffect()
	for i=1,10 do
		-- self:PlayShenZhuEffect(effect_list[i])
	end
end

function ForgeCast:FlushStar(level)
	-- local effect_list = ForgeData.Instance:GetShenZhuEffect()
	for i = 1, 10 do
		self.show_level_list[i]:SetValue(i <= level)
	end
	self.cur_level:SetValue(Language.Forge.ShengLevel[level])
	self.is_show_cur_level:SetValue(level > 0)
end

--点击了神铸
function ForgeCast:SendCast()
	if self.data == nil or self.data.item_id == nil then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end
	local improve_flag, item_id = ForgeData.Instance:CheckIsCanImprove(self.data, TabIndex.forge_cast)
	if improve_flag == 0 then
		local level = ForgeData.Instance:GetCurItemData().param.shen_level + 1
		self.now_level = level
		self:FlushStar(level)
		ForgeCtrl.Instance:SendCast()
	elseif improve_flag == 1 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.CastEndHighest)
	elseif improve_flag == 2 then
		local func = function(item_id2, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
		end
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
	end
end

function ForgeCast:PlayShenZhuEffect(list)
	local index = list[1]
	if self.effect_gameobject_list[index] then
		GameObject.Destroy(self.effect_gameobject_list[index].gameObject)
		self.effect_gameobject_list[index] = nil
	end
	-- PrefabPool.Instance:Load(AssetID("uis/images_atlas", "Star1"..index), function (prefab)
	-- 	if nil == prefab then
	-- 		return
	-- 	end
	-- 	local obj = GameObject.Instantiate(prefab)
	-- 	local obj_transform = obj.transform
	-- 	obj_transform:SetParent(self.effect_point_list[index].transform, false)
	-- 	table.insert(self.effect_gameobject_list, obj_transform)
	-- 	PrefabPool.Instance:Free(prefab)
	-- end)

end

----------------------------
-- 效果格子
----------------------------
CastEffectCell = CastEffectCell or BaseClass(ForgeBaseCell)

function CastEffectCell:__init()
	self:InitType2()
end

function CastEffectCell:FlushCallBack()
	self:FlushType2()
end


function CastEffectCell:ShowEmptyCallBack()
	self:ShowEmptyType2()
end
