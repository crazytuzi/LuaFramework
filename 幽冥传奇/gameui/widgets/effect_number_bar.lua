--带特效的数字显示
EffectNumberBar = EffectNumberBar or BaseClass(NumberBar)
EffectNumberBarActionType = 
{
	TARGET_ADD = 1,--当期向目标递进变更
	EVERY_ROT = 2, --数字滚动，从左往右逐个停止
}
function EffectNumberBar:__init()
	self.action_time = 0
	self.start_time = 0
	self.end_time = 0
	self.action_type = 1
	self.src_num = 0
	self.tar_num = 0
	self.interval = 0.1
	self.total_keep_time = 0
	self.compelte_callback = nil
end	

function EffectNumberBar:__delete()
	Runner.Instance:RemoveRunObj(self)
end	

function EffectNumberBar:SetInterval(interval)
	self.interval = interval
end	

function EffectNumberBar:SetEffectNumber(effect_type,src_num,tar_num,time,validate_bit,dir)
	self.action_type = effect_type
	self.start_time = Status.NowTime
	self.end_time = Status.NowTime + time
	self.total_keep_time = time
	self.src_num = src_num
	self.tar_num = tar_num
	self.validate_bit = validate_bit or 0 --有效的数位
	self.dir = dir or 1
	self:Flush()
end	

function EffectNumberBar:OnFlush()
	if "" == self.root_path then
		return
	end

	if nil == self.number_bar then
		self.number_bar = XLayout:create()
		self.view:addChild(self.number_bar)
	end


	if self.action_type == EffectNumberBarActionType.EVERY_ROT then	
		self.tar_num_str = tostring(self.tar_num)
		self.str_len = string.len(self.tar_num_str)
		
		self.random_num_str = {}
		self.tar_num_list = {}
			

		if self.validate_bit < self.str_len then
			self.validate_bit = self.str_len
		end	
		for i = 1, self.str_len do
			self.random_num_str[i] = math.random(0,9)
			self.tar_num_list[i] = string.byte(self.tar_num_str,i) - 48
		end	

		for i = self.validate_bit - self.str_len, 1 , -1 do
			table.insert(self.random_num_str,1,0)
			table.insert(self.tar_num_list,1,0)
		end	

		if self.dir == 1 then
			self.update_total = 1
		else
			self.update_total = self.validate_bit
		end

		self.update_space = self.total_keep_time / self.validate_bit
		self.action_time = Status.NowTime + self.update_space
	end	

	Runner.Instance:AddRunObj(self)
end	

function EffectNumberBar:Update(now_time, elapse_time)
	if self.action_type == EffectNumberBarActionType.TARGET_ADD then
		self:UpdateTargetAdd(now_time)
	elseif self.action_type == EffectNumberBarActionType.EVERY_ROT then	
		self:UpdateEveryRot(now_time)
	end	
end	

function EffectNumberBar:SetCompleteCallBack(fun)
	self.compelte_callback = fun
end	

function EffectNumberBar:UpdateNumberBar(list)
	local num_list = list

	local num_count = #num_list
	local img_count = #self.img_list

	local img = nil

	-- 不够则创建，多则删除
	if num_count > img_count then
		for i = 1, num_count - img_count do
			img = XImage:create()
			img:setAnchorPoint(0, 0)
			if self.is_grey then
				img:setGrey(true)
			end
			self.number_bar:addChild(img)
			table.insert(self.img_list, img)
		end
	elseif num_count < img_count then
		for i = 1, img_count - num_count do
			img = table.remove(self.img_list)
			img:removeFromParent()
		end
	end

	local offset_x = 0
	local size, max_height = nil, 0
	for i, v in ipairs(num_list) do
		img = self.img_list[i]
		img:loadTexture(self.root_path .. v .. ".png")
		img:setPositionX(offset_x)

		size = img:getContentSize()
		offset_x = offset_x + size.width + self.space
		if size.height > max_height then
			max_height = size.height
		end
	end

	self.number_bar:setContentWH(offset_x, self.view:getContentSize().height)

	self:UpdateBarPos()
end	

function EffectNumberBar:UpdateBarAction(time_space)
	local t = time_space / self.total_keep_time
	local number = self.src_num + (self.tar_num - self.src_num) * t
	self:UpdateNumberBar(self:NumberToList(number))
end	

function EffectNumberBar:UpdateTargetAdd(now_time)
	if now_time < self.end_time then
		if now_time > self.action_time then
			self.action_time = now_time + self.interval
			--更新动画
			self:UpdateBarAction(now_time - self.start_time)
		end	
	else
		self:UpdateNumberBar(self:NumberToList(self.tar_num))
		Runner.Instance:RemoveRunObj(self)
		if self.compelte_callback then
			self.compelte_callback()
		end	
		--动画结束
	end	
end	


function EffectNumberBar:UpdateEveryRot(now_time)
	if self.update_total <= self.validate_bit then
		for i = self.update_total, self.validate_bit do
			local num = self.random_num_str[i]
			num = num + 1
			if num > 9 then
				num = 0
			end	
			self.random_num_str[i] = num
		end	
		self:UpdateNumberBar(self.random_num_str)
		if now_time >= self.action_time then
			self.action_time = Status.NowTime + self.update_space
			self.random_num_str[self.update_total] = self.tar_num_list[self.update_total]
			self.update_total = self.update_total + 1
		end	
	else	
		self:UpdateNumberBar(self.tar_num_list)
		Runner.Instance:RemoveRunObj(self)
		if self.compelte_callback then
			self.compelte_callback()
		end	
		--动画结束
	end	
end	