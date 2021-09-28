require "Core.Module.Common.UIComponent"

MountReSetButton = class("MountReSetButton", UIComponent)
 
function MountReSetButton:New()
    self = { };
    setmetatable(self, { __index = MountReSetButton });
    return self;
end 

function MountReSetButton:_Init()
    self.txtPc = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtPc");
    self.txt_time = UIUtil.GetChildByName(self._gameObject, "UILabel", "txt_time");

    self._imgFrame = UIUtil.GetComponent(self._gameObject, "UISprite");
    self._button = UIUtil.GetComponent(self._gameObject, "UIButton");

    self._onClick = function(go) self:_OnClick(self) end

    UIUtil.GetComponent(self._button, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);

end

function MountReSetButton:SetActive(v)
    self._gameObject:SetActive(v);
end

-- 下载具


function MountReSetButton:AddClickListener(func)
    self._clickCallback = func;
end

function MountReSetButton:SetElseTime(lt)

    self.lmoun_time = lt;

    self:StopTime()

    self:UpTimeStr();

    if self.lmoun_time <= 0 then
      return ;
    end

    self._sec_timer = Timer.New( function()

        self.lmoun_time = self.lmoun_time - 1;
        self:UpTimeStr();

      --  log("  self.lmoun_time  "..self.lmoun_time);

        if self.lmoun_time < 0 then
            self:_OnClick();
            self:StopTime();
        end

    end , 1, self.lmoun_time + 1, false);

    self._sec_timer:Start();

end


function MountReSetButton:UpTimeStr()

    local tstr = GetTimeByStr(self.lmoun_time);
    self.txt_time.text = tstr;

end

function MountReSetButton:_OnClick(go)
    if (self._clickCallback) then
        self._clickCallback();
    end
end

function MountReSetButton:StopTime()
    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end
end

function MountReSetButton:StopAndHide()
 -- self:StopTime();
 -- 隐藏， 但还是需要 计算时间
   self:SetActive(false);
end

function MountReSetButton:_Dispose()

    self:StopTime()

    UIUtil.GetComponent(self._button, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClick = nil;
    self._clickCallback = nil
end
