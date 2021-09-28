require "Core.Module.Common.UIItem"
require "Core.Module.Pet.View.Item.PetSkillItem"

local PetSkillGroupItem = class("PetSkillGroupItem", UIItem)

function PetSkillGroupItem:_Init()
	
	self._skillItems = {}
	for i = 1, 5 do
		local item = UIUtil.GetChildByName(self.transform, "skillItem" .. i).gameObject
		self._skillItems[i] = PetSkillItem:New()
		self._skillItems[i]:Init(item.gameObject)
	end	
end

function PetSkillGroupItem:UpdateItem(data)
	self.data = data
	if(self.data) then
		local skillCount = #self.data
		for i = 1, 5 do
			-- if(i <= skillCount) then
			-- 	self._skillItems[i]:SetActive(true)
				self._skillItems[i]:UpdateItem(self.data[i])
			-- else
			-- 	self._skillItems[i]:SetActive(false)
			-- end
		end		
	-- else
	-- 	for i = 1, 5 do
	-- 		self._skillItems[i]:SetActive(false)
	-- 	end
	end
end

function PetSkillGroupItem:UnSetGray()
	for i = 1, 5 do
		self._skillItems[i]:UnSetGray(false)
	end
end

function PetSkillGroupItem:_Dispose()
	for i = 1, 5 do	
		self._skillItems[i]:Dispose()
	end
	self._skillItems = nil
end

return PetSkillGroupItem

