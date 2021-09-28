require "Core.Module.Common.UIComponent"
require "Core.Module.MainUI.View.Item.AchievementItem"
require "Core.Module.MainUI.View.Item.AchievementDetailItem"

MyAchievementPanel = class("MyAchievementPanel", UIComponent)

function MyAchievementPanel:New()
    self = { };
    setmetatable(self, { __index = MyAchievementPanel });
    return self;
end  


function MyAchievementPanel:_Init()
    self._txtAchievementExecution = UIUtil.GetChildByName(self._transform, "UILabel", "txtAchievementCount")
    self._phalanx1Info = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollView1/phalanx1")
    self._phalanx2Info = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollView2/phalanx2")
    self._phalanx1 = Phalanx:New()
    self._phalanx1:Init(self._phalanx1Info, AchievementItem)
    self._scrollView = UIUtil.GetChildByName(self._transform, "UIScrollView", "scrollView2")
    self._isInit = true
    self._phalanx2 = Phalanx:New()
    self._phalanx2:Init(self._phalanx2Info, AchievementDetailItem)
    self._toggle = UIUtil.GetChildByName(self._transform, "UIToggle", "toggle")
    self._onToggle = function(go) self:_OnToggle() end
    UIUtil.GetComponent(self._toggle, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onToggle);
    self._onlyShowFinish = false
    self._toggle.value = self._onlyShowFinish
    self._currentSelectIndex = 1
end
 
function MyAchievementPanel:UpdatePanel()
    self.data = AchievementManager.GetAchievementData()
    self._phalanx1:Build(table.getCount(self.data), 1, self.data)
    self:UpdateAchievementSelect(self._currentSelectIndex)
    self._txtAchievementExecution.text = AchievementManager.GetAllFinishAchievementCount() .. "/" .. AchievementManager.GetAllAchievementCount()
end
function MyAchievementPanel:ResetPosition()
    self._scrollView:ResetPosition()
end
function MyAchievementPanel:UpdateAchievementSelect(index)
    self._currentSelectIndex = index
    self._phalanx1:GetItem(self._currentSelectIndex).itemLogic:SetToggleEnable(true)
    local tempData = AchievementManager.GetAchievementDataByCondition(self._onlyShowFinish, self.data[self._currentSelectIndex].datas)
     
    self._phalanx2:Build(table.getCount(tempData), 1, tempData)
end

function MyAchievementPanel:_OnToggle()
    self._onlyShowFinish = self._toggle.value
    self:UpdateAchievementSelect(self._currentSelectIndex)
    self:ResetPosition()
end

function MyAchievementPanel:_Dispose()
    if (self._phalanx1) then
        self._phalanx1:Dispose()
        self._phalanx1 = nil
    end

    if (self._phalanx2) then
        self._phalanx2:Dispose()
        self._phalanx2 = nil
    end

    UIUtil.GetComponent(self._toggle, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onToggle = nil
    self._scrollView = nil

end