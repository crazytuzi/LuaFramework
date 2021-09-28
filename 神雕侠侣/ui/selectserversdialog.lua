require "ui.dialog"
require "ui.selectserversdialogcell"
require "config"
require "ui.newswarndlg"
require "ui.loginwaitingdialog"
require "ui.selectserversareacell"

g_bPopedWarnNotEnouMem = false
SelectServersDialog = {}
setmetatable(SelectServersDialog, Dialog)
SelectServersDialog.__index = SelectServersDialog 
SelectServersDialog.MAX_AREA_CNT = 10

local OPEN_NEWS_HAVE_OPEN = false
local OPEN_NEWS_TIME = 0

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function SelectServersDialog.getInstance()
	print("enter getinstance")

    if not _instance then
        _instance = SelectServersDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function SelectServersDialog.getInstanceAndShow()
	print("____SelectServersDialog.getInstanceAndShow")
    if not _instance then
        _instance = SelectServersDialog:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
 --    if Config.MOBILE_ANDROID ~= 1 or Config.CUR_3RD_LOGIN_SUFFIX ~= "ad91" then
	-- 	if NewsWarnDlg.GetLatestNewsWarn() then
	-- 		NewsWarnDlg.getInstanceAndShow()
	-- 	end
	-- end
    return _instance
end

function SelectServersDialog.getInstanceNotCreate()
    return _instance
end

function SelectServersDialog.DestroyDialog()
	if _instance then 
		GetLoginManager():ClearConnections()
		_instance:OnClose() 
		_instance = nil
	end
end

function SelectServersDialog.ToggleOpenClose()
	if not _instance then 
		_instance = SelectServersDialog:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
----/////////////////////////////////////////------

local SERVER_INFO_INI = "LastServerAccount.ini"

function SelectServersDialog.GetLayoutFileName()
    return "selectserversnew.layout"
end

function SelectServersDialog:OnCreate()
	print("enter SelectServersDialog oncreate")
	require "ui.crossserver.crossservermanager"

	if Config.CUR_3RD_LOGIN_SUFFIX == "lawp" then
		SERVER_INFO_INI = ".LastServerAccount.ini"
	else
		SERVER_INFO_INI = "LastServerAccount.ini"
	end

	if CrossServerManager.getInstanceNotCreate() then
		local account = CrossServerManager.getInstanceNotCreate().m_account
		local key = CrossServerManager.getInstanceNotCreate().m_ticket
		local host = CrossServerManager.getInstanceNotCreate().m_crossip
		local port = CrossServerManager.getInstanceNotCreate().m_crossport
		local suffix = Config.CUR_3RD_LOGIN_SUFFIX
		if Config.MOBILE_ANDROID == 1 then
			suffix = SDXL.ChannelManager:GetPlatformLoginSuffix()
		end	
		LogInfo("key = " .. key)
		GetGameApplication():CreateCrossConnection(account, key, host, port) 
		CrossServerManager.Destroy()
		_instance = nil
		return
	end
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    winMgr:getWindow("selectserversnewNew"):subscribeEvent("WindowUpdate", SelectServersDialog.run ,self)

    self.m_OKBtn = 
		CEGUI.Window.toPushButton(winMgr:getWindow("selectserversnew/gotogame") )
    self.m_ReturnBtn = 
		CEGUI.Window.toPushButton(winMgr:getWindow("selectserversnew/backtolog") )
    self.m_ServerListBack = 
		CEGUI.Window.toScrollablePane(winMgr:getWindow("selectserversnew/back/Bot") )
	self.m_AreaListBack = 
		CEGUI.Window.toScrollablePane(winMgr:getWindow("selectserversnew/back/Top/areaback") )
	self.m_LastServerBtn = 
		CEGUI.toGroupButton(winMgr:getWindow("selectserversnew/back/newinfo/severs/btn0") )
	self.m_NewServerBtn = 
		CEGUI.toGroupButton(winMgr:getWindow("selectserversnew/back/newinfo/severs/btn1") )

	self.m_LastServerTxt = winMgr:getWindow("selectserversnew/back/newinfo/severs/btn/name0")
	self.m_LastServerHead = winMgr:getWindow("selectserversnew/back/newinfo/severs/btn/icon0")
	self.m_LastServerLevel = winMgr:getWindow("selectserversnew/back/newinfo/severs/btn/level0")
	self.m_LastServerState = winMgr:getWindow("selectserversnew/back/newinfo/severs/pic/state0")
	self.m_NewServerTxt = winMgr:getWindow("selectserversnew/back/newinfo/severs/btn/name1")
	self.m_NewServerHead = winMgr:getWindow("selectserversnew/back/newinfo/severs/btn/icon1")
	self.m_NewServerLevel = winMgr:getWindow("selectserversnew/back/newinfo/severs/btn/level1")
	self.m_NewServerState = winMgr:getWindow("selectserversnew/back/newinfo/severs/pic/state1")

	self.m_AreaListBack:EnableHorzScrollBar(true)

    -- subscribe event
    self.m_OKBtn:subscribeEvent("Clicked", 
			SelectServersDialog.HandleOKBtnClicked, self) 
    self.m_ReturnBtn:subscribeEvent("Clicked",
			SelectServersDialog.HandleReturnBtnClicked, self)
    self.m_LastServerBtn:subscribeEvent("MouseButtonDown",
    		SelectServersDialog.HandleLastButtonClicked ,self)
    self.m_NewServerBtn:subscribeEvent("MouseButtonDown",
    		SelectServersDialog.HandleNewButtonClicked ,self)

	-- init settings

	self:OnInit()
	self:InitAreaList()
	self:LoadServerRoleInfoFromIni()
	self:InitLastSelectAreaAndServer()
	self:SetLastServerAreaSelected()
	self:CheckServersLoad()
	self:ClearAllServerCells()
	self:RefreshServerCells(self.m_SelectArea, self.m_SelectAreaID)
	self:DeselectAllServerBtn()
	self.m_LastServerBtn:setSelected(true)

	if Config.TRD_PLATFORM == 1 then
		if Config.CUR_3RD_PLATFORM == "app" then
			self.m_ReturnBtn:setVisible(false)
		end
	end
    
    --added by xiaolong for android free mem not enough warnning
	 if not g_bPopedWarnNotEnouMem then
	        local typeDevice = CDeviceInfo:GetDeviceType()
	        --android device
	        if  typeDevice == 2 then
	            local freeMemSize = CDeviceInfo:GetFreeMemSize()
	            if freeMemSize > 0 and freeMemSize < 60 then
	                g_bPopedWarnNotEnouMem = true
	                GetGameUIManager():AddMessageTipById(145139)
	            end
	        end
	 end

	print("exit SelectServersDialog OnCreate")
