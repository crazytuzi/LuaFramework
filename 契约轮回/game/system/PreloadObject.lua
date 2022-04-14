--
-- @Author: LaoY
-- @Date:   2019-08-17 14:57:42
--

--require("game.xx.xxx")

PreloadObject = PreloadObject or class("PreloadObject")

function PreloadObject:ctor(abName,assetName,cache_count,load_call_back)
	self.abName = abName
	self.assetName = assetName
	self.load_call_back = load_call_back

	self:Load()
end

function PreloadObject:dctor()
	-- 清除引用
	lua_resMgr:ClearClass(self)
	if not poolMgr:AddGameObject(self.abName, self.assetName, self.gameObject) then
		destroy(self.gameObject)
	end
	self.gameObject = nil
end

function PreloadObject:Load()
	local function load_call_back(objs,is_cache)
		if objs then
			local obj = objs[0]
			if is_cache then
	    		self.gameObject = obj
			else
	    		self.gameObject = newObject(obj)
	    	end
		end

		if self.load_call_back then
			self.load_call_back()
		end

		local function step()
			self:destroy()
		end
		GlobalSchedule:StartOnce(step,0)
	end
	lua_resMgr:LoadPrefab(self, self.abName, self.assetName, load_call_back)
end