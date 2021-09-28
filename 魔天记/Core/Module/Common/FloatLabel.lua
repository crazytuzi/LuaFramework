
FloatLabel = class("FloatLabel")
local insert = table.insert
local remove = table.remove
local _height = 50
local _floatTime = 0.4
function FloatLabel:New()
	local o = {};
	setmetatable(o, self);
	self.__index = self;
	return o;
end

--parent：文本父级  path:文本路径 time:文本的消失时间
function FloatLabel:Init(parent, path, time)
	self:_Init(parent, path, time)	
end

function FloatLabel:_Init(parent, path, time)
	self._isDispose = false
	self._parent = parent
	self._path = path
	self._time = time or _floatTime
	self._pool1 = {}
	self._pool2 = {}
end
local zero = Vector3.zero
--numer 飘的文本的内容 ,height 文本飘的高度(本地坐标)
function FloatLabel:Play(number, height)
	height = height or _height	
	if(self._isDispose) then return end
	local item = self:GetPool()
	if(item == nil) then
		item = {}
		item.go = UIUtil.GetUIGameObject(ResID.UI_ADDTXT)	
		
		if(item.go) then
			item.txt = UIUtil.GetComponent(item.go, "UILabel")
			item.trs = item.go.transform
			UIUtil.AddChild(self._parent, item.trs);
		end
	else
		Util.SetLocalPos(item.trs, zero)	
		item.go:SetActive(true)
	end
	item.time = 0
	item.height = height
	if(item.txt) then
		item.txt.text = tostring(number)
	end
	
	if(item.go) then
		insert(self._pool1, item)
	end
	if(self._timer == nil) then
		self._timer = Timer.New(function() self:Update(time) end, 0, - 1, false)
		self._timer:Start()	
	end
	
	self._timer:Pause(false)
end

function FloatLabel:GetPool()
	local item = self._pool2[1]
	if(item) then		
		table.remove(self._pool2, 1)
		return item
	end
end

function FloatLabel:Stop()
	
end

function FloatLabel:Dispose()
	self._isDispose = true
	self:_Dispose()
end

function FloatLabel:Update(time)
	if(self._isDispose) then return end
	if(table.getCount(self._pool1) > 0) then
		for i = table.getCount(self._pool1), 1, - 1 do
			self._pool1[i].time = self._pool1[i].time + Timer.deltaTime
			
			if(self._pool1[i].time >= self._time) then
				self._pool1[i].go:SetActive(false)
				local item = self._pool1[i]
				insert(self._pool2, item)
				remove(self._pool1, i)
			else
				local position = self._pool1[i].trs.localPosition
				position.y = math.lerp(position.y, self._pool1[i].height, self._pool1[i].time / self._time)
				Util.SetLocalPos(self._pool1[i].trs, position)				
			end
		end
		
		if(table.getCount(self._pool1) == 0) then
			self._timer:Pause(true)			
		end	
	end
end


function FloatLabel:_Dispose()
	if(self._timer) then
		self._timer:Stop()
		self._timer = nil
	end	
	
	self._parent = nil
	for k, v in ipairs(self._pool1) do
		if(v.go) then
			Resourcer.Recycle(v.go)
		end
	end
	
	for k, v in ipairs(self._pool2) do
		if(v.go) then
			Resourcer.Recycle(v.go)
		end
	end
	
	for k, v in pairs(self) do
		self[k] = nil
	end
end
