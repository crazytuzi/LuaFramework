-- --------------------------------------------------------------------
-- 变强 推荐阵容宝可梦子项
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 
-- --------------------------------------------------------------------
RecommandHeroItem = class("RecommandHeroItem", function()
    return ccui.Widget:create()
end)

function RecommandHeroItem:ctor()
    self:config()
    self:layoutUI()
    self:registerEvents()
end

function RecommandHeroItem:config()
    self.size = cc.size(87,87)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)
    self.is_show_point = false
    self.star_list = {}
end

function RecommandHeroItem:layoutUI()
    local csbPath = PathTool.getTargetCSB("stronger/recommand_hero_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    
    self.main_container = self.root_wnd:getChildByName("main_container")
    self.bg = self.main_container:getChildByName("bg")
    self.head_bg = self.main_container:getChildByName("head_bg")
    self.career = self.main_container:getChildByName("career")
    self.rare_type = self.main_container:getChildByName("rare_type")

    --星级
    self.star_con = ccui.Widget:create()
    self.main_container:addChild(self.star_con)
end

--==============================--
--desc:设置数据
--time:2018-07-20 07:14:05
--@vo:这个是 Config.PartnerData.data_partner_base = bid
--@return 
--==============================--
function RecommandHeroItem:setData(vo)
    if vo == nil or vo.bid == nil then return end
    local data = Config.PartnerData.data_partner_base[vo.bid]
    if data then
        self.is_touch = vo.is_touch or false
        self.data = data
        self.data.is_die = false
        self:updateData(data)
        self:setGrey()
    end
end

function RecommandHeroItem:updateData(data)
    local head_id = data.bid or 0
    if self.head_id == nil or (self.head_id ~= nil and self.head_id ~= head_id ) then
        local res = PathTool.getHeadIcon(head_id)
        self.head_bg:loadTexture(res,LOADTEXT_TYPE)
        self.head_id = head_id
    end

    -- local lev = data.lev or 0
    -- self.hero_lev:setString(lev)

    local quality = data.rare_type or 1
    quality = quality +1
    if self.quality == nil or ( self.quality ~= nil and self.quality ~= quality ) then
        local res = PathTool.getQualityBg(quality)
        self.bg:loadTexture(res,LOADTEXT_TYPE_PLIST)
        self.quality = quality
    end

    self.career:loadTexture(PathTool.getCareerIcon(data.type),LOADTEXT_TYPE_PLIST)

    -- if self.star == nil or ( self.star ~= nil and self.star ~= data.star ) then
        self:createStar(data.star)
    --     self.star = data.star
    -- end
    if  self.is_touch and self.is_touch == true then 
        self.is_touch = false
        self:clickHandler()
    end
    
    local rare_type = data.rare_type or 0
    local res = PathTool.getResFrame("common","common_9003"..(4-rare_type))
    self.rare_type:loadTexture(res,LOADTEXT_TYPE_PLIST)
    self.rare_type:setScale(0.8)
    if data.form_type == PartnerConst.Fun_Form.Adventure_Act then
        if not data.p_config then
        --     self:updateExtendUI(data.p_config)
        -- else
            data.p_config = {id = data.partner_id,hp_per = 100,end_time = 0}
        end
        --self:updateExtendUI(data.p_config)
    end
end

function RecommandHeroItem:createStar(num)
    num = num or 0
    local size = cc.size(14*num,15)
    self.star_con:setContentSize(size)
    self.star_con:setPosition(cc.p(self.size.width/2,8))

    for i=1,num do 
        if not self.star_list[i] then 
            local res = PathTool.getResFrame("common","common_90013")
            local star = createImage(self.star_con,res,0,size.height/2,cc.p(0,0.5),true,0,false)
            star:setScale(0.9)
            self.star_list[i] = star
        end
        self.star_list[i]:setVisible(true)
        self.star_list[i]:setPosition(cc.p((i-1)*14-3,size.height/2))
    end
end

---变强未拥有的宝可梦置灰
function RecommandHeroItem:setGrey(  )
    if self.data then 
        local temp = HeroController:getModel():getHadHeroStarBybid(self.data.bid)
        if temp > 0 then
            setChildUnEnabled(false,self)
        else
            setChildUnEnabled(true,self)
        end 
    end
end

--事件
function RecommandHeroItem:registerEvents()
    self:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            self.touch_end = sender:getTouchEndPosition()
            local is_click = true
            if self.touch_began ~= nil then
                is_click =
                    math.abs(self.touch_end.x - self.touch_began.x) <= 20 and
                    math.abs(self.touch_end.y - self.touch_began.y) <= 20
            end
            if is_click == true then
                playButtonSound2()
				if sender.guide_call_back ~= nil then
					sender.guide_call_back(sender)
				end
                if self.call_fun then
                    self:call_fun(self.data)
                end
            end
        elseif event_type == ccui.TouchEventType.began then
            self.touch_began = sender:getTouchBeganPosition()
        end
    end)
end

function RecommandHeroItem:clickHandler()
    if self.call_fun then 
        self:call_fun(self.data)
    end
end
function RecommandHeroItem:addCallBack(call_fun)
    self.call_fun =call_fun
end

function RecommandHeroItem:DeleteMe()
	if self.data then
		self.data = nil
    end
    self:removeFromParent()
end