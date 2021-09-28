require "Core.Module.Common.UIItem"
PVPRankItem = class("PVPRankItem", UIItem);

function PVPRankItem:New()
    self = { };
    setmetatable(self, { __index = PVPRankItem });
    return self
end


function PVPRankItem:_Init()
    self:_InitReference();
    self:_InitListener();
    self:UpdateItem(self.data)
end

function PVPRankItem:_InitReference()
    --    local txts = UIUtil.GetComponentsInChildren(self.gameObject, "UILabel");
    --    self._txtChange = UIUtil.GetChildInComponents(txts, "txtChange");
    --    self._txtOwnerDes = UIUtil.GetChildInComponents(txts, "txtOwnerDes");
    --    self._txtSkillName = UIUtil.GetChildInComponents(txts, "txtSkillName");
    --    self._txtSkillLevel = UIUtil.GetChildInComponents(txts, "txtSkillLevel");
    --    self._btnChange = UIUtil.GetChildByName(self.transform, "UIButton", "btnChange")
    --    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "skillIcon")
    --    self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "skillQuality")
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
    self._txtRank = UIUtil.GetChildByName(self.transform, "UILabel", "rank")
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
    self._txtLevel = UIUtil.GetChildByName(self.transform, "UILabel", "level")
    self._txtReward1 = UIUtil.GetChildByName(self.transform, "UILabel", "reward1")
    self._txtReward2 = UIUtil.GetChildByName(self.transform, "UILabel", "reward2")

    self._btnCheck = UIUtil.GetChildByName(self.transform, "UIButton", "check")
    self._txtPower = UIUtil.GetChildByName(self.transform, "UILabel", "fight")
    self._imgRank = UIUtil.GetChildByName(self.transform, "UISprite", "rankBg")
    --    self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "quality")
end

function PVPRankItem:_InitListener()
    self._onBtnCheckClick = function(go) self:_OnBtnCheckClick(self) end
    UIUtil.GetComponent(self._btnCheck, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onBtnCheckClick);
end

function PVPRankItem:_OnBtnCheckClick()
    ModuleManager.SendNotification(OtherInfoNotes.OPEN_INFO_PANEL, self.data.p);
end

function PVPRankItem:UpdateItem(data)
    if (data == nil) then return end
    self.data = data
    self._txtRank.text = tostring(data.r)
    self._txtName.text = tostring(data.n)
    self._txtLevel.text = tostring(data.l)
    self._txtPower.text = tostring(data.f)
    self._imgRank.spriteName =(data.r <= 3) and "speRank" or "normalRank"

    local rankReward = PVPManager.GetPVPDailyReward(data.r)
    local rewardDes = ""
    local level = HeroController.GetInstance().info.level
    self._txtReward1.text = "0"
    self._txtReward2.text = "0"


    for k, v in ipairs(rankReward) do
        if (SpecialProductId.GongXunCoin == v.itemId) then
            self._txtReward1.text = tostring(v.itemValueBase + level * v.itemValueAdd)
        elseif SpecialProductId.Vp == v.itemId then
            self._txtReward2.text = tostring(v.itemValueBase + level * v.itemValueAdd)
        end
        --        local item = ProductManager.GetProductById(v.itemId)
        --        rewardDes = rewardDes ..(v.itemValueBase + level * v.itemValueAdd) .. item.name
        --        if (k ~= table.getCount(rankReward)) then
        --            rewardDes = rewardDes .. "\n"
        --        end
    end
    self._imgIcon.spriteName = ConfigManager.GetCareerByKind(data.k).icon_id
    --    self._txtReward.text = rewardDes

end

function PVPRankItem:_Dispose()
    UIUtil.GetComponent(self._btnCheck, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onBtnCheckClick = nil;
end
 
