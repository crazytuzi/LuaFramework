------------------------------------------------------------
-- tip
------------------------------------------------------------
BaseTip = BaseTip or BaseClass(BaseView)

BaseTip.WIDTH = 470

function BaseTip:__init()
	self:SetBgOpacity(200)
	self.is_async_load = false
	self.is_any_click_close = true
	self.is_modal = true
	self.zorder = COMMON_CONSTS.ZORDER_ITEM_TIPS
	self.texture_path_list = {}
	self.config_tab = {}
	self.view_cache_time = ViewCacheTime.MOST

	self.fromView = EquipTip.FROM_NORMAL
	self.label_t = Language.Tip.ButtonLabel
	self.handle_param_t = self.handle_param_t or {}

	self.parts_cfg = {}
	self.sub_parts = {}
end

function BaseTip:__delete()
end

function BaseTip:SetPartsCfg(cfg)
	self.parts_cfg = cfg
end


--data = {item_id=100....} 如果背包有的话最好把背包的物品传过来
function BaseTip:SetData(data, fromView, param_t, offsetx, is_show_effect)
	if not data then
		return
	end
	
	if type(data) ~= "table" then
		return
	end

	self.data = data
	self.fromView = fromView or EquipTip.FROM_NORMAL
	self.handle_param_t = param_t or {}
	if "dev" == AgentAdapter:GetSpid() then
		print("[BaseTip]Open tip itemid:", self.data.item_id)
	end

	self:GetViewManager():OpenViewByDef(self:GetViewDef())
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()

	offsetx = offsetx or 0
	self.root_node:setPosition(screen_w / 2 + self.root_node_off_pos.x + offsetx, screen_h / 2 + self.root_node_off_pos.y)
	if not is_show_effect then
		if self.layout1 then
			self.layout1:removeFromParent()
			self.layout1 = nil
		end
		self.painting_img =nil
		self.effect_show1  = nil
		self.display_animate = nil
		self.role_display = nil
		self.bg_display = nil
		self.layout_display = nil
	end
	if is_show_effect then
		self:StopPlay()
		if self.layout1 == nil then
			self.layout1 = XUI.CreateLayout(-380,0,0, 0) 
			self:GetRootNode():addChild(self.layout1, 0)
		end

		if nil == self.painting_img then
			self.painting_img = XUI.CreateImageView(0,-200,ResPath.GetBigPainting("panting_tai_nbg2"),false)
			self.layout1:addChild(self.painting_img, 100)
		end

		if nil == self.effect_show1 then
		 	self.effect_show1 = AnimateSprite:create()
		 	self.effect_show1:setPosition(0, 0)
		 	self.layout1:addChild(self.effect_show1, 999)
		end
		local config = SpecialTipsCfg[self.data.item_id]
		local anim_path = ""
		local anim_name = ""
		local offestX = 0
		
		if config.modleType == 1 then
			anim_path, anim_name =  ResPath.GetWuqiBigAnimPath(config.modleId, SceneObjState.Stand, GameMath.DirDown, sex)
			offestX = 80
		elseif config.modleType == 2 then
			anim_path, anim_name = ResPath.GetRoleBigAnimPath(config.modleId, SceneObjState.Stand, GameMath.DirDown)
			offestX = 0
		elseif config.modleType == 3 then
			anim_path, anim_name = ResPath.GetEffectUiAnimPath(config.modleId)
			offestX = 0
		elseif config.modleType == 4 then
			self:WingEquipShow(config.modleId)
		end	
		if self.effect_show1 then
			self.effect_show1:setPosition((config.offestX or offestX), (config.offestY or 0))
			self.effect_show1:setScale(config.scale or 0.8)
			self.effect_show1:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		end
	end
end

