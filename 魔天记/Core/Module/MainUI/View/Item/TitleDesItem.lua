require "Core.Module.Common.UIItem"

TitleDesItem = UIItem:New();
function TitleDesItem:_Init()
    self._txtCount = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtCount")
    self._txtName = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtName")
    self:UpdateItem(self.data);
    self._toggle = UIUtil.GetComponent(self.gameObject, "UIToggle")
    self._onItemClick = function(go) self:_OnItemClick() end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onItemClick);
end


function TitleDesItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onItemClick = nil
end 

function TitleDesItem:UpdateItem(data)
    self.data = data
    if self.data then
        self._txtName.text = self.data.name
        local number = 0
        for k, v in ipairs(self.data.datas) do
            if (v.state == 1) then
                number = number + 1
            end
        end
        if (number ~= 0) then
            self._txtCount.text = "(" .. number .. ")"
        else
            self._txtCount.text = ""
        end
    end
end

function TitleDesItem:_OnItemClick()
    ModuleManager.SendNotification(MainUINotes.CHANGE_TITLE_INDEX, self.index)
end

function TitleDesItem:SetToggleEnable(enable)
    self._toggle.value = enable
end

