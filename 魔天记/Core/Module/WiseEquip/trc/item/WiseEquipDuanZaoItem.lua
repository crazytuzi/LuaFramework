
local WiseEquipDuanZaoItem = class("WiseEquipDuanZaoItem")

local sort = table.sort

function WiseEquipDuanZaoItem:New()
    self = { };
    setmetatable(self, { __index = WiseEquipDuanZaoItem });

    return self;
end


function WiseEquipDuanZaoItem:Init(transform)

    self.transform = transform;

    self.curr_att = UIUtil.GetChildByName(self.transform, "Transform", "curr_att");
    self.next_att = UIUtil.GetChildByName(self.transform, "Transform", "next_att");



    self.curr_att_txt_name = UIUtil.GetChildByName(self.curr_att, "UILabel", "txt_name");
    self.curr_att_txt_att = UIUtil.GetChildByName(self.curr_att, "UILabel", "txt_att");
    self.curr_att_txt_att_add = UIUtil.GetChildByName(self.curr_att, "UILabel", "txt_att_add");

    self.curr_att_icon = UIUtil.GetChildByName(self.curr_att, "UISprite", "icon");

    -- self.next_att_txt_name = UIUtil.GetChildByName(self.next_att, "UILabel", "txt_name");
    self.next_att_txt_att = UIUtil.GetChildByName(self.next_att, "UILabel", "txt_att");

    self.expSlider = UIUtil.GetChildByName(self.transform, "Transform", "expSlider");
    self.sliderconten = UIUtil.GetChildByName(self.expSlider, "UISprite", "sliderconten");
    self.expTotalTxt = UIUtil.GetChildByName(self.expSlider, "UILabel", "expTotalTxt");

    self.txt_full_lv_tip = UIUtil.GetChildByName(self.transform, "UILabel", "txt_full_lv_tip");
    self.txt_full_lv_tip.gameObject:SetActive(false);

    self.needPro_num = 3;
    self.needPros = { };
    self.proTips={};

    for i = 1, self.needPro_num do
        local obj = UIUtil.GetChildByName(self.transform, "Transform", "needPro" .. i);
        self.needPros[i] = ProductCtrl:New();
        self.needPros[i]:Init(obj, { hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, false);
        self.needPros[i]:SetOnClickBtnHandler(ProductCtrl.TYPE_NONE);
        self.needPros[i]:SetOnClickCallBack(WiseEquipDuanZaoItem.ProClick, self);
        self.needPros[i]:SetOnPressCallBack(WiseEquipDuanZaoItem.ProOnPress, self);

         self.proTips[i]=UIUtil.GetChildByName(obj, "UISprite", "tip");
         self.proTips[i].gameObject:SetActive(false);
    end

    self._timer = Timer.New( function() self:_OnTickHandler(false) end, 0.1, -1, false);
    self._timer:Start()
    self._timer:Pause(true)
    self.startSetNumTime = 5;
    self.canSetNum = false;
end

function WiseEquipDuanZaoItem:_OnTickHandler(isFirst)

    if self.startSetNumTime > 0 then
        self.startSetNumTime = self.startSetNumTime - 1;
        if self.startSetNumTime == 0 then
            self.canSetNum = true;
        end

    elseif self.canSetNum then

        if self.totalNum > 0 then
            self.d_num = self.d_num + 1;
            self.totalNum = self.totalNum - 1;
            self:UpAm(self.d_tg, self.totalNum)
        end

    end


end

function WiseEquipDuanZaoItem:ProClick(info)

    if self.ismaxLev then
        return;
    end

    if self.eqInfo ~= nil then
        self.dinfo = info;
        local spid = self.dinfo:GetSpId();
        log(" spid " .. spid);
        self.totalNum = BackpackDataManager.GetProductTotalNumBySpid(spid);
        if self.totalNum > 0 then
            self.d_num = 1;
            self:TryDo();

        else
            --  MsgUtils.ShowTips("WiseEquip/WiseEquipDuanZaoItem/label4");
            ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL, { id = spid })
        end
    else
      --  http://192.168.0.8:3000/issues/9945
         MsgUtils.ShowTips("WiseEquip/WiseEquipDuanZaoItem/label3");
       -- local spid = info:GetSpId();
       -- ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL, { id = spid })
    end

