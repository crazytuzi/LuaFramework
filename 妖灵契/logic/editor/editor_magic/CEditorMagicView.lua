local CEditorMagicView = class("CEditorMagicView", CViewBase)
CEditorMagicView.g_OriGetFile = false
function CEditorMagicView.ctor(self, cb)
	CViewBase.ctor(self, "UI/_Editor/EditorMagic/EditorMagicView.prefab", cb)
	self.m_DepthType = "Menu"
	self.m_GroupName = "EditorMaigc"
	--
	
	local config = require "logic.editor.editor_magic.editor_magic_config"
	rawset(_G, "config", config)
	self:RedefineFunc()
end

function CEditorMagicView.OnCreateView(self)
	self.m_SelFileBtn = self:NewUI(1, CButton)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_SaveBtn = self:NewUI(3, CButton)
	self.m_CmdListBox = self:NewUI(4, CEditorMagicCmdListBox)
	self.m_PlayBtn = self:NewUI(5, CButton)
	self.m_SaveAsBtn = self:NewUI(6, CButton)
	self.m_ArgBoxTable = self:NewUI(7,CTable)
	self.m_AttackBtn = self:NewUI(8, CButton)
	self.m_CamBtn = self:NewUI(10, CButton)
	-- self.m_HideBtn = self:NewUI(11, CButton)
	self.m_TopPart = self:NewUI(12, CWidget)
	self.m_DeleteBtn = self:NewUI(13, CButton)
	self.m_Container = self:NewUI(14, CWidget)
	self.m_Field = self:NewUI(15, CWidget)
	self.m_ClientTagInput = self:NewUI(16, CInput)
	self.m_ReplaceIDBtn = self:NewUI(17, CButton)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_ArgBoxDict = {}
	self.m_LoadData = {}
	self.m_SaveData = {}
	self.m_UserCache = {}
	self.m_IsHide = false
	self:InitContent()
end

function CEditorMagicView.Destroy(self)
	CViewBase.Destroy(self)
end

function CEditorMagicView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_SelFileBtn:AddUIEvent("click", callback(self, "OnSelFile"))
	self.m_SaveBtn:AddUIEvent("click", callback(self, "OnSaveFile"))
	self.m_PlayBtn:AddUIEvent("click", callback(self, "Play"))
	self.m_SaveAsBtn:AddUIEvent("click", callback(self, "OnSaveAsFile"))
	self.m_AttackBtn:AddUIEvent("click", callback(self, "Attack"))
	self.m_CamBtn:AddUIEvent("click", callback(self, "OnEditCam"))
	self.m_ReplaceIDBtn:AddUIEvent("click", callback(self, "OnReplaceID"))
	-- self.m_HideBtn:AddUIEvent("click", callback(self, "OnHide"))
	self.m_DeleteBtn:AddUIEvent("click", callback(self, "OnDeleteFile"))
	local lKey = {"warrior_cnt", "atk_id", "vic_ids", "vic_array",  "sub_type", "shape", "weapon", "run_env", "special_type"}
	local function initSub(obj, idx)
		local oBox = CEditorNormalArgBox.New(obj)
		local k = lKey[idx]
		local oArgInfo = config.arg.template[k]
		oBox:SetArgInfo(oArgInfo)
		if oArgInfo.change_refresh then
			oBox:SetValueChangeFunc(callback(self, "OnArgChange", oArgInfo.change_refresh))
		end
		self.m_ArgBoxDict[k] = oBox
		return oBox
	end
	self.m_ArgBoxTable:InitChild(initSub)

	local dUserCache = IOTools.GetClientData("editor_magic")
	if not dUserCache then
		dUserCache = {
			atk_id = 1,
			shape = 130,
			sub_type = "one",
			vic_ids = {15},
			warrior_cnt = 5,
			weapon = 2100,
			vic_array = 1,
			run_env = "war",
		}
	end
	self.m_UserCache = dUserCache
	for k, oBox in ipairs(self.m_ArgBoxTable:GetChildList()) do
		local v = dUserCache[oBox:GetKey()]
		if v ~= nil then
			oBox:SetValue(v, true)
		end
	end
	local lastPath = dUserCache["last_file_path"]
	if lastPath then
		self:LoadMagicFile(lastPath)
	end


	self:SetRunEnv(self.m_UserCache.run_env)
	self.m_InitDone = true
	g_WarTouchCtrl:SetPathMove(true)
	local oView = CNotifyView:GetView()
	if oView then
		oView.m_OrderBtn:SetActive(false)
	end
	self:RefreshRunEnv()
	g_AudioCtrl.m_MusicPlayer:SetVolume(0)
