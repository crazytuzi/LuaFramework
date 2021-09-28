local FactionTaskLayer = class("FactionTaskLayer", function() return cc.Layer:create() end )

local path = "res/faction/"
local pathCommon = "res/common/"

function FactionTaskLayer:ctor(factionData, parentBg, factionLayer)
    self.factionLayer = factionLayer
	local msgids = {FACTION_CS_GETTASKINFO,FACTION_SC_GETTASKINFO_RET}
	require("src/MsgHandler").new(self,msgids)

    -- 行会 id 保存位置 属性更新可能暂时未更新
    local factionId = (G_FACTION_INFO and G_FACTION_INFO.id) or require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID);
    g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GETTASKINFO, "GetFactionTaskInfo",{factionID=factionId})
	addNetLoading(FACTION_CS_GETTASKINFO,FACTION_SC_GETTASKINFO_RET)

    self.factionData = factionData

    --createSprite(self, "res/common/bg/bg-6.png", cc.p(480, 290), cc.p(0.5, 0.5))

    local baseNode = cc.Node:create()
	self:addChild(baseNode)
	baseNode:setPosition(cc.p(0, 0))
	self.baseNode = baseNode

    self.bg = createSprite(baseNode, path.."7.png", cc.p(32, 39), cc.p(0, 0))
    self.bg:setFlippedX(true)

    local infoBg = createSprite(self.bg, pathCommon.."bg/bg69.png", cc.p(0, self.bg:getContentSize().height/2), cc.p(0, 0.5))
	self.infoBg = infoBg
    createSprite(infoBg, path.."task_target.png", cc.p(infoBg:getContentSize().width/2, 452), cc.p(0.5, 0.5))
    createSprite(infoBg, path.."task_award.png", cc.p(infoBg:getContentSize().width/2, 272), cc.p(0.5, 0.5))

    createLabel(infoBg, game.getStrByKey("faction_task_hh"), cc.p(50, 228), cc.p(0, 0.5), 20, true)
    createLabel(infoBg, game.getStrByKey("faction_task_cy"), cc.p(50, 148), cc.p(0, 0.5), 20, true)
  
    --进度条
    createSprite(self.bg, pathCommon.."progress/jd19-bg.png", cc.p(580, 20), cc.p(0.5, 0.5))

    self.prog = cc.ProgressTimer:create(cc.Sprite:create(pathCommon.."progress/jd19-bar.png"))
    self.prog:setPosition(cc.p(325, 20))
    self.prog:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.prog:setAnchorPoint(cc.p(0.0,0.5))
    self.prog:setBarChangeRate(cc.p(1, 0))
    self.prog:setMidpoint(cc.p(0,1))
    self.prog:setPercentage(0)
    self.bg:addChild(self.prog)

    --createLabel(self.bg, game.getStrByKey("finish_point"), cc.p(600, 50), cc.p(1, 0.5), 20, true)
    --self.progLabelMax =  createLabel(self.bg, "500", cc.p(580, 21), cc.p(0, 0.5), 20, true)
    --self.progLabelCur =  createLabel(self.bg, "500", cc.p(580, 21), cc.p(1, 0.5), 20, true, nil, nil, MColor.white)
    self.progLabelPer =  createLabel(self.bg, "500", cc.p(580, 21), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.white)
end

function FactionTaskLayer:updateUI()
    if self.curTask == nil then
        return
    end

    local task_info = getConfigItemByKey("FactionTaskDB","q_id",self.curTask.ID)
    if task_info == nil then
        return
    end

    local richText = require("src/RichText").new(self.infoBg, cc.p(50, 430), cc.size(200, 120), cc.p(0, 1), 22, 20, MColor.lable_yellow)
    richText:addText(task_info.q_desc)
    richText:format()
    
    local str = string.format( game.getStrByKey( "faction_task_hh2" ) , tostring(task_info.q_rewards_facMoney) )
    self.m_hhValue = createLabel(self.infoBg, str, cc.p(60, 198), cc.p(0, 0.5), 20, true, nil, nil, MColor.yellow)

    str = string.format( game.getStrByKey( "faction_task_cy2" ) , tostring(task_info.q_rewards_facCon) )
    self.m_cyValue = createLabel(self.infoBg, str, cc.p(60, 118), cc.p(0, 0.5), 20, true, nil, nil, MColor.yellow)


    local targets = nil
    if task_info.q_end_need_killmonster ~= nil then
        targets = DATA_Mission.__parseTaskTarget(task_info.q_end_need_killmonster, 0 , true )
    elseif task_info.q_done_event ~= 0 then
        targets = DATA_Mission.__parseCollectTarget(task_info.q_done_event, 0)
    end

    if targets ~= nil and #targets > 0 then
        local maxCount = targets[1].count
        local curCount = self.curTask.curState

        if curCount > maxCount then
            curCount = maxCount
        end

        local percent = math.floor(curCount*100/maxCount)
        self.percent = percent
        self.prog:setPercentage(percent)
        self.progLabelPer:setString(tostring(curCount).."/"..tostring(maxCount).."("..tostring(percent).."%)")
        --self.progLabelMax:setString(("/"..tostring(maxCount)))
        --self.progLabelCur:setString((tostring(curCount)))
    end

    local function onShareToFactionGroup()
        local id = self.factionData.id
        local title = "快来参加行会副本"
        local desc = "今天行会任务已经完成了" .. tostring(self.percent) .. "%，再接再厉努力完成吧！"
        local urlIcon = "http://game.gtimg.cn/images/cqsj/m/m201604/web_logo.png"
        sdkSendToWXGroup(1, 1, self.factionData.id, title, desc, "MessageExt", "MSG_INVITE", urlIcon, "")
    end

    local function shareToFactionGroup()
        if isWXInstalled() then
            if self.factionLayer.isInWXgroup then
                onShareToFactionGroup()
                TIPS({ type = 1  , str = game.getStrByKey("faction_wxgroup_sendMSGtoGroup") })
            else
                TIPS({ type = 1  , str = game.getStrByKey("faction_wxgroup_notInWXgroup") })
            end
        else
            TIPS({ type = 1  , str = game.getStrByKey("faction_wxgroup_noInstalledWX") })
        end
    end

    if self.factionData.job >= 3 and self.factionLayer.hasWXgroup then
        local groupBtn = createMenuItem(self.infoBg, "res/component/button/66.png", cc.p(self.infoBg:getContentSize().width/2, 62), shareToFactionGroup)
        groupBtn:setEnabled(true)
        createLabel(groupBtn, game.getStrByKey("faction_wxgroup_sendMSGtoGroup"), getCenterPos(groupBtn), nil, 22, true)
    end
end

function FactionTaskLayer:networkHander(buff,msgid)
	local switch = {
		[FACTION_SC_GETTASKINFO_RET] = function() 
            local t = g_msgHandlerInst:convertBufferToTable("GetFactionTaskInfoRet", buff)           
            local count = #t.tasks
            for i=1, count do
                local task = {}
                task.ID = t.tasks[i].taskID
                task.targetCount = #t.tasks[i].targets
                for j=1, task.targetCount do
                    task.curState = t.tasks[i].targets[j]
                end

                self.curTask = task
                break
            end

            self:updateUI()
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return FactionTaskLayer