local CPopupList = class("CPopupList", CWidget)

function CPopupList.ctor(self, obj)
	CWidget.ctor(self, obj)
	self.m_UIPopupList = self:GetComponent(classtype.UIPopupList)
end

function CPopupList.AddItem(self, text)
    if text == nil or text == "" then 
        return
    end 
    self.m_UIPopupList:AddItem(text)
end

function CPopupList.GetValue(self)
    return self.m_UIPopupList.value
end

function CPopupList.Clear(self)
    self.m_UIPopupList:Clear()
end



return CPopupList
