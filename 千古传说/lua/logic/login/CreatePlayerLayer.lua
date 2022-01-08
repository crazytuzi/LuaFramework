
local CreatePlayerLayer = class("CreatePlayerLayer", BaseLayer)

CREATE_SCENE_FUN(CreatePlayerLayer)
CREATE_PANEL_FUN(CreatePlayerLayer)


local firstName = localizable.createPlayer_firstname
local secondName = localizable.createPlayer_secondName

local RoleIdList = GetPlayerRoleList()
function CreatePlayerLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.login.CreatePlayerLayer")


end

function CreatePlayerLayer:initUI(ui)
	self.super.initUI(self,ui)

	   	-- 名字配置
    self.nameList = require("lua.table.t_s_name")
	self.familyNameNum 	= 0
	self.ManNameNum 	= 0
	self.WomanNameNum 	= 0

    -- 统计姓 名的个数
    for v in self.nameList:iterator() do
        if v.familyname ~= "" then
        	self.familyNameNum = self.familyNameNum + 1
        end

        if v.manname ~= "" then
        	self.ManNameNum = self.ManNameNum + 1
        end

        if v.womanname ~= "" then
        	self.WomanNameNum = self.WomanNameNum + 1
        end
    end

    -- print("name(%d, %d, %d)", self.familyNameNum, self.ManNameNum, self.WomanNameNum)

	self.btn_role 		= {}
	self.img_icon 		= {}
	self.OkBtn 			= TFDirector:getChildByPath(ui, 'createOkBtn')
	self.img_role 		= TFDirector:getChildByPath(ui, 'img_role')
	self.btn_roll 		= TFDirector:getChildByPath(ui, 'btn_roll')
	self.img_choice 	= TFDirector:getChildByPath(ui, 'img_choice')
	self.playernameInputbg 	= TFDirector:getChildByPath(ui, 'Image_CreatePlayerLayer_1(3)')
	self.playernameInput = TFDirector:getChildByPath(ui, 'playernameInput')
	self.playernameInput:setCursorEnabled(true)

	for i=1,4 do
		local str = "btn_role_" .. i
		self.btn_role[i] 	= TFDirector:getChildByPath(ui, str)
		self.btn_role[i]:setTag(i)
		self.btn_role[i].logic = self
		str = "img_icon_" .. i
		self.img_icon[i] 	= TFDirector:getChildByPath(ui, str)
	end
	self.OkBtn.logic = self
	self.btn_roll.logic = self

    self.selectRoleIndex = 1
	for i=1,4 do
		local roleid = RoleIdList[i]
		local roleInfo = RoleData:objectByID(roleid)
		if roleInfo ~= nil then
			self.img_icon[i]:setTexture(roleInfo:getHeadPath())
	    end
	end
	self.RoleBtnClickHandle(self.btn_role[1])
	self:RollName()

end

function CreatePlayerLayer:registerEvents(ui)	
	self.super.registerEvents(self)

	for i=1,4 do
		self.btn_role[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.RoleBtnClickHandle))
	end

	self.OkBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.OkBtnClickHandle),1)
	self.btn_roll:addMEListener(TFWIDGET_CLICK, audioClickfun(self.RollBtnClickHandle),1)
	TFDirector:addProto(s2c.CREATE_PLAYER_RESULT, self, self.createPlayerHandle)

	local pos = self.playernameInputbg:getPosition()
	print("pos(%d, %d)", pos.x, pos.y)

		--添加输入账号时输入框上移逻辑
	local function onTextFieldAttachHandle(input)
        self.playernameInputbg:setPosition(ccp(pos.x,165))
    end
    self.playernameInput:addMEListener(TFTEXTFIELD_ATTACH, onTextFieldAttachHandle)

    local function onTextFieldChangedHandle(input)
		-- print("2222222")
		-- if self.textEditListen == false then
		-- 	return
		-- end
		-- print("444444444")
  --       self.playernameInputbg:setPosition(ccp(pos.x,245))
    end
    self.playernameInput:addMEListener(TFTEXTFIELD_TEXTCHANGE, onTextFieldChangedHandle)

    local function onTextFieldDetachHandle(input)
		print("3333333333")
        self.playernameInputbg:setPosition(ccp(pos.x, pos.y))
    end
    self.playernameInput:addMEListener(TFTEXTFIELD_DETACH, onTextFieldDetachHandle)
    self.playernameInput:setMaxLengthEnabled(true)
    self.playernameInput:setMaxLength(10)

    ADD_KEYBOARD_CLOSE_LISTENER(self, self.ui)

    TFDirector:addProto(s2c.LOGIN_RESULT, self, self.loginHandle)
end

function CreatePlayerLayer:removeEvents()
	TFDirector:removeProto(s2c.CREATE_PLAYER_RESULT, self, self.createPlayerHandle)

    
	TFDirector:removeProto(s2c.LOGIN_RESULT, self, self.loginHandle)
end

