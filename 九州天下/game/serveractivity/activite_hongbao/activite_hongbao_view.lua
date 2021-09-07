ActiviteHongBaoView = ActiviteHongBaoView or BaseClass(BaseView)
local PANEL_NUM = 3
function ActiviteHongBaoView:__init()
	self.ui_config = {"uis/views/serveractivity/openserverredpacket", "OpenServerRedPack"}
	self.play_audio = true
	self:SetMaskBg(true)
end

function ActiviteHongBaoView:__delete()

end

function ActiviteHongBaoView:CloseCallBack()

end

function ActiviteHongBaoView:LoadCallBack()
	self.title = self:FindVariable("Title")
	self.close_day = self:FindVariable("CloseTime")
	self.reward_desc = self:FindVariable("RewardText")
	self.get_diamond = self:FindVariable("GetDiamond")
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickGetDiamon", BindTool.Bind(self.OnClickGetDiamon, self))
	self.panel_list = {}
	for i = 1, PANEL_NUM do
		self.panel_list[i] = self:FindObj("Panel" .. i)
	end
end

function ActiviteHongBaoView:ReleaseCallBack()
	-- 清理变量和对象
	self.title = nil
	self.close_day = nil
	self.reward_desc = nil
	self.get_diamond = nil
	self.panel_list = nil
end

function ActiviteHongBaoView:OpenCallBack()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local total_day = GameEnum.NEW_SERVER_DAYS - open_day + 1 			-- 剩余天数
	self.close_day:SetValue(string.format(Language.ActHongBao.NeedDay, total_day))
	if open_day > GameEnum.NEW_SERVER_DAYS then
		self:ShowView(2)
		self.title:SetValue(Language.ActHongBao.TitleHongBao)
	else
		self:ShowView(1)
		self.title:SetValue(Language.ActHongBao.TitleReturn)
	end
	self:Flush()
end

function ActiviteHongBaoView:OnFlush()
	local return_percent = ActiviteHongBaoData.Instance:GetReturnPercent()
	local get_diamond_num = math.floor(ActiviteHongBaoData.Instance:GetDiamondNum() * return_percent * 0.01)
	local reward_ser = string.format(Language.ActHongBao.RewardDesc, return_percent)

	self.get_diamond:SetValue(get_diamond_num)
	self.reward_desc:SetValue(reward_ser)
	local flag = ActiviteHongBaoData.Instance:GetFlag()
	if flag == ActHongBaoFlag.HasGet then
		self:ShowView(3)
	end
end

function ActiviteHongBaoView:ShowView(index)
	for i = 1, PANEL_NUM do
		if i == index then
			self.panel_list[i]:SetActive(true)
		else
			self.panel_list[i]:SetActive(false)
		end
	end
end

function ActiviteHongBaoView:OnClickClose()
	self:Close()
end

function ActiviteHongBaoView:OnClickGetDiamon()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HONG_BAO)
end