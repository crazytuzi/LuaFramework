airShipRank = commonDialog:new()

function airShipRank:new(layerNum)
	local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum

    self.dialogWidth = G_VisibleSizeWidth
    self.dialogHeight = G_VisibleSizeHeight
    self.realHeight = self.dialogHeight - 80
    G_addResource8888(function()
        -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
        -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/youhuaUI6.plist")
        -- spriteController:addPlist("public/airPlaneImage1.plist")
        -- spriteController:addTexture("public/airPlaneImage1.png")
        -- spriteController:addPlist("public/taskYouhua.plist")
        -- spriteController:addTexture("public/taskYouhua.png")
    end)

    return nc
end

function airShipRank:dispose( )

    -- spriteController:removePlist("public/airPlaneImage1.plist")
    -- spriteController:removeTexture("public/airPlaneImage1.png")
    -- spriteController:removePlist("public/taskYouhua.plist")
    -- spriteController:removeTexture("public/taskYouhua.png")
end