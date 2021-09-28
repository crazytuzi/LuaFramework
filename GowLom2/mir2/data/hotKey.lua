local hotKey = {
	setKeyInfos = function (self, info)
		self.keyInfos = info

		return 
	end,
	getKeyInfos = function (self)
		return self.keyInfos
	end
}
local ver = "180"
hotKey.getHotKeySet = function (self)
	if not self.hotKeySet or #self.hotKeySet == 0 then
		self.hotKeySet = {}
		local index = 1

		for _, v in ipairs(def.operate.hotKeySet) do
			if v.version then
				for _, version in ipairs(v.version) do
					if tostring(version) == tostring(ver) then
						v.id = index

						table.insert(self.hotKeySet, v)

						index = index + 1

						break
					end
				end
			end
		end
	end

	return self.hotKeySet
end
hotKey.resetKey = function (self, id, key)
	local i_type = self.getType(self, id)

	if not i_type then
		return false
	end

	for _, v in ipairs(self.keyInfos) do
		if v.keyType == i_type.keyType and (not i_type.name or (v.params and v.params.name == i_type.name)) then
			v.keyType = nil
			v.params = nil
		end
	end

	for _, v in ipairs(self.keyInfos) do
		local isIn = true

		for _, v2 in ipairs(key) do
			if not self.iskeyInList(self, v2, v.pressKey) then
				isIn = false
			end
		end

		if #v.pressKey == #key and isIn then
			if v.canSet then
				v.keyType = i_type.keyType

				if i_type.name then
					v.params = {
						name = i_type.name
					}
				end

				return true
			else
				local errorMsg = "该键不可以自定义设置"

				return false, errorMsg
			end
		end
	end

	local newInfo = {}
	local keyName = {}

	for _, k in ipairs(key) do
		for _, v in ipairs(self.keyInfos) do
			if #v.pressKey == 1 and v.pressKey[1] == k then
				table.insert(keyName, v.keyName)
			end
		end
	end

	if 0 < #keyName then
		newInfo.id = #self.keyInfos + 1

		for i = 1, #keyName, 1 do
			if i == 1 then
				newInfo.keyName = keyName[i]
			else
				newInfo.keyName = newInfo.keyName .. "+" .. keyName[i]
			end
		end

		print("newInfo.keyName", newInfo.keyName)

		newInfo.pressKey = clone(key)
		newInfo.isKeybord = true
		newInfo.canSet = true
		newInfo.keyType = i_type.keyType

		if i_type.name then
			newInfo.params = {
				name = i_type.name
			}
		end

		table.insert(self.keyInfos, newInfo)

		return true
	end

	local errorMsg = "该键不可以自定义设置"

	return false
end
hotKey.isCanSet = function (self)
	local isIn = true

	for _, v2 in ipairs(key) do
		if not self.iskeyInList(self, v2, v.pressKey) then
			isIn = false
		end
	end

	return 
end
hotKey.getInfo = function (self, id)
	local i_type = self.getType(self, id)

	for _, v in ipairs(self.keyInfos) do
		if tostring(v.keyType) == tostring(i_type.keyType) and (not i_type.name or (v.params and v.params.name == i_type.name)) then
			return v
		end
	end

	return 
end
hotKey.getType = function (self, id)
	for i, v in ipairs(self.getHotKeySet(self)) do
		if i == id then
			return v
		end
	end

	return 
end
hotKey.isTrigger = function (self, keyCode, pressed)
	local key_count = 0
	local triggerInfo = nil

	for _, info in ipairs(self.keyInfos) do
		if self.iskeyInList(self, keyCode, info.pressKey) then
			local isFixed = true
			local i_count = 0

			for _, v in ipairs(info.pressKey) do
				if not self.iskeyInList(self, v, pressed) then
					isFixed = false

					break
				end

				i_count = i_count + 1
			end

			if isFixed then
				if key_count < i_count then
					triggerInfo = info
				end

				key_count = i_count
			end
		end
	end

	return triggerInfo
end
hotKey.iskeyInList = function (self, keyCode, pressed)
	for _, v in ipairs(pressed) do
		if v == keyCode then
			return true
		end
	end

	return false
end
hotKey.loadMagicHotKey = function (self, playerName)
	for _, magic in pairs(g_data.player.magicList) do
		if magic.key then
			for _, v in ipairs(self.keyInfos) do
				local key_id = nil

				if 48 < magic.key and magic.key < 57 then
					key_id = magic.key - 49 + 6
				elseif 64 < magic.key and magic.key < 73 then
					key_id = magic.key - 65 + 18
				end

				if v.id == key_id then
					self.setMagicHotKey(self, key_id, magic.magicId)
				end
			end
		end
	end

	return 
end
hotKey.setMagicHotKey = function (self, keyid, magicId)
	for _, info in ipairs(self.keyInfos) do
		if info.params and info.params.magicId == magicId then
			info.keyType = nil
			info.params = nil
		end
	end

	for _, info in ipairs(self.keyInfos) do
		if info.id == keyid then
			info.keyType = "skill"
			info.params = {
				magicId = magicId
			}
			local keyCode = nil

			if 6 <= keyid and keyid <= 13 then
				keyCode = keyid - 6 + 49

				break
			end

			if 18 <= keyid and keyid <= 25 then
				keyCode = keyid - 18 + 65
			end

			break
		end
	end

	return 
end
hotKey.magicIsHotKey = function (self, magicId)
	for _, info in ipairs(self.keyInfos) do
		if info.params and info.params.magicId == magicId then
			return true, info.id
		end
	end

	return false
end
hotKey.getMagicOfKey = function (self, keyid)
	for _, info in ipairs(self.keyInfos) do
		if info.id == keyid and info.keyType == "skill" and info.params then
			return info.params.magicId
		end
	end

	return 
end
hotKey.getSkillHotKey = function (self)
	local magicHotKeys = {}

	for i = 6, 13, 1 do
		local temp = {
			keyId = i,
			magicId = self.getMagicOfKey(self, i)
		}

		table.insert(magicHotKeys, temp)
	end

	for i = 18, 25, 1 do
		local temp = {
			keyId = i,
			magicId = self.getMagicOfKey(self, i)
		}

		table.insert(magicHotKeys, temp)
	end

	return magicHotKeys
end

return hotKey
