require "Core.Module.Common.UIItem"

PetSkillItem = class("PetSkillItem", UIItem)

function PetSkillItem:UpdateItem(data)
	self.data = data
	
	if(self.data) then
		
		self._imgIcon.spriteName = data.info.icon_id
		self._imgQuality.color = ColorDataManager.GetColorByQuality(data.info.quality)
		if(self.data.active) then
			ColorDataManager.UnSetGray(self._imgIcon)	
			ColorDataManager.UnSetGray(self._imgQuality)
		else
			ColorDataManager.SetGray(self._imgIcon)
			ColorDataManager.SetGray(self._imgQuality)
		end
	else
		self._imgIcon.spriteName = ""
		self._imgQuality.color = ColorDataManager.GetColorByQuality(0)
	end
	-- if (self.data and currentPetdata:GetRank() >= data.unlockRank) then    
	--     if (data.info ~= nil) then
	--         self._imgIcon.gameObject:SetActive(true) 
	--         self._imgIcon.spriteName = data.info.icon_id
	--         if (self._imgQuality.spriteName ~= "quality_circle0") then
	--             self._imgQuality.spriteName = "quality_circle0"
	--         end
	--         self._imgQuality.color = ColorDataManager.GetColorByQuality(data.info.quality)
	--     else 
	--         self._imgIcon.gameObject:SetActive(false)            
	--         if (self._imgQuality.spriteName ~= "skill_bg") then
	--             self._imgQuality.spriteName = "skill_bg"              
	--         end
	--         self._imgQuality.color = ColorDataManager.GetColorByQuality(0)
	--     end
	-- else
	--     if (self._imgQuality.spriteName ~= "skill_bg") then
	--         self._imgQuality.spriteName = "skill_bg"
	--     end
	--     self._imgIcon.gameObject:SetActive(false) 
	--     self._imgQuality.color = ColorDataManager.GetColorByQuality(0)
	-- end
end

function PetSkillItem:_Init(gameObject, data)
	self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "imgSkillIcon");
	self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "imgQuality");
	self:_AddBtnListen(self._imgIcon.gameObject)
	-- self._onClickImgIcon = function(go) self:_OnClickImgIcon(self) end
	-- UIUtil.GetComponent(self._imgIcon.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickImgIcon);
	self:UpdateItem(self.data);
end

function PetSkillItem:UnSetGray()
	ColorDataManager.UnSetGray(self._imgIcon)	
	ColorDataManager.UnSetGray(self._imgQuality)
end

function UIItem:_OnBtnsClick(go)
	if(go == self._imgIcon.gameObject) then
		self:_OnClickImgIcon()
	end
end

function PetSkillItem:_OnClickImgIcon()
	if(self.data) then
		ModuleManager.SendNotification(PetNotes.OPEN_PETSKILLDESPANEL, self.data)
	end
end

function PetSkillItem:_Dispose()
	UIUtil.GetComponent(self._imgIcon.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickImgIcon = nil;
end

