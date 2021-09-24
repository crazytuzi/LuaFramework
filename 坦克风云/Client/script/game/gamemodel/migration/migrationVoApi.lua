--数据迁移相关
--author: Liang Qi
migrationVoApi={
	initFlag=false,
	codeTb={},
	lastShowTs={},
	url=nil,
	platname=nil,
	mig_status=nil, --迁移开关的状态 1：被迁移方（生成迁移码），2：迁移方（输入迁移码）
}

function migrationVoApi:clear()
	self.mig_status = nil
	self.platname = nil
	self.url = nil
	self.initFlag = false
	self.codeTb = {}
	self.lastShowTs = {}
end

function migrationVoApi:init()
	if(G_curPlatName()=="0")then
		-- self.url="http://gm.rayjoy.com/tank_gm/gm_index/platformwar/"
		-- self.platname="gm_feiliu"
		-- self.url="http://192.168.8.213/test_gm_index/platformwar/"
		-- self.platname="gm_207"
	elseif(G_curPlatName()=="androidzhongshouyouko" or G_curPlatName()=="13" or G_curPlatName()=="andgamesdealko" or G_curPlatName()=="androidzsykonaver") then
		self.url="http://gm.rayjoy.com/tank_gm/gm_index/platformwar/"
		self.platname="gm_korea"
	elseif(G_curPlatName()=="androidkakaogoogle" or G_curPlatName()=="androidkakaonaver" or G_curPlatName()=="androidkakaotstore")then
		self.url="http://gm.rayjoy.com/tank_gm/gm_index/platformwar/"
		self.platname="gm_korea_kk"
	elseif(G_curPlatName()=="42" or G_curPlatName()=="1" or G_curPlatName()=="flandroid" or G_curPlatName()=="63" or G_curPlatName()=="flandroid_rgame" or G_curPlatName()=="68")then
		self.url="http://gm.rayjoy.com/tank_gm/gm_index/platformwar/"
		self.platname="gm_feiliuyueyu"
	elseif(G_curPlatName()=="51" or G_curPlatName()=="58" or G_curPlatName()=="60" or G_curPlatName()=="5") then
		self.url="http://gm.rayjoy.com/tank_gm/gm_index/platformwar/"
		self.platname="gm_feiliu"
	end

	self:checkMigrateUrl()

	self.initFlag=true
	-- local localData=CCUserDefault:sharedUserDefault():getStringForKey("migrationCode")
	-- if(localData and localData~="")then
	-- 	local function exception(msg)
	-- 		print(msg)
	-- 	end
	-- 	local function decode()
	-- 		local tb=G_Json.decode(localData)
	-- 		if(tb and type(tb)=="table")then
	-- 			self.codeTb=tb
	-- 		end
	-- 	end
	-- 	xpcall(decode,exception)
	-- end
	local localData=CCUserDefault:sharedUserDefault():getStringForKey("migrationShowTime")
	if(localData and localData~="")then
		local function exception(msg)
			print(msg)
		end
		local function decode()
			local tb=G_Json.decode(localData)
			if(tb and type(tb)=="table")then
				self.lastShowTs=tb
			end
		end
		xpcall(decode,exception)
	end
end

--检查该平台的迁移状态
--return 1: 被迁移的平台
--return 2: 要迁移到的平台
--return 0: 无关平台
function migrationVoApi:checkMigrateStatus()
	if(self.mig_status == 1 or G_curPlatName()=="androidzhongshouyouko" or G_curPlatName()=="13" or G_curPlatName()=="andgamesdealko" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="42" or (tonumber(base.migration)==1 and (G_curPlatName()=="58" or G_curPlatName()=="60" or G_curPlatName()=="5")))then
		return 1
		-- return 0
	elseif(self.mig_status == 2 or G_curPlatName()=="1" or G_curPlatName()=="51" or G_curPlatName()=="flandroid_rgame" or G_curPlatName()=="68")then
		return 2
		-- return 0
	elseif((G_curPlatName()=="androidkakaogoogle" or G_curPlatName()=="androidkakaonaver" or G_curPlatName()=="androidkakaotstore") and tonumber(base.curZoneID)>=600)then
		-- return 2
		return 0
	else
		return 0
	end
