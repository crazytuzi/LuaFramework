------------------------------------------------------
-- 奖励进度条
------------------------------------------------------
RewardBar = RewardBar or BaseClass(XuiBaseView)

function RewardBar:__init()
end

function RewardBar:__delete()
end

function RewardBar:ReleaseCallBack()
	if self.progressbar then
		self.progressbar:DeleteMe()
		self.progressbar = nil
	end
end

function RewardBar:LoadCallBack()
	self.gather = XUI.CreateLayout(-30, -195, 0, 0)
	self.root_node:addChild(self.gather)

	self.gather_progress_bg = XUI.CreateImageViewScale9(0, 0, 392, 36, ResPath.GetCommon("prog_104"), true, cc.rect(50, 0, 10, 0))
	self.gather:addChild(self.gather_progress_bg)

	self.gather_progress = XUI.CreateLoadingBar(0, 0, ResPath.GetCommon("prog_104_progress"), true)
	self.gather_progress:setScaleX(0.9)
	self.gather:addChild(self.gather_progress)
	self.gather_progress:setPosition(0, 0.4)

	self.tip_txt = XUI.CreateText(0, 30, 200, 30, nil, "", nil, 22)
	self.tip_txt:setVisible(false)
	self.gather:addChild(self.tip_txt)

	self.progressbar = ProgressBar.New()
	self.progressbar:SetView(self.gather_progress)
	self.progressbar:SetTailEffect(991, nil, true)
	self.progressbar:SetEffectOffsetX(- 19)
	self.progressbar:SetEffectOffsetY(2)
	self.progressbar:SetCompleteCallback(BindTool.Bind1(self.CompleteLoading, self))
end

function RewardBar:OpenCallBack()
	self.tip_txt:setString(Language.Common.Gathering)
	self:InitShowCallback()
	if nil ~= self.special_callback then
		self.special_callback(true)
	end
end

function RewardBar:CloseCallBack()
	if nil ~= self.special_callback then
		self.special_callback(false)
		self.special_callback = nil
	end
end

function RewardBar:SetGatherTime(time)
	self.progressbar:SetPercent(0, false)
	self.progressbar:SetTotalTime(time - 0.2)
	self.progressbar:SetPercent(100, true)
end

function RewardBar:CompleteLoading()
	-- Scene.PlayOneFlyEffect(918, nil, HandleRenderUnit:GetWidth() * 0.5 -30, HandleRenderUnit:GetHeight() * 0.5 -195)
	self:Close()
end

function RewardBar:SetTipString(des)
	self.tip_txt:setString(des)
end

function RewardBar:SetShowCallback(func)
	self.special_callback = func
end

--区分不同场景
function RewardBar:InitShowCallback(is_show)
end