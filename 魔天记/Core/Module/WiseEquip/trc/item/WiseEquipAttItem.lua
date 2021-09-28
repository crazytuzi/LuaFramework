local WiseEquipAttItem = class("WiseEquipAttItem")

WiseEquipAttItem.TYPE_FOR_LEFT = 1;
WiseEquipAttItem.TYPE_FOR_RIGHT = 2;

WiseEquipAttItem.MESSAGE_WISEEQUIPATTITEM_SELECT_CHANGE = "MESSAGE_WISEEQUIPATTITEM_SELECT_CHANGE";

function WiseEquipAttItem:New()
    self = { };
    setmetatable(self, { __index = WiseEquipAttItem });

    return self;
end


function WiseEquipAttItem:Init(transform, parent, type)

    self.transform = transform;
    self.myparent = parent;
    self.type = type;

    self.cb = UIUtil.GetChildByName(self.transform, "UIToggle", "cb");
    self.cb_mark = UIUtil.GetChildByName(self.cb, "UISprite", "Background");

    self.none = UIUtil.GetChildByName(self.transform, "Transform", "none");


    self.txt_att = UIUtil.GetChildByName(self.transform, "UILabel", "txt_att");
    self.txt_condition_dec = UIUtil.GetChildByName(self.transform, "UILabel", "txt_condition_dec");

    self._onClickBtn_cb = function(go) self:_OnClickBtn_cb(self) end
    UIUtil.GetComponent(self.cb, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_cb);
    self.select = false;


end

function WiseEquipAttItem:SetSelect(v)
    self.select = v;

    if self.cb.value ~= v then
        self.cb.value = v
    end

end

function WiseEquipAttItem:SetCBSetActive(v)
    if self.is_open then
        self.cb_mark.gameObject:SetActive(v);
    end

end



function WiseEquipAttItem:_OnClickBtn_cb()

    if self.myparent.currSelectTg == self then
        return;
    end

    self:UpSelfSelect()
end

function WiseEquipAttItem:UpSelfSelect()
    if self.myparent.currSelectTg ~= nil then
        self.myparent.currSelectTg:SetSelect(false);
    end

    self.myparent.currSelectTg = self;
    self.myparent.currSelectTg:SetSelect(true);

    MessageManager.Dispatch(WiseEquipAttItem, WiseEquipAttItem.MESSAGE_WISEEQUIPATTITEM_SELECT_CHANGE, self);
end

function WiseEquipAttItem:SetData(info, index)

    self.cf = EquipDataManager.GetFairy_groove_pos(index);
    self.index = index;
    self.info = info;
    self.att = nil;
    if self.info ~= nil then

        local isopen = self.info:IsOpenFairyGroove(index);
        if isopen then
            -- 槽为可以 开启
            self.att = self.info:GetFairyGroove(index);
            self:SetOpen()


            if self.att ~= nil then
                -- 已经有属性
                self.txt_att.text = "[" .. self.att.color .. "]" .. self.att.att_name .. "[-] +" .. self.att.att_value;
                self.none.gameObject:SetActive(false);
                if self.type == WiseEquipAttItem.TYPE_FOR_RIGHT then
                    
                    self:SetCbEnbel(true);
                end

            else
                -- 还没有属性
                self.txt_att.text = "";
                self.none.gameObject:SetActive(true);

                if self.type == WiseEquipAttItem.TYPE_FOR_RIGHT then
                     self:SetCbEnbel(false);
                end


            end

        else
            self:SetUnOpen(self.cf.rec_fighting)
        end

        if self.select then
            self:UpSelfSelect()
        end

    else
        self:SetUnOpen(self.cf.rec_fighting)
    end


end

function WiseEquipAttItem:SetOpen()

    self.cb_mark.gameObject:SetActive(true);
    self.txt_att.gameObject:SetActive(true);
    self.none.gameObject:SetActive(true);

    if self.type == WiseEquipAttItem.TYPE_FOR_RIGHT then
         self:SetCbEnbel(false);
    end

    self.txt_condition_dec.gameObject:SetActive(false);
    self.is_open = true;
end

function WiseEquipAttItem:SetCbEnbel(v)

  SetUIEnable(self.cb.transform, v);
end

function WiseEquipAttItem:SetUnOpen(condition_dec)

    self.cb_mark.gameObject:SetActive(false);
    self.txt_att.gameObject:SetActive(false);
    self.none.gameObject:SetActive(false);

    if self.type == WiseEquipAttItem.TYPE_FOR_RIGHT then
        self:SetCbEnbel(true);
    end

    self.txt_condition_dec.gameObject:SetActive(true);
    self.txt_condition_dec.text = condition_dec;
    self.is_open = false;
end


function WiseEquipAttItem:Dispose()

    UIUtil.GetComponent(self.cb, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_cb = nil;

    self.transform = nil;


end


return WiseEquipAttItem;

