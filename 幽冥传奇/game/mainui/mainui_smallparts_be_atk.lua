----------------------------------------------------
-- 主ui小部件（被攻击）
----------------------------------------------------
MainuiSmallParts = MainuiSmallParts or BaseClass()

function MainuiSmallParts:InitBeAtked()
	self.be_attacked_icon = nil
	self.be_attacked_time = 0
	self.remove_attacked_icon_time = 0
	self.be_attakced_update_t = nil
end

function MainuiSmallParts:DeleteBeAtk()
	if nil ~= self.be_attacked_icon then
		self.be_attacked_icon:DeleteMe()
		self.be_attacked_icon = nil
	end
end

function MainuiSmallParts:InitBeAtkedUi( ... )
	-- body
end

function MainuiSmallParts:CreateBeAttackedIcon(role_id, prof)
	if Status.NowTime - self.remove_attacked_icon_time <= 3 then
		return
	end

	if Status.NowTime - Scene.Instance:GetMainRole():GetLaskAtkTime() <= 2 then
		return
	end

	if nil == self.be_attacked_icon then
		self.be_attacked_icon = BeAttackIcon.New()
		self.be_attacked_icon:SetData(role_id, prof)
		self.be_attakced_update_t = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateBeAttackedIcon, self), 1)

		local view = self.be_attacked_icon:GetView()
		view:setTouchEnabled(true)
		view:addClickEventListener(BindTool.Bind1(self.ClickBeAttackedIconHandler, self))

		view:setPosition(HandleRenderUnit:GetWidth() - 375, 250)
		self.mt_layout_root:EffectLayout():addChild(view)
	end

	if self.be_attacked_icon:GetRoleId() == role_id then
		self.be_attacked_time = Status.NowTime
	end
end

function MainuiSmallParts:RemoveBeAttackedIcon()
	if self.be_attacked_icon then
		self.be_attacked_icon:GetView():removeFromParent()
		self.be_attacked_icon:DeleteMe()
		self.be_attacked_icon = nil
	end
	
	self.remove_attacked_icon_time = Status.NowTime
	if nil ~= self.be_attakced_update_t then
		GlobalTimerQuest:CancelQuest(self.be_attakced_update_t)
		self.be_attakced_update_t = nil
	end
end

function MainuiSmallParts:UpdateBeAttackedIcon()
	if nil == self.be_attacked_icon then return end

	local role_id = self.be_attacked_icon:GetRoleId()
	local target_obj = Scene.Instance:GetObjectByRoleId(role_id)
	if nil == target_obj then 
		self:RemoveBeAttackedIcon()
		return
	end

	if Status.NowTime - self.be_attacked_time > 3 then
		self:RemoveBeAttackedIcon()
		return
	end
end

