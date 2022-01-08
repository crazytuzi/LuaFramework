
local DefaultLayer = class("DefaultLayer", function(...)
	local layer = TFPanel:create()
	return layer
end)


local displayResList = require('default.defultdisplay')

function DefaultLayer:ctor(data)

	self.picNum = 0
	for k,display in pairs(displayResList) do
		-- print("display: ", display)

		self.picNum = self.picNum + 1
	end

	self.picIndex = 1
	-- print("self.picNum = ", self.picNum )

	if self.picNum < 1 then
		-- print("没有默认图片， 直接进入游戏")
		local function delayToGame()
	    	TFDirector:removeTimer(self.timer)
	        self.timer = nil

	        self:enterGame()
	    end
	    self.timer = TFDirector:addTimer(100, -1, nil, delayToGame)
		return
	end



    self:changeImage()

    local function delayToAction()
    	TFDirector:removeTimer(self.timer)
        self.timer = nil

        self:startAction()
    end
    self.timer = TFDirector:addTimer(1000, -1, nil, delayToAction)
end



function DefaultLayer:removeUI()

end

function DefaultLayer:registerEvents()

end

function DefaultLayer:removeEvents()
	TFDirector:removeTimer(self.timer)
    self.timer = nil
end

function DefaultLayer:changeImage()

	if self.showImage then
		self.showImage:removeFromParent()
		self.showImage = nil
	end

	-- print("显示图片 = ", displayResList[self.picIndex].name)

	local image = TFImage:create()

    image:setTexture(displayResList[self.picIndex].name)
    image:setAnchorPoint(ccp(0.5, 0.5))
    self:addChild(image)

    local pDirector = CCDirector:sharedDirector()


    -- local frameSize = pDirector:getOpenGLView():getFrameSize()
    local frameSize = GameConfig.WS--pDirector:getOpenGLView():getFrameSize()
    image:setPosition(ccp(frameSize.width/2, frameSize.height/2))

    local imageSize  	= image:getSize()
    local imageWidth 	= imageSize.width
    local imageHeight 	= imageSize.height

    image:setScaleX(frameSize.width/imageWidth)
    image:setScaleY(frameSize.height/imageHeight)


    -- print("frameSize = ", frameSize)
    -- print("imageWidth = ", imageWidth)
    -- print("imageHeight = ", imageHeight)
    -- 
    self.showImage = image
end

-- 开始
function DefaultLayer:startAction()
	function fadeOut()
		-- print("imageAction")
		local tween = 
	    {
	        target = self.showImage,

	        {
            	duration = 1,
            	alpha 	 = 0,
	    	},

	        {   
		        duration = 0,
	            onComplete = function ()
		            TFDirector:killAllTween()
	                -- print("step action complete")
	                self.picIndex = self.picIndex + 1
	                -- print("self.picIndex = ", self.picIndex)
	                if self.picIndex > self.picNum then
	                	-- print("显示完成，准备进入游戏")
	                	self:enterGame()
	                else
	                	-- print("开始下一场图片")
	                	self:changeImage()
	                	self:startAction()
	                end
	            end,
	        }

	    }
	    TFDirector:toTween(tween)
	end

	-- self:enterGame()

	local function fadeInAndOut()
		local tween = 
	    {
	        target = self.showImage,

	        {
	         	ease = {type=TFEaseType.EASE_IN, rate=5}, --由慢到快
            	duration = 1,
            	alpha 	 = 1,
	    	},

	        {
            	duration = 1,
            	alpha 	 = 0,
	    	},

	        {   
		        duration = 0,
	            onComplete = function ()
		            TFDirector:killAllTween()
	                self.picIndex = self.picIndex + 1
	                if self.picIndex > self.picNum then
	                	-- print("显示完成，准备进入游戏")
	                	self:enterGame()
	                else
	                	-- print("开始下一场图片")
	                	self:changeImage()
	                	self:startAction()
	                end
	            end,
	        }

	    }
	    TFDirector:toTween(tween)
	end

	if self.picIndex > 1 then
		self.showImage:setAlpha(0)
		fadeInAndOut()
	else
		fadeOut()
	end

