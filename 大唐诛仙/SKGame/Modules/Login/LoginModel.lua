LoginModel = BaseClass(LuaModel)

function LoginModel:__init()
	self.accountList = {} -- 账号信息列表
	self.serverList = {} -- 服务器列表
	self.curRegistAccount = {userName = "", passWord = "", userId = "", isVisitor = false}
	self.visitorUid = -1
	self.curServerID = 0 -- 当前服务器ID
	self.roles = {} -- 角色列表(已经创建的角色)
	self.isCreating = false -- 如果是刚创建的，默认选择登录刚创建的角色
	self.createName = nil -- 当前正在创建的角色名字用于定位刚创建的角色进场
	self.isLogined = false -- 登录状态
	self.isExistRoleOnGame = false -- 角色进入游戏中
	self.loginRole = nil -- 当前登录的角色
	self.serverTime = 0 -- 服务器时间
	self.telePhone = 0 --绑定的手机号码
	self.curResetPasswordInfo = {} --当前重置密码的信息

	--------新版角色界面所需数据 start
	self.cfgRolesInfo = {} --配置表中的所有角色信息
	self.skillCfg = GetCfgData("skill_CellNewSkillCfg")
	--------新版角色界面所需数据 end	

	-- S_EnterComplete 进入游戏完成后 拿取数据
		self.testSwitch = 0				 -- 外挂开关   1：开启
		self.bagGrid = 0				 -- 背包格子数
		self.listPlayerBags = {}		 -- 背包列表
		self.listPlayerEquipments = {}	 -- 装备列表
		self.hpDrugLumns = {}			 -- 三个红药栏
		self.mpDrugLumns = {}			 -- 三个蓝药栏
		self.listPlayerSkills = {}		 -- 已学会技能列表
		self.listPlayerFashions = {}	 -- 已拥有时装翅膀
		self.haveNewMail = 0			 -- 是否有新邮件
		self.listPlayerTasks = {}		 -- 任务列表
		self.equipmentGrid = 0			 -- 装备货架格子数
		self.listPlayerWeaponEffect = {} -- 武器铭文效果列表
		self.playerFamilyId = 0 		 -- 家族唯一id

	-- 登录信息与状态
	self.loginState = 0
	self.isReLink = false -- 是否为重连
	self.loginPlayerId = 0 -- 最后登录的玩家id
	self.loginUseName = nil -- 最后登录的玩家用户名
	self.loginUsePwd = ""
	self.loginAccountData = {}
	self.loginServerNo = 0

	--异常码1309错误提示累积次数
	self.dropItemErrorCodeCnt = 0
	self.autoHttpLogin = false
	self.roleSelectPanelOpenFlag = false

end

-- 获取初始角色信息数据
	function LoginModel:SetEnterData( msg )
		self.testSwitch = msg.testSwitch or 0
		self.bagGrid = msg.bagGrid or 0
		self.listPlayerBags = msg.listPlayerBags or {}
		self.listPlayerEquipments = msg.listPlayerEquipments or {}
		self.hpDrugLumns = msg.hpDrugLumns or {}
		self.mpDrugLumns = msg.mpDrugLumns or {}
		self.listPlayerSkills = msg.listPlayerSkills or {}
		self.listPlayerFashions = msg.listPlayerFashions or {}
		self.haveNewMail = msg.haveNewMail or 0
		self.listPlayerTasks = msg.listPlayerTasks or {}
		self.equipmentGrid = msg.equipmentGrid or 0
		self.listPlayerWeaponEffect = msg.listPlayerWeaponEffect or {}
		self.playerFamilyId = msg.playerFamilyId or 0
		self.familyName = msg.familyName or ""
		self.familySortId = msg.familySortId or 0
		self.signMsg = msg.signMsg or {}
		self.haveMailTotalNum = msg.haveMailTotalNum or 0
		self.curLayerId = msg.curLayerId or 1
		self.furnaceList = msg.furnaceList or {}
		GlobalDispatcher:DispatchEvent(EventName.ENTER_DATA_INITED)
	end
	function LoginModel:GetTestSwitch()
		return self.testSwitch or 0
	end
	function LoginModel:GetBagGrid()
		return self.bagGrid or 0
	end
	function LoginModel:GetListPlayerBags()
		return self.listPlayerBags or {}
	end
	function LoginModel:GetListPlayerEquipments()
		return self.listPlayerEquipments or {}
	end
	function LoginModel:GetHpDrugLumns()
		return self.hpDrugLumns or {}
	end
	function LoginModel:GetMpDrugLumns()
		return self.mpDrugLumns or {}
	end
	function LoginModel:GetListPlayerSkills()
		return self.listPlayerSkills or {}
	end
	function LoginModel:GetListPlayerFashions()
		return self.listPlayerFashions or {}
	end
	function LoginModel:GetHaveNewMail()
		return self.haveNewMail or 0
	end
	function LoginModel:GetListPlayerTasks()
		return self.listPlayerTasks or {}
	end
	function LoginModel:GetEquipmentGrid()
		return self.equipmentGrid or 0
	end
	function LoginModel:GetListPlayerWeaponEffect()
		return self.listPlayerWeaponEffect or {}
	end
	function LoginModel:GetplayerFamilyId()
		return self.playerFamilyId or 0
	end
	function LoginModel:GetSignMsg()
		return self.signMsg or {}
	end
	function LoginModel:GetMailTotalNum()
		return self.haveMailTotalNum or 0
	end
	function LoginModel:SetMailTotalNum(num)
		self.haveMailTotalNum = num
	end
	function LoginModel:GetTowerLayer()
		return self.curLayerId or 1
	end
	function LoginModel:SetTowerLayer(id)
		self.curLayerId = id
	end
	function LoginModel:GetFurnaceList()
		return self.furnaceList or {}
	end

