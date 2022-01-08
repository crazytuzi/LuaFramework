
local CreatePlayerNew = class("CreatePlayerNew", BaseLayer)

CREATE_SCENE_FUN(CreatePlayerNew)
CREATE_PANEL_FUN(CreatePlayerNew)


--local firstName = {"雪山","飞狐","七道","双剑","江湖","虾米","剑客","刀郎","情剑",}
--local secondName = {"戴神","甘道","医胃","何小","杨大","郭菜","李四","陶大"}
local firstName = localizable.createPlayer_firstname
local secondName = localizable.createPlayer_secondName

local RoleIdList = GetPlayerRoleList()

function CreatePlayerNew:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.login.CreatePlayerNew")
end

function CreatePlayerNew:initUI(ui)
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

	self.btn_role 		= {}
	self.OkBtn 			= TFDirector:getChildByPath(ui, 'Btn_star')
	self.bg 			= TFDirector:getChildByPath(ui, 'bg')
	self.txt_desc1		= TFDirector:getChildByPath(ui, 'TextDesc1')
	self.img_name		= TFDirector:getChildByPath(ui, 'Image_Name')
	self.txt_desc2		= TFDirector:getChildByPath(ui, 'TextDesc2')
	self.img_role 		= TFDirector:getChildByPath(ui, 'role_big')
	self.btn_roll 		= TFDirector:getChildByPath(ui, 'Btn_rename')
	self.Img_zhiye		= TFDirector:getChildByPath(ui, 'Img_zhiye')
	self.anim_panel		= TFDirector:getChildByPath(ui, 'anim_panel')
	self.playernameInputbg 	= TFDirector:getChildByPath(ui, 'bg_name')
	self.playernameInput = TFDirector:getChildByPath(ui, 'playernameInput')
	self.playernameInput:setCursorEnabled(true)

	self.txt_desc1:setVisible(false)


	for i=1,4 do
		-- local str = "Button_CreatePlayerNew_" .. i
		local str = "Image_CreatePlayerNew_" .. i
		self.btn_role[i] 	= TFDirector:getChildByPath(ui, str)
		self.btn_role[i]:setTag(i)
		self.btn_role[i].logic = self
	end


	self.roleNormalTextures = {'ui_new/createplayer/g1b.png','ui_new/createplayer/g3b.png','ui_new/createplayer/g4b.png','ui_new/createplayer/g2b.png'}
	self.roleSelectedTextures = {'ui_new/createplayer/g1.png','ui_new/createplayer/g3.png','ui_new/createplayer/g4.png','ui_new/createplayer/g2.png'}
	self.zhiyeTextures = {'ui_new/common/img_role_type1.png','ui_new/common/img_role_type3.png','ui_new/common/img_role_type4.png','ui_new/common/img_role_type2.png'}

	self.OkBtn.logic = self
	self.btn_roll.logic = self

	--print("------------------------CreatePlayerNew----------------------")
	math.randomseed(os.time())	
    self.selectRoleIndex = 1 + math.ceil(math.random()*100)%4
	self.RoleBtnClickHandle(self.btn_role[self.selectRoleIndex])
	self:RollName()

	self:addBottomEffect()
	-- self:playEffect()
	-- Public:addEffect("main_bg1", self.bg, self.bg:getSize().width/2 + 400, self.bg:getSize().height/2, 0.5)
end

function CreatePlayerNew:addBottomEffect()
	-- local resPath = "effect/ui/level_role_down.xml"
 --    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
 --    local effect = TFArmature:create("level_role_down_anim")
 --    effect:setPosition(ccp(160,180))
 --    effect:setZOrder(-1)
 --    self.anim_panel:addChild(effect)
 --    effect:playByIndex(0, -1, -1, 0)

 --    local resPath_1 = "effect/ui/level_up_lizi.xml"
 --    TFResourceHelper:instance():addArmatureFromJsonFile(resPath_1)
 --    local effect_1 = TFArmature:create("level_up_lizi_anim")
 --    effect_1:setPosition(ccp(90,10))
 --    self.anim_panel:addChild(effect_1)
 --    effect_1:playByIndex(0, -1, -1, 1)

    local effect = Public:addEffect("level_role_down", self.anim_panel, 150, -70, 0.55)
    effect:setZOrder(-1)
    Public:addEffect("level_up_lizi", self.anim_panel, 150,-100, 1)
