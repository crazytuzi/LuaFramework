require "Core.Module.Common.UIItem"
require "Core.Module.Friend.controlls.PartData"


PlayerInfoPanelItem = class("PlayerInfoPanelItem", UIItem);

function PlayerInfoPanelItem:New()
    self = { };
    setmetatable(self, { __index = PlayerInfoPanelItem });
    return self
end
 
function PlayerInfoPanelItem:UpdateItem(data)
    self.data = data
end

function PlayerInfoPanelItem:Init(gameObject, data)

    self.data = data
    self.gameObject = gameObject

    self.caree_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "caree_txt");
    self.name_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "name_txt");
    self.level_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "level_txt");
    self.fight_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "fight_txt");

    self.askFro_bt = UIUtil.GetChildByName(self.gameObject, "UIButton", "askFro_bt");

    self.my_team_icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "my_team_icon");

    self.askFro_bt_btHandler = function(go) self:AskFro_bt_btHandler(self) end
    UIUtil.GetComponent(self.askFro_bt, "LuaUIEventListener"):RegisterDelegate("OnClick", self.askFro_bt_btHandler);

    self.my_team_icon.gameObject:SetActive(false);

    self:UpdateItem(self.data);

end

function PlayerInfoPanelItem:AskFro_bt_btHandler()

     FriendProxy.TryInviteToTeam(self.infoData.pid,self.infoData.n);
   

end



function PlayerInfoPanelItem:CreateTeam()
    FriendProxy.TryCreateArmy()
end


function PlayerInfoPanelItem:SetActive(v)
    self.gameObject:SetActive(v);
end

--[[
l:[{pid:玩家id，n:玩家昵称,k：玩家kind,l:等级,f:战斗力},..]

]]
function PlayerInfoPanelItem:SetData(infoData)

    self.infoData = infoData;

    local careerCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CAREER);
    local baseInfo = careerCfg[self.infoData.k];

    if self.infoData.l == nil then
        self.infoData.l = 1;
    end


    self.caree_txt.text = baseInfo.career;
    self.name_txt.text = self.infoData.n;
    self.level_txt.text = GetLvDes1(self.infoData.l);


    self.fight_txt.text = "" .. self.infoData.f;

    local pid = infoData.pid;
    local imyTemd = PartData.FindMyTeammateData(pid);


    if imyTemd ~= nil then

        if imyTemd.p == 1 then
            self.my_team_icon.spriteName = "myis_leaderIcon";
        else
            self.my_team_icon.spriteName = "myis_teamerIcon";
        end


        self.my_team_icon.gameObject:SetActive(true);

    else
        self.my_team_icon.gameObject:SetActive(false);

    end

    self:SetActive(true);
end
   

function PlayerInfoPanelItem:_Dispose()
    self.gameObject = nil;
    self.data = nil;

    self.caree_txt = nil;
    self.name_txt = nil;
    self.level_txt = nil;
    self.fight_txt = nil;


    UIUtil.GetComponent(self.askFro_bt, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self.askFro_bt = nil;

    self.askFro_bt_btHandler = nil;

end