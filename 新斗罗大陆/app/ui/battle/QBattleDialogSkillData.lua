--
-- zxs
-- 小秘书日志查看
-- 

local QBattleDialog = import(".QBattleDialog")
local QBattleDialogSkillData = class("QBattleDialogSkillData", QBattleDialog)
local QListView = import("...views.QListView") 
local QUIWidgetAgainstRecordProgressBar = import("..widgets.QUIWidgetAgainstRecordProgressBar")

function QBattleDialogSkillData:ctor(options)
	local ccbFile = "ccb/Dialog_Secretary_log.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
	}
    QBattleDialogSkillData.super.ctor(self, ccbFile, {}, callBacks)
    q.setButtonEnableShadow(self._ccbOwner.btn_action)

    self._ccbOwner.frame_tf_title:setString("技能伤害统计")
    self._ccbOwner.node_no:setVisible(false)
    self._ccbOwner.btn_ok:setVisible(false)
    self._skillData = options.skillData or {}
    self._isHero = options.isHero
    self._data = {}

    self:initData()
    self:initListView()
end

function QBattleDialogSkillData:initData()
    local maxValue = 0
    for id, obj in pairs(self._skillData) do
        local info = {}
        local skillId = obj.skillId
        if not skillId then
            skillId = id
        end
        local desc = "魂技id: [" .. skillId .. "], 魂技名: [" .. tostring(db:getSkillByID(skillId).name) .. "]"
        table.insert(info, {desc = desc})

        local castMsg = ""
        if obj.hit then
            castMsg = castMsg .. "    击打次数: " .. q.format_dec_int(math.floor(obj.hit), nil, 3)
        end
        if obj.cast then
            castMsg = castMsg .. "    释放次数: " .. q.format_dec_int(math.floor(obj.cast), nil, 3)
        end
        if obj.damage then
            local desc = "造成伤害点: " .. q.format_dec_int(math.floor(obj.damage), nil, 3) .. castMsg
            local value = obj.damage
            maxValue = math.max(value, maxValue)
            table.insert(info, {desc = desc, value = value})
        end
        if obj.treat then
            local desc = "造成治疗点: " .. q.format_dec_int(math.floor(obj.treat), nil, 3) .. castMsg
            local value = obj.treat
            maxValue = math.max(value, maxValue)
            table.insert(info, {desc = desc, value = value})
        end
        if obj.absorb then
            local desc = "造成护盾: " .. q.format_dec_int(math.floor(obj.absorb), nil, 3) .. castMsg
            local value = obj.absorb
            maxValue = math.max(value, maxValue)
            table.insert(info, {desc = desc, value = value})
        end
        if not obj.damage and not obj.treat and obj.cast then
            local desc = castMsg
            table.insert(info, {desc = desc})
        end
        table.insert(self._data, {info = info})
    end

    for _, data in pairs(self._data) do
        data.maxValue = maxValue
    end
end

function QBattleDialogSkillData:initListView()
    local totalNumber = #self._data
    if not self._listView then
        local cfg = {
            renderItemCallBack = handler(self, self._renderItemCallBack),
            enableShadow = false,
            ignoreCanDrag = true,
            curOriginOffset = 5,
            totalNumber = totalNumber,
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = totalNumber})
    end
end

function QBattleDialogSkillData:_renderItemCallBack(list, index, info )
    local isCacheNode = true
    local itemData = self._data[index]

    local item = list:getItemFromCache()
    if not item then
        item = self:getDescNode()
        isCacheNode = false
    end
    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()

    return isCacheNode
end

function QBattleDialogSkillData:getDescNode()
    local node = CCNode:create()
    function node:setInfo(data)
        node:removeAllChildren()
        local info = data.info
        local height = 0
        for i, v in pairs(info) do
            local tf = CCLabelTTF:create("", global.font_default, 20, CCSize(800, 0), kCCTextAlignmentLeft)
            tf:setAnchorPoint(ccp(0, 1))
            tf:setColor(GAME_COLOR_LIGHT.normal)
            tf:setString(v.desc)
            tf:setPositionY(-height)
            node:addChild(tf)
            height = height + 25

            if v.value then
                local bar = QUIWidgetAgainstRecordProgressBar:new()
                bar:setAnchorPoint(ccp(0, 1))
                bar:setScaleY(0.5)
                bar:hideText()
                bar:setPosition(ccp(150, -height-10))
                bar:setCurValue(v.value, data.maxValue)
                node:addChild(bar)
                height = height + 30
            end
        end
        height = height + 10
        node:setContentSize(CCSize(800, height))
    end
    return node
end

function QBattleDialogSkillData:_onTriggerClose()
    app.sound:playSound("common_cancel")
    self:close()
end

function QBattleDialogSkillData:close()
    self:removeSelf()
end

return QBattleDialogSkillData