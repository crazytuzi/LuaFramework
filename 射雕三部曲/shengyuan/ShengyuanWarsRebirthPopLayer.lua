--[[
	文件名: ShengyuanWarsRebirthPopLayer.lua
	描述: 神域争霸复活页面
	创建人: wangzhi
	创建时间: 2016.7.6
--]]

local ShengyuanWarsRebirthPopLayer = class("ShengyuanWarsRebirthPopLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 100))
end)

function ShengyuanWarsRebirthPopLayer:ctor()
    -- 屏蔽底层点击事件
    ui.registerSwallowTouch({node = self})

    -- 背景人物
    local tmpSprite = ui.newSprite("c_84.png")
    tmpSprite:setScale(Adapter.MinScale)
    tmpSprite:setPosition(display.cx, display.cy)
    self:addChild(tmpSprite)

    -- 倒计时文字
    local mRemainTimeLabel = ui.newLabel({
		text        = TR("复活倒计时: #8EF20D%s秒", ShengyuanWarsHelper.rebirthTime),
		color 		= Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack,
		x           = 170,
	    y   	    = 70,
		}):addTo(tmpSprite)

	-- 定时器
	Utility.schedule(self, function ()
			mRemainTimeLabel:setString(TR("复活倒计时: #8EF20D%s秒", ShengyuanWarsHelper.rebirthTime))
			if ShengyuanWarsHelper.rebirthTime <= 0 then
				LayerManager.removeLayer(self)
			end
		end, 1.0)

	------------------------------------------------------------
    -- 比赛结束后关闭自身
    Notification:registerAutoObserver(ShengyuanWarsUiHelper:getOneEmptyNode(self), 
        function (node, info)
            LayerManager.removeLayer(self)
        end, {ShengyuanWarsHelper.Events.eShengyuanWarsFightResult})
end

return ShengyuanWarsRebirthPopLayer