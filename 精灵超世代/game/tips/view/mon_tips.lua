-- 怪物Tips
-- author:hp

MonTips = class("MonTips", function()
    return ccui.Layout:create()
end)


function MonTips:ctor()
    self:setTouchEnabled(true)
    self:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    showLayoutRect(self)
    self:initView()
    self:registerEvents()
end


function MonTips:initView()
    self.main_container = ccui.Widget:create()
    self.main_container:setAnchorPoint(cc.p(0.5, 0.5))
    self.main_container:setPosition(cc.p(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5))
    self:addChild(self.main_container)
    
    --背景界面
    self.background = ccui.ImageView:create(PathTool.getBgRes("bg_9"), LOADTEXT_TYPE)
    self.background:setScale9Enabled(true)
    self.background:setCapInsets(cc.rect(80, 20, 10, 10))
    self.background:setContentSize(cc.size(350, 200))
    self.background:setAnchorPoint(cc.p(0.5, 0.5))
    self.background:setPosition(cc.p(0, 0))
    self.background:setTouchEnabled(true)
    self.main_container:addChild(self.background)
    
    --关闭按钮
    self.close_btn = ccui.Button:create(PathTool.getBtnRes("close"), "", "", LOADTEXT_TYPE)
    self.close_btn:setPosition(cc.p(135, 65))
    self.close_btn:setScale(0.8)
    self.main_container:addChild(self.close_btn)
    
    self.mon_head = CommonHead.new()
    self.mon_head:setScale(0.7)
    self.mon_head:setPosition(cc.p(-106,38))
    self.main_container:addChild(self.mon_head)
    
    self.mon_name = CustomTool.createLabel(Config.Color4[15], Config.Color4[119], 20, cc.p(0,0.5))
    self.mon_name:setPosition(cc.p(-62, 58))
    self.mon_name:setString("")
    self.main_container:addChild(self.mon_name)
    
    self.mon_boss = CustomTool.createLabel(Config.Color4[44], Config.Color4[119], 20, cc.p(0,0.5))
    self.mon_boss:setPosition(cc.p(-62, 25))
    self.mon_boss:setString("Boss")
    self.main_container:addChild(self.mon_boss)
    
    self.mon_desc = CustomTool.createLabel(Config.Color4[15], Config.Color4[119], 20, cc.p(0,0.5))
    self.mon_desc:setPosition(cc.p(-132, -50))
    self.mon_desc:setWidth(280)
    self.main_container:addChild(self.mon_desc)
end


function MonTips:setMonData(data)
    if data.bid then
        local mon_data = Config.Mon[data.bid]
        if mon_data then
            self.mon_head:setHeadData({quality=mon_data.quality, res_id=mon_data.res_id})
            self.mon_name:setString(mon_data.name .. " LV." .. mon_data.lev)
            self.mon_desc:setString(mon_data.desc)
            if mon_data.type == 4 then
                self.mon_boss:setVisible(true)
            else
                self.mon_boss:setVisible(false)
            end
        end
    end
end


function MonTips:registerEvents()
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self:close()
        end
    end)

    self:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:close()
        end
    end)
end


function MonTips:close()
    --移除
    if self:getParent() then
        self:removeAllChildren()
        self:removeFromParent()
        self = nil
    end
end
