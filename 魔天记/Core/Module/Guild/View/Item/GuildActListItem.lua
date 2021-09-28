require "Core.Module.Common.UIItem"

GuildActListItem = UIItem:New();

function GuildActListItem:_Init()

    self._icoMain = UIUtil.GetChildByName(self.transform, "UISprite", "icoMain");
    -- self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._txtDesc = UIUtil.GetChildByName(self.transform, "UILabel", "txtDesc");

    self._icohasOver = UIUtil.GetChildByName(self.transform, "UISprite", "icohasOver");

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

    self._icohasOver.gameObject:SetActive(false);

    self:UpdateItem(self.data);
end

function GuildActListItem:_Dispose()
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;
end

function GuildActListItem:UpdateItem(data)
    self.data = data;

    if data then
        self._icoMain.spriteName = data.icon;
        -- self._txtName.text = data.name;
        local lv = GuildDataManager.data.level;
        if lv >= data.level then
            local rolelv = PlayerManager.GetPlayerLevel();

            if rolelv >= self.data.req_lev then
                ColorDataManager.UnSetGray(self._icoMain);

                if data.id == GuildDataManager.Open.BOSS then
                    self:GetBossStr();
                    self._txtDesc.text = self:GetOpenStr(data, GetOffsetTime());
                else
                    -- self._txtDesc.text = self:GetOpenStr(data, os.time({year=2016, month=12, day=9, hour=18, min=50, sec=10}));
                    self._txtDesc.text = self:GetOpenStr(data, GetOffsetTime());
                end

                self.lvEd = true;
            else
                ColorDataManager.SetGray(self._icoMain);

                self._txtDesc.text = LanguageMgr.Get("guild/act/openType/-2", { lv = self.data.req_lev });

                self.lvEd = false;
            end

        else
            ColorDataManager.SetGray(self._icoMain);

            self._txtDesc.text = LanguageMgr.Get("guild/act/openType/-1", { lv = data.level });

            self.lvEd = false;

        end

    else
        self._icoMain.spriteName = "";
        -- self._txtName.text = "";
        self._txtDesc.text = "";
    end
end

function GuildActListItem:_OnClickBtn()

    if self.data and self.lvEd then
        if self.data.id == GuildDataManager.Open.MINZU then
            if self.inOpenTime == false then
                return;
            end
        end
        MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_GUILD_ACT_SELECT, self.data);
    end

end

function GuildActListItem:GetOpenStr(cfg, time)
    if cfg.openType == 1 then
        self.inOpenTime = true;
        return cfg.openDesc;
    else
        self.inOpenTime = false;
        local d = os.date("*t", time);
        local inWday = true;
        if cfg.weeks and #cfg.weeks > 0 then
            inWday = GuildActListItem.InWday(d.wday, cfg.weeks);
        end

        -- 不在指定星期
        if inWday == false then
            return cfg.openDesc;
        end

        -- log(time);

        local cfgTimes = { };
        for i, v in ipairs(cfg.openParam) do
            cfgTimes[i] = GuildActListItem.GetTime(d, v);
            --[[
            if self.data.id == 4 then
                log("<" .. i .. "> " .. cfgTimes[i].startTime .. " - " .. cfgTimes[i].endTime);
            end
            ]]
        end

        -- 超过了结束时间
        local tmp = cfgTimes[#cfgTimes];
        if time > tmp.endTime then
            return cfg.openDesc;
        end

        if #cfgTimes > 1 then
            -- 在活动时间内
            for i, v in ipairs(cfgTimes) do
                if time >= v.startTime and time <= v.endTime then
                    --[[
                    if self.data.id == 4 then
                        log("在活动时间内" .. i);
                    end
                    ]]
                    self.inOpenTime = true;
                    return LanguageMgr.Get("guild/act/openType/0");
                end
            end
            -- 没到时间
            for i, v in ipairs(cfgTimes) do
                if time <= v.startTime then
                    --[[
                    if self.data.id == 4 then
                        log("没到时间" .. i .. "  - " .. (v.startTime - time));
                    end
                    ]]
                    return GuildActListItem.GetTimeStr(v.startTime - time);
                end
            end
            --[[
            if self.data.id == 4 then
                log("ddddddd");
            end
            ]]
        else
            if time < tmp.startTime then
                -- 显示距离开启的时间
                return GuildActListItem.GetTimeStr(tmp.startTime - time);
            else
                self.inOpenTime = true;
                -- 在活动时间内
                return LanguageMgr.Get("guild/act/openType/0");
            end
        end
    end
    return "";
end

function GuildActListItem.InWday(w, wdays)
    for i, v in ipairs(wdays) do
        if v == w then
            return true;
        end
    end
    return false;
end

function GuildActListItem.GetTime(date, cfgStr)
    local d = { };
    local cfg = string.split(cfgStr, "-");
    local vStart = string.split(cfg[1], ":");
    local startDate = clone(date);
    startDate.hour = vStart[1];
    startDate.min = vStart[2];
    startDate.sec = vStart[3];
    d.startTime = os.time(startDate);

    local vEnd = string.split(cfg[2], ":");
    local endDate = clone(date);
    endDate.hour = vEnd[1];
    endDate.min = vEnd[2];
    endDate.sec = vEnd[3];
    d.endTime = os.time(endDate);
    return d;
end

function GuildActListItem.GetTimeStr(time)
    local ts = TimeTranslate(time * 1000);
    return LanguageMgr.Get("guild/act/openType/1", { time = ts });
end


function GuildActListItem:GetBossStr()
    -- PrintTable(GuildDataManager.act);

    local tbs = GuildDataManager.act.tbs;

    -- tbs:帮会boss活动状态（1：没开启，2：进心中，3：已结束,4：胜利）
    if tbs == 1 then
        self._icohasOver.spriteName = "unOpen";
        self._icohasOver.gameObject:SetActive(true);
    elseif tbs == 2 then
        return LanguageMgr.Get("Guild/GuildActListItem/label2");
    elseif tbs == 3 then
        self._icohasOver.spriteName = "sign_yiwancheng";
        self._icohasOver.gameObject:SetActive(true);

    elseif tbs == 4 then
        self._icohasOver.spriteName = "winIcon";
        self._icohasOver.gameObject:SetActive(true);
    end


    return "";
end