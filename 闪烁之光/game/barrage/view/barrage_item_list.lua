-- --------------------------------------------------------------------
-- 单挑弹幕列表,随机速度
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
BarrageItemList = BarrageItemList or class("BarrageItemList", function()
	return ccui.Widget:create()
end)

local controller = BarrageController:getInstance()
local role_vo = RoleController:getInstance():getRoleVo()

function BarrageItemList:ctor( id)
    self.id = id
    
    local config = Config.SubtitleData.data_const.sub_font
    self.max_size = 30
    self.min_size = 25
    if config and config.val then
        self.max_size = config.val[2] or 30
        self.min_size = config.val[1] or 25
    end

    self.root_wnd = createCSBNote(PathTool.getTargetCSB("barrage/barrage_item_list"))
    self.content = self.root_wnd:getChildByName("content")
    self:addChild(self.root_wnd)
    self:retain()

    self:setContentSize(cc.size(100, 30))
    self:setAnchorPoint(cc.p(0, 0.5))
end

--==============================--
--desc:创建动作
--time:2017-09-07 07:56:11
--@type:
--@return 
--==============================--
function BarrageItemList:createAction(speed)
    if self.content ~= nil and not tolua.isnull(self.content) then
        local moveby = cc.MoveBy:create(speed, cc.p(-display.width-self.size.width-30, 15))
        local funcall = cc.CallFunc:create(function() 
            if self.action_call_back ~= nil then
                self.action_call_back(self)
            end
        end)
        self:runAction(cc.Sequence:create(moveby, funcall))
    end
end

--==============================--
--desc:设置运动结束之后的回调
--time:2017-09-07 07:56:51
--@call_back:
--@return 
--==============================--
function BarrageItemList:actionFinishCallBack(call_back)
    self.action_call_back = call_back
end

function BarrageItemList:update(data)
    if data == nil or data.msg == "" then return end

    local size = math.ceil(math.random( self.min_size, self.max_size ))
    self.content:setFontSize(size)

    local color_config = Config.SubtitleData.data_const["sub_color"]
    if color_config == nil then
        color_config = {val={91,97}}
    end
    local color = math.ceil(math.random(color_config.val[1], color_config.val[2]))
    self.content:setTextColor(Config.ColorData.data_color4[color])


    local msg = string.gsub(data.msg, "\n", "")
    self.content:setString(msg)
    self.size = self.content:getContentSize()

    self.root_wnd:setPositionY(self.size.height/2)
    self:setContentSize(self.size)

    self:checkSelfBarrage(data)
    
    local speed_config = Config.SubtitleData.data_const["sub_speed"]
    if speed_config == nil then
        speed_config = {val={14,20}}
    end
    local speed = math.ceil(math.random(speed_config.val[1], speed_config.val[2]))
    self:createAction(speed)
end

function BarrageItemList:checkSelfBarrage(data)
    local is_self = false
    if data == nil or data.rid == 0 or data.srv_id == "" then
        is_self = false
    else
        if role_vo == nil then
            is_self = false
        else
            if_self = (getNorKey(data.rid, data.srv_id) == getNorKey(role_vo.rid, role_vo.srv_id))
        end
    end
    if if_self == true then
        if self.self_notice_frame == nil then
            self.self_notice_frame = createImage(self.root_wnd, PathTool.getResFrame("common", "common_1055"), self.content:getPositionX()-6, 
                self.content:getPositionY()-2, cc.p(0, 0.5), true, -1, true)
        end
        self.self_notice_frame:setContentSize(cc.size(self.size.width+16, self.size.height+8))
    else
        if self.self_notice_frame ~= nil then
            self.self_notice_frame:removeFromParent()
            self.self_notice_frame = nil
        end
    end
end

function BarrageItemList:clearInfo()
    doStopAllActions(self)
	self:removeFromParent()
end

function BarrageItemList:DeleteMe()
    doStopAllActions(self)
	self:removeAllChildren()
	self:removeFromParent()
    self:release()
end