--[[
 * 剧情泡泡
 * @authors cloud
 * @date    2016.12.22
]]
StoryBubble = StoryBubble or BaseClass()

function StoryBubble:__init(parent_wnd)
	self:config()
	self:initView()
    if parent_wnd ~= nil then
        self:setParent(parent_wnd, 100)
    end
end

-- 一些记录数据初始化
function StoryBubble:config()

end

-- 界面初始化
function StoryBubble:initView()
	self.root_wnd = ccui.Layout:create()
    self.root_wnd:setAnchorPoint(cc.p(1, 0))
    self.root_wnd:setContentSize(cc.size(195, 63))
    -- 背景
    
    local res = PathTool.getResFrame("common", "common_30010")
    self.bubble_bg = createImage(self.root_wnd,res,97.5,31.5,cc.p(0.5,0.5),true)
    self.bubble_bg:setScale9Enabled(true)
    self.bubble_bg:setCapInsets(cc.rect(10,10,1,1))
    
    -- 内容
	self.target_label = createRichLabel(18, 63 , cc.p(0,0.5), cc.p(20,16), 1, 1, 210)
	self.root_wnd:addChild(self.target_label)
end

-- 设置内容 msg  is_turn 是否翻转
function StoryBubble:setData(msg,is_turn)
	local role_vo =  RoleController:getInstance():getRoleVo()
	local content = string.gsub(msg,"~n",role_vo.name)
	is_turn = is_turn or false
    content = WordCensor:getInstance():relapceFaceIconTag(content)[2]       -- 转换聊天泡泡
	self.target_label:setString(content)
    local label_size = self.target_label:getContentSize() 
	local w = label_size.width+40
	if w < 195 then
		w = 195
	end
    local space_y = 8
    local off_h = 21            -- 箭头的高度
    local h = self.target_label:getContentSize().height + off_h + 2 * space_y
	if h < 58 then
		h = 58
	end

    -- 这里之所以减掉16,主要是减掉箭头的高度
    self.target_label:setPositionY(h * 0.5 + off_h * 0.5)

	self.bubble_bg:setContentSize(cc.size(w,h))
    self.root_wnd:setContentSize(self.bubble_bg:getContentSize())
    self.bubble_bg:setPosition(w*0.5, h*0.5)
    if is_turn then
    	self.bubble_bg:setScaleX(-1)
    end
end

function StoryBubble:getRootWnd()
    return self.root_wnd
end

function StoryBubble:setAnchorPoint(x, y)
    self.root_wnd:setAnchorPoint(cc.p(x, y))
end

function StoryBubble:setPosition(x, y)
    self.root_wnd:setPosition(cc.p(x, y))
end

function StoryBubble:setParent(parent_wnd)
    if not tolua.isnull(self.root_wnd) then
        self.root_wnd:removeFromParent()
        if not tolua.isnull(parent_wnd) then
            parent_wnd:addChild(self.root_wnd)
        end
    end
end

function StoryBubble:__delete()
    if self.close_call_back then
        self.close_call_back()
    end
    if not tolua.isnull(self.root_wnd) then
        self.root_wnd:removeAllChildren()
        self.root_wnd:removeFromParent()
    end
    self.root_wnd = nil
end

function StoryBubble:addCloseCallBack(call_back)
    self.close_call_back = call_back
end
