--小贵族特权Item
VipSmallPrivilegeItem = VipSmallPrivilegeItem or class("VipSmallPrivilegeItem",BaseCloneItem)

function VipSmallPrivilegeItem:ctor(obj,parent_node)

    self.data = nil
   
    self:Load()
end

function VipSmallPrivilegeItem:dctor()

end

function VipSmallPrivilegeItem:LoadCallBack(  )
   
    self.nodes = {
      "txt_desc"
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()

end

function VipSmallPrivilegeItem:InitUI(  )
    self.txt_desc = GetText(self.txt_desc)
end

function VipSmallPrivilegeItem:AddEvent(  )
    
end

--data
--desc  buff描述文字
function VipSmallPrivilegeItem:SetData(data)
    self.data = data

    self:UpdateView()
end

function VipSmallPrivilegeItem:UpdateView()

    self:UpdateDesc()
end

--刷新buff描述
function VipSmallPrivilegeItem:UpdateDesc(  )
    self.txt_desc.text = self.data.desc
end