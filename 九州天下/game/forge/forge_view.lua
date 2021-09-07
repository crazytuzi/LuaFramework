require("game/forge/forge_strengthen_view")
require("game/forge/forge_gem_view")
require("game/forge/forge_cast_view")
require("game/forge/forge_upstar_view")
require("game/forge/forge_spirit_soul_view")

ForgeView = ForgeView or BaseClass(BaseView)

function ForgeView:__init()
	self.ui_config = {"uis/views/forgeview", "ForgeView"}
	self.full_screen = false
	self.play_audio = true
	self.is_async_load = false
	self:SetMaskBg()

	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenDuanzao)
	end

	self.strengthen_view = nil
	self.gem_view = nil
	self.cast_view = nil
	self.up_star_view = nil

	self.toggle_list = {}
	self.view_list = {}

	self.def_index = TabIndex.forge_strengthen

	self.global_event = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.OpenTrigger, self))

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function ForgeView:__delete()
	if self.global_event ~= nil then
		GlobalEventSystem:UnBind(self.global_event)
		self.global_event = nil
	end
end

function ForgeView:ReleaseCallBack()
	self.is_open_strengthen = nil
	self.is_open_baoshi = nil
	self.is_open_cast = nil
	self.is_open_up_star = nil
	self.is_open_soul = nil
	self.tab_strengthen = nil
	self.tab_gems = nil
	self.tab_cast = nil
	self.tab_up_star = nil
	self.tab_guide_star = nil
 	self.now_view = nil
	self.toggle_list = {}
	self.view_list = {}
	self.red_point_list = nil
	self.soul_bg = nil
	self.show_soul_bg = nil

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.strengthen_view then
		self.strengthen_view:DeleteMe()
		self.strengthen_view = nil
	end

	if self.gem_view then
		self.gem_view:DeleteMe()
		self.gem_view = nil
	end

	if self.cast_view then
		self.cast_view:DeleteMe()
		self.cast_view = nil
	end

	if self.up_star_view then
		self.up_star_view:DeleteMe()
		self.up_star_view = nil
	end

	if self.soul_view then
		self.soul_view:DeleteMe()
		self.soul_view = nil
	end
	
	if self.equip_change_callback ~= nil then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_change_callback)
		self.equip_change_callback = nil
	end
	-- if self.item_data_event ~= nil then
	-- 	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	-- 	self.item_data_event = nil
	-- end

	if self.money_bar then
 		self.money_bar:DeleteMe()
 		self.money_bar = nil
  	end
end

function ForgeView:OpenTrigger()
	if self:IsOpen() then
		local is_open_strengthen = OpenFunData.Instance:CheckIsHide("forge_strengthen")
		local is_open_baoshi = OpenFunData.Instance:CheckIsHide("forge_baoshi")
		local is_open_cast = OpenFunData.Instance:CheckIsHide("forge_cast")
		local is_open_up_star = OpenFunData.Instance:CheckIsHide("forge_up_star")
		local is_open_soul = OpenFunData.Instance:CheckIsHide("forge_soul")

		if self.is_open_strengthen then
			self.is_open_strengthen:SetValue(is_open_strengthen)
		end
		if self.is_open_baoshi then
			self.is_open_baoshi:SetValue(is_open_baoshi)
		end
		if self.is_open_cast then
			self.is_open_cast:SetValue(is_open_cast)
		end
		if self.is_open_up_star then
			self.is_open_up_star:SetValue(is_open_up_star)
		end
		if self.is_open_soul then
			self.is_open_soul:SetValue(is_open_soul)
		end	
	end
end

