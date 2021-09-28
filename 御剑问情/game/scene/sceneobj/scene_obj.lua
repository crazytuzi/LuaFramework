SceneObj = SceneObj or BaseClass()

local SceneObjLayer = GameObject.Find("GameRoot/SceneObjLayer").transform

--基本场景对象
function SceneObj:__init(vo, parent_scene)
	self.obj_type = SceneObjType.Unknown
	self.vo = vo

	self.parent_scene = parent_scene

	self.logic_pos = u3d.vec2(0, 0)
	self.real_pos = u3d.vec2(0, 0)

	self.draw_obj = DrawObj.New(self, SceneObjLayer)
	self.draw_obj:SetIsUseObjPool(true)
	self.draw_obj:SetSceneObj(self)
	self.draw_obj:SetLoadComplete(
		BindTool.Bind(self.OnModelLoaded, self))
	self.draw_obj:SetRemoveCallback(
		BindTool.Bind(self.OnModelRemove, self))
	self.load_priority = 0

	self.follow_ui = nil
	self.is_select = false

	self.quality_node = QualityConfig.ListenQualityChanged(function()
		self:OnQualityChanged()
	end)
end

function SceneObj:__delete()
	if self:IsDeleted() then
		return
	end

	if nil ~= self.follow_ui then
		self.follow_ui:DeleteMe()
		self.follow_ui = nil
	end

	self.parent_scene = nil
	self:DeleteDrawObj()

	if nil ~= self.vo then
		-- if self.vo.target_vo then
		-- 	GameVoManager.Instance:DeleteVo(self.vo.target_vo)
		-- end
		GameVoManager.Instance:DeleteVo(self.vo)
	end

	if self.delay_time then
		GlobalTimerQuest:CancelDelayTimer(self.delay_time)
		self.delay_time = nil
	end

	if self.quality_node ~= nil then
		QualityConfig.UnlistenQualtiy(self.quality_node)
		self.quality_node = nil
	end
end

function SceneObj:DeleteDrawObj()
	if nil ~= self.draw_obj then
		self.draw_obj:DeleteMe()
		self.draw_obj = nil
	end
end

function SceneObj:IsDeleted()
	return self.draw_obj == nil
end

function SceneObj:GetRoot()
	if self.draw_obj ~= nil then
		return self.draw_obj:GetRoot()
	end

	return nil
end

function SceneObj:Init(parent_scene)
	self.parent_scene = parent_scene
	self:InitInfo()
	self:InitShow()
	self:InitEnd()
end

----------------------------------------------------
-- 继承begin
----------------------------------------------------
function SceneObj:InitInfo()
	self:SetLogicPos(self.vo.pos_x, self.vo.pos_y)
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	main_part:SetGameLayer(UnityEngine.LayerMask.NameToLayer("Role"))
end

function SceneObj:InitShow()
	self.draw_obj:SetName(self.vo.name)
	self.draw_obj:SetPosition(self.real_pos.x, self.real_pos.y)
end

function SceneObj:InitEnd()
	self.is_inited = true

	if not self.parent_scene:IsSceneLoading() then
		self:OnEnterScene()
	end
end

function SceneObj:Update(now_time, elapse_time)
end

function SceneObj:OnQualityChanged()
	local quality_level = QualityConfig.QualityLevel
	--判断是否该隐藏阴影
	local part = self.draw_obj and self.draw_obj:GetPart(SceneObjPart.Shadow)
	if nil ~= part then
		local is_show = true
		if self:IsMainRole() and quality_level <= 0 then
			--高品质的不显示图片阴影
			is_show = false
		end
		part:SetVisible(is_show)
	end
end

function SceneObj:OnEnterScene()
	self.draw_obj:GetPart(SceneObjPart.Main):ListenClick(BindTool.Bind(self.OnClicked, self))
end

function SceneObj:IsCharacter()
	return false
end

function SceneObj:IsRole()
	return false
end

function SceneObj:IsEvent()
	return false
end

function SceneObj:IsMainRole()
	return false
end

function SceneObj:IsSpirit()
	return false
end

function SceneObj:IsMonster()
	return false
end

function SceneObj:IsNpc()
	return false
end

function SceneObj:IsGoddess()
	return false
end

function SceneObj:IsLingChong()
	return false
end

function SceneObj:IsSuperBaby()
	return false
end

function SceneObj:IsJumpPoint()
	return false
end

function SceneObj:IsGather()
	return false
end

function SceneObj:IsBaoJu()
	return false
end

function SceneObj:IsTruck()
	return false
end

function SceneObj:IsTrigger()
	return false
end

function SceneObj:IsEffect()
	return false
end

function SceneObj:IsBoat()
	return false
end

function SceneObj:IsFollowObj()
	return false
end

function SceneObj:IsModelTransparent()
	return false
end

function SceneObj:OnClick()
	if SceneObj.select_obj == self then
		return
	end
	if SceneObj.select_obj then
		SceneObj.select_obj:CancelSelect()
		SceneObj.select_obj = nil
	end
	self.is_select = true
	SceneObj.select_obj = self
	if nil ~= self:GetFollowUi() then
		self:GetFollowUi():Show()
	end
