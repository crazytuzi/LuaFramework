require "Core.Module.Common.UIItem"

local PetItem = UIItem:New();

function PetItem:_Init()
	--    self.gameObject = gameObject
	--    self.data = data
	self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "petPetIcon");
	self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "petQuality");
	self._goFightTag = UIUtil.GetChildByName(self.transform, "fightTag").gameObject
	self._goCanActiveTag = UIUtil.GetChildByName(self.transform, "canActiveTag").gameObject
	self._goCanUpdate = UIUtil.GetChildByName(self.transform, "canUpdate").gameObject
	-- self._collider = UIUtil.GetComponent(self.transform, "BoxCollider")
	self._toggle = UIUtil.GetComponent(self.transform, "UIToggle")
	self._goTip = UIUtil.GetChildByName(self.transform, "tip").gameObject
	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
	self._txtCombine = UIUtil.GetChildByName(self.transform, "UILabel", "txtCombine")
	self._txtLevelName = UIUtil.GetChildByName(self.transform, "UILabel", "levelName")
	self._onClickBtnIcon = function(go) self:_OnClickBtnIcon(self) end	
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnIcon);
	self:UpdateItem(self.data);
end

function PetItem:UpdateItem(data)
	self.data = data
	if(data) then
		self._imgIcon.spriteName = data:GetIcon()
		if(self.data:GetIsActive()) then
			self._txtCombine.text = ""
			ColorDataManager.UnSetGray(self._imgIcon)
			self._goCanActiveTag:SetActive(false)
			self._txtLevelName.text = data:GetLevelName()
			self._goCanUpdate:SetActive(data:GetCanUpdate())
			
		else
			self._txtCombine.text =(BackpackDataManager.GetProductTotalNumBySpid(data:GetActiveNeedItemId()) .. "/" .. data:GetActiveNeedItemCount())
			ColorDataManager.SetGray(self._imgIcon)
			self._goCanActiveTag:SetActive(BackpackDataManager.GetProductTotalNumBySpid(data:GetActiveNeedItemId()) >= data:GetActiveNeedItemCount())
			self._txtLevelName.text = ""
			self._goCanUpdate:SetActive(false)
			
		end
		self._goTip:SetActive(self.data:GetCanUpdate() or self.data:GetCanActive())
		self._imgQuality.color = ColorDataManager.GetColorByQuality(data:GetQuality())
		self._goFightTag:SetActive(data:GetId() == PetManager.GetCurUsePetId())
		self._txtName.text = data:GetName()
		self._txtName.color = ColorDataManager.GetColorByQuality(data:GetQuality())
		
	end
end

local activeNotice = LanguageMgr.Get("Pet/isActiveCurrentPet")
function PetItem:_OnClickBtnIcon()
	if(self.data == nil) then return end
	-- local temp = self.data:GetSynthesisInfo()
	-- if(BackpackDataManager.GetProductTotalNumBySpid(temp.itemId) >= temp.itemCount and not self.data:GetIsActive()) then
	-- 	ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
	-- 		msg = activeNotice,
	-- 		ok_Label = LanguageMgr.Get("common/agree"),
	-- 		hander = PetProxy.SendCombinePet
	-- 	});
	-- end
	-- PetManager.SetCurrentPet(self.data.id)
	ModuleManager.SendNotification(PetNotes.UPDATE_PETFASHIONPANEL, self.data)
end

function PetItem:SetToggleActive(enable, click)
	self._toggle.value = enable
	if(enable and click) then
		self:_OnClickBtnIcon()
	end
end

function PetItem:_Dispose()
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnIcon = nil;
end

return PetItem
