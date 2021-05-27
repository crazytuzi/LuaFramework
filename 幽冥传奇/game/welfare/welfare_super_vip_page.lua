SuperVipPage = SuperVipPage or BaseClass()

function SuperVipPage:__init()
	
end

function SuperVipPage:__delete()
	self:RemoveEvent()

	self.view = nil
end

--初始化页面接口
function SuperVipPage:InitPage(view)
	--绑定要操作的元素
	if self.view then return end
	self.view = view
	self:InitEvent()
	local scroll_node = self.view.node_t_list["rich_svip_info"].node
	local rich_svip_info = XUI.CreateRichText(50, 0, 640, 0, false)
	scroll_node:addChild(rich_svip_info, 100, 100)
	RichTextUtil.ParseRichText(rich_svip_info, Language.SuperVip.GiftInfo)
	-- HtmlTextUtil.SetString(rich_svip_info, Language.SuperVip.GiftInfo or "")
	rich_svip_info:refreshView()
	local scroll_size = scroll_node:getContentSize()
	local inner_h = math.max(rich_svip_info:getInnerContainerSize().height + 20, scroll_size.height)
	scroll_node:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	rich_svip_info:setPosition(scroll_size.width / 2, inner_h - 10)
	scroll_node:getInnerContainer():setPositionY(scroll_size.height - inner_h)
end	

--初始化事件
function SuperVipPage:InitEvent()
	local data = WelfareData.Instance:GetSvipSpidInfo()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	XUI.AddClickEventListener(self.view.node_t_list.img_oninfo.node, BindTool.Bind1(self.UpPersonInfo, self), true)
end

function SuperVipPage:RemoveEvent()

end



function SuperVipPage:UpdateData(index)
	local data = WelfareData.Instance:GetSvipSpidInfo()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	if level >= data.vip_level then
		self.view.node_t_list.img_oninfo.node:setVisible(true)
		self.view.node_t_list.img_info.node:setVisible(true)
	else
		self.view.node_t_list.img_oninfo.node:setVisible(false)
		self.view.node_t_list.img_info.node:setVisible(false)
	end
	self.view.node_t_list.txt_term.node:setString(string.format(Language.SuperVip.GetSvipTerm, data.vip_level))
	self.view.node_t_list.txt_my_vip_lv.node:setString(string.format(Language.SuperVip.LevelInfo, level))
	-- self.view.node_t_list.txt_kefu_chat.node:setString("微信：" .. data.kefu_chat)
	-- self.view.node_t_list.txt_kefu_qq.node:setString("Q Q：" .. data.kefu_qq)
end

function SuperVipPage:UpPersonInfo()
	ViewManager.Instance:Open(ViewName.ExtremeVipCommonView)
end



