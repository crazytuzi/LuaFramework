--[[
	只作用于测试服的创建角色面板
]]
UserPanel = class("UserPanel", function() 
	return ccui.Layout:create()
end)

function UserPanel:ctor(parent, ctrl)
	self.ctrl = ctrl
	self.model = self.ctrl:getModel()
	self.data = self.model:getLoginData()

	self.size = parent and parent:getContentSize() or cc.size(SCREEN_WIDTH, SCREEN_HEIGHT)
    self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)
	self:setPosition(self.size.width/2, self.size.height/2)

	self.root_wnd = createCSBNote(PathTool.getTargetCSB("login/user_panel"))
	self:addChild(self.root_wnd)
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width/2, self.size.height/2)
		
	self.user_name_input = self.root_wnd:getChildByName("user_name_input")
	self.user_name_input:setMaxLength(99)
	if self.data.usrName and self.data.usrName ~= "" then -- 平台用户名
		self.user_name_input:setString(self.data.usrName)
	else
		self.user_name_input:setPlaceHolder(TI18N("请输入账号"))
	end

	self.password_input = self.root_wnd:getChildByName("password_input")
	if self.data.password and self.data.password ~= "" then -- 密码
		self.password_input:setString(self.data.password)
	else
		self.password_input:setPlaceHolder(TI18N("请输入密码"))
	end

	self.btn_login = self.root_wnd:getChildByName("btn_login")
	if self.btn_login ~= nil then
		self.btn_login:setTitleText(TI18N("登陆"))
	end

	self.btn_regist = self.root_wnd:getChildByName("btn_regist")
	if self.btn_regist ~= nil then
		self.btn_regist:setTitleText(TI18N("一键注册"))
	end

	local function textFieldEvent(sender, eventType)
		if eventType == ccui.TextFiledEventType.attach_with_ime then
			sender:setString("")
        elseif eventType == ccui.TextFiledEventType.detach_with_ime then
        elseif eventType == ccui.TextFiledEventType.insert_text then
        elseif eventType == ccui.TextFiledEventType.delete_backward then
        end
	end
	self.user_name_input:addEventListener(textFieldEvent)
	self.password_input:addEventListener(textFieldEvent)

	--注册相关事件
	self:registerEvent()
end

--[[
	注册相关
]]
function UserPanel:registerEvent()
	if self.btn_login then
		self.btn_login:addTouchEventListener(function ( sender, eventType )
			if eventType == ccui.TouchEventType.ended then
				playButtonSound2()
				local usr = self.user_name_input:getString()
				local password = self.password_input:getString()
				if #usr < 2 or StringUtil.getStrLen(usr)>99 then
					message(TI18N("账户名字不对，必需是2-12位英文与数字组合"))
					return
				end
				if #password < 2 or #password>32 then
					message(TI18N("密码不对，必需是2-16位字符组合"))
					return
				end
				local data = {}
		    	data.isTourist = false
		    	data.usrName = usr
		    	data.password = password

		    	-- 登陆游戏,主要检测账号密码,同时下载默认服务器列表
		    	self.ctrl:loginPlatformRequest(data)
			end
		end)
	end

	if self.btn_regist then
		self.btn_regist:addTouchEventListener(function ( sender, eventType )
			if eventType == ccui.TouchEventType.ended then
				playButtonSound2()
				self:registAccount()
			end
		end)
	end
end

function UserPanel:registAccount()
	local function randomName(str)	
		local result = str
		local a = string.char(math.random(65, 90))
		local b = string.char(math.random(97, 122))
		local c = string.char(math.random(48, 57))
		if math.random(3) % 3 == 0 then
			result = result..a
		elseif  math.random(3) % 2 == 0 then
			result = result..b
		else
			result = result..c
		end
		if StringUtil.getStrLen(result)<12 then
			result = randomName(result)
		end
		return result
	end

	local usr = randomName("")
	local password = tostring(math.random(100000000000, 900000000000))
	self.user_name_input:setString(usr)
	self.password_input:setString(password)
	local data = {}
	data.usrName = usr
	data.password = password
	-- 一键注册
	self.ctrl:loginPlatformRequest(data)
end

--[[
	预留	
]]
function UserPanel:update()
end

--[[
	预留
]]
function UserPanel:effectHandler()
end

function UserPanel:DeleteMe()
	self:removeAllChildren()
    self:removeFromParent()
end