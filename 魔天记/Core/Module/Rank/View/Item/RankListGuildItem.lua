require "Core.Module.Common.UIItem"

RankListGuildItem = UIItem:New();

function RankListGuildItem:_Init()
    self._bg = UIUtil.GetChildByName(self.transform, "UISprite", "bg");
    self._txtRank = UIUtil.GetChildByName(self.transform, "UILabel", "txtRank");
    self._icoRank = UIUtil.GetChildByName(self.transform, "UISprite", "icoRank");
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._icoKind = UIUtil.GetChildByName(self.transform, "UISprite", "icoKind");
    self._txtLeader = UIUtil.GetChildByName(self.transform, "UILabel", "txtLeader");
    self._txtContent = UIUtil.GetChildByName(self.transform, "UILabel", "txtContent");
    self._txtNum = UIUtil.GetChildByName(self.transform, "UILabel", "txtNum");
    self._icoVip = UIUtil.GetChildByName(self.transform, "UISprite", "icoVip");

    self._txtNo = UIUtil.GetChildByName(self.transform, "UILabel", "txtNo");
    if self._txtNo then
        self._txtNo.gameObject:SetActive(false);
    end

    --[[    
    self._icoSelect = UIUtil.GetChildByName(self.transform, "UISprite", "icoSelect");
    if self._icoSelect then
        self._icoSelect.gameObject:SetActive(false);
    end

    self._onClick = function(go) self:_OnClick(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick); 
    ]]
    self:UpdateItem(self.data);
end

function RankListGuildItem:_Dispose()
    --UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    --self._onClick = nil;
end

function RankListGuildItem:UpdateItem(data)
    self.data = data;

    if data and data.id > 0 then

        if self._txtNo then
            self._txtNo.gameObject:SetActive(false);
        end

        if self._bg then
            local isMyGuild = data.gId == GuildDataManager.gId;
            --log(data.leader .. " " .. data.gId .. " - ".. GuildDataManager.gId);
            self._bg.alpha = isMyGuild and 1 or 0.5;
        end

        if data.id > 0 and data.id < 4 then 
            self._txtRank.gameObject:SetActive(false);
            self._icoRank.gameObject:SetActive(true);
            self._icoRank.spriteName = "no" .. data.id;
        else
            self._txtRank.gameObject:SetActive(true);
            self._icoRank.gameObject:SetActive(false);

            self._txtRank.text = data.id;
        end
        
        self._txtName.text = RankConst.GetRankColor(data.id, data.gName);
        self._icoKind.spriteName = "c" .. data.playerKind;
        self._txtLeader.text = data.leader;
        local lvCfg = ConfigManager.GetGuildLevelConfig(data.level);
        local lvStr = LanguageMgr.Get("common/numMax", {num = data.num, max = lvCfg and lvCfg.number or 0});
        self._txtNum.text = RankConst.GetRankColor(data.id, lvStr);
        self:UpdateType(data);

        --self._icoVip.spriteName = VIPManager.GetVipIconByVip(data.vip);
        self._icoVip.spriteName = ''
	    local vc = ColorDataManager.Get_Vip(data.vip)	
	    self._txtName.text = vc .. self._txtName.text
    else
        self._txtNo.gameObject:SetActive(true);
        if data and data.id < 0 and self._txtNo then
            
            self._txtNo.text = LanguageMgr.Get("rank/noData/" .. data.type);
        else
            self._txtNo.text = LanguageMgr.Get("rank/0");
        end

        self._txtRank.text = "";
        self._icoRank.gameObject:SetActive(false);
        self._txtName.text = "";
        self._icoKind.spriteName = "";
        self._txtLeader.text = "";
        self._txtContent.text = "";
        self._txtNum.text = "";

        self._icoVip.spriteName = "";
    end
end

function RankListGuildItem:UpdateType(data)
    if data.type == RankConst.Type.GUILD_FIGHT then
        self._txtContent.text = RankConst.GetRankColor(data.id, data.fight);
    elseif data.type == RankConst.Type.GUILD_RANK then
        self._txtContent.text = RankConst.GetRankColor(data.id, data.level);
    end
end

--[[
function RankListGuildItem:_OnClick()
    --MessageManager.Dispatch(RankNotes, RankNotes.ENV_ITEM_SIMPLE_SELECT, self.data);
end

function RankListGuildItem:UpdateSelected(data)
    local selected = false;
    if (self.data ~= nil) then
         selected = self.data.id == data.id;
    end
    self._icoSelect.gameObject:SetActive(selected);
end
]]