local CEditorArgBoxBase = class("CEditorArgBoxBase", CBox)

function CEditorArgBoxBase.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_DragObjCompnent = self:GetComponent(classtype.UIDragObject)
	self.m_Key = nil
	self.m_ContextCmdDataFunc = nil
	self.m_EditHideObj = obj
end

function CEditorArgBoxBase.SetEditHideObj(self, obj)
	self.m_EditHideObj = obj
end

function CEditorArgBoxBase.SetContextCmdDataFunc(self, func)
	self.m_ContextCmdDataFunc = func
end

function CEditorArgBoxBase.GetContextCmdData(self)
	if self.m_ContextCmdDataFunc then
		return self.m_ContextCmdDataFunc()
	end
end

function CEditorArgBoxBase.SetArgInfo(self, dInfo)

end

function CEditorArgBoxBase.GetArgData(self)

end

function CEditorArgBoxBase.SetKey(self, k)
	self.m_Key = k
end

function CEditorArgBoxBase.GetKey(self)
	return self.m_Key
end

function CEditorArgBoxBase.SetValue(self, v, bInput)

end

function CEditorArgBoxBase.ResetDefault()

end

return CEditorArgBoxBase