end

function CEditorMagicView.OnHideView(self)
	-- local oCam = g_CameraCtrl:GetWarCamera()
	-- oCam:SetRect(UnityEngine.Rect.New(0, 0, 1, 1))
end

function CEditorMagicView.OnShowView(self)

end

function CEditorMagicView.OnHide(self)
	self.m_IsHide = not self.m_IsHide
	local s = self.m_IsHide and "显示" or "隐藏"
	self.m_HideBtn:SetText(s)
	self.m_CmdListBox:SetActive(not self.m_IsHide)
	self.m_TopPart:SetActive(not self.m_IsHide)
end

function CEditorMagicView.OnArgChange(self, iFlag, key)
	if not self.m_InitDone then
		return
	end
	local bSaveChange, bRefreshRunEnv, bPlay = false, false, false
	if iFlag >= 1 then
		bSaveChange = true
	end
	if iFlag >= 2 then
		bRefreshRunEnv = true
	end
	if iFlag >= 3 then
		bPlay = true
	end
	if bSaveChange then
		local newVal = self.m_ArgBoxDict[key]:GetValue()
		if self:SetUserCache(key, newVal) then
			if key == "run_env" then
				self:SetRunEnv(newVal)
			else
				self:RefreshRunEnv()
				if bPlay then
					self:Play()
				end
			end
		end
	end
end

function CEditorMagicView.SetRunEnv(self, env)
	if config.run_env == env then
		return
	end
	config.run_env  = env
	g_WarCtrl:End()
	g_CreateRoleCtrl:EndCreateRole()
	if config.run_env  == "war" then
		local function delay()
			local oCam = g_CameraCtrl:GetWarCamera()
			if self.m_Container:GetWidth() == 1024 and self.m_Container:GetHeight() == 768 then
				oCam:SetRect(UnityEngine.Rect.New(1-self.m_Field:GetWidth()/1024, 0, self.m_Field:GetWidth()/1024, self.m_Field:GetHeight()/768))
			else
				local aspect = self.m_Field:GetWidth()/self.m_Container:GetWidth()
				oCam:SetRect(UnityEngine.Rect.New(1-aspect, 0, aspect, aspect))
			end
		end
		Utils.AddTimer(delay, 0, 0)
		self:RefreshRunEnv()
	elseif config.run_env  == "createrole" then
		local function delay()
			local oCam = g_CameraCtrl:GetCreateRoleCamera()
			if self.m_Container:GetWidth() == 1024 and self.m_Container:GetHeight() == 768 then
				oCam:SetRect(UnityEngine.Rect.New(1-self.m_Field:GetWidth()/1024, 0, self.m_Field:GetWidth()/1024, self.m_Field:GetHeight()/768))
			else
				local aspect = self.m_Field:GetWidth()/self.m_Container:GetWidth()
				oCam:SetRect(UnityEngine.Rect.New(1-aspect, 0, aspect, aspect))
			end
			g_CreateRoleCtrl:SetCreateData("mode", "branch")
			local oWarrior = g_CreateRoleCtrl:GetBranchWarrior()
			if oWarrior then
				oWarrior:ChangeShape(self:GetShape(), {weapon=self:GetWeapon()})
				oWarrior:Play("idleWar")
			end
		end
		g_CreateRoleCtrl:StartCreateRole(delay)
	end
end

