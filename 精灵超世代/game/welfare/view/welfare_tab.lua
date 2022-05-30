-- --------------------------------------------------------------------
-- 福利标签页
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
WelfareTab =  WelfareTab or class("WelfareTab", function()
	return ccui.Widget:create()
end)

function WelfareTab:ctor()    
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/welfare_tab"))

    self:setAnchorPoint(cc.p(0, 0.5))
    self:setContentSize(cc.size(123,166))
	self:setTouchEnabled(true)
    self:setSwallowTouches(false)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.name = self.main_container:getChildByName("name")
    self.red_point = self.main_container:getChildByName("red_point")
    self.icon = self.main_container:getChildByName("icon")
    self.stage = self.main_container:getChildByName("stage")
    self.select = self.main_container:getChildByName("select")

    self:registerEvent()
end

function WelfareTab:registerEvent()
    self:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.call_back ~= nil then
                self.call_back(self)
            end
        end
    end)
end

function WelfareTab:setData(data)
    if data ~= nil then
        self.data = data
        self.name:setString(self.data.title)
        local res = PathTool.getTargetRes("welfare/action_icon","welfare_icon_"..(self.data.ico or 1),false,false)
        if not self.item_load then
            self.item_load = createResourcesLoad(res, ResourcesType.single, function()
                if not tolua.isnull(self.icon) then
                    loadSpriteTexture(self.icon, res, LOADTEXT_TYPE)
                end
            end,self.item_load)
        end
    end
end

function WelfareTab:updateTipsStatus(status)
    self.red_point:setVisible(status)
end

function WelfareTab:getData()
    return self.data
end

function WelfareTab:setSelecte(status)
    if status then 
        self.select:setVisible(true)
        --loadSpriteTexture(self.select, PathTool.getResFrame("welfaretab","welfaretab_1"), LOADTEXT_TYPE_PLIST)
        if self.data then
            local ret = dumpTable(self.data)
            print("-----------------福利、限时活动数据打印------------------")
            print(ret)
            print("==================================================")
        end
    else
        self.select:setVisible(false)
    end
end

function WelfareTab:setClickCallBack(call_back)
    self.call_back = call_back
end

function WelfareTab:DeleteMe()
    if self.data then
		if self.update_self_event ~= nil then
			self.data:UnBind(self.update_self_event)
			self.update_self_event = nil
		end
		self.data = nil 
	end	

    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end