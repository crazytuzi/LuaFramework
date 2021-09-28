require "Core.Module.Common.Panel";
require "Core.Module.Guild.View.Item.GuildSkillItem";

GuildSkillPanel = Panel:New();

function GuildSkillPanel:_Init()
	self:_InitReference();
	self:_InitListener();
    
end

function GuildSkillPanel:_InitReference()
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self._btnResearch = UIUtil.GetChildByName(self._trsContent, "Transform", "trsToggle/btnResearch");
    self._btnLearn = UIUtil.GetChildByName(self._trsContent, "Transform", "trsToggle/btnLearn");
    self._icoTogBg1 = UIUtil.GetChildByName(self._btnLearn, "UISprite", "bg");
    self._icoTogBg2 = UIUtil.GetChildByName(self._btnResearch, "UISprite", "bg");
    self._icoTogActBg1 = UIUtil.GetChildByName(self._btnLearn, "UISprite", "highLight");
    self._icoTogActBg2 = UIUtil.GetChildByName(self._btnResearch, "UISprite", "highLight");

    self._icoLearnRed = UIUtil.GetChildByName(self._btnLearn, "UISprite", "icoRedPoint");
    self._icoResearchRed = UIUtil.GetChildByName(self._btnResearch, "UISprite", "icoRedPoint");
    self._icoLearnRed.alpha = 0;
    self._icoResearchRed.alpha = 0;

    self._btnOpt = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnOpt");

    self._txtTypeTitle = UIUtil.GetChildByName(self._trsContent, "UILabel", "trsTitle/txtTitle3");
    self._txtBtnTitle = UIUtil.GetChildByName(self._btnOpt, "UILabel", "Label");
    self._txtMyVal = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtMyVal");
    self._icoMyVal = UIUtil.GetChildByName(self._txtMyVal, "UISprite", "ico");

    self._txtMax = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtMax");
    self._txtMax.gameObject:SetActive(false);

   	self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "trsList/phalanx");
	self._phalanx = Phalanx:New();
	self._phalanx:Init(self._phalanxInfo, GuildSkillItem);

end

function GuildSkillPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

	self._onClickBtnR = function(go) self:UpdateDisplay(2) end
	UIUtil.GetComponent(self._btnResearch, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnR);

	self._onClickBtnL = function(go) self:UpdateDisplay(1) end
	UIUtil.GetComponent(self._btnLearn, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnL);
   	
    self._onClickBtnOpt = function(go) self:_OnClickBtnOpt() end
    UIUtil.GetComponent(self._btnOpt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnOpt);

    MessageManager.AddListener(GuildNotes, GuildNotes.ENV_GUILD_SKILL_ITEM_SELECTED, GuildSkillPanel.OnItemSelect, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_GUILD_SKILL_CHG, GuildSkillPanel.Refresh, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_NTF_LEVELUP, GuildSkillPanel.UpdateRedPoint, self);
    MessageManager.AddListener(GuildDataManager, GuildDataManager.MESSAGE_MONEYCHANGE, GuildSkillPanel.UpdateMoney, self);
	--MessageManager.AddListener(GuildDataManager, GuildDataManager.MESSAGE_DKPCHANGE, GuildSkillPanel.UpdateDkp, self);
    MessageManager.AddListener(MoneyDataManager, MoneyDataManager.EVENT_GUILD_SKILLPOINT_CHANGE, GuildSkillPanel.UpdateDkp, self);
end

function GuildSkillPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();

end

function GuildSkillPanel:_DisposeReference()

end

function GuildSkillPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;

    UIUtil.GetComponent(self._btnResearch, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnR = nil;
    UIUtil.GetComponent(self._btnLearn, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnL = nil;

    MessageManager.RemoveListener(GuildNotes, GuildNotes.ENV_GUILD_SKILL_ITEM_SELECTED, GuildSkillPanel.OnItemSelect);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_GUILD_SKILL_CHG, GuildSkillPanel.Refresh);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_NTF_LEVELUP, GuildSkillPanel.UpdateRedPoint);
    MessageManager.RemoveListener(GuildDataManager, GuildDataManager.MESSAGE_MONEYCHANGE, GuildSkillPanel.UpdateMoney);
	--MessageManager.RemoveListener(GuildDataManager, GuildDataManager.MESSAGE_DKPCHANGE, GuildSkillPanel.UpdateDkp);
    MessageManager.RemoveListener(MoneyDataManager, MoneyDataManager.EVENT_GUILD_SKILLPOINT_CHANGE, GuildSkillPanel.UpdateDkp);