end

function SceneObj:UpdateJumppointRotate()
	if not self:IsJumpPoint() then return end
	if self.vo.target_id and self.vo.target_id > 0 then
		local target_point = Scene.Instance:GetObjByTypeAndKey(SceneObjType.JumpPoint, self.vo.target_id)
		if target_point and self.draw_obj then
			self.draw_obj.root.transform:LookAt(target_point:GetRoot().transform)
		end
	end

	local jump_point_list = Scene.Instance:GetObjListByType(SceneObjType.JumpPoint)
	if jump_point_list then
		for k,v in pairs(jump_point_list) do
			if v.vo.target_id == self.vo.id then
				v:UpdateJumppointRotate()
			end
		end
	end
end

function SceneObj:CancelSelect()
	if SceneObj.select_obj == self then
		SceneObj.select_obj = nil
	end
	self.is_select = false
	if self:CanHideFollowUi() and nil ~= self.follow_ui and not self:IsRole() and not self:IsEvent() then
		self:GetFollowUi():Hide()
	end

	if not self:IsMainRole() and Scene.Instance:GetSceneType() == SceneType.HotSpring then
		--温泉场景双修
		GlobalEventSystem:Fire(ObjectEventType.CLICK_SHUANGXIU, self, self.vo, "cancel")
	end
end

function SceneObj:CanHideFollowUi()
	return not self.is_select
end

function SceneObj:CreateFollowUi()
	self.follow_ui = FollowUi.New()
	self.follow_ui:Create()
	if self.draw_obj then
		self.follow_ui:SetFollowTarget(self.draw_obj.root.transform)
	end
end
----------------------------------------------------
-- 继承end
----------------------------------------------------

function SceneObj:GetName()
	return self.vo.name
end

function SceneObj:GetVo()
	return self.vo
end

function SceneObj:GetType()
	return self.obj_type
end

function SceneObj:GetObjId()
	return self.vo.obj_id
end

function SceneObj:GetObjKey()
	return self.vo.obj_id
end

function SceneObj:SetLogicPos(pos_x, pos_y)
	self:SetLogicPosData(pos_x, pos_y)
	self.draw_obj:SetPosition(self.real_pos.x, self.real_pos.y)
end

function SceneObj:SetLogicPosData(pos_x, pos_y)
	self.logic_pos.x, self.logic_pos.y = pos_x, pos_y
	self.real_pos.x, self.real_pos.y = GameMapHelper.LogicToWorld(pos_x, pos_y)
end

function SceneObj:SetRealPos(pos_x, pos_y)
	self.real_pos.x, self.real_pos.y = pos_x, pos_y
	self.logic_pos.x, self.logic_pos.y = GameMapHelper.WorldToLogic(pos_x, pos_y)
end

function SceneObj:GetLogicPos()
	return self.logic_pos.x, self.logic_pos.y
end

function SceneObj:GetRealPos()
	return self.real_pos.x, self.real_pos.y
end

function SceneObj:GetLuaPosition()
	if nil == self.lua_position then
		self.lua_position = {x = 0, y = 0, z = 0}
	end

	if self:GetRoot() then
		local position = self:GetRoot().transform.position
		self.lua_position.x = position.x
		self.lua_position.y = position.y
		self.lua_position.z = position.z
	end

	return self.lua_position
end

function SceneObj:GetDrawObj()
	return self.draw_obj
end

function SceneObj:IsInBlock()
	return AStarFindWay:IsBlock(self.logic_pos.x, self.logic_pos.y)
end

function SceneObj:IsInSafeArea()
	return AStarFindWay:IsInSafeArea(self.logic_pos.x, self.logic_pos.y)
end

function SceneObj:IsWaterWay()
	return AStarFindWay:IsWaterWay(self.logic_pos.x, self.logic_pos.y)
end

function SceneObj:SetDirectionByXY(x, y)
	if nil == self.draw_obj then
		return
	end
	self.draw_obj:SetDirectionByXY(GameMapHelper.LogicToWorld(x, y))
end

function SceneObj:ChangeModel(part, bundle, name, callback)
	if not self.draw_obj or self.draw_obj:IsDeleted() then
		return
	end
	--温泉场景除了人物模型外其他都不显示
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.HotSpring and part ~= SceneObjPart.Main then
		return
	end
	-- 变身卡
	local special_appearance = self.vo.special_appearance
	if special_appearance ~= nil then
		if special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_WORD_EVENT_YURENCARD and part ~= SceneObjPart.Main then
			return
		end
	end

	local part_obj = self.draw_obj:GetPart(part)
	part_obj.load_priority = self.load_priority
	part_obj:ChangeModel(bundle, name, callback)
end

function SceneObj:RemoveModel(part)
	--if part == SceneObjPart.FightMount then
	--end
	if self.draw_obj then
		self.draw_obj:RemoveModel(part)
	end
end

function SceneObj:GetAttr(key)
	return self.vo[key]
end

function SceneObj:SetAttr(key, value)
	self.vo[key] = value
end

