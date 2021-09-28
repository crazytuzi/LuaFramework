require "Core.Module.Common.UIItem"


XMBossFuLiItem = class("XMBossFuLiItem", UIItem);
XMBossFuLiItem.currSelected = nil;

XMBossFuLiItem.Def_FuLi = {
    [1] = 501101,
    -- 金宝箱
    [2] = 501201,
    -- 银宝箱
  [3] = 501301-- 节日宝箱
};

function XMBossFuLiItem:New()
    self = { };
    setmetatable(self, { __index = XMBossFuLiItem });
    return self
end
 

function XMBossFuLiItem:UpdateItem(data)
    self.data = data
end

function XMBossFuLiItem:Init(gameObject, data)

    self.gameObject = gameObject;

    self.nicon = UIUtil.GetChildByName(self.gameObject, "UISprite", "nicon");
    self.selectedbg = UIUtil.GetChildByName(self.gameObject, "UISprite", "selectedbg");


    self.ntxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "ntxt");
    self.xmNametxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "xmNametxt");
    self.valuetxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "valuetxt");


    self.award1 = UIUtil.GetChildByName(self.gameObject, "Transform", "award1");
    self.award2 = UIUtil.GetChildByName(self.gameObject, "Transform", "award2");
    self.award3 = UIUtil.GetChildByName(self.gameObject, "Transform", "award3");



    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

    for i = 1, 3 do
        local obj = { num = 0, spId = XMBossFuLiItem.Def_FuLi[i] };
        self:SetAward(obj, i)
    end

end



function XMBossFuLiItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end


function XMBossFuLiItem:_OnClickBtn()

    if XMBossFuLiItem.currSelected ~= nil then
        XMBossFuLiItem.currSelected.selectedbg.gameObject:SetActive(false);
    end

    XMBossFuLiItem.currSelected = self;
    XMBossFuLiItem.currSelected.selectedbg.gameObject:SetActive(true);

end

function XMBossFuLiItem:UpAward(pid, pl)

    if self.data ~= nil then

        if self.data.id == pid then
            self.data.l = pl;

            local l = self.data.l;
            local t_num = table.getn(l);
            for i = 1, t_num do
                local obj = l[i];
                self:SetAward(obj, obj.t)
            end

        end


    end


end

--[[
 {id=10001,n="asdfefadf3",v=2155 ,idx=2}
]]
function XMBossFuLiItem:SetData(data, type)

    self.data = data;

    if self.data ~= nil then

        self.ntxt.text = "" .. data.idx;
        if data.idx > 3 then

            self.ntxt.gameObject:SetActive(true);
            self.nicon.gameObject:SetActive(false);
        else

            self.nicon.spriteName = "no" .. data.idx;
            self.ntxt.gameObject:SetActive(false);
            self.nicon.gameObject:SetActive(true);
        end

        self.xmNametxt.text = data.n;
        self.valuetxt.text = data.v;

        --
        local l = data.l;
        local t_num = table.getn(l);

         for i = 1, 3 do
            self:SetAward(nil, i)
        end

        for i = 1, t_num do
            local obj = l[i];
            self:SetAward(obj, obj.t)
        end


        self:SetActive(true);
    else

        self:SetActive(false);
    end


end

function XMBossFuLiItem:SetAward(data, i)


    local award = self["award" .. i];

    local icon = UIUtil.GetChildByName(award, "UISprite", "icon");
    local numtxt = UIUtil.GetChildByName(award, "UILabel", "numtxt");

    if data ~= nil then
        local infocf = ProductManager.GetProductById(data.spId);

         ProductManager.SetIconSprite(icon, infocf.icon_id);
        numtxt.text = data.num .. LanguageMgr.Get("XMBoss/XMBossFuLiItem/label1");
    else
       numtxt.text = "0";
    end

  



end


function XMBossFuLiItem:_Dispose()


    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self.gameObject = nil;

    self.nicon =  nil;
    self.selectedbg =  nil;


    self.ntxt =  nil;
    self.xmNametxt =  nil;
    self.valuetxt =  nil;


    self.award1 =  nil;
    self.award2 =  nil;
    self.award3 = nil;


end