GatherNameBoard = GatherNameBoard or BaseClass(NameBoard)
function GatherNameBoard:__init()
	self.gather_vo = nil

	self.special_name_text_rich = XUI.CreateRichText(0, 24, 200, 24)
	XUI.RichTextSetCenter(self.special_name_text_rich)
	self.root_node:addChild(self.special_name_text_rich)
end

function GatherNameBoard:__delete()
	
end

function GatherNameBoard:SetGather(gather_vo)
	self.gather_vo = gather_vo
	self:Flush()
	self:UpdateSpecialName()
end

function GatherNameBoard:UpdateSpecialName()

end