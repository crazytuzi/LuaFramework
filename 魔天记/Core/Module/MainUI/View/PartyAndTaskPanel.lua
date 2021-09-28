require "Core.Module.Friend.controlls.PartyFloatPanelControll"
require "Core.Module.Task.View.TaskFloatPanelControll";
require "Core.Module.XMBoss.controlls.XMBossFloatPanelControll";
require "Core.Module.MainUI.View.FbStarInfoForMainPanel"
local EndlessTryPanel = require "Core.Module.EndlessTry.View.EndlessTryPanel"
local TabooInfoPanel = require "Core.Module.Taboo.View.TabooInfoPanel"
local WildBossVipFloatPanel = require "Core.Module.WildBoss.View.WildBossVipFloatPanel"
local GuildWarFloatPanel = require "Core.Module.GuildWar.View.GuildWarFloatPanel"

PartyAndTaskPanel = class("PartyAndTaskPanel");


PartyAndTaskPanel.MESSAGE_PARTYANDTASKPANEL_ACT = "MESSAGE_PARTYANDTASKPANEL_ACT";

PartyAndTaskPanel.MESSAGE_SHOW_PARTYANDTASKPANEL = "MESSAGE_SHOW_PARTYANDTASKPANEL";
PartyAndTaskPanel.MESSAGE_CLOSE_PARTYANDTASKPANEL = "MESSAGE_CLOSE_PARTYANDTASKPANEL";

PartyAndTaskPanel.classify_btnParty = "btnParty";
PartyAndTaskPanel.classify_btnTask = "btnTask";

function PartyAndTaskPanel:New()
    self = { };
    setmetatable(self, { __index = PartyAndTaskPanel });
    return self
end

function PartyAndTaskPanel:SetActive(active)
    if (self.gameObject) then

        self.gameObject:SetActive(active);

    end
end

function PartyAndTaskPanel:Init(gameObject)
    self.gameObject = gameObject;
    self._trsContent = UIUtil.GetChildByName(self.gameObject, "Transform", "trsContent");

    self.classicToggle = UIUtil.GetChildByName(self._trsContent, "Transform", "classicToggle");

    self.treamPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "treamPanel");
    self.taskPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "taskPanel");
    self.xmBossPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "xmBossPanel");
    self.FbStarInfoForMain = UIUtil.GetChildByName(self._trsContent, "Transform", "FbStarInfoForMainPanel");

    self._partyFloatPanelControll = PartyFloatPanelControll:New();
    self._partyFloatPanelControll:Init(self.treamPanel);

    self._taskFloatPanelControll = TaskFloatPanelControll:New();
    self._taskFloatPanelControll:Init(self.taskPanel);

    self._XMBossFloatPanelControll = XMBossFloatPanelControll:New();
    self._XMBossFloatPanelControll:Init(self.xmBossPanel);

    self.FbStarInfoForMainPanelCtr = nil;
    self.FbStarInfoForMainPanelCtr = FbStarInfoForMainPanel:New();
    self.FbStarInfoForMainPanelCtr:Init(self.FbStarInfoForMain);

    -- self:SetTagleHandler(PartyAndTaskPanel.classify_btnParty);
    -- self:SetTagleHandler(PartyAndTaskPanel.classify_btnTask);

    self._toggleBtn1 = UIUtil.GetChildByName(self.classicToggle, "Transform", "btnTask");
    self._toggleIcon1 = UIUtil.GetChildByName(self._toggleBtn1, "UISprite", "icon");
    self._toggleTxt1 = UIUtil.GetChildByName(self._toggleBtn1, "UILabel", "title");

    self._toggleBtn2 = UIUtil.GetChildByName(self.classicToggle, "Transform", "btnParty");
    self._toggleIcon2 = UIUtil.GetChildByName(self._toggleBtn2, "UISprite", "icon");
    self._toggleTxt2 = UIUtil.GetChildByName(self._toggleBtn2, "UILabel", "title");

    self.btnParty_hasApplyListTip = UIUtil.GetChildByName(self._toggleBtn2, "Transform", "hasApplyListTip");

    self._classify_OnClick = function(go) self:Classify_OnClick(go.name) end;
    UIUtil.GetComponent(self._toggleBtn1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._classify_OnClick);
    UIUtil.GetComponent(self._toggleBtn2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._classify_OnClick);

    -- self:SetTagleSelect(PartyAndTaskPanel.classify_btnTask);
    self:Classify_OnClick(PartyAndTaskPanel.classify_btnTask);

    self._btnHide = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnHide");
    self._btnShow = UIUtil.GetChildByName(self.gameObject, "UIButton", "btnShow");

    self._onHide = function(go) self:UpdateMode(MainUIPanel.Mode.HIDE) end
    self._onShow = function(go) self:UpdateMode(MainUIPanel.Mode.SHOW) end
    UIUtil.GetComponent(self._btnHide, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onHide);
    UIUtil.GetComponent(self._btnShow, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onShow);

    self:UpdateMode(MainUIPanel.Mode.SHOW);

    MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_ENTER, self._SceneStartHandler, self);
    MessageManager.AddListener(PartyAndTaskPanel, PartyAndTaskPanel.MESSAGE_PARTYANDTASKPANEL_ACT, self._TbActHandler, self);

    MessageManager.AddListener(PartyAndTaskPanel, PartyAndTaskPanel.MESSAGE_SHOW_PARTYANDTASKPANEL, self._showPanel, self);
    MessageManager.AddListener(PartyAndTaskPanel, PartyAndTaskPanel.MESSAGE_CLOSE_PARTYANDTASKPANEL, self._hidePanel, self);

    MessageManager.AddListener(FriendProxy, FriendProxy.MESSAGE_NEED_SHOW_APPLYTEARMLIST_TIP, PartyAndTaskPanel.CheckAndShowAplTip, self);

    MessageManager.AddListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, PartyAndTaskPanel.CheckTeamNum, self);

    self.btnParty_hasApplyListTip.gameObject:SetActive(false);

    self:CheckAndShowAplTip();

    self:CheckTeamNum()