end

------------------- private: -----------------------------------

function SelectServersDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SelectServersDialog)

    return self
end

----/////////////////////////////////////////------
--
function SelectServersDialog:HandleOKBtnClicked(args)
    print("ok btn clicked, area " .. self.m_SelectArea .. " server " .. self.m_SelectServerKey)  
	--获取当前选中大区和服
	local selectedAreaInfo = self.m_AreaServersMap[self.m_SelectArea]
	if not selectedAreaInfo then 
		print("area info null")
		return 
	end

	for k,v in pairs(selectedAreaInfo.servers) do
		if v["serverid"] == self.m_SelectServerKey or v["servername"] == self.m_SelectServer then
			selectedServerInfo = v
		end
	end
	self.m_SelectServer = selectedServerInfo["servername"]
	if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "azhi" then
		local luaj = require "luaj"
		local tempTable = {}
		tempTable[1] = self.m_SelectServer
		luaj.callStaticMethod("com.wanmei.mini.condor.anzhi2.AnzhiPlatform", "setArea", tempTable, nil)
	end

	--获取端口
	local lowport = tonumber(selectedServerInfo.port)
	local highport = lowport + tonumber(selectedServerInfo.portnum) - 1
	highport = math.max(lowport, highport)

	print("lowport " .. lowport .. " highport " .. highport)
	local port = StringCover.randBetween(lowport, highport)
	local ip = selectedServerInfo.ip

	local cmode = selectedServerInfo["cmode"] or 0
	local gip = selectedServerInfo["gip"] or ""
	local gport = port or ""

	GetLoginManager():SetSelectServerInfo(self.m_SelectArea, self.m_SelectServer, ip, tostring(port), 0)
	GetLoginManager():Init()

	if Config.TRD_PLATFORM==1 then
			LogInfo("select server handle ok 3rd")
			LoginWaitingDialog.getInstanceAndShow()

			local account = GetLoginManager():GetAccount()
			local key = GetLoginManager():GetPassword()
			local host = GetLoginManager():GetHost()
			local port = GetLoginManager():GetPort()
			local suffix = Config.CUR_3RD_LOGIN_SUFFIX
			if Config.MOBILE_ANDROID == 1 then
				suffix = SDXL.ChannelManager:GetPlatformLoginSuffix()
			end	

			if cmode == 0 then
				GetGameApplication():CreateConnection(account, key, host, port, true, self.m_SelectServer, self.m_SelectArea, authc.Login.AT_AUANY,suffix)
			else
				GetGameApplication():CreateConnection(account, key, host, port, true, self.m_SelectServer, self.m_SelectArea, authc.Login.AT_AUANY,suffix, cmode, gip, gport) 
			end

			local strIniPath = SERVER_INFO_INI
			local iniMgr = CIniManager(strIniPath)
			LogInfo("createconnection write " .. strIniPath .. tostring(self.m_SelectAreaID) .. " " .. self.m_SelectServerKey)
			iniMgr:WriteValueByName("ServerArea", "id", tostring(self.m_SelectAreaID))
			iniMgr:WriteValueByName("Server", "id", tostring(self.m_SelectServerKey))
	else
		LogInfo("select server handle ok no 3rd")
		LoginDialog.getInstanceAndShow()
		local strIniPath = SERVER_INFO_INI
		local iniMgr = CIniManager(strIniPath)
	    LogInfo("createconnection write " .. strIniPath .. tostring(self.m_SelectAreaID) .. " " .. self.m_SelectServerKey)
		iniMgr:WriteValueByName("ServerArea", "id", tostring(self.m_SelectAreaID))
		iniMgr:WriteValueByName("Server", "id", tostring(self.m_SelectServerKey))
	end

	self:DestroyDialog()
    
    return true
