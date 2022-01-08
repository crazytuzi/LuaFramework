--[[
    固定配置

    --By: haidong.gan
    --2013/11/11
]]
local GameConfig = {}

if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
	GameConfig.FPS                	= 30;	--游戏帧率
else
	GameConfig.FPS                	= 30;	--游戏帧率
end

TFDirector:setFPS(GameConfig.FPS)

GameConfig.ANIM_FPS                	= 30; 	--动作帧率
-- GameConfig.FONT_TYPE                = "Arial";                                    --默认字体
GameConfig.WS                       = CCDirector:sharedDirector():getWinSize();   --窗口大小
GameConfig.COMMON_IMAGE_SIZE	    = CCSize(314,493);                            --卡牌大小
GameConfig.COMMON_ICON_SIZE	        = CCSize(100,100);                            --卡牌头像大小

GameConfig.FAIL	                    = 0;                          --失败
GameConfig.SUCCUSS	                = 1;                          --成功

if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
	GameConfig.FONT_TYPE = "KaiTi"
else
	GameConfig.FONT_TYPE = "font/simkai.ttf"
end

return GameConfig

