-- --------------------------------------------------------------------
-- 宝可梦查看
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
PokedexCheckWindow = PokedexCheckWindow or BaseClass(BaseView)

function PokedexCheckWindow:__init()
    self.ctrl = PokedexController:getInstance()
    self.is_full_screen = false
    self.title_str = TI18N("宝可梦详情")
    self.layout_name = "pokedex/pokedex_look_window"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("pokedex","pokedex"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3"), type = ResourcesType.single },
    }

    self.win_type = WinType.Big    
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.learn_btn = {}
    self.jie_btn = {}

    self.item_list = {}
    self.select_btn = nil
    self.tab_list = {}
    self.star_list = {}
    self.panel_list = {}
end

function PokedexCheckWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.title = self.main_panel:getChildByName("title")
    self.title:setString(self.title_str)
    self.tab_panel = self.main_panel:getChildByName("tab_panel") 
    self.bottom_panel = self.main_panel:getChildByName("bottom_panel")
    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.label_panel = self.main_panel:getChildByName("label_panel")
    self.label_panel:setTouchEnabled(false)

    local list = {[1]=TI18N("总览"),[2]=TI18N("属性"),[3]=TI18N("传记"),}
    for i=1,3 do
        local btn = self.tab_panel:getChildByName("tab_btn_"..i)
        local panel = self.main_panel:getChildByName("btn_panel_"..i)
        if btn and panel then 
            local tab = {}
            tab.btn = btn
            tab.select_bg = btn:getChildByName("select_bg")
            tab.select_bg:setVisible(false)
            tab.title = btn:getChildByName("title")
            tab.title:setString(list[i])
            tab.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff)) 
            tab.index = i
            tab.panel = panel
            tab.panel:setVisible(false)

            self.tab_list[i] = tab
        end
    end

    self:createBaseMessage()
end

function PokedexCheckWindow:register_event()
    for i,tab in pairs(self.tab_list) do
        tab.btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                self:changeTabIndex(tab.index)
            end
        end)
    end

    self.background:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self.ctrl:openCheckHeroWindow(false)
        end
    end)

    self.close_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self.ctrl:openCheckHeroWindow(false)
        end
    end)

    self.vedio_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            if self.data == nil or self.data.voice == nil then return end
            if self.data.voice == "" then
                message(TI18N("该宝可梦暂无配音"))
            else
                playPartnerSound(self.data.voice)
            end
        end
    end)

    self.comment_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            self.ctrl:openCommentWindow(true,self.data)
        end
    end)
end

function PokedexCheckWindow:createBaseMessage()
    --模型
    self.partner_model = PartnerBase.new(self.main_panel,false)
	self.partner_model:setPosition(cc.p(435,750))
    --星数
    --名字
    self.hero_name = createLabel(24,Config.ColorData.data_color4[1],nil,75,770,"",self.label_panel,0, cc.p(0,0))
    --稀有度
    self.rare_type = createImage(self.main_panel, nil, 30,840, cc.p(0,0), true, 1, false)
    --类型
    self.hero_type = createImage(self.main_panel, nil, 30,765, cc.p(0,0), true, 1, false)

    self.grow = createLabel(24, Config.ColorData.data_color4[1], nil, 73, 803, '', self.main_panel, 0, cc.p(0, 0))

    --描述
    self.desc_label = createRichLabel(20, Config.ColorData.data_color4[141], cc.p(0,1), cc.p(28,750), 0, 0, 200)
    self.label_panel:addChild(self.desc_label)
    --cv名字
    self.cv_name = createRichLabel(20, Config.ColorData.data_color4[141], cc.p(0,0), cc.p(35,595), 0, 0, 500)
    self.label_panel:addChild(self.cv_name)
    --cv声音按钮
    local res = PathTool.getResFrame("pokedex","pokedex_21")
    self.vedio_btn = createButton(self.main_panel,"", 50,540, nil, res, 24, Config.ColorData.data_color4[1])

     --评论按钮
    local res = PathTool.getResFrame("pokedex","pokedex_15")
    self.comment_btn = createButton(self.main_panel,TI18N("评论"), 615,850, nil, res, 20, Config.ColorData.data_color4[1])
    local label = self.comment_btn:getLabel()
    self.comment_btn:enableOutline(Config.ColorData.data_color4[9],2)
    label:setPosition(cc.p(25,4))

    self.star_con = ccui.Widget:create()
    self.main_panel:addChild(self.star_con)

    -- self.cv_name:setString("cv名字")

