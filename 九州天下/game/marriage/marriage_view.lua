require("game/marriage/marriage_honeymoon_view")
require("game/marriage/marriage_wedding_view")
require("game/marriage/marriage_fuben_view")
require("game/marriage/baobao/baobao_view")
require("game/marriage/marriage_halo_view")
require("game/marriage/equip/marry_equip_content_view")
require("game/marriage/marriage_halo_content")
require("game/marriage/shengdi/qingyuan_shengdi_view")
MarriageView = MarriageView or BaseClass(BaseView)

function MarriageView:__init()
	self.ui_config = {"uis/views/marriageview","MarriageView"}
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenMarry)
	end
	self.play_audio = true
	self:SetMaskBg()
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function MarriageView:__delete()

end

function MarriageView:ReleaseCallBack()
	if self.marriage_honeymoon_view then
		self.marriage_honeymoon_view:DeleteMe()
		self.marriage_honeymoon_view = nil
	end

	if self.item_change ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change)
		self.item_change = nil
	end

	if self.marriage_fuben_view then
		self.marriage_fuben_view:DeleteMe()
		self.marriage_fuben_view = nil
	end

	if self.equip_view then
		self.equip_view:DeleteMe()
		self.equip_view = nil
	end

	if self.lover_tree_view then
		self.lover_tree_view:DeleteMe()
		self.lover_tree_view = nil
	end

	if self.baobao_view then
		self.baobao_view:DeleteMe()
		self.baobao_view = nil
	end

	if self.love_contract_view then
		self.love_contract_view:DeleteMe()
		self.love_contract_view = nil
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	if self.halo_view then
		self.halo_view:DeleteMe()
		self.halo_view = nil
	end

	if self.equip_content then
		self.equip_content:DeleteMe()
		self.equip_content = nil
	end

	if self.shengdi_view then
		self.shengdi_view:DeleteMe()
		self.shengdi_view = nil
	end

	-- 清理变量和对象
	self.tab_lover = nil
	self.tab_ring = nil
	self.tab_hunyan = nil
	self.hunyan_toggle = nil
	self.honeymoon_red_point = nil
	self.show_halo_red_point = nil
	self.show_shengdi_red_point = nil
	self.tab_honeymoon = nil
	self.tab_fb = nil
	self.tab_halo = nil
	-- self.tab_baobao = nil
	self.tab_equip = nil
	self.toggle_honeymoon = nil
	self.fb_toggle = nil
	self.tab_love_tree = nil
	self.love_tree_toggle = nil
	self.tab_shengdi = nil
	self.halo_toggle = nil
	self.shengdi_toggle = nil
	self.tree_bg = nil
	self.red_point_list = nil
	self.show_fuben_red_point = nil
	self.equip_toggle = nil
	
	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function MarriageView:LoadCallBack()
	self.cur_index = TabIndex.marriage_honeymoon

	self:ListenEvent("Close",BindTool.Bind(self.ClickClose, self))

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))

	local honeymoon_content = self:FindObj("HoneyMoonView")
	honeymoon_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.marriage_honeymoon_view = MarriageHoneymoonView.New(obj)
		self.tab_lover = self.marriage_honeymoon_view.tab1
		self.tab_ring = self.marriage_honeymoon_view.tab2
		self.tab_hunyan = self.marriage_honeymoon_view.tab3
		self.hunyan_toggle = self.tab_hunyan.toggle

		self.tab_lover.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_lover))
		self.tab_ring.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_ring))
		self.hunyan_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_weeding))
		self.marriage_honeymoon_view:ShowOrHideTab()
		self.marriage_honeymoon_view:StopAutoUpgrade()

		self.marriage_honeymoon_view:OpenHoneyMoonCallBack()

		if self.select_lover then
			self.select_lover = false
			self.marriage_honeymoon_view:FlushDisPlay()
			return
		end
		if self.select_ring then
			self.select_ring = false
			self.marriage_honeymoon_view:RingInfoChange(true)
		elseif self.select_equip then
			self.select_equip = false
			self.marriage_honeymoon_view:SelectEquipToggle()
		elseif self.select_love_contract then
			self.select_love_contract = false
			self.marriage_honeymoon_view:SelectLoveContractToggle()
		elseif self.open_tuodan_list then
			self.open_tuodan_list = false
			self.marriage_honeymoon_view:RingInfoChange()
			self.marriage_honeymoon_view:FlushDisPlay()
			self.marriage_honeymoon_view:OpenTuoDanList()
		else
			self.marriage_honeymoon_view:RingInfoChange()
			if self.tab_lover.gameObject.activeInHierarchy and self.tab_lover.toggle.isOn then
				self.marriage_honeymoon_view:FlushDisPlay()
			end
			if self.cur_index == TabIndex.marriage_honeymoon then
				self.marriage_honeymoon_view:FlushLoveContractView()
			end
		end
	end)

	local fuben_content = self:FindObj("FuBenView")
	fuben_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.marriage_fuben_view = MarriageFuBenView.New(obj)
		self.marriage_fuben_view:ShowOrHideTab()
		self.marriage_fuben_view:Flush()
	end)

	-- local baobao_content = self:FindObj("BaoBaoView")
	-- baobao_content.uiprefab_loader:Wait(function(obj)
	-- 	obj = U3DObject(obj)
	-- 	self.baobao_view = BaoBaoView.New(obj, self)
	-- 	self.baobao_view:ShowOrHideTab()
	-- 	if self.select_baobao_guard then
	-- 		self.select_baobao_guard = false
	-- 		self.baobao_view:SelectBaoBaoGuard()
	-- 	else
	-- 		self.baobao_view:OpenBaobaoCallBack()
	-- 	end
	-- end)
	local equip_content = self:FindObj("EquipView")
	self.equip_view = MarryEquipContentView.New()
	equip_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.equip_view:SetInstance(obj)
		self.equip_view:ShowOrHideTab()
		self.equip_view:OpenCallBack()
	end)

	local lover_tree_content = self:FindObj("LoverTreeView")
	lover_tree_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.lover_tree_view = MarriageHaloView.New(obj)
		self.lover_tree_view:ShowOrHideTab()
		if self.open_interact_index then
			self.lover_tree_view:ShowHaloIndex(self.open_interact_index)
			self.open_interact_index = nil
		else
			self.lover_tree_view:OpenHaloCallBack()
		end
	end)

	local halo_content = self:FindObj("HaloContent")
	halo_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.halo_view = MarriageHaloContent.New(obj, self)
		self.halo_view:InitView()
	end)

	local shengdi_content = self:FindObj("ShengDiView")
	shengdi_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.shengdi_view = QingYuanShengDiView.New(obj, self)
		self.shengdi_view:ShowOrHideTab()
		self.shengdi_view:OpenCallBack()
	end)


	self.honeymoon_red_point = self:FindVariable("HoneyMoonRedPoint")
	self.show_halo_red_point = self:FindVariable("ShowHaloRedPoint")
	-- self.show_shengdi_red_point = self:FindVariable("ShowShengDiRedPoint")
	-- self.show_fuben_red_point = self:FindVariable("ShowFuBenRedPoint")
	self.tab_honeymoon = self:FindObj("ToggleHoneymoon")
	self.tab_fb = self:FindObj("FbToggle")
	self.tab_love_tree = self:FindObj("LoverTreeToggle")
	self.tab_equip = self:FindObj("EquipToggle")
	self.tab_halo = self:FindObj("HaloToggle")
	-- self.tab_baobao = self:FindObj("BaobaoToggle")
	self.tab_shengdi = self:FindObj("ShengDiToggle")

	self.toggle_honeymoon = self.tab_honeymoon.toggle
	self.fb_toggle = self.tab_fb.toggle
	self.halo_toggle = self.tab_halo.toggle
	self.love_tree_toggle = self.tab_love_tree.toggle
	self.equip_toggle = self.tab_equip.toggle
	-- self.baobao_toggle = self.tab_baobao.toggle
	self.shengdi_toggle = self.tab_shengdi.toggle

	self.toggle_honeymoon:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_honeymoon))
	self.fb_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_fuben))
	self.love_tree_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_love_tree))
	self.halo_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_halo_content))
	self.equip_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_equip))
	self.shengdi_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_shengdi))

	self.tree_bg = self:FindVariable("RawImageBg")

	self.red_point_list = {
		[RemindName.MarryFuBen] = self:FindVariable("ShowFuBenRedPoint"),
		[RemindName.MarryCoupHalo] = self:FindVariable("ShowMarryCoupHaloRedPoint"),
		[RemindName.MarryQingShi] = self:FindVariable("ShowQingShingRedPoint"),
		[RemindName.MarryShengDi] = self:FindVariable("ShowShengDiRedPoint"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.OnRoleAttrValueChange, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end

	if self.item_change == nil then
		self.item_change = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_change)
	end

	self.tab_equip:SetActive(OpenFunData.Instance:CheckIsHide("marriage_equip"))
	self.tab_shengdi:SetActive(OpenFunData.Instance:CheckIsHide("marriage_shnegdi"))
end


function MarriageView:RemindChangeCallBack(remind_name, num)
	if self.red_point_list[remind_name] then
		if RemindName.MarryFuBen == remind_name then
			self.red_point_list[remind_name]:SetValue(num > 0 and self:IsMarriage())
		else
			self.red_point_list[remind_name]:SetValue(num > 0)
		end
	end
end

function MarriageView:ShowOrHideTab()
	local show_list = {}
	local open_fun_data = OpenFunData.Instance
	show_list["tab_honeymoon"] = open_fun_data:CheckIsHide("marriage_honeymoon")
	show_list["tab_fb"] = open_fun_data:CheckIsHide("marriage_fuben")
	show_list["tab_love_tree"] = open_fun_data:CheckIsHide("marriage_halo")
	show_list["tab_baobao"] = false--open_fun_data:CheckIsHide("marriage_baobao")

	if self.toggle_honeymoon.isOn then
		if self.marriage_honeymoon_view then
			self.marriage_honeymoon_view:ShowOrHideTab()
		end
	elseif self.fb_toggle.isOn then
		if self.marriage_fuben_view then
			self.marriage_fuben_view:ShowOrHideTab()
		end
	elseif self.love_tree_toggle.isOn then
		if self.lover_tree_view then
			self.lover_tree_view:ShowOrHideTab()
		end
	end

	for k,v in pairs(show_list) do
		if self[k] then
			self[k]:SetActive(v)
		end
	end
end

function MarriageView:OnToggleChange(index, is_on)
	self:ShowOrHideTab()
	if self.marriage_honeymoon_view then
		self.marriage_honeymoon_view:StopAutoUpgrade()
	end

	if index == TabIndex.marriage_lover and is_on then
		if self.marriage_honeymoon_view then
			self.marriage_honeymoon_view:FlushDisPlay()
		else
			self.select_lover = true
		end
		return
	end

	if index == TabIndex.marriage_ring or index == TabIndex.marriage_weeding then
		return
	end
	if not is_on then return end
	self.cur_index = index
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
	elseif self.cur_index == TabIndex.marriage_fuben then
		ClickOnceRemindList[RemindName.MarryFuBen] = 0
		RemindManager.Instance:CreateIntervalRemindTimer(RemindName.MarryFuBen)

	elseif self.cur_index == TabIndex.marriage_love_tree then
		if self.open_interact_index then
			if self.lover_tree_view then
				self.lover_tree_view:ShowHaloIndex(self.open_interact_index)
			end
			self.open_interact_index = nil
		else
			if self.lover_tree_view then
				self.lover_tree_view:OpenHaloCallBack()
			end
		end
	elseif self.cur_index == TabIndex.marriage_love_tree then
		self.halo_toggle.isOn = true

	elseif self.cur_index == TabIndex.marriage_equip then
		self.tab_equip.toggle.isOn = true

	elseif self.cur_index == TabIndex.marriage_honeymoon then
		MarriageData.Instance:HandleRedPoint("lover", false)
		self:SetRedPoint()		
		if self.select_ring then
			if self.marriage_honeymoon_view then
				self.select_ring = false
				self.marriage_honeymoon_view:RingInfoChange(true)
			end
		elseif self.select_equip then
			if self.marriage_honeymoon_view then
				self.select_equip = false
				self.marriage_honeymoon_view:SelectEquipToggle()
			end
		elseif self.select_love_contract then
			if self.marriage_honeymoon_view then
				self.select_love_contract = false
				self.marriage_honeymoon_view:SelectLoveContractToggle()
			end
		elseif self.open_tuodan_list then
			if self.marriage_honeymoon_view then
				self.open_tuodan_list = false
				self.marriage_honeymoon_view:RingInfoChange()
				self.marriage_honeymoon_view:FlushDisPlay()
				self.marriage_honeymoon_view:OpenTuoDanList()
			end

		else
			if self.marriage_honeymoon_view then
				self.marriage_honeymoon_view:RingInfoChange()
				if self.tab_lover.gameObject.activeInHierarchy and self.tab_lover.toggle.isOn then
					self.marriage_honeymoon_view:FlushDisPlay()
				end
			end
		end
	elseif self.cur_index == TabIndex.marriage_shengdi then
		self.shengdi_toggle.isOn = true

		ClickOnceRemindList[RemindName.MarryShengDi] = 0
		RemindManager.Instance:CreateIntervalRemindTimer(RemindName.MarryShengDi)
	end
end

function MarriageView:CloseCallBack()
	if self.marriage_honeymoon_view then
		self.marriage_honeymoon_view:CloseCallBack()
	end
	if self.item_call_back then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_call_back)
		self.item_call_back = nil
	end
	if self.fun_open_bind then
		GlobalEventSystem:UnBind(self.fun_open_bind)
		self.fun_open_bind = nil
	end

	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function MarriageView:HoneyMoonToggleChange(is_on)
	if not is_on then
		if self.marriage_honeymoon_view then
			self.marriage_honeymoon_view:StopAutoUpgrade()
		end
	end