end

function SelectServersDialog:HandleReturnBtnClicked(args)
    print("return btn clicked") 
	if Config.TRD_PLATFORM==1 then
		SDXL.ChannelManager:ChangeUserLogin()
	else
		LoginDialog.getInstanceAndShow()
	end

	SelectServersDialog.DestroyDialog()
    return true
end

function SelectServersDialog:HandleAreaClicked(args)
    print("enter SelectServersDialog:HandleAreaClicked") 
	local selectedgbtn = self.m_Area[1]:getSelectedButtonInGroup()
	if not selectedgbtn then return end

	self.m_ShowArea = selectedgbtn:getText()
	self.m_ShowAreaID = selectedgbtn:getID()
	self.m_SelectArea = selectedgbtn:getText()
	self.m_SelectAreaID = selectedgbtn:getID()

	self:ClearAllServerCells()
	self:RefreshServerCells(selectedgbtn:getText(), selectedgbtn:getID())

    return true
end

function SelectServersDialog:HandleSelectServerStateChanged(args)
    print("enter SelectServersDialog:HandleSelectServerStateChanged") 

	local eventargs = CEGUI.toWindowEventArgs(args)
	self.m_SelectArea = self.m_ShowArea
	self.m_SelectAreaID = self.m_ShowAreaID
	self.m_SelectServerKey = eventargs.window:getID()
	self.m_SelectServer = eventargs.window:getText()

	self.m_LastServerBtn:setSelected(false)
	self.m_NewServerBtn:setSelected(false)

	self:DeselectOtherServerBtn()

	print("select server key " .. self.m_SelectServerKey)

    return true
end

function SelectServersDialog:HandleSelectAreaStateChanged(args)
    print("enter SelectServersDialog:HandleSelectAreaStateChanged") 

	local eventargs = CEGUI.toWindowEventArgs(args)

	self.m_ShowArea = eventargs.window:getText()
	self.m_ShowAreaID = eventargs.window:getID()
	self.m_SelectAreaID = eventargs.window:getID()
	self.m_SelectArea = eventargs.window:getText()

	self.m_LastServerBtn:setSelected(false)
	self.m_NewServerBtn:setSelected(false)

	self:DeselectOtherAreaBtn()
	print("select area key " .. self.m_SelectAreaID)

	self:ClearAllServerCells()
	self:RefreshServerCells(self.m_SelectArea, self.m_SelectAreaID)

	-- print("select server key " .. self.m_SelectServerKey)

    return true
end

function SelectServersDialog:HandleLastButtonClicked(args)
    print("enter SelectServersDialog:HandleLastButtonClicked")

    self.m_SelectArea = self.m_LastArea
    self.m_SelectAreaID = self.m_LastAreaID
    self.m_SelectServer = self.m_LastServer
    self.m_SelectServerKey = self.m_LastServerKey

	self:DeselectAllServerBtn()
	self.m_LastServerBtn:setSelected(true)
	print("select area key " .. self.m_SelectAreaID)

    return true
end

function SelectServersDialog:HandleNewButtonClicked(args)
    print("enter SelectServersDialog:HandleNewButtonClicked")

    self.m_SelectArea = self.m_NewArea
    self.m_SelectAreaID = self.m_NewAreaID
    self.m_SelectServer = self.m_NewServer
    self.m_SelectServerKey = self.m_NewServerKey

	self:DeselectAllServerBtn()
	self.m_NewServerBtn:setSelected(true)
	print("select area key " .. self.m_SelectAreaID)

    return true
end

