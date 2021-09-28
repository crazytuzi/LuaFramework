local g_Test_RoleObj = {}
local g_ChiBangOff = {}
local label_red, label_green, label_blue
local saveDir = device.writablePath .. "testData/"
local savePath = saveDir .. "data_ChiBangOff.lua"
local savePath_2 = saveDir .. "data_ChiBangOff_2.lua"
os.mkdir(saveDir)
local DirrectConvert = {
  [6] = 4,
  [7] = 3,
  [8] = 2
}
local g_HasTouchMoved = false
local g_TouchBeganPos = ccp(0, 0)
function testChiBang()
  local parentNode = CCScene:create()
  display.replaceScene(parentNode)
  local parentNode_Ui = display.newNode()
  parentNode:addChild(parentNode_Ui, 99)
  local parentNode_Role = display.newNode()
  parentNode:addChild(parentNode_Role, 10)
  local bg = display.newColorLayer(ccc4(180, 180, 180, 255))
  parentNode:addChild(bg, -1)
  bg:setTouchEnabled(true)
  bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    local name, x, y, prevX, prevY = event.name, event.x, event.y, event.prevX, event.prevY
    if name == "began" then
      g_TouchBeganPos = ccp(x, y)
    elseif name == "moved" then
      if not g_HasTouchMoved then
        if math.abs(g_TouchBeganPos.x - x) + math.abs(g_TouchBeganPos.y - y) > 10 then
          g_HasTouchMoved = true
        end
      else
        local dy = y - prevY
        local px, py = parentNode_Role:getPosition()
        parentNode_Role:setPosition(px, py + dy)
      end
    end
    return true
  end)
  local red_add = testChiBang_Btn("views/rolelist/btn_addpro.png", function()
    testChiBang_ColorAdd(1, 0, 0)
  end)
  parentNode_Ui:addChild(red_add, 10)
  red_add:setPosition(150, display.height - 30)
  local red_sub = testChiBang_Btn("views/rolelist/btn_subpro.png", function()
    testChiBang_ColorAdd(-1, 0, 0)
  end)
  parentNode_Ui:addChild(red_sub, 10)
  red_sub:setPosition(50, display.height - 30)
  label_red = ui.newTTFLabel({
    text = "",
    size = 25,
    font = KANG_TTF_FONT,
    color = ccc3(0, 0, 0)
  })
  parentNode_Ui:addChild(label_red, 10)
  label_red:setPosition(100, display.height - 30)
  label_red._value = 0
  local green_add = testChiBang_Btn("views/rolelist/btn_addpro.png", function()
    testChiBang_ColorAdd(0, 1, 0)
  end)
  parentNode_Ui:addChild(green_add, 10)
  green_add:setPosition(350, display.height - 30)
  local greed_sub = testChiBang_Btn("views/rolelist/btn_subpro.png", function()
    testChiBang_ColorAdd(0, -1, 0)
  end)
  parentNode_Ui:addChild(greed_sub, 10)
  greed_sub:setPosition(250, display.height - 30)
  label_green = ui.newTTFLabel({
    text = "0",
    size = 25,
    font = KANG_TTF_FONT,
    color = ccc3(0, 0, 0)
  })
  parentNode_Ui:addChild(label_green, 10)
  label_green:setPosition(300, display.height - 30)
  label_green._value = 0
  local blue_add = testChiBang_Btn("views/rolelist/btn_addpro.png", function()
    testChiBang_ColorAdd(0, 0, 1)
  end)
  parentNode_Ui:addChild(blue_add, 10)
  blue_add:setPosition(550, display.height - 30)
  local blue_sub = testChiBang_Btn("views/rolelist/btn_subpro.png", function()
    testChiBang_ColorAdd(0, 0, -1)
  end)
  parentNode_Ui:addChild(blue_sub, 10)
  blue_sub:setPosition(450, display.height - 30)
  label_blue = ui.newTTFLabel({
    text = "0",
    size = 25,
    font = KANG_TTF_FONT,
    color = ccc3(0, 0, 0)
  })
  parentNode_Ui:addChild(label_blue, 10)
  label_blue:setPosition(500, display.height - 30)
  label_blue._value = 0
  testChiBang_Load()
  for index, testShapeId in ipairs({
    11001,
    11004,
    11006,
    11009,
    12001,
    12002,
    12006,
    12007,
    13001,
    13004,
    13008,
    13009,
    14001,
    14002,
    14003,
    14004
  }) do
    local x = (index - 1) % 4 * 235 + 120
    local y = math.floor((index - 1) / 4) * 220 + 50
    local shapeNode = testChiBang_CreateShape(parentNode_Role, testShapeId, x, y)
    g_Test_RoleObj[testShapeId] = shapeNode
    testChiBang_FlushAni(testShapeId)
  end
  local saveBtn = testChiBang_Btn("views/common/btn/btn_2words.png", function()
    testChiBang_Save()
  end)
  parentNode_Ui:addChild(saveBtn, 10)
  saveBtn:setPosition(display.width - 50, display.height - 30)
  bg:setTouchEnabled(true)
  bg:registerScriptTouchHandler(function(event, tx, ty)
    if event == "began" then
      for testShapeId, shapeNode in pairs(g_Test_RoleObj) do
        local p = shapeNode:convertToNodeSpace(ccp(tx, ty))
        if p.x > -30 and p.x < 30 and p.y > 0 and p.y < 100 then
          local roleObj = shapeNode._role
          if roleObj.__act == "stand" then
            roleObj.__act = "walk"
          else
            roleObj.__act = "stand"
          end
          testChiBang_FlushAni(testShapeId)
          return true
        end
      end
    end
  end)
  testChiBang_ColorAdd(0, 0, 0)
