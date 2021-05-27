
local init_query = {
	MAX_RETRY = 8,
	RETRY_INTERVAL = 2,
	http = nil,
	start_time = 0,
	task_status = 0,

	query_flag = false,
	retry_time = 0,
	retry_count = 0,
	net_state = -1,
}

function init_query:Name()
	return "init_query"
end

function init_query:Start()
	print("init_query:Start")
	if 0 ~= self.start_time then return end

	self.http = HttpRequester:create()
	if nil ~= self.http then
		self.start_time = NOW_TIME
		
		self.http:retain()
		self.http:setCallback(LUA_CALLBACK(self, self.OnFetched))
		self:Request()

		self.task_status = MainLoader.TASK_STATUS_FINE

		MainProber:Step(MainProber.STEP_TASK_INIT_QUERY_BEG, GLOBAL_CONFIG.local_config.init_url)
		-- if MainProber.Step2 then MainProber:Step2(200, GLOBAL_CONFIG.local_config.init_url) end
	-- end
    -- if PLATFORM == cc.PLATFORM_OS_WINDOWS then
        -- require("win_local_server_list")
        -- if ServerList.use_local_server_list then
            -- MainLoader:PushTask(require("scripts/preload/load_script"))
            -- self.task_status = MainLoader.TASK_STATUS_DONE
            -- GLOBAL_CONFIG.server_info.server_list = ServerList.server_list
        -- end
    -- end
		if MainProber.Step2 then MainProber:Step2(MainProber.PHP_PUSH_GET_CONFIG_START, GLOBAL_CONFIG.local_config.init_url) end
	end
end

function init_query:Stop()
	print("init_query:Stop")
	if 0 == self.start_time then return end

	if nil ~= self.http then
		self.http:release()
		self.http = nil
	end
	self.net_state = 0
	self.retry_time = 0
	self.retry_count = 0
	self.start_time = 0
	self.task_status = 0
end

function init_query:Update()
	if 0 == self.start_time then return end
	
	if NOW_TIME > self.start_time + 1200 then
		self.task_status = MainLoader.TASK_STATUS_EXIT
	end

	if self.retry_time > 0 and NOW_TIME > self.retry_time then
		self:Request()
	end

	return self.task_status
end

function init_query:Status()
	return self.task_status, self.net_state, self.retry_count, self.retry_time
end

function init_query:Request()
	if self.query_flag then return end

	self.retry_time = 0
	self.retry_count = self.retry_count + 1
	if self.retry_count < self.MAX_RETRY and nil ~= self.http then
		local server = GLOBAL_CONFIG.local_config.init_url
		if 1 == (self.retry_count % 2) and GLOBAL_CONFIG.local_config.config_url then
			server = GLOBAL_CONFIG.local_config.config_url
		end
		local url = string.format("%s?plat=%s&pkg=%s&asset=%s&device=%s", server,
			GLOBAL_CONFIG.package_info.config.agent_id,
			GLOBAL_CONFIG.package_info.version, 
			GLOBAL_CONFIG.assets_info.version,
			tostring(PlatformAdapter.GetPhoneUniqueId())
			)

		if self.http:addRequest(url, "", 5) then
			self.query_flag = true
		end

		print("init_query request " .. url)
		MainProber:Warn(MainProber.EVENT_CONFIG_RETRY or 10016, self.retry_count, (NOW_TIME - self.start_time), url)
	end
end

function init_query:Retry()
	if MainLoader.TASK_STATUS_DONE ~= self.task_status then
		local delay = self.RETRY_INTERVAL + (math.random() * 1)
		self.retry_time = NOW_TIME + delay
		print("init_query retry " .. self.retry_count .. " " .. delay)
	end
end

function init_query:CheckInfo(info)
	if nil == info then
		return false
	end

	return true
end

