_G.ShampublicityModel = Module:new()
ShampublicityModel.Shampublicity = nil
ShampublicityModel.strList = {}

function ShampublicityModel:Enter(type)
	if 1 then return end
	self.Shampublicity = type
	if UIShampublicity:IsShow() then
		UIShampublicity:Resize()
	else
		UIShampublicity:Show()
	end
end

function ShampublicityModel:Out()
	self.Shampublicity = nil
	self.Font = nil
	UIShampublicity:Hide()
end

function ShampublicityModel:GetShampublicity()
	return self.Shampublicity
end

function ShampublicityModel:AddStr()
	local name = t_shampublicityname[math.random(#t_shampublicityname)].name or ""
	local text = string.format(ShampublicConsts.s_str, name, self:GetRandomText())
	table.push(self.strList, text)
	if #self.strList > ShampublicConsts.count then
		table.remove(self.strList, 1)
	end
end

function ShampublicityModel:GetRandomText()
	--随机一个文本
	local allWeight = 0
	for k, v in ipairs(t_shampublicitytext) do
		if not v.weight then t_shampublicitytext[k].weight = 100 end
		allWeight = allWeight + v.weight
	end
	local ranWeight = math.random(allWeight)

	local addWeight = 0
	for k, v in ipairs(t_shampublicitytext) do
		addWeight = addWeight + v.weight
		if addWeight >= ranWeight then
			return v.name
		end
	end
	return ""
end

function ShampublicityModel:GetStr()
	self:AddStr()
	local showStr = ""
	for i = 1, ShampublicConsts.count do
		local str = self.strList[i]
		if str then
			showStr = showStr .. str
		else
			return showStr
		end
		if i == ShampublicConsts.count then
			return showStr
		end
		showStr = showStr .. "\n"
	end
end