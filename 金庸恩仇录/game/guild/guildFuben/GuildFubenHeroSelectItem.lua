local GuildFubenHeroSelectItem = class("GuildFubenHeroSelectItem", function()
  return CCTableViewCell:new()
end)
function GuildFubenHeroSelectItem:getContentSize()
  return CCSizeMake(114, 140)
end
function GuildFubenHeroSelectItem:create(param)
  local _itemData = param.itemData
  local _viewSize = param.viewSize
  self._icon = require("game.Icon.IconObj").new({
    id = _itemData.resId
  })
  self._icon:setPosition(self:getContentSize().width / 2, _viewSize.height / 2 + 5)
  self:addChild(self._icon)
  self:refresh(param)
  return self
end
function GuildFubenHeroSelectItem:refresh(param)
  local _itemData = param.itemData
  self._icon:refresh({
    id = _itemData.resId,
    level = _itemData.level,
    cls = _itemData.cls
  })
end
return GuildFubenHeroSelectItem
