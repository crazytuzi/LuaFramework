--
-- Author: Kumo
-- Date: 2014-07-14 15:41:41
-- 一键扫荡副本相关设置
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetRobotSettingForDungeon = class("QUIWidgetRobotSettingForDungeon", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIWidgetRobotSettingForDungeon:ctor(options)
    local ccbFile = "ccb/Widget_RobotSettingForDungeon.ccbi"
    local callBacks = 
    {
        {ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
    }
    QUIWidgetRobotSettingForDungeon.super.ctor(self,ccbFile,callBacks,options)

    -- self._isSaved = true
    -- self._list = options.list
    self._robotType = options.robotType
    self._robotTargetID = options.targetID
    -- self._eliteCount = options.eliteCount
    self._robotEliteList = options.robotEliteList or {}
    self._robotNormalList = options.robotNormalList or {}

    self:_init()
end

function QUIWidgetRobotSettingForDungeon:_init()
    local item = QUIWidgetItemsBox.new()
    item:setGoodsInfo(self._robotTargetID, ITEM_TYPE.ITEM, 0)
    self._ccbOwner.node_icon:addChild(item)

    local itemConfig = remote.robot:getItemConfigByID( self._robotTargetID )
    self._ccbOwner.tf_name:setString(itemConfig.name)
    local fontColor = EQUIPMENT_COLOR[itemConfig.colour]
    self._ccbOwner.tf_name:setColor(fontColor)
    self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)

    local tbl = remote.robot:getTotalEliteAttackListByBaseList(self._robotEliteList, self._robotType)
    self._eliteCount = #tbl or 0

    if self._robotType == remote.robot.MATERIAL then
        -- 材料扫荡
        self._ccbOwner.tf_title:setString("现拥有数量：")
        self._ccbOwner.tf_count:setString(remote.robot:getItemsNumByID( self._robotTargetID ) or 0)
        self._ccbOwner.tf_robot_setting_3:setString("扫荡精英副本（可扫荡次数："..self._eliteCount.."）")
        if self._robotNormalList and table.nums(self._robotNormalList) > 0 and self._robotNormalList[1].title then
            self._ccbOwner.tf_robot_setting_4:setString("扫荡普通副本（"..self._robotNormalList[1].title.."）")
        else
            self._ccbOwner.tf_robot_setting_4:setString("扫荡普通副本（无）")
        end

        -- 自动击杀要塞怪物
        self._autoInvasion = remote.robot:getTmpAutoMaterialInvasion()
        if self._autoInvasion then
            self._ccbOwner.sp_select_1:setVisible(true)
        else
            self._autoInvasion = false
            self._ccbOwner.sp_select_1:setVisible(false)
        end
        -- 自动消耗体力药水补充体力
        self._autoEnergy = remote.robot:getTmpAutoMaterialEnergy()
        if self._autoEnergy then
            self._ccbOwner.sp_select_2:setVisible(true)
        else
            self._autoEnergy = false
            self._ccbOwner.sp_select_2:setVisible(false)
        end
        -- 扫荡精英副本
        self._autoElite = remote.robot:getTmpAutoMaterialElite()
        if self._autoElite then
            self._ccbOwner.sp_select_3:setVisible(true)
        else
            self._autoElite = false
            self._ccbOwner.sp_select_3:setVisible(false)
        end
        -- 扫荡普通副本
        self._autoNormal = remote.robot:getTmpAutoMaterialNormal()
        if self._autoNormal then
            self._ccbOwner.sp_select_4:setVisible(true)
        else
            self._autoNormal = false
            self._ccbOwner.sp_select_4:setVisible(false)
        end
        --不显示第五栏
        self._ccbOwner.cellNode_5:setVisible(false)
    else
        -- 灵魂碎片扫荡
        self._ccbOwner.tf_title:setString("可扫荡次数：")
        self._ccbOwner.tf_count:setString(self._eliteCount)

        local price1 = remote.robot:getTotalResetPriceByBaseList( self._robotEliteList, 1 )
        if price1 == 0 then
            self._ccbOwner.tf_robot_setting_3:setString("自动重置关卡1次（已重置）")
        else
            self._ccbOwner.tf_robot_setting_3:setString("自动重置关卡1次（花费"..price1.."钻石）")
        end
        
        local price2 = remote.robot:getTotalResetPriceByBaseList( self._robotEliteList, 2 )
        if price2 == 0 then
            self._ccbOwner.tf_robot_setting_4:setString("自动重置关卡2次（已重置）")
        else
            self._ccbOwner.tf_robot_setting_4:setString("自动重置关卡2次（花费"..price2.."钻石）")
        end
        
        local price3 = remote.robot:getTotalResetPriceByBaseList( self._robotEliteList, 3 )
        if price3 == 0 then
            self._ccbOwner.tf_robot_setting_5:setString("自动重置关卡3次（已重置）")
        else
            self._ccbOwner.tf_robot_setting_5:setString("自动重置关卡3次（花费"..price3.."钻石）")
        end

        -- 自动击杀要塞怪物
        self._autoInvasion = remote.robot:getTmpAutoSoulInvasion()
        if self._autoInvasion then
            self._ccbOwner.sp_select_1:setVisible(true)
        else
            self._autoInvasion = false
            self._ccbOwner.sp_select_1:setVisible(false)
        end
        -- 自动消耗体力药水补充体力
        self._autoEnergy = remote.robot:getTmpAutoSoulEnergy()
        if self._autoEnergy then
            self._ccbOwner.sp_select_2:setVisible(true)
        else
            self._autoEnergy = false
            self._ccbOwner.sp_select_2:setVisible(false)
        end
        -- 自动重置关卡1次
        self._autoReplayOnce = remote.robot:getTmpAutoSoulReplayOnce()
        if self._autoReplayOnce then
            self._ccbOwner.sp_select_3:setVisible(true)
        else
            self._autoReplayOnce = false
            self._ccbOwner.sp_select_3:setVisible(false)
        end
        -- 自动重置关卡2次
        self._autoReplayTwice = remote.robot:getTmpAutoSoulReplayTwice()
        if self._autoReplayTwice then
            self._ccbOwner.sp_select_4:setVisible(true)
        else
            self._autoReplayTwice = false
            self._ccbOwner.sp_select_4:setVisible(false)
        end
        -- 自动重置关卡3次
        self._autoReplayTrible = remote.robot:getTmpAutoSoulReplayTrible()
        if self._autoReplayTrible then
            self._ccbOwner.sp_select_5:setVisible(true)
        else
            self._autoReplayTrible = false
            self._ccbOwner.sp_select_5:setVisible(false)
        end
    end
end

function QUIWidgetRobotSettingForDungeon:_onTriggerSelect(event, target)
    -- self._isSaved = false

    if target == self._ccbOwner.btn_1 then
        self._autoInvasion = not self._autoInvasion
        if self._autoInvasion then
            self._ccbOwner.sp_select_1:setVisible(true)
        else
            self._ccbOwner.sp_select_1:setVisible(false)
        end
    elseif target == self._ccbOwner.btn_2 then
        self._autoEnergy = not self._autoEnergy
        if self._autoEnergy then
            self._ccbOwner.sp_select_2:setVisible(true)
        else
            self._ccbOwner.sp_select_2:setVisible(false)
        end
    elseif target == self._ccbOwner.btn_3 then
        if self._robotType == remote.robot.MATERIAL then
            self._autoElite = not self._autoElite
            if self._autoElite then
                self._ccbOwner.sp_select_3:setVisible(true)
            else
                self._ccbOwner.sp_select_3:setVisible(false)
            end
        else
            self._autoReplayOnce = not self._autoReplayOnce
            local tbl = {}
            if self._autoReplayOnce then
                self._ccbOwner.sp_select_3:setVisible(true)

                self._autoReplayTwice = false
                self._ccbOwner.sp_select_4:setVisible(false)

                self._autoReplayTrible = false
                self._ccbOwner.sp_select_5:setVisible(false)

                tbl = remote.robot:getTotalEliteAttackListByBaseList(self._robotEliteList, self._robotType, 1)
            else
                self._ccbOwner.sp_select_3:setVisible(false)

                tbl = remote.robot:getTotalEliteAttackListByBaseList(self._robotEliteList, self._robotType, 0)
            end

            self._ccbOwner.tf_count:setString(#tbl)
        end
    elseif target == self._ccbOwner.btn_4 then
        if self._robotType == remote.robot.MATERIAL then
            self._autoNormal = not self._autoNormal
            if self._autoNormal then
                self._ccbOwner.sp_select_4:setVisible(true)
            else
                self._ccbOwner.sp_select_4:setVisible(false)
            end
        else
            self._autoReplayTwice = not self._autoReplayTwice
            local tbl = {}
            if self._autoReplayTwice then
                self._ccbOwner.sp_select_4:setVisible(true)

                self._autoReplayOnce = false
                self._ccbOwner.sp_select_3:setVisible(false)

                self._autoReplayTrible = false
                self._ccbOwner.sp_select_5:setVisible(false)

                tbl = remote.robot:getTotalEliteAttackListByBaseList(self._robotEliteList, self._robotType, 2)
            else
                self._ccbOwner.sp_select_4:setVisible(false)

                tbl = remote.robot:getTotalEliteAttackListByBaseList(self._robotEliteList, self._robotType, 0)
            end

            self._ccbOwner.tf_count:setString(#tbl)
        end
    elseif target == self._ccbOwner.btn_5 then
        if self._robotType == remote.robot.MATERIAL then
            self._autoNormal = not self._autoNormal
            if self._autoNormal then
                self._ccbOwner.sp_select_5:setVisible(true)
            else
                self._ccbOwner.sp_select_5:setVisible(false)
            end
        else
            self._autoReplayTrible = not self._autoReplayTrible
            local tbl = {}
            if self._autoReplayTrible then
                self._ccbOwner.sp_select_5:setVisible(true)

                self._autoReplayOnce = false
                self._ccbOwner.sp_select_3:setVisible(false)

                self._autoReplayTwice = false
                self._ccbOwner.sp_select_4:setVisible(false)

                tbl = remote.robot:getTotalEliteAttackListByBaseList(self._robotEliteList, self._robotType, 3)
            else
                self._ccbOwner.sp_select_5:setVisible(false)

                tbl = remote.robot:getTotalEliteAttackListByBaseList(self._robotEliteList, self._robotType, 0)
            end

            self._ccbOwner.tf_count:setString(#tbl)
        end
    end

    self:saveSetting()
end

function QUIWidgetRobotSettingForDungeon:saveSetting( callback )
    -- if not self._isSaved then
        if self._robotType == remote.robot.MATERIAL then
            remote.robot:setTmpAutoMaterialEnergy( self._autoEnergy or false )
            remote.robot:setTmpAutoMaterialInvasion( self._autoInvasion or false )
            remote.robot:setTmpAutoMaterialElite( self._autoElite or false )
            remote.robot:setTmpAutoMaterialNormal( self._autoNormal or false )
            -- remote.robot:needMaterialSave()
        else
            remote.robot:setTmpAutoSoulEnergy( self._autoEnergy or false )
            remote.robot:setTmpAutoSoulInvasion( self._autoInvasion or false )
            remote.robot:setTmpAutoSoulReplayOnce( self._autoReplayOnce or false )
            remote.robot:setTmpAutoSoulReplayTwice( self._autoReplayTwice or false )
            remote.robot:setTmpAutoSoulReplayTrible( self._autoReplayTrible or false )
            -- remote.robot:needSoulSave()
        end
    -- else
    --     app.tip:floatTip("魂师大人，请选择或修改您的设置再点击保存~")
    --     return
    -- end

    if callback ~= nil then
        callback()
    end
end

return QUIWidgetRobotSettingForDungeon