-------------------------------------------------------------
----/////////////////////////////////////////------
--初始化，读取serverconfig.xml
function SelectServersDialog:OnInit()
	print("enter OnInit , read serverconfig.xml")
	self.m_AreaServersMap =  {}
	-- self.m_SelectAreaID = 1
	-- self.m_SelectServerKey = 0

	local fr = XMLIO.CFileReader()
	local serverConfigFileName = "/cfg/serverconfig.bin"
	if Config.CUR_3RD_LOGIN_SUFFIX == "efad" or Config.CUR_3RD_LOGIN_SUFFIX == "efis" then
		serverConfigFileName = "/cfg/serverconfig.bin"
	else
		if Config.MOBILE_ANDROID == 1 then
			if Config.CUR_3RD_LOGIN_SUFFIX == "txqq" then
				serverConfigFileName = "/cfg/serverconfigTecent.bin"
            elseif Config.CUR_3RD_LOGIN_SUFFIX == "lngz" then
                serverConfigFileName = "/cfg/serverconfiglongzhong.bin"
            elseif Config.CUR_3RD_LOGIN_SUFFIX == "twap" then
                serverConfigFileName = "/cfg/serverconfig_twapp01.bin"
            elseif Config.CUR_3RD_LOGIN_SUFFIX == "tw36" then
                serverConfigFileName = "/cfg/serverconfig_tw360.bin"
			else
				serverConfigFileName = "/cfg/serverconfig_android.bin"
			end
		elseif Config.TRD_PLATFORM == 1 then
			if Config.CUR_3RD_LOGIN_SUFFIX == "lahu" then
				serverConfigFileName = "/cfg/serverconfig_app.bin"
			elseif Config.CUR_3RD_LOGIN_SUFFIX == "lawp" then
				serverConfigFileName = "/cfg/serverconfig_wp.bin"
			else
				serverConfigFileName = "/cfg/serverconfig_ios.bin"
			end
		end
	end

	if fr:OpenFile(serverConfigFileName) ~= XMLIO.EC_SUCCESS then
		print("open serverconfig.xml error!")
		return
	end

	print("open serverconfig.xml ok")
	local root = XMLIO.CINode(), rval;
	rval = fr:GetRootNode(root)
	if not rval then
		fr:CloseFile()
		fr = nil
		return
	end

	print("serverxml area node total cnt  " .. root:GetChildrenCount())
	for i=1,root:GetChildrenCount() do
		LogInfo("serverxml area node cnt  " .. i)

		local typenode = XMLIO.CINode()
		rval = root:GetChildAt(i-1, typenode)

		if typenode:GetType() == XMLIO.NT_ELEMENT then
			local rval, areaname,areaid, areadesc, arearec,nullnode = false, "" , 0,  "", "0",""
			rval, nullnode, areaid = typenode:GetAttribute("id", nullnode);
			rval, nullnode, areaname = typenode:GetAttribute("name", nullnode);
			rval, nullnode, areadesc = typenode:GetAttribute("desc", nullnode);
			rval, nullnode, arearec = typenode:GetAttribute("rec", nullnode);

			LogInfo("area " .. areaname .. "desc " .. areadesc )

			self.m_AreaServersMap[areaname] =  {}
			self.m_AreaServersMap[areaname].id =  areaid
			self.m_AreaServersMap[areaname].servers =  {}
			self.m_AreaServersMap[areaname].areadesc = areadesc
			self.m_AreaServersMap[areaname].arearec = arearec

			local rec_server = 1
			local min_status = 4
			LogInfo("serverxml server node total cnt  " .. typenode:GetChildrenCount())
			for i_child= 1,typenode:GetChildrenCount() do
				LogInfo("serverxml server node cnt  " .. i_child)

				local rval, serveridstr, serverid,nullnode, showtimestr = false,"0", 0, "", ""
				local itemnode = XMLIO.CINode()
				rval =  typenode:GetChildAt(i_child-1, itemnode)
	
				local rval, nullnode, showtimestr = itemnode:GetAttribute("showtime", nullnode)
				local show = true
				if showtimestr ~= "0" then
					local showyear, showmonth, showday, showhour, showminute, showsecond = showtimestr:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
					local showtime = os.time({year=showyear, month=showmonth, day=showday, hour=showhour, min=showminute, sec=showsecond})
					if showtime > os.time() then	
						show = false
					end
				end

				if show then
					rval, nullnode,serveridstr = itemnode:GetAttribute("id", nullnode)
					serverid = tonumber(serveridstr)
					self.m_AreaServersMap[areaname].servers[i_child] = {}

					rval, nullnode, self.m_AreaServersMap[areaname].servers[i_child]["servername"] 
						= itemnode:GetAttribute("servername", nullnode)
					rval, nullnode, self.m_AreaServersMap[areaname].servers[i_child]["ip"] 
						= itemnode:GetAttribute("ip", nullnode)
					rval, nullnode, self.m_AreaServersMap[areaname].servers[i_child]["port"] 
						= itemnode:GetAttribute("port", nullnode)
					rval, nullnode, self.m_AreaServersMap[areaname].servers[i_child]["desc"] 
						= itemnode:GetAttribute("desc", nullnode)
					rval, nullnode, self.m_AreaServersMap[areaname].servers[i_child]["portnum"] 
						= itemnode:GetAttribute("portnum", nullnode)
					rval, nullnode, self.m_AreaServersMap[areaname].servers[i_child]["status"] 
						= itemnode:GetAttribute("status", nullnode)
					rval, nullnode, self.m_AreaServersMap[areaname].servers[i_child]["opentime"] 
						= itemnode:GetAttribute("opentime", nullnode)
					rval, nullnode, self.m_AreaServersMap[areaname].servers[i_child]["descopened"] 
						= itemnode:GetAttribute("descopened", nullnode)
					rval, nullnode, self.m_AreaServersMap[areaname].servers[i_child]["cmode"] 
						= itemnode:GetAttribute("cmode", nullnode)
					if rval == false then
						self.m_AreaServersMap[areaname].servers[i_child]["cmode"] = nil
					else
						rval, nullnode, self.m_AreaServersMap[areaname].servers[i_child]["gip"] 
							= itemnode:GetAttribute("gip", nullnode)
						rval, nullnode, self.m_AreaServersMap[areaname].servers[i_child]["gport"] 
							= itemnode:GetAttribute("gport", nullnode)

					end
					self.m_AreaServersMap[areaname].servers[i_child]["serverid"] = serverid

					if tonumber(self.m_AreaServersMap[areaname].servers[i_child]["status"]) < min_status then
						min_status = tonumber(self.m_AreaServersMap[areaname].servers[i_child]["status"])
						rec_server = i_child 
					end
				end
			end

			if require"utils.tableutil".tablelength(self.m_AreaServersMap[areaname].servers) == 0 then
				self.m_AreaServersMap[areaname] = nil	
			else
				if arearec == "1" then
					self.m_RecArea = areaid 
				end
				self.m_AreaServersMap[areaname].rec_server = self.m_AreaServersMap[areaname].servers[rec_server]["servername"]
			end
		end
	end

	LogInfo("xml server size ".. table.getn(self.m_AreaServersMap))

	fr:CloseFile()
	fr = nil
