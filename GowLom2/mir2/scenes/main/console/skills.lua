local iconFunc = import(".iconFunc")
local widgetDef = g_data.widgetDef
local common = import("..common.common")
local skills = class("skills")

table.merge(skills, {
	console,
	max = 20
})

skills.ctor = function (self, console)
	self.console = console

	return 
end
skills.upt = function (self)
	local function get(magicId)
		for i, v in ipairs(g_data.player.magicList) do
			if v.FMagicId == tonumber(magicId) then
				return v
			end
		end

		return 
	end

	for k, v in pairs(self.console.widgets) do
		if v.__cname == "btnMove" and v.config.btntype == "skill" then
			v.skill_upt(slot6, get(v.data.magicId))
		end
	end

	local datas = cache.getDiy(common.getPlayerName(), "_current")

	if not datas then
		self.defLayout(self)
	end

	return 
end
skills.select = function (self, magicId)
	for k, v in pairs(self.console.widgets) do
		if v.__cname == "btnMove" and v.config.btntype == "skill" then
			if magicId and v.data.magicId == tonumber(magicId) then
				v.select(v)
			else
				v.unselect(v)
			end
		end
	end

	return 
end
skills.defLayout = function (self)
	for i, v in ipairs(g_data.player.magicList) do
		self.layout(self, v.FMagicId, true)
	end

	return 
end
skills.layout = function (self, magicId, hasLearn)
	local skillLvl = g_data.player:getMagicLvl(magicId)
	local config = def.magic.getMagicConfigByUid(magicId, skillLvl)

	if not config or not config.btnpos then
		return 
	end

	local exist = self.console:findWidgetWithBtnpos(config.btnpos)
	local cover = false

	for _, v in pairs(self.console.widgets) do
		if v.__cname == "btnMove" and v.config.btntype == "skill" and v.data.btnpos == config.btnpos then
			local skillLvl = g_data.player:getMagicLvl(v.data.magicId)
			local magicdata = def.magic.getMagicConfigByUid(v.data.magicId, skillLvl)

			if config.btnpos == magicdata.btnpos and magicdata.priority < config.priority then
				self.console:removeWidget(v.data.key)

				cover = true

				break
			end
		end
	end

	if (not exist or (exist and cover)) and not WIN32_OPERATE then
		local data = {
			key2 = "btnSkillTemp",
			btnpos = config.btnpos,
			key = "skill" .. config.uid,
			magicId = config.uid,
			priority = config.priority
		}

		self.console:addWidget(data)
		self.console:saveEdit()

		if cover and not cache.getDiy(common.getPlayerName(), "diy_skill") then
			cache.saveDiy(common.getPlayerName(), "diy_skill", {
				diy_skill = true
			})
		end
	end

	return 
end

return skills
