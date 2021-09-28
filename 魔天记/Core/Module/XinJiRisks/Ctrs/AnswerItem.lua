
local AnswerItem = class("AnswerItem")


function AnswerItem:New(transform, parent)
    self = { };
    setmetatable(self, { __index = AnswerItem });
    self:Init(transform, parent)
    return self;
end

function AnswerItem:Init(transform, parent)
    self.transform = transform;
    self.parent = parent;

    self.zhicihlv = UIUtil.GetChildByName(self.transform, "Transform", "zhicihlv");

    self.selectBg = UIUtil.GetChildByName(self.transform, "UISprite", "selectBg");
    self.sureIcon = UIUtil.GetChildByName(self.transform, "UISprite", "sureIcon");

    self._txt_zhichilv = UIUtil.GetChildByName(self.zhicihlv, "UILabel", "_txt_zhichilv");
    self._txt_answer = UIUtil.GetChildByName(self.transform, "UILabel", "_txt_answer");

    self.zcbg = UIUtil.GetChildByName(self.zhicihlv, "UISprite", "zcbg");

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);
    self.enble = true;
    self.selectBg.gameObject:SetActive(false);
    self.sureIcon.gameObject:SetActive(false);
end

function AnswerItem:SetEnble(v)
    self.enble = v;
end

function AnswerItem:SetAnswer(data, index)
    self._txt_answer.text = data;
    self.index = index;
end

function AnswerItem:SetAr(ar)
    self.ar = ar

end

-- Ö§³ÖÂÊ
function AnswerItem:SetAp(ap)
    self.ap = ap;
    self._txt_zhichilv.text = ap .. "%";
end


function AnswerItem:SetZcbg(v)
    
    if v then
        self.zcbg.spriteName = "8";
    else
        self.zcbg.spriteName = "7";
    end

end

function AnswerItem:UpSt(st, min_ap)

    self.st = st;
    self.sureIcon.gameObject:SetActive(false);
    self.enble = false;
    if self.st == 1 then
        self.zhicihlv.gameObject:SetActive(false);
        self.enble = true;
    elseif self.st == 2 then
        self.zhicihlv.gameObject:SetActive(false);
    elseif self.st == 3 then
        self.zhicihlv.gameObject:SetActive(true);
        self.enble = true;
        if min_ap >= self.ap then
            self:SetZcbg(true);
        end

    elseif self.st == 4 then
        self.zhicihlv.gameObject:SetActive(false);
    elseif self.st == 5 then
        self.zhicihlv.gameObject:SetActive(true);
        self.sureIcon.gameObject:SetActive(self.ar);
    end

end

function AnswerItem:SetMyAnswer(_true)

    self.enble = false;

    if _true then
        self.selectBg.gameObject:SetActive(true);
    else
        self.selectBg.gameObject:SetActive(false);
    end

end


function AnswerItem:_OnClickBtn()
    if self.enble then
        if self.parent.currSelect ~= nil then
            self.parent.currSelect.selectBg.gameObject:SetActive(false);
        end
        self.parent.currSelect = self;
        self.parent.currSelect.selectBg.gameObject:SetActive(true);

        XinJiRisksProxy.Try_XinJiRisksAnswer(self.index)
    end

end

function AnswerItem:Dispose()

    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;


    self.transform = nil;


end


return AnswerItem;