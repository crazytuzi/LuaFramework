DaMoExChangeTips = DaMoExChangeTips or BaseClass(BaseView)
function DaMoExChangeTips:__init()
	self.ui_config = {"uis/views/hunqiview_prefab", "DaMoExChangeTips"}
	self.view_layer = UiLayer.Pop
end

function DaMoExChangeTips:ReleaseCallBack()
	self.btn_text = nil
	self.title_text = nil
	self.content = nil
end

function DaMoExChangeTips:LoadCallBack()
	self.btn_text = self:FindVariable("BtnText")
	self.title_text = self:FindVariable("TitleText")
	self.content = self:FindVariable("Content")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickBtn", BindTool.Bind(self.ClickBtn, self))
end

function DaMoExChangeTips:CloseWindow()
	self:Close()
end

function DaMoExChangeTips:ClickBtn()
	HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_EXCHANGE_IDENTIFY_EXP)
end

function DaMoExChangeTips:OpenCallBack()
	self:Flush()
end

function DaMoExChangeTips:OnFlush()
	local times = HunQiData.Instance:GetExChangeTimes()
	local exchange_list = HunQiData.Instance:GetExChangeCfg()
	if nil == exchange_list then
		return
	end
	local data = nil
	for k, v in ipairs(exchange_list) do
		if v.seq == times then
			data = v
			break
		end
	end
	if nil == data then
		self:Close()
		return
	end
	local left_times = #exchange_list - 1 - data.seq
	local des = string.format(Language.HunQi.ExChangeDes, data.consume_gold, data.reward_exp, left_times)
	self.content:SetValue(des)
end