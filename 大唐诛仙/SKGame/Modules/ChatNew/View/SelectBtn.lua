SelectBtn = BaseClass(LuaUI)

SelectBtn.CurSelect = nil
function SelectBtn:__init(...)
	self:RegistUI()
	self:Config()
end

function SelectBtn:SetProperty(...)
	
end

function SelectBtn:Config()
	
end

function SelectBtn:RegistUI()
	self.ui = UIPackage.CreateObject("ChatNew" , "SelectBtn");

	self.graybg = self.ui:GetChild("graybg")
	self.selectbg = self.ui:GetChild("selectbg")
	self.titleText = self.ui:GetChild("titleText")

	self.data = nil

	self.ui.onClick:Add(function(e)
		if SelectBtn.CurSelect then
			SelectBtn.CurSelect:UnSelect()
		end
		self:Select()
	end)

	self:UnSelect()
end

function SelectBtn:Select()
	self.graybg.visible = false
	self.selectbg.visible = true
	SelectBtn.CurSelect = self

	self.root:Refresh(self.data[2])
end

function SelectBtn:UnSelect()
	self.graybg.visible = true
	self.selectbg.visible = false
end

function SelectBtn.Create(ui, ...)
	return SelectBtn.New(ui, "#", {...})
end

function SelectBtn:SetData(data, x, y, root)
	self.data = data
	self.root = root
	self.titleText.text = self.data[1]
	self:AddTo(root.btnItemList, x, y)
end

function SelectBtn:__delete()
end