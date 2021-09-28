require "Core.Module.Common.UIItem"

DaysRankListItem = UIItem:New();

function DaysRankListItem:_Init()
	self._bg = UIUtil.GetChildByName(self.transform, "UISprite", "bg");
    self._txtRank = UIUtil.GetChildByName(self.transform, "UILabel", "txtRank");
    self._icoRank = UIUtil.GetChildByName(self.transform, "UISprite", "icoRank");
    self._icoKind = UIUtil.GetChildByName(self.transform, "UISprite", "icoKind");
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._txtContent = UIUtil.GetChildByName(self.transform, "UILabel", "txtContent");
    self._txtGuild = UIUtil.GetChildByName(self.transform, "UILabel", "txtGuild");

    self:UpdateItem(self.data);
end

function DaysRankListItem:_Dispose()

end

function DaysRankListItem:UpdateItem(data)
    self.data = data;
    
    if data then
    	if self._bg then
            self._bg.alpha = data.uid == PlayerManager.playerId and 1 or 0.5;
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

        self._txtName.text = data.uName;
        self._icoKind.spriteName = "c" .. data.kind;

        local c = data.value;

        if data.type == DaysRankManager.Type.WING then
            c = LanguageMgr.Get("daysRank/content/wing", data);

        elseif data.type == DaysRankManager.Type.PET then
        
         local rank,star =  PetManager.ChangeStarLevToRank(data.value);
        -- log("-- data.value-- "..data.value.." "..rank.." "..star);
           c = LanguageMgr.Get("daysRank/content/pet", {v1=rank,v2=star});
        end

        self._txtContent.text = c;
        self._txtGuild.text = data.gName;
    else
    	self._txtName.text = "";
    	self._icoKind.spriteName = "";
    	self._txtContent.text = "";
        self._txtGuild.text = "";
    end
end