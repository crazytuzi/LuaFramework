--使用逐张图片显示的动画控件
SingleAnimateSprite = SingleAnimateSprite or BaseClass(BaseRender)
function SingleAnimateSprite:__init()
	self.interval = 0.05
	self.next_update_time = 0
	self.start_index = 1
	self.end_index = 1
	self.current_index = 1
	self.max_loop = 1
	self.loop = 0
	self.id = 1
	self.is_delete = false
end	

function SingleAnimateSprite:__delete()
	self.is_delete = true
	Runner.Instance:RemoveRunObj(self)
end	

function SingleAnimateSprite:SetAnimate(id,start_index,end_index,max_loop,interval)
	if self.is_delete then
		return
	end	

	self.loop = 0
	self.id = id
	self.max_loop = max_loop
	self.start_index = start_index
	self.end_index = end_index
	self.current_index = start_index
	self.interval = interval

	if not self.effect_img then
		self.effect_img = XUI.CreateImageView(0, 0)
		self.view:addChild(self.effect_img)
	end	
	self.effect_img:loadTexture(ResPath.GetSingleAnimate(self.id,self.current_index))

	Runner.Instance:AddRunObj(self)
end	

function SingleAnimateSprite:Update(now_time, elapse_time)
	if now_time > self.next_update_time then
		self.next_update_time = now_time + self.interval
		if self.current_index > self.end_index then
			self.current_index = self.start_index
			self.loop = self.loop + 1
			if self.loop > self.max_loop then
				Runner.Instance:RemoveRunObj(self)
				return
			end
		end	

		if self.effect_img then
			self.effect_img:loadTexture(ResPath.GetSingleAnimate(self.id,self.current_index))
		end	

		self.current_index = self.current_index + 1
	end	
end	