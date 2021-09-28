require "Core.Module.Common.UIItem"


XMHuoDongJinDuRankItem = class("XMHuoDongJinDuRankItem", UIItem);


function XMHuoDongJinDuRankItem:New()
    self = { };
    setmetatable(self, { __index = XMHuoDongJinDuRankItem });
    return self
end
 

function XMHuoDongJinDuRankItem:UpdateItem(data)
    self.data = data
end

function XMHuoDongJinDuRankItem:Init(gameObject, data)

    self.gameObject = gameObject;

    self.nicon = UIUtil.GetChildByName(self.gameObject, "UISprite", "nicon");
   -- self.micon1 = UIUtil.GetChildByName(self.gameObject, "UISprite", "micon1");
   -- self.micon2 = UIUtil.GetChildByName(self.gameObject, "UISprite", "micon2");


    self.idxTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "idxTxt");
    self.nameTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "nameTxt");
    self.hurtTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "hurtTxt");
    self.timeTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "timeTxt");

   -- self.mtxt1 = UIUtil.GetChildByName(self.gameObject, "UILabel", "mtxt1");
  --  self.mtxt2 = UIUtil.GetChildByName(self.gameObject, "UILabel", "mtxt2");

    --[[
    self._onClickBtn1 = function(go) self:_OnClickBtn1(self) end
    UIUtil.GetComponent(self.micon1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn1);

    self._onClickBtn2 = function(go) self:_OnClickBtn2(self) end
    UIUtil.GetComponent(self.micon2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn2);
    ]]


    self:SetData(data)
end



function XMHuoDongJinDuRankItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end

function XMHuoDongJinDuRankItem:_OnClickBtn1()
    local cf = self["pcf1"];
    ProductCtrl.ShowProductTip(cf.id, ProductCtrl.TYPE_FROM_OTHER, cf.num);

end


function XMHuoDongJinDuRankItem:_OnClickBtn2()
    local cf = self["pcf2"];
    ProductCtrl.ShowProductTip(cf.id, ProductCtrl.TYPE_FROM_OTHER, cf.num);

end

-- l:{[idx:排名，tn：帮会呢称，h:累计伤害值，t:累计时间，item：[spid：道具id，num：道具数量]]
--[[
 S <-- 11:18:45.305, 0x1602, 14, {"l":[{"h":71283,"t":180,"idx":1,"tn":"u","item":[{"num":3,"spId":501101},{"num":5,"spId":501201}]}]}
]]
function XMHuoDongJinDuRankItem:SetData(data)

    self.data = data;

    self.idxTxt.text = "" .. data.idx;
    self.nameTxt.text = data.tn;
    self.hurtTxt.text = data.h .. "";
    self.timeTxt.text = GetTimeByStr(data.t);

    if data.idx <= 3 then
        self.nicon.spriteName = "no" .. data.idx;
        self.idxTxt.gameObject:SetActive(false);
        self.nicon.gameObject:SetActive(true);

    else
        self.nicon.gameObject:SetActive(false);
        self.idxTxt.gameObject:SetActive(true);
    end

    local item = data.item;
    local t_num = table.getn(item);

   -- self.micon1.gameObject:SetActive(false);
   -- self.micon2.gameObject:SetActive(false);

    --self.mtxt1.gameObject:SetActive(false);
    --self.mtxt2.gameObject:SetActive(false);

    for i = 1, 2 do

        if i <= t_num then
            local obj = item[i];
            self["pcf" .. i] = ProductManager.GetProductById(obj.spId);
          --  ProductManager.SetIconSprite(self["micon" .. i], self["pcf" .. i].icon_id);

           -- self["mtxt" .. i].text = obj.num .. LanguageMgr.Get("XMBoss/XMBossFuLiItem/label1");

            self["pcf" .. i].num = obj.num;

            --self["micon" .. i].gameObject:SetActive(true);
           -- self["mtxt" .. i].gameObject:SetActive(true);

        end

    end

end


function XMHuoDongJinDuRankItem:_Dispose()

   -- UIUtil.GetComponent(self.micon1, "LuaUIEventListener"):RemoveDelegate("OnClick");
   -- UIUtil.GetComponent(self.micon2, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self.gameObject = nil;

    self.nicon = nil;
    --self.micon1 = nil;
    --self.micon2 = nil;


    self.idxTxt = nil;
    self.nameTxt = nil;
    self.hurtTxt = nil;
    self.timeTxt = nil;

   -- self.mtxt1 = nil;
  --  self.mtxt2 = nil;

end