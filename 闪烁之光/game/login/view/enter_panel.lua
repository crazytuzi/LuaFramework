EnterPanel = class("EnterPanel", function() 
	return ccui.Widget:create()
end)

function EnterPanel:ctor(parent, ctrl)
	self.ctrl = ctrl
	self.size = parent and parent:getContentSize() or cc.size(SCREEN_WIDTH, SCREEN_HEIGHT)
	self.last_login = 0

	self.model = self.ctrl:getModel()
	self.data = self.model:getLoginData()
    self:setContentSize(self.size)
	self:setPosition(self.size.width/2, self.size.height/2)
	self:setCascadeOpacityEnabled(true)

	self:layoutUI()
	self:registerEvent()
end

function EnterPanel:layoutUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("login/enter_panel")) 
	self:addChild(self.root_wnd)
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width/2, self.size.height/2)
	local container = self.root_wnd:getChildByName("container")

	self.btn_user_center = container:getChildByName("btn_user_center")
	self.btn_user_center:setPosition(display.getLeft()+50, display.getTop()-50 )

	self.btn_notice = container:getChildByName("btn_notice")
	self.btn_notice:setPosition(display.getLeft()+50, self.btn_user_center:getPositionY() - self.btn_user_center:getContentSize().height-10)

	self.logo = container:getChildByName("logo")
	self.logo_img = self.logo:getChildByName("logo_img")

	if IS_NEED_SHOW_LOGO == false then
		self.logo_img:setVisible(false)
	else
		loadSpriteTexture(self.logo_img, PathTool.getLogoRes(), LOADTEXT_TYPE)
		self.logo_img:setVisible(true)
	end
	self.logo_size = self.logo:getContentSize()

	self.btn_login_server = container:getChildByName("btn_login_server")
	self.btn_login_server:setCascadeOpacityEnabled(true)
	self.btn_login_server:setVisible(false)

	self.icon_state = self.btn_login_server:getChildByName("icon_state")

	self.txt_cur_server = self.btn_login_server:getChildByName("txt_cur_server")
	self.txt_cur_server:setString("")

	self.btn_label = self.btn_login_server:getChildByName("btn_label")
	self.btn_label:setString(TI18N(""))
	if FINAL_SERVERS ~= nil then
		self.btn_label:setVisible(false)
	end

	self.stateIcon = self.btn_login_server:getChildByName("stateIcon")
	loadSpriteTexture(self.stateIcon, PathTool.getResFrame("login2", "txt_cn_login2_1008"), LOADTEXT_TYPE)
    self.stateIcon:setVisible(false)
	self.btn_enter = container:getChildByName("btn_enter")

	self.checkbox = container:getChildByName("checkbox")
    self.checkbox_lable = createRichLabel(22, cc.c3b(0xff,0xff,0xff), cc.p(0, 0.5), cc.p(140, 238),nil,nil, 1000)
    container:addChild(self.checkbox_lable)
    -- self.checkbox_lable:setString(TI18N("<div fontcolor=#ffffff outline=2,#000000>我已详细阅读并同意<div fontcolor=#eab95b outline=2,#000000>诗悦游戏用户协议</div>和<div fontcolor=#eab95b outline=2,#000000>隐私保护指引</div></div>"))
    self.checkbox_lable:setString(TI18N("<div fontcolor=#ffffff outline=2,#000000>我已详细阅读并同意<div href=onclick_1 fontcolor=#eab95b outline=2,#000000>诗悦游戏用户协议</div>和<div href=onclick_2 fontcolor=#eab95b outline=2,#000000>隐私保护指引</div></div>"))
    self.checkbox_lable:addTouchLinkListener(function(type, value, sender, pos)
        if value == "onclick_1" then
            --用户协议
            local value = "https://game.shiyuegame.com/article_detail_10_34.html"
            if IS_IOS_PLATFORM == true then
                sdkCallFunc("openSyW", value)
            else
                sdkCallFunc("openUrl", value)
            end
        elseif value == "onclick_2" then
            --隐私保护
            local value = "https://game.shiyuegame.com/article_detail_10_37.html"
            if IS_IOS_PLATFORM == true then
                sdkCallFunc("openSyW", value)
            else
                sdkCallFunc("openUrl", value)
            end
        end
    end, { "click", "href" })

    self.is_agree = SysEnv:getInstance():getBool(SysEnv.keys.user_proto_agree, false)
    self.checkbox:setSelected(self.is_agree)

	-- 提审服不可见公告面板,以及不显示修复按钮
	if MAKELIFEBETTER == true then
		self.btn_notice:setVisible(false)
		self.logo:setVisible(false);
		self.btn_user_center:setVisible(false)
	else
		if NEED_SHOW_REPAIR == true then	-- 控制包体是否显示修复按钮
			self.btn_repair = container:getChildByName("btn_repair")
			self.btn_repair:setPosition(display.getLeft()+50, self.btn_notice:getPositionY() - self.btn_notice:getContentSize().height-10)
			self.btn_repair:setVisible(true)
		end
		if canAddScannig() then
			self.btn_scan = container:getChildByName("btn_scan")
			self.btn_scan:setVisible(true)
			if self.btn_repair then
				self.btn_scan:setPosition(display.getLeft()+50, self.btn_repair:getPositionY() - self.btn_repair:getContentSize().height-10)
			else
				self.btn_scan:setPosition(display.getLeft()+50, self.btn_notice:getPositionY() - self.btn_notice:getContentSize().height-10)
			end
		end
	end

	-- 适配
	local top_off = display.getTop(container)
	local bottom_off = display.getBottom(container)
	self.logo:setPositionY(top_off-248)
	if checkUserProto and checkUserProto() then
		self.btn_login_server:setPositionY(bottom_off+320)
		self.btn_enter:setPositionY(bottom_off+238)
		self.checkbox:setPositionY(bottom_off+170)
		self.checkbox_lable:setPositionY(bottom_off+170)
	else
		self.btn_login_server:setPositionY(bottom_off+285)
		self.btn_enter:setPositionY(bottom_off+170)
		self.checkbox:setVisible(false)
		self.checkbox_lable:setVisible(false)
	end


	-- 特殊处理--4.4
	if needMourning() then
		setChildUnEnabled(true, self.logo)
		setChildUnEnabled(true, self.btn_repair)
		setChildUnEnabled(true, self.btn_repair)
		setChildUnEnabled(true, self.btn_scan)
		setChildUnEnabled(true, self.btn_notice)
		setChildUnEnabled(true, self.btn_user_center)
		setChildUnEnabled(true, self.btn_login_server)
		setChildUnEnabled(true, self.btn_enter)
		setChildUnEnabled(true, self.checkbox)
		self.checkbox_lable:setString(TI18N("<div fontcolor=#818181 >我已详细阅读并同意<div href=onclick_1 fontcolor=#818181 >诗悦游戏用户协议</div>和<div href=onclick_2 fontcolor=#818181 >隐私保护指引</div></div>"))
	end
