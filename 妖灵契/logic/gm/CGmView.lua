CGmView = class("CGmView", CViewBase)

function CGmView.ctor(self, cb)
	CViewBase.ctor(self, "UI/GM/GMView.prefab", cb)

	--界面设置
	self.m_DepthType = "Dialog"

	--self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
	self.m_TabType = nil
	self.m_Config = nil
	self.m_IsAlwaysShow = true
end

function CGmView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_CloseBtn = self:NewUI(2, CButton)

	self.m_GmTabGrid = self:NewUI(3, CGrid)
	self.m_CloneTabBtn = self:NewUI(4, CButton, true, false)

	self.m_CommandInput = self:NewUI(5, CInput)
	self.m_CommandExecuteBtn = self:NewUI(6, CButton, true, false)
	self.m_SyncTimeLabel = self:NewUI(7, CLabel)

	self.m_BtnInfoGroup = self:NewUI(8, CObject)
	self.m_BtnInfoListGrid = self:NewUI(9, CGrid)
	self.m_CloneBtnInfoListBtn = self:NewUI(10, CButton, true, false)
	
	self.m_RecordGroup = self:NewUI(11, CObject)
	self.m_RecordGrid = self:NewUI(12, CGrid)
	self.m_CloneRecordBtn = self:NewUI(13, CButton)
	self.m_RecordCleanBtn = self:NewUI(14, CButton)

	self.m_NilTipObj = self:NewUI(15, CObject)

	self.m_TestGroup = self:NewUI(16, CObject)
	self.m_TestGrid = self:NewUI(17, CGrid)
	self.m_CloneTestBtn = self:NewUI(18, CButton)

	self.m_GmHelpGroup = self:NewUI(19, CObject)
	self.m_GmHelpTabGroup = self:NewUI(20, CGrid)
	self.m_GmHelpGrid = self:NewUI(21, CGrid)
	self.m_CloneGmHelpeBtn = self:NewUI(22, CButton)

	self.m_ConsoleTipGroup = self:NewUI(23, CObject)
	self.m_ConsoleTipLabel = self:NewUI(24, CLabel)
	self.m_ConsoleCleanBtn = self:NewUI(25, CButton)
	self.m_AutoCloseSelBtn = self:NewUI(26, CSprite)
	local w, h = UITools.GetRootSize()
	self.m_Container:SetSize(w, h)
	self.m_Container:SetLocalPos(Vector3.New(-w/2, 0, 0))

	self:SetLastInstruct()
	self:InitContent()
	self:InitTabListGrid()
	self:InitRecordListBtnGrid()
	self:InitTestListBtnGrid()
	self:InitGmHelpListBtnGrid()
	self:InitConsoleTip()
	self:InitAutoClose()
	-- self:ShowSpecificPage()
	-- self:ShowSpecificTab()

	self.m_IsShowItemID = false
end

function CGmView.ShowSpecificPage(self, shwoNormal)
	shwoNormal = shwoNormal or true
	self.m_BtnInfoGroup:SetActive(shwoNormal)
	self.m_GmHelpGroup:SetActive(not shwoNormal)
end

function CGmView.ShowSpecificTab(self, tabIndex)
	tabIndex = tabIndex or self.m_TabType or g_GmCtrl:GetRecordTab()
	local btnInfo = nil
	if self.m_Config and #self.m_Config > 0 then
		btnInfo = self.m_Config[tabIndex]
		if not btnInfo then
			for i,v in ipairs(self.m_Config) do
				if v and #v then
					tabIndex = i
					btnInfo = v
					break
				end
			end
		end
	end

	if btnInfo then
		local obtn = self.m_GmTabGrid:GetChild(tabIndex)

		if obtn then
			obtn:SetSelected(true)
		end
		-- obtn:Notify(enum.UIEvent["click"])
		self:OnGMTabEvent(tabIndex, btnInfo)

		self.m_NilTipObj:SetActive(false)
	else
		self.m_NilTipObj:SetActive(true)
	end
end

