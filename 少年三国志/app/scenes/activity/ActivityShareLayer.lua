-- ActivityShareLayer


local function _updateLabel(target, name, params)
    
    local label = target:getLabelByName(name)
    if params.stroke ~= nil then
        label:createStroke(params.stroke, 1)
    end
    
    if params.color ~= nil then
        label:setColor(params.color)
    end
    
    if params.text ~= nil then
        label:setText(params.text)
    end
    
    if params.visible ~= nil then
        label:setVisible(params.visible)
    end
end

local function _updateImageView(target, name, params)
    
    local img = target:getImageViewByName(name)
    if params.texture ~= nil then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_LOCAL)
    end
    
    if params.visible ~= nil then
        img:setVisible(params.visible)
    end
    
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

require "app.cfg.share_info"


local ActivityShareLayer = class("ActivityShareLayer", UFCCSNormalLayer)

function ActivityShareLayer.create(...)
    return ActivityShareLayer.new("ui_layout/activity_ActivityShareLayer.json", ...)
end

function ActivityShareLayer:ctor()
    
    ActivityShareLayer.super.ctor(self)
    
    self._shareData = {container = {}}
    
    self._shareData.at = function(index)
        return self._shareData.container[index]
    end
    
    self._shareData.count = function()
        return #self._shareData.container
    end
    
    self._shareData.add = function(data)
        self._shareData.container[#self._shareData.container+1] = data
    end
    
    self._shareData.mod = function(data)
        for i=1, #self._shareData.container do
            if self._shareData.container[i].id == data.id then
                self._shareData.container[i] = data
                break
            end
        end
    end
    
    self._shareData.sort = function(func)
        table.sort(self._shareData.container, func)
    end
    
    self._shareData.clear = function()
        self._shareData.container = {}
    end
    
    self._shareData.pack = function()
        return clone(self._shareData.container)
    end
    
    _updateLabel(self, "Label_desc", {text=G_lang:get('LANG_ACTIVITY_SHARE_TITLE_DESC')})
    
    local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    if appstoreVersion then 
        GlobalFunc.replaceForAppVersion(self:getImageViewByName("ImageView_mm"))
    end
    
end

function ActivityShareLayer:onLayerEnter()
    
    G_HandlersManager.shareHandler:sendShareState(1)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_SHARE_INFO, function(_, message)
  
        self._shareData.clear()
        
        for i=1, #message.state do
            self._shareData.add(message.state[i])
        end
                
        self:_updateList()
        self:getPanelByName("Panel_listviewBg"):requestDoLayout()
    end, self)
end

function ActivityShareLayer:onLayerExit()
    
    uf_eventManager:removeListenerWithTarget(self)
    
end

