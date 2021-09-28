local equipBase = import(".equip")
local equipPc = class("equipPc", equipBase)
equipPc.ctor = function (self, params)
	equipBase.ctor(self, params)

	self.__cname = "equip"
	self.updateKey = gameEvent:addEventListener(gameEvent.skillHotKey, function (event)
		self:updateHotKeyUI()

		return 
	end)

	self.registerScriptHandler(equipBase, function (event)
		if event == "exit" then
			self:onExit()
		end

		return 
	end)

	return 
end
equipPc.onExit = function (self)
	if self.updateKey ~= nil then
		gameEvent:removeEventListener(self.updateKey)
	end

	return 
end
equipPc.updateMagic = function (self, magicId, node)
	equipBase.updateMagic(self, magicId, node)

	local magicData = self.baseData:getMagic(tonumber(magicId))

	if magicData then
		local hasKey, keyid = g_data.hotKey:magicIsHotKey(magicId)

		if keyid and (keyid < 6 or 29 < keyid) then
			return 
		end

		local strKey = nil

		if hasKey then
			if keyid < 18 then
				strKey = "F" .. keyid - 5
			else
				strKey = "F" .. keyid - 17 .. "\nCtrl"
			end
		else
			strKey = "ÉèÖÃ"
		end

		slot7 = an.newBtn(res.gettex2("pic/common/btn101.png"), function ()
			main_scene.ui:togglePanel("magicKeySetting", {
				magicId = magicId
			})

			return 
		end, {
			pressBig = true,
			label = {
				strKey,
				18,
				1,
				{
					color = cc.c3b(255, 255, 0)
				}
			}
		}).pos(slot7, 240, node.geth(node)/2):add2(node)
	end

	return 
end
equipPc.updateHotKeyUI = function (self)
	if self.page == "skill" then
		self.showContent(self, "skill")
	end

	return 
end

return equipPc
