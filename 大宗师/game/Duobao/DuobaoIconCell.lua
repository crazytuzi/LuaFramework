--[[
 --
 -- add by vicky
 -- 2014.08.13
 --
 --]]

local DuobaoIconCell = class("DuobaoIconCell", function()
    display.addSpriteFramesWithFile("ui/ui_icon_frame.plist", "ui/ui_icon_frame.png")
    return CCTableViewCell:new()
end)


function DuobaoIconCell:getContentSize()

    return CCSizeMake(105, 105)
end


function DuobaoIconCell:updateItem(param)
	self._id = param.id
	ResMgr.refreshIcon({itemBg = self._itemIcon, id = self._id, resType = ResMgr.getResType(self._type)})
end


function DuobaoIconCell:create(param)
	-- dump(param)
	self._id = param.id
    self._type = param.type

    local viewSize = param.viewSize
    self._itemIcon = ResMgr.getIconSprite({id = self._id, resType = ResMgr.getResType(self._type)})
    self:addChild(self._itemIcon)
    self._itemIcon:setPosition(self._itemIcon:getContentSize().width / 2, viewSize.height / 2)

    return self
end


function DuobaoIconCell:refresh(param)
	self:updateItem(param)
end


function DuobaoIconCell:selected()
    -- dump("选中：" .. self:getIdx())
end



return DuobaoIconCell