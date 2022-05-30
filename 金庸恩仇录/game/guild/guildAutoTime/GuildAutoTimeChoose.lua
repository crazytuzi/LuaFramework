local data_error_error = require("data.data_error_error")
local GuildAutoTimeChoose = class("GuildAutoTimeChoose", function()
  return require("utility.ShadeLayer").new()
end)
function GuildAutoTimeChoose:ctor(param)
  dump(param)
  self.shopType = param.shopType or ARENA_SHOP_TYPE
  local title = param.title
  local havenum = param.had
  local remainnum = param.limitNum
  local listener = param.listener
  local ismin = param.ismin
  local proxy = CCBProxy:create()
  local rootnode = {}
  local node = CCBuilderReaderLoad("guild/guild_AT_ChooseTime.ccbi", proxy, rootnode)
  node:setPosition(display.width / 2, display.height / 2)
  self:addChild(node)
  local function onClose()
    self:removeFromParentAndCleanup(true)
  end
  ResMgr.setControlBtnEvent(rootnode.cancelBtn, function()
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    onClose()
  end)
  ResMgr.setControlBtnEvent(rootnode.closeBtn, function()
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    onClose()
  end)
  local nameColor = ccc3(255, 243, 0)
  local nameLbl = ui.newTTFLabelWithShadow({
    text = title,
    size = 24,
    color = nameColor,
    shadowColor = FONT_COLOR.BLACK,
    font = FONTS_NAME.font_haibao,
    align = ui.TEXT_ALIGN_CENTER
  })
  nameLbl:setPosition(0, 0)
  rootnode.haveLabel:removeAllChildren()
  rootnode.haveLabel:addChild(nameLbl)
  local num = havenum
  rootnode.exchangeCountLabel:setString(tostring(num))
  local function onNumBtn(event, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    local tag = sender:getTag()
    if 1 == tag then
      if num == remainnum then
        if ismin and ismin == true then
          show_tip_label(data_error_error[2900103].prompt)
        else
          show_tip_label(data_error_error[2900102].prompt)
        end
        return
      end
      num = math.min(num + 1, remainnum)
    elseif 2 == tag then
      if num == remainnum then
        if ismin and ismin == true then
          show_tip_label(data_error_error[2900103].prompt)
        else
          show_tip_label(data_error_error[2900102].prompt)
        end
        return
      end
      num = math.min(num + 10, remainnum)
    elseif 3 == tag then
      num = math.max(num - 1, 0)
    elseif 4 == tag then
      num = math.max(num - 10, 0)
    end
    local tmp = num
    if num < 10 then
      tmp = "0" .. num
    end
    rootnode.exchangeCountLabel:setString(tmp)
  end
  rootnode.add10Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
  rootnode.add1Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
  rootnode.reduce10Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
  rootnode.reduce1Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
  if ismin and ismin == true then
    rootnode.add1Btn:setVisible(false)
    rootnode.reduce1Btn:setVisible(false)
    rootnode.add10Btn:setPosition(200, 25)
    rootnode.reduce10Btn:setPosition(-100, 25)
  else
    rootnode.add1Btn:setVisible(true)
    rootnode.reduce1Btn:setVisible(true)
  end
  ResMgr.setControlBtnEvent(rootnode.confirmBtn, function()
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    listener(num)
    onClose()
  end)
end
return GuildAutoTimeChoose
