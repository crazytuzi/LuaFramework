-- --------------------------------------------------------------------
-- 图鉴伙伴查看总览
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------

CheckDescPanel = class("CheckDescPanel", function() 
	return ccui.Layout:create()
end)



function CheckDescPanel:ctor(data)
    self.data = data
    self.empty_res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3")
    
    self.size = cc.size(645,420)
    self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)
    self:setPosition(cc.p(self.size.width/2,self.size.height/2))
    
    self:createDescPanel()
	self:registerEvent()
end
function CheckDescPanel:createDescPanel()
    local size = cc.size(623,426)
    self.main_panel = ccui.Widget:create()
    self.main_panel:setContentSize(size)
    self:addChild(self.main_panel)
    self.main_panel:setPosition(cc.p(self.size.width/2,220))
    local res = PathTool.getResFrame("common","common_90024")
    local bg = createImage(self.main_panel, res, size.width/2,size.height/2, cc.p(0.5,0.5), true, 0, true)
    bg:setContentSize(size)
   

    local res = PathTool.getResFrame("common","common_90025")
    local title_bg = createImage(self.main_panel, res, size.width/2,378, cc.p(0.5,0), true, 0, true)
    title_bg:setContentSize(cc.size(617,44))
    -- title_bg:setCapInsets(cc.rect(170, 22, 1, 1))
    local res = PathTool.getResFrame("pokedex","pokedex_5")
    local icon = createImage(self.main_panel, res, 15,380, cc.p(0,0), true, 1, false)
    local title = createLabel(26,Config.ColorData.data_color4[175],nil,75,386,"",self.main_panel,0, cc.p(0,0))
    title:setString(TI18N("宝可梦传记"))

    --滑动
    self.desc_scorll = createScrollView(620,340,0,20,self.main_panel,ccui.ScrollViewDir.vertical)
    self.desc_label = createRichLabel(24, Config.ColorData.data_color4[175], cc.p(0,1), cc.p(20,350),10, 0, 580)
    self.desc_scorll:addChild(self.desc_label)
 

    --判断锁着状态
    local is_lock = false 
    local config = Config.PartnerData.data_pokedex[self.data.bid]
    if not config then return end
    local lock_list = config.lock or {}
    local str = ""
    local is_have = PokedexController:getInstance():getModel():isHavePartner(self.data.bid) or false
    if lock_list[1] then 
        if type(lock_list[1]) == "number" and lock_list[1] ==1 then --获得就解锁
            is_lock = not is_have
            str = TI18N("获得宝可梦解锁该宝可梦传记")
        elseif type(lock_list[1]) == "table" then
            local lock_type = lock_list[1][1] or 0
            local lock_val = lock_list[1][2] or 0
            if lock_type == 2 then 
                str = TI18N("该宝可梦星数达到")..lock_val..TI18N("星解锁传记")
                is_lock = true
                if is_have == true then 
                    -- local partner_vo = PartnerController:getInstance():getModel():getPartnerByBid(self.data.bid)
                    -- if partner_vo and partner_vo.star and partner_vo.star >= lock_val then 
                    --     is_lock = false
                    -- end
                    
                end
                
            elseif lock_type == 3 then 
                str = TI18N("该宝可梦突破+")..lock_val..TI18N("解锁传记")
                is_lock = true
                if is_have == true then 
                    -- local partner_vo = PartnerController:getInstance():getModel():getPartnerByBid(self.data.bid)
                    -- if partner_vo and partner_vo.break_lev and partner_vo.break_lev >= lock_val then 
                    --     is_lock = false
                    -- end
                    
                end
            end
            
        end
        self:showEmptyIcon(is_lock,str)
    end
    if is_lock == true then 
        self.desc_label:setString("")
        return 
    end
    
    if config then 
        self.desc_label:setString(config.desc or "")
        local max_height = math.max(self.desc_label:getSize().height,self.desc_scorll:getContentSize().height)
        self.desc_scorll:setInnerContainerSize(cc.size(self.desc_scorll:getContentSize().width,max_height))
        self.desc_label:setPositionY(self.desc_scorll:getContentSize().height)
    end
end
--显示空白
function CheckDescPanel:showEmptyIcon(bool,str)
    if not self.empty_con and bool == false then return end
    if not self.empty_con then 
        local size = cc.size(200,200)
        self.empty_con = ccui.Widget:create()
        self.empty_con:setContentSize(size)
        self.empty_con:setPosition(cc.p(310,220))
        self.main_panel:addChild(self.empty_con,100)

        local bg = createImage(self.empty_con, self.empty_res, size.width/2, size.height/2, cc.p(0.5,0.5), false)
        self.empty_label = createLabel(24,Config.ColorData.data_color4[175],nil,size.width/2,-10,"",self.empty_con,0, cc.p(0.5,0))
    end
    local str = str or ""
    self.empty_label:setString(str)
    self.empty_con:setVisible(bool)
end
function CheckDescPanel:registerEvent()
    -- body
end
function CheckDescPanel:DeleteMe()
	self:removeAllChildren()
    self:removeFromParent()
end