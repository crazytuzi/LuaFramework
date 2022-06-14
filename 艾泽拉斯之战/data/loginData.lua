loginData = class("loginData")

function loginData:ctor()
	
	self.userName = "";
    self.passWord = "";
	self.serverId = 0;
	
	self.sdkLoginJson = "";
	self.bIsReconnect = false;
	
	self.enterBackTime = 0;
	
	self.isLogin = false;
	
	self.disconectType = enum.LOGIN_RESULT.LOGIN_RESULT_INVALID;
	
end

function loginData:initFromConfig()
	
	self.userName = fio.readIni("login", "userName", "", "config.cfg");
	self.serverId = fio.readIni("login", "lastServer", "", "config.cfg");
    self.passWord = fio.readIni("login", "passWord", "", "config.cfg");	
end

function loginData:setUserName(userName)
	
	self.userName = userName;
	
	fio.writeIni("login", "userName", self.userName, "config.cfg");
	
end

function loginData:setServerId(serverId)
	
	self.serverId = serverId;
	
	fio.writeIni("login", "lastServer", tostring(self.serverId), "config.cfg");
	
end

function loginData:setPassWord(password)
    self.passWord = password;
    fio.writeIni("login", "passWord", self.passWord, "config.cfg");
end

function loginData:getUserName()
	return self.userName;
end

function loginData:setPhoneNum(phoneNum)
    self.phoneNum = phoneNum;
end

function loginData:getPassWord()
    return self.passWord;
end

function loginData:getServerId()
	return self.serverId;
end

function loginData:setLoginJson(loginJson)
	self.sdkLoginJson = loginJson;
end

function loginData:getLoginJson()
	return self.sdkLoginJson;
end

function loginData:isReconnect()
	return self.bIsReconnect;
end

function loginData:login(isReconnect)
 	
 	self.bIsReconnect = isReconnect;
 	
    
 	local data = self:getServerDataFromCustomList(self.serverId);

 	if data then			
		local result = networkengine:connect(data.ipAndPort);
		
		if not result then
		
			eventManager.dispatchEvent({name = global_event.LOGIN_WIN_ENABLE_LOGIN, enabled = true});
			
		 	eventManager.dispatchEvent({name = global_event.MESSAGEBOX_SHOW, 
				textInfo = "服务器还没开启，请客官不要着急!", callBack = function() 
					
					if(game.state ~= game.GAME_STATE_LOADING)then
						GameClient.CGame:Instance():ResetGame();
					end
					
				end});	
				
				return;
		end
		
	
		--[[
	    local device = "";
	        local shellInterface = GameClient.CGame:Instance():getShellInterface();
			if shellInterface then
				device = shellInterface:getDeviceInfo();
			end			
	        if string.len(device) > 64 then
	            device = "windows simulater";
	        end
		]]


        -- zhouyou
        -- 测试 gameCenterID 和 udid
        -- self.userName 作为 gameCenterID
        -- self.passWord 作为 gameCenterID
        -- 如果用户未登陆gameCenter 那么 self.userName为“” self.passWord为设备ID
        -- 测试例子1 userName = ""  passWord = "this_is_udid_1"          返回 id 1
        -- 测试例子2 userName = "zhouyou" passWord = "this_is_udid_1"    返回 id 1
        -- 测试例子3 userName = "zhangyi" passWord = "this_is_udid_1"    返回 id 2
        -- 测试例子4 userName = ""  passWord = "this_is_udid_1"          返回 id 1
	    --print("userName."..self.userName.."passWord."..self.passWord.."device"..device.."serverID."..data.serverid);
		--sendLogin(self.userName, self.passWord, enum.PACKET_VERSION, self.passWord, data.serverid);

		local currentPlatform = GameClient.CGame:Instance():getPlatformInfo();
		if currentPlatform == "test" then
			-- windows
			sendLogin(self.userName, self.passWord, enum.PACKET_VERSION, self.passWord, data.serverid);
		else
			-- ios
			local sdkJson = self:getLoginJson();
			
			if sdkJson == "" then
				sdkJson = "{}";
			end
			
			local sdkTable = json.decode(sdkJson);
			if sdkTable == nil then
				sdkTable = {};
			end
			
			sdkTable.serverID = data.serverid;
			sdkTable.serverVersion = enum.PACKET_VERSION;
			sdkTable.device = "";
					
			local shellInterface = GameClient.CGame:Instance():getShellInterface();
			if shellInterface then
				sdkTable.device = shellInterface:getDeviceInfo();
			end
			
			sdkJson = json.encode(sdkTable);
			
			print(sdkJson);
			
			if sdkTable.playerID == nil or sdkTable.playerID == "" then
			
			end

			if sdkTable.playerID ~= "" then
				self:setUserName(sdkTable.playerID);
			end

			-- sdkJson 里面 playerID 字段是gamecenter的id， mac 字段是设备唯一标识
			sendLogin(self.userName, self.passWord, enum.PACKET_VERSION, sdkTable.device, data.serverid);

		end

		--sendLogin2(sdkJson);
		
		eventManager.dispatchEvent({name = global_event.LOGIN_WIN_ENABLE_LOGIN, enabled = false});
	end
