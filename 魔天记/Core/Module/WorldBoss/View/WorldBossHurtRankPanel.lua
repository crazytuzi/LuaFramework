require "Core.Module.Common.Panel"
require "Core.Module.WorldBoss.View.Item.WorldBossHurtRankItem"

WorldBossHurtRankPanel = class("WorldBossHurtRankPanel", Panel);
function WorldBossHurtRankPanel:New()
	self = {};
	setmetatable(self, {__index = WorldBossHurtRankPanel});
	return self
end

function WorldBossHurtRankPanel:_Init()
	self._datas = {}
	self:_InitReference();
	self:_InitListener();
	self:_OnClickBtnTog1();
end

function WorldBossHurtRankPanel:_InitReference()
	local txtTitle = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTitle");
	txtTitle.text = LanguageMgr.Get("WorldBoss/hurtrank/title")
	
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
	
	self._btnTog1 = UIUtil.GetChildByName(self._trsContent, "UIButton", "trsToggle/btnTog1");
	self._btnTog2 = UIUtil.GetChildByName(self._trsContent, "UIButton", "trsToggle/btnTog2");
	self._btnTog3 = UIUtil.GetChildByName(self._trsContent, "UIButton", "trsToggle/btnTog3");
	self._btnTog4 = UIUtil.GetChildByName(self._trsContent, "UIButton", "trsToggle/btnTog4");
	
	self._trsMy = UIUtil.GetChildByName(self._trsContent, "Transform", "trsMy");
	
	self._txtMyRank = UIUtil.GetChildByName(self._trsMy, "UILabel", "txtMyRank");
	self._txtMyHurt = UIUtil.GetChildByName(self._trsMy, "UILabel", "txtMyHurt");
	self._imgMyRank = UIUtil.GetChildByName(self._trsMy, "UISprite", "imgMyRank");
	
	self._txtPlayers = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtPlayers");
	
	self._trsList = UIUtil.GetChildByName(self._trsContent, "Transform", "trsList");
	self._scrollView = UIUtil.GetComponent(self._trsList, "UIScrollView");
	self._scrollPanel = UIUtil.GetComponent(self._trsList, "UIPanel");
	self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx");
	
	self._phalanx = Phalanx:New();
	self._phalanx:Init(self._phalanxInfo, WorldBossHurtRankItem);
end

function WorldBossHurtRankPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
	
	self._onClickBtnTog1 = function(go) self:_OnClickBtnTog1(self) end
	UIUtil.GetComponent(self._btnTog1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog1);
	
	self._onClickBtnTog2 = function(go) self:_OnClickBtnTog2(self) end
	UIUtil.GetComponent(self._btnTog2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog2);
	
	self._onClickBtnTog3 = function(go) self:_OnClickBtnTog3(self) end
	UIUtil.GetComponent(self._btnTog3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog3);
	
	self._onClickBtnTog4 = function(go) self:_OnClickBtnTog4(self) end
	UIUtil.GetComponent(self._btnTog4, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog4);
	
	MessageManager.AddListener(WorldBossNotes, WorldBossNotes.EVENT_BOSSHURTRANK, WorldBossHurtRankPanel._OnDataHandler, self);
end

function WorldBossHurtRankPanel:_OnDataHandler(data)
	self._datas[data.kind] = data
    self:_Update(data)
	-- self._data = data;
	-- if(data and self._txtMyRank) then
	-- 	if(data.my) then
	-- 		if(data.my > 3) then
	-- 			self._txtMyRank.text = data.my;
	-- 			self._imgMyRank.gameObject:SetActive(false);
	-- 		else
	-- 			self._imgMyRank.spriteName = "no" .. data.my;
	-- 			self._imgMyRank.gameObject:SetActive(true);
	-- 			self._txtMyRank.gameObject:SetActive(false);
	-- 		end
	-- 		self._txtMyHurt.text = data.mh;
	-- 		-- self._trsMy.gameObject:SetActive(true);
	-- 	else
	-- 		self._txtMyRank.text = LanguageMgr.Get("WorldBoss/hurtrank/null")
	-- 		self._txtMyHurt.text = "0";
	-- 		self._imgMyRank.gameObject:SetActive(false);
	-- 		-- self._trsMy.gameObject:SetActive(false);
	-- 	end
	-- 	self._txtPlayers.text = data.c;
	-- 	local ls = data.l;
	-- 	local count = table.getn(ls);
	-- 	self._phalanx:Build(count, 1, ls);
	-- end
