require "Core.Module.Common.UIItem"

WorldBossHurtRankItem = UIItem:New();

function WorldBossHurtRankItem:_Init()
	self._icoRank = UIUtil.GetChildByName(self.transform, "UISprite", "icoRank");
    self._txtRank = UIUtil.GetChildByName(self.transform, "UILabel", "txtRank");
	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
	self._txtHurt = UIUtil.GetChildByName(self.transform, "UILabel", "txtHurt");	
    self:UpdateItem(self.data);
end

function WorldBossHurtRankItem:_Dispose()
    self.data = nil;
    self._icoRank = nil;
    self._txtRank = nil;
	self._txtName = nil;
	self._txtHurt = nil;
end

function WorldBossHurtRankItem:UpdateItem(data)
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
