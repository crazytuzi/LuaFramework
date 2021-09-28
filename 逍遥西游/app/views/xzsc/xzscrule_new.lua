g_XZSCRuleDlg = nil
CXZSCRule = class("CXZSCRule", CcsSubView)
function CXZSCRule:ctor()
  CXZSCRule.super.ctor(self, "views/xzscrule.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  if g_XZSCRuleDlg ~= nil then
    g_XZSCRuleDlg:CloseSelf()
  end
  g_XZSCRuleDlg = self
end
function CXZSCRule:Btn_Close(obj, t)
  self:CloseSelf()
end
function CXZSCRule:Clear()
  if g_XZSCRuleDlg == self then
    g_XZSCRuleDlg = nil
  end
end
CXZSCRule_Award = class("CXZSCRule_Award", CcsSubView)
function CXZSCRule_Award:ctor(myStarNum)
  CXZSCRule_Award.super.ctor(self, "views/xzscrule_award.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  if g_XZSCRuleDlg ~= nil then
    g_XZSCRuleDlg:CloseSelf()
  end
  g_XZSCRuleDlg = self
  myStarNum = myStarNum or 0
  self.list_content = self:getNode("list_content")
  local listSize = self.list_content:getContentSize()
  local _sortDataFunc = function(a, b)
    if a == nil or b == nil then
      if a ~= nil then
        return true
      elseif b ~= nil then
        return false
      else
        return false
      end
    end
    return a[1] < b[1]
  end
  local dataList = {}
  for k, v in pairs(data_XueZhanShaChangStarAward) do
    if v.Honour ~= "" and v.Coin ~= "" then
      dataList[#dataList + 1] = {k, v}
    end
  end
  table.sort(dataList, _sortDataFunc)
  for index = 1, #dataList - 1 do
    local v = dataList[index]
    local score = v[1]
    local data = v[2]
    local v_next = dataList[index + 1]
    local score_next = v_next[1]
    local containFlag = false
    local scoreTxt = string.format("%.2d-%.2d星", score, score_next - 1)
    if myStarNum >= score and myStarNum < score_next - 1 then
      containFlag = true
    end
    if index >= #dataList - 1 then
      scoreTxt = string.format("%d星以上", score)
      if myStarNum >= score then
        containFlag = true
      end
    end
    local hourTxt = string.gsub(data.Honour, "Star", "星数")
    hourTxt = string.format("%s点#<IR6>#", hourTxt)
    local coinTxt = string.gsub(data.Coin, "Star", "星数")
    local tmp = string.find(coinTxt, "+")
    if tmp ~= nil then
      local tmpTxt = string.sub(coinTxt, tmp + 1)
      local tmpNumber = tonumber(tmpTxt)
      if tmpNumber ~= nil and tmpNumber > 10000 then
        coinTxt = string.format("%s%d万", string.sub(coinTxt, 1, tmp), math.floor(tmpNumber / 10000))
      end
    end
    coinTxt = string.format("%s#<IR1>#", coinTxt)
    local itemTxt = ""
    for k, v in pairs(data.Item) do
      local itemName = data_getItemName(k)
      itemTxt = string.format("%s%sx%d ", itemTxt, itemName, v)
    end
    local desc = string.format("%s: %s, %s, %s", scoreTxt, hourTxt, coinTxt, itemTxt)
    local txtColor = ccc3(255, 255, 255)
    if containFlag then
      txtColor = ccc3(255, 255, 0)
    end
    local descObj = CRichText.new({
      width = listSize.width,
      fontSize = 20,
      color = txtColor
    })
    descObj:addRichText(desc)
    self.list_content:pushBackCustomItem(descObj)
  end
  local emptyLine = CRichText.new({
    width = listSize.width,
    fontSize = 26,
    color = ccc3(255, 196, 98),
    align = CRichText_AlignType_Center
  })
  emptyLine:newLine()
  self.list_content:pushBackCustomItem(emptyLine)
  local titleObj = CRichText.new({
    width = listSize.width,
    fontSize = 26,
    color = ccc3(255, 196, 98),
    align = CRichText_AlignType_Center
  })
  titleObj:addRichText("规则说明")
  titleObj:newLine()
  self.list_content:pushBackCustomItem(titleObj)
  local ruleDesc = {
    "1、战胜越强大的对手获得的结算奖励越好。",
    "2、战胜越多的对手获得的结算奖励越好。",
    "3、战败之后结算奖励不会减少。",
    "4、排名前五的玩家将会获得量身订造的特殊称谓。",
    "5、结算奖励将会在活动结束后统一发放。"
  }
  for _, desc in pairs(ruleDesc) do
    local descObj = CRichText.new({
      width = listSize.width,
      fontSize = 20,
      color = ccc3(255, 255, 255)
    })
    descObj:addRichText(desc)
    self.list_content:pushBackCustomItem(descObj)
  end
end
function CXZSCRule_Award:Btn_Close(obj, t)
  self:CloseSelf()
end
function CXZSCRule_Award:Clear()
  if g_XZSCRuleDlg == self then
    g_XZSCRuleDlg = nil
  end
end
