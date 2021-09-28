AddHeroItem = class("AddHeroItem");


function AddHeroItem:New()
    self = { };
    setmetatable(self, { __index = AddHeroItem });
    return self
end


function AddHeroItem:Init(gameObject)

    self.gameObject = gameObject

    self.bg = UIUtil.GetChildByName(self.gameObject, "UISprite", "bg");


    self.dealBt1 = UIUtil.GetChildByName(self.gameObject, "UIButton", "dealBt1");
    self.dealBt2 = UIUtil.GetChildByName(self.gameObject, "UIButton", "dealBt2");


    self.deal1BtHandler = function(go) self:DealBtHandler(1) end
    self.deal2BtHandler = function(go) self:DealBtHandler(2) end


    self.bgClick = function(go) self:BgClick() end

    UIUtil.GetComponent(self.dealBt1, "LuaUIEventListener"):RegisterDelegate("OnClick", self.deal1BtHandler);
    UIUtil.GetComponent(self.dealBt2, "LuaUIEventListener"):RegisterDelegate("OnClick", self.deal2BtHandler);


    UIUtil.GetComponent(self.bg, "LuaUIEventListener"):RegisterDelegate("OnClick", self.bgClick);


    self:SetActive(false);

end

function AddHeroItem:BgClick()

    self:SetActive(false);

end


function AddHeroItem:HideAllBts()

    self.dealBt1.gameObject:SetActive(false);
    self.dealBt2.gameObject:SetActive(false);

end


function AddHeroItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end


function AddHeroItem:Show(index)


    self.index = index;
    local tempPos = Vector3.zero
    if self.index == 1 then
        tempPos = Vector3.New(-651, 0, 0);
    elseif self.index == 2 then
        tempPos = Vector3.New(-390, 0, 0);
    elseif self.index == 3 then
        tempPos = Vector3.New(-103, 0, 0);
    elseif self.index == 4 then
        tempPos = Vector3.New(145, 0, 0);
    end
    Util.SetLocalPos(self.gameObject, tempPos.x, tempPos.y, tempPos.z)

    self:SetActive(true);

    -- 需要判断自己是否已经有仙盟

    local b = GuildDataManager.InGuild();

    if not b then
        -- self.dealBt2.gameObject:SetActive(false);
    end

end


function AddHeroItem:DealBtHandler(index)


    if index == 2 then

        local b = GuildDataManager.InGuild();

        if not b then

            MsgUtils.ShowTips("Friend/AddHeroItem/label1");
            return;
        end

    end



    ModuleManager.SendNotification(FriendNotes.OPEN_YAOQINGZUDINGLISTPANEL, { type = index });


    self:SetActive(false);
end






function AddHeroItem:Dispose()

    UIUtil.GetComponent(self.dealBt1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.dealBt2, "LuaUIEventListener"):RemoveDelegate("OnClick");


    UIUtil.GetComponent(self.bg, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self.deal1BtHandler = nil;
    self.deal2BtHandler = nil;


    self.bgClick = nil;

    self.gameObject = nil;

    self.bg = nil;


    self.dealBt1 = nil;
    self.dealBt2 = nil;


end