function CGmView.SetLastInstruct(self)
	if g_GmCtrl.m_RecordInput then
		self:SetCommandInput(g_GmCtrl.m_RecordInput)
	end
end

function CGmView.SetCommandInput(self, str)
	g_GmCtrl.m_RecordInput = str
	self.m_CommandInput:SetText(str)
end

function CGmView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Gm.Event.RefreshLastInfo then
		self:InitRecordListBtnGrid()
	elseif oCtrl.m_EventID == define.Gm.Event.RefreshGmHelpMsg then
		self:InitConsoleTip()
	end
end

function CGmView.InitContent(self)
	g_GmCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CommandExecuteBtn:AddUIEvent("click", callback(self, "OnCommandExecute"))

	local function update()
		if Utils.IsNil(self) then
			return false
		end
		local time = g_TimeCtrl:GetTimeYMD()
		if time then
			self.m_SyncTimeLabel:SetText("当前服务器时间:" .. time)
		end
		return true
	end
	self.m_Timer = Utils.AddTimer(update, 1, 0)

	self.m_RecordCleanBtn:SetText("清除记录")
	self.m_RecordCleanBtn:AddUIEvent("click", callback(self, "OnRecordClean"))

	self.m_ConsoleCleanBtn:SetText("清除GM帮助")
	self.m_ConsoleCleanBtn:AddUIEvent("click", callback(self, "OnConsoleClean"))

	self.m_CloneTabBtn:SetActive(false)
	self.m_CloneBtnInfoListBtn:SetActive(false)
	self.m_CloneRecordBtn:SetActive(false)
	self.m_CloneTestBtn:SetActive(false)
end

CGmView.AutoClose = 0
function CGmView.InitAutoClose(self)
	if CGmView.AutoClose == 1 then
		self.m_AutoCloseSelBtn:SetSelected(true)
	else
		self.m_AutoCloseSelBtn:SetSelected(false)
	end
	self.m_AutoCloseSelBtn:AddUIEvent("click", function ()
		if self.m_AutoCloseSelBtn:GetSelected() then
			CGmView.AutoClose = 1
		else
			CGmView.AutoClose = 0
		end
	end)
end

function CGmView.OnCommandExecute(self)
	local sParam = self.m_CommandInput:GetText()
	local sFloatMsg = "请输入GM指令"
	if sParam == "" then
		return
	end
	local bCode = string.find(sParam, '~') ~= nil
	if bCode then
		local sOriText = sParam
		sParam = string.sub(sParam, 2)
		sParam = loadstring(sParam)
		if sParam then
			local oldprint = print
			print = function ( ... )
				oldprint(...)
			end
			xxpcall(function () sParam() end)
			print = oldprint
			self.m_CommandInput:SetText("")
			g_GmCtrl:SetRecord(sOriText)
		end
		if self.m_AutoCloseSelBtn:GetSelected() then
			self:CloseView()
		end
		return
	end
	local bClient = string.find(sParam, '#') ~= nil
	if bClient then
		local sSave, funcname = sParam, ""
		sParam = string.sub(sParam, 2)
		local argindex = sParam:find(" ")
		if argindex then
			funcname = sParam:sub(1, argindex-1)
			sParam = sParam:sub(argindex+1)
		else
			funcname = sParam
			sParam = ""
		end
		local func = rawget(CGmFunc, funcname)
		if func then
			if funcname == "rpccode" then
				local idx =  sParam:find(" ")
				func(sParam:sub(1, idx-1), sParam:sub(idx+1))
			else
				local arglist = string.split(sParam, " ")
				if arglist then
					func(unpack(arglist, 1))
				end
			end
		end
		
		g_GmCtrl:SetRecord(sSave)
		sFloatMsg = "客户端GM指令: " .. funcname
	else
		local startIdx = string.find(sParam, '%$') or 0
		sParam = string.sub(sParam, startIdx+1)
		sFloatMsg = "服务端GM指令: " .. sParam
		self:SetCommandInput(sParam)
		g_GmCtrl:C2GSGMCmd(sParam)
	end
	g_NotifyCtrl:FloatMsg(sFloatMsg)
	if self.m_AutoCloseSelBtn:GetSelected() then
		self:CloseView()
	end
