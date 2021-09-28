--子弹
Bullet = Bullet or BaseClass()

function Bullet:__init()
	self.start_pos_tbl = nil
	self.local_rotation = nil
	self.parent = nil
	self.obj = nil
	self.can_lanch = false
	self.is_load = false
	self.range_x = 0
	self.range_y = 0

	self.position_change_list = {}

	self.elapse_time = 0.02				--固定1次update时间

	Runner.Instance:AddRunObj(self, 8)
end

function Bullet:__delete()
	self.start_pos_tbl = nil
	self.local_rotation = nil
	self.parent = nil
	if self.obj then
		GameObjectPool.Instance:Free(self.obj)
	end
	self.obj = nil
	self.can_lanch = false
	self.is_load = false
	self.range_x = 0
	self.range_y = 0

	self.delete_call_back = nil
	self.touch_call_back = nil

	for k, v in ipairs(self.position_change_list) do
		v(99999, 99999)
	end
	self.position_change_list = {}

	Runner.Instance:RemoveRunObj(self)
end

function Bullet:GetObj()
	return self.obj
end

function Bullet:SetBulletAssetBundle(bundle, asset)
	self.bundle = bundle
	self.asset = asset
end

function Bullet:SetParent(parent)
	self.parent = parent
end

--设置范围（超出范围后回收）
function Bullet:SetRange(range_x, range_y)
	self.range_x = range_x
	self.range_y = range_y
end

--创建一个子弹资源
function Bullet:CreateBulletObj()
	self.bundle = self.bundle or "uis/views/yuleview_prefab"
	self.asset = self.asset or "Bullet01"
	GameObjectPool.Instance:SpawnAsset(self.bundle, self.asset, function(obj)
		if not obj then
			return
		end

		if self.obj then
			GameObjectPool.Instance:Free(self.obj)
		end
		self.obj = nil

		self.obj = obj

		if self.parent then
			self.obj.transform:SetParent(self.parent)
		end

		self.obj.transform.localScale = Vector3(1, 1, 1)

		if self.local_rotation then
			self.obj.transform.localRotation = self.local_rotation
		end

		if self.start_pos_tbl then
			self.obj.transform.localPosition = Vector3(self.start_pos_tbl.x, self.start_pos_tbl.y, 0)
		end

		local listen_trigger = self.obj:GetComponent(typeof(ListenTrigger))
		listen_trigger.triggerenter = BindTool.Bind(self.TriggerEnterChange, self)

		self.is_load = true
	end)
end

function Bullet:TriggerEnterChange(obj)
	if nil == self.obj then
		return
	end
	local local_position = self.obj.transform.localPosition
	--超出屏幕外就不处理碰撞
	if math.abs(local_position.x) > self.range_x or math.abs(local_position.y) > self.range_y then
		return
	end
	if self.touch_call_back then
		self.touch_call_back(self, obj)
	end
end

function Bullet:SetStartPosTbl(pos_tbl)
	self.start_pos_tbl = pos_tbl
end

function Bullet:SetLocalRotation(rotation)
	self.local_rotation = rotation
end

function Bullet:SetDeleteCallBack(call_back)
	self.delete_call_back = call_back
end

function Bullet:SetTouchCallBack(call_back)
	self.touch_call_back = call_back
end

function Bullet:AddPositionChangeListen(call_back)
	table.insert(self.position_change_list, call_back)
end

function Bullet:GetPosition()
	return self.obj.transform.position
end

function Bullet:Update(now_time, elapse_time)
	local diff_elapse_time = elapse_time - self.elapse_time
	if not self.is_load then
		return
	end
	local local_position = self.obj.transform.localPosition
	

	--超出屏幕外
	if math.abs(local_position.x) > self.range_x or math.abs(local_position.y) > self.range_y then
		--给一个尽量大的值
		for k, v in ipairs(self.position_change_list) do
			v(99999, 99999)
		end
	else
		for k, v in ipairs(self.position_change_list) do
			v(local_position.x, local_position.y)
		end
	end

	--加一个偏移值时为了拖尾效果不会马上消失
	if math.abs(local_position.x) >= self.range_x + 100 or math.abs(local_position.y) >= self.range_y + 100 then
		if self.delete_call_back then
			self.delete_call_back(self)
		end
		--没打到鱼
		local uid = FishingData.Instance:GetNowFishPondUid()
		local now_fish_list = FishingData.Instance:GetNowFishList()
		if nil == now_fish_list then
			return
		end
		YuLeCtrl.Instance:SendFishPoolStealFish(uid, now_fish_list.is_fake_pool, now_fish_list.fish_quality, FISH_TYPE.NOT_FISH)
		return
	end
	local speed = 2.5 + (diff_elapse_time/self.elapse_time) * 2.5
	self.obj.transform:Translate(0, speed, 0)
end