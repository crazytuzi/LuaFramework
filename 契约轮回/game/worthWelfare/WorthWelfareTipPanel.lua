--超值福利提示界面
WorthWelfareTipPanel = WorthWelfareTipPanel or class("WorthWelfareTipPanel",BasePanel)

function WorthWelfareTipPanel:ctor()
    self.abName = "WorthWelfare"
    self.assetName = "WorthWelfareTipPanel"
    self.layer = "UI"

    --self.panel_type = 2
    --self.is_hide_other_panel = true

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI

   
end

function WorthWelfareTipPanel:dctor()

    
end

function WorthWelfareTipPanel:LoadCallBack(  )
    self.nodes = {
        "btn_close",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end

end

function WorthWelfareTipPanel:InitUI(  )
   
end

function WorthWelfareTipPanel:AddEvent(  )

    --关闭按钮
    local function callback(  )
        self:Close()
    end
    AddClickEvent(self.btn_close.gameObject,callback)

    
end

--data
function WorthWelfareTipPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function WorthWelfareTipPanel:UpdateView()
    self.need_update_view = false
end