end


function loginData:regist()
 	
 	local data = self:getServerDataFromCustomList(self.serverId);

 	if data then			
		local result = networkengine:connect(data.ipAndPort);
		
		if not result then
		 	eventManager.dispatchEvent({name = global_event.MESSAGEBOX_SHOW, 
				textInfo = "服务器还没开启，请客官不要着急!", callBack = function() 
					
					if(game.state ~= game.GAME_STATE_LOADING)then
						GameClient.CGame:Instance():ResetGame();
					end
					
				end});	
				
				return;
		end
		
        local device = "";
        local shellInterface = GameClient.CGame:Instance():getShellInterface();
		if shellInterface then
			device = shellInterface:getDeviceInfo();
		end			
        if string.len(device) > 64 then
            device = "windows simulater";
        end

        print("userName."..self.userName.."passWord."..self.passWord.."device"..device.."serverID."..data.serverid);
		sendRegist(self.userName, self.passWord, self.phoneNum, enum.PACKET_VERSION, device, data.serverid);
		
		--local sdkJson = self:getLoginJson();
		
		--if sdkJson == "" then
		--	sdkJson = "{}";
		--end
		
		--local sdkTable = json.decode(sdkJson);
		--if sdkTable == nil then
		--	sdkTable = {};
		--end
		
		--sdkTable.serverID = data.serverid;
		--sdkTable.serverVersion = enum.PACKET_VERSION;
		--sdkTable.device = "";
				
		--local shellInterface = GameClient.CGame:Instance():getShellInterface();
		--if shellInterface then
		--	sdkTable.device = shellInterface:getDeviceInfo();
		--end
		
		--sdkJson = json.encode(sdkTable);
		
		--print(sdkJson);
				
		--sendLogin2(sdkJson);
		
		eventManager.dispatchEvent({name = global_event.REGISTER_HIDE});
	end
end


-- 根据id从删选后的serverlist里获取serverdata
function loginData:getServerDataFromCustomList(id)
	local serverlist = self:getServerlist();
	
	return serverlist[id];
	
end

