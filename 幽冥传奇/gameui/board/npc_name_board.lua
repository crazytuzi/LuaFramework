NpcNameBoard = NpcNameBoard or BaseClass(NameBoard)


function NpcNameBoard:__init()
	self.type_cell = nil
end

function NpcNameBoard:__delete()
	
end

function NpcNameBoard:SetNpcType(npc_type,offset)
	if self.type_cell == nil then
		self.type_cell = XUI.CreateLayout(0,30 + offset,0,0)
		self.type_cell:setAnchorPoint(0.5,0.5)
		local bg = XUI.CreateImageViewScale9(0,0,150,32,ResPath.GetCommon("img9_187"),true,cc.rect(33,13,10,8))
		self.type_cell:addChild(bg)
		self.root_node:addChild(self.type_cell)

		local text = XUI.CreateText(0,0,0,0,cc.TEXT_ALIGNMENT_LEFT,"",nil,nil,nil,nil)
		text:setString(Language.Npc.NpcTypeName[npc_type] or "检测语言包")
		self.type_cell:addChild(text)
	end	
end	