end

function MarriageView:SetRedPoint()
	local honeymoon_red_point = MarriageData.Instance:GetRedPointByKey("honeymoon_group")
	self.honeymoon_red_point:SetValue(honeymoon_red_point)
end

function MarriageView:SetHaloRedPoint()
	local show_red_point = MarriageData.Instance:GetRedPointByKey("interact_group")
	self.show_halo_red_point:SetValue(show_red_point)
end

function MarriageView:SetShengDiRedPoint()
	local show_red_point = MarriageData.Instance:GetRedPointByKey("shengdi_group")
	if self.show_shengdi_red_point then
		self.show_shengdi_red_point:SetValue(show_red_point)
	end
end

function MarriageView:SetFuBenRedPoint()
	local show_red_point = MarriageData.Instance:GetFuBenRemind()
	if self.show_fuben_red_point then
		self.show_fuben_red_point:SetValue(self:IsMarriage() and show_red_point)
	end
end

function MarriageView:IsMarriage()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.lover_name == nil or main_role_vo.lover_name == "" then
		return false
	end
	return true
end

function MarriageView:OpenCallBack()
	MarriageCtrl.Instance:SendQingYuanFBInfoReq()
	BaobaoCtrl.SendAllBabyInfoReq()
	MarriageCtrl.Instance:SendQingyuanLoveContractInfoReq()

	self:ShowOrHideTab()

	if self.item_call_back == nil then
		self.item_call_back = BindTool.Bind(self.ItemDataChange, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_call_back)
	end

	self.fun_open_bind = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowOrHideTab, self))

	self:FlushHoneyMoonView()

	self:SetHaloRedPoint()
	-- self:SetShengDiRedPoint()
	-- self:SetFuBenRedPoint()

	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.OnRoleAttrValueChange, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end

