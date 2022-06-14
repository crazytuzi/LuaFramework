local loginserver = class( "loginserver", layout );

global_event.LOGINSERVER_SHOW = "LOGINSERVER_SHOW";
global_event.LOGINSERVER_HIDE = "LOGINSERVER_HIDE";

	
local ITEM_COUNT_PER_TAB = 10;
	
function loginserver:ctor( id )
	loginserver.super.ctor( self, id );
	self:addEvent({ name = global_event.LOGINSERVER_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.LOGINSERVER_HIDE, eventHandler = self.onHide});
end

function loginserver:onShow(event)
	if self._show then
		return;
	end

	function onLoginServerClose()
		self:onHide();
	end
	
	self.lastserver = event.lastserver;
	
	self:Show();

	self.loginserver_huadong = LORD.toScrollPane(self:Child( "loginserver-huadong" ));
	self.loginserver_huadong:init();
	
	self.loginserver_tablist = LORD.toScrollPane(self:Child( "loginserver-tab" ));
	self.loginserver_tablist:init();
	
	self.loginserver_close = self:Child("loginserver-close");
	self.loginserver_close:subscribeEvent("ButtonClick", "onLoginServerClose");
	
	-- init tab list
	-- 第一个是推荐，后面的是大区列表 10 个一个tab
	self:initTabList();
	
	local defaultSelect = LORD.toRadioButton(self:Child("loginserver0_loginservertab"));
	defaultSelect:SetSelected(true);
end

function loginserver:onHide(event)
	self:Close();
end

function loginserver:onSelectTab(userdata)
	
	function onLoginServerClickServer(args)
		local window = LORD.toMouseEventArgs(args).window;
		local index = window:GetUserData();
		
		eventManager.dispatchEvent({name = "LOGIN_WIN_UI_UPDATE", selectserver = index, });
		
		self:onHide();
	end
	
	self.loginserver_huadong:ClearAllItem();
	
	local serverlist = dataManager.loginData:getServerlist();
			
	if userdata == 0 then
		--推荐
		local recommend = dataManager.loginData:getFirstLoginServer();
		
		if dataManager.loginData:getServerId() ~= "" then
			recommend = tonumber(dataManager.loginData:getServerId());
		end
		
		local configdata = serverlist[recommend];
		if configdata then
					
			local xpos = 0;
			local ypos = 0;
			local itemprefixname = "loginserver1";
			local item = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate(itemprefixname,"serveritem.dlg");
					
			item:SetPosition(LORD.UVector2(LORD.UDim(0, xpos), LORD.UDim(0, ypos)));
			self.loginserver_huadong:additem(item);
	
			local num = self:Child(itemprefixname.."_serveritem-num");
			local name = self:Child(itemprefixname.."_serveritem-name");
			local state = LORD.toStaticImage(self:Child(itemprefixname.."_serveritem-type"));
			
			num:SetText(configdata.id.."区");
			name:SetText(configdata.name);
			state:SetImage(enum.SERVER_STATE_IMAGE[configdata.state]);
			
			item:SetUserData(recommend);
			
			item:subscribeEvent("WindowTouchUp", "onLoginServerClickServer");
			
		end
	else
		
		local xpos = 0;
		local ypos = 0;
	
		--大区
		for i=1, ITEM_COUNT_PER_TAB do
				
				local serverid = (userdata-1)*ITEM_COUNT_PER_TAB + i;
				local configdata = serverlist[serverid];
				
				if configdata then
				
						local itemprefixname = "loginserver"..i;
						local item = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate(itemprefixname,"serveritem.dlg");
				
						local itemWidth = item:GetWidth();
						local itemHeight = item:GetHeight();
						
		
						if i%2==1 then
							xpos = 0;
						else
							xpos = itemWidth.offset;
						end
										
						item:SetPosition(LORD.UVector2(LORD.UDim(0, xpos), LORD.UDim(0, ypos)));
						self.loginserver_huadong:additem(item);
				
						if i%2==0 then
							ypos = ypos + itemHeight.offset + 10;
						end
						
						local num = self:Child(itemprefixname.."_serveritem-num");
						local name = self:Child(itemprefixname.."_serveritem-name");
						local state = LORD.toStaticImage(self:Child(itemprefixname.."_serveritem-type"));
						
						num:SetText(configdata.id.."区");
						name:SetText(configdata.name);
						state:SetImage(enum.SERVER_STATE_IMAGE[configdata.state]);
						
						item:SetUserData(serverid);
						
						item:subscribeEvent("WindowTouchUp", "onLoginServerClickServer");
						
				end
		end
		
	end
	
end

function loginserver:initTabList()
	
	function onLoginServerClickTab(args)
		
		local window = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
		local userdata =  window:GetUserData();
		if window:IsSelected() then
			self:onSelectTab(userdata);
		end
		
	end
	
	self.loginserver_tablist:ClearAllItem();
	
	local xpos = LORD.UDim(0, 10);
	local ypos = LORD.UDim(0, 0);
	
	local xoffset = LORD.UDim(0, 30);
	
	local tabitem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("loginserver0","loginservertab.dlg");
	tabitem:SetXPosition(xpos);
	tabitem:SetYPosition(ypos);
	tabitem:SetText("推  荐");
	tabitem:SetUserData(0);
	self.loginserver_tablist:additem(tabitem);
	xpos = xpos + tabitem:GetWidth() + xoffset;
	tabitem:subscribeEvent("RadioStateChanged", "onLoginServerClickTab");
	
	local serverlist = dataManager.loginData:getServerlist();
	local tabcount = math.floor(#serverlist/ITEM_COUNT_PER_TAB);
	
	if math.fmod(#serverlist, ITEM_COUNT_PER_TAB) ~= 0 then
		tabcount = tabcount + 1;
	end
	
	for i=tabcount, 1, -1 do
		
		local firstdata = serverlist[(i-1)*ITEM_COUNT_PER_TAB+1];

		local tabitem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("loginserver"..i,"loginservertab.dlg");
		tabitem:SetXPosition(xpos);
		tabitem:SetYPosition(ypos);
			
		tabitem:SetText(firstdata.tab);
		tabitem:SetUserData(i);
		self.loginserver_tablist:additem(tabitem);
		
		
		tabitem:subscribeEvent("RadioStateChanged", "onLoginServerClickTab");
		
		xpos = xpos + tabitem:GetWidth() + xoffset;
	end
	
end

return loginserver;
