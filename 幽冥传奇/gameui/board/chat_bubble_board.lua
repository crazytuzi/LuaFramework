ChatBubbleBoard = ChatBubbleBoard or BaseClass()
ChatBubbleBoard.FIX_WIDTH = 200

function ChatBubbleBoard:__init()
	self.root_node = cc.Node:create()
	self.root_node:setAnchorPoint(0,0)
	self.bg = XUI.CreateImageViewScale9(0,0,ChatBubbleBoard.FIX_WIDTH,100,ResPath.GetCommon("chat_bubble"),true,cc.rect(5,5,10,10))
	self.bg:setAnchorPoint(0,0)
	self.root_node:addChild(self.bg)
	self.bg_desc = XUI.CreateImageView(5,4,ResPath.GetCommon("chat_bubble_desc"),true)
	self.bg_desc:setAnchorPoint(0,1)
	self.root_node:addChild(self.bg_desc)
	self.name_text_rich = XUI.CreateRichText(ChatBubbleBoard.FIX_WIDTH * 0.5, 0, ChatBubbleBoard.FIX_WIDTH - 20, 22)
	self.root_node:addChild(self.name_text_rich)
end	

function ChatBubbleBoard:__delete()
	self.root_node = nil
	self.name_text_rich = nil
end

function ChatBubbleBoard:GetRootNode()
	return self.root_node
end	

function ChatBubbleBoard:SetSayContent(content)
	RichTextUtil.ParseRichText(self.name_text_rich,content)
	self.name_text_rich:refreshView() -- 马上刷新
	local size = self.name_text_rich:getInnerContainerSize()

	self.name_text_rich:setPosition(self.name_text_rich:getPositionX(),size.height)
	self.bg:setContentSize(cc.size(ChatBubbleBoard.FIX_WIDTH,size.height + 20))
end	

function ChatBubbleBoard:SetVisible(is_visible)
	self.root_node:setVisible(is_visible)
end