-- 影翼特殊处理
function BaseTip:WingEquipShow(itemid)
	if self.bg_display then
		self.bg_display:stopAllActions()
		self.bg_display:setPosition(0, 270)
	end	

	self.layout_display = XUI.CreateLayout(-30, -80, 350, 300)
	self.layout_display:setClippingEnabled(true)
	self.layout1:addChild(self.layout_display, 10)

	self.bg_display = XUI.CreateImageView(0, 270, ResPath.GetBigPainting("foot_print_scene", true), false)
	self.bg_display:setAnchorPoint(0, 0.5)
	self.bg_display:setScale(1.12)
	self.layout_display:addChild(self.bg_display)

	self.display_animate = AnimateSprite:create()
	self.display_animate:setPosition(30, -70)
	self.display_animate:addEventListener(BindTool.Bind(self.OnAnimateEvent, self))
	self.display_animate:setIsUpdateCallback(true)
	self.layout1:addChild(self.display_animate, 20)

	self.role_display = AnimateSprite:create()
	self.role_display:setPosition(30, -70)
	self.layout1:addChild(self.role_display, 20)

	if itemid then
		local frame_time = FrameTime.Stand
		local anim_path, anim_name = "", ""
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
		if item_cfg.type == ItemData.ItemType.itGenuineQi then
			anim_path, anim_name = ResPath.GetEffectUiAnimPath(itemid)
			self.display_animate:setScale(0.5)
			self.display_animate:setLocalZOrder(21)
			frame_time = FrameTime.Effect
		else
			anim_path, anim_name = ResPath.GetPhantomAnimPath(itemid, "run", 2)
			self.display_animate:setScale(1)
			self.display_animate:setLocalZOrder(19)
			frame_time = FrameTime.Stand
		end
		self.display_animate:setVisible(true)
		self.display_animate:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, frame_time, false)

		local move = cc.MoveBy:create(0.016, cc.p(-2, 0))
		self.bg_display:setPosition(0, 270)
		self.bg_display:stopAllActions()
		self.bg_display:runAction(cc.RepeatForever:create(move))

		anim_path, anim_name = ResPath.GetRoleAnimPath(10, "run", 2)

		self.role_display:setVisible(true)
		self.role_display:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Run, false)
	end
end

function BaseTip:OnAnimateEvent(sender, event_type, frame)
	if event_type == 2 then
		-- self:StopPlay()
	elseif event_type == 1 then
		if self.bg_display:getPositionX() < -1200 then
			self.bg_display:setPositionX(0)
		end
	end
end

function BaseTip:StopPlay()
	if self.layout1 then
		self.layout1:removeFromParent()
		self.layout1 = nil
	end
	self.painting_img =nil
	self.effect_show1  = nil
	self.display_animate = nil
	self.role_display = nil
	self.bg_display = nil
	self.layout_display = nil
end

function BaseTip:ReleaseCallBack()
	--self:StopPlay()
	self.data = nil
	self.fromView = EquipTip.FROM_NORMAL
	self.handle_param_t = {}

	for k, v in pairs(self.sub_parts) do
		v:DeleteMe()
	end
	self.sub_parts = {}

	if self.effect_show1 then
		self.effect_show1:setStop()
		self.effect_show1 = nil
	end

	if self.display_animate then
		self.display_animate:setStop()
		self.display_animate = nil
	end

	if self.role_display then
		self.role_display:setStop()
		self.role_display = nil
	end
	self.layout = nil
	self.layout1 = nil
	self.layout_display = nil

end

function BaseTip:GetOperationLabelByType(fromview)
	for i,v in ipairs(self.sub_parts) do
		if v.GetOperationLabelByType then
			return v:GetOperationLabelByType(fromview)
		end
	end
	return {}
end

function BaseTip:LoadCallBack()
	self.sub_parts = {}
	self.layout = XUI.CreateLayout(0,0,BaseTip.WIDTH, 0) 
	self:GetRootNode():addChild(self.layout, 0)

	for k, v in pairs(self.parts_cfg) do
		local obj = v.New()
		obj:SetRootObj(self)
		self.layout:addChild(obj:GetView(), 20)
		table.insert(self.sub_parts, obj)
	end

	table.sort(self.sub_parts, function(a, b)
		if a:YOrder() > b:YOrder() then
			return true
		end
	end)

	self.bg = XUI.CreateImageViewScale9(0, 0, BaseTip.WIDTH, 0, ResPath.GetBigPainting("tip_bg_1"), false, cc.rect(170,156,40,180))
	self.layout:addChild(self.bg, 0)
	self.bg:setAnchorPoint(0.5, 0)
	self.bg:setPosition(BaseTip.WIDTH / 2, 0)

