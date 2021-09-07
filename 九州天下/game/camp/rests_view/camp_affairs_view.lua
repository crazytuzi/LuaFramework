CampAffairsView = CampAffairsView or BaseClass(BaseView)

local AFFAIRS_BTN_LENGTH = 8		-- 一共有8个按钮

function CampAffairsView:__init()
	self.ui_config = {"uis/views/camp", "CampAffairsView"}
    self:SetMaskBg(true)
	-- self.full_screen = true								-- 是否是全屏界面(ViewManager里面调用)
	self.play_audio = true									-- 播放音效

	-- 注意！官职分别1-8对应的是：国家运镖、国家搬砖、国民福利、禁言玩家、标记内奸、赦免内奸、官员福利、复活分配

	-- 官职权限 没配置，策划说写死对应官职的权限，下标1-8分别对应的是1-7的官职，值的话分别对应官职是否有的权限
	self.camp_post_right = {
		[CAMP_AFFAIRS_TYPE.YUNBIAO] = {true, false, false, false, false, false, false},
		[CAMP_AFFAIRS_TYPE.BANZHUAN] = {true, false, false, false, false, false, false},
		[CAMP_AFFAIRS_TYPE.GUOMINFULI] = {true, true, true, true, true, false, false},
		[CAMP_AFFAIRS_TYPE.JINYANWANJIA] = {true, false, false, false, false, false, false},
		[CAMP_AFFAIRS_TYPE.NEIJIANBIAOJI] = {true, true, true, true, true, false, false},
		[CAMP_AFFAIRS_TYPE.SHEMIANNEIJIAN] = {true, true, true, true, true, false, false},
		[CAMP_AFFAIRS_TYPE.GUANYUANFULI] = {true, false, false, false, false, false, false},
		[CAMP_AFFAIRS_TYPE.FUHUOFENPEI] = {true, false, false, false, false, false, false},
	}

	-- 监听按钮点击事件表
	self.btn_list = {
		[CAMP_AFFAIRS_TYPE.YUNBIAO] = "OnBtnYunBiao",
		[CAMP_AFFAIRS_TYPE.BANZHUAN] = "OnBtnBanZhuan",
		[CAMP_AFFAIRS_TYPE.GUOMINFULI] = "OnBtnGuoMinFuLi",
		[CAMP_AFFAIRS_TYPE.JINYANWANJIA] = "OnBtnJinYanPlayer",
		[CAMP_AFFAIRS_TYPE.NEIJIANBIAOJI] = "OnBtnBiaoJiNeiJian",
		[CAMP_AFFAIRS_TYPE.SHEMIANNEIJIAN] = "OnBtnSheMianNeiJian",
		[CAMP_AFFAIRS_TYPE.GUANYUANFULI] = "OnBtnGuanYuanFuLi",
		[CAMP_AFFAIRS_TYPE.FUHUOFENPEI] = "OnBtnFuHuoFenPei",
	}

	-- 是否可点击按钮的名字表
	self.is_click_list_name = {
		[CAMP_AFFAIRS_TYPE.YUNBIAO] = "IsYunBiaoClick",
		[CAMP_AFFAIRS_TYPE.BANZHUAN] = "IsBanZhuanClick",
		[CAMP_AFFAIRS_TYPE.GUOMINFULI] = "IsGuoMinFuLiClick",
		[CAMP_AFFAIRS_TYPE.JINYANWANJIA] = "IsJinYanPlayerClick",
		[CAMP_AFFAIRS_TYPE.NEIJIANBIAOJI] = "IsBiaoJiNeiJianClick",
		[CAMP_AFFAIRS_TYPE.SHEMIANNEIJIAN] = "IsSheMianNeiJianClick",
		[CAMP_AFFAIRS_TYPE.GUANYUANFULI] = "IsGuanYuanFuLiClick",
		[CAMP_AFFAIRS_TYPE.FUHUOFENPEI] = "IsFuHuoFenPeiClick",
	}

	self.btn_is_click_list = {}

end

function CampAffairsView:__delete()
end

function CampAffairsView:ReleaseCallBack()
	self.lbl_guanzhi_name = nil
	self.btn_is_click_list = {}
	self.is_guominfuli_red = nil
	self.is_guanyuanfuli_red = nil
end

function CampAffairsView:LoadCallBack()
	--监听UI事件
	self:ListenEvent("Close", BindTool.Bind(self.OnCloseHandler, self))
	
	self.lbl_guanzhi_name = self:FindVariable("GuanZhiName")

	for i = 1, AFFAIRS_BTN_LENGTH do
		self:ListenEvent(self.btn_list[i], BindTool.Bind(self.OnBtnListHandler, self, i))
		self.btn_is_click_list[i] = self:FindVariable(self.is_click_list_name[i])
	end
	self.is_guominfuli_red = self:FindVariable("IsGuoMinFuLiRed")
	self.is_guanyuanfuli_red = self:FindVariable("IsGuanYuanFuLiRed")
