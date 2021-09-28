require "Core.Module.Common.UIItem"

GuildWarRoleItem = UIItem:New();

function GuildWarRoleItem:_Init()
    
    self._bg = UIUtil.GetChildByName(self.transform, "UISprite", "bg");
    self._txtRank = UIUtil.GetChildByName(self.transform, "UILabel", "txtRank");
    self._icoRank = UIUtil.GetChildByName(self.transform, "UISprite", "icoRank");
    self._icoKind = UIUtil.GetChildByName(self.transform, "UISprite", "icoKind");
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._txtLev = UIUtil.GetChildByName(self.transform, "UILabel", "txtLev");
    self._txtPoint = UIUtil.GetChildByName(self.transform, "UILabel", "txtPoint");

    self:UpdateItem(self.data);
end

function GuildWarRoleItem:_Dispose()
    
end

function GuildWarRoleItem:UpdateItem(data)
    self.data = data;
    
    if data then
        if self._bg then
            local isMy = data.pi == PlayerManager.playerId;
            self._bg.alpha = isMy and 1 or 0.5;
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
        if self._icoKind then
            self._icoKind.spriteName = "c" .. data.k;
        end
        self._txtName.text = RankConst.GetRankColor(data.id, data.pn);
        self._txtLev.text = data.lv;        
        self._txtPoint.text = data.pt;
    end
end
