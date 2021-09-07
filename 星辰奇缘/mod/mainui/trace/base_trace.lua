BaseTracePanel = BaseTracePanel or BaseClass(BasePanel)


function BaseTracePanel:__init(main)
    self.main = main
    self.isInit = false
    self.resList = {
    }
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function BaseTracePanel:__delete()

end
function BaseTracePanel:Init()

end
function BaseTracePanel:OnOpen()

end

function BaseTracePanel:OnHide()

end
