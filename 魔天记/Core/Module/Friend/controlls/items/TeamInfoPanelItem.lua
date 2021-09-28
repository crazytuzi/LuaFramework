require "Core.Module.Common.UIItem"


TeamInfoPanelItem = class("TeamInfoPanelItem", UIItem);

function TeamInfoPanelItem:New()
    self = { };
    setmetatable(self, { __index = TeamInfoPanelItem });
    return self
end

function TeamInfoPanelItem:UpdateItem(data)
    self.data = data
end

function TeamInfoPanelItem:Init(gameObject, data)

    self.data = data
    self.gameObject = gameObject

    self.caree_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "caree_txt");
    self.name_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "name_txt");
    self.level_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "level_txt");
    self.fight_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "fight_txt");
    self.player_num_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "player_num_txt");

    self.askFro_bt = UIUtil.GetChildByName(self.gameObject, "UIButton", "askFro_bt");

    self.askFro_bt_btHandler = function(go) self:AskFro_bt_btHandler(self) end
    UIUtil.GetComponent(self.askFro_bt, "LuaUIEventListener"):RegisterDelegate("OnClick", self.askFro_bt_btHandler);


    self:UpdateItem(self.data);



end

function TeamInfoPanelItem:AskFro_bt_btHandler()
    if self.infoData ~= nil then
        FriendProxy.TryJoinTeamAsk(self.infoData.id,self.infoData.n)
    end
end




function TeamInfoPanelItem:SetActive(v)
    self.gameObject:SetActive(v);
end

--  {"f":1128,"num":1,"k":101000,"id":1,"l":1,"n":"姜小浩"}
-- 入队申请
function TeamInfoPanelItem:SetData(infoData)

    self.infoData = infoData;

    local careerCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CAREER);
    local baseInfo = careerCfg[self.infoData.k];

    self.caree_txt.text = baseInfo.career;
    self.name_txt.text = self.infoData.n;
    self.level_txt.text = GetLvDes1(self.infoData.l);

    self.fight_txt.text = "" .. self.infoData.f;
    self.player_num_txt.text = self.infoData.num .. "/4";

    self:SetActive(true);
end


function TeamInfoPanelItem:_Dispose()



    UIUtil.GetComponent(self.askFro_bt, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self.askFro_bt_btHandler = nil;



    self.gameObject = nil;
    self.data = nil;

    self.caree_txt = nil;
    self.name_txt = nil;
    self.level_txt = nil;
    self.fight_txt = nil;
    self.player_num_txt = nil;

    self.askFro_bt = nil;

end 