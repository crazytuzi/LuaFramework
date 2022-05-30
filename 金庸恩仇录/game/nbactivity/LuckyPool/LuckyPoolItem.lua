local LuckyPoolItem = class("LuckyPoolItem", function()
  return display.newNode()
end)
function LuckyPoolItem:ctor(param)
  local proxy = CCBProxy:create()
  self._rootnode = {}
  local node = CCBuilderReaderLoad("nbhuodong/lucky_pool_item.ccbi", proxy, self._rootnode)
  local contentSize = self._rootnode.reward:getContentSize()
  node:setPosition(contentSize.width * 0.5 + 7.5, contentSize.height * 0.5)
  self:addChild(node)
  self:refreshItem(param)
  self._cntSize = CCSizeMake(contentSize.width + 15, contentSize.height)
end
function LuckyPoolItem:getContentSize()
  return self._cntSize
end
function LuckyPoolItem:changeBox(isVisible)
  self._rootnode.luckypool_item_effect:setVisible(isVisible)
end
function LuckyPoolItem:refreshItem(param)
  local itemData = ResMgr.getRefreshIconItem(param.itemData.id, param.itemData.type)
  itemData.num = param.itemData.num or 0
  local rewardIcon = self._rootnode.reward_icon
  rewardIcon:removeAllChildrenWithCleanup(true)
  ResMgr.refreshIcon({
    id = itemData.id,
    resType = itemData.iconType,
    itemBg = rewardIcon,
    iconNum = itemData.num,
    itemType = itemData.type,
    isShowIconNum = false,
    numLblSize = 22,
    numLblColor = ccc3(0, 255, 0),
    numLblOutColor = ccc3(0, 0, 0)
  })
  local canhunIcon = self._rootnode.reward_canhun
  local suipianIcon = self._rootnode.reward_suipian
  canhunIcon:setVisible(false)
  suipianIcon:setVisible(false)
  local nameKey = "reward_name"
  local nameColor = ResMgr.getItemNameColorByType(itemData.id, itemData.iconType)
  local nameLbl = ui.newTTFLabelWithShadow({
    text = itemData.name,
    size = 20,
    color = nameColor,
    shadowColor = ccc3(0, 0, 0),
    font = FONTS_NAME.font_fzcy,
    align = ui.TEXT_ALIGN_LEFT
  })
  nameLbl:setPosition(-nameLbl:getContentSize().width / 2, nameLbl:getContentSize().height / 2)
  self._rootnode[nameKey]:removeAllChildren()
  self._rootnode[nameKey]:addChild(nameLbl)
end
return LuckyPoolItem
