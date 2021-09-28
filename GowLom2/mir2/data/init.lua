local gameData = {
	player = import(".player"),
	map = import(".map"),
	serverConfig = import(".serverConfig"),
	bag = import(".bag"),
	guild = import(".guild"),
	tradeshop = import(".tradeshop"),
	equip = import(".equip"),
	chat = import(".chat"),
	client = import(".client"),
	shop = import(".shop"),
	hero = import(".hero"),
	heroBag = import(".heroBag"),
	heroEquip = import(".heroEquip"),
	relation = import(".relation"),
	mail = import(".mail"),
	mark = import(".mark"),
	credit = import(".credit"),
	hotKey = import(".hotKey"),
	task = import(".task"),
	eventDispatcher = import(".eventDispatcher"),
	redPacket = import(".redPacket"),
	pointTip = import(".pointTip"),
	firstOpen = import(".firstOpen"),
	diffPanels = import(".diffPanels"),
	horse = import(".horse"),
	pet = import(".pet"),
	equipGrid = import(".equipGrid"),
	serverTime = import(".serverTime"),
	solider = import(".solider"),
	luckyGift = import(".luckyGift")
}
g_data = {
	login = import(".login"),
	select = import(".select"),
	setting = import(".setting"),
	bigmap = import(".bigmap"),
	testCommond = import(".testCommond"),
	flyMap = def.flyshoeConfig,
	reconnct = {},
	openRealTimeAction = false
}
g_data.cleanup = function ()
	for k, v in pairs(g_data) do
		if type(v) == "table" and v.cleanup then
			v.cleanup(v)
		end
	end

	return 
end
g_data.reset = function ()
	for k, v in pairs(gameData) do
		gameData[k]._data_reset = function ()
			g_data[k] = clone(v)

			return 
		end

		gameData[k]._data_reset()
	end

	return 
end

g_data.reset()

return 