function SceneObj:SetObjId(obj_id)
	self.obj_id = obj_id
end

function SceneObj:ReloadUIName()
	if self.follow_ui ~= nil then
		self.follow_ui:SetName(self.vo.name or "", self)
	end
end

function SceneObj:GetFollowUi()
	if nil == self.follow_ui then
		self:CreateFollowUi()
		if nil == self.follow_ui then
			return nil
		end
		self.follow_ui:SetSpecialImage(false)
		self.follow_ui:SetGuildName("")
		self.follow_ui:SetLoverName("")
		self.follow_ui:Hide()
		self:ReloadUIName()
		self:_FlushFollowTarget()
	end

	return self.follow_ui
end

function SceneObj:OnLoadSceneComplete()
	if self:IsDeleted() then
		return
	end

	self.draw_obj:SetPosition(self.real_pos.x, self.real_pos.y)

	if self.is_inited then
		self:OnEnterScene()
	end
end

function SceneObj:OnClicked(param)
	if not self:IsDeleted() then
		GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, self, "scene")
		if DaFuHaoAutoGatherEvent.func then
			DaFuHaoAutoGatherEvent.func(true)
		end
		if DaFuHaoAutoGatherEvent.func then
			DaFuHaoAutoGatherEvent.func(true)
		end
		if not self:IsMainRole() and Scene.Instance:GetSceneType() == SceneType.HotSpring then
			--温泉场景双修
			GlobalEventSystem:Fire(ObjectEventType.CLICK_SHUANGXIU, self, self.vo, "select")
		end
		if not self:IsMainRole() and Scene.Instance:GetSceneType() == SceneType.KfMining then
			--跨服挖矿
			GlobalEventSystem:Fire(ObjectEventType.CLICK_KF_MINING, self)
		end
	end
end

function SceneObj:OnModelLoaded(part, obj)
	if self:IsMainRole() then
		if part == SceneObjPart.Mount then
			local mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
			mount_part:ListenEvent("jump/start", BindTool.Bind(self.OnJumpStart, self))
			mount_part:ListenEvent("jump/end", BindTool.Bind(self.OnJumpEnd, self))
		end
	end

	if part ~= SceneObjPart.Main then
		return
	end

	self:_FlushFollowTarget()

	if self:IsSpirit() then
		self:LoadOver()
	end
end

function SceneObj:OnModelRemove(part, obj)
end

function SceneObj:IsFishing()
	return CrossFishingData.Instance:IsFishing(self.logic_pos.x, self.logic_pos.y)
end

function SceneObj:_FlushFollowTarget()
	if self:IsDeleted() then
		return
	end

	if self:IsModelTransparent() then
		return
	end

	local follow_ui = self.follow_ui
	if nil == follow_ui then
		return
	end

	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	if self.draw_obj:GetObjType() == SceneObjType.Monster then
		if SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_ENEMY) and Scene.Instance:GetSceneLogic():CanShieldMonster() and self:IsCanShield() then
			local fixed_transform = self.draw_obj:GetTransfrom()
			follow_ui:SetFollowTarget(fixed_transform)
		else
			part:RequestAttachment(function(attachment)
				if nil ~= attachment then
					local point = attachment:GetAttachPoint(AttachPoint.UI)
					if point ~= nil and follow_ui ~= nil then
						follow_ui:SetFollowTarget(point)
					end
				end
			end)
		end
	else
		local settingData = SettingData.Instance
		local shield_others = settingData:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
		local shield_friend = settingData:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP)

		if not self:IsMainRole() and (shield_others or (shield_friend and not Scene.Instance:IsEnemy(self))) and self:IsRole() then
			local fixed_transform = self.draw_obj:GetTransfrom()
			follow_ui:SetFollowTarget(fixed_transform)
			follow_ui:SetLocalUI(0, 100, 0)
			follow_ui:Show()
		else
			part:RequestAttachment(function(attachment)
				if nil ~= attachment then
					local point = attachment:GetAttachPoint(AttachPoint.UI)
					if point ~= nil and follow_ui ~= nil then
						if not self.draw_obj:GetObjVisible() then
							follow_ui:SetFollowTarget(self.draw_obj:GetTransfrom())
						else
							follow_ui:SetFollowTarget(point)
						end
						follow_ui:SetLocalUI(0, 0, 0)
						if self:IsGoddess() or self:IsSpirit() then
							if not (shield_others or shield_friend) then
								follow_ui:Show()
							end
						else
							follow_ui:Show()
						end
					end
				end
			end)
		end
	end

	if follow_ui then
		follow_ui:SetNameTextPosition()
		follow_ui:SetHpBarLocalPosition(0, 10, 0)
	end
end

function SceneObj:OnJumpStart()

end

function SceneObj:OnJumpEnd()

end

function SceneObj:CheckWaterArea()

end

-- 是否可以屏蔽
function SceneObj:IsCanShield()
	return true
end

function SceneObj:EnterWater(is_in_water)

end

function SceneObj:GetIsInWater()
	local in_water = false
	if self.draw_obj then
		in_water = self.draw_obj:GetIsInWater()
	end
	return in_water
end