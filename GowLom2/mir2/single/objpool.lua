local objpool = {
	objs = {},
	perload = function (class, cnt, ...)
		local objs = objpool.objs[class.__cname]

		if not objs then
			objs = {}
			objpool.objs[class.__cname] = objs
		end

		for i = 1, cnt, 1 do
			local obj = class.new(...)

			obj.retain(obj)
			obj.setNodeEventEnabled(obj, true)

			obj.onCleanup = function ()
				obj:objpool_delegate_cleanup()

				objs[#objs + 1] = obj

				return 
			end
		end

		return 
	end,
	new = function (class, ...)
		local objs = objpool.objs[class.__cname]

		if not objs then
			objs = {}
			objpool.objs[class.__cname] = objs
		end

		local ret = nil

		if 0 < #objs then
			ret = objs[1]

			table.remove(objs, 1)
		else
			ret = class.new()

			ret.retain(ret)
			ret.setNodeEventEnabled(ret, true)

			ret.onCleanup = function ()
				ret:objpool_delegate_cleanup()

				objs[#objs + 1] = ret

				return 
			end
		end

		ret.objpool_delegate_init(slot2, ...)

		return ret
	end,
	clear = function (classname)
		local objs = objpool.objs[classname]

		if objs then
			for i, v in ipairs(objs) do
				v.release(v)
			end

			objpool.objs[classname] = nil
		end

		return 
	end
}

return objpool
