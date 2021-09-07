CallView = CallView or BaseClass(BaseView)
local Call_Index = {3, 2, 1, 4, 5}	

function CallView:__init()
	self.ui_config = {"uis/views/callview", "CallView"}
	self.full_screen = false
	self.play_audio = true
	self:SetMaskBg(true)

	self.list = {}
end
	
function CallView:__delete()
end

function CallView:LoadCallBack()
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshMountCell, self)
end

function CallView:ReleaseCallBack()
	for k, v in pairs(self.list) do
		v:DeleteMe()
	end
	self.list = {}
	self.list_view = nil
end

function CallView:GetNumberOfCells()
	return #Call_Index
end

function CallView:RefreshMountCell(cell, data_index)
	data_index = data_index + 1
	local call_item = self.list[cell]
	if call_item == nil then
		call_item = CallItemView.New(cell.gameObject)
		call_item:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
		self.list[cell] = call_item
	end
	call_item:SetIndex(data_index)
	call_item:SetData(Call_Index[data_index])
end

function CallView:OnClickItemCallBack(cell)
	if nil == cell or nil == cell.data then return end
	self:OnClickCall(cell.data)
end

function CallView:OpenCallBack()
	self:Flush()
end

function CallView:OnClickCall(index)
	if index then
		--判断是否满足条件
		local team_mate_num = ScoietyData.Instance:GetTeamNum()
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		local family_post = role_vo.guild_post
		local camp_post = role_vo.camp_post
		if index == Call.Country and not (camp_post >= 1 and camp_post <= 5) then
			TipsCtrl.Instance:ShowSystemMsg(Language.Convene.NotSatisfiedConditions[index])
			return
		elseif index == Call.Family and family_post == GuildDataConst.GUILD_POST.CHENG_YUAN then
			TipsCtrl.Instance:ShowSystemMsg(Language.Convene.NotSatisfiedConditions[index])
			return
		elseif index == Call.Team and team_mate_num < 2 then
			TipsCtrl.Instance:ShowSystemMsg(Language.Convene.NotSatisfiedConditions[index])
			return
		elseif index == Call.ReviveTotem then
			CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_CREATE_TOTEM_PILLAR, 0)
			return
		elseif index == Call.BloodTotem then
			CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_CREATE_TOTEM_PILLAR, 1)
			return
		end
		--算出还剩下多少次免费召集
		local callin_times = 0
		if index == Call.Country then
			local camp_role_info = CampData.Instance:GetCampRoleInfo()
			local free_call_times = CallData.Instance:GetCampCallCfg().free_call_times
			callin_times = free_call_times - camp_role_info.neizheng_callin_times
		end
		local func = function()
			if index == Call.Country then
				if callin_times > 0 then
					CallCtrl.Instance:SendCallReq(index,1)
					self:Close()
					return																			--第二个参数发1为消耗免费次数，发0为消耗非绑元宝
				end
			end
			CallCtrl.Instance:SendCallReq(index)
			self:Close()
		end
		if index == Call.Country then
			if callin_times > 0 then
				local str = string.format(Language.Convene.FreeTimes, callin_times)
				TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Convene.CallMan[4]..str)
				return
			end
		end
		TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Convene.CallMan[index])
	end
end

function CallView:OnFlush()
	if self.list_view ~= nil then
		self.list_view.scroller:ReloadData(0)
	end
end

function CallView:OnClickClose()
	self:Close()
end


-- 生成的列表
CallItemView = CallItemView or BaseClass(BaseCell)
local ITEM_BG = {
	[1] = "country",
	[2] = "family",
	[3] = "team",
	[4] = "revive_totem",
	[5] = "blood_totem",
}

function CallItemView:__init(instance)
	self:ListenEvent("OnClickChallenge",BindTool.Bind(self.OnIconBtnClick, self))
	self.bg = self:FindVariable("RawImage")
	self.title_text = self:FindVariable("TitleImage")
	self.cost = self:FindVariable("Cost")
	self.times = self:FindVariable("FreeTimes")
	self.show_times = self:FindVariable("ShowFreeTimes")
	self.text = self:FindVariable("Text")
	self.show_text = self:FindVariable("ShowText")
	self.btn_text = self:FindVariable("BtnText")
end

function CallItemView:__delete()
end

function CallItemView:SetIndex(index)
	self.index = index
end

function CallItemView:OnIconBtnClick()
	self:OnClick()
end

function CallItemView:OnFlush()
	if nil == self.data then return end
	self.bg:SetAsset(ResPath.GetRawImage("Call_" .. ITEM_BG[self.data] .. "_bg"))
	self.title_text:SetAsset(ResPath.GetCallImg("word_" .. ITEM_BG[self.data] .. ".png"))

	local team_cost = CallData.Instance:GetIndexCost(self.data)
	self.cost:SetValue(string.format(Language.Convene.CallCost[self.data], team_cost))

	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local family_post = role_vo.guild_post
	local camp_post = role_vo.camp_post
	local camp_role_info = CampData.Instance:GetCampRoleInfo()
	local free_call_times = CallData.Instance:GetCampCallCfg().free_call_times
	local callin_times = free_call_times - camp_role_info.neizheng_callin_times
	self.times:SetValue(ToColorStr(callin_times, TEXT_COLOR.GREEN))
	if self.data == Call.Country then
		self.show_times:SetValue((callin_times > 0 and (camp_post >= 1 and camp_post <= 5)) and true or false)
		self.show_text:SetValue((not (camp_post >= 1 and camp_post <= 5)) and true or false)
		self.text:SetValue(Language.Convene.CallText[1])
	elseif self.data == Call.Family then
		self.show_text:SetValue((family_post ~= GuildDataConst.GUILD_POST.TUANGZHANG and family_post ~= GuildDataConst.GUILD_POST.FU_TUANGZHANG) and true or false)
		self.text:SetValue(Language.Convene.CallText[2])
		self.show_times:SetValue(false)
	elseif self.data == Call.ReviveTotem or self.data == Call.BloodTotem then
		self.text:SetValue(Language.Convene.CallText[1])
		self.btn_text:SetValue(Language.Convene.BtnText[2])
		self.show_text:SetValue(true)
		self.show_times:SetValue(false)
	else
		self.show_text:SetValue(false)
		self.show_times:SetValue(false)
	end
end