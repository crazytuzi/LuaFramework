local CEditorBuffView = class("CEditorBuffView", CViewBase)

function CEditorBuffView.ctor(self, cb)
	CViewBase.ctor(self, "UI/_Editor/EditorBuff/EditorBuffView.prefab", cb)
	self.m_DepthType = "Menu"
	--
	config = require "logic.editor.editor_buff.editor_buff_config"
	self:RedefineFunc()
end

function CEditorBuffView.OnCreateView(self)
	self.m_SaveBtn = self:NewUI(1, CButton)
	self.m_DelBtn = self:NewUI(2, CButton)
	self.m_BuffListTable = self:NewUI(3, CTable)
	self.m_BuffBtnClone = self:NewUI(4, CButton)
	self.m_EffectListTable = self:NewUI(5, CTable)
	self.m_EffectBtnClone = self:NewUI(6, CButton)
	self.m_ArgBoxClone = self:NewUI(7, CEditorNormalArgBox)
	self.m_BuffArgTable = self:NewUI(8, CTable)
	self.m_EffArgTable = self:NewUI(9, CTable)
	self.m_AddEffectBtn = self:NewUI(10, CButton)
	self.m_DelEffectBtn = self:NewUI(11, CButton)
	self.m_PreviewBtn = self:NewUI(12, CButton)

	self.m_SaveData = data.warbuffdata.DATA
	self.m_CurBuff = {}
	self.m_BuffArgBoxDict = {}
	self.m_LayerPaths = {}
	self.m_SelectEffIdx = 1
	self.m_SelectBuffId = nil
	self:InitContent()
end

function CEditorBuffView.InitContent(self)
	self.m_SaveBtn:AddUIEvent("click", callback(self, "OnSave"))
	self.m_DelBtn:AddUIEvent("click", callback(self, "OnDel"))
	self.m_AddEffectBtn:AddUIEvent("click", callback(self, "OnAddEff"))
	self.m_DelEffectBtn:AddUIEvent("click", callback(self, "OnDelEff"))
	self.m_PreviewBtn:AddUIEvent("click", callback(self, "OnPreview"))
	self.m_ArgBoxClone:SetActive(false)
	self.m_BuffBtnClone:SetActive(false)
	self.m_EffectBtnClone:SetActive(false)
	self.m_BuffArgTable:Reposition()
	warsimulate.Start(1, 160, 2300)

	self.m_CurBuff = {buff_id = 1, buff_type="normal", effect_list={{}}}
	self:RefeshArgTable("buff", self.m_CurBuff, self.m_BuffArgTable, callback(self, "OnBuffArgChange"))
	self:RefeshArgTable("effect", {}, self.m_EffArgTable, callback(self, "OnEffectArgChange"))
	self:RefreshBuffList()
	self:RefreshEffectList()
end

function CEditorBuffView.OnAddEff(self)
	table.insert(self.m_CurBuff.effect_list, {})
	self:RefreshEffectList()
end

function CEditorBuffView.OnDelEff(self)
	if #self.m_CurBuff.effect_list == 1 then
		g_NotifyCtrl:FloatMsg("至少要有一个特效")
		return 
	end
	table.remove(self.m_CurBuff.effect_list, self.m_SelectEffIdx)
	self.m_SelectEffIdx = math.max(self.m_SelectEffIdx - 1, 1)
	self:RefreshEffectList()
end

function CEditorBuffView.OnShowView(self)
	local function delay()
		local oCam = g_CameraCtrl:GetWarCamera()
		local aspect = 750 / 1334 * 1.3
		oCam:SetRect(UnityEngine.Rect.New(1-aspect, 0, aspect, aspect))
	end
	Utils.AddTimer(delay, 0, 0)
end

function CEditorBuffView.RefreshBuffList(self)
	self.m_BuffListTable:Clear()
	local list = table.keys(self.m_SaveData)
	table.sort(list)
	for i, id in ipairs(list) do
		local oBtn = self.m_BuffBtnClone:Clone()
		oBtn.m_ID = id
		oBtn:SetText(tostring(id))
		oBtn:SetActive(true)
		oBtn:SetGroup(self.m_BuffListTable:GetInstanceID())
		oBtn:AddUIEvent("click", callback(self, "OnBuffBtn"))
		if (self.m_SelectBuffId and oBtn.m_ID == self.m_SelectBuffId) or (not self.m_SelectBuffId)then
			self:OnBuffBtn(oBtn)
		end
		self.m_BuffListTable:AddChild(oBtn)
	end
	self.m_BuffListTable:Reposition()
end

function CEditorBuffView.OnBuffArgChange(self, key, value)
	if self.m_CurBuff[key] == value then
		return
	end
	self.m_CurBuff[key] = value
	self:RefeshArgTable("buff", self.m_CurBuff, self.m_BuffArgTable, callback(self, "OnBuffArgChange"))
end

function CEditorBuffView.OnEffectArgChange(self, key, value)
	if self.m_CurBuff.effect_list[self.m_SelectEffIdx][key] == value then
		return
	end
	self.m_CurBuff.effect_list[self.m_SelectEffIdx][key] = value
	local dEffect = self.m_CurBuff.effect_list[self.m_SelectEffIdx]
	self:RefeshArgTable("effect", dEffect, self.m_EffArgTable, callback(self, "OnEffectArgChange"))