end

function CreatePlayerNew:onRoleButtonSelect( index )
	for i=1,4 do
		-- self.btn_role[i]:setTextureNormal(self.roleNormalTextures[i])
		self.btn_role[i]:setTexture(self.roleNormalTextures[i])
		if self.btn_role[i].effect then
			self.btn_role[i].effect:setVisible(false)
		end
	end
	local curBtn = self.btn_role[index]
	-- self.btn_role[index]:setTextureNormal(self.roleSelectedTextures[index])
	curBtn:setTexture(self.roleSelectedTextures[index])
	if not curBtn.effect then
		curBtn.effect = Public:addEffect("chuangjianjuese1", curBtn:getParent(), curBtn:getPositionX(), curBtn:getPositionY() + 20, 1)
		curBtn.effect:setZOrder(10)
	end
	curBtn.effect:setVisible(true)
	self.Img_zhiye:setTexture(self.zhiyeTextures[index])

	self:playAnimByRoleId(index)
end


-- self.armature:play("move")
-- self.armature:play("back")
-- self.armature:play("attack", -1, -1, 0)
-- self.armature:play("skill", -1, -1, 0)
-- self.armature:play("stand", -1, -1, 1)
-- self.armature:play("hit", -1, -1, 0)


function CreatePlayerNew:playAnimByRoleId( index )

	local roleid = RoleIdList[index]
	if self.currEffect then
		self.currEffect:removeFromParent()
		self.currEffect = nil
	end

	if self.preRoleAnim then
		self.preRoleAnim:removeFromParent()
		self.preRoleAnim = nil
	end

	if self.currRoleAnim then
		self.preRoleAnim = self.currRoleAnim
		self.preRoleAnim:setVisible(true)
		self.preRoleAnim:play("move")
		self.currRoleAnim = nil
	end

	-- self.currRoleAnim = GameResourceManager:getRoleAniById(roleid)
	-- self.currRoleAnim.step = 1
	-- self.currRoleAnim:setPosition(ccp(-200,-60))
 --    self.currRoleAnim:play("move")
 --    self.currRoleAnim:setScale(1.3)
 --    self.anim_panel:addChild(self.currRoleAnim)
 --    self:SaveRoleID(roleid)


    local roleData =  RoleData:objectByID(roleid)
    local armatureID = roleData.image
    ModelManager:addResourceFromFile(1, armatureID, 1)
    self.currRoleAnim = ModelManager:createResource(1, armatureID)
    self.currRoleAnim.step = 1
	self.currRoleAnim:setPosition(ccp(-200,-60))
    self.currRoleAnim:play("move")
    self.currRoleAnim:setScale(1.2)
    self.anim_panel:addChild(self.currRoleAnim)
    self:SaveRoleID(roleid)

    --加阴影
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/main_role2.xml")
	local effect2 = TFArmature:create("main_role2_anim")
	if effect2 ~= nil then
		effect2:setAnimationFps(GameConfig.ANIM_FPS)
		effect2:playByIndex(0, -1, -1, 1)
		effect2:setZOrder(-1)
		effect2:setPosition(ccp(0, -10))
		self.currRoleAnim:addChild(effect2)
	end

    self.currEffect = self:getEffectByRoleId(index)
    self.currEffect:setPosition(ccp(0,0))
    self.anim_panel:addChild(self.currEffect)


    if self.reardTimeId then
    	TFDirector:removeTimer(self.reardTimeId);
        self.reardTimeId = nil
    end

	if self.attackSoundTimerID then
		TFDirector:removeTimer(self.attackSoundTimerID)
		self.attackSoundTimerID = nil
	end

    local moveDx = 380
    local movePreDx = nil

    if self.preRoleAnim then
    	if self.preRoleAnim:getPositionX() >= 370 then
	    	movePreDx = 1
	    	self.currRoleAnim:setVisible(false)
	    else
			self.preRoleAnim:removeFromParent()
			self.preRoleAnim = nil
	    end
    end

	local function moveToPositonIn()
		if movePreDx then
			movePreDx = movePreDx * 3
		else
			moveDx = math.floor(moveDx/2)
		end
		if self.reardTimeId then
	    	TFDirector:removeTimer(self.reardTimeId);
	        self.reardTimeId = nil
	    end

		if moveDx > 0 then	
			if self.preRoleAnim then
				self.preRoleAnim:setPositionX(self.preRoleAnim:getPositionX() + movePreDx)
				if movePreDx > 800 then
					movePreDx = nil
					self.preRoleAnim:removeFromParent()
					self.preRoleAnim = nil
					self.currRoleAnim:setVisible(true)
				end
			else
				self.currRoleAnim:setPositionX(self.currRoleAnim:getPositionX() + moveDx)
			end

			self.reardTimeId = TFDirector:addTimer(66, 1 , nil, moveToPositonIn)
		else
			if self.preRoleAnim then
				self.preRoleAnim:removeFromParent()
				self.preRoleAnim = nil
			end
			self.currRoleAnim.step = self.currRoleAnim.step + 1
			-- self.currRoleAnim:play(self.currEffect.skillName, -1, -1, 0)
			ModelManager:playWithNameAndIndex(self.currRoleAnim, self.currEffect.skillName, -1, 0, -1, -1)

			if self.soundStartTime ~= nil and self.soundStartTime > 0 then
				self.attackSoundTimerID = TFDirector:addTimer(self.soundStartTime / FightManager.fightSpeed, 1, nil, 
				function() 
					if self.attackSoundTimerID then
						TFDirector:removeTimer(self.attackSoundTimerID)
						self.attackSoundTimerID = nil
					end
					self.attackSoundTimerID = nil
					TFAudio.playEffect(self.soundFile, false)
				end)
			else
				TFAudio.playEffect(self.soundFile, false)
			end

			self.currEffect:setPosition(self.currRoleAnim:getPosition())
			-- self.currEffect:playByIndex(0, -1, -1, 0)
			ModelManager:playWithNameAndIndex(self.currEffect, "", 0, 0, -1, -1)

			ModelManager:addListener(self.currRoleAnim, "ANIMATION_COMPLETE", function() 
				ModelManager:removeListener(self.currRoleAnim, "ANIMATION_COMPLETE")
				ModelManager:playWithNameAndIndex(self.currRoleAnim, "stand", -1, 1, -1, -1)
			end)

			-- self.currRoleAnim:addMEListener(TFARMATURE_COMPLETE,
			-- 	function()
			-- 		self.currRoleAnim:removeMEListener(TFARMATURE_COMPLETE)
			-- 		self.currRoleAnim:play("stand", -1, -1, 1)
			-- end)
		end
	end
	moveToPositonIn()
