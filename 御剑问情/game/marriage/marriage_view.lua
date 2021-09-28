require("game/marriage/marriage_honeymoon_view")
require("game/marriage/equip/marry_equip_content_view")
require("game/marriage/marriage_rings_view")
require("game/marriage/marriage_fuben_view")
require("game/marriage/baobao/baobao_view")
require("game/marriage/marriage_halo_content")
require("game/marriage/shengdi/qingyuan_shengdi_view")
require("game/marriage/marriage_love_tree_view")

MarriageView = MarriageView or BaseClass(BaseView)

local async_load_list = {
	-- 结婚面板
	[TabIndex.marriage_honeymoon] = {"uis/views/marriageview_prefab", "HoneyMoonContentView"},
	[TabIndex.marriage_ring] = {"uis/views/marriageview_prefab", "RingView"},
	[TabIndex.marriage_equip] = {"uis/views/marriageview_prefab", "MarryEquipContentView"},
	[TabIndex.marriage_fuben] = {"uis/views/marriageview_prefab", "FuBenContentView"},
	[TabIndex.marriage_love_halo] = {"uis/views/marriageview_prefab", "HaloContent"},
	[TabIndex.marriage_shengdi] = {"uis/views/marriageview_prefab", "QingYuanShengDiView"},
	[TabIndex.marriage_love_tree] = {"uis/views/marriageview_prefab", "LoveTreeContent"},
	-- 查看结婚信息

}
async_load_list[TabIndex.marriage_monomer] = async_load_list[TabIndex.marriage_honeymoon]

function MarriageView:__init()
	self.ui_config = {"uis/views/marriageview_prefab","MarriageView"}
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenMarry)
	end
	self.play_audio = true
	self.full_screen = true
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.async_load_call_back = BindTool.Bind(self.AsyncLoadCallBack, self)
end

function MarriageView:__delete()

end

function MarriageView:ReleaseCallBack()
	if self.marriage_honeymoon_view then
		self.marriage_honeymoon_view:DeleteMe()
		self.marriage_honeymoon_view = nil
	end

	if self.marriage_rings_view then
		self.marriage_rings_view:DeleteMe()
		self.marriage_rings_view = nil
	end

	if self.equip_view then
		self.equip_view:DeleteMe()
		self.equip_view = nil
	end

	if self.marriage_fuben_view then
		self.marriage_fuben_view:DeleteMe()
		self.marriage_fuben_view = nil
	end

	if self.halo_view then
		self.halo_view:DeleteMe()
		self.halo_view = nil
	end

	if self.shengdi_view then
		self.shengdi_view:DeleteMe()
		self.shengdi_view = nil
	end

	if self.love_tree_view then
		self.love_tree_view:DeleteMe()
		self.love_tree_view = nil
	end

	if self.baobao_view then
		self.baobao_view:DeleteMe()
		self.baobao_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end


	self.red_point_list = nil

	-- 清理变量和对象
	self.gold = nil
	self.bind_gold = nil
	self.tab_lover = nil
	self.tab_ring = nil
	self.honeymoon_red_point = nil
	self.tab_honeymoon = nil
	self.tab_fb = nil
	self.tab_baobao = nil
	self.tab_equip = nil
	self.toggle_honeymoon = nil
	self.fb_toggle = nil
	self.baobao_toggle = nil
	self.tab_ring = nil
	self.is_marry = nil
	self.toggle_ring = nil
	self.tab_halo = nil
	self.equip_toggle = nil
	self.halo_toggle = nil
	self.shengdi_toggle = nil
	self.tab_shengdi = nil
	self.honeymoon_content = nil
	self.rings_content = nil
	self.equip_content = nil
	self.fuben_content = nil
	self.halo_content = nil
	self.shengdi_content = nil
	self.love_tree_toggle = nil
	self.tab_love_tree = nil
	self.love_tree_content = nil
end