end

function MarriageView:FlushHoneyMoonView()
	if self.tab_lover and self.tab_lover.toggle.isOn then
		if self.marriage_honeymoon_view then
			self.marriage_honeymoon_view:FlushDisPlay()
		end
	else
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_vo.lover_uid <= 0 and self.tab_lover then
			self.tab_lover.toggle.isOn = true
		end
	end
	self:SetRedPoint()
	if self.marriage_honeymoon_view then
		if self.tab_honeymoon.toggle.isOn then
			self.marriage_honeymoon_view:OpenHoneyMoonCallBack()
		end
		self.marriage_honeymoon_view:RingInfoChange()
	end
end

function MarriageView:ClickClose()
	self:Close()
end

function MarriageView:RingChange()
	if self:IsLoaded() then
		if self.marriage_honeymoon_view then
			self.marriage_honeymoon_view:FlushRingRedPoint()
			self.marriage_honeymoon_view:RingInfoChange()
		end
		self:SetRedPoint()
	end
end

function MarriageView:BlessChange()
	if self:IsLoaded() then
		if self.marriage_honeymoon_view then
			self.marriage_honeymoon_view:Flush()
		end
		self:SetRedPoint()
	end
end

function MarriageView:OnFuBenChange()
	if self:IsLoaded() then
		if self.marriage_fuben_view then
			self.marriage_fuben_view:Flush()
		end
		if self.marriage_honeymoon_view then
			self.marriage_honeymoon_view:FlushWedding()
		end
	end
