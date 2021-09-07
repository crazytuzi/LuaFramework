require("game/beauty/beauty_info_view")
require("game/beauty/beauty_upgrade_view")
require("game/beauty/beauty_wish_view")
require("game/beauty/beauty_scheming_view")
require("game/beauty/beauty_pray_view")
require("game/beauty/beauty_xilian_view")
--------------------------------------------------------------------------
BeautyView = BeautyView or BaseClass(BaseView)

local Info_bg = "beauty_bg.png"
local Up_bg = "beauty_upgrade_bg.png"

function BeautyView:__init()
	self:SetMaskBg()
	self.ui_config = {"uis/views/beauty","BeautyView"}
	self.play_audio = true
end

function BeautyView:__delete()
end

function BeautyView:ReleaseCallBack()
	if self.info_view then
		self.info_view:DeleteMe()
		self.info_view = nil
	end
	if self.up_level_view then
		self.up_level_view:DeleteMe()
		self.up_level_view = nil
	end
	if self.wish_view then
		self.wish_view:DeleteMe()
		self.wish_view = nil
	end
	if self.scheming_view then
		self.scheming_view:DeleteMe()
		self.scheming_view = nil
	end
	if self.pray_view then
		self.pray_view:DeleteMe()
		self.pray_view = nil
	end

	if self.money then
		self.money:DeleteMe()
		self.money = nil
	end

	if self.xilian_content_view then
		self.xilian_content_view:DeleteMe()
		self.xilian_content_view = nil
	end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Beauty)
	end
	if self.item_change ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change)
		self.item_change = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	self.red_point_list = nil

	self.beauty_btn_active = nil
	self.beauty_btn_fit = nil
	self.btn_close = nil
	self.toggle_info = nil
	self.toggle_upgrade = nil
	self.toggle_wish = nil
	self.toggle_scheming = nil
	self.toggle_pray = nil
	self.toggle_xilian = nil

	-- self.show_info_red = nil
	-- self.show_upgrade_red = nil
	-- self.show_wish_red = nil
	-- self.show_scheming_red =nil
	-- self.show_pray_red = nil
	-- self.show_xilian_red = nil
end

function BeautyView:LoadCallBack()

	self:ListenEvent("Close", BindTool.Bind(self.HandleClose, self))

	self.money = MoneyBar.New()
	self.money:SetInstanceParent(self:FindObj("MoneyBar"))

	-- 标签页
	self.toggle_info = self:FindObj("TabInfo")
	self.toggle_upgrade = self:FindObj("TabUpgrade")
	self.toggle_wish = self:FindObj("TabWish")
	self.toggle_scheming = self:FindObj("TabScheming")
	self.toggle_pray = self:FindObj("TabPray")
	self.toggle_xilian = self:FindObj("TabXiLian")

	self.toggle_info.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleClick, self, TabIndex.beauty_info))
	self.toggle_upgrade.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleClick, self, TabIndex.beauty_upgrade))
	self.toggle_wish.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleClick, self, TabIndex.beauty_wish))
	self.toggle_scheming.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleClick, self, TabIndex.beauty_scheming))
	self.toggle_pray.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleClick, self, TabIndex.beauty_pray))
	self.toggle_xilian.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleClick, self, TabIndex.beauty_xilian))

	-- 检查功能是否开启
	self:CheckTabIsHide()

	self.info_view = BeautyInfoView.New()
	local info_content = self:FindObj("InfoContent")
	info_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.info_view:SetInstance(obj)
	end)

	self.up_level_view = BeautyUpgradeView.New()
	local up_content = self:FindObj("UpgradeContent")
	up_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.up_level_view:SetInstance(obj)
	end)

	self.wish_view = BeautyWishView.New()
	local wish_content = self:FindObj("WishContent")
	wish_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.wish_view:SetInstance(obj)
	end)

	self.scheming_view = BeautySchemingView.New()
	local scheming_content = self:FindObj("SchemingContent")
	scheming_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.scheming_view:SetInstance(obj)
	end)

	self.pray_view = BeautyPrayView.New()
	local pray_content = self:FindObj("PrayContent")
	pray_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.pray_view:SetInstance(obj)
	end)

	-- 洗练
	self.xilian_content_view = BeautyXiLianView.New()
	local xilian_content = self:FindObj("XiLianContent")
	xilian_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)		
		self.xilian_content_view:SetInstance(obj)
	end)

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Beauty, BindTool.Bind(self.GetUiCallBack, self))

	--引导用按钮
	self.btn_close = self:FindObj("BtnClose")

	if not self.item_change then
		self.item_change = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_change)
	end

	-- self.show_info_red = self:FindVariable("InfoRed")
	-- self.show_upgrade_red = self:FindVariable("UpgradeRed")
	-- self.show_wish_red = self:FindVariable("WishRed")
	-- self.show_scheming_red = self:FindVariable("SchemingRed")
	-- self.show_pray_red = self:FindVariable("PrayRed")

	--RemindManager.Instance:Bind(self.remind_change, RemindName.BeautyInfo)

	self.red_point_list = {
		[RemindName.BeautyInfo] = self:FindVariable("InfoRed"),
		[RemindName.BeautyUpgrade] = self:FindVariable("UpgradeRed"),
		[RemindName.BeautyWish] = self:FindVariable("WishRed"),
		[RemindName.BeautyScheming] = self:FindVariable("SchemingRed"),
		[RemindName.BeautyPray] = self:FindVariable("PrayRed"),
		[RemindName.BeautyXiLian] = self:FindVariable("XiLianRed"),
	}

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function BeautyView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

