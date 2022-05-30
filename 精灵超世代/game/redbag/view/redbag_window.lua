-- --------------------------------------------------------------------
-- 公会红包
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
RedBagWindow = RedBagWindow or BaseClass(BaseView)

function RedBagWindow:__init(extend_id)
    self.ctrl = RedbagController:getInstance()
    self.is_full_screen = false
    self.title_str = TI18N("公会红包")
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("redbag","redbag"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("guildboss","guildboss"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_42"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_43"), type = ResourcesType.single },
    }
    self.layout_name = "redbag/redbag_btn_panel"
    self.extend_id = extend_id
    self.win_type = WinType.Big  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.btn_list = {}
    self.view_list = {}
    self.select_btn = nil
end

function RedBagWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container , 1)
    local main_panel = main_container:getChildByName("main_panel")
    
    self.container = main_panel:getChildByName("container")
    main_panel:getChildByName("win_title"):setString(TI18N("公会红包"))
    local tab_container = main_panel:getChildByName("tab_container")
    local list = {[1]=TI18N("发红包"),[2]=TI18N("抢红包"),[3]=TI18N("发红包榜")}
    for i=1,3 do
        local btn = tab_container:getChildByName("tab_btn_"..i)
        if btn then 
            local tab = {}
            tab.btn = btn
            tab.select_bg = btn:getChildByName("select_bg")
            tab.select_bg:setVisible(false)
            tab.title =  btn:getChildByName("title")
            tab.red_point = btn:getChildByName("red_point")
            tab.red_point:setVisible(false)
            if i == 2 then
                local is_red = RedbagController:getInstance():getModel():getIsHaveRedBag()
                tab.red_point:setVisible(is_red)
                tab.red_status = is_red
            elseif i == 1 then
                local is_red = RedbagController:getInstance():getModel():getSendRedBagStatue()
                tab.red_point:setVisible(is_red)
                tab.red_status = is_red
            end
            local str = list[i] or ""
            tab.title:setString(str)
            tab.index = i

            self.btn_list[i] = tab
            btn:addTouchEventListener(function(sender, event_type) 
                if event_type == ccui.TouchEventType.ended then
                    playButtonSound2()
                    self:changeTabIndex(i)
                end
            end)
        end
    end
end

function RedBagWindow:register_event()
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            RedbagController:getInstance():openMainView(false)
        end 
    end)

    if self.update_red_status_event == nil then
        self.update_red_status_event = GlobalEvent:getInstance():Bind(GuildEvent.UpdateGuildRedStatus, function(type) 
            local is_red = RedbagController:getInstance():getModel():getIsHaveRedBag()
            self:updateSomeRedStatus(is_red)
            is_red = RedbagController:getInstance():getModel():getSendRedBagStatue()
            self:updateOneRedStatus(is_red)
		end)
	end
end

function RedBagWindow:updateSomeRedStatus(status)
    if self.btn_list and self.btn_list[2] then
        local btn = self.btn_list[2]
        btn.red_point:setVisible(status)
        btn.red_status = status
    end
end

function RedBagWindow:updateOneRedStatus(status)
    if self.btn_list and self.btn_list[1] then
        local btn = self.btn_list[1]
        btn.red_point:setVisible(status)
        btn.red_status = status
    end
end

function RedBagWindow:updateChoseRedStatus(  )
    for index,btn in pairs(self.btn_list) do
        if btn.red_status then
            if self.select_btn and self.select_btn.index == btn.index then
                btn.red_point:setVisible(false)
            else
                btn.red_point:setVisible(true)
            end
        end
    end
end

function RedBagWindow:changeTabIndex(index)
    if self.select_btn and self.select_btn.index == index then return end
    if self.select_btn then 
        self.select_btn.select_bg:setVisible(false)
        self.select_btn.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
    end
    if self.pre_panel then 
        self.pre_panel:setVisibleStatus(false)
    end
    self.pre_panel = self:createSubPanel(index)
    self.select_btn = self.btn_list[index] 
    if self.select_btn then 
        self.select_btn.select_bg:setVisible(true)
        self.select_btn.title:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
    end
    if self.pre_panel then 
        self.pre_panel:setVisibleStatus(true)
        self.pre_panel:setData(self.data )
    end
    if self.select_btn and self.select_btn.index == 3 then 
        self.ctrl:sender13545()
    end
    self:updateChoseRedStatus()
end


function RedBagWindow:createSubPanel(index)
    local panel = self.view_list[index]
    local size = self.container:getContentSize()
    if panel == nil then

        if index == 1 then
            panel = RedBagSendPanel.new(self.extend_id)
            panel:setPosition(cc.p(size.width/2,355))
        elseif index == 2 then
            panel = RedBagGetPanel.new()
            panel:setPosition(cc.p(size.width/2,375))
        elseif index == 3 then
            panel = RedBagRankPanel.new()
            panel:setPosition(cc.p(size.width/2,375))
        end
        self.container:addChild(panel)
        self.view_list[index] = panel
    end
    return panel
end

function RedBagWindow:openRootWnd(index,data)
    self.data = data
    index = index or 1
    local is_have_red = self.ctrl:getModel():getIsHaveRedBag() or false
    if is_have_red == true and index == 1 and not self.extend_id then 
        index = 2
    end
    self:changeTabIndex(index)
end
--[[
    @desc: 设置标签页面板数据内容
    author:{author}
    time:2018-05-03 21:57:09
    return
]]
function RedBagWindow:setPanelData()
end

function RedBagWindow:close_callback()
    if self.update_red_status_event then
        GlobalEvent:getInstance():UnBind(self.update_red_status_event)
        self.update_red_status_event = nil
    end
    self.ctrl:openMainView(false)
    for i,v in pairs(self.view_list) do 
        v:DeleteMe()
    end
    self.view_list = nil
end
