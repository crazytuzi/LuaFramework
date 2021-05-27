MainuiFightStateEffect = MainuiFightStateEffect or BaseClass()
AutoType = {
	None = 0,
	FindPath = 1,
	Guaji = 2,
}


function MainuiFightStateEffect:__init()
	self.mt_layout_root = nil
	self.auto_type = 0
	self.is_close_eff_attack = false
	self.check_huicheng_delay = 10
	self.fly_time = ClientFrameFlyConfig.remind_time
	self.transmit_cd_time = self.fly_time + Status.NowTime
end

function MainuiFightStateEffect:__delete()
	GlobalEventSystem:UnBind(self.guaji_handler)
	GlobalEventSystem:UnBind(self.find_path_handler)
	GlobalEventSystem:UnBind(self.find_path_end_handler)
	GlobalEventSystem:UnBind(self.main_role_be_attack_handler)
	GlobalEventSystem:UnBind(self.system_set_handler)
	--GlobalEventSystem:UnBind(self.huifuyao_handler)

	if ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
		self.itemdata_change_callback = nil
	end

	if RoleData.Instance then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_change)
		self.role_data_change = nil
	end	

	if self.check_huicheng_timer then
		GlobalTimerQuest:CancelQuest(self.check_huicheng_timer)
		self.check_huicheng_timer = nil
	end	

	if self.hero_attr_handler then
		GlobalEventSystem:UnBind(self.hero_attr_handler)
		self.hero_attr_handler = nil
	end	

	if self.map_area_change_handle then
		GlobalEventSystem:UnBind(self.map_area_change_handle)
		self.map_area_change_handle = nil
	end	

	if self.change_map_handler then
		GlobalEventSystem:UnBind(self.change_map_handler)
		self.change_map_handler = nil
	end	
end