function CEditorMagicView.SetUserCache(self, key, val)
	local oldVal = self.m_UserCache[key]
	if not table.equal(oldVal, val) then
		self.m_UserCache[key] = val
		-- table.print(self.m_UserCache)
		IOTools.SetClientData("editor_magic", self.m_UserCache)
		return true
	else
		return false
	end
end

function CEditorMagicView.RefreshRunEnv(self)
	if config.run_env == "war" then
		local iCnt = self.m_UserCache["warrior_cnt"] or 1
		warsimulate.Start(iCnt, self:GetShape(), self:GetWeapon(), self.m_UserCache["special_type"])
	elseif config.run_env == "createrole" then
		local oWarrior = g_CreateRoleCtrl:GetBranchWarrior()
		if oWarrior then
			oWarrior:ChangeShape(self:GetShape(), {weapon=self:GetWeapon()})
			oWarrior:Play("idleWar")
		end
	end
end

function CEditorMagicView.GetWeapon(self)
	return tonumber(self.m_ArgBoxDict["weapon"]:GetValue())
end

function CEditorMagicView.RedefineFunc(self)
	local function nilfunc() end
	CCreateRoleView.ctor = nilfunc
	CWarOrderCtrl.Bout = nilfunc
	CWarMainView.ShowView = nilfunc
	CWarrior.SetOrderDone = nilfunc
	CWarCtrl.SimulateMagicCmd = nilfunc
	CMainMenuView.ShowView = nilfunc
	local odlGet = CMagicCtrl.GetFileData
	CMagicCtrl.GetFileData = function(o, skillID, magicID)
		local sSubType = self.m_UserCache["sub_type"]
		if CEditorMagicView.g_OriGetFile or skillID == 99 or sSubType=="chain" or sSubType=="sequence" then
			local s = string.format("magic_%d_%d", skillID, magicID)
			reimport("logic.magic.magicfile."..s)
			return odlGet(o, skillID, magicID)
		else
			return self.m_SaveData
		end
	end
	CWarrior.SetName =function(o, name)
		name = string.format("%s", o.m_Pid)
		o.m_Name = name
		CObject.SetName(o, name)
		o:SetNameHud(name)
	end
	CWarrior.SetOrderDone = nilfunc
	CWarrior.SetReady = nilfunc
	CWarrior.GetCmdInVary = function(o, dVary, sListName)
		if sListName == "damage_list" then
			local oCmd
			local list = dVary.damage_list or {}
			if list[2] then
				oCmd = list[2]
			else
				oCmd = CWarCmd.New("WarDamage")
				oCmd.wid = o.m_ID
				oCmd.damage = -Utils.RandomInt(1, 3000)
				oCmd.iscrit = oCmd.damage<-1500
				table.insert(list, oCmd)
			end
			oCmd.damage_list = list
			return oCmd, #list
		end
	end
	CWarCmd.ClearWarriorVary = nilfunc
	CViewCtrl.CloseAll = nilfunc
	CTeamCtrl.GetMemberSize = function() return 4 end
	CPartnerCtrl.GetFightPartnerCnt = function() return 4 end
	CWarCtrl.Start=function(o, iWarID, iWarType)
		o:Clear()
		local oCamera = g_CameraCtrl:GetWarCamera()
		if oCamera then
			oCamera:SetFieldOfView(26)
		end
		Utils.SetShaderLight("war")
		g_HudCtrl:SetPanelActive("CBloodHud", false)
		g_WarTouchCtrl:SetLock(false)
		g_WarOrderCtrl:InitValue()
		g_SysSettingCtrl:SetSolveKaJiEnabled(false)
		o.m_WarID = iWarID
		-- iWarType = 18
		o.m_WarType = iWarType
		if iWarType == define.War.Type.GuideBoss or iWarType == define.War.Type.BossKing then
			g_CameraCtrl:PlayAction("guide_boss")
		else
			g_CameraCtrl:PlayAction("war_default")
		end
		
		-- g_CameraCtrl:AutoActive()
		o:StopCachedProto()
		g_MapCtrl:Clear(false)
		g_MagicCtrl:Clear("war")
		o:SwitchEnv(true)
		o.m_ActionFlag = 1
		o.m_IsWarStart = true

		o.m_IsClientRocord = g_NetCtrl:IsProtoRocord()
		o:LoadWarMap()
		g_GuideCtrl:TriggerCheck("war")
		o:OnEvent(define.War.Event.StartWar)
	end
	function CWarCtrl.IsGuideBoss(self)
		if self.m_WarType == define.War.Type.GuideBoss then
			return true
		end
		return false
	end

	function CWarBoutTimeBox.ShowWait(self, bShow)
		self.m_WaitSpr:SetActive(false)
	end
