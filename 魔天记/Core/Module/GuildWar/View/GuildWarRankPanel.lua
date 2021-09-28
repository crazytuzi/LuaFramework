require "Core.Module.Common.Panel";
require "Core.Module.Common.Phalanx";
require "Core.Module.GuildWar.View.Item.GuildWarRankItem";

GuildWarRankPanel = Panel:New();

function GuildWarRankPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function GuildWarRankPanel:_InitReference()

    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "ScrollView/phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, GuildWarRankItem);

    self._toggle = {};
    self._toggleSel = {};
    self._trsToggle = UIUtil.GetChildByName(self._trsContent, "Transform", "trsToggle");
    self._toggle[1] = UIUtil.GetChildByName(self._trsToggle, "UISprite", "btn1");
    self._toggleSel[1] = UIUtil.GetChildByName(self._trsToggle, "UISprite", "btn1/icoSelect");
    self._toggle[2] = UIUtil.GetChildByName(self._trsToggle, "UISprite", "btn2");
    self._toggleSel[2] = UIUtil.GetChildByName(self._trsToggle, "UISprite", "btn2/icoSelect");
    self._toggleSel[1].alpha = 0;
    self._toggleSel[2].alpha = 0;

    self._trsMyinfo = UIUtil.GetChildByName(self._trsContent, "Transform", "trsMyInfo");
    self._txtRank = UIUtil.GetChildByName(self._trsMyinfo, "UILabel", "txtRank");
    self._txtNum = UIUtil.GetChildByName(self._trsMyinfo, "UILabel", "txtNum");
	self._txtPoint = UIUtil.GetChildByName(self._trsMyinfo, "UILabel", "txtPoint");
	self._txtDesc = UIUtil.GetChildByName(self._trsMyinfo, "UILabel", "txtDesc");
	
end

function GuildWarRankPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

	self._onClickTog1 = function(go) self:_OnClickTog(1) end
	UIUtil.GetComponent(self._toggle[1], "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTog1);
	self._onClickTog2 = function(go) self:_OnClickTog(2) end
	UIUtil.GetComponent(self._toggle[2], "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTog2);
	
	MessageManager.AddListener(GuildWarNotes, GuildWarNotes.RSP_RANK_INFO, GuildWarRankPanel.UpdateDisplay, self);
end

function GuildWarRankPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function GuildWarRankPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;

	UIUtil.GetComponent(self._toggle[1], "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickTog1 = nil;
	UIUtil.GetComponent(self._toggle[2], "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickTog2 = nil;
	
	MessageManager.RemoveListener(GuildWarNotes, GuildWarNotes.RSP_RANK_INFO, GuildWarRankPanel.UpdateDisplay);
end

function GuildWarRankPanel:_DisposeReference()
    self._phalanx:Dispose();
end

function GuildWarRankPanel:_Opened()
   	--self:UpdateDisplay();
   	GuildWarProxy.ReqRankList();
end

local insert = table.insert;
function GuildWarRankPanel:UpdateDisplay(data)
	if data then
		local d = os.date("*t", GetTime());
		local cfg = GuildDataManager.GetWarConfig();
		local sd = GuildDataManager.SplitDateTime(cfg.sign_up_time[1]);
		local ed = GuildDataManager.SplitDateTime(cfg.week_time[#cfg.week_time].."_"..cfg.end_time);

		local notInTime = GuildDataManager.InTime(d, sd) and not GuildDataManager.InTime(d, ed);

		self.data = data;
		local myGuild = nil;
		local myId = GuildDataManager.gId;

		if data.l then
			for i, v in ipairs(data.l) do
				if v.tgi == myId then
					myGuild = v;
				end
			end
		end


		self:_OnClickTog(1);

		if myGuild then
			local rankIdx = myGuild.id <= 4 and 1 or 2;
			self._txtRank.text = LanguageMgr.Get("GuildWar/id/" .. rankIdx, myGuild);
			self._txtNum.gameObject:SetActive(true);
    		self._txtNum.text = myGuild.c;
    		self._txtPoint.gameObject:SetActive(true);
			self._txtPoint.text = myGuild.pt;

			local desc = "";
			if notInTime then
				desc = LanguageMgr.Get("GuildWar/Rank/Desc/-1");
			elseif myGuild.id < 3 then
				desc = LanguageMgr.Get("GuildWar/Rank/Desc/1");
			else
				desc = LanguageMgr.Get("GuildWar/Rank/Desc/0");
			end
			self._txtDesc.text = desc;
		else
			self._txtRank.text = LanguageMgr.Get("GuildWar/id/0");
    		self._txtNum.text = "";
    		self._txtNum.gameObject:SetActive(false);
			self._txtPoint.text = "";
			self._txtPoint.gameObject:SetActive(false);
			self._txtDesc.text = "";
		end
	end
end

function GuildWarRankPanel:_UpdateList()
	for i, v in ipairs(self._toggleSel) do
		v.alpha = self._index == i and 1 or 0;
	end
	
	local list = {};
	if self.data.l then 
		if self._index == 1 then
			for i = 1, 4 do
				if self.data.l[i] then
					table.insert(list, self.data.l[i]);
				end
			end
		else
			for i = 5, #self.data.l do
				if self.data.l[i] then
					table.insert(list, self.data.l[i]);
				end
			end
		end
	end
	self._phalanx:Build(#list, 1, list);
end

function GuildWarRankPanel:_OnClickTog(idx)
	if self.data then
		self._index = idx;
		self:_UpdateList();
	end
end

function GuildWarRankPanel:_OnClickBtnClose()
	ModuleManager.SendNotification(GuildWarNotes.CLOSE_RANK_PANEL);
end