end


function PartyAndTaskPanel:CheckTeamNum()

    local num = PartData.GetMyTeamNunberNum();
    if num > 0 then
        self._toggleTxt2.text = LanguageMgr.Get("PartyAndTaskPanel/label4", { n = num });
    else
        self._toggleTxt2.text = LanguageMgr.Get("PartyAndTaskPanel/label3");
    end



end





function PartyAndTaskPanel:FBElseTimeChange(finishTimeStamp)
    self._XMBossFloatPanelControll:FBElseTimeChange(finishTimeStamp);

end

function PartyAndTaskPanel:OnUpElseTime(fb_else_totalTime,isUpServer)
    self.FbStarInfoForMainPanelCtr:OnUpElseTime(fb_else_totalTime,isUpServer);
end

function PartyAndTaskPanel:CheckAndShowAplTip()

    local t_num = table.getn(PartData.applyTearmList);
    if t_num > 0 then
        -- 需要显示提示
        self.btnParty_hasApplyListTip.gameObject:SetActive(true);

    else
        self.btnParty_hasApplyListTip.gameObject:SetActive(false);
    end

end

function PartyAndTaskPanel:GensuiMenberChange(list)
    self._partyFloatPanelControll:GensuiMenberChange(list)
end

-- _TbActHandler

function PartyAndTaskPanel:_TbActHandler(p)
    self:UpdateMode(p);
end

