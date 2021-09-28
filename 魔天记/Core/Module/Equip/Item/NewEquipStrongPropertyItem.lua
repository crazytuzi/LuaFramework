require "Core.Module.Common.UIItem"


NewEquipStrongPropertyItem = UIItem:New();

function NewEquipStrongPropertyItem:_Init()
	self._txtPro = UIUtil.GetChildByName(self.transform, "UILabel", "pro")
	self._txtProAdd = UIUtil.GetChildByName(self.transform, "UILabel", "proAdd")	
	self._goAdd = UIUtil.GetChildByName(self.transform, "up").gameObject
	self:UpdateItem(self.data)
end

function NewEquipStrongPropertyItem:_Dispose()
 
end


function NewEquipStrongPropertyItem:UpdateItem(data)
	self.data = data;
	if(self.data) then
		self._txtPro.text = self.data.des .. " : " .. self.data.property.. "    [77ff47]+" .. self.data.curAdd .."[-]"
		if(self.data.nextAdd) then
			self._txtProAdd.text = "+" .. self.data.nextAdd
			self._goAdd:SetActive(true)
		else
			self._txtProAdd.text = ""
			self._goAdd:SetActive(false)
		end
		
	end	
end
 
