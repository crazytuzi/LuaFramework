-- View中的插件清理
NeedDelObjs = NeedDelObjs or {}

NeedDelObjs.list = {}

function NeedDelObjs:add(class, key)
	self.list[class] = self.list[class] or {}
	if nil == self.list[class][key] then
		if type(class[key]) == "table" then
			self.list[class][key] = true
		else
			ErrorLog("[NeedDelObjs]:key is not correct!")
		end
	else
		ErrorLog("[NeedDelObjs]:Attempt to create singleton twice!")
	end
end

function NeedDelObjs:clear(class)
	for k in pairs(self.list[class] or {}) do
		if type(class[k]) == "table" then
			if class[k].DeleteMe == nil then
				for i,v in pairs(class[k]) do
					if type(v) == "table" and v.DeleteMe then
						v:DeleteMe()
					else
						local view_def = ViewManager:GetStrByView(class.view_def or {})
						ErrorLog(string.format("[NeedDelObjs]:Trying to clean up the Key:%s in View:%s has a variable that does not have DeleteMe()", k, view_def))
					end
				end
			else
				class[k]:DeleteMe()
			end
			class[k] = nil
		else
			local view_def = ViewManager:GetStrByView(class.view_def or {})
			ErrorLog(string.format("[NeedDelObjs]:Trying to clean up the Key:%s in View:%s is not a table!", k, view_def))
		end
	end

	self.list[class] = nil
end