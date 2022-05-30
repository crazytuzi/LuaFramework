-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
-- [文件功能:技能按钮tips]
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
BattleSkillTips = BattleSkillTips or BaseClass()
function BattleSkillTips:__init(delay,parent,offset_y)
	if parent ~= nil then
		self.parent = parent
	end
    self.offset_y = offset_y or 0
    self.delay = delay or 3
    self.WIDTH = 370  --界面的宽度
    self.HEIGHT = 190
    
    self:createRootWnd()
end

function BattleSkillTips:createRootWnd()
    self:LoadLayoutFinish()
    self:registerCallBack()
end


function BattleSkillTips:LoadLayoutFinish()
    self.screen_bg = ccui.Layout:create()
    self.screen_bg:setAnchorPoint(cc.p(0, 0))
    self.screen_bg:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    self.screen_bg:setTouchEnabled(true)
    self.screen_bg:setSwallowTouches(false)

    self.root_wnd = ccui.Widget:create()
    self.root_wnd:setTouchEnabled(true)
    self.root_wnd:setAnchorPoint(cc.p(0, 0))
    self.root_wnd:setPosition(cc.p(0, 0))
    self.screen_bg:addChild(self.root_wnd)

    self.info_layer = ccui.Layout:create()
    self.info_layer:setCascadeOpacityEnabled(true)
    self.info_layer:setOpacity(0)
    self.info_layer:setScale(0)
    self.screen_bg:addChild(self.info_layer)
    self.info_layer:runAction(cc.Spawn:create(cc.FadeIn:create(0.2),cc.ScaleTo:create(0.2,1)))
               
end

function BattleSkillTips:setSkillInfo(data_vo,offset_y)
    self.offset_y = offset_y or 0
	local size = self.parent:getContentSize()
    self.info_layer:setPosition(SCREEN_WIDTH -  self.WIDTH/2,size.height)
    self.info_layer:setVisible(true)
    self.info_layer:setContentSize(cc.size(200,self.HEIGHT))
    local black = ccui.ImageView:create(PathTool.getResFrame("common", "common_90005"), LOADTEXT_TYPE_PLIST)
    black:setAnchorPoint(0.5,1)
    black:setScale9Enabled(true)
    black:setCapInsets(cc.rect(24, 29, 27, 18))
    self.info_layer:addChild(black)
    local black_bg_2 = ccui.ImageView:create(PathTool.getResFrame("common", "common_1016"), LOADTEXT_TYPE_PLIST)
    black_bg_2:setScale9Enabled(true)
    black_bg_2:setAnchorPoint(0.5,0)
    black:addChild(black_bg_2)
    local content = createRichLabel(22, 43, cc.p(0.5, 1), nil, 5, 0, self.WIDTH -20)
    local content3 = createRichLabel(20, 44, cc.p(0, 0), nil, 5, 0, self.WIDTH -20)
    local content2 = createRichLabel(20, 4, cc.p(0.5, 0), nil, 5, 0, self.WIDTH -45)
    local data = Config.SkillData.data_get_skill(data_vo)
    local str = string.format("<div fontcolor=#0x14b4f0 fontsize=22>%s\n</div>",data.name)
    content:setString(analyzeDesc(str,30,nil,30))
    local str3 = string.format("<div>%s%s：%s\n</div>",TI18N("冷却"),TI18N("回合"),data.cd)
    content3:setString(analyzeDesc(str3,30,nil,30))
    local str2 = string.format("<div>%s</div>", data.des)
    content2:setString(analyzeDesc(str2,30,nil,30))
    local size2 = content:getSize()
    local size3 = content2:getSize()
    local size4 = content3:getSize()
    
    -- local icon_scale = 1
    -- local icon_bg = createSprite(PathTool.getResFrame("battle", "button_bg"),60,98,black_bg, cc.p(0.5,1))
    -- local icon = createSprite( PathTool.getSkillRes(data.icon),7,6,icon_bg, cc.p(0,0),LOADTEXT_TYPE)\
    black:setPosition(0, self.HEIGHT/2)
    black:addChild(content)
    black:addChild(content3) 
    black:addChild(content2)
    black_bg_2:setContentSize(cc.size(350,1))
    local height = size2.height + size3.height + 60 + size4.height + 1
    content:setPosition(self.WIDTH/2,height - 8)
    content2:setPosition(self.WIDTH/2,height - size3.height  - size2.height - 20 )
    black_bg_2:setPosition(self.WIDTH/2, height - size3.height  - size2.height - 40)
    content3:setPosition(25,10)
    black:setContentSize(self.WIDTH,height)
    self.info_layer:setContentSize(self.WIDTH, size2.height)
    self.info_layer:setPosition(SCREEN_WIDTH - self.WIDTH * 1.8 ,height + self.offset_y)
end


function BattleSkillTips:registerCallBack()
    self.screen_bg:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.began then
            TipsManager:getInstance():hideTips()
        end
    end)
end


function BattleSkillTips:setPosition(x, y)
    self.root_wnd:setAnchorPoint(cc.p(0, 1))
    self.root_wnd:setPosition(cc.p(x, y))
end



function BattleSkillTips:setPos(x, y)
    self.root_wnd:setPosition(cc.p(x, y))
end

function BattleSkillTips:getContentSize()
    return self.root_wnd:getContentSize()
end


function BattleSkillTips:getScreenBg()
    return self.screen_bg
end


function BattleSkillTips:isOpen()
    return self.is_close
end

function BattleSkillTips:open()
	local parent = ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG)
    parent:addChild(self.screen_bg)
    doStopAllActions(self.screen_bg)
    delayRun(self.screen_bg, self.delay, function()
        TipsManager:getInstance():hideTips()
    end)
end


function BattleSkillTips:close()
	self.info_layer:runAction(cc.Sequence:create(cc.FadeOut:create(0.2),cc.CallFunc:create(function()
        doStopAllActions(self.screen_bg)
    	self.screen_bg:removeFromParent()
        self.is_close = true
	end)))
 end
