local CEditorAinmBox = class("CEditorAinmBox", CBox)

function CEditorAinmBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ArgBoxTable = self:NewUI(1, CTable)
	self.m_DescLabel = self:NewUI(2, CLabel)
	self.m_ArgBoxDict = {}
end

function CEditorAinmBox.SetIndex(self, index)
	self.m_DescLabel:SetText(tostring(index))
	self.m_Index = index
end

function CEditorAinmBox.InitContent(self)
	local lKey = {"action", "start_frame", "end_frame", "hit_frame", "speed"}
	local function initSub(obj, idx)
		local oBox = CEditorNormalArgBox.New(obj)
		local k = lKey[idx]
		local oArgInfo = config.arg.template[k]
		oBox:SetArgInfo(oArgInfo)
		if oArgInfo.change_refresh then
			oBox:SetValueChangeFunc(callback(self, "OnArgChange"))
		end
		self.m_ArgBoxDict[k] = oBox
		return oBox
	end
	self.m_ArgBoxTable:InitChild(initSub)
end

function CEditorAinmBox.OnArgChange(self, k)
	if self.m_ChangeCB then
		self.m_ChangeCB(k)
	end
end

function CEditorAinmBox.SetChangeCallback(self, f)
	self.m_ChangeCB = f
end

function CEditorAinmBox.GetData(self)
	local d = {}
	for k, oBox in pairs(self.m_ArgBoxDict) do
		local v = oBox:GetValue() 
		d[k] = v
	end
	return d
end

function CEditorAinmBox.Refresh(self, d)
	table.print(d)
	for k, oBox in pairs(self.m_ArgBoxDict) do
		local v = d[k] == "nil" and "" or d[k]
		if v then
			oBox:SetValue(v, true)
		else
			oBox:ResetDefault(v, true)
		end
	end
end

function CEditorAinmBox.SetDefalut(self)
	for k, oBox in pairs(self.m_ArgBoxDict) do
		oBox:ResetDefault()
	end
end

function CEditorAinmBox.GetDuration(self)
	local iStart = tonumber(self.m_ArgBoxDict["start_frame"]:GetValue()) or 0
	local iEnd = tonumber(self.m_ArgBoxDict["end_frame"]:GetValue()) or 0
	local iSpeed = tonumber(self.m_ArgBoxDict["speed"]:GetValue()) or 1
	return ((iEnd - iStart)) / iSpeed
end

return CEditorAinmBox