end


function CreatePlayerNew:playEffect()

	TFResourceHelper:instance():addArmatureFromJsonFile("effect/main_bg1.xml")
	local eff2 = TFArmature:create("main_bg1_anim")
	eff2:setPosition(ccp(self.bg:getSize().width/2,self.bg:getSize().height/2))
	eff2:setAnimationFps(GameConfig.ANIM_FPS)
	eff2:playByIndex(0, -1, -1, 1)
	eff2:setZOrder(1000)

	self.bg:addChild(eff2)
end

function CreatePlayerNew:getEffectByRoleId( index )


	local roleid = RoleIdList[index]
	local spell_id = nil
	local descr1 = nil
	local descr2 = nil
	local imgName = nil
	if index == 1 then
		spell_id = 7799		--杨过
		descr1 = localizable.createPlayer_namelist[1]
		descr2 = localizable.createPlayer_desc[1]
		imgName = "ui_new/Ys_font/chuangjue_lvdongbin.png"
	elseif index == 2 then
		spell_id = 7899		--张无忌
		descr1 = localizable.createPlayer_namelist[2]
		descr2 =localizable.createPlayer_desc[2]
		imgName = "ui_new/Ys_font/chuangjue_change.png"
	elseif index == 3 then
		spell_id = 7999		--周芷若
		descr1 = localizable.createPlayer_namelist[3]
		descr2 = localizable.createPlayer_desc[3]
		imgName = "ui_new/Ys_font/chuangjue_niexiaoqian.png"
	else
		spell_id = 8099		--黄蓉
		descr1 = localizable.createPlayer_namelist[4]
		descr2 = localizable.createPlayer_desc[4]
		imgName = "ui_new/Ys_font/chuangjue_jiangziya.png"
	end
	TFAudio.stopAllEffects()
	RoleSoundData:playSoundByIndex(roleid)

	-- self.txt_desc1:setText(descr1)
	self.img_name:setTexture(imgName)
	self.txt_desc2:setText(descr2)


	local spellInfo = SkillBaseData:objectByID(spell_id);
	local skillInfo = SkillDisplayData:objectByID(spellInfo.display_id)
	if skillInfo == nil then
		print("can't find "..spellInfo.display_id.." display_id")
		return
	end
	
	local nEffectID = skillInfo.attackEff[1]
	-- local resPath = "effect/"..nEffectID..".xml"
	-- if not TFFileUtil:existFile(resPath) then
	-- 	return
	-- end
	-- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
	

	-- local skillEff = TFArmature:create(nEffectID.."_anim")
	if not ModelManager:existResourceFile(2, nEffectID) then
		return
	end
	ModelManager:addResourceFromFile(2, nEffectID, 1)
	local skillEff = ModelManager:createResource(2, nEffectID)
	if skillEff == nil then
		return
	end
	skillEff.skillName = skillInfo.attackAnim
	skillEff:setScale(1.2)

	--sound
	local attackSoundID = skillInfo.attackSound
	if attackSoundID == nil or attackSoundID == 0 then
		return
	end
	self.soundFile = "sound/skill/"..attackSoundID..".mp3"
	self.soundStartTime = skillInfo.attackSoundTime	

	return skillEff