end

function CEditorMagicView.Attack(self)
	local atkid = self.m_UserCache["atk_id"]
	local vic_ids = self.m_UserCache["vic_ids"]
	warsimulate.NormalAttack(atkid, vic_ids[1])
end

function CEditorMagicView.Play(self)
	self:RefeshSaveData()
	if config.run_env == "war" then
		CEditorMagicView.g_OriGetFile = false
		local atkid = self.m_UserCache["atk_id"]
		local vic_ids = self.m_UserCache["vic_ids"]
		local sSubType = self.m_UserCache["sub_type"]
		local vic_array = self.m_UserCache["vic_array"]
		local s = self.m_NameLabel:GetText()
		s = string.split(s, ".")[1]
		local list = string.split(s, "_")
		warsimulate.Magic(list[2], list[3], {atkid}, vic_ids, sSubType, vic_array)
	elseif config.run_env == "createrole" then
		g_CreateRoleCtrl:DisplaySkill(0)
	end
end

function CEditorMagicView.OnReplaceID(self)
	local atkid = self.m_UserCache["atk_id"]
	local vic_ids = self.m_UserCache["vic_ids"]
	local v = 14
	if atkid > v then
		v = -v
	end
	self.m_ArgBoxDict["atk_id"]:SetValue(tostring(atkid+v), true)
	for i, vic in ipairs(vic_ids) do
		vic_ids[i] = vic - v
	end
	self.m_ArgBoxDict["vic_ids"]:SetValue(table.concat(vic_ids, ","), true)
end

function CEditorMagicView.RefeshSaveData(self)
	self.m_SaveData = self.m_CmdListBox:GetCmdSaveData()
	table.update(self.m_SaveData, {
			type = 1,
			run_env = config.run_env,
		})
end

function CEditorMagicView.OnSelFile(self)
	local function onSel(path)
		self:LoadMagicFile(path)
	end
	local selList = {}
	local wrap, sortfunc
	if Utils.IsEditor() then
		wrap = function (s)
			return IOTools.GetFileName(s)
		end
		selList = IOTools.GetFiles(self:GetMagicFilePath(), "*.lua", true)
		sortfunc = function (s1, s2)
			local _, ID1, Idx1 = unpack(string.split(s1, "_"))
			local _, ID2, Idx2 = unpack(string.split(s2, "_"))
			if ID1 == ID2 then
				return Idx1 < Idx2
			else
				return ID1 < ID2
			end
		end
		table.sort(selList, sortfunc)
	else
		selList = data.editordata.MAGIC_FILE
		wrap = function (t)
			return string.format("magic_%s_%s.lua",t[1],t[2])
		end
	end
	CMiscSelectView:ShowView(function(oView)
			oView:SetData(selList, onSel, wrap)
		end)
end

function CEditorMagicView.OnSaveFile(self)
	self:RefeshSaveData()
	if self.m_CurPath then
		self:SaveMagicFile(self.m_CurPath)
	else
		self:EditSavePath()
	end
end

function CEditorMagicView.OnDeleteFile(self)
	local args = {
		msg = "你确定要删除吗？",
		okCallback = callback(self, "DeleteFile"),
	}
	g_WindowTipCtrl:SetWindowConfirm(args)
end