end
function testChiBang_ColorAdd(r, g, b)
  label_red._value = label_red._value + r
  if label_red._value > 255 then
    label_red._value = 0
  end
  if label_red._value < 0 then
    label_red._value = 0
  end
  label_red:setString(tostring(label_red._value))
  label_green._value = label_green._value + g
  if label_green._value > 255 then
    label_green._value = 0
  end
  if label_green._value < 0 then
    label_green._value = 0
  end
  label_green:setString(tostring(label_green._value))
  label_blue._value = label_blue._value + b
  if label_blue._value > 255 then
    label_blue._value = 0
  end
  if label_blue._value < 0 then
    label_blue._value = 0
  end
  label_blue:setString(tostring(label_blue._value))
  for testShapeId, shapeNode in pairs(g_Test_RoleObj) do
    local chiBangAni = shapeNode._chibang
    chiBangAni:setColor(ccc3(label_red._value, label_green._value, label_blue._value))
  end
end
function testChiBang_Save()
  g_ChiBangOff = {}
  local saveStr = "data_ChiBang = {"
  for testShapeId, shapeNode in pairs(g_Test_RoleObj) do
    g_ChiBangOff[testShapeId] = {}
    saveStr = string.format([[
%s
		[%d] = {]], saveStr, testShapeId)
    local d = g_ChiBangOff[testShapeId]
    local roleObj = shapeNode._role
    if roleObj.__dataDict then
      for aniNameKey, pos in pairs(roleObj.__dataDict) do
        d[aniNameKey] = {
          pos.x,
          pos.y
        }
        saveStr = string.format([[
%s
				%s = {%d,%d},]], saveStr, aniNameKey, pos.x, pos.y)
      end
    end
    saveStr = string.format([[
%s
		},]], saveStr)
  end
  saveStr = string.format([[
%s
}]], saveStr)
  print("--------------------> savePath:", savePath)
  io.writefile(savePath, saveStr, "wb")
  ShowNotifyTips("保存成功")
end
function testChiBang_Load()
  g_ChiBangOff = data_ChiBang
end
function testChiBang_CreateShape(parentNode, testShapeId, nx, ny)
  local shapeNode = display.newNode()
  parentNode:addChild(shapeNode)
  shapeNode:setPosition(nx, ny)
  local roleObj, x, y = createBodyByShape(testShapeId)
  shapeNode:addChild(roleObj, 10)
  roleObj:setPosition(x, y)
  local shadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  shapeNode:addChild(shadow, -1)
  roleObj.__dir = 4
  roleObj.__act = "stand"
  local chiBangAni = CChiBang.new(testShapeId, 10001, roleObj)
  local addBtn = testChiBang_Btn("views/common/btn/btn_right.png", function()
    testChiBang_DirAdd(testShapeId)
  end)
  shapeNode:addChild(addBtn)
  addBtn:setPosition(80, 0)
  local subBtn = testChiBang_Btn("views/common/btn/btn_left.png", function()
    testChiBang_DirSub(testShapeId)
  end)
  shapeNode:addChild(subBtn)
  subBtn:setPosition(-80, 0)
  local offBtn = testChiBang_Btn("views/pic/pic_arrow2.png", function()
    testChiBang_AddOff(testShapeId, 1, 0)
  end)
  shapeNode:addChild(offBtn, 100)
  offBtn:setPosition(80, 50)
  local offBtn = testChiBang_Btn("views/pic/pic_arrow2.png", function()
    testChiBang_AddOff(testShapeId, -1, 0)
  end)
  offBtn:setRotation(180)
  shapeNode:addChild(offBtn, 100)
  offBtn:setPosition(-80, 50)
  local offBtn = testChiBang_Btn("views/pic/pic_arrow2.png", function()
    testChiBang_AddOff(testShapeId, 0, 1)
  end)
  offBtn:setRotation(-90)
  shapeNode:addChild(offBtn, 100)
  offBtn:setPosition(0, 140)
  local offBtn = testChiBang_Btn("views/pic/pic_arrow2.png", function()
    testChiBang_AddOff(testShapeId, 0, -1)
  end)
  offBtn:setRotation(90)
  shapeNode:addChild(offBtn, 100)
  offBtn:setPosition(0, -20)
  shapeNode._role = roleObj
  shapeNode._chibang = chiBangAni
  roleObj.__dataDict = {}
  local d = g_ChiBangOff[testShapeId]
  if d then
    for aniNameKey, pos in pairs(d) do
      roleObj.__dataDict[aniNameKey] = ccp(pos[1], pos[2])
    end
  end
  return shapeNode
