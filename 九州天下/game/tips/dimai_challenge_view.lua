TipsDiMaiChallengeView = TipsDiMaiChallengeView or BaseClass(BaseView)

function TipsDiMaiChallengeView:__init()
	self.ui_config = {"uis/views/tips/dimaitips", "ChallengeTips"}
	self.play_audio = true
	self:SetMaskBg(true)
	self.view_layer = UiLayer.Pop
end

function TipsDiMaiChallengeView:__delete()
end

function TipsDiMaiChallengeView:ReleaseCallBack()
	for k,v in pairs(self.item_list) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.item_list = {}

	if self.role_info_callback then
		GlobalEventSystem:UnBind(self.role_info_callback)
		self.role_info_callback = nil
	end

	self.view_data = nil
	self.name = nil
	self.role_buff_icon = nil
	self.map_image = nil
	self.map_name = nil
	self.show_challenge = nil

	self.camp_content = nil
	self.role_content = nil

	self.is_click_challenge = false
end

function TipsDiMaiChallengeView:LoadCallBack()
	self.is_click_challenge = false

	self.name = self:FindVariable("Name")
	self.role_buff_icon = self:FindVariable("RoleBuffIcon")
	self.map_image = self:FindVariable("MapImage")
	self.map_name = self:FindVariable("MapName")
	self.show_challenge = self:FindVariable("ShowChallenge")

	self.camp_content = self:FindObj("CampContent")
	self.role_content = self:FindObj("RoleContent")

	self.item_list = {}
	for i = 0, 2 do
		self.item_list[i] = {}
		self.item_list[i].obj = self:FindObj("Item" .. i)
		self.item_list[i].cell = ItemCell.New()
		self.item_list[i].cell:SetInstanceParent(self.item_list[i].obj)
		self.item_list[i].obj:SetActive(false)
	end

	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickChallenge", BindTool.Bind(self.OnClickChallenge, self))

	self.role_info_callback = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfoCallBack, self))
end

function TipsDiMaiChallengeView:CloseCallBack()
	if self.view_data then
		DiMaiCtrl.Instance:SendReqDimaiOpera(DIMAI_OPERA_TYPE.DIMAI_OPERA_TYPE_DIMAI_INFO, self.view_data.dimai_info.layer, self.view_data.dimai_info.point)
	end
end

function TipsDiMaiChallengeView:RoleInfoCallBack(uid, info)
	if self.view_data then
		if uid == self.view_data.dimai_info.uid then
			local camp_name = CampData.Instance:GetCampNameByCampType(info.camp_id, true, false, false)
			if camp_name then
				local str = camp_name .. info.role_name
				self.name:SetValue(ToColorStr(str, CAMP_COLOR[info.camp_id]))
			end
		end
	end
end

function TipsDiMaiChallengeView:OnFlush()
	if self.view_data then
		if self.view_data.dimai_info.uid ~= 0 then
			CheckCtrl.Instance:SendQueryRoleInfoReq(self.view_data.dimai_info.uid)
		else
			self.name:SetValue(Language.Common.ZanWu)
		end

		self.role_buff_icon:SetAsset(ResPath.GetDiMaiTipsBuffIcon(self.view_data.dimai_info.layer))
		self.map_image:SetAsset(ResPath.GetDiMaiChallengeBg(self.view_data.dimai_info.layer, self.view_data.dimai_info.point))

		local dimai_info = DiMaiData.Instance:GetDiMaiInfoCfg(self.view_data.dimai_info.layer, self.view_data.dimai_info.point)
		if dimai_info then
			self.map_name:SetValue(dimai_info.dimai_name)
			
			for k, v in pairs(dimai_info.challenge_rewards) do
				self.item_list[k].obj:SetActive(true)
				self.item_list[k].cell:SetData(v)
			end
			 
			local protect_time = self.view_data.dimai_info.protect_begin_time + dimai_info.protect_time

			self.show_challenge:SetValue(self.view_data.is_challenging <= 0 and protect_time <= TimeCtrl.Instance:GetServerTime())
		end
		self:FlushAttr()
	end
end

-- 刷新属性值
function TipsDiMaiChallengeView:FlushAttr()
	local role_cfg = DiMaiData.Instance:GetDiMaiRoleBuffCfg(self.view_data.dimai_info.layer, self.view_data.dimai_info.point)
	local camp_cfg = DiMaiData.Instance:GetDiMaiCampBuffCfg(self.view_data.dimai_info.layer, self.view_data.dimai_info.point)
	
	if role_cfg then
		CommonDataManager.SetRoleAttr(self.role_content, role_cfg, nil)
	end
	if camp_cfg then
		CommonDataManager.SetRoleAttr(self.camp_content, camp_cfg, nil)
	end
end

function TipsDiMaiChallengeView:SetData(data)
	self.view_data = data
	self:Flush()
	if self.is_click_challenge == true then
		self:CheckIsCanChallenge()
	end
end

function TipsDiMaiChallengeView:OnClickClose()
	self:Close()
end

function TipsDiMaiChallengeView:OnClickChallenge()
	if self.view_data then
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		local role_layer = DiMaiData.Instance:GetRoleLayerByRoleID(role_vo.role_id)
		if role_layer >= self.view_data.dimai_info.layer then
			TipsCtrl.Instance:ShowSystemMsg(Language.QiangDiMai.ChallengeTips)

		elseif self.is_click_challenge == false then
			self.is_click_challenge = true
			DiMaiCtrl.Instance:SendReqDimaiOpera(DIMAI_OPERA_TYPE.DIMAI_OPERA_TYPE_SINGLE_DIMAI_INFO, self.view_data.dimai_info.layer, self.view_data.dimai_info.point)
		end
	end
end

function TipsDiMaiChallengeView:CheckIsCanChallenge()
	self.is_click_challenge = false
	local dimai_info = DiMaiData.Instance:GetDiMaiInfoCfg(self.view_data.dimai_info.layer, self.view_data.dimai_info.point)
	if dimai_info then
		
		-- 是否挑战自己
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		if role_vo then
			if self.view_data.dimai_info.uid == role_vo.role_id then
				TipsCtrl.Instance:ShowSystemMsg(Language.QiangDiMai.ChallengeItself)
				return
			end
		end

		-- 是否有挑战次数
		local other_cfg = DiMaiData.Instance:GetDiMaiOtherCfg()
		local role_dimai_info = DiMaiData.Instance:GetRoleDimaiInfo()
		if other_cfg and role_dimai_info then
			local day_count = DiMaiData.Instance:GetDiMaiChallengeCount()
			local challenge_times = other_cfg.challenge_times_limit + role_dimai_info.dimai_buy_times - day_count
			if challenge_times <= 0 then
				TipsCtrl.Instance:ShowSystemMsg(Language.QiangDiMai.ChallengeTimesLack)
				return
			end
		end

		if self.view_data.dimai_info.protect_begin_time + dimai_info.protect_time > TimeCtrl.Instance:GetServerTime() then
			TipsCtrl.Instance:ShowSystemMsg(Language.QiangDiMai.ProtectTimeRemind)
		else
			if self.view_data.is_challenging > 0 then
				TipsCtrl.Instance:ShowSystemMsg(Language.QiangDiMai.ChallengindRemind)
			else
				FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_DIMAI, self.view_data.dimai_info.layer, self.view_data.dimai_info.point, 0)
				ViewManager.Instance:CloseAll()
			end
		end
	end
end