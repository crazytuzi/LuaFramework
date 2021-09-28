CSelectHero = class("SelectHero", function()
  return display.newLayer()
end)
function CSelectHero:ctor()
  self.m_LastRaceType = -1
  self.m_LastHeroType = -1
  local raceName = {
    [RACE_REN] = "人族",
    [RACE_MO] = "魔族",
    [RACE_XIAN] = "仙族"
  }
  self.m_RaceItem = {}
  local raceItems = {}
  local num = 3
  for i, raceId in ipairs({
    RACE_REN,
    RACE_MO,
    RACE_XIAN
  }) do
    do
      local race_item = ui.newTTFLabelMenuItem({
        text = raceName[raceId],
        size = 50,
        color = ccc3(255, 255, 255),
        align = ui.TEXT_ALIGN_CENTER,
        listener = function()
          self:Sel_Race(raceId)
        end,
        x = 200,
        y = display.height / 2 - (i - num / 2) * 70 + 25
      })
      raceItems[#raceItems + 1] = race_item
      self.m_RaceItem[raceId] = race_item
    end
  end
  local menu = ui.newMenu(raceItems)
  self:addChild(menu)
  self.m_HeroMenu = nil
  self.m_HeroItem = {}
  self:Sel_Race(RACE_REN)
  local onEdit = function(event, editbox)
    if event == "began" then
    elseif event == "changed" then
    elseif event == "ended" then
    elseif event == "return" then
    end
  end
  print("---->> 11111 1 ")
  local editbox = ui.newEditBox({
    image = "views/pic/pic_bginput.png",
    listener = onEdit,
    size = CCSize(400, 60),
    x = display.cx,
    y = display.height - 60
  })
  editbox:setPlaceHolder("输入名字")
  editbox:setFontColor(ccc3(0, 0, 0))
  editbox:setFontSize(30)
  editbox:setMaxLength(15)
  print("---->> 11111 2 ")
  print("===>>editbox:", editbox)
  self:addChild(editbox)
  self.m_NameInputBox = editbox
  local cancel_item = ui.newTTFLabelMenuItem({
    text = "取消",
    size = 40,
    color = ccc3(180, 180, 180),
    align = ui.TEXT_ALIGN_CENTER,
    listener = handler(self, self.Cancel),
    x = display.width * 9 / 10,
    y = 120
  })
  local craete_item = ui.newTTFLabelMenuItem({
    text = "创建角色",
    size = 40,
    color = ccc3(255, 255, 255),
    align = ui.TEXT_ALIGN_CENTER,
    listener = handler(self, self.Create),
    x = display.width * 9 / 10,
    y = 70
  })
  self:addChild(ui.newMenu({cancel_item, craete_item}))
end
function CSelectHero:Sel_Race(race)
  if self.m_LastRaceType == race then
    return
  end
  print("种族选择了:", race)
  for raceId, item in pairs(self.m_RaceItem) do
    if raceId == race then
      item:getLabel():setColor(ccc3(255, 0, 0))
      item:setScale(1.2)
    else
      item:getLabel():setColor(ccc3(255, 255, 255))
      item:setScale(1)
    end
  end
  self.m_LastRaceType = race
  self:CreateHeroMenu()
end
function CSelectHero:Sel_Hero(heroId)
  if self.m_LastHeroType == heroId then
    return
  end
  print("选择英雄:", heroId)
  for hId, item in pairs(self.m_HeroItem) do
    if hId == heroId then
      item:getLabel():setColor(ccc3(255, 0, 0))
      item:setScale(1.2)
    else
      item:getLabel():setColor(ccc3(255, 255, 255))
      item:setScale(1)
    end
  end
  self.m_LastHeroType = heroId
end
function CSelectHero:CreateHeroMenu()
  self.m_LastHeroType = -1
  if self.m_HeroMenu then
    self:removeChild(self.m_HeroMenu, true)
  end
  self.m_HeroItem = {}
  local heroIds = data_getHeroIdsByRaceNZSheng(self.m_LastRaceType, 0)
  table.sort(heroIds)
  self.m_HeroItem = {}
  local heroItems = {}
  local num = #heroIds
  for i, heroId in ipairs(heroIds) do
    do
      local heroData = data_Hero[heroId]
      local hero_item = ui.newTTFLabelMenuItem({
        text = heroData.des,
        size = 40,
        color = ccc3(255, 255, 255),
        align = ui.TEXT_ALIGN_CENTER,
        listener = function()
          self:Sel_Hero(heroId)
        end,
        x = 500,
        y = display.height / 2 - (i - num / 2) * 60 + 30
      })
      heroItems[#heroItems + 1] = hero_item
      self.m_HeroItem[heroId] = hero_item
    end
  end
  local menu = ui.newMenu(heroItems)
  self:addChild(menu)
  self.m_HeroMenu = menu
  if num > 0 then
    self:Sel_Hero(heroIds[1])
  end
end
function CSelectHero:Cancel()
  ShowLoginView(false)
end
function CSelectHero:Create()
  local name = self.m_NameInputBox:getText()
  if type(name) ~= "string" or string.len(name) < 4 or string.len(name) > 15 then
    device.showAlert("提示", "名字不能大于15个字节,小于4个字节", buttonLabels, listener)
    return
  end
  netsend.login.createHero(self.m_LastHeroType, name)
  self:ShowWaitingView(true)
end
function CSelectHero:ShowAsScene(transitionType, time, more)
  transitionType = transitionType or "fade"
  time = time or 0.2
  more = more or display.COLOR_WHITE
  local scene = CCScene:create()
  self:addTo(scene, self.m_ViewZOrder, self.m_ViewTag)
  display.replaceScene(scene, transitionType, time, more)
  return scene
end
