require "Core.Module.InstancePanel.View.items.GiftItem"

BottomPanelCtr = class("BottomPanelCtr");

function BottomPanelCtr:New()
    self = { };
    setmetatable(self, { __index = BottomPanelCtr });
    return self
end


function BottomPanelCtr:Init(gameObject)
    self.gameObject = gameObject;

    --[[
    self.btnAllShaodang = UIUtil.GetChildByName(self.gameObject, "UIButton", "btnAllShaodang");


    self._onbtnAllShaodang = function(go) self:_OnbtnAllShaodang(self) end
    UIUtil.GetComponent(self.btnAllShaodang, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onbtnAllShaodang);
    ]]

    self.slider = UIUtil.GetChildByName(self.gameObject, "Transform", "slider");
    self.progress = UIUtil.GetChildByName(self.slider, "UISprite", "progress");

    self.boxNum = 6;

    for i = 1, self.boxNum do
        self["gift" .. i] = UIUtil.GetChildByName(self.gameObject, "Transform", "gift" .. i);
        self["giftCtr" .. i] = GiftItem:New();
        self["giftCtr" .. i]:Init(self["gift" .. i], i);
    end

    InstancePanelProxy.TryGetGBoxInfos();
    MessageManager.AddListener(InstanceDataManager, InstanceDataManager.MESSAGE_INSTANCEDATA_BOXINFO_CHANGE, BottomPanelCtr.UpInfo, self);


end

function BottomPanelCtr:Set_kind(kind)
    self.kind = kind;
end

--[[
function BottomPanelCtr:_OnbtnAllShaodang()


    InstancePanelProxy.TryYIJianSaodang(InstanceDataManager.InstanceType.MainInstance, self.kind);

end
]]
function BottomPanelCtr:setData(fb_type, fb_kind)

    self.fb_type = fb_type;
    self.fb_kind = fb_kind;

    self:UpInfo()
end

function BottomPanelCtr:UpInfo()
    self.data = InstanceDataManager.GetListByKeys(self.fb_type, self.fb_kind);


    self:Set_kind(self.fb_kind);

    local starTotal = InstanceDataManager.GetTotalStarNumByKey(self.fb_type, self.fb_kind);
    local chapter_reward = self.data[1].chapter_reward;

    for i = 1, self.boxNum do
        self["giftCtr" .. i]:SetData(chapter_reward[i], self.fb_type, self.fb_kind, starTotal);
    end

    -- ???? ????
    local t_num = table.getn(chapter_reward);
  
     local numList = string.split(chapter_reward[t_num], "_");


    if starTotal == 0 then

      self.progress.gameObject:SetActive(false);
    else

     self.progress.width = 940 *(starTotal *(1 / numList[1]));
     self.progress.gameObject:SetActive(true);
    end


end

function BottomPanelCtr:Show()


    self.gameObject.gameObject:SetActive(true);
end

function BottomPanelCtr:Hide()


    self.gameObject.gameObject:SetActive(false);
end

function BottomPanelCtr:Dispose()

    --[[
    UIUtil.GetComponent(self.btnAllShaodang, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onbtnAllShaodang = nil;
    ]]
    MessageManager.RemoveListener(InstanceDataManager, InstanceDataManager.MESSAGE_INSTANCEDATA_BOXINFO_CHANGE, BottomPanelCtr.UpInfo);

    for i = 1, self.boxNum do
        self["giftCtr" .. i]:Dispose();
        self["giftCtr" .. i] = nil;
        self["gift" .. i] = nil;
    end

    self.gameObject = nil;

    --  self.btnAllShaodang = nil;




end