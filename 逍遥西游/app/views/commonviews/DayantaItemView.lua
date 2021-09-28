g_Click_Item_View = nil
ENTER_DAYANTA_BOSSTAG = 1
DayantaItemView = class("DayantaItemView", CcsSubView)
function DayantaItemView:ctor(params, autoDel, posPara, enterTag)
  DayantaItemView.super.ctor(self, "views/itemdetail.json")
  print("CItemDetailView---create")
  local enterTag = enterTag
  self.m_AutoDel = autoDel
  self.m_Bg = self:getNode("bg")
  local x, y = self:getNode("Desc"):getPosition()
  local descSize = self:getNode("Desc"):getSize()
  local tempDesc = CRichText.new({
    width = descSize.width,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 22,
    color = ccc3(255, 255, 255)
  })
  self.m_Bg:addChild(tempDesc)
  tempDesc:addRichText("可能获得：")
  tempDesc:newLine()
  local itemPreforence = {
    ["普通技能"] = {
      92001,
      92030,
      mtype = 1
    },
    ["高级技能"] = {
      92101,
      92127,
      mtype = 1
    }
  }
  if params ~= nil then
    for k, itemId in pairs(params) do
      local belong = false
      for p_k, p_v in pairs(itemPreforence) do
        if itemId >= p_v[1] and itemId <= p_v[2] then
          if p_v.isset ~= true then
            p_v.isset = true
            local name = data_getItemName(itemId)
            tempDesc:addRichText(string.format("#<CI:%d>%s#", itemId, p_k))
            if k < #params then
              tempDesc:addRichText("、")
            end
          end
          belong = true
          break
        end
      end
      if belong ~= true then
        local name
        if itemId == 80001 then
          name = "初级炼妖石"
        elseif itemId == 81001 then
          name = "中级炼妖石"
        elseif itemId == 82001 then
          name = "高级炼妖石"
        else
          name = data_getItemName(itemId)
        end
        if enterTag == ENTER_DAYANTA_BOSSTAG and (data_getIsXianQiJZ(itemId) or data_getIsGaoJiZBJZ(itemId)) then
          name = string.sub(name, 0, -9)
        end
        if name == nil then
          return
        end
        tempDesc:addRichText(string.format("#<CI:%d>%s#", itemId, name))
        if k < #params then
          tempDesc:addRichText("、")
        end
      end
    end
  else
    return
  end
  local offx = 20
  local offy = 20
  local size = tempDesc:getRealRichTextSize()
  local w = math.max(size.width + offx)
  local h = math.max(size.height + offy)
  self.m_Bg:setSize(CCSize(w, h))
  self.m_UINode:ignoreContentAdaptWithSize(false)
  self.m_UINode:setSize(CCSize(w, h))
  local realDescSize = tempDesc:getContentSize()
  tempDesc:setPosition(ccp(10, y + descSize.height - realDescSize.height + 5))
  local bgSize = self.m_Bg:getSize()
  local w = bgSize.width
  local h = bgSize.height
  self.m_Bg:setPosition(ccp(realDescSize.height / 2 - descSize.height + 10, h - descSize.height + realDescSize.height))
  if self.m_AutoDel == true then
    self:AutoDelSelf()
  end
  tipsviewExtend.extend(self)
  tipssetposExtend.extend(self, posPara)
end
function DayantaItemView:AutoDelSelf()
  if self.m_DelSelfHandler then
    scheduler.unscheduleGlobal(self.m_DelSelfHandler)
  end
  self.m_DelSelfHandler = scheduler.scheduleGlobal(function()
    print("CItemDetailView---removeself")
    self:removeFromParent()
  end, 3)
end
function DayantaItemView:getViewSize()
  return self.m_Bg:getSize()
end
function DayantaItemView:setItemPos()
  self.m_Bg:setPosition(ccp(0, h + realDescSize.height - descSize.height + 2))
end
function DayantaItemView:Clear()
  print("CItemDetailView---del")
  if self.m_DelSelfHandler then
    scheduler.unscheduleGlobal(self.m_DelSelfHandler)
  end
  g_Click_Item_View = nil
end