end
-------------------------------------------------------------
----/////////////////////////////////////////------
-------------------------------------------------------------
----/////////////////////////////////////////------
--读取上次选区选服配置

function SelectServersDialog:InitLastSelectAreaAndServer()
	for k,v in pairs(self.m_AreaServersMap) do
		if v.arearec == "1" then
			self.m_NewArea = k
			self.m_NewAreaID = v.id
		end
	end

	if self.m_NewArea == nil then
		for k,v in pairs(self.m_AreaServersMap) do
			if v.id == "1" then
				self.m_NewArea = k
				self.m_NewAreaID = v.id
			end
		end
	end


	for k,v in pairs(self.m_AreaServersMap[self.m_NewArea].servers) do
		if v["status"] == "1" then
			self.m_NewServer = v["servername"]
			self.m_NewServerKey = v["serverid"]
			break
		end

		if self.m_NewServerKey == nil then
			self.m_NewServer = v["servername"]
			self.m_NewServerKey = v["serverid"]
		elseif self.m_NewServerKey < v["serverid"] then
			self.m_NewServer = v["servername"]
			self.m_NewServerKey = v["serverid"]
		end
	end

	local strIniPath = SERVER_INFO_INI
	local iniMgr = CIniManager(strIniPath)

	local bExist, strArea,areaID, serverID,nullarea, nullserver = false, "","0","0"
	bExist, nullarea, nullserver, strArea = iniMgr:GetValueByName("ServerArea", "area", "")
	if bExist then
		self.m_LastArea = strArea
		print("last select area " .. strArea)
	end
	bExist, nullarea, nullserver, areaID = iniMgr:GetValueByName("ServerArea", "id", "")
	if bExist then
		self.m_LastAreaID = tonumber(areaID)
		print("last select areaid " .. areaID)
	end

	bExist, nullarea, nullserver, strServer = iniMgr:GetValueByName("Server", "server", "")
	if bExist then
		self.m_LastServer = strServer
		print("last select server " .. strServer)
	end
	bExist, nullarea, nullserver, serverID = iniMgr:GetValueByName("Server", "id", "")
	if bExist then
		self.m_LastServerKey = tonumber(serverID)
		print("last select serverkey " .. serverID)
	end

	if self.m_LastArea ~= nil and self.m_LastAreaID == nil then
		if self.m_AreaServersMap[self.m_LastArea] ~= nil then
			self.m_LastAreaID = self.m_AreaServersMap[self.m_LastArea].id
			print("Reset LastAreaID: " .. self.m_LastAreaID)
		end
	end
	if self.m_LastArea == nil and self.m_LastAreaID ~= nil then
		for k,v in pairs(self.m_AreaServersMap) do
			if tonumber(v.id) == self.m_LastAreaID then
				self.m_LastArea = k
				print("Reset LastArea: " .. self.m_LastArea)
			end
		end
	end

	if self.m_LastServer ~= nil and self.m_LastServerKey == nil then
		for k,v in pairs(self.m_AreaServersMap) do
			for sk,sv in pairs(v.servers) do
				if sv["servername"] == self.m_LastServer then
					self.m_LastServerKey = sv["serverid"]
					print("Reset LastServerKey: " .. self.m_LastServerKey)
				end
			end
		end
	end
	if self.m_LastServer == nil and self.m_LastServerKey ~= nil then
		for k,v in pairs(self.m_AreaServersMap) do
			for sk,sv in pairs(v.servers) do
				if sv["serverid"] == self.m_LastServerKey then
					self.m_LastServer = sv["servername"]
					print("Reset LastServer: " .. self.m_LastServer)
				end
			end
		end
	end

	if self.m_LastServerKey == nil or self.m_LastServer == nil or self.m_LastArea == nil or self.m_LastAreaID == nil or self.m_AreaServersMap[self.m_LastArea] == nil then
		print("Set last server info with new server")
		self.m_LastArea = self.m_NewArea
		self.m_LastAreaID = self.m_NewAreaID
		self.m_LastServer = self.m_NewServer
		self.m_LastServerKey = self.m_NewServerKey
	end

	self.m_SelectArea = self.m_LastArea
	self.m_SelectAreaID = self.m_LastAreaID
	self.m_SelectServer = self.m_LastServer
	self.m_SelectServerKey = self.m_LastServerKey
	self.m_ShowArea = self.m_SelectArea
	self.m_ShowAreaID = self.m_SelectAreaID
