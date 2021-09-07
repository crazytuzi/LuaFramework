local QuickRestart = {}

local old_act_scene_id = 0

function QuickRestart:Restart(reload_files)
	print(string.format("<color=#00ff00>[QuickRestart] start </color>", v))
	
	reload_files = self:GetReloadFiles(reload_files)
	if not self:PreCheckReloadFiles(reload_files) then
		return
	end

	old_act_scene_id = Scene.Instance:GetSceneId()
	CrossServerData.Instance:SetDisconnectGameServer()
	GameNet.Instance:DisconnectGameServer()

	local develop_mode = require("editor/develop_mode")
	develop_mode:UnLoadAllcheck()
	
	ViewManager.Instance:DestoryAllAndClear()
	ModulesController.Instance:DeleteGameModule()

	ConfigManager.Instance:ClearCfgList()
	self:ReLoadFiles(reload_files)
	develop_mode:Init()

	ModulesController.Instance:CreateGameModule()
	Scene.Instance.act_scene_id = old_act_scene_id

	GameNet.Instance:ResetLoginServer()
	GameNet.Instance:ResetGameServer()
	GameNet.Instance:AsyncConnectLoginServer(5)

	print(string.format("<color=#00ff00>[QuickRestart] success </color>", v))
end

function QuickRestart:GetReloadFiles(reload_files)
	local file_list = Split(reload_files or "", "|")
	table.insert(file_list, "game.guaji.guaji_data")
	
	return file_list
end

function QuickRestart:ReLoadFiles(reload_files)
	for _, v in pairs(reload_files) do
		if "" ~= v then
			print(string.format("<color=#00ff00> [ReLoadFile]%s</color>", v))
			_G.package.loaded[v] = nil
			require(v)
		end
	end
end

function QuickRestart:PreCheckReloadFiles(reload_files)
	for _, v in pairs(reload_files) do
		assert(loadfile(string.gsub(v, "%.", "/")))
	end

	return true
end



return QuickRestart