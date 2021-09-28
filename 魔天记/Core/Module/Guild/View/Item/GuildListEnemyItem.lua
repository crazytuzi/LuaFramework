require "Core.Module.Common.UIItem"

GuildListEnemyItem = UIItem:New();

function GuildListEnemyItem:_Init()
    
    self._txtRank = UIUtil.GetChildByName(self.transform, "UILabel", "txtRank");
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._txtLv = UIUtil.GetChildByName(self.transform, "UILabel", "txtLv");
    self._txtLeader = UIUtil.GetChildByName(self.transform, "UILabel", "txtLeader");
    self._icoLeader = UIUtil.GetChildByName(self.transform, "UISprite", "icoLeader");
    self._txtNum = UIUtil.GetChildByName(self.transform, "UILabel", "txtNum");
    self._txtJoin = UIUtil.GetChildByName(self.transform, "UILabel", "txtJoin");
    self._fight = UIUtil.GetChildByName(self.transform, "UILabel", "txtFight");

    self._btnOpt = UIUtil.GetChildByName(self.transform, "UIButton", "btnOpt");
    self._txtOpt = UIUtil.GetChildByName(self._btnOpt, "UILabel", "txtOpt");
    self._txtStatus = UIUtil.GetChildByName(self.transform, "UILabel", "txtStatus");

    self._icoVip = UIUtil.GetChildByName(self.gameObject, "UISprite", "icoVip");

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

    self._onClickOptBtn = function(go) self:_OnClickOptBtn(self) end
    UIUtil.GetComponent(self._btnOpt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickOptBtn);

    self._btnOpt.gameObject:SetActive(false);
    self._txtStatus.gameObject:SetActive(false);

    self:UpdateItem(self.data);
end

function GuildListEnemyItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;

    UIUtil.GetComponent(self._btnOpt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickOptBtn = nil;
end

function GuildListEnemyItem:UpdateItem(data)
    self.data = data;
    
    if data then
        self._txtRank.text = data.rank;
        self._txtName.text = data.name;
        self._txtLv.text = data.level;
        self._txtLeader.text = data.leader;
        self._icoLeader.spriteName = "c" .. data.leaderKind;
        
        local cfg = ConfigManager.GetGuildLevelConfig(data.level);
        local max = cfg.number;
        self._txtNum.text = LanguageMgr.Get("common/numMax", {num = data.num, max = max});
        self._fight.text = data.fight;

        self._icoVip.spriteName = VIPManager.GetVipIconByVip(data.leaderVip);

        self:UpdateStatusInfo();
    else
        self._txtRank.text = "";
        self._txtName.text = "";
        self._txtLv.text = "";
        self._txtLeader.text = "";
        self._icoLeader.spriteName = "";
        self._txtNum.text = "";
        self._fight.text = "";
        self._txtStatus.gameObject:SetActive(false);
        self._btnOpt.gameObject:SetActive(false);

        self._icoVip.spriteName = "";
    end
end

function GuildListEnemyItem:SetStatus(id, st)
    if self.data and self.data.id == id then
        self.data.isEnemy = st >= 0;
        self.data.enemyTime = st;
        self:UpdateStatusInfo();
    end
end

function GuildListEnemyItem:UpdateStatusInfo()
    self._needUpdate = false;
    if self.data.isEnemy then
        local now = GetTime();
        if now - self.data.enemyTime >= 0 then 
            self._txtOpt.text = LanguageMgr.Get("guild/enemy/cancel");
            self._btnOpt.gameObject:SetActive(true);
            self._txtStatus.gameObject:SetActive(false);
        else
            self._needUpdate = true;
            self._updateTime = self.data.enemyTime - now;
            self._btnOpt.gameObject:SetActive(false);
            self._txtStatus.gameObject:SetActive(true);
            self:UpdateTimeStr();
        end
    else
        self._txtOpt.text = LanguageMgr.Get("guild/enemy/set");
        self._btnOpt.gameObject:SetActive(true);
        self._txtStatus.gameObject:SetActive(false);
    end
end

function GuildListEnemyItem:UpdateStatus()
    if self._needUpdate then
        self._updateTime = self._updateTime - Timer.deltaTime;
        if self._updateTime > 0 then 
            self:UpdateTimeStr();
        else
            self:UpdateStatusInfo();
        end
    end
end

function GuildListEnemyItem:UpdateTimeStr()
    local timeStr = TimeUtil.SecondToHourMinSecString(self._updateTime);
    self._txtStatus.text = LanguageMgr.Get("value", {value = timeStr});
end

function GuildListEnemyItem:_OnClickBtn()
    ModuleManager.SendNotification(GuildNotes.OPEN_GUILD_DETAIL_PANEL, self.data);
end

function GuildListEnemyItem:_OnClickOptBtn()
    if self.data then
        local id = self.data.id;
        if self.data.isEnemy then
            GuildProxy.ReqCancelEnemy(id);
        else
            GuildProxy.ReqSetEnemy(id);
        end
    end
    
end