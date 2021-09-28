-- Filename: STTableViewCell.lua
-- Author: bzx
-- Date: 2015-05-06
-- Purpose: 

STTableViewCell = class("STTableViewCell", function ( ... )
	return STNode:create()
end)

function STTableViewCell:ctor()
	STNode.ctor(self)
end

function STTableViewCell:create( ... )
	local ret = STTableViewCell.new()
	return ret
end