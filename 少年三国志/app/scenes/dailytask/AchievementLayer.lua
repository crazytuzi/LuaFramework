-- AchievementLayer

require "app.cfg.target_info"


local function _updateLabel(target, name, text, stroke, color,strokenum)
    strokenum = strokenum or 1
    local label = target:getLabelByName(name)
    if stroke then
        label:createStroke(stroke, strokenum)
    end
    if color then
        label:setColor(color)
    end
    
    label:setText(text)
end

local function _updateImageView(target, name, texture, texType)
    
    local img = target:getImageViewByName(name)
    img:loadTexture(texture, texType)
    
end

local function _convertUnit(num)
    if num >= 10000 and num < 100000000 then
        return math.floor(num / 10000)..G_lang:get("LANG_WAN")
    elseif num >= 100000000 then
        return math.floor(num / 100000000)..G_lang:get("LANG_YI")
    else
        return num
    end
end

local function _alignPanelContents(panel)
    local widthLimit = panel:getSize().width
    local children = nil 
    if device.platform == "wp8" or device.platform == "winrt" then
        children = panel:getChildrenWidget()
    else
        children = panel:getChildren()
    end
    if not children then 
        return 
    end
    local childrenNum = children:count()

    -- calculate the total width of all children
    local totalWidth = 0
    for i = 0, childrenNum - 1 do
        local obj = children:objectAtIndex(i)
        totalWidth = totalWidth + obj:getContentSize().width
    end

    -- if total width is beyond the limit, then right-align with the panel's right edge
    -- or, put the contents at the panel's center
    if totalWidth <= widthLimit then
        local border = (widthLimit - totalWidth) / 2
        local baseX = border
        for i = 0, childrenNum - 1 do
            local obj = children:objectAtIndex(i)
            obj:setAnchorPoint(ccp(0, 0.5))
            obj:setPositionX(baseX)
            baseX = baseX + obj:getContentSize().width
        end
    else
        local baseX = widthLimit
        for i = childrenNum - 1, 0, -1 do
            local obj = children:objectAtIndex(i)
            obj:setAnchorPoint(ccp(1, 0.5))
            obj:setPositionX(baseX)
            baseX = baseX - obj:getContentSize().width
        end
    end
end

local AchievementLayer = class("AchievementLayer", UFCCSNormalLayer)

function AchievementLayer.create(...)
    return AchievementLayer.new("ui_layout/dailytask_AchievementLayer.json", nil, ...)
end

function AchievementLayer:onLayerEnter()
    
    -- 每次进入此页面的时候发送消息，然后在接收到消息后初始化列表，没有缓存
    G_HandlersManager.targetHandler:sendTargetInfo()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TARGET_INFO, function(_, message)
        local infoList = self:_initInfoList(message.info)
        self:_initListViewWithInfos(infoList)
        if not G_Me.achievementData:hasNew() then
            G_Me.achievementData:reset()
        end
    end, self)

end

function AchievementLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function AchievementLayer:_initInfoList(infos)
    
    -- 获取服务器发来的表的数据，经过处理后返回
    local info = infos or {}
    local infoList = {}
    for i=1, #info do
        infoList[i] = info[i]
    end

    infoList.sort = function()
        -- 根据策划案的定义，需要排定列表项的顺序，顺序按照|已完成但未领取>已开启但未完成>已完成且已领取|的顺序排序
        table.sort(infoList, function(a, b)
            -- 2表示已完成但未领取，为最高优先级项，如果两项都完成，则取id从小到大排列
            if a.step == 2 or b.step == 2 then
                if a.step == b.step then
                    return a.id < b.id
                else
                    return a.step == 2 and true or false
                end
            elseif a.step == b.step then
                return a.id < b.id
            else
                return a.step < b.step
            end
        end)
    end

    infoList.sort()
    
    return infoList
    
end