end

--读取server role info
function SelectServersDialog:LoadServerRoleInfoFromIni()
	local strIniPath = SERVER_INFO_INI
	local iniMgr = CIniManager(strIniPath)

	self.m_AccountInfo = {}
	local bExist, strValue, nullSection, nullServer = false, ""
	bExist, nullSection, nullName, strValue = iniMgr:GetValueByName("AccountInfo", "num", "0")
	print("AccountInfo num " .. strValue)
	local accountnum = tonumber(strValue)

	for index = 1, accountnum do
		bExist, nullSection, nullName, strValue = iniMgr:GetValueByName("Account" .. index, "username", "")
		print("Account" .. index .. " username " .. strValue)
		if strValue ~= "" then
			local actname = strValue
			self.m_AccountInfo[actname] = {}

			bExist, nullSection, nullName, strValue = iniMgr:GetValueByName("Account" .. index, "servernum", "0")
			for server_idx = 1, tonumber(strValue) do
				bExist, nullSection, nullName, strValue = iniMgr:GetValueByName("Account" .. index, "server" .. server_idx .. "name", "")
				print("Account" .. index .. " servername" .. strValue)
				if strValue ~= "" then
					local servername = strValue
					self.m_AccountInfo[actname][servername] = {}
					bExist, nullSection, nullName, strValue = iniMgr:GetValueByName("Account" .. index, "server" .. server_idx .. "lvl", "1") 
					print("Account" .. index .. " serverlevel " .. strValue)
					self.m_AccountInfo[actname][servername]["lvl"] = strValue
					bExist, nullSection, nullName, strValue = iniMgr:GetValueByName("Account" .. index, "server" .. server_idx .. "icon", "0") 
					print("Account" .. index .. " servericon " .. strValue) 
					self.m_AccountInfo[actname][servername]["icon"] = tonumber(strValue)
					bExist, nullSection, nullName, strValue = iniMgr:GetValueByName("Account" .. index, "server" .. server_idx .. "id", "0") 
					print("Account" .. index .. " serverid " .. strValue) 
					self.m_AccountInfo[actname][servername]["id"] = tonumber(strValue)
				end
			end
		end
	end
end
-------------------------------------------------------------
----/////////////////////////////////////////------
--设置上次选中服务大区,且设置大区控件信息
function SelectServersDialog:SetLastServerAreaSelected()

	self.m_LastServerTxt:setText(self.m_LastServer)
	self.m_NewServerTxt:setText(self.m_NewServer)

	local username = GetLoginManager():GetAccount()
	if self.m_AccountInfo[username] ~= nil then
		if self.m_AccountInfo[username][self.m_LastServer] ~= nil then
			self.m_LastServerHead:setProperty("Image", GetIconManager():GetImagePathByID(self.m_AccountInfo[username][self.m_LastServer]["icon"]):c_str())
			self.m_LastServerLevel:setText("Lv" .. self.m_AccountInfo[username][self.m_LastServer]["lvl"])
		else
			self.m_LastServerHead:setVisible(false)
			self.m_LastServerLevel:setVisible(false)
		end

		if self.m_AccountInfo[username][self.m_NewServer] ~= nil then
			self.m_NewServerHead:setProperty("Image", GetIconManager():GetImagePathByID(self.m_AccountInfo[username][self.m_NewServer]["icon"]):c_str())
			self.m_NewServerLevel:setText("Lv" .. self.m_AccountInfo[username][self.m_NewServer]["lvl"])
		else
			self.m_NewServerHead:setVisible(false)
			self.m_NewServerLevel:setVisible(false)
		end
	else
		self.m_LastServerHead:setVisible(false)
		self.m_LastServerLevel:setVisible(false)
		self.m_NewServerHead:setVisible(false)
		self.m_NewServerLevel:setVisible(false)
	end
	self:DeselectAllServerBtn()
	self.m_LastServerBtn:setSelected(true)

	for ak,av in pairs(self.m_Area) do
		if av:GetBtn():getText() == self.m_SelectArea then
			av:GetBtn():setSelected(true)
		end
	end
