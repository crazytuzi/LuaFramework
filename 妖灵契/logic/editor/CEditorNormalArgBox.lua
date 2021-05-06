local CEditorNormalArgBox = class("CEditorNormalArgBox", CEditorArgBoxBase)
-- local info = {
-- 	name = "",
-- 	k = "",
-- 	select = {}, or func,
-- 	wrap = {} or func,
-- 	format = "int",
-- 	default = {,} or int,
-- 	width = number or nil,
-- }

function CEditorNormalArgBox.ctor(self, obj)
	CEditorArgBoxBase.ctor(self, obj)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_Input = self:NewUI(2, CInput)
	self.m_SelBtn = self:NewUI(3, CButton)
	self.m_InfoDict = {}
	self.m_Value = nil
	self.m_Key = nil
	self.m_LastInputText = nil
	self.m_SelBtn:AddUIEvent("click", callback(self, "OnSel"))
	self.m_Input:AddUIEvent("focuschange", callback(self, "OnInputChange"))
	self.m_Input:AddUIEvent("submit", callback(self, "OnInputChange"))
end

function CEditorNormalArgBox.SetArgInfo(self, dInfo)
	self:SetKey(dInfo.key)
	self.m_InfoDict = dInfo
	if dInfo.select_type then
		local list = config.select[dInfo.select_type]
		local selectlist = {}
		local wraplist = {}
		for i, v in ipairs(list) do
			table.insert(selectlist, v[1])
			table.insert(wraplist, v[2])
		end
		dInfo.select = selectlist
		dInfo.wrap = wraplist
	elseif type(dInfo.select) == "function" then
		dInfo.select = dInfo.select()
	end
	self:CreateWrapFunc()
	self:Refresh()
end

function CEditorNormalArgBox.Refresh(self)
	local info = self.m_InfoDict
	if info.input_width then
		self.m_Input:SetWidth(info.input_width)
	end
	self.m_NameLabel:SetText(info.name)
	if info.select or info.select_update then
		if not info.force_input then
			self.m_Input:EnableTouch(false)
		end
		self.m_SelBtn:SetActive(true)
	else
		self.m_Input:EnableTouch(true)
		self.m_SelBtn:SetActive(false)
	end
end

function CEditorNormalArgBox.OnSel(self)
	local info = self.m_InfoDict
	local function sel(v)
		self:SetValue(v, true, true) 
	end
	local list = info.select
	if info.select_update then
		list = info.select_update()
	end
	CMiscSelectView:ShowView(function(oView)
			oView:SetData(list, sel, self.m_WrapFunc)
		end)
end

function CEditorNormalArgBox.CreateWrapFunc(self)
	local info = self.m_InfoDict
	
	if type(info.wrap) == "table" then
		self.m_WrapFunc = function (v) 
							local s = info.wrap[table.index(info.select, v)]
							if s then
								return s
							else
								return v
							end
						end
	elseif type(info.wrap) == "function" then
		self.m_WrapFunc = info.wrap
	else
		if info.format == "list_type" then
			self.m_WrapFunc = function(v) return table.concat(v, ",") end
		else
			self.m_WrapFunc = function(v) return tostring(v) end
		end
	end
end

function CEditorNormalArgBox.OnInputChange(self)
	local v = self.m_Input:GetText()
	if self.m_LastInputText ~= v then
		self.m_LastInputText = v
		self:SetValue(v, false, true)
	end
end

function CEditorNormalArgBox.SetValueChangeFunc(self, f)
	self.m_ValueChangeFunc = f
end

function CEditorNormalArgBox.SetValue(self, v, bInput, bCallback)
	local v = self:FormatValue(v)
	if bInput then
		if v == nil then
			self.m_Input:SetText("nil")
		else
			self.m_Input:SetText(self.m_WrapFunc(v))
		end
	end
	self.m_Value = v
	if bCallback == nil then
		bCallback = true
	end
	if bCallback then
		if self.m_ValueChangeFunc then
			self.m_ValueChangeFunc(self.m_Key, self.m_Value)
		end
		if self.m_InfoDict.refresh_args then
			local oBulidView = CEditorMagicBuildCmdView:GetView()
			if oBulidView then
				oBulidView:RefreshArgTable()
			end
		end
	end
end

function CEditorNormalArgBox.GetValue(self)
	if self.m_Value == "nil" then
		return nil
	else
		return self.m_Value
	end
end

function CEditorNormalArgBox.GetArgData(self)
	return {[self.m_Key] = self:GetValue()}
end

function CEditorNormalArgBox.FormatValue(self, v)
	local format = self.m_InfoDict.format
	if v == '' then
		return nil
	end
	if format == "number_type" then
		return tonumber(v)
	elseif format == "str_type" then
		return tostring(v)
	elseif format == "list_type" then
		if type(v) == "string" then
			local list = string.split(v, ",")
			for i, v in ipairs(list) do
				list[i] = tonumber(v)
			end
			return list
		elseif type(v) == "table" then
			return v
		else
			print("err list", v)
			return {}
		end
	else
		return v
	end
end

function CEditorNormalArgBox.ResetDefault(self)
	if self.m_InfoDict.default ~= nil then
		self:SetValue(self.m_InfoDict.default, true, false)
	end
end

function CEditorNormalArgBox.ClearInput(self)
	self.m_Input:SetText("")
end

return CEditorNormalArgBox