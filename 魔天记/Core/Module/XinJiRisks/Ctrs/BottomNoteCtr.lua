
local BottomNoteCtr = class("BottomNoteCtr")


function BottomNoteCtr:New(transform)
    self = { };
    setmetatable(self, { __index = BottomNoteCtr });
    self:Init(transform)
    return self;
end

function BottomNoteCtr:Init(transform)
    self.transform = transform;
    local txts = UIUtil.GetComponentsInChildren(self.transform, "UILabel");

    self._txt_playNumTip = UIUtil.GetChildInComponents(txts, "txt_playNumTip");
    self._txt_btTip = UIUtil.GetChildInComponents(txts, "txt_btTip");

end

function BottomNoteCtr:Dispose()

    self.transform = nil;
    self._txt_playNumTip = nil;
    self._txt_btTip = nil;

end


return BottomNoteCtr;