function PartyAndTaskPanel:_SceneStartHandler()
    --[[
    self.btnTaskLabel = UIUtil.GetChildByName(self.classicToggle, "UILabel", "btnTask/title");
    
    local xmbx_map_id = nil;
    if XMBossPanel.Fb_id ~= nil then
        local obj = InstanceDataManager.GetMapCfById(XMBossPanel.Fb_id);
        xmbx_map_id = obj.map_id;
    end

    if tonumber(GameSceneManager.id) == tonumber(xmbx_map_id) then

        self.btnTaskLabel.text = LanguageMgr.Get("PartyAndTaskPanel/label1");

        if self._taskFloatPanelControll.showing then
            self._taskFloatPanelControll:Close();
            self._XMBossFloatPanelControll:Show();
        end
    else
        self.btnTaskLabel.text = LanguageMgr.Get("PartyAndTaskPanel/label2");

        if self._XMBossFloatPanelControll.showing then
            self._taskFloatPanelControll:Show();
            self._XMBossFloatPanelControll:Close();
        end
    end
    ]]

    local fb_data = ConfigManager.GetMapById(GameSceneManager.id);
    
    if fb_data.id == ArathiProxy.readyMapId then
        ArathiProxy.ReqReadyInfo();
    end

    -- log("----------------------------------------- fb_data " .. fb_data.show_fbInfoPanel);
    --PrintTable(fb_data, "", Warning)
    self.showFBInfo = fb_data.show_fbInfoPanel;
    
	if self._EndlessTryPanel then self._EndlessTryPanel:Dispose() self._EndlessTryPanel = nil end
	if self._TabooInfoPanel then self._TabooInfoPanel:Dispose() self._TabooInfoPanel = nil end
    if self.showFBInfo == 0 then
        self._toggleTxt1.text = LanguageMgr.Get("PartyAndTaskPanel/label2");
        if self._wildBossVipFloatPanel then self._wildBossVipFloatPanel:Exit() end
        if self._guildWarFloatPanel then self._guildWarFloatPanel:Exit() end

        self.FbStarInfoForMainPanelCtr:Close();
        self._XMBossFloatPanelControll:Close();

        local tem = self._curr_classify;
        self._curr_classify = "";
        self:Classify_OnClick(tem);
    else
        -- 显示 地图名
        self._toggleTxt1.text = LanguageMgr.Get("PartyAndTaskPanel/label5");
        if self._taskFloatPanelControll.showing then
            self._taskFloatPanelControll:Close();
        end

        if self.showFBInfo == 1 then
            if not self.FbStarInfoForMainPanelCtr.enble then self.FbStarInfoForMainPanelCtr:Show(); end
            self.FbStarInfoForMainPanelCtr:SetData();
        elseif self.showFBInfo == 2 then
            if not self._EndlessTryPanel then
                self.endlessTryPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "EndlessTryPanel");
                self._EndlessTryPanel = EndlessTryPanel:New();
                self._EndlessTryPanel:Init(self.endlessTryPanel);
            end
            self._EndlessTryPanel:Enter()
        elseif self.showFBInfo == 3 then
            if not self._TabooInfoPanel then
                self.tabooInfoPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "TabooInfoPanel");
                self._TabooInfoPanel = TabooInfoPanel:New();
                self._TabooInfoPanel:Init(self.tabooInfoPanel);
            end
            self._TabooInfoPanel:Enter()
        elseif self.showFBInfo == 4 then
            if not self._wildBossVipFloatPanel then
                local trsVipFieldBossPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "VipFieldBossPanel");
                self._wildBossVipFloatPanel = WildBossVipFloatPanel.New();
                self._wildBossVipFloatPanel:Init(trsVipFieldBossPanel);
            end
            self._wildBossVipFloatPanel:Enter()
        elseif self.showFBInfo == 5 then
            self._XMBossFloatPanelControll:Show();
        elseif self.showFBInfo == 6 then
            if not self._guildWarFloatPanel then
                local trsGuildWarPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "GuildWarFloatPanel");
                self._guildWarFloatPanel = GuildWarFloatPanel.New();
                self._guildWarFloatPanel:Init(trsGuildWarPanel);
            end
            self._guildWarFloatPanel:Enter()
        end
       
        self:Classify_OnClick(PartyAndTaskPanel.classify_btnTask);
    end

end

function PartyAndTaskPanel:SetTagleSelect(idx)
    local c = nil;
    if idx == 2 then
        c = self._toggleIcon1.color;
        c.a = 0.4;
        self._toggleIcon1.color = c;

        c = self._toggleIcon1.color;
        c.a = 0.6;
        self._toggleTxt1.color = c;

        c = self._toggleIcon2.color;
        c.a = 1;
        self._toggleIcon2.color = c;
        self._toggleTxt2.color = c;
    else

        c = self._toggleIcon1.color;
        c.a = 1;
        self._toggleIcon1.color = c;
        self._toggleTxt1.color = c;

        c = self._toggleIcon2.color;
        c.a = 0.4;
        self._toggleIcon2.color = c;
        c = self._toggleTxt2.color;
        c.a = 0.6;
        self._toggleTxt2.color = c;
    end

end

