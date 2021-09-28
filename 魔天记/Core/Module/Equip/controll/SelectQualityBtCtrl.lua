


SelectQualityBtCtrl = { };

function SelectQualityBtCtrl:New()
    local o = { };
    setmetatable(o, { __index = self });
    return o;
end

function SelectQualityBtCtrl:Init(gameObject, index)

    self.gameObject = gameObject
    self._selectIcon = UIUtil.GetChildByName(self.gameObject, "Transform", "selectIcon");
    self.index = index;
    self:Selected(false);

end

function SelectQualityBtCtrl:SetOnClickBtnHandler(handler, hd_tg)

    self._selectHandler = handler;
    self._selectHandlerTg = hd_tg;
    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);
end

function SelectQualityBtCtrl:Selected(v)
    self.isSelect = v;
    self._selectIcon.gameObject:SetActive(v);
end



function SelectQualityBtCtrl:_OnClickBtn()

    if self._selectHandler ~= nil then
        if self._selectHandlerTg ~= nil then
            self._selectHandler(self._selectHandlerTg, self);
        else
            self._selectHandler(self);
        end

    end

end

function SelectQualityBtCtrl:Dispose()

    if self._onClickBtn ~= nil then

        UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
        self._onClickBtn = nil;

    end

    self.gameObject = nil;
    self._selectIcon = nil;
    self.index = nil;


end


