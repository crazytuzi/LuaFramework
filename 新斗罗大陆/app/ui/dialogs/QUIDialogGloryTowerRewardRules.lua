local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGloryTowerRewardRules = class("QUIDialogGloryTowerRewardRules", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")

local QUIWidgetGloryTowerRewardRulesReward = import("..widgets.QUIWidgetGloryTowerRewardRulesReward")
local QUIWidgetGloryTowerRewardRulesReward2 = import("..widgets.QUIWidgetGloryTowerRewardRulesReward2")
local QUIWidgetGloryTowerRewardRulesHead = import("..widgets.QUIWidgetGloryTowerRewardRulesHead")
local QUIWidgetGloryTowerRewardRulesSeparator = import("..widgets.QUIWidgetGloryTowerRewardRulesSeparator")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QListView = import("...views.QListView")


function QUIDialogGloryTowerRewardRules:ctor(options)
    local ccbFile = "ccb/Dialog_GloryTower_Rule.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogGloryTowerRewardRules._onTriggerClose)}
    }
    QUIDialogGloryTowerRewardRules.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true
    self.info = options.info
    self.scrollDistance = options.scrollDistance

    self:initData()
    self:initListView()
end

function QUIDialogGloryTowerRewardRules:initData( )
  -- body
    self._data = {}
    local config = QStaticDatabase:sharedDatabase():getGloryTower(self.info.floor or 0)
    local topConfig = QStaticDatabase:sharedDatabase():getGloryTower(self.info.maxFloor or 0)
    -- print("self.info.rank",config.name,topConfig.name)
    -- printTable(config)
    local rewardInfo
    if self.info.floor >= 21 then
        rewardInfo = QStaticDatabase:sharedDatabase():getGloryTowerRewardByRank(self.info.floor)
    end
    local headData = {}
    headData.gradeName = config.name or ""
    headData.topGradeName = topConfig.name or ""
    headData.rewardInfo = rewardInfo
    headData.dataType = "headData"

    local headFrames = QStaticDatabase:sharedDatabase():getFrames(remote.headProp.FRAME_GLORY_TYPE)
    for _, crownCfg in pairs(headFrames) do
        if crownCfg.condition == config.id then
            headData.crownIcon = {upIcon = crownCfg.icon_bottom, downIcon = crownCfg.icon}
            break
        end
    end

    table.insert(self._data,{dataType = "describe", info = {
        helpType = "duanweisai_shuoming_1",
        paramArr = {headData.gradeName},
        }})

    table.insert(self._data,headData)

    table.insert(self._data,{dataType = "describe", info = {
        helpType = "duanweisai_shuoming_2",
        }})

    table.insert(self._data,{dataType = "Separator", name = "段位达到条件:"})

    local function getCrownIcon(floor)
        -- body
        for _, config in pairs(headFrames) do
            if config.condition == floor then
                local info = {}
                info.upIcon = config.icon_bottom
                info.downIcon = config.icon
                return info
            end
        end
    end

    local gradeExplain = {
        {dataType = "gradeExplain", gradeName = "最强王者", explain = "第1名", id = 1, crownIcon = getCrownIcon(28)},
        {dataType = "gradeExplain", gradeName = "超凡大师", explain = "第2~3名",id = 2,crownIcon = getCrownIcon(27)},
        {dataType = "gradeExplain", gradeName = "璀璨钻石I", explain = "第4~10名",id = 4,crownIcon = getCrownIcon(26)},
        {dataType = "gradeExplain", gradeName = "璀璨钻石II", explain = "第11~50名",id = 11,crownIcon = getCrownIcon(25)},
        {dataType = "gradeExplain", gradeName = "璀璨钻石III", explain = "钻石段位排名前20%玩家",id = 12,crownIcon = getCrownIcon(24)},
        {dataType = "gradeExplain", gradeName = "璀璨钻石IV", explain = "钻石段位排名前30%玩家",id = 13,crownIcon = getCrownIcon(23)},
        {dataType = "gradeExplain", gradeName = "璀璨钻石V", explain = "达到钻石段位玩家",id = 14,crownIcon = getCrownIcon(22)}, 

    }
    --最强王者  超凡大师  璀璨1-5
    for i = 1,7 do 
        table.insert(self._data,gradeExplain[i])
    end
    table.insert(self._data,{dataType = "describe", customStr = "（同时满足条件按最高档位发放奖励）"})

    -- 本服奖励
    local rewardsExplain = {}
    table.insert(self._data,{dataType = "Separator",name = "本服排行奖励:"})
    for i = 1,7 do 
        rewardsExplain[i] = {}
        local rewardInfo = QStaticDatabase:sharedDatabase():getGloryTowerRewardByID(gradeExplain[i].id)
        if not rewardInfo then
            rewardInfo = {}
        end
        rewardsExplain[i].rewardInfo = rewardInfo
        rewardsExplain[i].explain = gradeExplain[i].explain
        rewardsExplain[i].dataType = "rewardsExplain"
        table.insert(self._data,rewardsExplain[i])
    end
    table.insert(self._data,{dataType = "describe", customStr = "（同时满足条件按最高档位发放奖励）"})

    -- 规则
    table.insert(self._data,{dataType = "Separator",name = "大魂师赛规则:"})
    table.insert(self._data,{dataType = "describe", info = {
        helpType = "duanweisai_shuoming_3",
        }})


    -- printTable(self._data)
end



function QUIDialogGloryTowerRewardRules:initListView(  )
    -- body
    local cfg = {
        renderItemCallBack = function( list, index, info )
          -- body
            local isCacheNode = true
            local data = self._data[index]
            local item = list:getItemFromCache(data.dataType)
            if not item then
                if data.dataType == "headData" then
                    item = QUIWidgetGloryTowerRewardRulesHead.new()
                    
                elseif data.dataType == "Separator" then
                    item = QUIWidgetGloryTowerRewardRulesSeparator.new()

                elseif data.dataType == "gradeExplain" then
                    item = QUIWidgetGloryTowerRewardRulesReward.new()
                elseif data.dataType == "rewardsExplain" then
                    item = QUIWidgetGloryTowerRewardRulesReward2.new()
                elseif data.dataType == "describe" then
                    item = QUIWidgetHelpDescribe.new()
                end
                isCacheNode = false
            end

            if data.dataType == "describe" then
                item:setInfo(data.info or {}, data.customStr)
            else
                 item:setInfo(data)
            end

            info.item = item
            info.size = item:getContentSize()
            info.tag = data.dataType

           
            return isCacheNode
        end,
        totalNumber = #self._data,
        enableShadow = false,

    }
    self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
   
end


function QUIDialogGloryTowerRewardRules:viewAnimationInHandler()
    -- if self.clent ~= nil then
    --   self.clent:setRewardItems()
    -- end
    if self.scrollDistance then
        self._listView:startScrollToPosScheduler(self.scrollDistance, 1)
    end
end

-- 初始化中间的魂师选择框 swipe工能

function QUIDialogGloryTowerRewardRules:viewAnimationOutHandler()
  app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogGloryTowerRewardRules:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogGloryTowerRewardRules:_onTriggerClose()
  app.sound:playSound("common_close")
  self:playEffectOut()
end

return QUIDialogGloryTowerRewardRules