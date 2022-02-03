-- --------------------------------------------------------------------
-- 我要变强主界面
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
StrongerMainWindow = StrongerMainWindow or BaseClass(BaseView)

function StrongerMainWindow:__init(partner_id)
	self.ctrl = StrongerController:getInstance()
    self.role_vo = RoleController:getInstance():getRoleVo()
    self.is_full_screen = true
    self.win_type = WinType.Full    
    --self.layout_name = "mall/mall_window"  
    self.title_str = TI18N("我要变强")     	
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("stronger","stronger"), type = ResourcesType.plist },
    }
    self.tab_info_list = {
        {label=TI18N("我要变强"), index=1, status=true},
        {label=TI18N("获取资源"), index=2, status=true},
        {label=TI18N("推荐阵容"), index=3, status=true},
        {label=TI18N("常见问题"), index=4, status=true},

    }
    self.partner_id = partner_id
    self.cur_index = nil
    self.pre_panel = nil
    self.view_list = {}
end

function StrongerMainWindow:open_callback()
    local list = HeroController:getModel():getMyPosList()
    for k,v in pairs(list) do
        local hero_data = HeroController:getModel():getHeroById(v.id)
        self.ctrl:sender11070(hero_data.partner_id)
    end
end

function StrongerMainWindow:openRootWnd(index)
    index = index or 1
    self:setSelecteTab(index,true)
    self.ctrl:setIsFirst(false)
    MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.stronger,false)
end

function StrongerMainWindow:selectedTabCallBack(index)
    self.cur_index = index

    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(false)
        end
    end

    self.pre_panel = self:createSubPanel(self.cur_index)
    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(true)
        end
    end
end

function StrongerMainWindow:createSubPanel(index)
    local panel = self.view_list[index]
    if panel == nil then
        if index ==1 then --变强
            panel = StrongerPanel.new(self.partner_id)
        elseif index == 2 then --获取资源
            panel = ResourcePanel.new()
        elseif index == 3 then --推荐阵容
            panel = RecommandPanel.new()
        elseif index == 4 then
            panel = ProblemPanel.new()--称号        
        end
        panel:setPosition(cc.p(10,15))
        self.container:addChild(panel)
        self.view_list[index] = panel
    end
    return panel
end

function StrongerMainWindow:register_event()

end

function StrongerMainWindow:close_callback()
    for i,v in pairs(self.view_list) do 
        v:DeleteMe()
    end

	self.ctrl:openMainWin(false)
end