function MainuiFightStateEffect:Init(mt_layout_root)
	self.mt_layout_root = mt_layout_root

	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()

	self.be_atk_effect = XUI.CreateImageViewScale9(0,0,screen_w,screen_h,ResPath.GetMainui2(""),true,cc.rect(36,36,50,50))
	self.be_atk_effect:setAnchorPoint(0,0)
	self.be_atk_effect:setVisible(false)
	self.mt_layout_root:TextureLayout():addChild(self.be_atk_effect)

	self.global_x = screen_w * 0.5
	self.global_y = 180

	self.map_desc_txt = XUI.CreateText(self.global_x, self.global_y - 25, screen_w, 0, cc.TEXT_ALIGNMENT_CENTER, "", nil, 28, COLOR3B.ORANGE,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	self.map_desc_txt:enableOutline(cc.c4b(0, 0, 0, 255), 1)
	self.mt_layout_root:TextLayout():addChild(self.map_desc_txt)

	self.auto_fight_effect = AnimateSprite:create()
	self.auto_fight_effect:setPosition(self.global_x-30,self.global_y + 70)
	self.mt_layout_root:TextureLayout():addChild(self.auto_fight_effect)

	self.auto_path_effect = AnimateSprite:create()
	self.auto_path_effect:setPosition(self.global_x-30,self.global_y + 70)
	self.mt_layout_root:TextureLayout():addChild(self.auto_path_effect)

	--自动传送鞋子
	self.fly_shoe = XUI.CreateLayout(self.global_x + 120, self.global_y + 130, 70, 70)
	local img_fly_shoe = XUI.CreateImageView(0, 0, ResPath.GetMainui("fly_shoe"))
	img_fly_shoe:setAnchorPoint(0.5,0.5)
	self.fly_shoe:addChild(img_fly_shoe)
	self.img_fly_effect = AnimateSprite:create()
	self.fly_shoe:addChild(self.img_fly_effect)
	local txet_desc = XUI.CreateText(0, -20, 120, 35, cc.TEXT_ALIGNMENT_CENTER, Language.Common.FreeFly, nil, 20, COLOR3B.GREEN)
	txet_desc:enableOutline(cc.c4b(0, 0, 0, 255), 1)
	txet_desc:setAnchorPoint(0.5,1)
	self.fly_shoe:addChild(txet_desc)
	self.fly_shoe:setVisible(false)

	ClientCommonButtonDic[CommonButtonType.MAINUI_FLYSHOP_BTN] = img_fly_shoe

	self.prompt_frame = XUI.CreateLayout(self.global_x + 150, self.global_y + 70, 70, 70)
	local img_bubble_arrow = XUI.CreateImageView(10,29,ResPath.GetCommon("chat_bubble_desc"),true)
	img_bubble_arrow:setAnchorPoint(0, 1)
	self.prompt_frame:addChild(img_bubble_arrow,100)
	local img9_bubblle_frame = XUI.CreateImageViewScale9(0,65,254,40,ResPath.GetCommon("chat_bubble"),true,cc.rect(5,5,10,10))
	-- XUI.CreateImageViewScale9(0,0,300,40,ResPath.GetGuide("bubble_frame"), true,cc.rect(20,20,20,20))
	img9_bubblle_frame:setAnchorPoint(0,1)
	self.prompt_frame:addChild(img9_bubblle_frame)
	local text_desc_1 = XUI.CreateText(10, 65, 242, 35, cc.TEXT_ALIGNMENT_LEFT, Language.Common.FlyPrompt, nil, 18, COLOR3B.WHITE,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	--XUI.CreateText(0, 65, 200, 35, cc.TEXT_ALIGNMENT_CENTER, Language.Common.FlyPrompt, nil, 18, COLOR3B.WHITE)
	text_desc_1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
	text_desc_1:setAnchorPoint(0,1)
	self.prompt_frame:addChild(text_desc_1, 1, 15)
	self.prompt_frame:setVisible(false)


	self.mt_layout_root:TextureLayout():addChild(self.fly_shoe)
	self.mt_layout_root:TextureLayout():addChild(self.prompt_frame)

	XUI.AddClickEventListener(img_fly_shoe, function()
		if PathActionInfo.task_id ~= nil then
			TaskCtrl.SendQuickFly(FlyType.Task,PathActionInfo.task_id)
		elseif PathActionInfo.tel_id ~= nil then	
			ActivityCtrl.DoTelActionByTelId(PathActionInfo.tel_id)
		end	
	end, true)

	--回城特效
	--[[self.check_huifuyao_image = XUI.CreateImageView(self.global_x - -541,self.global_y + 168,ResPath.GetMainui("item_yaopin_tip_icon"),true)
	self.mt_layout_root:TextureLayout():addChild(self.check_huifuyao_image,3)
	self.check_huifuyao_image:setVisible(false)

	XUI.AddClickEventListener(self.check_huifuyao_image, function()
		ViewManager.Instance:Open(ViewName.Bag)
 		ViewManager.Instance:FlushView(ViewName.Bag, 0, "change_shop")
	end, true)--]]

	self.hero_alive_imge = XUI.CreateImageView(self.global_x - 203,self.global_y + 95,ResPath.GetMainui("hero_alive_icon"),true)
	self.mt_layout_root:TextureLayout():addChild(self.hero_alive_imge)
	self.hero_alive_imge:setVisible(false)

	XUI.AddClickEventListener(self.hero_alive_imge, function()
		local hero_id = ZhanjiangData.Instance:GetAttr("hero_id")
		if hero_id > 0 then
			ZhanjiangCtrl.Instance:SetHeroStateReq(hero_id, HERO_STATE.SHOW)
		end	
	end, true)

	self.guaji_handler = GlobalEventSystem:Bind(OtherEventType.GUAJI_TYPE_CHANGE,BindTool.Bind(self.OnAutoFightChange,self))
	self.find_path_handler = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_PATH,BindTool.Bind(self.OnAutoFightChange,self))
	self.find_path_end_handler = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_MOVE_END,BindTool.Bind(self.OnAutoFightChange,self))
	self.main_role_be_attack_handler = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_BE_ATTACK,BindTool.Bind(self.OnBeAttack,self))
	self.system_set_handler = GlobalEventSystem:Bind(SettingEventType.SYSTEM_SETTING_CHANGE, BindTool.Bind(self.OnSysSettingChange, self))
	--self.huifuyao_handler = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_HUIFUYAO_STATE,BindTool.Bind(self.OnHuiFuYaoEffectChange, self))
	self.itemdata_change_callback = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)

	self.hero_attr_handler = GlobalEventSystem:Bind(HeroDataEvent.HERO_ATTR_CHANGE, BindTool.Bind(self.OnHeroAttrChange,self))
	self.map_area_change_handle = GlobalEventSystem:Bind(SceneEventType.SCENE_AREA_ATTR_CHANGE,BindTool.Bind(self.OnAreaChange,self))
	self.change_map_handler = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.OnChangMap, self))
	self.role_data_change = BindTool.Bind(self.OnRoleAttrChange, self)
	RoleData.Instance:NotifyAttrChange(self.role_data_change)
	self.is_main_role_be_atk = false
end
function MainuiFightStateEffect:InitHuiChengImage(image)
	self.check_huifuyao_image = image