end

--每天一次，自动弹出激活码提示
function migrationVoApi:checkShow()
	if(not self.initFlag)then
		self:init()
	end
	if(not self.url or self.url=="")then
		do return end
	end
	if(migrationVoApi:checkMigrateStatus()~=1)then
		do return end
	end
	if sceneController:getNextIndex()==1 and base.allShowedCommonDialog==0 and newGuidMgr:isNewGuiding()==false and SizeOfTable(G_SmallDialogDialogTb)==0 and otherGuideMgr.isGuiding==false then
		local lastTs=self.lastShowTs["u"..playerVoApi:getUid()]
		if(lastTs==nil or tonumber(lastTs)<base.curZeroTime)then
			migrationVoApi:showCodeDialog()
		end
	end
end

--获取激活码
function migrationVoApi:getCode()
	local codeKey="u"..playerVoApi:getUid()
	-- if(self.codeTb[codeKey])then
	-- 	return self.codeTb[codeKey]
	-- else
		if(self.url)then
		  	local zoneID
		    if(base.curOldZoneID and tonumber(base.curOldZoneID)>0)then
		        zoneID=tonumber(base.curOldZoneID)
		    else
		        zoneID=tonumber(base.curZoneID)
		    end
			local param="getaccounttoken?uid="..playerVoApi:getUid().."&zoneid="..tostring(zoneID).."&platname="..self.platname
			local result=G_sendHttpRequest(self.url..param)
			print("∑∑result",result)
			result=G_Json.decode(result)
			if(tonumber(result.result)==1 and result.data and result.data.token)then
				-- self.codeTb[codeKey]=tostring(result.data.token)
				return tostring(result.data.token)
			else
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("netiswrong"),28)
				return ""
			end
			-- CCUserDefault:sharedUserDefault():setStringForKey("migrationCode",G_Json.encode(self.codeTb))
			-- CCUserDefault:sharedUserDefault():flush()
			-- return self.codeTb[codeKey]
		else
			return ""
		end
	-- end
end

--批量获取本地存储登录账号的迁移码数据
function migrationVoApi:getMigrationCodeList(callback)
	if(not self.initFlag)then
		self:init()
	end
    local accountList = {}
	local accountStr = CCUserDefault:sharedUserDefault():getStringForKey("localUidData")
    if accountStr and accountStr ~= "" then
        accountList = G_Json.decode(accountStr)
    end
    local migrationStr = "?platname="..self.platname.."&data="
    local migrationInfo = {}
    for k,v in pairs(accountList) do
    	if v and SizeOfTable(v)>0 then
    		local regdate = v[4] or 0
    		if (regdate > 0  and regdate < 1553529600) or regdate==0 then --新号记录了注册时间，不显示迁移码,2019/3/26号之后的号为新号
		    	table.insert(migrationInfo,{v[2],v[1]})
    		end
    	end
    end
    if SizeOfTable(migrationInfo)>0 then
	   	migrationStr = migrationStr..G_Json.encode(migrationInfo)
    end
  	local param="getbatchaccounttoken"..migrationStr
  	if self.url then
  		local codeList = {}
		local result=G_sendHttpRequest(self.url..param)
		print("∑∑result",result)
		result=G_Json.decode(result)
		if(tonumber(result.result)==1 and result.data)then
			-- G_dayin(result.data)
			for k,v in pairs(result.data) do
				if v and v[1] and v[2] then
					codeList[tonumber(v[1])]={v[2],v[3] or 0}
				end
			end
			if callback then
				callback(codeList)
			end
		else
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("netiswrong"),28)
		end
  	end
end

