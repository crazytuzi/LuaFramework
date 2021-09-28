MarryNoticeView = MarryNoticeView or BaseClass(BaseView)

function MarryNoticeView:__init()
	self.ui_config = {"uis/views/marrynoticeview_prefab","MarryNoticeView"}
	self.play_audio = true
end

function MarryNoticeView:__delete()

end

function MarryNoticeView:LoadCallBack()
	self:ListenEvent("OnClose",
		BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickBlessing",
		BindTool.Bind(self.OnClickBlessing, self))
	self:ListenEvent("OnClickFlower",
		BindTool.Bind(self.OnClickFlower, self))

	self.head1 = self:FindVariable("Head1")
	self.head2 = self:FindVariable("Head2")
	self.name1 = self:FindVariable("Name1")
	self.name2 = self:FindVariable("Name2")
	self.number = self:FindVariable("Number")

	self.rawimage1 = self:FindObj("RawImage1")
	self.rawimage2 = self:FindObj("RawImage2")
	self.default_image1 = self:FindObj("DefaultImage1")
	self.default_image2 = self:FindObj("DefaultImage2")

	self.role_id = 0
end

function MarryNoticeView:ReleaseCallBack()
	self.head1 = nil
	self.head2 = nil
	self.name1 = nil
	self.name2 = nil
	self.number = nil
	self.rawimage1 = nil
	self.rawimage2 = nil
	self.default_image1 = nil
	self.default_image2 = nil
end

function MarryNoticeView:OpenCallBack()

end

function MarryNoticeView:CloseCallBack()

end

function MarryNoticeView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "info" then
			self:FlushAvatar(v)
			self.role_id = v.uid1 or 0
			self.number:SetValue(v.server_marry_times)
			self.name1:SetValue(v.name1)
			self.name2:SetValue(v.name2)
		end
	end
end

function MarryNoticeView:FlushAvatar(info)
	CommonDataManager.SetAvatar(info.uid1, self.rawimage1, self.default_image1, self.head1, GameEnum.MALE, info.prof1, true)
	CommonDataManager.SetAvatar(info.uid2, self.rawimage2, self.default_image2, self.head2, GameEnum.FEMALE, info.prof2, true)
end

-- 点击祝福
function MarryNoticeView:OnClickBlessing()
	MarryNoticeCtrl.Instance:SendMarryZhuheReq(self.role_id, MARRY_ZHUHE_TYPE.MARRY_ZHUHE_TYPE0)
	self:Close()
end

-- 点击送花
function MarryNoticeView:OnClickFlower()
	local role_id = self.role_id
	local yes_func = function()
		MarryNoticeCtrl.Instance:SendMarryZhuheReq(role_id, MARRY_ZHUHE_TYPE.MARRY_ZHUHE_TYPE1)
		self:Close()
	end
	local describe = string.format(Language.Marriage.SendFlower, MarryNoticeData.Instance:GetFlowerPrice())
	TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
end