SettingSelectView = SettingSelectView or BaseClass(BaseView)

function SettingSelectView:__init()
	self.can_penetrate = true -- 屏蔽根节点触摸
	self:SetIsAnyClickClose(true)

	self.btn_t = {}
	self.bg = nil
	self.data_t = {}
end

function SettingSelectView:__delete()

end

function SettingSelectView:ReleaseCallBack()
	self.btn_t = {}
	self.bg = nil
	self.scroll_view = nil
end

function SettingSelectView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
	
	end
end

function SettingSelectView:SelectSettingIndex(index)
	if self.call_back then
		self.call_back(#self.data_t - index)
	end
	self:Close()
end

function SettingSelectView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function SettingSelectView:SetDataAndOpen(data_t, call_back)
	self.data_t = data_t
	self.call_back = call_back
	self:Open()
end
function SettingSelectView:OpenCallBack()
	local inner_h = #self.data_t * 60 + 30
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()

	-- 1：竖向 2：横向：3：横竖都可以
	-- ScrollDir = { Vertical = 1, Horizontal = 2, Both = 3}
	-- -- 卷轴视图
	-- function XUI.CreateScrollView(x, y, w, h, direction)

	local h =  inner_h > (screen_h - 50) and (screen_h - 50) or inner_h
	if nil == self.scroll_view then
		self.root_node:setPosition(screen_w / 2, (screen_h - h) / 2)
		self.root_node:setContentWH(120, h)
		self.root_node:setAnchorPoint(0.5, 0)
		self.scroll_view = XUI.CreateScrollView(179, 0, 120, h, ScrollDir.Vertical)
		self.scroll_view:setAnchorPoint(0.5, 0)
		self.root_node:addChild(self.scroll_view, 2)
		self.scroll_view:setInnerContainerSize(cc.size(120, inner_h))
		-- self.scroll_view:setScorllDirection(ScrollDir.Horizontal)
	else
		self.root_node:setPosition(screen_w / 2, (screen_h - h) / 2 )
		self.root_node:setContentWH(120, h)
		self.scroll_view:setContentWH(120, h)
		self.scroll_view:setInnerContainerSize(cc.size(120, inner_h))
	end


	if nil == self.bg then
		self.root_node:setPosition(screen_w / 2, (screen_h - h) / 2)
		self.root_node:setContentWH(120, h)
		self.root_node:setAnchorPoint(0.5, 0)
		self.bg = XUI.CreateImageViewScale9(179, 0, 120, h, ResPath.GetCommon("img9_108"), true)
		self.bg:setAnchorPoint(0.5, 0)
		self.root_node:addChild(self.bg)
	else
		self.root_node:setPosition(screen_w / 2, (screen_h - h) / 2 )
		self.root_node:setContentWH(120, h)
		self.bg:setContentWH(120, h)
	end
	
	local inner_container = self.scroll_view:getInnerContainer()
	for i = 1, #self.data_t do
		if self.btn_t[i] == nil then
			local btn = XUI.CreateButton(60, i * 60 - 16, 0, 0, false, ResPath.GetCommon("btn_151"), "", "", true)
			btn:setTitleFontSize(18)
			btn:setTitleFontName(COMMON_CONSTS.FONT)
			btn:setTitleColor(cc.c3b(217, 212, 194))
			inner_container:addChild(btn)
			btn:addClickEventListener(BindTool.Bind(self.SelectSettingIndex, self, i))
			self.btn_t[i] = btn
		else
			self.btn_t[i]:setVisible(true)
		end
		self.btn_t[i]:setTitleText(self.data_t[#self.data_t - i + 1])
	end
	for i = #self.data_t + 1, #self.btn_t do
		self.btn_t[i]:setVisible(false)
	end
	
	self.scroll_view:jumpToTop()
end

function SettingSelectView:CloseCallBack()

end


function SettingSelectView:OnFlush(param_t, index)
	
end