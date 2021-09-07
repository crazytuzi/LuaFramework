MonomerView = MonomerView or BaseClass(BaseView)

function MonomerView:__init()
	self.ui_config = {"uis/views/marriageview","MonomerView"}
	self:SetMaskBg(true)
	self.view_layer = UiLayer.Pop
end

function MonomerView:__delete()

end

function MonomerView:LoadCallBack()
	self.input_field = self:FindObj("InputField")

	self.btn_text = self:FindVariable("BtnText")

	self:ListenEvent("CloseWinow",BindTool.Bind(self.ClickClose, self))
	self:ListenEvent("ClickTuoDan",BindTool.Bind(self.ClickTuoDan, self))
end

function MonomerView:OpenCallBack()
	self.input_field.input_field.text = ""
	-- local is_in_list = MarriageData.Instance:IsInTuoDanList()
	-- if is_in_list then
	-- 	self.btn_text:SetValue("单身万岁")
	-- else
	-- 	self.btn_text:SetValue("我要脱单")
	-- end
end

function MonomerView:ReleaseCallBack()
	self.btn_text = nil
	self.input_field = nil
end

function MonomerView:ClickClose()
	self:Close()
end

function MonomerView:ClickTuoDan()
	local is_in_list = MarriageData.Instance:IsInTuoDanList()
	local des = self.input_field.input_field.text
	-- if is_in_list then
	-- 	MarriageCtrl.Instance:SendTuodanReq(TUODAN_OPERA_TYPE.TUODAN_DELETE)
	-- else
	if des == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotTuoDanDes)
		return
	end
	if ChatFilter.Instance:IsIllegal(des) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ContentUnlawful)
		return
	end
	local length = StringUtil.GetCharacterCount(des)
	if length > 15 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.TuoDanDesTooLength)
		return
	end
	MarriageCtrl.Instance:SendTuodanReq(TUODAN_OPERA_TYPE.TUODAN_INSERT, des)
	-- end
	self:Close()

	--设置发送时间
	MarriageData.Instance:SetSendTuoDanTime()
end