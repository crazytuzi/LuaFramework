local CEditorWindowBase = class("CEditorWindowBase")

function CEditorWindowBase.ctor(self, window)
	self.m_Window = window
end

--static start--
function CEditorWindowBase.ShowWindow(clsname, window)
	if not g_EditorWindows[clsname] then
		_G[clsname] = reimport("logic.editor.editorgui."..clsname)
		local cls = _G[clsname]
		local oWindow = cls.New(window)
		oWindow:OnShow()
		g_EditorWindows[clsname] = oWindow
	end
	return g_EditorWindows[clsname]
end

function CEditorWindowBase.CloseWindow(clsname)
	local oWindow = g_EditorWindows[clsname]
	oWindow:OnClose()
	g_EditorWindows[clsname] = nil
end

function CEditorWindowBase.WindowGUI(clsname)
	xxpcall(function() 
		local oWindow = g_EditorWindows[clsname]
		oWindow:OnGUI()
	end)
end
--static end--

function CEditorWindowBase.OnGUI(self)

end

function CEditorWindowBase.OnShow(self)
	print("show window->", self.classname)
end

function CEditorWindowBase.OnClose(self)
	print("close window->", self.classname)
	EditorGUITools.ReleaseAll()
end

return CEditorWindowBase