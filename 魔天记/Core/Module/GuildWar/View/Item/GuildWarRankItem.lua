require "Core.Module.Common.UIItem"

--GuildWarRankItem = class("GuildWarRankItem", GuildWarRoleItem);
GuildWarRankItem = UIItem:New();

function GuildWarRankItem:_Init()
    self._bg = UIUtil.GetChildByName(self.transform, "UISprite", "bg");
    self._txtRank = UIUtil.GetChildByName(self.transform, "UILabel", "txtRank");
    self._icoRank = UIUtil.GetChildByName(self.transform, "UISprite", "icoRank");
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._txtLev = UIUtil.GetChildByName(self.transform, "UILabel", "txtLev");
    self._txtPoint = UIUtil.GetChildByName(self.transform, "UILabel", "txtPoint");

    self._icoKind = UIUtil.GetChildByName(self.transform, "UISprite", "icoKind");
    self._txtLeader = UIUtil.GetChildByName(self.transform, "UILabel", "txtLeader");
    self._icoVip = UIUtil.GetChildByName(self.transform, "UISprite", "icoVip");
    self._txtNum = UIUtil.GetChildByName(self.transform, "UILabel", "txtNum");

    self:UpdateItem(self.data);
end

function GuildWarRankItem:_Dispose()
    
end

function GuildWarRankItem:UpdateItem(data)
    if data then

        if self._bg then
            local isMyGuild = data.tgi == GuildDataManager.gId;
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

        self._txtName.text = RankConst.GetRankColor(data.id, data.tgn);
        self._txtLev.text = data.tlv;
        --self._icoKind.spriteName = "c" .. data.k;
        self._txtPoint.text = data.pt;
        
        --self._icoKind.spriteName = "c" .. data.playerKind;
        --self._icoVip.spriteName = VIPManager.GetVipIconByVip(data.vip);
        self._txtLeader.text = data.pn;
        self._txtNum.text = data.ft;
    end
end
