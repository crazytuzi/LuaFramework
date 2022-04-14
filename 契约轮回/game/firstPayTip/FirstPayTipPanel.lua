--首充提示界面
FirstPayTipPanel = FirstPayTipPanel or class("FirstPayTipPanel",BasePanel)

function FirstPayTipPanel:ctor()
    self.abName = "FirstPayTip"
    self.assetName = "FirstPayTipPanel"
    self.layer = "UI"

    self.panel_type = 4
    self.is_hide_other_panel = true

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
end

function FirstPayTipPanel:dctor()
   

end

function FirstPayTipPanel:LoadCallBack(  )
    self.nodes = {
        "btn_close","txt_time","btn_go",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()

    if self.need_update_view then
       self:UpdateView()
    end

   
end

function FirstPayTipPanel:InitUI(  )
    self.txt_time = GetText(self.txt_time)
end

function FirstPayTipPanel:AddEvent(  )

    --关闭界面
    local function callback(  )
        self:Close()
    end
    AddClickEvent(self.btn_close.gameObject,callback)

    --立即前往
    local function callback(  )
        self:Close()
        GlobalEvent:Brocast(FirstPayEvent.OpenFirstPayPanel)
    end
    AddClickEvent(self.btn_go.gameObject,callback)
end

--data
--time 剩余时间
function FirstPayTipPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function FirstPayTipPanel:UpdateView()
    self.need_update_view = false

    self:UpdateTime()
end

--刷新剩余时间
function FirstPayTipPanel:UpdateTime(  )
    self.txt_time.text = self.data.time
end