function loginData:getServerlist()

	local serverlist = {};
	
	local currentPlatform = GameClient.CGame:Instance():getPlatformInfo();
	
	-- currentPlatform 如果是test，能看到所有的服务器列表
	-- 如果是apps，只能看到ios官方的
	-- 其他的看到的是越狱渠道的服务器列表
	
	local serverlist = nil;
	if currentPlatform == "test" then
		-- windows
		serverlist = dataConfig.configs.serverlistConfig;
	elseif currentPlatform == "apps" then
		-- ios 官方
		serverlist = dataConfig.configs.serverlistappsConfig;
	else
		-- 越狱 + android
		serverlist = dataConfig.configs.serverlistpbConfig;
	end
	
	-- 筛选看不到的
	local resultlist = {};
	local nowtime = dataManager.getServerTime();
	for k,v in ipairs(serverlist) do
		
		local year, month, day = stringToDate(v.date);
		local hour, minute = stringToTime(v.time);
		
		local time = os.time({year = year, month = month, day = day, hour = hour, min = minute, sec = 0});

		
		if nowtime >= time then
			table.insert(resultlist, v);
		end
	end
	
	return resultlist, serverlist;
end

-- 第一次登录筛选一个服务器
function loginData:getFirstLoginServer()
	local serverlist = self:getServerlist();
	
	function sortLoginServer(data1, data2)
		local year1, month1, day1 = stringToDate(data1.date);
		local year2, month2, day2 = stringToDate(data2.date);
		local hour1, minute1 = stringToTime(data1.time);
		local hour2, minute2 = stringToTime(data2.time);
		
		wholesecond1 = os.time({year = year1, month = month1, day = day1, hour = hour1, min = minute1, sec = 0});
		wholesecond2 = os.time({year = year2, month = month2, day = day2, hour = hour2, min = minute2, sec = 0});
		
		return wholesecond1 > wholesecond2;
	end
	
	local newhotlist = {};
	local fulllist = {};
	
	for k,v in ipairs(serverlist) do
		if v.state == enum.SERVER_STATE.HOT or v.state == enum.SERVER_STATE.NEW then
			table.insert(newhotlist, v);
		else
			table.insert(fulllist, v);
		end
	end
	
	if #newhotlist > 0 then
		table.sort(newhotlist, sortLoginServer);
		return newhotlist[1].id;
	elseif #fulllist > 0 then
		table.sort(fulllist, sortLoginServer);
		return fulllist[1].id;
	else
		return nil;
	end

end

function loginData:recordEnterBackgroudTime()
	self.enterBackTime = dataManager.getServerTime();
end

function loginData:checkShouldGoBackLogin()
	local nowTime = dataManager.getServerTime();
	
	-- 10分钟就重新登录
	if nowTime - self.enterBackTime > 600 then
		
		-- 先弹出个loading，避免界面卡死，体验不好
		eventManager.dispatchEvent({name = global_event.LOADING_SHOW, notAutoHide = true});
		
		scheduler.performWithDelayGlobal(function() 
			GameClient.CGame:Instance():ResetGame();
		end, 1);

	end
end

-- 登录成功以后的处理
function loginData:onLoginSuccess()
	
	local lastReadRevengeTime = fio.readIni("idol", "lastReadRevengeTime", "0", global.getUserConfigFileName());
	
	dataManager.idolBuildData:setLastReadRevengeTime(tonumber(lastReadRevengeTime));
	
	eventManager.dispatchEvent({ name = global_event.LORGIN_SUCCESS });
	
	-- check werec ui
	local record = fio.readIni("system", "record", "off");
	local shellInterface = GameClient.CGame:Instance():getShellInterface();
	if shellInterface then
		if record == "on" then
			shellInterface:enableRecord(true);
		else
			shellInterface:enableRecord(false);
		end
	end
		
end

-- 设置是否登录了
function loginData:setLogin(setting)
	
	self.isLogin = setting;
	
end

function loginData:isLogin()
	
	return self.isLogin;
	
end

-- 设置断开的标志 
function loginData:setDisconectType(disType)
	
	self.disconectType = disType;
	
end

-- 判断是否需要重连，如果是某些被踢掉的情况不需要重连，比如封停
function loginData:isShouldReconnect()
	
	if self.disconectType == enum.LOGIN_RESULT.LOGIN_RESULT_FORBIN_BY_SERVER then
		return false;
	else
		return true;
	end
end
