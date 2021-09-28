-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_kick_member = i3k_class("wnd_kick_member",ui.wnd_base)

function wnd_kick_member:ctor()
	self.item_id = nil
end

function wnd_kick_member:configure()
	local widgets = self._layout.vars
	
	self._rootView = widgets.rootView
	self._scroll = widgets.scroll
end

function wnd_kick_member:refresh(viewPos)
	self:updateScroll(viewPos)
end

function wnd_kick_member:updateScroll(viewPos)
	local hero = i3k_game_get_player_hero()
	local memberIdx, members = hero:GetMulMemberInfo()
	
	local memeberInfo = {}
	for i, e in pairs(memberIdx) do
		local data = members[e]
		if e ~= 0 and members[e] then
			local info = { id = members[e].overview.id, name = members[e].overview.name,}
			table.insert(memeberInfo, info)
		end
	end
	
	local size = self._rootView:getContentSize()
	local height = 0
	self._scroll:removeAllChildren()
	for i = 1, #memeberInfo do
		local root = require("ui/widgets/zqtrt")()
		local info = memeberInfo[i]
		root.vars.roleName:setText(info.name)
		root.vars.btn:onClick(self, self.kickMember, info.id)
		
		self._scroll:addItem(root)
		height = height + root.rootVar:getSizeInScroll(self._scroll).height
	end
	self._rootView:setContentSize(size.width, height+15)
	self._scroll:setContentSize(size.width, height+15)
	self._scroll:setContainerSize(size.width, height+15)
	self._scroll:update()
	local child = self._scroll:getChildAtIndex(1)
	if child then
		local pos = child.rootVar:getPositionInScroll(self._scroll)
		self._rootView:setAnchorPoint(0.8, pos.y/(height-28))
		self._rootView:setPosition(viewPos)
	end
end

function wnd_kick_member:kickMember(senderm, roleID)
	i3k_sbean.mulhorse_kick_requst(roleID)
end

function wnd_create(layout)
	local wnd = wnd_kick_member.new()
	wnd:create(layout)
	return wnd
end