function AchievementLayer:_initListViewWithInfos(infoList)
    
    self._infoList = infoList
    
    -- 这里保存一个选择的target
    self._curSelectTarget = self._curSelectTarget or nil
    
    -- 初始化列表
    if not self._listView then

        local list = self:getPanelByName("Panel_list")
        local listview = CCSListViewEx:createWithPanel(list, LISTVIEW_DIR_VERTICAL)
        self._listView = listview
        
        local function _getAwardCallback(_, message)
            
            assert(self._curSelectTarget, "Current select target could not be nil with type: "..message.t)
            local target = target_info.get(self._curSelectTarget.id)
            self._curSelectTarget = nil

            -- 弹框提示获取了什么奖励
            local awards = {}
            for i=1, 3 do
                local _type = target['reward_type'..i]
                if _type ~= 0 then
                    awards[#awards+1] = {type = target['reward_type'..i], value = target['reward_value'..i], size = target['reward_size'..i]}
                end
            end

            local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awards)
            uf_notifyLayer:getModelNode():addChild(_layer)

        end
        
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TARGET_GET_REWARD, _getAwardCallback, self)
        
        -- 分别设置创建方法和更新方法
        self._listView:setCreateCellHandler(function(list, index)
            -- 创建item
            local item = CCSItemCellBase:create("ui_layout/dailytask_AchievementCell.json")
            
            -- 设置领取按钮响应
            item:registerBtnClickEvent("Button_get", function()
                
                self._curSelectTarget = self._infoList[item:getCellIndex()+1]
                
                -- 领取奖励
                G_HandlersManager.targetHandler:sendTargetGetReward(self._infoList[item:getCellIndex()+1].t)

            end)

            -- 设置前往按钮响应
            item:registerBtnClickEvent("Button_goto", function()

                self:_go(self._infoList[item:getCellIndex()+1].t)

            end)

            -- 头像现在需要响应事件用来显示详情
            item:registerWidgetTouchEvent("Image_icon", function(widget, state)
                -- 对于图片(ImageView)的交互事件来讲，分为手指按下，移动和抬起几个动作, 2表示抬起，只有在抬起的时候才会响应，其余则不响应
                if not (not state or state == 2) then
                    return
                end

--                uf_notifyLayer:getModelNode():addChild(require("app.scenes.dailytask.AchievementRewardDetailLayer").create(self._infoList[item:getCellIndex()+1]))
                uf_sceneManager:getCurScene():addChild(require("app.scenes.dailytask.AchievementRewardDetailLayer").create(self._infoList[item:getCellIndex()+1]))
                
            end)

            return item
        end)

        self._listView:setUpdateCellHandler(function(list, index, cell)

            local curInfo = self._infoList[index+1]
            local target = target_info.get(curInfo.id)
            assert(target, "Could not find the target with id: "..curInfo.id)
            
--            local icon_type = target.icon_type
--            local good = G_Goods.convert(target['reward_type'..icon_type], target['reward_value'..icon_type], target['reward_size'..icon_type])

            -- 更新头像
            _updateImageView(cell, "Image_icon", target.icon, UI_TEX_TYPE_LOCAL)

            -- 名称
            _updateLabel(cell, "Label_name", target.target_name, Colors.strokeBrown,nil,1)
            -- 品级框
            _updateImageView(cell, "Image_frame", G_Path.getEquipColorImage(4, G_Goods.TYPE_KNIGHT), UI_TEX_TYPE_PLIST)

            -- “奖励：”
            _updateLabel(cell, "Label_desc_reward", G_lang:get('LANG_ACHIEVEMENT_ITEM_REWARD_DESC'))
            
            -- 背景
            local itemBg = cell:getImageViewByName("Image_item_bg")
            if itemBg then
--                itemBg:loadTexture(G_Path.getEquipIconBack(good.quality))
                -- 默认的背景图, 根据策划要求单独选取一张背景图
                itemBg:loadTexture(G_Path.getAchievementItemBack())
            end

            -- 奖励描述
            local goods = {}
            goods.add = function(goo)
                if goo then
                    goods[#goods + 1] = goo
                end
            end
            goods.desc = function()
                local desc = ''
                for i=1, #goods do
                    desc = desc..goods[i].name.."x".._convertUnit(goods[i].size)
                    if i ~= #goods then desc = desc..'，' end
                end
                return desc
            end
            goods.add(G_Goods.convert(target['reward_type1'], target['reward_value1'], target['reward_size1']))
            goods.add(G_Goods.convert(target['reward_type2'], target['reward_value2'], target['reward_size2']))
            goods.add(G_Goods.convert(target['reward_type3'], target['reward_value3'], target['reward_size3']))

            -- 这里偷懒一下，考虑到文本区不同颜色并且可换行，现在功能应该没有，所以这里简单处理，在区域前加空格来解决这个问题
            -- '奖励：'需要十个空格？？难道是UILabel渲染所占区域宽度的问题？
            _updateLabel(cell, "Label_desc", '          '..goods.desc())

            -- 切换显示状态
    --            self:_switchTo(cell, curInfo.step == 1 and (curInfo.num >= target.num_request and 2 or 1) or curInfo.step, curInfo.num, target.num_request)
            self:_switchTo(cell, curInfo.step, curInfo.num, target.num_request)

        end)

        self._listView:initChildWithDataLength(#self._infoList, 0.2)
        self._listView:setSpaceBorder(0, 30)
        
    else
        
        self._listView:refreshAllCell()
        
    end

end

function AchievementLayer:_switchTo(target, step, cur, total)
    
    if step == 3 then
        target:getButtonByName('Button_get'):setVisible(false)
        target:getButtonByName('Button_get'):removeAllNodes()
        target:getButtonByName('Button_goto'):setVisible(false)
        target:getPanelByName("Panel_process"):setVisible(false)
        target:getImageViewByName("Image_finish"):setVisible(true)
    elseif step == 2 then
        target:getButtonByName('Button_get'):setVisible(true)
        target:getButtonByName('Button_get'):removeAllNodes()
        target:getButtonByName('Button_goto'):setVisible(false)
        target:getPanelByName("Panel_process"):setVisible(false)
        target:getImageViewByName("Image_finish"):setVisible(false)
        
        local EffectNode = require "app.common.effects.EffectNode"
        local node = EffectNode.new("effect_around2")     
        node:setScale(1.4) 
        node:play()
        local pt = node:getPositionInCCPoint()
        node:setPosition(ccp(pt.x, pt.y))
        target:getButtonByName('Button_get'):addNode(node)
        
    elseif step == 1 then
        target:getButtonByName('Button_get'):setVisible(false)
        target:getButtonByName('Button_get'):removeAllNodes()
        target:getButtonByName('Button_goto'):setVisible(true)
        target:getPanelByName("Panel_process"):setVisible(true)
        target:getImageViewByName("Image_finish"):setVisible(false)

        _updateLabel(target, "Label_process", G_lang:get('LANG_ACHIEVEMENT_ITEM_PROCESS_DESC'))
        _updateLabel(target, "Label_process_num", G_lang:get('LANG_ACHIEVEMENT_ITEM_PROCESS_NUM', {['cur'] = _convertUnit(cur), ['total'] = _convertUnit(total)}))
        _alignPanelContents(target:getPanelByName("Panel_process"))
    end
    
end

function AchievementLayer:_go(functionId)
    
        local moduleId = 0
        self._functionId = functionId
        self._functionValue = nil
        self._chapterId = 0
        self._scenePack = GlobalFunc.sceneToPack("app.scenes.mainscene.MainScene",{})
        local FunctionLevelConst = require("app.const.FunctionLevelConst")
        
        local sceneName = nil
        -- 主线副本
        if self._functionId == 1 or self._functionId == 2 or self._functionId == 17 then
            sceneName = "app.scenes.dungeon.DungeonMainScene"
        -- 武将强化
        elseif self._functionId == 3 or self._functionId == 4 then
            sceneName = "app.scenes.herofoster.HeroFosterScene"
        -- 天命
        elseif self._functionId == 5 then
            sceneName = "app.scenes.herofoster.HeroFosterScene"
        -- 无双界面
        elseif self._functionId == 6 then
            sceneName = "app.scenes.wush.WushScene"
            moduleId = FunctionLevelConst.TOWER_SCENE
        -- vip弹窗
        elseif self._functionId == 7 or self._functionId == 8 then
            local p = require("app.scenes.vip.VipMainLayer").create()
            G_Me.shopData:setVipEnter(true)   
            uf_sceneManager:getCurScene():addChild(p)
            return
        elseif self._functionId == 9 or self._functionId == 10 then
--            uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.hero.HeroScene").new( 1))
            sceneName = "app.scenes.hero.HeroScene"
        elseif self._functionId == 11 or self._functionId == 12 then
            sceneName = "app.scenes.city.CityScene"
        elseif self._functionId == 13 then
            sceneName = "app.scenes.moshen.MoShenScene"
        elseif self._functionId == 14 or self._functionId == 16 then
            sceneName = "app.scenes.harddungeon.HardDungeonMainScene"
            moduleId = FunctionLevelConst.HARDDUNGEON
        elseif self._functionId == 15 then
            sceneName = "app.scenes.herofoster.HeroFosterScene"
        elseif self._functionId == 18 then
            sceneName = "app.scenes.harddungeon.HardDungeonMainScene"
            moduleId = FunctionLevelConst.HARD_DUNGEON_RIOT
        elseif self._functionId == 19 or self._functionId == 20 then
            sceneName = "app.scenes.timeprivilege.TimePrivilegeMainScene"
            moduleId = FunctionLevelConst.TIME_PRIVILEGE
        elseif self._functionId == 22 then
            sceneName = "app.scenes.herosoul.HeroSoulScene"
            moduleId = FunctionLevelConst.HERO_SOUL
        end

    -- __Log("function_id:%d, function_value:%d, chapterId:%d", self._functionId, self._functionValue, self._chapterId)
    -- dump(self._scenePack)
        if moduleId > 0 and not G_moduleUnlock:checkModuleUnlockStatus(moduleId) then 
            return 
        end

        if moduleId == FunctionLevelConst.TIME_PRIVILEGE then
            if not G_Me.timePrivilegeData:isOpenFunction() then
                G_MovingTip:showMovingTip(G_lang:get("LANG_ACHIEVEMENT_CANNOTGO_TIMEPRI"))
                return
            end
        end

        if sceneName then
            uf_sceneManager:popToRootAndReplaceScene(require(sceneName).new(nil, nil, self._functionValue, self._chapterId, self._scenePack))
        end
end

return AchievementLayer

