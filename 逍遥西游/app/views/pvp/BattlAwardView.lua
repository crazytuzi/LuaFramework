CBattallAwardView = class("CBattallAwardView", CcsSubView)
function CBattallAwardView:ctor(param)
  local myCurRanking = param.ranking
  CBattallAwardView.super.ctor(self, "views/battl_rank.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = true
  })
  self:setMyRankAndAward(myCurRanking)
end
function CBattallAwardView:setMyRankAndAward(curRanking)
  local coinAward = 0
  local honourAward = 0
  local pos = {}
  for k, v in pairs(data_ArenaRankAward) do
    pos[#pos + 1] = k
  end
  table.sort(pos)
  for k, val in ipairs(pos) do
    if curRanking < val then
      local key = pos[k - 1]
      coinAward = data_ArenaRankAward[key].Coin
      honourAward = data_ArenaRankAward[key].Honour
      break
    end
  end
  local myRanking = self:getNode("rank_txt")
  local Rx, Ry = myRanking:getPosition()
  local rank_des = string.format("排名%d的奖励:", curRanking)
  myRanking:setText(rank_des)
  local tip_txt = self:getNode("tip_txt")
  local x, y = tip_txt:getPosition()
  local descSize = tip_txt:getContentSize()
  local temText = string.format([[
%d#<IR1>#

%d#<IR6>#]], coinAward, honourAward)
  local color = ccc3(255, 255, 255)
  if curRanking > BattlAward_LowestRanking then
    temText = "至少要6000名以内才能获得奖励，请加油哟！"
    color = ccc3(255, 254, 149)
  end
  local tempDesc_coinAward = CRichText.new({
    width = descSize.width,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 24,
    color = color
  })
  tempDesc_coinAward:setAnchorPoint(ccp(0, 0))
  tip_txt:addChild(tempDesc_coinAward)
  tempDesc_coinAward:setPosition(ccp(x - 15, y - descSize.height))
  tempDesc_coinAward:addRichText(temText)
end
function CBattallAwardView:Clear()
end