-- 基本的登入角色信息
	function LoginModel:CleanRoles()
		self.roles = {}
	end
	function LoginModel:GetRoles()
		return self.roles
	end
	function LoginModel:HasRole()
		return #self.roles ~= 0
	end
	function LoginModel:AddRole( role )
		table.insert(self.roles, role)
		--self:SortRoles()
	end

	function LoginModel:SortRoles()
		table.sort(self.roles, function(a, b) 
			return a.loginTime > b.loginTime
		end)
	end

	--设置某个账号的最近选择的角色信息
	function LoginModel:SetLastRole(playerId)
		if playerId ~= nil then
			local lastAccount = self:GetLastAccount()
			if not TableIsEmpty(lastAccount) then
				DataMgr.WriteData(LoginConst.LastSelectRoleKey, {userId = lastAccount.userId or 0, playerId = playerId})
			end
		end
	end

	--获取某个账号的最近选择的角色信息
	function LoginModel:GetLastRole()
		return DataMgr.ReadData(LoginConst.LastSelectRoleKey, {})
	end

	function LoginModel:CleanLastRole(playerId)
		if playerId then
			local lastAccount = self:GetLastRole()
			if not TableIsEmpty(lastAccount) then
				if lastAccount.playerId == playerId then
					self:SetLastRole(0)
				end
			end
		end
	end
	
	function LoginModel:GetRoleName(index)
		local rtnName = ""
		if index and index ~= -1 then
			rtnName = self.roles[index].playerName or ""
		end
		return rtnName
	end
	function LoginModel:GetRoleLev(index)
		local rtnLev = 0
		if index and index ~= -1 then
			rtnLev = self.roles[index].level or ""
		end
		return rtnLev
	end
	function LoginModel:GetRoleByPlayerId( playerId )
		for i,v in ipairs(self.roles) do
			if playerId == v.playerId then
				return v, i
			end
		end
		return nil
	end
	-- 获取角色总数
	function LoginModel:GetRolesCnt()
		return #self.roles
	end
	-- 设置当前登录角色信息
	function LoginModel:SetLoginRole( role )
		self.loginRole = role
	end
	-- 获取当前登录角色信息
	function LoginModel:GetLoginRole() -- 当前登录的角色
		return self.loginRole
	end
	-- 是否为自己
	function LoginModel:IsRole( playerId )
		return self.loginRole and self.loginRole.playerId == playerId
	end
	-- 主角数据一些变化同步
	function LoginModel:UpdateLoginData(k, v)
		if self.loginRole then
			self.loginRole:SetKV( k, v )
		end
	end

	--根据角色职业来判断玩家当前是否拥有该角色
	function LoginModel:IsHasRole(roleIndex)
		local rtnIsHas = false;
		local rtnRoleInfo = {};
		if roleIndex == nil then return end
		if self.roles[roleIndex] ~= nil then
			rtnIsHas = true
			rtnRoleInfo =self.roles[roleIndex]
		end
		return rtnIsHas, rtnRoleInfo;
	end

	function LoginModel:DeleteRole(playerId)
		if playerId then
			for index = 1, #self.roles do
				local characterVo = self.roles[index]
				if characterVo and characterVo.playerId == playerId then
					self.roles[index]:Destroy()
					table.remove(self.roles, index)
					break
				end
			end
			--self:SortRoles()
		end
	end

