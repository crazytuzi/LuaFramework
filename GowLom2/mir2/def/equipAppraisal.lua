local equipAppraisal = {
	getAtrNameById = function (self, id)
		local atrName = def.items.key2ValueName[id]

		if atrName then
			return atrName
		end

		return "Î´ÖªÊôÐÔ"
	end,
	getAppraisalAtr = function (self, data)
		local atrT = {}

		if not data.FItemValueList then
			return atrT
		end

		for k, v in ipairs(data.FItemValueList) do
			if 59 <= v.FValueType and v.FValueType <= 77 and v.FValueType ~= 73 then
				local valueType = v.FValueType
				local val = v.FValue

				table.insert(atrT, self.getAtrNameById(self, valueType) .. "|" .. val)
			end
		end

		return atrT
	end,
	getAppraisalDesc = function (self, curAppraisalAtr)
		local descT = {}

		for k, v in ipairs(curAppraisalAtr) do
			local Atrstr = string.split(v, "|")

			if Atrstr and #Atrstr == 2 then
				table.insert(descT, Atrstr[1] .. "+" .. Atrstr[2])
			end
		end

		return descT
	end
}

return equipAppraisal
