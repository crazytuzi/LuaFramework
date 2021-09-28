--[[
    文件名: DlgReportSettleLayer
	描述: 武林盟主战报的结算页面
	创建人: peiyaoqiang
	创建时间: 2017.07.07
-- ]]

local DlgReportSettleLayer = class("DlgReportSettleLayer",function()
	return cc.LayerColor:create(cc.c4b(0, 0, 0, 100))
end)
                                    
function DlgReportSettleLayer:ctor(params)
	-- 屏蔽下层点击事件
    -- ui.registerSwallowTouch({node = self})

    -- -- 确定按钮回调
    -- self.enusreCallBack = params.enusreCallBack
    -- self.mPlayerInfo = params.playerInfo

    -- -- 初始化页面
    -- self:setUI()

    -- Audio.playGameBackgroundMusic("audio/scene_sucess.mp3", false)
end

function DlgReportSettleLayer:setUI()
    --底部节点
    local backNode = cc.Node:create()
    backNode:setContentSize(cc.size(640, 1136))
    backNode:setAnchorPoint(cc.p(0.5, 0.5))
    backNode:setPosition(cc.p(display.cx, display.cy))
    backNode:setScale(Adapter.MinScale)
    self:addChild(backNode)

	-- logo标志
    local winLogoNode = ui.createPVPResultLogoNode({
        isWin      = self.mPlayerInfo.IsWin,
        myName     = self.mPlayerInfo.AttackerName,
        myFAP      = self.mPlayerInfo.AttackerFAP,
        enemyName  = self.mPlayerInfo.DefenderName, 
        enemyFap   = self.mPlayerInfo.DefenderFAP,
        showWinLog = true
    })
    winLogoNode:setPosition(cc.p(320, 820))
    backNode:addChild(winLogoNode)

    --确定
    local ensureBtn = ui.newButton({
        normalImage = "ui/c_31.png",
        position = cc.p(320, 160),
        text = TR("确 定"),
        fontSize = 32,
        clickAction = function (sender)
            self.enusreCallBack()
        end
    })
    backNode:addChild(ensureBtn)
end

return DlgReportSettleLayer