-- 服务器列表
	-- 服务器时间
	function LoginModel:SetServerTime( t )
		self.serverTime = t
		TimeTool.SetServerTime( t, true )
		GlobalDispatcher:DispatchEvent(EventName.UpdateServerTime,self.serverTime)
	end
	function LoginModel:GetServerTime()
		return self.serverTime
	end

	function LoginModel:GetSrvExecptionCfg( code )
		if self.cfg == nil then
			self.cfg = GetCfgData( "game_exception" )
		end
		return self.cfg:Get( tonumber(code) ) or {}
	end

-- 创建时拿到的配置角色信息
	function LoginModel:SetAllRolesCfgInfo( cfg)
		self.cfgRolesInfo = cfg or {};
	end

	function LoginModel:SortAllRolesInfo()
		if self.cfgRolesInfo ~= nil and table.nums(self.cfgRolesInfo) > 0 then
			local allRolesInfoSorted = {}
			for i = 1, table.nums(self.roles) do
				for j = 1, table.nums(self.cfgRolesInfo) do
					if self.roles[i].career == self.cfgRolesInfo[j].career then
						table.insert(allRolesInfoSorted, self.cfgRolesInfo[j])
						table.remove(self.cfgRolesInfo, j)
						break;
					end
				end
			end

			for k = 1, table.nums(self.cfgRolesInfo) do
				table.insert(allRolesInfoSorted, self.cfgRolesInfo[k]);
			end

			self.cfgRolesInfo = {}
			self.cfgRolesInfo = allRolesInfoSorted;
			
			table.sort(self.cfgRolesInfo, function (a, b)
				return a.career < b.career
			end)
		end
	end

	function LoginModel:GetAllRolesInfo()
		return self.cfgRolesInfo or {}
	end

-- 角色技能介绍
	function LoginModel:GetSkillIconId(skillId)
		local rtnIconId = ""
		if skillId ~= nil then
			local curSkill = self.skillCfg:Get(skillId)
			if curSkill ~= nil then
				rtnIconId = curSkill.iconID
			end
		end
		return rtnIconId
	end

	function LoginModel:GetSkillDesc(skillId)
		local rtnSkillInfo = ""
		if skillId ~= nil then
			local curSkill = self.skillCfg:Get(skillId)
			if curSkill ~= nil then
				rtnSkillInfo = curSkill.des
			end
		end
		return rtnSkillInfo
	end

	function LoginModel:GetSkillName(skillId)
		local rntSkillName = ""
		if skillId ~= nil then
			local curSkill = self.skillCfg:Get(skillId)
			if curSkill ~= nil then
				rntSkillName = curSkill.name
			end
		end
		return rntSkillName
	end

-- 登录状态 state : 0 未登入用户 1 用户登入成功 2 角色登入游戏成功
	function LoginModel:SetLoginState( state )
		self.loginState = state
		if state == 2 then
			self.isExistRoleOnGame = true
		end
		self:Fire(LoginConst.LOGIN_STATE_CHANGE)
	end
	function LoginModel:GetLoginState()
		return self.loginState
	end
-- 是否已经登录进入游戏
	function LoginModel:IsInGame()
		return self.loginState == 2
	end