end
function testChiBang_AddOff(testShapeId, offx, offy)
  local shapeNode = g_Test_RoleObj[testShapeId]
  if shapeNode == nil then
    return
  end
  print("testChiBang_AddOff", offx, offy)
  local roleObj = shapeNode._role
  local chibang = shapeNode._chibang
  local aniNameKey = string.format("%s_%d", roleObj.__act, roleObj.__dir)
  local x, y = chibang:getPosition()
  x = x + offx
  y = y + offy
  chibang:setPosition(x, y)
  if roleObj.__dataDict == nil then
    roleObj.__dataDict = {}
  end
  roleObj.__dataDict[aniNameKey] = ccp(x, y)
end
function testChiBang_DirAdd(testShapeId)
  local shapeNode = g_Test_RoleObj[testShapeId]
  if shapeNode == nil then
    return
  end
  local roleObj = shapeNode._role
  roleObj.__dir = roleObj.__dir - 1
  if roleObj.__dir < 1 then
    roleObj.__dir = 8
  end
  testChiBang_FlushAni(testShapeId)
end
function testChiBang_DirSub(testShapeId)
  local shapeNode = g_Test_RoleObj[testShapeId]
  if shapeNode == nil then
    return
  end
  local roleObj = shapeNode._role
  roleObj.__dir = roleObj.__dir + 1
  if roleObj.__dir > 8 then
    roleObj.__dir = 1
  end
  testChiBang_FlushAni(testShapeId)
end
function testChiBang_FlushAni(testShapeId)
  local shapeNode = g_Test_RoleObj[testShapeId]
  if shapeNode == nil then
    return
  end
  local roleObj = shapeNode._role
  local chibang = shapeNode._chibang
  local d = roleObj.__dir
  if roleObj.__dir >= 6 then
    roleObj:setScaleX(-1)
    chibang:setScaleX(-1)
    d = DirrectConvert[roleObj.__dir]
  else
    roleObj:setScaleX(1)
    chibang:setScaleX(1)
  end
  local aniName = string.format("%s_%d", roleObj.__act, d)
  roleObj:playAniWithName(aniName, -1)
  chibang:SetActAndDir(roleObj.__act, d)
  local aniNameKey = string.format("%s_%d", roleObj.__act, roleObj.__dir)
  if roleObj.__dataDict then
    local pos = roleObj.__dataDict[aniNameKey]
    if pos then
      chibang:setPosition(pos.x, pos.y)
    else
      roleObj.__dataDict[aniNameKey] = ccp(0, 0)
      chibang:setPosition(0, 0)
    end
  end
end
function testChiBang_Btn(path, callback)
  local btn = display.newSprite(path)
  btn:setTouchEnabled(true)
  btn:registerScriptTouchHandler(function(event, tx, ty)
    if event == "began" then
      if callback then
        callback()
      end
      btn:setScale(0.9)
      local act1 = CCDelayTime:create(0.3)
      local act2 = CCCallFunc:create(function()
        local a1 = CCCallFunc:create(function()
          if callback then
            callback()
          end
        end)
        local a2 = CCDelayTime:create(0.05)
        local a3 = CCRepeatForever:create(transition.sequence({a1, a2}))
        btn:runAction(a3)
      end)
      btn:runAction(transition.sequence({act1, act2}))
      return true
    elseif event == "ended" or event == "canceld" then
      btn:setScale(1)
      btn:stopAllActions()
    end
  end)
  return btn
end
