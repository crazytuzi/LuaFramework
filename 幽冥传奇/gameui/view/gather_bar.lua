------------------------------------------------------
--采集进度条
------------------------------------------------------
GatherBar = GatherBar or BaseClass(XuiBaseView)

function GatherBar:__init()
	if GatherBar.Instance ~= nil then
		ErrorLog("[FunctionGuide] attempt to create singleton twice!")
		return
	end
	self.zorder = -1000
	GatherBar.Instance = self
end

function GatherBar:__delete()
	GatherBar.Instance = nil
end

function GatherBar:ReleaseCallBack()
	if self.progressbar then
		self.progressbar:DeleteMe()
		self.progressbar =nil
	end
end

function GatherBar:LoadCallBack()
	self.gather = XUI.CreateLayout(0, -160, 0, 0)
	self.root_node:addChild(self.gather)

	self.gather_progress_bg = XUI.CreateImageViewScale9(0, 0, 280, 28, ResPath.GetMainui("gather_progress_bg"), true, cc.rect(33, 12, 5, 4))
	self.gather:addChild(self.gather_progress_bg)

	self.gather_progress = XUI.CreateLoadingBar(0, 1, ResPath.GetMainui("gather_progress"), true, nil, true, 265, 16, cc.rect(9, 2, 2, 12))
	self.gather:addChild(self.gather_progress)

	local part_left = XUI.CreateImageView(-140, 0, ResPath.GetMainui("gather_progress_part"))
	self.gather:addChild(part_left)

	local part_right = XUI.CreateImageView(140, 0, ResPath.GetMainui("gather_progress_part"))
	self.gather:addChild(part_right)
	part_right:setScaleX(-1)

	self.tip_txt = XUI.CreateText(0, 30, 200, 30, nil, Language.Common.Gathering, nil, 22)
	self.gather:addChild(self.tip_txt)

	self.progressbar = ProgressBar.New()
	self.progressbar:SetView(self.gather_progress)
	self.progressbar:SetTailEffect(3047)
	self.progressbar:SetCompleteCallback(BindTool.Bind1(self.CompleteLoading, self))
end

function GatherBar:OpenCallBack()
	self.tip_txt:setString(Language.Common.Gathering)
	self:InitShowCallback()
	if nil ~= self.special_callback then
		self.special_callback(true)
	end
end

function GatherBar:CloseCallBack()
	if nil ~= self.special_callback then
		self.special_callback(false)
		self.special_callback = nil
	end
end

function GatherBar:SetGatherTime(time)
	self.progressbar:SetPercent(0, false)
	self.progressbar:SetTotalTime(time - 0.2)
	self.progressbar:SetPercent(100, true)
end

function GatherBar:CompleteLoading()
	self:Close()
end

function GatherBar:SetTipString(des)
	self.tip_txt:setString(des)
end

function GatherBar:SetShowCallback(func)
	self.special_callback = func
end

--区分不同场景
function GatherBar:InitShowCallback(is_show)
	if SceneType.GuildStation == Scene.Instance:GetSceneType() then			--仙盟酒会倒酒特效
		self.special_callback = function(is_show)
			GuildCtrl.Instance:ShowToastEffect(is_show)
		end
	end
end