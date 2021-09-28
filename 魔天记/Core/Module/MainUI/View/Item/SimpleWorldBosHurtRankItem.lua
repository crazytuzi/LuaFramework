require "Core.Module.Common.UIItem"

SimpleWorldBosHurtRankItem = UIItem:New();

function SimpleWorldBosHurtRankItem:_Init()
	self._icoRank = UIUtil.GetChildByName(self.transform, "UISprite", "icoRank");
    self._txtRank = UIUtil.GetChildByName(self.transform, "UILabel", "txtRank");
	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
	self._txtHurt = UIUtil.GetChildByName(self.transform, "UILabel", "txtHurt");	
	self._imgFlag = UIUtil.GetChildByName(self.transform, "UISprite", "imgFlag");
    self:UpdateItem(self.data);
end

function SimpleWorldBosHurtRankItem:_Dispose()
    self._icoRank = nil;
    self._txtRank = nil;
	self._txtName = nil;
	self._txtHurt = nil;
	self._imgFlag = nil;
end

function SimpleWorldBosHurtRankItem:UpdateItem(data)
    self.data = data;
	if (data and self._txtRank) then
		if (data.id > 3) then
			self._txtRank.text = data.id;
		else
			self._icoRank.spriteName = "no"..data.id;
			self._icoRank.gameObject:SetActive(true);
		end
		self._txtName.text = data.pn;
		self._txtHurt.text = data.h;
	end
end
