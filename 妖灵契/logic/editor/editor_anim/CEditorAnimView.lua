local CEditorAnimView = class("CEditorAnimView", CViewBase)

function CEditorAnimView.ctor(self, cb)
	CViewBase.ctor(self, "UI/_Editor/EditorAnim/EditorAnimView.prefab", cb)
	self.m_DepthType = "Menu"
	--
	config = require "logic.editor.editor_anim.editor_anim_config"
	self:RedefineFunc()
end

function CEditorAnimView.RedefineFunc(self)
	local function nilfunc() end
	CWarOrderCtrl.Bout = nilfunc
	CWarMainView.ShowView = nilfunc
	CViewCtrl.CloseAll  = nilfunc
	CWarCtrl.GetRoot=function(o)
		if not o.m_Root then
			o.m_Root = CWarRoot.New()
			o.m_Root:SetPos(Vector3.New(2.65, -2.4, 0))
		end
		return o.m_Root
	end
	local oldGetData = CMagicCtrl.GetFileData
	CMagicCtrl.GetFileData = function (a1,a2,a3)
		local dData = oldGetData(a1,a2,a3)
		self.m_SequenceBox:RefreshTotalFrame()
		printc(self.m_SequenceBox.m_TotalFrame)
		local time = ModelTools.FrameToTime(self.m_SequenceBox.m_TotalFrame)
		dData.event = {
			hit = nil,
			hurt = nil,
			endhit = dData.cmds[2].start_time+time+0.1,
		}
		table.print(dData.event)
		return dData
	end
	CActor.PlayCombo = function(o)
		local list = self.m_SequenceBox:GetSequence()
		o.m_ComboActList = list
		o.m_ComboIdx = 1
		o:ComboStep()
		return true
	end
end

function CEditorAnimView.OnCreateView(self)
	self.m_SequenceBox = self:NewUI(1, CEditorAnimSequence)
	self.m_AttackBtn = self:NewUI(2, CButton)
	self.m_PlayBtn = self:NewUI(3, CButton)
	self.m_SaveBtn = self:NewUI(4, CButton)
	self.m_ArgBoxTable = self:NewUI(5, CTable)
	self.m_DelBtn = self:NewUI(6, CButton)
	self.m_ArgBoxDict = {}
	self.m_UserCache = {}
	self.m_SaveData = {}
	self:InitContent()
end

function CEditorAnimView.InitContent(self)
	self.m_AttackBtn:AddUIEvent("click", callback(self, "OnAttack"))
	self.m_PlayBtn:AddUIEvent("click", callback(self, "OnPlay"))
	self.m_SaveBtn:AddUIEvent("click", callback(self, "OnSave"))
	self.m_DelBtn:AddUIEvent("click", callback(self, "OnDel"))
	local lKey = {"shape", "name"}
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
	self.m_SaveData = table.copy(data.comboactdata.DATA)

	local dUserCache = IOTools.GetClientData("editor_anim")
	if dUserCache then
		self.m_UserCache = dUserCache
		for k, oBox in ipairs(self.m_ArgBoxTable:GetChildList()) do
			local v = dUserCache[oBox:GetKey()]

			if v ~= nil then
				oBox:SetValue(v, true)
			end
		end
	end
	self:CheckResetData()
	self.m_SequenceBox:SetFrameRefreshCB(function()
		local iShape = self.m_ArgBoxDict["shape"]:GetValue()
		local sName = self.m_ArgBoxDict["name"]:GetValue()
		if tonumber(iShape) and tostring(sName) ~= "nil" then
			local d = self.m_SequenceBox:GetSequence()
			if self.m_SaveData[iShape] then
				self.m_SaveData[iShape][sName] = d
			end
		end
	end)
	self:StartWar()
	self.m_InitDone = true
end

function CEditorAnimView.StartWar(self)
	local iShape = self.m_ArgBoxDict["shape"]:GetValue()
	iShape = tonumber(iShape) or 1110
	warsimulate.Start(1, iShape)
end

function CEditorAnimView.OnArgChange(self, iFlag, key, value)
	if not self.m_InitDone then
		return
	end
	self:SetUserCache(key, self.m_ArgBoxDict[key]:GetValue())
	self:CheckResetData()
	if iFlag == 2 then
		self:StartWar()
	end
end

function CEditorAnimView.CheckResetData(self)
	local iShape = self.m_ArgBoxDict["shape"]:GetValue()
	local sName = self.m_ArgBoxDict["name"]:GetValue()
	if tonumber(iShape) and tostring(sName) ~= "nil" then
		local d = self.m_SaveData[iShape]
		if d and d[sName] then
			self.m_SequenceBox:Refresh(d[sName])
		end
	end
end

function CEditorAnimView.SetUserCache(self, key, val)
	local oldVal = self.m_UserCache[key]
	if not table.equal(oldVal, val) then
		self.m_UserCache[key] = val
		IOTools.SetClientData("editor_anim", self.m_UserCache)
		return true
	else
		return false
	end
end

function CEditorAnimView.OnAttack(self)
	warsimulate.NormalAttack(1, 15)
end

function CEditorAnimView.OnSave(self)
	self:SaveToFile()
end

function CEditorAnimView.SaveToFile(self)
	local d = self.m_SequenceBox:GetSequence()
	local iShape = self.m_ArgBoxDict["shape"]:GetValue()
	local sName = self.m_ArgBoxDict["name"]:GetValue()
	if not sName or sName == "" then
		self.m_SaveData[iShape] = nil
	else
		if not self.m_SaveData[iShape] then
			self.m_SaveData[iShape] = {}
		end
		self.m_SaveData[iShape][sName] = d
	end
	local path = IOTools.GetAssetPath("/Lua/logic/data/comboactdata.lua")
	local s = "module(...)\n--anim editor build\n"..table.dump(self.m_SaveData, "DATA")
	IOTools.SaveTextFile(path, s)
	g_NotifyCtrl:FloatMsg("保存成功  "..path)
	self:CheckResetData()
end

function CEditorAnimView.OnPlay(self)
	g_WarCtrl.m_VaryCmd = nil
	g_WarCtrl.m_CmdList = {}
	g_WarCtrl.m_MainActionList = {}
	g_WarCtrl.m_SubActionsDict = {}
	g_MagicCtrl:Clear("war")
	for i, wid in ipairs({1,15}) do
		local oWarrior = g_WarCtrl:GetWarrior(wid)
		if oWarrior then
			oWarrior:SetLocalPos(oWarrior.m_OriginPos)
		end
	end
	warsimulate.Magic(10001, 1, {1}, {15})
end

function CEditorAnimView.OnDel(self)
	local iShape = self.m_ArgBoxDict["shape"]:GetValue()
	local sName = self.m_ArgBoxDict["name"]:GetValue()
	if tonumber(iShape) and tostring(sName) ~= "nil" then
		self.m_SaveData[iShape][sName] = nil
	end
	local path = IOTools.GetAssetPath("/Lua/logic/data/comboactdata.lua")
	local s = "module(...)\n--anim editor build\n"..table.dump(self.m_SaveData, "DATA")
	IOTools.SaveTextFile(path, s)
	g_NotifyCtrl:FloatMsg("删除成功  ")
	self.m_ArgBoxDict["name"]:SetValue("",true)
	self.m_SequenceBox:Clear()
end

function CEditorAnimView.GetAnimSequenceName(self)
	local iShape = self.m_ArgBoxDict["shape"]:GetValue()
	local d = self.m_SaveData[iShape]
	local list = {}
	if iShape and d then
		for k, v in pairs(d) do
			table.insert(list, k)
		end
	end
	return list
end

return CEditorAnimView