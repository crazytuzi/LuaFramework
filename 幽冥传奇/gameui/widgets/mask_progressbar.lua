MaskProgressBar = MaskProgressBar or BaseClass()

function MaskProgressBar:__init(parent,bg_node,stencil_node,cc_size,is_flippedY,percent_change_func)
	self.parent = parent
	self.clip_node = cc.ClippingNode:create()
	self.clip_node:setContentSize(cc_size.width,cc_size.height)
	self.clip_node:setAnchorPoint(0,0)
	self.clip_node:setAlphaThreshold(0)
	self.self_bg = bg_node
	self.clip_node:addChild(bg_node)
	self.self_bg:setAnchorPoint(0,0)
	self.self_stencil = stencil_node
	self.self_stencil:setAnchorPoint(0,0)
	self.is_flippedY = is_flippedY
	self.percent = 0
	self.target_percent = 0
	self.target_time = 0
	if is_flippedY then
		self.self_stencil:setPositionY(cc_size.height)
		self.self_stencil:setScaleY(-1)
	end
	self.clip_node:setStencil(stencil_node)
	self.parent:addChild(self.clip_node,100)
	self.percent_change_func = percent_change_func
end

function MaskProgressBar:__delete()
	Runner.Instance:RemoveRunObj(self)
end	

function MaskProgressBar:resize(cc_size)
	self.clip_node:setContentSize(cc_size.width,cc_size.height)
	if self.is_flippedY then
		self.self_stencil:setPositionY(cc_size.height)
		self.self_stencil:setScaleY(-1)
	end	
end	

function MaskProgressBar:Update(now_time, elapse_time)
	if now_time >= self.target_time then
		Runner.Instance:RemoveRunObj(self)
		if self.target_percent > 1 then
			self.percent = self.target_percent % 1.00000000001
			self.target_percent = self.percent
		else
			self.percent = self.target_percent
		end	
		local size = self.clip_node:getContentSize()
		self.self_stencil:setContentWH(size.width,size.height * self.percent)	
		if self.percent_change_func then
			self.percent_change_func(size.height * self.percent)
		end
	else
		local size = self.clip_node:getContentSize()
		local scale = 1 - (self.target_time - now_time)
		local temp_space = 0
		if self.space_percent > 1 then
			temp_space = (self.space_percent * scale) % 1.00000000001
		else
			temp_space = (self.space_percent * scale)
		end	 
		self.self_stencil:setContentWH(size.width,size.height * (self.percent + temp_space))
	
		if self.percent_change_func then
			self.percent_change_func(size.height * (self.percent + temp_space))
		end
	end	
end	

function MaskProgressBar:setBg(bg_node)
	if self.self_bg then
		self.self_bg:removeFromParent()
	end	

	self.self_bg = bg_node
	self.clip_node:addChild(bg_node)
	self.self_bg:setAnchorPoint(0,0)
end	

function MaskProgressBar:getView()
	return self.clip_node
end	

function MaskProgressBar:GetView()
	return self.clip_node
end	

function MaskProgressBar:GetTargetPercent()
	return self.target_percent
end	

function MaskProgressBar:setProgressPercent(percent,is_animate)
	is_animate = is_animate or false
	if percent ~= self.target_percent then
		self.target_percent = percent
		if self.percent ~= self.target_percent  then
			self.space_percent = self.target_percent - self.percent
			if is_animate then
				self.target_time = Status.NowTime + 1
			else
				self.target_time = Status.NowTime + 0.0001
			end	
			Runner.Instance:RemoveRunObj(self)
			Runner.Instance:AddRunObj(self, 8)
		end	
	end
end	

	-- local hp_bar_bg_node = XUI.CreateLayout(0,0,50,100)
	-- local hp_effect = AnimateSprite:create()
	-- local ani_path,ani_name = ResPath.GetEffectUiAnimPath(31)
	-- hp_effect:setAnimate(ani_path,ani_name,COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	-- hp_effect:setPosition(50,50)
	-- hp_effect:setScale(0.95)
	-- hp_bar_bg_node:addChild(hp_effect)

	-- self.hp_bar = MaskProgressBar.New(hp_mp_container,hp_bar_bg_node,
	--  								XUI.CreateImageViewScale9(0,0,50,100,ResPath.GetCommon("img9_138"), true,cc.rect(5,5,10,10)),
	--  								cc.size(50,100))
	-- self.hp_bar:getView():setPositionX(-50)