function ActivityShareLayer:_updateList()
    
    -- 先排序
    self._shareData.sort(function(a, b)
        if a.step == 1 or b.step == 1 then
            if a.step == b.step then
                return a.id > b.id
            else
                return a.step == 1 and true or false
            end
        else    -- 0, 2
            return a.step < b.step
        end
    end)
    
    if not self._listView then
        
        -- 创建列表
        local panel = self:getPanelByName("Panel_listview")
        local size = panel:getSize()
        -- 这里需要扣除speedbar的高度来计算实际的listview的size

        panel:setSize(CCSizeMake(size.width, size.height + display.height - 853))

        local listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        self._listView = listView
        
        listView:setCreateCellHandler(function()
            return CCSItemCellBase:create("ui_layout/activity_ActivityShareItem.json")
        end)
        
        listView:setUpdateCellHandler(function(list, index, cell)
            
            local data = self._shareData.at(index+1)
            local shareInfo = share_info.get(data.id)
            assert(shareInfo, "Could not find the share info with id: "..data.id)
            
            -- 奖励描述
            local goods = {}
            goods.add = function(goo)
                if goo then
                    goods[#goods + 1] = goo
                end
            end
            goods.at = function(index)
                return goods[index]
            end
            goods.desc = function()
                local desc = ''
                for i=1, #goods do
                    desc = desc..goods[i].name.."x".._convertUnit(goods[i].size)
                    if i ~= #goods then desc = desc..'，' end
                end
                return desc
            end
            goods.add(G_Goods.convert(shareInfo['type'], shareInfo['value'], shareInfo['size']))
            
            local good = goods.at(1)
            
            -- 分享按钮和已分享水印的切换，0.不能领取 1.可领取 2.已领取
            local btn = cell:getButtonByName("Button_get")
            btn:setTouchEnabled(data.step == 1)
            btn:setVisible(not (data.step == 2))
            
            cell:attachImageTextForBtn("Button_get", "Image_11")
            cell:registerBtnClickEvent("Button_get", function()
                
                local SharingLayer = require("app.scenes.mainscene.SharingLayer")
                local detailLayer = SharingLayer.create(SharingLayer.LAYOUT_ACTIVITY_STYLE, Colors.modelColor, {
                    {"Label_direction", {text=shareInfo.directions, stroke=Colors.strokeBrown}},
                    {"Label_share_content", {text=shareInfo.share_content}},
                    {"Label_award_desc", {text=G_lang:get("LANG_ACTIVITY_SHARE_AWARD_DESC")}},
                    {"Image_award_icon", {texture=good.icon_mini, texType=good.texture_type}},
                    {"Label_award_amount", {text=good.size, stroke=Colors.strokeBrown}},
                })
                uf_sceneManager:getCurScene():addChild(detailLayer)
                
                detailLayer:registerBtnClickEvent("Button_to_weibo", function()
                    G_ShareService:weiboShareText(shareInfo.share_content)                         
                end)
                
                detailLayer:registerBtnClickEvent("Button_to_wechat", function()
                    G_ShareService:weixinShareText(shareInfo.share_content)                         
                end)
                
                uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHARE_SUCCESS, function()
                    G_HandlersManager.shareHandler:sendShare(shareInfo.id)
                end, detailLayer)
                
                uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_SHARE_FINISH, function(_, message)
                    if message.ret == NetMsg_ERROR.RET_OK then    
                        -- 分享成功, 关闭弹窗
                        self._shareData.mod{id=data.id, step=2}
                        -- 更新活动中的数据
                        G_Me.activityData.share:set(self._shareData.pack())
                        -- 如果没得分享了则要关闭红点
                        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
                        self:_updateList()
                        local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create({{type=shareInfo['type'], value=shareInfo['value'], size=shareInfo['size']}})
                        uf_notifyLayer:getModelNode():addChild(_layer)
                        detailLayer:animationToClose()
                    end
                end, detailLayer)
                
            end)
            
            _updateImageView(cell, "Image_finish", {visible=(data.step == 2)})

            -- 更新头像
            _updateImageView(cell, "Image_icon", {texture=good.icon})

            -- 名称
            _updateLabel(cell, "Label_name", {text=shareInfo.title, stroke=Colors.strokeBrown})
            -- 品级框
            _updateImageView(cell, "Image_frame", {texture=G_Path.getEquipColorImage(good.quality, good.type), texType=UI_TEX_TYPE_PLIST})

            -- “奖励：”
            _updateLabel(cell, "Label_desc_reward", {text=G_lang:get('LANG_ACHIEVEMENT_ITEM_REWARD_DESC')})
            
--            -- 背景
--            local itemBg = cell:getImageViewByName("Image_item_bg")
--            if itemBg then
----                itemBg:loadTexture(G_Path.getEquipIconBack(good.quality))
--                -- 默认的背景图, 根据策划要求单独选取一张背景图
--                itemBg:loadTexture(G_Path.getAchievementItemBack())
--            end

            -- 这里偷懒一下，考虑到文本区不同颜色并且可换行，现在功能应该没有，所以这里简单处理，在区域前加空格来解决这个问题
            -- '奖励：'需要十个空格？？难道是UILabel渲染所占区域宽度的问题？
            _updateLabel(cell, "Label_desc", {text='          '..goods.desc()})
            
        end)
        
        listView:initChildWithDataLength(self._shareData.count())
        
    else
        
        self._listView:reloadWithLength(self._shareData.count())
        
    end
    
end

return ActivityShareLayer