end

function EnterPanel:registerEvent()
	self.btn_enter:addTouchEventListener(function(sender, event_type)
	    if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			self:requestEnterGame()
	    end
	end)

	registerButtonEventListener(self.checkbox, function()
        local is_select = self.checkbox:isSelected()
        self.is_agree = is_select
        SysEnv:getInstance():set(SysEnv.keys.user_proto_agree, self.is_agree, true)
    end, false, 1) 

	registerButtonEventListener(self.btn_repair, function() 
		local desc_str = TI18N("该操作会清除本地的补丁并重新下载补丁,请在良好的网络环境下进行")
		CommonAlert.show(desc_str, TI18N("确定"), function()
			cc.UserDefault:getInstance():setIntegerForKey("lasted_main_version", BUILD_VERSION)
	        cc.UserDefault:getInstance():setIntegerForKey("lasted_version", 0)
	        cc.UserDefault:getInstance():setIntegerForKey("local_version", 0)
	        cc.UserDefault:getInstance():setIntegerForKey("local_try_version", 0)
	        cc.UserDefault:getInstance():flush()
	        local path = string.format("%sassets/", cc.FileUtils:getInstance():getWritablePath())
	        if cc.FileUtils:getInstance():isDirectoryExist(path) then
	            cc.FileUtils:getInstance():removeDirectory(path)
	        end
	        path = string.format("%stryver/", cc.FileUtils:getInstance():getWritablePath())
	        if cc.FileUtils:getInstance():isDirectoryExist(path) then
	            cc.FileUtils:getInstance():removeDirectory(path)
	        end
	        path = string.format("%svoice/", cc.FileUtils:getInstance():getWritablePath())
	        if cc.FileUtils:getInstance():isDirectoryExist(path) then
	            cc.FileUtils:getInstance():removeDirectory(path)
	        end
			sdkOnSwitchAccount()
        end, TI18N("取消")) 
	end, false, 1)

	if self.btn_scan then
		self.btn_scan:addTouchEventListener(function(sender, event_type)
		    if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				local loginData = LoginController:getInstance():getModel():getLoginData()
        		local output = string.format('{"ip":"%s", "port":"%s", "host":"%s", "rid":"%s", "srv_id":"%s", "usrName":"%s", "srv_name":"%s"}', loginData.ip, loginData.port, loginData.host, loginData.rid, loginData.srv_id, loginData.usrName, loginData.srv_name)
        		callFunc("scanning", output)
		    end
		end)
	end

	self.btn_login_server:addTouchEventListener(function(sender, event_type)
	    if event_type == ccui.TouchEventType.ended then
			if IS_EXPERT == true then return end		-- 专家服不需要打开选服面板的
			if FINAL_SERVERS ~= nil then return end

		    if checkUserProto and checkUserProto() and not self.is_agree then
		    	message(TI18N("请勾选同意开始游戏按钮下方的 诗悦游戏用户协议 和 隐私保护指引,即可选择服务器")) 
		        return
		    end

			-- if LoginController:getInstance():getModel():checkIsNewAccount() then -- 新账号则不让选服,并且直接进游戏
			-- 	self:requestEnterGame()
			-- 	return
			-- end
			if self.model:getServerList() == nil or next(self.model:getServerList()) == nil or self.model:getSverListStatus() == false then
				message(TI18N("服务器列表正在加载中..."))
				self.model:checkReloadServerData()
	    		return
			end
	    	self.ctrl:openView(LoginController.type.server_list)
	    end
	end)

	self.btn_user_center:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			sdkOnSwitchAccount()
		end
	end)

	self.btn_notice:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			NoticeController:getInstance():openNoticeView()
		end
	end)

	-- 默认服务器数据返回
	if not self.defaule_server_success_event then
		self.defaule_server_success_event = GlobalEvent:getInstance():Bind(LoginEvent.DEFAULE_SERVER_SUCCESS, function ()
			self:updateChoseServerName()
		end)
	end
