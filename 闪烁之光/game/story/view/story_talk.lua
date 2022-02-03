-- --------------------------------------------------------------------
-- 剧情对话面板,出于一些设定,现在只要进剧情都会打开这个面板,只是状态不同 
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------

StoryTalk = StoryTalk or BaseClass(BaseView)

local controller = StoryController:getInstance()
local model = controller:getModel()
local story_view = controller:getView()
local table_insert = table.insert
local string_format = string.format

function StoryTalk:__init(is_skip)
    self.is_skip            = is_skip
	self.win_type           = WinType.Big
	self.is_full_screen     = true
	self.view_tag			= ViewMgrTag.MSG_TAG        	-- 父级层次

    self.max_height         = 0
    self.item_info_list     = {}                                -- 数据对象
    self.item_height        = 162
    self.item_show_list     = {}
    self.can_click          = false

	self.layout_name = "drama/dramatalk_view"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("drama", "drama"), type = ResourcesType.plist},
	}
end

function StoryTalk:open_callback()
    local background = self.root_wnd:getChildByName("background")
    background:setScale(display.getMaxScale())
    background:setOpacity(100)
    self.background = background

    local container = self.root_wnd:getChildByName("container")
    local offset_y = display.getBottom(self.root_wnd)
    container:setPositionY(offset_y)

    self.scroll_view = container:getChildByName("scroll_view")
    self.scroll_view:setScrollBarEnabled(false)
    self.scroll_size = self.scroll_view:getContentSize()

    self.item = self.root_wnd:getChildByName("item")
    self.item:setVisible(false) -- left_role right_role

    self.container = container
end

function StoryTalk:register_event()
    self.background:addTouchEventListener(function(sender,event_type)
        if event_type == ccui.TouchEventType.ended then
            self:playNextAcrt()	
        end
    end)

    self.scroll_view:addTouchEventListener(function(sender,event_type)
		if event_type == ccui.TouchEventType.ended then	
            self.touch_end = sender:getTouchEndPosition()
			local is_click = true
			if self.touch_began ~= nil then
				is_click = math.abs( self.touch_end.x - self.touch_began.x ) <= 20 and math.abs( self.touch_end.y - self.touch_began.y ) <= 20
			end
			if is_click == true then
                self:playNextAcrt()			
			end
		elseif event_type == ccui.TouchEventType.began then			
            self.touch_began = sender:getTouchBeganPosition()
		end
    end)

    self.container:addTouchEventListener(function(sender,event_type)
        if event_type == ccui.TouchEventType.ended then
            self:playNextAcrt()
        end
    end)
end

function StoryTalk:playNextAcrt()
    if self.can_click == true then
        GlobalEvent:getInstance():Fire(StoryEvent.PLAY_NEXT_ACT)
    else
    end
end

function StoryTalk:openRootWnd(type, bid, actiontype, name, msg)
    self:setData(type, bid, actiontype, name, msg)
end

--==============================--
--desc:设置剧情对白
--time:2018-07-13 01:58:46
--@type:0:头像出现在左侧, 1:头像出现在右侧
--@bid:
--@msg:
--@return 
--==============================--
function StoryTalk:setData(type, bid, actiontype, name, msg)
    if not self.scroll_size then return end
    self.can_click = false
    delayRun(self.container, 0.5, function() 
        self.can_click = true
    end) 
    local item_info = {type=type or 1, bid=bid, actiontype=actiontype or 1, name=name, msg=msg}
    table_insert(self.item_info_list, 1, item_info)

    if self.topDataCache then
        self:createItem(self.topDataCache)
    end

    local size = #self.item_info_list
    local space_y = -18
    self.max_height = size * self.item_height + (size - 1) * space_y + 40
    self.max_height = math.max(self.max_height, self.scroll_size.height )
    self.scroll_view:setInnerContainerSize(cc.size(self.scroll_size.width, self.max_height))

    -- 先把当前所有的往下移一个单位
    local _y = 0
    for i, object in ipairs(self.item_show_list) do
        if not tolua.isnull(object.item) then
            object.item:setPositionY(self.max_height - 40 - (i-1)*(self.item_height + space_y))
            _y = self.max_height - 40 - self.item_height - space_y -(i-1) *(self.item_height + space_y)
            self:doRunAction(object.item, _y, i)
        end
    end
    -- 显示骨骼动画
    self:showRoleSpine(item_info.type, item_info.bid, item_info.actiontype)
    self:refreshTopItem(item_info)