end

function CreatePlayerNew:SaveRoleID( id )
	local size = 1
	self.StorageRoleID = self.StorageRoleID or {}
	for k,v in pairs(self.StorageRoleID) do
		if v == id then
			return
		end
		size = size + 1
	end

	self.StorageRoleID[size] = id
end

function CreatePlayerNew:ReleaseRoleID()	
	for k,v in pairs(self.StorageRoleID) do
		GameResourceManager:deleRoleAniById(v)
	end
end

function CreatePlayerNew:registerEvents(ui)	

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
		print("onTextFieldAttachHandle")
        self.playernameInputbg:setPosition(ccp(pos.x,440))
    end
    
    self.playernameInput:addMEListener(TFTEXTFIELD_ATTACH, onTextFieldAttachHandle)

    local function onTextFieldChangedHandle(input)
		--self.playernameInputbg:setPosition(ccp(pos.x, pos.y))
		--self.playernameInput:closeIME()
    end
    self.playernameInput:addMEListener(TFTEXTFIELD_TEXTCHANGE, onTextFieldChangedHandle)

    local function onTextFieldDetachHandle(input)
        self.playernameInputbg:setPosition(ccp(pos.x, pos.y))
        self.playernameInput:closeIME()
    end
    self.playernameInput:addMEListener(TFTEXTFIELD_DETACH, onTextFieldDetachHandle)
    self.playernameInput:setMaxLengthEnabled(true)
    self.playernameInput:setMaxLength(10)

    local function spaceAreaClick(sender)
    	self.playernameInputbg:setPosition(ccp(pos.x, pos.y))
    	self.playernameInput:closeIME()
	end
    self.ui:setTouchEnabled(true)
    self.ui:addMEListener(TFWIDGET_CLICK, spaceAreaClick)


    ADD_KEYBOARD_CLOSE_LISTENER(self, self.ui)
    TFDirector:addProto(s2c.LOGIN_RESULT, self, self.loginHandle)
end