-- function BeautyView:CheckTabRed()
-- 	if self.show_info_red ~= nil then
-- 		self.show_info_red:SetValue(BeautyData.Instance:IsShowInfoRed())
-- 	end

-- 	if self.show_upgrade_red ~= nil then
-- 		self.show_upgrade_red:SetValue(BeautyData.Instance:IsShowUpgradeRed())
-- 	end

-- 	if self.show_wish_red ~= nil then
-- 		self.show_wish_red:SetValue(BeautyData.Instance:IsShowWishRed())
-- 	end

-- 	if self.show_scheming_red ~= nil then
-- 		self.show_scheming_red:SetValue(BeautyData.Instance:IsShowSchemingRed())
-- 	end

-- 	if self.show_pray_red ~= nil then
-- 		self.show_pray_red:SetValue(BeautyData.Instance:IsShowPrayRed())
-- 	end
-- end

function BeautyView:CheckTabIsHide()
	if not self:IsOpen() then return end
	self.toggle_info:SetActive(OpenFunData.Instance:CheckIsHide("beauty_info"))
	self.toggle_upgrade:SetActive(OpenFunData.Instance:CheckIsHide("beauty_upgrade"))
	self.toggle_wish:SetActive(OpenFunData.Instance:CheckIsHide("beauty_wish"))
	self.toggle_scheming:SetActive(OpenFunData.Instance:CheckIsHide("beauty_scheming"))
	self.toggle_pray:SetActive(OpenFunData.Instance:CheckIsHide("beauty_pray"))
	self.toggle_xilian:SetActive(OpenFunData.Instance:CheckIsHide("beauty_xilian"))
end

function BeautyView:HandleClose()
	self:Close()
end

function BeautyView:Open(index)
	BaseView.Open(self, index)
end

function BeautyView:OpenCallBack()
	-- if self.info_view then
	-- 	self.info_view:UpModelState()
	-- end
	BeautyCtrl:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_BASE_INFO)
end

function BeautyView:CheckRed()
	if self.red_point_list ~= nil then
		for k,v in pairs(self.red_point_list) do
			v:SetValue(RemindManager.Instance:GetRemind(k) > 0)
		end
	end
end

function BeautyView:CloseCallBack()

end

function BeautyView:ShowIndexCallBack(index)
	if index == TabIndex.beauty_info then
		self.toggle_info.toggle.isOn = true
	elseif index == TabIndex.beauty_upgrade then
		self.toggle_upgrade.toggle.isOn = true
	elseif index == TabIndex.beauty_wish then
		self.toggle_wish.toggle.isOn = true
	elseif index == TabIndex.beauty_scheming then
		self.toggle_scheming.toggle.isOn = true
	elseif index == TabIndex.beauty_pray then
		self.toggle_pray.toggle.isOn = true
	elseif self.show_index == TabIndex.beauty_xilian then
		self.toggle_xilian.toggle.isOn = true

		if HunQiData.Instance:GetXiLianRedPoint() then
			HunQiData.Instance:SetXiLianRedPoint(false)
			RemindManager.Instance:Fire(RemindName.BeautyXiLian)
		end
	end
	self:Flush()
end

function BeautyView:OnToggleClick(index, is_click)
	-- if self.show_index == index then return end
	if is_click then
		if self.up_level_view then
			self.up_level_view:SetIsGradeAuto(false)
		end
		self:ChangeToIndex(index)
	end
end

function BeautyView:OnFlush(param_t)
	--self:CheckTabRed()
	
	for k, v in pairs(param_t) do
		if k == "all" then
			if self.show_index == TabIndex.beauty_info then
				self.info_view:Flush("beauty_index", {item_id = v.item_id})
			elseif self.show_index == TabIndex.beauty_upgrade then
				self.up_level_view:Flush()
			elseif self.show_index == TabIndex.beauty_wish then
				self.wish_view:Flush()
			elseif self.show_index == TabIndex.beauty_scheming then
				self.scheming_view:Flush()
			elseif self.show_index == TabIndex.beauty_pray then
				self.pray_view:Flush()
			elseif self.show_index == TabIndex.beauty_xilian then
				if self.xilian_content_view then
					self.xilian_content_view:Flush()
				end
			end
		elseif k == "SkillSmmary" then
			self.up_level_view:Flush("SkillSmmary", v)
		elseif k == "xilian" and self.show_index == TabIndex.beauty_xilian then
			if self.xilian_content_view then
				self.xilian_content_view:FlushView()
			end
		end
	end	

	--self:CheckRed()
	--self.red_point_list[RemindName.BeautyUpgrade]:SetValue(BeautyData.Instance:IsShowUpgradeRed() > 0)
end

function BeautyView:ShowSkliiUplevel(types, index)
	self.scheming_view:ShowSkillUpLevel(types, index)
end

function BeautyView:SetAutoBeautyGrade(result)
	if self.show_index == TabIndex.beauty_upgrade then
		if self.up_level_view then
			if 0 == result then
				self.up_level_view:SetIsGradeAuto(false)
				self.up_level_view:SetBeautyButtonEnabled(true)
			else
				self.up_level_view:AutoBeautyGradeUpOnce()
			end
		end	
	end
end

function BeautyView:ShowDepot()
	if self.pray_view then
		self.pray_view:OnOpenDepotHandle()
	end
end

function BeautyView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		else
			return NextGuideStepFlag
		end
	else
		if not self.beauty_btn_active then
			self.beauty_btn_active = self.info_view:GetBtnActive()
		-- elseif not self.beauty_btn_fit then
		-- 	self.beauty_btn_fit = self.info_view:GetBtnFit()
		end
	end
end

function BeautyView:ItemDataChangeCallback()
	self:Flush()
end