end

-- 更新选服文字
function EnterPanel:updateChoseServerName(  )
	-- if LoginController:getInstance():getModel():checkIsNewAccount() then
	-- 	self.btn_label:setString(TI18N("首发新服"))
	-- else
		self.btn_label:setString(TI18N("选择服务器"))
	-- end
end

--==============================--
--desc:请求进入游戏
--time:2017-08-11 03:22:10
--@return 
--==============================--
function EnterPanel:requestEnterGame(is_agree)
    if checkUserProto and checkUserProto() and not self.is_agree and not is_agree then 
        message(TI18N("请勾选同意开始游戏按钮下方的 诗悦游戏用户协议 和 隐私保护指引,即可进入游戏"))
        return
    end
    self.is_agree = true
    self.checkbox:setSelected(self.is_agree)

	local function enterGame()
    	local data = self.model:getLoginData()
	    if data.srv_id == nil or data.srv_id == "" or data.usrName == "" then 
	    	self.ctrl:openView(LoginController.type.user_input)
	    	return
	    end

    	if data.ip==nil or #data.ip == 0 then
    		message(TI18N("当前服务器不可用"))
	    	self.ctrl:openView(LoginController.type.server_list)
    		return
    	end

	    if (os.time() - self.last_login) > (RECONNEST_INTERVAL or 5) then
	        self.last_login = os.time()
            sdkSubmitUserData(1)
	        self.ctrl:requestLoginGame(data.usrName, data.ip, data.port, true, true)
	    end
	end

	-- 点击冷却还是给效果只是不处理
	if (os.time() - self.last_login) <= (RECONNEST_INTERVAL or 5) then
		return
	end

	local data = self.model:getLoginData()
	if NEED_CHECK_CLOSE and (data.isClose or GameNet:getInstance():getTime() - data.open_time < 0) then
	    -- 重新请求下载服务器列表
	    self.model:checkReloadServerData(data)
        return
	end

    if not self.model:isNeedReload(TI18N("优先体验服变换，需要重新加载资源才能进入游戏"), data, sdkOnSwitchAccount) then
        self.model:saveCurSrv()
        enterGame()
    end
end

function EnterPanel:update()
	self:reselectedTarget()
end

