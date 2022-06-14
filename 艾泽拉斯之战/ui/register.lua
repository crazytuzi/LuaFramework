local register = class( "register", layout );

global_event.REGISTER_SHOW = "REGISTER_SHOW";
global_event.REGISTER_HIDE = "REGISTER_HIDE";

		
function register:ctor( id )
	register.super.ctor( self, id );
	self:addEvent({ name = global_event.REGISTER_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.REGISTER_HIDE, eventHandler = self.onHide});
end

function register:onShow(event)
	if self._show then
		return;
	end

    function onRegisterOK()
        -- copy from loginWin.lua function onClickLogin()
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
        
	    -- 账号密码登录方式
		local account = self.accountEdit:GetText();
		local password1 = self.password1Edit:GetText();
        local password2 = self.password2Edit:GetText();
        local phoneNum = self.phoneNumEdit:GetText();
		local data = dataManager.loginData:getServerDataFromCustomList(self.lastserver);
		
        if account == "" then
             eventManager.dispatchEvent({name = global_event.MESSAGEBOX_SHOW, 
				textInfo = "请输入账号名！", callBack = callBack}); 
            return;
        end;	
        
        if password1 == "" then
              eventManager.dispatchEvent({name = global_event.MESSAGEBOX_SHOW, 
				textInfo = "请输入密码！", callBack = callBack}); 
            return;
        end;	

        if not(password1 == password2) then
            eventManager.dispatchEvent({name = global_event.MESSAGEBOX_SHOW, 
				textInfo = "两次密码不一致！", callBack = callBack}); 
            return;
        end

		if account == string.match(account, "^%a+[%w_]*") and data then
			print("regist:  "..account.."  password:  "..password1.."phoneNum"..phoneNum.."ipAndPort  "..data.ipAndPort);
 				
			dataManager.loginData:setUserName(account);
            dataManager.loginData:setPassWord(password1);
			dataManager.loginData:setServerId(self.lastserver);
            dataManager.loginData:setPhoneNum(phoneNum);
				
			dataManager.loginData:regist(false);
           
		else
			self.accountEdit:SetText("");
		end
						
    end

	function onRegisterClose()
		self:onHide();
	end
	self:Show();

	self.register_ok = self:Child("register-ok");
	self.register_ok:subscribeEvent("ButtonClick", "onRegisterOK");

	self.register_close = self:Child("register-close");
	self.register_close:subscribeEvent("ButtonClick", "onRegisterClose");

    self.accountEdit = self:Child("register-account-edit");
 	self.password1Edit = self:Child("register-password1-edit");
    self.password2Edit = self:Child("register-password2-edit");
    self.phoneNumEdit = self:Child("register-cell-edit");

    self.lastserver = dataManager.loginData:getServerId();

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

function register:onHide(event)
	self:Close();
end

return register;