function ForgeView:LoadCallBack()
	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))

	self.is_open_strengthen = self:FindVariable("is_open_strengthen")
	self.is_open_baoshi = self:FindVariable("is_open_baoshi")
	self.is_open_cast = self:FindVariable("is_open_cast")
	self.is_open_up_star = self:FindVariable("is_open_up_star")
	self.is_open_soul = self:FindVariable("is_open_soul")

	self:ListenEvent("CloseForgeView", BindTool.Bind(self.OnClose, self))

	self.tab_strengthen = self:FindObj("TabStrengthen")
	self.tab_gems = self:FindObj("TabGem")
	self.tab_cast = self:FindObj("TabCast")
	self.tab_up_star = self:FindObj("TabUpStar")
	self.tab_guide_star = self:FindObj("TabGuideStar")
	self.soul_bg = self:FindVariable("Soul_Bg")
	self.show_soul_bg = self:FindVariable("Show_Soul_Bg")

	self.tab_strengthen.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickTab, self, TabIndex.forge_strengthen))
	self.tab_gems.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickTab, self, TabIndex.forge_baoshi))
	self.tab_cast.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickTab, self, TabIndex.forge_cast))
	self.tab_up_star.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickTab, self, TabIndex.forge_up_star))
	self.tab_guide_star.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickTab, self, TabIndex.forge_soul))

	self.toggle_list = {
		[TabIndex.forge_strengthen] = self.tab_strengthen.toggle,
		[TabIndex.forge_baoshi] = self.tab_gems.toggle,
		[TabIndex.forge_cast] = self.tab_cast.toggle,
		[TabIndex.forge_up_star] = self.tab_up_star.toggle,
		[TabIndex.forge_soul] = self.tab_guide_star.toggle,
	}

	self.strengthen_view = ForgeStrengthen.New()
	local strength_content = self:FindObj("StrengthenContent")
	strength_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.strengthen_view:SetInstance(obj)
		self.now_view = self.strengthen_view
		self.btn_strength = self.strengthen_view.btn_strength
	end)

	self.gem_view = ForgeGem.New()
	local gem_content = self:FindObj("GemContent")
	gem_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.gem_view:SetInstance(obj)
		self.now_view = self.gem_view
	end)

	self.cast_view = ForgeCast.New()
	local cast_content = self:FindObj("CastContent")
	cast_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.cast_view:SetInstance(obj)
		self.now_view = self.cast_view
	end)

	self.up_star_view = ForgeUpStarView.New()
	local up_star_content = self:FindObj("UpStarContent")
	up_star_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.up_star_view:SetInstance(obj)
		self.now_view = self.up_star_view
	end)

	self.soul_view = ForgeSpiritSoulView.New()
	local soul_content = self:FindObj("GuideStarContent")
	soul_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.soul_view:SetInstance(obj)
		self.now_view = self.soul_view
	end)

	self.view_list = {
		[TabIndex.forge_strengthen] = self.strengthen_view,
		[TabIndex.forge_baoshi] = self.gem_view,
		[TabIndex.forge_cast] = self.cast_view,
		[TabIndex.forge_up_star] = self.up_star_view,
		[TabIndex.forge_soul] = self.soul_view,
	}

	self.red_point_list = {
		[RemindName.ForgeStrengthen] = self:FindVariable("StrengthenRedPoint"),
		[RemindName.ForgeGem] = self:FindVariable("BaoShiRedPoint"),
		[RemindName.ForgeCast] = self:FindVariable("CastRedPoint"),
		[RemindName.ForgeUpStar] = self:FindVariable("UpStarRedPoint"),
		[RemindName.SpiritSoulGet] = self:FindVariable("SpiritSoulRedPoint"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	if self.equip_change_callback == nil then
		self.equip_change_callback = BindTool.Bind(self.OnEquipDataChange, self)
		EquipData.Instance:NotifyDataChangeCallBack(self.equip_change_callback)
	end
end

function ForgeView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function ForgeView:OnClickTab(index, ison)
	if ison then
		self:ChangeToIndex(index)
	end
end

function ForgeView:OnClose()
	self:Close()
end

function ForgeView:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "flush_soul_view" then
			if self.soul_view then
				self.soul_view:Flush()
			end
		end
	end
	if self.strengthen_view ~= nil then
		self.strengthen_view:Flush()
	end
	if self.gem_view ~= nil then
		self.gem_view:Flush()
	end
	if self.cast_view ~= nil then
		self.cast_view:Flush()
	end
	if self.up_star_view ~= nil then
		self.up_star_view:Flush()
	end
end

function ForgeView:ShowIndexCallBack(index)
	self.show_soul_bg:SetValue(TabIndex.forge_soul == index)
	if	TabIndex.forge_soul == index then
		ForgeCtrl.Instance:SendSpiritSoulOperaReq(GameEnum.LIEMING_HUNSHOU_OPERA_TYPE_ORDER_BAG)	
	end
	self.now_view = self.view_list[index]
	self.toggle_list[index].isOn = true
	self:Flush()
end

function ForgeView:OpenCallBack()
	self:OpenTrigger()
	ForgeCtrl.Instance:SendStoneInfo()
end

--宝石改变回调
function ForgeView:OnGemChange()
	-- ForgeData.Instance:SetAllRedPoint()
	if self.gem_view ~= nil then
		self.gem_view:Flush()
	end
end

-- 宝石可以镶嵌
function ForgeView:OnInlayCan()
	if self.gem_view ~= nil then
		self.gem_view:SetCanInLayState(true)
	end
end

-- function ForgeView:ItemDataChangeCallback()
-- 	if self.strengthen_view ~= nil then
-- 		self.strengthen_view:Flush()
-- 	end
-- 	if self.gem_view ~= nil then
-- 		self.gem_view:Flush()
-- 	end
-- 	if self.cast_view ~= nil then
-- 		self.cast_view:Flush()
-- 	end
-- 	if self.up_star_view ~= nil then
-- 		self.up_star_view:Flush()
-- 	end
-- 	self:DoRemind()
-- end

function ForgeView:DoRemind()
	RemindManager.Instance:Fire(RemindName.ForgeStrengthen)
	RemindManager.Instance:Fire(RemindName.ForgeGem)
	RemindManager.Instance:Fire(RemindName.ForgeCast)
	RemindManager.Instance:Fire(RemindName.ForgeUpStar)
	RemindManager.Instance:Fire(RemindName.SpiritSoulGet)
end

--身上装备改变后的回调函数
function ForgeView:OnEquipDataChange()
	if not self:IsLoaded() then
		return
	end
	if self.now_view ~= nil then
		self.now_view:Flush()
	end
	if self.now_view == self.strengthen_view then
		self.strengthen_view:FlushFloatLabel()
	end
	-- ForgeData.Instance:SetAllRedPoint()
end

function ForgeView:IsSoulBg(value)
	 if self.soul_bg then
	 	self.soul_bg:SetValue(value)
	 end
end