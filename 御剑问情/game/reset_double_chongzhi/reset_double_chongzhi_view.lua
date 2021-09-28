--------------------------------------------------------------------------
--PuTianTongQingView 	普天同庆面板
--------------------------------------------------------------------------

ResetDoubleChongzhiView = ResetDoubleChongzhiView or BaseClass(BaseView)

function ResetDoubleChongzhiView:__init()
	self.ui_config = {"uis/views/restdoublechongzhi_prefab", "RestDoubleChongZhiView"}
	self.play_audio = true
end

function ResetDoubleChongzhiView:__delete()
	-- body
end

--打开回调函数
function ResetDoubleChongzhiView:OpenCallBack()
	self:Flush()
end

--关闭回调函数
function ResetDoubleChongzhiView:CloseCallBack()

end

--释放回调
function ResetDoubleChongzhiView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self.act_time = nil
	self.show_btn = nil
end

function ResetDoubleChongzhiView:LoadCallBack()
	self.act_time = self:FindVariable("act_time")
	self.show_btn = self:FindVariable("show_btn")

	self:ListenEvent("ClickClose", BindTool.Bind(self.OnCloseClick, self))
	self:ListenEvent("ClickChongZhi", BindTool.Bind(self.OnChongZhiClick, self))
end

function ResetDoubleChongzhiView:OnFlush()
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
end

--关闭页面
function ResetDoubleChongzhiView:OnCloseClick()
	self:Close()
end

function ResetDoubleChongzhiView:OnChongZhiClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ResetDoubleChongzhiView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	local time_type = 1
	if time > 3600 * 24 then
		time_type = 6
	elseif time > 3600 then
		time_type = 1
	else
		time_type = 2
	end
	
	self.act_time:SetValue(TimeUtil.FormatSecond(time, time_type))
end



