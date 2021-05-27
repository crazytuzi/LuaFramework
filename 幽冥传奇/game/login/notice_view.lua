NoticeView = NoticeView or BaseClass(BaseView)
function NoticeView:__init()
	self:SetModal(true)
	self.zorder = COMMON_CONSTS.ZORDER_LOGIN + 10
	self.texture_path_list[1] = 'res/xui/login.png'

	self.config_tab = {
		{"login_ui_cfg", 5, {0}},
	}
	self.content = ""
	self:RecvMainInfoCallBack()
end

function NoticeView:__delete()
end

function NoticeView:ReleaseCallBack()

end

function NoticeView:RecvMainInfoCallBack()
	local real_url = ""
	if self.view_def == ViewDef.Notice then
		local url = GLOBAL_CONFIG.param_list.notice_query_url
		if nil == url then return end
		local spid = AgentAdapter:GetSpid()
		local server_id = 0
		local type_id = 1
		real_url = string.format("%s?spid=%s&server=%s&type=%s", url, spid, server_id, type_id)
		--Log("log_real_url==" .. real_url)

	elseif self.view_def == ViewDef.UserAgreement then -- 用户协议
		local spid = AgentAdapter:GetSpid()
		local type_id = 1
		real_url = string.format("http://l.cqtest.jianguogame.com:88/api/c2s/fetch_text.php?spid=%s&type=%s", spid, type_id)
		--Log("log_real_url==" .. real_url)

	elseif self.view_def == ViewDef.PrivacyPolicy then -- 隐私保护政策
		local spid = AgentAdapter:GetSpid()
		local type_id = 2
		real_url = string.format("http://l.cqtest.jianguogame.com:88/api/c2s/fetch_text.php?spid=%s&type=%s", spid, type_id)
		--Log("log_real_url==" .. real_url)
	end

	HttpClient:Request(real_url, "", function(url, arg, data, size)
			self:VerifyCallback(url, arg, data, size)
		end)
end

function NoticeView:VerifyCallback(url, arg, data, size)
 	local ret_t = cjson.decode(data)
	if nil == ret_t or 0 ~= ret_t.ret or nil == ret_t.msg or nil == ret_t.data then
		return
	end

	self:SetEverydayContent(ret_t.data)
end

-- 设置日常公告内容
function NoticeView:SetEverydayContent(data)
	if "table" ~= type(data) or nil == next(data) then return -1 end

	local content = ""
	for k,v in ipairs(data) do
		local str = v.content
		str = string.gsub(str, "\\n", "\n")
		content = content .. str .. "\n"
	end

	if self.view_def == ViewDef.Notice then
		WelfareData.AfficheContent = content
	else
		self.content = content
	end

	self:Flush()
end

function NoticeView:LoadCallBack(index, loaded_times)
	local title_text = ""
	if self.view_def == ViewDef.Notice then
		title_text = "公告"
	elseif self.view_def == ViewDef.UserAgreement then -- 用户协议
		title_text = "用户协议"
	elseif self.view_def == ViewDef.PrivacyPolicy then -- 隐私保护政策
		title_text = "隐私保护政策"
	end
	self.node_t_list["lbl_title"].node:setString(title_text)

	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	self.root_node:setContentSize(cc.size(screen_w, screen_h))
	self.node_tree.layout_notice.node:setPosition(screen_w / 2, screen_h / 2)

	--创建背景
	local bg_path = "agentres/login_bg.jpg"
	local login_bg = "agentres/login_bg.jpg"
	if cc.FileUtils:getInstance():isFileExist(login_bg) then
		bg_path = login_bg
	end
	self.bg1 = XUI.CreateImageView(screen_w / 2, screen_h / 2, bg_path, false)
	self.root_node:addChild(self.bg1, 0, 0)

	-- local top_img = XUI.CreateImageView(screen_w / 2, screen_h, ResPath.GetLogin("bg_top"))
	-- top_img:setAnchorPoint(0.5, 1)
	-- self.root_node:addChild(top_img, 0, 0)

	-- local down_img = XUI.CreateImageView(screen_w / 2, 0, ResPath.GetLogin("bg_top"))
	-- down_img:setAnchorPoint(0.5, 1)
	-- down_img:setScaleY(-1)
	-- self.root_node:addChild(down_img, 0, 0)

	self.scroll_node = self.node_t_list.scroll_text_content.node

	self.rich_content = XUI.CreateRichText(10, 10, 600, 0, false)
	self.scroll_node:addChild(self.rich_content, 100, 100)
	
	XUI.AddClickEventListener(self.node_tree.layout_notice.layout_btn_login.node, BindTool.Bind1(self.OnClickEnter, self), true)
end

function NoticeView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function NoticeView:OpenCallBack()

end

function NoticeView:CloseCallBack()

end

function NoticeView:OnFlush(param_t, index)
	if self.view_def == ViewDef.Notice then
		HtmlTextUtil.SetString(self.rich_content, WelfareData.AfficheContent)
	else
		HtmlTextUtil.SetString(self.rich_content, self.content)
	end

	self.rich_content:refreshView()

	local scroll_size = self.scroll_node:getContentSize()
	local inner_h = math.max(self.rich_content:getInnerContainerSize().height + 20, scroll_size.height)
	self.scroll_node:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	self.rich_content:setPosition(scroll_size.width / 2, inner_h - 10)
	self.scroll_node:jumpToTop()
	
end

function NoticeView:OnClickEnter()
	self:CloseHelper()
end