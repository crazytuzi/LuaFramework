local eventDispatcher = {
	events_ = {},
	addListener = function (self, msg, listener, callback)
		if self.events_[msg] == nil then
			self.events_[msg] = {}
		end

		self.events_[msg][#self.events_[msg] + 1] = {
			listener,
			callback
		}

		if not listener.isAutoRelease then
			local curOnExit = listener.onExit
			listener.onExit = function (node)
				if curOnExit then
					curOnExit(node)
				end

				self:removeListener(node)

				return 
			end

			listener.setNodeEventEnabled(slot2, true)

			listener.isAutoRelease = true
		end

		return 
	end,
	dispatch = function (self, msg, params, ...)
		if self.events_[msg] then
			for k, v in pairs(self.events_[msg]) do
				v[2](v[1], params, ...)
			end
		end

		return 
	end,
	removeListener = function (self, listener)
		for k, v in pairs(self.events_) do
			for k2, v2 in pairs(v) do
				if v2[1] == listener then
					v[k2] = nil

					if #v == 0 then
						self.events_[k] = nil
					end
				end
			end
		end

		return 
	end,
	cleanup = function (self)
		self.events_ = {}

		return 
	end
}

return eventDispatcher
