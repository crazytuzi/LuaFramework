
local loginWinuiclass = class("loginWinuiclass",layout)

global_event.LOGIN_WIN_UI_SHOW = "LOGIN_WIN_UI_SHOW";
global_event.LOGIN_WIN_UI_HIDE = "LOGIN_WIN_UI_HIDE";
global_event.LOGIN_WIN_UI_UPDATE = "LOGIN_WIN_UI_UPDATE";
global_event.LOGIN_WIN_ENABLE_LOGIN = "LOGIN_WIN_ENABLE_LOGIN";

function loginWinuiclass:ctor( id )
	 loginWinuiclass.super.ctor(self,id)	
	 self:addEvent({ name = global_event.LOGIN_WIN_UI_SHOW, eventHandler = self.onShow})				
	 self:addEvent({ name = global_event.LOGIN_WIN_UI_HIDE, eventHandler = self.onHide})
	 self:addEvent({ name = global_event.LOGIN_WIN_UI_UPDATE, eventHandler = self.onUpdate})
	 self:addEvent({ name = global_event.LOGIN_WIN_ENABLE_LOGIN, eventHandler = self.onEnableLogin})
end	

function loginWinuiclass:onShow(event)

	self:Show();	
	
	-- check sdk 如果是sdk登录的方式 就没有输入框，只有登录按钮
	local loginWin_container = self:Child("loginWin-container");
	local loginWin_LoginButton = self:Child("loginWin-LoginButton");
    local loginWin_Regist = self:Child("loginWin-registerButton");
	local currentPlatform = GameClient.CGame:Instance():getPlatformInfo();
	if currentPlatform ~= "test" then
		loginWin_container:SetVisible(false);
		
		local ypos = loginWin_LoginButton:GetYPosition();
		loginWin_LoginButton:SetYPosition(ypos - LORD.UDim(0, 80));
	end
	
	local shellInterface = GameClient.CGame:Instance():getShellInterface();
	if shellInterface then
		shellInterface:login();
	end
	
	function  onClickLogin()
		
		local data = dataManager.loginData:getServerDataFromCustomList(self.lastserver);
		if data == nil then
			-- 没有一个服务器开启
			-- find new time;
			local reallist, alllist = dataManager.loginData:getServerlist();
			if alllist and alllist[1] then
				local nearestTimeData = alllist[1];
				eventManager.dispatchEvent({name = global_event.MESSAGEBOX_SHOW, 
					textInfo = nearestTimeData.date.." "..nearestTimeData.time.."开放服务器", callBack = function() 
					end});
			end
			
			return;
		end
		
		local shellInterface = GameClient.CGame:Instance():getShellInterface();
		if shellInterface and shellInterface:isLoginFromSdk() then

			local sdkJson = dataManager.loginData:getLoginJson();
		
			if sdkJson == "" then
				sdkJson = "{}";
			end
			
			local sdkTable = json.decode(sdkJson);
			if sdkTable == nil then
				sdkTable = {};
			end

			-- sdk 验证登录方式
			if sdkTable.playerID == ""  or sdkTable.playerID == nil then
				-- 弹出确认框，先确认是否不登陆gamecenter
				eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
				text = "请先登陆Game Center, 再进行游戏！", callBack = function() 
					
					shellInterface:enterUserCenter();

				end, callOnCancel = function()
					
					--dataManager.loginData:setServerId(self.lastserver);
					--dataManager.loginData:login(false);

				end});	

				return;
			else
				
				dataManager.loginData:setServerId(self.lastserver);
				dataManager.loginData:login(false);
				
			end
			
		else
			-- 账号密码登录方式
			local account = self.accountEdit:GetText();
			local password = self.passwordEdit:GetText();
			local data = dataManager.loginData:getServerDataFromCustomList(self.lastserver);
			
            -- zhouyou
            -- 190917775@qq.com 就不能通过match	
            -- if account == string.match(account, "^%a+[%w_]*") and data then
            if data then
				print("account:  "..account.."  password:  "..password.."ipAndPort  "..data.ipAndPort);
 				
				dataManager.loginData:setUserName(account);
                dataManager.loginData:setPassWord(password);
				dataManager.loginData:setServerId(self.lastserver);
				
				dataManager.loginData:login(false);
				
			else
				self.accountEdit:SetText("");
			end
						
		end
 
	end
	
	function onServerList()
		eventManager.dispatchEvent({name = "LOGINSERVER_SHOW", lastserver = self.lastserver, });
	end

    function onRegist()
        eventManager.dispatchEvent({name = "REGISTER_SHOW"});
    end
	
	self:Child("loginWin-LoginButton"):subscribeEvent("ButtonClick", "onClickLogin")
 	self:Child("loginWin-server"):subscribeEvent("ButtonClick", "onServerList")
    self:Child("loginWin-registerButton"):subscribeEvent("ButtonClick", "onRegist");
 	
 	self.accountEdit = self:Child("loginWin-LoginAccount");
 	self.passwordEdit = self:Child("loginWin-LoginPassword");
 	
	self.accountEdit:SetText(dataManager.loginData:getUserName());
	self.lastserver = dataManager.loginData:getServerId();
    self.passwordEdit:SetText(dataManager.loginData:getPassWord());
	
	self:Child("loginWin-num"):SetText("");
	self:Child("loginWin-name"):SetText("");
			
	if self.lastserver == "" then
		--eventManager.dispatchEvent({name = "LOGIN_SERVER_UI_SHOW", lastserver = nil, });
	
		-- todo 第一次登录 选择一个服务器
		self.lastserver = dataManager.loginData:getFirstLoginServer();
		
		dataManager.loginData:setServerId(self.lastserver);
		
	end
	
	self.lastserver = tonumber(self.lastserver);
	local serverlist = dataManager.loginData:getServerlist();
	data = serverlist[self.lastserver];

	if data == nil then
		data = serverlist[1];
		self.lastserver = 1;
	end
	
	if data then	
		self:Child("loginWin-num"):SetText(data.id.."区");
		self:Child("loginWin-name"):SetText(data.name);
	end
end

function loginWinuiclass:onHide(event)
	self:Close();
end

function loginWinuiclass:onUpdate(event)
	self.lastserver = event.selectserver;

	local data = dataManager.loginData:getServerDataFromCustomList(self.lastserver);
	
	if data then
			self:Child("loginWin-num"):SetText(data.id.."区");
			self:Child("loginWin-name"):SetText(data.name);
	end

end

function loginWinuiclass:onEnableLogin(event)
	print("onEnableLogin");
	if self._show then
		self:Child("loginWin-LoginButton"):SetEnabled(event.enabled);
	end
end

return loginWinuiclass