end
function MainuiFightStateEffect:FeameFlushTime()
	local time = self.transmit_cd_time - Status.NowTime
	local remindtime = string.format(Language.Common.FlyPrompt, GameMath.Round(time))
	if time <= 1 then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		if PathActionInfo.task_id ~= nil then
			TaskCtrl.SendQuickFly(FlyType.Task,PathActionInfo.task_id)
		elseif PathActionInfo.tel_id ~= nil then	
			ActivityCtrl.DoTelActionByTelId(PathActionInfo.tel_id)
		end
	end
	local txt = self.prompt_frame:getChildByTag(15)
	if txt then
		txt:setString(remindtime)
	end

end

function MainuiFightStateEffect:OnHeroAttrChange(key, value)
	if key == "state" then
		self:OnAreaChange()
	end	
end	

function MainuiFightStateEffect:OnChangMap()
	local map_cfg = Scene.Instance.client_scene_cfg
	if map_cfg and map_cfg.sceneGuide then
		self.map_desc_txt:setString(map_cfg.sceneGuide)
	else
		self.map_desc_txt:setString("")
	end	

	if ClientSpecialNotShowHuiCheng[Scene.Instance:GetSceneId()] then
		self:OnHuiFuYaoEffectChange(false)
	end
end	

function MainuiFightStateEffect:OnAreaChange()
	if Scene.Instance:IsNotZhaohuanZhanjiang() then
		self:OnHeroStateEffectChange(false)
	else
		if ZhanjiangData.Instance:IsHeroFighting() then
			self:OnHeroStateEffectChange(false)
		elseif ZhanjiangData.Instance:GetAttr("hero_id") > 0 then
			local state = ZhanjiangData.Instance:GetAttr("state")
			if state == HERO_STATE.REST then
				if ZhanjiangData.Instance:GetRestNormalReliveCnt() > 0 then
					--播放
					if not ClientSpecialNotShowHuiCheng[Scene.Instance:GetSceneId()] then
						self:OnHeroStateEffectChange(true)
					end
				end	
			end	
		end	
	end	
end	

function MainuiFightStateEffect:OnRoleAttrChange(key, value, old_value)
	if key == OBJ_ATTR.CREATURE_LEVEL 
		or key == OBJ_ATTR.ACTOR_CIRCLE then
		if not ClientSpecialNotShowHuiCheng[Scene.Instance:GetSceneId()] then
			self:CheckShowHuichengTip()
		end
	end	
end	

function MainuiFightStateEffect:ItemDataChangeCallback(change_type, item_id, item_index, series, reason)
	if ClientSpecialNotShowHuiCheng[Scene.Instance:GetSceneId()] then
		self:OnHuiFuYaoEffectChange(false)
	else
		self:CheckShowHuichengTip()
	end
end	

function MainuiFightStateEffect:CheckShowHuichengTip()
	if not self.check_huicheng_timer then
		self.check_huicheng_timer = GlobalTimerQuest:AddDelayTimer(function()
			local count = ItemData.Instance:GetItemNumInBagById(SettingData.DELIVERY_T[1])
			local main_role = Scene.Instance:GetMainRole()
			self:OnHuiFuYaoEffectChange(count < 1 and not main_role:HasBuffByGroup(BUFF_GROUP.NEW_PLAYER_PROTETED))
			self.check_huicheng_timer = nil
			self.check_huicheng_delay = 1
		 end, self.check_huicheng_delay)
	end	
end	

function MainuiFightStateEffect:OnHeroStateEffectChange(state)
	if not state then
		if self.hero_alive_imge:isVisible() then
			self.hero_alive_imge:setVisible(false)
			self.hero_alive_imge:stopAllActions()
		end	
	else
		if not self.hero_alive_imge:isVisible() then
			self.hero_alive_imge:setVisible(true)
			local fade_out = cc.FadeOut:create(0.49)
			local fade_int = cc.FadeIn:create(0.49)

			local seq = cc.RepeatForever:create(cc.Sequence:create(fade_int,fade_out))
			self.hero_alive_imge:runAction(seq)
		end
	end	
end	

function MainuiFightStateEffect:OnHuiFuYaoEffectChange(state)
	if not state then
		if self.check_huifuyao_image:isVisible() then
			self.check_huifuyao_image:setVisible(false)
			self.check_huifuyao_image:stopAllActions()
		end	
	else
		if not self.check_huifuyao_image:isVisible() then
			self.check_huifuyao_image:setVisible(true)
			local fade_out = cc.FadeOut:create(0.49)
			local fade_int = cc.FadeIn:create(0.49)

			local seq = cc.RepeatForever:create(cc.Sequence:create(fade_int,fade_out))
			self.check_huifuyao_image:runAction(seq)
		end
	end	