function MarriageView:LoadCallBack()
	self:ListenEvent("Close",BindTool.Bind(self.ClickClose, self))
	self:ListenEvent("AddGold",BindTool.Bind(self.HandleAddGold, self))
	self:ListenEvent("ClickEquipTab",BindTool.Bind(self.ClickEquipTab, self))
	self:ListenEvent("ClickHalo",BindTool.Bind(self.ClickHalo, self))
	self:ListenEvent("ClickShengdiTab",BindTool.Bind(self.ClickShengdiTab, self))
	self:ListenEvent("ClickHoneyMoon",BindTool.Bind(self.ClickHoneyMoon, self))
	self:ListenEvent("ClickFuBen",BindTool.Bind(self.ClickFuBen, self))
	self:ListenEvent("ClickRingTab",BindTool.Bind(self.ClickRingTab, self))
	self:ListenEvent("ClickLoveTreeTab",BindTool.Bind(self.ClickLoveTreeTab, self))

	self.is_marry = self:FindVariable("IsMarry")

	self.honeymoon_content = self:FindObj("HoneyMoonView")
	self.rings_content = self:FindObj("WeddingRingView")
	self.equip_content = self:FindObj("EquipView")
	self.fuben_content = self:FindObj("FuBenView")
	self.halo_content = self:FindObj("HaloContent")
	self.shengdi_content = self:FindObj("ShengDiView")
	self.love_tree_content = self:FindObj("LoveTreeContent")

	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("BindGold")
	self.tab_honeymoon = self:FindObj("ToggleHoneymoon")
	self.tab_ring = self:FindObj("WeddingRingToggle")
	self.tab_fb = self:FindObj("FbToggle")
	self.tab_equip = self:FindObj("EquipToggle")
	self.tab_baobao = self:FindObj("BaobaoToggle")
	self.tab_halo = self:FindObj("HaloToggle")
	self.tab_shengdi = self:FindObj("TabQingYuanShengDi")
	self.tab_love_tree = self:FindObj("TabLoveTree")

	self.toggle_honeymoon = self.tab_honeymoon.toggle
	self.toggle_ring = self.tab_ring.toggle
	self.fb_toggle = self.tab_fb.toggle
	self.equip_toggle = self.tab_equip.toggle
	self.baobao_toggle = self.tab_baobao.toggle
	self.halo_toggle = self.tab_halo.toggle
	self.shengdi_toggle = self.tab_shengdi.toggle
	self.love_tree_toggle = self.tab_love_tree.toggle

	self.toggle_honeymoon:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_honeymoon))
	self.toggle_ring:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_ring))
	self.fb_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_fuben))
	self.baobao_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_baobao))

	self.red_point_list = {
		[RemindName.HoneyMoon] = self:FindVariable("HoneyMoonRedPoint"),
		[RemindName.MarryFuBen] = self:FindVariable("ShowFuBenRedPoint"),
		[RemindName.MarryRing] = self:FindVariable("ShowRingRedPoint"),
		[RemindName.MarryEquip] = self:FindVariable("ShowEquipRedPoint"),
		[RemindName.MarryEquipRecyle] = self:FindVariable("ShowEquipRedPoint"),
		[RemindName.MarrySuit] = self:FindVariable("ShowEquipRedPoint"),
		[RemindName.MarryCoupHalo] = self:FindVariable("ShowHaloRedPoint"),
		[RemindName.ShengDiGroup] = self:FindVariable("ShowShengDiRedPoint"),
		[RemindName.MarryLoveTree] = self:FindVariable("ShowLoveTreeRemind"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
	RemindManager.Instance:Fire(RemindName.MarryFuBen)
	-- RemindManager.Instance:Fire(RemindName.MarryRing)
end

function MarriageView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		if remind_name == RemindName.MarryEquip or remind_name == RemindName.MarrySuit or remind_name == RemindName.MarryEquipRecyle then
			local remind_m = RemindManager.Instance
			local num = remind_m:GetRemind(RemindName.MarryEquip) + remind_m:GetRemind(RemindName.MarrySuit) + remind_m:GetRemind(RemindName.MarryEquipRecyle)
			self.red_point_list[remind_name]:SetValue(num > 0)
			self:Flush("equip")
		else
			self.red_point_list[remind_name]:SetValue(num > 0)
		end
	end
end

--是否已婚
function MarriageView:CheckIsMarry()
	return MarriageData.Instance:CheckIsMarry()
end

function MarriageView:ShowOrHideTab()
	local show_list = {}
	local open_fun_data = OpenFunData.Instance
	show_list["tab_honeymoon"] = open_fun_data:CheckIsHide("marriage_honeymoon")
	show_list["tab_halo"] = open_fun_data:CheckIsHide("marriage_halo")
	show_list["tab_fb"] = open_fun_data:CheckIsHide("marriage_fuben")
	show_list["tab_baobao"] = open_fun_data:CheckIsHide("marriage_baobao")
	show_list["tab_equip"] = open_fun_data:CheckIsHide("marriage_equip")
	show_list["tab_shengdi"] = open_fun_data:CheckIsHide("marriage_shengdi")
	show_list["tab_love_tree"] = open_fun_data:CheckIsHide("marriage_love_tree")

	for k,v in pairs(show_list) do
		if self[k] then
			self[k]:SetActive(v)
		end
	end
end

function MarriageView:OnToggleChange(index, is_on)
	if is_on then
		self:ChangeToIndex(index)
	end
	if self.marriage_rings_view then
		self.marriage_rings_view:StopAutoUpgrade()
	end
	self.cur_index = index
	if index == TabIndex.marriage_honeymoon and is_on then
		if self.marriage_honeymoon_view then
			self.marriage_honeymoon_view:FlushDisPlay()
		end
	end

	if index == TabIndex.marriage_ring then
		if self.marriage_rings_view then
			self.marriage_rings_view:Flush()
		end
	end

	if not is_on then return end
	if self.cur_index == TabIndex.marriage_baobao then
		if self.select_baobao_guard then
			if self.baobao_view then
				self.select_baobao_guard = false
				self.baobao_view:SelectBaoBaoGuard()
			end
		else
			if self.baobao_view then
				self.baobao_view:OpenBaobaoCallBack()
			end
		end
	elseif self.cur_index == TabIndex.marriage_halo then
		if self.open_interact_index then
			if self.halo_view then
				self.halo_view:ShowHaloIndex(self.open_interact_index)
			end
			self.open_interact_index = nil
		else
			if self.halo_view then
				self.halo_view:OpenHaloCallBack()
			end
		end
	elseif self.cur_index == TabIndex.marriage_honeymoon then
		if self.open_tuodan_list then
			if self.marriage_honeymoon_view then
				self.open_tuodan_list = false
				self.marriage_honeymoon_view:FlushDisPlay()
			end
		else
			if self.marriage_honeymoon_view then
				 if self.tab_honeymoon.toggle.isOn then
					self.marriage_honeymoon_view:FlushDisPlay()
				end
			end
		end
	end
end

function MarriageView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.marriage_honeymoon_view then
		self.marriage_honeymoon_view:CloseCallBack()
	end

	if self.marriage_rings_view then
		self.marriage_rings_view:CloseCallBack()
	end

	if self.fun_open_bind then
		GlobalEventSystem:UnBind(self.fun_open_bind)
		self.fun_open_bind = nil
	end
end

function MarriageView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function MarriageView:OpenCallBack()
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])

	MarriageCtrl.Instance:SendQingYuanFBInfoReq()
	BaobaoCtrl.SendAllBabyInfoReq()
	MarriageCtrl.Instance:SendQingyuanLoveContractInfoReq()

	self:ShowOrHideTab()

	self.fun_open_bind = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowOrHideTab, self))
	self.is_marry:SetValue(self:CheckIsMarry())

	MarriageData.Instance:SetTempCoupleHaloLevelList()