end
----/////////////////////////////////////////------
--
--清除所有服务器cell显示
function SelectServersDialog:ClearAllServerCells()
	if self.m_ArrayServerCells then
		for k,v in pairs(self.m_ArrayServerCells) do
			v:OnClose()
			v = nil
		end
	end
	self.m_ArrayServerCells = nil
end

----/////////////////////////////////////////------
--刷新当前选中大区的服务器列表
function SelectServersDialog:RefreshServerCells(selectedAreaName, selectedAreaID)
	if self.m_AreaServersMap == nil then return end

	local selectedArea = self.m_AreaServersMap[selectedAreaName]
	if not selectedArea then
		for k,v in pairs(self.m_AreaServersMap) do
			if v.id == selectedAreaID then
				selectedArea = v
			end
		end
	end

	self:CheckServersLoad()
	if selectedArea then
		self.m_ArrayServerCells = {}

		local username = GetLoginManager():GetAccount()

		local index = 0
		local haveSelected = false
		local defaultSelected = 1
		for k,v in pairs(selectedArea.servers) do
			index = index+1
			LogInfo("refresh server cell " .. index .. v.servername .. " " .. k) 
			self.m_ArrayServerCells[index] = SelectServersDialogCell.CreateNewDlg(self.m_ServerListBack)
			local mainFrame = self.m_ArrayServerCells[index]:GetWindow()
			local hoffset = (index-1)*mainFrame:getHeight().offset
			mainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, 0.0), CEGUI.UDim(0.0, hoffset)))

			if index == 1 then
				defaultSelected = v["serverid"]
			end

			local serverroleinfo = nil
			if self.m_AccountInfo[username] then
				serverroleinfo = self.m_AccountInfo[username][v["servername"]]
				LogInfo("refresh account sererinfo")
				if not serverroleinfo then
					LogInfo("refresh account sererinfo nil")
					for key,value in pairs(self.m_AccountInfo[username]) do
						LogInfo("refresh account sererinfo nil " .. key .. " " .. value.id)
						if value.id == v["serverid"] then
							serverroleinfo = value
						end
					end
				end
			end

			self.m_ArrayServerCells[index]:SetCellInfo(v["serverid"], v, self.m_SelectServer, serverroleinfo)

			if v["servername"] == self.m_SelectServer then 
				self.m_SelectServerKey = v["serverid"]
			end

			if v["serverid"] == self.m_SelectServerKey then
				haveSelected = true
			end
		end

		if not haveSelected then
			self.m_SelectServerKey = defaultSelected
		end
		
		self:DeselectOtherServerBtn()
		self.m_ServerListBack:setVisible(false)
		self.m_ServerListBack:setVisible(true)
	end
end

----/////////////////////////////////////////------
--
function SelectServersDialog:DeselectOtherServerBtn()
	print("enter SelectServersDialog:DeselectOtherServerBtn ")
	if self.m_ArrayServerCells then
		for k,v in pairs(self.m_ArrayServerCells) do
			print("deselect server key ".. k)
			v:SetSelectedState(self.m_SelectServerKey)
		end
	end
end
function SelectServersDialog:DeselectOtherAreaBtn()
	print("enter SelectServersDialog:DeselectOtherAreaBtn ")
	if self.m_Area then
		for k,v in pairs(self.m_Area) do
			print("deselect area key ".. k)
			v:SetSelectedState(self.m_SelectAreaID)
		end
	end
end
function SelectServersDialog:DeselectAllServerBtn()
	print("enter SelectServersDialog:DeselectAllServerBtn ")
	if self.m_ArrayServerCells then
		for k,v in pairs(self.m_ArrayServerCells) do
			print("deselect server key ".. k)
			v:SetSelectedState(0)
		end
	end
	self.m_NewServerBtn:setSelected(false)
	self.m_LastServerBtn:setSelected(false)