function init_query:UpdateConfig()
	GLOBAL_CONFIG.local_config.init_url = GLOBAL_CONFIG.param_list.init_url
	GLOBAL_CONFIG.local_config.config_url = GLOBAL_CONFIG.param_list.config_url
	GLOBAL_CONFIG.local_config.report_url = GLOBAL_CONFIG.param_list.report_url
	GLOBAL_CONFIG.local_config.report_url2 = GLOBAL_CONFIG.param_list.report_url2
	GLOBAL_CONFIG.local_config.switch_list = GLOBAL_CONFIG.param_list.switch_list or {}
	PlatformAdapter:SaveLocalConfig(GLOBAL_CONFIG.local_config)

	IS_AUDIT_VERSION = GLOBAL_CONFIG.local_config.switch_list.audit_version
	MainLoader:AuditVersionChanged()

	-- if IS_AUDIT_VERSION then
		-- local vertDefaultSource = "" ..
				-- "attribute vec4 a_position; \n" ..
				-- "attribute vec2 a_texCoord; \n" ..
				-- "attribute vec4 a_color; \n" ..
				-- "#ifdef GL_ES \n" ..
				-- "varying lowp vec4 v_fragmentColor;\n" ..
				-- "varying mediump vec2 v_texCoord;\n" ..
				-- "#else \n" ..
				-- "varying vec4 v_fragmentColor; \n" ..
				-- "varying vec2 v_texCoord;  \n" ..
				-- "#endif \n" ..
				-- "void main() \n" ..
				-- "{\n" ..
				-- "gl_Position = CC_PMatrix * a_position; \n" ..
				-- "v_fragmentColor = a_color;\n" ..
				-- "v_texCoord = a_texCoord;\n" ..
				-- "}"
		-- local pszFragSource = "" ..
				-- "#ifdef GL_ES \n" ..
				-- "precision mediump float; \n" ..
				-- "#endif \n" ..
				-- "varying vec4 v_fragmentColor; \n" ..
				-- "varying vec2 v_texCoord; \n" ..
				-- "void main(void) \n" ..
				-- "{ \n" ..
				-- "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..
				-- "gl_FragColor = v_fragmentColor * vec4(0.9*c.r, 0.9*c.g, 1.6*c.b, 0.9 * c.a); \n" ..
				-- "}"

	    -- local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource, pszFragSource)
	    -- pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
	    -- pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
	    -- pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
	    -- pProgram:updateUniforms()
	    -- cc.GLProgramCache:getInstance():addGLProgram(pProgram, "ShaderPositionTextureColor_noMVP");
	-- end

	if nil == GLOBAL_CONFIG.param_list.agent_config then
		GLOBAL_CONFIG.param_list.agent_config = {}
	end
	
	GlobalConfigChanged()
end

function init_query:OnFetched(url, arg, data, size)
	print("init_query:OnFetched = " .. size)
	self.query_flag = false

	for i=1,1 do
		if nil == data or size <= 0 then break end

		local init_info = cjson.decode(data);
		if not self:CheckInfo(init_info) then break end

		if nil == init_info.param_list then break end
		GLOBAL_CONFIG.param_list = init_info.param_list

		MainProber:Step(MainProber.STEP_TASK_INIT_QUERY_END, self.retry_count, GLOBAL_CONFIG.param_list.client_ip)
		-- if MainProber.Step2 then MainProber:Step2(300, self.retry_count) end
		if MainProber.Step2 then MainProber:Step2(MainProber.PHP_PUSH_GET_CONFIG_END, self.retry_count) end

		if nil == init_info.server_info then break end
		GLOBAL_CONFIG.server_info = init_info.server_info
		GLOBAL_CONFIG.client_time = NOW_TIME

		if nil == init_info.version_info then break end
		local version_info = init_info.version_info
		GLOBAL_CONFIG.version_info = {}

		if nil == version_info.package_info then break end
		GLOBAL_CONFIG.version_info.package_info = version_info.package_info

		if nil == version_info.assets_info then break end
		GLOBAL_CONFIG.version_info.assets_info = version_info.assets_info

		if nil == version_info.update_data then break end
		local update_data = mime.unb64(version_info.update_data)

		-- if nil == update_data then break end
		-- if PLATFORM ~= cc.PLATFORM_OS_WINDOWS then		
			-- local update_func = loadstring(update_data)
			-- if nil ~= update_func and "function" == type(update_func) then
				-- local updater = update_func()
				local updater = require("scripts/update")
				-- if nil ~= updater and nil ~= updater.Start then
					-- self:UpdateConfig()
					-- MainLoader:PushTask(updater)
					-- self.task_status = MainLoader.TASK_STATUS_DONE
				-- end
			-- end
			-- ResourceMgr:getInstance():setDownloadUrl(GLOBAL_CONFIG.param_list.update_url .. "data/")
		-- else	
            -- MainLoader:PushTask(require("scripts/preload/load_script"))
            -- self.task_status = MainLoader.TASK_STATUS_DONE
		-- end
		
		if nil == version_info.update_data then break end
		local update_data = mime.unb64(version_info.update_data)

		if nil == update_data then break end
		local update_func = loadstring(update_data)
		if nil ~= update_func and "function" == type(update_func) then
			local updater = update_func()
			if nil ~= updater and nil ~= updater.Start then
				self:UpdateConfig()

				MainLoader:PushTask(updater)
				
				self.task_status = MainLoader.TASK_STATUS_DONE
			end
		end

		ResourceMgr:getInstance():setDownloadUrl(GLOBAL_CONFIG.param_list.update_url .. "data/")
		
		break
	end

	self:Retry()
end

function init_query:NetStateChanged(net_state)
	self.net_state = net_state
	print("init_query:NetStateChanged = " .. net_state)

	self.retry_count = 0
	self:Retry()
end

return init_query 
