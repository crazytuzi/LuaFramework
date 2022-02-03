---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/10/17 15:46:08
-- @description: 圣夜奇境 工会排行界面
---------------------------------
local _controller = MonopolyController:getInstance()
local _model = _controller:getModel()

MonopolyGuildRankPanel = class("MonopolyGuildRankPanel",function()
    return ccui.Layout:create()
end)

function MonopolyGuildRankPanel:ctor(step_id)
	self.step_id = step_id
    self.is_init = true
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("monopoly/monopoly_rank_guild_panel"))

    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    self.scroll_container = self.root_wnd:getChildByName("scroll_container")
    self.empty_bg = self.scroll_container:getChildByName("empty_bg")
    self.empty_bg:setVisible(false)
    loadSpriteTexture(self.empty_bg, PathTool.getPlistImgForDownLoad("bigbg", "bigbg_3"), LOADTEXT_TYPE)
    self.desc_label = self.empty_bg:getChildByName("desc_label")
    self.desc_label:setPositionX(self.empty_bg:getContentSize().width / 2)
    self.desc_label:setString(TI18N("暂无记录"))

    local title_bg = self.root_wnd:getChildByName("title_bg")
    title_bg:getChildByName("title_1"):setString(TI18N("排名"))
    title_bg:getChildByName("title_2"):setString(TI18N("公会名称"))
    title_bg:getChildByName("title_3"):setString(TI18N("等级"))
    title_bg:getChildByName("title_4"):setString(TI18N("成员"))
    title_bg:getChildByName("title_5"):setString(TI18N("总伤害"))

    local scroll_size = self.scroll_container:getContentSize()
    local size = cc.size(scroll_size.width, scroll_size.height-70)
    local setting = {
        item_class = MonopolyGuildRankItem,
        start_x = 4,
        space_x = 4,
        start_y = 0,
        space_y = 0,
        item_width = 614,
        item_height = 125,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.scroll_view = CommonScrollViewLayout.new(self.scroll_container, nil, nil, nil, size, setting)

    local my_container = self.root_wnd:getChildByName("my_container")
    local my_rank_title = my_container:getChildByName("my_rank_title")
    my_rank_title:setString(TI18N("我的排名"))

    self.rank_img = my_container:getChildByName("rank_img")
    self.rank_img:setVisible(false)
    self.rank_x = self.rank_img:getPositionX()
    self.rank_y = self.rank_img:getPositionY()

    self.no_rank = my_container:getChildByName("no_rank")
    self.no_rank:setString(TI18N("未上榜"))
    self.no_rank:setVisible(false)
    self.my_rank_txt = my_container:getChildByName("rank_id")

    self.my_guile_name_txt = createLabel(24,175,nil,204,60,"",my_container,nil, cc.p(0.5, 0.5))
    self.my_chairman_txt = createLabel(20,186,nil,204,32,"",my_container,nil, cc.p(0.5,0.5))
    self.my_guild_lev_txt = createLabel(24,175,nil,342,57,"",my_container,nil, cc.p(0.5,0.5))
    self.my_guild_num_txt = createLabel(24,175,nil,425,57,"",my_container,nil, cc.p(0.5,0.5))
    self.my_guild_hurt_txt = createRichLabel(24, 186,cc.p(0.5,0.5), cc.p(525,57), 0, 0, 500)
	my_container:addChild(self.my_guild_hurt_txt)

    self.my_container = my_container

    self:registerEvent()
end

function MonopolyGuildRankPanel:registerEvent()
    if self.update_rank_event == nil then
        self.update_rank_event = GlobalEvent:getInstance():Bind(MonopolyEvent.Get_Guild_Rank_Data_Event, function(data) 
            if data and data.id == self.step_id then
            	self:updateRankList(data)
            end
        end)
    end
end

function MonopolyGuildRankPanel:setNodeVisible(status)
    self:setVisible(status)
end

function MonopolyGuildRankPanel:addToParent()
    -- 窗体打开只请求一次，不是标签显示
    if self.is_init == true then
    	if self.step_id then
    		_controller:sender27503(self.step_id, 1)
    	end
        self.is_init = false
    end
end

function MonopolyGuildRankPanel:updateRankList(data)
    local role_vo = RoleController:getInstance():getRoleVo()
    if data and role_vo then
        self.my_guile_name_txt:setString(data.r_name or "暂无")
        self.my_chairman_txt:setString(data.r_leader_name or "暂无")
        self.my_guild_lev_txt:setString(data.r_lev or 0)
        self.my_guild_num_txt:setString(string.format("%d/%d", data.r_member or 0, data.r_member_max or 0))
        self.my_guild_hurt_txt:setString(MoneyTool.GetMoneyWanString(data.r_dps or 0))

        local my_rank = data.r_rank or 0
        if my_rank <= 3 then
            self.my_rank_txt:setVisible(false)
            if my_rank == 0 then
                self.rank_img:setVisible(false)
                self.no_rank:setVisible(true)
            else
                self.no_rank:setVisible(false)
                local res_id = PathTool.getResFrame("common", string.format("common_200%s", my_rank))
                if self.rank_res_id ~= res_id then
                    self.rank_res_id  = res_id
                    loadSpriteTexture(self.rank_img, res_id, LOADTEXT_TYPE_PLIST)
                end
                self.rank_img:setVisible(true)
            end
        else
            self.my_rank_txt:setVisible(true)
            self.my_rank_txt:setString(my_rank)
            self.rank_img:setVisible(false)
        end

        if data.guild_stage_rank ~= nil and next(data.guild_stage_rank) ~= nil then
            table.sort(data.guild_stage_rank, SortTools.KeyLowerSorter("rank"))
            self.scroll_view:setData(data.guild_stage_rank)
            self.empty_bg:setVisible(false)
        else
            self.empty_bg:setVisible(true)
        end
    end
end

function MonopolyGuildRankPanel:DeleteMe()
    if self.update_rank_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_rank_event)
        self.update_rank_event = nil
    end
    if self.role_head then
    	self.role_head:DeleteMe()
    	self.role_head = nil
    end
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
end

