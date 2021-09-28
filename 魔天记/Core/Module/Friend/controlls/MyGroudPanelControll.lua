
require "Core.Module.Friend.controlls.items.HeroInfoPanelItem";

require "Core.Module.Friend.controlls.items.AddHeroItem";

require "Core.Module.Friend.controlls.FBListSelectPanelCtr";

MyGroudPanelControll = class("MyGroudPanelControll");

function MyGroudPanelControll:New()
    self = { };
    setmetatable(self, { __index = MyGroudPanelControll });
    return self
end


function MyGroudPanelControll:Init(gameObject, groudDo2Bt)
    self.gameObject = gameObject;
    self.groudDo2Bt = groudDo2Bt;

    self._roleParent1 = UIUtil.GetChildByName(self.gameObject, "imgRole/heroCamera/trsRoleParent1");
    self._roleParent2 = UIUtil.GetChildByName(self.gameObject, "imgRole/heroCamera/trsRoleParent2");
    self._roleParent3 = UIUtil.GetChildByName(self.gameObject, "imgRole/heroCamera/trsRoleParent3");
    self._roleParent4 = UIUtil.GetChildByName(self.gameObject, "imgRole/heroCamera/trsRoleParent4");

    self._heroinfoPane1 = UIUtil.GetChildByName(self.gameObject, "imgRole/heroinfoPane1");
    self._heroinfoPane2 = UIUtil.GetChildByName(self.gameObject, "imgRole/heroinfoPane2");
    self._heroinfoPane3 = UIUtil.GetChildByName(self.gameObject, "imgRole/heroinfoPane3");
    self._heroinfoPane4 = UIUtil.GetChildByName(self.gameObject, "imgRole/heroinfoPane4");

    self.heroDealItem = UIUtil.GetChildByName(self.gameObject, "imgRole/heroDealItem");
    self.heroDealItemCtrl = HeroDealItem:New();
    self.heroDealItemCtrl:Init(self.heroDealItem);


    self.addHeroItem = UIUtil.GetChildByName(self.gameObject, "imgRole/addHeroItem");
    self.addHeroItemCtrl = AddHeroItem:New();
    self.addHeroItemCtrl:Init(self.addHeroItem);

    self.team_leaderIcon = UIUtil.GetChildByName(self.gameObject, "Transform", "team_leaderIcon");


    self.fbListSelectPanel = UIUtil.GetChildByName(self.gameObject, "Transform", "fbListSelectPanel");
    self.fbListSelectPanelCtr = FBListSelectPanelCtr:New();
    self.fbListSelectPanelCtr:Init(self.fbListSelectPanel, self.groudDo2Bt)

    self._HeroInfoPanelItem1 = HeroInfoPanelItem:New();
    self._HeroInfoPanelItem2 = HeroInfoPanelItem:New();
    self._HeroInfoPanelItem3 = HeroInfoPanelItem:New();
    self._HeroInfoPanelItem4 = HeroInfoPanelItem:New();


    self._HeroInfoPanelItem1:Init(self._roleParent1, self._heroinfoPane1, self.heroDealItemCtrl, 1, self.addHeroItemCtrl);
    self._HeroInfoPanelItem2:Init(self._roleParent2, self._heroinfoPane2, self.heroDealItemCtrl, 2, self.addHeroItemCtrl);
    self._HeroInfoPanelItem3:Init(self._roleParent3, self._heroinfoPane3, self.heroDealItemCtrl, 3, self.addHeroItemCtrl);
    self._HeroInfoPanelItem4:Init(self._roleParent4, self._heroinfoPane4, self.heroDealItemCtrl, 4, self.addHeroItemCtrl);

    -- 角色 血量 变化 不需要更新 时装
    -- MessageManager.AddListener(PartData, PartData.MESSAGE_PARTY_MENBER_DATA_CHANGE, MyGroudPanelControll.MenberDataChange, self);
    MessageManager.AddListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, MyGroudPanelControll.MenberDataChange, self);

    self.isFirst = true;

   
end

function MyGroudPanelControll:SetInstanceId(val)
    self.fbListSelectPanelCtr:SetInstanceId(val)
end

function MyGroudPanelControll:Show()

    self.gameObject:SetActive(true);
    self.showing = true;
    self:UpData();

end

function MyGroudPanelControll:Close()
    self.gameObject:SetActive(false);
    self.showing = false;

end


function MyGroudPanelControll:HideAllHeroMc()

    self._HeroInfoPanelItem1:Hdie();
    self._HeroInfoPanelItem2:Hdie();
    self._HeroInfoPanelItem3:Hdie();
    self._HeroInfoPanelItem4:Hdie();

end

function MyGroudPanelControll:MenberDataChange(data)

    if self._HeroInfoPanelItem1 ~= nil then
        self:UpData()
    end


end

-- 队伍数据发送改变
function MyGroudPanelControll:UpData()

    self:HideAllHeroMc();
    if self.showing then

        local myTeamData = PartData.GetMyTeam();

        if myTeamData ~= nil then

            local m = myTeamData.m;
            local index = 1;

            for key, value in pairs(m) do
                if index <= 4 then
                    self["_HeroInfoPanelItem" .. index]:Show(value);
                    index = index + 1;
                end

            end

            -- 需要 更新 数据模型
            if self.isFirst then

                self.isFirst = false;
            else
                FriendProxy.GetPartyDress();
            end



            self.team_leaderIcon.gameObject:SetActive(true);

        else
            self.team_leaderIcon.gameObject:SetActive(false);
        end

    end

end



function MyGroudPanelControll:GetPartyDressResult(data)

   if data == nil then
    return ;
   end 

    self._HeroInfoPanelItem1:UpDress(data.dress);
    self._HeroInfoPanelItem2:UpDress(data.dress);
    self._HeroInfoPanelItem3:UpDress(data.dress);
    self._HeroInfoPanelItem4:UpDress(data.dress);

    --  MessageManager.RemoveListener(PartData, PartData.MESSAGE_PARTY_MENBER_DATA_CHANGE, MyGroudPanelControll.MenberDataChange);
end

function MyGroudPanelControll:Dispose()

    -- MessageManager.RemoveListener(PartData, PartData.MESSAGE_PARTY_MENBER_DATA_CHANGE, MyGroudPanelControll.MenberDataChange);
    MessageManager.RemoveListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, MyGroudPanelControll.MenberDataChange);

    self._HeroInfoPanelItem1:Dispose();
    self._HeroInfoPanelItem2:Dispose();
    self._HeroInfoPanelItem3:Dispose();
    self._HeroInfoPanelItem4:Dispose();

    self.heroDealItemCtrl:Dispose();
    self.addHeroItemCtrl:Dispose();

    self.fbListSelectPanelCtr:Dispose();

    self._HeroInfoPanelItem1 = nil;
    self._HeroInfoPanelItem2 = nil;
    self._HeroInfoPanelItem3 = nil;
    self._HeroInfoPanelItem4 = nil;

    self.heroDealItemCtrl = nil;

    self._roleParent1 = nil;
    self._roleParent2 = nil;
    self._roleParent3 = nil;
    self._roleParent4 = nil;

    self._heroinfoPane1 = nil;
    self._heroinfoPane2 = nil;
    self._heroinfoPane3 = nil;
    self._heroinfoPane4 = nil;

    self.heroDealItem = nil;

end