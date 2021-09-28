require "Core.Module.Common.UIComponent"

BuffItem = class("BuffItem", UIComponent)
 
function BuffItem:New(transform, buff)
    self = { };
    setmetatable(self, { __index = BuffItem });
    if (transform) then
        self.transform = transform;
        self:Init(transform);
        self:SetBuff(buff);
        self._gameObject:SetActive(true);
    end
    return self;
end 

function BuffItem:SetEnable(enable)
    local pt = self.transform.localPosition;
    if (enable) then
        pt.y = 0;
    else
        pt.y = 1000;
    end
    Util.SetLocalPos(self.transform, pt);
end

function BuffItem:SetBuff(buff)
    self.buff = buff
    self._overlap = -1;
    if (buff) then
        self._imgIcon.spriteName = buff.info.icon_id;
    end
    self:SetEnable(buff ~= nil);
end

function BuffItem:_Init()
    self._imgCool = UIUtil.GetChildByName(self._transform, "UISprite", "imgCool");
    self._imgIcon = UIUtil.GetChildByName(self._transform, "UISprite", "imgIcon");
    self._txtNum = UIUtil.GetChildByName(self._transform, "UILabel", "txtNum");
end

function BuffItem:_Dispose()
    self._imgCool = nil
    self._imgIcon = nil;
    self._txtNum = nil
    self.buff = nil;
end

function BuffItem:Update()
    local buff = self.buff;
    if (buff) then
        self._imgCool.fillAmount = 1 - buff.curCoolTime / buff.totalTime;
        if (self._overlap ~= buff.overlap) then
            self._overlap = buff.overlap;
            if (self._overlap > 1) then
                self._txtNum.text = self._overlap
            else
                self._txtNum.text = ""
            end
        end
    end
end