end

function StoryTalk:doRunAction(item, target_y, index)
    if tolua.isnull(item) then return end
    local off_y = 20
    local x = self.scroll_size.width * 0.5
    local move_to1 = cc.MoveTo:create(0.2, cc.p(x, target_y-off_y))
    local move_to2 = cc.MoveTo:create(0.3, cc.p(x, target_y)) 
    local fadeout = cc.FadeOut:create(0.2) 
    local fadein = cc.FadeIn:create(0.1) 
    if index == 3 then
        item:runAction(cc.Sequence:create(cc.Spawn:create(fadeout, move_to2),fadein))
    else
        item:runAction(cc.Sequence:create(move_to1, move_to2))
    end
end

-- 刷新顶部固定的对话框
function StoryTalk:refreshTopItem( data )
    if tolua.isnull(self.item) then return end
    if not self.topItem then
        self.topItem = self.item:clone()
        self.topItem:setPosition(self.scroll_size.width*0.5, self.max_height+6)
        self.topItem:setVisible(true)

        local itemBg = self.topItem:getChildByName("Image_4")
        local bgSize = itemBg:getContentSize()

        -- 名称
        local nameBg = createImage(itemBg, PathTool.getResFrame("drama","drama_1002"), 10, bgSize.height-8, cc.p(0, 0.5), true)
        local nameBgSize = nameBg:getContentSize()
        local name_txt = createLabel(26,cc.c3b(255, 255, 255),nil,nameBgSize.width/2,nameBgSize.height/2,data.name or "",nameBg,nil, cc.p(0.5, 0.5))

        -- 对话内容
        local item_msg = createRichLabel(24, cc.c3b(104, 69, 42), cc.p(0, 1), cc.p(20, bgSize.height-50), 10, nil, 628)
        item_msg:setString(WordCensor:getInstance():relapceFaceIconTag(data.msg or "")[2] or "")
        itemBg:addChild(item_msg)

        -- 箭头
        local arrow = createImage(itemBg, PathTool.getResFrame("drama","drama_1004"), bgSize.width-52, 27, cc.p(0.5, 0.5), true)
        arrow:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(1.0, 100), cc.FadeTo:create(1.0, 255))))

        self.scroll_view:addChild(self.topItem, 10)

        self.topItem.name_txt = name_txt
        self.topItem.msg_txt = item_msg

        self.topItem:setOpacity(0)
        local _x = self.scroll_size.width * 0.5
        local fadein = cc.FadeIn:create(0.3)
        local move_to = cc.MoveTo:create(0.3, cc.p(_x, self.max_height-40))
        self.topItem:runAction(cc.Spawn:create(fadein, move_to))
    else
        self.topItem.name_txt:setString(data.name or "")
        self.topItem.msg_txt:setString(WordCensor:getInstance():relapceFaceIconTag(data.msg or "")[2] or "")
        self.topItem:setPosition(cc.p(self.scroll_size.width * 0.5, self.max_height+6))
        self.topItem:setOpacity(0)
        local fadein = cc.FadeIn:create(0.3)
        local move_to = cc.MoveTo:create(0.3, cc.p(self.scroll_size.width * 0.5, self.max_height-40))
        self.topItem:runAction(cc.Spawn:create(fadein, move_to))
    end
    self.topDataCache = data
end

-- 创建一个非顶部对话框
function StoryTalk:createItem(data)
    if tolua.isnull(self.item) then return end

    local item = self.item:clone()
    item:setPosition(self.scroll_size.width*0.5, self.max_height-40)
    item:setVisible(true)

    local itemBg = item:getChildByName("Image_4")
    local bgSize = cc.size(646, 130)
    itemBg:setContentSize(bgSize)
    itemBg:loadTexture(PathTool.getResFrame("drama","drama_1003"), LOADTEXT_TYPE_PLIST)

    -- 名称
    local name_txt = createLabel(24,cc.c3b(199,130,55),nil,20,100,data.name or "",itemBg,nil, cc.p(0, 0.5))

    -- 对话内容
    local item_msg = createRichLabel(24, cc.c3b(147,119,97), cc.p(0, 1), cc.p(20, bgSize.height-50), 10, nil, 606)
    item_msg:setString(WordCensor:getInstance():relapceFaceIconTag(data.msg or "")[2] or "")
    itemBg:addChild(item_msg)

    self.scroll_view:addChild(item)

    local object = {}
    object.item = item
    object.item_msg = item_msg
    object.name_txt = name_txt
    table_insert(self.item_show_list, 1, object)

    object.item:setOpacity(0)
    local fadein = cc.FadeIn:create(0.3)
    object.item:runAction(fadein)
