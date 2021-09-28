 --[[
 --
 -- @authors shan 
 -- @date    2014-06-03 17:40:45
 -- @version 
 --
 --]]

require("game.GameConst")


local ArenaChangeMsgBox = class("ArenaChangeMsgBox", function (data)
	return require("utility.ShadeLayer").new()
end)

function ArenaChangeMsgBox:ctor(param)
    local resetFunc = param.resetFunc
    local battleFunc = param.battleFunc
    

    local proxy = CCBProxy:create()
    local ccbReader = proxy:createCCBReader()
    local rootnode = rootnode or {}

    self._rootnode = {}
    local node = CCBuilderReaderLoad("ccbi/arena/arena_change_msgBox.ccbi", proxy, self._rootnode)
    node:setPosition(display.width/2, display.height/2)
    self:addChild(node)

  
    

    setControlBtnEvent(self._rootnode["backBtn"],function()

        --刷新列表并且将这个页面关闭
        resetFunc()
        self:removeSelf()

        end,
        function()
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        end)

    setControlBtnEvent(self._rootnode["confirm_btn"],function()

        --确定列表并且进入竞技场战斗
        battleFunc()
        end)

    

end







return ArenaChangeMsgBox