end

function MarriageView:ClickClose()
	self:Close()
end

function MarriageView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.gold:SetValue(CommonDataManager.ConverMoney(vo.gold))
	end
	if attr_name == "bind_gold" then
		self.bind_gold:SetValue(CommonDataManager.ConverMoney(vo.bind_gold))
	end
end

function MarriageView:RingChange()
	if self:IsLoaded() then
		if self.marriage_rings_view then
			self.marriage_rings_view:Flush()
		end
	end
end

function MarriageView:BlessChange()
	if self:IsLoaded() then
		if self.marriage_rings_view then
			self.marriage_rings_view:Flush()
		end
	end
end

function MarriageView:OnFuBenChange()
	if self:IsLoaded() then
		if self.marriage_fuben_view then
			self.marriage_fuben_view:Flush()
		end
		if self.toggle_honeymoon.isOn then
			MarriageCtrl.Instance:FlushWeddingView()
		end
	end
end

function MarriageView:ClickHoneyMoon()
	self:ShowIndex(TabIndex.marriage_honeymoon)
end

function MarriageView:ClickFuBen()
	self:ShowIndex(TabIndex.marriage_fuben)
end

function MarriageView:ClickEquipTab()
	self:ShowIndex(TabIndex.marriage_equip)
end

--婚戒
function MarriageView:ClickRingTab()
	self:ShowIndex(TabIndex.marriage_ring)
	local ring_had_active = MarriageData.Instance:GetRingHadActive()
	if ring_had_active then
		--戒指已激活
		-- TipsCtrl.Instance:ShowRingInfo()
	else
		--戒指未激活
		if self:CheckIsMarry() then
			--已结婚
			TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Activate_Ring)
		else
			--未结婚
			self.marriage_rings_view:ShowGoToMarryTips()
		end
	end