end

function CampAffairsView:OpenCallBack()
	CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_GET_CAMP_ROLE_INFO)
end

function CampAffairsView:CloseCallBack()
	
end

function CampAffairsView:OnCloseHandler()
	ViewManager.Instance:Close(ViewName.CampAffairs)
end

function CampAffairsView:ShowIndexCallBack(index)
	self:Flush()
end

function CampAffairsView:OnFlush(param_list)
	local camp_post = PlayerData.Instance.role_vo.camp_post
	local bundle, asset = ResPath.GetCampRes("lbl_statue_" .. camp_post)
	self.lbl_guanzhi_name:SetAsset(bundle, asset)

	for k, v in pairs(self.btn_is_click_list) do
		local camp_post_right = self.camp_post_right[k]
		if camp_post_right then
			local day_counter_num = CampData.Instance:GetDayCounterList(k)
			v:SetValue(camp_post_right[camp_post] and day_counter_num > 0)
			--print.error(1)
		end
	end
	self:IsRedShow()
end
------------------国民福利。官员福利红点是否显示
function CampAffairsView:IsRedShow()
	if CampData.Instance:GetDayCounterList(CAMP_AFFAIRS_TYPE.GUOMINFULI) then
		self.is_guominfuli_red:SetValue(CampData.Instance:GetDayCounterList(CAMP_AFFAIRS_TYPE.GUOMINFULI) > 0 and true or false)
	end
	if CampData.Instance:GetDayCounterList(CAMP_AFFAIRS_TYPE.GUANYUANFULI)then
		self.is_guanyuanfuli_red:SetValue(CampData.Instance:GetDayCounterList(CAMP_AFFAIRS_TYPE.GUANYUANFULI) > 0 and true or false)
	end
end


function CampAffairsView:OnBtnListHandler(btn_type)
	local camp_post = PlayerData.Instance.role_vo.camp_post
	local camp_post_right = self.camp_post_right[btn_type]

	if camp_post_right and camp_post_right[camp_post] then
		if CampData.Instance:GetDayCounterList(btn_type) <= 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Camp.DayNotNum)
			return
		end

		if btn_type == CAMP_AFFAIRS_TYPE.YUNBIAO then				-- 国家运镖
			TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Camp.IsOpenYunBiao, function ()
				CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_NEIZHENG_YUNBIAO)
				CampCtrl.Instance:SendCampTaskCommonOpera(CAMP_TASK_OPERA_TYPE.OPERA_TYPE_GET_TASK_STATUS, CAMP_TASK_TYPE.CAMP_TASK_TYPE_YUNBIAO)
			end)

		elseif btn_type == CAMP_AFFAIRS_TYPE.BANZHUAN then			-- 国家搬砖
			TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Camp.IsOpenBanZhuan, function ()
				CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_NEIZHENG_BANZHUAN)
			end)
			
		elseif btn_type == CAMP_AFFAIRS_TYPE.GUOMINFULI then		-- 国民福利
			CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_NEIZHENG_GUOMIN_WELFARE)

		elseif btn_type == CAMP_AFFAIRS_TYPE.JINYANWANJIA then		-- 禁言玩家
			CampData.Instance:SetMemberListType(CampData.JinYanGuanLi)
			ViewManager.Instance:Open(ViewName.CampMemberList)
		elseif btn_type == CAMP_AFFAIRS_TYPE.NEIJIANBIAOJI then		-- 标记内奸
			CampData.Instance:SetMemberListType(CampData.NeiJianBiaoJi)
			ViewManager.Instance:Open(ViewName.CampMemberList)
		elseif btn_type == CAMP_AFFAIRS_TYPE.SHEMIANNEIJIAN then	-- 赦免内奸
			CampData.Instance:SetMemberListType(CampData.JieChuNeiJian)
			ViewManager.Instance:Open(ViewName.CampMemberList)
		elseif btn_type == CAMP_AFFAIRS_TYPE.GUANYUANFULI then		-- 官员福利
			CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_NEIZHENG_OFFICER_WELFARE)
		elseif btn_type == CAMP_AFFAIRS_TYPE.FUHUOFENPEI then		-- 复活分配
			ViewManager.Instance:Open(ViewName.CampFuHuo)
		end
	else
		if camp_post <= CAMP_POST.CAMP_POST_YUSHIDAFU then 			-- 官员权限不足
			SysMsgCtrl.Instance:ErrorRemind(Language.Camp.QuanXianBuZu)
			return
		end

		if btn_type == CAMP_AFFAIRS_TYPE.GUOMINFULI or btn_type == CAMP_AFFAIRS_TYPE.NEIJIANBIAOJI or btn_type == CAMP_AFFAIRS_TYPE.SHEMIANNEIJIAN then
			SysMsgCtrl.Instance:ErrorRemind(Language.Camp.CivilianQuanXianBuZu)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Camp.QuanXianBuZu)
		end
	end
end

