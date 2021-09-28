--装备-品质
ForgeQuality = ForgeQuality or BaseClass(ForgeBaseView)

function ForgeQuality:__init()
	--两个效果格子
	self.next_effect = QualityEffectCell.New(self:FindObj("NextQuality"),"quality")
	self.current_effect = QualityEffectCell.New(self:FindObj("CurrentQuality"))
	self.max_effect = QualityEffectCell.New(self:FindObj("MaxQuality"))
	-- 绑定点击事件
	self.mother_view:SetClickCallBack(TabIndex.forge_quality, BindTool.Bind(self.OnClick, self))

	self:ListenEvent("ClickGoGet", BindTool.Bind(self.ClickGoGet, self))
	self:ListenEvent("SendImproveQuality", BindTool.Bind(self.SendImproveQuality, self))

	self.root_node:SetActive(false)
	--模型展示
	self.model_display_max = self:FindObj("ModelDisplayMax")
	if nil ~= self.model_display_max then
		self.model_max = RoleModel.New()
		self.model_max:SetDisplay(self.model_display_max.ui3d_display)
	end
	self.model_display_cur = self:FindObj("ModelDisplayCur")
	if nil ~= self.model_display_cur then
		self.model_cur = RoleModel.New()
		self.model_cur:SetDisplay(self.model_display_cur.ui3d_display)
	end
	self.model_display_next = self:FindObj("ModelDisplayNext")
	if nil ~= self.model_display_next then
		self.model_next = RoleModel.New()
		self.model_next:SetDisplay(self.model_display_next.ui3d_display)
	end
end

function ForgeQuality:OnClick()
	self:Flush()
end

function ForgeQuality:__delete()
	if nil ~= self.model_max then
		self.model_max:DeleteMe()
		self.model_max = nil
	end

	if nil ~= self.model_cur then
		self.model_cur:DeleteMe()
		self.model_cur = nil
	end

	if nil ~= self.model_next then
		self.model_next:DeleteMe()
		self.model_next = nil
	end
end

--点击了前往获取
function ForgeQuality:ClickGoGet()
	self.mother_view:Close()
	ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_tower)
	FuBenCtrl.Instance:SendGetPhaseFBInfoReq()
	FuBenCtrl.Instance:SendGetExpFBInfoReq()
	FuBenCtrl.Instance:SendGetStoryFBGetInfo()
	FuBenCtrl.Instance:SendGetVipFBGetInfo()
	FuBenCtrl.Instance:SendGetTowerFBGetInfo()
end

function ForgeQuality:SetNextCfg()
	self.next_cfg = ForgeData.Instance:GetQualityCfg(self.data, true)
		--设置模型
	local model_index = "000" .. self.data.data_index + 1
	if nil ~= self.model_max then
		self.model_max:SetMainAsset(ResPath.GetForgeEquipModel(model_index))
	end
	if nil ~= self.model_cur then
		self.model_cur:SetMainAsset(ResPath.GetForgeEquipModel(model_index))
	end
	if nil ~= self.model_next then
		self.model_next:SetMainAsset(ResPath.GetForgeEquipModel(model_index))
	end
end

--刷新
function ForgeQuality:Flush()
	self:CommonFlush()
end

--不显示数据
function ForgeQuality:ShowEmpty()

end

--提升品质
function ForgeQuality:SendImproveQuality()
	if self.data == nil or self.data.param == nil then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end
	local improve_flag, item_id = ForgeData.Instance:CheckIsCanImprove(self.data, TabIndex.forge_quality)
	if improve_flag == 0 then
		ForgeCtrl.Instance:SendImproveQuality()
	elseif improve_flag == 1 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.UpEndHighest)
	elseif improve_flag == 2 then
		local func = function(item_id2, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
		end
		item_cfg = ItemData.Instance:GetItemConfig(item_id)
		TipsCtrl.Instance:ShowSystemMsg(ToColorStr(item_cfg.name, TEXT_COLOR.GREEN).."不足")
	end
end

----------------------------
--效果格子
----------------------------
QualityEffectCell = QualityEffectCell or BaseClass(ForgeBaseCell)
function QualityEffectCell:__init()
	self:InitType2()
	self.level_limit = self:FindVariable("LevelLimit")
	if self.is_next then
		self.promote_level = self:FindVariable("PromoteLevel")
	end
end

function QualityEffectCell:FlushCallBack()
	self:FlushType2()
	--强化等级上限
	local max_strengthen_level = ForgeData:GetStrengthenLevel(self.data)
	self.level_limit:SetValue("+"..max_strengthen_level)

	if self.is_next then
		--强化等级上限提升值
		local previous_max_strengthen_level = ForgeData:GetStrengthenLevel(self.previous_data)
		local change_value = max_strengthen_level - previous_max_strengthen_level
		self.promote_level:SetValue(change_value)
	end
end

function QualityEffectCell:ShowEmptyCallBack()
	self:ShowEmptyType2()
end