end

function DefaultLayer:enterGame()

    -- restartLuaEngine("EnterGame")
	-- local UpdateLayer   = require("lua.logic.login.UpdateLayer")
	-- AlertManager:changeScene(UpdateLayer:scene())

	-- if TFClientResourceUpdate == nil then 
 --        local UpdateLayer   = require("lua.logic.login.UpdateLayer")
 --        AlertManager:changeScene(UpdateLayer:scene())
 --    else
 --        local UpdateLayer   = require("lua.logic.login.UpdateLayer_new")
 --        AlertManager:changeScene(UpdateLayer:scene())
 --    end

 	-- local UpdateLayer = require("lua.logic.login.UpdateLayer")
  --   AlertManager:changeScene(UpdateLayer:scene())

  	TFDirector:changeScene(SceneType.LOGIN)
end

function DefaultLayer:testAnimation()
  local armatureID = 10016
  -- local armatureID = 10001
  ModelManager:addResourceFromFile(1, armatureID, 0.8)
  local res = ModelManager:createResource(1, armatureID)

  local eftID = 100161
  -- local eftID = 100013
  ModelManager:addResourceFromFile(2, eftID, 0.8)
  local eft = ModelManager:createResource(2, eftID)

  ModelManager:addListener(res, "ANIMATION_COMPLETE", function() print("self.armature------------>") end)
  -- res:addMEListener(TFARMATURE_COMPLETE, function() print("self.armature------------>")	end)

  -- local armatureID = 10001
  -- ModelManager:addResourceFromFile(1, armatureID)
  -- local res = ModelManager:createResource(1, armatureID)

  -- local eftID = 100013
  -- ModelManager:addResourceFromFile(2, eftID)
  -- local eft = ModelManager:createResource(2, eftID)
 
  local frameSize = GameConfig.WS
  if res then
  	self:addChild(res)
	res:setPosition(ccp(frameSize.width/2, 100))
	ModelManager:playWithNameAndIndex(res, "skill", -1, 0, -1, -1)
  end

  if eft then
  	self:addChild(eft)
  	eft:setPosition(ccp(frameSize.width/2, 100))
  	ModelManager:playWithNameAndIndex(eft, "eff_skill", 0, 0, -1, -1)
  end
end

function DefaultLayer:testSkeleton()
	TFResourceHelper:instance():addSkeletonFromFile("skeleton/10016", 1)
    local skeleton = TFSkeleton:create("skeleton/10016")

    -- TFResourceHelper:instance():addSkeletonFromFile("eft/tiangjiang01e", 1)
    -- local eft = TFSkeleton:create("eft/tiangjiang01e")

     local frameSize = GameConfig.WS
    --  local fightBGImg = TFImage:create("fightmap/mission1.jpg")
    -- fightBGImg:setPosition(ccp(frameSize.width/2, frameSize.height/2))
    -- self:addChild(fightBGImg)


    skeleton:setPosition(ccp(frameSize.width/2, 100))
    -- eft:setPosition(ccp(frameSize.width/2, 100))
    self:addChild(skeleton)
    -- self:addChild(eft)

    -- skeleton:setOpacity(150)
    -- skeleton:setColor(ccc3(0, 255, 0))

    skeleton:play("stand", 1)
    -- eft:play("eff_skill", 1)

    skeleton:setTouchEnabled(true)
    skeleton:addMEListener(TFWIDGET_CLICK, function() print("click------------>") end)

    -- self.lb_name:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSelectAccountClickHandle))

 -- 	local armatureID = 10006
	-- local resPath = "armature/"..armatureID..".xml"
	-- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
	-- local armature = TFArmature:create(armatureID.."_anim")
	-- self:addChild(armature)
	-- local frameSize = GameConfig.WS
	-- armature:setPosition(ccp(frameSize.width/2, 100))
	-- armature:play("stand", -1, -1, 1)
	-- armature:setTouchEnabled(true)

	-- armature:addMEListener(TFWIDGET_CLICK, function() print("click------------>") end)
end

return DefaultLayer