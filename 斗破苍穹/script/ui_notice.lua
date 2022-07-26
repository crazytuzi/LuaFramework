UINotice = {
	preViewThing = {}
}
local textItem = {}
local curShowText = nil

local function getTextWidth()
  return textItem[1]:getContentSize().width + textItem[2]:getContentSize().width + textItem[3]:getContentSize().width
end

local function setTextPosition()
  local ui_panel = ccui.Helper:seekNodeByName(UINotice.Widget,"panel")
  textItem[1]:setPosition(cc.p(ui_panel:getContentSize().width,ui_panel:getContentSize().height/2))
  textItem[2]:setPosition(cc.p(ui_panel:getContentSize().width + textItem[1]:getContentSize().width,ui_panel:getContentSize().height/2))
  textItem[3]:setPosition(cc.p(ui_panel:getContentSize().width + textItem[1]:getContentSize().width + textItem[2]:getContentSize().width,ui_panel:getContentSize().height/2))
end

local function setTextItemColor(label_l)
  if label_l == "%[" then 
    textItem[2]:setTextColor(cc.c4b(255,165,0,255))
  end
end

local function isClearItem()
	if #UINotice.preViewThing >= 1 then 
    	if UINotice.preViewThing[1][1] == curShowText then 
    		table.remove(UINotice.preViewThing,1)
    		if #UINotice.preViewThing == 0 then
    			textItem[1]:setString("")
          textItem[2]:setString("")
          textItem[3]:setString("")
    			return true
    		else 
          return false
        end
    	else 
        return false
      end
  else 
  	return true
  end
end

local function setItemView()
	if UINotice.preViewThing[1] then
      curShowText = UINotice.preViewThing[1][1]
      local str = {}
      local label_l = nil
      local label_r = nil
      if string.find(UINotice.preViewThing[1][1], "%[") then 
        label_l = "%["
        label_r = "%]"
      end
      if label_l and label_r then 
        local text = utils.stringSplit(UINotice.preViewThing[1][1], label_l)
        str[1] = text[1]
        str[2] = utils.stringSplit(text[2], label_r)[1]
        str[3] = utils.stringSplit(text[2], label_r)[2]
      else 
        str[1] = UINotice.preViewThing[1][1]
      end
     	textItem[1]:setString(str[1])
      if str[2] then 
        textItem[2]:setString("  [" .. str[2] .. "]  ")
        setTextItemColor(label_l)
      else 
        textItem[2]:setString("")
      end
      if str[3] then 
        textItem[3]:setString(str[3])
      else 
        textItem[3]:setString("")
      end
     	if UINotice.preViewThing[1][2] then 
     		local color = utils.stringSplit(UINotice.preViewThing[1][2], ",")
     		textItem[1]:setTextColor(cc.c4b(tonumber(color[1]),tonumber(color[2]),tonumber(color[3]),255))
        textItem[3]:setTextColor(cc.c4b(tonumber(color[1]),tonumber(color[2]),tonumber(color[3]),255))
     	end
    end
end

local function itemAction()
  textItem[1]:stopAllActions()
  textItem[2]:stopAllActions()
  textItem[3]:stopAllActions()
  textItem[1]:setString("")
  textItem[2]:setString("")
  textItem[3]:setString("")
  local ui_panel = ccui.Helper:seekNodeByName(UINotice.Widget,"panel")
  local time = 0
  if not isClearItem() then 
    setItemView()
    time = 5*(ui_panel:getContentSize().width + getTextWidth())/ui_panel:getContentSize().width 
  else 
    curShowText = nil
  end
  setTextPosition()
  local movedWidth  = -ui_panel:getContentSize().width- getTextWidth()
  textItem[1]:runAction(cc.Sequence:create(cc.MoveBy:create(time, cc.p(movedWidth,0)),cc.CallFunc:create(itemAction)))
  textItem[2]:runAction(cc.MoveBy:create(time, cc.p(movedWidth,0)))
  textItem[3]:runAction(cc.MoveBy:create(time, cc.p(movedWidth,0)))
end

function UINotice.init()
	local ui_panel = ccui.Helper:seekNodeByName(UINotice.Widget,"panel")
	textItem[1] = ccui.Text:create()
	textItem[1]:setAnchorPoint(cc.p(0, 0.5))
	textItem[1]:setFontSize(20)
	textItem[1]:setFontName(dp.FONT)
	ui_panel:addChild(textItem[1])
  textItem[2] = ccui.Text:create()
  textItem[2]:setAnchorPoint(cc.p(0, 0.5))
  textItem[2]:setFontSize(20)
  textItem[2]:setFontName(dp.FONT)
  ui_panel:addChild(textItem[2])
  textItem[3] = ccui.Text:create()
  textItem[3]:setAnchorPoint(cc.p(0, 0.5))
  textItem[3]:setFontSize(20)
  textItem[3]:setFontName(dp.FONT)
  ui_panel:addChild(textItem[3])
  itemAction()
end