function EnterPanel:effectHandler()
	if self.hasShowFinish then return end
	self.logo:stopAllActions()
	self.btn_login_server:stopAllActions()
	self.btn_enter:stopAllActions()

	self.txt_cur_server:setVisible(false)
	self.icon_state:setVisible(false)
 	self.stateIcon:setVisible(false)
 	self.btn_label:setVisible(false)

	self.btn_login_server:setOpacity(0)
	self.btn_enter:setOpacity(0)
	self.logo:setScale(0)
	self.logo:setOpacity(0)

	self.checkbox:setOpacity(0)
	self.checkbox_lable:setOpacity(0)

	local action = cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.5, 1), cc.FadeIn:create(0.5)), 
					cc.CallFunc:create( function()
						local action1 = cc.Sequence:create( cc.FadeIn:create(0.5), cc.CallFunc:create(
							function ()
								self.txt_cur_server:setVisible(true)
								if FINAL_SERVERS == nil then
									self.btn_label:setVisible(true)
								end
								self.icon_state:setVisible(true)
								if IS_NEED_LOGIN_EFFECT == true and not self.spine and not isVestPackage() then 
									self.spine = createEffectSpine(PathTool.getEffectRes(122), cc.p(self.logo_size.width/2-28, self.logo_size.height/2-64) , cc.p(0.5,0.5),true,PlayerAction.action,nil,cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
									self.logo:addChild(self.spine)
								end
								-- 这里要重新计算一下是否显示
								if self.need_show_status then
    								self.stateIcon:setVisible(true)
    							end
							end))

						self.btn_login_server:runAction(action1)
						local action2 = cc.Sequence:create( cc.FadeIn:create(0.5) )
						self.btn_enter:runAction(action2)
						self.checkbox:runAction(cc.Sequence:create( cc.FadeIn:create(0.5) ))
						self.checkbox_lable:runAction(cc.Sequence:create( cc.FadeIn:create(0.5) ))

					end))
	self.logo:runAction(action)
	self.hasShowFinish = true
	local list = self.model.loginData.newNameList or {}
	local is_show_user_proto = true
	if next(list) == nil then --说明没有账号来
		if self.is_agree then --说明是旧账号 --保存
			is_show_user_proto = false
		end
		SysEnv:getInstance():set(SysEnv.keys.user_proto_name_list, {{usr = self.model.loginData.usrName}}, true)
	else
		for i,v in ipairs(list) do
			if v.usr == self.model.loginData.usrName then
				is_show_user_proto = false
				break
			end
		end
		--说明是新账号
		if is_show_user_proto then
			self.is_agree = false
    		self.checkbox:setSelected(self.is_agree)
    		SysEnv:getInstance():set(SysEnv.keys.user_proto_agree, self.is_agree, false)
    		table.insert(list, 1, {usr=self.model.loginData.usrName})
    		SysEnv:getInstance():set(SysEnv.keys.user_proto_name_list, list, true)
		end
	end

	if is_show_user_proto and checkUserProto and checkUserProto() then
		--判断如果没有缓存文件 打开用户协议界面
		self.ctrl:openUserProtoPanel(true, function() self:requestEnterGame(true) end)
	end
end

function EnterPanel:DeleteMe()
	if self.spine then
		self.spine:setVisible(false)
		self.spine:clearTracks()
		self.spine:removeFromParent() 
	end
	if self.btn_enter and not tolua.isnull(self.btn_enter) then
		self.btn_enter:stopAllActions()
	end
    if self.defaule_server_success_event then
    	GlobalEvent:getInstance():UnBind(self.defaule_server_success_event)
    	self.defaule_server_success_event = nil
    end
	self:removeAllChildren()
    self:removeFromParent()
end

function EnterPanel:reselectedTarget()
	self.data = self.model:getLoginData()

	self.need_show_status = false
	if self.data == nil or self.data.usrName == nil or self.data.usrName == "" then
		self.btn_login_server:setVisible(false)
	else
		self.btn_login_server:setVisible(true)
		-- 这个时候服务器列表还没有初始化完全
		local cur_server = self.data
	    --如果服务器处于维护状态,优先判断维护状态
	    local status
	    if cur_server.isClose then
	    	status = 2
			setChildUnEnabled(true, self.stateIcon)
	    elseif cur_server.isNew then
			setChildUnEnabled(false, self.stateIcon)
	    	status = 0
	    else
			setChildUnEnabled(false, self.stateIcon)
	    	status = 1
	    end
	    --只要不是正常状态,都显示
	    self.need_show_status = (status ~= 1)
		if status ~= 1 then
			loadSpriteTexture(self.stateIcon, PathTool.getResFrame("login2", "txt_cn_login2_1008"), LOADTEXT_TYPE_PLIST)
		end
	    self.stateIcon:setVisible(self.need_show_status)
	    self.icon_state:loadTexture(PathTool.getResFrame("login2", "login2_100"..status), LOADTEXT_TYPE_PLIST)
		self.txt_cur_server:setString(cur_server.srv_name or "")
	end
	self.btn_enter:setTouchEnabled(true)

	-- 特殊处理--4.4
	if needMourning() then
		setChildUnEnabled(true, self.stateIcon)
	end
end