end

function WiseEquipDuanZaoItem:ProOnPress(isPress, info, tg)

    if self.ismaxLev then
        return;
    end

    if self.eqInfo ~= nil then
        self.dinfo = info;
        self.d_tg = tg;

        if isPress then
            self.startSetNumTime = 10;
            self.canSetNum = false;
            self.d_num = 0;
            self.totalNum = BackpackDataManager.GetProductTotalNumBySpid(self.dinfo:GetSpId());
            self._timer:Pause(false);
        else
            self._timer:Pause(true)
            self.startSetNumTime = 10;
            self.canSetNum = false;
            self:TryDo();
        end

    end




end

-- 尝试锻造
function WiseEquipDuanZaoItem:TryDo()

    local index = 0;
    local spid = self.dinfo:GetSpId();

    if self.kind == EquipDataManager.KIND_XIANBING then
        index = EquipDataManager.ExtEquipIdx.Idx1;
    elseif self.kind == EquipDataManager.KIND_XUANBING then
        index = EquipDataManager.ExtEquipIdx.Idx2;
    end

    -- log("----------WiseEquipDuanZaoItem:TryDo------------ " .. self.d_num .. "  self.att_key " .. self.att_key .. " index " .. index .. " spid " .. spid);
    if self.d_num > 0 then
        WiseEquipPanelProxy.TryWiseEquip_duanzao(index, self.att_key, spid, self.d_num)
    end


end


--[[
仙纹 1                                                        生命 :(product_attr.mag_def + fairy_forging.att_value)   -> (下一级属性)(product_attr.mag_def + fairy_forging.att_value) 对应属性- 上一级属性
仙纹 10（对应等级找下一个base_attribute_per 不为0的等级显示）     生命 :(product_attr.mag_def + fairy_forging.att_value（取10级的值）)*base_attribute_per           base_attribute_per



进度 1->2 需要的经验， 比如 a/30
]] 