end

function BaseTip:OpenCallBack()
	AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(AudioEffect.OpenTip), AudioInterval.Common)

	for k, v in pairs(self.sub_parts) do
		if v.OpenCallBack then
			v:OpenCallBack()
		end
	end
end

function BaseTip:CloseCallBack()
	AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(AudioEffect.OpenTip), AudioInterval.Common)

	for k, v in pairs(self.sub_parts) do
		if v.CloseCallBack then
			v:CloseCallBack()
		end
	end
	ViewManager.Instance:CloseViewByDef(ViewDef.SpecialEquipTipShow)
end

local qualitybg2topimg = {
	[8] = "orn_121",
	[9] = "orn_122",
}
local qualitybg2offsx = {
	[8] = -8,
	[9] = 8,
}
local qualitybg2eff = {
	[7] = 1192,
	[8] = 1193,
	[9] = 1194,
}
function BaseTip:ShowIndexCallBack()
	for k, part in pairs(self.sub_parts) do
		part:SetData(self.data, self.fromView, self.handle_param_t)
	end

	-- 从底部开始排
	local now_h = 0
	for i = #self.sub_parts, 1, -1 do
		local part = self.sub_parts[i]
		if not part:IsIgnoreHeight() then
			self.sub_parts[i]:GetView():setPosition(0, now_h)
			now_h = now_h + part:ContentHeight()
		else
			part:AlignSelf()
		end
	end

	local total_height = 0
	for k, v in pairs(self.sub_parts) do
		if not v:IsIgnoreHeight() then
			total_height = total_height + v:ContentHeight()
		end
	end
	
	-- 背景
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	-- local num = math.min(math.max(math.floor(item_cfg.showQuality or 0), 1), 5)
	local img_name = "tip_bg_" .. (item_cfg.showQualityBg or 1)
	local offset_height = 10
	local offset_width = 4
	self.bg:loadTexture(ResPath.GetBigPainting(img_name))
	self.bg:setContentWH(BaseTip.WIDTH + offset_width, total_height + offset_height)
	self.layout:setContentWH(BaseTip.WIDTH, total_height + 4)
	-- self:GetRootNode():setBackGroundColor(COLOR3B.GREEN)


	if qualitybg2topimg[item_cfg.showQualityBg] then
		if nil == self.bg.top_img then
			local top_img = XUI.CreateImageView(0, 0, ResPath.GetCommon(qualitybg2topimg[item_cfg.showQualityBg]), true)
			self.bg:addChild(top_img, 300)
			self.bg.top_img = top_img
		end
		self.bg.top_img:loadTexture(ResPath.GetCommon(qualitybg2topimg[item_cfg.showQualityBg]))
		self.bg.top_img:setPosition((BaseTip.WIDTH + offset_width)/2, (total_height + qualitybg2offsx[item_cfg.showQualityBg]))
	end
	if self.bg.top_img then
		self.bg.top_img:setVisible(qualitybg2topimg[item_cfg.showQualityBg]~=nil)
	end


	if qualitybg2eff[item_cfg.showQualityBg] then
		if nil == self.bg.bg_eff then
		 	self.bg.bg_eff = AnimateSprite:create()
		 	self.bg.bg_eff:setAnchorPoint(0.5, 0.5)
		 	self.layout:addChild(self.bg.bg_eff, 999)
		end
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(qualitybg2eff[item_cfg.showQualityBg])
		self.bg.bg_eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Run, false)
	end
	if self.bg.bg_eff then
		self.bg.bg_eff:setScaleY(total_height / (884 - 160))
		self.bg.bg_eff:setPosition((BaseTip.WIDTH + offset_width)/2 - 6, (total_height) / 2)
		self.bg.bg_eff:setVisible(qualitybg2eff[item_cfg.showQualityBg]~=nil)
		if item_cfg.showQualityBg == 8 then
			self.bg.bg_eff:setPosition((BaseTip.WIDTH + offset_width)/2 - 6, (total_height) / 2 - 6)
		end
	end

	for k, part in pairs(self.sub_parts) do
		if part.TotalhightChange then
			part:TotalhightChange(total_height)
		end
	end
end

function BaseTip:OnFlush(param_t)
end
