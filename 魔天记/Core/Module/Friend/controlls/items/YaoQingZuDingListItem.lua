YaoQingZuDingListItem = class("YaoQingZuDingListItem", UIItem);

function YaoQingZuDingListItem:New()
    self = { };
    setmetatable(self, { __index = YaoQingZuDingListItem });
    return self
end

function YaoQingZuDingListItem:Init(gameObject, data)
    self.gameObject = gameObject


    self.infos = UIUtil.GetChildByName(self.gameObject, "Transform", "infos");

    self.imgIcon = UIUtil.GetChildByName(self.infos, "UISprite", "imgIcon");

    self.txtName = UIUtil.GetChildByName(self.infos, "UILabel", "txtName");
    self.txtLevel = UIUtil.GetChildByName(self.infos, "UILabel", "txtLevel");
    self.fightTxt = UIUtil.GetChildByName(self.infos, "UILabel", "fightTxt");

    self.yaoqing_bt = UIUtil.GetChildByName(self.gameObject, "UIButton", "yaoqing_bt");
    self._onClickyaoqing_bt = function(go) self:_OnClickyaoqing_bt(self) end
    UIUtil.GetComponent(self.yaoqing_bt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickyaoqing_bt);



    self:SetData(data);
end



function YaoQingZuDingListItem:SetActive(v)
    self.enble = v;
    self.gameObject.gameObject:SetActive(v);
end

function YaoQingZuDingListItem:_OnClickyaoqing_bt()

    FriendProxy.TryInviteToTeam(self.info.id,self.info.name);
end

--[[
 1--level= [66]
| --id= [10000758]
| --sex= [0]
| --fight= [120977]
| --is_online= [1]
| --kind= [102000]
| --type= [1]
| --name= [龙星]
| --tid= [1049]
]]

function YaoQingZuDingListItem:SetData(data)
  
  self.info=data;

   self.imgIcon.spriteName = ""..data.kind;

    self.txtName.text=data.name;
    self.txtLevel.text=""..data.level;
    self.fightTxt.text=""..data.fight;

end



function YaoQingZuDingListItem:_Dispose()

    UIUtil.GetComponent(self.yaoqing_bt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickyaoqing_bt = nil;


    self.gameObject = nil;




end