end

function MarriageView:HaloChange()
	if self:IsLoaded() and self.tab_halo.toggle.isOn then
		if self.lover_tree_view then
			self.lover_tree_view:HaloChange()
		end
	end
end

--决定显示那个界面
function MarriageView:ShowIndexCallBack(index)
	if index == TabIndex.marriage_honeymoon then
		self.toggle_honeymoon.isOn = true
		MarriageData.Instance:HandleRedPoint("lover", false)
		self:SetRedPoint()
	elseif index == TabIndex.marriage_ring then
		if self.toggle_honeymoon.isOn then
			if self.marriage_honeymoon_view then
				self.marriage_honeymoon_view:RingInfoChange(true)
			end
		else
			self.select_ring = true
			self.toggle_honeymoon.isOn = true
		end
	elseif index == TabIndex.marriage_weeding then
			self.toggle_honeymoon.isOn = true
			self.hunyan_toggle.isOn = true
	elseif index == TabIndex.marriage_equip then
		if self.toggle_honeymoon.isOn and self.marriage_honeymoon_view then
			self.marriage_honeymoon_view:SelectEquipToggle()
		else
			self.select_equip = true
			self.toggle_honeymoon.isOn = true
		end
	elseif index == TabIndex.marriage_fuben then
		if not self.fb_toggle.isOn then
			self.fb_toggle.isOn = true
		end
	elseif index == TabIndex.marriage_love_contract then
		if self.toggle_honeymoon.isOn and self.marriage_honeymoon_view then
			self.marriage_honeymoon_view:SelectLoveContractToggle()
		else
			self.select_love_contract = true
			self.toggle_honeymoon.isOn = true
		end
	elseif index == TabIndex.marriage_equip
		or index == TabIndex.marriage_equip_suit
		or index == TabIndex.marriage_equip_recyle then
		self.tab_equip.toggle.isOn = true
		if self.equip_view then
			self.equip_view:SetShowIndex(index)
			self.equip_view:OpenCallBack()
		end
	-- elseif index == TabIndex.marriage_baobao then
	-- 	self.tab_baobao.toggle.isOn = true
	-- elseif index == TabIndex.marriage_baobao_guard then
	-- 	self.tab_baobao.toggle.isOn = true
	-- 	self.select_baobao_guard = true
	elseif index == TabIndex.marriage_monomer then
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_vo.lover_uid <= 0 then
			if self.toggle_honeymoon.isOn and self.marriage_honeymoon_view then
				self.marriage_honeymoon_view:RingInfoChange()
				self.marriage_honeymoon_view:FlushDisPlay()
				self.marriage_honeymoon_view:OpenTuoDanList()
			else
				self.open_tuodan_list = true
				self.toggle_honeymoon.isOn = true
			end
		else
			self.toggle_honeymoon.isOn = true
		end
	elseif index == TabIndex.marriage_love_tree then
		if not self.love_tree_toggle.isOn then
			self.open_interact_index = index
			self.love_tree_toggle.isOn = true
		end
	elseif index == TabIndex.marriage_halo_content then
		if not self.halo_toggle.isOn then
			self.halo_toggle.isOn = true
		end
	elseif index == TabIndex.marriage_shengdi then
		self.tab_shengdi.toggle.isOn = true
		self:Flush("Shendi")
	end
