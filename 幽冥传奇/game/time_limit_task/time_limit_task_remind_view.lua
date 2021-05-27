
-- 限时任务提醒
TimeLimitTaskRemindView = TimeLimitTaskRemindView or BaseClass(BaseView)

function TimeLimitTaskRemindView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)
end

function TimeLimitTaskRemindView:__delete()
end

function TimeLimitTaskRemindView:ReleaseCallBack()
end

function TimeLimitTaskRemindView:LoadCallBack(index, loaded_times)
	local root_node = self:GetRootNode()

	self.img = XUI.CreateImageView(0, 0, ResPath.GetBigPainting("time_limit_task_bg"))
	root_node:addChild(self.img, 0)
	local img_size = self.img:getContentSize()
	root_node:setContentSize(img_size)
	self.img:setAnchorPoint(0, 0)

	self.btn = XUI.CreateButton(img_size.width / 2, 55, 0, 0, false, ResPath.GetCommon("btn_148"), "", "", XUI.IS_PLIST)
	self.btn:setTitleFontName(COMMON_CONSTS.FONT)
	self.btn:setTitleFontSize(22)
	self.btn:setTitleColor(COLOR3B.G_W2)
	self.btn:setTitleText("立即完成")

	root_node:addChild(self.btn, 1)
	XUI.AddClickEventListener(self.btn, function()
		self:GetViewManager():OpenViewByDef(ViewDef.TimeLimitTask)
		self:CloseHelper()
	end)
end

function TimeLimitTaskRemindView:OpenCallBack()
end

function TimeLimitTaskRemindView:CloseCallBack(is_all)
end

function TimeLimitTaskRemindView:ShowIndexCallBack(index)
end

function TimeLimitTaskRemindView:OnFlush(param_t, index)
end