end
-------------------------------------------------------------
function SelectServersDialog:CheckServersLoad()
	LogInfo("SelectServersDialog CheckServersLoad")
	if self.m_AreaServersMap == nil then return end
	local selectedArea = self.m_AreaServersMap[self.m_SelectArea]
	if not selectedArea then
		for k,v in pairs(self.m_AreaServersMap) do
			if v.id == self.m_SelectAreaID then
				selectedArea = v
			end
		end
	end

	GetLoginManager():ClearConnections()

	if selectedArea then
		for k,v in pairs(selectedArea.servers) do
			local key = v["serverid"]
			local lowport = tonumber(v.port)
			local highport = lowport + tonumber(v.portnum) - 1
			highport = math.max(lowport, highport)
			local port = StringCover.randBetween(lowport, highport)
			local ip = v.ip
			local cmode = v["cmode"] or 0
			local gip = v["gip"] or ""
			local gport = port or ""

			if cmode == 0 then
				GetLoginManager():CheckLoad(ip, port, key)
			else
				GetLoginManager():CheckLoad(ip, port, key, cmode, gip, gport)
			end
		end	
	end

	for ak,av in pairs(self.m_AreaServersMap) do
		for k,v in pairs(av.servers) do
			if v["serverid"] == self.m_LastServerKey or v["serverid"] == self.m_NewServerKey then
				local key = v["serverid"]
				local lowport = tonumber(v.port)
				local highport = lowport + tonumber(v.portnum) - 1
				highport = math.max(lowport, highport)
				local port = StringCover.randBetween(lowport, highport)
				local ip = v.ip
				local cmode = v["cmode"] or 0
				local gip = v["gip"] or ""
				local gport = port or ""

				if cmode == 0 then
					GetLoginManager():CheckLoad(ip, port, key)
				else
					GetLoginManager():CheckLoad(ip, port, key, cmode, gip, gport)
				end
			end
		end
	end	
end

function SelectServersDialog.SetServerLoad(serverKey, serverLoad)
	LogInfo("SelectServersDialog SetServerLoad serverKey = " .. tostring(serverKey) .. ",serverLoad = " .. tostring(serverLoad))
	if _instance then
		if serverLoad == 1 or serverLoad == 2 or serverLoad == 3 then   --good 
			if _instance.m_ArrayServerCells then
				for k,v in pairs(_instance.m_ArrayServerCells) do
					if v.m_CellBack:getID() == serverKey then
						v.m_Status:setProperty("Image", SelectServersDialogCell.GetIconByStatus(v.status))
					end
				end
			end
			if serverKey == _instance.m_LastServerKey then
				if _instance.m_LastServerState ~= nil then
					_instance.m_LastServerState:setProperty("Image", "set:LoginBack1 image:lastone")
				end
			end
			if serverKey == _instance.m_NewServerKey then
				if _instance.m_NewServerState ~= nil then
					_instance.m_NewServerState:setProperty("Image", "set:LoginBack1 image:new")
				end
			end
		elseif serverLoad == -1 then  --maintain
			if _instance.m_ArrayServerCells then
				for k,v in pairs(_instance.m_ArrayServerCells) do
					if v.m_CellBack:getID() == serverKey then
						v.m_Status:setProperty("Image", "set:LoginBack1 image:weihu")
					end
				end
			end
			if serverKey == _instance.m_LastServerKey then
				if _instance.m_LastServerState ~= nil then
					_instance.m_LastServerState:setProperty("Image", "set:LoginBack1 image:weihu")
				end
			end
			if serverKey == _instance.m_NewServerKey then
				if _instance.m_NewServerState ~= nil then
					_instance.m_NewServerState:setProperty("Image", "set:LoginBack1 image:weihu")
				end
			end
		end
	end
end

----/////////////////////////////////////////------
--新界面初始化大区列表
function SelectServersDialog:InitAreaList()
	LogInfo("SelectServersDialog InitAreaList")
	local AreaServerSort = {}
	local indexArea = 0
	for k,v in pairs(self.m_AreaServersMap) do
		indexArea = indexArea + 1
		AreaServerSort[indexArea] = {}
		AreaServerSort[indexArea].id = tonumber(v.id)
		AreaServerSort[indexArea].name = k
	end

	local sortFunc = function(a, b) return b.id < a.id end
	table.sort(AreaServerSort, sortFunc)

	self.m_Area = {}
	local index = 0
	for k,v in pairs(AreaServerSort)do
		index = index + 1
		self.m_Area[index] =  SelectServersAreaCell.CreateNewDlg(self.m_AreaListBack)
		local mainFrame = self.m_Area[index]:GetWindow()
		local woffset = (index-1)*mainFrame:getWidth().offset+1
		mainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, woffset), CEGUI.UDim(0.0, 1.0)))
		self.m_Area[index]:SetCellVisible(true)
		self.m_Area[index]:SetCellInfo(v.id, v.name, self.m_SelectArea)
	end

	self.m_AreaListBack:setVisible(false)
	self.m_AreaListBack:setVisible(true)
end

function SelectServersDialog:run(args)
	delta = CEGUI.toUpdateEventArgs(args).d_timeSinceLastFrame * 1000

	if not OPEN_NEWS_HAVE_OPEN then
		OPEN_NEWS_TIME = OPEN_NEWS_TIME + delta
		if OPEN_NEWS_TIME > 0 then
			if NewsWarnDlg.GetLatestNewsWarn() then
				NewsWarnDlg.getInstanceAndShow()
			end
			OPEN_NEWS_TIME = 0
			OPEN_NEWS_HAVE_OPEN = true
		end
	end
end

return SelectServersDialog