end

function CGmView.OnRecordClean(self)
	g_GmCtrl:CleanRecordInstructDic()
end

function CGmView.OnConsoleClean(self)
	g_GmCtrl:CleanConsoleTip()
end

function CGmView.InitTabListGrid(self)
	self.m_Config = self.m_Config or CGmConfig.gmConfig
	self.m_CloneTabBtn:SetCacheKey("CGmView.m_CloneTabBtn")
	if self.m_Config and #self.m_Config > 0 then
		for i, v in ipairs(self.m_Config) do
			local function cb(oTabBtn, time)
				if Utils.IsNil(self) then
					return false
				end
				-- local oTabBtn = self.m_CloneTabBtn:Clone()
				oTabBtn:GetMissingComponent(classtype.UIDragScrollView)
				oTabBtn:SetActive(true)
				--oTabBtn:SetSize(180, 40)
				oTabBtn:SetText(v.name)
				oTabBtn:AddUIEvent("click", callback(self, "OnGMTabEvent", i, v))
				self.m_GmTabGrid:AddChild(oTabBtn)
				self.m_GmTabGrid:Reposition()
				if i == #self.m_Config then
					self:ShowSpecificPage()
					self:ShowSpecificTab()
				end
			end
			self.m_CloneTabBtn:CloneAnsy(cb, false)
		end
	else
		g_NotifyCtrl:FloatMsg("没有GM配置")
	end
end

function CGmView.OnGMTabEvent(self, index, arg)
	if (self.m_TabType or 0) ~= index then
		self.m_TabType = index
		if arg then
			self:InitGmListBtnGrid(arg.btnInfo)
			-- Sava
			g_GmCtrl:SetRecordTab(index)
		end
	end
end

function CGmView.InitGmListBtnGrid(self, dataInfo)
	local gmConfig = dataInfo or CGmConfig.gmConfig[self.m_TabType].btnInfo
	local showGmList = gmConfig and #gmConfig > 0
	self.m_NilTipObj:SetActive(not showGmList)

	local btnGridList = self.m_BtnInfoListGrid:GetChildList() or {}
	self.m_CloneBtnInfoListBtn:SetCacheKey("CGmView.m_CloneBtnInfoListBtn")
	local upvalue = Utils.GetUniqueID()
	self.m_RefreshID = upvalue
	if showGmList then
		for i, v in ipairs(gmConfig) do
			local function ansy(oGMBtn)
				if Utils.IsNil(self) then
					return false
				end
				if self.m_RefreshID == upvalue then
					oGMBtn:GetMissingComponent(classtype.UIDragScrollView)
					--oGMBtn:SetSize(118, 48)
					self.m_BtnInfoListGrid:AddChild(oGMBtn)
					oGMBtn:AddUIEvent("click", callback(self, "OnGMBtnEvent", v))
					oGMBtn:SetActive(true)
					oGMBtn:SetText(v.name)
					if i == #gmConfig then
						if #btnGridList > #gmConfig then
							for i=#gmConfig+1,#btnGridList do
								btnGridList[i]:SetActive(false)
							end
						end
					end
					self.m_BtnInfoListGrid:Reposition()
				else
					return false
				end
			end
			if i > #btnGridList then
				self.m_CloneBtnInfoListBtn:CloneAnsy(ansy, false)
			else
				ansy(btnGridList[i])
			end
		end
	else
		if btnGridList and #btnGridList > 0 then
			for _,v in ipairs(btnGridList) do
				v:SetActive(false)
			end
		end
	end
end