end
function PokedexCheckWindow:updateModel(data)
    if not data then return end
    local info = self.partner_model:getData()
    local is_update= true
    if info and info.bid == data.bid  then 
        is_update = false
    end
    if is_update == true then
        if data.clothes_id ~=0 then 
            self.partner_model:updateSpine(data.bid,true, data.clothes_id)
        else 
            self.partner_model:updateSpine(data.bid,false,data.clothes_id)
        end
        self.partner_model:setScale(1)
    end
    self.partner_model:setData(data)  
end

function PokedexCheckWindow:openRootWnd(data)
    self.data = data 
    self:updateMessage()
    self:changeTabIndex(1)
end

function PokedexCheckWindow:changeTabIndex(index)
    if self.select_btn and self.select_btn.index == index then return end

    if self.select_btn then 
        self.select_btn.select_bg:setVisible(false)
        self.select_btn.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff)) 
        self.select_btn.panel:setVisible(false)
    end

    self.select_btn = self.tab_list[index]
    if self.select_btn then 
        self.select_btn.select_bg:setVisible(true)
        self.select_btn.title:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
        self.select_btn.panel:setVisible(true)
    end

    if not self.panel_list[index] then 
        local panel =self:createPanel(index,self.select_btn.panel)
        self.panel_list[index] = panel
    end
    self.pre_panel = self.panel_list[index]

end
function PokedexCheckWindow:createPanel(index,panel_root)
    local panel
    if index == 1 then 
        panel = CheckAllPanel.new(self.data,true)
    elseif index == 2 then 
        panel = CheckAttrPanel.new(self.data)
    elseif index == 3 then 
        panel = CheckDescPanel.new(self.data)
    end
    panel_root:addChild(panel)
    return panel
end
function PokedexCheckWindow:updateMessage()
    if not self.data then return end
    local data = self.data
    local name = data.name or ""
    self.hero_name:setString(name)
    self.grow:setString(TI18N("资质:")..data.grow)
    local hero_type = data.type or 0
    local res = PathTool.getResFrame("common","common_900"..(45+hero_type))
    self.hero_type:loadTexture(res,LOADTEXT_TYPE_PLIST)

    local rare_type = data.rare_type or 3
    local res = PathTool.getResFrame("common","common_900"..(31-rare_type))
    self.rare_type:loadTexture(res,LOADTEXT_TYPE_PLIST)

    local config = Config.PartnerData.data_pokedex[data.bid]
    if not config then return end
    local desc = config.call_desc or ""
    self.desc_label:setString(desc)
    
    self.cv_name:setString("CV: "..config.cv_name)

    if self.partner_model then
        self:updateModel(data)
    end

    self:createStar(data.show_star)
end
function PokedexCheckWindow:createStar(num)
    num = num or 0
    local size = cc.size(23*3,23)
    self.star_con:setContentSize(size)
    self.star_con:setPosition(cc.p(135,855))

    for i=1,num do 
        if not self.star_list[i] then 
            local res = PathTool.getResFrame("common","common_90011")
            local star = createImage(self.star_con,res,0,size.height/2,cc.p(0,0.5),true,0,false)
            star:setScale(0.6)
            self.star_list[i] = star
        end
        self.star_list[i]:setVisible(true)
        self.star_list[i]:setPosition(cc.p((i-1)*23-3,size.height/2))
    end
end

--创建总览面板
function PokedexCheckWindow:createAllPanel(panel)
    if not panel then return end

    


    

end

function PokedexCheckWindow:setPanelData()
end

function PokedexCheckWindow:close_callback()
    self.ctrl:openCheckHeroWindow(false)
    if self.partner_model then 
        self.partner_model:DeleteMe()
        self.partner_model = nil
    end
    for i,v in pairs(self.panel_list) do
        v:DeleteMe()
    end
    self.panel_list = nil
end
