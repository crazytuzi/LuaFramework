require "Core.Module.Common.UIItem"

SaoDangInfoItem = class("SaoDangInfoItem", UIItem)
 

function SaoDangInfoItem:New()
    self = { };
    setmetatable(self, { __index = SaoDangInfoItem });
    return self
end


function SaoDangInfoItem:UpdateItem(data)
    if (data) then
        self.data = data
        self:SetData(self.data)
    end

end

function SaoDangInfoItem:_Init()


    self.title_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "title_txt");

    self.exp_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "exp_txt");
    self.linshi_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "linshi_txt");

    self.expLabel = UIUtil.GetChildByName(self.gameObject, "UILabel", "expLabel");
    self.linshiLabel = UIUtil.GetChildByName(self.gameObject, "UILabel", "linshiLabel");

    self._onPro_txt1 = function(go) self:_OnPro_txt1(self) end
    self._onPro_txt2 = function(go) self:_OnPro_txt2(self) end
    self._onPro_txt3 = function(go) self:_OnPro_txt3(self) end
    self._onPro_txt4 = function(go) self:_OnPro_txt4(self) end
    self._onPro_txt5 = function(go) self:_OnPro_txt5(self) end
    self._onPro_txt6 = function(go) self:_OnPro_txt6(self) end
    self._onPro_txt7 = function(go) self:_OnPro_txt7(self) end
    self._onPro_txt8 = function(go) self:_OnPro_txt8(self) end

    for i = 1, 8 do
        self["pro_txt" .. i] = UIUtil.GetChildByName(self.gameObject, "UILabel", "pro_txt" .. i);
        UIUtil.GetComponent(self["pro_txt" .. i], "LuaUIEventListener"):RegisterDelegate("OnClick", self["_onPro_txt" .. i]);
    end

    self:UpdateItem(self.data);


    self:SetActive(false);
end

function SaoDangInfoItem:SetActive(v)
    self.active = v;
    self.gameObject.gameObject:SetActive(v);
end

function SaoDangInfoItem:_OnPro_txt1() self:_OnPro_txtClicl(1) end
function SaoDangInfoItem:_OnPro_txt2() self:_OnPro_txtClicl(2) end
function SaoDangInfoItem:_OnPro_txt3() self:_OnPro_txtClicl(3) end
function SaoDangInfoItem:_OnPro_txt4() self:_OnPro_txtClicl(4) end
function SaoDangInfoItem:_OnPro_txt5() self:_OnPro_txtClicl(5) end
function SaoDangInfoItem:_OnPro_txt6() self:_OnPro_txtClicl(6) end
function SaoDangInfoItem:_OnPro_txt7() self:_OnPro_txtClicl(7) end
function SaoDangInfoItem:_OnPro_txt8() self:_OnPro_txtClicl(8) end

function SaoDangInfoItem:_OnPro_txtClicl(index)



    local info = self["pro_txt_info" .. index];

    ModuleManager.SendNotification(ProductTipNotes.SHOW_BY_PRODUCT, { info = info, type = ProductCtrl.TYPE_FROM_OTHER });

end


function SaoDangInfoItem:SetTotalPro(list)

    local res = { };

    local t_num = table.getn(list);
    for i = 1, t_num do
        local obj = list[i];
        if res[obj.spId] == nil then
            res[obj.spId] = { num = obj.num, spId = obj.spId };
        else
            res[obj.spId].num = res[obj.spId].num + obj.num;
        end

    end

    local rlist = { };
    local rlistIndex = 1;

    for key, value in pairs(res) do
        rlist[rlistIndex] = value;
        rlistIndex = rlistIndex + 1;
    end


    return rlist;
end


-- {"items":[{"num":20000,"spId":4},{"num":1000,"spId":1},{"num":1,"spId":301001}],"instId":"750001"}
function SaoDangInfoItem:SetData(d)


    local fb_cf = InstanceDataManager.GetMapCfById(d.instId);

    if fb_cf.kind == InstanceDataManager.kind_1 then
        self.title_txt.text = fb_cf.name .. LanguageMgr.Get("InstancePanel/SaoDangInfoItem/label1");
    elseif fb_cf.kind == InstanceDataManager.kind_2 then
        self.title_txt.text = fb_cf.name .. LanguageMgr.Get("InstancePanel/SaoDangInfoItem/label2");
    elseif fb_cf.kind == InstanceDataManager.kind_3 then
        self.title_txt.text = fb_cf.name .. LanguageMgr.Get("InstancePanel/SaoDangInfoItem/label3");
    end

    local txtIndex = 1;
    self.ct_h = 0;

    local items = self:SetTotalPro(d.items);

    for key, value in pairs(items) do
        local spId = tonumber(value.spId);
        local cf = ProductManager.GetProductById(spId);


        if spId == SpecialProductId.Exp then
            self.exp_txt.text = "" .. value.num;
            self.expLabel.text = cf.name .. "：";

            self.ct_h = -92;
        elseif spId == SpecialProductId.Money then
            self.linshi_txt.text = "" .. value.num;
            self.linshiLabel.text = cf.name .. "：";
            self.ct_h = -92;
        else

            local info = ProductManager.GetProductInfoById(value.spId, value.num);
            local quality = info:GetQuality();

            self["pro_txt" .. txtIndex].text = ColorDataManager.GetColorTextByQuality(quality, info:GetName()) .. " X " .. info:GetAm();
            self["pro_txt" .. txtIndex].gameObject:SetActive(true);
            self["pro_txt_info" .. txtIndex] = info;

            --  self.ct_h = self["pro_txt" .. txtIndex].transform.localPosition.y - 30;

            if txtIndex == 1 or txtIndex == 2 then
                self.ct_h = -92 - 30;
            elseif txtIndex == 3 or txtIndex == 4 then
                self.ct_h = -118 - 30;
            elseif txtIndex == 5 or txtIndex == 6 then
                self.ct_h = -143 - 30;
            elseif txtIndex == 7 or txtIndex == 8 then
                self.ct_h = -166 - 30;
            end

            txtIndex = txtIndex + 1;
        end

    end

    -- log("---- self.ct_h  "..self.ct_h);

end


function SaoDangInfoItem:SetY(y)
    Util.SetLocalPos(self.gameObject, -205, y, 0)

    --    self.gameObject.transform.localPosition = Vector3.New(-205, y, 0);
end
 
function SaoDangInfoItem:_Dispose()

    for i = 1, 8 do
        UIUtil.GetComponent(self["pro_txt" .. i], "LuaUIEventListener"):RemoveDelegate("OnClick");
        self["_onPro_txt" .. i] = nil;
        self["pro_txt" .. i] = nil;
    end


    self.title_txt = nil;

    self.exp_txt = nil;
    self.linshi_txt = nil;



end

