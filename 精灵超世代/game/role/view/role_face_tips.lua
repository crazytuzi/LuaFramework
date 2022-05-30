-- --------------------------------------------------------------------
-- 头像框tips
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
RoleFaceTips = RoleFaceTips or BaseClass(CommonUI)

function RoleFaceTips:__init()
	self.WIDTH = 366
    self.HEIGHT = 300
	self:initMainContainer()
end

function RoleFaceTips:initMainContainer()
    local win_size = cc.size(SCREEN_WIDTH, display.height)
    --父容器
    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setContentSize(win_size)
    self.root_wnd:setTouchEnabled(true)
    self.root_wnd:setSwallowTouches(false)
    local parent = ViewManager:getInstance():getLayerByTag( ViewMgrTag.MSG_TAG )
    parent:addChild(self.root_wnd)
    self:setCommonUIZOrder(self:getRootWnd())

    --主界面容器
    self.main_container = ccui.Widget:create()
    self.main_container:setTouchEnabled(true)
    self.main_container:setAnchorPoint(cc.p(0.5, 0.5))
    self.main_container:setContentSize(cc.size(self.WIDTH, self.HEIGHT))
    self.main_container:setPosition(cc.p(win_size.width/2, win_size.height/2))
    self.root_wnd:addChild(self.main_container)

    local res = PathTool.getResFrame("common","common_1034")
    self.background = createScale9Sprite(res, 0, 0)
	self.background:setContentSize(cc.size(self.WIDTH, self.HEIGHT))
	self.background:setAnchorPoint(cc.p(0, 0))
    self.background:setCapInsets(cc.rect(20, 20, 1, 1))
	self.main_container:addChild(self.background)
end

function RoleFaceTips:setData( type,data )
	self:registerEvents()
    --self:open()

    --self:setCascadeOpacityEnabled(self.root_wnd, true)
    self.type = type
    self.data = data
    if type == 1 then --头像

    elseif type == 2 then --头像框
    	if self.head == nil then
    		self.head = RoleFaceItem.new()
    		self.main_container:addChild(self.head)
    	end
    	self.head:setData(data)
    	self:createHeadInfo()
    elseif type == 3 then --称号
        self:createTitleInfo()
    end

    self:adjustSize()
end

function RoleFaceTips:createHeadInfo(  )
	if self.info_con == nil then
		self.info_con = ccui.Widget:create()
	    self.info_con:setAnchorPoint(cc.p(0, 0.5))
	    --self.info_con:setContentSize(cc.size(self.WIDTH, self.HEIGHT))
	    self.info_con:setPosition(cc.p(0, self.background:getContentSize().height/2))
	    self.background:addChild(self.info_con)

	    self.time = createRichLabel(18,Config.ColorData.data_new_color4[12],cc.p(0,1),cc.p(30,175))
    	self.info_con:addChild(self.time)
    	local val = ""
    	if self.data.expire_time>0 then
    		val = TimeTool.GetTimeFormatDay(self.data.expire_time*60)
    	else
    		val = TI18N("永久")
    	end
    	self.time:setString(string.format(TI18N("使用期限：%s"),val))

    	self.condition = createRichLabel(18,Config.ColorData.data_new_color4[6],cc.p(0,1),cc.p(30,140),0,0,190)
    	self.info_con:addChild(self.condition)
    	self.condition:setString(string.format(TI18N("激活条件：%s"),self.data.desc))

        local height = math.max(self.time:getContentSize().height+self.condition:getContentSize().height+90,230)
        self.info_con:setContentSize(self.WIDTH,height)
	end
end

