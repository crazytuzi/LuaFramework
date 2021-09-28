local ScrollBase = require("universal.ScrollBase")
local ScrollContent = class("ScrollContent", ScrollBase)
function ScrollContent:ctor(w, h, direction, cont, contWidth, contHeight, priority)
  ScrollContent.super.ctor(self, w, h, direction, priority)
  self:setView(cont, contWidth, contHeight)
end
function ScrollContent.newVertical(w, h, cont, contWidth, contHeight, priority)
  return ScrollContent.new(w, h, ScrollBase.DIRECTION_VERTICAL, cont, contWidth, contHeight, priority)
end
function ScrollContent.newHorizontal(w, h, cont, contWidth, contHeight, priority)
  return ScrollContent.new(w, h, ScrollBase.DIRECTION_HORIZONTAL, cont, contWidth, contHeight, priority)
end
return ScrollContent