function CEditorMagicView.DeleteFile(self)
	if self.m_CurPath and self.m_CurPath ~= "" then
		local path = self:GetMagicFilePath().."/"..self.m_CurPath
		IOTools.Delete(path)
		local pathMeta = path..".meta"
		IOTools.Delete(pathMeta)
		self:SetCurFile("")
		self.m_CmdListBox:SetCmds({}, {})
	end
end

function CEditorMagicView.OnSaveAsFile(self)
	self:RefeshSaveData()
	self:EditSavePath()
end

function CEditorMagicView.EditSavePath(self)
	local function f(oView)
		local function cb(filename)
			self:SetCurFile(filename)
			self:SaveMagicFile(filename)
		end
		oView:SetConfirmFunc(cb)
	end
	CEditorMagicSaveAsView:ShowView(f)
end

function CEditorMagicView.GetMagicFilePath(self)
	return IOTools.GetAssetPath("/Lua/logic/magic/magicfile")
end

function CEditorMagicView.SetCurFile(self, path)
	self.m_CurPath = path
	self.m_NameLabel:SetText(path)
	self:LoadClientTagInput(path)
	self:SetUserCache("last_file_path", self:GetMagicFilePath().."/"..path)
end

function CEditorMagicView.LoadMagicFile(self, path)
	self:LoadClientTagInput(path)
	if Utils.IsEditor() then
		local content = IOTools.LoadTextFile(path)
		if not content then return end
		content = string.gsub(content, "module%b()", "")
		content = string.format("local %s\n return DATA", content)
		
		local f = loadstring(content)
		local d = nil
		if f then
			d = f()
		end
		if not d then
			return
		end
		self:SetCurFile(IOTools.GetFileName(path, false))
		self.m_LoadData = d
	else
		if type(path) == "table" then
			local t = require(string.format("logic.magic.magicfile.magic_%s_%s", path[1], path[2]))
			self:SetCurFile(string.format("magic_%s_%s.lua",path[1],path[2]))
			self.m_LoadData = t.DATA
		else
			return
		end
	end
	
	table.copy(self.m_LoadData, self.m_SaveData)
	self:ResetWithData(self.m_LoadData)
end

function CEditorMagicView.SaveMagicFile(self, path)
	self:SaveClientTagInput(path)
	path = self:GetMagicFilePath().."/"..path
	local s = "module(...)\n--magic editor build\n"..table.dump(self.m_SaveData, "DATA")
	IOTools.SaveTextFile(path, s)
	g_NotifyCtrl:FloatMsg("保存成功  "..path)
end

function CEditorMagicView.ResetWithData(self, d)
	self.m_CmdListBox:SetCmds(d.cmds, d.group_cmds)
	self.m_CmdListBox.m_ScrollView:ResetPosition()
end

function CEditorMagicView.GetSeqAnimList(self)
	local iShape = 101
	local d = data.comboactdata.DATA[iShape]
	local list = {}
	if iShape and d then
		for k, v in pairs(d) do
			table.insert(list, k)
		end
	end
	return list
end

function CEditorMagicView.GetShape(self)
	return tonumber(self.m_ArgBoxDict["shape"]:GetValue())
end

function CEditorMagicView.OnEditCam(self)
	CEditorMagicView:CloseView()
	CEditorCameraView:ShowView()
end

function CEditorMagicView.SaveClientTagInput(self, filename)
	local sTag = self.m_ClientTagInput:GetText()
	local tagList = self:GetTagList()
	if filename then
		IOTools.SetClientData(filename, {sTag = sTag, tagList = tagList})
	end
end

function CEditorMagicView.LoadClientTagInput(self, filename)
	local clientData = IOTools.GetClientData(filename)
	if clientData then
		local sTag = clientData.sTag or ""
		local tagList = clientData.tagList or {}
		self.m_ClientTagInput:SetText(sTag)
		self.m_CmdListBox:SetTagList(tagList)
	end
	self.m_CmdListBox:SetClientTagFilename(filename)
end

function CEditorMagicView.GetTagList(self)
	return self.m_CmdListBox:GetTagList()
end

return CEditorMagicView