--账号数据处理
	--获取游客名称(显示表现，实为全部)
	function LoginModel:GetVisitorName()
		local deviceUID = DeviceInfo:GetDeviceUID()
		local visitorName = string.sub(deviceUID, 0, 6)
		return visitorName or ""
	end

	function LoginModel:GetVisitorPassWord()
		return "123456"
	end

	function LoginModel:GetAccountList()
		self.accountList = {}
		local curAccountCnt = self:GetAccountCnt()
		for index = 0, curAccountCnt -1 do
			local curAccountKey = StringFormat("{0}{1}", LoginConst.AccountKey, index)
			local curAccount = self:GetAccount(curAccountKey)
			if not TableIsEmpty(curAccount) then table.insert(self.accountList, curAccount) end
		end
		return self.accountList
	end

	function LoginModel:SetCurRegistAccount(userName, passWord, isVisitor)
		if userName and passWord and isVisitor ~= nil then
			self.curRegistAccount.userName = userName
			self.curRegistAccount.passWord = passWord
			self.curRegistAccount.isVisitor = isVisitor
		end
	end

	function LoginModel:SetCurRegistAccountUid(userId)
		if userId then
			self.curRegistAccount.userId = userId
		end
	end

	-- userId:账号唯一标示
	-- key：随机密钥（存起来，登录游戏用到）
	-- time：加密时间（存起来，登录游戏用到）
	-- sign：加密签名（存起来，登录游戏用到）
	function LoginModel:SetAccountByLogin(data)
		local accountKeyIdx = self:GetAccountKeyByUid(data.userId)

		if self.curRegistAccount.userName ~= "" and self.curRegistAccount.passWord ~= "" and self.curRegistAccount.isVisitor and accountKeyIdx == -1 then
			local curAccountCnt = self:GetAccountCnt()
			local accountKey = StringFormat("{0}{1}", LoginConst.AccountKey, curAccountCnt)
			local curAccount = self.curRegistAccount
			if accountKey ~= LoginConst.AccountKey then
				DataMgr.WriteData(accountKey, {userId = data.userId, key = data.key, time = data.time, sign = data.sign, userName = curAccount.userName or "", passWord = curAccount.passWord or "", isVisitor = curAccount.isVisitor, telePhone = data.telePhone or 0})
			end

			if not self:IsContainAccount(accountKey) then
				self:SetAccountCnt()
			end
			self.visitorUid = data.userId
			return
		end

		if accountKeyIdx ~= -1 then
			accountKey = StringFormat("{0}{1}", LoginConst.AccountKey, accountKeyIdx)
			local curAccount = self:GetAccount(accountKey)
			if accountKey ~= LoginConst.AccountKey and curAccount ~= nil then
				DataMgr.WriteData(accountKey, {userId = data.userId, key = data.key, time = data.time, sign = data.sign, userName = curAccount.userName or "", passWord = curAccount.passWord or "", isVisitor = curAccount.isVisitor, telePhone = data.telePhone or 0})
			end
		else
			local curAccountCnt = self:GetAccountCnt()
			local accountKey = StringFormat("{0}{1}", LoginConst.AccountKey, curAccountCnt)
			local curAccount = self.curRegistAccount
			if accountKey ~= LoginConst.AccountKey then
				DataMgr.WriteData(accountKey, {userId = data.userId, key = data.key, time = data.time, sign = data.sign, userName = curAccount.userName or "", passWord = curAccount.passWord or "", isVisitor = curAccount.isVisitor, telePhone = data.telePhone or 0})
			end

			if not self:IsContainAccount(accountKey) then
				self:SetAccountCnt()
			end
		end
	end

	--游客转正设置数据
	function LoginModel:SetVisitorAccount()
		local visitorKey, visitorAccount = self:GetVisitorAccount()
		if visitorKey ~= "" and (not TableIsEmpty(visitorAccount)) then
			if self.curRegistAccount.userName ~= "" and self.curRegistAccount.passWord ~= "" and self.curRegistAccount.isVisitor then
				visitorAccount.userName = self.curRegistAccount.userName
				visitorAccount.passWord = self.curRegistAccount.passWord
				visitorAccount.isVisitor = not self.curRegistAccount.isVisitor
				DataMgr.WriteData(visitorKey, visitorAccount)
			end
		end
	end

	function LoginModel:GetVisitorAccount()
		local rtnAccountKey = ""
		local rtnAccount = {}
		local curAccountCnt = self:GetAccountCnt()
		for index = 1, curAccountCnt do
			local curAccountKey = StringFormat("{0}{1}", LoginConst.AccountKey, index - 1)
			local curAccount = self:GetAccount(curAccountKey)
			if not TableIsEmpty(curAccount) then
				rtnAccount = curAccount
				rtnAccountKey = curAccountKey
				break
			end
		end
		return rtnAccountKey, rtnAccount
	end

	function LoginModel:SetAccountByRegist()
		local curRegistAccount = self.curRegistAccount
		if curRegistAccount.userName ~= "" and curRegistAccount.passWord ~= "" and curRegistAccount.userId ~= "" then
			local curAccountCnt = self:GetAccountCnt()
			local accountKey = StringFormat("{0}{1}", LoginConst.AccountKey, curAccountCnt)
			if accountKey ~= LoginConst.AccountKey then
				DataMgr.WriteData(accountKey, {userName = curRegistAccount.userName, passWord = curRegistAccount.passWord, userId = curRegistAccount.userId, isVisitor = curRegistAccount.isVisitor })
				if not self:IsContainAccount(accountKey) then
					self:SetAccountCnt()
				end
			end
		end
	end

	function LoginModel:GetAccountKeyByUid(userId)
		local accountKey = -1
		local accountList = self:GetAccountList()
		for index = 1, #accountList do
			if accountList[index] then
				if accountList[index].userId == userId then
					accountKey = index - 1
					break
				end
			end
		end
		return accountKey
	end

	function LoginModel:GetAccountByUid(userId)
		local rtnAccount = {}
		local accountList = self:GetAccountList()
		for index = 1, #accountList do
			if accountList[index] then
				if accountList[index].userId == userId then
					rtnAccount = accountList[index]
					break
				end
			end
		end
		return rtnAccount
	end

	function LoginModel:GetAccount(accountKey)
		return DataMgr.ReadData(accountKey, {})
	end

	function LoginModel:SetAccountCnt()
		DataMgr.WriteData(LoginConst.AccountCntKey, self:GetAccountCnt() + 1)
	end

	function LoginModel:RemAccountCnt()
		DataMgr.WriteData(LoginConst.AccountCntKey, self:GetAccountCnt() - 1)
	end

	function LoginModel:GetAccountCnt()
		return DataMgr.ReadData(LoginConst.AccountCntKey, 0)
	end

	function LoginModel:IsContainAccount(accountKey)
		if DataMgr.ReadData(accountKey, 0) == 0 then
			return false
		else
			return true
		end
	end

	function LoginModel:IsHasAccount()
		return self:GetAccountCnt() > 0 
	end

	function LoginModel:SetLastAccount(accountData)
		if accountData then
			DataMgr.WriteData( LoginConst.LastAccountDataKey, accountData)
		end
	end

	function LoginModel:GetLastAccount()
		return DataMgr.ReadData( LoginConst.LastAccountDataKey, {})
	end

	function LoginModel:UpdateLastAccount()
		local lastAccount = self:GetLastAccount()
		if not TableIsEmpty(lastAccount) then
			local newAccount = self:GetAccountByUid(lastAccount.userId)
			if newAccount.passWord ~= lastAccount.passWord then
				DataMgr.WriteData(LoginConst.LastAccountDataKey, newAccount)
			end
		end
	end

	function LoginModel:GetLastAccountBindPhone()
		local rtnTelePhone = ""
		local accountData = self:GetLastAccount()
		if not TableIsEmpty(accountData) and accountData.telePhone then
			rtnTelePhone = accountData.telePhone
		end
		return rtnTelePhone
	end

	function LoginModel:SetVisitorUID(data)
		self.visitorUid = data or -1
	end

	function LoginModel:GetVisitorUID()
		return self.visitorUid
	end

	function LoginModel:SetAutoHttpLogin(bl)
		self.autoHttpLogin = bl
	end

	function LoginModel:GetAutoHttpLogin()
		return self.autoHttpLogin
	end

	function LoginModel:DeleteAccount(accountData)
		if accountData then
			local accountList = self:GetAccountList()
			local accountKeyIdx = self:GetAccountKeyByUid(accountData.userId or -1)
			if accountKeyIdx ~= -1 then
				local accountKey = StringFormat("{0}{1}", LoginConst.AccountKey, accountKeyIdx)
				table.remove(accountList, accountKeyIdx)
				DataMgr.DeleteKey(accountKey)
				self:SetAccountList(accountList)
				self:RemAccountCnt()
				self:DispatchEvent(LoginConst.OnAccountItemDelect, accountData)
			end
		end
	end

	function LoginModel:SetAccountList(accountList)
		if accountList then
			for index = 1, #accountList do
				local accountIndex = index - 1
				local accountKey = StringFormat("{0}{1}", LoginConst.AccountKey, accountIndex)
				DataMgr.WriteData(accountKey, accountList[index])
			end
		end
	end

	function LoginModel:IsHasVisitor()
		local rtnIsHas = false
		local accountList = self:GetAccountList()
		for index = 1, #accountList do
			if accountList[index].isVisitor == true then
				rtnIsHas = true
				break
			end
		end
		return rtnIsHas
	end


