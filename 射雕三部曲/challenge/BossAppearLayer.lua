--[[
	文件名：BossAppearLayer.lua
	文件描述：Boss出现页面
	创建人：chenqiang
	创建时间：2017-03-06
]]

local BossAppearLayer = class("BossAppearLayer", function()
	return display.newLayer(cc.c4b(0, 0, 0, 200))
end)

-- 构造函数
--[[
-- 参数 params 中的各个字段为
    {
		bossId: boss信息
    }
]]
function BossAppearLayer:ctor(params)
	self.mBossId = params.bossId
	-- boss信息
	self.mBossInfo = nil

	-- 屏蔽下层触摸事件
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	-- 获取boss信息的服务器请求
	self:requestBossInfo()
end

function BossAppearLayer:initUI()
	-- 形象
	self.mHeroFigure = Figure.newHero({
        parent = self.mParentLayer,
        heroModelID = self.mBossInfo.BossModelId,
        anchorPoint = (cc.p(0.5, 0)),
        position = cc.p(320, 400),
        scale = 0.25,
        needRace = false,
    })
    self.mHeroFigure:setOpacity(0)

    -- 音效
    MqAudio.playEffect("etuchuxian.mp3")
    -- 闪电动画
    ui.newEffect({
        parent = self.mParentLayer,
        effectName = "effect_ui_etuchuxian",
        position = cc.p(320, 340),
        scale = 1.5,
        loop = false,
        endRelease = true,
    })

    -- 英雄浮现动画
	local sequence = cc.Sequence:create(
		cc.FadeTo:create(1.5, 255),
		cc.DelayTime:create(1),
		cc.Spawn:create(
			cc.JumpBy:create(1, cc.p(320, 800), 800, 1),
			cc.ScaleTo:create(1, 0.1)
		),
		cc.CallFunc:create(function()
			LayerManager.addLayer({
				name = "challenge.BossInfoLayer",
				data = {
					bossId = self.mBossId,
				},
				cleanUp = false,
				needRestore = true,
			})

			LayerManager.removeLayer(self)
		end)
	)
	self.mHeroFigure:runAction(sequence)
end

-- =============================网络数据处理======================

-- 获取boss信息的服务器请求
function BossAppearLayer:requestBossInfo()
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "BossBattle",
        methodName = "GetBossInfo",
        svrMethodData = {self.mBossId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
            	return 
            end
            local value = response.Value

            -- boss信息
			self.mBossInfo = value.BossInfo

			self:initUI()
        end,
    })
end


return BossAppearLayer