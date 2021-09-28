local onRecvMasterReq = function(buff)
	log("onRecvMasterReq")
	local t = g_msgHandlerInst:convertBufferToTable("MasterRet", buff) 
	local name = t.name
	local staticId = t.roleSID
	local function yesFunc()
		--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_AGREE_REQ, "ii", G_ROLE_MAIN.obj_id, staticId)
		local t = {}
		t.roleSID = staticId
		g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_AGREE_REQ, "MasterAgree", t)
	end

	local function noFunc()
		--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_REFUSE_REQ, "i", staticId)
		local t = {}
		t.roleSID = staticId
		g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_REFUSE_REQ, "MasterRefuse", t)
	end
	local box = MessageBoxYesNo(nil, string.format(game.getStrByKey("master_master_request"), name), yesFunc, noFunc)
	box:setLocalZOrder(150)
end

local onRecvStudentReq = function(buff)
	log("onRecvStudentReq")
	local t = g_msgHandlerInst:convertBufferToTable("ApprenticeRet", buff) 
	local name = t.name
	local staticId = t.roleSID
	local function yesFunc()
		--g_msgHandlerInst:sendNetDataByFmtExEx(APPRENTICE_CS_AGREE_REQ, "ii", G_ROLE_MAIN.obj_id, staticId)
		local t = {}
		t.roleSID = staticId
		g_msgHandlerInst:sendNetDataByTableExEx(APPRENTICE_CS_AGREE_REQ, "ApprenticeAgree", t)
	end

	local function noFunc()
		--g_msgHandlerInst:sendNetDataByFmtExEx(APPRENTICE_CS_REFUSE_REQ, "i", staticId)
		local t = {}
		t.roleSID = staticId
		g_msgHandlerInst:sendNetDataByTableExEx(APPRENTICE_CS_REFUSE_REQ, "ApprenticeRefuse", t)
	end
	local box = MessageBoxYesNo(nil, string.format(game.getStrByKey("master_student_request"), name) , yesFunc, noFunc)
	box:setLocalZOrder(150)
end

local function addHistoryData(param)

	local actionStr = 
	{
		[1] = {str=game.getStrByKey("master_str_history_1"), dir="/master_", isMaster=true},
		[2] = {str=game.getStrByKey("master_str_history_2"), dir="/master_", isMaster=true},
		[3] = {str=game.getStrByKey("master_str_history_3"), dir="/master_", isMaster=true},
		[4] = {str=game.getStrByKey("master_str_history_4"), dir="/student_", isMaster=false},
		[5] = {str=game.getStrByKey("master_str_history_5"), dir="/student_", isMaster=false},
		[6] = {str=game.getStrByKey("master_str_history_6"), dir="/student_", isMaster=false},
		[7] = {str=game.getStrByKey("master_str_history_7"), dir="/student_", isMaster=false},
	}

	local record = actionStr[param.flag]
	--dump(record)
	if record.isMaster then
		local data = {}
		local fileName = getDownloadDir().."master_"..tostring(userInfo.currRoleStaticId)..".cfg"
		local file = io.open(fileName, "r")

		if not file then
			file = io.open(fileName, "w")
			if file then 
				file:close()
				file = io.open(fileName, "r")
			end
		end

		if file then
			local str = file:read()
			while str do
				table.insert(data, str)
				str = file:read()
			end

			local timeStr = os.date(game.getStrByKey("master_master_history_time"), param.time)
			local actionStr = string.format(record.str, param.name or "")
			local str
			if timeStr and actionStr then
				str = timeStr..actionStr
			end
			dump(data)
			if str then
				table.insert(data, #data+1, str)
			end

			while #data > 50 do
				table.remove(data, 1)
			end
			file:close()
		end

		local file = io.open(fileName, "w+")
		if file then
			dump(data)
			for i,v in ipairs(data) do
			 	file:write(v)
				file:write("\n")
			end
			file:close() 
		end
	else
		local data = {}
		local fileName = getDownloadDir().."student_"..tostring(userInfo.currRoleStaticId)..".cfg"
		local file = io.open(fileName, "r")

		if not file then
			file = io.open(fileName, "w")
			if file then 
				file:close()
				file = io.open(fileName, "r")
			end
		end

		if file then
			local str = file:read()
			while str do
				table.insert(data, str)
				str = file:read()
			end

			local timeStr = os.date(game.getStrByKey("master_master_history_time"), param.time)
			local actionStr = string.format(record.str, param.name or "")
			local str
			if timeStr and actionStr then
				str = timeStr..actionStr
			end

			if str then
				table.insert(data, #data+1, str)
			end

			while #data > 50 do
				table.remove(data, 1)
			end
			file:close()
		end

		local file = io.open(fileName, "w+")
		if file then
			for i,v in ipairs(data) do
			 	file:write(v)
				file:write("\n")
			end
			file:close() 
		end
	end
end

local onRecvExperienceReq = function(buff)
	log("onRecvExperienceReq")
	local t = g_msgHandlerInst:convertBufferToTable("MasterAddExperience", buff) 
	local flag = t.flag
	local time = t.time
	local name = t.name
	addHistoryData({flag=flag, time=time, name=name})
end

local onSuccess = function(buff)
	log("onSuccess") 
	playCommonFontEffect(3)
end

g_msgHandlerInst:registerMsgHandler(MASTER_SC_REQ_RET, onRecvMasterReq)
g_msgHandlerInst:registerMsgHandler(APPRENTICE_SC_REQ_RET, onRecvStudentReq)
g_msgHandlerInst:registerMsgHandler(MASTER_SC_ADD_EXPERIENCE, onRecvExperienceReq)
g_msgHandlerInst:registerMsgHandler(MASTER_SC_REQ_SUCCESS, onSuccess)