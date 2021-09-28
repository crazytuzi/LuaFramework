require "Core.Module.Common.UIItem"

WildBossHurtRankItem = UIItem:New();

function WildBossHurtRankItem:_Init()
	self._icoRank = UIUtil.GetChildByName(self.transform, "UISprite", "icoRank");
    self._txtRank = UIUtil.GetChildByName(self.transform, "UILabel", "txtRank");
	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
	self._txtHurt = UIUtil.GetChildByName(self.transform, "UILabel", "txtHurt");	
    self:UpdateItem(self.data);
end

function WildBossHurtRankItem:_Dispose()
    self._icoRank = nil;
    self._txtRank = nil;
	self._txtName = nil;
	self._txtHurt = nil;
end

function WildBossHurtRankItem:UpdateItem(data)
    self.data = data;
	if (data and self._txtRank) then
		if (data.id > 3) then
			self._txtRank.text = data.id;
		else
			self._icoRank.spriteName = "no"..data.id;
			self._icoRank.gameObject:SetActive(true);
		end
		self._txtName.text = data.n;
		self._txtHurt.text = data.h;
	end
end
