require "Core.Module.Common.Panel"
require "Core.Module.WildBoss.View.Item.WildBossHurtRankItem"

WildBossHurtRankPanel = class("WildBossHurtRankPanel", Panel);
function WildBossHurtRankPanel:New()
	self = { };
	setmetatable(self, { __index = WildBossHurtRankPanel });
	return self
end 

function WildBossHurtRankPanel:_Init()
	self:_InitReference();
	self:_InitListener();	
end

function WildBossHurtRankPanel:_InitReference()
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
	local txtTitle = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTitle");
	txtTitle.text = LanguageMgr.Get("WildBoss/hurtrank/title")
	
	self._txtMyRank = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtMyRank");
	self._txtMyHurt = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtMyHurt");

	self._trsList = UIUtil.GetChildByName(self._trsContent, "Transform", "trsList");
	self._scrollView = UIUtil.GetComponent(self._trsList, "UIScrollView");
	self._scrollPanel = UIUtil.GetComponent(self._trsList, "UIPanel");
	self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx");
	self._phalanx = Phalanx:New();
	self._phalanx:Init(self._phalanxInfo, WildBossHurtRankItem);
	
end

function WildBossHurtRankPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);

	--MessageManager.AddListener(WildBossNotes, WildBossNotes.EVENT_BOSSHURTRANK, WildBossHurtRankPanel.SetData, self);
end

function WildBossHurtRankPanel:SetData(data)
	self._data = data;
	if (data and self._txtMyRank) then
        if (data.my) then
		self._txtMyRank.text = data.my
        else
            self._txtMyRank.text = LanguageMgr.Get("WildBoss/hurtrank/noRank")
        end
        if (data.myh) then
		    self._txtMyHurt.text = data.myh
        else
            self._txtMyHurt.text = "0";
        end

		local ls = data.l;
        if (ls) then
		    local count = table.getn(ls);
		    self._phalanx:Build(count, 1, ls);
        end
	end
end

function WildBossHurtRankPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(WildBossNotes.CLOSE_WILDBOSSHURTRANKPANEL)
end

function WildBossHurtRankPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function WildBossHurtRankPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;

	--MessageManager.RemoveListener(WildBossNotes, WildBossNotes.EVENT_BOSSHURTRANK, WildBossHurtRankPanel._OnDataHandler, self);
end

function WildBossHurtRankPanel:_DisposeReference()
	self._btn_close = nil;
    self._txtMyRank = nil;
	self._txtMyHurt = nil;
	self._trsList = nil;
	self._scrollView = nil;
	self._scrollPanel = nil;
	self._phalanx:Dispose();
	self._phalanx = nil;
end