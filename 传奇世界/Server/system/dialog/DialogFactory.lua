--DialogFactory.lua
--/*-----------------------------------------------------------------
 --* Module:  DialogFactory.lua
 --* Author:  Huang YingTian
 --* Modified: 2009年12月16日 15:29:49
 --* Purpose: Implementation of the class DialogFactory
 -------------------------------------------------------------------*/

 DialogFactory=class(nil, Singleton)

function DialogFactory:__init()
	self._npcs = {}
	self._options = {}
	self._npc_options = {}
	local npc_data = require "data.NpcDB"
	for i, info in pairs(npc_data) do
		if info.q_options then			
			self._npc_options[info.q_id] = unserialize(info.q_options)
		end
		self._npcs[info.q_id] = {x = info.q_x, y = info.q_y, mapId = info.q_map }
	end
	local option_data = require "data.NpcOptionDB"
	for i, info in pairs(option_data) do
		if info.id then			
			self._options[info.id] = info
		end
	end
end

--判断npc对话距离
function DialogFactory:canTalk(player, npcId)
	local npcpos = self._npcs[npcId]	
	if npcpos and npcpos.mapId == player:getMapID() then
		local tile = player:getTile()
		if math.max(math.abs(tile.x - npcpos.x), math.abs(tile.y - npcpos.y)) <= 5 then
			return true
		end
	end
	return false
end

--取得运行时任务选项，param存在则直接执行了rule，否则获得所有与该npc相关任务选项
function DialogFactory:getRunOptions_Task(player, npcId, option)
	if player and npcId then
		return g_taskMgr:doTalkWithNPC(player, npcId, option)
	end
	return "", 0, {}
end

function DialogFactory:createOneModel(npcId, txtId, text, options, type)
	local modelData = {}
	modelData.txt = text or ""
	modelData.type = type or DialogModelType.Npc
	modelData.npcId = npcId or 0
	modelData.txtId = txtId or 0
	modelData.options = options
	return modelData
end

--创建对话框
function DialogFactory:createDialogModel(player, npcId, option)
	if npcId then
		if option and option.type == DialogActionType.Runtime_Task then
			local now_options = {}
			local text, txtIdx, task_options = self:getRunOptions_Task(player, npcId, option)
			--加上运行时options
			if table.size(task_options) > 0 then
				local customId = 1001
				for id, option_info in pairs(task_options) do
					now_options[customId] = option_info
					customId = customId + 1
				end
				return self:createOneModel(npcId, txtIdx, text, now_options, DialogModelType.Task)
			end			
		else
			return self:pickNpcData(player, npcId)
		end
	end
end

--NPC对话框的生成，主要的修改在于仅对默认对话框提供运行时任务选项
function DialogFactory:pickNpcData(player, npcId)
	local text, txtIdx, task_options = self:getRunOptions_Task(player, npcId)

	if task_options and #task_options == 1 then
		local option = task_options[1]
		if option then
			--只有一个任务选项的时候，直接打开任务相关对话
			local model = self:createDialogModel(player, npcId, option)		
			g_dialogServlet:doSendDialog(player:getID(), model)
		end
		return
	end
	--缺省的对话
	local options = {}
	if self._npc_options[npcId] then
		for i, optionId in pairs(self._npc_options[npcId]) do
			options[optionId] = self._options[optionId]
		end
	end
	--加上运行时options
	local customId = 1001
	for id, option_info in pairs(task_options) do
		options[customId] = option_info
		customId = customId + 1
	end
	--组装对话框
	return self:createOneModel(npcId, npcId, text, options, DialogModelType.Npc)
end

 function DialogFactory.getInstance()
	return DialogFactory()
 end
