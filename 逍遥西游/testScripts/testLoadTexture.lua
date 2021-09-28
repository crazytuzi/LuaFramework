require("app.gamereset")
require("config")
require("framework.init")
filter = require("framework.filter")
require("framework.shortcodes")
require("framework.cc.init")
cc.net = require("framework.cc.net.init")
lfs = require("lfs")
CCFileUtils:sharedFileUtils():addSearchPath("res/")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local files = {
  "pic_mapscenebg1001",
  "pic_mapscenebg1003",
  "pic_mapscenebg1004",
  "pic_mapscenebg1005",
  "pic_mapscenebg1006",
  "pic_mapscenebg1007",
  "pic_mapscenebg1008",
  "pic_mapscenebg1009",
  "pic_mapscenebg1010",
  "pic_mapscenebg10111",
  "pic_mapscenebg10112",
  "pic_mapscenebg1012",
  "pic_mapscenebg1013"
}
local testLoadTexture = {}
function testLoadTexture.loadPath(path)
  local paths = {}
  for i, file in ipairs(files) do
    for i, suffix in ipairs({
      ".jpg",
      ".png",
      ".pvr.ccz"
    }) do
      local filePath = path .. file .. suffix
      filePath = CCFileUtils:sharedFileUtils():fullPathForFilename(filePath)
      if io.exists(filePath) then
        paths[#paths + 1] = filePath
      end
    end
  end
  local time1 = cc.net.SocketTCP.getTime()
  for i, filePath in ipairs(paths) do
    sprite = display.newSprite(filePath)
  end
  local time2 = cc.net.SocketTCP.getTime()
  return time2 - time1
end
local dt = 1
function testLoadTexture.startTest(path, delayTime)
  scheduler.performWithDelayGlobal(function()
    print([[


]])
    print("====================================================================")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames()
    CCTextureCache:sharedTextureCache():removeUnusedTextures()
    print("\n")
    print("path:", path)
    local t = testLoadTexture.loadPath(path)
    CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
    print(string.format("Load %s used:%f", path, t))
    print([[


]])
  end, dt)
  dt = dt + 3
end
function testLoadTexture.start()
  print("testLoadTexture->>")
  testLoadTexture.startTest("testOut/")
  testLoadTexture.startTest("testOut_pvrccz/")
  testLoadTexture.startTest("testOut_pvrccz_encrypt/")
  testLoadTexture.startTest("testOut_pvr_encrypte/")
end
function testLoadTexture.testMask()
  local scene = CCScene:create()
  display.replaceScene(scene)
  local colorLayer = CCLayerColor:create(ccc4(255, 255, 255, 255))
  scene:addChild(colorLayer)
  local sprite = NmgMaskSprite:create("test/magic2_8.pvr.ccz", "test/magic2_8_mask.png")
  colorLayer:addChild(sprite)
  local size = sprite:getContentSize()
  sprite:setPosition(size.width / 2, size.height / 2)
  local sprite2 = display.newSprite("test/magic2_8.png")
  colorLayer:addChild(sprite2)
  local size = sprite2:getContentSize()
  sprite2:setPosition(display.width / 2 + size.width / 2, size.height / 2)
  CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
end
function testLoadTexture.newMaskedSprite(__mask, __pic)
  local __mb = ccBlendFunc()
  __mb.src = GL_SRC_ALPHA
  __mb.dst = GL_ZERO
  local __pb = ccBlendFunc()
  __pb.src = GL_SRC_COLOR
  __pb.dst = GL_ZERO
  local __maskSprite = display.newSprite(__mask):align(display.LEFT_BOTTOM, 0, 0)
  __maskSprite:setBlendFunc(__mb)
  local __picSprite = display.newSprite(__pic):align(display.LEFT_BOTTOM, 0, 0)
  __picSprite:setBlendFunc(__pb)
  local __maskSize = __maskSprite:getContentSize()
  local __canva = CCRenderTexture:create(__maskSize.width, __maskSize.height)
  __canva:clear(255, 255, 255, 255)
  __canva:begin()
  __maskSprite:visit()
  __picSprite:visit()
  __canva:endToLua()
  local __resultSprite = CCSprite:createWithTexture(__canva:getSprite():getTexture())
  __resultSprite:setFlipY(true)
  return __resultSprite
end
function testLoadTexture.loadJpg()
  local jpgPaths = {
    "test/testjpg_565_100.jpg",
    "test/testjpg_565.jpg",
    "test/testjpg_888.jpg",
    "test/testjpg_8888.jpg",
    "test/testjpg.png"
  }
  for k, path in pairs(jpgPaths) do
    display.newSprite(path)
  end
  CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
end
function testLoadTexture.PrintMemoryInfo()
  local totalMem, freeMem, appUsedMem = SyNative.getMemoryInfo()
  if totalMem ~= nil and freeMem ~= nil and appUsedMem ~= nil then
    CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
    print(string.format("LUA VM MEMORY USED: %0.2f KB", collectgarbage("count")))
    print(string.format("总内存:%.2fMB,空余内存:%.2fMB,app使用内存:%.2fMB", totalMem, freeMem, appUsedMem))
  end
end
function testLoadTexture.loadPngMemory()
  local scene = CCScene:create()
  display.replaceScene(scene)
  local pngPath = "test/test_png_mem.png"
  display.newSprite(pngPath)
  testLoadTexture.PrintMemoryInfo()
  scheduler.performWithDelayGlobal(function()
    testLoadTexture.PrintMemoryInfo()
  end, 1)
  local idx = 0
  scheduler.scheduleGlobal(function()
    local sprite = display.newSprite(pngPath)
    scene:addChild(sprite)
    sprite:setPosition(math.random(200, 500), math.random(100, 600))
    idx = idx + 1
    print("\n")
    print(string.format("----------------------------%d--------------------------", idx))
    testLoadTexture.PrintMemoryInfo()
    print("\n")
  end, 5)
end
function testLoadTexture.testBlack()
  local spritePath = "test/tt2.pvr.ccz"
  local scene = CCScene:create()
  display.replaceScene(scene)
  local colorLayer = CCSprite:create("xiyou/mapbg/pic_mapscenebg1006.jpg")
  colorLayer:setPosition(display.width / 2, display.height / 2)
  scene:addChild(colorLayer)
  local sprite2 = NmgClearBalckBgSprite:create(spritePath)
  colorLayer:addChild(sprite2)
  local size = sprite2:getContentSize()
  sprite2:setPosition(size.width * 3 / 2, size.height)
  CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
end
function testLoadTexture.loadDiffiencePixelFormat()
  print("loadDiffiencePixelFormat->>")
  scheduler.performWithDelayGlobal(function()
    print([[


]])
    print("====================================================================")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames()
    CCTextureCache:sharedTextureCache():removeUnusedTextures()
    testLoadTexture.PrintMemoryInfo()
    print([[


]])
  end, 1)
  scheduler.performWithDelayGlobal(function()
    local path = "test/t1/"
    local pre = "a8"
    for i = 1, 10 do
      local filePath = string.format("%s%s_%d.png", path, pre, i)
      sprite = display.newSprite(filePath)
    end
    print([[


]])
    print("====================================================================")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames()
    CCTextureCache:sharedTextureCache():removeUnusedTextures()
    testLoadTexture.PrintMemoryInfo()
    print([[


]])
  end, 5)
end
function testLoadTexture.testText()
  local scene = CCScene:create()
  display.replaceScene(scene)
  local colorLayer = CCLayerColor:create(ccc4(182, 130, 68, 255))
  colorLayer:setPosition(0, 0)
  scene:addChild(colorLayer)
  local txtColor = ccc3(0, 0, 0)
  local strokeColor = ccc3(35, 91, 42)
  local font = "Arial-BoldMT"
  local x, y = display.width / 2, display.height / 2 + 300
  local dy = -40
  local d = {
    {
      "描边测试TestABC0156248_描边颜色不一样_1",
      1,
      strokeColor
    },
    {
      "描边测试TestABC0156248_描边颜色一样_1",
      0.5,
      txtColor
    },
    {
      "描边测试TestABC0156248_描边颜色不一样_2",
      2,
      strokeColor
    },
    {
      "描边测试TestABC0156248_描边颜色一样_2",
      2,
      txtColor
    },
    {
      "描边测试TestABC0156248",
      4,
      strokeColor
    }
  }
  local txt1 = CCLabelTTF:create("描边测试TestABC0156248", font, 30)
  txt1:setColor(txtColor)
  scene:addChild(txt1)
  txt1:setPosition(x, y)
  for i, data in ipairs(d) do
    y = y - 10
    local txt, strokeSize, sColor = unpack(data, 1, 3)
    local txtIns = ui.newTTFLabelWithShadow({
      text = txt,
      size = 30,
      font = font,
      color = txtColor,
      textAlign = ui.TEXT_ALIGN_CENTER,
      shadowColor = sColor
    })
    txtIns.shadow1:realign(2, 0)
    scene:addChild(txtIns)
    y = y + dy
    txtIns:setPosition(x - txtIns:getContentSize().width / 2, y)
    local txtIns = CCLabelTTF:create(txt, font, 30)
    txtIns:setColor(txtColor)
    txtIns:enableShadow(cc.size(2, 0), 255, 1, true)
    scene:addChild(txtIns)
    y = y + dy
    txtIns:setPosition(x, y)
  end
end
function testLoadTexture.loadTextureAsync()
  local loadIdx = 0
  local jpgPaths = {
    {
      "test/pic_mapscenebg100201.jpg",
      1
    },
    {
      "test/pic_mapscenebg100202.jpg",
      2
    },
    {
      "test/c_dazhao1_8_00001.png",
      5
    },
    {
      "test/c_dazhao1_8_00002.png",
      8
    },
    {
      "test/c_dazhao1_8_00003.png",
      5
    },
    {
      "test/pic_mapscenebg100203.jpg",
      5
    },
    {
      "test/pic_mapscenebg1001.jpg",
      5
    },
    {
      "test/pic_mapscenebg1003.jpg",
      5
    },
    {
      "test/pic_mapscenebg1004.jpg",
      5
    },
    {
      "test/pic_mapscenebg1005.jpg",
      5
    },
    {
      "test/pic_mapscenebg1006.jpg",
      5
    },
    {
      "test/pic_mapscenebg1007.jpg",
      5
    },
    {
      "test/pic_mapscenebg1008.jpg",
      5
    },
    {
      "test/pic_mapscenebg1009.jpg",
      5
    },
    {
      "test/pic_mapscenebg1010.jpg",
      5
    },
    {
      "test/pic_mapscenebg1011.jpg",
      5
    },
    {
      "test/pic_mapscenebg1012.jpg",
      5
    },
    {
      "test/pic_mapscenebg1013.jpg",
      5
    }
  }
  for k, pathInfo in ipairs(jpgPaths) do
    do
      local path = pathInfo[1]
      local priority = pathInfo[2]
      local pixelFormat = kCCTexture2DPixelFormat_RGB565
      display.addImageAsync(path, function()
        loadIdx = loadIdx + 1
        print(string.format([[

	 %d, %d, %s
]], loadIdx, priority, path))
        display.newSprite(path)
        if loadIdx == #jpgPaths then
          CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
        end
      end, pixelFormat)
    end
  end
  CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
end
function testLoadTexture.testMerge()
  local scene = CCScene:create()
  display.replaceScene(scene)
  local colorLayer = CCLayerColor:create(ccc4(255, 255, 255, 255))
  scene:addChild(colorLayer)
  local mapPic = display.newSprite("xiyou/mapbg/pic_mapscenebg1001.jpg")
  mapPic:setPosition(ccp(display.width / 2, display.height / 2))
  colorLayer:addChild(mapPic, 10)
  local ani = CreateSeqAnimation("xiyou/shape/shape11004_dlg.plist", -1)
  ani:setPosition(ccp(display.width / 2 - 100, display.height / 2))
  colorLayer:addChild(ani, 20)
  ani:playAniWithName("stand_4", -1)
  ani:setEnalbeColorful(true)
  ani:setColorful(1, ccc4(180, 255, 150, 255))
  ani:setColorful(2, ccc4(150, 255, 160, 255))
  ani:setColorful(3, ccc4(255, 255, 255, 255))
  ani:setColorful(4, ccc4(255, 255, 100, 255))
  CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
  scheduler.scheduleGlobal(function()
    CCTextureCache:sharedTextureCache():removeUnusedTextures()
    printInfo("---------------------------------------------------")
    CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
  end, 1)
  scheduler.scheduleGlobal(function()
    if ani then
      ani:removeSelf()
      ani = nil
    end
  end, 5)
end
function testLoadTexture.loadTextureAsyncAndroid()
  local loadIdx = 0
  local jpgPaths = {
    {
      "xiyou/mapbg/pic_mapscenebg1001.jpg",
      5
    },
    {
      "xiyou/mapbg/pic_mapscenebg1003.jpg",
      5
    },
    {
      "xiyou/mapbg/pic_mapscenebg1004.jpg",
      5
    },
    {
      "xiyou/mapbg/pic_mapscenebg1005.jpg",
      5
    },
    {
      "xiyou/mapbg/pic_mapscenebg1006.jpg",
      5
    },
    {
      "xiyou/mapbg/pic_mapscenebg1007.jpg",
      5
    },
    {
      "xiyou/mapbg/pic_mapscenebg1008.jpg",
      5
    },
    {
      "xiyou/mapbg/pic_mapscenebg1009.jpg",
      5
    },
    {
      "xiyou/mapbg/pic_mapscenebg1010.jpg",
      5
    },
    {
      "xiyou/mapbg/pic_mapscenebg1011.jpg",
      5
    },
    {
      "xiyou/mapbg/pic_mapscenebg1012.jpg",
      5
    },
    {
      "xiyou/mapbg/pic_mapscenebg1013.jpg",
      5
    }
  }
  for k, pathInfo in ipairs(jpgPaths) do
    do
      local path = pathInfo[1]
      local priority = pathInfo[2]
      local pixelFormat = kCCTexture2DPixelFormat_RGB565
      local function listener()
        loadIdx = loadIdx + 1
        print(string.format([[

	 %d, %d, %s
]], loadIdx, priority, path))
        display.newSprite(path)
        if loadIdx == #jpgPaths then
          CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
        end
      end
      addDynamicLoadTexture(path, listener, {pixelFormat = pixelFormat})
    end
  end
  CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
end
function testLoadTexture.loadTextureAndroid()
  setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
  local loadIdx = 0
  local jpgPaths = {
    {
      "xiyou/mapbg/pic_mapscenebg1001.jpg",
      5,
      kCCTexture2DPixelFormat_RGB565
    },
    {
      "xiyou/mapbg/pic_mapscenebg1003.jpg",
      5,
      kCCTexture2DPixelFormat_RGB565
    },
    {
      "xiyou/mapbg/pic_mapscenebg1004.jpg",
      5,
      kCCTexture2DPixelFormat_RGB565
    },
    {
      "xiyou/mapbg/pic_mapscenebg1005.jpg",
      5,
      kCCTexture2DPixelFormat_RGB565
    },
    {
      "xiyou/mapbg/pic_mapscenebg1006.jpg",
      5,
      kCCTexture2DPixelFormat_RGB565
    },
    {
      "xiyou/mapbg/pic_mapscenebg1007.jpg",
      5,
      kCCTexture2DPixelFormat_RGB565
    },
    {
      "xiyou/mapbg/pic_mapscenebg1008.jpg",
      5,
      kCCTexture2DPixelFormat_RGB565
    },
    {
      "xiyou/mapbg/pic_mapscenebg1009.jpg",
      5,
      kCCTexture2DPixelFormat_RGB565
    },
    {
      "xiyou/mapbg/pic_mapscenebg1010.jpg",
      5,
      kCCTexture2DPixelFormat_RGB565
    },
    {
      "xiyou/shape/shape20034.png",
      5,
      kCCTexture2DPixelFormat_RGBA4444
    },
    {
      "xiyou/shape/shape20035.png",
      5,
      kCCTexture2DPixelFormat_RGBA4444
    },
    {
      "xiyou/shape/shape20036.png",
      5,
      kCCTexture2DPixelFormat_RGBA4444
    },
    {
      "xiyou/shape/shape20037.png",
      5,
      kCCTexture2DPixelFormat_RGBA4444
    },
    {
      "xiyou/shape/shape20038.png",
      5,
      kCCTexture2DPixelFormat_RGBA4444
    },
    {
      "xiyou/shape/shape20039.png",
      5,
      kCCTexture2DPixelFormat_RGBA4444
    }
  }
  for k, pathInfo in ipairs(jpgPaths) do
    setDefaultAlphaPixelFormat(pathInfo[3])
    display.newSprite(pathInfo[1])
  end
  scheduler.scheduleGlobal(function()
    CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
  end, 3)
end
function testLoadTexture.loadTextureAndroid2()
  local scene = display.newScene()
  display.replaceScene(scene)
  local path = "pic_mapscenebg1001.jpg"
  setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
  local sp = display.newSprite("pic_mapscenebg1001.jpg")
  scene:addChild(sp)
  sp:setPosition(display.width / 2 - sp:getContentSize().width / 2, 0)
  setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  scheduler.scheduleGlobal(function()
    CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
  end, 3)
end
return testLoadTexture
