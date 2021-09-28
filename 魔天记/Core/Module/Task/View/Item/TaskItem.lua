require "Core.Module.Common.UIItem"

TaskItem = UIItem:New();
 
function TaskItem:_Init()
    local txts = UIUtil.GetComponentsInChildren(self.transform, "UILabel");
    self._txtTaskName = UIUtil.GetChildInComponents(txts, "txtTaskName");
    self._txtTaskType = UIUtil.GetChildInComponents(txts, "txtTaskType");
    self._txtTaskStatus = UIUtil.GetChildInComponents(txts, "txtTaskStatus");

    self._imgTaskIco = UIUtil.GetChildByName(self.transform, "UISprite", "imgTaskIco");
    self._imgHighLight = UIUtil.GetChildByName(self.transform, "UISprite", "imgHighLight");
    self._imgHighLight.gameObject:SetActive(false);

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

    self:UpdateItem(self.data);
end

function TaskItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;
end

function TaskItem:UpdateItem(data)
    self.data = data;
    local config = data:GetConfig();
    if data.type == TaskConst.Type.REWARD then
        self._txtTaskName.text = LanguageMgr.GetColor(config.quality, config.name);
    else
        self._txtTaskName.text = LanguageMgr.GetColor("d", config.name);
    end
    
    self._txtTaskStatus.text = LanguageMgr.Get("task/st/ti/"..data.status);
    self._imgTaskIco.spriteName = data.type;
end

function TaskItem:_OnClickBtn()
    MessageManager.Dispatch(TaskItem, TaskNotes.TASK_ITEM_SELECTED, self.data);
end

function TaskItem:UpdateSelected(val)
    self._imgHighLight.gameObject:SetActive(self.data and val);
end
