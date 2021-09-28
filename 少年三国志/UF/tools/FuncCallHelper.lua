--FuncCallManager.lua


local FuncCallHelper = class ("FuncCallHelper", function (  )
	return display.newNode()
end)

flag1 = false
flag2 = false
function FuncCallHelper:ctor( parent )
	if parent and parent.addChild then 
		parent:addChild(self)
	else
		uf_notifyLayer:addNode(self)
	end

	self._frameFuncList = {}

	local updateHandler = function (  )
		if #self._frameFuncList < 1 then 
			return nil
		end
		for i, v in pairs(self._frameFuncList) do 
			if v ~= nil and type(v) == "table" and table.getn(v) >= 3 then 
				local frameCount = v[3]
				frameCount = frameCount - 1
				v[3] = frameCount
				if frameCount == 0 then 
					if v[1] ~= nil and v[2] ~= nil then 
						v[2](v[1])
					elseif v[2] ~= nil then 
						v[2]()
					else
						print("else occur!")
					end

					
					table.remove(self._frameFuncList, i)
				end
			end
		end

	end

	self:scheduleUpdate(updateHandler, 0)
end

function FuncCallHelper:clearCallHelper( )
	self._frameFuncList = {}
end

function FuncCallHelper:callNextFrame( fun, target )
	if fun == nil then 
		return nil
	end 

	count = #self._frameFuncList
	table.insert(self._frameFuncList, count + 1, {target, fun, 1})
end

function FuncCallHelper:callAfterFrameCount( frame, fun, target )
	if fun == nil then 
		return nil
	end

	count = #self._frameFuncList
	table.insert(self._frameFuncList, count + 1, {target, fun, frame or 20})
end

function FuncCallHelper:callAfterDelayTime( delay, args, fun, target )
	if delay <= 0 or fun == nil then 
		return false
	end

	local array = CCArray:create()
	array:addObject(CCDelayTime:create(delay))
	array:addObject(CCCallFunc:create(function (  )
		if fun ~= nil and target ~= nil then
			fun(target, args)
		elseif fun ~= nil then
			fun(args)
		end
	end))

	self:runAction(CCSequence:create(array))
end

function FuncCallHelper:callAfterDelayTimeOnObj(obj, delay, args, fun, target )
	if obj == nil or delay <= 0 or fun == nil then 
		return false
	end

	local array = CCArray:create()
	array:addObject(CCDelayTime:create(delay))
	array:addObject(CCCallFunc:create(function (  )
		if fun ~= nil and target ~= nil then
			fun(target, args)
		elseif fun ~= nil then
			fun(args)
		end
	end))

	obj:runAction(CCSequence:create(array))
end

function FuncCallHelper:getCurrentTime(  )
	return FuncHelperUtil:getCurrentTime()
end


return FuncCallHelper