end

--相思树
function MarriageView:ClickLoveTreeTab()
	self:ShowIndex(TabIndex.marriage_love_tree)
end

function MarriageView:MarryStateChange()
	self.is_marry:SetValue(self:CheckIsMarry())
	if self.toggle_honeymoon.isOn and self.marriage_honeymoon_view then
		self.marriage_honeymoon_view:MarryStateChange()
		self.marriage_honeymoon_view:ShowOrHideTab()
	end

	if self.halo_toggle.isOn and self.halo_view then
		self.halo_view:FlushLoverModel()
		self.halo_view:FlushRoleContent()
	end
end

function MarriageView:ClickHalo()
	self:ShowIndex(TabIndex.marriage_love_halo)
end

function MarriageView:ClickShengdiTab()
	-- 红点处理
	ClickOnceRemindList[RemindName.MarryShengDi] = 0
	RemindManager.Instance:CreateIntervalRemindTimer(RemindName.MarryShengDi)

	self:ShowIndex(TabIndex.marriage_shengdi)
end

function MarriageView:AsyncLoadCallBack(index, obj)
	if index == TabIndex.marriage_honeymoon or index == TabIndex.marriage_monomer then
		obj.transform:SetParent(self.honeymoon_content.transform, false)
		obj = U3DObject(obj)
		self.marriage_honeymoon_view = MarriageHoneymoonView.New(obj)
		self.marriage_honeymoon_view:ShowOrHideTab()
		self.marriage_honeymoon_view:ShowIndexCallBack()
		if self.open_tuodan_list then
			self.open_tuodan_list = false
			self.marriage_honeymoon_view:FlushDisPlay()
		end
	elseif index == TabIndex.marriage_ring then
		obj.transform:SetParent(self.rings_content.transform, false)
		obj = U3DObject(obj)
		self.marriage_rings_view = MarriageRingView.New(obj)
		self.marriage_rings_view:ShowOrHideTab()
		self.marriage_rings_view:Flush()

	elseif index == TabIndex.marriage_equip then
		obj.transform:SetParent(self.equip_content.transform, false)
		obj = U3DObject(obj)
		self.equip_view = MarryEquipContentView.New(obj, self)
		self.equip_view:ShowOrHideTab()
		self.equip_view:OpenCallBack()

	elseif index == TabIndex.marriage_fuben then
		obj.transform:SetParent(self.fuben_content.transform, false)
		obj = U3DObject(obj)
		self.marriage_fuben_view = MarriageFuBenView.New(obj)
		self.marriage_fuben_view:ShowOrHideTab()
		self.marriage_fuben_view:Flush()

	elseif index == TabIndex.marriage_love_halo then
		obj.transform:SetParent(self.halo_content.transform, false)
		obj = U3DObject(obj)
		self.halo_view = MarriageHaloContent.New(obj, self)
		self.halo_view:InitView()

	elseif index == TabIndex.marriage_shengdi then
		obj.transform:SetParent(self.shengdi_content.transform, false)
		obj = U3DObject(obj)
		self.shengdi_view = QingYuanShengDiView.New(obj, self)
		self.shengdi_view:ShowOrHideTab()
		self.shengdi_view:OpenCallBack()

	elseif index == TabIndex.marriage_love_tree then
		obj.transform:SetParent(self.love_tree_content.transform, false)
		obj = U3DObject(obj)
		self.love_tree_view = MarriageLoveTreeView.New(obj, self)
		self.love_tree_view:InitView()
	end
end

