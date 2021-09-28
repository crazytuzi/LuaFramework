require "Core.Module.Common.UIItem"


XMBossJoinInfosItem = class("XMBossJoinInfosItem", UIItem);


function XMBossJoinInfosItem:New()
    self = { };
    setmetatable(self, { __index = XMBossJoinInfosItem });
    return self
end
 

function XMBossJoinInfosItem:UpdateItem(data)
    self.data = data
end

function XMBossJoinInfosItem:Init(gameObject, data)

    self.gameObject = gameObject;

    self.cicon = UIUtil.GetChildByName(self.gameObject, "UISprite", "cicon");

    self.nameTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "nameTxt");
    self.lvTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "lvTxt");
    self.fTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "fTxt");

    self:SetData(data);

end



function XMBossJoinInfosItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end


--[[
l:{[n:玩家呢称，l:玩家等级，f:战斗力，c:职业]}

{"n":"\u5F6D\u6587\u5BB9","c":104000,"l":48,"f":274031}

]]
function XMBossJoinInfosItem:SetData(data)

    self.data = data;

    self.cicon.spriteName = "c" .. data.c;
    self.nameTxt.text = data.n;
    self.lvTxt.text = data.l .. "";
    self.fTxt.text = data.f .. "";

end


function XMBossJoinInfosItem:_Dispose()
    self.gameObject = nil;
     self.data = nil;
    self.cicon = nil;

    self.nameTxt = nil;
    self.lvTxt = nil;
    self.fTxt = nil;

end