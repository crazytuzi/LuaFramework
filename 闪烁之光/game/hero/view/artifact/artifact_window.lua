-- --------------------------------------------------------------------
-- 竖版神器合成重铸操作界面
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
ArtifactWindow = ArtifactWindow or BaseClass(BaseView)

function ArtifactWindow:__init()
    self.ctrl = HeroController:getInstance()
    self.is_full_screen = false
    self.title_str = TI18N("符文")
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("artifact","artifact"), type = ResourcesType.plist },
    }

    self.win_type = WinType.Big    
    self.btn_list = {}
    self.view_list = {}
    self.select_btn = nil
end

function ArtifactWindow:open_callback()
    local csbPath = PathTool.getTargetCSB("hero/tab_btn_panel")
    local root = cc.CSLoader:createNode(csbPath)
    self.container:addChild(root,10)
    local size= self.container:getContentSize()
    root:setAnchorPoint(cc.p(0.5,0))
    root:setPosition(cc.p(size.width/2,735))
    
    self.btn_panel = root:getChildByName("main_panel")

    local list = {[1]=TI18N("升星"),[2]=TI18N("重铸")}
    for i=1,2 do
        local btn = self.btn_panel:getChildByName("tab_btn_"..i)
        if btn then 
            local tab = {}
            tab.btn = btn
            tab.select_bg = btn:getChildByName("select_bg")
            tab.select_bg:setVisible(false)
            tab.title =  btn:getChildByName("title")
            local str = list[i] or ""
            tab.title:setString(str)
            tab.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff)) 
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

function ArtifactWindow:register_event()
    if not self.select_item_event then 
        self.select_item_event = GlobalEvent:getInstance():Bind(HeroEvent.Artifact_Select_Event,function(data)
            if self.pre_panel then 
                self.pre_panel:clickFun(data)
            end
        end)
    end
end


function ArtifactWindow:changeTabIndex(index)
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
        self.pre_panel:setData(self.data, self.partner_id)
    end
end


function ArtifactWindow:createSubPanel(index)
    local panel = self.view_list[index]
    if panel == nil then

        if index == 1 then
            panel = ArtifactComposePanel.new(self.data)
        elseif index == 2 then
            panel = ArtifactRecastPanel.new(self.data)
        end
        local size = self.container:getContentSize()
        panel:setPosition(cc.p(size.width/2,390))
        self.container:addChild(panel)
        self.view_list[index] = panel
    end
    return panel
end

function ArtifactWindow:openRootWnd(index,data,partner_id)
    self.data = data
    self.partner_id = partner_id
    index = index or 1
    self:changeTabIndex(index)
end
--[[
    @desc: 设置标签页面板数据内容
    author:{author}
    time:2018-05-03 21:57:09
    return
]]
function ArtifactWindow:setPanelData()
end

function ArtifactWindow:close_callback()
    self.ctrl:openArtifactWindow(false)
    if self.select_item_event then 
        GlobalEvent:getInstance():UnBind(self.select_item_event)
        self.select_item_event = nil
    end

    for i,v in pairs(self.view_list) do 
        v:DeleteMe()
    end
    self.view_list = nil
end
