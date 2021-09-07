CampFuHuoView = CampFuHuoView or BaseClass(BaseView)

local AFFAIRS_BTN_LENGTH = 8		-- 一共有8个按钮

function CampFuHuoView:__init()
	self.ui_config = {"uis/views/camp", "CampFuHuoView"}
	self:SetMaskBg(true)

	-- self.full_screen = true								-- 是否是全屏界面(ViewManager里面调用)
	self.play_audio = true									-- 播放音效

end

function CampFuHuoView:__delete()
end

function CampFuHuoView:ReleaseCallBack()
	self.dropdown_list = {}
	self.lbl_fuhuo_num = nil
end

function CampFuHuoView:LoadCallBack()
	--监听UI事件
	self:ListenEvent("BtnClose", BindTool.Bind(self.OnCloseHandler, self))
	self:ListenEvent("BtnConfirm", BindTool.Bind(self.OnBtnConfirmHandler, self))
	
	self.dropdown_list = {}
	for i = 1, 4 do
		self.dropdown_list[i] = self:FindObj("Dropdown" .. i).dropdown
	end
	
	self.lbl_fuhuo_num = self:FindVariable("FuHuoNum")
end

function CampFuHuoView:OpenCallBack()
	CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_GET_REBORN_TIMES_LIST)
end

function CampFuHuoView:CloseCallBack()
	
end

function CampFuHuoView:OnCloseHandler()
	ViewManager.Instance:Close(ViewName.CampFuHuo)
end

function CampFuHuoView:ShowIndexCallBack(index)
	self:Flush()
end

function CampFuHuoView:OnFlush(param_list)
	local camp_info = CampData.Instance:GetCampItemList()
	if camp_info == nil or next(camp_info) == nil then
		return
	end
	local camp_item_list = CampData.Instance:GetCampLevelCfgByCampLevel(camp_info.camp_level)
	if camp_item_list == nil or next(camp_item_list) == nil then
		return
	end

	local tab = Split(camp_item_list.reborn_times_list, "|")
	for i = 1, 4 do
		for j = 0, 3 do
			if self.dropdown_list[i] ~= nil then
				self.dropdown_list[i].options[j].text = tab[j + 1]
			end
		end
	end

	local reborn_info = CampData.Instance:GetCampRebornInfo()
	self.dropdown_list[1].value = reborn_info.king_reborn_times_idx
	self.dropdown_list[2].value = reborn_info.officer_reborn_times_idx
	self.dropdown_list[3].value = reborn_info.jingying_reborn_times_idx
	self.dropdown_list[4].value = reborn_info.guomin_reborn_times_idx
	for i = 1, 4 do
		self.dropdown_list[i].captionText.text = tab[self.dropdown_list[i].value + 1]
	end

	self.lbl_fuhuo_num:SetValue(string.format(Language.Camp.CampFuHuoNum, CampData.Instance:GetCampRebornDanNum()))
end

function CampFuHuoView:OnBtnConfirmHandler()
	CampCtrl.Instance:SendCampSetRebornTimes(
		self.dropdown_list[1].value,
		self.dropdown_list[2].value,
		self.dropdown_list[3].value,
		self.dropdown_list[4].value)

	ViewManager.Instance:Close(ViewName.CampFuHuo)
end
