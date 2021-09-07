require("game/camp/camp_info_view")
require("game/camp/camp_member_view")
require("game/camp/camp_auction_view")
require("game/camp/fate/camp_fate_view")
require("game/camp/camp_build_view")

CampView = CampView or BaseClass(BaseView)

function CampView:__init()
	self.ui_config = {"uis/views/camp", "CampView"}

	self.play_audio = true								-- 播放音效
	self:SetMaskBg()									-- 使用蒙板

end

function CampView:__delete()

end

function CampView:ReleaseCallBack()
	if self.info_view then
		self.info_view:DeleteMe()
		self.info_view = nil
	end
	if self.member_view then
		self.member_view:DeleteMe()
		self.member_view = nil
	end
	if self.build_view then
		self.build_view:DeleteMe()
		self.build_view = nil
	end
	if self.auction_view then
		self.auction_view:DeleteMe()
		self.auction_view = nil
	end
	if self.fate_view then
		self.fate_view:DeleteMe()
		self.fate_view = nil
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	self.toggle_info = nil
	self.toggle_member = nil
	self.toggle_build = nil
	self.toggle_auction = nil
	self.toggle_fate = nil
	self.is_red_show = nil

	if self.remind_change then
	   RemindManager.Instance:UnBind(self.remind_change)
	   self.remind_change = nil 
	end


end

function CampView:LoadCallBack()
	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
	--获得变量
	self.is_red_show = self:FindVariable("IsRedShow")

	--监听UI事件
	self:ListenEvent("Close", BindTool.Bind(self.OnCloseHandler, self))
	self:ListenEvent("AddGold", BindTool.Bind(self.OnAddGoldHandle, self))

	-- 标签页
	self.toggle_info = self:FindObj("ToggleInfo")
	self.toggle_member = self:FindObj("ToggleMember")
	self.toggle_build = self:FindObj("ToggleBuild")
	self.toggle_auction = self:FindObj("ToggleAuction")
	self.toggle_fate = self:FindObj("ToggleFate")


	self.toggle_info.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.camp_info))
	self.toggle_member.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.camp_member))
	self.toggle_build.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.camp_build))
	self.toggle_auction.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.camp_auction))
	self.toggle_fate.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.camp_fate))

	-- 检查功能是否开启
	self:CheckTabIsHide()

	-- 阵营(国家)信息
	self.info_view = CampInfoView.New()
	local info_content = self:FindObj("InfoContent")
	info_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.info_view:SetInstance(obj)
	end)

	-- 阵营(国家)成员信息
	self.member_view = CampMemberView.New()
	local member_content = self:FindObj("MemberContent")
	member_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.member_view:SetInstance(obj)
	end)

	-- 阵营(国家)国家升级
	self.build_view = CampBuildView.New()
	local build_content = self:FindObj("BuildContent")
	build_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.build_view:SetInstance(obj)
	end)

	-- 阵营(国家)拍卖
	self.auction_view = CampAuctionView.New()
	local auction_content = self:FindObj("AuctionContent")
	auction_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.auction_view:SetInstance(obj)
	end)

	-- 阵营(国家)气运
	self.fate_view = CampFateView.New()
	local fate_content = self:FindObj("FateContent")
	fate_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.fate_view:SetInstance(obj)
	end)

	
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.CampInternal)

end

function CampView:OpenCallBack()
	CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_GET_CAMP_ROLE_INFO)
	CampCtrl.Instance:SendQueryCampBuildReportInfo()
end

function CampView:CloseCallBack()
	
end

function CampView:OnAddGoldHandle()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function CampView:OnCloseHandler()
	ViewManager.Instance:Close(ViewName.Camp)
end

--决定显示那个界面
function CampView:ShowIndexCallBack(index)
	if index == TabIndex.camp_info then
		self.toggle_info.toggle.isOn = true
		CampCtrl.Instance:SendGetCampInfo()

	elseif index == TabIndex.camp_member then
		self.toggle_member.toggle.isOn = true
		self.member_view:SendQueryCampMemInfo()

	elseif index == TabIndex.camp_build then
		self.toggle_build.toggle.isOn = true
		CampCtrl.Instance:SendGetCampInfo()
		--self.build_view:SendRequest()

	elseif index == TabIndex.camp_auction then
		self.toggle_auction.toggle.isOn = true
		self.auction_view:SendRequest()
		
	elseif index == TabIndex.camp_fate then
		self.toggle_fate.toggle.isOn = true
		self.fate_view:SendRequest()
	end

	self:Flush()
