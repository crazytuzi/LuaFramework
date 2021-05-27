----------------------------------------------------
-- 描述显示
--@author bzw
----------------------------------------------------
DescTip = DescTip or BaseClass(BaseView)
function DescTip:__init()
	if DescTip.Instance then
		ErrorLog("[DescTip] Attemp to create a singleton twice !")
	end
	self.is_modal = true
	self.is_any_click_close = true
	self.config_tab  = {{"itemtip_ui_cfg", 4, {0},}}
	self.title_name = nil

	DescTip.Instance = self
	self.content = ""
	self.title_name_txt = nil
	self.zorder = 99
end

function DescTip:__delete()
	DescTip.Instance = nil
end

function DescTip:LoadCallBack()
	local size = self.node_t_list.img9_bg.node:getContentSize()
	self.scroll_view = XUI.CreateScrollView(size.width / 2, size.height / 2 - 30, size.width, 20, ScrollDir.Vertical)
	self.scroll_view:setAnchorPoint(cc.p(0.5, 1))
	-- self.scroll_view:jumpToTop()
	self.node_t_list.img9_bg.node:addChild(self.scroll_view, 100)
	local scroll_size = self.scroll_view:getContentSize()
	self.rtxt = XUI.CreateRichText(scroll_size.width / 2, 0, scroll_size.width - 10, 20, false)
	self.rtxt:setAnchorPoint(cc.p(0.5, 1))
	self.rtxt:setVerticalSpace(5)
	self.scroll_view:addChild(self.rtxt, 10000)

	self.layout_title = XUI.CreateLayout(size.width / 2, size.height - 20, size.width, 40)
	local title_bg = XUI.CreateImageViewScale9(size.width / 2, 20, size.width, 40, ResPath.GetCommon("bg_101"), true, cc.rect(101.99, 15.5, 26, 10))
	self.layout_title:addChild(title_bg)
	title_bg:setVisible(false)
	self.title_name = XUI.CreateText(10, 5, 151.05, 30.85, 0, "", COMMON_CONSTS.FONT, 24, COLOR3B.YELLOW)
	self.title_name:setAnchorPoint(0, 0.5)
	self.layout_title:addChild(self.title_name)
	self.root_node:addChild(self.layout_title, 10000)
	self.layout_title:setVisible(false)
end

--设置内容
function DescTip:SetContent(content, title_name)
	self.content = content
	self.title_name_txt = title_name
	self:Open()
end

function DescTip:ShowIndexCallBack()
	self:Flush()
end

function DescTip:CloseCallBack()
	self.content = ""
	self.title_name_txt = nil
end

function DescTip:OnFlush()
	RichTextUtil.ParseRichText(self.rtxt, self.content, 22, COLOR3B.WHITE)

	local size = self.node_t_list.img9_bg.node:getContentSize()
	self.rtxt:refreshView()
	local inner_h = self.rtxt:getInnerContainerSize().height
	local all_h = inner_h + 70
	if nil ~= self.title_name_txt and "" ~= self.title_name_txt then
		self.layout_title:setPositionY(all_h - 30)
		self:SetTitleName(self.title_name_txt)
		self.scroll_view:setPosition(size.width / 2, all_h - 50)
		self.scroll_view:setContentSize(cc.size(size.width, all_h - 60))
	else
		all_h = inner_h + 20
		self:SetTitleVisible(false)
		self.scroll_view:setPosition(size.width / 2, all_h - 30)
		self.scroll_view:setContentSize(cc.size(size.width, all_h - 80 + 20))
	end
	self.scroll_view:setInnerContainerSize(cc.size(size.width, inner_h))
	self.rtxt:setPosition(size.width / 2 + 5, inner_h)
	self.node_t_list.img9_bg.node:setContentWH(size.width, all_h)
	self.node_t_list.img9_bg.node:setPositionY(all_h / 2 )
	self.root_node:setContentWH(size.width - 40, all_h)

	self.scroll_view:jumpToTop()
end

function DescTip:SetTitleName(title_name)
	self:SetTitleVisible(true)
	self.title_name:setString(title_name)
end

function DescTip:SetTitleVisible(is_visible)
	self.layout_title:setVisible(is_visible)
end