function PartyAndTaskPanel:Classify_OnClick(name)

    if self._curr_classify ~= name then
        self._curr_classify = name;

        self._taskFloatPanelControll:Close();
        self._XMBossFloatPanelControll:Close();
        self.FbStarInfoForMainPanelCtr:Close();
        if self._EndlessTryPanel then self._EndlessTryPanel:Close() end
        if self._TabooInfoPanel then self._TabooInfoPanel:Close() end
        if self._wildBossVipFloatPanel then self._wildBossVipFloatPanel:Close() end
        if self._guildWarFloatPanel then self._guildWarFloatPanel:Close() end

        if name == PartyAndTaskPanel.classify_btnParty then
            self._partyFloatPanelControll:Show();
            self:SetTagleSelect(2);

        elseif name == PartyAndTaskPanel.classify_btnTask then
            self._partyFloatPanelControll:Close();

            --[[
            local xmbx_map_id = nil;
            if XMBossPanel.Fb_id ~= nil then
                local obj = InstanceDataManager.GetMapCfById(XMBossPanel.Fb_id);
                xmbx_map_id = obj.map_id;
            end

            if tonumber(GameSceneManager.id) == tonumber(xmbx_map_id) then
                self.FbStarInfoForMainPanelCtr:Close();
                self._partyFloatPanelControll:Close();
                self._XMBossFloatPanelControll:Show();
                self._taskFloatPanelControll:Close();
            else
                self._partyFloatPanelControll:Close();
                self._XMBossFloatPanelControll:Close();
                self.FbStarInfoForMainPanelCtr:Close();
                self._taskFloatPanelControll:Show();
            end
            ]]

            if self.showFBInfo == 0 then
                self._taskFloatPanelControll:Show();
            elseif self.showFBInfo == 1 then
                self.FbStarInfoForMainPanelCtr:Show();
            elseif self.showFBInfo == 2 then
                self._EndlessTryPanel:Show()
            elseif self.showFBInfo == 3 then
                self._TabooInfoPanel:Show()
            elseif self.showFBInfo == 4 then
                self._wildBossVipFloatPanel:Show()
            elseif self.showFBInfo == 5 then
                self._XMBossFloatPanelControll:Show()
            elseif self.showFBInfo == 6 then
                self._guildWarFloatPanel:Show()
            end

            self:SetTagleSelect(1);
        end

    else
        if name == PartyAndTaskPanel.classify_btnTask then
            if self.showFBInfo == 0 then
                ModuleManager.SendNotification(TaskNotes.OPEN_TASKPANEL);
            end
        elseif name == PartyAndTaskPanel.classify_btnParty then
            ModuleManager.SendNotification(FriendNotes.OPEN_FRIENDPANEL, FriendNotes.PANEL_PARTY);
        end
    end

end

function PartyAndTaskPanel:UpdateMode(mode)
    self.mode = mode;
    self._trsContent.gameObject:SetActive(mode == MainUIPanel.Mode.SHOW);
    self._btnShow.gameObject:SetActive(mode == MainUIPanel.Mode.HIDE);
end

function PartyAndTaskPanel:Close()

    self:SetActive(false);
end

function PartyAndTaskPanel:_showPanel()

    self:SetActive(true);

end

function PartyAndTaskPanel:_hidePanel()

    self:SetActive(false);
end

function PartyAndTaskPanel:Dispose()
    self._partyFloatPanelControll:Dispose();
    self._taskFloatPanelControll:Dispose();
    self._XMBossFloatPanelControll:Dispose();
	if self._EndlessTryPanel then self._EndlessTryPanel:Dispose() self._EndlessTryPanel = nil end
	if self._TabooInfoPanel then self._TabooInfoPanel:Dispose() self._TabooInfoPanel = nil end
    if self._wildBossVipFloatPanel then self._wildBossVipFloatPanel:Dispose() self._wildBossVipFloatPanel = nil end
    if self._guildWarFloatPanel then self._guildWarFloatPanel:Dispose() self._guildWarFloatPanel = nil end
    
    if self.FbStarInfoForMainPanelCtr ~= nil then
        self.FbStarInfoForMainPanelCtr:Dispose();
        self.FbStarInfoForMainPanelCtr = nil;
    end

    MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_ENTER, self._SceneStartHandler, self);
    MessageManager.RemoveListener(PartyAndTaskPanel, PartyAndTaskPanel.MESSAGE_PARTYANDTASKPANEL_ACT, self._TbActHandler, self);
    MessageManager.RemoveListener(FriendProxy, FriendProxy.MESSAGE_NEED_SHOW_APPLYTEARMLIST_TIP, PartyAndTaskPanel.CheckAndShowAplTip);

    MessageManager.RemoveListener(PartyAndTaskPanel, PartyAndTaskPanel.MESSAGE_SHOW_PARTYANDTASKPANEL, self._showPanel, self);
    MessageManager.RemoveListener(PartyAndTaskPanel, PartyAndTaskPanel.MESSAGE_CLOSE_PARTYANDTASKPANEL, self._hidePanel, self);

    MessageManager.RemoveListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, PartyAndTaskPanel.CheckTeamNum);


    UIUtil.GetComponent(self._toggleBtn1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._toggleBtn2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._classify_OnClick = nil;

    UIUtil.GetComponent(self._btnHide, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnShow, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onHide = nil;
    self._onShow = nil;
end