--  att_key 属性字段
--  att_lv 属性当前等级 （没有等级为0）
--  att_exp 当前属性经验
function WiseEquipDuanZaoItem:SetData(kind, eqInfo, att_key, att_lv, att_exp)

    self.kind = kind;
    self.eqInfo = eqInfo;
    self.att_key = att_key;

    local att_lv = 0;
    local att_exp = 0;

    local dz_att = nil;
    local basAttList = nil;
    local dz_att_next = nil;
    if eqInfo ~= nil then

        local att = EquipLvDataManager.GetWiseEqAtt(att_key, kind);
        if att ~= nil then
            att_lv = att.lev;
            att_exp = att.exp;
        end



        dz_att = EquipDataManager.GetWiseEquip_forging(kind, att_key, att_lv);
        basAttList = eqInfo:GetPropertyAndDes();

        dz_att_next = EquipDataManager.GetWiseEquip_forging(kind, att_key, att_lv + 1);

        if dz_att.exp == 0 then
            self.sliderconten.transform.localScale = Vector3.New(1, 1, 1);
        else
            self.sliderconten.transform.localScale = Vector3.New(att_exp / dz_att.exp, 1, 1);
        end


        self.expTotalTxt.text = att_exp .. "/" .. dz_att.exp;

        if dz_att_next ~= nil then
            self.curr_att_icon.gameObject:SetActive(true);
            self.curr_att_txt_att_add.gameObject:SetActive(true);

        else
            self.curr_att_icon.gameObject:SetActive(false);
            self.curr_att_txt_att_add.gameObject:SetActive(false);
        end


    else


        dz_att = EquipDataManager.GetWiseEquip_forging(kind, att_key, att_lv);
        local temAtt = { };
        temAtt[att_key] = 0;
        local res = ProductAttrInfo:New();
        res:Init(temAtt);
        basAttList = res:GetAllPropertyAndDes();
        self.curr_att_icon.gameObject:SetActive(false);
        self.curr_att_txt_att_add.gameObject:SetActive(false);
        self.sliderconten.transform.localScale = Vector3.New(0.001, 1, 1);
        self.expTotalTxt.text = "";
    end


    local baseAtt = self:GetAtt(att_key, basAttList);



    if baseAtt == nil then
        if eqInfo ~= nil then
            Error(" not found att_key in product_attr.lua  key: " .. att_key .. " product id " .. eqInfo:GetSpId());
        else
            Error(" not found att_key in product_attr.lua  key: " .. att_key);
        end
    else

        local att_value = dz_att.att_value;
        local base_attribute_per = dz_att.base_attribute_per;
        local base_attribute_in = dz_att.base_attribute_in;
        local consume_item = dz_att.consume_item;
        -- 353002,353003,353004
        local lev_exp = dz_att.exp;

        self.curr_att_txt_name.text = LanguageMgr.Get("WiseEquip/WiseEquipDuanZaoItem/label1") .. dz_att.lev;

        local curr_att = math.floor((att_value + baseAtt.property) *(1 + base_attribute_per * 0.01));


        if dz_att_next ~= nil then
            local next_att = math.floor((dz_att_next.att_value + baseAtt.property) *(1 + dz_att_next.base_attribute_per * 0.01));

            self.curr_att_txt_att.text = baseAtt.des .. "+" .. curr_att;
            self.curr_att_txt_att_add.text = "+" ..(next_att - curr_att);

        else
            self.curr_att_txt_att.text = baseAtt.des .. "+" .. curr_att;

        end

        local extAtt = EquipDataManager.GetWiseEquip_forging(kind, att_key, base_attribute_in);
        -- self.next_att_txt_name.text = LanguageMgr.Get("WiseEquip/WiseEquipDuanZaoItem/label1") .. extAtt.lev;
        -- self.next_att_txt_att.text = LanguageMgr.Get("WiseEquip/WiseEquipDuanZaoItem/label2",{a= extAtt.lev,b=extAtt.base_attribute_per,c=}) .. baseAtt.des .. "+" .. extAtt.base_attribute_per .. baseAtt.des ;

        self.next_att_txt_att.text = extAtt.add_des;
        ------------------------
        local t_num = table.getn(consume_item);


        for i = 1, self.needPro_num do
           self.proTips[i].gameObject:SetActive(false);
            if i <= t_num then
                local spid = consume_item[i];

                if spid ~= nil and spid ~= 0 and spid ~= "0" then
                    local info = ProductManager.GetProductInfoById(consume_item[i], 1)
                    self.needPros[i]:SetData(info);

                    totalNum = BackpackDataManager.GetProductTotalNumBySpid(spid);
                    self:UpAm(self.needPros[i], totalNum)
                    if totalNum > 0 then
                     self.proTips[i].gameObject:SetActive(true);
                    end

                else
                    self.needPros[i]:SetData(nil);
                end

            else
                self.needPros[i]:SetData(nil);
            end
        end

        if t_num == 1 then
            self.ismaxLev = true;
            self.txt_full_lv_tip.gameObject:SetActive(true);
            self.expSlider.gameObject:SetActive(false);
            self:SetneedProsActive(false);
        else
            self.ismaxLev = false;
            self.txt_full_lv_tip.gameObject:SetActive(false);
            self.expSlider.gameObject:SetActive(true);
            self:SetneedProsActive(true);
        end

    end

end

function WiseEquipDuanZaoItem:SetneedProsActive(v)
    for i = 1, self.needPro_num do
        self.needPros[i]:SetActive(v);
    end
end

function WiseEquipDuanZaoItem:UpAm(tg, totalNum)
    local str = "";

    if totalNum > 0 then
        str = "[9cff94]" .. totalNum .. "[-]"
    else
        str = "[ff0000]0[-]"
    end

    tg:UpAm(str)
end

function WiseEquipDuanZaoItem:GetAtt(att_key, attList)

    for key, value in pairs(attList) do
        if value.key == att_key then
            return value;
        end
    end
    return nil;
end


function WiseEquipDuanZaoItem:Show()
    self.transform.gameObject:SetActive(true);
end

function WiseEquipDuanZaoItem:Hide()
    self.transform.gameObject:SetActive(false);
end

function WiseEquipDuanZaoItem:Dispose()

    for i = 1, self.needPro_num do
        self.needPros[i]:Dispose();
    end

    if (self._timer ~= nil) then
        self._timer:Stop();
        self._timer = nil
    end


    self.transform = nil;

end


return WiseEquipDuanZaoItem;

