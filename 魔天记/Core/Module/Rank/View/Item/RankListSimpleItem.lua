require "Core.Module.Common.UIItem"

RankListSimpleItem = UIItem:New();

-- local partner_advance = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_PARTNER_ADVANCE);
function RankListSimpleItem:_Init()
    self._bg = UIUtil.GetChildByName(self.transform, "UISprite", "bg");
    self._txtRank = UIUtil.GetChildByName(self.transform, "UILabel", "txtRank");
    self._icoRank = UIUtil.GetChildByName(self.transform, "UISprite", "icoRank");
    self._icoKind = UIUtil.GetChildByName(self.transform, "UISprite", "icoKind");
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._txtContent = UIUtil.GetChildByName(self.transform, "UILabel", "txtContent");
    self._icoContent = UIUtil.GetChildByName(self.transform, "UISprite", "icoContent");
    self._icoVip = UIUtil.GetChildByName(self.transform, "UISprite", "icoVip");

    self._txtNo = UIUtil.GetChildByName(self.transform, "UILabel", "txtNo");
    if self._txtNo then
        self._txtNo.gameObject:SetActive(false);
    end

    self._icoSelect = UIUtil.GetChildByName(self.transform, "UISprite", "icoSelect");
    if self._icoSelect then
        self._icoSelect.gameObject:SetActive(false);
    end

    self._onClick = function(go) self:_OnClick(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);

    self:UpdateItem(self.data);
end

function RankListSimpleItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClick = nil;
end

function RankListSimpleItem:UpdateItem(data)
    self.data = data;

    if data and data.id > 0 then

        if self._txtNo then
            self._txtNo.gameObject:SetActive(false);
        end

        if self._bg then
            self._bg.alpha = data.playerId == PlayerManager.playerId and 1 or 0.5;
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
        self._txtName.text = data.playerName;

        self._icoKind.spriteName = "c" .. data.playerKind;

        self._txtContent.text = "";
        self._icoContent.spriteName = "";
        self:UpdateType(data);



        if data.type == RankConst.Type.PET then
            self._icoVip.spriteName = "";
        else
            --self._icoVip.spriteName = VIPManager.GetVipIconByVip(data.vip);
            self._icoVip.spriteName = ''
	        local vc = ColorDataManager.Get_Vip(data.vip)
	        self._txtName.text = vc .. self._txtName.text
        end

    else
        self._txtNo.gameObject:SetActive(true);
        if data and self._txtNo then
            if data.id < 0 then
                self._txtNo.text = LanguageMgr.Get("rank/noData/" .. data.type);
            else
                self._txtNo.text = LanguageMgr.Get("rank/0");
            end
        end

        self._txtRank.text = "";
        self._icoRank.gameObject:SetActive(false);
        self._txtName.text = "";
        self._icoKind.spriteName = "";
        self._txtContent.text = "";
        self._icoContent.spriteName = "";

        self._icoVip.spriteName = "";
    end
end

function RankListSimpleItem:UpdateType(data)
    local cStr = "";
    self._icoKind.gameObject:SetActive(true);
    if data.type == RankConst.Type.FIGHT then
        cStr = data.fight;
    elseif data.type == RankConst.Type.LEVEL then
        cStr = GetLvDes1(data.level);
    elseif data.type == RankConst.Type.GOLD then
        cStr = data.gold;
        self._icoContent.spriteName = "xianyu";
    elseif data.type == RankConst.Type.MONEY then
        cStr = data.money;
        self._icoContent.spriteName = "lingshi";
    elseif data.type == RankConst.Type.PET then
        self._icoKind.gameObject:SetActive(false);

        local petcf = PetManager.GetPetConfig(data.use_id)
        self._txtName.text = petcf.name;
        -- cStr = data.fight;
        local rankLevel, star = PetManager.ChangeStarLevToRank(data.s);

        cStr = LanguageMgr.Get("rank/Item/LabelPet", { n = rankLevel, m = star });
    elseif data.type == RankConst.Type.REALM then
        cStr = data.level;
    elseif data.type == RankConst.Type.WING then
        cStr = LanguageMgr.Get("rank/content/22", data);
    elseif data.type == RankConst.Type.ARENA then
        cStr = data.fight;
    elseif data.type == RankConst.Type.XULING then
        cStr = data.level;
    elseif data.type == RankConst.Type.AUTOFIGHT then
        cStr = data.exp;
    end

    self._txtContent.text = RankConst.GetRankColor(data.id, cStr);
end

function RankListSimpleItem:_OnClick()
    MessageManager.Dispatch(RankNotes, RankNotes.ENV_ITEM_SIMPLE_SELECT, self.data);
end

function RankListSimpleItem:UpdateSelected(data)
    local selected = false;
    if (self.data ~= nil) then
        selected = self.data.id == data.id;
    end

    self._icoSelect.gameObject:SetActive(selected);

end