--决定显示那个界面
function MarriageView:ShowIndexCallBack(index)
	local asset_bundle_list = async_load_list[index] or {}
	self:AsyncLoadView(index, asset_bundle_list[1], asset_bundle_list[2], self.async_load_call_back)

	if index == TabIndex.marriage_honeymoon then
		self.toggle_honeymoon.isOn = true
		if self.marriage_honeymoon_view then
			self.marriage_honeymoon_view:FLushMarryGiftBtn()
		end
	elseif index == TabIndex.marriage_ring and self.toggle_ring.isActiveAndEnabled then
			self.toggle_ring.isOn = true
	elseif index == TabIndex.marriage_fuben then
			self.fb_toggle.isOn = true
	elseif index == TabIndex.marriage_equip
		or index == TabIndex.marriage_equip_suit
		or index == TabIndex.marriage_equip_recyle then
		self.tab_equip.toggle.isOn = true
		if self.equip_view then
			self.equip_view:OpenCallBack()
		end
	elseif index == TabIndex.marriage_baobao then
		self.tab_baobao.toggle.isOn = true
	elseif index == TabIndex.marriage_baobao_guard then
		self.tab_baobao.toggle.isOn = true
		self.select_baobao_guard = true
	elseif index == TabIndex.marriage_monomer then
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_vo.lover_uid <= 0 then
			if self.toggle_honeymoon.isOn and self.marriage_honeymoon_view then
				self.marriage_honeymoon_view:Flush()
				self.marriage_honeymoon_view:FlushDisPlay()
			else
				self.open_tuodan_list = true
				self.toggle_honeymoon.isOn = true
			end
		else
			self.toggle_honeymoon.isOn = true
		end
	elseif index == TabIndex.marriage_shengdi then
		RemindManager.Instance:Fire(RemindName.MarryShengDi, true)
		self.tab_shengdi.toggle.isOn = true
		self:Flush("Shendi")
	elseif index == TabIndex.marriage_love_halo then
		self.halo_toggle.isOn = true
		if self.halo_view then
			self.halo_view:InitView()
		end
	elseif index == TabIndex.marriage_love_tree then
		self.love_tree_toggle.isOn = true
		if self.love_tree_view then
			self.love_tree_view:InitView()
		end
	else
		self.toggle_honeymoon.isOn = true
		self:ShowIndex(TabIndex.marriage_honeymoon)
	end
end

function MarriageView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "baobao" and self.baobao_toggle.isOn then
			if self.baobao_view then
				self.baobao_view:FlushView()
			end
		elseif k == "equip" and self.equip_toggle.isOn then
			if self.equip_view then
				self.equip_view:Flush()
			end
		elseif k == "tuodan" and self.toggle_honeymoon.isOn then
			MarriageCtrl.Instance:FlushMonomerListView()
			if self.marriage_honeymoon_view and not self:CheckIsMarry() then
				self.marriage_honeymoon_view:ChangeTuoDanBtnText()
			end

		elseif k == "hunyan_change" then
			if self.toggle_honeymoon.isOn then
				self.marriage_honeymoon_view:ShowOrHideTab()
			end
		elseif k == "halo" and self.halo_toggle.isOn then
			if self.halo_view then
				self.halo_view:FlushView()
			end
		elseif k == "love_contract" and self.toggle_honeymoon.isOn then
			MarriageCtrl.Instance:FlushLoveContractView()
		elseif k == "lover_change" then
			self:MarryStateChange()
		elseif k == "Shendi" and self.shengdi_toggle.isOn then
			if self.shengdi_view then
				self.shengdi_view:Flush()
			end
		elseif k == "love_tree" then
			if self.love_tree_toggle.isOn and self.love_tree_view then
				self.love_tree_view:FlushLoveTreeView()
			end
		elseif k == "love_tree_item_change" then
			if self.love_tree_toggle.isOn and self.love_tree_view then
				self.love_tree_view:UpdateUsedItem()
			end
		elseif k == "love_tree_upgrade" then
			if self.love_tree_toggle.isOn and self.love_tree_view then
				self.love_tree_view:UpGradeResult(v[1])
			end
		elseif k == "marry_gift" then
			if self.toggle_honeymoon.isOn and self.marriage_honeymoon_view then
				self.marriage_honeymoon_view:FLushMarryGiftBtn()
			end
		end
	end
end