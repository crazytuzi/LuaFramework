require "Core.Module.Common.UIItem"


XMBossGameResultItem = class("XMBossGameResultItem", UIItem);


function XMBossGameResultItem:New()
    self = { };
    setmetatable(self, { __index = XMBossGameResultItem });
    return self
end
 

function XMBossGameResultItem:UpdateItem(data)
    self.data = data
end

function XMBossGameResultItem:Init(gameObject, data)

    self.gameObject = gameObject;


    self.nicon = UIUtil.GetChildByName(self.gameObject, "UISprite", "nicon");
   -- self.awardIcon1 = UIUtil.GetChildByName(self.gameObject, "UISprite", "awardIcon1");
   -- self.awardIcon2 = UIUtil.GetChildByName(self.gameObject, "UISprite", "awardIcon2");

    self.ntxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "ntxt");
    self.xmNametxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "xmNametxt");
    self.valuetxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "valuetxt");
   -- self.awardtxt1 = UIUtil.GetChildByName(self.gameObject, "UILabel", "awardtxt1");
   -- self.awardtxt2 = UIUtil.GetChildByName(self.gameObject, "UILabel", "awardtxt2");


end



function XMBossGameResultItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end


--[[
 {"n":"\u5F6D\u6587\u5BB9","s":100,"r":[],"id":"20100419"}
]]
function XMBossGameResultItem:SetData(data, type)

    self.data = data;

    if self.data == nil then
        self:SetActive(false);
    else

        self.xmNametxt.text = data.n;

        self.valuetxt.text = GetNumStrW(data.v);

        local r = data.r;
        local t_num = table.getn(r);
        --[[
        if t_num > 0 then

            if r[1].spId == 4 then
                -- exp
                self.awardtxt1.text = "" .. r[1].am;
                self.awardtxt2.text = "" .. r[2].am;

            elseif r[1].spId == 1 then
                -- my
                self.awardtxt2.text = "" .. r[1].am;
                self.awardtxt1.text = "" .. r[2].am;
            end


            self.awardIcon1.gameObject:SetActive(true);
            self.awardIcon2.gameObject:SetActive(true);

            self.awardtxt1.gameObject:SetActive(true);
            self.awardtxt2.gameObject:SetActive(true);

        else
            self.awardIcon1.gameObject:SetActive(false);
            self.awardIcon2.gameObject:SetActive(false);

          --  self.awardtxt1.gameObject:SetActive(false);
          --  self.awardtxt2.gameObject:SetActive(false);

        end
        ]]

        local rank = data.id;
        if rank <= 3 then
            self.nicon.spriteName = "no" .. rank;
            self.ntxt.gameObject:SetActive(false);
        else
            self.ntxt.text = "" .. rank;
            self.nicon.gameObject:SetActive(false);
        end



        self:SetActive(true);
    end



end


function XMBossGameResultItem:_Dispose()
    self.gameObject = nil;

    

    self.nicon =  nil;
    self.awardIcon1 =  nil;
    self.awardIcon2 =  nil;

    self.ntxt =  nil;
    self.xmNametxt = nil;
    self.valuetxt =  nil;
   -- self.awardtxt1 =  nil;
  --  self.awardtxt2 =  nil;

end