FactionEscortHelpItem = FactionEscortHelpItem or class("FactionEscortHelpItem",BaseCloneItem)

function FactionEscortHelpItem:ctor(obj,parent_node,layer)
    FactionEscortHelpItem.super.Load(self)
    self.model = FactionEscortModel:GetInstance()

end
function FactionEscortHelpItem:dctor()

end

function FactionEscortHelpItem:LoadCallBack()
    self.nodes =
    {
        "helpBtn","name","power","level","vip","Image",
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self.name = GetText(self.name)
    self.power = GetText(self.power)
    self.level = GetText(self.level)
    self.vip = GetText(self.vip)
    self.Image = GetImage(self.Image)
    self:AddEvent()
    --self:SetTileTextImage("combine_image", "Combine_title")

end

function FactionEscortHelpItem:AddEvent()

    function call_back()
        Notify.ShowText("Seek for Help")
        GlobalEvent:Brocast(FactionEscortEvent.FactionEscortClickHelpBtn,self)
    end
    
    AddClickEvent(self.helpBtn.gameObject,call_back)
end

function FactionEscortHelpItem:SetData(data)
    self.data = data
    self:SetInfo()
end

function FactionEscortHelpItem:SetInfo()
    local role = self.data.base
    self.name.text = role.name
    self.power.text = role.power
    self.level.text = role.level
    self.vip.text = role.viplv
    if role.gender == 1 then
        lua_resMgr:SetImageTexture(self,self.Image, 'main_image', 'img_role_head_1',true)
    else
        lua_resMgr:SetImageTexture(self,self.Image, 'main_image', 'img_role_head_2',true)
    end
end