function RoleFaceTips:createTitleInfo(  )
    if self.title_info_con == nil then
        self.title_info_con = ccui.Widget:create()
        self.title_info_con:setAnchorPoint(cc.p(0, 0.5))
        self.title_info_con:setContentSize(cc.size(self.WIDTH, self.HEIGHT))
        self.title_info_con:setPosition(cc.p(0, self.main_container:getContentSize().height/2))
        self.main_container:addChild(self.title_info_con)

        self.icon = createImage(self.title_info_con, nil, self.WIDTH*0.5, 260, cc.p(0.5,1), false)

        local face_id = self.data.base_id 
        local config = Config.HonorData.data_title[face_id]
        if config and config.res_id then 
            local res = PathTool.getTargetRes("honor","txt_cn_honor_"..config.res_id,false,false)
            self.icon:loadTexture(res,LOADTEXT_TYPE)
        end

        --属性
        local attr_title = createRichLabel(22,Config.ColorData.data_new_color4[6],cc.p(0,1),cc.p(30,154))
        self.title_info_con:addChild(attr_title)
        attr_title:setString(TI18N("属性加成："))
        local str = ""--TI18N("属性加成：")
        if self.data.attr and next(self.data.attr)~=nil then
            for k,v in pairs(self.data.attr) do
                local temp = string.format("%s",v[2])
                str = str..Config.AttrData.data_key_to_name[v[1]].."+"..temp.." "
            end
        else
            str = str..TI18N("无")
        end
        self.attr_label = createRichLabel(22,Config.ColorData.data_new_color4[6],cc.p(0,1),cc.p(attr_title:getPositionX()+attr_title:getContentSize().width,154),0,0,200)
        self.title_info_con:addChild(self.attr_label)
        self.attr_label:setString(str)

        self.time = createRichLabel(22,Config.ColorData.data_new_color4[17],cc.p(0,0),cc.p(30,162))
        self.title_info_con:addChild(self.time)
        local val = ""
        if self.data.expire_time>0 then
            if self.data.is_lock then
                val = TimeTool.GetTimeFormatDay(self.data.expire_time*60)
            else
                val = TimeTool.GetTimeFormatDay(self.data.expire_time - GameNet:getInstance():getTime())
            end
        else
            val = TI18N("永久")
        end
        self.time:setString(string.format(TI18N("使用期限：%s"),val))

        self.condition = createRichLabel(22,175,cc.p(0,1),cc.p(30,self.attr_label:getPositionY()-self.attr_label:getContentSize().height-10),0,0,300)
        self.title_info_con:addChild(self.condition)
        self.condition:setString(string.format(TI18N("获得条件：%s"),self.data.desc))

    end
end

function RoleFaceTips:adjustSize(  )
	if self.type == 1 then

	elseif self.type == 2 then --头像框
        self.main_container:setContentSize(cc.size(self.WIDTH, self.info_con:getContentSize().height))
        self.background:setContentSize(cc.size(self.WIDTH, self.info_con:getContentSize().height))
        self.info_con:setPosition(cc.p(0, self.background:getContentSize().height/2))
		self.head:setAnchorPoint(0,0.5)
		self.head:setPosition(210,self.info_con:getContentSize().height/2)
        self.head:setFaceNameBgY(-16)
		self.head:showLock(false)
        self.time:setPositionY(self.info_con:getContentSize().height-50)
        self.condition:setPositionY(self.time:getPositionY()-self.time:getContentSize().height-10)
    elseif self.type == 3 then --称号
        self.main_container:setContentSize(cc.size(self.WIDTH, self.HEIGHT))
        self.background:setContentSize(cc.size(self.WIDTH, self.HEIGHT))
	end
end

function RoleFaceTips:registerEvents()
	self.root_wnd:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:close()
        end
    end)
end

function RoleFaceTips:getRootWnd()
    return self.root_wnd
end

function RoleFaceTips:unRegisterEvent()

    
end


function RoleFaceTips:__close()
    --移除
    doRemoveFromParent(self:getRootWnd())
end


function RoleFaceTips:close()
    if tolua.isnull(self:getRootWnd()) then return end
    self:unRegisterEvent()
    self:__close()

end