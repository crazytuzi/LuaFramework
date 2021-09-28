NotifyManager = {}
local xiakeid = 18
local function onClickedXiakeWarning()
	local jiuguan = XiakeJiuguan.getInstance()
	if not jiuguan:IsVisible() then
		jiuguan:SetVisible(true)
	end
	CWaringlistDlg:GetSingleton():HideWarning(xiakeid)
end

local function subscribeWarningEvent()
	local winMgr = CEGUI.WindowManager:getSingleton()
	local wnd = winMgr:getWindow(xiakeid.."waringlistitem")
	wnd:subscribeEvent("Clicked", onClickedXiakeWarning)
end

function NotifyManager.EventLevelChange(level)
	local poses = require "ui.xiake.xiake_manager".battlePos
	for i = 1, #poses do
		if poses[i] == level then
			CWaringlistDlg:GetSingleton():ShowWarning(xiakeid)
			subscribeWarningEvent()
		end
	end
end

function NotifyManager.HandleGotoFunction(npcid)
	if npcid == 61 then
		if GetTaskManager() then
			local quests = std.vector_int_()
			GetTaskManager():GetAcceptableQuestListForLua(quests)
			LogInsane("size="..quests:size())
			local hasQuest = false
			for i = 0, quests:size() - 1 do
				local taskid = quests[i]
				LogInsane("questid="..quests[i])
				local tasktype = GetTaskManager():GetTaskType(taskid)
				if tasktype ~= 0 and tasktype ~= 1 then
					hasQuest = true
					break
				end
			end
			if hasQuest then
				require "ui.task.taskdialog".OpenAcceptQuest()
			else
				GetNetConnection():send(knight.gsp.task.activelist.CRefreshActivityListFinishTimes())
			end
		end
	elseif npcid == 62 then
		local quests = std.vector_knight__gsp__task__ScenarioQuestInfo_()
		GetTaskManager():GetScenarioQuestListForLua(quests)
		local taskid = 0
		for i = 0, quests:size() - 1 do
			local questinfo = quests[i]
			LogInsane("questid="..questinfo.questid)
			local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.task.cfamoustask", questinfo.questid)
			if cfg and cfg.id ~= -1 then
				taskid = questinfo.questid
				break
			end
		end
		if taskid ~= 0 then
			require "ui.activity.npctipsdialog":getInstance():ParseCommitScenarioQuest(taskid, true)
		end
	elseif npcid == 63 then
		require "ui.jewelry.ringmake":GetSingletonDialogAndShowIt()
	end
	
end

function NotifyManager.SendOpenFactionProtocol()
	local p = require "protocoldef.knight.gsp.faction.copenfaction":new()
	require "manager.luaprotocolmanager":send(p)
end

return NotifyManager