end

function WorldBossHurtRankPanel:_Update(data)
	if(data and self._txtMyRank) then
		if(data.my) then
			if(data.my > 3) then
				self._txtMyRank.text = data.my;
				self._imgMyRank.gameObject:SetActive(false);
			else
				self._imgMyRank.spriteName = "no" .. data.my;
				self._imgMyRank.gameObject:SetActive(true);
				self._txtMyRank.gameObject:SetActive(false);
			end
			self._txtMyHurt.text = data.mh;
			-- self._trsMy.gameObject:SetActive(true);
		else
			self._txtMyRank.text = LanguageMgr.Get("WorldBoss/hurtrank/null")
			self._txtMyHurt.text = "0";
			self._imgMyRank.gameObject:SetActive(false);
			-- self._trsMy.gameObject:SetActive(false);
		end
		self._txtPlayers.text = data.c;
		local ls = data.l;
		local count = table.getn(ls);
		self._phalanx:Build(count, 1, ls);
	end
end

function WorldBossHurtRankPanel:_OnClickBtnTog1()
	if(self._datas[101000]) then
		self:_Update(self._datas[101000])
	else		
		WorldBossProxy.RefreshBossHurtRank(101000)
	end
end

function WorldBossHurtRankPanel:_OnClickBtnTog2()
	if(self._datas[102000]) then
		self:_Update(self._datas[102000])		
	else		
		WorldBossProxy.RefreshBossHurtRank(102000)
	end
	-- WorldBossProxy.RefreshBossHurtRank(102000)
end

function WorldBossHurtRankPanel:_OnClickBtnTog3()
	if(self._datas[103000]) then
		self:_Update(self._datas[103000])
		
	else		
		WorldBossProxy.RefreshBossHurtRank(103000)
	end
	-- WorldBossProxy.RefreshBossHurtRank(103000)
end

function WorldBossHurtRankPanel:_OnClickBtnTog4()
	if(self._datas[104000]) then
		self:_Update(self._datas[104000])		
	else		
		WorldBossProxy.RefreshBossHurtRank(104000)
	end
	-- WorldBossProxy.RefreshBossHurtRank(104000)
end

function WorldBossHurtRankPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(WorldBossNotes.CLOSE_WORLDBOSSHURTRANKPANEL)
end

function WorldBossHurtRankPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function WorldBossHurtRankPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
	
	UIUtil.GetComponent(self._btnTog1, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnTog1 = nil;
	
	UIUtil.GetComponent(self._btnTog2, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnTog2 = nil;
	
	UIUtil.GetComponent(self._btnTog3, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnTog3 = nil;
	
	UIUtil.GetComponent(self._btnTog4, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnTog4 = nil;
	
	MessageManager.RemoveListener(WorldBossNotes, WorldBossNotes.EVENT_BOSSHURTRANK, WorldBossHurtRankPanel._OnDataHandler, self);
end

function WorldBossHurtRankPanel:_DisposeReference()
	self._datas = nil;
	self._btn_close = nil;
	self._btnTog1 = nil;
	self._btnTog2 = nil;
	self._btnTog3 = nil;
	self._btnTog4 = nil;
	self._trsMy = nil;
	self._txtMyRank = nil;
	self._txtMyHurt = nil;
	self._imgMyRank = nil;
	self._txtPlayers = nil;
	self._trsList = nil;
	self._scrollView = nil;
	self._scrollPanel = nil;
	self._phalanxInfo = nil;
	self._phalanx:Dispose();
	self._phalanx = nil;
end 