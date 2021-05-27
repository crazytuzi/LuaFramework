
-----------------------------------------------------
-- NumberBar 根据数字创建sprite
-----------------------------------------------------

NumberBar = NumberBar or BaseClass(BaseRender)

NumberBarGravity = {
	Left = 0,
	Center = 1,
	Right = 2,
}

function NumberBar:__init()
	self.number_bar = nil
	self.root_path = ""
	self.gravity = NumberBarGravity.Left			-- 对齐方式
	self.space = 0									-- 字间距
	self.has_plus = false							-- 是否有加号
	self.has_minus = true							-- 是否有减号
	self.is_grey = false
	self.img_list = {}
	self.num_list = nil
end

function NumberBar:__delete()

end

function NumberBar:Create(x, y, w, h, path)
	self:SetPosition(x, y)
	self:SetContentSize(w, h)
	self:SetRootPath(path)
end

-- 设置根路径
function NumberBar:SetRootPath(path)
	self.root_path = string.gsub(path, ".png", "")
end

-- 设置根路径
function NumberBar:SetRootPathEx(path)
	self.root_path = path
end

-- 设置数字
function NumberBar:SetNumber(number)
	self.num_list = nil
	self:SetData(number)
end

-- 设置数字
function NumberBar:SetNumberList(number_t)
	self.num_list = number_t
	self:Flush()
end

-- 设置对齐方式
function NumberBar:SetGravity(gravity)
	self.gravity = gravity
end

-- 设置字间距
function NumberBar:SetSpace(space)
	self.space = space
end

-- 设置是否有加号
function NumberBar:SetHasPlus(has_plus)
	self.has_plus = has_plus
end

-- 设置是否有加号
function NumberBar:SetHasMinus(has_minus)
	self.has_minus = has_minus
end

-- 	设置是否变灰
function NumberBar:SetGrey(is_grey)
	self.is_grey = is_grey
	for k, v in pairs(self.img_list) do
		v:setGrey(is_grey)
	end
end

-- 刷新
function NumberBar:OnFlush()
	if nil == self.data and nil == self.num_list then
		self.view:removeAllChildren()
		self.img_list = {}
	else
		self:FlushImg()
	end
end

function NumberBar:FlushImg()
	if "" == self.root_path then
		return
	end

	if nil == self.number_bar then
		self.number_bar = XLayout:create()
		self.view:addChild(self.number_bar)
	end

	local num_list = self.num_list or self:NumberToList(self.data)

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
			if img.removeFromParent then
				img:removeFromParent()
			end
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

function NumberBar:SetContentSize(w, h)
	BaseRender.SetContentSize(self, w, h)
	self:UpdateBarPos()
end

function NumberBar:UpdateBarPos()
	if nil == self.number_bar then
		return
	end

	if NumberBarGravity.Left == self.gravity then
		self.number_bar:setAnchorPoint(0, 0)
		self.number_bar:setPositionX(0)
	elseif NumberBarGravity.Center == self.gravity then
		self.number_bar:setAnchorPoint(0.5, 0)
		self.number_bar:setPositionX(self.view:getContentSize().width / 2)
	else
		self.number_bar:setAnchorPoint(1.0, 0)
		self.number_bar:setPositionX(self.view:getContentSize().width)
	end
end

-- 数字转list
function NumberBar:NumberToList(number)
	local num_list = {}
	local is_minus = false

	if number < 0 then
		number = -number
		is_minus = true
	end

	number = math.floor(number)
	for i = 1, 20 do
		table.insert(num_list, 1, number % 10)
		number = math.floor(number / 10)
		if number <= 0 then
			break
		end
	end

	if is_minus then
		if self.has_minus then
			table.insert(num_list, 1, "minus")
		end
	else
		if self.has_plus then
			table.insert(num_list, 1, "plus")
		end
	end
	return num_list
end

function NumberBar:SetVisible(value)
	if self.number_bar then
		self.number_bar:setVisible(value)
	end
end

function NumberBar:SetScale(value)
	if self.number_bar then
		self.number_bar:setScale(value)
	end
end
function NumberBar:GetNumberBar()
	return self.number_bar
end