function CreatePlayerNew:removeEvents()
	TFDirector:removeProto(s2c.CREATE_PLAYER_RESULT, self, self.createPlayerHandle)    
	TFDirector:removeProto(s2c.LOGIN_RESULT, self, self.loginHandle)

	self.super.removeEvents(self)
	for i=1,4 do
		self.btn_role[i]:removeMEListener(TFWIDGET_CLICK)
	end
	self.OkBtn:removeMEListener(TFWIDGET_CLICK)
	self.btn_roll:removeMEListener(TFWIDGET_CLICK)
    self.playernameInput:removeMEListener(TFTEXTFIELD_ATTACH)
    self.playernameInput:removeMEListener(TFTEXTFIELD_TEXTCHANGE)
    self.playernameInput:removeMEListener(TFTEXTFIELD_DETACH)
    self.ui:removeMEListener(TFWIDGET_CLICK)
end

function CreatePlayerNew:removeUI()
	self.super.removeUI(self)

	self.btn_role			= nil
	--self.img_icon			= nil
	self.OkBtn				= nil
	self.img_role			= nil
	self.btn_roll			= nil
	--self.img_choice			= nil
	self.playernameInput	= nil
	self.selectRoleIndex    = nil

	if self.attackSoundTimerID then
		TFDirector:removeTimer(self.attackSoundTimerID)
		self.attackSoundTimerID = nil
	end
	if self.reardTimeId then
    	TFDirector:removeTimer(self.reardTimeId);
        self.reardTimeId = nil
	end

	self:ReleaseRoleID()

	if self.currEffect then
		self.currEffect:removeFromParent()
		self.currEffect = nil
	end

	if self.preRoleAnim then
		self.preRoleAnim:removeFromParent()
		self.preRoleAnim = nil
	end

	if self.currRoleAnim then
		self.preRoleAnim = self.currRoleAnim
		self.preRoleAnim:removeFromParent()
		self.currRoleAnim = nil
	end
end

function CreatePlayerNew:loginHandle(event)
		print("event = ", event)
	if event.data.statusCode == 0 then
		if event.data.empty then
			hideAllLoading()
		end
	else
		--toastMessage("登陆失败")
		toastMessage(localizable.loginNoticePage_login_fail)
	end
end

function CreatePlayerNew:playChooseAction(index)
	-- local self = logic
	local pos = self.img_role:getPosition()
	if self.ChooseEffect == nil then
		local resPath = "effect/createroleaction.xml"
	    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
	    local effect = TFArmature:create("createroleaction_anim")

	    effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:setPosition(ccp(self:getSize().width/2,self:getSize().height/2))

        self:addChild(effect,2)
       
	    self.ChooseEffect = effect
   	end
   	TFAudio.playEffect("sound/bgmusic/choose.mp3", false)
    self.ChooseEffect:playByIndex(index, -1, -1, 0)
end

function CreatePlayerNew.RoleBtnClickHandle(sender)
	local self = sender.logic
	if self == nil then return end
	
	-- 如果性别 有变化则重新随机名字
	local newTag = sender:getTag()
	local oldTag = self.selectRoleIndex
	self.selectRoleIndex = sender:getTag()

	self:onRoleButtonSelect(self.selectRoleIndex)

	if newTag > 2 and oldTag <= 2 then
		self:RollName()
	elseif newTag <= 2 and oldTag > 2 then
		self:RollName()
	end

	self.img_role:setTexture("ui_new/createplayer/role_"..self.selectRoleIndex..".png")
	--self:playChooseAction(self.selectRoleIndex-1)
end

function CreatePlayerNew.RollBtnClickHandle(sender)
	local self = sender.logic
	if self == nil then return end
	self:RollName()
end

function CreatePlayerNew:RollName()
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
	local isMale		= self.selectRoleIndex == 1 or self.selectRoleIndex == 4
	-- 男
	if isMale then
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

function CreatePlayerNew.OkBtnClickHandle(btn)
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

function CreatePlayerNew:createPlayerHandle(event)
	if event.data.statusCode ~= 0 then
		hideLoading();
		--toastMessage("创建角色失败")
		toastMessage(localizable.createPlayer_create_fail)
	else
		MainPlayer.bIsNewRole = true
		print("创建角色成功")
	end
end


return CreatePlayerNew;