end

function MarriageView:ItemDataChange(change_item_id)
	--27406婚戒材料
	if change_item_id == 27406 and self:IsLoaded() then
		self:SetRedPoint()
		if self.tab_honeymoon.toggle.isOn and not self.tab_ring.toggle.isOn then
			-- if self.tab_ring.toggle.isOn then
				-- self:RingChange()
			-- end
			if self.marriage_honeymoon_view then
				self.marriage_honeymoon_view:FlushRingRedPoint()
			end
		end
	end
end

function MarriageView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "love_tree" and self.love_tree_toggle.isOn then
			if self.lover_tree_view then
				self.lover_tree_view:FlushLoveTreeView()
			end
		elseif k == "tuodan" and self.toggle_honeymoon.isOn then
			if self.marriage_honeymoon_view then
				self.marriage_honeymoon_view:FlushTuoDanList()
			end
		elseif k == "marry_equip" and self.toggle_honeymoon.isOn then
			if self.marriage_honeymoon_view then
				self.marriage_honeymoon_view:FlushEquipView()
			end
		elseif k == "love_contract" and self.toggle_honeymoon.isOn then
			if self.marriage_honeymoon_view then
				self.marriage_honeymoon_view:FlushLoveContractView()
				self:SetRedPoint()
				self.marriage_honeymoon_view:QiYueRedPoint()
				self.marriage_honeymoon_view:FlushLoverContentRedPoint()
				self.marriage_honeymoon_view:ShowOrHideTab()
			end
		elseif k == "equip" and self.tab_equip.toggle.isOn then
			if self.equip_view then
				self.equip_view:FlushView()
			end
		elseif k == "halo" and self.halo_toggle.isOn then
			if self.halo_view then
				self.halo_view:FlushView()
				self.halo_view:Flush()
			end
		elseif k == "Shendi" and self.shengdi_toggle.isOn then
			if self.shengdi_view then
				self.shengdi_view:Flush()
			end
		end
	end
end

function MarriageView:SetTreeBg(raw_bunble, raw_asset)
	if self.tree_bg ~= nil and raw_bunble ~= nil and raw_asset ~= nil then
		self.tree_bg:SetAsset(raw_bunble, raw_asset)
	end
end

function MarriageView:ItemDataChangeCallback(item_id)
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
	self:Flush("halo")
	RemindManager.Instance:Fire(RemindName.MarryCoupHalo)
end


function MarriageView:OnRoleAttrValueChange(key, new_value, old_value)
	if key == "lover_uid" then
		if self.equip_view ~= nil then
			self.equip_view:FlushView()
		elseif self.cur_index == TabIndex.marriage_halo_content and self.halo_view ~= nil then
			self:Flush("halo")
		end
	end
end