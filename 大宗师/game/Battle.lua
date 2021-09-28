 --[[
 --
 -- @authors shan 
 -- @date    2014-05-12 11:26:17
 -- @version 
 --
 --]]

local Battle = class("Battle", function ( ... )
	return display.newScene("Battle")
end)

function Battle:ctor( ... )
	self.bg = display.newSprite("bigmap_bg.png")
	self.bg:setPosition(display.width/2, self.bg:getContentSize().height/2)
	self:addChild(self.bg)

    display.addSpriteFramesWithFile("bigmap/bigmap.plist", "bigmap/bigmap.png")

	self.backBtn = ui.newImageMenuItem({
        image = "#bigmap_back_up.png",
        imageSelected = "#bigmap_back_down.png",
        -- color = ccc3(255, 0, 0),
        x = display.left + 100,
        y = display.bottom + 70,
        listener = function ()
            GameStateManager:ChangeState(GAME_STATE.STATE_FUBEN)
        end

        })
    self:addChild(ui.newMenu({self.backBtn}))

    -- ccs
    local armatureName = "huangrong_ccs"
    -- local armatureName = "Cowboy"
    local animName = {"wuli","faxi","beijida","zou"}
    local filename = "ccs/" .. armatureName .. ".ExportJson"
    local function dataLoaded( percent )
        -- body
        -- if(percent > 10) then
            self.armature = CCArmature:create(armatureName)
            self.armature:getAnimation():playWithIndex(0)
            self.armature:setPosition(display.width/2, display.height/2)
            self:addChild(self.armature)
        -- end
    end
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfoAsync(filename, dataLoaded)

    self.index = 1
    self.backBtn = ui.newTTFLabelMenuItem({
        text = "play",
        x = display.width/2,
        y = display.height/4,
        size = 40,
        listener = function ( ... )
            self.armature:getAnimation():play(animName[self.index])
            self.index = self.index + 1
            if(self.index == 5) then
                self.index = 1
            end
        end
        })
    self:addChild(ui.newMenu({self.backBtn}))
end


return Battle