--DialogServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  DialogServlet.lua
 --* Author:  Huang YingTian
 --* Modified: 2009年12月9日 15:34:56
 --* Purpose: Implementation of the class DialogServlet
 -------------------------------------------------------------------*/
require "system.dialog.DialogFactory"
require "system.dialog.DialogConfig"

local factory = DialogFactory.getInstance()
DialogServlet = class(EventSetDoer, Singleton)
function DialogServlet:__init()
	self._doer = {
			[DIALOG_CS_CLICKNPC]	=	DialogServlet.doQueryNpc,
			[DIALOG_CS_CLICKOPTION]	=	DialogServlet.doOptionChosed,
		}	
end

--点击某个npc请求dialog
function DialogServlet:doQueryNpc(event)
	local params = event:getParams()
	local buff, dbId = params[1], params[2]
	local dialogReq, err = protobuf.decode("DialogClickProtocol" , buff)
	if dialogReq then
		local npcId = dialogReq.npcId
		local player = g_entityMgr:getPlayerBySID(dbId)
		if player and factory:canTalk(player, npcId) then
			local model = factory:createDialogModel(player, npcId)
			self:doSendDialog(player:getID(), model)
		else
			fireProtoSysMessageBySid(self:getCurEventID(), dbId, EVENT_DIALOG_SETS, Dialog_Distance_So_Long)
		end
	end
end

--执行定义的函数
function DialogServlet:execMethod(method_name, ...)
	local code, custom_fun = pcall(loadstring("local fun=" .. method_name .. " return fun"))
	if type(custom_fun) == "function" then
		local args = {...}
		return custom_fun(unpack(args))
	end
end

--点击选项
function DialogServlet:doOptionChosed(event)
	local params = event:getParams()
	local buff, dbId = params[1], params[2]
	local dialogReq, err = protobuf.decode("DialogOptionProtocol" , buff)
	if dialogReq then
		local npcId = dialogReq.npcId
		local player = g_entityMgr:getPlayerBySID(dbId)
		if player and factory:canTalk(player, npcId) then
			local dialogType = dialogReq.dialogType
			local dialogValue = dialogReq.dialogValue
			local dialogParam = dialogReq.dialogParam

			if dialogType == DialogActionType.Doer then
				if GameDoerMap[dialogValue] then
					self:execMethod(GameDoerMap[dialogValue], player:getID(), npcId, dialogParam)
				else
					print("Can't find method:" .. dialogValue)
				end
			elseif dialogType == DialogActionType.Runtime_Task then
				local option = {type = dialogType, value = dialogValue, param = dialogParam}
				local model = factory:createDialogModel(player, npcId, option)		
				self:doSendDialog(player:getID(), model)
			end
		end
	end
end

--发送对话框快捷方式
function DialogServlet:fireDialog(roleId, npcId, text, options)
	local protoData = {
		npcId = npcId,
		txtId = 0,		
		type = DialogModelType.Npc,		
		txt = text,	
		options = {}
	}
	local op_id = 1001
	for _, option in pairs(options) do
		local new_option = {}
		new_option.op_id = op_id + 1
		new_option.text = option.text
		new_option.type = option.type
		new_option.value = option.value
		new_option.icon = option.icon
		new_option.param = option.param
		table.insert(protoData.options, new_option)
	end	
	fireProtoMessage(roleId, DIALOG_SC_CLICKNPC, "DialogClickRetProtocol", protoData)
end

--发送对话框
function DialogServlet:doSendDialog(roleId, model)
	if model then
		local protoData = {
			npcId = model.npcId,
			txtId = model.txtId,		
			type = model.type,	
			txt = model.txt,
			options = {}
		}
		for op_id, option in pairs(model.options) do
			local new_option = {}
			new_option.op_id = op_id
			if op_id > 1000 then
				new_option.text = option.text
				new_option.type = option.type
				new_option.value = option.value
				new_option.icon = option.icon
				new_option.param = option.param
			end
			table.insert(protoData.options, new_option)
		end
		fireProtoMessage(roleId, DIALOG_SC_CLICKNPC, "DialogClickRetProtocol", protoData)
	end
end

function DialogServlet.getInstance()
	return DialogServlet()
end

g_dialogServlet = DialogServlet.getInstance()
g_eventMgr:addEventListener(g_dialogServlet)