end

-- 显示骨骼动画 dirType: 1为左边 2为右边
function StoryTalk:showRoleSpine( dirType, effid, actionType )
    local action = self:getSpineActionName(actionType)
    if dirType == 1 then
        if self.leftSpine and self.leftSpine.effid ~= effid then -- 如果换了新的spine则删除旧的
            self.leftSpine:removeFromParent()
            self.leftSpine = nil
        end
        if self.leftSpine == nil then
            local size = self.container:getContentSize()
            self.leftSpine = createEffectSpine(PathTool.getEffectRes(effid), cc.p(30, -80), cc.p(0.5, 0), true, action)
            self.leftSpine.effid = effid
            local pos_left = self.container:getChildByName("pos_left")
            self.leftSpine:setOpacity(0)
            pos_left:addChild(self.leftSpine)
            self.leftSpine:runAction(cc.FadeIn:create(0.2))
        elseif not self.lastDirType or self.lastDirType ~= dirType or self.lastActionType ~= actionType then
            self.leftSpine:setOpacity(100)
            self.leftSpine:setAnimation(0, action, true)
            self.leftSpine:setToSetupPose()
            self.leftSpine:runAction(cc.FadeIn:create(0.2))
        end
        if (not self.lastDirType or self.lastDirType ~= dirType) and self.rightSpine then
            self.rightSpine:setAnimation(0, "action2", true)
            self.rightSpine:setToSetupPose()
        end
    elseif dirType == 2 then
        if self.rightSpine and self.rightSpine.effid ~= effid then -- 如果换了新的spine则删除旧的
            self.rightSpine:removeFromParent()
            self.rightSpine = nil
        end
        if self.rightSpine == nil then
            local size = self.container:getContentSize()
            self.rightSpine = createEffectSpine(PathTool.getEffectRes(effid), cc.p(-30, -20), cc.p(0.5, 0), true, action)
            self.rightSpine:setOpacity(0)
            self.rightSpine.effid = effid
            local pos_right = self.container:getChildByName("pos_right")
            pos_right:addChild(self.rightSpine)
            self.rightSpine:runAction(cc.FadeIn:create(0.2))
        elseif not self.lastDirType or self.lastDirType ~= dirType or self.lastActionType ~= actionType then
            self.rightSpine:setOpacity(100)
            self.rightSpine:setAnimation(0, action, true)
            self.rightSpine:setToSetupPose()
            self.rightSpine:runAction(cc.FadeIn:create(0.2))
        end
        if (not self.lastDirType or self.lastDirType ~= dirType) and self.leftSpine then
            self.leftSpine:setAnimation(0, "action2", true)
            self.leftSpine:setToSetupPose()
        end
    end
    -- 记录最后一次的播放状态
    self.lastDirType = dirType
    self.lastActionType = actionType
end

function StoryTalk:getSpineActionName( actionType )
    local action = "action1"
    if actionType and type(actionType) == "number" then
        action = "action" .. actionType
    end
    return action
end

function StoryTalk:close_callback()
    doStopAllActions(self.container)
    doStopAllActions(self.leftSpine)
    doStopAllActions(self.rightSpine)
    for i, object in ipairs(self.item_show_list) do
        doStopAllActions(object.item)
    end
    if self.leftSpine then
        self.leftSpine:clearTracks()
        self.leftSpine:removeFromParent()
        self.leftSpine = nil
    end
    if self.rightSpine then
        self.rightSpine:clearTracks()
        self.rightSpine:removeFromParent()
        self.rightSpine = nil
    end
    self.item_show_list = nil
    story_view:hideTalk()
end