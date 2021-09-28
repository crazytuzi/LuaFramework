-- 家族排位元件
FamilyItem = BaseClass(LuaUI)
function FamilyItem:__init(root)
	self.URL = "ui://j7ibmhype9ze27";
	self:Layout(root)
	self:InitEvent()
	self:SetBtnClick()
end

function FamilyItem:Layout(root)
	self.ui = UIPackage.CreateObject("Family","FamilyItem");
	root:AddChild(self.ui)
	self.title = self.ui:GetChild("title")
	self.headIcon = self.ui:GetChild("headIcon")
	self.name = self.ui:GetChild("name")
	self.chenghao = self.ui:GetChild("chenghao")
	self.btnPen = self.ui:GetChild("btnPen")
	self.btnDown = self.ui:GetChild("btnDown")
	self.btnUp = self.ui:GetChild("btnUp")
end

function FamilyItem:InitEvent()
	self.model = FamilyModel:GetInstance()
end

-- 设置item显示
function FamilyItem:Update( player, index, max )
	self.title.text = numToCN(player.familySortId)
	self.headIcon.icon = "Icon/Head/r1"..player.career 
	self.headIcon.title = player.level
	self.name.text = player.playerName
	self.chenghao.touchable  = false
	if index == 1 then
		self.chenghao.text = "族长"
	elseif index == 2 then
		self.chenghao.text = "长老"
	elseif index == 3 then
		self.chenghao.text = "掌事"
	else
		self.chenghao.text = "族人"
	end
	self.btnUp.grayed = not (index > 2)
	self.btnUp.touchable = index > 2
	self.btnUp.visible = index > 1
	self.btnDown.grayed = not (index > 1 and index < max)
	self.btnDown.touchable = index > 1 and index < max
	self.btnDown.visible = index > 1
end

-- 点击事件
function FamilyItem:SetBtnClick()

	self.btnUp.onClick:Add(function ( e )
		local index = e.sender.data
		self.model:SetSortMembers( index, index-1 )
	end)

	self.btnDown.onClick:Add(function ( e )
		local index = e.sender.data
		self.model:SetSortMembers( index, index+1 )
	end)
end

function FamilyItem.Create(ui, ...)
	return FamilyItem.New(ui, "#", {...})
end

function FamilyItem:__delete()
	self.model = nil
end