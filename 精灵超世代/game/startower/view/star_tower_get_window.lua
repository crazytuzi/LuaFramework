-- --------------------------------------------------------------------
-- 星命塔解锁
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
StarTowerGetWindow = StarTowerGetWindow or BaseClass(BaseView)

function StarTowerGetWindow:__init(tower)
    self.ctrl = StartowerController:getInstance()
    self.is_full_screen = false
    self.layout_name = "startower/star_tower_get"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("startower","startower"), type = ResourcesType.plist },
    }
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.tower = tower or 0
end

function StarTowerGetWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.background:setVisible(true)

    self.main_panel = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_panel, 1)
    self.main_panel:setTouchEnabled(false)
    self.ok_btn = self.main_panel:getChildByName("ok_btn") 
    self.ok_btn:setTitleText(TI18N("知道了"))
    local title = self.ok_btn:getTitleRenderer()   
    title:enableOutline(Config.ColorData.data_color4[264],2)

    self:createDesc()
    self:updateDesc()
end

function StarTowerGetWindow:register_event()
    self.ok_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self.ctrl:openGetWindow(false)
        end
    end)
end

function StarTowerGetWindow:createDesc()
    local size = self.main_panel:getContentSize()

    self.star_name = createLabel(26,Config.ColorData.data_color4[1],Config.ColorData.data_color4[9],size.width/2,385,"",self.main_panel,2,cc.p(0.5,0))

    self.star_desc =   createRichLabel(26,Config.ColorData.data_color4[1],cc.p(0.5,1),cc.p(size.width/2,360),nil,nil,500)
    self.main_panel:addChild(self.star_desc)
end

function StarTowerGetWindow:updateDesc()
    if self.tower == 0 then return end
    local config = Config.StarTowerData.data_award_list
    local data
    for i,v in pairs(config) do
        if v.lev and v.lev == self.tower then 
            if v.extend and v.extend[1] then 
                local item_config = Config.ItemData.data_get_data(v.extend[1])
                data = item_config
            end
            
        end
    end
    local size = self.main_panel:getContentSize()
    if not data then return end
    if not self.head_icon then
        self.head_icon = BackPackItem.new(true)
        self.main_panel:addChild(self.head_icon, 1000)
        local bg = self.head_icon:getBackground()
        bg:setVisible(false)
        self.head_icon:setData(data)
    end
    
    self.head_icon:setPosition(cc.p(size.width/2,500))
    self.head_icon:setAnchorPoint(cc.p(0.5,0.5))
    self.head_icon:setScale(1.2)
    local desc = data.desc or ""

    self.star_desc:setString(desc)

    if data.eqm_set then 
        local name = Config.StarData.data_star_name[data.eqm_set] or ""
        self.star_name:setString(name)
    end
end

function StarTowerGetWindow:openRootWnd()
    playOtherSound("c_get")
    self:handleEffect(true)
end

--[[
    @desc: 设置标签页面板数据内容
    author:{author}
    time:2018-05-03 21:57:09
    return
]]
function StarTowerGetWindow:setPanelData()
end

function StarTowerGetWindow:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
        if not tolua.isnull(self.main_panel) and self.play_effect == nil then
            local size = self.main_panel:getContentSize() 
            self.play_effect = createEffectSpine(Config.EffectData.data_effect_info[145], cc.p(size.width*0.5, size.height*0.5+10), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.main_panel:addChild(self.play_effect, 1)
        end
	end
end 

function StarTowerGetWindow:close_callback()
    self.ctrl:openGetWindow(false)
    self:handleEffect(false)
    -- 关闭面板的时候做一次事件,允许可以播放剧情或者引导
	GlobalEvent:getInstance():Fire(BattleEvent.CLOSE_RESULT_VIEW)
    if self.bottom_head then 
        self.bottom_head:DeleteMe()
        self.bottom_head = nil
    end
    if self.head_icon then 
        self.head_icon:DeleteMe()
        self.head_icon = nil
    end
end







