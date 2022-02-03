-- --------------------------------------------------------------------
-- tips来源单个
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
SourceItem = class("SourceItem", function()
    return ccui.Widget:create()
end)

local controller = BackpackController:getInstance()
local model = BackpackController:getInstance():getModel()

SourceItem.WIDTH = 554
SourceItem.HEIGHT = 115

function SourceItem:ctor(bid, need_item_list)
    self.bid = bid      -- 物品id
    self.need_item_list = need_item_list
    self:configUI()
    self:registerEvent()
end

function SourceItem:configUI( ... )
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("tips/source_item"))
    
    self:setAnchorPoint(cc.p(0, 1))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(self.WIDTH,self.HEIGHT))

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.desc = self.main_container:getChildByName("desc")
    self.goto_btn = self.main_container:getChildByName("goto_btn")
    self.goto_btn:setTitleText(TI18N("前往"))
    self.unlock_label = self.main_container:getChildByName('unlock_label')
    self.unlock_label:setString(TI18N('未开启'))
    self.goto_btn.label = self.goto_btn:getTitleRenderer()
    if self.goto_btn.label ~= nil then
    	self.goto_btn.label:enableOutline(cc.c4b(0x29,0x4a,0x15,0xff), 2)
    end

    self.tag = self.main_container:getChildByName("tag")
    self.label = self.tag:getChildByName("label")
    self.label:setString(TI18N("推荐"))

    self.tag:setVisible(false)
end

function SourceItem:setCloseCallBack(callback)
    self.closeCallBack = callback
end

function SourceItem:setData( data )
    --self.data = data
    if not data then return end
    self.data = data.infon_data
    -- 引导需要
    self.goto_btn:setTag(2000+(self.data.id or 0))
    self.desc:setString(self.data.name)
    if data[2] then 
        if data[2] == 0 then --不推荐
            self.tag:setVisible(false)
        else
            self.tag:setVisible(true)
        end
    end
    -- local is_lock,str = self:checIsOpen(self.data.lev_limit)
    if data.is_lock == TRUE then
        self.goto_btn:setVisible(false)
        self.unlock_label:setVisible(true)
        self.unlock_label:setString(data.str)
    else
        if self.data.evt_type == "" then
            self.goto_btn:setVisible(false)
        else
            self.goto_btn:setVisible(true)
        end
        self.unlock_label:setVisible(false)
    end
end


function SourceItem:registerEvent(  )
    if self.goto_btn then
        self.goto_btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                self:clickBtn()
                if self.closeCallBack then
                    self.closeCallBack()
                else
                    controller:openTipsSource(false)    
                end
                TipsManager:getInstance():hideTips()
            end
        end)
    end
end

function SourceItem:clickBtn(  )
    controller:gotoItemSources(self.data.evt_type, self.data.extend, self.bid, self.need_item_list)
    GlobalEvent:getInstance():Fire(TipsEvent.TipsGoToEvent)
end

function SourceItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end