function MainuiSmallParts:ClickBeAttackedIconHandler()
	local role_id = self.be_attacked_icon:GetRoleId()
	local target_obj = Scene.Instance:GetObjectByRoleId(role_id)

	GlobalTimerQuest:AddDelayTimer(function() self:RemoveBeAttackedIcon() end, 0)

	if nil ~= target_obj then
		local attack_mode = GameEnum.ATTACK_MODE_ALL
		if SceneType.GongChengZhan ~= Scene.Instance:GetSceneType() and SceneType.XianMengzhan ~= Scene.Instance:GetSceneType() then
			if GameEnum.ATTACK_MODE_TEAM == Scene.Instance:GetMainRole():GetVo().attack_mode and
				not SocietyData.Instance:IsTeamMember(role_id) then
				PkCtrl.SendSetAttackMode(GameEnum.ATTACK_MODE_TEAM, 1)
				attack_mode = GameEnum.ATTACK_MODE_TEAM
			elseif GameEnum.ATTACK_MODE_GUILD == Scene.Instance:GetMainRole():GetVo().attack_mode and
				Scene.Instance:GetMainRole():GetAttr(OBJ_ATTR.ACTOR_GUILD_ID) ~= target_obj:GetAttr(OBJ_ATTR.ACTOR_GUILD_ID)
				and Scene.Instance:GetMainRole():GetAttr(OBJ_ATTR.ACTOR_GUILD_ID) ~= 0 then
				PkCtrl.SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD, 1)
				attack_mode = GameEnum.ATTACK_MODE_GUILD
			elseif GameEnum.ATTACK_MODE_CAMP == Scene.Instance:GetMainRole():GetVo().attack_mode and
				Scene.Instance:GetMainRole():GetAttr(OBJ_ATTR.ACTOR_CAMP) ~= target_obj:GetAttr(OBJ_ATTR.ACTOR_CAMP)
				and Scene.Instance:GetMainRole():GetAttr(OBJ_ATTR.ACTOR_CAMP) ~= 0 then
				PkCtrl.SendSetAttackMode(GameEnum.ATTACK_MODE_CAMP, 1)
				attack_mode = GameEnum.ATTACK_MODE_CAMP
			elseif GameEnum.ATTACK_MODE_NAMECOLOR == Scene.Instance:GetMainRole():GetVo().attack_mode and
				EvilColorList.NAME_COLOR_WHITE < target_obj:GetVo().name_color then
				PkCtrl.SendSetAttackMode(GameEnum.ATTACK_MODE_NAMECOLOR, 1)
				attack_mode = GameEnum.ATTACK_MODE_NAMECOLOR
			else
				PkCtrl.SendSetAttackMode(GameEnum.ATTACK_MODE_ALL, 1)
				attack_mode = GameEnum.ATTACK_MODE_ALL
			end
		end
		if attack_mode == Scene.Instance:GetMainRole():GetVo().attack_mode then
			self:DoAttackOnBeAttacked(target_obj)
		else
			GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.DoAttackOnBeAttacked, self, target_obj), 0.3)
		end
	end
end

function MainuiSmallParts:DoAttackOnBeAttacked(target_obj)
	GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, target_obj, "")
end

----------------------------------------------------
-- 被攻击时图标控件
----------------------------------------------------
BeAttackIcon = BeAttackIcon or BaseClass()
function BeAttackIcon:__init()
	self.role_id = role_id
	self.width = 70
	self.height = 70

	self.view = XUI.CreateLayout(0, 0, self.width, self.height)
	self.view:setTouchEnabled(true)

	self.icon_bg = XUI.CreateImageView(self.width / 2, self.height / 2, ResPath.GetCommon("cell_105"), true)
	self.view:addChild(self.icon_bg)

	self.icon = XUI.CreateImageView(self.width / 2, self.height / 2, ResPath.GetCommon("cell_105"), true)
	self.icon:setScale(0.96)
	self.view:addChild(self.icon)

	local be_atked_icon = XUI.CreateImageView(self.width / 2, self.height / 2, ResPath.GetMainui("be_atked_icon"), true)
	local be_atked_icon_scale = 0.5
	be_atked_icon:setScale(be_atked_icon_scale)
	be_atked_icon:setAnchorPoint(0.5, 0.5)
	local icon_size = be_atked_icon:getContentSize()
	be_atked_icon:setPosition(self.width - icon_size.width * be_atked_icon_scale / 2, icon_size.height * be_atked_icon_scale / 2)
	self.view:addChild(be_atked_icon)

	local scale_to1 = cc.ScaleTo:create(0.3, 0.6, 0.6)
	local scale_to2 = cc.ScaleTo:create(0.3, be_atked_icon_scale, be_atked_icon_scale)
	local sequence = cc.Sequence:create(scale_to1, scale_to2)
	local forever = cc.RepeatForever:create(sequence)
	be_atked_icon:runAction(forever)

	local anim_path, anim_name = ResPath.GetEffectAnimPath(3046)
	self.effect = AnimateSprite:create(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	self.effect:setPosition(self.width / 2, self.height / 2)
	self.effect:setScale(1.2)
	self.view:addChild(self.effect, 1000)
end

function BeAttackIcon:__delete()
	AvatarManager.Instance:CancelUpdateAvatar(self.icon)
end

function BeAttackIcon:GetView()
	return self.view
end

function BeAttackIcon:SetData(role_id, prof)
	self.role_id = role_id
	AvatarManager.Instance:UpdateAvatarImg(self.icon, role_id, prof, false)
end

function BeAttackIcon:GetRoleId()
	return self.role_id
end
