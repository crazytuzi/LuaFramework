function TestSeqAni(parentNode)
  CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("test/NewAnimation0.png", "test/NewAnimation0.plist", "test/NewAnimation.ExportJson")
  local ani = CCArmature:create("NewAnimation")
  print("===>ani:", ani)
  ani:getAnimation():setMovementEventCallFunc(function(aniObj, eventType, movementId)
    print("\n================= 动画回调")
    print("aniObj, eventType, movementId:", aniObj, eventType, movementId)
    print("aniObj == ani:", aniObj == ani)
    print([[
--------------------

]])
  end)
  ani:getAnimation():playWithIndex(0, -1, -1, 1)
  ani:setPosition(ccp(480, 320))
  parentNode:addChild(ani)
  ani:runAction(transition.sequence({
    CCDelayTime:create(2),
    CCCallFunc:create(function()
      print("===>开始FadeOut")
    end),
    CCFadeOut:create(2),
    CCCallFunc:create(function()
      print("====> FadeOut End")
    end),
    CCDelayTime:create(2),
    CCCallFunc:create(function()
      print("===>开始FadeIn")
    end),
    CCFadeIn:create(2),
    CCCallFunc:create(function()
      print("====> FadeIn End")
    end)
  }))
end
function TestSeqAni2()
  print("----->>> TestSeqAni2 test[1]")
  local plistPath = "./test/shapetest.plist"
  local pngPath = "./test/shapetest.png"
  display.addSpriteFramesWithFile(plistPath, pngPath)
  local frameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
  local node = display.newNode()
  local spriteList = {}
  for i = 1, 8 do
    local frameSprite = frameCache:spriteFrameByName(string.format("shapetest_1500%d.png", i))
    local sprite = display.newSprite(frameSprite)
    node:addChild(sprite, 0)
    spriteList[#spriteList + 1] = sprite
    sprite:setVisible(false)
  end
  local curShowIdx = 1
  spriteList[curShowIdx]:setVisible(true)
  local len = #spriteList
  local function show()
    spriteList[curShowIdx]:setVisible(false)
    curShowIdx = curShowIdx + 1
    if curShowIdx > len then
      curShowIdx = 1
    end
    spriteList[curShowIdx]:setVisible(true)
  end
  scheduler.scheduleGlobal(function()
    show()
  end, 0.1)
  return node
end
