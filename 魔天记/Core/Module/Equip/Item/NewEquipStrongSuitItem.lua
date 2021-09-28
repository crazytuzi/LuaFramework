require "Core.Module.Common.UIItem"


local NewEquipStrongSuitItem = UIItem:New();
local greenCode = "[" .. ColorDataManager.ConventToColorCode(ColorDataManager.Get_green()) .. "]"
local grayCode = "[" .. ColorDataManager.ConventToColorCode(ColorDataManager.Get_greyf()) .. "]"

function NewEquipStrongSuitItem:_Init()
	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
	self._txtJindu = UIUtil.GetChildByName(self.transform, "UILabel", "jindu")
	self._txtAttrList = UIUtil.GetChildByName(self.transform, "UILabel", "list")
	
	self:UpdateItem(self.data)
end

function NewEquipStrongSuitItem:_Dispose()
	
end

function NewEquipStrongSuitItem:UpdateItem(data)
	self.data = data;

	if(self.data) then
		local isAttch =(self.data.id == NewEquipStrongManager.GetPlusId())
		self._txtName.text = self.data.desc
		self._txtJindu.text = "(" .. NewEquipStrongManager.GetAllSuiteCountByLevel(data.min_lev) .. "/" .. self.data.item_num .. ")"
		
		local attr = self.data.attr:GetPropertyAndDes()
		
		local list = ""
		local count = table.getCount(attr)
		if(not isAttch) then
			list = list .. grayCode
		end
		
		for i = 1, count do		
			if(isAttch) then		
				list = list .. attr[i].des .. ": " .. greenCode .. "+" .. attr[i].property .. attr[i].sign .. "[-]"
			else
				list = list .. attr[i].des .. ": +" .. attr[i].property .. attr[i].sign
			end
			
			if(i ~= count) then
				list = list .. "\n"
			end				
		end	
		
		if(not isAttch) then
			list = list .. "[-]"
		end
		
		self._txtAttrList.text = list
		
	end	
end

return NewEquipStrongSuitItem 