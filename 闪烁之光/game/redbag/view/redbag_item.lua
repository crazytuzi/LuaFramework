-- --------------------------------------------------------------------
-- 红包子项
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
RedBagItem = class("RedBagItem", function()
    return ccui.Widget:create()
end)

function RedBagItem:ctor()
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function RedBagItem:config()
    self.size = cc.size(262,327)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)
    self:setAnchorPoint(cc.p(0.5,0.5))
    self.is_show_point = false
    self.open_type = 0
    self.star_list = {}
    self.is_can_get = true
end
function RedBagItem:layoutUI()
    local csbPath = PathTool.getTargetCSB("redbag/redbag_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.label_panel = self.main_panel:getChildByName("label_panel")

    --标题
    self.title = self.main_panel:getChildByName("title")
    self.title:setString(TI18N("我是红包标题"))
    --中间资产图标
    self.coin_icon = self.main_panel:getChildByName("coin_icon")
    local res = PathTool.getResFrame("redbag","redbag_4")
    loadSpriteTexture(self.coin_icon,res,LOADTEXT_TYPE_PLIST)
    
    --领完变灰
    self.black_bg = self.main_panel:getChildByName("black_bg")
    self.black_bg:setVisible(false)
    --已领取标志
    self.finish_icon = self.main_panel:getChildByName("finish_icon")
    self.finish_icon:setVisible(false)

    --红包状态
    self.status_icon = self.main_panel:getChildByName("status_icon")
    self.status_icon:setVisible(false)

    --点击领取
    self.get_status = self.main_panel:getChildByName("get_status")
    self.get_status:setVisible(true)
    
    --红包描述
    self.desc_label = createRichLabel(20,Config.ColorData.data_color4[1],cc.p(0.5,1),cc.p(self.size.width/2,288),nil,nil,600)
    self.label_panel:addChild(self.desc_label)
    self.desc_label:setString(TI18N("我是描述描述描述"))
    --发红包的人
    self.role_name = createRichLabel(20,cc.c4b(0x70,0x00,0x16,0xff),cc.p(0.5,0),cc.p(self.size.width/2,20),nil,nil,500)
    self.label_panel:addChild(self.role_name)
    self.role_name:setString(string.format(TI18N("来自<div fontcolor=#ffea96>我是名字哦</div>(成员)")))

    self.other_label = createRichLabel(22,Config.ColorData.data_color4[1],cc.p(0.5,0),cc.p(self.size.width/2,20),nil,nil,500)
    self.label_panel:addChild(self.other_label)
    self.other_label:setVisible(false)
    self.other_label:setString(TI18N("向公会发送大量金币"))
end

function RedBagItem:setData(vo)
    if not vo then return end
    local data = vo
    if vo.open_type and vo.open_type ==1 then
        data = vo.data
    end
    self.open_type = vo.open_type or 0
    self.data = data
    local res = PathTool.getResFrame("redbag","redbag_4")
    if self.open_type == 1 then
        local str = data.name or ""
        self.title:setString(str)
        self.role_name:setString("")
        self.desc_label:setString("")
        self.get_status:setVisible(false)
        self.other_label:setVisible(true)
        local desc = data.desc or ""
        self.other_label:setString(desc)
        res = PathTool.getResFrame("redbag",data.res_name)
    else
        local name = data.name or ""
        local post_num = data.post or 3
        local post_config =  Config.GuildData.data_position[post_num]
        if post_config then
            local post = post_config.name or ""
            local str = string.format(TI18N("来自<div fontcolor=#ffea96>%s</div>(%s)"),name,post)
            self.role_name:setString(str)

        end
        local config = Config.GuildData.data_guild_red_bag[data.type]
        if config then 
            local name = config.name or ""
            self.title:setString(name)
            --if config.assets and config.assets == "gold" then 
                res = PathTool.getResFrame("redbag",config.res_name)
            --end
            self.desc_label:setString(config.desc)
        end
        --[[local msg_config = Config.GuildData.data_guild_red_bag_desc[data.msg_id]
        if msg_config then 
            local msg = msg_config.msg or ""
            self.desc_label:setString(msg)
        end--]]

        self:updateStatus(data)
    end
    loadSpriteTexture(self.coin_icon,res,LOADTEXT_TYPE_PLIST)
end

function RedBagItem:updateStatus(data)
    if not data then return end
    self.is_can_get = true
    --是否已经领完
    local get_num = data.num
    local max_num = data.max_num
    self.is_finish = false
    if get_num >=max_num then 
        self.is_finish = true
    end

    --是否过期
    local less_time = data.time - GameNet:getInstance():getTime()
    self.is_out_time = false
    if less_time <=0 then 
        self.is_out_time = true
    end

    --是否自己领完了
    self.my_status = data.flag

    doStopAllActions(self.get_status)
    if self.my_status == 1 then 
        self.finish_icon:setVisible(true)
        self.is_can_get = false
    else
        self.finish_icon:setVisible(false)
    end

    local res 
    if self.is_finish ==true then 
        res = PathTool.getResFrame("redbag","txt_cn_redbag_3")
        self.is_can_get = false
    elseif self.is_out_time ==true then 
        res = PathTool.getResFrame("redbag","txt_cn_redbag_1")
        self.is_can_get = false
    end

    if res then 
        self.status_icon:loadTexture(res,LOADTEXT_TYPE_PLIST)
    end
    local bool = self.is_finish or self.is_out_time
    self.status_icon:setVisible(bool)
    local bool = self.is_finish or self.is_out_time or self.my_status == 1
    self.black_bg:setVisible(bool)
    
    breatheShineAction(self.get_status, 0.8, 0.8)
    self.get_status:setVisible(self.is_can_get)
end
--事件
function RedBagItem:registerEvents()
    self:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.call_fun then
                self:call_fun(self.data)
            end
        end
    end)
end
function RedBagItem:getIsCanGet()
    return self.is_can_get
end
function RedBagItem:clickHandler()
    if self.call_fun then 
        self:call_fun(self.data)
    end
end
function RedBagItem:addCallBack(call_fun)
    self.call_fun =call_fun
end
function RedBagItem:showBlackBg(bool)
    bool = bool or false

    self.black_bg:setVisible(bool)
end

function RedBagItem:setVisibleStatus(bool)
    self:setVisible(bool)
end


function RedBagItem:getData(  )
    return self.data
end

function RedBagItem:DeleteMe()
end