end

function GuildSkillPanel:_Opened()
    self:UpdateDisplay(1);
end

function GuildSkillPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILD_OTHER_PANEL, GuildNotes.OTHER.SKILL);
end

function GuildSkillPanel:UpdateDisplay(idx)
    if self.tabIdx ~= idx then
    	self.tabIdx = idx;
    	self:UpdateTab();

        self:UpdateList();

        if self.tabIdx == 1 then
            self._txtMyVal.text = GuildDataManager.GetSkillPoint();
        else
            self._txtMyVal.text = GuildDataManager.GetMoney();
        end

        self:UpdateRedPoint();
    end
end

function GuildSkillPanel:Refresh()
    self:UpdateList();
    self:UpdateRedPoint();
end

function GuildSkillPanel:UpdateTab()
	for i = 1, 2 do
		self["_icoTogBg" .. i].alpha = i == self.tabIdx and 0 or 1;
		self["_icoTogActBg" .. i].alpha = i == self.tabIdx and 1 or 0;
	end

    self._txtTypeTitle.text = LanguageMgr.Get("guild/skill/type/title/" .. self.tabIdx);
    self._txtBtnTitle.text = LanguageMgr.Get("guild/skill/type/btn/" .. self.tabIdx);

    self._icoMyVal.spriteName = self.tabIdx == 1 and "pvpPoint" or "xianmengzijin";
end

function GuildSkillPanel:UpdateList()
    local dict = GuildDataManager.GetSkillList(self.tabIdx);
    
    local list = {};
    for k, v in pairs(dict) do
        v._tabIdx = self.tabIdx;
        table.insert(list, v);
    end

    self._phalanx:Build(#list, 1 , list);

    if self.selType == nil then
        self:OnItemSelect(list[1]);
    else
        local tmpItem = list[1];
        for i,v in ipairs(list) do 
            if v.type == self.selType then
                tmpItem = v;
                break;
            end
        end
        self:OnItemSelect(tmpItem);
    end
    
end

function GuildSkillPanel:UpdateDkp()
    if self.tabIdx == 1 then
        self._txtMyVal.text = GuildDataManager.GetSkillPoint();
        self:UpdateList();
        self:UpdateRedPoint();
    end
end

function GuildSkillPanel:UpdateMoney()
    if self.tabIdx == 2 then
        self._txtMyVal.text = GuildDataManager.GetMoney();
        self:UpdateList();
        self:UpdateRedPoint();
    end
end

function GuildSkillPanel:UpdateRedPoint()
    self._icoLearnRed.alpha = GuildDataManager.GetSkillLearnRedPoint() and 1 or 0;
    self._icoResearchRed.alpha = GuildDataManager.GetSkillResRedPoint() and 1 or 0;
end

function GuildSkillPanel:OnItemSelect(data)
    self.curSkill = data;
    self.selType = data.type;
    self:UpdateSelect(data);
end

function GuildSkillPanel:UpdateSelect(data)
    local items = self._phalanx:GetItems();
    for i,v in ipairs(items) do
        local item = v.itemLogic;
        item:UpdateSelected(data);
    end
    local isMax = data.level >= data.levelMax;
    self._txtMax.gameObject:SetActive(isMax);
    self._btnOpt.gameObject:SetActive(not isMax);
end

function GuildSkillPanel:_OnClickBtnOpt()
    if self.curSkill then
        local myVal = 0;
        local cost = 0;
        if self.tabIdx == 1 then
            myVal = GuildDataManager.GetSkillPoint();
            cost = tonumber(string.split(self.curSkill.study_need_item, "_")[2]);

            if myVal < cost then
                ProductGetProxy.TryShowGetUI(14, GuildNotes.CLOSE_GUILD_OTHER_PANEL);
                MsgUtils.ShowTips("guild/skill/learn/no");
                return;
            end

            GuildProxy.ReqLearnSkill(self.curSkill.type);
        else
            if GuildDataManager.GetGrant(GuildDataManager.opt.research) then

                myVal = GuildDataManager.GetMoney();
                cost = tonumber(string.split(self.curSkill.research_need_item, "_")[2]);

                if myVal < cost then
                    MsgUtils.ShowTips("guild/skill/research/no");
                    return;
                end

                GuildProxy.ReqResearchSkill(self.curSkill.type);
            else
                MsgUtils.ShowTips("guild/skill/noGrant");
            end
        end
    end
end