------------------------------@ item
MonopolyGuildRankItem = class("MonopolyGuildRankItem",function()
    return ccui.Widget:create()
end)

function MonopolyGuildRankItem:ctor()
    self.width = 614
	self.height = 125
	self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(self.width,self.height))
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setTouchEnabled(false) 

    self:configUI()
end

function MonopolyGuildRankItem:configUI(  )
	--底内框 
    self.back = ccui.Widget:create()
    self.back:setCascadeOpacityEnabled(true)
    self.back:setContentSize(cc.size(self.width, self.height))
    self.back:setAnchorPoint(cc.p(0, 0))
    self:addChild(self.back)

    local res = PathTool.getResFrame("common","common_1029")
    self.background = createImage(self.back,res,self.width/2,self.height/2,cc.p(0.5,0.5),true,0,true)
    self.background:setContentSize(cc.size(self.width, self.height))

	self.rank_icon = createImage(self, nil, 60,self.height/2, cc.p(0.5,0.5), true, 1, false)
	self.rank_index =  createLabel(30,186,nil,50,40,"",self,0, cc.p(0.5,0),"fonts/title.ttf")

	self.my_guile_name_txt = createLabel(24,175,nil,197,80,"",self,nil, cc.p(0.5, 0.5))
    self.my_chairman_txt = createLabel(20,186,nil,197,50,"",self,nil, cc.p(0.5,0.5))
    self.my_guild_lev_txt = createLabel(24,175,nil,335,62,"",self,nil, cc.p(0.5,0.5))
    self.my_guild_num_txt = createLabel(24,175,nil,431,62,"",self,nil, cc.p(0.5,0.5))
    self.my_guild_hurt_txt = createRichLabel(24, 186,cc.p(0.5,0.5), cc.p(543,62), 0, 0, 500)
    self:addChild(self.my_guild_hurt_txt)
end


function MonopolyGuildRankItem:setData(data)
    if not data then return end

    self.index = data.rank or 0
	self.rank_index:setString(self.index)
	if self.index >= 1 and self.index <= 3 then
        self.rank_index:setVisible(false)
        self.rank_icon:setVisible(true)
		self.rank_icon:loadTexture(PathTool.getResFrame("common","common_200"..self.index),LOADTEXT_TYPE_PLIST)
		self.rank_icon:setScale(0.7)
    else
        self.rank_index:setVisible(true)
        self.rank_icon:setVisible(false)
    end

    self.my_guile_name_txt:setString(data.name or "")
    self.my_chairman_txt:setString(data.leader_name or "")
    self.my_guild_lev_txt:setString(data.lev or 0)
    self.my_guild_num_txt:setString(string.format("%d/%d", data.member or 0, data.member_max or 0))
    self.my_guild_hurt_txt:setString(MoneyTool.GetMoneyWanString(data.dps or 0))
end

function MonopolyGuildRankItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end