end

function CampView:CheckTabIsHide()
	if not self:IsOpen() then return end

	self.toggle_info:SetActive(OpenFunData.Instance:CheckIsHide("camp_info"))
	self.toggle_member:SetActive(OpenFunData.Instance:CheckIsHide("camp_member"))
	-- self.toggle_build:SetActive(OpenFunData.Instance:CheckIsHide("camp_build"))
	self.toggle_auction:SetActive(OpenFunData.Instance:CheckIsHide("camp_auction"))
	self.toggle_fate:SetActive(OpenFunData.Instance:CheckIsHide("camp_fate"))
end

function CampView:OnToggleChange(index, ison)
	if TabIndex.camp_build == index then
		PlayerCtrl.Instance:SendReqCommonOpreate(COMMON_OPERATE_TYPE.COT_REQ_MONSTER_SIEGE_INFO)
		-- local data = CampData.Instance:GetMonsterSiegeInfo()
		-- if data ~= nil and self.build_view ~= nil then
		-- 	local camp = PlayerData.Instance.role_vo.camp
		-- 	if data.monster_siege_camp > 0 and data.monster_siege_camp == camp then
		-- 		self.build_view:SetOpenView(1)
		-- 	end
		-- end
		if self.build_view ~= nil then
			self.build_view:CheckIsShowMonsterSiege()
		end
	end

	if ison then
		self:ChangeToIndex(index)
	end
end

--红点是否显示
--function CampView:FlushRedShow()								
	--if self.is_red_show then
		--self.is_red_show:SetValue(CampData.Instance:GetDayCounterList(3) > 0 or CampData.Instance:GetDayCounterList(7) > 0)
	--end
--end

function CampView:OnFlush(param_list)
	--self:FlushRedShow()
	for k, v in pairs(param_list) do
		if k == "all" then
			if self.show_index == TabIndex.camp_info then
				if self.info_view then
					self.info_view:Flush()
				end
			elseif self.show_index == TabIndex.camp_member then
				if self.member_view then
					self.member_view:Flush()
				end
			elseif self.show_index == TabIndex.camp_build then
				if self.build_view then
					self.build_view:Flush()
				end
			elseif self.show_index == TabIndex.camp_auction then
				if self.auction_view then
					self.auction_view:Flush()
				end
			elseif self.show_index == TabIndex.camp_fate then
				if self.fate_view then
					self.fate_view:Flush()
				end
			end
		elseif k == "flush_camp_info_view" then
			if self.info_view then
				self.info_view:Flush(v)
			end

			if self.show_index == TabIndex.camp_build and self.build_view ~= nil then
				self.build_view:Flush()
			end
		elseif k == "flush_camp_member_view" then
			if self.member_view then
				self.member_view:Flush(v)
			end
		elseif k == "flush_camp_build_view" then
			if self.build_view and self.show_index == TabIndex.camp_build then
				if v.act_status == ACTIVITY_STATUS.CLOSE then
					CampCtrl.Instance:SendGetCampInfo()
				end
				self.build_view:Flush()
			end
		-- elseif k == "flush_camp_monster_siege" then
		-- 	if self.build_view and self.show_index == TabIndex.camp_build then
		-- 		self.build_view:Flush("flush_monster_siege", {monster_siege_camp = v.monster_siege_camp})
		-- 	end
		elseif k == "flush_camp_auction_view" then
			if self.auction_view then
				self.auction_view:Flush(v)
			end
		elseif k == "flush_camp_auction_list" then
			if self.auction_view then
				self.auction_view:FlushItemList(v)
			end
		elseif k == "flush_camp_fate_view" then
			if self.fate_view then
				self.fate_view:Flush(v)
			end
		end
	end
end
function CampView:RemindChangeCallBack(remind_name, state)
	self.is_red_show:SetValue(state)
end