function CreatePlayerLayer:removeUI()
	self.super.removeUI(self)

	self.btn_role			= nil
	self.img_icon			= nil
	self.OkBtn				= nil
	self.img_role			= nil
	self.btn_roll			= nil
	self.img_choice			= nil
	self.playernameInput	= nil
	self.selectRoleIndex    = nil
end

function CreatePlayerLayer:loginHandle(event)
		print("event = ", event)
	if event.data.statusCode == 0 then
		if event.data.empty then
			hideAllLoading()
		end
	else
		--toastMessage("登陆失败")
		toastMessage(localizable.common_login_fail)
	end
end

function CreatePlayerLayer:playChooseAction(index)
	-- local self = logic
	local pos = self.img_role:getPosition()
	if self.ChooseEffect == nil then
		local resPath = "effect/createroleaction.xml"
	    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
	    local effect = TFArmature:create("createroleaction_anim")

	    effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:setPosition(ccp(self:getSize().width/2,self:getSize().height/2))

        self:addChild(effect,2)

       
	    effect:addMEListener(TFARMATURE_COMPLETE,function()
	        -- effect:removeMEListener(TFARMATURE_COMPLETE) 
	        -- effect:removeFromParent()
	    end)

	    self.ChooseEffect = effect
   	end
   	TFAudio.playEffect("sound/bgmusic/choose.mp3", false)
    self.ChooseEffect:playByIndex(index, -1, -1, 0)
end

function CreatePlayerLayer.RoleBtnClickHandle(sender)
	local self = sender.logic
	if self == nil then return end
	self.img_choice:setPosition(sender:getPosition())
	-- 如果性别 有变化则重新随机名字
	local newTag = sender:getTag()
	local oldTag = self.selectRoleIndex
	self.selectRoleIndex = sender:getTag()

	if newTag > 2 and oldTag <= 2 then
		self:RollName()
	elseif newTag <= 2 and oldTag > 2 then
		self:RollName()
	end

	-- 
	self.img_role:setTexture("ui_new/createplayer/role_"..self.selectRoleIndex..".png")--roleInfo:getImagePath())
	
	-- self.img_role:setVisible(false)
	self:playChooseAction(self.selectRoleIndex-1)
end

function CreatePlayerLayer.RollBtnClickHandle(sender)
	local self = sender.logic
	if self == nil then return end
	self:RollName()
end

function CreatePlayerLayer:RollName()
	local x = 0--math.random(0,100)%2
	local name = 0
	-- if x == 0 then
	-- 	local f1 = math.random(1,#firstName)
	-- 	local f2 = math.random(1,#secondName)
	-- 	name = firstName[f1] .. secondName[f2]
	-- else
	-- 	local f1 = math.random(1,#firstName)
	-- 	local f2 = math.random(1,#secondName)
	-- 	name = secondName[f2] ..firstName[f1] 
	-- end

	-- 
	local f1 			= math.random(1, self.familyNameNum)
	local familyname 	= self.nameList:getObjectAt(f1).familyname
	local name 			= ""
	-- 男
	if self.selectRoleIndex <= 2 then
		local f2 = math.random(1, self.ManNameNum)
		name = self.nameList:getObjectAt(f2).manname

	-- 女
	else
		local f2 = math.random(1, self.WomanNameNum)
		name = self.nameList:getObjectAt(f2).womanname
	end

	-- print("familyname = %s,len = %d", familyname, string.len(familyname))
	-- print("name = %s", name)
	self.playernameInput:setText(familyname..name)
end

function CreatePlayerLayer.OkBtnClickHandle(btn)
	if btn.logic.selectRoleIndex == nil then
		--toastMessage("请选择角色")
		toastMessage(localizable.createPlayer_check_player)
		return
	end

	local playerName = btn.logic.playernameInput:getText()
	if playerName == nil or playerName == "" then
		--toastMessage("请输入角色名")
		toastMessage(localizable.createPlayer_input_player)
		return
	end

	local roleid = RoleIdList[btn.logic.selectRoleIndex]
	local roleInfo = RoleData:objectByID(roleid)
	if roleInfo == nil then
		--toastMessage("角色不存在")
		toastMessage(localizable.createPlayer_not_player)
		return
	end
	
	if CommonManager:getConnectionStatus() == false then
		print("创建角色的时候网络是关闭的， 重新连接")
		CommonManager:loginServer()
		return
	end

	local sex = {1,1,0,0}
	local createPlayerMsg = 			
	{
		playerName,
		sex[btn.logic.selectRoleIndex],
		roleInfo.id,
	}
    showLoading();
	TFDirector:send(c2s.REGIST_DATA, createPlayerMsg)
end

function CreatePlayerLayer:createPlayerHandle(event)
	if event.data.statusCode ~= 0 then
		hideLoading();
		--toastMessage("创建角色失败")
		toastMessage(localizable.createPlayer_create_fail)
	end
end


return CreatePlayerLayer;
