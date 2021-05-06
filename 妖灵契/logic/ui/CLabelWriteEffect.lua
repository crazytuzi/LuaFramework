local CLabelWriteEffect = class("CLabelWriteEffect", CLabel)

function CLabelWriteEffect.ctor(self, obj)
	CLabel.ctor(self, obj)
	self.m_Speed = 2
	self.m_Text = {}
	self.m_EffectTimer = nil
	self.m_FinishCb = nil
	self.m_StartCb = nil
	self.m_CurIndex = 0
	self.m_UpdateDelta = 0.1
	self.m_TotalIndex = 0
	self.m_ColorStr = "ffffff"
	self.m_MaskIdx = {}			--富文本颜色的位置	
	self.m_MaskJumpIdx = {}		--富文本颜色跳过的个数
	self.m_IsPause = false
end

function CLabelWriteEffect.InitLabel(self, config)
	self.m_FinishCb = config.FinishCallBack
	self.m_StartCb = config.StartCallBack
end

function CLabelWriteEffect.SetEffectText(self, text, isOpen)		
	if self.m_EffectTimer ~= nil then
		Utils.DelTimer(self.m_EffectTimer)
		self.m_EffectTimer = nil
	end	
	if not self:GetActive() then
		self:SetText(text)
		return
	end

	if isOpen == false then		
		self:SetText(text)
		if self.m_FinishCb then
			self.m_FinishCb()
		end
	else
		if self.m_StartCb then
			self.m_StartCb()
		end

		self.m_Text = string.getutftable(text)
		self.m_CurIndex = 0			
		self.m_TotalIndex = #self.m_Text
		self.m_EffectTimer = Utils.AddTimer(callback(self, "LocalUpdate"), self.m_UpdateDelta, 0)
		self:InitMskIdx(text)
	end	
end

function CLabelWriteEffect.LocalUpdate(self)
	if Utils.IsNil(self) then
		return false
	end
	local b = self:SetUpdateText()
	if b == false and self.m_FinishCb then
		self.m_FinishCb()
	end
	return b
end

function CLabelWriteEffect.SetUpdateText(self)
	if self.m_IsPause then
		return true
	end
	local step = 4
	self.m_CurIndex = self.m_CurIndex + self.m_Speed
	if self.m_CurIndex > self.m_TotalIndex + step then
		self.m_CurIndex = self.m_TotalIndex + step
	end
	local str = ""
	local color = 
	{
		[0] = "00",
		[1] = "44",
		[2] = "88",
		[3] = "aa",
		[4] = "ff",
		[5] = "ff",
	}
	for i = 1, self.m_TotalIndex + step do 
		local s = self.m_Text[i]
		if not s then
			s = ""
		end
		if i > self.m_CurIndex then
			break
		end	

		--处于渐变色区间
		if self.m_CurIndex - i >= 0 and self.m_CurIndex - i < step then
			--如果当前的字是富文本中的，则不截取该字符
			if self.m_MaskIdx[i] == "[-]" then
				str = str .. "[-]"
			elseif self.m_MaskIdx[i] then
				self.m_ColorStr = self.m_MaskIdx[i]
				str = str .. "[".. self.m_ColorStr.. color[self.m_CurIndex-i].."]"
			else
				str = str .. "[".. self.m_ColorStr.. color[self.m_CurIndex-i].."]".. s .."[-]"
			end 				
		else
			--如果当前的字是富文本中的，则不截取该字符,并且让后面的字颜色变为该颜色
			if self.m_MaskIdx[i] == "[-]" then
				str = str .. "[-]"
			elseif self.m_MaskIdx[i] then
				str = str.."[" .. self.m_MaskIdx[i] .."ff]"
			else
				str = str..s
			end
		end
	end
	--如果该字处于富文本中的字，则跳过富文本的个数
	if self.m_MaskJumpIdx[self.m_CurIndex] then
		self.m_CurIndex = self.m_CurIndex + self.m_MaskJumpIdx[self.m_CurIndex]
	end 
	self:SetText(str)
	return (self.m_CurIndex < self.m_TotalIndex + step)
end

function CLabelWriteEffect.SetFinsh(self)
	if self.m_EffectTimer ~= nil then
		Utils.DelTimer(self.m_EffectTimer)
		self.m_EffectTimer = nil
	end
	local str = ""
	for i = 1, self.m_TotalIndex do 
		str = str..self.m_Text[i]
	end	
	self:SetText(str)
	if self.m_FinishCb then
		self.m_FinishCb()
	end	
end

function CLabelWriteEffect.Destroy(self)
	if self.m_EffectTimer ~= nil then
		Utils.DelTimer(self.m_EffectTimer)
		self.m_EffectTimer = nil
	end
	CObject.Destroy(self)
end

--10进制转16进制字符串
function CLabelWriteEffect.ConverToOx(self, n)
	n = math.floor(tonumber(n))
	local t = 
	{
		["0"] ="00",
		["1"] ="01",
		["2"] ="02",
		["3"] ="03",
		["4"] ="04",
		["5"] ="05",
		["6"] ="06",
		["7"] ="07",
		["8"] ="08",
		["9"] ="09",
		["a"] ="0a",
		["b"] ="0b",
		["c"] ="0c",
		["d"] ="0d",
		["e"] ="0e",
		["f"] ="0f",
	}
	local s = string.format("%#x", tonumber(n))
	s = string.gsub(s, "0x", "")
	if t[s] then
		s = t[s]
	end
	return s
end

function CLabelWriteEffect.InitMskIdx(self, text)
	self.m_MaskIdx = {}
	self.m_MaskJumpIdx = {}
	for i = 1, #self.m_Text do
		--字符串中带有 #R #G #B
		if self.m_Text[i] == "#" and self.m_Text[i + 1] then
			local str = "#"..tostring(self.m_Text[i + 1])
			if data.colordata.COLORINDARK_2[str] then
				self.m_MaskIdx[i] = data.colordata.COLORINDARK_2[str]
				self.m_MaskIdx[i + 1] = data.colordata.COLORINDARK_2[str]
				self.m_MaskJumpIdx[i] = 1
			elseif str == "#n" then
				self.m_MaskIdx[i] = "[-]"
				self.m_MaskIdx[i + 1] = "[-]"
				self.m_MaskJumpIdx[i] = 1
			end
		--字符中带有[ffffff]
		elseif self.m_Text[i] == "[" and self.m_Text[i + 7] and self.m_Text[i + 7] == "]" then
			local str = ""
			for k = i + 1, i + 6 do
				if not self.m_Text[k] then
					break
				else
					str = str .. self.m_Text[k]
				end
			end
			if string.len(str) == 6 then
				for k = i, i + 8 do
					self.m_MaskIdx[k] = str
				end				
				self.m_MaskJumpIdx[i] = 7
			end
		end
	end
end

function CLabelWriteEffect.SetPause(self, b)
	self.m_IsPause = b
end

return CLabelWriteEffect