end	

function MainuiFightStateEffect:OnSysSettingChange(setting_type, flag)
	if setting_type == SETTING_TYPE.SHIELD_BE_ATTACKED then
		self.is_close_eff_attack = flag
	end	
end	

function MainuiFightStateEffect:OnBeAttack(atker_obj_id)
	local role = Scene.Instance:GetRoleByObjId(atker_obj_id)
	if role and not self.is_close_eff_attack then
		self:DoBeAttackTipEffect(true)
	end	
end	

function MainuiFightStateEffect:DoBeAttackTipEffect(v)
	if self.is_main_role_be_atk ~= v then
		self.is_main_role_be_atk = v
		self.be_atk_effect:setVisible(true)
		self.be_atk_effect:setOpacity(0)

		local fade_out = cc.FadeOut:create(0.5)
		local fade_int = cc.FadeIn:create(0.5)
		local tick = 0
		local call_back = cc.CallFunc:create(
			function()
				tick = tick + 1
				if tick >= 10 then
					self.be_atk_effect:setVisible(false)
					self.be_atk_effect:stopAllActions()
					self.is_main_role_be_atk = false
				end	
			end
			)
		local seq = cc.RepeatForever:create(cc.Sequence:create(fade_int,fade_out,call_back))
		self.be_atk_effect:runAction(seq)
	end	
end	

function MainuiFightStateEffect:OnAutoFightChange()
	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		if main_role:GetIsAutoFight() then
			self:StopAutoFindPathEffect()
			self:PlayAutoGuajiEffect()

		elseif main_role:GetIsPathing() then
			self:StopAutoGuajiEffect()
			self:PlayAutoFindPathEffect()
		else	
			self:StopAutoFindPathEffect()
			self:StopAutoGuajiEffect()
		end	
	end	
end	

function MainuiFightStateEffect:PlayAutoFindPathEffect()
	if self.auto_type ~= AutoType.FindPath then
		self.auto_type = AutoType.FindPath
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(ResPath.AutoFindPath)
		self.auto_path_effect:setAnimate(anim_path,anim_name,COMMON_CONSTS.MAX_LOOPS,FrameTime.Effect,false)
	end
	
	if not self.fly_shoe:isVisible() and (PathActionInfo.task_id ~= nil or PathActionInfo.tel_id ~= nil) then
		if not ClientTaskFlyNotShowCfg[PathActionInfo.task_id] then
			self.fly_shoe:setVisible(true)
			-- self.prompt_frame:setVisible(true)
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(36)
			self.img_fly_effect:setAnimate(anim_path,anim_name,COMMON_CONSTS.MAX_LOOPS,FrameTime.Effect,false)

			local guide = GuideData.Instance:GetTaskFlyCfg()
			if guide.task_id[PathActionInfo.task_id] then
				local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)		-- 人物等级
				if role_level < guide.level then
					self.transmit_cd_time = self.fly_time + Status.NowTime
					self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FeameFlushTime, self, -1),  1)
					self:FeameFlushTime()
					self.prompt_frame:setVisible(true)
				else
					self.prompt_frame:setVisible(false)
					if self.timer then
						GlobalTimerQuest:CancelQuest(self.timer)
						self.timer = nil
					end
				end
			end	
		end
	elseif self.fly_shoe:isVisible() and PathActionInfo.task_id == nil then	
		self.fly_shoe:setVisible(false)
		self.prompt_frame:setVisible(false)
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		self.img_fly_effect:setStop()
	end
end

function MainuiFightStateEffect:StopAutoFindPathEffect()
	if self.auto_type == AutoType.FindPath then
		self.auto_type = AutoType.None
		self.auto_path_effect:setStop()
		if self.fly_shoe:isVisible() then
			self.fly_shoe:setVisible(false)
			self.img_fly_effect:setStop()
		end

		if self.prompt_frame:isVisible() then
			self.prompt_frame:setVisible(false)
			if self.timer then
				GlobalTimerQuest:CancelQuest(self.timer)
				self.timer = nil
			end
		end
	end
end

function MainuiFightStateEffect:PlayAutoGuajiEffect()
	if self.auto_type ~= AutoType.Guaji then
		self.auto_type = AutoType.Guaji
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(ResPath.AutoGuaji)
		self.auto_fight_effect:setAnimate(anim_path,anim_name,COMMON_CONSTS.MAX_LOOPS,FrameTime.Effect,false)
	end
end

function MainuiFightStateEffect:StopAutoGuajiEffect()
	if self.auto_type == AutoType.Guaji then
		self.auto_type = AutoType.None
		self.auto_fight_effect:setStop()
	end
end