function CGmView.InitRecordListBtnGrid(self)
	local recordInstruct = g_GmCtrl:GetRecordInstruct()
	local showRecordGroup = recordInstruct and #recordInstruct > 0
	self.m_RecordGroup:SetActive(showRecordGroup)
	self:ReSetConsoleTipPos()
	
	if showRecordGroup then
		self.m_RecordInstructBtns = self.m_RecordInstructBtns or {}
		for i=#recordInstruct,1,-1 do
			local v = recordInstruct[i]
			local oRecordBtn = nil
			if #recordInstruct-i >= #self.m_RecordInstructBtns then
				oRecordBtn = self.m_CloneRecordBtn:Clone(false)
				oRecordBtn:GetMissingComponent(classtype.UIDragScrollView)
				oRecordBtn:SetSize(200, 48)

				self.m_RecordGrid:AddChild(oRecordBtn)
				table.insert(self.m_RecordInstructBtns, oRecordBtn)
			else
				oRecordBtn = self.m_RecordInstructBtns[#recordInstruct-i+1]
			end
			oRecordBtn:SetActive(true)
			oRecordBtn:SetText(v.name)
			oRecordBtn:AddUIEvent("click", callback(self, "OnGMBtnEvent", v))
		end

		-- for i, v in ipairs(recordInstruct) do
		-- 	self.m_RecordInstructBtns = self.m_RecordInstructBtns or {}
		-- 	local oRecordBtn = nil
		-- 	if i > #self.m_RecordInstructBtns then
		-- 		oRecordBtn = self.m_CloneRecordBtn:Clone(false)
		-- 		oRecordBtn:GetMissingComponent(classtype.UIDragScrollView)
		-- 		oRecordBtn:SetActive(true)
		-- 		oRecordBtn:SetSize(200, 48)
		-- 		oRecordBtn:SetText(v.name)

		-- 		oRecordBtn:AddUIEvent("click", callback(self, "OnGMBtnEvent", v))
		-- 		self.m_RecordGrid:AddChild(oRecordBtn)
		-- 		table.insert(self.m_RecordInstructBtns, oRecordBtn)
		-- 	else
		-- 		oRecordBtn = self.m_RecordInstructBtns[i]
		-- 		oRecordBtn:SetText(v.name)
		-- 		oRecordBtn:AddUIEvent("click", callback(self, "OnGMBtnEvent", v))
		-- 	end
		-- end
	else
		if self.m_RecordInstructBtns then
			for _,v in ipairs(self.m_RecordInstructBtns) do
				v:SetActive(false)
			end
		end
	end
end

function CGmView.InitTestListBtnGrid(self)
	local tConfig = CGmConfig.testConfig
	local showTestGroup = tConfig and #tConfig > 0
	self.m_TestGroup:SetActive(showTestGroup)

	if showTestGroup then
		for _, v in ipairs(tConfig) do
			local oTestBtn = self.m_CloneTestBtn:Clone(false)
			oTestBtn:GetMissingComponent(classtype.UIDragScrollView)
			oTestBtn:SetActive(true)
			oTestBtn:SetSize(100, 36)
			oTestBtn:SetText(v.name)

			oTestBtn:AddUIEvent("click", callback(self, "OnGMBtnEvent", v))
			self.m_TestGrid:AddChild(oTestBtn)
		end
	end
end

function CGmView.InitGmHelpListBtnGrid(self, dataInfo)
	local tConfig = dataInfo or {}
	if tConfig and #tConfig >  0 then
		for _,v in ipairs(tConfig) do
			local oGmHelpBtn = self.m_CloneGmHelpeBtn:Clone(false)
			oGmHelpBtn:GetMissingComponent(classtype.UIDragScrollView)
			oGmHelpBtn:SetActive(true)
			oGmHelpBtn:SetSize(118, 48)
			oGmHelpBtn:SetText(v.name)

			oGmHelpBtn:AddUIEvent("click", callback(self, "OnGMBtnEvent", v))
			self.m_GmHelpGrid:AddChild(oGmHelpBtn)
		end
	end
end

function CGmView.InitConsoleTip(self)
	local tMsg = g_GmCtrl.m_HelpMsg or ""

	self.m_ConsoleTipGroup:SetActive(string.len(tMsg) > 0)
	if string.len(tMsg) > 0 then
		self:ReSetConsoleTipPos()
		self.m_ConsoleTipLabel:SetText(tMsg)
	end
end

function CGmView.ReSetConsoleTipPos(self)
	if self.m_ConsoleTipGroup:GetActive() then
		local tPosX = 168
		if self.m_RecordGroup:GetActive() then
			tPosX = 394
		end
		-- self.m_ConsoleTipGroup:SetLocalPos(Vector3.New(tPosX, -70, 0))
	end
end

function CGmView.ReplaceArg(self, s)
	if s ~= "" and string.find(s, "目标玩家ID") then
		s = string.replace(s, "目标玩家ID", tostring(g_AttrCtrl.pid) )
	end
	if s ~= "" and string.find(s, "目标公会ID") then
		s = string.replace(s, "目标公会ID", tostring(g_AttrCtrl.org_id) )
	end
	return s
end

function CGmView.OnGMBtnEvent(self, ...)
	local args = {...}
	local arg = args[1]
	local param = self:ReplaceArg(arg.param)

	if arg.fun then
		if string.find(arg.fun, '#') then
			self.m_CommandInput:SetText( self:ReplaceArg(arg.fun))
			return
		end
		local f = self[funcname]
		if f then
			-- self:SetCommandInput(arg.name .. ":" .. arg.param)
			f(self, arg)
		else
			-- 默认调用：C2GSGMCmd
			-- self:SetCommandInput(param)
			g_GmCtrl:C2GSGMCmd(param)
		end
	else
		self:SetCommandInput(param)
	end
end

-- [[本地数据GM指令]]
function CGmView.HeroSpeed(self, arg)
	self.m_Config = self.m_Config or CGmConfig.gmConfig
	arg = arg or self.m_Config[self.m_TabType].btnInfo[1]
	local hero = g_MapCtrl:GetHero()
	if hero then
		if hero.m_Walker2D.moveSpeed < 6 then
			arg.param = "20"
		else
			arg.param = "3"
		end
		local oldSp = hero.m_Walker2D.moveSpeed
		local speed = tonumber(arg.param)
		hero.m_Walker2D.moveSpeed = speed
		arg.param = tonumber(oldSp)
		if speed > 6 then
			arg.name = "玩家移速正常"
		else
			arg.name = "玩家移速快"
		end
	else
		print("没有找到玩家，关闭GM界面")
	end

	self:CloseView()
end

-- function CGmView.OpenMapViwe(self, arg)

-- end

-- function CGmView.Experience(self, arg)
-- 	self:SetCommandInput(arg.name)
-- end

-- function CGmView.OpenBagLock(self, arg)
-- 	self:SetCommandInput(arg[1])
-- 	g_ItemCtrl:ExtBagSize(10)
-- end


function CGmView.Test1(self, arg)
	-- self:SetCommandInput(arg.name)
	g_TeamCtrl:TestApply()
end

function CGmView.Test2(self, arg)
	-- self:SetCommandInput(arg.name)
	g_TeamCtrl:TestInvite()
end

-- function CGmView.Test3(self, arg)
-- 	self:SetCommandInput(arg.name)
-- end

-- [[测试按钮执行]]
function CGmView.OnTest1(self, arg)
	
	g_NotifyCtrl:FloatMsg("执行测试按钮1")

	local pbdata = {
		text = "123456789&Q选项1&Q选项2&Q选项3",
		name = "测试名称"
	}
	--g_DialogueCtrl:GS2CNpcSay(pbdata)
end

function CGmView.ShowTestWarView(self, arg)
	g_NotifyCtrl:FloatMsg("步进模式开启成功")
	g_WarCtrl.m_IsTestMode = true
	g_WarCtrl.m_CanMoveNext = false
	if g_WarCtrl:IsWar() and CTestWarView:GetView() == nil then
		CTestWarView:ShowView()
	end
end

function CGmView.OnWarSimulate(self,arg)
	self:OnClose()
	CGmWarSimulateView:ShowView()
end

function CGmView.TestMaskWord()
	CGmCheckView:ShowView()
end

function CGmView.OnShowItemID(self)
	self.m_IsShowItemID = not self.m_IsShowItemID
	g_GmCtrl:ShowItemID(self.m_IsShowItemID)
end

return CGmView