--输入激活码，执行迁移
function migrationVoApi:inputCode(code)
	if(not self.initFlag)then
		self:init()
	end
	if(code and self.url)then
		local zoneid
		if(base.curOldZoneID and tonumber(base.curOldZoneID)~=nil and tonumber(base.curOldZoneID)>0)then
			zoneid=tonumber(base.curOldZoneID)
		else
			zoneid=tonumber(base.curZoneID)
		end
		local param="bindnewaccount?uid="..playerVoApi:getUid().."&zoneid="..tostring(zoneid).."&token="..code.."&platname="..self.platname
		local result=G_sendHttpRequest(self.url..param)
		print("∑∑result",result)
		result=G_Json.decode(result)
		if(tonumber(result.result)==1)then
			base:changeServer()
			if PlatformManage~=nil then
				PlatformManage:shared():switchAccount()
			end
		elseif tonumber(result.result)==-102 or tonumber(result.result)==-103 or tonumber(result.result)==-106 then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("migrationError"..RemoveFirstChar(result.result)),28)
		else
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage304"),28)
		end
	end
end

function migrationVoApi:showCodeDialog()
	local code=migrationVoApi:getCode()
	local str=getlocal("migrationCodeDesc",{code})
	local function callback( ... )
		if(G_curPlatName()=="42")then
			local tmpTb={}
			tmpTb["action"]="openUrl"
			tmpTb["parms"]={}
			tmpTb["parms"]["url"]="http://union.7659.com/wap/index.html?appid=com.lvmax.appstore.tank&channel_id=kuaiyong&platform_id=7659"
			local cjson=G_Json.encode(tmpTb)
			G_accessCPlusFunction(cjson)
		end
	end
	smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callback,getlocal("dialog_title_prompt"),str,nil,200)
	self.lastShowTs["u"..playerVoApi:getUid()]=base.serverTime
	CCUserDefault:sharedUserDefault():setStringForKey("migrationShowTime",G_Json.encode(self.lastShowTs))
	CCUserDefault:sharedUserDefault():flush()
end

function migrationVoApi:showInputDialog(layerNum)
	local function callback(codeStr)
		self:inputCode(codeStr)
	end
	smallDialog:showInputCodeDialog(layerNum,callback)
end

--复制保存迁移码
function migrationVoApi:setMigrationCode(zoneid,code)
    local key = "migrationKey"..zoneid
    CCUserDefault:sharedUserDefault():setStringForKey(key, code)
    CCUserDefault:sharedUserDefault():flush()
end

--获取复制的迁移码
function migrationVoApi:getMigrationCopyCode(zoneid)
    local key = "migrationKey"..zoneid
    return CCUserDefault:sharedUserDefault():getStringForKey(key)
end

function migrationVoApi:checkMigrateUrl()
	local serverpid = G_getServerPlatId()
	self.url = "http://gm.rayjoy.com/tank_gm/gm_index/platformwar/"
	if self.platname == nil then
		if platCfg.gmNameCfg and platCfg.gmNameCfg[serverpid] then
			self.platname = platCfg.gmNameCfg[serverpid]
		end
	end
end

--从管理工具获取渠道迁移开关状态
function migrationVoApi:getMigrateStatusFromServer(callback)
	if G_getCurChoseLanguage() ~= "cn" then
		do return end
	end
	if self.mig_status ~= nil then
		do return end
	end
	--管理工具获取该渠道迁移状态
	local cfgurl, params
	if G_curPlatName() == "0" then
		cfgurl = "http://192.168.8.213/test_gm_index/operative/gettransferchannel"
	else
		cfgurl = "http://gm.rayjoy.com/tank_gm/gm_index/operative/gettransferchannel"
	end
	params = "channelid=" .. G_getPlatAppID()
	-- print("cfgurl====> ",cfgurl .. "?" .. params)
	local function requestHandler(data)
        if data and data ~= "" then
            local rd = G_Json.decode(data)
            if rd and rd.result then
				self.mig_status = tonumber(rd.result)
				-- print("appid, mig_status=====>> ", G_getPlatAppID(), self.mig_status)
				if callback and type(callback) == "function" then 
					callback()
				end
            end
        end 
    end
    G_sendHttpAsynRequest(cfgurl, params, requestHandler, 2)
end