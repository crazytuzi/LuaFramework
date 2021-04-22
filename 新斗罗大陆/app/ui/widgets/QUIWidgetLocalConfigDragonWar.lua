
-- 本地龙战配置面板

local QUIWidgetLocalConfigBasePanel = import(".QUIWidgetLocalConfigBasePanel")
local QUIWidgetLocalConfigDragonWar = class("QUIWidgetLocalConfigDragonWar", QUIWidgetLocalConfigBasePanel)

local QUIWidgetLocalConfigInput = import("..widgets.QUIWidgetLocalConfigInput")

local QUIViewController = import("..QUIViewController")
local QUnionDragonWarArrangementLocal = import("...arrangement.QUnionDragonWarArrangementLocal")

function QUIWidgetLocalConfigDragonWar:ctor(options)
	QUIWidgetLocalConfigDragonWar.super.ctor(self, options)


	self._avtar = remote.user.avatar
	self._name = remote.user.nickname
	self._teamKey = remote.teamManager.UNION_DRAGON_WAR_ATTACK_TEAM
end




-- 战斗配置
function QUIWidgetLocalConfigDragonWar:fightConfig()
	self:beginGroup("战斗配置", "fight")
	self:addInput("    龙id：", "id", QUIWidgetLocalConfigInput.INPUT_MOD_NUMBER)
	self:addInput("龙的等级：", "level", QUIWidgetLocalConfigInput.INPUT_MOD_NUMBER)
	self:toNextLine()
	self:addInput("攻打次数：", "count", QUIWidgetLocalConfigInput.INPUT_MOD_NUMBER)
	self:addInput("战斗时长：", "time", QUIWidgetLocalConfigInput.INPUT_MOD_NUMBER)
	self:endGroup()
end

-- 加成配置
function QUIWidgetLocalConfigDragonWar:markUpConfig()
	self:beginGroup("加成配置", "markUp")
	self:addMultiple("开启神圣加成", "enabledSacred")
	self:addInput("神圣加成：", "sacred", QUIWidgetLocalConfigInput.INPUT_MOD_NUMBER)
	self:toNextLine()

	self:addInput("连胜次数：", "winningStreakCount", QUIWidgetLocalConfigInput.INPUT_MOD_NUMBER)
	self:toNextLine()
	self:addInput("连胜2加成：", "winningStreak_2", QUIWidgetLocalConfigInput.INPUT_MOD_NUMBER)
	self:addInput("连胜3加成：", "winningStreak_3", QUIWidgetLocalConfigInput.INPUT_MOD_NUMBER)
	self:toNextLine()
	self:addInput("连胜4加成：", "winningStreak_4", QUIWidgetLocalConfigInput.INPUT_MOD_NUMBER)
	self:addInput("连胜5加成：", "winningStreak_5", QUIWidgetLocalConfigInput.INPUT_MOD_NUMBER)
	self:endGroup()
end

-- 天气配置
function QUIWidgetLocalConfigDragonWar:weatherConfig()
	self:beginGroup("天气配置", "weather")

	local fightWeather = db:getStaticByName("sociaty_dragon_fight_weather")
	local weatherTable = {}
	for _, value in pairs(fightWeather) do
		table.insert(weatherTable, { id = value.id, name = value.name })
	end
	table.sort(weatherTable, function(a, b)
		return a.id < b.id
	end)

	for index, value in ipairs(weatherTable) do
		self:addSingle(value.name, "id", value.id)
		if index % 3 == 0 then
			self:toNextLine()
		end
	end

	self:endGroup()
end

-- 获取默认配置
function QUIWidgetLocalConfigDragonWar:getDefaultConfig()
	local fight = {
		id = 1,
		level = 1,
		count = db:getConfiguration()["sociaty_dragon_fight_initial"].value,
		time = 90,
	}
	local markUp = {
		sacred = db:getConfiguration()["sociaty_dragon_holy_bonous"].value,
		winningStreakCount = 1,
		winningStreak_2 = db:getConfiguration()["union_dragon_war_victory_time_2"].value,
		winningStreak_3 = db:getConfiguration()["union_dragon_war_victory_time_3"].value,
		winningStreak_4 = db:getConfiguration()["union_dragon_war_victory_time_4"].value,
		winningStreak_5 = db:getConfiguration()["union_dragon_war_victory_time_5"].value,
	}
	local weather = {
		id = 1,
	}

	return {
		fight = fight,
		markUp = markUp,
		weather = weather,
	}

end

function QUIWidgetLocalConfigDragonWar:makeConfigs()
	self:fightConfig()
	self:markUpConfig()
	self:weatherConfig()

	return self:getDefaultConfig()
end

function QUIWidgetLocalConfigDragonWar:onTriggerDo(config)
	local param = {
		teamKey = self._teamKey,
		myInfo = { avatar = self._avtar, name = self._name },
	}
	local dragonArrangement = QUnionDragonWarArrangementLocal.new(param)
	dragonArrangement:setInfo(config)

    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
		 options = {arrangement = dragonArrangement}})
end




function QUIWidgetLocalConfigDragonWar:startBattle()

end

return QUIWidgetLocalConfigDragonWar