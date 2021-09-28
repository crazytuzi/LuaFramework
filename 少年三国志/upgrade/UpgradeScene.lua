--UpgradeScene.lua

require("framework.functions")
require("upgrade.config")

-- print("USE_ENCRYPT_LUA is:"..(USE_ENCRYPT_LUA and "true" or "false")..", type is:"..type(USE_ENCRYPT_LUA))
-- if USE_ENCRYPT_LUA then 
--     local key = "D8C092100C7F487B"
--     local sign = "927CC05C-BE89-4356-B36E-374333E05387"
--     FuncHelperUtil:setXXTeaKeyAndSign(key, #key, sign, #sign)
-- end

local UpgradeScene = class ("UpgradeScene", function()
    return CCSUIScene:create()
end)

function UpgradeScene:ctor(  )
    print("eeeeeeeeee")
    CCFileUtils:sharedFileUtils():purgeCachedEntries()

    CCFileUtils:sharedFileUtils():addSearchPath("res/")
    CCFileUtils:sharedFileUtils():addSearchPath("res/ui/font/")
    
    local winSize = CCDirector:sharedDirector():getWinSize()
    local height = winSize.height*CONFIG_SCREEN_WIDTH/winSize.width
    CCEGLView:sharedOpenGLView():setDesignResolutionSize(CONFIG_SCREEN_WIDTH, height, kResolutionShowAll)

    local splashLayer = require("upgrade.SplashLayer").new()
    self:addChild(splashLayer)

    self._upgradeLayer = require("upgrade.UpgradeLayer").new()
    self._upgradeLayer:retain()

    splashLayer:splashScreen(function ( ... )
    	print("splashLayer:splashScreen(function ( ... )")
    	if splashLayer then 
    		splashLayer:removeFromParentAndCleanup(true)
    		splashLayer = nil
    	end
    	
    	if self._upgradeLayer then 
    		self:addUILayerComponent("UpgradeLayer", self._upgradeLayer, true);
    		self._upgradeLayer:release()
    	end
    end)
    
end

return UpgradeScene
