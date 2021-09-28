require "Core.Module.Common.UIComponent"
require "Core.Module.WildBoss.View.Item.WildBossRankListItem"

WildBossRankItem = class("WildBossRankItem", UIComponent);

function WildBossRankItem:New(transform, id, list)
	self = { };
	setmetatable(self, { __index = WildBossRankItem });
	self.id = id;
	self._list = list    
	if (transform) then
        transform.gameObject.name = string.format("%.3d", id);
		self:Init(transform);
	end
	return self
end

function WildBossRankItem:_Init()
	self:_InitReference();
	-- self:_InitListener();
end

function WildBossRankItem:_InitReference()
	self._txtTitle = UIUtil.GetChildByName(self._transform, "UILabel", "txtTitle")
	self._txtTitle.text = LanguageMgr.Get("WildBoss/rank/round" .. self.id);

	self._phalanxGo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "phalanx");
	self._phalanx = Phalanx:New();
	self._phalanx:Init(self._phalanxGo, WildBossRankListItem);
    
	local data = self._list;
	local count = table.getn(data);
	self._phalanx:Build(count, 1, data);	
end

function WildBossRankItem:_InitListener()

end

  
function WildBossRankItem:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function WildBossRankItem:_DisposeListener()
	
end

function WildBossRankItem:_DisposeReference()
    self.id = nil;
	self._list = nil;

	self._txtTitle = nil;
	self._phalanx:Dispose();
	self._phalanx = nil;
end