--服务器列表数据处理
	-- serverNo：服务器编号
	-- serverName：服务器名称
	-- gameHost：服务器ip
	-- gamePort：服务器端口
	-- severState：服务器状态 (0.测试 1.流畅2：拥挤3.火爆  4.维护中 5.关闭)
	-- severType：服务器类型(0.普通 1.新服 2.推荐)
	-- loginFlag：是否登录过  1：是  0：否
	-- openServerDate：开服时间

	function LoginModel:SetServerList(data)
		if data == nil or data == "" then return end
		local dataJson = JSON:decode(data)
		self.serverList = dataJson
		table.sort(self.serverList, function (a, b)
			return a.serverNo > b.serverNo
		end)
	end

	function LoginModel:GetServerList()
		return self.serverList
	end

	--获取登录过的，并且创建过角色的服务列表
	function LoginModel:GetHasLoginServerList()
		local rtnServerList = {}
		for index = 1, #self.serverList do
			local curServer = self.serverList[index]
			if curServer.loginFlag == LoginConst.HasLogin.Yes then
				table.insert(rtnServerList, curServer)
			end
		end
		return rtnServerList
	end

	--获取推荐服列表
	function LoginModel:GetRecommendServerList()
		local rtnServerList = {}
		for index = 1, #self.serverList do
			local curServer = self.serverList[index]
			if not TableIsEmpty(curServer) and  curServer.severType == LoginConst.ServerType.Recommend then
				table.insert(rtnServerList, curServer)
			end
		end
		return rtnServerList
	end

	--获取新服列表
	function LoginModel:GetNewServerList()
		local rtnServerList = {}
		for index = 1, #self.serverList do
			local curServer = self.serverList[index]
			if not TableIsEmpty(curServer) and curServer.severType == LoginConst.ServerType.New then
				table.insert(rtnServerList, curServer)
			end
		end
		return rtnServerList
	end

	--获取当前组的服务器列表
	function LoginModel:GetServerListByGroup(groupIndex)
		local rtnServerList = {}
		local firstNum = groupIndex * ServerSelectConst.ServerGroupItemCnt - (ServerSelectConst.ServerGroupItemCnt - 1)
		local endNum = groupIndex * ServerSelectConst.ServerGroupItemCnt

		if firstNum ~= 0 and endNum ~= 0 and firstNum < endNum then
			for i = 1, #self.serverList do
				local curServer = self.serverList[i]
				if not TableIsEmpty(curServer) then
					if i >= firstNum and i <= endNum then
						table.insert(rtnServerList, curServer)
					end
				end
			end
		end
		return rtnServerList
	end

	--获取当前类型服务器列表
	function LoginModel:GetServerListByType(v)
		local t = LoginConst.ServerTabType
		if v == t.My then
			return self:GetHasLoginServerList()
		elseif v == t.Recommend then
			return self:GetRecommendServerList()
		elseif v > t.Recommend then
			return self:GetServerListByGroup(v - 1)
		end
		return {}
	end

	--设置最近登录的服务器
	function LoginModel:SetLastServer(v)
		if v then
			v.phonePlat = GameConst.PhonePlat
			DataMgr.WriteData(LoginConst.LastServerKey, v)
		end
	end

	--更新最近登录的服务器
	function LoginModel:UpdateLastServer()
		local lastServer = self:GetLastServer()
		local lastServerNo = self:GetLastServerNo()
		if not TableIsEmpty(lastServer) and lastServerNo ~= 0 then
			for i = 1, #self.serverList do
				local cur = self.serverList[i]
				if not TableIsEmpty(cur) and cur.serverNo == lastServerNo then
					self:SetLastServer(cur)
					break
				end
			end
		end
	end

	--获取最近登录的服务器
	function LoginModel:GetLastServer()
		return DataMgr.ReadData(LoginConst.LastServerKey, {})
	end

	function LoginModel:GetLastServerNo()
		local data = self:GetLastServer()
		if not TableIsEmpty(data) then
			return data.serverNo or 0
		end
		return 0
	end

	function LoginModel:GetLastServerName()
		local data = self:GetLastServer()
		if not TableIsEmpty(data) then
			return data.serverName or ""
		end
		return ""
	end

	--获取某个服的开服时间
	function LoginModel:GetServerOpenDateByServerNo(serverNo)
		for i = 1, #self.serverList do
			local curServer = self.serverList[i]
			if not TableIsEmpty(curServer) and curServer.serverNo == serverNo then
				return curServer.openServerDate
			end
		end
		return 0
	end
	-- 获取服务器vo
	function LoginModel:GetServerByserverNo(serverNo)
		for i = 1, #self.serverList do
			local curServer = self.serverList[i]
			if not TableIsEmpty(curServer) and curServer.serverNo == serverNo then
				return curServer
			end
		end
		return {}
	end

	--获取最新的服务器
	function LoginModel:GetNewestServer()
		return self.serverList[#self.serverList]
	end

	--设置选中最新的服务器
	function LoginModel:SetSelectNewestServer()
		local newestServer = self:GetNewestServer()
		if not TableIsEmpty(newestServer) then
			self:SetLastServer(newestServer)
			GlobalDispatcher:DispatchEvent(EventName.SelectServer, newestServer)
		end
	end

	--获取服务器页签总个数
	--我的服务器 和 推荐服务器是固定页签
	function LoginModel:GetServerTabCnt()
		local tabCnt, b = math.modf(#self.serverList / ServerSelectConst.ServerGroupItemCnt)
		if tabCnt == 0 then
			tabCnt = 1
		else
			if b > 0 and tabCnt > 0 then
				tabCnt = tabCnt + 1
			end
		end
		tabCnt = tabCnt + 2  -- 我的服务器 和 推荐服务器是固定页签
		return tabCnt
	end

	--错误码1309异常提示
	function LoginModel:SetDropItemErrorCodeCnt()
		self.dropItemErrorCodeCnt = self.dropItemErrorCodeCnt + 10
	end

	function LoginModel:GetDropItemErrorCodeCnt()
		return self.dropItemErrorCodeCnt
	end

	function LoginModel:SetCurResetPasswordInfo(userId, userName, oldPassword, newPassword)
		-- body
		self.curResetPasswordInfo = {}
		if userId and userName and oldPassword and newPassword then
			self.curResetPasswordInfo.userId = userId
			self.curResetPasswordInfo.userName = userName
			self.curResetPasswordInfo.oldPassword = oldPassword
			self.curResetPasswordInfo.newPassword = newPassword
		end
	end

	function LoginModel:CleanCurResetPasswordInfo()
		self.curResetPasswordInfo = {}
	end

	function LoginModel:GetCurResetPasswordInfo()
		return self.curResetPasswordInfo
	end

	--重置某个账号的密码
	function LoginModel:ResetPassword()
		if not TableIsEmpty(self.curResetPasswordInfo) then
			local curAccountData = self:GetAccountByUid(self.curResetPasswordInfo.userId or 0)
			local curAccountKeyIdx = self:GetAccountKeyByUid(self.curResetPasswordInfo.userId or 0)
			if not TableIsEmpty(curAccountData) and curAccountKeyIdx ~= -1 then
				if  curAccountData.userId == self.curResetPasswordInfo.userId and curAccountData.passWord == self.curResetPasswordInfo.oldPassword then
					local curAccountKey = StringFormat("{0}{1}", LoginConst.AccountKey, curAccountKeyIdx)
					curAccountData.passWord = self.curResetPasswordInfo.newPassword
					DataMgr.WriteData(curAccountKey, curAccountData)
					self:UpdateLastAccount()
				end
			end
		end
	end

-- 单例
function LoginModel:GetInstance()
	if LoginModel.inst == nil then
		LoginModel.inst = LoginModel.New()
	end
	return LoginModel.inst
end

function LoginModel:__delete()
	self.accountInfoList = nil
	self.serverList = nil
	self.isExistRoleOnGame = nil
	LoginModel.inst = nil
end

--为了解决退出重登，在场景加载界面会闪现MainCityUI界面
--设置是否角色选择界面是否打开
function LoginModel:SetRoleSelectPanelOpenFlag(bl)
	if bl ~= nil and type(bl) == 'boolean' then
		self.roleSelectPanelOpenFlag = bl
	end
end

function LoginModel:GetRoleSelectPanelOpenFlag()
	return self.roleSelectPanelOpenFlag
end