end

function CEditorBuffView.RedefineFunc(self)
	CWarBuff.GetData = function()
		return self.m_CurBuff
	end
	local function nilfunc() end
	CWarOrderCtrl.Bout = nilfunc
	CWarMainView.ShowView = nilfunc
end

function CEditorBuffView.OnBuffBtn(self, oBtn)
	self.m_SelectBuffId = oBtn.m_ID
	oBtn:SetSelected(true)
	self.m_CurBuff = table.copy(self.m_SaveData[oBtn.m_ID])
	self.m_CurBuff.buff_id = oBtn.m_ID
	self:RefeshArgTable("buff", self.m_CurBuff, self.m_BuffArgTable, callback(self, "OnBuffArgChange"))
	self:RefreshEffectList()
end

function CEditorBuffView.RefreshEffectList(self)
	self.m_EffectListTable:Clear()
	for i, dEffect in ipairs(self.m_CurBuff.effect_list) do
		local oBtn = self.m_EffectBtnClone:Clone()
		oBtn.m_Idx = i
		oBtn:SetActive(true)
		oBtn:SetGroup(self.m_EffectListTable:GetInstanceID())
		oBtn:SetText(tostring(i))
		oBtn:AddUIEvent("click", callback(self, "OnEffectBtn"))
		if (self.m_SelectEffIdx and self.m_SelectEffIdx == i) or (not self.m_SelectEffIdx) then
			self:OnEffectBtn(oBtn)
		end
		self.m_EffectListTable:AddChild(oBtn)
	end

	self.m_EffectListTable:Reposition()
end

function CEditorBuffView.RefeshArgTable(self, sArgType, dCurArgData, oTable, callback)
	local arglist = self:GetShowArgList(config.arg[sArgType], dCurArgData)
	for k, v in pairs(dCurArgData) do
		local bDel = true
		for i, dArg in ipairs(arglist) do
			if dArg.key == k then
				bDel = false
				break
			end
		end
		if bDel and k ~= "effect_list" then
			dCurArgData[k] = nil
		end
	end
	oTable:Clear()
	for i, arg in ipairs(arglist) do
		local oBox =self.m_ArgBoxClone:Clone()
		oBox:SetActive(true)
		oBox:SetArgInfo(arg)
		oBox:SetValueChangeFunc(callback)
		if dCurArgData[arg.key] ~= nil then
			oBox:SetValue(dCurArgData[arg.key], true, false)
		else
			oBox:ResetDefault()
			dCurArgData[arg.key] = oBox:GetValue()
		end
		oTable:AddChild(oBox)
	end
	oTable:Reposition()
end

function CEditorBuffView.OnEffectBtn(self, oBtn)
	oBtn:SetSelected(true)
	self.m_SelectEffIdx = oBtn.m_Idx
	local dEffect = self.m_CurBuff.effect_list[self.m_SelectEffIdx]
	self:RefeshArgTable("effect", dEffect, self.m_EffArgTable, callback(self, "OnEffectArgChange"))
end

function CEditorBuffView.GetShowArgList(self, tArgs, dSetArgs)
	local list = {}
	for i, dArg in ipairs(tArgs) do
		table.insert(list, dArg)
		if dArg.refresh_args == true then
			local key = dSetArgs[dArg.key] or dArg.default
			local sublist = tArgs[key] or {}
			list = table.extend(list, self:GetShowArgList(sublist, dSetArgs))
		end
	end
	return list
end

function CEditorBuffView.OnSave(self)
	self.m_SaveData[self.m_CurBuff.buff_id] = self.m_CurBuff
	self.m_SelectBuffId = self.m_CurBuff.buff_id
	table.print(self.m_SaveData)
	self:RefreshBuffList()
	self:DataToFile()
end

function CEditorBuffView.OnDel(self)
	local d = self.m_CurBuff
	self.m_SaveData[d.buff_id] = nil
	self.m_SelectBuffId = nil
	self.m_CurBuff = {buff_id = 1, buff_type="normal", effect_list={{}}}
	self:RefreshBuffList()
	self:DataToFile()
end

function CEditorBuffView.DataToFile(self)
	local s = table.dump(self.m_SaveData, "DATA")
	local s = "module(...)\n"..s
	local path = IOTools.GetAssetPath("/Lua/logic/data/warbuffdata.lua")
	IOTools.SaveTextFile(path, s)
end

function CEditorBuffView.DelayRefresh(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
	end
	self.m_Timer = Utils.AddTimer(callback(self, "RefeshBuff"), 0, 0)
end


function CEditorBuffView.OnPreview(self)
	local dBuff = self.m_CurBuff
	table.safeset(data.buffdata.DATA, 1, dBuff.buff_id, "show_effect")
	local iLevel = self.m_CurBuff.add_cnt or #dBuff.effect_list or 1
	for i, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
		oWarrior:ClearBuff()
		oWarrior:RefreshBuff(dBuff.buff_id, 1, iLevel, false, 1)
	end
end

return CEditorBuffView