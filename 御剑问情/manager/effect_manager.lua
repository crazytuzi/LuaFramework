EffectManager = EffectManager or BaseClass()

function EffectManager:__init()
	if EffectManager.Instance then
		print_error("EffectManager to create singleton twice")
	end
	EffectManager.Instance = self
end

function EffectManager:__delete()
	self.Instance = nil
end

function EffectManager:PlayAtTransform(bundle, asset, transform, duration, position, rotation, scale)
	GameObjectPool.Instance:SpawnAsset(bundle, asset, function(obj)
		if nil == obj then
			print_warning("obj not exist", bundle, asset)
			return
		end

		if transform == nil or IsNil(transform) then
			GameObjectPool.Instance:Free(obj)
			return
		end

		local canvas = transform:GetComponentInParent(typeof(UnityEngine.Canvas))
		if canvas == nil then
			GameObjectPool.Instance:Free(obj)
			print_error("PlayAtTransform transform is not in a canvas.")
			return
		end

		obj.transform:SetParent(transform, false)
		if position ~= nil then
			obj.transform.position = position
		end

		if rotation ~= nil then
			obj.transform.rotation = rotation
		end

		if scale ~= nil then
			obj.transform.localScale = scale
		end

		local sorting_order = obj:GetOrAddComponent(typeof(SortingOrderOverrider))
		sorting_order.SortingOrder = canvas.sortingOrder + 3

		GlobalTimerQuest:AddDelayTimer(function()
			GameObjectPool.Instance:Free(obj)
		end, duration)
	end)
end

function EffectManager:PlayAtTransformCenter(bundle, asset, transform, duration)
	self:PlayAtTransform(bundle, asset, transform, duration, transform:GetWorldCenter())
end

-- 播放带有EffectControl的特效
function EffectManager:PlayControlEffect(bundle, asset, position, deliverer_position, transform, scale)
	GameObjectPool.Instance:SpawnAsset(bundle, asset, function(obj)
		if nil == obj then
			print_warning("obj not exist", bundle, asset)
			return
		end

		-- 使用第五个参数transform的话就可以把特效放在指定的transform上播放，否则只能放在坐标位置
		if transform ~= nil then
			obj.transform:SetParent(transform, false)
		end

		obj.transform.position = position

		if deliverer_position then
			local direction = position - deliverer_position
            direction.y = 0;
            obj.transform:SetPositionAndRotation(
                    position, Quaternion.LookRotation(direction));
		end

		if scale then
			obj.transform:SetLocalScale(scale, scale, scale)
		end

		local control = obj:GetOrAddComponent(typeof(EffectControl))
		if control == nil then
			GameObjectPool.Instance:Free(obj)
			print_warning("PlayControlEffect not exist EffectControl")
			return
		end

		control:Reset()
		control.FinishEvent = control.FinishEvent + function()
			GameObjectPool.Instance:Free(obj)
		end

		control:Play()
	end)
end