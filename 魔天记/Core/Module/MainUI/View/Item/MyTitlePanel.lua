require "Core.Module.Common.UIComponent"
require "Core.Module.MainUI.View.Item.TitleDesItem"
require "Core.Module.MainUI.View.Item.TitleDetailItem"

MyTitlePanel = class("MyTitlePanel", UIComponent)

function MyTitlePanel:New()
    self = { };
    setmetatable(self, { __index = MyTitlePanel });
    return self;
end  


function MyTitlePanel:_Init()
    self._txtTitleCount = UIUtil.GetChildByName(self._transform, "UILabel", "txtTitleCount")
    self._txtCurTitle = UIUtil.GetChildByName(self._transform, "UILabel", "txtCurTitle")
    self._phalanx1Info = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollView1/phalanx1")
    self._phalanx2Info = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollView2/phalanx2")
    self._phalanx1 = Phalanx:New()
    self._phalanx1:Init(self._phalanx1Info, TitleDesItem)
    self._scrollView = UIUtil.GetChildByName(self._transform, "UIScrollView", "scrollView2")
    self._isInit = true
    self._phalanx2 = Phalanx:New()
    self._phalanx2:Init(self._phalanx2Info, TitleDetailItem)
    self._toggle = UIUtil.GetChildByName(self._transform, "UIToggle", "toggle")
    self._onToggle = function(go) self:_OnToggle() end
    UIUtil.GetComponent(self._toggle, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onToggle);
    self._btnTitleProperty = UIUtil.GetChildByName(self._transform, "UIButton", "btnTitleProperty")
    self._onClickBtnTitle = function(go) self:_OnClickBtnTitle() end
    UIUtil.GetComponent(self._btnTitleProperty, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTitle);
    self._onlyShowGet = false
    self._toggle.value = self._onlyShowGet
    self._currentSelectIndex = 1
end

function MyTitlePanel:_OnClickBtnTitle()
    ModuleManager.SendNotification(MainUINotes.OPEN_TITLEATTRPANEL)
end
 
function MyTitlePanel:UpdatePanel(index)
    self.data = TitleManager.GetTitleData()
    self._phalanx1:Build(table.getCount(self.data), 1, self.data)
    self._txtTitleCount.text = TitleManager.GetFinishTitleCount() .. "/" .. TitleManager.GetAllTitleCount()
    local curTitleData = TitleManager.GetCurrentEquipTitleData()
    if (index) then
        self._currentSelectIndex = index
    end
    self._txtCurTitle.text = curTitleData and curTitleData.name or ""
    self:UpdateTitleSelect(self._currentSelectIndex)
end

function MyTitlePanel:ResetPosition()
    self._scrollView:ResetPosition()
end

function MyTitlePanel:UpdateTitleSelect(index)
    self._currentSelectIndex = index
    self._phalanx1:GetItem(self._currentSelectIndex).itemLogic:SetToggleEnable(true)
    local datas = TitleManager.GetDataByCondition(self._onlyShowGet, self.data[self._currentSelectIndex].datas)
    self._phalanx2:Build(table.getCount(datas), 1, datas)
end

function MyTitlePanel:_OnToggle()
    self._onlyShowGet = self._toggle.value
    self:UpdateTitleSelect(self._currentSelectIndex)
    self:ResetPosition()
end

function MyTitlePanel:_Dispose()
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
    UIUtil.GetComponent(self._btnTitleProperty, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTitle = nil
end